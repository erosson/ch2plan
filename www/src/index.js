import "./main.css";
import { Zlib } from "zlibjs/bin/rawinflate.min.js";
import AMF from "amf-js";
import { Elm } from "../src/Main.elm";
import gameData from "../../assets/public/ch2data/chars/all.min.json";
import changelog from "!!raw-loader!../../CHANGELOG.md";
import ClipboardJS from "clipboard";

// google analytics
window.dataLayer = window.dataLayer || [];
function gtag() {
  dataLayer.push(arguments);
}
gtag("js", new Date());
gtag("config", "UA-122483662-1");

const clipTarget = new ClipboardJS(".clipboard-button-target");
const clipText = new ClipboardJS(".clipboard-button-text", {
  text: (trigger) => trigger.getAttribute("data-clipboard-text"),
});

console.log("init", { Elm, gameData, changelog, env: process.env, Zlib, AMF });
const flags = {
  changelog,
  gameData,
  windowSize: {
    width: document.documentElement.clientWidth,
    height: document.documentElement.clientHeight,
  },
};
const app = Elm.Main.init({ flags });

app.ports.saveFileSelected.subscribe((elemId) => {
  var reader = new FileReader();
  reader.onload = () => {
    try {
      var file = reader.result;
      var inflate = new Zlib.RawInflate(file);
      var plain = inflate.decompress();
      var json = AMF.deserialize(plain.buffer);
      console.log("savefile", json);

      app.ports.saveFileContentRead.send({
        status: "success",
        hero: json.name,
        build: Object.keys(json.nodesPurchased),
        equippedEtherealItems: json.equippedEtherealItems,
        etherealItemInventory: json.etherealItemInventory,
        etherealItemStorage: json.etherealItemStorage,
      });
    } catch (error) {
      console.error("Error while reading savefile", error);
      app.ports.saveFileContentRead.send({
        status: "error",
        error: error.message,
      });
    }
  };
  reader.readAsArrayBuffer(document.getElementById(elemId).files[0]);
});
