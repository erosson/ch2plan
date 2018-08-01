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
            build: Object.keys(json.nodesPurchased),
            error: null
          });
        } catch (error) {
          console.error("Error while reading savefile : " + error);
          app.ports.saveFileContentRead.send({
            hero: "",
            build: [],
            error: "Save game could not be loaded."
          });
        }
      };
      reader.readAsArrayBuffer(document.getElementById(elemId).files[0]);
    });
    var q = null;
    window.addEventListener("hashchange", function() {
      q = parseSearchRegex(app, q);
    });
    // elm search url updates don't fire browser's hashchange event for some reason
    app.ports.searchUpdated.subscribe(function() {
      q = parseSearchRegex(app, q);
    });
    q = parseSearchRegex(app, q);
  })
  .catch(console.error);

/**
 * parse search regexes in Javascript, since that's one of the few things that seriously breaks elm.
 * https://github.com/erosson/ch2plan/issues/44
 */
function parseSearchRegex(app, q0) {
  console.log("PARSESEARCHREGEX");
  var q = parseQS(window.location.hash).q || null;
  var error = null;
  if (q !== q0) {
    try {
      var qr = new RegExp(q);
    } catch (e) {
      error = e.message;
    }
  }
  app.ports.searchRegex.send({ string: q, error: error });
  return q;
}
function parseQS(hash) {
  var qs = {};
  (hash.split("?")[1] || "").split("&").forEach(function(opt) {
    var pair = opt.split("=");
    qs[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1]);
  });
  return qs;
}
