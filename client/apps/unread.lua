function UpdateAppUnread(app, unread)
    for k, v in pairs(Config.Apps) do
        if v.container == app then
            v.unread = unread
            break
        end
    end

    SendNUIMessage(
        {
            action = "updateUnread",
            app = app,
            unread = unread
        }
    )

    if not isPhoneOpen then
        SendNUIMessage(
            {
                action = "AddClosedAlert",
                app = app
            }
        )
    end
end

RegisterNetEvent("mythic_phone:client:SyncUnread")
AddEventHandler(
    "mythic_phone:client:SyncUnread",
    function(unreads)
        for k, v in ipairs(Config.Apps) do
            v.unread = unreads[v.container]

            if unreads[v.container] ~= nil then
                if unreads[v.container] > 0 then
                    SendNUIMessage(
                        {
                            action = "AddClosedAlert",
                            app = v.container
                        }
                    )
                end
            else
                print(v.container)
            end
        end

        SendNUIMessage(
            {
                action = "SyncUnread",
                unread = unreads
            }
        )
    end
)

RegisterNUICallback(
    "SetUnread",
    function(data, cb)
        ESX.TriggerServerCallback(
            "mythic_phone:server:SetUnread",
            function(status)
                for k, v in ipairs(Config.Apps) do
                    if data.app == v.container then
                        v.unread = data.unread
                    end
                end
                cb(status)
            end,
            data
        )
    end
)

Citizen.CreateThread(
    function()
        Citizen.Wait(1000)
        SendNUIMessage(
            {
                action = "OpenPhoneAlert"
            }
        )
    end
)
