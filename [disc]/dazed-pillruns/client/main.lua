ESX = nil
PlayerData = nil

isHidingRun = false
isRunActive = false
event_time_passed = 0.0
pillsSold = 30

local currentDrugTask = {
    pointIndex = 0,
    runsLeft = 0,
    drugsIndex = 0
}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

--Register Points
Citizen.CreateThread(function()
    for k, v in pairs(Config.DeliveryPoints) do
        local marker = {
            name = v.name .. '_drug_dp',
            type = 2,
            coords = v.coords,
            colour = { r = 255, b = 55, g = 55 },
            size = vector3(1.0, 1.0, 0.5),
            msg = 'Press ~INPUT_CONTEXT~ to deliver at ' .. v.name,
            action = DeliverDrugs,
            deliveryPointIndex = k,
            shouldDraw = function()
                return Config.DeliveryPoints[k].isDeliveryPointActive and not isHidingRun
            end
        }
        TriggerEvent('disc-base:registerMarker', marker)
    end

    for k, v in pairs(Config.StartingPoints) do
        local marker = {
            name = v.name .. '_drug_sp',
            type = 29,
            coords = v.coords,
            colour = { r = 255, b = 55, g = 55 },
            size = vector3(1.0, 1.0, 0.5),
            msg = 'Press ~INPUT_CONTEXT~ to start drug run at ' .. v.name .. ' for $' .. Config.StartPrice,
            action = StartNewRun,
            shouldDraw = function()
                return not isRunActive
            end
        }
        TriggerEvent('disc-base:registerMarker', marker)
    end
end)

function disableAllPoints()
    for k, v in pairs(Config.DeliveryPoints) do
        Config.DeliveryPoints[k].isDeliveryPointActive = false
    end
end

function DeliverDrugs()
    --Take Drugs
    ESX.TriggerServerCallback('disc-base:takePlayerItem', function(tookItem)
        if not tookItem then
            exports['mythic_notify']:DoHudText('error', 'You don\'t have the drugs? Where is it?')
            EndRuns()
        else
            --Pay for Drugs
            local price = math.random(Config.Drugs[currentDrugTask.drugsIndex].price[1], Config.Drugs[currentDrugTask.drugsIndex].price[2])

            exports['mythic_notify']:DoHudText('success', 'Good, Here\'s $' .. price)
            TriggerServerEvent('disc-base:givePlayerMoney', price)
            --Continue if has more runs
            GotoNextRun()
        end
    end, Config.Drugs[currentDrugTask.drugsIndex].item, 1)
end

function StartNewRun()  
    if pillsSold >= 1 then
        ESX.TriggerServerCallback('disc-base:takePlayerMoney', function(took)
            if not took then
                exports['mythic_notify']:DoHudText('error', 'You don\'t have enough money, you need $' .. Config.StartPrice)
                return
            end
            isRunActive = true
            isHidingRun = true
            event_time_passed = 0.0
            drugCount = math.random(5, 10)
            drugIndex = math.random(#Config.Drugs)
            pillsSold = pillsSold - 1
            print(pillsSold)
            currentDrugTask = {
                pointIndex = math.random(#Config.DeliveryPoints),
                runsLeft = drugCount,
                drugsIndex = drugIndex
            }
            exports['mythic_notify']:DoHudText('success', 'Starting Drug Run!')
            TriggerServerEvent('disc-base:givePlayerItem', Config.Drugs[drugIndex].item, drugCount)
            Config.DeliveryPoints[currentDrugTask.pointIndex].isDeliveryPointActive = true
        end, Config.StartPrice)
    elseif pillsSold <= 0 then 
        exports['mythic_notify']:DoHudText('error', 'All Pill orders have already been filled today. Check back later.')
    end
end

function GotoNextRun()
    disableAllPoints()
    if currentDrugTask.runsLeft - 1 == 0 then
        EndRuns()
    else
        isHidingRun = true
        currentDrugTask = {
            pointIndex = math.random(#Config.DeliveryPoints),
            runsLeft = currentDrugTask.runsLeft - 1,
            drugsIndex = math.random(#Config.Drugs)
        }

        Config.DeliveryPoints[currentDrugTask.pointIndex].isDeliveryPointActive = true
    end
end

function EndRuns()
    isRunActive = false
    disableAllPoints()
	event_time_passed = 0.0
end

-- CANCEL CHECK IN CASE PLAYER DIED OR VEHICLE DESTROYED.
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
				if isRunActive then

						if IsPedDeadOrDying(GetPlayerPed(-1)) then
							EndRuns()
							exports['mythic_notify']:DoHudText('error', 'Pill Run has ended due to loss of consciousness!')
						end

						if event_time_passed > 900 then
							EndRuns()
							exports['mythic_notify']:DoHudText('error', 'Pill Run has timed out!')
						end

						event_time_passed = event_time_passed + 5
				end
		end
end)


--Hiding Run
Citizen.CreateThread(function()
    while true do
        if isHidingRun then
            Citizen.Wait(1000)
            isHidingRun = false
            serverId = GetPlayerServerId(PlayerId())
            ESX.TriggerServerCallback('disc-gcphone:getNumber', function(number)
                coords = Config.DeliveryPoints[currentDrugTask.pointIndex].coords
                message = 'GPS: ' .. coords.x .. ', ' .. coords.y
                TriggerServerEvent('disc-gcphone:sendMessageFrom', 'Patient', number, message, serverId)
            end)
        end
        Citizen.Wait(5000)
    end
end)
