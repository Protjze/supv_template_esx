local resourceName = 'es_extended'

if not GetResourceState(resourceName):find('start') then return end

SetTimeout(0, function()
    local ESX = exports[resourceName]:getSharedObject()

    GetPlayer = ESX.GetPlayerFromId

    if not ESX.GetConfig().OxInventory then
        function RemoveItem(playerId, item)
            local player = GetPlayer(playerId)

            if player then player.removeInventoryItem(item, 1) end
        end

        function DoesPlayerHaveItem(player, items)
            for i = 1, #items do
                local item = items[i]
                local data = player.getInventoryItem(item.name)

                if data?.count > 0 then
                    if item.remove then
                        player.removeInventoryItem(item.name, 1)
                    end

                    return item.name
                end
            end

            return false
        end
    end
end)

function GetCharacterId(player)
    return player.identifier
end

function IsPlayerInGroup(player, filter)
    local type = type(filter)
    local dj = ESX.GetConfig().DoubleJob.enable and ESX.GetConfig().DoubleJob or nil

    if type == 'string' then
        if player.job.name == filter then
            return player.job.name, player.job.grade
        elseif db and player[db.name].name == filter  then
            return player[db.name].name, player[db.name].grade
        end
    else
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            local grade, gradef = filter[player.job.name], db and filter[player[db.name].name] or nil

            if grade and grade <= player.job.grade then
                return player.job.name, player.job.grade
            elseif gradef and gradef <= player[db.name].grade
                return player[db.name].name, player[db.name].grade
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                if player.job.name == filter[i] then
                    return player.job.name, player.job.grade
                elseif db and player[db.name].name == filter[i] then
                    return player[db.name].name, player[db.name].grade
                end
            end
        end
    end
end

