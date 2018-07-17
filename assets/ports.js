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
