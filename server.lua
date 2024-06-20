ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Register the lockpick item usage
ESX.RegisterUsableItem('lockpick', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('esx_lockpick:unlockVehicle', source)
end)

-- Register server-side command 'sellvehicle'
RegisterCommand('sellvehicle', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)  -- Fetch xPlayer instance
    local playerPed = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if DoesEntityExist(vehicle) then
        local driverSeat = GetPedInVehicleSeat(vehicle, -1)
        if driverSeat == playerPed then
            -- Generate a random amount of money between 2000 and 10000
            local amount = math.random(2000, 10000)

            -- Add money to the player's account
            xPlayer.addAccountMoney('black_money', amount)

            -- Delay a moment to ensure the player is safely outside the vehicle
            Citizen.Wait(1000)

            -- Check if player is still in the vehicle after the delay
            if GetVehiclePedIsIn(playerPed, false) == vehicle then
                -- Remove the player from the vehicle
                TaskLeaveVehicle(playerPed, vehicle, 0)
                DeleteEntity(vehicle)
                -- Wait for the player to exit the vehicle
                Citizen.Wait(1000)
            end

            -- Delete the vehicle
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteEntity(vehicle)  -- Use DeleteEntity instead of DeleteVehicle

            -- Notify the player
            TriggerClientEvent('esx:showNotification', source, "You sold the vehicle for $" .. amount)
        else
            TriggerClientEvent('esx:showNotification', source, "You must be in the driver's seat to sell the vehicle.")
        end
    else
        TriggerClientEvent('esx:showNotification', source, "You are not in a vehicle.")
    end
end, false)
