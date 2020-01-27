RegisterNUICallback('CreateContact', function(data, cb)
    Callbacks:ServerCallback('mythic_phone:server:CreateContact', { name = data.name, number = data.number }, cb)
end)

RegisterNUICallback('EditContact', function(data, cb)
    Callbacks:ServerCallback('mythic_phone:server:EditContact', { name = data.name, number = data.number, originName = data.originName, originNumber = data.originNumber }, cb)
end)

RegisterNUICallback('DeleteContact', function(data, cb)
    Callbacks:ServerCallback('mythic_phone:server:DeleteContact', { name = data.name, number = data.number }, cb)
end)