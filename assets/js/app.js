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

console.log(`ale superrrr id ${window.userToken}`);
let socketParams = window.userToken == "" ? {} : { token: window.userToken };
let socket = new Socket("/socket", {
  params: socketParams,
});

socket.connect();

const elmContainer = document.querySelector("#elm-container");

if (elmContainer) {
  let name = window.location.pathname.replace(/^\//, "");
  let app = Elm.Main.init({
    node: elmContainer,
    flags: { name: name, users: all_users },
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
      `Send msg '${msg}' score data from Elm using the sendMessage port.`
    );
    channel.push("send_message", { message: msg });
  });

  channel.on("send_message", (payload) => {
    console.log(
      `Receiving ${payload.sender} score data  and name ${payload.msg} from Phoenix using the ReceiveMsg port.`
    );
    app.ports.messageReceiver.send(payload);
  });
}
