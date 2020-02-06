RegisterNetEvent("mythic_phone:client:ReceiveNewIRCMessage")
AddEventHandler(
    "mythic_phone:client:ReceiveNewIRCMessage",
    function(data)
        TriggerServerEvent(
            "mythic_sounds:server:PlayWithinDistance",
            10.0,
            "text_message",
            0.05 * (Config.Settings.volume / 100)
        )
        exports["mythic_notify"]:SendAlert("inform", "You Received An IRC Message")
        SendNUIMessage(
            {
                action = "receiveIRCChat",
                channel = data.channel,
                message = data.message
            }
        )
    end
)

RegisterNUICallback(
    "IRCJoinChannel",
    function(data, cb)
        ESX.TriggerServerCallback("mythic_phone:server:IRCJoinChannel", cb, data)
    end
)

RegisterNUICallback(
    "IRCLeaveChannel",
    function(data, cb)
        ESX.TriggerServerCallback("mythic_phone:server:IRCLeaveChannel", cb, data)
    end
)

RegisterNUICallback(
    "IRCGetMessages",
    function(data, cb)
        ESX.TriggerServerCallback("mythic_phone:server:IRCGetMessages", cb, data)
    end
)

RegisterNUICallback(
    "IRCNewMessage",
    function(data, cb)
        ESX.TriggerServerCallback("mythic_phone:server:IRCNewMessage", cb, data)
    end
)
