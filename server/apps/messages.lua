ESX = nil

TriggerEvent(
    "esx:getSharedObject",
    function(obj)
        ESX = obj
    end
)

RegisterServerEvent("mythic_base:server:CharacterSpawned")
AddEventHandler(
    "mythic_base:server:CharacterSpawned",
    function()
        local src = source
        local char = exports["mythic_base"]:FetchComponent("Fetch"):Source(src):GetData("character")
        local cData = char:GetData()

        Citizen.CreateThread(
            function()
                exports["ghmattimysql"]:execute(
                    "SELECT * FROM phone_texts WHERE (sender = @number AND sender_deleted = 0) OR (receiver = @number AND receiver_deleted = 0)",
                    {["number"] = cData.phone},
                    function(messages)
                        TriggerClientEvent("mythic_phone:client:SetupData", src, {{name = "messages", data = messages}})
                    end
                )
            end
        )
    end
)

ESX.RegisterServerCallback(
    "mythic_phone:server:SendText",
    function(source, data, cb)
        local char = exports["mythic_base"]:FetchComponent("Fetch"):Source(source):GetData("character")
        local cData = char:GetData()

        Citizen.CreateThread(
            function()
                exports["ghmattimysql"]:execute(
                    "INSERT INTO phone_texts (`sender`, `receiver`, `message`) VALUES(@sender, @receiver, @message)",
                    {["sender"] = cData.phone, ["receiver"] = data.receiver, ["message"] = data.message},
                    function(status)
                        if status.affectedRows > 0 then
                            exports["ghmattimysql"]:execute(
                                "SELECT * FROM phone_texts WHERE id = @id",
                                {["id"] = status.insertId},
                                function(text)
                                    if text[1] ~= nil then
                                        cb(text[1])

                                        local tPlayer = exports["mythic_base"]:FetchComponent("Fetch"):Phone(receiver)
                                        if tPlayer ~= nil then
                                            local tChar = tPlayer:GetData("character"):GetData()
                                            exports["ghmattimysql"]:execute(
                                                "SELECT * FROM phone_contacts WHERE number = @number AND charid = @charid",
                                                {["number"] = cData.phone, ["charid"] = tChar.id},
                                                function(contact)
                                                    if contact[1] ~= nil then
                                                        TriggerClientEvent(
                                                            "mythic_phone:client:ReceiveText",
                                                            tPlayer:GetData("source"),
                                                            contact[1].name,
                                                            text[1]
                                                        )
                                                    else
                                                        TriggerClientEvent(
                                                            "mythic_phone:client:ReceiveText",
                                                            tPlayer:GetData("source"),
                                                            cData.phone,
                                                            text[1]
                                                        )
                                                    end
                                                end
                                            )
                                        end
                                    else
                                        cb(false)
                                    end
                                end
                            )
                        else
                            cb(false)
                        end
                    end
                )
            end
        )
    end
)

ESX.RegisterServerCallback(
    "mythic_phone:server:DeleteConversation",
    function(source, data, cb)
        local char = exports["mythic_base"]:FetchComponent("Fetch"):Source(source):GetData("character")
        local cData = char:GetData()

        exports["ghmattimysql"]:execute(
            "UPDATE phone_texts SET sender_deleted = 1 WHERE sender = @me AND receiver = @other",
            {["me"] = cData.phone, ["other"] = data.number},
            function(status1)
                exports["ghmattimysql"]:execute(
                    "UPDATE phone_texts SET receiver_deleted = 1 WHERE receiver = @me AND sender = @other",
                    {["me"] = cData.phone, ["other"] = data.number},
                    function(status2)
                        cb(status1 ~= nil and status2 ~= nil)
                    end
                )
            end
        )
    end
)
