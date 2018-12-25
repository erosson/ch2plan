 package
{
	import com.doogog.utils.MiscUtils;
	import com.playsaurus.managers.BigNumberFormatter;
	import com.playsaurus.numbers.BigNumber;
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
	import models.Buff;
	import models.Character;
	import models.Characters;
	import models.Item;
	import models.ItemStat;
	import models.Items;
	import models.Skill;
	import models.Character;
	import models.Monster;
	import models.AttackData;
	import models.Tutorial;
	import models.RubyPurchase;
	import heroclickerlib.GpuMovieClip;
	import heroclickerlib.managers.CH2AssetManager;
	import com.gskinner.utils.Rnd;
	import heroclickerlib.managers.SoundManager;
	import HelpfulAdventurer.thumbnail;
	import models.UserData;
	import ui.CH2UI;
	import ui.TutorialManager;
	
	public dynamic class HelpfulAdventurerMain extends Sprite
	{
		public static const CHARACTER_NAME:String = "Helpful Adventurer";
		public static const CHARACTER_ASSET_GROUP:String = "HelpfulAdventurer";
		
		public var MOD_INFO:Object = 
		{
			"id": 1,
			"name": CHARACTER_NAME,
			"description": "Default prepackaged character class",
			"version": 1,
			"author": "Playsaurus",
			"dependencies": "",
			"library": {}
		};
		
		public static const HUGE_CLICK:String = CHARACTER_ASSET_GROUP+"_hugeClick";
		public static const BIG_CLICK:String = CHARACTER_ASSET_GROUP+"_bigClicks";
		public static const BIG_GIANT_CLICK:String = CHARACTER_ASSET_GROUP+"_bigGiantClick";
		public static const HUGE_CLICK_CRACK:String = CHARACTER_ASSET_GROUP+"_hugeClickCrack";
		public static const BUFF_INDICATOR:String = CHARACTER_ASSET_GROUP+"_indicator";
		public static const ENERGY_CHARGE:String = CHARACTER_ASSET_GROUP+"_energyCharge";
		
		public static const GRAPH_NODE_NINE_CLICK_MULTIPLIER:Number = 2;
		public static const GRAPH_NODE_BIG_CLICKS_MULTIPLIER:Number = 2;
		public static const GRAPH_NODE_HUGE_CLICK_MULTIPLIER:Number = 2;
		public static const GRAPH_NODE_MASSIVE_CLICK_MULTIPLIER:Number = 2;
		public static const GRAPH_NODE_CLICKSTORM_CD_REDUCTION:Number = 0.5;
		public static const CLICKSTORM_BASE_COOLDOWN:Number = 600 * 1000;// 1000 * 60 * 30;
		public static const GRAPH_NODE_POWER_SURGE_DURATION_INCREASE:Number = 1.5;
		public static const GRAPH_NODE_POWER_SURGE_DAMAGE_INCREASE:Number = 1.5;
		public static const ENERGIZE_BASE_MANA_COST:Number = 25;
		public static const GRAPH_NODE_ENERGIZE_MANA_COST_REDUCTION:Number = 0.5;
		public static const CLICKSTORM_TOOLTIP:String = "Consumes 1.25 energy per second to click 2.5 times per second, until you run out of energy. Speed increases over time.";
		public static const CRITSTORM_TOOLTIP:String = "Consumes 1.25 energy per second to click 2.5 times per second, until you run out of energy. Clicks from this skill have +100% chance of being critical strikes. Speed increases over time.";
		public static const GOLDENCLICKS_TOOLTIP:String = "Consumes 1.25 energy per second to click 2.5 times per second, until you run out of energy. Doubles gold gained while active. Speed increases over time.";
		public static const CLICKTORRENT_TOOLTIP:String = "Consumes 10 energy per second to click 30 times per second, until you run out of energy. Speed increases over time.";
		public static const AUTOATTACKSTORM_TOOLTIP:String = "Consumes 1.25 mana per second to auto attack 2.5 times per second, until you run out of mana. Speed increases over time.";
		
		public static const FIXED_FIRST_RUN_CATALOG_DATA:Array = [
			[
				[
					{
						"id": 14,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": 9,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": 0,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": 3,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": 17,
						"level": 1
					}
				],
				[
					{
						"id": 13,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": 15,
						"level": 1
					}
				],
				[
					{
						"id": 10,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": 8,
						"level": 1
					}
				],
				[
					{
						"id": 2,
						"level": 1
					}
				],
				[
					{
						"id": 5,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": 9,
						"level": 1
					}
				],
				[
					{
						"id": 16,
						"level": 1
					}
				],
				[
					{
						"id": 4,
						"level": 1
					}
				]
			]
		];
		
		public var firstRunHardcodedCatalogs:Array = [];
		public var bigClicksIndicators:Array = [];
		public var energizeIndicator:CharacterUIElement = new CharacterUIElement();
		public var helpfulAdventurer:Character = new Character();
		
		public function HelpfulAdventurerMain() 
		{
			MOD_INFO["library"]["thumbnail"] = HelpfulAdventurer.thumbnail;
			MOD_INFO["library"]["frame"] = HelpfulAdventurer.frame;
		}
		
		public function onStartup(game:IdleHeroMain):void //Save data is NOT loaded at this point, init() has not yet been run
		{
			helpfulAdventurer.assetGroupName = CHARACTER_ASSET_GROUP;
			
			helpfulAdventurer.levelGraphNodeTypes = {
				"G": { 
					"name": "Gold",
					"tooltip": "Multiplies your gold received from all sources by 110%.",
					"flavorText": "We can also say that it is multiplied by 1.1, but that sounds so much weaker.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD)},
					"icon": "goldx3"
				},
				"Cc": { 
					"name": "Crit Chance",
					"tooltip": "Adds 2% to your chance to score a critical hit." ,
					"flavorText": "Ever wonder what happens when you get over 100% Crit Chance? The Ancients once knew, but that is ancient history.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_CHANCE)},
					"icon": "critChance"
				},
				"Cd": { 
					"name": "Crit Damage",
					"tooltip": "Multiplies the damage of your critical hits by 120%." ,
					"flavorText": "When a number is multiplied by a fixed amount (greater than 1) many times, that number is said to grow \"exponentially\". This is because that process is usually represented by a formula that uses exponential notation.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_DAMAGE)},
					"icon": "critDamage"
				},			
				"H": { 
					"name": "Haste",
					"tooltip": "Multiplies your Haste by 105%." ,
					"flavorText": "Haste affects the rate that you auto-attack, and all cooldown speeds, including Automator cooldown speeds.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_HASTE)},
					"icon": "haste"
				},
				"Gc": { 
					"name": "Clickable Gold",
					"tooltip": "Multiplies your gold received from clickables by 150%." ,
					"flavorText": "If only someone could click on them before they go off the screen.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_GOLD)},
					"icon": "clickableGold"
				},
				"Cl": { 
					"name": "Click Damage",
					"tooltip": "Multiplies your click damage by 110%." ,
					"flavorText": "This affects damage from all skills that \"click\". But it does not affect auto-attacks, because those are not \"clicks\".",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICK_DAMAGE)},
					"icon": "clickDamage"
				},
				"Gb": { 
					"name": "Monster Gold",
					"tooltip": "Multiplies gold received by monsters by 120%." ,
					"flavorText": "", //AO: Need new flavor text
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_MONSTER_GOLD)},
					"icon": "bossGold"
				},
				"Ir": { 
					"name": "Item Cost Reduction",
					"tooltip": "Multiplies the gold costs of buying and leveling equipment by 0.92." ,
					"flavorText": "Rufus sometimes wonders why he can't compete in the Gold market. He always felt like there was a mysterious seller undercutting him.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_COST_REDUCTION)},
					"icon": "itemCostReduction"
				},
				"Mt": { 
					"name": "Total Mana",
					"tooltip": "Increases your maximum mana by 25." ,
					"flavorText": "If a fixed amount is added to a number many times, that number is said to grow \"linearly\". This is because if you plot it out on an x/y graph, you'll see a line.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_MANA)},
					"icon": "totalMana"
				},
				"Mr": { 
					"name": "Mana Regeneration",
					"tooltip": "Multiplies your mana regeneration rate by 110%." ,
					"flavorText": "You will get 10% more mana per minute than before you had this upgrade.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_MANA_REGEN)},
					"icon": "manaRegen"
				},
				"En": { 
					"name": "Total Energy",
					"tooltip": "Increases your maximum energy by 25." ,
					"flavorText": "If a fixed amount is added to a number many times, that number is said to grow \"linearly\". This is because if you plot it out on an x/y graph, you'll see a line.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_ENERGY)},
					"icon": "totalEnergy"
				},
				"Gp": { 
					"name": "Gold Piles",
					"tooltip": "Multiplies the number of gold piles found by 110%." ,
					"flavorText": "This only affects piles of gold. Not other clickables." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_CHANCE)},
					"icon": "goldPiles"
				},
				"Bg": { 
					"name": "Bonus Gold Chance",
					"tooltip": "Adds 1% to your chance of finding bonus gold." ,
					"flavorText": "When killing monsters, bonus gold may appear. This is a linear bonus, like Crit Chance." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_BONUS_GOLD_CHANCE)},
					"icon": "goldChance"
				},
				"Tc": { 
					"name": "Treasure Chest Chance",
					"tooltip": "Adds 2% to the chance that a monster happens to be a treasure chest." ,
					"flavorText": "Making good use of the lingering powers of a once-loathed ancient known as Thusia.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_CHANCE)},
					"icon": "treasureChance"
				},
				"Tg": { 
					"name": "Treasure Chest Gold",
					"tooltip": "Multiplies the gold received from treasure chest monsters by 125%." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_GOLD)},
					"icon": "treasureGold"
				},
				"I1": { 
					"name": "Equipment: Sword",
					"tooltip": "Multiplies the damage you deal with swords by 150%" ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_WEAPON_DAMAGE)},
					"icon": "damageWeapon"
				},
				"I2": { 
					"name": "Equipment: Helmet",
					"tooltip": "Multiplies the damage you deal with helmets by 150%" ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_HEAD_DAMAGE)},
					"icon": "damageHead"
				},
				"I3": { 
					"name": "Equipment: Breastplate",
					"tooltip": "Multiplies the damage you deal with breastplates by 150%" ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_CHEST_DAMAGE)},
					"icon": "damageTop"
				},
				"I4": { 
					"name": "Equipment: Ring",
					"tooltip": "Multiplies the damage you deal with rings by 150%" ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_RING_DAMAGE)},
					"icon": "damageAccesory"
				},
				"I5": { 
					"name": "Equipment: Pants",
					"tooltip": "Multiplies the damage you deal with pants by 150%" ,
					"flavorText": "Pants shouldn't do damage, that's ridiculous.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_LEGS_DAMAGE)},
					"icon": "damageLegs"
				},
				"I6": { 
					"name": "Equipment: Gloves",
					"tooltip": "Multiplies the damage you deal with gloves by 150%" ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_HANDS_DAMAGE)},
					"icon": "damageHands"
				},
				"I7": { 
					"name": "Equipment: Boots",
					"tooltip": "Multiplies the damage you deal with boots by 150%" ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_FEET_DAMAGE)},
					"icon": "damageFeet"
				},
				"I8": { 
					"name": "Equipment: Cape",
					"tooltip": "Multiplies the damage you deal with capes by 150%" ,
					"flavorText": "If you wear these in real life, people will think something is wrong with you.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_BACK_DAMAGE)},
					"icon": "damageBack"
				},
				"Mo": { 
					"name": "Mousing over Clickables",
					"tooltip": "Collect Clickables by mousing over them instead of clicking them" ,
					"flavorText": "The ancients left some of their greatest powers behind for you to discover.",
					"setupFunction": function(){},
					"purchaseFunction": function() {},
					"icon": "clickableGold"
				},
				//####################################################################
				//########################## CLASS SPECIFIC ##########################
				//####################################################################
				"Mu": {
					"name": "Increased MultiClicks",
					"tooltip": "Adds 3 clicks to your multiclick, at the cost of 1 additional energy.",
					"flavorText": "No matter how many of these upgrades you get, MultiClick will take the same amount of time to perform all of its clicks.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("ExtraMulticlicks", 3); CH2.currentCharacter.getSkill("MultiClick").energyCost += 1; },
					"icon": "nineClicks"
				},
				"Bc": { 
					"name": "More Big Clicks",
					"tooltip": "Increases the number of clicks empowered by Big Clicks by 1.",
					"flavorText": "They march loyally behind you in unison, each one prepared to sacrifice itself for your cause.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("BigClickStacks", 1)},
					"icon": "iconBigClicks"
				},
				"Bd": { 
					"name": "Bigger Big Clicks",
					"tooltip": "Multiplies the damage done by Big Clicks by 125%",
					"flavorText": "They might not look any bigger when you get this upgrade. They're bigger on the inside. In fact, they weigh a lot more.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("BigClicksDamage", 1)},
					"icon": "iconBigClicks"
				},
				"Hd": { 
					"name": "Huger Huge Click",
					"tooltip": "Multiplies the damage done by Huge Click by 125%",
					"flavorText": "It actually gets bigger. But there is an unusual visual side effect that the rest of the world increases in size proportionally.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("HugeClickDamage", 1);},
					"icon": "hugeClicks"
				},
				"Md": { 
					"name": "Mana Crit Damage",
					"tooltip": "Multiplies the damage of Mana Crit by 125%",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("ManaCritDamage", 1);},
					"icon": "manaClick"
				},
				"Kh": { 
					"name": "Hastened Clickstorm",
					"tooltip": "Multiplies the cooldown of Clickstorm by 0.8",
					"flavorText": "If a fixed positive amount less than 1 is multiplied to a number many times, that number is said to \"approach zero\". Enough applications and your number will get very close to, but never actually reach, zero.",
					"setupFunction": function(){},
					"purchaseFunction": function() {hastenClickstorm();},
					"icon": "clickstorm"
				},
				"Eh": { 
					"name": "Hastened Energize",
					"tooltip": "Multiplies the cooldown and mana cost of Energize by 0.8",
					"flavorText": "If a fixed positive amount less than 1 is multiplied to a number many times, that number is said to \"approach zero\". Enough applications and your number will get very close to, but never actually reach, zero.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {hastenEnergize();},
					"icon": "energize"
				},
				"Ea": { 
					"name": "Improved Energize",
					"tooltip": "Increases the duration of Energize by 20% of its original duration.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("ImprovedEnergize", 1);},
					"icon": "energize"
				},
				"Ph": { 
					"name": "Hastened Powersurge",
					"tooltip": "Multiplies the cooldown and mana cost of Powersurge by 0.8",
					"flavorText": "If a fixed positive amount less than 1 is multiplied to a number many times, that number is said to \"approach zero\". Enough applications and your number will get very close to, but never actually reach, zero.",
					"setupFunction": function(){},
					"purchaseFunction": function() { hastenSkill("Powersurge", 0.8); },
					"icon": "powersurgeDuration"
				},
				"Pt": { 
					"name": "Sustained Powersurge",
					"tooltip": "Multiplies the duration of Powersurge by 120%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("SustainedPowersurge", 1);},
					"icon": "powersurgeDuration"
				},
				"Pa": { 
					"name": "Improved Powersurge",
					"tooltip": "Multiplies the damage bonus of Powersurge by 125%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("ImprovedPowersurge", 1);},
					"icon": "powersurgeDamage"
				},
				"Ra": { 
					"name": "Improved Reload",
					"tooltip": "Increases the effect of Reload by 20% of its base effect." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("ImprovedReload", 1); },
					"icon": "improvedReload"
				},
				"Rh": { 
					"name": "Hastened Reload",
					"tooltip": "Multiplies the cooldown of Reload by 0.8",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { hastenSkill("Reload", 0.8); },
					"icon": "hastenReload"
				},
				//###################################################################
				//############################ SKILLS ############################
				//###################################################################
				"T3": { 
					"name": "Skill: MultiClick",
					"tooltip": "Clicks 5 times." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() {
						addSkill("MultiClick")(); 
					},
					"icon": "nineClicks"
				},
				"T1": { 
					"name": "Skill: Big Clicks",
					"tooltip": "Causes your next 6 clicks to deal 300% damage." ,
					"flavorText": "When activated, press your mouse button harder for added effect.",
					"setupFunction": function() {},
					"alwaysAvailable": true,
					"purchaseFunction": function() {
						CH2.currentCharacter.hasPurchasedFirstSkill = true;
						addSkill("Big Clicks")(); 						
					},
					"icon": "iconBigClicks"
				},
				"T2": { 
					"name": "Skill: Energize.",
					"tooltip": "Restores 2 energy per second for 60 seconds." ,
					"flavorText": "This skill consumes Mana to create Energy.",
					"setupFunction": function() {},
					"purchaseFunction": function() { addSkill("Energize")(); },
					"icon": "energize"
				},
				"T5": { 
					"name": "Skill: Huge Click",
					"tooltip": "Causes your next click to deal 1000% damage." ,
					"flavorText": "It stacks. Everything stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function() { addSkill("Huge Click")(); },
					"icon": "hugeClicks"
				},
				"T4": { 
					"name": "Skill: Clickstorm",
					"tooltip": CLICKSTORM_TOOLTIP,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { addSkill("Clickstorm")(); },
					"icon": "clickstorm"
				},
				"T6": { 
					"name": "Skill: Powersurge",
					"tooltip": "Causes your clicks within 60 seconds to deal 200% damage." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { addSkill("Powersurge")(); },
					"icon": "powersurgeDamage"
				},
				"T7": { 
					"name": "Skill: Mana Crit",
					"tooltip": "Clicks with a 100% chance to score a critical hit." ,
					"flavorText": "It stacks. Everything stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function() { addSkill("Mana Crit")(); },
					"icon": "manaClick"
				},
				"T8": { 
					"name": "Skill: Reload",
					"tooltip": "Restores energy and mana and reduces the remaining cooldown of all skills by 40%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { addSkill("Reload")(); },
					"icon": "reload"
				},
				//###################################################################
				//############################ Key Skills ###########################
				//###################################################################
				"qG": {
					"name": "Mammon's Greed",
					"tooltip": "Multiplies your gold received from all sources by 133%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD, 3)},
					"icon": "goldx3"
				},
				"qCd": {
					"name": "Precision of Bhaal",
					"tooltip": "Multiplies the damage of your critical hits by 172.8%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_DAMAGE, 3)},
					"icon": "critDamage"
				},
				"qH": {
					"name": "Vaagur's Impatience",
					"tooltip": "Multiplies your Haste by 115.7%." ,
					"flavorText": "Haste affects the rate that you auto-attack, and all cooldown speeds, including Automator cooldown speeds.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_HASTE, 3)},
					"icon": "haste"
				},
				"qGc": {
					"name": "Revolc's Blessing",
					"tooltip": "Multiplies your gold received from clickables by 337.5%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_GOLD, 3)},
					"icon": "clickableGold"
				},
				"qCl": {
					"name": "The Wrath of Fragsworth",
					"tooltip": "Multiplies your click damage by 133%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICK_DAMAGE, 3)},
					"icon": "clickDamage"
				},
				"qGb": {
					"name": "Mimzee's Kindness",
					"tooltip": "Multiplies gold received by monsters by 172.8%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_MONSTER_GOLD, 3)},
					"icon": "bossGold"
				},
				"qIr": {
					"name": "The Thrift of Dogcog",
					"tooltip": "Reduces the cost of buying and leveling items by 22%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_COST_REDUCTION, 3)},
					"icon": "itemCostReduction"
				},
				"qMt": {
					"name": "Energon's Ions",
					"tooltip": "Increases your maximum Mana by 100.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_MANA, 4)},
					"icon": "totalMana"
				},
				"qMr": {
					"name": "Energon's Grace",
					"tooltip": "Multiplies your mana regeneration by 133%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_MANA_REGEN, 3)},
					"icon": "manaRegen"
				},
				"qEn": {
					"name": "Juggernaut's Pittance",
					"tooltip": "Increases your maximum Energy by 100.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_ENERGY, 4)},
					"icon": "totalEnergy"
				},
				"qGp": {
					"name": "The Vision of Iris",
					"tooltip": "Multiplies the number of gold piles found by 130%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_CHANCE, 3)},
					"icon": "goldPiles"
				},
				"qBg": {
					"name": "Fortuna's Luck",
					"tooltip": "Adds 3% to your chance of finding bonus gold.",
					"flavorText": "When killing monsters, bonus gold may appear. This is a linear bonus, like Crit Chance." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_BONUS_GOLD_CHANCE, 3)},
					"icon": "goldChance"
				},
				"qTc": {
					"name": "Mimzee's Favor",
					"tooltip": "Adds 6% to the chance that a monster happens to be a treasure chest.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_CHANCE, 3)},
					"icon": "treasureChance"
				},
				"qTg": {
					"name": "Mimzee's Blessing",
					"tooltip": "Multiplies your gold received from treasure chests by 195%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_GOLD, 3)},
					"icon": "treasureGold"
				},
				"qMu": {
					"name": "Mega Increased MultiClicks",
					"tooltip": "Adds 9 clicks to your multiclick, at the cost of 3 additional energy.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("ExtraMulticlicks", 9); CH2.currentCharacter.getSkill("MultiClick").energyCost += 3; },
					"icon": "nineClicks"
				},
				"qBc": { 
					"name": "Mega More Big Clicks",
					"tooltip": "Increases the number of clicks empowered by Big Clicks by 3.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("BigClickStacks", 3)},
					"icon": "iconBigClicks"
				},
				"qBd": { 
					"name": "Mega Bigger Big Clicks",
					"tooltip": "Multiplies the damage done by Big Clicks by 195%",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("BigClicksDamage", 3)},
					"icon": "iconBigClicks"
				},
				"qHd": { 
					"name": "Mega Huger Huge Click",
					"tooltip": "Multiplies the damage of Huge Click by 195%",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("HugeClickDamage", 3);},
					"icon": "hugeClicks"
				},
				"qMd": { 
					"name": "Mega Mana Crit Damage",
					"tooltip": "Multiplies the damage done by Mana Crits by 195%",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("ManaCritDamage", 3);},
					"icon": "manaClick"
				},
				"Q21": { 
					"name": "Synchrony",
					"tooltip": "Skills do not interrupt Auto Attacks." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {applyUninterruptedAutoAttacksTalent()},  
					"icon": "damagex3"
				},
				"Q22": { 
					"name": "Release",
					"tooltip": "Damage is increased by 100% while you have less than 60% of your total energy." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("LowEnergyDamageBonus", 1);},  
					"icon": "damagex3"
				},
				"Q23": { 
					"name": "Restraint",
					"tooltip": "Gold gained is increased by 100% while you have more than 40% of your total energy." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("HighEnergyGoldBonus", 1);},  
					"icon": "damagex3"
				},
				"Q24": { 
					"name": "Discharge",
					"tooltip": "Spending energy deals damage equal to one click per energy. Consumes Big Clicks and Huge Clicks." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("Discharge", 1);},  
					"icon": "damagex3"
				},
				"Q25": { 
					"name": "Gift of Chronos",
					"tooltip": "Spending mana increases haste for 5 seconds." ,
					"flavorText": "To clarify, this multiplies your haste by 100% plus 1% per point of mana spent in the previous 5 seconds. Gift of Chronos's duration is not decreased by haste.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("SpendManaHaste", 1);},  
					"icon": "damagex3"
				},
				"Q26": { 
					"name": "Curse of the Juggernaut",
					"tooltip": "While Big Clicks is active, all skills cost 1 additional energy per skill that has been activated since Big Clicks began." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("CurseOfTheJuggernaut", 1)},
					"icon": "damagex3"
				},
				"Q27": { 
					"name": "Limitless Big Clicks",
					"tooltip": "Big Clicks has no cooldown and can stack infinitely." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {applyLimitlessBigClicks(); },  
					"icon": "damagex3"
				},
				"Q28": { 
					"name": "Jerator's Enchantment",
					"tooltip": "Critical Hits from Auto Attacks can restore 1 mana one time per second." ,
					"flavorText": "This effect can not occur more than once every second.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("AutoAttackCritMana", 1);},  
					"icon": "damagex3"
				},
				"Q29": { 
					"name": "AutoAttackStorm",
					"tooltip": AUTOATTACKSTORM_TOOLTIP, //"A skill. Consumes 1.25 mana per second to auto attack an extra 2.5 times per second.",
					"flavorText": "AutoAttackStorm is like Clickstorm, but does not replace it and can be used in conjunction with Clickstorm.",
					"setupFunction": function(){},
					"purchaseFunction": function() {addSkill("Autoattackstorm")();},  
					"icon": "damagex3"
				},
				"Q30": { 
					"name": "Managize",
					"tooltip": "Energize becomes Managize, which restores 25% of your mana at the cost of 120 energy." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.replaceSkill("Energize", CH2.currentCharacter.getStaticSkill("Managize")); },  
					"icon": "damagex3"
				},
				"Q41": { 
					"name": "Golden Clicks",
					"tooltip": GOLDENCLICKS_TOOLTIP,
					"flavorText": "Replaces Clickstorm.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.buffs.removeBuff("Clickstorm"); CH2.currentCharacter.replaceSkill("Clickstorm", CH2.currentCharacter.getStaticSkill("GoldenClicks")); },  
					"icon": "damagex3"
				},
				"Q42": { 
					"name": "Huge Click Discount",
					"tooltip": "Huge Click reduces the cost of items by a portion of your Huge Click's damage bonus for 4 seconds." ,
					"flavorText": "Huge Click Discount's duration is not decreased by haste.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("HugeClickDiscount", 1);},  
					"icon": "damagex3"
				},
				"Q43": { 
					"name": "Reload Rampage",
					"tooltip": "Reload also returns your current gold to the amount you had at the beginning of the zone, then increases it by Reload's bonus." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("ReloadRampage", 1);},  
					"icon": "damagex3"
				},
				"Q44": { 
					"name": "Preload",
					"tooltip": "Reload reduces the cooldown of the next skill used by 50%." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("Preload", 1);},  
					"icon": "damagex3"
				},
				"Q45": { 
					"name": "Quick Reload",
					"tooltip": "Reload's effects and cooldown are reduced by 80%." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {applySmallReloads(); },  
					"icon": "damagex3"
				},
				"Q61": { 
					"name": "Bhaal's Rise",
					"tooltip": "Scoring a Critical Hit reduces the remaining cooldown of Mana Crit by 1 second." ,
					"flavorText": "Casting a cooldown-improved Mana Crit will reset the cooldown of your *next* Mana Crit to its original duration.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("BhaalsRise", 1);},  
					"icon": "damagex3"
				},
				"Q62": { 
					"name": "Improved Mana Crit",
					"tooltip": "Crit Chance increases the damage of Mana Crit and gives a chance to refund its mana cost, by the amount of Crit Chance you have." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("ImprovedManaCrit", 1);},  
					"icon": "damagex3"
				},
				"Q63": { 
					"name": "Critical Killing Surge",
					"tooltip": "Monsters killed with a Critical Hit reduces the cooldown of Powersurge by 5 seconds." ,
					"flavorText": "Casting a cooldown-improved Powersurge will reset the cooldown of your *next* Powersurge to its original duration.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("CritKillPowerSurgeCooldown", 1);},  
					"icon": "damagex3"
				},
				"Q64": { 
					"name": "Mana Crit Overflow",
					"tooltip": "Overkill from Mana Crit damages the next monster." ,
					"flavorText": "It will not spill damage over to more than one additional monster.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("ManaCritOverflow", 1);},  
					"icon": "damagex3"
				},
				"Q65": { 
					"name": "CritStorm",
					"tooltip": CRITSTORM_TOOLTIP,
					"flavorText": "Replaces Clickstorm.", //"Bhaal's Favorite.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.buffs.removeBuff("Clickstorm"); CH2.currentCharacter.replaceSkill("Clickstorm", CH2.currentCharacter.getStaticSkill("Critstorm")); },
					"icon": "damagex3"
				},
				"Q66": { 
					"name": "Critical Powersurge",
					"tooltip": "PowerSurge, upon activating, increases Crit Chance by 1% every second until it ends." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("PowerSurgeCritChance", 1);},  
					"icon": "damagex3"
				},
				"Q81": { 
					"name": "Limitless Haste",
					"tooltip": "Removes the 1-second minimum limit on Global Cooldown, allowing Haste to reduce it below 1 second." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.gcdMinimum = 0.1; },  
					"icon": "damagex3"
				},
				"Q82": { 
					"name": "Flurry",
					"tooltip": "Haste increases the number of clicks in a MultiClick by the percentage of haste you have." ,
					"flavorText": "Rounded up or rounded down? Only the Ancients know.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("Flurry", 1);},  
					"icon": "damagex3"
				},
				"Q83": { 
					"name": "Killing Frenzy",
					"tooltip": "Multiply your haste by 150% upon killing a monster. Lasts 5 seconds. Does not stack, but the timer will reset with each kill." ,
					"flavorText": "Killing Frenzy's duration is not decreased by haste.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("KillingFrenzy", 1);},  
					"icon": "damagex3"
				},
				"Q84": { 
					"name": "Small Clicks",
					"tooltip": "Makes your Big Clicks smaller. Small Clicks are half as strong, but there are twice as many of them." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("DistributedBigClicks", 1);},  
					"icon": "damagex3"
				},
				"Q85": { 
					"name": "Expandable Small Clicks",
					"tooltip": "Haste increases the number of charges from Small Clicks, by the percentage of haste you have." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("DistributedBigClicksScaling", 1);},  
					"icon": "damagex3"
				},
				"Q86": { 
					"name": "Stormbringer",
					"tooltip": "Small Clicks decreases the remaining cooldown of ClickTorrent by 1 second each." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("Stormbringer", 1);},  
					"icon": "damagex3"
				},
				"Q87": { 
					"name": "Hecaton's Echo",
					"tooltip": "Huge Click, when activated, also triggers on every 20th click for the next 100 clicks." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("HecatonsEcho", 1);},  
					"icon": "damagex3"
				},
				"Q88": { 
					"name": "ClickTorrent",
					"tooltip": CLICKTORRENT_TOOLTIP,
					"flavorText": "Replaces Clickstorm.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.buffs.removeBuff("Clickstorm"); CH2.currentCharacter.replaceSkill("Clickstorm", CH2.currentCharacter.getStaticSkill("Clicktorrent")); },  
					"icon": "damagex3"
				},
				//###################################################################
				//############################ AUTOMATOR ############################
				//###################################################################
				"A00": {
					"name": "Automator",
					"tooltip": "Unlocks the Automator." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"alwaysAvailable": true,
					"loadFunction": function() { },
					"setupFunction": function() { unlockAutomator(); CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_15", tripleClick); CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_16", bigClicks);},
					"purchaseFunction": function() { purchaseAutomator();  CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_15");  CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_16"); },
					"icon": "automator"
				},
				"A01": { 
					"name": "Gem: MultiClick",
					"tooltip": "Automates MultiClick." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_15", tripleClick); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_15");  },
					"icon": "gemNineClicks"
				},
				"A03": { 
					"name": "Gem: Big Clicks",
					"tooltip": "Automates Big Clicks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_16", bigClicks); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_16"); },
					"icon": "gemGameBigClicks"
				},
				"A05": { 
					"name": "Gem: Huge Click",
					"tooltip": "Automates Huge Click." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_17", hugeClick); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_17"); },
					"icon": "gemHugeClicks"
				},
				"A04": { 
					"name": "Gem: Clickstorm",
					"tooltip": "Automates Clickstorm." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_51", clickstorm); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_51"); },
					"icon": "gemClickstorm"
				},
				"A02": { 
					"name": "Gem: Energize.",
					"tooltip": "Automates Energize." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_18", energize); },
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_18"); },
					"icon": "gemEnergize"
				},
				"A06": { 
					"name": "Gem: Powersurge.",
					"tooltip": "Automates Powersurge." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_19", powerSurge); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_19"); },
					"icon": "gemPowersurge"
				},
				"A07": { 
					"name": "Gem: Mana Crit",
					"tooltip": "Automates Mana Crit." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_20", manaClick); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_20"); },
					"icon": "gemManaClick" 
				},
				"A08": { 
					"name": "Gem: Reload",
					"tooltip": "Automates Reload." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_52", reload); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_52"); },
					"icon": "gemReload" 
				},
				"A11": { 
					"name": "Gem: AutoAttack Storm",
					"tooltip": "Automates AutoAttack Storm. " ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_56", autoAttackstorm); },
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_56"); },
					"icon": "gemClickstorm"
				},
				"A12": { 
					"name": "Gem: ClickTorrent",
					"tooltip": "Automates ClickTorrent." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_57", clicktorrent ); },
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_57"); },
					"icon": "gemClickstorm"
				},
				"A13": { 
					"name": "Gem: Golden Clicks",
					"tooltip": "Automates Golden Clicks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_58", goldenClicks ); },
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_58"); },
					"icon": "gemClickstorm"
				},
				"A14": { 
					"name": "Gem: Critstorm",
					"tooltip": "Automates Critstorm." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_59", critstorm); },
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_59"); },
					"icon": "gemClickstorm"
				},
				"A15": { 
					"name": "Gem: Managize",
					"tooltip": "Automates Managize. " ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_55", managize); },
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_55"); },
					"icon": "gemEnergize"
				},
				"A20": { 
					"name": "Gem: Buy Random Catalog",
					"tooltip": "Automates Buying a Random Catalog Item." ,
					"flavorText": "The Catalog is that area on the bottom left of the UI where you purchase new items.",
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuyRandomCatalogItemGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_4");  },
					"icon": "gemBuyRandom"
				},
				"A21": { 
					"name": "Gem: Upgrade Cheapest Item",
					"tooltip": "Automates Upgrading the Cheapest Item. It can also purchase a new item, if that is cheaper than all of your upgrades." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addUpgradeCheapestItemGem();},
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_5");},
					"icon": "gemUpgradeCheapest"
				},
				"A24": { 
					"name": "Gem: Upgrade Newest Item",
					"tooltip": "Automates upgrading the Newest Item." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addUpgradeNewestItemGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_53");  },
					"icon": "gemBuyRandom"
				},
				"A26": { 
					"name": "Gem: Upgrade All Items ",
					"tooltip": "Automates upgrading All Items." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addUpgradeAllItemsGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_54");  },
					"icon": "gemBuyRandom"
				},
				"A31": { 
					"name": "Gem: Swapping to set 1",
					"tooltip": "Automates swapping to set 1." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addSwapToFirstSet(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_80");  },
					"icon": "gemUpgradeCheapest"
				},
				"A32": { 
					"name": "Gem: Swapping to set 2",
					"tooltip": "Automates swapping to set 2." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addSwapToSecondSet(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_81");  },
					"icon": "gemUpgradeCheapest"
				},
				"A33": { 
					"name": "Gem: Swapping to set 3",
					"tooltip": "Automates swapping to set 3." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addSwapToThirdSet(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_82");  },
					"icon": "gemUpgradeCheapest"
				},
				"A34": { 
					"name": "Gem: Swapping to set 4",
					"tooltip": "Automates swapping to set 4." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addSwapToFourthSet(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_83");  },
					"icon": "gemUpgradeCheapest"
				},
				"A35": { 
					"name": "Gem: Swapping to set 5",
					"tooltip": "Automates swapping to set 5." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addSwapToFifthSet(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_84");  },
					"icon": "gemUpgradeCheapest"
				},
				"A36": {
					"name": "Gem: Next Set",
					"tooltip": "Switch to the next Automator Set." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){ addNextSetGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_21"); },
					"icon": "gemSwitchNext"
				},
				"A37": {
					"name": "Gem: Previous Set",
					"tooltip": "Switch to the previous Automator Set." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){ addPreviousSetGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_22"); },
					"icon": "gemSwitchPrev"
				},
				"A38": { 
					"name": "Additional Automator Set",
					"tooltip": "Unlocks an additional set for the Automator." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.automator.addQueueSet(); },
					"icon": "gemAddSet"
				},
				"A39": {
					"name": "Automator Speed",
					"tooltip": "Speeds up the Automator by 25%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.levelUpStat(CH2.STAT_AUTOMATOR_SPEED); },
					"icon": "automatorSpeed"
				},
				"S20": { 
					"name": "Stone: Always",
					"tooltip": "A stone that can always activate." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addAlwaysStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_1");  },
					"icon": "always"
				},
				"S01": { 
					"name": "Stone: MH more than 50%",
					"tooltip": "A stone that can activate when the next monster's health is greater than 50%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addMHGreaterThan50PercentStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_5");  },
					"icon": "mhGreater50"
				},
				"S02": { 
					"name": "Stone: MH less than 50%",
					"tooltip": "A stone that can activate when the next monster's health is less than 50%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addMHLessThan50PercentStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_6"); },
					"icon": "mhLower50"
				},
				"S03": { 
					"name": "Stone: Energy more than 90%",
					"tooltip": "A stone that can activate when your energy is above 90%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addGreaterThan90PercentEnergyStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_7"); },
					"icon": "energyGreater90"
				},
				"S04": { 
					"name": "Stone: Energy less than 10%",
					"tooltip": "A stone that can activate when your energy is below 10%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addLessThan10PercentEnergyStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_8");},
					"icon": "energyLower10"
				},
				"S05": { 
					"name": "Stone: Mana more than 90%",
					"tooltip": "A stone that can activate when your mana is above 90%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addGreaterThan90PercentManaStone(); },
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_9");},
					"icon": "manaGreater90"
				},
				"S06": { 
					"name": "Stone: Mana less than 10%",
					"tooltip": "A stone that can activate when your mana is below 10%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){ addLessThan10PercentManaStone(); },
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_10");},
					"icon": "manaLower10"
				},
				"S07": {
					"name": "Stone: Zone Start",
					"tooltip": "A stone that can activate during the first half of a zone." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addZoneStartStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_19"); },
					"icon": "zoneStart"
				},
				"S08": {
					"name": "Stone: Zone Middle",
					"tooltip": "A stone that can activate during the second half of a zone." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addZoneMiddleStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_20"); },
					"icon": "zoneMiddle"
				},
				"S21": {
					"name": "Stone: 4s CD",
					"tooltip": "A stone that can activate once every 4 seconds." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_11", 4000);},
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_11"); },
					"icon": "CD4S"
				},
				"S22": { 
					"name": "Stone: 8s CD",
					"tooltip": "A stone that can activate once every 8 seconds." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_12", 8000);},
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_12"); },
					"icon": "CD8S"
				},
				"S23": { 
					"name": "Stone: 40s CD",
					"tooltip": "A stone that can activate once every 40 seconds." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_13", 40000);},
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_13"); },
					"icon": "CD40S"
				},
				"S24": { 
					"name": "Stone: 90s CD",
					"tooltip": "A stone that can activate once every 90 seconds." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_14", 90000);},
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_14"); },
					"icon": "CD90S"
				},
				"S25": { 
					"name": "Stone: 10m CD",
					"tooltip": "A stone that can activate once every 10 minutes." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_15", 600000);},
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_15");},
					"icon": "CD10M"
				},
				"S61": { 
					"name": "Stone: Energize is not active.",
					"tooltip": "A stone that can activate when Energize is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("EnergizeEQ0", "Energize = 0", "A stone that can activate when Energize is not active.", "Energize", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("EnergizeEQ0");  },
					"icon": "gemEnergize"
				},
				"S62": { 
					"name": "Stone: Huge Click is not active.",
					"tooltip": "A stone that can activate when Huge Click is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("HugeClickEQ0", "Huge Click = 0", "A stone that can activate when Huge Click is not active.", "Huge Click", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("HugeClickEQ0");  },
					"icon": "gemHugeClicks"
				},
				"S63": { 
					"name": "Stone: Huge Click more than 0",
					"tooltip": "A stone that can activate when Huge Click is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("HugeClickGT0", "Huge Click > 0", "A stone that can activate when Huge Click is active.", "Huge Click", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("HugeClickGT0");  },
					"icon": "gemHugeClicks"
				},
				"S51": { 
					"name": "Stone: Clickstorm is not active.",
					"tooltip": "A stone that can activate when Clickstorm is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("ClickstormEQ0", "Clickstorm = 0", "A stone that can activate when Clickstorm is not active.", "Clickstorm", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("ClickstormEQ0");  },
					"icon": "gemClickstorm"
				},
				"S52": { 
					"name": "Stone: Clickstorm more than 0",
					"tooltip": "A stone that can activate when Clickstorm is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("ClickstormGT0", "Clickstorm > 0", "A stone that can activate when Clickstorm is active.", "Clickstorm", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("ClickstormGT0");  },
					"icon": "gemClickstorm"
				},
				"S66": { 
					"name": "Stone: Powersurge is not active.",
					"tooltip": "A stone that can activate when Powersurge is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("PowersurgeEQ0", "Powersurge = 0", "A stone that can activate when Powersurge is not active.", "Powersurge", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("PowersurgeEQ0"); },
					"icon": "gemPowersurge"
				},
				"S67": { 
					"name": "Stone: Powersurge more than 0",
					"tooltip": "A stone that can activate when Powersurge is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("PowersurgeGT0", "Powersurge > 0", "A stone that can activate when Powersurge is active.", "Powersurge", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("PowersurgeGT0"); },
					"icon": "gemPowersurge"
				},
				"S68": { 
					"name": "Stone: Big Clicks is not active.",
					"tooltip": "A stone that can activate when Big Clicks is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksEQ0", "Big Clicks = 0", "A stone that can activate when Big Clicks is not active.", "Big Clicks", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("BigClicksEQ0"); },
					"icon": "gemGameBigClicks"
				},
				"S69": { 
					"name": "Stone: Big Clicks more than 0",
					"tooltip": "A stone that can activate when Big Clicks is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksGT0", "Big Clicks > 0", "A stone that can activate when Big Clicks is active.", "Big Clicks", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("BigClicksGT0");  },
					"icon": "gemGameBigClicks"
				},
				"S70": { 
					"name": "Stone: Big Clicks less than 10",
					"tooltip": "A stone that can activate when Big Clicks has less than 10 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksLT10", "Big Clicks < 10", "A stone that can activate when Big Clicks has less than 10 stacks.", "Big Clicks", CH2.COMPARISON_LT, 10); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("BigClicksLT10");  },
					"icon": "gemGameBigClicks"
				},
				"S71": { 
					"name": "Stone: Big Clicks more than 10",
					"tooltip": "A stone that can activate when Big Clicks has more than 10 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksGT10", "Big Clicks > 10", "A stone that can activate when Big Clicks has more than 10 stacks.", "Big Clicks", CH2.COMPARISON_GT, 10); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("BigClicksGT10");  },
					"icon": "gemGameBigClicks"
				},
				"S72": { 
					"name": "Stone: Big Clicks less than 50",
					"tooltip": "A stone that can activate when Big Clicks has less than 50 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksLT50", "Big Clicks < 50", "A stone that can activate when Big Clicks has less than 50 stacks.", "Big Clicks", CH2.COMPARISON_LT, 50); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("BigClicksLT50");  },
					"icon": "gemGameBigClicks"
				},
				"S73": { 
					"name": "Stone: Big Clicks more than 50",
					"tooltip": "A stone that can activate when Big Clicks has more than 50 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksGT50", "Big Clicks > 50", "A stone that can activate when Big Clicks has more than 50 stacks.", "Big Clicks", CH2.COMPARISON_GT, 50); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("BigClicksGT50");  },
					"icon": "gemGameBigClicks"
				},
				"S74": { 
					"name": "Stone: Big Clicks less than 100",
					"tooltip": "A stone that can activate when Big Clicks has less than 100 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksLT100", "Big Clicks < 100", "A stone that can activate when Big Clicks has less than 100 stacks.", "Big Clicks", CH2.COMPARISON_LT, 100); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("BigClicksLT100");  },
					"icon": "gemGameBigClicks"
				},
				"S75": { 
					"name": "Stone: Big Clicks more than 100",
					"tooltip": "A stone that can activate when Big Clicks has more than 100 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksGT100", "Big Clicks > 100", "A stone that can activate when Big Clicks has more than 100 stacks.", "Big Clicks", CH2.COMPARISON_GT, 100); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("BigClicksGT100");  },
					"icon": "gemGameBigClicks"
				},
				"S76": { 
					"name": "Stone: Big Clicks less than 200",
					"tooltip": "A stone that can activate when Big Clicks has less than 200 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksLT200", "Big Clicks < 200", "A stone that can activate when Big Clicks has less than 200 stacks.", "Big Clicks", CH2.COMPARISON_LT, 200); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("BigClicksLT200");  },
					"icon": "gemGameBigClicks"
				},
				"S77": { 
					"name": "Stone: Big Clicks more than 200",
					"tooltip": "A stone that can activate when Big Clicks has more than 200 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksGT200", "Big Clicks > 200", "A stone that can activate when Big Clicks has more than 200 stacks.", "Big Clicks", CH2.COMPARISON_GT, 200); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("BigClicksGT200");  },
					"icon": "gemGameBigClicks"
				},
				"S78": { 
					"name": "Stone: Big Clicks more than MultiClick",
					"tooltip": "A stone that can activate when Big Clicks has more stacks than MultiClick can click." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBigClicksGTMultiClicksStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("BigClicksGTMultiClicks");  },
					"icon": "gemGameBigClicks"
				},
				"S79": { 
					"name": "Stone: Big Clicks is less than MultiClick",
					"tooltip": "A stone that can activate when Big Clicks does not have more stacks than MultiClick can click." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBigClicksLTEMultiClicksStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("BigClicksLTEMultiClicks");  },
					"icon": "gemGameBigClicks"
				},
				"S80": { 
					"name": "Stone: Juggernaut more than 20",
					"tooltip": "A stone that can activate when Juggernaut has more than 20 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("JuggernautGT20", "Juggernaut > 20", "A stone that can activate when Juggernaut has more than 20 stacks.", "Curse Of The Juggernaut", CH2.COMPARISON_GT, 20); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("JuggernautGT20");  },
					"icon": "automator"
				},
				"S81": { 
					"name": "Stone: Juggernaut more than 50",
					"tooltip": "A stone that can activate when Juggernaut has more than 50 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("JuggernautGT50", "Juggernaut > 50", "A stone that can activate when Juggernaut has more than 50 stacks.", "Curse Of The Juggernaut", CH2.COMPARISON_GT, 50); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("JuggernautGT50");  },
					"icon": "automator"
				},
				"S82": { 
					"name": "Stone: Juggernaut more than 100",
					"tooltip": "A stone that can activate when Juggernaut has more than 100 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("JuggernautGT100", "Juggernaut > 100", "A stone that can activate when Juggernaut has more than 100 stacks.", "Curse Of The Juggernaut", CH2.COMPARISON_GT, 100); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("JuggernautGT100");  },
					"icon": "automator"
				},
				"S83": { 
					"name": "Stone: Juggernaut more than 200",
					"tooltip": "A stone that can activate when Juggernaut has more than 200 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("JuggernautGT200", "Juggernaut > 200", "A stone that can activate when Juggernaut has more than 200 stacks.", "Curse Of The Juggernaut", CH2.COMPARISON_GT, 200); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("JuggernautGT200");  },
					"icon": "automator"
				},
				"V": { 
					"name": "Automator Point",
					"tooltip": "Adds an Automator Point.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.automatorPoints++;  },
					"icon": "automator"
				},
				//###################################################################
				//#TEST NODES AND/OR NODES THAT ARE NOT AND MAY NEVER BE IMPLEMENTED#
				//###################################################################		
				"qCc": { 
					"name": "+20% Crit Chance",
					"tooltip": "This Node does not actually exist in the game." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_CHANCE, 10)},
					"icon": "critChance"
				},
				"": {
					"name": "NULL",
					"tooltip": "Does Absolutely NOTHING.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {},
					"icon": "goldx3"
				},
				"Z01": { 
					"name": "Gem: Attempt Boss",
					"tooltip": "Automates Attempting a Boss." ,
					"flavorText": null,
					"setupFunction": function() { addAttemptBossGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_10");  },
					"icon": "gemAttemptBoss"
				},
				"A9": { 
					"name": "Gem: Dash",
					"tooltip": "Automates Dash." ,
					"flavorText": null,
					"setupFunction": function() { addDashGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_3");  },
					"icon": "gemDash"
				},
				"A27": { 
					"name": "Gem: Spend All Gold on Cheapest Upgrades",
					"tooltip": "Automates spending all gold on Cheapest Upgrades." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addUpgradeAllCheapestItemsGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_62"); },
					"icon": "gemUpgradeCheapest"
				},
				"Z00": { 
					"name": "Automator Slot",
					"tooltip": "Unlocks an additional slot for the Automator." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.automator.addQueueSlot(); },
					"icon": "gemAddSlot"
				},
				"Pc": { 
					"name": "Pierce Chance (NOT IN GAME)",
					"tooltip": "Adds 1% to your chance to hit an additional monster." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_PIERCE_CHANCE, 5)},
					"icon": "pierceChance"
				},
				//###################################################################
				//#################### NEW NODES FOR PATCH 0.08 #####################
				//###################################################################
				"A22": { 
					"name": "Gem: Upgrade 3rd Newest Item",
					"tooltip": "Automates upgrading the Third Newest Item." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addUpgradeThirdNewestItemGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_60"); },
					"icon": "gemBuyRandom"
				},
				"A23": { 
					"name": "Gem: Upgrade 2nd Newest Item",
					"tooltip": "Automates upgrading the Second Newest Item." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addUpgradeSecondNewestItemGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_61"); },
					"icon": "gemBuyRandom"
				},
				"A25": { 
					"name": "Gem: Upgrade Cheapest Item to x10",
					"tooltip": "Automates upgrading the Cheapest Item to the next Multiplier." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addUpgradeCheapestItemToNextMultiplierGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_63"); },
					"icon": "gemBuyRandom"
				},
				"A28": { 
					"name": "Gem: Buy Metal Detectors",
					"tooltip": "Automates buying Metal Detectors." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuyMetalDetectorsGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_64"); },
					"icon": "gemBuyRandom"
				},
				"A29": { 
					"name": "Gem: Buy Runes",
					"tooltip": "Automates buying Runes." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuyRunesGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_65"); },
					"icon": "gemBuyRandom"
				},
				"A30": { 
					"name": "Stone: World Completions < 1",
					"tooltip": "A stone that always activates on the first run of a world." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addLT1WorldCompletionsStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("LT1WorldCompletions"); },
					"icon": ""
				},
				"A31": { 
					"name": "Stone: World Completions > 1",
					"tooltip": "A stone that always activates on repeated runs of a world." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addGT1WorldCompletionsStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("GT1WorldCompletions"); },
					"icon": ""
				},
				"S09": {
					"name": "Stone: Boss Zone",
					"tooltip": "A stone that can activate during a boss fight." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBossEncounterStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_18"); },
					"icon": "gemAttemptBoss"
				},
				"S10": { 
					"name": "Stone: Crit Chance >= 100%",
					"tooltip": "A stone that can activate when your chance to score a critical hit is above 99%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addCritThresholdStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_21"); },
					"icon": "gemAddSet"
				},
				"S11": { 
					"name": "Stone: Energy more than Mana",
					"tooltip": "A stone that can activate when your energy is above your mana." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addEnergyGreaterThanManaStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_22"); },
					"icon": ""
				},
				"S12": { 
					"name": "Stone: Mana more than Energy",
					"tooltip": "A stone that can activate when your mana is above your energy." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addManaGreaterThanEnergyStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_23"); },
					"icon": ""
				},
				"S13": { 
					"name": "Stone: Energy less than 40%",
					"tooltip": "A stone that can activate when your energy is below 40%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addEnergyLessThan40PercentStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_24"); },
					"icon": ""
				},
				"S14": { 
					"name": "Stone: Energy more than 60%",
					"tooltip": "A stone that can activate when your energy is above 60%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addEnergyGreaterThan60PercentStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_25"); },
					"icon": ""
				},
				"S15": { 
					"name": "Stone: Mana less than 40%",
					"tooltip": "A stone that can activate when your mana is below 40%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addManaLessThan40PercentStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_26"); },
					"icon": ""
				},
				"S16": { 
					"name": "Stone: Mana more than 60%",
					"tooltip": "A stone that can activate when your mana is above 60%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addManaGreaterThan60PercentStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_27"); },
					"icon": ""
				},
				"S17": { 
					"name": "Stone: Before First Zone Kill",
					"tooltip": "A stone that can activate before killing the first monster of a zone." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBeforeFirstZoneKillStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_28"); },
					"icon": ""
				},
				"S53": { 
					"name": "Stone: Autoattackstorm is not active",
					"tooltip": "A stone that can activate when Autoattackstorm is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuffComparisonStone("AutoattackstormEQ0", "Autoattackstorm = 0", "A stone that can activate when Autoattackstorm is not active.", "Autoattackstorm", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("AutoattackstormEQ0"); },
					"icon": "gemClickstorm"
				},
				"S54": { 
					"name": "Stone: Autoattackstorm is active",
					"tooltip": "A stone that can activate when Autoattackstorm is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("AutoattackstormGT0", "Autoattackstorm > 0", "A stone that can activate when Autoattackstorm is active.", "Autoattackstorm", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("AutoattackstormGT0"); },
					"icon": "gemClickstorm"
				},
				"S55": { 
					"name": "Stone: Critstorm is not active",
					"tooltip": "A stone that can activate when Critstorm is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuffComparisonStone("CritstormEQ0", "Critstorm = 0", "A stone that can activate when Critstorm is not active.", "Critstorm", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("CritstormEQ0"); },
					"icon": "gemClickstorm"
				},
				"S56": { 
					"name": "Stone: Critstorm is active",
					"tooltip": "A stone that can activate when Critstorm is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("CritstormGT0", "Critstorm > 0", "A stone that can activate when Critstorm is active.", "Critstorm", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("CritstormGT0"); },
					"icon": "gemClickstorm"
				},
				"S57": { 
					"name": "Stone: Golden Clicks is not active",
					"tooltip": "A stone that can activate when Golden Clicks is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuffComparisonStone("GoldenClicksEQ0", "Golden Clicks = 0", "A stone that can activate when Golden Clicks is not active.", "GoldenClicks", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("GoldenClicksEQ0"); },
					"icon": "gemClickstorm"
				},
				"S58": { 
					"name": "Stone: Golden Clicks is active",
					"tooltip": "A stone that can activate when Golden Clicks is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("GoldenClicksGT0", "Golden Clicks > 0", "A stone that can activate when Golden Clicks is active.", "GoldenClicks", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("GoldenClicksGT0"); },
					"icon": "gemClickstorm"
				},
				"S59": { 
					"name": "Stone: Clicktorrent is not active",
					"tooltip": "A stone that can activate when Clicktorrent is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuffComparisonStone("ClicktorrentEQ0", "Clicktorrent = 0", "A stone that can activate when Clicktorrent is not active.", "Clicktorrent", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("ClicktorrentEQ0"); },
					"icon": "gemClickstorm"
				},
				"S60": { 
					"name": "Stone: Clicktorrent is active",
					"tooltip": "A stone that can activate when Clicktorrent is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("ClicktorrentGT0", "Clicktorrent > 0", "A stone that can activate when Clicktorrent is active.", "Clicktorrent", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("ClicktorrentGT0"); },
					"icon": "gemClickstorm"
				},
				"S64": { 
					"name": "Stone: Discount is active",
					"tooltip": "A stone that can activate when Huge Click Discount is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("DiscountGT0", "Discount > 0", "A stone that can activate when Huge Click Discount is active.", "Huge Click Discount", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("DiscountGT0"); },
					"icon": "gemHugeClicks"
				},
				"S65": { 
					"name": "Stone: Preload is active",
					"tooltip": "A stone that can activate when Preload is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("PreloadGT0", "Preload > 0", "A stone that can activate when Preload is active.", "Preload", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("PreloadGT0"); },
					"icon": "gemReload"
				}
			}
			
			helpfulAdventurer.levelGraphObject = {"edges":[{"1":[77,541]},{"2":[341,405]},{"3":[831,838]},{"4":[346,347]},{"5":[662,663]},{"6":[200,207]},{"7":[126,128]},{"8":[319,423]},{"9":[5,8]},{"10":[669,670]},{"11":[119,122]},{"12":[250,259]},{"13":[154,215]},{"14":[488,543]},{"15":[203,259]},{"16":[123,643]},{"17":[78,654]},{"18":[517,563]},{"19":[189,193]},{"20":[360,425]},{"21":[204,205]},{"22":[17,841]},{"23":[185,241]},{"24":[131,186]},{"25":[548,560]},{"26":[51,194]},{"27":[528,529]},{"28":[324,434]},{"29":[358,361]},{"30":[16,21]},{"31":[404,439]},{"32":[184,189]},{"33":[327,437]},{"34":[442,657]},{"35":[108,450]},{"36":[146,193]},{"37":[526,597]},{"38":[490,554]},{"39":[41,129]},{"40":[160,161]},{"41":[157,216]},{"42":[830,831]},{"43":[87,633]},{"44":[516,614]},{"45":[386,391]},{"46":[94,461]},{"47":[262,270]},{"48":[340,367]},{"49":[157,220]},{"50":[61,62]},{"51":[312,387]},{"52":[16,25]},{"53":[489,541]},{"54":[384,385]},{"55":[370,415]},{"56":[534,586]},{"57":[61,457]},{"58":[75,114]},{"59":[652,653]},{"60":[234,235]},{"61":[649,650]},{"62":[179,269]},{"63":[517,528]},{"64":[472,514]},{"65":[546,549]},{"66":[83,104]},{"67":[510,512]},{"68":[317,331]},{"69":[56,667]},{"70":[155,262]},{"71":[778,822]},{"72":[343,368]},{"73":[307,392]},{"74":[506,510]},{"75":[35,36]},{"76":[88,630]},{"77":[592,605]},{"78":[140,275]},{"79":[400,401]},{"80":[180,249]},{"81":[1,2]},{"82":[315,331]},{"83":[271,277]},{"84":[76,634]},{"85":[626,646]},{"86":[311,359]},{"87":[840,846]},{"88":[84,633]},{"89":[834,836]},{"90":[832,840]},{"91":[482,618]},{"92":[556,560]},{"93":[99,441]},{"94":[638,640]},{"95":[203,206]},{"96":[164,169]},{"97":[66,70]},{"98":[393,403]},{"99":[96,655]},{"100":[570,574]},{"101":[320,423]},{"102":[469,639]},{"103":[282,458]},{"104":[63,170]},{"105":[53,430]},{"106":[207,208]},{"107":[296,398]},{"108":[149,222]},{"109":[140,249]},{"110":[559,562]},{"111":[168,187]},{"112":[523,524]},{"113":[547,599]},{"114":[287,444]},{"115":[253,254]},{"116":[290,646]},{"117":[151,265]},{"118":[576,577]},{"119":[561,602]},{"120":[477,583]},{"121":[208,209]},{"122":[336,663]},{"123":[564,565]},{"124":[387,388]},{"125":[54,582]},{"126":[236,239]},{"127":[485,522]},{"128":[42,130]},{"129":[807,824]},{"130":[17,22]},{"131":[335,336]},{"132":[211,212]},{"133":[571,574]},{"134":[427,439]},{"135":[579,580]},{"136":[574,575]},{"137":[463,625]},{"138":[177,178]},{"139":[339,368]},{"140":[100,448]},{"141":[102,107]},{"142":[33,50]},{"143":[11,12]},{"144":[142,171]},{"145":[479,515]},{"146":[378,431]},{"147":[233,267]},{"148":[214,276]},{"149":[548,557]},{"150":[487,614]},{"151":[473,562]},{"152":[72,82]},{"153":[91,121]},{"154":[809,824]},{"155":[520,523]},{"156":[532,568]},{"157":[401,402]},{"158":[559,568]},{"159":[521,522]},{"160":[115,117]},{"161":[21,36]},{"162":[805,843]},{"163":[81,108]},{"164":[143,192]},{"165":[127,379]},{"166":[325,363]},{"167":[28,32]},{"168":[309,407]},{"169":[779,822]},{"170":[304,316]},{"171":[489,539]},{"172":[126,632]},{"173":[328,666]},{"174":[358,388]},{"175":[239,273]},{"176":[400,424]},{"177":[85,227]},{"178":[816,836]},{"179":[601,620]},{"180":[132,197]},{"181":[363,408]},{"182":[541,542]},{"183":[254,255]},{"184":[783,805]},{"185":[243,245]},{"186":[45,606]},{"187":[53,340]},{"188":[73,125]},{"189":[623,624]},{"190":[468,637]},{"191":[207,228]},{"192":[538,539]},{"193":[783,848]},{"194":[295,403]},{"195":[298,406]},{"196":[790,845]},{"197":[175,202]},{"198":[122,123]},{"199":[471,520]},{"200":[198,229]},{"201":[557,558]},{"202":[624,625]},{"203":[793,827]},{"204":[69,658]},{"205":[114,674]},{"206":[264,266]},{"207":[549,550]},{"208":[237,270]},{"209":[90,92]},{"210":[229,673]},{"211":[814,816]},{"212":[191,192]},{"213":[20,21]},{"214":[48,49]},{"215":[422,424]},{"216":[80,462]},{"217":[165,169]},{"218":[176,177]},{"219":[342,376]},{"220":[64,65]},{"221":[226,237]},{"222":[17,18]},{"223":[97,628]},{"224":[179,213]},{"225":[119,446]},{"226":[138,214]},{"227":[588,612]},{"228":[537,543]},{"229":[389,420]},{"230":[222,280]},{"231":[641,642]},{"232":[377,378]},{"233":[356,439]},{"234":[543,544]},{"235":[487,529]},{"236":[481,558]},{"237":[305,348]},{"238":[342,430]},{"239":[519,563]},{"240":[175,181]},{"241":[273,278]},{"242":[216,245]},{"243":[202,280]},{"244":[483,531]},{"245":[379,416]},{"246":[308,319]},{"247":[503,599]},{"248":[171,172]},{"249":[200,227]},{"250":[151,259]},{"251":[670,673]},{"252":[395,405]},{"253":[219,221]},{"254":[318,429]},{"255":[355,432]},{"256":[342,418]},{"257":[118,123]},{"258":[512,513]},{"259":[323,398]},{"260":[476,527]},{"261":[75,459]},{"262":[101,441]},{"263":[527,535]},{"264":[566,567]},{"265":[486,587]},{"266":[146,210]},{"267":[486,505]},{"268":[231,672]},{"269":[345,411]},{"270":[494,565]},{"271":[382,383]},{"272":[841,842]},{"273":[334,434]},{"274":[380,386]},{"275":[74,124]},{"276":[316,351]},{"277":[11,14]},{"278":[338,397]},{"279":[553,554]},{"280":[471,519]},{"281":[24,63]},{"282":[503,504]},{"283":[159,204]},{"284":[132,166]},{"285":[829,847]},{"286":[519,553]},{"287":[110,112]},{"288":[161,162]},{"289":[29,846]},{"290":[806,809]},{"291":[787,791]},{"292":[325,438]},{"293":[536,538]},{"294":[317,413]},{"295":[799,808]},{"296":[109,654]},{"297":[790,825]},{"298":[338,355]},{"299":[374,375]},{"300":[64,460]},{"301":[23,38]},{"302":[385,386]},{"303":[19,25]},{"304":[297,410]},{"305":[392,432]},{"306":[806,812]},{"307":[573,606]},{"308":[215,221]},{"309":[308,371]},{"310":[349,429]},{"311":[67,658]},{"312":[482,540]},{"313":[665,666]},{"314":[106,468]},{"315":[113,121]},{"316":[305,431]},{"317":[79,124]},{"318":[179,180]},{"319":[515,545]},{"320":[396,412]},{"321":[99,102]},{"322":[224,236]},{"323":[153,274]},{"324":[484,580]},{"325":[218,219]},{"326":[159,183]},{"327":[253,257]},{"328":[144,238]},{"329":[54,55]},{"330":[591,612]},{"331":[399,433]},{"332":[57,116]},{"333":[479,510]},{"334":[563,564]},{"335":[572,588]},{"336":[372,409]},{"337":[634,636]},{"338":[630,648]},{"339":[83,664]},{"340":[589,669]},{"341":[798,825]},{"342":[71,469]},{"343":[158,179]},{"344":[811,818]},{"345":[366,411]},{"346":[100,125]},{"347":[361,421]},{"348":[500,607]},{"349":[29,784]},{"350":[284,287]},{"351":[511,569]},{"352":[234,270]},{"353":[117,466]},{"354":[571,600]},{"355":[42,59]},{"356":[293,418]},{"357":[612,613]},{"358":[335,351]},{"359":[85,86]},{"360":[267,274]},{"361":[531,533]},{"362":[182,213]},{"363":[611,615]},{"364":[628,629]},{"365":[109,632]},{"366":[165,166]},{"367":[511,539]},{"368":[530,535]},{"369":[640,648]},{"370":[640,653]},{"371":[513,514]},{"372":[480,547]},{"373":[152,182]},{"374":[142,170]},{"375":[627,656]},{"376":[58,96]},{"377":[137,177]},{"378":[498,615]},{"379":[780,802]},{"380":[801,811]},{"381":[493,556]},{"382":[115,124]},{"383":[94,95]},{"384":[364,414]},{"385":[513,537]},{"386":[780,789]},{"387":[577,578]},{"388":[830,832]},{"389":[359,362]},{"390":[589,598]},{"391":[550,595]},{"392":[10,11]},{"393":[402,429]},{"394":[194,201]},{"395":[455,626]},{"396":[268,269]},{"397":[505,569]},{"398":[248,254]},{"399":[26,46]},{"400":[572,586]},{"401":[59,668]},{"402":[671,672]},{"403":[173,178]},{"404":[474,551]},{"405":[353,397]},{"406":[49,124]},{"407":[91,93]},{"408":[794,844]},{"409":[301,425]},{"410":[248,250]},{"411":[289,651]},{"412":[15,37]},{"413":[231,233]},{"414":[218,272]},{"415":[87,88]},{"416":[104,465]},{"417":[385,440]},{"418":[271,272]},{"419":[128,470]},{"420":[504,520]},{"421":[72,465]},{"422":[344,391]},{"423":[107,111]},{"424":[491,578]},{"425":[146,199]},{"426":[240,243]},{"427":[312,374]},{"428":[795,796]},{"429":[135,247]},{"430":[74,75]},{"431":[593,617]},{"432":[403,409]},{"433":[603,608]},{"434":[307,364]},{"435":[181,211]},{"436":[226,228]},{"437":[362,363]},{"438":[141,174]},{"439":[173,266]},{"440":[545,589]},{"441":[299,429]},{"442":[106,652]},{"443":[310,357]},{"444":[43,118]},{"445":[456,631]},{"446":[133,255]},{"447":[32,34]},{"448":[787,845]},{"449":[71,656]},{"450":[172,174]},{"451":[481,609]},{"452":[542,618]},{"453":[285,460]},{"454":[660,674]},{"455":[100,109]},{"456":[281,453]},{"457":[561,566]},{"458":[187,188]},{"459":[23,31]},{"460":[474,594]},{"461":[788,829]},{"462":[570,572]},{"463":[799,828]},{"464":[644,645]},{"465":[51,260]},{"466":[350,353]},{"467":[64,113]},{"468":[627,628]},{"469":[286,647]},{"470":[582,583]},{"471":[329,330]},{"472":[838,839]},{"473":[39,40]},{"474":[141,181]},{"475":[387,420]},{"476":[364,415]},{"477":[801,828]},{"478":[508,536]},{"479":[450,644]},{"480":[602,611]},{"481":[197,198]},{"482":[153,240]},{"483":[834,835]},{"484":[514,552]},{"485":[618,619]},{"486":[60,73]},{"487":[371,426]},{"488":[337,428]},{"489":[339,367]},{"490":[199,201]},{"491":[287,647]},{"492":[525,526]},{"493":[92,93]},{"494":[29,814]},{"495":[578,581]},{"496":[290,451]},{"497":[580,581]},{"498":[311,365]},{"499":[573,608]},{"500":[799,823]},{"501":[62,110]},{"502":[524,525]},{"503":[365,382]},{"504":[200,205]},{"505":[24,569]},{"506":[354,369]},{"507":[81,659]},{"508":[445,635]},{"509":[95,97]},{"510":[183,209]},{"511":[231,232]},{"512":[365,373]},{"513":[131,163]},{"514":[476,597]},{"515":[798,823]},{"516":[803,818]},{"517":[57,59]},{"518":[286,447]},{"519":[50,51]},{"520":[813,820]},{"521":[76,114]},{"522":[150,225]},{"523":[534,576]},{"524":[567,612]},{"525":[327,328]},{"526":[501,521]},{"527":[112,445]},{"528":[222,223]},{"529":[213,217]},{"530":[156,218]},{"531":[139,244]},{"532":[797,833]},{"533":[650,657]},{"534":[249,252]},{"535":[5,6]},{"536":[496,586]},{"537":[18,794]},{"538":[127,642]},{"539":[590,607]},{"540":[120,447]},{"541":[323,370]},{"542":[103,636]},{"543":[807,813]},{"544":[246,266]},{"545":[232,238]},{"546":[480,517]},{"547":[518,552]},{"548":[540,610]},{"549":[145,231]},{"550":[146,202]},{"551":[30,48]},{"552":[294,394]},{"553":[326,437]},{"554":[498,593]},{"555":[42,443]},{"556":[71,96]},{"557":[148,207]},{"558":[284,288]},{"559":[835,842]},{"560":[65,67]},{"561":[32,38]},{"562":[46,47]},{"563":[380,390]},{"564":[497,604]},{"565":[571,585]},{"566":[283,635]},{"567":[621,622]},{"568":[776,785]},{"569":[812,837]},{"570":[7,33]},{"571":[786,792]},{"572":[10,26]},{"573":[354,427]},{"574":[502,503]},{"575":[775,797]},{"576":[575,579]},{"577":[546,601]},{"578":[9,39]},{"579":[324,661]},{"580":[321,371]},{"581":[310,435]},{"582":[84,128]},{"583":[241,242]},{"584":[664,665]},{"585":[343,390]},{"586":[318,323]},{"587":[322,353]},{"588":[561,562]},{"589":[492,532]},{"590":[212,251]},{"591":[820,843]},{"592":[551,566]},{"593":[509,533]},{"594":[55,89]},{"595":[796,815]},{"596":[292,347]},{"597":[777,785]},{"598":[334,339]},{"599":[552,557]},{"600":[136,266]},{"601":[824,844]},{"602":[341,406]},{"603":[501,502]},{"604":[195,196]},{"605":[794,819]},{"606":[517,518]},{"607":[34,35]},{"608":[6,14]},{"609":[584,585]},{"610":[156,217]},{"611":[52,53]},{"612":[467,658]},{"613":[779,788]},{"614":[292,400]},{"615":[144,185]},{"616":[577,667]},{"617":[532,533]},{"618":[244,245]},{"619":[337,422]},{"620":[12,30]},{"621":[117,118]},{"622":[393,419]},{"623":[131,195]},{"624":[224,225]},{"625":[394,395]},{"626":[43,44]},{"627":[396,407]},{"628":[507,510]},{"629":[414,426]},{"630":[83,84]},{"631":[260,261]},{"632":[188,191]},{"633":[630,631]},{"634":[551,560]},{"635":[364,369]},{"636":[800,810]},{"637":[252,257]},{"638":[68,464]},{"639":[314,339]},{"640":[320,408]},{"641":[209,210]},{"642":[630,655]},{"643":[96,98]},{"644":[145,230]},{"645":[139,242]},{"646":[448,640]},{"647":[290,627]},{"648":[475,546]},{"649":[483,525]},{"650":[297,324]},{"651":[352,389]},{"652":[37,52]},{"653":[776,792]},{"654":[413,425]},{"655":[235,274]},{"656":[47,620]},{"657":[44,45]},{"658":[530,596]},{"659":[288,289]},{"660":[381,671]},{"661":[164,264]},{"662":[336,440]},{"663":[576,608]},{"664":[78,87]},{"665":[97,449]},{"666":[72,88]},{"667":[810,817]},{"668":[147,226]},{"669":[142,184]},{"670":[70,621]},{"671":[784,798]},{"672":[66,461]},{"673":[51,190]},{"674":[21,22]},{"675":[433,438]},{"676":[68,662]},{"677":[333,437]},{"678":[505,506]},{"679":[345,346]},{"680":[276,277]},{"681":[786,815]},{"682":[449,622]},{"683":[246,247]},{"684":[111,451]},{"685":[176,257]},{"686":[406,412]},{"687":[464,632]},{"688":[515,516]},{"689":[356,360]},{"690":[102,106]},{"691":[60,103]},{"692":[499,603]},{"693":[781,804]},{"694":[76,101]},{"695":[284,285]},{"696":[377,416]},{"697":[361,425]},{"698":[591,611]},{"699":[544,558]},{"700":[389,391]},{"701":[129,192]},{"702":[300,352]},{"703":[320,354]},{"704":[454,651]},{"705":[167,170]},{"706":[373,404]},{"707":[105,643]},{"708":[467,623]},{"709":[306,322]},{"710":[348,349]},{"711":[499,613]},{"712":[596,616]},{"713":[562,616]},{"714":[41,77]},{"715":[223,224]},{"716":[132,167]},{"717":[619,620]},{"718":[313,390]},{"719":[155,263]},{"720":[251,256]},{"721":[492,530]},{"722":[4,6]},{"723":[605,606]},{"724":[17,839]},{"725":[778,791]},{"726":[133,196]},{"727":[239,263]},{"728":[78,452]},{"729":[56,668]},{"730":[636,637]},{"731":[138,212]},{"732":[804,837]},{"733":[446,649]},{"734":[500,573]},{"735":[781,826]},{"736":[323,421]},{"737":[105,120]},{"738":[277,278]},{"739":[592,620]},{"740":[357,399]},{"741":[282,283]},{"742":[151,268]},{"743":[498,600]},{"744":[222,256]},{"745":[477,584]},{"746":[478,502]},{"747":[2,3]},{"748":[95,98]},{"749":[821,826]},{"750":[321,436]},{"751":[160,169]},{"752":[375,376]},{"753":[331,344]},{"754":[357,436]},{"755":[388,407]},{"756":[116,118]},{"757":[91,281]},{"758":[329,437]},{"759":[638,639]},{"760":[333,384]},{"761":[204,261]},{"762":[625,629]},{"763":[190,191]},{"764":[215,273]},{"765":[6,13]},{"766":[53,372]},{"767":[587,598]},{"768":[62,90]},{"769":[79,80]},{"770":[288,624]},{"771":[290,645]},{"772":[549,604]},{"773":[27,32]},{"774":[219,220]},{"775":[27,29]},{"776":[3,4]},{"777":[162,163]},{"778":[241,641]},{"779":[580,582]},{"780":[330,383]},{"781":[13,40]},{"782":[330,331]},{"783":[596,617]},{"784":[497,605]},{"785":[332,410]},{"786":[337,419]},{"787":[555,565]},{"788":[495,574]},{"789":[782,803]},{"790":[86,393]},{"791":[819,833]},{"792":[61,89]},{"793":[69,70]},{"794":[302,433]},{"795":[332,336]},{"796":[152,206]},{"797":[89,130]},{"798":[275,276]},{"799":[590,595]},{"800":[60,68]},{"801":[172,173]},{"802":[782,793]},{"803":[395,417]},{"804":[8,15]},{"805":[643,659]},{"806":[350,435]},{"807":[660,661]},{"808":[80,659]},{"809":[306,379]},{"810":[227,230]},{"811":[522,589]},{"812":[258,265]},{"813":[507,508]},{"814":[134,253]},{"815":[158,271]},{"816":[609,610]},{"817":[346,381]},{"818":[304,328]},{"819":[58,82]},{"820":[135,279]},{"821":[161,229]},{"822":[303,439]},{"823":[548,555]},{"824":[92,442]},{"825":[775,777]},{"826":[257,258]},{"827":[590,594]},{"828":[403,417]},{"829":[366,419]},{"830":[142,168]},{"831":[291,345]},{"832":[481,550]},{"833":[57,458]},{"834":[488,536]},{"835":[186,279]},{"836":[378,381]},{"837":[7,8]},{"838":[490,509]},{"839":[789,821]},{"840":[802,817]}],"nodes":[{"1":{"val":"T1","x":0,"y":-84}},{"2":{"val":"T2","x":85,"y":-1}},{"3":{"val":"T3","x":1,"y":82}},{"4":{"val":"T4","x":-81,"y":0}},{"5":{"val":"T5","x":-211,"y":131}},{"6":{"val":"V","x":-211,"y":0}},{"7":{"val":"G","x":-349,"y":196}},{"8":{"val":"T8","x":-211,"y":268}},{"9":{"val":"V","x":-423,"y":-84}},{"10":{"val":"Mt","x":-342,"y":-185}},{"11":{"val":"T7","x":-211,"y":-266}},{"12":{"val":"Cd","x":-71,"y":-182}},{"13":{"val":"V","x":-339,"y":0}},{"14":{"val":"T6","x":-211,"y":-134}},{"15":{"val":"H","x":-74,"y":197}},{"16":{"val":"A04","x":15666,"y":-283}},{"17":{"val":"A38","x":15740,"y":-633}},{"18":{"val":"A39","x":15741,"y":-758}},{"19":{"val":"S52","x":15593,"y":-62}},{"20":{"val":"A07","x":15815,"y":-282}},{"21":{"val":"A02","x":15741,"y":-377}},{"22":{"val":"A39","x":15740,"y":-501}},{"23":{"val":"S66","x":15888,"y":-61}},{"24":{"val":"Gp","x":-1489,"y":51}},{"25":{"val":"S51","x":15593,"y":-189}},{"26":{"val":"V","x":-389,"y":-329}},{"27":{"val":"A39","x":15741,"y":255}},{"28":{"val":"A08","x":15666,"y":32}},{"29":{"val":"A38","x":15741,"y":384}},{"30":{"val":"V","x":-27,"y":-328}},{"31":{"val":"S67","x":15888,"y":-189}},{"32":{"val":"A05","x":15741,"y":129}},{"33":{"val":"V","x":-400,"y":342}},{"34":{"val":"A39","x":15741,"y":0}},{"35":{"val":"A00","x":15741,"y":-125}},{"36":{"val":"A39","x":15741,"y":-254}},{"37":{"val":"V","x":-26,"y":342}},{"38":{"val":"A06","x":15816,"y":34}},{"39":{"val":"V","x":-507,"y":-1}},{"40":{"val":"V","x":-423,"y":82}},{"41":{"val":"Ir","x":-793,"y":-35}},{"42":{"val":"V","x":108,"y":-1772}},{"43":{"val":"Gc","x":-39,"y":-1138}},{"44":{"val":"Cc","x":-234,"y":-1113}},{"45":{"val":"Gp","x":-427,"y":-1093}},{"46":{"val":"Bd","x":-503,"y":-438}},{"47":{"val":"qMr","x":-614,"y":-543}},{"48":{"val":"Cc","x":87,"y":-438}},{"49":{"val":"qCd","x":205,"y":-544}},{"50":{"val":"Hd","x":-503,"y":427}},{"51":{"val":"qG","x":-614,"y":520}},{"52":{"val":"Mu","x":86,"y":429}},{"53":{"val":"qH","x":206,"y":520}},{"54":{"val":"Gc","x":-193,"y":-2104}},{"55":{"val":"Gp","x":-39,"y":-2079}},{"56":{"val":"Mr","x":-174,"y":-1631}},{"57":{"val":"Bd","x":146,"y":-1468}},{"58":{"val":"Rh","x":1883,"y":-863}},{"59":{"val":"Bc","x":107,"y":-1614}},{"60":{"val":"I7","x":1106,"y":-119}},{"61":{"val":"Cc","x":254,"y":-2027}},{"62":{"val":"I3","x":382,"y":-2127}},{"63":{"val":"Ea","x":-1505,"y":224}},{"64":{"val":"Bg","x":1074,"y":-1851}},{"65":{"val":"Cl","x":1228,"y":-1868}},{"66":{"val":"Tg","x":1796,"y":-1561}},{"67":{"val":"Gc","x":1385,"y":-1875}},{"68":{"val":"H","x":1236,"y":-65}},{"69":{"val":"Gb","x":1605,"y":-1791}},{"70":{"val":"G","x":1698,"y":-1661}},{"71":{"val":"Bc","x":1622,"y":-1023}},{"72":{"val":"Mu","x":1890,"y":-583}},{"73":{"val":"Mu","x":1213,"y":-233}},{"74":{"val":"Mu","x":449,"y":-575}},{"75":{"val":"H","x":552,"y":-466}},{"76":{"val":"V","x":816,"y":-444}},{"77":{"val":"Gp","x":-785,"y":-172}},{"78":{"val":"V","x":1544,"y":-457}},{"79":{"val":"Pa","x":466,"y":-778}},{"80":{"val":"V","x":605,"y":-887}},{"81":{"val":"Pt","x":660,"y":-1069}},{"82":{"val":"Hd","x":1914,"y":-724}},{"83":{"val":"H","x":1920,"y":-215}},{"84":{"val":"Bd","x":1788,"y":-265}},{"85":{"val":"Hd","x":-262,"y":1152}},{"86":{"val":"G","x":-219,"y":1016}},{"87":{"val":"I4","x":1674,"y":-507}},{"88":{"val":"Md","x":1752,"y":-615}},{"89":{"val":"Mt","x":110,"y":-2045}},{"90":{"val":"G","x":493,"y":-2227}},{"91":{"val":"I4","x":811,"y":-2032}},{"92":{"val":"V","x":617,"y":-2144}},{"93":{"val":"Cl","x":764,"y":-2155}},{"94":{"val":"Md","x":1879,"y":-1304}},{"95":{"val":"I8","x":1805,"y":-1183}},{"96":{"val":"V","x":1744,"y":-942}},{"97":{"val":"Kh","x":1668,"y":-1241}},{"98":{"val":"Md","x":1837,"y":-1046}},{"99":{"val":"Md","x":693,"y":-767}},{"100":{"val":"Pa","x":1308,"y":-443}},{"101":{"val":"Cc","x":717,"y":-579}},{"102":{"val":"Hd","x":829,"y":-763}},{"103":{"val":"Kh","x":988,"y":-196}},{"104":{"val":"Bc","x":1961,"y":-342}},{"105":{"val":"I3","x":603,"y":-1215}},{"106":{"val":"G","x":946,"y":-695}},{"107":{"val":"Ra","x":947,"y":-841}},{"108":{"val":"Cd","x":776,"y":-1170}},{"109":{"val":"Ir","x":1348,"y":-310}},{"110":{"val":"Md","x":429,"y":-2002}},{"111":{"val":"Ph","x":970,"y":-958}},{"112":{"val":"Cd","x":376,"y":-1870}},{"113":{"val":"Tc","x":1066,"y":-1987}},{"114":{"val":"Bc","x":667,"y":-364}},{"115":{"val":"Mr","x":270,"y":-819}},{"116":{"val":"Eh","x":122,"y":-1312}},{"117":{"val":"Ea","x":207,"y":-987}},{"118":{"val":"I1","x":143,"y":-1147}},{"119":{"val":"G","x":555,"y":-1413}},{"120":{"val":"Cc","x":691,"y":-1329}},{"121":{"val":"Ir","x":951,"y":-2081}},{"122":{"val":"Cd","x":426,"y":-1344}},{"123":{"val":"Ph","x":301,"y":-1241}},{"124":{"val":"Md","x":325,"y":-663}},{"125":{"val":"Md","x":1178,"y":-364}},{"126":{"val":"Mu","x":1563,"y":-112}},{"127":{"val":"Hd","x":392,"y":2166}},{"128":{"val":"I5","x":1699,"y":-163}},{"129":{"val":"Gc","x":-897,"y":60}},{"130":{"val":"I2","x":23,"y":-1909}},{"131":{"val":"qMt","x":-2345,"y":618}},{"132":{"val":"qEn","x":-1880,"y":156}},{"133":{"val":"qGp","x":-2344,"y":976}},{"134":{"val":"qIr","x":-2246,"y":1050}},{"135":{"val":"qGc","x":-2258,"y":959}},{"136":{"val":"Q43","x":-2144,"y":787}},{"137":{"val":"qHd","x":-1679,"y":1158}},{"138":{"val":"qIr","x":-1526,"y":1279}},{"139":{"val":"qBd","x":-224,"y":2344}},{"140":{"val":"qG","x":-1746,"y":1410}},{"141":{"val":"qG","x":-1598,"y":971}},{"142":{"val":"Q44","x":-1495,"y":466}},{"143":{"val":"qGp","x":-707,"y":139}},{"144":{"val":"qH","x":-220,"y":2054}},{"145":{"val":"qMu","x":-353,"y":1554}},{"146":{"val":"qBg","x":-1027,"y":837}},{"147":{"val":"qGb","x":-676,"y":1504}},{"148":{"val":"qHd","x":-728,"y":1213}},{"149":{"val":"Q42","x":-829,"y":1167}},{"150":{"val":"qTc","x":-810,"y":1272}},{"151":{"val":"Q41","x":-2178,"y":1669}},{"152":{"val":"qHd","x":-2178,"y":1960}},{"153":{"val":"qBd","x":-494,"y":2016}},{"154":{"val":"Q45","x":-932,"y":1926}},{"155":{"val":"qTg","x":-723,"y":1827}},{"156":{"val":"qG","x":-1467,"y":2108}},{"157":{"val":"qHd","x":-745,"y":2256}},{"158":{"val":"qGb","x":-1576,"y":1793}},{"159":{"val":"qH","x":-537,"y":823}},{"160":{"val":"qMr","x":-2104,"y":382}},{"161":{"val":"I6","x":-2239,"y":319}},{"162":{"val":"Gc","x":-2373,"y":364}},{"163":{"val":"Gp","x":-2388,"y":494}},{"164":{"val":"G","x":-2055,"y":570}},{"165":{"val":"Mt","x":-1799,"y":411}},{"166":{"val":"Mr","x":-1905,"y":286}},{"167":{"val":"V","x":-1734,"y":224}},{"168":{"val":"Kh","x":-1352,"y":404}},{"169":{"val":"En","x":-1954,"y":467}},{"170":{"val":"Eh","x":-1606,"y":340}},{"171":{"val":"Gp","x":-1588,"y":592}},{"172":{"val":"Gc","x":-1709,"y":699}},{"173":{"val":"I4","x":-1845,"y":782}},{"174":{"val":"Cd","x":-1635,"y":833}},{"175":{"val":"Cl","x":-1286,"y":915}},{"176":{"val":"Rh","x":-1912,"y":1225}},{"177":{"val":"I3","x":-1837,"y":1085}},{"178":{"val":"Ra","x":-1808,"y":925}},{"179":{"val":"V","x":-1734,"y":1821}},{"180":{"val":"Mr","x":-1787,"y":1675}},{"181":{"val":"I5","x":-1439,"y":941}},{"182":{"val":"Ph","x":-1996,"y":1956}},{"183":{"val":"Hd","x":-666,"y":884}},{"184":{"val":"Cd","x":-1383,"y":565}},{"185":{"val":"Hd","x":-89,"y":2073}},{"186":{"val":"G","x":-2219,"y":680}},{"187":{"val":"Bd","x":-1195,"y":368}},{"188":{"val":"Bc","x":-1029,"y":344}},{"189":{"val":"Cc","x":-1242,"y":621}},{"190":{"val":"Gp","x":-737,"y":414}},{"191":{"val":"V","x":-871,"y":334}},{"192":{"val":"I8","x":-846,"y":198}},{"193":{"val":"G","x":-1174,"y":748}},{"194":{"val":"Ir","x":-727,"y":624}},{"195":{"val":"I2","x":-2398,"y":726}},{"196":{"val":"Hd","x":-2391,"y":854}},{"197":{"val":"Hd","x":-2033,"y":147}},{"198":{"val":"Ra","x":-2179,"y":167}},{"199":{"val":"Tg","x":-968,"y":704}},{"200":{"val":"Ir","x":-447,"y":1162}},{"201":{"val":"Tc","x":-874,"y":595}},{"202":{"val":"Tc","x":-1141,"y":935}},{"203":{"val":"Md","x":-2358,"y":1760}},{"204":{"val":"V","x":-411,"y":897}},{"205":{"val":"Eh","x":-390,"y":1033}},{"206":{"val":"Pa","x":-2299,"y":1884}},{"207":{"val":"I1","x":-588,"y":1170}},{"208":{"val":"Bg","x":-667,"y":1064}},{"209":{"val":"G","x":-772,"y":970}},{"210":{"val":"Gb","x":-880,"y":875}},{"211":{"val":"Hd","x":-1387,"y":1074}},{"212":{"val":"G","x":-1396,"y":1214}},{"213":{"val":"I7","x":-1817,"y":1968}},{"214":{"val":"Ea","x":-1459,"y":1405}},{"215":{"val":"V","x":-1074,"y":1906}},{"216":{"val":"Pa","x":-606,"y":2310}},{"217":{"val":"Pt","x":-1637,"y":2026}},{"218":{"val":"Cc","x":-1288,"y":2114}},{"219":{"val":"Cd","x":-1105,"y":2170}},{"220":{"val":"Md","x":-923,"y":2212}},{"221":{"val":"Bd","x":-1108,"y":2039}},{"222":{"val":"V","x":-970,"y":1142}},{"223":{"val":"Tg","x":-987,"y":1269}},{"224":{"val":"Ir","x":-1005,"y":1398}},{"225":{"val":"Gb","x":-850,"y":1397}},{"226":{"val":"Gp","x":-564,"y":1427}},{"227":{"val":"Mu","x":-347,"y":1274}},{"228":{"val":"G","x":-532,"y":1292}},{"229":{"val":"Rh","x":-2308,"y":209}},{"230":{"val":"H","x":-320,"y":1415}},{"231":{"val":"I3","x":-278,"y":1683}},{"232":{"val":"Bd","x":-216,"y":1802}},{"233":{"val":"Ea","x":-405,"y":1714}},{"234":{"val":"Gb","x":-559,"y":1748}},{"235":{"val":"Bg","x":-569,"y":1878}},{"236":{"val":"Bg","x":-973,"y":1535}},{"237":{"val":"Gc","x":-501,"y":1544}},{"238":{"val":"Bc","x":-166,"y":1933}},{"239":{"val":"Ra","x":-958,"y":1677}},{"240":{"val":"Ph","x":-638,"y":2038}},{"241":{"val":"Mu","x":-31,"y":2188}},{"242":{"val":"H","x":-94,"y":2301}},{"243":{"val":"Pt","x":-575,"y":2166}},{"244":{"val":"Cl","x":-335,"y":2268}},{"245":{"val":"I5","x":-472,"y":2260}},{"246":{"val":"Tg","x":-1961,"y":930}},{"247":{"val":"Tc","x":-2116,"y":943}},{"248":{"val":"Gc","x":-2368,"y":1371}},{"249":{"val":"Hd","x":-1847,"y":1536}},{"250":{"val":"Gp","x":-2362,"y":1511}},{"251":{"val":"Ra","x":-1257,"y":1171}},{"252":{"val":"Mt","x":-1959,"y":1422}},{"253":{"val":"G","x":-2153,"y":1183}},{"254":{"val":"I1","x":-2313,"y":1253}},{"255":{"val":"Cd","x":-2361,"y":1115}},{"256":{"val":"Rh","x":-1110,"y":1152}},{"257":{"val":"V","x":-2059,"y":1307}},{"258":{"val":"Cd","x":-2173,"y":1390}},{"259":{"val":"I8","x":-2327,"y":1639}},{"260":{"val":"Ea","x":-510,"y":637}},{"261":{"val":"Kh","x":-408,"y":749}},{"262":{"val":"Ir","x":-745,"y":1685}},{"263":{"val":"Rh","x":-870,"y":1783}},{"264":{"val":"Cl","x":-1932,"y":644}},{"265":{"val":"Cc","x":-2155,"y":1533}},{"266":{"val":"V","x":-1996,"y":772}},{"267":{"val":"Eh","x":-344,"y":1829}},{"268":{"val":"Hd","x":-2036,"y":1719}},{"269":{"val":"Cl","x":-1890,"y":1776}},{"270":{"val":"V","x":-615,"y":1631}},{"271":{"val":"G","x":-1427,"y":1843}},{"272":{"val":"Gc","x":-1332,"y":1970}},{"273":{"val":"G","x":-1077,"y":1766}},{"274":{"val":"I4","x":-438,"y":1910}},{"275":{"val":"Eh","x":-1628,"y":1497}},{"276":{"val":"Kh","x":-1474,"y":1552}},{"277":{"val":"I6","x":-1410,"y":1697}},{"278":{"val":"Hd","x":-1245,"y":1736}},{"279":{"val":"Gb","x":-2276,"y":814}},{"280":{"val":"I2","x":-1032,"y":1020}},{"281":{"val":"Md","x":751,"y":-1903}},{"282":{"val":"Cl","x":370,"y":-1569}},{"283":{"val":"Cc","x":237,"y":-1659}},{"284":{"val":"Cl","x":997,"y":-1646}},{"285":{"val":"Cd","x":882,"y":-1742}},{"286":{"val":"Md","x":816,"y":-1421}},{"287":{"val":"V","x":847,"y":-1613}},{"288":{"val":"Pt","x":1100,"y":-1543}},{"289":{"val":"Cc","x":1100,"y":-1421}},{"290":{"val":"I2","x":1228,"y":-1080}},{"291":{"val":"qG","x":-12,"y":1367}},{"292":{"val":"qHd","x":266,"y":1504}},{"293":{"val":"Q81","x":263,"y":803}},{"294":{"val":"qH","x":543,"y":932}},{"295":{"val":"qBg","x":-151,"y":766}},{"296":{"val":"Q84","x":802,"y":1253}},{"297":{"val":"qCd","x":752,"y":154}},{"298":{"val":"qBd","x":454,"y":1140}},{"299":{"val":"qH","x":658,"y":1374}},{"300":{"val":"Q82","x":930,"y":726}},{"301":{"val":"qHd","x":1132,"y":961}},{"302":{"val":"Q86","x":1464,"y":1926}},{"303":{"val":"Q85","x":1258,"y":1304}},{"304":{"val":"qCl","x":1622,"y":314}},{"305":{"val":"qTg","x":526,"y":1785}},{"306":{"val":"qIr","x":651,"y":2068}},{"307":{"val":"qH","x":1088,"y":1534}},{"308":{"val":"qMu","x":1227,"y":1810}},{"309":{"val":"qBc","x":607,"y":996}},{"310":{"val":"qBd","x":1240,"y":2235}},{"311":{"val":"qHd","x":1882,"y":1351}},{"312":{"val":"qH","x":782,"y":851}},{"313":{"val":"qHd","x":772,"y":644}},{"314":{"val":"qH","x":768,"y":510}},{"315":{"val":"qBd","x":1401,"y":908}},{"316":{"val":"Kh","x":1632,"y":178}},{"317":{"val":"Hd","x":1502,"y":1020}},{"318":{"val":"Cd","x":893,"y":1437}},{"319":{"val":"H","x":1373,"y":1802}},{"320":{"val":"Bc","x":1570,"y":1646}},{"321":{"val":"Cl","x":1203,"y":2006}},{"322":{"val":"Rh","x":774,"y":2120}},{"323":{"val":"V","x":978,"y":1332}},{"324":{"val":"Ph","x":624,"y":72}},{"325":{"val":"Mu","x":1771,"y":1833}},{"326":{"val":"Q83","x":1518,"y":607}},{"327":{"val":"I6","x":1750,"y":452}},{"328":{"val":"Cd","x":1774,"y":311}},{"329":{"val":"Kh","x":1709,"y":678}},{"330":{"val":"Cd","x":1667,"y":807}},{"331":{"val":"Md","x":1555,"y":893}},{"332":{"val":"Pa","x":1050,"y":236}},{"333":{"val":"Bd","x":1555,"y":445}},{"334":{"val":"Md","x":595,"y":281}},{"335":{"val":"Cd","x":1325,"y":236}},{"336":{"val":"I7","x":1183,"y":279}},{"337":{"val":"V","x":23,"y":1186}},{"338":{"val":"Q88","x":943,"y":1937}},{"339":{"val":"I8","x":653,"y":416}},{"340":{"val":"Cd","x":331,"y":426}},{"341":{"val":"Cl","x":242,"y":1194}},{"342":{"val":"V","x":385,"y":687}},{"343":{"val":"Mu","x":927,"y":433}},{"344":{"val":"En","x":1474,"y":761}},{"345":{"val":"I2","x":-24,"y":1505}},{"346":{"val":"Gp","x":90,"y":1583}},{"347":{"val":"Bc","x":229,"y":1634}},{"348":{"val":"H","x":673,"y":1717}},{"349":{"val":"Bd","x":778,"y":1606}},{"350":{"val":"Mu","x":989,"y":2233}},{"351":{"val":"Pt","x":1472,"y":184}},{"352":{"val":"V","x":1078,"y":692}},{"353":{"val":"V","x":898,"y":2148}},{"354":{"val":"I1","x":1492,"y":1541}},{"355":{"val":"H","x":852,"y":1839}},{"356":{"val":"Eh","x":1435,"y":1173}},{"357":{"val":"Ea","x":1381,"y":2191}},{"358":{"val":"Mu","x":941,"y":1096}},{"359":{"val":"G","x":1913,"y":1479}},{"360":{"val":"Bd","x":1303,"y":1153}},{"361":{"val":"H","x":1077,"y":1111}},{"362":{"val":"Cl","x":1891,"y":1612}},{"363":{"val":"Kh","x":1791,"y":1702}},{"364":{"val":"V","x":1222,"y":1581}},{"365":{"val":"I5","x":1828,"y":1216}},{"366":{"val":"Gb","x":-129,"y":1269}},{"367":{"val":"Hd","x":496,"y":409}},{"368":{"val":"Cl","x":818,"y":348}},{"369":{"val":"Mu","x":1362,"y":1596}},{"370":{"val":"I6","x":1094,"y":1385}},{"371":{"val":"I8","x":1123,"y":1897}},{"372":{"val":"G","x":115,"y":624}},{"373":{"val":"Mu","x":1695,"y":1261}},{"374":{"val":"Cl","x":662,"y":752}},{"375":{"val":"Mu","x":522,"y":807}},{"376":{"val":"H","x":521,"y":660}},{"377":{"val":"Tc","x":259,"y":1947}},{"378":{"val":"Rh","x":216,"y":1805}},{"379":{"val":"Tg","x":511,"y":2079}},{"380":{"val":"H","x":1065,"y":555}},{"381":{"val":"Bg","x":90,"y":1726}},{"382":{"val":"H","x":1807,"y":1062}},{"383":{"val":"Bd","x":1754,"y":920}},{"384":{"val":"H","x":1415,"y":431}},{"385":{"val":"Mu","x":1312,"y":502}},{"386":{"val":"Bc","x":1214,"y":596}},{"387":{"val":"Kh","x":921,"y":913}},{"388":{"val":"Cl","x":841,"y":1012}},{"389":{"val":"Cl","x":1207,"y":791}},{"390":{"val":"Bd","x":913,"y":575}},{"391":{"val":"I4","x":1329,"y":699}},{"392":{"val":"Hd","x":956,"y":1594}},{"393":{"val":"Tc","x":-76,"y":994}},{"394":{"val":"Hd","x":388,"y":947}},{"395":{"val":"Bd","x":233,"y":932}},{"396":{"val":"H","x":626,"y":1173}},{"397":{"val":"G","x":985,"y":2058}},{"398":{"val":"Mr","x":916,"y":1210}},{"399":{"val":"I7","x":1500,"y":2109}},{"400":{"val":"I4","x":380,"y":1419}},{"401":{"val":"G","x":492,"y":1500}},{"402":{"val":"Cl","x":633,"y":1532}},{"403":{"val":"I1","x":-45,"y":865}},{"404":{"val":"Cl","x":1544,"y":1290}},{"405":{"val":"Kh","x":273,"y":1066}},{"406":{"val":"Mt","x":366,"y":1244}},{"407":{"val":"I3","x":723,"y":1072}},{"408":{"val":"qH","x":1695,"y":1609}},{"409":{"val":"Tg","x":35,"y":744}},{"410":{"val":"Cc","x":903,"y":173}},{"411":{"val":"Gc","x":-141,"y":1409}},{"412":{"val":"Bc","x":518,"y":1266}},{"413":{"val":"Cl","x":1355,"y":1033}},{"414":{"val":"Hd","x":1137,"y":1690}},{"415":{"val":"Bd","x":1214,"y":1441}},{"416":{"val":"I3","x":394,"y":1985}},{"417":{"val":"H","x":85,"y":906}},{"418":{"val":"I5","x":248,"y":672}},{"419":{"val":"Ir","x":-104,"y":1128}},{"420":{"val":"G","x":1055,"y":846}},{"421":{"val":"Hd","x":1067,"y":1234}},{"422":{"val":"Ra","x":129,"y":1275}},{"423":{"val":"Hd","x":1507,"y":1754}},{"424":{"val":"H","x":254,"y":1343}},{"425":{"val":"I2","x":1207,"y":1068}},{"426":{"val":"H","x":1035,"y":1795}},{"427":{"val":"Cd","x":1436,"y":1423}},{"428":{"val":"Q87","x":117,"y":1085}},{"429":{"val":"Mu","x":766,"y":1469}},{"430":{"val":"Bd","x":345,"y":561}},{"431":{"val":"G","x":376,"y":1822}},{"432":{"val":"Kh","x":879,"y":1703}},{"433":{"val":"V","x":1577,"y":2003}},{"434":{"val":"H","x":519,"y":169}},{"435":{"val":"Kh","x":1111,"y":2262}},{"436":{"val":"G","x":1320,"y":2080}},{"437":{"val":"V","x":1651,"y":548}},{"438":{"val":"Bd","x":1685,"y":1930}},{"439":{"val":"V","x":1397,"y":1301}},{"440":{"val":"qHd","x":1199,"y":412}},{"441":{"val":"qH","x":602,"y":-666}},{"442":{"val":"qBd","x":596,"y":-2007}},{"443":{"val":"Q63","x":259,"y":-1801}},{"444":{"val":"Q64","x":728,"y":-1547}},{"445":{"val":"qBd","x":502,"y":-1774}},{"446":{"val":"qMd","x":507,"y":-1546}},{"447":{"val":"qCd","x":845,"y":-1274}},{"448":{"val":"qCd","x":1225,"y":-551}},{"449":{"val":"qCd","x":1577,"y":-1359}},{"450":{"val":"qCl","x":848,"y":-1044}},{"451":{"val":"qCd","x":1080,"y":-1044}},{"452":{"val":"Q61","x":1454,"y":-552}},{"453":{"val":"qCd","x":729,"y":-1769}},{"454":{"val":"qMd","x":1078,"y":-1271}},{"455":{"val":"Q66","x":1224,"y":-774}},{"456":{"val":"qMd","x":1453,"y":-775}},{"457":{"val":"qEn","x":216,"y":-2168}},{"458":{"val":"qMr","x":299,"y":-1451}},{"459":{"val":"qHd","x":420,"y":-406}},{"460":{"val":"qGb","x":920,"y":-1862}},{"461":{"val":"qIr","x":1895,"y":-1446}},{"462":{"val":"Q62","x":778,"y":-914}},{"463":{"val":"Q65","x":1262,"y":-1272}},{"464":{"val":"qMu","x":1378,"y":-94}},{"465":{"val":"qH","x":1861,"y":-444}},{"466":{"val":"qMt","x":347,"y":-1062}},{"467":{"val":"qG","x":1339,"y":-1683}},{"468":{"val":"qBd","x":1018,"y":-587}},{"469":{"val":"qCl","x":1487,"y":-967}},{"470":{"val":"qBd","x":1624,"y":-271}},{"471":{"val":"Q27","x":-2253,"y":-908}},{"472":{"val":"Q26","x":-1910,"y":-565}},{"473":{"val":"Q30","x":-1650,"y":-1470}},{"474":{"val":"qMt","x":-1331,"y":-1142}},{"475":{"val":"Q24","x":-1068,"y":-692}},{"476":{"val":"qBd","x":-2143,"y":-1744}},{"477":{"val":"qCd","x":-553,"y":-2256}},{"478":{"val":"qGc","x":-2244,"y":-586}},{"479":{"val":"qIr","x":-1896,"y":-244}},{"480":{"val":"qMt","x":-2085,"y":-741}},{"481":{"val":"qMr","x":-1322,"y":-820}},{"482":{"val":"qTg","x":-1059,"y":-370}},{"483":{"val":"Q21","x":-2133,"y":-1422}},{"484":{"val":"Q28","x":-544,"y":-1934}},{"485":{"val":"Q23","x":-2233,"y":-359}},{"486":{"val":"qBg","x":-1890,"y":-17}},{"487":{"val":"qGp","x":-2121,"y":-467}},{"488":{"val":"Q25","x":-1311,"y":-593}},{"489":{"val":"qG","x":-1048,"y":-143}},{"490":{"val":"qGp","x":-2123,"y":-1195}},{"491":{"val":"qMd","x":-533,"y":-1707}},{"492":{"val":"qGc","x":-1782,"y":-1543}},{"493":{"val":"qEn","x":-1848,"y":-1285}},{"494":{"val":"Q29","x":-2012,"y":-1132}},{"495":{"val":"qBd","x":-673,"y":-1890}},{"496":{"val":"qCl","x":-630,"y":-1677}},{"497":{"val":"qBd","x":-793,"y":-924}},{"498":{"val":"qEn","x":-1265,"y":-2024}},{"499":{"val":"Q22","x":-813,"y":-1473}},{"500":{"val":"qCd","x":-803,"y":-1151}},{"501":{"val":"Cd","x":-2384,"y":-492}},{"502":{"val":"I6","x":-2365,"y":-614}},{"503":{"val":"Mu","x":-2391,"y":-746}},{"504":{"val":"Kh","x":-2389,"y":-878}},{"505":{"val":"I3","x":-1729,"y":-54}},{"506":{"val":"Mr","x":-1743,"y":-181}},{"507":{"val":"Rh","x":-1623,"y":-321}},{"508":{"val":"Ra","x":-1514,"y":-423}},{"509":{"val":"Hd","x":-2039,"y":-1317}},{"510":{"val":"V","x":-1777,"y":-309}},{"511":{"val":"Bg","x":-1385,"y":-111}},{"512":{"val":"En","x":-1757,"y":-431}},{"513":{"val":"I5","x":-1738,"y":-561}},{"514":{"val":"V","x":-1804,"y":-670}},{"515":{"val":"Gp","x":-2025,"y":-210}},{"516":{"val":"Eh","x":-2035,"y":-326}},{"517":{"val":"V","x":-1951,"y":-776}},{"518":{"val":"Gc","x":-1827,"y":-840}},{"519":{"val":"Pt","x":-2115,"y":-905}},{"520":{"val":"I8","x":-2358,"y":-1008}},{"521":{"val":"Cc","x":-2353,"y":-372}},{"522":{"val":"V","x":-2312,"y":-251}},{"523":{"val":"Pt","x":-2336,"y":-1126}},{"524":{"val":"Ph","x":-2314,"y":-1248}},{"525":{"val":"Pa","x":-2262,"y":-1372}},{"526":{"val":"G","x":-2253,"y":-1505}},{"527":{"val":"Cd","x":-1991,"y":-1781}},{"528":{"val":"Cd","x":-1984,"y":-651}},{"529":{"val":"Cc","x":-2100,"y":-593}},{"530":{"val":"H","x":-1739,"y":-1674}},{"531":{"val":"I1","x":-2030,"y":-1520}},{"532":{"val":"Md","x":-1799,"y":-1409}},{"533":{"val":"V","x":-1944,"y":-1410}},{"534":{"val":"Mr","x":-656,"y":-1517}},{"535":{"val":"Ir","x":-1837,"y":-1793}},{"536":{"val":"I2","x":-1364,"y":-447}},{"537":{"val":"Mt","x":-1585,"y":-569}},{"538":{"val":"G","x":-1279,"y":-317}},{"539":{"val":"V","x":-1213,"y":-174}},{"540":{"val":"Gp","x":-1180,"y":-465}},{"541":{"val":"Tc","x":-926,"y":-216}},{"542":{"val":"Tg","x":-854,"y":-341}},{"543":{"val":"Gp","x":-1454,"y":-638}},{"544":{"val":"Cc","x":-1535,"y":-759}},{"545":{"val":"G","x":-2156,"y":-239}},{"546":{"val":"V","x":-985,"y":-814}},{"547":{"val":"Bd","x":-2191,"y":-811}},{"548":{"val":"Eh","x":-1597,"y":-1049}},{"549":{"val":"Cl","x":-1038,"y":-946}},{"550":{"val":"Ea","x":-1186,"y":-883}},{"551":{"val":"Kh","x":-1437,"y":-1249}},{"552":{"val":"Mu","x":-1703,"y":-776}},{"553":{"val":"Rh","x":-2118,"y":-1024}},{"554":{"val":"Ra","x":-2216,"y":-1104}},{"555":{"val":"Ea","x":-1736,"y":-1086}},{"556":{"val":"Mr","x":-1720,"y":-1220}},{"557":{"val":"En","x":-1627,"y":-903}},{"558":{"val":"Cd","x":-1468,"y":-874}},{"559":{"val":"Eh","x":-1527,"y":-1344}},{"560":{"val":"I2","x":-1575,"y":-1184}},{"561":{"val":"Bd","x":-1375,"y":-1515}},{"562":{"val":"V","x":-1509,"y":-1480}},{"563":{"val":"I7","x":-1980,"y":-907}},{"564":{"val":"Gp","x":-1847,"y":-970}},{"565":{"val":"V","x":-1876,"y":-1108}},{"566":{"val":"Rh","x":-1355,"y":-1370}},{"567":{"val":"Ra","x":-1203,"y":-1413}},{"568":{"val":"Gp","x":-1674,"y":-1345}},{"569":{"val":"Ir","x":-1560,"y":-70}},{"570":{"val":"Mt","x":-901,"y":-1863}},{"571":{"val":"Pa","x":-949,"y":-2061}},{"572":{"val":"En","x":-896,"y":-1720}},{"573":{"val":"I7","x":-654,"y":-1196}},{"574":{"val":"I5","x":-804,"y":-1979}},{"575":{"val":"Gp","x":-714,"y":-2087}},{"576":{"val":"Pa","x":-517,"y":-1444}},{"577":{"val":"Pt","x":-428,"y":-1564}},{"578":{"val":"I6","x":-377,"y":-1708}},{"579":{"val":"Kh","x":-554,"y":-2110}},{"580":{"val":"V","x":-408,"y":-2012}},{"581":{"val":"Cd","x":-356,"y":-1857}},{"582":{"val":"Cc","x":-333,"y":-2128}},{"583":{"val":"Md","x":-408,"y":-2227}},{"584":{"val":"Ph","x":-712,"y":-2225}},{"585":{"val":"Pt","x":-850,"y":-2168}},{"586":{"val":"V","x":-782,"y":-1621}},{"587":{"val":"Tc","x":-2033,"y":-1}},{"588":{"val":"G","x":-1022,"y":-1647}},{"589":{"val":"I4","x":-2247,"y":-141}},{"590":{"val":"V","x":-1120,"y":-1141}},{"591":{"val":"Mu","x":-1218,"y":-1625}},{"592":{"val":"Cc","x":-686,"y":-789}},{"593":{"val":"H","x":-1404,"y":-1951}},{"594":{"val":"En","x":-1219,"y":-1237}},{"595":{"val":"Mt","x":-1191,"y":-1023}},{"596":{"val":"I3","x":-1606,"y":-1728}},{"597":{"val":"Cl","x":-2206,"y":-1632}},{"598":{"val":"Tg","x":-2126,"y":-101}},{"599":{"val":"Bc","x":-2263,"y":-706}},{"600":{"val":"Kh","x":-1106,"y":-2067}},{"601":{"val":"I8","x":-846,"y":-756}},{"602":{"val":"Bc","x":-1403,"y":-1663}},{"603":{"val":"H","x":-710,"y":-1372}},{"604":{"val":"Eh","x":-901,"y":-1012}},{"605":{"val":"Cd","x":-643,"y":-935}},{"606":{"val":"Kh","x":-594,"y":-1068}},{"607":{"val":"Mr","x":-962,"y":-1162}},{"608":{"val":"Ph","x":-576,"y":-1304}},{"609":{"val":"Kh","x":-1231,"y":-710}},{"610":{"val":"Gc","x":-1162,"y":-595}},{"611":{"val":"V","x":-1295,"y":-1753}},{"612":{"val":"I4","x":-1105,"y":-1522}},{"613":{"val":"Hd","x":-955,"y":-1513}},{"614":{"val":"Ea","x":-1998,"y":-442}},{"615":{"val":"Gc","x":-1247,"y":-1887}},{"616":{"val":"Ea","x":-1537,"y":-1615}},{"617":{"val":"Bd","x":-1515,"y":-1841}},{"618":{"val":"I1","x":-935,"y":-442}},{"619":{"val":"G","x":-809,"y":-535}},{"620":{"val":"En","x":-725,"y":-654}},{"621":{"val":"Ra","x":1567,"y":-1601}},{"622":{"val":"Pt","x":1492,"y":-1477}},{"623":{"val":"Md","x":1186,"y":-1681}},{"624":{"val":"Bd","x":1248,"y":-1529}},{"625":{"val":"V","x":1317,"y":-1404}},{"626":{"val":"Cc","x":1248,"y":-900}},{"627":{"val":"Pa","x":1363,"y":-1158}},{"628":{"val":"Hd","x":1528,"y":-1212}},{"629":{"val":"I7","x":1440,"y":-1325}},{"630":{"val":"Cc","x":1633,"y":-699}},{"631":{"val":"I1","x":1583,"y":-838}},{"632":{"val":"Hd","x":1453,"y":-216}},{"633":{"val":"Kh","x":1727,"y":-384}},{"634":{"val":"Bd","x":812,"y":-284}},{"635":{"val":"Pt","x":389,"y":-1697}},{"636":{"val":"I8","x":957,"y":-340}},{"637":{"val":"Cl","x":1017,"y":-456}},{"638":{"val":"Ir","x":1336,"y":-759}},{"639":{"val":"Cd","x":1370,"y":-887}},{"640":{"val":"V","x":1338,"y":-628}},{"641":{"val":"Kh","x":111,"y":2223}},{"642":{"val":"Bc","x":256,"y":2211}},{"643":{"val":"Cc","x":454,"y":-1153}},{"644":{"val":"G","x":956,"y":-1138}},{"645":{"val":"Cl","x":1104,"y":-1165}},{"646":{"val":"V","x":1339,"y":-1007}},{"647":{"val":"I5","x":933,"y":-1507}},{"648":{"val":"Cl","x":1489,"y":-664}},{"649":{"val":"Rh","x":605,"y":-1651}},{"650":{"val":"Pa","x":615,"y":-1793}},{"651":{"val":"Cd","x":968,"y":-1377}},{"652":{"val":"Bd","x":1076,"y":-749}},{"653":{"val":"I6","x":1189,"y":-667}},{"654":{"val":"H","x":1472,"y":-353}},{"655":{"val":"Pt","x":1730,"y":-802}},{"656":{"val":"Md","x":1480,"y":-1087}},{"657":{"val":"Kh","x":525,"y":-1901}},{"658":{"val":"I6","x":1457,"y":-1760}},{"659":{"val":"Cl","x":520,"y":-1012}},{"660":{"val":"Bd","x":468,"y":-165}},{"661":{"val":"H","x":524,"y":-35}},{"662":{"val":"Cd","x":1314,"y":44}},{"663":{"val":"Mu","x":1206,"y":134}},{"664":{"val":"Cd","x":1904,"y":-78}},{"665":{"val":"Md","x":1912,"y":60}},{"666":{"val":"H","x":1858,"y":191}},{"667":{"val":"Cd","x":-286,"y":-1529}},{"668":{"val":"Md","x":-34,"y":-1571}},{"669":{"val":"Gc","x":-2362,"y":-61}},{"670":{"val":"Bd","x":-2235,"y":28}},{"671":{"val":"Ir","x":-36,"y":1704}},{"672":{"val":"Hd","x":-152,"y":1621}},{"673":{"val":"Gp","x":-2361,"y":93}},{"674":{"val":"Cd","x":559,"y":-270}},{"775":{"val":"S06","x":16063,"y":-435}},{"776":{"val":"S13","x":16146,"y":-66}},{"777":{"val":"S14","x":16147,"y":-319}},{"778":{"val":"A23","x":15331,"y":-58}},{"779":{"val":"A29","x":15332,"y":-320}},{"780":{"val":"S75","x":15189,"y":128}},{"781":{"val":"S72","x":15189,"y":-374}},{"782":{"val":"S21","x":16283,"y":127}},{"783":{"val":"S10","x":16283,"y":-376}},{"784":{"val":"A39","x":15741,"y":510}},{"785":{"val":"S16","x":16146,"y":-197}},{"786":{"val":"S65","x":16064,"y":184}},{"787":{"val":"A28","x":15415,"y":184}},{"788":{"val":"S64","x":15415,"y":-435}},{"789":{"val":"S74","x":15188,"y":3}},{"790":{"val":"A20","x":15577,"y":409}},{"791":{"val":"A22","x":15331,"y":67}},{"792":{"val":"S15","x":16147,"y":67}},{"793":{"val":"S79","x":16283,"y":2}},{"794":{"val":"A39","x":15740,"y":-888}},{"795":{"val":"S61","x":15824,"y":520}},{"796":{"val":"S12","x":15904,"y":409}},{"797":{"val":"S04","x":15983,"y":-548}},{"798":{"val":"A39","x":15741,"y":638}},{"799":{"val":"S62","x":15741,"y":892}},{"800":{"val":"S83","x":15557,"y":637}},{"801":{"val":"S24","x":15922,"y":636}},{"802":{"val":"S82","x":15283,"y":257}},{"803":{"val":"S78","x":16195,"y":250}},{"804":{"val":"A15","x":15280,"y":-502}},{"805":{"val":"S09","x":16194,"y":-501}},{"806":{"val":"S70","x":15555,"y":-883}},{"807":{"val":"S01","x":15836,"y":-1006}},{"808":{"val":"S63","x":15648,"y":763}},{"809":{"val":"S69","x":15641,"y":-1004}},{"810":{"val":"S77","x":15467,"y":512}},{"811":{"val":"S23","x":16011,"y":511}},{"812":{"val":"S71","x":15466,"y":-760}},{"813":{"val":"S02","x":15921,"y":-886}},{"814":{"val":"A12","x":15834,"y":252}},{"815":{"val":"S11","x":15985,"y":295}},{"816":{"val":"S59","x":15926,"y":125}},{"817":{"val":"S76","x":15375,"y":385}},{"818":{"val":"S22","x":16102,"y":382}},{"819":{"val":"S03","x":15823,"y":-771}},{"820":{"val":"S07","x":16011,"y":-760}},{"821":{"val":"S81","x":15189,"y":-122}},{"822":{"val":"A24","x":15331,"y":-193}},{"823":{"val":"A39","x":15741,"y":763}},{"824":{"val":"S68","x":15740,"y":-1141}},{"825":{"val":"A21","x":15657,"y":520}},{"826":{"val":"S73","x":15189,"y":-251}},{"827":{"val":"S20","x":16283,"y":-125}},{"828":{"val":"S25","x":15833,"y":762}},{"829":{"val":"A25","x":15496,"y":-548}},{"830":{"val":"A37","x":15460,"y":-127}},{"831":{"val":"S54","x":15460,"y":-255}},{"832":{"val":"S58","x":15460,"y":0}},{"833":{"val":"S05","x":15902,"y":-660}},{"834":{"val":"A36","x":16014,"y":-128}},{"835":{"val":"S56","x":16014,"y":-255}},{"836":{"val":"S60","x":16014,"y":0}},{"837":{"val":"S80","x":15374,"y":-632}},{"838":{"val":"S53","x":15555,"y":-382}},{"839":{"val":"A11","x":15647,"y":-507}},{"840":{"val":"S57","x":15550,"y":124}},{"841":{"val":"A14","x":15832,"y":-507}},{"842":{"val":"S55","x":15925,"y":-378}},{"843":{"val":"S08","x":16105,"y":-626}},{"844":{"val":"A39","x":15740,"y":-1012}},{"845":{"val":"A26","x":15495,"y":295}},{"846":{"val":"A13","x":15642,"y":250}},{"847":{"val":"A30","x":15575,"y":-659}},{"848":{"val":"S17","x":16283,"y":-251}}]};

			helpfulAdventurer.levelGraph = LevelGraph.loadGraph(helpfulAdventurer.levelGraphObject, helpfulAdventurer);
			
			helpfulAdventurer.name = "Helpful Adventurer";
			helpfulAdventurer.flavorName = "Cid";
			helpfulAdventurer.flavorClass = "The Helpful Adventurer";
			helpfulAdventurer.flavor = "A character who uses her energy to empower rapid click attacks.";
			helpfulAdventurer.characterSelectOrder = 1;
			helpfulAdventurer.availableForCreation = true;
			helpfulAdventurer.visibleOnCharacterSelect = true;
			helpfulAdventurer.defaultSaveName = "helpful_adventurer";
			helpfulAdventurer.startingSkills = [];
			helpfulAdventurer.upgradeableStats = Character.DEFAULT_UPGRADEABLE_STATS;
			helpfulAdventurer.assetGroupName = CHARACTER_ASSET_GROUP;
			//helpfulAdventurer.onCharacterDisplayCreated = null;
			
			//types
			/*advancedToWorldX
			click x times
			upgrade x items
			use x skills
			1 shot x monsters
			unlock x stones
			fail x bosses
			pay for x paywalls
			acquire x tier armor
			reach item level x
			unlock all skills
			click x clickables*/
			
			// AO: Need to make a static function called registerStaticClass or something
			Characters.startingDefaultInstances[helpfulAdventurer.name] = helpfulAdventurer;
			var tripleClick:Skill = new Skill();
			tripleClick.modName = MOD_INFO["name"];
			tripleClick.name = "MultiClick";
			tripleClick.description = "";
			tripleClick.cooldown = 0;
			tripleClick.iconId = 197;
			tripleClick.manaCost = 0;
			tripleClick.energyCost = 3;
			tripleClick.consumableOnly = false;
			tripleClick.minimumAscensions = 0;
			tripleClick.effectFunction = multiClickEffect;
			tripleClick.ignoresGCD = false;
			tripleClick.maximumRange = 9000;
			tripleClick.minimumRange = 0;
			tripleClick.tooltipFunction = function():Object{ return this.skillTooltip("Clicks " + Math.ceil((5 + CH2.currentCharacter.getTrait("ExtraMulticlicks")) * (CH2.currentCharacter.getTrait("Flurry") ? CH2.currentCharacter.hasteRating : 1))  + " times.  Dashing consumes 20% of remaining clicks."); };
			
			var bigClicks:Skill = new Skill();
			bigClicks.modName = MOD_INFO["name"];
			bigClicks.name = "Big Clicks";
			bigClicks.description = "";
			bigClicks.cooldown = 8000;
			bigClicks.iconId = 198;
			bigClicks.manaCost = 0;
			bigClicks.energyCost = 4;
			bigClicks.consumableOnly = false;
			bigClicks.minimumAscensions = 0;
			bigClicks.effectFunction = bigClicksEffect;
			bigClicks.ignoresGCD = false;
			bigClicks.maximumRange = 9000;
			bigClicks.minimumRange = 0;
			bigClicks.tooltipFunction = function():Object { 
				var character:Character = CH2.currentCharacter;
				var clicks:int = 6 + character.getTrait("BigClickStacks")
				var damage:Number = 3 * (Math.pow(1.25, character.getTrait("BigClicksDamage"))) * 100;
				if (character.getTrait("DistributedBigClicks"))
				{
					damage = (damage - 100) * 0.5 + 100;
				}
				return this.skillTooltip("Causes your next " + clicks + " clicks to deal " + damage.toFixed(2) + "% damage."); 	
			}
			
			var hugeClick:Skill = new Skill();
			hugeClick.modName = MOD_INFO["name"];
			hugeClick.name = "Huge Click";
			hugeClick.description = "";
			hugeClick.cooldown = 8000;
			hugeClick.iconId = 199;
			hugeClick.manaCost = 0;
			hugeClick.energyCost = 3;
			hugeClick.consumableOnly = false;
			hugeClick.minimumAscensions = 0;
			hugeClick.effectFunction = hugeClickEffect;
			hugeClick.ignoresGCD = false;
			hugeClick.maximumRange = 9000;
			hugeClick.minimumRange = 0;
			hugeClick.tooltipFunction = function():Object { 
				var character:Character = CH2.currentCharacter;
				var damage:Number = 10.00 * (Math.pow(1.25, character.getTrait("HugeClickDamage"))) * 100;
				return this.skillTooltip("Causes your next click to deal " + damage.toFixed(2) + "% damage."); 
			};			

			var manaClick:Skill = new Skill();
			manaClick.modName = MOD_INFO["name"];
			manaClick.name = "Mana Crit";
			manaClick.description = "";
			manaClick.cooldown = 60000;
			manaClick.iconId = 1;
			manaClick.manaCost = 5;
			manaClick.energyCost = 0;
			manaClick.consumableOnly = false;
			manaClick.minimumAscensions = 0;
			manaClick.effectFunction = manaClickEffect;
			manaClick.ignoresGCD = false;
			manaClick.maximumRange = 9000;
			manaClick.minimumRange = 0;
			manaClick.tooltipFunction = function():Object{ return this.skillTooltip("Clicks with a 100% chance to score a critical hit."); };
			
			var clickstorm:Skill = new Skill();
			clickstorm.modName = MOD_INFO["name"];
			clickstorm.name = "Clickstorm";
			clickstorm.description = "";
			clickstorm.cooldown = CLICKSTORM_BASE_COOLDOWN;
			clickstorm.iconId = 200;
			clickstorm.manaCost = 0;
			clickstorm.energyCost = 0;
			clickstorm.consumableOnly = false;
			clickstorm.minimumAscensions = 0;
			clickstorm.effectFunction = clickstormEffect;
			clickstorm.ignoresGCD = false;
			clickstorm.maximumRange = 9000;
			clickstorm.minimumRange = 0;
			clickstorm.usesMaxEnergy = false;
			clickstorm.tooltipFunction = function():Object { return this.skillTooltip(CLICKSTORM_TOOLTIP); };
			
			var critstorm:Skill = new Skill();
			critstorm.modName = MOD_INFO["name"];
			critstorm.name = "Critstorm";
			critstorm.description = "";
			critstorm.cooldown = CLICKSTORM_BASE_COOLDOWN;
			critstorm.iconId = 201;
			critstorm.manaCost = 0;
			critstorm.energyCost = 0;
			critstorm.consumableOnly = false;
			critstorm.minimumAscensions = 0;
			critstorm.effectFunction = critstormEffect;
			critstorm.ignoresGCD = false;
			critstorm.maximumRange = 9000;
			critstorm.minimumRange = 0;
			critstorm.usesMaxEnergy = false;
			critstorm.tooltipFunction = function():Object { return this.skillTooltip(CRITSTORM_TOOLTIP); };
			Character.staticSkillInstances[critstorm.uid] = critstorm;
			
			var goldenClicks:Skill = new Skill();
			goldenClicks.modName = MOD_INFO["name"];
			goldenClicks.name = "GoldenClicks";
			goldenClicks.description = "";
			goldenClicks.cooldown = CLICKSTORM_BASE_COOLDOWN;
			goldenClicks.iconId = 201;
			goldenClicks.manaCost = 0;
			goldenClicks.energyCost = 0;
			goldenClicks.consumableOnly = false;
			goldenClicks.minimumAscensions = 0;
			goldenClicks.effectFunction = goldenClicksEffect;
			goldenClicks.ignoresGCD = false;
			goldenClicks.maximumRange = 9000;
			goldenClicks.minimumRange = 0;
			goldenClicks.usesMaxEnergy = false;
			goldenClicks.tooltipFunction = function():Object { return this.skillTooltip(GOLDENCLICKS_TOOLTIP); };
			Character.staticSkillInstances[goldenClicks.uid] = goldenClicks;
			
			var autoAttackstorm:Skill = new Skill();
			autoAttackstorm.modName = MOD_INFO["name"];
			autoAttackstorm.name = "Autoattackstorm";
			autoAttackstorm.description = "";
			autoAttackstorm.cooldown = CLICKSTORM_BASE_COOLDOWN;
			autoAttackstorm.iconId = 201;
			autoAttackstorm.manaCost = 0;
			autoAttackstorm.energyCost = 0;
			autoAttackstorm.consumableOnly = false;
			autoAttackstorm.minimumAscensions = 0;
			autoAttackstorm.effectFunction = autoAttackstormEffect;
			autoAttackstorm.ignoresGCD = false;
			autoAttackstorm.maximumRange = 9000;
			autoAttackstorm.minimumRange = 0;
			autoAttackstorm.usesMaxEnergy = false;
			autoAttackstorm.tooltipFunction = function():Object{ return this.skillTooltip(AUTOATTACKSTORM_TOOLTIP); };
			Character.staticSkillInstances[autoAttackstorm.uid] = autoAttackstorm;
			
			var energize:Skill = new Skill();
			energize.modName = MOD_INFO["name"];
			energize.name = "Energize";
			energize.description = "";
			energize.cooldown = 60000;
			energize.iconId = 35;
			energize.manaCost = ENERGIZE_BASE_MANA_COST;
			energize.energyCost = 0;
			energize.consumableOnly = false;
			energize.minimumAscensions = 0;
			energize.effectFunction = energizeEffect;
			energize.ignoresGCD = false;
			energize.maximumRange = 9000;
			energize.minimumRange = 0;
			energize.usesMaxEnergy = false;
			energize.tooltipFunction = function():Object { 
				var character:Character = CH2.currentCharacter;
				var duration:Number = 60 / character.hasteRating;
				duration += (60 * (0.2 * character.getTrait("ImprovedEnergize"))) / character.hasteRating;
				return this.skillTooltip("Restores " + (2 * character.hasteRating).toFixed(2) + " energy per second for " + (duration).toFixed(2) + " seconds."); };
			
			var managize:Skill = new Skill();
			managize.modName = MOD_INFO["name"];
			managize.name = "Managize";
			managize.description = "";
			managize.cooldown = 60000;
			managize.iconId = 35;
			managize.manaCost = 0;
			managize.energyCost = 120;
			managize.consumableOnly = false;
			managize.minimumAscensions = 0;
			managize.effectFunction = managizeEffect;
			managize.ignoresGCD = false;
			managize.maximumRange = 9000;
			managize.minimumRange = 0;
			managize.usesMaxEnergy = false;
			managize.tooltipFunction = function():Object{ return this.skillTooltip("Restores " + (25 + (25 * 0.2 * CH2.currentCharacter.getTrait("ImprovedEnergize"))).toFixed(0) + "% of your maximum mana."); };
			
			var energizeExtend:Skill = new Skill();
			energizeExtend.modName = MOD_INFO["name"];
			energizeExtend.name = "Energize: Extend";
			energizeExtend.description = "";
			energizeExtend.cooldown = 0;
			energizeExtend.iconId = 35;
			energizeExtend.manaCost = ENERGIZE_BASE_MANA_COST;
			energizeExtend.energyCost = 0;
			energizeExtend.consumableOnly = false;
			energizeExtend.minimumAscensions = 0;
			energizeExtend.effectFunction = energizeExtendEffect;
			energizeExtend.ignoresGCD = false;
			energizeExtend.maximumRange = 9000;
			energizeExtend.minimumRange = 0;
			energizeExtend.usesMaxEnergy = false;
			energizeExtend.tooltipFunction = function():Object{ return this.skillTooltip("Restores 2 energy per second for 120 seconds. Multiple use will extend the duration. (needs implementation)."); };
			
			var energizeRush:Skill = new Skill();
			energizeRush.modName = MOD_INFO["name"];
			energizeRush.name = "Energize: Rush";
			energizeRush.description = "";
			energizeRush.cooldown = 30000;
			energizeRush.iconId = 35;
			energizeRush.manaCost = ENERGIZE_BASE_MANA_COST;
			energizeRush.energyCost = 0;
			energizeRush.consumableOnly = false;
			energizeRush.minimumAscensions = 0;
			energizeRush.effectFunction = energizeRushEffect;
			energizeRush.ignoresGCD = false;
			energizeRush.maximumRange = 9000;
			energizeRush.minimumRange = 0;
			energizeRush.usesMaxEnergy = false;
			energizeRush.tooltipFunction = function():Object{ return this.skillTooltip("Restores 50 energy per second for 5 seconds, then 1 energy per second for 25 seconds (needs implementation)."); }
			
			var reload:Skill = new Skill();
			reload.modName = MOD_INFO["name"];
			reload.name = "Reload";
			reload.description = "";
			reload.cooldown = 30000 * 60;
			reload.iconId = 168;
			reload.manaCost = 0;
			reload.energyCost = 0;
			reload.consumableOnly = false;
			reload.minimumAscensions = 0;
			reload.effectFunction = reloadEffect;
			reload.ignoresGCD = false;
			reload.maximumRange = 9000;
			reload.minimumRange = 0;
			reload.usesMaxEnergy = false;
			reload.tooltipFunction = function():Object { 
				var character:Character = CH2.currentCharacter;
				var reloadAmount:Number = (40 + (20 * character.getTrait("ImprovedReload")));
				if (character.getTrait("SmallReloads"))
				{
					reloadAmount *= 0.2;
				}
				return this.skillTooltip("Restores energy and mana and reduces the remaining cooldowns of all skills by %d%.".replace("%d",reloadAmount)); 
			};
				
			var powerSurge:Skill = new Skill();
			powerSurge.modName = MOD_INFO["name"];
			powerSurge.name = "Powersurge";
			powerSurge.description = "";
			powerSurge.cooldown = 15000 * 60;
			powerSurge.iconId = 150;
			powerSurge.manaCost = 50;
			powerSurge.energyCost = 0;
			powerSurge.consumableOnly = false;
			powerSurge.minimumAscensions = 0;
			powerSurge.effectFunction = powerSurgeEffect;
			powerSurge.ignoresGCD = false;
			powerSurge.maximumRange = 9000;
			powerSurge.minimumRange = 0;
			powerSurge.usesMaxEnergy = false;
			powerSurge.tooltipFunction = function():Object{ 
				var character:Character = CH2.currentCharacter;
				var duration:Number = (60 * Math.pow(1.2, character.getTrait("SustainedPowersurge"))) / character.hasteRating;
				var damage:Number = 2 * (Math.pow(1.25, character.getTrait("ImprovedPowersurge"))) * 100;
				return this.skillTooltip("Causes your clicks within " + duration.toFixed(0) + " seconds to deal " + damage.toFixed(2) + "% damage."); 
			};
			
			Character.staticSkillInstances[tripleClick.uid] = tripleClick;
			Character.staticSkillInstances[bigClicks.uid] = bigClicks;
			Character.staticSkillInstances[hugeClick.uid] = hugeClick;
			Character.staticSkillInstances[manaClick.uid] = manaClick;
			Character.staticSkillInstances[clickstorm.uid] = clickstorm;
			Character.staticSkillInstances[energize.uid] = energize;
			Character.staticSkillInstances[energizeExtend.uid] = energizeExtend;
			Character.staticSkillInstances[energizeRush.uid] = energizeRush;
			Character.staticSkillInstances[reload.uid] = reload;
			Character.staticSkillInstances[powerSurge.uid] = powerSurge;
			Character.staticSkillInstances[managize.uid] = managize;
			
			var clicktorrent:Skill = new Skill();
			clicktorrent.modName = MOD_INFO["name"];
			clicktorrent.name = "Clicktorrent";
			clicktorrent.description = "";
			clicktorrent.cooldown = CLICKSTORM_BASE_COOLDOWN;
			clicktorrent.iconId = 202;
			clicktorrent.manaCost = 0;
			clicktorrent.energyCost = 0;
			clicktorrent.consumableOnly = false;
			clicktorrent.minimumAscensions = 0;
			clicktorrent.effectFunction = clicktorrentEffect;
			clicktorrent.ignoresGCD = false;
			clicktorrent.maximumRange = 9000;
			clicktorrent.minimumRange = 0;
			clicktorrent.usesMaxEnergy = false;
			clicktorrent.tooltipFunction = function():Object{ return this.skillTooltip(CLICKTORRENT_TOOLTIP); };
			Character.staticSkillInstances[clicktorrent.uid] = clicktorrent;
			
			var bigClicksAdditionalTutorialCondition:Function = function():Boolean {
				return !CH2.currentCharacter.buffs.hasBuffByName("Big Clicks");
			};
			
			var hugeClicksAdditionalTutorialCondition:Function = function():Boolean {
				return !CH2.currentCharacter.buffs.hasBuffByName("Huge Click");
			};
			
			var energizeAdditionalTutorialCondition:Function = function():Boolean {
				return !CH2.currentCharacter.buffs.hasBuffByName("Energize") && (CH2.user.totalMsecsPlayed - CH2.currentCharacter.timeOfLastOutOfEnergy) < 15000;
			};
			
			addSkillTutorial("MultiClick", 15, 2);
			addSkillTutorial("Big Clicks", 15, 3, bigClicksAdditionalTutorialCondition);
			addSkillTutorial("Huge Click", 15, 1, hugeClicksAdditionalTutorialCondition);
			addSkillTutorial("Energize", 5, 6, energizeAdditionalTutorialCondition);
			addItemUpgradeTutorial();
			addCatalogTutorial();
			addItemTabTutorial();
			addSkillTreeTabTutorial();
			addAutomatorTabTutorial();
			addMainPanelTutorial();
			addRubyShopTutorial();
		}
		
		public function createFixedFirstRunCatalogs(data:Array):void
		{
			firstRunHardcodedCatalogs = [];
			
			var worldCostCurve:Array = Formulas.STANDARD;
			var worldCostMultiplier:BigNumber = new BigNumber(1);
			for (var catalogIndex:int = 0; catalogIndex < data.length; catalogIndex++)
			{
				var hardcodedCatalog:Array = [];
				for (var itemIndex:int = 0; itemIndex < data[catalogIndex].length; itemIndex++)
				{
					var fixedAttributes:Array = [];
					var itemStats:Array = data[catalogIndex][itemIndex];
					for (var itemStatIndex:int = 0; itemStatIndex < itemStats.length; itemStatIndex++)
					{
						var itemStat:ItemStat = new ItemStat();
						itemStat.id = itemStats[itemStatIndex]["id"];
						itemStat.level = itemStats[itemStatIndex]["level"];
						fixedAttributes.push(itemStat);
					}
					var item:Item = new Item();
					item.level = 1;
					item.init(catalogIndex % Item.ITEM_EQUIP_AMOUNT, worldCostCurve, worldCostMultiplier, catalogIndex + 1, fixedAttributes);
					hardcodedCatalog.push(item);
				}
				firstRunHardcodedCatalogs.push(hardcodedCatalog);
			}
		}
		
		public function addHelpfulAdventurerStaticTutorial(key:String, tutorial:Tutorial):void
		{
			if (Character.staticTutorialInstances[helpfulAdventurer.name] == null)
			{
				Character.staticTutorialInstances[helpfulAdventurer.name] = { };
			}
			Character.staticTutorialInstances[helpfulAdventurer.name][key] = tutorial;
		}
		
		public function doesPlayerRequireAutomatorTabTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return !character.hasSeenAutomatorPanel;
		}
		
		public function doesPlayerRequireSkillTreeTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return character.highestWorldCompleted < 1 && character.level < 8 && character.level > 1;
		}
		
		public function doesPlayerRequireItemTabTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return character.highestWorldCompleted < 1 && character.totalCatalogItemsPurchased < 11;
		}
		
		public function doesPlayerRequireItemUpgradeTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return character.highestWorldCompleted < 1 && character.totalCatalogItemsPurchased < 11;
		}
		
		public function doesPlayerRequireCatalogTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return character.highestWorldCompleted < 1 && character.totalCatalogItemsPurchased < 11;
		}
		
		public function shouldStartAutomatorTabTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return character.highestWorldCompleted < 1 && character.hasUnlockedAutomator && !character.hasSeenAutomatorPanel;
		}
		
		public function shouldStartItemTabTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return character.highestWorldCompleted < 1 && (shouldStartItemUpgradeTutorial() || shouldStartCatalogTutorial());
		}
		
		public function shouldStartSkillTreeTabTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return character.level < 8 &&
				character.highestWorldCompleted < 1 && 
				character.level > 1 &&
				character.hasNewSkillTreePointsAvailable &&
				CH2.user.totalMsecsPlayed - character.timeOfLastLevelUp > Character.TIME_UNTIL_PLAYER_NEEDS_HINT_MS;
		}
		
		public function shouldStartItemUpgradeTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return character.totalCatalogItemsPurchased < 11 &&
				character.highestWorldCompleted < 1 && 
				CH2.user.totalMsecsPlayed - character.timeOfLastItemUpgrade > Character.TIME_UNTIL_PLAYER_NEEDS_HINT_MS &&
				CH2.user.totalMsecsPlayed - character.timeOfLastCatalogPurchase > Character.TIME_UNTIL_PLAYER_NEEDS_HINT_MS &&
				character.canAffordAPurchaseOnAllItems();
		}
		
		public function shouldStartCatalogTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return !character.didFinishWorld &&
				character.highestWorldCompleted < 1 && 
				character.totalCatalogItemsPurchased < 11 &&
				CH2.user.totalMsecsPlayed - character.timeOfLastCatalogPurchase > Character.TIME_UNTIL_PLAYER_NEEDS_HINT_MS &&
				CH2.user.totalMsecsPlayed - character.timeOfLastItemUpgrade > Character.TIME_UNTIL_PLAYER_NEEDS_HINT_MS &&
				character.gold.gte(character.getCurrentCatalogPrice());
		}
		
		public function addRubyShopTutorial():void
		{
			var tutorial:Tutorial = new Tutorial();
			
			tutorial.priority = 9;
			
			tutorial.doesPlayerRequireFunction = function():Boolean {
				var character:Character = CH2.currentCharacter;
				return character.highestWorldCompleted < 1 && !character.hasSeenRubyShopPanel;
			};
			
			tutorial.shouldStartFunction = function():Boolean {
				var character:Character = CH2.currentCharacter;
				return !character.hasSeenRubyShopPanel &&
					character.highestWorldCompleted < 1 && 
					character.timeSinceLastRubyShopAppearance > Character.TIME_UNTIL_PLAYER_NEEDS_RUBY_SHOP_HINT_MS && 
					character.timeSinceLastRubyShopAppearance < Character.RUBY_SHOP_APPEARANCE_DURATION;
			};
			
			tutorial.onStartFunction = function():void {
				TutorialManager.instance.addRightPanelTutorialArrow(tutorial);
			};
			
			tutorial.shouldEndFunction = function():Boolean {
				var character:Character = CH2.currentCharacter;
				return character.hasSeenRubyShopPanel ||
					character.timeSinceLastRubyShopAppearance >= Character.RUBY_SHOP_APPEARANCE_DURATION;
			};
			
			tutorial.onEndFunction = function():void {
				TutorialManager.instance.removeTutorialArrow(tutorial);
			};
			
			addHelpfulAdventurerStaticTutorial("Ruby_Shop_Tutorial", tutorial);
		}
		
		public function addMainPanelTutorial():void
		{
			var tutorial:Tutorial = new Tutorial();
			
			tutorial.priority = 8;
			
			tutorial.doesPlayerRequireFunction = function():Boolean {
				var character:Character = CH2.currentCharacter;
				return character.highestWorldCompleted < 1 && 
					(doesPlayerRequireAutomatorTabTutorial() ||
					doesPlayerRequireSkillTreeTutorial() ||
					doesPlayerRequireItemTabTutorial());
			};
			
			tutorial.shouldStartFunction = function():Boolean {
				return !CH2UI.instance.mainUI.mainPanel.isToggledOut && 
					(shouldStartAutomatorTabTutorial() ||
						shouldStartItemTabTutorial() ||
						shouldStartSkillTreeTabTutorial());
			};
			
			tutorial.onStartFunction = function():void {
				TutorialManager.instance.addMainPanelTutorialArrow(tutorial);
			};
			
			tutorial.shouldEndFunction = function():Boolean {
				return CH2UI.instance.mainUI.mainPanel.isToggledOut;
			};
			
			tutorial.onEndFunction = function():void {
				TutorialManager.instance.removeTutorialArrow(tutorial);
			};
			
			addHelpfulAdventurerStaticTutorial("Main_Panel_Tab_Tutorial", tutorial);
		}
		
		public function addAutomatorTabTutorial():void
		{
			var tutorial:Tutorial = new Tutorial();
			
			tutorial.priority = 7;
			
			tutorial.doesPlayerRequireFunction = doesPlayerRequireAutomatorTabTutorial;
			
			tutorial.shouldStartFunction = function():Boolean {
				var character:Character = CH2.currentCharacter;
				return !character.hasSeenAutomatorPanel && CH2UI.instance.mainUI.mainPanel.isToggledOut && shouldStartAutomatorTabTutorial();
			};
			
			tutorial.onStartFunction = function():void {
				TutorialManager.instance.addTabTutorialArrow(3, tutorial);
			};
			
			tutorial.shouldEndFunction = function():Boolean {
				var character:Character = CH2.currentCharacter;
				return !CH2UI.instance.mainUI.mainPanel.isToggledOut ||
					character.hasSeenAutomatorPanel;
			};
			
			tutorial.onEndFunction = function():void {
				TutorialManager.instance.removeTutorialArrow(tutorial);
			};
			
			addHelpfulAdventurerStaticTutorial("Automator_Tab_Tutorial", tutorial);
		}
		
		public function addItemTabTutorial():void
		{
			var tutorial:Tutorial = new Tutorial();
			tutorial.priority = 7;
			
			tutorial.doesPlayerRequireFunction = doesPlayerRequireItemTabTutorial;
			
			tutorial.shouldStartFunction = function():Boolean {
				return CH2UI.instance.mainUI.mainPanel.isToggledOut && !CH2UI.instance.mainUI.mainPanel.isOnItemsPanel && shouldStartItemTabTutorial();
			};
			
			tutorial.onStartFunction = function():void {
				TutorialManager.instance.addTabTutorialArrow(0, tutorial);
			};
			
			tutorial.shouldEndFunction = function():Boolean {
				var character:Character = CH2.currentCharacter;
				return !CH2UI.instance.mainUI.mainPanel.isToggledOut || 
					CH2UI.instance.mainUI.mainPanel.isOnItemsPanel ||
					(!shouldStartItemUpgradeTutorial() && !shouldStartCatalogTutorial());
				
			};
			
			tutorial.onEndFunction = function():void {
				TutorialManager.instance.removeTutorialArrow(tutorial);
			};
			
			addHelpfulAdventurerStaticTutorial("Item_Tab_Tutorial", tutorial);
		}
		
		public function addSkillTreeTabTutorial():void
		{
			var tutorial:Tutorial = new Tutorial();
			
			tutorial.priority = 7;
			
			tutorial.doesPlayerRequireFunction = doesPlayerRequireSkillTreeTutorial;
			
			tutorial.shouldStartFunction = function():Boolean {
				return CH2UI.instance.mainUI.mainPanel.isToggledOut && !CH2UI.instance.mainUI.mainPanel.isOnGraphPanel && shouldStartSkillTreeTabTutorial();
			};
			
			tutorial.onStartFunction = function():void {
				TutorialManager.instance.addTabTutorialArrow(1, tutorial);
			};
			
			tutorial.shouldEndFunction = function():Boolean {
				var character:Character = CH2.currentCharacter;
				return !CH2UI.instance.mainUI.mainPanel.isToggledOut ||
					CH2UI.instance.mainUI.mainPanel.isOnGraphPanel ||
					character.level >= 8 ||
					!character.hasNewSkillTreePointsAvailable;
			};
			
			tutorial.onEndFunction = function():void {
				TutorialManager.instance.removeTutorialArrow(tutorial);
			};
			
			addHelpfulAdventurerStaticTutorial("Skill_Tree_Tab_Tutorial", tutorial);
		}
		
		public function addItemUpgradeTutorial():void
		{
			var tutorial:Tutorial = new Tutorial();
			
			tutorial.priority = 4;
			
			var previousCatalogItemsPurchased:Number = 0;
			
			tutorial.doesPlayerRequireFunction = doesPlayerRequireItemUpgradeTutorial;
			
			tutorial.shouldStartFunction = function():Boolean {
				return CH2UI.instance.mainUI.mainPanel.isToggledOut && CH2UI.instance.mainUI.mainPanel.isOnItemsPanel && shouldStartItemUpgradeTutorial();
			};
			
			tutorial.onStartFunction = function():void {
				var character:Character = CH2.currentCharacter;
				previousCatalogItemsPurchased = character.totalCatalogItemsPurchased;
				
				var item:Item;
				var inventory:Array = character.inventory.items;
				for each (item in inventory)
				{
					TutorialManager.instance.addEquipmentSlotTutorialArrow(item.type, tutorial);
				}
			};
			
			tutorial.shouldEndFunction = function():Boolean {
				var character:Character = CH2.currentCharacter;
				return !CH2UI.instance.mainUI.mainPanel.isToggledOut ||
					!CH2UI.instance.mainUI.mainPanel.isOnItemsPanel ||
					!character.canAffordAPurchaseOnAllItems();
			};
			
			tutorial.onEndFunction = function():void {
				TutorialManager.instance.removeTutorialArrow(tutorial);
			};
			
			addHelpfulAdventurerStaticTutorial("Upgrade_Tutorial", tutorial);
		}
		
		public function addCatalogTutorial():int
		{
			var tutorial:Tutorial = new Tutorial();
			
			tutorial.priority = 5;
			
			var previousCatalogItemsPurchased:Number = 0;
			tutorial.doesPlayerRequireFunction = doesPlayerRequireCatalogTutorial;
			
			tutorial.shouldStartFunction = function():Boolean {
				return CH2UI.instance.mainUI.mainPanel.isToggledOut && CH2UI.instance.mainUI.mainPanel.isOnItemsPanel && shouldStartCatalogTutorial();
			};
			
			tutorial.onStartFunction = function():void {
				var character:Character = CH2.currentCharacter;
				previousCatalogItemsPurchased = character.totalCatalogItemsPurchased;
				for (var i:int = 0; i < character.catalogItemsForSale.length; i++)
				{
					TutorialManager.instance.addCatalogTutorialArrow(i, tutorial);
				}
			};
			
			tutorial.shouldEndFunction = function():Boolean {
				var character:Character = CH2.currentCharacter;
				return !CH2UI.instance.mainUI.mainPanel.isToggledOut ||
					!CH2UI.instance.mainUI.mainPanel.isOnItemsPanel ||
					character.totalCatalogItemsPurchased > previousCatalogItemsPurchased;
			};
			
			tutorial.onEndFunction = function():void {
				TutorialManager.instance.removeTutorialArrow(tutorial);
			};
			
			addHelpfulAdventurerStaticTutorial("Catalog_Tutorial", tutorial);
		}
		
		public function addSkillTutorial(uid:String, castsRequired:Number, priority:int=0, additionalConditionFunction:Function=null):void
		{
			var tutorial:Tutorial = new Tutorial();
			tutorial.priority = priority;
			
			var previousTimesCast:Number = 0;
			tutorial.doesPlayerRequireFunction = function():Boolean {
				var staticSkill:Skill = CH2.currentCharacter.getStaticSkill(uid);
				if (staticSkill)
				{
					var skill:Skill = CH2.currentCharacter.getSkill(uid);
					return CH2.currentCharacter.gilds < 1 && (!skill || skill.timesCast < castsRequired);
				}
				return false;
			};
			
			tutorial.shouldStartFunction = function():Boolean {
				var skill:Skill = CH2.currentCharacter.getSkill(uid);
				return skill &&
					skill.slot != -1 &&
					skill.timesCast < castsRequired && 
					skill.canUseSkill &&
					CH2.user.totalMsecsPlayed - skill.timeOfLastUse > Character.TIME_UNTIL_PLAYER_NEEDS_HINT_MS &&
					(!additionalConditionFunction || additionalConditionFunction());
			};
			
			tutorial.onStartFunction = function():void {
				var skill:Skill = CH2.currentCharacter.getSkill(uid);
				previousTimesCast = skill.timesCast;
				TutorialManager.instance.addSkillBarTutorialArrow(skill.slot, tutorial);
			};
			
			tutorial.shouldEndFunction = function():Boolean {
				var skill:Skill = CH2.currentCharacter.getSkill(uid);
				return skill && previousTimesCast < skill.timesCast;
			};
			
			tutorial.onEndFunction = function():void {
				TutorialManager.instance.removeTutorialArrow(tutorial);
			};
			
			addHelpfulAdventurerStaticTutorial(uid + "_Tutorial", tutorial);
		}
		
		public static function addSkill(name:String):Function
		{
			return function():void {
				var skill:Skill = CH2.currentCharacter.getStaticSkill(name);
				CH2.currentCharacter.activateSkill(skill.uid);
			}
		}
		
		public static function addSkillTooltip(name:String):Function
		{
			return function():Object {
				var skill:Skill = CH2.currentCharacter.getSkill(name);
				return skill.tooltipFunction();
			}
		}
		
		private function unlockAutomator():void
		{
			CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_16", 10000);
			CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_11", 4000);
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_23", "Perform a click", 1, "Performs a single click.", onClickActivate, function():Boolean{ return true; }, 0);
		}
		
		private function purchaseAutomator():void
		{
			CH2.currentCharacter.onAutomatorUnlocked();
			CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_16");
			CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_11");
			CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_23");
		}
		
		private function onClickActivate():Boolean
		{
			CH2.currentCharacter.clickAttack();
			return true;
		}
		
		private function addDummyAlwaysGem():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_1", "Dummy (Always)", 4, "Dummy gem that always activates.", onDummyAlwaysGemActivate, function():Boolean{ return true; } );
		}
		
		private function addDummyNeverGem():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_2", "Dummy (Never)", 3, "Dummy gem that never activates.", onDummyNeverGemActivate, function():Boolean{ return false; });
		}
		
		private function addDashGem():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_3", "Dash", 158, "Dashes to the nearest monster.", onDashGemActivate, canActivateDashGem);
		}
		
		private function addBuyRandomCatalogItemGem():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_4", "Buy Random Catalog Item", 97, "Buys a random catalog item if you can afford it.", onBuyRandomCatalogItemGemActivate, canBuyRandomCatalogItem, 500);
		}
		
		private function addUpgradeCheapestItemGem():void 
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_5", "Upgrade Cheapest Item", 96, "Buys the cheapest item upgrade you can afford.", onUpgradeCheapestItemGemActivate, canUpgradeCheapestItem, 500);
		}
		
		private function addUpgradeThirdNewestItemGem():void 
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_60", "Upgrade The Third Newest Item", 96, "Buys an upgrade on the third newest item you purchased.", onUpgradeThirdNewestItemGemActivate, canUpgradeThirdNewestItem, 500);
		}
		
		private function addUpgradeSecondNewestItemGem():void 
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_61", "Upgrade The Second Newest Item", 96, "Buys an upgrade on the second newest item you purchased.", onUpgradeSecondNewestItemGemActivate, canUpgradeSecondNewestItem, 500);
		}
		
		private function addUpgradeAllCheapestItemsGem():void 
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_62", "Spend all gold upgrading cheapest items", 96, "Spends all gold on the cheapest available item upgrades.", onUpgradeAllCheapestItemsGemActivate, canUpgradeCheapestItem, 500);
		}
		
		private function addUpgradeCheapestItemToNextMultiplierGem():void 
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_63", "Upgrade Cheapest Item to Next x10", 96, "Spends gold required to upgrade the cheapest item to its next multiplier.", onUpgradeCheapestItemToNextMultiplierGemActivate, canUpgradeCheapestItemToNextMultiplier, 500);
		}
		
		private function addBuyMetalDetectorsGem():void 
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_64", "Purchase Metal Detector", 5, "Purchases a metal detector from the ruby bonus shop", onBuyMetalDetectorsGemActivate, canBuyMetalDetectors, 500);
		}
		
		private function addBuyRunesGem():void 
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_65", "Purchase Rune", 5, "Purchases a rune from the ruby bonus shop", onBuyRunesGemActivate, canBuyRunes, 500);
		}
		
		private function addLT1WorldCompletionsStone():void 
		{
			CH2.currentCharacter.automator.addStone("LT1WorldCompletions", "World Completions < 1", "World Completions < 1", "A stone that always activates on the first run of a world.", onLT1WorldCompletionsActivate);
		}
		
		private function addGT1WorldCompletionsStone():void
		{
			CH2.currentCharacter.automator.addStone("GT1WorldCompletions", "World Completions >= 1", "World Completions >= 1", "A stone that always activates on repeated runs of a world.", onGT1WorldCompletionsActivate);
		}
		
		private function addUpgradeNewestItemGem():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_53", "Upgrade Newest Item", 96, "Upgrades your newest item.", onUpgradeNewestItemGemActivate, canUpgradeNewestItem, 500);
		}
		
		private function addUpgradeAllItemsGem():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_54", "Upgrade All Items", 96, "Upgrades all of your items.", onUpgradeAllItemsGemActivate, canUpgradeAllItems, 500);
		}
		
		public function addSwapToFirstSet():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_80", "Swap to First Automator Set", 96, "Swaps to first automator set.", onSwapToFirstSet, canSwapToFirstSet, 500);
		}
		
		public function addSwapToSecondSet():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_81", "Swap to Second Automator Set", 96, "Swaps to second automator set.", onSwapToSecondSet, canSwapToSecondSet, 500);
		}
		
		public function addSwapToThirdSet():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_82", "Swap to Third Automator Set", 96, "Swaps to third automator set.", onSwapToThirdSet, canSwapToThirdSet, 500);
		}
		
		private function addSwapToFourthSet():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_83", "Swap to Fourth Automator Set", 96, "Swaps to fourth automator set.", onSwapToFourthSet, canSwapToFourthSet, 500);
		}
		
		private function addSwapToFifthSet():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_84", "Swap to Fifth Automator Set", 96, "Swaps to fifth automator set.", onSwapToFifthSet, canSwapToFifthSet, 500);
		}
		
		private function addUpgradeFirstAffordableItemGem():void 
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_6", "Upgrade First Affordable Item", 94, "Buys the first item upgrade you can afford.", onUpgradeFirstAffordableItemGemActivate, canUpgradeFirstAffordableItem, 500);
		}
		
		private function addAttemptBossGem():void 
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_10", "Attempt Boss", 162, "If you can attempt the boss, automatically progress to the boss zone.", onAttemptBossGemActivate, canAttemptBoss, 500);
		}
		
		private function addAlwaysStone():void 
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_1", "Always", "Always", "A stone that will always activate.", function():Boolean
			{
				return true;
			});
		}
		
		private function add50PercentChanceStone():void 
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_2", "50% Chance", "50%", "A stone that activates 50% of the time.", function():Boolean
			{
				return CH2.roller.modRoller.boolean(0.5);
			});
		}
		
		private function add25PercentChanceStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_3", "25% Chance", "25%", "A stone that activates 25% of the time.", function():Boolean
			{
				return CH2.roller.modRoller.boolean(0.25);
			});
		}
		
		private function add10PercentChanceStone():void 
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_4", "10% Chance", "10%", "A stone that activates 10% of the time.", function():Boolean
			{
				return CH2.roller.modRoller.boolean(0.1);
			});
		}
		
		private function addMHGreaterThan50PercentStone():void 
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_5", "Monster Health Greater Than 50%", "MH>50%", "A stone that activates when the next monster's health is greater than 50%.", function():Boolean
			{
				var monster:Monster = CH2.world.getNextMonster();
				if (monster)
				{
					var healthPercent:BigNumber = monster.health.divideToPercent(monster.maxHealth);
					if (healthPercent.gtN(0.5))
					{
						return true;
					}
				}
				return false;
			});
		}
		
		private function addMHLessThan50PercentStone():void 
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_6", "Monster Health Less Than 50%", "MH<50%", "A stone that activates when the next monster's health is less than 50%.", function():Boolean
			{
				var monster:Monster = CH2.world.getNextMonster();
				if (monster)
				{
					var healthPercent:BigNumber = monster.health.divideToPercent(monster.maxHealth);
					if (healthPercent.ltN(0.5))
					{
						return true;
					}
				}
				return false;
			});
		}
		
		private function addGreaterThan90PercentEnergyStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_7", "Energy Greater Than 90%", "En>90%", "A stone that activates when energy is greater than 90%.", function():Boolean
			{
				var percentEnergy:Number = CH2.currentCharacter.energy / CH2.currentCharacter.maxEnergy;
				if (percentEnergy > 0.9)
				{
					return true;
				}
				return false;
			});
		}
		
		private function addLessThan10PercentEnergyStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_8", "Energy Less Than 10%", "En<10%", "A stone that activates when energy is less than 10%.", function():Boolean
			{
				var percentEnergy:Number = CH2.currentCharacter.energy / CH2.currentCharacter.maxEnergy;
				if (percentEnergy < 0.1)
				{
					return true;
				}
				return false;
			});
		}
		
		private function addGreaterThan90PercentManaStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_9", "Mana Greater Than 90%", "Mana>90%", "A stone that activates when mana is greater than 90%.", function():Boolean
			{
				var percentMana:Number = CH2.currentCharacter.mana / CH2.currentCharacter.maxMana;
				if (percentMana > 0.9)
				{
					return true;
				}
				return false;
			});
		}
		
		private function addLessThan10PercentManaStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_10", "Mana Less Than 10%", "Mana<10%", "A stone that activates when mana is less than 10%.", function():Boolean
			{
				var percentMana:Number = CH2.currentCharacter.mana / CH2.currentCharacter.maxMana;
				if (percentMana < 0.1)
				{
					return true;
				}
				return false;
			});
		}
		
		private function addOnPreviousStoneActivatedStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_17", "Previous Stone", "Previous Stone", "A stone that activates if the previous stone activated.", function():Boolean
			{
				return true; //Needs implementation
			})
		}
		
		private function addBossEncounterStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_18", "Boss Encounter", "Boss Zone", "A stone that activates on boss zones.", function():Boolean
			{
				return CH2.user.isOnBossZone;
			})
		}
		
		private function addZoneStartStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_19", "Zone Start", "Zone Start", "A stone that activates during the first half of a zone.", function():Boolean
			{
				var zoneProgressPercent = Math.min(1, CH2.currentCharacter.monstersKilledOnCurrentZone / CH2.currentCharacter.monstersPerZone);
				return (zoneProgressPercent < 0.5);
			})
		}
			
		private function addZoneMiddleStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_20", "Zone Middle", "Zone Middle", "A stone that activates during the second half of a zone.", function():Boolean
			{
				var zoneProgressPercent = Math.min(1, CH2.currentCharacter.monstersKilledOnCurrentZone / CH2.currentCharacter.monstersPerZone);
				return (zoneProgressPercent >= 0.5);
			})
		}
		
		private function addCritThresholdStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_21", "Critical Chance >= 100%", "Crit Chance", "A stone that activates when crit is greater than or equal to 100%.", function():Boolean
			{
				return CH2.currentCharacter.criticalChance >= 1;
			})
		}
		
		private function addEnergyGreaterThanManaStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_22", "Energy Greater Than Mana", "Energy > Mana", "A stone that activates when current energy is greater than current mana.", function():Boolean
			{
				return CH2.currentCharacter.energy > CH2.currentCharacter.mana;
			})
		}
		
		private function addManaGreaterThanEnergyStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_23", "Mana Greater Than Energy", "Mana > Energy", "A stone that activates when current mana is greater than current energy.", function():Boolean
			{
				return CH2.currentCharacter.mana > CH2.currentCharacter.energy;
			})
		}
		
		private function addEnergyLessThan40PercentStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_24", "Energy Less Than 40%", "Energy < 40%", "A stone that can activate when your energy is below 40%.", function():Boolean
			{
				return (CH2.currentCharacter.energy / CH2.currentCharacter.maxEnergy) < .4;
			})
		}
		
		private function addEnergyGreaterThan60PercentStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_25", "Energy Greater Than 60%", "Energy > 60%", "A stone that can activate when your energy is above 60%.", function():Boolean
			{
				return (CH2.currentCharacter.energy / CH2.currentCharacter.maxEnergy) > .6;
			})
		}
		
		private function addManaLessThan40PercentStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_26", "Mana Less Than 40%", "Mana < 40%", "A stone that can activate when your mana is below 40%.", function():Boolean
			{
				return (CH2.currentCharacter.mana / CH2.currentCharacter.maxMana) < .4;
			})
		}
		
		private function addManaGreaterThan60PercentStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_27", "Mana Greater Than 60%", "Mana > 60%", "A stone that can activate when your mana is above 60%.", function():Boolean
			{
				return (CH2.currentCharacter.mana / CH2.currentCharacter.maxMana) > .6;
			})
		}
		
		private function addBeforeFirstZoneKillStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_28", "Before First Zone Kill", "Before First Zone Kill", "A stone that activates before a kill has been made on a zone.", function():Boolean
			{
				return (CH2.currentCharacter.monstersKilledOnCurrentZone == 0);
			})
		}
		
		private function addBuffComparisonStone(stoneId:String, stoneName:String, stoneDescription:String, buffName:String, comparison:int, comparisonValue:int):void
		{
			var stoneFunction:Function;
			switch (comparison) 
			{
				case CH2.COMPARISON_EQ:
					stoneFunction = function():Boolean { var buffValue:int = 0;  if (CH2.currentCharacter.buffs.hasBuffByName(buffName)) { buffValue = CH2.currentCharacter.buffs.getBuff(buffName).stacks } return (buffValue == comparisonValue); };
					break;
				case CH2.COMPARISON_NEQ:
					stoneFunction = function():Boolean { var buffValue:int = 0;  if (CH2.currentCharacter.buffs.hasBuffByName(buffName)) { buffValue = CH2.currentCharacter.buffs.getBuff(buffName).stacks } return (buffValue != comparisonValue); };
					break;
				case CH2.COMPARISON_LT:
					stoneFunction = function():Boolean { var buffValue:int = 0;  if (CH2.currentCharacter.buffs.hasBuffByName(buffName)) { buffValue = CH2.currentCharacter.buffs.getBuff(buffName).stacks } return (buffValue < comparisonValue); };
					break;
				case CH2.COMPARISON_LTE:
					stoneFunction = function():Boolean { var buffValue:int = 0;  if (CH2.currentCharacter.buffs.hasBuffByName(buffName)) { buffValue = CH2.currentCharacter.buffs.getBuff(buffName).stacks } return (buffValue <= comparisonValue); };
					break;
				case CH2.COMPARISON_GT:
					stoneFunction = function():Boolean { var buffValue:int = 0;  if (CH2.currentCharacter.buffs.hasBuffByName(buffName)) { buffValue = CH2.currentCharacter.buffs.getBuff(buffName).stacks } return (buffValue > comparisonValue); };
					break;
				case CH2.COMPARISON_GTE:
					stoneFunction = function():Boolean { var buffValue:int = 0;  if (CH2.currentCharacter.buffs.hasBuffByName(buffName)) { buffValue = CH2.currentCharacter.buffs.getBuff(buffName).stacks } return (buffValue >= comparisonValue); };
					break;
				default:
					stoneFunction = function():Boolean { return false; };
			}			
			CH2.currentCharacter.automator.addStone(stoneId, stoneName, stoneName, stoneDescription, stoneFunction);
		}
		
		public function addBigClicksGTMultiClicksStone():void
		{
			CH2.currentCharacter.automator.addStone("BigClicksGTMultiClicks", "Big Clicks > Multiclicks", "Big Clicks > Multiclicks", "A stone that activates if you have more Big Clicks than Multiclick can consume.", bigClicksGTMulticlicks);
		}
		
		public function addBigClicksLTEMultiClicksStone():void
		{
			CH2.currentCharacter.automator.addStone("BigClicksLTEMultiClicks", "Big Clicks <= Multiclicks", "Big Clicks <= Multiclicks", "A stone that activates if your Multiclick would consume all of your Big Clicks.", bigClicksLTEMulticlicks);
		}
		
		private function addNextSetGem():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_21", "Next Set", 158, "Switches the automator to the next set", onNextSetGemActivate, canActivateNextSetGem);
		}
		
		public function canActivateNextSetGem():Boolean
		{
			return true;
		}
		
		public function onNextSetGemActivate():Boolean
		{
			var currentQueueIndex:int = CH2.currentCharacter.automator.currentQueueIndex;
			
			CH2.currentCharacter.automator.setCurrentQueue(currentQueueIndex + 1);	
			
			if (CH2UI.instance.mainUI && CH2UI.instance.mainUI.mainPanel && CH2UI.instance.mainUI.mainPanel.isOnAutomatorPanel)
			{
				CH2UI.instance.mainUI.mainPanel.refreshOpenTab();
			}
			return true;
		}
		
		private function addPreviousSetGem():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_22", "Previous Set", 158, "Switches the automator to the previous set", onPreviousSetGemActivate, canActivatePreviousSetGem);
		}
		
		public function canActivatePreviousSetGem():Boolean
		{
			return true;
		}
		
		public function onPreviousSetGemActivate():Boolean
		{
			var currentQueueIndex:int = CH2.currentCharacter.automator.currentQueueIndex;
			
			CH2.currentCharacter.automator.setCurrentQueue(currentQueueIndex - 1);
			
			if (CH2UI.instance.mainUI && CH2UI.instance.mainUI.mainPanel && CH2UI.instance.mainUI.mainPanel.isOnAutomatorPanel)
			{
				CH2UI.instance.mainUI.mainPanel.refreshOpenTab();
			}
			return true;
		}
		
		// ******************** GRAPH STUFF THAT NEEDS NAMES/NODES ******************************
		public function applyManaCritFromCritsTalent():void
		{
			var buff:Buff = new Buff();
			buff.iconId = 21;
			buff.isUntimedBuff = true;
			buff.name = "Mana Crit From Crits";
			buff.critFunction = function(attackData:AttackData)
			{
				var manaCrit:Skill = CH2.currentCharacter.getSkill("Mana Crit");
				manaCrit.cooldownRemaining -= 1000;
			}
			CH2.currentCharacter.buffs.addBuff(buff);
		}
		
		public function applyCritChanceFromNonCritsTalent():void
		{
			// there is no onHit buff function
			/*
			var buff:Buff = new Buff();
			buff.iconId = 21;
			buff.isUntimedBuff = true;
			buff.name = "Crit Chance From Non-Crits";
			
			buff.onHit = function(attackData:AttackData)
			{
				if (!attackData.isCritical) 
				{
					buff.buffStat(CH2.STAT_CRIT_CHANCE, buff.getStatValue(CH2.STAT_CRIT_CHANCE) + 0.01)
				} 
				else 
				{
					buff.buffStat(CH2.STAT_CRIT_CHANCE, 0);
				}
			}
			CH2.currentCharacter.buffs.addBuff(buff);*/
		}
		
		public function applyUninterruptedAutoAttacksTalent():void
		{
			CH2.currentCharacter.autoAttacksNotInterrupted = true;
		}
		
		public function applyLimitlessBigClicks():void
		{
			var bigClicks:Skill = CH2.currentCharacter.getSkill("Big Clicks");
			bigClicks.cooldown = 0;
			CH2.currentCharacter.setTrait("UnlimitedBigClicks", 1);
		}
		
		// ********************* END OF NEW BATCH OF GRAPH STUFF *****************************************
		
		// Character function Overrides
		
		//public function helpfulAdventurerCanUseSkill(skill:Skill):Boolean
		public function canUseSkillOverride(skill:Skill):Boolean
		{
			var character:Character = CH2.currentCharacter;
			if (character.buffs.hasBuffByName("Curse Of The Juggernaut"))
			{
				return (character.canUseSkillDefault(skill) && (character.energy >= (getCalculatedEnergyCostOverride(skill))));
			}
			else
			{
				return CH2.currentCharacter.canUseSkillDefault(skill);
			}
		}
		
		//public function helpfulAdventurerOnKilledMonster(monster:Monster):void
		public function onKilledMonsterOverride(monster:Monster):void
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.getTrait("KillingFrenzy"))
			{
				
				//if (character.buffs.hasBuffByName("Killing Frenzy")) {
					//var killingFrenzy:Buff = character.buffs.getBuff("Killing Frenzy");
					//killingFrenzy.timeSinceActivated = 0;
					//killingFrenzy.buffStat(CH2.STAT_HASTE, 1.5);
				//}
				//else
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
/*					buff.tickRate = 1000;
					buff.tickFunction = function() {
						buff.buffStat(CH2.STAT_HASTE, buff.getStatValue(CH2.STAT_HASTE) - 0.1);
					}
*/				
					character.buffs.addBuff(buff);
				}
			}
			
			character.onKilledMonsterDefault(monster);
		}
		
		//public function helpfulAdventurerAttack(attackData:AttackData):void
		public function attackOverride(attackData:AttackData):void
		{
			if (CH2.currentCharacter.getTrait("LowEnergyDamageBonus") && CH2.currentCharacter.energy < CH2.currentCharacter.maxEnergy * 0.60)
			{
				attackData.damage.timesEqualsN(2);
			}
			
			var monsterHealth:BigNumber = new BigNumber(0);
			
			if (CH2.currentCharacter.getTrait("ManaCritOverflow"))
			{
				var target:Monster = CH2.world.getNextMonster();
				if (target)
				{
					monsterHealth.power = target.health.power;
					monsterHealth.base = target.health.base;
				}
			}
			
			CH2.currentCharacter.attackDefault(attackData);
			
			if (attackData.isAutoAttack && attackData.isCritical && CH2.currentCharacter.getTrait("AutoAttackCritMana") && !(CH2.currentCharacter.buffs.hasBuffByName("AutoAttackCritMana")))
			{
				CH2.currentCharacter.addMana(1);
				var buff:Buff = new Buff();
				buff.name = "AutoAttackCritMana";
				buff.iconId = 23;
				buff.isUntimedBuff = false;
				buff.duration = 1000;
				buff.unhastened = true;
						buff.tooltipFunction = function() {
							return {
								"header": "AutoAttackCritMana",
								"body": "Gained 1 mana."
							};
						}
				CH2.currentCharacter.buffs.addBuff(buff);
			}
			
			if (attackData.isCritical && (CH2.currentCharacter.getTrait("BhaalsRise") || CH2.currentCharacter.getTrait("BhallsRise")))
			{
				var manaCrit:Skill = CH2.currentCharacter.getSkill("Mana Crit");
				if (manaCrit)
				{	
					manaCrit.cooldownRemaining -= 1000;
				}
			}
			
			if (attackData.isKillShot && attackData.isCritical && (CH2.currentCharacter.getTrait("CritKillPowerSurge") || CH2.currentCharacter.getTrait("CritKillPowerSurgeCooldown")))
			{
				var powerSurge:Skill = CH2.currentCharacter.getSkill("Powersurge");
				if (powerSurge)
				{
					powerSurge.cooldownRemaining -= 5000;
				}
			}
			
			if (attackData.isKillShot && (CH2.currentCharacter.buffs.hasBuffByName("Mana Crit")) && CH2.currentCharacter.getTrait("ManaCritOverflow"))
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
		}
		
