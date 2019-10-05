-- Allow passengers to shoot
local passengerDriveBy = true

local doors = {
	{"seat_dside_f", -1},
	{"seat_pside_f", 0},
	{"seat_dside_r", 1},
	{"seat_pside_r", 2}
  }
  
function VehicleInFront()
	local pos = GetEntityCoords(GetPlayerPed(-1))
	local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 5.0, 0.0)
	local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
	local _, _, _, _, result = GetRaycastResult(rayHandle)
	return result
end

Citizen.CreateThread(function()
while true do
	Citizen.Wait(0)
	DisablePlayerVehicleRewards(PlayerId())
	if IsControlJustReleased(0, 23) and running ~= true and GetVehiclePedIsIn(GetPlayerPed(-1), false) == 0 then
	local vehicle = VehicleInFront()
	running = true
	if vehicle ~= nil then
		local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
		local doorDistances = {}
		for k, door in pairs(doors) do
		local doorBone = GetEntityBoneIndexByName(vehicle, door[1])
		local doorPos = GetWorldPositionOfEntityBone(vehicle, doorBone)
		local distance = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, doorPos.x, doorPos.y, doorPos.z)
		table.insert(doorDistances, distance)
		end
		local key, min = 1, doorDistances[1]
		for k, v in ipairs(doorDistances) do
		if doorDistances[k] < min then
			key, min = k, v
		end
		end
		TaskEnterVehicle(GetPlayerPed(-1), vehicle, -1, doors[key][2], 1.0, 1, 0)
	end
	running = false
	end
end
end)

Citizen.CreateThread(function()
	while true do
		Wait(1)
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		local speed = GetEntitySpeed(vehicle)
		local kmh = 3.6
		local mph = 2.23694
		local vehicleClass = GetVehicleClass(vehicle)
		local vehicleModel = GetEntityModel(vehicle)
			
			
		if vehicleClass ~= 15 and 16 then
		GetEntitySpeed(GetPedInVehicleSeat(GetPlayerPed(-1), false)) 
		-- If you want mph, then replace kmh with mph under here. If you want more or less than 30 also change it here
		if math.floor(speed*mph) > 30 then
				SetPlayerCanDoDriveBy(PlayerId(), false)
			elseif passengerDriveBy then
				SetPlayerCanDoDriveBy(PlayerId(), true)
			else
				SetPlayerCanDoDriveBy(PlayerId(), false)
			end
		end
	end
end)

-- VEHICLE CLASSES
-- id = 0 --compacts
-- id = 1 --sedans
-- id = 2 --SUV's
-- id = 3, --coupes
-- id = 4 --muscle
-- id = 5 --sport classic
-- id = 6 --sport
-- id = 7 --super
-- id = 8 --motorcycle
-- id = 9 --offroad
-- id = 10 --industrial
-- id = 11 -utility
-- id = 12 --vans
-- id = 13 --bicycles
-- id = 14 --boats
-- id = 15, --helicopter
-- id = 16 --plane
-- id = 17 --service
-- id = 18 --emergency
-- id = 19 --military

RegisterCommand("hood", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= nil and veh ~= 0 and veh ~= 1 then
        if GetVehicleDoorAngleRatio(veh, 4) > 0 then
            SetVehicleDoorShut(veh, 4, false)
        else
            SetVehicleDoorOpen(veh, 4, false, false)
        end
    end
end, false)

RegisterCommand("trunk", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= nil and veh ~= 0 and veh ~= 1 then
        if GetVehicleDoorAngleRatio(veh, 5) > 0 then
            SetVehicleDoorShut(veh, 5, false)
        else
            SetVehicleDoorOpen(veh, 5, false, false)
        end
    end
end, false)

RegisterCommand("door0", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= nil and veh ~= 0 and veh ~= 1 then
        if GetVehicleDoorAngleRatio(veh, 0) > 0 then
            SetVehicleDoorShut(veh, 0, false)
        else
            SetVehicleDoorOpen(veh, 0, false, false)
        end
    end
end, false)

RegisterCommand("door1", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= nil and veh ~= 0 and veh ~= 1 then
        if GetVehicleDoorAngleRatio(veh, 1) > 0 then
            SetVehicleDoorShut(veh, 1, false)
        else
            SetVehicleDoorOpen(veh, 1, false, false)
        end
    end
end, false)

RegisterCommand("door2", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= nil and veh ~= 0 and veh ~= 1 then
        if GetVehicleDoorAngleRatio(veh, 2) > 0 then
            SetVehicleDoorShut(veh, 2, false)
        else
            SetVehicleDoorOpen(veh, 2, false, false)
        end
    end
end, false)

RegisterCommand("door3", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= nil and veh ~= 0 and veh ~= 1 then
        if GetVehicleDoorAngleRatio(veh, 3) > 0 then
            SetVehicleDoorShut(veh, 3, false)
        else
            SetVehicleDoorOpen(veh, 3, false, false)
        end
    end
end, false)