package
{
	import com.doogog.utils.MiscUtils;
	import flash.display.Sprite;
	import flash.system.Capabilities;
	import flash.utils.setTimeout;
	import heroclickerlib.CH2;
	import com.playsaurus.model.Model;
	import heroclickerlib.GpuImage;
	import heroclickerlib.managers.SoundManager;
	import heroclickerlib.ui.CharacterDisplayUI;
	import heroclickerlib.ui.CharacterUIElement;
	import heroclickerlib.world.CharacterDisplay;
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
	import ui.CachedText;
	import ui.CachedTextManager;
	
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
		
		public function WizardMain() 
		{
			MOD_INFO["library"]["thumbnail"] = Wizard.thumbnail;
			MOD_INFO["library"]["frame"] = Wizard.frame;
		}
		
		public function onStartup(game:IdleHeroMain):void //Save data is NOT loaded at this point, init() has not yet been run
		{
			var wizard:Character = new Character();
			wizard.assetGroupName = CHARACTER_ASSET_GROUP;
			
			wizard.levelGraphObject = {"nodes":[{"1":{"x": -172, "val":"D", "y": -167}}, {"2":{"x":40, "val":"G", "y": -167}}, {"3":{"x": -148, "val":"Cc", "y":21}}, {"4":{"x":49, "val":"D", "y":21}}, {"5":{"x": -51, "val":"D", "y": -90}}, {"7":{"x":109, "val":"D", "y":20}}, {"8":{"x": -38, "val":"H", "y":126}}, {"11":{"x":158, "val":"D", "y":27}}, {"12":{"x":221, "val":"D", "y":33}}], "edges":[{"1":[4, 7]}, {"2":[7, 11]}, {"3":[2, 4]}, {"4":[3, 8]}, {"5":[7, 8]}, {"6":[3, 5]}, {"7":[2, 5]}, {"8":[11, 12]}, {"9":[1, 5]}]};
			
			wizard.levelGraphNodeTypes = {
				"G": { 
					"name": "Gold",
					"tooltip": "Multiplies your gold received from all sources by 196%.",
					"setupFunction": function(){},
					"purchaseFunction": function() { CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD, 2)},
					"icon": "goldx3"
				},
				"D": {
					"name": "Damage",
					"tooltip": "Multiplies the damage you deal from all sources by 196%.",
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_DAMAGE, 2)},
					"icon": "damagex3"
				},
				"Cc": { 
					"name": "Crit Chance",
					"tooltip": "Increases your chance to score a critical hit by 2%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_CHANCE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "critChance"
				},
				"Cd": { 
					"name": "Crit Damage",
					"tooltip": "Multiplies the damage of your critical hits by 20%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CRIT_DAMAGE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "critDamage"
				},
				"H": { 
					"name": "Haste",
					"tooltip": "Multiplies your auto-attack and cooldown speeds by 5%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_HASTE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "haste"
				},
				"Gc": { 
					"name": "Clickable Gold",
					"tooltip": "Multiplies your gold received from clickables by 50%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_GOLD); },
					"icon": "clickableGold"
				},
				"Cl": { 
					"name": "Click Damage",
					"tooltip": "Multiplies your click damage by 25%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICK_DAMAGE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "clickDamage"
				},
				"Gb": { 
					"name": "Boss Gold",
					"tooltip": "Multiplies your gold received from bosses by 200%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_BOSS_GOLD); },
					"icon": "bossGold"
				},
				"Ic": { 
					"name": "Item Cost Reduction",
					"tooltip": "Reduces the cost of buying and leveling items by 1%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_COST_REDUCTION); },
					"icon": "itemCostReduction"
				},
				"Mt": { 
					"name": "Total Mana",
					"tooltip": "Increases the size of your mana pool by 25." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_MANA); },
					"icon": "totalMana"
				},
				"Mr": { 
					"name": "Mana Regeneration",
					"tooltip": "Increases your mana regeneration by 5%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_MANA_REGEN); },
					"icon": "manaRegeneration"
				},
				"Et": { 
					"name": "Total Energy",
					"tooltip": "Increases the size of your energy pool by 25." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TOTAL_ENERGY); },
					"icon": "totalEnergy"
				},
				"Gp": { 
					"name": "Gold Piles",
					"tooltip": "Increases number of gold piles found by 10%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_CLICKABLE_CHANCE); },
					"icon": "goldPiles"
				},
				"Bg": { 
					"name": "Bonus Gold Chance",
					"tooltip": "Increases your chance of finding bonus gold by 1%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_BONUS_GOLD_CHANCE); },
					"icon": "goldChance"
				},
				"Tc": { 
					"name": "Treasure Chest Chance",
					"tooltip": "(Incomplete) Increases the chance of finding a treasure chest by 1%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_CHANCE); },
					"icon": "treasureChance"
				},
				"Tg": { 
					"name": "Treasure Chest Gold",
					"tooltip": "Multiplies your gold received from treasure chests by 25%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_TREASURE_CHEST_GOLD); },
					"icon": "treasureGold"
				},
				"Pc": { 
					"name": "Pierce Chance",
					"tooltip": "Increases your chance to hit an additional monster by 1%." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_PIERCE_CHANCE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "pierceChance"
				},
				"Tp": { 
					"name": "Talent Point",
					"tooltip": "(INCOMPLETE) Increases the number of talent points you start the world with by 1." ,
					"setupFunction": function(){},
					"purchaseFunction": function() {},
					"icon": "talentPoint"
				},
				"I1": { 
					"name": "Item Slot 1",
					"tooltip": "Multiplies the damage you deal with swords by 150%" ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_WEAPON_DAMAGE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "damageWeapon"
				},
				"I2": { 
					"name": "Item Slot 2",
					"tooltip": "Multiplies the damage you deal with helmets by 150%" ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_HEAD_DAMAGE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "damageHead"
				},
				"I3": { 
					"name": "Item Slot 3",
					"tooltip": "Multiplies the damage you deal with chest pieces by 150%" ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_CHEST_DAMAGE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "damageTop"
				},
				"I4": { 
					"name": "Item Slot 4",
					"tooltip": "Multiplies the damage you deal with rings by 150%" ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_HANDS_DAMAGE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "damageAccesory"
				},
				"I5": { 
					"name": "Item Slot 5",
					"tooltip": "Multiplies the damage you deal with pants by 150%" ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_LEGS_DAMAGE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "damageLegs"
				},
				"I6": { 
					"name": "Item Slot 6",
					"tooltip": "Multiplies the damage you deal with gloves by 150%" ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_HANDS_DAMAGE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "damageHands"
				},
				"I7": { 
					"name": "Item Slot 7",
					"tooltip": "Multiplies the damage you deal with boots by 150%" ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_FEET_DAMAGE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "damageFeet"
				},
				"I8": { 
					"name": "Item Slot 8",
					"tooltip": "Multiplies the damage you deal with capes by 150%" ,
					"setupFunction": function(){},
					"purchaseFunction": function() {CH2.currentCharacter.levelUpStat(CH2.STAT_ITEM_BACK_DAMAGE); CH2.currentCharacter.levelUpStat(CH2.STAT_GOLD);},
					"icon": "damageBack"
				}
			}
			
			wizard.levelGraph = LevelGraph.loadGraph(wizard.levelGraphObject, wizard);
			
			wizard.name = "Wizard";
			wizard.flavorName = "???"
			wizard.flavorClass = "The Cursed Wizard"
			wizard.flavor = "Coming Soon!";
			wizard.characterSelectOrder = 2;
			wizard.availableForCreation = IdleHeroMain.IS_DEVELOPMENT_BUILD;
			wizard.visibleOnCharacterSelect = true;
			wizard.defaultSaveName = "wizard";
			wizard.levelCostScaling = "linear10";
			wizard.startingSkills = [];
			
			wizard.statBaseValues[CH2.STAT_TOTAL_ENERGY] = 300;
			wizard.statBaseValues[CH2.STAT_DAMAGE] = 0.25;
			
			wizard.monstersPerZone = 10;
			wizard.monsterHealthMultiplier = 5;
			wizard.attackRange = 300;
			wizard.attackMsDelay = 2000;
			
			wizard.upgradeableStats = Character.DEFAULT_UPGRADEABLE_STATS;
			
			Characters.startingDefaultInstances[wizard.name] = wizard;
			
			//RUNES
			
			var runeIce:Skill = new Skill();
			runeIce.modName = MOD_INFO["name"];
			runeIce.name = "Ice Rune";
			runeIce.description = "";
			runeIce.cooldown = 0;
			runeIce.iconId = 163;
			runeIce.manaCost = 0;
			runeIce.energyCost = 10;
			runeIce.consumableOnly = false;
			runeIce.minimumAscensions = 0;
			runeIce.effectFunction = function(){ runeEffect("Ice"); };
			runeIce.ignoresGCD = false;
			runeIce.maximumRange = 300;
			runeIce.minimumRange = 0;
			runeIce.tooltipFunction = function():Object{ return this.skillTooltip("Fire"); };
			Character.staticSkillInstances[runeIce.uid] = runeIce;
			
			var runeFire:Skill = new Skill();
			runeFire.modName = MOD_INFO["name"];
			runeFire.name = "Fire Rune";
			runeFire.description = "";
			runeFire.cooldown = 0;
			runeFire.iconId = 163;
			runeFire.manaCost = 0;
			runeFire.energyCost = 10;
			runeFire.consumableOnly = false;
			runeFire.minimumAscensions = 0;
			runeFire.effectFunction = function(){ runeEffect("Fire"); };
			runeFire.ignoresGCD = false;
			runeFire.maximumRange = 300;
			runeFire.minimumRange = 0;
			runeFire.tooltipFunction = function():Object{ return this.skillTooltip("Ice"); };
			Character.staticSkillInstances[runeFire.uid] = runeFire;
			
			var runeLightning:Skill = new Skill();
			runeLightning.modName = MOD_INFO["name"];
			runeLightning.name = "Lightning Rune";
			runeLightning.description = "";
			runeLightning.cooldown = 0;
			runeLightning.iconId = 163;
			runeLightning.manaCost = 0;
			runeLightning.energyCost = 10;
			runeLightning.consumableOnly = false;
			runeLightning.minimumAscensions = 0;
			runeLightning.effectFunction = function(){ runeEffect("Lightning"); };
			runeLightning.ignoresGCD = false;
			runeLightning.maximumRange = 300;
			runeLightning.minimumRange = 0;
			runeLightning.tooltipFunction = function():Object{ return this.skillTooltip("Lightning"); };
			Character.staticSkillInstances[runeLightning.uid] = runeLightning;
			
			var rune1:Skill = new Skill();
			rune1.modName = MOD_INFO["name"];
			rune1.name = "rune1";
			rune1.description = "";
			rune1.cooldown = 0;
			rune1.iconId = 163;
			rune1.manaCost = 0;
			rune1.energyCost = 10;
			rune1.consumableOnly = false;
			rune1.minimumAscensions = 0;
			rune1.effectFunction = function(){ runeEffect("1"); };
			rune1.ignoresGCD = false;
			rune1.maximumRange = 300;
			rune1.minimumRange = 0;
			rune1.tooltipFunction = function():Object{ return this.skillTooltip("1"); };
			Character.staticSkillInstances[rune1.uid] = rune1;
			
			var rune2:Skill = new Skill();
			rune2.modName = MOD_INFO["name"];
			rune2.name = "rune2";
			rune2.description = "";
			rune2.cooldown = 0;
			rune2.iconId = 163;
			rune2.manaCost = 0;
			rune2.energyCost = 10;
			rune2.consumableOnly = false;
			rune2.minimumAscensions = 0;
			rune2.effectFunction = function(){ runeEffect("2"); };
			rune2.ignoresGCD = false;
			rune2.maximumRange = 300;
			rune2.minimumRange = 0;
			rune2.tooltipFunction = function():Object{ return this.skillTooltip("2"); };
			Character.staticSkillInstances[rune2.uid] = rune2;
			
			var rune3:Skill = new Skill();
			rune3.modName = MOD_INFO["name"];
			rune3.name = "rune3";
			rune3.description = "";
			rune3.cooldown = 0;
			rune3.iconId = 163;
			rune3.manaCost = 0;
			rune3.energyCost = 10;
			rune3.consumableOnly = false;
			rune3.minimumAscensions = 0;
			rune3.effectFunction = function(){ runeEffect("3"); };
			rune3.ignoresGCD = false;
			rune3.maximumRange = 300;
			rune3.minimumRange = 0;
			rune3.tooltipFunction = function():Object{ return this.skillTooltip("3"); };
			Character.staticSkillInstances[rune3.uid] = rune3;
			
			var rune4:Skill = new Skill();
			rune4.modName = MOD_INFO["name"];
			rune4.name = "rune4";
			rune4.description = "";
			rune4.cooldown = 0;
			rune4.iconId = 163;
			rune4.manaCost = 0;
			rune4.energyCost = 10;
			rune4.consumableOnly = false;
			rune4.minimumAscensions = 0;
			rune4.effectFunction = function(){ runeEffect("4"); };
			rune4.ignoresGCD = false;
			rune4.maximumRange = 300;
			rune4.minimumRange = 0;
			rune4.tooltipFunction = function():Object{ return this.skillTooltip("4"); };
			Character.staticSkillInstances[rune4.uid] = rune4;		
			
			var rune5:Skill = new Skill();
			rune5.modName = MOD_INFO["name"];
			rune5.name = "rune5";
			rune5.description = "";
			rune5.cooldown = 0;
			rune5.iconId = 163;
			rune5.manaCost = 0;
			rune5.energyCost = 10;
			rune5.consumableOnly = false;
			rune5.minimumAscensions = 0;
			rune5.effectFunction = function(){ runeEffect("5"); };
			rune5.ignoresGCD = false;
			rune5.maximumRange = 300;
			rune5.minimumRange = 0;
			rune5.tooltipFunction = function():Object{ return this.skillTooltip("5"); };
			Character.staticSkillInstances[rune5.uid] = rune5;
			
			var rune6:Skill = new Skill();
			rune6.modName = MOD_INFO["name"];
			rune6.name = "rune6";
			rune6.description = "";
			rune6.cooldown = 0;
			rune6.iconId = 163;
			rune6.manaCost = 0;
			rune6.energyCost = 10;
			rune6.consumableOnly = false;
			rune6.minimumAscensions = 0;
			rune6.effectFunction = function(){ runeEffect("6"); };
			rune6.ignoresGCD = false;
			rune6.maximumRange = 300;
			rune6.minimumRange = 0;
			rune6.tooltipFunction = function():Object{ return this.skillTooltip("6"); };
			Character.staticSkillInstances[rune6.uid] = rune6;
			
			var activateRune:Skill = new Skill();
			activateRune.modName = MOD_INFO["name"];
			activateRune.name = "activateRune";
			activateRune.description = "";
			activateRune.cooldown = 0;
			activateRune.iconId = 163;
			activateRune.manaCost = 0;
			activateRune.energyCost = 10;
			activateRune.consumableOnly = false;
			activateRune.minimumAscensions = 0;
			activateRune.effectFunction = function(){ runeEffect("EXE"); };
			activateRune.ignoresGCD = false;
			activateRune.maximumRange = 300;
			activateRune.minimumRange = 0;
			activateRune.tooltipFunction = function():Object{ return this.skillTooltip("Activate"); };
			Character.staticSkillInstances[activateRune.uid] = activateRune;
			
			var frostBolt:Skill = new Skill();
			frostBolt.modName = MOD_INFO["name"];
			frostBolt.name = "Frost Bolt";
			frostBolt.description = "";
			frostBolt.cooldown = 0;
			frostBolt.castTime = 2.0;
			frostBolt.iconId = 163;
			frostBolt.manaCost = 0;
			frostBolt.energyCost = 10;
			frostBolt.consumableOnly = false;
			frostBolt.minimumAscensions = 0;
			frostBolt.effectFunction = frostBoltEffect;
			frostBolt.ignoresGCD = false;
			frostBolt.maximumRange = 300;
			frostBolt.minimumRange = 0;
			frostBolt.tooltipFunction = function():Object{ return this.skillTooltip("Frosts Bolts."); };
			Character.staticSkillInstances[frostBolt.uid] = frostBolt;
			
			var fireball:Skill = new Skill();
			fireball.modName = MOD_INFO["name"];
			fireball.name = "Fireball";
			fireball.description = "";
			fireball.cooldown = 0;
			fireball.castTime = 4.0;
			fireball.iconId = 163;
			fireball.manaCost = 0;
			fireball.energyCost = 30;
			fireball.consumableOnly = false;
			fireball.minimumAscensions = 0;
			fireball.effectFunction = fireballEffect;
			fireball.ignoresGCD = false;
			fireball.maximumRange = 300;
			fireball.minimumRange = 0;
			fireball.tooltipFunction = function():Object{ return this.skillTooltip("Doesn't Frost Bolts."); };
			Character.staticSkillInstances[fireball.uid] = fireball;

			var lightningBolt:Skill = new Skill();
			lightningBolt.modName = MOD_INFO["name"];
			lightningBolt.name = "Lightning Bolt";
			lightningBolt.description = "";
			lightningBolt.cooldown = 0;
			lightningBolt.castTime = 5.0;
			lightningBolt.iconId = 163;
			lightningBolt.manaCost = 0;
			lightningBolt.energyCost = 30;
			lightningBolt.consumableOnly = false;
			lightningBolt.minimumAscensions = 0;
			lightningBolt.effectFunction = lightningBoltEffect;
			lightningBolt.ignoresGCD = false;
			lightningBolt.maximumRange = 500;
			lightningBolt.minimumRange = 0;
			lightningBolt.tooltipFunction = function():Object{ return this.skillTooltip("Lightnings Bolts."); };
			Character.staticSkillInstances[lightningBolt.uid] = lightningBolt;
			
			var earthShock:Skill = new Skill();
			earthShock.modName = MOD_INFO["name"];
			earthShock.name = "Earth Shock";
			earthShock.description = "";
			earthShock.cooldown = 0;
			earthShock.castTime = 0;
			earthShock.iconId = 163;
			earthShock.manaCost = 0;
			earthShock.energyCost = 30;
			earthShock.consumableOnly = false;
			earthShock.minimumAscensions = 0;
			earthShock.effectFunction = earthShockEffect;
			earthShock.ignoresGCD = false;
			earthShock.maximumRange = 500;
			earthShock.minimumRange = 0;
			earthShock.tooltipFunction = function():Object{ return this.skillTooltip("Earths Shocks."); };
			Character.staticSkillInstances[earthShock.uid] = earthShock;
			
			var flameShock:Skill = new Skill();
			flameShock.modName = MOD_INFO["name"];
			flameShock.name = "Flame Shock";
			flameShock.description = "";
			flameShock.cooldown = 0;
			flameShock.castTime = 0;
			flameShock.iconId = 163;
			flameShock.manaCost = 0;
			flameShock.energyCost = 10;
			flameShock.consumableOnly = false;
			flameShock.minimumAscensions = 0;
			flameShock.effectFunction = flameShockEffect;
			flameShock.ignoresGCD = false;
			flameShock.maximumRange = 500;
			flameShock.minimumRange = 0;
			flameShock.tooltipFunction = function():Object{ return this.skillTooltip("Flames Shocks."); };
			Character.staticSkillInstances[flameShock.uid] = flameShock;
			
			var lavaBurst:Skill = new Skill();
			lavaBurst.modName = MOD_INFO["name"];
			lavaBurst.name = "Lava Burst";
			lavaBurst.description = "";
			lavaBurst.cooldown = 8000;
			lavaBurst.castTime = 2;
			lavaBurst.iconId = 163;
			lavaBurst.manaCost = 0;
			lavaBurst.energyCost = 10;
			lavaBurst.consumableOnly = false;
			lavaBurst.minimumAscensions = 0;
			lavaBurst.effectFunction = lavaBurstEffect;
			lavaBurst.ignoresGCD = false;
			lavaBurst.maximumRange = 500;
			lavaBurst.minimumRange = 0;
			lavaBurst.tooltipFunction = function():Object{ return this.skillTooltip("Lightnings Bolts."); };
			Character.staticSkillInstances[lavaBurst.uid] = lavaBurst;
			
			var combust:Skill = new Skill();
			combust.modName = MOD_INFO["name"];
			combust.name = "Combust";
			combust.description = "";
			combust.cooldown = 0;
			combust.castTime = 2;
			combust.iconId = 163;
			combust.manaCost = 0;
			combust.energyCost = 40;
			combust.consumableOnly = false;
			combust.minimumAscensions = 0;
			combust.effectFunction = combustEffect;
			combust.ignoresGCD = false;
			combust.maximumRange = 500;
			combust.minimumRange = 0;
			combust.tooltipFunction = function():Object{ return this.skillTooltip("Wastes Energy."); };
			Character.staticSkillInstances[combust.uid] = combust;
		}
		
		public function frostBoltEffect():void
		{
			var target:Monster = CH2.world.getNextMonster();
			if (target)
			{
				var attackData:AttackData = new AttackData();
				attackData.damage = CH2.currentCharacter.damage.multiplyN(15);
				CH2.currentCharacter.attack(attackData);
				CH2.world.camera.shake(0.5, -50, 50);
				
				if (Rnd.boolean(1.0))
				{
					if (CH2.currentCharacter.buffs.hasBuffByName("Chills"))
					{
						var buff:Buff = CH2.currentCharacter.buffs.getBuff("Chills");
						if (buff.stacks < 10)
						{
							buff.stacks++;
							buff.buffStat(CH2.STAT_ENERGY_COST_REDUCTION, buff.stacks * 0.2);
						}
						buff.refreshTimer();	
					}
					else
					{
						var buff:Buff = new Buff
						buff.iconId = 21;
						buff.duration = 10000;
						buff.name = "Chills";
						buff.maximumStacks = 20;
						buff.buffStat(CH2.STAT_ENERGY_COST_REDUCTION, 0.2);
						CH2.currentCharacter.buffs.addBuff(buff);
					}
				}
			}
		}
		
		public function fireballEffect():void
		{
			var target:Monster = CH2.world.getNextMonster();
			if (target)
			{
				var attackData:AttackData = new AttackData();
				attackData.damage = CH2.currentCharacter.damage.multiplyN(30).multiplyN((CH2.currentCharacter.buffs.hasBuffByName("Chills") ? CH2.currentCharacter.buffs.getBuff("Chills").stacks + 1 : 1));
				CH2.currentCharacter.attack(attackData);
				CH2.world.camera.shake(0.5, -50, 50);
				
				if (CH2.currentCharacter.buffs.hasBuffByName("Chills"))
				{
					var buff:Buff = CH2.currentCharacter.buffs.getBuff("Chills");
					buff.stacks--;
					buff.buffStat(CH2.STAT_ENERGY_COST_REDUCTION, buff.stacks * 0.2);
				}
				else
				{
					
				}
				if (CH2.currentCharacter.buffs.hasBuffByName("Overheated"))
				{
					var buff:Buff = CH2.currentCharacter.buffs.getBuff("Overheated");
					if (buff.stacks < 10)
					{
						buff.stacks++;
						buff.buffStat(CH2.STAT_HASTE, 1 + (buff.stacks * 0.10));
					}
					buff.refreshTimer();
				}
				else
				{
					var buff:Buff = new Buff
					buff.iconId = 52;
					buff.duration = 10000;
					buff.name = "Overheated";
					buff.maximumStacks = 20;
					buff.buffStat(CH2.STAT_HASTE, 1.10);
					CH2.currentCharacter.buffs.addBuff(buff);
				}
			}
		}
		
		public function lightningBoltEffect():void
		{
			var target:Monster = CH2.world.getNextMonster();
			if (target)
			{
				var attackData:AttackData = new AttackData();
				attackData.damage = CH2.currentCharacter.damage.multiplyN(45).multiplyN((CH2.currentCharacter.buffs.hasBuffByName("Overheated") ? CH2.currentCharacter.buffs.getBuff("Overheated").stacks + 1 : 1));
				CH2.currentCharacter.attack(attackData);
				if (CH2.currentCharacter.buffs.hasBuffByName("Overheated"))
				{
					var buff:Buff = CH2.currentCharacter.buffs.getBuff("Overheated");
					buff.stacks--;
					buff.buffStat(CH2.STAT_HASTE, 1 + (buff.stacks * 0.10));
				}
				else
				{
					
				}
				if (CH2.currentCharacter.buffs.hasBuffByName("Charged"))
				{
					var buff:Buff = CH2.currentCharacter.buffs.getBuff("Charged");
					if (buff.stacks < 10)
					{
						buff.stacks++;
						buff.buffStat(CH2.STAT_CRIT_CHANCE, (buff.stacks * 0.04));
					}
					buff.refreshTimer();
				}
				else
				{
					var buff:Buff = new Buff
					buff.iconId = 70;
					buff.duration = 10000;
					buff.name = "Charged";
					buff.maximumStacks = 20;
					buff.buffStat(CH2.STAT_CRIT_CHANCE, 0.04);
					CH2.currentCharacter.buffs.addBuff(buff);
				}
			}
		}
		
		public function lightningBoltEffectOld():void
		{
			var target:Monster = CH2.world.getNextMonster();
			if (target)
			{
				var attackData:AttackData = new AttackData();
				attackData.damage = CH2.currentCharacter.damage.multiplyN(20);
				CH2.currentCharacter.attack(attackData);
				if (Rnd.boolean(0.35))
				{
					var buff:Buff = new Buff
					buff.iconId = 21;
					buff.duration = 3600000;
					buff.name = "Static Charge";
					buff.maximumStacks = 10;
					CH2.currentCharacter.buffs.addBuff(buff);
				}
			}
		}
		
		public function combustEffect():void
		{
			var target:Monster = CH2.world.getNextMonster();
			if (target)
			{
				var attackData:AttackData = new AttackData();
				attackData.damage = CH2.currentCharacter.damage.multiplyN(40);
				CH2.currentCharacter.attack(attackData);
			}
		}
		
		public function flameShockEffect():void
		{
			var target:Monster = CH2.world.getNextMonster();
			if (target)
			{
				var debuff:MonsterDebuff = new MonsterDebuff(target);
				debuff.name = "Flame Shock";
				debuff.iconId = 7;
				debuff.tooltipFunction = "poisonTooltip";
				debuff.tickFunction = function() 
				{
					if (target.isAlive)
					{
						var attackData:AttackData = new AttackData();
						attackData.damage = CH2.currentCharacter.damage.multiplyN(1);
						CH2.currentCharacter.attack(attackData);
						if (Rnd.boolean(0.05))
						{
							var lavaBurstSkill:Skill = CH2.currentCharacter.getActiveSkillByName("Lava Burst");
							if (lavaBurstSkill && lavaBurstSkill.isActive)
							{
								lavaBurstSkill.cooldownRemaining = 0;
								var previousLavaBurstCastTime:Number = lavaBurstSkill.castTime;
								var buff:Buff = new Buff();
								buff.iconId = 20;
								buff.duration = 8000;
								buff.name = "Flashfire";
								//buff.startFunction = function()
								//{
									//lavaBurstSkill.castTime = 0;
								//}
								//buff.finishFunction = function()
								//{
									//lavaBurstSkill.castTime = previousLavaBurstCastTime;
								//}
								buff.castFunction = function()
								{
								}
								CH2.currentCharacter.buffs.addBuff(buff);
								
							}
						}
					}
				}
				debuff.duration = 30000;
				debuff.tickRate = 500;
				target.addDebuff(debuff);
			}
		}
		
		public function lavaBurstEffect():void
		{
			var character:Character = CH2.currentCharacter;
			var target:Monster = CH2.world.getNextMonster();
			if (target)
			{
				var damage:BigNumber = CH2.currentCharacter.damage.multiplyN(32);
				if (target.hasDebuff("Flame Shock")) 
				{
					var attackData:AttackData = new AttackData();
					attackData.damage = damage;
					attackData.damage.timesEqualsN(2);
					attackData.isCritical = true;
					CH2.currentCharacter.attack(attackData);
				} else
				{
					var attackData:AttackData = new AttackData();
					attackData.damage = damage;
					CH2.currentCharacter.attack(attackData);
				}
				if (character.buffs.hasBuffByName("Flashfire"))
				{
					character.buffs.removeBuff("FlashFire");
				}
			}
		}
		
		public function earthShockEffect():void
		{
			var target:Monster = CH2.world.getNextMonster();
			if (target)
			{
				var attackData:AttackData = new AttackData();
				attackData.damage = CH2.currentCharacter.damage.multiplyN(8)
				if (CH2.currentCharacter.buffs.hasBuffByName("Static Charge"))
				{
					var staticCharge:Buff = CH2.currentCharacter.buffs.getBuff("Static Charge");
					var chargeCount:int = staticCharge.stacks;
					attackData.damage.plusEquals(CH2.currentCharacter.damage.multiplyN(16 * chargeCount));
					CH2.currentCharacter.addEnergy(60 * chargeCount);
					staticCharge.duration = 0;
				}
				CH2.currentCharacter.attack(attackData);
			}
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
				characterInstance.assetGroupName = CHARACTER_ASSET_GROUP;
				characterInstance.autoAttack = wizardAutoAttack;
				characterInstance.onCharacterDisplayCreated = setUpDisplay;
			}
		}
		
		public function setUpDisplay(display:CharacterDisplay):void
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
			SoundManager.instance.loadAudioClass("audio/wizard/fire_skill/fire_activate");
			SoundManager.instance.loadAudioClass("audio/wizard/fire_skill/fire_strike");
			SoundManager.instance.loadAudioClass("audio/wizard/ice_skill/ice_activate");
			SoundManager.instance.loadAudioClass("audio/wizard/ice_skill/ice_strike");
			SoundManager.instance.loadAudioClass("audio/wizard/lightning_skill/lightning_activate");
			SoundManager.instance.loadAudioClass("audio/wizard/lightning_skill/lightning_strike");
		}
		
		public function wizardAutoAttack():void
		{
			if (!CH2.currentCharacter.isCasting && pendingRunes.length == 0)
			{
				CH2.currentCharacter.autoAttackDefault();
			}
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
		
		//#######################################################
		//###################### NEW STUFF ######################
		//#######################################################
		
		public var pendingRunes:Array = [];
		public function onRunesActivated():void
		{
			var skillToUse:Skill;
			if (pendingRunes[0].name == "Fire")
			{
				skillToUse = Character.staticSkillInstances["Fireball"];
			}
			else if (pendingRunes[0].name == "Ice")
			{
				skillToUse = Character.staticSkillInstances["Frost Bolt"];
			}
			else if (pendingRunes[0].name == "Lightning")
			{
				skillToUse = Character.staticSkillInstances["Lightning Bolt"];
			}
			
			for (var i:int = 0; i < pendingRunes.length; i++)
			{
				if (CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(pendingRunes[i].name))
				{
					CH2.currentCharacter.characterDisplay.characterUI.removeUIElement(pendingRunes[i]);
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
			
			if (skillToUse)
			{
				activateSkill(skillToUse);
			}
		}
		
		public function runeEffect(runeId:String):void
		{
			var numRunes:int = pendingRunes.length;
			pendingRunes[numRunes] = new CharacterUIElement();
			pendingRunes[numRunes].active = true;
			pendingRunes[numRunes].name = runeId;
			var runeAsset:GpuImage = CH2AssetManager.instance.getGpuImage("Wizard_rune"+runeId);
			pendingRunes[numRunes].addChild(runeAsset);
			pendingRunes[numRunes].type = CharacterDisplayUI.OTHER_ELEMENT;
			pendingRunes[numRunes].useWorldCoordinates = false;
			pendingRunes[numRunes].worldX = CH2.currentCharacter.x;
			pendingRunes[numRunes].worldY = CH2.currentCharacter.y + 100;
			pendingRunes[numRunes].modStateHolder["num"] = numRunes;
			pendingRunes[numRunes].updateHook = function(dt:Number):void
			{
				this.worldX = CH2.currentCharacter.x - (25 * pendingRunes.length) + (50 * this.modStateHolder["num"]);
				this.worldY = CH2.currentCharacter.y + 100;
				
				this.x = CH2.world.worldToScreenX(this.worldX, this.worldY);
				this.y = CH2.world.worldToScreenY(this.worldX, this.worldY);
			}
			if (!CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(pendingRunes[numRunes].name))
			{
				CH2.currentCharacter.characterDisplay.characterUI.addUIElement(pendingRunes[numRunes], CH2.world.environmentFront);
			}
			
			// Handle circle effects
			var numRunes:int = pendingRunes.length;
			var spellType:String = pendingRunes[0].name;
			if (runeId == "EXE")
			{
				onRunesActivated();
			}
			else if (spellType == "Fire")
			{
				if (numRunes < 4)
				{
					addSpellCircleEffect("Fire", numRunes);
				}
			}
			else if (spellType == "Lightning")
			{
				if (numRunes < 4)
				{
					addSpellCircleEffect("Lightning", numRunes);
				}
			}
			else if (spellType == "Ice")
			{
				if (numRunes < 4)
				{
					addSpellCircleEffect("Frost", numRunes);
				}
			}
		}
		
		public function activateSkill(skill:Skill):void
		{
			var castTimeMsec:Number = skill.castTime * (1 / (CH2.currentCharacter.hasteRating)) * 1000;
			var castingLoopScene:String;
			var skillAnimation:String;
			var castingEndAnimation:String;
			var activateSoundId:String;
			var strikeSoundId:String;
			switch(skill.name)
			{
				case "Frost Bolt":
					castingLoopScene = "castingLoop0_selfLoop";
					skillAnimation = "Wizard_frostSpell";
					castingEndAnimation = "castingEnd0_random";
					activateSoundId = "ice_activate";
					strikeSoundId = "ice_strike";
					break;
				case "Fireball":
					castingLoopScene = "castingLoop1_selfLoop";
					skillAnimation = "Wizard_fireSpell";
					castingEndAnimation = "castingEnd1_random";
					activateSoundId = "fire_activate";
					strikeSoundId = "fire_strike";
					break;
				case "Lightning Bolt":
					castingLoopScene = "castingLoop2_selfLoop";
					skillAnimation = "Wizard_lightningSpell";
					castingEndAnimation = "castingEnd2_random";
					activateSoundId = "lightning_activate";
					strikeSoundId = "lightning_strike";
					break;
				default:
					return;
			}
			
			SoundManager.instance.playSound(activateSoundId);
			CH2.currentCharacter.characterDisplay.playSceneByName(castingLoopScene, CharacterDisplay.STATE_CASTING);
			var animation:GpuMovieClip = CH2AssetManager.instance.getGpuMovieClip(skillAnimation);
			var characterDisplay:GpuMovieClip = CH2.currentCharacter.characterDisplay.characterDisplay;
			var effectDisplayMsecBeforeHittingGround:Number = (animation.assetData.scenes["hitGround"].startFrame - animation.assetData.scenes["end"].startFrame) * animation.mSecPerFrame;
			var timeBeforePlayingEffect:Number = castTimeMsec - effectDisplayMsecBeforeHittingGround;
			var castingEndDurationMs:Number = characterDisplay.numFramesInScene(castingEndAnimation) * characterDisplay.mSecPerFrame;
			setTimeout(function(){ CH2.currentCharacter.characterDisplay.playSceneByName(castingEndAnimation, CharacterDisplay.STATE_CASTING); }, (castTimeMsec - castingEndDurationMs));
			
			animation.playScene("loop", true);
			CH2.world.addEffect(animation, CH2.world.roomsFront, CH2.world.getNextMonster().x, CH2.world.getNextMonster().y);
			var animationTransition:Function =
				function()
				{
					if (SoundManager.instance.isPlayingSound(activateSoundId))
					{
						SoundManager.instance.stopSound(activateSoundId);
					}
					SoundManager.instance.playSound(strikeSoundId);
					animation.gotoAndPlay(animation.assetData.scenes["end"].startFrame);
					animation.isLooping = false;
					animation.currentSceneName = null;
				};
			if (timeBeforePlayingEffect >= 17)
			{
				SetTimedEvent.addEvent(animationTransition, timeBeforePlayingEffect);
			}
			else
			{
				animationTransition();
			}
			
			skill.useSkill();
		}
		
		public var activeCircleEffects:Array = [];
		public function addSpellCircleEffect(circleType:String, circleNum:int):void
		{
			var circleAsset:GpuImage = CH2AssetManager.instance.getGpuImage("Wizard_spellCircle" + circleType + circleNum);
			var circleEffect:CharacterUIElement = new CharacterUIElement();
			circleEffect.active = true;
			circleEffect.name = circleType + circleNum;
			circleEffect.addChild(circleAsset);
			circleEffect.type = CharacterDisplayUI.OTHER_ELEMENT;
			circleEffect.useWorldCoordinates = false;
			circleEffect.worldX = CH2.currentCharacter.x;
			circleEffect.worldY = CH2.currentCharacter.y;
			circleEffect.rotation = Math.PI / 6;
			circleEffect.skewX = Math.PI / 6;
			
			circleEffect.updateHook = function(dt:Number):void
			{
				this.worldX = CH2.currentCharacter.x;
				this.worldY = CH2.currentCharacter.y;
				
				if (circleNum == 2)
				{
					this.getChildAt(0).rotation = (MiscUtils.cachedTime / (circleNum * 1000) * Math.PI / 6) % (Math.PI * 2);
				}
				else
				{
					this.getChildAt(0).rotation = (MiscUtils.cachedTime / -1 * (circleNum * 1000) * Math.PI / 6) % (Math.PI * 2);
				}
				
				this.x = CH2.world.worldToScreenX(this.worldX, this.worldY);
				this.y = CH2.world.worldToScreenY(this.worldX, this.worldY);
			}
			if (!CH2.currentCharacter.characterDisplay.characterUI.hasUIElement(circleEffect.name))
			{
				CH2.currentCharacter.characterDisplay.characterUI.addUIElement(circleEffect, CH2.world.roomsBack);
			}
			
			activeCircleEffects.push(circleEffect);
		}
		
	}

}

import models.Skill;
class Spell
{
	public var id:int;
	public var name:String;
	public var rank:int;
	public var runeCombination:Array;
	public var spellSkill:Skill;
	public var talents:Vector.<SpellTrait>;
	
	public function Spell() 
	{
		
	}
}

class SpellTrait
{
	public var name:String;
	public var associatedSpellId:int;
	
	public function SpellTrait() 
	{
		
	}
}