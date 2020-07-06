package
{
	import HelpfulAdventurerChallengeBase;
	import com.doogog.utils.MiscUtils;
	import com.playsaurus.managers.BigNumberFormatter;
	import com.playsaurus.numbers.BigNumber;
	import com.playsaurus.utils.ServerTimeKeeper;
	import com.playsaurus.utils.StringFormatter;
	import com.playsaurus.utils.TimeFormatter;
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
	import OneWorldFrenzyAssets.thumbnail;
	
	public dynamic class OneWorldFrenzy extends HelpfulAdventurerChallengeBase
	{
		public static const GOLD_GAIN_MULTIPLIER:Number = 1;
		//############### DEFINE THE SUPER CLASS ASSET GROUP AND CHARACTER NAME ###############
		public static const SUPER_CLASS_CHARACTER_NAME:String = "Helpful Adventurer";
		public static const CHARACTER_ASSET_GROUP:String = "HelpfulAdventurer";
		//#####################################################################################
		public static const CHARACTER_NAME:String = "One World Frenzy";
		public static const NEW_CHARACTER_NAME:String = "One World Frenzy";
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
			{ "name": "CLICK_DAMAGE", "id": "5", "level": 10 },
			{ "name": "MONSTER_GOLD", "id": "6", "level": 10 },
			{ "name": "ITEM_COST_REDUCTION", "id": "7", "level": 10 },
			{ "name": "TOTAL_MANA", "id": "8", "level": 5 },
			{ "name": "MANA_REGEN", "id": "9", "level": 15 },
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
			{ "name": "BigClicksDamage", "id": "35", "level": 10 },
			{ "name": "HugeClickDamage", "id": "38", "level": 10 },
			{ "name": "ManaCritDamage", "id": "39", "level": 10 },
			{ "name": "ImprovedEnergize", "id": "40", "level": 8 },
			{ "name": "SustainedPowersurge", "id": "41", "level": 20 },
			{ "name": "ImprovedPowersurge", "id": "42", "level": 15 },
			{ "name": "ImprovedReload", "id": "43", "level": 20 }
		];
		
		public function OneWorldFrenzy() 
		{
			super();
			
			this.MOD_INFO = 
			{
				"id": 5,
				"name": NEW_CHARACTER_NAME,
				"description": "Default prepackaged challenge class",
				"version": 1,
				"author": "Playsaurus",
				"dependencies": "HelpfulAdventurer",
				"library": {}
			};
			
			MOD_INFO["library"]["thumbnail"] = OneWorldFrenzyAssets.thumbnail;
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
			newCharacter.flavorName = "One World Frenzy";
			newCharacter.flavorClass = "As Cid, The Hasteful Adventurer";
			newCharacter.flavor = "How fast can you beat the world?";
			newCharacter.availableForCreation = true;
			newCharacter.visibleOnCharacterSelect = true;
			newCharacter.startingSkills = [ ];
			newCharacter.upgradeableStats = Character.DEFAULT_UPGRADEABLE_STATS;
			newCharacter.attackMsDelay = 600;
			newCharacter.gildStartBuild = [3, 1, 5, 4, 2, 6, 8, 9, 11, 13, 14, 35, 39, 40];
			newCharacter.isChallengeCharacter = true;
			
			Characters.startingDefaultInstances[newCharacter.name] = newCharacter;
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
				
				//Setup the handlers
				characterInstance.getLevelUpCostToNextLevelHandler = this;
				characterInstance.updateHandler = this;
				characterInstance.onWorldFinishedHandler = this;
				characterInstance.onCharacterLoadedHandler = this;
				characterInstance.getItemDamageHandler = this;
				characterInstance.gainLevelHandler = this;
				characterInstance.onKilledMonsterHandler = this;
				characterInstance.onUsedSkillHandler = this;
				characterInstance.clickAttackHandler = this;
				characterInstance.extendedVariables = new ChallengeExtendedVariables();
				characterInstance.readExtendedVariables();
				
				//Register the challenge functions
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
		
		public function clickAttackOverride(doesCostEnergy:Boolean):void
		{
			if (!CH2.currentCharacter.extendedVariables["isStarted"])
			{
				CH2.currentCharacter.extendedVariables["isStarted"] = true;
			}
			
			CH2.currentCharacter.clickAttackDefault(doesCostEnergy);
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
						
						if ( i + 1 == CH2.currentCharacter.gildStartBuild.length )
						{
							CH2.currentCharacter.totalStatPointsV2 += 19;
							CH2.currentCharacter.level = 20;
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
			
			multiplier *= (Math.pow(0.95, item.rank - 1));
			
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
		
		
		//Makes it so experience above what is required for your next level will carry over towards the one after it. 
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
			
			//determines the total number of levels for the challenge.
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
		
		override public function onUICreated():void
		{
			if (CH2.currentCharacter.name == NEW_CHARACTER_NAME)
			{
				callSuperClassFunction(super.onUICreated, CH2.currentCharacter);
			}
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