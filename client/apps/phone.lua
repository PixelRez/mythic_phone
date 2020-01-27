Call = {}
local isLoggedIn = false

local Ringtones = {
    { name = 'Default', duration = 2000, file = 'ringtone1' },
    { name = 'Memes', duration = 20000, file = 'ringtone2' },
}

function IsInCall()
    return (Call.number ~= nil and Call.status == 1) or (Call.number ~= nil and Call.status == 0 and Call.initiator)
end

RegisterNetEvent('mythic_phone:client:CreateCall')
AddEventHandler('mythic_phone:client:CreateCall', function(number)
    Call.number = number
    Call.status = 0
    Call.initiator = true

    PhonePlayCall(false)

    Citizen.CreateThread(function()
        while Call.status == 0 do
            TriggerServerEvent('mythic_sounds:server:PlayOnSource', 'dialtone', 0.1)
            Citizen.Wait(100)
        end
    end)

    local count = 0
    Citizen.CreateThread(function()
        while Call.status == 0 do
            if count >= 30 then
                TriggerServerEvent('mythic_phone:server:EndCall')
                TriggerEvent('mythic_sounds:client:StopOnOne', 'dialtone')

                if isPhoneOpen then
                    PhoneCallToText()
                else
                    PhonePlayOut()
                end

                Call = {}
            else
                count = count + 1
            end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterNetEvent('mythic_phone:client:AcceptCall')
AddEventHandler('mythic_phone:client:AcceptCall', function(channel, initiator)
    if Call.number ~= nil and Call.status == 0 then
        Call.status = 1
        Call.channel = channel
        Call.initiator = initiator

        exports['tokovoip_script']:addPlayerToRadio(Call.channel, false)

        if initiator then
            SendNUIMessage({
                action = 'acceptCallSender',
                number = Call.number
            })
            exports['mythic_notify']:PersistentAlert('start', 'active-call', 'inform', 'You\'re In A Call', { ['background-color'] = '#ff8555', ['color'] = '#ffffff' })
        else
            exports['mythic_notify']:PersistentAlert('end', Config.IncomingNotifId)
            exports['mythic_notify']:PersistentAlert('start', 'active-call', 'inform', 'You\'re In A Call', { ['background-color'] = '#ff8555', ['color'] = '#ffffff' })
            PhonePlayCall(false)
            SendNUIMessage({
                action = 'acceptCallReceiver',
                number = Call.number
            })
        end

        TriggerEvent('mythic_sounds:client:StopOnOne', 'dialtone')
        TriggerServerEvent('mythic_sounds:server:StopWithinDistance', 'ringtone2')
    end
end)

RegisterNetEvent('mythic_phone:client:EndCall')
AddEventHandler('mythic_phone:client:EndCall', function()
    SendNUIMessage({
        action = 'endCall'
    })

    TriggerEvent('mythic_sounds:client:StopOnOne', 'dialtone')
    TriggerServerEvent('mythic_sounds:server:StopWithinDistance', 'ringtone2')
    exports['mythic_notify']:SendAlert('inform', 'Call Ended', 2500, { ['background-color'] = '#ff8555', ['color'] = '#ffffff' })
    exports['mythic_notify']:PersistentAlert('end', Config.IncomingNotifId)
    exports['mythic_notify']:PersistentAlert('end', 'active-call')
    exports['tokovoip_script']:removePlayerFromRadio(Call.channel)

    Call = {}

    if isPhoneOpen then
        PhoneCallToText()
    else
        PhonePlayOut()
    end
end)

RegisterNetEvent('mythic_phone:client:ReceiveCall')
AddEventHandler('mythic_phone:client:ReceiveCall', function(number)
    Call.number = number
    Call.status = 0
    Call.initiator = false

    SendNUIMessage({
        action = 'receiveCall',
        number = number
    })

    Citizen.CreateThread(function()
        while Call.status == 0 do
            TriggerServerEvent('mythic_sounds:server:PlayWithinDistance', 10.0, 'ringtone2', 0.1 * (Config.Settings.volume / 100))

            Citizen.Wait(500)
        end
    end)

    local count = 0
    Citizen.CreateThread(function()
        while Call.status == 0 do
            if count >= 30 then
                TriggerServerEvent('mythic_sounds:server:StopWithinDistance', 'ringtone2')
                TriggerServerEvent('mythic_phone:server:EndCall')
                Call = {}
            else
                count = count + 1
            end
            Citizen.Wait(1000)
        end
    end)
end)

RegisterNetEvent('mythic_phone:client:OtherToggleHold')
AddEventHandler('mythic_phone:client:OtherToggleHold', function(number)
    if Call.number ~= nil and Call.status ~= 0 then
        Call.OtherHold = not Call.OtherHold
    end
end)

RegisterNUICallback('CreateCall', function(data, cb)
    Callbacks:ServerCallback('mythic_phone:server:CreateCall', { number = data.number, nonStandard = data.nonStandard }, cb)
end)

RegisterNUICallback('AcceptCall', function(data, cb)
    TriggerServerEvent('mythic_phone:server:AcceptCall')
end)

RegisterNUICallback('EndCall', function(data, cb)
    TriggerServerEvent('mythic_phone:server:EndCall', Call)
end)

RegisterNUICallback('ToggleHold', function( data, cb )
    if Call.number ~= nil and Call.number ~= 0 then
        Call.Hold = not Call.Hold
        TriggerServerEvent('mythic_phone:server:ToggleHold', Call)
        if Call.Hold then
            exports['tokovoip_script']:removePlayerFromRadio(Call.channel)
            if isPhoneOpen then
                PhoneCallToText()
            else
                PhonePlayOut()
            end
        else
            exports['tokovoip_script']:addPlayerToRadio(Call.channel, false)
            PhonePlayCall(false)
        end

        cb(Call.Hold)
    end
end)

RegisterNUICallback('DeleteCallRecord', function(data, cb)
    Callbacks:ServerCallback('mythic_phone:server:DeleteCallRecord', { id = data.id }, cb)
end)

RegisterNetEvent('mythic_base:client:Logout')
AddEventHandler('mythic_base:client:Logout', function()
    isLoggedIn = false
end)

AddEventHandler('mythic_base:client:CharacterSpawned', function()
    isLoggedIn = true

    Citizen.CreateThread(function()
        while isLoggedIn do
            if IsInCall() and Call ~= nil and Call.status ~= 0 then
                if IsControlJustReleased(1, 51) then
                    Call.Hold = not Call.Hold
                    TriggerServerEvent('mythic_phone:server:ToggleHold', Call)
                    if Call.Hold then
                        exports['tokovoip_script']:removePlayerFromRadio(Call.channel)
                        if isPhoneOpen then
                            PhoneCallToText()
                        else
                            PhonePlayOut()
                        end
                    else
                        exports['tokovoip_script']:addPlayerToRadio(Call.channel, false)
                        PhonePlayCall(false)
                    end
                elseif IsControlJustReleased(1, 47) and not Call.Hold then
                    TriggerServerEvent('mythic_phone:server:EndCall', Call)
                end
    
                if Death:IsDead() then
                    TriggerServerEvent('mythic_phone:server:EndCall', Call)
                end
    
                Citizen.Wait(1)
            else
                Citizen.Wait(1000)
            end
        end
    end)
    
    Citizen.CreateThread(function()
        while isLoggedIn do
            if IsInCall() and Call ~= nil and Call.status ~= 0 then
                if not Call.OtherHold then
                    if not Call.Hold then
                        DrawUIText("~r~[E] ~s~Hold ~r~| [G] ~s~Hangup", 4, 1, 0.5, 0.85, 0.5, 255, 255, 255, 255)
                    else
                        DrawUIText("~r~[E] ~s~Resume ~r~| [G] ~s~Hangup", 4, 1, 0.5, 0.85, 0.5, 255, 255, 255, 255)
                    end
                else
                    if not Call.Hold then
                        DrawUIText("~r~[E] ~s~Hold ~r~| [G] ~s~Hangup ~r~| ~s~On Hold", 4, 1, 0.5, 0.85, 0.5, 255, 255, 255, 255)
                    else
                        DrawUIText("~r~[E] ~s~Resume ~r~| [G] ~s~Hangup ~r~| ~s~On Hold", 4, 1, 0.5, 0.85, 0.5, 255, 255, 255, 255)
                    end
                end
                Citizen.Wait(1)
            else
                Citizen.Wait(1000)
            end
        end
    end)
end)