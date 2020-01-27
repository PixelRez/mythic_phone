RegisterServerEvent('mythic_base:server:CharacterSpawned')
AddEventHandler('mythic_base:server:CharacterSpawned', function()
    local src = source
    local char = exports['mythic_base']:FetchComponent('Fetch'):Source(src):GetData('character')
    local cData = char:GetData()


    Citizen.CreateThread(function()
        local contactData = {}
        exports['ghmattimysql']:execute('SELECT name, number FROM phone_contacts WHERE charid = @charid', { ['charid'] = cData.id }, function(contacts) 
            for k, v in pairs(contacts) do
                table.insert(contactData, v)
            end

            TriggerClientEvent('mythic_phone:client:SetupData', src, { { name = 'contacts', data = contactData } })
        end)
    end)
end)

AddEventHandler('mythic_base:shared:ComponentsReady', function()
    Callbacks = Callbacks or exports['mythic_base']:FetchComponent('Callbacks')

    Callbacks:RegisterServerCallback('mythic_phone:server:CreateContact', function(source, data, cb)
        local char = exports['mythic_base']:FetchComponent('Fetch'):Source(source):GetData('character')
        local cData = char:GetData()

        exports['ghmattimysql']:execute('INSERT INTO phone_contacts (`charid`, `number`, `name`) VALUES(@charid, @number, @name)', { ['charid'] = cData.id, ['number'] = data.number, ['name'] = data.name }, function(status) 
            if status.affectedRows > 0 then
                cb(true)
            else
                cb(false)
            end
        end)
    end)

    Callbacks:RegisterServerCallback('mythic_phone:server:EditContact', function(source, data, cb)
        local char = exports['mythic_base']:FetchComponent('Fetch'):Source(source):GetData('character')
        local cData = char:GetData()
    
        exports['ghmattimysql']:execute('UPDATE phone_contacts SET name = @name, number = @number WHERE charid = @charid AND name = @oName AND number = @oNumber', { ['name'] = data.name, ['number'] = data.number, ['id'] = data.id, ['charid'] = cData.id, ['oName'] = data.originName, ['oNumber'] = data.originNumber }, function(status) 
            if status.affectedRows > 0 then
                cb(true)
            else
                cb(false)
            end
        end)
    end)

    Callbacks:RegisterServerCallback('mythic_phone:server:DeleteContact', function(source, data, cb)
        local char = exports['mythic_base']:FetchComponent('Fetch'):Source(source):GetData('character')
        local cData = char:GetData()
    
        exports['ghmattimysql']:execute('DELETE FROM phone_contacts WHERE charid = @charid AND name = @name AND number = @number', { ['charid'] = cData.id, ['name'] = data.name, ['number'] = data.number }, function(status) 
            if status.affectedRows > 0 then
                cb(true)
            else
                cb(false)
            end
        end)
    end)
end)