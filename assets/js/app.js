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

function createChannel(name, params = {}) {
  let channel = socket.channel(name, params);
  channel
    .join()
    .receive("ok", (resp) => {
      console.log("Joined successfully", resp);
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });
  return channel;
}

if (elmContainer) {
  const element = document.getElementById("allusers");
  const { users } = element.dataset;
  const all_users = JSON.parse(users);
  let app = Elm.Main.init({
    node: elmContainer,
    flags: {
      name: username,
      users: all_users,
    },
  });

  let general = createChannel("room:general");
  general.on("online_users", (payload) => {
    console.log(
      `Receiving  name ${payload.name} from Phoenix using the comeOnline port.`
    );
    app.ports.newOnlineUser.send({
      name: `${payload.name}`,
    });
  });

  let channel = createChannel(`room:${socketParams.token}`, { name: name });
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
    channel.push("send_message", { message: msg });
  });

  channel.on("send_message", (payload) => {
    console.log(
      `Receiving ${payload.sender} score data  and name ${payload.msg} from Phoenix using the ReceiveMsg port.`
    );
    payload.receiver = payload.sender;
    app.ports.messageReceiver.send(payload);
  });
}
