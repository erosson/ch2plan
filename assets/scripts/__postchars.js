/**
 * Compile all data for one version of Clicker Heroes 2.
 *
 * Input:
 * - /assets/stats.json: links passive tree nodes to stats for stat-calculations.
 *   Maintained by hand, based on diffs of CH2's exported actionscript:
 *   run `yarn as3` to export this actionscript into `./ch2data`, then `git diff`.
 *   FFDec is required to export: https://github.com/jindrapetrik/jpexs-decompiler
 *
 * - /assets/latest.json: nodes, edges, characters, basically everything else.
 *   Maintained automatically, based on the output of our CH2 exporter mod:
 *   install the mod "/exporter/bin/ch2plan-exporter.swf" into your CH2,
 *   run the game, then check your desktop for a `latest.json` file.
 *   Install the mod: https://www.clickerheroes2.com/installing_mods.php
 *   Develop the mod: https://www.clickerheroes2.com/creating_mods.php
 */
const fs = require("fs").promises;
const sortJson = require("sort-json");

async function readStats(path) {
  try {
    const body = await fs.readFile(path);
    console.log(path, "found stats snapshot, IGNORING ./stats.json");
    return body;
  } catch (e) {
    console.log(path, "no stats snapshot yet, using ./stats.json");
    return await fs.readFile("./stats.json");
  }
}
async function main() {
  try {
    await fs.mkdir("./public/ch2data/chars/v/full");
  } catch (e) {
    // the dir already exists, that's fine
  }

  const json = sortJson(
    JSON.parse(await fs.readFile("public/ch2data/chars/latest.json"))
  );

  const rawSortedJson = Object.assign({}, json);
  json.versionSlug = json.ch2.GAME_VERSION.replace(/\s/g, "-");
  const statsSnapshotPath =
    "./public/ch2data/chars/v/full/" + json.versionSlug + ".stats.json";
  const statsText = await readStats(statsSnapshotPath);
  const statsJson = JSON.parse(statsText);
  // no need to snapshot my comments
  for (let key of Object.keys(statsJson)) {
    if (key.startsWith("//")) {
      delete statsJson[key];
    }
  }
  for (let key of Object.keys(statsJson.rules || {})) {
    if (key.startsWith("//")) {
      delete statsJson.rules[key];
    }
  }
  json.stats = statsJson;

  const allPath = "./public/ch2data/chars/all.min.json";
  const allJson = JSON.parse(await fs.readFile(allPath));
  if (!allJson.byVersion[json.versionSlug]) {
    allJson.versionList.push(json.versionSlug);
  }
  allJson.byVersion[json.versionSlug] = json;
  await Promise.all([
    fs.writeFile(
      "./public/ch2data/chars/latest.json",
      JSON.stringify(rawSortedJson, null, 2)
    ),
    fs.writeFile(statsSnapshotPath, statsText),
    fs.writeFile(
      "./public/ch2data/chars/latest.min.json",
      JSON.stringify(json)
    ),
    fs.writeFile(
      "./public/ch2data/chars/v/full/" + json.versionSlug + ".json",
      JSON.stringify(json, null, 2)
    ),
    fs.writeFile(
      "./public/ch2data/chars/v/" + json.versionSlug + ".min.json",
      JSON.stringify(json)
    ),
    fs.writeFile(allPath, JSON.stringify(allJson)),
  ]);
  console.log("postexport:chars", json.versionSlug);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
