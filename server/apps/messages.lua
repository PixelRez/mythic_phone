ESX = nil

TriggerEvent(
    "esx:getSharedObject",
    function(obj)
        ESX = obj
    end
)

RegisterServerEvent("serverCharacterSpawned")
AddEventHandler(
    "serverCharacterSpawned",
    function()
        local src = source
        local cData = exports["utils"]:getIdentity(src)

        Citizen.CreateThread(
            function()
                exports["ghmattimysql"]:execute(
                    "SELECT * FROM phone_messages WHERE (sender = @number AND sender_deleted = 0) OR (receiver = @number AND receiver_deleted = 0)",
                    {["number"] = cData.phone_number},
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
    function(source, cb, data)
        local src = source
        local cData = exports["utils"]:getIdentity(src)
        print("cdata")
        print(exports["utils"]:tprint(cData))
        print("sending text")
        print("src")
        print(src)
        print("cb")
        print(exports["utils"]:tprint(cb))
        print("data")
        print(exports["utils"]:tprint(data))

        Citizen.CreateThread(
            function()
                exports["ghmattimysql"]:execute(
                    "INSERT INTO phone_messages (`sender`, `receiver`, `message`) VALUES(@sender, @receiver, @message)",
                    {["sender"] = cData.phone_number, ["receiver"] = data.receiver, ["message"] = data.message},
                    function(status)
                        print("status")
                        print(exports["utils"]:tprint(status))
                        if status.affectedRows > 0 then
                            exports["ghmattimysql"]:execute(
                                "SELECT * FROM phone_messages WHERE id = @id",
                                {["id"] = status.insertId},
                                function(text)
                                    print("text")
                                    print(exports["utils"]:tprint(text))
                                    if text[1] ~= nil then
                                        cb(text[1])

                                        -- local tPlayer = exports["mythic_base"]:FetchComponent("Fetch"):Phone(receiver)
                                        -- SEE IF THIS IS OK, CALLS TO A SYNCHRONOUS SQL CALL FOR GETTING IDENTIFIER
                                        local tPlayerId = exports["utils"]:getIdentifierByPhoneNumber(data.receiver)
                                        if tPlayerId ~= nil then
                                            local tPlayerSourceID = ESX.GetPlayerFromIdentifier(tPlayerId).source
                                            exports["ghmattimysql"]:execute(
                                                "SELECT * FROM phone_contacts WHERE number = @number AND charid = @charid",
                                                {["number"] = cData.phone_number, ["charid"] = tPlayerId},
                                                function(contact)
                                                    if contact[1] ~= nil then
                                                        TriggerClientEvent(
                                                            "mythic_phone:client:ReceiveText",
                                                            tPlayerSourceID,
                                                            contact[1].name,
                                                            text[1]
                                                        )
                                                    else
                                                        print("we should be sending a message WITHOUT a contact")
                                                        TriggerClientEvent(
                                                            "mythic_phone:client:ReceiveText",
                                                            tPlayerSourceID,
                                                            cData.phone_number,
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
    function(source, cb, data)
        local src = source
        local cData = exports["utils"]:getIdentity(src)

        exports["ghmattimysql"]:execute(
            "UPDATE phone_messages SET sender_deleted = 1 WHERE sender = @me AND receiver = @other",
            {["me"] = cData.phone_number, ["other"] = data.number},
            function(status1)
                exports["ghmattimysql"]:execute(
                    "UPDATE phone_messages SET receiver_deleted = 1 WHERE receiver = @me AND sender = @other",
                    {["me"] = cData.phone_number, ["other"] = data.number},
                    function(status2)
                        cb(status1 ~= nil and status2 ~= nil)
                    end
                )
            end
        )
    end
)
