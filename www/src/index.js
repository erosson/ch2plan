import "./main.css";
import { Zlib } from "zlibjs/bin/rawinflate.min.js";
import AMF from "amf-js";
import { Elm } from "./Main.elm";
import gameData from "../../assets/public/ch2data/chars/all.min.json";
// I want to import raw text. fs.readFileSync() runs at build time,
// which is confusing/surprising, but works:
// https://github.com/parcel-bundler/parcel/issues/970
import fs from "fs";
const changelog = fs.readFileSync(__dirname + "/../../CHANGELOG.md").toString();

// google analytics
window.dataLayer = window.dataLayer || [];
function gtag() {
  dataLayer.push(arguments);
}
gtag("js", new Date());
gtag("config", "UA-122483662-1");

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
