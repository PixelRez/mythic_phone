RegisterServerEvent("serverCharacterSpawned")
AddEventHandler(
    "serverCharacterSpawned",
    function()
        local src = source
        Citizen.CreateThread(
            function()
                exports["ghmattimysql"]:execute(
                    "SELECT * FROM phone_tweets ORDER BY time DESC",
                    {},
                    function(tweets)
                        TriggerClientEvent("mythic_phone:client:SetupData", src, {{name = "tweets", data = tweets}})
                    end
                )
            end
        )
    end
)

ESX.RegisterServerCallback(
    "mythic_phone:server:NewTweet",
    function(source, data, cb)
        Citizen.CreateThread(
            function()
                local tweet = {}

                -- local char = exports["mythic_base"]:FetchComponent("Fetch"):Source(source):GetData("character")
                local char = exports["utils"]:getIdentity(source)
                local author = char:GetData("firstName") .. "_" .. char:GetData("lastName")
                local users = exports["mythic_base"]:FetchComponent("Fetch"):All()

                if data.mentions ~= nil then
                    for k, v in pairs(data.mentions) do
                        for k2, v2 in pairs(users) do
                            local mPlayer = exports["mythic_base"]:FetchComponent("Fetch"):Source(v2)
                            local c2 = mPlayer:GetData("character")
                            if ("@" .. c2:GetData("firstName") .. "_" .. c2:GetData("lastName")) == v then
                                TriggerClientEvent(
                                    "mythic_phone:client:MentionedInTweet",
                                    mPlayer:GetData("source"),
                                    author
                                )
                            end
                        end
                    end
                end

                exports["ghmattimysql"]:execute(
                    "INSERT INTO phone_tweets (`author_id`, `author`, `message`) VALUES(@id, @author, @message)",
                    {["id"] = char:GetData("id"), ["author"] = author, ["message"] = data.message},
                    function(status)
                        if status.affectedRows > 0 then
                            tweet.author = author
                            tweet.message = data.message
                            tweet.time = data.time

                            cb(tweet)
                        else
                            cb(false)
                        end
                    end
                )

                if tweet.message ~= nil then
                    TriggerClientEvent("mythic_phone:client:ReceiveNewTweet", -1, tweet)
                end
            end
        )
    end
)
