ESX = {}
ESX.Players = {}
ESX.Jobs = {}
ESX.Items = {}
ESX[Config.DoubleJob.table] = Config.DoubleJob.enable and {} or nil
Core = {}
Core.UsableItemsCallbacks = {}
Core.RegisteredCommands = {}
Core.Pickups = {}
Core.PickupId = 0
Core.PlayerFunctionOverrides = {}
Core.DatabaseConnected = false
Core.playersByIdentifier = {}

Core.vehicleTypesByModel = {}

AddEventHandler("esx:getSharedObject", function(cb)
  cb(exports.es_extended:getSharedObject())
end)

exports('getSharedObject', function()
  return ESX
end)

if GetResourceState('ox_inventory') ~= 'missing' then
  Config.OxInventory = true
  Config.PlayerFunctionOverride = 'OxInventory'
  SetConvarReplicated('inventory:framework', 'esx')
  SetConvarReplicated('inventory:weight', Config.MaxWeight * 1000)
end

local function StartDBSync()
  CreateThread(function()
    while true do
      Wait(10 * 60 * 1000)
      Core.SavePlayers()
    end
  end)
end

MySQL.ready(function()
  Core.DatabaseConnected = true
  if not Config.OxInventory then
    local items = MySQL.query.await('SELECT * FROM items')
    for k, v in ipairs(items) do
      ESX.Items[v.name] = {label = v.label, weight = v.weight, rare = v.rare, canRemove = v.can_remove}
    end
  else
    TriggerEvent('__cfx_export_ox_inventory_Items', function(ref)
      if ref then
        ESX.Items = ref()
      end
    end)

    AddEventHandler('ox_inventory:itemList', function(items)
      ESX.Items = items
    end)

    while not next(ESX.Items) do
      Wait(0)
    end
  end


  ESX.RefreshJobs()

  if Config.DoubleJob.enable then
    local users = MySQL.query.await("SHOW COLUMNS FROM users")
  
    if users then
      local faction_name, faction_grade
  
      for i = 1, #users do
        local r = users[i]
  
        if r.Field == Config.DoubleJob.database.users_dj_name then
          faction_name = true
        elseif r.Field == Config.DoubleJob.database.users_dj_grade then
          faction_grade = true
        end
      end
  
      if not faction_name then
        MySQL.query(("ALTER TABLE `users` ADD COLUMN `%s` varchar(50) DEFAULT '%s'"):format(Config.DoubleJob.database.users_dj_name, Config.DoubleJob.default.list.name))
      end
  
      if not faction_grade then
        MySQL.query(("ALTER TABLE `users` ADD COLUMN `%s` int(11) DEFAULT '%s'"):format(Config.DoubleJob.database.users_dj_grade, Config.DoubleJob.default.list_grade.grade))
      end
    end
  
    local db = {
      [Config.DoubleJob.database.list] = {
        exist = ("SELECT 1 FROM %s"):format(Config.DoubleJob.database.list),
        create = ([[CREATE TABLE `%s` (
          `name` varchar(50) NOT NULL,
          `label` varchar(50) NULL DEFAULT NULL,
          PRIMARY KEY (`name`) USING BTREE
        )]]):format(Config.DoubleJob.database.list),
        default_name = Config.DoubleJob.default.list.name,
        default_label = Config.DoubleJob.default.list.label,
      }, -- factions
      [Config.DoubleJob.database.list_grade] = {
        exist = ("SELECT 1 FROM %s"):format(Config.DoubleJob.database.list_grade),
        create = ([[CREATE TABLE `%s` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `%s` varchar(50) NULL DEFAULT NULL,
          `grade` int(11) NOT NULL,
          `name` varchar(50) NOT NULL,
          `label` varchar(50) NOT NULL,
          `salary` int(11) NOT NULL DEFAULT '0',
          `skin_male` longtext NOT NULL DEFAULT '{}',
          `skin_female` longtext NOT NULL DEFAULT '{}',
          PRIMARY KEY (`id`) USING BTREE
        )]]):format(Config.DoubleJob.database.list_grade, Config.DoubleJob.database.list_grade_name),
      } -- faction_grades
    }
  
    local dj_list = pcall(MySQL.scalar.await, db[Config.DoubleJob.database.list].exist)
    if not dj_list then
      local create = MySQL.query.await(db[Config.DoubleJob.database.list].create)
      if create then
        MySQL.query(("INSERT INTO %s (`name`, `label`) VALUES (?, ?)"):format(Config.DoubleJob.database.list), {db[Config.DoubleJob.database.list].default_name, db[Config.DoubleJob.database.list].default_label})
      end
    end
  
    local dj_grade = pcall(MySQL.scalar.await, db[Config.DoubleJob.database.list_grade].exist)
    if not dj_grade then
      local create = MySQL.query.await(db[Config.DoubleJob.database.list_grade].create)
      if create then
        MySQL.query(("INSERT INTO %s (`%s`, `name`, `grade`, `label`) VALUES (?, ?, ?, ?)"):format(Config.DoubleJob.database.list_grade, Config.DoubleJob.database.list_grade_name), {
          Config.DoubleJob.default.list_grade.name, Config.DoubleJob.default.list_grade.name, Config.DoubleJob.default.list_grade.grade, Config.DoubleJob.default.list_grade.label 
        })
      end
    end

    Wait(500)

    ESX[Config.DoubleJob.refresh]()
  end

  print(('[^2INFO^7] ESX ^5Legacy %s^0 edited by supv initialized!'):format(GetResourceMetadata(GetCurrentResourceName(), "version", 0)))
    
  StartDBSync()
  if Config.EnablePaycheck then
		StartPayCheck()
	end
end)

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
  if Config.EnableDebug then
    print(('[^2TRACE^7] %s^7'):format(msg))
  end
end)

RegisterNetEvent("esx:ReturnVehicleType", function(Type, Request)
  if Core.ClientCallbacks[Request] then
    Core.ClientCallbacks[Request](Type)
    Core.ClientCallbacks[Request] = nil
  end
end)
