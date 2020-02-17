Calls = {}

function CreateCallRecord(sender, receiver, state)
end

-- print("mythic_phone/server/apps/phone.lua Calls")
-- print(exports["utils"]:tprint(Calls))

AddEventHandler(
    "playerDropped",
    function(source)
        local src = source
        if src ~= nil then
            local cData = exports["utils"]:getIdentity(src)

            if Calls[cData.phone_number] ~= nil then
                local tPlayerId = exports["utils"]:getIdentifierByPhoneNumber(Calls[cData.phone_number].number)
                if tPlayerId ~= nil then
                    local tPlayerSourceID = ESX.GetPlayerFromIdentifier(tPlayerId).source
                    TriggerClientEvent("mythic_phone:client:EndCall", tPlayerSourceID)
                else
                    Calls[Calls[cData.phone_number].number] = nil
                end
                Calls[cData.phone_number] = nil
            end
        end
    end
)

RegisterServerEvent("serverCharacterSpawned")
AddEventHandler(
    "serverCharacterSpawned",
    function()
        local src = source
        local cData = exports["utils"]:getIdentity(src)
        -- print("mythic_phone/server/apps/phone.lua serverCharacterSpawned")
        -- print("cData")
        -- print(exports["utils"]:tprint(cData))

        Citizen.CreateThread(
            function()
                exports["ghmattimysql"]:execute(
                    "SELECT * FROM phone_calls WHERE (sender = @number AND sender_deleted = 0) OR (receiver = @number AND receiver_deleted = 0) LIMIT 50",
                    {["number"] = cData.phone_number},
                    function(history)
                        TriggerClientEvent("mythic_phone:client:SetupData", src, {{name = "history", data = history}})
                    end
                )
            end
        )
    end
)

ESX.RegisterServerCallback(
    "mythic_phone:server:CreateCall",
    function(source, cb, data)
        local src = source
        local cData = exports["utils"]:getIdentity(src)

        -- print("mythic_phone:server:CreateCall")
        -- print("Source")
        -- print(src)
        -- print("Character Data")
        -- print(exports["utils"]:tprint(cData))
        -- print("Callback Data")
        -- print(exports["utils"]:tprint(cb))
        -- print("GETTING FULLNAME")
        -- print(getFullName(cData))

        local tPlayerId = exports["utils"]:getIdentifierByPhoneNumber(data.number)
        if tPlayerId ~= nil then
            local tPlayerSourceID = ESX.GetPlayerFromIdentifier(tPlayerId).source
            -- local tPlayerSourceID = 1
            -- if tPlayerSourceID ~= nil then -- Add ability to call self
            if tPlayerSourceID ~= nil and tPlayerSourceID ~= src then -- Remove ability to call self
                if Calls[data.number] ~= nil then
                    cb(-3)
                    TriggerClientEvent(
                        "mythic_notify:client:SendAlert",
                        tPlayerSourceID,
                        {
                            type = "inform",
                            text = getFullName(cData) .. " Tried Calling You, Sending Busy Response"
                        }
                    )
                else
                    exports["ghmattimysql"]:execute(
                        "INSERT INTO phone_calls (sender, receiver, status, anon) VALUES(@sender, @receiver, @status, @anon)",
                        {
                            ["sender"] = cData.phone_number,
                            ["receiver"] = data.number,
                            ["status"] = 0,
                            ["anon"] = data.nonStandard
                        },
                        function(status)
                            if status.affectedRows > 0 then
                                cb(1)

                                TriggerClientEvent("mythic_phone:client:CreateCall", source, cData.phone_number)
                                if data.nonStandard then
                                    TriggerClientEvent(
                                        "mythic_phone:client:ReceiveCall",
                                        tPlayerSourceID,
                                        "Anonymous Caller"
                                    )
                                    TriggerClientEvent(
                                        "mythic_notify:client:PersistentAlert",
                                        tPlayerSourceID,
                                        {
                                            id = Config.IncomingNotifId,
                                            action = "start",
                                            type = "inform",
                                            text = "Recieve A Call From A Hidden Number",
                                            style = {["background-color"] = "#ff8555", ["color"] = "#ffffff"}
                                        }
                                    )
                                else
                                    TriggerClientEvent(
                                        "mythic_phone:client:ReceiveCall",
                                        tPlayerSourceID,
                                        cData.phone_number
                                    )
                                    TriggerClientEvent(
                                        "mythic_notify:client:PersistentAlert",
                                        tPlayerSourceID,
                                        {
                                            id = Config.IncomingNotifId,
                                            action = "start",
                                            type = "inform",
                                            text = getFullName(cData) .. " Is Calling You",
                                            style = {["background-color"] = "#ff8555", ["color"] = "#ffffff"}
                                        }
                                    )
                                end

                                Calls[cData.phone_number] = {
                                    number = data.number,
                                    status = 0,
                                    record = status.insertId
                                }
                                Calls[data.number] = {
                                    number = cData.phone_number,
                                    status = 0,
                                    record = status.insertId
                                }
                            else
                                cb(-1)
                            end
                        end
                    )
                end
            else
                cb(-2)
            end
        else
            cb(-1)
        end
    end
)

