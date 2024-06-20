ESX = nil

-- List of muscle car model names
local muscleCars = {
    "dominator",
    "dukes",
    "gauntlet",
    "stalion",
    "blade"
}

-- List of spawn coordinates
local spawnCoords = {
    {x = 977.956, y = -3001.959, z = -39.6037},
    {x = 971.9292, y = -3034.916, z = -39.64696},
    {x = 959.3937, y = -3035.349, z = -39.64695},
    {x = 955.0344, y = -3023.712, z = -39.64697}
}

local spawnedVehicles = {}

-- Define the garage coordinates
local garageCoords = vector3(1218.548, -3234.72, 5.528709)

-- Define the waypoint coordinates
local waypointCoords = vector3(-3081.74, 224.6, 14.03)

-- Define the zone center and radius
local zoneCenter = vector3(970.8951, -2987.196, -39.64695)
local zoneRadius = 50.0

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- Function to spawn a random muscle car at each spawn location
function spawnMuscleCars()
    for i, coords in ipairs(spawnCoords) do
        -- Get a random car model
        local carModel = muscleCars[math.random(#muscleCars)]

        -- Load the car model
        RequestModel(carModel)
        while not HasModelLoaded(carModel) do
            Citizen.Wait(0)
        end

        -- Create the vehicle at the specified coordinates
        local vehicle = CreateVehicle(carModel, coords.x, coords.y, coords.z, 0.0, true, false)
        
        -- Lock the vehicle
        SetVehicleDoorsLocked(vehicle, 2)
        SetVehicleDoorsLockedForAllPlayers(vehicle, true)
        
        -- Store the vehicle in a list
        table.insert(spawnedVehicles, vehicle)
        
        -- Set the model as no longer needed to free up memory
        SetModelAsNoLongerNeeded(carModel)
    end
end

-- Register a command 'spawnmusclecars'
RegisterCommand("spawnmusclecars", function(source, args, rawCommand)
    spawnMuscleCars()
end, false)

-- Event to unlock the vehicle using a lockpick
RegisterNetEvent('esx_lockpick:unlockVehicle')
AddEventHandler('esx_lockpick:unlockVehicle', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- Find the closest vehicle
    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    
    if DoesEntityExist(vehicle) then
        -- Unlock the vehicle
        SetVehicleDoorsLocked(vehicle, 1)
        SetVehicleDoorsLockedForAllPlayers(vehicle, false)
        ESX.ShowNotification("Vehicle unlocked")
    else
        ESX.ShowNotification("No vehicle nearby to unlock")
    end
end)

-- Event to handle the 'leavegarage' command
RegisterCommand("leavegarage", function(source, args, rawCommand)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= 0 then
        local driverSeat = GetPedInVehicleSeat(vehicle, -1)
        if driverSeat == playerPed then
            -- Check if player is within the zone
            local playerCoords = GetEntityCoords(playerPed)
            local distance = GetDistanceBetweenCoords(playerCoords, zoneCenter, true)
            
            if distance <= zoneRadius then
                -- Get current vehicle position and heading
                local vehCoords = GetEntityCoords(vehicle)
                local vehHeading = GetEntityHeading(vehicle)
                
                -- Teleport player and vehicle to the garage coordinates
                SetEntityCoords(vehicle, garageCoords.x, garageCoords.y, garageCoords.z, false, false, false, true)
              --  SetEntityCoords(playerPed, garageCoords.x, garageCoords.y, garageCoords.z, false, false, false, true)
                SetEntityHeading(vehicle, vehHeading)  -- Set vehicle heading after teleporting
                
               
            else
                -- If not in zone, teleport only the player
                SetEntityCoords(playerPed, garageCoords.x, garageCoords.y, garageCoords.z, false, false, false, true)
   
            end
            
            -- Set waypoint after leaving garage
            SetNewWaypoint(waypointCoords.x, waypointCoords.y)
        else
            print("trololo")
        end
    else
        ESX.ShowNotification("You are not in a vehicle.")
    end
end, false)



RegisterCommand("teleportingarage", function(source, args, rawCommand)
    local x, y, z = 970.8951, -2987.196, -39.64695
    local playerPed = GetPlayerPed(-1)
    SetEntityCoords(playerPed, x, y, z, false, false, false, true)
    spawnMuscleCars()
end, false)


TriggerEvent('gridsystem:registerMarker', {
    name = 'enter_garage',
    pos = vector3(1218.548, -3234.72, 5.528709),
    scale = vector3(0.7, 0.7, 0.7),
    msg = Config.EnterMessage,
    control = 'E',
    type = 20,
    color = { r = 130, g = 120, b = 110 },
    action = function()
      ExecuteCommand("teleportingarage")
    end,
    onEnter = function()
    end,
    onExit = function()
    end
  })

  TriggerEvent('gridsystem:registerMarker', {
    name = 'start_garage',
    pos = vector3(1274.883, -1710.818, 54.77144),
    scale = vector3(0.7, 0.7, 0.7),
    msg = Config.StartMission,
    control = 'E',
    type = 20,
    color = { r = 130, g = 120, b = 110 },
    action = function()
      ExecuteCommand("waypointtogarage")
    end,
    onEnter = function()
    end,
    onExit = function()
    end
  })

  RegisterCommand("waypointtogarage", function()
    ESX.ShowNotification("Car guy: Hi, you have a new mission, you have to steal a vehicle from the garage")
    Citizen.Wait(5000)
    ESX.ShowNotification("Car guy: you have to enter the garage and lockpick a vehicle and bring it to the seller once you leave the garage")
    Citizen.Wait(5000)
    ESX.ShowNotification("Car guy: i gave you the gps in map to go the garage, good luck boy")
    SetNewWaypoint(1218.548, -3234.72)
  end)
  Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local playerVeh = GetVehiclePedIsIn(playerPed, false)

        if playerVeh ~= 0 and IsPedInAnyVehicle(playerPed, false) then
            for _, vehicle in ipairs(spawnedVehicles) do
                if playerVeh == vehicle then
                    Citizen.Wait(500) -- Delay to ensure vehicle movement
                    if GetEntitySpeed(vehicle) > 0 then
                        -- Check if player is within the zone
                        local playerCoords = GetEntityCoords(playerPed)
                        local distance = GetDistanceBetweenCoords(playerCoords, zoneCenter, true)
                        
                        if distance <= zoneRadius then
                            -- Fade out screen
                            DoScreenFadeOut(1000)
                            Citizen.Wait(1000)
                            -- Execute the 'leavegarage' command
                            ExecuteCommand('leavegarage')
                            -- Fade in screen
                            DoScreenFadeIn(1000)
                            break
                        end
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(500)
		for k = 1, #Config.PedList, 1 do
			v = Config.PedList[k]
			local playerCoords = GetEntityCoords(PlayerPedId())
			local dist = #(playerCoords - v.coords)

			if dist < Config.Distance and not v.isRendered then
				local ped = nearPed(v.model, v.coords, v.heading, v.gender, v.animDict, v.animName, v.scenario)
				v.ped = ped
				v.isRendered = true
			end
			
			if dist >= Config.Distance and v.isRendered then
				if Config.Fade then
					for i = 255, 0, -51 do
						Citizen.Wait(50)
						SetEntityAlpha(v.ped, i, false)
					end
				end
				DeletePed(v.ped)
				v.ped = nil
				v.isRendered = false
			end
		end
	end
end)

function nearPed(model, coords, heading, gender, animDict, animName, scenario)
	local genderNum = 0
--AddEventHandler('nearPed', function(model, coords, heading, gender, animDict, animName)
	-- Request the models of the peds from the server, so they can be ready to spawn.
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(1)
	end
	
	-- Convert plain language genders into what fivem uses for ped types.
	if gender == 'male' then
		genderNum = 4
	elseif gender == 'female' then 
		genderNum = 5
	else
		print("No gender provided! Check your configuration!")
	end	

	--Check if someones coordinate grabber thingy needs to subract 1 from Z or not.
	if Config.MinusOne then 
		local x, y, z = table.unpack(coords)
		ped = CreatePed(genderNum, GetHashKey(model), x, y, z - 1, heading, false, true)
		
	else
		ped = CreatePed(genderNum, GetHashKey(v.model), coords, heading, false, true)
	end
	
	SetEntityAlpha(ped, 0, false)
	
	if Config.Frozen then
		FreezeEntityPosition(ped, true) --Don't let the ped move.
	end
	
	if Config.Invincible then
		SetEntityInvincible(ped, true) --Don't let the ped die.
	end

	if Config.Stoic then
		SetBlockingOfNonTemporaryEvents(ped, true) --Don't let the ped react to his surroundings.
	end
	
	--Add an animation to the ped, if one exists.
	if animDict and animName then
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(1)
		end
		TaskPlayAnim(ped, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
	end

	if scenario then
		TaskStartScenarioInPlace(ped, scenario, 0, true) -- begins peds animation
	end
	
	if Config.Fade then
		for i = 0, 255, 51 do
			Citizen.Wait(50)
			SetEntityAlpha(ped, i, false)
		end
	end

	return ped
end


local sellMarker = nil  -- Variable to store the marker handle
local sellPos = vector3(-3082.181, 222.3764, 14.00895)  -- Sell marker coordinates
local sellRadius = 2.0  -- Radius around sell marker

-- Function to create or update the sell marker
function createSellMarker()

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            -- Calculate the distance between player and the sell marker
            local distance = GetDistanceBetweenCoords(playerCoords, sellPos, true)

            -- Check if player is within the sell radius
            if distance < sellRadius then
                -- Draw a marker on the ground
                DrawMarker(1, sellPos.x, sellPos.y, sellPos.z - 1.0, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 0.5, 255, 0, 0, 100, false, true, 2, nil, nil, false)

                -- Check if player presses 'E' to trigger sell command (change '38' to your desired key)
                if IsControlJustReleased(0, 38) then  -- 38 is the control for 'E' key
                    TriggerEvent('sell')
                end
            end
        end
    end)
end


RegisterNetEvent('sell')
AddEventHandler('sell', function()
    ExecuteCommand("sellvehicle")

end)


Citizen.CreateThread(function()
    createSellMarker()
end)