/*		public function helpfulAdventurerGetCalculatedEnergyCost(skill:Skill):Number
		{
			if (!skill.usesMaxEnergy)
			{
				var cost:Number = skill.energyCost * (1 - CH2.currentCharacter.energyCostReduction);
				if (CH2.currentCharacter.buffs.hasBuffByName("Curse Of The Juggernaut"))
				{
					var juggernautBuff:Buff = CH2.currentCharacter.buffs.getBuff("Curse Of The Juggernaut");
					cost += juggernautBuff.stacks;
				}
				return cost;
			}
			else
			{
				return this.maxEnergy;
			}
		}
*/		
		//public function helpfulAdventurerZoneChanged(zoneNumber:int):void
		public function onZoneChangedOverride(zoneNumber:int):void
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.buffs.hasBuffByName("Alacrity"))
			{
				character.buffs.removeBuff("Alacrity");
			}
			
			character.onZoneChangedDefault(zoneNumber);
		}
		
		//public function helpfulAdventurerAddGold(goldToAdd:BigNumber):void
		public function addGoldOverride(goldToAdd:BigNumber):void
		{
			if (CH2.currentCharacter.getTrait("HighEnergyGoldBonus") && (goldToAdd.gtN(0)) && CH2.currentCharacter.energy > 0.40 * CH2.currentCharacter.maxEnergy)
			{
				CH2.currentCharacter.addGoldDefault(goldToAdd);
			}
			
			CH2.currentCharacter.addGoldDefault(goldToAdd);
		}
		
		//public function helpfulAdventurerAddEnergy(amount:Number, showFloatingText:Boolean = true):void
		public function addEnergyOverride(amount:Number, showFloatingText:Boolean = true):void
		{
			var character:Character = CH2.currentCharacter;
			if (amount < 0)
			{
				if (character.getTrait("Discharge"))
				{
					var target:Monster = CH2.world.getNextMonster();
					if (target && (Math.abs(target.y - CH2.currentCharacter.y) < 200))
					{
						var attackData:AttackData = new AttackData();
						attackData.damage = character.clickDamage.multiplyN(Math.abs(amount));
						attackData.isCritical = false;
						attackData.monster = target;
						target.takeDamage(attackData);
						attackData.isClickAttack = true;
						character.buffs.onAttack([attackData]);
					}
				}
			}
			
			character.addEnergyDefault(amount, showFloatingText);
		}
		
		//public function helpfulAdventurerAddMana(amount:Number, showFloatingText:Boolean = true):void
		public function addManaOverride(amount:Number, showFloatingText:Boolean = true):void
		{
			var character:Character = CH2.currentCharacter;
			if (amount < 0)
			{
				if (character.getTrait("SpendManaHaste"))
				{
					if (character.buffs.hasBuffByName("SpendManaHaste"))
					{
						var existingBuff:Buff = character.buffs.getBuff("SpendManaHaste");
						var remainingValue:Number = (existingBuff.getStatValue(CH2.STAT_HASTE) - 1) * (existingBuff.duration - existingBuff.timeSinceActivated) / 5000;
						existingBuff.buffStat(CH2.STAT_HASTE, 1 + ( -amount / 100) + remainingValue);
						existingBuff.timeSinceActivated = 0;
						
					}
					else
					{
						var buff:Buff = new Buff();
						buff.name = "SpendManaHaste";
						buff.iconId = 23;
						buff.isUntimedBuff = false;
						buff.duration = 5000;
						buff.unhastened = true;
						buff.tooltipFunction = function() {
							return {
								"header": "Gift of Chronos",
								"body": "Increases haste by " + (buff.getStatValue(CH2.STAT_HASTE) * 100).toFixed(2) + "%."
							};
						}
						buff.buffStat(CH2.STAT_HASTE, 1 + (-amount / 100));
						character.buffs.addBuff(buff);
					}
					
				}
			}
			
			character.addManaDefault(amount, showFloatingText);
		}
		
		
		// End of Overrides
		
		public function applyQuickRecoveryTalent():void
		{
			var buff:Buff = new Buff();
			buff.iconId = 21;
			buff.isUntimedBuff = true;
			buff.name = "Quick Recovery";
			buff.buffStat(CH2.STAT_ENERGY_REGEN, 1);
			CH2.currentCharacter.buffs.addBuff(buff);
		}
		
		
		
		public function quickRecoveryTooltip():Object
		{
			return {
				"header": "Quick Recovery",
				"body": "Generate 1 additional energy with each auto attack."
			};
		}	
		
		public function applyQuickerRecoveryTalent():void
		{
			var buff:Buff = new Buff();
			buff.iconId = 21;
			buff.isUntimedBuff = true;
			buff.name = "Quicker Recovery";
			buff.buffStat(CH2.STAT_ENERGY_REGEN, 1);
			CH2.currentCharacter.buffs.addBuff(buff);
		}
		
		public function quickerRecoveryTooltip():Object
		{
			return {
				"header": "Quicker Recovery",
				"body": "Generate 1 additional energy with each auto attack."
			};
		}
		
		public function applyPowerfulStrikesTalent():void
		{
			var buff:Buff = new Buff();
			buff.iconId = 22;
			buff.isUntimedBuff = true;
			buff.name = "Powerful Strikes";
			buff.buffStat(CH2.STAT_CLICK_DAMAGE, 2.00);
			CH2.currentCharacter.buffs.addBuff(buff);
		}
		
		public function powerfulStrikesTooltip():Object
		{
			return {
				"header": "Powerful Strikes",
				"body": "Doubles click damage."
			};
		}
		
		public function applyMetalDetectorTalent():void
		{
			var buff:Buff = new Buff();
			buff.iconId = 21;
			buff.isUntimedBuff = true;
			buff.name = "Metal Detector";
			buff.buffStat(CH2.STAT_GOLD, 2.00);
			CH2.currentCharacter.buffs.addBuff(buff);
		}
		
		public function metalDetectorTooltip():Object
		{
			return {
				"header": "Metal Detector",
				"body": "Doubles gold received from all sources."
			};
		}
		
		public function applyEnergizeExtendTalent():void
		{
			var energize:Skill = CH2.currentCharacter.getSkill("Energize");
			CH2.currentCharacter.replaceSkill(energize.uid, CH2.currentCharacter.getStaticSkill("Energize: Extend"));
		}
		
		public function applyEnergizeRushTalent():void
		{
			var energize:Skill = CH2.currentCharacter.getSkill("Energize");
			CH2.currentCharacter.replaceSkill(energize.uid, CH2.currentCharacter.getStaticSkill("Energize: Rush"));
		}
		
		public function energizeExtendTooltip():Object 
		{
			return {
				"header": "Energize: Extend",
				"body": "Replaces Energize. Restores 2 energy per second over 120 seconds. Multiple use will extend the duration."
			};
		}
		
		public function energizeRushTooltip():Object
		{
			return {
				"header": "Energize: Rush",
				"body": "Replaces Energize. Restores 50 energy per second over 5 seconds, then 2 energy per second over 25 seconds."
			};
		}
		
		public function bigClicksGTMulticlicks():Boolean
		{
			var character:Character = CH2.currentCharacter;
			var bigClicksCount:int = 0;
			if (character.buffs.hasBuffByName("Big Clicks"))
			{
				bigClicksCount = character.buffs.getBuff("Big Clicks").stacks;
			}
			return (bigClicksCount > multiClickCount());
		}
		
		public function bigClicksLTEMulticlicks():Boolean
		{
			var character:Character = CH2.currentCharacter;
			var bigClicksCount:int = 0;
			if (character.buffs.hasBuffByName("Big Clicks"))
			{
				bigClicksCount = character.buffs.getBuff("Big Clicks").stacks;
			}
			return (bigClicksCount <= multiClickCount());
		}
		
		public function multiClickCount():int
		{
			var character:Character = CH2.currentCharacter;
			var buffClicks:int = 4 + character.getTrait("ExtraMulticlicks");
			if (character.getTrait("Flurry"))
			{
				buffClicks = (buffClicks + 1) * character.hasteRating - 1;
			}
			return buffClicks + 1;
		}
		
		public function multiClickEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			var buffClicks:int = multiClickCount() - 1;
			buff.name = "MultiClick";
			buff.iconId = 202;
			buff.tickRate = 50;
			buff.duration = buff.tickRate * buffClicks;
			buff.tickFunction = function() {
				if (!CH2.currentCharacter.isNextMonsterInRange)
				{
					buff.timeSinceActivated += 0.2 * buff.timeLeft;
				}
				character.clickAttack(false);
			}
			character.buffs.addBuff(buff);
			character.clickAttack(false);
		}
			
		public function clicktorrentEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var tickSpeed:int = 1;
			var buff:Buff = new Buff();
			buff.name = "Clicktorrent";
			buff.iconId = 202;
			buff.duration = 60000;
			buff.tickRate = 1000 / 30;
			buff.tickFunction = function() {
				character.clickAttack(false);
				character.addEnergy(-(1/3), false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
				if (buff.timeLeft < buff.tickRate) {
					buff.timeSinceActivated = 0;
					tickSpeed++;
					buff.tickRate = (1000/30) / tickSpeed;
				}
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Clicktorrent",
					"body": "Clicking " + (30 * character.hasteRating).toFixed(2) + " times per second. Consuming " + (10 * character.hasteRating).toFixed(2) + " energy per second. Speed increases over time."
				};
			}
			character.buffs.addBuff(buff);
		}
		
		public function clickstormEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var tickSpeed:int = 1;
			var buff:Buff = new Buff();
			buff.name = "Clickstorm";
			buff.iconId = 200;
			buff.duration = 60000;
			buff.tickRate = 400;
			buff.tickFunction = function() {
				character.clickAttack(false);
				character.addEnergy(-0.5, false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
				if (buff.timeLeft <= buff.tickRate) {
					buff.timeSinceActivated = 0;
					tickSpeed++;
					buff.tickRate = 400 / tickSpeed;
				}
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Clickstorm",
					"body": "Clicking " + (2.5 * tickSpeed * character.hasteRating).toFixed(2) + " times per second. Consuming " + (1.25 * tickSpeed * character.hasteRating).toFixed(2) + " energy per second. Speed increases over time."
				};
			}
			character.buffs.addBuff(buff);
		}
		
		public function critstormEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var tickSpeed:int = 1;
			var buff:Buff = new Buff();
			buff.name = "Critstorm";
			buff.iconId = 200;
			buff.duration = 60000;
			buff.tickRate = 400;
			buff.tickFunction = function() {
				buff.buffStat(CH2.STAT_CRIT_CHANCE, 1);
				character.clickAttack(false);
				buff.buffStat(CH2.STAT_CRIT_CHANCE, 0);
				character.addEnergy(-0.5, false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
				if (buff.timeLeft <= buff.tickRate) {
					buff.timeSinceActivated = 0;
					tickSpeed++;
					buff.tickRate = 400 / tickSpeed;
				}
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Critstorm",
					"body": "Critting " + (2.5 * tickSpeed * character.hasteRating).toFixed(2) + " times per second. Consuming " + (1.25 * tickSpeed * character.hasteRating).toFixed(2) + " energy per second. Speed increases over time."
				};
			}
			character.buffs.addBuff(buff);
		}
		
		public function goldenClicksEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var tickSpeed:int = 1;
			var buff:Buff = new Buff();
			buff.name = "GoldenClicks";
			buff.iconId = 201;
			buff.duration = 60000;
			buff.tickRate = 400;
			buff.tickFunction = function() {
				character.clickAttack(false);
				character.addEnergy(-0.5, false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
				if (buff.timeLeft <= buff.tickRate) {
					buff.timeSinceActivated = 0;
					tickSpeed++;
					buff.tickRate = 400 / tickSpeed;
				}
			}
			buff.buffStat(CH2.STAT_GOLD, 2.0);
			buff.tooltipFunction = function() {
				return {
					"header": "Golden Clicks",
					"body": "Clicking " + (2.5 * tickSpeed * character.hasteRating).toFixed(2) + " times per second. Gold gained increased by 100%. Consuming " + (1.25 * tickSpeed * character.hasteRating).toFixed(2) + " energy per second. Speed increases over time."
				};
			}
			character.buffs.addBuff(buff);
		}
		
		public function autoAttackstormEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var tickSpeed:int = 1;
			var buff:Buff = new Buff();
			buff.name = "Autoattackstorm";
			buff.iconId = 201;
			buff.duration = 60000;
			buff.tickRate = 400;
			buff.tickFunction = function() {
				if (character.isNextMonsterInRange)
				{
					var attackTimer:Number = character.timeSinceLastAutoAttack;
					character.autoAttack();
					character.timeSinceLastClickAttack = character.timeSinceLastAutoAttack;
					character.timeSinceLastAutoAttack = attackTimer;
					character.addMana(-0.5);
					if (character.mana <= 0) {
						buff.isFinished = true;
						buff.onFinish();
					}
				}
				if (buff.timeLeft <= buff.tickRate) {
					buff.timeSinceActivated = 0;
					tickSpeed++;
					buff.tickRate = 400 / tickSpeed;
				}
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Autoattackstorm",
					"body": "Autoattacking " + (2.5 * tickSpeed * character.hasteRating).toFixed(2) + " times per second. Consuming " + (1.25 * tickSpeed * character.hasteRating).toFixed(2) + " mana per second. Speed increases over time."
				};
			}
			character.buffs.addBuff(buff);
		}
		
		public function energizeEffect():void
		{
			SoundManager.instance.playSound("energize");
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.name = "Energize";
			buff.iconId = 35;
			buff.duration = 60000;
			buff.duration += 60000 * (0.2 * character.getTrait("ImprovedEnergize"));
			buff.tickRate = 1000;
			buff.tickFunction = function() {
				character.addEnergy(2);
			}
			buff.finishFunction = function() {
				removeEnergizeIndicator();
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Energize",
					"body": "Restoring 2 energy every " + (1 / character.hasteRating).toFixed(2) + " second."
				};
			}
			character.buffs.addBuff(buff);
			addEnergizeIndicator();
		}
		
		public function managizeEffect():void
		{
			var character:Character = CH2.currentCharacter;
			character.addMana((character.maxMana * 0.25) + ((character.maxMana * 0.25) * (0.2 * character.getTrait("ImprovedEnergize"))));
		}

		public function energizeExtendEffect():void						// Do Not Implement - Repeated use should increase buff duration by the base duration.
		{
			SoundManager.instance.playSound("Activate Potion");
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.iconId = 35;
			buff.duration = 120000;
			buff.tickRate = 1000;
			buff.tickFunction = function() {
				character.addEnergy(2);
			}
			buff.finishFunction = function() {
				removeEnergizeIndicator();
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Energize: Extend",
					"body": "Restoring 2 energy per second."
				};
			}
			character.buffs.addBuff(buff);
			addEnergizeIndicator();
		}
		
		public function energizeRushEffect():void
		{
			SoundManager.instance.playSound("Activate Potion");
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.iconId = 35;
			buff.duration = 5000;
			buff.tickRate = 100;
			buff.tickFunction = function() {
				character.addEnergy(5);
			}
			buff.finishFunction = function() {
				removeEnergizeIndicator();
				energizeEbbEffect;
			}
			
			buff.tooltipFunction = function() {
				return {
					"header": "Energize: Rush",
					"body": "Restoring 50 energy per second."
				};
			}
			character.buffs.addBuff(buff);
			addEnergizeIndicator();
		}

		public function energizeEbbEffect():void				// Do Not Implement/Fix - Ebb should automatically occur after Rush ends.
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();							
			buff.iconId = 35;
			buff.duration = 25000;
			buff.tickRate = 1000;
			buff.tickFunction = function() {
				character.addEnergy(1);
			}
			buff.finishFunction = function() {
				removeEnergizeIndicator();
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Energize: Ebb",
					"body": "Restoring 1 energy per second."
				};
			}
			character.buffs.addBuff(buff);
			addEnergizeIndicator();
		}
		
		public function reloadEffect():void
		{
			SoundManager.instance.playSound("reload");
			var character:Character = CH2.currentCharacter;
			var reloadBonus:Number = 0.4 + (0.2 * character.getTrait("ImprovedReload"));
			if (character.getTrait("SmallReloads"))
			{
				reloadBonus *= 0.2;
			}
			var energyRestored:Number = character.maxEnergy * reloadBonus;
			var manaRestored:Number = character.maxMana * reloadBonus;

			character.addEnergy(energyRestored);
			character.addMana(manaRestored);
			
			for (var id:String in character.skills)
			{
				if (character.skills[id].isActive && id != "Reload")
				{
					character.skills[id].cooldownRemaining -= character.skills[id].cooldown * reloadBonus;
				}
			}
			if (character.getTrait("Preload"))
			{
				var buff:Buff = new Buff();		
				buff.name = "Preload";
				buff.iconId = 168;
				buff.isUntimedBuff = true;
				buff.skillUseFunction = function(skill:Skill) {
					if (skill.name != "Reload")
					{
						skill.cooldownRemaining = skill.cooldown * 0.5;
						buff.isFinished = true;
						buff.onFinish();
					}
				}
				buff.tooltipFunction = function() {
					return {
						"header": "Preload",
						"body": "Reduces the cooldown of the next skill used by 50%."
					};
				}
				character.buffs.addBuff(buff);
			}
			if (character.getTrait("ReloadRampage"))
			{
				var goldToAdd:BigNumber = character.zoneStartGold.multiplyN(1 + reloadBonus).subtract(character.gold);
				character.addGold(goldToAdd);
			}
		}
		
		public function bigClicksEffect():void
		{
			var character:Character = CH2.currentCharacter;
			
			var stacksPerUse = 6 + character.getTrait("BigClickStacks");
			if (character.getTrait("DistributedBigClicks"))
			{
				stacksPerUse *= 2;
				if (character.getTrait("DistributedBigClicksScaling"))
				{
					stacksPerUse *= character.hasteRating;
				}
			}
			
			if (character.getTrait("UnlimitedBigClicks") && character.buffs.hasBuffByName("Big Clicks"))
			{
				var buff:Buff = character.buffs.getBuff("Big Clicks");
				buff.maximumStacks += stacksPerUse;
				buff.stacks += stacksPerUse;
				
			}
			else
			{
				var buff:Buff = new Buff();
				buff.name = "Big Clicks";
				buff.iconId = 198;
				buff.isUntimedBuff = true;
				buff.stacks = stacksPerUse;
				buff.maximumStacks = stacksPerUse;
				buff.attackFunction = function(attackDatas:Array) {
					if (attackDatas[0].isClickAttack) {
						
						if (character.getTrait("DistributedBigClicks") && character.getTrait("Stormbringer"))
						{
							var clickTorrent:Skill = character.getSkill("Clicktorrent");
							if (clickTorrent)
							{
								clickTorrent.cooldownRemaining -= 1000;
							}
						}
						if (!character.buffs.hasBuffByName("Huge Click"))
						{
							if (IdleHeroMain.IS_RENDERING) {
								SoundManager.instance.playSound("Big Click Hits");
								var effect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(BIG_CLICK);
								effect.gotoAndPlay(Rnd.integer(1,8));
								effect.isLooping = false;
								effect.rotation = Math.PI * Rnd.float( -0.13, 0.13);
								if (effect.rotation > 0)
								{
									effect.scaleX = -1;
								}
								CH2.world.addEffect(effect, CH2.world.roomsFront, attackDatas[0].monster.x, attackDatas[0].monster.y, World.REMOVE_EFFECT_WHEN_FINISHED, 1, 10);
								CH2.world.camera.shake(0.5, -25, 25);
							}
						}
						
						buff.stacks--;
						if (buff.stacks < 100)
						{
							if (IdleHeroMain.IS_RENDERING)
							{
								removeSingleBigClicksIndicator(buff.stacks);
							}
						}
						if (buff.stacks < 1) {
							buff.isFinished = true;
							buff.onFinish();
						}
					}
				}
				
				
				var damageBuff:Number = 3 * (Math.pow(1.25, character.getTrait("BigClicksDamage")));
				if (character.getTrait("DistributedBigClicks"))
				{
					damageBuff = (damageBuff - 1) * 0.5 + 1;
				}
				var damageBuffToolTip:Number = damageBuff * 100;
				buff.tooltipFunction = function() {
					return {
						"header": "Big Clicks",
						"body": "Your clicks deal " +  damageBuffToolTip.toFixed(2) + "% damage."
					};
				}
				buff.buffStat(CH2.STAT_CLICK_DAMAGE, damageBuff);
				
				character.buffs.addBuff(buff);
				
				
				if (character.getTrait("CurseOfTheJuggernaut"))
				{
					var juggernautBuff:Buff = new Buff();
					juggernautBuff.name = "Curse Of The Juggernaut";
					juggernautBuff.iconId = 198;
					juggernautBuff.isUntimedBuff = true;
					juggernautBuff.stacks = 1
					juggernautBuff.maximumStacks = 0;
					juggernautBuff.skillUseFunction = function(skill:Skill) {
//						CH2.currentCharacter.addEnergy(-juggernautBuff.stacks);
						juggernautBuff.stacks++;
					}
					juggernautBuff.tooltipFunction = function() {
						return {
							"header": "Curse of the Juggernaut",
							"body": "Your skills cost " +  juggernautBuff.stacks + " additional energy."
						};
					}
					
					buff.finishFunction = function() {
						CH2.currentCharacter.buffs.removeBuff("Curse Of The Juggernaut");
					}
					
					character.buffs.addBuff(juggernautBuff);
				}
			}
			
			
			SoundManager.instance.playSound("Big Click Activated");
			if (IdleHeroMain.IS_RENDERING)
			{
				addBigClicksIndicators();
			}
		}
		
		public function powerSurgeEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var damage:Number = 2 * Math.pow(1.25, character.getTrait("ImprovedPowersurge"));
			var buff:Buff = new Buff();
			buff.name = "Powersurge";
			buff.iconId = 150;
			buff.isUntimedBuff = false;
			buff.duration =  60000 * Math.pow(1.2, character.getTrait("SustainedPowersurge"));
			buff.attackFunction = function(attackDatas:Array) {
				if (attackDatas[0].isClickAttack) {
					var effect:GpuMovieClip = getBamplode(Rnd.integer(1,4));
					effect.gotoAndPlay(1);
					effect.isLooping = false;
					CH2.world.addEffect(effect, CH2.world.roomsFront, attackDatas[0].monster.x, attackDatas[0].monster.y);
				}
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Powersurge",
					"body": "Your clicks deal " + (damage * 100).toFixed(2) + "% damage."
				};
			}
			buff.buffStat(CH2.STAT_CLICK_DAMAGE, damage);
			
			if (character.getTrait("PowerSurgeCritChance"))
			{
				buff.tickRate = 1000;
//				buff.buffStat(CH2.STAT_CRIT_CHANCE, -1.0);
				buff.tickFunction = function() {
					buff.buffStat(CH2.STAT_CRIT_CHANCE, buff.getStatValue(CH2.STAT_CRIT_CHANCE) + 0.01);
				}
			}
			
			character.buffs.addBuff(buff);
			SoundManager.instance.playSound("power_surge_activate");
		}
		
		public function hugeClickEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var damage:Number = 10.00 * (Math.pow(1.25, character.getTrait("HugeClickDamage")));
			var buff:Buff = new Buff();
			buff.name = "Huge Click";
			buff.iconId = 199;
			buff.isUntimedBuff = true;
			if (character.getTrait("HecatonsEcho"))
			{
				buff.stacks = 101;
			}
			else
			{
				buff.stacks = 1;
			}
			buff.attackFunction = function(attackDatas:Array) {
				if (attackDatas[0].isClickAttack)
				{
					if (buff.stacks % 20 == 1)
					{
						if (!character.buffs.hasBuffByName("Big Clicks"))
						{
							var effect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(HUGE_CLICK);
							effect.gotoAndPlay(1);
							effect.isLooping = false;
							CH2.world.addEffect(effect, CH2.world.roomsFront, attackDatas[0].monster.x, attackDatas[0].monster.y);
							Shaker.add(CH2.world.roomsBack, -100, 100, 0.5, 0);
							CH2.world.camera.shake(0.5, -100, 100);
						}
						else
						{
							//This is a Big Click and a Huge Click play the special animation
							var effect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(BIG_GIANT_CLICK);
							effect.gotoAndPlay(1);
							effect.isLooping = false;
							CH2.world.addEffect(effect, CH2.world.roomsFront, attackDatas[0].monster.x, attackDatas[0].monster.y);
							Shaker.add(CH2.world.roomsBack, -200, 200, 0.5, 0);
							CH2.world.camera.shake(0.5, -200, 200);
						}
						
						if (!attackDatas[0].monster.isFinalBoss)
						{
							var crackEffect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(HUGE_CLICK_CRACK);
							crackEffect.gotoAndPlay(1);
							crackEffect.isLooping = false;
							CH2.world.addEffect(crackEffect, CH2.world.roomsBack, attackDatas[0].monster.x, attackDatas[0].monster.y, World.REMOVE_EFFECT_WHEN_OFFSCREEN);
						}
						
						SoundManager.instance.playSound("huge_click", .8, SoundManager.EFFECTS_PRIORITY);
						
						if (character.getTrait("HugeClickDiscount")) {
							var discountBuff:Buff = new Buff();
							discountBuff.name = "Huge Click Discount";
							discountBuff.iconId = 99;
							discountBuff.duration = 4000;
							discountBuff.unhastened = true;
//							discountBuff.buffStat(CH2.STAT_ITEM_COST_REDUCTION, 0.02 * 10.00 * (Math.pow(1.25, character.getTrait("HugeClickDamage"))));
							discountBuff.buffStat(CH2.STAT_ITEM_COST_REDUCTION, 1 / (1 + (0.005 * 10.00 * (1.25 * character.getTrait("HugeClickDamage")))));
							discountBuff.tooltipFunction = function() {
								return {
									"header": "Huge Click Discount",
									"body": "Item costs " + ((1 / (1 + (0.005 * 10.00 * (1.25 * character.getTrait("HugeClickDamage"))))) * 100).toFixed(2) + "%."
								};
							}
							character.buffs.addBuff(discountBuff);
						}
						buff.buffStat(CH2.STAT_CLICK_DAMAGE, 1);
					}
					
					buff.stacks--;
					
					if (buff.stacks <= 0) 
					{
						buff.isFinished = true;
						buff.onFinish();
					}
					else if (buff.stacks % 20 == 1)
					{
						buff.buffStat(CH2.STAT_CLICK_DAMAGE, damage);
					}
				}
			}
			buff.buffStat(CH2.STAT_CLICK_DAMAGE, damage);
			
			buff.tooltipFunction = function() {
				return {
					"header": "Huge Click",
					"body": "Your next click deals " + (damage * 100).toFixed(2) + "% damage."
				};
			}
			character.buffs.addBuff(buff);
			SoundManager.instance.playSound("huge_click_activate");
		}
		
		public function manaClickEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.name = "Mana Crit";
			buff.duration = 1;
			buff.tickRate = 1;
			
			if (character.getTrait("ImprovedManaCrit"))
			{
				buff.buffStat(CH2.STAT_CLICK_DAMAGE, Math.pow(1.25, character.getTrait("ManaCritDamage")) * (1 + character.criticalChance));
				var restoreMana:Boolean = CH2.roller.attackRoller.boolean(character.criticalChance);
				if (restoreMana) 
				{
					character.addMana(character.getSkill("Mana Crit").manaCost);
				}
			}
			else
			{
				buff.buffStat(CH2.STAT_CLICK_DAMAGE, Math.pow(1.25, character.getTrait("ManaCritDamage")));
			}
			
			buff.buffStat(CH2.STAT_CRIT_CHANCE, 1);
			character.buffs.addBuff(buff);
			character.clickAttack();
			character.buffs.removeBuff("Mana Crit");
		}
		
		public function addBigClicksIndicators():void
		{
			for (var i:int = 0; (i < CH2.currentCharacter.buffs.getBuff("Big Clicks").stacks) && (i < 100); i++)
			{
				if (bigClicksIndicators[i] != null)
				{
					removeSingleBigClicksIndicator(i);
				}
				
				bigClicksIndicators[i] = new CharacterUIElement();
				bigClicksIndicators[i].active = true;
				bigClicksIndicators[i].name = "Big_Clicks_Indicator_" + i;
				var indicatorAsset:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(BUFF_INDICATOR);
				indicatorAsset.playScene("idle", true);
				indicatorAsset.gotoAndPlay(Rnd.integer(i+1, i+3));
				bigClicksIndicators[i].addChild(indicatorAsset);
				bigClicksIndicators[i].type = CharacterDisplayUI.OTHER_ELEMENT;
				bigClicksIndicators[i].useWorldCoordinates = false;
				bigClicksIndicators[i].worldX = CH2.currentCharacter.x + Rnd.float(0,10);
				bigClicksIndicators[i].worldY = CH2.currentCharacter.y - 100 + Rnd.float(0,10);
				bigClicksIndicators[i].modStateHolder["num"] = i;
				bigClicksIndicators[i].updateHook = function(dt:Number):void
				{
					this.angle = Math.atan2( ((CH2.currentCharacter.y - this.modStateHolder["num"]*8) - 100 - this.worldY), ((CH2.currentCharacter.x) - this.worldX) );
					this.force = Math.sqrt(Math.pow((CH2.currentCharacter.x) - this.worldX, 2) + Math.pow((CH2.currentCharacter.y - this.modStateHolder["num"] * 8) - this.worldY - 100, 2)) / 100;
					this.worldX += 30 * dt/1000 * this.worldXVel;
					this.worldY += 30 * dt/1000 * this.worldYVel;
					
					this.worldXVel += this.force * Math.cos( this.angle );
					this.worldYVel += this.force * Math.sin( this.angle );
					this.worldXVel *= this.drag;
					this.worldYVel *= this.drag;
					
					this.x = CH2.world.worldToScreenX(this.worldX, this.worldY);
					this.y = CH2.world.worldToScreenY(this.worldX, this.worldY);
				}
				if (!CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(bigClicksIndicators[i].name))
				{
					CH2.currentCharacter.characterDisplay.characterUI.addUIElement(bigClicksIndicators[i], CH2.world.roomsFront);
				}
			}
		}
		
		public function removeSingleBigClicksIndicator(num:int):void
		{
			if (CH2.currentCharacter.characterDisplay.characterUI.hasUIElement("Big_Clicks_Indicator_"+num))
			{
				var indicatorAsset:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(BUFF_INDICATOR);
				indicatorAsset.playScene("launch", true);
				indicatorAsset.isLooping = false;
				CH2.world.addEffect(indicatorAsset, CH2.world.roomsFront, bigClicksIndicators[num].worldX, bigClicksIndicators[num].worldY, World.REMOVE_EFFECT_WHEN_FINISHED_OR_HITS_CAP, 2, 20);
				
				CH2.currentCharacter.characterDisplay.characterUI.removeUIElement(bigClicksIndicators[num]);
				bigClicksIndicators[num] = null;
			}
		}
		
		public function addEnergizeIndicator():void
		{
			energizeIndicator.name = "Energize_Indicator";
			
			if (!CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(energizeIndicator.name))
			{
				var animation:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(ENERGY_CHARGE);
				animation.isLooping = true;
				
				energizeIndicator.active = true;
				energizeIndicator.removeChildren();
				energizeIndicator.addChild(animation);
				energizeIndicator.type = CharacterDisplayUI.OTHER_ELEMENT;
				energizeIndicator.x = 0;
				energizeIndicator.y = 0;
				energizeIndicator.visible = true;
				
				CH2.currentCharacter.characterDisplay.characterUI.addUIElement(energizeIndicator, CH2.currentCharacter.characterDisplay.characterUI.frontCharacterDisplay);
			}
		}
		
		public function removeEnergizeIndicator():void
		{
			if (CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(energizeIndicator.name))
			{
				energizeIndicator.visible = false;
				CH2.currentCharacter.characterDisplay.characterUI.removeUIElement(energizeIndicator);
			}
		}
		
		public function getBamplode(num:int):GpuMovieClip
		{
			return CH2AssetManager.instance.getGpuMovieClip(CHARACTER_ASSET_GROUP+"_bamplode"+num);
		}
		
		public function onStaticDataLoaded(staticData:Object):void
		{
			
		}
		
		public function onUserDataLoaded():void
		{
		}
		
		public function onCharacterCreated(characterInstance:Character):void
		{
			if (characterInstance.name == CHARACTER_NAME)
			{
				characterInstance.modDependencies[CHARACTER_NAME] = true;
				characterInstance.assetGroupName = CHARACTER_ASSET_GROUP;
				
				characterInstance.onCharacterDisplayCreatedHandler = this;
				characterInstance.attackHandler = this;
				characterInstance.onKilledMonsterHandler = this;
				characterInstance.addGoldHandler = this;
				characterInstance.addEnergyHandler = this;
				characterInstance.canUseSkillHandler = this;
				characterInstance.addManaHandler = this;
				characterInstance.onZoneChangedHandler = this;
				characterInstance.getCalculatedEnergyCostHandler = this;
				characterInstance.generateCatalogHandler = this;
				characterInstance.onMigrationHandler = this;
				characterInstance.populateRubyPurchaseOptionsHandler = this;
				
				createFixedFirstRunCatalogs(FIXED_FIRST_RUN_CATALOG_DATA);
			}
		}
		
		//public function helpfulAdventurerOnMigration(characterInstance:Character):void
		public function onMigrationOverride(characterInstance:Character):void
		{
			// 0.07
			if (characterInstance.version <= 2)
			{
				// fix saves that have the "buy astral shards" gem, give them stone replacement
				var gemsRemoved:int = characterInstance.automator.removeGemFromSave("Helpful Adventurer_66");
				for (var i:int = 0; i < gemsRemoved; i++)
				{
					characterInstance.automator.unlockStone("LT1WorldCompletions");
				}
			}
			
			if (characterInstance.version <= 1)
			{
				// fix saves with broken 4s stones
				characterInstance.automator.removeStoneFromSave("Helpful Adventurer_21", "Helpful Adventurer_11");
				
				// delete existing automator nodes so that they can be repurchased in the new tree
				for (var i:int = 16; i <= 38; i++)
				{
					if (characterInstance.nodesPurchased[i])
					{
						delete characterInstance.nodesPurchased[i];
					}
				}
				
				for (var i:int = 775; i <= 848; i++)
				{
					if (characterInstance.nodesPurchased[i])
					{
						delete characterInstance.nodesPurchased[i];
					}
				}
			}
			
			// 0.06
			if (characterInstance.version == 0)
			{
				if (characterInstance.highestWorldCompleted >= 16 && characterInstance.gilds == 0)
				{
					characterInstance.runsCompletedPerWorld = { };
					characterInstance.highestMonstersKilled = { };
					for (var i:int = 0; i <= 16; i++)
					{
						characterInstance.runsCompletedPerWorld[i] = 0;
						characterInstance.highestMonstersKilled[i] = 0;
					}
					characterInstance.highestWorldCompleted = 1;
					characterInstance.currentWorldId = 16;
					characterInstance.finishWorld();
					characterInstance.worlds.ascensionWorlds = [];
					characterInstance.totalStatPointsV2 += 3;
				}
			}
		}
		
		//public function helpfulAdventurerGetCalculatedEnergyCost(skill:Skill):Number
		public function getCalculatedEnergyCostOverride(skill:Skill):Number
		{
			if (!skill.usesMaxEnergy)
			{
				var cost:Number = skill.energyCost * (1 - CH2.currentCharacter.energyCostReduction);
				if (CH2.currentCharacter.buffs.hasBuffByName("Curse Of The Juggernaut"))
				{
					var juggernautBuff:Buff = CH2.currentCharacter.buffs.getBuff("Curse Of The Juggernaut");
					cost += juggernautBuff.stacks;
				}
				return cost;
			}
			else
			{
				return this.maxEnergy;
			}
		}
		
		/*private function autoAttack():void
		{
			CH2.currentCharacter.autoAttackDefault();
		}*/
		
		/*private function clickAttack(doesCostEnergy:Boolean = true):void
		{
			CH2.currentCharacter.clickAttackDefault(doesCostEnergy);
		}*/
		
		//public function setUpDisplay(display:CharacterDisplay):void
		public function onCharacterDisplayCreatedOverride(display:CharacterDisplay):void
		{
			display.playDash = dashAnimation;
			display.msBetweenStepSounds = 375;
			
			// Load audio
			SoundManager.instance.loadAudioClass("audio/HelpfulAdventurer/huge_click");
			SoundManager.instance.loadAudioClass("audio/HelpfulAdventurer/critical_hit");
			SoundManager.instance.loadAudioClass("audio/HelpfulAdventurer/hit");
			SoundManager.instance.loadAudioClass("audio/HelpfulAdventurer/get_hit");
			SoundManager.instance.loadAudioClass("audio/HelpfulAdventurer/Big Click Activated");
			SoundManager.instance.loadAudioClass("audio/HelpfulAdventurer/Big Click Hits");
			SoundManager.instance.loadAudioClass("audio/HelpfulAdventurer/clickdash0");
			SoundManager.instance.loadAudioClass("audio/HelpfulAdventurer/clickdash1");
			SoundManager.instance.loadAudioClass("audio/HelpfulAdventurer/huge_click_activate");
			SoundManager.instance.loadAudioClass("audio/HelpfulAdventurer/power_surge_activate");
			SoundManager.instance.loadAudioClass("audio/HelpfulAdventurer/reload");
			SoundManager.instance.loadAudioClass("audio/HelpfulAdventurer/energize");
		}
		
		public function dashAnimation(distance:Number = 0):void
		{
			//Play default dash
			CH2.currentCharacter.characterDisplay.playDashDefault(distance);
			
			//Play Dash sound
			SoundManager.instance.playSound("clickdash" + Rnd.integer(2)); //clickDash0 or clickDash1
			
			//Add the fire effect
			var teleportOriginWorldY:Number = CH2.currentCharacter.y - distance;
			var firePatchLocation:Number = CH2.currentCharacter.y - 20;
			var fireLengthY:int = 50;
			var i:Number = 0;
			while(firePatchLocation >= teleportOriginWorldY)
			{
				var animation:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(CHARACTER_ASSET_GROUP+"_fire", 60);
				var frameToStartFireOn:int = Math.min(1 + (i * 3), 37);
				animation.gotoAndPlay(1 + (i * 3)); //Start on a later frame the further the fire is from the character
				animation.isLooping = false;
				CH2.world.addEffect(animation, CH2.world.roomsBack, CH2.currentCharacter.x, firePatchLocation);
				firePatchLocation -= fireLengthY;
				i++;
			}
		}
		
		public function canActivateDashGem():Boolean
		{
			return (CH2.currentCharacter.isInTeleportClickAttackState && CH2.currentCharacter.canAffordClickAttack);
		}
		
		public function onDashGemActivate():Boolean
		{
			if (canActivateDashGem())
			{
				CH2.currentCharacter.clickAttack();
				return true;
			}
			return false;
		}
		
		public function onDummyAlwaysGemActivate():Boolean
		{
			return true;
		}
		
		public function onDummyNeverGemActivate():Boolean
		{
			return false;
		}
		
		public function canBuyRandomCatalogItem():Boolean
		{
			var character:Character = CH2.currentCharacter;
			if (!character.didFinishWorld && character.catalogItemsForSale && character.catalogItemsForSale.length > 0)
			{
				var catalog:Array = character.catalogItemsForSale;
				var randomItemIndex:int = CH2.roller.modRoller.integer(0, catalog.length-1);
				var randomItem:Item = catalog[randomItemIndex];
				
				return (!character.isPurchasingLocked && character.gold.gte(randomItem.cost()));
			}
			else
			{
				return false;
			}
		}
		
		public function onBuyRandomCatalogItemGemActivate():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked || character.didFinishWorld)
			{
				return false;
			}
			
			var catalog:Array = character.catalogItemsForSale;
			var randomItemIndex:int = CH2.roller.modRoller.integer(0, catalog.length - 1);
			var randomItem:Item = catalog[randomItemIndex];
			if (character.gold.gte(randomItem.cost()))
			{
				character.purchaseCatalogItem(randomItemIndex);
				CH2UI.instance.refreshDamageDisplays();
				return true;
			}
			return false;
		}
		
		public function canUpgradeCheapestItem():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked)
			{
				return false;
			}
			if (character.inventory.items.length <= 0)
			{
				return false;
			}
			
			var item:Item;
			var cheapestItem:Item;
			var cheapestCost:BigNumber;
			var isCatalogItem:Boolean;
			var catalogIndex:int;
			
			// check for cheapest in inventory
			var inventory:Array = character.inventory.items;
			for each (item in inventory)
			{
				var cost:BigNumber = item.costForNextLevel();
				if (cheapestCost == null || cost.lt(cheapestCost))
				{
					cheapestItem = item;
					cheapestCost = cost;
					isCatalogItem = false;
				}
			}
			
			// check for cheapest in catalog
			var catalog:Array = character.catalogItemsForSale;
			var catalogLength:int = catalog.length;
			for (var i:int = 0; i < catalogLength; i++)
			{
				item = catalog[i];
				var cost:BigNumber = item.costForNextLevel();
				if (cheapestCost == null || cost.lt(cheapestCost))
				{
					cheapestItem = item;
					cheapestCost = cost;
					isCatalogItem = true;
					catalogIndex = i;
				}
			}
			
			return (cheapestItem != null && character.gold.gte(cheapestCost));
		}
		
		public function canUpgradeCheapestItemToNextMultiplier():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked || character.inventory.items.length <= 0)
			{
				return false;
			}
			
			var item:Item;
			var cheapestItem:Item;
			var cheapestCost:BigNumber;
			var inventory:Array = character.inventory.items;
			for each (item in inventory)
			{
				var cost:BigNumber = item.cost(item.levelsBetweenMultipliers - (item.level % item.levelsBetweenMultipliers));
				if (cheapestCost == null || cost.lt(cheapestCost))
				{
					cheapestItem = item;
					cheapestCost = cost;
				}
			}
			
			return (cheapestItem != null && character.gold.gte(cheapestCost));
		}
		
		public function getXNewestItem(numBeforeCurrent:int):Item
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.inventory.items.length >= numBeforeCurrent)
			{
				var currentCatalogRank:int = character.currentCatalogRank; //rank of most recently purchased item
				var rankOfItemToUpgrade:int = currentCatalogRank - numBeforeCurrent + 1;
				var inventory:Array = character.inventory.items;
				for each (item in inventory)
				{
					if (item.rank == rankOfItemToUpgrade)
					{
						if (character.gold.gte(item.costForNextLevel()))
						{
							return item;
						}
					}
				}
			}
			else
			{
				return null;
			}
		}
		
		public function canBuyMetalDetectors():Boolean
		{
			if (CH2.world && CH2.world.rubyBonusShop && CH2.world.rubyBonusShop.isActive)
			{
				var character:Character = CH2.currentCharacter;
				var canPurchase:Boolean = false;
				if (character.currentRubyShop.length > 0)
				{
					for (var i:int = 0; i < character.currentRubyShop.length; i++)
					{
						if (character.currentRubyShop[i].iconId == 5) //Probably a better way to do this
						{
							var rubyPurchasePrice:Number = character.currentRubyShop[i].price;
							canPurchase = canPurchase || (character.rubies >= rubyPurchasePrice && character.currentRubyShop[i].canPurchase());
						}
					}
				}
				return canPurchase;
			}
			else
			{
				return false;
			}
		}
		
		public function canBuyRunes():Boolean
		{
			if (CH2.world && CH2.world.rubyBonusShop && CH2.world.rubyBonusShop.isActive)
			{
				var character:Character = CH2.currentCharacter;
				var canPurchase:Boolean = false;
				if (character.currentRubyShop.length > 0)
				{
					for (var i:int = 0; i < character.currentRubyShop.length; i++)
					{
						if (character.currentRubyShop[i].iconId == 2 || character.currentRubyShop[i].iconId == 3 || character.currentRubyShop[i].iconId == 4) //Probably a better way to do this
						{
							var rubyPurchasePrice:Number = character.currentRubyShop[i].price;
							canPurchase = canPurchase || (character.rubies >= rubyPurchasePrice && character.currentRubyShop[i].canPurchase());
						}
					}
				}
				return canPurchase;
			}
			else
			{
				return false;
			}
		}
		
		public function canUpgradeThirdNewestItem():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked || character.inventory.items.length < 3)
			{
				return false;
			}
			
			var itemToUpgrade:Item = getXNewestItem(3);
			if (itemToUpgrade)
			{
				return (character.gold.gte(itemToUpgrade.costForNextLevel()));
			}
			else
			{
				return false;
			}
		}
		
		public function canUpgradeSecondNewestItem():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked || character.inventory.items.length < 2)
			{
				return false;
			}
			
			var itemToUpgrade:Item = getXNewestItem(2);
			if (itemToUpgrade)
			{
				return (character.gold.gte(itemToUpgrade.costForNextLevel()));
			}
			else
			{
				return false;
			}
		}
		
		public function canUpgradeNewestItem():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked)
			{
				return false;
			}
			if (character.inventory.items.length <= 0)
			{
				return false;
			}
			var item:Item;
			var newestItem:Item;
			var newestRank:Number = 0;
			var newestCost:BigNumber;
			
			// Find newest item
			var inventory:Array = character.inventory.items;
			for each (item in inventory)
			{
				var rank:Number = item.rank;
				
				if (newestRank == 0 || rank > newestRank)
				{
					newestItem = item;
					newestRank = rank;
					newestCost = item.costForNextLevel();
				}
			}
			
			return (newestItem != null && character.gold.gte(newestCost));
		}
		
		public function onUpgradeNewestItemGemActivate():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked)
			{
				return false;
			}
			
			var item:Item;
			var newestItem:Item;
			var newestRank:Number = 0;
			var newestCost:BigNumber;
			
			var inventory:Array = character.inventory.items;
			for each (item in inventory)
			{
				var rank:Number = item.rank;
				if (newestRank == 0 || rank > newestRank)
				{
					newestItem = item;
					newestRank = rank;
					newestCost = item.costForNextLevel();
				}
			}
			
			if (newestItem != null && character.gold.gte(newestCost))
			{
				character.levelUpItem(newestItem);
				return true;
			}
			return false;
		}
		
		public function canUpgradeAllItems():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked)
			{
				return false;
			}
			if (character.inventory.items.length <= 0)
			{
				return false;
			}
			
			var item:Item;
			
			var inventory:Array = character.inventory.items;
			var totalCost:BigNumber = new BigNumber(0);
			for each (item in inventory)
			{
				totalCost.plusEquals(item.costForNextLevel());
			}
			
			return (character.gold.gte(totalCost));
		}
		
		public function onUpgradeAllItemsGemActivate():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked)
			{
				return false;
			}
			
			var item:Item;
			
			var inventory:Array = character.inventory.items;
			var totalCost:BigNumber = new BigNumber(0);
			for each (item in inventory)
			{
				totalCost.plusEquals(item.costForNextLevel());
			}
			
			if (character.gold.gte(totalCost))
			{
				for each (item in inventory)
				{
					character.levelUpItem(item);
					CH2UI.instance.refreshDamageDisplays();
				}
				return true;
			}
			
			return false;
		}
		
		public function onSwapToSet(queueSet:int):Boolean
		{
			if (CH2.currentCharacter.automator.currentQueueIndex == queueSet)
			{
				return false;
			}
			if (CH2.currentCharacter.automator.numSetsUnlocked >= queueSet)
			{
				CH2.currentCharacter.automator.setCurrentQueue(queueSet);
				CH2UI.instance.mainUI.mainPanel.refreshOpenTab();
				CH2UI.instance.mainUI.mainPanel.automatorPanel.refreshPauseButton();
			}
			return true;
		}
		
		public function onSwapToFirstSet():Boolean
		{
			return onSwapToSet(1);
		}
		public function onSwapToSecondSet():Boolean
		{
			return onSwapToSet(2);
		}
		
		public function onSwapToThirdSet():Boolean
		{
			return onSwapToSet(3);
		}
		
		public function onSwapToFourthSet():Boolean
		{
			return onSwapToSet(4);
		}
		public function onSwapToFifthSet():Boolean
		{
			return onSwapToSet(5);
		}
		
		public function canSwapToSet(queueSetIndex:int):Boolean
		{
			if (CH2.currentCharacter.automator.numSetsUnlocked >= queueSetIndex && CH2.currentCharacter.automator.currentQueueIndex != queueSetIndex)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function canSwapToFirstSet():Boolean
		{
			return canSwapToSet(1);
		}
		public function canSwapToSecondSet():Boolean
		{
			return canSwapToSet(2);
		}
		
		public function canSwapToThirdSet():Boolean
		{
			return canSwapToSet(3);
		}
		
		public function canSwapToFourthSet():Boolean
		{
			return canSwapToSet(4);
		}
		
		public function canSwapToFifthSet():Boolean
		{
			return canSwapToSet(5);
		}
		
		public function onUpgradeCheapestItemGemActivate():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked)
			{
				return false;
			}
			
			var item:Item;
			var cheapestItem:Item;
			var cheapestCost:BigNumber;
			var isCatalogItem:Boolean;
			var catalogIndex:int;
			
			// check for cheapest in inventory
			var inventory:Array = character.inventory.items;
			for each (item in inventory)
			{
				var cost:BigNumber = item.costForNextLevel();
				if (cheapestCost == null || cost.lt(cheapestCost))
				{
					cheapestItem = item;
					cheapestCost = cost;
					isCatalogItem = false;
				}
			}
			
			// check for cheapest in catalog
			var catalog:Array = character.catalogItemsForSale;
			var catalogLength:int = catalog.length;
			for (var i:int = 0; i < catalogLength; i++)
			{
				item = catalog[i];
				var cost:BigNumber = item.costForNextLevel();
				if (cheapestCost == null || cost.lt(cheapestCost))
				{
					cheapestItem = item;
					cheapestCost = cost;
					isCatalogItem = true;
					catalogIndex = i;
				}
			}
			
			if (cheapestItem != null && character.gold.gte(cheapestCost))
			{
				if (isCatalogItem)
				{
					character.purchaseCatalogItem(catalogIndex);
				}
				else
				{
					character.levelUpItem(cheapestItem);
				}
				return true;
			}
			return false;
		}
		
		public function onUpgradeCheapestItemToNextMultiplierGemActivate():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked || character.inventory.items.length <= 0)
			{
				return false;
			}
			
			var item:Item;
			var cheapestItem:Item;
			var cheapestCost:BigNumber;
			var inventory:Array = character.inventory.items;
			for each (item in inventory)
			{
				var cost:BigNumber = item.cost(item.levelsBetweenMultipliers - (item.level % item.levelsBetweenMultipliers));
				if (cheapestCost == null || cost.lt(cheapestCost))
				{
					cheapestItem = item;
					cheapestCost = cost;
				}
			}
			
			if (cheapestItem != null && character.gold.gte(cheapestCost))
			{
				character.levelUpItem(cheapestItem, cheapestItem.levelsBetweenMultipliers - (cheapestItem.level % cheapestItem.levelsBetweenMultipliers));
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function onBuyMetalDetectorsGemActivate():Boolean
		{
			if (CH2.world && CH2.world.rubyBonusShop && CH2.world.rubyBonusShop.isActive)
			{
				var character:Character = CH2.currentCharacter;
				var madePurchase:Boolean = false;
				if (character.currentRubyShop.length > 0)
				{
					for (var i:int = 0; i < character.currentRubyShop.length; i++)
					{
						if (character.currentRubyShop[i].iconId == 5) //Probably a better way to do this
						{
							CH2UI.instance.mainUI.rightPanel.currentPanel.doPurchase(character.currentRubyShop[i]);
							madePurchase = true;
						}
					}
				}
				return madePurchase;
			}
			else
			{
				return false;
			}
		}
		
		public function onBuyRunesGemActivate():Boolean
		{
			if (CH2.world && CH2.world.rubyBonusShop && CH2.world.rubyBonusShop.isActive)
			{
				var character:Character = CH2.currentCharacter;
				var madePurchase:Boolean = false;
				if (character.currentRubyShop.length > 0)
				{
					for (var i:int = 0; i < character.currentRubyShop.length; i++)
					{
						if (character.currentRubyShop[i].iconId == 2 || character.currentRubyShop[i].iconId == 3 || character.currentRubyShop[i].iconId == 4) //Probably a better way to do this
						{
							CH2UI.instance.mainUI.rightPanel.currentPanel.doPurchase(character.currentRubyShop[i]);
							madePurchase = true;
						}
					}
				}
				return madePurchase;
			}
			else
			{
				return false;
			}
		}
		
		public function onLT1WorldCompletionsActivate():Boolean
		{
			return CH2.currentCharacter.runsCompletedPerWorld[CH2.currentCharacter.currentWorldId] < 1;
		}
		
		public function onGT1WorldCompletionsActivate():Boolean
		{
			return CH2.currentCharacter.runsCompletedPerWorld[CH2.currentCharacter.currentWorldId] >= 1;
		}
		
		public function onUpgradeAllCheapestItemsGemActivate():Boolean
		{
			if (!canUpgradeCheapestItem())
			{
				return false;
			}
			while (canUpgradeCheapestItem())
			{
				onUpgradeCheapestItemGemActivate();
			}
			return true;
		}
		
		public function onUpgradeThirdNewestItemGemActivate():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (canUpgradeThirdNewestItem())
			{
				character.levelUpItem(getXNewestItem(3));
				return true;
			}
			return false;
		}
		
		public function onUpgradeSecondNewestItemGemActivate():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (canUpgradeSecondNewestItem())
			{
				character.levelUpItem(getXNewestItem(2));
				return true;
			}
			return false;
		}
		
		public function canUpgradeFirstAffordableItem():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked)
			{
				return false;
			}
			
			var currentGold:BigNumber = character.gold;
			var item:Item;
			
			// check inventory for first affordable item
			var inventory:Array = character.inventory.items;
			for each (item in inventory)
			{
				if (currentGold.gte(item.costForNextLevel()))
				{
					character.levelUpItem(item);
					return true;
				}
			}
			
			// check catalog for first affordable item
			var catalog:Array = character.catalogItemsForSale;
			var catalogLength:int = catalog.length;
			for (var i:int = 0; i < catalogLength; i++)
			{
				item = catalog[i];
				if (currentGold.gte(item.costForNextLevel()))
				{
					return true;
				}
			}
			return false;
		}
		
		public function onUpgradeFirstAffordableItemGemActivate():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.isPurchasingLocked)
			{
				return false;
			}
			
			var currentGold:BigNumber = character.gold;
			var item:Item;
			
			// check inventory for first affordable item
			var inventory:Array = character.inventory.items;
			for each (item in inventory)
			{
				if (currentGold.gte(item.costForNextLevel()))
				{
					character.levelUpItem(item);
					return true;
				}
			}
			
			// check catalog for first affordable item
			var catalog:Array = character.catalogItemsForSale;
			var catalogLength:int = catalog.length;
			for (var i:int = 0; i < catalogLength; i++)
			{
				item = catalog[i];
				if (currentGold.gte(item.costForNextLevel()))
				{
					character.purchaseCatalogItem(i);
					return true;
				}
			}
			
			return false;
		}
		
		public function canAttemptBoss():Boolean
		{
			var character:Character = CH2.currentCharacter;
			var world:World = CH2.world;
			return (character.hasCompletedCurrentZone() && world.isBossZone(character.currentZone+1));
		}
		
		public function onAttemptBossGemActivate():Boolean
		{
			if (canAttemptBoss())
			{
				CH2.world.moveToNextZone();
				return true;
			}
			return false;
		}
		
		public function hastenSkill(skillName:String, multiplier:Number)
		{
			var skill:Skill = CH2.currentCharacter.getSkill(skillName);
			skill.cooldown *= multiplier;
			skill.manaCost *= multiplier;
			skill.energyCost *= multiplier;
			skill.cooldownRemaining = Math.min(skill.cooldownRemaining, skill.cooldown);
		}
		
		public function hastenClickstorm():void
		{
			var clickstorm:Skill = CH2.currentCharacter.getSkill("Clickstorm");
			clickstorm.cooldown *= 0.80;
			clickstorm.cooldownRemaining = Math.min(clickstorm.cooldownRemaining, clickstorm.cooldown);
			var critstorm:Skill = CH2.currentCharacter.getSkill("Critstorm");
			critstorm.cooldown *= 0.80;
			critstorm.cooldownRemaining = Math.min(critstorm.cooldownRemaining, critstorm.cooldown);
			var autoattackstorm:Skill = CH2.currentCharacter.getSkill("Autoattackstorm");
			autoattackstorm.cooldown *= 0.80;
			autoattackstorm.cooldownRemaining = Math.min(autoattackstorm.cooldownRemaining, autoattackstorm.cooldown);
			var goldenclicks:Skill = CH2.currentCharacter.getSkill("GoldenClicks");
			goldenclicks.cooldown *= 0.80;
			goldenclicks.cooldownRemaining = Math.min(goldenclicks.cooldownRemaining, goldenclicks.cooldown);
			var clicktorrent:Skill = CH2.currentCharacter.getSkill("Clicktorrent");
			clicktorrent.cooldown *= 0.80;
			clicktorrent.cooldownRemaining = Math.min(clicktorrent.cooldownRemaining, clicktorrent.cooldown);
		}
		
		public function hastenEnergize():void
		{
			var energize:Skill = CH2.currentCharacter.getSkill("Energize");
			energize.manaCost *= 0.80;
			energize.cooldown *= 0.80;
			energize.cooldownRemaining = Math.min(energize.cooldownRemaining, energize.cooldown);
			var managize:Skill = CH2.currentCharacter.getSkill("Managize");
			managize.cooldown *= 0.80;
			managize.cooldownRemaining = Math.min(managize.cooldownRemaining, managize.cooldown);
		}
		
		public function applySmallReloads():void
		{
			hastenSkill("Reload", 0.2);
			CH2.currentCharacter.setTrait("SmallReloads", 1);
		}
		
		//public function helpfulAdventurerGenerateCatalog():void
		public function generateCatalogOverride():void
		{
			var character:Character = CH2.currentCharacter;
			var rank:Number = character.currentCatalogRank;
			if (character.highestWorldCompleted < 1 && rank < firstRunHardcodedCatalogs.length)
			{
				catalogItemsForSale = [];
				character.catalogItemsForSale = firstRunHardcodedCatalogs[rank];
				CH2UI.instance.refreshCatalogDisplay();
			}
			else
			{
				character.generateCatalogDefault();
			}
		}
		
		public function populateRubyPurchaseOptionsOverride():void
		{
			var character:Character = CH2.currentCharacter;
			character.populateRubyPurchaseOptionsDefault();
			
			var automatorPointPurchase:RubyPurchase = new RubyPurchase();
			automatorPointPurchase.priority = 1;
			automatorPointPurchase.name = "Automator Point";
			automatorPointPurchase.price = 100;
			automatorPointPurchase.iconId = 4;
			automatorPointPurchase.getDescription = character.getAutomatorPointDescription;
			automatorPointPurchase.getSoldOutText = character.getDefaultSoldOutText;
			automatorPointPurchase.onPurchase = character.onAutomatorPointPurchase;
			automatorPointPurchase.canAppear = character.canAutomatorPointAppear;
			automatorPointPurchase.canPurchase = character.canPurchaseAutomatorPoint;
			character.rubyPurchaseOptions.push(automatorPointPurchase);
			
		}
	}
}
