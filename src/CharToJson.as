// This code's a mess, sorry. I don't know AS3, but the game's written in it and we have to eval game files.
// flash/as3 in 2018, lol
package {
  import flash.external.ExternalInterface;
  import flash.display.Sprite;
  import flash.display.MovieClip;
  import flash.events.Event;
  import flash.net.URLRequest;
  import flash.text.TextField;
  import flash.display.Loader;

  public class CharToJson extends Sprite {
    private var pending: int = 0
    private var json: Object = {heroes: {}, skills: {}}
    private var fields:Array = ['name', 'flavorName', 'flavorClass', 'flavor', 'levelGraphNodeTypes', 'levelGraphObject']

    public function CharToJson () {
      requestSwf("./ClickerHeroes2.swf", loadCH2)
      requestSwf("./HelpfulAdventurer.swf", loadHelpfulAdventurer)
      requestSwf("./Wizard.swf", loadWizard)

      var textField:TextField = new TextField();
      textField.text = "Open the JS console!";
      addChild(textField);

      log('CharToJson loaded')
    }

    private function loadCH2(e:Event):void {
      try {
        var cls:Class = e.target.applicationDomain.getDefinition("IdleHeroMain") as Class;
        // thanks, ffdec/JPEXS!
        this.json.ch2 = pick(cls, ['GAME_VERSION'])
        loadComplete()
      }
      catch(e:Error) {
        log("failed to load ch2: "+e)
      }
    }
    private function loadHelpfulAdventurer(e:Event):void {
      try {
        var cls:Class = e.target.applicationDomain.getDefinition("HelpfulAdventurerMain") as Class;
        new cls().onStartup(null);
        var Characters:Class = e.target.applicationDomain.getDefinition("models.Characters") as Class;
        var char:Object = Characters.startingDefaultInstances['Helpful Adventurer']
        this.json.heroes.helpfulAdventurer = pick(char, fields)
        loadSkills(e, "helpfulAdventurer")
        loadComplete()
      }
      catch(e:Error) {
        log("failed to load helpfulAdventurer: "+e)
      }
    }
    private function loadWizard(e:Event):void {
      try {
        var cls:Class = e.target.applicationDomain.getDefinition("WizardMain") as Class;
        new cls().onStartup(null)
        var Characters:Class = e.target.applicationDomain.getDefinition("models.Characters") as Class;
        var char:Object = Characters.startingDefaultInstances['Wizard']
        this.json.heroes.wizard = pick(char, fields)
        // until wizard's working, fake its graph
        this.json.heroes.wizard.levelGraphObject = {edges:[], nodes:[]}
        this.json.heroes.wizard.levelGraphNodeTypes = {}
        loadSkills(e, "wizard")
        loadComplete()
      }
      catch(e:Error) {
        log("failed to load wizard: "+e)
      }
    }
    private function loadComplete():void {
      this.pending -= 1;
      if (this.pending > 0) return;

      // all loaded!
      logJson(this.json)
      log("")
      log("CharToJson success! Copy-paste that big mess above into the json file that we just opened for you, please:")
      log("./assets/ch2data/chars/latest.json")
    }

    private function loadSkills(e: Event, char: String): void {
      var Character:Class = e.target.applicationDomain.getDefinition("models.Character") as Class;
      for (var key:String in Character.staticSkillInstances) {
        if (!this.json.skills[key]) {
          this.json.skills[key] = pick(Character.staticSkillInstances[key], ['modName', 'uid', 'name', 'description', 'cooldown', 'manaCost', 'energyCost', 'ignoresGCD', 'iconId']);
          this.json.skills[key].char = char
        }
      }
    }

    // https://stackoverflow.com/questions/1634757/as3-instantiate-class-from-external-swf
    private function requestSwf(path: String, onLoad: Function): void {
      var loader:Loader = new Loader();
      loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
      loader.load(new URLRequest(path));
      this.pending += 1
    }

    // https://stackoverflow.com/questions/864155/see-trace-of-flash-when-running-in-browser
    private function log(str:String):void {
      if(ExternalInterface.available){
        // define this in javascript on the same page!
        ExternalInterface.call("logEscaped", escape(str));
      }
    }

    private function logJson(obj: Object): void {
      log(JSON.stringify(obj, null, 2))
    }

    private function pick(obj: Object, keys: Array): Object {
      var ret:Object = {}
      for (var i:int=0; i < keys.length; i++) {
        ret[keys[i]] = obj[keys[i]]
      }
      return ret
    }

  }
}
