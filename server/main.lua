ESX = nil

TriggerEvent(
    "esx:getSharedObject",
    function(obj)
        ESX = obj
    end
)

AppData = {}
Cache = nil
xPlayer = nil

function RegisterData(source, key, data)
    if AppData[source] ~= nil then
        AppData[source].key = data
    else
        AppData[source] = {}
        AppData[source].key = data
    end
end

AddEventHandler(
    "playerDropped",
    function(source)
        local src = source
        TriggerClientEvent("playerLogout", src)
    end
)

AddEventHandler(
    "esx:playerLoaded",
    function()
        TriggerEvent("serverCharacterSpawned")
    end
)

RegisterServerEvent("checkForPhone")
AddEventHandler(
    "checkForPhone",
    function()
        local _source = source
        Citizen.CreateThread(
            function()
                while xPlayer == nil do
                    Citizen.Wait(5)
                    xPlayer = ESX.GetPlayerFromId(_source)
                end
                if xPlayer ~= nil then
                    if xPlayer.getInventoryItem("phone").count >= 1 then
                        TriggerClientEvent("togglePhone", _source)
                    else
                        TriggerClientEvent("noPhone", _source)
                    end
                end
            end
        )
    end
)

RegisterServerEvent("serverCharacterSpawned")
AddEventHandler(
    "serverCharacterSpawned",
    function()
        print("character spawned or loaded, setup phone")
        local src = source
        local cData = exports["utils"]:getIdentity(src)
        print(exports["utils"]:tprint(cData))
        TriggerClientEvent(
            "mythic_phone:client:SetupData",
            src,
            {
                {
                    name = "myData",
                    data = {
                        id = cData.identifier,
                        name = cData.firstname .. " " .. cData.lastname,
                        phone = cData.phone_number_number
                    }
                },
                {name = "apps", data = Config.Apps}
            }
        )
    end
)

ESX.RegisterServerCallback(
    "mythic_phone:server:GetData",
    function(source, data, cb)
        RegisterData(source, data.key, data.data)
        cb(true)
    end
)

ESX.RegisterServerCallback(
    "mythic_phone:server:GetData",
    function(source, data, cb)
        cb(AppData[source][data.key])
    end
)
