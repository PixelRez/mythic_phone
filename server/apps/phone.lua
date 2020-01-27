Calls = {}

function CreateCallRecord(sender, receiver, state)

end

AddEventHandler('playerDropped', function()
    local mPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(source)
    if mPlayer ~= nil then
        local char = mPlayer:GetData('character')
        local cData = char:GetData()
        if Calls[cData.phone] ~= nil then
            local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):Phone(Calls[cData.phone].number)
            if tPlayer ~= nil then
                TriggerClientEvent('mythic_phone:client:EndCall', tPlayer:GetData('source'))
            else
                Calls[Calls[cData.phone].number]= nil
            end
            Calls[cData.phone] = nil
        end
    end
end)

RegisterServerEvent('mythic_base:server:CharacterSpawned')
AddEventHandler('mythic_base:server:CharacterSpawned', function()
    local src = source
    local char = exports['mythic_base']:FetchComponent('Fetch'):Source(src):GetData('character')
    local cData = char:GetData()

    Citizen.CreateThread(function()
        exports['ghmattimysql']:execute('SELECT * FROM phone_calls WHERE (sender = @number AND sender_deleted = 0) OR (receiver = @number AND receiver_deleted = 0) LIMIT 50', { ['number'] = cData.phone }, function(history) 
            TriggerClientEvent('mythic_phone:client:SetupData', src, { { name = 'history', data = history } })
        end)
    end)
end)

AddEventHandler('mythic_base:shared:ComponentsReady', function()
    Callbacks = Callbacks or exports['mythic_base']:FetchComponent('Callbacks')

    Callbacks:RegisterServerCallback('mythic_phone:server:CreateCall', function(source, data, cb)
        local char = exports['mythic_base']:FetchComponent('Fetch'):Source(source):GetData('character')
        local cData = char:GetData()

        local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):Phone(data.number)
        if tPlayer ~= nil then
            if tPlayer:GetData('source') ~= nil then
                if Calls[data.number] ~= nil then
                    cb(-3)
                    TriggerClientEvent('mythic_notify:client:SendAlert', tPlayer:GetData('source'), { type = 'inform', text = char:getFullName() .. ' Tried Calling You, Sending Busy Response'})
                else
                    exports['ghmattimysql']:execute('INSERT INTO phone_calls (sender, receiver, status, anon) VALUES(@sender, @receiver, @status, @anon)', {
                        ['sender'] = cData.phone,
                        ['receiver'] = data.number,
                        ['status'] = 0,
                        ['anon'] = data.nonStandard
                    }, function(status)
                        if status.affectedRows > 0 then
                            cb(1)
            
                            TriggerClientEvent('mythic_phone:client:CreateCall', source, cData.phone)
                            if data.nonStandard then
                                TriggerClientEvent('mythic_phone:client:ReceiveCall', tPlayer:GetData('source'), 'Anonymous Caller')
                                TriggerClientEvent('mythic_notify:client:PersistentAlert', tPlayer:GetData('source'), { id = Config.IncomingNotifId, action = 'start', type = 'inform', text = 'Recieve A Call From A Hidden Number', style = { ['background-color'] = '#ff8555', ['color'] = '#ffffff' } })
                            else
                                TriggerClientEvent('mythic_phone:client:ReceiveCall', tPlayer:GetData('source'), cData.phone)
                                TriggerClientEvent('mythic_notify:client:PersistentAlert', tPlayer:GetData('source'), { id = Config.IncomingNotifId, action = 'start', type = 'inform', text = char:getFullName() .. ' Is Calling You', style = { ['background-color'] = '#ff8555', ['color'] = '#ffffff' } })
                            end
                            
                            Calls[cData.phone] = {
                                number = data.number,
                                status = 0,
                                record = status.insertId
                            }
                            Calls[data.number] = {
                                number = cData.phone,
                                status = 0,
                                record = status.insertId
                            }
                        else
                            cb(-1)
                        end
                    end)
                end
            else
                cb(-2)
            end
        else
            cb(-1)
        end
    end)
    
    Callbacks:RegisterServerCallback('mythic_phone:server:DeleteCallRecord', function(source, data, cb)
        local char = exports['mythic_base']:FetchComponent('Fetch'):Source(source):GetData('character')
        local cData = char:GetData()
    
        exports['ghmattimysql']:execute('SELECT * FROM phone_calls WHERE id = @id', { ['id'] = data.id }, function(record)
            if record[1] ~= nil then
                if record[1].sender == cData.phone then
                    exports['ghmattimysql']:execute('UPDATE phone_calls SET sender_deleted = 1 WHERE id = @id AND sender = @phone', { ['id'] = id, ['phone'] = cData.phone }, function(status)
                        if status.affectedRows > 0 then
                            cb(true)
                        else
                            cb(false)
                        end
                    end)
                else
                    exports['ghmattimysql']:execute('UPDATE phone_calls SET receiver_deleted = 1 WHERE id = @id AND receiver = @phone', { ['id'] = id, ['phone'] = cData.phone }, function(status)
                        if status.affectedRows > 0 then
                            cb(true)
                        else
                            cb(false)
                        end
                    end)
                end
            else
                cb(false)
            end
        end)
    end)
end)

RegisterServerEvent('mythic_phone:server:ToggleHold')
AddEventHandler('mythic_phone:server:ToggleHold', function(call)
    local src = source
    local char = exports['mythic_base']:FetchComponent('Fetch'):Source(src):GetData('character')
    local cData = char:GetData()
    local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):Phone(Calls[call.number].number)
    TriggerClientEvent('mythic_phone:client:OtherToggleHold', tPlayer:GetData('source'))
end)

RegisterServerEvent('mythic_phone:server:AcceptCall')
AddEventHandler('mythic_phone:server:AcceptCall', function()
    local src = source
    local char = exports['mythic_base']:FetchComponent('Fetch'):Source(src):GetData('character')
    local cData = char:GetData()

    if Calls[cData.phone] ~= nil then
        local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):Phone(Calls[cData.phone].number)
        if tPlayer ~= nil then
            if (Calls[cData.phone].number ~= nil) and (Calls[Calls[cData.phone].number].number ~= nil) then
                Calls[Calls[cData.phone].number].status = 1
                Calls[cData.phone].status = 1

                TriggerClientEvent('mythic_phone:client:AcceptCall', src, (tPlayer:GetData('source') + 100), false)
                TriggerClientEvent('mythic_phone:client:AcceptCall', tPlayer:GetData('source'), (tPlayer:GetData('source') + 100), true)
            else
                Calls[Calls[cData.phone].number] = nil
                Calls[cData.phone] = nil
                TriggerClientEvent('mythic_phone:client:EndCall', src)
                TriggerClientEvent('mythic_phone:client:EndCall', tPlayer:GetData('source'))
            end
        else
            TriggerClientEvent('mythic_phone:client:EndCall', src)
        end
    end
end)

RegisterServerEvent('mythic_phone:server:EndCall')
AddEventHandler('mythic_phone:server:EndCall', function()
    local src = source
    
    local char = exports['mythic_base']:FetchComponent('Fetch'):Source(src):GetData('character')
    local cData = char:GetData()

    if Calls[cData.phone] ~= nil then
        local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):Phone(Calls[cData.phone].number)
        if tPlayer ~= nil then
            Calls[Calls[cData.phone].number] = nil
            Calls[cData.phone] = nil

            TriggerClientEvent('mythic_phone:client:EndCall', src)
            TriggerClientEvent('mythic_phone:client:EndCall', tPlayer:GetData('source'))
        end
    end
end)