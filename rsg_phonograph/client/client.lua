-- Variables

local RSGCore = exports['rsg-core']:GetCoreObject()
local deployeddecks = nil

-- Functions

local function loadAnimDict(dict)
  while (not HasAnimDictLoaded(dict)) do
      RequestAnimDict(dict)
      Wait(5)
  end
end

local function helpText(text)
	SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- target
Citizen.CreateThread(function()

local djdecksprop = {
    `P_PHONOGRAPH01X`,
    }
    exports['rsg-target']:AddTargetModel(djdecksprop, {
        options = {
            {
                type = "client",
				event = "rsg_mobiledj:client:playMusic",
                icon = "fas fa-record-vinyl",
                label = "Music Menu",
            },
            {
				type = "client",
				event = "rsg_mobiledj:client:pickupDJEquipment",
                icon = "fas fa-undo",
                label = "Pickup Equipment",
            },
        },
        distance = 3.0
    })
end)

-- Events

-- place dj equipment
RegisterNetEvent('rsg_mobiledj:client:placeDJEquipment', function()
    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    local forward = GetEntityForwardVector(PlayerPedId())
    local x, y, z = table.unpack(coords + forward * 0.5)
    local object = CreateObject(GetHashKey('P_PHONOGRAPH01X'), x, y, z, true, false, false)
    TaskStartScenarioInPlace(PlayerPedId(), GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), -1, true, "StartScenario", 0, false)
    PlaceObjectOnGroundProperly(object)
    SetEntityHeading(object, heading)
    FreezeEntityPosition(object, true)
	Wait(500)
    ClearPedTasks(PlayerPedId())
    deployeddecks = NetworkGetNetworkIdFromEntity(object)
end)

RegisterNetEvent('rsg_mobiledj:client:playMusic', function(data)
local musicMenu = {
	{
		isHeader = true,
		header = '💿 | Music box'
	},
	{
		header = '🎶 | Play a song',
		txt = 'Enter a youtube URL',
		params = {
			event = 'rsg_mobiledj:client:musicMenu',
			args = {
				entity = deployeddecks,
			}
		}
	},
	{
		header = '⏸️ | Pause Music',
		txt = 'Pause currently playing music',
		params = {
			isServer = true,
			event = 'rsg_mobiledj:server:pauseMusic',
			args = {
				entity = deployeddecks,
			}
		}
	},
	{
		header = '▶️ | Resume Music',
		txt = 'Resume playing paused music',
		params = {
			isServer = true,
			event = 'rsg_mobiledj:server:resumeMusic',
			args = {
				entity = deployeddecks,
			}
		}
	},
	{
		header = '🔈 | Change Volume',
		txt = 'Resume playing paused music',
		params = {
			event = 'rsg_mobiledj:client:changeVolume',
		}
	},
	{
		header = '❌ | Turn off music',
		txt = 'Stop the music & choose a new song',
		isServer = true,
		params = {
			isServer = true,
			event = 'rsg_mobiledj:server:stopMusic',
			args = {
				entity = deployeddecks,
			}
		}
	}
}
    exports['rsg-menu']:openMenu(musicMenu)
end)

RegisterNetEvent('rsg_mobiledj:client:musicMenu', function()
    local dialog = exports['rsg-input']:ShowInput({
        header = 'Song Selection',
        submitText = "Submit",
        inputs = {
            {
                type = 'text',
                isRequired = true,
                name = 'song',
                text = 'YouTube URL'
            }
        }
    })
    if dialog then
        if not dialog.song then return end
        TriggerServerEvent('rsg_mobiledj:server:playMusic', dialog.song, deployeddecks, GetEntityCoords(NetworkGetEntityFromNetworkId(deployeddecks)))
    end
end)

RegisterNetEvent('rsg_mobiledj:client:changeVolume', function()
    local dialog = exports['rsg-input']:ShowInput({
        header = 'Music Volume',
        submitText = "Submit",
        inputs = {
            {
                type = 'text', -- number doesn't accept decimals??
                isRequired = true,
                name = 'volume',
                text = 'Min: 0.01 - Max: 1'
            }
        }
    })
    if dialog then
        if not dialog.volume then return end
        TriggerServerEvent('rsg_mobiledj:server:changeVolume', dialog.volume, deployeddecks)
    end
end)

RegisterNetEvent('rsg_mobiledj:client:pickupDJEquipment', function()
    local obj = NetworkGetEntityFromNetworkId(deployeddecks)
    local objCoords = GetEntityCoords()
    NetworkRequestControlOfEntity(obj)
    SetEntityAsMissionEntity(obj,false,true)
    DeleteEntity(obj)
    DeleteObject(obj)
    if not DoesEntityExist(obj) then
        TriggerServerEvent('rsg_mobiledj:server:pickedup', deployeddecks)
        TriggerServerEvent('rsg_mobiledj:server:pickeupdecks')
        deployeddecks = nil
    end
    Wait(500)
    ClearPedTasks(PlayerPedId())
end)
