// google analytics
window.dataLayer = window.dataLayer || []
function gtag(){dataLayer.push(arguments)}
gtag('js', new Date())
gtag('config', 'UA-122483662-1')

console.log(window.helpfulAdventurer)
var app = Elm.Main.fullscreen({
  // TODO support list of characterdata
  characterData: window.helpfulAdventurer,
})

fetch('./CHANGELOG.md')
.then(function(res) { return res.text() })
.then(function(text) { app.ports.changelogText.send(text) })
.catch(console.error)
