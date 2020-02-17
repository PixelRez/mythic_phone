import Config from "./config";
import Data from "./utils/data";
import Utils from "./utils/utils";
import Notif from "./utils/notification";
import Unread from "./utils/unread";
import Apps from "./apps/apps";

import "../../css/src/materialize.scss";
import "../../css/src/style.scss";

import Test from "./test";
import custom from "./apps/tuner/custom";

var appTrail = [
  {
    app: null,
    data: null,
    fade: null
  }
];

moment.fn.fromNowOrNow = function (a) {
  if (Math.abs(moment().diff(this)) < 60000) {
    return "just now";
  }
  return this.fromNow(a);
};

// $(function() {
//   $(".wrapper").fadeIn();
//   Data.ClearData();
//   $.post(
//     Config.ROOT_ADDRESS + "/log",
//     JSON.stringify({
//       text: "Initializing apps with test function"
//     })
//   );
//   $.post(
//     Config.ROOT_ADDRESS + "/log",
//     JSON.stringify({
//       text: JSON.stringify(Data)
//     })
//   );
//   Data.SetupData([
//     { name: "myData", data: Test.PlayerDetails },
//     { name: "settings", data: Test.Settings },
//     { name: "contacts", data: Test.Contacts },
//     { name: "messages", data: Test.Messages },
//     { name: "history", data: Test.Calls },
//     { name: "apps", data: Config.Apps },
//     { name: "tweets", data: Test.Tweets },
//     { name: "adverts", data: Test.Adverts },
//     { name: "factory-tunes", data: Test.FactoryTunes },
//     { name: "custom-tunes", data: Test.Tunes },
//     { name: "bank-accounts", data: Test.Accounts },
//     { name: "irc-messages", data: Test.IRCMessages }
//   ]);

//   OpenApp("home", null, true);
//   $(".sdcard").addClass("advanced");
//   $(".sdcard").fadeIn("fast");
// });

window.addEventListener("message", event => {
  switch (event.data.action) {
    case "show":
      $.post(
        Config.ROOT_ADDRESS + "/log",
        JSON.stringify({
          text: "Nui show phone"
        })
      );
      $(".wrapper").show("slide", { direction: "down" }, 500);

      if (!Apps.Phone.Call.IsCallPending()) {
        OpenApp("home", null, true);
      } else {
        appTrail = [
          {
            app: "home",
            data: null,
            fade: false
          }
        ];
        OpenApp(
          "phone-call",
          {
            number: event.data.number,
            receiver: !event.data.initiator
          },
          false
        );
      }
      break;
    case "hide":
      $.post(
        Config.ROOT_ADDRESS + "/log",
        JSON.stringify({
          text: "Nui hide phone"
        })
      );
      console.log("hide case from switch");
      ClosePhone();
      break;
    case "SetServerID":
      $(".player-id span").html(event.data.id);
      break;
  }
});

function InitShit() {
  $(".modal").modal();
  $(".dropdown-trigger").dropdown({
    constrainWidth: false
  });
  $(".tabs").tabs();
  //$('select').formSelect();
  $(".char-count-input").characterCounter();
  $(".phone-number").mask("000-0000", { placeholder: "###-####" });
}

$(function () {
  let settings = Data.GetData("settings");

  Utils.UpdateWallpaper(`url(./imgs/back00${settings.wallpaper}.png)`);
  Utils.SetMute(settings.volume === 0);

  //   document.onkeyup = function(data) {
  //     if (data.which == 114 || data.which == 27) {
  //       console.log("we pressed one of the keys");
  //       ClosePhone();
  //     }
  //   };
});

$(".phone-header").on("click", ".in-call", e => {
  if (appTrail[appTrail.length - 1].app != "phone-call") {
    OpenApp("phone-call", null, false);
  }
});

$(".phone").on("click", ".back-button", event => {
  if (!$(event.currentTarget).hasClass("disabled")) {
    $(".footer-button").addClass("disabled");
    GoBack();
  }
});

$(".phone").on("click", ".home-button", event => {
  if (!$(event.currentTarget).hasClass("disabled")) {
    $(".footer-button").addClass("disabled");
    GoHome();
  }
});

$(".phone").on("click", ".close-button", e => {
  console.log("we clicked close");
  ClosePhone();
});

$("#remove-sim-card").on("click", e => {
  let modal = M.Modal.getInstance($("#remove-sim-conf"));
  modal.close();
  Utils.NotifyAltSim(false);
  Notif.Alert("Sim Removed");
});

$(".mute").on("click", e => {
  let volume = Data.GetData("settings").volume;

  $.post(
    Config.ROOT_ADDRESS + "/ToggleMute",
    JSON.stringify({
      muted: volume === 0 ? false : true
    }),
    status => {
      if (status) {
        Data.UpdateData("settings", "volume", volume === 0 ? 100 : 0);
        Utils.SetMute(volume !== 0);
      }
    }
  );
});

function ClosePhone() {
  $.post(Config.ROOT_ADDRESS + "/ClosePhone", JSON.stringify({}));
  $(".wrapper").hide("slide", { direction: "down" }, 500, () => {
    $("#screen-content").trigger(
      `${appTrail[appTrail.length - 1].app}-close-app`
    );
    $("#toast-container").remove();
    $(".material-tooltip").remove();
    $(".app-container").hide();
    appTrail = [
      {
        app: null,
        data: null,
        fade: null
      }
    ];
  });
}

