RegisterNUICallback(
    "CreateContact",
    function(data, cb)
        ESX.TriggerServerCallback("mythic_phone:server:CreateContact", cb, {name = data.name, number = data.number})
    end
)

RegisterNUICallback(
    "EditContact",
    function(data, cb)
        ESX.TriggerServerCallback(
            "mythic_phone:server:EditContact",
            cb,
            {name = data.name, number = data.number, originName = data.originName, originNumber = data.originNumber}
        )
    end
)

RegisterNUICallback(
    "DeleteContact",
    function(data, cb)
        ESX.TriggerServerCallback("mythic_phone:server:DeleteContact", cb, {name = data.name, number = data.number})
    end
)
