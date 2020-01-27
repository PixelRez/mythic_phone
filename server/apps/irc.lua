RegisterServerEvent('mythic_base:server:CharacterSpawned')
AddEventHandler('mythic_base:server:CharacterSpawned', function()
    local src = source
    local char = exports['mythic_base']:FetchComponent('Fetch'):Source(src):GetData('character')
    local cData = char:GetData()

    Citizen.CreateThread(function()
        local myChannels = {}
        exports['ghmattimysql']:execute('SELECT ch.* FROM phone_irc_channels ch INNER JOIN phone_irc_messages mess ON ch.channel = mess.channel WHERE charid = @charid GROUP BY mess.channel ORDER BY mess.date DESC', {
            ['charid'] = cData.id
        }, function(channels)
            TriggerClientEvent('mythic_phone:client:SetupData', src, { { name = 'irc-channels', data = channels } })
        end)
    end)
end)

AddEventHandler('mythic_base:shared:ComponentsReady', function()
    Callbacks = Callbacks or exports['mythic_base']:FetchComponent('Callbacks')

    Callbacks:RegisterServerCallback('mythic_phone:server:IRCJoinChannel', function(source, data, cb)
        local char = exports['mythic_base']:FetchComponent('Fetch'):Source(source):GetData('character')
        local cData = char:GetData()

        exports['ghmattimysql']:execute('INSERT INTO phone_irc_channels (charid, channel) VALUES(@charid, @channel)', { ['charid'] = cData.id, ['channel'] = data.channel }, function(status)
            cb(status.affectedRows > 0)
        end)
    end)

    Callbacks:RegisterServerCallback('mythic_phone:server:IRCLeaveChannel', function(source, data, cb)
        local char = exports['mythic_base']:FetchComponent('Fetch'):Source(source):GetData('character')
        local cData = char:GetData()

        exports['ghmattimysql']:execute('DELETE FROM phone_irc_channels WHERE charid = @charid AND channel = @channel', { ['charid'] = cData.id, ['channel'] = data.channel }, function(status)
            cb(status.affectedRows > 0)
        end)
    end)

    Callbacks:RegisterServerCallback('mythic_phone:server:IRCGetMessages', function(source, data, cb)
        local char = exports['mythic_base']:FetchComponent('Fetch'):Source(source):GetData('character')

        exports['ghmattimysql']:scalar('SELECT joined FROM phone_irc_channels WHERE charid = @charid AND channel = @channel', { ['charid'] = char:GetData('id'), ['channel'] = data.channel }, function(joined)
            if joined ~= nil then
                exports['ghmattimysql']:execute('SELECT * FROM phone_irc_messages WHERE channel = @channel AND date >= FROM_UNIXTIME(@joined)', { ['channel'] = data.channel, ['joined'] = (joined / 1000) }, function(msgs)
                    cb(msgs)
                end)
            else
                cb(nil)
            end
        end)
    end)

    Callbacks:RegisterServerCallback('mythic_phone:server:IRCNewMessage', function(source, data, cb)
        local char = exports['mythic_base']:FetchComponent('Fetch'):Source(source):GetData('character')

        exports['ghmattimysql']:scalar('SELECT channel FROM phone_irc_channels WHERE charid = @charid AND channel = @channel', { ['charid'] = char:GetData('id'), ['channel'] = data.channel }, function(channel)
            if channel ~= nil then
                exports['ghmattimysql']:execute('INSERT INTO phone_irc_messages (channel, message) VALUES(@channel, @message)', { ['channel'] = data.channel, ['message'] = data.message }, function(res)
                    if res.affectedRows > 0 then
                        Citizen.CreateThread(function()
                            exports['ghmattimysql']:execute('SELECT * FROM phone_irc_channels WHERE channel = @channel', { ['channel'] = data.channel }, function(data)
                                for k, v in ipairs(data) do
                                    if char:GetData('id') ~= v.charid then
                                        local tPlayer = exports['mythic_base']:FetchComponent('Fetch'):CharId(v.charid)
                                        if tPlayer ~= nil then
                                            TriggerClientEvent('mythic_phone:client:ReceiveNewIRCMessage', tPlayer:GetData('source'), { channel = data.channel, message = data.message })
                                        end
                                    end
                                end
                            end)
                        end)
                    end
                    
                    cb(res.affectedRows > 0)
                end)
            else
                cb(nil)
            end
        end)
    end)

end)