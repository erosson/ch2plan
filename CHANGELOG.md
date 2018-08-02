# Clicker Heroes 2 Skill Tree Planner: updates

All substantial Skill Tree Planner changes are listed here.

**Found a bug?** Please [file an issue](https://github.com/erosson/ch2plan/issues) or [message me on Reddit](https://www.reddit.com/user/kawaritai).

The source code: https://github.com/erosson/ch2plan

The developer: https://github.com/erosson . Also on [Reddit](https://www.reddit.com/user/kawaritai).

Shameless self-promotion: if you like Clicker Heroes, you should try my game, [Swarm Simulator](https://www.swarmsim.com).
Now also on [Android](https://play.google.com/store/apps/details?id=com.ironhorse.swarmsimulator) and [iOS](https://itunes.apple.com/us/app/swarm-simulator-evolution/id1320056680)!

## [Unreleased]

### Beta/experimental features

These are at least partially working, but turned _off_ by default.

- [Full-screen skill tree](https://ch2.erosson.org/?enableFullscreen=1).
- [Prettier-looking, faster-activating skill info tooltips/mouseover text](https://ch2.erosson.org/?enableFancyTooltips=1).
- [Importing your build from a saved game](https://ch2.erosson.org/?enableSaveImport=1).

### New features

These recently left beta, and are turned _on_ by default. For now, you can disable them if they're causing trouble.

- None, for now.

---

## 2018-08-01

- Broken searches now display an error, instead of crashing the website.
- A search can now highlight results in up to 7 different colors. An example with 4 colors: [`(big)|(huge)|(multiclick)|(energize)`](https://ch2.erosson.org/#/g/0.06-beta/helpfulAdventurer?q=%28big%29%7C%28huge%29%7C%28multiclick%29%7C%28energize%29)
- The stats screen now has icons for each skill.

## 2018-07-31

- New beta feature: import your build from a saved game. Thanks, [@Judgy53](https://github.com/Judgy53)!
- Game update: 0.06-beta

## 2018-07-30

- Selecting/deselecting nodes feels faster now: triggers when the mouse is pressed, instead of when it's released.
- The new beta tooltips now work on touch screens, using a long press.
- The stats table more closely matches what's in-game.
- Created a new page for build statistics. Moved the node summary there.
- Implemented some skill-specific stat calculations: damage, cost, cooldown, duration, stack count, effect.

## 2018-07-28

- Edges between two selected nodes are now much more visible.
- Zooming/panning are now much less laggy.
- Search no longer tries to highlight things while you're typing; it's less laggy this way.
- Add support for multiple game versions, and for the new 0.06 PTR release.

## 2018-07-27

- ~~Added `?hueSelected=` and `?hueSearch=` parameters, intended to make life a little easier for the colorblind.~~
- Search should be much less laggy, and no longer skips letters.

## 2018-07-25

- Smoother zooming in more browsers. Thanks, [@Judgy53](https://github.com/Judgy53)!
- Added some basic character stat calculations. More to come soon.

## 2018-07-23

- Smoother panning.
- Added zoom buttons for those without mouse-wheels.
- The browser's back button now undoes your last point selection.
- New feature's out of beta: zoom/pan. Thanks, [@Judgy53](https://github.com/Judgy53)!
- New feature's out of beta: select/unselect multiple nodes with one click.

## 2018-07-21

- Improvements to zooming/panning - [thanks, @Judgy53](https://github.com/erosson/ch2plan/pull/18)!
- Performance tweaking - selecting/unselecting nodes should be a bit faster.
- Nicer background images for small nodes, next (purple) nodes, and search results nodes.
- Improved visibility for some nodes - small nodes now have a green border when selected; search results now have a bright red border.
- You can now link to a search. For example, `?q=haste`

## 2018-07-20

- New beta feature: zoom/pan. Thanks, [@Judgy53](https://github.com/Judgy53)!
- New beta feature: select/unselect multiple nodes with one click.
- Redesigned how data's extracted from the Clicker Heroes 2 game files. Tooltips should be more complete, and future updates to game data are more automatic.
- Added support for multiple character classes. Added a link to the (currently empty) wizard.
- Icons now have transparency, and icon backgrounds now use the fancy in-game galaxy(?) images. Search results should be much more visible.
- Started this changelog. (Shame on me for not having one from the start; things were a bit rushed.)

## 2018-07-17

- Initial release and [announcement](https://redd.it/8zjsfk).
