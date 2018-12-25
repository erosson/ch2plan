package
{
	import com.doogog.utils.MiscUtils;
	import flash.display.Sprite;
	import flash.system.Capabilities;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import heroclickerlib.CH2;
	import com.playsaurus.model.Model;
	import heroclickerlib.GpuImage;
	import heroclickerlib.managers.SoundManager;
	import heroclickerlib.managers.Trace;
	import heroclickerlib.managers.TransientEffects;
	import heroclickerlib.ui.CharacterDisplayUI;
	import heroclickerlib.ui.CharacterUIElement;
	import heroclickerlib.world.CharacterDisplay;
	import heroclickerlib.world.World;
	import models.Item;
	import models.Keybindings;
	import models.Monsters;
	import models.SetTimedEvent;
	import models.Skill;
	import models.Buff;
	import models.Characters;
	import models.Character;
	import models.Monster;
	import models.AttackData;
	import com.doogog.bitmap.BitmapAnimation;
	import flash.display.DisplayObject;
	import models.MonsterDebuff;
	import com.playsaurus.numbers.BigNumber;
	import com.gskinner.utils.Rnd;
	import heroclickerlib.managers.CH2AssetManager;
	import heroclickerlib.GpuMovieClip;
	import heroclickerlib.LevelGraph;
	import Wizard.thumbnail;
	import starling.display.Quad;
	import ui.CachedText;
	import ui.CachedTextManager;
	import ui.CH2UI;
	import ui.hud.BuffSlotUI;
	import ui.hud.HUD;
	import ui.panels.graph.GraphPanel;
	
	public class WizardMain extends Sprite
	{
		public static const CHARACTER_NAME:String = "Wizard";
		public static const CHARACTER_ASSET_GROUP:String = "Wizard";
		
		public var MOD_INFO:Object = 
		{
			"id": 3,
			"name": CHARACTER_NAME,
			"description": "Default prepackaged character class",
			"version": 1.0,
			"author": "Playsaurus",
			"dependencies": "",
			"library": {}
		};
		
		//##############################################
		//############### BALANCE CONSTS ###############
		//##############################################
		
		public static const ENERGY_REGEN_PER_SECOND:int = 1;
		public static const MANA_REGEN_PER_SECOND:int = 1;		// per two seconds
//		public static const LEVEL_UP_GROWTH_RATE_MULTIPLIER:int = 1.5;
		public static function playBackDamageMultiplierGrowthFormula(monstersKilledSinceIdle:Number):Number
		{
			//10% per monster compounding
			return Math.pow(1.2, monstersKilledSinceIdle);
		}
		
		//Runes
		public static const BASE_ACTIVATION_WINDOW_PER_RUNE:Number = 1000;
		public static const ICE_MSEC_PER_RUNE:Number = 2000;
		public static const FIRE_MSEC_PER_RUNE:Number = 1800;
		public static const LIGHTNING_MSEC_PER_RUNE:Number = 1600;
		
		public static const ICE_DAMAGE_MULTIPLIER:Number = 1;
		public static const FIRE_DAMAGE_MULTIPLIER:Number = 1;
		public static const LIGHTNING_DAMAGE_MULTIPLIER:Number = 0.6;
		
		public static const ICE_COST_MULTIPLIER:Number = 0.6;
		public static const FIRE_COST_MULTIPLIER:Number = 1.2;
		public static const LIGHTNING_COST_MULTIPLIER:Number = 1;
		
		//Stats
		public static const FATIGUE_COST:Number = 0.04;
		public static const ICE_CRIT_PERCENT_CHANCE:Number = 5;
		public static const ICE_CRIT_DAMAGE_PERCENT:Number = 40;
		public static const LIGHTNING_HASTE_PERCENT:Number = 10;
		public static const LIGHTNING_CHAIN_PERCENT:Number = 10;
		public static const FIRE_CORROSION_PERCENT_DAMAGE_INCREASE:Number = 20;
		public static const FIRE_BURN_PERCENT_DAMAGE_INCREASE:Number = 10;
		public static const ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT:Number = 10;
		public static const ICE_COOL_CRITICALS_DURATION_SECONDS:Number = 10;
		public static const ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT:Number = 5;
		public static const ICE_COLD_COOL_CRITICALS_DURATION_SECONDS:Number = 5;
		public static const LIGHTNING_FLASH_SPEED_INCREASE_PERCENT:Number = 10;
		public static const LIGHTNING_FLASH_NUM_SPELLS:Number = 3;
		public static const LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT:Number = 5;
		public static const LIGHTNING_LINGERING_FLASH_NUM_SPELLS:Number = 1;
		public static const FIRE_COMBUSTION_CHANCE_PERCENT:Number = 20;
		public static const FIRE_COMBUSTION_DURATION_SECONDS:Number = 8;
		public static const FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT:Number = 10;
		public static const FIRE_SEETHING_COMBUSTION_DURATION_SECONDS:Number = 4;
		public static const FIRE_EXPLOSION_DAMAGE_PERCENT:Number = 50;
		public static const LIGHTNING_CIRCUIT_DAMAGE_PERCENT:Number = 50;
		public static const SHATTER_DAMAGE_PERCENT:Number = 20;
		public static const SHATTER_NUM_MONSTERS:Number = 3;
		public static const COOLTH_REDUCTION_PER_CRIT:Number = 2;
		public static const COOLTH_NUM_CRITS_WHICH_COOL:Number = 4;
		public static const ENERGIZE_DURATION_SECONDS:Number = 10;
		public static const ENERGIZE_ENERGY_PERCENT_RESTORED:Number = 2;
		public static const WARMTH_REDUCTION_PER_BURN:Number = 1;
		public static const WARMTH_MAX_NUMBER_OF_BURNS:Number = 8;
		public static const ICE_ADDITIONAL_PERCENT_DAMAGE:Number = 5;
		public static const LIGHTNING_ADDITIONAL_PERCENT_DAMAGE:Number = 5;
		public static const FIRE_ADDITIONAL_PERCENT_DAMAGE:Number = 5;
		public static const ENERGIZE_ENERGY_PERCENT_RESTORED_ADDITIONAL:Number = 1;
		public static const ENERGIZE_DURATION_SECONDS_ADDITIONAL:Number = 5;
		public static const WARMTH_REDUCTION_PER_BURN_ADDITIONAL:Number = 1;
		public static const WARMTH_MAX_NUMBER_OF_BURNS_ADDITIONAL:Number = 4;
		public static const ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL:Number = 5;
		public static const LIGHTNING_CHAIN_PERCENT_ADDITIONAL:Number = 10;
		public static const LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE:Number = 10;
		public static const HYPERTHERMIA_REDUCTION:Number = 1;
		public static const COOLTH_REDUCTION_PER_CRIT_ADDITION:Number = 2;
		public static const ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE:Number = 5;
		public static const LIGHTNING_FIRE_HASTE_PERCENT:Number = 10;
		public static const LIGHTNING_FIRE_DAMAGE_PERCENT:Number = 5;
		public static const ICE_FIRE_CRIT_DAMAGE_PERCENT:Number = 40;
		public static const ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE:Number = 5;
		public static const ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE:Number = 20;
		public static const LIGHTNING_ZAP_PERCENT_DAMAGE:Number = 5;
		public static const LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE:Number = 5;
		
		public static const ICE_COST_REDUCTION_PERCENT_CHANCE:Number = 10;
		public static const LIGHTNING_COST_REDUCTION_PERCENT_CHANCE:Number = 10;
		public static const FIRE_COST_REDUCTION_PERCENT_CHANCE:Number = 10;
		public static const ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE:Number = 10;
		public static const LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE:Number = 10;
		public static const ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE:Number = 10;
		public static const ICE_LIGHTNING_CHAIN_CHANCE:Number = 10;
		
		public static const BASE_LIGHTNING_ZAP_PERCENT_DAMAGE:Number = 0.5;
		
		//##############################################
		
		//Indexing
		public static const FIRE_RUNE_ID:int = 1;
		public static const ICE_RUNE_ID:int = 2;
		public static const LIGHTNING_RUNE_ID:int = 3;
		public static const NEUTRAL_RUNE_ID:int = 7;
		public static const EXE_RUNE_ID:int = 8;
		
		//Visual
		public static const RUNE_DISTANCE_APART:Number = 42;
		public static const X_DISPLACEMENT:Array = [200,300];
		public static const Y_DISPLACEMENT:Array = [0, 0];	
		public static const ASSOCIATED_FALL_GROUPS:Object = {
			"Wizard_spellIce1": "Wizard_iceFallGroup",
			"Wizard_spellIce2": "Wizard_iceFallGroup",
			"Wizard_spellIce3": "Wizard_iceFallGroup",
			
			"Wizard_spellFire1": "Wizard_fireFallGroup",
			"Wizard_spellFire2": "Wizard_fireFallGroup",
			"Wizard_spellFire3": "Wizard_fireFallGroup",
			
			"Wizard_spellLightning1": "",
			"Wizard_spellLightning2": "",
			"Wizard_spellLightning3": ""
		};
		//Spell names & Descriptions
		public static const ICE1:Object = {"name": "Ice: Magic Rank 1", "description": ""};
		public static const ICE2:Object = {"name": "Ice: Magic Rank 2", "description": ""};
		public static const ICE3:Object = {"name": "Ice: Magic Rank 3", "description": ""};
		public static const ICE4:Object = {"name": "Ice: Magic Rank 4", "description": ""};
		public static const ICE5:Object = {"name": "Ice: Magic Rank 5", "description": ""};
		public static const ICE6:Object = {"name": "Ice: Magic Rank 6", "description": ""};
		public static const ICE7:Object = {"name": "Ice: Magic Rank 7", "description": ""};
		public static const ICE8:Object = {"name": "Ice: Magic Rank 8", "description": ""};
		public static const ICE9:Object = {"name": "Ice: Magic Rank 9", "description": ""};
		
		public static const FIRE1:Object = {"name": "Fire: Magic Rank 1", "description": ""};
		public static const FIRE2:Object = {"name": "Fire: Magic Rank 2", "description": ""};
		public static const FIRE3:Object = {"name": "Fire: Magic Rank 3", "description": ""};
		public static const FIRE4:Object = {"name": "Fire: Magic Rank 4", "description": ""};
		public static const FIRE5:Object = {"name": "Fire: Magic Rank 5", "description": ""};
		public static const FIRE6:Object = {"name": "Fire: Magic Rank 6", "description": ""};
		public static const FIRE7:Object = {"name": "Fire: Magic Rank 7", "description": ""};
		public static const FIRE8:Object = {"name": "Fire: Magic Rank 8", "description": ""};
		public static const FIRE9:Object = {"name": "Fire: Magic Rank 9", "description": ""};
		
		public static const LIGHTNING1:Object = {"name": "Lightning: Magic Rank 1", "description": ""};
		public static const LIGHTNING2:Object = {"name": "Lightning: Magic Rank 2", "description": ""};
		public static const LIGHTNING3:Object = {"name": "Lightning: Magic Rank 3", "description": ""};
		public static const LIGHTNING4:Object = {"name": "Lightning: Magic Rank 4", "description": ""};
		public static const LIGHTNING5:Object = {"name": "Lightning: Magic Rank 5", "description": ""};
		public static const LIGHTNING6:Object = {"name": "Lightning: Magic Rank 6", "description": ""};
		public static const LIGHTNING7:Object = {"name": "Lightning: Magic Rank 7", "description": ""};
		public static const LIGHTNING8:Object = {"name": "Lightning: Magic Rank 8", "description": ""};
		public static const LIGHTNING9:Object = {"name": "Lightning: Magic Rank 9", "description": ""};
		
		//COST REDUCTION VALUES
		public static const ICE_RANK_1_ENERGY_COST:int = 3;
		public static const FIRE_RANK_1_ENERGY_COST:int = 6;
		public static const LIGHTNING_RANK_1_ENERGY_COST:int = 5;
		
		
		public var pendingRunes:Array = [];
		public var cutSpellCombo:Array = [];
		public var isCutting:Boolean = false;
		public var isPasting:Boolean = false;
		public var wasPasted:Boolean = false;
		public var spellStartTime:Number;
		public var recordings:Vector.<Recording> = new Vector.<Recording>;
		public var spells:Vector.<Spell> = new Vector.<Spell>();
		public var charges:Vector.<Charge> = new Vector.<Charge>();
		public var spellTypeHistory:Array = [];
		public var hasUnseenSpell:Boolean = false;
		
		//ui
		public var spellBar:SpellBar;
		public var spellsPanel:SpellsPanel;
		public var automatorPanel:WizardAutomatorPanel;
		
		public function WizardMain() 
		{
			MOD_INFO["library"]["thumbnail"] = Wizard.thumbnail;
			MOD_INFO["library"]["frame"] = Wizard.frame;
		}
		
		public function onStartup(game:IdleHeroMain):void //Save data is NOT loaded at this point, init() has not yet been run
		{
			var wizard:Character = new Character();
			wizard.assetGroupName = CHARACTER_ASSET_GROUP;
			
			wizard.levelGraphObject = {"nodes":[{"1":{"val":"Qs0", "x":0, "y":0}}, {"2":{"val":"Is1", "x": -121, "y":70}}, {"3":{"val":"Ms1", "x": -121, "y": -70}}, {"4":{"val":"Ls1", "x":0, "y": -140}}, {"5":{"val":"Ns1", "x":121, "y": -70}}, {"6":{"val":"Fs1", "x":121, "y":70}}, {"7":{"val":"Os1", "x":0, "y":140}}, {"8":{"val":"Ia1", "x": -140, "y":242}}, {"9":{"val":"Ic1", "x": -242, "y":140}}, {"10":{"val":"Ib1", "x": -280, "y":0}}, {"11":{"val":"Ma1", "x": -242, "y": -140}}, {"12":{"val":"La1", "x": -140, "y": -242}}, {"13":{"val":"Lc1", "x":0, "y": -280}}, {"14":{"val":"Lb1", "x":140, "y": -242}}, {"15":{"val":"Na1", "x":242, "y": -140}}, {"16":{"val":"Fa1", "x":280, "y":0}}, {"17":{"val":"Fc1", "x":242, "y":140}}, {"18":{"val":"Fb1", "x":140, "y":242}}, {"19":{"val":"Oa1", "x":0, "y":280}}, {"20":{"val":"Ic2", "x": -144, "y":395}}, {"21":{"val":"Ib2", "x": -270, "y":322}}, {"22":{"val":"Is2", "x": -364, "y":210}}, {"23":{"val":"Ic2", "x": -414, "y":73}}, {"24":{"val":"Ia2", "x": -414, "y": -73}}, {"25":{"val":"Mb2", "x": -364, "y": -210}}, {"26":{"val":"Lc2", "x": -270, "y": -322}}, {"27":{"val":"Lb2", "x": -144, "y": -395}}, {"28":{"val":"Ls2", "x":0, "y": -420}}, {"29":{"val":"Lc2", "x":144, "y": -395}}, {"30":{"val":"La2", "x":270, "y": -322}}, {"31":{"val":"Nb2", "x":364, "y": -210}}, {"32":{"val":"Fc2", "x":414, "y": -73}}, {"33":{"val":"Fb2", "x":414, "y":73}}, {"34":{"val":"Fs2", "x":364, "y":210}}, {"35":{"val":"Fc2", "x":270, "y":322}}, {"36":{"val":"Fa2", "x":144, "y":395}}, {"37":{"val":"Ob2", "x":0, "y":420}}, {"38":{"val":"Ia2", "x": -145, "y":541}}, {"39":{"val":"Ib2", "x": -265, "y":459}}, {"40":{"val":"Ic2", "x": -295, "y":511}}, {"41":{"val":"Id2", "x": -396, "y":396}}, {"42":{"val":"Ib2", "x": -485, "y":280}}, {"43":{"val":"Ia2", "x": -541, "y":145}}, {"44":{"val":"Ic2", "x": -530, "y":0}}, {"45":{"val":"Id2", "x": -590, "y":0}}, {"46":{"val":"Ia2", "x": -541, "y": -145}}, {"47":{"val":"Mb2", "x": -485, "y": -280}}, {"48":{"val":"Lc2", "x": -396, "y": -396}}, {"49":{"val":"La2", "x": -265, "y": -459}}, {"50":{"val":"Ld2", "x": -295, "y": -511}}, {"51":{"val":"Lb2", "x": -145, "y": -541}}, {"52":{"val":"Lc2", "x":0, "y": -560}}, {"53":{"val":"Ld2", "x":145, "y": -541}}, {"54":{"val":"La2", "x":265, "y": -459}}, {"55":{"val":"Lb2", "x":295, "y": -511}}, {"56":{"val":"Lc2", "x":396, "y": -396}}, {"57":{"val":"Na2", "x":485, "y": -280}}, {"58":{"val":"Fd2", "x":541, "y": -145}}, {"59":{"val":"Fb2", "x":530, "y":0}}, {"60":{"val":"Fa2", "x":590, "y":0}}, {"61":{"val":"Fc2", "x":541, "y":145}}, {"62":{"val":"Fb2", "x":485, "y":280}}, {"63":{"val":"Fd2", "x":396, "y":396}}, {"64":{"val":"Fc2", "x":265, "y":459}}, {"65":{"val":"Fa2", "x":295, "y":511}}, {"66":{"val":"Fd2", "x":145, "y":541}}, {"67":{"val":"Oc2", "x":0, "y":560}}, {"68":{"val":"Ib3", "x": -285, "y":639}}, {"69":{"val":"Id3", "x": -394, "y":542}}, {"70":{"val":"Ic3", "x": -429, "y":591}}, {"71":{"val":"Ib3", "x": -520, "y":468}}, {"72":{"val":"Is3", "x": -606, "y":350}}, {"73":{"val":"Ic3", "x": -666, "y":216}}, {"74":{"val":"Ib3", "x": -666, "y":70}}, {"75":{"val":"Ia3", "x": -726, "y":76}}, {"76":{"val":"Id3", "x": -696, "y": -73}}, {"77":{"val":"Mb3", "x": -666, "y": -216}}, {"78":{"val":"Ma3", "x": -606, "y": -350}}, {"79":{"val":"Mc3", "x": -520, "y": -468}}, {"80":{"val":"Lb3", "x": -411, "y": -566}}, {"81":{"val":"La3", "x": -273, "y": -612}}, {"82":{"val":"Lc3", "x": -297, "y": -667}}, {"83":{"val":"Lb3", "x": -146, "y": -685}}, {"84":{"val":"Ls3", "x":0, "y": -700}}, {"85":{"val":"La3", "x":146, "y": -685}}, {"86":{"val":"Lc3", "x":273, "y": -612}}, {"87":{"val":"Lb3", "x":297, "y": -667}}, {"88":{"val":"Ld3", "x":411, "y": -566}}, {"89":{"val":"Nc3", "x":520, "y": -468}}, {"90":{"val":"Nb3", "x":606, "y": -350}}, {"91":{"val":"Nd3", "x":666, "y": -216}}, {"92":{"val":"Fc3", "x":696, "y": -73}}, {"93":{"val":"Fa3", "x":666, "y":70}}, {"94":{"val":"Fb3", "x":726, "y":76}}, {"95":{"val":"Fd3", "x":666, "y":216}}, {"96":{"val":"Fs3", "x":606, "y":350}}, {"97":{"val":"Fa3", "x":520, "y":468}}, {"98":{"val":"Fc3", "x":394, "y":542}}, {"99":{"val":"Fd3", "x":429, "y":591}}, {"100":{"val":"Fb3", "x":285, "y":639}}, {"101":{"val":"Oc3", "x":146, "y":685}}, {"102":{"val":"Oa3", "x":0, "y":700}}, {"103":{"val":"Od3", "x": -146, "y":685}}, {"104":{"val":"Ic3", "x": -287, "y":789}}, {"105":{"val":"Ia3", "x": -405, "y":701}}, {"106":{"val":"Iz3", "x": -435, "y":753}}, {"107":{"val":"Id3", "x": -540, "y":643}}, {"108":{"val":"Ib3", "x": -643, "y":540}}, {"109":{"val":"It3", "x": -727, "y":420}}, {"110":{"val":"Id3", "x": -789, "y":287}}, {"111":{"val":"Ib3", "x": -827, "y":146}}, {"112":{"val":"Iy3", "x": -810, "y":0}}, {"113":{"val":"Iz3", "x": -870, "y":0}}, {"114":{"val":"Ia3", "x": -827, "y": -146}}, {"115":{"val":"Mc3", "x": -789, "y": -287}}, {"116":{"val":"Mb3", "x": -727, "y": -420}}, {"117":{"val":"Md3", "x": -643, "y": -540}}, {"118":{"val":"Lz3", "x": -540, "y": -643}}, {"119":{"val":"Ly3", "x": -405, "y": -701}}, {"120":{"val":"Lc3", "x": -435, "y": -753}}, {"121":{"val":"Lz3", "x": -287, "y": -789}}, {"122":{"val":"La3", "x": -146, "y": -827}}, {"123":{"val":"Lt3", "x":0, "y": -840}}, {"124":{"val":"Lb3", "x":146, "y": -827}}, {"125":{"val":"Lz3", "x":287, "y": -789}}, {"126":{"val":"Ld3", "x":405, "y": -701}}, {"127":{"val":"Ly3", "x":435, "y": -753}}, {"128":{"val":"La3", "x":540, "y": -643}}, {"129":{"val":"Nb3", "x":643, "y": -540}}, {"130":{"val":"Nc3", "x":727, "y": -420}}, {"131":{"val":"Nd3", "x":789, "y": -287}}, {"132":{"val":"Fb3", "x":827, "y": -146}}, {"133":{"val":"Fa3", "x":810, "y":0}}, {"134":{"val":"Fc3", "x":870, "y":0}}, {"135":{"val":"Fz3", "x":827, "y":146}}, {"136":{"val":"Fb3", "x":789, "y":287}}, {"137":{"val":"Ft3", "x":727, "y":420}}, {"138":{"val":"Fy3", "x":643, "y":540}}, {"139":{"val":"Fa3", "x":540, "y":643}}, {"140":{"val":"Fd3", "x":405, "y":701}}, {"141":{"val":"Fb3", "x":435, "y":753}}, {"142":{"val":"Fy3", "x":287, "y":789}}, {"143":{"val":"Oc3", "x":146, "y":827}}, {"144":{"val":"Od3", "x":0, "y":840}}, {"145":{"val":"Ob3", "x": -146, "y":827}}, {"146":{"val":"Ia4", "x": -289, "y":936}}, {"147":{"val":"Ic4", "x": -412, "y":856}}, {"148":{"val":"Iz4", "x": -438, "y":910}}, {"149":{"val":"Ia4", "x": -552, "y":810}}, {"150":{"val":"Iy4", "x": -646, "y":696}}, {"151":{"val":"Ib4", "x": -687, "y":740}}, {"152":{"val":"Ia4", "x": -766, "y":611}}, {"153":{"val":"Is4", "x": -849, "y":490}}, {"154":{"val":"Id4", "x": -912, "y":358}}, {"155":{"val":"Ia4", "x": -926, "y":211}}, {"156":{"val":"Iz4", "x": -985, "y":225}}, {"157":{"val":"Ib4", "x": -977, "y":73}}, {"158":{"val":"Iy4", "x": -947, "y": -71}}, {"159":{"val":"Iz4", "x": -1007, "y": -75}}, {"160":{"val":"Ic4", "x": -955, "y": -218}}, {"161":{"val":"Ma4", "x": -912, "y": -358}}, {"162":{"val":"Md4", "x": -849, "y": -490}}, {"163":{"val":"Mb4", "x": -766, "y": -611}}, {"164":{"val":"La4", "x": -667, "y": -718}}, {"165":{"val":"Lz4", "x": -535, "y": -785}}, {"166":{"val":"Ld4", "x": -569, "y": -835}}, {"167":{"val":"Ly4", "x": -425, "y": -883}}, {"168":{"val":"Lc4", "x": -280, "y": -908}}, {"169":{"val":"Lb4", "x": -298, "y": -965}}, {"170":{"val":"La4", "x": -146, "y": -969}}, {"171":{"val":"Ls4", "x":0, "y": -980}}, {"172":{"val":"Lz4", "x":146, "y": -969}}, {"173":{"val":"Lc4", "x":280, "y": -908}}, {"174":{"val":"Ld4", "x":298, "y": -965}}, {"175":{"val":"Lb4", "x":425, "y": -883}}, {"176":{"val":"Lc4", "x":535, "y": -785}}, {"177":{"val":"Ld4", "x":569, "y": -835}}, {"178":{"val":"Ly4", "x":667, "y": -718}}, {"179":{"val":"Nc4", "x":766, "y": -611}}, {"180":{"val":"Nb4", "x":849, "y": -490}}, {"181":{"val":"Na4", "x":912, "y": -358}}, {"182":{"val":"Fd4", "x":955, "y": -218}}, {"183":{"val":"Fc4", "x":947, "y": -71}}, {"184":{"val":"Fa4", "x":1007, "y": -75}}, {"185":{"val":"Fd4", "x":977, "y":73}}, {"186":{"val":"Fz4", "x":926, "y":211}}, {"187":{"val":"Fy4", "x":985, "y":225}}, {"188":{"val":"Fa4", "x":912, "y":358}}, {"189":{"val":"Fs4", "x":849, "y":490}}, {"190":{"val":"Fc4", "x":766, "y":611}}, {"191":{"val":"Fz4", "x":646, "y":696}}, {"192":{"val":"Fa4", "x":687, "y":740}}, {"193":{"val":"Fd4", "x":552, "y":810}}, {"194":{"val":"Fb4", "x":412, "y":856}}, {"195":{"val":"Fz4", "x":438, "y":910}}, {"196":{"val":"Fy4", "x":289, "y":936}}, {"197":{"val":"Oa4", "x":146, "y":969}}, {"198":{"val":"Od4", "x":0, "y":980}}, {"199":{"val":"Ob4", "x": -146, "y":969}}, {"200":{"val":"Ia4", "x": -290, "y":1082}}, {"201":{"val":"Id4", "x": -417, "y":1007}}, {"202":{"val":"Ic4", "x": -440, "y":1062}}, {"203":{"val":"Ib4", "x": -560, "y":970}}, {"204":{"val":"Iz4", "x": -664, "y":865}}, {"205":{"val":"Ic4", "x": -700, "y":912}}, {"206":{"val":"Ib4", "x": -792, "y":792}}, {"207":{"val":"Iy4", "x": -889, "y":682}}, {"208":{"val":"It4", "x": -970, "y":560}}, {"209":{"val":"Id4", "x": -1035, "y":429}}, {"210":{"val":"Ia4", "x": -1082, "y":290}}, {"211":{"val":"Ib4", "x": -1081, "y":142}}, {"212":{"val":"Id4", "x": -1140, "y":150}}, {"213":{"val":"Iy4", "x": -1120, "y":0}}, {"214":{"val":"Ic4", "x": -1081, "y": -142}}, {"215":{"val":"Ia4", "x": -1140, "y": -150}}, {"216":{"val":"Iz4", "x": -1082, "y": -290}}, {"217":{"val":"Md4", "x": -1035, "y": -429}}, {"218":{"val":"Mb4", "x": -970, "y": -560}}, {"219":{"val":"Mc4", "x": -889, "y": -682}}, {"220":{"val":"Lz4", "x": -792, "y": -792}}, {"221":{"val":"Ly4", "x": -664, "y": -865}}, {"222":{"val":"Lc4", "x": -700, "y": -912}}, {"223":{"val":"La4", "x": -560, "y": -970}}, {"224":{"val":"Lb4", "x": -417, "y": -1007}}, {"225":{"val":"Ly4", "x": -440, "y": -1062}}, {"226":{"val":"La4", "x": -290, "y": -1082}}, {"227":{"val":"Lc4", "x": -146, "y": -1110}}, {"228":{"val":"Lt4", "x":0, "y": -1120}}, {"229":{"val":"Lb4", "x":146, "y": -1110}}, {"230":{"val":"Lc4", "x":290, "y": -1082}}, {"231":{"val":"Ld4", "x":417, "y": -1007}}, {"232":{"val":"Lz4", "x":440, "y": -1062}}, {"233":{"val":"Lc4", "x":560, "y": -970}}, {"234":{"val":"Ly4", "x":664, "y": -865}}, {"235":{"val":"Lb4", "x":700, "y": -912}}, {"236":{"val":"Lc4", "x":792, "y": -792}}, {"237":{"val":"Na4", "x":889, "y": -682}}, {"238":{"val":"Nd4", "x":970, "y": -560}}, {"239":{"val":"Nb4", "x":1035, "y": -429}}, {"240":{"val":"Fc4", "x":1082, "y": -290}}, {"241":{"val":"Fa4", "x":1081, "y": -142}}, {"242":{"val":"Fb4", "x":1140, "y": -150}}, {"243":{"val":"Fd4", "x":1120, "y":0}}, {"244":{"val":"Fz4", "x":1081, "y":142}}, {"245":{"val":"Fc4", "x":1140, "y":150}}, {"246":{"val":"Fb4", "x":1082, "y":290}}, {"247":{"val":"Fy4", "x":1035, "y":429}}, {"248":{"val":"Ft4", "x":970, "y":560}}, {"249":{"val":"Fb4", "x":889, "y":682}}, {"250":{"val":"Fy4", "x":792, "y":792}}, {"251":{"val":"Fd4", "x":664, "y":865}}, {"252":{"val":"Fc4", "x":700, "y":912}}, {"253":{"val":"Fz4", "x":560, "y":970}}, {"254":{"val":"Fd4", "x":417, "y":1007}}, {"255":{"val":"Fy4", "x":440, "y":1062}}, {"256":{"val":"Fz4", "x":290, "y":1082}}, {"257":{"val":"Ob4", "x":146, "y":1110}}, {"258":{"val":"Od4", "x":0, "y":1120}}, {"259":{"val":"Oc4", "x": -146, "y":1110}}, {"260":{"val":"Iy5", "x": -431, "y":1184}}, {"261":{"val":"Id5", "x": -552, "y":1099}}, {"262":{"val":"Ic5", "x": -579, "y":1153}}, {"263":{"val":"Iz5", "x": -692, "y":1053}}, {"264":{"val":"Ib5", "x": -791, "y":942}}, {"265":{"val":"Id5", "x": -829, "y":988}}, {"266":{"val":"Ic5", "x": -916, "y":865}}, {"267":{"val":"Iz5", "x": -1011, "y":752}}, {"268":{"val":"Is5", "x": -1091, "y":630}}, {"269":{"val":"Ic5", "x": -1157, "y":499}}, {"270":{"val":"Ib5", "x": -1207, "y":361}}, {"271":{"val":"Iz5", "x": -1211, "y":214}}, {"272":{"val":"Id5", "x": -1270, "y":224}}, {"273":{"val":"Ic5", "x": -1258, "y":73}}, {"274":{"val":"Ib5", "x": -1228, "y": -72}}, {"275":{"val":"Id5", "x": -1288, "y": -75}}, {"276":{"val":"Ic5", "x": -1241, "y": -219}}, {"277":{"val":"Ma5", "x": -1207, "y": -361}}, {"278":{"val":"Mb5", "x": -1157, "y": -499}}, {"279":{"val":"Mc5", "x": -1091, "y": -630}}, {"280":{"val":"Md5", "x": -1011, "y": -752}}, {"281":{"val":"Ma5", "x": -916, "y": -865}}, {"282":{"val":"Lb5", "x": -810, "y": -965}}, {"283":{"val":"Lc5", "x": -676, "y": -1028}}, {"284":{"val":"Ld5", "x": -709, "y": -1078}}, {"285":{"val":"Lb5", "x": -565, "y": -1126}}, {"286":{"val":"Ly5", "x": -421, "y": -1156}}, {"287":{"val":"Lz5", "x": -441, "y": -1212}}, {"288":{"val":"Ld5", "x": -291, "y": -1226}}, {"289":{"val":"Ly5", "x": -146, "y": -1251}}, {"290":{"val":"Ls5", "x":0, "y": -1260}}, {"291":{"val":"La5", "x":146, "y": -1251}}, {"292":{"val":"Lb5", "x":291, "y": -1226}}, {"293":{"val":"Ly5", "x":421, "y": -1156}}, {"294":{"val":"Ld5", "x":441, "y": -1212}}, {"295":{"val":"La5", "x":565, "y": -1126}}, {"296":{"val":"Lc5", "x":676, "y": -1028}}, {"297":{"val":"Ly5", "x":709, "y": -1078}}, {"298":{"val":"Ld5", "x":810, "y": -965}}, {"299":{"val":"Nb5", "x":916, "y": -865}}, {"300":{"val":"Na5", "x":1011, "y": -752}}, {"301":{"val":"Nd5", "x":1091, "y": -630}}, {"302":{"val":"Nc5", "x":1157, "y": -499}}, {"303":{"val":"Nb5", "x":1207, "y": -361}}, {"304":{"val":"Fz5", "x":1241, "y": -219}}, {"305":{"val":"Fa5", "x":1228, "y": -72}}, {"306":{"val":"Fc5", "x":1288, "y": -75}}, {"307":{"val":"Fb5", "x":1258, "y":73}}, {"308":{"val":"Fd5", "x":1211, "y":214}}, {"309":{"val":"Fy5", "x":1270, "y":224}}, {"310":{"val":"Fz5", "x":1207, "y":361}}, {"311":{"val":"Fa5", "x":1157, "y":499}}, {"312":{"val":"Fs5", "x":1091, "y":630}}, {"313":{"val":"Fy5", "x":1011, "y":752}}, {"314":{"val":"Fd5", "x":916, "y":865}}, {"315":{"val":"Fa5", "x":791, "y":942}}, {"316":{"val":"Fc5", "x":829, "y":988}}, {"317":{"val":"Fy5", "x":692, "y":1053}}, {"318":{"val":"Fz5", "x":552, "y":1099}}, {"319":{"val":"Fa5", "x":579, "y":1153}}, {"320":{"val":"Fb5", "x":431, "y":1184}}, {"321":{"val":"Oc5", "x":291, "y":1226}}, {"322":{"val":"Od5", "x":146, "y":1251}}, {"323":{"val":"Oa5", "x":0, "y":1260}}, {"324":{"val":"Ob5", "x": -146, "y":1251}}, {"325":{"val":"Od5", "x": -291, "y":1226}}, {"326":{"val":"Ia5", "x": -433, "y":1331}}, {"327":{"val":"Ib5", "x": -557, "y":1252}}, {"328":{"val":"Iz5", "x": -582, "y":1306}}, {"329":{"val":"Id5", "x": -700, "y":1212}}, {"330":{"val":"Iy5", "x": -805, "y":1108}}, {"331":{"val":"Iz5", "x": -841, "y":1157}}, {"332":{"val":"Id5", "x": -937, "y":1040}}, {"333":{"val":"Ia5", "x": -1018, "y":917}}, {"334":{"val":"Iz5", "x": -1063, "y":957}}, {"335":{"val":"Ic5", "x": -1133, "y":823}}, {"336":{"val":"It5", "x": -1212, "y":700}}, {"337":{"val":"Iy5", "x": -1279, "y":569}}, {"338":{"val":"Ia5", "x": -1303, "y":423}}, {"339":{"val":"Ic5", "x": -1360, "y":442}}, {"340":{"val":"Ib5", "x": -1369, "y":291}}, {"341":{"val":"Ia5", "x": -1362, "y":143}}, {"342":{"val":"Iy5", "x": -1422, "y":149}}, {"343":{"val":"Iz5", "x": -1400, "y":0}}, {"344":{"val":"Ib5", "x": -1362, "y": -143}}, {"345":{"val":"Id5", "x": -1422, "y": -149}}, {"346":{"val":"Iy5", "x": -1369, "y": -291}}, {"347":{"val":"Mc5", "x": -1331, "y": -433}}, {"348":{"val":"Ma5", "x": -1279, "y": -569}}, {"349":{"val":"Ms5", "x": -1212, "y": -700}}, {"350":{"val":"Mc5", "x": -1133, "y": -823}}, {"351":{"val":"Mb5", "x": -1040, "y": -937}}, {"352":{"val":"Lz5", "x": -937, "y": -1040}}, {"353":{"val":"La5", "x": -805, "y": -1108}}, {"354":{"val":"Lb5", "x": -841, "y": -1157}}, {"355":{"val":"Ly5", "x": -700, "y": -1212}}, {"356":{"val":"Lz5", "x": -557, "y": -1252}}, {"357":{"val":"La5", "x": -582, "y": -1306}}, {"358":{"val":"Ld5", "x": -433, "y": -1331}}, {"359":{"val":"Lb5", "x": -285, "y": -1340}}, {"360":{"val":"Lz5", "x": -297, "y": -1399}}, {"361":{"val":"Lc5", "x": -146, "y": -1392}}, {"362":{"val":"Lt5", "x":0, "y": -1400}}, {"363":{"val":"Lb5", "x":146, "y": -1392}}, {"364":{"val":"La5", "x":285, "y": -1340}}, {"365":{"val":"Lc5", "x":297, "y": -1399}}, {"366":{"val":"Lz5", "x":433, "y": -1331}}, {"367":{"val":"Ly5", "x":557, "y": -1252}}, {"368":{"val":"Lc5", "x":582, "y": -1306}}, {"369":{"val":"Ld5", "x":700, "y": -1212}}, {"370":{"val":"La5", "x":805, "y": -1108}}, {"371":{"val":"Lc5", "x":841, "y": -1157}}, {"372":{"val":"Lb5", "x":937, "y": -1040}}, {"373":{"val":"Nd5", "x":1040, "y": -937}}, {"374":{"val":"Nc5", "x":1133, "y": -823}}, {"375":{"val":"Ns5", "x":1212, "y": -700}}, {"376":{"val":"Na5", "x":1279, "y": -569}}, {"377":{"val":"Nb5", "x":1331, "y": -433}}, {"378":{"val":"Fd5", "x":1369, "y": -291}}, {"379":{"val":"Fc5", "x":1362, "y": -143}}, {"380":{"val":"Fa5", "x":1422, "y": -149}}, {"381":{"val":"Fd5", "x":1400, "y":0}}, {"382":{"val":"Fz5", "x":1362, "y":143}}, {"383":{"val":"Fy5", "x":1422, "y":149}}, {"384":{"val":"Fa5", "x":1369, "y":291}}, {"385":{"val":"Fz5", "x":1303, "y":423}}, {"386":{"val":"Fb5", "x":1360, "y":442}}, {"387":{"val":"Fy5", "x":1279, "y":569}}, {"388":{"val":"Ft5", "x":1212, "y":700}}, {"389":{"val":"Fc5", "x":1133, "y":823}}, {"390":{"val":"Fa5", "x":1018, "y":917}}, {"391":{"val":"Fd5", "x":1063, "y":957}}, {"392":{"val":"Fc5", "x":937, "y":1040}}, {"393":{"val":"Fb5", "x":805, "y":1108}}, {"394":{"val":"Fz5", "x":841, "y":1157}}, {"395":{"val":"Fa5", "x":700, "y":1212}}, {"396":{"val":"Fc5", "x":557, "y":1252}}, {"397":{"val":"Fb5", "x":582, "y":1306}}, {"398":{"val":"Fy5", "x":433, "y":1331}}, {"399":{"val":"Oa5", "x":291, "y":1369}}, {"400":{"val":"Od5", "x":146, "y":1392}}, {"401":{"val":"Os5", "x":0, "y":1400}}, {"402":{"val":"Ob5", "x": -146, "y":1392}}, {"403":{"val":"Oa5", "x": -291, "y":1369}}, {"404":{"val":"Iz6", "x": -434, "y":1478}}, {"405":{"val":"Id6", "x": -561, "y":1402}}, {"406":{"val":"Ib6", "x": -584, "y":1458}}, {"407":{"val":"Ia6", "x": -706, "y":1369}}, {"408":{"val":"Ic6", "x": -816, "y":1270}}, {"409":{"val":"Id6", "x": -849, "y":1321}}, {"410":{"val":"Ib6", "x": -952, "y":1211}}, {"411":{"val":"Iy6", "x": -1042, "y":1093}}, {"412":{"val":"Ia6", "x": -1083, "y":1136}}, {"413":{"val":"Ib6", "x": -1164, "y":1008}}, {"414":{"val":"Iz6", "x": -1254, "y":893}}, {"415":{"val":"Is6", "x": -1334, "y":770}}, {"416":{"val":"Id6", "x": -1401, "y":640}}, {"417":{"val":"Iz6", "x": -1455, "y":504}}, {"418":{"val":"Iy6", "x": -1467, "y":356}}, {"419":{"val":"Ia6", "x": -1526, "y":370}}, {"420":{"val":"Iz6", "x": -1524, "y":219}}, {"421":{"val":"Ic6", "x": -1508, "y":72}}, {"422":{"val":"Ia6", "x": -1568, "y":75}}, {"423":{"val":"Iz6", "x": -1538, "y": -73}}, {"424":{"val":"Id6", "x": -1495, "y": -215}}, {"425":{"val":"Ic6", "x": -1554, "y": -223}}, {"426":{"val":"Iz6", "x": -1497, "y": -363}}, {"427":{"val":"Mb6", "x": -1455, "y": -504}}, {"428":{"val":"Mc6", "x": -1401, "y": -640}}, {"429":{"val":"Ma6", "x": -1334, "y": -770}}, {"430":{"val":"Mb6", "x": -1254, "y": -893}}, {"431":{"val":"Mc6", "x": -1164, "y": -1008}}, {"432":{"val":"La6", "x": -1063, "y": -1115}}, {"433":{"val":"Lz6", "x": -933, "y": -1187}}, {"434":{"val":"Lb6", "x": -971, "y": -1234}}, {"435":{"val":"Ly6", "x": -833, "y": -1296}}, {"436":{"val":"La6", "x": -692, "y": -1342}}, {"437":{"val":"Lb6", "x": -719, "y": -1395}}, {"438":{"val":"Lz6", "x": -572, "y": -1430}}, {"439":{"val":"Ld6", "x": -425, "y": -1449}}, {"440":{"val":"Lc6", "x": -442, "y": -1506}}, {"441":{"val":"Lz6", "x": -291, "y": -1512}}, {"442":{"val":"Lb6", "x": -146, "y": -1533}}, {"443":{"val":"Ls6", "x":0, "y": -1540}}, {"444":{"val":"Ld6", "x":146, "y": -1533}}, {"445":{"val":"La6", "x":291, "y": -1512}}, {"446":{"val":"Lc6", "x":425, "y": -1449}}, {"447":{"val":"Ly6", "x":442, "y": -1506}}, {"448":{"val":"La6", "x":572, "y": -1430}}, {"449":{"val":"Ld6", "x":692, "y": -1342}}, {"450":{"val":"Ly6", "x":719, "y": -1395}}, {"451":{"val":"Lb6", "x":833, "y": -1296}}, {"452":{"val":"La6", "x":933, "y": -1187}}, {"453":{"val":"Ly6", "x":971, "y": -1234}}, {"454":{"val":"Lz6", "x":1063, "y": -1115}}, {"455":{"val":"Nb6", "x":1164, "y": -1008}}, {"456":{"val":"Nd6", "x":1254, "y": -893}}, {"457":{"val":"Na6", "x":1334, "y": -770}}, {"458":{"val":"Nc6", "x":1401, "y": -640}}, {"459":{"val":"Nb6", "x":1455, "y": -504}}, {"460":{"val":"Fa6", "x":1497, "y": -363}}, {"461":{"val":"Fd6", "x":1495, "y": -215}}, {"462":{"val":"Fb6", "x":1554, "y": -223}}, {"463":{"val":"Fz6", "x":1538, "y": -73}}, {"464":{"val":"Fa6", "x":1508, "y":72}}, {"465":{"val":"Fd6", "x":1568, "y":75}}, {"466":{"val":"Fc6", "x":1524, "y":219}}, {"467":{"val":"Fb6", "x":1467, "y":356}}, {"468":{"val":"Fd6", "x":1526, "y":370}}, {"469":{"val":"Fa6", "x":1455, "y":504}}, {"470":{"val":"Fb6", "x":1401, "y":640}}, {"471":{"val":"Fs6", "x":1334, "y":770}}, {"472":{"val":"Fy6", "x":1254, "y":893}}, {"473":{"val":"Fd6", "x":1164, "y":1008}}, {"474":{"val":"Fc6", "x":1042, "y":1093}}, {"475":{"val":"Fz6", "x":1083, "y":1136}}, {"476":{"val":"Fb6", "x":952, "y":1211}}, {"477":{"val":"Fa6", "x":816, "y":1270}}, {"478":{"val":"Fc6", "x":849, "y":1321}}, {"479":{"val":"Fb6", "x":706, "y":1369}}, {"480":{"val":"Fd6", "x":561, "y":1402}}, {"481":{"val":"Fc6", "x":584, "y":1458}}, {"482":{"val":"Fy6", "x":434, "y":1478}}, {"483":{"val":"Oa6", "x":291, "y":1512}}, {"484":{"val":"Oc6", "x":146, "y":1533}}, {"485":{"val":"Od6", "x":0, "y":1540}}, {"486":{"val":"Ob6", "x": -146, "y":1533}}, {"487":{"val":"Oc6", "x": -291, "y":1512}}, {"488":{"val":"Iy6", "x": -435, "y":1623}}, {"489":{"val":"Ix6", "x": -564, "y":1550}}, {"490":{"val":"Ic6", "x": -585, "y":1607}}, {"491":{"val":"Ib6", "x": -710, "y":1523}}, {"492":{"val":"Iy6", "x": -825, "y":1429}}, {"493":{"val":"Ic6", "x": -855, "y":1481}}, {"494":{"val":"Iz6", "x": -964, "y":1376}}, {"495":{"val":"Id6", "x": -1061, "y":1264}}, {"496":{"val":"Ix6", "x": -1099, "y":1310}}, {"497":{"val":"Ic6", "x": -1188, "y":1188}}, {"498":{"val":"Ib6", "x": -1264, "y":1061}}, {"499":{"val":"Ix6", "x": -1310, "y":1099}}, {"500":{"val":"Ia6", "x": -1376, "y":964}}, {"501":{"val":"It6", "x": -1455, "y":840}}, {"502":{"val":"Ic6", "x": -1523, "y":710}}, {"503":{"val":"Iz6", "x": -1550, "y":564}}, {"504":{"val":"Iw6", "x": -1607, "y":585}}, {"505":{"val":"Ix6", "x": -1623, "y":435}}, {"506":{"val":"Id6", "x": -1625, "y":287}}, {"507":{"val":"Ia6", "x": -1684, "y":297}}, {"508":{"val":"Ix6", "x": -1674, "y":146}}, {"509":{"val":"Ib6", "x": -1650, "y":0}}, {"510":{"val":"Iz6", "x": -1710, "y":0}}, {"511":{"val":"Ia6", "x": -1674, "y": -146}}, {"512":{"val":"Ix6", "x": -1625, "y": -287}}, {"513":{"val":"Iy6", "x": -1684, "y": -297}}, {"514":{"val":"Id6", "x": -1623, "y": -435}}, {"515":{"val":"Mc6", "x": -1579, "y": -575}}, {"516":{"val":"Ma6", "x": -1523, "y": -710}}, {"517":{"val":"Mb6", "x": -1455, "y": -840}}, {"518":{"val":"Md6", "x": -1376, "y": -964}}, {"519":{"val":"Ma6", "x": -1287, "y": -1080}}, {"520":{"val":"Lc6", "x": -1188, "y": -1188}}, {"521":{"val":"Lb6", "x": -1061, "y": -1264}}, {"522":{"val":"Lx6", "x": -1099, "y": -1310}}, {"523":{"val":"Lw6", "x": -964, "y": -1376}}, {"524":{"val":"Ld6", "x": -825, "y": -1429}}, {"525":{"val":"Lx6", "x": -855, "y": -1481}}, {"526":{"val":"Lz6", "x": -710, "y": -1523}}, {"527":{"val":"Ld6", "x": -564, "y": -1550}}, {"528":{"val":"Ly6", "x": -585, "y": -1607}}, {"529":{"val":"Lw6", "x": -435, "y": -1623}}, {"530":{"val":"Lx6", "x": -287, "y": -1625}}, {"531":{"val":"Ld6", "x": -297, "y": -1684}}, {"532":{"val":"Lb6", "x": -146, "y": -1674}}, {"533":{"val":"Lt6", "x":0, "y": -1680}}, {"534":{"val":"Lz6", "x":146, "y": -1674}}, {"535":{"val":"Lw6", "x":287, "y": -1625}}, {"536":{"val":"La6", "x":297, "y": -1684}}, {"537":{"val":"Lz6", "x":435, "y": -1623}}, {"538":{"val":"Lc6", "x":564, "y": -1550}}, {"539":{"val":"Ly6", "x":585, "y": -1607}}, {"540":{"val":"Lb6", "x":710, "y": -1523}}, {"541":{"val":"Ld6", "x":825, "y": -1429}}, {"542":{"val":"Lz6", "x":855, "y": -1481}}, {"543":{"val":"Lc6", "x":964, "y": -1376}}, {"544":{"val":"Lw6", "x":1061, "y": -1264}}, {"545":{"val":"Ld6", "x":1099, "y": -1310}}, {"546":{"val":"Ly6", "x":1188, "y": -1188}}, {"547":{"val":"Na6", "x":1287, "y": -1080}}, {"548":{"val":"Nc6", "x":1376, "y": -964}}, {"549":{"val":"Nd6", "x":1455, "y": -840}}, {"550":{"val":"Nb6", "x":1523, "y": -710}}, {"551":{"val":"Na6", "x":1579, "y": -575}}, {"552":{"val":"Fz6", "x":1623, "y": -435}}, {"553":{"val":"Fy6", "x":1625, "y": -287}}, {"554":{"val":"Fb6", "x":1684, "y": -297}}, {"555":{"val":"Fx6", "x":1674, "y": -146}}, {"556":{"val":"Fa6", "x":1650, "y":0}}, {"557":{"val":"Fy6", "x":1710, "y":0}}, {"558":{"val":"Fc6", "x":1674, "y":146}}, {"559":{"val":"Fz6", "x":1625, "y":287}}, {"560":{"val":"Fy6", "x":1684, "y":297}}, {"561":{"val":"Fw6", "x":1623, "y":435}}, {"562":{"val":"Fz6", "x":1550, "y":564}}, {"563":{"val":"Fd6", "x":1607, "y":585}}, {"564":{"val":"Fy6", "x":1523, "y":710}}, {"565":{"val":"Ft6", "x":1455, "y":840}}, {"566":{"val":"Fa6", "x":1376, "y":964}}, {"567":{"val":"Fw6", "x":1264, "y":1061}}, {"568":{"val":"Fy6", "x":1310, "y":1099}}, {"569":{"val":"Fb6", "x":1188, "y":1188}}, {"570":{"val":"Fa6", "x":1061, "y":1264}}, {"571":{"val":"Fz6", "x":1099, "y":1310}}, {"572":{"val":"Fx6", "x":964, "y":1376}}, {"573":{"val":"Fc6", "x":825, "y":1429}}, {"574":{"val":"Fd6", "x":855, "y":1481}}, {"575":{"val":"Fy6", "x":710, "y":1523}}, {"576":{"val":"Fa6", "x":564, "y":1550}}, {"577":{"val":"Fc6", "x":585, "y":1607}}, {"578":{"val":"Fz6", "x":435, "y":1623}}, {"579":{"val":"Od6", "x":292, "y":1654}}, {"580":{"val":"Oc6", "x":146, "y":1674}}, {"581":{"val":"Oa6", "x":0, "y":1680}}, {"582":{"val":"Od6", "x": -146, "y":1674}}, {"583":{"val":"Ob6", "x": -292, "y":1654}}, {"584":{"val":"Iy7", "x": -576, "y":1726}}, {"585":{"val":"Iz7", "x": -702, "y":1647}}, {"586":{"val":"Ix7", "x": -725, "y":1702}}, {"587":{"val":"Iy7", "x": -846, "y":1612}}, {"588":{"val":"Ib7", "x": -957, "y":1513}}, {"589":{"val":"Id7", "x": -989, "y":1564}}, {"590":{"val":"Ia7", "x": -1093, "y":1455}}, {"591":{"val":"Iz7", "x": -1187, "y":1340}}, {"592":{"val":"Ib7", "x": -1227, "y":1385}}, {"593":{"val":"Id7", "x": -1313, "y":1261}}, {"594":{"val":"Ic7", "x": -1387, "y":1132}}, {"595":{"val":"Ib7", "x": -1433, "y":1170}}, {"596":{"val":"Iw7", "x": -1498, "y":1034}}, {"597":{"val":"Is7", "x": -1576, "y":910}}, {"598":{"val":"Ic7", "x": -1644, "y":780}}, {"599":{"val":"Ix7", "x": -1674, "y":635}}, {"600":{"val":"Id7", "x": -1730, "y":656}}, {"601":{"val":"Ic7", "x": -1748, "y":506}}, {"602":{"val":"Ia7", "x": -1754, "y":358}}, {"603":{"val":"Iy7", "x": -1813, "y":370}}, {"604":{"val":"Ix7", "x": -1807, "y":219}}, {"605":{"val":"Ia7", "x": -1789, "y":72}}, {"606":{"val":"Iy7", "x": -1848, "y":74}}, {"607":{"val":"Id7", "x": -1819, "y": -73}}, {"608":{"val":"Ib7", "x": -1777, "y": -216}}, {"609":{"val":"Ia7", "x": -1837, "y": -223}}, {"610":{"val":"Ic7", "x": -1783, "y": -364}}, {"611":{"val":"Mb7", "x": -1748, "y": -506}}, {"612":{"val":"Ma7", "x": -1674, "y": -635}}, {"613":{"val":"Mc7", "x": -1730, "y": -656}}, {"614":{"val":"Md7", "x": -1644, "y": -780}}, {"615":{"val":"Mb7", "x": -1576, "y": -910}}, {"616":{"val":"Ma7", "x": -1498, "y": -1034}}, {"617":{"val":"Md7", "x": -1387, "y": -1132}}, {"618":{"val":"Mb7", "x": -1433, "y": -1170}}, {"619":{"val":"Mc7", "x": -1313, "y": -1261}}, {"620":{"val":"Lz7", "x": -1207, "y": -1362}}, {"621":{"val":"Ly7", "x": -1075, "y": -1431}}, {"622":{"val":"Lw7", "x": -1111, "y": -1479}}, {"623":{"val":"Lx7", "x": -973, "y": -1538}}, {"624":{"val":"Lb7", "x": -832, "y": -1585}}, {"625":{"val":"Lw7", "x": -860, "y": -1638}}, {"626":{"val":"Lz7", "x": -713, "y": -1674}}, {"627":{"val":"Ld7", "x": -567, "y": -1698}}, {"628":{"val":"Lx7", "x": -586, "y": -1755}}, {"629":{"val":"Lw7", "x": -436, "y": -1767}}, {"630":{"val":"Lb7", "x": -287, "y": -1767}}, {"631":{"val":"Lx7", "x": -297, "y": -1826}}, {"632":{"val":"La7", "x": -146, "y": -1814}}, {"633":{"val":"Ls7", "x":0, "y": -1820}}, {"634":{"val":"Lx7", "x":146, "y": -1814}}, {"635":{"val":"Lb7", "x":287, "y": -1767}}, {"636":{"val":"Ly7", "x":297, "y": -1826}}, {"637":{"val":"Lc7", "x":436, "y": -1767}}, {"638":{"val":"Lb7", "x":567, "y": -1698}}, {"639":{"val":"Lx7", "x":586, "y": -1755}}, {"640":{"val":"Ly7", "x":713, "y": -1674}}, {"641":{"val":"Ld7", "x":832, "y": -1585}}, {"642":{"val":"La7", "x":860, "y": -1638}}, {"643":{"val":"Ly7", "x":973, "y": -1538}}, {"644":{"val":"Lb7", "x":1075, "y": -1431}}, {"645":{"val":"Lx7", "x":1111, "y": -1479}}, {"646":{"val":"Lw7", "x":1207, "y": -1362}}, {"647":{"val":"Nb7", "x":1313, "y": -1261}}, {"648":{"val":"Nd7", "x":1387, "y": -1132}}, {"649":{"val":"Na7", "x":1433, "y": -1170}}, {"650":{"val":"Nb7", "x":1498, "y": -1034}}, {"651":{"val":"Nc7", "x":1576, "y": -910}}, {"652":{"val":"Nd7", "x":1644, "y": -780}}, {"653":{"val":"Nb7", "x":1674, "y": -635}}, {"654":{"val":"Na7", "x":1730, "y": -656}}, {"655":{"val":"Nd7", "x":1748, "y": -506}}, {"656":{"val":"Fy7", "x":1783, "y": -364}}, {"657":{"val":"Fx7", "x":1777, "y": -216}}, {"658":{"val":"Fd7", "x":1837, "y": -223}}, {"659":{"val":"Fy7", "x":1819, "y": -73}}, {"660":{"val":"Fc7", "x":1789, "y":72}}, {"661":{"val":"Fw7", "x":1848, "y":74}}, {"662":{"val":"Fz7", "x":1807, "y":219}}, {"663":{"val":"Fd7", "x":1754, "y":358}}, {"664":{"val":"Fc7", "x":1813, "y":370}}, {"665":{"val":"Fb7", "x":1748, "y":506}}, {"666":{"val":"Fd7", "x":1674, "y":635}}, {"667":{"val":"Fy7", "x":1730, "y":656}}, {"668":{"val":"Fa7", "x":1644, "y":780}}, {"669":{"val":"Fs7", "x":1576, "y":910}}, {"670":{"val":"Fc7", "x":1498, "y":1034}}, {"671":{"val":"Fd7", "x":1387, "y":1132}}, {"672":{"val":"Fz7", "x":1433, "y":1170}}, {"673":{"val":"Fb7", "x":1313, "y":1261}}, {"674":{"val":"Fd7", "x":1187, "y":1340}}, {"675":{"val":"Fy7", "x":1227, "y":1385}}, {"676":{"val":"Fb7", "x":1093, "y":1455}}, {"677":{"val":"Fz7", "x":957, "y":1513}}, {"678":{"val":"Fd7", "x":989, "y":1564}}, {"679":{"val":"Fc7", "x":846, "y":1612}}, {"680":{"val":"Fb7", "x":702, "y":1647}}, {"681":{"val":"Fa7", "x":725, "y":1702}}, {"682":{"val":"Fw7", "x":576, "y":1726}}, {"683":{"val":"Od7", "x":436, "y":1767}}, {"684":{"val":"Oc7", "x":287, "y":1767}}, {"685":{"val":"Oa7", "x":297, "y":1826}}, {"686":{"val":"Od7", "x":146, "y":1814}}, {"687":{"val":"Oc7", "x":0, "y":1820}}, {"688":{"val":"Oa7", "x": -146, "y":1814}}, {"689":{"val":"Od7", "x": -287, "y":1767}}, {"690":{"val":"Ob7", "x": -297, "y":1826}}, {"691":{"val":"Oa7", "x": -436, "y":1767}}, {"692":{"val":"Iw7", "x": -578, "y":1873}}, {"693":{"val":"Id7", "x": -705, "y":1797}}, {"694":{"val":"Ix7", "x": -727, "y":1852}}, {"695":{"val":"Iy7", "x": -850, "y":1766}}, {"696":{"val":"Ic7", "x": -965, "y":1671}}, {"697":{"val":"Ix7", "x": -995, "y":1723}}, {"698":{"val":"Ia7", "x": -1104, "y":1619}}, {"699":{"val":"Ib7", "x": -1203, "y":1509}}, {"700":{"val":"Iz7", "x": -1241, "y":1556}}, {"701":{"val":"Ia7", "x": -1333, "y":1437}}, {"702":{"val":"Ic7", "x": -1415, "y":1313}}, {"703":{"val":"Iy7", "x": -1459, "y":1354}}, {"704":{"val":"Id7", "x": -1532, "y":1222}}, {"705":{"val":"Ia7", "x": -1619, "y":1104}}, {"706":{"val":"It7", "x": -1697, "y":980}}, {"707":{"val":"Iw7", "x": -1766, "y":850}}, {"708":{"val":"Ia7", "x": -1825, "y":716}}, {"709":{"val":"Ix7", "x": -1844, "y":569}}, {"710":{"val":"Iz7", "x": -1902, "y":587}}, {"711":{"val":"Ic7", "x": -1911, "y":436}}, {"712":{"val":"Id7", "x": -1908, "y":288}}, {"713":{"val":"Ia7", "x": -1968, "y":297}}, {"714":{"val":"Iw7", "x": -1955, "y":146}}, {"715":{"val":"Iy7", "x": -1930, "y":0}}, {"716":{"val":"Id7", "x": -1990, "y":0}}, {"717":{"val":"Iw7", "x": -1955, "y": -146}}, {"718":{"val":"Ix7", "x": -1908, "y": -288}}, {"719":{"val":"Iy7", "x": -1968, "y": -297}}, {"720":{"val":"Iw7", "x": -1911, "y": -436}}, {"721":{"val":"Mc7", "x": -1873, "y": -578}}, {"722":{"val":"Mb7", "x": -1797, "y": -705}}, {"723":{"val":"Ma7", "x": -1852, "y": -727}}, {"724":{"val":"Mc7", "x": -1766, "y": -850}}, {"725":{"val":"Ms7", "x": -1697, "y": -980}}, {"726":{"val":"Md7", "x": -1619, "y": -1104}}, {"727":{"val":"Mc7", "x": -1509, "y": -1203}}, {"728":{"val":"Mb7", "x": -1556, "y": -1241}}, {"729":{"val":"Ma7", "x": -1437, "y": -1333}}, {"730":{"val":"Lc7", "x": -1333, "y": -1437}}, {"731":{"val":"Lz7", "x": -1203, "y": -1509}}, {"732":{"val":"Ld7", "x": -1241, "y": -1556}}, {"733":{"val":"Lc7", "x": -1104, "y": -1619}}, {"734":{"val":"Ly7", "x": -965, "y": -1671}}, {"735":{"val":"Lw7", "x": -995, "y": -1723}}, {"736":{"val":"Lc7", "x": -850, "y": -1766}}, {"737":{"val":"Lx7", "x": -705, "y": -1797}}, {"738":{"val":"La7", "x": -727, "y": -1852}}, {"739":{"val":"Ld7", "x": -578, "y": -1873}}, {"740":{"val":"Lw7", "x": -429, "y": -1882}}, {"741":{"val":"Lz7", "x": -443, "y": -1940}}, {"742":{"val":"Lx7", "x": -292, "y": -1938}}, {"743":{"val":"Lw7", "x": -146, "y": -1955}}, {"744":{"val":"Lt7", "x":0, "y": -1960}}, {"745":{"val":"Lb7", "x":146, "y": -1955}}, {"746":{"val":"Lx7", "x":292, "y": -1938}}, {"747":{"val":"Lz7", "x":429, "y": -1882}}, {"748":{"val":"Lc7", "x":443, "y": -1940}}, {"749":{"val":"Lx7", "x":578, "y": -1873}}, {"750":{"val":"Lw7", "x":705, "y": -1797}}, {"751":{"val":"Ld7", "x":727, "y": -1852}}, {"752":{"val":"Lc7", "x":850, "y": -1766}}, {"753":{"val":"Lx7", "x":965, "y": -1671}}, {"754":{"val":"Ld7", "x":995, "y": -1723}}, {"755":{"val":"Ly7", "x":1104, "y": -1619}}, {"756":{"val":"Lz7", "x":1203, "y": -1509}}, {"757":{"val":"Lx7", "x":1241, "y": -1556}}, {"758":{"val":"Ld7", "x":1333, "y": -1437}}, {"759":{"val":"Nb7", "x":1437, "y": -1333}}, {"760":{"val":"Na7", "x":1509, "y": -1203}}, {"761":{"val":"Nc7", "x":1556, "y": -1241}}, {"762":{"val":"Nd7", "x":1619, "y": -1104}}, {"763":{"val":"Ns7", "x":1697, "y": -980}}, {"764":{"val":"Na7", "x":1766, "y": -850}}, {"765":{"val":"Nc7", "x":1797, "y": -705}}, {"766":{"val":"Nd7", "x":1852, "y": -727}}, {"767":{"val":"Nb7", "x":1873, "y": -578}}, {"768":{"val":"Fa7", "x":1911, "y": -436}}, {"769":{"val":"Fx7", "x":1908, "y": -288}}, {"770":{"val":"Fb7", "x":1968, "y": -297}}, {"771":{"val":"Fc7", "x":1955, "y": -146}}, {"772":{"val":"Fa7", "x":1930, "y":0}}, {"773":{"val":"Fw7", "x":1990, "y":0}}, {"774":{"val":"Fd7", "x":1955, "y":146}}, {"775":{"val":"Fc7", "x":1908, "y":288}}, {"776":{"val":"Fb7", "x":1968, "y":297}}, {"777":{"val":"Fz7", "x":1911, "y":436}}, {"778":{"val":"Fw7", "x":1844, "y":569}}, {"779":{"val":"Fa7", "x":1902, "y":587}}, {"780":{"val":"Fc7", "x":1825, "y":716}}, {"781":{"val":"Fx7", "x":1766, "y":850}}, {"782":{"val":"Ft7", "x":1697, "y":980}}, {"783":{"val":"Fa7", "x":1619, "y":1104}}, {"784":{"val":"Fd7", "x":1532, "y":1222}}, {"785":{"val":"Fc7", "x":1415, "y":1313}}, {"786":{"val":"Fy7", "x":1459, "y":1354}}, {"787":{"val":"Fw7", "x":1333, "y":1437}}, {"788":{"val":"Fb7", "x":1203, "y":1509}}, {"789":{"val":"Fx7", "x":1241, "y":1556}}, {"790":{"val":"Fa7", "x":1104, "y":1619}}, {"791":{"val":"Fb7", "x":965, "y":1671}}, {"792":{"val":"Fd7", "x":995, "y":1723}}, {"793":{"val":"Fx7", "x":850, "y":1766}}, {"794":{"val":"Fz7", "x":705, "y":1797}}, {"795":{"val":"Fy7", "x":727, "y":1852}}, {"796":{"val":"Fw7", "x":578, "y":1873}}, {"797":{"val":"Ob7", "x":436, "y":1911}}, {"798":{"val":"Od7", "x":288, "y":1908}}, {"799":{"val":"Oc7", "x":297, "y":1968}}, {"800":{"val":"Ob7", "x":146, "y":1955}}, {"801":{"val":"Os7", "x":0, "y":1960}}, {"802":{"val":"Oc7", "x": -146, "y":1955}}, {"803":{"val":"Ob7", "x": -288, "y":1908}}, {"804":{"val":"Oa7", "x": -297, "y":1968}}, {"805":{"val":"Oc7", "x": -436, "y":1911}}, {"806":{"val":"Iw8", "x": -579, "y":2019}}, {"807":{"val":"Ib8", "x": -708, "y":1945}}, {"808":{"val":"Ix8", "x": -729, "y":2002}}, {"809":{"val":"Ia8", "x": -854, "y":1918}}, {"810":{"val":"Id8", "x": -972, "y":1828}}, {"811":{"val":"Iw8", "x": -1000, "y":1881}}, {"812":{"val":"Iy8", "x": -1113, "y":1781}}, {"813":{"val":"Iz8", "x": -1217, "y":1675}}, {"814":{"val":"Iw8", "x": -1252, "y":1723}}, {"815":{"val":"Iy8", "x": -1350, "y":1609}}, {"816":{"val":"Ic8", "x": -1438, "y":1489}}, {"817":{"val":"Iz8", "x": -1480, "y":1532}}, {"818":{"val":"Iw8", "x": -1561, "y":1405}}, {"819":{"val":"Ic8", "x": -1631, "y":1274}}, {"820":{"val":"Ib8", "x": -1678, "y":1311}}, {"821":{"val":"Ia8", "x": -1741, "y":1174}}, {"822":{"val":"Is8", "x": -1819, "y":1050}}, {"823":{"val":"Id8", "x": -1887, "y":921}}, {"824":{"val":"Ic8", "x": -1919, "y":775}}, {"825":{"val":"Ib8", "x": -1975, "y":798}}, {"826":{"val":"Id8", "x": -1997, "y":649}}, {"827":{"val":"Ia8", "x": -2009, "y":501}}, {"828":{"val":"Ic8", "x": -2067, "y":515}}, {"829":{"val":"Ix8", "x": -2068, "y":365}}, {"830":{"val":"Iy8", "x": -2059, "y":216}}, {"831":{"val":"Ic8", "x": -2118, "y":223}}, {"832":{"val":"Id8", "x": -2099, "y":73}}, {"833":{"val":"Iw8", "x": -2069, "y": -72}}, {"834":{"val":"Iy8", "x": -2129, "y": -74}}, {"835":{"val":"Ix8", "x": -2088, "y": -220}}, {"836":{"val":"Id8", "x": -2039, "y": -359}}, {"837":{"val":"Ib8", "x": -2098, "y": -370}}, {"838":{"val":"Iy8", "x": -2038, "y": -508}}, {"839":{"val":"Ma8", "x": -1997, "y": -649}}, {"840":{"val":"Md8", "x": -1919, "y": -775}}, {"841":{"val":"Mb8", "x": -1975, "y": -798}}, {"842":{"val":"Ma8", "x": -1887, "y": -921}}, {"843":{"val":"Mc8", "x": -1819, "y": -1050}}, {"844":{"val":"Mb8", "x": -1741, "y": -1174}}, {"845":{"val":"Md8", "x": -1631, "y": -1274}}, {"846":{"val":"Ma8", "x": -1678, "y": -1311}}, {"847":{"val":"Mc8", "x": -1561, "y": -1405}}, {"848":{"val":"Lz8", "x": -1459, "y": -1511}}, {"849":{"val":"La8", "x": -1331, "y": -1586}}, {"850":{"val":"Lw8", "x": -1369, "y": -1632}}, {"851":{"val":"Ld8", "x": -1234, "y": -1699}}, {"852":{"val":"La8", "x": -1097, "y": -1755}}, {"853":{"val":"Lz8", "x": -1129, "y": -1806}}, {"854":{"val":"Lw8", "x": -986, "y": -1854}}, {"855":{"val":"Ld8", "x": -842, "y": -1891}}, {"856":{"val":"Lx8", "x": -866, "y": -1946}}, {"857":{"val":"Ly8", "x": -718, "y": -1973}}, {"858":{"val":"Lc8", "x": -571, "y": -1990}}, {"859":{"val":"Lx8", "x": -587, "y": -2047}}, {"860":{"val":"Lw8", "x": -437, "y": -2054}}, {"861":{"val":"Lb8", "x": -288, "y": -2050}}, {"862":{"val":"Lc8", "x": -296, "y": -2109}}, {"863":{"val":"Lw8", "x": -146, "y": -2095}}, {"864":{"val":"Ls8", "x":0, "y": -2100}}, {"865":{"val":"Lb8", "x":146, "y": -2095}}, {"866":{"val":"Ly8", "x":288, "y": -2050}}, {"867":{"val":"Lz8", "x":296, "y": -2109}}, {"868":{"val":"La8", "x":437, "y": -2054}}, {"869":{"val":"Ld8", "x":571, "y": -1990}}, {"870":{"val":"Ly8", "x":587, "y": -2047}}, {"871":{"val":"Lw8", "x":718, "y": -1973}}, {"872":{"val":"Lb8", "x":842, "y": -1891}}, {"873":{"val":"Lz8", "x":866, "y": -1946}}, {"874":{"val":"Lw8", "x":986, "y": -1854}}, {"875":{"val":"Lx8", "x":1097, "y": -1755}}, {"876":{"val":"La8", "x":1129, "y": -1806}}, {"877":{"val":"Lc8", "x":1234, "y": -1699}}, {"878":{"val":"Lx8", "x":1331, "y": -1586}}, {"879":{"val":"Lb8", "x":1369, "y": -1632}}, {"880":{"val":"Lc8", "x":1459, "y": -1511}}, {"881":{"val":"Nd8", "x":1561, "y": -1405}}, {"882":{"val":"Nb8", "x":1631, "y": -1274}}, {"883":{"val":"Nc8", "x":1678, "y": -1311}}, {"884":{"val":"Nd8", "x":1741, "y": -1174}}, {"885":{"val":"Nb8", "x":1819, "y": -1050}}, {"886":{"val":"Na8", "x":1887, "y": -921}}, {"887":{"val":"Nc8", "x":1919, "y": -775}}, {"888":{"val":"Nb8", "x":1975, "y": -798}}, {"889":{"val":"Na8", "x":1997, "y": -649}}, {"890":{"val":"Fy8", "x":2038, "y": -508}}, {"891":{"val":"Fx8", "x":2039, "y": -359}}, {"892":{"val":"Fw8", "x":2098, "y": -370}}, {"893":{"val":"Fz8", "x":2088, "y": -220}}, {"894":{"val":"Fa8", "x":2069, "y": -72}}, {"895":{"val":"Fy8", "x":2129, "y": -74}}, {"896":{"val":"Fb8", "x":2099, "y":73}}, {"897":{"val":"Fd8", "x":2059, "y":216}}, {"898":{"val":"Fy8", "x":2118, "y":223}}, {"899":{"val":"Fc8", "x":2068, "y":365}}, {"900":{"val":"Fx8", "x":2009, "y":501}}, {"901":{"val":"Fz8", "x":2067, "y":515}}, {"902":{"val":"Fc8", "x":1997, "y":649}}, {"903":{"val":"Fy8", "x":1919, "y":775}}, {"904":{"val":"Fb8", "x":1975, "y":798}}, {"905":{"val":"Fd8", "x":1887, "y":921}}, {"906":{"val":"Fs8", "x":1819, "y":1050}}, {"907":{"val":"Fb8", "x":1741, "y":1174}}, {"908":{"val":"Fc8", "x":1631, "y":1274}}, {"909":{"val":"Fw8", "x":1678, "y":1311}}, {"910":{"val":"Fy8", "x":1561, "y":1405}}, {"911":{"val":"Fc8", "x":1438, "y":1489}}, {"912":{"val":"Fw8", "x":1480, "y":1532}}, {"913":{"val":"Fb8", "x":1350, "y":1609}}, {"914":{"val":"Fc8", "x":1217, "y":1675}}, {"915":{"val":"Fz8", "x":1252, "y":1723}}, {"916":{"val":"Fx8", "x":1113, "y":1781}}, {"917":{"val":"Fc8", "x":972, "y":1828}}, {"918":{"val":"Fa8", "x":1000, "y":1881}}, {"919":{"val":"Fx8", "x":854, "y":1918}}, {"920":{"val":"Fz8", "x":708, "y":1945}}, {"921":{"val":"Fb8", "x":729, "y":2002}}, {"922":{"val":"Fx8", "x":579, "y":2019}}, {"923":{"val":"Oc8", "x":437, "y":2054}}, {"924":{"val":"Od8", "x":288, "y":2050}}, {"925":{"val":"Ob8", "x":296, "y":2109}}, {"926":{"val":"Oc8", "x":146, "y":2095}}, {"927":{"val":"Oa8", "x":0, "y":2100}}, {"928":{"val":"Ob8", "x": -146, "y":2095}}, {"929":{"val":"Oc8", "x": -288, "y":2050}}, {"930":{"val":"Oa8", "x": -296, "y":2109}}, {"931":{"val":"Od8", "x": -437, "y":2054}}, {"932":{"val":"Ib8", "x": -580, "y":2164}}, {"933":{"val":"Ix8", "x": -710, "y":2093}}, {"934":{"val":"Iz8", "x": -730, "y":2150}}, {"935":{"val":"Id8", "x": -857, "y":2069}}, {"936":{"val":"Iy8", "x": -977, "y":1982}}, {"937":{"val":"Iz8", "x": -1004, "y":2036}}, {"938":{"val":"Ic8", "x": -1120, "y":1940}}, {"939":{"val":"Id8", "x": -1228, "y":1838}}, {"940":{"val":"Ib8", "x": -1261, "y":1887}}, {"941":{"val":"Iy8", "x": -1364, "y":1777}}, {"942":{"val":"Iz8", "x": -1457, "y":1662}}, {"943":{"val":"Ic8", "x": -1497, "y":1707}}, {"944":{"val":"Id8", "x": -1584, "y":1584}}, {"945":{"val":"Ix8", "x": -1662, "y":1457}}, {"946":{"val":"Ib8", "x": -1707, "y":1497}}, {"947":{"val":"Ia8", "x": -1777, "y":1364}}, {"948":{"val":"Iw8", "x": -1862, "y":1244}}, {"949":{"val":"It8", "x": -1940, "y":1120}}, {"950":{"val":"Ia8", "x": -2009, "y":991}}, {"951":{"val":"Ix8", "x": -2069, "y":857}}, {"952":{"val":"Ib8", "x": -2093, "y":710}}, {"953":{"val":"Ic8", "x": -2150, "y":730}}, {"954":{"val":"Iw8", "x": -2164, "y":580}}, {"955":{"val":"Iz8", "x": -2168, "y":431}}, {"956":{"val":"Ix8", "x": -2226, "y":443}}, {"957":{"val":"Ic8", "x": -2221, "y":292}}, {"958":{"val":"Iz8", "x": -2205, "y":145}}, {"959":{"val":"Ia8", "x": -2265, "y":148}}, {"960":{"val":"Iw8", "x": -2240, "y":0}}, {"961":{"val":"Ib8", "x": -2205, "y": -145}}, {"962":{"val":"Ix8", "x": -2265, "y": -148}}, {"963":{"val":"Id8", "x": -2221, "y": -292}}, {"964":{"val":"Iy8", "x": -2168, "y": -431}}, {"965":{"val":"Iw8", "x": -2226, "y": -443}}, {"966":{"val":"Iz8", "x": -2164, "y": -580}}, {"967":{"val":"Mb8", "x": -2121, "y": -720}}, {"968":{"val":"Mc8", "x": -2042, "y": -846}}, {"969":{"val":"Ma8", "x": -2097, "y": -869}}, {"970":{"val":"Mb8", "x": -2009, "y": -991}}, {"971":{"val":"Mc8", "x": -1940, "y": -1120}}, {"972":{"val":"Ma8", "x": -1862, "y": -1244}}, {"973":{"val":"Mb8", "x": -1753, "y": -1345}}, {"974":{"val":"Md8", "x": -1801, "y": -1382}}, {"975":{"val":"Ma8", "x": -1684, "y": -1477}}, {"976":{"val":"Lx8", "x": -1584, "y": -1584}}, {"977":{"val":"Ld8", "x": -1457, "y": -1662}}, {"978":{"val":"Ly8", "x": -1497, "y": -1707}}, {"979":{"val":"Lz8", "x": -1364, "y": -1777}}, {"980":{"val":"Lb8", "x": -1228, "y": -1838}}, {"981":{"val":"Ld8", "x": -1261, "y": -1887}}, {"982":{"val":"Ly8", "x": -1120, "y": -1940}}, {"983":{"val":"La8", "x": -977, "y": -1982}}, {"984":{"val":"Ld8", "x": -1004, "y": -2036}}, {"985":{"val":"Lx8", "x": -857, "y": -2069}}, {"986":{"val":"Lb8", "x": -710, "y": -2093}}, {"987":{"val":"Lw8", "x": -730, "y": -2150}}, {"988":{"val":"La8", "x": -580, "y": -2164}}, {"989":{"val":"Lb8", "x": -431, "y": -2168}}, {"990":{"val":"Ld8", "x": -443, "y": -2226}}, {"991":{"val":"Lz8", "x": -292, "y": -2221}}, {"992":{"val":"Lx8", "x": -147, "y": -2235}}, {"993":{"val":"Lt8", "x":0, "y": -2240}}, {"994":{"val":"Lz8", "x":147, "y": -2235}}, {"995":{"val":"Ly8", "x":292, "y": -2221}}, {"996":{"val":"La8", "x":431, "y": -2168}}, {"997":{"val":"Lx8", "x":443, "y": -2226}}, {"998":{"val":"Ld8", "x":580, "y": -2164}}, {"999":{"val":"Ly8", "x":710, "y": -2093}}, {"1000":{"val":"Lz8", "x":730, "y": -2150}}, {"1001":{"val":"Lb8", "x":857, "y": -2069}}, {"1002":{"val":"Ly8", "x":977, "y": -1982}}, {"1003":{"val":"Lw8", "x":1004, "y": -2036}}, {"1004":{"val":"Lc8", "x":1120, "y": -1940}}, {"1005":{"val":"Lz8", "x":1228, "y": -1838}}, {"1006":{"val":"Lx8", "x":1261, "y": -1887}}, {"1007":{"val":"Lc8", "x":1364, "y": -1777}}, {"1008":{"val":"Lz8", "x":1457, "y": -1662}}, {"1009":{"val":"Lb8", "x":1497, "y": -1707}}, {"1010":{"val":"Lc8", "x":1584, "y": -1584}}, {"1011":{"val":"Nd8", "x":1684, "y": -1477}}, {"1012":{"val":"Nb8", "x":1753, "y": -1345}}, {"1013":{"val":"Nc8", "x":1801, "y": -1382}}, {"1014":{"val":"Na8", "x":1862, "y": -1244}}, {"1015":{"val":"Nd8", "x":1940, "y": -1120}}, {"1016":{"val":"Nb8", "x":2009, "y": -991}}, {"1017":{"val":"Na8", "x":2042, "y": -846}}, {"1018":{"val":"Nd8", "x":2097, "y": -869}}, {"1019":{"val":"Nc8", "x":2121, "y": -720}}, {"1020":{"val":"Fw8", "x":2164, "y": -580}}, {"1021":{"val":"Fz8", "x":2168, "y": -431}}, {"1022":{"val":"Fx8", "x":2226, "y": -443}}, {"1023":{"val":"Fc8", "x":2221, "y": -292}}, {"1024":{"val":"Fy8", "x":2205, "y": -145}}, {"1025":{"val":"Fd8", "x":2265, "y": -148}}, {"1026":{"val":"Fc8", "x":2240, "y":0}}, {"1027":{"val":"Fx8", "x":2205, "y":145}}, {"1028":{"val":"Fy8", "x":2265, "y":148}}, {"1029":{"val":"Fw8", "x":2221, "y":292}}, {"1030":{"val":"Fz8", "x":2168, "y":431}}, {"1031":{"val":"Fb8", "x":2226, "y":443}}, {"1032":{"val":"Fx8", "x":2164, "y":580}}, {"1033":{"val":"Fa8", "x":2093, "y":710}}, {"1034":{"val":"Fw8", "x":2150, "y":730}}, {"1035":{"val":"Fd8", "x":2069, "y":857}}, {"1036":{"val":"Fx8", "x":2009, "y":991}}, {"1037":{"val":"Ft8", "x":1940, "y":1120}}, {"1038":{"val":"Fa8", "x":1862, "y":1244}}, {"1039":{"val":"Fy8", "x":1777, "y":1364}}, {"1040":{"val":"Fb8", "x":1662, "y":1457}}, {"1041":{"val":"Fw8", "x":1707, "y":1497}}, {"1042":{"val":"Fa8", "x":1584, "y":1584}}, {"1043":{"val":"Fd8", "x":1457, "y":1662}}, {"1044":{"val":"Fc8", "x":1497, "y":1707}}, {"1045":{"val":"Fa8", "x":1364, "y":1777}}, {"1046":{"val":"Fb8", "x":1228, "y":1838}}, {"1047":{"val":"Fc8", "x":1261, "y":1887}}, {"1048":{"val":"Fz8", "x":1120, "y":1940}}, {"1049":{"val":"Fy8", "x":977, "y":1982}}, {"1050":{"val":"Fx8", "x":1004, "y":2036}}, {"1051":{"val":"Fc8", "x":857, "y":2069}}, {"1052":{"val":"Fb8", "x":710, "y":2093}}, {"1053":{"val":"Fw8", "x":730, "y":2150}}, {"1054":{"val":"Fz8", "x":580, "y":2164}}, {"1055":{"val":"Od8", "x":437, "y":2197}}, {"1056":{"val":"Oc8", "x":288, "y":2191}}, {"1057":{"val":"Oa8", "x":296, "y":2251}}, {"1058":{"val":"Ob8", "x":147, "y":2235}}, {"1059":{"val":"Oc8", "x":0, "y":2240}}, {"1060":{"val":"Oa8", "x": -147, "y":2235}}, {"1061":{"val":"Od8", "x": -288, "y":2191}}, {"1062":{"val":"Oc8", "x": -296, "y":2251}}, {"1063":{"val":"Oa8", "x": -437, "y":2197}}, {"1064":{"val":"Iz9", "x": -722, "y":2268}}, {"1065":{"val":"Iy9", "x": -849, "y":2191}}, {"1066":{"val":"Ic9", "x": -871, "y":2247}}, {"1067":{"val":"Iw9", "x": -995, "y":2162}}, {"1068":{"val":"Ia9", "x": -1112, "y":2070}}, {"1069":{"val":"Ic9", "x": -1140, "y":2123}}, {"1070":{"val":"Iw9", "x": -1253, "y":2024}}, {"1071":{"val":"Iz9", "x": -1358, "y":1918}}, {"1072":{"val":"Id9", "x": -1392, "y":1967}}, {"1073":{"val":"Ic9", "x": -1492, "y":1854}}, {"1074":{"val":"Iz9", "x": -1583, "y":1737}}, {"1075":{"val":"Ix9", "x": -1624, "y":1781}}, {"1076":{"val":"Ib9", "x": -1709, "y":1657}}, {"1077":{"val":"Id9", "x": -1785, "y":1529}}, {"1078":{"val":"Ix9", "x": -1830, "y":1568}}, {"1079":{"val":"Iz9", "x": -1899, "y":1434}}, {"1080":{"val":"Iw9", "x": -1984, "y":1315}}, {"1081":{"val":"Is9", "x": -2061, "y":1190}}, {"1082":{"val":"Id9", "x": -2130, "y":1061}}, {"1083":{"val":"Ia9", "x": -2192, "y":928}}, {"1084":{"val":"Iz9", "x": -2216, "y":781}}, {"1085":{"val":"Ib9", "x": -2273, "y":801}}, {"1086":{"val":"Ic9", "x": -2289, "y":651}}, {"1087":{"val":"Iw9", "x": -2296, "y":503}}, {"1088":{"val":"Ia9", "x": -2354, "y":516}}, {"1089":{"val":"Iz9", "x": -2352, "y":365}}, {"1090":{"val":"Ix9", "x": -2340, "y":217}}, {"1091":{"val":"Ic9", "x": -2400, "y":222}}, {"1092":{"val":"Ia9", "x": -2379, "y":73}}, {"1093":{"val":"Ix9", "x": -2349, "y": -72}}, {"1094":{"val":"Ic9", "x": -2409, "y": -74}}, {"1095":{"val":"Ib9", "x": -2370, "y": -220}}, {"1096":{"val":"Ix9", "x": -2322, "y": -360}}, {"1097":{"val":"Id9", "x": -2381, "y": -370}}, {"1098":{"val":"Ic9", "x": -2325, "y": -509}}, {"1099":{"val":"Ma9", "x": -2289, "y": -651}}, {"1100":{"val":"Md9", "x": -2216, "y": -781}}, {"1101":{"val":"Mb9", "x": -2273, "y": -801}}, {"1102":{"val":"Ma9", "x": -2192, "y": -928}}, {"1103":{"val":"Md9", "x": -2130, "y": -1061}}, {"1104":{"val":"Mb9", "x": -2061, "y": -1190}}, {"1105":{"val":"Ma9", "x": -1984, "y": -1315}}, {"1106":{"val":"Md9", "x": -1899, "y": -1434}}, {"1107":{"val":"Mc9", "x": -1785, "y": -1529}}, {"1108":{"val":"Mb9", "x": -1830, "y": -1568}}, {"1109":{"val":"Md9", "x": -1709, "y": -1657}}, {"1110":{"val":"Lz9", "x": -1603, "y": -1759}}, {"1111":{"val":"Lx9", "x": -1473, "y": -1831}}, {"1112":{"val":"Lw9", "x": -1511, "y": -1878}}, {"1113":{"val":"Lc9", "x": -1375, "y": -1943}}, {"1114":{"val":"Ld9", "x": -1237, "y": -1998}}, {"1115":{"val":"Ly9", "x": -1269, "y": -2049}}, {"1116":{"val":"Lx9", "x": -1126, "y": -2097}}, {"1117":{"val":"Lz9", "x": -982, "y": -2135}}, {"1118":{"val":"Lc9", "x": -1007, "y": -2189}}, {"1119":{"val":"La9", "x": -860, "y": -2219}}, {"1120":{"val":"Lz9", "x": -712, "y": -2239}}, {"1121":{"val":"Ly9", "x": -731, "y": -2297}}, {"1122":{"val":"Ld9", "x": -581, "y": -2308}}, {"1123":{"val":"Lw9", "x": -432, "y": -2310}}, {"1124":{"val":"Lx9", "x": -443, "y": -2369}}, {"1125":{"val":"Ld9", "x": -292, "y": -2362}}, {"1126":{"val":"Ly9", "x": -147, "y": -2375}}, {"1127":{"val":"Ls9", "x":0, "y": -2380}}, {"1128":{"val":"La9", "x":147, "y": -2375}}, {"1129":{"val":"Lw9", "x":292, "y": -2362}}, {"1130":{"val":"Lx9", "x":432, "y": -2310}}, {"1131":{"val":"La9", "x":443, "y": -2369}}, {"1132":{"val":"Lb9", "x":581, "y": -2308}}, {"1133":{"val":"Lw9", "x":712, "y": -2239}}, {"1134":{"val":"Lz9", "x":731, "y": -2297}}, {"1135":{"val":"La9", "x":860, "y": -2219}}, {"1136":{"val":"Lb9", "x":982, "y": -2135}}, {"1137":{"val":"Lc9", "x":1007, "y": -2189}}, {"1138":{"val":"Lw9", "x":1126, "y": -2097}}, {"1139":{"val":"Ld9", "x":1237, "y": -1998}}, {"1140":{"val":"Ly9", "x":1269, "y": -2049}}, {"1141":{"val":"Lx9", "x":1375, "y": -1943}}, {"1142":{"val":"Lz9", "x":1473, "y": -1831}}, {"1143":{"val":"La9", "x":1511, "y": -1878}}, {"1144":{"val":"Lx9", "x":1603, "y": -1759}}, {"1145":{"val":"Nc9", "x":1709, "y": -1657}}, {"1146":{"val":"Na9", "x":1785, "y": -1529}}, {"1147":{"val":"Nb9", "x":1830, "y": -1568}}, {"1148":{"val":"Nd9", "x":1899, "y": -1434}}, {"1149":{"val":"Nc9", "x":1984, "y": -1315}}, {"1150":{"val":"Na9", "x":2061, "y": -1190}}, {"1151":{"val":"Nd9", "x":2130, "y": -1061}}, {"1152":{"val":"Nc9", "x":2192, "y": -928}}, {"1153":{"val":"Na9", "x":2216, "y": -781}}, {"1154":{"val":"Nb9", "x":2273, "y": -801}}, {"1155":{"val":"Nc9", "x":2289, "y": -651}}, {"1156":{"val":"Fa9", "x":2325, "y": -509}}, {"1157":{"val":"Fx9", "x":2322, "y": -360}}, {"1158":{"val":"Fy9", "x":2381, "y": -370}}, {"1159":{"val":"Fz9", "x":2370, "y": -220}}, {"1160":{"val":"Fd9", "x":2349, "y": -72}}, {"1161":{"val":"Fw9", "x":2409, "y": -74}}, {"1162":{"val":"Fa9", "x":2379, "y":73}}, {"1163":{"val":"Fy9", "x":2340, "y":217}}, {"1164":{"val":"Fx9", "x":2400, "y":222}}, {"1165":{"val":"Fc9", "x":2352, "y":365}}, {"1166":{"val":"Fw9", "x":2296, "y":503}}, {"1167":{"val":"Fb9", "x":2354, "y":516}}, {"1168":{"val":"Fd9", "x":2289, "y":651}}, {"1169":{"val":"Fc9", "x":2216, "y":781}}, {"1170":{"val":"Fw9", "x":2273, "y":801}}, {"1171":{"val":"Fx9", "x":2192, "y":928}}, {"1172":{"val":"Fy9", "x":2130, "y":1061}}, {"1173":{"val":"Fs9", "x":2061, "y":1190}}, {"1174":{"val":"Fb9", "x":1984, "y":1315}}, {"1175":{"val":"Fw9", "x":1899, "y":1434}}, {"1176":{"val":"Fz9", "x":1785, "y":1529}}, {"1177":{"val":"Fa9", "x":1830, "y":1568}}, {"1178":{"val":"Fx9", "x":1709, "y":1657}}, {"1179":{"val":"Fy9", "x":1583, "y":1737}}, {"1180":{"val":"Fc9", "x":1624, "y":1781}}, {"1181":{"val":"Fa9", "x":1492, "y":1854}}, {"1182":{"val":"Fw9", "x":1358, "y":1918}}, {"1183":{"val":"Fy9", "x":1392, "y":1967}}, {"1184":{"val":"Fd9", "x":1253, "y":2024}}, {"1185":{"val":"Fx9", "x":1112, "y":2070}}, {"1186":{"val":"Fa9", "x":1140, "y":2123}}, {"1187":{"val":"Fc9", "x":995, "y":2162}}, {"1188":{"val":"Fz9", "x":849, "y":2191}}, {"1189":{"val":"Fx9", "x":871, "y":2247}}, {"1190":{"val":"Fd9", "x":722, "y":2268}}, {"1191":{"val":"Ob9", "x":581, "y":2308}}, {"1192":{"val":"Oc9", "x":432, "y":2310}}, {"1193":{"val":"Oa9", "x":443, "y":2369}}, {"1194":{"val":"Od9", "x":292, "y":2362}}, {"1195":{"val":"Ob9", "x":147, "y":2375}}, {"1196":{"val":"Oa9", "x":0, "y":2380}}, {"1197":{"val":"Od9", "x": -147, "y":2375}}, {"1198":{"val":"Oc9", "x": -292, "y":2362}}, {"1199":{"val":"Ob9", "x": -432, "y":2310}}, {"1200":{"val":"Oa9", "x": -443, "y":2369}}, {"1201":{"val":"Od9", "x": -581, "y":2308}}, {"1202":{"val":"Iz9", "x": -723, "y":2414}}, {"1203":{"val":"Ia9", "x": -852, "y":2340}}, {"1204":{"val":"Id9", "x": -872, "y":2396}}, {"1205":{"val":"Ix9", "x": -998, "y":2314}}, {"1206":{"val":"Ia9", "x": -1118, "y":2225}}, {"1207":{"val":"Iy9", "x": -1144, "y":2279}}, {"1208":{"val":"Iz9", "x": -1260, "y":2182}}, {"1209":{"val":"Id9", "x": -1368, "y":2080}}, {"1210":{"val":"Ix9", "x": -1401, "y":2130}}, {"1211":{"val":"Iz9", "x": -1505, "y":2021}}, {"1212":{"val":"Iy9", "x": -1601, "y":1907}}, {"1213":{"val":"Iw9", "x": -1639, "y":1953}}, {"1214":{"val":"Ix9", "x": -1729, "y":1833}}, {"1215":{"val":"Ic9", "x": -1811, "y":1709}}, {"1216":{"val":"Ia9", "x": -1855, "y":1750}}, {"1217":{"val":"Iw9", "x": -1930, "y":1620}}, {"1218":{"val":"Ic9", "x": -1997, "y":1487}}, {"1219":{"val":"Id9", "x": -2045, "y":1523}}, {"1220":{"val":"Iz9", "x": -2105, "y":1385}}, {"1221":{"val":"It9", "x": -2182, "y":1260}}, {"1222":{"val":"Iy9", "x": -2252, "y":1131}}, {"1223":{"val":"Iw9", "x": -2286, "y":986}}, {"1224":{"val":"Id9", "x": -2341, "y":1010}}, {"1225":{"val":"Ia9", "x": -2368, "y":862}}, {"1226":{"val":"Iz9", "x": -2385, "y":714}}, {"1227":{"val":"Ib9", "x": -2443, "y":731}}, {"1228":{"val":"Ic9", "x": -2452, "y":581}}, {"1229":{"val":"Iy9", "x": -2452, "y":432}}, {"1230":{"val":"Ib9", "x": -2511, "y":443}}, {"1231":{"val":"Ic9", "x": -2503, "y":293}}, {"1232":{"val":"Iz9", "x": -2486, "y":145}}, {"1233":{"val":"Iy9", "x": -2546, "y":148}}, {"1234":{"val":"Ic9", "x": -2520, "y":0}}, {"1235":{"val":"Ix9", "x": -2486, "y": -145}}, {"1236":{"val":"Iw9", "x": -2546, "y": -148}}, {"1237":{"val":"Ia9", "x": -2503, "y": -293}}, {"1238":{"val":"Ic9", "x": -2452, "y": -432}}, {"1239":{"val":"Id9", "x": -2511, "y": -443}}, {"1240":{"val":"Iw9", "x": -2452, "y": -581}}, {"1241":{"val":"Mc9", "x": -2414, "y": -723}}, {"1242":{"val":"Ma9", "x": -2340, "y": -852}}, {"1243":{"val":"Md9", "x": -2396, "y": -872}}, {"1244":{"val":"Mc9", "x": -2314, "y": -998}}, {"1245":{"val":"Ms9", "x": -2252, "y": -1131}}, {"1246":{"val":"Mt9", "x": -2105, "y": -1385}}, {"1247":{"val":"Md9", "x": -2021, "y": -1505}}, {"1248":{"val":"Mc9", "x": -1907, "y": -1601}}, {"1249":{"val":"Mb9", "x": -1953, "y": -1639}}, {"1250":{"val":"Ma9", "x": -1833, "y": -1729}}, {"1251":{"val":"Ly9", "x": -1729, "y": -1833}}, {"1252":{"val":"Lx9", "x": -1601, "y": -1907}}, {"1253":{"val":"Lb9", "x": -1639, "y": -1953}}, {"1254":{"val":"Ld9", "x": -1505, "y": -2021}}, {"1255":{"val":"Lz9", "x": -1368, "y": -2080}}, {"1256":{"val":"Ly9", "x": -1401, "y": -2130}}, {"1257":{"val":"Lc9", "x": -1260, "y": -2182}}, {"1258":{"val":"Lx9", "x": -1118, "y": -2225}}, {"1259":{"val":"Ly9", "x": -1144, "y": -2279}}, {"1260":{"val":"Lc9", "x": -998, "y": -2314}}, {"1261":{"val":"Lw9", "x": -852, "y": -2340}}, {"1262":{"val":"La9", "x": -872, "y": -2396}}, {"1263":{"val":"Lz9", "x": -723, "y": -2414}}, {"1264":{"val":"Lw9", "x": -574, "y": -2423}}, {"1265":{"val":"Lc9", "x": -588, "y": -2481}}, {"1266":{"val":"Ld9", "x": -438, "y": -2482}}, {"1267":{"val":"Lx9", "x": -289, "y": -2473}}, {"1268":{"val":"Lb9", "x": -296, "y": -2533}}, {"1269":{"val":"Ly9", "x": -147, "y": -2516}}, {"1270":{"val":"Lt9", "x":0, "y": -2520}}, {"1271":{"val":"Lb9", "x":147, "y": -2516}}, {"1272":{"val":"Lc9", "x":289, "y": -2473}}, {"1273":{"val":"Ly9", "x":296, "y": -2533}}, {"1274":{"val":"Lx9", "x":438, "y": -2482}}, {"1275":{"val":"La9", "x":574, "y": -2423}}, {"1276":{"val":"Ly9", "x":588, "y": -2481}}, {"1277":{"val":"Lc9", "x":723, "y": -2414}}, {"1278":{"val":"Lw9", "x":852, "y": -2340}}, {"1279":{"val":"Ld9", "x":872, "y": -2396}}, {"1280":{"val":"La9", "x":998, "y": -2314}}, {"1281":{"val":"Lc9", "x":1118, "y": -2225}}, {"1282":{"val":"Lz9", "x":1144, "y": -2279}}, {"1283":{"val":"Lb9", "x":1260, "y": -2182}}, {"1284":{"val":"Ly9", "x":1368, "y": -2080}}, {"1285":{"val":"Lc9", "x":1401, "y": -2130}}, {"1286":{"val":"Lw9", "x":1505, "y": -2021}}, {"1287":{"val":"La9", "x":1601, "y": -1907}}, {"1288":{"val":"Lc9", "x":1639, "y": -1953}}, {"1289":{"val":"Lx9", "x":1729, "y": -1833}}, {"1290":{"val":"Na9", "x":1833, "y": -1729}}, {"1291":{"val":"Nc9", "x":1907, "y": -1601}}, {"1292":{"val":"Nb9", "x":1953, "y": -1639}}, {"1293":{"val":"Nd9", "x":2021, "y": -1505}}, {"1294":{"val":"Ns9", "x":2105, "y": -1385}}, {"1295":{"val":"Nt9", "x":2252, "y": -1131}}, {"1296":{"val":"Nd9", "x":2314, "y": -998}}, {"1297":{"val":"Nc9", "x":2340, "y": -852}}, {"1298":{"val":"Nb9", "x":2396, "y": -872}}, {"1299":{"val":"Nd9", "x":2414, "y": -723}}, {"1300":{"val":"Fw9", "x":2452, "y": -581}}, {"1301":{"val":"Fz9", "x":2452, "y": -432}}, {"1302":{"val":"Fb9", "x":2511, "y": -443}}, {"1303":{"val":"Fy9", "x":2503, "y": -293}}, {"1304":{"val":"Fz9", "x":2486, "y": -145}}, {"1305":{"val":"Fw9", "x":2546, "y": -148}}, {"1306":{"val":"Fx9", "x":2520, "y":0}}, {"1307":{"val":"Fb9", "x":2486, "y":145}}, {"1308":{"val":"Fy9", "x":2546, "y":148}}, {"1309":{"val":"Fx9", "x":2503, "y":293}}, {"1310":{"val":"Fa9", "x":2452, "y":432}}, {"1311":{"val":"Fz9", "x":2511, "y":443}}, {"1312":{"val":"Fd9", "x":2452, "y":581}}, {"1313":{"val":"Fc9", "x":2385, "y":714}}, {"1314":{"val":"Fw9", "x":2443, "y":731}}, {"1315":{"val":"Fa9", "x":2368, "y":862}}, {"1316":{"val":"Fc9", "x":2286, "y":986}}, {"1317":{"val":"Fy9", "x":2341, "y":1010}}, {"1318":{"val":"Fz9", "x":2252, "y":1131}}, {"1319":{"val":"Ft9", "x":2182, "y":1260}}, {"1320":{"val":"Fd9", "x":2105, "y":1385}}, {"1321":{"val":"Fy9", "x":1997, "y":1487}}, {"1322":{"val":"Fw9", "x":2045, "y":1523}}, {"1323":{"val":"Fc9", "x":1930, "y":1620}}, {"1324":{"val":"Fb9", "x":1811, "y":1709}}, {"1325":{"val":"Fa9", "x":1855, "y":1750}}, {"1326":{"val":"Fx9", "x":1729, "y":1833}}, {"1327":{"val":"Fb9", "x":1601, "y":1907}}, {"1328":{"val":"Fz9", "x":1639, "y":1953}}, {"1329":{"val":"Fy9", "x":1505, "y":2021}}, {"1330":{"val":"Fx9", "x":1368, "y":2080}}, {"1331":{"val":"Fc9", "x":1401, "y":2130}}, {"1332":{"val":"Fb9", "x":1260, "y":2182}}, {"1333":{"val":"Fd9", "x":1118, "y":2225}}, {"1334":{"val":"Fy9", "x":1144, "y":2279}}, {"1335":{"val":"Fw9", "x":998, "y":2314}}, {"1336":{"val":"Fa9", "x":852, "y":2340}}, {"1337":{"val":"Fz9", "x":872, "y":2396}}, {"1338":{"val":"Fb9", "x":723, "y":2414}}, {"1339":{"val":"Od9", "x":581, "y":2452}}, {"1340":{"val":"Oa9", "x":432, "y":2452}}, {"1341":{"val":"Ob9", "x":443, "y":2511}}, {"1342":{"val":"Oc9", "x":293, "y":2503}}, {"1343":{"val":"Os9", "x":147, "y":2516}}, {"1344":{"val":"Ot9", "x": -147, "y":2516}}, {"1345":{"val":"Ob9", "x": -293, "y":2503}}, {"1346":{"val":"Oc9", "x": -432, "y":2452}}, {"1347":{"val":"Oa9", "x": -443, "y":2511}}, {"1348":{"val":"Od9", "x": -581, "y":2452}}], "edges":[{"1":[3, 2]}, {"2":[4, 3]}, {"3":[1, 4]}, {"4":[6, 5]}, {"5":[7, 6]}, {"6":[5, 1]}, {"7":[9, 8]}, {"8":[9, 2]}, {"9":[10, 9]}, {"10":[11, 10]}, {"11":[12, 11]}, {"12":[13, 12]}, {"13":[13, 4]}, {"14":[14, 13]}, {"15":[15, 14]}, {"16":[16, 15]}, {"17":[17, 16]}, {"18":[17, 6]}, {"19":[18, 17]}, {"20":[19, 18]}, {"21":[19, 8]}, {"22":[21, 20]}, {"23":[22, 21]}, {"24":[23, 22]}, {"25":[24, 23]}, {"26":[25, 24]}, {"27":[25, 11]}, {"28":[26, 25]}, {"29":[27, 26]}, {"30":[28, 27]}, {"31":[29, 28]}, {"32":[30, 29]}, {"33":[31, 30]}, {"34":[31, 15]}, {"35":[32, 31]}, {"36":[33, 32]}, {"37":[34, 33]}, {"38":[35, 34]}, {"39":[36, 35]}, {"40":[37, 36]}, {"41":[37, 20]}, {"42":[37, 19]}, {"43":[39, 38]}, {"44":[39, 41]}, {"45":[40, 38]}, {"46":[41, 40]}, {"47":[42, 41]}, {"48":[42, 22]}, {"49":[43, 42]}, {"50":[44, 43]}, {"51":[44, 46]}, {"52":[45, 43]}, {"53":[46, 45]}, {"54":[47, 46]}, {"55":[48, 47]}, {"56":[49, 48]}, {"57":[49, 51]}, {"58":[50, 48]}, {"59":[51, 50]}, {"60":[52, 51]}, {"61":[52, 28]}, {"62":[53, 52]}, {"63":[54, 53]}, {"64":[54, 56]}, {"65":[55, 53]}, {"66":[56, 55]}, {"67":[57, 56]}, {"68":[58, 57]}, {"69":[59, 58]}, {"70":[59, 61]}, {"71":[60, 58]}, {"72":[61, 60]}, {"73":[62, 61]}, {"74":[62, 34]}, {"75":[63, 62]}, {"76":[64, 63]}, {"77":[64, 66]}, {"78":[65, 63]}, {"79":[66, 65]}, {"80":[67, 66]}, {"81":[67, 38]}, {"82":[69, 68]}, {"83":[69, 71]}, {"84":[70, 68]}, {"85":[71, 70]}, {"86":[72, 71]}, {"87":[73, 72]}, {"88":[74, 73]}, {"89":[74, 76]}, {"90":[75, 73]}, {"91":[76, 75]}, {"92":[77, 76]}, {"93":[78, 77]}, {"94":[78, 47]}, {"95":[79, 78]}, {"96":[80, 79]}, {"97":[81, 80]}, {"98":[81, 83]}, {"99":[82, 80]}, {"100":[83, 82]}, {"101":[84, 83]}, {"102":[85, 84]}, {"103":[86, 85]}, {"104":[86, 88]}, {"105":[87, 85]}, {"106":[88, 87]}, {"107":[89, 88]}, {"108":[90, 89]}, {"109":[90, 57]}, {"110":[91, 90]}, {"111":[92, 91]}, {"112":[93, 92]}, {"113":[93, 95]}, {"114":[94, 92]}, {"115":[95, 94]}, {"116":[96, 95]}, {"117":[97, 96]}, {"118":[98, 97]}, {"119":[98, 100]}, {"120":[99, 97]}, {"121":[100, 99]}, {"122":[101, 100]}, {"123":[102, 101]}, {"124":[102, 67]}, {"125":[103, 102]}, {"126":[103, 68]}, {"127":[105, 104]}, {"128":[105, 107]}, {"129":[106, 104]}, {"130":[107, 106]}, {"131":[108, 107]}, {"132":[109, 108]}, {"133":[109, 72]}, {"134":[110, 109]}, {"135":[111, 110]}, {"136":[112, 111]}, {"137":[112, 114]}, {"138":[113, 111]}, {"139":[114, 113]}, {"140":[115, 114]}, {"141":[116, 115]}, {"142":[117, 116]}, {"143":[118, 117]}, {"144":[119, 118]}, {"145":[119, 121]}, {"146":[120, 118]}, {"147":[121, 120]}, {"148":[122, 121]}, {"149":[123, 122]}, {"150":[123, 84]}, {"151":[124, 123]}, {"152":[125, 124]}, {"153":[126, 125]}, {"154":[126, 128]}, {"155":[127, 125]}, {"156":[128, 127]}, {"157":[129, 128]}, {"158":[130, 129]}, {"159":[131, 130]}, {"160":[132, 131]}, {"161":[133, 132]}, {"162":[133, 135]}, {"163":[134, 132]}, {"164":[135, 134]}, {"165":[136, 135]}, {"166":[137, 136]}, {"167":[137, 96]}, {"168":[138, 137]}, {"169":[139, 138]}, {"170":[140, 139]}, {"171":[140, 142]}, {"172":[141, 139]}, {"173":[142, 141]}, {"174":[143, 142]}, {"175":[144, 143]}, {"176":[145, 144]}, {"177":[145, 104]}, {"178":[147, 146]}, {"179":[147, 149]}, {"180":[148, 146]}, {"181":[149, 148]}, {"182":[150, 149]}, {"183":[150, 152]}, {"184":[151, 149]}, {"185":[152, 151]}, {"186":[153, 152]}, {"187":[154, 153]}, {"188":[155, 154]}, {"189":[155, 157]}, {"190":[156, 154]}, {"191":[157, 156]}, {"192":[158, 157]}, {"193":[158, 160]}, {"194":[159, 157]}, {"195":[160, 159]}, {"196":[161, 160]}, {"197":[162, 161]}, {"198":[162, 116]}, {"199":[163, 162]}, {"200":[164, 163]}, {"201":[165, 164]}, {"202":[165, 167]}, {"203":[166, 164]}, {"204":[167, 166]}, {"205":[168, 167]}, {"206":[168, 170]}, {"207":[169, 167]}, {"208":[170, 169]}, {"209":[171, 170]}, {"210":[172, 171]}, {"211":[173, 172]}, {"212":[173, 175]}, {"213":[174, 172]}, {"214":[175, 174]}, {"215":[176, 175]}, {"216":[176, 178]}, {"217":[177, 175]}, {"218":[178, 177]}, {"219":[179, 178]}, {"220":[180, 179]}, {"221":[180, 130]}, {"222":[181, 180]}, {"223":[182, 181]}, {"224":[183, 182]}, {"225":[183, 185]}, {"226":[184, 182]}, {"227":[185, 184]}, {"228":[186, 185]}, {"229":[186, 188]}, {"230":[187, 185]}, {"231":[188, 187]}, {"232":[189, 188]}, {"233":[190, 189]}, {"234":[191, 190]}, {"235":[191, 193]}, {"236":[192, 190]}, {"237":[193, 192]}, {"238":[194, 193]}, {"239":[194, 196]}, {"240":[195, 193]}, {"241":[196, 195]}, {"242":[197, 196]}, {"243":[198, 197]}, {"244":[198, 144]}, {"245":[199, 198]}, {"246":[199, 146]}, {"247":[201, 200]}, {"248":[201, 203]}, {"249":[202, 200]}, {"250":[203, 202]}, {"251":[204, 203]}, {"252":[204, 206]}, {"253":[205, 203]}, {"254":[206, 205]}, {"255":[207, 206]}, {"256":[208, 207]}, {"257":[208, 153]}, {"258":[209, 208]}, {"259":[210, 209]}, {"260":[211, 210]}, {"261":[211, 213]}, {"262":[212, 210]}, {"263":[213, 212]}, {"264":[214, 213]}, {"265":[214, 216]}, {"266":[215, 213]}, {"267":[216, 215]}, {"268":[217, 216]}, {"269":[218, 217]}, {"270":[219, 218]}, {"271":[220, 219]}, {"272":[221, 220]}, {"273":[221, 223]}, {"274":[222, 220]}, {"275":[223, 222]}, {"276":[224, 223]}, {"277":[224, 226]}, {"278":[225, 223]}, {"279":[226, 225]}, {"280":[227, 226]}, {"281":[228, 227]}, {"282":[228, 171]}, {"283":[229, 228]}, {"284":[230, 229]}, {"285":[231, 230]}, {"286":[231, 233]}, {"287":[232, 230]}, {"288":[233, 232]}, {"289":[234, 233]}, {"290":[234, 236]}, {"291":[235, 233]}, {"292":[236, 235]}, {"293":[237, 236]}, {"294":[238, 237]}, {"295":[239, 238]}, {"296":[240, 239]}, {"297":[241, 240]}, {"298":[241, 243]}, {"299":[242, 240]}, {"300":[243, 242]}, {"301":[244, 243]}, {"302":[244, 246]}, {"303":[245, 243]}, {"304":[246, 245]}, {"305":[247, 246]}, {"306":[248, 247]}, {"307":[248, 189]}, {"308":[249, 248]}, {"309":[250, 249]}, {"310":[251, 250]}, {"311":[251, 253]}, {"312":[252, 250]}, {"313":[253, 252]}, {"314":[254, 253]}, {"315":[254, 256]}, {"316":[255, 253]}, {"317":[256, 255]}, {"318":[257, 256]}, {"319":[258, 257]}, {"320":[259, 258]}, {"321":[259, 200]}, {"322":[261, 260]}, {"323":[261, 263]}, {"324":[262, 260]}, {"325":[263, 262]}, {"326":[264, 263]}, {"327":[264, 266]}, {"328":[265, 263]}, {"329":[266, 265]}, {"330":[267, 266]}, {"331":[268, 267]}, {"332":[269, 268]}, {"333":[270, 269]}, {"334":[271, 270]}, {"335":[271, 273]}, {"336":[272, 270]}, {"337":[273, 272]}, {"338":[274, 273]}, {"339":[274, 276]}, {"340":[275, 273]}, {"341":[276, 275]}, {"342":[277, 276]}, {"343":[278, 277]}, {"344":[279, 278]}, {"345":[279, 218]}, {"346":[280, 279]}, {"347":[281, 280]}, {"348":[282, 281]}, {"349":[283, 282]}, {"350":[283, 285]}, {"351":[284, 282]}, {"352":[285, 284]}, {"353":[286, 285]}, {"354":[286, 288]}, {"355":[287, 285]}, {"356":[288, 287]}, {"357":[289, 288]}, {"358":[290, 289]}, {"359":[291, 290]}, {"360":[292, 291]}, {"361":[293, 292]}, {"362":[293, 295]}, {"363":[294, 292]}, {"364":[295, 294]}, {"365":[296, 295]}, {"366":[296, 298]}, {"367":[297, 295]}, {"368":[298, 297]}, {"369":[299, 298]}, {"370":[300, 299]}, {"371":[301, 300]}, {"372":[301, 238]}, {"373":[302, 301]}, {"374":[303, 302]}, {"375":[304, 303]}, {"376":[305, 304]}, {"377":[305, 307]}, {"378":[306, 304]}, {"379":[307, 306]}, {"380":[308, 307]}, {"381":[308, 310]}, {"382":[309, 307]}, {"383":[310, 309]}, {"384":[311, 310]}, {"385":[312, 311]}, {"386":[313, 312]}, {"387":[314, 313]}, {"388":[315, 314]}, {"389":[315, 317]}, {"390":[316, 314]}, {"391":[317, 316]}, {"392":[318, 317]}, {"393":[318, 320]}, {"394":[319, 317]}, {"395":[320, 319]}, {"396":[321, 320]}, {"397":[322, 321]}, {"398":[323, 322]}, {"399":[323, 258]}, {"400":[324, 323]}, {"401":[325, 324]}, {"402":[325, 260]}, {"403":[327, 326]}, {"404":[327, 329]}, {"405":[328, 326]}, {"406":[329, 328]}, {"407":[330, 329]}, {"408":[330, 332]}, {"409":[331, 329]}, {"410":[332, 331]}, {"411":[333, 332]}, {"412":[333, 335]}, {"413":[334, 332]}, {"414":[335, 334]}, {"415":[336, 335]}, {"416":[336, 268]}, {"417":[337, 336]}, {"418":[338, 337]}, {"419":[338, 340]}, {"420":[339, 337]}, {"421":[340, 339]}, {"422":[341, 340]}, {"423":[341, 343]}, {"424":[342, 340]}, {"425":[343, 342]}, {"426":[344, 343]}, {"427":[344, 346]}, {"428":[345, 343]}, {"429":[346, 345]}, {"430":[347, 346]}, {"431":[348, 347]}, {"432":[349, 348]}, {"433":[350, 349]}, {"434":[351, 350]}, {"435":[352, 351]}, {"436":[353, 352]}, {"437":[353, 355]}, {"438":[354, 352]}, {"439":[355, 354]}, {"440":[356, 355]}, {"441":[356, 358]}, {"442":[357, 355]}, {"443":[358, 357]}, {"444":[359, 358]}, {"445":[359, 361]}, {"446":[360, 358]}, {"447":[361, 360]}, {"448":[362, 361]}, {"449":[362, 290]}, {"450":[363, 362]}, {"451":[364, 363]}, {"452":[364, 366]}, {"453":[365, 363]}, {"454":[366, 365]}, {"455":[367, 366]}, {"456":[367, 369]}, {"457":[368, 366]}, {"458":[369, 368]}, {"459":[370, 369]}, {"460":[370, 372]}, {"461":[371, 369]}, {"462":[372, 371]}, {"463":[373, 372]}, {"464":[374, 373]}, {"465":[375, 374]}, {"466":[376, 375]}, {"467":[377, 376]}, {"468":[378, 377]}, {"469":[379, 378]}, {"470":[379, 381]}, {"471":[380, 378]}, {"472":[381, 380]}, {"473":[382, 381]}, {"474":[382, 384]}, {"475":[383, 381]}, {"476":[384, 383]}, {"477":[385, 384]}, {"478":[385, 387]}, {"479":[386, 384]}, {"480":[387, 386]}, {"481":[388, 387]}, {"482":[388, 312]}, {"483":[389, 388]}, {"484":[390, 389]}, {"485":[390, 392]}, {"486":[391, 389]}, {"487":[392, 391]}, {"488":[393, 392]}, {"489":[393, 395]}, {"490":[394, 392]}, {"491":[395, 394]}, {"492":[396, 395]}, {"493":[396, 398]}, {"494":[397, 395]}, {"495":[398, 397]}, {"496":[399, 398]}, {"497":[400, 399]}, {"498":[401, 400]}, {"499":[402, 401]}, {"500":[403, 402]}, {"501":[403, 326]}, {"502":[405, 404]}, {"503":[405, 407]}, {"504":[406, 404]}, {"505":[407, 406]}, {"506":[408, 407]}, {"507":[408, 410]}, {"508":[409, 407]}, {"509":[410, 409]}, {"510":[411, 410]}, {"511":[411, 413]}, {"512":[412, 410]}, {"513":[413, 412]}, {"514":[414, 413]}, {"515":[415, 414]}, {"516":[416, 415]}, {"517":[417, 416]}, {"518":[418, 417]}, {"519":[418, 420]}, {"520":[419, 417]}, {"521":[420, 419]}, {"522":[421, 420]}, {"523":[421, 423]}, {"524":[422, 420]}, {"525":[423, 422]}, {"526":[424, 423]}, {"527":[424, 426]}, {"528":[425, 423]}, {"529":[426, 425]}, {"530":[427, 426]}, {"531":[428, 427]}, {"532":[429, 428]}, {"533":[429, 349]}, {"534":[430, 429]}, {"535":[431, 430]}, {"536":[432, 431]}, {"537":[433, 432]}, {"538":[433, 435]}, {"539":[434, 432]}, {"540":[435, 434]}, {"541":[436, 435]}, {"542":[436, 438]}, {"543":[437, 435]}, {"544":[438, 437]}, {"545":[439, 438]}, {"546":[439, 441]}, {"547":[440, 438]}, {"548":[441, 440]}, {"549":[442, 441]}, {"550":[443, 442]}, {"551":[444, 443]}, {"552":[445, 444]}, {"553":[446, 445]}, {"554":[446, 448]}, {"555":[447, 445]}, {"556":[448, 447]}, {"557":[449, 448]}, {"558":[449, 451]}, {"559":[450, 448]}, {"560":[451, 450]}, {"561":[452, 451]}, {"562":[452, 454]}, {"563":[453, 451]}, {"564":[454, 453]}, {"565":[455, 454]}, {"566":[456, 455]}, {"567":[457, 456]}, {"568":[457, 375]}, {"569":[458, 457]}, {"570":[459, 458]}, {"571":[460, 459]}, {"572":[461, 460]}, {"573":[461, 463]}, {"574":[462, 460]}, {"575":[463, 462]}, {"576":[464, 463]}, {"577":[464, 466]}, {"578":[465, 463]}, {"579":[466, 465]}, {"580":[467, 466]}, {"581":[467, 469]}, {"582":[468, 466]}, {"583":[469, 468]}, {"584":[470, 469]}, {"585":[471, 470]}, {"586":[472, 471]}, {"587":[473, 472]}, {"588":[474, 473]}, {"589":[474, 476]}, {"590":[475, 473]}, {"591":[476, 475]}, {"592":[477, 476]}, {"593":[477, 479]}, {"594":[478, 476]}, {"595":[479, 478]}, {"596":[480, 479]}, {"597":[480, 482]}, {"598":[481, 479]}, {"599":[482, 481]}, {"600":[483, 482]}, {"601":[484, 483]}, {"602":[485, 484]}, {"603":[485, 401]}, {"604":[486, 485]}, {"605":[487, 486]}, {"606":[487, 404]}, {"607":[489, 488]}, {"608":[489, 491]}, {"609":[490, 488]}, {"610":[491, 490]}, {"611":[492, 491]}, {"612":[492, 494]}, {"613":[493, 491]}, {"614":[494, 493]}, {"615":[495, 494]}, {"616":[495, 497]}, {"617":[496, 494]}, {"618":[497, 496]}, {"619":[498, 497]}, {"620":[498, 500]}, {"621":[499, 497]}, {"622":[500, 499]}, {"623":[501, 500]}, {"624":[501, 415]}, {"625":[502, 501]}, {"626":[503, 502]}, {"627":[503, 505]}, {"628":[504, 502]}, {"629":[505, 504]}, {"630":[506, 505]}, {"631":[506, 508]}, {"632":[507, 505]}, {"633":[508, 507]}, {"634":[509, 508]}, {"635":[509, 511]}, {"636":[510, 508]}, {"637":[511, 510]}, {"638":[512, 511]}, {"639":[512, 514]}, {"640":[513, 511]}, {"641":[514, 513]}, {"642":[515, 514]}, {"643":[516, 515]}, {"644":[517, 516]}, {"645":[518, 517]}, {"646":[519, 518]}, {"647":[520, 519]}, {"648":[521, 520]}, {"649":[521, 523]}, {"650":[522, 520]}, {"651":[523, 522]}, {"652":[524, 523]}, {"653":[524, 526]}, {"654":[525, 523]}, {"655":[526, 525]}, {"656":[527, 526]}, {"657":[527, 529]}, {"658":[528, 526]}, {"659":[529, 528]}, {"660":[530, 529]}, {"661":[530, 532]}, {"662":[531, 529]}, {"663":[532, 531]}, {"664":[533, 532]}, {"665":[533, 443]}, {"666":[534, 533]}, {"667":[535, 534]}, {"668":[535, 537]}, {"669":[536, 534]}, {"670":[537, 536]}, {"671":[538, 537]}, {"672":[538, 540]}, {"673":[539, 537]}, {"674":[540, 539]}, {"675":[541, 540]}, {"676":[541, 543]}, {"677":[542, 540]}, {"678":[543, 542]}, {"679":[544, 543]}, {"680":[544, 546]}, {"681":[545, 543]}, {"682":[546, 545]}, {"683":[547, 546]}, {"684":[548, 547]}, {"685":[549, 548]}, {"686":[550, 549]}, {"687":[551, 550]}, {"688":[552, 551]}, {"689":[553, 552]}, {"690":[553, 555]}, {"691":[554, 552]}, {"692":[555, 554]}, {"693":[556, 555]}, {"694":[556, 558]}, {"695":[557, 555]}, {"696":[558, 557]}, {"697":[559, 558]}, {"698":[559, 561]}, {"699":[560, 558]}, {"700":[561, 560]}, {"701":[562, 561]}, {"702":[562, 564]}, {"703":[563, 561]}, {"704":[564, 563]}, {"705":[565, 564]}, {"706":[565, 471]}, {"707":[566, 565]}, {"708":[567, 566]}, {"709":[567, 569]}, {"710":[568, 566]}, {"711":[569, 568]}, {"712":[570, 569]}, {"713":[570, 572]}, {"714":[571, 569]}, {"715":[572, 571]}, {"716":[573, 572]}, {"717":[573, 575]}, {"718":[574, 572]}, {"719":[575, 574]}, {"720":[576, 575]}, {"721":[576, 578]}, {"722":[577, 575]}, {"723":[578, 577]}, {"724":[579, 578]}, {"725":[580, 579]}, {"726":[581, 580]}, {"727":[582, 581]}, {"728":[583, 582]}, {"729":[583, 488]}, {"730":[585, 584]}, {"731":[585, 587]}, {"732":[586, 584]}, {"733":[587, 586]}, {"734":[588, 587]}, {"735":[588, 590]}, {"736":[589, 587]}, {"737":[590, 589]}, {"738":[591, 590]}, {"739":[591, 593]}, {"740":[592, 590]}, {"741":[593, 592]}, {"742":[594, 593]}, {"743":[594, 596]}, {"744":[595, 593]}, {"745":[596, 595]}, {"746":[597, 596]}, {"747":[598, 597]}, {"748":[599, 598]}, {"749":[599, 601]}, {"750":[600, 598]}, {"751":[601, 600]}, {"752":[602, 601]}, {"753":[602, 604]}, {"754":[603, 601]}, {"755":[604, 603]}, {"756":[605, 604]}, {"757":[605, 607]}, {"758":[606, 604]}, {"759":[607, 606]}, {"760":[608, 607]}, {"761":[608, 610]}, {"762":[609, 607]}, {"763":[610, 609]}, {"764":[611, 610]}, {"765":[612, 611]}, {"766":[612, 614]}, {"767":[613, 611]}, {"768":[614, 613]}, {"769":[615, 614]}, {"770":[615, 517]}, {"771":[616, 615]}, {"772":[617, 616]}, {"773":[617, 619]}, {"774":[618, 616]}, {"775":[619, 618]}, {"776":[620, 619]}, {"777":[621, 620]}, {"778":[621, 623]}, {"779":[622, 620]}, {"780":[623, 622]}, {"781":[624, 623]}, {"782":[624, 626]}, {"783":[625, 623]}, {"784":[626, 625]}, {"785":[627, 626]}, {"786":[627, 629]}, {"787":[628, 626]}, {"788":[629, 628]}, {"789":[630, 629]}, {"790":[630, 632]}, {"791":[631, 629]}, {"792":[632, 631]}, {"793":[633, 632]}, {"794":[634, 633]}, {"795":[635, 634]}, {"796":[635, 637]}, {"797":[636, 634]}, {"798":[637, 636]}, {"799":[638, 637]}, {"800":[638, 640]}, {"801":[639, 637]}, {"802":[640, 639]}, {"803":[641, 640]}, {"804":[641, 643]}, {"805":[642, 640]}, {"806":[643, 642]}, {"807":[644, 643]}, {"808":[644, 646]}, {"809":[645, 643]}, {"810":[646, 645]}, {"811":[647, 646]}, {"812":[648, 647]}, {"813":[648, 650]}, {"814":[649, 647]}, {"815":[650, 649]}, {"816":[651, 650]}, {"817":[651, 549]}, {"818":[652, 651]}, {"819":[653, 652]}, {"820":[653, 655]}, {"821":[654, 652]}, {"822":[655, 654]}, {"823":[656, 655]}, {"824":[657, 656]}, {"825":[657, 659]}, {"826":[658, 656]}, {"827":[659, 658]}, {"828":[660, 659]}, {"829":[660, 662]}, {"830":[661, 659]}, {"831":[662, 661]}, {"832":[663, 662]}, {"833":[663, 665]}, {"834":[664, 662]}, {"835":[665, 664]}, {"836":[666, 665]}, {"837":[666, 668]}, {"838":[667, 665]}, {"839":[668, 667]}, {"840":[669, 668]}, {"841":[670, 669]}, {"842":[671, 670]}, {"843":[671, 673]}, {"844":[672, 670]}, {"845":[673, 672]}, {"846":[674, 673]}, {"847":[674, 676]}, {"848":[675, 673]}, {"849":[676, 675]}, {"850":[677, 676]}, {"851":[677, 679]}, {"852":[678, 676]}, {"853":[679, 678]}, {"854":[680, 679]}, {"855":[680, 682]}, {"856":[681, 679]}, {"857":[682, 681]}, {"858":[683, 682]}, {"859":[684, 683]}, {"860":[684, 686]}, {"861":[685, 683]}, {"862":[686, 685]}, {"863":[687, 686]}, {"864":[687, 581]}, {"865":[688, 687]}, {"866":[689, 688]}, {"867":[689, 691]}, {"868":[690, 688]}, {"869":[691, 690]}, {"870":[691, 584]}, {"871":[693, 692]}, {"872":[693, 695]}, {"873":[694, 692]}, {"874":[695, 694]}, {"875":[696, 695]}, {"876":[696, 698]}, {"877":[697, 695]}, {"878":[698, 697]}, {"879":[699, 698]}, {"880":[699, 701]}, {"881":[700, 698]}, {"882":[701, 700]}, {"883":[702, 701]}, {"884":[702, 704]}, {"885":[703, 701]}, {"886":[704, 703]}, {"887":[705, 704]}, {"888":[706, 705]}, {"889":[706, 597]}, {"890":[707, 706]}, {"891":[708, 707]}, {"892":[709, 708]}, {"893":[709, 711]}, {"894":[710, 708]}, {"895":[711, 710]}, {"896":[712, 711]}, {"897":[712, 714]}, {"898":[713, 711]}, {"899":[714, 713]}, {"900":[715, 714]}, {"901":[715, 717]}, {"902":[716, 714]}, {"903":[717, 716]}, {"904":[718, 717]}, {"905":[718, 720]}, {"906":[719, 717]}, {"907":[720, 719]}, {"908":[721, 720]}, {"909":[722, 721]}, {"910":[722, 724]}, {"911":[723, 721]}, {"912":[724, 723]}, {"913":[725, 724]}, {"914":[726, 725]}, {"915":[727, 726]}, {"916":[727, 729]}, {"917":[728, 726]}, {"918":[729, 728]}, {"919":[730, 729]}, {"920":[731, 730]}, {"921":[731, 733]}, {"922":[732, 730]}, {"923":[733, 732]}, {"924":[734, 733]}, {"925":[734, 736]}, {"926":[735, 733]}, {"927":[736, 735]}, {"928":[737, 736]}, {"929":[737, 739]}, {"930":[738, 736]}, {"931":[739, 738]}, {"932":[740, 739]}, {"933":[740, 742]}, {"934":[741, 739]}, {"935":[742, 741]}, {"936":[743, 742]}, {"937":[744, 743]}, {"938":[744, 633]}, {"939":[745, 744]}, {"940":[746, 745]}, {"941":[747, 746]}, {"942":[747, 749]}, {"943":[748, 746]}, {"944":[749, 748]}, {"945":[750, 749]}, {"946":[750, 752]}, {"947":[751, 749]}, {"948":[752, 751]}, {"949":[753, 752]}, {"950":[753, 755]}, {"951":[754, 752]}, {"952":[755, 754]}, {"953":[756, 755]}, {"954":[756, 758]}, {"955":[757, 755]}, {"956":[758, 757]}, {"957":[759, 758]}, {"958":[760, 759]}, {"959":[760, 762]}, {"960":[761, 759]}, {"961":[762, 761]}, {"962":[763, 762]}, {"963":[764, 763]}, {"964":[765, 764]}, {"965":[765, 767]}, {"966":[766, 764]}, {"967":[767, 766]}, {"968":[768, 767]}, {"969":[769, 768]}, {"970":[769, 771]}, {"971":[770, 768]}, {"972":[771, 770]}, {"973":[772, 771]}, {"974":[772, 774]}, {"975":[773, 771]}, {"976":[774, 773]}, {"977":[775, 774]}, {"978":[775, 777]}, {"979":[776, 774]}, {"980":[777, 776]}, {"981":[778, 777]}, {"982":[778, 780]}, {"983":[779, 777]}, {"984":[780, 779]}, {"985":[781, 780]}, {"986":[782, 781]}, {"987":[782, 669]}, {"988":[783, 782]}, {"989":[784, 783]}, {"990":[785, 784]}, {"991":[785, 787]}, {"992":[786, 784]}, {"993":[787, 786]}, {"994":[788, 787]}, {"995":[788, 790]}, {"996":[789, 787]}, {"997":[790, 789]}, {"998":[791, 790]}, {"999":[791, 793]}, {"1000":[792, 790]}, {"1001":[793, 792]}, {"1002":[794, 793]}, {"1003":[794, 796]}, {"1004":[795, 793]}, {"1005":[796, 795]}, {"1006":[797, 796]}, {"1007":[798, 797]}, {"1008":[798, 800]}, {"1009":[799, 797]}, {"1010":[800, 799]}, {"1011":[801, 800]}, {"1012":[802, 801]}, {"1013":[803, 802]}, {"1014":[803, 805]}, {"1015":[804, 802]}, {"1016":[805, 804]}, {"1017":[805, 692]}, {"1018":[807, 806]}, {"1019":[807, 809]}, {"1020":[808, 806]}, {"1021":[809, 808]}, {"1022":[810, 809]}, {"1023":[810, 812]}, {"1024":[811, 809]}, {"1025":[812, 811]}, {"1026":[813, 812]}, {"1027":[813, 815]}, {"1028":[814, 812]}, {"1029":[815, 814]}, {"1030":[816, 815]}, {"1031":[816, 818]}, {"1032":[817, 815]}, {"1033":[818, 817]}, {"1034":[819, 818]}, {"1035":[819, 821]}, {"1036":[820, 818]}, {"1037":[821, 820]}, {"1038":[822, 821]}, {"1039":[823, 822]}, {"1040":[824, 823]}, {"1041":[824, 826]}, {"1042":[825, 823]}, {"1043":[826, 825]}, {"1044":[827, 826]}, {"1045":[827, 829]}, {"1046":[828, 826]}, {"1047":[829, 828]}, {"1048":[830, 829]}, {"1049":[830, 832]}, {"1050":[831, 829]}, {"1051":[832, 831]}, {"1052":[833, 832]}, {"1053":[833, 835]}, {"1054":[834, 832]}, {"1055":[835, 834]}, {"1056":[836, 835]}, {"1057":[836, 838]}, {"1058":[837, 835]}, {"1059":[838, 837]}, {"1060":[839, 838]}, {"1061":[840, 839]}, {"1062":[840, 842]}, {"1063":[841, 839]}, {"1064":[842, 841]}, {"1065":[843, 842]}, {"1066":[843, 725]}, {"1067":[844, 843]}, {"1068":[845, 844]}, {"1069":[845, 847]}, {"1070":[846, 844]}, {"1071":[847, 846]}, {"1072":[848, 847]}, {"1073":[849, 848]}, {"1074":[849, 851]}, {"1075":[850, 848]}, {"1076":[851, 850]}, {"1077":[852, 851]}, {"1078":[852, 854]}, {"1079":[853, 851]}, {"1080":[854, 853]}, {"1081":[855, 854]}, {"1082":[855, 857]}, {"1083":[856, 854]}, {"1084":[857, 856]}, {"1085":[858, 857]}, {"1086":[858, 860]}, {"1087":[859, 857]}, {"1088":[860, 859]}, {"1089":[861, 860]}, {"1090":[861, 863]}, {"1091":[862, 860]}, {"1092":[863, 862]}, {"1093":[864, 863]}, {"1094":[865, 864]}, {"1095":[866, 865]}, {"1096":[866, 868]}, {"1097":[867, 865]}, {"1098":[868, 867]}, {"1099":[869, 868]}, {"1100":[869, 871]}, {"1101":[870, 868]}, {"1102":[871, 870]}, {"1103":[872, 871]}, {"1104":[872, 874]}, {"1105":[873, 871]}, {"1106":[874, 873]}, {"1107":[875, 874]}, {"1108":[875, 877]}, {"1109":[876, 874]}, {"1110":[877, 876]}, {"1111":[878, 877]}, {"1112":[878, 880]}, {"1113":[879, 877]}, {"1114":[880, 879]}, {"1115":[881, 880]}, {"1116":[882, 881]}, {"1117":[882, 884]}, {"1118":[883, 881]}, {"1119":[884, 883]}, {"1120":[885, 884]}, {"1121":[885, 763]}, {"1122":[886, 885]}, {"1123":[887, 886]}, {"1124":[887, 889]}, {"1125":[888, 886]}, {"1126":[889, 888]}, {"1127":[890, 889]}, {"1128":[891, 890]}, {"1129":[891, 893]}, {"1130":[892, 890]}, {"1131":[893, 892]}, {"1132":[894, 893]}, {"1133":[894, 896]}, {"1134":[895, 893]}, {"1135":[896, 895]}, {"1136":[897, 896]}, {"1137":[897, 899]}, {"1138":[898, 896]}, {"1139":[899, 898]}, {"1140":[900, 899]}, {"1141":[900, 902]}, {"1142":[901, 899]}, {"1143":[902, 901]}, {"1144":[903, 902]}, {"1145":[903, 905]}, {"1146":[904, 902]}, {"1147":[905, 904]}, {"1148":[906, 905]}, {"1149":[907, 906]}, {"1150":[908, 907]}, {"1151":[908, 910]}, {"1152":[909, 907]}, {"1153":[910, 909]}, {"1154":[911, 910]}, {"1155":[911, 913]}, {"1156":[912, 910]}, {"1157":[913, 912]}, {"1158":[914, 913]}, {"1159":[914, 916]}, {"1160":[915, 913]}, {"1161":[916, 915]}, {"1162":[917, 916]}, {"1163":[917, 919]}, {"1164":[918, 916]}, {"1165":[919, 918]}, {"1166":[920, 919]}, {"1167":[920, 922]}, {"1168":[921, 919]}, {"1169":[922, 921]}, {"1170":[923, 922]}, {"1171":[924, 923]}, {"1172":[924, 926]}, {"1173":[925, 923]}, {"1174":[926, 925]}, {"1175":[927, 926]}, {"1176":[927, 801]}, {"1177":[928, 927]}, {"1178":[929, 928]}, {"1179":[929, 931]}, {"1180":[930, 928]}, {"1181":[931, 930]}, {"1182":[931, 806]}, {"1183":[933, 932]}, {"1184":[933, 935]}, {"1185":[934, 932]}, {"1186":[935, 934]}, {"1187":[936, 935]}, {"1188":[936, 938]}, {"1189":[937, 935]}, {"1190":[938, 937]}, {"1191":[939, 938]}, {"1192":[939, 941]}, {"1193":[940, 938]}, {"1194":[941, 940]}, {"1195":[942, 941]}, {"1196":[942, 944]}, {"1197":[943, 941]}, {"1198":[944, 943]}, {"1199":[945, 944]}, {"1200":[945, 947]}, {"1201":[946, 944]}, {"1202":[947, 946]}, {"1203":[948, 947]}, {"1204":[949, 948]}, {"1205":[949, 822]}, {"1206":[950, 949]}, {"1207":[951, 950]}, {"1208":[952, 951]}, {"1209":[952, 954]}, {"1210":[953, 951]}, {"1211":[954, 953]}, {"1212":[955, 954]}, {"1213":[955, 957]}, {"1214":[956, 954]}, {"1215":[957, 956]}, {"1216":[958, 957]}, {"1217":[958, 960]}, {"1218":[959, 957]}, {"1219":[960, 959]}, {"1220":[961, 960]}, {"1221":[961, 963]}, {"1222":[962, 960]}, {"1223":[963, 962]}, {"1224":[964, 963]}, {"1225":[964, 966]}, {"1226":[965, 963]}, {"1227":[966, 965]}, {"1228":[967, 966]}, {"1229":[968, 967]}, {"1230":[968, 970]}, {"1231":[969, 967]}, {"1232":[970, 969]}, {"1233":[971, 970]}, {"1234":[972, 971]}, {"1235":[973, 972]}, {"1236":[973, 975]}, {"1237":[974, 972]}, {"1238":[975, 974]}, {"1239":[976, 975]}, {"1240":[977, 976]}, {"1241":[977, 979]}, {"1242":[978, 976]}, {"1243":[979, 978]}, {"1244":[980, 979]}, {"1245":[980, 982]}, {"1246":[981, 979]}, {"1247":[982, 981]}, {"1248":[983, 982]}, {"1249":[983, 985]}, {"1250":[984, 982]}, {"1251":[985, 984]}, {"1252":[986, 985]}, {"1253":[986, 988]}, {"1254":[987, 985]}, {"1255":[988, 987]}, {"1256":[989, 988]}, {"1257":[989, 991]}, {"1258":[990, 988]}, {"1259":[991, 990]}, {"1260":[992, 991]}, {"1261":[993, 992]}, {"1262":[993, 864]}, {"1263":[994, 993]}, {"1264":[995, 994]}, {"1265":[996, 995]}, {"1266":[996, 998]}, {"1267":[997, 995]}, {"1268":[998, 997]}, {"1269":[999, 998]}, {"1270":[999, 1001]}, {"1271":[1000, 998]}, {"1272":[1001, 1000]}, {"1273":[1002, 1001]}, {"1274":[1002, 1004]}, {"1275":[1003, 1001]}, {"1276":[1004, 1003]}, {"1277":[1005, 1004]}, {"1278":[1005, 1007]}, {"1279":[1006, 1004]}, {"1280":[1007, 1006]}, {"1281":[1008, 1007]}, {"1282":[1008, 1010]}, {"1283":[1009, 1007]}, {"1284":[1010, 1009]}, {"1285":[1011, 1010]}, {"1286":[1012, 1011]}, {"1287":[1012, 1014]}, {"1288":[1013, 1011]}, {"1289":[1014, 1013]}, {"1290":[1015, 1014]}, {"1291":[1016, 1015]}, {"1292":[1017, 1016]}, {"1293":[1017, 1019]}, {"1294":[1018, 1016]}, {"1295":[1019, 1018]}, {"1296":[1020, 1019]}, {"1297":[1021, 1020]}, {"1298":[1021, 1023]}, {"1299":[1022, 1020]}, {"1300":[1023, 1022]}, {"1301":[1024, 1023]}, {"1302":[1024, 1026]}, {"1303":[1025, 1023]}, {"1304":[1026, 1025]}, {"1305":[1027, 1026]}, {"1306":[1027, 1029]}, {"1307":[1028, 1026]}, {"1308":[1029, 1028]}, {"1309":[1030, 1029]}, {"1310":[1030, 1032]}, {"1311":[1031, 1029]}, {"1312":[1032, 1031]}, {"1313":[1033, 1032]}, {"1314":[1033, 1035]}, {"1315":[1034, 1032]}, {"1316":[1035, 1034]}, {"1317":[1036, 1035]}, {"1318":[1037, 1036]}, {"1319":[1037, 906]}, {"1320":[1038, 1037]}, {"1321":[1039, 1038]}, {"1322":[1040, 1039]}, {"1323":[1040, 1042]}, {"1324":[1041, 1039]}, {"1325":[1042, 1041]}, {"1326":[1043, 1042]}, {"1327":[1043, 1045]}, {"1328":[1044, 1042]}, {"1329":[1045, 1044]}, {"1330":[1046, 1045]}, {"1331":[1046, 1048]}, {"1332":[1047, 1045]}, {"1333":[1048, 1047]}, {"1334":[1049, 1048]}, {"1335":[1049, 1051]}, {"1336":[1050, 1048]}, {"1337":[1051, 1050]}, {"1338":[1052, 1051]}, {"1339":[1052, 1054]}, {"1340":[1053, 1051]}, {"1341":[1054, 1053]}, {"1342":[1055, 1054]}, {"1343":[1056, 1055]}, {"1344":[1056, 1058]}, {"1345":[1057, 1055]}, {"1346":[1058, 1057]}, {"1347":[1059, 1058]}, {"1348":[1060, 1059]}, {"1349":[1061, 1060]}, {"1350":[1061, 1063]}, {"1351":[1062, 1060]}, {"1352":[1063, 1062]}, {"1353":[1063, 932]}, {"1354":[1065, 1064]}, {"1355":[1065, 1067]}, {"1356":[1066, 1064]}, {"1357":[1067, 1066]}, {"1358":[1068, 1067]}, {"1359":[1068, 1070]}, {"1360":[1069, 1067]}, {"1361":[1070, 1069]}, {"1362":[1071, 1070]}, {"1363":[1071, 1073]}, {"1364":[1072, 1070]}, {"1365":[1073, 1072]}, {"1366":[1074, 1073]}, {"1367":[1074, 1076]}, {"1368":[1075, 1073]}, {"1369":[1076, 1075]}, {"1370":[1077, 1076]}, {"1371":[1077, 1079]}, {"1372":[1078, 1076]}, {"1373":[1079, 1078]}, {"1374":[1080, 1079]}, {"1375":[1081, 1080]}, {"1376":[1082, 1081]}, {"1377":[1083, 1082]}, {"1378":[1084, 1083]}, {"1379":[1084, 1086]}, {"1380":[1085, 1083]}, {"1381":[1086, 1085]}, {"1382":[1087, 1086]}, {"1383":[1087, 1089]}, {"1384":[1088, 1086]}, {"1385":[1089, 1088]}, {"1386":[1090, 1089]}, {"1387":[1090, 1092]}, {"1388":[1091, 1089]}, {"1389":[1092, 1091]}, {"1390":[1093, 1092]}, {"1391":[1093, 1095]}, {"1392":[1094, 1092]}, {"1393":[1095, 1094]}, {"1394":[1096, 1095]}, {"1395":[1096, 1098]}, {"1396":[1097, 1095]}, {"1397":[1098, 1097]}, {"1398":[1099, 1098]}, {"1399":[1100, 1099]}, {"1400":[1100, 1102]}, {"1401":[1101, 1099]}, {"1402":[1102, 1101]}, {"1403":[1103, 1102]}, {"1404":[1104, 1103]}, {"1405":[1104, 971]}, {"1406":[1105, 1104]}, {"1407":[1106, 1105]}, {"1408":[1107, 1106]}, {"1409":[1107, 1109]}, {"1410":[1108, 1106]}, {"1411":[1109, 1108]}, {"1412":[1110, 1109]}, {"1413":[1111, 1110]}, {"1414":[1111, 1113]}, {"1415":[1112, 1110]}, {"1416":[1113, 1112]}, {"1417":[1114, 1113]}, {"1418":[1114, 1116]}, {"1419":[1115, 1113]}, {"1420":[1116, 1115]}, {"1421":[1117, 1116]}, {"1422":[1117, 1119]}, {"1423":[1118, 1116]}, {"1424":[1119, 1118]}, {"1425":[1120, 1119]}, {"1426":[1120, 1122]}, {"1427":[1121, 1119]}, {"1428":[1122, 1121]}, {"1429":[1123, 1122]}, {"1430":[1123, 1125]}, {"1431":[1124, 1122]}, {"1432":[1125, 1124]}, {"1433":[1126, 1125]}, {"1434":[1127, 1126]}, {"1435":[1128, 1127]}, {"1436":[1129, 1128]}, {"1437":[1130, 1129]}, {"1438":[1130, 1132]}, {"1439":[1131, 1129]}, {"1440":[1132, 1131]}, {"1441":[1133, 1132]}, {"1442":[1133, 1135]}, {"1443":[1134, 1132]}, {"1444":[1135, 1134]}, {"1445":[1136, 1135]}, {"1446":[1136, 1138]}, {"1447":[1137, 1135]}, {"1448":[1138, 1137]}, {"1449":[1139, 1138]}, {"1450":[1139, 1141]}, {"1451":[1140, 1138]}, {"1452":[1141, 1140]}, {"1453":[1142, 1141]}, {"1454":[1142, 1144]}, {"1455":[1143, 1141]}, {"1456":[1144, 1143]}, {"1457":[1145, 1144]}, {"1458":[1146, 1145]}, {"1459":[1146, 1148]}, {"1460":[1147, 1145]}, {"1461":[1148, 1147]}, {"1462":[1149, 1148]}, {"1463":[1150, 1149]}, {"1464":[1150, 1015]}, {"1465":[1151, 1150]}, {"1466":[1152, 1151]}, {"1467":[1153, 1152]}, {"1468":[1153, 1155]}, {"1469":[1154, 1152]}, {"1470":[1155, 1154]}, {"1471":[1156, 1155]}, {"1472":[1157, 1156]}, {"1473":[1157, 1159]}, {"1474":[1158, 1156]}, {"1475":[1159, 1158]}, {"1476":[1160, 1159]}, {"1477":[1160, 1162]}, {"1478":[1161, 1159]}, {"1479":[1162, 1161]}, {"1480":[1163, 1162]}, {"1481":[1163, 1165]}, {"1482":[1164, 1162]}, {"1483":[1165, 1164]}, {"1484":[1166, 1165]}, {"1485":[1166, 1168]}, {"1486":[1167, 1165]}, {"1487":[1168, 1167]}, {"1488":[1169, 1168]}, {"1489":[1169, 1171]}, {"1490":[1170, 1168]}, {"1491":[1171, 1170]}, {"1492":[1172, 1171]}, {"1493":[1173, 1172]}, {"1494":[1174, 1173]}, {"1495":[1175, 1174]}, {"1496":[1176, 1175]}, {"1497":[1176, 1178]}, {"1498":[1177, 1175]}, {"1499":[1178, 1177]}, {"1500":[1179, 1178]}, {"1501":[1179, 1181]}, {"1502":[1180, 1178]}, {"1503":[1181, 1180]}, {"1504":[1182, 1181]}, {"1505":[1182, 1184]}, {"1506":[1183, 1181]}, {"1507":[1184, 1183]}, {"1508":[1185, 1184]}, {"1509":[1185, 1187]}, {"1510":[1186, 1184]}, {"1511":[1187, 1186]}, {"1512":[1188, 1187]}, {"1513":[1188, 1190]}, {"1514":[1189, 1187]}, {"1515":[1190, 1189]}, {"1516":[1191, 1190]}, {"1517":[1192, 1191]}, {"1518":[1192, 1194]}, {"1519":[1193, 1191]}, {"1520":[1194, 1193]}, {"1521":[1195, 1194]}, {"1522":[1196, 1195]}, {"1523":[1196, 1059]}, {"1524":[1197, 1196]}, {"1525":[1198, 1197]}, {"1526":[1199, 1198]}, {"1527":[1199, 1201]}, {"1528":[1200, 1198]}, {"1529":[1201, 1200]}, {"1530":[1201, 1064]}, {"1531":[1203, 1202]}, {"1532":[1203, 1205]}, {"1533":[1204, 1202]}, {"1534":[1205, 1204]}, {"1535":[1206, 1205]}, {"1536":[1206, 1208]}, {"1537":[1207, 1205]}, {"1538":[1208, 1207]}, {"1539":[1209, 1208]}, {"1540":[1209, 1211]}, {"1541":[1210, 1208]}, {"1542":[1211, 1210]}, {"1543":[1212, 1211]}, {"1544":[1212, 1214]}, {"1545":[1213, 1211]}, {"1546":[1214, 1213]}, {"1547":[1215, 1214]}, {"1548":[1215, 1217]}, {"1549":[1216, 1214]}, {"1550":[1217, 1216]}, {"1551":[1218, 1217]}, {"1552":[1218, 1220]}, {"1553":[1219, 1217]}, {"1554":[1220, 1219]}, {"1555":[1221, 1220]}, {"1556":[1221, 1081]}, {"1557":[1222, 1221]}, {"1558":[1223, 1222]}, {"1559":[1223, 1225]}, {"1560":[1224, 1222]}, {"1561":[1225, 1224]}, {"1562":[1226, 1225]}, {"1563":[1226, 1228]}, {"1564":[1227, 1225]}, {"1565":[1228, 1227]}, {"1566":[1229, 1228]}, {"1567":[1229, 1231]}, {"1568":[1230, 1228]}, {"1569":[1231, 1230]}, {"1570":[1232, 1231]}, {"1571":[1232, 1234]}, {"1572":[1233, 1231]}, {"1573":[1234, 1233]}, {"1574":[1235, 1234]}, {"1575":[1235, 1237]}, {"1576":[1236, 1234]}, {"1577":[1237, 1236]}, {"1578":[1238, 1237]}, {"1579":[1238, 1240]}, {"1580":[1239, 1237]}, {"1581":[1240, 1239]}, {"1582":[1241, 1240]}, {"1583":[1242, 1241]}, {"1584":[1242, 1244]}, {"1585":[1243, 1241]}, {"1586":[1244, 1243]}, {"1587":[1245, 1244]}, {"1588":[1247, 1246]}, {"1589":[1248, 1247]}, {"1590":[1248, 1250]}, {"1591":[1249, 1247]}, {"1592":[1250, 1249]}, {"1593":[1251, 1250]}, {"1594":[1252, 1251]}, {"1595":[1252, 1254]}, {"1596":[1253, 1251]}, {"1597":[1254, 1253]}, {"1598":[1255, 1254]}, {"1599":[1255, 1257]}, {"1600":[1256, 1254]}, {"1601":[1257, 1256]}, {"1602":[1258, 1257]}, {"1603":[1258, 1260]}, {"1604":[1259, 1257]}, {"1605":[1260, 1259]}, {"1606":[1261, 1260]}, {"1607":[1261, 1263]}, {"1608":[1262, 1260]}, {"1609":[1263, 1262]}, {"1610":[1264, 1263]}, {"1611":[1264, 1266]}, {"1612":[1265, 1263]}, {"1613":[1266, 1265]}, {"1614":[1267, 1266]}, {"1615":[1267, 1269]}, {"1616":[1268, 1266]}, {"1617":[1269, 1268]}, {"1618":[1270, 1269]}, {"1619":[1270, 1127]}, {"1620":[1271, 1270]}, {"1621":[1272, 1271]}, {"1622":[1272, 1274]}, {"1623":[1273, 1271]}, {"1624":[1274, 1273]}, {"1625":[1275, 1274]}, {"1626":[1275, 1277]}, {"1627":[1276, 1274]}, {"1628":[1277, 1276]}, {"1629":[1278, 1277]}, {"1630":[1278, 1280]}, {"1631":[1279, 1277]}, {"1632":[1280, 1279]}, {"1633":[1281, 1280]}, {"1634":[1281, 1283]}, {"1635":[1282, 1280]}, {"1636":[1283, 1282]}, {"1637":[1284, 1283]}, {"1638":[1284, 1286]}, {"1639":[1285, 1283]}, {"1640":[1286, 1285]}, {"1641":[1287, 1286]}, {"1642":[1287, 1289]}, {"1643":[1288, 1286]}, {"1644":[1289, 1288]}, {"1645":[1290, 1289]}, {"1646":[1291, 1290]}, {"1647":[1291, 1293]}, {"1648":[1292, 1290]}, {"1649":[1293, 1292]}, {"1650":[1294, 1293]}, {"1651":[1296, 1295]}, {"1652":[1297, 1296]}, {"1653":[1297, 1299]}, {"1654":[1298, 1296]}, {"1655":[1299, 1298]}, {"1656":[1300, 1299]}, {"1657":[1301, 1300]}, {"1658":[1301, 1303]}, {"1659":[1302, 1300]}, {"1660":[1303, 1302]}, {"1661":[1304, 1303]}, {"1662":[1304, 1306]}, {"1663":[1305, 1303]}, {"1664":[1306, 1305]}, {"1665":[1307, 1306]}, {"1666":[1307, 1309]}, {"1667":[1308, 1306]}, {"1668":[1309, 1308]}, {"1669":[1310, 1309]}, {"1670":[1310, 1312]}, {"1671":[1311, 1309]}, {"1672":[1312, 1311]}, {"1673":[1313, 1312]}, {"1674":[1313, 1315]}, {"1675":[1314, 1312]}, {"1676":[1315, 1314]}, {"1677":[1316, 1315]}, {"1678":[1316, 1318]}, {"1679":[1317, 1315]}, {"1680":[1318, 1317]}, {"1681":[1319, 1318]}, {"1682":[1319, 1173]}, {"1683":[1320, 1319]}, {"1684":[1321, 1320]}, {"1685":[1321, 1323]}, {"1686":[1322, 1320]}, {"1687":[1323, 1322]}, {"1688":[1324, 1323]}, {"1689":[1324, 1326]}, {"1690":[1325, 1323]}, {"1691":[1326, 1325]}, {"1692":[1327, 1326]}, {"1693":[1327, 1329]}, {"1694":[1328, 1326]}, {"1695":[1329, 1328]}, {"1696":[1330, 1329]}, {"1697":[1330, 1332]}, {"1698":[1331, 1329]}, {"1699":[1332, 1331]}, {"1700":[1333, 1332]}, {"1701":[1333, 1335]}, {"1702":[1334, 1332]}, {"1703":[1335, 1334]}, {"1704":[1336, 1335]}, {"1705":[1336, 1338]}, {"1706":[1337, 1335]}, {"1707":[1338, 1337]}, {"1708":[1339, 1338]}, {"1709":[1340, 1339]}, {"1710":[1340, 1342]}, {"1711":[1341, 1339]}, {"1712":[1342, 1341]}, {"1713":[1343, 1342]}, {"1714":[1345, 1344]}, {"1715":[1346, 1345]}, {"1716":[1346, 1348]}, {"1717":[1347, 1345]}, {"1718":[1348, 1347]}, {"1719":[1348, 1202]}]};
			
			wizard.levelGraphNodeTypes = {
				"Is1": { //x
					"name": ICE1["name"],
					"tooltip": "Unlocks Ice Magic Rank 1. Ice spells are slow but very efficient.",
					"flavorText": function(){ return getSpell("ice1").extendedTooltip.body; },
					"setupFunction": function() {},
					"alwaysAvailable": true,
					"loadFunction": function(){ unlockSpellAndBelowRanks("ice", 1); },
					"purchaseFunction": function() { unlockSpellAndBelowRanks("ice", 1); },
					"icon": "iceRank1"
				},
				"Is2": { //x
					"name": ICE2["name"],
					"tooltip": "Unlocks Ice Magic Ranks 1-2. Ice spells are slow but very efficient." ,
					"flavorText": function(){ return getSpell("ice2").extendedTooltip.body; },
					"setupFunction": function() {},
					"loadFunction": function(){ unlockSpellAndBelowRanks("ice", 2); },
					"purchaseFunction": function() {unlockSpellAndBelowRanks("ice", 2);},
					"icon": "iceRank1"
				},
				"Is3": { //x
					"name": ICE3["name"],
					"tooltip": "Unlocks Ice Magic Ranks 1-3. Ice spells are slow but very efficient." ,
					"flavorText": function(){ return getSpell("ice3").extendedTooltip.body; },
					"setupFunction": function() {},
					"loadFunction": function(){ unlockSpellAndBelowRanks("ice", 3); },
					"purchaseFunction": function() {unlockSpellAndBelowRanks("ice", 3);},
					"icon": "iceRank1"
				},
				"Is4": { //x
					"name": ICE4["name"],
					"tooltip": "Unlocks Ice Magic Ranks 1-4. Ice spells are slow but very efficient." ,
					"flavorText": function(){ return getSpell("ice4").extendedTooltip.body; },
					"setupFunction": function() {},
					"loadFunction": function(){ unlockSpellAndBelowRanks("ice", 4); },
					"purchaseFunction": function() {unlockSpellAndBelowRanks("ice", 4);},
					"icon": "iceRank1"
				},
				"Is5": { //x
					"name": ICE5["name"],
					"tooltip": "Unlocks Ice Magic Ranks 1-5. Ice spells are slow but very efficient." ,
					"flavorText": function(){ return getSpell("ice5").extendedTooltip.body; },
					"setupFunction": function() {},
					"loadFunction": function(){ unlockSpellAndBelowRanks("ice", 5); },
					"purchaseFunction": function() {unlockSpellAndBelowRanks("ice", 5);},
					"icon": "iceRank1"
				},
				"Is6": { //x
					"name": ICE6["name"],
					"tooltip": "Unlocks Ice Magic Ranks 1-6. Ice spells are slow but very efficient." ,
					"flavorText": function(){ return getSpell("ice6").extendedTooltip.body; },
					"setupFunction": function() {},
					"loadFunction": function(){ unlockSpellAndBelowRanks("ice", 6); },
					"purchaseFunction": function() {unlockSpellAndBelowRanks("ice", 6);},
					"icon": "iceRank1"
				},
				"Is7": { //x
					"name": ICE7["name"],
					"tooltip": "Unlocks Ice Magic Ranks 1-7. Ice spells are slow but very efficient." ,
					"flavorText": function(){ return getSpell("ice7").extendedTooltip.body; },
					"setupFunction": function() {},
					"loadFunction": function(){ unlockSpellAndBelowRanks("ice", 7); },
					"purchaseFunction": function() {unlockSpellAndBelowRanks("ice", 7); },
					"icon": "iceRank1"
				},
				"Is8": { //x
					"name": ICE8["name"],
					"tooltip": "Unlocks Ice Magic Ranks 1-8. Ice spells are slow but very efficient." ,
					"flavorText": function(){ return getSpell("ice8").extendedTooltip.body; },
					"setupFunction": function() {},
					"loadFunction": function(){ unlockSpellAndBelowRanks("ice", 8); },
					"purchaseFunction": function() {unlockSpellAndBelowRanks("ice", 8); },
					"icon": "iceRank1"
				},
				"Is9": { //x
					"name": ICE9["name"],
					"tooltip": "Unlocks Ice Magic Ranks 1-9. Ice spells are slow but very efficient." ,
					"flavorText": function(){ return getSpell("ice9").extendedTooltip.body; },
					"setupFunction": function() {},
					"loadFunction": function(){ unlockSpellAndBelowRanks("ice", 9); },
					"purchaseFunction": function() {unlockSpellAndBelowRanks("ice", 9); },
					"icon": "iceRank1"
				},
				"Ls1": { //x
					"name": LIGHTNING1["name"],
					"tooltip": "Unlocks Lightning Magic Rank 1. Lightning spells are quick and empowered the next two click attacks by 50% of the spell's damage and reduce their energy cost to 0." ,
					"flavorText": function(){ return getSpell("lightning1").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("lightning", 1); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("lightning", 1); },
					"icon": "lightningRank1"
				},
				"Ls2": { //x
					"name": LIGHTNING2["name"],
					"tooltip": "Unlocks Lightning Magic Ranks 1-2. Lightning spells are quick and empowered the next two click attacks by 50% of the spell's damage and reduce their energy cost to 0." ,
					"flavorText": function(){ return getSpell("lightning2").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("lightning", 2); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("lightning", 2); },
					"icon": "lightningRank1"
				},
				"Ls3": { //x
					"name": LIGHTNING3["name"],
					"tooltip": "Unlocks Lightning Magic Ranks 1-3. Lightning spells are quick and empowered the next two click attacks by 50% of the spell's damage and reduce their energy cost to 0." ,
					"flavorText": function(){ return getSpell("lightning3").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("lightning", 3); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("lightning", 3); },
					"icon": "lightningRank1"
				},
				"Ls4": { //x
					"name": LIGHTNING4["name"],
					"tooltip": "Unlocks Lightning Magic Ranks 1-4. Lightning spells are quick and empowered the next two click attacks by 50% of the spell's damage and reduce their energy cost to 0." ,
					"flavorText": function(){ return getSpell("lightning4").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("lightning", 4); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("lightning", 4); },
					"icon": "lightningRank1"
				},
				"Ls5": { //x
					"name": LIGHTNING5["name"],
					"tooltip": "Unlocks Lightning Magic Ranks 1-5. Lightning spells are quick and empowered the next two click attacks by 50% of the spell's damage and reduce their energy cost to 0." ,
					"flavorText": function(){ return getSpell("lightning5").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("lightning", 5); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("lightning", 5); },
					"icon": "lightningRank1"
				},
				"Ls6": { //x
					"name": LIGHTNING6["name"],
					"tooltip": "Unlocks Lightning Magic Ranks 1-6. Lightning spells are quick and empowered the next two click attacks by 50% of the spell's damage and reduce their energy cost to 0." ,
					"flavorText": function(){ return getSpell("lightning6").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("lightning", 6); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("lightning", 6); },
					"icon": "lightningRank1"
				},
				"Ls7": { //x
					"name": LIGHTNING7["name"],
					"tooltip": "Unlocks Lightning Magic Ranks 1-7. Lightning spells are quick and empowered the next two click attacks by 50% of the spell's damage and reduce their energy cost to 0." ,
					"flavorText": function(){ return getSpell("lightning7").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("lightning", 7); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("lightning", 7); },
					"icon": "lightningRank1"
				},
				"Ls8": { //x
					"name": LIGHTNING8["name"],
					"tooltip": "Unlocks Lightning Magic Ranks 1-8. Lightning spells are quick and empowered the next two click attacks by 50% of the spell's damage and reduce their energy cost to 0." ,
					"flavorText": function(){ return getSpell("lightning8").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("lightning", 8); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("lightning", 8); },
					"icon": "lightningRank1"
				},
				"Ls9": { //x
					"name": LIGHTNING9["name"],
					"tooltip": "Unlocks Lightning Magic Ranks 1-9. Lightning spells are quick and empowered the next two click attacks by 50% of the spell's damage and reduce their energy cost to 0." ,
					"flavorText": function(){ return getSpell("lightning9").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("lightning", 9); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("lightning", 9); },
					"icon": "lightningRank1"
				},
				"Fs1": { //x
					"name": FIRE1["name"],
					"tooltip": "Unlocks Fire Magic Rank 1. Fire spells are highly destructive, dealing additional burn damage equivalent to the spell's damage." ,
					"flavorText": function(){ return getSpell("fire1").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("fire", 1); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("fire", 1); },
					"icon": "fireRank1"
				},
				"Fs2": { //x
					"name": FIRE2["name"],
					"tooltip": "Unlocks Fire Magic Ranks 1-2. Fire spells are highly destructive, dealing additional burn damage equivalent to the spell's damage." ,
					"flavorText": function(){ return getSpell("fire2").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("fire", 2); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("fire", 2); },
					"icon": "fireRank1"
				},
				"Fs3": { //x
					"name": FIRE3["name"],
					"tooltip": "Unlocks Fire Magic Ranks 1-3. Fire spells are highly destructive, dealing additional burn damage equivalent to the spell's damage." ,
					"flavorText": function(){ return getSpell("fire3").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("fire", 3); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("fire", 3); },
					"icon": "fireRank1"
				},
				"Fs4": { //x
					"name": FIRE4["name"],
					"tooltip": "Unlocks Fire Magic Ranks 1-4. Fire spells are highly destructive, dealing additional burn damage equivalent to the spell's damage." ,
					"flavorText": function(){ return getSpell("fire4").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("fire", 4); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("fire", 4); },
					"icon": "fireRank1"
				},
				"Fs5": { //x
					"name": FIRE5["name"],
					"tooltip": "Unlocks Fire Magic Ranks 1-5. Fire spells are highly destructive, dealing additional burn damage equivalent to the spell's damage." ,
					"flavorText": function(){ return getSpell("fire5").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("fire", 5); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("fire", 5); },
					"icon": "fireRank1"
				},
				"Fs6": { //x
					"name": FIRE6["name"],
					"tooltip": "Unlocks Fire Magic Ranks 1-6. Fire spells are highly destructive, dealing additional burn damage equivalent to the spell's damage." ,
					"flavorText": function(){ return getSpell("fire6").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("fire", 6); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("fire", 6); },
					"icon": "fireRank1"
				},
				"Fs7": { //x
					"name": FIRE7["name"],
					"tooltip": "Unlocks Fire Magic Ranks 1-7. Fire spells are highly destructive, dealing additional burn damage equivalent to the spell's damage." ,
					"flavorText": function(){ return getSpell("fire7").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("fire", 7); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("fire", 7); },
					"icon": "fireRank1"
				},
				"Fs8": { //x
					"name": FIRE8["name"],
					"tooltip": "Unlocks Fire Magic Ranks 1-8. Fire spells are highly destructive, dealing additional burn damage equivalent to the spell's damage." ,
					"flavorText": function(){ return getSpell("fire8").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("fire", 8); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("fire", 8); },
					"icon": "fireRank1"
				},
				"Fs9": { //x
					"name": FIRE9["name"],
					"tooltip": "Unlocks Fire Magic Ranks 1-9. Fire spells are highly destructive, dealing additional burn damage equivalent to the spell's damage." ,
					"flavorText": function(){ return getSpell("fire9").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpellAndBelowRanks("fire", 9); },
					"setupFunction": function() {},
					"purchaseFunction": function() { unlockSpellAndBelowRanks("fire", 9); },
					"icon": "fireRank1"
				},
				"Ia1": { //x
					"name": "Ice: Crit Chance 1",
					"tooltip": "Increases your chance to score a critical hit with Ice Spells by "+ICE_CRIT_PERCENT_CHANCE+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", ICE_CRIT_PERCENT_CHANCE/100); },
					"icon": "iceCritChance1"
				},
				"Ia2": { //x 												// Generally, higher ranks multiply base amount by rank
					"name": "Ice: Crit Chance 2",
					"tooltip": "Increases your chance to score a critical hit with Ice Spells by "+ (1.2 * ICE_CRIT_PERCENT_CHANCE) +"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", 1.2* ICE_CRIT_PERCENT_CHANCE/100); },
					"icon": "iceCritChance1"
				},
				"Ia3": { //x
					"name": "Ice: Crit Chance 3",
					"tooltip": "Increases your chance to score a critical hit with Ice Spells by "+ (1.4* ICE_CRIT_PERCENT_CHANCE) +"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", 1.4* ICE_CRIT_PERCENT_CHANCE/100); },
					"icon": "iceCritChance1"
				},
				"Ia4": { //x
					"name": "Ice: Crit Chance 4",
					"tooltip": "Increases your chance to score a critical hit with Ice Spells by "+ (1.6* ICE_CRIT_PERCENT_CHANCE) +"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", 1.6* ICE_CRIT_PERCENT_CHANCE/100); },
					"icon": "iceCritChance1"
				},
				"Ia5": { //x
					"name": "Ice: Crit Chance 5",
					"tooltip": "Increases your chance to score a critical hit with Ice Spells by "+ (1.8* ICE_CRIT_PERCENT_CHANCE) +"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", 1.8* ICE_CRIT_PERCENT_CHANCE/100); },
					"icon": "iceCritChance1"
				},
				"Ia6": { //x
					"name": "Ice: Crit Chance 6",
					"tooltip": "Increases your chance to score a critical hit with Ice Spells by "+ (2.0* ICE_CRIT_PERCENT_CHANCE) +"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", 2.0* ICE_CRIT_PERCENT_CHANCE/100); },
					"icon": "iceCritChance1"
				},
				"Ia7": { //x
					"name": "Ice: Crit Chance 7",
					"tooltip": "Increases your chance to score a critical hit with Ice Spells by "+ (2.2* ICE_CRIT_PERCENT_CHANCE) +"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", 2.2* ICE_CRIT_PERCENT_CHANCE/100); },
					"icon": "iceCritChance1"
				},
				"Ia8": { //x
					"name": "Ice: Crit Chance 8",
					"tooltip": "Increases your chance to score a critical hit with Ice Spells by "+ (2.4* ICE_CRIT_PERCENT_CHANCE) +"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", 2.4* ICE_CRIT_PERCENT_CHANCE/100); },
					"icon": "iceCritChance1"
				},
				"Ia9": { //x
					"name": "Ice: Crit Chance 9",
					"tooltip": "Increases your chance to score a critical hit with Ice Spells by "+ (2.6* ICE_CRIT_PERCENT_CHANCE) +"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", 2.6* ICE_CRIT_PERCENT_CHANCE/100); },
					"icon": "iceCritChance1"
				},
				"Ib1": { //x
					"name": "Ice: Crit Damage 1",
					"tooltip": "Increases the damage of your critical hits with Ice Spells by "+ICE_CRIT_DAMAGE_PERCENT+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", ICE_CRIT_DAMAGE_PERCENT/100); },
					"icon": "wizCritDamage1"
				},
				"Ib2": { //x
					"name": "Ice: Crit Damage 2",
					"tooltip": "Increases the damage of your critical hits with Ice Spells by "+(ICE_CRIT_DAMAGE_PERCENT*1.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (ICE_CRIT_DAMAGE_PERCENT*1.2)/100); },
					"icon": "wizCritDamage1"
				},
				"Ib3": { //x
					"name": "Ice: Crit Damage 3",
					"tooltip": "Increases the damage of your critical hits with Ice Spells by "+(ICE_CRIT_DAMAGE_PERCENT*1.4)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (ICE_CRIT_DAMAGE_PERCENT*1.4)/100); },
					"icon": "wizCritDamage1"
				},
				"Ib4": { //x
					"name": "Ice: Crit Damage 4",
					"tooltip": "Increases the damage of your critical hits with Ice Spells by "+(ICE_CRIT_DAMAGE_PERCENT*1.6)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (ICE_CRIT_DAMAGE_PERCENT*1.6)/100); },
					"icon": "wizCritDamage1"
				},
				"Ib5": { //x
					"name": "Ice: Crit Damage 5",
					"tooltip": "Increases the damage of your critical hits with Ice Spells by "+(ICE_CRIT_DAMAGE_PERCENT*1.8)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (ICE_CRIT_DAMAGE_PERCENT*1.8)/100); },
					"icon": "wizCritDamage1"
				},
				"Ib6": { //x
					"name": "Ice: Crit Damage 6",
					"tooltip": "Increases the damage of your critical hits with Ice Spells by "+(ICE_CRIT_DAMAGE_PERCENT*2.0)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (ICE_CRIT_DAMAGE_PERCENT*2.0)/100); },
					"icon": "wizCritDamage1"
				},
				"Ib7": { //x
					"name": "Ice: Crit Damage 7",
					"tooltip": "Increases the damage of your critical hits with Ice Spells by "+(ICE_CRIT_DAMAGE_PERCENT*2.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (ICE_CRIT_DAMAGE_PERCENT*2.2)/100); },
					"icon": "wizCritDamage1"
				},
				"Ib8": { //x
					"name": "Ice: Crit Damage 8",
					"tooltip": "Increases the damage of your critical hits with Ice Spells by "+(ICE_CRIT_DAMAGE_PERCENT*2.4)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (ICE_CRIT_DAMAGE_PERCENT*2.4)/100); },
					"icon": "wizCritDamage1"
				},
				"Ib9": { //x
					"name": "Ice: Crit Damage 9",
					"tooltip": "Increases the damage of your critical hits with Ice Spells by "+(ICE_CRIT_DAMAGE_PERCENT*2.6)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (ICE_CRIT_DAMAGE_PERCENT*2.6)/100); },
					"icon": "wizCritDamage1"
				},
				"Ic1": { //x
					"name": "Ice: Damage 1",
					"tooltip": "Increases the damage of Ice Spells by "+ICE_ADDITIONAL_PERCENT_DAMAGE+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", ICE_ADDITIONAL_PERCENT_DAMAGE/100); },
					"icon": "iceDamage1"
				},
				"Ic2": { //x
					"name": "Ice: Damage 2",
					"tooltip": "Increases the damage of Ice Spells by "+(ICE_ADDITIONAL_PERCENT_DAMAGE*1.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (ICE_ADDITIONAL_PERCENT_DAMAGE*1.2)/100); },
					"icon": "iceDamage1"
				},
				"Ic3": { //x
					"name": "Ice: Damage 3",
					"tooltip": "Increases the damage of Ice Spells by "+(ICE_ADDITIONAL_PERCENT_DAMAGE*1.4)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (ICE_ADDITIONAL_PERCENT_DAMAGE*1.4)/100); },
					"icon": "iceDamage1"
				},
				"Ic4": { //x
					"name": "Ice: Damage 4",
					"tooltip": "Increases the damage of Ice Spells by "+(ICE_ADDITIONAL_PERCENT_DAMAGE*1.6)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (ICE_ADDITIONAL_PERCENT_DAMAGE*1.6)/100); },
					"icon": "iceDamage1"
				},
				"Ic5": { //x
					"name": "Ice: Damage 5",
					"tooltip": "Increases the damage of Ice Spells by "+(ICE_ADDITIONAL_PERCENT_DAMAGE*1.8)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (ICE_ADDITIONAL_PERCENT_DAMAGE*1.8)/100); },
					"icon": "iceDamage1"
				},
				"Ic6": { //x
					"name": "Ice: Damage 6",
					"tooltip": "Increases the damage of Ice Spells by "+(ICE_ADDITIONAL_PERCENT_DAMAGE*2.0)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (ICE_ADDITIONAL_PERCENT_DAMAGE*2.0)/100); },
					"icon": "iceDamage1"
				},
				"Ic7": { //x
					"name": "Ice: Damage 7",
					"tooltip": "Increases the damage of Ice Spells by "+(ICE_ADDITIONAL_PERCENT_DAMAGE*2.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (ICE_ADDITIONAL_PERCENT_DAMAGE*2.2)/100); },
					"icon": "iceDamage1"
				},
				"Ic8": { //x
					"name": "Ice: Damage 8",
					"tooltip": "Increases the damage of Ice Spells by "+(ICE_ADDITIONAL_PERCENT_DAMAGE*2.4)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (ICE_ADDITIONAL_PERCENT_DAMAGE*2.4)/100); },
					"icon": "iceDamage1"
				},
				"Ic9": { //x
					"name": "Ice: Damage 9",
					"tooltip": "Increases the damage of Ice Spells by "+(ICE_ADDITIONAL_PERCENT_DAMAGE*2.6)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (ICE_ADDITIONAL_PERCENT_DAMAGE*2.6)/100); },
					"icon": "iceDamage1"
				},
				"La1": { //x
					"name": "Lightning: Zap 1",
					"tooltip": "After casting a Lightning spell, your next 2 clicks attacks are increased by "+LIGHTNING_ZAP_PERCENT_DAMAGE+"% and cost no energy." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", LIGHTNING_ZAP_PERCENT_DAMAGE/100); },
					"icon": "lightningZapps"
				},
				"La2": { //x
					"name": "Lightning: Zap 2",
					"tooltip": "After casting a Lightning spell, your next 2 clicks attacks are increased by "+LIGHTNING_ZAP_PERCENT_DAMAGE+"% and cost no energy." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (LIGHTNING_ZAP_PERCENT_DAMAGE*1.2)/100); },
					"icon": "lightningZapps"
				},
				"La3": { //x
					"name": "Lightning: Zap 3",
					"tooltip": "After casting a Lightning spell, your next 2 clicks attacks are increased by "+(LIGHTNING_ZAP_PERCENT_DAMAGE*1.4)+"% and cost no energy." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (LIGHTNING_ZAP_PERCENT_DAMAGE*1.4)/100); },
					"icon": "lightningZapps"
				},
				"La4": { //x
					"name": "Lightning: Zap 4",
					"tooltip": "After casting a Lightning spell, your next 2 clicks attacks are increased by "+(LIGHTNING_ZAP_PERCENT_DAMAGE*1.6)+"% and cost no energy." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (LIGHTNING_ZAP_PERCENT_DAMAGE*1.6)/100); },
					"icon": "lightningZapps"
				},
				"La5": { //x
					"name": "Lightning: Zap 5",
					"tooltip": "After casting a Lightning spell, your next 2 clicks attacks are increased by "+(LIGHTNING_ZAP_PERCENT_DAMAGE*1.8)+"% and cost no energy." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (LIGHTNING_ZAP_PERCENT_DAMAGE*1.8)/100); },
					"icon": "lightningZapps"
				},
				"La6": { //x
					"name": "Lightning: Zap 6",
					"tooltip": "After casting a Lightning spell, your next 2 clicks attacks are increased by "+(LIGHTNING_ZAP_PERCENT_DAMAGE*2.0)+"% and cost no energy." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (LIGHTNING_ZAP_PERCENT_DAMAGE*2.0)/100); },
					"icon": "lightningZapps"
				},
				"La7": { //x
					"name": "Lightning: Zap 7",
					"tooltip": "After casting a Lightning spell, your next 2 clicks attacks are increased by "+(LIGHTNING_ZAP_PERCENT_DAMAGE*2.2)+"% and cost no energy." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (LIGHTNING_ZAP_PERCENT_DAMAGE*2.2)/100); },
					"icon": "lightningZapps"
				},
				"La8": { //x
					"name": "Lightning: Zap 8",
					"tooltip": "After casting a Lightning spell, your next 2 clicks attacks are increased by "+(LIGHTNING_ZAP_PERCENT_DAMAGE*2.4)+"% and cost no energy." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (LIGHTNING_ZAP_PERCENT_DAMAGE*2.4)/100); },
					"icon": "lightningZapps"
				},
				"La9": { //x
					"name": "Lightning: Zap 9",
					"tooltip": "After casting a Lightning spell, your next 2 clicks attacks are increased by "+(LIGHTNING_ZAP_PERCENT_DAMAGE*2.6)+"% and cost no energy." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (LIGHTNING_ZAP_PERCENT_DAMAGE*2.6)/100); },
					"icon": "lightningZapps"
				},
				"Lb1": { //x
					"name": "Lightning: Chain 1",
					"tooltip": "Increases the chance that your Lightning Spells will hit an additional monster by "+LIGHTNING_CHAIN_PERCENT+"%." ,
					"flavorText": "This effect can hit additional monsters after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", LIGHTNING_CHAIN_PERCENT/100); },
					"icon": "lightningChain1"
				},
				"Lb2": { //x
					"name": "Lightning: Chain 2",
					"tooltip": "Increases the chance that your Lightning Spells will hit an additional monster by "+(LIGHTNING_CHAIN_PERCENT*1.2)+"%." ,
					"flavorText": "This effect can hit additional monsters after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (LIGHTNING_CHAIN_PERCENT*1.2)/100); },
					"icon": "lightningChain1"
				},
				"Lb3": { //x
					"name": "Lightning: Chain 3",
					"tooltip": "Increases the chance that your Lightning Spells will hit an additional monster by "+(LIGHTNING_CHAIN_PERCENT*1.4)+"%." ,
					"flavorText": "This effect can hit additional monsters after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (LIGHTNING_CHAIN_PERCENT*1.4)/100); },
					"icon": "lightningChain1"
				},
				"Lb4": { //x
					"name": "Lightning: Chain 4",
					"tooltip": "Increases the chance that your Lightning Spells will hit an additional monster by "+(LIGHTNING_CHAIN_PERCENT*1.6)+"%." ,
					"flavorText": "This effect can hit additional monsters after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (LIGHTNING_CHAIN_PERCENT*1.6)/100); },
					"icon": "lightningChain1"
				},
				"Lb5": { //x
					"name": "Lightning: Chain 5",
					"tooltip": "Increases the chance that your Lightning Spells will hit an additional monster by "+(LIGHTNING_CHAIN_PERCENT*1.8)+"%." ,
					"flavorText": "This effect can hit additional monsters after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (LIGHTNING_CHAIN_PERCENT*1.8)/100); },
					"icon": "lightningChain1"
				},
				"Lb6": { //x
					"name": "Lightning: Chain 6",
					"tooltip": "Increases the chance that your Lightning Spells will hit an additional monster by "+(LIGHTNING_CHAIN_PERCENT*2.0)+"%." ,
					"flavorText": "This effect can hit additional monsters after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (LIGHTNING_CHAIN_PERCENT*2.0)/100); },
					"icon": "lightningChain1"
				},
				"Lb7": { //x
					"name": "Lightning: Chain 7",
					"tooltip": "Increases the chance that your Lightning Spells will hit an additional monster by "+(LIGHTNING_CHAIN_PERCENT*2.2)+"%." ,
					"flavorText": "This effect can hit additional monsters after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (LIGHTNING_CHAIN_PERCENT*2.2)/100); },
					"icon": "lightningChain1"
				},
				"Lb8": { //x
					"name": "Lightning: Chain 8",
					"tooltip": "Increases the chance that your Lightning Spells will hit an additional monster by "+(LIGHTNING_CHAIN_PERCENT*2.4)+"%." ,
					"flavorText": "This effect can hit additional monsters after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (LIGHTNING_CHAIN_PERCENT*2.4)/100); },
					"icon": "lightningChain1"
				},
				"Lb9": { //x
					"name": "Lightning: Chain 9",
					"tooltip": "Increases the chance that your Lightning Spells will hit an additional monster by "+(LIGHTNING_CHAIN_PERCENT*2.6)+"%." ,
					"flavorText": "This effect can hit additional monsters after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (LIGHTNING_CHAIN_PERCENT*2.6)/100); },
					"icon": "lightningChain1"
				},
				"Lc1": { //x
					"name": "Lightning: Damage 1",
					"tooltip": "Increases the damage of Lightning Spells by "+LIGHTNING_ADDITIONAL_PERCENT_DAMAGE+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100); },
					"icon": "lightningDamage1"
				},
				"Lc2": { //x
					"name": "Lightning: Damage 2",
					"tooltip": "Increases the damage of Lightning Spells by "+(LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*1.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*1.2)/100); },
					"icon": "lightningDamage1"
				},
				"Lc3": { //x
					"name": "Lightning: Damage 3",
					"tooltip": "Increases the damage of Lightning Spells by "+(LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*1.4)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*1.4)/100); },
					"icon": "lightningDamage1"
				},
				"Lc4": { //x
					"name": "Lightning: Damage 4",
					"tooltip": "Increases the damage of Lightning Spells by "+(LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*1.6)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*1.6)/100); },
					"icon": "lightningDamage1"
				},
				"Lc5": { //x
					"name": "Lightning: Damage 5",
					"tooltip": "Increases the damage of Lightning Spells by "+(LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*1.8)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*1.8)/100); },
					"icon": "lightningDamage1"
				},
				"Lc6": { //x
					"name": "Lightning: Damage 6",
					"tooltip": "Increases the damage of Lightning Spells by "+(LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*2.0)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*2.0)/100); },
					"icon": "lightningDamage1"
				},
				"Lc7": { //x
					"name": "Lightning: Damage 7",
					"tooltip": "Increases the damage of Lightning Spells by "+(LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*2.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*2.2)/100); },
					"icon": "lightningDamage1"
				},
				"Lc8": { //x
					"name": "Lightning: Damage 8",
					"tooltip": "Increases the damage of Lightning Spells by "+(LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*2.4)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*2.4)/100); },
					"icon": "lightningDamage1"
				},
				"Lc9": { //x
					"name": "Lightning: Damage 9",
					"tooltip": "Increases the damage of Lightning Spells by "+(LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*2.6)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*2.6)/100); },
					"icon": "lightningDamage1"
				},
				"Fa1": { //x
					"name": "Fire: Corrosion 1",
					"tooltip": "Increases all damage taken by monsters by "+FIRE_CORROSION_PERCENT_DAMAGE_INCREASE+"% after being hit by a Fire spell until a monster is killed." ,
					"flavorText": "Stacks with similar effects but not with itself.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", FIRE_CORROSION_PERCENT_DAMAGE_INCREASE/100); },
					"icon": "fireCorrosion1"
				},
				"Fa2": { //x
					"name": "Fire: Corrosion 2",
					"tooltip": "Increases all damage taken by monsters by "+(FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*1.2)+"% after being hit by a Fire spell until a monster is killed." ,
					"flavorText": "Stacks with similar effects but not with itself.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*1.2)/100); },
					"icon": "fireCorrosion1"
				},
				"Fa3": { //x
					"name": "Fire: Corrosion 3",
					"tooltip": "Increases all damage taken by monsters by "+(FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*1.4)+"% after being hit by a Fire spell until a monster is killed." ,
					"flavorText": "Stacks with similar effects but not with itself.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*1.4)/100); },
					"icon": "fireCorrosion1"
				},
				"Fa4": { //x
					"name": "Fire: Corrosion 4",
					"tooltip": "Increases all damage taken by monsters by "+(FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*1.6)+"% after being hit by a Fire spell until a monster is killed." ,
					"flavorText": "Stacks with similar effects but not with itself.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*1.6)/100); },
					"icon": "fireCorrosion1"
				},
				"Fa5": { //x
					"name": "Fire: Corrosion 5",
					"tooltip": "Increases all damage taken by monsters by "+(FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*1.8)+"% after being hit by a Fire spell until a monster is killed." ,
					"flavorText": "Stacks with similar effects but not with itself.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*1.8)/100); },
					"icon": "fireCorrosion1"
				},
				"Fa6": { //x
					"name": "Fire: Corrosion 6",
					"tooltip": "Increases all damage taken by monsters by "+(FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*2.0)+"% after being hit by a Fire spell until a monster is killed." ,
					"flavorText": "Stacks with similar effects but not with itself.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*2.0)/100); },
					"icon": "fireCorrosion1"
				},
				"Fa7": { //x
					"name": "Fire: Corrosion 7",
					"tooltip": "Increases all damage taken by monsters by "+(FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*2.2)+"% after being hit by a Fire spell until a monster is killed." ,
					"flavorText": "Stacks with similar effects but not with itself.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*2.2)/100); },
					"icon": "fireCorrosion1"
				},
				"Fa8": { //x
					"name": "Fire: Corrosion 8",
					"tooltip": "Increases all damage taken by monsters by "+(FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*2.4)+"% after being hit by a Fire spell until a monster is killed." ,
					"flavorText": "Stacks with similar effects but not with itself.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*2.4)/100); },
					"icon": "fireCorrosion1"
				},
				"Fa9": { //x
					"name": "Fire: Corrosion 9",
					"tooltip": "Increases all damage taken by monsters by "+(FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*2.6)+"% after being hit by a Fire spell until a monster is killed." ,
					"flavorText": "Stacks with similar effects but not with itself.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (FIRE_CORROSION_PERCENT_DAMAGE_INCREASE*2.6)/100); },
					"icon": "fireCorrosion1"
				},
				"Fb1": { //x
					"name": "Fire: Burn 1",
					"tooltip": "Increases the damage over time of Fire Spells by "+FIRE_BURN_PERCENT_DAMAGE_INCREASE+"%." ,
					"flavorText": "Stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireBurnDamage", FIRE_BURN_PERCENT_DAMAGE_INCREASE/100); },
					"icon": "fireBurn1"
				},
				"Fb2": { //x
					"name": "Fire: Burn 2",
					"tooltip": "Increases the damage over time of Fire Spells by "+(FIRE_BURN_PERCENT_DAMAGE_INCREASE*1.2)+"%." ,
					"flavorText": "Stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireBurnDamage", (FIRE_BURN_PERCENT_DAMAGE_INCREASE*1.2)/100); },
					"icon": "fireBurn1"
				},
				"Fb3": { //x
					"name": "Fire: Burn 3",
					"tooltip": "Increases the damage over time of Fire Spells by "+(FIRE_BURN_PERCENT_DAMAGE_INCREASE*1.4)+"%." ,
					"flavorText": "Stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireBurnDamage", (FIRE_BURN_PERCENT_DAMAGE_INCREASE*1.4)/100); },
					"icon": "fireBurn1"
				},
				"Fb4": { //x
					"name": "Fire: Burn 4",
					"tooltip": "Increases the damage over time of Fire Spells by "+(FIRE_BURN_PERCENT_DAMAGE_INCREASE*1.6)+"%." ,
					"flavorText": "Stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireBurnDamage", (FIRE_BURN_PERCENT_DAMAGE_INCREASE*1.6)/100); },
					"icon": "fireBurn1"
				},
				"Fb5": { //x
					"name": "Fire: Burn 5",
					"tooltip": "Increases the damage over time of Fire Spells by "+(FIRE_BURN_PERCENT_DAMAGE_INCREASE*1.8)+"%." ,
					"flavorText": "Stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireBurnDamage", (FIRE_BURN_PERCENT_DAMAGE_INCREASE*1.8)/100); },
					"icon": "fireBurn1"
				},
				"Fb6": { //x
					"name": "Fire: Burn 6",
					"tooltip": "Increases the damage over time of Fire Spells by "+(FIRE_BURN_PERCENT_DAMAGE_INCREASE*2.0)+"%." ,
					"flavorText": "Stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireBurnDamage", (FIRE_BURN_PERCENT_DAMAGE_INCREASE*2.0)/100); },
					"icon": "fireBurn1"
				},
				"Fb7": { //x
					"name": "Fire: Burn 7",
					"tooltip": "Increases the damage over time of Fire Spells by "+(FIRE_BURN_PERCENT_DAMAGE_INCREASE*2.2)+"%." ,
					"flavorText": "Stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireBurnDamage", (FIRE_BURN_PERCENT_DAMAGE_INCREASE*2.2)/100); },
					"icon": "fireBurn1"
				},
				"Fb8": { //x
					"name": "Fire: Burn 8",
					"tooltip": "Increases the damage over time of Fire Spells by "+(FIRE_BURN_PERCENT_DAMAGE_INCREASE*2.4)+"%." ,
					"flavorText": "Stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireBurnDamage", (FIRE_BURN_PERCENT_DAMAGE_INCREASE*2.4)/100); },
					"icon": "fireBurn1"
				},
				"Fb9": { //x
					"name": "Fire: Burn 9",
					"tooltip": "Increases the damage over time of Fire Spells by "+(FIRE_BURN_PERCENT_DAMAGE_INCREASE*2.6)+"%." ,
					"flavorText": "Stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireBurnDamage", (FIRE_BURN_PERCENT_DAMAGE_INCREASE*2.6)/100); },
					"icon": "fireBurn1"
				},
				"Fc1": { //x
					"name": "Fire: Damage 1",
					"tooltip": "Increases the damage of Fire Spells by "+FIRE_ADDITIONAL_PERCENT_DAMAGE+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", FIRE_ADDITIONAL_PERCENT_DAMAGE/100); },
					"icon": "fireDamage1"
				},
				"Fc2": { //x
					"name": "Fire: Damage 2",
					"tooltip": "Increases the damage of Fire Spells by "+(FIRE_ADDITIONAL_PERCENT_DAMAGE*1.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (FIRE_ADDITIONAL_PERCENT_DAMAGE*1.2)/100); },
					"icon": "fireDamage1"
				},
				"Fc3": { //x
					"name": "Fire: Damage 3",
					"tooltip": "Increases the damage of Fire Spells by "+(FIRE_ADDITIONAL_PERCENT_DAMAGE*1.4)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (FIRE_ADDITIONAL_PERCENT_DAMAGE*1.4)/100); },
					"icon": "fireDamage1"
				},
				"Fc4": { //x
					"name": "Fire: Damage 4",
					"tooltip": "Increases the damage of Fire Spells by "+(FIRE_ADDITIONAL_PERCENT_DAMAGE*1.6)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (FIRE_ADDITIONAL_PERCENT_DAMAGE*1.6)/100); },
					"icon": "fireDamage1"
				},
				"Fc5": { //x
					"name": "Fire: Damage 5",
					"tooltip": "Increases the damage of Fire Spells by "+(FIRE_ADDITIONAL_PERCENT_DAMAGE*1.8)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (FIRE_ADDITIONAL_PERCENT_DAMAGE*1.8)/100); },
					"icon": "fireDamage1"
				},
				"Fc6": { //x
					"name": "Fire: Damage 6",
					"tooltip": "Increases the damage of Fire Spells by "+(FIRE_ADDITIONAL_PERCENT_DAMAGE*2.0)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (FIRE_ADDITIONAL_PERCENT_DAMAGE*2.0)/100); },
					"icon": "fireDamage1"
				},
				"Fc7": { //x
					"name": "Fire: Damage 7",
					"tooltip": "Increases the damage of Fire Spells by "+(FIRE_ADDITIONAL_PERCENT_DAMAGE*2.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (FIRE_ADDITIONAL_PERCENT_DAMAGE*2.2)/100); },
					"icon": "fireDamage1"
				},
				"Fc8": { //x
					"name": "Fire: Damage 8",
					"tooltip": "Increases the damage of Fire Spells by "+(FIRE_ADDITIONAL_PERCENT_DAMAGE*2.4)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (FIRE_ADDITIONAL_PERCENT_DAMAGE*2.4)/100); },
					"icon": "fireDamage1"
				},
				"Fc9": { //x
					"name": "Fire: Damage 9",
					"tooltip": "Increases the damage of Fire Spells by "+(FIRE_ADDITIONAL_PERCENT_DAMAGE*2.6)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (FIRE_ADDITIONAL_PERCENT_DAMAGE*2.6)/100); },
					"icon": "fireDamage1"
				},
				"Id1": { //x
					"name": "Ice: Cost Reduction 1",
					"tooltip": "Increases the chance of cost reduction from Ice spells by "+ICE_COST_REDUCTION_PERCENT_CHANCE+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", ICE_COST_REDUCTION_PERCENT_CHANCE); },
					"icon": "iceCostReduction"
				},
				"Id2": { //x
					"name": "Ice: Cost Reduction 2",
					"tooltip": "Increases the chance of cost reduction from Ice spells by "+(1.2*ICE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (1.2*ICE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceCostReduction"
				},
				"Id3": { //x
					"name": "Ice: Cost Reduction 3",
					"tooltip": "Increases the chance of cost reduction from Ice spells by "+(1.4*ICE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (1.4*ICE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceCostReduction"
				},
				"Id4": { //x
					"name": "Ice: Cost Reduction 4",
					"tooltip": "Increases the chance of cost reduction from Ice spells by "+(1.6*ICE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (1.6*ICE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceCostReduction"
				},
				"Id5": { //x
					"name": "Ice: Cost Reduction 5",
					"tooltip": "Increases the chance of cost reduction from Ice spells by "+(1.8*ICE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (1.8*ICE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceCostReduction"
				},
				"Id6": { //x
					"name": "Ice: Cost Reduction 6",
					"tooltip": "Increases the chance of cost reduction from Ice spells by "+(2.0*ICE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (2.0*ICE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceCostReduction"
				},
				"Id7": { //x
					"name": "Ice: Cost Reduction 7",
					"tooltip": "Increases the chance of cost reduction from Ice spells by "+(2.2*ICE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (2.2*ICE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceCostReduction"
				},
				"Id8": { //x
					"name": "Ice: Cost Reduction 8",
					"tooltip": "Increases the chance of cost reduction from Ice spells by "+(2.4*ICE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (2.4*ICE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceCostReduction"
				},
				"Id9": { //x
					"name": "Ice: Cost Reduction 9",
					"tooltip": "Increases the chance of cost reduction from Ice spells by "+(2.6*ICE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (2.6*ICE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceCostReduction"
				},
				"Ld1": { //x
					"name": "Lightning: Cost Reduction 1",
					"tooltip": "Increases the chance of cost reduction from Lightning spells by "+LIGHTNING_COST_REDUCTION_PERCENT_CHANCE+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", LIGHTNING_COST_REDUCTION_PERCENT_CHANCE); },
					"icon": "lightningCostReduction"
				},
				"Ld2": { //x
					"name": "Lightning: Cost Reduction 2",
					"tooltip": "Increases the chance of cost reduction from Lightning spells by "+(1.2*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (1.2*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningCostReduction"
				},
				"Ld3": { //x
					"name": "Lightning: Cost Reduction 3",
					"tooltip": "Increases the chance of cost reduction from Lightning spells by "+(1.4*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (1.4*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningCostReduction"
				},
				"Ld4": { //x
					"name": "Lightning: Cost Reduction 4",
					"tooltip": "Increases the chance of cost reduction from Lightning spells by "+(1.6*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (1.6*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningCostReduction"
				},
				"Ld5": { //x
					"name": "Lightning: Cost Reduction 5",
					"tooltip": "Increases the chance of cost reduction from Lightning spells by "+(1.8*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (1.8*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningCostReduction"
				},
				"Ld6": { //x
					"name": "Lightning: Cost Reduction 6",
					"tooltip": "Increases the chance of cost reduction from Lightning spells by "+(2.0*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (2.0*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningCostReduction"
				},
				"Ld7": { //x
					"name": "Lightning: Cost Reduction 7",
					"tooltip": "Increases the chance of cost reduction from Lightning spells by "+(2.2*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (2.2*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningCostReduction"
				},
				"Ld8": { //x
					"name": "Lightning: Cost Reduction 8",
					"tooltip": "Increases the chance of cost reduction from Lightning spells by "+(2.4*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (2.4*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningCostReduction"
				},
				"Ld9": { //x
					"name": "Lightning: Cost Reduction 9",
					"tooltip": "Increases the chance of cost reduction from Lightning spells by "+(2.6*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (2.6*LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningCostReduction"
				},
				"Fd1": { //x
					"name": "Fire: Cost Reduction 1",
					"tooltip": "Increases the chance of cost reduction from Fire spells by "+FIRE_COST_REDUCTION_PERCENT_CHANCE+"%." ,
					"flavorText": "Cost reduction lowers the cost of Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCostReductionPercentChance", FIRE_COST_REDUCTION_PERCENT_CHANCE); },
					"icon": "fireCostReduction"
				},
				"Fd2": { //x
					"name": "Fire: Cost Reduction 2",
					"tooltip": "Increases the chance of cost reduction from Fire spells by "+(1.2*FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (1.2*FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "fireCostReduction"
				},
				"Fd3": { //x
					"name": "Fire: Cost Reduction 3",
					"tooltip": "Increases the chance of cost reduction from Fire spells by "+(1.4*FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (1.4*FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "fireCostReduction"
				},
				"Fd4": { //x
					"name": "Fire: Cost Reduction 4",
					"tooltip": "Increases the chance of cost reduction from Fire spells by "+(1.6*FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (1.6*FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "fireCostReduction"
				},
				"Fd5": { //x
					"name": "Fire: Cost Reduction 5",
					"tooltip": "Increases the chance of cost reduction from Fire spells by "+(1.8*FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (1.8*FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "fireCostReduction"
				},
				"Fd6": { //x
					"name": "Fire: Cost Reduction 6",
					"tooltip": "Increases the chance of cost reduction from Fire spells by "+(2.0*FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (2.0*FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "fireCostReduction"
				},
				"Fd7": { //x
					"name": "Fire: Cost Reduction 7",
					"tooltip": "Increases the chance of cost reduction from Fire spells by "+(2.2*FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (2.2*FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "fireCostReduction"
				},
				"Fd8": { //x
					"name": "Fire: Cost Reduction 8",
					"tooltip": "Increases the chance of cost reduction from Fire spells by "+(2.4*FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (2.4*FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "fireCostReduction"
				},
				"Fd9": { //x
					"name": "Fire: Cost Reduction 9",
					"tooltip": "Increases the chance of cost reduction from Fire spells by "+(2.6*FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (2.6*FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "fireCostReduction"
				},
				"Md1": { //x
					"name": "Ice and Lightning: Cost Reduction 1",
					"tooltip": "Increases the chance of cost reduction from Ice and Lightning spells by "+ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE); CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE); },
					"icon": "iceLightningCostReduction"
				},
				"Md2": { //x
					"name": "Ice and Lightning: Cost Reduction 2",
					"tooltip": "Increases the chance of cost reduction from Ice and Lightning spells by "+(1.2*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (1.2*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (1.2*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceLightningCostReduction"
				},
				"Md3": { //x
					"name": "Ice and Lightning: Cost Reduction 3",
					"tooltip": "Increases the chance of cost reduction from Ice and Lightning spells by "+(1.4*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (1.4*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (1.4*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceLightningCostReduction"
				},
				"Md4": { //x
					"name": "Ice and Lightning: Cost Reduction 4",
					"tooltip": "Increases the chance of cost reduction from Ice and Lightning spells by "+(1.6*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (1.6*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (1.6*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceLightningCostReduction"
				},
				"Md5": { //x
					"name": "Ice and Lightning: Cost Reduction 5",
					"tooltip": "Increases the chance of cost reduction from Ice and Lightning spells by "+(1.8*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (1.8*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (1.8*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceLightningCostReduction"
				},
				"Md6": { //x
					"name": "Ice and Lightning: Cost Reduction 6",
					"tooltip": "Increases the chance of cost reduction from Ice and Lightning spells by "+(2.0*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (2.0*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (2.0*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceLightningCostReduction"
				},
				"Md7": { //x
					"name": "Ice and Lightning: Cost Reduction 7",
					"tooltip": "Increases the chance of cost reduction from Ice and Lightning spells by "+(2.2*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (2.2*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (2.2*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceLightningCostReduction"
				},
				"Md8": { //x
					"name": "Ice and Lightning: Cost Reduction 8",
					"tooltip": "Increases the chance of cost reduction from Ice and Lightning spells by "+(2.4*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (2.4*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (2.4*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceLightningCostReduction"
				},
				"Md9": { //x
					"name": "Ice and Lightning: Cost Reduction 9",
					"tooltip": "Increases the chance of cost reduction from Ice and Lightning spells by "+(2.6*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Lightning spells by 5 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (2.6*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (2.6*ICE_LIGHTNING_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "iceLightningCostReduction"
				},
				"Nd1": { //x
					"name": "Lightning and Fire: Cost Reduction 1",
					"tooltip": "Increases the chance of cost reduction from Lightning and Fire spells by "+LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE); },
					"icon": "lightningFireCostReduction"
				},
				"Nd2": { //x
					"name": "Lightning and Fire: Cost Reduction 2",
					"tooltip": "Increases the chance of cost reduction from Lightning and Fire spells by "+(1.2*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (1.2*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (1.2*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningFireCostReduction"
				},
				"Nd3": { //x
					"name": "Lightning and Fire: Cost Reduction 3",
					"tooltip": "Increases the chance of cost reduction from Lightning and Fire spells by "+(1.4*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (1.4*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (1.4*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningFireCostReduction"
				},
				"Nd4": { //x
					"name": "Lightning and Fire: Cost Reduction 4",
					"tooltip": "Increases the chance of cost reduction from Lightning and Fire spells by "+(1.6*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (1.6*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (1.6*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningFireCostReduction"
				},
				"Nd5": { //x
					"name": "Lightning and Fire: Cost Reduction 5",
					"tooltip": "Increases the chance of cost reduction from Lightning and Fire spells by "+(1.8*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (1.8*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (1.8*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningFireCostReduction"
				},
				"Nd6": { //x
					"name": "Lightning and Fire: Cost Reduction 6",
					"tooltip": "Increases the chance of cost reduction from Lightning and Fire spells by "+(2.0*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (2.0*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (2.0*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningFireCostReduction"
				},
				"Nd7": { //x
					"name": "Lightning and Fire: Cost Reduction 7",
					"tooltip": "Increases the chance of cost reduction from Lightning and Fire spells by "+(2.2*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (2.2*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (2.2*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningFireCostReduction"
				},
				"Nd8": { //x
					"name": "Lightning and Fire: Cost Reduction 8",
					"tooltip": "Increases the chance of cost reduction from Lightning and Fire spells by "+(2.4*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (2.4*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (2.4*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningFireCostReduction"
				},
				"Nd9": { //x
					"name": "Lightning and Fire: Cost Reduction 9",
					"tooltip": "Increases the chance of cost reduction from Lightning and Fire spells by "+(2.6*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Lightning spells by 5 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCostReductionPercentChance", (2.6*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (2.6*LIGHTNING_FIRE_COST_REDUCTION_PERCENT_CHANCE)); },
					"icon": "lightningFireCostReduction"
				},
				"Od1": { //x
					"name": "Ice and Fire: Cost Reduction 1",
					"tooltip": "Increases the chance of cost reduction from Ice and Fire spells by "+ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE);},
					"icon": "iceFireCostReduction"
				},
				"Od2": { //x
					"name": "Ice and Fire: Cost Reduction 2",
					"tooltip": "Increases the chance of cost reduction from Ice and Fire spells by "+(1.2*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (1.2*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (1.2*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE));},
					"icon": "iceFireCostReduction"
				},
				"Od3": { //x
					"name": "Ice and Fire: Cost Reduction 3",
					"tooltip": "Increases the chance of cost reduction from Ice and Fire spells by "+(1.4*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (1.4*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (1.4*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE));},
					"icon": "iceFireCostReduction"
				},
				"Od4": { //x
					"name": "Ice and Fire: Cost Reduction 4",
					"tooltip": "Increases the chance of cost reduction from Ice and Fire spells by "+(1.6*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (1.6*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (1.6*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE));},
					"icon": "iceFireCostReduction"
				},
				"Od5": { //x
					"name": "Ice and Fire: Cost Reduction 5",
					"tooltip": "Increases the chance of cost reduction from Ice and Fire spells by "+(1.8*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (1.8*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (1.8*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE));},
					"icon": "iceFireCostReduction"
				},
				"Od6": { //x
					"name": "Ice and Fire: Cost Reduction 6",
					"tooltip": "Increases the chance of cost reduction from Ice and Fire spells by "+(2.0*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (2.0*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (2.0*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE));},
					"icon": "iceFireCostReduction"
				},
				"Od7": { //x
					"name": "Ice and Fire: Cost Reduction 7",
					"tooltip": "Increases the chance of cost reduction from Ice and Fire spells by "+(2.2*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (2.2*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (2.2*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE));},
					"icon": "iceFireCostReduction"
				},
				"Od8": { //x
					"name": "Ice and Fire: Cost Reduction 8",
					"tooltip": "Increases the chance of cost reduction from Ice and Fire spells by "+(2.4*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (2.4*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (2.4*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE));},
					"icon": "iceFireCostReduction"
				},
				"Od9": { //x
					"name": "Ice and Fire: Cost Reduction 9",
					"tooltip": "Increases the chance of cost reduction from Ice and Fire spells by "+(2.6*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)+"%." ,
					"flavorText": "Cost reduction lowers the cost of Ice spells by 3 and Fire spells by 6 and Fatigue incurred by 1. This effect increases after every 100% chance.",
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCostReductionPercentChance", (2.6*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE)); CH2.currentCharacter.addTrait("FireCostReductionPercentChance", (2.6*ICE_FIRE_COST_REDUCTION_PERCENT_CHANCE));},
					"icon": "iceFireCostReduction"
				},
				"Ma1": { //x
					"name": "Ice and Lightning: Crit Chance 1",
					"tooltip": "Increases your chance to score a critical hit with Ice and Lightning Spells by "+ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", (ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL/100)); CH2.currentCharacter.addTrait("LightningAdditionalCritChance", (ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL/100)); },
					"icon": "dualIceLightningCritChance1"
				},
				"Ma2": { //x
					"name": "Ice and Lightning: Crit Chance 2",
					"tooltip": "Increases your chance to score a critical hit with Ice and Lightning Spells by "+(ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL*1.2)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", (2 * ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL / 100)); CH2.currentCharacter.addTrait("LightningAdditionalCritChance", (2 * ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL / 100)); },
					"icon": "dualIceLightningCritChance1"
				},
				"Ma3": { //x
					"name": "Ice and Lightning: Crit Chance 3",
					"tooltip": "Increases your chance to score a critical hit with Ice and Lightning Spells by "+(ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL*1.4)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", (1.4* ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL / 100)); CH2.currentCharacter.addTrait("LightningAdditionalCritChance", (1.4* ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL / 100)); },
					"icon": "dualIceLightningCritChance1"
				},
				"Ma4": { //x
					"name": "Ice and Lightning: Crit Chance 4",
					"tooltip": "Increases your chance to score a critical hit with Ice and Lightning Spells by "+(ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL*1.6)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", (1.6* ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL / 100)); CH2.currentCharacter.addTrait("LightningAdditionalCritChance", (1.6* ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL / 100)); },
					"icon": "dualIceLightningCritChance1"
				},
				"Ma5": { //x
					"name": "Ice and Lightning: Crit Chance 5",
					"tooltip": "Increases your chance to score a critical hit with Ice and Lightning Spells by "+(ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL*1.8)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", (1.8* ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL / 100));  CH2.currentCharacter.addTrait("LightningAdditionalCritChance", (1.8* ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL / 100)); },
					"icon": "dualIceLightningCritChance1"
				},
				"Ma6": { //x
					"name": "Ice and Lightning: Crit Chance 6",
					"tooltip": "Increases your chance to score a critical hit with Ice and Lightning Spells by "+(ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL*2.0)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", (2.0*ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL/100));  CH2.currentCharacter.addTrait("LightningAdditionalCritChance", (2.0* ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL/100)); },
					"icon": "dualIceLightningCritChance1"
				},
				"Ma7": { //x
					"name": "Ice and Lightning: Crit Chance 7",
					"tooltip": "Increases your chance to score a critical hit with Ice and Lightning Spells by "+(ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL*2.2)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", (2.2* ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL / 100));  CH2.currentCharacter.addTrait("LightningAdditionalCritChance", (2.2* ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL / 100)); },
					"icon": "dualIceLightningCritChance1"
				},
				"Ma8": { //x
					"name": "Ice and Lightning: Crit Chance 8",
					"tooltip": "Increases your chance to score a critical hit with Ice and Lightning Spells by "+(ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL*2.4)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", (2.4*ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL/100));  CH2.currentCharacter.addTrait("LightningAdditionalCritChance", (2.4* ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL/100)); },
					"icon": "dualIceLightningCritChance1"
				},
				"Ma9": { //x
					"name": "Ice and Lightning: Crit Chance 9",
					"tooltip": "Increases your chance to score a critical hit with Ice and Lightning Spells by "+(ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL*2.6)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalCritChance", (2.6*ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL/100));  CH2.currentCharacter.addTrait("LightningAdditionalCritChance", (2.6* ICE_LIGHTNING_CRIT_PERCENT_CHANCE_ADDITIONAL/100)) },
					"icon": "dualIceLightningCritChance1"
				},
				"Mb1": { //x
					"name": "Ice and Lightning: Chain 1",
					"tooltip": "Increases the chance that your Ice and Lightning Spells will hit an additional monster by "+ICE_LIGHTNING_CHAIN_CHANCE+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (LIGHTNING_CHAIN_PERCENT_ADDITIONAL/100)); CH2.currentCharacter.addTrait("IceChainChance", (ICE_LIGHTNING_CHAIN_CHANCE/100)); },
					"icon": "dualIceLightningChain1"
				},
				"Mb2": { //x
					"name": "Ice and Lightning: Chain 2",
					"tooltip": "Increases the chance that your Ice and Lightning Spells will hit an additional monster by "+(ICE_LIGHTNING_CHAIN_CHANCE*1.2)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*1.2)/100); CH2.currentCharacter.addTrait("IceChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*1.2/100)); },
					"icon": "dualIceLightningChain1"
				},
				"Mb3": { //x
					"name": "Ice and Lightning: Chain 3",
					"tooltip": "Increases the chance that your Ice and Lightning Spells will hit an additional monster by "+(ICE_LIGHTNING_CHAIN_CHANCE*1.4)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*1.4)/100); CH2.currentCharacter.addTrait("IceChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*1.4/100)); },
					"icon": "dualIceLightningChain1"
				},
				"Mb4": { //x
					"name": "Ice and Lightning: Chain 4",
					"tooltip": "Increases the chance that your Ice and Lightning Spells will hit an additional monster by "+(ICE_LIGHTNING_CHAIN_CHANCE*1.6)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*1.6)/100); CH2.currentCharacter.addTrait("IceChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*1.6/100)); },
					"icon": "dualIceLightningChain1"
				},
				"Mb5": { //x
					"name": "Ice and Lightning: Chain 5",
					"tooltip": "Increases the chance that your Ice and Lightning Spells will hit an additional monster by "+(ICE_LIGHTNING_CHAIN_CHANCE*1.8)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*1.8)/100); CH2.currentCharacter.addTrait("IceChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*1.8/100)); },
					"icon": "dualIceLightningChain1"
				},
				"Mb6": { //x
					"name": "Ice and Lightning: Chain 6",
					"tooltip": "Increases the chance that your Ice and Lightning Spells will hit an additional monster by "+(ICE_LIGHTNING_CHAIN_CHANCE*2.0)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*2.0)/100); CH2.currentCharacter.addTrait("IceChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*2.0/100)); },
					"icon": "dualIceLightningChain1"
				},
				"Mb7": { //x
					"name": "Ice and Lightning: Chain 7",
					"tooltip": "Increases the chance that your Ice and Lightning Spells will hit an additional monster by "+(ICE_LIGHTNING_CHAIN_CHANCE*2.2)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*2.2)/100); CH2.currentCharacter.addTrait("IceChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*2.2/100)); },
					"icon": "dualIceLightningChain1"
				},
				"Mb8": { //x
					"name": "Ice and Lightning: Chain 8",
					"tooltip": "Increases the chance that your Ice and Lightning Spells will hit an additional monster by "+(ICE_LIGHTNING_CHAIN_CHANCE*2.4)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*2.4)/100); CH2.currentCharacter.addTrait("IceChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*2.4/100)); },
					"icon": "dualIceLightningChain1"
				},
				"Mb9": { //x
					"name": "Ice and Lightning: Chain 9",
					"tooltip": "Increases the chance that your Ice and Lightning Spells will hit an additional monster by "+(ICE_LIGHTNING_CHAIN_CHANCE*2.6)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*2.6)/100); CH2.currentCharacter.addTrait("IceChainChance", (ICE_LIGHTNING_CHAIN_CHANCE*2.6/100)); },
					"icon": "dualIceLightningChain1"
				},
				"Mc1": { //x
					"name": "Ice and Lightning: Damage 1",
					"tooltip": "Increases the damage of Ice and Lightning Spells by "+ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100); CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100); },
					"icon": "dualIceLightningDamage1"
				},
				"Mc2": { //x
					"name": "Ice and Lightning: Damage 2",
					"tooltip": "Increases the damage of Ice and Lightning Spells by "+(ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*1.2)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (1.2*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (1.2*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); },
					"icon": "dualIceLightningDamage1"
				},
				"Mc3": { //x
					"name": "Ice and Lightning: Damage 3",
					"tooltip": "Increases the damage of Ice and Lightning Spells by "+(ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*1.4)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (1.4*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (1.4*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); },
					"icon": "dualIceLightningDamage1"
				},
				"Mc4": { //x
					"name": "Ice and Lightning: Damage 4",
					"tooltip": "Increases the damage of Ice and Lightning Spells by "+(ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*1.6)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (1.6*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (1.6*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); },
					"icon": "dualIceLightningDamage1"
				},
				"Mc5": { //x
					"name": "Ice and Lightning: Damage 5",
					"tooltip": "Increases the damage of Ice and Lightning Spells by "+(ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*1.8)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (1.8*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (1.8*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); },
					"icon": "dualIceLightningDamage1"
				},
				"Mc6": { //x
					"name": "Ice and Lightning: Damage 6",
					"tooltip": "Increases the damage of Ice and Lightning Spells by "+(ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*2.0)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (2.0*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (2.0*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); },
					"icon": "dualIceLightningDamage1"
				},
				"Mc7": { //x
					"name": "Ice and Lightning: Damage 7",
					"tooltip": "Increases the damage of Ice and Lightning Spells by "+(ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*2.2)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (2.2*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (2.2*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); },
					"icon": "dualIceLightningDamage1"
				},
				"Mc8": { //x
					"name": "Ice and Lightning: Damage 8",
					"tooltip": "Increases the damage of Ice and Lightning Spells by "+(ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*2.4)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (2.4*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (2.4*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); },
					"icon": "dualIceLightningDamage1"
				},
				"Mc9": { //x
					"name": "Ice and Lightning: Damage 9",
					"tooltip": "Increases the damage of Ice and Lightning Spells by "+(ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE*2.6)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (2.6*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (2.6*ICE_LIGHTNING_ADDITIONAL_PERCENT_DAMAGE/100)); },
					"icon": "dualIceLightningDamage1"
				},
				"Na1": { //x
					"name": "Lightning and Fire: Zap 1",
					"tooltip": "After casting a Lightning or Fire spell, your next 2 clicks attacks are increased by "+LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE+"% and cost no energy.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("FireZapPercentDamage", (LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); },
					"icon": "dualLightningFireZapps"
				},
				"Na2": { //x
					"name": "Lightning and Fire: Zap 2",
					"tooltip": "After casting a Lightning or Fire spell, your next 2 clicks attacks are increased by "+(LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE*1.2)+"% and cost no energy.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (1.2*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("FireZapPercentDamage", (1.2*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); },
					"icon": "dualLightningFireZapps"
				},
				"Na3": { //x
					"name": "Lightning and Fire: Zap 3",
					"tooltip": "After casting a Lightning or Fire spell, your next 2 clicks attacks are increased by "+(LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE*1.4)+"% and cost no energy.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (1.4*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("FireZapPercentDamage", (1.4*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); },
					"icon": "dualLightningFireZapps"
				},
				"Na4": { //x
					"name": "Lightning and Fire: Zap 4",
					"tooltip": "After casting a Lightning or Fire spell, your next 2 clicks attacks are increased by "+(LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE*1.6)+"% and cost no energy.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (1.6*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("FireZapPercentDamage", (1.6*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); },
					"icon": "dualLightningFireZapps"
				},
				"Na5": { //x
					"name": "Lightning and Fire: Zap 5",
					"tooltip": "After casting a Lightning or Fire spell, your next 2 clicks attacks are increased by "+(LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE*1.8)+"% and cost no energy.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (1.8*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("FireZapPercentDamage", (1.8*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); },
					"icon": "dualLightningFireZapps"
				},
				"Na6": { //x
					"name": "Lightning and Fire: Zap 6",
					"tooltip": "After casting a Lightning or Fire spell, your next 2 clicks attacks are increased by "+(LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE*2.0)+"% and cost no energy.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (2.0*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("FireZapPercentDamage", (2.0*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); },
					"icon": "dualLightningFireZapps"
				},
				"Na7": { //x
					"name": "Lightning and Fire: Zap 7",
					"tooltip": "After casting a Lightning or Fire spell, your next 2 clicks attacks are increased by "+(LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE*2.2)+"% and cost no energy.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (2.2*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("FireZapPercentDamage", (2.2*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); },
					"icon": "dualLightningFireZapps"
				},
				"Na8": { //x
					"name": "Lightning and Fire: Zap 8",
					"tooltip": "After casting a Lightning or Fire spell, your next 2 clicks attacks are increased by "+(LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE*2.4)+"% and cost no energy.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (2.4*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("FireZapPercentDamage", (2.4*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); },
					"icon": "dualLightningFireZapps"
				},
				"Na9": { //x
					"name": "Lightning and Fire: Zap 9",
					"tooltip": "After casting a Lightning or Fire spell, your next 2 clicks attacks are increased by "+(LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE*2.6)+"% and cost no energy.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningZapPercentDamage", (2.6*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); CH2.currentCharacter.addTrait("FireZapPercentDamage", (2.6*LIGHTNING_FIRE_ZAP_PERCENT_DAMAGE/100)); },
					"icon": "dualLightningFireZapps"
				},
				"Nb1": {
					"name": "Lightning and Fire: Burn 1",
					"tooltip": "Increases the damage over time effect of Lightning and Fire Spells by "+LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("LightningBurnDamage", LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE/100); CH2.currentCharacter.addTrait("FireBurnDamage", LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE/100);},
					"icon": "dualLightningFireBurnUp1"
				},
				"Nb2": { //x
					"name": "Lightning and Fire: Burn 2",
					"tooltip": "Increases the damage over time effect of Lightning and Fire Spells by "+(1.2*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("LightningBurnDamage", (1.2*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100); CH2.currentCharacter.addTrait("FireBurnDamage", (1.2*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100);},
					"icon": "dualLightningFireBurnUp1"
				},
				"Nb3": { //x
					"name": "Lightning and Fire: Burn 3",
					"tooltip": "Increases the damage over time effect of Lightning and Fire Spells by "+(1.4*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("LightningBurnDamage", (1.4*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100); CH2.currentCharacter.addTrait("FireBurnDamage", (1.4*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100);},
					"icon": "dualLightningFireBurnUp1"
				},
				"Nb4": { //x
					"name": "Lightning and Fire: Burn 4",
					"tooltip": "Increases the damage over time effect of Lightning and Fire Spells by "+(1.6*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("LightningBurnDamage", (1.6*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100); CH2.currentCharacter.addTrait("FireBurnDamage", (1.6*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100);},
					"icon": "dualLightningFireBurnUp1"
				},
				"Nb5": { //x
					"name": "Lightning and Fire: Burn 5",
					"tooltip": "Increases the damage over time effect of Lightning and Fire Spells by "+(1.8*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("LightningBurnDamage", (1.8*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100); CH2.currentCharacter.addTrait("FireBurnDamage", (1.8*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100);},
					"icon": "dualLightningFireBurnUp1"
				},
				"Nb6": { //x
					"name": "Lightning and Fire: Burn 6",
					"tooltip": "Increases the damage over time effect of Lightning and Fire Spells by "+(2.0*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("LightningBurnDamage", (2.0*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100); CH2.currentCharacter.addTrait("FireBurnDamage", (2.0*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100);},
					"icon": "dualLightningFireBurnUp1"
				},
				"Nb7": { //x
					"name": "Lightning and Fire: Burn 7",
					"tooltip": "Increases the damage over time effect of Lightning and Fire Spells by "+(2.2*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("LightningBurnDamage", (2.2*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100); CH2.currentCharacter.addTrait("FireBurnDamage", (2.2*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100);},
					"icon": "dualLightningFireBurnUp1"
				},
				"Nb8": { //x
					"name": "Lightning and Fire: Burn 8",
					"tooltip": "Increases the damage over time effect of Lightning and Fire Spells by "+(2.4*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("LightningBurnDamage", (2.4*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100); CH2.currentCharacter.addTrait("FireBurnDamage", (2.4*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100);},
					"icon": "dualLightningFireBurnUp1"
				},
				"Nb9": { //x
					"name": "Lightning and Fire: Burn 9",
					"tooltip": "Increases the damage over time effect of Lightning and Fire Spells by "+(2.6*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("LightningBurnDamage", (2.6*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100); CH2.currentCharacter.addTrait("FireBurnDamage", (2.6*LIGHTNING_FIRE_BURN_PERCENT_DAMAGE_INCREASE)/100);},
					"icon": "dualLightningFireBurnUp1"
				},
				"Nc1": { //x
					"name": "Lightning and Fire: Damage 1",
					"tooltip": "Increases the damage of Lightning and Fire Spells by "+LIGHTNING_FIRE_DAMAGE_PERCENT+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (LIGHTNING_FIRE_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (LIGHTNING_FIRE_DAMAGE_PERCENT/100)); },
					"icon": "dualLightningFireDamage1"
				},
				"Nc2": { //x
					"name": "Lightning and Fire: Damage 2",
					"tooltip": "Increases the damage of Lightning and Fire Spells by "+(1.2*LIGHTNING_FIRE_DAMAGE_PERCENT)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (1.2*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (1.2*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); },
					"icon": "dualLightningFireDamage1"
				},
				"Nc3": { //x
					"name": "Lightning and Fire: Damage 3",
					"tooltip": "Increases the damage of Lightning and Fire Spells by "+(1.4*LIGHTNING_FIRE_DAMAGE_PERCENT)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (1.4*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (1.4*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); },
					"icon": "dualLightningFireDamage1"
				},
				"Nc4": { //x
					"name": "Lightning and Fire: Damage 4",
					"tooltip": "Increases the damage of Lightning and Fire Spells by "+(1.6*LIGHTNING_FIRE_DAMAGE_PERCENT)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (1.6*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (1.6*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); },
					"icon": "dualLightningFireDamage1"
				},
				"Nc5": { //x
					"name": "Lightning and Fire: Damage 5",
					"tooltip": "Increases the damage of Lightning and Fire Spells by "+(1.8*LIGHTNING_FIRE_DAMAGE_PERCENT)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (1.8*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (1.8*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); },
					"icon": "dualLightningFireDamage1"
				},
				"Nc6": { //x
					"name": "Lightning and Fire: Damage 6",
					"tooltip": "Increases the damage of Lightning and Fire Spells by "+(2.0*LIGHTNING_FIRE_DAMAGE_PERCENT)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (2.0*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (2.0*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); },
					"icon": "dualLightningFireDamage1"
				},
				"Nc7": { //x
					"name": "Lightning and Fire: Damage 7",
					"tooltip": "Increases the damage of Lightning and Fire Spells by "+(2.2*LIGHTNING_FIRE_DAMAGE_PERCENT)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (2.2*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (2.2*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); },
					"icon": "dualLightningFireDamage1"
				},
				"Nc8": { //x
					"name": "Lightning and Fire: Damage 8",
					"tooltip": "Increases the damage of Lightning and Fire Spells by "+(2.4*LIGHTNING_FIRE_DAMAGE_PERCENT)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (2.4*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (2.4*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); },
					"icon": "dualLightningFireDamage1"
				},
				"Nc9": { //x
					"name": "Lightning and Fire: Damage 9",
					"tooltip": "Increases the damage of Lightning and Fire Spells by "+(2.6*LIGHTNING_FIRE_DAMAGE_PERCENT)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningAdditionalPercentDamage", (2.6*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (2.6*LIGHTNING_FIRE_DAMAGE_PERCENT/100)); },
					"icon": "dualLightningFireDamage1"
				},
				"Oa1": { //x
					"name": "Ice and Fire: Corrosion Damage 1",
					"tooltip": "Increases all damage taken by monsters by "+ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE+"% after being hit by an Ice or Fire spell.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCorrosionDamageBonus", ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE/100); CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE/100); },
					"icon": "dualIceFireCorrosionDamage1"
				},
				"Oa2": { //x
					"name": "Ice and Fire: Corrosion Damage 2",
					"tooltip": "Increases all damage taken by monsters by "+(1.2*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)+"% after being hit by an Ice or Fire spell.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCorrosionDamageBonus", (1.2*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (1.2*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireCorrosionDamage1"
				},
				"Oa3": { //x
					"name": "Ice and Fire: Corrosion Damage 3",
					"tooltip": "Increases all damage taken by monsters by "+(1.4*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)+"% after being hit by an Ice or Fire spell.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCorrosionDamageBonus", (1.4*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (1.4*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireCorrosionDamage1"
				},
				"Oa4": { //x
					"name": "Ice and Fire: Corrosion Damage 4",
					"tooltip": "Increases all damage taken by monsters by "+(1.6*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)+"% after being hit by an Ice or Fire spell.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCorrosionDamageBonus", (1.6*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (1.6*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireCorrosionDamage1"
				},
				"Oa5": { //x
					"name": "Ice and Fire: Corrosion Damage 5",
					"tooltip": "Increases all damage taken by monsters by "+(1.8*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)+"% after being hit by an Ice or Fire spell.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCorrosionDamageBonus", (1.8*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (1.8*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireCorrosionDamage1"
				},
				"Oa6": { //x
					"name": "Ice and Fire: Corrosion Damage 6",
					"tooltip": "Increases all damage taken by monsters by "+(2.0*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)+"% after being hit by an Ice or Fire spell.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCorrosionDamageBonus", (2.0*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (2.0*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireCorrosionDamage1"
				},
				"Oa7": { //x
					"name": "Ice and Fire: Corrosion Damage 7",
					"tooltip": "Increases all damage taken by monsters by "+(2.2*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)+"% after being hit by an Ice or Fire spell.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCorrosionDamageBonus", (2.2*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (2.2*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireCorrosionDamage1"
				},
				"Oa8": { //x
					"name": "Ice and Fire: Corrosion Damage 8",
					"tooltip": "Increases all damage taken by monsters by "+(2.4*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)+"% after being hit by an Ice or Fire spell.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCorrosionDamageBonus", (2.4*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (2.4*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireCorrosionDamage1"
				},
				"Oa9": { //x
					"name": "Ice and Fire: Corrosion Damage 9",
					"tooltip": "Increases all damage taken by monsters by "+(2.6*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)+"% after being hit by an Ice or Fire spell.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCorrosionDamageBonus", (2.6*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireCorrosionDamageBonus", (2.6*ICE_FIRE_CORROSION_DAMAGE_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireCorrosionDamage1"
				},
				"Ob1": { //x
					"name": "Ice and Fire: Crit Damage 1",
					"tooltip": "Increases the damage of your critical hits with Ice and Fire Spells by "+ICE_FIRE_CRIT_DAMAGE_PERCENT+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", ICE_FIRE_CRIT_DAMAGE_PERCENT/100); CH2.currentCharacter.addTrait("FireCritAdditionalDamage", ICE_FIRE_CRIT_DAMAGE_PERCENT/100); },
					"icon": "dualIceFireCritDamage1"
				},
				"Ob2": { //x
					"name": "Ice and Fire: Crit Damage 2",
					"tooltip": "Increases the damage of your critical hits with Ice and Fire Spells by "+(1.2*ICE_FIRE_CRIT_DAMAGE_PERCENT)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (1.2*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireCritAdditionalDamage", (1.2*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); },
					"icon": "dualIceFireCritDamage1"
				},
				"Ob3": { //x
					"name": "Ice and Fire: Crit Damage 3",
					"tooltip": "Increases the damage of your critical hits with Ice and Fire Spells by "+(1.4*ICE_FIRE_CRIT_DAMAGE_PERCENT)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (1.4*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireCritAdditionalDamage", (1.4*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); },
					"icon": "dualIceFireCritDamage1"
				},
				"Ob4": { //x
					"name": "Ice and Fire: Crit Damage 4",
					"tooltip": "Increases the damage of your critical hits with Ice and Fire Spells by "+(1.6*ICE_FIRE_CRIT_DAMAGE_PERCENT)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (1.6*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireCritAdditionalDamage", (1.6*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); },
					"icon": "dualIceFireCritDamage1"
				},
				"Ob5": { //x
					"name": "Ice and Fire: Crit Damage 5",
					"tooltip": "Increases the damage of your critical hits with Ice and Fire Spells by "+(1.8*ICE_FIRE_CRIT_DAMAGE_PERCENT)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (1.8*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireCritAdditionalDamage", (1.8*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); },
					"icon": "dualIceFireCritDamage1"
				},
				"Ob6": { //x
					"name": "Ice and Fire: Crit Damage 6",
					"tooltip": "Increases the damage of your critical hits with Ice and Fire Spells by "+(2.0*ICE_FIRE_CRIT_DAMAGE_PERCENT)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (2.0*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireCritAdditionalDamage", (2.0*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); },
					"icon": "dualIceFireCritDamage1"
				},
				"Ob7": { //x
					"name": "Ice and Fire: Crit Damage 7",
					"tooltip": "Increases the damage of your critical hits with Ice and Fire Spells by "+(2.2*ICE_FIRE_CRIT_DAMAGE_PERCENT)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (2.2*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireCritAdditionalDamage", (2.2*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); },
					"icon": "dualIceFireCritDamage1"
				},
				"Ob8": { //x
					"name": "Ice and Fire: Crit Damage 8",
					"tooltip": "Increases the damage of your critical hits with Ice and Fire Spells by "+(2.4*ICE_FIRE_CRIT_DAMAGE_PERCENT)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (2.4*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); CH2.currentCharacter.addTrait("FireCritAdditionalDamage", (2.4*ICE_FIRE_CRIT_DAMAGE_PERCENT/100)); },
					"icon": "dualIceFireCritDamage1"
				},
				"Ob9": { //x
					"name": "Ice and Fire: Crit Damage 9",
					"tooltip": "Increases the damage of your critical hits with Ice and Fire Spells by "+(2.6*ICE_FIRE_CRIT_DAMAGE_PERCENT)+"%.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceCritAdditionalDamage", (2.6*ICE_FIRE_CRIT_DAMAGE_PERCENT)); CH2.currentCharacter.addTrait("FireCritAdditionalDamage", (2.6*ICE_FIRE_CRIT_DAMAGE_PERCENT)); },
					"icon": "dualIceFireCritDamage1"
				},
				"Oc1": { //x
					"name": "Ice and Fire: Damage 1",
					"tooltip": "Increases the damage of Ice and Fire Spells by "+ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE/100); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE/100); },
					"icon": "dualIceFireDamage1"
				},
				"Oc2": { //x
					"name": "Ice and Fire: Damage 2",
					"tooltip": "Increases the damage of Ice and Fire Spells by "+(1.2*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (1.2*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (1.2*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireDamage1"
				},
				"Oc3": { //x
					"name": "Ice and Fire: Damage 3",
					"tooltip": "Increases the damage of Ice and Fire Spells by "+(1.4*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (1.4*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (1.4*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireDamage1"
				},
				"Oc4": { //x
					"name": "Ice and Fire: Damage 4",
					"tooltip": "Increases the damage of Ice and Fire Spells by "+(1.6*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (1.6*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (1.6*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireDamage1"
				},
				"Oc5": { //x
					"name": "Ice and Fire: Damage 5",
					"tooltip": "Increases the damage of Ice and Fire Spells by "+(1.8*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (1.8*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (1.8*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireDamage1"
				},
				"Oc6": { //x
					"name": "Ice and Fire: Damage 6",
					"tooltip": "Increases the damage of Ice and Fire Spells by "+(2.0*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (2.0*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (2.0*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireDamage1"
				},
				"Oc7": { //x
					"name": "Ice and Fire: Damage 7",
					"tooltip": "Increases the damage of Ice and Fire Spells by "+(2.2*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (2.2*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (2.2*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireDamage1"
				},
				"Oc8": { //x
					"name": "Ice and Fire: Damage 8",
					"tooltip": "Increases the damage of Ice and Fire Spells by "+(2.4*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (2.4*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (2.4*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireDamage1"
				},
				"Oc9": { //x
					"name": "Ice and Fire: Damage 9",
					"tooltip": "Increases the damage of Ice and Fire Spells by "+(2.6*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("IceAdditionalPercentDamage", (2.6*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); CH2.currentCharacter.addTrait("FireAdditionalPercentDamage", (2.6*ICE_FIRE_ADDITIONAL_PERCENT_DAMAGE)/100); },
					"icon": "dualIceFireDamage1"
				},
				"It3": { //x
					"name": "Ice Trait: Cool Criticals 1",
					"tooltip": "Tier 1 Ice Spells increase the chance to score a critical hit by "+ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT+"% with all Spells for "+ICE_COOL_CRITICALS_DURATION_SECONDS+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritChance", ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT/100); CH2.currentCharacter.addTrait("Ice1CritDuration", ICE_COOL_CRITICALS_DURATION_SECONDS*1000); },
					"icon": "iceTraitCoolCriticals"
				},
				"It4": { //x
					"name": "Ice Trait: Cool Criticals 2",
					"tooltip": "Tier 1 Ice Spells increase the chance to score a critical hit by "+(1.5*ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT)+"% with all Spells for "+ICE_COOL_CRITICALS_DURATION_SECONDS+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritChance", (1.5*ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT)/100); },
					"icon": "iceTraitCoolCriticals"
				},
				"It5": { //x
					"name": "Ice Trait: Cool Criticals 3",
					"tooltip": "Tier 1 Ice Spells increase the chance to score a critical hit by "+(2.0*ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT)+"% with all Spells for "+ICE_COOL_CRITICALS_DURATION_SECONDS+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritChance", (2.0*ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT)/100); },
					"icon": "iceTraitCoolCriticals"
				},
				"Iz3": { //x
					"name": "Ice Trait: Chilly Cool Criticals 1",
					"tooltip": "Increases the critical hit bonus of Cool Criticals by "+ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritChance", ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT/100); },
					"icon": "iceTraitChillyCoolCriticals1"
				},
				"Iz4": { //x
					"name": "Ice Trait: Chilly Cool Criticals 2",
					"tooltip": "Increases the critical hit bonus of Cool Criticals by "+(ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT*1.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritChance", (ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT*1.2)/100); },
					"icon": "iceTraitChillyCoolCriticals1"
				},
				"Iz5": { //x
					"name": "Ice Trait: Chilly Cool Criticals 3",
					"tooltip": "Increases the critical hit bonus of Cool Criticals by "+(ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT*1.4)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritChance", (ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT*1.4)/100); },
					"icon": "iceTraitChillyCoolCriticals1"
				},
				"Iz6": { //x
					"name": "Ice Trait: Chilly Cool Criticals 4",
					"tooltip": "Increases the critical hit bonus of Cool Criticals by "+(ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT*1.6)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritChance", (ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT*1.6)/100); },
					"icon": "iceTraitChillyCoolCriticals1"
				},
				"Iz7": { //x
					"name": "Ice Trait: Chilly Cool Criticals 5",
					"tooltip": "Increases the critical hit bonus of Cool Criticals by "+(ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT*1.8)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritChance", (ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT*1.8)/100); },
					"icon": "iceTraitChillyCoolCriticals1"
				},
				"Iz8": { //x
					"name": "Ice Trait: Chilly Cool Criticals 6",
					"tooltip": "Increases the critical hit bonus of Cool Criticals by "+(ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT*2.0)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritChance", (ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT*2.0)/100); },
					"icon": "iceTraitChillyCoolCriticals1"
				},
				"Iz9": { //x
					"name": "Ice Trait: Chilly Cool Criticals 7",
					"tooltip": "Increases the critical hit bonus of Cool Criticals by "+(ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT*2.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritChance", (ICE_CHILLY_COOL_CRITICALS_CRIT_CHANCE_PERCENT*2.2)/100); },
					"icon": "iceTraitChillyCoolCriticals1"
				},
				"Iy3": { //x
					"name": "Ice Trait: Cold Cool Criticals 1",
					"tooltip": "Increases the duration of Cool Criticals by "+ICE_COLD_COOL_CRITICALS_DURATION_SECONDS+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritDuration", ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*1000); },
					"icon": "iceTraitColdCoolCriticals1"
				},
				"Iy4": { //x
					"name": "Ice Trait: Cold Cool Criticals 2",
					"tooltip": "Increases the duration of Cool Criticals by "+(ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*1.2)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritDuration", (ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*1.2)*1000); },
					"icon": "iceTraitColdCoolCriticals1"
				},
				"Iy5": { //x
					"name": "Ice Trait: Cold Cool Criticals 3",
					"tooltip": "Increases the duration of Cool Criticals by "+(ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*1.4)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritDuration", (ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*1.4)*1000); },
					"icon": "iceTraitColdCoolCriticals1"
				},
				"Iy6": { //x
					"name": "Ice Trait: Cold Cool Criticals 4",
					"tooltip": "Increases the duration of Cool Criticals by "+(ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*1.6)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritDuration", (ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*1.6)*1000); },
					"icon": "iceTraitColdCoolCriticals1"
				},
				"Iy7": { //x
					"name": "Ice Trait: Cold Cool Criticals 5",
					"tooltip": "Increases the duration of Cool Criticals by "+(ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*1.8)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritDuration", (ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*1.8)*1000); },
					"icon": "iceTraitColdCoolCriticals1"
				},
				"Iy8": { //x
					"name": "Ice Trait: Cold Cool Criticals 6",
					"tooltip": "Increases the duration of Cool Criticals by "+(ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*2.0)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritDuration", (ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*2.0)*1000); },
					"icon": "iceTraitColdCoolCriticals1"
				},
				"Iy9": { //x
					"name": "Ice Trait: Cold Cool Criticals 7",
					"tooltip": "Increases the duration of Cool Criticals by "+(ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*2.2)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("Ice1CritDuration", (ICE_COLD_COOL_CRITICALS_DURATION_SECONDS*2.2)*1000); },
					"icon": "iceTraitColdCoolCriticals1"
				},
				"Lt3": { //x
					"name": "Lightning Trait: Flash 1",
					"tooltip": "Tier 1 Lightning Spells increase the speed at which you cast all Spells by "+LIGHTNING_FLASH_SPEED_INCREASE_PERCENT+"% for your next "+LIGHTNING_FLASH_NUM_SPELLS+" Spells." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashHaste", LIGHTNING_FLASH_SPEED_INCREASE_PERCENT/100); CH2.currentCharacter.addTrait("LightningFlashNumSpells", LIGHTNING_FLASH_NUM_SPELLS); },
					"icon": "lightningTraitFlash"
				},
				"Lt4": { //x
					"name": "Lightning Trait: Flash 2",
					"tooltip": "Tier 1 Lightning Spells increase the speed at which you cast all Spells by "+(LIGHTNING_FLASH_SPEED_INCREASE_PERCENT*1.5)+"% for your next "+LIGHTNING_FLASH_NUM_SPELLS+" Spells." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashHaste", (LIGHTNING_FLASH_SPEED_INCREASE_PERCENT*1.5)/100); setTraitIfLess("LightningFlashNumSpells", LIGHTNING_FLASH_NUM_SPELLS); },
					"icon": "lightningTraitFlash"
				},
				"Lt5": { //x
					"name": "Lightning Trait: Flash 3",
					"tooltip": "Tier 1 Lightning Spells increase the speed at which you cast all Spells by "+(LIGHTNING_FLASH_SPEED_INCREASE_PERCENT*2.0)+"% for your next "+LIGHTNING_FLASH_NUM_SPELLS+" Spells." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashHaste", (LIGHTNING_FLASH_SPEED_INCREASE_PERCENT*2.0)/100); setTraitIfLess("LightningFlashNumSpells", LIGHTNING_FLASH_NUM_SPELLS); },
					"icon": "lightningTraitFlash"
				},
				"Lz3": { //x
					"name": "Lightning Trait: Flashier Flash 1",
					"tooltip": "Increases the haste bonus of Flash by "+LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashHaste", LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT/100); setTraitIfLess("LightningFlashNumSpells", LIGHTNING_FLASH_NUM_SPELLS); },
					"icon": "lightningTraitFlashierFlash1"
				},
				"Lz4": { //x
					"name": "Lightning Trait: Flashier Flash 2",
					"tooltip": "Increases the haste bonus of Flash by "+(LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT*1.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashHaste", (LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT*1.2)/100); setTraitIfLess("LightningFlashNumSpells", LIGHTNING_FLASH_NUM_SPELLS); },
					"icon": "lightningTraitFlashierFlash1"
				},
				"Lz5": { //x
					"name": "Lightning Trait: Flashier Flash 3",
					"tooltip": "Increases the haste bonus of Flash by "+(LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT*1.4)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashHaste", (LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT*1.4)/100); setTraitIfLess("LightningFlashNumSpells", LIGHTNING_FLASH_NUM_SPELLS); },
					"icon": "lightningTraitFlashierFlash1"
				},
				"Lz6": { //x
					"name": "Lightning Trait: Flashier Flash 4",
					"tooltip": "Increases the haste bonus of Flash by "+(LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT*1.6)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashHaste", (LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT*1.6)/100); setTraitIfLess("LightningFlashNumSpells", LIGHTNING_FLASH_NUM_SPELLS); },
					"icon": "lightningTraitFlashierFlash1"
				},
				"Lz7": { //x
					"name": "Lightning Trait: Flashier Flash 5",
					"tooltip": "Increases the haste bonus of Flash by "+(LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT*1.8)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashHaste", (LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT*1.8)/100); setTraitIfLess("LightningFlashNumSpells", LIGHTNING_FLASH_NUM_SPELLS); },
					"icon": "lightningTraitFlashierFlash1"
				},
				"Lz8": { //x
					"name": "Lightning Trait: Flashier Flash 6",
					"tooltip": "Increases the haste bonus of Flash by "+(LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT*2.0)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashHaste", (LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT*2.0)/100); setTraitIfLess("LightningFlashNumSpells", LIGHTNING_FLASH_NUM_SPELLS); },
					"icon": "lightningTraitFlashierFlash1"
				},
				"Lz9": { //x
					"name": "Lightning Trait: Flashier Flash 7",
					"tooltip": "Increases the haste bonus of Flash by "+(LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT*2.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashHaste", (LIGHTNING_FLASHIER_FLASH_HASTE_PERCENT*2.2)/100); setTraitIfLess("LightningFlashNumSpells", LIGHTNING_FLASH_NUM_SPELLS); },
					"icon": "lightningTraitFlashierFlash1"
				},
				"Ly3": { //x
					"name": "Lightning Trait: Lingering Flash 1",
					"tooltip": "Increases the duration of Flash by "+LIGHTNING_LINGERING_FLASH_NUM_SPELLS+" Spell." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashNumSpells", LIGHTNING_LINGERING_FLASH_NUM_SPELLS); },
					"icon": "lightningTraitLingeringFlash1"
				},
				"Ly4": { //x
					"name": "Lightning Trait: Lingering Flash 2",
					"tooltip": "Increases the duration of Flash by "+(LIGHTNING_LINGERING_FLASH_NUM_SPELLS*1.2)+" Spell." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashNumSpells", (LIGHTNING_LINGERING_FLASH_NUM_SPELLS*1.2)); },
					"icon": "lightningTraitLingeringFlash1"
				},
				"Ly5": { //x
					"name": "Lightning Trait: Lingering Flash 3",
					"tooltip": "Increases the duration of Flash by "+(LIGHTNING_LINGERING_FLASH_NUM_SPELLS*1.4)+" Spell." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashNumSpells", (LIGHTNING_LINGERING_FLASH_NUM_SPELLS*1.4)); },
					"icon": "lightningTraitLingeringFlash1"
				},
				"Ly6": { //x
					"name": "Lightning Trait: Lingering Flash 4",
					"tooltip": "Increases the duration of Flash by "+(LIGHTNING_LINGERING_FLASH_NUM_SPELLS*1.6)+" Spell." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashNumSpells", (LIGHTNING_LINGERING_FLASH_NUM_SPELLS*1.6)); },
					"icon": "lightningTraitLingeringFlash1"
				},
				"Ly7": { //x
					"name": "Lightning Trait: Lingering Flash 5",
					"tooltip": "Increases the duration of Flash by "+(LIGHTNING_LINGERING_FLASH_NUM_SPELLS*1.8)+" Spell." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashNumSpells", (LIGHTNING_LINGERING_FLASH_NUM_SPELLS*1.8)); },
					"icon": "lightningTraitLingeringFlash1"
				},
				"Ly8": { //x
					"name": "Lightning Trait: Lingering Flash 6",
					"tooltip": "Increases the duration of Flash by "+(LIGHTNING_LINGERING_FLASH_NUM_SPELLS*2.0)+" Spell." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashNumSpells", (LIGHTNING_LINGERING_FLASH_NUM_SPELLS*2.0)); },
					"icon": "lightningTraitLingeringFlash1"
				},
				"Ly9": { //x
					"name": "Lightning Trait: Lingering Flash 7",
					"tooltip": "Increases the duration of Flash by "+(LIGHTNING_LINGERING_FLASH_NUM_SPELLS*2.2)+" Spell." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningFlashNumSpells", (LIGHTNING_LINGERING_FLASH_NUM_SPELLS*2.2)); },
					"icon": "lightningTraitLingeringFlash1"
				},
				"Ft3": { //x
					"name": "Fire Trait: Combustion 1",
					"tooltip": "Tier 1 Fire Spells give a "+FIRE_COMBUSTION_CHANCE_PERCENT+"% chance for all Burn damage to occur twice for "+FIRE_COMBUSTION_DURATION_SECONDS+" seconds." ,  // More specifically, this gives a 10s long Buff (increased by y). During this Buff, Burn ticks have a chance to occur twice. These double ticks should not decrease the remaining ticks by any extra amounts beyond the normal one tick.
					"flavorText": null,			
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnChance", (FIRE_COMBUSTION_CHANCE_PERCENT/100)/4); CH2.currentCharacter.addTrait("DoubleBurnDuration", FIRE_COMBUSTION_DURATION_SECONDS*1000); },
					"icon": "fireTraitCombustion"
				},
				"Ft4": { //x
					"name": "Fire Trait: Combustion 2",
					"tooltip": "Tier 1 Fire Spells give a "+(FIRE_COMBUSTION_CHANCE_PERCENT*1.5)+"% chance for all Burn damage to occur twice for "+(FIRE_COMBUSTION_DURATION_SECONDS)+" seconds." ,  // More specifically, this gives a 10s long Buff (increased by y). During this Buff, Burn ticks have a chance to occur twice. These double ticks should not decrease the remaining ticks by any extra amounts beyond the normal one tick.
					"flavorText": null,			
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnChance", ((FIRE_COMBUSTION_CHANCE_PERCENT/100)*1.5)/4); CH2.currentCharacter.addTrait("DoubleBurnDuration", (FIRE_COMBUSTION_DURATION_SECONDS)*1000); },
					"icon": "fireTraitCombustion"
				},
				"Ft5": { //x
					"name": "Fire Trait: Combustion 3",
					"tooltip": "Tier 1 Fire Spells give a "+(FIRE_COMBUSTION_CHANCE_PERCENT*2.0)+"% chance for all Burn damage to occur twice for "+(FIRE_COMBUSTION_DURATION_SECONDS)+" seconds." ,  // More specifically, this gives a 10s long Buff (increased by y). During this Buff, Burn ticks have a chance to occur twice. These double ticks should not decrease the remaining ticks by any extra amounts beyond the normal one tick.
					"flavorText": null,			
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnChance", ((FIRE_COMBUSTION_CHANCE_PERCENT/100)*2.0)/4); CH2.currentCharacter.addTrait("DoubleBurnDuration", (FIRE_COMBUSTION_DURATION_SECONDS)*1000); },
					"icon": "fireTraitCombustion"
				},
				"Fz3": { //x
					"name": "Fire Trait: Incendiary Combustion 1",
					"tooltip": "Increases the chance for Combustion to occur by "+FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnChance", FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT/100); },
					"icon": "fireTraitIncendiaryCombustion1"
				},
				"Fz4": { //x
					"name": "Fire Trait: Incendiary Combustion 2",
					"tooltip": "Increases the chance for Combustion to occur by "+(FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT*1.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnChance", (FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT*1.2)/100); },
					"icon": "fireTraitIncendiaryCombustion1"
				},
				"Fz5": { //x
					"name": "Fire Trait: Incendiary Combustion 3",
					"tooltip": "Increases the chance for Combustion to occur by "+(FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT*1.4)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnChance", (FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT*1.4)/100); },
					"icon": "fireTraitIncendiaryCombustion1"
				},
				"Fz6": { //x
					"name": "Fire Trait: Incendiary Combustion 4",
					"tooltip": "Increases the chance for Combustion to occur by "+(FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT*1.6)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnChance", (FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT*1.6)/100); },
					"icon": "fireTraitIncendiaryCombustion1"
				},
				"Fz7": { //x
					"name": "Fire Trait: Incendiary Combustion 5",
					"tooltip": "Increases the chance for Combustion to occur by "+(FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT*1.8)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnChance", (FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT*1.8)/100); },
					"icon": "fireTraitIncendiaryCombustion1"
				},
				"Fz8": { //x
					"name": "Fire Trait: Incendiary Combustion 6",
					"tooltip": "Increases the chance for Combustion to occur by "+(FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT*2.0)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnChance", (FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT*2.0)/100); },
					"icon": "fireTraitIncendiaryCombustion1"
				},
				"Fz9": { //x
					"name": "Fire Trait: Incendiary Combustion 7",
					"tooltip": "Increases the chance for Combustion to occur by "+(FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT*2.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnChance", (FIRE_INCENDIARY_COMBUSTION_CHANCE_PERCENT*2.2)/100); },
					"icon": "fireTraitIncendiaryCombustion1"
				},
				"Fy3": { //x
					"name": "Fire Trait: Seething Combustion 1",
					"tooltip": "Increases the duration of Combustion by "+FIRE_SEETHING_COMBUSTION_DURATION_SECONDS+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnDuration", FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*1000); },
					"icon": "fireTraitSeethingCombustion1"
				},
				"Fy4": { //x
					"name": "Fire Trait: Seething Combustion 2",
					"tooltip": "Increases the duration of Combustion by "+(FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*1.2)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnDuration", (FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*1.2)*1000); },
					"icon": "fireTraitSeethingCombustion1"
				},
				"Fy5": { //x
					"name": "Fire Trait: Seething Combustion 3",
					"tooltip": "Increases the duration of Combustion by "+(FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*1.4)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnDuration", (FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*1.4)*1000); },
					"icon": "fireTraitSeethingCombustion1"
				},
				"Fy6": { //x
					"name": "Fire Trait: Seething Combustion 4",
					"tooltip": "Increases the duration of Combustion by "+(FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*1.6)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnDuration", (FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*1.6)*1000); },
					"icon": "fireTraitSeethingCombustion1"
				},
				"Fy7": { //x
					"name": "Fire Trait: Seething Combustion 5",
					"tooltip": "Increases the duration of Combustion by "+(FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*1.8)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnDuration", (FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*1.8)*1000); },
					"icon": "fireTraitSeethingCombustion1"
				},
				"Fy8": { //x
					"name": "Fire Trait: Seething Combustion 6",
					"tooltip": "Increases the duration of Combustion by "+(FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*2.0)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnDuration", (FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*2.0)*1000); },
					"icon": "fireTraitSeethingCombustion1"
				},
				"Fy9": { //x
					"name": "Fire Trait: Seething Combustion 7",
					"tooltip": "Increases the duration of Combustion by "+(FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*2.2)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("DoubleBurnDuration", (FIRE_SEETHING_COMBUSTION_DURATION_SECONDS*2.2)*1000); },
					"icon": "fireTraitSeethingCombustion1"
				},
				"It6": { //x
					"name": "Ice Trait: Coolth",
					"tooltip": "Tier 2 Ice Spells causes the next "+COOLTH_NUM_CRITS_WHICH_COOL+" spell crits to cool you, reducing Hyperthermia by "+COOLTH_REDUCTION_PER_CRIT+" for each crit." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("CoolthReductionPerCrit", COOLTH_REDUCTION_PER_CRIT); CH2.currentCharacter.addTrait("CoolthNumCritsWhichCool", COOLTH_NUM_CRITS_WHICH_COOL); },
					"icon": "iceTraitCoolth"
				},
				"It7": { //x
					"name": "Ice Trait: Coolth 2",
					"tooltip": "Tier 2 Ice Spells causes the next "+(COOLTH_NUM_CRITS_WHICH_COOL)+" spell crits to cool you, reducing Hyperthermia by "+(COOLTH_REDUCTION_PER_CRIT*1.5)+" for each crit." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("CoolthReductionPerCrit", (COOLTH_REDUCTION_PER_CRIT*1.5)); CH2.currentCharacter.addTrait("CoolthNumCritsWhichCool", (COOLTH_NUM_CRITS_WHICH_COOL)); },
					"icon": "iceTraitCoolth"
				},
				"Iw6": { //x
					"name": "Ice Trait: Frosty Coolth 1",
					"tooltip": "Increases Coolth's Hyperthermia reduction by "+HYPERTHERMIA_REDUCTION+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("CoolthReductionPerCrit", HYPERTHERMIA_REDUCTION); },
					"icon": "iceTraitHyperthermia"
				},
				"Iw7": { //x
					"name": "Ice Trait: Frosty Coolth 2",
					"tooltip": "Increases Coolth's Hyperthermia reduction by "+(HYPERTHERMIA_REDUCTION*1.2)+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("CoolthReductionPerCrit", (HYPERTHERMIA_REDUCTION*1.2)); },
					"icon": "iceTraitHyperthermia"
				},
				"Iw8": { //x
					"name": "Ice Trait: Frosty Coolth 3",
					"tooltip": "Increases Coolth's Hyperthermia reduction by "+(HYPERTHERMIA_REDUCTION*1.4)+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("CoolthReductionPerCrit", (HYPERTHERMIA_REDUCTION*1.4)); },
					"icon": "iceTraitHyperthermia"
				},
				"Iw9": { //x
					"name": "Ice Trait: Frosty Coolth 4",
					"tooltip": "Increases Coolth's Hyperthermia reduction by "+(HYPERTHERMIA_REDUCTION*1.6)+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("CoolthReductionPerCrit", (HYPERTHERMIA_REDUCTION*1.6)); },
					"icon": "iceTraitHyperthermia"
				},
				"Ix6": { //x
					"name": "Ice Trait: Sustained Coolth 1",
					"tooltip": "Increases the number of spell crits affected by Coolth by "+COOLTH_REDUCTION_PER_CRIT_ADDITION+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("CoolthNumCritsWhichCool", COOLTH_REDUCTION_PER_CRIT_ADDITION); },
					"icon": "iceTraitCoolthCrit"
				},
				"Ix7": { //x
					"name": "Ice Trait: Sustained Coolth 2",
					"tooltip": "Increases the number of spell crits affected by Coolth by "+(COOLTH_REDUCTION_PER_CRIT_ADDITION*1.2)+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("CoolthNumCritsWhichCool", (COOLTH_REDUCTION_PER_CRIT_ADDITION*1.2)); },
					"icon": "iceTraitCoolthCrit"
				},
				"Ix8": { //x
					"name": "Ice Trait: Sustained Coolth 3",
					"tooltip": "Increases the number of spell crits affected by Coolth by "+(COOLTH_REDUCTION_PER_CRIT_ADDITION*1.4)+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("CoolthNumCritsWhichCool", (COOLTH_REDUCTION_PER_CRIT_ADDITION*1.4)); },
					"icon": "iceTraitCoolthCrit"
				},
				"Ix9": { //x
					"name": "Ice Trait: Sustained Coolth 4",
					"tooltip": "Increases the number of spell crits affected by Coolth by "+(COOLTH_REDUCTION_PER_CRIT_ADDITION*1.6)+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("CoolthNumCritsWhichCool", (COOLTH_REDUCTION_PER_CRIT_ADDITION*1.6)); },
					"icon": "iceTraitCoolthCrit"
				},
				"Lt6": { //x
					"name": "Lightning Trait: Energize",
					"tooltip": "Tier 2 Lightning Spells energize you for "+ENERGIZE_DURATION_SECONDS+" seconds, restoring "+ENERGIZE_ENERGY_PERCENT_RESTORED+"% total energy whenever Fatigue is loss." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("EnergizeDuration", ENERGIZE_DURATION_SECONDS); CH2.currentCharacter.addTrait("EnergizeEnergyRestoration", (ENERGIZE_ENERGY_PERCENT_RESTORED/100)); },
					"icon": "lightningTraitEnergize"
				},
				"Lt7": { //x
					"name": "Lightning Trait: Energize 2",
					"tooltip": "Tier 2 Lightning Spells energize you for "+(ENERGIZE_DURATION_SECONDS)+" seconds, restoring "+(ENERGIZE_ENERGY_PERCENT_RESTORED*1.5)+"% total energy whenever Fatigue is loss." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("EnergizeDuration", (ENERGIZE_DURATION_SECONDS)); CH2.currentCharacter.addTrait("EnergizeEnergyRestoration", ((ENERGIZE_ENERGY_PERCENT_RESTORED*1.5)/100)); },
					"icon": "lightningTraitEnergize"
				},
				"Lw6": { //x
					"name": "Lightning Trait: Innervating Energize 1",
					"tooltip": "Increases the amount of energy restored by Energize by "+ENERGIZE_ENERGY_PERCENT_RESTORED_ADDITIONAL+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("EnergizeEnergyRestoration", (ENERGIZE_ENERGY_PERCENT_RESTORED_ADDITIONAL/100)); },
					"icon": "lightningTraitEnergizeEnergyRestore"
				},
				"Lw7": { //x
					"name": "Lightning Trait: Innervating Energize 2",
					"tooltip": "Increases the amount of energy restored by Energize by "+(ENERGIZE_ENERGY_PERCENT_RESTORED_ADDITIONAL*1.2)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("EnergizeEnergyRestoration", ((ENERGIZE_ENERGY_PERCENT_RESTORED_ADDITIONAL*1.2)/100)); },
					"icon": "lightningTraitEnergizeEnergyRestore"
				},
				"Lw8": { //x
					"name": "Lightning Trait: Innervating Energize 3",
					"tooltip": "Increases the amount of energy restored by Energize by "+(ENERGIZE_ENERGY_PERCENT_RESTORED_ADDITIONAL*1.4)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("EnergizeEnergyRestoration", ((ENERGIZE_ENERGY_PERCENT_RESTORED_ADDITIONAL*1.4)/100)); },
					"icon": "lightningTraitEnergizeEnergyRestore"
				},
				"Lw9": { //x
					"name": "Lightning Trait: Innervating Energize 4",
					"tooltip": "Increases the amount of energy restored by Energize by "+(ENERGIZE_ENERGY_PERCENT_RESTORED_ADDITIONAL*1.6)+"%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("EnergizeEnergyRestoration", ((ENERGIZE_ENERGY_PERCENT_RESTORED_ADDITIONAL*1.6)/100)); },
					"icon": "lightningTraitEnergizeEnergyRestore"
				},
				"Lx6": { //x
					"name": "Lightning Trait: Sustained Energize 1",
					"tooltip": "Increases the duration of Energize by "+ENERGIZE_DURATION_SECONDS_ADDITIONAL+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("EnergizeDuration", ENERGIZE_DURATION_SECONDS_ADDITIONAL); },
					"icon": "lightningTraitEnergizeDuration"
				},
				"Lx7": { //x
					"name": "Lightning Trait: Sustained Energize 2",
					"tooltip": "Increases the duration of Energize by "+(ENERGIZE_DURATION_SECONDS_ADDITIONAL*1.2)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("EnergizeDuration", (ENERGIZE_DURATION_SECONDS_ADDITIONAL*1.2)); },
					"icon": "lightningTraitEnergizeDuration"
				},
				"Lx8": { //x
					"name": "Lightning Trait: Sustained Energize 3",
					"tooltip": "Increases the duration of Energize by "+(ENERGIZE_DURATION_SECONDS_ADDITIONAL*1.4)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("EnergizeDuration", (ENERGIZE_DURATION_SECONDS_ADDITIONAL*1.4)); },
					"icon": "lightningTraitEnergizeDuration"
				},
				"Lx9": { //x
					"name": "Lightning Trait: Sustained Energize 4",
					"tooltip": "Increases the duration of Energize by "+(ENERGIZE_DURATION_SECONDS_ADDITIONAL*1.6)+" seconds." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("EnergizeDuration", (ENERGIZE_DURATION_SECONDS_ADDITIONAL*1.6)); },
					"icon": "lightningTraitEnergizeDuration"
				},
				"Ft6": { //x
					"name": "Fire Trait: Warmth",
					"tooltip": "Tier 2 Fire Spells provides warmth, reducing Hypothermia by "+WARMTH_REDUCTION_PER_BURN+" when a monster takes Burn damage, up to "+WARMTH_MAX_NUMBER_OF_BURNS+" times." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("WarmthReductionPerBurn", WARMTH_REDUCTION_PER_BURN); CH2.currentCharacter.addTrait("WarmthMaxNumberOfReductions", WARMTH_MAX_NUMBER_OF_BURNS); },
					"icon": "fireTraitWarmth"
				},
				"Ft7": { //x
					"name": "Fire Trait: Warmth 2",
					"tooltip": "Tier 2 Fire Spells provides warmth, reducing Hypothermia by "+(WARMTH_REDUCTION_PER_BURN*1.5)+" when a monster takes Burn damage, up to "+(WARMTH_MAX_NUMBER_OF_BURNS)+" times." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("WarmthReductionPerBurn", (WARMTH_REDUCTION_PER_BURN*1.5)); CH2.currentCharacter.addTrait("WarmthMaxNumberOfReductions", (WARMTH_MAX_NUMBER_OF_BURNS)); },
					"icon": "fireTraitWarmth"
				},
				"Fw6": { //x
					"name": "Fire Trait: Thawing Warmth 1",
					"tooltip": "Increases Warmth's Hypothermia reduction by "+WARMTH_REDUCTION_PER_BURN_ADDITIONAL+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("WarmthReductionPerBurn", WARMTH_REDUCTION_PER_BURN_ADDITIONAL); },
					"icon": "fireTraitWarmthHypothermiaRedUp"
				},
				"Fw7": { //x
					"name": "Fire Trait: Thawing Warmth 2",
					"tooltip": "Increases Warmth's Hypothermia reduction by "+(WARMTH_REDUCTION_PER_BURN_ADDITIONAL*1.2)+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("WarmthReductionPerBurn", (WARMTH_REDUCTION_PER_BURN_ADDITIONAL*1.2)); },
					"icon": "fireTraitWarmthHypothermiaRedUp"
				},
				"Fw8": { //x
					"name": "Fire Trait: Thawing Warmth 3",
					"tooltip": "Increases Warmth's Hypothermia reduction by "+(WARMTH_REDUCTION_PER_BURN_ADDITIONAL*1.4)+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("WarmthReductionPerBurn", (WARMTH_REDUCTION_PER_BURN_ADDITIONAL*1.4)); },
					"icon": "fireTraitWarmthHypothermiaRedUp"
				},
				"Fw9": { //x
					"name": "Fire Trait: Thawing Warmth 4",
					"tooltip": "Increases Warmth's Hypothermia reduction by "+(WARMTH_REDUCTION_PER_BURN_ADDITIONAL * 4)+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("WarmthReductionPerBurn", (WARMTH_REDUCTION_PER_BURN_ADDITIONAL*1.6)); },
					"icon": "fireTraitWarmthHypothermiaRedUp"
				},
				"Fx6": { //x
					"name": "Fire Trait: Sustained Warmth 1",
					"tooltip": "Increases the number of Burns affected by Warmth by "+WARMTH_MAX_NUMBER_OF_BURNS_ADDITIONAL+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("WarmthMaxNumberOfReductions", WARMTH_MAX_NUMBER_OF_BURNS_ADDITIONAL); },
					"icon": "fireTraitWarmthBurnCountUp"
				},
				"Fx7": { //x
					"name": "Fire Trait: Sustained Warmth 2",
					"tooltip": "Increases the number of Burns affected by Warmth by "+(WARMTH_MAX_NUMBER_OF_BURNS_ADDITIONAL*1.2)+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("WarmthMaxNumberOfReductions", (WARMTH_MAX_NUMBER_OF_BURNS_ADDITIONAL*1.2)); },
					"icon": "fireTraitWarmthBurnCountUp"
				},
				"Fx8": { //x
					"name": "Fire Trait: Sustained Warmth 3",
					"tooltip": "Increases the number of Burns affected by Warmth by "+(WARMTH_MAX_NUMBER_OF_BURNS_ADDITIONAL*1.4)+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("WarmthMaxNumberOfReductions", (WARMTH_MAX_NUMBER_OF_BURNS_ADDITIONAL*1.4)); },
					"icon": "fireTraitWarmthBurnCountUp"
				},
				"Fx9": { //x
					"name": "Fire Trait: Sustained Warmth 4",
					"tooltip": "Increases the number of Burns affected by Warmth by "+(WARMTH_MAX_NUMBER_OF_BURNS_ADDITIONAL*1.6)+"." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("WarmthMaxNumberOfReductions", (WARMTH_MAX_NUMBER_OF_BURNS_ADDITIONAL*1.6)); },
					"icon": "fireTraitWarmthBurnCountUp"
				},
				"Ft8": { //x
					"name": "Fire Trait: Explosion",
					"tooltip": "Tier 3 Fire Spells cause the current monster to explode on death, dealing "+FIRE_EXPLOSION_DAMAGE_PERCENT+"% burn damage they have suffered to the next monster." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireExplosionDamagePercent", FIRE_EXPLOSION_DAMAGE_PERCENT/100); },
					"icon": "fireTraitExplosion"
				},
				"Ft9": { //x
					"name": "Fire Trait: Explosion 2",
					"tooltip": "Tier 3 Fire Spells cause the current monster to explode on death, dealing "+(FIRE_EXPLOSION_DAMAGE_PERCENT*2.0)+"% burn damage they have suffered to the next monster." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("FireExplosionDamagePercent", (FIRE_EXPLOSION_DAMAGE_PERCENT*2.0)/100); },
					"icon": "fireTraitExplosion"
				},
				"Lt8": { //x
					"name": "Lightning Trait: Circuit",
					"tooltip": "Tier 3 Lightning Spells strike the current monster an additional time for "+LIGHTNING_CIRCUIT_DAMAGE_PERCENT+"% damage after each chain." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCircuitDamagePercent", LIGHTNING_CIRCUIT_DAMAGE_PERCENT/100); },
					"icon": "lightningTraitCircuit"
				},
				"Lt9": { //x
					"name": "Lightning Trait: Circuit 2",
					"tooltip": "Tier 3 Lightning Spells strike the current monster an additional time for "+(LIGHTNING_CIRCUIT_DAMAGE_PERCENT*2.0)+"% damage after each chain." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("LightningCircuitDamagePercent", (LIGHTNING_CIRCUIT_DAMAGE_PERCENT*2.0)/100); },
					"icon": "lightningTraitCircuit"
				},
				"It8": { //x
					"name": "Ice Trait: Shatter",
					"tooltip": "Tier 3 Ice Spells that kill a monster cause it to shatter, dealing "+SHATTER_DAMAGE_PERCENT+"% of the damage to each of the next "+SHATTER_NUM_MONSTERS+" monsters." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("ShatterDamagePercent", SHATTER_DAMAGE_PERCENT/100); CH2.currentCharacter.addTrait("ShatterDamageMonsters", SHATTER_NUM_MONSTERS); },
					"icon": "iceTraitShatter"
				},
				"It9": { //x
					"name": "Ice Trait: Shatter 2",
					"tooltip": "Tier 3 Ice Spells that kill a monster cause it to shatter, dealing "+(SHATTER_DAMAGE_PERCENT*2.0)+"% of the damage to each of the next "+(SHATTER_NUM_MONSTERS*1.2)+" monsters." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("ShatterDamagePercent", (SHATTER_DAMAGE_PERCENT*2.0)/100); CH2.currentCharacter.addTrait("ShatterDamageMonsters", (SHATTER_NUM_MONSTERS*1.2)); },
					"icon": "iceTraitShatter"
				},
				"Ms1": { //x
					"name": "Neutral: Energon Cube",
					"tooltip": "" ,
					"flavorText": function(){ return getSpell("Energon Cube").extendedTooltip.body; },
					"setupFunction": function() {},
					"loadFunction": function(){ unlockSpell("Energon Cube"); },
					"purchaseFunction": function() { unlockSpell("Energon Cube"); },
					"icon": "iceMangoSlurry"
				},
				"Ns1": { //x
					"name": "Neutral: Cut and Paste",
					"tooltip": "" ,
					"flavorText": function(){ return "Cut: "+getSpell("cut").extendedTooltip.body+"\n\n"+"Paste: "+getSpell("paste").extendedTooltip.body; },
					"setupFunction": function() {},
					"loadFunction": function(){ unlockSpell("cut"); unlockSpell("paste"); },
					"purchaseFunction": function() { unlockSpell("cut"); unlockSpell("paste"); },
					"icon": "utilityCutAndPaste"
				},
				"Os1": { //x
					"name": "Neutral: Dark Ritual",
					"tooltip": "" ,
					"flavorText": function(){ return getSpell("iceFireDarkRitual").extendedTooltip.body; },
					"setupFunction": function() {},
					"loadFunction": function(){ unlockSpell("iceFireDarkRitual"); },
					"purchaseFunction": function() { unlockSpell("iceFireDarkRitual"); },
					"icon": "darkRitual"
				},
				"Ms5": { //x
					"name": "Ice and Lightning: Synergy",
					"tooltip": "Ice and Lightning Spells gain the benefit of all stats that affect either Ice or Lightning Magic for 30 seconds per charge, up to 5 charges." ,
					"flavorText": function(){ return getSpell("synergyIceLightning").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpell("synergyIceLightning"); },
					"purchaseFunction": function() { unlockSpell("synergyIceLightning"); CH2.currentCharacter.addTrait("IceLightningBuffDuration", 30000); },
					"icon": "synergyIceLightning1"
				},
				"Ms7": { //x
					"name": "Ice and Lightning: Synergy",
					"tooltip": "Ice and Lightning Spells gain the benefit of all stats that affect either Ice or Lightning Magic for 30 seconds per charge, up to 5 charges." ,
					"flavorText": function(){ return getSpell("synergyIceLightning").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpell("synergyIceLightning"); },
					"purchaseFunction": function() { unlockSpell("synergyIceLightning"); CH2.currentCharacter.addTrait("IceLightningBuffDuration", 30000); },
					"icon": "synergyIceLightning1"
				},
				"Ns5": { //x
					"name": "Lightning and Fire: Synergy",
					"tooltip": "Lightning and Fire Spells gain the benefit of all stats that affect either Lightning and Fire Magic for 30 seconds per charge, up to 5 charges." ,
					"flavorText": function(){ return getSpell("synergyFireLightning").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpell("synergyFireLightning"); },
					"purchaseFunction": function() { unlockSpell("synergyFireLightning"); CH2.currentCharacter.addTrait("LightningFireBuffDuration", 30000); },
					"icon": "synergyLightningFire1"
				},
				"Ns7": { //x
					"name": "Lightning and Fire: Synergy",
					"tooltip": "Lightning and Fire Spells gain the benefit of all stats that affect either Lightning and Fire Magic for 30 seconds per charge, up to 5 charges." ,
					"flavorText": function(){ return getSpell("synergyFireLightning").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpell("synergyFireLightning"); },
					"purchaseFunction": function() { unlockSpell("synergyFireLightning"); CH2.currentCharacter.addTrait("LightningFireBuffDuration", 30000); },
					"icon": "synergyLightningFire1"
				},
				"Os5": { //x
					"name": "Ice and Fire: Synergy",
					"tooltip": "Ice and Fire Spells gain the benefit of all stats that affect either Ice or Fire Magic for 30 seconds per charge, up to 5 charges." ,
					"flavorText": function(){ return getSpell("synergyIceFire").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpell("synergyIceFire"); },
					"purchaseFunction": function() { unlockSpell("synergyIceFire"); CH2.currentCharacter.addTrait("IceFireBuffDuration", 30000); },
					"icon": "synergyIceFire1"
				},
				"Os7": { //x
					"name": "Ice and Fire: Synergy",
					"tooltip": "Ice and Fire Spells gain the benefit of all stats that affect either Ice or Fire Magic for 30 seconds per charge, up to 5 charges." ,
					"flavorText": function(){ return getSpell("synergyIceFire").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpell("synergyIceFire"); },
					"purchaseFunction": function() { unlockSpell("synergyIceFire"); CH2.currentCharacter.addTrait("IceFireBuffDuration", 30000); },
					"icon": "synergyIceFire1"
				},
				"Ms9": { //x
					"name": "Ice and Lightning: Damage Spell",
					"tooltip": "Deal damage equivalent to Rank 9 Ice and Lightning spells. Benefits from all Ice and Lightning stats. Gains 50% damage per charge, up to 5 charges." ,
					"flavorText": function(){ return getSpell("iceLightningDamage").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpell("iceLightningDamage"); },
					"purchaseFunction": function() { unlockSpell("iceLightningDamage"); },
					"icon": "dualIceLightningDamageExtreme"
				},
				"Ns9": { //x
					"name": "Lightning and Fire: Damage Spell",
					"tooltip": "Deal damage equivalent to Rank 9 Lightning and Fire spells. Benefits from all Lightning and Fire stats. Gains 50% damage per charge, up to 5 charges." ,
					"flavorText": function(){ return getSpell("lightningFireDamage").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpell("lightningFireDamage"); },
					"purchaseFunction": function() { unlockSpell("lightningFireDamage"); },
					"icon": "dualLightningFireDamageExtreme"
				},
				"Os9": { //x
					"name": "Ice and Fire: Damage Spell",
					"tooltip": "Deal damage equivalent to Rank 9 Ice and Fire spells. Benefits from all Ice and Fire stats. Gains 50% damage per charge, up to 5 charges." ,
					"flavorText": function(){ return getSpell("iceFireDamage").extendedTooltip.body; },
					"loadFunction": function(){ unlockSpell("iceFireDamage"); },
					"purchaseFunction": function() { unlockSpell("iceFireDamage"); },
					"icon": "dualIceFireDamageExtreme"
				},
				"Mt9": { //x
					"name": "Ice and Lightning: Thundersnow",
					"tooltip": "Summons a thunderstorm, which strikes the monster with ice or lightning whenever a spell is cast. Affects two spells per charge, up to 10 charges." ,
					"flavorText": function(){ return getSpell("iceLightningThundersnow").extendedTooltip.body; },
					"loadFunction": function() {unlockSpell("iceLightningThundersnow");},
					"purchaseFunction": function() { unlockSpell("iceLightningThundersnow"); },
					"icon": "dualUltimaIceLightning"
				},
				"Nt9": { //x
					"name": "Lightning and Fire: Solar Storm",
					"tooltip": "A solar flare manifests. All monsters lose 1% of their current health per charge, up to 10 charges. You lose all energy and gain 100 Hyperthermia." ,
					"flavorText": function(){ return getSpell("fireLightningSolarStorm").extendedTooltip.body; },
					"loadFunction": function() {unlockSpell("fireLightningSolarStorm");},
					"purchaseFunction": function() { unlockSpell("fireLightningSolarStorm"); },
					"icon": "dualUltimaLightningFire"
				},
				"Ot9": { //x
					"name": "Ice and Fire: Comet Shower",
					"tooltip": "Comets rain from the heavens, striking the monster at random intervals. Occurs three times per charge, up to 10 charges." ,
					"flavorText": function(){ return getSpell("iceFireCometShower").extendedTooltip.body; },
					"loadFunction": function() {unlockSpell("iceFireCometShower");},
					"purchaseFunction": function() { unlockSpell("iceFireCometShower"); },
					"icon": "dualUltimaIceFire"
				},
				"Qs0": { //x
					"name": "Runecorder",
					"tooltip": "Unlocks the Runecorder." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() {CH2.currentCharacter.hasUnlockedAutomator = true; CH2.currentCharacter.addTrait("HasAutomator", 1); },
					"icon": "runecorder"
				},
				"": {
					"name": "NULL",
					"tooltip": "Does Absolutely NOTHING.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {},
					"icon": "goldx3"
				}
			}
					
			wizard.levelGraph = LevelGraph.loadGraph(wizard.levelGraphObject, wizard);
			
			wizard.name = "Wizard";
			wizard.flavorName = "Cursor"
			wizard.flavorClass = "The Cursed Wizard"
			wizard.flavor = "A character who spells doom to those around him.";
			wizard.characterSelectOrder = 2;
			wizard.availableForCreation = true;
			wizard.visibleOnCharacterSelect = true;
			wizard.defaultSaveName = "wizard";
//			wizard.levelCostScaling = "linear10";
			wizard.startingSkills = [];
			
			wizard.statBaseValues[CH2.STAT_TOTAL_ENERGY] = 300;
			wizard.statBaseValues[CH2.STAT_DAMAGE] = 0.7; // 0.25;
			
			wizard.energy = 300;
			wizard.monstersPerZone = 10;
			wizard.monsterHealthMultiplier = 5;
			wizard.attackRange = 300;
			wizard.attackMsDelay = 2000;
			
			wizard.upgradeableStats = Character.DEFAULT_UPGRADEABLE_STATS;
			
			Characters.startingDefaultInstances[wizard.name] = wizard;
			
			//RUNES
			
			var runeFire:Skill = new Skill();
			runeFire.modName = MOD_INFO["name"];
			runeFire.name = "Igni";
			runeFire.description = "";
			runeFire.cooldown = 0;
			runeFire.iconId = 204;
			runeFire.manaCost = 0;
			runeFire.energyCost = 0;
			runeFire.consumableOnly = false;
			runeFire.minimumAscensions = 0;
			runeFire.effectFunction = function(){ runeEffect("1"); };
			runeFire.ignoresGCD = true;
			runeFire.maximumRange = 300;
			runeFire.minimumRange = 0;
			runeFire.tooltipFunction = function():Object{ return this.skillTooltip("Fire Rune\n\nUse runes to cast incantations. See the Spells tab for a list of incantations you have unlocked."); };
			Character.staticSkillInstances[runeFire.uid] = runeFire;
			
			var runeIce:Skill = new Skill();
			runeIce.modName = MOD_INFO["name"];
			runeIce.name = "Frigo";
			runeIce.description = "";
			runeIce.cooldown = 0;
			runeIce.iconId = 205;
			runeIce.manaCost = 0;
			runeIce.energyCost = 0;
			runeIce.consumableOnly = false;
			runeIce.minimumAscensions = 0;
			runeIce.effectFunction = function(){ runeEffect("2"); };
			runeIce.ignoresGCD = true;
			runeIce.maximumRange = 300;
			runeIce.minimumRange = 0;
			runeIce.tooltipFunction = function():Object{ return this.skillTooltip("Ice Rune\n\nUse runes to cast incantations. See the Spells tab for a list of incantations you have unlocked."); };
			Character.staticSkillInstances[runeIce.uid] = runeIce;
			
			var runeLightning:Skill = new Skill();
			runeLightning.modName = MOD_INFO["name"];
			runeLightning.name = "Lor Vas";
			runeLightning.description = "";
			runeLightning.cooldown = 0;
			runeLightning.iconId = 206;
			runeLightning.manaCost = 0;
			runeLightning.energyCost = 0;
			runeLightning.consumableOnly = false;
			runeLightning.minimumAscensions = 0;
			runeLightning.effectFunction = function(){ runeEffect("3"); };
			runeLightning.ignoresGCD = true;
			runeLightning.maximumRange = 300;
			runeLightning.minimumRange = 0;
			runeLightning.tooltipFunction = function():Object{ return this.skillTooltip("Lightning Rune\n\nUse runes to cast incantations. See the Spells tab for a list of incantations you have unlocked."); };
			Character.staticSkillInstances[runeLightning.uid] = runeLightning;
			
			var rune2:Skill = new Skill();
			rune2.modName = MOD_INFO["name"];
			rune2.name = "Kras";
			rune2.description = "";
			rune2.cooldown = 0;
			rune2.iconId = 207;
			rune2.manaCost = 0;
			rune2.energyCost = 0;
			rune2.consumableOnly = false;
			rune2.minimumAscensions = 0;
			rune2.effectFunction = function(){ runeEffect("4"); };
			rune2.ignoresGCD = true;
			rune2.maximumRange = 300;
			rune2.minimumRange = 0;
			rune2.tooltipFunction = function():Object{ return this.skillTooltip("Neutral Rune\n\nUse runes to cast incantations. See the Spells tab for a list of incantations you have unlocked."); };
			Character.staticSkillInstances[rune2.uid] = rune2;
			
			var rune3:Skill = new Skill();
			rune3.modName = MOD_INFO["name"];
			rune3.name = "Ohm";
			rune3.description = "";
			rune3.cooldown = 0;
			rune3.iconId = 208;
			rune3.manaCost = 0;
			rune3.energyCost = 0;
			rune3.consumableOnly = false;
			rune3.minimumAscensions = 0;
			rune3.effectFunction = function(){ runeEffect("5"); };
			rune3.ignoresGCD = true;
			rune3.maximumRange = 300;
			rune3.minimumRange = 0;
			rune3.tooltipFunction = function():Object{ return this.skillTooltip("Neutral Rune\n\nUse runes to cast incantations. See the Spells tab for a list of incantations you have unlocked."); };
			Character.staticSkillInstances[rune3.uid] = rune3;
			
			var rune4:Skill = new Skill();
			rune4.modName = MOD_INFO["name"];
			rune4.name = "Yrdei";
			rune4.description = "";
			rune4.cooldown = 0;
			rune4.iconId = 209;
			rune4.manaCost = 0;
			rune4.energyCost = 0;
			rune4.consumableOnly = false;
			rune4.minimumAscensions = 0;
			rune4.effectFunction = function(){ runeEffect("6"); };
			rune4.ignoresGCD = true;
			rune4.maximumRange = 300;
			rune4.minimumRange = 0;
			rune4.tooltipFunction = function():Object{ return this.skillTooltip("Neutral Rune\n\nUse runes to cast incantations. See the Spells tab for a list of incantations you have unlocked."); };
			Character.staticSkillInstances[rune4.uid] = rune4;		
			
			var rune5:Skill = new Skill();
			rune5.modName = MOD_INFO["name"];
			rune5.name = "Helio";
			rune5.description = "";
			rune5.cooldown = 0;
			rune5.iconId = 210;
			rune5.manaCost = 0;
			rune5.energyCost = 0;
			rune5.consumableOnly = false;
			rune5.minimumAscensions = 0;
			rune5.effectFunction = function(){ runeEffect("7"); };
			rune5.ignoresGCD = true;
			rune5.maximumRange = 300;
			rune5.minimumRange = 0;
			rune5.tooltipFunction = function():Object{ return this.skillTooltip("Neutral Rune\n\nUse runes to cast incantations. See the Spells tab for a list of incantations you have unlocked."); };
			Character.staticSkillInstances[rune5.uid] = rune5;
			
			var activateRune:Skill = new Skill();
			activateRune.modName = MOD_INFO["name"];
			activateRune.name = "Exe";
			activateRune.description = "";
			activateRune.cooldown = 0;
			activateRune.iconId = 215;
			activateRune.manaCost = 0;
			activateRune.energyCost = 0;
			activateRune.consumableOnly = false;
			activateRune.minimumAscensions = 0;
			activateRune.effectFunction = function(){ runeEffect("8"); };
			activateRune.ignoresGCD = true;
			activateRune.maximumRange = 300;
			activateRune.minimumRange = 0;
			activateRune.tooltipFunction = function():Object{ return this.skillTooltip("Activation Rune\n\nUse runes to cast incantations. See the Spells tab for a list of incantations you have unlocked."); };
			Character.staticSkillInstances[activateRune.uid] = activateRune;
		}
		
		public function onStaticDataLoaded(staticData:Object):void
		{
			
		}
		
		public function onUserDataLoaded():void
		{
			
		}
		
		public function setTraitIfLess(traitName:String, minimumValue:int):void
		{
			if (CH2.currentCharacter.getTrait(traitName) < minimumValue)
			{
				CH2.currentCharacter.setTrait(traitName, minimumValue);
			}
		}
		
		//##############################################
		//############## WIZARD OVERRIDES ##############
		//##############################################
		
		public function onCharacterCreated(characterInstance:Character):void
		{
			if (characterInstance.name == CHARACTER_NAME)
			{
				characterInstance.assetGroupName = CHARACTER_ASSET_GROUP;
//				characterInstance.statValueFunctions[CH2.STAT_DAMAGE] = Character.exponentialMultiplier(LEVEL_UP_GROWTH_RATE_MULTIPLIER);
				
				characterInstance.updateHandler = this;
				characterInstance.autoAttackHandler = this;
				characterInstance.clickAttackHandler = this;
				characterInstance.onUsedSkillHandler = this;
				characterInstance.getLevelUpCostToNextLevelHandler = this;
//				characterInstance.getItemDamageHandler = this;
				characterInstance.onCharacterDisplayCreatedHandler = this;
				characterInstance.canUseSkillHandler = this;
				characterInstance.addGildHandler = this;
				characterInstance.isAutomatorPanelUnlockedHandler = this;
				characterInstance.onCharacterUnloadedHandler = this;
				characterInstance.attackHandler = this;
				characterInstance.onCharacterLoadedHandler = this;
				
				characterInstance.worldsPerGild = 50;
				GraphPanel.HAS_AUTOMATOR_PANEL = false;
				BuffSlotUI.SHOW_BUFF_BG = false;
				
				setupCharges();
				setupSpells();
				
				for (var key:String in characterInstance.traits)
				{
					if (key.indexOf("recording") > -1)
					{
						var loadedRecording:Recording = new Recording();
						loadedRecording.fromJson(characterInstance.traits[key]);
						if (loadedRecording.id > 0)
						{
							recordings.push(loadedRecording);
						}
					}
				}
				if (recordings.length == 0)
				{
					recordings.push(new Recording());
				}
				Trace("A");
				
				if (CH2.currentCharacter)
				{
					stopAllRecording();
					stopAllPlayback();
					
					if (characterInstance.getTrait("solarFlarePercentHealth") > 0)
					{
						startsolarFlareBuff();
					}
				}
				
				if (isCastingSpell)
				{
					endSpell();
				}
			}
		}
		
		public function updateOverride(dt:int):void
		{
			if (isCastingSpell)
			{
				spellUpdate();
			}
			if (CH2.currentCharacter.energy < CH2.currentCharacter.maxEnergy)
			{
				CH2.currentCharacter.addEnergy((dt / 1000) * ENERGY_REGEN_PER_SECOND, false);
			}
			if (CH2.currentCharacter.mana < CH2.currentCharacter.maxMana)
			{
				CH2.currentCharacter.addMana((dt / 2000) * MANA_REGEN_PER_SECOND, false);
			}
			
			//Playback of recording
			doRecordingPlayback(dt);
			spellBar.refresh(dt, getSpellsForBar());
			CH2.currentCharacter.updateDefault(dt);
		}
		
		public function doRecordingPlayback(dt:int):void
		{
			for (var i:int = 0; i < recordings.length; i++)
			{
				recordings[i].update(dt);
			}
		}
		
		public function autoAttackOverride():void
		{
			if (!CH2.currentCharacter.isCasting && pendingRunes.length == 0 && (lastSpellActivationTime == 0 || CH2.currentCharacter.attackDelay < (CH2.user.totalMsecsPlayed - lastSpellActivationTime)))
			{
				var attackData:AttackData = new AttackData();
				attackData.isAutoAttack = true;
				attackData.damage = CH2.currentCharacter.autoAttackDamage;
				
				CH2.currentCharacter.characterDisplay.playAutoAttack();
				CH2.currentCharacter.timeSinceLastAutoAttack = 0;
				CH2.currentCharacter.attack(attackData);
			}
		}
		
		public function onCharacterLoadedOverride():void
		{
			if (CH2.currentCharacter)
			{
				stopAllRecording();
				stopAllPlayback();
				
				recordings = new Vector.<Recording>();
				for (var key:String in CH2.currentCharacter.traits)
				{
					if (key.indexOf("recording") > -1)
					{
						var loadedRecording:Recording = new Recording();
						loadedRecording.fromJson(CH2.currentCharacter.traits[key]);
						if (loadedRecording.id > 0)
						{
							recordings.push(loadedRecording);
						}
					}
				}
				if (recordings.length == 0)
				{
					recordings.push(new Recording());
				}
				Trace("B");
				
				if (CH2.currentCharacter.getTrait("solarFlarePercentHealth") > 0)
				{
					startsolarFlareBuff();
				}
			}
		}
		
		public var usedLightningZap:Boolean = false;
		public var usedFireZap:Boolean = false;
		public function clickAttackOverride(doesCostEnergy:Boolean = true):void
		{
			//Loop over recordings and check for is recording and assign action
			for (var i:int = 0; i < recordings.length; i++)
			{
				if (recordings[i].isRecording)
				{
					recordings[i].logRecordedAction("999");
				}
			}
			if (!CH2.currentCharacter.isCasting && pendingRunes.length == 0)
			{
				var buffName:String = "LightningZap";
				var buffName2:String = "FireZap";
				var hasLightningZap:Boolean = CH2.currentCharacter.buffs.hasBuffByName(buffName);
				var hasFireZap:Boolean = CH2.currentCharacter.buffs.hasBuffByName(buffName2);
				if (hasLightningZap)
				{
					useLightningZap();
					usedLightningZap = true;
				}
				if (hasFireZap)
				{
					useFireZap();
					usedFireZap = true;
				}
				
				if(hasFireZap || hasLightningZap)
				{
					CH2.currentCharacter.clickAttackDefault(false);
				}
				else
				{
					CH2.currentCharacter.clickAttackDefault(doesCostEnergy);
				}
			}
		}
		
		public function attackOverride(attackData:AttackData):void
		{
			if (usedLightningZap || usedFireZap)
			{
				if (usedLightningZap && CH2.currentCharacter.buffs.hasBuffByName("LightningZap"))
				{
					attackData.damage.plusEquals(CH2.currentCharacter.buffs.getBuff("LightningZap").stateValues["spellDamage"]);
				}
				if (usedFireZap && CH2.currentCharacter.buffs.hasBuffByName("FireZap"))
				{
					attackData.damage.plusEquals(CH2.currentCharacter.buffs.getBuff("FireZap").stateValues["spellDamage"]);
				}
				CH2.currentCharacter.attackDefault(attackData);
				usedLightningZap = false;
				usedFireZap = false;
			}
			else
			{
				CH2.currentCharacter.attackDefault(attackData);
			}
		}
		
		public function onUsedSkillOverride(skill:Skill):void
		{
			if (CH2.currentCharacter.state == Character.STATE_WALKING && !CH2.world.bossEncounter)
			{
				CH2.currentCharacter.teleport();
			}
			for (var i:int = 0; i < recordings.length; i++)
			{
				if (recordings[i].isRecording)
				{
					recordings[i].logRecordedAction(skill.uid);
				}
			}
			CH2.currentCharacter.onUsedSkillDefault(skill);
		}
		
		public function canUseSkillOverride(skill:Skill):Boolean
		{
			if ( CH2.world.getNextMonster() == null)
			{
				return false;
			}
			return (
				!skill.isOnCooldown && 
				CH2.currentCharacter.energy >= skill.getCalculatedEnergyCost() && 
				CH2.currentCharacter.mana >= skill.getManaCost() && 
				(CH2.currentCharacter.gcdRemaining <= 0 || skill.ignoresGCD)
			);
		}
		
		public function addGildOverride(worldId:Number):void
		{
			deleteAllRecordings();
			deactivateAllSpells();
			stopAllPlayback();
			stopAllRecording();
			
			//need to disable the automator tab
			
			var gildNumber:int = Math.floor((CH2.currentCharacter.currentWorldId - 1) / CH2.currentCharacter.worldsPerGild);
			
			//FOR HOTARA: Insert skill tree changes here.
			
			//do the default tear down
			CH2.currentCharacter.addGildDefault(worldId);
		}
		
		public function isAutomatorPanelUnlockedOverride():Boolean
		{
			return CH2.currentCharacter.getTrait("HasAutomator") > 0;
		}
		
		public function onCharacterUnloadedOverride():void
		{
			deactivateAllSpells();
			stopAllPlayback();
			stopAllRecording();
			GraphPanel.HAS_AUTOMATOR_PANEL = true;
			BuffSlotUI.SHOW_BUFF_BG = true;
			
				Trace("C");
			
			CH2.currentCharacter.onCharacterUnloadedDefault();
		}
		
		public function getLevelUpCostToNextLevelOverride(level:Number):BigNumber
		{
			if (level <= 7)
			{
				return new BigNumber(600 + (level - 2) * 400);
			}
			return new BigNumber(2000 + (level - 6) * 500);
			
/*			if (level <= 10) {
				return new BigNumber(225 + (level - 2) * 180);
			}
			if (level <= 19) {
				return new BigNumber(1860 + (level - 11) * 255);
			}
			return new BigNumber(4380 + (level - 20) * 500);
*/
		}

		public function getItemDamageOverride(item:Item):BigNumber
		{
			if (item.skills.length > 0)
			{
				return new BigNumber(0);
			}
			var result:BigNumber = item.baseCost.divideN(30);
			if (CH2.currentAscensionWorld && CH2.currentAscensionWorld.worldNumber <= 2)
			{
				result.timesEqualsN(Math.pow(0.86, item.rank - 1));
			}
			else
			{
				result.timesEqualsN(Math.pow(0.9, item.rank - 1));
			}
			result.timesEqualsN(1.0 + item.bonusDamage);
			
			if (item.rank < 4)
			{
				result.timesEqualsN(5 - item.rank);
			}
			
			result.floorInPlace();
			result.timesEqualsN(item.level);
			//result.timesEqualsN(Item.rarities[item.itemRarityId].baseDamageMultiplier);
			result.timesEqualsN(Math.pow(CH2.currentCharacteritem10LvlDmgMultiplier, Math.floor(item.level / 10)));
			result.timesEqualsN(Math.pow(CH2.currentCharacteritem20LvlDmgMultiplier, Math.floor(item.level / 20)));
			if (item.level >= 50)
			{
				result.timesEqualsN(CH2.currentCharacteritem50LvlDmgMultiplier);
				if (item.level >= 100)
				{
					result.timesEqualsN(CH2.currentCharacteritem100LvlDmgMultiplier);
				}
			}
			result.timesEqualsN(CH2.currentCharacter.getMultiplierForItemType(item.type));
			return result;
		}
		
		public function onCharacterDisplayCreatedOverride(display:CharacterDisplay):void
		{
			display.playDash = dashAnimation;
			display.playWalk = walkAnimation;
			display.playWalkEnd = walkEndAnimation;
			display.msBetweenStepSounds = Number.MAX_VALUE; //doesn't play step sound
			
			// Load audio
			SoundManager.instance.loadAudioClass("audio/wizard/critical_hit");
			SoundManager.instance.loadAudioClass("audio/wizard/hit");
			SoundManager.instance.loadAudioClass("audio/wizard/apparate");
			SoundManager.instance.loadAudioClass("audio/wizard/disapparate");
			
			SoundManager.instance.loadAudioClass("audio/wizard/burn");
			SoundManager.instance.loadAudioClass("audio/wizard/chainlightning_command");
			SoundManager.instance.loadAudioClass("audio/wizard/cut");
			SoundManager.instance.loadAudioClass("audio/wizard/damage_all_monsters");
			SoundManager.instance.loadAudioClass("audio/wizard/dark_ritual");
			SoundManager.instance.loadAudioClass("audio/wizard/energize");
			SoundManager.instance.loadAudioClass("audio/wizard/failure");
			SoundManager.instance.loadAudioClass("audio/wizard/fire_1_impact");
			SoundManager.instance.loadAudioClass("audio/wizard/fire_1_spawn");
			SoundManager.instance.loadAudioClass("audio/wizard/fire_5_impact");
			SoundManager.instance.loadAudioClass("audio/wizard/fire_5_spawn");
			SoundManager.instance.loadAudioClass("audio/wizard/fire_9_impact");
			SoundManager.instance.loadAudioClass("audio/wizard/fire_9_spawn");
			SoundManager.instance.loadAudioClass("audio/wizard/ice_1_spawn");
			SoundManager.instance.loadAudioClass("audio/wizard/ice_5_impact");
			SoundManager.instance.loadAudioClass("audio/wizard/ice_5_spawn");
			SoundManager.instance.loadAudioClass("audio/wizard/ice_9_impact");
			SoundManager.instance.loadAudioClass("audio/wizard/ice_9_spawn");
			SoundManager.instance.loadAudioClass("audio/wizard/ice1_impact");
			SoundManager.instance.loadAudioClass("audio/wizard/lightning_1_impact");
			SoundManager.instance.loadAudioClass("audio/wizard/lightning_1_spawn");
			SoundManager.instance.loadAudioClass("audio/wizard/lightning_5_impact");
			SoundManager.instance.loadAudioClass("audio/wizard/lightning_5_spawn");
			SoundManager.instance.loadAudioClass("audio/wizard/lightning_9_impact");
			SoundManager.instance.loadAudioClass("audio/wizard/lightning_9_spawn");
			SoundManager.instance.loadAudioClass("audio/wizard/massive_orange_fish");
			SoundManager.instance.loadAudioClass("audio/wizard/paste");
			SoundManager.instance.loadAudioClass("audio/wizard/rune");
			SoundManager.instance.loadAudioClass("audio/wizard/stone_of_time");
			SoundManager.instance.loadAudioClass("audio/wizard/synergy");
		}
		
		public function dashAnimation(distance:Number = 0):void
		{
			var teleportOriginWorldY:Number = CH2.currentCharacter.y - distance;
			var animation:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip("Wizard_clickDashStart", 60);
			animation.isLooping = false;
			CH2.world.addEffect(animation, CH2.world.roomsFront, CH2.currentCharacter.x, teleportOriginWorldY);
			CH2.currentCharacter.characterDisplay.playDashDefault(distance);
		}
		
		public function walkAnimation():void
		{
			CH2.currentCharacter.characterDisplay.playWalkDefault();
			SoundManager.instance.playSound("apparate");
		}
		
		public function walkEndAnimation():void
		{
			CH2.currentCharacter.characterDisplay.playWalkEndDefault();
			SoundManager.instance.playSound("disapparate");
		}
		
		public static function addSkill(name:String):Function
		{
			return function():void {
				var skill:Skill = CH2.currentCharacter.getStaticSkill(name);
				CH2.currentCharacter.activateSkill(skill.uid);
			}
		}
		
		//##########################################################################
		//################################ UI SETUP ################################
		//##########################################################################
		
		public function onUICreated():void
		{
			if (CH2.currentCharacter.name == "Wizard")
			{
				HUD.UI_POSITIONS["FullScreen"]["UI_Components"]["_buffBar.display"]["y"] = 560;
				HUD.UI_POSITIONS["HalfScreen"]["UI_Components"]["_buffBar.display"]["y"] = 560;
				HUD.UI_POSITIONS["RightScreen"]["UI_Components"]["_buffBar.display"]["y"] = 560;
				
				spellBar = new SpellBar();
				
				CH2UI.instance.mainUI.hud._buffBar.buffs = buffSelectionFunction;
				spellBar.display.y = 60;
				CH2UI.instance.mainUI.hud._buffBar.display.addChild(spellBar.display);
				
				CH2UI.instance.mainUI.mainPanel.miscellaneousPanel.tabClasses[0] = WizardStatsSubTab;
				
				spellsPanel = new SpellsPanel();
				CH2UI.instance.mainUI.mainPanel.unregisterTab(2);
				CH2UI.instance.mainUI.mainPanel.registerTab(2, "Spells", spellsPanel, 3, function(){ return getActiveSpells().length > 0; }, shouldShowSpellsPanelGlow, function(){ });

				automatorPanel = new WizardAutomatorPanel();
				CH2UI.instance.mainUI.mainPanel.unregisterTab(3);
				CH2UI.instance.mainUI.mainPanel.registerTab(3, "Runecorder", automatorPanel, 5, CH2.currentCharacter.isAutomatorPanelUnlocked, function():Boolean{ return false; }, function(){ });
				
				GraphPanel.HAS_AUTOMATOR_PANEL = false;
				BuffSlotUI.SHOW_BUFF_BG = false;
				
				hasUnseenSpell = false;
			}
		}
		
		public function buffSelectionFunction():Array
		{
			var returnValue:Array = [];
			for (var i:int = 0; i < CH2.currentCharacter.buffs.buffs.length; i++)
			{
				if (!CH2.currentCharacter.buffs.buffs[i].stateValues.hasOwnProperty("hideFromBuffBar"))
				{
					returnValue.push(CH2.currentCharacter.buffs.buffs[i]);
				}
			}
			return returnValue;
		}
		
		public function shouldShowSpellsPanelGlow():Boolean
		{
			return hasUnseenSpell;
		}
		
		//##########################################################################
		//###################### RUNE AND SPELL FUNCTIONALITY ######################
		//##########################################################################
		
		//############################ HELPER FUNCTIONS ############################
		public function timeLeftInSpell():Number 
		{
			return totalSpellCastDuration() - (CH2.user.totalMsecsPlayed - spellStartTime);
		}
		
		public function totalSpellCastDuration():Number
		{
			var msecPerRune:Number = BASE_ACTIVATION_WINDOW_PER_RUNE;
			if (pendingRunes.length > 0)
			{
				var highestSpell:Spell = highestValidSpell();
				if (highestSpell != null)
				{
					msecPerRune = highestSpell.msecsPerRune;
				}
			}
			var duration:Number = pendingRunes.length * msecPerRune * (1/CH2.currentCharacter.hasteRating);
			if (wasPasted)
			{
				return duration / 10;
			}
			else
			{
				return duration;
			}
		}
		
		public function isReadyToActivate():Boolean 
		{
			return pendingRunes.length > 0 && pendingRunes[pendingRunes.length - 1].modStateHolder["runeId"] == EXE_RUNE_ID;
		}
		
		public function canCastSpell():Boolean
		{
			if (CH2.world.bossEncounter)
			{
				var bossTimerFinished:Boolean = CH2.world.bossEncounter.battleEnded;
				var isRunningUpToBoss:Boolean = !CH2.world.bossEncounter.battleStarted;
				return (!bossTimerFinished && !isRunningUpToBoss);
			}
			else
			{
				return (CH2.world.getNextMonster() != null);
				//return (CH2.world.getNextMonster().y <= CH2.currentCharacter.y + CH2.currentCharacter.attackRange);
			}
		}
		
		public function currentSpellRuneValues():Array
		{
			var currentRunes:Array = pendingRunes;
			var result:Array = [];
			for (var i:int = 0; i < currentRunes.length; i++)
			{
				result.push(currentRunes[i].modStateHolder["runeId"]);
			}
			return result;
		}
		
		public static const SPELL_TYPE_NAMES:Array = ["", "Fire", "Ice", "Lightning", "Neutral", "Neutral", "Neutral", "Neutral", ""];
		public function spellTypeName():String
		{
			if (pendingRunes.length == 0) return "";
			
			var spellIndex:int = pendingRunes[0].modStateHolder["runeId"];
			if (spellIndex < SPELL_TYPE_NAMES.length)
			{
				return SPELL_TYPE_NAMES[spellIndex];
			}
			else
			{
				return "";
			}
		}
		
		public function getSpellTypes(spell:Spell):Array
		{
			var types:Array = spell.types;
			if (CH2.currentCharacter.buffs.hasBuffByName("iceLightningBuff1") && (spell.types.indexOf(ICE_RUNE_ID) > -1 || spell.types.indexOf(LIGHTNING_RUNE_ID) > -1))
			{
				types.push(ICE_RUNE_ID);
				types.push(LIGHTNING_RUNE_ID);
			}
			if (CH2.currentCharacter.buffs.hasBuffByName("iceFireBuff1") && (spell.types.indexOf(ICE_RUNE_ID) > -1 || spell.types.indexOf(FIRE_RUNE_ID) > -1))
			{
				types.push(ICE_RUNE_ID);
				types.push(FIRE_RUNE_ID);
			}
			if (CH2.currentCharacter.buffs.hasBuffByName("fireLightningBuff1") && (spell.types.indexOf(FIRE_RUNE_ID) > -1 || spell.types.indexOf(LIGHTNING_RUNE_ID) > -1))
			{
				types.push(FIRE_RUNE_ID);
				types.push(LIGHTNING_RUNE_ID);
			}
			return types;
		}
		
		public function isSpellValid():Boolean
		{
			return getSpellToActivate() != null;
		}
		
		public function getSpellToActivate():Spell
		{
			var candidateSpell:Spell = highestValidSpell();
			
			if (currentSpellRuneValues().length == candidateSpell.runeCombination.length)
			{
				return candidateSpell;
			}
			else
			{
				return null;
			}
		}
		
		public function highestValidSpell():Spell
		{
			var activeSpells:Vector.<Spell> = getActiveSpells();
			var currentRunes:Array = currentSpellRuneValues();
			var highestValidSpellSubset:Spell = null;
			var maxMatches:int = 0;
			var minLength:int = int.MAX_VALUE;
			
			for (var i:int = 0; i < activeSpells.length; i++)
			{
				for (var j:int = 0; j < currentRunes.length; j++)
				{
					if (activeSpells[i].runeCombination[j] != currentRunes[j])
					{
						if ((j > 0 && highestValidSpellSubset == null) || (j > maxMatches) || (j == maxMatches && activeSpells[i].runeCombination.length < minLength))
						{
							maxMatches = j;
							minLength = activeSpells[i].runeCombination.length;
							highestValidSpellSubset = activeSpells[i];
						}
						break;
					}
					else if(j == currentRunes.length-1) //it IS the spell
					{
						return activeSpells[i];
					}
				}
			}
			return highestValidSpellSubset;
		}
		
		public function isSpellFailure():Boolean
		{
			if (highestValidSpell() == null) return true;
			
			var candidateSpellRuneCombination:Array = highestValidSpell().runeCombination;
			var currentRuneCombination:Array = currentSpellRuneValues();
			if (candidateSpellRuneCombination.length < currentRuneCombination.length || candidateSpellRuneCombination.length == 0)
			{
				return true;
			}
			else
			{
				for (var i:int = 0; i < currentRuneCombination.length; i++)
				{
					if (currentRuneCombination[i] != candidateSpellRuneCombination[i])
					{
						return true;
					}
				}
			}
			return false;
		}
		
		//############################ SPELL ACTIVATION ############################
		public var spellEffectDisplays:Vector.<GpuMovieClip> = new Vector.<GpuMovieClip>();
		public var spellParticleEffectDisplays:Vector.<GpuMovieClip> = new Vector.<GpuMovieClip>();
		public var cachedHighestSpell:Spell;
		public var cachedSpellEffects:String = "";
		public var attackEffectStartTime:int = 0;
		public var lastSpellActivationTime:int = 0;
		public var travelTimeMsec:int = 180;
		public var isCastingSpell:Boolean = false;
		
		public function spellUpdate():void
		{
			//If the spell can no longer be cast end the spell
			if (!canCastSpell())
			{
				endSpell();
			}
			
			//Spell was activated, play activation effect or tween
			if (attackEffectStartTime > 0)
			{
				var spellToActivate:Spell = getSpellToActivate();
				var fatigueReduced:int = 0;
				if (spellToActivate != null)
				{
					var energyCost:Number = spellToActivate.energyCost;
					var spellTypes:Array = getSpellTypes(spellToActivate);
					
					if (spellTypes.indexOf(ICE_RUNE_ID) != -1)
					{
						var guaranteedReduction:Number = Math.floor(CH2.currentCharacter.getTrait("IceCostReductionPercentChance") / 100);
						var additionalReductionBasedOnChance:Number = CH2.roller.modRoller.boolean((CH2.currentCharacter.getTrait("IceCostReductionPercentChance") % 100) / 100);
						var totalCostReduction:Number = guaranteedReduction + additionalReductionBasedOnChance;
						var energyReduction:Number = ICE_RANK_1_ENERGY_COST * totalCostReduction;
						fatigueReduced = totalCostReduction;
						
						if (CH2.currentCharacter.buffs.hasBuffByName(ICE_RUNE_ID + "Fatigue"))
						{
							energyCost *= (1 + (FATIGUE_COST * CH2.currentCharacter.buffs.getBuff(ICE_RUNE_ID + "Fatigue").stacks));
						}
						energyCost = Math.max(energyCost - energyReduction, 0);
					}
					if (spellTypes.indexOf(FIRE_RUNE_ID) != -1)
					{
						var guaranteedReduction:Number = Math.floor(CH2.currentCharacter.getTrait("FireCostReductionPercentChance") / 100);
						var additionalReductionBasedOnChance:Number = CH2.roller.modRoller.boolean((CH2.currentCharacter.getTrait("FireCostReductionPercentChance") % 100) / 100);
						var totalCostReduction:Number = guaranteedReduction + additionalReductionBasedOnChance;
						var energyReduction:Number = FIRE_RANK_1_ENERGY_COST * totalCostReduction;
						fatigueReduced = totalCostReduction;
						
						if (CH2.currentCharacter.buffs.hasBuffByName(FIRE_RUNE_ID + "Fatigue"))
						{
							energyCost *= (1 + (FATIGUE_COST * CH2.currentCharacter.buffs.getBuff(FIRE_RUNE_ID + "Fatigue").stacks));
						}
						energyCost = Math.max(energyCost - energyReduction, 0);
					}
					if (spellTypes.indexOf(LIGHTNING_RUNE_ID) != -1)
					{
						var guaranteedReduction:Number = Math.floor(CH2.currentCharacter.getTrait("LightningCostReductionPercentChance") / 100);
						var additionalReductionBasedOnChance:Number = CH2.roller.modRoller.boolean((CH2.currentCharacter.getTrait("LightningCostReductionPercentChance") % 100) / 100);
						var totalCostReduction:Number = guaranteedReduction + additionalReductionBasedOnChance;
						var energyReduction:Number = LIGHTNING_RANK_1_ENERGY_COST * totalCostReduction;
						fatigueReduced = totalCostReduction;
						
						if (CH2.currentCharacter.buffs.hasBuffByName(LIGHTNING_RUNE_ID + "Fatigue"))
						{
							energyCost *= (1 + (FATIGUE_COST * CH2.currentCharacter.buffs.getBuff(LIGHTNING_RUNE_ID + "Fatigue").stacks));
						}
						energyCost = Math.max(energyCost - energyReduction, 0);
					}
					
					if (energyCost <= CH2.currentCharacter.energy && spellToActivate.manaCost <= CH2.currentCharacter.mana)
					{
						if (CH2.user.totalMsecsPlayed - attackEffectStartTime < travelTimeMsec)
						{
							for (var i:int = 0; i < spellEffectDisplays.length; i++)
							{
								var xDisplacement:Number = X_DISPLACEMENT[i] - easeInQuint(CH2.user.totalMsecsPlayed - attackEffectStartTime, X_DISPLACEMENT[i], travelTimeMsec);
								var yDisplacement:Number = Y_DISPLACEMENT[i] - easeInQuint(CH2.user.totalMsecsPlayed - attackEffectStartTime, Y_DISPLACEMENT[i], travelTimeMsec);
								
								//Adjust world coordinates
								if (spellEffectDisplays[i] && spellEffectDisplays[i].parent != null)
								{
									CH2.world.getEffect(spellEffectDisplays[i]).x = CH2.world.getNextMonster().x - xDisplacement;
									CH2.world.getEffect(spellEffectDisplays[i]).y = CH2.world.getNextMonster().y - yDisplacement;
								}
							}
						}
						else
						{
							var buffName:String = spellToActivate.id + " Cooldown";
							if (CH2.currentCharacter.buffs.getBuff(buffName))
							{
								//time is not up yet in cooldown
								TransientEffects.instance.showFadingText("Spell is still on cooldown", 5000, 1000);
								endSpell(spellToActivate);
							}
							else if (spellToActivate.requiredCharge != null && !hasCharge(spellToActivate.requiredCharge.id))
							{
								//doesn't have required charge
								TransientEffects.instance.showFadingText("You do not have the required charge to activate this spell", 5000, 1000);
								endSpell(spellToActivate);
							}
							else
							{
								CH2.currentCharacter.addEnergy(energyCost * -1, (energyCost > 0));
								CH2.currentCharacter.addMana(spellToActivate.manaCost * -1, (spellToActivate.manaCost > 0));
								activateSpell(getSpellToActivate(), fatigueReduced);
							}
						}
					}
					else if(energyCost > CH2.currentCharacter.energy)
					{
						TransientEffects.instance.showFadingText("Not enough energy to activate spell", 5000, 1000);
						endSpell();
					}
					else if (spellToActivate.manaCost > CH2.currentCharacter.mana)
					{
						TransientEffects.instance.showFadingText("Not enough mana to activate spell", 5000, 1000);
						endSpell();
					}
				}
				else
				{
					//invalid spell
					playSpellFailure();
					endSpell();
				}
				return;
			}
			
			//Check if current runes are an invalid sequence
			if (isSpellFailure())
			{
				playSpellFailure();
				endSpell();
			}
			
			//Check for whether to activate spell
			if (timeLeftInSpell() <= 0)
			{
				if(isReadyToActivate())
				{
					attackEffectStartTime = CH2.user.totalMsecsPlayed;
				}
				else
				{
					endSpell();
				}
				return;
			}
			
			//Is Cutting
			if (isCutting && isReadyToActivate() && highestValidSpell().id != "cut")
			{
				cutSpellCombo = [];
				for (var i:int = 0; i < pendingRunes.length; i++)
				{
					cutSpellCombo.push(pendingRunes[i].modStateHolder["runeId"]);
				}
				SoundManager.instance.playSound("cut");
				isCutting = false;
				endSpell();
			}
			
			//Check whether to upgrade spell
			if (cachedHighestSpell != highestValidSpell())
			{
				cachedHighestSpell = highestValidSpell();
				
				CH2UI.instance.mainUI.hud.hudTop.enemyHealthBar.setExpectedDamage(cachedHighestSpell.damage);
				
				addSpellCircleEffect(cachedHighestSpell);
				
				CH2.currentCharacter.characterDisplay.playSceneByName("castingLoop0_selfLoop", CharacterDisplay.STATE_CASTING);
				
				var newSpellEffects:String = cachedHighestSpell.spellEffects.join("");
				if (cachedSpellEffects != newSpellEffects)
				{
					if (cachedHighestSpell.spawnSound != "")
					{
						SoundManager.instance.playSound(cachedHighestSpell.spawnSound);
					}
					for (var i:int = 0; i < spellEffectDisplays.length; i++)
					{
						CH2.world.removeEffect(spellEffectDisplays[i]);
					}
					spellEffectDisplays = new Vector.<GpuMovieClip>();
					for (var i:int = 0; i < cachedHighestSpell.spellEffects.length; i++)
					{
						var newSpellEffectAsset:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(cachedHighestSpell.spellEffects[i]);
						newSpellEffectAsset.isLooping = true;
						spellEffectDisplays.push(newSpellEffectAsset);
						
						if (!newSpellEffectAsset.assetData.isBroken)
						{
							CH2.world.addEffect(newSpellEffectAsset, CH2.world.roomsFront, CH2.world.getNextMonster().x - X_DISPLACEMENT[i], CH2.world.getNextMonster().y - Y_DISPLACEMENT[i]);
						}
						
						var spellParticleEffect:String = ASSOCIATED_FALL_GROUPS[cachedHighestSpell.spellEffects[i]];
						if (CH2AssetManager.instance.exists(spellParticleEffect))
						{
							var newSpellParticleEffectAsset:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(spellParticleEffect);
							newSpellParticleEffectAsset.isLooping = true;
							spellParticleEffectDisplays[i] = newSpellParticleEffectAsset;
							spellEffectDisplays[i].addChild(spellParticleEffectDisplays[i]);
						}
					}
					
					cachedSpellEffects = newSpellEffects;
				}
			}
		}
		
		public function activateSpell(spellToActivate:Spell, fatigueReduction:int=0, activatedByBuff:Boolean = false):void
		{
			var buffName:String = spellToActivate.id + " Cooldown";
			var buff:Buff = new Buff();
			buff.name = buffName;
			buff.duration = spellToActivate.cooldownMsec;
			buff.iconId = 168;
			buff.stateValues["hideFromBuffBar"] = true;
			buff.unhastened = true;
			buff.tooltipFunction = function() {
				return {
					"header": buffName,
					"body": ""
				};
			}
			CH2.currentCharacter.buffs.addBuff(buff);
			
			spellToActivate.spellActivationFunction();
			
			spellTypeHistory.push(spellToActivate.types);
			if (spellTypeHistory.length > 10)
			{
				spellTypeHistory.shift();
			}
			
			applySpellTypeFatigue(spellToActivate, fatigueReduction);
			applySpellTypeCharge(spellToActivate);
			
			if (!activatedByBuff && spellToActivate.id != "iceLightningThundersnow")
			{
				setTimeout(thunderSnowOnSpellCast, 100);
			}
			endSpell(spellToActivate);
		}
		
		public function doSpellDamage(spell:Spell):void
		{
			var spellDamage:BigNumber = spell.damage;
			var criticalChance:Number = CH2.currentCharacter.criticalChance;
			var criticalDamageMultiplier:Number = CH2.currentCharacter.criticalDamageMultiplier;
			var numMonstersToAttack:int = 1;
			var livingMonsters:Vector.<Monster> = CH2.world.monsters.getLivingMonsters();
			CH2UI.instance.mainUI.hud.hudTop.enemyHealthBar.setExpectedDamage(new BigNumber(0));
			
			var types:Array = getSpellTypes(spell);
			if (spell.impactSound != "")
			{
				SoundManager.instance.playSound(spell.impactSound);
			}
			
			var appliedFlashBuff:Boolean = false;
			
			//##################### APPLY SPELL SPECIFIC MODIFIERS ######################
			//##################### ICE #####################
			if (types.indexOf(ICE_RUNE_ID) > -1)
			{
				criticalChance += CH2.currentCharacter.getTrait("IceAdditionalCritChance");
				criticalDamageMultiplier += CH2.currentCharacter.getTrait("IceCritAdditionalDamage");
				spellDamage.timesEqualsN(1 + CH2.currentCharacter.getTrait("IceAdditionalPercentDamage"));
				if (spell.tier == 1 && CH2.currentCharacter.getTrait("Ice1CritChance") > 0)
				{
					applyCoolCriticalsBuff(spell);
				}
				
				if (spell.tier == 2 && CH2.currentCharacter.getTrait("CoolthReductionPerCrit") > 0)
				{
					applyCoolthBuff(spell);
				}
				
				if (spell.tier == 3 && CH2.currentCharacter.getTrait("ShatterDamagePercent") > 0)
				{
					var monsterListToAttack:Array = [];
					for ( var i:int = 0; i < CH2.world.monsters.monsters.length; i++ )
					{
						var monster:Monster = CH2.world.monsters.monsters[i];
						if (monster.isAlive && monster.y >= CH2.world.getNextMonster().y && monsterListToAttack.length < CH2.currentCharacter.getTrait("ShatterDamageMonsters"))
						{
							monsterListToAttack.push(monster);
						}
					}
					
					for (var i:int = 0; i < monsterListToAttack.length; i++)
					{
						var attackData:AttackData = new AttackData();
						attackData.monster = monsterListToAttack[i];
						attackData.damage = spellDamage.multiplyN(CH2.currentCharacter.getTrait("ShatterDamagePercent"));
						attackData.isCritical = CH2.roller.attackRoller.boolean(criticalChance);
						if (attackData.isCritical)
						{
							attackData.damage = attackData.damage.multiplyN(criticalDamageMultiplier);
						}
						
						if (attackData.monster != null)
						{
							CH2.currentCharacter.buffs.onAttack([attackData]);
							attackData.monster.takeDamage(attackData);
							CH2.currentCharacter.playRandomHitSound(attackData);
						}
					}
				}
				
				//Chain lightning from Ice
				if (CH2.currentCharacter.getTrait("IceChainChance") > 0)
				{
					var numChainAttacks:int = int(CH2.currentCharacter.getTrait("IceChainChance")) + CH2.roller.attackRoller.boolean(CH2.currentCharacter.getTrait("IceChainChance") % 1);
					numMonstersToAttack += numChainAttacks;
					if (numChainAttacks > 0)
					{
						var monstersToRenderInChain:Vector.<Monster> = livingMonsters.slice(1, Math.min(livingMonsters.length-1, 1 + numChainAttacks));
						renderChainLightningBetweenMonsters(monstersToRenderInChain);
					}
					
					var lightningCircuitDamageMultiplier:Number = CH2.currentCharacter.getTrait("LightningCircuitDamagePercent");
					if (lightningCircuitDamageMultiplier > 0 && spell.tier == 3)
					{
						for (var i:int = 0; i < numChainAttacks && i<livingMonsters.length; i++)
						{
							var attackData:AttackData = new AttackData();
							attackData.monster = livingMonsters[i];
							attackData.damage = spellDamage.multiplyN(lightningCircuitDamageMultiplier);
							attackData.isCritical = CH2.roller.attackRoller.boolean(criticalChance);
							if (attackData.isCritical)
							{
								attackData.damage = attackData.damage.multiplyN(criticalDamageMultiplier);
							}
							
							if (attackData.monster != null)
							{
								CH2.currentCharacter.buffs.onAttack([attackData]);
								attackData.monster.takeDamage(attackData);
								CH2.currentCharacter.playRandomHitSound(attackData);
								SoundManager.instance.playSound("chainlightning_command");
							}
						}
					}
				}
			}
			//##################### FIRE #####################
			if (types.indexOf(FIRE_RUNE_ID) > -1)
			{
				criticalChance += CH2.currentCharacter.getTrait("FireAdditionalCritChance");
				criticalDamageMultiplier += CH2.currentCharacter.getTrait("FireCritAdditionalDamage");
				spellDamage = spellDamage.multiplyN(1 + CH2.currentCharacter.getTrait("FireAdditionalPercentDamage"));
				if (spell.tier == 1 && CH2.currentCharacter.getTrait("DoubleBurnChance") > 0)
				{
					applyCombustionBuff(spell);
				}
				
				if (spell.tier == 2 && CH2.currentCharacter.getTrait("WarmthReductionPerBurn") > 0)
				{
					applyWarmthBuff(spell);
				}
				
				applyFireDamageOverTimeBuff(spell, "Fire");
				
				if (CH2.currentCharacter.getTrait("FireZapPercentDamage") > 0)
				{
					fireZapActivation(spell);
				}
			}
			//##################### LIGHTNING #####################
			if (types.indexOf(LIGHTNING_RUNE_ID) > -1)
			{
				criticalChance += CH2.currentCharacter.getTrait("LightningAdditionalCritChance");
				criticalDamageMultiplier += CH2.currentCharacter.getTrait("LightningCritAdditionalDamage");
				spellDamage = spellDamage.multiplyN(1 + CH2.currentCharacter.getTrait("LightningAdditionalPercentDamage"));
				if (spell.tier == 1 && CH2.currentCharacter.getTrait("LightningFlashHaste") > 0)
				{
					applyFlashBuff(spell);
					appliedFlashBuff = true;
				}
				
				if (spell.tier == 2 && CH2.currentCharacter.getTrait("EnergizeDuration") > 0)
				{
					applyEnergize(spell);
				}
				
				if (CH2.currentCharacter.getTrait("LightningChainChance") > 0)
				{
					var numChainAttacks:int = int(CH2.currentCharacter.getTrait("LightningChainChance")) + CH2.roller.attackRoller.boolean(CH2.currentCharacter.getTrait("LightningChainChance") % 1);
					numMonstersToAttack += numChainAttacks;
					if (numChainAttacks > 0)
					{
						var monstersToRenderInChain:Vector.<Monster> = livingMonsters.slice(1, Math.min(livingMonsters.length-1, 1 + numChainAttacks));
						renderChainLightningBetweenMonsters(monstersToRenderInChain);
					}
					
					var lightningCircuitDamageMultiplier:Number = CH2.currentCharacter.getTrait("LightningCircuitDamagePercent");
					if (lightningCircuitDamageMultiplier > 0 && spell.tier == 3)
					{
						for (var i:int = 0; i < numChainAttacks && i<livingMonsters.length; i++)
						{
							var attackData:AttackData = new AttackData();
							attackData.monster = livingMonsters[i];
							attackData.damage = spellDamage.multiplyN(lightningCircuitDamageMultiplier);
							attackData.isCritical = CH2.roller.attackRoller.boolean(criticalChance);
							if (attackData.isCritical)
							{
								attackData.damage = attackData.damage.multiplyN(criticalDamageMultiplier);
							}
							
							if (attackData.monster != null)
							{
								CH2.currentCharacter.buffs.onAttack([attackData]);
								attackData.monster.takeDamage(attackData);
								CH2.currentCharacter.playRandomHitSound(attackData);
								SoundManager.instance.playSound("chainlightning_command");
							}
						}
					}
				}
				
				if (CH2.currentCharacter.getTrait("LightningBurnDamage") > 0)
				{
					applyFireDamageOverTimeBuff(spell, "Lightning");
				}
				
				lightningZapActivation(spell);
			}
			
			if (!appliedFlashBuff)
			{
				useFlashBuff();
			}
			
			//###################################################################
			//################# Dual Damage Spell Charge Boosts #################
			//###################################################################
			
			if (spell.id == "iceFireDamage" || spell.id == "iceLightningDamage" || spell.id == "lightningFireDamage")
			{
				var chargeId:String = spell.requiredCharge.id;
				if (hasCharge(chargeId))
				{
					var chargeCount:int = numCharges(chargeId);
					chargeCount = Math.min(5, chargeCount);
					spellDamage.timesEqualsN(1 + (chargeCount * .5));
					useCharges(chargeId);
				}
			}
			
			//##############################################################
			//################# Apply Damage To Monster(s) #################
			//##############################################################
			if (spellDamage.gtN(0))
			{
				var monsterListToAttack:Array = [];
				for ( var i:int = 0; i < livingMonsters.length && i<numMonstersToAttack; i++ )
				{
					monsterListToAttack.push(livingMonsters[i]);
				}
				if (monsterListToAttack.length > 0)
				{
					doSpellHitEffect(monsterListToAttack[0]);
					CH2.world.camera.shake(0.5, -50, 50);
				}
				
				for (var i:int = 0; i < monsterListToAttack.length; i++)
				{
					var attackData:AttackData = new AttackData();
					attackData.monster = monsterListToAttack[i];
					attackData.damage = spellDamage;
					attackData.isCritical = CH2.roller.attackRoller.boolean(criticalChance);
					
					if (attackData.isCritical)
					{
						attackData.damage = attackData.damage.multiplyN(criticalDamageMultiplier);
					}
					
					if (attackData.monster != null)
					{
						CH2.currentCharacter.buffs.onAttack([attackData]);
						attackData.monster.takeDamage(attackData);
						CH2.currentCharacter.playRandomHitSound(attackData);
						
						//############################ APPLY AFTER DAMAGE SPELL MODIFIERS AND BUFFS ############################
						if (attackData.monster.isAlive) 
						{
							if (spell.types.indexOf(ICE_RUNE_ID) > -1)
							{
								if (CH2.currentCharacter.getTrait("IceCorrosionDamageBonus") > 0)
								{
									applyCorrosionDamageBonusBuff("Ice");
								}
							}
							if (spell.types.indexOf(FIRE_RUNE_ID) > -1)
							{
								if (CH2.currentCharacter.getTrait("FireCorrosionDamageBonus") > 0)
								{
									applyCorrosionDamageBonusBuff("Fire");
								}
							}
							if (spell.types.indexOf(LIGHTNING_RUNE_ID) > -1)
							{
								if (CH2.currentCharacter.getTrait("LightningCorrosionDamageBonus") > 0)
								{
									applyCorrosionDamageBonusBuff("Lightning");
								}
							}
						}
					}
				}
			}
		}
		
		public function iceFire1Activation():void
		{
			if (hasCharge("iceFire1"))
			{
				var buffName:String = "IceFireBuff1";
				if (!CH2.currentCharacter.buffs.hasBuffByName(buffName))
				{
					var buff:Buff = new Buff();
					buff.name = buffName;
					buff.duration = CH2.currentCharacter.getTrait("IceFireBuffDuration") * Math.min(5, numCharges("iceFire1"));
					buff.iconId = 280;
					buff.unhastened = true;
					buff.tooltipFunction = function() {
						return {
							"header": "Ice Fire Synergy",
							"body": "Ice spells benefit from fire buffs, fire spells benefit from ice buffs."
						};
					}
					CH2.currentCharacter.buffs.addBuff(buff);
				}
				else
				{
					var buff:Buff = CH2.currentCharacter.buffs.getBuff(buffName);
					buff.timeSinceActivated = 0;
				}
				useCharges("iceFire1");
				SoundManager.instance.playSound("synergy");
			}
			else
			{
				TransientEffects.instance.showFadingText("You require a charge to activate this spell.", 1000, 1000);
			}
		}
		
		public function iceLightning1Activation():void
		{
			if (hasCharge("iceLightning1"))
			{
				var buffName:String = "IceLightningBuff1";
				if (!CH2.currentCharacter.buffs.hasBuffByName(buffName))
				{
					var buff:Buff = new Buff();
					buff.name = buffName;
					buff.duration = CH2.currentCharacter.getTrait("IceLightningBuffDuration") * Math.min(5, numCharges("iceLightning1"));
					buff.iconId = 330;
					buff.unhastened = true;
					buff.tooltipFunction = function() {
						return {
							"header": "Ice Lightning Synergy",
							"body": "Ice spells benefit from lightning buffs, lightning spells benefit from ice buffs."
						};
					}
					CH2.currentCharacter.buffs.addBuff(buff);
				}
				else
				{
					var buff:Buff = CH2.currentCharacter.buffs.getBuff(buffName);
					buff.timeSinceActivated = 0;
				}
				useCharges("iceLightning1");
				SoundManager.instance.playSound("synergy");
			}
			else
			{
				TransientEffects.instance.showFadingText("You require a charge to activate this spell.", 1000, 1000);
			}
		}
		
		public function fireLightning1Activation():void
		{
			if (hasCharge("fireLightning1"))
			{
				var buffName:String = "FireLightningBuff1";
				if (!CH2.currentCharacter.buffs.hasBuffByName(buffName))
				{
					var buff:Buff = new Buff();
					buff.name = buffName;
					buff.duration = CH2.currentCharacter.getTrait("LightningFireBuffDuration") * Math.min(5, numCharges("fireLightning1"));
					buff.iconId = 305;
					buff.unhastened = true;
					buff.tooltipFunction = function() {
						return {
							"header": "Fire Lightning Synergy",
							"body": "Fire spells benefit from lightning buffs, lightning spells benefit from fire buffs."
						};
					}
					CH2.currentCharacter.buffs.addBuff(buff);
				}
				else
				{
					var buff:Buff = CH2.currentCharacter.buffs.getBuff(buffName);
					buff.timeSinceActivated = 0;
				}
				useCharges("fireLightning1");
				SoundManager.instance.playSound("synergy");
			}
			else
			{
				TransientEffects.instance.showFadingText("You require a charge to activate this spell.", 1000, 1000);
			}
		}
		
		public function energizeActivation():void
		{
			var buffName:String = "iceLightningEnergize";
			if (!CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				var buff:Buff = new Buff();
				buff.name = buffName;
				buff.duration = 10000;
				buff.tickRate = 2000;
				buff.unhastened = true;
				buff.tickFunction = function():void
				{
					var numStacks:int = this.stacks;
					for (var i:int = 1; i < 8; i++)
					{
						reduceSpellTypeFatigue(i, numStacks);
					}
					CH2.currentCharacter.addEnergy(CH2.currentCharacter.maxEnergy * .01 * numStacks, true);
				}
				buff.iconId = 261;
				buff.tooltipFunction = function() {
					return {
						"header": "Energon Cube",
						"body": "Restores 1% energy and reduces all Fatigue by 1 every 2 seconds for 10 seconds. Stacks."
					};
				}
				CH2.currentCharacter.buffs.addBuff(buff);
			}
			else
			{
				var buff:Buff = CH2.currentCharacter.buffs.getBuff(buffName);
				buff.stacks++;
				buff.timeSinceActivated = 0;
			}
			SoundManager.instance.playSound("energize");
		}
		
		public function darkRitualActivation():void
		{
			var buffName:String = "DarkRitual";
			if (!CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				var buff:Buff = new Buff();
				buff.name = buffName;
				buff.duration = 60000;
				buff.unhastened = true;
				buff.iconId = 355;
				buff.unhastened = true;
				buff.buffStat(CH2.STAT_DAMAGE, 1.05);
				buff.tooltipFunction = function() {
					return {
						"header": "Dark Ritual",
						"body": "Multiply your current DPS by 1.05 per stack. Stacks up to 20 times."
					};
				}
				CH2.currentCharacter.buffs.addBuff(buff);
			}
			else
			{
				var buff:Buff = CH2.currentCharacter.buffs.getBuff(buffName);
				buff.stacks = Math.min(20, buff.stacks + 1);
				buff.timeSinceActivated = 0;
				buff.buffStat(CH2.STAT_DAMAGE, Math.pow(1.05,buff.stacks));
			}
			SoundManager.instance.playSound("dark_ritual");
		}
		
		public function cutActivation():void
		{
			isCutting = true;
		}
		
		public function pasteActivation():void
		{
			if (cutSpellCombo.length > 0)
			{
				isPasting = true;
			}
		}
		
		public function stopAllRecording():void
		{
			for (var i:int = 0; i < recordings.length; i++)
			{
				if (recordings[i].isRecording)
				{
					recordings[i].endRecording();
				}
			}
		}
		
		public function deleteRecording(id:int):void
		{
			for (var i:int = 0; i < recordings.length; i++)
			{
				if (recordings[i].id == id)
				{
					recordings.splice(i, 1);
				}
			}
			delete CH2.currentCharacter.traits["recording" + id];
		}
		
		public function deleteAllRecordings():void
		{
			for (var i:int = 0; i < recordings.length; i++)
			{
				deleteRecording(recordings[i].id);
			}
		}
		
		public function stopAllPlayback():void
		{
			for (var i:int = 0; i < recordings.length; i++)
			{
				if (recordings[i].isPlaying)
				{
					recordings[i].endPlayback();
				}
			}
		}
		
		public function playSpellFailure():void
		{
			for (var i:int = 0; i < pendingRunes.length; i++)
			{
				pendingRunes[i].modStateHolder["isFailed"] = true;
				pendingRunes[i].modStateHolder["numFailed"] = pendingRunes.length;
			}
			SoundManager.instance.playSound("failure");
		}
		
		public function endSpell(spellActivated:Spell = null):void
		{
			isCastingSpell = false;
			
			cachedHighestSpell = null;
			cachedSpellEffects = "";
			attackEffectStartTime = 0;
			lastSpellActivationTime = CH2.user.totalMsecsPlayed;
			if (spellEffectDisplays.length > 0)
			{
				for (var i:int = 0; i < spellEffectDisplays.length; i++)
				{
					spellEffectDisplays[i].stop();
					spellEffectDisplays[i].visible = false;
				}
			}
			
			for (var i:int = 0; i < pendingRunes.length; i++)
			{
				if (!pendingRunes[i].modStateHolder["isFailed"])
				{
					if (CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(pendingRunes[i].name))
					{
						CH2.currentCharacter.characterDisplay.characterUI.removeUIElement(pendingRunes[i]);
					}
				}
			}
			pendingRunes = [];
			
			for (var i:int = 0; i < activeCircleEffects.length; i++)
			{
				if (CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(activeCircleEffects[i].name))
				{
					CH2.currentCharacter.characterDisplay.characterUI.removeUIElement(activeCircleEffects[i]);
				}
			}
			activeCircleEffects = [];
			
			CH2.currentCharacter.characterDisplay.playSceneByName("castingEnd0_random", CharacterDisplay.STATE_CASTING);
			
			//Start the pasted spell if a spell was pasted
			if (isPasting)
			{
				if (cutSpellCombo.length > 0)
				{
					for (var i:int = 0; i < cutSpellCombo.length; i++)
					{
						runeEffect(cutSpellCombo[i]);
					}
				}
				isPasting = false;
				wasPasted = true;
				SoundManager.instance.playSound("paste");
			}
			else
			{
				wasPasted = false;
			}
		}
		
		public function runeEffect(runeId:String):void
		{
			//START SPELL
			if (pendingRunes.length == 0)
			{
				spellStartTime = CH2.user.totalMsecsPlayed;
				staffEffect();
				isCastingSpell = true;
				var nextMonster:Monster = CH2.world.getNextMonster();
				if (nextMonster != null)
				{
					nextMonster.display.displayHealthBar = true;
				}
			}
			
			//add count down line if it hasn't been added yet
			addCastBar();
			
			//add runes
			var numRunes:int = pendingRunes.length;
			var runeAsset:GpuImage = CH2AssetManager.instance.getGpuImage("Wizard_rune" + runeId);
			runeAsset.alpha = 0;
			var runeAssetDark:GpuImage = CH2AssetManager.instance.getGpuImage("Wizard_rune" + runeId + "B");
			runeAssetDark.alpha = 1;
			var runeFailedX:GpuImage = CH2AssetManager.instance.getGpuImage("Wizard_runeFail");
			runeFailedX.alpha = 0;
			pendingRunes[numRunes] = new CharacterUIElement();
			pendingRunes[numRunes].active = true;
			pendingRunes[numRunes].name = numRunes;
			pendingRunes[numRunes].addChild(runeAsset);
			pendingRunes[numRunes].addChild(runeAssetDark);
			pendingRunes[numRunes].addChild(runeFailedX);
			pendingRunes[numRunes].type = CharacterDisplayUI.OTHER_ELEMENT;
			pendingRunes[numRunes].useWorldCoordinates = false;
			pendingRunes[numRunes].worldX = CH2.currentCharacter.x;
			pendingRunes[numRunes].worldY = CH2.currentCharacter.y + 125;
			pendingRunes[numRunes].modStateHolder["num"] = numRunes;
			pendingRunes[numRunes].modStateHolder["runeId"] = runeId;
			pendingRunes[numRunes].modStateHolder["isFailed"] = false;
			pendingRunes[numRunes].modStateHolder["failedTime"] = 0;
			pendingRunes[numRunes].modStateHolder["numFailed"] = 0;
			pendingRunes[numRunes].updateHook = function(dt:Number):void
			{
				var totalRunes:int = (this.modStateHolder["isFailed"]) ? this.modStateHolder["numFailed"] : pendingRunes.length;
				
				this.worldX = CH2.currentCharacter.x - ((RUNE_DISTANCE_APART/2) * totalRunes) + (RUNE_DISTANCE_APART * this.modStateHolder["num"]);
				this.worldY = CH2.currentCharacter.y + 125;
				
				this.x = CH2.world.worldToScreenX(this.worldX, this.worldY) - CH2.world.worldToScreenX(CH2.currentCharacter.x, CH2.currentCharacter.y);
				this.y = CH2.world.worldToScreenY(this.worldX, this.worldY) - CH2.world.worldToScreenY(CH2.currentCharacter.x, CH2.currentCharacter.y);
				
				if (!this.modStateHolder["isFailed"])
				{
					//fade between the dark and the light rune symbols
					var currentRuneBeingActivated:int = Math.floor((1 - (timeLeftInSpell() / totalSpellCastDuration())) * totalRunes);
					if (this.modStateHolder["num"] <= currentRuneBeingActivated)
					{
						var currentRuneBeingActivated:int = totalSpellCastDuration() - timeLeftInSpell();
						runeAssetDark.alpha -= dt / (totalSpellCastDuration() / totalRunes);
						runeAssetDark.alpha = Math.min(1, Math.max(0, runeAssetDark.alpha));
						runeAsset.alpha = 1 - runeAssetDark.alpha;
					}
					if (this.modStateHolder["bgHighlight"])
					{
						this.modStateHolder["bgHighlight"].width = (RUNE_DISTANCE_APART * totalRunes);
					}
				}
				else
				{
					this.modStateHolder["failedTime"] += dt;
					if (this.modStateHolder["failedTime"] > 1000)
					{
						if (CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(this.name))
						{
							CH2.currentCharacter.characterDisplay.characterUI.removeUIElement(this);
						}
					}
					else
					{
						runeAssetDark.alpha = 1 - (this.modStateHolder["failedTime"]/1000);
						runeFailedX.alpha = runeAssetDark.alpha;
						runeAsset.alpha = 0;
					}
				}
			}
			SoundManager.instance.playSound("rune");
			CH2.currentCharacter.characterDisplay.characterUI.addUIElement(pendingRunes[numRunes], CH2.currentCharacter.characterDisplay.characterUI.behindCharacterDisplay);
			addRunePlacedEffect(runeAsset);
			addIgniteEffect(runeAsset);
		}
		
		public function applyCoolCriticalsBuff(spell:Spell):void
		{
			if (CH2.currentCharacter.buffs.hasBuffByName("CoolCriticals"))
			{
				CH2.currentCharacter.buffs.getBuff("CoolCriticals").timeSinceActivated = 0;
			}
			else
			{
				var buff:Buff = new Buff();
				buff.name = "CoolCriticals";
				buff.tickRate = 1000;
				buff.iconId = 240;
				buff.isUntimedBuff = false;
				buff.unhastened = true;
				buff.duration = CH2.currentCharacter.getTrait("Ice1CritDuration");
				buff.buffStat(CH2.STAT_CRIT_CHANCE, CH2.currentCharacter.getTrait("Ice1CritChance"));
				buff.tooltipFunction = function() {
					return {
						"header": "Cool Criticals",
						"body": "Your chance to score a critical hit is increased by " + ICE_COOL_CRITICALS_CRIT_CHANCE_PERCENT + "% with all Spells."
					};
				}
				CH2.currentCharacter.buffs.addBuff(buff);
			}
		}
		
		public function applyCoolthBuff(spell:Spell):void
		{
			if (!CH2.currentCharacter.buffs.hasBuffByName("Coolth"))
			{
				var buff:Buff = new Buff();
				buff.name = "Coolth";
				buff.iconId = 241;
				buff.isUntimedBuff = true;
				buff.unhastened = true;
				buff.stateValues["numCrits"] = COOLTH_NUM_CRITS_WHICH_COOL;
				buff.attackFunction = function(attackDatas:Array):void
				{
					for (var i:int = 0; i < attackDatas.length; i++)
					{
						if ((attackDatas[i] as AttackData).isCritical)
						{
							reduceSpellTypeFatigue(FIRE_RUNE_ID, COOLTH_REDUCTION_PER_CRIT);
						}
					}
					this.stateValues["numCrits"]--;
					if (this.stateValues["numCrits"] <= 0)
					{
						CH2.currentCharacter.buffs.removeBuff(this.name);
					}
				}
				buff.tooltipFunction = function() {
					return {
						"header": "Coolth",
						"body": "The next " + buff.stateValues["numCrits"] + " spell crits cool you, reducing Hyperthermia by " + COOLTH_REDUCTION_PER_CRIT + " for each crit."
					};
				}
				CH2.currentCharacter.buffs.addBuff(buff);
			}
			else
			{
				var buff:Buff = CH2.currentCharacter.buffs.getBuff("Coolth");
				buff.stateValues["numCrits"] += COOLTH_NUM_CRITS_WHICH_COOL;
			}
		}
		
		public function applyFireDamageOverTimeBuff(spell:Spell, type:String):void
		{
			var target:Monster = CH2.world.getNextMonster();
			if (target)
			{
				var dotTickRate:Number = BASE_ACTIVATION_WINDOW_PER_RUNE;
				var numTicks:Number = spell.runeCombination.length * 2;
				var damagePerTick:BigNumber = spell.damage.divideN(numTicks).multiplyN(1 + CH2.currentCharacter.getTrait(type+"BurnDamage"));
				var isExploding:Boolean = CH2.currentCharacter.getTrait("FireExplosionDamagePercent") > 0 && spell.tier == 3;
				
				if (!CH2.currentCharacter.buffs.hasBuffByName("Explosion") && isExploding)
				{
					var buff:Buff = new Buff();
					buff.name = "Explosion";
					buff.iconId = 150;
					buff.isUntimedBuff = true;
					buff.unhastened = true;
					buff.stateValues["burnDamageDealt"] = new BigNumber(0);
					buff.killFunction = function(attackData:AttackData):void
					{
						var nextMonster:Monster = CH2.world.getNextMonster();
						if (nextMonster)
						{
							var newAttackData:AttackData = new AttackData();
							newAttackData.damage = this.stateValues["burnDamageDealt"];
							nextMonster.takeDamage(newAttackData);
						}
						CH2.currentCharacter.buffs.removeBuff(this.name);
					};
					buff.tooltipFunction = function() {
						return {
							"header": "Explosion",
							"body": ""
						};
					}
					CH2.currentCharacter.buffs.addBuff(buff);
				}
				
				var buff:Buff = new Buff();
				buff.name = "Burn"+MiscUtils.cachedTime;
				buff.tickRate = dotTickRate;
				buff.iconId = 171;
				buff.isUntimedBuff = false;
				buff.unhastened = true;
				buff.duration = dotTickRate * numTicks;
				buff.stateValues["targetMonster"] = target;
				buff.stateValues["burnEffect"] = doDamageOverTimeBurnEffect(target);
				buff.stateValues["damage"] = damagePerTick;
				buff.stateValues["dealBurnDamage"] = function(currentTarget:Monster, attackData:AttackData):void{
					if (currentTarget.isAlive)
					{
						currentTarget.takeDamage(attackData);
						if (CH2.currentCharacter.buffs.hasBuffByName("Explosion"))
						{
							CH2.currentCharacter.buffs.getBuff("Explosion").stateValues["burnDamageDealt"].plusEquals(attackData.damage)
						}
						if (CH2.currentCharacter.buffs.hasBuffByName("Warmth"))
						{
							reduceSpellTypeFatigue(ICE_RUNE_ID, CH2.currentCharacter.getTrait("WarmthReductionPerBurn"));
							CH2.currentCharacter.buffs.getBuff("Warmth").stacks--;
							if (CH2.currentCharacter.buffs.getBuff("Warmth").stacks < 0)
							{
								CH2.currentCharacter.buffs.removeBuff("Warmth");
							}
						}
						SoundManager.instance.playSound("burn");
					}
				};
				buff.tickFunction = function(){
					var currentTarget:Monster = this.stateValues["targetMonster"];
					if (currentTarget.isAlive)
					{
						var attackData:AttackData = new AttackData();
						attackData.damage = this.stateValues["damage"];
						
						if (CH2.currentCharacter.buffs.hasBuffByName("CombustionBuff"))
						{
							var chanceOfDoubleAttack:Number = CH2.currentCharacter.getTrait("DoubleBurnChance");
							if (CH2.roller.attackRoller.boolean(chanceOfDoubleAttack))
							{
								this.stateValues["dealBurnDamage"](currentTarget, attackData);
							}
						}
						
						this.stateValues["dealBurnDamage"](currentTarget, attackData);
					}
					else
					{
						CH2.world.removeEffect(this.stateValues["burnEffect"]);
						CH2.currentCharacter.buffs.removeBuff(this.name);
					}
				}
				buff.finishFunction = function() {
					if (this.stateValues["burnEffect"].parent)
					{
						CH2.world.removeEffect(this.stateValues["burnEffect"]);
					}
				}
				buff.tooltipFunction = function() {
					return {
						"header": "Burn",
						"body": "Deals Burn Damage Over Time"
					};
				}
				CH2.currentCharacter.buffs.addBuff(buff);
			}
		}
		
		public function applyFlashBuff(spell:Spell):void
		{
			var stacksPerFlashBuff:int = CH2.currentCharacter.getTrait("LightningFlashNumSpells");
			
			if (CH2.currentCharacter.buffs.hasBuffByName("FlashBuff"))
			{
				CH2.currentCharacter.buffs.getBuff("FlashBuff").stacks = stacksPerFlashBuff;
			}
			else
			{
				var buff:Buff = new Buff();
				buff.name = "FlashBuff";
				buff.tickRate = 1000;
				buff.iconId = 260;
				buff.unhastened = true;
				buff.isUntimedBuff = true;
				buff.stacks = stacksPerFlashBuff;
				buff.tooltipFunction = function() {
					return {
						"header": "Flash Buff",
						"body": "The speed at which you cast all Spells is increased by " + (CH2.currentCharacter.getTrait("LightningFlashHaste")*100) + "% for your next " + stacksPerFlashBuff + " Spells."
					};
				}
				buff.buffStat(CH2.STAT_HASTE, 1+(CH2.currentCharacter.getTrait("LightningFlashHaste")));
				CH2.currentCharacter.buffs.addBuff(buff);
			}
		}
		
		public function applyEnergize(spell:Spell):void
		{
			if (CH2.currentCharacter.buffs.hasBuffByName("Energize"))
			{
				CH2.currentCharacter.buffs.getBuff("Energize").timeSinceActivated = 0;
			}
			else
			{
				var buff:Buff = new Buff();
				buff.name = "Energize";
				buff.iconId = 261;
				buff.unhastened = true;
				buff.isUntimedBuff = false;
				buff.duration = CH2.currentCharacter.getTrait("EnergizeDuration");
				buff.tooltipFunction = function() {
					return {
						"header": "Energize",
						"body": ""
					};
				}
				CH2.currentCharacter.buffs.addBuff(buff);
			}
		}
		
		public function useFlashBuff():void
		{
			if (CH2.currentCharacter.buffs.hasBuffByName("FlashBuff"))
			{
				var flashBuff:Buff = CH2.currentCharacter.buffs.getBuff("FlashBuff");
				flashBuff.stacks--;
				
				if (flashBuff.stacks <= 0)
				{
					CH2.currentCharacter.buffs.removeBuff("FlashBuff");
				}
			}
		}
		
		public function applyCombustionBuff(spell:Spell):void
		{
			if (CH2.currentCharacter.buffs.hasBuffByName("CombustionBuff"))
			{
				CH2.currentCharacter.buffs.removeBuff("CombustionBuff");
			}
			
			var buff:Buff = new Buff();
			buff.name = "CombustionBuff";
			buff.tickRate = 1000;
			buff.iconId = 221;
			buff.unhastened = true;
			buff.isUntimedBuff = false;
			buff.duration = CH2.currentCharacter.getTrait("DoubleBurnDuration");
			buff.tooltipFunction = function() {
				return {
					"header": "Combustion",
					"body": "You have a " + FIRE_COMBUSTION_CHANCE_PERCENT*100 + "% chance for all Burn damage to occur twice."
				};
			}
			CH2.currentCharacter.buffs.addBuff(buff);
		}
		
		public function applyWarmthBuff(spell:Spell):void
		{
			var buffName:String = "Warmth";
			var numStacks:int = CH2.currentCharacter.getTrait("WarmthMaxNumberOfReductions");
			if (CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				CH2.currentCharacter.buffs.getBuff(buffName).stacks = numStacks;
			}
			else
			{
				var buff:Buff = new Buff();
				buff.name = buffName;
				buff.iconId = 222;
				buff.unhastened = true;
				buff.isUntimedBuff = true;
				buff.stacks = numStacks;
				buff.tooltipFunction = function() {
					return {
						"header": "Warmth",
						"body": "Hypothermia is reduced by " + WARMTH_REDUCTION_PER_BURN + " when a monster takes Burn damage."
					};
				}
				CH2.currentCharacter.buffs.addBuff(buff);
			}
		}
		
		public function applyCorrosionDamageBonusBuff(type:String):void
		{
			var buffName:String = type+"CorrosionBuff";
			if (!CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				var buff:Buff = new Buff();
				buff.name = buffName;
				buff.iconId = 220;
				buff.unhastened = true;
				buff.isUntimedBuff = true;
				buff.killFunction = function(attackData:AttackData):void
				{
					CH2.currentCharacter.buffs.removeBuff(this.name);
				};
				buff.attackFunction = function(attackDatas:Array):void
				{
					for (var i:int = 0; i < attackDatas.length; i++)
					{
						attackDatas[i].damage.timesEqualsN(1 + CH2.currentCharacter.getTrait(type+"CorrosionDamageBonus"));
					}
				};
				buff.tooltipFunction = function() {
					return {
						"header": type + " Corrosion",
						"body": "Multiplies all damage taken by monsters by " + (1 + CH2.currentCharacter.getTrait(type+"CorrosionDamageBonus")) + " until a monster is killed."
					};
				}
				CH2.currentCharacter.buffs.addBuff(buff);
			}
		}
		
		public function thunderSnowActivation(spell:Spell):void
		{
			if (hasCharge("iceLightning3"))
			{
				var buffName:String = "Thundersnow";
				if (!CH2.currentCharacter.buffs.hasBuffByName(buffName))
				{
					var buff:Buff = new Buff();
					buff.name = buffName;
					buff.iconId = 332;
					buff.unhastened = true;
					buff.isUntimedBuff = true;
					buff.stateValues["spellsRemaining"] = Math.min(20, numCharges("iceLightning3") * 2);
					buff.tooltipFunction = function() {
						return {
							"header": "Thundersnow",
							"body": "A thunderstorm will strike a monster with ice or lightning whenever a spell is cast. Affects two spells per charge, up to 10 charges."
						};
					}
					CH2.currentCharacter.buffs.addBuff(buff);
				}
				useCharges("iceLightning3");
			}
		}
		
		private function thunderSnowOnSpellCast():void
		{
			var buffName:String = "ThunderSnow";
			if (CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				var thunderSnowBuff:Buff = CH2.currentCharacter.buffs.getBuff(bufName);
				if (CH2.roller.attackRoller.boolean(0.5))
				{
					activateSpell(getSpell("ice9"), 0, true);
				}
				else
				{
					activateSpell(getSpell("lightning9"), 0, true);
				}
				
				thunderSnowBuff.stateValues["spellsRemaining"]--;
				if (thunderSnowBuff.stateValues["spellsRemaining"] <= 0)
				{
					CH2.currentCharacter.buffs.removeBuff(buffName);
				}
			}
		}
		
		public function solarStormActivation(spell:Spell):void
		{
			if (hasCharge("fireLightning3"))
			{
				var solarStormPercentHealthRemaining:Number = CH2.currentCharacter.getTrait("solarFlarePercentHealth");
				if (solarStormPercentHealthRemaining == 0) solarStormPercentHealthRemaining = 1;
				CH2.currentCharacter.addEnergy(CH2.currentCharacter.energy * -1); //set energy to 0
				for (var i:int = 0; i < 20; i++)
				{
					applySpellTypeFatigue(getSpell("fire5")); //add 100 hyperthermia
				}
				var chargeHealthReduction:Number = Math.min(10, numCharges("fireLightning3")) * .01;
				solarStormPercentHealthRemaining *= (1 - chargeHealthReduction);
				CH2.currentCharacter.setTrait("solarFlarePercentHealth", solarStormPercentHealthRemaining);
				
				startsolarFlareBuff();
				
				useCharges("fireLightning3");
			}
		}
		
		public function startsolarFlareBuff():void
		{
			if (!CH2.currentCharacter)
			{
				//keep trying while game starts up
				setTimeout(startsolarFlareBuff, 1000);
				return;
			}
			var buffName:String = "Solar Storm";
			if (!CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				var buff:Buff = new Buff();
				buff.name = buffName;
				buff.iconId = 307;
				buff.unhastened = true;
				buff.isUntimedBuff = true;
				buff.tooltipFunction = function() {
					return {
						"header": "Solar Storm",
						"body": ""
					};
				};
				buff.monsterSpawnFunction = function(monster:Monster) {
					var damageToDeal:BigNumber = monster.maxHealth.multiplyN(1 - CH2.currentCharacter.getTrait("solarFlarePercentHealth"));
					var attackData:AttackData = new AttackData();
					attackData.monster = monster;
					attackData.damage = damageToDeal;
					monster.takeDamage(attackData);
				};
				CH2.currentCharacter.buffs.addBuff(buff);
			}
		}
		
		public function cometShowerActivation(spell:Spell):void
		{
			if (hasCharge("iceFire3"))
			{
				var tempNumCharges:int = Math.min(10, numCharges("iceFire3"));
				var buffName:String = "Comet Shower";
				if (!CH2.currentCharacter.buffs.hasBuffByName(buffName))
				{
					var buff:Buff = new Buff();
					buff.name = buffName;
					buff.iconId = 282;
					buff.isUntimedBuff = true;
					buff.stateValues["nextActivationTime"] = CH2.user.totalMsecsPlayed + CH2.roller.attackRoller.range(10000,30000);
					buff.stateValues["remainingActivations"] = 3 * tempNumCharges;
					buff.tooltipFunction = function() {
						return {
							"header": "Comet Shower",
							"body": ""
						};
					};
					buff.tickFunction = function() {
						if (CH2.user.totalMsecsPlayed <= this.stateValues["nextActivationTime"])
						{
							activateSpell(getSpell("iceFireDamage"), 0, true);
							this.stateValues["nextActivationTime"] = CH2.user.totalMsecsPlayed + CH2.roller.attackRoller.range(10000, 30000);
							this.stateValues["remainingActivations"]--;
							if (this.stateValues["remainingActivations"] <= 0)
							{
								CH2.currentCharacter.buffs.removeBuff("Comet Shower");
							}
						}
					}
					CH2.currentCharacter.buffs.addBuff(buff);
					useCharges("iceFire3");
				}
			}
		}
		
		public function lightningZapActivation(spell:Spell):void
		{
			var buffName:String = "LightningZap";
			if (!CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				var buff:Buff = new Buff();
				buff.name = buffName;
				buff.iconId = 375;
				buff.isUntimedBuff = true;
				buff.stacks = 2;
				buff.stateValues["spellDamage"] = spell.damage.multiplyN(BASE_LIGHTNING_ZAP_PERCENT_DAMAGE + CH2.currentCharacter.getTrait("LightningZapPercentDamage"));
				buff.tooltipFunction = function() {
					return {
						"header": "Lightning Zap",
						"body": "Increases your next 2 clicks attacks"
					};
				};
				CH2.currentCharacter.buffs.addBuff(buff);
			}
			else
			{
				CH2.currentCharacter.buffs.getBuff(buffName).stateValues["spellDamage"] = spell.damage.multiplyN(BASE_LIGHTNING_ZAP_PERCENT_DAMAGE + CH2.currentCharacter.getTrait("LightningZapPercentDamage"));
				CH2.currentCharacter.buffs.getBuff(buffName).stacks = 2;
			}
		}
		
		public function fireZapActivation(spell:Spell):void
		{
			var buffName:String = "FireZap";
			if (!CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				var buff:Buff = new Buff();
				buff.name = buffName;
				buff.iconId = 375;
				buff.isUntimedBuff = true;
				buff.stacks = 2;
				buff.stateValues["spellDamage"] = spell.damage.multiplyN(CH2.currentCharacter.getTrait("FireZapPercentDamage"));
				buff.tooltipFunction = function() {
					return {
						"header": "Fire Zap",
						"body": "Increases your next 2 click attacks"
					};
				};
				CH2.currentCharacter.buffs.addBuff(buff);
			}
			else
			{
				CH2.currentCharacter.buffs.getBuff(buffName).stateValues["spellDamage"] = spell.damage.multiplyN(CH2.currentCharacter.getTrait("FireZapPercentDamage"));
				CH2.currentCharacter.buffs.getBuff(buffName).stacks = 2;
			}
		}
		
		public function useLightningZap():void
		{
			var buffName:String = "LightningZap";
			if (CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				var zapBuff:Buff = CH2.currentCharacter.buffs.getBuff(buffName);
				zapBuff.stacks--;
				if (zapBuff.stacks <= 0)
				{
					CH2.currentCharacter.buffs.removeBuff(buffName);
				}
			}
		}
		
		public function useFireZap():void
		{
			var buffName:String = "FireZap";
			if (CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				var zapBuff:Buff = CH2.currentCharacter.buffs.getBuff(buffName);
				zapBuff.stacks--;
				if (zapBuff.stacks <= 0)
				{
					CH2.currentCharacter.buffs.removeBuff(buffName);
				}
			}
		}
		
		public function applySpellTypeFatigue(spell:Spell, reduction:int = 0):void
		{
			for (var i:int = 0; i < spell.types.length; i++)
			{
				if (spell.types[i] != NEUTRAL_RUNE_ID)
				{
					var stacksToAdd:int = spell.rank - reduction;
					if (stacksToAdd > 0)
					{
						var buffName:String = spell.types[i] + "Fatigue";
						if (CH2.currentCharacter.buffs.hasBuffByName(buffName))
						{
							CH2.currentCharacter.buffs.getBuff(buffName).stacks += stacksToAdd;
						}
						else
						{
							var spellDebuff:Buff = new Buff();
							spellDebuff.tickRate = 17;
							var tooltipName:String = "";
							if (spell.types[0] == ICE_RUNE_ID)
							{
								spellDebuff.iconId = 369;
								tooltipName = "Fatigue: Hypothermia";
							}
							else if (spell.types[0] == FIRE_RUNE_ID)
							{
								spellDebuff.iconId = 368;
								tooltipName = "Fatigue: Hyperthermia";
							}
							else
							{
								spellDebuff.iconId = 370; //need lightning hand
								tooltipName = "Fatigue: Enervation";
							}
							
							spellDebuff.isUntimedBuff = false;
							spellDebuff.name = buffName;
							spellDebuff.unhastened = true;
							spellDebuff.duration = 8000; // (spell.rank + 1) * 1000;
							spellDebuff.stacks = stacksToAdd;
							spellDebuff.stateValues["type"] = spell.types[i];
							spellDebuff.stateValues["typeName"] = SPELL_TYPE_NAMES[spell.types[i]];
							spellDebuff.tickFunction = function(){
								if (this.timeLeft <= 17 && this.stacks > 1)
								{
									reduceSpellTypeFatigue(this.stateValues["type"], 1);
									this.duration = 8000; // this.stacks * 1000;
									this.timeSinceActivated = 0;
								}
							}
							spellDebuff.tooltipFunction = function() {
								return {
									"header": tooltipName,
									"body": "Increases energy cost of "+this.stateValues["typeName"]+" spells by "+100*FATIGUE_COST+"% for each stack.\n\nCasting "+this.stateValues["typeName"]+" spells adds stacks."
								};
							}
							CH2.currentCharacter.buffs.addBuff(spellDebuff);
						}
					}
				}
			}
		}
		
		public function reduceSpellTypeFatigue(type:int, numToReduce:int):void
		{
			var buffName:String = type + "Fatigue";
			if (CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				var buff:Buff = CH2.currentCharacter.buffs.getBuff(buffName);
				
				var numStacksToRemove:Number = Math.min(numToReduce, buff.stacks);
				if (CH2.currentCharacter.buffs.hasBuffByName("Energize"))
				{
					var energyToAdd:Number = numStacksToRemove * CH2.currentCharacter.getTrait("EnergizeEnergyRestoration");
					CH2.currentCharacter.addEnergy(energyToAdd, false);
				}
				
				buff.stacks -= numStacksToRemove;
				if (buff.stacks <= 0)
				{
					CH2.currentCharacter.buffs.removeBuff(buffName);
				}
			}
		}
		
		public function applySpellTypeCharge(spell:Spell):void
		{
			var chargesToApply:Vector.<Charge> = new Vector.<Charge>();
			var spellHistoryLength:int = spellTypeHistory.length;
			var activeCharges:Vector.<Charge> = getActiveCharges();
			for (var i:int = activeCharges.length - 1; i > 0; i--)
			{
				if (CH2.currentCharacter.buffs.hasBuffByName(activeCharges[i].id + " Cooldown"))
				{
					activeCharges.splice(i, 1);
				}
			}
			
			for (var i:int = 0; i < activeCharges.length; i++)
			{
				var candidateChargeLength:int = activeCharges[i].spellTypeCombination.length;
				if (spellHistoryLength >= candidateChargeLength)
				{
					for (var j:int = 0; j < candidateChargeLength; j++)
					{
						if (spellTypeHistory[spellHistoryLength - 1 - j].indexOf(activeCharges[i].spellTypeCombination[candidateChargeLength - 1 - j]) == -1)
						{
							break;
						}
						else if (j == candidateChargeLength - 1)
						{
							chargesToApply.push(activeCharges[i]);
						}
					}
				}
			}
			
			for (var i:int = 0; i < chargesToApply.length; i++)
			{
				addCharge(chargesToApply[i]);
			}
		}
		
		public function addCharge(charge:Charge):void
		{
			var buffName:String = charge.id  + " Charge";
			if (CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				CH2.currentCharacter.buffs.getBuff(buffName).stacks++;
			}
			else
			{
				var spellCharge:Buff = new Buff();
				spellCharge.iconId = charge.iconId;
				spellCharge.isUntimedBuff = true;
				spellCharge.unhastened = true;
				spellCharge.name = buffName;
				spellCharge.stateValues["charge"] = charge;
				spellCharge.tooltipFunction = function(){ return this.stateValues["charge"]["tooltip"] };
				CH2.currentCharacter.buffs.addBuff(spellCharge);
			}
		}
		
		public function hasCharge(chargeId:String):Boolean
		{
			return CH2.currentCharacter.buffs.hasBuffByName(chargeId + " Charge");
		}
		
		public function numCharges(chargeId:String):int
		{
			var buffName:String = chargeId + " Charge";
			if (CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				return CH2.currentCharacter.buffs.getBuff(buffName).stacks;
			}
			else
			{
				return 0;
			}
		}
		
		public function useCharges(chargeId:String):void
		{
			var buffName:String = chargeId + " Charge";
			if (CH2.currentCharacter.buffs.hasBuffByName(buffName))
			{
				if (CH2.currentCharacter.buffs.getBuff(buffName).stacks <= 0)
				{
					CH2.currentCharacter.buffs.removeBuff(buffName);
				}
			}
		}
		
		//######################################################################
		//#################### DISPLAY SPELL & RUNE EFFECTS ####################
		//######################################################################
		
		public var staffElement:CharacterUIElement;
		public function staffEffect():void
		{
			if (staffElement != null) return;
			
			staffElement = new CharacterUIElement();
			staffElement.active = true;
			staffElement.name = "WizStaff";
			var staffAsset:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip("Wizard_staff");
			staffElement.addChild(staffAsset);
			staffElement.type = CharacterDisplayUI.OTHER_ELEMENT;
			staffElement.useWorldCoordinates = false;
			staffElement.worldX = CH2.currentCharacter.x;
			staffElement.worldY = CH2.currentCharacter.y + 125;
			staffElement.updateHook = function(dt:Number):void
			{
				this.worldX = CH2.currentCharacter.x + ((RUNE_DISTANCE_APART/2) * pendingRunes.length);
				this.worldY = CH2.currentCharacter.y + 125;
				
				this.x = CH2.world.worldToScreenX(this.worldX, this.worldY) - CH2.currentCharacter.characterDisplay.display.x;
				this.y = CH2.world.worldToScreenY(this.worldX, this.worldY) - CH2.currentCharacter.characterDisplay.display.y;
				
				this.visible = pendingRunes.length > 0;
			}
			if (!CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(staffElement.name))
			{
				CH2.currentCharacter.characterDisplay.characterUI.addUIElement(staffElement, CH2.currentCharacter.characterDisplay.characterUI.behindCharacterDisplay);
			}
		}
		
		public var activeCircleEffects:Array = [];
		public function addSpellCircleEffect(highestSpell:Spell):void
		{
			for (var i:int = 0; i < highestSpell.spellRings.length; i++)
			{
				var circleAsset:GpuImage = CH2AssetManager.instance.getGpuImage("Wizard_spellCircle" + highestSpell.spellRings[i]);
				var circleEffect:CharacterUIElement = new CharacterUIElement();
				circleEffect.active = true;
				circleEffect.name = highestSpell.spellRings[i];
				circleEffect.addChild(circleAsset);
				circleEffect.type = CharacterDisplayUI.OTHER_ELEMENT;
				circleEffect.useWorldCoordinates = false;
				circleEffect.worldX = CH2.currentCharacter.x;
				circleEffect.worldY = CH2.currentCharacter.y;
				circleEffect.rotation = Math.PI / 6;
				circleEffect.skewX = Math.PI / 6;
				circleEffect.modStateHolder["index"] = i;
				
				circleEffect.updateHook = function(dt:Number):void
				{
					this.worldX = CH2.currentCharacter.x;
					this.worldY = CH2.currentCharacter.y;
					
					if (this.modStateHolder["index"] != 1)
					{
						this.getChildAt(0).rotation = (MiscUtils.cachedTime / (this.modStateHolder["index"]+1 * 2000) * Math.PI / 6) % (Math.PI * 2);
					}
					else
					{
						this.getChildAt(0).rotation = ((MiscUtils.cachedTime / (this.modStateHolder["index"]+1 * 2000) * Math.PI / 6) % (Math.PI * 2)) * -1;
					}
					
					this.x = CH2.world.worldToScreenX(this.worldX, this.worldY);
					this.y = CH2.world.worldToScreenY(this.worldX, this.worldY);
				}
				if (!CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(circleEffect.name))
				{
					CH2.currentCharacter.characterDisplay.characterUI.addUIElement(circleEffect, CH2.world.roomsBack);
					addIgniteEffect(circleAsset);
					activeCircleEffects.push(circleEffect);
				}
			}
		}
		
		public var spellCastBar:CharacterUIElement;
		public var castBar:Quad;
		public var castBarFill:Quad;
		public var cutPasteHighlight:Quad;
		public function addCastBar():void
		{
			if (castBar != null && spellCastBar.parent != null) return;
			
			castBar = new Quad(1, 5);
			castBar.y = -1.2 * RUNE_DISTANCE_APART;
			castBarFill = new Quad(1, 3, 0x000000);
			castBarFill.y = castBar.y + 2;
			cutPasteHighlight = new Quad(1, 100, 0x3399ff);
			cutPasteHighlight.y = castBar.y + 5;
			
			spellCastBar = new CharacterUIElement();
			spellCastBar.active = true;
			spellCastBar.name = "spellCountDown";
			spellCastBar.addChild(cutPasteHighlight);
			spellCastBar.addChild(castBar);
			spellCastBar.addChild(castBarFill);
			spellCastBar.type = CharacterDisplayUI.OTHER_ELEMENT;
			spellCastBar.useWorldCoordinates = false;
			spellCastBar.worldX = CH2.currentCharacter.x;
			spellCastBar.worldY = CH2.currentCharacter.y;
			castBar.skewX = Math.PI / 6.75;
			castBarFill.skewX = Math.PI / 6.75;
			cutPasteHighlight.skewX = Math.PI / -6.75;
			
			spellCastBar.updateHook = function(dt:Number):void
			{
				if (pendingRunes.length == 0)
				{
					this.visible = false;
				}
				else
				{
					this.visible = true;
					
					cutPasteHighlight.visible = isCutting || wasPasted;
					
					var adjustedWidthPerRune:Number = RUNE_DISTANCE_APART / Math.cos(Math.PI / 6.75);
					this.worldX = CH2.currentCharacter.x - ((adjustedWidthPerRune/2) * (pendingRunes.length+1));
					this.worldY = CH2.currentCharacter.y + 135;
					
					this.x = CH2.world.worldToScreenX(this.worldX, this.worldY) - CH2.currentCharacter.characterDisplay.display.x;
					this.y = CH2.world.worldToScreenY(this.worldX, this.worldY) - CH2.currentCharacter.characterDisplay.display.y;
					
					castBar.rotation = 0;
					castBarFill.rotation = 0;
					cutPasteHighlight.rotation = 0;
					
					castBar.width = pendingRunes.length * adjustedWidthPerRune;
					var percentComplete:Number =  1 - (timeLeftInSpell() / totalSpellCastDuration());
					castBarFill.width = (pendingRunes.length) * (adjustedWidthPerRune) * Math.min(1, percentComplete);
					cutPasteHighlight.width = castBar.width;
					
					castBar.rotation = Math.PI / 6.75;
					castBarFill.rotation = Math.PI / 6.75;
					cutPasteHighlight.rotation = Math.PI / 6.75;
				}
			}
			
			if (!CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(spellCastBar.name))
			{
				CH2.currentCharacter.characterDisplay.characterUI.addUIElement(spellCastBar, CH2.currentCharacter.characterDisplay.characterUI.behindCharacterDisplay);
			}
		}
		
		public function addIgniteEffect(displayToAttachTo:starling.display.DisplayObject):void
		{
			var igniteEffect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip("Wizard_efModifyIgnite");
			addSinglePlayAttachedEffect(igniteEffect, displayToAttachTo);
		}
		public function addRunePlacedEffect(displayToAttachTo:starling.display.DisplayObject):void
		{
			var runePlacedEffect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip("Wizard_runePlaced");
			addSinglePlayAttachedEffect(runePlacedEffect, displayToAttachTo);
		}
		
		public function addSinglePlayAttachedEffect(effect:GpuMovieClip, displayToAttachTo:starling.display.DisplayObject):void
		{
			effect.gotoAndPlay(1);
			effect.isLooping = false;
			var uIElement:CharacterUIElement = new CharacterUIElement();
			uIElement.active = true;
			uIElement.name = "ignite";
			uIElement.type = CharacterDisplayUI.OTHER_ELEMENT;
			uIElement.useWorldCoordinates = false;
			uIElement.modStateHolder = effect;
			displayToAttachTo.addChild(effect);
			
			uIElement.updateHook = function(dt:Number):void
			{
				var effect:GpuMovieClip = (this.modStateHolder as GpuMovieClip);
				if (effect.highestFramePlayed >= effect.totalFrames)
				{
					effect.stop();
					if (effect.parent)
					{
						effect.parent.removeChild(this);
					}
					CH2.currentCharacter.characterDisplay.characterUI.removeUIElement(this);
				}
			}
			CH2.currentCharacter.characterDisplay.characterUI.addUIElement(uIElement, CH2.world.roomsBack);
		}
		
		public function doSpellHitEffect(monster:Monster):void
		{
			var animation:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip("Wizard_" + spellTypeName().toLowerCase() + "Hit", 30);
			animation.isLooping = false;
			CH2.world.addEffect(animation, CH2.world.roomsFront, monster.x, monster.y);
		}
		
		public function doDamageOverTimeBurnEffect(monster:Monster):GpuMovieClip
		{
			var animation:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip("Wizard_bedOfFlames");
			animation.isLooping = true;
			CH2.world.addEffect(animation, CH2.world.roomsBack, monster.x, monster.y);
			return animation;
		}
		
		public function renderChainLightningBetweenMonsters(monsters:Vector.<Monster>):void
		{
			for (var i:int = 0; i < monsters.length; i++)
			{
				var animation:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip("Wizard_singleLightningBolt");
				animation.isLooping = false;
				CH2.world.addEffect(animation, CH2.world.roomsFront, monsters[i].x, monsters[i].y, World.REMOVE_EFFECT_IMMEDIATELY_WHEN_FINISHED);
			}
		}
		
		private function easeInQuint(currentTime:Number, changeInValue:Number, duration:Number):Number
		{
			currentTime /= duration;
			return changeInValue*Math.pow(currentTime,5);
		}
		
		//#######################################################################
		//################################ RUNES ################################
		//#######################################################################
		
		private function unlockRunes():void
		{
			var fireRune:Skill = CH2.currentCharacter.getStaticSkill("Igni");
			CH2.currentCharacter.activateSkill(fireRune.uid);
			var iceRune:Skill = CH2.currentCharacter.getStaticSkill("Frigo");
			CH2.currentCharacter.activateSkill(iceRune.uid);
			var lightningRune:Skill = CH2.currentCharacter.getStaticSkill("Lor Vas");
			CH2.currentCharacter.activateSkill(lightningRune.uid);
			var rune2:Skill = CH2.currentCharacter.getStaticSkill("Kras");
			CH2.currentCharacter.activateSkill(rune2.uid);
			var rune3:Skill = CH2.currentCharacter.getStaticSkill("Ohm");
			CH2.currentCharacter.activateSkill(rune3.uid);
			var rune4:Skill = CH2.currentCharacter.getStaticSkill("Yrdei");
			CH2.currentCharacter.activateSkill(rune4.uid);
			var rune5:Skill = CH2.currentCharacter.getStaticSkill("Helio");
			CH2.currentCharacter.activateSkill(rune5.uid);
			var activateRune:Skill = CH2.currentCharacter.getStaticSkill("Exe");
			CH2.currentCharacter.activateSkill(activateRune.uid);
		}
		
		//#######################################################################
		//###################### SPELL SETUP FUNCTIONALITY ######################
		//#######################################################################
		
		public function setupSpells():void
		{
			spells = new Vector.<Spell>();
			
			//##########################################
			//################## ICE ###################
			//##########################################
			
			var ice1:Spell = new Spell();
			ice1.id = "ice1";
			ice1.rank = 1;
			ice1.types = [ICE_RUNE_ID];
			ice1.runeCombination = [2, 8];
			ice1.spellRings = ["Ice1"];
			ice1.spellEffects = ["Wizard_spellIce1"];
			ice1.spellActivationFunction = function(){doSpellDamage(this);};
			ice1.damageMultiplier = ICE_DAMAGE_MULTIPLIER;
			ice1.costMultiplier = ICE_COST_MULTIPLIER;
			ice1.msecsPerRune = ICE_MSEC_PER_RUNE;
			ice1.iconId = 1;
			ice1.spellPanelIcon = "BitmapHUD_iceRank1";
			ice1.displayName = ICE1["name"];
			ice1.description = ICE1["description"];
			ice1.tier = 1;
			ice1.spawnSound = "ice_1_spawn";
			ice1.impactSound = "ice1_impact";
			spells.push(ice1);
			
			var ice2:Spell = new Spell();
			ice2.id = "ice2";
			ice2.rank = 2;
			ice2.types = [ICE_RUNE_ID];
			ice2.runeCombination = [2, 5, 8];
			ice2.spellRings = ["Ice1"];
			ice2.spellEffects = ["Wizard_spellIce1"];
			ice2.spellActivationFunction = function(){doSpellDamage(this);};
			ice2.damageMultiplier = ICE_DAMAGE_MULTIPLIER;
			ice2.costMultiplier = ICE_COST_MULTIPLIER;
			ice2.msecsPerRune = ICE_MSEC_PER_RUNE;
			ice2.spellPanelIcon = "BitmapHUD_iceRank1";
			ice2.displayName = ICE2["name"];
			ice2.description = ICE2["description"];
			ice2.tier = 1;
			ice2.spawnSound = "ice_1_spawn";
			ice2.impactSound = "ice1_impact";
			spells.push(ice2);
			
			var ice3:Spell = new Spell();
			ice3.id = "ice3";
			ice3.rank = 3;
			ice3.types = [ICE_RUNE_ID];
			ice3.runeCombination = [2, 5, 3, 8];
			ice3.spellRings = ["Ice1"];
			ice3.spellEffects = ["Wizard_spellIce1"];
			ice3.spellActivationFunction = function(){doSpellDamage(this);};
			ice3.damageMultiplier = ICE_DAMAGE_MULTIPLIER;
			ice3.costMultiplier = ICE_COST_MULTIPLIER;
			ice3.msecsPerRune = ICE_MSEC_PER_RUNE;
			ice3.spellPanelIcon = "BitmapHUD_iceRank1";
			ice3.displayName = ICE3["name"];
			ice3.description = ICE3["description"];
			ice3.tier = 1;
			ice3.spawnSound = "ice_1_spawn";
			ice3.impactSound = "ice1_impact";
			spells.push(ice3);
			
			var ice4:Spell = new Spell();
			ice4.id = "ice4";
			ice4.rank = 4;
			ice4.types = [ICE_RUNE_ID];
			ice4.runeCombination = [2, 5, 3, 2, 8];
			ice4.spellRings = ["Ice1", "Ice2"];
			ice4.spellEffects = ["Wizard_spellIce2"];
			ice4.spellActivationFunction = function(){doSpellDamage(this);};
			ice4.damageMultiplier = ICE_DAMAGE_MULTIPLIER;
			ice4.costMultiplier = ICE_COST_MULTIPLIER;
			ice4.msecsPerRune = ICE_MSEC_PER_RUNE;
			ice4.spellPanelIcon = "BitmapHUD_iceRank1";
			ice4.displayName = ICE4["name"];
			ice4.description = ICE4["description"];
			ice4.tier = 2;
			ice4.spawnSound = "ice_5_spawn";
			ice4.impactSound = "ice_5_impact";
			spells.push(ice4);
			
			var ice5:Spell = new Spell();
			ice5.id = "ice5";
			ice5.rank = 5;
			ice5.types = [ICE_RUNE_ID];
			ice5.runeCombination = [2, 5, 3, 2, 4, 8];
			ice5.spellRings = ["Ice1", "Ice2"];
			ice5.spellEffects = ["Wizard_spellIce2"];
			ice5.spellActivationFunction = function(){doSpellDamage(this);};
			ice5.damageMultiplier = ICE_DAMAGE_MULTIPLIER;
			ice5.costMultiplier = ICE_COST_MULTIPLIER;
			ice5.msecsPerRune = ICE_MSEC_PER_RUNE;
			ice5.spellPanelIcon = "BitmapHUD_iceRank1";
			ice5.displayName = ICE5["name"];
			ice5.description = ICE5["description"];
			ice5.tier = 2;
			ice5.spawnSound = "ice_5_spawn";
			ice5.impactSound = "ice_5_impact";
			spells.push(ice5);
			
			var ice6:Spell = new Spell();
			ice6.id = "ice6";
			ice6.rank = 6;
			ice6.types = [ICE_RUNE_ID];
			ice6.runeCombination = [2, 5, 3, 2, 4, 7, 8];
			ice6.spellRings = ["Ice1", "Ice2"];
			ice6.spellEffects = ["Wizard_spellIce2"];
			ice6.spellActivationFunction = function(){doSpellDamage(this);};
			ice6.damageMultiplier = ICE_DAMAGE_MULTIPLIER;
			ice6.costMultiplier = ICE_COST_MULTIPLIER;
			ice6.msecsPerRune = ICE_MSEC_PER_RUNE;
			ice6.spellPanelIcon = "BitmapHUD_iceRank1";
			ice6.displayName = ICE6["name"];
			ice6.description = ICE6["description"];
			ice6.tier = 2;
			ice6.spawnSound = "ice_5_spawn";
			ice6.impactSound = "ice_5_impact";
			spells.push(ice6);
			
			var ice7:Spell = new Spell();
			ice7.id = "ice7";
			ice7.rank = 7;
			ice7.types = [ICE_RUNE_ID];
			ice7.runeCombination = [2, 5, 3, 2, 4, 7, 2, 8];
			ice7.spellRings = ["Ice1", "Ice2", "Ice3"];
			ice7.spellEffects = ["Wizard_spellIce3"];
			ice7.spellActivationFunction = function(){doSpellDamage(this);};
			ice7.damageMultiplier = ICE_DAMAGE_MULTIPLIER;
			ice7.costMultiplier = ICE_COST_MULTIPLIER;
			ice7.msecsPerRune = ICE_MSEC_PER_RUNE;
			ice7.spellPanelIcon = "BitmapHUD_iceRank1";
			ice7.displayName = ICE7["name"];
			ice7.description = ICE7["description"];
			ice7.tier = 3;
			ice7.spawnSound = "ice_9_spawn";
			ice7.impactSound = "ice_9_impact";
			spells.push(ice7);
			
			var ice8:Spell = new Spell();
			ice8.id = "ice8";
			ice8.rank = 8;
			ice8.types = [ICE_RUNE_ID];
			ice8.runeCombination = [2, 5, 3, 2, 4, 7, 2, 3, 8];
			ice8.spellRings = ["Ice1", "Ice2", "Ice3"];
			ice8.spellEffects = ["Wizard_spellIce3"];
			ice8.spellActivationFunction = function(){doSpellDamage(this);};
			ice8.damageMultiplier = ICE_DAMAGE_MULTIPLIER;
			ice8.costMultiplier = ICE_COST_MULTIPLIER;
			ice8.msecsPerRune = ICE_MSEC_PER_RUNE;
			ice8.spellPanelIcon = "BitmapHUD_iceRank1";
			ice8.displayName = ICE8["name"];
			ice8.description = ICE8["description"];
			ice8.tier = 3;
			ice8.spawnSound = "ice_9_spawn";
			ice8.impactSound = "ice_9_impact";
			spells.push(ice8);
			
			var ice9:Spell = new Spell();
			ice9.id = "ice9";
			ice9.rank = 9;
			ice9.types = [ICE_RUNE_ID];
			ice9.runeCombination = [2, 5, 3, 2, 4, 7, 2, 3, 5, 8];
			ice9.spellRings = ["Ice1", "Ice2", "Ice3"];
			ice9.spellEffects = ["Wizard_spellIce3"];
			ice9.spellActivationFunction = function(){doSpellDamage(this);};
			ice9.damageMultiplier = ICE_DAMAGE_MULTIPLIER;
			ice9.costMultiplier = ICE_COST_MULTIPLIER;
			ice9.msecsPerRune = ICE_MSEC_PER_RUNE;
			ice9.spellPanelIcon = "BitmapHUD_iceRank1";
			ice9.displayName = ICE9["name"];
			ice9.description = ICE9["description"];
			ice9.tier = 3;
			ice9.spawnSound = "ice_9_spawn";
			ice9.impactSound = "ice_9_impact";
			spells.push(ice9);
			
			//###########################################
			//################## FIRE ###################
			//###########################################			
			
			var fire1:Spell = new Spell();
			fire1.id = "fire1";
			fire1.rank = 1;
			fire1.types = [FIRE_RUNE_ID];
			fire1.runeCombination = [1, 8];
			fire1.spellRings = ["Fire1"];
			fire1.spellEffects = ["Wizard_spellFire1"];
			fire1.spellActivationFunction = function(){doSpellDamage(this);};
			fire1.damageMultiplier = FIRE_DAMAGE_MULTIPLIER;
			fire1.costMultiplier = FIRE_COST_MULTIPLIER;
			fire1.msecsPerRune = FIRE_MSEC_PER_RUNE;
			fire1.spellPanelIcon = "BitmapHUD_fireRank1";
			fire1.displayName = FIRE1["name"];
			fire1.description = FIRE1["description"];
			fire1.tier = 1;
			fire1.spawnSound = "fire_1_spawn";
			fire1.impactSound = "fire_1_impact";
			spells.push(fire1);
			
			var fire2:Spell = new Spell();
			fire2.id = "fire2";
			fire2.rank = 2;
			fire2.types = [FIRE_RUNE_ID];
			fire2.runeCombination = [1, 4, 8];
			fire2.spellRings = ["Fire1"];
			fire2.spellEffects = ["Wizard_spellFire1"];
			fire2.spellActivationFunction = function(){doSpellDamage(this);};
			fire2.damageMultiplier = FIRE_DAMAGE_MULTIPLIER;
			fire2.costMultiplier = FIRE_COST_MULTIPLIER;
			fire2.msecsPerRune = FIRE_MSEC_PER_RUNE;
			fire2.spellPanelIcon = "BitmapHUD_fireRank1";
			fire2.displayName = FIRE2["name"];
			fire2.description = FIRE2["description"];
			fire2.tier = 1;
			fire2.spawnSound = "fire_1_spawn";
			fire2.impactSound = "fire_1_impact";
			spells.push(fire2);
			
			var fire3:Spell = new Spell();
			fire3.id = "fire3";
			fire3.rank = 3;
			fire3.types = [FIRE_RUNE_ID];
			fire3.runeCombination = [1, 4, 2, 8];
			fire3.spellRings = ["Fire1"];
			fire3.spellEffects = ["Wizard_spellFire1"];
			fire3.spellActivationFunction = function(){doSpellDamage(this);};
			fire3.damageMultiplier = FIRE_DAMAGE_MULTIPLIER;
			fire3.costMultiplier = FIRE_COST_MULTIPLIER;
			fire3.msecsPerRune = FIRE_MSEC_PER_RUNE;
			fire3.spellPanelIcon = "BitmapHUD_fireRank1";
			fire3.displayName = FIRE3["name"];
			fire3.description = FIRE3["description"];
			fire3.tier = 1;
			fire3.spawnSound = "fire_1_spawn";
			fire3.impactSound = "fire_1_impact";
			spells.push(fire3);
			
			var fire4:Spell = new Spell();
			fire4.id = "fire4";
			fire4.rank = 4;
			fire4.types = [FIRE_RUNE_ID];
			fire4.runeCombination = [1, 4, 2, 1, 8];
			fire4.spellRings = ["Fire1","Fire2"];
			fire4.spellEffects = ["Wizard_spellFire2"];
			fire4.spellActivationFunction = function(){doSpellDamage(this);};
			fire4.damageMultiplier = FIRE_DAMAGE_MULTIPLIER;
			fire4.costMultiplier = FIRE_COST_MULTIPLIER;
			fire4.msecsPerRune = FIRE_MSEC_PER_RUNE;
			fire4.spellPanelIcon = "BitmapHUD_fireRank1";
			fire4.displayName = FIRE4["name"];
			fire4.description = FIRE4["description"];
			fire4.tier = 2;
			fire4.spawnSound = "fire_5_spawn";
			fire4.impactSound = "fire_5_impact";
			spells.push(fire4);
			
			var fire5:Spell = new Spell();
			fire5.id = "fire5";
			fire5.rank = 5;
			fire5.types = [FIRE_RUNE_ID];
			fire5.runeCombination = [1, 4, 2, 1, 6, 8];
			fire5.spellRings = ["Fire1","Fire2"];
			fire5.spellEffects = ["Wizard_spellFire2"];
			fire5.spellActivationFunction = function(){doSpellDamage(this);};
			fire5.damageMultiplier = FIRE_DAMAGE_MULTIPLIER;
			fire5.costMultiplier = FIRE_COST_MULTIPLIER;
			fire5.msecsPerRune = FIRE_MSEC_PER_RUNE;
			fire5.spellPanelIcon = "BitmapHUD_fireRank1";
			fire5.displayName = FIRE5["name"];
			fire5.description = FIRE5["description"];
			fire5.tier = 2;
			fire5.spawnSound = "fire_5_spawn";
			fire5.impactSound = "fire_5_impact";
			spells.push(fire5);
			
			var fire6:Spell = new Spell();
			fire6.id = "fire6";
			fire6.rank = 6;
			fire6.types = [FIRE_RUNE_ID];
			fire6.runeCombination = [1, 4, 2, 1, 6, 7, 8];
			fire6.spellRings = ["Fire1","Fire2"];
			fire6.spellEffects = ["Wizard_spellFire2"];
			fire6.spellActivationFunction = function(){doSpellDamage(this);};
			fire6.damageMultiplier = FIRE_DAMAGE_MULTIPLIER;
			fire6.costMultiplier = FIRE_COST_MULTIPLIER;
			fire6.msecsPerRune = FIRE_MSEC_PER_RUNE;
			fire6.spellPanelIcon = "BitmapHUD_fireRank1";
			fire6.displayName = FIRE6["name"];
			fire6.description = FIRE6["description"];
			fire6.tier = 2;
			fire6.spawnSound = "fire_5_spawn";
			fire6.impactSound = "fire_5_impact";
			spells.push(fire6);
			
			var fire7:Spell = new Spell();
			fire7.id = "fire7";
			fire7.rank = 7;
			fire7.types = [FIRE_RUNE_ID];
			fire7.runeCombination = [1, 4, 2, 1, 6, 7, 1, 8];
			fire7.spellRings = ["Fire1","Fire2","Fire3"];
			fire7.spellEffects = ["Wizard_spellFire3"];
			fire7.spellActivationFunction = function(){doSpellDamage(this);};
			fire7.damageMultiplier = FIRE_DAMAGE_MULTIPLIER;
			fire7.costMultiplier = FIRE_COST_MULTIPLIER;
			fire7.msecsPerRune = FIRE_MSEC_PER_RUNE;
			fire7.spellPanelIcon = "BitmapHUD_fireRank1";
			fire7.displayName = FIRE7["name"];
			fire7.description = FIRE7["description"];
			fire7.tier = 3;
			fire7.spawnSound = "fire_9_spawn";
			fire7.impactSound = "fire_9_impact";
			spells.push(fire7);
			
			var fire8:Spell = new Spell();
			fire8.id = "fire8";
			fire8.rank = 8;
			fire8.types = [FIRE_RUNE_ID];
			fire8.runeCombination = [1, 4, 2, 1, 6, 7, 1, 2, 8];
			fire8.spellRings = ["Fire1","Fire2","Fire3"];
			fire8.spellEffects = ["Wizard_spellFire3"];
			fire8.spellActivationFunction = function(){doSpellDamage(this);};
			fire8.damageMultiplier = FIRE_DAMAGE_MULTIPLIER;
			fire8.costMultiplier = FIRE_COST_MULTIPLIER;
			fire8.msecsPerRune = FIRE_MSEC_PER_RUNE;
			fire8.spellPanelIcon = "BitmapHUD_fireRank1";
			fire8.displayName = FIRE8["name"];
			fire8.description = FIRE8["description"];
			fire8.tier = 3;
			fire8.spawnSound = "fire_9_spawn";
			fire8.impactSound = "fire_9_impact";
			spells.push(fire8);
			
			var fire9:Spell = new Spell();
			fire9.id = "fire9";
			fire9.rank = 9;
			fire9.types = [FIRE_RUNE_ID];
			fire9.runeCombination = [1, 4, 2, 1, 6, 7, 1, 2, 4, 8];
			fire9.spellRings = ["Fire1","Fire2","Fire3"];
			fire9.spellEffects = ["Wizard_spellFire3"];
			fire9.spellActivationFunction = function(){doSpellDamage(this);};
			fire9.damageMultiplier = FIRE_DAMAGE_MULTIPLIER;
			fire9.costMultiplier = FIRE_COST_MULTIPLIER;
			fire9.msecsPerRune = FIRE_MSEC_PER_RUNE;
			fire9.spellPanelIcon = "BitmapHUD_fireRank1";
			fire9.displayName = FIRE9["name"];
			fire9.description = FIRE9["description"];
			fire9.tier = 3;
			fire9.spawnSound = "fire_9_spawn";
			fire9.impactSound = "fire_9_impact";
			spells.push(fire9);
			
			//################################################
			//################## LIGHTNING ###################
			//################################################	
			
			var lightning1:Spell = new Spell();
			lightning1.id = "lightning1";
			lightning1.rank = 1;
			lightning1.types = [LIGHTNING_RUNE_ID];
			lightning1.runeCombination = [3, 8];
			lightning1.spellRings = ["Lightning1"];
			lightning1.spellEffects = ["Wizard_spellLightning1"];
			lightning1.spellActivationFunction = function(){doSpellDamage(this);};
			lightning1.damageMultiplier = LIGHTNING_DAMAGE_MULTIPLIER;
			lightning1.costMultiplier = LIGHTNING_COST_MULTIPLIER;
			lightning1.msecsPerRune = LIGHTNING_MSEC_PER_RUNE;
			lightning1.spellPanelIcon = "BitmapHUD_lightningRank1";
			lightning1.displayName = LIGHTNING1["name"];
			lightning1.description = LIGHTNING1["description"];
			lightning1.tier = 1;
			lightning1.spawnSound = "lightning_1_spawn";
			lightning1.impactSound = "lightning_1_impact";
			spells.push(lightning1);
			
			var lightning2:Spell = new Spell();
			lightning2.id = "lightning2";
			lightning2.rank = 2;
			lightning2.types = [LIGHTNING_RUNE_ID];
			lightning2.runeCombination = [3, 6, 8];
			lightning2.spellRings = ["Lightning1"];
			lightning2.spellEffects = ["Wizard_spellLightning1"];
			lightning2.spellActivationFunction = function(){doSpellDamage(this);};
			lightning2.damageMultiplier = LIGHTNING_DAMAGE_MULTIPLIER;
			lightning2.costMultiplier = LIGHTNING_COST_MULTIPLIER;
			lightning2.msecsPerRune = LIGHTNING_MSEC_PER_RUNE;
			lightning2.spellPanelIcon = "BitmapHUD_lightningRank1";
			lightning2.displayName = LIGHTNING2["name"];
			lightning2.description = LIGHTNING2["description"];
			lightning2.tier = 1;
			lightning2.spawnSound = "lightning_1_spawn";
			lightning2.impactSound = "lightning_1_impact";
			spells.push(lightning2);
			
			var lightning3:Spell = new Spell();
			lightning3.id = "lightning3";
			lightning3.rank = 3;
			lightning3.types = [LIGHTNING_RUNE_ID];
			lightning3.runeCombination = [3, 6, 1, 8];
			lightning3.spellRings = ["Lightning1"];
			lightning3.spellEffects = ["Wizard_spellLightning1"];
			lightning3.spellActivationFunction = function(){doSpellDamage(this);};
			lightning3.damageMultiplier = LIGHTNING_DAMAGE_MULTIPLIER;
			lightning3.costMultiplier = LIGHTNING_COST_MULTIPLIER;
			lightning3.msecsPerRune = LIGHTNING_MSEC_PER_RUNE;
			lightning3.spellPanelIcon = "BitmapHUD_lightningRank1";
			lightning3.displayName = LIGHTNING3["name"];
			lightning3.description = LIGHTNING3["description"];
			lightning3.tier = 1;
			lightning3.spawnSound = "lightning_1_spawn";
			lightning3.impactSound = "lightning_1_impact";
			spells.push(lightning3);
			
			var lightning4:Spell = new Spell();
			lightning4.id = "lightning4";
			lightning4.rank = 4;
			lightning4.types = [LIGHTNING_RUNE_ID];
			lightning4.runeCombination = [3, 6, 1, 3, 8];
			lightning4.spellRings = ["Lightning1","Lightning2"];
			lightning4.spellEffects = ["Wizard_spellLightning2"];
			lightning4.spellActivationFunction = function(){doSpellDamage(this);};
			lightning4.damageMultiplier = LIGHTNING_DAMAGE_MULTIPLIER;
			lightning4.costMultiplier = LIGHTNING_COST_MULTIPLIER;
			lightning4.msecsPerRune = LIGHTNING_MSEC_PER_RUNE;
			lightning4.spellPanelIcon = "BitmapHUD_lightningRank1";
			lightning4.displayName = LIGHTNING4["name"];
			lightning4.description = LIGHTNING4["description"];
			lightning4.tier = 2;
			lightning4.spawnSound = "lightning_5_spawn";
			lightning4.impactSound = "lightning_5_impact";
			spells.push(lightning4);
			
			var lightning5:Spell = new Spell();
			lightning5.id = "lightning5";
			lightning5.rank = 5;
			lightning5.types = [LIGHTNING_RUNE_ID];
			lightning5.runeCombination = [3, 6, 1, 3, 5, 8];
			lightning5.spellRings = ["Lightning1","Lightning2"];
			lightning5.spellEffects = ["Wizard_spellLightning2"];
			lightning5.spellActivationFunction = function(){doSpellDamage(this);};
			lightning5.damageMultiplier = LIGHTNING_DAMAGE_MULTIPLIER;
			lightning5.costMultiplier = LIGHTNING_COST_MULTIPLIER;
			lightning5.msecsPerRune = LIGHTNING_MSEC_PER_RUNE;
			lightning5.spellPanelIcon = "BitmapHUD_lightningRank1";
			lightning5.displayName = LIGHTNING5["name"];
			lightning5.description = LIGHTNING5["description"];
			lightning5.tier = 2;
			lightning5.spawnSound = "lightning_5_spawn";
			lightning5.impactSound = "lightning_5_impact";
			spells.push(lightning5);
			
			var lightning6:Spell = new Spell();
			lightning6.id = "lightning6";
			lightning6.rank = 6;
			lightning6.types = [LIGHTNING_RUNE_ID];
			lightning6.runeCombination = [3, 6, 1, 3, 5, 7, 8];
			lightning6.spellRings = ["Lightning1","Lightning2"];
			lightning6.spellEffects = ["Wizard_spellLightning2"];
			lightning6.spellActivationFunction = function(){doSpellDamage(this);};
			lightning6.damageMultiplier = LIGHTNING_DAMAGE_MULTIPLIER;
			lightning6.costMultiplier = LIGHTNING_COST_MULTIPLIER;
			lightning6.msecsPerRune = LIGHTNING_MSEC_PER_RUNE;
			lightning6.spellPanelIcon = "BitmapHUD_lightningRank1";
			lightning6.displayName = LIGHTNING6["name"];
			lightning6.description = LIGHTNING6["description"];
			lightning6.tier = 2;
			lightning6.spawnSound = "lightning_5_spawn";
			lightning6.impactSound = "lightning_5_impact";
			spells.push(lightning6);
			
			var lightning7:Spell = new Spell();
			lightning7.id = "lightning7";
			lightning7.rank = 7;
			lightning7.types = [LIGHTNING_RUNE_ID];
			lightning7.runeCombination = [3, 6, 1, 3, 5, 7, 3, 8];
			lightning7.spellRings = ["Lightning1","Lightning2","Lightning3"];
			lightning7.spellEffects = ["Wizard_spellLightning3"];
			lightning7.spellActivationFunction = function(){doSpellDamage(this);};
			lightning7.damageMultiplier = LIGHTNING_DAMAGE_MULTIPLIER;
			lightning7.costMultiplier = LIGHTNING_COST_MULTIPLIER;
			lightning7.msecsPerRune = LIGHTNING_MSEC_PER_RUNE;
			lightning7.spellPanelIcon = "BitmapHUD_lightningRank1";
			lightning7.displayName = LIGHTNING7["name"];
			lightning7.description = LIGHTNING7["description"];
			lightning7.tier = 3;
			lightning7.spawnSound = "lightning_9_spawn";
			lightning7.impactSound = "lightning_9_impact";
			spells.push(lightning7);
			
			var lightning8:Spell = new Spell();
			lightning8.id = "lightning8";
			lightning8.rank = 8;
			lightning8.types = [LIGHTNING_RUNE_ID];
			lightning8.runeCombination = [3, 6, 1, 3, 5, 7, 3, 1, 8];
			lightning8.spellRings = ["Lightning1","Lightning2","Lightning3"];
			lightning8.spellEffects = ["Wizard_spellLightning3"];
			lightning8.spellActivationFunction = function(){doSpellDamage(this);};
			lightning8.damageMultiplier = LIGHTNING_DAMAGE_MULTIPLIER;
			lightning8.costMultiplier = LIGHTNING_COST_MULTIPLIER;
			lightning8.msecsPerRune = LIGHTNING_MSEC_PER_RUNE;
			lightning8.spellPanelIcon = "BitmapHUD_lightningRank1";
			lightning8.displayName = LIGHTNING8["name"];
			lightning8.description = LIGHTNING8["description"];
			lightning8.tier = 3;
			lightning8.spawnSound = "lightning_9_spawn";
			lightning8.impactSound = "lightning_9_impact";
			spells.push(lightning8);
			
			var lightning9:Spell = new Spell();
			lightning9.id = "lightning9";
			lightning9.rank = 9;
			lightning9.types = [LIGHTNING_RUNE_ID];
			lightning9.runeCombination = [3, 6, 1, 3, 5, 7, 3, 1, 6, 8];
			lightning9.spellRings = ["Lightning1","Lightning2","Lightning3"];
			lightning9.spellEffects = ["Wizard_spellLightning3"];
			lightning9.spellActivationFunction = function(){doSpellDamage(this);};
			lightning9.damageMultiplier = LIGHTNING_DAMAGE_MULTIPLIER;
			lightning9.costMultiplier = LIGHTNING_COST_MULTIPLIER;
			lightning9.msecsPerRune = LIGHTNING_MSEC_PER_RUNE;
			lightning9.spellPanelIcon = "BitmapHUD_lightningRank1";
			lightning9.displayName = LIGHTNING9["name"];
			lightning9.description = LIGHTNING9["description"];
			lightning9.tier = 3;
			lightning9.spawnSound = "lightning_9_spawn";
			lightning9.impactSound = "lightning_9_impact";
			spells.push(lightning9);
			
			//######################################################
			//###################### NEUTRAL #######################
			//######################################################
			
			//################### EARLY STARTERS ###################
			//Lightning Fire
			var cut:Spell = new Spell();
			cut.id = "cut";
			cut.rank = 1;
			cut.types = [NEUTRAL_RUNE_ID];
			cut.runeCombination = [7, 6, 3, 8];
			cut.spellRings = ["Neutral1"];
			cut.spellEffects = [];
			cut.spellActivationFunction = function(){cutActivation();};
			cut.damageMultiplier = 0;
			cut.costMultiplier = 0;
			cut.manaCost = 20;
			cut.iconId = 366;
			cut.msecsPerRune = BASE_ACTIVATION_WINDOW_PER_RUNE;
			cut.spellPanelIcon = "BitmapHUD_utilityCutAndPaste";
			cut.displayName = "Cut";
			cut.description = "Cuts and saves the next incantation you invoke.";
			spells.push(cut);
			
			var paste:Spell = new Spell();
			paste.id = "paste";
			paste.rank = 1;
			paste.types = [NEUTRAL_RUNE_ID];
			paste.runeCombination = [8, 8];
			paste.spellRings = ["Neutral1"];
			paste.spellEffects = [];
			paste.spellActivationFunction = function(){pasteActivation();};
			paste.damageMultiplier = 0;
			paste.costMultiplier = 0;
			paste.manaCost = 10;
			paste.msecsPerRune = BASE_ACTIVATION_WINDOW_PER_RUNE;
			paste.cooldownMsec = 0;
			paste.iconId = 366;
			paste.spellPanelIcon = "BitmapHUD_utilityCutAndPaste";
			paste.displayName = "Paste";
			paste.description = "Casts the last incantation you Cut.";
			spells.push(paste);
			
			var energize:Spell = new Spell();
			energize.id = "Energon Cube";
			energize.rank = 1;
			energize.types = [NEUTRAL_RUNE_ID];
			energize.runeCombination = [7, 5, 2, 8];
			energize.spellRings = ["Neutral1"];
			energize.spellEffects = [];
			energize.spellActivationFunction = function(){energizeActivation();};
			energize.damageMultiplier = 0;
			energize.costMultiplier = 0;
			energize.manaCost = 15;
			energize.msecsPerRune = BASE_ACTIVATION_WINDOW_PER_RUNE;
			energize.iconId = 261;
			energize.spellPanelIcon = "BitmapHUD_energizeSpell";
			energize.description = "";
			energize.displayName = "Energon Cube";
			energize.description = "Restores 1% energy and reduces all Fatigue by 1 every 2 seconds for 10 seconds. Stacks.";
			spells.push(energize);
			
			var darkRitual:Spell = new Spell();
			darkRitual.id = "iceFireDarkRitual";
			darkRitual.rank = 1;
			darkRitual.types = [NEUTRAL_RUNE_ID];
			darkRitual.runeCombination = [7, 4, 1, 8];
			darkRitual.spellRings = ["Neutral1"];
			darkRitual.spellEffects = [];
			darkRitual.spellActivationFunction = function(){darkRitualActivation();};
			darkRitual.damageMultiplier = 0;
			darkRitual.costMultiplier = 0;
			darkRitual.manaCost = 10;
			darkRitual.msecsPerRune = BASE_ACTIVATION_WINDOW_PER_RUNE;
			darkRitual.iconId = 355;
			darkRitual.spellPanelIcon = "BitmapHUD_darkRitual";
			darkRitual.displayName = "Dark Ritual";
			darkRitual.description = "Multiply your current DPS by 1.05 for 60 seconds.";
			spells.push(darkRitual);
			
			//######################################################
			//################### DUAL ELEMENTS ####################
			//######################################################
			
			//################### MID GAME BUFFS (SYNERGY) ###################
			var synergyIceFire:Spell = new Spell();
			synergyIceFire.id = "synergyIceFire";
			synergyIceFire.rank = 6;
			synergyIceFire.types = [ICE_RUNE_ID, FIRE_RUNE_ID];
			synergyIceFire.runeCombination = [4, 1, 2, 2, 1, 4, 8];
			synergyIceFire.spellRings = ["Ice1", "Fire2"];
			synergyIceFire.spellEffects = [];
			synergyIceFire.spellActivationFunction = function(){iceFire1Activation();};
			synergyIceFire.damageMultiplier = 0;
			synergyIceFire.costMultiplier = 0;
			synergyIceFire.manaCost = 50;
			synergyIceFire.msecsPerRune = (ICE_MSEC_PER_RUNE + FIRE_MSEC_PER_RUNE)/2;
			synergyIceFire.cooldownMsec = 300000;
			synergyIceFire.iconId = 384;
			synergyIceFire.spellPanelIcon = "BitmapHUD_synergyIceFire1";
			synergyIceFire.spellBarIcon = "BitmapHUD_SBsynergyIceFire";
			synergyIceFire.requiredCharge = getCharge("iceFire1");
			synergyIceFire.displayName = "Ice & Fire Synergy";
			synergyIceFire.description = "Ice and Fire Spells gain the benefit of all stats that affect either Ice or Fire Magic.";
			spells.push(synergyIceFire);
			
			var synergyIceLightning:Spell = new Spell();
			synergyIceLightning.id = "synergyIceLightning";
			synergyIceLightning.rank = 6;
			synergyIceLightning.types = [ICE_RUNE_ID, LIGHTNING_RUNE_ID];
			synergyIceLightning.runeCombination = [5, 2, 3, 3, 2, 5, 8];
			synergyIceLightning.spellRings = ["Ice1", "Lightning2"];
			synergyIceLightning.spellEffects = [];
			synergyIceLightning.spellActivationFunction = function(){iceLightning1Activation();};
			synergyIceLightning.damageMultiplier = 0;
			synergyIceLightning.costMultiplier = 0;
			synergyIceLightning.manaCost = 50;
			synergyIceLightning.msecsPerRune = (ICE_MSEC_PER_RUNE + LIGHTNING_MSEC_PER_RUNE)/2;
			synergyIceLightning.cooldownMsec = 300000;
			synergyIceLightning.iconId = 388;
			synergyIceLightning.spellPanelIcon = "BitmapHUD_synergyIceLightning1";
			synergyIceLightning.spellBarIcon = "BitmapHUD_SBsynergyIceLightning";
			synergyIceLightning.requiredCharge = getCharge("iceLightning1");
			synergyIceLightning.displayName = "Ice & Lightning Synergy";
			synergyIceLightning.description = "Ice and Lightning Spells gain the benefit of all stats that affect either Ice or Lightning Magic.";
			spells.push(synergyIceLightning);
			
			var synergyFireLightning:Spell = new Spell();
			synergyFireLightning.id = "synergyFireLightning";
			synergyFireLightning.rank = 6;
			synergyFireLightning.types = [FIRE_RUNE_ID, LIGHTNING_RUNE_ID];
			synergyFireLightning.runeCombination = [6, 3, 1, 1, 3, 6, 8];
			synergyFireLightning.spellRings = ["Fire1", "Lightning2"];
			synergyFireLightning.spellEffects = [];
			synergyFireLightning.spellActivationFunction = function(){fireLightning1Activation();};
			synergyFireLightning.damageMultiplier = 0;
			synergyFireLightning.costMultiplier = 0;
			synergyFireLightning.manaCost = 50;
			synergyFireLightning.msecsPerRune = (LIGHTNING_MSEC_PER_RUNE + FIRE_MSEC_PER_RUNE)/2;
			synergyFireLightning.cooldownMsec = 300000;
			synergyFireLightning.iconId = 386;
			synergyFireLightning.spellPanelIcon = "BitmapHUD_synergyLightningFire1";
			synergyFireLightning.spellBarIcon = "BitmapHUD_SBsynergyLightningFire";
			synergyFireLightning.requiredCharge = getCharge("fireLightning1");
			synergyFireLightning.displayName = "Fire & Lightning Synergy";
			synergyFireLightning.description = "Fire and Lightning Spells gain the benefit of all stats that affect either Fire or Lightning Magic.";
			spells.push(synergyFireLightning);
			
			//################## LATE GAME DAMAGERS ################
			var iceFireDamage:Spell = new Spell();
			iceFireDamage.id = "iceFireDamage";
			iceFireDamage.rank = 9;
			iceFireDamage.types = [ICE_RUNE_ID, FIRE_RUNE_ID];
			iceFireDamage.runeCombination = [4, 2, 1, 7, 4, 7, 2, 1, 4, 8];
			iceFireDamage.spellRings = ["Ice1", "Fire2", "Ice3"];
			iceFireDamage.spellEffects = ["Wizard_spellIce3","Wizard_spellFire3"];
			iceFireDamage.spellActivationFunction = function(){doSpellDamage(this);};
			iceFireDamage.damageMultiplier = (ICE_DAMAGE_MULTIPLIER + FIRE_DAMAGE_MULTIPLIER);
			iceFireDamage.costMultiplier = 0;
			iceFireDamage.manaCost = 100;
			iceFireDamage.msecsPerRune = (ICE_MSEC_PER_RUNE + FIRE_MSEC_PER_RUNE)/2;
			iceFireDamage.iconId = 390;
			iceFireDamage.cooldownMsec = 120000;
			iceFireDamage.spellPanelIcon = "BitmapHUD_dualIceFireDamageExtreme";
			iceFireDamage.spellBarIcon = "BitmapHUD_SBultIceFire";
			iceFireDamage.requiredCharge = getCharge("iceFire2");
			iceFireDamage.displayName = "Ice and Fire: Damage Spell";
			iceFireDamage.description = "Deal damage equivalent to Rank 9 Ice and Fire spells. Benefits from all Ice and Fire stats. Gains 50% damage per charge, up to 5 charges.";
			spells.push(iceFireDamage);
			
			var iceLightningDamage:Spell = new Spell();
			iceLightningDamage.id = "iceLightningDamage";
			iceLightningDamage.rank = 9;
			iceLightningDamage.types = [ICE_RUNE_ID, LIGHTNING_RUNE_ID];
			iceLightningDamage.runeCombination = [5, 3, 2, 7, 5, 7, 3, 2, 5, 8];
			iceLightningDamage.spellRings = ["Ice1", "Lightning2", "Ice3"];
			iceLightningDamage.spellEffects = ["Wizard_spellIce3","Wizard_spellLightning3"];
			iceLightningDamage.spellActivationFunction = function(){doSpellDamage(this);};
			iceLightningDamage.damageMultiplier = (ICE_DAMAGE_MULTIPLIER + LIGHTNING_DAMAGE_MULTIPLIER)/2;
			iceLightningDamage.costMultiplier = 0;
			iceLightningDamage.manaCost = 100;
			iceLightningDamage.msecsPerRune = (ICE_MSEC_PER_RUNE + LIGHTNING_MSEC_PER_RUNE);
			iceLightningDamage.iconId = 392;
			iceLightningDamage.cooldownMsec = 120000;
			iceLightningDamage.spellPanelIcon = "BitmapHUD_dualIceLightningDamageExtreme";
			iceLightningDamage.spellBarIcon = "BitmapHUD_SBultIceLightning";
			iceLightningDamage.requiredCharge = getCharge("iceLightning2");
			iceLightningDamage.displayName = "Ice and Lightning: Damage Spell";
			iceLightningDamage.description = "Deal damage equivalent to Rank 9 Ice and Lightning spells. Benefits from all Ice and Lightning stats. Gains 50% damage per charge, up to 5 charges.";
			spells.push(iceLightningDamage);
			
			var fireLightningDamage:Spell = new Spell();
			fireLightningDamage.id = "lightningFireDamage";
			fireLightningDamage.rank = 9;
			fireLightningDamage.types = [FIRE_RUNE_ID, LIGHTNING_RUNE_ID];
			fireLightningDamage.runeCombination = [6, 1, 3, 7, 6, 7, 1, 3, 6, 8];
			fireLightningDamage.spellRings = ["Fire1", "Lightning2", "Fire3"];
			fireLightningDamage.spellEffects = ["Wizard_spellFire3","Wizard_spellLightning3"];
			fireLightningDamage.spellActivationFunction = function(){doSpellDamage(this);};
			fireLightningDamage.damageMultiplier = (FIRE_DAMAGE_MULTIPLIER + LIGHTNING_DAMAGE_MULTIPLIER)/2;
			fireLightningDamage.costMultiplier = 0;
			fireLightningDamage.manaCost = 100;
			fireLightningDamage.msecsPerRune = (FIRE_MSEC_PER_RUNE + LIGHTNING_MSEC_PER_RUNE);
			fireLightningDamage.iconId = 394;
			fireLightningDamage.cooldownMsec = 120000;
			fireLightningDamage.spellPanelIcon = "BitmapHUD_dualLightningFireDamageExtreme";
			fireLightningDamage.spellBarIcon = "BitmapHUD_SBultLightningFire";
			fireLightningDamage.requiredCharge = getCharge("fireLightning2");
			fireLightningDamage.displayName = "Lightning and Fire: Damage Spell";
			fireLightningDamage.description = "Deal damage equivalent to Rank 9 Lightning and Fire spells. Benefits from all Lightning and Fire stats. Gains 50% damage per charge, up to 5 charges.";
			spells.push(fireLightningDamage);
			
			//################## LATE GAME SPECIAL SPELLS ################
			var iceLightningThundersnow:Spell = new Spell();
			iceLightningThundersnow.id = "iceLightningThundersnow";
			iceLightningThundersnow.rank = 9;
			iceLightningThundersnow.types = [ICE_RUNE_ID, LIGHTNING_RUNE_ID];
			iceLightningThundersnow.runeCombination = [5, 2, 2, 7, 5, 7, 3, 3, 5, 8];
			iceLightningThundersnow.spellRings = ["Ice1", "Lightning2", "Ice3"];
			iceLightningThundersnow.spellEffects = [];
			iceLightningThundersnow.spellActivationFunction = function(){thunderSnowActivation(this);};
			iceLightningThundersnow.damageMultiplier = 0;
			iceLightningThundersnow.costMultiplier = 0;
			iceLightningThundersnow.manaCost = 100;
			iceLightningThundersnow.msecsPerRune = (ICE_MSEC_PER_RUNE + LIGHTNING_MSEC_PER_RUNE)/2;
			iceLightningThundersnow.iconId = 398;
			iceLightningThundersnow.spellPanelIcon = "BitmapHUD_dualUltimaIceLightning"; //need new one
			iceLightningThundersnow.spellBarIcon = "BitmapHUD_SBdualIceFireDamageExtreme"; //need new one
			iceLightningThundersnow.requiredCharge = getCharge("iceLightning3");
			iceLightningThundersnow.cooldownMsec = 600000;
			iceLightningThundersnow.displayName = "Thundersnow";
			iceLightningThundersnow.description = "Summons a thunderstorm, which strikes the monster with ice or lightning whenever a spell is cast. Affects two spells per charge, up to 10 charges.";
			spells.push(iceLightningThundersnow);
			
			var fireLightningSolarStorm:Spell = new Spell();
			fireLightningSolarStorm.id = "fireLightningSolarStorm";
			fireLightningSolarStorm.rank = 9;
			fireLightningSolarStorm.types = [FIRE_RUNE_ID, LIGHTNING_RUNE_ID];
			fireLightningSolarStorm.runeCombination = [6, 3, 3, 7, 6, 7, 1, 1, 6, 8];
			fireLightningSolarStorm.spellRings = ["Fire1", "Lightning2", "Fire3"];
			fireLightningSolarStorm.spellEffects = [];
			fireLightningSolarStorm.spellActivationFunction = function(){solarStormActivation(this);};
			fireLightningSolarStorm.damageMultiplier = 0;
			fireLightningSolarStorm.costMultiplier = 0;
			fireLightningSolarStorm.manaCost = 100;
			fireLightningSolarStorm.msecsPerRune = (FIRE_MSEC_PER_RUNE + LIGHTNING_MSEC_PER_RUNE)/2;
			fireLightningSolarStorm.iconId = 394;
			fireLightningSolarStorm.spellPanelIcon = "BitmapHUD_dualUltimaLightningFire"; //need new one
			fireLightningSolarStorm.spellBarIcon = "BitmapHUD_SBdualIceLightningDamageExtreme"; //need new one
			fireLightningSolarStorm.requiredCharge = getCharge("fireLightning3");
			fireLightningSolarStorm.cooldownMsec = 1800000;
			fireLightningSolarStorm.displayName = "Solar Storm";
			fireLightningSolarStorm.description = "A solar flare manifests. All monsters lose 1% of their current health per charge, up to 10 charges. You lose all energy and gain 100 Hyperthermia.";
			spells.push(fireLightningSolarStorm);
			
			var iceFireCometShower:Spell = new Spell();
			iceFireCometShower.id = "iceFireCometShower";
			iceFireCometShower.rank = 9;
			iceFireCometShower.types = [ICE_RUNE_ID, FIRE_RUNE_ID];
			iceFireCometShower.runeCombination = [4, 1, 1, 7, 4, 7, 2, 2, 4, 8];
			iceFireCometShower.spellRings = ["Ice1", "Fire2", "Ice3"];
			iceFireCometShower.spellEffects = [];
			iceFireCometShower.spellActivationFunction = function(){cometShowerActivation(this);};
			iceFireCometShower.damageMultiplier = 0;
			iceFireCometShower.costMultiplier = 0;
			iceFireCometShower.manaCost = 100;
			iceFireCometShower.msecsPerRune = (ICE_MSEC_PER_RUNE + FIRE_MSEC_PER_RUNE)/2;
			iceFireCometShower.iconId = 396;
			iceFireCometShower.spellPanelIcon = "BitmapHUD_dualUltimaIceFire"; //need new one
			iceFireCometShower.spellBarIcon = "BitmapHUD_SBdualLightningFireDamageExtreme"; //need new one
			iceFireCometShower.requiredCharge = getCharge("iceFire3");
			iceFireCometShower.cooldownMsec = 900000;
			iceFireCometShower.displayName = "Comet Shower";
			iceFireCometShower.description = "Comets rain from the heavens, striking the monster at random intervals. Occurs three times per charge, up to 10 charges.";
			spells.push(iceFireCometShower);
		}
		
		public function deactivateAllSpells():void
		{
			for (var i:int = 0; i < spells.length; i++)
			{
				spells[i].isActive = false;
			}
		}
		
		public function getSpell(spellId:String):Spell
		{
			for (var i:int = 0; i < spells.length; i++)
			{
				if (spells[i].id == spellId)
				{
					return spells[i];
				}
			}
			return null;
		}
		
		public function getActiveSpells():Vector.<Spell>
		{
			var spellsToReturn:Vector.<Spell> = new Vector.<Spell>();
			for (var i:int = 0; i < spells.length; i++)
			{
				if (spells[i].isActive)
				{
					spellsToReturn.push(spells[i]);
				}
			}
			return spellsToReturn;
		}
		
		public function unlockSpellAndBelowRanks(spellType:String, id:int):void
		{
			for (var i:int = 1; i <= id; i++)
			{
				if (!getSpell(spellType+String(i)).isActive)
				{
					getSpell(spellType+String(i)).isActive = true;
					hasUnseenSpell = true;
				}
			}
			if (!CH2.currentCharacter.getStaticSkill("Igni").isActive)
			{
				unlockRunes();
			}
			
		}
		
		public function unlockSpell(spellName:String):void
		{
			if (!getSpell(spellName).isActive)
			{
				getSpell(spellName).isActive = true;
				hasUnseenSpell = true;
			}
			if (!CH2.currentCharacter.getStaticSkill("Igni").isActive)
			{
				unlockRunes();
			}
		}
		
		//#####################################################################
		//############################## CHARGES ##############################
		//#####################################################################	
		
		public function setupCharges():void
		{
			charges = new Vector.<Charge>();
			
			//(Mid) Stat Buffs
			var iceLightning1:Charge = new Charge();
			iceLightning1.id = "iceLightning1";
			iceLightning1.spellTypeCombination = [ICE_RUNE_ID, LIGHTNING_RUNE_ID, ICE_RUNE_ID];
			iceLightning1.displayName = "Ice Lightning Charge";
			iceLightning1.description = "";
			iceLightning1.iconId = 374;
			charges.push(iceLightning1);
			
			var fireLightning1:Charge = new Charge();
			fireLightning1.id = "fireLightning1";
			fireLightning1.spellTypeCombination = [LIGHTNING_RUNE_ID, FIRE_RUNE_ID, LIGHTNING_RUNE_ID];
			fireLightning1.displayName = "Fire Lightning Charge";
			fireLightning1.description = "";
			fireLightning1.iconId = 373;
			charges.push(fireLightning1);
			
			var iceFire1:Charge = new Charge();
			iceFire1.id = "iceFire1";
			iceFire1.spellTypeCombination = [FIRE_RUNE_ID, ICE_RUNE_ID, FIRE_RUNE_ID];
			iceFire1.displayName = "Ice Fire Charge";
			iceFire1.description = "";
			iceFire1.iconId = 372;
			charges.push(iceFire1);
			
			//(Late) Damage Buffs
			var iceLightning2:Charge = new Charge();
			iceLightning2.id = "iceLightning2";
			iceLightning2.spellTypeCombination = [LIGHTNING_RUNE_ID, ICE_RUNE_ID, LIGHTNING_RUNE_ID];
			iceLightning2.displayName = "Ice Lightning Charge 2";
			iceLightning2.description = "";
			iceLightning2.iconId = 374;
			charges.push(iceLightning2);
			
			var fireLightning2:Charge = new Charge();
			fireLightning2.id = "fireLightning2";
			fireLightning2.spellTypeCombination = [FIRE_RUNE_ID, LIGHTNING_RUNE_ID, FIRE_RUNE_ID];
			fireLightning2.displayName = "Fire Lightning Charge 2";
			fireLightning2.description = "";
			fireLightning2.iconId = 373;
			charges.push(fireLightning2);
			
			var iceFire2:Charge = new Charge();
			iceFire2.id = "iceFire2";
			iceFire2.spellTypeCombination = [ICE_RUNE_ID, FIRE_RUNE_ID, ICE_RUNE_ID];
			iceFire2.displayName = "Ice Fire Charge 2";
			iceFire2.description = "";
			iceFire2.iconId = 372;
			charges.push(iceFire2);
			
			//(Late) Buffs
			var iceLightning3:Charge = new Charge();
			iceLightning3.id = "iceLightning3";
			iceLightning3.spellTypeCombination = [ICE_RUNE_ID, LIGHTNING_RUNE_ID, LIGHTNING_RUNE_ID];
			iceLightning3.displayName = "Ice Lightning Charge 3";
			iceLightning3.description = "";
			iceLightning3.iconId = 374;
			charges.push(iceLightning3);
			
			var fireLightning3:Charge = new Charge();
			fireLightning3.id = "fireLightning3";
			fireLightning3.spellTypeCombination = [LIGHTNING_RUNE_ID, FIRE_RUNE_ID, FIRE_RUNE_ID];
			fireLightning3.displayName = "Fire Lightning Charge 3";
			fireLightning3.description = "";
			fireLightning3.iconId = 373;
			charges.push(fireLightning3);
			
			var iceFire3:Charge = new Charge();
			iceFire3.id = "iceFire3";
			iceFire3.spellTypeCombination = [FIRE_RUNE_ID, ICE_RUNE_ID, ICE_RUNE_ID];
			iceFire3.displayName = "Ice Fire Charge 3";
			iceFire3.description = "";
			iceFire3.iconId = 372;
			charges.push(iceFire3);
		}
		
		public function getCharge(chargeId:String):Charge
		{
			for (var i:int = 0; i < charges.length; i++)
			{
				if (charges[i].id == chargeId)
				{
					return charges[i];
				}
			}
			return null;
		}
		
		public function getActiveCharges():Vector.<Charge>
		{
			var activeCharges:Vector.<Charge> = new Vector.<Charge>();
			var activeSpells:Vector.<Spell> = getActiveSpells();
			for (var i:int = 0; i < activeSpells.length; i++)
			{
				if (activeSpells[i].requiredCharge && activeCharges.indexOf(activeSpells[i].requiredCharge) == -1)
				{
					activeCharges.push(activeSpells[i].requiredCharge);
				}
			}
			return activeCharges;
		}
		
		//######################################################################
		//############################## SPELLBAR ##############################
		//######################################################################
		
		public function getSpellsForBar():Vector.<Spell>
		{
			var spellsToReturn:Vector.<Spell> = new Vector.<Spell>();
			for (var i:int = 0; i < spells.length; i++)
			{
				if (spells[i].isActive && spells[i].cooldownMsec > 0)
				{
					spellsToReturn.push(spells[i]);
				}
			}
			return spellsToReturn;
		}
		
		//#################################################################################
		//############################## UTILITY FOR CONSOLE ##############################
		//#################################################################################
		
		public function unlockAllSpells():void
		{
			for (var i:int = 0; i < spells.length; i++)
			{
				spells[i].isActive = true;
			}
		}
		
		public function addAllCharges():void
		{
			for (var i:int = 0; i < charges.length; i++)
			{
				addCharge(charges[i]);
			}
		}
	}

}

//############################################################################
//############################## WIZARD CLASSES ##############################
//############################################################################

//############################################################################
//################################## MODELS ##################################
//############################################################################
class Rune
{
	public static const RUNE_NAME_TO_ID:Object = {
		"Igni": 1,
		"Frigo": 2,
		"Lor Vas": 3,
		"Kras": 4,
		"Ohm": 5,
		"Yrdei": 6,
		"Helio": 7,
		"Exe": 8
	};
	public static const RUNE_ID_TO_NAME:Array = ["", "Igni", "Frigo", "Lor Vas", "Kras", "Ohm", "Yrdei", "Helio", "Exe"]; //reference index
	
	public function Rune()
	{
		
	}
	
	public static function getKeyBoundForRuneByName(runeName:String):String
	{
		return getKeyBoundForRuneByName(RUNE_NAME_TO_ID[runeName]);
	}
	
	public static function getKeyBoundForRuneById(runeId:int):String
	{
		for (var i:int = 0; i < CH2.currentCharacter.activeSkills.length; i++)
		{
			if (CH2.currentCharacter.activeSkills[i].uid == RUNE_ID_TO_NAME[runeId])
			{
				return CH2.user.keyBindings.getHotkeyName(CH2.currentCharacter.activeSkills[i].slot);
			}
		}
		return "Unassigned";
	}
	
	public static function formatArrayOfRuneIds(runeIdArray:Array):String
	{
		var result:String = "";
		for (var i:int = 0; i < runeIdArray.length; i++)
		{
			result += RUNE_ID_TO_NAME[runeIdArray[i]] + "(" + getKeyBoundForRuneById(runeIdArray[i]).replace(" ", "") + ")";
			if (i < runeIdArray.length - 1)
			{
				result += ", ";
			}
		}
		return result;
	}
}


import flash.display.SimpleButton;
import heroclickerlib.CpuImage;
import heroclickerlib.managers.Trace;
import models.Skill;
import com.playsaurus.numbers.BigNumber;
import com.playsaurus.utils.TimeFormatter;
import com.playsaurus.utils.StringFormatter;
import ui.elements.DragDropSprite;
class Spell
{
	public var id:String;
	public var rank:int;
	public var types:Array = [];
	public var runeCombination:Array;
	public var spellRings:Array;
	public var spellEffects:Array;
	public var isActive:Boolean;
	public var spellActivationFunction:Function;
	public var damageMultiplier:Number;
	public var costMultiplier:Number;
	public var manaCost:Number = 0;
	public var msecsPerRune:int;
	public var cooldownMsec:int = 0;
	public var iconId:int = 1;
	public var spellPanelIcon:String = "";
	public var spellBarIcon:String;
	public var displayName:String = "";
	public var description:String = "";
	public var requiredCharge:Charge;
	public var tier:int;
	public var spawnSound:String = "";
	public var impactSound:String = "";
	
	public function get damage():BigNumber
	{
		var spellDamageMultiplier:Number = 25 * Math.pow(2, this.rank - 1) * this.damageMultiplier;
		return CH2.currentCharacter.damage.multiplyN(spellDamageMultiplier);
	}
	
	public function get energyCost():int
	{
		return int(5 * (this.runeCombination.length) * this.costMultiplier);
	}
	
	public function get costsMana():Boolean
	{
		return manaCost > 0;
	}
	
	public function get spellCastDurationMsec():int
	{
		return Math.floor(msecsPerRune * runeCombination.length);
	}
	
	public function get extendedTooltip():Object
	{
		var newDescription = "";
		if (this.description)
		{
			newDescription = this.description + "\n";
		}
		
		if (this.damage.gtN(0))
		{
			newDescription += "Damage: " + CH2.game.formattedNumber(this.damage) + "\n";
		}
		
		if (this.msecsPerRune > 0)
		{
			newDescription += "Cast Duration: " + (spellCastDurationMsec/1000) + "sec\n";
		}
		
		if (this.requiredCharge != null)
		{
			newDescription += "Required Charge: " + this.requiredCharge.displayName +  "\n  " + this.requiredCharge.tooltip.body + "\n";
		}
		
		var tierDescription:String = "";
		if (this.tier)
		{
			tierDescription = " (Tier " + this.tier + ")";
		}
		
		return {"header": this.displayName + tierDescription, "body": newDescription + "Incantation: " + Rune.formatArrayOfRuneIds(runeCombination) + "\n\n" + spellCosts()};
		
	}
	
	public function get tooltip():Object
	{
		var newDescription = "";
		if (description)
		{
			newDescription = "\n" + description;
		}
		
		if  (this.damage.gtN(0))
		{
			newDescription += "\nDamage: " + CH2.game.formattedNumber(this.damage);
		}
		
		var tierDescription:String = "";
		if (this.tier)
		{
			tierDescription = " (Tier " + this.tier + ")";
		}
		
		return {"header": this.displayName + tierDescription, "body":  "Incantation: " + Rune.formatArrayOfRuneIds(runeCombination) + newDescription + "\n\n" + spellCosts()};
		
	}
	
	public function spellCosts():String
	{
		var spellCosts:String = "";
		if (this.costsMana)
		{
			spellCosts += "Mana: " + this.manaCost + "\n";
			spellCosts = StringFormatter.colorize(spellCosts, "#00A6CE");
		}
		if (this.costMultiplier > 0)
		{
			spellCosts += "Energy: " + this.energyCost + "\n";
			spellCosts = StringFormatter.colorize(spellCosts, "#ffff00");
		}
		if (this.cooldownMsec > 0)
		{
			spellCosts += "Cooldown: " + TimeFormatter.formatTimeDescriptive(Math.floor(this.cooldownMsec / 1000));
		}
		return spellCosts;
	}
	
	public function Spell() 
	{
		
	}
}

class Charge
{
	public var id:String;
	public var spellTypeCombination:Array;
	public var iconId:int = 1;
	public var displayName:String = "";
	public var description:String = "";
	
	public function get tooltip():Object
	{
		return {"header": displayName, "body": description+"\Spell Type Pattern: "+Rune.formatArrayOfRuneIds(spellTypeCombination)};
	}
	
	public function Charge() 
	{
		
	}
}

//############################################################################
//#################################### UI ####################################
//############################################################################

import flash.display.MovieClip;
class SpellBar
{
	public static const SLOTS_ON_SPELL_BAR:int = 8;
	public var display:MovieClip;
	public var spellSlots:Vector.<SpellSlotUI>;
	public var previousActiveSpells:int = 0;
	
	public function SpellBar() 
	{
		super();
		display = new MovieClip();
		setupSlots();
	}
	
	private function setupSlots():void
	{
		spellSlots = new Vector.<SpellSlotUI>();
		
		var spellSlot:SpellSlotUI;
		for (var i:int = 0; i < SLOTS_ON_SPELL_BAR; i++)
		{
			spellSlot = new SpellSlotUI();
			spellSlot.emptySlot.x = i*55 + 23;
			spellSlot.emptySlot.y = 0;
			display.addChild(spellSlot.emptySlot);
			spellSlots.push(spellSlot);
		}
	}
	
	public function refresh(dt:Number, barSpells:Vector.<Spell>):void
	{
		if (previousActiveSpells != barSpells.length)
		{
			previousActiveSpells = barSpells.length;
			
			barSpells.sort(sortSpells);
			
			for (var i:int = 0; i < SLOTS_ON_SPELL_BAR; i++)
			{
				spellSlots[i].spell = null;
			}
			
			for (var i:int = 0; i < spellSlots.length; i++)
			{
				if (barSpells.length > i)
				{
					spellSlots[i].spell = barSpells[i];
					spellSlots[i].setSpellBarIcon();
				}
			}
		}
		
		for (var i:int = 0; i < SLOTS_ON_SPELL_BAR; i++)
		{
			spellSlots[i].updateDisplay();
		}
	}
	
	public function sortSpells(spell1:Spell, spell2:Spell):int
	{
		var orderOfSpells:Array = ["synergyIceFire", "synergyIceLightning", "synergyLightningFire", 
		"iceFireDamage", "iceLightningDamage", "lightningFireDamage", 
		"iceLightningThundersnow", "fireLightningSolarStorm", "iceFireCometShower"];
		
		if (orderOfSpells.indexOf(spell1.id) > orderOfSpells.indexOf(spell2.id))
		{
			return 1;
		}
		else
		{
			return -1;
		}
	}
}

import swc.mainui.SkillSlotDisplay;
import heroclickerlib.CpuMovieClip;
import flash.events.MouseEvent;
import heroclickerlib.managers.MouseEnabler;
import flash.text.TextField;
import heroclickerlib.managers.TooltipManager;
import flash.ui.Mouse;
import com.adobe.utils.NumberFormatter;
import heroclickerlib.CH2;
import models.Buff;
import heroclickerlib.managers.CH2AssetManager;
class SpellSlotUI
{
	private static const FRAME_COUNT:Number = 240.00;
	
	public var spell:Spell;
	public var buff:Buff;
	public var spellBuffIcon:CpuMovieClip;
	public var display:CpuImage;
	public var emptySlot:CpuImage;
	public var cooldownShadow:CpuMovieClip;
	public var used:Boolean = false;
	public var displayAdded:Boolean = false;
	
	public function SpellSlotUI() 
	{
		display = CH2AssetManager.instance.getCpuImage("BitmapHUD_emptySpellCircleSlot");
		emptySlot = CH2AssetManager.instance.getCpuImage("BitmapHUD_emptySpellCircleSlot");
		cooldownShadow = CH2AssetManager.instance.getCpuMovieClip("BitmapHUD_SBcountdownOverlay", 30);
		cooldownShadow.alpha = .5;
		resetSlot();
	}
	
	public function resetSlot():void
	{
		cooldownShadow.stop();
		cooldownShadow.visible = false;
		spellBuffIcon = null;
	}
	
	public function getSpellIcon():CpuMovieClip
	{
		if (!spellBuffIcon)
		{
			var icon:CpuMovieClip = CH2AssetManager.instance.getUpgradeIcons();
			icon.gotoAndStop( spell.iconId );
			spellBuffIcon = icon;
		}
		return spellBuffIcon;
	}
	
	public function setSpellBarIcon():void
	{
		display = CH2AssetManager.instance.getCpuImage(spell.spellBarIcon);
		
		display.addEventListener( MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true );
		display.addEventListener( MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true );
		
		MouseEnabler.instance.enable(display);
	}
	
	public function updateDisplay():void
	{
		if (spell)
		{
			if (CH2.currentCharacter.buffs.hasBuffByName(spell.id + " Cooldown"))
			{
				buff = CH2.currentCharacter.buffs.getBuff(spell.id + " Cooldown");
				var precentLeft:int = Math.floor(buff.timeLeft / buff.duration);
				cooldownShadow.gotoAndStop(Math.min(100, 1 + precentLeft));
				cooldownShadow.visible = true;
			}
			else
			{
				buff = null;
				cooldownShadow.visible = false;
			}
			
			var icon:CpuMovieClip = getSpellIcon();
			if (!emptySlot.contains(display))
			{
				emptySlot.removeChildren();
				emptySlot.addChild(display);
				emptySlot.addChild(cooldownShadow);
			}
			display.visible = true;
		}
		else
		{
			resetSlot();
			emptySlot.removeChildren();
			cooldownShadow.visible = false;
			buff = null;
		}
	}
	
	public function onMouseOver(e:MouseEvent):void
	{
		if (spell)
		{
			var tooltip:Object = spell.extendedTooltip;
			TooltipManager.instance.showBuffTooltip(tooltip.header, tooltip.body, this.display);
		}
		Mouse.cursor = "button";
	}
	
	public function onMouseOut(e:MouseEvent):void
	{
		TooltipManager.instance.hide();
		Mouse.cursor = "auto";
	}
}

import ui.elements.SubPanel;
import swc.HUD.SkillsPanelDisplay2;
import heroclickerlib.scrollers.SimpleScroller;
import ui.SkillPanelEntryUI;
import flash.display.Sprite;

class SpellsPanel extends SubPanel
{
	private static const SPACE_BETWEEN_ENTRIES:int = 110;
	
	private var spellEntries:Vector.<SpellPanelEntryUI>;
	private var panelOverlay:SkillsPanelDisplay2;
	private var entryHolder:Sprite;
	private var scrollBar:SimpleScroller;
	
	public function SpellsPanel() 
	{
		spellEntries = new Vector.<SpellPanelEntryUI>();
		setDisplay(new MovieClip());
		panelOverlay = new SkillsPanelDisplay2();
		panelOverlay.mouseChildren = false;
		panelOverlay.mouseEnabled = false;
		display.addChild(panelOverlay);
		
		scrollBar = new SimpleScroller( CH2.game.stage );
		scrollBar.offsetScrollY = 0;
		scrollBar.initWithOwnSetup( panelOverlay.entryHolder, panelOverlay.panelMask, panelOverlay.scrollbar );
		scrollBar.mouseDownSpeed = 10;
		scrollBar.registerAreaBGClip( display );
		panelOverlay.entryHolder.mask = panelOverlay.panelMask;
	}
	
	override public function activate():void
	{
		super.activate();
		
		ModLoader.instance.getModWithName("Wizard")["hasUnseenSpell"] = false;
	}
	
	override public function dispose():void
	{
		super.dispose();
		
		scrollBar.dispose();
	}
	
	override protected function setup():void
	{
		super.setup();
	}
	
	override public function update(dt:Number):void
	{
		var hasUpdated:Boolean = false;
		
		var activeSpells:Vector.<Spell> = ModLoader.instance.getModWithName("Wizard")["getActiveSpells"]();
		if (spellEntries.length > activeSpells.length)
		{
			for (var i:int = 0; i < spellEntries.length; i++)
			{
				spellEntries[i].parent.removeChild(spellEntries[i]);
			}
			spellEntries = new Vector.<SpellPanelEntryUI>();
		}
		
		for (var i:int = 0; i < activeSpells.length; i++)
		{
			if (spellEntries.length <= i)
			{
				var spellPanelEntry:SpellPanelEntryUI = new SpellPanelEntryUI(i, this);
				spellPanelEntry.x = 0;
				spellPanelEntry.y = (i * SPACE_BETWEEN_ENTRIES);
				spellEntries.push(spellPanelEntry);
				panelOverlay.entryHolder.addChild(spellPanelEntry);
				hasUpdated = true;
			}
			spellEntries[i].index = i;
			spellEntries[i].update(dt);
		}
		
		if ( hasUpdated )
		{
			scrollBar.updateScrollableRange();
		}
		
		panelOverlay.scrollbar.visible = panelOverlay.entryHolder.height > panelOverlay.panelMask.height;
	}
}

import com.doogog.utils.MiscUtils;
import flash.display.Sprite;
import flash.text.TextField;
import heroclickerlib.CpuMovieClip;
import heroclickerlib.CH2;
import heroclickerlib.managers.CH2AssetManager;
import swc.HUD.skillPanelEntry;
class SpellPanelEntryUI extends Sprite
{
	public var index:int;
	public var spellPanel:SpellsPanel;
	public var iconHolder:Sprite;
	public var icon:CpuImage;
	
	private var _skillPanelEntry:skillPanelEntry;
	private var backgroundDisplay:Sprite;
	
	public function get spell():Spell
	{
		var activeSpells:Vector.<Spell> = ModLoader.instance.getModWithName("Wizard")["getActiveSpells"]();
		if (index < activeSpells.length)
		{
			return activeSpells[index];
		}
		return null;
	}
	
	public function SpellPanelEntryUI(index:int, spellPanel:SpellsPanel) 
	{
		super();
		
		this.index = index;
		this.spellPanel = spellPanel;
		
		_skillPanelEntry = new skillPanelEntry();
		_skillPanelEntry.title.htmlText = spell.tooltip.header;
		_skillPanelEntry.description.htmlText = spell.tooltip.body;
		_skillPanelEntry.x = 0;
		_skillPanelEntry.emptySlot.visible = false;
		this.addChild(_skillPanelEntry);
		
		iconHolder = new Sprite();
		iconHolder.x = 471;
		iconHolder.y = 50;
		this.addChild(iconHolder);
		
		icon = getSpellIcon(spell.spellPanelIcon);
		iconHolder.addChildAt(icon, 0);
		
		MouseEnabler.instance.enable(_skillPanelEntry);
		_skillPanelEntry.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 0, true);
		_skillPanelEntry.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 0, true);
	}
	
	public function onMouseOver(e:MouseEvent):void
	{
		if (spell)
		{
			var tooltip:Object = spell.extendedTooltip;
			TooltipManager.instance.showTooltip(tooltip.header, tooltip.body, this.iconHolder);
		}
		Mouse.cursor = "button";
	}
	
	public function onMouseOut(e:MouseEvent):void
	{
		TooltipManager.instance.hide();
		Mouse.cursor = "auto";
	}
	
	public function update(dt:Number):void
	{
		if (MiscUtils.requiresUpdate(300, dt))
		{
			_skillPanelEntry.description.htmlText = spell.tooltip.body;
			_skillPanelEntry.title.htmlText = spell.tooltip.header;
			iconHolder.removeChild(icon);
			icon = getSpellIcon(spell.spellPanelIcon);
			iconHolder.addChild(icon);
		}
	}
	
	private function getSpellIcon(iconId:String):CpuImage
	{
		var icon:CpuImage = CH2AssetManager.instance.getCpuImage(iconId);
		icon.scaleX = 0.5;
		icon.scaleY = 0.5;
		icon.x = 10;
		icon.y = -5;
		return icon;
	}
	
}

import com.doogog.utils.CreationUtils;
import heroclickerlib.managers.MouseEnabler;
import swc.HUD.WizardAutomatorPanelDisplay;

class WizardAutomatorPanel extends SubPanel
{
	public var panelDisplay:WizardAutomatorPanelDisplay = new WizardAutomatorPanelDisplay();
	public var currentRecording:Recording;
	public var currentTimeline:RecordingTimeline = new RecordingTimeline();
	
	public function WizardAutomatorPanel()
	{
		super();
	}
	
	override public function activate():void
	{
		setDisplay(panelDisplay);
		 
		panelDisplay.playButton.gotoAndStop(1);
		panelDisplay.stopButton.gotoAndStop(1);
		panelDisplay.recordButton.gotoAndStop(1);
		panelDisplay.deleteButton.gotoAndStop(1);
		
		panelDisplay.playButton.icon.gotoAndStop(1);
		panelDisplay.stopButton.icon.gotoAndStop(2);
		panelDisplay.recordButton.icon.gotoAndStop(3);
		panelDisplay.deleteButton.icon.gotoAndStop(4);
		
		panelDisplay.playButton.addEventListener(MouseEvent.MOUSE_OVER, onPanelButtonOver, false, 0, true);
		panelDisplay.playButton.addEventListener(MouseEvent.MOUSE_OUT, onPanelButtonOut, false, 0, true);
		panelDisplay.playButton.addEventListener(MouseEvent.CLICK, onPlayClick, false, 0, true);
		MouseEnabler.instance.enable(panelDisplay.playButton);
		
		panelDisplay.stopButton.addEventListener(MouseEvent.MOUSE_OVER, onPanelButtonOver, false, 0, true);
		panelDisplay.stopButton.addEventListener(MouseEvent.MOUSE_OUT, onPanelButtonOut, false, 0, true);
		panelDisplay.stopButton.addEventListener(MouseEvent.CLICK, onStopClick, false, 0, true);
		MouseEnabler.instance.enable(panelDisplay.stopButton);
		
		panelDisplay.recordButton.addEventListener(MouseEvent.MOUSE_OVER, onPanelButtonOver, false, 0, true);
		panelDisplay.recordButton.addEventListener(MouseEvent.MOUSE_OUT, onPanelButtonOut, false, 0, true);
		panelDisplay.recordButton.addEventListener(MouseEvent.CLICK, onRecordClick, false, 0, true);
		MouseEnabler.instance.enable(panelDisplay.recordButton);
		
		panelDisplay.deleteButton.addEventListener(MouseEvent.MOUSE_OVER, onPanelButtonOver, false, 0, true);
		panelDisplay.deleteButton.addEventListener(MouseEvent.MOUSE_OUT, onPanelButtonOut, false, 0, true);
		panelDisplay.deleteButton.addEventListener(MouseEvent.CLICK, onDeleteClick, false, 0, true);
		MouseEnabler.instance.enable(panelDisplay.deleteButton);
		
		panelDisplay.recordingsHolder.mask = panelDisplay.recordingMask;
		
		panelDisplay.timelineHolder.addChild(currentTimeline);
		
		var totalRecordings:int = ModLoader.instance.getModWithName("Wizard")["recordings"].length;
		if (totalRecordings > 0)
		{
			currentRecording = ModLoader.instance.getModWithName("Wizard")["recordings"][0];
		}
		
		currentTimeline.recording = currentRecording;
	}
	
	private function onPlayClick(e:MouseEvent):void
	{
		if (currentRecording == null || currentRecording.id == 0) return;
		
		var button:MovieClip = e.currentTarget;
		if (currentRecording.isRecording)
		{
			currentRecording.endRecording();
			panelDisplay.recordButton.gotoAndStop(1);
		}
		
		if (!currentRecording.isPlaying)
		{
			currentRecording.startPlayback();
			if (currentRecording.isPlaying)
			{
				button.gotoAndStop(3);
			}
		}
		else
		{
			currentRecording.endPlayback();
			button.gotoAndStop(2);
		}
	}
	
	private function onStopClick(e:MouseEvent):void
	{
		if (currentRecording == null || currentRecording.id == 0) return;
		
		if (currentRecording.isRecording)
		{
			currentRecording.endRecording();
			panelDisplay.recordButton.gotoAndStop(1);
		}
		
		if (currentRecording.isPlaying)
		{
			currentRecording.endPlayback();
			panelDisplay.playButton.gotoAndStop(1);
		}
	}
	
	private function onRecordClick(e:MouseEvent):void
	{
		var button:MovieClip = e.currentTarget;
		if (currentRecording.isPlaying)
		{
			currentRecording.endPlayback();
			panelDisplay.playButton.gotoAndStop(1);
		}
		
		if (!currentRecording.isRecording)
		{
			currentTimeline.clear();
			currentRecording.startRecording();
			button.gotoAndStop(3);
		}
		else
		{
			currentRecording.endRecording();
			button.gotoAndStop(2);
		}
	}
	
	private function onDeleteClick(e:MouseEvent):void
	{
		currentRecording.clear();
		currentTimeline.clear();
		
		panelDisplay.playButton.gotoAndStop(1);
		panelDisplay.stopButton.gotoAndStop(1);
		panelDisplay.recordButton.gotoAndStop(1);
		panelDisplay.deleteButton.gotoAndStop(2);
	}
	
	private function onPanelButtonOver(e:MouseEvent):void
	{
		var button:MovieClip = e.currentTarget;
		if (button.currentFrame != 3)
		{
			button.gotoAndStop(2);
		}
		Mouse.cursor = "button";
	}
	
	private function onPanelButtonOut(e:MouseEvent):void
	{
		var button:MovieClip = e.currentTarget;
		if (button.currentFrame != 3)
		{
			button.gotoAndStop(1);
		}
		Mouse.cursor = "auto";
	}
	
	override public function deactivate(refresh:Boolean=false):void
	{
		dispose();
		
		panelDisplay.playButton.removeEventListener(MouseEvent.MOUSE_OVER, onPanelButtonOver);
		panelDisplay.playButton.removeEventListener(MouseEvent.MOUSE_OUT, onPanelButtonOut);
		panelDisplay.playButton.removeEventListener(MouseEvent.CLICK, onPlayClick);
		MouseEnabler.instance.disable(panelDisplay.playButton);
		
		panelDisplay.stopButton.removeEventListener(MouseEvent.MOUSE_OVER, onPanelButtonOver);
		panelDisplay.stopButton.removeEventListener(MouseEvent.MOUSE_OUT, onPanelButtonOut);
		panelDisplay.stopButton.removeEventListener(MouseEvent.CLICK, onStopClick);
		MouseEnabler.instance.disable(panelDisplay.stopButton);
		
		panelDisplay.recordButton.removeEventListener(MouseEvent.MOUSE_OVER, onPanelButtonOver);
		panelDisplay.recordButton.removeEventListener(MouseEvent.MOUSE_OUT, onPanelButtonOut);
		panelDisplay.recordButton.removeEventListener(MouseEvent.CLICK, onRecordClick);
		MouseEnabler.instance.disable(panelDisplay.recordButton);
		
		panelDisplay.deleteButton.removeEventListener(MouseEvent.MOUSE_OVER, onPanelButtonOver);
		panelDisplay.deleteButton.removeEventListener(MouseEvent.MOUSE_OUT, onPanelButtonOut);
		panelDisplay.deleteButton.removeEventListener(MouseEvent.CLICK, onDeleteClick);
		MouseEnabler.instance.disable(panelDisplay.deleteButton);
		
		panelDisplay.timelineHolder.removeChild(currentTimeline);
	}
	
	override public function update(dt:Number):void
	{
		if (currentRecording)
		{
			currentTimeline.update(dt);
		}
	}
	
	override protected function setup():void
	{
		super.setup();
	}
	
	override public function dispose():void 
	{
		super.dispose();
	}
}

import heroclickerlib.managers.TransientEffects;
import com.playsaurus.model.Model;
import models.AttackData;
class Recording extends Model
{
	public var id:int = 0;
	public var isPlaying:Boolean = false;
	public var isRecording:Boolean = false;
	public var playbackStartTime:Number = 0;
	public var recordingStartTime:Number = 0;
	public var playbackDtRemaining:Number = 0;
	public var playbackIndex:int = 0;
	public var recordedActions:Array = [];
	public var recordedHaste:Number = 1;
	
	public function get getSpeed():Number
	{
		return CH2.currentCharacter.hasteRating / recordedHaste;
	}
	
	public function Recording()
	{
		registerDynamicNumber("id");
		registerDynamicNumber("playbackStartTime");
		registerDynamicNumber("recordingStartTime");
		registerDynamicNumber("playbackDtRemaining");
		registerDynamicNumber("playbackIndex");
		registerDynamicObject("recordedActions");
		registerDynamicNumber("recordedHaste");
	}
	
	public function clear():void
	{
		isPlaying = false;
		isRecording = false;
		playbackStartTime = 0;
		recordingStartTime = 0;
		playbackDtRemaining = 0;
		playbackIndex = 0;
		recordedActions = [];
	}
	
	public function playbackPercentComplete():Number
	{
		if ((playbackDtRemaining > 0 || playbackIndex > 0) && !isRecording)
		{
			if (recordedActions == null || playbackIndex >= recordedActions.length) return 1;
			
			var currentTime:int = recordedActions[playbackIndex]["dt"];
			currentTime += playbackDtRemaining;
			var totalTime:int = recordedActions[recordedActions.length - 1]["dt"];
			return currentTime / totalTime;
		}
		else
		{
			return 0;
		}
	}
	
	public function logRecordedAction(actionId:String):void
	{
		var msecsSinceRecordingStarted:Number = CH2.user.totalMsecsPlayed - recordingStartTime;
		//later push to seek location
		recordedActions.push({"skillUid": actionId, "dt": msecsSinceRecordingStarted});
	}
	
	public function pause():void
	{
		
	}
	
	public function seek(msec:int):void
	{
		
	}
	
	public function update(dt:Number):void
	{
		if (isPlaying && recordedActions.length > 0)
		{
			playbackDtRemaining += (dt * getSpeed);
			while (playbackDtRemaining > 0 && dt > 0)
			{
				var previousIndex:int = playbackIndex;
				var candidateIndex:int = (playbackIndex + 1) % recordedActions.length;
				
				var dtDifference:int = recordedActions[candidateIndex]["dt"] - recordedActions[previousIndex]["dt"];
				if (dtDifference < 0)
				{
					dtDifference = recordedActions[candidateIndex]["dt"];
				}
				if (dtDifference <= playbackDtRemaining)
				{
					if (recordedActions[candidateIndex]["skillUid"] != -1 && recordedActions[candidateIndex]["skillUid"] != "999" && 
					CH2.currentCharacter.canUseSkill(CH2.currentCharacter.getSkill(recordedActions[candidateIndex]["skillUid"])) && 
					ModLoader.instance.getModWithName("Wizard")["canCastSpell"]())
					{
						CH2.currentCharacter.getSkill(recordedActions[candidateIndex]["skillUid"]).useSkill();
					}
					else if (recordedActions[candidateIndex]["skillUid"] == "999")
					{
						CH2.currentCharacter.clickAttack();
					}
					playbackDtRemaining -= dtDifference;
					playbackIndex = candidateIndex;
				}
				else
				{
					break;
				}
			}
		}
	}
	
	public function startRecording():void
	{
		if (this.id == 0)
		{
			this.id = MiscUtils.cachedTime;
		}
		if (isPlaying)
		{
			TransientEffects.instance.showFadingText("You must stop playback to start recording.", 5000, 1000);
			return;
		}
		recordedHaste = CH2.currentCharacter.hasteRating;
		recordingStartTime = CH2.user.totalMsecsPlayed;
		isRecording = true;
		recordedActions = [];
		recordedActions.push({"skillUid": "-1", "dt": 0}); //this ensures we start processing on index 1
		
		if (!CH2.currentCharacter.buffs.hasBuff("Recording"))
		{
			var buff:Buff = new Buff();
			buff.name = "Recording";
			buff.iconId = 359;
			buff.isUntimedBuff = true;
			buff.unhastened = true;
			buff.tooltipFunction = function() {
				return {
					"header": "Recording",
					"body": ""
				};
			}
			CH2.currentCharacter.buffs.addBuff(buff);
		}
	}
	
	public function endRecording():void
	{
		isRecording = false;
		var msecsSinceRecordingStarted:Number = CH2.user.totalMsecsPlayed - recordingStartTime;
		recordedActions.push({"skillUid": "-1", "dt": msecsSinceRecordingStarted});
		
		if (CH2.currentCharacter.buffs.hasBuffByName("Recording"))
		{
			CH2.currentCharacter.buffs.removeBuff("Recording");
		}
		CH2.currentCharacter.traits["recording" + id] = this.toJson();
	}
	
	public function startPlayback():void
	{
		if (isRecording)
		{
			TransientEffects.instance.showFadingText("You must stop recording to start playback", 5000, 1000);
			return;
		}
		if (recordedActions.length == 0)
		{
			return;
		}
		
		isPlaying = true;
		playbackStartTime = CH2.user.totalMsecsPlayed;
		playbackDtRemaining = 0;
		playbackIndex = 0;
		
		if (!CH2.currentCharacter.buffs.hasBuffByName("playback"))
		{
			var playbackBuff:Buff = new Buff();
			playbackBuff.isUntimedBuff = true;
			playbackBuff.name = "playback";
			playbackBuff.tickRate = 100;
			playbackBuff.iconId = 358;
			playbackBuff.unhastened = true;
			playbackBuff.stateValues["monstersKilled"] = 0;
			
			playbackBuff.killFunction = function(attackData:AttackData)
			{
				var msecsSinceActivatedOrIdle:Number = Math.min(this.timeSinceActivated, CH2.user.timeSinceLastGameImpactingAction);
				if (msecsSinceActivatedOrIdle >= 180000)
				{
					this.stateValues["monstersKilled"]++;
				}
			}
			playbackBuff.tooltipFunction = function() {
				var damageMultiplier:Number = WizardMain.playBackDamageMultiplierGrowthFormula(this.stateValues["monstersKilled"]);
				
				var description:String;
				var msecsSinceActivatedOrIdle:Number = Math.min(this.timeSinceActivated, CH2.user.timeSinceLastGameImpactingAction);
				if (msecsSinceActivatedOrIdle >= 180000)
				{
					description = "Increases damage for each monster killed while idle.\n\nCurrent Damage Bonus: " + damageMultiplier + "x";
				}
				else
				{
					var secondsUntilIdle:int = Math.ceil(180000 - msecsSinceActivatedOrIdle) / 1000;
					description = "Increases damage for each monster killed while idle.\n\nIdle bonus begins in " + secondsUntilIdle + " seconds of additional idle play";
				}
				
				return {
					"header": "Playback",
					"body": description
				};
			}
			playbackBuff.tickFunction = function()
			{
				var msecsSinceActivatedOrIdle:Number = Math.min(this.timeSinceActivated, CH2.user.timeSinceLastGameImpactingAction);
				if (msecsSinceActivatedOrIdle < 180000)
				{
					this.stateValues["monstersKilled"] = 0;
				}
				var damageMultiplier:Number = WizardMain.playBackDamageMultiplierGrowthFormula(this.stateValues["monstersKilled"]);
				this.buffStat(CH2.STAT_DAMAGE, damageMultiplier);
			}
			CH2.currentCharacter.buffs.addBuff(playbackBuff);
		}
	}
	
	public function endPlayback():void
	{
		isPlaying = false;
		playbackDtRemaining = 0;
		CH2.currentCharacter.buffs.removeBuff("playback");
	}
}

class RecordingTimeline extends Sprite
{
	public var actionLines:Vector.<Sprite>;
	public var timeLineTimes:Vector.<TextField>;
	public var border:Sprite;
	public var playbackBarBackground:Sprite;
	public var playbackBarLineHolder:Sprite;
	public var recordedActionHash:int = 0;

	public var recording:Recording;
	
	public function RecordingTimeline()
	{
		super();
		
		border = CreationUtils.createSquare(405, 55, 0x000000);
		border.x = 0;
		border.y = 0;
		playbackBarBackground = CreationUtils.createSquare(400, 50, 0xFFFFFF);
		playbackLine = CreationUtils.createSquare(3, 50, 0x000000);
		playbackLine.x = 0;
		playbackLine.y = 0;
		playbackLine.visible = false;
		
		playbackBarBackground.x = 2.5;
		playbackBarBackground.y = 2.5;
		
		this.addChild(border);
		this.addChild(playbackBarBackground);
		playbackBarBackground.addChild(playbackLine);
		playbackBarLineHolder = new Sprite();
		playbackBarBackground.addChild(playbackBarLineHolder);
		recordedActionHash = 0;
	}
	
	public function clear():void
	{
		for each (var actionLine:Sprite in actionLines)
		{
			playbackBarLineHolder.removeChild(actionLine);
		}
		actionLines = null;
		recordedActionHash = 0;
	}
	
	public function update(dt:int):void
	{
		if (recording.recordedActions.length < 2) return;
		
		var newHashValue:int = recording.recordedActions.length * recording.recordedActions[recording.recordedActions.length-2]["dt"];
		if (recordedActionHash != newHashValue)
		{
			recordedActionHash = newHashValue;
			
			if (actionLines)
			{
				for (var i:int = 0; i < actionLines.length; i++)
				{
					if (actionLines[i].parent != null)
					{
						actionLines[i].parent.removeChild(actionLines[i]);
					}
				}
			}
			actionLines = new Vector.<Sprite>();
			var totalDuration:int = recording.recordedActions[recording.recordedActions.length - 1]["dt"];
			for (var i:int = 0; i < recording.recordedActions.length; i++)
			{
				if (recording.recordedActions[i]["skillUid"] != "-1")
				{
					if (recording.recordedActions[i]["skillUid"] == "999")
					{
						var actionLine:Sprite = CreationUtils.createSquare(3, 50, 0xAAAAAA);
					}
					else
					{
						var actionLine:Sprite = CreationUtils.createSquare(3, 50, 0xAAAAAA);
					}
					if (recording.recordedActions.length > 0)
					{
						actionLine.x = 400 * (recording.recordedActions[i]["dt"] / totalDuration);
					}
					actionLines.push(actionLine);
					playbackBarLineHolder.addChild(actionLine);
				}
			}
		}
		playbackLine.x = 400 * recording.playbackPercentComplete();
		playbackLine.visible = recording.isPlaying;
	}
}

import com.doogog.utils.MiscUtils;
import com.playsaurus.numbers.BigNumber;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import heroclickerlib.CH2;
import heroclickerlib.managers.MouseEnabler;
import heroclickerlib.managers.TooltipManager;
import heroclickerlib.scrollers.SimpleScroller;
import swc.HUD.StatEntryDisplay;
import swc.HUD.StatHeaderEntryDisplay;
import swc.HUD.StatsSubtabDisplay;
import swc.HUD.StatsPanelBar;
import it.sephiroth.gettext._;
class WizardStatsSubTab extends MovieClip 
{
	private static const UPDATE_FREQUENCY_MSEC:int = 2000;
	
	private var _yOffset:Number = 0;
	private var _scroller:SimpleScroller;
	private var _numberMode:int = 1;
	
	public var typedDisplay:StatsSubtabDisplay;
	
	public function WizardStatsSubTab()
	{
		typedDisplay = new StatsSubtabDisplay();
		addChild(typedDisplay);
		typedDisplay.statsHolder.mask = typedDisplay.statsMask;
		
		populateStats();
		
		_scroller = new SimpleScroller( CH2.game.stage );
		_scroller.offsetScrollY = -15;
		_scroller.initWithOwnSetup( typedDisplay.statsHolder, typedDisplay.statsMask, typedDisplay.scrollbar );
		_scroller.mouseDownSpeed = 10;
		_scroller.registerAreaBGClip( typedDisplay );
	}
	
	private function addStatEntry(nameText:String, value:*, unit:String = "", tooltipText:String="", significantDigits:int = 0):void
	{
		var valueText:String;
		
		if ( value is BigNumber )
		{
			valueText = CH2.game.formattedNumber(value) + unit;
		}
		else
		{
			valueText = Number(value).toFixed(significantDigits) + unit;
		}
		
		var statEntry:MovieClip = new StatEntryDisplay();
		statEntry.field.text = nameText;
		statEntry.field2.text = valueText;
		statEntry.field2.x = 0;
		statEntry.y = _yOffset;
		statEntry.addEventListener(MouseEvent.MOUSE_OVER, function(e:Event){ showStatTooltip(statEntry, nameText, tooltipText); }, false, 0, true);
		statEntry.addEventListener(MouseEvent.MOUSE_OUT, function(e:Event){ hideStatTooltip(); }, false, 0, true);
		typedDisplay.statsHolder.addChild(statEntry);
		_yOffset += 23;
	}
	
	private function addStatHeader(text:String)
	{
		var statHeader:MovieClip;
		var statBar:MovieClip;
		statHeader = new StatHeaderEntryDisplay();
		statBar = new StatsPanelBar();
		statHeader.field.text = text;
		statHeader.y = _yOffset;
		statBar.y = _yOffset + 27;
		typedDisplay.statsHolder.addChild(statHeader);
		typedDisplay.statsHolder.addChild(statBar);
		_yOffset += 28;
	}
	
	private function addSpace(text:String)
	{
		var statEntry:MovieClip;
		statEntry = new StatEntryDisplay();
		statEntry.field.text = text;
		statEntry.y = _yOffset;
		typedDisplay.statsHolder.addChild(statEntry);
		_yOffset += 23;	
	}
	
	public function populateStats():void
	{
		_yOffset = 0;
		typedDisplay.statsHolder.removeChildren();
		
		addStatHeader(_("Stats"));
		addStatEntry(_("Auto-attack Damage:"), (CH2.currentCharacter.damage), "", "Damage that is dealt when the character automatically attacks. You also gain energy when this happens."); 
		addStatEntry(_("Click Damage:"), (CH2.currentCharacter.clickDamage), "", "Damage that is dealt from mouse clicks, and from skills that say they \"click\".");
		addStatEntry(_("Damage Multiplier from Level:"), new BigNumber((CH2.currentCharacter.statValueFunctions[CH2.STAT_DAMAGE](CH2.currentCharacter.level - 1) * 100)), "%", "Damage bonus you have from your character level. This number is multiplied by 150% each time you level up.");
		addStatEntry(_("Attack Delay:"), CH2.currentCharacter.attackDelay / 1000.0, "s", "How much time your character waits between each auto-attack.", 3);
		addStatEntry(_("Energy from Auto Attacks:"), CH2.currentCharacter.energyRegeneration, "", "How much energy you gain from each auto-attack." );
		addStatEntry(_("Global Cooldown Time:"), CH2.currentCharacter.gcd / 1000.0, "s", "After you use a skill, this is how much time it takes for all of your other skills to cool down.", 2);
		addStatEntry(_("Automator Speed:"), CH2.currentCharacter.automatorSpeed * CH2.currentCharacter.hasteRating * 100, "%", "How fast your Automator pointer moves. 100% is the base speed.");
		addStatEntry(_("Critical Chance:"), (CH2.currentCharacter.criticalChance * 100), "%", "Your chance to get a \"Critical hit\", or \"Crit\", when attacking. When this happens, your damage is multiplied by the Critical Damage Multiplier.", 2);
		addStatEntry(_("Critical Damage Multiplier:"), CH2.currentCharacter.getStat(CH2.STAT_CRIT_DAMAGE) * 100, "%", "When you crit, this is how much your damage is multiplied by.");
		addStatEntry(_("Haste:"), CH2.currentCharacter.hasteRating * 100, "%", "Haste affects the rate that you auto-attack, and all cooldown speeds, including Automator cooldown speeds."); //Character.haste
		addStatEntry(_("Maximum Energy:"), CH2.currentCharacter.maxEnergy);
		addStatEntry(_("Maximum Mana:"), CH2.currentCharacter.maxMana);
		addStatEntry(_("Mana Regeneration:"), (CH2.currentCharacter.getStat(CH2.STAT_MANA_REGEN)) * 100, "%", "");
		addStatEntry(_("Run Speed:"), CH2.currentCharacter.walkSpeedMultiplier * 100, "%", "How fast you run. 100% is the base speed.");
		addStatEntry(_("Gold from All Sources:"), CH2.currentCharacter.getStat(CH2.STAT_GOLD) * 100, "%", "How much gold you get from all sources. 100% is the base amount." );
		addStatEntry(_("Monster Gold:"), CH2.currentCharacter.getStat(CH2.STAT_MONSTER_GOLD) * 100, "%", "How much gold you get from bosses, including mini-bosses, 25-zone bosses, and world bosses. 100% is the base amount." );
		addStatEntry(_("Treasure Chest Chance:"), CH2.currentCharacter.getStat(CH2.STAT_TREASURE_CHEST_CHANCE) * 100, "%", "The chance of a monster spawning as a treasure chest.", 2);
		addStatEntry(_("Treasure Chest Gold:"), CH2.currentCharacter.getStat(CH2.STAT_TREASURE_CHEST_GOLD) * 500, "%", "How much gold you get from treasure chests, compared to normal monsters.");
		addStatEntry(_("Item Costs:"), ((CH2.currentCharacter.getStat(CH2.STAT_ITEM_COST_REDUCTION))) * 100, "%", "How much your items cost. 100% is the base amount.", 2);
		addStatEntry(_("Ancient Shards:"), (CH2.currentCharacter.ancientShards), "", "Ancient shards are purchased from the Ruby Shop.");
		
		addSpace("");
		addStatHeader(_("Bonuses from Equipment"));
		addStatEntry(_("Click Damage:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_CLICK_DAMAGE) * 100, "%");
		addStatEntry(_("Critical Chance:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_CRIT_CHANCE) * 100, "%", null, 2);
		addStatEntry(_("Critical Damage Multiplier:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_CRIT_DAMAGE) * 100, "%");
		addStatEntry(_("Haste:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_HASTE) * 100, "%"); // Character.inventory.getEquippedStat(Multiplier/Rating)
		addStatEntry(_("Maximum Energy:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_TOTAL_ENERGY));
		addStatEntry(_("Maximum Mana:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_TOTAL_MANA));
		addStatEntry(_("Mana Regeneration:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_MANA_REGEN) * 100, "%");
		addStatEntry(_("Gold from All Sources:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_GOLD) * 100, "%");
		addStatEntry(_("Bonus Gold Chance:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_BONUS_GOLD_CHANCE) * 100, "%");
		addStatEntry(_("Monster Gold:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_MONSTER_GOLD) * 100, "%");
		addStatEntry(_("Clickable Gold Piles:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_CLICKABLE_GOLD) * 100, "%");
		addStatEntry(_("Clickable Gold Chance:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_CLICKABLE_CHANCE) * 100, "%");
		addStatEntry(_("Treasure Chest Chance:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_TREASURE_CHEST_CHANCE) * 100, "%", null, 2);
		addStatEntry(_("Treasure Chest Gold:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_TREASURE_CHEST_GOLD) * 100, "%");
		addStatEntry(_("Item Costs:"), CH2.currentCharacter.inventory.getEquippedStatRating(CH2.STAT_ITEM_COST_REDUCTION) * 100, "%", null, 2);
		
		addSpace("");
		addStatHeader("Bonuses from Skill Tree");
		addSpace("");
		addStatHeader("Ice");
		addStatEntry(_("Chance of Reduced Ice Spell Cost:"), CH2.currentCharacter.getTrait("IceCostReductionPercentChance") * 100, "%");
		addStatEntry(_("Ice Additional Damage from Crits:"), CH2.currentCharacter.getTrait("IceCritAdditionalDamage") * 100, "%");
		addStatEntry(_("Ice Additional Damage:"), CH2.currentCharacter.getTrait("IceAdditionalPercentDamage") * 100, "%");
		addStatEntry(_("Cool Crits Chance of Critical Hit:"), CH2.currentCharacter.getTrait("Ice1CritChance") * 100, "%");
		addStatEntry(_("Coolth Number of Crtits Which Cool:"), CH2.currentCharacter.getTrait("CoolthNumCritsWhichCool"));
		addStatEntry(_("Coolth Reduced Hyperthermia Per Crit:"), CH2.currentCharacter.getTrait("CoolthReductionPerCrit"), "");
		addStatEntry(_("Shatter Damage:"), CH2.currentCharacter.getTrait("ShatterDamagePercent") * 100, "%"); //deal to next monsterS
		addStatEntry(_("Monsters Effected by Shatter:"), CH2.currentCharacter.getTrait("ShatterDamageMonsters"));
		addStatEntry(_("Ice Additional Chance of Crit:"), CH2.currentCharacter.getTrait("IceAdditionalCritChance") * 100, "%");
		addStatEntry(_("Cool Criticals Duration:"), CH2.currentCharacter.getTrait("Ice1CritDuration"), "sec");
		addStatEntry(_("Ice Corrosion Damage:"), CH2.currentCharacter.getTrait("IceCorrosionDamageBonus") * 100, "%");
		addStatEntry(_("Synergy Ice Lightning Duration:"), CH2.currentCharacter.getTrait("IceLightningBuffDuration")/1000, "sec");
		addStatEntry(_("Synergy Ice Fire Duration:"), CH2.currentCharacter.getTrait("IceFireBuffDuration") / 10000, "sec");
		
		addStatHeader("Fire");
		addStatEntry(_("Chance of Reduced Fire Spell Cost:"), CH2.currentCharacter.getTrait("FireCostReductionPercentChance") * 100, "%");
		addStatEntry(_("Fire Additional Damage from Crits:"), CH2.currentCharacter.getTrait("FireCritAdditionalDamage") * 100, "%");
		addStatEntry(_("Fire Additional Damage:"), CH2.currentCharacter.getTrait("FireAdditionalPercentDamage") * 100, "%");
		addStatEntry(_("Warmth Max Hypothermia Reductions:"), CH2.currentCharacter.getTrait("WarmthMaxNumberOfReductions"));
		addStatEntry(_("Warmth Reduced Hypothermia Per Burn:"), CH2.currentCharacter.getTrait("WarmthReductionPerBurn"), "");
		addStatEntry(_("Chance of Combustion:"), CH2.currentCharacter.getTrait("DoubleBurnChance") * 100, "%");
		addStatEntry(_("Explosion Damage:"), CH2.currentCharacter.getTrait("FireExplosionDamagePercent") * 100, "%"); //deal to next monster
		addStatEntry(_("Explosion Damage Dealt To Next Monster:"), CH2.currentCharacter.getTrait("FireExplosionDamagePercent") * 100, "%");
		addStatEntry(_("Fire Additional Damage from Corrosion:"), CH2.currentCharacter.getTrait("FireCorrosionDamageBonus") * 100, "%");
		addStatEntry(_("Fire Zap Percent Damage:"), CH2.currentCharacter.getTrait("FireZapPercentDamage") * 100, "%");
		addStatEntry(_("Fire Burn Damage:"), CH2.currentCharacter.getTrait("FireBurnDamage") * 100, "%");
		addStatEntry(_("Synergy Lightning Fire Duration:"), CH2.currentCharacter.getTrait("LightningFireBuffDuration") / 1000, "sec");
		
		addStatHeader("Lightning");
		addStatEntry(_("Chance of Reduced Lightning Spell Cost:"), CH2.currentCharacter.getTrait("LightningCostReductionPercentChance") * 100, "%");
		addStatEntry(_("Lightning Additional Chance of Crit:"), CH2.currentCharacter.getTrait("LightningAdditionalCritChance") * 100, "%");
		addStatEntry(_("Lightning Additional Damage:"), CH2.currentCharacter.getTrait("LightningAdditionalPercentDamage") * 100, "%");
		addStatEntry(_("Flash % Spell Cast Duration Increase:"), CH2.currentCharacter.getTrait("LightningFlashHaste") * 100, "%");
		addStatEntry(_("Energize % Energy Restored:"), CH2.currentCharacter.getTrait("EnergizeEnergyRestoration") * 100, "%");
		addStatEntry(_("Energize Duration:"), CH2.currentCharacter.getTrait("EnergizeDuration"), "sec");
		addStatEntry(_("Lightning Circuit Damage:"), CH2.currentCharacter.getTrait("LightningCircuitDamagePercent") * 100, "%");
		addStatEntry(_("Lightning Chain Chance:"), CH2.currentCharacter.getTrait("LightningChainChance") * 100, "%"); //of hitting additional monster(s)
		addStatEntry(_("Lightning Zap Percent Damage:"), CH2.currentCharacter.getTrait("LightningZapPercentDamage") * 100, "%");
		addStatEntry(_("Lightning Burn Damage:"), CH2.currentCharacter.getTrait("LightningBurnDamage") * 100, "%");
		

		addSpace("");
		addStatHeader(_("Worlds"));
		addStatEntry(_("Highest World Completed:"), CH2.currentCharacter.highestWorldCompleted);
		addStatEntry(_("Total Monsters Killed:"), CH2.user.totalMonstersKilled);
		
		addSpace("");
		addStatHeader(_("Other"));
		addStatEntry(_("Time Played (All Characters):"), CH2.user.totalMsecsPlayed / 86400000.0, " days", "Don't pay too much attention to this.", 2);
		addStatEntry(_("Total Experience:"), CH2.currentCharacter.totalExperience, " exp");
		addStatEntry(_("Total Rubies:"), CH2.currentCharacter.totalRubies);
		
		MouseEnabler.instance.enableDisplayAndChildren(typedDisplay);
	}
	
	private function getSkillTreeBonusValue(nodeStatId:int):Number
	{
		var statBaseValue:Number = CH2.currentCharacter.statBaseValues[nodeStatId];
		if (CH2.currentCharacter.statLevels.hasOwnProperty(nodeStatId))
		{
			return (CH2.currentCharacter.statValueFunctions[nodeStatId](CH2.currentCharacter.statLevels[nodeStatId])) - statBaseValue;
		}
		else
		{
			return 0;
		}
	}
	
	private function showStatTooltip(display:MovieClip, statName:String, tooltipBody:String):void
	{
		if (tooltipBody)
		{
			TooltipManager.instance.showTooltip(statName, tooltipBody, display);
		}
	}
	
	private function hideStatTooltip():void
	{
		TooltipManager.instance.hide();
	}
	
	public function update(dt:int):void
	{
		var currentNumberMode:int = int(CH2.user.numberModeShortNumber) + (int(CH2.user.numberModeAlphabetic) * 2) + (int(CH2.user.numberModeEngineer) * 4) + (int(CH2.user.numberModeScientific) * 8);
		if (currentNumberMode != _numberMode)
		{
			_numberMode = currentNumberMode;
			populateStats();
		}
		else
		{
			if (MiscUtils.requiresUpdate(UPDATE_FREQUENCY_MSEC, dt))
			{
				populateStats();
			}
		}
	}
}