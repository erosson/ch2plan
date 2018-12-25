package models
{
   import com.doogog.utils.MiscUtils;
   import com.gskinner.utils.Rnd;
   import com.playsaurus.model.Model;
   import com.playsaurus.numbers.BigNumber;
   import com.playsaurus.utils.ServerTimeKeeper;
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
   import lib.managers.TextManager;
   import ui.CH2UI;
   
   public class Character extends Model
   {
      
      public static const GILD_PERSISTING_TRUE:Boolean = true;
      
      public static const GILD_PERSISTING_FALSE:Boolean = false;
      
      public static const GILD_DAMAGE_INCREASE:Number = 218750000;
      
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
      
      public static const ANCIENT_SHARD_DAMAGE_BONUS:Number = 2;
      
      public static const ANCIENT_SHARD_PURCHASE_COOLDOWN:int = 84600000;
      
      public static const AUTOMATOR_POINT_PURCHASE_COOLDOWN:int = 14400000;
      
      public static const POWER_RUNE_DAMAGE_BONUS:Number = 1;
      
      public static const SPEED_RUNE_HASTE_BONUS:Number = 0.1;
      
      public static const LUCK_RUNE_CRITICAL_BONUS:Number = 0.05;
      
      public static const METAL_DETECTOR_GOLD_BONUS:Number = 2;
      
      public static const METAL_DETECTOR_TIME_DURATION:Number = 1200000;
      
      public static const METAL_DETECTOR_ZONE_DURATION:Number = 5;
      
      public static const MAGICAL_BREW_MANA_AMOUNT:Number = 10;
      
      public static const DEFAULT_UPGRADEABLE_STATS:Array = [CH2.STAT_GOLD,CH2.STAT_MOVEMENT_SPEED,CH2.STAT_CRIT_CHANCE,CH2.STAT_CRIT_DAMAGE,CH2.STAT_HASTE,CH2.STAT_MANA_REGEN,CH2.STAT_IDLE_DAMAGE,CH2.STAT_CLICKABLE_GOLD,CH2.STAT_CLICK_DAMAGE,CH2.STAT_TREASURE_CHEST_CHANCE,CH2.STAT_MONSTER_GOLD,CH2.STAT_ITEM_COST_REDUCTION,CH2.STAT_TOTAL_MANA,CH2.STAT_TOTAL_ENERGY,CH2.STAT_CLICKABLE_CHANCE,CH2.STAT_BONUS_GOLD_CHANCE,CH2.STAT_TREASURE_CHEST_GOLD,CH2.STAT_PIERCE_CHANCE,CH2.STAT_ITEM_WEAPON_DAMAGE,CH2.STAT_ITEM_HEAD_DAMAGE,CH2.STAT_ITEM_CHEST_DAMAGE,CH2.STAT_ITEM_RING_DAMAGE,CH2.STAT_ITEM_LEGS_DAMAGE,CH2.STAT_ITEM_HANDS_DAMAGE,CH2.STAT_ITEM_FEET_DAMAGE,CH2.STAT_ITEM_BACK_DAMAGE];
      
      public static const VALUES_RESET_AT_ASCENSION:Array = ["state","timeSinceLastClickAttack","timeSinceLastSkill","timeSinceLastAutoAttack","consecutiveOneShottedMonsters","gold","mana","energy","gcdRemaining","castTimeRemaining","castTime","skillBeingCast","buffs","inventory","currentCatalogRank","catalogItemsForSale","isPurchasingLocked","currentZone","highestZone","totalRunDistance","totalGold","monstersKilled","monstersKilledPerZone","powerRuneActivated","speedRuneActivated","luckRuneActivated","timeMetalDetectorActive","zoneMetalDetectorActive","zoneStartGold"];
      
      public static var staticTutorialInstances:Object = {};
      
      public static var staticSkillInstances:Object = {};
      
      public static var staticFields:Array = ["flavorName","flavorClass","flavor","gender","flair","characterSelectOrder","availableForCreation","visibleOnCharacterSelect","defaultSaveName","startingSkills","levelCostScaling","upgradeableStats","assetGroupName","damageMultiplierBase","maxManaMultiplierBase","maxEnergyMultiplierBase","attackMsDelay","gcdBase","autoAttackDamageMultiplierBase","damageMultiplierValueFunction","maxManaMultiplierValueFunction","maxEnergyMultiplierValueFunction","damageMultiplierCostFunction","maxManaMultiplierCostFunction","maxEnergyMultiplierCostFunction","statValueFunctions","statBaseValues","statCostFunctions","monstersPerZone","monsterHealthMultiplier","attackRange","levelGraph","levelGraphNodeTypes"];
       
      
      public var isMouseOverClickableActivationUnlocked:Boolean = false;
      
      public var numUserInputActions:Number;
      
      public var sidePanelIsVisible:Boolean;
      
      public var modDependencies:Object;
      
      public var version:Number = 0;
      
      public var state:int = 5;
      
      public var monstersPerZone:Number = 50;
      
      public var worldsPerGild:Number = 30;
      
      public var monsterHealthMultiplier:Number = 1;
      
      public var attackRange:int = 90;
      
      public var isAbleToCollectGoldDrops:Boolean = true;
      
      public var doesAttractCoins:Boolean = true;
      
      public var unarmedDamage:BigNumber;
      
      public var timeSinceLastClickAttack:Number = 0;
      
      public var timeSinceLastSkill:Number = 0;
      
      public var timeSinceLastAutoAttack:Number = 0;
      
      public var autoAttacksNotInterrupted:Boolean = false;
      
      public var consecutiveOneShottedMonsters:Number = 0;
      
      public var clickAttackEnergyCost:int = 1;
      
      public var heroId:int = 1;
      
      public var name:String;
      
      public var creationTime:Number;
      
      public var gender:String;
      
      public var flair:String;
      
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
      
      public var timeSinceLastAncientShardPurchase:int = 84600000;
      
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
      
      public var buffs:Buffs;
      
      public var inventory:Items;
      
      public var shouldLevelToNextMultiplier:Boolean = false;
      
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
      
      public var hasSeenMainPanel:Boolean = false;
      
      public var hasSeenItemsPanel:Boolean = false;
      
      public var hasSeenGraphPanel:Boolean = false;
      
      public var hasSeenSkillsPanel:Boolean = false;
      
      public var hasSeenAutomatorPanel:Boolean = false;
      
      public var hasSeenWorldsPanel:Boolean = false;
      
      public var hasSeenMiscPanel:Boolean = false;
      
      public var hasReceivedFirstTimeEnergy:Boolean = false;
      
      public var hasSeenRubyShopPanel:Boolean = false;
      
      public var onlineTimeAsOfLastRubyShopMilliseconds:Number;
      
      public var hasNewSkillTreePointsAvailable:Boolean = false;
      
      public var hasNewSkillAvailable:Boolean = false;
      
      public var totalRubies:Number = 0;
      
      public var isItemPanelUnlockedHandler:Object = null;
      
      public var isGraphPanelUnlockedHandler:Object = null;
      
      public var isSkillPanelUnlockedHandler:Object = null;
      
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
      
      public var automatorPoints:int = 0;
      
      public var totalExperience:BigNumber;
      
      public var experienceAtRunStart:BigNumber;
      
      public var experienceForCurrentWorld:BigNumber;
      
      public var experience:BigNumber;
      
      public var highestWorldCompleted:Number = 0;
      
      public var fastestWorldTimes:Object;
      
      public var runsCompletedPerWorld:Object;
      
      public var highestMonstersKilled:Object;
      
      public var statLevels:Object;
      
      public var isLocked:Boolean = true;
      
      public var spentStatPoints:BigNumber;
      
      public var gilds:int = 0;
      
      public var gildedDamageMultiplier:BigNumber;
      
      public var hasNeverStartedWorld:Boolean = true;
      
      public var lostOnGilding:Array;
      
      public var isViewingAutomatorTree:Boolean = false;
      
      public var skillTreeViewX:Number = 0;
      
      public var skillTreeViewY:Number = 0;
      
      public var automatorTreeViewX:Number = 15741;
      
      public var automatorTreeViewY:Number = -125;
      
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
      
      public var statCostFunctions:Array;
      
      public var statBaseValues:Array;
      
      public var levelGraphObject:Object;
      
      public var levelGraph:LevelGraph;
      
      public var levelGraphNodeTypes:Object;
      
      public var nodesPurchased:Object;
      
      public var undoNodes:Object;
      
      public var traits:Object;
      
      public var characterDisplay:CharacterDisplay;
      
      public var worldEntity:WorldEntity;
      
      public var x:Number;
      
      public var y:Number;
      
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
      
      public var onAscensionHandler:Object = null;
      
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
      
      public var getLevelUpCostToNextLevelHandler:Object = null;
      
      public var addGildHandler:Object = null;
      
      public var highestDamageExponent:Number = 0;
      
      public var shouldRubyShopActivateHandler:Object = null;
      
      public var shouldRubyShopDeactivateHandler:Object = null;
      
      public var populateRubyPurchaseOptionsHandler:Object = null;
      
      public var generateRubyShopHandler:Object = null;
      
      public var updateRubyShopFieldsHandler:Object = null;
      
      public var onMigrationHandler:Object = null;
      
      public var getItemDamageHandler:Object = null;
      
      public function Character()
      {
         this.modDependencies = {};
         this.unarmedDamage = new BigNumber(1);
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
         this.buffs = new Buffs();
         this.inventory = new Items();
         this.catalogItemsForSale = [];
         this.automator = new Automator();
         this.worldEndAutomationOptions = [];
         this.tutorials = [];
         this.totalGold = new BigNumber(0);
         this.monstersKilledPerZone = {};
         this.skills = {};
         this.activeSkills = [];
         this.totalExperience = new BigNumber(0);
         this.experienceAtRunStart = new BigNumber(0);
         this.experienceForCurrentWorld = new BigNumber(0);
         this.experience = new BigNumber(0);
         this.fastestWorldTimes = {};
         this.runsCompletedPerWorld = {};
         this.highestMonstersKilled = {};
         this.statLevels = {};
         this.spentStatPoints = new BigNumber(0);
         this.gildedDamageMultiplier = new BigNumber(1);
         this.lostOnGilding = [];
         this.statValueFunctions = new Array();
         this.statCostFunctions = new Array();
         this.statBaseValues = new Array();
         this.nodesPurchased = {};
         this.undoNodes = {};
         this.traits = {};
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
         this.persist(GILD_PERSISTING_TRUE,registerDynamicObject,"modDependencies");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"version");
         this.persist(GILD_PERSISTING_FALSE,registerDynamicBigNumber,"unarmedDamage");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicChild,"worlds",AscensionWorlds);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicString,"name");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicChild,"roller",Roller);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"startingRollerValue");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicChild,"trackedDps",TrackedStat);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicChild,"trackedOverkill",TrackedStat);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicChild,"trackedGoldGained",TrackedStat);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicChild,"trackedGoldSpent",TrackedStat);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicChild,"trackedEnergyUsed",TrackedStat);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicChild,"trackedManaUsed",TrackedStat);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicChild,"trackedFrameMsec",TrackedStat);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicChild,"trackedXPEarned",TrackedStat);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBigNumber,"gold");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBigNumber,"zoneStartGold");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"rubies");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"energy");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"mana");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"totalRubies");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicChild,"inventory",Items);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicChild,"automator",Automator);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"currentWorldEndAutomationOption");
         this.persist(GILD_PERSISTING_FALSE,registerDynamicCollection,"skills",Skill);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"currentCatalogRank");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicCollection,"catalogItemsForSale",Item);
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"onlineTimeAsOfLastRubyShopMilliseconds");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeOfLastRun");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeOfLastAscension");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeCharacterWasUnlocked");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeOnlineMilliseconds");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeOfflineMilliseconds");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeOfflineMilliseconds");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"serverTimeOfLastUpdate");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"creationTime");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeOfLastOutOfEnergy");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeOfLastLevelUp");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeOfLastItemUpgrade");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeOfLastCatalogPurchase");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeSinceLastRubyShopAppearance");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeSinceLastAncientShardPurchase");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeSinceLastAutomatorPointPurchase");
         this.persist(GILD_PERSISTING_FALSE,registerDynamicNumber,"ancientShards");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"powerRuneActivated");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"speedRuneActivated");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"luckRuneActivated");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"timeMetalDetectorActive");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeSinceTimeMetalDetectorActivated");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"zoneMetalDetectorActive");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"zoneOfZoneMetalDetectorActivation");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicObject,"zoneToShowPerWorld");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicObject,"hasActivatedMassiveOrangeFish");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"didFinishWorld");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"currentZone");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"highestZone");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"totalRunDistance");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBigNumber,"totalGold");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"highestItemTierSeen");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"monstersKilled");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"totalUpgradesToItems");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"totalCatalogItemsPurchased");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"totalOneShotMonsters");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"totalSkillsUsed");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"consecutiveOneShottedMonsters");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"currentWorldId");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"attemptsOnCurrrentBoss");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeSinceRegularMonsterHasDroppedRubies");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"timeSinceLastOrangeFishAppearance");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasPurchasedFirstSkill");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasUnlockedAutomator");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasSeenMainPanel");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasSeenItemsPanel");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasSeenGraphPanel");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasSeenSkillsPanel");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasSeenAutomatorPanel");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasSeenWorldsPanel");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasSeenMiscPanel");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasReceivedFirstTimeEnergy");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasSeenRubyShopPanel");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasNewSkillTreePointsAvailable");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicString,"name");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"level");
         this.persist(GILD_PERSISTING_FALSE,registerDynamicNumber,"totalStatPointsV2");
         this.persist(GILD_PERSISTING_FALSE,registerDynamicNumber,"automatorPoints");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"didConvertTotalStatPointsToV2ThisIsStupid");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBigNumber,"experience");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBigNumber,"totalExperience");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBigNumber,"experienceForCurrentWorld");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBigNumber,"experienceAtRunStart");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"highestWorldCompleted");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicObject,"fastestWorldTimes");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicObject,"highestMonstersKilled");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicObject,"runsCompletedPerWorld");
         this.persist(GILD_PERSISTING_FALSE,registerDynamicObject,"statLevels");
         this.persist(GILD_PERSISTING_FALSE,registerDynamicNumber,"gcdMinimum");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"isLocked");
         this.persist(GILD_PERSISTING_FALSE,registerDynamicBigNumber,"spentStatPoints");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicNumber,"gilds");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBigNumber,"gildedDamageMultiplier");
         this.persist(GILD_PERSISTING_FALSE,registerDynamicObject,"nodesPurchased");
         this.persist(GILD_PERSISTING_FALSE,registerDynamicObject,"undoNodes");
         this.persist(GILD_PERSISTING_FALSE,registerDynamicObject,"traits");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicObject,"monstersKilledPerZone");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasNeverStartedWorld");
         this.persist(GILD_PERSISTING_FALSE,registerDynamicBoolean,"autoAttacksNotInterrupted");
         this.persist(GILD_PERSISTING_TRUE,registerDynamicBoolean,"hasEditedSave");
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
         this.statBaseValues[CH2.STAT_CRIT_DAMAGE] = 3;
         this.statBaseValues[CH2.STAT_CRIT_CHANCE] = 0.05;
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
         this.statBaseValues[CH2.STAT_TREASURE_CHEST_CHANCE] = 0.02;
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
         this.statValueFunctions[CH2.STAT_IDLE_GOLD] = exponentialMultiplier(1.25);
         this.statValueFunctions[CH2.STAT_HASTE] = exponentialMultiplier(1.05);
         this.statValueFunctions[CH2.STAT_GOLD] = exponentialMultiplier(1.1);
         this.statValueFunctions[CH2.STAT_CRIT_DAMAGE] = exponentialMultiplier(1.2);
         this.statValueFunctions[CH2.STAT_CRIT_CHANCE] = linear(0.02);
         this.statValueFunctions[CH2.STAT_TOTAL_ENERGY] = linear(25);
         this.statValueFunctions[CH2.STAT_TOTAL_MANA] = linear(25);
         this.statValueFunctions[CH2.STAT_BONUS_GOLD_CHANCE] = linear(0.01);
         this.statValueFunctions[CH2.STAT_ITEM_COST_REDUCTION] = exponentialMultiplier(0.92);
         this.statValueFunctions[CH2.STAT_CLICK_DAMAGE] = exponentialMultiplier(1.1);
         this.statValueFunctions[CH2.STAT_IDLE_DAMAGE] = exponentialMultiplier(1.25);
         this.statValueFunctions[CH2.STAT_MOVEMENT_SPEED] = exponentialMultiplier(1.05);
         this.statValueFunctions[CH2.STAT_PIERCE_CHANCE] = linear(0.01);
         this.statValueFunctions[CH2.STAT_MANA_REGEN] = exponentialMultiplier(1.1);
         this.statValueFunctions[CH2.STAT_CLICKABLE_GOLD] = exponentialMultiplier(1.5);
         this.statValueFunctions[CH2.STAT_TREASURE_CHEST_CHANCE] = linear(0.02);
         this.statValueFunctions[CH2.STAT_TREASURE_CHEST_GOLD] = exponentialMultiplier(1.25);
         this.statValueFunctions[CH2.STAT_MONSTER_GOLD] = exponentialMultiplier(1.12);
         this.statValueFunctions[CH2.STAT_CLICKABLE_CHANCE] = linear(0.1);
         this.statValueFunctions[CH2.STAT_ENERGY_REGEN] = linear(0);
         this.statValueFunctions[CH2.STAT_DAMAGE] = exponentialMultiplier(1.5);
         this.statValueFunctions[CH2.STAT_ENERGY_COST_REDUCTION] = linear(0);
         this.statValueFunctions[CH2.STAT_ITEM_WEAPON_DAMAGE] = exponentialMultiplier(1.5);
         this.statValueFunctions[CH2.STAT_ITEM_HEAD_DAMAGE] = exponentialMultiplier(1.5);
         this.statValueFunctions[CH2.STAT_ITEM_CHEST_DAMAGE] = exponentialMultiplier(1.5);
         this.statValueFunctions[CH2.STAT_ITEM_RING_DAMAGE] = exponentialMultiplier(1.5);
         this.statValueFunctions[CH2.STAT_ITEM_LEGS_DAMAGE] = exponentialMultiplier(1.5);
         this.statValueFunctions[CH2.STAT_ITEM_HANDS_DAMAGE] = exponentialMultiplier(1.5);
         this.statValueFunctions[CH2.STAT_ITEM_FEET_DAMAGE] = exponentialMultiplier(1.5);
         this.statValueFunctions[CH2.STAT_ITEM_BACK_DAMAGE] = exponentialMultiplier(1.5);
         this.statValueFunctions[CH2.STAT_AUTOMATOR_SPEED] = exponentialMultiplier(1.25);
         this.statCostFunctions[CH2.STAT_IDLE_GOLD] = linear(1,4);
         this.statCostFunctions[CH2.STAT_HASTE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_GOLD] = linear(1,4);
         this.statCostFunctions[CH2.STAT_CRIT_DAMAGE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_CRIT_CHANCE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_TOTAL_ENERGY] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_TOTAL_MANA] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_BONUS_GOLD_CHANCE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_ITEM_COST_REDUCTION] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_CLICK_DAMAGE] = linear(1,4);
         this.statCostFunctions[CH2.STAT_IDLE_DAMAGE] = linear(1,4);
         this.statCostFunctions[CH2.STAT_MOVEMENT_SPEED] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_PIERCE_CHANCE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_MANA_REGEN] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_CLICKABLE_GOLD] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_TREASURE_CHEST_CHANCE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_TREASURE_CHEST_GOLD] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_MONSTER_GOLD] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_CLICKABLE_CHANCE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_ENERGY_REGEN] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_DAMAGE] = linear(1);
         this.statCostFunctions[CH2.STAT_ENERGY_COST_REDUCTION] = linear(1);
         this.statCostFunctions[CH2.STAT_ITEM_WEAPON_DAMAGE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_ITEM_HEAD_DAMAGE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_ITEM_CHEST_DAMAGE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_ITEM_RING_DAMAGE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_ITEM_LEGS_DAMAGE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_ITEM_HANDS_DAMAGE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_ITEM_FEET_DAMAGE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_ITEM_BACK_DAMAGE] = exponential(1.25);
         this.statCostFunctions[CH2.STAT_AUTOMATOR_SPEED] = exponential(1.25);
      }
      
      public static function linear(scale:Number, base:Number = 0) : Function
      {
         return function(statLevel:Number):Number
         {
            return base + scale * statLevel;
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
         return function(statLevel:Number):Number
         {
            if(!statLevel || statLevel == 0)
            {
               return 1;
            }
            return Math.pow(base,statLevel);
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
         return this.availableStatPoints.gtN(0);
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
            this.inputLogger = new InputLog();
         }
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
      
      public function getTrait(trait:String) : Number
      {
         if(this.traits.hasOwnProperty(trait))
         {
            return this.traits[trait];
         }
         this.traits[trait] = 0;
         return 0;
      }
      
      public function setTrait(trait:String, value:Number) : void
      {
         this.traits[trait] = value;
      }
      
      public function addTrait(trait:String, value:Number) : void
      {
         this.traits[trait] = this.getTrait(trait) + value;
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
         this.onWorldStarted(worldNumber);
         this.generateCatalog();
         this.didFinishWorld = false;
         if(!this.highestMonstersKilled.hasOwnProperty(worldNumber))
         {
            this.highestMonstersKilled[worldNumber] = 0;
         }
         if(!this.zoneToShowPerWorld.hasOwnProperty(worldNumber))
         {
            worldIsInLastFiveOfGild = (this.currentWorldId - 1) % this.worldsPerGild >= this.worldsPerGild - 4;
            chanceToShowInWorld = !!worldIsInLastFiveOfGild?Number(0.25):Number(0.1);
            willShowInCurrentWorld = CH2.roller.worldRoller.boolean(chanceToShowInWorld);
            if(willShowInCurrentWorld)
            {
               this.zoneToShowPerWorld[worldNumber] = CH2.roller.worldRoller.integer(35,90);
            }
            else
            {
               this.zoneToShowPerWorld[worldNumber] = 101;
            }
            this.hasActivatedMassiveOrangeFish[worldNumber] = false;
         }
         MusicManager.instance.shufflePlaylists();
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
         var expectedNumGilds:int = Math.floor((this.currentWorldId - 1) / this.worldsPerGild);
         if(this.gilds < expectedNumGilds)
         {
            this.drainWorldsUpTo(this.currentWorldId - 1);
            this.addGild(this.currentWorldId);
         }
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
         this.gcdRemaining = this.gcd;
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
      
      public function onWorldEndRerunCurrentWorld() : void
      {
         this.ascend(this.currentWorldId);
      }
      
      public function isRerunCurrentWorldOnWorldEndUnlocked() : Boolean
      {
         return this.highestWorldCompleted >= WORLD_END_AUTOMATION_OPTIONS_UNLOCK_WORLD;
      }
      
      public function onWorldEndAttemptNextWorld() : void
      {
         this.ascend(this.currentWorldId + 1);
      }
      
      public function isAttemptNextWorldOnWorldEndUnlocked() : Boolean
      {
         return this.highestWorldCompleted >= WORLD_END_AUTOMATION_OPTIONS_UNLOCK_WORLD;
      }
      
      public function onWorldEndAttemptHighestWorld() : void
      {
         this.ascend(this.highestWorldCompleted + 1);
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
         this.timeSinceLastRubyShopAppearance = this.timeSinceLastRubyShopAppearance + dt;
         this.timeSinceRegularMonsterHasDroppedRubies = this.timeSinceRegularMonsterHasDroppedRubies + dt;
         this.timeSinceLastOrangeFishAppearance = this.timeSinceLastOrangeFishAppearance + dt;
         this.serverTimeOfLastUpdate = ServerTimeKeeper.instance.timestamp;
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
         this.cooldownSkills(dt);
         this.gcdRemaining = this.gcdRemaining - dt;
         if(IdleHeroMain.IS_RENDERING)
         {
            this.characterDisplay.update(dt);
         }
         this.automator.executeAutomatorQueue(dt);
         var lockedState:int = this.state;
         switch(lockedState)
         {
            case STATE_PAUSED:
               if(CH2.world.isBossZone && !this.isNextMonsterInRange && CH2.world.getNextMonster() != null)
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
         this.buffs.updateBuffs(dt);
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
         var i:int = 0;
         var attackRange:Number = NaN;
         var monstersAttacked:Array = [];
         var attackDatas:Array = [];
         attackData.isPierce = CH2.roller.attackRoller.boolean(this.pierceChance);
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
            attackDatas[i].isCritical = CH2.roller.attackRoller.boolean(this.criticalChance);
            if(attackDatas[i].isCritical)
            {
               attackData.isCritical = true;
            }
            attackDatas[i].monster = monstersAttacked[i];
            if(attackDatas[i].isCritical)
            {
               attackDatas[i].damage = attackDatas[i].damage.multiplyN(this.criticalDamageMultiplier);
            }
         }
         this.buffs.onAttack(attackDatas);
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
         this.addEnergy(this.energyRegeneration,false);
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
         if(CH2.user.isProgressionModeActive && !CH2.user.isOnBossZone && this.hasCompletedCurrentZone() && !CH2.user.isOnFinalBossZone)
         {
            this.eventLogger.logEvent(EventLog.BEAT_ZONE);
            CH2.world.moveToNextZone(false);
         }
         else if(!this.isNextMonsterInRange)
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
            return skill.energyCost * (1 - this.energyCostReduction);
         }
         return this.maxEnergy;
      }
      
      public function onAscension() : void
      {
         if(this.onAscensionHandler)
         {
            this.onAscensionHandler.onAscensionOverride();
         }
         else
         {
            this.onAscensionDefault();
         }
      }
      
      public function onAscensionDefault() : void
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
         var dmg:BigNumber = this.inventory.getEquippedDamage().add(this.unarmedDamage);
         dmg.timesEqualsN(this.ancientShardDamageMultiplier);
         dmg.timesEqualsN(1 + (!!this.powerRuneActivated?POWER_RUNE_DAMAGE_BONUS:0));
         dmg.timesEqualsN(this.damageMultiplier);
         dmg.timesEquals(this.gildedDamageMultiplier);
         if(this.isIdle)
         {
            dmg.timesEqualsN(this.idleDamageMultiplier);
         }
         dmg.floorInPlace();
         dmg.atLeastOne();
         return dmg;
      }
      
      public function get characterDamageMultipliers() : BigNumber
      {
         var multiplier:BigNumber = this.gildedDamageMultiplier.multiplyN(1 + (!!this.powerRuneActivated?POWER_RUNE_DAMAGE_BONUS:0)).multiplyN(this.damageMultiplier).multiplyN(this.ancientShardDamageMultiplier);
         if(this.isIdle)
         {
            multiplier.timesEqualsN(this.idleDamageMultiplier);
         }
         return multiplier;
      }
      
      public function get treasureChestChance() : Number
      {
         return this.getStat(CH2.STAT_TREASURE_CHEST_CHANCE);
      }
      
      public function get treasureChestGold() : Number
      {
         return this.getStat(CH2.STAT_TREASURE_CHEST_GOLD);
      }
      
      public function get monsterGold() : Number
      {
         return this.getStat(CH2.STAT_MONSTER_GOLD);
      }
      
      public function get clickableGold() : Number
      {
         return this.getStat(CH2.STAT_CLICKABLE_GOLD);
      }
      
      public function get walkSpeed() : Number
      {
         return WALK_SPEED_METERS_PER_SECOND * this.walkSpeedMultiplier;
      }
      
      public function get autoAttackDamage() : BigNumber
      {
         return this.damage.multiplyN(this.autoattackDamageMultiplier);
      }
      
      public function get clickDamage() : BigNumber
      {
         return this.damage.multiplyN(this.clickDamageMultiplier);
      }
      
      public function get hasteRating() : Number
      {
         return this.getStat(CH2.STAT_HASTE) * (1 + (!!this.speedRuneActivated?SPEED_RUNE_HASTE_BONUS:0));
      }
      
      public function get automatorSpeed() : Number
      {
         return this.getStat(CH2.STAT_AUTOMATOR_SPEED);
      }
      
      public function get baseAttackDelay() : Number
      {
         return this.attackMsDelay;
      }
      
      public function get attackDelay() : Number
      {
         return this.baseAttackDelay / this.hasteRating;
      }
      
      public function get baseGCD() : Number
      {
         return this.gcdBase;
      }
      
      public function get gcd() : Number
      {
         return Math.max(this.baseGCD / this.hasteRating,this.gcdMinimum);
      }
      
      public function get pierceChance() : Number
      {
         return this.getStat(CH2.STAT_PIERCE_CHANCE);
      }
      
      public function get criticalChance() : Number
      {
         return this.getStat(CH2.STAT_CRIT_CHANCE) + (!!this.luckRuneActivated?LUCK_RUNE_CRITICAL_BONUS:0);
      }
      
      public function get bonusGoldChance() : Number
      {
         return this.getStat(CH2.STAT_BONUS_GOLD_CHANCE);
      }
      
      public function get itemCostReduction() : Number
      {
         return this.getStat(CH2.STAT_ITEM_COST_REDUCTION);
      }
      
      public function get baseMaxMana() : Number
      {
         return this.statBaseValues[CH2.STAT_TOTAL_MANA];
      }
      
      public function get maxMana() : Number
      {
         return this.getStat(CH2.STAT_TOTAL_MANA);
      }
      
      public function get baseMaxEnergy() : Number
      {
         return this.statBaseValues[CH2.STAT_TOTAL_ENERGY];
      }
      
      public function get maxEnergy() : Number
      {
         return this.getStat(CH2.STAT_TOTAL_ENERGY);
      }
      
      public function get hasIdleBonuses() : Boolean
      {
         return this.idleMonsterGoldMultiplier != 1 || this.idleDamageMultiplier != 1;
      }
      
      public function get idleMonsterGoldMultiplier() : Number
      {
         return this.getStat(CH2.STAT_IDLE_GOLD);
      }
      
      public function get walkSpeedMultiplier() : Number
      {
         return this.getStat(CH2.STAT_MOVEMENT_SPEED);
      }
      
      public function get damageMultiplier() : Number
      {
         return this.getStat(CH2.STAT_DAMAGE);
      }
      
      public function get ancientShardDamageMultiplier() : Number
      {
         return Math.pow(ANCIENT_SHARD_DAMAGE_BONUS,this.ancientShards);
      }
      
      public function get monsterGoldMultiplier() : Number
      {
         return this.getStat(CH2.STAT_GOLD);
      }
      
      public function get criticalDamageMultiplier() : Number
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
      
      public function get bonusGoldChanceRating() : Number
      {
         return this.getStat(CH2.STAT_BONUS_GOLD_CHANCE);
      }
      
      public function get itemCostReductionRating() : Number
      {
         return this.getStat(CH2.STAT_ITEM_COST_REDUCTION);
      }
      
      public function get energyRegeneration() : Number
      {
         return ENERGY_REGEN_PER_AUTO_ATTACK + this.getStat(CH2.STAT_ENERGY_REGEN);
      }
      
      public function get autoattackDamageMultiplier() : Number
      {
         return 1;
      }
      
      public function get clickDamageMultiplier() : Number
      {
         return this.getStat(CH2.STAT_CLICK_DAMAGE);
      }
      
      public function get idleDamageMultiplier() : Number
      {
         return this.getStat(CH2.STAT_IDLE_DAMAGE);
      }
      
      public function get manaRegenMultiplier() : Number
      {
         return this.getStat(CH2.STAT_MANA_REGEN);
      }
      
      public function get energyCostReduction() : Number
      {
         return this.getStat(CH2.STAT_ENERGY_COST_REDUCTION);
      }
      
      public function get clickableChance() : Number
      {
         return this.getStat(CH2.STAT_CLICKABLE_CHANCE);
      }
      
      public function getMultiplierForItemType(type:int) : Number
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
               return 1;
         }
      }
      
      public function getStat(id:Number) : Number
      {
         var statRating:Number = NaN;
         var statMultiplier:Number = NaN;
         if(CH2.STATS[id].calculationType == CH2.ADDITIVE)
         {
            statRating = 0;
            statRating = statRating + this.inventory.getEquippedStatRating(id);
            statRating = statRating + this.buffs.getBuffedStatRating(id);
            statRating = statRating + this.getClassStat(id);
            return statRating;
         }
         if(CH2.STATS[id].calculationType == CH2.MULTIPLICATIVE)
         {
            statMultiplier = 1;
            statMultiplier = statMultiplier * this.inventory.getEquippedStatMultiplier(id);
            statMultiplier = statMultiplier * this.buffs.getBuffedStatMultiplier(id);
            statMultiplier = statMultiplier * this.getClassStat(id);
            return statMultiplier;
         }
         return 1;
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
            CH2UI.instance.mainUI.hud.skillBar.skillSlots[slot].skillSlotUI.skill = null;
            CH2UI.instance.mainUI.hud.skillBar.skillSlots[slot].skillSlotUI.removeItemIcon();
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
      
      public function cooldownSkills(dt:int) : void
      {
         var skill:Skill = null;
         var cooldownTime:Number = dt * CH2.currentCharacter.hasteRating;
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
         return 1 / SECONDS_FROM_ZERO_TO_BASE_MAX_MANA_WITHOUT_MANA_REGEN_STATS * this.statBaseValues[CH2.STAT_TOTAL_MANA] * this.manaRegenMultiplier;
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
         var previousEnergy:Number = this.energy;
         if(this.energy < this.maxEnergy || amount < 0 || this.energy == this.maxEnergy && amount > this.energyRegeneration)
         {
            this.energy = this.energy + amount;
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
         var previousMana:Number = this.mana;
         if(this.mana <= this.maxMana || amount < 0)
         {
            this.mana = this.mana + amount;
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
         if(this.gold.gte(item.cost(amount)) && !this.isPurchasingLocked)
         {
            this.inputLogger.recordInput(GameActions["LEVEL_UP_ITEM_" + this.inventory.getSlotFromItem(item.uid)],amount);
            this.subtractGold(item.cost(amount));
            item.level = item.level + amount;
            this.inventory.cachedEquippedDamage.base = -1;
            if(IdleHeroMain.IS_RENDERING)
            {
               this.excitingUpgradeCheck();
               CH2UI.instance.mainUI.mainPanel.itemsPanel.updateAllEquipAndCatalogSlots();
               CH2UI.instance.mainUI.mainPanel.itemsPanel.equipSlots[item.type].updateMultiplierMeter();
            }
            this.totalUpgradesToItems++;
            this.timeOfLastItemUpgrade = CH2.user.totalMsecsPlayed;
            item.updateNextPurchaseInfo(this.shouldLevelToNextMultiplier);
         }
         else
         {
            Trace("Not enough gold to level item slot " + this.inventory.getSlotFromItem(item.uid) + " " + amount + "x");
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
         var itemToPurchase:Item = this.catalogItemsForSale[index];
         var itemCost:BigNumber = itemToPurchase.cost();
         if(this.gold.gte(itemCost) && !this.isPurchasingLocked)
         {
            previousMaxMana = this.maxMana;
            previousMaxEnergy = this.maxEnergy;
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
            if(this.maxMana > previousMaxMana)
            {
               this.addMana(this.maxMana - previousMaxMana);
            }
            if(this.maxEnergy > previousMaxEnergy)
            {
               this.addEnergy(this.maxEnergy - previousMaxEnergy);
            }
            if(itemToPurchase.tier > this.highestItemTierSeen)
            {
               this.highestItemTierSeen = itemToPurchase.tier;
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
         var _loc4_:Item = null;
         var _loc5_:Item = null;
         this.catalogItemsForSale = [];
         var _loc1_:Number = Math.min(this.currentCatalogRank + 1,MAX_CATALOG_SIZE);
         var _loc2_:Boolean = false;
         var _loc3_:Number = this.currentCatalogRank % Item.ITEM_EQUIP_AMOUNT;
         if(this.inventory.items[_loc3_] != null)
         {
            _loc4_ = this.inventory.items[_loc3_];
            while(this.catalogItemsForSale.length < _loc1_ - 1)
            {
               _loc5_ = new Item();
               _loc5_.level = 1;
               _loc5_.init(_loc3_,this.currentWorld.itemCostCurve,this.currentWorld.costMultiplier,this.currentCatalogRank + 1,_loc4_.bonuses);
               this.catalogItemsForSale.push(_loc5_);
            }
         }
         while(this.catalogItemsForSale.length < _loc1_)
         {
            _loc5_ = new Item();
            _loc5_.level = 1;
            _loc5_.init(_loc3_,this.currentWorld.itemCostCurve,this.currentWorld.costMultiplier,this.currentCatalogRank + 1);
            if(!_loc2_)
            {
               _loc2_ = _loc5_.isCursed;
            }
            this.catalogItemsForSale.push(_loc5_);
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
      
      public function getClassStat(statId:int) : Number
      {
         var i:int = 0;
         if(!this.classStatsCached)
         {
            for(i = 0; i < CH2.STATS.length; i++)
            {
               this.cachedClassStats[i] = this.getStatAtLevel(i,this.getStatLevel(i));
            }
            this.classStatsCached = true;
         }
         return this.cachedClassStats[statId];
      }
      
      public function setClassStatsCached(value:Boolean) : void
      {
         if(this.classStatsCached)
         {
            this.classStatsCached = value;
         }
      }
      
      public function resetStatLevels() : void
      {
         if(this.statLevels)
         {
            this.statLevels = {};
         }
      }
      
      public function getStatLevel(statId:int) : Number
      {
         if(this.statLevels[statId])
         {
            return this.statLevels[statId];
         }
         return 0;
      }
      
      public function getStatAtLevel(statId:int, level:Number) : Number
      {
         var valueFunction:Function = this.statValueFunctions[statId];
         var baseValue:Number = this.statBaseValues[statId];
         if(valueFunction != null)
         {
            if(CH2.STATS[statId].calculationType == CH2.MULTIPLICATIVE)
            {
               return baseValue * valueFunction(level);
            }
            return baseValue + valueFunction(level);
         }
         throw Error("Can\'t find value function or base value for stat: " + statId);
      }
      
      public function getStatDisplayName(statId:int) : String
      {
         if(CH2.STATS[statId] == null)
         {
            throw Error("Can\'t find display name for stat: " + statId);
         }
         return CH2.STATS[statId].displayName;
      }
      
      public function getStatDescription(statId:int) : String
      {
         return this.getStatDescriptionAtLevel(statId,this.getStatLevel(statId));
      }
      
      public function getStatDescriptionAtNextLevel(statId:int) : String
      {
         return this.getStatDescriptionAtLevel(statId,this.getStatLevel(statId) + 1);
      }
      
      public function getStatDescriptionAtLevel(statId:int, level:Number) : String
      {
         if(CH2.STATS[statId] == null)
         {
            throw Error("Can\'t find description function for stat: " + statId);
         }
         return _(CH2.STATS[statId].description,this.getStatAtLevel(statId,level));
      }
      
      public function getStatLevelUpCost(statId:int) : BigNumber
      {
         if(this.statCostFunctions[statId] != null)
         {
            return new BigNumber(this.statCostFunctions[statId](this.getStatLevel(statId) + 1));
         }
         throw Error("Can\'t find cost function for stat: " + statId);
      }
      
      public function getStatValueIncreaseAsMultiple(statId:int) : Number
      {
         var statLevel:Number = this.getStatLevel(statId);
         var baseStatValue:Number = this.statBaseValues[statId];
         var nextLevelValue:Number = baseStatValue + this.statValueFunctions[statId](statLevel + 1);
         var currentLevelValue:Number = baseStatValue + this.statValueFunctions[statId](statLevel);
         return nextLevelValue / currentLevelValue;
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
      
      public function respecStats() : void
      {
         if(this.level > 1)
         {
            this.level--;
            this.statLevels = {};
            this.spentStatPoints = new BigNumber(0);
         }
      }
      
      public function gainLevel() : void
      {
         this.level++;
         var whatever:BigNumber = this.totalStatPoints;
         this.totalStatPointsV2++;
         this.hasNewSkillTreePointsAvailable = true;
         this.timeOfLastLevelUp = CH2.user.totalMsecsPlayed;
         this.levelUpStat(CH2.STAT_DAMAGE);
         this.eventLogger.logEvent(EventLog.LEVELED_UP);
         if(this.energy < this.maxEnergy)
         {
            this.addEnergy(this.maxEnergy - this.energy,false);
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
         while(this.levelUpCost.lte(this.experience))
         {
            this.experience.minusEquals(this.levelUpCost);
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
      
      public function partialRespec(param1:int) : void
      {
         var _loc8_:int = 0;
         var _loc9_:Skill = null;
         var _loc10_:Number = NaN;
         var _loc2_:Number = this.statLevels[CH2.STAT_AUTOMATOR_SPEED];
         var _loc3_:Number = this.statLevels[CH2.STAT_DAMAGE];
         var _loc4_:Object = this.nodesPurchased;
         var _loc5_:Object = this.undoNodes;
         var _loc6_:Number = this.totalStatPointsV2;
         var _loc7_:Character = new Character();
         _loc7_.name = this.name;
         Characters.populateStaticFields(_loc7_);
         this.buffs.removeAllBuffs();
         for(_loc8_ = 0; _loc8_ < this.activeSkills.length; _loc8_++)
         {
            _loc9_ = this.activeSkills[_loc8_];
            _loc10_ = null;
            if(_loc9_ && _loc9_.isActive)
            {
               _loc10_ = _loc9_.slot;
               if(_loc10_ >= 0 && CH2UI.instance.mainUI)
               {
                  CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc10_].removeChild(CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc10_].skillSlotUI);
                  CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc10_].onDropRemoved(CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc10_].skillSlotUI);
               }
            }
         }
         this.deactivateAllSkills();
         for(_loc8_ = 0; _loc8_ < this.lostOnGilding.length; _loc8_++)
         {
            this[this.lostOnGilding[_loc8_]] = _loc7_[this.lostOnGilding[_loc8_]];
         }
         this.setupSkills();
         this.statLevels[CH2.STAT_AUTOMATOR_SPEED] = _loc2_;
         this.statLevels[CH2.STAT_DAMAGE] = _loc3_;
         this.totalStatPointsV2 = _loc6_;
         for(_loc8_ = 0; _loc8_ < this.levelGraph.nodes.length; _loc8_++)
         {
            if(this.levelGraph.nodes[_loc8_])
            {
               if(_loc4_.hasOwnProperty(this.levelGraph.nodes[_loc8_].id))
               {
                  if(_loc5_.hasOwnProperty(this.levelGraph.nodes[_loc8_].id) && _loc5_[this.levelGraph.nodes[_loc8_].id] > param1)
                  {
                     this.levelGraph.purchaseNode(this.levelGraph.nodes[_loc8_].id);
                  }
               }
            }
         }
         if(this.characterDisplay)
         {
            this.characterDisplay.characterUI.removeAll();
         }
      }
      
      public function addGild(worldId:Number) : Boolean
      {
         if(this.addGildHandler)
         {
            return this.addGildHandler.addGildOverride(worldId);
         }
         return this.addGildDefault(worldId);
      }
      
      public function addGildDefault(param1:Number) : void
      {
         var _loc4_:int = 0;
         var _loc8_:Skill = null;
         var _loc9_:Number = NaN;
         var _loc2_:Number = this.statLevels[CH2.STAT_AUTOMATOR_SPEED];
         var _loc3_:Character = new Character();
         _loc3_.name = this.name;
         Characters.populateStaticFields(_loc3_);
         this.buffs.removeAllBuffs();
         for(_loc4_ = 0; _loc4_ < this.activeSkills.length; _loc4_++)
         {
            _loc8_ = this.activeSkills[_loc4_];
            _loc9_ = null;
            if(_loc8_ && _loc8_.isActive)
            {
               _loc9_ = _loc8_.slot;
               if(_loc9_ >= 0 && CH2UI.instance.mainUI)
               {
                  CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc9_].removeChild(CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc9_].skillSlotUI);
                  CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc9_].onDropRemoved(CH2UI.instance.mainUI.hud.skillBar.skillSlots[_loc9_].skillSlotUI);
               }
            }
         }
         this.deactivateAllSkills();
         for(_loc4_ = 0; _loc4_ < this.lostOnGilding.length; _loc4_++)
         {
            this[this.lostOnGilding[_loc4_]] = _loc3_[this.lostOnGilding[_loc4_]];
         }
         this.setupSkills();
         CH2.currentCharacter.setClassStatsCached(false);
         CH2.currentCharacter.resetStatLevels();
         this.timeSinceLastAncientShardPurchase = ANCIENT_SHARD_PURCHASE_COOLDOWN;
         this.gilds = Math.floor((param1 - 1) / this.worldsPerGild);
         this.level = param1 * 5 + 6 + (this.gilds - 1) * 5;
         this.experience = new BigNumber(0);
         var _loc5_:BigNumber = this.getLevelUpCostToNextLevel(this.level);
         _loc5_.timesEqualsN(0.8);
         this.experience = _loc5_;
         this.statLevels[CH2.STAT_AUTOMATOR_SPEED] = _loc2_;
         this.statLevels[CH2.STAT_DAMAGE] = this.level;
         var _loc6_:BigNumber = new BigNumber(0);
         _loc6_.base = this.gildedDamageMultiplier.base;
         _loc6_.power = this.gildedDamageMultiplier.power;
         this.gildedDamageMultiplier = Formulas.instance.getWorldDifficulty(param1).divideN(this.getClassStat(CH2.STAT_DAMAGE));
         var _loc7_:BigNumber = this.gildedDamageMultiplier.divide(_loc6_);
         if(this.characterDisplay)
         {
            this.characterDisplay.characterUI.removeAll();
         }
         this.showCongratsPopupWhenUIIsCreated(_loc7_);
         this.totalStatPointsV2 = 6;
      }
      
      public function showCongratsPopupWhenUIIsCreated(gildedDamageChange:BigNumber) : void
      {
         if(CH2UI.instance.doesGameUIExist)
         {
            CH2UI.instance.showSimpleGamePopup("Congratulations!",_("Congratulations! You\'ve completed a gilded world. Your base damage has been multiplied by %s%, and your skill tree has been reset, but your Automator upgrades remain.",CH2.game.formattedNumber(gildedDamageChange.multiplyN(100))),null,"Continue");
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
      
      public function statTooltipDescription(statId:int) : Object
      {
         var header:String = this.getStatDisplayName(statId) + " - " + _("LVL %s",this.getStatLevel(statId));
         var description:String = TextManager.textToColor(this.getStatDescription(statId),"#00F462");
         description = description + ("\n\nNext Level: " + this.getStatDescriptionAtNextLevel(statId));
         return {
            "header":header,
            "body":description
         };
      }
      
      public function applyPurchasedNodes() : void
      {
         var key:* = null;
         var nodeType:Object = null;
         for(key in this.nodesPurchased)
         {
            nodeType = this.levelGraphNodeTypes[this.levelGraph.nodes[key].type];
            if(nodeType.hasOwnProperty("loadFunction"))
            {
               this.levelGraphNodeTypes[this.levelGraph.nodes[key].type].loadFunction();
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
         this.onAscension();
      }
      
      public function shouldRubyShopActivate() : Boolean
      {
         if(this.shouldRubyShopActivateHandler)
         {
            return this.shouldRubyShopActivateHandler.shouldRubyShopActivateOverride();
         }
         return this.shouldRubyShopActivateDefault();
      }
      
      private function shouldRubyShopActivateDefault() : Boolean
      {
         return this.timeSinceLastRubyShopAppearance > RUBY_SHOP_APPEARANCE_COOLDOWN && !CH2.world.isBossZone(this.currentZone) && !this.didFinishWorld && this.totalRubies >= 50 && !CH2.world.massiveOrangeFish.isActive;
      }
      
      public function shouldRubyShopDeactivate() : Boolean
      {
         if(this.shouldRubyShopDeactivateHandler)
         {
            return this.shouldRubyShopDeactivateHandler.shouldRubyShopDeactivateOverride();
         }
         return this.shouldRubyShopDeactivateDefault();
      }
      
      private function shouldRubyShopDeactivateDefault() : Boolean
      {
         return this.timeSinceLastRubyShopAppearance > RUBY_SHOP_APPEARANCE_DURATION || CH2.world.isBossZone(this.currentZone) || this.didFinishWorld;
      }
      
      public function populateRubyPurchaseOptions() : void
      {
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
         var ancientShardPurchase:RubyPurchase = new RubyPurchase();
         ancientShardPurchase.priority = 1;
         ancientShardPurchase.name = "Ancient Shard";
         ancientShardPurchase.price = 50;
         ancientShardPurchase.iconId = 1;
         ancientShardPurchase.getDescription = this.getAncientShardDescription;
         ancientShardPurchase.getSoldOutText = this.getDefaultSoldOutText;
         ancientShardPurchase.onPurchase = this.onAncientShardPurchase;
         ancientShardPurchase.canAppear = this.canAncientShardAppear;
         ancientShardPurchase.canPurchase = this.canPurchaseAncientShard;
         this.rubyPurchaseOptions.push(ancientShardPurchase);
         var powerRunePurchase:RubyPurchase = new RubyPurchase();
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
         luckRunePurchase.priority = 2;
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
         bagOfGold.priority = 3;
         bagOfGold.name = "Bag of Gold";
         bagOfGold.getDescription = this.getBagOfGoldDescription;
         bagOfGold.getSoldOutText = this.getDefaultSoldOutText;
         bagOfGold.price = 1;
         bagOfGold.iconId = 6;
         bagOfGold.onPurchase = this.onBagOfGoldPurchase;
         bagOfGold.canAppear = this.canBagOfGoldAppear;
         bagOfGold.canPurchase = this.canPurchaseBagOfGold;
         this.rubyPurchaseOptions.push(bagOfGold);
         var magicalBrew:RubyPurchase = new RubyPurchase();
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
         var index:int = 0;
         var possiblePurchases:Array = [];
         for each(rubyPurchase in this.rubyPurchaseOptions)
         {
            if(rubyPurchase.priority == priority && rubyPurchase.canAppear() && this.currentRubyShop.indexOf(rubyPurchase) == -1)
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
      
      public function generateRubyShopDefault() : void
      {
         this.currentRubyShop = [];
         var option1:RubyPurchase = this.getRandomRubyPurchase(1);
         if(!option1)
         {
            option1 = this.getRandomRubyPurchase(2);
         }
         if(option1)
         {
            this.currentRubyShop.push(option1);
         }
         var option2:RubyPurchase = this.getRandomRubyPurchase(2);
         if(!option2)
         {
            option2 = this.getRandomRubyPurchase(3);
         }
         if(option2)
         {
            this.currentRubyShop.push(option2);
         }
         var option3:RubyPurchase = this.getRandomRubyPurchase(3);
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
         this.timeSinceLastAncientShardPurchase = this.timeSinceLastAncientShardPurchase + dt;
         this.timeSinceLastAutomatorPointPurchase = this.timeSinceLastAutomatorPointPurchase + dt;
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
         var rubyPurchaseName:String = rubyPurchase.name;
         var rubyPurchasePrice:Number = rubyPurchase.price;
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
         return !this.speedRuneActivated;
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
         return _("Multiply your damage by x%s until the next time you Gild.",ANCIENT_SHARD_DAMAGE_BONUS);
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
      
      public function getAutomatorPointDescription() : String
      {
         return _("Gives you 1 automator point");
      }
      
      public function onAutomatorPointPurchase() : void
      {
         CH2.currentCharacter.automatorPoints++;
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
      
      public function ascend(worldNumber:Number) : void
      {
         this.inputLogger.recordInput(GameActions.ASCEND,worldNumber);
         CH2.user.timesAscended++;
         this.onAscension();
         if(this.characterDisplay)
         {
            this.characterDisplay.characterUI.removeAll();
         }
         this.startWorld(worldNumber);
         this.energy = this.maxEnergy;
         this.mana = this.maxMana;
         this.cooldownSkills(1000000000);
         CH2.game.doGameStateAction(IdleHeroMain.ACTION_PLAYER_CLICKED_START_RUN);
         this.eventLogger.logEvent(EventLog.ASCENDED);
      }
      
      public function persist(persistThroughGilding:Boolean, registerDynamicFunction:Function, ... registerDynamicArgs) : *
      {
         if(registerDynamicArgs.length == 2)
         {
            registerDynamicFunction(registerDynamicArgs[0],registerDynamicArgs[1]);
         }
         else
         {
            registerDynamicFunction(registerDynamicArgs[0]);
         }
         if(!persistThroughGilding)
         {
            this.lostOnGilding.push(registerDynamicArgs[0]);
         }
      }
      
      public function migrate(characterInstance:Character) : void
      {
         trace("migrating version " + this.version + " to " + IdleHeroMain.SAVE_VERSION);
         this.onMigration(characterInstance);
         this.version = IdleHeroMain.SAVE_VERSION;
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
         if(item.skills.length > 0)
         {
            return new BigNumber(0);
         }
         var result:BigNumber = item.baseCost.divideN(30);
         if(CH2.currentAscensionWorld && CH2.currentAscensionWorld.worldNumber <= 2)
         {
            result.timesEqualsN(Math.pow(0.86,item.rank - 1));
         }
         else
         {
            result.timesEqualsN(Math.pow(0.9,item.rank - 1));
         }
         result.timesEqualsN(1 + item.bonusDamage);
         if(item.rank < 4)
         {
            result.timesEqualsN(5 - item.rank);
         }
         result.floorInPlace();
         result.timesEqualsN(item.level);
         result.timesEqualsN(Math.pow(this.item10LvlDmgMultiplier,Math.floor(item.level / 10)));
         result.timesEqualsN(Math.pow(this.item20LvlDmgMultiplier,Math.floor(item.level / 20)));
         if(item.level >= 50)
         {
            result.timesEqualsN(this.item50LvlDmgMultiplier);
            if(item.level >= 100)
            {
               result.timesEqualsN(this.item100LvlDmgMultiplier);
            }
         }
         result.timesEqualsN(this.getMultiplierForItemType(item.type));
         return result;
      }
   }
}
