# Contributing to the CH2 tree planner

Want to add something/fix something in the skill tree planner? I take pull requests. Thanks for your interest!

## Updating

**The game was updated, and the planner is now outdated? You can help!**

### The `ch2plan-exporter` mod

**[`ch2plan-exporter.swf`](/exporter/bin/ch2plan-exporter.swf)**

- [Install the above `swf` mod using these directions from Playsaurus](https://www.clickerheroes2.com/installing_mods.php).
- Run Clicker Heroes 2. This mod won't affect your gameplay, but instead writes a file to your desktop, `latest.json`.
  - If something goes wrong, you'll see `error.txt` on your desktop instead.
  - If neither file is on your desktop after running the game, the mod isn't correctly installed!
- Replace [`/assets/latest.json`](/assets/latest.json) with your shiny new copy and add it to git.
- _Optional_: if you have the development tools ([nodejs](https://nodejs.org/en/download/) and [yarn](https://classic.yarnpkg.com/en/docs/install/)) installed, run the assets build and add the results to git: `cd assets && yarn build`
- Finally, send a pull request. Thanks for your help!

For most CH2 updates, this is all you need to do. No development tools required!

### Stat calculations: `stats.json`

CH2 got an update that changes how stats are calculated? These updates take more work, sadly. You'll need [nodejs](https://nodejs.org/en/download/) and [yarn](https://classic.yarnpkg.com/en/docs/install/) and [FFDec Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler/releases) installed.

- Update `latest.json`, above.
- Extract CH2's script files with FFDec: `cd assets && yarn as3`
  - The most interesting scripts are written to `assets/ch2data`.
  - TODO how to specify ch2 dir? currently hardcoded in `scripts-win/*`
- Run `git diff assets/ch2data`. Manually examine the differences, and update `assets/stats.json`.
- Run the assets build and add the results to git: `cd assets && yarn build`

## Developing

### Running the website locally

Windows and Linux are supported. You should have [nodejs](https://nodejs.org/en/download/) and [yarn](https://classic.yarnpkg.com/en/docs/install/) installed.

    git clone git@github.com:erosson/ch2plan.git
    cd ch2plan
    yarn
    yarn start

Website development commands:

- `yarn start` runs the website. I spend most of my time here.
- `yarn build` builds the production website in `/www/dist`.
- `yarn start:prod` builds and serves the production website locally.
- `yarn test` or `yarn test --watch` runs automated tests and checks lint/code style.
- `yarn format` to automatically fix code style. Set up your editor to run it on save!

### Editing the ch2plan-exporter mod

- Install [Flashdevelop](https://www.flashdevelop.org/), as recommended by [Playsaurus for mod development](https://www.clickerheroes2.com/creating_mods.php)
  - [I had to jump through a few extra hoops to get Flashdevelop working](https://www.flashdevelop.org/community/viewtopic.php?p=55977)
- Open the exporter's AS3 project: file > open > `exporter/`
  - Project > properties > build > post-build steps: set your ch2 path, so the mod is copied to your CH2 mod folder automatically on build

## Releasing

All code pushed to the master branch is released immediately, automatically, after [Travis](https://travis-ci.org/erosson/ch2plan) runs the tests and build. There is no development or preprod environment, other than your local machine. Instead, you should use feature-flags (`?enableXYZ=1`) for new things you're even a little uncertain about - take a look at Route.elm for examples.
