RegisterNetEvent("mythic_phone:client:ReceiveAd")
AddEventHandler(
    "mythic_phone:client:ReceiveAd",
    function(advert)
        if advert.phone ~= CharData.phone then
            SendNUIMessage(
                {
                    action = "ReceiveAd",
                    advert = advert
                }
            )
        end
    end
)

RegisterNetEvent("mythic_phone:client:DeleteAd")
AddEventHandler(
    "mythic_phone:client:DeleteAd",
    function(id)
        if id ~= CharData.id then
            SendNUIMessage(
                {
                    action = "DeleteAd",
                    id = id
                }
            )
        end
    end
)

RegisterNUICallback(
    "NewAd",
    function(data, cb)
        ESX.TriggerServerCallback("mythic_phone:server:NewAd", data, cb)
    end
)

RegisterNUICallback(
    "DeleteAd",
    function(data, cb)
        ESX.TriggerServerCallback("mythic_phone:server:DeleteAd", data, cb)
    end
)
