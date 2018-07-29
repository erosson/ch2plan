# A new CH2 version!

Here's the procedure. An Ubuntu Linux machine and ffdec are required. (TODO add urls)

* Run `yarn extract:as3`. It'll generate some changes in git.
* Run `git diff ./ch2data`. Manually examine the differences, and update `./assets/stats.json`
* Run `yarn extract:chars`. It opens a text file and - much less visibly - starts a web server and adds the url to your clipboard.
  * Open a browser. New tab. Ctrl-v, enter. You'll see a page that says "open the javascript console".
  * Do so (ctrl-shift-j). Copy all the json. Paste it in to the text file.
  * Close the text file. Kill the web server (ctrl-c).
* Add links to the new version in ViewSkillTree.elm, if necessary.
* You're done, hopefully! Run `yarn dev` to test things.
  * If you change stats.json after this point, run `yarn extract:post-chars` to update it.
