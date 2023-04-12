local resourceName = 'es_extended'

if not GetResourceState(resourceName):find('start') then return end

local dj

SetTimeout(0, function()
    local ESX = exports[resourceName]:getSharedObject()
    
    GetPlayer = ESX.GetPlayerFromId
    if not dj and ESX.GetConfig().DoubleJob.enable then dj = ESX.GetConfig().DoubleJob end
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

    if type == 'string' then
        if player.job.name == filter then
            return player.job.name, player.job.grade
        elseif dj and player[dj.name].name == filter  then
            return player[dj.name].name, player[dj.name].grade
        end
    else
        local tabletype = table.type(filter)

        if tabletype == 'hash' then
            local grade, gradef = filter[player.job.name], dj and filter[player[dj.name].name] or nil

            if grade and grade <= player.job.grade then
                return player.job.name, player.job.grade
            elseif gradef and gradef <= player[dj.name].grade then
                return player[dj.name].name, player[dj.name].grade
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                if player.job.name == filter[i] then
                    return player.job.name, player.job.grade
                elseif dj and player[dj.name].name == filter[i] then
                    return player[dj.name].name, player[dj.name].grade
                end
            end
        end
    end
end

