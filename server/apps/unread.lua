function ResetUnreads()
    local table = {}
    for k, v in ipairs(Config.Apps) do
        table[v.container] = 0
    end
    return table
end

-- RegisterServerEvent('mythic_base:server:Logout')
-- AddEventHandler('mythic_base:server:Logout', function()
--     local src = source
--     local mPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(src)
--     if mPlayer ~= nil then
--         local char = mPlayer:GetData('character')
--         local cid = char:GetData('id')
--         if char ~= nil then
--             if Cache:Get('phone-unread')[cid] ~= nil then
--                 exports['ghmattimysql']:execute('UPDATE phone_unread SET data = @data WHERE charid = @charid', {
--                     ['data'] = json.encode(Cache:Get('phone-unread')[cid].unread),
--                     ['charid'] = cid
--                 }, function(res)
--                     if res.affectedRows > 0 then
--                         Cache.Remove:Index('phone-unreads', cid)
--                     end
--                 end)
--             end
--         end
--     end
-- end)

-- AddEventHandler('playerDropped', function()
--     local src = source
--     local mPlayer = exports['mythic_base']:FetchComponent('Fetch'):Source(src)
--     if mPlayer ~= nil then
--         local char = mPlayer:GetData('character')
--         local cid = char:GetData('id')
--         if char ~= nil then
--             if Cache:Get('phone-unread')[cid] ~= nil then
--                 exports['ghmattimysql']:execute('UPDATE phone_unread SET data = @data WHERE charid = @charid', {
--                     ['data'] = json.encode(Cache:Get('phone-unread')[cid].unread),
--                     ['charid'] = cid
--                 }, function(res)
--                     if res.affectedRows > 0 then
--                         Cache.Remove:Index('phone-unreads', cid)
--                     end
--                 end)
--             end
--         end
--     end
-- end)

-- Uncomment when ready to implement this
-- RegisterServerEvent("serverCharacterSpawned")
-- AddEventHandler(
--     "serverCharacterSpawned",
--     function()
--         local src = source
--         -- local char = exports["mythic_base"]:FetchComponent("Fetch"):Source(src):GetData("character")
--         local char = exports["utils"]:getIdentity(src)

--         local unreads = Cache:Get("phone-unread")[char:GetData("id")]
--         if unreads == nil then
--             exports["ghmattimysql"]:scalar(
--                 "SELECT data FROM phone_unread WHERE charid = @charid",
--                 {["charid"] = char:GetData("id")},
--                 function(unread)
--                     if unread ~= nil then
--                         if json.decode(unread) ~= nil then
--                             Cache.Add:Index(
--                                 "phone-unread",
--                                 char:GetData("id"),
--                                 {
--                                     charid = char:GetData("id"),
--                                     unread = json.decode(unread)
--                                 }
--                             )

--                             TriggerClientEvent("mythic_phone:client:SyncUnread", src, json.decode(unread))
--                         else
--                             unreads = ResetUnreads()
--                             Cache.Add:Index(
--                                 "phone-unread",
--                                 char:GetData("id"),
--                                 {
--                                     charid = char:GetData("id"),
--                                     unread = unreads
--                                 }
--                             )

--                             TriggerClientEvent("mythic_phone:client:SyncUnread", src, unreads)
--                         end
--                     else
--                         unreads = ResetUnreads()
--                         Cache.Add:Index(
--                             "phone-unread",
--                             char:GetData("id"),
--                             {
--                                 charid = char:GetData("id"),
--                                 unread = unreads
--                             }
--                         )

--                         TriggerClientEvent("mythic_phone:client:SyncUnread", src, unreads)
--                     end
--                 end
--             )
--         else
--             TriggerClientEvent("mythic_phone:client:SyncUnread", src, unreads)
--         end
--     end
-- )

AddEventHandler(
    "mythic_base:shared:ComponentsReady",
    function()
        -- Callbacks = Callbacks or exports['mythic_base']:FetchComponent('Callbacks')
        Cache = Cache or exports["mythic_base"]:FetchComponent("Cache")

        Cache:Set(
            "phone-unread",
            {},
            function(data)
                for k, v in pairs(data) do
                    if v.charid ~= nil and v.unread ~= nil then
                        exports["ghmattimysql"]:execute(
                            "INSERT INTO `phone_unread` (`charid`, `data`) VALUES (@charid, @data) ON DUPLICATE KEY UPDATE `data` = VALUES(`data`)",
                            {
                                ["charid"] = v.charid,
                                ["data"] = json.encode(v.unread)
                            }
                        )
                    end
                end
            end
        )

        ESX.RegisterServerCallback(
            "mythic_phone:server:SetUnread",
            function(source, data, cb)
                -- local char = exports["mythic_base"]:FetchComponent("Fetch"):Source(source):GetData("character")
                local char = exports["utils"]:getIdentity(source)

                local unreads = Cache:Get("phone-unread")[char:GetData("id")]
                if unreads == nil then
                    exports["ghmattimysql"]:scalar(
                        "SELECT data FROM phone_unread WHERE charid = @charid",
                        {["charid"] = char:GetData("id")},
                        function(unread)
                            if unread ~= nil then
                                unreads = json.decode(unread)
                            else
                                unread = ResetUnreads()
                            end
                        end
                    )

                    while unread == nil do
                        Citizen.Wait(5)
                    end
                end

                if unreads.unread[data.app] ~= data.unread then
                    unreads.unread[data.app] = data.unread
                    Cache.Update:Index("phone-unread", char:GetData("id"), unreads)
                end

                cb(unreads.unread[data.app])
            end
        )
    end
)
