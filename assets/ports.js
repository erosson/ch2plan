// google analytics
window.dataLayer = window.dataLayer || []
function gtag(){dataLayer.push(arguments)}
gtag('js', new Date())
gtag('config', 'UA-122483662-1')

// load everything before elm inits, to avoid the trouble of loading states/ports
Promise.all([
  fetch('./ch2data/chars.json').then(function(res) { return res.json() }),
  fetch('./CHANGELOG.md').then(function(res) { return res.text() }),
])
.then(function([chars, changelog]) {
  var app = Elm.Main.fullscreen({
    changelog: changelog,
    lastUpdatedVersion: chars.ch2.GAME_VERSION,
    characterData: chars.helpfulAdventurer,
  })
})
.catch(console.error)
