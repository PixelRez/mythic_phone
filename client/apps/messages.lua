RegisterNetEvent("mythic_phone:client:ReceiveText")
AddEventHandler(
    "mythic_phone:client:ReceiveText",
    function(sender, text)
        TriggerServerEvent(
            "mythic_sounds:server:PlayWithinDistance",
            10.0,
            "text_message",
            0.05 * (Config.Settings.volume / 100)
        )
        exports["mythic_notify"]:SendAlert("inform", "You Received A Text From " .. sender)

        SendNUIMessage(
            {
                action = "receiveText",
                data = {
                    sender = sender,
                    text = text
                }
            }
        )
    end
)

RegisterNUICallback(
    "SendText",
    function(data, cb)
        ESX.TriggerServerCallback("mythic_phone:server:SendText", data, cb)
    end
)

RegisterNUICallback(
    "DeleteConversation",
    function(data, cb)
        ESX.TriggerServerCallback("mythic_phone:server:DeleteConversation", data, cb)
    end
)
