RegisterNetEvent('mythic_phone:client:ReceiveNewIRCMessage')
AddEventHandler('mythic_phone:client:ReceiveNewIRCMessage', function(data)
    TriggerServerEvent('mythic_sounds:server:PlayWithinDistance', 10.0, 'text_message', 0.05 * (Config.Settings.volume / 100))
    exports['mythic_notify']:SendAlert('inform', 'You Received An IRC Message')
    SendNUIMessage({
        action = 'receiveIRCChat',
        channel = data.channel,
        message = data.message
    })
end)

RegisterNUICallback('IRCJoinChannel', function(data, cb)
    Callbacks:ServerCallback('mythic_phone:server:IRCJoinChannel', data, cb)
end)

RegisterNUICallback('IRCLeaveChannel', function(data, cb)
    Callbacks:ServerCallback('mythic_phone:server:IRCLeaveChannel', data, cb)
end)

RegisterNUICallback('IRCGetMessages', function(data, cb)
    Callbacks:ServerCallback('mythic_phone:server:IRCGetMessages', data, cb)
end)

RegisterNUICallback('IRCNewMessage', function(data, cb)
    Callbacks:ServerCallback('mythic_phone:server:IRCNewMessage', data, cb)
end)