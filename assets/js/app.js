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

let sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms * 1000));

let socketParams = window.userToken == "" ? {} : { token: window.userToken };
let socket = new Socket("/socket", {
  params: socketParams,
});

socket.connect();

const elmContainer = document.querySelector("#elm-container");

if (elmContainer) {
  let name = window.location.pathname.replace(/^\//, "");
  let app = Elm.Main.init({ node: elmContainer, flags: name });

  let channel = socket.channel("room:chat", { name: name });

  channel
    .join()
    .receive("ok", (resp) => {
      console.log("Joined successfully", resp);
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });

  app.ports.sendMessage.subscribe(function (msg) {
    console.log(
      `Broadcasting ${msg} score data from Elm using the sendMessage port.`
    );
    channel.push("broadcast_custom", { msg: msg });
    // Later, we'll push the score data to the Phoenix channel
  });

  channel.on("broadcast_custom", (payload) => {
    console.log(
      `Receiving ${payload.name} score data  and name ${payload.name} from Phoenix using the ReceiveMsg port.`
    );
    app.ports.messageReceiver.send({
      msg: `${payload.name}: ${payload.msg}`,
    });
  });
}