package
{
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.display.Sprite;
	import heroclickerlib.CH2;
	import IdleHeroConsole;
	import heroclickerlib.managers.Trace;
	import models.Character;
	import models.Characters;

	public class CH2PlanExporter extends Sprite 
	{
		public var MOD_INFO:Object =    
		{    
		    "name": "ch2plan-exporter",
		    "description": "extract ch2 game data used in https://ch2.erosson.org",
		    "version": 1,
		    "author": "erosson"
		};

		private var game: IdleHeroMain = null;
		private var json: Object = {heroes: {}, skills: {}};
		private var slugs: Object = {
			"Helpful Adventurer": "helpfulAdventurer",
			"Wizard": "wizard"
		};
		public function onStartup(game:IdleHeroMain):void {
			this.game = game;
		}
		public function onStaticDataLoaded(staticData: Object):void {
			try {
				this._onStartup(this.game);
			}
			catch (e: Error) {
				this.writeFile(File.desktopDirectory.resolvePath("error.txt"), e.getStackTrace());
			}
		}
		private function _onStartup(game:IdleHeroMain):void {
			json.ch2 = pick(IdleHeroMain, ['GAME_VERSION']);
			for (var ckey:String in Characters.startingDefaultInstances) {
				var char:* = Characters.startingDefaultInstances[ckey];
				var slug:String = slugs[ckey];
				json.heroes[slug] = pick(char, ['name', 'flavorName', 'flavorClass', 'flavor']);
				json.heroes[slug].levelGraphObject = char.levelGraphObject || {nodes:[], edges:[]};
				json.heroes[slug].levelGraphNodeTypes = {};
				for (var nodekey:String in char.levelGraphNodeTypes || {}) {
					var node:Object = char.levelGraphNodeTypes[nodekey] || {};
					json.heroes[slug].levelGraphNodeTypes[nodekey] = {};
					for (var fieldkey:String in node) {
						json.heroes[slug].levelGraphNodeTypes[nodekey][fieldkey] = node[fieldkey];
					}
					if (node['tooltipFunction']) {
						try {
							var cc:* = CH2.currentCharacter;
							CH2.currentCharacter = char;
							json.heroes[slug].levelGraphNodeTypes[nodekey]['__ch2plan_tooltip'] = node['tooltipFunction'](1);
							CH2.currentCharacter = cc;
						}
						catch (e:Error) {
							//json.heroes[slug].levelGraphNodeTypes[nodekey]['__ch2plan_tooltip_error'] = e.getStackTrace();
							throw e;
						}
					}
				}
			}
			for (var skey:String in Character.staticSkillInstances) {
				var skill:Object = Character.staticSkillInstances[skey];
				this.json.skills[skey] = pick(skill, ['modName', 'uid', 'name', 'description', 'cooldown', 'manaCost', 'energyCost', 'ignoresGCD', 'iconId']);
				this.json.skills[skey].char = slugs[skill.modName];
			}
			
			var config: Object = {};
			var file:File = File.applicationDirectory.resolvePath("mods\\active\\ch2plan-exporter.json")
			try {
				config = JSON.parse(this.readFile(file));
			}
			catch (e: Error) {
				config._error = e;
				config._nativePath = file.nativePath;
				//this.writeFile(File.desktopDirectory.resolvePath("config.json"), JSON.stringify(config, null, 2));
			}
			var outDir:File = config["dest"] ? new File(config["dest"]) : File.desktopDirectory;
			this.writeFile(outDir.resolvePath("latest.json"), JSON.stringify(json, null, 2));
		}
		private function writeFile(file: File, content: String):void {
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(content);
			stream.close();
		}
		private function readFile(file: File): String {
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var content:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			return content;
		}
		public function onUserDataLoaded():void {}
		public function onCharacterCreated(characterInstance:Character):void {}
		
		private function pick(obj: Object, keys: Array): Object {
			var ret:Object = {}
			for (var i:int=0; i < keys.length; i++) {
				ret[keys[i]] = obj[keys[i]]
			}
			return ret
		}
	}
}