ESX.RegisterServerCallback(
    "mythic_phone:server:DeleteCallRecord",
    function(source, cb, data)
        local cData = exports["utils"]:getIdentity(src)

        exports["ghmattimysql"]:execute(
            "SELECT * FROM phone_calls WHERE id = @id",
            {["id"] = data.id},
            function(record)
                if record[1] ~= nil then
                    if record[1].sender == cData.phone_number then
                        exports["ghmattimysql"]:execute(
                            "UPDATE phone_calls SET sender_deleted = 1 WHERE id = @id AND sender = @phone",
                            {["id"] = id, ["phone"] = cData.phone_number},
                            function(status)
                                if status.affectedRows > 0 then
                                    cb(true)
                                else
                                    cb(false)
                                end
                            end
                        )
                    else
                        exports["ghmattimysql"]:execute(
                            "UPDATE phone_calls SET receiver_deleted = 1 WHERE id = @id AND receiver = @phone",
                            {["id"] = id, ["phone"] = cData.phone_number},
                            function(status)
                                if status.affectedRows > 0 then
                                    cb(true)
                                else
                                    cb(false)
                                end
                            end
                        )
                    end
                else
                    cb(false)
                end
            end
        )
    end
)

RegisterServerEvent("mythic_phone:server:ToggleHold")
AddEventHandler(
    "mythic_phone:server:ToggleHold",
    function(call)
        local src = source
        -- local char = exports["mythic_base"]:FetchComponent("Fetch"):Source(src):GetData("character")
        -- local cData = char:GetData()
        local cData = exports["utils"]:getIdentity(src)

        local tPlayerId = exports["utils"]:getIdentifierByPhoneNumber(Calls[cData.phone_number].number)
        local tPlayerSourceID = ESX.GetPlayerFromIdentifier(tPlayerId).source
        TriggerClientEvent("mythic_phone:client:OtherToggleHold", tPlayerSourceID)
    end
)

RegisterServerEvent("mythic_phone:server:AcceptCall")
AddEventHandler(
    "mythic_phone:server:AcceptCall",
    function()
        print("Inside Server AcceptCall")
        local src = source
        -- local char = exports["mythic_base"]:FetchComponent("Fetch"):Source(src):GetData("character")
        -- local cData = char:GetData()
        local cData = exports["utils"]:getIdentity(src)
        -- print("Character Data")
        -- print(exports["utils"]:tprint(cData))
        -- print("Calls")
        -- print(exports["utils"]:tprint(Calls))

        if Calls[cData.phone_number] ~= nil then
            -- local tPlayer = exports["mythic_base"]:FetchComponent("Fetch"):Phone(Calls[cData.phone_number].number)
            local tPlayerId = exports["utils"]:getIdentifierByPhoneNumber(Calls[cData.phone_number].number)
            if tPlayerId ~= nil then
                local tPlayerSourceID = ESX.GetPlayerFromIdentifier(tPlayerId).source
                if (Calls[cData.phone_number].number ~= nil) and (Calls[Calls[cData.phone_number].number].number ~= nil) then
                    Calls[Calls[cData.phone_number].number].status = 1
                    Calls[cData.phone_number].status = 1

                    TriggerClientEvent("mythic_phone:client:AcceptCall", src, (tPlayerSourceID + 100), false)
                    TriggerClientEvent("mythic_phone:client:AcceptCall", tPlayerSourceID, (tPlayerSourceID + 100), true)
                else
                    Calls[Calls[cData.phone_number].number] = nil
                    Calls[cData.phone_number] = nil
                    TriggerClientEvent("mythic_phone:client:EndCall", src)
                    TriggerClientEvent("mythic_phone:client:EndCall", tPlayerSourceID)
                end
            else
                TriggerClientEvent("mythic_phone:client:EndCall", src)
            end
        end
    end
)

RegisterServerEvent("mythic_phone:server:EndCall")
AddEventHandler(
    "mythic_phone:server:EndCall",
    function(data)
        local src = source

        -- local char = exports["mythic_base"]:FetchComponent("Fetch"):Source(src):GetData("character")
        -- local cData = char:GetData()
        local cData = exports["utils"]:getIdentity(src)

        if Calls[cData.phone_number] ~= nil then
            local tPlayerId = exports["utils"]:getIdentifierByPhoneNumber(Calls[cData.phone_number].number)

            -- local tPlayer = exports["mythic_base"]:FetchComponent("Fetch"):Phone(Calls[cData.phone_number].number)
            if tPlayerId ~= nil then
                local tPlayerSourceID = ESX.GetPlayerFromIdentifier(tPlayerId).source
                -- local tPlayerSourceID = 1

                Calls[Calls[cData.phone_number].number] = nil
                Calls[cData.phone_number] = nil

                TriggerClientEvent("mythic_phone:client:EndCall", src)
                TriggerClientEvent("mythic_phone:client:EndCall", tPlayerSourceID)
            end
        end
    end
)

function getFullName(char)
    if char ~= nil then
        return char.firstname .. " " .. char.lastname
    end
end
