// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
import { Socket } from "phoenix";
//     import socket from "./socket"
//
import "phoenix_html";

// Elm

import { Elm } from "../elm/src/Main.elm";

let socketParams = window.userToken == "" ? {} : { token: window.userToken };
let socket = new Socket("/socket", {
  params: socketParams,
});

socket.connect();

const elmContainer = document.querySelector("#elm-container");

function getItem(name, empty) {
  let existing = localStorage.getItem(name);
  let value = existing ? existing : JSON.stringify(empty);
  return JSON.parse(value);
}

function updateLocalStorage(msg) {
  let messages = getItem("messages", []);
  let user = messages.find((item) => item.friend == msg.receiver);
  if (user) {
    user["msgs"].push(msg.sender + ": " + msg.msg);
  } else {
    messages.push({
      friend: msg.receiver,
      msgs: [msg.sender + ": " + msg.msg],
    });
  }
  localStorage.setItem("messages", JSON.stringify(messages));
}

if (elmContainer) {
  let name = window.location.pathname.replace(/^\//, "");
  let app = Elm.Main.init({
    node: elmContainer,
    flags: {
      name: name,
      users: all_users,
      users_with_msgs: getItem("messages", []),
    },
  });

  let general = socket.channel("room:general");
  general
    .join()
    .receive("ok", (resp) => {
      console.log("Joined successfully", resp);
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });
  general.on("online_users", (payload) => {
    console.log(
      `Receiving  name ${payload.name} from Phoenix using the comeOnline port.`
    );
    app.ports.newOnlineUser.send({
      name: `${payload.name}`,
    });
  });

  let channel = socket.channel(`room:${socketParams.token}`, { name: name });

  channel
    .join()
    .receive("ok", (resp) => {
      console.log("Joined successfully", resp);
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });

  app.ports.comeOnline.subscribe(function (name) {
    console.log(`Broadcasting name ${name} using comeOnline port.`);
    channel.push("come_online", { name: name });
  });

  app.ports.sendMessage.subscribe(function (msg) {
    console.log(
      `Send msg data '${JSON.stringify(
        msg
      )}' score data from Elm using the sendMessage port.`
    );
    updateLocalStorage(msg);
    channel.push("send_message", { message: msg });
  });

  channel.on("send_message", (payload) => {
    console.log(
      `Receiving ${payload.sender} score data  and name ${payload.msg} from Phoenix using the ReceiveMsg port.`
    );
    payload.receiver = payload.sender;
    updateLocalStorage(payload);
    app.ports.messageReceiver.send(payload);
  });
}
