package
{
	import com.playsaurus.numbers.BigNumber;
	import flash.display.Sprite;
	import heroclickerlib.CH2;
	import com.playsaurus.model.Model;
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
	import models.Items;
	import models.Skill;
	import models.Character;
	import models.Monster;
	import models.Talent;
	import models.AttackData;
	import heroclickerlib.GpuMovieClip;
	import heroclickerlib.managers.CH2AssetManager;
	import com.gskinner.utils.Rnd;
	import heroclickerlib.managers.SoundManager;
	import HelpfulAdventurer.thumbnail;
	import ui.IdleHeroUIManager;
	
	public dynamic class HelpfulAdventurerMain extends Sprite
	{
		public static const CHARACTER_NAME:String = "Helpful Adventurer";
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
		
		public static const HUGE_CLICK:String = "HelpfulAdventurer_hugeClick";
		public static const BIG_CLICK:String = "HelpfulAdventurer_bigClicks";
		public static const BIG_GIANT_CLICK:String = "HelpfulAdventurer_bigGiantClick";
		public static const HUGE_CLICK_CRACK:String = "HelpfulAdventurer_hugeClickCrack";
		public static const BUFF_INDICATOR:String = "HelpfulAdventurer_indicator";
		public static const ENERGY_CHARGE:String = "HelpfulAdventurer_energyCharge";
		
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
		public static const CLICKSTORM_TOOLTIP:String = "Consumes 1.25 energy per second to click 2.5 times per second, until you run out of energy.";
		public static const CRITSTORM_TOOLTIP:String = "Consumes 1.25 energy per second to click 2.5 times per second, until you run out of energy. Clicks from this skill have +100% chance of being critical strikes.";
		public static const GOLDENCLICKS_TOOLTIP:String = "Consumes 1.25 energy per second to click 2.5 times per second, until you run out of energy. Doubles gold gained while active.";
		public static const CLICKTORRENT_TOOLTIP:String = "Consumes 10 energy per second to click 30 times per second, until you run out of energy.";
		public static const AUTOATTACKSTORM_TOOLTIP:String = "Consumes 1.25 mana per second to auto attacks 2.5 times per second, until you run out of mana.";
		
		
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
					"tooltip": "Increases your chance to score a critical hit by 2%." ,
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
					"name": "Boss Gold",
					"tooltip": "Multiplies your gold received from bosses by 200%." ,
					"flavorText": "If you're tired of farming bosses, this will roughly cut it in half. Can you prove this?",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_BOSS_GOLD)},
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
					"tooltip": "Increases your chance of finding bonus gold by 2%." ,
					"flavorText": "When killing monsters, bonus gold may appear. This is a linear bonus, like Crit Chance." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_BONUS_GOLD_CHANCE)},
					"icon": "goldChance"
				},
				"Tc": { 
					"name": "Treasure Chest Chance",
					"tooltip": "Increases the chance that a monster happens to be a treasure chest by 2%." ,
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
					"name": "Equipment: Weapon",
					"tooltip": "Multiplies the damage you deal with weapons by 150%" ,
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
					"name": "Equipment: Chest",
					"tooltip": "Multiplies the damage you deal with chest pieces by 150%" ,
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
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_HANDS_DAMAGE)},
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
					"name": "Equipment: Capes",
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
					"tooltip": "Increases the number of clicks empowered by Big Clicks by 1",
					"flavorText": "They march loyally behind you in unison, each one prepared to sacrifice itself for your cause.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("BigClickStacks", 1)},
					"icon": "bigClicks"
				},
				"Bd": { 
					"name": "Bigger Big Clicks",
					"tooltip": "Multiplies the damage done by Big Clicks by 125%",
					"flavorText": "They might not look any bigger when you get this upgrade. They're bigger on the inside. In fact, they weigh a lot more.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("BigClicksDamage", 1)},
					"icon": "bigClicks"
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
					"tooltip": "Increases the effect of Reload by 10%." ,
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
					"icon": "bigClicks"
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
					"tooltip": "Restores energy and mana and reduces the remaining cooldown of all skills by 10%." ,
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
					"tooltip": "Multiplies your gold received from bosses by 800%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_BOSS_GOLD, 3)},
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
					"tooltip": "Increases number of gold piles found by 30%.",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_CHANCE, 3)},
					"icon": "goldPiles"
				},
				"qBg": {
					"name": "Fortuna's Luck",
					"tooltip": "Increases your chance of finding bonus gold by 6%.",
					"flavorText": "When killing monsters, bonus gold may appear. This is a linear bonus, like Crit Chance." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_BONUS_GOLD_CHANCE, 3)},
					"icon": "goldChance"
				},
				"qTc": {
					"name": "Mimzee's Favor",
					"tooltip": "Increases the chance that a monster is a treasure chest by 6%.",
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
					"icon": "bigClicks"
				},
				"qBd": { 
					"name": "Mega Bigger Big Clicks",
					"tooltip": "Increases the damage done by Big Clicks by 95%",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.addTrait("BigClicksDamage", 3)},
					"icon": "bigClicks"
				},
				"qHd": { 
					"name": "Mega Huger Huge Click",
					"tooltip": "Increases the damage of Huge Click by 95%",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("HugeClickDamage", 3);},
					"icon": "hugeClicks"
				},
				"qMd": { 
					"name": "Mega Mana Crit Damage",
					"tooltip": "Mana Crits do 95% more damage",
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
					"tooltip": "Spending energy deals damage equal to one click per energy." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("Discharge", 1);},  
					"icon": "damagex3"
				},
				"Q25": { 
					"name": "Gift of Chronos",
					"tooltip": "Spending mana increases haste for 5 seconds." ,
					"flavorText": null,
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
					"tooltip": "Critical Hits from Auto Attacks restore 1 mana." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("AutoAttackCritMana", 1);},  
					"icon": "damagex3"
				},
				"Q29": { 
					"name": "AutoAttackStorm",
					"tooltip": AUTOATTACKSTORM_TOOLTIP, //"A skill. Consumes 1.25 mana per second to auto attack an extra 2.5 times per second.",
					"flavorText": "AutoAttackStorm is like Clickstorm, but does not replace it and can be used in conjunction with Clickstorm.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.replaceSkill("Clickstorm", CH2.currentCharacter.getStaticSkill("Autoattackstorm"));},  
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
					"purchaseFunction": function() {CH2.currentCharacter.replaceSkill("Clickstorm", CH2.currentCharacter.getStaticSkill("GoldenClicks"));},  
					"icon": "damagex3"
				},
				"Q42": { 
					"name": "Huge Click Discount",
					"tooltip": "Huge Click further increases the effect of Item Cost Reduction by 0.5% of Huge Click's damage bonus for four seconds." ,
					"flavorText": null,
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
					"tooltip": "Reload's effects and cooldown are reduced by 90%." ,
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
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("BhallsRise", 1);},  
					"icon": "damagex3"
				},
				"Q62": { 
					"name": "Improved Mana Crit",
					"tooltip": "Crit Chance increases the damage of Mana Crit and gives a chance to refund mana cost. (CLARIFY)" ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("ImprovedManaCrit", 1);},  
					"icon": "damagex3"
				},
				"Q63": { 
					"name": "Critical Killing Surge",
					"tooltip": "Monsters killed with a Critical Hit reduces the cooldown of Power Surge by 5 seconds." ,
					"flavorText": "Casting a cooldown-improved Power Surge will reset the cooldown of your *next* Power Surge to its original duration.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("CritKillPowerSurge", 1);},  
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
					"purchaseFunction": function() {CH2.currentCharacter.replaceSkill("Clickstorm", CH2.currentCharacter.getStaticSkill("Critstorm"));},
					"icon": "damagex3"
				},
				"Q66": { 
					"name": "Critical Power Surge",
					"tooltip": "PowerSurge, upon activating, decreases Crit Chance by 100%, and then increases Crit Chance by 5% every second until it ends." ,
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
					"tooltip": "Gain 100% haste upon killing a monster. Lasts 5 seconds, quickly decreasing over time." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.addTrait("KillingFrenzy", 1);},  
					"icon": "damagex3"
				},
				"Q84": { 
					"name": "Small Clicks",
					"tooltip": "Replaces Big Clicks with Small Clicks. Small Clicks are half as strong, but there are twice as many of them." ,
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
					"purchaseFunction": function() {CH2.currentCharacter.replaceSkill("Clickstorm", CH2.currentCharacter.getStaticSkill("Clicktorrent"));},  
					"icon": "damagex3"
				},
				//###################################################################
				//############################ AUTOMATOR ############################
				//###################################################################
				"A0": { // Needs Icon
					"name": "Automator",
					"tooltip": "Unlocks the Automator." ,
					"flavorText": null,
					"loadFunction": function() { },
					"setupFunction": function() { unlockAutomator(); CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_15", tripleClick); CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_16", bigClicks);},
					"purchaseFunction": function() { purchaseAutomator();  CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_15");  CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_16"); },
					"icon": "automator"
				},
				"A1": { 
					"name": "Automator Gem: MultiClick",
					"tooltip": "Automates MultiClick." ,
					"flavorText": null,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_15", tripleClick); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_15");  },
					"icon": "gemNineClicks"
				},
				"A3": { 
					"name": "Automator Gem: Big Clicks",
					"tooltip": "Automates Big Clicks." ,
					"flavorText": null,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_16", bigClicks); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_16"); },
					"icon": "gemGameBigClicks"
				},
				"A5": { 
					"name": "Automator Gem: Huge Click",
					"tooltip": "Automates Huge Click." ,
					"flavorText": null,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_17", hugeClick); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_17"); },
					"icon": "gemHugeClicks"
				},
				"A4": { 
					"name": "Automator Gem: Clickstorm",
					"tooltip": "Automates Clickstorm." ,
					"flavorText": null,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_51", clickstorm); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_51"); },
					"icon": "gemClickstorm"
				},
				"Av": { 
					"name": "Automator Gem: Upgrade Cheapest Item",
					"tooltip": "Automates Upgrading the Cheapest Item." ,
					"flavorText": null,
					"setupFunction": function() { addUpgradeCheapestItemGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_5");  },
					"icon": "gemUpgradeCheapest"
				},
				"Au": { 
					"name": "Automator Gem: Buy Random Catalog",
					"tooltip": "Automates Buying a Random Catalog Item." ,
					"flavorText": "The Catalog is that area on the bottom left of the UI where you purchase new items.",
					"setupFunction": function() { addBuyRandomCatalogItemGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_4");  },
					"icon": "gemBuyRandom"
				},
				"A2": { 
					"name": "Automator Gem: Energize.",
					"tooltip": "Automates Energize." ,
					"flavorText": null,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_18", energize); },
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_18"); },
					"icon": "gemEnergize"
				},
				"A6": { 
					"name": "Automator Gem: Powersurge.",
					"tooltip": "Automates Powersurge." ,
					"flavorText": null,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_19", powerSurge); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_19"); },
					"icon": "gemPowersurge"
				},
				"A7": { 
					"name": "Automator Gem: Mana Crit",
					"tooltip": "Automates Mana Crit." ,
					"flavorText": null,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_20", manaClick); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_20"); },
					"icon": "gemManaClick" 
				},
				"A8": { 
					"name": "Automator Gem: Reload",
					"tooltip": "Automates Reload." ,
					"flavorText": null,
					"setupFunction": function() { CH2.currentCharacter.automator.addSkillGem(CHARACTER_NAME+"_52", reload); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_52"); },
					"icon": "gemReload" 
				},
				"Aw": { //incomplete
					"name": "Automator Gem: Next Set",
					"tooltip": "Switch to the next Automator Set." ,
					"flavorText": null,
					"setupFunction": function(){ addNextSetGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_21"); },  // Needs Implementation!
					"icon": "gemSwitchNext"
				},
				"Ax": { //incomplete
					"name": "Automator Gem: Previous Set",
					"tooltip": "Switch to the previous Automator Set." ,
					"flavorText": null,
					"setupFunction": function(){ addPreviousSetGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_22"); },  // Needs Implementation!
					"icon": "gemSwitchPrev"
				},
				"Ay": { 
					"name": "Automator Set",
					"tooltip": "Unlocks an additional set for the Automator." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.automator.addQueueSet(); },
					"icon": "gemAddSet"
				},
				"Az": {
					"name": "Automator Speed",
					"tooltip": "Speeds up the Automator by 25%." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.levelUpStat(CH2.STAT_AUTOMATOR_SPEED); },
					"icon": "automatorSpeed"
				},
				"S1": { 
					"name": "Automator Stone: Always",
					"tooltip": "A stone that can always activate." ,
					"flavorText": null,
					"setupFunction": function() { addAlwaysStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_1");  },
					"icon": "always"
				},
				"S2": { 
					"name": "Automator Stone: MH > 50%",
					"tooltip": "A stone that can activate when the next monster's health is greater than 50%." ,
					"flavorText": null,
					"setupFunction": function() { addMHGreaterThan50PercentStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_5");  },
					"icon": "mhGreater50"
				},
				"S3": { 
					"name": "Automator Stone: MH < 50%",
					"tooltip": "A stone that can activate when the next monster's health is less than 50%." ,
					"flavorText": null,
					"setupFunction": function() { addMHLessThan50PercentStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_6"); },
					"icon": "mhLower50"
				},
				"S4": { 
					"name": "Automator Stone: Energy > 90%",
					"tooltip": "A stone that can activate when your energy is above 90%." ,
					"flavorText": null,
					"setupFunction": function() { addGreaterThan90PercentEnergyStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_7"); },
					"icon": "energyGreater90"
				},
				"S5": { 
					"name": "Automator Stone: Energy < 10%",
					"tooltip": "A stone that can activate when your energy is below 10%." ,
					"flavorText": null,
					"setupFunction": function() { addLessThan10PercentEnergyStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_8");},
					"icon": "energyLower10"
				},
				"S6": { 
					"name": "Automator Stone: Mana > 90%",
					"tooltip": "A stone that can activate when your mana is above 90%." ,
					"flavorText": null,
					"setupFunction": function() { addGreaterThan90PercentManaStone(); },
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_9");},
					"icon": "manaGreater90"
				},
				"S7": { 
					"name": "Automator Stone: Mana < 10%",
					"tooltip": "A stone that can activate when your mana is below 10%." ,
					"flavorText": null,
					"setupFunction": function(){ addLessThan10PercentManaStone(); },
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_10");},
					"icon": "manaLower10"
				},
				"S8": {
					"name": "Automator Stone: Zone Start",
					"tooltip": "A stone that can activate during the first half of a zone." ,
					"flavorText": null,
					"setupFunction": function() { addZoneStartStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_19"); },
					"icon": "zoneStart"
				},
				"S9": {
					"name": "Automator Stone: Zone Middle",
					"tooltip": "A stone that can activate during the second half of a zone." ,
					"flavorText": null,
					"setupFunction": function() { addZoneMiddleStone(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_20"); },
					"icon": "zoneMiddle"
				},
				"Sc": { 
					"name": "Automator Stone: 4s CD",
					"tooltip": "A stone that can activate once every 4 seconds." ,
					"flavorText": null,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_11", 4000);},
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_11"); },
					"icon": "CD4S"
				},
				"Sd": { 
					"name": "Automator Stone: 8s CD",
					"tooltip": "A stone that can activate once every 8 seconds." ,
					"flavorText": null,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_12", 8000);},
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_12"); },
					"icon": "CD8S"
				},
				"Se": { 
					"name": "Automator Stone: 40s CD",
					"tooltip": "A stone that can activate once every 40 seconds." ,
					"flavorText": null,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_13", 40000);},
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_13"); },
					"icon": "CD40S"
				},
				"Sf": { 
					"name": "Automator Stone: 90s CD",
					"tooltip": "A stone that can activate once every 90 seconds." ,
					"flavorText": null,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_14", 90000);},
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_14"); },
					"icon": "CD90S"
				},
				"Sg": { 
					"name": "Automator Stone: 10m CD",
					"tooltip": "A stone that can activate once every 10 minutes." ,
					"flavorText": null,
					"setupFunction": function(){CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_15", 600000);},
					"purchaseFunction": function() {CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_15");},
					"icon": "CD10M"
				},
				//###################################################################
				//#TEST NODES AND/OR NODES THAT ARE NOT AND MAY NEVER BE IMPLEMENTED#
				//###################################################################		
				"Pc": { 
					"name": "Pierce Chance (NOT IN GAME)",
					"tooltip": "Increases your chance to hit an additional monster by 1%." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_PIERCE_CHANCE)},
					"icon": "pierceChance"
				},
				"Test": {
					"name": "Test Cheats",
					"tooltip": "Easy access test nodes that you can find scattered throughout the tree.",
					"flavorText": null,
					"setupFunction": function(){},
					"alwaysAvailable": true,
					"purchaseFunction": function() {},
					"icon": ""
				},
				"Tp": { 
					"name": "Talent Point",
					"tooltip": "(GONE) Increases the number of talent points you start the world with by 1." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {},
					"icon": "talentPoint"
				},
				"q": {
					"name": "These should no longer exist",
					"tooltip": "Let Hotara know if you spot one",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_DAMAGE)},
					"icon": "damagex3"
				},
				"qCc": { 
					"name": "+20% Crit Chance",
					"tooltip": "This Node does not actually exist in the game." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_CHANCE, 10)},
					"icon": "critChance"
				},
				"": {
					"name": "TBD",
					"tooltip": "To Be Determined (temporarily gold)",
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD)},
					"icon": "goldx3"
				},
				"Nc": { 
					"name": "MultiClick",
					"tooltip": "Multiplies your damage from MultiClicks by " + GRAPH_NODE_NINE_CLICK_MULTIPLIER ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {},
					"icon": "nineClicks"
				},
				"Z01": { 
					"name": "Automator Gem: Attempt Boss",
					"tooltip": "Automates Attempting a Boss." ,
					"flavorText": null,
					"setupFunction": function() { addAttemptBossGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_10");  },
					"icon": "gemAttemptBoss"
				},
				"A9": { 
					"name": "Automator Gem: Dash",
					"tooltip": "Automates Dash." ,
					"flavorText": null,
					"setupFunction": function() { addDashGem(); },
					"purchaseFunction": function() { CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_3");  },
					"icon": "gemDash"
				},
				"Z00": { 
					"name": "Automator Slot",
					"tooltip": "Unlocks an additional slot for the Automator." ,
					"flavorText": null,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.automator.addQueueSlot(); },
					"icon": "gemAddSlot"
				}
			}
			
//tumor		helpfulAdventurer.levelGraphObject = {"edges":[{"1":[514, 552]}, {"2":[76, 634]}, {"3":[290, 627]}, {"4":[153, 274]}, {"5":[564, 565]}, {"6":[164, 264]}, {"7":[536, 538]}, {"8":[101, 441]}, {"9":[596, 616]}, {"10":[96, 98]}, {"11":[482, 540]}, {"12":[44, 45]}, {"13":[35, 36]}, {"14":[487, 614]}, {"15":[301, 384]}, {"16":[297, 372]}, {"17":[48, 49]}, {"18":[116, 118]}, {"19":[625, 629]}, {"20":[341, 406]}, {"21":[165, 166]}, {"22":[573, 606]}, {"23":[660, 674]}, {"24":[553, 554]}, {"25":[61, 62]}, {"26":[343, 368]}, {"27":[349, 369]}, {"28":[194, 260]}, {"29":[129, 192]}, {"30":[420, 421]}, {"31":[122, 123]}, {"32":[576, 577]}, {"33":[567, 612]}, {"34":[153, 240]}, {"35":[53, 411]}, {"36":[302, 403]}, {"37":[264, 266]}, {"38":[295, 340]}, {"39":[151, 265]}, {"40":[63, 198]}, {"41":[78, 452]}, {"42":[185, 241]}, {"43":[388, 391]}, {"44":[652, 653]}, {"45":[662, 663]}, {"46":[320, 398]}, {"47":[365, 382]}, {"48":[208, 209]}, {"49":[339, 367]}, {"50":[304, 666]}, {"51":[384, 385]}, {"52":[120, 447]}, {"53":[534, 586]}, {"54":[374, 396]}, {"55":[359, 362]}, {"56":[513, 537]}, {"57":[394, 402]}, {"58":[307, 433]}, {"59":[510, 512]}, {"60":[248, 250]}, {"61":[353, 397]}, {"62":[277, 278]}, {"63":[80, 659]}, {"64":[576, 608]}, {"65":[634, 674]}, {"66":[305, 322]}, {"67":[91, 93]}, {"68":[38, 40]}, {"69":[231, 233]}, {"70":[95, 98]}, {"71":[60, 68]}, {"72":[139, 244]}, {"73":[212, 251]}, {"74":[79, 80]}, {"75":[203, 259]}, {"76":[402, 429]}, {"77":[47, 620]}, {"78":[342, 430]}, {"79":[61, 89]}, {"80":[626, 646]}, {"81":[503, 599]}, {"82":[332, 410]}, {"83":[490, 554]}, {"84":[288, 289]}, {"85":[630, 655]}, {"86":[109, 654]}, {"87":[142, 184]}, {"88":[525, 526]}, {"89":[354, 427]}, {"90":[344, 671]}, {"91":[37, 38]}, {"92":[312, 391]}, {"93":[28, 33]}, {"94":[156, 218]}, {"95":[593, 617]}, {"96":[75, 114]}, {"97":[186, 279]}, {"98":[7, 39]}, {"99":[111, 451]}, {"100":[132, 166]}, {"101":[303, 364]}, {"102":[5, 6]}, {"103":[477, 584]}, {"104":[481, 550]}, {"105":[497, 605]}, {"106":[187, 188]}, {"107":[282, 283]}, {"108":[348, 349]}, {"109":[10, 16]}, {"110":[305, 432]}, {"111":[318, 319]}, {"112":[344, 345]}, {"113":[160, 169]}, {"114":[144, 238]}, {"115":[136, 266]}, {"116":[172, 174]}, {"117":[339, 368]}, {"118":[638, 639]}, {"119":[563, 564]}, {"120":[505, 506]}, {"121":[517, 528]}, {"122":[222, 256]}, {"123":[244, 245]}, {"124":[157, 220]}, {"125":[92, 442]}, {"126":[33, 50]}, {"127":[127, 340]}, {"128":[142, 171]}, {"129":[667, 668]}, {"130":[310, 360]}, {"131":[189, 190]}, {"132":[28, 39]}, {"133":[571, 574]}, {"134":[49, 124]}, {"135":[479, 515]}, {"136":[138, 214]}, {"137":[317, 413]}, {"138":[62, 110]}, {"139":[84, 128]}, {"140":[286, 647]}, {"141":[327, 328]}, {"142":[307, 412]}, {"143":[182, 213]}, {"144":[364, 414]}, {"145":[66, 461]}, {"146":[164, 169]}, {"147":[237, 270]}, {"148":[375, 376]}, {"149":[341, 405]}, {"150":[322, 353]}, {"151":[422, 424]}, {"152":[550, 595]}, {"153":[27, 32]}, {"154":[97, 628]}, {"155":[323, 438]}, {"156":[107, 111]}, {"157":[184, 189]}, {"158":[183, 209]}, {"159":[86, 127]}, {"160":[377, 416]}, {"161":[91, 121]}, {"162":[140, 275]}, {"163":[545, 589]}, {"164":[526, 597]}, {"165":[372, 409]}, {"166":[474, 551]}, {"167":[46, 47]}, {"168":[498, 593]}, {"169":[393, 419]}, {"170":[473, 562]}, {"171":[71, 656]}, {"172":[173, 178]}, {"173":[37, 52]}, {"174":[511, 569]}, {"175":[305, 349]}, {"176":[134, 253]}, {"177":[292, 348]}, {"178":[413, 420]}, {"179":[515, 516]}, {"180":[58, 96]}, {"181":[91, 281]}, {"182":[303, 374]}, {"183":[562, 616]}, {"184":[300, 386]}, {"185":[446, 649]}, {"186":[133, 255]}, {"187":[392, 415]}, {"188":[176, 177]}, {"189":[161, 162]}, {"190":[548, 557]}, {"191":[131, 195]}, {"192":[571, 585]}, {"193":[316, 390]}, {"194":[331, 333]}, {"195":[192, 193]}, {"196":[56, 89]}, {"197":[323, 398]}, {"198":[374, 375]}, {"199":[106, 468]}, {"200":[67, 658]}, {"201":[530, 596]}, {"202":[148, 207]}, {"203":[271, 277]}, {"204":[644, 645]}, {"205":[72, 82]}, {"206":[227, 230]}, {"207":[396, 401]}, {"208":[70, 621]}, {"209":[592, 605]}, {"210":[218, 219]}, {"211":[65, 67]}, {"212":[326, 439]}, {"213":[241, 641]}, {"214":[449, 622]}, {"215":[195, 196]}, {"216":[3, 4]}, {"217":[60, 73]}, {"218":[138, 212]}, {"219":[68, 662]}, {"220":[337, 411]}, {"221":[173, 266]}, {"222":[126, 128]}, {"223":[12, 20]}, {"224":[380, 386]}, {"225":[500, 573]}, {"226":[383, 384]}, {"227":[176, 257]}, {"228":[496, 586]}, {"229":[469, 639]}, {"230":[380, 390]}, {"231":[638, 640]}, {"232":[19, 28]}, {"233":[62, 90]}, {"234":[353, 427]}, {"235":[215, 221]}, {"236":[327, 437]}, {"237":[218, 272]}, {"238":[310, 363]}, {"239":[162, 163]}, {"240":[194, 201]}, {"241":[508, 536]}, {"242":[224, 236]}, {"243":[329, 330]}, {"244":[71, 96]}, {"245":[630, 648]}, {"246":[80, 462]}, {"247":[317, 319]}, {"248":[231, 232]}, {"249":[72, 88]}, {"250":[321, 408]}, {"251":[152, 182]}, {"252":[463, 625]}, {"253":[17, 19]}, {"254":[490, 509]}, {"255":[234, 270]}, {"256":[68, 464]}, {"257":[602, 611]}, {"258":[518, 552]}, {"259":[105, 120]}, {"260":[113, 121]}, {"261":[572, 586]}, {"262":[311, 319]}, {"263":[471, 520]}, {"264":[612, 613]}, {"265":[216, 245]}, {"266":[235, 274]}, {"267":[488, 536]}, {"268":[52, 53]}, {"269":[324, 440]}, {"270":[370, 429]}, {"271":[102, 106]}, {"272":[477, 583]}, {"273":[156, 217]}, {"274":[51, 194]}, {"275":[308, 357]}, {"276":[222, 223]}, {"277":[546, 549]}, {"278":[412, 414]}, {"279":[577, 667]}, {"280":[57, 116]}, {"281":[76, 114]}, {"282":[507, 508]}, {"283":[204, 205]}, {"284":[117, 466]}, {"285":[286, 447]}, {"286":[559, 568]}, {"287":[160, 161]}, {"288":[305, 350]}, {"289":[288, 624]}, {"290":[557, 558]}, {"291":[30, 31]}, {"292":[146, 210]}, {"293":[85, 86]}, {"294":[480, 547]}, {"295":[54, 582]}, {"296":[566, 567]}, {"297":[115, 117]}, {"298":[226, 237]}, {"299":[634, 636]}, {"300":[64, 460]}, {"301":[355, 357]}, {"302":[324, 410]}, {"303":[207, 228]}, {"304":[88, 630]}, {"305":[6, 7]}, {"306":[109, 632]}, {"307":[110, 112]}, {"308":[643, 659]}, {"309":[417, 428]}, {"310":[324, 434]}, {"311":[450, 644]}, {"312":[524, 525]}, {"313":[16, 25]}, {"314":[190, 200]}, {"315":[150, 225]}, {"316":[18, 25]}, {"317":[506, 510]}, {"318":[591, 612]}, {"319":[103, 636]}, {"320":[392, 432]}, {"321":[215, 273]}, {"322":[223, 224]}, {"323":[464, 632]}, {"324":[334, 434]}, {"325":[151, 268]}, {"326":[483, 531]}, {"327":[240, 243]}, {"328":[587, 598]}, {"329":[664, 665]}, {"330":[448, 640]}, {"331":[99, 441]}, {"332":[321, 371]}, {"333":[81, 659]}, {"334":[205, 207]}, {"335":[254, 255]}, {"336":[489, 539]}, {"337":[636, 637]}, {"338":[293, 377]}, {"339":[105, 643]}, {"340":[57, 59]}, {"341":[592, 620]}, {"342":[370, 415]}, {"343":[572, 588]}, {"344":[537, 543]}, {"345":[298, 394]}, {"346":[64, 113]}, {"347":[295, 430]}, {"348":[468, 637]}, {"349":[389, 391]}, {"350":[17, 18]}, {"351":[378, 431]}, {"352":[313, 381]}, {"353":[347, 419]}, {"354":[29, 32]}, {"355":[387, 388]}, {"356":[584, 585]}, {"357":[205, 227]}, {"358":[502, 503]}, {"359":[532, 533]}, {"360":[268, 269]}, {"361":[315, 323]}, {"362":[442, 657]}, {"363":[350, 435]}, {"364":[601, 620]}, {"365":[385, 386]}, {"366":[191, 192]}, {"367":[579, 580]}, {"368":[199, 201]}, {"369":[291, 346]}, {"370":[287, 444]}, {"371":[393, 394]}, {"372":[102, 107]}, {"373":[373, 404]}, {"374":[345, 346]}, {"375":[74, 75]}, {"376":[171, 172]}, {"377":[365, 373]}, {"378":[87, 88]}, {"379":[561, 562]}, {"380":[542, 618]}, {"381":[219, 221]}, {"382":[4, 5]}, {"383":[577, 578]}, {"384":[498, 615]}, {"385":[307, 400]}, {"386":[445, 635]}, {"387":[507, 510]}, {"388":[540, 610]}, {"389":[1, 2]}, {"390":[232, 238]}, {"391":[126, 632]}, {"392":[168, 187]}, {"393":[133, 196]}, {"394":[123, 643]}, {"395":[493, 556]}, {"396":[527, 535]}, {"397":[108, 450]}, {"398":[573, 608]}, {"399":[509, 533]}, {"400":[181, 211]}, {"401":[590, 607]}, {"402":[92, 93]}, {"403":[209, 210]}, {"404":[96, 655]}, {"405":[147, 226]}, {"406":[325, 439]}, {"407":[495, 574]}, {"408":[14, 15]}, {"409":[378, 381]}, {"410":[76, 101]}, {"411":[329, 437]}, {"412":[226, 228]}, {"413":[117, 118]}, {"414":[512, 513]}, {"415":[309, 352]}, {"416":[239, 273]}, {"417":[467, 623]}, {"418":[293, 343]}, {"419":[83, 84]}, {"420":[619, 620]}, {"421":[627, 628]}, {"422":[11, 12]}, {"423":[548, 560]}, {"424":[559, 562]}, {"425":[669, 670]}, {"426":[580, 582]}, {"427":[316, 434]}, {"428":[94, 95]}, {"429":[75, 459]}, {"430":[21, 23]}, {"431":[149, 222]}, {"432":[472, 514]}, {"433":[140, 249]}, {"434":[175, 181]}, {"435":[170, 673]}, {"436":[231, 672]}, {"437":[146, 202]}, {"438":[522, 589]}, {"439":[26, 46]}, {"440":[304, 328]}, {"441":[135, 247]}, {"442":[132, 167]}, {"443":[90, 92]}, {"444":[641, 642]}, {"445":[78, 654]}, {"446":[523, 524]}, {"447":[485, 522]}, {"448":[287, 647]}, {"449":[115, 124]}, {"450":[500, 607]}, {"451":[179, 213]}, {"452":[137, 177]}, {"453":[24, 63]}, {"454":[471, 519]}, {"455":[520, 523]}, {"456":[548, 555]}, {"457":[233, 267]}, {"458":[141, 181]}, {"459":[79, 124]}, {"460":[330, 331]}, {"461":[144, 185]}, {"462":[546, 601]}, {"463":[650, 657]}, {"464":[50, 51]}, {"465":[371, 426]}, {"466":[26, 27]}, {"467":[243, 245]}, {"468":[78, 87]}, {"469":[283, 635]}, {"470":[348, 435]}, {"471":[161, 229]}, {"472":[556, 560]}, {"473":[299, 415]}, {"474":[99, 102]}, {"475":[482, 618]}, {"476":[41, 77]}, {"477":[486, 505]}, {"478":[497, 604]}, {"479":[660, 661]}, {"480":[551, 566]}, {"481":[326, 437]}, {"482":[284, 287]}, {"483":[415, 422]}, {"484":[151, 259]}, {"485":[54, 55]}, {"486":[570, 574]}, {"487":[342, 343]}, {"488":[281, 453]}, {"489":[104, 465]}, {"490":[13, 14]}, {"491":[211, 212]}, {"492":[7, 8]}, {"493":[504, 520]}, {"494":[2, 3]}, {"495":[43, 44]}, {"496":[549, 604]}, {"497":[323, 421]}, {"498":[492, 532]}, {"499":[578, 581]}, {"500":[630, 631]}, {"501":[478, 502]}, {"502":[501, 502]}, {"503":[400, 424]}, {"504":[627, 656]}, {"505":[72, 465]}, {"506":[179, 269]}, {"507":[517, 518]}, {"508":[175, 202]}, {"509":[10, 11]}, {"510":[131, 186]}, {"511":[519, 553]}, {"512":[284, 288]}, {"513":[222, 280]}, {"514":[135, 279]}, {"515":[203, 206]}, {"516":[454, 651]}, {"517":[77, 541]}, {"518":[488, 543]}, {"519":[467, 658]}, {"520":[36, 37]}, {"521":[476, 597]}, {"522":[131, 163]}, {"523":[118, 123]}, {"524":[100, 448]}, {"525":[530, 535]}, {"526":[561, 602]}, {"527":[404, 439]}, {"528":[306, 427]}, {"529":[355, 397]}, {"530":[8, 9]}, {"531":[303, 420]}, {"532":[489, 541]}, {"533":[582, 583]}, {"534":[168, 170]}, {"535":[588, 612]}, {"536":[456, 631]}, {"537":[290, 451]}, {"538":[83, 104]}, {"539":[591, 611]}, {"540":[498, 600]}, {"541":[177, 178]}, {"542":[21, 22]}, {"543":[296, 407]}, {"544":[25, 26]}, {"545":[260, 261]}, {"546":[167, 170]}, {"547":[73, 125]}, {"548":[492, 530]}, {"549":[605, 606]}, {"550":[325, 438]}, {"551":[145, 230]}, {"552":[640, 648]}, {"553":[499, 613]}, {"554":[516, 614]}, {"555":[214, 276]}, {"556":[403, 409]}, {"557":[41, 129]}, {"558":[106, 652]}, {"559":[61, 457]}, {"560":[128, 470]}, {"561":[89, 130]}, {"562":[42, 443]}, {"563":[561, 566]}, {"564":[29, 30]}, {"565":[66, 70]}, {"566":[294, 379]}, {"567":[213, 217]}, {"568":[188, 192]}, {"569":[267, 274]}, {"570":[308, 359]}, {"571":[366, 411]}, {"572":[81, 108]}, {"573":[571, 600]}, {"574":[410, 663]}, {"575":[42, 59]}, {"576":[361, 425]}, {"577":[64, 65]}, {"578":[84, 633]}, {"579":[408, 425]}, {"580":[538, 539]}, {"581":[22, 31]}, {"582":[418, 428]}, {"583":[484, 580]}, {"584":[55, 56]}, {"585":[480, 517]}, {"586":[20, 31]}, {"587":[250, 259]}, {"588":[481, 609]}, {"589":[356, 360]}, {"590":[483, 525]}, {"591":[475, 546]}, {"592":[301, 387]}, {"593":[590, 594]}, {"594":[382, 383]}, {"595":[532, 568]}, {"596":[342, 418]}, {"597":[33, 34]}, {"598":[501, 521]}, {"599":[649, 650]}, {"600":[152, 206]}, {"601":[435, 642]}, {"602":[358, 361]}, {"603":[155, 262]}, {"604":[119, 122]}, {"605":[289, 651]}, {"606":[455, 626]}, {"607":[158, 179]}, {"608":[640, 653]}, {"609":[378, 406]}, {"610":[207, 208]}, {"611":[202, 280]}, {"612":[59, 668]}, {"613":[354, 356]}, {"614":[24, 598]}, {"615":[132, 197]}, {"616":[199, 200]}, {"617":[517, 563]}, {"618":[570, 572]}, {"619":[372, 661]}, {"620":[331, 440]}, {"621":[369, 370]}, {"622":[172, 173]}, {"623":[69, 70]}, {"624":[159, 183]}, {"625":[275, 276]}, {"626":[141, 174]}, {"627":[249, 252]}, {"628":[15, 40]}, {"629":[284, 285]}, {"630":[388, 407]}, {"631":[362, 363]}, {"632":[319, 423]}, {"633":[60, 103]}, {"634":[30, 48]}, {"635":[193, 194]}, {"636":[159, 204]}, {"637":[290, 645]}, {"638":[241, 242]}, {"639":[474, 594]}, {"640":[236, 239]}, {"641":[292, 347]}, {"642":[555, 565]}, {"643":[302, 341]}, {"644":[9, 10]}, {"645":[155, 263]}, {"646":[159, 261]}, {"647":[486, 587]}, {"648":[154, 215]}, {"649":[253, 257]}, {"650":[394, 395]}, {"651":[158, 271]}, {"652":[143, 192]}, {"653":[335, 336]}, {"654":[83, 664]}, {"655":[624, 625]}, {"656":[262, 270]}, {"657":[145, 231]}, {"658":[251, 256]}, {"659":[234, 235]}, {"660":[252, 257]}, {"661":[541, 542]}, {"662":[621, 622]}, {"663":[552, 557]}, {"664":[379, 416]}, {"665":[273, 278]}, {"666":[165, 169]}, {"667":[487, 529]}, {"668":[139, 242]}, {"669":[580, 581]}, {"670":[611, 615]}, {"671":[575, 579]}, {"672":[340, 367]}, {"673":[257, 258]}, {"674":[146, 200]}, {"675":[57, 458]}, {"676":[180, 249]}, {"677":[23, 38]}, {"678":[314, 351]}, {"679":[190, 191]}, {"680":[142, 168]}, {"681":[69, 658]}, {"682":[352, 389]}, {"683":[357, 399]}, {"684":[338, 339]}, {"685":[531, 533]}, {"686":[100, 109]}, {"687":[157, 216]}, {"688":[246, 266]}, {"689":[476, 527]}, {"690":[71, 469]}, {"691":[481, 558]}, {"692":[479, 510]}, {"693":[333, 404]}, {"694":[515, 545]}, {"695":[246, 247]}, {"696":[301, 376]}, {"697":[253, 254]}, {"698":[503, 504]}, {"699":[395, 417]}, {"700":[248, 254]}, {"701":[366, 403]}, {"702":[87, 633]}, {"703":[219, 220]}, {"704":[337, 338]}, {"705":[396, 407]}, {"706":[34, 35]}, {"707":[551, 560]}, {"708":[42, 130]}, {"709":[628, 629]}, {"710":[308, 358]}, {"711":[547, 599]}, {"712":[399, 433]}, {"713":[491, 578]}, {"714":[534, 576]}, {"715":[74, 124]}, {"716":[302, 336]}, {"717":[290, 646]}, {"718":[58, 82]}, {"719":[623, 624]}, {"720":[414, 426]}, {"721":[282, 458]}, {"722":[346, 347]}, {"723":[416, 431]}, {"724":[574, 575]}, {"725":[43, 118]}, {"726":[285, 460]}, {"727":[316, 351]}, {"728":[271, 272]}, {"729":[112, 445]}, {"730":[85, 204]}, {"731":[544, 558]}, {"732":[569, 669]}, {"733":[12, 13]}, {"734":[179, 180]}, {"735":[100, 125]}, {"736":[499, 603]}, {"737":[589, 598]}, {"738":[95, 97]}, {"739":[276, 277]}, {"740":[6, 15]}, {"741":[198, 229]}, {"742":[297, 335]}, {"743":[505, 569]}, {"744":[590, 595]}, {"745":[603, 608]}, {"746":[618, 619]}, {"747":[344, 428]}, {"748":[671, 672]}, {"749":[549, 550]}, {"750":[297, 332]}, {"751":[337, 405]}, {"752":[543, 544]}, {"753":[297, 334]}, {"754":[97, 449]}, {"755":[239, 263]}, {"756":[665, 666]}, {"757":[521, 522]}, {"758":[513, 514]}, {"759":[94, 461]}, {"760":[596, 617]}, {"761":[224, 225]}, {"762":[511, 539]}, {"763":[318, 436]}, {"764":[197, 198]}, {"765":[670, 673]}, {"766":[609, 610]}, {"767":[45, 606]}, {"768":[519, 563]}, {"769":[320, 423]}, {"770":[315, 382]}, {"771":[400, 401]}, {"772":[528, 529]}, {"773":[494, 565]}, {"774":[119, 446]}, {"775":[258, 265]}, {"776":[321, 436]}], "nodes":[{"1":{"val":"T1", "x": -54, "y": -23}}, {"2":{"val":"T2", "x":1, "y": -97}}, {"3":{"val":"T3", "x":56, "y": -24}}, {"4":{"val":"T4", "x":1, "y":42}}, {"5":{"val":"T5", "x":1, "y":139}}, {"6":{"val":"A0", "x":1, "y":250}}, {"7":{"val":"A3", "x": -76, "y":150}}, {"8":{"val":"T8", "x": -147, "y":56}}, {"9":{"val":"A5", "x": -147, "y": -43}}, {"10":{"val":"S3", "x": -75, "y": -138}}, {"11":{"val":"T7", "x":2, "y": -237}}, {"12":{"val":"S2", "x":79, "y": -138}}, {"13":{"val":"A4", "x":150, "y": -43}}, {"14":{"val":"T6", "x":150, "y":55}}, {"15":{"val":"A2", "x":79, "y":150}}, {"16":{"val":"Az", "x": -174, "y": -188}}, {"17":{"val":"Ax", "x": -358, "y":2}}, {"18":{"val":"Ay", "x": -358, "y": -119}}, {"19":{"val":"Ay", "x": -358, "y":118}}, {"20":{"val":"Az", "x":175, "y": -187}}, {"21":{"val":"Aw", "x":361, "y":0}}, {"22":{"val":"Ay", "x":361, "y": -120}}, {"23":{"val":"Ay", "x":361, "y":120}}, {"24":{"val":"Gp", "x": -2065, "y":18}}, {"25":{"val":"Au", "x": -265, "y": -233}}, {"26":{"val":"S8", "x": -179, "y": -336}}, {"27":{"val":"S4", "x": -88, "y": -448}}, {"28":{"val":"A8", "x": -259, "y":238}}, {"29":{"val":"S6", "x":89, "y": -448}}, {"30":{"val":"S9", "x":181, "y": -336}}, {"31":{"val":"A6", "x":265, "y": -233}}, {"32":{"val":"A7", "x":2, "y": -555}}, {"33":{"val":"Sg", "x": -178, "y":338}}, {"34":{"val":"S5", "x": -88, "y":446}}, {"35":{"val":"S1", "x":1, "y":557}}, {"36":{"val":"S7", "x":92, "y":446}}, {"37":{"val":"Sf", "x":180, "y":339}}, {"38":{"val":"Av", "x":262, "y":238}}, {"39":{"val":"Az", "x": -168, "y":193}}, {"40":{"val":"Az", "x":171, "y":192}}, {"41":{"val":"Ir", "x": -731, "y":99}}, {"42":{"val":"I2", "x":247, "y": -1673}}, {"43":{"val":"Gc", "x":126, "y": -1055}}, {"44":{"val":"Cc", "x": -57, "y": -1043}}, {"45":{"val":"Gp", "x": -246, "y": -1053}}, {"46":{"val":"Bd", "x": -283, "y": -436}}, {"47":{"val":"qMr", "x": -397, "y": -548}}, {"48":{"val":"Cc", "x":285, "y": -440}}, {"49":{"val":"qCd", "x":387, "y": -551}}, {"50":{"val":"Hd", "x": -274, "y":441}}, {"51":{"val":"qG", "x": -373, "y":547}}, {"52":{"val":"Mu", "x":267, "y":438}}, {"53":{"val":"qH", "x":360, "y":546}}, {"54":{"val":"Gc", "x":25, "y": -2172}}, {"55":{"val":"Gp", "x":167, "y": -2139}}, {"56":{"val":"Mr", "x":143, "y": -2011}}, {"57":{"val":"Bd", "x":289, "y": -1380}}, {"58":{"val":"Rh", "x":2025, "y": -745}}, {"59":{"val":"Bc", "x":242, "y": -1523}}, {"60":{"val":"I7", "x":1265, "y": -13}}, {"61":{"val":"Cc", "x":396, "y": -1909}}, {"62":{"val":"I3", "x":524, "y": -2009}}, {"63":{"val":"Gc", "x": -2086, "y":145}}, {"64":{"val":"Bg", "x":1216, "y": -1733}}, {"65":{"val":"Cl", "x":1370, "y": -1750}}, {"66":{"val":"Tg", "x":1938, "y": -1443}}, {"67":{"val":"Gc", "x":1527, "y": -1757}}, {"68":{"val":"H", "x":1386, "y":51}}, {"69":{"val":"Gb", "x":1747, "y": -1673}}, {"70":{"val":"G", "x":1840, "y": -1543}}, {"71":{"val":"Bc", "x":1764, "y": -905}}, {"72":{"val":"Mu", "x":2032, "y": -465}}, {"73":{"val":"Mu", "x":1355, "y": -115}}, {"74":{"val":"Mu", "x":564, "y": -529}}, {"75":{"val":"H", "x":647, "y": -400}}, {"76":{"val":"I8", "x":917, "y": -332}}, {"77":{"val":"Gp", "x": -691, "y": -52}}, {"78":{"val":"I4", "x":1686, "y": -339}}, {"79":{"val":"Pa", "x":617, "y": -767}}, {"80":{"val":"Cc", "x":762, "y": -812}}, {"81":{"val":"Pt", "x":794, "y": -952}}, {"82":{"val":"Hd", "x":2056, "y": -606}}, {"83":{"val":"H", "x":2062, "y": -97}}, {"84":{"val":"Bd", "x":1930, "y": -147}}, {"85":{"val":"Bd", "x": -222, "y":1135}}, {"86":{"val":"Kh", "x": -127, "y":1028}}, {"87":{"val":"Cd", "x":1816, "y": -389}}, {"88":{"val":"Md", "x":1894, "y": -497}}, {"89":{"val":"Mt", "x":252, "y": -1927}}, {"90":{"val":"G", "x":635, "y": -2109}}, {"91":{"val":"I4", "x":953, "y": -1914}}, {"92":{"val":"Cl", "x":759, "y": -2026}}, {"93":{"val":"Gp", "x":906, "y": -2037}}, {"94":{"val":"Md", "x":2021, "y": -1186}}, {"95":{"val":"I8", "x":1947, "y": -1065}}, {"96":{"val":"Cd", "x":1886, "y": -824}}, {"97":{"val":"Kh", "x":1810, "y": -1123}}, {"98":{"val":"Md", "x":1979, "y": -928}}, {"99":{"val":"Md", "x":835, "y": -649}}, {"100":{"val":"Pa", "x":1450, "y": -325}}, {"101":{"val":"Cc", "x":859, "y": -461}}, {"102":{"val":"Hd", "x":971, "y": -645}}, {"103":{"val":"Kh", "x":1163, "y": -94}}, {"104":{"val":"Bc", "x":2103, "y": -224}}, {"105":{"val":"I3", "x":749, "y": -1096}}, {"106":{"val":"G", "x":1088, "y": -577}}, {"107":{"val":"Ra", "x":1089, "y": -723}}, {"108":{"val":"Cd", "x":913, "y": -1043}}, {"109":{"val":"Ir", "x":1490, "y": -192}}, {"110":{"val":"Md", "x":571, "y": -1884}}, {"111":{"val":"Ph", "x":1202, "y": -799}}, {"112":{"val":"Cd", "x":518, "y": -1752}}, {"113":{"val":"Tc", "x":1208, "y": -1869}}, {"114":{"val":"Bc", "x":775, "y": -320}}, {"115":{"val":"Mr", "x":402, "y": -782}}, {"116":{"val":"Eh", "x":265, "y": -1219}}, {"117":{"val":"Ea", "x":335, "y": -921}}, {"118":{"val":"I1", "x":289, "y": -1070}}, {"119":{"val":"G", "x":697, "y": -1295}}, {"120":{"val":"Cc", "x":833, "y": -1206}}, {"121":{"val":"Ir", "x":1093, "y": -1963}}, {"122":{"val":"Cd", "x":568, "y": -1226}}, {"123":{"val":"Ph", "x":439, "y": -1126}}, {"124":{"val":"Md", "x":494, "y": -663}}, {"125":{"val":"Md", "x":1320, "y": -246}}, {"126":{"val":"Mu", "x":1705, "y":6}}, {"127":{"val":"Hd", "x": -3, "y":1105}}, {"128":{"val":"I5", "x":1841, "y": -45}}, {"129":{"val":"Gc", "x": -749, "y":262}}, {"130":{"val":"En", "x":201, "y": -1803}}, {"131":{"val":"qMt", "x": -2211, "y":812}}, {"132":{"val":"qEn", "x": -1746, "y":350}}, {"133":{"val":"qGp", "x": -2210, "y":1170}}, {"134":{"val":"qIr", "x": -2112, "y":1244}}, {"135":{"val":"qGc", "x": -2124, "y":1153}}, {"136":{"val":"Q43", "x": -2010, "y":981}}, {"137":{"val":"qHd", "x": -1545, "y":1352}}, {"138":{"val":"qIr", "x": -1392, "y":1473}}, {"139":{"val":"qBd", "x": -92, "y":2572}}, {"140":{"val":"qG", "x": -1612, "y":1604}}, {"141":{"val":"qG", "x": -1464, "y":1165}}, {"142":{"val":"Q44", "x": -1361, "y":660}}, {"143":{"val":"qGp", "x": -573, "y":333}}, {"144":{"val":"qH", "x": -88, "y":2282}}, {"145":{"val":"qMu", "x": -219, "y":1748}}, {"146":{"val":"qBg", "x": -893, "y":1031}}, {"147":{"val":"qHd", "x": -542, "y":1698}}, {"148":{"val":"Q42", "x": -594, "y":1407}}, {"149":{"val":"qGb", "x": -695, "y":1361}}, {"150":{"val":"qTc", "x": -676, "y":1466}}, {"151":{"val":"Q41", "x": -2044, "y":1863}}, {"152":{"val":"qHd", "x": -2044, "y":2154}}, {"153":{"val":"qBd", "x": -352, "y":2227}}, {"154":{"val":"Q45", "x": -798, "y":2128}}, {"155":{"val":"qTg", "x": -589, "y":2021}}, {"156":{"val":"qG", "x": -1333, "y":2307}}, {"157":{"val":"qHd", "x": -611, "y":2463}}, {"158":{"val":"qGb", "x": -1442, "y":1994}}, {"159":{"val":"qH", "x": -404, "y":1017}}, {"160":{"val":"qMr", "x": -1970, "y":576}}, {"161":{"val":"I6", "x": -2105, "y":513}}, {"162":{"val":"Gc", "x": -2239, "y":558}}, {"163":{"val":"Gp", "x": -2295, "y":694}}, {"164":{"val":"G", "x": -1928, "y":771}}, {"165":{"val":"Mt", "x": -1670, "y":627}}, {"166":{"val":"Mr", "x": -1644, "y":475}}, {"167":{"val":"Ea", "x": -1555, "y":332}}, {"168":{"val":"Kh", "x": -1238, "y":525}}, {"169":{"val":"En", "x": -1824, "y":650}}, {"170":{"val":"Eh", "x": -1368, "y":390}}, {"171":{"val":"Gp", "x": -1441, "y":798}}, {"172":{"val":"Gc", "x": -1574, "y":894}}, {"173":{"val":"G", "x": -1711, "y":976}}, {"174":{"val":"Cd", "x": -1501, "y":1027}}, {"175":{"val":"Cl", "x": -1152, "y":1109}}, {"176":{"val":"Rh", "x": -1778, "y":1419}}, {"177":{"val":"I3", "x": -1703, "y":1279}}, {"178":{"val":"Ra", "x": -1674, "y":1119}}, {"179":{"val":"G", "x": -1600, "y":2015}}, {"180":{"val":"Mr", "x": -1653, "y":1869}}, {"181":{"val":"I5", "x": -1305, "y":1135}}, {"182":{"val":"Ph", "x": -1862, "y":2150}}, {"183":{"val":"Hd", "x": -538, "y":1071}}, {"184":{"val":"Cd", "x": -1221, "y":742}}, {"185":{"val":"Hd", "x":43, "y":2287}}, {"186":{"val":"G", "x": -2082, "y":872}}, {"187":{"val":"Bd", "x": -1088, "y":428}}, {"188":{"val":"Bc", "x": -904, "y":393}}, {"189":{"val":"Cc", "x": -1067, "y":662}}, {"190":{"val":"Gp", "x": -892, "y":701}}, {"191":{"val":"Gc", "x": -821, "y":550}}, {"192":{"val":"I8", "x": -721, "y":414}}, {"193":{"val":"Gb", "x": -605, "y":545}}, {"194":{"val":"Ir", "x": -487, "y":668}}, {"195":{"val":"I2", "x": -2316, "y":915}}, {"196":{"val":"Hd", "x": -2318, "y":1070}}, {"197":{"val":"Hd", "x": -1849, "y":246}}, {"198":{"val":"Ra", "x": -2005, "y":245}}, {"199":{"val":"Tg", "x": -729, "y":887}}, {"200":{"val":"Ir", "x": -896, "y":869}}, {"201":{"val":"Tc", "x": -635, "y":748}}, {"202":{"val":"G", "x": -1007, "y":1129}}, {"203":{"val":"Md", "x": -2241, "y":1958}}, {"204":{"val":"Ea", "x": -360, "y":1165}}, {"205":{"val":"Eh", "x": -306, "y":1317}}, {"206":{"val":"Pa", "x": -2182, "y":2083}}, {"207":{"val":"I1", "x": -450, "y":1374}}, {"208":{"val":"Bg", "x": -518, "y":1250}}, {"209":{"val":"G", "x": -643, "y":1170}}, {"210":{"val":"Gb", "x": -746, "y":1069}}, {"211":{"val":"Hd", "x": -1253, "y":1268}}, {"212":{"val":"G", "x": -1262, "y":1408}}, {"213":{"val":"I7", "x": -1683, "y":2162}}, {"214":{"val":"Ea", "x": -1325, "y":1599}}, {"215":{"val":"G", "x": -940, "y":2100}}, {"216":{"val":"Pa", "x": -456, "y":2525}}, {"217":{"val":"Pt", "x": -1503, "y":2220}}, {"218":{"val":"Cc", "x": -1154, "y":2308}}, {"219":{"val":"Cd", "x": -972, "y":2364}}, {"220":{"val":"Md", "x": -794, "y":2400}}, {"221":{"val":"Bd", "x": -974, "y":2233}}, {"222":{"val":"I2", "x": -836, "y":1336}}, {"223":{"val":"Tg", "x": -853, "y":1463}}, {"224":{"val":"Ir", "x": -871, "y":1592}}, {"225":{"val":"Gb", "x": -716, "y":1591}}, {"226":{"val":"Gp", "x": -430, "y":1621}}, {"227":{"val":"Mu", "x": -213, "y":1465}}, {"228":{"val":"G", "x": -398, "y":1498}}, {"229":{"val":"Rh", "x": -2097, "y":368}}, {"230":{"val":"H", "x": -198, "y":1611}}, {"231":{"val":"I3", "x": -144, "y":1877}}, {"232":{"val":"Bd", "x": -82, "y":2008}}, {"233":{"val":"Ea", "x": -271, "y":1908}}, {"234":{"val":"Gb", "x": -425, "y":1942}}, {"235":{"val":"Bg", "x": -435, "y":2072}}, {"236":{"val":"Bg", "x": -839, "y":1729}}, {"237":{"val":"Gc", "x": -367, "y":1738}}, {"238":{"val":"Bc", "x": -68, "y":2145}}, {"239":{"val":"Ra", "x": -824, "y":1871}}, {"240":{"val":"Ph", "x": -492, "y":2278}}, {"241":{"val":"Mu", "x":129, "y":2425}}, {"242":{"val":"H", "x":1, "y":2453}}, {"243":{"val":"Pt", "x": -382, "y":2383}}, {"244":{"val":"Cl", "x": -180, "y":2451}}, {"245":{"val":"I5", "x": -313, "y":2509}}, {"246":{"val":"Tg", "x": -1827, "y":1124}}, {"247":{"val":"Tc", "x": -1982, "y":1137}}, {"248":{"val":"Gc", "x": -2265, "y":1563}}, {"249":{"val":"En", "x": -1713, "y":1730}}, {"250":{"val":"Gp", "x": -2276, "y":1715}}, {"251":{"val":"Ra", "x": -1123, "y":1365}}, {"252":{"val":"Mt", "x": -1825, "y":1616}}, {"253":{"val":"G", "x": -2019, "y":1377}}, {"254":{"val":"I1", "x": -2179, "y":1447}}, {"255":{"val":"Cd", "x": -2246, "y":1323}}, {"256":{"val":"Rh", "x": -976, "y":1346}}, {"257":{"val":"Hd", "x": -1925, "y":1501}}, {"258":{"val":"Cd", "x": -2039, "y":1584}}, {"259":{"val":"I8", "x": -2193, "y":1833}}, {"260":{"val":"H", "x": -381, "y":816}}, {"261":{"val":"Kh", "x": -532, "y":896}}, {"262":{"val":"Ir", "x": -611, "y":1879}}, {"263":{"val":"Rh", "x": -736, "y":1977}}, {"264":{"val":"Cl", "x": -1802, "y":838}}, {"265":{"val":"Cc", "x": -2021, "y":1727}}, {"266":{"val":"I4", "x": -1862, "y":966}}, {"267":{"val":"Eh", "x": -210, "y":2023}}, {"268":{"val":"Hd", "x": -1902, "y":1913}}, {"269":{"val":"Cl", "x": -1756, "y":1970}}, {"270":{"val":"I4", "x": -481, "y":1825}}, {"271":{"val":"Gp", "x": -1293, "y":2037}}, {"272":{"val":"Gc", "x": -1198, "y":2164}}, {"273":{"val":"Cd", "x": -943, "y":1960}}, {"274":{"val":"H", "x": -304, "y":2104}}, {"275":{"val":"Eh", "x": -1494, "y":1691}}, {"276":{"val":"Kh", "x": -1340, "y":1746}}, {"277":{"val":"I6", "x": -1276, "y":1891}}, {"278":{"val":"Hd", "x": -1111, "y":1930}}, {"279":{"val":"Gb", "x": -2150, "y":1002}}, {"280":{"val":"Tc", "x": -894, "y":1214}}, {"281":{"val":"Md", "x":893, "y": -1785}}, {"282":{"val":"Cl", "x":512, "y": -1451}}, {"283":{"val":"Cc", "x":379, "y": -1541}}, {"284":{"val":"Cl", "x":1139, "y": -1528}}, {"285":{"val":"Cd", "x":1024, "y": -1624}}, {"286":{"val":"Md", "x":958, "y": -1303}}, {"287":{"val":"I5", "x":987, "y": -1495}}, {"288":{"val":"Pt", "x":1217, "y": -1416}}, {"289":{"val":"Cc", "x":1266, "y": -1291}}, {"290":{"val":"I2", "x":1370, "y": -962}}, {"291":{"val":"qBg", "x":142, "y":2159}}, {"292":{"val":"qTg", "x":459, "y":2317}}, {"293":{"val":"qGp", "x":503, "y":1401}}, {"294":{"val":"qH", "x":830, "y":1553}}, {"295":{"val":"qBg", "x":2, "y":1328}}, {"296":{"val":"qBd", "x":1199, "y":1907}}, {"297":{"val":"qCd", "x":1204, "y":378}}, {"298":{"val":"Q84", "x":771, "y":1822}}, {"299":{"val":"qH", "x":1028, "y":2071}}, {"300":{"val":"qH", "x":1350, "y":1214}}, {"301":{"val":"qBd", "x":1640, "y":1482}}, {"302":{"val":"qH", "x":808, "y":695}}, {"303":{"val":"qCl", "x":1847, "y":1905}}, {"304":{"val":"Q83", "x":2336, "y":458}}, {"305":{"val":"qG", "x":786, "y":2640}}, {"306":{"val":"Q85", "x":936, "y":2964}}, {"307":{"val":"Q87", "x":1546, "y":2281}}, {"308":{"val":"qHd", "x":1719, "y":2633}}, {"309":{"val":"Q88", "x":932, "y":1655}}, {"310":{"val":"qBd", "x":1769, "y":3111}}, {"311":{"val":"Q86", "x":2714, "y":1925}}, {"312":{"val":"qMu", "x":1206, "y":1376}}, {"313":{"val":"Q81", "x":1203, "y":1142}}, {"314":{"val":"Q82", "x":1199, "y":879}}, {"315":{"val":"qH", "x":2028, "y":1394}}, {"316":{"val":"Mu", "x":1375, "y":704}}, {"317":{"val":"Bc", "x":2360, "y":1898}}, {"318":{"val":"Kh", "x":2496, "y":2051}}, {"319":{"val":"I8", "x":2553, "y":1920}}, {"320":{"val":"Pa", "x":2418, "y":1661}}, {"321":{"val":"H", "x":2300, "y":2295}}, {"322":{"val":"Gp", "x":925, "y":2694}}, {"323":{"val":"Bc", "x":2160, "y":1516}}, {"324":{"val":"Bd", "x":1627, "y":572}}, {"325":{"val":"Ph", "x":2171, "y":1176}}, {"326":{"val":"qCd", "x":2197, "y":877}}, {"327":{"val":"I2", "x":2445, "y":712}}, {"328":{"val":"Cc", "x":2439, "y":556}}, {"329":{"val":"Cd", "x":2247, "y":690}}, {"330":{"val":"Cl", "x":2092, "y":644}}, {"331":{"val":"I3", "x":1922, "y":656}}, {"332":{"val":"Hd", "x":1382, "y":357}}, {"333":{"val":"G", "x":1919, "y":792}}, {"334":{"val":"H", "x":1305, "y":496}}, {"335":{"val":"Mt", "x":1080, "y":493}}, {"336":{"val":"Mr", "x":950, "y":596}}, {"337":{"val":"H", "x":428, "y":831}}, {"338":{"val":"qG", "x":426, "y":995}}, {"339":{"val":"Mu", "x":344, "y":1115}}, {"340":{"val":"H", "x":93, "y":1219}}, {"341":{"val":"Cl", "x":711, "y":814}}, {"342":{"val":"I7", "x":237, "y":1503}}, {"343":{"val":"H", "x":340, "y":1385}}, {"344":{"val":"Kh", "x":220, "y":1877}}, {"345":{"val":"Mu", "x":249, "y":2025}}, {"346":{"val":"I5", "x":289, "y":2175}}, {"347":{"val":"Gp", "x":433, "y":2175}}, {"348":{"val":"G", "x":577, "y":2415}}, {"349":{"val":"Cc", "x":716, "y":2499}}, {"350":{"val":"Bd", "x":612, "y":2651}}, {"351":{"val":"I1", "x":1213, "y":724}}, {"352":{"val":"I5", "x":1074, "y":1723}}, {"353":{"val":"I3", "x":1049, "y":2786}}, {"354":{"val":"Hd", "x":1230, "y":2975}}, {"355":{"val":"H", "x":1364, "y":2704}}, {"356":{"val":"Bd", "x":1412, "y":3009}}, {"357":{"val":"I2", "x":1536, "y":2667}}, {"358":{"val":"H", "x":1890, "y":2581}}, {"359":{"val":"Kh", "x":1771, "y":2755}}, {"360":{"val":"G", "x":1584, "y":3054}}, {"361":{"val":"Bd", "x":2033, "y":2623}}, {"362":{"val":"Hd", "x":1670, "y":2839}}, {"363":{"val":"G", "x":1732, "y":2957}}, {"364":{"val":"Mu", "x":1898, "y":2039}}, {"365":{"val":"H", "x":1883, "y":1121}}, {"366":{"val":"Kh", "x":587, "y":544}}, {"367":{"val":"Bd", "x":196, "y":1111}}, {"368":{"val":"Hd", "x":410, "y":1247}}, {"369":{"val":"Cl", "x":763, "y":2350}}, {"370":{"val":"Cd", "x":850, "y":2235}}, {"371":{"val":"I1", "x":2136, "y":2258}}, {"372":{"val":"Bd", "x":1021, "y":328}}, {"373":{"val":"I7", "x":1907, "y":979}}, {"374":{"val":"H", "x":1684, "y":1839}}, {"375":{"val":"Bd", "x":1776, "y":1719}}, {"376":{"val":"Bc", "x":1762, "y":1565}}, {"377":{"val":"Cl", "x":650, "y":1341}}, {"378":{"val":"I8", "x":930, "y":1021}}, {"379":{"val":"Mu", "x":829, "y":1411}}, {"380":{"val":"Kh", "x":1467, "y":961}}, {"381":{"val":"H", "x":1067, "y":1098}}, {"382":{"val":"Mu", "x":1938, "y":1255}}, {"383":{"val":"Hd", "x":1790, "y":1295}}, {"384":{"val":"H", "x":1646, "y":1335}}, {"385":{"val":"Mu", "x":1553, "y":1214}}, {"386":{"val":"I4", "x":1457, "y":1109}}, {"387":{"val":"Cc", "x":1508, "y":1566}}, {"388":{"val":"Cl", "x":1372, "y":1662}}, {"389":{"val":"H", "x":1201, "y":1638}}, {"390":{"val":"H", "x":1378, "y":846}}, {"391":{"val":"Mu", "x":1298, "y":1513}}, {"392":{"val":"Gb", "x":972, "y":2364}}, {"393":{"val":"Tg", "x":509, "y":1907}}, {"394":{"val":"I6", "x":638, "y":1868}}, {"395":{"val":"Mu", "x":603, "y":1736}}, {"396":{"val":"G", "x":1516, "y":1807}}, {"397":{"val":"Ir", "x":1207, "y":2761}}, {"398":{"val":"Ea", "x":2304, "y":1570}}, {"399":{"val":"Tc", "x":1591, "y":2529}}, {"400":{"val":"Mu", "x":1487, "y":2106}}, {"401":{"val":"H", "x":1499, "y":1952}}, {"402":{"val":"G", "x":671, "y":1998}}, {"403":{"val":"H", "x":766, "y":549}}, {"404":{"val":"H", "x":2019, "y":906}}, {"405":{"val":"Ea", "x":576, "y":892}}, {"406":{"val":"H", "x":804, "y":927}}, {"407":{"val":"I6", "x":1337, "y":1816}}, {"408":{"val":"qH", "x":2300, "y":2437}}, {"409":{"val":"Mu", "x":857, "y":402}}, {"410":{"val":"Md", "x":1552, "y":425}}, {"411":{"val":"Bc", "x":454, "y":654}}, {"412":{"val":"Bg", "x":1695, "y":2226}}, {"413":{"val":"Mt", "x":2177, "y":1872}}, {"414":{"val":"Gb", "x":1837, "y":2169}}, {"415":{"val":"I4", "x":1010, "y":2219}}, {"416":{"val":"H", "x":781, "y":1271}}, {"417":{"val":"H", "x":459, "y":1712}}, {"418":{"val":"Cl", "x":280, "y":1637}}, {"419":{"val":"Tc", "x":410, "y":2018}}, {"420":{"val":"H", "x":1998, "y":1810}}, {"421":{"val":"Mu", "x":2067, "y":1656}}, {"422":{"val":"Gc", "x":1173, "y":2216}}, {"423":{"val":"Cc", "x":2499, "y":1784}}, {"424":{"val":"Gp", "x":1341, "y":2186}}, {"425":{"val":"Bc", "x":2171, "y":2554}}, {"426":{"val":"H", "x":1984, "y":2213}}, {"427":{"val":"G", "x":1083, "y":2925}}, {"428":{"val":"qIr", "x":324, "y":1774}}, {"429":{"val":"H", "x":740, "y":2124}}, {"430":{"val":"Gc", "x":116, "y":1418}}, {"431":{"val":"Kh", "x":859, "y":1149}}, {"432":{"val":"G", "x":896, "y":2519}}, {"433":{"val":"Tg", "x":1516, "y":2420}}, {"434":{"val":"Bc", "x":1459, "y":568}}, {"435":{"val":"Hd", "x":510, "y":2555}}, {"436":{"val":"Mu", "x":2399, "y":2181}}, {"437":{"val":"Md", "x":2339, "y":811}}, {"438":{"val":"Cd", "x":2197, "y":1352}}, {"439":{"val":"Pt", "x":2125, "y":1033}}, {"440":{"val":"qMd", "x":1759, "y":671}}, {"441":{"val":"qH", "x":744, "y": -548}}, {"442":{"val":"qBd", "x":738, "y": -1889}}, {"443":{"val":"Q63", "x":401, "y": -1683}}, {"444":{"val":"Q64", "x":870, "y": -1429}}, {"445":{"val":"qBd", "x":644, "y": -1656}}, {"446":{"val":"qMd", "x":649, "y": -1428}}, {"447":{"val":"qCd", "x":987, "y": -1156}}, {"448":{"val":"qCd", "x":1367, "y": -433}}, {"449":{"val":"qCd", "x":1719, "y": -1241}}, {"450":{"val":"qCl", "x":990, "y": -926}}, {"451":{"val":"qCd", "x":1222, "y": -926}}, {"452":{"val":"Q61", "x":1596, "y": -434}}, {"453":{"val":"qCd", "x":871, "y": -1651}}, {"454":{"val":"qMd", "x":1220, "y": -1153}}, {"455":{"val":"Q66", "x":1366, "y": -656}}, {"456":{"val":"qMd", "x":1595, "y": -657}}, {"457":{"val":"qEn", "x":358, "y": -2050}}, {"458":{"val":"qMr", "x":441, "y": -1333}}, {"459":{"val":"qHd", "x":562, "y": -288}}, {"460":{"val":"qGb", "x":1062, "y": -1744}}, {"461":{"val":"qIr", "x":2037, "y": -1328}}, {"462":{"val":"Q62", "x":920, "y": -796}}, {"463":{"val":"Q65", "x":1404, "y": -1154}}, {"464":{"val":"qMu", "x":1520, "y":24}}, {"465":{"val":"qH", "x":2003, "y": -326}}, {"466":{"val":"qMt", "x":489, "y": -944}}, {"467":{"val":"qG", "x":1481, "y": -1565}}, {"468":{"val":"qBd", "x":1160, "y": -469}}, {"469":{"val":"qCl", "x":1629, "y": -849}}, {"470":{"val":"qBd", "x":1766, "y": -153}}, {"471":{"val":"Q27", "x": -2042, "y": -914}}, {"472":{"val":"Q26", "x": -1699, "y": -571}}, {"473":{"val":"Q30", "x": -1439, "y": -1476}}, {"474":{"val":"qMt", "x": -1120, "y": -1148}}, {"475":{"val":"Q24", "x": -857, "y": -698}}, {"476":{"val":"qBd", "x": -1932, "y": -1750}}, {"477":{"val":"qCd", "x": -342, "y": -2262}}, {"478":{"val":"qGc", "x": -2033, "y": -592}}, {"479":{"val":"qIr", "x": -1690, "y": -249}}, {"480":{"val":"qMt", "x": -1874, "y": -747}}, {"481":{"val":"qMr", "x": -1111, "y": -826}}, {"482":{"val":"qTg", "x": -848, "y": -376}}, {"483":{"val":"Q25", "x": -1922, "y": -1428}}, {"484":{"val":"Q28", "x": -333, "y": -1940}}, {"485":{"val":"Q23", "x": -2022, "y": -365}}, {"486":{"val":"qBg", "x": -1679, "y": -23}}, {"487":{"val":"qGp", "x": -1910, "y": -473}}, {"488":{"val":"Q21", "x": -1100, "y": -599}}, {"489":{"val":"qG", "x": -837, "y": -149}}, {"490":{"val":"qGp", "x": -1912, "y": -1201}}, {"491":{"val":"qMd", "x": -322, "y": -1713}}, {"492":{"val":"qGc", "x": -1565, "y": -1545}}, {"493":{"val":"qEn", "x": -1637, "y": -1291}}, {"494":{"val":"Q29", "x": -1801, "y": -1138}}, {"495":{"val":"qBd", "x": -462, "y": -1896}}, {"496":{"val":"qCl", "x": -419, "y": -1683}}, {"497":{"val":"qBd", "x": -582, "y": -930}}, {"498":{"val":"qEn", "x": -1054, "y": -2030}}, {"499":{"val":"Q22", "x": -602, "y": -1479}}, {"500":{"val":"qCd", "x": -592, "y": -1157}}, {"501":{"val":"Cd", "x": -2202, "y": -493}}, {"502":{"val":"I6", "x": -2156, "y": -613}}, {"503":{"val":"Mu", "x": -2212, "y": -731}}, {"504":{"val":"Kh", "x": -2218, "y": -861}}, {"505":{"val":"I3", "x": -1518, "y": -60}}, {"506":{"val":"Mr", "x": -1532, "y": -187}}, {"507":{"val":"Rh", "x": -1412, "y": -327}}, {"508":{"val":"Ra", "x": -1303, "y": -429}}, {"509":{"val":"Hd", "x": -1819, "y": -1311}}, {"510":{"val":"Md", "x": -1566, "y": -315}}, {"511":{"val":"Bg", "x": -1154, "y": -111}}, {"512":{"val":"En", "x": -1546, "y": -437}}, {"513":{"val":"Mt", "x": -1528, "y": -567}}, {"514":{"val":"I5", "x": -1593, "y": -676}}, {"515":{"val":"Gp", "x": -1822, "y": -208}}, {"516":{"val":"Eh", "x": -1830, "y": -331}}, {"517":{"val":"G", "x": -1740, "y": -786}}, {"518":{"val":"Gc", "x": -1616, "y": -846}}, {"519":{"val":"Pt", "x": -1904, "y": -899}}, {"520":{"val":"I8", "x": -2170, "y": -989}}, {"521":{"val":"Cc", "x": -2186, "y": -365}}, {"522":{"val":"I4", "x": -2106, "y": -255}}, {"523":{"val":"Pt", "x": -2174, "y": -1115}}, {"524":{"val":"Ph", "x": -2128, "y": -1245}}, {"525":{"val":"Pa", "x": -2060, "y": -1365}}, {"526":{"val":"G", "x": -2089, "y": -1512}}, {"527":{"val":"Cd", "x": -1780, "y": -1787}}, {"528":{"val":"Cd", "x": -1773, "y": -657}}, {"529":{"val":"Cc", "x": -1889, "y": -599}}, {"530":{"val":"H", "x": -1528, "y": -1680}}, {"531":{"val":"Mu", "x": -1819, "y": -1526}}, {"532":{"val":"Md", "x": -1588, "y": -1415}}, {"533":{"val":"I1", "x": -1733, "y": -1416}}, {"534":{"val":"Mr", "x": -445, "y": -1523}}, {"535":{"val":"Ir", "x": -1626, "y": -1799}}, {"536":{"val":"I2", "x": -1153, "y": -453}}, {"537":{"val":"Gc", "x": -1374, "y": -575}}, {"538":{"val":"G", "x": -1068, "y": -323}}, {"539":{"val":"Gb", "x": -1002, "y": -180}}, {"540":{"val":"Gp", "x": -969, "y": -471}}, {"541":{"val":"Tc", "x": -715, "y": -222}}, {"542":{"val":"Tg", "x": -643, "y": -347}}, {"543":{"val":"Gp", "x": -1243, "y": -644}}, {"544":{"val":"Cc", "x": -1324, "y": -765}}, {"545":{"val":"Gc", "x": -1947, "y": -241}}, {"546":{"val":"I8", "x": -774, "y": -820}}, {"547":{"val":"Bd", "x": -2008, "y": -711}}, {"548":{"val":"Eh", "x": -1386, "y": -1055}}, {"549":{"val":"Cl", "x": -827, "y": -952}}, {"550":{"val":"Ea", "x": -975, "y": -889}}, {"551":{"val":"Kh", "x": -1226, "y": -1255}}, {"552":{"val":"Mu", "x": -1492, "y": -782}}, {"553":{"val":"Rh", "x": -1904, "y": -1026}}, {"554":{"val":"Ra", "x": -2005, "y": -1104}}, {"555":{"val":"Ea", "x": -1525, "y": -1092}}, {"556":{"val":"Mr", "x": -1509, "y": -1226}}, {"557":{"val":"En", "x": -1416, "y": -909}}, {"558":{"val":"Cd", "x": -1257, "y": -880}}, {"559":{"val":"Gc", "x": -1316, "y": -1350}}, {"560":{"val":"I2", "x": -1364, "y": -1190}}, {"561":{"val":"Bd", "x": -1164, "y": -1521}}, {"562":{"val":"I3", "x": -1298, "y": -1486}}, {"563":{"val":"I7", "x": -1769, "y": -916}}, {"564":{"val":"Gp", "x": -1636, "y": -976}}, {"565":{"val":"Md", "x": -1665, "y": -1114}}, {"566":{"val":"Rh", "x": -1144, "y": -1376}}, {"567":{"val":"Ra", "x": -992, "y": -1419}}, {"568":{"val":"Gp", "x": -1463, "y": -1351}}, {"569":{"val":"Ir", "x": -1349, "y": -76}}, {"570":{"val":"Mt", "x": -690, "y": -1869}}, {"571":{"val":"Pa", "x": -738, "y": -2067}}, {"572":{"val":"En", "x": -685, "y": -1726}}, {"573":{"val":"I7", "x": -452, "y": -1210}}, {"574":{"val":"I5", "x": -593, "y": -1985}}, {"575":{"val":"Gp", "x": -503, "y": -2093}}, {"576":{"val":"Pa", "x": -306, "y": -1454}}, {"577":{"val":"Pt", "x": -217, "y": -1570}}, {"578":{"val":"I6", "x": -166, "y": -1714}}, {"579":{"val":"Gc", "x": -343, "y": -2116}}, {"580":{"val":"Cd", "x": -197, "y": -2018}}, {"581":{"val":"Kh", "x": -145, "y": -1863}}, {"582":{"val":"Cc", "x": -111, "y": -2127}}, {"583":{"val":"Md", "x": -190, "y": -2235}}, {"584":{"val":"Ph", "x": -504, "y": -2259}}, {"585":{"val":"Pt", "x": -646, "y": -2192}}, {"586":{"val":"Md", "x": -571, "y": -1627}}, {"587":{"val":"Tc", "x": -1821, "y": -6}}, {"588":{"val":"G", "x": -811, "y": -1653}}, {"589":{"val":"G", "x": -2037, "y": -141}}, {"590":{"val":"Cl", "x": -909, "y": -1147}}, {"591":{"val":"Mu", "x": -1007, "y": -1631}}, {"592":{"val":"Cc", "x": -475, "y": -795}}, {"593":{"val":"H", "x": -1193, "y": -1957}}, {"594":{"val":"En", "x": -1008, "y": -1243}}, {"595":{"val":"Mt", "x": -980, "y": -1029}}, {"596":{"val":"Eh", "x": -1394, "y": -1733}}, {"597":{"val":"Cl", "x": -2047, "y": -1645}}, {"598":{"val":"Tg", "x": -1947, "y": -40}}, {"599":{"val":"Bc", "x": -2096, "y": -808}}, {"600":{"val":"Kh", "x": -895, "y": -2073}}, {"601":{"val":"Mu", "x": -635, "y": -762}}, {"602":{"val":"Bc", "x": -1192, "y": -1669}}, {"603":{"val":"H", "x": -504, "y": -1378}}, {"604":{"val":"Eh", "x": -690, "y": -1018}}, {"605":{"val":"Cd", "x": -435, "y": -943}}, {"606":{"val":"Kh", "x": -420, "y": -1078}}, {"607":{"val":"Mr", "x": -751, "y": -1168}}, {"608":{"val":"Ph", "x": -363, "y": -1318}}, {"609":{"val":"Kh", "x": -1020, "y": -716}}, {"610":{"val":"Gc", "x": -951, "y": -601}}, {"611":{"val":"Gp", "x": -1084, "y": -1759}}, {"612":{"val":"I4", "x": -894, "y": -1528}}, {"613":{"val":"Hd", "x": -744, "y": -1519}}, {"614":{"val":"Ea", "x": -1787, "y": -447}}, {"615":{"val":"Gc", "x": -1036, "y": -1893}}, {"616":{"val":"Ea", "x": -1344, "y": -1615}}, {"617":{"val":"Bd", "x": -1304, "y": -1847}}, {"618":{"val":"I1", "x": -724, "y": -448}}, {"619":{"val":"G", "x": -598, "y": -541}}, {"620":{"val":"En", "x": -513, "y": -662}}, {"621":{"val":"Ra", "x":1709, "y": -1483}}, {"622":{"val":"Pt", "x":1634, "y": -1359}}, {"623":{"val":"Md", "x":1328, "y": -1563}}, {"624":{"val":"Bd", "x":1378, "y": -1422}}, {"625":{"val":"I7", "x":1444, "y": -1295}}, {"626":{"val":"Md", "x":1357, "y": -786}}, {"627":{"val":"Pa", "x":1505, "y": -1040}}, {"628":{"val":"Hd", "x":1670, "y": -1094}}, {"629":{"val":"Cd", "x":1556, "y": -1199}}, {"630":{"val":"Cc", "x":1775, "y": -581}}, {"631":{"val":"I1", "x":1725, "y": -720}}, {"632":{"val":"Hd", "x":1595, "y": -98}}, {"633":{"val":"Kh", "x":1869, "y": -266}}, {"634":{"val":"Bd", "x":959, "y": -201}}, {"635":{"val":"Pt", "x":531, "y": -1579}}, {"636":{"val":"H", "x":1107, "y": -216}}, {"637":{"val":"Cl", "x":1159, "y": -338}}, {"638":{"val":"Ir", "x":1478, "y": -641}}, {"639":{"val":"Cd", "x":1512, "y": -769}}, {"640":{"val":"I6", "x":1480, "y": -510}}, {"641":{"val":"Kh", "x":200, "y":2540}}, {"642":{"val":"Bc", "x":347, "y":2578}}, {"643":{"val":"Md", "x":589, "y": -1066}}, {"644":{"val":"G", "x":1098, "y": -1020}}, {"645":{"val":"Cl", "x":1246, "y": -1047}}, {"646":{"val":"Cc", "x":1466, "y": -877}}, {"647":{"val":"G", "x":1075, "y": -1389}}, {"648":{"val":"Cl", "x":1631, "y": -546}}, {"649":{"val":"Rh", "x":747, "y": -1533}}, {"650":{"val":"Pa", "x":757, "y": -1675}}, {"651":{"val":"Cd", "x":1110, "y": -1259}}, {"652":{"val":"Cd", "x":1218, "y": -631}}, {"653":{"val":"Bd", "x":1331, "y": -549}}, {"654":{"val":"H", "x":1614, "y": -235}}, {"655":{"val":"Pt", "x":1872, "y": -684}}, {"656":{"val":"Md", "x":1622, "y": -969}}, {"657":{"val":"Kh", "x":667, "y": -1783}}, {"658":{"val":"I6", "x":1599, "y": -1642}}, {"659":{"val":"Cl", "x":639, "y": -929}}, {"660":{"val":"H", "x":889, "y":70}}, {"661":{"val":"H", "x":991, "y":183}}, {"662":{"val":"Cd", "x":1450, "y":176}}, {"663":{"val":"Mu", "x":1536, "y":288}}, {"664":{"val":"Cd", "x":2156, "y":23}}, {"665":{"val":"Mu", "x":2233, "y":156}}, {"666":{"val":"Md", "x":2287, "y":295}}, {"667":{"val":"Cd", "x": -58, "y": -1550}}, {"668":{"val":"Md", "x":91, "y": -1520}}, {"669":{"val":"Gc", "x": -1245, "y":34}}, {"670":{"val":"Bd", "x": -1200, "y":174}}, {"671":{"val":"G", "x":116, "y":1780}}, {"672":{"val":"Hd", "x": -31, "y":1805}}, {"673":{"val":"Gp", "x": -1260, "y":306}}, {"674":{"val":"Md", "x":888, "y": -75}}]};
//			helpfulAdventurer.levelGraphObject = {"edges":[{"1":[514,552]},{"2":[76,634]},{"3":[290,627]},{"4":[153,274]},{"5":[564,565]},{"6":[164,264]},{"7":[536,538]},{"8":[301,425]},{"9":[101,441]},{"10":[596,616]},{"11":[401,402]},{"12":[96,98]},{"13":[427,439]},{"14":[482,540]},{"15":[44,45]},{"16":[35,36]},{"17":[307,392]},{"18":[487,614]},{"19":[389,420]},{"20":[48,49]},{"21":[116,118]},{"22":[625,629]},{"23":[341,406]},{"24":[165,166]},{"25":[323,370]},{"26":[573,606]},{"27":[660,674]},{"28":[553,554]},{"29":[61,62]},{"30":[343,368]},{"31":[363,408]},{"32":[127,379]},{"33":[129,192]},{"34":[307,364]},{"35":[122,123]},{"36":[576,577]},{"37":[567,612]},{"38":[306,322]},{"39":[63,170]},{"40":[153,240]},{"41":[338,397]},{"42":[264,266]},{"43":[433,438]},{"44":[151,265]},{"45":[78,452]},{"46":[185,241]},{"47":[326,437]},{"48":[652,653]},{"49":[662,663]},{"50":[592,776]},{"51":[114,674]},{"52":[361,421]},{"53":[365,382]},{"54":[51,190]},{"55":[305,431]},{"56":[208,209]},{"57":[339,367]},{"58":[311,365]},{"59":[384,385]},{"60":[120,447]},{"61":[534,586]},{"62":[359,362]},{"63":[513,537]},{"64":[292,400]},{"65":[510,512]},{"66":[338,355]},{"67":[248,250]},{"68":[277,278]},{"69":[80,659]},{"70":[576,608]},{"71":[91,93]},{"72":[38,40]},{"73":[231,233]},{"74":[95,98]},{"75":[60,68]},{"76":[139,244]},{"77":[212,251]},{"78":[79,80]},{"79":[203,259]},{"80":[402,429]},{"81":[47,620]},{"82":[342,430]},{"83":[61,89]},{"84":[626,646]},{"85":[503,599]},{"86":[146,199]},{"87":[780,781]},{"88":[332,410]},{"89":[490,554]},{"90":[288,289]},{"91":[630,655]},{"92":[109,654]},{"93":[142,184]},{"94":[525,526]},{"95":[354,427]},{"96":[37,38]},{"97":[28,33]},{"98":[156,218]},{"99":[593,617]},{"100":[75,114]},{"101":[186,279]},{"102":[7,39]},{"103":[111,451]},{"104":[132,166]},{"105":[315,331]},{"106":[5,6]},{"107":[477,584]},{"108":[481,550]},{"109":[497,605]},{"110":[187,188]},{"111":[282,283]},{"112":[348,349]},{"113":[10,16]},{"114":[160,169]},{"115":[310,435]},{"116":[144,238]},{"117":[136,266]},{"118":[172,174]},{"119":[339,368]},{"120":[638,639]},{"121":[563,564]},{"122":[505,506]},{"123":[517,528]},{"124":[222,256]},{"125":[244,245]},{"126":[157,220]},{"127":[92,442]},{"128":[33,50]},{"129":[142,171]},{"130":[333,384]},{"131":[28,39]},{"132":[571,574]},{"133":[49,124]},{"134":[479,515]},{"135":[138,214]},{"136":[317,413]},{"137":[62,110]},{"138":[84,128]},{"139":[286,647]},{"140":[327,328]},{"141":[182,213]},{"142":[364,414]},{"143":[66,461]},{"144":[311,359]},{"145":[164,169]},{"146":[237,270]},{"147":[353,397]},{"148":[375,376]},{"149":[341,405]},{"150":[422,424]},{"151":[550,595]},{"152":[27,32]},{"153":[97,628]},{"154":[107,111]},{"155":[184,189]},{"156":[183,209]},{"157":[325,363]},{"158":[377,416]},{"159":[91,121]},{"160":[140,275]},{"161":[545,589]},{"162":[526,597]},{"163":[372,409]},{"164":[474,551]},{"165":[778,779]},{"166":[46,47]},{"167":[204,261]},{"168":[498,593]},{"169":[393,419]},{"170":[473,562]},{"171":[71,656]},{"172":[173,178]},{"173":[37,52]},{"174":[511,569]},{"175":[134,253]},{"176":[515,516]},{"177":[58,96]},{"178":[91,281]},{"179":[562,616]},{"180":[446,649]},{"181":[133,255]},{"182":[176,177]},{"183":[161,162]},{"184":[548,557]},{"185":[131,195]},{"186":[571,585]},{"187":[372,780]},{"188":[323,398]},{"189":[374,375]},{"190":[106,468]},{"191":[67,658]},{"192":[530,596]},{"193":[148,207]},{"194":[271,277]},{"195":[644,645]},{"196":[72,82]},{"197":[85,227]},{"198":[227,230]},{"199":[70,621]},{"200":[592,605]},{"201":[218,219]},{"202":[65,67]},{"203":[333,437]},{"204":[241,641]},{"205":[449,622]},{"206":[195,196]},{"207":[3,4]},{"208":[60,73]},{"209":[138,212]},{"210":[173,266]},{"211":[126,128]},{"212":[12,20]},{"213":[380,386]},{"214":[322,353]},{"215":[500,573]},{"216":[176,257]},{"217":[496,586]},{"218":[469,639]},{"219":[380,390]},{"220":[386,391]},{"221":[638,640]},{"222":[19,28]},{"223":[62,90]},{"224":[68,662]},{"225":[381,671]},{"226":[215,221]},{"227":[327,437]},{"228":[218,272]},{"229":[162,163]},{"230":[508,536]},{"231":[224,236]},{"232":[329,330]},{"233":[71,96]},{"234":[630,648]},{"235":[80,462]},{"236":[318,323]},{"237":[56,668]},{"238":[231,232]},{"239":[72,88]},{"240":[152,182]},{"241":[463,625]},{"242":[17,19]},{"243":[490,509]},{"244":[234,270]},{"245":[68,464]},{"246":[602,611]},{"247":[518,552]},{"248":[105,120]},{"249":[113,121]},{"250":[572,586]},{"251":[471,520]},{"252":[612,613]},{"253":[216,245]},{"254":[235,274]},{"255":[488,536]},{"256":[364,369]},{"257":[52,53]},{"258":[102,106]},{"259":[477,583]},{"260":[156,217]},{"261":[222,223]},{"262":[546,549]},{"263":[577,667]},{"264":[57,116]},{"265":[76,114]},{"266":[507,508]},{"267":[204,205]},{"268":[117,466]},{"269":[286,447]},{"270":[260,782]},{"271":[559,568]},{"272":[200,205]},{"273":[160,161]},{"274":[288,624]},{"275":[557,558]},{"276":[30,31]},{"277":[146,210]},{"278":[85,86]},{"279":[480,547]},{"280":[54,582]},{"281":[566,567]},{"282":[115,117]},{"283":[226,237]},{"284":[634,636]},{"285":[64,460]},{"286":[207,228]},{"287":[88,630]},{"288":[6,7]},{"289":[109,632]},{"290":[110,112]},{"291":[345,411]},{"292":[142,170]},{"293":[643,659]},{"294":[324,434]},{"295":[450,644]},{"296":[524,525]},{"297":[16,25]},{"298":[150,225]},{"299":[18,25]},{"300":[506,510]},{"301":[377,378]},{"302":[591,612]},{"303":[103,636]},{"304":[392,432]},{"305":[215,273]},{"306":[223,224]},{"307":[464,632]},{"308":[305,348]},{"309":[334,434]},{"310":[151,268]},{"311":[483,531]},{"312":[194,201]},{"313":[240,243]},{"314":[587,598]},{"315":[664,665]},{"316":[448,640]},{"317":[99,441]},{"318":[321,371]},{"319":[81,659]},{"320":[254,255]},{"321":[489,539]},{"322":[636,637]},{"323":[200,227]},{"324":[115,778]},{"325":[105,643]},{"326":[57,59]},{"327":[592,620]},{"328":[370,415]},{"329":[572,588]},{"330":[537,543]},{"331":[64,113]},{"332":[293,418]},{"333":[468,637]},{"334":[51,194]},{"335":[389,391]},{"336":[17,18]},{"337":[378,431]},{"338":[29,32]},{"339":[387,388]},{"340":[584,585]},{"341":[337,428]},{"342":[502,503]},{"343":[532,533]},{"344":[268,269]},{"345":[442,657]},{"346":[350,435]},{"347":[601,620]},{"348":[385,386]},{"349":[308,319]},{"350":[579,580]},{"351":[199,201]},{"352":[337,419]},{"353":[287,444]},{"354":[102,107]},{"355":[373,404]},{"356":[345,346]},{"357":[74,75]},{"358":[171,172]},{"359":[365,373]},{"360":[87,88]},{"361":[561,562]},{"362":[542,618]},{"363":[219,221]},{"364":[4,5]},{"365":[577,578]},{"366":[498,615]},{"367":[191,192]},{"368":[320,408]},{"369":[334,339]},{"370":[294,394]},{"371":[445,635]},{"372":[507,510]},{"373":[540,610]},{"374":[1,2]},{"375":[232,238]},{"376":[126,632]},{"377":[168,187]},{"378":[133,196]},{"379":[123,643]},{"380":[83,664]},{"381":[493,556]},{"382":[527,535]},{"383":[108,450]},{"384":[573,608]},{"385":[509,533]},{"386":[181,211]},{"387":[590,607]},{"388":[92,93]},{"389":[302,433]},{"390":[209,210]},{"391":[354,369]},{"392":[96,655]},{"393":[147,226]},{"394":[495,574]},{"395":[14,15]},{"396":[378,381]},{"397":[76,101]},{"398":[329,437]},{"399":[226,228]},{"400":[189,193]},{"401":[512,513]},{"402":[239,273]},{"403":[117,118]},{"404":[467,623]},{"405":[83,84]},{"406":[619,620]},{"407":[346,381]},{"408":[627,628]},{"409":[11,12]},{"410":[548,560]},{"411":[309,407]},{"412":[559,562]},{"413":[669,670]},{"414":[580,582]},{"415":[94,95]},{"416":[75,459]},{"417":[303,439]},{"418":[328,666]},{"419":[776,777]},{"420":[21,23]},{"421":[149,222]},{"422":[300,352]},{"423":[472,514]},{"424":[140,249]},{"425":[175,181]},{"426":[330,383]},{"427":[312,387]},{"428":[146,202]},{"429":[356,439]},{"430":[522,589]},{"431":[26,46]},{"432":[135,247]},{"433":[231,672]},{"434":[132,167]},{"435":[90,92]},{"436":[393,403]},{"437":[358,388]},{"438":[641,642]},{"439":[78,654]},{"440":[56,667]},{"441":[523,524]},{"442":[485,522]},{"443":[406,412]},{"444":[310,357]},{"445":[349,429]},{"446":[287,647]},{"447":[331,344]},{"448":[344,391]},{"449":[115,124]},{"450":[500,607]},{"451":[413,425]},{"452":[179,213]},{"453":[396,412]},{"454":[137,177]},{"455":[337,422]},{"456":[357,436]},{"457":[24,63]},{"458":[471,519]},{"459":[520,523]},{"460":[548,555]},{"461":[233,267]},{"462":[141,181]},{"463":[296,398]},{"464":[79,124]},{"465":[330,331]},{"466":[350,353]},{"467":[144,185]},{"468":[318,429]},{"469":[546,601]},{"470":[387,420]},{"471":[650,657]},{"472":[299,429]},{"473":[50,51]},{"474":[55,89]},{"475":[371,426]},{"476":[243,245]},{"477":[78,87]},{"478":[283,635]},{"479":[161,229]},{"480":[556,560]},{"481":[99,102]},{"482":[482,618]},{"483":[41,77]},{"484":[486,505]},{"485":[26,27]},{"486":[497,604]},{"487":[660,661]},{"488":[297,410]},{"489":[317,331]},{"490":[360,425]},{"491":[551,566]},{"492":[284,287]},{"493":[343,390]},{"494":[342,376]},{"495":[151,259]},{"496":[54,55]},{"497":[308,371]},{"498":[570,574]},{"499":[281,453]},{"500":[104,465]},{"501":[13,14]},{"502":[211,212]},{"503":[7,8]},{"504":[504,520]},{"505":[385,440]},{"506":[403,417]},{"507":[2,3]},{"508":[43,44]},{"509":[86,393]},{"510":[549,604]},{"511":[323,421]},{"512":[492,532]},{"513":[578,581]},{"514":[630,631]},{"515":[478,502]},{"516":[501,502]},{"517":[400,424]},{"518":[627,656]},{"519":[72,465]},{"520":[313,390]},{"521":[179,269]},{"522":[517,518]},{"523":[175,202]},{"524":[10,11]},{"525":[131,186]},{"526":[127,642]},{"527":[519,553]},{"528":[284,288]},{"529":[297,324]},{"530":[222,280]},{"531":[135,279]},{"532":[203,206]},{"533":[454,651]},{"534":[77,541]},{"535":[488,543]},{"536":[467,658]},{"537":[36,37]},{"538":[476,597]},{"539":[131,163]},{"540":[118,123]},{"541":[100,448]},{"542":[530,535]},{"543":[561,602]},{"544":[366,419]},{"545":[404,439]},{"546":[324,661]},{"547":[306,379]},{"548":[8,9]},{"549":[489,541]},{"550":[582,583]},{"551":[588,612]},{"552":[456,631]},{"553":[290,451]},{"554":[83,104]},{"555":[591,611]},{"556":[146,193]},{"557":[498,600]},{"558":[177,178]},{"559":[589,669]},{"560":[21,22]},{"561":[25,26]},{"562":[298,406]},{"563":[260,261]},{"564":[24,569]},{"565":[167,170]},{"566":[73,125]},{"567":[492,530]},{"568":[332,336]},{"569":[605,606]},{"570":[325,438]},{"571":[145,230]},{"572":[640,648]},{"573":[229,673]},{"574":[336,440]},{"575":[499,613]},{"576":[516,614]},{"577":[214,276]},{"578":[403,409]},{"579":[41,129]},{"580":[314,339]},{"581":[106,652]},{"582":[61,457]},{"583":[128,470]},{"584":[89,130]},{"585":[295,403]},{"586":[42,443]},{"587":[561,566]},{"588":[395,405]},{"589":[66,70]},{"590":[29,30]},{"591":[213,217]},{"592":[267,274]},{"593":[366,411]},{"594":[81,108]},{"595":[571,600]},{"596":[292,347]},{"597":[42,59]},{"598":[361,425]},{"599":[64,65]},{"600":[53,340]},{"601":[84,633]},{"602":[538,539]},{"603":[312,374]},{"604":[22,31]},{"605":[782,783]},{"606":[484,580]},{"607":[480,517]},{"608":[20,31]},{"609":[250,259]},{"610":[481,609]},{"611":[356,360]},{"612":[483,525]},{"613":[475,546]},{"614":[590,594]},{"615":[382,383]},{"616":[532,568]},{"617":[342,418]},{"618":[33,34]},{"619":[501,521]},{"620":[649,650]},{"621":[152,206]},{"622":[358,361]},{"623":[304,328]},{"624":[155,262]},{"625":[119,122]},{"626":[289,651]},{"627":[455,626]},{"628":[158,179]},{"629":[355,432]},{"630":[640,653]},{"631":[207,208]},{"632":[202,280]},{"633":[59,668]},{"634":[132,197]},{"635":[517,563]},{"636":[570,572]},{"637":[172,173]},{"638":[69,70]},{"639":[159,183]},{"640":[275,276]},{"641":[141,174]},{"642":[249,252]},{"643":[15,40]},{"644":[284,285]},{"645":[388,407]},{"646":[362,363]},{"647":[319,423]},{"648":[60,103]},{"649":[30,48]},{"650":[159,204]},{"651":[290,645]},{"652":[241,242]},{"653":[474,594]},{"654":[236,239]},{"655":[555,565]},{"656":[9,10]},{"657":[155,263]},{"658":[486,587]},{"659":[154,215]},{"660":[253,257]},{"661":[394,395]},{"662":[158,271]},{"663":[291,345]},{"664":[143,192]},{"665":[335,336]},{"666":[624,625]},{"667":[262,270]},{"668":[304,316]},{"669":[145,231]},{"670":[251,256]},{"671":[234,235]},{"672":[252,257]},{"673":[541,542]},{"674":[621,622]},{"675":[200,207]},{"676":[552,557]},{"677":[379,416]},{"678":[273,278]},{"679":[165,169]},{"680":[487,529]},{"681":[364,415]},{"682":[139,242]},{"683":[336,663]},{"684":[580,581]},{"685":[611,615]},{"686":[575,579]},{"687":[340,367]},{"688":[53,372]},{"689":[257,258]},{"690":[57,458]},{"691":[180,249]},{"692":[23,38]},{"693":[188,191]},{"694":[190,191]},{"695":[142,168]},{"696":[69,658]},{"697":[352,389]},{"698":[357,399]},{"699":[531,533]},{"700":[320,354]},{"701":[100,109]},{"702":[157,216]},{"703":[246,266]},{"704":[476,527]},{"705":[71,469]},{"706":[481,558]},{"707":[479,510]},{"708":[515,545]},{"709":[335,351]},{"710":[246,247]},{"711":[253,254]},{"712":[503,504]},{"713":[395,417]},{"714":[248,254]},{"715":[87,633]},{"716":[219,220]},{"717":[396,407]},{"718":[34,35]},{"719":[551,560]},{"720":[51,260]},{"721":[42,130]},{"722":[628,629]},{"723":[547,599]},{"724":[399,433]},{"725":[491,578]},{"726":[534,576]},{"727":[74,124]},{"728":[290,646]},{"729":[58,82]},{"730":[623,624]},{"731":[414,426]},{"732":[282,458]},{"733":[346,347]},{"734":[574,575]},{"735":[43,118]},{"736":[285,460]},{"737":[316,351]},{"738":[271,272]},{"739":[112,445]},{"740":[544,558]},{"741":[12,13]},{"742":[179,180]},{"743":[100,125]},{"744":[499,603]},{"745":[589,598]},{"746":[95,97]},{"747":[276,277]},{"748":[6,15]},{"749":[198,229]},{"750":[505,569]},{"751":[590,595]},{"752":[603,608]},{"753":[618,619]},{"754":[549,550]},{"755":[543,544]},{"756":[97,449]},{"757":[239,263]},{"758":[665,666]},{"759":[521,522]},{"760":[513,514]},{"761":[94,461]},{"762":[596,617]},{"763":[224,225]},{"764":[511,539]},{"765":[197,198]},{"766":[53,430]},{"767":[670,673]},{"768":[671,672]},{"769":[609,610]},{"770":[45,606]},{"771":[519,563]},{"772":[320,423]},{"773":[400,401]},{"774":[528,529]},{"775":[494,565]},{"776":[119,446]},{"777":[258,265]},{"778":[321,436]}],"nodes":[{"1":{"val":"T1","x":-54,"y":-23}},{"2":{"val":"T2","x":1,"y":-97}},{"3":{"val":"T3","x":56,"y":-24}},{"4":{"val":"T4","x":1,"y":42}},{"5":{"val":"T5","x":1,"y":139}},{"6":{"val":"A0","x":1,"y":250}},{"7":{"val":"A3","x":-76,"y":150}},{"8":{"val":"T8","x":-147,"y":56}},{"9":{"val":"A5","x":-147,"y":-43}},{"10":{"val":"S3","x":-75,"y":-138}},{"11":{"val":"T7","x":2,"y":-237}},{"12":{"val":"S2","x":79,"y":-138}},{"13":{"val":"A4","x":149,"y":-44}},{"14":{"val":"T6","x":149,"y":53}},{"15":{"val":"A2","x":79,"y":150}},{"16":{"val":"Az","x":-174,"y":-188}},{"17":{"val":"Sd","x":-358,"y":2}},{"18":{"val":"Az","x":-358,"y":-119}},{"19":{"val":"Az","x":-358,"y":118}},{"20":{"val":"Az","x":174,"y":-187}},{"21":{"val":"Se","x":361,"y":2}},{"22":{"val":"Az","x":361,"y":-118}},{"23":{"val":"Az","x":361,"y":120}},{"24":{"val":"Gp","x":-1278,"y":46}},{"25":{"val":"Au","x":-265,"y":-231}},{"26":{"val":"S8","x":-178,"y":-335}},{"27":{"val":"S4","x":-86,"y":-448}},{"28":{"val":"A8","x":-271,"y":237}},{"29":{"val":"S6","x":89,"y":-448}},{"30":{"val":"S9","x":184,"y":-334}},{"31":{"val":"A6","x":266,"y":-234}},{"32":{"val":"A7","x":2,"y":-555}},{"33":{"val":"Sg","x":-189,"y":337}},{"34":{"val":"S5","x":-95,"y":444}},{"35":{"val":"S1","x":6,"y":551}},{"36":{"val":"S7","x":97,"y":440}},{"37":{"val":"Sf","x":185,"y":337}},{"38":{"val":"Av","x":262,"y":238}},{"39":{"val":"Az","x":-168,"y":193}},{"40":{"val":"Az","x":171,"y":192}},{"41":{"val":"Ir","x":-582,"y":-41}},{"42":{"val":"I2","x":321,"y":-1780}},{"43":{"val":"Gc","x":172,"y":-1144}},{"44":{"val":"Cc","x":-23,"y":-1119}},{"45":{"val":"Gp","x":-216,"y":-1099}},{"46":{"val":"Bd","x":-292,"y":-444}},{"47":{"val":"qMr","x":-403,"y":-549}},{"48":{"val":"Cc","x":299,"y":-444}},{"49":{"val":"qCd","x":417,"y":-550}},{"50":{"val":"Hd","x":-291,"y":426}},{"51":{"val":"qG","x":-403,"y":515}},{"52":{"val":"Mu","x":298,"y":424}},{"53":{"val":"qH","x":418,"y":515}},{"54":{"val":"Gc","x":18,"y":-2110}},{"55":{"val":"Gp","x":172,"y":-2085}},{"56":{"val":"Mr","x":37,"y":-1637}},{"57":{"val":"Bd","x":358,"y":-1474}},{"58":{"val":"Rh","x":2095,"y":-869}},{"59":{"val":"Bc","x":319,"y":-1620}},{"60":{"val":"I7","x":1318,"y":-125}},{"61":{"val":"Cc","x":466,"y":-2033}},{"62":{"val":"I3","x":594,"y":-2133}},{"63":{"val":"Gc","x":-1294,"y":219}},{"64":{"val":"Bg","x":1286,"y":-1857}},{"65":{"val":"Cl","x":1440,"y":-1874}},{"66":{"val":"Tg","x":2008,"y":-1567}},{"67":{"val":"Gc","x":1597,"y":-1881}},{"68":{"val":"H","x":1448,"y":-71}},{"69":{"val":"Gb","x":1817,"y":-1797}},{"70":{"val":"G","x":1910,"y":-1667}},{"71":{"val":"Bc","x":1834,"y":-1029}},{"72":{"val":"Mu","x":2102,"y":-589}},{"73":{"val":"Mu","x":1425,"y":-239}},{"74":{"val":"Mu","x":661,"y":-581}},{"75":{"val":"H","x":764,"y":-472}},{"76":{"val":"I8","x":1028,"y":-450}},{"77":{"val":"Gp","x":-574,"y":-178}},{"78":{"val":"I4","x":1756,"y":-463}},{"79":{"val":"Pa","x":678,"y":-784}},{"80":{"val":"Cc","x":817,"y":-893}},{"81":{"val":"Pt","x":872,"y":-1075}},{"82":{"val":"Hd","x":2126,"y":-730}},{"83":{"val":"H","x":2132,"y":-221}},{"84":{"val":"Bd","x":2000,"y":-271}},{"85":{"val":"","x":-51,"y":1147}},{"86":{"val":"","x":-8,"y":1011}},{"87":{"val":"Cd","x":1886,"y":-513}},{"88":{"val":"Md","x":1964,"y":-621}},{"89":{"val":"Mt","x":322,"y":-2051}},{"90":{"val":"G","x":705,"y":-2233}},{"91":{"val":"I4","x":1023,"y":-2038}},{"92":{"val":"Cl","x":829,"y":-2150}},{"93":{"val":"Gp","x":976,"y":-2161}},{"94":{"val":"Md","x":2091,"y":-1310}},{"95":{"val":"I8","x":2017,"y":-1189}},{"96":{"val":"Cd","x":1956,"y":-948}},{"97":{"val":"Kh","x":1880,"y":-1247}},{"98":{"val":"Md","x":2049,"y":-1052}},{"99":{"val":"Md","x":905,"y":-773}},{"100":{"val":"Pa","x":1520,"y":-449}},{"101":{"val":"Cc","x":929,"y":-585}},{"102":{"val":"Hd","x":1041,"y":-769}},{"103":{"val":"Kh","x":1200,"y":-202}},{"104":{"val":"Bc","x":2173,"y":-348}},{"105":{"val":"I3","x":815,"y":-1221}},{"106":{"val":"G","x":1158,"y":-701}},{"107":{"val":"Ra","x":1159,"y":-847}},{"108":{"val":"Cd","x":988,"y":-1176}},{"109":{"val":"Ir","x":1560,"y":-316}},{"110":{"val":"Md","x":641,"y":-2008}},{"111":{"val":"Ph","x":1272,"y":-923}},{"112":{"val":"Cd","x":588,"y":-1876}},{"113":{"val":"Tc","x":1278,"y":-1993}},{"114":{"val":"Bc","x":879,"y":-370}},{"115":{"val":"Mr","x":482,"y":-825}},{"116":{"val":"Eh","x":334,"y":-1318}},{"117":{"val":"Ea","x":419,"y":-993}},{"118":{"val":"I1","x":355,"y":-1153}},{"119":{"val":"G","x":767,"y":-1419}},{"120":{"val":"Cc","x":903,"y":-1335}},{"121":{"val":"Ir","x":1163,"y":-2087}},{"122":{"val":"Cd","x":638,"y":-1350}},{"123":{"val":"Ph","x":513,"y":-1247}},{"124":{"val":"Md","x":537,"y":-669}},{"125":{"val":"Md","x":1390,"y":-370}},{"126":{"val":"Mu","x":1775,"y":-118}},{"127":{"val":"Hd","x":604,"y":2161}},{"128":{"val":"I5","x":1911,"y":-169}},{"129":{"val":"Gc","x":-686,"y":55}},{"130":{"val":"En","x":235,"y":-1915}},{"131":{"val":"qMt","x":-2134,"y":613}},{"132":{"val":"qEn","x":-1669,"y":151}},{"133":{"val":"qGp","x":-2133,"y":971}},{"134":{"val":"qIr","x":-2035,"y":1045}},{"135":{"val":"qGc","x":-2047,"y":954}},{"136":{"val":"Q43","x":-1933,"y":782}},{"137":{"val":"qHd","x":-1468,"y":1153}},{"138":{"val":"qIr","x":-1315,"y":1274}},{"139":{"val":"qBd","x":-13,"y":2339}},{"140":{"val":"qG","x":-1535,"y":1405}},{"141":{"val":"qG","x":-1387,"y":966}},{"142":{"val":"Q44","x":-1284,"y":461}},{"143":{"val":"qGp","x":-496,"y":134}},{"144":{"val":"qH","x":-9,"y":2049}},{"145":{"val":"qMu","x":-142,"y":1549}},{"146":{"val":"qBg","x":-816,"y":832}},{"147":{"val":"qGb","x":-465,"y":1499}},{"148":{"val":"qHd","x":-517,"y":1208}},{"149":{"val":"Q42","x":-618,"y":1162}},{"150":{"val":"qTc","x":-599,"y":1267}},{"151":{"val":"Q41","x":-1967,"y":1664}},{"152":{"val":"qHd","x":-1967,"y":1955}},{"153":{"val":"qBd","x":-283,"y":2011}},{"154":{"val":"Q45","x":-721,"y":1921}},{"155":{"val":"qTg","x":-512,"y":1822}},{"156":{"val":"qG","x":-1256,"y":2103}},{"157":{"val":"qHd","x":-534,"y":2251}},{"158":{"val":"qGb","x":-1365,"y":1788}},{"159":{"val":"qH","x":-326,"y":818}},{"160":{"val":"qMr","x":-1893,"y":377}},{"161":{"val":"I6","x":-2028,"y":314}},{"162":{"val":"Gc","x":-2162,"y":359}},{"163":{"val":"Gp","x":-2177,"y":489}},{"164":{"val":"G","x":-1851,"y":572}},{"165":{"val":"Mt","x":-1588,"y":406}},{"166":{"val":"Mr","x":-1694,"y":281}},{"167":{"val":"Ea","x":-1523,"y":219}},{"168":{"val":"Kh","x":-1141,"y":399}},{"169":{"val":"En","x":-1743,"y":462}},{"170":{"val":"Eh","x":-1395,"y":335}},{"171":{"val":"Gp","x":-1377,"y":587}},{"172":{"val":"Gc","x":-1498,"y":694}},{"173":{"val":"G","x":-1634,"y":777}},{"174":{"val":"Cd","x":-1424,"y":828}},{"175":{"val":"Cl","x":-1075,"y":910}},{"176":{"val":"Rh","x":-1701,"y":1220}},{"177":{"val":"I3","x":-1626,"y":1080}},{"178":{"val":"Ra","x":-1597,"y":920}},{"179":{"val":"G","x":-1523,"y":1816}},{"180":{"val":"Mr","x":-1576,"y":1670}},{"181":{"val":"I5","x":-1228,"y":936}},{"182":{"val":"Ph","x":-1785,"y":1951}},{"183":{"val":"Hd","x":-455,"y":879}},{"184":{"val":"Cd","x":-1172,"y":560}},{"185":{"val":"Hd","x":122,"y":2068}},{"186":{"val":"G","x":-2008,"y":675}},{"187":{"val":"Bd","x":-984,"y":363}},{"188":{"val":"Bc","x":-818,"y":339}},{"189":{"val":"Cc","x":-1031,"y":616}},{"190":{"val":"Gp","x":-526,"y":409}},{"191":{"val":"Gc","x":-660,"y":329}},{"192":{"val":"I8","x":-635,"y":193}},{"193":{"val":"Gb","x":-963,"y":743}},{"194":{"val":"Ir","x":-516,"y":619}},{"195":{"val":"I2","x":-2187,"y":721}},{"196":{"val":"Hd","x":-2180,"y":849}},{"197":{"val":"Hd","x":-1822,"y":142}},{"198":{"val":"Ra","x":-1968,"y":162}},{"199":{"val":"Tg","x":-757,"y":699}},{"200":{"val":"Ir","x":-236,"y":1157}},{"201":{"val":"Tc","x":-663,"y":590}},{"202":{"val":"G","x":-930,"y":930}},{"203":{"val":"Md","x":-2147,"y":1755}},{"204":{"val":"Ea","x":-200,"y":892}},{"205":{"val":"Eh","x":-179,"y":1028}},{"206":{"val":"Pa","x":-2088,"y":1879}},{"207":{"val":"I1","x":-377,"y":1165}},{"208":{"val":"Bg","x":-456,"y":1059}},{"209":{"val":"G","x":-566,"y":971}},{"210":{"val":"Gb","x":-669,"y":870}},{"211":{"val":"Hd","x":-1176,"y":1069}},{"212":{"val":"G","x":-1185,"y":1209}},{"213":{"val":"I7","x":-1606,"y":1963}},{"214":{"val":"Ea","x":-1248,"y":1400}},{"215":{"val":"G","x":-863,"y":1901}},{"216":{"val":"Pa","x":-395,"y":2305}},{"217":{"val":"Pt","x":-1426,"y":2021}},{"218":{"val":"Cc","x":-1077,"y":2109}},{"219":{"val":"Cd","x":-894,"y":2165}},{"220":{"val":"Md","x":-712,"y":2207}},{"221":{"val":"Bd","x":-897,"y":2034}},{"222":{"val":"I2","x":-759,"y":1137}},{"223":{"val":"Tg","x":-776,"y":1264}},{"224":{"val":"Ir","x":-794,"y":1393}},{"225":{"val":"Gb","x":-639,"y":1392}},{"226":{"val":"Gp","x":-353,"y":1422}},{"227":{"val":"Mu","x":-136,"y":1269}},{"228":{"val":"G","x":-321,"y":1287}},{"229":{"val":"Rh","x":-2097,"y":204}},{"230":{"val":"H","x":-109,"y":1410}},{"231":{"val":"I3","x":-67,"y":1678}},{"232":{"val":"Bd","x":-5,"y":1797}},{"233":{"val":"Ea","x":-194,"y":1709}},{"234":{"val":"Gb","x":-348,"y":1743}},{"235":{"val":"Bg","x":-358,"y":1873}},{"236":{"val":"Bg","x":-762,"y":1530}},{"237":{"val":"Gc","x":-290,"y":1539}},{"238":{"val":"Bc","x":45,"y":1928}},{"239":{"val":"Ra","x":-747,"y":1672}},{"240":{"val":"Ph","x":-427,"y":2033}},{"241":{"val":"Mu","x":180,"y":2183}},{"242":{"val":"H","x":117,"y":2296}},{"243":{"val":"Pt","x":-364,"y":2161}},{"244":{"val":"Cl","x":-124,"y":2263}},{"245":{"val":"I5","x":-261,"y":2255}},{"246":{"val":"Tg","x":-1750,"y":925}},{"247":{"val":"Tc","x":-1905,"y":938}},{"248":{"val":"Gc","x":-2157,"y":1366}},{"249":{"val":"En","x":-1636,"y":1531}},{"250":{"val":"Gp","x":-2151,"y":1506}},{"251":{"val":"Ra","x":-1046,"y":1166}},{"252":{"val":"Mt","x":-1748,"y":1417}},{"253":{"val":"G","x":-1942,"y":1178}},{"254":{"val":"I1","x":-2102,"y":1248}},{"255":{"val":"Cd","x":-2150,"y":1110}},{"256":{"val":"Rh","x":-899,"y":1147}},{"257":{"val":"Hd","x":-1848,"y":1302}},{"258":{"val":"Cd","x":-1962,"y":1385}},{"259":{"val":"I8","x":-2116,"y":1634}},{"260":{"val":"H","x":-299,"y":632}},{"261":{"val":"Kh","x":-197,"y":744}},{"262":{"val":"Ir","x":-534,"y":1680}},{"263":{"val":"Rh","x":-659,"y":1778}},{"264":{"val":"Cl","x":-1725,"y":639}},{"265":{"val":"Cc","x":-1944,"y":1528}},{"266":{"val":"I4","x":-1785,"y":767}},{"267":{"val":"Eh","x":-133,"y":1824}},{"268":{"val":"Hd","x":-1825,"y":1714}},{"269":{"val":"Cl","x":-1679,"y":1771}},{"270":{"val":"I4","x":-404,"y":1626}},{"271":{"val":"Gp","x":-1216,"y":1838}},{"272":{"val":"Gc","x":-1121,"y":1965}},{"273":{"val":"Cd","x":-866,"y":1761}},{"274":{"val":"H","x":-227,"y":1905}},{"275":{"val":"Eh","x":-1417,"y":1492}},{"276":{"val":"Kh","x":-1263,"y":1547}},{"277":{"val":"I6","x":-1199,"y":1692}},{"278":{"val":"Hd","x":-1034,"y":1731}},{"279":{"val":"Gb","x":-2065,"y":809}},{"280":{"val":"Tc","x":-817,"y":1015}},{"281":{"val":"Md","x":963,"y":-1909}},{"282":{"val":"Cl","x":582,"y":-1575}},{"283":{"val":"Cc","x":449,"y":-1665}},{"284":{"val":"Cl","x":1209,"y":-1652}},{"285":{"val":"Cd","x":1094,"y":-1748}},{"286":{"val":"Md","x":1028,"y":-1427}},{"287":{"val":"I5","x":1057,"y":-1619}},{"288":{"val":"Pt","x":1287,"y":-1540}},{"289":{"val":"Cc","x":1336,"y":-1415}},{"290":{"val":"I2","x":1440,"y":-1086}},{"291":{"val":"qG","x":199,"y":1362}},{"292":{"val":"qHd","x":478,"y":1499}},{"293":{"val":"Q81","x":475,"y":798}},{"294":{"val":"qH","x":755,"y":927}},{"295":{"val":"qBg","x":60,"y":761}},{"296":{"val":"Q84","x":1014,"y":1248}},{"297":{"val":"qCd","x":964,"y":149}},{"298":{"val":"qBd","x":666,"y":1135}},{"299":{"val":"qH","x":870,"y":1369}},{"300":{"val":"qMu","x":1142,"y":721}},{"301":{"val":"qBc","x":1344,"y":956}},{"302":{"val":"Q86","x":1676,"y":1921}},{"303":{"val":"Q85","x":1470,"y":1299}},{"304":{"val":"Q83","x":1834,"y":309}},{"305":{"val":"qTg","x":738,"y":1780}},{"306":{"val":"qIr","x":863,"y":2063}},{"307":{"val":"qH","x":1300,"y":1529}},{"308":{"val":"qMu","x":1439,"y":1805}},{"309":{"val":"qMu","x":819,"y":991}},{"310":{"val":"qBd","x":1452,"y":2230}},{"311":{"val":"qHd","x":2094,"y":1346}},{"312":{"val":"qH","x":994,"y":846}},{"313":{"val":"Q82","x":984,"y":639}},{"314":{"val":"qH","x":980,"y":505}},{"315":{"val":"qH","x":1613,"y":903}},{"316":{"val":"Kh","x":1844,"y":173}},{"317":{"val":"Hd","x":1714,"y":1015}},{"318":{"val":"Cd","x":1115,"y":1429}},{"319":{"val":"H","x":1585,"y":1797}},{"320":{"val":"Bc","x":1782,"y":1641}},{"321":{"val":"Cl","x":1415,"y":2001}},{"322":{"val":"Rh","x":989,"y":2110}},{"323":{"val":"I6","x":1220,"y":1341}},{"324":{"val":"Ph","x":836,"y":67}},{"325":{"val":"Mu","x":1983,"y":1828}},{"326":{"val":"qCl","x":1730,"y":602}},{"327":{"val":"H","x":1962,"y":447}},{"328":{"val":"Cd","x":1986,"y":306}},{"329":{"val":"Kh","x":1921,"y":673}},{"330":{"val":"Cd","x":1879,"y":802}},{"331":{"val":"Mu","x":1767,"y":888}},{"332":{"val":"Pa","x":1262,"y":231}},{"333":{"val":"Bd","x":1767,"y":440}},{"334":{"val":"Md","x":807,"y":276}},{"335":{"val":"Cd","x":1537,"y":231}},{"336":{"val":"I7","x":1395,"y":274}},{"337":{"val":"Ra","x":235,"y":1181}},{"338":{"val":"Q88","x":1155,"y":1932}},{"339":{"val":"I8","x":865,"y":411}},{"340":{"val":"Cd","x":543,"y":421}},{"341":{"val":"Cl","x":454,"y":1189}},{"342":{"val":"I5","x":644,"y":667}},{"343":{"val":"Mu","x":1139,"y":428}},{"344":{"val":"En","x":1686,"y":756}},{"345":{"val":"I2","x":187,"y":1500}},{"346":{"val":"Gp","x":302,"y":1578}},{"347":{"val":"Bc","x":441,"y":1629}},{"348":{"val":"H","x":885,"y":1712}},{"349":{"val":"Bd","x":990,"y":1601}},{"350":{"val":"Mu","x":1201,"y":2228}},{"351":{"val":"Pt","x":1684,"y":179}},{"352":{"val":"Cl","x":1290,"y":687}},{"353":{"val":"G","x":1114,"y":2143}},{"354":{"val":"I1","x":1704,"y":1536}},{"355":{"val":"H","x":1064,"y":1834}},{"356":{"val":"Eh","x":1644,"y":1169}},{"357":{"val":"Ea","x":1593,"y":2186}},{"358":{"val":"Mu","x":1153,"y":1091}},{"359":{"val":"G","x":2125,"y":1474}},{"360":{"val":"Bd","x":1505,"y":1162}},{"361":{"val":"H","x":1289,"y":1118}},{"362":{"val":"Cl","x":2103,"y":1607}},{"363":{"val":"Kh","x":2003,"y":1697}},{"364":{"val":"Kh","x":1434,"y":1576}},{"365":{"val":"I5","x":2040,"y":1211}},{"366":{"val":"Gb","x":82,"y":1264}},{"367":{"val":"Hd","x":708,"y":404}},{"368":{"val":"Cl","x":1030,"y":343}},{"369":{"val":"Mu","x":1574,"y":1591}},{"370":{"val":"H","x":1354,"y":1390}},{"371":{"val":"I8","x":1335,"y":1892}},{"372":{"val":"G","x":327,"y":619}},{"373":{"val":"Mu","x":1907,"y":1256}},{"374":{"val":"Cl","x":846,"y":810}},{"375":{"val":"Mu","x":827,"y":671}},{"376":{"val":"H","x":741,"y":545}},{"377":{"val":"Tc","x":471,"y":1942}},{"378":{"val":"Rh","x":428,"y":1800}},{"379":{"val":"Tg","x":723,"y":2074}},{"380":{"val":"H","x":1277,"y":550}},{"381":{"val":"Bg","x":302,"y":1721}},{"382":{"val":"H","x":2019,"y":1057}},{"383":{"val":"Bd","x":1966,"y":915}},{"384":{"val":"H","x":1627,"y":426}},{"385":{"val":"Mu","x":1524,"y":497}},{"386":{"val":"Bc","x":1426,"y":591}},{"387":{"val":"Kh","x":1133,"y":908}},{"388":{"val":"Cl","x":1053,"y":1007}},{"389":{"val":"H","x":1419,"y":786}},{"390":{"val":"Bd","x":1125,"y":570}},{"391":{"val":"I4","x":1541,"y":694}},{"392":{"val":"Hd","x":1168,"y":1589}},{"393":{"val":"Tc","x":135,"y":989}},{"394":{"val":"Hd","x":600,"y":942}},{"395":{"val":"Kh","x":445,"y":927}},{"396":{"val":"H","x":838,"y":1168}},{"397":{"val":"Bg","x":1197,"y":2053}},{"398":{"val":"Mr","x":1151,"y":1223}},{"399":{"val":"H","x":1712,"y":2104}},{"400":{"val":"I4","x":592,"y":1414}},{"401":{"val":"G","x":704,"y":1495}},{"402":{"val":"Cl","x":845,"y":1527}},{"403":{"val":"I1","x":166,"y":860}},{"404":{"val":"Cl","x":1756,"y":1285}},{"405":{"val":"Mu","x":485,"y":1061}},{"406":{"val":"Mt","x":578,"y":1239}},{"407":{"val":"I3","x":935,"y":1067}},{"408":{"val":"qH","x":1907,"y":1604}},{"409":{"val":"Tg","x":247,"y":739}},{"410":{"val":"Cc","x":1115,"y":168}},{"411":{"val":"Gc","x":70,"y":1404}},{"412":{"val":"Bc","x":730,"y":1261}},{"413":{"val":"Cl","x":1567,"y":1028}},{"414":{"val":"Hd","x":1349,"y":1685}},{"415":{"val":"Bd","x":1480,"y":1449}},{"416":{"val":"I3","x":606,"y":1980}},{"417":{"val":"H","x":297,"y":901}},{"418":{"val":"H","x":616,"y":795}},{"419":{"val":"Ir","x":107,"y":1123}},{"420":{"val":"G","x":1267,"y":841}},{"421":{"val":"Hd","x":1319,"y":1243}},{"422":{"val":"Mu","x":341,"y":1270}},{"423":{"val":"Hd","x":1719,"y":1749}},{"424":{"val":"H","x":466,"y":1338}},{"425":{"val":"I2","x":1419,"y":1063}},{"426":{"val":"H","x":1247,"y":1790}},{"427":{"val":"Cd","x":1648,"y":1418}},{"428":{"val":"Q87","x":329,"y":1080}},{"429":{"val":"Mu","x":978,"y":1464}},{"430":{"val":"Bd","x":530,"y":592}},{"431":{"val":"G","x":588,"y":1817}},{"432":{"val":"Mu","x":1091,"y":1698}},{"433":{"val":"I7","x":1789,"y":1998}},{"434":{"val":"H","x":731,"y":164}},{"435":{"val":"Kh","x":1323,"y":2257}},{"436":{"val":"G","x":1532,"y":2075}},{"437":{"val":"I6","x":1863,"y":543}},{"438":{"val":"Bd","x":1897,"y":1925}},{"439":{"val":"H","x":1609,"y":1296}},{"440":{"val":"qHd","x":1411,"y":407}},{"441":{"val":"qH","x":814,"y":-672}},{"442":{"val":"qBd","x":808,"y":-2013}},{"443":{"val":"Q63","x":471,"y":-1807}},{"444":{"val":"Q64","x":940,"y":-1553}},{"445":{"val":"qBd","x":714,"y":-1780}},{"446":{"val":"qMd","x":719,"y":-1552}},{"447":{"val":"qCd","x":1057,"y":-1280}},{"448":{"val":"qCd","x":1437,"y":-557}},{"449":{"val":"qCd","x":1789,"y":-1365}},{"450":{"val":"qCl","x":1060,"y":-1050}},{"451":{"val":"qCd","x":1292,"y":-1050}},{"452":{"val":"Q61","x":1666,"y":-558}},{"453":{"val":"qCd","x":941,"y":-1775}},{"454":{"val":"qMd","x":1290,"y":-1277}},{"455":{"val":"Q66","x":1436,"y":-780}},{"456":{"val":"qMd","x":1665,"y":-781}},{"457":{"val":"qEn","x":428,"y":-2174}},{"458":{"val":"qMr","x":511,"y":-1457}},{"459":{"val":"qHd","x":632,"y":-412}},{"460":{"val":"qGb","x":1132,"y":-1868}},{"461":{"val":"qIr","x":2107,"y":-1452}},{"462":{"val":"Q62","x":990,"y":-920}},{"463":{"val":"Q65","x":1474,"y":-1278}},{"464":{"val":"qMu","x":1590,"y":-100}},{"465":{"val":"qH","x":2073,"y":-450}},{"466":{"val":"qMt","x":559,"y":-1068}},{"467":{"val":"qG","x":1551,"y":-1689}},{"468":{"val":"qBd","x":1230,"y":-593}},{"469":{"val":"qCl","x":1699,"y":-973}},{"470":{"val":"qBd","x":1836,"y":-277}},{"471":{"val":"Q27","x":-2042,"y":-914}},{"472":{"val":"Q26","x":-1699,"y":-571}},{"473":{"val":"Q30","x":-1439,"y":-1476}},{"474":{"val":"qMt","x":-1120,"y":-1148}},{"475":{"val":"Q24","x":-857,"y":-698}},{"476":{"val":"qBd","x":-1932,"y":-1750}},{"477":{"val":"qCd","x":-342,"y":-2262}},{"478":{"val":"qGc","x":-2033,"y":-592}},{"479":{"val":"qIr","x":-1685,"y":-250}},{"480":{"val":"qMt","x":-1874,"y":-747}},{"481":{"val":"qMr","x":-1111,"y":-826}},{"482":{"val":"qTg","x":-848,"y":-376}},{"483":{"val":"Q25","x":-1922,"y":-1428}},{"484":{"val":"Q28","x":-333,"y":-1940}},{"485":{"val":"Q23","x":-2022,"y":-365}},{"486":{"val":"qBg","x":-1679,"y":-23}},{"487":{"val":"qGp","x":-1910,"y":-473}},{"488":{"val":"Q21","x":-1100,"y":-599}},{"489":{"val":"qG","x":-837,"y":-149}},{"490":{"val":"qGp","x":-1912,"y":-1201}},{"491":{"val":"qMd","x":-322,"y":-1713}},{"492":{"val":"qGc","x":-1565,"y":-1545}},{"493":{"val":"qEn","x":-1637,"y":-1291}},{"494":{"val":"Q29","x":-1801,"y":-1138}},{"495":{"val":"qBd","x":-462,"y":-1896}},{"496":{"val":"qCl","x":-419,"y":-1683}},{"497":{"val":"qBd","x":-582,"y":-930}},{"498":{"val":"qEn","x":-1054,"y":-2030}},{"499":{"val":"Q22","x":-602,"y":-1479}},{"500":{"val":"qCd","x":-592,"y":-1157}},{"501":{"val":"Cd","x":-2115,"y":-501}},{"502":{"val":"I6","x":-2154,"y":-620}},{"503":{"val":"Mu","x":-2174,"y":-748}},{"504":{"val":"Kh","x":-2169,"y":-882}},{"505":{"val":"I3","x":-1518,"y":-60}},{"506":{"val":"Mr","x":-1532,"y":-187}},{"507":{"val":"Rh","x":-1412,"y":-327}},{"508":{"val":"Ra","x":-1303,"y":-429}},{"509":{"val":"Hd","x":-1819,"y":-1311}},{"510":{"val":"Md","x":-1566,"y":-315}},{"511":{"val":"Bg","x":-1174,"y":-117}},{"512":{"val":"En","x":-1546,"y":-437}},{"513":{"val":"Mt","x":-1528,"y":-567}},{"514":{"val":"I5","x":-1593,"y":-676}},{"515":{"val":"Gp","x":-1814,"y":-216}},{"516":{"val":"Eh","x":-1824,"y":-332}},{"517":{"val":"G","x":-1740,"y":-786}},{"518":{"val":"Gc","x":-1616,"y":-846}},{"519":{"val":"Pt","x":-1904,"y":-911}},{"520":{"val":"I8","x":-2122,"y":-1012}},{"521":{"val":"Cc","x":-2142,"y":-378}},{"522":{"val":"I4","x":-2101,"y":-257}},{"523":{"val":"Pt","x":-2125,"y":-1132}},{"524":{"val":"Ph","x":-2103,"y":-1254}},{"525":{"val":"Pa","x":-2051,"y":-1378}},{"526":{"val":"G","x":-2042,"y":-1511}},{"527":{"val":"Cd","x":-1780,"y":-1787}},{"528":{"val":"Cd","x":-1773,"y":-657}},{"529":{"val":"Cc","x":-1889,"y":-599}},{"530":{"val":"H","x":-1528,"y":-1680}},{"531":{"val":"Mu","x":-1819,"y":-1526}},{"532":{"val":"Md","x":-1588,"y":-1415}},{"533":{"val":"I1","x":-1733,"y":-1416}},{"534":{"val":"Mr","x":-445,"y":-1523}},{"535":{"val":"Ir","x":-1626,"y":-1799}},{"536":{"val":"I2","x":-1153,"y":-453}},{"537":{"val":"Gc","x":-1374,"y":-575}},{"538":{"val":"G","x":-1068,"y":-323}},{"539":{"val":"Gb","x":-1002,"y":-180}},{"540":{"val":"Gp","x":-969,"y":-471}},{"541":{"val":"Tc","x":-715,"y":-222}},{"542":{"val":"Tg","x":-643,"y":-347}},{"543":{"val":"Gp","x":-1243,"y":-644}},{"544":{"val":"Cc","x":-1324,"y":-765}},{"545":{"val":"Gc","x":-1945,"y":-245}},{"546":{"val":"I8","x":-774,"y":-820}},{"547":{"val":"Bd","x":-1984,"y":-810}},{"548":{"val":"Eh","x":-1386,"y":-1055}},{"549":{"val":"Cl","x":-827,"y":-952}},{"550":{"val":"Ea","x":-975,"y":-889}},{"551":{"val":"Kh","x":-1226,"y":-1255}},{"552":{"val":"Mu","x":-1492,"y":-782}},{"553":{"val":"Rh","x":-1904,"y":-1026}},{"554":{"val":"Ra","x":-2005,"y":-1104}},{"555":{"val":"Ea","x":-1525,"y":-1092}},{"556":{"val":"Mr","x":-1509,"y":-1226}},{"557":{"val":"En","x":-1416,"y":-909}},{"558":{"val":"Cd","x":-1257,"y":-880}},{"559":{"val":"Gc","x":-1316,"y":-1350}},{"560":{"val":"I2","x":-1364,"y":-1190}},{"561":{"val":"Bd","x":-1164,"y":-1521}},{"562":{"val":"I3","x":-1298,"y":-1486}},{"563":{"val":"I7","x":-1769,"y":-916}},{"564":{"val":"Gp","x":-1636,"y":-976}},{"565":{"val":"Md","x":-1665,"y":-1114}},{"566":{"val":"Rh","x":-1144,"y":-1376}},{"567":{"val":"Ra","x":-992,"y":-1419}},{"568":{"val":"Gp","x":-1463,"y":-1351}},{"569":{"val":"Ir","x":-1349,"y":-76}},{"570":{"val":"Mt","x":-690,"y":-1869}},{"571":{"val":"Pa","x":-738,"y":-2067}},{"572":{"val":"En","x":-685,"y":-1726}},{"573":{"val":"I7","x":-443,"y":-1202}},{"574":{"val":"I5","x":-593,"y":-1985}},{"575":{"val":"Gp","x":-503,"y":-2093}},{"576":{"val":"Pa","x":-306,"y":-1450}},{"577":{"val":"Pt","x":-217,"y":-1570}},{"578":{"val":"I6","x":-166,"y":-1714}},{"579":{"val":"Gc","x":-343,"y":-2116}},{"580":{"val":"Cd","x":-197,"y":-2018}},{"581":{"val":"Kh","x":-145,"y":-1863}},{"582":{"val":"Cc","x":-122,"y":-2134}},{"583":{"val":"Md","x":-197,"y":-2233}},{"584":{"val":"Ph","x":-501,"y":-2231}},{"585":{"val":"Pt","x":-639,"y":-2174}},{"586":{"val":"Md","x":-571,"y":-1627}},{"587":{"val":"Tc","x":-1822,"y":-7}},{"588":{"val":"G","x":-811,"y":-1653}},{"589":{"val":"G","x":-2036,"y":-147}},{"590":{"val":"Cl","x":-909,"y":-1147}},{"591":{"val":"Mu","x":-1007,"y":-1631}},{"592":{"val":"Cc","x":-475,"y":-795}},{"593":{"val":"H","x":-1193,"y":-1957}},{"594":{"val":"En","x":-1008,"y":-1243}},{"595":{"val":"Mt","x":-980,"y":-1029}},{"596":{"val":"Eh","x":-1394,"y":-1733}},{"597":{"val":"Cl","x":-1995,"y":-1638}},{"598":{"val":"Tg","x":-1915,"y":-107}},{"599":{"val":"Bc","x":-2055,"y":-716}},{"600":{"val":"Kh","x":-895,"y":-2073}},{"601":{"val":"Mu","x":-635,"y":-762}},{"602":{"val":"Bc","x":-1192,"y":-1669}},{"603":{"val":"H","x":-499,"y":-1378}},{"604":{"val":"Eh","x":-690,"y":-1018}},{"605":{"val":"Cd","x":-432,"y":-941}},{"606":{"val":"Kh","x":-383,"y":-1074}},{"607":{"val":"Mr","x":-751,"y":-1168}},{"608":{"val":"Ph","x":-365,"y":-1310}},{"609":{"val":"Kh","x":-1020,"y":-716}},{"610":{"val":"Gc","x":-951,"y":-601}},{"611":{"val":"Gp","x":-1084,"y":-1759}},{"612":{"val":"I4","x":-894,"y":-1528}},{"613":{"val":"Hd","x":-744,"y":-1519}},{"614":{"val":"Ea","x":-1787,"y":-448}},{"615":{"val":"Gc","x":-1036,"y":-1893}},{"616":{"val":"Ea","x":-1344,"y":-1615}},{"617":{"val":"Bd","x":-1304,"y":-1847}},{"618":{"val":"I1","x":-724,"y":-448}},{"619":{"val":"G","x":-598,"y":-541}},{"620":{"val":"En","x":-514,"y":-660}},{"621":{"val":"Ra","x":1779,"y":-1607}},{"622":{"val":"Pt","x":1704,"y":-1483}},{"623":{"val":"Md","x":1398,"y":-1687}},{"624":{"val":"Bd","x":1448,"y":-1546}},{"625":{"val":"I7","x":1514,"y":-1419}},{"626":{"val":"Md","x":1427,"y":-910}},{"627":{"val":"Pa","x":1575,"y":-1164}},{"628":{"val":"Hd","x":1740,"y":-1218}},{"629":{"val":"Cd","x":1626,"y":-1323}},{"630":{"val":"Cc","x":1845,"y":-705}},{"631":{"val":"I1","x":1795,"y":-844}},{"632":{"val":"Hd","x":1665,"y":-222}},{"633":{"val":"Kh","x":1939,"y":-390}},{"634":{"val":"Bd","x":1024,"y":-290}},{"635":{"val":"Pt","x":601,"y":-1703}},{"636":{"val":"H","x":1169,"y":-346}},{"637":{"val":"Cl","x":1229,"y":-462}},{"638":{"val":"Ir","x":1548,"y":-765}},{"639":{"val":"Cd","x":1582,"y":-893}},{"640":{"val":"I6","x":1550,"y":-634}},{"641":{"val":"Kh","x":323,"y":2218}},{"642":{"val":"Bc","x":468,"y":2206}},{"643":{"val":"Md","x":666,"y":-1159}},{"644":{"val":"G","x":1168,"y":-1144}},{"645":{"val":"Cl","x":1316,"y":-1171}},{"646":{"val":"Cc","x":1536,"y":-1001}},{"647":{"val":"G","x":1145,"y":-1513}},{"648":{"val":"Cl","x":1701,"y":-670}},{"649":{"val":"Rh","x":817,"y":-1657}},{"650":{"val":"Pa","x":827,"y":-1799}},{"651":{"val":"Cd","x":1180,"y":-1383}},{"652":{"val":"Cd","x":1288,"y":-755}},{"653":{"val":"Bd","x":1401,"y":-673}},{"654":{"val":"H","x":1684,"y":-359}},{"655":{"val":"Pt","x":1942,"y":-808}},{"656":{"val":"Md","x":1692,"y":-1093}},{"657":{"val":"Kh","x":737,"y":-1907}},{"658":{"val":"I6","x":1669,"y":-1766}},{"659":{"val":"Cl","x":732,"y":-1018}},{"660":{"val":"Bd","x":680,"y":-171}},{"661":{"val":"H","x":736,"y":-41}},{"662":{"val":"Cd","x":1526,"y":39}},{"663":{"val":"Mu","x":1418,"y":129}},{"664":{"val":"Cd","x":2116,"y":-84}},{"665":{"val":"Md","x":2124,"y":55}},{"666":{"val":"H","x":2070,"y":186}},{"667":{"val":"Cd","x":-75,"y":-1535}},{"668":{"val":"Md","x":177,"y":-1577}},{"669":{"val":"Gc","x":-2151,"y":-67}},{"670":{"val":"Bd","x":-2024,"y":23}},{"671":{"val":"Ir","x":175,"y":1699}},{"672":{"val":"Hd","x":59,"y":1616}},{"673":{"val":"Gp","x":-2150,"y":88}},{"674":{"val":"Cd","x":771,"y":-276}},{"776":{"val":"Ay","x":-344,"y":-681}},{"777":{"val":"Ax","x":-236,"y":-587}},{"778":{"val":"Ay","x":362,"y":-723}},{"779":{"val":"Aw","x":250,"y":-633}},{"780":{"val":"Ay","x":219,"y":526}},{"781":{"val":"Ax","x":129,"y":628}},{"782":{"val":"Ay","x":-184,"y":540}},{"783":{"val":"Aw","x":-93,"y":647}}]};
			helpfulAdventurer.levelGraphObject = {"edges":[{"1":[314, 339]}, {"2":[107, 111]}, {"3":[649, 650]}, {"4":[526, 597]}, {"5":[118, 123]}, {"6":[195, 196]}, {"7":[95, 98]}, {"8":[532, 533]}, {"9":[26, 27]}, {"10":[76, 634]}, {"11":[309, 407]}, {"12":[593, 617]}, {"13":[92, 442]}, {"14":[27, 32]}, {"15":[389, 420]}, {"16":[111, 451]}, {"17":[106, 652]}, {"18":[395, 405]}, {"19":[337, 422]}, {"20":[158, 271]}, {"21":[75, 459]}, {"22":[571, 585]}, {"23":[385, 440]}, {"24":[165, 169]}, {"25":[393, 419]}, {"26":[580, 582]}, {"27":[591, 611]}, {"28":[513, 537]}, {"29":[559, 562]}, {"30":[243, 245]}, {"31":[200, 205]}, {"32":[268, 269]}, {"33":[550, 595]}, {"34":[83, 104]}, {"35":[387, 420]}, {"36":[126, 128]}, {"37":[358, 361]}, {"38":[292, 347]}, {"39":[78, 452]}, {"40":[548, 560]}, {"41":[303, 439]}, {"42":[99, 102]}, {"43":[290, 451]}, {"44":[630, 631]}, {"45":[442, 657]}, {"46":[94, 95]}, {"47":[576, 577]}, {"48":[487, 614]}, {"49":[77, 541]}, {"50":[160, 161]}, {"51":[66, 70]}, {"52":[144, 185]}, {"53":[101, 441]}, {"54":[41, 129]}, {"55":[638, 640]}, {"56":[42, 59]}, {"57":[578, 581]}, {"58":[413, 425]}, {"59":[476, 597]}, {"60":[328, 666]}, {"61":[106, 468]}, {"62":[366, 411]}, {"63":[487, 529]}, {"64":[350, 435]}, {"65":[324, 661]}, {"66":[100, 125]}, {"67":[644, 645]}, {"68":[161, 229]}, {"69":[146, 193]}, {"70":[288, 624]}, {"71":[222, 280]}, {"72":[331, 344]}, {"73":[359, 362]}, {"74":[252, 257]}, {"75":[139, 242]}, {"76":[33, 34]}, {"77":[516, 614]}, {"78":[456, 631]}, {"79":[335, 336]}, {"80":[776, 777]}, {"81":[514, 552]}, {"82":[571, 600]}, {"83":[364, 415]}, {"84":[601, 620]}, {"85":[36, 37]}, {"86":[449, 622]}, {"87":[297, 410]}, {"88":[54, 55]}, {"89":[557, 558]}, {"90":[454, 651]}, {"91":[122, 123]}, {"92":[541, 542]}, {"93":[498, 600]}, {"94":[455, 626]}, {"95":[81, 108]}, {"96":[486, 505]}, {"97":[501, 502]}, {"98":[71, 469]}, {"99":[21, 23]}, {"100":[140, 275]}, {"101":[249, 252]}, {"102":[336, 663]}, {"103":[307, 392]}, {"104":[530, 535]}, {"105":[361, 425]}, {"106":[588, 612]}, {"107":[42, 443]}, {"108":[301, 425]}, {"109":[214, 276]}, {"110":[151, 265]}, {"111":[149, 222]}, {"112":[621, 622]}, {"113":[580, 581]}, {"114":[134, 253]}, {"115":[582, 583]}, {"116":[30, 31]}, {"117":[605, 606]}, {"118":[486, 587]}, {"119":[385, 386]}, {"120":[177, 178]}, {"121":[15, 40]}, {"122":[414, 426]}, {"123":[308, 319]}, {"124":[8, 9]}, {"125":[74, 124]}, {"126":[386, 391]}, {"127":[382, 383]}, {"128":[46, 47]}, {"129":[112, 445]}, {"130":[534, 586]}, {"131":[300, 352]}, {"132":[200, 207]}, {"133":[64, 65]}, {"134":[29, 30]}, {"135":[640, 653]}, {"136":[173, 266]}, {"137":[307, 364]}, {"138":[154, 215]}, {"139":[498, 593]}, {"140":[71, 656]}, {"141":[284, 285]}, {"142":[611, 615]}, {"143":[579, 580]}, {"144":[155, 262]}, {"145":[146, 210]}, {"146":[394, 395]}, {"147":[275, 276]}, {"148":[400, 424]}, {"149":[85, 86]}, {"150":[396, 412]}, {"151":[433, 438]}, {"152":[552, 557]}, {"153":[575, 579]}, {"154":[371, 426]}, {"155":[267, 274]}, {"156":[283, 635]}, {"157":[156, 218]}, {"158":[253, 257]}, {"159":[472, 514]}, {"160":[374, 375]}, {"161":[152, 206]}, {"162":[290, 646]}, {"163":[199, 201]}, {"164":[119, 122]}, {"165":[35, 36]}, {"166":[536, 538]}, {"167":[141, 174]}, {"168":[53, 340]}, {"169":[241, 641]}, {"170":[131, 195]}, {"171":[140, 249]}, {"172":[379, 416]}, {"173":[627, 656]}, {"174":[630, 655]}, {"175":[355, 432]}, {"176":[480, 547]}, {"177":[120, 447]}, {"178":[251, 256]}, {"179":[271, 277]}, {"180":[290, 645]}, {"181":[475, 546]}, {"182":[478, 502]}, {"183":[129, 192]}, {"184":[159, 204]}, {"185":[325, 363]}, {"186":[546, 601]}, {"187":[544, 558]}, {"188":[58, 96]}, {"189":[94, 461]}, {"190":[463, 625]}, {"191":[175, 181]}, {"192":[273, 278]}, {"193":[589, 669]}, {"194":[37, 52]}, {"195":[236, 239]}, {"196":[54, 582]}, {"197":[511, 569]}, {"198":[234, 235]}, {"199":[337, 419]}, {"200":[56, 668]}, {"201":[590, 594]}, {"202":[84, 633]}, {"203":[287, 444]}, {"204":[262, 270]}, {"205":[603, 608]}, {"206":[264, 266]}, {"207":[549, 550]}, {"208":[520, 523]}, {"209":[44, 45]}, {"210":[72, 465]}, {"211":[330, 383]}, {"212":[340, 367]}, {"213":[172, 173]}, {"214":[474, 551]}, {"215":[21, 22]}, {"216":[291, 345]}, {"217":[179, 213]}, {"218":[164, 264]}, {"219":[159, 183]}, {"220":[53, 372]}, {"221":[102, 107]}, {"222":[158, 179]}, {"223":[566, 567]}, {"224":[233, 267]}, {"225":[79, 124]}, {"226":[384, 385]}, {"227":[380, 390]}, {"228":[312, 387]}, {"229":[528, 529]}, {"230":[25, 26]}, {"231":[350, 353]}, {"232":[138, 212]}, {"233":[313, 390]}, {"234":[143, 192]}, {"235":[58, 82]}, {"236":[513, 514]}, {"237":[30, 48]}, {"238":[257, 258]}, {"239":[373, 404]}, {"240":[474, 594]}, {"241":[115, 117]}, {"242":[41, 77]}, {"243":[388, 407]}, {"244":[288, 289]}, {"245":[127, 379]}, {"246":[146, 202]}, {"247":[180, 249]}, {"248":[97, 628]}, {"249":[226, 237]}, {"250":[323, 398]}, {"251":[395, 417]}, {"252":[623, 624]}, {"253":[482, 540]}, {"254":[515, 545]}, {"255":[148, 207]}, {"256":[345, 346]}, {"257":[570, 572]}, {"258":[538, 539]}, {"259":[312, 374]}, {"260":[362, 363]}, {"261":[333, 437]}, {"262":[338, 397]}, {"263":[356, 439]}, {"264":[224, 225]}, {"265":[57, 458]}, {"266":[241, 242]}, {"267":[207, 208]}, {"268":[634, 636]}, {"269":[60, 103]}, {"270":[248, 254]}, {"271":[179, 269]}, {"272":[564, 565]}, {"273":[335, 351]}, {"274":[23, 38]}, {"275":[74, 75]}, {"276":[551, 560]}, {"277":[43, 118]}, {"278":[311, 365]}, {"279":[304, 328]}, {"280":[543, 544]}, {"281":[64, 460]}, {"282":[665, 666]}, {"283":[505, 569]}, {"284":[522, 589]}, {"285":[476, 527]}, {"286":[188, 191]}, {"287":[363, 408]}, {"288":[298, 406]}, {"289":[372, 409]}, {"290":[87, 633]}, {"291":[282, 458]}, {"292":[22, 31]}, {"293":[246, 247]}, {"294":[53, 430]}, {"295":[171, 172]}, {"296":[69, 70]}, {"297":[260, 261]}, {"298":[287, 647]}, {"299":[12, 13]}, {"300":[207, 228]}, {"301":[198, 229]}, {"302":[490, 554]}, {"303":[197, 198]}, {"304":[517, 518]}, {"305":[153, 240]}, {"306":[78, 87]}, {"307":[778, 779]}, {"308":[304, 316]}, {"309":[427, 439]}, {"310":[60, 73]}, {"311":[253, 254]}, {"312":[190, 191]}, {"313":[365, 373]}, {"314":[42, 130]}, {"315":[343, 390]}, {"316":[142, 168]}, {"317":[179, 180]}, {"318":[469, 639]}, {"319":[318, 323]}, {"320":[28, 33]}, {"321":[135, 247]}, {"322":[481, 558]}, {"323":[515, 516]}, {"324":[88, 630]}, {"325":[339, 367]}, {"326":[145, 231]}, {"327":[24, 569]}, {"328":[346, 347]}, {"329":[503, 504]}, {"330":[782, 783]}, {"331":[87, 88]}, {"332":[628, 629]}, {"333":[271, 272]}, {"334":[153, 274]}, {"335":[119, 446]}, {"336":[26, 46]}, {"337":[343, 368]}, {"338":[6, 7]}, {"339":[65, 67]}, {"340":[479, 510]}, {"341":[530, 596]}, {"342":[555, 565]}, {"343":[609, 610]}, {"344":[24, 63]}, {"345":[618, 619]}, {"346":[34, 35]}, {"347":[231, 672]}, {"348":[548, 557]}, {"349":[45, 606]}, {"350":[175, 202]}, {"351":[561, 562]}, {"352":[547, 599]}, {"353":[167, 170]}, {"354":[519, 563]}, {"355":[670, 673]}, {"356":[96, 98]}, {"357":[372, 780]}, {"358":[63, 170]}, {"359":[352, 389]}, {"360":[137, 177]}, {"361":[484, 580]}, {"362":[332, 410]}, {"363":[10, 11]}, {"364":[319, 423]}, {"365":[69, 658]}, {"366":[542, 618]}, {"367":[399, 433]}, {"368":[55, 89]}, {"369":[357, 399]}, {"370":[320, 423]}, {"371":[132, 167]}, {"372":[109, 632]}, {"373":[110, 112]}, {"374":[208, 209]}, {"375":[499, 603]}, {"376":[534, 576]}, {"377":[61, 62]}, {"378":[51, 260]}, {"379":[90, 92]}, {"380":[500, 607]}, {"381":[219, 221]}, {"382":[491, 578]}, {"383":[574, 575]}, {"384":[330, 331]}, {"385":[471, 519]}, {"386":[345, 411]}, {"387":[496, 586]}, {"388":[480, 517]}, {"389":[290, 627]}, {"390":[73, 125]}, {"391":[4, 5]}, {"392":[511, 539]}, {"393":[393, 403]}, {"394":[401, 402]}, {"395":[219, 220]}, {"396":[531, 533]}, {"397":[142, 170]}, {"398":[3, 4]}, {"399":[306, 322]}, {"400":[521, 522]}, {"401":[95, 97]}, {"402":[482, 618]}, {"403":[358, 388]}, {"404":[131, 186]}, {"405":[318, 429]}, {"406":[577, 578]}, {"407":[258, 265]}, {"408":[492, 530]}, {"409":[396, 407]}, {"410":[320, 354]}, {"411":[643, 659]}, {"412":[67, 658]}, {"413":[305, 431]}, {"414":[20, 31]}, {"415":[218, 219]}, {"416":[204, 261]}, {"417":[400, 401]}, {"418":[100, 109]}, {"419":[553, 554]}, {"420":[596, 617]}, {"421":[498, 615]}, {"422":[91, 281]}, {"423":[6, 15]}, {"424":[324, 434]}, {"425":[548, 555]}, {"426":[50, 51]}, {"427":[641, 642]}, {"428":[285, 460]}, {"429":[97, 449]}, {"430":[596, 616]}, {"431":[276, 277]}, {"432":[157, 216]}, {"433":[567, 612]}, {"434":[191, 192]}, {"435":[78, 654]}, {"436":[332, 336]}, {"437":[671, 672]}, {"438":[71, 96]}, {"439":[316, 351]}, {"440":[450, 644]}, {"441":[519, 553]}, {"442":[234, 270]}, {"443":[7, 39]}, {"444":[81, 659]}, {"445":[33, 50]}, {"446":[250, 259]}, {"447":[246, 266]}, {"448":[37, 38]}, {"449":[61, 457]}, {"450":[132, 166]}, {"451":[96, 655]}, {"452":[327, 437]}, {"453":[102, 106]}, {"454":[51, 190]}, {"455":[127, 642]}, {"456":[320, 408]}, {"457":[61, 89]}, {"458":[494, 565]}, {"459":[56, 667]}, {"460":[403, 417]}, {"461":[239, 263]}, {"462":[524, 525]}, {"463":[231, 233]}, {"464":[100, 448]}, {"465":[660, 674]}, {"466":[551, 566]}, {"467":[315, 331]}, {"468":[142, 171]}, {"469":[91, 121]}, {"470":[68, 464]}, {"471":[16, 25]}, {"472":[321, 436]}, {"473":[334, 339]}, {"474":[115, 124]}, {"475":[176, 257]}, {"476":[477, 583]}, {"477":[489, 539]}, {"478":[5, 6]}, {"479":[128, 470]}, {"480":[481, 609]}, {"481":[284, 288]}, {"482":[294, 394]}, {"483":[333, 384]}, {"484":[592, 605]}, {"485":[9, 10]}, {"486":[150, 225]}, {"487":[202, 280]}, {"488":[325, 438]}, {"489":[590, 595]}, {"490":[495, 574]}, {"491":[161, 162]}, {"492":[254, 255]}, {"493":[342, 430]}, {"494":[589, 598]}, {"495":[356, 360]}, {"496":[602, 611]}, {"497":[132, 197]}, {"498":[329, 330]}, {"499":[477, 584]}, {"500":[38, 40]}, {"501":[2, 3]}, {"502":[365, 382]}, {"503":[445, 635]}, {"504":[152, 182]}, {"505":[14, 15]}, {"506":[573, 606]}, {"507":[18, 25]}, {"508":[481, 550]}, {"509":[156, 217]}, {"510":[357, 436]}, {"511":[507, 510]}, {"512":[571, 574]}, {"513":[281, 453]}, {"514":[561, 602]}, {"515":[115, 778]}, {"516":[147, 226]}, {"517":[377, 416]}, {"518":[378, 381]}, {"519":[518, 552]}, {"520":[636, 637]}, {"521":[497, 605]}, {"522":[151, 259]}, {"523":[295, 403]}, {"524":[145, 230]}, {"525":[47, 620]}, {"526":[49, 124]}, {"527":[80, 462]}, {"528":[59, 668]}, {"529":[105, 643]}, {"530":[540, 610]}, {"531":[483, 525]}, {"532":[215, 221]}, {"533":[91, 93]}, {"534":[200, 227]}, {"535":[1, 2]}, {"536":[155, 263]}, {"537":[523, 524]}, {"538":[222, 223]}, {"539":[361, 421]}, {"540":[354, 427]}, {"541":[323, 370]}, {"542":[660, 661]}, {"543":[57, 59]}, {"544":[28, 39]}, {"545":[105, 120]}, {"546":[187, 188]}, {"547":[377, 378]}, {"548":[591, 612]}, {"549":[232, 238]}, {"550":[135, 279]}, {"551":[546, 549]}, {"552":[366, 419]}, {"553":[780, 781]}, {"554":[138, 214]}, {"555":[70, 621]}, {"556":[517, 563]}, {"557":[224, 236]}, {"558":[500, 573]}, {"559":[640, 648]}, {"560":[282, 283]}, {"561":[402, 429]}, {"562":[103, 636]}, {"563":[126, 632]}, {"564":[404, 439]}, {"565":[406, 412]}, {"566":[506, 510]}, {"567":[226, 228]}, {"568":[317, 413]}, {"569":[576, 608]}, {"570":[360, 425]}, {"571":[392, 432]}, {"572":[76, 101]}, {"573":[570, 574]}, {"574":[348, 349]}, {"575":[577, 667]}, {"576":[370, 415]}, {"577":[168, 187]}, {"578":[561, 566]}, {"579":[310, 357]}, {"580":[72, 88]}, {"581":[165, 166]}, {"582":[512, 513]}, {"583":[229, 673]}, {"584":[86, 393]}, {"585":[215, 273]}, {"586":[329, 437]}, {"587":[113, 121]}, {"588":[114, 674]}, {"589":[336, 440]}, {"590":[592, 620]}, {"591":[133, 196]}, {"592":[297, 324]}, {"593":[572, 586]}, {"594":[308, 371]}, {"595":[525, 526]}, {"596":[479, 515]}, {"597":[104, 465]}, {"598":[43, 44]}, {"599":[537, 543]}, {"600":[562, 616]}, {"601":[80, 659]}, {"602":[10, 16]}, {"603":[572, 588]}, {"604":[322, 353]}, {"605":[123, 643]}, {"606":[203, 259]}, {"607":[176, 177]}, {"608":[13, 14]}, {"609":[84, 128]}, {"610":[286, 647]}, {"611":[146, 199]}, {"612":[57, 116]}, {"613":[464, 632]}, {"614":[189, 193]}, {"615":[508, 536]}, {"616":[173, 178]}, {"617":[592, 776]}, {"618":[64, 113]}, {"619":[83, 664]}, {"620":[203, 206]}, {"621":[549, 604]}, {"622":[471, 520]}, {"623":[310, 435]}, {"624":[467, 623]}, {"625":[76, 114]}, {"626":[284, 287]}, {"627":[305, 348]}, {"628":[62, 110]}, {"629":[485, 522]}, {"630":[341, 406]}, {"631":[342, 418]}, {"632":[293, 418]}, {"633":[160, 169]}, {"634":[306, 379]}, {"635":[299, 429]}, {"636":[532, 568]}, {"637":[144, 238]}, {"638":[83, 84]}, {"639":[68, 662]}, {"640":[556, 560]}, {"641":[468, 637]}, {"642":[239, 273]}, {"643":[612, 613]}, {"644":[327, 328]}, {"645":[227, 230]}, {"646":[334, 434]}, {"647":[619, 620]}, {"648":[488, 543]}, {"649":[381, 671]}, {"650":[223, 224]}, {"651":[277, 278]}, {"652":[172, 174]}, {"653":[662, 663]}, {"654":[507, 508]}, {"655":[151, 268]}, {"656":[117, 118]}, {"657":[211, 212]}, {"658":[79, 80]}, {"659":[501, 521]}, {"660":[51, 194]}, {"661":[108, 450]}, {"662":[624, 625]}, {"663":[212, 251]}, {"664":[473, 562]}, {"665":[364, 414]}, {"666":[346, 381]}, {"667":[216, 245]}, {"668":[380, 386]}, {"669":[483, 531]}, {"670":[545, 589]}, {"671":[349, 429]}, {"672":[625, 629]}, {"673":[204, 205]}, {"674":[389, 391]}, {"675":[573, 608]}, {"676":[630, 648]}, {"677":[296, 398]}, {"678":[497, 604]}, {"679":[339, 368]}, {"680":[627, 628]}, {"681":[650, 657]}, {"682":[7, 8]}, {"683":[17, 18]}, {"684":[136, 266]}, {"685":[317, 331]}, {"686":[186, 279]}, {"687":[248, 250]}, {"688":[446, 649]}, {"689":[509, 533]}, {"690":[490, 509]}, {"691":[652, 653]}, {"692":[323, 421]}, {"693":[142, 184]}, {"694":[182, 213]}, {"695":[116, 118]}, {"696":[235, 274]}, {"697":[240, 243]}, {"698":[85, 227]}, {"699":[62, 90]}, {"700":[11, 12]}, {"701":[194, 201]}, {"702":[378, 431]}, {"703":[231, 232]}, {"704":[117, 466]}, {"705":[493, 556]}, {"706":[344, 391]}, {"707":[563, 564]}, {"708":[181, 211]}, {"709":[141, 181]}, {"710":[499, 613]}, {"711":[29, 32]}, {"712":[66, 461]}, {"713":[504, 520]}, {"714":[164, 169]}, {"715":[139, 244]}, {"716":[587, 598]}, {"717":[590, 607]}, {"718":[467, 658]}, {"719":[527, 535]}, {"720":[488, 536]}, {"721":[338, 355]}, {"722":[503, 599]}, {"723":[109, 654]}, {"724":[342, 376]}, {"725":[387, 388]}, {"726":[638, 639]}, {"727":[133, 255]}, {"728":[517, 528]}, {"729":[403, 409]}, {"730":[664, 665]}, {"731":[92, 93]}, {"732":[89, 130]}, {"733":[289, 651]}, {"734":[286, 447]}, {"735":[326, 437]}, {"736":[311, 359]}, {"737":[218, 272]}, {"738":[489, 541]}, {"739":[584, 585]}, {"740":[75, 114]}, {"741":[364, 369]}, {"742":[222, 256]}, {"743":[213, 217]}, {"744":[448, 640]}, {"745":[302, 433]}, {"746":[60, 68]}, {"747":[162, 163]}, {"748":[48, 49]}, {"749":[375, 376]}, {"750":[244, 245]}, {"751":[492, 532]}, {"752":[260, 782]}, {"753":[99, 441]}, {"754":[505, 506]}, {"755":[510, 512]}, {"756":[341, 405]}, {"757":[17, 19]}, {"758":[337, 428]}, {"759":[209, 210]}, {"760":[183, 209]}, {"761":[19, 28]}, {"762":[12, 20]}, {"763":[669, 670]}, {"764":[237, 270]}, {"765":[52, 53]}, {"766":[72, 82]}, {"767":[321, 371]}, {"768":[353, 397]}, {"769":[292, 400]}, {"770":[157, 220]}, {"771":[559, 568]}, {"772":[502, 503]}, {"773":[626, 646]}, {"774":[131, 163]}, {"775":[184, 189]}, {"776":[185, 241]}, {"777":[422, 424]}, {"778":[354, 369]}], "nodes":[{"1":{"val":"T1", "x": -54, "y": -23}}, {"2":{"val":"T2", "x":1, "y": -97}}, {"3":{"val":"T3", "x":56, "y": -24}}, {"4":{"val":"T4", "x":1, "y":42}}, {"5":{"val":"T5", "x":1, "y":139}}, {"6":{"val":"A0", "x":1, "y":250}}, {"7":{"val":"A5", "x": -76, "y":150}}, {"8":{"val":"T8", "x": -147, "y":56}}, {"9":{"val":"Au", "x": -147, "y": -43}}, {"10":{"val":"S3", "x": -75, "y": -138}}, {"11":{"val":"T7", "x":2, "y": -237}}, {"12":{"val":"S2", "x":79, "y": -138}}, {"13":{"val":"Av", "x":149, "y": -44}}, {"14":{"val":"T6", "x":149, "y":53}}, {"15":{"val":"Se", "x":79, "y":150}}, {"16":{"val":"Az", "x": -174, "y": -188}}, {"17":{"val":"Se", "x": -358, "y":2}}, {"18":{"val":"S8", "x": -358, "y": -119}}, {"19":{"val":"Sg", "x": -358, "y":118}}, {"20":{"val":"Az", "x":174, "y": -187}}, {"21":{"val":"Sd", "x":361, "y":2}}, {"22":{"val":"S9", "x":361, "y": -118}}, {"23":{"val":"Sf", "x":361, "y":120}}, {"24":{"val":"Gp", "x": -1278, "y":46}}, {"25":{"val":"A2", "x": -265, "y": -231}}, {"26":{"val":"Mt", "x": -178, "y": -335}}, {"27":{"val":"S4", "x": -86, "y": -448}}, {"28":{"val":"A8", "x": -271, "y":237}}, {"29":{"val":"S6", "x":89, "y": -448}}, {"30":{"val":"Cd", "x":184, "y": -334}}, {"31":{"val":"A7", "x":266, "y": -234}}, {"32":{"val":"A6", "x":2, "y": -555}}, {"33":{"val":"G", "x": -189, "y":337}}, {"34":{"val":"S5", "x": -95, "y":444}}, {"35":{"val":"S1", "x":6, "y":551}}, {"36":{"val":"S7", "x":97, "y":440}}, {"37":{"val":"H", "x":185, "y":337}}, {"38":{"val":"A4", "x":262, "y":238}}, {"39":{"val":"Az", "x": -168, "y":193}}, {"40":{"val":"Az", "x":171, "y":192}}, {"41":{"val":"Ir", "x": -582, "y": -41}}, {"42":{"val":"I2", "x":321, "y": -1780}}, {"43":{"val":"Gc", "x":172, "y": -1144}}, {"44":{"val":"Cc", "x": -23, "y": -1119}}, {"45":{"val":"Gp", "x": -216, "y": -1099}}, {"46":{"val":"Bd", "x": -292, "y": -444}}, {"47":{"val":"qMr", "x": -403, "y": -549}}, {"48":{"val":"Cc", "x":299, "y": -444}}, {"49":{"val":"qCd", "x":417, "y": -550}}, {"50":{"val":"Hd", "x": -292, "y":422}}, {"51":{"val":"qG", "x": -403, "y":515}}, {"52":{"val":"Mu", "x":298, "y":424}}, {"53":{"val":"qH", "x":418, "y":515}}, {"54":{"val":"Gc", "x":18, "y": -2110}}, {"55":{"val":"Gp", "x":172, "y": -2085}}, {"56":{"val":"Mr", "x":37, "y": -1637}}, {"57":{"val":"Bd", "x":358, "y": -1474}}, {"58":{"val":"Rh", "x":2095, "y": -869}}, {"59":{"val":"Bc", "x":319, "y": -1620}}, {"60":{"val":"I7", "x":1318, "y": -125}}, {"61":{"val":"Cc", "x":466, "y": -2033}}, {"62":{"val":"I3", "x":594, "y": -2133}}, {"63":{"val":"Gc", "x": -1294, "y":219}}, {"64":{"val":"Bg", "x":1286, "y": -1857}}, {"65":{"val":"Cl", "x":1440, "y": -1874}}, {"66":{"val":"Tg", "x":2008, "y": -1567}}, {"67":{"val":"Gc", "x":1597, "y": -1881}}, {"68":{"val":"H", "x":1448, "y": -71}}, {"69":{"val":"Gb", "x":1817, "y": -1797}}, {"70":{"val":"G", "x":1910, "y": -1667}}, {"71":{"val":"Bc", "x":1834, "y": -1029}}, {"72":{"val":"Mu", "x":2102, "y": -589}}, {"73":{"val":"Mu", "x":1425, "y": -239}}, {"74":{"val":"Mu", "x":661, "y": -581}}, {"75":{"val":"H", "x":764, "y": -472}}, {"76":{"val":"I8", "x":1028, "y": -450}}, {"77":{"val":"Gp", "x": -574, "y": -178}}, {"78":{"val":"I4", "x":1756, "y": -463}}, {"79":{"val":"Pa", "x":678, "y": -784}}, {"80":{"val":"Cc", "x":817, "y": -893}}, {"81":{"val":"Pt", "x":872, "y": -1075}}, {"82":{"val":"Hd", "x":2126, "y": -730}}, {"83":{"val":"H", "x":2132, "y": -221}}, {"84":{"val":"Bd", "x":2000, "y": -271}}, {"85":{"val":"", "x": -51, "y":1147}}, {"86":{"val":"", "x": -8, "y":1011}}, {"87":{"val":"Cd", "x":1886, "y": -513}}, {"88":{"val":"Md", "x":1964, "y": -621}}, {"89":{"val":"Mt", "x":322, "y": -2051}}, {"90":{"val":"G", "x":705, "y": -2233}}, {"91":{"val":"I4", "x":1023, "y": -2038}}, {"92":{"val":"Cl", "x":829, "y": -2150}}, {"93":{"val":"Gp", "x":976, "y": -2161}}, {"94":{"val":"Md", "x":2091, "y": -1310}}, {"95":{"val":"I8", "x":2017, "y": -1189}}, {"96":{"val":"Cd", "x":1956, "y": -948}}, {"97":{"val":"Kh", "x":1880, "y": -1247}}, {"98":{"val":"Md", "x":2049, "y": -1052}}, {"99":{"val":"Md", "x":905, "y": -773}}, {"100":{"val":"Pa", "x":1520, "y": -449}}, {"101":{"val":"Cc", "x":929, "y": -585}}, {"102":{"val":"Hd", "x":1041, "y": -769}}, {"103":{"val":"Kh", "x":1200, "y": -202}}, {"104":{"val":"Bc", "x":2173, "y": -348}}, {"105":{"val":"I3", "x":815, "y": -1221}}, {"106":{"val":"G", "x":1158, "y": -701}}, {"107":{"val":"Ra", "x":1159, "y": -847}}, {"108":{"val":"Cd", "x":988, "y": -1176}}, {"109":{"val":"Ir", "x":1560, "y": -316}}, {"110":{"val":"Md", "x":641, "y": -2008}}, {"111":{"val":"Ph", "x":1272, "y": -923}}, {"112":{"val":"Cd", "x":588, "y": -1876}}, {"113":{"val":"Tc", "x":1278, "y": -1993}}, {"114":{"val":"Bc", "x":879, "y": -370}}, {"115":{"val":"Mr", "x":482, "y": -825}}, {"116":{"val":"Eh", "x":334, "y": -1318}}, {"117":{"val":"Ea", "x":419, "y": -993}}, {"118":{"val":"I1", "x":355, "y": -1153}}, {"119":{"val":"G", "x":767, "y": -1419}}, {"120":{"val":"Cc", "x":903, "y": -1335}}, {"121":{"val":"Ir", "x":1163, "y": -2087}}, {"122":{"val":"Cd", "x":638, "y": -1350}}, {"123":{"val":"Ph", "x":513, "y": -1247}}, {"124":{"val":"Md", "x":537, "y": -669}}, {"125":{"val":"Md", "x":1390, "y": -370}}, {"126":{"val":"Mu", "x":1775, "y": -118}}, {"127":{"val":"Hd", "x":604, "y":2161}}, {"128":{"val":"I5", "x":1911, "y": -169}}, {"129":{"val":"Gc", "x": -686, "y":55}}, {"130":{"val":"En", "x":235, "y": -1915}}, {"131":{"val":"qMt", "x": -2134, "y":613}}, {"132":{"val":"qEn", "x": -1669, "y":151}}, {"133":{"val":"qGp", "x": -2133, "y":971}}, {"134":{"val":"qIr", "x": -2035, "y":1045}}, {"135":{"val":"qGc", "x": -2047, "y":954}}, {"136":{"val":"Q43", "x": -1933, "y":782}}, {"137":{"val":"qHd", "x": -1468, "y":1153}}, {"138":{"val":"qIr", "x": -1315, "y":1274}}, {"139":{"val":"qBd", "x": -13, "y":2339}}, {"140":{"val":"qG", "x": -1535, "y":1405}}, {"141":{"val":"qG", "x": -1387, "y":966}}, {"142":{"val":"Q44", "x": -1284, "y":461}}, {"143":{"val":"qGp", "x": -496, "y":134}}, {"144":{"val":"qH", "x": -9, "y":2049}}, {"145":{"val":"qMu", "x": -142, "y":1549}}, {"146":{"val":"qBg", "x": -816, "y":832}}, {"147":{"val":"qGb", "x": -465, "y":1499}}, {"148":{"val":"qHd", "x": -517, "y":1208}}, {"149":{"val":"Q42", "x": -618, "y":1162}}, {"150":{"val":"qTc", "x": -599, "y":1267}}, {"151":{"val":"Q41", "x": -1967, "y":1664}}, {"152":{"val":"qHd", "x": -1967, "y":1955}}, {"153":{"val":"qBd", "x": -283, "y":2011}}, {"154":{"val":"Q45", "x": -721, "y":1921}}, {"155":{"val":"qTg", "x": -512, "y":1822}}, {"156":{"val":"qG", "x": -1256, "y":2103}}, {"157":{"val":"qHd", "x": -534, "y":2251}}, {"158":{"val":"qGb", "x": -1365, "y":1788}}, {"159":{"val":"qH", "x": -326, "y":818}}, {"160":{"val":"qMr", "x": -1893, "y":377}}, {"161":{"val":"I6", "x": -2028, "y":314}}, {"162":{"val":"Gc", "x": -2162, "y":359}}, {"163":{"val":"Gp", "x": -2177, "y":489}}, {"164":{"val":"G", "x": -1851, "y":572}}, {"165":{"val":"Mt", "x": -1588, "y":406}}, {"166":{"val":"Mr", "x": -1694, "y":281}}, {"167":{"val":"Ea", "x": -1523, "y":219}}, {"168":{"val":"Kh", "x": -1141, "y":399}}, {"169":{"val":"En", "x": -1743, "y":462}}, {"170":{"val":"Eh", "x": -1395, "y":335}}, {"171":{"val":"Gp", "x": -1377, "y":587}}, {"172":{"val":"Gc", "x": -1498, "y":694}}, {"173":{"val":"G", "x": -1634, "y":777}}, {"174":{"val":"Cd", "x": -1424, "y":828}}, {"175":{"val":"Cl", "x": -1075, "y":910}}, {"176":{"val":"Rh", "x": -1701, "y":1220}}, {"177":{"val":"I3", "x": -1626, "y":1080}}, {"178":{"val":"Ra", "x": -1597, "y":920}}, {"179":{"val":"G", "x": -1523, "y":1816}}, {"180":{"val":"Mr", "x": -1576, "y":1670}}, {"181":{"val":"I5", "x": -1228, "y":936}}, {"182":{"val":"Ph", "x": -1785, "y":1951}}, {"183":{"val":"Hd", "x": -455, "y":879}}, {"184":{"val":"Cd", "x": -1172, "y":560}}, {"185":{"val":"Hd", "x":122, "y":2068}}, {"186":{"val":"G", "x": -2008, "y":675}}, {"187":{"val":"Bd", "x": -984, "y":363}}, {"188":{"val":"Bc", "x": -818, "y":339}}, {"189":{"val":"Cc", "x": -1031, "y":616}}, {"190":{"val":"Gp", "x": -526, "y":409}}, {"191":{"val":"Gc", "x": -660, "y":329}}, {"192":{"val":"I8", "x": -635, "y":193}}, {"193":{"val":"Gb", "x": -963, "y":743}}, {"194":{"val":"Ir", "x": -516, "y":619}}, {"195":{"val":"I2", "x": -2187, "y":721}}, {"196":{"val":"Hd", "x": -2180, "y":849}}, {"197":{"val":"Hd", "x": -1822, "y":142}}, {"198":{"val":"Ra", "x": -1968, "y":162}}, {"199":{"val":"Tg", "x": -757, "y":699}}, {"200":{"val":"Ir", "x": -236, "y":1157}}, {"201":{"val":"Tc", "x": -663, "y":590}}, {"202":{"val":"G", "x": -930, "y":930}}, {"203":{"val":"Md", "x": -2147, "y":1755}}, {"204":{"val":"Ea", "x": -200, "y":892}}, {"205":{"val":"Eh", "x": -179, "y":1028}}, {"206":{"val":"Pa", "x": -2088, "y":1879}}, {"207":{"val":"I1", "x": -377, "y":1165}}, {"208":{"val":"Bg", "x": -456, "y":1059}}, {"209":{"val":"G", "x": -566, "y":971}}, {"210":{"val":"Gb", "x": -669, "y":870}}, {"211":{"val":"Hd", "x": -1176, "y":1069}}, {"212":{"val":"G", "x": -1185, "y":1209}}, {"213":{"val":"I7", "x": -1606, "y":1963}}, {"214":{"val":"Ea", "x": -1248, "y":1400}}, {"215":{"val":"G", "x": -863, "y":1901}}, {"216":{"val":"Pa", "x": -395, "y":2305}}, {"217":{"val":"Pt", "x": -1426, "y":2021}}, {"218":{"val":"Cc", "x": -1077, "y":2109}}, {"219":{"val":"Cd", "x": -894, "y":2165}}, {"220":{"val":"Md", "x": -712, "y":2207}}, {"221":{"val":"Bd", "x": -897, "y":2034}}, {"222":{"val":"I2", "x": -759, "y":1137}}, {"223":{"val":"Tg", "x": -776, "y":1264}}, {"224":{"val":"Ir", "x": -794, "y":1393}}, {"225":{"val":"Gb", "x": -639, "y":1392}}, {"226":{"val":"Gp", "x": -353, "y":1422}}, {"227":{"val":"Mu", "x": -136, "y":1269}}, {"228":{"val":"G", "x": -321, "y":1287}}, {"229":{"val":"Rh", "x": -2097, "y":204}}, {"230":{"val":"H", "x": -109, "y":1410}}, {"231":{"val":"I3", "x": -67, "y":1678}}, {"232":{"val":"Bd", "x": -5, "y":1797}}, {"233":{"val":"Ea", "x": -194, "y":1709}}, {"234":{"val":"Gb", "x": -348, "y":1743}}, {"235":{"val":"Bg", "x": -358, "y":1873}}, {"236":{"val":"Bg", "x": -762, "y":1530}}, {"237":{"val":"Gc", "x": -290, "y":1539}}, {"238":{"val":"Bc", "x":45, "y":1928}}, {"239":{"val":"Ra", "x": -747, "y":1672}}, {"240":{"val":"Ph", "x": -427, "y":2033}}, {"241":{"val":"Mu", "x":180, "y":2183}}, {"242":{"val":"H", "x":117, "y":2296}}, {"243":{"val":"Pt", "x": -364, "y":2161}}, {"244":{"val":"Cl", "x": -124, "y":2263}}, {"245":{"val":"I5", "x": -261, "y":2255}}, {"246":{"val":"Tg", "x": -1750, "y":925}}, {"247":{"val":"Tc", "x": -1905, "y":938}}, {"248":{"val":"Gc", "x": -2157, "y":1366}}, {"249":{"val":"En", "x": -1636, "y":1531}}, {"250":{"val":"Gp", "x": -2151, "y":1506}}, {"251":{"val":"Ra", "x": -1046, "y":1166}}, {"252":{"val":"Mt", "x": -1748, "y":1417}}, {"253":{"val":"G", "x": -1942, "y":1178}}, {"254":{"val":"I1", "x": -2102, "y":1248}}, {"255":{"val":"Cd", "x": -2150, "y":1110}}, {"256":{"val":"Rh", "x": -899, "y":1147}}, {"257":{"val":"Hd", "x": -1848, "y":1302}}, {"258":{"val":"Cd", "x": -1962, "y":1385}}, {"259":{"val":"I8", "x": -2116, "y":1634}}, {"260":{"val":"H", "x": -299, "y":632}}, {"261":{"val":"Kh", "x": -197, "y":744}}, {"262":{"val":"Ir", "x": -534, "y":1680}}, {"263":{"val":"Rh", "x": -659, "y":1778}}, {"264":{"val":"Cl", "x": -1725, "y":639}}, {"265":{"val":"Cc", "x": -1944, "y":1528}}, {"266":{"val":"I4", "x": -1785, "y":767}}, {"267":{"val":"Eh", "x": -133, "y":1824}}, {"268":{"val":"Hd", "x": -1825, "y":1714}}, {"269":{"val":"Cl", "x": -1679, "y":1771}}, {"270":{"val":"I4", "x": -404, "y":1626}}, {"271":{"val":"Gp", "x": -1216, "y":1838}}, {"272":{"val":"Gc", "x": -1121, "y":1965}}, {"273":{"val":"Cd", "x": -866, "y":1761}}, {"274":{"val":"H", "x": -227, "y":1905}}, {"275":{"val":"Eh", "x": -1417, "y":1492}}, {"276":{"val":"Kh", "x": -1263, "y":1547}}, {"277":{"val":"I6", "x": -1199, "y":1692}}, {"278":{"val":"Hd", "x": -1034, "y":1731}}, {"279":{"val":"Gb", "x": -2065, "y":809}}, {"280":{"val":"Tc", "x": -817, "y":1015}}, {"281":{"val":"Md", "x":963, "y": -1909}}, {"282":{"val":"Cl", "x":582, "y": -1575}}, {"283":{"val":"Cc", "x":449, "y": -1665}}, {"284":{"val":"Cl", "x":1209, "y": -1652}}, {"285":{"val":"Cd", "x":1094, "y": -1748}}, {"286":{"val":"Md", "x":1028, "y": -1427}}, {"287":{"val":"I5", "x":1057, "y": -1619}}, {"288":{"val":"Pt", "x":1287, "y": -1540}}, {"289":{"val":"Cc", "x":1336, "y": -1415}}, {"290":{"val":"I2", "x":1440, "y": -1086}}, {"291":{"val":"qG", "x":199, "y":1362}}, {"292":{"val":"qHd", "x":478, "y":1499}}, {"293":{"val":"Q81", "x":475, "y":798}}, {"294":{"val":"qH", "x":755, "y":927}}, {"295":{"val":"qBg", "x":60, "y":761}}, {"296":{"val":"Q84", "x":1014, "y":1248}}, {"297":{"val":"qCd", "x":964, "y":149}}, {"298":{"val":"qBd", "x":666, "y":1135}}, {"299":{"val":"qH", "x":870, "y":1369}}, {"300":{"val":"qMu", "x":1142, "y":721}}, {"301":{"val":"qBc", "x":1344, "y":956}}, {"302":{"val":"Q86", "x":1676, "y":1921}}, {"303":{"val":"Q85", "x":1470, "y":1299}}, {"304":{"val":"Q83", "x":1834, "y":309}}, {"305":{"val":"qTg", "x":738, "y":1780}}, {"306":{"val":"qIr", "x":863, "y":2063}}, {"307":{"val":"qH", "x":1300, "y":1529}}, {"308":{"val":"qMu", "x":1439, "y":1805}}, {"309":{"val":"qMu", "x":819, "y":991}}, {"310":{"val":"qBd", "x":1452, "y":2230}}, {"311":{"val":"qHd", "x":2094, "y":1346}}, {"312":{"val":"qH", "x":994, "y":846}}, {"313":{"val":"Q82", "x":984, "y":639}}, {"314":{"val":"qH", "x":980, "y":505}}, {"315":{"val":"qH", "x":1613, "y":903}}, {"316":{"val":"Kh", "x":1844, "y":173}}, {"317":{"val":"Hd", "x":1714, "y":1015}}, {"318":{"val":"Cd", "x":1115, "y":1429}}, {"319":{"val":"H", "x":1585, "y":1797}}, {"320":{"val":"Bc", "x":1782, "y":1641}}, {"321":{"val":"Cl", "x":1415, "y":2001}}, {"322":{"val":"Rh", "x":989, "y":2110}}, {"323":{"val":"I6", "x":1220, "y":1341}}, {"324":{"val":"Ph", "x":836, "y":67}}, {"325":{"val":"Mu", "x":1983, "y":1828}}, {"326":{"val":"qCl", "x":1730, "y":602}}, {"327":{"val":"H", "x":1962, "y":447}}, {"328":{"val":"Cd", "x":1986, "y":306}}, {"329":{"val":"Kh", "x":1921, "y":673}}, {"330":{"val":"Cd", "x":1879, "y":802}}, {"331":{"val":"Mu", "x":1767, "y":888}}, {"332":{"val":"Pa", "x":1262, "y":231}}, {"333":{"val":"Bd", "x":1767, "y":440}}, {"334":{"val":"Md", "x":807, "y":276}}, {"335":{"val":"Cd", "x":1537, "y":231}}, {"336":{"val":"I7", "x":1395, "y":274}}, {"337":{"val":"Ra", "x":235, "y":1181}}, {"338":{"val":"Q88", "x":1155, "y":1932}}, {"339":{"val":"I8", "x":865, "y":411}}, {"340":{"val":"Cd", "x":543, "y":421}}, {"341":{"val":"Cl", "x":454, "y":1189}}, {"342":{"val":"I5", "x":644, "y":667}}, {"343":{"val":"Mu", "x":1139, "y":428}}, {"344":{"val":"En", "x":1686, "y":756}}, {"345":{"val":"I2", "x":187, "y":1500}}, {"346":{"val":"Gp", "x":302, "y":1578}}, {"347":{"val":"Bc", "x":441, "y":1629}}, {"348":{"val":"H", "x":885, "y":1712}}, {"349":{"val":"Bd", "x":990, "y":1601}}, {"350":{"val":"Mu", "x":1201, "y":2228}}, {"351":{"val":"Pt", "x":1684, "y":179}}, {"352":{"val":"Cl", "x":1290, "y":687}}, {"353":{"val":"G", "x":1114, "y":2143}}, {"354":{"val":"I1", "x":1704, "y":1536}}, {"355":{"val":"H", "x":1064, "y":1834}}, {"356":{"val":"Eh", "x":1644, "y":1169}}, {"357":{"val":"Ea", "x":1593, "y":2186}}, {"358":{"val":"Mu", "x":1153, "y":1091}}, {"359":{"val":"G", "x":2125, "y":1474}}, {"360":{"val":"Bd", "x":1505, "y":1162}}, {"361":{"val":"H", "x":1289, "y":1118}}, {"362":{"val":"Cl", "x":2103, "y":1607}}, {"363":{"val":"Kh", "x":2003, "y":1697}}, {"364":{"val":"Kh", "x":1434, "y":1576}}, {"365":{"val":"I5", "x":2040, "y":1211}}, {"366":{"val":"Gb", "x":82, "y":1264}}, {"367":{"val":"Hd", "x":708, "y":404}}, {"368":{"val":"Cl", "x":1030, "y":343}}, {"369":{"val":"Mu", "x":1574, "y":1591}}, {"370":{"val":"H", "x":1354, "y":1390}}, {"371":{"val":"I8", "x":1335, "y":1892}}, {"372":{"val":"G", "x":327, "y":619}}, {"373":{"val":"Mu", "x":1907, "y":1256}}, {"374":{"val":"Cl", "x":846, "y":810}}, {"375":{"val":"Mu", "x":827, "y":671}}, {"376":{"val":"H", "x":741, "y":545}}, {"377":{"val":"Tc", "x":471, "y":1942}}, {"378":{"val":"Rh", "x":428, "y":1800}}, {"379":{"val":"Tg", "x":723, "y":2074}}, {"380":{"val":"H", "x":1277, "y":550}}, {"381":{"val":"Bg", "x":302, "y":1721}}, {"382":{"val":"H", "x":2019, "y":1057}}, {"383":{"val":"Bd", "x":1966, "y":915}}, {"384":{"val":"H", "x":1627, "y":426}}, {"385":{"val":"Mu", "x":1524, "y":497}}, {"386":{"val":"Bc", "x":1426, "y":591}}, {"387":{"val":"Kh", "x":1133, "y":908}}, {"388":{"val":"Cl", "x":1053, "y":1007}}, {"389":{"val":"H", "x":1419, "y":786}}, {"390":{"val":"Bd", "x":1125, "y":570}}, {"391":{"val":"I4", "x":1541, "y":694}}, {"392":{"val":"Hd", "x":1168, "y":1589}}, {"393":{"val":"Tc", "x":135, "y":989}}, {"394":{"val":"Hd", "x":600, "y":942}}, {"395":{"val":"Kh", "x":445, "y":927}}, {"396":{"val":"H", "x":838, "y":1168}}, {"397":{"val":"Bg", "x":1197, "y":2053}}, {"398":{"val":"Mr", "x":1151, "y":1223}}, {"399":{"val":"H", "x":1712, "y":2104}}, {"400":{"val":"I4", "x":592, "y":1414}}, {"401":{"val":"G", "x":704, "y":1495}}, {"402":{"val":"Cl", "x":845, "y":1527}}, {"403":{"val":"I1", "x":166, "y":860}}, {"404":{"val":"Cl", "x":1756, "y":1285}}, {"405":{"val":"Mu", "x":485, "y":1061}}, {"406":{"val":"Mt", "x":578, "y":1239}}, {"407":{"val":"I3", "x":935, "y":1067}}, {"408":{"val":"qH", "x":1907, "y":1604}}, {"409":{"val":"Tg", "x":247, "y":739}}, {"410":{"val":"Cc", "x":1115, "y":168}}, {"411":{"val":"Gc", "x":70, "y":1404}}, {"412":{"val":"Bc", "x":730, "y":1261}}, {"413":{"val":"Cl", "x":1567, "y":1028}}, {"414":{"val":"Hd", "x":1349, "y":1685}}, {"415":{"val":"Bd", "x":1480, "y":1449}}, {"416":{"val":"I3", "x":606, "y":1980}}, {"417":{"val":"H", "x":297, "y":901}}, {"418":{"val":"H", "x":616, "y":795}}, {"419":{"val":"Ir", "x":107, "y":1123}}, {"420":{"val":"G", "x":1267, "y":841}}, {"421":{"val":"Hd", "x":1319, "y":1243}}, {"422":{"val":"Mu", "x":341, "y":1270}}, {"423":{"val":"Hd", "x":1719, "y":1749}}, {"424":{"val":"H", "x":466, "y":1338}}, {"425":{"val":"I2", "x":1419, "y":1063}}, {"426":{"val":"H", "x":1247, "y":1790}}, {"427":{"val":"Cd", "x":1648, "y":1418}}, {"428":{"val":"Q87", "x":329, "y":1080}}, {"429":{"val":"Mu", "x":978, "y":1464}}, {"430":{"val":"Bd", "x":530, "y":592}}, {"431":{"val":"G", "x":588, "y":1817}}, {"432":{"val":"Mu", "x":1091, "y":1698}}, {"433":{"val":"I7", "x":1789, "y":1998}}, {"434":{"val":"H", "x":731, "y":164}}, {"435":{"val":"Kh", "x":1323, "y":2257}}, {"436":{"val":"G", "x":1532, "y":2075}}, {"437":{"val":"I6", "x":1863, "y":543}}, {"438":{"val":"Bd", "x":1897, "y":1925}}, {"439":{"val":"H", "x":1609, "y":1296}}, {"440":{"val":"qHd", "x":1411, "y":407}}, {"441":{"val":"qH", "x":814, "y": -672}}, {"442":{"val":"qBd", "x":808, "y": -2013}}, {"443":{"val":"Q63", "x":471, "y": -1807}}, {"444":{"val":"Q64", "x":940, "y": -1553}}, {"445":{"val":"qBd", "x":714, "y": -1780}}, {"446":{"val":"qMd", "x":719, "y": -1552}}, {"447":{"val":"qCd", "x":1057, "y": -1280}}, {"448":{"val":"qCd", "x":1437, "y": -557}}, {"449":{"val":"qCd", "x":1789, "y": -1365}}, {"450":{"val":"qCl", "x":1060, "y": -1050}}, {"451":{"val":"qCd", "x":1292, "y": -1050}}, {"452":{"val":"Q61", "x":1666, "y": -558}}, {"453":{"val":"qCd", "x":941, "y": -1775}}, {"454":{"val":"qMd", "x":1290, "y": -1277}}, {"455":{"val":"Q66", "x":1436, "y": -780}}, {"456":{"val":"qMd", "x":1665, "y": -781}}, {"457":{"val":"qEn", "x":428, "y": -2174}}, {"458":{"val":"qMr", "x":511, "y": -1457}}, {"459":{"val":"qHd", "x":632, "y": -412}}, {"460":{"val":"qGb", "x":1132, "y": -1868}}, {"461":{"val":"qIr", "x":2107, "y": -1452}}, {"462":{"val":"Q62", "x":990, "y": -920}}, {"463":{"val":"Q65", "x":1474, "y": -1278}}, {"464":{"val":"qMu", "x":1590, "y": -100}}, {"465":{"val":"qH", "x":2073, "y": -450}}, {"466":{"val":"qMt", "x":559, "y": -1068}}, {"467":{"val":"qG", "x":1551, "y": -1689}}, {"468":{"val":"qBd", "x":1230, "y": -593}}, {"469":{"val":"qCl", "x":1699, "y": -973}}, {"470":{"val":"qBd", "x":1836, "y": -277}}, {"471":{"val":"Q27", "x": -2042, "y": -914}}, {"472":{"val":"Q26", "x": -1699, "y": -571}}, {"473":{"val":"Q30", "x": -1439, "y": -1476}}, {"474":{"val":"qMt", "x": -1120, "y": -1148}}, {"475":{"val":"Q24", "x": -857, "y": -698}}, {"476":{"val":"qBd", "x": -1932, "y": -1750}}, {"477":{"val":"qCd", "x": -342, "y": -2262}}, {"478":{"val":"qGc", "x": -2033, "y": -592}}, {"479":{"val":"qIr", "x": -1685, "y": -250}}, {"480":{"val":"qMt", "x": -1874, "y": -747}}, {"481":{"val":"qMr", "x": -1111, "y": -826}}, {"482":{"val":"qTg", "x": -848, "y": -376}}, {"483":{"val":"Q25", "x": -1922, "y": -1428}}, {"484":{"val":"Q28", "x": -333, "y": -1940}}, {"485":{"val":"Q23", "x": -2022, "y": -365}}, {"486":{"val":"qBg", "x": -1679, "y": -23}}, {"487":{"val":"qGp", "x": -1910, "y": -473}}, {"488":{"val":"Q21", "x": -1100, "y": -599}}, {"489":{"val":"qG", "x": -837, "y": -149}}, {"490":{"val":"qGp", "x": -1912, "y": -1201}}, {"491":{"val":"qMd", "x": -322, "y": -1713}}, {"492":{"val":"qGc", "x": -1565, "y": -1545}}, {"493":{"val":"qEn", "x": -1637, "y": -1291}}, {"494":{"val":"Q29", "x": -1801, "y": -1138}}, {"495":{"val":"qBd", "x": -462, "y": -1896}}, {"496":{"val":"qCl", "x": -419, "y": -1683}}, {"497":{"val":"qBd", "x": -582, "y": -930}}, {"498":{"val":"qEn", "x": -1054, "y": -2030}}, {"499":{"val":"Q22", "x": -602, "y": -1479}}, {"500":{"val":"qCd", "x": -592, "y": -1157}}, {"501":{"val":"Cd", "x": -2115, "y": -501}}, {"502":{"val":"I6", "x": -2154, "y": -620}}, {"503":{"val":"Mu", "x": -2174, "y": -748}}, {"504":{"val":"Kh", "x": -2169, "y": -882}}, {"505":{"val":"I3", "x": -1518, "y": -60}}, {"506":{"val":"Mr", "x": -1532, "y": -187}}, {"507":{"val":"Rh", "x": -1412, "y": -327}}, {"508":{"val":"Ra", "x": -1303, "y": -429}}, {"509":{"val":"Hd", "x": -1819, "y": -1311}}, {"510":{"val":"Md", "x": -1566, "y": -315}}, {"511":{"val":"Bg", "x": -1174, "y": -117}}, {"512":{"val":"En", "x": -1546, "y": -437}}, {"513":{"val":"Mt", "x": -1528, "y": -567}}, {"514":{"val":"I5", "x": -1593, "y": -676}}, {"515":{"val":"Gp", "x": -1814, "y": -216}}, {"516":{"val":"Eh", "x": -1824, "y": -332}}, {"517":{"val":"G", "x": -1740, "y": -786}}, {"518":{"val":"Gc", "x": -1616, "y": -846}}, {"519":{"val":"Pt", "x": -1904, "y": -911}}, {"520":{"val":"I8", "x": -2122, "y": -1012}}, {"521":{"val":"Cc", "x": -2142, "y": -378}}, {"522":{"val":"I4", "x": -2101, "y": -257}}, {"523":{"val":"Pt", "x": -2125, "y": -1132}}, {"524":{"val":"Ph", "x": -2103, "y": -1254}}, {"525":{"val":"Pa", "x": -2051, "y": -1378}}, {"526":{"val":"G", "x": -2042, "y": -1511}}, {"527":{"val":"Cd", "x": -1780, "y": -1787}}, {"528":{"val":"Cd", "x": -1773, "y": -657}}, {"529":{"val":"Cc", "x": -1889, "y": -599}}, {"530":{"val":"H", "x": -1528, "y": -1680}}, {"531":{"val":"Mu", "x": -1819, "y": -1526}}, {"532":{"val":"Md", "x": -1588, "y": -1415}}, {"533":{"val":"I1", "x": -1733, "y": -1416}}, {"534":{"val":"Mr", "x": -445, "y": -1523}}, {"535":{"val":"Ir", "x": -1626, "y": -1799}}, {"536":{"val":"I2", "x": -1153, "y": -453}}, {"537":{"val":"Gc", "x": -1374, "y": -575}}, {"538":{"val":"G", "x": -1068, "y": -323}}, {"539":{"val":"Gb", "x": -1002, "y": -180}}, {"540":{"val":"Gp", "x": -969, "y": -471}}, {"541":{"val":"Tc", "x": -715, "y": -222}}, {"542":{"val":"Tg", "x": -643, "y": -347}}, {"543":{"val":"Gp", "x": -1243, "y": -644}}, {"544":{"val":"Cc", "x": -1324, "y": -765}}, {"545":{"val":"Gc", "x": -1945, "y": -245}}, {"546":{"val":"I8", "x": -774, "y": -820}}, {"547":{"val":"Bd", "x": -1984, "y": -810}}, {"548":{"val":"Eh", "x": -1386, "y": -1055}}, {"549":{"val":"Cl", "x": -827, "y": -952}}, {"550":{"val":"Ea", "x": -975, "y": -889}}, {"551":{"val":"Kh", "x": -1226, "y": -1255}}, {"552":{"val":"Mu", "x": -1492, "y": -782}}, {"553":{"val":"Rh", "x": -1904, "y": -1026}}, {"554":{"val":"Ra", "x": -2005, "y": -1104}}, {"555":{"val":"Ea", "x": -1525, "y": -1092}}, {"556":{"val":"Mr", "x": -1509, "y": -1226}}, {"557":{"val":"En", "x": -1416, "y": -909}}, {"558":{"val":"Cd", "x": -1257, "y": -880}}, {"559":{"val":"Gc", "x": -1316, "y": -1350}}, {"560":{"val":"I2", "x": -1364, "y": -1190}}, {"561":{"val":"Bd", "x": -1164, "y": -1521}}, {"562":{"val":"I3", "x": -1298, "y": -1486}}, {"563":{"val":"I7", "x": -1769, "y": -916}}, {"564":{"val":"Gp", "x": -1636, "y": -976}}, {"565":{"val":"Md", "x": -1665, "y": -1114}}, {"566":{"val":"Rh", "x": -1144, "y": -1376}}, {"567":{"val":"Ra", "x": -992, "y": -1419}}, {"568":{"val":"Gp", "x": -1463, "y": -1351}}, {"569":{"val":"Ir", "x": -1349, "y": -76}}, {"570":{"val":"Mt", "x": -690, "y": -1869}}, {"571":{"val":"Pa", "x": -738, "y": -2067}}, {"572":{"val":"En", "x": -685, "y": -1726}}, {"573":{"val":"I7", "x": -443, "y": -1202}}, {"574":{"val":"I5", "x": -593, "y": -1985}}, {"575":{"val":"Gp", "x": -503, "y": -2093}}, {"576":{"val":"Pa", "x": -306, "y": -1450}}, {"577":{"val":"Pt", "x": -217, "y": -1570}}, {"578":{"val":"I6", "x": -166, "y": -1714}}, {"579":{"val":"Gc", "x": -343, "y": -2116}}, {"580":{"val":"Cd", "x": -197, "y": -2018}}, {"581":{"val":"Kh", "x": -145, "y": -1863}}, {"582":{"val":"Cc", "x": -122, "y": -2134}}, {"583":{"val":"Md", "x": -197, "y": -2233}}, {"584":{"val":"Ph", "x": -501, "y": -2231}}, {"585":{"val":"Pt", "x": -639, "y": -2174}}, {"586":{"val":"Md", "x": -571, "y": -1627}}, {"587":{"val":"Tc", "x": -1822, "y": -7}}, {"588":{"val":"G", "x": -811, "y": -1653}}, {"589":{"val":"G", "x": -2036, "y": -147}}, {"590":{"val":"Cl", "x": -909, "y": -1147}}, {"591":{"val":"Mu", "x": -1007, "y": -1631}}, {"592":{"val":"Cc", "x": -475, "y": -795}}, {"593":{"val":"H", "x": -1193, "y": -1957}}, {"594":{"val":"En", "x": -1008, "y": -1243}}, {"595":{"val":"Mt", "x": -980, "y": -1029}}, {"596":{"val":"Eh", "x": -1394, "y": -1733}}, {"597":{"val":"Cl", "x": -1995, "y": -1638}}, {"598":{"val":"Tg", "x": -1915, "y": -107}}, {"599":{"val":"Bc", "x": -2055, "y": -716}}, {"600":{"val":"Kh", "x": -895, "y": -2073}}, {"601":{"val":"Mu", "x": -635, "y": -762}}, {"602":{"val":"Bc", "x": -1192, "y": -1669}}, {"603":{"val":"H", "x": -499, "y": -1378}}, {"604":{"val":"Eh", "x": -690, "y": -1018}}, {"605":{"val":"Cd", "x": -432, "y": -941}}, {"606":{"val":"Kh", "x": -383, "y": -1074}}, {"607":{"val":"Mr", "x": -751, "y": -1168}}, {"608":{"val":"Ph", "x": -365, "y": -1310}}, {"609":{"val":"Kh", "x": -1020, "y": -716}}, {"610":{"val":"Gc", "x": -951, "y": -601}}, {"611":{"val":"Gp", "x": -1084, "y": -1759}}, {"612":{"val":"I4", "x": -894, "y": -1528}}, {"613":{"val":"Hd", "x": -744, "y": -1519}}, {"614":{"val":"Ea", "x": -1787, "y": -448}}, {"615":{"val":"Gc", "x": -1036, "y": -1893}}, {"616":{"val":"Ea", "x": -1344, "y": -1615}}, {"617":{"val":"Bd", "x": -1304, "y": -1847}}, {"618":{"val":"I1", "x": -724, "y": -448}}, {"619":{"val":"G", "x": -598, "y": -541}}, {"620":{"val":"En", "x": -514, "y": -660}}, {"621":{"val":"Ra", "x":1779, "y": -1607}}, {"622":{"val":"Pt", "x":1704, "y": -1483}}, {"623":{"val":"Md", "x":1398, "y": -1687}}, {"624":{"val":"Bd", "x":1448, "y": -1546}}, {"625":{"val":"I7", "x":1514, "y": -1419}}, {"626":{"val":"Md", "x":1427, "y": -910}}, {"627":{"val":"Pa", "x":1575, "y": -1164}}, {"628":{"val":"Hd", "x":1740, "y": -1218}}, {"629":{"val":"Cd", "x":1626, "y": -1323}}, {"630":{"val":"Cc", "x":1845, "y": -705}}, {"631":{"val":"I1", "x":1795, "y": -844}}, {"632":{"val":"Hd", "x":1665, "y": -222}}, {"633":{"val":"Kh", "x":1939, "y": -390}}, {"634":{"val":"Bd", "x":1024, "y": -290}}, {"635":{"val":"Pt", "x":601, "y": -1703}}, {"636":{"val":"H", "x":1169, "y": -346}}, {"637":{"val":"Cl", "x":1229, "y": -462}}, {"638":{"val":"Ir", "x":1548, "y": -765}}, {"639":{"val":"Cd", "x":1582, "y": -893}}, {"640":{"val":"I6", "x":1550, "y": -634}}, {"641":{"val":"Kh", "x":323, "y":2218}}, {"642":{"val":"Bc", "x":468, "y":2206}}, {"643":{"val":"Md", "x":666, "y": -1159}}, {"644":{"val":"G", "x":1168, "y": -1144}}, {"645":{"val":"Cl", "x":1316, "y": -1171}}, {"646":{"val":"Cc", "x":1536, "y": -1001}}, {"647":{"val":"G", "x":1145, "y": -1513}}, {"648":{"val":"Cl", "x":1701, "y": -670}}, {"649":{"val":"Rh", "x":817, "y": -1657}}, {"650":{"val":"Pa", "x":827, "y": -1799}}, {"651":{"val":"Cd", "x":1180, "y": -1383}}, {"652":{"val":"Cd", "x":1288, "y": -755}}, {"653":{"val":"Bd", "x":1401, "y": -673}}, {"654":{"val":"H", "x":1684, "y": -359}}, {"655":{"val":"Pt", "x":1942, "y": -808}}, {"656":{"val":"Md", "x":1692, "y": -1093}}, {"657":{"val":"Kh", "x":737, "y": -1907}}, {"658":{"val":"I6", "x":1669, "y": -1766}}, {"659":{"val":"Cl", "x":732, "y": -1018}}, {"660":{"val":"Bd", "x":680, "y": -171}}, {"661":{"val":"H", "x":736, "y": -41}}, {"662":{"val":"Cd", "x":1526, "y":39}}, {"663":{"val":"Mu", "x":1418, "y":129}}, {"664":{"val":"Cd", "x":2116, "y": -84}}, {"665":{"val":"Md", "x":2124, "y":55}}, {"666":{"val":"H", "x":2070, "y":186}}, {"667":{"val":"Cd", "x": -75, "y": -1535}}, {"668":{"val":"Md", "x":177, "y": -1577}}, {"669":{"val":"Gc", "x": -2151, "y": -67}}, {"670":{"val":"Bd", "x": -2024, "y":23}}, {"671":{"val":"Ir", "x":175, "y":1699}}, {"672":{"val":"Hd", "x":59, "y":1616}}, {"673":{"val":"Gp", "x": -2150, "y":88}}, {"674":{"val":"Cd", "x":771, "y": -276}}, {"776":{"val":"Ay", "x": -344, "y": -681}}, {"777":{"val":"Ax", "x": -236, "y": -587}}, {"778":{"val":"Ay", "x":362, "y": -723}}, {"779":{"val":"Aw", "x":250, "y": -633}}, {"780":{"val":"Ay", "x":219, "y":526}}, {"781":{"val":"Ax", "x":129, "y":628}}, {"782":{"val":"Ay", "x": -184, "y":540}}, {"783":{"val":"Aw", "x": -93, "y":647}}]};
			
			helpfulAdventurer.levelGraph = LevelGraph.loadGraph(helpfulAdventurer.levelGraphObject, helpfulAdventurer);
			
			helpfulAdventurer.name = "Helpful Adventurer";
			helpfulAdventurer.flavorName = "Cid";
			helpfulAdventurer.flavorClass = "The Helpful Adventurer";
			helpfulAdventurer.flavor = "A character who uses her energy to empower rapid click attacks.";
			helpfulAdventurer.gender = "female";
			helpfulAdventurer.flair = "";
			helpfulAdventurer.characterSelectOrder = 1;
			helpfulAdventurer.availableForCreation = true;
			helpfulAdventurer.visibleOnCharacterSelect = true;
			helpfulAdventurer.defaultSaveName = "helpful_adventurer";
			helpfulAdventurer.baseOutfitId = 1;
			helpfulAdventurer.startingSkills = [];
			helpfulAdventurer.recommendedLevelsForWorlds = { "1": 0, "2": 15, "3": 30 };
			
			helpfulAdventurer.talentChoices = [
				["MultiClick"],
//				["BlitzClick"],
				["Energize"],
				["Big Clicks"],
				["Huge Click"],
				[ "Quick Recovery", "Powerful Strikes"],
				["Clickstorm"],
				[ "Energize: Extend", "Energize: Rush"],
				[ "Clickdrizzle", "Clicktorrent" ],
				["Power Surge"],
				[ "Quicker Recovery", "Metal Detector"],
				["Reload"],
				["Mana Crit"]
			];
			helpfulAdventurer.talentZones = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 60, 70, 80, 90];
			helpfulAdventurer.upgradeableStats = Character.DEFAULT_UPGRADEABLE_STATS;
			helpfulAdventurer.onCharacterDisplayCreated = null;
			
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
			tripleClick.useTutorialArrow = true;
			tripleClick.tooltipFunction = function():Object{ return this.skillTooltip("Clicks " + Math.ceil((5 + CH2.currentCharacter.getTrait("ExtraMulticlicks")) * (CH2.currentCharacter.getTrait("Flurry") ? CH2.currentCharacter.hasteRating : 1))  + " times."); };
			
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
			bigClicks.useTutorialArrow = true;
			bigClicks.tooltipFunction = function():Object { 
				var character:Character = CH2.currentCharacter;
				var clicks:int = 6 + character.getTrait("BigClickStacks")
				var damage:Number = 3 * (Math.pow(1.25, character.getTrait("BigClicksDamage"))) * 100;
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
			energize.useTutorialArrow = true;
			energize.tooltipFunction = function():Object { 
				var character:Character = CH2.currentCharacter;
				var duration:Number = 60;
				duration += 60 * (0.2 * character.getTrait("ImprovedEnergize"));
				return this.skillTooltip("Restores 2 energy per second for " + duration.toFixed(0) + " seconds."); };
			
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
			managize.useTutorialArrow = true;
			managize.tooltipFunction = function():Object{ return this.skillTooltip("Restores 25% of your maximum mana."); };
			
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
				var reloadAmount:Number = (10 * (1 + character.getTrait("ImprovedReload")));
				if (character.getTrait("SmallReloads"))
				{
					reloadAmount *= 0.1;
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
				var duration:Number = 60 * Math.pow(1.2, character.getTrait("SustainedPowersurge"));
				var damage:Number = (1 + Math.pow(1.25, character.getTrait("ImprovedPowersurge"))) * 100;
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
			
			var clickdrizzle:Skill = new Skill();
			clickdrizzle.modName = MOD_INFO["name"];
			clickdrizzle.name = "Clickdrizzle";
			clickdrizzle.description = "";
			clickdrizzle.cooldown = CLICKSTORM_BASE_COOLDOWN;
			clickdrizzle.iconId = 201;
			clickdrizzle.manaCost = 0;
			clickdrizzle.energyCost = 0;
			clickdrizzle.consumableOnly = false;
			clickdrizzle.minimumAscensions = 0;
			clickdrizzle.effectFunction = clickdrizzleEffect;
			clickdrizzle.ignoresGCD = false;
			clickdrizzle.maximumRange = 9000;
			clickdrizzle.minimumRange = 0;
			clickdrizzle.usesMaxEnergy = false;
			clickdrizzle.tooltipFunction = function():Object{ return this.skillTooltip("Consumes energy to click 5 times per second."); };
			Character.staticSkillInstances[clickdrizzle.uid] = clickdrizzle;
			
			Talent.talents["Clicktorrent"] = {
				"iconId": 202,
				"applyFunction": applyClickTorrentTalent,
				"tooltipFunction": clickTorrentTooltip
			};
			
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
			CH2.currentCharacter.automator.addCooldownStone(CHARACTER_NAME+"_21", 4000);
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_23", "Perform a click", 1, "Performs a single click.", onClickActivate, function():Boolean{ return true; }, 250);
		}
		
		private function purchaseAutomator():void
		{
			CH2.currentCharacter.onAutomatorUnlocked();
			CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_16");
			CH2.currentCharacter.automator.unlockStone(CHARACTER_NAME+"_21");
			CH2.currentCharacter.automator.unlockGem(CHARACTER_NAME+"_23");
		}
		
		private function onClickActivate():Boolean
		{
			CH2.world.onWorldClick();
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
		
		private function addUpgradeFirstAffordableItemGem():void 
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_6", "Upgrade First Affordable Item", 94, "Buys the first item upgrade you can afford.", onUpgradeFirstAffordableItemGemActivate, canUpgradeFirstAffordableItem, 500);
		}
		
		private function addAttemptBossGem():void 
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_10", "Attempt Boss", 162, "If you can attempt the boss, automatically progress to the boss zone.", onAttemptBossGemActivate, canAttemptBoss);
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
					var healthPercent:Number = (monster.health / monster.maxHealth);
					if (healthPercent > 0.5)
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
					var healthPercent:Number = (monster.health / monster.maxHealth);
					if (healthPercent < 0.5)
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
		
		private function addNextSetGem():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_21", "Next Set", 158, "Switches the automator to the next set", onNextSetGemActivate, canActivateNextSetGem);
		}
		
		public function canActivateNextSetGem():Boolean
		{
			return (CH2.currentCharacter.automator.currentQueueIndex < CH2.currentCharacter.automator.numSetsUnlocked);
		}
		
		public function onNextSetGemActivate():Boolean
		{
			if (canActivateNextSetGem())
			{
				var currentQueueIndex:int = CH2.currentCharacter.automator.currentQueueIndex;
				CH2.currentCharacter.automator.setCurrentQueue(currentQueueIndex + 1);
				if (IdleHeroUIManager.instance.mainUI && IdleHeroUIManager.instance.mainUI.mainPanel && IdleHeroUIManager.instance.mainUI.mainPanel.isOnAutomatorPanel)
				{
					IdleHeroUIManager.instance.mainUI.mainPanel.refreshOpenTab();
				}
				return true;
			}
			return false;
		}
		
		private function addPreviousSetGem():void
		{
			CH2.currentCharacter.automator.addGem(CHARACTER_NAME+"_22", "Previous Set", 158, "Switches the automator to the previous set", onPreviousSetGemActivate, canActivatePreviousSetGem);
		}
		
		public function canActivatePreviousSetGem():Boolean
		{
			return (CH2.currentCharacter.automator.currentQueueIndex > 1);
		}
		
		public function onPreviousSetGemActivate():Boolean
		{
			if (canActivatePreviousSetGem())
			{
				var currentQueueIndex:int = CH2.currentCharacter.automator.currentQueueIndex;
				CH2.currentCharacter.automator.setCurrentQueue(currentQueueIndex - 1);
				if (IdleHeroUIManager.instance.mainUI && IdleHeroUIManager.instance.mainUI.mainPanel && IdleHeroUIManager.instance.mainUI.mainPanel.isOnAutomatorPanel)
				{
					IdleHeroUIManager.instance.mainUI.mainPanel.refreshOpenTab();
				}
				return true;
			}
			return false;
		}
		
		// ******************** GRAPH STUFF THAT NEEDS NAMES/NODES ******************************
		public function applyManaCritFromCritsTalent():void
		{
			var buff:Buff = new Buff();
			buff.iconId = 21;
			buff.isUntimedBuff = true;
			buff.name = "Mana Crit From Crits";
			buff.onCrit = function(attackData:AttackData)
			{
				var manaCrit:Skill = CH2.currentCharacter.getSkill("Mana Crit");
				manaCrit.cooldownRemaining -= 1000;
			}
			CH2.currentCharacter.buffs.addBuff(buff);
		}
		
		public function applyCritChanceFromNonCritsTalent():void
		{
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
			CH2.currentCharacter.buffs.addBuff(buff);
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
		
		public function helpfulAdventurerCanUseSkill(skill:Skill):Boolean
		{
			var character:Character = CH2.currentCharacter;
			if (character.buffs.hasBuffByName("Curse Of The Juggernaut"))
			{
				var juggernautBuff:Buff = character.buffs.getBuff("Curse Of The Juggernaut");
				return (character.canUseSkillDefault(skill) && (character.energy >= (skill.energyCost + juggernautBuff.stacks)));
			}
			else
			{
				return CH2.currentCharacter.canUseSkillDefault(skill);
			}
		}
		
		public function helpfulAdventurerOnKilledMonster(monster:Monster):void
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.getTrait("KillingFrenzy"))
			{
				
				if (character.buffs.hasBuffByName("Killing Frenzy")) {
					var killingFrenzy:Buff = character.buffs.getBuff("Killing Frenzy");
					killingFrenzy.duration = 5000;
					killingFrenzy.buffStat(CH2.STAT_HASTE, 1.5);
				}
				else
				{
					var buff:Buff = new Buff();
					buff.name = "Killing Frenzy";
					buff.iconId = 23;
					buff.tooltipFunction = function() {
						return {
							"header": "Killing Frenzy",
							"body": "Increases haste by " + buff.getStatValue(CH2.STAT_HASTE) * 100 + "%. Reduced by 10% per second."
						};
					}
					buff.buffStat(CH2.STAT_HASTE, 1.5);
					buff.tickRate = 1000;
					buff.duration = 5000;
					buff.tickFunction = function() {
						buff.buffStat(CH2.STAT_HASTE, buff.getStatValue(CH2.STAT_HASTE) - 0.1);
					}
				
					character.buffs.addBuff(buff);
				}
			}
			
			character.onKilledMonsterDefault(monster);
		}
		
		public function helpfulAdventurerAttack(attackData:AttackData):void
		{
			if (CH2.currentCharacter.getTrait("LowEnergyDamageBonus") && CH2.currentCharacter.energy < CH2.currentCharacter.maxEnergy * 0.60)
			{
				attackData.damage.timesEqualsN(2);
			}
			
			var monsterHealth:BigNumber;
			
			if (CH2.currentCharacter.getTrait("ManaCritOverflow"))
			{
				var target:Monster = CH2.world.getNextMonster();
				if (target)
				{
					monsterHealth = target.health;
				}
			}
			
			CH2.currentCharacter.attackDefault(attackData);
			
			if (attackData.isAutoAttack && attackData.isCritical && CH2.currentCharacter.getTrait("AutoAttackCritMana"))
			{
				CH2.currentCharacter.addMana(1);
			}
			
			if (attackData.isCritical && CH2.currentCharacter.getTrait("BhaalsRise"))
			{
				var manaCrit:Skill = CH2.currentCharacter.getSkill("Mana Crit");
				if (manaCrit)
				{	
					manaCrit.cooldownRemaining -= 1000;
				}
			}
			
			if (attackData.isKillShot && attackData.isCritical && CH2.currentCharacter.getTrait("CritKillPowerSurgeCooldown"))
			{
				var powerSurge:Skill = CH2.currentCharacter.getSkill("Power Surge");
				if (powerSurge)
				{
					powerSurge.cooldownRemaining -= 5000;
				}
			}
			
			if (attackData.isKillShot && (CH2.currentCharacter.buffs.getBuff("Mana Crit") != null) && CH2.currentCharacter.getTrait("ManaCritOverflow"))
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
		
		public function helpfulAdventurerZoneChanged(zoneNumber:int):void
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.buffs.hasBuffByName("Alacrity"))
			{
				character.buffs.removeBuff("Alacrity");
			}
			
			character.onZoneChangedDefault(zoneNumber);
		}
		
		public function helpfulAdventurerAddGold(goldToAdd:BigNumber):void
		{
			if (CH2.currentCharacter.getTrait("HighEnergyGoldBonus") && CH2.currentCharacter.energy > 0.40 * CH2.currentCharacter.maxEnergy)
			{
				goldToAdd.timesEqualsN(2);
			}
			CH2.currentCharacter.addGoldDefault(goldToAdd);
		}
		
		public function helpfulAdventurerAddEnergy(amount:Number, showFloatingText:Boolean = true):void
		{
			var character:Character = CH2.currentCharacter;
			if (amount < 0)
			{
				if (character.getTrait("Discharge"))
				{
					var target:Monster = CH2.world.getNextMonster();
					if (target && (Math.abs(target.y - CH2.currentCharacter.y) < 2000))
					{
						var attackData:AttackData = new AttackData();
						attackData.damage = character.clickDamage.multiplyN(Math.abs(amount));
						attackData.isCritical = false;
						attackData.monster = target;
						target.takeDamage(attackData);
					}
				}
			}
			
			character.addEnergyDefault(amount, showFloatingText);
		}
		
		public function helpfulAdventurerAddMana(amount:Number, showFloatingText:Boolean = true):void
		{
			var character:Character = CH2.currentCharacter;
			if (amount < 0)
			{
				if (character.getTrait("SpendManaHaste"))
				{
					var buff:Buff = new Buff();
					buff.name = "SpendManaHaste";
					buff.iconId = 23;
					buff.isUntimedBuff = false;
					buff.duration = 5000;
					buff.tooltipFunction = function() {
						return {
							"header": "Gift of Chronos",
							"body": "Increases haste by " + buff.getStatValue(CH2.STAT_HASTE) * 100 + "%."
						};
					}
					buff.buffStat(CH2.STAT_HASTE, 1 + (-amount / 100));
					character.buffs.addBuff(buff);
					
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
		
		public function applyClickDrizzleTalent():void
		{
			var clickstorm:Skill = CH2.currentCharacter.getSkill("Clickstorm");
			CH2.currentCharacter.replaceSkill(clickstorm.uid, CH2.currentCharacter.getStaticSkill("Clickdrizzle"));
		}
		
		public function applyClickTorrentTalent():void
		{
			var clickstorm:Skill = CH2.currentCharacter.getSkill("Clickstorm");
			CH2.currentCharacter.replaceSkill(clickstorm.uid, CH2.currentCharacter.getStaticSkill("Clicktorrent"));
		}
		
		public function clickDrizzleTooltip():Object 
		{
			return {
				"header": "Clickdrizzle",
				"body": "Replaces Clickstorm. Clicks fewer times per second but lasts significantly longer."
			};
		}
		
		public function clickTorrentTooltip():Object
		{
			return {
				"header": "Clicktorrent",
				"body": "Replaces Clickstorm. Clicks much faster but does not last as long."
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
		
		public function multiClickEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			var buffClicks:int = 4 + character.getTrait("ExtraMulticlicks");
			if (character.getTrait("Flurry"))
			{
				buffClicks = (buffClicks + 1) * character.hasteRating - 1;
			}
			buff.name = "MultiClick";
			buff.duration = 800;
			buff.tickRate = buff.duration / buffClicks;
			buff.tickFunction = function() {
				character.clickAttack(false);
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
				character.addEnergy(-(1/3), false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Clicktorrent",
					"body": "Clicking 30 times per second. Consuming 10 energy per second."
				};
			}
			character.buffs.addBuff(buff);
		}
		
		public function clickdrizzleEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.name = "Clickdrizzle";
			buff.iconId = 201;
			buff.isUntimedBuff = true;
			buff.tickRate = 200;
			buff.tickFunction = function() {
				character.clickAttack(false);
				character.addEnergy( -0.333, false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Clickdrizzle",
					"body": "Clicking 5 times per second."
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
			buff.tickRate = 400;
			buff.tickFunction = function() {
				character.clickAttack(false);
				character.addEnergy(-0.5, false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Clickstorm",
					"body": "Clicking 2.5 times per second. Consuming 1.25 energy per second."
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
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Critstorm",
					"body": "Critting 2.5 times per second. Consuming 1.25 energy per second."
				};
			}
			character.buffs.addBuff(buff);
		}
		
		public function goldenClicksEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.name = "GoldenClicks";
			buff.iconId = 201;
			buff.isUntimedBuff = true;
			buff.tickRate = 400;
			buff.tickFunction = function() {
				character.clickAttack(false);
				character.addEnergy(-0.5, false);
				if (character.energy <= 0) {
					buff.isFinished = true;
					buff.onFinish();
				}
			}
			buff.buffStat(CH2.STAT_GOLD, 2.0);
			buff.tooltipFunction = function() {
				return {
					"header": "Golden Clicks",
					"body": "Clicking 2.5 times per second. Gold gained increased by 100%. Consuming 1.25 energy per second."
				};
			}
			character.buffs.addBuff(buff);
		}
		
		public function autoAttackstormEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var buff:Buff = new Buff();
			buff.name = "Autoattackstorm";
			buff.iconId = 201;
			buff.isUntimedBuff = true;
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
			}
			buff.tooltipFunction = function() {
				return {
					"header": "Autoattackstorm",
					"body": "Autoattacking 2.5 times per second. Consuming 1.25 mana per second."
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
					"body": "Restoring 2 energy per second."
				};
			}
			character.buffs.addBuff(buff);
			addEnergizeIndicator();
		}
		
		public function managizeEffect():void
		{
			var character:Character = CH2.currentCharacter;
			character.addMana(character.maxMana * 0.25);
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
			var reloadBonus:Number = 0.1 * (1 + character.getTrait("ImprovedReload"));
			var energyRestored:Number = character.maxEnergy * reloadBonus;
			var manaRestored:Number = character.maxMana * reloadBonus;
			if (character.getTrait("SmallReloads"))
			{
				energyRestored *= 0.1;
				manaRestored *= 0.1;
			}
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
				buff.iconId = 35;
				buff.isUntimedBuff = true;
				buff.skillUseFunction = function(skill:Skill) {
					skill.cooldownRemaining = skill.cooldown * 0.5;
					buff.isFinished = true;
					buff.onFinish();
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
				if (character.getTrait("DistributedBigClickScaling"))
				{
					stacksPerUse *= character.hasteRating;
				}
			}
			
			if (character.getTrait("UnlimitedBigClicks") && character.buffs.hasBuffByName("Big Clicks"))
			{
				var buff:Buff = character.buffs.getBuff("Big Clicks");
				trace("Unlimited Big Clicks");
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
							SoundManager.instance.playSound("Big Click Hits");
							var effect:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(BIG_CLICK);
							effect.gotoAndPlay(Rnd.integer(1,8));
							effect.isLooping = false;
							effect.rotation = Math.PI * Rnd.float( -0.13, 0.13);
							if (effect.rotation > 0)
							{
								effect.scaleX = -1;
							}
							CH2.world.addEffect(effect, CH2.world.roomsFront, attackDatas[0].monster.x, attackDatas[0].monster.y);
							CH2.world.camera.shake(0.5, -25, 25);
						}
						
						buff.stacks--;
						if (buff.stacks < 100)
						{
							removeSingleBigClicksIndicator(buff.stacks);
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
						CH2.currentCharacter.addEnergy(-juggernautBuff.stacks);
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
			addBigClicksIndicators();
		}
		
		public function powerSurgeEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var damage:Number = 1 + Math.pow(1.25, character.getTrait("ImprovedPowersurge"));
			var buff:Buff = new Buff();
			buff.name = "Power Surge";
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
					"header": "Power Surge",
					"body": "Your clicks deal " + (damage * 100).toFixed(2) + "% damage."
				};
			}
			buff.buffStat(CH2.STAT_CLICK_DAMAGE, damage);
			
			if (character.getTrait("PowerSurgeCritChance"))
			{
				buff.tickRate = 1000;
				buff.buffStat(CH2.STAT_CRIT_CHANCE, -1.0);
				buff.tickFunction = function() {
					buff.buffStat(CH2.STAT_CRIT_CHANCE, buff.getStatValue(CH2.STAT_CRIT_CHANCE) + 0.05);
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
	//						discountBuff.buffStat(CH2.STAT_ITEM_COST_REDUCTION, 0.005 * 10.00 * (Math.pow(1.25, character.getTrait("HugeClickDamage"))));
							discountBuff.buffStat(CH2.STAT_ITEM_COST_REDUCTION, CH2.currentCharacter.itemCostReductionRating / (1 + (0.005 * 10.00 * (Math.pow(1.25, character.getTrait("HugeClickDamage"))))));
							discountBuff.tooltipFunction = function() {
								return {
									"header": "Huge Click Discount",
									"body": "Item costs reduced by an additional " + 0.005 * 10.00 * (Math.pow(1.25, character.getTrait("HugeClickDamage"))) * 100 + "%."
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
				CH2.world.addEffect(indicatorAsset, CH2.world.roomsFront, bigClicksIndicators[num].worldX, bigClicksIndicators[num].worldY);
				
				CH2.currentCharacter.characterDisplay.characterUI.removeUIElement(bigClicksIndicators[num]);
				bigClicksIndicators[num] = null;
			}
		}
		
		public function addEnergizeIndicator():void
		{
			if (!energizeIndicator.type)
			{
				energizeIndicator.active = true;
				energizeIndicator.name = "Energize_Indicator";
				energizeIndicator.addChild(CH2AssetManager.instance.getGpuMovieClip(ENERGY_CHARGE));
				energizeIndicator.type = CharacterDisplayUI.OTHER_ELEMENT;
				energizeIndicator.x = 0;
				energizeIndicator.y = 0;
			}
			
			if (!CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(energizeIndicator.name))
			{
				CH2.currentCharacter.characterDisplay.characterUI.addUIElement(energizeIndicator, CH2.currentCharacter.characterDisplay.characterUI.frontCharacterDisplay);
			}
		}
		
		public function removeEnergizeIndicator():void
		{
			if (CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(energizeIndicator.name))
			{
				CH2.currentCharacter.characterDisplay.characterUI.removeUIElement(energizeIndicator);
			}
		}
		
		public function getBamplode(num:int):GpuMovieClip
		{
			return CH2AssetManager.instance.getGpuMovieClip("HelpfulAdventurer_bamplode"+num);
		}
		
		public function onStaticDataLoaded():void
		{
			
		}
		
		public function onUserDataLoaded():void
		{
			
		}
		
		public function onCharacterLoaded():void
		{
			// I have no idea whether these functions ever existed but loading characters was failing because they currently do not.
			// Only manual loads had this problem, not automatic character loads when game is launched, which is also concerning.
			//applyClickstormCooldownReduction();
			//applyEnergizeCostReduction();
		}
		
		public function onCharacterCreated(characterInstance:Character):void
		{
			characterInstance.onCharacterDisplayCreated = setUpDisplay;
			characterInstance.autoAttack = autoAttack;
			characterInstance.clickAttack = clickAttack;
			characterInstance.onCharacterLoaded = onCharacterLoaded;
			
			characterInstance.attack = helpfulAdventurerAttack;
			characterInstance.onKilledMonster = helpfulAdventurerOnKilledMonster;
			characterInstance.addGold = helpfulAdventurerAddGold;
			characterInstance.addEnergy = helpfulAdventurerAddEnergy;
			characterInstance.canUseSkill = helpfulAdventurerCanUseSkill;
			characterInstance.addMana = helpfulAdventurerAddMana;
			characterInstance.onZoneChanged = helpfulAdventurerZoneChanged;
			
			
			//setup ascension functionality
			for (var key:String in characterInstance.levelGraphNodeTypes)
			{
				helpfulAdventurer.levelGraphNodeTypes[key].setupFunction();
			}
		}
		
		private function autoAttack():void
		{
			CH2.currentCharacter.autoAttackDefault();
		}
		
		private function clickAttack(doesCostEnergy:Boolean = true):void
		{
			CH2.currentCharacter.clickAttackDefault(doesCostEnergy);
		}
		
		public function setUpDisplay(display:CharacterDisplay):void
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
				var animation:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip("HelpfulAdventurer_fire", 60);
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
			var catalog:Array = character.catalogItemsForSale;
			var randomItemIndex:int = CH2.roller.modRoller.integer(0, catalog.length-1);
			var randomItem:Item = catalog[randomItemIndex];
			
			return (!character.itemPurchasesLocked && character.gold.gte(randomItem.cost()));
		}
		
		public function onBuyRandomCatalogItemGemActivate():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.itemPurchasesLocked)
			{
				return false;
			}
			
			var catalog:Array = character.catalogItemsForSale;
			var randomItemIndex:int = CH2.roller.modRoller.integer(0, catalog.length - 1);
			var randomItem:Item = catalog[randomItemIndex];
			if (character.gold.gte(randomItem.cost()))
			{
				character.purchaseCatalogItem(randomItemIndex);
				IdleHeroUIManager.instance.refreshDamageDisplays();
				return true;
			}
			return false;
		}
		
		public function canUpgradeCheapestItem():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.itemPurchasesLocked)
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
		
		public function onUpgradeCheapestItemGemActivate():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.itemPurchasesLocked)
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
		
		public function canUpgradeFirstAffordableItem():Boolean
		{
			var character:Character = CH2.currentCharacter;
			
			if (character.itemPurchasesLocked)
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
			
			if (character.itemPurchasesLocked)
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
//			clickstorm.manaCost *= 0.80;
			clickstorm.cooldownRemaining = Math.min(clickstorm.cooldownRemaining, clickstorm.cooldown);
		}
		
		public function hastenEnergize():void
		{
			var energize:Skill = CH2.currentCharacter.getSkill("Energize");
			energize.manaCost *= 0.80;
			energize.cooldown *= 0.80;
			energize.cooldownRemaining = Math.min(energize.cooldownRemaining, energize.cooldown);
		}
		
		public function applySmallReloads():void
		{
			hastenSkill("Reload", 0.1);
			CH2.currentCharacter.setTrait("SmallReloads", 1);
		}	
	}
}
