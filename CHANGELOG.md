# Clicker Heroes 2 Skill Tree Planner: updates

All substantial Skill Tree Planner changes are listed here.

**Found a bug?** Please [file an issue](https://github.com/erosson/ch2plan/issues) or [message me on Reddit](https://www.reddit.com/user/kawaritai).

The source code: https://github.com/erosson/ch2plan

The developer: https://github.com/erosson . Also on [Reddit](https://www.reddit.com/user/kawaritai).

Shameless self-promotion: if you like Clicker Heroes, you should try my game, [Swarm Simulator](https://www.swarmsim.com).
Now also on [Android](https://play.google.com/store/apps/details?id=com.ironhorse.swarmsimulator) and [iOS](https://itunes.apple.com/us/app/swarm-simulator-evolution/id1320056680)!

## [Unreleased]

### Beta/experimental features

These new features are at least partially working, but turned _off_ by default.

- Nothing, for now.

### New features

These recently left beta, and are turned _on_ by default. For now, you can disable them if they're causing trouble - that won't be possible forever, so if they're broken, please [contact the developer](https://www.reddit.com/user/kawaritai)!

- [Prettier-looking, faster-activating skill info tooltips/mouseover text](https://ch2.erosson.org/?enableFancyTooltips=0).
- [Import your build from a saved game](https://ch2.erosson.org/?enableSaveImport=0).
- [Full-screen skill tree](https://ch2.erosson.org/?enableFullscreen=0).

---

## 2020-08-07

- Updated to live version 0.15.0.
- Added an import/export field compatible with the new in-game tree planner.
- New builds now track and display the order of node purchases.
  - Old builds will still work, but their node order will be wrong.
- Fixed a bug breaking this changelog page.

## 2020-07-06

- Updated to live version 0.14.0.

## 2020-06-07

- Updated Wizard stats for 0.13.0.

## 2020-06-05

- Update to live version 0.13.0.

## 2020-05-24

- Wizard stats are now calculated.
- Fixed wizard spell cast times.

## 2020-05-20

- The Wizard's spells are now listed correctly.

## 2020-05-19

- Update to live version 0.12.0. (This one took some effort)

## 2019-07-10

- Update to live version 0.9.7.
- Added a new page to examine an imported save's ethereal items. Still under construction.

## 2018-12-24

- Update to live version 0.8.1-(early access), and PTR version 0.9.0-(experimental).
- [The wizard skill tree](https://ch2.erosson.org/#/g/0.09-%28e%29/wizard/) mostly works. Known issues, to be fixed soon: ~~the start node is wrong~~, node icons don't look quite right (transparency, stars), and the stats screen doesn't help with wizard stats.
  - The wizard skill tree now starts from the correct node.

## 2018-09-23

- [The build URL "all"](https://ch2.erosson.org/#/g/0.07-beta/helpfulAdventurer/all) now selects all possible nodes.
- PTR 0.08-beta-(e): you can now plan your automator tree and select automator nodes. Scroll far to the right.

## 2018-09-17

- Update to live version 0.07-beta, and PTR version 0.08-beta-(e).
  - Planning your PTR automator tree is not yet supported, but you can see the automator tree by scrolling far to the right.

## 2018-09-15

- [Lots of internal code changes](https://github.com/erosson/ch2plan/issues/60). None of these changes should be visible to you, or make the site behave any differently - let me know if anything broke today!

## 2018-08-19

- Update to 0.07-(8)-beta-PTR

## 2018-08-18

- Search now displays some help text when clicked.
- Zoom/pan/search-highlights are now preserved when entering and leaving the build statistics page.

## 2018-08-14

- You can now export your build to a spreadsheet (tab-separated). Look for the "spreadsheet format" link.
- PTR build urls now escape (parentheses) properly, and should no longer break Markdown-formatted text (like Reddit posts).

## 2018-08-10

- Tooltips should now be positioned correctly.

## 2018-08-07

- Added the 0.07 PTR patch to the planner. Biggest change is haste's effect on skill duration.
- Added _uptime_ - duration / cooldown - to skill calculations.
- New feature's out of beta: full-screen skill tree.

## 2018-08-06

- Small screens can zoom out farther.
- You can no longer scroll as far into empty space.
- Invalid builds now display an error, instead of silently ignoring the build.
- New feature's out of beta: prettier tooltips/mouseover text.
- New feature's out of beta: import your build from a saved game. Thanks, [@Judgy53](https://github.com/Judgy53)!

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
