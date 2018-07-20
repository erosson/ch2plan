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
    private var chars: Object = {}
    private var fields:Array = ['name', 'flavorName', 'flavorClass', 'flavor', 'levelGraphNodeTypes', 'levelGraphObject']

    public function CharToJson () {
      requestSwf("./ClickerHeroes2.swf", loadCH2)
      requestSwf("./HelpfulAdventurer.swf", loadHelpfulAdventurer)

      var textField:TextField = new TextField();
      textField.text = "Open the JS console!";
      addChild(textField);

      log('CharToJson loaded')
    }

    private function loadCH2(e:Event):void {
      try {
        var cls:Class = e.target.applicationDomain.getDefinition("IdleHeroMain") as Class;
        // thanks, ffdec/JPEXS!
        this.chars.ch2 = pick(cls, ['GAME_VERSION'])
        loadComplete()
      }
      catch(e:Error) {
        log("failed to load ch2: "+e)
      }
    }
    private function loadHelpfulAdventurer(e:Event):void {
      try {
        var CharClass:Class = e.target.applicationDomain.getDefinition("HelpfulAdventurerMain") as Class;
        var char:Object = new CharClass();
        char.onStartup(null)
        this.chars.helpfulAdventurer = pick(char.helpfulAdventurer, fields)
        loadComplete()
      }
      catch(e:Error) {
        log("failed to load character: "+e)
      }
    }
    private function loadComplete():void {
      var numLoaded: int = 0;
      for (var key:String in this.chars) {
        numLoaded += 1;
      }
      if (numLoaded < this.pending) return;

      // all loaded!
      logJson(this.chars)
      log("")
      log("CharToJson success! Copy-paste that big mess above into ch2plan's json file, please: ")
      log("./assets/ch2data/chars.json")
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
      //log(JSON.stringify(obj, null, 2))
      log(JSON.stringify(obj))
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
