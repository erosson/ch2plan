# Contributing to the CH2 tree planner

Want to add something/fix something in the skill tree planner? I take pull requests. Thanks for your interest!

## Getting started/Running the website locally

- Install Ubuntu Linux, probably: https://www.ubuntu.com/
  - I haven't tested anything on Windows or other flavors of Linux, but feel free to try! A VM should work fine too.
- Install NodeJS: https://nodejs.org/en/download/
- Install Yarn: https://yarnpkg.com/lang/en/docs/install/#debian-stable
- Configure your editor for Elm: https://guide.elm-lang.org/install.html . Most of our code is written in Elm.
  - No need to _install_ Elm - that happens automatically in the next step, running `yarn`.
  - Elm code that hasn't been run through `elm-format` will fail automated tests!
- Configure your editor to run [prettier](https://prettier.io) on save: https://prettier.io/docs/en/editors.html
  - JS and JSON that hasn't been run through `prettier` will fail automated tests!
- Get the planner's code on to your machine, if you haven't already: `git clone git@github.com:erosson/ch2plan.git` ; `cd ch2plan`
- Install Elm and other dependencies: `yarn`
- Finally, run the planner in development mode: `yarn dev`

## Development commands

- `yarn dev` runs things in development mode. You'll need to restart it when changing `index.html` or `CHANGELOG.md`, but everything else should auto-reload when changed. I spend most of my time here.
- `yarn start` creates a production build, and runs it with no development features. Useful to see exactly how the app will behave when deployed.
- `yarn test` or `yarn test --watch` to run automated tests.
- If your editor doesn't support the autoformatting configuration we did in the above section, run `yarn format` before sending a pull request.

## Choosing what to work on

Before you start working, please file an issue, or otherwise talk to me (@erosson). I like accepting pull requests, and I'd hate to turn away your hard work if there's a better approach to the problem you're solving!

## Releasing

All code pushed to the master branch is released immediately, automatically, after [Travis](https://travis-ci.org/erosson/ch2plan) runs the tests and build. There is no development or preprod environment, other than your local machine. Instead, you should use feature-flags (`?enableXYZ=1`) for new things you're even a little uncertain about - take a look at Route.elm for examples.

## Updating the planner for a new CH2 version

Here's the procedure. An Ubuntu Linux machine and ffdec are required. (TODO add urls)

- Extract the updated Clicker Heroes 2 game to `./game`. A symlink works too - I dual-boot, and symlink `./game` to CH2 on my Windows partition.
- Run `yarn export:as3`. It'll generate some changes in git.
- Run `git diff ./ch2data`. Manually examine the differences, and update `./assets/stats.json`
- Do one of the following: 
  - Use the new and experimental ch2plan-exporter mod.
    - Add ./exporter/bin/ch2plan-exporter.swf to your [Clicker Heroes 2 mods](https://www.clickerheroes2.com/installing_mods.php).
    - Open Clicker Heroes 2.
    - (TODO: automate this) Move `latest.json` from your desktop to (TODO: where it belongs).
    - (TODO: automate this) Run `yarn export:post-chars`
  - Run the old reliable `yarn export:chars`. It opens a text file and - much less visibly - starts a web server and adds the url to your clipboard.
    - Open a browser. New tab. Ctrl-v, enter. You'll see a page that says "open the javascript console".
    - Do so (ctrl-shift-j). Copy all the json. Paste it in to the text file.
    - Close the text file. Kill the web server (ctrl-c).
-   Add links to the new version in ViewSkillTree.elm, if necessary.
- You're done, hopefully! Run `yarn dev` to test things.
  - If you change stats.json after this point, run `yarn export:post-chars` to update it.
