local markers = {}
local CurrentMarker = nil
local blips = {}

local HasAlreadyEnteredMarker

--[[
    Usage:
    marker = {
        type = 20
        coords = {x, y, z},
        colour = {r, g, b},
        shouldDraw = function() returns boolean,
        action = function(marker),
        msg = 'Display this when entered'
    }
]]--

RegisterNetEvent('disc-base:registerMarker')
AddEventHandler('disc-base:registerMarker', function(marker)
    if marker.coords == nil then
        print('Needs Coords for marker')
        return
    end
    if marker.shouldDraw == nil then
        marker.shouldDraw = function()
            return true
        end
    end

    markers[getOrElse(marker.name, #markers + 1)] = marker
end)

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local isInMarker = false
        local lastMarker = nil
        for k, v in pairs(markers) do
            local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.coords.x, v.coords.y, v.coords.z, true)
            if distance < Config.DrawDistance and v.shouldDraw() then
                DrawMarker(v.type, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.size.x, v.size.y, v.size.z, v.colour.r, v.colour.g, v.colour.b, 100, getOrElse(v.bob, false), true, 2, true, false, false, false)
            end
            if distance < v.size.x and v.shouldDraw() then
                isInMarker = true
                lastMarker = v
            end

        end

        if isInMarker and not HasAlreadyEnteredMarker then
            HasAlreadyEnteredMarker = true
            TriggerEvent('disc-base:hasEnteredMarker', lastMarker)
        end
        if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
            HasAlreadyEnteredMarker = false
            TriggerEvent('disc-base:hasExitedMarker')
        end
    end

end)

AddEventHandler('disc-base:hasExitedMarker', function()
    CurrentMarker = nil
    ESX.UI.Menu.CloseAll()
end)

AddEventHandler('disc-base:hasEnteredMarker', function(marker)
    print('Marker: ' .. marker.name)
    CurrentMarker = marker
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if CurrentMarker and CurrentMarker.shouldDraw() then
            ESX.ShowHelpNotification(CurrentMarker.msg)

            if IsControlJustReleased(0, 38) then
                if CurrentMarker.action ~= nil then
                    CurrentMarker.action(CurrentMarker)
                end
            end
        end
    end
end)

RegisterNetEvent('disc-base:registerBlip')
AddEventHandler('disc-base:registerBlip', function(blip)

    if blip.coords == nil then
        print("Coords needed for Blip")
        return
    end

    local _blip = AddBlipForCoord(blip.coords)
    SetBlipSprite(_blip, getOrElse(blip.sprite, 1))
    SetBlipDisplay(_blip, 4)
    if blip.scale then
        SetBlipScale(_blip, getOrElse(blip.scale, 0.5))
    end
    SetBlipColour(_blip, getOrElse(blip.colour, 1))
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(getOrElse(blip.name, "Blip Missing Name"))
    EndTextCommandSetBlipName(_blip)
    blips[getOrElse(blip.id, #blips + 1)] = _blip
end)

RegisterNetEvent('disc-base:updateBlip')
AddEventHandler('disc-base:updateBlip', function(blip)
    if not blip.id then
        print('Blip Id Missing')
        return
    end
    local _blip = blips[blip.id]
    if blip.sprite then
        SetBlipSprite(_blip, blip.sprite)
    end
    if blip.display then
        SetBlipDisplay(_blip, blip.display)
    end
    if blip.scale then
        SetBlipScale(_blip, getOrElse(blip.scale, 0.5))
    end
    if blip.colour then
        SetBlipScale(_blip, blip.colour)
    end
    if blip.name then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blip.name)
        EndTextCommandSetBlipName(_blip)
    end
end)
