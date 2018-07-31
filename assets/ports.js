// google analytics
window.dataLayer = window.dataLayer || [];
function gtag() {
  dataLayer.push(arguments);
}
gtag("js", new Date());
gtag("config", "UA-122483662-1");

// load everything before elm inits, to avoid the trouble of loading states/ports
Promise.all([
  fetch("./ch2data/chars/all.min.json").then(function(res) {
    return res.json();
  }),
  fetch("./CHANGELOG.md").then(function(res) {
    return res.text();
  })
])
  .then(function([game, changelog]) {
    // console.log(chars)
    var app = Elm.Main.fullscreen({
      changelog: changelog,
      lastUpdatedVersion: game.versionList[game.versionList.length - 1],
      gameData: game,
      windowSize: {
        width: document.documentElement.clientWidth,
        height: document.documentElement.clientHeight
      }
    });
    app.ports.saveFileSelected.subscribe(function(elemId) {
      var reader = new FileReader();
      reader.onload = function() {
        try {
          var file = reader.result;
          var inflate = new Zlib.RawInflate(file);
          var plain = inflate.decompress();
          var json = AMF.deserialize(plain.buffer);

          app.ports.saveFileContentRead.send({
            hero: json.name,
            build: Object.keys(json.nodesPurchased)
          });
        } catch (error) {
          console.error("Error while reading savefile : " + error);
        }
      };
      reader.readAsArrayBuffer(document.getElementById(elemId).files[0]);
    });
  })
  .catch(console.error);
