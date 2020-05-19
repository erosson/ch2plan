const { promisify } = require("util");
const fs = require("fs");
const sortJson = require("sort-json");

async function readStats(path) {
  try {
    const body = await promisify(fs.readFile)(path);
    console.log(path, "found stats snapshot, IGNORING ./assets/stats.json");
    return body;
  } catch (e) {
    console.log(path, "no stats snapshot yet, using ./assets/stats.json");
    return await promisify(fs.readFile)("./assets/stats.json");
  }
}
async function main(path) {
  try {
    await promisify(fs.mkdir)("./assets/ch2data/chars/v/full");
  } catch (e) {
    // the dir already exists, that's fine
  }

  const json = sortJson(JSON.parse(await promisify(fs.readFile)(path)));
  const rawSortedJson = Object.assign({}, json);
  json.versionSlug = json.ch2.GAME_VERSION.replace(/\s/g, "-");
  const statsSnapshotPath =
    "./assets/ch2data/chars/v/full/" + json.versionSlug + ".stats.json";
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

  const allPath = "./assets/ch2data/chars/all.min.json";
  const allJson = JSON.parse(await promisify(fs.readFile)(allPath));
  if (!allJson.byVersion[json.versionSlug]) {
    allJson.versionList.push(json.versionSlug);
  }
  allJson.byVersion[json.versionSlug] = json;
  await Promise.all([
    promisify(fs.writeFile)(path, JSON.stringify(rawSortedJson, null, 2)),
    promisify(fs.writeFile)(statsSnapshotPath, statsText),
    promisify(fs.writeFile)(
      "./assets/ch2data/chars/latest.min.json",
      JSON.stringify(json)
    ),
    promisify(fs.writeFile)(
      "./assets/ch2data/chars/v/full/" + json.versionSlug + ".json",
      JSON.stringify(json, null, 2)
    ),
    promisify(fs.writeFile)(
      "./assets/ch2data/chars/v/" + json.versionSlug + ".min.json",
      JSON.stringify(json)
    ),
    promisify(fs.writeFile)(allPath, JSON.stringify(allJson))
  ]);
  console.log("postexport:chars", path, json.versionSlug);
}
main(process.argv[process.argv.length - 1]).catch(err => {
  console.error(err);
  process.exit(1);
});
