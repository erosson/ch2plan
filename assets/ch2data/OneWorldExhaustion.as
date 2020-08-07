package
{
	import HelpfulAdventurerChallengeBase;
	import com.bigDecimal.com.BigDecimal;
	import com.doogog.utils.MiscUtils;
	import com.playsaurus.managers.BigNumberFormatter;
	import com.playsaurus.numbers.BigNumber;
	import com.playsaurus.utils.ServerTimeKeeper;
	import com.playsaurus.utils.StringFormatter;
	import com.playsaurus.utils.TimeFormatter;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import heroclickerlib.CH2;
	import com.playsaurus.model.Model;
	import heroclickerlib.managers.Formulas;
	import heroclickerlib.ui.CharacterDisplayUI;
	import heroclickerlib.ui.CharacterUIElement;
	import heroclickerlib.Shaker;
	import heroclickerlib.LevelGraph;
	import heroclickerlib.world.CharacterDisplay;
	import heroclickerlib.world.World;
	import models.Automator;
	import models.AutomatorGem;
	import models.AutomatorStone;
	import models.AutomatorWorldEndOption;
	import models.Buff;
	import models.ChallengeResult;
	import models.Character;
	import models.Characters;
	import models.EtherealItem;
	import models.EtherealItemStat;
	import models.EtherealItemStatChoice;
	import models.Item;
	import models.ItemStat;
	import models.Items;
	import models.Skill;
	import models.Character;
	import models.Monster;
	import models.AttackData;
	import models.Skin;
	import models.StarSystem;
	import models.Tutorial;
	import models.RubyPurchase;
	import models.AscensionWorld;
	import models.AscensionWorlds;
	import heroclickerlib.GpuMovieClip;
	import heroclickerlib.managers.CH2AssetManager;
	import com.gskinner.utils.Rnd;
	import heroclickerlib.managers.SoundManager;
	import HelpfulAdventurer.thumbnail;
	import models.UserData;
	import ui.CH2UI;
	import ui.TutorialManager;
	import ui.hud.HUD;
	import ui.panels.graph.GraphPanel;
	import it.sephiroth.gettext._;
	import flash.utils.describeType;
	import models.ExtendedVariables;
	import models.EventLog;
	import flash.utils.getQualifiedSuperclassName;
	import flash.utils.getDefinitionByName;
	import models.AttackData;
	import Challenge2Assets.thumbnail;
	import heroclickerlib.managers.ItemDropManager;
	
	public dynamic class OneWorldExhaustion extends HelpfulAdventurerChallengeBase
	{
		public static const GOLD_GAIN_MULTIPLIER:Number = 1;
		//############### DEFINE THE SUPER CLASS ASSET GROUP AND CHARACTER NAME ###############
		public static const SUPER_CLASS_CHARACTER_NAME:String = "Helpful Adventurer";
		public static const CHARACTER_ASSET_GROUP:String = "HelpfulAdventurer";
		//#####################################################################################
		public static const CHARACTER_NAME:String = "One World Exhaustion";
		public static const NEW_CHARACTER_NAME:String = "One World Exhaustion";
		public static const ZONE_FREQUENCY_TO_SAVE_PROGRESS:int = 10; //Save every 10 zones, this shouldn't exceed more than 50 data points per challenge
		private static const ACHIEVEMENT_TIMES:Object = {
			"bronze": 40 * 60,
			"silver": 30 * 60,
			"gold": 20 * 60
		};
		
		//Determines the starting perk levels
		public static const CHARACTER_PERKS:Array = [
			{ "name": "GOLD", "id": "0", "level": 10 },
			{ "name": "CRIT_CHANCE", "id": "1", "level": 25 },
			{ "name": "CRIT_DAMAGE", "id": "2", "level": 10 },
			{ "name": "HASTE", "id": "3", "level": 8 },
			{ "name": "CLICKABLE_GOLD", "id": "4", "level": 10 },
			{ "name": "CLICK_DAMAGE", "id": "5", "level": 5 },
			{ "name": "MONSTER_GOLD", "id": "6", "level": 10 },
			{ "name": "ITEM_COST_REDUCTION", "id": "7", "level": 10 },
			{ "name": "TOTAL_MANA", "id": "8", "level": 5 },
			{ "name": "MANA_REGEN", "id": "9", "level": 20 },
			{ "name": "TOTAL_ENERGY", "id": "10", "level": 10 },
			{ "name": "BONUS_GOLD_CHANCE", "id": "11", "level": 10 },
			{ "name": "CLICKABLE_CHANCE", "id": "12", "level": 15 },
			{ "name": "TREASURE_CHEST_CHANCE", "id": "13", "level": 15 },
			{ "name": "TREASURE_CHEST_GOLD", "id": "14", "level": 10 },
			{ "name": "ITEM_WEAPON_DAMAGE", "id": "15", "level": 10 },
			{ "name": "ITEM_HEAD_DAMAGE", "id": "16", "level": 10 },
			{ "name": "ITEM_CHEST_DAMAGE", "id": "17", "level": 10 },
			{ "name": "ITEM_RING_DAMAGE", "id": "18", "level": 10 },
			{ "name": "ITEM_LEGS_DAMAGE", "id": "19", "level": 10 },
			{ "name": "ITEM_HANDS_DAMAGE", "id": "20", "level": 10 },
			{ "name": "ITEM_FEET_DAMAGE", "id": "21", "level": 10 },
			{ "name": "ITEM_BACK_DAMAGE", "id": "22", "level": 10 },
			{ "name": "AUTOMATOR_SPEED", "id": "23", "level": 10 },
			{ "name": "AUTOATTACK_DAMAGE", "id": "24", "level": 5 },
			{ "name": "BigClicksDamage", "id": "35", "level": 15 },
			{ "name": "HugeClickDamage", "id": "38", "level": 15 },
			{ "name": "ManaCritDamage", "id": "39", "level": 15 },
			{ "name": "ImprovedEnergize", "id": "40", "level": 10 },
			{ "name": "SustainedPowersurge", "id": "41", "level": 20 },
			{ "name": "ImprovedPowersurge", "id": "42", "level": 15 },
			{ "name": "ImprovedReload", "id": "43", "level": 20 }
		];
		
		public function OneWorldExhaustion() 
		{
			super();
			
			this.MOD_INFO = 
			{
				"id": 5,
				"name": NEW_CHARACTER_NAME,
				"description": "Default prepackaged character class",
				"version": 1,
				"author": "Playsaurus",
				"dependencies": "HelpfulAdventurer",
				"library": {}
			};
			
			MOD_INFO["library"]["thumbnail"] = Challenge2Assets.thumbnail;
			MOD_INFO["library"]["frame"] = HelpfulAdventurer.frame;
		}
		
		/*
		 * Call super class using it's character name so as to ensure function executes within branches
		 */ 
		private function callSuperClassFunction(superClassFunction:Function, characterInstanceToOverride:Character, ...rest):void
		{
			characterInstanceToOverride.name = SUPER_CLASS_CHARACTER_NAME;
			superClassFunction.apply(null, rest);
			characterInstanceToOverride.name = NEW_CHARACTER_NAME;
		}
		
		override public function onStartup(game:IdleHeroMain):void //Save data is NOT loaded at this point, init() has not yet been run
		{
			//############### ENSURE SUPER CLASS ONSTARTUP SAVES USING PROPER NAME ###############
			HelpfulAdventurerChallengeBase.CHARACTER_NAME = NEW_CHARACTER_NAME;
			super.onStartup(game);
			HelpfulAdventurerChallengeBase.CHARACTER_NAME = SUPER_CLASS_CHARACTER_NAME;
			//####################################################################################
			
			var newCharacter:Character = this.helpfulAdventurer;
			
			newCharacter.assetGroupName = "HelpfulAdventurer"; 	// Lets a character use Cid's art assets
			newCharacter.name = NEW_CHARACTER_NAME; 			// Needs to match mod name in MOD_INFO
			newCharacter.flavorName = "One World Exhaustion";
			newCharacter.flavorClass = "As Cid, The Helpful Adventurer";
			newCharacter.flavor = "Clicks regenerate energy, but give Exhaustion. The skill tree has been changed and there are new buffs to unlock.";
			newCharacter.availableForCreation = true;
			newCharacter.visibleOnCharacterSelect = true;
			newCharacter.startingSkills = [ ];
			newCharacter.upgradeableStats = Character.DEFAULT_UPGRADEABLE_STATS;
			newCharacter.attackMsDelay = 600;
			newCharacter.gildStartBuild = [3, 1, 5, 4, 2, 6, 8, 9, 11, 13, 14, 35, 39, 40, 454, 474, 140, 309];		
			newCharacter.isChallengeCharacter = true;
			
			newCharacter.excludedItemStats = [];
			newCharacter.excludedItemStats.push(CH2.STAT_TOTAL_ENERGY.toString());
			newCharacter.statBaseValues[CH2.STAT_TOTAL_ENERGY] = 20;
			
			//replaces Clickstorm with a modified AutoAttackstorm
			newCharacter.levelGraphNodeTypes["T4"] = { 
				"name": "AutoAttackStorm",
				"tooltip": "Storm: Consumes 2.5 mana per second to auto attack 5 times per second, until you run out of mana. Autoattack damage is doubled while active.",
				"flavorText": "Replaces your current Storm.",
				"setupFunction": function(){},
				"purchaseFunction": function(nodeLevel:Number) { replaceStorm(CH2.currentCharacter.getStaticSkill("Challenge Autoattackstorm"));},  
				"icon": "damagex3",
				"flammable": true
			},
			
			//replace Energize with Managize
			newCharacter.levelGraphNodeTypes["T2"] = newCharacter.levelGraphNodeTypes["Q30"];
			
			//replaces Crit storm
			newCharacter.levelGraphNodeTypes["Q65"] = { 
				"name": "Improved Overflow",
				"tooltip": "Monsters killed by Big Clicks have a chance to give a stack of Improved Overflow. When Manacrit Overflow is unlocked Improved Overflow allows it to damage up to 5 enemies. Each enemy hit reduces the cooldown of Manacrit by 25%.",
				"flavorText": "Chance is based on 4% of your Big Clicks Damage.",
				"setupFunction": function(){},
				"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("CriticalBigClicks", nodeLevel, false, false); },
				"icon": "damagex3",
				"flammable": true
			};
			
			//replaces Golden clicks
			newCharacter.levelGraphNodeTypes["Q41"] = {
				"name": "Pay Day",
				"tooltip": "Monsters killed by Big Clicks have a chance to give a stack of Pay Day. Pay Day increases the gold dropped from the next monster killed with Huge Click by 250% for each stack.",
				"flavorText":  "Chance is based on 4% of your Big Clicks Damage.",
				"setupFunction": function(){},
				"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("PayDay", nodeLevel, false, false); },
				"icon": "damagex3",
				"flammable": true
			};
			
			//replaces Click Torrent
			newCharacter.levelGraphNodeTypes["Q88"] = {
				"name": "Reinvigorate",
				"tooltip": "Every click has a chance to remove Exhaust.",
				"flavorText":  "Chance is based on 3% of your Haste.",
				"setupFunction": function(){},
				"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("Reinvigorate", nodeLevel, false, false); },
				"icon": "damagex3",
				"flammable": true
			};
			
			//Synchrony no longer increases energy regen from autoattacks.
			newCharacter.levelGraphNodeTypes["Q21"] = { 
				"name": "Synchrony",
				"tooltip": "Skills do not interrupt Auto Attacks." ,
				"flavorText": null,
				"setupFunction": function(){},
				"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("Synchrony", nodeLevel, false, false); applyUninterruptedAutoAttacksTalent()},  
				"icon": "damagex3",
				"flammable": true
			},

			//replaces total energy nodes with autoattack damage nodes. (I know... I hate it too)
			newCharacter.levelGraphNodeTypes["En"] = newCharacter.levelGraphNodeTypes["Aa"];
			newCharacter.levelGraphNodeTypes["qEn"] = newCharacter.levelGraphNodeTypes["Aa"];
			
			//replace total mana with big clicks damage
			newCharacter.levelGraphNodeTypes["Mt"] = newCharacter.levelGraphNodeTypes["Bd"];
			newCharacter.levelGraphNodeTypes["qMt"] = newCharacter.levelGraphNodeTypes["qBd"];
			
			newCharacter.levelGraphObject = {"nodes":[{"1":{"x":0, "val":"T1", "y": -84}}, {"2":{"x":85, "val":"T2", "y": -1}}, {"3":{"x":1, "val":"T3", "y":82}}, {"4":{"x": -81, "val":"T4", "y":0}}, {"5":{"x": -211, "val":"T5", "y":131}}, {"6":{"x": -211, "val":"V", "y":0}}, {"8":{"x": -211, "val":"T8", "y":268}}, {"9":{"x": -423, "val":"V", "y": -84}}, {"11":{"x": -211, "val":"T7", "y": -266}}, {"13":{"x": -339, "val":"V", "y":0}}, {"14":{"x": -211, "val":"T6", "y": -134}}, {"24":{"x": -1612, "val":"Gp", "y": -224}}, {"39":{"x": -507, "val":"V", "y": -1}}, {"40":{"x": -423, "val":"V", "y":82}}, {"41":{"x": -1120, "val":"Ir", "y": -11}}, {"42":{"x":108, "val":"V", "y": -1848}}, {"43":{"x": -4, "val":"Gc", "y": -1274}}, {"44":{"x": -8, "val":"Cc", "y": -1481}}, {"45":{"x": -830, "val":"Gp", "y": -1045}}, {"51":{"x": -666, "val":"qG", "y":558}}, {"53":{"x":296, "val":"qH", "y":558}}, {"54":{"x": -332, "val":"Gc", "y": -2071}}, {"55":{"x": -328, "val":"Gp", "y": -1896}}, {"56":{"x": -58, "val":"Mr", "y": -1846}}, {"57":{"x":146, "val":"Bd", "y": -1544}}, {"58":{"x":1883, "val":"Aa", "y": -939}}, {"59":{"x":107, "val":"Bc", "y": -1690}}, {"60":{"x":1106, "val":"I7", "y": -171}}, {"61":{"x":254, "val":"Cc", "y": -2103}}, {"62":{"x":382, "val":"I3", "y": -2203}}, {"63":{"x": -1742, "val":"Ea", "y":511}}, {"64":{"x":1074, "val":"Bg", "y": -1927}}, {"65":{"x":1228, "val":"Cl", "y": -1944}}, {"66":{"x":1796, "val":"Tg", "y": -1637}}, {"67":{"x":1385, "val":"Gc", "y": -1951}}, {"68":{"x":1236, "val":"H", "y": -117}}, {"69":{"x":1605, "val":"Gb", "y": -1867}}, {"70":{"x":1698, "val":"G", "y": -1737}}, {"71":{"x":1622, "val":"Bc", "y": -1099}}, {"72":{"x":1890, "val":"Mu", "y": -659}}, {"73":{"x":1213, "val":"Mu", "y": -309}}, {"74":{"x":375, "val":"Mu", "y": -615}}, {"75":{"x":498, "val":"H", "y": -491}}, {"76":{"x":816, "val":"V", "y": -520}}, {"77":{"x": -977, "val":"Gp", "y": -88}}, {"78":{"x":1544, "val":"V", "y": -533}}, {"79":{"x":466, "val":"Pa", "y": -854}}, {"80":{"x":605, "val":"V", "y": -963}}, {"81":{"x":660, "val":"Pt", "y": -1145}}, {"82":{"x":1914, "val":"Hd", "y": -800}}, {"83":{"x":1920, "val":"H", "y": -291}}, {"84":{"x":1788, "val":"Bd", "y": -341}}, {"85":{"x": -171, "val":"Hd", "y":1190}}, {"86":{"x": -128, "val":"G", "y":1054}}, {"87":{"x":1674, "val":"I4", "y": -583}}, {"88":{"x":1752, "val":"Md", "y": -691}}, {"89":{"x":110, "val":"Mt", "y": -2121}}, {"90":{"x":493, "val":"G", "y": -2303}}, {"91":{"x":811, "val":"I4", "y": -2108}}, {"92":{"x":617, "val":"V", "y": -2220}}, {"93":{"x":764, "val":"Cl", "y": -2231}}, {"94":{"x":1879, "val":"Md", "y": -1380}}, {"95":{"x":1805, "val":"I8", "y": -1259}}, {"96":{"x":1744, "val":"V", "y": -1018}}, {"97":{"x":1668, "val":"Aa", "y": -1317}}, {"98":{"x":1837, "val":"Md", "y": -1122}}, {"99":{"x":693, "val":"Md", "y": -843}}, {"100":{"x":1308, "val":"Pa", "y": -519}}, {"101":{"x":717, "val":"Cc", "y": -655}}, {"102":{"x":829, "val":"Hd", "y": -839}}, {"103":{"x":988, "val":"Aa", "y": -272}}, {"104":{"x":1961, "val":"Bc", "y": -418}}, {"105":{"x":603, "val":"I3", "y": -1291}}, {"106":{"x":946, "val":"G", "y": -771}}, {"107":{"x":947, "val":"Ra", "y": -917}}, {"108":{"x":776, "val":"Cd", "y": -1246}}, {"109":{"x":1348, "val":"Ir", "y": -386}}, {"110":{"x":429, "val":"Md", "y": -2078}}, {"111":{"x":970, "val":"Aa", "y": -1034}}, {"112":{"x":376, "val":"Cd", "y": -1946}}, {"113":{"x":1066, "val":"Tc", "y": -2063}}, {"114":{"x":667, "val":"Bc", "y": -440}}, {"115":{"x":270, "val":"Mr", "y": -895}}, {"116":{"x":122, "val":"Aa", "y": -1388}}, {"117":{"x":207, "val":"Ea", "y": -1063}}, {"118":{"x":143, "val":"I1", "y": -1223}}, {"119":{"x":555, "val":"G", "y": -1489}}, {"120":{"x":691, "val":"Cc", "y": -1405}}, {"121":{"x":951, "val":"Ir", "y": -2157}}, {"122":{"x":426, "val":"Cd", "y": -1420}}, {"123":{"x":301, "val":"Aa", "y": -1317}}, {"124":{"x":325, "val":"Md", "y": -739}}, {"125":{"x":1178, "val":"Md", "y": -440}}, {"126":{"x":1563, "val":"Mu", "y": -164}}, {"127":{"x":482, "val":"Hd", "y":2204}}, {"128":{"x":1699, "val":"I5", "y": -215}}, {"129":{"x": -1277, "val":"Gc", "y": -40}}, {"130":{"x":23, "val":"I2", "y": -1985}}, {"131":{"x": -2397, "val":"qMt", "y":656}}, {"132":{"x": -1932, "val":"qEn", "y":194}}, {"133":{"x": -2396, "val":"qGp", "y":1014}}, {"134":{"x": -2298, "val":"qIr", "y":1088}}, {"135":{"x": -2310, "val":"qGc", "y":997}}, {"136":{"x": -2196, "val":"Q43", "y":825}}, {"137":{"x": -1731, "val":"qHd", "y":1196}}, {"138":{"x": -1578, "val":"qIr", "y":1317}}, {"139":{"x": -159, "val":"qBd", "y":2249}}, {"140":{"x": -1798, "val":"qG", "y":1448}}, {"141":{"x": -1650, "val":"qG", "y":1009}}, {"142":{"x": -1547, "val":"Q44", "y":504}}, {"143":{"x": -1187, "val":"qGp", "y":257}}, {"144":{"x": -129, "val":"qH", "y":2114}}, {"145":{"x": -262, "val":"qMu", "y":1592}}, {"146":{"x": -1079, "val":"qBg", "y":875}}, {"147":{"x": -728, "val":"qGb", "y":1542}}, {"148":{"x": -780, "val":"qHd", "y":1251}}, {"149":{"x": -881, "val":"Q42", "y":1205}}, {"150":{"x": -862, "val":"qTc", "y":1310}}, {"151":{"x": -2230, "val":"Q41", "y":1707}}, {"152":{"x": -2230, "val":"qHd", "y":1998}}, {"153":{"x": -546, "val":"qBd", "y":2054}}, {"154":{"x": -984, "val":"Q45", "y":1964}}, {"155":{"x": -775, "val":"qTg", "y":1865}}, {"156":{"x": -1519, "val":"qG", "y":2146}}, {"157":{"x": -797, "val":"qHd", "y":2294}}, {"158":{"x": -1628, "val":"qGb", "y":1831}}, {"159":{"x": -589, "val":"qH", "y":861}}, {"160":{"x": -2156, "val":"qMr", "y":420}}, {"161":{"x": -2291, "val":"I6", "y":357}}, {"162":{"x": -2425, "val":"Gc", "y":402}}, {"163":{"x": -2440, "val":"Gp", "y":532}}, {"164":{"x": -2107, "val":"G", "y":608}}, {"165":{"x": -1851, "val":"Mt", "y":449}}, {"166":{"x": -1957, "val":"Mr", "y":324}}, {"167":{"x": -1786, "val":"V", "y":262}}, {"168":{"x": -1404, "val":"Aa", "y":442}}, {"169":{"x": -2006, "val":"En", "y":505}}, {"170":{"x": -1658, "val":"Aa", "y":378}}, {"171":{"x": -1640, "val":"Gp", "y":630}}, {"172":{"x": -1761, "val":"Gc", "y":737}}, {"173":{"x": -1897, "val":"I4", "y":820}}, {"174":{"x": -1687, "val":"Cd", "y":871}}, {"175":{"x": -1338, "val":"Cl", "y":953}}, {"176":{"x": -1964, "val":"Aa", "y":1263}}, {"177":{"x": -1889, "val":"I3", "y":1123}}, {"178":{"x": -1860, "val":"Ra", "y":963}}, {"179":{"x": -1786, "val":"V", "y":1859}}, {"180":{"x": -1839, "val":"Mr", "y":1713}}, {"181":{"x": -1491, "val":"I5", "y":979}}, {"182":{"x": -2048, "val":"Aa", "y":1994}}, {"183":{"x": -718, "val":"Hd", "y":922}}, {"184":{"x": -1435, "val":"Cd", "y":603}}, {"185":{"x":1, "val":"Hd", "y":2111}}, {"186":{"x": -2271, "val":"G", "y":718}}, {"187":{"x": -1247, "val":"Bd", "y":406}}, {"188":{"x": -1081, "val":"Bc", "y":382}}, {"189":{"x": -1294, "val":"Cc", "y":659}}, {"190":{"x": -789, "val":"Gp", "y":452}}, {"191":{"x": -923, "val":"V", "y":372}}, {"192":{"x": -982, "val":"I8", "y":244}}, {"193":{"x": -1226, "val":"G", "y":786}}, {"194":{"x": -779, "val":"Ir", "y":662}}, {"195":{"x": -2450, "val":"I2", "y":764}}, {"196":{"x": -2443, "val":"Hd", "y":892}}, {"197":{"x": -2085, "val":"Hd", "y":185}}, {"198":{"x": -2231, "val":"Ra", "y":205}}, {"199":{"x": -1020, "val":"Tg", "y":742}}, {"200":{"x": -499, "val":"Ir", "y":1200}}, {"201":{"x": -926, "val":"Tc", "y":633}}, {"202":{"x": -1193, "val":"Tc", "y":973}}, {"203":{"x": -2410, "val":"Md", "y":1798}}, {"204":{"x": -463, "val":"V", "y":935}}, {"205":{"x": -442, "val":"Aa", "y":1071}}, {"206":{"x": -2351, "val":"Pa", "y":1922}}, {"207":{"x": -640, "val":"I1", "y":1208}}, {"208":{"x": -719, "val":"Bg", "y":1102}}, {"209":{"x": -824, "val":"G", "y":1008}}, {"210":{"x": -932, "val":"Gb", "y":913}}, {"211":{"x": -1439, "val":"Hd", "y":1112}}, {"212":{"x": -1448, "val":"G", "y":1252}}, {"213":{"x": -1869, "val":"I7", "y":2006}}, {"214":{"x": -1511, "val":"Ea", "y":1443}}, {"215":{"x": -1126, "val":"V", "y":1944}}, {"216":{"x": -658, "val":"Pa", "y":2348}}, {"217":{"x": -1689, "val":"Pt", "y":2064}}, {"218":{"x": -1340, "val":"Cc", "y":2152}}, {"219":{"x": -1157, "val":"Cd", "y":2208}}, {"220":{"x": -975, "val":"Md", "y":2250}}, {"221":{"x": -1160, "val":"Bd", "y":2077}}, {"222":{"x": -1022, "val":"V", "y":1180}}, {"223":{"x": -1039, "val":"Tg", "y":1307}}, {"224":{"x": -1057, "val":"Ir", "y":1436}}, {"225":{"x": -902, "val":"Gb", "y":1435}}, {"226":{"x": -616, "val":"Gp", "y":1465}}, {"227":{"x": -256, "val":"Mu", "y":1312}}, {"228":{"x": -584, "val":"G", "y":1330}}, {"229":{"x": -2360, "val":"Aa", "y":247}}, {"230":{"x": -229, "val":"H", "y":1453}}, {"231":{"x": -187, "val":"I3", "y":1721}}, {"232":{"x": -125, "val":"Bd", "y":1840}}, {"233":{"x": -791, "val":"Ea", "y":2014}}, {"234":{"x": -611, "val":"Gb", "y":1786}}, {"235":{"x": -621, "val":"Bg", "y":1916}}, {"236":{"x": -1025, "val":"Bg", "y":1573}}, {"237":{"x": -553, "val":"Gc", "y":1582}}, {"238":{"x": -75, "val":"Bc", "y":1971}}, {"239":{"x": -1010, "val":"Ra", "y":1715}}, {"240":{"x": -638, "val":"Aa", "y":2155}}, {"241":{"x":59, "val":"Mu", "y":2226}}, {"242":{"x": -39, "val":"H", "y":2304}}, {"243":{"x": -519, "val":"Pt", "y":2173}}, {"244":{"x": -60, "val":"Cl", "y":2198}}, {"245":{"x": -524, "val":"I5", "y":2298}}, {"246":{"x": -2013, "val":"Tg", "y":968}}, {"247":{"x": -2168, "val":"Tc", "y":981}}, {"248":{"x": -2420, "val":"Gc", "y":1409}}, {"249":{"x": -1899, "val":"Hd", "y":1574}}, {"250":{"x": -2414, "val":"Gp", "y":1549}}, {"251":{"x": -1309, "val":"Ra", "y":1209}}, {"252":{"x": -2011, "val":"Mt", "y":1460}}, {"253":{"x": -2205, "val":"G", "y":1221}}, {"254":{"x": -2365, "val":"I1", "y":1291}}, {"255":{"x": -2413, "val":"Cd", "y":1153}}, {"256":{"x": -1162, "val":"Aa", "y":1190}}, {"257":{"x": -2111, "val":"V", "y":1345}}, {"258":{"x": -2225, "val":"Cd", "y":1428}}, {"259":{"x": -2379, "val":"I8", "y":1677}}, {"260":{"x": -562, "val":"Ea", "y":675}}, {"261":{"x": -460, "val":"Aa", "y":787}}, {"262":{"x": -797, "val":"Ir", "y":1723}}, {"263":{"x": -922, "val":"Aa", "y":1821}}, {"264":{"x": -1984, "val":"Cl", "y":682}}, {"265":{"x": -2207, "val":"Cc", "y":1571}}, {"266":{"x": -2048, "val":"V", "y":810}}, {"267":{"x": -635, "val":"Aa", "y":2008}}, {"268":{"x": -2088, "val":"Hd", "y":1757}}, {"269":{"x": -1942, "val":"Cl", "y":1814}}, {"270":{"x": -667, "val":"V", "y":1669}}, {"271":{"x": -1479, "val":"G", "y":1881}}, {"272":{"x": -1384, "val":"Gc", "y":2008}}, {"273":{"x": -1129, "val":"G", "y":1804}}, {"274":{"x": -490, "val":"I4", "y":1948}}, {"275":{"x": -1680, "val":"Aa", "y":1535}}, {"276":{"x": -1526, "val":"Aa", "y":1590}}, {"277":{"x": -1462, "val":"I6", "y":1735}}, {"278":{"x": -1297, "val":"Hd", "y":1774}}, {"279":{"x": -2328, "val":"Gb", "y":852}}, {"280":{"x": -1084, "val":"I2", "y":1058}}, {"281":{"x":751, "val":"Md", "y": -1979}}, {"282":{"x":370, "val":"Cl", "y": -1645}}, {"283":{"x":237, "val":"Cc", "y": -1735}}, {"284":{"x":997, "val":"Cl", "y": -1722}}, {"285":{"x":882, "val":"Cd", "y": -1818}}, {"286":{"x":816, "val":"Md", "y": -1497}}, {"287":{"x":847, "val":"V", "y": -1689}}, {"288":{"x":1100, "val":"Pt", "y": -1619}}, {"289":{"x":1100, "val":"Cc", "y": -1497}}, {"290":{"x":1228, "val":"I2", "y": -1156}}, {"291":{"x":78, "val":"qG", "y":1405}}, {"292":{"x":356, "val":"qHd", "y":1542}}, {"293":{"x":353, "val":"Q89", "y":841}}, {"294":{"x":633, "val":"qH", "y":970}}, {"295":{"x":180, "val":"qBg", "y":847}}, {"296":{"x":892, "val":"Q84", "y":1291}}, {"297":{"x":752, "val":"qCd", "y":101}}, {"298":{"x":544, "val":"qBd", "y":1178}}, {"299":{"x":748, "val":"qH", "y":1412}}, {"300":{"x":1020, "val":"Q82", "y":764}}, {"301":{"x":1222, "val":"qHd", "y":999}}, {"303":{"x":1348, "val":"Q85", "y":1342}}, {"304":{"x":1622, "val":"qCl", "y":261}}, {"305":{"x":616, "val":"qTg", "y":1823}}, {"306":{"x":741, "val":"qIr", "y":2106}}, {"307":{"x":1178, "val":"qH", "y":1572}}, {"308":{"x":1317, "val":"qMu", "y":1848}}, {"309":{"x":697, "val":"qBc", "y":1034}}, {"310":{"x":1330, "val":"qBd", "y":2273}}, {"311":{"x":1972, "val":"qHd", "y":1389}}, {"312":{"x":872, "val":"qH", "y":889}}, {"313":{"x":896, "val":"qHd", "y":712}}, {"314":{"x":858, "val":"qH", "y":548}}, {"315":{"x":1491, "val":"qBd", "y":946}}, {"316":{"x":1632, "val":"Aa", "y":125}}, {"317":{"x":1592, "val":"Hd", "y":1058}}, {"318":{"x":983, "val":"Cd", "y":1475}}, {"319":{"x":1463, "val":"H", "y":1840}}, {"320":{"x":1660, "val":"Bc", "y":1684}}, {"321":{"x":1293, "val":"Cl", "y":2044}}, {"322":{"x":864, "val":"Aa", "y":2158}}, {"323":{"x":1068, "val":"V", "y":1370}}, {"324":{"x":624, "val":"Aa", "y":19}}, {"325":{"x":1861, "val":"Mu", "y":1871}}, {"326":{"x":1595, "val":"Q83", "y":608}}, {"327":{"x":1704, "val":"I6", "y":710}}, {"328":{"x":1774, "val":"Cd", "y":258}}, {"329":{"x":1799, "val":"Aa", "y":716}}, {"330":{"x":1757, "val":"Cd", "y":845}}, {"331":{"x":1645, "val":"Md", "y":931}}, {"332":{"x":1050, "val":"Pa", "y":183}}, {"333":{"x":1645, "val":"Bd", "y":483}}, {"334":{"x":643, "val":"Md", "y":542}}, {"335":{"x":1325, "val":"Cd", "y":183}}, {"336":{"x":1183, "val":"I7", "y":226}}, {"337":{"x":113, "val":"V", "y":1224}}, {"338":{"x":1033, "val":"Q88", "y":1975}}, {"339":{"x":743, "val":"I8", "y":454}}, {"340":{"x":421, "val":"Cd", "y":464}}, {"341":{"x":332, "val":"Cl", "y":1232}}, {"342":{"x":475, "val":"V", "y":725}}, {"343":{"x":1017, "val":"Mu", "y":471}}, {"344":{"x":1564, "val":"En", "y":799}}, {"345":{"x":66, "val":"I2", "y":1543}}, {"346":{"x":180, "val":"Gp", "y":1621}}, {"347":{"x":319, "val":"Bc", "y":1672}}, {"348":{"x":763, "val":"H", "y":1755}}, {"349":{"x":868, "val":"Bd", "y":1644}}, {"350":{"x":1079, "val":"Mu", "y":2271}}, {"351":{"x":1472, "val":"Pt", "y":131}}, {"352":{"x":1168, "val":"V", "y":730}}, {"353":{"x":988, "val":"V", "y":2186}}, {"354":{"x":1582, "val":"I1", "y":1579}}, {"355":{"x":942, "val":"H", "y":1877}}, {"356":{"x":1525, "val":"Aa", "y":1211}}, {"357":{"x":1471, "val":"Ea", "y":2229}}, {"358":{"x":1031, "val":"Mu", "y":1134}}, {"359":{"x":2003, "val":"G", "y":1517}}, {"360":{"x":1393, "val":"Bd", "y":1191}}, {"361":{"x":1167, "val":"H", "y":1149}}, {"362":{"x":1981, "val":"Cl", "y":1650}}, {"363":{"x":1881, "val":"Aa", "y":1740}}, {"364":{"x":1312, "val":"V", "y":1619}}, {"365":{"x":1918, "val":"I5", "y":1254}}, {"366":{"x": -38, "val":"Gb", "y":1307}}, {"367":{"x":586, "val":"Hd", "y":447}}, {"368":{"x":908, "val":"Cl", "y":386}}, {"369":{"x":1452, "val":"Mu", "y":1634}}, {"370":{"x":1184, "val":"I6", "y":1423}}, {"371":{"x":1213, "val":"I8", "y":1935}}, {"372":{"x":205, "val":"G", "y":662}}, {"373":{"x":1785, "val":"Mu", "y":1299}}, {"374":{"x":752, "val":"Cl", "y":790}}, {"375":{"x":612, "val":"Mu", "y":845}}, {"376":{"x":611, "val":"H", "y":698}}, {"377":{"x":349, "val":"Tc", "y":1985}}, {"378":{"x":306, "val":"Aa", "y":1843}}, {"379":{"x":601, "val":"Tg", "y":2117}}, {"380":{"x":1155, "val":"H", "y":593}}, {"381":{"x":180, "val":"Bg", "y":1764}}, {"382":{"x":1897, "val":"H", "y":1100}}, {"383":{"x":1844, "val":"Bd", "y":958}}, {"384":{"x":1505, "val":"H", "y":469}}, {"385":{"x":1402, "val":"Mu", "y":540}}, {"386":{"x":1304, "val":"Bc", "y":634}}, {"387":{"x":1011, "val":"Aa", "y":951}}, {"388":{"x":931, "val":"Cl", "y":1050}}, {"389":{"x":1297, "val":"Cl", "y":829}}, {"390":{"x":1003, "val":"Bd", "y":613}}, {"391":{"x":1419, "val":"I4", "y":737}}, {"392":{"x":1046, "val":"Hd", "y":1632}}, {"393":{"x":14, "val":"Tc", "y":1032}}, {"394":{"x":478, "val":"Hd", "y":985}}, {"395":{"x":323, "val":"Bd", "y":970}}, {"396":{"x":716, "val":"H", "y":1211}}, {"397":{"x":1075, "val":"G", "y":2096}}, {"398":{"x":1006, "val":"Mr", "y":1248}}, {"399":{"x":1590, "val":"I7", "y":2147}}, {"400":{"x":470, "val":"I4", "y":1457}}, {"401":{"x":582, "val":"G", "y":1538}}, {"402":{"x":723, "val":"Cl", "y":1570}}, {"403":{"x":45, "val":"I1", "y":903}}, {"404":{"x":1634, "val":"Cl", "y":1328}}, {"405":{"x":363, "val":"Aa", "y":1104}}, {"406":{"x":456, "val":"Mt", "y":1282}}, {"407":{"x":813, "val":"I3", "y":1110}}, {"408":{"x":1785, "val":"qH", "y":1647}}, {"409":{"x":125, "val":"Tg", "y":782}}, {"410":{"x":903, "val":"Cc", "y":120}}, {"411":{"x": -50, "val":"Gc", "y":1447}}, {"412":{"x":608, "val":"Bc", "y":1304}}, {"413":{"x":1445, "val":"Cl", "y":1071}}, {"414":{"x":1227, "val":"Hd", "y":1728}}, {"415":{"x":1304, "val":"Bd", "y":1479}}, {"416":{"x":484, "val":"I3", "y":2023}}, {"417":{"x":175, "val":"H", "y":944}}, {"418":{"x":338, "val":"I5", "y":710}}, {"419":{"x": -13, "val":"Ir", "y":1166}}, {"420":{"x":1145, "val":"G", "y":884}}, {"421":{"x":1157, "val":"Hd", "y":1272}}, {"422":{"x":219, "val":"Ra", "y":1313}}, {"423":{"x":1597, "val":"Hd", "y":1792}}, {"424":{"x":344, "val":"H", "y":1381}}, {"425":{"x":1297, "val":"I2", "y":1106}}, {"426":{"x":1125, "val":"H", "y":1833}}, {"427":{"x":1526, "val":"Cd", "y":1461}}, {"428":{"x":207, "val":"Q87", "y":1123}}, {"429":{"x":856, "val":"Mu", "y":1507}}, {"430":{"x":435, "val":"Bd", "y":599}}, {"431":{"x":466, "val":"G", "y":1860}}, {"432":{"x":969, "val":"Aa", "y":1741}}, {"433":{"x":1667, "val":"V", "y":2041}}, {"434":{"x":750, "val":"H", "y":631}}, {"435":{"x":1201, "val":"Aa", "y":2300}}, {"436":{"x":1410, "val":"G", "y":2118}}, {"437":{"x":1741, "val":"V", "y":586}}, {"438":{"x":1775, "val":"Bd", "y":1968}}, {"439":{"x":1487, "val":"V", "y":1339}}, {"440":{"x":1477, "val":"qHd", "y":631}}, {"441":{"x":602, "val":"qH", "y": -742}}, {"442":{"x":596, "val":"qBd", "y": -2083}}, {"443":{"x":259, "val":"Q63", "y": -1877}}, {"444":{"x":728, "val":"Q64", "y": -1623}}, {"445":{"x":502, "val":"qBd", "y": -1850}}, {"446":{"x":507, "val":"qMd", "y": -1622}}, {"447":{"x":845, "val":"qCd", "y": -1350}}, {"448":{"x":1225, "val":"qCd", "y": -627}}, {"449":{"x":1577, "val":"qCd", "y": -1435}}, {"450":{"x":848, "val":"qCl", "y": -1120}}, {"451":{"x":1080, "val":"qCd", "y": -1120}}, {"452":{"x":1454, "val":"Q61", "y": -628}}, {"453":{"x":729, "val":"qCd", "y": -1845}}, {"454":{"x":1078, "val":"qMd", "y": -1347}}, {"455":{"x":1224, "val":"Q66", "y": -850}}, {"456":{"x":1453, "val":"qMd", "y": -851}}, {"457":{"x":201, "val":"qEn", "y": -1986}}, {"458":{"x":299, "val":"qMr", "y": -1527}}, {"459":{"x":584, "val":"qHd", "y": -597}}, {"460":{"x":920, "val":"qGb", "y": -1938}}, {"461":{"x":1895, "val":"qIr", "y": -1522}}, {"462":{"x":778, "val":"Q62", "y": -990}}, {"463":{"x":1262, "val":"Q65", "y": -1348}}, {"464":{"x":1378, "val":"qMu", "y": -146}}, {"465":{"x":1861, "val":"qH", "y": -520}}, {"466":{"x":347, "val":"qMt", "y": -1138}}, {"467":{"x":1339, "val":"qG", "y": -1759}}, {"468":{"x":1018, "val":"qBd", "y": -663}}, {"469":{"x":1487, "val":"qCl", "y": -1043}}, {"470":{"x":1624, "val":"qBd", "y": -347}}, {"471":{"x": -2337, "val":"Q27", "y": -908}}, {"472":{"x": -1994, "val":"Q26", "y": -565}}, {"474":{"x": -1415, "val":"qMt", "y": -1142}}, {"475":{"x": -1152, "val":"Q24", "y": -692}}, {"476":{"x": -2227, "val":"qBd", "y": -1744}}, {"477":{"x": -650, "val":"qCd", "y": -2256}}, {"478":{"x": -2328, "val":"qGc", "y": -586}}, {"479":{"x": -1980, "val":"qIr", "y": -244}}, {"480":{"x": -2169, "val":"qMt", "y": -741}}, {"481":{"x": -1406, "val":"qMr", "y": -820}}, {"482":{"x": -1143, "val":"qTg", "y": -370}}, {"483":{"x": -2217, "val":"Q21", "y": -1422}}, {"484":{"x": -623, "val":"Q28", "y": -1912}}, {"485":{"x": -2317, "val":"Q23", "y": -359}}, {"486":{"x": -1946, "val":"qBg", "y": -40}}, {"487":{"x": -2205, "val":"qGp", "y": -467}}, {"488":{"x": -1395, "val":"Q25", "y": -593}}, {"489":{"x": -1132, "val":"qG", "y": -143}}, {"490":{"x": -2207, "val":"qGp", "y": -1195}}, {"491":{"x": -609, "val":"qMd", "y": -1785}}, {"492":{"x": -1866, "val":"qGc", "y": -1543}}, {"493":{"x": -1932, "val":"qEn", "y": -1285}}, {"495":{"x": -757, "val":"qBd", "y": -1890}}, {"496":{"x": -759, "val":"qCl", "y": -1740}}, {"497":{"x": -877, "val":"qBd", "y": -924}}, {"498":{"x": -1349, "val":"qEn", "y": -2024}}, {"499":{"x": -897, "val":"Q22", "y": -1473}}, {"500":{"x": -887, "val":"qCd", "y": -1151}}, {"501":{"x": -2468, "val":"Cd", "y": -492}}, {"502":{"x": -2449, "val":"I6", "y": -614}}, {"503":{"x": -2475, "val":"Mu", "y": -746}}, {"504":{"x": -2473, "val":"Aa", "y": -878}}, {"505":{"x": -1813, "val":"I3", "y": -54}}, {"506":{"x": -1827, "val":"Mr", "y": -181}}, {"507":{"x": -1707, "val":"Aa", "y": -321}}, {"508":{"x": -1598, "val":"Ra", "y": -423}}, {"509":{"x": -2123, "val":"Hd", "y": -1317}}, {"510":{"x": -1861, "val":"V", "y": -309}}, {"511":{"x": -1469, "val":"Bg", "y": -111}}, {"512":{"x": -1841, "val":"En", "y": -431}}, {"513":{"x": -1822, "val":"I5", "y": -561}}, {"514":{"x": -1888, "val":"V", "y": -670}}, {"515":{"x": -2109, "val":"Gp", "y": -230}}, {"516":{"x": -2122, "val":"Aa", "y": -344}}, {"517":{"x": -2035, "val":"V", "y": -776}}, {"518":{"x": -1911, "val":"Gc", "y": -840}}, {"519":{"x": -2199, "val":"Pt", "y": -905}}, {"520":{"x": -2442, "val":"I8", "y": -1008}}, {"521":{"x": -2437, "val":"Cc", "y": -372}}, {"522":{"x": -2396, "val":"V", "y": -251}}, {"523":{"x": -2420, "val":"Pt", "y": -1126}}, {"524":{"x": -2398, "val":"Aa", "y": -1248}}, {"525":{"x": -2346, "val":"Pa", "y": -1372}}, {"526":{"x": -2337, "val":"G", "y": -1505}}, {"527":{"x": -2075, "val":"Cd", "y": -1781}}, {"528":{"x": -2068, "val":"Cd", "y": -651}}, {"529":{"x": -2184, "val":"Cc", "y": -593}}, {"530":{"x": -1823, "val":"H", "y": -1674}}, {"531":{"x": -2114, "val":"I1", "y": -1520}}, {"532":{"x": -1883, "val":"Md", "y": -1409}}, {"533":{"x": -2028, "val":"V", "y": -1410}}, {"534":{"x": -740, "val":"Mr", "y": -1517}}, {"535":{"x": -1921, "val":"Ir", "y": -1793}}, {"536":{"x": -1448, "val":"I2", "y": -447}}, {"537":{"x": -1669, "val":"Mt", "y": -569}}, {"538":{"x": -1363, "val":"G", "y": -317}}, {"539":{"x": -1297, "val":"V", "y": -174}}, {"540":{"x": -1264, "val":"Gp", "y": -465}}, {"541":{"x": -1010, "val":"Tc", "y": -216}}, {"542":{"x": -938, "val":"Tg", "y": -341}}, {"543":{"x": -1538, "val":"Gp", "y": -638}}, {"544":{"x": -1619, "val":"Cc", "y": -759}}, {"545":{"x": -2240, "val":"G", "y": -239}}, {"546":{"x": -1069, "val":"V", "y": -814}}, {"547":{"x": -2275, "val":"Bd", "y": -811}}, {"548":{"x": -1681, "val":"Aa", "y": -1049}}, {"549":{"x": -1122, "val":"Cl", "y": -946}}, {"550":{"x": -1270, "val":"Ea", "y": -883}}, {"551":{"x": -1521, "val":"Aa", "y": -1249}}, {"552":{"x": -1787, "val":"Mu", "y": -776}}, {"553":{"x": -2202, "val":"Aa", "y": -1024}}, {"554":{"x": -2300, "val":"Ra", "y": -1104}}, {"555":{"x": -1820, "val":"Ea", "y": -1086}}, {"556":{"x": -1804, "val":"Mr", "y": -1220}}, {"557":{"x": -1711, "val":"En", "y": -903}}, {"558":{"x": -1552, "val":"Cd", "y": -874}}, {"559":{"x": -1611, "val":"Aa", "y": -1344}}, {"560":{"x": -1659, "val":"I2", "y": -1184}}, {"561":{"x": -1459, "val":"Bd", "y": -1515}}, {"562":{"x": -1593, "val":"V", "y": -1480}}, {"563":{"x": -2064, "val":"I7", "y": -907}}, {"564":{"x": -1931, "val":"Gp", "y": -970}}, {"565":{"x": -1960, "val":"V", "y": -1108}}, {"566":{"x": -1439, "val":"Aa", "y": -1370}}, {"567":{"x": -1287, "val":"Ra", "y": -1413}}, {"568":{"x": -1758, "val":"Gp", "y": -1345}}, {"569":{"x": -1644, "val":"Ir", "y": -70}}, {"570":{"x": -985, "val":"Mt", "y": -1863}}, {"571":{"x": -1033, "val":"Pa", "y": -2061}}, {"572":{"x": -980, "val":"En", "y": -1720}}, {"573":{"x": -738, "val":"I7", "y": -1196}}, {"574":{"x": -888, "val":"I5", "y": -1979}}, {"575":{"x": -798, "val":"Gp", "y": -2087}}, {"576":{"x": -614, "val":"Pa", "y": -1444}}, {"577":{"x": -525, "val":"Pt", "y": -1564}}, {"578":{"x": -474, "val":"I6", "y": -1708}}, {"579":{"x": -651, "val":"Aa", "y": -2110}}, {"580":{"x": -505, "val":"V", "y": -2012}}, {"581":{"x": -453, "val":"Cd", "y": -1857}}, {"582":{"x": -430, "val":"Cc", "y": -2128}}, {"583":{"x": -505, "val":"Md", "y": -2227}}, {"584":{"x": -796, "val":"Aa", "y": -2225}}, {"585":{"x": -934, "val":"Pt", "y": -2168}}, {"586":{"x": -866, "val":"V", "y": -1621}}, {"587":{"x": -2092, "val":"Tc", "y": -47}}, {"588":{"x": -1106, "val":"G", "y": -1647}}, {"589":{"x": -2331, "val":"I4", "y": -141}}, {"590":{"x": -1204, "val":"V", "y": -1141}}, {"591":{"x": -1302, "val":"Mu", "y": -1625}}, {"592":{"x": -770, "val":"Cc", "y": -789}}, {"593":{"x": -1488, "val":"H", "y": -1951}}, {"594":{"x": -1303, "val":"En", "y": -1237}}, {"595":{"x": -1275, "val":"Mt", "y": -1023}}, {"596":{"x": -1690, "val":"I3", "y": -1728}}, {"597":{"x": -2290, "val":"Cl", "y": -1632}}, {"598":{"x": -2236, "val":"Tg", "y": -75}}, {"599":{"x": -2347, "val":"Bc", "y": -706}}, {"600":{"x": -1190, "val":"Aa", "y": -2067}}, {"601":{"x": -930, "val":"I8", "y": -756}}, {"602":{"x": -1487, "val":"Bc", "y": -1663}}, {"603":{"x": -794, "val":"H", "y": -1372}}, {"604":{"x": -985, "val":"Aa", "y": -1012}}, {"605":{"x": -727, "val":"Cd", "y": -935}}, {"606":{"x": -678, "val":"Aa", "y": -1068}}, {"607":{"x": -1046, "val":"Mr", "y": -1162}}, {"608":{"x": -660, "val":"Aa", "y": -1304}}, {"609":{"x": -1315, "val":"Aa", "y": -710}}, {"610":{"x": -1246, "val":"Gc", "y": -595}}, {"611":{"x": -1379, "val":"V", "y": -1753}}, {"612":{"x": -1189, "val":"I4", "y": -1522}}, {"613":{"x": -1039, "val":"Hd", "y": -1513}}, {"614":{"x": -2082, "val":"Ea", "y": -442}}, {"615":{"x": -1331, "val":"Gc", "y": -1887}}, {"616":{"x": -1621, "val":"Ea", "y": -1615}}, {"617":{"x": -1599, "val":"Bd", "y": -1841}}, {"618":{"x": -1019, "val":"I1", "y": -442}}, {"619":{"x": -893, "val":"G", "y": -535}}, {"620":{"x": -809, "val":"En", "y": -654}}, {"621":{"x":1567, "val":"Ra", "y": -1677}}, {"622":{"x":1492, "val":"Pt", "y": -1553}}, {"623":{"x":1186, "val":"Md", "y": -1757}}, {"624":{"x":1248, "val":"Bd", "y": -1605}}, {"625":{"x":1317, "val":"V", "y": -1480}}, {"626":{"x":1248, "val":"Cc", "y": -976}}, {"627":{"x":1363, "val":"Pa", "y": -1234}}, {"628":{"x":1528, "val":"Hd", "y": -1288}}, {"629":{"x":1440, "val":"I7", "y": -1401}}, {"630":{"x":1633, "val":"Cc", "y": -775}}, {"631":{"x":1583, "val":"I1", "y": -914}}, {"632":{"x":1453, "val":"Hd", "y": -292}}, {"633":{"x":1727, "val":"Aa", "y": -460}}, {"634":{"x":812, "val":"Bd", "y": -360}}, {"635":{"x":389, "val":"Pt", "y": -1773}}, {"636":{"x":957, "val":"I8", "y": -416}}, {"637":{"x":1017, "val":"Cl", "y": -532}}, {"638":{"x":1336, "val":"Ir", "y": -835}}, {"639":{"x":1370, "val":"Cd", "y": -963}}, {"640":{"x":1338, "val":"V", "y": -704}}, {"641":{"x":201, "val":"Aa", "y":2261}}, {"642":{"x":346, "val":"Bc", "y":2249}}, {"643":{"x":454, "val":"Cc", "y": -1229}}, {"644":{"x":956, "val":"G", "y": -1214}}, {"645":{"x":1104, "val":"Cl", "y": -1241}}, {"646":{"x":1339, "val":"V", "y": -1083}}, {"647":{"x":933, "val":"I5", "y": -1583}}, {"648":{"x":1489, "val":"Cl", "y": -740}}, {"649":{"x":605, "val":"Aa", "y": -1727}}, {"650":{"x":615, "val":"Pa", "y": -1869}}, {"651":{"x":968, "val":"Cd", "y": -1453}}, {"652":{"x":1076, "val":"Bd", "y": -825}}, {"653":{"x":1189, "val":"I6", "y": -743}}, {"654":{"x":1472, "val":"H", "y": -429}}, {"655":{"x":1730, "val":"Pt", "y": -878}}, {"656":{"x":1480, "val":"Md", "y": -1163}}, {"657":{"x":525, "val":"Aa", "y": -1977}}, {"658":{"x":1457, "val":"I6", "y": -1836}}, {"659":{"x":520, "val":"Cl", "y": -1088}}, {"660":{"x":468, "val":"Bd", "y": -217}}, {"661":{"x":524, "val":"H", "y": -87}}, {"662":{"x":1314, "val":"Cd", "y": -8}}, {"663":{"x":1206, "val":"Mu", "y":81}}, {"664":{"x":1904, "val":"Cd", "y": -130}}, {"665":{"x":1912, "val":"Md", "y":7}}, {"666":{"x":1858, "val":"H", "y":138}}, {"667":{"x": -653, "val":"Cd", "y": -1650}}, {"668":{"x": -25, "val":"Md", "y": -1687}}, {"669":{"x": -2199, "val":"Gc", "y": -156}}, {"670":{"x": -2551, "val":"Bd", "y":362}}, {"671":{"x":54, "val":"Ir", "y":1742}}, {"672":{"x": -61, "val":"Hd", "y":1659}}, {"673":{"x": -2469, "val":"Gp", "y":249}}, {"674":{"x":559, "val":"Cd", "y": -346}}, {"35":{"x":15743, "val":"A00", "y": -127}}, {"18":{"x":15743, "val":"A39", "y": -2}}, {"825":{"x":15743, "val":"A21", "y": -237}}, {"790":{"x":15743, "val":"A20", "y": -352}}, {"845":{"x":15743, "val":"A26", "y": -455}}, {"32":{"x":15631, "val":"A05", "y": -61}}, {"28":{"x":15634, "val":"A08", "y": -192}}, {"828":{"x":15847, "val":"S25", "y": -190}}, {"21":{"x":15849, "val":"A02", "y": -62}}, {"20":{"x":15526, "val":"A07", "y": -261}}, {"801":{"x":15963, "val":"S24", "y": -263}}, {"811":{"x":16067, "val":"S23", "y": -329}}, {"819":{"x":15952, "val":"S03", "y":3}}, {"799":{"x":15527, "val":"S62", "y":3}}, {"791":{"x":15638, "val":"A22", "y": -542}}, {"787":{"x":15849, "val":"A28", "y": -541}}, {"778":{"x":15638, "val":"A23", "y": -638}}, {"822":{"x":15638, "val":"A24", "y": -733}}, {"779":{"x":15849, "val":"A29", "y": -639}}, {"788":{"x":15849, "val":"S64", "y": -733}}, {"829":{"x":15743, "val":"A25", "y": -830}}, {"818":{"x":16078, "val":"S22", "y": -423}}, {"807":{"x":16093, "val":"S01", "y": -533}}, {"813":{"x":16175, "val":"S02", "y": -591}}, {"783":{"x":16258, "val":"S10", "y": -641}}, {"805":{"x":16361, "val":"S09", "y": -631}}, {"827":{"x":16443, "val":"S20", "y": -623}}, {"856":{"x":16432, "val":"S27", "y": -516}}, {"848":{"x":16420, "val":"S17", "y": -413}}, {"843":{"x":16339, "val":"S08", "y": -357}}, {"820":{"x":16266, "val":"S07", "y": -309}}, {"782":{"x":16164, "val":"S21", "y": -319}}, {"826":{"x":15055, "val":"S73", "y":382}}, {"781":{"x":15062, "val":"S72", "y":280}}, {"812":{"x":15073, "val":"S71", "y":178}}, {"806":{"x":15153, "val":"S70", "y":118}}, {"809":{"x":15234, "val":"S69", "y":64}}, {"824":{"x":15337, "val":"S68", "y":70}}, {"808":{"x":15419, "val":"S63", "y":76}}, {"821":{"x":15335, "val":"S81", "y":325}}, {"802":{"x":15262, "val":"S82", "y":389}}, {"800":{"x":15161, "val":"S83", "y":385}}, {"846":{"x":15034, "val":"A13", "y": -591}}, {"832":{"x":15119, "val":"S58", "y": -607}}, {"836":{"x":15228, "val":"S60", "y": -628}}, {"816":{"x":15310, "val":"S59", "y": -570}}, {"814":{"x":15384, "val":"A12", "y": -508}}, {"25":{"x":15408, "val":"S51", "y": -416}}, {"16":{"x":15427, "val":"A04", "y": -326}}, {"19":{"x":15323, "val":"S52", "y": -303}}, {"38":{"x":15222, "val":"A06", "y": -280}}, {"23":{"x":15142, "val":"S66", "y": -339}}, {"31":{"x":15074, "val":"S67", "y": -392}}, {"840":{"x":15051, "val":"S57", "y": -493}}, {"833":{"x":16061, "val":"S05", "y":77}}, {"797":{"x":16154, "val":"S04", "y":67}}, {"777":{"x":16265, "val":"S14", "y":57}}, {"776":{"x":16340, "val":"S13", "y":124}}, {"815":{"x":16408, "val":"S11", "y":194}}, {"796":{"x":16422, "val":"S12", "y":287}}, {"795":{"x":16432, "val":"S61", "y":378}}, {"857":{"x":16326, "val":"S84", "y":390}}, {"786":{"x":16223, "val":"S65", "y":402}}, {"792":{"x":16149, "val":"S15", "y":336}}, {"785":{"x":16085, "val":"S16", "y":276}}, {"775":{"x":16073, "val":"S06", "y":174}}, {"22":{"x":15743, "val":"A39", "y":129}}, {"27":{"x":15814, "val":"A39", "y":196}}, {"17":{"x":15890, "val":"A38", "y":275}}, {"36":{"x":15890, "val":"A39", "y":375}}, {"830":{"x":15889, "val":"A37", "y":472}}, {"34":{"x":15824, "val":"A39", "y":538}}, {"784":{"x":15755, "val":"A39", "y":605}}, {"794":{"x":15679, "val":"A39", "y":538}}, {"834":{"x":15611, "val":"A36", "y":471}}, {"798":{"x":15610, "val":"A39", "y":375}}, {"29":{"x":15612, "val":"A38", "y":280}}, {"823":{"x":15680, "val":"A39", "y":202}}, {"841":{"x":15264, "val":"A14", "y": -346}}, {"842":{"x":15194, "val":"S55", "y": -398}}, {"835":{"x":15121, "val":"S56", "y": -455}}, {"839":{"x":15339, "val":"A11", "y": -446}}, {"838":{"x":15270, "val":"S53", "y": -500}}, {"831":{"x":15194, "val":"S54", "y": -554}}, {"864":{"x":16170, "val":"A40", "y": -404}}, {"865":{"x":16181, "val":"A41", "y": -494}}, {"789":{"x":15124, "val":"S74", "y":321}}, {"780":{"x":15144, "val":"S75", "y":236}}, {"817":{"x":15205, "val":"S76", "y":182}}, {"810":{"x":15283, "val":"S77", "y":184}}, {"793":{"x":15266, "val":"S79", "y":264}}, {"803":{"x":15209, "val":"S78", "y":315}}, {"844":{"x":15751, "val":"A39", "y":375}}, {"804":{"x":16149, "val":"A15", "y":140}}, {"859":{"x":16273, "val":"S28", "y": -490}}, {"854":{"x":16263, "val":"S26", "y": -400}}, {"870":{"x":15407, "val":"S80", "y":258}}, {"837":{"x":15413, "val":"S86", "y":163}}, {"871":{"x":15346, "val":"S87", "y":139}}, {"872":{"x":16238, "val":"S85", "y":207}}], "edges":[{"1":[187, 188]}, {"2":[330, 331]}, {"3":[808, 824]}, {"4":[42, 130]}, {"5":[42, 443]}, {"6":[57, 458]}, {"7":[330, 383]}, {"8":[800, 802]}, {"9":[670, 673]}, {"10":[399, 433]}, {"11":[400, 401]}, {"12":[807, 813]}, {"13":[806, 809]}, {"14":[146, 193]}, {"15":[290, 451]}, {"16":[589, 598]}, {"17":[776, 777]}, {"18":[133, 255]}, {"19":[377, 416]}, {"20":[289, 651]}, {"21":[323, 370]}, {"22":[142, 168]}, {"23":[154, 215]}, {"24":[204, 261]}, {"25":[36, 844]}, {"26":[151, 259]}, {"27":[463, 625]}, {"28":[176, 177]}, {"29":[160, 169]}, {"30":[17, 27]}, {"31":[364, 369]}, {"32":[6, 13]}, {"33":[200, 207]}, {"34":[650, 657]}, {"35":[576, 577]}, {"36":[148, 207]}, {"37":[456, 631]}, {"38":[21, 35]}, {"39":[100, 448]}, {"40":[208, 209]}, {"41":[486, 505]}, {"42":[69, 70]}, {"43":[1, 2]}, {"44":[499, 613]}, {"45":[179, 269]}, {"46":[485, 522]}, {"47":[793, 810]}, {"48":[509, 533]}, {"49":[476, 597]}, {"50":[346, 381]}, {"51":[75, 459]}, {"52":[795, 857]}, {"53":[502, 503]}, {"54":[133, 196]}, {"55":[117, 118]}, {"56":[567, 612]}, {"57":[538, 539]}, {"58":[778, 791]}, {"59":[158, 179]}, {"60":[820, 843]}, {"61":[112, 445]}, {"62":[837, 870]}, {"63":[73, 125]}, {"64":[345, 411]}, {"65":[307, 364]}, {"66":[43, 44]}, {"67":[334, 339]}, {"68":[179, 180]}, {"69":[797, 833]}, {"70":[277, 278]}, {"71":[141, 174]}, {"72":[190, 191]}, {"73":[233, 267]}, {"74":[534, 576]}, {"75":[176, 257]}, {"76":[394, 395]}, {"77":[552, 557]}, {"78":[783, 805]}, {"79":[62, 110]}, {"80":[500, 573]}, {"81":[226, 237]}, {"82":[120, 447]}, {"83":[186, 279]}, {"84":[801, 828]}, {"85":[78, 654]}, {"86":[317, 413]}, {"87":[119, 446]}, {"88":[32, 799]}, {"89":[534, 586]}, {"90":[495, 574]}, {"91":[341, 405]}, {"92":[561, 566]}, {"93":[19, 38]}, {"94":[802, 821]}, {"95":[317, 331]}, {"96":[307, 392]}, {"97":[561, 562]}, {"98":[392, 432]}, {"99":[102, 106]}, {"100":[87, 633]}, {"101":[182, 213]}, {"102":[831, 838]}, {"103":[142, 170]}, {"104":[804, 872]}, {"105":[291, 345]}, {"106":[60, 103]}, {"107":[806, 812]}, {"108":[231, 232]}, {"109":[53, 372]}, {"110":[467, 623]}, {"111":[271, 272]}, {"112":[290, 646]}, {"113":[348, 349]}, {"114":[17, 36]}, {"115":[251, 256]}, {"116":[814, 816]}, {"117":[105, 643]}, {"118":[660, 674]}, {"119":[155, 263]}, {"120":[128, 470]}, {"121":[76, 634]}, {"122":[44, 57]}, {"123":[343, 368]}, {"124":[171, 172]}, {"125":[450, 644]}, {"126":[548, 557]}, {"127":[285, 460]}, {"128":[519, 563]}, {"129":[141, 181]}, {"130":[385, 386]}, {"131":[630, 655]}, {"132":[68, 464]}, {"133":[54, 55]}, {"134":[16, 839]}, {"135":[31, 840]}, {"136":[108, 450]}, {"137":[788, 829]}, {"138":[292, 400]}, {"139":[781, 812]}, {"140":[487, 614]}, {"141":[118, 123]}, {"142":[83, 84]}, {"143":[506, 510]}, {"144":[159, 204]}, {"145":[132, 167]}, {"146":[838, 839]}, {"147":[644, 645]}, {"148":[72, 82]}, {"149":[29, 798]}, {"150":[181, 211]}, {"151":[313, 390]}, {"152":[553, 554]}, {"153":[165, 169]}, {"154":[854, 859]}, {"155":[111, 451]}, {"156":[158, 271]}, {"157":[96, 98]}, {"158":[288, 289]}, {"159":[532, 568]}, {"160":[327, 437]}, {"161":[320, 423]}, {"162":[590, 607]}, {"163":[320, 408]}, {"164":[339, 368]}, {"165":[571, 600]}, {"166":[626, 646]}, {"167":[355, 432]}, {"168":[570, 572]}, {"169":[257, 258]}, {"170":[517, 518]}, {"171":[807, 818]}, {"172":[86, 393]}, {"173":[248, 250]}, {"174":[4, 6]}, {"175":[172, 174]}, {"176":[146, 210]}, {"177":[140, 275]}, {"178":[39, 40]}, {"179":[835, 842]}, {"180":[381, 671]}, {"181":[602, 611]}, {"182":[572, 586]}, {"183":[218, 219]}, {"184":[366, 411]}, {"185":[11, 14]}, {"186":[638, 640]}, {"187":[51, 190]}, {"188":[508, 536]}, {"189":[352, 389]}, {"190":[393, 403]}, {"191":[816, 836]}, {"192":[550, 595]}, {"193":[573, 606]}, {"194":[832, 836]}, {"195":[671, 672]}, {"196":[262, 270]}, {"197":[25, 814]}, {"198":[360, 425]}, {"199":[67, 658]}, {"200":[395, 405]}, {"201":[100, 109]}, {"202":[488, 536]}, {"203":[521, 522]}, {"204":[492, 530]}, {"205":[51, 194]}, {"206":[20, 28]}, {"207":[215, 221]}, {"208":[239, 263]}, {"209":[643, 659]}, {"210":[84, 128]}, {"211":[22, 27]}, {"212":[145, 230]}, {"213":[641, 642]}, {"214":[151, 268]}, {"215":[246, 247]}, {"216":[5, 6]}, {"217":[79, 80]}, {"218":[92, 442]}, {"219":[354, 369]}, {"220":[222, 256]}, {"221":[116, 118]}, {"222":[132, 197]}, {"223":[810, 871]}, {"224":[113, 121]}, {"225":[319, 423]}, {"226":[91, 121]}, {"227":[75, 114]}, {"228":[481, 558]}, {"229":[267, 274]}, {"230":[237, 270]}, {"231":[791, 845]}, {"232":[283, 635]}, {"233":[24, 569]}, {"234":[364, 415]}, {"235":[109, 654]}, {"236":[810, 817]}, {"237":[92, 93]}, {"238":[511, 569]}, {"239":[297, 324]}, {"240":[95, 97]}, {"241":[373, 404]}, {"242":[536, 538]}, {"243":[619, 620]}, {"244":[498, 600]}, {"245":[333, 437]}, {"246":[80, 462]}, {"247":[489, 541]}, {"248":[448, 640]}, {"249":[543, 544]}, {"250":[229, 673]}, {"251":[843, 848]}, {"252":[471, 520]}, {"253":[809, 824]}, {"254":[337, 428]}, {"255":[234, 270]}, {"256":[488, 543]}, {"257":[146, 199]}, {"258":[231, 672]}, {"259":[260, 261]}, {"260":[350, 435]}, {"261":[491, 578]}, {"262":[167, 170]}, {"263":[811, 864]}, {"264":[268, 269]}, {"265":[150, 225]}, {"266":[131, 163]}, {"267":[311, 365]}, {"268":[362, 363]}, {"269":[386, 391]}, {"270":[469, 639]}, {"271":[592, 620]}, {"272":[332, 336]}, {"273":[357, 436]}, {"274":[81, 108]}, {"275":[545, 589]}, {"276":[216, 245]}, {"277":[574, 575]}, {"278":[71, 469]}, {"279":[372, 409]}, {"280":[318, 323]}, {"281":[71, 656]}, {"282":[389, 420]}, {"283":[548, 560]}, {"284":[395, 417]}, {"285":[258, 265]}, {"286":[577, 578]}, {"287":[241, 242]}, {"288":[165, 166]}, {"289":[106, 468]}, {"290":[81, 659]}, {"291":[835, 846]}, {"292":[388, 407]}, {"293":[528, 529]}, {"294":[547, 599]}, {"295":[476, 527]}, {"296":[624, 625]}, {"297":[324, 661]}, {"298":[227, 230]}, {"299":[304, 328]}, {"300":[377, 378]}, {"301":[286, 647]}, {"302":[548, 555]}, {"303":[126, 128]}, {"304":[335, 351]}, {"305":[532, 533]}, {"306":[785, 792]}, {"307":[127, 642]}, {"308":[149, 222]}, {"309":[156, 217]}, {"310":[199, 201]}, {"311":[16, 25]}, {"312":[346, 347]}, {"313":[442, 657]}, {"314":[482, 540]}, {"315":[142, 184]}, {"316":[18, 35]}, {"317":[83, 664]}, {"318":[401, 402]}, {"319":[99, 102]}, {"320":[55, 581]}, {"321":[822, 829]}, {"322":[320, 354]}, {"323":[282, 283]}, {"324":[561, 602]}, {"325":[501, 521]}, {"326":[211, 212]}, {"327":[591, 611]}, {"328":[406, 412]}, {"329":[446, 649]}, {"330":[2, 3]}, {"331":[322, 353]}, {"332":[799, 808]}, {"333":[854, 864]}, {"334":[640, 653]}, {"335":[790, 825]}, {"336":[609, 610]}, {"337":[531, 533]}, {"338":[139, 242]}, {"339":[61, 89]}, {"340":[188, 191]}, {"341":[135, 279]}, {"342":[140, 249]}, {"343":[312, 374]}, {"344":[789, 826]}, {"345":[328, 666]}, {"346":[783, 813]}, {"347":[100, 125]}, {"348":[636, 637]}, {"349":[53, 430]}, {"350":[177, 178]}, {"351":[796, 815]}, {"352":[214, 276]}, {"353":[612, 613]}, {"354":[139, 244]}, {"355":[302, 433]}, {"356":[97, 449]}, {"357":[198, 229]}, {"358":[454, 651]}, {"359":[483, 525]}, {"360":[557, 558]}, {"361":[303, 439]}, {"362":[329, 437]}, {"363":[621, 622]}, {"364":[9, 39]}, {"365":[358, 361]}, {"366":[222, 280]}, {"367":[338, 397]}, {"368":[248, 254]}, {"369":[479, 510]}, {"370":[240, 243]}, {"371":[61, 62]}, {"372":[243, 245]}, {"373":[325, 438]}, {"374":[66, 461]}, {"375":[168, 187]}, {"376":[570, 574]}, {"377":[571, 574]}, {"378":[95, 98]}, {"379":[501, 502]}, {"380":[507, 508]}, {"381":[402, 429]}, {"382":[338, 355]}, {"383":[482, 618]}, {"384":[70, 621]}, {"385":[290, 627]}, {"386":[472, 514]}, {"387":[45, 606]}, {"388":[628, 629]}, {"389":[123, 643]}, {"390":[32, 35]}, {"391":[71, 96]}, {"392":[519, 553]}, {"393":[23, 38]}, {"394":[781, 826]}, {"395":[161, 229]}, {"396":[300, 352]}, {"397":[588, 612]}, {"398":[173, 266]}, {"399":[555, 565]}, {"400":[530, 596]}, {"401":[3, 4]}, {"402":[164, 264]}, {"403":[104, 465]}, {"404":[232, 238]}, {"405":[800, 826]}, {"406":[276, 277]}, {"407":[342, 376]}, {"408":[310, 435]}, {"409":[605, 606]}, {"410":[787, 845]}, {"411":[273, 278]}, {"412":[209, 210]}, {"413":[288, 624]}, {"414":[34, 784]}, {"415":[516, 614]}, {"416":[365, 382]}, {"417":[155, 262]}, {"418":[840, 846]}, {"419":[805, 827]}, {"420":[290, 645]}, {"421":[366, 419]}, {"422":[481, 609]}, {"423":[848, 856]}, {"424":[246, 266]}, {"425":[382, 383]}, {"426":[484, 580]}, {"427":[571, 585]}, {"428":[175, 202]}, {"429":[566, 567]}, {"430":[573, 608]}, {"431":[91, 281]}, {"432":[841, 842]}, {"433":[157, 220]}, {"434":[105, 120]}, {"435":[61, 457]}, {"436":[396, 412]}, {"437":[591, 612]}, {"438":[356, 360]}, {"439":[101, 441]}, {"440":[311, 359]}, {"441":[808, 837]}, {"442":[572, 588]}, {"443":[794, 834]}, {"444":[16, 19]}, {"445":[775, 833]}, {"446":[831, 846]}, {"447":[191, 192]}, {"448":[341, 406]}, {"449":[370, 415]}, {"450":[315, 331]}, {"451":[786, 792]}, {"452":[387, 388]}, {"453":[175, 181]}, {"454":[152, 206]}, {"455":[138, 214]}, {"456":[592, 605]}, {"457":[185, 241]}, {"458":[215, 273]}, {"459":[29, 823]}, {"460":[404, 439]}, {"461":[576, 608]}, {"462":[63, 170]}, {"463":[343, 390]}, {"464":[489, 539]}, {"465":[250, 259]}, {"466":[16, 841]}, {"467":[284, 285]}, {"468":[361, 421]}, {"469":[524, 525]}, {"470":[396, 407]}, {"471":[393, 419]}, {"472":[480, 517]}, {"473":[497, 604]}, {"474":[294, 394]}, {"475":[782, 811]}, {"476":[363, 408]}, {"477":[455, 626]}, {"478":[224, 225]}, {"479":[134, 253]}, {"480":[287, 647]}, {"481":[203, 206]}, {"482":[249, 252]}, {"483":[378, 431]}, {"484":[94, 461]}, {"485":[325, 363]}, {"486":[275, 276]}, {"487":[477, 584]}, {"488":[649, 650]}, {"489":[173, 178]}, {"490":[375, 376]}, {"491":[85, 227]}, {"492":[180, 249]}, {"493":[79, 124]}, {"494":[798, 834]}, {"495":[385, 440]}, {"496":[498, 593]}, {"497":[122, 123]}, {"498":[387, 420]}, {"499":[96, 655]}, {"500":[223, 224]}, {"501":[559, 562]}, {"502":[284, 287]}, {"503":[335, 336]}, {"504":[316, 351]}, {"505":[200, 205]}, {"506":[252, 257]}, {"507":[314, 339]}, {"508":[57, 59]}, {"509":[494, 565]}, {"510":[41, 129]}, {"511":[224, 236]}, {"512":[384, 385]}, {"513":[336, 663]}, {"514":[189, 193]}, {"515":[660, 661]}, {"516":[492, 532]}, {"517":[90, 92]}, {"518":[801, 811]}, {"519":[241, 641]}, {"520":[147, 226]}, {"521":[378, 381]}, {"522":[493, 556]}, {"523":[499, 603]}, {"524":[321, 436]}, {"525":[103, 636]}, {"526":[296, 398]}, {"527":[546, 549]}, {"528":[526, 597]}, {"529":[359, 362]}, {"530":[156, 218]}, {"531":[164, 169]}, {"532":[236, 239]}, {"533":[34, 830]}, {"534":[652, 653]}, {"535":[584, 585]}, {"536":[23, 31]}, {"537":[282, 458]}, {"538":[207, 228]}, {"539":[339, 367]}, {"540":[342, 418]}, {"541":[109, 632]}, {"542":[59, 668]}, {"543":[775, 785]}, {"544":[310, 357]}, {"545":[62, 90]}, {"546":[157, 216]}, {"547":[312, 387]}, {"548":[350, 353]}, {"549":[589, 669]}, {"550":[58, 82]}, {"551":[559, 568]}, {"552":[131, 195]}, {"553":[449, 622]}, {"554":[106, 652]}, {"555":[380, 386]}, {"556":[789, 803]}, {"557":[293, 418]}, {"558":[264, 266]}, {"559":[304, 316]}, {"560":[551, 560]}, {"561":[117, 466]}, {"562":[611, 615]}, {"563":[664, 665]}, {"564":[790, 845]}, {"565":[379, 416]}, {"566":[143, 192]}, {"567":[35, 828]}, {"568":[145, 231]}, {"569":[64, 65]}, {"570":[132, 166]}, {"571":[72, 465]}, {"572":[28, 35]}, {"573":[271, 277]}, {"574":[53, 340]}, {"575":[518, 552]}, {"576":[537, 543]}, {"577":[323, 421]}, {"578":[345, 346]}, {"579":[587, 598]}, {"580":[549, 604]}, {"581":[511, 539]}, {"582":[356, 439]}, {"583":[525, 526]}, {"584":[22, 823]}, {"585":[778, 822]}, {"586":[832, 846]}, {"587":[473, 562]}, {"588":[514, 552]}, {"589":[115, 124]}, {"590":[578, 581]}, {"591":[43, 118]}, {"592":[16, 20]}, {"593":[623, 624]}, {"594":[630, 648]}, {"595":[400, 424]}, {"596":[540, 610]}, {"597":[403, 409]}, {"598":[212, 251]}, {"599":[197, 198]}, {"600":[114, 674]}, {"601":[389, 391]}, {"602":[478, 502]}, {"603":[354, 427]}, {"604":[551, 566]}, {"605":[218, 272]}, {"606":[549, 550]}, {"607":[474, 594]}, {"608":[337, 422]}, {"609":[226, 228]}, {"610":[85, 86]}, {"611":[496, 586]}, {"612":[512, 513]}, {"613":[859, 865]}, {"614":[69, 658]}, {"615":[305, 431]}, {"616":[213, 217]}, {"617":[64, 113]}, {"618":[523, 524]}, {"619":[513, 514]}, {"620":[298, 406]}, {"621":[477, 583]}, {"622":[481, 550]}, {"623":[306, 379]}, {"624":[593, 617]}, {"625":[374, 375]}, {"626":[194, 201]}, {"627":[318, 429]}, {"628":[137, 177]}, {"629":[563, 564]}, {"630":[618, 619]}, {"631":[468, 637]}, {"632":[544, 558]}, {"633":[235, 274]}, {"634":[804, 833]}, {"635":[464, 632]}, {"636":[77, 541]}, {"637":[596, 617]}, {"638":[662, 663]}, {"639":[582, 583]}, {"640":[590, 595]}, {"641":[97, 628]}, {"642":[207, 208]}, {"643":[146, 202]}, {"644":[138, 212]}, {"645":[520, 523]}, {"646":[65, 67]}, {"647":[60, 73]}, {"648":[287, 444]}, {"649":[467, 658]}, {"650":[35, 825]}, {"651":[253, 254]}, {"652":[142, 171]}, {"653":[18, 22]}, {"654":[780, 789]}, {"655":[234, 235]}, {"656":[864, 865]}, {"657":[13, 40]}, {"658":[329, 330]}, {"659":[151, 265]}, {"660":[490, 554]}, {"661":[153, 274]}, {"662":[162, 163]}, {"663":[546, 601]}, {"664":[89, 130]}, {"665":[286, 447]}, {"666":[782, 820]}, {"667":[433, 438]}, {"668":[136, 266]}, {"669":[308, 371]}, {"670":[490, 509]}, {"671":[358, 388]}, {"672":[222, 223]}, {"673":[239, 273]}, {"674":[541, 542]}, {"675":[503, 599]}, {"676":[301, 425]}, {"677":[627, 656]}, {"678":[119, 122]}, {"679":[380, 390]}, {"680":[413, 425]}, {"681":[144, 185]}, {"682":[80, 659]}, {"683":[281, 453]}, {"684":[486, 587]}, {"685":[131, 186]}, {"686":[115, 117]}, {"687":[510, 512]}, {"688":[811, 818]}, {"689":[202, 280]}, {"690":[153, 240]}, {"691":[422, 424]}, {"692":[254, 255]}, {"693":[306, 322]}, {"694":[498, 615]}, {"695":[556, 560]}, {"696":[284, 288]}, {"697":[786, 857]}, {"698":[627, 628]}, {"699":[292, 347]}, {"700":[42, 59]}, {"701":[596, 616]}, {"702":[780, 817]}, {"703":[777, 797]}, {"704":[219, 220]}, {"705":[475, 546]}, {"706":[414, 426]}, {"707":[143, 187]}, {"708":[564, 565]}, {"709":[580, 582]}, {"710":[309, 407]}, {"711":[579, 580]}, {"712":[500, 607]}, {"713":[107, 111]}, {"714":[634, 636]}, {"715":[68, 662]}, {"716":[6, 14]}, {"717":[507, 510]}, {"718":[323, 398]}, {"719":[94, 95]}, {"720":[203, 259]}, {"721":[195, 196]}, {"722":[527, 535]}, {"723":[179, 213]}, {"724":[795, 796]}, {"725":[827, 856]}, {"726":[474, 551]}, {"727":[78, 87]}, {"728":[127, 379]}, {"729":[184, 189]}, {"730":[403, 417]}, {"731":[353, 397]}, {"732":[308, 319]}, {"733":[798, 844]}, {"734":[515, 545]}, {"735":[522, 589]}, {"736":[129, 539]}, {"737":[41, 77]}, {"738":[99, 441]}, {"739":[497, 605]}, {"740":[161, 162]}, {"741":[479, 515]}, {"742":[78, 452]}, {"743":[152, 182]}, {"744":[630, 631]}, {"745":[60, 68]}, {"746":[776, 815]}, {"747":[471, 519]}, {"748":[110, 112]}, {"749":[332, 410]}, {"750":[36, 830]}, {"751":[56, 668]}, {"752":[779, 787]}, {"753":[793, 803]}, {"754":[515, 516]}, {"755":[445, 635]}, {"756":[83, 104]}, {"757":[144, 238]}, {"758":[819, 833]}, {"759":[87, 88]}, {"760":[74, 124]}, {"761":[305, 348]}, {"762":[575, 579]}, {"763":[54, 582]}, {"764":[577, 667]}, {"765":[530, 535]}, {"766":[299, 429]}, {"767":[480, 547]}, {"768":[91, 93]}, {"769":[364, 414]}, {"770":[344, 391]}, {"771":[334, 434]}, {"772":[562, 616]}, {"773":[542, 618]}, {"774":[57, 116]}, {"775":[638, 639]}, {"776":[58, 96]}, {"777":[625, 629]}, {"778":[505, 506]}, {"779":[253, 257]}, {"780":[135, 247]}, {"781":[172, 173]}, {"782":[66, 70]}, {"783":[21, 819]}, {"784":[371, 426]}, {"785":[76, 101]}, {"786":[505, 569]}, {"787":[517, 528]}, {"788":[183, 209]}, {"789":[487, 529]}, {"790":[779, 788]}, {"791":[321, 371]}, {"792":[601, 620]}, {"793":[159, 183]}, {"794":[88, 630]}, {"795":[821, 870]}, {"796":[160, 161]}, {"797":[126, 632]}, {"798":[219, 221]}, {"799":[76, 114]}, {"800":[349, 429]}, {"801":[331, 344]}, {"802":[102, 107]}, {"803":[84, 633]}, {"804":[340, 367]}, {"805":[503, 504]}, {"806":[337, 419]}, {"807":[580, 581]}, {"808":[64, 460]}, {"809":[297, 410]}, {"810":[483, 531]}, {"811":[5, 8]}, {"812":[513, 537]}, {"813":[603, 608]}, {"814":[204, 205]}, {"815":[72, 88]}, {"816":[427, 439]}, {"817":[665, 666]}, {"818":[326, 437]}, {"819":[784, 794]}, {"820":[640, 648]}, {"821":[342, 430]}, {"822":[357, 399]}, {"823":[590, 594]}, {"824":[365, 373]}, {"825":[74, 75]}, {"826":[295, 403]}, {"827":[361, 425]}, {"828":[504, 520]}, {"829":[56, 130]}, {"830":[517, 563]}, {"831":[333, 384]}, {"832":[51, 260]}]};
			newCharacter.levelGraph = LevelGraph.loadGraph(newCharacter.levelGraphObject, newCharacter);
			
			Characters.startingDefaultInstances[newCharacter.name] = newCharacter;
			
			var ChallengeAutoAttackstorm:Skill = new Skill();
			ChallengeAutoAttackstorm.modName = MOD_INFO["name"];
			ChallengeAutoAttackstorm.name = "Challenge Autoattackstorm";
			ChallengeAutoAttackstorm.description = "";
			ChallengeAutoAttackstorm.cooldown = 420 * 1000;
			ChallengeAutoAttackstorm.iconId = 201;
			ChallengeAutoAttackstorm.manaCost = 0;
			ChallengeAutoAttackstorm.energyCost = 0;
			ChallengeAutoAttackstorm.consumableOnly = false;
			ChallengeAutoAttackstorm.minimumAscensions = 0;
			ChallengeAutoAttackstorm.effectFunction = challengeAutoAttackstormEffect;
			ChallengeAutoAttackstorm.ignoresGCD = false;
			ChallengeAutoAttackstorm.maximumRange = 9000;
			ChallengeAutoAttackstorm.minimumRange = 0;
			ChallengeAutoAttackstorm.usesMaxEnergy = false;
			ChallengeAutoAttackstorm.tooltipFunction = function():Object{ return this.skillTooltip("Storm: Consumes 2.5 mana per second to auto attack 5 times per second, until you run out of mana. Autoattack damage is doubled while active."); };
			Character.staticSkillInstances[ChallengeAutoAttackstorm.uid] = ChallengeAutoAttackstorm;
		}
		
		override public function onCharacterCreated(characterInstance:Character):void
		{
			if (characterInstance.name == NEW_CHARACTER_NAME)
			{
				callSuperClassFunction(super.onCharacterCreated, characterInstance, characterInstance);
				
				characterInstance.isChallengeCharacter = true;
				characterInstance.monstersPerZone = 5;
				characterInstance.worldsPerSystem = 1;
				characterInstance.hasUnlockedTranscendencePanel = true;
				
				//setup the handlers
				characterInstance.getLevelUpCostToNextLevelHandler = this;
				characterInstance.updateHandler = this;
				characterInstance.onWorldFinishedHandler = this;
				//characterInstance.populateWorldEndAutomationOptionsHandler = this;
				characterInstance.onCharacterLoadedHandler = this;
				characterInstance.getItemDamageHandler = this;
				characterInstance.gainLevelHandler = this;
				characterInstance.onKilledMonsterHandler = this;
				characterInstance.onUsedSkillHandler = this;
				characterInstance.clickAttackHandler = this;
				characterInstance.attackHandler = this;
				characterInstance.autoAttackHandler = this;
				characterInstance.extendedVariables = new ChallengeExtendedVariables();
				characterInstance.readExtendedVariables();
				
				characterInstance.excludedItemStats = [];
				characterInstance.excludedItemStats.push(CH2.STAT_TOTAL_ENERGY.toString());
				characterInstance.energy = 20;
				
				//register the challenge functions
				characterInstance.challengeTimeToDisplayFunction = challengeTimeToDisplayFunction;
				characterInstance.challengeTooltipFunction = challengeTooltipFunction;
				characterInstance.challengeProgressTextDisplayFunction = challengeProgressTextDisplayFunction;
				characterInstance.challengeProgressTooltipFunction = challengeProgressTooltipFunction;
				characterInstance.isChallengeFinishedFunction = isChallengeFinishedFunction;
				characterInstance.getChallengeAchievementTimes = getChallengeAchievementTimes;
				
				//No offline progress allowed
				characterInstance.serverTimeOfLastUpdate = ServerTimeKeeper.instance.timestamp;
				
				//Set the rollers
				characterInstance.startingRollerValue = 7;
				characterInstance.roller.initialize(characterInstance.startingRollerValue);
			}
		}
		
		private var ranFirstUpdate:Boolean = false;
		public function onCharacterLoadedOverride():void
		{
			ranFirstUpdate = false;
			CH2.currentCharacter.onCharacterLoadedDefault();
			CH2.currentAscensionWorld.theme.id = 7;
		}
		
		private function setTranscensionPerkLevel(perkId:int, level:int):void
		{
			if (!CH2.currentCharacter.transcensionPerkLevels[perkId])
			{
				CH2.currentCharacter.transcensionPerkLevels[perkId] = 0;
			}
			while (CH2.currentCharacter.transcensionPerkLevels[perkId] < level)
			{
				CH2.currentCharacter.transcensionPerks[perkId].levelFunction();
				CH2.currentCharacter.transcensionPerkLevels[perkId] += 1;
			}
		}
		
		public function updateOverride(dt:int):void
		{
			if (!ranFirstUpdate)
			{
				onCharacterFullyInitialized(); 
				ranFirstUpdate = true;
				CH2.currentCharacter.updateDefault(0);
			}
			if (isChallengeFinishedFunction()) return;
			if (!CH2.currentCharacter.extendedVariables["isStarted"]) return;
			
			CH2.currentCharacter.updateDefault(dt);
			
			if (MiscUtils.requiresUpdate(10000, dt))
			{
				//prevent ruby shop from showing up
				CH2.currentCharacter.timeSinceRegularMonsterHasDroppedRubies = 0;
				CH2.currentCharacter.timeSinceLastRubyShopAppearance = 0;
				//CH2UI.instance.mainUI.hud.hudTop.challengeUI
			}
		}
		
		private function onChallengeClickActivate():Boolean
		{
			CH2.currentCharacter.clickAttack();
			return true;
		}
		
		
		override protected function unlockAutomator():void 
		{
			CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_16", 10000);
			CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_11", 4000);
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_223", "Perform a click", 1, "Performs a single click that cost no energy.", onChallengeClickActivate, function() { return true; }, 0);
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_223", "Perform a click", 1, "Performs a single click that cost no energy.", onChallengeClickActivate, function() { return true; }, 0);
		}
		
		override protected function purchaseAutomator():void 
		{
			CH2.currentCharacter.onAutomatorUnlocked();
			CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_223");
			CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_223");
			CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_16");
			CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_11");
			
			if (CH2.currentCharacter.gilds > 0 ) 
			{
				CH2.currentCharacter.automatorPoints++;
			}
		}
		
		var hasHugeClick:Boolean = false; 
		
		public function clickAttackOverride(doesCostEnergy:Boolean):void
		{
			//absolute jank
			if (CH2.currentCharacter.buffs.hasBuffByName("Huge Click"))
			{
				hasHugeClick = true;
			}
			
			if (!CH2.currentCharacter.extendedVariables["isStarted"])
			{
				CH2.currentCharacter.extendedVariables["isStarted"] = true;
			}
			
			CH2.currentCharacter.clickAttackDefault(false);

			CH2.currentCharacter.addEnergy(2);
	
			if (CH2.currentCharacter.getTrait("Reinvigorate"))
				var reduceExhaustion:Boolean =  CH2.roller.attackRoller.boolean((CH2.currentCharacter.hasteRating) * .03);
			{
				
				if (reduceExhaustion && CH2.currentCharacter.buffs.hasBuffByName("Exhaustion"))
				{
					CH2.currentCharacter.buffs.removeBuff("Exhaustion");
				}
			}
		}
		
		public function onUsedSkillOverride(skill:Skill):void
		{
			if (!CH2.currentCharacter.extendedVariables["isStarted"])
			{
				CH2.currentCharacter.extendedVariables["isStarted"] = true;
			}
			
			CH2.currentCharacter.onUsedSkillDefault(skill);
		}
		
		private function onCharacterFullyInitialized():void
		{
			//Purchases starting nodes declared in gildStartBuild
			if (CH2.currentCharacter.nodesPurchased)
			{
				for (var i:int = 0; i < CH2.currentCharacter.gildStartBuild.length; i++)
				{
					if (!CH2.currentCharacter.nodesPurchased[JSON.stringify(CH2.currentCharacter.gildStartBuild[i])])
					{
						CH2.currentCharacter.totalStatPointsV2++;
						CH2.currentCharacter.levelGraph.purchaseNode(CH2.currentCharacter.gildStartBuild[i]);
						CH2.currentCharacter.alwaysAvailableNodes[CH2.currentCharacter.gildStartBuild[i]] = true;
						
						if ( i + 1 == CH2.currentCharacter.gildStartBuild.length )
						{
							CH2.currentCharacter.totalStatPointsV2 += 19;
							CH2.currentCharacter.level = 20;
							CH2.currentCharacter.automatorPoints += 4;
						}
					}
				}
			}
			
			//Adjusts starting perk levels based on CHARACTER_PERKS
			for (var i:int = 0; i < CHARACTER_PERKS.length; i++)
			{
				setTranscensionPerkLevel(CHARACTER_PERKS[i].id, CHARACTER_PERKS[i].level);
			}
			
			//Setup challenge id stuff if character save didn't already exist
			if (!CH2.currentCharacter.extendedVariables || CH2.currentCharacter.extendedVariables["challengeId"] == 0)
			{
				var currentTime:Date = new Date();
				currentTime.setTime(ServerTimeKeeper.instance.timestamp);
				CH2.currentCharacter.extendedVariables = new ChallengeExtendedVariables();
				CH2.currentCharacter.extendedVariables["challengeId"] = int(currentTime.getTime()/1000);
				CH2.user.challengeResults.addChallenge(CH2.currentCharacter.extendedVariables["challengeId"], NEW_CHARACTER_NAME);
			}
			
			CH2.currentCharacter.levelUpStat(CH2.STAT_AUTOMATOR_SPEED, 15);
			CH2.currentCharacter.currentWorldEndAutomationOption = 0;
			CH2.currentCharacter.onCharacterLoadedDefault();
		}
		
		override public function onZoneChangedOverride(zoneNumber:int):void
		{
			callSuperClassFunction(super.onZoneChangedOverride, CH2.currentCharacter, zoneNumber);
			
			var previousZoneNumber:int = zoneNumber - 1;
			if (previousZoneNumber % ZONE_FREQUENCY_TO_SAVE_PROGRESS == 0 && zoneNumber > 1)
			{
				CH2.user.challengeResults.updateChallenge(
					CH2.currentCharacter.extendedVariables["challengeId"],
					CH2.currentCharacter.timeOnlineSeconds,
					CH2.currentCharacter.currentWorldId,
					previousZoneNumber
				);
			}
		}
		
		public function challengeTimeToDisplayFunction():String
		{
			return TimeFormatter.formatTime(CH2.currentCharacter.timeOnlineSeconds);
		}
		
		public function challengeTooltipFunction():Object
		{
			var achievementTimes:Object = getChallengeAchievementTimes();
			return {
				"header": "Times for each achievement",
				"body": "Gold: "+TimeFormatter.formatTime(achievementTimes.gold)+"\nSilver: "+TimeFormatter.formatTime(achievementTimes.silver)+"\nBronze: "+TimeFormatter.formatTime(achievementTimes.bronze)+""
			};
		}
		
		public function challengeProgressTextDisplayFunction():String
		{
			var currentWorldNumber:int = CH2.currentCharacter.currentWorldId;
			var nextProgressPointMultiple:int = Math.ceil(CH2.currentCharacter.currentZone / ZONE_FREQUENCY_TO_SAVE_PROGRESS) * ZONE_FREQUENCY_TO_SAVE_PROGRESS;
			
			var previousResult:ChallengeResult = CH2.user.challengeResults.getPreviousChallengeResult(NEW_CHARACTER_NAME);
			var previousTime:int = (previousResult != null) ? previousResult.getTimeAtZone(currentWorldNumber, nextProgressPointMultiple) : 0;
			var bestResult:ChallengeResult = CH2.user.challengeResults.getBestChallengeResult(NEW_CHARACTER_NAME);
			var bestTime:int = (bestResult != null) ? bestResult.getTimeAtZone(currentWorldNumber, nextProgressPointMultiple) : 0;
			
			return "Time To Beat "+currentWorldNumber+"-"+nextProgressPointMultiple+"   Prev. "+TimeFormatter.formatTime(previousTime)+"   Best "+TimeFormatter.formatTime(bestTime);
		}
		
		public function challengeProgressTooltipFunction():Object
		{
			var previousResult:ChallengeResult = CH2.user.challengeResults.getPreviousChallengeResult(NEW_CHARACTER_NAME);
			var previousTime:int = (previousResult != null) ? previousResult.finalTimeInSecs() : 0;
			var bestResult:ChallengeResult = CH2.user.challengeResults.getBestChallengeResult(NEW_CHARACTER_NAME);
			var bestTime:int = (bestResult != null) ? bestResult.finalTimeInSecs() : 0;
			
			return {
				"header": "Best Times For Challenge",
				"body": "Previous Final Time: " + TimeFormatter.formatTime(previousTime) + "\nBest Final Time: " + TimeFormatter.formatTime(bestTime)
			};
		}
		
		public function isChallengeFinishedFunction():Boolean
		{
			return CH2.currentCharacter.numStartSystemsCompleted() >= 1;
		}
		
		public function getChallengeAchievementTimes():Object
		{
			return ACHIEVEMENT_TIMES;
		}
		
		public function getLevelUpCostToNextLevelOverride(level:Number):BigNumber
		{
			//keeps xp required to level consistent through out levels
			return CH2.currentCharacter.getLevelUpCostToNextLevelDefault(1);
		}
		
		override public function addGoldOverride(goldToAdd:BigNumber):void
		{
			if (goldToAdd.gtN(0))
			{
				callSuperClassFunction(super.addGoldOverride, CH2.currentCharacter, goldToAdd.multiplyN(GOLD_GAIN_MULTIPLIER));
			}
			else
			{
				callSuperClassFunction(super.addGoldOverride, CH2.currentCharacter, goldToAdd);
			}
		}
		
		override public function applySystemTraitsOverride(worldNumber:Number):void
		{
			callSuperClassFunction(super.applySystemTraitsOverride, CH2.currentCharacter, worldNumber);
			CH2.currentCharacter.monstersPerZone = 5;
		}
		
		public function onWorldFinishedOverride():void
		{
			CH2.currentCharacter.onWorldFinishedDefault();
			
			if (isChallengeFinishedFunction())
			{
				//Finished the challenge
				trace("Finished Challenge in: " + CH2.currentCharacter.timeOnlineSeconds);
				
				CH2.user.challengeResults.updateChallenge(
					CH2.currentCharacter.extendedVariables["challengeId"],
					CH2.currentCharacter.timeOnlineSeconds,
					CH2.currentCharacter.currentWorldId,
					CH2.currentCharacter.currentZone
				);
				
				CH2.user.challengeResults.onChallengeFinished(
					CH2.currentCharacter.extendedVariables["challengeId"],
					CH2.currentCharacter.timeOnlineSeconds
				);
				
				var currentChallengeResult:ChallengeResult = CH2.user.challengeResults.getChallengeResultById(CH2.currentCharacter.extendedVariables["challengeId"]);
				
				if (CH2.currentCharacter.timeOnlineSeconds <= getChallengeAchievementTimes().gold)
				{
					currentChallengeResult.setAchievedGold();
				}
				else if (CH2.currentCharacter.timeOnlineSeconds <= getChallengeAchievementTimes().silver)
				{
					currentChallengeResult.setAchievedSilver();
				}
				else if (CH2.currentCharacter.timeOnlineSeconds <= getChallengeAchievementTimes().bronze)
				{
					currentChallengeResult.setAchievedBronze();
				}
				
				CH2UI.instance.mainUI.showChallengeComplete();
			}
		}
		
		//tweaks items curve to adjust for damage earned from skill tree
		public function getItemDamageOverride(item:Item):BigNumber
		{
			if (item.skills.length > 0)
			{
				return new BigNumber(0);
			}
			var result:BigNumber = item.baseCost.multiplyN(1 / 30);
			var multiplier:Number = 1;
			
			multiplier *= (Math.pow(0.93, item.rank - 1));
			
			multiplier *= (1.0 + item.bonusDamage);
			
			if (item.rank < 4)
			{
				multiplier *= (5 - item.rank);
			}
			
			result.timesEqualsN(multiplier);
			result.floorInPlace();
			
			multiplier = item.level;
			multiplier *= (Math.pow(CH2.currentCharacter.item10LvlDmgMultiplier, Math.floor(item.level / 10)));
			multiplier *= (Math.pow(CH2.currentCharacter.item20LvlDmgMultiplier, Math.floor(item.level / 20)));
			if (item.level >= 50)
			{
				multiplier *= (CH2.currentCharacter.item50LvlDmgMultiplier);
				if (item.level >= 100)
				{
					multiplier *= (CH2.currentCharacter.item100LvlDmgMultiplier);
				}
			}
			result.timesEqualsN(multiplier);
			result.timesEquals(CH2.currentCharacter.getMultiplierForItemType(item.type));
			return result;
		}
		
		//Disables energy regen from leveling up
		public function gainLevelOverride():void
		{
			CH2.currentCharacter.level++;
			var whatever:BigNumber = CH2.currentCharacter.totalStatPoints;
			CH2.currentCharacter.totalStatPointsV2++;
			CH2.currentCharacter.hasNewSkillTreePointsAvailable = true;
			CH2.currentCharacter.timeOfLastLevelUp = CH2.user.totalMsecsPlayed;
			CH2.currentCharacter.eventLogger.logEvent(EventLog.LEVELED_UP);
			CH2UI.instance.refreshLevelDisplays();
			CH2.user.remoteStatsTracking.addEvent({
				"type": "levelUp",
				"highestWorld": CH2.currentCharacter.highestWorldCompleted,
				"timestamp": ServerTimeKeeper.instance.secondsTimestamp,
				"level": CH2.currentCharacter.level,
				"ancientShardsPurchased": CH2.currentCharacter.ancientShards
			});
		}
		
		
		//Makes it so experience above what is required for your current level will carry over towards your next level. 
		public function addExperienceOverNextLevel(points:BigNumber):void
		{
			var currentExperience:BigNumber = CH2.currentCharacter.experience;
			var experienceRequiredToLevel:BigNumber = getLevelUpCostToNextLevelOverride(0);
			var experienceRemainingToLevelUp:BigNumber = experienceRequiredToLevel.subtract(currentExperience);
			var carryOverExperience:BigNumber = points.subtract(experienceRemainingToLevelUp);		
	
			CH2.currentCharacter.addExperience(points);
			
			if (carryOverExperience.gtN(0))
			{
				CH2.currentCharacter.addExperience(carryOverExperience);
			}
		}
		
		//Removes Kuma stacks and experience from all monsters. 
		override public function onKilledMonsterOverride(monster:Monster):void
		{
			//############## From HelpfulAdventurerChallengeBase.as ##############
			var character:Character = CH2.currentCharacter;
			if (character.getTrait("KillingFrenzy"))
			{
				var buff:Buff = new Buff();
				buff.name = "Killing Frenzy";
				buff.unhastened = true;
				buff.iconId = 23;
				buff.tooltipFunction = function() {
					return {
						"header": "Killing Frenzy",
						"body": "Multiplies haste by " + buff.getStatValue(CH2.STAT_HASTE) * 100 + "% for 5 seconds." // Reduced by 10% per second."
					};
				}
				buff.buffStat(CH2.STAT_HASTE, 1.5);
				buff.duration = 5000;			
				character.buffs.addBuff(buff);
			}
			
			monster.level += character.getTrait("EtherealMonsterLevels");
			
			//############## From Character.as ##############
			
			CH2.currentCharacter.monstersKilled++;
			CH2.user.totalMonstersKilled++;
			
			trace(CH2.currentCharacter.experience);
			
			//makes each zone give less than the one before it. Helps the player get going earlier, but not getting overwhelmed with levels at the end.
			var experienceForCurrentZone:BigNumber = new BigNumber(50 + (500 * (100 - (CH2.currentCharacter.currentZone-1)) / 100));
			
			if (CH2.currentCharacter.monstersKilledPerZone.hasOwnProperty(CH2.currentCharacter.currentZone))
			{
				CH2.currentCharacter.monstersKilledPerZone[CH2.currentCharacter.currentZone]++;
			}
			else
			{
				CH2.currentCharacter.monstersKilledPerZone[CH2.currentCharacter.currentZone] = 1;
			}
			
			if (CH2.currentCharacter.isOnHighestZone)
			{
				CH2UI.instance.mainUI.hud.update(0);
			}
			
			if (!monster.isBoss || !monster.isMiniBoss)
			{
				addExperienceOverNextLevel(experienceForCurrentZone.multiplyN(.66).divideN(CH2.currentCharacter.monstersPerZone));
			}
			
			if (monster.isMiniBoss)
			{
				addExperienceOverNextLevel(experienceForCurrentZone.multiplyN(.34));
			}
			
			if (monster.isBoss)
			{
				CH2.currentCharacter.highestMonstersKilled[CH2.currentCharacter.currentWorldId] = (monster.zoneSpawned) * CH2.currentCharacter.monstersPerZone;
				
				//experienced earned over a level is ignored this makes it so you still get the animation for leveling up and still get 10 levels from bosses
				CH2.currentCharacter.addExperience(CH2.currentCharacter.getLevelUpCostToNextLevel(0));
				CH2.currentCharacter.level += int(9);
				CH2.currentCharacter.totalStatPointsV2 += int(9);
			}
			else
			{
				CH2.currentCharacter.highestMonstersKilled[CH2.currentCharacter.currentWorldId] = (monster.zoneSpawned - 1) * CH2.currentCharacter.monstersPerZone + CH2.currentCharacter.monstersKilledOnCurrentZone;
			}
			
			if (!CH2.currentCharacter.runsCompletedPerWorld.hasOwnProperty(CH2.currentCharacter.currentWorldId))
			{
				CH2.currentCharacter.runsCompletedPerWorld[CH2.currentCharacter.currentWorldId] = 0;
			}
			
			
			//AO: Boss encounter is moving them to the next zone already, may need refactor
			if (!CH2.user.isOnBossZone && CH2.currentCharacter.hasCompletedCurrentZone() && !CH2.user.isOnFinalBossZone)
			{
				CH2.currentCharacter.eventLogger.logEvent(EventLog.BEAT_ZONE);
				CH2.world.moveToNextZone(false);
			}
			else if(!CH2.currentCharacter.isNextMonsterInRange && !CH2.currentCharacter.isPaused)
			{
				CH2.currentCharacter.changeState(Character.STATE_ENDING_COMBAT);
			}
		}
		
		override public function attackOverride(attackData:AttackData):void
		{
			var character:Character = CH2.currentCharacter;
			var currentSystem:StarSystem = CH2.currentCharacter.getStarSystem(CH2.currentAscensionWorld.starSystemId);
			
			if (currentSystem.traits[WT_ROBUST])
			{
				attackData.critChanceModifier = -100;
			}
			
			if (character.getTrait("LowEnergyDamageBonus") && character.energy < character.maxEnergy.numberValue() * 0.60)
			{
				attackData.damage.timesEqualsN(2);
			}
			
			var monsterHealth:BigNumber; 
			
			if (character.getTrait("ManaCritOverflow"))
			{
				var target:Monster = CH2.world.getNextMonster();
				if (target)
				{
					monsterHealth = new BigNumber(0);
					monsterHealth.power = target.health.power;
					monsterHealth.base = target.health.base;
				}
			}
			
			character.attackDefault(attackData);
			
			if (!attackData.isAutoAttack)
			{
				if (character.buffs.hasBuffByName("Exhaustion"))
				{
					var currentExhaustion:Buff = character.buffs.getBuff("Exhaustion");
					if (currentExhaustion.stacks < 100000)
					{
						currentExhaustion.stacks += 1;
						currentExhaustion.buffStat(CH2.STAT_HASTE, 0.95 * currentExhaustion.getStatValue(CH2.STAT_HASTE));
						currentExhaustion.duration = 500 * currentExhaustion.stacks;
					}
					currentExhaustion.timeSinceActivated = 0;
				}
				else
				{
					var exhaustion:Buff = new Buff();
					exhaustion.name = "Exhaustion";
					exhaustion.iconId = 147;
					exhaustion.isUntimedBuff = false;
					exhaustion.duration = 500;
					exhaustion.maximumStacks = 100000;
					exhaustion.unhastened = true;
					exhaustion.tickRate = 500;
					exhaustion.tooltipFunction = function() {
						return {
							"header": "Exhaustion",
							"body": "Tired of attacking, haste temporarily reduced."
						};
					}
					exhaustion.buffStat(CH2.STAT_HASTE,  0.9);
					exhaustion.tickFunction = function() {
						var currentExhaustion:Buff = CH2.currentCharacter.buffs.getBuff("Exhaustion")
						currentExhaustion.stacks -= 1;
						currentExhaustion.buffStat(CH2.STAT_HASTE, 1 / 0.95 * currentExhaustion.getStatValue(CH2.STAT_HASTE));
					}
					character.buffs.addBuff(exhaustion);
				}
			}
			
			if (attackData.isAutoAttack && attackData.isCritical && character.getTrait("AutoAttackCritMana"))
			{
				character.addMana(1);
				character.addEnergy(2);
			}
			
			if (attackData.isCritical && (character.getTrait("BhaalsRise") || character.getTrait("BhallsRise")))
			{
				var manaCrit:Skill = character.getSkill("Mana Crit");
				if (manaCrit)
				{	
					manaCrit.cooldownRemaining -= 1000;
				}
			}
			
			if (attackData.isKillShot && attackData.isCritical && (character.getTrait("CritKillPowerSurge") || character.getTrait("CritKillPowerSurgeCooldown")))
			{
				var powerSurge:Skill = character.getSkill("Powersurge");
				if (powerSurge)
				{
					powerSurge.cooldownRemaining -= 5000;
				}
			}
			
			if (attackData.isKillShot && (character.buffs.hasBuffByName("Mana Crit")) && character.getTrait("ManaCritOverflow"))
			{
				if (!character.buffs.hasBuffByName("Improved Overflow"))
				{
					var overflowDamage:BigNumber = attackData.damage.subtract(monsterHealth);
					var nextTarget:Monster = CH2.world.getNextMonster();
					if (nextTarget)
					{
						var overflowAttack:AttackData = new AttackData();
						overflowAttack.damage = overflowDamage;
						nextTarget.takeDamage(overflowAttack);
					}
				}
				else
				{
					var impOverflow:Buff = character.buffs.getBuff("Improved Overflow");
					var impOverFlowDamage:BigNumber = attackData.damage.subtract(monsterHealth);
					
					var livingMonsters:Vector.<Monster> = CH2.world.monsters.getLivingMonsters();
					if (livingMonsters.length == 0) return;
					if (CH2.world.bossEncounter && !CH2.world.bossEncounter.battleStarted) return;
	
					var numMonstersToAttack:int = Math.min(livingMonsters.length, impOverflow.stacks);
					var monsterListToAttack:Array = [];
					var nextMonster = 0;
					
					for ( var i:int = 0; i < numMonstersToAttack; i++ )
					{
						monsterListToAttack.push(livingMonsters[i]);
					}
					
					while (impOverFlowDamage.gtN(0) && nextMonster < monsterListToAttack.length)
					{
						var overflowAttack:AttackData = new AttackData();
						overflowAttack.damage = impOverFlowDamage.subtract(monsterListToAttack[nextMonster].health);
						impOverFlowDamage = impOverFlowDamage.subtract(monsterListToAttack[nextMonster].maxHealth);
						
						if (overflowAttack.damage.gtN(0))
						{
							monsterListToAttack[nextMonster].takeDamage(overflowAttack);
							
							nextMonster++;
							impOverflow.stacks--;
							character.getSkill("Mana Crit").cooldownRemaining -= character.getSkill("Mana Crit").cooldown * .25;
						}
					}
				}
			}
			
			if (character.getTrait("PayDay") && attackData.isKillShot && attackData.isClickAttack && character.buffs.hasBuffByName("Big Clicks"))
			{
				var addBuff:Boolean = CH2.roller.attackRoller.boolean(3 * character.getTraitValue("BigClicksDamage") * .04);
				
				if (addBuff)
				{
					if (!character.buffs.hasBuffByName("Pay Day"))
					{
						var buff:Buff = new Buff();
							buff.name = "Pay Day";
							buff.iconId = 96;
							buff.stacks = 1;
							buff.isUntimedBuff = true;
							buff.unhastened = true;
							buff.tooltipFunction = function() {
								return {
									"header": "Pay Day",
									"body": "The next monster killed by Huge Clicks will drop " + (buff.stacks * 250) + "% more gold"  
								};
							}
							buff.killFunction = function(attack:AttackData) {
								
								if (hasHugeClick)
								{
									ItemDropManager.instance.goldSplash(attack.monster.goldReward().multiplyN(buff.stacks * 2.5), attack.monster.x, attack.monster.y, CH2.currentCharacter, "N");
									character.buffs.removeBuff("Pay Day");
								}
								hasHugeClick = false;
							}
							
						character.buffs.addBuff(buff);
					}
					else
					{
						character.buffs.getBuff("Pay Day").stacks++; 
					}
				}
			}
			
			if (character.getTrait("CriticalBigClicks") && attackData.isKillShot && attackData.isClickAttack && character.buffs.hasBuffByName("Big Clicks"))
			{
				var addBuff:Boolean = CH2.roller.attackRoller.boolean(3 * character.getTraitValue("BigClicksDamage") * .04);
				
				if (addBuff)
				{
					if (!character.buffs.hasBuffByName("Improved Overflow"))
					{
						var buff:Buff = new Buff();
							buff.name = "Improved Overflow";
							buff.iconId = 163;
							buff.stacks = 1;
							buff.isUntimedBuff = true;
							buff.unhastened = true;
							buff.tooltipFunction = function() {
								return {
									"header": "Improved Overflow",
									"body": "Manacrit can hit up to " + (buff.stacks) + " extra enemies"  
								};
							}
						character.buffs.addBuff(buff);
					}
					else
					{
						if (character.buffs.getBuff("Improved Overflow").stacks < 5)
						{
							character.buffs.getBuff("Improved Overflow").stacks++; 
						}
					}
				}
			}
			
			if (attackData.isClickAttack)
			{
				hasHugeClick = false;
			}
		}
		
		public function challengeAutoAttackstormEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.name = "Challenge Autoattackstorm";
			buff.iconId = 201;
			buff.isUntimedBuff = true;
			buff.tickRate = 200;
			buff.tickFunction = function() {
				if (character.isNextMonsterInRange)
				{
					var attackTimer:Number = character.timeSinceLastAutoAttack;
					character.autoAttack();
					character.timeSinceLastClickAttack = character.timeSinceLastAutoAttack;
					character.timeSinceLastAutoAttack = attackTimer;
					character.addMana( -0.5);
					if (character.mana <= 0) {
						buff.isFinished = true;
						buff.onFinish();
					}
				}
			}
			buff.buffStat(CH2.STAT_AUTOATTACK_DAMAGE, 2);
			buff.tooltipFunction = function() {
				return {
					"header": "Challenge Autoattackstorm",
					"body": "Autoattacking " + (5 * character.hasteRating.numberValue()).toFixed(2) + " times per second. Autoattack damage doubled. Consuming " + (2.5 * character.hasteRating.numberValue()).toFixed(2) + " mana per second."
				};
			}
			character.buffs.addBuff(buff);
		}
		
		override public function autoAttackOverride():void
		{
			var character:Character = CH2.currentCharacter;
			
			//if (character.getTrait("Synchrony") && character.buffs.hasBuffByName("Autoattackstorm"))
			//{
				//character.addEnergy(2, false);
			//}
			
			var attackData:AttackData = new AttackData();
			attackData.isAutoAttack = true;
			attackData.damage = CH2.currentCharacter.autoAttackDamage;
			
			character.characterDisplay.playAutoAttack();
			character.timeSinceLastAutoAttack = 0;
			character.attack(attackData);
			
			//Disables energy regen from autoattacks
			//addEnergy(energyRegeneration.numberValue(), false);
		}
		
		override public function onUICreated():void
		{
			if (CH2.currentCharacter.name == NEW_CHARACTER_NAME)
			{
				callSuperClassFunction(super.onUICreated, CH2.currentCharacter);
			}
			
		}
		
		override public function createFixedFirstRunCatalogs(data:Array):void
		{
			return;
		}
	}
}

import models.ExtendedVariables;
class ChallengeExtendedVariables extends ExtendedVariables
{
	public var challengeId:int;
	public var isStarted:Boolean = false;
	
	public function ChallengeExtendedVariables()
	{
		super();
		persist(ASCENSION_PERSISTING_TRUE, 0, registerDynamicNumber, "challengeId");
		persist(ASCENSION_PERSISTING_TRUE, 0, registerDynamicBoolean, "isStarted");
	}
}