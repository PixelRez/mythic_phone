PUT THE YARN.LOCK IN THE UI MAIN FOLDER AND REPLACE OTHERWISE THE PHONE WILL FACE ISSUES


# Mythic Phone | WIP

This is a custom phone written for Mythic RP. It is replacing an existing port of GCPhone after having loads of issues with trying to successfully port. This is very much a Work In Progress and you should not even look into using this unless you're prepared to do a shitload of work.

## Dependencies

- [InteractSound](https://github.com/plunkettscott/interact-sound))
- [GHMattiMySQL](https://github.com/GHMatti/ghmattimysql)

> This is a WIP resource so this dependency list is very likely to expand as features are added.

### Things to Replace

local tPlayer = exports["mythic_base"]:FetchComponent("Fetch"):Phone(data.number) ---> local tPlayerId = exports["utils"]:getIdentifierByPhoneNumber(data.receiver)
tPlayer:GetData("source") ---> local tPlayerSourceID = ESX.GetPlayerFromIdentifier(tPlayerId).source

### TODO

Text Messages:
Unread messages Indicator at the bottom

Calls:
E to hold G to hangup dont work

### Testing
Calls : 
    Mute
    Hangup
    Call : 
      Contacts
      History
    Answer
    Talking
    Delete

Messages :
    Send
    Receive
    Delete
    Call

Contacts :
    Add
    Delete
    Edit
    Call
    Message
    Search

### Comments

Due to the scope of this project expanding I've ended up adding in some various resources to aid in making the files that need to be included for the phone to funciton in-game end up minified and compressed into as few files as possible but while retaining readability and breaking up the code into logical sections. So due to this you'll need a few things in order to get this working from the source alone.

- JS - Due to how I have the JavaScript structured I have opted to setup webpack to minify the files into a single file. This makes it far easier to add content in the future and not have to mess around with importing as well as ensures the file that's being included in the manifest file will always be the one that has all the data for it. Not sure if there's any sort of major performance issues. When you clone the repo, cd into the html folder and use command `yarn` if you have yarn or `npm install` if you're using npm and it will install all the required dependencies. After that run `yarn run build` or `npm run build` and it will build the minified build.js file needed.

> Note: You can in theory just change the manifest to include the regular JS files as well as add them being included in the HTML file and it'll work. But I will not give any guarantee that it'll work doing so. It's also using ES6 modules so you may end up with errors because of that.

**You not shit with webpack? Feel free to get the stupid thing to work & pack all depedencies needed and make a pull request. Because I cannot for the life of me get that dumbshit to work**

#### Libraries Used

- [jQuery](https://jquery.com/)
- [jQuery Inputmask](http://igorescobar.github.io/jQuery-Mask-Plugin/)
- [jQuery UI](https://jqueryui.com/)
- [noUiSlider](https://github.com/leongersen/noUiSlider)
- [Materialize](https://materializecss.com/)
- [Moment.js](https://momentjs.com/)
- [FontAwesome](https://fontawesome.com/)

---

# Screenshots

### Home

![Home Screen](https://i.imgur.com/oQBKg8X.png)
![Home Screen](https://i.imgur.com/7xH1BkE.gif)

### Contacts

![Contacts App](https://i.imgur.com/1FcOcJc.png)
![Contacts App](https://i.imgur.com/xL9I0xq.png)
![Contacts App](https://i.imgur.com/3tyUB7p.png)
![Contacts App](https://i.imgur.com/kNQOc14.gif)
![Contacts App](https://i.imgur.com/ItGpCwf.gif)
![Contacts App](https://i.imgur.com/2sBWhZY.gif)

### Phone

![Phone App](https://i.imgur.com/asgy0QI.png)
![Phone App](https://i.imgur.com/cMtdIzM.png)
![Phone App](https://i.imgur.com/rzzUKX4.png)

### Messages

![Messages App](https://i.imgur.com/H2lae7o.png)
![Messages App](https://i.imgur.com/FSVIusg.png)
![Messages App](https://i.imgur.com/t3CSGm2.png)
![Messages App](https://i.imgur.com/8OaYbbY.gif)

### Twitter

![Twitter App](https://i.imgur.com/X8pFTY4.png)
![Twitter App](https://i.imgur.com/ENaF9Mu.gif)

# mythic_phone
