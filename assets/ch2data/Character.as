package models
{
   import com.doogog.utils.MiscUtils;
   import com.gskinner.utils.Rnd;
   import com.playsaurus.managers.BigNumberFormatter;
   import com.playsaurus.model.Model;
   import com.playsaurus.numbers.BigNumber;
   import com.playsaurus.utils.ServerTimeKeeper;
   import com.playsaurus.utils.StringFormatter;
   import com.playsaurus.utils.TimeFormatter;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import heroclickerlib.CH2;
   import heroclickerlib.LevelGraph;
   import heroclickerlib.managers.Formulas;
   import heroclickerlib.managers.ItemDropManager;
   import heroclickerlib.managers.MusicManager;
   import heroclickerlib.managers.SoundManager;
   import heroclickerlib.managers.Trace;
   import heroclickerlib.world.CharacterDisplay;
   import it.sephiroth.gettext._;
   import ui.CH2UI;
   
   public class Character extends Model
   {
      
      public static const ASCENSION_PERSISTING_TRUE:Boolean = true;
      
      public static const ASCENSION_PERSISTING_FALSE:Boolean = false;
      
      public static const TRANSCENSION_PERSISTING_TRUE:Boolean = true;
      
      public static const TRANSCENSION_PERSISTING_FALSE:Boolean = false;
      
      public static const ASCENSION_DAMAGE_INCREASE:Number = 218750000;
      
      public static const VALIDATION_CHECK_VALUE_TRUE:Boolean = true;
      
      public static const VALIDATION_CHECK_VALUE_FALSE:Boolean = false;
      
      public static const TIME_UNTIL_PLAYER_NEEDS_HINT_MS:Number = 60000;
      
      public static const TIME_UNTIL_PLAYER_NEEDS_RUBY_SHOP_HINT_MS:Number = 150000;
      
      public static const ROLLER_SEEDS:Array = [12,6,10,42,49,29,38,26,8,31,1,9,36,7,44,30,40,20,11,37,48,34,28,16,45];
      
      public static const STATE_WALKING:int = 0;
      
      public static const STATE_COMBAT:int = 1;
      
      public static const STATE_PAUSED:int = 2;
      
      public static const STATE_ENDING_COMBAT:int = 3;
      
      public static const STATE_CASTING:int = 4;
      
      public static const STATE_UNKNOWN:int = 5;
      
      public static const MS_DELAY_BEFORE_IDLE:int = 60000;
      
      public static const TIME_AFTER_KILL_BEFORE_WALKING_MS:int = 230;
      
      public static const BASE_ATTACK_MS_DELAY:Number = 1000;
      
      public static const ENERGY_REGEN_PER_SECOND:Number = 0;
      
      public static const ENERGY_REGEN_PER_AUTO_ATTACK:Number = 1;
      
      public static const SECONDS_FROM_ZERO_TO_BASE_MAX_MANA_WITHOUT_MANA_REGEN_STATS:Number = 1200;
      
      public static const MAX_CATALOG_SIZE:Number = 4;
      
      public static const WORLD_END_AUTOMATION_OPTIONS_UNLOCK_WORLD:Number = 3;
      
      public static const WALK_SPEED_METERS_PER_SECOND:Number = 4.5;
      
      public static const ONE_METER_Y_DISTANCE:Number = 44;
      
      public static const CHARACTER_ZONE_START_Y:Number = 600;
      
      public static const MONSTER_RUBY_DROP_TIME_INTERVAL:Number = 600000;
      
      public static const ORANGE_FISH_TIME_INTERVAL:Number = 3600000;
      
      public static const REGULAR_MONSTER_RUBY_DROP_AMOUNT:Number = 1;
      
      public static const ORANGE_FISH_RUBY_DROP_AMOUNT:Number = 25;
      
      public static const TIMED_ZONE_RUBY_DROP_AMOUNT:Number = 5;
      
      public static const BOSS_ZONE_RUBY_DROP_AMOUNT:Number = 25;
      
      public static const RUBY_SHOP_APPEARANCE_COOLDOWN:int = 1500000;
      
      public static const RUBY_SHOP_APPEARANCE_DURATION:int = 300000;
      
      public static const ANCIENT_SHARD_DAMAGE_BONUS:Number = 1.1;
      
      public static const ANCIENT_SHARD_PURCHASE_COOLDOWN:int = 84600000;
      
      public static const ETHEREAL_ITEM_PURCHASE_COOLDOWN:int = 84600000;
      
      public static const TRANSCENDENCE_MOTE_PURCHASE_COOLDOWN:Number = 84600000;
      
      public static const AUTOMATOR_POINT_PURCHASE_COOLDOWN:int = 14400000;
      
      public static const POWER_RUNE_DAMAGE_BONUS:Number = 0.1;
      
      public static const SPEED_RUNE_HASTE_BONUS:Number = 0.1;
      
      public static const LUCK_RUNE_CRITICAL_BONUS:Number = 0.05;
      
      public static const METAL_DETECTOR_GOLD_BONUS:Number = 1.5;
      
      public static const METAL_DETECTOR_TIME_DURATION:Number = 1200000;
      
      public static const METAL_DETECTOR_ZONE_DURATION:Number = 5;
      
      public static const MAGICAL_BREW_MANA_AMOUNT:Number = 10;
      
      public static const DEFAULT_UPGRADEABLE_STATS:Array = [CH2.STAT_GOLD,CH2.STAT_CRIT_CHANCE,CH2.STAT_CRIT_DAMAGE,CH2.STAT_HASTE,CH2.STAT_CLICKABLE_GOLD,CH2.STAT_CLICK_DAMAGE,CH2.STAT_MONSTER_GOLD,CH2.STAT_ITEM_COST_REDUCTION,CH2.STAT_TOTAL_MANA,CH2.STAT_MANA_REGEN,CH2.STAT_TOTAL_ENERGY,CH2.STAT_CLICKABLE_CHANCE,CH2.STAT_BONUS_GOLD_CHANCE,CH2.STAT_TREASURE_CHEST_CHANCE,CH2.STAT_TREASURE_CHEST_GOLD,CH2.STAT_ITEM_WEAPON_DAMAGE,CH2.STAT_ITEM_HEAD_DAMAGE,CH2.STAT_ITEM_CHEST_DAMAGE,CH2.STAT_ITEM_RING_DAMAGE,CH2.STAT_ITEM_LEGS_DAMAGE,CH2.STAT_ITEM_HANDS_DAMAGE,CH2.STAT_ITEM_FEET_DAMAGE,CH2.STAT_ITEM_BACK_DAMAGE,CH2.STAT_AUTOMATOR_SPEED,CH2.STAT_AUTOATTACK_DAMAGE];
      
      public static const VALUES_RESET_AT_ASCENSION:Array = ["state","timeSinceLastClickAttack","timeSinceLastSkill","timeSinceLastAutoAttack","consecutiveOneShottedMonsters","gold","castTimeRemaining","castTime","skillBeingCast","buffs","inventory","currentCatalogRank","catalogItemsForSale","isPurchasingLocked","currentZone","highestZone","totalRunDistance","totalGold","monstersKilled","monstersKilledPerZone","powerRuneActivated","speedRuneActivated","luckRuneActivated","timeMetalDetectorActive","zoneMetalDetectorActive","zoneStartGold"];
      
      public static const NUMBER_OF_ETHEREAL_ITEM_SLOTS:int = 8;
      
      public static const MAX_ETHEREAL_STORAGE_SIZE:int = 72;
      
      public static const ETHEREAL_ITEM_RUBY_SELL_PRICE:int = 50;
      
      public static var staticTutorialInstances:Object = {};
      
      public static var staticSkillInstances:Object = {};
      
      public static var staticFields:Array = ["flavorName","flavorClass","flavor","characterSelectOrder","availableForCreation","visibleOnCharacterSelect","defaultSaveName","startingSkills","levelCostScaling","upgradeableStats","traitsToLevel","assetGroupName","damageMultiplierBase","maxManaMultiplierBase","maxEnergyMultiplierBase","attackMsDelay","gcdBase","gcdMinimum","autoAttackDamageMultiplierBase","damageMultiplierValueFunction","maxManaMultiplierValueFunction","maxEnergyMultiplierValueFunction","damageMultiplierCostFunction","maxManaMultiplierCostFunction","maxEnergyMultiplierCostFunction","statValueFunctions","statPanelTraits","traitInfo","statBaseValues","monstersPerZone","preKumaMonstersPerZone","monsterHealthMultiplier","attackRange","levelGraph","levelGraphNodeTypes","transcensionPerks","systemTraits","hardcodedSystemTraits","gildStartBuild","etherealTraitTooltipInfo","traitTooltipInfo"];
       
      
      public var isMouseOverClickableActivationUnlocked:Boolean = false;
      
      public var numUserInputActions:Number;
      
      public var sidePanelIsVisible:Boolean;
      
      public var equippedEtherealItems:Object;
      
      public var etherealItemStorage:Object;
      
      public var etherealItemInventory:Array;
      
      public var etherealItemStats:Object;
      
      public var etherealItemStatChoices:Array;
      
      public var etherealItemSpecialChoices:Array;
      
      public var shouldShowNewEtherealItemPopup:Boolean = false;
      
      public var etherealItemIndiciesForPopup:Array;
      
      public var specialEtherealItemChance:Number = 0.03333333333333333;
      
      public var canChangeEtherealEquipment:Boolean = false;
      
      public var pendingEtherealEquipmentChanges:Object;
      
      public var modDependencies:Object;
      
      public var version:Number = 0;
      
      public var hasSeenMigrationPopup:Boolean = true;
      
      public var state:int = 5;
      
      public var monstersPerZone:Number = 50;
      
      public var preKumaMonstersPerZone:Number = 50;
      
      public var worldsPerSystem:Number = 30;
      
      public var monsterHealthMultiplier:Number = 1;
      
      public var attackRange:int = 90;
      
      public var isAbleToCollectGoldDrops:Boolean = true;
      
      public var doesAttractCoins:Boolean = true;
      
      public var bagOfGoldPrice:Number = 1;
      
      public var timeUntilClickableRoll:Number = 300000;
      
      public var unarmedDamage:BigNumber;
      
      public var timeSinceLastClickAttack:Number = 0;
      
      public var timeSinceLastSkill:Number = 0;
      
      public var timeSinceLastAutoAttack:Number = 0;
      
      public var autoAttacksNotInterrupted:Boolean = false;
      
      public var consecutiveOneShottedMonsters:Number = 0;
      
      public var consecutiveEasyBossesKilled:Number = 0;
      
      public var clickAttackEnergyCost:int = 1;
      
      public var heroId:int = 1;
      
      public var name:String;
      
      public var creationTime:Number;
      
      public var extendedVariables:ExtendedVariables;
      
      public var serializedExtendedVariables:Object;
      
      public var skins:Array;
      
      public var selectedSkinIndex:int = 0;
      
      public var roller:Roller;
      
      public var startingRollerValue:int;
      
      public var hasEditedSave:Boolean = false;
      
      public var gold:BigNumber;
      
      public var zoneStartGold:BigNumber;
      
      public var rubies:Number = 0;
      
      public var mana:Number = 100;
      
      public var energy:Number = 100;
      
      public var timeSinceLastRubyShopAppearance:int = 0;
      
      public var rubyPurchaseOptions:Array;
      
      public var currentRubyShop:Array;
      
      public var ancientShards:Number = 0;
      
      public var transcendenceMotes:Number = 0;
      
      public var currentTranscendenceMoteCooldown:Number = 84600000;
      
      public var timeSinceLastAncientShardPurchase:int = 84600000;
      
      public var timeSinceLastEtherealItemPurchase:int = 84600000;
      
      public var timeSinceLastTranscendenceMotePurchase:Number = 0;
      
      public var timeSinceLastAutomatorPointPurchase:int = 14400000;
      
      public var powerRuneActivated:Boolean = false;
      
      public var speedRuneActivated:Boolean = false;
      
      public var luckRuneActivated:Boolean = false;
      
      public var timeMetalDetectorActive:Boolean = false;
      
      public var timeSinceTimeMetalDetectorActivated:Number;
      
      public var zoneMetalDetectorActive:Boolean = false;
      
      public var zoneOfZoneMetalDetectorActivation:Number;
      
      public var zoneToShowPerWorld:Object;
      
      public var hasActivatedMassiveOrangeFish:Object;
      
      public var inputLogger:InputLog;
      
      public var eventLogger:EventLog;
      
      public var trackedDps:TrackedStat;
      
      public var trackedOverkill:TrackedStat;
      
      public var trackedGoldGained:TrackedStat;
      
      public var trackedGoldSpent:TrackedStat;
      
      public var trackedEnergyUsed:TrackedStat;
      
      public var trackedManaUsed:TrackedStat;
      
      public var trackedFrameMsec:TrackedStat;
      
      public var trackedXPEarned:TrackedStat;
      
      public var drawCounts:TrackedStat;
      
      public var gcdRemaining:Number = 0;
      
      public var castTimeRemaining:Number = 0;
      
      public var castTime:Number = 0;
      
      public var skillBeingCast:Skill;
      
      public var worlds:AscensionWorlds;
      
      public var starSystems:Array;
      
      public var starSystemAncientShards:Object;
      
      public var starSystemTimesSinceLastAncientShardPurchase:Object;
      
      public var killedMonsterDuringWorld:Boolean = false;
      
      public var interactedWithGameDuringDuringWorld:Boolean = false;
      
      public var buffs:Buffs;
      
      public var inventory:Items;
      
      public var shouldLevelToNextMultiplier:Boolean = false;
      
      public var excludedItemStats:Array;
      
      public var currentCatalogRank:Number = 0;
      
      public var catalogItemsForSale:Array;
      
      public var isPurchasingLocked:Boolean = false;
      
      public var automator:Automator;
      
      public var currentWorldEndAutomationOption:int = -1;
      
      public var worldEndAutomationOptions:Array;
      
      public var automatorStones:Number = 0;
      
      public var currentTutorial:Tutorial = null;
      
      public var tutorials:Array;
      
      public var timeOfLastRun:Number = 0;
      
      public var timeOfLastAscension:Number = 0;
      
      public var timeCharacterWasUnlocked:Number = 0;
      
      public var timeOnlineMilliseconds:Number = 0;
      
      public var timeOfflineMilliseconds:Number = 0;
      
      public var serverTimeOfLastUpdate:Number = 0;
      
      public var timeOfLastCatalogPurchase:Number = 0;
      
      public var timeOfLastItemUpgrade:Number = 0;
      
      public var timeOfLastOutOfEnergy:Number = 0;
      
      public var timeOfLastLevelUp:Number = 0;
      
      public var treasureChestsAreMonsters:Number = 0;
      
      public var clickablesHaveTreasureChestGold:Number = 0;
      
      public var treasureChestsHaveClickableGold:Number = 0;
      
      public var didFinishWorld:Boolean = true;
      
      public var currentZone:Number = 1;
      
      public var highestZone:Number = 1;
      
      public var totalRunDistance:Number = 0;
      
      public var totalGold:BigNumber;
      
      public var highestItemTierSeen:Number = 0;
      
      public var monstersKilled:Number = 0;
      
      public var monstersKilledPerZone:Object;
      
      public var currentWorldId:Number = 1;
      
      public var totalUpgradesToItems:Number = 0;
      
      public var totalCatalogItemsPurchased:Number = 0;
      
      public var totalOneShotMonsters:Number = 0;
      
      public var totalSkillsUsed:Number = 0;
      
      public var attemptsOnCurrrentBoss:Number = 0;
      
      public var timeSinceRegularMonsterHasDroppedRubies:Number = 0;
      
      public var timeSinceLastOrangeFishAppearance:Number = 0;
      
      public var hasPurchasedFirstSkill:Boolean = false;
      
      public var hasUnlockedAutomator:Boolean = false;
      
      public var hasUnlockedTranscendencePanel:Boolean = false;
      
      public var hasSeenMainPanel:Boolean = false;
      
      public var hasSeenItemsPanel:Boolean = false;
      
      public var hasSeenGraphPanel:Boolean = false;
      
      public var hasSeenSkillsPanel:Boolean = false;
      
      public var hasSeenAutomatorPanel:Boolean = false;
      
      public var hasSeenEtherealPanel:Boolean = false;
      
      public var hasSeenWorldsPanel:Boolean = false;
      
      public var hasSeenMiscPanel:Boolean = false;
      
      public var hasSeenTranscendencePanel:Boolean = false;
      
      public var transcensionLevel:Number = 0;
      
      public var hasReceivedFirstTimeEnergy:Boolean = false;
      
      public var hasSeenRubyShopPanel:Boolean = false;
      
      public var onlineTimeAsOfLastRubyShopMilliseconds:Number;
      
      public var numGameLoopsProcessed:Number = 0;
      
      public var gameTimeProcessed:Number = 0;
      
      public var totalRubies:Number = 0;
      
      public var numAscensions:Number = 0;
      
      public var achievements:Achievements;
      
      public var hasNewSkillTreePointsAvailable:Boolean = false;
      
      public var hasNewSkillAvailable:Boolean = false;
      
      public var isItemPanelUnlockedHandler:Object = null;
      
      public var isEtherealPanelUnlockedHandler:Object = null;
      
      public var isGraphPanelUnlockedHandler:Object = null;
      
      public var isSkillPanelUnlockedHandler:Object = null;
      
      public var isTranscendencePanelUnlockedHandler:Object = null;
      
      public var isAutomatorPanelUnlockedHandler:Object = null;
      
      public var isWorldsPanelUnlockedHandler:Object = null;
      
      public var isMiscPanelUnlockedHandler:Object = null;
      
      public var shouldSlideInMainPanelForFirstTimeHandler:Object = null;
      
      public var assetGroupName:String;
      
      public var skills:Object;
      
      public var activeSkills:Array;
      
      public var level:Number = 1;
      
      public var totalStatPointsV2:Number = 0;
      
      public var didConvertTotalStatPointsToV2ThisIsStupid:Boolean = false;
      
      public var carryoverStatPoints:Number = 0;
      
      public var ascensionStartStatPoints:Number = 0;
      
      public var automatorPoints:int = 0;
      
      public var totalExperience:BigNumber;
      
      public var experienceAtRunStart:BigNumber;
      
      public var experienceForCurrentWorld:BigNumber;
      
      public var experience:BigNumber;
      
      public var worldCrumbs:BigNumber;
      
      public var heroSouls:BigNumber;
      
      public var pendingHeroSouls:BigNumber;
      
      public var starfire:Number = 0;
      
      public var stellarRadiance:Number = 0;
      
      public var astralDiamonds:Number = 0;
      
      public var highestEtherealItemAcquired:Number = 0;
      
      public var highestWorldCompleted:Number = 0;
      
      public var fastestWorldTimes:Object;
      
      public var runsCompletedPerWorld:Object;
      
      public var highestMonstersKilled:Object;
      
      public var statLevels:Object;
      
      public var statLevelMultipliers:Object;
      
      public var isLocked:Boolean = true;
      
      public var spentStatPoints:BigNumber;
      
      public var gilds:int = 0;
      
      public var ascensionDamageMultiplier:BigNumber;
      
      public var hasNeverStartedWorld:Boolean = true;
      
      public var lostOnAscending:Array;
      
      public var lostOnTranscension:Array;
      
      public var skipOnValidation:Array;
      
      public var isViewingAutomatorTree:Boolean = false;
      
      public var skillTreeViewX:Number = 0;
      
      public var skillTreeViewY:Number = 0;
      
      public var automatorTreeViewX:Number = 15741;
      
      public var automatorTreeViewY:Number = -125;
      
      public var nodeLevels:Object;
      
      public var flavorName:String;
      
      public var flavorClass:String;
      
      public var flavor:String;
      
      public var characterSelectOrder:Number;
      
      public var availableForCreation:Boolean;
      
      public var visibleOnCharacterSelect:Boolean;
      
      public var defaultSaveName:String;
      
      public var startingSkills:Array;
      
      public var levelCostScaling:String;
      
      public var upgradeableStats:Array;
      
      public var traitsToLevel:Array;
      
      public var attackMsDelay:Number;
      
      public var gcdBase:Number;
      
      public var gcdMinimum:Number;
      
      public var item10LvlDmgMultiplier:Number = 2;
      
      public var item20LvlDmgMultiplier:Number = 1.5;
      
      public var item50LvlDmgMultiplier:Number = 5;
      
      public var item100LvlDmgMultiplier:Number = 5;
      
      public var damageMultiplierBase:Number;
      
      public var maxManaMultiplierBase:Number;
      
      public var maxEnergyMultiplierBase:Number;
      
      public var energyRegenerationBase:Number;
      
      public var autoAttackDamageMultiplierBase:Number;
      
      public var damageMultiplierValueFunction:Function;
      
      public var maxManaMultiplierValueFunction:Function;
      
      public var maxEnergyMultiplierValueFunction:Function;
      
      public var energyRegenerationValueFunction:Function;
      
      public var autoAttackDamageMultiplierValueFunction:Function;
      
      public var damageMultiplierCostFunction:Function;
      
      public var maxManaMultiplierCostFunction:Function;
      
      public var maxEnergyMultiplierCostFunction:Function;
      
      public var energyRegenerationCostFunction:Function;
      
      public var autoAttackDamageMultiplierCostFunction:Function;
      
      public var statValueFunctions:Array;
      
      public var statBaseValues:Array;
      
      public var levelGraphObject:Object;
      
      public var levelGraph:LevelGraph;
      
      public var levelGraphNodeTypes:Object;
      
      public var nodesPurchased:Object;
      
      public var transcensionPerks:Object;
      
      public var transcensionPerkLevels:Object;
      
      public var undoNodes:Object;
      
      public var traits:Object;
      
      public var traitMultipliers:Object;
      
      public var traitInfo:Object;
      
      public var statPanelTraits:Object;
      
      public var traitPersistanceValues:Object;
      
      public var traitTranscensionPersisting:Object;
      
      public var systemTraits:Array;
      
      public var hardcodedSystemTraits:Object;
      
      public var gildStartBuild:Array;
      
      public var etherealTraitTooltipInfo:Object;
      
      public var traitTooltipInfo:Object;
      
      public var characterDisplay:CharacterDisplay;
      
      public var worldEntity:WorldEntity;
      
      public var x:Number;
      
      public var y:Number;
      
      public var applySystemTraitsHandler:Object = null;
      
      public var onWorldStartedHandler:Object = null;
      
      public var onCharacterLoadedHandler:Object = null;
      
      public var onCharacterUnloadedHandler:Object = null;
      
      public var onCharacterDisplayCreatedHandler:Object = null;
      
      public var triggerGlobalCooldownHandler:Object = null;
      
      public var unlockCharacterHandler:Object = null;
      
      public var onAutomatorUnlockedHandler:Object = null;
      
      public var populateWorldEndAutomationOptionsHandler:Object = null;
      
      private var timeUntilDamageCache:int = 100;
      
      private var cachedDamage:Array;
      
      private var nextDamageCacheEntry:int = 0;
      
      private var musicExcitementLevel:int = 0;
      
      private var musicExcitementTimer:int = 0;
      
      private var timeSinceRegen:int = 0;
      
      public var updateHandler:Object = null;
      
      public var cachedTimelapseServerTime = 0;
      
      public var changeStateHandler:Object = null;
      
      public var attackHandler:Object = null;
      
      public var clickAttackHandler:Object = null;
      
      public var autoAttackHandler:Object = null;
      
      public var onClickAttackHandler:Object = null;
      
      public var onTeleportAttackHandler:Object = null;
      
      public var onKilledMonsterHandler:Object = null;
      
      public var onZoneChangedHandler:Object = null;
      
      public var onWorldFinishedHandler:Object = null;
      
      public var getCalculatedEnergyCostHandler:Object = null;
      
      public var onWorldChangeHandler:Object = null;
      
      public var damageValueHandler:Object = null;
      
      public var addGoldHandler:Object = null;
      
      public var addRubiesHandler:Object = null;
      
      public var regenerateManaAndEnergyHandler:Object = null;
      
      public var addEnergyHandler:Object = null;
      
      public var addManaHandler:Object = null;
      
      public var canUseSkillHandler:Object = null;
      
      public var onUsedSkillHandler:Object = null;
      
      public var levelUpItemHandler:Object = null;
      
      public var buyNextItemBonusHandler:Object = null;
      
      public var purchaseCatalogItemHandler:Object = null;
      
      public var generateCatalogHandler:Object = null;
      
      public var walkHandler:Object = null;
      
      private var cachedClassStats:Array;
      
      private var classStatsCached:Boolean = false;
      
      public var gainLevelHandler:Object = null;
      
      public var getLevelUpCostToNextLevelHandler:Object = null;
      
      public var ascendHandler:Object = null;
      
      public var transcendHandler:Object = null;
      
      public var addGildHandler:Object = null;
      
      public var highestDamageExponent:Number = 0;
      
      public var isRubyShopAvailableHandler:Object = null;
      
      public var ancientShardPurchase:RubyPurchase;
      
      public var etherealItemPurchase:RubyPurchase;
      
      public var transcendenceMotePurchase:RubyPurchase;
      
      public var populateRubyPurchaseOptionsHandler:Object = null;
      
      public var generateRubyShopHandler:Object = null;
      
      public var updateRubyShopFieldsHandler:Object = null;
      
      public var onMigrationHandler:Object = null;
      
      public var getItemDamageHandler:Object = null;
      
      public var getSystemTraitCountHandler:Object = null;
      
      public var populateEtherealItemStatsHandler:Object = null;
      
      public function Character()
      {
         this.equippedEtherealItems = {
            0:-1,
            1:-1,
            2:-1,
            3:-1,
            4:-1,
            5:-1,
            6:-1,
            7:-1
         };
         this.etherealItemStorage = {};
         this.etherealItemInventory = [];
         this.etherealItemStats = {};
         this.etherealItemStatChoices = [];
         this.etherealItemSpecialChoices = [];
         this.etherealItemIndiciesForPopup = [];
         this.pendingEtherealEquipmentChanges = {
            0:-1,
            1:-1,
            2:-1,
            3:-1,
            4:-1,
            5:-1,
            6:-1,
            7:-1
         };
         this.modDependencies = {};
         this.unarmedDamage = new BigNumber(1);
         this.serializedExtendedVariables = {};
         this.skins = [];
         this.roller = new Roller();
         this.gold = new BigNumber(0);
         this.zoneStartGold = new BigNumber(0);
         this.rubyPurchaseOptions = [];
         this.currentRubyShop = [];
         this.zoneToShowPerWorld = {};
         this.hasActivatedMassiveOrangeFish = {};
         this.inputLogger = new InputLog();
         this.eventLogger = new EventLog();
         this.worlds = new AscensionWorlds();
         this.starSystems = [];
         this.starSystemAncientShards = {};
         this.starSystemTimesSinceLastAncientShardPurchase = {};
         this.buffs = new Buffs();
         this.inventory = new Items();
         this.excludedItemStats = [];
         this.catalogItemsForSale = [];
         this.automator = new Automator();
         this.worldEndAutomationOptions = [];
         this.tutorials = [];
         this.totalGold = new BigNumber(0);
         this.monstersKilledPerZone = {};
         this.achievements = new Achievements();
         this.skills = {};
         this.activeSkills = [];
         this.totalExperience = new BigNumber(0);
         this.experienceAtRunStart = new BigNumber(0);
         this.experienceForCurrentWorld = new BigNumber(0);
         this.experience = new BigNumber(0);
         this.worldCrumbs = new BigNumber(0);
         this.heroSouls = new BigNumber(0);
         this.pendingHeroSouls = new BigNumber(0);
         this.fastestWorldTimes = {};
         this.runsCompletedPerWorld = {};
         this.highestMonstersKilled = {};
         this.statLevels = {};
         this.statLevelMultipliers = {};
         this.spentStatPoints = new BigNumber(0);
         this.ascensionDamageMultiplier = new BigNumber(1);
         this.lostOnAscending = [];
         this.lostOnTranscension = [];
         this.skipOnValidation = [];
         this.nodeLevels = {};
         this.statValueFunctions = new Array();
         this.statBaseValues = new Array();
         this.nodesPurchased = {};
         this.transcensionPerks = {};
         this.transcensionPerkLevels = {};
         this.undoNodes = {};
         this.traits = {};
         this.traitMultipliers = {};
         this.traitInfo = {};
         this.statPanelTraits = {};
         this.traitPersistanceValues = {};
         this.traitTranscensionPersisting = {};
         this.systemTraits = new Array();
         this.hardcodedSystemTraits = {};
         this.gildStartBuild = new Array();
         this.worldEntity = new WorldEntity();
         this.cachedDamage = [];
         this.cachedClassStats = [];
         super();
         if(CH2.STATS.length == 0)
         {
            CH2.initStats();
         }
         this.x = 20;
         this.y = CHARACTER_ZONE_START_Y;
         this.worldEntity.removeOnZoneChanges = false;
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"serializedExtendedVariables");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"modDependencies");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"version");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"unarmedDamage");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicChild,"worlds",AscensionWorlds);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicCollection,"starSystems",StarSystem);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"starSystemAncientShards");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"starSystemTimesSinceLastAncientShardPurchase");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"killedMonsterDuringWorld");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"interactedWithGameDuringDuringWorld");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"bagOfGoldPrice");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"timeUntilClickableRoll");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicString,"name");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicCollection,"skins",Skin);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"selectedSkinIndex");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicChild,"roller",Roller);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"startingRollerValue");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"equippedEtherealItems");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"etherealItemStorage");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"pendingEtherealEquipmentChanges");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicCollection,"etherealItemInventory",EtherealItem);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicChild,"trackedDps",TrackedStat);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicChild,"trackedOverkill",TrackedStat);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicChild,"trackedGoldGained",TrackedStat);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicChild,"trackedGoldSpent",TrackedStat);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicChild,"trackedEnergyUsed",TrackedStat);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicChild,"trackedManaUsed",TrackedStat);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicChild,"trackedFrameMsec",TrackedStat);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicChild,"trackedXPEarned",TrackedStat);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"gold");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"zoneStartGold");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"rubies");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"energy");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"mana");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"totalRubies");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"numAscensions");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicChild,"achievements",Achievements);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicChild,"inventory",Items);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicChild,"automator",Automator);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"currentWorldEndAutomationOption");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicCollection,"skills",Skill);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"currentCatalogRank");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicCollection,"catalogItemsForSale",Item);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"onlineTimeAsOfLastRubyShopMilliseconds");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"timeOfLastRun");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"timeOfLastAscension");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"timeCharacterWasUnlocked");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"timeOnlineMilliseconds");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"timeOfflineMilliseconds");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"timeOfflineMilliseconds");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"serverTimeOfLastUpdate");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"creationTime");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"timeOfLastOutOfEnergy");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"timeOfLastLevelUp");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"timeOfLastItemUpgrade");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"timeOfLastCatalogPurchase");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"timeSinceLastRubyShopAppearance");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"timeSinceLastAncientShardPurchase");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"timeSinceLastEtherealItemPurchase");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"timeSinceLastTranscendenceMotePurchase");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"timeSinceLastAutomatorPointPurchase");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"ancientShards");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"transcendenceMotes");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"currentTranscendenceMoteCooldown");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"powerRuneActivated");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"speedRuneActivated");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"luckRuneActivated");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"timeMetalDetectorActive");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"timeSinceTimeMetalDetectorActivated");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"zoneMetalDetectorActive");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"zoneOfZoneMetalDetectorActivation");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicCollection,"currentRubyShop",RubyPurchase);
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"zoneToShowPerWorld");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"hasActivatedMassiveOrangeFish");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"didFinishWorld");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"currentZone");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"highestZone");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"totalRunDistance");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"totalGold");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"highestItemTierSeen");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"monstersKilled");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"totalUpgradesToItems");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"totalCatalogItemsPurchased");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"totalOneShotMonsters");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"totalSkillsUsed");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"consecutiveOneShottedMonsters");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"consecutiveEasyBossesKilled");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"currentWorldId");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"attemptsOnCurrrentBoss");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"timeSinceRegularMonsterHasDroppedRubies");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"timeSinceLastOrangeFishAppearance");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"hasPurchasedFirstSkill");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"hasUnlockedAutomator");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"hasUnlockedTranscendencePanel");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"hasSeenMainPanel");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"hasSeenItemsPanel");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"hasSeenGraphPanel");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"hasSeenSkillsPanel");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"hasSeenAutomatorPanel");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"hasSeenEtherealPanel");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"hasSeenWorldsPanel");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"hasSeenMiscPanel");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"hasReceivedFirstTimeEnergy");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"hasSeenRubyShopPanel");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"hasSeenTranscendencePanel");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicNumber,"transcensionLevel");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"nodeLevels");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_FALSE,registerDynamicBoolean,"hasNewSkillTreePointsAvailable");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"highestEtherealItemAcquired");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"treasureChestsAreMonsters");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"treasureChestsHaveClickableGold");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"clickablesHaveTreasureChestGold");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicString,"name");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"level");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"worldCrumbs");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"heroSouls");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"pendingHeroSouls");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"starfire");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"totalStatPointsV2");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"carryoverStatPoints");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"ascensionStartStatPoints");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"automatorPoints");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"didConvertTotalStatPointsToV2ThisIsStupid");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"experience");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"totalExperience");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"experienceForCurrentWorld");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"experienceAtRunStart");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"highestWorldCompleted");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"fastestWorldTimes");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"highestMonstersKilled");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"runsCompletedPerWorld");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"statLevels");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"statLevelMultipliers");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"gcdMinimum");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"isLocked");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"spentStatPoints");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"gilds");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBigNumber,"ascensionDamageMultiplier");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"nodesPurchased");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"undoNodes");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"traits");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"traitMultipliers");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"traitPersistanceValues");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"traitTranscensionPersisting");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"monstersKilledPerZone");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"hasNeverStartedWorld");
         this.persist(ASCENSION_PERSISTING_FALSE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"autoAttacksNotInterrupted");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicBoolean,"hasEditedSave");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"numGameLoopsProcessed");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_FALSE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicNumber,"gameTimeProcessed");
         this.persist(ASCENSION_PERSISTING_TRUE,TRANSCENSION_PERSISTING_TRUE,VALIDATION_CHECK_VALUE_TRUE,registerDynamicObject,"transcensionPerkLevels");
         this.attackMsDelay = 600;
         this.gcdBase = 2000;
         this.gcdMinimum = 1000;
         this.damageMultiplierBase = 1;
         this.maxManaMultiplierBase = 1;
         this.maxEnergyMultiplierBase = 1;
         this.energyRegenerationBase = 1;
         this.autoAttackDamageMultiplierBase = 1;
         this.levelCostScaling = "exponential1_75";
         this.statBaseValues[CH2.STAT_IDLE_GOLD] = 1;
         this.statBaseValues[CH2.STAT_HASTE] = 1;
         this.statBaseValues[CH2.STAT_GOLD] = 1;
         this.statBaseValues[CH2.STAT_CRIT_DAMAGE] = 1.5;
         this.statBaseValues[CH2.STAT_CRIT_CHANCE] = 0;
         this.statBaseValues[CH2.STAT_TOTAL_ENERGY] = 100;
         this.statBaseValues[CH2.STAT_TOTAL_MANA] = 100;
         this.statBaseValues[CH2.STAT_BONUS_GOLD_CHANCE] = 0;
         this.statBaseValues[CH2.STAT_ITEM_COST_REDUCTION] = 1;
         this.statBaseValues[CH2.STAT_CLICK_DAMAGE] = 1;
         this.statBaseValues[CH2.STAT_IDLE_DAMAGE] = 1;
         this.statBaseValues[CH2.STAT_MOVEMENT_SPEED] = 1;
         this.statBaseValues[CH2.STAT_PIERCE_CHANCE] = 0;
         this.statBaseValues[CH2.STAT_MANA_REGEN] = 1;
         this.statBaseValues[CH2.STAT_CLICKABLE_GOLD] = 1;
         this.statBaseValues[CH2.STAT_TREASURE_CHEST_CHANCE] = 0;
         this.statBaseValues[CH2.STAT_TREASURE_CHEST_GOLD] = 1;
         this.statBaseValues[CH2.STAT_MONSTER_GOLD] = 1;
         this.statBaseValues[CH2.STAT_CLICKABLE_CHANCE] = 0;
         this.statBaseValues[CH2.STAT_ENERGY_REGEN] = 0;
         this.statBaseValues[CH2.STAT_DAMAGE] = 1;
         this.statBaseValues[CH2.STAT_ENERGY_COST_REDUCTION] = 0;
         this.statBaseValues[CH2.STAT_ITEM_WEAPON_DAMAGE] = 1;
         this.statBaseValues[CH2.STAT_ITEM_HEAD_DAMAGE] = 1;
         this.statBaseValues[CH2.STAT_ITEM_CHEST_DAMAGE] = 1;
         this.statBaseValues[CH2.STAT_ITEM_RING_DAMAGE] = 1;
         this.statBaseValues[CH2.STAT_ITEM_LEGS_DAMAGE] = 1;
         this.statBaseValues[CH2.STAT_ITEM_HANDS_DAMAGE] = 1;
         this.statBaseValues[CH2.STAT_ITEM_FEET_DAMAGE] = 1;
         this.statBaseValues[CH2.STAT_ITEM_BACK_DAMAGE] = 1;
         this.statBaseValues[CH2.STAT_AUTOMATOR_SPEED] = 1;
         this.statBaseValues[CH2.STAT_AUTOATTACK_DAMAGE] = 1;
         this.monstersPerZone = 50;
         this.monsterHealthMultiplier = 1;
         this.attackRange = 90;
         this.damageMultiplierValueFunction = linear1;
         this.damageMultiplierCostFunction = linear1;
         this.maxManaMultiplierValueFunction = linear1;
         this.maxManaMultiplierCostFunction = linear1;
         this.maxEnergyMultiplierValueFunction = linear1;
         this.maxEnergyMultiplierCostFunction = linear1;
         this.energyRegenerationValueFunction = linear1;
         this.energyRegenerationCostFunction = linear1;
         this.autoAttackDamageMultiplierValueFunction = linear1;
         this.autoAttackDamageMultiplierCostFunction = linear1;
         this.statValueFunctions[CH2.STAT_IDLE_GOLD] = linear(0.25,1);
         this.statValueFunctions[CH2.STAT_HASTE] = onePlusLinearReciprocalComplement(0.005,1,9);
         this.statValueFunctions[CH2.STAT_GOLD] = linear(0.05,1);
         this.statValueFunctions[CH2.STAT_CRIT_DAMAGE] = linear(0.05,1);
         this.statValueFunctions[CH2.STAT_CRIT_CHANCE] = linearReciprocalComplement(0.005,1);
         this.statValueFunctions[CH2.STAT_TOTAL_ENERGY] = linear(10);
         this.statValueFunctions[CH2.STAT_TOTAL_MANA] = linear(10);
         this.statValueFunctions[CH2.STAT_BONUS_GOLD_CHANCE] = linearReciprocalComplement(0.005,1);
         this.statValueFunctions[CH2.STAT_ITEM_COST_REDUCTION] = linearReciprocal(0.005,1);
         this.statValueFunctions[CH2.STAT_CLICK_DAMAGE] = linear(0.05,1);
         this.statValueFunctions[CH2.STAT_IDLE_DAMAGE] = linear(0.25,1);
         this.statValueFunctions[CH2.STAT_MOVEMENT_SPEED] = linear(0.05,1);
         this.statValueFunctions[CH2.STAT_PIERCE_CHANCE] = linear(0.01);
         this.statValueFunctions[CH2.STAT_MANA_REGEN] = linear(0.05,1);
         this.statValueFunctions[CH2.STAT_CLICKABLE_GOLD] = linear(0.05,1);
         this.statValueFunctions[CH2.STAT_TREASURE_CHEST_CHANCE] = linearReciprocalComplement(0.005,1);
         this.statValueFunctions[CH2.STAT_TREASURE_CHEST_GOLD] = linear(0.05,1);
         this.statValueFunctions[CH2.STAT_MONSTER_GOLD] = linear(0.05,1);
         this.statValueFunctions[CH2.STAT_CLICKABLE_CHANCE] = linearReciprocalComplement(0.0005,1);
         this.statValueFunctions[CH2.STAT_ENERGY_REGEN] = linear(0);
         this.statValueFunctions[CH2.STAT_DAMAGE] = linear(0,1);
         this.statValueFunctions[CH2.STAT_ENERGY_COST_REDUCTION] = linear(0);
         this.statValueFunctions[CH2.STAT_ITEM_WEAPON_DAMAGE] = linear(0.1,1);
         this.statValueFunctions[CH2.STAT_ITEM_HEAD_DAMAGE] = linear(0.1,1);
         this.statValueFunctions[CH2.STAT_ITEM_CHEST_DAMAGE] = linear(0.1,1);
         this.statValueFunctions[CH2.STAT_ITEM_RING_DAMAGE] = linear(0.1,1);
         this.statValueFunctions[CH2.STAT_ITEM_LEGS_DAMAGE] = linear(0.1,1);
         this.statValueFunctions[CH2.STAT_ITEM_HANDS_DAMAGE] = linear(0.1,1);
         this.statValueFunctions[CH2.STAT_ITEM_FEET_DAMAGE] = linear(0.1,1);
         this.statValueFunctions[CH2.STAT_ITEM_BACK_DAMAGE] = linear(0.1,1);
         this.statValueFunctions[CH2.STAT_AUTOMATOR_SPEED] = linear(0.5,1);
         this.statValueFunctions[CH2.STAT_AUTOATTACK_DAMAGE] = linear(0.2,1);
         this.achievements.alertSteam = false;
      }
      
      public static function one() : Function
      {
         return function(statLevel:Number):Number
         {
            return 1;
         };
      }
      
      public static function linear(scale:Number, base:Number = 0) : Function
      {
         return function(statLevel:Number):BigNumber
         {
            var result:* = new BigNumber(statLevel);
            result.timesEqualsN(scale);
            return result.addN(base);
         };
      }
      
      public static function linearN(scale:Number, base:Number = 0) : Function
      {
         return function(statLevel:Number):Number
         {
            return base + scale * statLevel;
         };
      }
      
      public static function linearReciprocal(scale:Number, base:Number = 0) : Function
      {
         return function(statLevel:Number):BigNumber
         {
            var result:* = new BigNumber(statLevel);
            result.timesEqualsN(scale);
            result = result.addN(base);
            var one:* = new BigNumber(1);
            return one.divide(result);
         };
      }
      
      public static function linearReciprocalComplement(scale:Number, base:Number = 0, max:Number = 1) : Function
      {
         return function(statLevel:Number):BigNumber
         {
            var result:* = new BigNumber(statLevel);
            result.timesEqualsN(scale);
            result = result.addN(base);
            var one:* = new BigNumber(1);
            result = one.divide(result);
            one.minusEquals(result);
            one.timesEqualsN(max);
            return one;
         };
      }
      
      public static function onePlusLinearReciprocalComplement(scale:Number, base:Number = 0, max:Number = 1) : Function
      {
         return function(statLevel:Number):BigNumber
         {
            var result:* = new BigNumber(statLevel);
            result.timesEqualsN(scale);
            result = result.addN(base);
            var one:* = new BigNumber(1);
            result = one.divide(result);
            one.minusEquals(result);
            one.timesEqualsN(max);
            one = one.addN(1);
            return one;
         };
      }
      
      public static function polynomial(exponent:Number, scale:Number) : Function
      {
         return function(statLevel:Number):Number
         {
            return Math.pow(scale * statLevel + 1,exponent);
         };
      }
      
      public static function temporarySloppyDamageFunction(statLevel:Number) : Number
      {
         if(!statLevel || statLevel == 0)
         {
            return 0;
         }
         var totalExpectedDamage:Number = 1;
         totalExpectedDamage = totalExpectedDamage * Math.pow(1.5,statLevel);
         return totalExpectedDamage - 1;
      }
      
      public static function exponentialMultiplier(base:Number) : Function
      {
         return function(statLevel:Number):BigNumber
         {
            if(!statLevel || statLevel == 0)
            {
               return new BigNumber(1);
            }
            return new BigNumber(base).pow(statLevel);
         };
      }
      
      public static function exponential(base:Number) : Function
      {
         return function(statLevel:Number):Number
         {
            if(!statLevel || statLevel == 0)
            {
               return 0;
            }
            return Math.pow(base,statLevel);
         };
      }
      
      public static function linearExponential(start:Number, scale:Number, base:Number) : Function
      {
         return function(statLevel:Number):BigNumber
         {
            var result:* = new BigNumber(base).pow(statLevel);
            var level:* = new BigNumber(statLevel);
            level.timesEqualsN(scale);
            level = level.addN(start);
            result.timesEquals(level);
            return result;
         };
      }
      
      public static function exponentialComplement(base:Number) : Function
      {
         return function(statLevel:Number):Number
         {
            if(!statLevel || statLevel == 0)
            {
               return 1;
            }
            return 1 - Math.pow(base,statLevel);
         };
      }
      
      public static function diminishing(limit:Number, step:Number) : Function
      {
         return function(statLevel:Number):Number
         {
            return limit * (1 - Math.exp(-step * statLevel));
         };
      }
      
      public static function linear1(statLevel:Number) : Number
      {
         return 1 * statLevel;
      }
      
      public static function linear2(statLevel:Number) : Number
      {
         return 2 * statLevel;
      }
      
      public static function scaleLinearlyWithStatLevel(statKey:String, characterInstance:Character) : Function
      {
         return function(exchangeRate:Number):Number
         {
            if(characterInstance.statLevels[statKey])
            {
               return exchangeRate * characterInstance.statLevels[statKey];
            }
            return 0;
         };
      }
      
      public static function scaleLinearlyWithTraitLevel(traitKey:String, characterInstance:Character) : Function
      {
         return function(exchangeRate:Number):Number
         {
            if(characterInstance.getTrait(traitKey))
            {
               return exchangeRate * characterInstance.getTrait(traitKey);
            }
            return 0;
         };
      }
      
      public static function scaleLinearlyWithSkillPoints(characterInstance:Character) : Function
      {
         return function(exchangeRate:Number):Number
         {
            return exchangeRate * characterInstance.totalStatPointsV2;
         };
      }
      
      public static function scaleLinearlyWithSystem(characterInstance:Character) : Function
      {
         return function(exchangeRate:Number):Number
         {
            return exchangeRate * Math.floor(characterInstance.currentWorldId / characterInstance.worldsPerSystem);
         };
      }
      
      public static function etherealExchangeRateFunction(scaler:Number) : Function
      {
         return function(systemNumber:int):Number
         {
            var _loc13_:* = undefined;
            return 0;
         };
      }
      
      public static function transcendentStatPerk(perkId:String, stat:int, tooltipFunction:Function, costFunction:Function, iconName:String, maxLevel:Number = -1, statLevelMultiplier:Number = 1.1) : Object
      {
         var result:Object = new Object();
         result["name"] = "Transcendent " + CH2.STATS[stat].displayName;
         result["description"] = "Increases the power of " + CH2.STATS[stat].displayName + " nodes in the skill tree.";
         result["tooltipFunction"] = tooltipFunction;
         result["costFunction"] = costFunction;
         result["levelFunction"] = function():*
         {
            CH2.currentCharacter.statLevelMultipliers[stat] = CH2.currentCharacter.statLevelMultipliers[stat] * statLevelMultiplier;
         };
         result["maxLevel"] = maxLevel;
         result["icon"] = iconName;
         return result;
      }
      
      public static function transcendentTraitPerk(perkId:String, trait:String, traitDisplayName:String, tooltipFunction:Function, costFunction:Function, iconName:String, maxLevel:Number = -1, traitMultiplier:Number = 1.1) : Object
      {
         var result:Object = new Object();
         result["name"] = "Transcendent " + traitDisplayName;
         result["description"] = "Increases the power of " + traitDisplayName + " nodes in the skill tree.";
         result["tooltipFunction"] = tooltipFunction;
         result["costFunction"] = costFunction;
         result["levelFunction"] = function():*
         {
            CH2.currentCharacter.traitMultipliers[trait] = CH2.currentCharacter.getTraitMultiplier(trait) * traitMultiplier;
         };
         result["maxLevel"] = maxLevel;
         result["icon"] = iconName;
         return result;
      }
      
      public static function getStatTooltipFunction(statId:int, extraLevels:Number = 0, baseValueOnly:Boolean = false) : Function
      {
         return function(nodeLevel:Number):String
         {
            var statIncrease:* = undefined;
            var currentStatLevel:* = undefined;
            var currentStatLevelValue:* = undefined;
            var statValueFunction:* = CH2.currentCharacter.statValueFunctions[statId];
            var statLevel:* = extraLevels + nodeLevel;
            var multiplier:* = 1;
            if(CH2.currentCharacter.statLevelMultipliers[statId])
            {
               multiplier = CH2.currentCharacter.statLevelMultipliers[statId];
            }
            if(CH2.currentCharacter.statLevels[statId] && !baseValueOnly)
            {
               currentStatLevel = CH2.currentCharacter.statLevels[statId];
               currentStatLevel = currentStatLevel * multiplier;
               currentStatLevelValue = statValueFunction(currentStatLevel);
               statIncrease = statValueFunction(currentStatLevel + statLevel * multiplier);
               statIncrease.minusEquals(currentStatLevelValue);
               statIncrease.timesEqualsN(100);
            }
            else
            {
               statIncrease = statValueFunction(statLevel * multiplier);
               statIncrease.timesEqualsN(100);
               statIncrease = statIncrease.addN(-100);
            }
            return "Increases your " + CH2.STATS[statId].displayName + " by " + statIncrease.toFixed(2) + "%.";
         };
      }
      
      public static function getStatTooltipFunctionChance(statId:int, extraLevels:Number = 0, baseValueOnly:Boolean = false) : Function
      {
         return function(nodeLevel:Number):String
         {
            var statIncrease:* = undefined;
            var currentStatLevel:* = undefined;
            var statValueFunction:* = CH2.currentCharacter.statValueFunctions[statId];
            var statLevel:* = extraLevels + nodeLevel;
            var multiplier:* = 1;
            if(CH2.currentCharacter.statLevelMultipliers[statId])
            {
               multiplier = CH2.currentCharacter.statLevelMultipliers[statId];
            }
            if(CH2.currentCharacter.statLevels[statId] && !baseValueOnly)
            {
               currentStatLevel = CH2.currentCharacter.statLevels[statId];
               currentStatLevel = currentStatLevel * multiplier;
               statIncrease = (statValueFunction(currentStatLevel + statLevel * multiplier) - statValueFunction(currentStatLevel)) * 100;
            }
            else
            {
               statIncrease = statValueFunction(statLevel * multiplier) * 100;
            }
            return "Increases your " + CH2.STATS[statId].displayName + " by " + statIncrease.toFixed(2) + "%.";
         };
      }
      
      public static function getStatTooltipFunctionReduction(statId:int, extraLevels:Number = 0, baseValueOnly:Boolean = false) : Function
      {
         return function(nodeLevel:Number):String
         {
            var statIncrease:* = undefined;
            var currentStatLevel:* = undefined;
            var statValueFunction:* = CH2.currentCharacter.statValueFunctions[statId];
            var statLevel:* = extraLevels + nodeLevel;
            var multiplier:* = 1;
            if(CH2.currentCharacter.statLevelMultipliers[statId])
            {
               multiplier = CH2.currentCharacter.statLevelMultipliers[statId];
            }
            if(CH2.currentCharacter.statLevels[statId] && !baseValueOnly)
            {
               currentStatLevel = CH2.currentCharacter.statLevels[statId];
               currentStatLevel = currentStatLevel * multiplier;
               statIncrease = (statValueFunction(currentStatLevel + statLevel * multiplier) - statValueFunction(currentStatLevel)) * 100;
            }
            else
            {
               statIncrease = (CH2.currentCharacter.statBaseValues[statId] - statValueFunction(statLevel * multiplier)) * 100;
            }
            return "Increases your " + CH2.STATS[statId].displayName + " by " + statIncrease.toFixed(2) + "%.";
         };
      }
      
      public static function getStatTooltipFunctionNoPercent(statId:int, extraLevels:Number = 0, baseValueOnly:Boolean = false) : Function
      {
         return function(nodeLevel:Number):String
         {
            var statIncrease:* = undefined;
            var currentStatLevel:* = undefined;
            var statValueFunction:* = CH2.currentCharacter.statValueFunctions[statId];
            var statLevel:* = extraLevels + nodeLevel;
            var multiplier:* = 1;
            if(CH2.currentCharacter.statLevelMultipliers[statId])
            {
               multiplier = CH2.currentCharacter.statLevelMultipliers[statId];
            }
            if(CH2.currentCharacter.statLevels[statId] && !baseValueOnly)
            {
               currentStatLevel = CH2.currentCharacter.statLevels[statId];
               currentStatLevel = currentStatLevel * multiplier;
               statIncrease = statValueFunction(currentStatLevel + statLevel * multiplier) - statValueFunction(currentStatLevel);
            }
            else
            {
               statIncrease = statValueFunction(statLevel * multiplier);
            }
            return "Increases your " + CH2.STATS[statId].displayName + " by " + statIncrease.toFixed(2) + ".";
         };
      }
      
      public static function getTraitTooltipFunction(trait:String, extraLevels:Number = 0) : Function
      {
         return function(nodeLevel:Number):String
         {
            var traitLevel:* = nodeLevel + extraLevels;
            var multiplier:* = CH2.currentCharacter.getTraitMultiplier(trait);
            traitLevel = traitLevel * multiplier;
            var tooltipFormat:* = CH2.currentCharacter.traitTooltipInfo[trait].tooltipFormat;
            var traitValueFunction:* = CH2.currentCharacter.traitTooltipInfo[trait].valueFunction;
            return _(tooltipFormat,traitValueFunction(traitLevel));
         };
      }
      
      public static function getTranscendencePerkTooltipFunctionCommon(key:String) : Function
      {
         return function():String
         {
            var costFunction:* = CH2.currentCharacter.transcensionPerks[key].costFunction;
            var perkLevel:* = 0;
            if(CH2.currentCharacter.transcensionPerkLevels[key])
            {
               perkLevel = CH2.currentCharacter.transcensionPerkLevels[key];
            }
            if(isPerkMaxLevel(key))
            {
               return StringFormatter.colorize("Level " + perkLevel + " (MAX)","#FFFF00");
            }
            return StringFormatter.colorize("Level " + perkLevel,"#FFFF00") + "\nCost of Next Level: " + BigNumberFormatter.shortenNumber(costFunction(perkLevel).ceil()) + " Hero Souls";
         };
      }
      
      public static function getTranscendencePerkTooltipFunctionWithTraitValue(key:String, traitName:String, traitMultiplier:Number) : Function
      {
         return function():String
         {
            var costFunction:* = CH2.currentCharacter.transcensionPerks[key].costFunction;
            var perkLevel:* = 0;
            var currentTraitMultiplier:* = CH2.currentCharacter.getTraitMultiplier(traitName);
            var nextLevelTraitMultiplier:* = CH2.currentCharacter.getTraitMultiplier(traitName) * traitMultiplier;
            if(CH2.currentCharacter.transcensionPerkLevels[key])
            {
               perkLevel = CH2.currentCharacter.transcensionPerkLevels[key];
            }
            if(isPerkMaxLevel(key))
            {
               return StringFormatter.colorize("Level " + perkLevel + " (MAX)","#FFFF00");
            }
            return StringFormatter.colorize("Level " + perkLevel,"#FFFF00") + "\nCost of Next Level: " + BigNumberFormatter.shortenNumber(costFunction(perkLevel).ceil()) + " Hero Souls\n\nCurrent Multiplier: " + currentTraitMultiplier.toFixed(2) + "x\n\nNext Level Multiplier: " + nextLevelTraitMultiplier.toFixed(2) + "x";
         };
      }
      
      public static function getTranscendencePerkTooltipFunction(stat:int, key:String) : Function
      {
         return function():String
         {
            var currentBaseValueEffect:* = getStatTooltipFunction(stat,0,true);
            var levelDifference:* = 0.1;
            var nextBaseValueEffect:* = getStatTooltipFunction(stat,levelDifference,true);
            var tooltip:* = getTranscendencePerkTooltipFunctionCommon(key)() + "\n\nCurrent Node Effect: " + currentBaseValueEffect(1);
            if(!isPerkMaxLevel(key))
            {
               return tooltip + "\n\nEffect Next Level: " + nextBaseValueEffect(1);
            }
            return tooltip;
         };
      }
      
      public static function getTranscendencePerkTooltipFunctionChance(stat:int, key:String) : Function
      {
         return function():String
         {
            var currentBaseValueEffect:* = getStatTooltipFunctionChance(stat,0,true);
            var levelDifference:* = 0.1;
            var nextBaseValueEffect:* = getStatTooltipFunctionChance(stat,levelDifference,true);
            var tooltip:* = getTranscendencePerkTooltipFunctionCommon(key)() + "\n\nCurrent Node Effect: " + currentBaseValueEffect(1);
            if(!isPerkMaxLevel(key))
            {
               return tooltip + "\n\nEffect Next Level: " + nextBaseValueEffect(1);
            }
            return tooltip;
         };
      }
      
      public static function getTranscendencePerkTooltipFunctionReduction(stat:int, key:String) : Function
      {
         return function():String
         {
            var currentBaseValueEffect:* = getStatTooltipFunctionReduction(stat,0,true);
            var levelDifference:* = 0.1;
            var nextBaseValueEffect:* = getStatTooltipFunctionReduction(stat,levelDifference,true);
            var tooltip:* = getTranscendencePerkTooltipFunctionCommon(key)() + "\n\nCurrent Node Effect: " + currentBaseValueEffect(1);
            if(!isPerkMaxLevel(key))
            {
               return tooltip + "\n\nEffect Next Level: " + nextBaseValueEffect(1);
            }
            return tooltip;
         };
      }
      
      public static function getTranscendencePerkTooltipFunctionNoPercent(stat:int, key:String) : Function
      {
         return function():String
         {
            var currentBaseValueEffect:* = getStatTooltipFunctionNoPercent(stat,0,true);
            var levelDifference:* = 0.1;
            var nextBaseValueEffect:* = getStatTooltipFunctionNoPercent(stat,levelDifference,true);
            var tooltip:* = getTranscendencePerkTooltipFunctionCommon(key)() + "\n\nCurrent Node Effect: " + currentBaseValueEffect(1);
            if(!isPerkMaxLevel(key))
            {
               return tooltip + "\n\nEffect Next Level: " + nextBaseValueEffect(1);
            }
            return tooltip;
         };
      }
      
      public static function getTraitTranscendencePerkTooltipFunction(trait:String, key:String) : Function
      {
         return function():String
         {
            var currentBaseValueEffect:* = undefined;
            var levelDifference:* = undefined;
            var nextBaseValueEffect:* = undefined;
            var tooltip:* = getTranscendencePerkTooltipFunctionCommon(key)();
            if(CH2.currentCharacter.traitTooltipInfo.hasOwnProperty(trait))
            {
               currentBaseValueEffect = getTraitTooltipFunction(trait);
               levelDifference = 0.1;
               nextBaseValueEffect = getTraitTooltipFunction(trait,levelDifference);
               tooltip = tooltip + ("\n\nCurrent Node Effect: " + currentBaseValueEffect(1));
               if(!isPerkMaxLevel(key))
               {
                  return tooltip + "\n\nEffect Next Level: " + nextBaseValueEffect(1);
               }
            }
            return tooltip;
         };
      }
      
      public static function isPerkMaxLevel(perkId:String) : Boolean
      {
         if(CH2.currentCharacter.transcensionPerks[perkId].maxLevel != -1 && CH2.currentCharacter.transcensionPerkLevels[perkId] >= CH2.currentCharacter.transcensionPerks[perkId].maxLevel)
         {
            return true;
         }
         return false;
      }
      
      public function get timeSinceLastActiveAction() : Number
      {
         return Math.min(this.timeSinceLastClickAttack,this.timeSinceLastSkill);
      }
      
      public function get shouldAutoAttack() : Boolean
      {
         return this.millisecondsBeforeNextAutoAttack <= 0 && !this.isCasting;
      }
      
      public function get isPaused() : Boolean
      {
         return this.state == STATE_PAUSED;
      }
      
      public function get millisecondsBeforeNextAutoAttack() : Number
      {
         if(this.autoAttacksNotInterrupted)
         {
            return this.attackDelay - this.timeSinceLastAutoAttack;
         }
         return this.attackDelay - this.timeSinceLastAttack;
      }
      
      public function get millisecondsBeforeNextMonsterReached() : Number
      {
         var distance:Number = NaN;
         var closestMonster:Monster = CH2.world.getNextMonster();
         if(closestMonster)
         {
            distance = (closestMonster.y - this.worldEntity.y - this.attackRange) / Character.ONE_METER_Y_DISTANCE;
            return distance / this.walkSpeed * 1000;
         }
         return Number.MAX_VALUE;
      }
      
      public function get timeSinceLastAttack() : Number
      {
         return Math.min(this.timeSinceLastClickAttack,this.timeSinceLastAutoAttack,this.timeSinceLastSkill);
      }
      
      public function get isNextMonsterInRange() : Boolean
      {
         var closestMonster:Monster = CH2.world.getNextMonster();
         if(closestMonster)
         {
            return closestMonster.y - this.y <= this.attackRange;
         }
         return false;
      }
      
      public function get isIdle() : Boolean
      {
         return this.timeSinceLastActiveAction > MS_DELAY_BEFORE_IDLE;
      }
      
      public function get isInTeleportClickAttackState() : Boolean
      {
         return this.state == STATE_WALKING || this.state == STATE_ENDING_COMBAT;
      }
      
      public function get isCasting() : Boolean
      {
         return this.state == STATE_CASTING && this.castTime > 0;
      }
      
      public function get canAffordClickAttack() : Boolean
      {
         return this.energy >= this.clickAttackEnergyCost;
      }
      
      public function writeExtendedVariables() : void
      {
         if(this.extendedVariables)
         {
            this.serializedExtendedVariables = this.extendedVariables.toJsonObject();
         }
      }
      
      public function readExtendedVariables() : void
      {
         if(this.extendedVariables)
         {
            this.extendedVariables.fromJsonObject(this.serializedExtendedVariables);
         }
      }
      
      public function isItemPanelUnlocked() : Boolean
      {
         if(this.isItemPanelUnlockedHandler)
         {
            return this.isItemPanelUnlockedHandler.isItemPanelUnlockedOverride();
         }
         return this.isItemPanelUnlockedDefault();
      }
      
      public function isItemPanelUnlockedDefault() : Boolean
      {
         return true;
      }
      
      public function isEtherealPanelUnlocked() : Boolean
      {
         if(this.isEtherealPanelUnlockedHandler)
         {
            return this.isEtherealPanelUnlockedHandler.isEtherealPanelUnlockedOverride();
         }
         return this.isEtherealPanelUnlockedDefault();
      }
      
      public function isEtherealPanelUnlockedDefault() : Boolean
      {
         return this.hasSeenEtherealPanel || this.etherealItemInventory.length > 0;
      }
      
      public function isGraphPanelUnlocked() : Boolean
      {
         if(this.isGraphPanelUnlockedHandler)
         {
            return this.isGraphPanelUnlockedHandler.isGraphPanelUnlockedOverride();
         }
         return this.isGraphPanelUnlockedDefault();
      }
      
      public function isGraphPanelUnlockedDefault() : Boolean
      {
         return this.level >= 2;
      }
      
      public function isSkillPanelUnlocked() : Boolean
      {
         if(this.isSkillPanelUnlockedHandler)
         {
            return this.isSkillPanelUnlockedHandler.isSkillPanelUnlockedOverride();
         }
         return this.isSkillPanelUnlockedDefault();
      }
      
      public function isSkillPanelUnlockedDefault() : Boolean
      {
         return this.hasPurchasedFirstSkill;
      }
      
      public function isTranscendencePanelUnlocked() : Boolean
      {
         if(this.isTranscendencePanelUnlockedHandler)
         {
            return this.isTranscendencePanelUnlockedHandler.isTranscendencePanelUnlockedOverride();
         }
         return this.isTranscendencePanelUnlockedDefault();
      }
      
      public function isTranscendencePanelUnlockedDefault() : Boolean
      {
         return this.hasUnlockedTranscendencePanel;
      }
      
      public function isAutomatorPanelUnlocked() : Boolean
      {
         if(this.isAutomatorPanelUnlockedHandler)
         {
            return this.isAutomatorPanelUnlockedHandler.isAutomatorPanelUnlockedOverride();
         }
         return this.isAutomatorPanelUnlockedDefault();
      }
      
      public function isAutomatorPanelUnlockedDefault() : Boolean
      {
         return this.hasUnlockedAutomator;
      }
      
      public function isWorldsPanelUnlocked() : Boolean
      {
         if(this.isWorldsPanelUnlockedHandler)
         {
            return this.isWorldsPanelUnlockedHandler.isWorldsPanelUnlockedOverride();
         }
         return this.isWorldsPanelUnlockedDefault();
      }
      
      public function numStartSystemsCompleted() : Number
      {
         return Math.floor(this.highestWorldCompleted / this.worldsPerSystem);
      }
      
      public function isWorldsPanelUnlockedDefault() : Boolean
      {
         return this.highestWorldCompleted >= 1;
      }
      
      public function isMiscPanelUnlocked() : Boolean
      {
         if(this.isMiscPanelUnlockedHandler)
         {
            return this.isMiscPanelUnlockedHandler.isMiscPanelUnlockedOverride();
         }
         return this.isMiscPanelUnlockedDefault();
      }
      
      public function isMiscPanelUnlockedDefault() : Boolean
      {
         return true;
      }
      
      private function canAffordFirstCatalogItem() : Boolean
      {
         var item:Item = this.catalogItemsForSale[0];
         if(item)
         {
            return this.canAffordCatalogItem(item);
         }
         return false;
      }
      
      public function shouldSlideInMainPanelForFirstTime() : Boolean
      {
         if(this.shouldSlideInMainPanelForFirstTimeHandler)
         {
            return this.shouldSlideInMainPanelForFirstTimeHandler.shouldSlideInMainPanelForFirstTimeOverride();
         }
         return this.shouldSlideInMainPanelForFirstTimeDefault();
      }
      
      public function shouldSlideInMainPanelForFirstTimeDefault() : Boolean
      {
         return !this.hasSeenMainPanel && this.canAffordFirstCatalogItem();
      }
      
      public function getCurrentSkin() : Skin
      {
         return this.skins[this.selectedSkinIndex];
      }
      
      public function get isOnHighestZone() : Boolean
      {
         return this.highestZone == this.currentZone;
      }
      
      public function get monstersKilledOnCurrentZone() : int
      {
         return this.monstersKilledPerZone[this.currentZone];
      }
      
      public function get killedAllMonstersOnZone() : Boolean
      {
         return this.monstersKilledOnCurrentZone >= this.monstersPerZone;
      }
      
      public function get millisecondsRemainingToBeatWorld() : int
      {
         return AscensionWorlds.MILLISECONDS_TO_BEAT_WORLD - this.timeSinceMostRecentRunBegan;
      }
      
      public function hasCompletedCurrentZone() : Boolean
      {
         return this.killedAllMonstersOnZone || !this.isOnHighestZone;
      }
      
      public function get levelUpCost() : BigNumber
      {
         return this.getLevelUpCostToNextLevel(this.level);
      }
      
      public function get totalStatPoints() : BigNumber
      {
         if(!this.didConvertTotalStatPointsToV2ThisIsStupid)
         {
            this.totalStatPointsV2 = Formulas.instance.getTotalStatPoints(this.level).numberValue();
            this.didConvertTotalStatPointsToV2ThisIsStupid = true;
         }
         return new BigNumber(this.totalStatPointsV2);
      }
      
      public function get availableStatPoints() : BigNumber
      {
         return this.totalStatPoints.subtract(this.spentStatPoints);
      }
      
      public function get hasAvailableStatPoints() : Boolean
      {
         return this.availableStatPoints.gtN(0.99);
      }
      
      public function get currentWorld() : AscensionWorld
      {
         return this.worlds.getWorld(this.currentWorldId);
      }
      
      public function get timeSinceMostRecentRunBegan() : Number
      {
         return CH2.user.totalMsecsPlayed - this.timeOfLastRun;
      }
      
      public function setupRoller() : void
      {
         if(!this.roller.isInitialized && this.roller.seedRoller.numUses == 0)
         {
            this.startingRollerValue = ROLLER_SEEDS[Rnd.integer(ROLLER_SEEDS.length)];
            if(IdleHeroConsole.gameSeed > -1)
            {
               this.startingRollerValue = IdleHeroConsole.gameSeed;
            }
            this.roller.initialize(this.startingRollerValue);
            CH2.user.remoteStatsTracking.addEvent({
               "type":"createCharacter",
               "createdTimestamp":ServerTimeKeeper.instance.secondsTimestamp,
               "characterType":1,
               "startingSeed":this.startingRollerValue
            });
         }
         else
         {
            this.roller.isInitialized = true;
         }
      }
      
      public function setupLogs() : void
      {
         if(!this.eventLogger)
         {
            this.eventLogger = new EventLog();
         }
         if(!this.inputLogger)
         {
            this.inputLogger = new InputLog();
         }
         this.eventLogger.log.position = this.eventLogger.log.length;
         this.inputLogger.log.position = this.inputLogger.log.length;
      }
      
      public function setStartValueForInputLog() : void
      {
         this.inputLogger.characterDataAtStartOfLogSegmentId = JSON.stringify(this.toJsonObject());
      }
      
      public function setupTrackedStats() : void
      {
         this.trackedDps = new TrackedStat();
         this.trackedDps.name = "DPS";
         this.trackedOverkill = new TrackedStat();
         this.trackedOverkill.name = "Overkill %";
         this.trackedGoldGained = new TrackedStat();
         this.trackedGoldGained.name = "Gold Gained";
         this.trackedGoldSpent = new TrackedStat();
         this.trackedGoldSpent.name = "Gold Spent";
         this.trackedEnergyUsed = new TrackedStat();
         this.trackedEnergyUsed.name = "Energy Used";
         this.trackedManaUsed = new TrackedStat();
         this.trackedManaUsed.name = "Mana Used";
         this.trackedFrameMsec = new TrackedStat();
         this.trackedFrameMsec.name = "Frame Msec";
         this.trackedXPEarned = new TrackedStat();
         this.trackedXPEarned.name = "XP Earned";
      }
      
      public function getTraitMultiplier(trait:String) : Number
      {
         if(this.traitMultipliers[trait])
         {
            return this.traitMultipliers[trait];
         }
         return 1;
      }
      
      public function getTrait(trait:String) : Number
      {
         if(this.traits.hasOwnProperty(trait))
         {
            return this.traits[trait] * this.getTraitMultiplier(trait);
         }
         this.traits[trait] = 0;
         return 0;
      }
      
      public function getTraitValue(trait:String) : Number
      {
         if(this.traits.hasOwnProperty(trait))
         {
            if(this.traitInfo.hasOwnProperty(trait))
            {
               return this.traitInfo[trait]["valueFunction"](this.getTrait(trait));
            }
            return this.getTrait(trait);
         }
         this.traits[trait] = 0;
         return 0;
      }
      
      public function setTrait(trait:String, value:Number, isEtherealTrait:Boolean = false, ascensionPersisting:Boolean = true, transcensionPersisting:Boolean = false) : void
      {
         this.traits[trait] = value;
         this.traitPersistanceValues[trait] = ascensionPersisting;
         this.traitTranscensionPersisting[trait] = transcensionPersisting;
         if(isEtherealTrait)
         {
            this.classStatsCached = false;
            this.inventory.cachedEquippedDamage.base = -1;
         }
      }
      
      public function addTrait(trait:String, value:Number, isEtherealTrait:Boolean = false, ascensionPersisting:Boolean = true, transcensionPersisting:Boolean = false) : void
      {
         if(this.traits.hasOwnProperty(trait))
         {
            this.traits[trait] = this.traits[trait] + value;
         }
         else
         {
            this.traits[trait] = value;
         }
         this.traitPersistanceValues[trait] = ascensionPersisting;
         this.traitTranscensionPersisting[trait] = transcensionPersisting;
         if(isEtherealTrait)
         {
            this.classStatsCached = false;
            this.inventory.cachedEquippedDamage.base = -1;
         }
      }
      
      public function canAffordCatalogItem(item:Item) : Boolean
      {
         return this.gold.gte(item.cost());
      }
      
      public function getNodeInfo(nodeType:String) : Object
      {
         if(this.levelGraphNodeTypes.hasOwnProperty(nodeType))
         {
            return this.levelGraphNodeTypes[nodeType];
         }
         return this.levelGraphNodeTypes["D"];
      }
      
      public function startWorld(worldNumber:Number) : void
      {
         var worldIsInLastFiveOfGild:* = false;
         var chanceToShowInWorld:Number = NaN;
         var willShowInCurrentWorld:* = undefined;
         this.hasNeverStartedWorld = false;
         var previousStarSystemId:Number = this.currentWorld.starSystemId;
         this.onWorldStarted(worldNumber);
         if(previousStarSystemId != this.currentWorld.starSystemId)
         {
            CH2.currentCharacter.starSystemAncientShards[previousStarSystemId] = CH2.currentCharacter.ancientShards;
            CH2.currentCharacter.starSystemTimesSinceLastAncientShardPurchase[previousStarSystemId] = CH2.currentCharacter.timeSinceLastAncientShardPurchase;
            if(CH2.currentCharacter.starSystemAncientShards[this.currentWorld.starSystemId])
            {
               CH2.currentCharacter.ancientShards = CH2.currentCharacter.starSystemAncientShards[this.currentWorld.starSystemId];
            }
            else
            {
               CH2.currentCharacter.ancientShards = 0;
            }
            if(CH2.currentCharacter.starSystemTimesSinceLastAncientShardPurchase[this.currentWorld.starSystemId])
            {
               CH2.currentCharacter.timeSinceLastAncientShardPurchase = CH2.currentCharacter.starSystemTimesSinceLastAncientShardPurchase[this.currentWorld.starSystemId];
            }
            else
            {
               CH2.currentCharacter.timeSinceLastAncientShardPurchase = ANCIENT_SHARD_PURCHASE_COOLDOWN;
            }
         }
         this.generateCatalog();
         CH2.currentCharacter.applySystemTraits(worldNumber);
         var startingGold:BigNumber = new BigNumber(5);
         startingGold.timesEquals(CH2.currentCharacter.monsterGoldMultiplier);
         var startingGoldMultiplier:BigNumber = CH2.currentCharacter.monsterGold.max(CH2.currentCharacter.clickableGold).max(CH2.currentCharacter.treasureChestGold.multiplyN(5).multiply(CH2.currentCharacter.treasureChestChance));
         startingGold.timesEquals(startingGoldMultiplier);
         var bonusGold:BigNumber = new BigNumber(this.bonusGoldChance);
         bonusGold.timesEqualsN(Formulas.BONUS_GOLD_MULTIPLIER);
         bonusGold.plusEquals(this.bonusGoldChance.negate().addN(1));
         startingGold.timesEquals(bonusGold);
         CH2.currentCharacter.addGold(startingGold);
         this.bagOfGoldPrice = 1;
         for(var i:int = this.rubyPurchaseOptions.length - 1; i >= 0; i--)
         {
            if(this.rubyPurchaseOptions[i].id == "bagOfGold")
            {
               this.rubyPurchaseOptions[i].price = this.bagOfGoldPrice;
            }
         }
         this.didFinishWorld = false;
         this.canChangeEtherealEquipment = false;
         this.equipPendingEtherealItems();
         if(!this.highestMonstersKilled.hasOwnProperty(worldNumber))
         {
            this.highestMonstersKilled[worldNumber] = 0;
         }
         if(!this.zoneToShowPerWorld.hasOwnProperty(worldNumber))
         {
            worldIsInLastFiveOfGild = (this.currentWorldId - 1) % this.worldsPerSystem >= this.worldsPerSystem - 4;
            chanceToShowInWorld = !!worldIsInLastFiveOfGild?Number(0.25):Number(0.1);
            willShowInCurrentWorld = this.roller.worldRoller.boolean(chanceToShowInWorld);
            if(willShowInCurrentWorld)
            {
               this.zoneToShowPerWorld[worldNumber] = this.roller.worldRoller.integer(35,90);
            }
            else
            {
               this.zoneToShowPerWorld[worldNumber] = 101;
            }
            this.hasActivatedMassiveOrangeFish[worldNumber] = false;
         }
         MusicManager.instance.shufflePlaylists();
      }
      
      public function applySystemTraits(worldNumber:Number) : void
      {
         if(this.applySystemTraitsHandler)
         {
            this.applySystemTraitsHandler.applySystemTraitsOverride(worldNumber);
         }
         else
         {
            this.applySystemTraitsDefault(worldNumber);
         }
      }
      
      public function applySystemTraitsDefault(worldNumber:Number) : void
      {
         var kumaIconId:int = 0;
         var kumaBuff:Buff = null;
         this.monstersPerZone = this.preKumaMonstersPerZone;
         if(this.consecutiveEasyBossesKilled > 0)
         {
            if(this.consecutiveEasyBossesKilled < 10)
            {
               kumaIconId = 113;
            }
            else if(this.consecutiveEasyBossesKilled < 20)
            {
               kumaIconId = 114;
            }
            else if(this.consecutiveEasyBossesKilled < 30)
            {
               kumaIconId = 115;
            }
            else if(this.consecutiveEasyBossesKilled < 40)
            {
               kumaIconId = 116;
            }
            else
            {
               kumaIconId = 76;
            }
            this.monstersPerZone = this.monstersPerZone - Math.floor(this.consecutiveEasyBossesKilled * this.preKumaMonstersPerZone / 50);
            kumaBuff = new Buff();
            kumaBuff.iconId = kumaIconId;
            kumaBuff.isUntimedBuff = true;
            kumaBuff.name = "kuma";
            kumaBuff.stacks = this.consecutiveEasyBossesKilled;
            kumaBuff.tooltipFunction = function():Object
            {
               var kumaTooltip:String = null;
               if(consecutiveEasyBossesKilled < 10)
               {
                  kumaTooltip = "You seem powerful.";
               }
               else if(consecutiveEasyBossesKilled < 20)
               {
                  kumaTooltip = "Your strength is admirable.";
               }
               else if(consecutiveEasyBossesKilled < 30)
               {
                  kumaTooltip = "You are being watched from the shadows.";
               }
               else if(consecutiveEasyBossesKilled < 40)
               {
                  kumaTooltip = "You have Kumawakamaru\'s attention.";
               }
               else
               {
                  kumaTooltip = "You don\'t belong here.";
               }
               return {
                  "header":"...",
                  "body":kumaTooltip
               };
            };
            this.buffs.addBuff(kumaBuff);
            if(this.monstersPerZone < 1)
            {
               this.monstersPerZone = 1;
            }
         }
      }
      
      public function onWorldStarted(worldNumber:Number) : void
      {
         if(this.onWorldStartedHandler)
         {
            this.onWorldStartedHandler.onWorldStartedOverride(worldNumber);
         }
         else
         {
            this.onWorldStartedDefault(worldNumber);
         }
      }
      
      public function onWorldStartedDefault(worldNumber:Number) : void
      {
         this.currentWorldId = worldNumber;
         this.timeOfLastRun = CH2.user.totalMsecsPlayed;
      }
      
      public function onCharacterLoaded() : void
      {
         if(this.onCharacterLoadedHandler)
         {
            this.onCharacterLoadedHandler.onCharacterLoadedOverride();
         }
         else
         {
            this.onCharacterLoadedDefault();
         }
      }
      
      public function onCharacterLoadedDefault() : void
      {
         ItemStat.clearCachedItemStats();
      }
      
      public function onCharacterUnloaded() : void
      {
         if(this.onCharacterUnloadedHandler)
         {
            this.onCharacterUnloadedHandler.onCharacterUnloadedOverride();
         }
         else
         {
            this.onCharacterUnloadedDefault();
         }
      }
      
      public function onCharacterUnloadedDefault() : void
      {
         this.activeSkills = [];
         ItemStat.clearCachedItemStats();
      }
      
      public function onCharacterDisplayCreated(display:CharacterDisplay) : void
      {
         if(this.onCharacterDisplayCreatedHandler)
         {
            this.onCharacterDisplayCreatedHandler.onCharacterDisplayCreatedOverride(display);
         }
         else
         {
            this.onCharacterDisplayCreatedDefault(display);
         }
      }
      
      public function onCharacterDisplayCreatedDefault(display:CharacterDisplay) : void
      {
      }
      
      public function triggerGlobalCooldown() : void
      {
         if(this.triggerGlobalCooldownHandler)
         {
            this.triggerGlobalCooldownHandler.triggerGlobalCooldownOverride();
         }
         else
         {
            this.triggerGlobalCooldownDefault();
         }
      }
      
      public function triggerGlobalCooldownDefault() : void
      {
         this.gcdRemaining = this.baseGCD;
      }
      
      public function unlockCharacter() : void
      {
         if(this.unlockCharacterHandler)
         {
            this.unlockCharacterHandler.unlockCharacterOverride();
         }
         else
         {
            this.unlockCharacterDefault();
         }
      }
      
      public function unlockCharacterDefault() : void
      {
         if(this.isLocked)
         {
            this.isLocked = false;
            this.timeCharacterWasUnlocked = CH2.user.totalMsecsPlayed;
         }
      }
      
      public function onAutomatorUnlocked() : void
      {
         if(this.onAutomatorUnlockedHandler)
         {
            this.onAutomatorUnlockedHandler.onAutomatorUnlockedOverride();
         }
         else
         {
            this.onAutomatorUnlockedDefault();
         }
      }
      
      public function onAutomatorUnlockedDefault() : void
      {
         this.hasUnlockedAutomator = true;
      }
      
      public function populateWorldEndAutomationOptions() : void
      {
         if(this.populateWorldEndAutomationOptionsHandler)
         {
            this.populateWorldEndAutomationOptionsHandler.populateWorldEndAutomationOptionsOverride();
         }
         else
         {
            this.populateWorldEndAutomationOptionsDefault();
         }
      }
      
      public function populateWorldEndAutomationOptionsDefault() : void
      {
         var rerunCurrentWorldOption:AutomatorWorldEndOption = new AutomatorWorldEndOption();
         rerunCurrentWorldOption.name = "Rerun Current World";
         rerunCurrentWorldOption.onWorldEndFunction = this.onWorldEndRerunCurrentWorld;
         rerunCurrentWorldOption.isUnlockedFunction = this.isRerunCurrentWorldOnWorldEndUnlocked;
         this.worldEndAutomationOptions.push(rerunCurrentWorldOption);
         var attemptNextWorldOption:AutomatorWorldEndOption = new AutomatorWorldEndOption();
         attemptNextWorldOption.name = "Attempt Next World";
         attemptNextWorldOption.onWorldEndFunction = this.onWorldEndAttemptNextWorld;
         attemptNextWorldOption.isUnlockedFunction = this.isAttemptNextWorldOnWorldEndUnlocked;
         this.worldEndAutomationOptions.push(attemptNextWorldOption);
         var attemptHighestWorldOption:AutomatorWorldEndOption = new AutomatorWorldEndOption();
         attemptHighestWorldOption.name = "Attempt Highest World";
         attemptHighestWorldOption.onWorldEndFunction = this.onWorldEndAttemptHighestWorld;
         attemptHighestWorldOption.isUnlockedFunction = this.isAttemptHighestWorldOnWorldEndUnlocked;
         this.worldEndAutomationOptions.push(attemptHighestWorldOption);
      }
      
      public function onWorldEndStopBeforeGild() : void
      {
         if((this.currentWorldId + 1) % this.worldsPerSystem == 1)
         {
            this.changeWorld(this.currentWorldId);
         }
         else
         {
            this.changeWorld(this.currentWorldId + 1);
         }
      }
      
      public function isStopBeforeGildOnWorldEndUnlocked() : Boolean
      {
         return this.highestWorldCompleted >= WORLD_END_AUTOMATION_OPTIONS_UNLOCK_WORLD;
      }
      
      public function onWorldEndRerunCurrentWorld() : void
      {
         this.changeWorld(this.currentWorldId);
      }
      
      public function isRerunCurrentWorldOnWorldEndUnlocked() : Boolean
      {
         return this.highestWorldCompleted >= WORLD_END_AUTOMATION_OPTIONS_UNLOCK_WORLD;
      }
      
      public function onWorldEndAttemptNextWorld() : void
      {
         this.changeWorld(this.currentWorldId + 1);
      }
      
      public function isAttemptNextWorldOnWorldEndUnlocked() : Boolean
      {
         return this.highestWorldCompleted >= WORLD_END_AUTOMATION_OPTIONS_UNLOCK_WORLD;
      }
      
      public function onWorldEndAttemptHighestWorld() : void
      {
         this.changeWorld(this.highestWorldCompleted + 1);
      }
      
      public function isAttemptHighestWorldOnWorldEndUnlocked() : Boolean
      {
         return this.highestWorldCompleted >= WORLD_END_AUTOMATION_OPTIONS_UNLOCK_WORLD;
      }
      
      private function fillDamageCache(value:BigNumber) : void
      {
         for(var i:int = 0; i < 50; i++)
         {
            this.cachedDamage[i] = value;
         }
      }
      
      public function excitingUpgradeCheck() : void
      {
         var currentDamage:BigNumber = this.inventory.getEquippedDamage();
         if(this.cachedDamage.length < 50)
         {
            this.fillDamageCache(currentDamage);
         }
         if(currentDamage > this.cachedDamage[this.nextDamageCacheEntry].multiplyN(2))
         {
            this.fillDamageCache(currentDamage);
            this.musicExcitementLevel++;
            this.musicExcitementTimer = 60000;
         }
      }
      
      public function update(dt:int) : void
      {
         if(this.updateHandler)
         {
            this.updateHandler.updateOverride(dt);
         }
         else
         {
            this.updateDefault(dt);
         }
      }
      
      public function updateDefault(dt:int) : void
      {
         var target:Monster = null;
         this.timeOnlineMilliseconds = this.timeOnlineMilliseconds + dt;
         this.timeUntilDamageCache = this.timeUntilDamageCache - dt;
         this.musicExcitementTimer = this.musicExcitementTimer - dt;
         this.timeSinceLastClickAttack = this.timeSinceLastClickAttack + dt;
         this.timeSinceLastSkill = this.timeSinceLastSkill + dt;
         this.timeSinceLastAutoAttack = this.timeSinceLastAutoAttack + dt;
         this.timeSinceRegularMonsterHasDroppedRubies = this.timeSinceRegularMonsterHasDroppedRubies + dt;
         this.timeSinceLastOrangeFishAppearance = this.timeSinceLastOrangeFishAppearance + dt;
         if(IdleHeroMain.IS_TIMELAPSE)
         {
            if(this.cachedTimelapseServerTime == 0)
            {
               this.cachedTimelapseServerTime = ServerTimeKeeper.instance.timestamp;
            }
            this.serverTimeOfLastUpdate = this.cachedTimelapseServerTime - 17 * (IdleHeroMain.totalTimeLapseLoops - IdleHeroMain.completedTimeLapseLoops);
         }
         else
         {
            this.cachedTimelapseServerTime = 0;
            this.serverTimeOfLastUpdate = ServerTimeKeeper.instance.timestamp;
         }
         this.updateStats(dt);
         if(this.timeUntilDamageCache <= 0)
         {
            if(this.musicExcitementTimer < 0)
            {
               this.musicExcitementLevel = 0;
            }
            this.timeUntilDamageCache = 100;
            this.cachedDamage[this.nextDamageCacheEntry] = this.inventory.getEquippedDamage();
            this.nextDamageCacheEntry = (this.nextDamageCacheEntry + 1) % 49;
            if(this.nextDamageCacheEntry > 50)
            {
               this.nextDamageCacheEntry = 0;
            }
         }
         this.timeSinceRegen = this.timeSinceRegen + dt;
         if(this.timeSinceRegen > 1000)
         {
            this.regenerateManaAndEnergy(this.timeSinceRegen);
            this.timeSinceRegen = 0;
         }
         var hasteThisFrame:Number = this.hasteRating.numberValue();
         this.cooldownSkills(dt,hasteThisFrame);
         this.gcdRemaining = this.gcdRemaining - dt * Math.min(hasteThisFrame,this.baseGCD / this.gcdMinimum);
         if(IdleHeroMain.IS_RENDERING)
         {
            this.characterDisplay.update(dt);
         }
         this.automator.executeAutomatorQueue(dt);
         var lockedState:int = this.state;
         switch(lockedState)
         {
            case STATE_PAUSED:
               if(CH2.world.isBossZone(this.currentZone) && !this.isNextMonsterInRange && CH2.world.getNextMonster() != null)
               {
                  if(this.characterDisplay.animationState != CharacterDisplay.STATE_WALKING)
                  {
                     this.characterDisplay.playWalk();
                  }
                  this.walk(dt);
                  this.characterDisplay.playFootStepSound(dt);
                  this.state = STATE_PAUSED;
               }
               else if(this.characterDisplay.animationState != CharacterDisplay.STATE_PAUSED)
               {
                  this.characterDisplay.playPause();
               }
               break;
            case STATE_CASTING:
               this.castTimeRemaining = this.castTimeRemaining - dt / 1000;
               if(this.castTimeRemaining < 0)
               {
                  this.timeSinceLastSkill = 0;
                  this.skillBeingCast.effectFunction();
                  this.skillBeingCast = null;
                  this.castTime = 0;
                  this.castTimeRemaining = 0;
                  this.changeState(STATE_UNKNOWN);
               }
               break;
            case STATE_WALKING:
               this.walk(dt);
               this.characterDisplay.playFootStepSound(dt);
               break;
            case STATE_ENDING_COMBAT:
               if(this.timeSinceLastAttack > TIME_AFTER_KILL_BEFORE_WALKING_MS)
               {
                  this.changeState(STATE_WALKING);
               }
               break;
            case STATE_COMBAT:
               target = CH2.world.getNextMonster();
               if(target && this.shouldAutoAttack)
               {
                  this.autoAttack();
               }
               break;
            case STATE_UNKNOWN:
               if(this.isNextMonsterInRange)
               {
                  this.changeState(STATE_COMBAT);
               }
               else if(CH2.world.getNextMonster())
               {
                  this.changeState(STATE_WALKING);
               }
         }
         if(!(CH2.world.isBossZone(this.currentZone) && !this.isNextMonsterInRange && CH2.world.getNextMonster() != null) && (!CH2.world.bossEncounter || CH2.world.bossEncounter.battleStarted && !CH2.world.bossEncounter.battleEnded))
         {
            this.buffs.updateBuffs(dt,hasteThisFrame);
         }
         this.updateRubyShopFields(dt);
         if(Math.floor(this.timeOnlineMilliseconds / 3600000) != Math.floor((this.timeOnlineMilliseconds - dt) / 3600000))
         {
            this.sendServerStatsUpdate();
         }
         this.worldEntity.x = this.x;
         this.worldEntity.y = this.y;
      }
      
      public function updateOfflineProgress() : void
      {
         if(this.serverTimeOfLastUpdate == 0)
         {
            this.serverTimeOfLastUpdate = ServerTimeKeeper.instance.timestamp;
         }
         var msecOfflineSinceLastSession:Number = ServerTimeKeeper.instance.timestamp - this.serverTimeOfLastUpdate;
         msecOfflineSinceLastSession = Math.min(msecOfflineSinceLastSession,1000 * 60 * 60 * 24.5);
         if(msecOfflineSinceLastSession > 0 || Validate.IS_VALIDATING)
         {
            if(!CH2.user.disableOfflineProgress)
            {
               IdleHeroMain.NEED_TIMELAPSE = true;
               IdleHeroMain.totalTimeLapseTime = msecOfflineSinceLastSession;
            }
            if(msecOfflineSinceLastSession > 0)
            {
               this.inputLogger.recordInput(GameActions.START_GAME);
            }
         }
      }
      
      public function sendServerStatsUpdate() : void
      {
         var runsInWorld:int = 0;
         if(!this.runsCompletedPerWorld.hasOwnProperty(this.currentWorldId))
         {
            runsInWorld = 0;
         }
         else
         {
            runsInWorld = this.runsCompletedPerWorld[this.currentWorldId];
         }
         CH2.user.remoteStatsTracking.addEvent({
            "type":"updateCharacter",
            "highestWorld":this.highestWorldCompleted,
            "currentLevel":this.level,
            "totalRubiesEarned":this.rubies,
            "totalAncientShardsPurchased":this.ancientShards,
            "runsInHighestWorld":runsInWorld,
            "lastPlayedTimestamp":ServerTimeKeeper.instance.secondsTimestamp
         });
      }
      
      public function changeState(newState:int) : void
      {
         if(this.changeStateHandler)
         {
            this.changeStateHandler.changeStateOverride(newState);
         }
         else
         {
            this.changeStateDefault(newState);
         }
      }
      
      public function changeStateDefault(newState:int) : void
      {
         switch(newState)
         {
            case STATE_PAUSED:
               this.characterDisplay.playPause();
               break;
            case STATE_WALKING:
               this.characterDisplay.playWalk();
               break;
            case STATE_COMBAT:
               if(this.state == STATE_WALKING)
               {
                  this.characterDisplay.playWalkEnd();
               }
               else
               {
                  this.characterDisplay.playCombatIdle();
               }
         }
         this.state = newState;
      }
      
      public function attack(attackData:AttackData) : void
      {
         if(this.attackHandler)
         {
            this.attackHandler.attackOverride(attackData);
         }
         else
         {
            this.attackDefault(attackData);
         }
      }
      
      public function attackDefault(attackData:AttackData) : void
      {
         var monsterAttacked:Monster = CH2.world.getNextMonster();
         if(!monsterAttacked)
         {
            return;
         }
         if(attackData.canCrit)
         {
            attackData.isCritical = this.roller.attackRoller.boolean(this.criticalChance + attackData.critChanceModifier);
         }
         else
         {
            attackData.isCritical = false;
         }
         if(attackData.isCritical)
         {
            attackData.damage.timesEquals(this.criticalDamageMultiplier);
         }
         attackData.monster = monsterAttacked;
         this.buffs.onAttack(attackData);
         if(attackData.monster)
         {
            attackData.monster.takeDamage(attackData);
         }
         this.playRandomHitSound(attackData);
      }
      
      public function attackDefaultOld(attackData:AttackData) : void
      {
         var i:int = 0;
         var attackRange:Number = NaN;
         var monstersAttacked:Array = [];
         var attackDatas:Array = [];
         attackData.isPierce = this.roller.attackRoller.boolean(this.pierceChance.numberValue());
         if(attackData.isPierce)
         {
            attackRange = 250;
            monstersAttacked = CH2.world.monsters.getMonstersInCenter(this.x,this.y,attackRange);
         }
         else
         {
            monstersAttacked[0] = CH2.world.getNextMonster();
         }
         if(!monstersAttacked[0])
         {
            return;
         }
         attackDatas[0] = attackData;
         for(i = 0; i < monstersAttacked.length; i++)
         {
            if(i > 0)
            {
               attackDatas[i] = attackData.getCopy();
            }
            if(attackDatas[i].canCrit)
            {
               attackDatas[i].isCritical = this.roller.attackRoller.boolean(this.criticalChance.numberValue());
            }
            else
            {
               attackDatas[i].isCritical = false;
            }
            if(attackDatas[i].isCritical)
            {
               attackData.isCritical = true;
            }
            attackDatas[i].monster = monstersAttacked[i];
            if(attackDatas[i].isCritical)
            {
               attackDatas[i].damage.timesEqualsN(this.criticalDamageMultiplier);
            }
         }
         this.buffs.onAttack(attackData);
         for(i = 0; i < attackDatas.length; i++)
         {
            if(attackDatas[i].monster)
            {
               attackDatas[i].monster.takeDamage(attackDatas[i]);
            }
            this.playRandomHitSound(attackData);
         }
      }
      
      public function clickAttack(doesCostEnergy:Boolean = true) : void
      {
         if(this.clickAttackHandler)
         {
            this.clickAttackHandler.clickAttackOverride(doesCostEnergy);
         }
         else
         {
            this.clickAttackDefault(doesCostEnergy);
         }
      }
      
      public function clickAttackDefault(doesCostEnergy:Boolean = true) : void
      {
         var closestMonster:Monster = null;
         var energyCost:Number = !!doesCostEnergy?Number(-1 * this.clickAttackEnergyCost):Number(0);
         if(this.canAffordClickAttack || !doesCostEnergy)
         {
            this.timeSinceLastClickAttack = 0;
            if(this.state == STATE_COMBAT)
            {
               this.onClickAttack();
               this.addEnergy(energyCost);
            }
            else if(this.isInTeleportClickAttackState)
            {
               closestMonster = CH2.world.getNextMonster();
               if(!this.isNextMonsterInRange && closestMonster && (!closestMonster.isBoss || CH2.world.bossEncounter.isWithinAttackRange))
               {
                  this.onTeleportAttack();
                  this.addEnergy(energyCost);
               }
            }
         }
         else
         {
            CH2UI.instance.mainUI.hud.showInsufficientEnergy();
         }
         this.buffs.onClick(null);
      }
      
      public function autoAttack() : void
      {
         if(this.autoAttackHandler)
         {
            this.autoAttackHandler.autoAttackOverride();
         }
         else
         {
            this.autoAttackDefault();
         }
      }
      
      public function autoAttackDefault() : void
      {
         var attackData:AttackData = new AttackData();
         attackData.isAutoAttack = true;
         attackData.damage = this.autoAttackDamage;
         this.characterDisplay.playAutoAttack();
         this.timeSinceLastAutoAttack = 0;
         this.attack(attackData);
         this.addEnergy(this.energyRegeneration.numberValue(),false);
      }
      
      public function onClickAttack() : void
      {
         if(this.onClickAttackHandler)
         {
            this.onClickAttackHandler.onClickAttackOverride();
         }
         else
         {
            this.onClickAttackDefault();
         }
      }
      
      public function onClickAttackDefault() : void
      {
         var attackData:AttackData = new AttackData();
         attackData.isClickAttack = true;
         attackData.damage = this.clickDamage;
         this.characterDisplay.playClickAttack();
         this.attack(attackData);
      }
      
      public function onTeleportAttack() : void
      {
         if(this.onTeleportAttackHandler)
         {
            this.onTeleportAttackHandler.onTeleportAttackOverride();
         }
         else
         {
            this.onTeleportAttackDefault();
         }
      }
      
      public function onTeleportAttackDefault() : void
      {
         if(!CH2.world.getNextMonster())
         {
            return;
         }
         var attackData:AttackData = new AttackData();
         attackData.isClickAttack = true;
         attackData.isTeleportAttack = true;
         attackData.damage = this.clickDamage;
         this.teleport();
         this.attack(attackData);
         CH2.world.removeOldMonsters();
         CH2.world.spawnMonsters();
      }
      
      public function teleport() : void
      {
         if(!CH2.world.getNextMonster())
         {
            return;
         }
         var previousY:Number = this.y;
         this.y = CH2.world.getNextMonster().y - this.attackRange;
         this.changeState(STATE_COMBAT);
         if(IdleHeroMain.IS_RENDERING)
         {
            this.characterDisplay.playDash(this.y - previousY);
         }
      }
      
      public function onKilledMonster(monster:Monster) : void
      {
         if(this.onKilledMonsterHandler)
         {
            this.onKilledMonsterHandler.onKilledMonsterOverride(monster);
         }
         else
         {
            this.onKilledMonsterDefault(monster);
         }
      }
      
      public function onKilledMonsterDefault(monster:Monster) : void
      {
         var kumaIconId:int = 0;
         var buff:Buff = null;
         this.monstersKilled++;
         CH2.user.totalMonstersKilled++;
         if(this.monstersKilledPerZone.hasOwnProperty(this.currentZone))
         {
            this.monstersKilledPerZone[this.currentZone]++;
         }
         else
         {
            this.monstersKilledPerZone[this.currentZone] = 1;
         }
         if(this.isOnHighestZone)
         {
            CH2UI.instance.mainUI.hud.update(0);
         }
         if(monster.isBoss)
         {
            this.highestMonstersKilled[this.currentWorldId] = monster.zoneSpawned * this.monstersPerZone;
            if(this.attemptsOnCurrrentBoss > 1)
            {
               this.consecutiveEasyBossesKilled = 0;
               this.buffs.removeBuff("kuma");
               this.monstersPerZone = this.preKumaMonstersPerZone;
            }
            else
            {
               this.consecutiveEasyBossesKilled++;
               if(this.consecutiveEasyBossesKilled < this.preKumaMonstersPerZone / 5)
               {
                  kumaIconId = 113;
               }
               else if(this.consecutiveEasyBossesKilled < 2 * this.preKumaMonstersPerZone / 5)
               {
                  kumaIconId = 114;
               }
               else if(this.consecutiveEasyBossesKilled < 3 * this.preKumaMonstersPerZone / 5)
               {
                  kumaIconId = 115;
               }
               else if(this.consecutiveEasyBossesKilled < 4 * this.preKumaMonstersPerZone / 5)
               {
                  kumaIconId = 116;
               }
               else
               {
                  kumaIconId = 76;
               }
               if(this.buffs.hasBuffByName("kuma"))
               {
                  buff = this.buffs.getBuff("kuma");
                  buff.stacks = this.consecutiveEasyBossesKilled;
                  buff.iconId = kumaIconId;
                  buff.tooltipFunction = function():Object
                  {
                     var kumaTooltip:String = null;
                     if(consecutiveEasyBossesKilled < preKumaMonstersPerZone / 5)
                     {
                        kumaTooltip = "You seem powerful.";
                     }
                     else if(consecutiveEasyBossesKilled < 2 * preKumaMonstersPerZone / 5)
                     {
                        kumaTooltip = "Your strength is admirable.";
                     }
                     else if(consecutiveEasyBossesKilled < 3 * preKumaMonstersPerZone / 5)
                     {
                        kumaTooltip = "You are being watched from the shadows.";
                     }
                     else if(consecutiveEasyBossesKilled < 4 * preKumaMonstersPerZone / 5)
                     {
                        kumaTooltip = "You have Kumawakamaru\'s attention.";
                     }
                     else
                     {
                        kumaTooltip = "You don\'t belong here.";
                     }
                     return {
                        "header":"...",
                        "body":kumaTooltip
                     };
                  };
               }
               else
               {
                  buff = new Buff();
                  buff.iconId = kumaIconId;
                  buff.isUntimedBuff = true;
                  buff.name = "kuma";
                  buff.stacks = this.consecutiveEasyBossesKilled;
                  buff.tooltipFunction = function():Object
                  {
                     var kumaTooltip:String = null;
                     if(consecutiveEasyBossesKilled < preKumaMonstersPerZone / 5)
                     {
                        kumaTooltip = "You seem powerful.";
                     }
                     else if(consecutiveEasyBossesKilled < 2 * preKumaMonstersPerZone / 5)
                     {
                        kumaTooltip = "Your strength is admirable.";
                     }
                     else if(consecutiveEasyBossesKilled < 3 * preKumaMonstersPerZone / 5)
                     {
                        kumaTooltip = "You are being watched from the shadows.";
                     }
                     else if(consecutiveEasyBossesKilled < 4 * preKumaMonstersPerZone / 5)
                     {
                        kumaTooltip = "You have Kumawakamaru\'s attention.";
                     }
                     else
                     {
                        kumaTooltip = "You don\'t belong here.";
                     }
                     return {
                        "header":"...",
                        "body":kumaTooltip
                     };
                  };
                  this.buffs.addBuff(buff);
               }
            }
         }
         else
         {
            this.highestMonstersKilled[CH2.currentCharacter.currentWorldId] = (monster.zoneSpawned - 1) * this.monstersPerZone + this.monstersKilledOnCurrentZone;
         }
         if(!this.runsCompletedPerWorld.hasOwnProperty(this.currentWorldId))
         {
            this.runsCompletedPerWorld[this.currentWorldId] = 0;
         }
         this.addExperience(Formulas.instance.getMonsterExperience(monster));
         if(!CH2.user.isOnBossZone && this.hasCompletedCurrentZone() && !CH2.user.isOnFinalBossZone)
         {
            this.eventLogger.logEvent(EventLog.BEAT_ZONE);
            CH2.world.moveToNextZone(false);
         }
         else if(!this.isNextMonsterInRange && !this.isPaused)
         {
            this.changeState(STATE_ENDING_COMBAT);
         }
      }
      
      public function highestZoneOnWorld(worldNumber:int) : int
      {
         if(!this.highestMonstersKilled.hasOwnProperty(worldNumber))
         {
            return 0;
         }
         return Math.floor(this.highestMonstersKilled[worldNumber] / this.monstersPerZone);
      }
      
      public function resetMonstersKilledOnZone(zone:int) : void
      {
         this.monstersKilledPerZone[zone] = 0;
      }
      
      public function onZoneChanged(zoneNumber:int) : void
      {
         if(this.onZoneChangedHandler)
         {
            this.onZoneChangedHandler.onZoneChangedOverride(zoneNumber);
         }
         else
         {
            this.onZoneChangedDefault(zoneNumber);
         }
      }
      
      public function onZoneChangedDefault(zoneNumber:int) : void
      {
         this.currentZone = zoneNumber;
         if(this.highestZone < this.currentZone)
         {
            if(CH2.user.isOnBossZone)
            {
               this.attemptsOnCurrrentBoss = 0;
            }
            this.highestZone = this.currentZone;
            this.monstersKilledPerZone[this.currentZone] = 0;
         }
         this.changeState(STATE_ENDING_COMBAT);
         this.zoneStartGold.base = this.gold.base;
         this.zoneStartGold.power = this.gold.power;
      }
      
      public function onTimedZoneStart() : void
      {
         this.monstersKilledPerZone[this.currentZone] = 0;
      }
      
      public function addToTotalOneShotMonsters() : void
      {
         this.totalOneShotMonsters++;
      }
      
      public function calculateNewWorldBonusExperience() : BigNumber
      {
         var bonusExperience:BigNumber = null;
         var i:int = 0;
         var worldExperience:BigNumber = null;
         var totalMonstersForBonus:Number = NaN;
         if(this.highestWorldCompleted >= 1)
         {
            bonusExperience = new BigNumber(0);
            for(i = 1; i <= this.highestWorldCompleted; i++)
            {
               worldExperience = Formulas.instance.getMonsterExperienceForWorld(i);
               totalMonstersForBonus = this.monstersPerZone * 100 - this.highestMonstersKilled[i];
               worldExperience.timesEqualsN(totalMonstersForBonus);
               bonusExperience.plusEquals(worldExperience);
            }
            return bonusExperience;
         }
         return new BigNumber(0);
      }
      
      public function calculateBonusExperience(param1:Number, param2:int = 0) : BigNumber
      {
         var _loc3_:BigNumber = null;
         var _loc4_:int = 0;
         var _loc5_:BigNumber = null;
         var _loc6_:Number = NaN;
         var _loc7_:int = 0;
         var _loc8_:BigNumber = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(this.runsCompletedPerWorld[param1] < 5 - param2)
         {
            _loc3_ = new BigNumber(0);
            for(_loc4_ = param1 - 1; _loc4_ > 0; _loc4_--)
            {
               _loc5_ = Formulas.instance.getMonsterExperienceForWorld(_loc4_);
               if(param2 > 0)
               {
                  _loc6_ = this.monstersPerZone * 100 - this.highestMonstersKilled[_loc4_];
                  _loc5_.timesEqualsN(_loc6_);
                  for(_loc7_ = 1; _loc7_ <= param2; _loc7_++)
                  {
                     _loc8_ = Formulas.instance.getMonsterExperienceForWorld(_loc4_);
                     _loc8_.timesEqualsN(this.monstersPerZone * 100);
                     _loc8_.timesEqualsN(Math.pow(0.965,_loc7_));
                     _loc5_.plusEquals(_loc8_);
                  }
               }
               else
               {
                  _loc6_ = this.monstersPerZone * 100 - this.highestMonstersKilled[_loc4_];
                  _loc5_.timesEqualsN(_loc6_);
               }
               if(this.runsCompletedPerWorld[_loc4_] < 5)
               {
                  _loc9_ = Math.max(5 - this.runsCompletedPerWorld[_loc4_],0);
                  _loc10_ = Math.min(1 + param2,_loc9_);
                  param2 = param2 + _loc10_;
               }
               _loc3_.plusEquals(_loc5_);
            }
            return _loc3_;
         }
         return new BigNumber(0);
      }
      
      public function drainWorldsUpTo(worldNumber:Number) : *
      {
         var j:int = 0;
         var worldExperience:BigNumber = null;
         var totalMonstersForBonus:Number = NaN;
         var extraRuns:int = 0;
         var bonusExperience:BigNumber = new BigNumber(0);
         for(var i:int = worldNumber; i > 0; i--)
         {
            for(j = 0; j < 1000; j++)
            {
               worldExperience = Formulas.instance.getMonsterExperienceForWorld(i);
               totalMonstersForBonus = this.monstersPerZone * 100 - this.highestMonstersKilled[i];
               worldExperience.timesEqualsN(totalMonstersForBonus);
               this.runsCompletedPerWorld[i]++;
               this.highestMonstersKilled[i] = 0;
               bonusExperience.plusEquals(worldExperience);
            }
         }
         this.addExperience(bonusExperience);
      }
      
      public function onWorldFinished() : void
      {
         if(this.onWorldFinishedHandler)
         {
            this.onWorldFinishedHandler.onWorldFinishedOverride();
         }
         else
         {
            this.onWorldFinishedDefault();
         }
      }
      
      public function onWorldFinishedDefault() : void
      {
         var totalPowerNeeded:BigNumber = null;
         var totalCrumbsNeeded:BigNumber = null;
         var totalPreviousCrumbs:BigNumber = null;
         var newCrumbs:BigNumber = null;
         var slot:int = 0;
         this.didFinishWorld = true;
         this.highestMonstersKilled[this.currentWorldId] = 0;
         if(this.runsCompletedPerWorld.hasOwnProperty(this.currentWorldId))
         {
            this.runsCompletedPerWorld[this.currentWorldId]++;
         }
         else
         {
            this.runsCompletedPerWorld[this.currentWorldId] = 1;
         }
         if(this.currentWorldId > this.highestWorldCompleted)
         {
            this.highestWorldCompleted = this.currentWorldId;
            this.highestEtherealItemAcquired = this.currentWorldId;
            this.worlds.getWorld(this.currentWorldId + 1);
            totalPowerNeeded = new BigNumber(1.1).pow(this.highestWorldCompleted);
            totalCrumbsNeeded = totalPowerNeeded.addN(-1).divideN(0.1);
            totalPreviousCrumbs = totalPowerNeeded.divideN(1.1).addN(-1).divideN(0.1);
            newCrumbs = totalCrumbsNeeded.subtract(totalPreviousCrumbs);
            this.worldCrumbs.plusEquals(newCrumbs);
            this.pendingHeroSouls.plusEquals(Formulas.instance.getHeroSoulsForSystem(CH2.currentCharacter.currentWorld.starSystemId).multiplyN(0.5).multiplyN(1 / CH2.currentCharacter.worldsPerSystem));
            if(this.currentWorldId % this.worldsPerSystem == 0)
            {
               this.starfire = this.starfire + 1;
               this.pendingHeroSouls.plusEquals(Formulas.instance.getHeroSoulsForSystem(CH2.currentCharacter.currentWorld.starSystemId).multiplyN(0.5));
            }
            this.shouldShowNewEtherealItemPopup = true;
            this.etherealItemIndiciesForPopup = [];
            if(this.highestWorldCompleted <= 8)
            {
               slot = 8 - (this.highestWorldCompleted - 1);
               this.etherealItemIndiciesForPopup.push(this.addEtherealItemToInventory(this.rollEtherealItem(CH2.currentCharacter.currentWorld.starSystemId,slot - 1)));
            }
            else
            {
               this.etherealItemIndiciesForPopup.push(this.addEtherealItemToInventory(this.rollEtherealItem(CH2.currentCharacter.currentWorld.starSystemId)));
            }
         }
         if(this.fastestWorldTimes.hasOwnProperty(this.currentWorldId))
         {
            if(this.fastestWorldTimes[this.currentWorldId] > this.timeSinceMostRecentRunBegan)
            {
               this.fastestWorldTimes[this.currentWorldId] = this.timeSinceMostRecentRunBegan;
            }
         }
         else
         {
            this.fastestWorldTimes[this.currentWorldId] = this.timeSinceMostRecentRunBegan;
         }
         CH2.user.remoteStatsTracking.addEvent({
            "type":"finishRun",
            "world":this.currentWorldId,
            "runsInPreviousWorld":this.runsCompletedPerWorld[this.currentWorldId],
            "startTimestamp":ServerTimeKeeper.instance.secondsTimestamp - (CH2.user.totalMsecsPlayed - this.timeOfLastRun) / 1000,
            "endTimestamp":ServerTimeKeeper.instance.secondsTimestamp,
            "characterLevel":this.level,
            "ancientShardsPurchased":this.ancientShards
         });
         if(CH2.user.permadeathJokeEnabled && !CH2.currentCharacter.achievements.isAchievementComplete(24))
         {
            CH2.user.awardAchievement(24);
         }
         if(!this.killedMonsterDuringWorld && !CH2.currentCharacter.achievements.isAchievementComplete(25))
         {
            CH2.user.awardAchievement(25);
         }
         if(!this.interactedWithGameDuringDuringWorld && !CH2.currentCharacter.achievements.isAchievementComplete(30) && this.name == "Helpful Adventurer")
         {
            CH2.user.awardAchievement(30);
         }
         this.killedMonsterDuringWorld = false;
         this.interactedWithGameDuringDuringWorld = false;
      }
      
      public function setHighestWorldCompleted(newHighestWorldCompleted:int) : void
      {
         this.highestWorldCompleted = newHighestWorldCompleted;
         this.highestEtherealItemAcquired = newHighestWorldCompleted;
         this.worlds.getWorld(this.highestWorldCompleted + 1);
         this.inputLogger.recordInput(GameActions.SET_NEW_HIGHEST_WORLD,newHighestWorldCompleted);
      }
      
      public function getCalculatedEnergyCost(skill:Skill) : Number
      {
         if(this.getCalculatedEnergyCostHandler)
         {
            return this.getCalculatedEnergyCostHandler.getCalculatedEnergyCostOverride(skill);
         }
         return this.getCalculatedEnergyCostDefault(skill);
      }
      
      public function getCalculatedEnergyCostDefault(skill:Skill) : Number
      {
         if(!skill.usesMaxEnergy)
         {
            return skill.energyCost * (1 - this.energyCostReduction.numberValue());
         }
         return this.maxEnergy.numberValue();
      }
      
      public function onWorldChange() : void
      {
         if(this.onWorldChangeHandler)
         {
            this.onWorldChangeHandler.onWorldChangeOverride();
         }
         else
         {
            this.onWorldChangeDefault();
         }
      }
      
      public function onWorldChangeDefault() : void
      {
         var sclass:Class = null;
         for(var i:int = 0; i < VALUES_RESET_AT_ASCENSION.length; i++)
         {
            if(MiscUtils.isPrimitive(this[VALUES_RESET_AT_ASCENSION[i]]))
            {
               this[VALUES_RESET_AT_ASCENSION[i]] = Characters.startingDefaultInstances[this.name][VALUES_RESET_AT_ASCENSION[i]];
            }
            else if(this[VALUES_RESET_AT_ASCENSION[i]] != null)
            {
               sclass = Class(getDefinitionByName(getQualifiedClassName(this[VALUES_RESET_AT_ASCENSION[i]])));
               this[VALUES_RESET_AT_ASCENSION[i]] = new sclass();
            }
         }
         this.timeOfLastAscension = CH2.user.totalMsecsPlayed;
      }
      
      public function get damage() : BigNumber
      {
         return this.damageValue();
      }
      
      public function damageValue() : BigNumber
      {
         if(this.damageValueHandler)
         {
            return this.damageValueHandler.damageValueOverride();
         }
         return this.damageValueDefault();
      }
      
      public function damageValueDefault() : BigNumber
      {
         var dmg:BigNumber = this.inventory.getEquippedDamage().add(this.unarmedDamage);
         dmg.timesEqualsN(this.ancientShardDamageMultiplier);
         dmg.timesEqualsN(1 + (!!this.powerRuneActivated?POWER_RUNE_DAMAGE_BONUS:0));
         dmg.timesEquals(this.damageMultiplier);
         dmg.timesEquals(this.ascensionDamageMultiplier);
         if(this.isIdle)
         {
            dmg.timesEquals(this.idleDamageMultiplier);
         }
         dmg.floorInPlace();
         dmg.atLeastOne();
         return dmg;
      }
      
      public function get characterDamageMultipliers() : BigNumber
      {
         var multiplier:BigNumber = this.ascensionDamageMultiplier.multiplyN(1 + (!!this.powerRuneActivated?POWER_RUNE_DAMAGE_BONUS:0)).multiply(this.damageMultiplier).multiplyN(this.ancientShardDamageMultiplier);
         if(this.isIdle)
         {
            multiplier.timesEquals(this.idleDamageMultiplier);
         }
         return multiplier;
      }
      
      public function get treasureChestChance() : BigNumber
      {
         return this.getStat(CH2.STAT_TREASURE_CHEST_CHANCE);
      }
      
      public function get treasureChestGold() : BigNumber
      {
         return this.getStat(CH2.STAT_TREASURE_CHEST_GOLD);
      }
      
      public function get monsterGold() : BigNumber
      {
         return this.getStat(CH2.STAT_MONSTER_GOLD);
      }
      
      public function get clickableGold() : BigNumber
      {
         return this.getStat(CH2.STAT_CLICKABLE_GOLD);
      }
      
      public function get walkSpeed() : Number
      {
         return WALK_SPEED_METERS_PER_SECOND * this.walkSpeedMultiplier.numberValue();
      }
      
      public function get autoAttackDamage() : BigNumber
      {
         return this.damage.multiply(this.autoAttackDamageMultiplier);
      }
      
      public function get clickDamage() : BigNumber
      {
         return this.damage.multiply(this.clickDamageMultiplier);
      }
      
      public function get hasteRating() : BigNumber
      {
         return this.getStat(CH2.STAT_HASTE).multiplyN(1 + (!!this.speedRuneActivated?SPEED_RUNE_HASTE_BONUS:0));
      }
      
      public function get automatorSpeed() : BigNumber
      {
         return this.getStat(CH2.STAT_AUTOMATOR_SPEED);
      }
      
      public function get baseAttackDelay() : Number
      {
         return this.attackMsDelay;
      }
      
      public function get attackDelay() : Number
      {
         return this.baseAttackDelay / this.hasteRating.numberValue();
      }
      
      public function get baseGCD() : Number
      {
         return this.gcdBase;
      }
      
      public function get gcd() : Number
      {
         return Math.max(this.baseGCD / this.hasteRating.numberValue(),this.gcdMinimum);
      }
      
      public function get pierceChance() : BigNumber
      {
         return this.getStat(CH2.STAT_PIERCE_CHANCE);
      }
      
      public function get criticalChance() : BigNumber
      {
         return this.getStat(CH2.STAT_CRIT_CHANCE).addN(!!this.luckRuneActivated?Number(LUCK_RUNE_CRITICAL_BONUS):Number(0));
      }
      
      public function get bonusGoldChance() : BigNumber
      {
         return this.getStat(CH2.STAT_BONUS_GOLD_CHANCE);
      }
      
      public function get itemCostReduction() : BigNumber
      {
         return this.getStat(CH2.STAT_ITEM_COST_REDUCTION);
      }
      
      public function get baseMaxMana() : Number
      {
         return this.statBaseValues[CH2.STAT_TOTAL_MANA];
      }
      
      public function get maxMana() : BigNumber
      {
         return this.getStat(CH2.STAT_TOTAL_MANA);
      }
      
      public function get baseMaxEnergy() : Number
      {
         return this.statBaseValues[CH2.STAT_TOTAL_ENERGY];
      }
      
      public function get maxEnergy() : BigNumber
      {
         return this.getStat(CH2.STAT_TOTAL_ENERGY);
      }
      
      public function get hasIdleBonuses() : Boolean
      {
         return !this.idleMonsterGoldMultiplier.eqN(1) || !this.idleDamageMultiplier.eqN(1);
      }
      
      public function get idleMonsterGoldMultiplier() : BigNumber
      {
         return this.getStat(CH2.STAT_IDLE_GOLD);
      }
      
      public function get walkSpeedMultiplier() : BigNumber
      {
         if(!CH2.world.isBossZone(this.currentZone))
         {
            return this.getStat(CH2.STAT_MOVEMENT_SPEED);
         }
         return new BigNumber(1);
      }
      
      public function get damageMultiplier() : BigNumber
      {
         return this.getStat(CH2.STAT_DAMAGE);
      }
      
      public function get ancientShardDamageMultiplier() : Number
      {
         return Math.pow(ANCIENT_SHARD_DAMAGE_BONUS,this.ancientShards);
      }
      
      public function get monsterGoldMultiplier() : BigNumber
      {
         return this.getStat(CH2.STAT_GOLD);
      }
      
      public function get criticalDamageMultiplier() : BigNumber
      {
         return this.getStat(CH2.STAT_CRIT_DAMAGE);
      }
      
      public function get maxManaMultiplier() : Number
      {
         return 1;
      }
      
      public function get maxEnergyMultiplier() : Number
      {
         return 1;
      }
      
      public function get bonusGoldChanceRating() : BigNumber
      {
         return this.getStat(CH2.STAT_BONUS_GOLD_CHANCE);
      }
      
      public function get itemCostReductionRating() : BigNumber
      {
         return this.getStat(CH2.STAT_ITEM_COST_REDUCTION);
      }
      
      public function get energyRegeneration() : BigNumber
      {
         var temp:BigNumber = this.getStat(CH2.STAT_ENERGY_REGEN);
         temp.plusEqualsN(ENERGY_REGEN_PER_AUTO_ATTACK);
         return temp;
      }
      
      public function get autoattackDamageMultiplier() : Number
      {
         return 1;
      }
      
      public function get clickDamageMultiplier() : BigNumber
      {
         return this.getStat(CH2.STAT_CLICK_DAMAGE);
      }
      
      public function get autoAttackDamageMultiplier() : BigNumber
      {
         return this.getStat(CH2.STAT_AUTOATTACK_DAMAGE);
      }
      
      public function get idleDamageMultiplier() : BigNumber
      {
         return this.getStat(CH2.STAT_IDLE_DAMAGE);
      }
      
      public function get manaRegenMultiplier() : BigNumber
      {
         return this.getStat(CH2.STAT_MANA_REGEN);
      }
      
      public function get energyCostReduction() : BigNumber
      {
         return this.getStat(CH2.STAT_ENERGY_COST_REDUCTION);
      }
      
      public function get clickableChance() : BigNumber
      {
         return this.getStat(CH2.STAT_CLICKABLE_CHANCE);
      }
      
      public function getMultiplierForItemType(type:int) : BigNumber
      {
         switch(type)
         {
            case Item.TYPE_WEAPON:
               return this.getStat(CH2.STAT_ITEM_WEAPON_DAMAGE);
            case Item.TYPE_BACK:
               return this.getStat(CH2.STAT_ITEM_BACK_DAMAGE);
            case Item.TYPE_HEAD:
               return this.getStat(CH2.STAT_ITEM_HEAD_DAMAGE);
            case Item.TYPE_CHEST:
               return this.getStat(CH2.STAT_ITEM_CHEST_DAMAGE);
            case Item.TYPE_FINGER:
               return this.getStat(CH2.STAT_ITEM_RING_DAMAGE);
            case Item.TYPE_LEGS:
               return this.getStat(CH2.STAT_ITEM_LEGS_DAMAGE);
            case Item.TYPE_HANDS:
               return this.getStat(CH2.STAT_ITEM_HANDS_DAMAGE);
            case Item.TYPE_FEET:
               return this.getStat(CH2.STAT_ITEM_FEET_DAMAGE);
            default:
               Trace("Error item type doesn\'t exist");
               return new BigNumber(1);
         }
      }
      
      public function getStat(id:Number) : BigNumber
      {
         var statRating:BigNumber = null;
         var statMultiplier:BigNumber = null;
         if(CH2.STATS[id].calculationType == CH2.ADDITIVE)
         {
            statRating = this.getClassStat(id);
            statRating = statRating.addN(this.inventory.getEquippedStatRating(id));
            statRating.plusEqualsN(this.buffs.getBuffedStatRating(id));
            statRating.timesEqualsN(this.getEtherealEquippedStatMultiplier(id));
            return statRating;
         }
         if(CH2.STATS[id].calculationType == CH2.MULTIPLICATIVE)
         {
            statMultiplier = this.getClassStat(id);
            statMultiplier = statMultiplier.multiplyN(this.inventory.getEquippedStatMultiplier(id));
            statMultiplier.timesEqualsN(this.getEtherealEquippedStatMultiplier(id));
            statMultiplier.timesEqualsN(this.buffs.getBuffedStatMultiplier(id));
            return statMultiplier;
         }
         return new BigNumber(1);
      }
      
      public function getStatMultiplier(id:Number) : Number
      {
         var statMultiplier:Number = 1;
         statMultiplier = statMultiplier * this.inventory.getEquippedStatMultiplier(id);
         statMultiplier = statMultiplier * this.buffs.getBuffedStatMultiplier(id);
         return statMultiplier;
      }
      
      public function getStatRating(id:Number) : Number
      {
         var statRating:Number = 0;
         statRating = statRating + this.inventory.getEquippedStatRating(id);
         statRating = statRating + this.buffs.getBuffedStatRating(id);
         return statRating;
      }
      
      public function setupSkillTree() : void
      {
         var key:* = null;
         for(key in this.levelGraphNodeTypes)
         {
            if(this.levelGraphNodeTypes[key].setupFunction)
            {
               this.levelGraphNodeTypes[key].setupFunction();
            }
         }
      }
      
      public function setupSkills() : void
      {
         var _loc1_:Skill = null;
         var _loc2_:* = null;
         for each(_loc1_ in staticSkillInstances)
         {
            if(!this.getSkill(_loc1_.uid))
            {
               this.addSkill(_loc1_);
               this.initializeStaticValues(_loc1_.uid);
               this.getSkill(_loc1_.uid).initialize();
            }
            else
            {
               this.initializeStaticValues(_loc1_.uid);
            }
         }
         for(_loc2_ in this.skills)
         {
            _loc1_ = this.skills[_loc2_];
            if(!this.getStaticSkill(_loc1_.uid))
            {
               delete this.skills[_loc2_];
            }
            else if(_loc1_.isActive)
            {
               this.activeSkills.push(_loc1_);
            }
         }
         this.activeSkills.sortOn("uid",Array.DESCENDING);
      }
      
      public function getSkill(uid:String) : Skill
      {
         if(this.skills[uid])
         {
            return this.skills[uid];
         }
         return null;
      }
      
      public function replaceSkill(replaceUid:String, newSkill:Skill) : void
      {
         var slot:Number = null;
         if(this.skills[replaceUid] && this.skills[replaceUid].isActive)
         {
            slot = this.skills[replaceUid].slot;
            if(slot >= 0 && slot < CH2UI.instance.mainUI.hud.skillBar.skillSlots.length)
            {
               if(CH2UI.instance.mainUI.hud.skillBar.skillSlots[slot].skillSlotUI != null)
               {
                  CH2UI.instance.mainUI.hud.skillBar.skillSlots[slot].skillSlotUI.skill = null;
                  CH2UI.instance.mainUI.hud.skillBar.skillSlots[slot].skillSlotUI.removeItemIcon();
               }
            }
            this.deactivateSkill(replaceUid);
         }
         this.activateSkill(newSkill.uid);
         if(slot)
         {
            newSkill.slot = slot;
         }
      }
      
      public function getStaticSkill(uid:String) : Skill
      {
         if(staticSkillInstances[uid])
         {
            return staticSkillInstances[uid];
         }
         return null;
      }
      
      public function addSkill(staticSkill:Skill) : void
      {
         var skill:Skill = new Skill();
         skill.name = staticSkill.name;
         skill.modName = staticSkill.modName;
         this.skills[skill.uid] = skill;
      }
      
      public function getActiveSkillByName(name:String) : Skill
      {
         var skill:Skill = null;
         for each(skill in this.activeSkills)
         {
            if(skill.name == name)
            {
               return skill;
            }
         }
         return null;
      }
      
      public function initializeStaticValues(skillUid:String) : void
      {
         var i:int = 0;
         var key:String = null;
         var staticSkillInstance:Skill = this.getStaticSkill(skillUid);
         for(i = 0; i < Skill.staticFields.length; i++)
         {
            key = Skill.staticFields[i];
            this.skills[skillUid][key] = staticSkillInstance[key];
         }
      }
      
      public function cooldownSkills(dt:int, currentHaste:Number) : void
      {
         var skill:Skill = null;
         var cooldownTime:Number = dt * currentHaste;
         for each(skill in this.activeSkills)
         {
            skill.cooldownRemaining = skill.cooldownRemaining - cooldownTime;
         }
      }
      
      public function deactivateAllSkills() : void
      {
         var id:* = null;
         for(id in this.skills)
         {
            this.skills[id].isActive = false;
            this.skills[id].cooldownRemaining = 0;
         }
         this.activeSkills = [];
         if(CH2UI.instance.mainUI)
         {
            CH2UI.instance.mainUI.mainPanel.skillsPanel.clearSkillsPanelEntries();
         }
      }
      
      public function activateSkill(skillUid:String) : void
      {
         var skill:Skill = this.getSkill(skillUid);
         if(skill)
         {
            if(!skill.isActive)
            {
               skill.timeOfUnlock = CH2.user.totalMsecsPlayed;
               skill.isActive = true;
               skill.slot = this.getFirstOpenSkillBarSlot();
               if(skill.slot < 0)
               {
                  this.hasNewSkillAvailable = true;
               }
               this.activeSkills.push(skill);
            }
            return;
         }
         throw Error("Can\'t find skill with uid: " + skillUid);
      }
      
      public function deactivateSkill(skillUid:String) : void
      {
         var skill:Skill = this.getSkill(skillUid);
         if(skill && skill.isActive)
         {
            skill.isActive = false;
            skill.cooldownRemaining = 0;
            this.activeSkills.splice(this.activeSkills.indexOf(skill),1);
            CH2UI.instance.mainUI.mainPanel.skillsPanel.clearSkillsPanelEntries();
            return;
         }
         throw Error("Can\'t find skill with uid: " + skillUid);
      }
      
      public function getFirstOpenSkillBarSlot() : int
      {
         var slotsUsed:Array = [0,0,0,0,0,0,0,0];
         for(var i:int = 0; i < this.activeSkills.length; i++)
         {
            if(this.activeSkills[i].slot > -1)
            {
               slotsUsed[this.activeSkills[i].slot]++;
            }
         }
         return slotsUsed.indexOf(0);
      }
      
      public function getSkillStaticHolderIndex(skill:Skill) : int
      {
         for(var i:int = 0; i < this.activeSkills.length; i++)
         {
            if(this.activeSkills[i] == skill)
            {
               return i;
            }
         }
         return -1;
      }
      
      public function addGold(goldToAdd:BigNumber) : void
      {
         if(this.addGoldHandler)
         {
            this.addGoldHandler.addGoldOverride(goldToAdd);
         }
         else
         {
            this.addGoldDefault(goldToAdd);
         }
      }
      
      public function addGoldDefault(goldToAdd:BigNumber) : void
      {
         this.gold.plusEquals(goldToAdd);
         if(goldToAdd.gtN(0))
         {
            this.buffs.onGoldGained(goldToAdd);
            this.totalGold.plusEquals(goldToAdd);
            this.logGold(goldToAdd);
         }
         else
         {
            CH2.user.addUserInputActions("SPENT_GOLD");
            this.logGoldSpent(goldToAdd.multiplyN(-1));
         }
         CH2UI.instance.refreshGoldDisplays();
      }
      
      public function subtractGold(goldToSubtract:BigNumber) : void
      {
         this.addGold(goldToSubtract.multiplyN(-1));
      }
      
      public function addRubies(rubiesToAdd:Number, type:String = "", id:String = "") : void
      {
         if(this.addRubiesHandler)
         {
            this.addRubiesHandler.addRubiesOverride(rubiesToAdd,type,id);
         }
         else
         {
            this.addRubiesDefault(rubiesToAdd,type,id);
         }
      }
      
      public function addRubiesDefault(rubiesToAdd:Number, type:String = "", id:String = "") : void
      {
         this.rubies = this.rubies + rubiesToAdd;
         if(rubiesToAdd > 0)
         {
            this.totalRubies = this.totalRubies + rubiesToAdd;
         }
         CH2UI.instance.refreshRubiesDisplays();
      }
      
      public function subtractRubies(rubiesToSubtract:Number, type:String = "", id:String = "") : void
      {
         this.addRubies(rubiesToSubtract * -1,type,id);
      }
      
      public function regenerateManaAndEnergy(time:Number) : void
      {
         if(this.regenerateManaAndEnergyHandler)
         {
            this.regenerateManaAndEnergyHandler.regenerateManaAndEnergyOverride(time);
         }
         else
         {
            this.regenerateManaAndEnergyDefault(time);
         }
      }
      
      public function regenerateManaAndEnergyDefault(time:Number) : void
      {
         var timeInSeconds:Number = time / 1000;
         var manaToAdd:Number = timeInSeconds * this.getManaRegenRate();
         this.addMana(manaToAdd,false);
      }
      
      public function getManaRegenRate() : Number
      {
         return 1 / SECONDS_FROM_ZERO_TO_BASE_MAX_MANA_WITHOUT_MANA_REGEN_STATS * this.statBaseValues[CH2.STAT_TOTAL_MANA] * this.manaRegenMultiplier.numberValue();
      }
      
      public function addEnergy(amount:Number, showFloatingText:Boolean = true) : void
      {
         if(this.addEnergyHandler)
         {
            this.addEnergyHandler.addEnergyOverride(amount,showFloatingText);
         }
         else
         {
            this.addEnergyDefault(amount,showFloatingText);
         }
      }
      
      public function addEnergyDefault(amount:Number, showFloatingText:Boolean = true) : void
      {
         var total:* = undefined;
         var maxTotal:* = undefined;
         var previousEnergy:Number = this.energy;
         var maxEnergyN:Number = this.maxEnergy.numberValue();
         if(this.energy < maxEnergyN || amount < 0 || this.energy == maxEnergyN && amount > this.energyRegeneration.numberValue())
         {
            total = this.energy + amount;
            maxTotal = maxEnergyN + 50;
            if(total >= maxTotal)
            {
               this.energy = maxTotal;
            }
            else
            {
               this.energy = total;
            }
         }
         if(this.energy < 0)
         {
            this.energy = 0;
         }
         if(amount < 0)
         {
            this.logEnergyUsed(new BigNumber(amount * -1));
         }
         if(this.energy == 0)
         {
            this.timeOfLastOutOfEnergy = CH2.user.totalMsecsPlayed;
         }
         if(this.energy != previousEnergy && showFloatingText)
         {
            if(this.energy > previousEnergy)
            {
               CH2UI.instance.mainUI.hud.playEnergyGainedEffect();
            }
            CH2UI.instance.mainUI.hud.showEnergyUsed(this.energy - previousEnergy);
         }
      }
      
      public function addMana(amount:Number, showFloatingText:Boolean = true) : void
      {
         if(this.addManaHandler)
         {
            this.addManaHandler.addManaOverride(amount,showFloatingText);
         }
         else
         {
            this.addManaDefault(amount,showFloatingText);
         }
      }
      
      public function addManaDefault(amount:Number, showFloatingText:Boolean = true) : void
      {
         var total:* = undefined;
         var maxTotal:* = undefined;
         var previousMana:Number = this.mana;
         var maxManaN:Number = this.maxMana.numberValue();
         if(this.mana <= maxManaN || amount < 0)
         {
            total = this.mana + amount;
            maxTotal = maxManaN + 50;
            if(total >= maxTotal)
            {
               this.mana = maxTotal;
            }
            else
            {
               this.mana = total;
            }
         }
         if(this.mana < 0)
         {
            this.mana = 0;
         }
         if(amount < 0)
         {
            this.logManaUsed(new BigNumber(amount * -1));
         }
         if(this.mana != previousMana && showFloatingText)
         {
            if(this.mana > previousMana)
            {
               CH2UI.instance.mainUI.hud.playManaGainedEffect();
            }
            CH2UI.instance.mainUI.hud.showManaUsed(this.mana - previousMana);
         }
      }
      
      public function canUseSkill(skill:Skill) : Boolean
      {
         if(this.canUseSkillHandler)
         {
            return this.canUseSkillHandler.canUseSkillOverride(skill);
         }
         return this.canUseSkillDefault(skill);
      }
      
      public function canUseSkillDefault(skill:Skill) : Boolean
      {
         return skill.canUseSkill;
      }
      
      public function getActiveSkill(uid:String) : Skill
      {
         var activeSkill:Skill = null;
         for each(activeSkill in this.activeSkills)
         {
            if(activeSkill.uid == uid)
            {
               return activeSkill;
            }
         }
         return null;
      }
      
      public function onUsedSkill(skill:Skill) : void
      {
         if(this.onUsedSkillHandler)
         {
            this.onUsedSkillHandler.onUsedSkillOverride(skill);
         }
         else
         {
            this.onUsedSkillDefault(skill);
         }
      }
      
      public function onUsedSkillDefault(skill:Skill) : void
      {
         CH2.user.addUserInputActions("SPENT_GOLD");
         CH2.currentCharacter.buffs.onSkillUse(skill);
         this.totalSkillsUsed++;
      }
      
      public function levelUpItem(item:Item, amount:Number = 1) : void
      {
         if(this.levelUpItemHandler)
         {
            this.levelUpItemHandler.levelUpItemOverride(item,amount);
         }
         else
         {
            this.levelUpItemDefault(item,amount);
         }
      }
      
      public function levelUpItemDefault(item:Item, amount:Number = 1) : void
      {
         var itemCost:BigNumber = null;
         if(item != null)
         {
            itemCost = item.cost(amount);
            if(this.gold.gte(itemCost) && !this.isPurchasingLocked)
            {
               this.inputLogger.recordInput(GameActions["LEVEL_UP_ITEM_" + this.inventory.getSlotFromItem(item.uid)],amount);
               this.subtractGold(itemCost);
               item.level = item.level + amount;
               this.inventory.cachedEquippedDamage.base = -1;
               if(IdleHeroMain.IS_RENDERING)
               {
                  this.excitingUpgradeCheck();
                  CH2UI.instance.mainUI.mainPanel.itemsPanel.updateAllEquipAndCatalogSlots();
                  CH2UI.instance.mainUI.mainPanel.itemsPanel.updatePercentDamage();
                  CH2UI.instance.mainUI.mainPanel.itemsPanel.equipSlots[item.type].updateMultiplierMeter();
               }
               this.totalUpgradesToItems++;
               this.timeOfLastItemUpgrade = CH2.user.totalMsecsPlayed;
               if(IdleHeroMain.IS_RENDERING)
               {
                  item.updateNextPurchaseInfo(this.shouldLevelToNextMultiplier);
               }
            }
            else
            {
               Trace("Not enough gold to level item slot " + this.inventory.getSlotFromItem(item.uid) + " " + amount + "x");
               Trace("Current Gold: " + BigNumberFormatter.newShortenNumber(this.gold) + " Gold Needed: " + BigNumberFormatter.newShortenNumber(itemCost) + "x");
            }
         }
         else
         {
            Trace("Item is null");
         }
      }
      
      public function buyNextItemBonus(item:Item) : void
      {
         if(this.buyNextItemBonusHandler)
         {
            this.buyNextItemBonusHandler.buyNextItemBonusOverride(item);
         }
         else
         {
            this.buyNextItemBonusDefault(item);
         }
      }
      
      public function buyNextItemBonusDefault(item:Item) : void
      {
         var upgradeCost:BigNumber = item.costForNextBonus();
         for(var i:int = 0; i < item.bonuses.length; i++)
         {
            if(item.bonuses[i].level < 0)
            {
               item.bonuses[i].level--;
            }
            else if(item.bonuses[i].level > 0)
            {
               item.bonuses[i].level++;
            }
         }
         this.subtractGold(upgradeCost);
         this.timeOfLastItemUpgrade = CH2.user.totalMsecsPlayed;
      }
      
      public function canAffordAPurchaseOnAllItems() : Boolean
      {
         var item:Item = null;
         var inventory:Array = this.inventory.items;
         for each(item in inventory)
         {
            if(!this.canAffordLevelUpPurchase(item))
            {
               return false;
            }
         }
         return inventory.length > 0;
      }
      
      public function canAffordLevelUpPurchase(item:Item) : Boolean
      {
         return this.gold.gte(item.costForNextPurchase);
      }
      
      public function setUpgradeToNextMultiplier(value:Boolean) : void
      {
         var item:Item = null;
         this.shouldLevelToNextMultiplier = value;
         for each(item in this.inventory.items)
         {
            item.updateNextPurchaseInfo(value);
         }
      }
      
      public function purchaseCatalogItem(index:int) : void
      {
         if(this.purchaseCatalogItemHandler)
         {
            this.purchaseCatalogItemHandler.purchaseCatalogItemOverride(index);
         }
         else
         {
            this.purchaseCatalogItemDefault(index);
         }
      }
      
      public function purchaseCatalogItemDefault(index:int) : void
      {
         var previousMaxMana:Number = NaN;
         var previousMaxEnergy:Number = NaN;
         var maxManaN:Number = NaN;
         var maxEnergyN:Number = NaN;
         var itemToPurchase:Item = this.catalogItemsForSale[index];
         var itemCost:BigNumber = itemToPurchase.cost();
         if(this.gold.gte(itemCost) && !this.isPurchasingLocked)
         {
            previousMaxMana = this.maxMana.numberValue();
            previousMaxEnergy = this.maxEnergy.numberValue();
            this.eventLogger.logEvent(EventLog.PURCHASED_ITEM);
            this.inputLogger.recordInput(GameActions.PURCHASE_ITEM,index);
            this.subtractGold(itemCost);
            this.inventory.replaceItem(itemToPurchase);
            itemToPurchase.updateNextPurchaseInfo(this.shouldLevelToNextMultiplier);
            CH2UI.instance.mainUI.mainPanel.itemsPanel.equipSlots[itemToPurchase.type].reloadItemIcon();
            CH2UI.instance.mainUI.mainPanel.itemsPanel.equipSlots[itemToPurchase.type].playPurchaseAnimation();
            CH2UI.instance.mainUI.mainPanel.itemsPanel.hideBuyGlowOnSlot(CH2.currentCharacter.currentCatalogRank % 8);
            this.currentCatalogRank++;
            this.generateCatalog();
            this.excitingUpgradeCheck();
            CH2UI.instance.mainUI.mainPanel.itemsPanel.updateAllEquipAndCatalogSlots();
            CH2UI.instance.mainUI.mainPanel.itemsPanel.updateEquipSlotDisplay();
            CH2UI.instance.mainUI.mainPanel.itemsPanel.updateCatalogSlot();
            CH2UI.instance.refreshDamageDisplays();
            this.totalCatalogItemsPurchased++;
            this.timeOfLastCatalogPurchase = CH2.user.totalMsecsPlayed;
            maxManaN = this.maxMana.numberValue();
            maxEnergyN = this.maxEnergy.numberValue();
            if(maxManaN > previousMaxMana)
            {
               this.addMana(maxManaN - previousMaxMana);
            }
            if(maxEnergyN > previousMaxEnergy)
            {
               this.addEnergy(maxEnergyN - previousMaxEnergy);
            }
            if(itemToPurchase.tier > this.highestItemTierSeen)
            {
               this.highestItemTierSeen = itemToPurchase.tier;
            }
            if(!CH2.currentCharacter.achievements.isAchievementComplete(29) && CH2.currentCharacter.itemCostReduction.numberValue() <= 0.1)
            {
               CH2.user.awardAchievement(29);
            }
         }
         else
         {
            Trace("Not enough gold to purchase item rank " + this.currentCatalogRank);
         }
      }
      
      public function generateCatalog() : void
      {
         if(this.generateCatalogHandler)
         {
            this.generateCatalogHandler.generateCatalogOverride();
         }
         else
         {
            this.generateCatalogDefault();
         }
      }
      
      public function generateCatalogDefault() : void
      {
         var _loc5_:Item = null;
         var _loc6_:Item = null;
         this.catalogItemsForSale = [];
         var _loc1_:Number = Math.min(this.currentCatalogRank + 1,MAX_CATALOG_SIZE);
         var _loc2_:Boolean = false;
         var _loc3_:Number = this.currentCatalogRank % Item.ITEM_EQUIP_AMOUNT;
         var _loc4_:Number = CH2.currentCharacter.numGameLoopsProcessed;
         if(this.inventory.items[_loc3_] != null)
         {
            _loc5_ = this.inventory.items[_loc3_];
            while(this.catalogItemsForSale.length < _loc1_ - 1)
            {
               _loc6_ = new Item();
               _loc6_.level = 1;
               _loc6_.init(_loc3_,this.currentWorld.itemCostCurve,this.currentWorld.costMultiplier,this.currentCatalogRank + 1,_loc4_ + this.catalogItemsForSale.length,_loc5_.bonuses);
               this.catalogItemsForSale.push(_loc6_);
            }
         }
         while(this.catalogItemsForSale.length < _loc1_)
         {
            _loc6_ = new Item();
            _loc6_.level = 1;
            _loc6_.init(_loc3_,this.currentWorld.itemCostCurve,this.currentWorld.costMultiplier,this.currentCatalogRank + 1,_loc4_ + this.catalogItemsForSale.length);
            if(!_loc2_)
            {
               _loc2_ = _loc6_.isCursed;
            }
            this.catalogItemsForSale.push(_loc6_);
         }
         CH2UI.instance.refreshCatalogDisplay();
      }
      
      public function get itemPurchasesLocked() : Boolean
      {
         return this.isPurchasingLocked;
      }
      
      public function lockItemPurchases() : void
      {
         this.isPurchasingLocked = true;
         CH2UI.instance.refreshCatalogDisplay();
      }
      
      public function unlockItemPurchases() : void
      {
         this.isPurchasingLocked = false;
         CH2UI.instance.refreshCatalogDisplay();
      }
      
      public function getCurrentCatalogPrice() : BigNumber
      {
         return this.catalogItemsForSale[0].cost();
      }
      
      public function walk(dt:Number) : void
      {
         if(this.walkHandler)
         {
            this.walkHandler.walkOverride(dt);
         }
         else
         {
            this.walkDefault(dt);
         }
      }
      
      public function walkDefault(dt:Number) : void
      {
         var distanceWalked:Number = this.walkSpeed * (dt / 1000) * ONE_METER_Y_DISTANCE;
         var closestMonster:Monster = CH2.world.getNextMonster();
         var distanceToNextMonster:Number = closestMonster != null?Number(closestMonster.y - this.attackRange - this.y):Number(1000);
         distanceWalked = Math.min(distanceWalked,distanceToNextMonster);
         this.y = this.y + distanceWalked;
         this.totalRunDistance = this.totalRunDistance + distanceWalked;
         if(this.isNextMonsterInRange)
         {
            this.changeState(STATE_COMBAT);
         }
      }
      
      public function playRandomHitSound(attackData:AttackData) : void
      {
         var volume:Number = !!attackData.isAutoAttack?Number(0.2):Number(0.52);
         if(attackData.isKillShot || attackData.isCritical)
         {
            volume = volume * 1.5;
         }
         if(attackData.isCritical)
         {
            SoundManager.instance.playSound("critical_hit",volume,SoundManager.RESPONSIVE_EFFECTS_PRIORITY);
         }
         else
         {
            SoundManager.instance.playSound("hit",volume,SoundManager.RESPONSIVE_EFFECTS_PRIORITY);
         }
      }
      
      public function getClassStat(param1:int) : BigNumber
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Function = null;
         var _loc5_:Number = NaN;
         var _loc6_:BigNumber = null;
         if(!this.classStatsCached)
         {
            for(_loc2_ = 0; _loc2_ < CH2.STATS.length; )
            {
               _loc3_ = 0;
               if(this.statLevels[_loc2_])
               {
                  _loc3_ = this.statLevels[_loc2_];
               }
               if(!this.statLevelMultipliers[_loc2_])
               {
                  this.statLevelMultipliers[_loc2_] = 1;
               }
               _loc3_ = _loc3_ * this.statLevelMultipliers[_loc2_];
               _loc4_ = this.statValueFunctions[_loc2_];
               _loc5_ = this.statBaseValues[_loc2_];
               if(_loc4_ != null)
               {
                  if(CH2.STATS[_loc2_].calculationType == CH2.MULTIPLICATIVE)
                  {
                     _loc6_ = _loc4_(_loc3_);
                     _loc6_.timesEqualsN(_loc5_);
                     this.cachedClassStats[_loc2_] = _loc6_;
                  }
                  else
                  {
                     _loc6_ = _loc4_(_loc3_);
                     this.cachedClassStats[_loc2_] = _loc6_.addN(_loc5_);
                  }
                  _loc2_++;
                  continue;
               }
               throw Error("Can\'t find value function or base value for stat: " + _loc2_);
            }
            this.classStatsCached = true;
         }
         return this.cachedClassStats[param1];
      }
      
      public function getEtherealEquippedStatMultiplier(id:Number) : Number
      {
         var index:int = 0;
         var etherealItem:EtherealItem = null;
         var etherealItemStatValue:Number = 0;
         for(var i:* = NUMBER_OF_ETHEREAL_ITEM_SLOTS - 1; i >= 0; i--)
         {
            index = this.equippedEtherealItems[i];
            if(index != -1)
            {
               etherealItem = this.etherealItemInventory[index];
               if(etherealItem != null && etherealItem.statId == id)
               {
                  etherealItemStatValue = etherealItemStatValue + etherealItem.getStatValue(etherealItem.statId,etherealItem.systemNumber);
               }
            }
         }
         return etherealItemStatValue + 1;
      }
      
      public function getStatDisplayName(statId:int) : String
      {
         if(CH2.STATS[statId] == null)
         {
            return _("ERROR: UNKNOWN STAT");
         }
         return CH2.STATS[statId].displayName;
      }
      
      public function getStatId(displayName:String) : int
      {
         var i:* = undefined;
         if(displayName == null)
         {
            return -1;
         }
         for(i = 0; i < CH2.STATS.length; i++)
         {
            displayName = displayName.replace(/_/g," ");
            if(displayName.toLowerCase() === CH2.STATS[i].displayName.toLowerCase())
            {
               return CH2.STATS[i].id;
            }
         }
         return -1;
      }
      
      public function getStatDescription(statId:int) : String
      {
         if(CH2.STATS[statId] == null)
         {
            return _("ERROR: UNKNOWN STAT");
         }
         return _(CH2.STATS[statId].description,BigNumberFormatter.shortenNumber(this.getClassStat(statId)));
      }
      
      public function levelUpStat(statId:int, levelsToAdd:int = 1) : void
      {
         if(this.statLevels[statId])
         {
            this.statLevels[statId] = this.statLevels[statId] + levelsToAdd;
         }
         else
         {
            this.statLevels[statId] = levelsToAdd;
         }
         this.classStatsCached = false;
         this.inventory.cachedEquippedDamage.base = -1;
      }
      
      public function gainLevel() : void
      {
         if(this.gainLevelHandler)
         {
            this.gainLevelHandler.gainLevelOverride();
         }
         else
         {
            this.gainLevelDefault();
         }
      }
      
      public function gainLevelDefault() : void
      {
         this.level++;
         var whatever:BigNumber = this.totalStatPoints;
         this.totalStatPointsV2++;
         this.hasNewSkillTreePointsAvailable = true;
         this.timeOfLastLevelUp = CH2.user.totalMsecsPlayed;
         this.eventLogger.logEvent(EventLog.LEVELED_UP);
         var maxEnergyN:Number = this.maxEnergy.numberValue();
         if(this.energy < maxEnergyN)
         {
            this.addEnergy(maxEnergyN - this.energy,false);
         }
         CH2UI.instance.refreshLevelDisplays();
         CH2.user.remoteStatsTracking.addEvent({
            "type":"levelUp",
            "highestWorld":this.highestWorldCompleted,
            "timestamp":ServerTimeKeeper.instance.secondsTimestamp,
            "level":this.level,
            "ancientShardsPurchased":this.ancientShards
         });
      }
      
      public function addExperience(points:BigNumber) : void
      {
         var secondsElapsed:Number = (CH2.user.totalMsecsPlayed - CH2.currentCharacter.timeOfLastRun) / 1000;
         this.experience.plusEquals(points);
         this.totalExperience.plusEquals(points);
         this.experienceForCurrentWorld.plusEquals(points);
         this.logXPEarned(points);
         var didLevel:Boolean = false;
         if(this.levelUpCost.lte(this.experience))
         {
            this.experience.minusEquals(this.experience);
            this.gainLevel();
            didLevel = true;
         }
         if(didLevel)
         {
            if(CH2UI.instance.mainUI)
            {
               CH2UI.instance.mainUI.mainPanel.graphPanel.redrawGraph();
               if(CH2UI.instance.mainUI.mainPanel.isOnGraphPanel)
               {
                  CH2UI.instance.mainUI.mainPanel.graphPanel.updateInteractiveLayer();
               }
            }
            if(this.characterDisplay)
            {
               this.characterDisplay.playLevelUp();
            }
         }
         CH2UI.instance.refreshXPDisplays();
         CH2UI.instance.refreshWorldStatDisplay();
      }
      
      public function getLevelUpCostToNextLevel(level:Number) : BigNumber
      {
         if(this.getLevelUpCostToNextLevelHandler)
         {
            return this.getLevelUpCostToNextLevelHandler.getLevelUpCostToNextLevelOverride(level);
         }
         return this.getLevelUpCostToNextLevelDefault(level);
      }
      
      public function getLevelUpCostToNextLevelDefault(level:Number) : BigNumber
      {
         if(level <= 6)
         {
            return new BigNumber(500 + (level - 1) * 300);
         }
         return new BigNumber(2000 + (level - 6) * 500);
      }
      
      public function getLevelUpCostToNextLevelOld(level:Number) : BigNumber
      {
         if(level == 1)
         {
            return new BigNumber(1000);
         }
         if(level == 2)
         {
            return new BigNumber(2500);
         }
         var result:BigNumber = new BigNumber(1.5);
         return result.pow(level - 1).multiplyN(2500).ceil();
      }
      
      public function get descriptionText() : String
      {
         return this.flavor;
      }
      
      public function ascend() : void
      {
         if(this.ascendHandler)
         {
            this.ascendHandler.ascendOverride();
         }
         else
         {
            this.ascendDefault();
         }
      }
      
      public function ascendDefault() : void
      {
         this.timeSinceLastEtherealItemPurchase = ETHEREAL_ITEM_PURCHASE_COOLDOWN;
         var damageIncrease:BigNumber = new BigNumber(0.1);
         damageIncrease = damageIncrease.multiply(this.worldCrumbs);
         this.ascensionDamageMultiplier.plusEquals(damageIncrease);
         this.worldCrumbs = new BigNumber(0);
         this.starfire = this.starfire - 1;
         this.numAscensions++;
         this.resetAscension();
         this.showCongratsPopupWhenUIIsCreated(damageIncrease);
      }
      
      public function resetAscension() : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = null;
         var _loc6_:Skill = null;
         var _loc7_:Number = NaN;
         var _loc1_:Number = this.carryoverStatPoints;
         var _loc2_:Number = this.statLevels[CH2.STAT_AUTOMATOR_SPEED];
         var _loc3_:Character = new Character();
         _loc3_.name = this.name;
         Characters.populateStaticFields(_loc3_);
         this.buffs.removeAllBuffs();
         for(_loc4_ = 0; _loc4_ < this.activeSkills.length; _loc4_++)
         {
            _loc6_ = this.activeSkills[_loc4_];
            _loc7_ = null;
            if(_loc6_ && _loc6_.isActive)
            {
               _loc7_ = _loc6_.slot;
               if(_loc7_ >= 0 && CH2UI.instance.mainUI)
               {
                  CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc7_].removeChild(CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc7_].skillSlotUI);
                  CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc7_].onDropRemoved(CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc7_].skillSlotUI);
               }
            }
         }
         this.deactivateAllSkills();
         for(_loc4_ = 0; _loc4_ < this.lostOnAscending.length; _loc4_++)
         {
            this[this.lostOnAscending[_loc4_]] = _loc3_[this.lostOnAscending[_loc4_]];
         }
         for(_loc5_ in this.traits)
         {
            if(this.traitPersistanceValues[_loc5_] == false)
            {
               this.traits[_loc5_] = 0;
            }
         }
         if(this.extendedVariables)
         {
            this.extendedVariables.onAscend();
         }
         this.setupSkills();
         this.classStatsCached = false;
         this.statLevels[CH2.STAT_AUTOMATOR_SPEED] = _loc2_;
         if(this.characterDisplay)
         {
            this.characterDisplay.characterUI.removeAll();
         }
         this.totalStatPointsV2 = _loc1_ + this.gildStartBuild.length + this.ascensionStartStatPoints;
         for(_loc4_ = 0; _loc4_ < this.gildStartBuild.length; _loc4_++)
         {
            this.levelGraph.purchaseNode(this.gildStartBuild[_loc4_]);
         }
      }
      
      public function transcend() : void
      {
         if(this.transcendHandler)
         {
            this.transcendHandler.transcendOverride();
         }
         else
         {
            this.transcendDefault();
         }
      }
      
      public function transcendDefault() : void
      {
         var _loc3_:int = 0;
         var _loc5_:* = null;
         var _loc6_:Skill = null;
         var _loc7_:Number = NaN;
         var _loc1_:Number = Math.min(this.transcendenceMotes,Math.floor(10 + this.transcensionLevel));
         this.transcendenceMotes = this.transcendenceMotes - _loc1_;
         this.transcensionLevel = this.transcensionLevel + _loc1_ / (10 + Math.floor(this.transcensionLevel));
         this.heroSouls.plusEquals(this.pendingHeroSouls.multiplyN(_loc1_));
         this.pendingHeroSouls = new BigNumber(0);
         var _loc2_:Character = new Character();
         _loc2_.name = this.name;
         Characters.populateStaticFields(_loc2_);
         this.buffs.removeAllBuffs();
         for(_loc3_ = 0; _loc3_ < this.activeSkills.length; _loc3_++)
         {
            _loc6_ = this.activeSkills[_loc3_];
            _loc7_ = null;
            if(_loc6_ && _loc6_.isActive)
            {
               _loc7_ = _loc6_.slot;
               if(_loc7_ >= 0 && CH2UI.instance.mainUI)
               {
                  CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc7_].removeChild(CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc7_].skillSlotUI);
                  CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc7_].onDropRemoved(CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc7_].skillSlotUI);
               }
            }
         }
         this.deactivateAllSkills();
         for(_loc3_ = 0; _loc3_ < this.lostOnAscending.length; _loc3_++)
         {
            this[this.lostOnAscending[_loc3_]] = _loc2_[this.lostOnAscending[_loc3_]];
         }
         var _loc4_:Object = this.traits;
         for(_loc3_ = 0; _loc3_ < this.lostOnTranscension.length; _loc3_++)
         {
            this[this.lostOnTranscension[_loc3_]] = _loc2_[this.lostOnTranscension[_loc3_]];
         }
         for(_loc5_ in _loc4_)
         {
            if(this.traitTranscensionPersisting[_loc5_] == true)
            {
               this.traits[_loc5_] = _loc4_[_loc5_];
            }
         }
         if(this.extendedVariables)
         {
            this.extendedVariables.onAscend();
         }
         this.setupSkills();
         this.classStatsCached = false;
         if(this.characterDisplay)
         {
            this.characterDisplay.characterUI.removeAll();
         }
         this.totalStatPointsV2 = 0;
         this.changeWorld(1);
      }
      
      public function addGild(worldId:Number) : void
      {
         if(this.addGildHandler)
         {
            this.addGildHandler.addGildOverride(worldId);
         }
         else
         {
            this.addGildDefault(worldId);
         }
      }
      
      public function addGildDefault(worldId:Number) : void
      {
         this.timeSinceLastAncientShardPurchase = ANCIENT_SHARD_PURCHASE_COOLDOWN;
         this.timeSinceLastEtherealItemPurchase = ETHEREAL_ITEM_PURCHASE_COOLDOWN;
         this.gilds = Math.floor((worldId - 1) / this.worldsPerSystem);
         var firstWorldOfGild:Number = Math.floor((CH2.currentCharacter.highestWorldCompleted + 1) / CH2.currentCharacter.worldsPerSystem) * CH2.currentCharacter.worldsPerSystem + 1;
         this.resetGild(firstWorldOfGild);
         this.ancientShards = 0;
         this.setGildBonus(firstWorldOfGild);
         var previousGildedDamage:BigNumber = new BigNumber(0);
         previousGildedDamage.base = this.ascensionDamageMultiplier.base;
         previousGildedDamage.power = this.ascensionDamageMultiplier.power;
         var gildedDamageChange:BigNumber = this.ascensionDamageMultiplier.divide(previousGildedDamage);
         this.showCongratsPopupWhenUIIsCreated(gildedDamageChange);
      }
      
      public function setGildBonus(worldId:int) : void
      {
         this.ascensionDamageMultiplier = Formulas.instance.getWorldDifficulty(worldId).multiplyN(100);
      }
      
      public function resetGild(param1:Number) : void
      {
         var _loc4_:int = 0;
         var _loc6_:Skill = null;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:EtherealItem = null;
         var _loc2_:Number = this.statLevels[CH2.STAT_AUTOMATOR_SPEED];
         var _loc3_:Character = new Character();
         _loc3_.name = this.name;
         Characters.populateStaticFields(_loc3_);
         this.buffs.removeAllBuffs();
         for(_loc4_ = 0; _loc4_ < this.activeSkills.length; _loc4_++)
         {
            _loc6_ = this.activeSkills[_loc4_];
            _loc7_ = null;
            if(_loc6_ && _loc6_.isActive)
            {
               _loc7_ = _loc6_.slot;
               if(_loc7_ >= 0 && CH2UI.instance.mainUI)
               {
                  CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc7_].removeChild(CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc7_].skillSlotUI);
                  CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc7_].onDropRemoved(CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc7_].skillSlotUI);
               }
            }
         }
         this.deactivateAllSkills();
         for(_loc4_ = 0; _loc4_ < this.lostOnAscending.length; _loc4_++)
         {
            this[this.lostOnAscending[_loc4_]] = _loc3_[this.lostOnAscending[_loc4_]];
         }
         if(this.extendedVariables)
         {
            this.extendedVariables.onAscend();
         }
         this.setupSkills();
         this.classStatsCached = false;
         this.statLevels = {};
         this.level = param1 * 5 + 6;
         this.experience = new BigNumber(0);
         var _loc5_:BigNumber = this.getLevelUpCostToNextLevel(this.level);
         _loc5_.timesEqualsN(0.8);
         this.experience = _loc5_;
         this.statLevels[CH2.STAT_AUTOMATOR_SPEED] = _loc2_;
         this.setGildBonus(param1);
         if(this.characterDisplay)
         {
            this.characterDisplay.characterUI.removeAll();
         }
         this.totalStatPointsV2 = 6;
         for(_loc4_ = 0; _loc4_ < NUMBER_OF_ETHEREAL_ITEM_SLOTS; _loc4_++)
         {
            _loc8_ = this.equippedEtherealItems[_loc4_];
            if(_loc8_ != -1)
            {
               _loc9_ = this.etherealItemInventory[_loc8_];
               if(_loc9_ != null)
               {
                  _loc9_.grantStats(this);
               }
            }
         }
         for(_loc4_ = 0; _loc4_ < this.gildStartBuild.length; _loc4_++)
         {
            this.levelGraph.purchaseNode(this.gildStartBuild[_loc4_]);
         }
      }
      
      public function showCongratsPopupWhenUIIsCreated(gildedDamageChange:BigNumber) : void
      {
         if(CH2UI.instance.doesGameUIExist)
         {
            CH2UI.instance.showSimpleGamePopup("Congratulations!",_("You have Ascended! Your base damage has been multiplied by %s%, and your skill tree has been reset, but your Automator upgrades and the value of previously purchased stat and trait nodes remain.",CH2.game.formattedNumber(gildedDamageChange.multiplyN(100))),null,"Continue");
         }
         else
         {
            SetTimedEvent.addEvent(function():*
            {
               showCongratsPopupWhenUIIsCreated(gildedDamageChange);
            },250);
         }
      }
      
      public function playCastAnimation() : void
      {
         this.characterDisplay.playCastingLoop();
      }
      
      public function isOnHighestZoneOfHighestWorld() : Boolean
      {
         return this.isOnHighestZone && this.highestWorldCompleted < this.currentWorldId;
      }
      
      public function applyPurchasedNodes() : void
      {
         var key:* = null;
         var nodeType:Object = null;
         for(key in this.nodesPurchased)
         {
            if(this.levelGraph.nodes[key])
            {
               nodeType = this.levelGraphNodeTypes[this.levelGraph.nodes[key].type];
               if(nodeType.hasOwnProperty("loadFunction"))
               {
                  this.levelGraphNodeTypes[this.levelGraph.nodes[key].type].loadFunction();
               }
            }
         }
      }
      
      public function numNodeType(type:String) : int
      {
         var key:* = null;
         var num:int = 0;
         for(key in this.nodesPurchased)
         {
            if(this.levelGraph.nodes[key].type == type)
            {
               num++;
            }
         }
         return num;
      }
      
      public function finishWorld() : void
      {
         CH2.game.doGameStateAction(IdleHeroMain.ACTION_PLAYER_FINISHED_WORLD);
         this.onWorldFinished();
         this.onWorldChange();
      }
      
      public function isRubyShopAvailable() : Boolean
      {
         if(this.isRubyShopAvailableHandler)
         {
            return this.isRubyShopAvailableHandler.isRubyShopAvailableOverride() && !IdleHeroMain.IS_TIMELAPSE;
         }
         return this.isRubyShopAvailableDefault() && !IdleHeroMain.IS_TIMELAPSE;
      }
      
      public function isRubyShopAvailableDefault() : Boolean
      {
         return this.currentRubyShop && this.currentRubyShop.length > 0 && !CH2.world.isBossZone(this.currentZone) && !this.didFinishWorld && this.totalRubies >= 50 && !CH2.world.massiveOrangeFish.isActive;
      }
      
      public function populateRubyPurchaseOptions() : void
      {
         this.ancientShardPurchase = new RubyPurchase();
         this.ancientShardPurchase.id = "ancientShardPurchase";
         this.ancientShardPurchase.priority = 0;
         this.ancientShardPurchase.name = "Ancient Shard";
         this.ancientShardPurchase.price = 50;
         this.ancientShardPurchase.iconId = 1;
         this.ancientShardPurchase.getDescription = this.getAncientShardDescription;
         this.ancientShardPurchase.getSoldOutText = this.getDefaultSoldOutText;
         this.ancientShardPurchase.onPurchase = this.onAncientShardPurchase;
         this.ancientShardPurchase.canAppear = this.canAncientShardAppear;
         this.ancientShardPurchase.canPurchase = this.canPurchaseAncientShard;
         this.rubyPurchaseOptions.push(this.ancientShardPurchase);
         this.etherealItemPurchase = new RubyPurchase();
         this.etherealItemPurchase.id = "etherealItemPurchase";
         this.etherealItemPurchase.priority = 0;
         this.etherealItemPurchase.name = "Ethereal Item";
         this.etherealItemPurchase.price = 200;
         this.etherealItemPurchase.iconId = 9;
         this.etherealItemPurchase.getDescription = this.getEtherealItemPurchaseDescription;
         this.etherealItemPurchase.getSoldOutText = this.getDefaultSoldOutText;
         this.etherealItemPurchase.onPurchase = this.onEtherealItemPurchase;
         this.etherealItemPurchase.canAppear = this.canEtherealItemPurchaseAppear;
         this.etherealItemPurchase.canPurchase = this.canPurchaseEtherealItem;
         this.rubyPurchaseOptions.push(this.etherealItemPurchase);
         this.transcendenceMotePurchase = new RubyPurchase();
         this.transcendenceMotePurchase.id = "transcendenceMotePurchase";
         this.transcendenceMotePurchase.priority = 0;
         this.transcendenceMotePurchase.name = "Empyrean Mote";
         this.transcendenceMotePurchase.price = 1;
         this.transcendenceMotePurchase.iconId = 10;
         this.transcendenceMotePurchase.getDescription = this.getTranscendenceMoteDescription;
         this.transcendenceMotePurchase.getSoldOutText = this.getDefaultSoldOutText;
         this.transcendenceMotePurchase.onPurchase = this.onTranscendenceMotePurchase;
         this.transcendenceMotePurchase.canAppear = this.canTranscendenceMoteAppear;
         this.transcendenceMotePurchase.canPurchase = this.canPurchaseTranscendenceMote;
         this.rubyPurchaseOptions.push(this.transcendenceMotePurchase);
         if(this.populateRubyPurchaseOptionsHandler)
         {
            this.populateRubyPurchaseOptionsHandler.populateRubyPurchaseOptionsOverride();
         }
         else
         {
            this.populateRubyPurchaseOptionsDefault();
         }
      }
      
      public function populateRubyPurchaseOptionsDefault() : void
      {
         var powerRunePurchase:RubyPurchase = new RubyPurchase();
         powerRunePurchase.id = "powerRunePurchase";
         powerRunePurchase.priority = 2;
         powerRunePurchase.name = "Power Rune";
         powerRunePurchase.getDescription = this.getPowerRuneDescription;
         powerRunePurchase.getSoldOutText = this.getDefaultSoldOutText;
         powerRunePurchase.price = 100;
         powerRunePurchase.iconId = 2;
         powerRunePurchase.onPurchase = this.onPowerRunePurchase;
         powerRunePurchase.canAppear = this.canPowerRuneAppear;
         powerRunePurchase.canPurchase = this.canPurchasePowerRune;
         this.rubyPurchaseOptions.push(powerRunePurchase);
         var speedRunePurchase:RubyPurchase = new RubyPurchase();
         speedRunePurchase.id = "speedRunePurchase";
         speedRunePurchase.priority = 2;
         speedRunePurchase.name = "Speed Rune";
         speedRunePurchase.getDescription = this.getSpeedRuneDescription;
         speedRunePurchase.getSoldOutText = this.getDefaultSoldOutText;
         speedRunePurchase.price = 35;
         speedRunePurchase.iconId = 3;
         speedRunePurchase.onPurchase = this.onSpeedRunePurchase;
         speedRunePurchase.canAppear = this.canSpeedRuneAppear;
         speedRunePurchase.canPurchase = this.canPurchaseSpeedRune;
         this.rubyPurchaseOptions.push(speedRunePurchase);
         var luckRunePurchase:RubyPurchase = new RubyPurchase();
         luckRunePurchase.id = "luckRunePurchase";
         luckRunePurchase.priority = 0;
         luckRunePurchase.name = "Luck Rune";
         luckRunePurchase.getDescription = this.getLuckRuneDescription;
         luckRunePurchase.getSoldOutText = this.getDefaultSoldOutText;
         luckRunePurchase.price = 20;
         luckRunePurchase.iconId = 4;
         luckRunePurchase.onPurchase = this.onLuckRunePurchase;
         luckRunePurchase.canAppear = this.canLuckRuneAppear;
         luckRunePurchase.canPurchase = this.canPurchaseLuckRune;
         this.rubyPurchaseOptions.push(luckRunePurchase);
         var timeMetalDetector:RubyPurchase = new RubyPurchase();
         timeMetalDetector.id = "timeMetalDetector";
         timeMetalDetector.priority = 2;
         timeMetalDetector.name = "Metal Detector (Time)";
         timeMetalDetector.getDescription = this.getTimeMetalDetectorDescription;
         timeMetalDetector.getSoldOutText = this.getDefaultSoldOutText;
         timeMetalDetector.price = 15;
         timeMetalDetector.iconId = 5;
         timeMetalDetector.onPurchase = this.onTimeMetalDetectorPurchase;
         timeMetalDetector.canAppear = this.canTimeMetalDetectorAppear;
         timeMetalDetector.canPurchase = this.canPurchaseTimeMetalDetector;
         this.rubyPurchaseOptions.push(timeMetalDetector);
         var zoneMetalDetector:RubyPurchase = new RubyPurchase();
         zoneMetalDetector.id = "zoneMetalDetector";
         zoneMetalDetector.priority = 2;
         zoneMetalDetector.name = "Metal Detector (Zone)";
         zoneMetalDetector.getDescription = this.getZoneMetalDetectorDescription;
         zoneMetalDetector.getSoldOutText = this.getDefaultSoldOutText;
         zoneMetalDetector.price = 15;
         zoneMetalDetector.iconId = 5;
         zoneMetalDetector.onPurchase = this.onZoneMetalDetectorPurchase;
         zoneMetalDetector.canAppear = this.canZoneMetalDetectorAppear;
         zoneMetalDetector.canPurchase = this.canPurchaseZoneMetalDetector;
         this.rubyPurchaseOptions.push(zoneMetalDetector);
         var bagOfGold:RubyPurchase = new RubyPurchase();
         bagOfGold.id = "bagOfGold";
         bagOfGold.priority = 3;
         bagOfGold.name = "Bag of Gold";
         bagOfGold.getDescription = this.getBagOfGoldDescription;
         bagOfGold.getSoldOutText = this.getDefaultSoldOutText;
         bagOfGold.price = this.bagOfGoldPrice;
         bagOfGold.iconId = 6;
         bagOfGold.onPurchase = this.onBagOfGoldPurchase;
         bagOfGold.canAppear = this.canBagOfGoldAppear;
         bagOfGold.canPurchase = this.canPurchaseBagOfGold;
         this.rubyPurchaseOptions.push(bagOfGold);
         var magicalBrew:RubyPurchase = new RubyPurchase();
         magicalBrew.id = "magicalBrew";
         magicalBrew.priority = 3;
         magicalBrew.name = "Magical Brew";
         magicalBrew.getDescription = this.getMagicalBrewDescription;
         magicalBrew.getSoldOutText = this.getDefaultSoldOutText;
         magicalBrew.price = 2;
         magicalBrew.iconId = 7;
         magicalBrew.onPurchase = this.onMagicalBrewPurchase;
         magicalBrew.canAppear = this.canMagicalBrewAppear;
         magicalBrew.canPurchase = this.canPurchaseMagicalBrew;
         this.rubyPurchaseOptions.push(magicalBrew);
      }
      
      public function getRandomRubyPurchase(priority:int) : RubyPurchase
      {
         var rubyPurchase:RubyPurchase = null;
         var isAlreadyInShop:Boolean = false;
         var i:int = 0;
         var index:int = 0;
         var possiblePurchases:Array = [];
         for each(rubyPurchase in this.rubyPurchaseOptions)
         {
            isAlreadyInShop = false;
            for(i = 0; i < this.currentRubyShop.length; i++)
            {
               if(this.currentRubyShop[i].id == rubyPurchase.id)
               {
                  isAlreadyInShop = true;
                  break;
               }
            }
            if(rubyPurchase.priority == priority && rubyPurchase.canAppear() && !isAlreadyInShop)
            {
               possiblePurchases.push(rubyPurchase);
            }
         }
         if(possiblePurchases.length > 0)
         {
            index = this.roller.rubyShopRoller.integer(0,possiblePurchases.length - 1);
            return possiblePurchases[index];
         }
         return null;
      }
      
      public function generateRubyShop() : void
      {
         if(this.generateRubyShopHandler)
         {
            this.generateRubyShopHandler.generateRubyShopOverride();
         }
         else
         {
            this.generateRubyShopDefault();
         }
      }
      
      public function getRubyPurchaseInstance(id:String) : RubyPurchase
      {
         var rubyPurchase:RubyPurchase = null;
         for each(rubyPurchase in this.rubyPurchaseOptions)
         {
            if(rubyPurchase.id == id)
            {
               return rubyPurchase;
            }
         }
         return null;
      }
      
      public function generateRubyShopDefault() : void
      {
         var option2:RubyPurchase = null;
         var option3:RubyPurchase = null;
         var option1:RubyPurchase = null;
         this.currentRubyShop = [];
         if(this.transcendenceMotePurchase.canAppear())
         {
            this.currentRubyShop.push(this.transcendenceMotePurchase);
            this.hasUnlockedTranscendencePanel = true;
         }
         else if(this.ancientShardPurchase.canAppear())
         {
            this.currentRubyShop.push(this.ancientShardPurchase);
         }
         else if(this.etherealItemPurchase.canAppear())
         {
            this.currentRubyShop.push(this.etherealItemPurchase);
         }
         else
         {
            option1 = this.getRandomRubyPurchase(1);
            if(!option1)
            {
               option1 = this.getRandomRubyPurchase(2);
            }
            if(option1)
            {
               this.currentRubyShop.push(option1);
            }
         }
         option2 = this.getRandomRubyPurchase(2);
         if(!option2)
         {
            option2 = this.getRandomRubyPurchase(3);
         }
         if(option2)
         {
            this.currentRubyShop.push(option2);
         }
         option3 = this.getRandomRubyPurchase(3);
         if(option3)
         {
            this.currentRubyShop.push(option3);
         }
      }
      
      public function updateRubyShopFields(dt:int) : void
      {
         if(this.updateRubyShopFieldsHandler)
         {
            this.updateRubyShopFieldsHandler.updateRubyShopFieldsOverride(dt);
         }
         else
         {
            this.updateRubyShopFieldsDefault(dt);
         }
      }
      
      public function updateRubyShopFieldsDefault(dt:int) : void
      {
         this.timeSinceLastRubyShopAppearance = this.timeSinceLastRubyShopAppearance + dt;
         if(this.timeSinceLastRubyShopAppearance > RUBY_SHOP_APPEARANCE_COOLDOWN)
         {
            this.timeSinceLastRubyShopAppearance = 0;
            this.generateRubyShop();
            CH2UI.instance.rubyShopChanged = true;
         }
         this.timeSinceLastAncientShardPurchase = this.timeSinceLastAncientShardPurchase + dt;
         this.timeSinceLastAutomatorPointPurchase = this.timeSinceLastAutomatorPointPurchase + dt;
         this.timeSinceLastEtherealItemPurchase = this.timeSinceLastEtherealItemPurchase + dt;
         this.timeSinceLastTranscendenceMotePurchase = this.timeSinceLastTranscendenceMotePurchase + dt;
         this.timeSinceTimeMetalDetectorActivated = this.timeSinceTimeMetalDetectorActivated + dt;
         if(this.timeMetalDetectorActive && this.timeSinceTimeMetalDetectorActivated > METAL_DETECTOR_TIME_DURATION)
         {
            this.timeMetalDetectorActive = false;
         }
         if(this.zoneMetalDetectorActive && this.zoneOfZoneMetalDetectorActivation + METAL_DETECTOR_ZONE_DURATION < this.currentZone)
         {
            this.zoneMetalDetectorActive = false;
         }
      }
      
      public function makeRubyPurchase(rubyPurchase:RubyPurchase) : void
      {
         var rubyPurchasePrice:Number = NaN;
         var rubyPurchaseName:String = rubyPurchase.name;
         rubyPurchasePrice = rubyPurchase.price;
         if(this.rubies >= rubyPurchasePrice && rubyPurchase.canPurchase())
         {
            rubyPurchase.onPurchase();
            this.rubies = this.rubies - rubyPurchasePrice;
         }
         CH2UI.instance.mainUI.rightPanel.currentPanel.refreshAll();
      }
      
      public function getDefaultSoldOutText() : String
      {
         return _("SOLD OUT");
      }
      
      public function getPowerRuneDescription() : String
      {
         return _("Increase your damage by +%s% for the rest of the world.",POWER_RUNE_DAMAGE_BONUS * 100);
      }
      
      public function onPowerRunePurchase() : void
      {
         this.powerRuneActivated = true;
      }
      
      public function canPowerRuneAppear() : Boolean
      {
         return !this.powerRuneActivated;
      }
      
      public function canPurchasePowerRune() : Boolean
      {
         return !this.powerRuneActivated;
      }
      
      public function getSpeedRuneDescription() : String
      {
         return _("Increases your haste by +%s% for the rest of the world.",SPEED_RUNE_HASTE_BONUS * 100);
      }
      
      public function onSpeedRunePurchase() : void
      {
         this.speedRuneActivated = true;
      }
      
      public function canSpeedRuneAppear() : Boolean
      {
         return !this.speedRuneActivated && this.name != "Wizard";
      }
      
      public function canPurchaseSpeedRune() : Boolean
      {
         return !this.speedRuneActivated;
      }
      
      public function getLuckRuneDescription() : String
      {
         return _("Increases your critical chance by +%s% for the rest of the world.",LUCK_RUNE_CRITICAL_BONUS * 100);
      }
      
      public function onLuckRunePurchase() : void
      {
         this.luckRuneActivated = true;
      }
      
      public function canLuckRuneAppear() : Boolean
      {
         return !this.luckRuneActivated;
      }
      
      public function canPurchaseLuckRune() : Boolean
      {
         return !this.luckRuneActivated;
      }
      
      public function getAncientShardDescription() : String
      {
         return _("Multiply your damage by x%s while in this Star System.",ANCIENT_SHARD_DAMAGE_BONUS);
      }
      
      public function onAncientShardPurchase() : void
      {
         this.ancientShards++;
         this.timeSinceLastAncientShardPurchase = 0;
      }
      
      public function canAncientShardAppear() : Boolean
      {
         return this.timeSinceLastAncientShardPurchase > ANCIENT_SHARD_PURCHASE_COOLDOWN;
      }
      
      public function canPurchaseAncientShard() : Boolean
      {
         return this.timeSinceLastAncientShardPurchase > ANCIENT_SHARD_PURCHASE_COOLDOWN;
      }
      
      public function getEtherealItemPurchaseDescription() : String
      {
         return _("Gives you a random Ethereal Item.");
      }
      
      public function onEtherealItemPurchase() : void
      {
         this.timeSinceLastEtherealItemPurchase = 0;
         CH2UI.instance.showEtherealItemRewardPopup([this.addEtherealItemToInventory(this.rollEtherealItem(CH2.currentCharacter.currentWorld.starSystemId))]);
      }
      
      public function canEtherealItemPurchaseAppear() : Boolean
      {
         return this.timeSinceLastEtherealItemPurchase > ETHEREAL_ITEM_PURCHASE_COOLDOWN;
      }
      
      public function canPurchaseEtherealItem() : Boolean
      {
         return this.timeSinceLastEtherealItemPurchase > ETHEREAL_ITEM_PURCHASE_COOLDOWN;
      }
      
      public function getTranscendenceMoteDescription() : String
      {
         return _("Allows you to Transcend.");
      }
      
      public function onTranscendenceMotePurchase() : void
      {
         this.transcendenceMotes++;
         this.timeSinceLastTranscendenceMotePurchase = 0;
      }
      
      public function canTranscendenceMoteAppear() : Boolean
      {
         return this.timeSinceLastTranscendenceMotePurchase > this.currentTranscendenceMoteCooldown;
      }
      
      public function canPurchaseTranscendenceMote() : Boolean
      {
         return this.timeSinceLastTranscendenceMotePurchase > this.currentTranscendenceMoteCooldown;
      }
      
      public function getAutomatorPointDescription() : String
      {
         return _("Gives you 1 automator point.");
      }
      
      public function onAutomatorPointPurchase() : void
      {
         CH2.currentCharacter.automatorPoints++;
         CH2UI.instance.mainUI.mainPanel.graphPanel.levelGraphDisplay.completeRedraw();
         CH2UI.instance.mainUI.mainPanel.graphPanel.backgroundGraphDisplay.completeRedraw(true);
         this.timeSinceLastAutomatorPointPurchase = 0;
      }
      
      public function canAutomatorPointAppear() : Boolean
      {
         return this.timeSinceLastAutomatorPointPurchase > AUTOMATOR_POINT_PURCHASE_COOLDOWN;
      }
      
      public function canPurchaseAutomatorPoint() : Boolean
      {
         return this.timeSinceLastAutomatorPointPurchase > AUTOMATOR_POINT_PURCHASE_COOLDOWN;
      }
      
      public function getTimeMetalDetectorDescription() : String
      {
         return _("Increases your gold gained by +%s% for %s.",(METAL_DETECTOR_GOLD_BONUS - 1) * 100,TimeFormatter.formatTimeDescriptive(METAL_DETECTOR_TIME_DURATION / 1000).replace(" ",""));
      }
      
      public function onTimeMetalDetectorPurchase() : void
      {
         this.timeMetalDetectorActive = true;
         this.timeSinceTimeMetalDetectorActivated = 0;
      }
      
      public function canTimeMetalDetectorAppear() : Boolean
      {
         return !this.timeMetalDetectorActive;
      }
      
      public function canPurchaseTimeMetalDetector() : Boolean
      {
         return !this.timeMetalDetectorActive;
      }
      
      public function getZoneMetalDetectorDescription() : String
      {
         return _("Increases your gold gained by +%s% for %s.",(METAL_DETECTOR_GOLD_BONUS - 1) * 100,_("%s zones",METAL_DETECTOR_ZONE_DURATION));
      }
      
      public function onZoneMetalDetectorPurchase() : void
      {
         this.zoneMetalDetectorActive = true;
         this.zoneOfZoneMetalDetectorActivation = this.currentZone;
      }
      
      public function canZoneMetalDetectorAppear() : Boolean
      {
         return !this.zoneMetalDetectorActive;
      }
      
      public function canPurchaseZoneMetalDetector() : Boolean
      {
         return !this.zoneMetalDetectorActive;
      }
      
      public function getBagOfGoldDescription() : String
      {
         return _("Gain +%s Gold.",CH2.game.formattedNumber(Formulas.instance.getGoldForBagOfGold()));
      }
      
      public function onBagOfGoldPurchase() : void
      {
         var i:int = 0;
         this.bagOfGoldPrice = this.bagOfGoldPrice + 1;
         for(i = this.rubyPurchaseOptions.length - 1; i >= 0; i--)
         {
            if(this.rubyPurchaseOptions[i].id == "bagOfGold")
            {
               this.rubyPurchaseOptions[i].price = this.bagOfGoldPrice;
            }
         }
         ItemDropManager.instance.goldSplash(Formulas.instance.getGoldForBagOfGold(),this.x - 100,this.y - 250,this,"N",0.25);
      }
      
      public function canBagOfGoldAppear() : Boolean
      {
         return true;
      }
      
      public function canPurchaseBagOfGold() : Boolean
      {
         return true;
      }
      
      public function getMagicalBrewDescription() : String
      {
         return _("Gain +%s Mana.",CH2.game.formattedNumber(MAGICAL_BREW_MANA_AMOUNT));
      }
      
      public function onMagicalBrewPurchase() : void
      {
         this.addMana(MAGICAL_BREW_MANA_AMOUNT);
      }
      
      public function canMagicalBrewAppear() : Boolean
      {
         return true;
      }
      
      public function canPurchaseMagicalBrew() : Boolean
      {
         return true;
      }
      
      public function updateStats(dt:Number) : void
      {
         if(IdleHeroMain.IS_RENDERING)
         {
            this.trackedDps.update(dt);
            this.trackedOverkill.update(dt);
            this.trackedGoldGained.update(dt);
            this.trackedGoldSpent.update(dt);
            this.trackedEnergyUsed.update(dt);
            this.trackedManaUsed.update(dt);
            this.trackedFrameMsec.update(dt);
            this.trackedXPEarned.update(dt);
         }
      }
      
      public function logXPEarned(value:BigNumber) : void
      {
         this.trackedXPEarned.logValue(value);
      }
      
      public function logDamage(value:BigNumber) : void
      {
         this.trackedDps.logValue(value);
      }
      
      public function logOverkill(value:BigNumber) : void
      {
         this.trackedOverkill.logValue(value);
      }
      
      public function logGold(value:BigNumber) : void
      {
         this.trackedGoldGained.logValue(value);
      }
      
      public function logGoldSpent(value:BigNumber) : void
      {
         this.trackedGoldSpent.logValue(value);
      }
      
      public function logEnergyUsed(value:BigNumber) : void
      {
         this.trackedEnergyUsed.logValue(value);
      }
      
      public function logManaUsed(value:BigNumber) : void
      {
         this.trackedManaUsed.logValue(value);
      }
      
      public function changeWorld(worldNumber:Number) : void
      {
         var maxEnergyN:Number = NaN;
         var maxManaN:Number = NaN;
         this.inputLogger.startNewSegment();
         this.inputLogger.recordInput(GameActions.CHANGE_WORLD,worldNumber);
         CH2.user.timesAscended++;
         this.onWorldChange();
         if(this.characterDisplay)
         {
            this.characterDisplay.characterUI.removeAll();
         }
         maxEnergyN = this.maxEnergy.numberValue();
         maxManaN = this.maxMana.numberValue();
         if(this.energy > maxEnergyN)
         {
            this.energy = maxEnergyN;
         }
         if(this.mana > maxManaN)
         {
            this.mana = maxManaN;
         }
         this.startWorld(worldNumber);
         CH2.game.doGameStateAction(IdleHeroMain.ACTION_PLAYER_CLICKED_START_RUN);
         this.eventLogger.logEvent(EventLog.CHANGED_WORLD);
      }
      
      public function persist(persistThroughAscending:Boolean, persistThroughTranscension:Boolean, requiresValidation:Boolean, registerDynamicFunction:Function, ... registerDynamicArgs) : *
      {
         if(registerDynamicArgs.length == 2)
         {
            registerDynamicFunction(registerDynamicArgs[0],registerDynamicArgs[1]);
         }
         else
         {
            registerDynamicFunction(registerDynamicArgs[0]);
         }
         if(!persistThroughAscending)
         {
            this.lostOnAscending.push(registerDynamicArgs[0]);
         }
         if(!persistThroughTranscension)
         {
            this.lostOnTranscension.push(registerDynamicArgs[0]);
         }
         if(!requiresValidation)
         {
            this.skipOnValidation.push(registerDynamicArgs[0]);
         }
      }
      
      public function migrate(characterInstance:Character) : void
      {
         trace("migrating version " + characterInstance.version + " to " + IdleHeroMain.SAVE_VERSION);
         if(characterInstance.version < IdleHeroMain.SAVE_VERSION)
         {
            characterInstance.onMigration(characterInstance);
            characterInstance.version = IdleHeroMain.SAVE_VERSION;
         }
      }
      
      public function onMigration(characterInstance:Character) : void
      {
         if(this.onMigrationHandler)
         {
            this.onMigrationHandler.onMigrationOverride(characterInstance);
         }
         else
         {
            this.onMigrationDefault(characterInstance);
         }
      }
      
      public function onMigrationDefault(characterInstance:Character) : void
      {
      }
      
      public function populateTutorials() : void
      {
         var staticTutorial:Tutorial = null;
         var tutorial:Tutorial = null;
         if(this.currentTutorial != null)
         {
            this.currentTutorial.isInProgress = false;
            this.currentTutorial.onEndFunction();
            this.currentTutorial = null;
         }
         this.tutorials = [];
         for each(staticTutorial in Character.staticTutorialInstances[this.name])
         {
            if(staticTutorial.doesPlayerRequireFunction())
            {
               tutorial = new Tutorial();
               tutorial.priority = staticTutorial.priority;
               tutorial.doesPlayerRequireFunction = staticTutorial.doesPlayerRequireFunction;
               tutorial.shouldStartFunction = staticTutorial.shouldStartFunction;
               tutorial.shouldEndFunction = staticTutorial.shouldEndFunction;
               tutorial.onStartFunction = staticTutorial.onStartFunction;
               tutorial.onEndFunction = staticTutorial.onEndFunction;
               this.tutorials.push(tutorial);
            }
         }
      }
      
      public function get itemTierReachedThisWorld() : int
      {
         var item:Item = null;
         if(this.inventory.length > 0)
         {
            item = this.inventory.items[0];
            return item.tier;
         }
         return 0;
      }
      
      public function getItemDamage(item:Item) : BigNumber
      {
         if(this.getItemDamageHandler)
         {
            return this.getItemDamageHandler.getItemDamageOverride(item);
         }
         return this.getItemDamageDefault(item);
      }
      
      public function getItemDamageDefault(item:Item) : BigNumber
      {
         var result:BigNumber = null;
         var multiplier:Number = NaN;
         if(item.skills.length > 0)
         {
            return new BigNumber(0);
         }
         result = item.baseCost.multiplyN(1 / 30);
         multiplier = 1;
         if(CH2.currentAscensionWorld && CH2.currentAscensionWorld.worldNumber <= 1)
         {
            if(item.rank <= 32)
            {
               multiplier = multiplier * Math.pow(1.06,item.rank - 1);
            }
            else
            {
               multiplier = multiplier * Math.pow(1.06,31);
            }
         }
         else
         {
            multiplier = multiplier * Math.pow(0.99,item.rank - 1);
         }
         multiplier = multiplier * (1 + item.bonusDamage);
         if(item.rank < 4)
         {
            multiplier = multiplier * (5 - item.rank);
         }
         result.timesEqualsN(multiplier);
         result.floorInPlace();
         multiplier = item.level;
         multiplier = multiplier * Math.pow(this.item10LvlDmgMultiplier,Math.floor(item.level / 10));
         multiplier = multiplier * Math.pow(this.item20LvlDmgMultiplier,Math.floor(item.level / 20));
         if(item.level >= 50)
         {
            multiplier = multiplier * this.item50LvlDmgMultiplier;
            if(item.level >= 100)
            {
               multiplier = multiplier * this.item100LvlDmgMultiplier;
            }
         }
         result.timesEqualsN(multiplier);
         result.timesEquals(this.getMultiplierForItemType(item.type));
         return result;
      }
      
      public function getSystemTraitCount(worldNumber:int) : int
      {
         if(this.getSystemTraitCountHandler)
         {
            return this.getSystemTraitCountHandler.getSystemTraitCountOverride(worldNumber);
         }
         return this.getSystemTraitCountDefault(worldNumber);
      }
      
      public function getSystemTraitCountDefault(worldNumber:int) : int
      {
         return 0;
      }
      
      public function equipEtherealItem(index:int) : void
      {
         var etherealItem:EtherealItem = null;
         var slot:int = 0;
         etherealItem = this.etherealItemInventory[index];
         slot = etherealItem.slot;
         if(index != -1 && slot != -1)
         {
            if(this.equippedEtherealItems.hasOwnProperty(slot) && this.equippedEtherealItems[slot] != -1)
            {
               this.unequipEtherealItem(slot);
            }
            this.equippedEtherealItems[slot] = index;
         }
         this.classStatsCached = false;
      }
      
      public function unequipEtherealItem(slot:int) : void
      {
         var etherealItem:EtherealItem = null;
         if(slot != -1)
         {
            etherealItem = this.etherealItemInventory[this.equippedEtherealItems[slot]];
            this.equippedEtherealItems[slot] = -1;
         }
         this.classStatsCached = false;
      }
      
      public function recalculateEtherealItemStats() : void
      {
         var slot:* = null;
         var index:* = undefined;
         for(slot in this.equippedEtherealItems)
         {
            index = this.equippedEtherealItems[slot];
            if(index != -1)
            {
            }
         }
         this.classStatsCached = false;
      }
      
      public function sellEtherealItem(index:int) : void
      {
         this.removeEtherealItemFromInventory(index);
         this.rubies = this.rubies + ETHEREAL_ITEM_RUBY_SELL_PRICE;
         this.fillEmptyStorageSpaces();
      }
      
      public function populateEtherealItemStats() : void
      {
         if(this.populateEtherealItemStatsHandler)
         {
            this.etherealItemStatChoices = this.populateEtherealItemStatsHandler.populateEtherealItemStatsOverride(this);
         }
         else
         {
            this.etherealItemStatChoices = this.populateEtherealItemStatsDefault(this);
         }
      }
      
      public function populateEtherealItemStatsDefault(characterInstance:Character) : Array
      {
         this.etherealItemSpecialChoices = [];
         return this.etherealItemStatChoices;
      }
      
      public function getEtherealStatFunction(id:String) : Function
      {
         if(this.etherealItemStats[id])
         {
            return this.etherealItemStats[id].valueFunction;
         }
         return null;
      }
      
      public function getEtherealSpecialStatus(id:String) : Boolean
      {
         if(this.etherealItemStats[id])
         {
            return this.etherealItemStats[id].isSpecial;
         }
         return false;
      }
      
      public function getEtherealTooltipFormat(id:String) : String
      {
         if(this.etherealItemStats[id])
         {
            return this.etherealItemStats[id].tooltipDescriptionFormat;
         }
         return null;
      }
      
      public function getEtherealNamePrefix(id:int) : String
      {
         if(this.etherealItemStatChoices[id])
         {
            return this.etherealItemStatChoices[id].namePrefix;
         }
         return null;
      }
      
      public function getEtherealNameSuffix(id:int) : String
      {
         if(this.etherealItemStatChoices[id])
         {
            return this.etherealItemStatChoices[id].nameSuffix;
         }
         return null;
      }
      
      public function getEtherealStatParams(id:String) : Object
      {
         if(this.etherealItemStats[id])
         {
            return this.etherealItemStats[id].params;
         }
         return null;
      }
      
      public function getEtherealExchangeRateFunction(id:String) : Function
      {
         if(this.etherealItemStats[id])
         {
            return this.etherealItemStats[id].exchangeRateFunction;
         }
         return null;
      }
      
      public function placeEtherealItemInFirstOpenSpace(index:int) : Boolean
      {
         var etherealItem:EtherealItem = null;
         var slot:int = 0;
         var i:int = 0;
         etherealItem = this.etherealItemInventory[index];
         slot = etherealItem.slot;
         if(!this.equippedEtherealItems.hasOwnProperty(slot) || this.equippedEtherealItems[etherealItem.slot] == -1)
         {
            this.equipEtherealItem(index);
            return true;
         }
         for(i = 0; i < MAX_ETHEREAL_STORAGE_SIZE; i++)
         {
            if(!this.etherealItemStorage.hasOwnProperty(i) || this.etherealItemStorage[i] == -1)
            {
               this.etherealItemStorage[i] = index;
               return true;
            }
         }
         return false;
      }
      
      public function fixAnyDupedItems() : void
      {
         var foundIncidies:Array = null;
         var i:int = 0;
         foundIncidies = [];
         for(i = 0; i < MAX_ETHEREAL_STORAGE_SIZE; i++)
         {
            if(foundIncidies.indexOf(this.etherealItemStorage[i]) == -1)
            {
               foundIncidies.push(this.etherealItemStorage[i]);
            }
            else
            {
               this.etherealItemStorage[i] = -1;
            }
         }
      }
      
      public function wipeStorage() : void
      {
         var i:int = 0;
         for(i = 0; i < MAX_ETHEREAL_STORAGE_SIZE; i++)
         {
            this.etherealItemStorage[i] = -1;
         }
      }
      
      public function fillEmptyStorageSpaces() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         _loc1_ = [];
         for(_loc2_ = 0; _loc2_ < NUMBER_OF_ETHEREAL_ITEM_SLOTS; _loc2_++)
         {
            if(this.equippedEtherealItems[_loc2_] != -1)
            {
               _loc1_.push(this.equippedEtherealItems[_loc2_]);
            }
         }
         for(_loc2_ = 0; _loc2_ < MAX_ETHEREAL_STORAGE_SIZE; _loc2_++)
         {
            if(_loc1_.indexOf(this.etherealItemStorage[_loc2_]) == -1)
            {
               _loc1_.push(this.etherealItemStorage[_loc2_]);
            }
         }
         for(_loc2_ = 0; _loc2_ < this.etherealItemInventory.length; _loc2_++)
         {
            if(_loc1_.indexOf(_loc2_) == -1)
            {
               this.placeEtherealItemInFirstOpenSpace(_loc2_);
               _loc1_.push(_loc2_);
            }
         }
      }
      
      public function addEtherealItemToInventory(etherealItem:EtherealItem) : int
      {
         var index:int = 0;
         if(etherealItem)
         {
            index = this.etherealItemInventory.push(etherealItem) - 1;
            this.placeEtherealItemInFirstOpenSpace(index);
            return index;
         }
         return null;
      }
      
      public function removeEtherealItemFromInventory(param1:int) : void
      {
         var _loc2_:int = 0;
         for(_loc2_ = 0; _loc2_ < NUMBER_OF_ETHEREAL_ITEM_SLOTS; _loc2_++)
         {
            if(this.equippedEtherealItems[_loc2_] == param1)
            {
               this.unequipEtherealItem(_loc2_);
            }
            if(this.pendingEtherealEquipmentChanges[_loc2_] == param1)
            {
               this.pendingEtherealEquipmentChanges[_loc2_] = -1;
            }
         }
         for(_loc2_ = 0; _loc2_ < MAX_ETHEREAL_STORAGE_SIZE; _loc2_++)
         {
            if(this.etherealItemStorage[_loc2_] == param1)
            {
               this.etherealItemStorage[_loc2_] = -1;
            }
         }
         for(_loc2_ = 0; _loc2_ < MAX_ETHEREAL_STORAGE_SIZE; _loc2_++)
         {
            if(this.etherealItemStorage[_loc2_] != -1 && this.etherealItemStorage[_loc2_] > param1)
            {
               this.etherealItemStorage[_loc2_]--;
            }
         }
         for(_loc2_ = 0; _loc2_ < NUMBER_OF_ETHEREAL_ITEM_SLOTS; _loc2_++)
         {
            if(this.equippedEtherealItems[_loc2_] > param1)
            {
               this.equippedEtherealItems[_loc2_]--;
            }
            if(this.pendingEtherealEquipmentChanges[_loc2_] > param1)
            {
               this.pendingEtherealEquipmentChanges[_loc2_]--;
            }
         }
         this.etherealItemInventory.splice(param1,1);
      }
      
      public function rollEtherealItem(systemNumber:int, fixedSlot:int = -1) : EtherealItem
      {
         var statChosen:int = 0;
         var slot:int = 0;
         var etherealItem:EtherealItem = null;
         statChosen = this.chooseEtherealItemStat(this.etherealItemStatChoices);
         slot = -1;
         if(statChosen > -1)
         {
            if(fixedSlot != -1)
            {
               slot = fixedSlot;
            }
            else
            {
               slot = this.roller.etherealItemsRoller.integer(0,7);
            }
            etherealItem = new EtherealItem();
            etherealItem.create(slot,this.getEtherealItemRarity(systemNumber),statChosen,systemNumber,slot + 1);
            return etherealItem;
         }
         return null;
      }
      
      public function makeEtherealItemStat(choice:EtherealItemStatChoice, gildNumber:int) : EtherealItemStat
      {
         var etherealItemStat:EtherealItemStat = null;
         etherealItemStat = new EtherealItemStat();
         etherealItemStat.create(choice.id,choice.key,gildNumber);
         etherealItemStat.calculateExchangeRate(this);
         return etherealItemStat;
      }
      
      public function chooseEtherealItemStat(param1:Array) : int
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         _loc2_ = 0;
         for(_loc3_ = 0; _loc3_ < param1.length; _loc3_++)
         {
            _loc2_ = _loc2_ + param1[_loc3_].weight;
         }
         _loc4_ = this.roller.etherealItemsRoller.randFloat() * _loc2_;
         _loc5_ = -1;
         _loc6_ = 0;
         for(_loc3_ = 0; _loc3_ < param1.length; _loc3_++)
         {
            _loc7_ = param1[_loc3_].weight;
            if(_loc4_ > _loc6_ && _loc4_ < _loc6_ + _loc7_)
            {
               _loc5_ = _loc3_;
               break;
            }
            _loc6_ = _loc6_ + _loc7_;
         }
         if(_loc5_ != -1 && param1[_loc5_])
         {
            return _loc5_;
         }
         return -1;
      }
      
      public function equipPendingEtherealItems() : void
      {
         var i:int = 0;
         var previousEquippedItem:int = 0;
         var j:int = 0;
         for(i = 0; i < NUMBER_OF_ETHEREAL_ITEM_SLOTS; i++)
         {
            if(this.pendingEtherealEquipmentChanges[i] != -1)
            {
               previousEquippedItem = this.equippedEtherealItems[i];
               this.equipEtherealItem(this.pendingEtherealEquipmentChanges[i]);
               for(j = 0; j < MAX_ETHEREAL_STORAGE_SIZE; j++)
               {
                  if(this.etherealItemStorage[j] == this.pendingEtherealEquipmentChanges[i])
                  {
                     this.etherealItemStorage[j] = previousEquippedItem;
                     break;
                  }
               }
               this.pendingEtherealEquipmentChanges[i] = -1;
            }
         }
      }
      
      public function getEtherealItemRarity(gildNumber:int) : int
      {
         return Math.min(Math.floor(gildNumber / 5) + 2,8);
      }
      
      public function getStarSystem(systemId:Number) : StarSystem
      {
         var newStarSystem:StarSystem = null;
         if(!this.starSystems[systemId])
         {
            newStarSystem = new StarSystem();
            newStarSystem.systemNumber = systemId;
            newStarSystem.init();
            this.starSystems[systemId] = newStarSystem;
         }
         return this.starSystems[systemId];
      }
      
      public function levelNode(nodeId:int) : void
      {
         var nodeType:Object = null;
         var costFunction:Function = null;
         var cost:BigNumber = null;
         nodeType = CH2.currentCharacter.levelGraphNodeTypes[CH2.currentCharacter.levelGraph.nodes[nodeId].type];
         if(nodeType.hasOwnProperty("upgradeable") && nodeType["upgradeable"])
         {
            if(!CH2.currentCharacter.nodeLevels[nodeId])
            {
               CH2.currentCharacter.nodeLevels[nodeId] = 1;
            }
            costFunction = nodeType["upgradeCostFunction"];
            cost = costFunction(CH2.currentCharacter.nodeLevels[nodeId]);
            if(CH2.currentCharacter.heroSouls.gte(cost))
            {
               CH2.currentCharacter.nodeLevels[nodeId] = CH2.currentCharacter.nodeLevels[nodeId] + 1;
               CH2.currentCharacter.heroSouls.minusEquals(cost);
            }
         }
      }
      
      public function refundAndResetNodeId(nodeType:String) : void
      {
         var nodeId:int = 0;
         var i:int = 0;
         var nodeTypeObject:Object = null;
         var cost:BigNumber = null;
         for(i = 1; i < CH2.currentCharacter.levelGraph.nodes.length - 1; i++)
         {
            if(CH2.currentCharacter.levelGraph.nodes[i].type == nodeType)
            {
               nodeId = CH2.currentCharacter.levelGraph.nodes[i].id;
               break;
            }
         }
         nodeTypeObject = CH2.currentCharacter.levelGraphNodeTypes[nodeType];
         var costFunction:Function = nodeTypeObject["upgradeCostFunction"];
         while(CH2.currentCharacter.nodeLevels[nodeId] > 1)
         {
            CH2.currentCharacter.nodeLevels[nodeId]--;
            cost = costFunction(CH2.currentCharacter.nodeLevels[nodeId]);
            CH2.currentCharacter.heroSouls.plusEquals(cost);
         }
      }
   }
}
