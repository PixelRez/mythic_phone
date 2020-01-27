local Advertisements = {}

function CreateAd(adData)
    Advertisements[adData.id] = adData
    TriggerClientEvent('mythic_phone:client:ReceiveAd', -1, Advertisements[adData.id])
    return Advertisements[adData.id] ~= nil
end

function DeleteAd(source)
    local mPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(source)
    if mPlayer ~= nil then
        local char = mPlayer:GetData('character')
        
        if char ~= nil then
            local id = char:GetData('id')
            Advertisements[id] = nil
            TriggerClientEvent('mythic_phone:client:DeleteAd', -1, id)
        else
            return false
        end

        return true
    else
        return false
    end    
end

RegisterServerEvent('mythic_base:server:Logout')
AddEventHandler('mythic_base:server:Logout', function()
    DeleteAd(source)
end)

RegisterServerEvent('mythic_base:server:CharacterSpawned')
AddEventHandler('mythic_base:server:CharacterSpawned', function()
    TriggerClientEvent('mythic_phone:client:SetupData', source, { { name = 'adverts', data = Advertisements } })
end)

AddEventHandler('playerDropped', function()
    DeleteAd(source)
end)

AddEventHandler('mythic_base:shared:ComponentsReady', function()
    Callbacks = Callbacks or exports['mythic_base']:FetchComponent('Callbacks')

    Callbacks:RegisterServerCallback('mythic_phone:server:NewAd', function(source, data, cb)
        local char = exports['mythic_base']:FetchComponent('Fetch'):Source(source):GetData('character')
        local id = char:GetData('id')
        cb(CreateAd({
            id = id,
            author = char:getFullName(),
            number = char:GetData('phone'),
            date = data.date,
            title = data.title,
            message = data.message
        }))
    end)

    Callbacks:RegisterServerCallback('mythic_phone:server:DeleteAd', function(source, data, cb)
        cb(DeleteAd(source))
    end)
end)