TriggerEvent(
    "mythic_base:server:RegisterUsableItem",
    "simcard",
    function(source, item)
        -- TriggerEvent('mythic_phone:server:StartInstallApp', source, item)
        local char = exports["utils"]:getIdentity(src)
        char.Inventory.Temporary:Add(
            item,
            function(status)
                if status ~= nil then
                    TriggerClientEvent("mythic_notify:client:SendAlert", source, {type = "inform", text = "lol woot"})
                else
                    TriggerClientEvent(
                        "mythic_notify:client:SendAlert",
                        source,
                        {type = "error", text = "Unable To Use Sim Card"}
                    )
                end
            end
        )
    end
)
