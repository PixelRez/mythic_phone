RegisterNetEvent("mythic_phone:client:ReceiveText")
AddEventHandler(
    "mythic_phone:client:ReceiveText",
    function(sender, text)
        -- REVISIT THIS LATER
        -- TriggerServerEvent(
        --     "mythic_sounds:server:PlayWithinDistance",
        --     10.0,
        --     "text_message",
        --     0.05 * (Config.Settings.volume / 100)
        -- )
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
        -- print("SendText data resources/mythic_phone/client/apps/messages.lua")
        -- print(exports["utils"]:tprint(data))
        ESX.TriggerServerCallback("mythic_phone:server:SendText", cb, data)
    end
)

RegisterNUICallback(
    "DeleteConversation",
    function(data, cb)
        ESX.TriggerServerCallback("mythic_phone:server:DeleteConversation", cb, data)
    end
)

RegisterCommand(
    "sendText",
    function()
        local data = {receiver = "555-5555", message = "Something here plz"}
        ESX.TriggerServerCallback("mythic_phone:server:SendText", true, data)
    end
)

Citizen.CreateThread(
    function()
        local i = 0;
        -- set this to true if you want to test getting text messages
    while false do
        print('inside while true do')
        local data = {receiver = "555-5555", message = "Something here plz " .. i}
        ESX.TriggerServerCallback("mythic_phone:server:SendText", true, data)
        print("hopefully waiting 5 seconds")
        i = i+1
        Citizen.Wait(5000)
    end
end)
