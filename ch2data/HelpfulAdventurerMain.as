 package
{
	import com.doogog.utils.MiscUtils;
	import com.playsaurus.managers.BigNumberFormatter;
	import com.playsaurus.numbers.BigNumber;
	import com.playsaurus.utils.StringFormatter;
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
	import it.sephiroth.gettext._;

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
		public static const ENERGY_CHARGE:String = CHARACTER_ASSET_GROUP + "_energyCharge";
		
		// World Trait IDs
		
		public static const WT_ROBUST:int = 0;
		public static const WT_EXHAUSTING:int = 1;
		public static const WT_BANAL:int = 2;
		public static const WT_GARGANTUAN:int = 3;
		public static const WT_UNDERFED:int = 4;
		public static const WT_UNSTABLE:int = 5;
		public static const WT_INCOME_TAX:int = 6;
		public static const WT_SPEED_LIMIT:int = 7;
		
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
		public static const CLICKSTORM_TOOLTIP:String = "Consumes 2.5 energy per second to click 5 times per second, until you run out of energy. Speed increases over time.";
		public static const CRITSTORM_TOOLTIP:String = "Consumes 2.5 energy per second to click 5 times per second, until you run out of energy. Clicks from this skill have double chance of being critical strikes. Speed increases over time.";
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
			
			helpfulAdventurer.worldTraits[WT_ROBUST] = {
				"name": "Robust",
				"description": "Critical hit chance reduced by 100%."
			};
			helpfulAdventurer.worldTraits[WT_EXHAUSTING] = {
				"name": "Exhausting",
				"description": "Attacking temporarily reduces your haste."
			};
			helpfulAdventurer.worldTraits[WT_BANAL] = {
				"name": "Banal",
				"description": "Mana regenerates at 10% the normal rate."
			};
			helpfulAdventurer.worldTraits[WT_GARGANTUAN] = {
				"name": "Gargantuan",
				"description": "Five heckin' chonkers per zone."
			};
			helpfulAdventurer.worldTraits[WT_UNDERFED] = {
				"name": "Underfed",
				"description": "Lots of itty bitties."
			};
			helpfulAdventurer.worldTraits[WT_UNSTABLE] = {
				"name": "Unstable",
				"description": "All energy is lost upon reaching maximum energy."
			};
			helpfulAdventurer.worldTraits[WT_INCOME_TAX] = {
				"name": "Income Tax",
				"description": "An aggressive tax structure that scales with multipliers to monster gold."
			};
			helpfulAdventurer.worldTraits[WT_SPEED_LIMIT] = {
				"name": "Speed Limit",
				"description": "Fines will be issued for dashing."
			};
			
			helpfulAdventurer.hardcodedWorldTraits = {
				//"2": {
					//"traitIDs": [WT_UNDERFED]
				//},
				//"3": {
					//"traitIDs": [WT_UNSTABLE]
				//},
				"31": {
					"traitIDs": [WT_ROBUST]
				},
				"61": {
					"traitIDs": [WT_EXHAUSTING]
				},
				"91": {
					"traitIDs": [WT_GARGANTUAN]
				}
			};
			
			helpfulAdventurer.etherealTraitTooltipInfo = {
				"ExtraMulticlicks": {
					"tooltipFormat": "+%s clicks to your MultiClick",
					"valueFunction": function(levels:Number):Number {
						return 2 * levels;
					}
				},
				"BigClickStacks": {
					"tooltipFormat": "+%s clicks empowered by Big Clicks",
					"valueFunction": function(levels:Number):Number {
						return levels;
					}
				},
				"BigClicksDamage": {
					"tooltipFormat": "x%s% damage done by Big Clicks",
					"valueFunction": function(levels:Number):Number {
						return Math.pow(1.25, levels);
					}
				},
				"HugeClickDamage": {
					"tooltipFormat": "x%s% damage done by Huge Click",
					"valueFunction": function(levels:Number):Number {
						return Math.pow(1.25, levels);
					}
				},
				"ManaCritDamage": {
					"tooltipFormat": "x%s% damage of Mana Crit",
					"valueFunction": function(levels:Number):Number {
						return Math.pow(1.25, levels);
					}
				},
				"ImprovedEnergize": {
					"tooltipFormat": "+%s% duration of Energize",
					"valueFunction": function(levels:Number):Number {
						return 0.2 * levels;
					}
				},
				"SustainedPowersurge": {
					"tooltipFormat": "x%s% duration of Powersurge",
					"valueFunction": function(levels:Number):Number {
						return Math.pow(1.2, levels);
					}
				},
				"ImprovedPowersurge": {
					"tooltipFormat": "x%s% damage bonus of Powersurge",
					"valueFunction": function(levels:Number):Number {
						return Math.pow(1.25, levels);
					}
				},
				"ImprovedReload": {
					"tooltipFormat": "+%s% Reload effect",
					"valueFunction": function(levels:Number):Number {
						return 0.5 * levels * 100;
					}
				}
			}
			
			helpfulAdventurer.levelGraphNodeTypes = {
				"G": { 
					"name": "Gold",
					"tooltip": "1 Level of Gold Received. Multiplies your gold received from all sources by 110%.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_GOLD, 1),
					"flavorText": "We can also say that it is multiplied by 1.1, but that sounds so much weaker.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD)},
					"icon": "goldx3"
				},
				"Cc": { 
					"name": "Crit Chance",
					"tooltip": "1 Level of Critical Chance. Adds 2% to your chance to score a critical hit.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_CRIT_CHANCE, 1),
					"flavorText": "Ever wonder what happens when you get over 100% Crit Chance? The Ancients once knew, but that is ancient history.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_CHANCE)},
					"icon": "critChance"
				},
				"Cd": { 
					"name": "Crit Damage",
					"tooltip": "1 Level of Critical Damage. Multiplies the damage of your critical hits by 120%.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_CRIT_DAMAGE, 1),
					"flavorText": "When a number is multiplied by a fixed amount (greater than 1) many times, that number is said to grow \"exponentially\". This is because that process is usually represented by a formula that uses exponential notation.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_DAMAGE)},
					"icon": "critDamage"
				},			
				"H": { 
					"name": "Haste",
					"tooltip": "1 Level of Haste. Multiplies your Haste by 105%.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_HASTE, 1),
					"flavorText": "Haste affects the rate that you auto-attack, and all cooldown speeds, including Automator cooldown speeds.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_HASTE)},
					"icon": "haste"
				},
				"Gc": { 
					"name": "Clickable Gold",
					"tooltip": "1 Level of Clickable Gold. Multiplies your gold received from clickables by 150%." ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_CLICKABLE_GOLD, 1),
					"flavorText": "If only someone could click on them before they go off the screen.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_GOLD)},
					"icon": "clickableGold"
				},
				"Cl": { 
					"name": "Click Damage",
					"tooltip": "1 Level of Click Damage. Multiplies your click damage by 110%." ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_CLICK_DAMAGE, 1),
					"flavorText": "This affects damage from all skills that \"click\". But it does not affect auto-attacks, because those are not \"clicks\".",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICK_DAMAGE)},
					"icon": "clickDamage"
				},
				"Gb": { 
					"name": "Monster Gold",
					"tooltip": "1 Level of Monster Gold. Multiplies gold received by monsters by 120%." ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_MONSTER_GOLD, 1),
					"flavorText": "", //AO: Need new flavor text
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_MONSTER_GOLD)},
					"icon": "bossGold"
				},
				"Ir": { 
					"name": "Item Cost Reduction",
					"tooltip": "1 Level of Item Cost Reduction. Multiplies the gold costs of buying and leveling equipment by 0.92." ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_ITEM_COST_REDUCTION, 1),
					"flavorText": "Rufus sometimes wonders why he can't compete in the Gold market. He always felt like there was a mysterious seller undercutting him.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_COST_REDUCTION)},
					"icon": "itemCostReduction"
				},
				"Mt": { 
					"name": "Total Mana",
					"tooltip": "1 Level of Total Mana. Increases your maximum mana by 25." ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_TOTAL_MANA, 1),
					"flavorText": "If a fixed amount is added to a number many times, that number is said to grow \"linearly\". This is because if you plot it out on an x/y graph, you'll see a line.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_MANA)},
					"icon": "totalMana"
				},
				"Mr": { 
					"name": "Mana Regeneration",
					"tooltip": "1 Level of Mana Regeneration. Multiplies your mana regeneration rate by 110%." ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_MANA_REGEN, 1),
					"flavorText": "You will get 10% more mana per minute than before you had this upgrade.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_MANA_REGEN)},
					"icon": "manaRegen"
				},
				"En": { 
					"name": "Total Energy",
					"tooltip": "1 Level of Total Energy. Increases your maximum energy by 25." ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_TOTAL_ENERGY, 1),
					"flavorText": "If a fixed amount is added to a number many times, that number is said to grow \"linearly\". This is because if you plot it out on an x/y graph, you'll see a line.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_ENERGY)},
					"icon": "totalEnergy"
				},
				"Gp": { 
					"name": "Gold Piles",
					"tooltip": "1 Level of Gold Piles. Multiplies the number of gold piles found by 110%." ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_CLICKABLE_CHANCE, 1),
					"flavorText": "This only affects piles of gold. Not other clickables." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_CHANCE)},
					"icon": "goldPiles"
				},
				"Bg": { 
					"name": "Bonus Gold Chance",
					"tooltip": "1 Level of Bonus Gold Chance. Adds 1% to your chance of finding bonus gold." ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_BONUS_GOLD_CHANCE, 1),
					"flavorText": "When killing monsters, bonus gold may appear. This is a linear bonus, like Crit Chance." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_BONUS_GOLD_CHANCE)},
					"icon": "goldChance"
				},
				"Tc": { 
					"name": "Treasure Chest Chance",
					"tooltip": "1 Level of Treasure Chest Chance. Adds 2% to the chance that a monster happens to be a treasure chest." ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_TREASURE_CHEST_CHANCE, 1),
					"flavorText": "Making good use of the lingering powers of a once-loathed ancient known as Thusia.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_CHANCE)},
					"icon": "treasureChance"
				},
				"Tg": { 
					"name": "Treasure Chest Gold",
					"tooltip": "1 Level of Treasure Chest Gold. Multiplies the gold received from treasure chest monsters by 125%." ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_TREASURE_CHEST_GOLD, 1),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_GOLD)},
					"icon": "treasureGold"
				},
				"I1": { 
					"name": "Equipment: Weapon",
					"tooltip": "1 Level of Weapon Damage. Multiplies the damage you deal with weapons by 150%" ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_ITEM_WEAPON_DAMAGE, 1),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_WEAPON_DAMAGE)},
					"icon": "damageWeapon"
				},
				"I2": { 
					"name": "Equipment: Helmet",
					"tooltip": "1 Level of Helmet Damage. Multiplies the damage you deal with helmets by 150%" ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_ITEM_HEAD_DAMAGE, 1),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_HEAD_DAMAGE)},
					"icon": "damageHead"
				},
				"I3": { 
					"name": "Equipment: Breastplate",
					"tooltip": "1 Level of Breastplate Damage. Multiplies the damage you deal with breastplates by 150%" ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_ITEM_CHEST_DAMAGE, 1),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_CHEST_DAMAGE)},
					"icon": "damageTop"
				},
				"I4": { 
					"name": "Equipment: Ring",
					"tooltip": "1 Level of Ring Damage. Multiplies the damage you deal with rings by 150%" ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_ITEM_RING_DAMAGE, 1),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_RING_DAMAGE)},
					"icon": "damageAccesory"
				},
				"I5": { 
					"name": "Equipment: Pants",
					"tooltip": "1 Level of Pants Damage. Multiplies the damage you deal with pants by 150%" ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_ITEM_LEGS_DAMAGE, 1),
					"flavorText": "Pants shouldn't do damage, that's ridiculous.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_LEGS_DAMAGE)},
					"icon": "damageLegs"
				},
				"I6": { 
					"name": "Equipment: Gloves",
					"tooltip": "1 Level of Gloves Damage. Multiplies the damage you deal with gloves by 150%" ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_ITEM_HANDS_DAMAGE, 1),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_HANDS_DAMAGE)},
					"icon": "damageHands"
				},
				"I7": { 
					"name": "Equipment: Boots",
					"tooltip": "1 Level of Boots Damage. Multiplies the damage you deal with boots by 150%" ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_ITEM_FEET_DAMAGE, 1),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_FEET_DAMAGE)},
					"icon": "damageFeet"
				},
				"I8": { 
					"name": "Equipment: Cape",
					"tooltip": "1 Level of Cape Damage. Multiplies the damage you deal with capes by 150%" ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_ITEM_BACK_DAMAGE, 1),
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
					"tooltip": "1 Level of Increased MultiClicks. Adds 2 clicks to your MultiClick.",
					"tooltipFunction": getAddTraitTooltipFunction("ExtraMulticlicks", 1),
					"flavorText": "No matter how many of these upgrades you get, MultiClick will take the same amount of time to perform all of its clicks.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("ExtraMulticlicks", 1, true); CH2.currentCharacter.addTrait("TreeExtraMulticlicks", 1); },
					"icon": "nineClicks"
				},
				"Bc": { 
					"name": "More Big Clicks",
					"tooltip": "1 Level of More Big Clicks. Increases the number of clicks empowered by Big Clicks by 1.",
					"tooltipFunction": getAddTraitTooltipFunction("BigClickStacks", 1),
					"flavorText": "They march loyally behind you in unison, each one prepared to sacrifice itself for your cause.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("BigClickStacks", 1, true); CH2.currentCharacter.addTrait("TreeBigClickStacks", 1); },
					"icon": "iconBigClicks"
				},
				"Bd": { 
					"name": "Bigger Big Clicks",
					"tooltip": "1 Level of Bigger Big Clicks. Multiplies the damage done by Big Clicks by 125%",
					"tooltipFunction": getAddTraitTooltipFunction("BigClicksDamage", 1),
					"flavorText": "They might not look any bigger when you get this upgrade. They're bigger on the inside. In fact, they weigh a lot more.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("BigClicksDamage", 1, true); CH2.currentCharacter.addTrait("TreeBigClicksDamage", 1); },
					"icon": "iconBigClicks"
				},
				"Hd": { 
					"name": "Huger Huge Click",
					"tooltip": "1 Level of Huger Huge Clicks. Multiplies the damage done by Huge Click by 125%",
					"tooltipFunction": getAddTraitTooltipFunction("HugeClickDamage", 1),
					"flavorText": "It actually gets bigger. But there is an unusual visual side effect that the rest of the world increases in size proportionally.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("HugeClickDamage", 1, true); CH2.currentCharacter.addTrait("TreeHugeClickDamage", 1); },
					"icon": "hugeClicks"
				},
				"Md": { 
					"name": "Mana Crit Damage",
					"tooltip": "1 Level of Mana Crit Damage. Multiplies the damage of Mana Crit by 125%",
					"tooltipFunction": getAddTraitTooltipFunction("ManaCritDamage", 1),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("ManaCritDamage", 1, true); CH2.currentCharacter.addTrait("TreeManaCritDamage", 1); },
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
					"tooltip": "1 Level of Improved Energize. Increases the duration of Energize by 20% of its original duration.",
					"tooltipFunction": getAddTraitTooltipFunction("ImprovedEnergize", 1),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("ImprovedEnergize", 1, true); CH2.currentCharacter.addTrait("TreeImprovedEnergize", 1); },
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
					"tooltip": "1 Level of Sustained Powersurge. Multiplies the duration of Powersurge by 120%.",
					"tooltipFunction": getAddTraitTooltipFunction("SustainedPowersurge", 1),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("SustainedPowersurge", 1, true); CH2.currentCharacter.addTrait("TreeSustainedPowersurge", 1); },
					"icon": "powersurgeDuration"
				},
				"Pa": { 
					"name": "Improved Powersurge",
					"tooltip": "1 Level of Improved Powersurge. Multiplies the damage bonus of Powersurge by 125%.",
					"tooltipFunction": getAddTraitTooltipFunction("ImprovedPowersurge", 1),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("ImprovedPowersurge", 1, true); CH2.currentCharacter.addTrait("TreeImprovedPowersurge", 1); },
					"icon": "powersurgeDamage"
				},
				"Ra": { 
					"name": "Improved Reload",
					"tooltip": "1 Level of Improved Reload. Increases the effect of Reload by 50% of its base effect." ,
					"tooltipFunction": getAddTraitTooltipFunction("ImprovedReload", 1),
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("ImprovedReload", 1, true);  CH2.currentCharacter.addTrait("TreeImprovedReload", 1); },
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
					"tooltip": "Clicks with +100% chance to score a critical hit." ,
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
					"tooltip": "3 Levels of Gold Received. Multiplies your gold received from all sources by 133%.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_GOLD, 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD, 3)},
					"icon": "goldx3"
				},
				"qCd": {
					"name": "Precision of Bhaal",
					"tooltip": "3 Levels of Critical Damage. Multiplies the damage of your critical hits by 172.8%.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_CRIT_DAMAGE, 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_DAMAGE, 3)},
					"icon": "critDamage"
				},
				"qH": {
					"name": "Vaagur's Impatience",
					"tooltip": "3 Levels of Haste. Multiplies your Haste by 115.7%." ,
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_HASTE, 3),
					"flavorText": "Haste affects the rate that you auto-attack, and all cooldown speeds, including Automator cooldown speeds.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_HASTE, 3)},
					"icon": "haste"
				},
				"qGc": {
					"name": "Revolc's Blessing",
					"tooltip": "3 Levels of Clickable Gold. Multiplies your gold received from clickables by 337.5%.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_CLICKABLE_GOLD, 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_GOLD, 3)},
					"icon": "clickableGold"
				},
				"qCl": {
					"name": "The Wrath of Fragsworth",
					"tooltip": "3 Levels of Click Damage. Multiplies your click damage by 133%.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_CLICK_DAMAGE, 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICK_DAMAGE, 3)},
					"icon": "clickDamage"
				},
				"qGb": {
					"name": "Mimzee's Kindness",
					"tooltip": "3 Levels of Monster Gold. Multiplies gold received by monsters by 172.8%.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_MONSTER_GOLD, 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_MONSTER_GOLD, 3)},
					"icon": "bossGold"
				},
				"qIr": {
					"name": "The Thrift of Dogcog",
					"tooltip": "3 Levels of Item Cost Reduction. Reduces the cost of buying and leveling items by 22%.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_ITEM_COST_REDUCTION, 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_COST_REDUCTION, 3)},
					"icon": "itemCostReduction"
				},
				"qMt": {
					"name": "Energon's Ions",
					"tooltip": "4 Levels of Total Mana. Increases your maximum Mana by 100.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_TOTAL_MANA, 4),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_MANA, 4)},
					"icon": "totalMana"
				},
				"qMr": {
					"name": "Energon's Grace",
					"tooltip": "3 Levels of Mana Regeneration. Multiplies your mana regeneration by 133%.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_MANA_REGEN, 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_MANA_REGEN, 3)},
					"icon": "manaRegen"
				},
				"qEn": {
					"name": "Juggernaut's Pittance",
					"tooltip": "4 Levels of Total Energy. Increases your maximum Energy by 100.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_TOTAL_ENERGY, 4),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_ENERGY, 4)},
					"icon": "totalEnergy"
				},
				"qGp": {
					"name": "The Vision of Iris",
					"tooltip": "3 Levels of Gold Piles. Multiplies the number of gold piles found by 130%.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_CLICKABLE_CHANCE, 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_CHANCE, 3)},
					"icon": "goldPiles"
				},
				"qBg": {
					"name": "Fortuna's Luck",
					"tooltip": "3 Levels of Bonus Gold Chance. Adds 3% to your chance of finding bonus gold.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_BONUS_GOLD_CHANCE, 3),
					"flavorText": "When killing monsters, bonus gold may appear. This is a linear bonus, like Crit Chance." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_BONUS_GOLD_CHANCE, 3)},
					"icon": "goldChance"
				},
				"qTc": {
					"name": "Mimzee's Favor",
					"tooltip": "3 Levels of Treasure Chest Chance. Adds 6% to the chance that a monster happens to be a treasure chest.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_TREASURE_CHEST_CHANCE, 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_CHANCE, 3)},
					"icon": "treasureChance"
				},
				"qTg": {
					"name": "Mimzee's Blessing",
					"tooltip": "3 Levels of Treasure Chest Gold. Multiplies your gold received from treasure chests by 195%.",
					"tooltipFunction": getAddStatTooltipFunction(CH2.STAT_TREASURE_CHEST_GOLD, 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_GOLD, 3)},
					"icon": "treasureGold"
				},
				"qMu": {
					"name": "Mega Increased MultiClicks",
					"tooltip": "3 Levels of Increased MultiClicks. Adds 6 clicks to your MultiClick.",
					"tooltipFunction": getAddTraitTooltipFunction("ExtraMulticlicks", 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("ExtraMulticlicks", 3, true);  CH2.currentCharacter.addTrait("TreeExtraMulticlicks", 3); },
					"icon": "nineClicks"
				},
				"qBc": { 
					"name": "Mega More Big Clicks",
					"tooltip": "3 Levels of More Big Clicks. Increases the number of clicks empowered by Big Clicks by 3.",
					"tooltipFunction": getAddTraitTooltipFunction("BigClickStacks", 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("BigClickStacks", 3, true); CH2.currentCharacter.addTrait("TreeBigClickStacks", 3); },
					"icon": "iconBigClicks"
				},
				"qBd": { 
					"name": "Mega Bigger Big Clicks",
					"tooltip": "3 Levels of Bigger Big Clicks. Multiplies the damage done by Big Clicks by 195%",
					"tooltipFunction": getAddTraitTooltipFunction("BigClicksDamage", 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("BigClicksDamage", 3, true); CH2.currentCharacter.addTrait("TreeBigClicksDamage", 3); },
					"icon": "iconBigClicks"
				},
				"qHd": { 
					"name": "Mega Huger Huge Click",
					"tooltip": "3 Levels of Huger Huge Click. Multiplies the damage of Huge Click by 195%",
					"tooltipFunction": getAddTraitTooltipFunction("HugeClickDamage", 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("HugeClickDamage", 3, true); CH2.currentCharacter.addTrait("TreeHugeClickDamage", 3); },
					"icon": "hugeClicks"
				},
				"qMd": { 
					"name": "Mega Mana Crit Damage",
					"tooltip": "3 Levels of Mana Crit Damage. Multiplies the damage done by Mana Crits by 195%",
					"tooltipFunction": getAddTraitTooltipFunction("ManaCritDamage", 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("ManaCritDamage", 3, true); CH2.currentCharacter.addTrait("TreeManaCritDamage", 3); },
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
					"tooltip": "Energize becomes Managize, which restores 25% of your mana at the cost of 120 energy over 15 seconds." ,
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
					"tooltip": "PowerSurge gradually increases Crit Chance while active, reaching +60% at the end of its duration.",
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
					"name": "Automator Points",
					"tooltip": "Adds 2 Automator Points.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function() { CH2.currentCharacter.automatorPoints = CH2.currentCharacter.automatorPoints + 2;  },
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
				"S18": {
                    "name": "Stone: First World Of Gild",
                    "tooltip": "A stone that can activate when you are on the first world of a gild." ,
                    "flavorText": null,
                    "costsAutomatorPoint": true,
                    "setupFunction": function() { addFirstWorldOfGildStone(); },
                    "purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_29"); },
                    "icon": ""
                },
                "S19": {
                    "name": "Stone: Not First World Of Gild",
                    "tooltip": "A stone that can activate when you are not on the first world of a gild." ,
                    "flavorText": null,
                    "costsAutomatorPoint": true,
                    "setupFunction": function() { addNotFirstWorldOfGildStone(); },
                    "purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_30"); },
                    "icon": ""
                },
				"S26": {
                    "name": "Stone: Next monster more than 90 cm away",
                    "tooltip": "A stone that can activate when the next monster is more than 90 cm away." ,
                    "flavorText": null,
                    "costsAutomatorPoint": true,
                    "setupFunction": function() { addGreaterThanMonsterDistanceStone(); },
                    "purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_31"); },
                    "icon": ""
                },
				"S27": {
                    "name": "Stone: Not a Boss Zone",
                    "tooltip": "A stone that can activate when you are not on a boss zone." ,
                    "flavorText": null,
                    "costsAutomatorPoint": true,
                    "setupFunction": function() { addNotABossZoneStone(); },
                    "purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_32"); },
                    "icon": "gemAttemptBoss"
                },
				"S28": {
                    "name": "Stone: Next monster less than 90 cm away",
                    "tooltip": "A stone that can activate when the next monster is less than 90 cm away." ,
                    "flavorText": null,
                    "costsAutomatorPoint": true,
                    "setupFunction": function() { addLessThanMonsterDistanceStone(); },
                    "purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_33"); },
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
				},
				"S84": { 
					"name": "Stone: Preload is not active",
					"tooltip": "A stone that can activate when Preload is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("PreloadEQ0", "Preload = 0", "A stone that can activate when Preload is not active.", "Preload", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone("PreloadEQ0"); },
					"icon": "gemReload"
				}
			}
			
			helpfulAdventurer.levelGraphObject = {"edges":[{"1":[641, 642]}, {"2":[812, 837]}, {"3":[799, 828]}, {"4":[526, 597]}, {"5":[308, 371]}, {"6":[778, 791]}, {"7":[293, 418]}, {"8":[341, 406]}, {"9":[292, 400]}, {"10":[517, 563]}, {"11":[151, 265]}, {"12":[6, 14]}, {"13":[630, 655]}, {"14":[71, 96]}, {"15":[660, 661]}, {"16":[343, 368]}, {"17":[636, 637]}, {"18":[649, 650]}, {"19":[185, 241]}, {"20":[313, 390]}, {"21":[375, 376]}, {"22":[783, 805]}, {"23":[576, 608]}, {"24":[484, 580]}, {"25":[211, 212]}, {"26":[561, 566]}, {"27":[57, 59]}, {"28":[138, 212]}, {"29":[780, 802]}, {"30":[358, 361]}, {"31":[519, 553]}, {"32":[329, 437]}, {"33":[311, 359]}, {"34":[775, 797]}, {"35":[231, 233]}, {"36":[92, 442]}, {"37":[548, 557]}, {"38":[63, 170]}, {"39":[588, 612]}, {"40":[530, 596]}, {"41":[486, 505]}, {"42":[572, 588]}, {"43":[194, 201]}, {"44":[475, 546]}, {"45":[302, 433]}, {"46":[601, 620]}, {"47":[203, 206]}, {"48":[638, 639]}, {"49":[81, 108]}, {"50":[325, 363]}, {"51":[573, 608]}, {"52":[563, 564]}, {"53":[395, 405]}, {"54":[811, 818]}, {"55":[53, 372]}, {"56":[456, 631]}, {"57":[286, 647]}, {"58":[798, 825]}, {"59":[222, 256]}, {"60":[327, 437]}, {"61":[834, 835]}, {"62":[849, 850]}, {"63":[222, 223]}, {"64":[219, 220]}, {"65":[532, 568]}, {"66":[576, 577]}, {"67":[71, 656]}, {"68":[780, 789]}, {"69":[783, 856]}, {"70":[393, 403]}, {"71":[850, 854]}, {"72":[253, 257]}, {"73":[803, 818]}, {"74":[134, 253]}, {"75":[150, 225]}, {"76":[287, 444]}, {"77":[365, 373]}, {"78":[384, 385]}, {"79":[323, 398]}, {"80":[11, 12]}, {"81":[285, 460]}, {"82":[135, 247]}, {"83":[512, 513]}, {"84":[799, 823]}, {"85":[325, 438]}, {"86":[314, 339]}, {"87":[820, 843]}, {"88":[611, 615]}, {"89":[590, 595]}, {"90":[260, 261]}, {"91":[284, 285]}, {"92":[507, 510]}, {"93":[473, 562]}, {"94":[43, 118]}, {"95":[68, 662]}, {"96":[189, 193]}, {"97":[354, 427]}, {"98":[483, 525]}, {"99":[396, 412]}, {"100":[32, 34]}, {"101":[590, 594]}, {"102":[327, 328]}, {"103":[612, 613]}, {"104":[75, 459]}, {"105":[157, 220]}, {"106":[536, 538]}, {"107":[319, 423]}, {"108":[46, 47]}, {"109":[793, 827]}, {"110":[16, 25]}, {"111":[640, 648]}, {"112":[644, 645]}, {"113":[142, 168]}, {"114":[23, 38]}, {"115":[518, 552]}, {"116":[555, 565]}, {"117":[816, 836]}, {"118":[159, 204]}, {"119":[835, 842]}, {"120":[474, 594]}, {"121":[123, 643]}, {"122":[21, 36]}, {"123":[577, 667]}, {"124":[593, 617]}, {"125":[54, 55]}, {"126":[139, 242]}, {"127":[91, 121]}, {"128":[41, 129]}, {"129":[596, 616]}, {"130":[323, 370]}, {"131":[284, 287]}, {"132":[564, 565]}, {"133":[507, 508]}, {"134":[304, 328]}, {"135":[108, 450]}, {"136":[476, 597]}, {"137":[115, 117]}, {"138":[135, 279]}, {"139":[796, 815]}, {"140":[154, 215]}, {"141":[106, 468]}, {"142":[133, 196]}, {"143":[350, 353]}, {"144":[497, 604]}, {"145":[830, 831]}, {"146":[557, 558]}, {"147":[450, 644]}, {"148":[177, 178]}, {"149":[337, 419]}, {"150":[393, 419]}, {"151":[288, 624]}, {"152":[784, 798]}, {"153":[78, 87]}, {"154":[487, 529]}, {"155":[249, 252]}, {"156":[132, 167]}, {"157":[779, 822]}, {"158":[355, 432]}, {"159":[294, 394]}, {"160":[318, 429]}, {"161":[502, 503]}, {"162":[304, 316]}, {"163":[84, 128]}, {"164":[100, 448]}, {"165":[61, 62]}, {"166":[549, 550]}, {"167":[315, 331]}, {"168":[116, 118]}, {"169":[794, 844]}, {"170":[624, 625]}, {"171":[337, 422]}, {"172":[650, 657]}, {"173":[5, 8]}, {"174":[200, 227]}, {"175":[219, 221]}, {"176":[510, 512]}, {"177":[514, 552]}, {"178":[80, 462]}, {"179":[346, 347]}, {"180":[311, 365]}, {"181":[76, 101]}, {"182":[343, 390]}, {"183":[208, 209]}, {"184":[801, 811]}, {"185":[209, 210]}, {"186":[199, 201]}, {"187":[126, 128]}, {"188":[467, 658]}, {"189":[471, 519]}, {"190":[292, 347]}, {"191":[7, 33]}, {"192":[223, 224]}, {"193":[534, 586]}, {"194":[358, 388]}, {"195":[161, 229]}, {"196":[88, 630]}, {"197":[819, 833]}, {"198":[402, 429]}, {"199":[477, 583]}, {"200":[467, 623]}, {"201":[200, 205]}, {"202":[310, 435]}, {"203":[591, 612]}, {"204":[8, 15]}, {"205":[79, 124]}, {"206":[290, 451]}, {"207":[112, 445]}, {"208":[446, 649]}, {"209":[77, 541]}, {"210":[401, 402]}, {"211":[171, 172]}, {"212":[582, 583]}, {"213":[48, 49]}, {"214":[75, 114]}, {"215":[29, 814]}, {"216":[511, 539]}, {"217":[394, 395]}, {"218":[498, 593]}, {"219":[59, 668]}, {"220":[119, 122]}, {"221":[51, 194]}, {"222":[132, 166]}, {"223":[164, 264]}, {"224":[26, 46]}, {"225":[404, 439]}, {"226":[341, 405]}, {"227":[303, 439]}, {"228":[321, 371]}, {"229":[490, 509]}, {"230":[498, 615]}, {"231":[854, 859]}, {"232":[128, 470]}, {"233":[792, 857]}, {"234":[215, 221]}, {"235":[377, 416]}, {"236":[1, 2]}, {"237":[70, 621]}, {"238":[110, 112]}, {"239":[142, 171]}, {"240":[72, 82]}, {"241":[2, 3]}, {"242":[670, 673]}, {"243":[231, 232]}, {"244":[222, 280]}, {"245":[403, 417]}, {"246":[503, 504]}, {"247":[372, 409]}, {"248":[240, 243]}, {"249":[69, 70]}, {"250":[6, 13]}, {"251":[520, 523]}, {"252":[117, 118]}, {"253":[454, 651]}, {"254":[387, 388]}, {"255":[162, 163]}, {"256":[336, 440]}, {"257":[800, 810]}, {"258":[312, 374]}, {"259":[76, 114]}, {"260":[380, 386]}, {"261":[307, 364]}, {"262":[244, 245]}, {"263":[176, 177]}, {"264":[200, 207]}, {"265":[246, 247]}, {"266":[361, 421]}, {"267":[179, 269]}, {"268":[810, 817]}, {"269":[493, 556]}, {"270":[147, 226]}, {"271":[160, 169]}, {"272":[797, 833]}, {"273":[132, 197]}, {"274":[553, 554]}, {"275":[403, 409]}, {"276":[56, 667]}, {"277":[241, 242]}, {"278":[202, 280]}, {"279":[469, 639]}, {"280":[545, 589]}, {"281":[61, 457]}, {"282":[301, 425]}, {"283":[254, 255]}, {"284":[794, 819]}, {"285":[638, 640]}, {"286":[778, 822]}, {"287":[149, 222]}, {"288":[364, 415]}, {"289":[626, 646]}, {"290":[337, 428]}, {"291":[72, 88]}, {"292":[101, 441]}, {"293":[17, 22]}, {"294":[559, 568]}, {"295":[61, 89]}, {"296":[805, 843]}, {"297":[671, 672]}, {"298":[97, 628]}, {"299":[776, 785]}, {"300":[528, 529]}, {"301":[527, 535]}, {"302":[156, 217]}, {"303":[111, 451]}, {"304":[57, 458]}, {"305":[215, 273]}, {"306":[389, 391]}, {"307":[789, 821]}, {"308":[213, 217]}, {"309":[422, 424]}, {"310":[342, 430]}, {"311":[45, 606]}, {"312":[65, 67]}, {"313":[788, 829]}, {"314":[490, 554]}, {"315":[9, 39]}, {"316":[561, 602]}, {"317":[519, 563]}, {"318":[630, 631]}, {"319":[468, 637]}, {"320":[172, 174]}, {"321":[508, 536]}, {"322":[474, 551]}, {"323":[218, 272]}, {"324":[300, 352]}, {"325":[307, 392]}, {"326":[838, 839]}, {"327":[348, 349]}, {"328":[395, 417]}, {"329":[321, 436]}, {"330":[113, 121]}, {"331":[489, 539]}, {"332":[516, 614]}, {"333":[561, 562]}, {"334":[332, 336]}, {"335":[32, 38]}, {"336":[815, 857]}, {"337":[34, 35]}, {"338":[336, 663]}, {"339":[834, 836]}, {"340":[27, 32]}, {"341":[100, 109]}, {"342":[237, 270]}, {"343":[309, 407]}, {"344":[139, 244]}, {"345":[95, 97]}, {"346":[102, 107]}, {"347":[312, 387]}, {"348":[339, 368]}, {"349":[830, 832]}, {"350":[80, 659]}, {"351":[100, 125]}, {"352":[634, 636]}, {"353":[117, 466]}, {"354":[207, 208]}, {"355":[27, 29]}, {"356":[531, 533]}, {"357":[81, 659]}, {"358":[283, 635]}, {"359":[378, 381]}, {"360":[56, 668]}, {"361":[96, 655]}, {"362":[495, 574]}, {"363":[16, 21]}, {"364":[239, 273]}, {"365":[114, 674]}, {"366":[12, 30]}, {"367":[592, 605]}, {"368":[218, 219]}, {"369":[297, 324]}, {"370":[580, 582]}, {"371":[239, 263]}, {"372":[138, 214]}, {"373":[488, 536]}, {"374":[344, 391]}, {"375":[567, 612]}, {"376":[345, 411]}, {"377":[366, 411]}, {"378":[145, 231]}, {"379":[574, 575]}, {"380":[356, 360]}, {"381":[231, 672]}, {"382":[140, 275]}, {"383":[365, 382]}, {"384":[517, 528]}, {"385":[175, 202]}, {"386":[579, 580]}, {"387":[357, 399]}, {"388":[17, 839]}, {"389":[322, 353]}, {"390":[775, 777]}, {"391":[103, 636]}, {"392":[389, 420]}, {"393":[477, 584]}, {"394":[463, 625]}, {"395":[566, 567]}, {"396":[799, 808]}, {"397":[127, 379]}, {"398":[552, 557]}, {"399":[120, 447]}, {"400":[445, 635]}, {"401":[43, 44]}, {"402":[630, 648]}, {"403":[330, 383]}, {"404":[85, 227]}, {"405":[158, 179]}, {"406":[546, 549]}, {"407":[53, 340]}, {"408":[35, 36]}, {"409":[186, 279]}, {"410":[338, 397]}, {"411":[23, 31]}, {"412":[168, 187]}, {"413":[142, 170]}, {"414":[41, 77]}, {"415":[78, 654]}, {"416":[141, 174]}, {"417":[64, 65]}, {"418":[243, 245]}, {"419":[79, 80]}, {"420":[64, 113]}, {"421":[95, 98]}, {"422":[324, 661]}, {"423":[448, 640]}, {"424":[318, 323]}, {"425":[137, 177]}, {"426":[332, 410]}, {"427":[226, 237]}, {"428":[540, 610]}, {"429":[87, 88]}, {"430":[92, 93]}, {"431":[290, 627]}, {"432":[273, 278]}, {"433":[665, 666]}, {"434":[183, 209]}, {"435":[335, 351]}, {"436":[814, 816]}, {"437":[802, 817]}, {"438":[499, 603]}, {"439":[506, 510]}, {"440":[813, 820]}, {"441":[790, 845]}, {"442":[577, 578]}, {"443":[252, 257]}, {"444":[87, 633]}, {"445":[513, 514]}, {"446":[106, 652]}, {"447":[596, 617]}, {"448":[107, 111]}, {"449":[546, 601]}, {"450":[226, 228]}, {"451":[234, 235]}, {"452":[352, 389]}, {"453":[94, 95]}, {"454":[532, 533]}, {"455":[72, 465]}, {"456":[449, 622]}, {"457":[24, 63]}, {"458":[102, 106]}, {"459":[359, 362]}, {"460":[7, 8]}, {"461":[790, 825]}, {"462":[191, 192]}, {"463":[621, 622]}, {"464":[126, 632]}, {"465":[360, 425]}, {"466":[524, 525]}, {"467":[494, 565]}, {"468":[187, 188]}, {"469":[241, 641]}, {"470":[497, 605]}, {"471":[155, 263]}, {"472":[160, 161]}, {"473":[198, 229]}, {"474":[234, 270]}, {"475":[295, 403]}, {"476":[190, 191]}, {"477":[603, 608]}, {"478":[486, 587]}, {"479":[538, 539]}, {"480":[349, 429]}, {"481":[227, 230]}, {"482":[787, 791]}, {"483":[455, 626]}, {"484":[513, 537]}, {"485":[471, 520]}, {"486":[235, 274]}, {"487":[264, 266]}, {"488":[798, 823]}, {"489":[515, 545]}, {"490":[156, 218]}, {"491":[286, 447]}, {"492":[335, 336]}, {"493":[377, 378]}, {"494":[505, 569]}, {"495":[328, 666]}, {"496":[549, 604]}, {"497":[20, 21]}, {"498":[786, 792]}, {"499":[131, 163]}, {"500":[570, 574]}, {"501":[207, 228]}, {"502":[511, 569]}, {"503":[291, 345]}, {"504":[590, 607]}, {"505":[400, 401]}, {"506":[781, 826]}, {"507":[551, 566]}, {"508":[627, 656]}, {"509":[824, 849]}, {"510":[83, 664]}, {"511":[353, 397]}, {"512":[592, 620]}, {"513":[591, 611]}, {"514":[161, 162]}, {"515":[204, 205]}, {"516":[275, 276]}, {"517":[69, 658]}, {"518":[310, 357]}, {"519":[267, 274]}, {"520":[58, 82]}, {"521":[464, 632]}, {"522":[388, 407]}, {"523":[500, 607]}, {"524":[146, 199]}, {"525":[392, 432]}, {"526":[501, 502]}, {"527":[386, 391]}, {"528":[618, 619]}, {"529":[251, 256]}, {"530":[317, 331]}, {"531":[232, 238]}, {"532":[320, 354]}, {"533":[66, 461]}, {"534":[57, 116]}, {"535":[308, 319]}, {"536":[42, 443]}, {"537":[181, 211]}, {"538":[795, 796]}, {"539":[165, 169]}, {"540":[54, 582]}, {"541":[399, 433]}, {"542":[414, 426]}, {"543":[236, 239]}, {"544":[804, 837]}, {"545":[62, 90]}, {"546":[83, 104]}, {"547":[609, 610]}, {"548":[129, 192]}, {"549":[781, 804]}, {"550":[537, 543]}, {"551":[782, 803]}, {"552":[115, 124]}, {"553":[250, 259]}, {"554":[60, 73]}, {"555":[522, 589]}, {"556":[317, 413]}, {"557":[342, 418]}, {"558":[385, 386]}, {"559":[109, 632]}, {"560":[78, 452]}, {"561":[492, 532]}, {"562":[602, 611]}, {"563":[356, 439]}, {"564":[51, 260]}, {"565":[282, 458]}, {"566":[406, 412]}, {"567":[153, 274]}, {"568":[550, 595]}, {"569":[373, 404]}, {"570":[479, 515]}, {"571":[501, 521]}, {"572":[821, 826]}, {"573":[776, 792]}, {"574":[339, 367]}, {"575":[39, 40]}, {"576":[517, 518]}, {"577":[188, 191]}, {"578":[195, 196]}, {"579":[498, 600]}, {"580":[152, 182]}, {"581":[306, 379]}, {"582":[60, 103]}, {"583":[413, 425]}, {"584":[76, 634]}, {"585":[492, 530]}, {"586":[831, 838]}, {"587":[151, 259]}, {"588":[268, 269]}, {"589":[570, 572]}, {"590":[442, 657]}, {"591":[669, 670]}, {"592":[572, 586]}, {"593":[91, 93]}, {"594":[806, 812]}, {"595":[105, 643]}, {"596":[4, 6]}, {"597":[96, 98]}, {"598":[214, 276]}, {"599":[73, 125]}, {"600":[542, 618]}, {"601":[556, 560]}, {"602":[52, 53]}, {"603":[488, 543]}, {"604":[329, 330]}, {"605":[282, 283]}, {"606":[64, 460]}, {"607":[481, 558]}, {"608":[13, 40]}, {"609":[50, 51]}, {"610":[382, 383]}, {"611":[91, 281]}, {"612":[479, 510]}, {"613":[122, 123]}, {"614":[330, 331]}, {"615":[547, 599]}, {"616":[544, 558]}, {"617":[55, 89]}, {"618":[427, 439]}, {"619":[299, 429]}, {"620":[472, 514]}, {"621":[396, 407]}, {"622":[175, 181]}, {"623":[363, 408]}, {"624":[144, 185]}, {"625":[152, 206]}, {"626":[276, 277]}, {"627":[623, 624]}, {"628":[233, 267]}, {"629":[58, 96]}, {"630":[324, 434]}, {"631":[361, 425]}, {"632":[619, 620]}, {"633":[184, 189]}, {"634":[33, 50]}, {"635":[229, 673]}, {"636":[832, 840]}, {"637":[90, 92]}, {"638":[478, 502]}, {"639":[257, 258]}, {"640":[777, 785]}, {"641":[489, 541]}, {"642":[224, 236]}, {"643":[385, 440]}, {"644":[10, 11]}, {"645":[68, 464]}, {"646":[151, 268]}, {"647":[37, 52]}, {"648":[496, 586]}, {"649":[541, 542]}, {"650":[140, 249]}, {"651":[62, 110]}, {"652":[11, 14]}, {"653":[340, 367]}, {"654":[320, 408]}, {"655":[580, 581]}, {"656":[182, 213]}, {"657":[378, 431]}, {"658":[589, 669]}, {"659":[643, 659]}, {"660":[660, 674]}, {"661":[480, 547]}, {"662":[143, 192]}, {"663":[571, 574]}, {"664":[840, 846]}, {"665":[530, 535]}, {"666":[342, 376]}, {"667":[21, 22]}, {"668":[364, 369]}, {"669":[333, 437]}, {"670":[305, 431]}, {"671":[841, 842]}, {"672":[248, 254]}, {"673":[146, 193]}, {"674":[18, 794]}, {"675":[49, 124]}, {"676":[30, 48]}, {"677":[807, 813]}, {"678":[627, 628]}, {"679":[316, 351]}, {"680":[131, 195]}, {"681":[371, 426]}, {"682":[476, 527]}, {"683":[42, 130]}, {"684":[534, 576]}, {"685":[305, 348]}, {"686":[42, 59]}, {"687":[326, 437]}, {"688":[829, 847]}, {"689":[159, 183]}, {"690":[350, 435]}, {"691":[334, 339]}, {"692":[807, 824]}, {"693":[180, 249]}, {"694":[17, 18]}, {"695":[85, 86]}, {"696":[17, 841]}, {"697":[212, 251]}, {"698":[491, 578]}, {"699":[354, 369]}, {"700":[253, 254]}, {"701":[652, 653]}, {"702":[589, 598]}, {"703":[362, 363]}, {"704":[118, 123]}, {"705":[357, 436]}, {"706":[89, 130]}, {"707":[97, 449]}, {"708":[505, 506]}, {"709":[503, 599]}, {"710":[500, 573]}, {"711":[573, 606]}, {"712":[28, 32]}, {"713":[142, 184]}, {"714":[548, 555]}, {"715":[290, 645]}, {"716":[338, 355]}, {"717":[145, 230]}, {"718":[370, 415]}, {"719":[148, 207]}, {"720":[587, 598]}, {"721":[296, 398]}, {"722":[288, 289]}, {"723":[51, 190]}, {"724":[44, 45]}, {"725":[779, 788]}, {"726":[24, 569]}, {"727":[481, 609]}, {"728":[628, 629]}, {"729":[480, 517]}, {"730":[290, 646]}, {"731":[284, 288]}, {"732":[173, 266]}, {"733":[664, 665]}, {"734":[204, 261]}, {"735":[562, 616]}, {"736":[5, 6]}, {"737":[381, 671]}, {"738":[578, 581]}, {"739":[334, 434]}, {"740":[559, 562]}, {"741":[173, 178]}, {"742":[843, 856]}, {"743":[131, 186]}, {"744":[499, 613]}, {"745":[543, 544]}, {"746":[167, 170]}, {"747":[482, 540]}, {"748":[782, 793]}, {"749":[197, 198]}, {"750":[67, 658]}, {"751":[433, 438]}, {"752":[133, 255]}, {"753":[104, 465]}, {"754":[99, 441]}, {"755":[127, 642]}, {"756":[379, 416]}, {"757":[277, 278]}, {"758":[158, 271]}, {"759":[71, 469]}, {"760":[164, 169]}, {"761":[783, 848]}, {"762":[83, 84]}, {"763":[109, 654]}, {"764":[662, 663]}, {"765":[380, 390]}, {"766":[144, 238]}, {"767":[119, 446]}, {"768":[504, 520]}, {"769":[94, 461]}, {"770":[165, 166]}, {"771":[640, 653]}, {"772":[481, 550]}, {"773":[281, 453]}, {"774":[179, 213]}, {"775":[47, 620]}, {"776":[271, 277]}, {"777":[525, 526]}, {"778":[575, 579]}, {"779":[571, 585]}, {"780":[786, 815]}, {"781":[787, 845]}, {"782":[84, 633]}, {"783":[262, 270]}, {"784":[246, 266]}, {"785":[19, 25]}, {"786":[482, 618]}, {"787":[801, 828]}, {"788":[172, 173]}, {"789":[333, 384]}, {"790":[74, 124]}, {"791":[176, 257]}, {"792":[806, 809]}, {"793":[258, 265]}, {"794":[824, 844]}, {"795":[216, 245]}, {"796":[523, 524]}, {"797":[60, 68]}, {"798":[10, 26]}, {"799":[387, 420]}, {"800":[289, 651]}, {"801":[287, 647]}, {"802":[153, 240]}, {"803":[157, 216]}, {"804":[605, 606]}, {"805":[298, 406]}, {"806":[400, 424]}, {"807":[203, 259]}, {"808":[29, 784]}, {"809":[364, 414]}, {"810":[515, 516]}, {"811":[509, 533]}, {"812":[374, 375]}, {"813":[625, 629]}, {"814":[136, 266]}, {"815":[366, 419]}, {"816":[29, 846]}, {"817":[146, 202]}, {"818":[105, 120]}, {"819":[3, 4]}, {"820":[346, 381]}, {"821":[571, 600]}, {"822":[809, 824]}, {"823":[584, 585]}, {"824":[331, 344]}, {"825":[179, 180]}, {"826":[271, 272]}, {"827":[15, 37]}, {"828":[345, 346]}, {"829":[155, 262]}, {"830":[99, 102]}, {"831":[306, 322]}, {"832":[146, 210]}, {"833":[297, 410]}, {"834":[66, 70]}, {"835":[551, 560]}, {"836":[485, 522]}, {"837":[521, 522]}, {"838":[323, 421]}, {"839":[74, 75]}, {"840":[320, 423]}, {"841":[86, 393]}, {"842":[141, 181]}, {"843":[548, 560]}, {"844":[483, 531]}, {"845":[53, 430]}, {"846":[224, 225]}, {"847":[487, 614]}, {"848":[248, 250]}], "nodes":[{"1":{"x":0, "val":"T1", "y": -84}}, {"2":{"x":85, "val":"T2", "y": -1}}, {"3":{"x":1, "val":"T3", "y":82}}, {"4":{"x": -81, "val":"T4", "y":0}}, {"5":{"x": -211, "val":"T5", "y":131}}, {"6":{"x": -211, "val":"V", "y":0}}, {"7":{"x": -349, "val":"G", "y":196}}, {"8":{"x": -211, "val":"T8", "y":268}}, {"9":{"x": -423, "val":"V", "y": -84}}, {"10":{"x": -342, "val":"Mt", "y": -185}}, {"11":{"x": -211, "val":"T7", "y": -266}}, {"12":{"x": -71, "val":"Cd", "y": -182}}, {"13":{"x": -339, "val":"V", "y":0}}, {"14":{"x": -211, "val":"T6", "y": -134}}, {"15":{"x": -74, "val":"H", "y":197}}, {"16":{"x":15666, "val":"A04", "y": -283}}, {"17":{"x":15740, "val":"A38", "y": -633}}, {"18":{"x":15741, "val":"A39", "y": -758}}, {"19":{"x":15593, "val":"S52", "y": -62}}, {"20":{"x":15815, "val":"A07", "y": -282}}, {"21":{"x":15741, "val":"A02", "y": -377}}, {"22":{"x":15740, "val":"A39", "y": -501}}, {"23":{"x":15888, "val":"S66", "y": -61}}, {"24":{"x": -1489, "val":"Gp", "y":51}}, {"25":{"x":15593, "val":"S51", "y": -189}}, {"26":{"x": -389, "val":"V", "y": -329}}, {"27":{"x":15741, "val":"A39", "y":255}}, {"28":{"x":15666, "val":"A08", "y":32}}, {"29":{"x":15741, "val":"A38", "y":384}}, {"30":{"x": -27, "val":"V", "y": -328}}, {"31":{"x":15888, "val":"S67", "y": -189}}, {"32":{"x":15741, "val":"A05", "y":129}}, {"33":{"x": -400, "val":"V", "y":342}}, {"34":{"x":15741, "val":"A39", "y":0}}, {"35":{"x":15741, "val":"A00", "y": -125}}, {"36":{"x":15741, "val":"A39", "y": -254}}, {"37":{"x": -26, "val":"V", "y":342}}, {"38":{"x":15816, "val":"A06", "y":34}}, {"39":{"x": -507, "val":"V", "y": -1}}, {"40":{"x": -423, "val":"V", "y":82}}, {"41":{"x": -793, "val":"Ir", "y": -35}}, {"42":{"x":108, "val":"V", "y": -1772}}, {"43":{"x": -39, "val":"Gc", "y": -1138}}, {"44":{"x": -234, "val":"Cc", "y": -1113}}, {"45":{"x": -427, "val":"Gp", "y": -1093}}, {"46":{"x": -503, "val":"Bd", "y": -438}}, {"47":{"x": -614, "val":"qMr", "y": -543}}, {"48":{"x":87, "val":"Cc", "y": -438}}, {"49":{"x":205, "val":"qCd", "y": -544}}, {"50":{"x": -503, "val":"Hd", "y":427}}, {"51":{"x": -614, "val":"qG", "y":520}}, {"52":{"x":86, "val":"Mu", "y":429}}, {"53":{"x":206, "val":"qH", "y":520}}, {"54":{"x": -193, "val":"Gc", "y": -2104}}, {"55":{"x": -39, "val":"Gp", "y": -2079}}, {"56":{"x": -174, "val":"Mr", "y": -1631}}, {"57":{"x":146, "val":"Bd", "y": -1468}}, {"58":{"x":1883, "val":"Rh", "y": -863}}, {"59":{"x":107, "val":"Bc", "y": -1614}}, {"60":{"x":1106, "val":"I7", "y": -119}}, {"61":{"x":254, "val":"Cc", "y": -2027}}, {"62":{"x":382, "val":"I3", "y": -2127}}, {"63":{"x": -1505, "val":"Ea", "y":224}}, {"64":{"x":1074, "val":"Bg", "y": -1851}}, {"65":{"x":1228, "val":"Cl", "y": -1868}}, {"66":{"x":1796, "val":"Tg", "y": -1561}}, {"67":{"x":1385, "val":"Gc", "y": -1875}}, {"68":{"x":1236, "val":"H", "y": -65}}, {"69":{"x":1605, "val":"Gb", "y": -1791}}, {"70":{"x":1698, "val":"G", "y": -1661}}, {"71":{"x":1622, "val":"Bc", "y": -1023}}, {"72":{"x":1890, "val":"Mu", "y": -583}}, {"73":{"x":1213, "val":"Mu", "y": -233}}, {"74":{"x":449, "val":"Mu", "y": -575}}, {"75":{"x":552, "val":"H", "y": -466}}, {"76":{"x":816, "val":"V", "y": -444}}, {"77":{"x": -785, "val":"Gp", "y": -172}}, {"78":{"x":1544, "val":"V", "y": -457}}, {"79":{"x":466, "val":"Pa", "y": -778}}, {"80":{"x":605, "val":"V", "y": -887}}, {"81":{"x":660, "val":"Pt", "y": -1069}}, {"82":{"x":1914, "val":"Hd", "y": -724}}, {"83":{"x":1920, "val":"H", "y": -215}}, {"84":{"x":1788, "val":"Bd", "y": -265}}, {"85":{"x": -262, "val":"Hd", "y":1152}}, {"86":{"x": -219, "val":"G", "y":1016}}, {"87":{"x":1674, "val":"I4", "y": -507}}, {"88":{"x":1752, "val":"Md", "y": -615}}, {"89":{"x":110, "val":"Mt", "y": -2045}}, {"90":{"x":493, "val":"G", "y": -2227}}, {"91":{"x":811, "val":"I4", "y": -2032}}, {"92":{"x":617, "val":"V", "y": -2144}}, {"93":{"x":764, "val":"Cl", "y": -2155}}, {"94":{"x":1879, "val":"Md", "y": -1304}}, {"95":{"x":1805, "val":"I8", "y": -1183}}, {"96":{"x":1744, "val":"V", "y": -942}}, {"97":{"x":1668, "val":"Kh", "y": -1241}}, {"98":{"x":1837, "val":"Md", "y": -1046}}, {"99":{"x":693, "val":"Md", "y": -767}}, {"100":{"x":1308, "val":"Pa", "y": -443}}, {"101":{"x":717, "val":"Cc", "y": -579}}, {"102":{"x":829, "val":"Hd", "y": -763}}, {"103":{"x":988, "val":"Kh", "y": -196}}, {"104":{"x":1961, "val":"Bc", "y": -342}}, {"105":{"x":603, "val":"I3", "y": -1215}}, {"106":{"x":946, "val":"G", "y": -695}}, {"107":{"x":947, "val":"Ra", "y": -841}}, {"108":{"x":776, "val":"Cd", "y": -1170}}, {"109":{"x":1348, "val":"Ir", "y": -310}}, {"110":{"x":429, "val":"Md", "y": -2002}}, {"111":{"x":970, "val":"Ph", "y": -958}}, {"112":{"x":376, "val":"Cd", "y": -1870}}, {"113":{"x":1066, "val":"Tc", "y": -1987}}, {"114":{"x":667, "val":"Bc", "y": -364}}, {"115":{"x":270, "val":"Mr", "y": -819}}, {"116":{"x":122, "val":"Eh", "y": -1312}}, {"117":{"x":207, "val":"Ea", "y": -987}}, {"118":{"x":143, "val":"I1", "y": -1147}}, {"119":{"x":555, "val":"G", "y": -1413}}, {"120":{"x":691, "val":"Cc", "y": -1329}}, {"121":{"x":951, "val":"Ir", "y": -2081}}, {"122":{"x":426, "val":"Cd", "y": -1344}}, {"123":{"x":301, "val":"Ph", "y": -1241}}, {"124":{"x":325, "val":"Md", "y": -663}}, {"125":{"x":1178, "val":"Md", "y": -364}}, {"126":{"x":1563, "val":"Mu", "y": -112}}, {"127":{"x":392, "val":"Hd", "y":2166}}, {"128":{"x":1699, "val":"I5", "y": -163}}, {"129":{"x": -897, "val":"Gc", "y":60}}, {"130":{"x":23, "val":"I2", "y": -1909}}, {"131":{"x": -2345, "val":"qMt", "y":618}}, {"132":{"x": -1880, "val":"qEn", "y":156}}, {"133":{"x": -2344, "val":"qGp", "y":976}}, {"134":{"x": -2246, "val":"qIr", "y":1050}}, {"135":{"x": -2258, "val":"qGc", "y":959}}, {"136":{"x": -2144, "val":"Q43", "y":787}}, {"137":{"x": -1679, "val":"qHd", "y":1158}}, {"138":{"x": -1526, "val":"qIr", "y":1279}}, {"139":{"x": -224, "val":"qBd", "y":2344}}, {"140":{"x": -1746, "val":"qG", "y":1410}}, {"141":{"x": -1598, "val":"qG", "y":971}}, {"142":{"x": -1495, "val":"Q44", "y":466}}, {"143":{"x": -707, "val":"qGp", "y":139}}, {"144":{"x": -220, "val":"qH", "y":2054}}, {"145":{"x": -353, "val":"qMu", "y":1554}}, {"146":{"x": -1027, "val":"qBg", "y":837}}, {"147":{"x": -676, "val":"qGb", "y":1504}}, {"148":{"x": -728, "val":"qHd", "y":1213}}, {"149":{"x": -829, "val":"Q42", "y":1167}}, {"150":{"x": -810, "val":"qTc", "y":1272}}, {"151":{"x": -2178, "val":"Q41", "y":1669}}, {"152":{"x": -2178, "val":"qHd", "y":1960}}, {"153":{"x": -494, "val":"qBd", "y":2016}}, {"154":{"x": -932, "val":"Q45", "y":1926}}, {"155":{"x": -723, "val":"qTg", "y":1827}}, {"156":{"x": -1467, "val":"qG", "y":2108}}, {"157":{"x": -745, "val":"qHd", "y":2256}}, {"158":{"x": -1576, "val":"qGb", "y":1793}}, {"159":{"x": -537, "val":"qH", "y":823}}, {"160":{"x": -2104, "val":"qMr", "y":382}}, {"161":{"x": -2239, "val":"I6", "y":319}}, {"162":{"x": -2373, "val":"Gc", "y":364}}, {"163":{"x": -2388, "val":"Gp", "y":494}}, {"164":{"x": -2055, "val":"G", "y":570}}, {"165":{"x": -1799, "val":"Mt", "y":411}}, {"166":{"x": -1905, "val":"Mr", "y":286}}, {"167":{"x": -1734, "val":"V", "y":224}}, {"168":{"x": -1352, "val":"Kh", "y":404}}, {"169":{"x": -1954, "val":"En", "y":467}}, {"170":{"x": -1606, "val":"Eh", "y":340}}, {"171":{"x": -1588, "val":"Gp", "y":592}}, {"172":{"x": -1709, "val":"Gc", "y":699}}, {"173":{"x": -1845, "val":"I4", "y":782}}, {"174":{"x": -1635, "val":"Cd", "y":833}}, {"175":{"x": -1286, "val":"Cl", "y":915}}, {"176":{"x": -1912, "val":"Rh", "y":1225}}, {"177":{"x": -1837, "val":"I3", "y":1085}}, {"178":{"x": -1808, "val":"Ra", "y":925}}, {"179":{"x": -1734, "val":"V", "y":1821}}, {"180":{"x": -1787, "val":"Mr", "y":1675}}, {"181":{"x": -1439, "val":"I5", "y":941}}, {"182":{"x": -1996, "val":"Ph", "y":1956}}, {"183":{"x": -666, "val":"Hd", "y":884}}, {"184":{"x": -1383, "val":"Cd", "y":565}}, {"185":{"x": -89, "val":"Hd", "y":2073}}, {"186":{"x": -2219, "val":"G", "y":680}}, {"187":{"x": -1195, "val":"Bd", "y":368}}, {"188":{"x": -1029, "val":"Bc", "y":344}}, {"189":{"x": -1242, "val":"Cc", "y":621}}, {"190":{"x": -737, "val":"Gp", "y":414}}, {"191":{"x": -871, "val":"V", "y":334}}, {"192":{"x": -846, "val":"I8", "y":198}}, {"193":{"x": -1174, "val":"G", "y":748}}, {"194":{"x": -727, "val":"Ir", "y":624}}, {"195":{"x": -2398, "val":"I2", "y":726}}, {"196":{"x": -2391, "val":"Hd", "y":854}}, {"197":{"x": -2033, "val":"Hd", "y":147}}, {"198":{"x": -2179, "val":"Ra", "y":167}}, {"199":{"x": -968, "val":"Tg", "y":704}}, {"200":{"x": -447, "val":"Ir", "y":1162}}, {"201":{"x": -874, "val":"Tc", "y":595}}, {"202":{"x": -1141, "val":"Tc", "y":935}}, {"203":{"x": -2358, "val":"Md", "y":1760}}, {"204":{"x": -411, "val":"V", "y":897}}, {"205":{"x": -390, "val":"Eh", "y":1033}}, {"206":{"x": -2299, "val":"Pa", "y":1884}}, {"207":{"x": -588, "val":"I1", "y":1170}}, {"208":{"x": -667, "val":"Bg", "y":1064}}, {"209":{"x": -772, "val":"G", "y":970}}, {"210":{"x": -880, "val":"Gb", "y":875}}, {"211":{"x": -1387, "val":"Hd", "y":1074}}, {"212":{"x": -1396, "val":"G", "y":1214}}, {"213":{"x": -1817, "val":"I7", "y":1968}}, {"214":{"x": -1459, "val":"Ea", "y":1405}}, {"215":{"x": -1074, "val":"V", "y":1906}}, {"216":{"x": -606, "val":"Pa", "y":2310}}, {"217":{"x": -1637, "val":"Pt", "y":2026}}, {"218":{"x": -1288, "val":"Cc", "y":2114}}, {"219":{"x": -1105, "val":"Cd", "y":2170}}, {"220":{"x": -923, "val":"Md", "y":2212}}, {"221":{"x": -1108, "val":"Bd", "y":2039}}, {"222":{"x": -970, "val":"V", "y":1142}}, {"223":{"x": -987, "val":"Tg", "y":1269}}, {"224":{"x": -1005, "val":"Ir", "y":1398}}, {"225":{"x": -850, "val":"Gb", "y":1397}}, {"226":{"x": -564, "val":"Gp", "y":1427}}, {"227":{"x": -347, "val":"Mu", "y":1274}}, {"228":{"x": -532, "val":"G", "y":1292}}, {"229":{"x": -2308, "val":"Rh", "y":209}}, {"230":{"x": -320, "val":"H", "y":1415}}, {"231":{"x": -278, "val":"I3", "y":1683}}, {"232":{"x": -216, "val":"Bd", "y":1802}}, {"233":{"x": -405, "val":"Ea", "y":1714}}, {"234":{"x": -559, "val":"Gb", "y":1748}}, {"235":{"x": -569, "val":"Bg", "y":1878}}, {"236":{"x": -973, "val":"Bg", "y":1535}}, {"237":{"x": -501, "val":"Gc", "y":1544}}, {"238":{"x": -166, "val":"Bc", "y":1933}}, {"239":{"x": -958, "val":"Ra", "y":1677}}, {"240":{"x": -638, "val":"Ph", "y":2038}}, {"241":{"x": -31, "val":"Mu", "y":2188}}, {"242":{"x": -94, "val":"H", "y":2301}}, {"243":{"x": -575, "val":"Pt", "y":2166}}, {"244":{"x": -335, "val":"Cl", "y":2268}}, {"245":{"x": -472, "val":"I5", "y":2260}}, {"246":{"x": -1961, "val":"Tg", "y":930}}, {"247":{"x": -2116, "val":"Tc", "y":943}}, {"248":{"x": -2368, "val":"Gc", "y":1371}}, {"249":{"x": -1847, "val":"Hd", "y":1536}}, {"250":{"x": -2362, "val":"Gp", "y":1511}}, {"251":{"x": -1257, "val":"Ra", "y":1171}}, {"252":{"x": -1959, "val":"Mt", "y":1422}}, {"253":{"x": -2153, "val":"G", "y":1183}}, {"254":{"x": -2313, "val":"I1", "y":1253}}, {"255":{"x": -2361, "val":"Cd", "y":1115}}, {"256":{"x": -1110, "val":"Rh", "y":1152}}, {"257":{"x": -2059, "val":"V", "y":1307}}, {"258":{"x": -2173, "val":"Cd", "y":1390}}, {"259":{"x": -2327, "val":"I8", "y":1639}}, {"260":{"x": -510, "val":"Ea", "y":637}}, {"261":{"x": -408, "val":"Kh", "y":749}}, {"262":{"x": -745, "val":"Ir", "y":1685}}, {"263":{"x": -870, "val":"Rh", "y":1783}}, {"264":{"x": -1932, "val":"Cl", "y":644}}, {"265":{"x": -2155, "val":"Cc", "y":1533}}, {"266":{"x": -1996, "val":"V", "y":772}}, {"267":{"x": -344, "val":"Eh", "y":1829}}, {"268":{"x": -2036, "val":"Hd", "y":1719}}, {"269":{"x": -1890, "val":"Cl", "y":1776}}, {"270":{"x": -615, "val":"V", "y":1631}}, {"271":{"x": -1427, "val":"G", "y":1843}}, {"272":{"x": -1332, "val":"Gc", "y":1970}}, {"273":{"x": -1077, "val":"G", "y":1766}}, {"274":{"x": -438, "val":"I4", "y":1910}}, {"275":{"x": -1628, "val":"Eh", "y":1497}}, {"276":{"x": -1474, "val":"Kh", "y":1552}}, {"277":{"x": -1410, "val":"I6", "y":1697}}, {"278":{"x": -1245, "val":"Hd", "y":1736}}, {"279":{"x": -2276, "val":"Gb", "y":814}}, {"280":{"x": -1032, "val":"I2", "y":1020}}, {"281":{"x":751, "val":"Md", "y": -1903}}, {"282":{"x":370, "val":"Cl", "y": -1569}}, {"283":{"x":237, "val":"Cc", "y": -1659}}, {"284":{"x":997, "val":"Cl", "y": -1646}}, {"285":{"x":882, "val":"Cd", "y": -1742}}, {"286":{"x":816, "val":"Md", "y": -1421}}, {"287":{"x":847, "val":"V", "y": -1613}}, {"288":{"x":1100, "val":"Pt", "y": -1543}}, {"289":{"x":1100, "val":"Cc", "y": -1421}}, {"290":{"x":1228, "val":"I2", "y": -1080}}, {"291":{"x": -12, "val":"qG", "y":1367}}, {"292":{"x":266, "val":"qHd", "y":1504}}, {"293":{"x":263, "val":"Q81", "y":803}}, {"294":{"x":543, "val":"qH", "y":932}}, {"295":{"x": -151, "val":"qBg", "y":766}}, {"296":{"x":802, "val":"Q84", "y":1253}}, {"297":{"x":752, "val":"qCd", "y":154}}, {"298":{"x":454, "val":"qBd", "y":1140}}, {"299":{"x":658, "val":"qH", "y":1374}}, {"300":{"x":930, "val":"Q82", "y":726}}, {"301":{"x":1132, "val":"qHd", "y":961}}, {"302":{"x":1464, "val":"Q86", "y":1926}}, {"303":{"x":1258, "val":"Q85", "y":1304}}, {"304":{"x":1622, "val":"qCl", "y":314}}, {"305":{"x":526, "val":"qTg", "y":1785}}, {"306":{"x":651, "val":"qIr", "y":2068}}, {"307":{"x":1088, "val":"qH", "y":1534}}, {"308":{"x":1227, "val":"qMu", "y":1810}}, {"309":{"x":607, "val":"qBc", "y":996}}, {"310":{"x":1240, "val":"qBd", "y":2235}}, {"311":{"x":1882, "val":"qHd", "y":1351}}, {"312":{"x":782, "val":"qH", "y":851}}, {"313":{"x":772, "val":"qHd", "y":644}}, {"314":{"x":768, "val":"qH", "y":510}}, {"315":{"x":1401, "val":"qBd", "y":908}}, {"316":{"x":1632, "val":"Kh", "y":178}}, {"317":{"x":1502, "val":"Hd", "y":1020}}, {"318":{"x":893, "val":"Cd", "y":1437}}, {"319":{"x":1373, "val":"H", "y":1802}}, {"320":{"x":1570, "val":"Bc", "y":1646}}, {"321":{"x":1203, "val":"Cl", "y":2006}}, {"322":{"x":774, "val":"Rh", "y":2120}}, {"323":{"x":978, "val":"V", "y":1332}}, {"324":{"x":624, "val":"Ph", "y":72}}, {"325":{"x":1771, "val":"Mu", "y":1833}}, {"326":{"x":1518, "val":"Q83", "y":607}}, {"327":{"x":1750, "val":"I6", "y":452}}, {"328":{"x":1774, "val":"Cd", "y":311}}, {"329":{"x":1709, "val":"Kh", "y":678}}, {"330":{"x":1667, "val":"Cd", "y":807}}, {"331":{"x":1555, "val":"Md", "y":893}}, {"332":{"x":1050, "val":"Pa", "y":236}}, {"333":{"x":1555, "val":"Bd", "y":445}}, {"334":{"x":595, "val":"Md", "y":281}}, {"335":{"x":1325, "val":"Cd", "y":236}}, {"336":{"x":1183, "val":"I7", "y":279}}, {"337":{"x":23, "val":"V", "y":1186}}, {"338":{"x":943, "val":"Q88", "y":1937}}, {"339":{"x":653, "val":"I8", "y":416}}, {"340":{"x":331, "val":"Cd", "y":426}}, {"341":{"x":242, "val":"Cl", "y":1194}}, {"342":{"x":385, "val":"V", "y":687}}, {"343":{"x":927, "val":"Mu", "y":433}}, {"344":{"x":1474, "val":"En", "y":761}}, {"345":{"x": -24, "val":"I2", "y":1505}}, {"346":{"x":90, "val":"Gp", "y":1583}}, {"347":{"x":229, "val":"Bc", "y":1634}}, {"348":{"x":673, "val":"H", "y":1717}}, {"349":{"x":778, "val":"Bd", "y":1606}}, {"350":{"x":989, "val":"Mu", "y":2233}}, {"351":{"x":1472, "val":"Pt", "y":184}}, {"352":{"x":1078, "val":"V", "y":692}}, {"353":{"x":898, "val":"V", "y":2148}}, {"354":{"x":1492, "val":"I1", "y":1541}}, {"355":{"x":852, "val":"H", "y":1839}}, {"356":{"x":1435, "val":"Eh", "y":1173}}, {"357":{"x":1381, "val":"Ea", "y":2191}}, {"358":{"x":941, "val":"Mu", "y":1096}}, {"359":{"x":1913, "val":"G", "y":1479}}, {"360":{"x":1303, "val":"Bd", "y":1153}}, {"361":{"x":1077, "val":"H", "y":1111}}, {"362":{"x":1891, "val":"Cl", "y":1612}}, {"363":{"x":1791, "val":"Kh", "y":1702}}, {"364":{"x":1222, "val":"V", "y":1581}}, {"365":{"x":1828, "val":"I5", "y":1216}}, {"366":{"x": -129, "val":"Gb", "y":1269}}, {"367":{"x":496, "val":"Hd", "y":409}}, {"368":{"x":818, "val":"Cl", "y":348}}, {"369":{"x":1362, "val":"Mu", "y":1596}}, {"370":{"x":1094, "val":"I6", "y":1385}}, {"371":{"x":1123, "val":"I8", "y":1897}}, {"372":{"x":115, "val":"G", "y":624}}, {"373":{"x":1695, "val":"Mu", "y":1261}}, {"374":{"x":662, "val":"Cl", "y":752}}, {"375":{"x":522, "val":"Mu", "y":807}}, {"376":{"x":521, "val":"H", "y":660}}, {"377":{"x":259, "val":"Tc", "y":1947}}, {"378":{"x":216, "val":"Rh", "y":1805}}, {"379":{"x":511, "val":"Tg", "y":2079}}, {"380":{"x":1065, "val":"H", "y":555}}, {"381":{"x":90, "val":"Bg", "y":1726}}, {"382":{"x":1807, "val":"H", "y":1062}}, {"383":{"x":1754, "val":"Bd", "y":920}}, {"384":{"x":1415, "val":"H", "y":431}}, {"385":{"x":1312, "val":"Mu", "y":502}}, {"386":{"x":1214, "val":"Bc", "y":596}}, {"387":{"x":921, "val":"Kh", "y":913}}, {"388":{"x":841, "val":"Cl", "y":1012}}, {"389":{"x":1207, "val":"Cl", "y":791}}, {"390":{"x":913, "val":"Bd", "y":575}}, {"391":{"x":1329, "val":"I4", "y":699}}, {"392":{"x":956, "val":"Hd", "y":1594}}, {"393":{"x": -76, "val":"Tc", "y":994}}, {"394":{"x":388, "val":"Hd", "y":947}}, {"395":{"x":233, "val":"Bd", "y":932}}, {"396":{"x":626, "val":"H", "y":1173}}, {"397":{"x":985, "val":"G", "y":2058}}, {"398":{"x":916, "val":"Mr", "y":1210}}, {"399":{"x":1500, "val":"I7", "y":2109}}, {"400":{"x":380, "val":"I4", "y":1419}}, {"401":{"x":492, "val":"G", "y":1500}}, {"402":{"x":633, "val":"Cl", "y":1532}}, {"403":{"x": -45, "val":"I1", "y":865}}, {"404":{"x":1544, "val":"Cl", "y":1290}}, {"405":{"x":273, "val":"Kh", "y":1066}}, {"406":{"x":366, "val":"Mt", "y":1244}}, {"407":{"x":723, "val":"I3", "y":1072}}, {"408":{"x":1695, "val":"qH", "y":1609}}, {"409":{"x":35, "val":"Tg", "y":744}}, {"410":{"x":903, "val":"Cc", "y":173}}, {"411":{"x": -141, "val":"Gc", "y":1409}}, {"412":{"x":518, "val":"Bc", "y":1266}}, {"413":{"x":1355, "val":"Cl", "y":1033}}, {"414":{"x":1137, "val":"Hd", "y":1690}}, {"415":{"x":1214, "val":"Bd", "y":1441}}, {"416":{"x":394, "val":"I3", "y":1985}}, {"417":{"x":85, "val":"H", "y":906}}, {"418":{"x":248, "val":"I5", "y":672}}, {"419":{"x": -104, "val":"Ir", "y":1128}}, {"420":{"x":1055, "val":"G", "y":846}}, {"421":{"x":1067, "val":"Hd", "y":1234}}, {"422":{"x":129, "val":"Ra", "y":1275}}, {"423":{"x":1507, "val":"Hd", "y":1754}}, {"424":{"x":254, "val":"H", "y":1343}}, {"425":{"x":1207, "val":"I2", "y":1068}}, {"426":{"x":1035, "val":"H", "y":1795}}, {"427":{"x":1436, "val":"Cd", "y":1423}}, {"428":{"x":117, "val":"Q87", "y":1085}}, {"429":{"x":766, "val":"Mu", "y":1469}}, {"430":{"x":345, "val":"Bd", "y":561}}, {"431":{"x":376, "val":"G", "y":1822}}, {"432":{"x":879, "val":"Kh", "y":1703}}, {"433":{"x":1577, "val":"V", "y":2003}}, {"434":{"x":519, "val":"H", "y":169}}, {"435":{"x":1111, "val":"Kh", "y":2262}}, {"436":{"x":1320, "val":"G", "y":2080}}, {"437":{"x":1651, "val":"V", "y":548}}, {"438":{"x":1685, "val":"Bd", "y":1930}}, {"439":{"x":1397, "val":"V", "y":1301}}, {"440":{"x":1199, "val":"qHd", "y":412}}, {"441":{"x":602, "val":"qH", "y": -666}}, {"442":{"x":596, "val":"qBd", "y": -2007}}, {"443":{"x":259, "val":"Q63", "y": -1801}}, {"444":{"x":728, "val":"Q64", "y": -1547}}, {"445":{"x":502, "val":"qBd", "y": -1774}}, {"446":{"x":507, "val":"qMd", "y": -1546}}, {"447":{"x":845, "val":"qCd", "y": -1274}}, {"448":{"x":1225, "val":"qCd", "y": -551}}, {"449":{"x":1577, "val":"qCd", "y": -1359}}, {"450":{"x":848, "val":"qCl", "y": -1044}}, {"451":{"x":1080, "val":"qCd", "y": -1044}}, {"452":{"x":1454, "val":"Q61", "y": -552}}, {"453":{"x":729, "val":"qCd", "y": -1769}}, {"454":{"x":1078, "val":"qMd", "y": -1271}}, {"455":{"x":1224, "val":"Q66", "y": -774}}, {"456":{"x":1453, "val":"qMd", "y": -775}}, {"457":{"x":216, "val":"qEn", "y": -2168}}, {"458":{"x":299, "val":"qMr", "y": -1451}}, {"459":{"x":420, "val":"qHd", "y": -406}}, {"460":{"x":920, "val":"qGb", "y": -1862}}, {"461":{"x":1895, "val":"qIr", "y": -1446}}, {"462":{"x":778, "val":"Q62", "y": -914}}, {"463":{"x":1262, "val":"Q65", "y": -1272}}, {"464":{"x":1378, "val":"qMu", "y": -94}}, {"465":{"x":1861, "val":"qH", "y": -444}}, {"466":{"x":347, "val":"qMt", "y": -1062}}, {"467":{"x":1339, "val":"qG", "y": -1683}}, {"468":{"x":1018, "val":"qBd", "y": -587}}, {"469":{"x":1487, "val":"qCl", "y": -967}}, {"470":{"x":1624, "val":"qBd", "y": -271}}, {"471":{"x": -2253, "val":"Q27", "y": -908}}, {"472":{"x": -1910, "val":"Q26", "y": -565}}, {"473":{"x": -1650, "val":"Q30", "y": -1470}}, {"474":{"x": -1331, "val":"qMt", "y": -1142}}, {"475":{"x": -1068, "val":"Q24", "y": -692}}, {"476":{"x": -2143, "val":"qBd", "y": -1744}}, {"477":{"x": -553, "val":"qCd", "y": -2256}}, {"478":{"x": -2244, "val":"qGc", "y": -586}}, {"479":{"x": -1896, "val":"qIr", "y": -244}}, {"480":{"x": -2085, "val":"qMt", "y": -741}}, {"481":{"x": -1322, "val":"qMr", "y": -820}}, {"482":{"x": -1059, "val":"qTg", "y": -370}}, {"483":{"x": -2133, "val":"Q21", "y": -1422}}, {"484":{"x": -544, "val":"Q28", "y": -1934}}, {"485":{"x": -2233, "val":"Q23", "y": -359}}, {"486":{"x": -1890, "val":"qBg", "y": -17}}, {"487":{"x": -2121, "val":"qGp", "y": -467}}, {"488":{"x": -1311, "val":"Q25", "y": -593}}, {"489":{"x": -1048, "val":"qG", "y": -143}}, {"490":{"x": -2123, "val":"qGp", "y": -1195}}, {"491":{"x": -533, "val":"qMd", "y": -1707}}, {"492":{"x": -1782, "val":"qGc", "y": -1543}}, {"493":{"x": -1848, "val":"qEn", "y": -1285}}, {"494":{"x": -2012, "val":"Q29", "y": -1132}}, {"495":{"x": -673, "val":"qBd", "y": -1890}}, {"496":{"x": -630, "val":"qCl", "y": -1677}}, {"497":{"x": -793, "val":"qBd", "y": -924}}, {"498":{"x": -1265, "val":"qEn", "y": -2024}}, {"499":{"x": -813, "val":"Q22", "y": -1473}}, {"500":{"x": -803, "val":"qCd", "y": -1151}}, {"501":{"x": -2384, "val":"Cd", "y": -492}}, {"502":{"x": -2365, "val":"I6", "y": -614}}, {"503":{"x": -2391, "val":"Mu", "y": -746}}, {"504":{"x": -2389, "val":"Kh", "y": -878}}, {"505":{"x": -1729, "val":"I3", "y": -54}}, {"506":{"x": -1743, "val":"Mr", "y": -181}}, {"507":{"x": -1623, "val":"Rh", "y": -321}}, {"508":{"x": -1514, "val":"Ra", "y": -423}}, {"509":{"x": -2039, "val":"Hd", "y": -1317}}, {"510":{"x": -1777, "val":"V", "y": -309}}, {"511":{"x": -1385, "val":"Bg", "y": -111}}, {"512":{"x": -1757, "val":"En", "y": -431}}, {"513":{"x": -1738, "val":"I5", "y": -561}}, {"514":{"x": -1804, "val":"V", "y": -670}}, {"515":{"x": -2025, "val":"Gp", "y": -210}}, {"516":{"x": -2035, "val":"Eh", "y": -326}}, {"517":{"x": -1951, "val":"V", "y": -776}}, {"518":{"x": -1827, "val":"Gc", "y": -840}}, {"519":{"x": -2115, "val":"Pt", "y": -905}}, {"520":{"x": -2358, "val":"I8", "y": -1008}}, {"521":{"x": -2353, "val":"Cc", "y": -372}}, {"522":{"x": -2312, "val":"V", "y": -251}}, {"523":{"x": -2336, "val":"Pt", "y": -1126}}, {"524":{"x": -2314, "val":"Ph", "y": -1248}}, {"525":{"x": -2262, "val":"Pa", "y": -1372}}, {"526":{"x": -2253, "val":"G", "y": -1505}}, {"527":{"x": -1991, "val":"Cd", "y": -1781}}, {"528":{"x": -1984, "val":"Cd", "y": -651}}, {"529":{"x": -2100, "val":"Cc", "y": -593}}, {"530":{"x": -1739, "val":"H", "y": -1674}}, {"531":{"x": -2030, "val":"I1", "y": -1520}}, {"532":{"x": -1799, "val":"Md", "y": -1409}}, {"533":{"x": -1944, "val":"V", "y": -1410}}, {"534":{"x": -656, "val":"Mr", "y": -1517}}, {"535":{"x": -1837, "val":"Ir", "y": -1793}}, {"536":{"x": -1364, "val":"I2", "y": -447}}, {"537":{"x": -1585, "val":"Mt", "y": -569}}, {"538":{"x": -1279, "val":"G", "y": -317}}, {"539":{"x": -1213, "val":"V", "y": -174}}, {"540":{"x": -1180, "val":"Gp", "y": -465}}, {"541":{"x": -926, "val":"Tc", "y": -216}}, {"542":{"x": -854, "val":"Tg", "y": -341}}, {"543":{"x": -1454, "val":"Gp", "y": -638}}, {"544":{"x": -1535, "val":"Cc", "y": -759}}, {"545":{"x": -2156, "val":"G", "y": -239}}, {"546":{"x": -985, "val":"V", "y": -814}}, {"547":{"x": -2191, "val":"Bd", "y": -811}}, {"548":{"x": -1597, "val":"Eh", "y": -1049}}, {"549":{"x": -1038, "val":"Cl", "y": -946}}, {"550":{"x": -1186, "val":"Ea", "y": -883}}, {"551":{"x": -1437, "val":"Kh", "y": -1249}}, {"552":{"x": -1703, "val":"Mu", "y": -776}}, {"553":{"x": -2118, "val":"Rh", "y": -1024}}, {"554":{"x": -2216, "val":"Ra", "y": -1104}}, {"555":{"x": -1736, "val":"Ea", "y": -1086}}, {"556":{"x": -1720, "val":"Mr", "y": -1220}}, {"557":{"x": -1627, "val":"En", "y": -903}}, {"558":{"x": -1468, "val":"Cd", "y": -874}}, {"559":{"x": -1527, "val":"Eh", "y": -1344}}, {"560":{"x": -1575, "val":"I2", "y": -1184}}, {"561":{"x": -1375, "val":"Bd", "y": -1515}}, {"562":{"x": -1509, "val":"V", "y": -1480}}, {"563":{"x": -1980, "val":"I7", "y": -907}}, {"564":{"x": -1847, "val":"Gp", "y": -970}}, {"565":{"x": -1876, "val":"V", "y": -1108}}, {"566":{"x": -1355, "val":"Rh", "y": -1370}}, {"567":{"x": -1203, "val":"Ra", "y": -1413}}, {"568":{"x": -1674, "val":"Gp", "y": -1345}}, {"569":{"x": -1560, "val":"Ir", "y": -70}}, {"570":{"x": -901, "val":"Mt", "y": -1863}}, {"571":{"x": -949, "val":"Pa", "y": -2061}}, {"572":{"x": -896, "val":"En", "y": -1720}}, {"573":{"x": -654, "val":"I7", "y": -1196}}, {"574":{"x": -804, "val":"I5", "y": -1979}}, {"575":{"x": -714, "val":"Gp", "y": -2087}}, {"576":{"x": -517, "val":"Pa", "y": -1444}}, {"577":{"x": -428, "val":"Pt", "y": -1564}}, {"578":{"x": -377, "val":"I6", "y": -1708}}, {"579":{"x": -554, "val":"Kh", "y": -2110}}, {"580":{"x": -408, "val":"V", "y": -2012}}, {"581":{"x": -356, "val":"Cd", "y": -1857}}, {"582":{"x": -333, "val":"Cc", "y": -2128}}, {"583":{"x": -408, "val":"Md", "y": -2227}}, {"584":{"x": -712, "val":"Ph", "y": -2225}}, {"585":{"x": -850, "val":"Pt", "y": -2168}}, {"586":{"x": -782, "val":"V", "y": -1621}}, {"587":{"x": -2033, "val":"Tc", "y": -1}}, {"588":{"x": -1022, "val":"G", "y": -1647}}, {"589":{"x": -2247, "val":"I4", "y": -141}}, {"590":{"x": -1120, "val":"V", "y": -1141}}, {"591":{"x": -1218, "val":"Mu", "y": -1625}}, {"592":{"x": -686, "val":"Cc", "y": -789}}, {"593":{"x": -1404, "val":"H", "y": -1951}}, {"594":{"x": -1219, "val":"En", "y": -1237}}, {"595":{"x": -1191, "val":"Mt", "y": -1023}}, {"596":{"x": -1606, "val":"I3", "y": -1728}}, {"597":{"x": -2206, "val":"Cl", "y": -1632}}, {"598":{"x": -2126, "val":"Tg", "y": -101}}, {"599":{"x": -2263, "val":"Bc", "y": -706}}, {"600":{"x": -1106, "val":"Kh", "y": -2067}}, {"601":{"x": -846, "val":"I8", "y": -756}}, {"602":{"x": -1403, "val":"Bc", "y": -1663}}, {"603":{"x": -710, "val":"H", "y": -1372}}, {"604":{"x": -901, "val":"Eh", "y": -1012}}, {"605":{"x": -643, "val":"Cd", "y": -935}}, {"606":{"x": -594, "val":"Kh", "y": -1068}}, {"607":{"x": -962, "val":"Mr", "y": -1162}}, {"608":{"x": -576, "val":"Ph", "y": -1304}}, {"609":{"x": -1231, "val":"Kh", "y": -710}}, {"610":{"x": -1162, "val":"Gc", "y": -595}}, {"611":{"x": -1295, "val":"V", "y": -1753}}, {"612":{"x": -1105, "val":"I4", "y": -1522}}, {"613":{"x": -955, "val":"Hd", "y": -1513}}, {"614":{"x": -1998, "val":"Ea", "y": -442}}, {"615":{"x": -1247, "val":"Gc", "y": -1887}}, {"616":{"x": -1537, "val":"Ea", "y": -1615}}, {"617":{"x": -1515, "val":"Bd", "y": -1841}}, {"618":{"x": -935, "val":"I1", "y": -442}}, {"619":{"x": -809, "val":"G", "y": -535}}, {"620":{"x": -725, "val":"En", "y": -654}}, {"621":{"x":1567, "val":"Ra", "y": -1601}}, {"622":{"x":1492, "val":"Pt", "y": -1477}}, {"623":{"x":1186, "val":"Md", "y": -1681}}, {"624":{"x":1248, "val":"Bd", "y": -1529}}, {"625":{"x":1317, "val":"V", "y": -1404}}, {"626":{"x":1248, "val":"Cc", "y": -900}}, {"627":{"x":1363, "val":"Pa", "y": -1158}}, {"628":{"x":1528, "val":"Hd", "y": -1212}}, {"629":{"x":1440, "val":"I7", "y": -1325}}, {"630":{"x":1633, "val":"Cc", "y": -699}}, {"631":{"x":1583, "val":"I1", "y": -838}}, {"632":{"x":1453, "val":"Hd", "y": -216}}, {"633":{"x":1727, "val":"Kh", "y": -384}}, {"634":{"x":812, "val":"Bd", "y": -284}}, {"635":{"x":389, "val":"Pt", "y": -1697}}, {"636":{"x":957, "val":"I8", "y": -340}}, {"637":{"x":1017, "val":"Cl", "y": -456}}, {"638":{"x":1336, "val":"Ir", "y": -759}}, {"639":{"x":1370, "val":"Cd", "y": -887}}, {"640":{"x":1338, "val":"V", "y": -628}}, {"641":{"x":111, "val":"Kh", "y":2223}}, {"642":{"x":256, "val":"Bc", "y":2211}}, {"643":{"x":454, "val":"Cc", "y": -1153}}, {"644":{"x":956, "val":"G", "y": -1138}}, {"645":{"x":1104, "val":"Cl", "y": -1165}}, {"646":{"x":1339, "val":"V", "y": -1007}}, {"647":{"x":933, "val":"I5", "y": -1507}}, {"648":{"x":1489, "val":"Cl", "y": -664}}, {"649":{"x":605, "val":"Rh", "y": -1651}}, {"650":{"x":615, "val":"Pa", "y": -1793}}, {"651":{"x":968, "val":"Cd", "y": -1377}}, {"652":{"x":1076, "val":"Bd", "y": -749}}, {"653":{"x":1189, "val":"I6", "y": -667}}, {"654":{"x":1472, "val":"H", "y": -353}}, {"655":{"x":1730, "val":"Pt", "y": -802}}, {"656":{"x":1480, "val":"Md", "y": -1087}}, {"657":{"x":525, "val":"Kh", "y": -1901}}, {"658":{"x":1457, "val":"I6", "y": -1760}}, {"659":{"x":520, "val":"Cl", "y": -1012}}, {"660":{"x":468, "val":"Bd", "y": -165}}, {"661":{"x":524, "val":"H", "y": -35}}, {"662":{"x":1314, "val":"Cd", "y":44}}, {"663":{"x":1206, "val":"Mu", "y":134}}, {"664":{"x":1904, "val":"Cd", "y": -78}}, {"665":{"x":1912, "val":"Md", "y":60}}, {"666":{"x":1858, "val":"H", "y":191}}, {"667":{"x": -286, "val":"Cd", "y": -1529}}, {"668":{"x": -34, "val":"Md", "y": -1571}}, {"669":{"x": -2362, "val":"Gc", "y": -61}}, {"670":{"x": -2235, "val":"Bd", "y":28}}, {"671":{"x": -36, "val":"Ir", "y":1704}}, {"672":{"x": -152, "val":"Hd", "y":1621}}, {"673":{"x": -2361, "val":"Gp", "y":93}}, {"674":{"x":559, "val":"Cd", "y": -270}}, {"775":{"x":16063, "val":"S06", "y": -435}}, {"776":{"x":16146, "val":"S13", "y": -66}}, {"777":{"x":16147, "val":"S14", "y": -319}}, {"778":{"x":15331, "val":"A23", "y": -58}}, {"779":{"x":15332, "val":"A29", "y": -320}}, {"780":{"x":15189, "val":"S75", "y":128}}, {"781":{"x":15189, "val":"S72", "y": -374}}, {"782":{"x":16283, "val":"S21", "y":127}}, {"783":{"x":16283, "val":"S10", "y": -376}}, {"784":{"x":15741, "val":"A39", "y":510}}, {"785":{"x":16146, "val":"S16", "y": -197}}, {"786":{"x":16026, "val":"S65", "y":153}}, {"787":{"x":15415, "val":"A28", "y":184}}, {"788":{"x":15415, "val":"S64", "y": -435}}, {"789":{"x":15188, "val":"S74", "y":3}}, {"790":{"x":15577, "val":"A20", "y":409}}, {"791":{"x":15331, "val":"A22", "y":67}}, {"792":{"x":16147, "val":"S15", "y":67}}, {"793":{"x":16283, "val":"S79", "y":2}}, {"794":{"x":15740, "val":"A39", "y": -888}}, {"795":{"x":15824, "val":"S61", "y":520}}, {"796":{"x":15904, "val":"S12", "y":409}}, {"797":{"x":15983, "val":"S04", "y": -548}}, {"798":{"x":15741, "val":"A39", "y":638}}, {"799":{"x":15741, "val":"S62", "y":892}}, {"800":{"x":15557, "val":"S83", "y":637}}, {"801":{"x":15922, "val":"S24", "y":636}}, {"802":{"x":15283, "val":"S82", "y":257}}, {"803":{"x":16195, "val":"S78", "y":250}}, {"804":{"x":15280, "val":"A15", "y": -502}}, {"805":{"x":16157, "val":"S09", "y": -481}}, {"806":{"x":15555, "val":"S70", "y": -883}}, {"807":{"x":15836, "val":"S01", "y": -1006}}, {"808":{"x":15648, "val":"S63", "y":763}}, {"809":{"x":15641, "val":"S69", "y": -1004}}, {"810":{"x":15467, "val":"S77", "y":512}}, {"811":{"x":16011, "val":"S23", "y":511}}, {"812":{"x":15466, "val":"S71", "y": -760}}, {"813":{"x":15921, "val":"S02", "y": -886}}, {"814":{"x":15834, "val":"A12", "y":252}}, {"815":{"x":15985, "val":"S11", "y":295}}, {"816":{"x":15926, "val":"S59", "y":125}}, {"817":{"x":15375, "val":"S76", "y":385}}, {"818":{"x":16102, "val":"S22", "y":382}}, {"819":{"x":15823, "val":"S03", "y": -771}}, {"820":{"x":16011, "val":"S07", "y": -760}}, {"821":{"x":15189, "val":"S81", "y": -122}}, {"822":{"x":15331, "val":"A24", "y": -193}}, {"823":{"x":15741, "val":"A39", "y":763}}, {"824":{"x":15740, "val":"S68", "y": -1141}}, {"825":{"x":15657, "val":"A21", "y":520}}, {"826":{"x":15189, "val":"S73", "y": -251}}, {"827":{"x":16283, "val":"S20", "y": -125}}, {"828":{"x":15833, "val":"S25", "y":762}}, {"829":{"x":15496, "val":"A25", "y": -548}}, {"830":{"x":15460, "val":"A37", "y": -127}}, {"831":{"x":15460, "val":"S54", "y": -255}}, {"832":{"x":15460, "val":"S58", "y":0}}, {"833":{"x":15902, "val":"S05", "y": -660}}, {"834":{"x":16014, "val":"A36", "y": -128}}, {"835":{"x":16014, "val":"S56", "y": -255}}, {"836":{"x":16014, "val":"S60", "y":0}}, {"837":{"x":15374, "val":"S80", "y": -632}}, {"838":{"x":15555, "val":"S53", "y": -382}}, {"839":{"x":15647, "val":"A11", "y": -507}}, {"840":{"x":15550, "val":"S57", "y":124}}, {"841":{"x":15832, "val":"A14", "y": -507}}, {"842":{"x":15925, "val":"S55", "y": -378}}, {"843":{"x":16105, "val":"S08", "y": -626}}, {"844":{"x":15740, "val":"A39", "y": -1012}}, {"845":{"x":15495, "val":"A26", "y":295}}, {"846":{"x":15642, "val":"A13", "y":250}}, {"847":{"x":15575, "val":"A30", "y": -659}}, {"848":{"x":16283, "val":"S17", "y": -251}}, {"849":{"x":15739, "val":"S18", "y": -1309}}, {"850":{"x":15855, "val":"S19", "y": -1169}}, {"854":{"x":15968, "val":"S26", "y": -1033}}, {"856":{"x":16226, "val":"S27", "y": -527}}, {"857":{"x":16114, "val":"S84", "y":209}}, {"859":{"x":16073, "val":"S28", "y": -898}}]};
			
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
			helpfulAdventurer.gildStartBuild = [1, 2, 3, 4, 6, 35];
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
			tripleClick.tooltipFunction = function():Object{ return this.skillTooltip("Clicks " + Math.ceil((5 + (2 * CH2.currentCharacter.getTrait("ExtraMulticlicks"))) * (CH2.currentCharacter.getTrait("Flurry") ? CH2.currentCharacter.hasteRating : 1))  + " times.  Dashing consumes 20% of remaining clicks."); };
			
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
			manaClick.tooltipFunction = function():Object{
				var character:Character = CH2.currentCharacter;
				var manaClickTooltip:String = "Clicks with +100% chance to critical hit";
				var manaClickDamageBonus:Number = 0;
				
				if (character.getTrait("ImprovedManaCrit"))
				{
					manaClickDamageBonus = Math.pow(1.25, character.getTrait("ManaCritDamage")) * (1 + character.criticalChance);
				}
				else
				{
					manaClickDamageBonus = Math.pow(1.25, character.getTrait("ManaCritDamage"));
				}
				
				if (manaClickDamageBonus > 1)
				{
					manaClickTooltip += " and a " + (manaClickDamageBonus * 100).toFixed(0) + "% damage bonus";
				}
				
				return this.skillTooltip(manaClickTooltip + "."); 
			};
			
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
			managize.energyCost = 0;
			managize.consumableOnly = false;
			managize.minimumAscensions = 0;
			managize.effectFunction = managizeEffect;
			managize.ignoresGCD = false;
			managize.maximumRange = 9000;
			managize.minimumRange = 0;
			managize.usesMaxEnergy = false;
			managize.tooltipFunction = function():Object {
				var character:Character = CH2.currentCharacter;
				var duration:Number = 15;
				duration += (15 * (0.2 * character.getTrait("ImprovedEnergize")));
				return this.skillTooltip("Restores " + (character.maxMana * 0.25 / 15).toFixed(2) + " mana  at a cost of " + (120/duration).toFixed(2) + " energy every " + (1 / character.hasteRating).toFixed(2) + " seconds over " + (duration * (1 / character.hasteRating)).toFixed(2) + " seconds."); 
			};
			
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
			
			if (CH2.currentCharacter.gilds > 0 ) 
			{
				CH2.currentCharacter.automatorPoints++;
			}
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
		
		private function addFirstWorldOfGildStone():void
        {
            CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_29", "First World Of Gild", "First world Of Gild", "A stone that can activate when you are on the first world of a gild.", function ():Boolean
            {
                return (CH2.currentCharacter.currentWorldId % CH2.currentCharacter.worldsPerGild == 1); 
            })
        }
        
        private function addNotFirstWorldOfGildStone():void
        {
            CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_30", "Not First World Of Gild", "Not first world Of Gild", "A stone that can activate when you are not on the first world of a gild.", function ():Boolean
            {
                return (CH2.currentCharacter.currentWorldId % CH2.currentCharacter.worldsPerGild != 1);   
            })
        }    
		
		private function addGreaterThanMonsterDistanceStone():void
        {
            CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_31", "Next Monster > 90 cm Away", "Next monster > 90 cm away", "A stone that can activate when the next monster is greater than 90 cm away.", function ():Boolean
            {
			var nextMonster = CH2.world.getNextMonster();
			if ( nextMonster == null)
				{
					return false;
				}
				var nearestMonsterDistance:Number = Math.abs(nextMonster.y - CH2.currentCharacter.y);
				return (nearestMonsterDistance > 90);
            })
        }  

		private function addLessThanMonsterDistanceStone():void
        {
            CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_33", "Next Monster < 90 cm Away", "Next monster < 90 cm away", "A stone that can activate when the next monster is less than 90 cm away.", function ():Boolean
            {
			var nextMonster = CH2.world.getNextMonster();
			if ( nextMonster == null)
				{
					return false;
				}
				var nearestMonsterDistance:Number = Math.abs(nextMonster.y - CH2.currentCharacter.y);
				return (nearestMonsterDistance <= 90);
            })
        }  
		
		private function addNotABossZoneStone():void
        {
            CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_32", "Not A Boss Zone", "Not a boss zone", "A stone that can activate when you are not on a boss zone.", function ():Boolean
            {
				return !CH2.user.isOnBossZone;
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
			CH2.currentCharacter.automator.addStone("BigClicksGTMultiClicks", "Big Clicks > Multiclicks", "Big Clicks > Multiclicks", "A stone that activates if you have more Big Clicks than MultiClick can consume.", bigClicksGTMulticlicks);
		}
		
		public function addBigClicksLTEMultiClicksStone():void
		{
			CH2.currentCharacter.automator.addStone("BigClicksLTEMultiClicks", "Big Clicks <= Multiclicks", "Big Clicks <= Multiclicks", "A stone that activates if your MultiClick would consume all of your Big Clicks.", bigClicksLTEMulticlicks);
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
			var nextQueueIndex:int = CH2.currentCharacter.automator.currentQueueIndex + 1;
			
			if (CH2UI.instance.mainUI && CH2UI.instance.mainUI.mainPanel && CH2UI.instance.mainUI.mainPanel.isOnAutomatorPanel)
			{
				CH2UI.instance.mainUI.mainPanel.automatorPanel.switchQueueSet(nextQueueIndex);
			}
			else
			{
				CH2.currentCharacter.automator.setCurrentQueue(nextQueueIndex);
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
			var previousQueueIndex:int = CH2.currentCharacter.automator.currentQueueIndex - 1;
			
			if (CH2UI.instance.mainUI && CH2UI.instance.mainUI.mainPanel && CH2UI.instance.mainUI.mainPanel.isOnAutomatorPanel)
			{
				CH2UI.instance.mainUI.mainPanel.automatorPanel.switchQueueSet(previousQueueIndex);
			}
			else
			{
				CH2.currentCharacter.automator.setCurrentQueue(previousQueueIndex);
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
			
			character.onKilledMonsterDefault(monster);
		}
		
		public function onTeleportAttackOverride():void
		{
			if (CH2.currentAscensionWorld.traits[WT_SPEED_LIMIT])
			{
				CH2.currentCharacter.addGold(CH2.currentCharacter.gold.multiplyN( -0.2));
			}
			CH2.currentCharacter.onTeleportAttackDefault();
		}
		
		//public function helpfulAdventurerAttack(attackData:AttackData):void
		public function attackOverride(attackData:AttackData):void
		{
			var character:Character = CH2.currentCharacter;
			if (CH2.currentAscensionWorld.traits[WT_ROBUST])
			{
				attackData.critChanceModifier = -100;
			}
			
			if (character.getTrait("LowEnergyDamageBonus") && character.energy < character.maxEnergy * 0.60)
			{
				attackData.damage.timesEqualsN(2);
			}
			
			var monsterHealth:BigNumber = new BigNumber(0);
			
			if (character.getTrait("ManaCritOverflow"))
			{
				var target:Monster = CH2.world.getNextMonster();
				if (target)
				{
					monsterHealth.power = target.health.power;
					monsterHealth.base = target.health.base;
				}
			}
			
			character.attackDefault(attackData);
			
			if (!attackData.isAutoAttack && CH2.currentAscensionWorld.traits[WT_EXHAUSTING])
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
					exhaustion.buffStat(CH2.STAT_HASTE,  0.95);
					exhaustion.tickFunction = function() {
						var currentExhaustion:Buff = CH2.currentCharacter.buffs.getBuff("Exhaustion")
						currentExhaustion.stacks -= 1;
						currentExhaustion.buffStat(CH2.STAT_HASTE, 1 / 0.95 * currentExhaustion.getStatValue(CH2.STAT_HASTE));
					}
					character.buffs.addBuff(exhaustion);
				}
			}
			
			if (attackData.isAutoAttack && attackData.isCritical && character.getTrait("AutoAttackCritMana") && !(character.buffs.hasBuffByName("AutoAttackCritMana")))
			{
				character.addMana(1);
				var buff:Buff = new Buff();
				buff.name = "AutoAttackCritMana";
				buff.iconId = 23;
				buff.isUntimedBuff = false;
				buff.duration = 1000 * Math.pow(0.25, character.getTrait("EtherealJerator"));
				buff.unhastened = true;
						buff.tooltipFunction = function() {
							return {
								"header": "Jerator's Enchantment",
								"body": "Gained 1 mana."
							};
						}
				character.buffs.addBuff(buff);
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
			if (CH2.currentAscensionWorld.traits[WT_INCOME_TAX] && goldToAdd.isPositive)
			{
				goldToAdd.timesEqualsN(1 / CH2.currentCharacter.monsterGoldMultiplier);
			}
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
						attackData.damage = character.clickDamage.multiplyN(Math.abs(amount) * (character.getTrait("EtherealDischarge") + 1));
						attackData.isCritical = false;
						attackData.monster = target;
						target.takeDamage(attackData);
						attackData.isClickAttack = true;
						character.buffs.onAttack(attackData);
					}
				}
			}
			
			if (CH2.currentAscensionWorld.traits[WT_UNSTABLE] && ((character.energy + amount) >= character.maxEnergy))
			{
				amount = -character.energy;
			}
			character.addEnergyDefault(amount, showFloatingText);
		}
		
		public function regenerateManaAndEnergyOverride(time:Number):void
		{
			var character:Character = CH2.currentCharacter;
			
			var timeInSeconds:Number = (time / 1000);
			
			var manaToAdd:Number = timeInSeconds * character.getManaRegenRate();
			if (CH2.currentAscensionWorld.traits[WT_BANAL])
			{
				manaToAdd *= 0.1;
			}
			character.addMana(manaToAdd, false);
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
			var buffClicks:int = 4 + (2 * character.getTrait("ExtraMulticlicks"));
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
				if (!character.isNextMonsterInRange && !character.getTrait("EtherealMultiClick"))
				{
					buff.timeSinceActivated += 0.2 * buff.timeLeft;
					if (buff.timeLeft < buff.timeSinceLastTick) {
						buff.timeSinceLastTick = buff.timeLeft;
					}
				}
				character.clickAttack(false);
			}
			buff.tooltipFunction = function() {
				return {
					"header": "MultiClick",
					"body": "Clicking " + Math.ceil((5 + (2 * CH2.currentCharacter.getTrait("ExtraMulticlicks"))) * (CH2.currentCharacter.getTrait("Flurry") ? CH2.currentCharacter.hasteRating : 1))  + " times, with " + Math.ceil(buff.timeLeft/buff.tickRate) + " remaining. Dashing consumes 20% of remaining clicks."
				};
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
				var costReduction:Number = Math.pow(0.5, character.getTrait("EtherealStorms"));
				character.addEnergy(-(1/3) * costReduction, false);
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
			buff.tickRate = 200;
			buff.tickFunction = function() {
				character.clickAttack(false);
				var costReduction:Number = Math.pow(0.5, character.getTrait("EtherealStorms"));
				character.addEnergy(-0.5 * costReduction, false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
				if (buff.timeLeft <= buff.tickRate) {
					buff.timeSinceActivated = 0;
					tickSpeed *= 2;
					buff.tickRate = 200 / tickSpeed;
				}
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Clickstorm",
					"body": "Clicking " + (5 * tickSpeed * character.hasteRating).toFixed(2) + " times per second. Consuming " + (2.5 * tickSpeed * character.hasteRating).toFixed(2) + " energy per second. Speed increases over time."
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
			buff.tickRate = 200;
			buff.tickFunction = function() {
				buff.buffStat(CH2.STAT_CRIT_CHANCE, CH2.currentCharacter.criticalChance);
				character.clickAttack(false);
				buff.buffStat(CH2.STAT_CRIT_CHANCE, 0);
				var costReduction:Number = Math.pow(0.5, character.getTrait("EtherealStorms"));
				character.addEnergy(-0.5 * costReduction, false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
				if (buff.timeLeft <= buff.tickRate) {
					buff.timeSinceActivated = 0;
					tickSpeed *= 2;
					buff.tickRate = 200 / tickSpeed;
				}
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Critstorm",
					"body": "Clicking " + (5 * tickSpeed * character.hasteRating).toFixed(2) + " times per second with double crit chance. Consuming " + (2.5 * tickSpeed * character.hasteRating).toFixed(2) + " energy per second. Speed increases over time."
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
				var costReduction:Number = Math.pow(0.5, character.getTrait("EtherealStorms"));
				character.addEnergy(-0.5 * costReduction, false);
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
			var buff:Buff = new Buff();
			buff.name = "Managize";
			buff.iconId = 35;
			buff.duration = 15000;
			buff.duration += 15000 * (0.2 * character.getTrait("ImprovedEnergize"));
			buff.tickRate = 1000;
			buff.tickFunction = function () {
				if (character.energy >= 1)
				{
					character.addEnergy(-120*(1000/buff.duration));
					character.addMana(character.maxMana * 0.25 / 15);
				}
			}
			buff.finishFunction = function() {
				removeEnergizeIndicator();
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Managize",
					"body": "Restoring " + (character.maxMana * 0.25 / 15).toFixed(2) + " mana every " + (1 / character.hasteRating).toFixed(2) + " second."
				};
			}
			character.buffs.addBuff(buff);
			addEnergizeIndicator();
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
				buff.attackFunction = function(attackData:AttackData) {
					if (attackData.isClickAttack) {
						
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
								CH2.world.addEffect(effect, CH2.world.roomsFront, attackData.monster.x, attackData.monster.y, World.REMOVE_EFFECT_WHEN_FINISHED, 1, 10);
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
			buff.attackFunction = function(attackData:AttackData) {
				if (attackData.isClickAttack) {
					var effect:GpuMovieClip = getBamplode(Rnd.integer(1,4));
					effect.gotoAndPlay(1);
					effect.isLooping = false;
					CH2.world.addEffect(effect, CH2.world.roomsFront, attackData.monster.x, attackData.monster.y);
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
				buff.tickRate = buff.duration / 60;
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
			buff.attackFunction = function(attackData:AttackData) {
				if (attackData.isClickAttack)
				{
					if (buff.stacks % 20 == 1)
					{
						if (!character.buffs.hasBuffByName("Big Clicks"))
						{
							var effect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(HUGE_CLICK);
							effect.gotoAndPlay(1);
							effect.isLooping = false;
							CH2.world.addEffect(effect, CH2.world.roomsFront, attackData.monster.x, attackData.monster.y);
							Shaker.add(CH2.world.roomsBack, -100, 100, 0.5, 0);
							CH2.world.camera.shake(0.5, -100, 100);
						}
						else
						{
							//This is a Big Click and a Huge Click play the special animation
							var effect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(BIG_GIANT_CLICK);
							effect.gotoAndPlay(1);
							effect.isLooping = false;
							CH2.world.addEffect(effect, CH2.world.roomsFront, attackData.monster.x, attackData.monster.y);
							Shaker.add(CH2.world.roomsBack, -200, 200, 0.5, 0);
							CH2.world.camera.shake(0.5, -200, 200);
						}
						
						if (!attackData.monster.isFinalBoss)
						{
							var crackEffect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(HUGE_CLICK_CRACK);
							crackEffect.gotoAndPlay(1);
							crackEffect.isLooping = false;
							CH2.world.addEffect(crackEffect, CH2.world.roomsBack, attackData.monster.x, attackData.monster.y, World.REMOVE_EFFECT_WHEN_OFFSCREEN);
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
			
			if (character.getTrait("EtherealManaCrit"))
			{
				buff.buffStat(CH2.STAT_CLICK_DAMAGE, buff.getStatValue(CH2.STAT_CLICK_DAMAGE) * 4 * character.getTrait("EtherealManaCrit"));
			}
			else
			{
				buff.buffStat(CH2.STAT_CRIT_CHANCE, 1);
			}
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
				characterInstance.getWorldTraitCountHandler = this;
				characterInstance.applyWorldTraitsHandler = this;
				characterInstance.onTeleportAttackHandler = this;
				characterInstance.populateEtherealItemStatsHandler = this;
				characterInstance.regenerateManaAndEnergyHandler = this;
				
				characterInstance.populateEtherealItemStats();
				createFixedFirstRunCatalogs(FIXED_FIRST_RUN_CATALOG_DATA);
			}
		}
		
		public static var etherealItemStatStats:Array = [];
		public static var etherealItemTraitStats:Object = {};
		public static var etherealItemTraitNames:Array = [
			"ExtraMulticlicks",
			"BigClickStacks",
			"BigClicksDamage",
			"HugeClickDamage",
			"ManaCritDamage",
			"ImprovedEnergize",
			"SustainedPowersurge",
			"ImprovedPowersurge",
			"ImprovedReload"
		];
		
		public function populateEtherealItemStatsOverride(characterInstance:Character):void
		{
            etherealItemStatStats[CH2.STAT_GOLD] = {
                "sourcePower": 3.0612249,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Mammon's",
				"nameSuffix": "of Greed"
            };
            etherealItemStatStats[CH2.STAT_MOVEMENT_SPEED] = {
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "",
				"nameSuffix": "of Swiftness"
            };
            etherealItemStatStats[CH2.STAT_CRIT_CHANCE] = {
                "sourcePower": 7.894736842,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Risen Bhaal's",
				"nameSuffix": "of Rising"
            };
            etherealItemStatStats[CH2.STAT_CRIT_DAMAGE] = {
                "sourcePower": 2.727272727,
                "sourceWeight": 1,
				"destinationPower": 0.5227586989,
                "destinationWeight": 1,
				"namePrefix": "Precise Bhaal's",
				"nameSuffix": "of Precision"
            };
            etherealItemStatStats[CH2.STAT_HASTE] = {
                "sourcePower": 2.586206897,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Vaagur's",
				"nameSuffix": "of Impatience"
            };
            etherealItemStatStats[CH2.STAT_MANA_REGEN] = {
                "sourcePower": 7.142857143,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Graceful Energon's",
				"nameSuffix": "of Grace"
            };
            etherealItemStatStats[CH2.STAT_IDLE_GOLD] = {
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
            etherealItemStatStats[CH2.STAT_IDLE_DAMAGE] = {
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
            etherealItemStatStats[CH2.STAT_CLICKABLE_GOLD] = {
                "sourcePower": 6.52173913,
                "sourceWeight": 1,
				"destinationPower": 0.2350638265,
                "destinationWeight": 1,
				"namePrefix": "Revolc's",
				"nameSuffix": "of Blessings"
            };
            etherealItemStatStats[CH2.STAT_CLICK_DAMAGE] = {
                "sourcePower": 4.166666667,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Fragsworth's",
				"nameSuffix": "of Wrath"
            };
            etherealItemStatStats[CH2.STAT_TREASURE_CHEST_CHANCE] = {
                "sourcePower": 13.63636364,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Favorable Mimzee's",
				"nameSuffix": "of Coffers"
            };
            etherealItemStatStats[CH2.STAT_MONSTER_GOLD] = {
                "sourcePower": 10,
                "sourceWeight": 1,
				"destinationPower": 0.8410066661,
                "destinationWeight": 1,
				"namePrefix": "Kind Mimzee's",
				"nameSuffix": "of Kindness"
            };
            etherealItemStatStats[CH2.STAT_ITEM_COST_REDUCTION] = {
                "sourcePower": 5.555555556,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Dogcog's",
				"nameSuffix": "of Thrift"
            };
            etherealItemStatStats[CH2.STAT_TOTAL_MANA] = {
                "sourcePower": 6.25,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Ionic Energon's",
				"nameSuffix": "of Ions"
            };
            etherealItemStatStats[CH2.STAT_TOTAL_ENERGY] = {
                "sourcePower": 6.52173913,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Juggernaut's",
				"nameSuffix": "of Pittance"
            };
            etherealItemStatStats[CH2.STAT_CLICKABLE_CHANCE] = {
                "sourcePower": 5.172413793,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Iris'",
				"nameSuffix": "of Vision"
            };
            etherealItemStatStats[CH2.STAT_BONUS_GOLD_CHANCE] = {
                "sourcePower": 10,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Fortuna's",
				"nameSuffix": "of Luck"
            };
            etherealItemStatStats[CH2.STAT_TREASURE_CHEST_GOLD] = {
                "sourcePower": 8.823529412,
                "sourceWeight": 1,
				"destinationPower": 0.4271249572,
                "destinationWeight": 1,
				"namePrefix": "Blessed Mimzee's",
				"nameSuffix": "of Treasures"
            };
            etherealItemStatStats[CH2.STAT_PIERCE_CHANCE] = {
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
            etherealItemStatStats[CH2.STAT_ENERGY_REGEN] = {
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
            etherealItemStatStats[CH2.STAT_DAMAGE] = {
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
            etherealItemStatStats[CH2.STAT_ENERGY_COST_REDUCTION] = {
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
            etherealItemStatStats[CH2.STAT_ITEM_WEAPON_DAMAGE] = {
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Fighter's",
				"nameSuffix": "of Arms"
            };
            etherealItemStatStats[CH2.STAT_ITEM_HEAD_DAMAGE] = {
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Milliner's",
				"nameSuffix": "of Skulls"
            };
            etherealItemStatStats[CH2.STAT_ITEM_CHEST_DAMAGE] = {
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Knight's",
				"nameSuffix": "of Armor"
            };
            etherealItemStatStats[CH2.STAT_ITEM_RING_DAMAGE] = {
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Prince's",
				"nameSuffix": "of Jewels"
            };
            etherealItemStatStats[CH2.STAT_ITEM_LEGS_DAMAGE] = {
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Runner's",
				"nameSuffix": "of Limbs"
            };
            etherealItemStatStats[CH2.STAT_ITEM_HANDS_DAMAGE] = {
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Boxer's",
				"nameSuffix": "of Fists"
            };
            etherealItemStatStats[CH2.STAT_ITEM_FEET_DAMAGE] = {
                "sourcePower": 21.42857143,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Kicker's",
				"nameSuffix": "of Toes"
            };
            etherealItemStatStats[CH2.STAT_ITEM_BACK_DAMAGE] = {
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Lurker's",
				"nameSuffix": "of Mantles"
            };
            etherealItemStatStats[CH2.STAT_AUTOMATOR_SPEED] = {
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
			
			etherealItemTraitStats["ExtraMulticlicks"] = {
				"name": "Increased MultiClicks",
				"sourcePower": 5.172413793,
				"sourceWeight": 1,
				"destinationPower": 1,
				"destinationWeight": 1,
				"namePrefix": "Clicker's",
				"nameSuffix": "of Many Clicks"
			};
			etherealItemTraitStats["BigClickStacks"] = {
				"name": "More Big Clicks",
				"sourcePower": 9.375,
				"sourceWeight": 1,
				"destinationPower": 1,
				"destinationWeight": 1,
				"namePrefix": "Stacker's",
				"nameSuffix": "of Stacking Clicks"
			};
			etherealItemTraitStats["BigClicksDamage"] = {
				"name": "Bigger Big Clicks",
				"sourcePower": 2.542372881,
				"sourceWeight": 1,
				"destinationPower": 0.4271249572,
				"destinationWeight": 1,
				"namePrefix": "Big",
				"nameSuffix": "of Magnitude"
			};
			etherealItemTraitStats["HugeClickDamage"] = {
				"name": "Huger Huge Click",
				"sourcePower": 2.727272727,
				"sourceWeight": 1,
				"destinationPower": 0.4271249572,
				"destinationWeight": 1,
				"namePrefix": "Huge",
				"nameSuffix": "of Enormity"
			};
			etherealItemTraitStats["ManaCritDamage"] = {
				"name": "Mana Crit Damage",
				"sourcePower": 4.838709677,
				"sourceWeight": 1,
				"destinationPower": 0.4271249572,
				"destinationWeight": 1,
				"namePrefix": "Critter's",
				"nameSuffix": "of Ionic Precision"
			};
			etherealItemTraitStats["ImprovedEnergize"] = {
				"name": "Improved Energize",
				"sourcePower": 15,
				"sourceWeight": 1,
				"destinationPower": 1,
				"destinationWeight": 1,
				"namePrefix": "Energizer's",
				"nameSuffix": "of Energy"
			};
			etherealItemTraitStats["SustainedPowersurge"] = {
				"name": "Sustained Powersurge",
				"sourcePower": 12.5,
				"sourceWeight": 1,
				"destinationPower": 0.5227586989,
				"destinationWeight": 1,
				"namePrefix": "Sustainer's",
				"nameSuffix": "of Endurance"
			};
			etherealItemTraitStats["ImprovedPowersurge"] = {
				"name": "Improved Powersurge",
				"sourcePower": 15,
				"sourceWeight": 1,
				"destinationPower": 0.4271249572,
				"destinationWeight": 1,
				"namePrefix": "Surger's",
				"nameSuffix": "of Power"
			};
			etherealItemTraitStats["ImprovedReload"] = {
				"name": "Improved Reload",
				"sourcePower": 15,
				"sourceWeight": 1,
				"destinationPower": 1,
				"destinationWeight": 1,
				"namePrefix": "Loader's",
				"nameSuffix": "of Resources"
			};
			
			var etherealItemStats:Object = { };
			for each (var stat:Object in CH2.STATS)
			{
				var sourceStatStats:Object = etherealItemStatStats[stat["id"]];
				if (sourceStatStats["destinationWeight"] > 0)
				{
					//Note: sourceStatStats is actually for the destination stat here, as there is no source stat for this type of item.
					var etherealItemStatChoice:EtherealItemStatChoice = new EtherealItemStatChoice();
					etherealItemStatChoice.id = stat["etherealTraitKey"] + "ForSkillPoints";
					etherealItemStatChoice.key = stat["etherealTraitKey"];
					etherealItemStatChoice.isSpecial = false;
					etherealItemStatChoice.slots = stat["etherealSlots"];
					etherealItemStatChoice.valueFunction = Character.scaleLinearlyWithSkillPoints(characterInstance);
					etherealItemStatChoice.exchangeRateFunction = Character.etherealExchangeRateFunction(0.5 * sourceStatStats["destinationPower"]);
					etherealItemStatChoice.weight = sourceStatStats["destinationWeight"];
					etherealItemStatChoice.tooltipDescriptionFormat = "+%s levels of " + stat["displayName"] + " per skill point acquired";
					etherealItemStatChoice.namePrefix = "Skillful";
					etherealItemStatChoice.nameSuffix = sourceStatStats["nameSuffix"];
					etherealItemStatChoice.params = {
						"destinationId": stat["id"]
					};
					etherealItemStats[etherealItemStatChoice.id] = etherealItemStatChoice;
				}
				
				if (sourceStatStats["sourceWeight"] > 0)
				{
					for each (var destinationStat:Object in CH2.STATS)
					{
						var destinationStatStats:Object = etherealItemStatStats[destinationStat["id"]];
						if (destinationStat["canBeDestinationOfEtherealStat"])
						{
							var etherealItemStatChoice:EtherealItemStatChoice = new EtherealItemStatChoice();
							etherealItemStatChoice.id = destinationStat["etherealTraitKey"] + "ForStatLevelsOfId" + stat["id"];
							etherealItemStatChoice.key = destinationStat["etherealTraitKey"];
							etherealItemStatChoice.isSpecial = false;
							etherealItemStatChoice.slots = destinationStat["etherealSlots"];
							etherealItemStatChoice.valueFunction = Character.scaleLinearlyWithStatLevel(stat["id"], characterInstance);
							etherealItemStatChoice.exchangeRateFunction = Character.etherealExchangeRateFunction(sourceStatStats["sourcePower"] * destinationStatStats["destinationPower"]);
							etherealItemStatChoice.weight = destinationStatStats["destinationWeight"] * sourceStatStats["sourceWeight"];
							etherealItemStatChoice.tooltipDescriptionFormat = "+%s levels of " + destinationStat["displayName"] + " per level of " + stat["displayName"] + " from tree";
							etherealItemStatChoice.namePrefix = sourceStatStats["namePrefix"];
							etherealItemStatChoice.nameSuffix = destinationStatStats["nameSuffix"];
							etherealItemStatChoice.params = {
								"sourceId": stat["id"],
								"destinationId": destinationStat["id"]
							};
							etherealItemStats[etherealItemStatChoice.id] = etherealItemStatChoice;
						}
					}
					
					for each (var destinationTraitName:String in etherealItemTraitNames)
					{
						var destinationTraitStats:Object = etherealItemTraitStats[destinationTraitName];
						var etherealItemStatChoice:EtherealItemStatChoice = new EtherealItemStatChoice();
						etherealItemStatChoice.id = destinationTraitName + "ForStatLevelsOfId" + stat["id"];
						etherealItemStatChoice.key = destinationTraitName;
						etherealItemStatChoice.isSpecial = false;
						etherealItemStatChoice.slots = [0, 1, 2, 3, 4, 5, 6, 7];
						etherealItemStatChoice.valueFunction = Character.scaleLinearlyWithStatLevel(stat["id"], characterInstance);
						etherealItemStatChoice.exchangeRateFunction = Character.etherealExchangeRateFunction(sourceStatStats["sourcePower"] * destinationTraitStats["destinationPower"]);
						etherealItemStatChoice.weight = destinationTraitStats["destinationWeight"] * sourceStatStats["sourceWeight"];
						etherealItemStatChoice.tooltipDescriptionFormat = "+%s levels of " + destinationTraitStats["name"] + " per level of " + stat["displayName"] + " from tree";
						etherealItemStatChoice.namePrefix = sourceStatStats["namePrefix"];
						etherealItemStatChoice.nameSuffix = destinationTraitStats["nameSuffix"];
						etherealItemStatChoice.params = {
							"sourceId": stat["id"],
							"destinationId": destinationTraitName
						};
						etherealItemStats[etherealItemStatChoice.id] = etherealItemStatChoice;
					}
				}
			}
			
			for each (var sourceTraitName:String in etherealItemTraitNames)
			{
				var sourceTraitStats:Object = etherealItemTraitStats[sourceTraitName];
				if (sourceTraitStats["destinationWeight"] > 0)
				{
					// Note: sourceTraitStats is for the destination trait here.
					var etherealItemStatChoice:EtherealItemStatChoice = new EtherealItemStatChoice();
					etherealItemStatChoice.id = sourceTraitName + "ForSkillPoints";
					etherealItemStatChoice.key = sourceTraitName;
					etherealItemStatChoice.isSpecial = false;
					etherealItemStatChoice.slots = [0, 1, 2, 3, 4, 5, 6, 7];
					etherealItemStatChoice.valueFunction = Character.scaleLinearlyWithSkillPoints(characterInstance);
					etherealItemStatChoice.exchangeRateFunction = Character.etherealExchangeRateFunction(0.5 * sourceTraitStats["destinationPower"]);
					etherealItemStatChoice.weight = sourceTraitStats["destinationWeight"];
					etherealItemStatChoice.tooltipDescriptionFormat = "+%s levels of " + sourceTraitStats["name"] + " per skill point acquired";
					etherealItemStatChoice.namePrefix = "Skillful";
					etherealItemStatChoice.nameSuffix = sourceTraitStats["nameSuffix"];
					etherealItemStatChoice.params = {
						"destinationId": sourceTraitName
					};
					etherealItemStats[etherealItemStatChoice.id] = etherealItemStatChoice;
				}
				
				if (sourceTraitStats["sourceWeight"] > 0)
				{
					for each (var destinationStat:Object in CH2.STATS)
					{
						var destinationStatStats:Object = etherealItemStatStats[destinationStat["id"]];
						if (destinationStat["canBeDestinationOfEtherealStat"])
						{
							var etherealItemStatChoice:EtherealItemStatChoice = new EtherealItemStatChoice();
							etherealItemStatChoice.id = destinationStat["etherealTraitKey"] + "ForTraitLevelsOf" + sourceTraitName;
							etherealItemStatChoice.key = destinationStat["etherealTraitKey"];
							etherealItemStatChoice.isSpecial = false;
							etherealItemStatChoice.slots = destinationStat["etherealSlots"];
							etherealItemStatChoice.valueFunction = Character.scaleLinearlyWithTraitLevel("Tree" + sourceTraitName, characterInstance);
							etherealItemStatChoice.exchangeRateFunction = Character.etherealExchangeRateFunction(sourceTraitStats["sourcePower"] * destinationStatStats["destinationPower"]);
							etherealItemStatChoice.weight = destinationStatStats["destinationWeight"] * sourceTraitStats["sourceWeight"];
							etherealItemStatChoice.tooltipDescriptionFormat = "+%s levels of " + destinationStat["displayName"] + " per level of " + sourceTraitStats["name"] + " from tree";
							etherealItemStatChoice.namePrefix = sourceTraitStats["namePrefix"];
							etherealItemStatChoice.nameSuffix = destinationStatStats["nameSuffix"];
							etherealItemStatChoice.params = {
								"sourceId": sourceTraitName,
								"destinationId": destinationStat["id"]
							};
							etherealItemStats[etherealItemStatChoice.id] = etherealItemStatChoice;
						}
					}
					
					for each (var destinationTraitName:String in etherealItemTraitNames)
					{
						var destinationTraitStats:Object = etherealItemTraitStats[destinationTraitName];
						var etherealItemStatChoice:EtherealItemStatChoice = new EtherealItemStatChoice();
						etherealItemStatChoice.id = destinationTraitName + "ForStatLevelsOf" + sourceTraitName;
						etherealItemStatChoice.key = destinationTraitName;
						etherealItemStatChoice.isSpecial = false;
						etherealItemStatChoice.slots = [0, 1, 2, 3, 4, 5, 6, 7];
						etherealItemStatChoice.valueFunction = Character.scaleLinearlyWithTraitLevel("Tree" + sourceTraitName, characterInstance);
						etherealItemStatChoice.exchangeRateFunction = Character.etherealExchangeRateFunction(sourceTraitStats["sourcePower"] * destinationTraitStats["destinationPower"]);
						etherealItemStatChoice.weight = destinationTraitStats["destinationWeight"] * sourceTraitStats["sourceWeight"];
						etherealItemStatChoice.tooltipDescriptionFormat = "+%s levels of " + destinationTraitStats["name"] + " per level of " + sourceTraitStats["name"] + " from tree";
						etherealItemStatChoice.namePrefix = sourceTraitStats["namePrefix"];
						etherealItemStatChoice.nameSuffix = destinationTraitStats["nameSuffix"];
						etherealItemStatChoice.params = {
							"sourceId": sourceTraitName,
							"destinationId": destinationTraitName
						};
						etherealItemStats[etherealItemStatChoice.id] = etherealItemStatChoice;
					}
				}
			}
			
			// special ethereal items
			var etherealItemSpecialChoices:Object = { };
			var allSlots:Array = [0, 1, 2, 3, 4, 5, 6, 7];
			
			var etherealMulticlickSpecial:EtherealItemStatChoice = new EtherealItemStatChoice();
			etherealMulticlickSpecial.id = "EtherealMultiClick";
			etherealMulticlickSpecial.key = "EtherealMultiClick";
			etherealMulticlickSpecial.isSpecial = true;
			etherealMulticlickSpecial.slots = allSlots;
			etherealMulticlickSpecial.valueFunction = Character.one();
			etherealMulticlickSpecial.exchangeRateFunction = Character.one();
			etherealMulticlickSpecial.weight = 1;
			etherealMulticlickSpecial.tooltipDescriptionFormat = "Equip: Removes dash penalty from MultiClick.";
			etherealMulticlickSpecial.namePrefix = "Dashing";
			etherealMulticlickSpecial.nameSuffix = "";
			etherealMulticlickSpecial.params = {};
			etherealItemStats[etherealMulticlickSpecial.id] = etherealMulticlickSpecial;
			
			var etherealManaCritSpecial:EtherealItemStatChoice = new EtherealItemStatChoice();
			etherealManaCritSpecial.id = "EtherealManaCrit";
			etherealManaCritSpecial.key = "EtherealManaCrit";
			etherealManaCritSpecial.isSpecial = true;
			etherealManaCritSpecial.slots = allSlots;
			etherealManaCritSpecial.valueFunction = Character.one();
			etherealManaCritSpecial.exchangeRateFunction = Character.one();
			etherealManaCritSpecial.weight = 1;
			etherealManaCritSpecial.tooltipDescriptionFormat = "Equip: Replaces Mana Crit's guaranteed crit chance with a damage bonus.";
			etherealManaCritSpecial.namePrefix = "Damaging";
			etherealManaCritSpecial.nameSuffix = "";
			etherealManaCritSpecial.params = {};
			etherealItemStats[etherealManaCritSpecial.id] = etherealManaCritSpecial;
			
			var etherealMonsterLevelsSpecial:EtherealItemStatChoice = new EtherealItemStatChoice();
			etherealMonsterLevelsSpecial.id = "EtherealMonsterLevels";
			etherealMonsterLevelsSpecial.key = "EtherealMonsterLevels";
			etherealMonsterLevelsSpecial.isSpecial = true;
			etherealMonsterLevelsSpecial.slots = allSlots;
			etherealMonsterLevelsSpecial.valueFunction = Character.one();
			etherealMonsterLevelsSpecial.exchangeRateFunction = Character.one();
			etherealMonsterLevelsSpecial.weight = 1;
			etherealMonsterLevelsSpecial.tooltipDescriptionFormat = "Equip: Monsters count as higher level when awarding experience.";
			etherealMonsterLevelsSpecial.namePrefix = "Rewarding";
			etherealMonsterLevelsSpecial.nameSuffix = "";
			etherealMonsterLevelsSpecial.params = {};
			etherealItemStats[etherealMonsterLevelsSpecial.id] = etherealMonsterLevelsSpecial;
			
			var etherealStormsSpecial:EtherealItemStatChoice = new EtherealItemStatChoice();
			etherealStormsSpecial.id = "EtherealStorms";
			etherealStormsSpecial.key = "EtherealStorms";
			etherealStormsSpecial.isSpecial = true;
			etherealStormsSpecial.slots = allSlots;
			etherealStormsSpecial.valueFunction = Character.one();
			etherealStormsSpecial.exchangeRateFunction = Character.one();
			etherealStormsSpecial.weight = 1;
			etherealStormsSpecial.tooltipDescriptionFormat = "Equip: Reduces energy cost of Storms.";
			etherealStormsSpecial.namePrefix = "Storming";
			etherealStormsSpecial.nameSuffix = "";
			etherealStormsSpecial.params = {};
			etherealItemStats[etherealStormsSpecial.id] = etherealStormsSpecial;
			
			var etherealJeratorSpecial:EtherealItemStatChoice = new EtherealItemStatChoice();
			etherealJeratorSpecial.id = "EtherealJerator";
			etherealJeratorSpecial.key = "EtherealJerator";
			etherealJeratorSpecial.isSpecial = true;
			etherealJeratorSpecial.slots = allSlots;
			etherealJeratorSpecial.valueFunction = Character.one();
			etherealJeratorSpecial.exchangeRateFunction = Character.one();
			etherealJeratorSpecial.weight = 1;
			etherealJeratorSpecial.tooltipDescriptionFormat = "Equip: Reduces internal cooldown on Jerator's Enchantment";
			etherealJeratorSpecial.namePrefix = "Cooling";
			etherealJeratorSpecial.nameSuffix = "";
			etherealJeratorSpecial.params = {};
			etherealItemStats[etherealJeratorSpecial.id] = etherealJeratorSpecial;
			
			var etherealDischargeSpecial:EtherealItemStatChoice = new EtherealItemStatChoice();
			etherealDischargeSpecial.id = "EtherealDischarge";
			etherealDischargeSpecial.key = "EtherealDischarge";
			etherealDischargeSpecial.isSpecial = true;
			etherealDischargeSpecial.slots = allSlots;
			etherealDischargeSpecial.valueFunction = Character.one();
			etherealDischargeSpecial.exchangeRateFunction = Character.one();
			etherealDischargeSpecial.weight = 1;
			etherealDischargeSpecial.tooltipDescriptionFormat = "Equip: Increases Discharge damage.";
			etherealDischargeSpecial.namePrefix = "Discharging";
			etherealDischargeSpecial.nameSuffix = "";
			etherealDischargeSpecial.params = {};
			etherealItemStats[etherealDischargeSpecial.id] = etherealDischargeSpecial;
			
			var etherealRyanSpecial:EtherealItemStatChoice = new EtherealItemStatChoice();
			etherealRyanSpecial.id = "EtherealRyan";
			etherealRyanSpecial.key = "EtherealRyan";
			etherealRyanSpecial.isSpecial = true;
			etherealRyanSpecial.slots = allSlots;
			etherealRyanSpecial.valueFunction = Character.one();
			etherealRyanSpecial.exchangeRateFunction = Character.one();
			etherealRyanSpecial.weight = 1 ^ 1;
			etherealRyanSpecial.tooltipDescriptionFormat = "Equip: Confuse the hell out of Ryan for a couple minutes.";
			etherealRyanSpecial.namePrefix = "Confusing";
			etherealRyanSpecial.nameSuffix = "";
			etherealRyanSpecial.params = {};
			etherealItemStats[etherealRyanSpecial.id] = etherealRyanSpecial;
			
			characterInstance.etherealItemStats = etherealItemStats;
		}
		
		public function statForSkillPointsTooltip(statChocie:EtherealItemStat):String
		{
			return _("+x% %s per skill point acquired.");
		}
		
		public function statForStatLevelsOfIdTooltip(statChocie:EtherealItemStat):String
		{
			return _("+x% %s per %s node purchased.");
		}
		
		public function onMigrationOverride(characterInstance:Character):void
		{
			CH2.currentCharacter = characterInstance;
			
			// 0.09
			if (characterInstance.version <= 8)
			{
				if (characterInstance.gilds > 0)
				{
					var firstWorldOfGild:Number = Math.floor((characterInstance.highestWorldCompleted + 1) / characterInstance.worldsPerGild) * characterInstance.worldsPerGild + 1;
					var levelDiff:Number = characterInstance.level - ((firstWorldOfGild) * 5 + 6);
					characterInstance.statLevels[CH2.STAT_DAMAGE] = 0;
					characterInstance.levelUpStat(CH2.STAT_DAMAGE, levelDiff);
				}
			}
			
			if (characterInstance.version <= 7)
			{
				if (characterInstance.gilds > 0)
				{
					var firstWorldOfGild:Number = Math.floor((characterInstance.highestWorldCompleted + 1) / characterInstance.worldsPerGild) * characterInstance.worldsPerGild + 1;
					characterInstance.setGildBonus(firstWorldOfGild);
				}
			}
			
			if (characterInstance.version <= 6)
			{
				var highestWorld:int = characterInstance.highestWorldCompleted;
				var highestEtherealItem:int = characterInstance.highestEtherealItemAcquired;
				var worldsPerGild:int = characterInstance.worldsPerGild;
				if (highestWorld != highestEtherealItem)
				{
					for (var i:int = highestWorld; (i > highestEtherealItem) && (i >= highestWorld - 40); i--)
					{
						characterInstance.addEtherealItemToInventory(characterInstance.rollEtherealItem(Math.floor((i + 1) / worldsPerGild)));
						characterInstance.addEtherealItemToInventory(characterInstance.rollEtherealItem(Math.floor((i + 1) / worldsPerGild)));
					}
					characterInstance.highestEtherealItemAcquired = highestWorld;
				}
			}
			
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
			
			CH2.currentCharacter = null;
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
		
		public function applyWorldTraitsOverride(worldNumber:Number):void
		{
			var character:Character = CH2.currentCharacter;
			var world:AscensionWorld = character.worlds.getWorld(worldNumber);
			if (world.traits[WT_GARGANTUAN] && !world.traits[WT_UNDERFED])
			{
				character.monstersPerZone = 5;
				character.monsterHealthMultiplier = 10;
			}
			else if (world.traits[WT_UNDERFED] && !world.traits[WT_GARGANTUAN])
			{
				character.monstersPerZone = 200;
				character.monsterHealthMultiplier = 0.25;
			}
			else
			{
				character.monstersPerZone = 50;
				character.monsterHealthMultiplier = 1;
			}
		}
		
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
			var character:Character = CH2.currentCharacter;
			if (character.isRubyShopAvailable())
			{
				var canPurchase:Boolean = false;
				for (var i:int = 0; i < character.currentRubyShop.length; i++)
				{
					var currentPurchaseId:String = character.currentRubyShop[i].id;
					var rubyPurchase:RubyPurchase = character.getRubyPurchaseInstance(currentPurchaseId);
					if (currentPurchaseId == "zoneMetalDetector" || currentPurchaseId == "timeMetalDetector")
					{
						var rubyPurchasePrice:Number = rubyPurchase.price;
						canPurchase = canPurchase || (character.rubies >= rubyPurchasePrice && rubyPurchase.canPurchase());
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
			var character:Character = CH2.currentCharacter;
			if (character.isRubyShopAvailable())
			{
				var canPurchase:Boolean = false;
				for (var i:int = 0; i < character.currentRubyShop.length; i++)
				{
					var currentPurchaseId:String = character.currentRubyShop[i].id;
					var rubyPurchase:RubyPurchase = character.getRubyPurchaseInstance(currentPurchaseId);
					if (currentPurchaseId == "luckRunePurchase" || currentPurchaseId == "speedRunePurchase" || currentPurchaseId == "powerRunePurchase")
					{
						var rubyPurchasePrice:Number = character.currentRubyShop[i].price;
						canPurchase = canPurchase || (character.rubies >= rubyPurchasePrice && rubyPurchase.canPurchase());
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
				CH2UI.instance.mainUI.mainPanel.automatorPanel.switchQueueSet(queueSet);
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
			var character:Character = CH2.currentCharacter;
			if (character.isRubyShopAvailable())
			{
				var madePurchase:Boolean = false;
				for (var i:int = 0; i < character.currentRubyShop.length; i++)
				{
					var currentPurchaseId:String = character.currentRubyShop[i].id;
					var rubyPurchase:RubyPurchase = character.getRubyPurchaseInstance(currentPurchaseId);
					if (currentPurchaseId == "zoneMetalDetector" || currentPurchaseId == "timeMetalDetector")
					{
						CH2UI.instance.mainUI.rightPanel.currentPanel.doPurchase(rubyPurchase);
						madePurchase = true;
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
				for (var i:int = 0; i < character.currentRubyShop.length; i++)
				{
					var currentPurchaseId:String = character.currentRubyShop[i].id;
					var rubyPurchase:RubyPurchase = character.getRubyPurchaseInstance(currentPurchaseId);
					if (currentPurchaseId == "luckRunePurchase" || currentPurchaseId == "speedRunePurchase" || currentPurchaseId == "powerRunePurchase")
					{
						CH2UI.instance.mainUI.rightPanel.currentPanel.doPurchase(rubyPurchase);
						madePurchase = true;
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
			automatorPointPurchase.id = "automatorPointPurchase";
			automatorPointPurchase.priority = 1;
			automatorPointPurchase.name = "Automator Point";
			automatorPointPurchase.price = 100;
			automatorPointPurchase.iconId = 8;
			automatorPointPurchase.getDescription = character.getAutomatorPointDescription;
			automatorPointPurchase.getSoldOutText = character.getDefaultSoldOutText;
			automatorPointPurchase.onPurchase = character.onAutomatorPointPurchase;
			automatorPointPurchase.canAppear = character.canAutomatorPointAppear;
			automatorPointPurchase.canPurchase = character.canPurchaseAutomatorPoint;
			character.rubyPurchaseOptions.push(automatorPointPurchase);
		}
		
		public function getWorldTraitCountOverride(worldNumber:int):int
		{
			var worldsPerGild:int = CH2.currentCharacter.worldsPerGild;
			
			if (worldNumber > worldsPerGild * 20)
			{
				return 3;
			}
			else if (worldNumber > worldsPerGild * 10)
			{
				return 2;
			}
			else if (worldNumber > worldsPerGild)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		
		public function getAddStatTooltipFunction(stat:int, level:int):Function
		{
			return function():String
			{
				if (CH2.currentCharacter.etherealItemInventory.length > 0) 
				{
					var etherealBonusInfo:String = "";
					var equippedEtherealItems:Object = CH2.currentCharacter.equippedEtherealItems;
					
					for (var i = 0; i < 8; i++)
					{
						if (equippedEtherealItems[i] != -1)
						{
							var etherealItem:EtherealItem = CH2.currentCharacter.etherealItemInventory[equippedEtherealItems[i]];
							for (var j = 0; j < etherealItem.stats.length; j++)
							{
								var params:Object = CH2.currentCharacter.getEtherealStatParams(etherealItem.stats[j].id);
								if (params.hasOwnProperty("destinationId") && params.hasOwnProperty("sourceId"))
								{
									if (params["sourceId"] == stat)
									{
										var levels:Number = etherealItem.stats[j].calculatedExchangeRate * level;
										
										if (params["destinationId"] is String)
										{
											var destinationId:String = params["destinationId"];
											etherealBonusInfo += "\n+" + (etherealItem.stats[j].calculatedExchangeRate * level).toFixed(2) + " Levels of " + etherealItemTraitStats[destinationId].name + " from Ethereal " + Item.SLOT_NAMES[i];
											
											var traitValueDescriptionFormat:String = helpfulAdventurer.etherealTraitTooltipInfo[destinationId]["tooltipFormat"];
											var traitValueFunction:Function = helpfulAdventurer.etherealTraitTooltipInfo[destinationId]["valueFunction"];
											var traitValue:Number = traitValueFunction(levels);
											etherealBonusInfo += " (" + _(traitValueDescriptionFormat, traitValue.toFixed(2)) + ").";
										}
										else
										{
											var destinationIntId:int = params["destinationId"];
											var valueFunction:Function = CH2.currentCharacter.statValueFunctions[destinationIntId];
											
											etherealBonusInfo += "\n+" + levels.toFixed(2) + " Levels of " + CH2.STATS[destinationIntId].displayName + " from Ethereal " + Item.SLOT_NAMES[i];
											
											if (destinationIntId == CH2.STAT_TOTAL_ENERGY || destinationIntId == CH2.STAT_TOTAL_MANA) 
											{
												etherealBonusInfo += " (+" + valueFunction(levels).toFixed(2) + " " + CH2.STATS[destinationIntId].displayName + ")";
											}
											else if (destinationIntId == CH2.STAT_TREASURE_CHEST_CHANCE || destinationIntId == CH2.STAT_BONUS_GOLD_CHANCE || destinationIntId == CH2.STAT_CRIT_CHANCE)
											{
												etherealBonusInfo += " (+" + (valueFunction(levels) * 100).toFixed(2) + "% " + CH2.STATS[destinationIntId].displayName + ")";
											}
											else
											{
												etherealBonusInfo += " (" + valueFunction(levels).toFixed(2) + "x " + CH2.STATS[destinationIntId].displayName + ")";
											}
										}
									}
								}
							}
						}
					}
					
					if (etherealBonusInfo != "")
					{
						return StringFormatter.colorize("\n\nEthereal Item Bonus:", "#FFFF00") + etherealBonusInfo;
					}
				}
				return null;
			}
		}
			
		public function getAddTraitTooltipFunction(trait:String, level:int):Function
		{
			return function():String
			{
				if (CH2.currentCharacter.etherealItemInventory.length > 0) 
				{
					var etherealBonusInfo:String = "";
					var equippedEtherealItems:Object = CH2.currentCharacter.equippedEtherealItems;
					
					for (var i = 0; i < 8; i++)
					{
						if (equippedEtherealItems[i] != -1)
						{
							var etherealItem:EtherealItem = CH2.currentCharacter.etherealItemInventory[equippedEtherealItems[i]];
							for (var j = 0; j < etherealItem.stats.length; j++)
							{
								var params:Object = CH2.currentCharacter.getEtherealStatParams(etherealItem.stats[j].id);
								if (params.hasOwnProperty("destinationId") && params.hasOwnProperty("sourceId"))
								{
									if (params["sourceId"] == trait)
									{
										var levels:Number = etherealItem.stats[j].calculatedExchangeRate * level;
										
										if (params["destinationId"] is String)
										{
											var destinationId:String = params["destinationId"];
											etherealBonusInfo += "\n+" + levels.toFixed(2) + " Levels of " + etherealItemTraitStats[destinationId].name + " from Ethereal " + Item.SLOT_NAMES[i];
											
											var traitValueDescriptionFormat:String = helpfulAdventurer.etherealTraitTooltipInfo[destinationId]["tooltipFormat"];
											var traitValueFunction:Function = helpfulAdventurer.etherealTraitTooltipInfo[destinationId]["valueFunction"];
											var traitValue:Number = traitValueFunction(levels);
											etherealBonusInfo += " (" + _(traitValueDescriptionFormat, traitValue.toFixed(2)) + ").";
										}
										else
										{
											var destinationIntId:int = params["destinationId"];
											var valueFunction:Function = CH2.currentCharacter.statValueFunctions[destinationIntId];
											
											etherealBonusInfo += "\n+" + levels.toFixed(2) + " Levels of " + CH2.STATS[destinationIntId].displayName + " from Ethereal " + Item.SLOT_NAMES[i];
											
											if (destinationIntId == CH2.STAT_TOTAL_ENERGY || destinationIntId == CH2.STAT_TOTAL_MANA) 
											{
												etherealBonusInfo += " (+" + valueFunction(levels).toFixed(2) + " " + CH2.STATS[destinationIntId].displayName + ")";
											}
											else if (destinationIntId == CH2.STAT_TREASURE_CHEST_CHANCE || destinationIntId == CH2.STAT_BONUS_GOLD_CHANCE || destinationIntId == CH2.STAT_CRIT_CHANCE)
											{
												etherealBonusInfo += " (+" + (valueFunction(levels) * 100).toFixed(2) + "% " + CH2.STATS[destinationIntId].displayName + ")";
											}
											else
											{
												etherealBonusInfo += " (" + valueFunction(levels).toFixed(2) + "x " + CH2.STATS[destinationIntId].displayName + ")";
											}
										}
									}
								}
							}
						}
					}
					
					if (etherealBonusInfo != "")
					{
						return StringFormatter.colorize("\n\nEthereal Item Bonus:", "#FFFF00") + etherealBonusInfo;
					}
				}
				return null;
			}
		}
	}
}