function SetupApp(app, data, pop, disableFade, exit) {
  $.post(
    Config.ROOT_ADDRESS + "/log",
    JSON.stringify({
      text: "Setting Up App"
    })
  );
  $.ajax({
    url: `./html/apps/${app}.html`,
    cache: false,
    dataType: "html",
    statusCode: {
      404: function () {
        console.log("ajax Post fail");
        appTrail.push({ app: app, data: null, fade: false, close: exit });
        Notif.Alert("App Doesn't Exist", 1000);
        GoHome();
        $(".footer-button").removeClass("disabled");
      }
    },

    success: function (response) {
      console.log("ajax Post success");
      console.log("response");
      console.log(JSON.stringify(response));
      $("#screen-content").html(response);
      InitShit();

      window.dispatchEvent(
        new CustomEvent(`${appTrail[appTrail.length - 1].app}-close-app`)
      );
      console.log("Inside App.js SetupApp");
      console.log(JSON.stringify(app));
      console.log(JSON.stringify(data));
      console.log(pop);
      console.log(disableFade);
      console.log(exit);
      if (pop) {
        appTrail.pop();
        disableFade = null;
        appTrail.pop();
      }

      appTrail.push({
        app: app,
        data: data,
        fade: disableFade,
        close: exit
      });

      $(".material-tooltip").remove();
      window.dispatchEvent(
        new CustomEvent(`remove-closed-notif`, { detail: { app: app } })
      );
      console.log(`just about to send to the ${app}-open-app`);
      console.log(JSON.stringify(data));

      window.dispatchEvent(
        new CustomEvent(`${app}-open-app`, { detail: data })
      );

      $("#screen-content").show();
      $(".footer-button").removeClass("disabled");
    }
  });
}

window.addEventListener("custom-close-finish", data => {
  if (data.detail.disableFade) {
    SetupApp(
      data.detail.app,
      data.detail.data,
      data.detail.pop,
      data.detail.disableFade,
      data.detail.customExit
    );
  } else {
    $("#screen-content").fadeOut("fast", () => {
      SetupApp(
        data.detail.app,
        data.detail.data,
        data.detail.pop,
        data.detail.disableFade,
        data.detail.customExit
      );
    });
  }
});

function OpenApp(
  app,
  data = null,
  pop = false,
  disableFade = false,
  customExit = false
) {
  console.log("Inside App.js OpenApp");
  console.log(JSON.stringify(app));
  console.log(JSON.stringify(data));
  console.log(pop);
  console.log(disableFade);
  console.log(customExit);
  if ($("#screen-content .app-container").length <= 0 || disableFade) {
    console.log(`Inside 1`);
    if (appTrail[appTrail.length - 1].close) {
      console.log(`Inside 2`);
      window.dispatchEvent(
        new CustomEvent(
          `${appTrail[appTrail.length - 1].app}-custom-close-app`,
          {
            detail: {
              app: app,
              data: data,
              pop: pop,
              disableFade: disableFade,
              customExit: customExit
            }
          }
        )
      );
    } else {
      console.log(`Inside 3`);
      console.log(JSON.stringify(app));
      console.log(JSON.stringify(data));
      console.log(pop);
      console.log(disableFade);
      console.log(customExit);
      SetupApp(app, data, pop, disableFade, customExit);
    }
  } else {
    console.log(`Inside 4`);
    if (appTrail[appTrail.length - 1].close) {
      console.log(`Inside 5`);
      window.dispatchEvent(
        new CustomEvent(
          `${appTrail[appTrail.length - 1].app}-custom-close-app`,
          {
            detail: {
              app: app,
              data: data,
              pop: pop,
              disableFade: disableFade,
              customExit: customExit
            }
          }
        )
      );
    } else {
      console.log(`Inside 6`);
      $("#screen-content").fadeOut("fast", () => {
        SetupApp(app, data, pop, disableFade, customExit);
      });
    }
  }
  console.log(`End`);
}

function RefreshApp() {
  // This is here to update the text-messages list when you receive a text.
  if (`${appTrail[appTrail.length - 1].app}-open-app` === "message-open-app") {
    window.dispatchEvent(
      new CustomEvent(`${appTrail[appTrail.length - 1].app}-open-app`, { detail: [appTrail[appTrail.length - 1].data] })
    );
  }

  $(".material-tooltip").remove();
  $("#screen-content").trigger(
    `${appTrail[appTrail.length - 1].app}-open-app`,
    [appTrail[appTrail.length - 1].data]
  );
}

function GoHome() {
  if (appTrail[appTrail.length - 1].app !== "home") {
    OpenApp("home");
  }
}

function GoBack() {
  if (appTrail[appTrail.length - 1].app !== "home") {
    if (appTrail.length > 1) {
      OpenApp(
        appTrail[appTrail.length - 2].app,
        appTrail[appTrail.length - 2].data,
        true,
        appTrail[appTrail.length - 1].fade,
        appTrail[appTrail.length - 2].close
      );
    } else {
      GoHome();
    }
  }
}

function GetCurrentApp() {
  return appTrail[appTrail.length - 1].app;
}

export default { GoHome, GoBack, OpenApp, RefreshApp, GetCurrentApp };
