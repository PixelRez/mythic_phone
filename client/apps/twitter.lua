RegisterNetEvent("mythic_phone:client:ReceiveNewTweet")
AddEventHandler(
    "mythic_phone:client:ReceiveNewTweet",
    function(tweet)
        local myname = CharData:GetData("firstName") .. "_" .. CharData:GetData("lastName")

        if tweet.author ~= myname then
            SendNUIMessage(
                {
                    action = "ReceiveNewTweet",
                    tweet = tweet
                }
            )
        end
    end
)

RegisterNetEvent("mythic_phone:client:MentionedInTweet")
AddEventHandler(
    "mythic_phone:client:MentionedInTweet",
    function(author)
        local app = GetAppData("twitter")
        UpdateAppUnread("twitter", app.unread + 1)

        PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
        exports["mythic_notify"]:SendAlert(
            "inform",
            "@" .. author .. " Mentioned You In A Tweet",
            2500,
            {["background-color"] = "#039be5"}
        )
    end
)

RegisterNUICallback(
    "NewTweet",
    function(data, cb)
        ESX.TriggerServerCallback(
            "mythic_phone:server:NewTweet",
            cb,
            {message = data.message, mentions = data.mentions, hashtags = data.hashtags}
        )
    end
)
