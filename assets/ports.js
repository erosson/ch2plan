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
  // console.log(chars)
  var ch2 = chars.ch2
  delete chars.ch2
  var app = Elm.Main.fullscreen({
    changelog: changelog,
    lastUpdatedVersion: ch2.GAME_VERSION,
    characterData: chars,
    windowSize: {width: document.documentElement.clientWidth, height: document.documentElement.clientHeight},
  })
})
.catch(console.error)
