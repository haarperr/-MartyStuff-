ESX = nil
PlayerData = nil

isHidingRun = false
isRunActive = false
event_time_passed = 0.0
pawnSold = 30

local currentPawnTask = {
    pointIndex = 0,
    runsLeft = 0,
    pawnIndex = 0
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

--Spawn PED at delivery location

Citizen.CreateThread(function()

	RequestModel(Config.NPCHash)
	while not HasModelLoaded(Config.NPCHash) do
	Wait(1)

	end

	--PROVIDER
		meth_dealer_seller = CreatePed(1, Config.NPCHash, Config.DeliveryPoints.x, Config.DeliveryPoints.y, Config.DeliveryPoints.z, Config.heading, false, true)
		SetBlockingOfNonTemporaryEvents(meth_dealer_seller, true)
		SetPedDiesWhenInjured(meth_dealer_seller, false)
		SetPedCanPlayAmbientAnims(meth_dealer_seller, true)
		SetPedCanRagdollFromPlayerImpact(meth_dealer_seller, false)
		SetEntityInvincible(meth_dealer_seller, true)
		FreezeEntityPosition(meth_dealer_seller, true)
		TaskStartScenarioInPlace(meth_dealer_seller, "WORLD_HUMAN_SMOKING", 0, true);

end)


--Register Points
Citizen.CreateThread(function()
    for k, v in pairs(Config.DeliveryPoints) do
        local marker = {
            name = v.name .. '_pawn_dp',
            type = 2,
            coords = v.coords,
            colour = { r = 255, b = 55, g = 55 },
            size = vector3(1.0, 1.0, 0.5),
            msg = 'Press ~INPUT_CONTEXT~ to deliver at ' .. v.name,
            action = DeliverPawn,
            deliveryPointIndex = k,
            shouldDraw = function()
                return Config.DeliveryPoints[k].isDeliveryPointActive and not isHidingRun
            end
        }
        TriggerEvent('disc-base:registerMarker', marker)
    end

    for k, v in pairs(Config.StartingPoints) do
        local marker = {
            name = v.name .. '_pawn_sp',
            type = 29,
            coords = v.coords,
            colour = { r = 255, b = 55, g = 55 },
            size = vector3(1.0, 1.0, 0.5),
            msg = 'Press ~INPUT_CONTEXT~ to start available pawn runs at ' .. v.name .. ' for $' .. Config.StartPrice,
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

function DeliverPawn()
    --Take Pawn
    ESX.TriggerServerCallback('disc-base:takePlayerItem', function(tookItem)
        if not tookItem then
            exports['mythic_notify']:DoHudText('error', 'You didn\'t bring the right pawn? You imbecile.')
            EndRuns()
            exports['mythic_notify']:DoHudText('error', 'Pawn Run has ended due to merchandise issue')
        else
            --Pay for Pawn
            local price = math.random(Config.Pawn[currentPawnTask.pawnIndex].price[1], Config.Pawn[currentPawnTask.pawnIndex].price[2])

            exports['mythic_notify']:DoHudText('success', 'Good, Here\'s $' .. price)
            TriggerServerEvent('disc-base:givePlayerMoney', price)
            --Continue if has more runs
            GotoNextRun()
        end
    end, Config.Pawn[currentPawnTask.pawnIndex].item, 1)
end

function StartNewRun()
    if pawnSold >= 1 then
        ESX.TriggerServerCallback('disc-base:takePlayerMoney', function(took)
            if not took then
                exports['mythic_notify']:DoHudText('error', 'You don\'t have enough money, you need $' .. Config.StartPrice)
                return
            end
            isRunActive = true
            isHidingRun = true
            event_time_passed = 0.0
            pawnCount = math.random(5, 10)
            pawnIndex = math.random(#Config.Pawn)
            pawnSold = pawnSold - 1
            print(pawnSold)
            currentPawnTask = {
                pointIndex = math.random(#Config.DeliveryPoints),
                runsLeft = pawnCount,
                pawnIndex = pawnIndex
            }
            exports['mythic_notify']:DoHudText('success', 'Starting pawn Run!')
            -- TriggerServerEvent('disc-base:givePlayerItem', Config.Pawn[pawnIndex].item, pawnCount)
            Config.DeliveryPoints[currentPawnTask.pointIndex].isDeliveryPointActive = true
        end, Config.StartPrice)
    elseif pawnSold <= 0 then 
        exports['mythic_notify']:DoHudText('error', 'All Pawn lists have been sold already today. Check back later.')
    end
end

function GotoNextRun()
    disableAllPoints()
    if currentPawnTask.runsLeft - 1 == 0 then
        EndRuns()
    else
        isHidingRun = true
        currentPawnTask = {
            pointIndex = math.random(#Config.DeliveryPoints),
            runsLeft = currentPawnTask.runsLeft - 1,
            pawnIndex = math.random(#Config.Pawn)
        }
        

        Config.DeliveryPoints[currentPawnTask.pointIndex].isDeliveryPointActive = true
    end
end

function EndRuns()
    isRunActive = false
    disableAllPoints()  
	event_time_passed = 0.0
end

-- CANCEL CHECK IN CASE PLAYER DIED OR TAKES TO LONG TO COMPLETE
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
				if isRunActive then

						if IsPedDeadOrDying(GetPlayerPed(-1)) then
							EndRuns()
							exports['mythic_notify']:DoHudText('error', 'Pawn Run has ended due to loss of consciousness!')
						end

						if event_time_passed > 60 then
							EndRuns()
							exports['mythic_notify']:DoHudText('error', 'Pawn Run has timed out!')
						end

						event_time_passed = event_time_passed + 5
				end
		end
end)

--Timeaddon

Citizen.CreateThread(function()
    
    while true do
        if GetClockHours() == 0 and GetClockMinutes() <= 5 and GetClockSeconds() == 0 then
            -- Do Stuff at 7:00
            pawnSold = pawnSold + 10
            print(pawnSold)
       end
        Citizen.Wait(5000)
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
                coords = Config.DeliveryPoints[currentPawnTask.pointIndex].coords
                message = 'GPS: ' .. coords.x .. ', ' .. coords.y
                TriggerServerEvent('disc-gcphone:sendMessageFrom', 'Client', number, message, serverId)
            end)
        end
        Citizen.Wait(5000)
    end
end)
