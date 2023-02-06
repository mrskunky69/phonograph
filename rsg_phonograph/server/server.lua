local RSGCore = exports['rsg-core']:GetCoreObject()
local xSound = exports.xsound
local isPlaying = false

RSGCore.Functions.CreateUseableItem("phonograph", function(source, item)
	local src = source
	local Player = RSGCore.Functions.GetPlayer(src)
	local firstname = Player.PlayerData.charinfo.firstname
    local lastname = Player.PlayerData.charinfo.lastname
	TriggerClientEvent('rsg_mobiledj:client:placeDJEquipment', src)
	Player.Functions.RemoveItem('phonograph', 1)
	TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['phonograph'], "remove")
	TriggerEvent('rsg-log:server:CreateLog', 'music', 'MUSIC PLAYING', 'yellow', firstname..' '..lastname..'🎶 IS PLAYING MUSIC! 🎶')
end)

RegisterNetEvent('rsg_mobiledj:server:playMusic', function(song, entity, coords)
    local src = source
    xSound:PlayUrlPos(-1, tostring(entity), song, Config.DefaultVolume, coords)
    xSound:Distance(-1, tostring(entity), Config.radius)
    isPlaying = true
end)

RegisterNetEvent('rsg_mobiledj:server:pickedup', function(entity)
    local src = source
    xSound:Destroy(-1, tostring(entity))
end)

RegisterNetEvent('rsg_mobiledj:server:stopMusic', function(data)
    local src = source
    xSound:Destroy(-1, tostring(data.entity))
    TriggerClientEvent('rsg_mobiledj:client:playMusic', src)
end)

RegisterNetEvent('rsg_mobiledj:server:pauseMusic', function(data)
    local src = source
    xSound:Pause(-1, tostring(data.entity))
end)

RegisterNetEvent('rsg_mobiledj:server:resumeMusic', function(data)
    local src = source
    xSound:Resume(-1, tostring(data.entity))
end)

RegisterNetEvent('rsg_mobiledj:server:changeVolume', function(volume, entity)
    local src = source
    if not tonumber(volume) then return end
    xSound:setVolume(-1, tostring(entity), volume)
end)

RegisterNetEvent('rsg_mobiledj:Server:RemoveItem', function(item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(item, amount)
end)

RegisterServerEvent('rsg_mobiledj:server:pickeupdecks')
AddEventHandler('rsg_mobiledj:server:pickeupdecks', function()
	local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
	local firstname = Player.PlayerData.charinfo.firstname
    local lastname = Player.PlayerData.charinfo.lastname
	Player.Functions.AddItem('phonograph', 1)
	TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items['phonograph'], "add")
	TriggerEvent('rsg-log:server:CreateLog', 'music', 'MUSIC STOPPED', 'red', firstname..' '..lastname..'🎶 STOPPED PLAYING MUSIC! 🎶')
end)