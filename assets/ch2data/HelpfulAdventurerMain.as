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

	public dynamic class HelpfulAdventurerMain extends Sprite
	{
		public static var CHARACTER_NAME:String = "Helpful Adventurer";
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
		
		public static const HUGE_CLICK:String = "_hugeClick";
		public static const BIG_CLICK:String = "_bigClicks";
		public static const BIG_GIANT_CLICK:String = "_bigGiantClick";
		public static const HUGE_CLICK_CRACK:String = "_hugeClickCrack";
		public static const BUFF_INDICATOR:String = "_indicator";
		public static const ENERGY_CHARGE:String = "_energyCharge";
		
		// World Trait IDs
		
		//Actual
		//public static const WT_ROBUST:int = 0;
		//public static const WT_EXHAUSTING:int = 1;
		//public static const WT_BANAL:int = 2;
		//public static const WT_GARGANTUAN:int = 3;
		//public static const WT_UNDERFED:int = 4;
		//public static const WT_UNSTABLE:int = 5;
		//public static const WT_INCOME_TAX:int = 6;
		//public static const WT_SPEED_LIMIT:int = 7;
		
		//Disabled
		public static const WT_ROBUST:int = 999;
		public static const WT_EXHAUSTING:int = 999;
		public static const WT_BANAL:int = 999;
		public static const WT_GARGANTUAN:int = 999;
		public static const WT_UNDERFED:int = 999;
		public static const WT_UNSTABLE:int = 999;
		public static const WT_INCOME_TAX:int = 999;
		public static const WT_SPEED_LIMIT:int = 999;
		
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
		public static const CLICKSTORM_TOOLTIP:String = "Storm: Consumes 2.5 energy per second to click 5 times per second, until you run out of energy.";
		public static const CRITSTORM_TOOLTIP:String = "Storm: Consumes 2.5 energy per second to click 5 times per second, until you run out of energy. Clicks from this skill have double chance of being critical strikes.";
		public static const GOLDENCLICKS_TOOLTIP:String = "Storm: Consumes 1.25 energy per second to click 2.5 times per second, until you run out of energy. Doubles gold gained while active.";
		public static const CLICKTORRENT_TOOLTIP:String = "Storm: Consumes 10 energy per second to click 30 times per second, until you run out of energy.";
		public static const AUTOATTACKSTORM_TOOLTIP:String = "Storm: Consumes 2.5 mana per second to auto attack 5 times per second, until you run out of mana.  These attacks generate 1 extra energy. Autoattack damage is doubled while active.";
		
		public static const FIXED_FIRST_RUN_CATALOG_DATA:Array = [
			[
				[
					{
						"id": CH2.STAT_TOTAL_ENERGY,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": CH2.STAT_CLICK_DAMAGE,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": CH2.STAT_GOLD,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": CH2.STAT_CRIT_DAMAGE,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": CH2.STAT_TREASURE_CHEST_GOLD,
						"level": 1
					}
				],
				[
					{
						"id": CH2.STAT_TOTAL_MANA,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": CH2.STAT_HASTE,
						"level": 1
					}
				],
				[
					{
						"id": CH2.STAT_MONSTER_GOLD,
						"level": 1
					}
				]
			],
			[
				[
					{
						"id": CH2.STAT_CLICKABLE_GOLD,
						"level": 1
					}
				],
				[
					{
						"id": CH2.STAT_CLICK_DAMAGE,
						"level": 1
					}
				],
				[
					{
						"id": CH2.STAT_MANA_REGEN,
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
			
			//helpfulAdventurer.systemTraits[WT_ROBUST] = {
				//"name": "Robust",
				//"description": "Critical hit chance reduced by 100%."
			//};
			//helpfulAdventurer.systemTraits[WT_EXHAUSTING] = {
				//"name": "Exhausting",
				//"description": "Attacking temporarily reduces your haste."
			//};
			//helpfulAdventurer.systemTraits[WT_BANAL] = {
				//"name": "Banal",
				//"description": "Mana regenerates at 10% the normal rate."
			//};
			//helpfulAdventurer.systemTraits[WT_GARGANTUAN] = {
				//"name": "Gargantuan",
				//"description": "Five heckin' chonkers per zone."
			//};
			//helpfulAdventurer.systemTraits[WT_UNDERFED] = {
				//"name": "Underfed",
				//"description": "Lots of itty bitties."
			//};
			//helpfulAdventurer.systemTraits[WT_UNSTABLE] = {
				//"name": "Unstable",
				//"description": "All energy is lost upon reaching maximum energy."
			//};
			//helpfulAdventurer.systemTraits[WT_INCOME_TAX] = {
				//"name": "Income Tax",
				//"description": "An aggressive tax structure that scales with multipliers to monster gold."
			//};
			//helpfulAdventurer.systemTraits[WT_SPEED_LIMIT] = {
				//"name": "Speed Limit",
				//"description": "Fines will be issued for dashing."
			//};
			
			helpfulAdventurer.hardcodedSystemTraits = {
				//"2": {
					//"traitIDs": [WT_UNDERFED]
				//},
				//"3": {
					//"traitIDs": [WT_UNSTABLE]
				//},
				"2": {
					"traitIDs": [WT_ROBUST]
				},
				"3": {
					"traitIDs": [WT_EXHAUSTING]
				},
				"4": {
					"traitIDs": [WT_GARGANTUAN]
				}
			};
			
			helpfulAdventurer.traitTooltipInfo = {
				"BigClicksDamage": {
					"tooltipFormat": "Increases the damage done by Big Clicks by %s%.",
					"valueFunction": function(levels:Number):Number {
						return (0.05 * levels * 100).toFixed(2);
					}
				},
				"HugeClickDamage": {
					"tooltipFormat": "Increases the damage done by Huge Click by %s%.",
					"valueFunction": function(levels:Number):Number {
						return (0.05 * levels * 100).toFixed(2);
					}
				},
				"ManaCritDamage": {
					"tooltipFormat": "Increases the damage of Mana Crit by %s%.",
					"valueFunction": function(levels:Number):Number {
						return (0.05 * levels * 100).toFixed(2);
					}
				},
				"ImprovedEnergize": {
					"tooltipFormat": "Increases the duration of Energize by %s% of its original duration.",
					"valueFunction": function(levels:Number):Number {
						return (0.10 * levels * 100).toFixed(2);
					}
				},
				"SustainedPowersurge": {
					"tooltipFormat": "Increases the duration of Powersurge by %s%.",
					"valueFunction": function(levels:Number):Number {
						return (0.05 * levels * 100).toFixed(2);
					}
				},
				"ImprovedPowersurge": {
					"tooltipFormat": "Increases the damage bonus of Powersurge by %s%.",
					"valueFunction": function(levels:Number):Number {
						return (0.05 * levels * 100).toFixed(2);
					}
				}
				// ImprovedReload = getImprovedReloadTooltip()
			}
			
			
			helpfulAdventurer.etherealTraitTooltipInfo = {
				"ExtraMulticlicks": {
					"tooltipFormat": "+%s clicks to your MultiClick",
					"valueFunction": function(levels:Number):Number {
						return levels;
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
						return 100 * Math.pow(1.10, levels);
					}
				},
				"HugeClickDamage": {
					"tooltipFormat": "x%s% damage done by Huge Click",
					"valueFunction": function(levels:Number):Number {
						return 100 * Math.pow(1.10, levels);
					}
				},
				"ManaCritDamage": {
					"tooltipFormat": "x%s% damage of Mana Crit",
					"valueFunction": function(levels:Number):Number {
						return 100 * Math.pow(1.25, levels);
					}
				},
				"ImprovedEnergize": {
					"tooltipFormat": "+%s% duration of Energize",
					"valueFunction": function(levels:Number):Number {
						return 100 * 0.2 * levels;
					}
				},
				"SustainedPowersurge": {
					"tooltipFormat": "x%s% duration of Powersurge",
					"valueFunction": function(levels:Number):Number {
						return 100 * Math.pow(1.1, levels);
					}
				},
				"ImprovedPowersurge": {
					"tooltipFormat": "x%s% damage bonus of Powersurge",
					"valueFunction": function(levels:Number):Number {
						return 100 * Math.pow(1.10, levels);
					}
				},
				"ImprovedReload": {
					"tooltipFormat": "+%s% Reload effect",
					"valueFunction": function(levels:Number):Number {
						return 100 * 0.5 * levels;
					}
				}
			}
			
			helpfulAdventurer.levelGraphNodeTypes = {
				"G": { 
					"name": "Gold",
					"tooltip": "1 Level of Gold Received. Multiplies your gold received from all sources by 110%.",
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_GOLD),
					"flavorText": null,// "We can also say that it is multiplied by 1.1, but that sounds so much weaker.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD, nodeLevel)},
					"icon": "goldx3",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Cc": { 
					"name": "Crit Chance",
					"tooltip": "1 Level of Critical Chance. Adds 2% to your chance to score a critical hit.",
					"tooltipFunction": Character.getStatTooltipFunctionChance(CH2.STAT_CRIT_CHANCE),
					"flavorText": null,// "Ever wonder what happens when you get over 100% Crit Chance? The Ancients once knew, but that is ancient history.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_CHANCE, nodeLevel)},
					"icon": "critChance",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"Cd": { 
					"name": "Crit Damage",
					"tooltip": "1 Level of Critical Damage. Multiplies the damage of your critical hits by 120%.",
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_CRIT_DAMAGE),
					"flavorText": null,// "When a number is multiplied by a fixed amount (greater than 1) many times, that number is said to grow \"exponentially\". This is because that process is usually represented by a formula that uses exponential notation.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_DAMAGE, nodeLevel)},
					"icon": "critDamage",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},			
				"H": { 
					"name": "Haste",
					"tooltip": "1 Level of Haste. Multiplies your Haste by 105%.",
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_HASTE),
					"flavorText": "Haste affects the rate that you auto-attack, and all cooldown speeds, including Automator cooldown speeds.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_HASTE, nodeLevel)},
					"icon": "haste",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Gc": { 
					"name": "Clickable Gold",
					"tooltip": "1 Level of Clickable Gold. Multiplies your gold received from clickables by 150%." ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_CLICKABLE_GOLD),
					"flavorText": "If only someone could click on them before they go off the screen.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_GOLD, nodeLevel)},
					"icon": "clickableGold",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Cl": { 
					"name": "Click Damage",
					"tooltip": "1 Level of Click Damage. Multiplies your click damage by 110%." ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_CLICK_DAMAGE),
					"flavorText": "This affects damage from all skills that \"click\". But it does not affect auto-attacks, because those are not \"clicks\".",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICK_DAMAGE, nodeLevel)},
					"icon": "clickDamage",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Gb": { 
					"name": "Monster Gold",
					"tooltip": "1 Level of Monster Gold. Multiplies gold received by monsters by 120%." ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_MONSTER_GOLD),
					"flavorText": "", //AO: Need new flavor text
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_MONSTER_GOLD, nodeLevel)},
					"icon": "bossGold",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Ir": { 
					"name": "Item Cost Reduction",
					"tooltip": "1 Level of Item Cost Reduction. Multiplies the gold costs of buying and leveling equipment by 0.92." ,
					"tooltipFunction": Character.getStatTooltipFunctionReduction(CH2.STAT_ITEM_COST_REDUCTION),
					"flavorText": "Rufus sometimes wonders why he can't compete in the Gold market. He always felt like there was a mysterious seller undercutting him.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_COST_REDUCTION, nodeLevel)},
					"icon": "itemCostReduction",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"Mt": { 
					"name": "Total Mana",
					"tooltip": "1 Level of Total Mana. Increases your maximum mana by 25." ,
					"tooltipFunction": Character.getStatTooltipFunctionNoPercent(CH2.STAT_TOTAL_MANA),
					"flavorText": "If a fixed amount is added to a number many times, that number is said to grow \"linearly\". This is because if you plot it out on an x/y graph, you'll see a line.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_MANA, nodeLevel)},
					"icon": "totalMana",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Mr": { 
					"name": "Mana Regeneration",
					"tooltip": "1 Level of Mana Regeneration. Multiplies your mana regeneration rate by 110%." ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_MANA_REGEN),
					"flavorText": null,// "You will get 10% more mana per minute than before you had this upgrade.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_MANA_REGEN, nodeLevel)},
					"icon": "manaRegen",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"En": { 
					"name": "Total Energy",
					"tooltip": "1 Level of Total Energy. Increases your maximum energy by 25." ,
					"tooltipFunction": Character.getStatTooltipFunctionNoPercent(CH2.STAT_TOTAL_ENERGY),
					"flavorText": "If a fixed amount is added to a number many times, that number is said to grow \"linearly\". This is because if you plot it out on an x/y graph, you'll see a line.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_ENERGY, nodeLevel)},
					"icon": "totalEnergy",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Gp": { 
					"name": "Clickable Chance",
					"tooltip": "1 Level of Gold Piles. Multiplies the number of gold piles found by 110%." ,
					"tooltipFunction": Character.getStatTooltipFunctionChance(CH2.STAT_CLICKABLE_CHANCE),
					"flavorText": "The chance that a floating gold clickable will spawn every 5 seconds." ,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_CHANCE, nodeLevel)},
					"icon": "goldPiles",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"Bg": { 
					"name": "Bonus Gold Chance",
					"tooltip": "1 Level of Bonus Gold Chance. Adds 1% to your chance of finding bonus gold." ,
					"tooltipFunction": Character.getStatTooltipFunctionChance(CH2.STAT_BONUS_GOLD_CHANCE),
					"flavorText": "When killing monsters, bonus gold may appear." ,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_BONUS_GOLD_CHANCE, nodeLevel)},
					"icon": "goldChance",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"Tc": { 
					"name": "Treasure Chest Chance",
					"tooltip": "1 Level of Treasure Chest Chance. Adds 2% to the chance that a monster happens to be a treasure chest." ,
					"tooltipFunction": Character.getStatTooltipFunctionChance(CH2.STAT_TREASURE_CHEST_CHANCE),
					"flavorText": "Making good use of the lingering powers of a once-loathed ancient known as Thusia.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_CHANCE, nodeLevel)},
					"icon": "treasureChance",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"Tg": { 
					"name": "Treasure Chest Gold",
					"tooltip": "1 Level of Treasure Chest Gold. Multiplies the gold received from treasure chest monsters by 125%." ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_TREASURE_CHEST_GOLD),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_GOLD, nodeLevel)},
					"icon": "treasureGold",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"I1": { 
					"name": "Equipment: Weapon",
					"tooltip": "1 Level of Weapon Damage. Multiplies the damage you deal with weapons by 150%" ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_ITEM_WEAPON_DAMAGE),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_WEAPON_DAMAGE, nodeLevel)},
					"icon": "damageWeapon",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"I2": { 
					"name": "Equipment: Helmet",
					"tooltip": "1 Level of Helmet Damage. Multiplies the damage you deal with helmets by 150%" ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_ITEM_HEAD_DAMAGE),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_HEAD_DAMAGE, nodeLevel)},
					"icon": "damageHead",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"I3": { 
					"name": "Equipment: Breastplate",
					"tooltip": "1 Level of Breastplate Damage. Multiplies the damage you deal with breastplates by 150%" ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_ITEM_CHEST_DAMAGE),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_CHEST_DAMAGE, nodeLevel)},
					"icon": "damageTop",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"I4": { 
					"name": "Equipment: Ring",
					"tooltip": "1 Level of Ring Damage. Multiplies the damage you deal with rings by 150%" ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_ITEM_RING_DAMAGE),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_RING_DAMAGE, nodeLevel)},
					"icon": "damageAccesory",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"I5": { 
					"name": "Equipment: Pants",
					"tooltip": "1 Level of Pants Damage. Multiplies the damage you deal with pants by 150%" ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_ITEM_LEGS_DAMAGE),
					"flavorText": "Pants shouldn't do damage, that's ridiculous.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_LEGS_DAMAGE, nodeLevel)},
					"icon": "damageLegs",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"I6": { 
					"name": "Equipment: Gloves",
					"tooltip": "1 Level of Gloves Damage. Multiplies the damage you deal with gloves by 150%" ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_ITEM_HANDS_DAMAGE),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_HANDS_DAMAGE, nodeLevel)},
					"icon": "damageHands",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"I7": { 
					"name": "Equipment: Boots",
					"tooltip": "1 Level of Boots Damage. Multiplies the damage you deal with boots by 150%" ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_ITEM_FEET_DAMAGE),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_FEET_DAMAGE, nodeLevel)},
					"icon": "damageFeet",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"I8": { 
					"name": "Equipment: Cape",
					"tooltip": "1 Level of Cape Damage. Multiplies the damage you deal with capes by 150%" ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_ITEM_BACK_DAMAGE),
					"flavorText": "If you wear these in real life, people will think something is wrong with you.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_BACK_DAMAGE, nodeLevel)},
					"icon": "damageBack",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Mo": { 
					"name": "Mousing over Clickables",
					"tooltip": "Collect Clickables by mousing over them instead of clicking them" ,
					"flavorText": "The ancients left some of their greatest powers behind for you to discover.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {},
					"icon": "clickableGold"
				},
				//####################################################################
				//########################## CLASS SPECIFIC ##########################
				//####################################################################
				"Mu": {
					"name": "Increased MultiClicks",
					"tooltip": "Adds 1 click to your MultiClick.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("ExtraMulticlicks", nodeLevel); CH2.currentCharacter.addTrait("TreeExtraMulticlicks", nodeLevel, true); },
					"icon": "nineClicks",
					"upgradeable": false
					//"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"Bc": { 
					"name": "More Big Clicks",
					"tooltip": "Increases the number of clicks empowered by Big Clicks by 1.",
					"flavorText": "They march loyally behind you in unison, each one prepared to sacrifice itself for your cause.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("BigClickStacks", nodeLevel); CH2.currentCharacter.addTrait("TreeBigClickStacks", nodeLevel, true); },
					"icon": "iconBigClicks",
					"upgradeable": false
					//"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"Bd": { 
					"name": "Bigger Big Clicks",
					"tooltip": "Increases the damage done by Big Clicks by 5%",
					"tooltipFunction": Character.getTraitTooltipFunction("BigClicksDamage"),
					"flavorText": "They might not look any bigger when you get this upgrade. They're bigger on the inside. In fact, they weigh a lot more.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("BigClicksDamage", nodeLevel); CH2.currentCharacter.addTrait("TreeBigClicksDamage", nodeLevel, true); },
					"icon": "iconBigClicks",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Hd": { 
					"name": "Huger Huge Click",
					"tooltip": "Increases the damage done by Huge Click by 5%",
					"tooltipFunction": Character.getTraitTooltipFunction("HugeClickDamage"),
					"flavorText": "It actually gets bigger. But there is an unusual visual side effect that the rest of the world increases in size proportionally.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("HugeClickDamage", nodeLevel); CH2.currentCharacter.addTrait("TreeHugeClickDamage", nodeLevel, true); },
					"icon": "hugeClicks",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Md": { 
					"name": "Mana Crit Damage",
					"tooltip": "Increases the damage of Mana Crit by 5%",
					"tooltipFunction": Character.getTraitTooltipFunction("ManaCritDamage"),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("ManaCritDamage", nodeLevel); CH2.currentCharacter.addTrait("TreeManaCritDamage", nodeLevel, true); },
					"icon": "manaClick",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Kh": { 
					"name": "Hastened Clickstorm",
					"tooltip": "Multiplies the cooldown of Clickstorm by 0.8",
					"flavorText": "If a fixed positive amount less than 1 is multiplied to a number many times, that number is said to \"approach zero\". Enough applications and your number will get very close to, but never actually reach, zero.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {hastenClickstorm();},
					"icon": "clickstorm"
					
				},
				"Eh": { 
					"name": "Hastened Energize",
					"tooltip": "Multiplies the cooldown and mana cost of Energize by 0.8",
					"flavorText": "If a fixed positive amount less than 1 is multiplied to a number many times, that number is said to \"approach zero\". Enough applications and your number will get very close to, but never actually reach, zero.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {hastenEnergize();},
					"icon": "energize"
				},
				"Ea": { 
					"name": "Improved Energize",
					"tooltip": "Increases the duration of Energize by 10% of its original duration.",
					"tooltipFunction": Character.getTraitTooltipFunction("ImprovedEnergize"),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("ImprovedEnergize", nodeLevel); CH2.currentCharacter.addTrait("TreeImprovedEnergize", nodeLevel, true); },
					"icon": "energize",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Ph": { 
					"name": "Hastened Powersurge",
					"tooltip": "Multiplies the cooldown and mana cost of Powersurge by 0.8",
					"flavorText": "If a fixed positive amount less than 1 is multiplied to a number many times, that number is said to \"approach zero\". Enough applications and your number will get very close to, but never actually reach, zero.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { hastenSkill("Powersurge", 0.8); },
					"icon": "powersurgeDuration"
				},
				"Pt": { 
					"name": "Sustained Powersurge",
					"tooltip": "Increases the duration of Powersurge by 5%.",
					"tooltipFunction": Character.getTraitTooltipFunction("SustainedPowersurge"),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("SustainedPowersurge", nodeLevel); CH2.currentCharacter.addTrait("TreeSustainedPowersurge", nodeLevel, true); },
					"icon": "powersurgeDuration",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Pa": { 
					"name": "Improved Powersurge",
					"tooltip": "Increases the damage bonus of Powersurge by 5%.",
					"tooltipFunction": Character.getTraitTooltipFunction("ImprovedPowersurge"),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("ImprovedPowersurge", nodeLevel); CH2.currentCharacter.addTrait("TreeImprovedPowersurge", nodeLevel, true); },
					"icon": "powersurgeDamage",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Ra": { 
					"name": "Improved Reload",
					"tooltip": "Increases Energy and Mana restored by Reload by 20 and...",
					"tooltipFunction": getImprovedReloadTooltip(),
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("ImprovedReload", nodeLevel);  CH2.currentCharacter.addTrait("TreeImprovedReload", nodeLevel, true); },
					"icon": "improvedReload",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Rh": { 
					"name": "Hastened Reload",
					"tooltip": "Multiplies the cooldown of Reload by 0.8",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function(nodeLevel:Number) { hastenSkill("Reload", 0.8); },
					"icon": "hastenReload"
				},
				"Aa": { 
					"name": "Auto Attack Damage",
					"tooltip": "Increases the damage you do with Auto Attacks by 20%.",
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_AUTOATTACK_DAMAGE),
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.levelUpStat(CH2.STAT_AUTOATTACK_DAMAGE, nodeLevel); },
					"icon": "autoAttack",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				//###################################################################
				//############################ SKILLS ############################
				//###################################################################
				"T3": { 
					"name": "Skill: MultiClick",
					"tooltip": "Clicks 5 times." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function(nodeLevel:Number) {
						addSkill("MultiClick")(); 
					},
					"icon": "nineClicks",
					"flammable": true
				},
				"T1": { 
					"name": "Skill: Big Clicks",
					"tooltip": "Causes your next 6 clicks to deal 300% damage." ,
					"flavorText": "When activated, press your mouse button harder for added effect.",
					"setupFunction": function() {},
					"alwaysAvailable": true,
					"purchaseFunction": function(nodeLevel:Number) {
						CH2.currentCharacter.hasPurchasedFirstSkill = true;
						addSkill("Big Clicks")(); 						
					},
					"icon": "iconBigClicks",
					"flammable": true
				},
				"T2": { 
					"name": "Skill: Energize.",
					"tooltip": "Restores 2 energy per second for 60 seconds." ,
					"flavorText": "This skill consumes Mana to create Energy.",
					"setupFunction": function() {},
					"purchaseFunction": function(nodeLevel:Number) { addSkill("Energize")(); },
					"icon": "energize",
					"flammable": true
				},
				"T5": { 
					"name": "Skill: Huge Click",
					"tooltip": "Causes your next click to deal 1000% damage." ,
					"flavorText": "It stacks. Everything stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function(nodeLevel:Number) { addSkill("Huge Click")(); },
					"icon": "hugeClicks",
					"flammable": true
				},
				"T4": { 
					"name": "Skill: Clickstorm",
					"tooltip": CLICKSTORM_TOOLTIP,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function(nodeLevel:Number) { addSkill("Clickstorm")(); },
					"icon": "clickstorm",
					"flammable": true
				},
				"T6": { 
					"name": "Skill: Powersurge",
					"tooltip": "Causes your clicks within 60 seconds to deal 200% damage." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function(nodeLevel:Number) { addSkill("Powersurge")(); },
					"icon": "powersurgeDamage",
					"flammable": true
				},
				"T7": { 
					"name": "Skill: Mana Crit",
					"tooltip": "Clicks with +100% chance to score a critical hit." ,
					"flavorText": "It stacks. Everything stacks.",
					"setupFunction": function() {},
					"purchaseFunction": function(nodeLevel:Number) { addSkill("Mana Crit")(); },
					"icon": "manaClick",
					"flammable": true
				},
				"T8": { 
					"name": "Skill: Reload",
					"tooltip": "Restores 40 energy and mana and reduces the remaining cooldown of all skills by 40%." ,
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function(nodeLevel:Number) { addSkill("Reload")(); },
					"icon": "reload",
					"flammable": true
				},
				//###################################################################
				//############################ Key Skills ###########################
				//###################################################################
				"qG": {
					"name": "Mammon's Greed",
					"tooltip": "3 Levels of Gold Received. Multiplies your gold received from all sources by 133%.",
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_GOLD, 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD, 2 + nodeLevel)},
					"icon": "goldx3",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"qCd": {
					"name": "Precision of Bhaal",
					"tooltip": "3 Levels of Critical Damage. Multiplies the damage of your critical hits by 172.8%.",
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_CRIT_DAMAGE, 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_DAMAGE, 2 + nodeLevel)},
					"icon": "critDamage",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"qH": {
					"name": "Vaagur's Impatience",
					"tooltip": "3 Levels of Haste. Multiplies your Haste by 115.7%." ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_HASTE, 2),
					"flavorText": "Haste affects the rate that you auto-attack, and all cooldown speeds, including Automator cooldown speeds.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_HASTE, 2 + nodeLevel)},
					"icon": "haste",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"qGc": {
					"name": "Revolc's Blessing",
					"tooltip": "3 Levels of Clickable Gold. Multiplies your gold received from clickables by 337.5%.",
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_CLICKABLE_GOLD, 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_GOLD, 2 + nodeLevel)},
					"icon": "clickableGold",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"qCl": {
					"name": "The Wrath of Fragsworth",
					"tooltip": "3 Levels of Click Damage. Multiplies your click damage by 133%.",
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_CLICK_DAMAGE, 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICK_DAMAGE, 2 + nodeLevel)},
					"icon": "clickDamage",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"qGb": {
					"name": "Mimzee's Kindness",
					"tooltip": "3 Levels of Monster Gold. Multiplies gold received by monsters by 172.8%.",
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_MONSTER_GOLD, 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_MONSTER_GOLD, 2 + nodeLevel)},
					"icon": "bossGold",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"qIr": {
					"name": "The Thrift of Dogcog",
					"tooltip": "3 Levels of Item Cost Reduction. Reduces the cost of buying and leveling items by 22%.",
					"tooltipFunction": Character.getStatTooltipFunctionReduction(CH2.STAT_ITEM_COST_REDUCTION, 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_COST_REDUCTION, 2 + nodeLevel)},
					"icon": "itemCostReduction",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"qMt": {
					"name": "Energon's Ions",
					"tooltip": "4 Levels of Total Mana. Increases your maximum Mana by 100.",
					"tooltipFunction": Character.getStatTooltipFunctionNoPercent(CH2.STAT_TOTAL_MANA, 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_MANA, 3 + nodeLevel)},
					"icon": "totalMana",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"qMr": {
					"name": "Energon's Grace",
					"tooltip": "3 Levels of Mana Regeneration. Multiplies your mana regeneration by 133%.",
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_MANA_REGEN, 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_MANA_REGEN, 2 + nodeLevel)},
					"icon": "manaRegen",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"qEn": {
					"name": "Juggernaut's Pittance",
					"tooltip": "4 Levels of Total Energy. Increases your maximum Energy by 100.",
					"tooltipFunction": Character.getStatTooltipFunctionNoPercent(CH2.STAT_TOTAL_ENERGY, 3),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_ENERGY, 3 + nodeLevel)},
					"icon": "totalEnergy",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"qGp": {
					"name": "The Vision of Iris",
					"tooltip": "3 Levels of Gold Piles. Multiplies the number of gold piles found by 130%.",
					"tooltipFunction": Character.getStatTooltipFunctionChance(CH2.STAT_CLICKABLE_CHANCE, 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_CHANCE, 2 + nodeLevel)},
					"icon": "goldPiles",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"qBg": {
					"name": "Fortuna's Luck",
					"tooltip": "3 Levels of Bonus Gold Chance. Adds 3% to your chance of finding bonus gold.",
					"tooltipFunction": Character.getStatTooltipFunctionChance(CH2.STAT_BONUS_GOLD_CHANCE, 2),
					"flavorText": "When killing monsters, bonus gold may appear." ,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_BONUS_GOLD_CHANCE, 2 + nodeLevel)},
					"icon": "goldChance",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"qTc": {
					"name": "Mimzee's Favor",
					"tooltip": "3 Levels of Treasure Chest Chance. Adds 6% to the chance that a monster happens to be a treasure chest.",
					"tooltipFunction": Character.getStatTooltipFunctionChance(CH2.STAT_TREASURE_CHEST_CHANCE, 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_CHANCE, 2 + nodeLevel)},
					"icon": "treasureChance",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"qTg": {
					"name": "Mimzee's Blessing",
					"tooltip": "3 Levels of Treasure Chest Gold. Multiplies your gold received from treasure chests by 195%.",
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_TREASURE_CHEST_GOLD, 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_GOLD, 2 + nodeLevel)},
					"icon": "treasureGold",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"qMu": {
					"name": "Mega Increased MultiClicks",
					"tooltip": "Adds 3 clicks to your MultiClick.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("ExtraMulticlicks", 2 + nodeLevel);  CH2.currentCharacter.addTrait("TreeExtraMulticlicks", 2 + nodeLevel, true); },
					"icon": "nineClicks",
					"upgradeable": false,
					"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"qBc": { 
					"name": "Mega More Big Clicks",
					"tooltip": "Increases the number of clicks empowered by Big Clicks by 3.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("BigClickStacks", 2 + nodeLevel); CH2.currentCharacter.addTrait("TreeBigClickStacks", 2 + nodeLevel, true); },
					"icon": "iconBigClicks",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(10, 1, 2)
				},
				"qBd": { 
					"name": "Mega Bigger Big Clicks",
					"tooltip": "Increases the damage done by Big Clicks by 15%.",
					"tooltipFunction": Character.getTraitTooltipFunction("BigClicksDamage", 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("BigClicksDamage", 2 + nodeLevel); CH2.currentCharacter.addTrait("TreeBigClicksDamage", 2 + nodeLevel, true); },
					"icon": "iconBigClicks",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"qHd": { 
					"name": "Mega Huger Huge Click",
					"tooltip": "Increases the damage of Huge Click by 15%.",
					"tooltipFunction": Character.getTraitTooltipFunction("HugeClickDamage", 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("HugeClickDamage", 2 + nodeLevel); CH2.currentCharacter.addTrait("TreeHugeClickDamage", 2 + nodeLevel, true); },
					"icon": "hugeClicks",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"qMd": { 
					"name": "Mega Mana Crit Damage",
					"tooltip": "Increases the damage done by Mana Crits by 15%.",
					"tooltipFunction": Character.getTraitTooltipFunction("ManaCritDamage", 2),
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("ManaCritDamage", 2 + nodeLevel); CH2.currentCharacter.addTrait("TreeManaCritDamage", 2 + nodeLevel, true); },
					"icon": "manaClick",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"Q21": { 
					"name": "Synchrony",
					"tooltip": "Skills do not interrupt Auto Attacks.  Auto Attacks generate 2 extra energy when Autoattackstorm is active." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("Synchrony", nodeLevel, false, false); applyUninterruptedAutoAttacksTalent()},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q22": { 
					"name": "Release",
					"tooltip": "Damage is increased by 100% while you have less than 60% of your total energy." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("LowEnergyDamageBonus", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q23": { 
					"name": "Restraint",
					"tooltip": "Gold gained is increased by 100% while you have more than 40% of your total energy." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("HighEnergyGoldBonus", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q24": { 
					"name": "Discharge",
					"tooltip": "Spending energy deals damage based on the amount of energy spent and your auto attack damage." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("Discharge", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q25": { 
					"name": "Gift of Chronos",
					"tooltip": "Spending mana increases haste for 5 seconds." ,
					"flavorText": "To clarify, this multiplies your haste by 100% plus 1% per point of mana spent in the previous 5 seconds. Gift of Chronos's duration is not decreased by haste.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("SpendManaHaste", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q26": { 
					"name": "Curse of the Juggernaut",
					"tooltip": "While Big Clicks is active, all skills cost 1 additional energy per skill that has been activated since Big Clicks began." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("CurseOfTheJuggernaut", nodeLevel, false, false)},
					"icon": "damagex3",
					"flammable": true
				},
				"Q27": { 
					"name": "Limitless Big Clicks",
					"tooltip": "Big Clicks has no cooldown and can stack infinitely." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {applyLimitlessBigClicks(); },  
					"icon": "damagex3",
					"flammable": true
				},
				"Q28": { 
					"name": "Jerator's Enchantment",
					"tooltip": "Critical Hits from Auto Attacks restore 1 mana and 3 energy." ,
					"flavorText": "",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("AutoAttackCritMana", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q29": { 
					"name": "AutoAttackStorm",
					"tooltip": AUTOATTACKSTORM_TOOLTIP, //"A skill. Consumes 1.25 mana per second to auto attack an extra 2.5 times per second.",
					"flavorText": "Replaces your current Storm.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { replaceStorm(CH2.currentCharacter.getStaticSkill("Autoattackstorm"));},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q30": { 
					"name": "Managize",
					"tooltip": "Energize becomes Managize, which restores 25% of your mana at the cost of 120 energy over 15 seconds." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.replaceSkill("Energize", CH2.currentCharacter.getStaticSkill("Managize")); },  
					"icon": "damagex3",
					"flammable": true
				},
				"Q41": { 
					"name": "Golden Clicks",
					"tooltip": GOLDENCLICKS_TOOLTIP,
					"flavorText": "Replaces your current Storm.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { replaceStorm(CH2.currentCharacter.getStaticSkill("GoldenClicks")); },  
					"icon": "damagex3",
					"flammable": true
				},
				"Q42": { 
					"name": "Huge Click Discount",
					"tooltip": "Huge Click reduces the cost of items by half for 4 seconds." ,
					"flavorText": "Huge Click Discount's duration is not decreased by haste.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("HugeClickDiscount", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q43": { 
					"name": "Reload Rampage",
					"tooltip": "Reload also sets your current gold to double the amount you had at the beginning of the zone." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("ReloadRampage", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q44": { 
					"name": "Preload",
					"tooltip": "Reload reduces the cooldown of the next skill used by 50%." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("Preload", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q45": { 
					"name": "Quick Reload",
					"tooltip": "Reload's effects and cooldown are reduced by 80%." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {applySmallReloads(); },  
					"icon": "damagex3",
					"flammable": true
				},
				"Q61": { 
					"name": "Bhaal's Rise",
					"tooltip": "Scoring a Critical Hit reduces the remaining cooldown of Mana Crit by 1 second." ,
					"flavorText": "Casting a cooldown-improved Mana Crit will reset the cooldown of your *next* Mana Crit to its original duration.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("BhaalsRise", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q62": { 
					"name": "Improved Mana Crit",
					"tooltip": "Crit Chance increases the damage of Mana Crit and gives a chance to refund its mana cost, by the amount of Crit Chance you have." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("ImprovedManaCrit", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q63": { 
					"name": "Critical Killing Surge",
					"tooltip": "Monsters killed with a Critical Hit reduces the cooldown of Powersurge by 5 seconds." ,
					"flavorText": "Casting a cooldown-improved Powersurge will reset the cooldown of your *next* Powersurge to its original duration.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("CritKillPowerSurgeCooldown", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q64": { 
					"name": "Mana Crit Overflow",
					"tooltip": "Overkill from Mana Crit damages the next monster." ,
					"flavorText": "It will not spill damage over to more than one additional monster.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("ManaCritOverflow", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q65": { 
					"name": "CritStorm",
					"tooltip": CRITSTORM_TOOLTIP,
					"flavorText": "Replaces your current Storm.", //"Bhaal's Favorite.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { replaceStorm(CH2.currentCharacter.getStaticSkill("Critstorm")); },
					"icon": "damagex3",
					"flammable": true
				},
				"Q66": { 
					"name": "Critical Powersurge",
					"tooltip": "PowerSurge gradually increases Crit Chance while active, reaching +20% at the end of its duration.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("PowerSurgeCritChance", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q81": { 
					"name": "Limitless Haste",
					"tooltip": "Removes the 1-second minimum limit on Global Cooldown, allowing Haste to reduce it below 1 second." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.gcdMinimum = 0.1; },  
					"icon": "damagex3",
					"flammable": true
				},
				"Q82": { 
					"name": "Flurry",
					"tooltip": "Haste increases the number of clicks in a MultiClick by the percentage of haste you have." ,
					"flavorText": "Rounded up or rounded down? Only the Ancients know.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("Flurry", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q83": { 
					"name": "Killing Frenzy",
					"tooltip": "Multiply your haste by 150% upon killing a monster. Lasts 5 seconds. Does not stack, but the timer will reset with each kill." ,
					"flavorText": "Killing Frenzy's duration is not decreased by haste.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("KillingFrenzy", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q84": { 
					"name": "Small Clicks",
					"tooltip": "Makes your Big Clicks smaller. Small Clicks are half as strong, but there are twice as many of them." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("DistributedBigClicks", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q85": { 
					"name": "Expandable Small Clicks",
					"tooltip": "Haste increases the number of charges from Small Clicks, by the percentage of haste you have." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("DistributedBigClicksScaling", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q86": { 
					"name": "Stormbringer",
					"tooltip": "Small Clicks decreases the remaining cooldown of ClickTorrent by 1 second each." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("Stormbringer", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q87": { 
					"name": "Hecaton's Echo",
					"tooltip": "Huge Click, when activated, also triggers on every 20th click for the next 100 clicks." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.addTrait("HecatonsEcho", nodeLevel, false, false);},  
					"icon": "damagex3",
					"flammable": true
				},
				"Q88": { 
					"name": "ClickTorrent",
					"tooltip": CLICKTORRENT_TOOLTIP,
					"flavorText": "Replaces your current Storm.",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { replaceStorm(CH2.currentCharacter.getStaticSkill("Clicktorrent")); },  
					"icon": "damagex3",
					"flammable": true
				},
				"Q89": { 
					"name": "Limited Haste",
					"tooltip": "Triples your damage at the cost of half of your haste.",
					"flavorText": "Do you really need to be going that fast?",
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.addTrait("LimitedHaste", nodeLevel, false, false); applyLimitedHaste(); },  
					"icon": "damagex3",
					"flammable": true
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
					"purchaseFunction": function(nodeLevel:Number) { purchaseAutomator();  CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_15");  CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_16"); },
					"icon": "automator"
				},
				"A01": { 
					"name": "Gem: MultiClick",
					"tooltip": "Automates MultiClick." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_15", tripleClick); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_15");  },
					"icon": "gemNineClicks"
				},
				"A03": { 
					"name": "Gem: Big Clicks",
					"tooltip": "Automates Big Clicks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_16", bigClicks); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_16"); },
					"icon": "gemGameBigClicks"
				},
				"A05": { 
					"name": "Gem: Huge Click",
					"tooltip": "Automates Huge Click." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_17", hugeClick); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_17"); },
					"icon": "gemHugeClicks"
				},
				"A04": { 
					"name": "Gem: Clickstorm",
					"tooltip": "Automates Clickstorm." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_51", clickstorm); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_51"); },
					"icon": "gemClickstorm"
				},
				"A02": { 
					"name": "Gem: Energize.",
					"tooltip": "Automates Energize." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_18", energize); },
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_18"); },
					"icon": "gemEnergize"
				},
				"A06": { 
					"name": "Gem: Powersurge.",
					"tooltip": "Automates Powersurge." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_19", powerSurge); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_19"); },
					"icon": "gemPowersurge"
				},
				"A07": { 
					"name": "Gem: Mana Crit",
					"tooltip": "Automates Mana Crit." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_20", manaClick); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_20"); },
					"icon": "gemManaClick" 
				},
				"A08": { 
					"name": "Gem: Reload",
					"tooltip": "Automates Reload." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_52", reload); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_52"); },
					"icon": "gemReload" 
				},
				"A11": { 
					"name": "Gem: AutoAttack Storm",
					"tooltip": "Automates AutoAttack Storm. " ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_56", autoAttackstorm); },
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_56"); },
					"icon": "gemClickstorm"
				},
				"A12": { 
					"name": "Gem: ClickTorrent",
					"tooltip": "Automates ClickTorrent." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_57", clicktorrent ); },
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_57"); },
					"icon": "gemClickstorm"
				},
				"A13": { 
					"name": "Gem: Golden Clicks",
					"tooltip": "Automates Golden Clicks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_58", goldenClicks ); },
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_58"); },
					"icon": "gemClickstorm"
				},
				"A14": { 
					"name": "Gem: Critstorm",
					"tooltip": "Automates Critstorm." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_59", critstorm); },
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_59"); },
					"icon": "gemClickstorm"
				},
				"A15": { 
					"name": "Gem: Managize",
					"tooltip": "Automates Managize. " ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_55", managize); },
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_55"); },
					"icon": "gemEnergize"
				},
				"A20": { 
					"name": "Gem: Buy Random Catalog",
					"tooltip": "Automates Buying a Random Catalog Item." ,
					"flavorText": "The Catalog is that area on the bottom left of the UI where you purchase new items.",
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuyRandomCatalogItemGem(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_4");  },
					"icon": "gemBuyRandom"
				},
				"A21": { 
					"name": "Gem: Upgrade Cheapest Item",
					"tooltip": "Automates Upgrading the Cheapest Item. It can also purchase a new item, if that is cheaper than all of your upgrades." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addUpgradeCheapestItemGem();},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_5");},
					"icon": "gemUpgradeCheapest"
				},
				"A24": { 
					"name": "Gem: Upgrade Newest Item",
					"tooltip": "Automates upgrading the Newest Item." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addUpgradeNewestItemGem(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_53");  },
					"icon": "gemBuyRandom"
				},
				"A26": { 
					"name": "Gem: Upgrade All Items ",
					"tooltip": "Automates upgrading All Items." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addUpgradeAllItemsGem(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_54");  },
					"icon": "gemBuyRandom"
				},
				"A31": { 
					"name": "Gem: Swapping to set 1",
					"tooltip": "Automates swapping to set 1." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addSwapToFirstSet(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_80");  },
					"icon": "gemUpgradeCheapest"
				},
				"A32": { 
					"name": "Gem: Swapping to set 2",
					"tooltip": "Automates swapping to set 2." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addSwapToSecondSet(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_81");  },
					"icon": "gemUpgradeCheapest"
				},
				"A33": { 
					"name": "Gem: Swapping to set 3",
					"tooltip": "Automates swapping to set 3." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addSwapToThirdSet(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_82");  },
					"icon": "gemUpgradeCheapest"
				},
				"A34": { 
					"name": "Gem: Swapping to set 4",
					"tooltip": "Automates swapping to set 4." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addSwapToFourthSet(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_83");  },
					"icon": "gemUpgradeCheapest"
				},
				"A35": { 
					"name": "Gem: Swapping to set 5",
					"tooltip": "Automates swapping to set 5." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addSwapToFifthSet(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_84");  },
					"icon": "gemUpgradeCheapest"
				},
				"A36": {
					"name": "Gem: Next Set",
					"tooltip": "Switch to the next Automator Set." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){ addNextSetGem(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_21"); },
					"icon": "gemSwitchNext"
				},
				"A37": {
					"name": "Gem: Previous Set",
					"tooltip": "Switch to the previous Automator Set." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){ addPreviousSetGem(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_22"); },
					"icon": "gemSwitchPrev"
				},
				"A38": { 
					"name": "Additional Automator Set",
					"tooltip": "Unlocks an additional set for the Automator." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.addQueueSet(); },
					"icon": "gemAddSet"
				},
				"A39": {
					"name": "Automator Speed",
					"tooltip": "Speeds up the Automator by 50%." ,
					"tooltipFunction": Character.getStatTooltipFunction(CH2.STAT_AUTOMATOR_SPEED),
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.levelUpStat(CH2.STAT_AUTOMATOR_SPEED, nodeLevel); },
					"icon": "automatorSpeed",
					"upgradeable": true,
					"upgradeCostFunction": Character.linearExponential(5, 1, 2)
				},
				"A40": {
					"name": "Gem: Pause",
					"tooltip": "Pauses the game" ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){ addPauseGem()},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_66");  },
					"icon": "pauseIcon"
				},
				"A41": {
					"name": "Gem: Unpause",
					"tooltip": "Unpauses the game" ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){ addUnpauseGem()},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_67"); },
					"icon": "playIcon"				
				},
				"S20": { 
					"name": "Stone: Always",
					"tooltip": "A stone that can always activate." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addAlwaysStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_1");  },
					"icon": "always"
				},
				"S01": { 
					"name": "Stone: MH more than 50%",
					"tooltip": "A stone that can activate when the next monster's health is greater than 50%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addMHGreaterThan50PercentStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_5");  },
					"icon": "mhGreater50"
				},
				"S02": { 
					"name": "Stone: MH less than 50%",
					"tooltip": "A stone that can activate when the next monster's health is less than 50%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addMHLessThan50PercentStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_6"); },
					"icon": "mhLower50"
				},
				"S03": { 
					"name": "Stone: Energy more than 90%",
					"tooltip": "A stone that can activate when your energy is above 90%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addGreaterThan90PercentEnergyStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_7"); },
					"icon": "energyGreater90"
				},
				"S04": { 
					"name": "Stone: Energy less than 10%",
					"tooltip": "A stone that can activate when your energy is below 10%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addLessThan10PercentEnergyStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_8");},
					"icon": "energyLower10"
				},
				"S05": { 
					"name": "Stone: Mana more than 90%",
					"tooltip": "A stone that can activate when your mana is above 90%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addGreaterThan90PercentManaStone(); },
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_9");},
					"icon": "manaGreater90"
				},
				"S06": { 
					"name": "Stone: Mana less than 10%",
					"tooltip": "A stone that can activate when your mana is below 10%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){ addLessThan10PercentManaStone(); },
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_10");},
					"icon": "manaLower10"
				},
				"S07": {
					"name": "Stone: Zone Start",
					"tooltip": "A stone that can activate during the first half of a zone." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addZoneStartStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_19"); },
					"icon": "zoneStart"
				},
				"S08": {
					"name": "Stone: Zone Middle",
					"tooltip": "A stone that can activate during the second half of a zone." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addZoneMiddleStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_20"); },
					"icon": "zoneMiddle"
				},
				"S21": {
					"name": "Stone: 4s CD",
					"tooltip": "A stone that can activate once every 4 seconds." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_11", 4000);},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_11"); },
					"icon": "CD4S"
				},
				"S22": { 
					"name": "Stone: 8s CD",
					"tooltip": "A stone that can activate once every 8 seconds." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_12", 8000);},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_12"); },
					"icon": "CD8S"
				},
				"S23": { 
					"name": "Stone: 40s CD",
					"tooltip": "A stone that can activate once every 40 seconds." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_13", 40000);},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_13"); },
					"icon": "CD40S"
				},
				"S24": { 
					"name": "Stone: 90s CD",
					"tooltip": "A stone that can activate once every 90 seconds." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_14", 90000);},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_14"); },
					"icon": "CD90S"
				},
				"S25": { 
					"name": "Stone: 10m CD",
					"tooltip": "A stone that can activate once every 10 minutes." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_15", 600000);},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_15");},
					"icon": "CD10M"
				},
				"S61": { 
					"name": "Stone: Energize is not active.",
					"tooltip": "A stone that can activate when Energize is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("EnergizeEQ0", "Energize = 0", "A stone that can activate when Energize is not active.", "Energize", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("EnergizeEQ0");  },
					"icon": "gemEnergize"
				},
				"S62": { 
					"name": "Stone: Huge Click is not active.",
					"tooltip": "A stone that can activate when Huge Click is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("HugeClickEQ0", "Huge Click = 0", "A stone that can activate when Huge Click is not active.", "Huge Click", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("HugeClickEQ0");  },
					"icon": "gemHugeClicks"
				},
				"S63": { 
					"name": "Stone: Huge Click more than 0",
					"tooltip": "A stone that can activate when Huge Click is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("HugeClickGT0", "Huge Click > 0", "A stone that can activate when Huge Click is active.", "Huge Click", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("HugeClickGT0");  },
					"icon": "gemHugeClicks"
				},
				"S51": { 
					"name": "Stone: Clickstorm is not active.",
					"tooltip": "A stone that can activate when Clickstorm is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("ClickstormEQ0", "Clickstorm = 0", "A stone that can activate when Clickstorm is not active.", "Clickstorm", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("ClickstormEQ0");  },
					"icon": "gemClickstorm"
				},
				"S52": { 
					"name": "Stone: Clickstorm more than 0",
					"tooltip": "A stone that can activate when Clickstorm is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("ClickstormGT0", "Clickstorm > 0", "A stone that can activate when Clickstorm is active.", "Clickstorm", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("ClickstormGT0");  },
					"icon": "gemClickstorm"
				},
				"S66": { 
					"name": "Stone: Powersurge is not active.",
					"tooltip": "A stone that can activate when Powersurge is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("PowersurgeEQ0", "Powersurge = 0", "A stone that can activate when Powersurge is not active.", "Powersurge", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("PowersurgeEQ0"); },
					"icon": "gemPowersurge"
				},
				"S67": { 
					"name": "Stone: Powersurge more than 0",
					"tooltip": "A stone that can activate when Powersurge is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("PowersurgeGT0", "Powersurge > 0", "A stone that can activate when Powersurge is active.", "Powersurge", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("PowersurgeGT0"); },
					"icon": "gemPowersurge"
				},
				"S68": { 
					"name": "Stone: Big Clicks is not active.",
					"tooltip": "A stone that can activate when Big Clicks is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksEQ0", "Big Clicks = 0", "A stone that can activate when Big Clicks is not active.", "Big Clicks", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("BigClicksEQ0"); },
					"icon": "gemGameBigClicks"
				},
				"S69": { 
					"name": "Stone: Big Clicks more than 0",
					"tooltip": "A stone that can activate when Big Clicks is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksGT0", "Big Clicks > 0", "A stone that can activate when Big Clicks is active.", "Big Clicks", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("BigClicksGT0");  },
					"icon": "gemGameBigClicks"
				},
				"S70": { 
					"name": "Stone: Big Clicks less than 10",
					"tooltip": "A stone that can activate when Big Clicks has less than 10 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksLT10", "Big Clicks < 10", "A stone that can activate when Big Clicks has less than 10 stacks.", "Big Clicks", CH2.COMPARISON_LT, 10); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("BigClicksLT10");  },
					"icon": "gemGameBigClicks"
				},
				"S71": { 
					"name": "Stone: Big Clicks more than 10",
					"tooltip": "A stone that can activate when Big Clicks has more than 10 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksGT10", "Big Clicks > 10", "A stone that can activate when Big Clicks has more than 10 stacks.", "Big Clicks", CH2.COMPARISON_GT, 10); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("BigClicksGT10");  },
					"icon": "gemGameBigClicks"
				},
				"S72": { 
					"name": "Stone: Big Clicks less than 50",
					"tooltip": "A stone that can activate when Big Clicks has less than 50 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksLT50", "Big Clicks < 50", "A stone that can activate when Big Clicks has less than 50 stacks.", "Big Clicks", CH2.COMPARISON_LT, 50); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("BigClicksLT50");  },
					"icon": "gemGameBigClicks"
				},
				"S73": { 
					"name": "Stone: Big Clicks more than 50",
					"tooltip": "A stone that can activate when Big Clicks has more than 50 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksGT50", "Big Clicks > 50", "A stone that can activate when Big Clicks has more than 50 stacks.", "Big Clicks", CH2.COMPARISON_GT, 50); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("BigClicksGT50");  },
					"icon": "gemGameBigClicks"
				},
				"S74": { 
					"name": "Stone: Big Clicks less than 100",
					"tooltip": "A stone that can activate when Big Clicks has less than 100 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksLT100", "Big Clicks < 100", "A stone that can activate when Big Clicks has less than 100 stacks.", "Big Clicks", CH2.COMPARISON_LT, 100); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("BigClicksLT100");  },
					"icon": "gemGameBigClicks"
				},
				"S75": { 
					"name": "Stone: Big Clicks more than 100",
					"tooltip": "A stone that can activate when Big Clicks has more than 100 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksGT100", "Big Clicks > 100", "A stone that can activate when Big Clicks has more than 100 stacks.", "Big Clicks", CH2.COMPARISON_GT, 100); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("BigClicksGT100");  },
					"icon": "gemGameBigClicks"
				},
				"S76": { 
					"name": "Stone: Big Clicks less than 200",
					"tooltip": "A stone that can activate when Big Clicks has less than 200 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksLT200", "Big Clicks < 200", "A stone that can activate when Big Clicks has less than 200 stacks.", "Big Clicks", CH2.COMPARISON_LT, 200); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("BigClicksLT200");  },
					"icon": "gemGameBigClicks"
				},
				"S77": { 
					"name": "Stone: Big Clicks more than 200",
					"tooltip": "A stone that can activate when Big Clicks has more than 200 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("BigClicksGT200", "Big Clicks > 200", "A stone that can activate when Big Clicks has more than 200 stacks.", "Big Clicks", CH2.COMPARISON_GT, 200); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("BigClicksGT200");  },
					"icon": "gemGameBigClicks"
				},
				"S78": { 
					"name": "Stone: Big Clicks more than MultiClick",
					"tooltip": "A stone that can activate when Big Clicks has more stacks than MultiClick can click." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBigClicksGTMultiClicksStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("BigClicksGTMultiClicks");  },
					"icon": "gemGameBigClicks"
				},
				"S79": { 
					"name": "Stone: Big Clicks is less than MultiClick",
					"tooltip": "A stone that can activate when Big Clicks does not have more stacks than MultiClick can click." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBigClicksLTEMultiClicksStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("BigClicksLTEMultiClicks");  },
					"icon": "gemGameBigClicks"
				},
				"S80": { 
					"name": "Stone: Juggernaut more than 20",
					"tooltip": "A stone that can activate when Juggernaut has more than 20 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("JuggernautGT20", "Juggernaut > 20", "A stone that can activate when Juggernaut has more than 20 stacks.", "Curse Of The Juggernaut", CH2.COMPARISON_GT, 20); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("JuggernautGT20");  },
					"icon": "automator"
				},
				"S81": { 
					"name": "Stone: Juggernaut more than 50",
					"tooltip": "A stone that can activate when Juggernaut has more than 50 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("JuggernautGT50", "Juggernaut > 50", "A stone that can activate when Juggernaut has more than 50 stacks.", "Curse Of The Juggernaut", CH2.COMPARISON_GT, 50); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("JuggernautGT50");  },
					"icon": "automator"
				},
				"S82": { 
					"name": "Stone: Juggernaut more than 100",
					"tooltip": "A stone that can activate when Juggernaut has more than 100 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("JuggernautGT100", "Juggernaut > 100", "A stone that can activate when Juggernaut has more than 100 stacks.", "Curse Of The Juggernaut", CH2.COMPARISON_GT, 100); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("JuggernautGT100");  },
					"icon": "automator"
				},
				"S83": { 
					"name": "Stone: Juggernaut more than 200",
					"tooltip": "A stone that can activate when Juggernaut has more than 200 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("JuggernautGT200", "Juggernaut > 200", "A stone that can activate when Juggernaut has more than 200 stacks.", "Curse Of The Juggernaut", CH2.COMPARISON_GT, 200); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("JuggernautGT200");  },
					"icon": "automator"
				},
				"V": { 
					"name": "Automator Points",
					"tooltip": "Adds 2 Automator Points.",
					"flavorText": null,
					"setupFunction": function() {},
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automatorPoints = CH2.currentCharacter.automatorPoints + 2;  },
					"icon": "automator"
				},
				"S85": { 
					"name": "Stone: Managize is not active.",
					"tooltip": "A stone that can activate when Managize is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("ManagizeEQ0", "Managize = 0", "A stone that can activate when Managize is not active.", "Managize", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("ManagizeEQ0");  },
					"icon": "gemEnergize"
				},
				"S87": { 
					"name": "Stone: Multiclick is not active.",
					"tooltip": "A stone that can activate when Multiclick is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("MultiClickEQ0", "Multiclick = 0", "A stone that can activate when Multiclick is not active.", "MultiClick", CH2.COMPARISON_LTE, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("MultiClickEQ0");  },
					"icon": "gemNineClicks"
				},
				"S86": { 
					"name": "Stone: Juggernaut more than 10",
					"tooltip": "A stone that can activate when Juggernaut has more than 10 stacks." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("JuggernautGT10", "Juggernaut > 10", "A stone that can activate when Juggernaut has more than 10 stacks.", "Curse Of The Juggernaut", CH2.COMPARISON_GT, 10); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("JuggernautGT10");  },
					"icon": "automator"
				},				
				"S89": { 
					"name": "Stone: First Zone of World",
					"tooltip": "A stone that can activate when it's the first zone of the world." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addFirstZoneOfWorldStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_35"); },
					"icon": null
				},
				"S88": { 
					"name": "Stone: Not First Zone of World",
					"tooltip": "A stone that can activate when it's not the first zone of the world." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addNotFirstZoneOfWorldStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_34"); },
					"icon": null
				},				
				
				//###################################################################
				//#TEST NODES AND/OR NODES THAT ARE NOT AND MAY NEVER BE IMPLEMENTED#
				//###################################################################		
				"qCc": { 
					"name": "+20% Crit Chance",
					"tooltip": "This Node does not actually exist in the game." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_CHANCE, 9 + nodeLevel)},
					"icon": "critChance"
				},
				"": {
					"name": "NULL",
					"tooltip": "Does Absolutely NOTHING.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {},
					"icon": "goldx3"
				},
				"Z01": { 
					"name": "Gem: Attempt Boss",
					"tooltip": "Automates Attempting a Boss." ,
					"flavorText": null,
					"setupFunction": function() { addAttemptBossGem(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_10");  },
					"icon": "gemAttemptBoss"
				},
				"A9": { 
					"name": "Gem: Dash",
					"tooltip": "Automates Dash." ,
					"flavorText": null,
					"setupFunction": function() { addDashGem(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_3");  },
					"icon": "gemDash"
				},
				"A27": { 
					"name": "Gem: Spend All Gold on Cheapest Upgrades",
					"tooltip": "Automates spending all gold on Cheapest Upgrades." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addUpgradeAllCheapestItemsGem(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_62"); },
					"icon": "gemUpgradeCheapest"
				},
				"Z00": { 
					"name": "Automator Slot",
					"tooltip": "Unlocks an additional slot for the Automator." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.automator.addQueueSlot(); },
					"icon": "gemAddSlot"
				},
				"Pc": { 
					"name": "Pierce Chance (NOT IN GAME)",
					"tooltip": "Adds 1% to your chance to hit an additional monster." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function(nodeLevel:Number) {CH2.currentCharacter.levelUpStat(CH2.STAT_PIERCE_CHANCE, 4 + nodeLevel)},
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
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_60"); },
					"icon": "gemBuyRandom"
				},
				"A23": { 
					"name": "Gem: Upgrade 2nd Newest Item",
					"tooltip": "Automates upgrading the Second Newest Item." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addUpgradeSecondNewestItemGem(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_61"); },
					"icon": "gemBuyRandom"
				},
				"A25": { 
					"name": "Gem: Upgrade Cheapest Item to x10",
					"tooltip": "Automates upgrading the Cheapest Item to the next Multiplier." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addUpgradeCheapestItemToNextMultiplierGem(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_63"); },
					"icon": "gemBuyRandom"
				},
				"A28": { 
					"name": "Gem: Buy Metal Detectors",
					"tooltip": "Automates buying Metal Detectors." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuyMetalDetectorsGem(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_64"); },
					"icon": "gemBuyRandom"
				},
				"A29": { 
					"name": "Gem: Buy Runes",
					"tooltip": "Automates buying Runes." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuyRunesGem(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_65"); },
					"icon": "gemBuyRandom"
				},
				"A30": { 
					"name": "Stone: World Completions < 1",
					"tooltip": "A stone that always activates on the first run of a world." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addLT1WorldCompletionsStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("LT1WorldCompletions"); },
					"icon": ""
				},
				"A31": { 
					"name": "Stone: World Completions > 1",
					"tooltip": "A stone that always activates on repeated runs of a world." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addGT1WorldCompletionsStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("GT1WorldCompletions"); },
					"icon": ""
				},
				"S09": {
					"name": "Stone: Boss Zone",
					"tooltip": "A stone that can activate during a boss fight." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBossEncounterStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_18"); },
					"icon": "gemAttemptBoss"
				},
				"S10": { 
					"name": "Stone: Crit Chance >= 100%",
					"tooltip": "A stone that can activate when your chance to score a critical hit is above 99%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addCritThresholdStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_21"); },
					"icon": "gemAddSet"
				},
				"S11": { 
					"name": "Stone: Energy more than Mana",
					"tooltip": "A stone that can activate when your energy is above your mana." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addEnergyGreaterThanManaStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_22"); },
					"icon": "EgtMIcon"
				},
				"S12": { 
					"name": "Stone: Mana more than Energy",
					"tooltip": "A stone that can activate when your mana is above your energy." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addManaGreaterThanEnergyStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_23"); },
					"icon": "MgtEIcon"
				},
				"S13": { 
					"name": "Stone: Energy less than 40%",
					"tooltip": "A stone that can activate when your energy is below 40%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addEnergyLessThan40PercentStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_24"); },
					"icon": ""
				},
				"S14": { 
					"name": "Stone: Energy more than 60%",
					"tooltip": "A stone that can activate when your energy is above 60%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addEnergyGreaterThan60PercentStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_25"); },
					"icon": ""
				},
				"S15": { 
					"name": "Stone: Mana less than 40%",
					"tooltip": "A stone that can activate when your mana is below 40%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addManaLessThan40PercentStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_26"); },
					"icon": ""
				},
				"S16": { 
					"name": "Stone: Mana more than 60%",
					"tooltip": "A stone that can activate when your mana is above 60%." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addManaGreaterThan60PercentStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_27"); },
					"icon": ""
				},
				"S17": { 
					"name": "Stone: Before First Zone Kill",
					"tooltip": "A stone that can activate before killing the first monster of a zone." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBeforeFirstZoneKillStone(); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_28"); },
					"icon": "firstMonsterIcon"
				},
				"S18": {
                    "name": "Stone: First World of System",
                    "tooltip": "A stone that can activate when you are on the first world of a Star System." ,
                    "flavorText": null,
                    "costsAutomatorPoint": true,
                    "setupFunction": function() { addFirstWorldOfGildStone(); },
                    "purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_29"); },
                    "icon": ""
                },
                "S19": {
                    "name": "Stone: Not First World of Sysem",
                    "tooltip": "A stone that can activate when you are not on the first world of a Star System." ,
                    "flavorText": null,
                    "costsAutomatorPoint": true,
                    "setupFunction": function() { addNotFirstWorldOfGildStone(); },
                    "purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_30"); },
                    "icon": ""
                },
				"S26": {
                    "name": "Stone: Next monster more than 90 cm away",
                    "tooltip": "A stone that can activate when the next monster is more than 90 cm away." ,
                    "flavorText": null,
                    "costsAutomatorPoint": true,
                    "setupFunction": function() { addGreaterThanMonsterDistanceStone(); },
                    "purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_31"); },
                    "icon": "NMgt90Icon"
                },
				"S27": {
                    "name": "Stone: Not a Boss Zone",
                    "tooltip": "A stone that can activate when you are not on a boss zone." ,
                    "flavorText": null,
                    "costsAutomatorPoint": true,
                    "setupFunction": function() { addNotABossZoneStone(); },
                    "purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_32"); },
                    "icon": "gemAttemptBoss"
                },
				"S28": {
                    "name": "Stone: Next monster less than 90 cm away",
                    "tooltip": "A stone that can activate when the next monster is less than 90 cm away." ,
                    "flavorText": null,
                    "costsAutomatorPoint": true,
                    "setupFunction": function() { addLessThanMonsterDistanceStone(); },
                    "purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_33"); },
                    "icon": "NMlt90Icon"
                },
				"S53": { 
					"name": "Stone: Autoattackstorm is not active",
					"tooltip": "A stone that can activate when Autoattackstorm is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuffComparisonStone("AutoattackstormEQ0", "Autoattackstorm = 0", "A stone that can activate when Autoattackstorm is not active.", "Autoattackstorm", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("AutoattackstormEQ0"); },
					"icon": "gemClickstorm"
				},
				"S54": { 
					"name": "Stone: Autoattackstorm is active",
					"tooltip": "A stone that can activate when Autoattackstorm is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("AutoattackstormGT0", "Autoattackstorm > 0", "A stone that can activate when Autoattackstorm is active.", "Autoattackstorm", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("AutoattackstormGT0"); },
					"icon": "gemClickstorm"
				},
				"S55": { 
					"name": "Stone: Critstorm is not active",
					"tooltip": "A stone that can activate when Critstorm is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuffComparisonStone("CritstormEQ0", "Critstorm = 0", "A stone that can activate when Critstorm is not active.", "Critstorm", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("CritstormEQ0"); },
					"icon": "gemClickstorm"
				},
				"S56": { 
					"name": "Stone: Critstorm is active",
					"tooltip": "A stone that can activate when Critstorm is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("CritstormGT0", "Critstorm > 0", "A stone that can activate when Critstorm is active.", "Critstorm", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("CritstormGT0"); },
					"icon": "gemClickstorm"
				},
				"S57": { 
					"name": "Stone: Golden Clicks is not active",
					"tooltip": "A stone that can activate when Golden Clicks is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuffComparisonStone("GoldenClicksEQ0", "Golden Clicks = 0", "A stone that can activate when Golden Clicks is not active.", "GoldenClicks", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("GoldenClicksEQ0"); },
					"icon": "gemClickstorm"
				},
				"S58": { 
					"name": "Stone: Golden Clicks is active",
					"tooltip": "A stone that can activate when Golden Clicks is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("GoldenClicksGT0", "Golden Clicks > 0", "A stone that can activate when Golden Clicks is active.", "GoldenClicks", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("GoldenClicksGT0"); },
					"icon": "gemClickstorm"
				},
				"S59": { 
					"name": "Stone: Clicktorrent is not active",
					"tooltip": "A stone that can activate when Clicktorrent is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() { addBuffComparisonStone("ClicktorrentEQ0", "Clicktorrent = 0", "A stone that can activate when Clicktorrent is not active.", "Clicktorrent", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("ClicktorrentEQ0"); },
					"icon": "gemClickstorm"
				},
				"S60": { 
					"name": "Stone: Clicktorrent is active",
					"tooltip": "A stone that can activate when Clicktorrent is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("ClicktorrentGT0", "Clicktorrent > 0", "A stone that can activate when Clicktorrent is active.", "Clicktorrent", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("ClicktorrentGT0"); },
					"icon": "gemClickstorm"
				},
				"S64": { 
					"name": "Stone: Discount is active",
					"tooltip": "A stone that can activate when Huge Click Discount is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("DiscountGT0", "Discount > 0", "A stone that can activate when Huge Click Discount is active.", "Huge Click Discount", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("DiscountGT0"); },
					"icon": "gemHugeClicks"
				},
				"S65": { 
					"name": "Stone: Preload is active",
					"tooltip": "A stone that can activate when Preload is active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("PreloadGT0", "Preload > 0", "A stone that can activate when Preload is active.", "Preload", CH2.COMPARISON_GT, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("PreloadGT0"); },
					"icon": "gemReload"
				},
				"S84": { 
					"name": "Stone: Preload is not active",
					"tooltip": "A stone that can activate when Preload is not active." ,
					"flavorText": null,
					"costsAutomatorPoint": true,
					"setupFunction": function() {addBuffComparisonStone("PreloadEQ0", "Preload = 0", "A stone that can activate when Preload is not active.", "Preload", CH2.COMPARISON_EQ, 0); },
					"purchaseFunction": function(nodeLevel:Number) { CH2.currentCharacter.automator.unlockStone("PreloadEQ0"); },
					"icon": "gemReload"
				},
				"HL": {
					"name": "Gem: Hand of Libertas", //Purchaseable through perk only, node needed for setupFunction
					"tooltip": "",
					"flavorText": null,
					"costsAutomatorPoint": false,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem("HandOfLibertas", handOfLibertas); },
					"purchaseFunction": function(nodeLevel:Number) { },
					"icon": ""
				}
			}
			
			// Stat Perks
			helpfulAdventurer.transcensionPerks["0"] = Character.transcendentStatPerk("0", CH2.STAT_GOLD, Character.getTranscendencePerkTooltipFunction(CH2.STAT_GOLD, "0"), Character.linearExponential(5, 1, 1.1), "goldx3");
			helpfulAdventurer.transcensionPerks["1"] = Character.transcendentStatPerk("1", CH2.STAT_CRIT_CHANCE, Character.getTranscendencePerkTooltipFunctionChance(CH2.STAT_CRIT_CHANCE, "1"), Character.linearExponential(5, 2, 2), "critChance");
			helpfulAdventurer.transcensionPerks["2"] = Character.transcendentStatPerk("2", CH2.STAT_CRIT_DAMAGE, Character.getTranscendencePerkTooltipFunction(CH2.STAT_CRIT_DAMAGE, "2"), Character.linearExponential(5, 1, 1.1), "critDamage");
			helpfulAdventurer.transcensionPerks["3"] = Character.transcendentStatPerk("3", CH2.STAT_HASTE, Character.getTranscendencePerkTooltipFunction(CH2.STAT_HASTE, "3"), Character.linearExponential(5, 2, 2), "haste");
			helpfulAdventurer.transcensionPerks["4"] = Character.transcendentStatPerk("4", CH2.STAT_CLICKABLE_GOLD, Character.getTranscendencePerkTooltipFunction(CH2.STAT_CLICKABLE_GOLD, "4"), Character.linearExponential(5, 1, 1.1), "clickableGold");
			helpfulAdventurer.transcensionPerks["5"] = Character.transcendentStatPerk("5", CH2.STAT_CLICK_DAMAGE, Character.getTranscendencePerkTooltipFunction(CH2.STAT_CLICK_DAMAGE, "5"), Character.linearExponential(5, 1, 1.1), "clickDamage");
			helpfulAdventurer.transcensionPerks["6"] = Character.transcendentStatPerk("6", CH2.STAT_MONSTER_GOLD, Character.getTranscendencePerkTooltipFunction(CH2.STAT_MONSTER_GOLD, "6"), Character.linearExponential(5, 1, 1.1), "bossGold");
			helpfulAdventurer.transcensionPerks["7"] = Character.transcendentStatPerk("7", CH2.STAT_ITEM_COST_REDUCTION, Character.getTranscendencePerkTooltipFunctionReduction(CH2.STAT_ITEM_COST_REDUCTION, "7"), Character.linearExponential(5, 2, 2), "itemCostReduction");
			helpfulAdventurer.transcensionPerks["8"] = Character.transcendentStatPerk("8", CH2.STAT_TOTAL_MANA, Character.getTranscendencePerkTooltipFunctionNoPercent(CH2.STAT_TOTAL_MANA, "8"), Character.linearExponential(5, 1, 1.1), "totalMana");
			helpfulAdventurer.transcensionPerks["9"] = Character.transcendentStatPerk("9", CH2.STAT_MANA_REGEN, Character.getTranscendencePerkTooltipFunction(CH2.STAT_MANA_REGEN, "9"), Character.linearExponential(5, 1, 1.1), "manaRegen");
			helpfulAdventurer.transcensionPerks["10"] = Character.transcendentStatPerk("10", CH2.STAT_TOTAL_ENERGY, Character.getTranscendencePerkTooltipFunctionNoPercent(CH2.STAT_TOTAL_ENERGY, "10"), Character.linearExponential(5, 1, 1.1), "totalEnergy");
			helpfulAdventurer.transcensionPerks["11"] = Character.transcendentStatPerk("11", CH2.STAT_BONUS_GOLD_CHANCE, Character.getTranscendencePerkTooltipFunctionChance(CH2.STAT_BONUS_GOLD_CHANCE, "11"), Character.linearExponential(5, 2, 2), "goldChance");
			helpfulAdventurer.transcensionPerks["12"] = Character.transcendentStatPerk("12", CH2.STAT_CLICKABLE_CHANCE, Character.getTranscendencePerkTooltipFunctionChance(CH2.STAT_CLICKABLE_CHANCE, "12"), Character.linearExponential(5, 2, 2), "goldPiles");
			helpfulAdventurer.transcensionPerks["13"] = Character.transcendentStatPerk("13", CH2.STAT_TREASURE_CHEST_CHANCE, Character.getTranscendencePerkTooltipFunctionChance(CH2.STAT_TREASURE_CHEST_CHANCE, "13"), Character.linearExponential(5, 2, 2), "treasureChance");
			helpfulAdventurer.transcensionPerks["14"] = Character.transcendentStatPerk("14", CH2.STAT_TREASURE_CHEST_GOLD, Character.getTranscendencePerkTooltipFunction(CH2.STAT_TREASURE_CHEST_GOLD, "14"), Character.linearExponential(5, 1, 1.1), "treasureGold");
			helpfulAdventurer.transcensionPerks["15"] = Character.transcendentStatPerk("15", CH2.STAT_ITEM_WEAPON_DAMAGE, Character.getTranscendencePerkTooltipFunction(CH2.STAT_ITEM_WEAPON_DAMAGE, "15"), Character.linearExponential(5, 1, 1.1), "damageWeapon");
			helpfulAdventurer.transcensionPerks["16"] = Character.transcendentStatPerk("16", CH2.STAT_ITEM_HEAD_DAMAGE, Character.getTranscendencePerkTooltipFunction(CH2.STAT_ITEM_HEAD_DAMAGE, "16"), Character.linearExponential(5, 1, 1.1), "damageHead");
			helpfulAdventurer.transcensionPerks["17"] = Character.transcendentStatPerk("17", CH2.STAT_ITEM_CHEST_DAMAGE, Character.getTranscendencePerkTooltipFunction(CH2.STAT_ITEM_CHEST_DAMAGE, "17"), Character.linearExponential(5, 1, 1.1), "damageTop");
			helpfulAdventurer.transcensionPerks["18"] = Character.transcendentStatPerk("18", CH2.STAT_ITEM_RING_DAMAGE, Character.getTranscendencePerkTooltipFunction(CH2.STAT_ITEM_RING_DAMAGE, "18"), Character.linearExponential(5, 1, 1.1), "damageAccesory");
			helpfulAdventurer.transcensionPerks["19"] = Character.transcendentStatPerk("19", CH2.STAT_ITEM_LEGS_DAMAGE, Character.getTranscendencePerkTooltipFunction(CH2.STAT_ITEM_LEGS_DAMAGE, "19"), Character.linearExponential(5, 1, 1.1), "damageLegs");
			helpfulAdventurer.transcensionPerks["20"] = Character.transcendentStatPerk("20", CH2.STAT_ITEM_HANDS_DAMAGE, Character.getTranscendencePerkTooltipFunction(CH2.STAT_ITEM_HANDS_DAMAGE, "20"), Character.linearExponential(5, 1, 1.1), "damageHands");
			helpfulAdventurer.transcensionPerks["21"] = Character.transcendentStatPerk("21", CH2.STAT_ITEM_FEET_DAMAGE, Character.getTranscendencePerkTooltipFunction(CH2.STAT_ITEM_FEET_DAMAGE, "21"), Character.linearExponential(5, 1, 1.1), "damageFeet");
			helpfulAdventurer.transcensionPerks["22"] = Character.transcendentStatPerk("22", CH2.STAT_ITEM_BACK_DAMAGE, Character.getTranscendencePerkTooltipFunction(CH2.STAT_ITEM_BACK_DAMAGE, "22"), Character.linearExponential(5, 1, 1.1), "damageBack");
			helpfulAdventurer.transcensionPerks["23"] = Character.transcendentStatPerk("23", CH2.STAT_AUTOMATOR_SPEED, Character.getTranscendencePerkTooltipFunction(CH2.STAT_AUTOMATOR_SPEED, "23"), Character.linearExponential(5, 2, 2), "automatorSpeed");
			helpfulAdventurer.transcensionPerks["24"] = Character.transcendentStatPerk("24", CH2.STAT_AUTOATTACK_DAMAGE, Character.getTranscendencePerkTooltipFunction(CH2.STAT_AUTOATTACK_DAMAGE, "24"), Character.linearExponential(5, 1, 1.1), "damagex3");
			
			// Trait Perks
			helpfulAdventurer.transcensionPerks["35"] = Character.transcendentTraitPerk("35", "BigClicksDamage", "Bigger Big Clicks", Character.getTraitTranscendencePerkTooltipFunction("BigClicksDamage", "35"), Character.linearExponential(5, 1, 1.1), "iconBigClicks");
			helpfulAdventurer.transcensionPerks["38"] = Character.transcendentTraitPerk("38", "HugeClickDamage", "Huger Huge Click", Character.getTraitTranscendencePerkTooltipFunction("HugeClickDamage", "38"), Character.linearExponential(5, 1, 1.1), "hugeClicks");
			helpfulAdventurer.transcensionPerks["39"] = Character.transcendentTraitPerk("39", "ManaCritDamage", "Mana Crit Damage", Character.getTraitTranscendencePerkTooltipFunction("ManaCritDamage", "39"), Character.linearExponential(5, 1, 1.1), "manaClick");
			helpfulAdventurer.transcensionPerks["40"] = Character.transcendentTraitPerk("40", "ImprovedEnergize", "Improved Energize", Character.getTraitTranscendencePerkTooltipFunction("ImprovedEnergize", "40"), Character.linearExponential(5, 1, 1.1), "energize");
			helpfulAdventurer.transcensionPerks["41"] = Character.transcendentTraitPerk("41", "SustainedPowersurge", "Sustained Powersurge", Character.getTraitTranscendencePerkTooltipFunction("SustainedPowersurge", "41"), Character.linearExponential(5, 2, 2), "powersurgeDuration");
			helpfulAdventurer.transcensionPerks["42"] = Character.transcendentTraitPerk("42", "ImprovedPowersurge", "Improved Powersurge", Character.getTraitTranscendencePerkTooltipFunction("ImprovedPowersurge", "42"), Character.linearExponential(5, 1, 1.1), "powersurgeDamage");
			helpfulAdventurer.transcensionPerks["43"] = Character.transcendentTraitPerk("43", "ImprovedReload", "Improved Reload", getImprovedReloadTranscendencePerkTooltipFunction("43"), Character.linearExponential(5, 1, 1.1), "improvedReload");
			
			// Other Perks
			helpfulAdventurer.transcensionPerks["50"] = {
				"name": "Improved Ascension",
				"description": "Increases the stat points available after ascending.",
				"tooltipFunction": Character.getTranscendencePerkTooltipFunctionCommon("50"),
				"costFunction": Character.exponentialMultiplier(5),
				"levelFunction": function() {
					CH2.currentCharacter.ascensionStartStatPoints++;
				},
				"maxLevel": -1,
				"icon": "improvedAscensionIcon"
			};
			
			// Special Perks
			helpfulAdventurer.transcensionPerks["100"] = {
				"name": "Hand of Libertas",
				"description": "Grants the Hand of Libertas skill.",
				"tooltipFunction": Character.getTranscendencePerkTooltipFunctionCommon("100"),
				"costFunction": function() { return(new BigNumber(10000)); },
				"levelFunction": function() {
					addSkill("Hand of Libertas")();
					CH2.currentCharacter.automator.unlockGem("HandOfLibertas");
					CH2.currentCharacter.setTrait("HandOfLibertas", 1, false, true, true);
				},
				"maxLevel": 1,
				"icon": "handOfLibertasIcon"
			};
			
			helpfulAdventurer.transcensionPerks["101"] = {
				"name": "Downpour",
				"description": "Greatly increases the power of Clicktorrent.",
				"tooltipFunction": Character.getTranscendencePerkTooltipFunctionCommon("101"),
				"costFunction": function() { return(new BigNumber(250000)); },
				"levelFunction": function() {
					CH2.currentCharacter.setTrait("Downpour", 1, false, true, true);
					CH2.currentCharacter.alwaysAvailableNodes[338] = true;
				},
				"maxLevel": 1,
				"icon": "damagex3"
			};
			
			helpfulAdventurer.transcensionPerks["102"] = {
				"name": "Kinetic Energy",
				"description": "Curse of the Juggernaut amplifies autoattack damage while active.",
				"tooltipFunction": Character.getTranscendencePerkTooltipFunctionCommon("102"),
				"costFunction": function() { return(new BigNumber(6000000)); },
				"levelFunction": function() {
					CH2.currentCharacter.setTrait("KineticEnergy", 1, false, true, true);
					CH2.currentCharacter.alwaysAvailableNodes[472] = true;
				},
				"maxLevel": 1,
				"icon": "kineticEnergyIcon"
			}
			
			helpfulAdventurer.transcensionPerks["103"] = {
				"name": "Clickable Value",
				"description": "Makes clickables scale with your treasure chest stats.",
				"tooltipFunction": Character.getTranscendencePerkTooltipFunctionCommon("103"),
				"costFunction": function() { return(new BigNumber(15000000)); },
				"levelFunction": function() {
					CH2.currentCharacter.clickablesHaveTreasureChestGold = true;
				},
				"maxLevel": 1,
				"icon": "clickableValueIcon"
			}
			
			helpfulAdventurer.transcensionPerks["104"] = {
				"name": "Glorious Bounty",
				"description": "Transforms Golden Clicks to make you wealthy beyond your wildest dreams (terms and conditions apply).",
				"tooltipFunction": Character.getTranscendencePerkTooltipFunctionCommon("104"),
				"costFunction": function() { return(new BigNumber(500000000)); },
				"levelFunction": function() {
					CH2.currentCharacter.setTrait("GloriousBounty", 1, false, true, true);
					CH2.currentCharacter.alwaysAvailableNodes[151] = true;
				},
				"maxLevel": 1,
				"icon": "gloriousBountyIcon"
			}
			
			helpfulAdventurer.transcensionPerks["105"] = {
				"name": "Automatic Automation",
				"description": "Start each transcension with one full copy of the Automator tree.",
				"tooltipFunction": Character.getTranscendencePerkTooltipFunctionCommon("105"),
				"costFunction": function() { return(new BigNumber(50000)); },
				"levelFunction": function() {
					CH2.currentCharacter.setTrait("AutomaticAutomation", 1, false, true, true);
				},
				"maxLevel": 1,
				"icon": "automaticAutomationIcon"
			}
			
			helpfulAdventurer.levelGraphObject = {"nodes":[{"1":{"x":0, "val":"T1", "y": -84}}, {"2":{"x":85, "val":"T2", "y": -1}}, {"3":{"x":1, "val":"T3", "y":82}}, {"4":{"x": -81, "val":"T4", "y":0}}, {"5":{"x": -211, "val":"T5", "y":131}}, {"6":{"x": -211, "val":"V", "y":0}}, {"7":{"x": -349, "val":"G", "y":196}}, {"8":{"x": -211, "val":"T8", "y":268}}, {"9":{"x": -423, "val":"V", "y": -84}}, {"10":{"x": -342, "val":"Mt", "y": -185}}, {"11":{"x": -211, "val":"T7", "y": -266}}, {"12":{"x": -71, "val":"Cd", "y": -182}}, {"13":{"x": -339, "val":"V", "y":0}}, {"14":{"x": -211, "val":"T6", "y": -134}}, {"15":{"x": -74, "val":"H", "y":197}}, {"24":{"x": -1489, "val":"Gp", "y":51}}, {"26":{"x": -389, "val":"V", "y": -329}}, {"30":{"x": -27, "val":"V", "y": -328}}, {"33":{"x": -400, "val":"V", "y":342}}, {"37":{"x": -26, "val":"V", "y":342}}, {"39":{"x": -507, "val":"V", "y": -1}}, {"40":{"x": -423, "val":"V", "y":82}}, {"41":{"x": -1036, "val":"Ir", "y": -11}}, {"42":{"x":108, "val":"V", "y": -1772}}, {"43":{"x": -4, "val":"Gc", "y": -1198}}, {"44":{"x": -8, "val":"Cc", "y": -1405}}, {"45":{"x": -457, "val":"Gp", "y": -1142}}, {"46":{"x": -503, "val":"Bd", "y": -438}}, {"47":{"x": -614, "val":"qMr", "y": -543}}, {"48":{"x":87, "val":"Cc", "y": -438}}, {"49":{"x":205, "val":"qCd", "y": -544}}, {"50":{"x": -503, "val":"Hd", "y":427}}, {"51":{"x": -614, "val":"qG", "y":520}}, {"52":{"x":86, "val":"Mu", "y":429}}, {"53":{"x":206, "val":"qH", "y":520}}, {"54":{"x": -235, "val":"Gc", "y": -2071}}, {"55":{"x": -231, "val":"Gp", "y": -1896}}, {"56":{"x": -58, "val":"Mr", "y": -1770}}, {"57":{"x":146, "val":"Bd", "y": -1468}}, {"58":{"x":1883, "val":"Aa", "y": -863}}, {"59":{"x":107, "val":"Bc", "y": -1614}}, {"60":{"x":1106, "val":"I7", "y": -119}}, {"61":{"x":254, "val":"Cc", "y": -2027}}, {"62":{"x":382, "val":"I3", "y": -2127}}, {"63":{"x": -1505, "val":"Ea", "y":224}}, {"64":{"x":1074, "val":"Bg", "y": -1851}}, {"65":{"x":1228, "val":"Cl", "y": -1868}}, {"66":{"x":1796, "val":"Tg", "y": -1561}}, {"67":{"x":1385, "val":"Gc", "y": -1875}}, {"68":{"x":1236, "val":"H", "y": -65}}, {"69":{"x":1605, "val":"Gb", "y": -1791}}, {"70":{"x":1698, "val":"G", "y": -1661}}, {"71":{"x":1622, "val":"Bc", "y": -1023}}, {"72":{"x":1890, "val":"Mu", "y": -583}}, {"73":{"x":1213, "val":"Mu", "y": -233}}, {"74":{"x":449, "val":"Mu", "y": -575}}, {"75":{"x":552, "val":"H", "y": -466}}, {"76":{"x":816, "val":"V", "y": -444}}, {"77":{"x": -893, "val":"Gp", "y": -88}}, {"78":{"x":1544, "val":"V", "y": -457}}, {"79":{"x":466, "val":"Pa", "y": -778}}, {"80":{"x":605, "val":"V", "y": -887}}, {"81":{"x":660, "val":"Pt", "y": -1069}}, {"82":{"x":1914, "val":"Hd", "y": -724}}, {"83":{"x":1920, "val":"H", "y": -215}}, {"84":{"x":1788, "val":"Bd", "y": -265}}, {"85":{"x": -262, "val":"Hd", "y":1152}}, {"86":{"x": -219, "val":"G", "y":1016}}, {"87":{"x":1674, "val":"I4", "y": -507}}, {"88":{"x":1752, "val":"Md", "y": -615}}, {"89":{"x":110, "val":"Mt", "y": -2045}}, {"90":{"x":493, "val":"G", "y": -2227}}, {"91":{"x":811, "val":"I4", "y": -2032}}, {"92":{"x":617, "val":"V", "y": -2144}}, {"93":{"x":764, "val":"Cl", "y": -2155}}, {"94":{"x":1879, "val":"Md", "y": -1304}}, {"95":{"x":1805, "val":"I8", "y": -1183}}, {"96":{"x":1744, "val":"V", "y": -942}}, {"97":{"x":1668, "val":"Aa", "y": -1241}}, {"98":{"x":1837, "val":"Md", "y": -1046}}, {"99":{"x":693, "val":"Md", "y": -767}}, {"100":{"x":1308, "val":"Pa", "y": -443}}, {"101":{"x":717, "val":"Cc", "y": -579}}, {"102":{"x":829, "val":"Hd", "y": -763}}, {"103":{"x":988, "val":"Aa", "y": -196}}, {"104":{"x":1961, "val":"Bc", "y": -342}}, {"105":{"x":603, "val":"I3", "y": -1215}}, {"106":{"x":946, "val":"G", "y": -695}}, {"107":{"x":947, "val":"Ra", "y": -841}}, {"108":{"x":776, "val":"Cd", "y": -1170}}, {"109":{"x":1348, "val":"Ir", "y": -310}}, {"110":{"x":429, "val":"Md", "y": -2002}}, {"111":{"x":970, "val":"Aa", "y": -958}}, {"112":{"x":376, "val":"Cd", "y": -1870}}, {"113":{"x":1066, "val":"Tc", "y": -1987}}, {"114":{"x":667, "val":"Bc", "y": -364}}, {"115":{"x":270, "val":"Mr", "y": -819}}, {"116":{"x":122, "val":"Aa", "y": -1312}}, {"117":{"x":207, "val":"Ea", "y": -987}}, {"118":{"x":143, "val":"I1", "y": -1147}}, {"119":{"x":555, "val":"G", "y": -1413}}, {"120":{"x":691, "val":"Cc", "y": -1329}}, {"121":{"x":951, "val":"Ir", "y": -2081}}, {"122":{"x":426, "val":"Cd", "y": -1344}}, {"123":{"x":301, "val":"Aa", "y": -1241}}, {"124":{"x":325, "val":"Md", "y": -663}}, {"125":{"x":1178, "val":"Md", "y": -364}}, {"126":{"x":1563, "val":"Mu", "y": -112}}, {"127":{"x":392, "val":"Hd", "y":2166}}, {"128":{"x":1699, "val":"I5", "y": -163}}, {"129":{"x": -1193, "val":"Gc", "y": -40}}, {"130":{"x":23, "val":"I2", "y": -1909}}, {"131":{"x": -2345, "val":"qMt", "y":618}}, {"132":{"x": -1880, "val":"qEn", "y":156}}, {"133":{"x": -2344, "val":"qGp", "y":976}}, {"134":{"x": -2246, "val":"qIr", "y":1050}}, {"135":{"x": -2258, "val":"qGc", "y":959}}, {"136":{"x": -2144, "val":"Q43", "y":787}}, {"137":{"x": -1679, "val":"qHd", "y":1158}}, {"138":{"x": -1526, "val":"qIr", "y":1279}}, {"139":{"x": -250, "val":"qBd", "y":2211}}, {"140":{"x": -1746, "val":"qG", "y":1410}}, {"141":{"x": -1598, "val":"qG", "y":971}}, {"142":{"x": -1495, "val":"Q44", "y":466}}, {"143":{"x": -1135, "val":"qGp", "y":219}}, {"144":{"x": -220, "val":"qH", "y":2076}}, {"145":{"x": -353, "val":"qMu", "y":1554}}, {"146":{"x": -1027, "val":"qBg", "y":837}}, {"147":{"x": -676, "val":"qGb", "y":1504}}, {"148":{"x": -728, "val":"qHd", "y":1213}}, {"149":{"x": -829, "val":"Q42", "y":1167}}, {"150":{"x": -810, "val":"qTc", "y":1272}}, {"151":{"x": -2178, "val":"Q41", "y":1669}}, {"152":{"x": -2178, "val":"qHd", "y":1960}}, {"153":{"x": -494, "val":"qBd", "y":2016}}, {"154":{"x": -932, "val":"Q45", "y":1926}}, {"155":{"x": -723, "val":"qTg", "y":1827}}, {"156":{"x": -1467, "val":"qG", "y":2108}}, {"157":{"x": -745, "val":"qHd", "y":2256}}, {"158":{"x": -1576, "val":"qGb", "y":1793}}, {"159":{"x": -537, "val":"qH", "y":823}}, {"160":{"x": -2104, "val":"qMr", "y":382}}, {"161":{"x": -2239, "val":"I6", "y":319}}, {"162":{"x": -2373, "val":"Gc", "y":364}}, {"163":{"x": -2388, "val":"Gp", "y":494}}, {"164":{"x": -2055, "val":"G", "y":570}}, {"165":{"x": -1799, "val":"Mt", "y":411}}, {"166":{"x": -1905, "val":"Mr", "y":286}}, {"167":{"x": -1734, "val":"V", "y":224}}, {"168":{"x": -1352, "val":"Aa", "y":404}}, {"169":{"x": -1954, "val":"En", "y":467}}, {"170":{"x": -1606, "val":"Aa", "y":340}}, {"171":{"x": -1588, "val":"Gp", "y":592}}, {"172":{"x": -1709, "val":"Gc", "y":699}}, {"173":{"x": -1845, "val":"I4", "y":782}}, {"174":{"x": -1635, "val":"Cd", "y":833}}, {"175":{"x": -1286, "val":"Cl", "y":915}}, {"176":{"x": -1912, "val":"Aa", "y":1225}}, {"177":{"x": -1837, "val":"I3", "y":1085}}, {"178":{"x": -1808, "val":"Ra", "y":925}}, {"179":{"x": -1734, "val":"V", "y":1821}}, {"180":{"x": -1787, "val":"Mr", "y":1675}}, {"181":{"x": -1439, "val":"I5", "y":941}}, {"182":{"x": -1996, "val":"Aa", "y":1956}}, {"183":{"x": -666, "val":"Hd", "y":884}}, {"184":{"x": -1383, "val":"Cd", "y":565}}, {"185":{"x": -89, "val":"Hd", "y":2073}}, {"186":{"x": -2219, "val":"G", "y":680}}, {"187":{"x": -1195, "val":"Bd", "y":368}}, {"188":{"x": -1029, "val":"Bc", "y":344}}, {"189":{"x": -1242, "val":"Cc", "y":621}}, {"190":{"x": -737, "val":"Gp", "y":414}}, {"191":{"x": -871, "val":"V", "y":334}}, {"192":{"x": -930, "val":"I8", "y":206}}, {"193":{"x": -1174, "val":"G", "y":748}}, {"194":{"x": -727, "val":"Ir", "y":624}}, {"195":{"x": -2398, "val":"I2", "y":726}}, {"196":{"x": -2391, "val":"Hd", "y":854}}, {"197":{"x": -2033, "val":"Hd", "y":147}}, {"198":{"x": -2179, "val":"Ra", "y":167}}, {"199":{"x": -968, "val":"Tg", "y":704}}, {"200":{"x": -447, "val":"Ir", "y":1162}}, {"201":{"x": -874, "val":"Tc", "y":595}}, {"202":{"x": -1141, "val":"Tc", "y":935}}, {"203":{"x": -2358, "val":"Md", "y":1760}}, {"204":{"x": -411, "val":"V", "y":897}}, {"205":{"x": -390, "val":"Aa", "y":1033}}, {"206":{"x": -2299, "val":"Pa", "y":1884}}, {"207":{"x": -588, "val":"I1", "y":1170}}, {"208":{"x": -667, "val":"Bg", "y":1064}}, {"209":{"x": -772, "val":"G", "y":970}}, {"210":{"x": -880, "val":"Gb", "y":875}}, {"211":{"x": -1387, "val":"Hd", "y":1074}}, {"212":{"x": -1396, "val":"G", "y":1214}}, {"213":{"x": -1817, "val":"I7", "y":1968}}, {"214":{"x": -1459, "val":"Ea", "y":1405}}, {"215":{"x": -1074, "val":"V", "y":1906}}, {"216":{"x": -606, "val":"Pa", "y":2310}}, {"217":{"x": -1637, "val":"Pt", "y":2026}}, {"218":{"x": -1288, "val":"Cc", "y":2114}}, {"219":{"x": -1105, "val":"Cd", "y":2170}}, {"220":{"x": -923, "val":"Md", "y":2212}}, {"221":{"x": -1108, "val":"Bd", "y":2039}}, {"222":{"x": -970, "val":"V", "y":1142}}, {"223":{"x": -987, "val":"Tg", "y":1269}}, {"224":{"x": -1005, "val":"Ir", "y":1398}}, {"225":{"x": -850, "val":"Gb", "y":1397}}, {"226":{"x": -564, "val":"Gp", "y":1427}}, {"227":{"x": -347, "val":"Mu", "y":1274}}, {"228":{"x": -532, "val":"G", "y":1292}}, {"229":{"x": -2308, "val":"Aa", "y":209}}, {"230":{"x": -320, "val":"H", "y":1415}}, {"231":{"x": -278, "val":"I3", "y":1683}}, {"232":{"x": -216, "val":"Bd", "y":1802}}, {"233":{"x": -405, "val":"Ea", "y":1714}}, {"234":{"x": -559, "val":"Gb", "y":1748}}, {"235":{"x": -569, "val":"Bg", "y":1878}}, {"236":{"x": -973, "val":"Bg", "y":1535}}, {"237":{"x": -501, "val":"Gc", "y":1544}}, {"238":{"x": -166, "val":"Bc", "y":1933}}, {"239":{"x": -958, "val":"Ra", "y":1677}}, {"240":{"x": -638, "val":"Aa", "y":2038}}, {"241":{"x": -31, "val":"Mu", "y":2188}}, {"242":{"x": -130, "val":"H", "y":2266}}, {"243":{"x": -575, "val":"Pt", "y":2166}}, {"244":{"x": -151, "val":"Cl", "y":2160}}, {"245":{"x": -472, "val":"I5", "y":2260}}, {"246":{"x": -1961, "val":"Tg", "y":930}}, {"247":{"x": -2116, "val":"Tc", "y":943}}, {"248":{"x": -2368, "val":"Gc", "y":1371}}, {"249":{"x": -1847, "val":"Hd", "y":1536}}, {"250":{"x": -2362, "val":"Gp", "y":1511}}, {"251":{"x": -1257, "val":"Ra", "y":1171}}, {"252":{"x": -1959, "val":"Mt", "y":1422}}, {"253":{"x": -2153, "val":"G", "y":1183}}, {"254":{"x": -2313, "val":"I1", "y":1253}}, {"255":{"x": -2361, "val":"Cd", "y":1115}}, {"256":{"x": -1110, "val":"Aa", "y":1152}}, {"257":{"x": -2059, "val":"V", "y":1307}}, {"258":{"x": -2173, "val":"Cd", "y":1390}}, {"259":{"x": -2327, "val":"I8", "y":1639}}, {"260":{"x": -510, "val":"Ea", "y":637}}, {"261":{"x": -408, "val":"Aa", "y":749}}, {"262":{"x": -745, "val":"Ir", "y":1685}}, {"263":{"x": -870, "val":"Aa", "y":1783}}, {"264":{"x": -1932, "val":"Cl", "y":644}}, {"265":{"x": -2155, "val":"Cc", "y":1533}}, {"266":{"x": -1996, "val":"V", "y":772}}, {"267":{"x": -344, "val":"Aa", "y":1829}}, {"268":{"x": -2036, "val":"Hd", "y":1719}}, {"269":{"x": -1890, "val":"Cl", "y":1776}}, {"270":{"x": -615, "val":"V", "y":1631}}, {"271":{"x": -1427, "val":"G", "y":1843}}, {"272":{"x": -1332, "val":"Gc", "y":1970}}, {"273":{"x": -1077, "val":"G", "y":1766}}, {"274":{"x": -438, "val":"I4", "y":1910}}, {"275":{"x": -1628, "val":"Aa", "y":1497}}, {"276":{"x": -1474, "val":"Aa", "y":1552}}, {"277":{"x": -1410, "val":"I6", "y":1697}}, {"278":{"x": -1245, "val":"Hd", "y":1736}}, {"279":{"x": -2276, "val":"Gb", "y":814}}, {"280":{"x": -1032, "val":"I2", "y":1020}}, {"281":{"x":751, "val":"Md", "y": -1903}}, {"282":{"x":370, "val":"Cl", "y": -1569}}, {"283":{"x":237, "val":"Cc", "y": -1659}}, {"284":{"x":997, "val":"Cl", "y": -1646}}, {"285":{"x":882, "val":"Cd", "y": -1742}}, {"286":{"x":816, "val":"Md", "y": -1421}}, {"287":{"x":847, "val":"V", "y": -1613}}, {"288":{"x":1100, "val":"Pt", "y": -1543}}, {"289":{"x":1100, "val":"Cc", "y": -1421}}, {"290":{"x":1228, "val":"I2", "y": -1080}}, {"291":{"x": -12, "val":"qG", "y":1367}}, {"292":{"x":266, "val":"qHd", "y":1504}}, {"293":{"x":263, "val":"Q89", "y":803}}, {"294":{"x":543, "val":"qH", "y":932}}, {"295":{"x": -151, "val":"qBg", "y":766}}, {"296":{"x":802, "val":"Q84", "y":1253}}, {"297":{"x":752, "val":"qCd", "y":154}}, {"298":{"x":454, "val":"qBd", "y":1140}}, {"299":{"x":658, "val":"qH", "y":1374}}, {"300":{"x":930, "val":"Q82", "y":726}}, {"301":{"x":1132, "val":"qHd", "y":961}}, {"302":{"x":1464, "val":"Q86", "y":1926}}, {"303":{"x":1258, "val":"Q85", "y":1304}}, {"304":{"x":1622, "val":"qCl", "y":314}}, {"305":{"x":526, "val":"qTg", "y":1785}}, {"306":{"x":651, "val":"qIr", "y":2068}}, {"307":{"x":1088, "val":"qH", "y":1534}}, {"308":{"x":1227, "val":"qMu", "y":1810}}, {"309":{"x":607, "val":"qBc", "y":996}}, {"310":{"x":1240, "val":"qBd", "y":2235}}, {"311":{"x":1882, "val":"qHd", "y":1351}}, {"312":{"x":782, "val":"qH", "y":851}}, {"313":{"x":772, "val":"qHd", "y":644}}, {"314":{"x":768, "val":"qH", "y":510}}, {"315":{"x":1401, "val":"qBd", "y":908}}, {"316":{"x":1632, "val":"Aa", "y":178}}, {"317":{"x":1502, "val":"Hd", "y":1020}}, {"318":{"x":893, "val":"Cd", "y":1437}}, {"319":{"x":1373, "val":"H", "y":1802}}, {"320":{"x":1570, "val":"Bc", "y":1646}}, {"321":{"x":1203, "val":"Cl", "y":2006}}, {"322":{"x":774, "val":"Aa", "y":2120}}, {"323":{"x":978, "val":"V", "y":1332}}, {"324":{"x":624, "val":"Aa", "y":72}}, {"325":{"x":1771, "val":"Mu", "y":1833}}, {"326":{"x":1518, "val":"Q83", "y":607}}, {"327":{"x":1750, "val":"I6", "y":452}}, {"328":{"x":1774, "val":"Cd", "y":311}}, {"329":{"x":1709, "val":"Aa", "y":678}}, {"330":{"x":1667, "val":"Cd", "y":807}}, {"331":{"x":1555, "val":"Md", "y":893}}, {"332":{"x":1050, "val":"Pa", "y":236}}, {"333":{"x":1555, "val":"Bd", "y":445}}, {"334":{"x":629, "val":"Md", "y":284}}, {"335":{"x":1325, "val":"Cd", "y":236}}, {"336":{"x":1183, "val":"I7", "y":279}}, {"337":{"x":23, "val":"V", "y":1186}}, {"338":{"x":943, "val":"Q88", "y":1937}}, {"339":{"x":653, "val":"I8", "y":416}}, {"340":{"x":331, "val":"Cd", "y":426}}, {"341":{"x":242, "val":"Cl", "y":1194}}, {"342":{"x":385, "val":"V", "y":687}}, {"343":{"x":927, "val":"Mu", "y":433}}, {"344":{"x":1474, "val":"En", "y":761}}, {"345":{"x": -24, "val":"I2", "y":1505}}, {"346":{"x":90, "val":"Gp", "y":1583}}, {"347":{"x":229, "val":"Bc", "y":1634}}, {"348":{"x":673, "val":"H", "y":1717}}, {"349":{"x":778, "val":"Bd", "y":1606}}, {"350":{"x":989, "val":"Mu", "y":2233}}, {"351":{"x":1472, "val":"Pt", "y":184}}, {"352":{"x":1078, "val":"V", "y":692}}, {"353":{"x":898, "val":"V", "y":2148}}, {"354":{"x":1492, "val":"I1", "y":1541}}, {"355":{"x":852, "val":"H", "y":1839}}, {"356":{"x":1435, "val":"Aa", "y":1173}}, {"357":{"x":1381, "val":"Ea", "y":2191}}, {"358":{"x":941, "val":"Mu", "y":1096}}, {"359":{"x":1913, "val":"G", "y":1479}}, {"360":{"x":1303, "val":"Bd", "y":1153}}, {"361":{"x":1077, "val":"H", "y":1111}}, {"362":{"x":1891, "val":"Cl", "y":1612}}, {"363":{"x":1791, "val":"Aa", "y":1702}}, {"364":{"x":1222, "val":"V", "y":1581}}, {"365":{"x":1828, "val":"I5", "y":1216}}, {"366":{"x": -129, "val":"Gb", "y":1269}}, {"367":{"x":496, "val":"Hd", "y":409}}, {"368":{"x":818, "val":"Cl", "y":348}}, {"369":{"x":1362, "val":"Mu", "y":1596}}, {"370":{"x":1094, "val":"I6", "y":1385}}, {"371":{"x":1123, "val":"I8", "y":1897}}, {"372":{"x":115, "val":"G", "y":624}}, {"373":{"x":1695, "val":"Mu", "y":1261}}, {"374":{"x":662, "val":"Cl", "y":752}}, {"375":{"x":522, "val":"Mu", "y":807}}, {"376":{"x":521, "val":"H", "y":660}}, {"377":{"x":259, "val":"Tc", "y":1947}}, {"378":{"x":216, "val":"Aa", "y":1805}}, {"379":{"x":511, "val":"Tg", "y":2079}}, {"380":{"x":1065, "val":"H", "y":555}}, {"381":{"x":90, "val":"Bg", "y":1726}}, {"382":{"x":1807, "val":"H", "y":1062}}, {"383":{"x":1754, "val":"Bd", "y":920}}, {"384":{"x":1415, "val":"H", "y":431}}, {"385":{"x":1312, "val":"Mu", "y":502}}, {"386":{"x":1214, "val":"Bc", "y":596}}, {"387":{"x":921, "val":"Aa", "y":913}}, {"388":{"x":841, "val":"Cl", "y":1012}}, {"389":{"x":1207, "val":"Cl", "y":791}}, {"390":{"x":913, "val":"Bd", "y":575}}, {"391":{"x":1329, "val":"I4", "y":699}}, {"392":{"x":956, "val":"Hd", "y":1594}}, {"393":{"x": -76, "val":"Tc", "y":994}}, {"394":{"x":388, "val":"Hd", "y":947}}, {"395":{"x":233, "val":"Bd", "y":932}}, {"396":{"x":626, "val":"H", "y":1173}}, {"397":{"x":985, "val":"G", "y":2058}}, {"398":{"x":916, "val":"Mr", "y":1210}}, {"399":{"x":1500, "val":"I7", "y":2109}}, {"400":{"x":380, "val":"I4", "y":1419}}, {"401":{"x":492, "val":"G", "y":1500}}, {"402":{"x":633, "val":"Cl", "y":1532}}, {"403":{"x": -45, "val":"I1", "y":865}}, {"404":{"x":1544, "val":"Cl", "y":1290}}, {"405":{"x":273, "val":"Aa", "y":1066}}, {"406":{"x":366, "val":"Mt", "y":1244}}, {"407":{"x":723, "val":"I3", "y":1072}}, {"408":{"x":1695, "val":"qH", "y":1609}}, {"409":{"x":35, "val":"Tg", "y":744}}, {"410":{"x":903, "val":"Cc", "y":173}}, {"411":{"x": -141, "val":"Gc", "y":1409}}, {"412":{"x":518, "val":"Bc", "y":1266}}, {"413":{"x":1355, "val":"Cl", "y":1033}}, {"414":{"x":1137, "val":"Hd", "y":1690}}, {"415":{"x":1214, "val":"Bd", "y":1441}}, {"416":{"x":394, "val":"I3", "y":1985}}, {"417":{"x":85, "val":"H", "y":906}}, {"418":{"x":248, "val":"I5", "y":672}}, {"419":{"x": -104, "val":"Ir", "y":1128}}, {"420":{"x":1055, "val":"G", "y":846}}, {"421":{"x":1067, "val":"Hd", "y":1234}}, {"422":{"x":129, "val":"Ra", "y":1275}}, {"423":{"x":1507, "val":"Hd", "y":1754}}, {"424":{"x":254, "val":"H", "y":1343}}, {"425":{"x":1207, "val":"I2", "y":1068}}, {"426":{"x":1035, "val":"H", "y":1795}}, {"427":{"x":1436, "val":"Cd", "y":1423}}, {"428":{"x":117, "val":"Q87", "y":1085}}, {"429":{"x":766, "val":"Mu", "y":1469}}, {"430":{"x":345, "val":"Bd", "y":561}}, {"431":{"x":376, "val":"G", "y":1822}}, {"432":{"x":879, "val":"Aa", "y":1703}}, {"433":{"x":1577, "val":"V", "y":2003}}, {"434":{"x":736, "val":"H", "y":245}}, {"435":{"x":1111, "val":"Aa", "y":2262}}, {"436":{"x":1320, "val":"G", "y":2080}}, {"437":{"x":1651, "val":"V", "y":548}}, {"438":{"x":1685, "val":"Bd", "y":1930}}, {"439":{"x":1397, "val":"V", "y":1301}}, {"440":{"x":1199, "val":"qHd", "y":412}}, {"441":{"x":602, "val":"qH", "y": -666}}, {"442":{"x":596, "val":"qBd", "y": -2007}}, {"443":{"x":259, "val":"Q63", "y": -1801}}, {"444":{"x":728, "val":"Q64", "y": -1547}}, {"445":{"x":502, "val":"qBd", "y": -1774}}, {"446":{"x":507, "val":"qMd", "y": -1546}}, {"447":{"x":845, "val":"qCd", "y": -1274}}, {"448":{"x":1225, "val":"qCd", "y": -551}}, {"449":{"x":1577, "val":"qCd", "y": -1359}}, {"450":{"x":848, "val":"qCl", "y": -1044}}, {"451":{"x":1080, "val":"qCd", "y": -1044}}, {"452":{"x":1454, "val":"Q61", "y": -552}}, {"453":{"x":729, "val":"qCd", "y": -1769}}, {"454":{"x":1078, "val":"qMd", "y": -1271}}, {"455":{"x":1224, "val":"Q66", "y": -774}}, {"456":{"x":1453, "val":"qMd", "y": -775}}, {"457":{"x":216, "val":"qEn", "y": -2168}}, {"458":{"x":299, "val":"qMr", "y": -1451}}, {"459":{"x":420, "val":"qHd", "y": -406}}, {"460":{"x":920, "val":"qGb", "y": -1862}}, {"461":{"x":1895, "val":"qIr", "y": -1446}}, {"462":{"x":778, "val":"Q62", "y": -914}}, {"463":{"x":1262, "val":"Q65", "y": -1272}}, {"464":{"x":1378, "val":"qMu", "y": -94}}, {"465":{"x":1861, "val":"qH", "y": -444}}, {"466":{"x":347, "val":"qMt", "y": -1062}}, {"467":{"x":1339, "val":"qG", "y": -1683}}, {"468":{"x":1018, "val":"qBd", "y": -587}}, {"469":{"x":1487, "val":"qCl", "y": -967}}, {"470":{"x":1624, "val":"qBd", "y": -271}}, {"471":{"x": -2253, "val":"Q27", "y": -908}}, {"472":{"x": -1910, "val":"Q26", "y": -565}}, {"473":{"x": -1650, "val":"Q30", "y": -1470}}, {"474":{"x": -1331, "val":"qMt", "y": -1142}}, {"475":{"x": -1068, "val":"Q24", "y": -692}}, {"476":{"x": -2143, "val":"qBd", "y": -1744}}, {"477":{"x": -553, "val":"qCd", "y": -2256}}, {"478":{"x": -2244, "val":"qGc", "y": -586}}, {"479":{"x": -1896, "val":"qIr", "y": -244}}, {"480":{"x": -2085, "val":"qMt", "y": -741}}, {"481":{"x": -1322, "val":"qMr", "y": -820}}, {"482":{"x": -1059, "val":"qTg", "y": -370}}, {"483":{"x": -2133, "val":"Q21", "y": -1422}}, {"484":{"x": -544, "val":"Q28", "y": -1934}}, {"485":{"x": -2233, "val":"Q23", "y": -359}}, {"486":{"x": -1890, "val":"qBg", "y": -17}}, {"487":{"x": -2121, "val":"qGp", "y": -467}}, {"488":{"x": -1311, "val":"Q25", "y": -593}}, {"489":{"x": -1048, "val":"qG", "y": -143}}, {"490":{"x": -2123, "val":"qGp", "y": -1195}}, {"491":{"x": -533, "val":"qMd", "y": -1707}}, {"492":{"x": -1782, "val":"qGc", "y": -1543}}, {"493":{"x": -1848, "val":"qEn", "y": -1285}}, {"494":{"x": -2012, "val":"Q29", "y": -1132}}, {"495":{"x": -673, "val":"qBd", "y": -1890}}, {"496":{"x": -630, "val":"qCl", "y": -1677}}, {"497":{"x": -793, "val":"qBd", "y": -924}}, {"498":{"x": -1265, "val":"qEn", "y": -2024}}, {"499":{"x": -813, "val":"Q22", "y": -1473}}, {"500":{"x": -803, "val":"qCd", "y": -1151}}, {"501":{"x": -2384, "val":"Cd", "y": -492}}, {"502":{"x": -2365, "val":"I6", "y": -614}}, {"503":{"x": -2391, "val":"Mu", "y": -746}}, {"504":{"x": -2389, "val":"Aa", "y": -878}}, {"505":{"x": -1729, "val":"I3", "y": -54}}, {"506":{"x": -1743, "val":"Mr", "y": -181}}, {"507":{"x": -1623, "val":"Aa", "y": -321}}, {"508":{"x": -1514, "val":"Ra", "y": -423}}, {"509":{"x": -2039, "val":"Hd", "y": -1317}}, {"510":{"x": -1777, "val":"V", "y": -309}}, {"511":{"x": -1385, "val":"Bg", "y": -111}}, {"512":{"x": -1757, "val":"En", "y": -431}}, {"513":{"x": -1738, "val":"I5", "y": -561}}, {"514":{"x": -1804, "val":"V", "y": -670}}, {"515":{"x": -2025, "val":"Gp", "y": -210}}, {"516":{"x": -2035, "val":"Aa", "y": -326}}, {"517":{"x": -1951, "val":"V", "y": -776}}, {"518":{"x": -1827, "val":"Gc", "y": -840}}, {"519":{"x": -2115, "val":"Pt", "y": -905}}, {"520":{"x": -2358, "val":"I8", "y": -1008}}, {"521":{"x": -2353, "val":"Cc", "y": -372}}, {"522":{"x": -2312, "val":"V", "y": -251}}, {"523":{"x": -2336, "val":"Pt", "y": -1126}}, {"524":{"x": -2314, "val":"Aa", "y": -1248}}, {"525":{"x": -2262, "val":"Pa", "y": -1372}}, {"526":{"x": -2253, "val":"G", "y": -1505}}, {"527":{"x": -1991, "val":"Cd", "y": -1781}}, {"528":{"x": -1984, "val":"Cd", "y": -651}}, {"529":{"x": -2100, "val":"Cc", "y": -593}}, {"530":{"x": -1739, "val":"H", "y": -1674}}, {"531":{"x": -2030, "val":"I1", "y": -1520}}, {"532":{"x": -1799, "val":"Md", "y": -1409}}, {"533":{"x": -1944, "val":"V", "y": -1410}}, {"534":{"x": -656, "val":"Mr", "y": -1517}}, {"535":{"x": -1837, "val":"Ir", "y": -1793}}, {"536":{"x": -1364, "val":"I2", "y": -447}}, {"537":{"x": -1585, "val":"Mt", "y": -569}}, {"538":{"x": -1279, "val":"G", "y": -317}}, {"539":{"x": -1213, "val":"V", "y": -174}}, {"540":{"x": -1180, "val":"Gp", "y": -465}}, {"541":{"x": -926, "val":"Tc", "y": -216}}, {"542":{"x": -854, "val":"Tg", "y": -341}}, {"543":{"x": -1454, "val":"Gp", "y": -638}}, {"544":{"x": -1535, "val":"Cc", "y": -759}}, {"545":{"x": -2156, "val":"G", "y": -239}}, {"546":{"x": -985, "val":"V", "y": -814}}, {"547":{"x": -2191, "val":"Bd", "y": -811}}, {"548":{"x": -1597, "val":"Aa", "y": -1049}}, {"549":{"x": -1038, "val":"Cl", "y": -946}}, {"550":{"x": -1186, "val":"Ea", "y": -883}}, {"551":{"x": -1437, "val":"Aa", "y": -1249}}, {"552":{"x": -1703, "val":"Mu", "y": -776}}, {"553":{"x": -2118, "val":"Aa", "y": -1024}}, {"554":{"x": -2216, "val":"Ra", "y": -1104}}, {"555":{"x": -1736, "val":"Ea", "y": -1086}}, {"556":{"x": -1720, "val":"Mr", "y": -1220}}, {"557":{"x": -1627, "val":"En", "y": -903}}, {"558":{"x": -1468, "val":"Cd", "y": -874}}, {"559":{"x": -1527, "val":"Aa", "y": -1344}}, {"560":{"x": -1575, "val":"I2", "y": -1184}}, {"561":{"x": -1375, "val":"Bd", "y": -1515}}, {"562":{"x": -1509, "val":"V", "y": -1480}}, {"563":{"x": -1980, "val":"I7", "y": -907}}, {"564":{"x": -1847, "val":"Gp", "y": -970}}, {"565":{"x": -1876, "val":"V", "y": -1108}}, {"566":{"x": -1355, "val":"Aa", "y": -1370}}, {"567":{"x": -1203, "val":"Ra", "y": -1413}}, {"568":{"x": -1674, "val":"Gp", "y": -1345}}, {"569":{"x": -1560, "val":"Ir", "y": -70}}, {"570":{"x": -901, "val":"Mt", "y": -1863}}, {"571":{"x": -949, "val":"Pa", "y": -2061}}, {"572":{"x": -896, "val":"En", "y": -1720}}, {"573":{"x": -654, "val":"I7", "y": -1196}}, {"574":{"x": -804, "val":"I5", "y": -1979}}, {"575":{"x": -714, "val":"Gp", "y": -2087}}, {"576":{"x": -517, "val":"Pa", "y": -1444}}, {"577":{"x": -428, "val":"Pt", "y": -1564}}, {"578":{"x": -377, "val":"I6", "y": -1708}}, {"579":{"x": -554, "val":"Aa", "y": -2110}}, {"580":{"x": -408, "val":"V", "y": -2012}}, {"581":{"x": -356, "val":"Cd", "y": -1857}}, {"582":{"x": -333, "val":"Cc", "y": -2128}}, {"583":{"x": -408, "val":"Md", "y": -2227}}, {"584":{"x": -712, "val":"Aa", "y": -2225}}, {"585":{"x": -850, "val":"Pt", "y": -2168}}, {"586":{"x": -782, "val":"V", "y": -1621}}, {"587":{"x": -2033, "val":"Tc", "y": -1}}, {"588":{"x": -1022, "val":"G", "y": -1647}}, {"589":{"x": -2247, "val":"I4", "y": -141}}, {"590":{"x": -1120, "val":"V", "y": -1141}}, {"591":{"x": -1218, "val":"Mu", "y": -1625}}, {"592":{"x": -686, "val":"Cc", "y": -789}}, {"593":{"x": -1404, "val":"H", "y": -1951}}, {"594":{"x": -1219, "val":"En", "y": -1237}}, {"595":{"x": -1191, "val":"Mt", "y": -1023}}, {"596":{"x": -1606, "val":"I3", "y": -1728}}, {"597":{"x": -2206, "val":"Cl", "y": -1632}}, {"598":{"x": -2126, "val":"Tg", "y": -101}}, {"599":{"x": -2263, "val":"Bc", "y": -706}}, {"600":{"x": -1106, "val":"Aa", "y": -2067}}, {"601":{"x": -846, "val":"I8", "y": -756}}, {"602":{"x": -1403, "val":"Bc", "y": -1663}}, {"603":{"x": -710, "val":"H", "y": -1372}}, {"604":{"x": -901, "val":"Aa", "y": -1012}}, {"605":{"x": -643, "val":"Cd", "y": -935}}, {"606":{"x": -594, "val":"Aa", "y": -1068}}, {"607":{"x": -962, "val":"Mr", "y": -1162}}, {"608":{"x": -576, "val":"Aa", "y": -1304}}, {"609":{"x": -1231, "val":"Aa", "y": -710}}, {"610":{"x": -1162, "val":"Gc", "y": -595}}, {"611":{"x": -1295, "val":"V", "y": -1753}}, {"612":{"x": -1105, "val":"I4", "y": -1522}}, {"613":{"x": -955, "val":"Hd", "y": -1513}}, {"614":{"x": -1998, "val":"Ea", "y": -442}}, {"615":{"x": -1247, "val":"Gc", "y": -1887}}, {"616":{"x": -1537, "val":"Ea", "y": -1615}}, {"617":{"x": -1515, "val":"Bd", "y": -1841}}, {"618":{"x": -935, "val":"I1", "y": -442}}, {"619":{"x": -809, "val":"G", "y": -535}}, {"620":{"x": -725, "val":"En", "y": -654}}, {"621":{"x":1567, "val":"Ra", "y": -1601}}, {"622":{"x":1492, "val":"Pt", "y": -1477}}, {"623":{"x":1186, "val":"Md", "y": -1681}}, {"624":{"x":1248, "val":"Bd", "y": -1529}}, {"625":{"x":1317, "val":"V", "y": -1404}}, {"626":{"x":1248, "val":"Cc", "y": -900}}, {"627":{"x":1363, "val":"Pa", "y": -1158}}, {"628":{"x":1528, "val":"Hd", "y": -1212}}, {"629":{"x":1440, "val":"I7", "y": -1325}}, {"630":{"x":1633, "val":"Cc", "y": -699}}, {"631":{"x":1583, "val":"I1", "y": -838}}, {"632":{"x":1453, "val":"Hd", "y": -216}}, {"633":{"x":1727, "val":"Aa", "y": -384}}, {"634":{"x":812, "val":"Bd", "y": -284}}, {"635":{"x":389, "val":"Pt", "y": -1697}}, {"636":{"x":957, "val":"I8", "y": -340}}, {"637":{"x":1017, "val":"Cl", "y": -456}}, {"638":{"x":1336, "val":"Ir", "y": -759}}, {"639":{"x":1370, "val":"Cd", "y": -887}}, {"640":{"x":1338, "val":"V", "y": -628}}, {"641":{"x":111, "val":"Aa", "y":2223}}, {"642":{"x":256, "val":"Bc", "y":2211}}, {"643":{"x":454, "val":"Cc", "y": -1153}}, {"644":{"x":956, "val":"G", "y": -1138}}, {"645":{"x":1104, "val":"Cl", "y": -1165}}, {"646":{"x":1339, "val":"V", "y": -1007}}, {"647":{"x":933, "val":"I5", "y": -1507}}, {"648":{"x":1489, "val":"Cl", "y": -664}}, {"649":{"x":605, "val":"Aa", "y": -1651}}, {"650":{"x":615, "val":"Pa", "y": -1793}}, {"651":{"x":968, "val":"Cd", "y": -1377}}, {"652":{"x":1076, "val":"Bd", "y": -749}}, {"653":{"x":1189, "val":"I6", "y": -667}}, {"654":{"x":1472, "val":"H", "y": -353}}, {"655":{"x":1730, "val":"Pt", "y": -802}}, {"656":{"x":1480, "val":"Md", "y": -1087}}, {"657":{"x":525, "val":"Aa", "y": -1901}}, {"658":{"x":1457, "val":"I6", "y": -1760}}, {"659":{"x":520, "val":"Cl", "y": -1012}}, {"660":{"x":468, "val":"Bd", "y": -165}}, {"661":{"x":524, "val":"H", "y": -35}}, {"662":{"x":1314, "val":"Cd", "y":44}}, {"663":{"x":1206, "val":"Mu", "y":134}}, {"664":{"x":1904, "val":"Cd", "y": -78}}, {"665":{"x":1912, "val":"Md", "y":60}}, {"666":{"x":1858, "val":"H", "y":191}}, {"667":{"x": -370, "val":"Cd", "y": -1440}}, {"668":{"x": -25, "val":"Md", "y": -1611}}, {"669":{"x": -2362, "val":"Gc", "y": -61}}, {"670":{"x": -2211, "val":"Bd", "y":29}}, {"671":{"x": -36, "val":"Ir", "y":1704}}, {"672":{"x": -152, "val":"Hd", "y":1621}}, {"673":{"x": -2361, "val":"Gp", "y":93}}, {"674":{"x":559, "val":"Cd", "y": -270}}, {"35":{"x":15743, "val":"A00", "y": -127}}, {"18":{"x":15743, "val":"A39", "y": -2}}, {"825":{"x":15743, "val":"A21", "y": -237}}, {"790":{"x":15743, "val":"A20", "y": -352}}, {"845":{"x":15743, "val":"A26", "y": -455}}, {"32":{"x":15631, "val":"A05", "y": -61}}, {"28":{"x":15634, "val":"A08", "y": -192}}, {"828":{"x":15847, "val":"S25", "y": -190}}, {"21":{"x":15849, "val":"A02", "y": -62}}, {"20":{"x":15526, "val":"A07", "y": -261}}, {"801":{"x":15963, "val":"S24", "y": -263}}, {"811":{"x":16067, "val":"S23", "y": -329}}, {"819":{"x":15952, "val":"S03", "y":3}}, {"799":{"x":15527, "val":"S62", "y":3}}, {"791":{"x":15638, "val":"A22", "y": -542}}, {"787":{"x":15849, "val":"A28", "y": -541}}, {"778":{"x":15638, "val":"A23", "y": -638}}, {"822":{"x":15638, "val":"A24", "y": -733}}, {"779":{"x":15849, "val":"A29", "y": -639}}, {"788":{"x":15849, "val":"S64", "y": -733}}, {"829":{"x":15743, "val":"A25", "y": -830}}, {"818":{"x":16081, "val":"S22", "y": -431}}, {"807":{"x":16093, "val":"S01", "y": -534}}, {"813":{"x":16182, "val":"S02", "y": -604}}, {"783":{"x":16272, "val":"S10", "y": -660}}, {"805":{"x":16375, "val":"S09", "y": -650}}, {"827":{"x":16479, "val":"S20", "y": -635}}, {"856":{"x":16461, "val":"S27", "y": -518}}, {"848":{"x":16444, "val":"S17", "y": -421}}, {"843":{"x":16364, "val":"S08", "y": -359}}, {"820":{"x":16274, "val":"S07", "y": -310}}, {"782":{"x":16175, "val":"S21", "y": -316}}, {"826":{"x":15045, "val":"S73", "y":390}}, {"781":{"x":15053, "val":"S72", "y":280}}, {"812":{"x":15068, "val":"S71", "y":178}}, {"806":{"x":15145, "val":"S70", "y":107}}, {"809":{"x":15226, "val":"S69", "y":53}}, {"824":{"x":15329, "val":"S68", "y":59}}, {"808":{"x":15422, "val":"S63", "y":70}}, {"821":{"x":15344, "val":"S81", "y":325}}, {"802":{"x":15265, "val":"S82", "y":392}}, {"800":{"x":15154, "val":"S83", "y":394}}, {"846":{"x":15014, "val":"A13", "y": -606}}, {"832":{"x":15099, "val":"S58", "y": -622}}, {"836":{"x":15221, "val":"S60", "y": -643}}, {"816":{"x":15303, "val":"S59", "y": -585}}, {"814":{"x":15392, "val":"A12", "y": -519}}, {"25":{"x":15408, "val":"S51", "y": -432}}, {"16":{"x":15427, "val":"A04", "y": -326}}, {"19":{"x":15324, "val":"S52", "y": -301}}, {"38":{"x":15210, "val":"A06", "y": -282}}, {"23":{"x":15130, "val":"S66", "y": -341}}, {"31":{"x":15059, "val":"S67", "y": -399}}, {"840":{"x":15031, "val":"S57", "y": -508}}, {"833":{"x":16056, "val":"S05", "y":62}}, {"797":{"x":16162, "val":"S04", "y":52}}, {"777":{"x":16273, "val":"S14", "y":47}}, {"776":{"x":16348, "val":"S13", "y":114}}, {"815":{"x":16416, "val":"S11", "y":184}}, {"796":{"x":16430, "val":"S12", "y":294}}, {"795":{"x":16440, "val":"S61", "y":385}}, {"857":{"x":16334, "val":"S84", "y":397}}, {"786":{"x":16220, "val":"S65", "y":406}}, {"792":{"x":16138, "val":"S15", "y":329}}, {"785":{"x":16074, "val":"S16", "y":269}}, {"775":{"x":16062, "val":"S06", "y":167}}, {"22":{"x":15743, "val":"A39", "y":129}}, {"27":{"x":15814, "val":"A39", "y":196}}, {"17":{"x":15890, "val":"A38", "y":275}}, {"36":{"x":15890, "val":"A39", "y":375}}, {"830":{"x":15889, "val":"A37", "y":472}}, {"34":{"x":15824, "val":"A39", "y":538}}, {"784":{"x":15755, "val":"A39", "y":605}}, {"794":{"x":15679, "val":"A39", "y":538}}, {"834":{"x":15611, "val":"A36", "y":471}}, {"798":{"x":15610, "val":"A39", "y":375}}, {"29":{"x":15612, "val":"A38", "y":280}}, {"823":{"x":15680, "val":"A39", "y":202}}, {"841":{"x":15256, "val":"A14", "y": -355}}, {"842":{"x":15186, "val":"S55", "y": -407}}, {"835":{"x":15112, "val":"S56", "y": -466}}, {"839":{"x":15339, "val":"A11", "y": -446}}, {"838":{"x":15262, "val":"S53", "y": -509}}, {"831":{"x":15178, "val":"S54", "y": -568}}, {"864":{"x":16144, "val":"A40", "y": -439}}, {"865":{"x":16192, "val":"A41", "y": -506}}, {"789":{"x":15127, "val":"S74", "y":315}}, {"780":{"x":15147, "val":"S75", "y":230}}, {"817":{"x":15208, "val":"S76", "y":176}}, {"810":{"x":15286, "val":"S77", "y":178}}, {"793":{"x":15269, "val":"S79", "y":258}}, {"803":{"x":15212, "val":"S78", "y":309}}, {"844":{"x":15751, "val":"A39", "y":375}}, {"804":{"x":16144, "val":"A15", "y":125}}, {"859":{"x":16274, "val":"S28", "y": -566}}, {"870":{"x":15416, "val":"S80", "y":258}}, {"837":{"x":15422, "val":"S86", "y":163}}, {"871":{"x":15349, "val":"S87", "y":133}}, {"872":{"x":16241, "val":"S85", "y":203}}, {"873":{"x":16360, "val":"S26", "y": -595}}, {"874":{"x":16402, "val":"S88", "y": -532}}, {"875":{"x":16353, "val":"S89", "y": -462}}, {"876":{"x":16267, "val":"S19", "y": -405}}, {"877":{"x":16183, "val":"S18", "y": -375}}], "edges":[{"1":[321, 371]}, {"2":[356, 360]}, {"3":[365, 382]}, {"4":[556, 560]}, {"5":[589, 598]}, {"6":[414, 426]}, {"7":[110, 112]}, {"8":[300, 352]}, {"9":[791, 845]}, {"10":[250, 259]}, {"11":[103, 636]}, {"12":[16, 839]}, {"13":[660, 661]}, {"14":[577, 578]}, {"15":[142, 171]}, {"16":[819, 833]}, {"17":[324, 661]}, {"18":[200, 205]}, {"19":[212, 251]}, {"20":[128, 470]}, {"21":[286, 647]}, {"22":[309, 407]}, {"23":[325, 363]}, {"24":[251, 256]}, {"25":[835, 846]}, {"26":[364, 414]}, {"27":[832, 846]}, {"28":[797, 833]}, {"29":[25, 814]}, {"30":[168, 187]}, {"31":[172, 173]}, {"32":[366, 419]}, {"33":[21, 35]}, {"34":[146, 193]}, {"35":[43, 118]}, {"36":[75, 459]}, {"37":[516, 614]}, {"38":[783, 805]}, {"39":[95, 97]}, {"40":[34, 784]}, {"41":[401, 402]}, {"42":[360, 425]}, {"43":[481, 558]}, {"44":[186, 279]}, {"45":[837, 870]}, {"46":[782, 820]}, {"47":[155, 263]}, {"48":[380, 390]}, {"49":[284, 288]}, {"50":[185, 241]}, {"51":[342, 430]}, {"52":[662, 663]}, {"53":[329, 437]}, {"54":[139, 244]}, {"55":[492, 532]}, {"56":[406, 412]}, {"57":[105, 120]}, {"58":[358, 388]}, {"59":[285, 460]}, {"60":[41, 77]}, {"61":[364, 369]}, {"62":[342, 376]}, {"63":[799, 808]}, {"64":[319, 423]}, {"65":[481, 609]}, {"66":[795, 857]}, {"67":[499, 613]}, {"68":[497, 604]}, {"69":[561, 602]}, {"70":[74, 75]}, {"71":[311, 365]}, {"72":[567, 612]}, {"73":[446, 649]}, {"74":[517, 518]}, {"75":[509, 533]}, {"76":[46, 47]}, {"77":[561, 562]}, {"78":[592, 620]}, {"79":[22, 823]}, {"80":[231, 672]}, {"81":[198, 229]}, {"82":[393, 419]}, {"83":[490, 554]}, {"84":[513, 537]}, {"85":[500, 573]}, {"86":[88, 630]}, {"87":[295, 403]}, {"88":[78, 654]}, {"89":[786, 857]}, {"90":[378, 431]}, {"91":[118, 123]}, {"92":[333, 437]}, {"93":[357, 436]}, {"94":[30, 48]}, {"95":[306, 322]}, {"96":[315, 331]}, {"97":[636, 637]}, {"98":[413, 425]}, {"99":[164, 169]}, {"100":[471, 519]}, {"101":[11, 14]}, {"102":[54, 55]}, {"103":[188, 191]}, {"104":[487, 529]}, {"105":[195, 196]}, {"106":[318, 429]}, {"107":[588, 612]}, {"108":[20, 28]}, {"109":[197, 198]}, {"110":[177, 178]}, {"111":[100, 448]}, {"112":[330, 331]}, {"113":[71, 96]}, {"114":[350, 353]}, {"115":[536, 538]}, {"116":[404, 439]}, {"117":[222, 256]}, {"118":[507, 510]}, {"119":[584, 585]}, {"120":[644, 645]}, {"121":[549, 604]}, {"122":[191, 192]}, {"123":[122, 123]}, {"124":[132, 197]}, {"125":[517, 563]}, {"126":[35, 825]}, {"127":[501, 521]}, {"128":[619, 620]}, {"129":[223, 224]}, {"130":[241, 242]}, {"131":[157, 216]}, {"132":[218, 272]}, {"133":[29, 823]}, {"134":[243, 245]}, {"135":[271, 272]}, {"136":[534, 576]}, {"137":[546, 549]}, {"138":[331, 344]}, {"139":[232, 238]}, {"140":[802, 821]}, {"141":[618, 619]}, {"142":[775, 785]}, {"143":[590, 594]}, {"144":[66, 461]}, {"145":[224, 236]}, {"146":[17, 27]}, {"147":[92, 442]}, {"148":[34, 830]}, {"149":[876, 877]}, {"150":[625, 629]}, {"151":[570, 572]}, {"152":[517, 528]}, {"153":[548, 555]}, {"154":[305, 348]}, {"155":[603, 608]}, {"156":[800, 826]}, {"157":[582, 583]}, {"158":[605, 606]}, {"159":[827, 873]}, {"160":[780, 817]}, {"161":[495, 574]}, {"162":[189, 193]}, {"163":[145, 230]}, {"164":[640, 648]}, {"165":[66, 70]}, {"166":[580, 582]}, {"167":[498, 600]}, {"168":[297, 410]}, {"169":[105, 643]}, {"170":[144, 185]}, {"171":[784, 794]}, {"172":[146, 210]}, {"173":[126, 632]}, {"174":[61, 89]}, {"175":[339, 367]}, {"176":[504, 520]}, {"177":[859, 873]}, {"178":[231, 232]}, {"179":[314, 339]}, {"180":[239, 263]}, {"181":[146, 199]}, {"182":[138, 214]}, {"183":[402, 429]}, {"184":[81, 108]}, {"185":[472, 514]}, {"186":[518, 552]}, {"187":[775, 833]}, {"188":[523, 524]}, {"189":[471, 520]}, {"190":[47, 620]}, {"191":[814, 816]}, {"192":[86, 393]}, {"193":[141, 181]}, {"194":[173, 178]}, {"195":[76, 634]}, {"196":[384, 385]}, {"197":[393, 403]}, {"198":[180, 249]}, {"199":[561, 566]}, {"200":[456, 631]}, {"201":[547, 599]}, {"202":[173, 266]}, {"203":[551, 566]}, {"204":[305, 431]}, {"205":[290, 646]}, {"206":[241, 641]}, {"207":[137, 177]}, {"208":[179, 269]}, {"209":[650, 657]}, {"210":[127, 642]}, {"211":[76, 114]}, {"212":[563, 564]}, {"213":[175, 181]}, {"214":[572, 586]}, {"215":[139, 242]}, {"216":[798, 844]}, {"217":[488, 536]}, {"218":[621, 622]}, {"219":[545, 589]}, {"220":[6, 13]}, {"221":[136, 266]}, {"222":[5, 8]}, {"223":[96, 98]}, {"224":[781, 826]}, {"225":[370, 415]}, {"226":[83, 104]}, {"227":[293, 418]}, {"228":[22, 27]}, {"229":[21, 819]}, {"230":[571, 574]}, {"231":[150, 225]}, {"232":[151, 265]}, {"233":[155, 262]}, {"234":[843, 848]}, {"235":[500, 607]}, {"236":[543, 544]}, {"237":[64, 113]}, {"238":[467, 658]}, {"239":[69, 658]}, {"240":[149, 222]}, {"241":[507, 508]}, {"242":[116, 118]}, {"243":[463, 625]}, {"244":[345, 346]}, {"245":[215, 221]}, {"246":[375, 376]}, {"247":[841, 842]}, {"248":[660, 674]}, {"249":[303, 439]}, {"250":[257, 258]}, {"251":[386, 391]}, {"252":[252, 257]}, {"253":[81, 659]}, {"254":[26, 46]}, {"255":[175, 202]}, {"256":[87, 633]}, {"257":[641, 642]}, {"258":[330, 383]}, {"259":[577, 667]}, {"260":[374, 375]}, {"261":[48, 49]}, {"262":[57, 59]}, {"263":[129, 539]}, {"264":[478, 502]}, {"265":[359, 362]}, {"266":[548, 560]}, {"267":[503, 599]}, {"268":[194, 201]}, {"269":[190, 191]}, {"270":[532, 533]}, {"271":[349, 429]}, {"272":[35, 828]}, {"273":[248, 250]}, {"274":[95, 98]}, {"275":[15, 37]}, {"276":[135, 279]}, {"277":[271, 277]}, {"278":[403, 409]}, {"279":[87, 88]}, {"280":[117, 466]}, {"281":[67, 658]}, {"282":[127, 379]}, {"283":[132, 167]}, {"284":[623, 624]}, {"285":[785, 792]}, {"286":[806, 812]}, {"287":[464, 632]}, {"288":[490, 509]}, {"289":[292, 400]}, {"290":[301, 425]}, {"291":[276, 277]}, {"292":[323, 398]}, {"293":[485, 522]}, {"294":[483, 531]}, {"295":[58, 82]}, {"296":[85, 86]}, {"297":[344, 391]}, {"298":[790, 825]}, {"299":[479, 515]}, {"300":[634, 636]}, {"301":[793, 803]}, {"302":[318, 323]}, {"303":[3, 4]}, {"304":[13, 40]}, {"305":[62, 90]}, {"306":[182, 213]}, {"307":[778, 822]}, {"308":[519, 563]}, {"309":[6, 14]}, {"310":[104, 465]}, {"311":[542, 618]}, {"312":[23, 38]}, {"313":[77, 541]}, {"314":[572, 588]}, {"315":[187, 188]}, {"316":[486, 505]}, {"317":[385, 440]}, {"318":[515, 516]}, {"319":[75, 114]}, {"320":[337, 422]}, {"321":[455, 626]}, {"322":[109, 654]}, {"323":[156, 218]}, {"324":[112, 445]}, {"325":[41, 129]}, {"326":[100, 125]}, {"327":[364, 415]}, {"328":[800, 802]}, {"329":[332, 336]}, {"330":[323, 370]}, {"331":[592, 605]}, {"332":[32, 799]}, {"333":[578, 581]}, {"334":[143, 187]}, {"335":[165, 166]}, {"336":[76, 101]}, {"337":[71, 656]}, {"338":[151, 268]}, {"339":[296, 398]}, {"340":[308, 319]}, {"341":[511, 569]}, {"342":[107, 111]}, {"343":[827, 874]}, {"344":[222, 223]}, {"345":[288, 624]}, {"346":[575, 579]}, {"347":[131, 195]}, {"348":[8, 15]}, {"349":[69, 70]}, {"350":[534, 586]}, {"351":[24, 569]}, {"352":[491, 578]}, {"353":[566, 567]}, {"354":[345, 411]}, {"355":[160, 161]}, {"356":[790, 845]}, {"357":[488, 543]}, {"358":[176, 257]}, {"359":[133, 196]}, {"360":[329, 330]}, {"361":[290, 451]}, {"362":[777, 797]}, {"363":[477, 584]}, {"364":[342, 418]}, {"365":[591, 611]}, {"366":[152, 182]}, {"367":[16, 841]}, {"368":[627, 628]}, {"369":[480, 517]}, {"370":[787, 845]}, {"371":[56, 130]}, {"372":[334, 434]}, {"373":[106, 468]}, {"374":[159, 183]}, {"375":[396, 407]}, {"376":[53, 340]}, {"377":[562, 616]}, {"378":[779, 787]}, {"379":[246, 247]}, {"380":[219, 221]}, {"381":[371, 426]}, {"382":[97, 628]}, {"383":[346, 381]}, {"384":[55, 581]}, {"385":[630, 655]}, {"386":[142, 168]}, {"387":[85, 227]}, {"388":[277, 278]}, {"389":[835, 842]}, {"390":[354, 427]}, {"391":[448, 640]}, {"392":[204, 261]}, {"393":[43, 44]}, {"394":[99, 102]}, {"395":[776, 777]}, {"396":[395, 417]}, {"397":[827, 856]}, {"398":[240, 243]}, {"399":[786, 792]}, {"400":[115, 124]}, {"401":[519, 553]}, {"402":[805, 827]}, {"403":[306, 379]}, {"404":[550, 595]}, {"405":[821, 870]}, {"406":[5, 6]}, {"407":[350, 435]}, {"408":[10, 26]}, {"409":[477, 583]}, {"410":[541, 542]}, {"411":[838, 839]}, {"412":[537, 543]}, {"413":[400, 424]}, {"414":[281, 453]}, {"415":[795, 796]}, {"416":[161, 229]}, {"417":[36, 844]}, {"418":[78, 452]}, {"419":[317, 413]}, {"420":[16, 19]}, {"421":[493, 556]}, {"422":[498, 593]}, {"423":[811, 864]}, {"424":[108, 450]}, {"425":[302, 433]}, {"426":[481, 550]}, {"427":[7, 33]}, {"428":[781, 812]}, {"429":[146, 202]}, {"430":[476, 527]}, {"431":[258, 265]}, {"432":[209, 210]}, {"433":[505, 569]}, {"434":[83, 664]}, {"435":[820, 843]}, {"436":[831, 846]}, {"437":[28, 35]}, {"438":[612, 613]}, {"439":[320, 408]}, {"440":[142, 184]}, {"441":[840, 846]}, {"442":[528, 529]}, {"443":[202, 280]}, {"444":[89, 130]}, {"445":[433, 438]}, {"446":[9, 39]}, {"447":[467, 623]}, {"448":[489, 539]}, {"449":[816, 836]}, {"450":[226, 228]}, {"451":[171, 172]}, {"452":[512, 513]}, {"453":[248, 254]}, {"454":[671, 672]}, {"455":[665, 666]}, {"456":[152, 206]}, {"457":[44, 57]}, {"458":[557, 558]}, {"459":[335, 336]}, {"460":[72, 465]}, {"461":[119, 446]}, {"462":[780, 789]}, {"463":[70, 621]}, {"464":[353, 397]}, {"465":[53, 430]}, {"466":[356, 439]}, {"467":[312, 374]}, {"468":[822, 829]}, {"469":[469, 639]}, {"470":[400, 401]}, {"471":[283, 635]}, {"472":[297, 324]}, {"473":[513, 514]}, {"474":[498, 615]}, {"475":[392, 432]}, {"476":[549, 550]}, {"477":[126, 128]}, {"478":[123, 643]}, {"479":[810, 817]}, {"480":[589, 669]}, {"481":[587, 598]}, {"482":[160, 169]}, {"483":[114, 674]}, {"484":[162, 163]}, {"485":[203, 259]}, {"486":[317, 331]}, {"487":[515, 545]}, {"488":[234, 235]}, {"489":[511, 539]}, {"490":[289, 651]}, {"491":[102, 107]}, {"492":[141, 174]}, {"493":[378, 381]}, {"494":[505, 506]}, {"495":[346, 347]}, {"496":[184, 189]}, {"497":[68, 662]}, {"498":[109, 632]}, {"499":[486, 587]}, {"500":[165, 169]}, {"501":[848, 856]}, {"502":[179, 213]}, {"503":[18, 22]}, {"504":[494, 565]}, {"505":[332, 410]}, {"506":[801, 811]}, {"507":[340, 367]}, {"508":[553, 554]}, {"509":[793, 810]}, {"510":[51, 194]}, {"511":[131, 163]}, {"512":[264, 266]}, {"513":[590, 607]}, {"514":[479, 510]}, {"515":[304, 316]}, {"516":[59, 668]}, {"517":[31, 840]}, {"518":[18, 35]}, {"519":[60, 73]}, {"520":[540, 610]}, {"521":[322, 353]}, {"522":[476, 597]}, {"523":[804, 833]}, {"524":[253, 257]}, {"525":[218, 219]}, {"526":[51, 260]}, {"527":[807, 818]}, {"528":[111, 451]}, {"529":[167, 170]}, {"530":[551, 560]}, {"531":[200, 207]}, {"532":[60, 103]}, {"533":[538, 539]}, {"534":[254, 255]}, {"535":[49, 124]}, {"536":[652, 653]}, {"537":[395, 405]}, {"538":[339, 368]}, {"539":[94, 461]}, {"540":[343, 368]}, {"541":[576, 608]}, {"542":[268, 269]}, {"543":[527, 535]}, {"544":[372, 409]}, {"545":[358, 361]}, {"546":[288, 289]}, {"547":[282, 283]}, {"548":[811, 818]}, {"549":[399, 433]}, {"550":[524, 525]}, {"551":[341, 406]}, {"552":[134, 253]}, {"553":[91, 93]}, {"554":[143, 192]}, {"555":[132, 166]}, {"556":[570, 574]}, {"557":[216, 245]}, {"558":[363, 408]}, {"559":[91, 281]}, {"560":[788, 829]}, {"561":[532, 568]}, {"562":[387, 420]}, {"563":[794, 834]}, {"564":[308, 371]}, {"565":[207, 228]}, {"566":[334, 339]}, {"567":[62, 110]}, {"568":[573, 606]}, {"569":[640, 653]}, {"570":[284, 287]}, {"571":[382, 383]}, {"572":[789, 826]}, {"573":[33, 50]}, {"574":[450, 644]}, {"575":[804, 872]}, {"576":[294, 394]}, {"577":[496, 586]}, {"578":[292, 347]}, {"579":[208, 209]}, {"580":[514, 552]}, {"581":[142, 170]}, {"582":[385, 386]}, {"583":[96, 655]}, {"584":[544, 558]}, {"585":[361, 425]}, {"586":[291, 345]}, {"587":[365, 373]}, {"588":[649, 650]}, {"589":[2, 3]}, {"590":[287, 647]}, {"591":[521, 522]}, {"592":[80, 462]}, {"593":[51, 190]}, {"594":[559, 568]}, {"595":[611, 615]}, {"596":[320, 354]}, {"597":[394, 395]}, {"598":[298, 406]}, {"599":[801, 828]}, {"600":[354, 369]}, {"601":[487, 614]}, {"602":[445, 635]}, {"603":[211, 212]}, {"604":[73, 125]}, {"605":[97, 449]}, {"606":[389, 420]}, {"607":[61, 62]}, {"608":[72, 88]}, {"609":[307, 392]}, {"610":[50, 51]}, {"611":[628, 629]}, {"612":[234, 270]}, {"613":[45, 606]}, {"614":[552, 557]}, {"615":[377, 378]}, {"616":[213, 217]}, {"617":[811, 877]}, {"618":[798, 834]}, {"619":[29, 798]}, {"620":[396, 412]}, {"621":[379, 416]}, {"622":[282, 458]}, {"623":[502, 503]}, {"624":[630, 631]}, {"625":[335, 351]}, {"626":[362, 363]}, {"627":[482, 618]}, {"628":[237, 270]}, {"629":[267, 274]}, {"630":[627, 656]}, {"631":[176, 177]}, {"632":[290, 627]}, {"633":[779, 788]}, {"634":[72, 82]}, {"635":[12, 30]}, {"636":[337, 428]}, {"637":[326, 437]}, {"638":[204, 205]}, {"639":[526, 597]}, {"640":[78, 87]}, {"641":[68, 464]}, {"642":[357, 399]}, {"643":[325, 438]}, {"644":[361, 421]}, {"645":[503, 504]}, {"646":[555, 565]}, {"647":[638, 639]}, {"648":[591, 612]}, {"649":[387, 388]}, {"650":[65, 67]}, {"651":[609, 610]}, {"652":[100, 109]}, {"653":[23, 31]}, {"654":[120, 447]}, {"655":[42, 59]}, {"656":[214, 276]}, {"657":[144, 238]}, {"658":[140, 249]}, {"659":[355, 432]}, {"660":[864, 865]}, {"661":[499, 603]}, {"662":[310, 357]}, {"663":[624, 625]}, {"664":[859, 865]}, {"665":[7, 8]}, {"666":[564, 565]}, {"667":[115, 117]}, {"668":[579, 580]}, {"669":[875, 876]}, {"670":[287, 444]}, {"671":[522, 589]}, {"672":[161, 162]}, {"673":[11, 12]}, {"674":[74, 124]}, {"675":[501, 502]}, {"676":[61, 457]}, {"677":[275, 276]}, {"678":[286, 447]}, {"679":[226, 237]}, {"680":[670, 673]}, {"681":[17, 36]}, {"682":[809, 824]}, {"683":[489, 541]}, {"684":[831, 838]}, {"685":[16, 20]}, {"686":[531, 533]}, {"687":[630, 648]}, {"688":[183, 209]}, {"689":[236, 239]}, {"690":[1, 2]}, {"691":[172, 174]}, {"692":[60, 68]}, {"693":[336, 663]}, {"694":[63, 170]}, {"695":[506, 510]}, {"696":[602, 611]}, {"697":[571, 600]}, {"698":[164, 264]}, {"699":[321, 436]}, {"700":[83, 84]}, {"701":[219, 220]}, {"702":[380, 386]}, {"703":[64, 65]}, {"704":[273, 278]}, {"705":[36, 830]}, {"706":[299, 429]}, {"707":[147, 226]}, {"708":[643, 659]}, {"709":[235, 274]}, {"710":[92, 93]}, {"711":[810, 871]}, {"712":[341, 405]}, {"713":[573, 608]}, {"714":[54, 582]}, {"715":[473, 562]}, {"716":[138, 212]}, {"717":[832, 836]}, {"718":[215, 273]}, {"719":[796, 815]}, {"720":[148, 207]}, {"721":[808, 837]}, {"722":[179, 180]}, {"723":[338, 397]}, {"724":[626, 646]}, {"725":[91, 121]}, {"726":[508, 536]}, {"727":[80, 659]}, {"728":[157, 220]}, {"729":[4, 6]}, {"730":[311, 359]}, {"731":[484, 580]}, {"732":[249, 252]}, {"733":[156, 217]}, {"734":[304, 328]}, {"735":[475, 546]}, {"736":[153, 274]}, {"737":[328, 666]}, {"738":[778, 791]}, {"739":[262, 270]}, {"740":[320, 423]}, {"741":[39, 40]}, {"742":[348, 349]}, {"743":[207, 208]}, {"744":[474, 551]}, {"745":[227, 230]}, {"746":[388, 407]}, {"747":[151, 259]}, {"748":[571, 585]}, {"749":[203, 206]}, {"750":[580, 581]}, {"751":[310, 435]}, {"752":[99, 441]}, {"753":[454, 651]}, {"754":[222, 280]}, {"755":[101, 441]}, {"756":[442, 657]}, {"757":[19, 38]}, {"758":[525, 526]}, {"759":[199, 201]}, {"760":[789, 803]}, {"761":[352, 389]}, {"762":[590, 595]}, {"763":[52, 53]}, {"764":[84, 633]}, {"765":[377, 416]}, {"766":[381, 671]}, {"767":[483, 525]}, {"768":[159, 204]}, {"769":[601, 620]}, {"770":[497, 605]}, {"771":[290, 645]}, {"772":[806, 809]}, {"773":[530, 596]}, {"774":[783, 813]}, {"775":[530, 535]}, {"776":[102, 106]}, {"777":[449, 622]}, {"778":[42, 443]}, {"779":[337, 419]}, {"780":[117, 118]}, {"781":[596, 616]}, {"782":[71, 469]}, {"783":[233, 267]}, {"784":[403, 417]}, {"785":[42, 130]}, {"786":[79, 124]}, {"787":[57, 458]}, {"788":[316, 351]}, {"789":[56, 668]}, {"790":[153, 240]}, {"791":[480, 547]}, {"792":[94, 95]}, {"793":[131, 186]}, {"794":[808, 824]}, {"795":[307, 364]}, {"796":[37, 52]}, {"797":[373, 404]}, {"798":[782, 811]}, {"799":[154, 215]}, {"800":[546, 601]}, {"801":[145, 231]}, {"802":[64, 460]}, {"803":[140, 275]}, {"804":[53, 372]}, {"805":[10, 11]}, {"806":[574, 575]}, {"807":[253, 254]}, {"808":[548, 557]}, {"809":[181, 211]}, {"810":[343, 390]}, {"811":[133, 255]}, {"812":[492, 530]}, {"813":[79, 80]}, {"814":[284, 285]}, {"815":[119, 122]}, {"816":[474, 594]}, {"817":[260, 261]}, {"818":[366, 411]}, {"819":[576, 577]}, {"820":[84, 128]}, {"821":[422, 424]}, {"822":[113, 121]}, {"823":[638, 640]}, {"824":[389, 391]}, {"825":[338, 355]}, {"826":[90, 92]}, {"827":[158, 179]}, {"828":[312, 387]}, {"829":[106, 652]}, {"830":[58, 96]}, {"831":[313, 390]}, {"832":[16, 25]}, {"833":[32, 35]}, {"834":[135, 247]}, {"835":[327, 437]}, {"836":[333, 384]}, {"837":[520, 523]}, {"838":[559, 562]}, {"839":[468, 637]}, {"840":[239, 273]}, {"841":[323, 421]}, {"842":[224, 225]}, {"843":[807, 813]}, {"844":[874, 875]}, {"845":[57, 116]}, {"846":[482, 540]}, {"847":[510, 512]}, {"848":[596, 617]}, {"849":[158, 271]}, {"850":[593, 617]}, {"851":[246, 266]}, {"852":[664, 665]}, {"853":[427, 439]}, {"854":[776, 815]}, {"855":[229, 673]}]};
			helpfulAdventurer.levelGraph = LevelGraph.loadGraph(helpfulAdventurer.levelGraphObject, helpfulAdventurer);
			
			helpfulAdventurer.name = CHARACTER_NAME;
			helpfulAdventurer.flavorName = "Cid";
			helpfulAdventurer.flavorClass = "The Helpful Adventurer";
			helpfulAdventurer.flavor = "A character who uses her energy to empower rapid click attacks.";
			helpfulAdventurer.characterSelectOrder = 1;
			helpfulAdventurer.availableForCreation = true;
			helpfulAdventurer.visibleOnCharacterSelect = true;
			helpfulAdventurer.defaultSaveName = "helpful_adventurer";
			helpfulAdventurer.startingSkills = [];
			helpfulAdventurer.upgradeableStats = Character.DEFAULT_UPGRADEABLE_STATS;
			helpfulAdventurer.traitsToLevel = ["ExtraMulticlicks", "BigClickStacks", "BigClicksDamage", "HugeClickDamage", "ManaCritDamage", "ImprovedEnergize", "SustainedPowersurge", "ImprovedPowersurge", "ImprovedReload"];
			helpfulAdventurer.assetGroupName = CHARACTER_ASSET_GROUP;
			helpfulAdventurer.gildStartBuild = [1, 2, 3, 4, 6, 35];
			helpfulAdventurer.gcdMinimum = 0.1;
			
			helpfulAdventurer.statPanelTraits = {
			   "BigClicksDamage":{
				  "isPercent":true
				},
			   "HugeClickDamage":{
				  "isPercent":true
				},
			   "ExtraMulticlicks":{
				  "isPercent":false
				},
			   "BigClickStacks":{
				  "isPercent":false
				},
			   "ManaCritDamage":{
				  "isPercent":true
				},
			   "ImprovedEnergize":{
				  "isPercent":true
				},
			   "SustainedPowersurge":{
				  "isPercent":true
				},
			   "ImprovedPowersurge":{
				  "isPercent":true
				}
			}
			
			helpfulAdventurer.traitInfo = {
				"BigClicksDamage": {
					"name": "Bigger Big Clicks",
					"valueFunction": Character.linearN(0.05, 1)
				},
				"HugeClickDamage": {
					"name": "Huger Huge Click",
					"valueFunction": Character.linearN(0.05, 1)
				},
				"ExtraMulticlicks": {
					"name": "Increased MultiClicks",
					"valueFunction": Character.linearN(1)
				},
				"BigClickStacks": {
					"name": "More Big Clicks",
					"valueFunction": Character.linearN(1)
				},
				"ManaCritDamage": {
					"name": "Mana Crit Damage",
					"valueFunction": Character.linearN(0.05, 1)
				},
				"ImprovedEnergize": {
					"name": "Improved Energize",
					"valueFunction": Character.linearN(0.1)
				},
				"SustainedPowersurge": {
					"name": "Sustained Powersurge",
					"valueFunction": Character.linearN(0.05, 1)
				},
				"ImprovedPowersurge": {
					"name": "Improved Powersurge",
					"valueFunction": Character.linearN(0.05, 1)
				}
				/*"ImprovedReload": {
					"name": "",
					"valueFunction": 
				}*/
			};
			
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
			tripleClick.tooltipFunction = function():Object{ return this.skillTooltip("Clicks " + Math.ceil((5 + (CH2.currentCharacter.getTraitValue("ExtraMulticlicks"))) * (CH2.currentCharacter.getTrait("Flurry") ? CH2.currentCharacter.hasteRating.powN(2/3).numberValue() : 1))  + " times.  Dashing consumes 20% of remaining clicks."); };
			
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
				var clicks:int = 6 + character.getTraitValue("BigClickStacks");
				var damage:Number = 3 * (character.getTraitValue("BigClicksDamage")) * 100;
				if (character.getTrait("DistributedBigClicks"))
				{
					damage = (damage - 100) * 0.5 + 100;
					clicks *= 2;
					if (character.getTrait("DistributedBigClicksScaling"))
					{
						clicks = Math.ceil(clicks * character.hasteRating.powN(2/3).numberValue());
					}
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
				var damage:Number = 10.00 * (character.getTraitValue("HugeClickDamage")) * 100;
				return this.skillTooltip("Causes your next click to deal " + damage.toFixed(2) + "% damage."); 
			};			

			var manaClick:Skill = new Skill();
			manaClick.modName = MOD_INFO["name"];
			manaClick.name = "Mana Crit";
			manaClick.description = "";
			manaClick.cooldown = 120000;
			manaClick.iconId = 1;
			manaClick.manaCost = 20;
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
					manaClickDamageBonus = character.getTraitValue("ManaCritDamage") * (1 + character.criticalChance.numberValue());
				}
				else
				{
					manaClickDamageBonus = character.getTraitValue("ManaCritDamage");
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
				var duration:Number = 60 / character.hasteRating.numberValue();
				duration += (60 * character.getTraitValue("ImprovedEnergize")) / character.hasteRating.numberValue();
				return this.skillTooltip("Restores " + (2 * character.hasteRating.numberValue()).toFixed(2) + " energy per second for " + (duration).toFixed(2) + " seconds."); };
			
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
				duration += (15 * character.getTraitValue("ImprovedEnergize"));
				return this.skillTooltip("Restores " + (character.maxMana.numberValue() * 0.25 / 15).toFixed(2) + " mana  at a cost of " + (120/duration).toFixed(2) + " energy every " + (1 / character.hasteRating.numberValue()).toFixed(2) + " seconds over " + (duration * (1 / character.hasteRating.numberValue())).toFixed(2) + " seconds."); 
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
				var reloadAmount:Number = (40 + (10 * character.getTrait("ImprovedReload")));
				var cooldownReduction:Number = 100 * (0.4 + (0.6 * (1 - (1 / (1 + 0.005 * character.getTrait("ImprovedReload"))))));
				
				if (character.getTrait("SmallReloads"))
				{
					reloadAmount *= 0.2;
					cooldownReduction *= 02;
				}
				return this.skillTooltip("Restores " + reloadAmount.toFixed(0) + " energy and mana and reduces the cooldowns of all skills by %d%.".replace("%d",cooldownReduction.toFixed(2))); 
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
				var duration:Number = (60 * character.getTraitValue("SustainedPowersurge")) / character.hasteRating.numberValue();
				var damage:Number = 2 * character.getTraitValue("ImprovedPowersurge") * 100;
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
			
			var handOfLibertas:Skill = new Skill();
			handOfLibertas.modName = MOD_INFO["name"];
			handOfLibertas.name = "Hand of Libertas";
			handOfLibertas.description = "";
			handOfLibertas.cooldown = 60000;
			handOfLibertas.iconId = 50;
			handOfLibertas.manaCost = 0;
			handOfLibertas.energyCost = 0;
			handOfLibertas.consumableOnly = false;
			handOfLibertas.minimumAscensions = 0;
			handOfLibertas.effectFunction = handOfLibertasEffect;
			handOfLibertas.ignoresGCD = false;
			handOfLibertas.maximumRange = 9000;
			handOfLibertas.minimumRange = 0;
			handOfLibertas.usesMaxEnergy = false;
			handOfLibertas.tooltipFunction = function():Object{ return this.skillTooltip("Clicks a floating clickable"); };
			Character.staticSkillInstances[handOfLibertas.uid] = handOfLibertas;
			
			var bigClicksAdditionalTutorialCondition:Function = function():Boolean {
				return !CH2.currentCharacter.buffs.hasBuffByName("Big Clicks");
			};
			
			var hugeClicksAdditionalTutorialCondition:Function = function():Boolean {
				return !CH2.currentCharacter.buffs.hasBuffByName("Huge Click");
			};
			
			var energizeAdditionalTutorialCondition:Function = function():Boolean {
				return !CH2.currentCharacter.buffs.hasBuffByName("Energize") && (CH2.user.totalMsecsPlayed - CH2.currentCharacter.timeOfLastOutOfEnergy) < 15000;
			};
			
			addSkillTutorial("MultiClick", 1, 2);
			addSkillTutorial("Big Clicks", 3, 3, bigClicksAdditionalTutorialCondition);
			//addSkillTutorial("Huge Click", 1, 1, hugeClicksAdditionalTutorialCondition);
			addSkillTutorial("Energize", 2, 6, energizeAdditionalTutorialCondition);
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
			var uid:int = 0;
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
					item.init(catalogIndex % Item.ITEM_EQUIP_AMOUNT, worldCostCurve, worldCostMultiplier, catalogIndex + 1, uid, fixedAttributes);
					hardcodedCatalog.push(item);
					uid++;
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
			return character.highestWorldCompleted < 1 && character.level < 3 && character.level > 1;
		}
		
		public function doesPlayerRequireItemTabTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return character.highestWorldCompleted < 1 && character.totalCatalogItemsPurchased < 3;
		}
		
		public function doesPlayerRequireItemUpgradeTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return character.highestWorldCompleted < 1 && character.totalCatalogItemsPurchased < 2 && (character.level < 2 || (character.level == 2 && character.experience.lteN(250)));
		}
		
		public function doesPlayerRequireCatalogTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return character.highestWorldCompleted < 1 && character.totalCatalogItemsPurchased < 3;
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
			return character.level < 3 &&
				character.highestWorldCompleted < 1 && 
				character.level > 1 &&
				character.hasNewSkillTreePointsAvailable &&
				CH2.user.totalMsecsPlayed - character.timeOfLastLevelUp > Character.TIME_UNTIL_PLAYER_NEEDS_HINT_MS;
		}
		
		public function shouldStartItemUpgradeTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return character.totalCatalogItemsPurchased < 2 &&
				character.highestWorldCompleted < 1 && (character.level < 2 || (character.level == 2 && character.experience.lteN(250))) &&
				CH2.user.totalMsecsPlayed - character.timeOfLastItemUpgrade > Character.TIME_UNTIL_PLAYER_NEEDS_HINT_MS &&
				CH2.user.totalMsecsPlayed - character.timeOfLastCatalogPurchase > Character.TIME_UNTIL_PLAYER_NEEDS_HINT_MS &&
				character.canAffordAPurchaseOnAllItems();
		}
		
		public function shouldStartCatalogTutorial():Boolean
		{
			var character:Character = CH2.currentCharacter;
			return !character.didFinishWorld &&
				character.highestWorldCompleted < 1 && 
				character.totalCatalogItemsPurchased < 3 &&
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
					character.level >= 3 ||
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
		
		protected function unlockAutomator():void
		{
			CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_16", 10000);
			CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_11", 4000);
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_23", "Perform a click", 1, "Performs a single click.", onClickActivate, canClickActivate, 0);
		}
		
		protected function purchaseAutomator():void
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
		
		private function canClickActivate():Boolean
		{
			return CH2.currentCharacter.energy > 0;
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
		
		private function addPauseGem():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_66", "Pause Gem", 96, "Pauses the game", onPauseGemActivate, canActivatePauseGem);
		}
		
		private function addUnpauseGem():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_67", "Unpause Gem", 96, "Unpauses the game", onUnpauseGemActivate, canActivateUnpauseGem);		
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
				var percentEnergy:Number = CH2.currentCharacter.energy / CH2.currentCharacter.maxEnergy.numberValue();
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
				var percentEnergy:Number = CH2.currentCharacter.energy / CH2.currentCharacter.maxEnergy.numberValue();
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
				var percentMana:Number = CH2.currentCharacter.mana / CH2.currentCharacter.maxMana.numberValue();
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
				var percentMana:Number = CH2.currentCharacter.mana / CH2.currentCharacter.maxMana.numberValue();
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
				return CH2.currentCharacter.criticalChance.numberValue() >= 1;
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
				return (CH2.currentCharacter.energy / CH2.currentCharacter.maxEnergy.numberValue()) < .4;
			})
		}
		
		private function addEnergyGreaterThan60PercentStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_25", "Energy Greater Than 60%", "Energy > 60%", "A stone that can activate when your energy is above 60%.", function():Boolean
			{
				return (CH2.currentCharacter.energy / CH2.currentCharacter.maxEnergy.numberValue()) > .6;
			})
		}
		
		private function addManaLessThan40PercentStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_26", "Mana Less Than 40%", "Mana < 40%", "A stone that can activate when your mana is below 40%.", function():Boolean
			{
				return (CH2.currentCharacter.mana / CH2.currentCharacter.maxMana.numberValue()) < .4;
			})
		}
		
		private function addManaGreaterThan60PercentStone():void
		{
			CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_27", "Mana Greater Than 60%", "Mana > 60%", "A stone that can activate when your mana is above 60%.", function():Boolean
			{
				return (CH2.currentCharacter.mana / CH2.currentCharacter.maxMana.numberValue()) > .6;
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
            CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_29", "First World of System", "First world of System", "A stone that can activate when you are on the first world of a Star System.", function ():Boolean
            {
                return (CH2.currentCharacter.currentWorldId % CH2.currentCharacter.worldsPerSystem == 1); 
            })
        }
        
        private function addNotFirstWorldOfGildStone():void
        {
            CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_30", "Not First World of System", "Not first world of System", "A stone that can activate when you are not on the first world of a Star System.", function ():Boolean
            {
                return (CH2.currentCharacter.currentWorldId % CH2.currentCharacter.worldsPerSystem != 1);   
            })
        }            
		
		private function addFirstZoneOfWorldStone():void
        {
            CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_35", "Zone = 1", "Zone = 1", "A stone that can activate when it's the first zone of the world.", function ():Boolean
            {
                return (CH2.currentCharacter.currentZone <= 1);   
            })
        }            
		
		private function addNotFirstZoneOfWorldStone():void
        {
            CH2.currentCharacter.automator.addStone(CHARACTER_NAME+"_34", "Zone > 1", "Zone > 1", "A stone that can activate when it's not the first zone of the world.", function ():Boolean
            {
                return (CH2.currentCharacter.currentZone > 1);   
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
		
		protected function addBuffComparisonStone(stoneId:String, stoneName:String, stoneDescription:String, buffName:String, comparison:int, comparisonValue:int):void
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
			CH2.currentCharacter.setTrait("UnlimitedBigClicks", 1, false, false);
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
			var currentSystem:StarSystem = CH2.currentCharacter.getStarSystem(CH2.currentAscensionWorld.starSystemId);
			if (currentSystem.traits[WT_SPEED_LIMIT])
			{
				CH2.currentCharacter.addGold(CH2.currentCharacter.gold.multiplyN( -0.2));
			}
			CH2.currentCharacter.onTeleportAttackDefault();
		}
		
		public function autoAttackOverride():void
		{
			var character:Character = CH2.currentCharacter;
			if (character.getTrait("Synchrony") && character.buffs.hasBuffByName("Autoattackstorm"))
			{
				character.addEnergy(2, false);
			}
			character.autoAttackDefault();
			
		}
		
		protected function applySpecialTraitsBeforeAttack(attackData:AttackData):AttackData 
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.getTrait("LowEnergyDamageBonus") && character.energy < character.maxEnergy.numberValue() * 0.60)
			{
				attackData.damage.timesEqualsN(2);
			}
			
			return attackData;
		}
		
		protected function applySpecialTraitsAfterAttack(attackData:AttackData):AttackData 
		{
			var character:Character = CH2.currentCharacter;
			
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
			
			return attackData;
		}
		
		//public function helpfulAdventurerAttack(attackData:AttackData):void
		public function attackOverride(attackData:AttackData):void
		{
			var character:Character = CH2.currentCharacter;
			var currentSystem:StarSystem = CH2.currentCharacter.getStarSystem(CH2.currentAscensionWorld.starSystemId);
			
			if (currentSystem.traits[WT_ROBUST])
			{
				attackData.critChanceModifier = -100;
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
			
			attackData = applySpecialTraitsBeforeAttack(attackData);
			character.attackDefault(attackData);
			attackData = applySpecialTraitsAfterAttack(attackData);
			
			if (!attackData.isAutoAttack && currentSystem.traits[WT_EXHAUSTING])
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
			
			if (attackData.isAutoAttack && attackData.isCritical && character.getTrait("AutoAttackCritMana"))
			{
				character.addMana(1);
				character.addEnergy(2);
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
			var currentSystem:StarSystem = CH2.currentCharacter.getStarSystem(CH2.currentAscensionWorld.starSystemId);
			if (currentSystem.traits[WT_INCOME_TAX] && goldToAdd.isPositive)
			{
				goldToAdd.timesEquals(1 / CH2.currentCharacter.monsterGoldMultiplier);
			}
			if (CH2.currentCharacter.getTrait("HighEnergyGoldBonus") && (goldToAdd.gtN(0)) && CH2.currentCharacter.energy > 0.40 * CH2.currentCharacter.maxEnergy.numberValue())
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
				if (!CH2.currentCharacter.achievements.isAchievementComplete(27) && amount < -100)
				{
					CH2.user.awardAchievement(27);
				}
				
				if (character.getTrait("Discharge"))
				{
					var target:Monster = CH2.world.getNextMonster();
					if (target && (Math.abs(target.y - character.y) < 400))
					{
						var attackData:AttackData = new AttackData();
						attackData.damage = character.autoAttackDamage.multiplyN((Math.pow(Math.abs(amount * 4), 1.05)) * (character.getTrait("EtherealDischarge") + 1));
						attackData.isCritical = character.roller.attackRoller.boolean(character.criticalChance);
						if (attackData.isCritical)
						{
							attackData.damage.timesEquals(character.criticalDamageMultiplier);
						}
						attackData.monster = target;
						attackData = applySpecialTraitsBeforeAttack(attackData);
						attackData = applySpecialTraitsAfterAttack(attackData);
						target.takeDamage(attackData);
						attackData.isClickAttack = false;
						character.buffs.onAttack(attackData);
					}
				}
			}
			
			var currentSystem:StarSystem = CH2.currentCharacter.getStarSystem(CH2.currentAscensionWorld.starSystemId);
			if (currentSystem.traits[WT_UNSTABLE] && ((character.energy + amount) >= character.maxEnergy.numberValue()))
			{
				amount = -character.energy;
			}
			character.addEnergyDefault(amount, showFloatingText);
		}
		
		public function regenerateManaAndEnergyOverride(time:Number):void
		{
			var character:Character = CH2.currentCharacter;
			var currentSystem:StarSystem = CH2.currentCharacter.getStarSystem(CH2.currentAscensionWorld.starSystemId);
			
			var timeInSeconds:Number = (time / 1000);
			var manaToAdd:Number = timeInSeconds * character.getManaRegenRate();
			if (currentSystem.traits[WT_BANAL])
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
						existingBuff.buffStat(CH2.STAT_HASTE, Math.min(2, 1 + ( -amount / 100) + remainingValue));
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
						buff.buffStat(CH2.STAT_HASTE, Math.min(2, 1 + ( -amount / 100)));
						character.buffs.addBuff(buff);
					}
					
				}
			}
			
			character.addManaDefault(amount, showFloatingText);
		}
		
		public function transcendOverride():void
		{
			var character:Character = CH2.currentCharacter;
			character.transcendDefault();
			if (character.getTrait("AutomaticAutomation"))
			{
				var levelGraph:LevelGraph = character.levelGraph;
				for (var i:int = 0; i < levelGraph.nodes.length; i++)
				{
					if (levelGraph.nodes[i])
					{
						var nodeInfo:Object = character.getNodeInfo(levelGraph.nodes[i].type);
						if (nodeInfo.hasOwnProperty("costsAutomatorPoint") && nodeInfo["costsAutomatorPoint"])
						{
							character.automatorPoints++;
							levelGraph.purchaseNode(levelGraph.nodes[i].id);
						}
					}
				}
			}
			if (character.getTrait("HandOfLibertas"))
			{
				addSkill("Hand of Libertas")();
				CH2.currentCharacter.automator.unlockGem("HandOfLibertas");
			}
		}
		
		public function ascendOverride():void
		{
			var character:Character = CH2.currentCharacter;
			character.ascendDefault();
			
			if (character.getTrait("HandOfLibertas"))
			{
				addSkill("Hand of Libertas")();
				CH2.currentCharacter.automator.unlockGem("HandOfLibertas");
			}			
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
			var buffClicks:int = 4 + (character.getTraitValue("ExtraMulticlicks"));
			if (character.getTrait("Flurry"))
			{
				buffClicks = Math.ceil((buffClicks + 1) * character.hasteRating.powN(2/3).numberValue() - 1);
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
					"body": "Clicking " + Math.ceil((5 + (CH2.currentCharacter.getTraitValue("ExtraMulticlicks"))) * (CH2.currentCharacter.getTrait("Flurry") ? CH2.currentCharacter.hasteRating.powN(2/3).numberValue() : 1))  + " times, with " + Math.ceil(buff.timeLeft/buff.tickRate) + " remaining. Dashing consumes 20% of remaining clicks."
				};
			}
			character.buffs.addBuff(buff);
			character.clickAttack(false);
		}
			
		public function clicktorrentEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.name = "Clicktorrent";
			buff.iconId = 202;
			buff.isUntimedBuff = true;
			buff.tickRate = 1000 / 30;
			buff.tickFunction = function() {
				character.clickAttack(false);
				if (character.getTrait("Downpour"))
				{
					if (character.roller.attackRoller.randFloat() < 0.05)
					{
						hugeClickEffect();
					}
					if (character.roller.attackRoller.randFloat() < 0.05)
					{
						bigClicksEffect();
					}
				}
				var costReduction:Number = Math.pow(0.5, character.getTrait("EtherealStorms"));
				character.addEnergy(-(1/3) * costReduction, false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
			}
			buff.tooltipFunction = function() {
				var costReduction:Number = Math.pow(0.5, character.getTrait("EtherealStorms"));
				
				return {
					"header": "Clicktorrent",
					"body": "Clicking " + (30 * character.hasteRating.numberValue()).toFixed(2) + " times per second. Consuming " + (10 * costReduction * character.hasteRating.numberValue()).toFixed(2) + " energy per second."
				};
			}
			character.buffs.addBuff(buff);
		}
		
		public function clickstormEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.name = "Clickstorm";
			buff.iconId = 200;
			buff.isUntimedBuff = true;
			buff.tickRate = 200;
			buff.tickFunction = function() {
				character.clickAttack(false);
				var costReduction:Number = Math.pow(0.5, character.getTrait("EtherealStorms"));
				character.addEnergy(-0.5 * costReduction, false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Clickstorm",
					"body": "Clicking " + (5 * character.hasteRating.numberValue()).toFixed(2) + " times per second. Consuming " + (2.5 * character.hasteRating.numberValue()).toFixed(2) + " energy per second."
				};
			}
			character.buffs.addBuff(buff);
		}
		
		public function critstormEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.name = "Critstorm";
			buff.iconId = 200;
			buff.isUntimedBuff = true;
			buff.tickRate = 200;
			buff.tickFunction = function() {
				buff.buffStat(CH2.STAT_CRIT_CHANCE, CH2.currentCharacter.criticalChance.numberValue());
				character.clickAttack(false);
				buff.buffStat(CH2.STAT_CRIT_CHANCE, 0);
				var costReduction:Number = Math.pow(0.5, character.getTrait("EtherealStorms"));
				character.addEnergy(-0.5 * costReduction, false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Critstorm",
					"body": "Clicking " + (5 * character.hasteRating.numberValue()).toFixed(2) + " times per second with double crit chance. Consuming " + (2.5 * character.hasteRating.numberValue()).toFixed(2) + " energy per second."
				};
			}
			character.buffs.addBuff(buff);
		}
		
		public function metalDetectorEffect():void
		{
			var character:Character = CH2.currentCharacter;
			for (var i:int = 0; i < CH2.rooms.activeRooms.length; i++)
			{
				if (CH2.rooms.activeRooms[i].leftClickableId > 0)
				{
					if (CH2.rooms.activeRooms[i].leftClickable.validationUid == param)
					{
						CH2.rooms.activeRooms[i].leftClickable.onHitBoxClick();
					}
				}
			}
		}
		
		public function goldenClicksEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.name = "GoldenClicks";
			buff.iconId = 201;
			buff.isUntimedBuff = true;
			if (character.getTrait("GloriousBounty"))
			{
				buff.tickRate = 2000;
				buff.startFunction = function() {
					character.treasureChestsAreMonsters = true;
					character.treasureChestsHaveClickableGold = true;
				};
				
				buff.finishFunction = function() {
					character.treasureChestsAreMonsters = false;
					character.treasureChestsHaveClickableGold = false;
				};
			}
			else
			{
				buff.tickRate = 400;
			}
			buff.tickFunction = function() {
				character.clickAttack(false);
				var costReduction:Number = Math.pow(0.5, character.getTrait("EtherealStorms"));
				character.addEnergy(-0.5 * costReduction, false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
			}
			buff.buffStat(CH2.STAT_GOLD, 2.0);
			buff.tooltipFunction = function() {
				return {
					"header": "Golden Clicks",
					"body": "Clicking " + (2.5 * character.hasteRating.numberValue()).toFixed(2) + " times per second. Gold gained increased by 100%. Consuming " + (1.25 * character.hasteRating.numberValue()).toFixed(2) + " energy per second."
				};
			}
			
			character.buffs.addBuff(buff);
		}
		
		public function handOfLibertasEffect():void
		{
			if (CH2.world.floatingClickables[0])
			{
				CH2.world.floatingClickables[0].pop();
			}
		}
		
		public function autoAttackstormEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.name = "Autoattackstorm";
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
					character.addEnergy(1);
					if (character.mana <= 0) {
						buff.isFinished = true;
						buff.onFinish();
					}
				}
			}
			buff.buffStat(CH2.STAT_AUTOATTACK_DAMAGE, 2);
			buff.tooltipFunction = function() {
				return {
					"header": "Autoattackstorm",
					"body": "Autoattacking " + (5 * character.hasteRating.numberValue()).toFixed(2) + " times per second. These attacks generate 1 extra energy. Autoattack damage doubled. Consuming " + (2.5 * character.hasteRating.numberValue()).toFixed(2) + " mana per second."
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
			buff.duration += 60000 * character.getTraitValue("ImprovedEnergize");
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
					"body": "Restoring 2 energy every " + (1 / character.hasteRating.numberValue()).toFixed(2) + " second."
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
			buff.duration += 15000 * character.getTraitValue("ImprovedEnergize");
			buff.tickRate = 1000;
			buff.tickFunction = function () {
				if (character.energy >= 120*(1000/buff.duration))
				{
					character.addEnergy(-120*(1000/buff.duration));
					character.addMana(character.maxMana.numberValue() * 0.25 / 15);
				}
			}
			buff.finishFunction = function() {
				removeEnergizeIndicator();
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Managize",
					"body": "Restoring " + (character.maxMana.numberValue() * 0.25 / 15).toFixed(2) + " mana every " + (1 / character.hasteRating.numberValue()).toFixed(2) + " second."
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
			var reloadBonus:Number = 40 + (10 * character.getTrait("ImprovedReload"));
			if (character.getTrait("SmallReloads"))
			{
				reloadBonus *= 0.2;
			}
			var energyRestored:Number = reloadBonus;
			var manaRestored:Number = reloadBonus;

			character.addEnergy(energyRestored);
			character.addMana(manaRestored);
			
			for (var id:String in character.skills)
			{
				if (character.skills[id].isActive && id != "Reload")
				{
					var cooldownReduction:Number = character.skills[id].cooldown * (0.4 + (0.6 * (1 - (1 / (1 + 0.005 * character.getTrait("ImprovedReload"))))));
					if (character.getTrait("SmallReloads"))
					{
						cooldownReduction *= 0.2;
					}
					character.skills[id].cooldownRemaining -= cooldownReduction;
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
				var goldToAdd:BigNumber = character.zoneStartGold.multiplyN(2).subtract(character.gold);
				character.addGold(goldToAdd);
				trace(character.getTrait("ImprovedReload"));
			}
		}
		
		public function bigClicksEffect():void
		{
			var character:Character = CH2.currentCharacter;
			
			var stacksPerUse = 6 + character.getTraitValue("BigClickStacks");
			if (character.getTrait("DistributedBigClicks"))
			{
				stacksPerUse *= 2;
				if (character.getTrait("DistributedBigClicksScaling"))
				{
					stacksPerUse = Math.ceil(stacksPerUse * character.hasteRating.powN(2/3).numberValue());
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
								var effect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(CH2.currentCharacter.getCurrentSkin().skinAssetId+BIG_CLICK);
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
				
				
				var damageBuff:Number = 3 * (character.getTraitValue("BigClicksDamage"));
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
					
					if (character.getTrait("KineticEnergy"))
					{
						juggernautBuff.buffStat(CH2.STAT_AUTOATTACK_DAMAGE, character.getClassStat(CH2.STAT_AUTOATTACK_DAMAGE).pow(3));
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
			var damage:Number = 2 * character.getTraitValue("ImprovedPowersurge");
			var buff:Buff = new Buff();
			buff.name = "Powersurge";
			buff.iconId = 150;
			buff.isUntimedBuff = false;
			buff.duration =  60000 * character.getTraitValue("SustainedPowersurge");
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
				buff.tickRate = buff.duration / 20;
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
			var damage:Number = 10.00 * (character.getTraitValue("HugeClickDamage"));
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
							var effect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(CH2.currentCharacter.getCurrentSkin().skinAssetId+HUGE_CLICK);
							effect.gotoAndPlay(1);
							effect.isLooping = false;
							CH2.world.addEffect(effect, CH2.world.roomsFront, attackData.monster.x, attackData.monster.y);
							Shaker.add(CH2.world.roomsBack, -100, 100, 0.5, 0);
							CH2.world.camera.shake(0.5, -100, 100);
						}
						else
						{
							//This is a Big Click and a Huge Click play the special animation
							var effect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(CH2.currentCharacter.getCurrentSkin().skinAssetId+BIG_GIANT_CLICK);
							effect.gotoAndPlay(1);
							effect.isLooping = false;
							CH2.world.addEffect(effect, CH2.world.roomsFront, attackData.monster.x, attackData.monster.y);
							Shaker.add(CH2.world.roomsBack, -200, 200, 0.5, 0);
							CH2.world.camera.shake(0.5, -200, 200);
						}
						
						if (!attackData.monster.isFinalBoss)
						{
							var crackEffect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(CH2.currentCharacter.getCurrentSkin().skinAssetId+HUGE_CLICK_CRACK);
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
							//discountBuff.buffStat(CH2.STAT_ITEM_COST_REDUCTION, 1 / (1 + (0.005 * (10.00 * (character.getTraitValue("HugeClickDamage"))))));
							discountBuff.buffStat(CH2.STAT_ITEM_COST_REDUCTION, 0.5);
							discountBuff.tooltipFunction = function() {
								return {
									"header": "Huge Click Discount",
									"body": "Item costs halved."
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
			
			var isAchievementCandidate:Boolean = false;
			if (!character.achievements.isAchievementComplete(31))
			{
				if (character.buffs.hasBuffByName("Huge Click") && 
					character.buffs.hasBuffByName("Big Clicks") &&
					character.buffs.hasBuffByName("Powersurge") &&
					CH2.world.getNextMonster() != null &&
					CH2.world.getNextMonster().isBoss)
				{
					isAchievementCandidate = true;
				}
			}
			
			var buff:Buff = new Buff();
			buff.name = "Mana Crit";
			buff.duration = 1;
			buff.tickRate = 1;
			
			if (character.getTrait("ImprovedManaCrit"))
			{
				buff.buffStat(CH2.STAT_CLICK_DAMAGE, character.getTraitValue("ManaCritDamage") * (1 + character.criticalChance.numberValue()));
				var restoreMana:Boolean = CH2.roller.attackRoller.boolean(character.criticalChance.numberValue());
				if (restoreMana) 
				{
					character.addMana(character.getSkill("Mana Crit").manaCost);
				}
			}
			else
			{
				buff.buffStat(CH2.STAT_CLICK_DAMAGE, character.getTraitValue("ManaCritDamage"));
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
			
			if (isAchievementCandidate)
			{
				if (CH2.world.bossEncounter != null && CH2.world.bossEncounter.boss.isDead)
				{
					CH2.user.awardAchievement(31);
				}
			}
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
				var indicatorAsset:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(CH2.currentCharacter.getCurrentSkin().skinAssetId+BUFF_INDICATOR);
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
				var indicatorAsset:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(CH2.currentCharacter.getCurrentSkin().skinAssetId+BUFF_INDICATOR);
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
				var animation:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(CH2.currentCharacter.getCurrentSkin().skinAssetId+ENERGY_CHARGE);
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
			return CH2AssetManager.instance.getGpuMovieClip(CH2.currentCharacter.getCurrentSkin().skinAssetId+"_bamplode"+num);
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
				characterInstance.skins = new Array();
					var skin1:Skin = new Skin();
					skin1.skinName = "Helpful Adventurer";
					skin1.skinDescription = "Cid";
					skin1.skinAssetId = "HelpfulAdventurer";
					characterInstance.skins.push(skin1);
					var skin2:Skin = new Skin();
					skin2.skinName = "Helpful Adventurer 2";
					skin2.skinDescription = "Cid 2";
					skin2.skinAssetId = "HelpfulAdventurer2";
					characterInstance.skins.push(skin2);
				
				characterInstance.onCharacterDisplayCreatedHandler = this;
				characterInstance.attackHandler = this;
				characterInstance.autoAttackHandler = this;
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
				characterInstance.getSystemTraitCountHandler = this;
				characterInstance.applySystemTraitsHandler = this;
				characterInstance.onTeleportAttackHandler = this;
				characterInstance.populateEtherealItemStatsHandler = this;
				characterInstance.regenerateManaAndEnergyHandler = this;
				characterInstance.transcendHandler = this;
				characterInstance.ascendHandler = this;
				
				characterInstance.populateEtherealItemStats();
				
				characterInstance.excludedItemStats = [];
				characterInstance.excludedItemStats.push(CH2.STAT_TREASURE_CHEST_CHANCE.toString());
				
				createFixedFirstRunCatalogs(FIXED_FIRST_RUN_CATALOG_DATA);
			}
		}
		
		public function onUICreated():void
		{
			if (CH2.currentCharacter.name == CHARACTER_NAME)
			{
				HUD.UI_POSITIONS["FullScreen"]["UI_Components"]["_buffBar.display"]["y"] = 620;
				HUD.UI_POSITIONS["HalfScreen"]["UI_Components"]["_buffBar.display"]["y"] = 620;
				HUD.UI_POSITIONS["RightScreen"]["UI_Components"]["_buffBar.display"]["y"] = 620;
				
				GraphPanel.HAS_AUTOMATOR_PANEL = true;
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
		
		public function populateEtherealItemStatsOverride(characterInstance:Character):Array
		{
            etherealItemStatStats[CH2.STAT_GOLD] = {
				"weight": 1,
                "sourcePower": 3.0612249,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Mammon's",
				"nameSuffix": "of Greed"
            };
            etherealItemStatStats[CH2.STAT_MOVEMENT_SPEED] = {
				"weight": 0,
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "",
				"nameSuffix": "of Swiftness"
            };
            etherealItemStatStats[CH2.STAT_CRIT_CHANCE] = {
				"weight": 0,
                "sourcePower": 7.894736842,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Risen Bhaal's",
				"nameSuffix": "of Rising"
            };
            etherealItemStatStats[CH2.STAT_CRIT_DAMAGE] = {
				"weight": 1,
                "sourcePower": 2.727272727,
                "sourceWeight": 1,
				"destinationPower": 0.5227586989,
                "destinationWeight": 1,
				"namePrefix": "Precise Bhaal's",
				"nameSuffix": "of Precision"
            };
            etherealItemStatStats[CH2.STAT_HASTE] = {
				"weight": 0,
                "sourcePower": 2.586206897,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Vaagur's",
				"nameSuffix": "of Impatience"
            };
            etherealItemStatStats[CH2.STAT_MANA_REGEN] = {
				"weight": 1,
                "sourcePower": 7.142857143,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Graceful Energon's",
				"nameSuffix": "of Grace"
            };
            etherealItemStatStats[CH2.STAT_IDLE_GOLD] = {
				"weight": 0,
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
            etherealItemStatStats[CH2.STAT_IDLE_DAMAGE] = {
				"weight": 0,
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
            etherealItemStatStats[CH2.STAT_CLICKABLE_GOLD] = {
				"weight": 1,
                "sourcePower": 6.52173913,
                "sourceWeight": 1,
				"destinationPower": 0.2350638265,
                "destinationWeight": 1,
				"namePrefix": "Revolc's",
				"nameSuffix": "of Blessings"
            };
            etherealItemStatStats[CH2.STAT_CLICK_DAMAGE] = {
				"weight": 1,
                "sourcePower": 4.166666667,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Fragsworth's",
				"nameSuffix": "of Wrath"
            };
			etherealItemStatStats[CH2.STAT_AUTOATTACK_DAMAGE] = {
				"weight": 1,
                "sourcePower": 4.166666667,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Siyalatas'",
				"nameSuffix": "of Abandon"
            };
            etherealItemStatStats[CH2.STAT_TREASURE_CHEST_CHANCE] = {
				"weight": 0,
                "sourcePower": 13.63636364,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Favorable Mimzee's",
				"nameSuffix": "of Coffers"
            };
            etherealItemStatStats[CH2.STAT_MONSTER_GOLD] = {
				"weight": 1,
                "sourcePower": 10,
                "sourceWeight": 1,
				"destinationPower": 0.8410066661,
                "destinationWeight": 1,
				"namePrefix": "Kind Mimzee's",
				"nameSuffix": "of Kindness"
            };
            etherealItemStatStats[CH2.STAT_ITEM_COST_REDUCTION] = {
				"weight": 0,
                "sourcePower": 5.555555556,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Dogcog's",
				"nameSuffix": "of Thrift"
            };
            etherealItemStatStats[CH2.STAT_TOTAL_MANA] = {
				"weight": 1,
                "sourcePower": 6.25,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Ionic Energon's",
				"nameSuffix": "of Ions"
            };
            etherealItemStatStats[CH2.STAT_TOTAL_ENERGY] = {
				"weight": 1,
                "sourcePower": 6.52173913,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Juggernaut's",
				"nameSuffix": "of Pittance"
            };
            etherealItemStatStats[CH2.STAT_CLICKABLE_CHANCE] = {
				"weight": 0,
                "sourcePower": 5.172413793,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Iris'",
				"nameSuffix": "of Vision"
            };
            etherealItemStatStats[CH2.STAT_BONUS_GOLD_CHANCE] = {
				"weight": 0,
                "sourcePower": 10,
                "sourceWeight": 1,
				"destinationPower": 1,
                "destinationWeight": 1,
				"namePrefix": "Fortuna's",
				"nameSuffix": "of Luck"
            };
            etherealItemStatStats[CH2.STAT_TREASURE_CHEST_GOLD] = {
				"weight": 1,
                "sourcePower": 8.823529412,
                "sourceWeight": 1,
				"destinationPower": 0.4271249572,
                "destinationWeight": 1,
				"namePrefix": "Blessed Mimzee's",
				"nameSuffix": "of Treasures"
            };
            etherealItemStatStats[CH2.STAT_PIERCE_CHANCE] = {
				"weight": 0,
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
            etherealItemStatStats[CH2.STAT_ENERGY_REGEN] = {
				"weight": 0,
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
            etherealItemStatStats[CH2.STAT_DAMAGE] = {
				"weight": 0,
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
            etherealItemStatStats[CH2.STAT_ENERGY_COST_REDUCTION] = {
				"weight": 0,
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
            etherealItemStatStats[CH2.STAT_ITEM_WEAPON_DAMAGE] = {
				"weight": 0.125,
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Fighter's",
				"nameSuffix": "of Arms"
            };
            etherealItemStatStats[CH2.STAT_ITEM_HEAD_DAMAGE] = {
				"weight": 0.125,
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Milliner's",
				"nameSuffix": "of Skulls"
            };
            etherealItemStatStats[CH2.STAT_ITEM_CHEST_DAMAGE] = {
				"weight": 0.125,
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Knight's",
				"nameSuffix": "of Armor"
            };
            etherealItemStatStats[CH2.STAT_ITEM_RING_DAMAGE] = {
				"weight": 0.125,
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Prince's",
				"nameSuffix": "of Jewels"
            };
            etherealItemStatStats[CH2.STAT_ITEM_LEGS_DAMAGE] = {
				"weight": 0.125,
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Runner's",
				"nameSuffix": "of Limbs"
            };
            etherealItemStatStats[CH2.STAT_ITEM_HANDS_DAMAGE] = {
				"weight": 0.125,
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Boxer's",
				"nameSuffix": "of Fists"
            };
            etherealItemStatStats[CH2.STAT_ITEM_FEET_DAMAGE] = {
				"weight": 0.125,
                "sourcePower": 21.42857143,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Kicker's",
				"nameSuffix": "of Toes"
            };
            etherealItemStatStats[CH2.STAT_ITEM_BACK_DAMAGE] = {
				"weight": 0.125,
                "sourcePower": 18.75,
                "sourceWeight": 0.125,
				"destinationPower": 0.2350638265,
                "destinationWeight": 0.125,
				"namePrefix": "Lurker's",
				"nameSuffix": "of Mantles"
            };
            etherealItemStatStats[CH2.STAT_AUTOMATOR_SPEED] = {
				"weight": 0,
                "sourcePower": 0,
                "sourceWeight": 0,
				"destinationPower": 0,
                "destinationWeight": 0,
				"namePrefix": "",
				"nameSuffix": ""
            };
			
			
			/*etherealItemTraitStats["ExtraMulticlicks"] = {
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
			};*/
			
			return etherealItemStatStats;
			
			var etherealItemStats:Object = { };
			for each (var stat:Object in CH2.STATS)
			{
				var sourceStatStats:Object = etherealItemStatStats[stat["id"]];
				
				/* Broken WIP
				if (sourceStatStats["destinationWeight"] > 0)
				{
					//Note: sourceStatStats is actually for the destination stat here, as there is no source stat for this type of item.
					var etherealItemStatChoice:EtherealItemStatChoice = new EtherealItemStatChoice();
					etherealItemStatChoice.id = stat["etherealTraitKey"] + "ForSkillPoints";
					etherealItemStatChoice.key = stat["etherealTraitKey"];
					etherealItemStatChoice.isSpecial = false;
					etherealItemStatChoice.slots = stat["etherealSlots"];
					etherealItemStatChoice.valueFunction = Character.scaleLinearlyWithSystem(characterInstance);
					etherealItemStatChoice.exchangeRateFunction = Character.etherealExchangeRateFunction(0.5 * sourceStatStats["destinationPower"]);
					etherealItemStatChoice.weight = sourceStatStats["destinationWeight"];
					etherealItemStatChoice.tooltipDescriptionFormat = "+%s levels of " + stat["displayName"];
					etherealItemStatChoice.namePrefix = "";
					etherealItemStatChoice.nameSuffix = sourceStatStats["nameSuffix"];
					etherealItemStatChoice.params = {
						"destinationId": stat["id"]
					};
					etherealItemStats[etherealItemStatChoice.id] = etherealItemStatChoice;
				}
				*/
				
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
				
				/* Broken WIP
				if (sourceTraitStats["destinationWeight"] > 0)
				{
					// Note: sourceTraitStats is for the destination trait here.
					var etherealItemStatChoice:EtherealItemStatChoice = new EtherealItemStatChoice();
					etherealItemStatChoice.id = sourceTraitName + "ForSkillPoints";
					etherealItemStatChoice.key = sourceTraitName;
					etherealItemStatChoice.isSpecial = false;
					etherealItemStatChoice.slots = [0, 1, 2, 3, 4, 5, 6, 7];
					etherealItemStatChoice.valueFunction = Character.scaleLinearlyWithSystem(characterInstance);
					etherealItemStatChoice.exchangeRateFunction = Character.etherealExchangeRateFunction(0.5 * sourceTraitStats["destinationPower"]);
					etherealItemStatChoice.weight = sourceTraitStats["destinationWeight"];
					etherealItemStatChoice.tooltipDescriptionFormat = "+%s levels of " + sourceTraitStats["name"];
					etherealItemStatChoice.namePrefix = "";
					etherealItemStatChoice.nameSuffix = sourceTraitStats["nameSuffix"];
					etherealItemStatChoice.params = {
						"destinationId": sourceTraitName
					};
					etherealItemStats[etherealItemStatChoice.id] = etherealItemStatChoice;
				}
				*/
				
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
			/*var etherealItemSpecialChoices:Object = { };
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
			etherealItemStats[etherealRyanSpecial.id] = etherealRyanSpecial;*/
			
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
			// NEW MIGRATIONS GO AT THE BOTTOM!!!
			
			CH2.currentCharacter = characterInstance;
			
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
			
			if (characterInstance.version <= 6)
			{
				var highestWorld:int = characterInstance.highestWorldCompleted;
				var highestEtherealItem:int = characterInstance.highestEtherealItemAcquired;
				var worldsPerSystem:int = characterInstance.worldsPerSystem;
				if (highestWorld != highestEtherealItem)
				{
					for (var i:int = highestWorld; (i > highestEtherealItem) && (i >= highestWorld - 40); i--)
					{
						characterInstance.addEtherealItemToInventory(characterInstance.rollEtherealItem(characterInstance.currentWorld.starSystemId));
					}
					characterInstance.highestEtherealItemAcquired = highestWorld;
				}
			}
			
			if (characterInstance.version <= 7)
			{
				if (characterInstance.gilds > 0)
				{
					var firstWorldOfGild:Number = Math.floor((characterInstance.highestWorldCompleted + 1) / characterInstance.worldsPerSystem) * characterInstance.worldsPerSystem + 1;
					characterInstance.setGildBonus(firstWorldOfGild);
				}
			}
			
			
			// 0.09
			if (characterInstance.version <= 8)
			{
				if (characterInstance.gilds > 0)
				{
					var firstWorldOfGild:Number = Math.floor((characterInstance.highestWorldCompleted + 1) / characterInstance.worldsPerSystem) * characterInstance.worldsPerSystem + 1;
					var levelDiff:Number = characterInstance.level - ((firstWorldOfGild) * 5 + 6);
					characterInstance.statLevels[CH2.STAT_DAMAGE] = 0;
					characterInstance.levelUpStat(CH2.STAT_DAMAGE, levelDiff);
				}
			}
			
			if (characterInstance.version <= 9)
			{
				// Might need to actually force an ascension here to flush out changes to skill cooldowns etc.
				characterInstance.currentWorldEndAutomationOption = -1;
				characterInstance.resetAscension();
				characterInstance.statLevels = { };
				characterInstance.traits = { };
				characterInstance.totalStatPointsV2 = characterInstance.level - 1;
				characterInstance.spentStatPoints = new BigNumber(0);
				characterInstance.carryoverStatPoints = characterInstance.level - 1;
				characterInstance.ascensionDamageMultiplier = new BigNumber(1);
				var totalPowerNeeded:BigNumber = new BigNumber(1.1).pow(characterInstance.highestWorldCompleted);
				characterInstance.worldCrumbs = totalPowerNeeded.addN( -1).divideN(0.1);
				
				characterInstance.timeSinceLastTranscendenceMotePurchase = characterInstance.ancientShards * Character.ANCIENT_SHARD_PURCHASE_COOLDOWN;
				
				var highestSystemCompleted:Number = Math.floor(characterInstance.highestWorldCompleted / characterInstance.worldsPerSystem);
				var expectedHeroSouls:BigNumber = new BigNumber(0);
				
				for (var i:int = 1; i < characterInstance.worlds.ascensionWorlds.length; i++)
				{
					var world:AscensionWorld = characterInstance.worlds.ascensionWorlds[i];
					world.init(world.worldNumber);
				}
				
				for (var i:int = 1; i <= highestSystemCompleted; i++)
				{
					characterInstance.starfire++;
					characterInstance.starSystemAncientShards[i] = 5;
					expectedHeroSouls.plusEquals(Formulas.instance.getHeroSoulsForSystem(i));
					characterInstance.timeSinceLastTranscendenceMotePurchase += 5 * Character.ANCIENT_SHARD_PURCHASE_COOLDOWN;
				}
				
				if (characterInstance.timeSinceLastTranscendenceMotePurchase >= Character.TRANSCENDENCE_MOTE_PURCHASE_COOLDOWN)
				{
					characterInstance.transcendenceMotes = 1;
					characterInstance.timeSinceLastTranscendenceMotePurchase = 0;
				}
				
				characterInstance.pendingHeroSouls = expectedHeroSouls.powN(0.75).ceil();
				characterInstance.hasUnlockedTranscendencePanel = true;
				characterInstance.currentTranscendenceMoteCooldown = 1207800000;
				
				characterInstance.hasSeenMigrationPopup = false;
			}
			
			if (characterInstance.version <= 10)
			{
				// Convert for new transcendence changes.
				var convertedMotes:Number = Math.floor(characterInstance.transcendenceMotes * characterInstance.currentTranscendenceMoteCooldown / Character.TRANSCENDENCE_MOTE_PURCHASE_COOLDOWN);
				var fromUnfinishedMotes:Number = Math.floor(characterInstance.timeSinceLastTranscendenceMotePurchase / Character.TRANSCENDENCE_MOTE_PURCHASE_COOLDOWN);
				characterInstance.transcendenceMotes = convertedMotes + fromUnfinishedMotes;
				characterInstance.timeSinceLastTranscendenceMotePurchase -= Math.floor(characterInstance.timeSinceLastTranscendenceMotePurchase / Character.TRANSCENDENCE_MOTE_PURCHASE_COOLDOWN) * Character.TRANSCENDENCE_MOTE_PURCHASE_COOLDOWN;
				characterInstance.pendingHeroSouls.timesEqualsN(0.1);
				characterInstance.currentTranscendenceMoteCooldown = Character.TRANSCENDENCE_MOTE_PURCHASE_COOLDOWN;
				if (characterInstance.transcendenceMotes > 0)
				{
					characterInstance.hasUnlockedTranscendencePanel = true;
				}
			}
			
			if (characterInstance.version <= 12)
			{
				// Convert for new transcendence changes.
				characterInstance.currentWorldEndAutomationOption++;
			}
			
			if (characterInstance.version <= 13)
			{
				var previousMotes:Number = characterInstance.transcendenceMotes;
				characterInstance.transcendenceMotes = 0;
				characterInstance.firstTranscendenceMoteCooldown = (60 + 2 * Math.floor(characterInstance.transcensionLevel)) * Character.TRANSCENDENCE_MOTE_TIME_UNIT;
				characterInstance.currentTranscendenceMoteCooldown = characterInstance.firstTranscendenceMoteCooldown;
				var entitledMoteTime:Number = previousMotes * 84600000 + characterInstance.timeSinceLastTranscendenceMotePurchase;
				while (entitledMoteTime >= characterInstance.currentTranscendenceMoteCooldown)
				{
					entitledMoteTime -= characterInstance.currentTranscendenceMoteCooldown;
					characterInstance.timeSinceLastTranscendenceMotePurchase = characterInstance.currentTranscendenceMoteCooldown;
					characterInstance.onTranscendenceMotePurchase();
				}
				characterInstance.timeSinceLastTranscendenceMotePurchase = entitledMoteTime;
				characterInstance.pendingHeroSouls = characterInstance.pendingHeroSouls.divideN(6);
			}
			
			// ^^ NEW MIGRATIONS GO ABOVE THIS LINE ^^
			
			CH2.currentCharacter = null;
		}
		
		//public function helpfulAdventurerGetCalculatedEnergyCost(skill:Skill):Number
		public function getCalculatedEnergyCostOverride(skill:Skill):Number
		{
			if (!skill.usesMaxEnergy)
			{
				var cost:Number = skill.energyCost * (1 - CH2.currentCharacter.energyCostReduction.numberValue());
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
		
		public function applySystemTraitsOverride(worldNumber:Number):void
		{
			var character:Character = CH2.currentCharacter;
			var world:AscensionWorld = character.worlds.getWorld(worldNumber);
			var system:StarSystem = CH2.currentCharacter.getStarSystem(world.starSystemId);
			if (system.traits[WT_GARGANTUAN] && !system.traits[WT_UNDERFED])
			{
				character.monstersPerZone = 5;
				character.monsterHealthMultiplier = 10;
			}
			else if (system.traits[WT_UNDERFED] && !system.traits[WT_GARGANTUAN])
			{
				character.monstersPerZone = 200;
				character.monsterHealthMultiplier = 0.25;
			}
			else
			{
				character.monstersPerZone = 50;
				character.monsterHealthMultiplier = 1;
			}
			
			if (!character.buffs.hasBuffByName("Golden Clicks") || !character.getTrait("GloriousBounty"))
			{
				character.treasureChestsAreMonsters = false;
				character.treasureChestsHaveClickableGold = false;
			}
			
			if (character.getTrait("LimitedHaste") && !character.buffs.hasBuffByName("LimitedHaste"))
			{
				applyLimitedHaste();
			}
			
			CH2.currentCharacter.applySystemTraitsDefault(worldNumber);
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
				var animation:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(CH2.currentCharacter.getCurrentSkin().skinAssetId+"_fire", 60);
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
		
		public function canActivatePauseGem():Boolean
		{
			return !CH2.currentCharacter.isPaused;
		}
		
		public function canActivateUnpauseGem():Boolean
		{
			return CH2.currentCharacter.isPaused;
		}
		
		public function onPauseGemActivate():Boolean
		{
			if (canActivatePauseGem)
			{
				CH2.user.pauseGame();
				return true;
			}
			return false;
		}
		
		public function onUnpauseGemActivate():Boolean
		{
			if (canActivateUnpauseGem)
			{
				CH2.user.unpauseGame();
				return true;
			}
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
						var rubyPurchasePrice:Number = rubyPurchase.price;
						canPurchase = canPurchase || ((character.rubies >= rubyPurchasePrice) && rubyPurchase.canPurchase());
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
						CH2UI.instance.mainUI.rightPanel.currentPanel.doPurchase(i);
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
			var character:Character = CH2.currentCharacter;
			if (character.isRubyShopAvailable())
			{
				var madePurchase:Boolean = false;
				for (var i:int = 0; i < character.currentRubyShop.length; i++)
				{
					var currentPurchaseId:String = character.currentRubyShop[i].id;
					var rubyPurchase:RubyPurchase = character.getRubyPurchaseInstance(currentPurchaseId);
					if (rubyPurchase.canPurchase()) 
					{
						if (currentPurchaseId == "luckRunePurchase" || currentPurchaseId == "speedRunePurchase" || currentPurchaseId == "powerRunePurchase")
						{
							CH2UI.instance.mainUI.rightPanel.currentPanel.doPurchase(i);
							madePurchase = true;
							break;
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
			CH2.currentCharacter.setTrait("SmallReloads", 1, false, false);
		}
		
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
		
		public function getSystemTraitCountOverride(systemNumber:int):int
		{
			
			if (systemNumber > 20)
			{
				return 3;
			}
			else if (systemNumber > 10)
			{
				return 2;
			}
			else if (systemNumber > 1)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		
		public function getImprovedReloadTooltip(extraLevels:Number = 0):Function
		{
			return function(nodeLevel:Number):String
			{
				var level = nodeLevel + extraLevels;
				var resourceIncrease:Number = 10 * level * CH2.currentCharacter.getTraitMultiplier("ImprovedReload");
				
				var currentTraitLevel:Number = CH2.currentCharacter.getTrait("ImprovedReload");
				var newTraitLevel:Number =  (CH2.currentCharacter.traits["ImprovedReload"] + level) * CH2.currentCharacter.getTraitMultiplier("ImprovedReload");
				
				var currentCooldownEffect:Number = (0.6 * (1 - (1 / (1 + 0.005 * currentTraitLevel))));
				var newCooldownEffect:Number = (0.6 * (1 - (1 / (1 + 0.005 * (newTraitLevel)))));
				
				return "Increases Energy and Mana restored by Reload by " + resourceIncrease.toFixed(2) + " and reduces the remaining cooldown of skills by a further " + ((newCooldownEffect - currentCooldownEffect) * 100).toFixed(2) + "%.";
			}
		}
		
		public function getImprovedReloadTranscendencePerkTooltipFunction(key:String):Function
		{
			return function():String
			{
				var currentBaseValueEffect:Function = getImprovedReloadTooltip();
				
				var levelDifference:Number = 0.1;
				var nextBaseValueEffect:Function = getImprovedReloadTooltip(levelDifference);
				
				var tooltip:String = Character.getTranscendencePerkTooltipFunctionCommon(key)() + "\n\nCurrent Node Effect: " + currentBaseValueEffect(1);
				
				if (!Character.isPerkMaxLevel(key))
				{
					return tooltip + "\n\nEffect Next Level: " + nextBaseValueEffect(1);
				}
				else return tooltip;
			}
		}
		
		public function replaceStorm(newSkill:Skill):void
		{
			var character:Character = CH2.currentCharacter;
			var stormNames:Array = ["Clickstorm", "GoldenClicks", "Critstorm", "Autoattackstorm", "Clicktorrent"];
			var slot:Number = null;
			
			
			for (var i:int = 0; i < stormNames.length; i++)
			{
				if (character.skills[stormNames[i]] && character.skills[stormNames[i]].isActive)
				{
					character.buffs.removeBuff(stormNames[i]);
					slot = character.skills[stormNames[i]].slot;
					if (slot >= 0 && slot < CH2UI.instance.mainUI.hud.skillBar.skillSlots.length)
					{
						if (CH2UI.instance.mainUI.hud.skillBar.skillSlots[slot].skillSlotUI != null)
						{
							CH2UI.instance.mainUI.hud.skillBar.skillSlots[slot].skillSlotUI.skill = null;
							CH2UI.instance.mainUI.hud.skillBar.skillSlots[slot].skillSlotUI.removeItemIcon();
						}
					}
					character.deactivateSkill(stormNames[i]);
				}
			}
			character.activateSkill(newSkill.uid);
			if (slot)
			{
				newSkill.slot = slot;
			}
		}
		
		public function applyLimitedHaste():void
		{
			var buff:Buff = new Buff();
			buff.name = "LimitedHaste";
			buff.iconId = 176;
			buff.isUntimedBuff = true;
			buff.buffStat(CH2.STAT_DAMAGE, 3);
			buff.buffStat(CH2.STAT_HASTE, 0.5);
			
			buff.tooltipFunction = function() {
				return {
					"header": "Limited Haste",
					"body": "You deal 300% damage but your speed is halved."
				};
			}
			
			CH2.currentCharacter.buffs.addBuff(buff);
		}
		
	}
}