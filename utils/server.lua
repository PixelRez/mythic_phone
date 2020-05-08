ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function getPlayerID(source)
    local identifiers = GetPlayerIdentifiers(source)
    local player = getIdentifiant(identifiers)
    return player
end
function getIdentifiant(id)
    for _, v in ipairs(id) do
        return v
    end
end

function getIdentifierByPhoneNumber(phone_number) 
    local result = exports["ghmattimysql"]:execute("SELECT users.identifier FROM users WHERE users.phone_number = @phone_number", {
        ['@phone_number'] = phone_number
    })
    end

function getIdentity(source, callback)
    local identifier = GetPlayerIdentifiers(source)[1]
    local xPlayer = ESX.GetPlayerFromId(src)

    exports["ghmattimysql"]:execute('SELECT identifier, firstname, lastname, dateofbirth, sex, height, phone_number FROM `users` WHERE `identifier` = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result[1].identifier ~= nil then
            local cData = {
                identifier    = result[1].identifier,
                firstname    = result[1].firstname,
                lastname    = result[1].lastname,
                dateofbirth    = result[1].dateofbirth,
                sex            = result[1].sex,
                height        = result[1].height,
		        phone_number  = result[1].phone_number,
            }

        else
            local cData = {
                identifier    = '',
                firstname    = '',
                lastname    = '',
                dateofbirth    = '',
                sex            = '',
                height        = '',
		        phone_number  = '',
            }

        end
    end)
end
