ESX = nil

TriggerEvent(
    "esx:getSharedObject",
    function(obj)
        ESX = obj
    end
)

AddEventHandler(
    "esx:playerLoaded",
    function(source)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        local playerId = xPlayer.getIdentifier()

        Citizen.CreateThread(
            function()
                local contactData = {}
                MySQL.Async.fetchAll(
                    "SELECT name, number FROM phone_contacts WHERE charid = @charid",
                    {["@charid"] = playerId},
                    function(contacts)
                        for k, v in pairs(contacts) do
                            table.insert(contactData, v)
                        end

                        TriggerClientEvent(
                            "mythic_phone:client:SetupData",
                            src,
                            {{name = "contacts", data = contactData}}
                        )
                    end
                )
            end
        )
    end
)

ESX.RegisterServerCallback(
    "mythic_phone:server:CreateContact",
    function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerId = xPlayer.getIdentifier()

        MySQL.Async.execute(
            "INSERT INTO phone_contacts (`charid`, `number`, `name`) VALUES(@charid, @number, @name)",
            {["@charid"] = playerId, ["@number"] = data.number, ["@name"] = data.name},
            function(status)
                if status > 0 then
                    cb(true)
                else
                    cb(false)
                end
            end
        )
    end
)

ESX.RegisterServerCallback(
    "mythic_phone:server:EditContact",
    function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerId = xPlayer.getIdentifier()

        MySQL.Async.execute(
            "UPDATE phone_contacts SET name = @name, number = @number WHERE charid = @charid AND name = @oName AND number = @oNumber",
            {
                ["@name"] = data.name,
                ["@number"] = data.number,
                ["@charid"] = playerId,
                ["@oName"] = data.originName,
                ["@oNumber"] = data.originNumber
            },
            function(status)
                if status > 0 then
                    cb(true)
                else
                    cb(false)
                end
            end
        )
    end
)

ESX.RegisterServerCallback(
    "mythic_phone:server:DeleteContact",
    function(source, cb, data)
        local xPlayer = ESX.GetPlayerFromId(source)
        local playerId = xPlayer.getIdentifier()

        MySQL.Async.execute(
            "DELETE FROM phone_contacts WHERE charid = @charid AND name = @name AND number = @number",
            {["@charid"] = playerId, ["@name"] = data.name, ["@number"] = data.number},
            function(status)
                if status > 0 then
                    cb(true)
                else
                    cb(false)
                end
            end
        )
    end
)
