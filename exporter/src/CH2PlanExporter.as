package
{
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.display.Sprite;
	import heroclickerlib.CH2;
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
		
		private var json: Object = {heroes: {}, skills: {}};
		private var slugs: Object = {
			"Helpful Adventurer": "helpfulAdventurer",
			"Wizard": "wizard"
		};
		public function onStartup(game:IdleHeroMain):void {
			json.ch2 = pick(IdleHeroMain, ['GAME_VERSION']);
			for (var ckey:String in Characters.startingDefaultInstances) {
				var char:Object = Characters.startingDefaultInstances[ckey];
				var slug:String = slugs[ckey];
				json.heroes[slug] = pick(char, ['name', 'flavorName', 'flavorClass', 'flavor', 'levelGraphNodeTypes', 'levelGraphObject']);
			}
			for (var skey:String in Character.staticSkillInstances) {
				var skill:Object = Character.staticSkillInstances[skey];
				this.json.skills[skey] = pick(skill, ['modName', 'uid', 'name', 'description', 'cooldown', 'manaCost', 'energyCost', 'ignoresGCD', 'iconId']);
				this.json.skills[skey].char = slugs[skill.modName];
			}
			
			var file:File = File.desktopDirectory.resolvePath("latest.json");
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(JSON.stringify(json, null, 2));
			stream.close();
		}
		public function onStaticDataLoaded(staticData:Object):void {}
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