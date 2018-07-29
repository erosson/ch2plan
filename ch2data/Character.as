package models
{
   import com.doogog.utils.MiscUtils;
   import com.gskinner.utils.Rnd;
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
   import ui.IdleHeroUIManager;
   
   public dynamic class Character extends WorldEntity
   {
      
      public static const TIME_UNTIL_PLAYER_NEEDS_HINT_MS:Number = 300000;
      
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
      
      public static const SECONDS_FROM_ZERO_TO_FULL_MANA:Number = 1200;
      
      public static const MAX_CATALOG_SIZE:Number = 4;
      
      public static const ZONES_BETWEEN_TALENTS:Number = 10;
      
      private static const WORLD_END_AUTOMATION_OPTIONS_UNLOCK_WORLD:Number = 3;
      
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
      
      public static const POWER_RUNE_DAMAGE_BONUS:Number = 1;
      
      public static const SPEED_RUNE_HASTE_BONUS:Number = 0.1;
      
      public static const LUCK_RUNE_CRITICAL_BONUS:Number = 0.05;
      
      public static const METAL_DETECTOR_GOLD_BONUS:Number = 2;
      
      public static const METAL_DETECTOR_TIME_DURATION:Number = 1200000;
      
      public static const METAL_DETECTOR_ZONE_DURATION:Number = 5;
      
      public static const MAGICAL_BREW_MANA_AMOUNT:Number = 10;
      
      public static const DEFAULT_UPGRADEABLE_STATS:Array = [CH2.STAT_GOLD,CH2.STAT_MOVEMENT_SPEED,CH2.STAT_CRIT_CHANCE,CH2.STAT_CRIT_DAMAGE,CH2.STAT_HASTE,CH2.STAT_MANA_REGEN,CH2.STAT_IDLE_DAMAGE,CH2.STAT_CLICKABLE_GOLD,CH2.STAT_CLICK_DAMAGE,CH2.STAT_TREASURE_CHEST_CHANCE,CH2.STAT_BOSS_GOLD,CH2.STAT_ITEM_COST_REDUCTION,CH2.STAT_TOTAL_MANA,CH2.STAT_TOTAL_ENERGY,CH2.STAT_CLICKABLE_CHANCE,CH2.STAT_BONUS_GOLD_CHANCE,CH2.STAT_TREASURE_CHEST_GOLD,CH2.STAT_PIERCE_CHANCE,CH2.STAT_ITEM_WEAPON_DAMAGE,CH2.STAT_ITEM_HEAD_DAMAGE,CH2.STAT_ITEM_CHEST_DAMAGE,CH2.STAT_ITEM_RING_DAMAGE,CH2.STAT_ITEM_LEGS_DAMAGE,CH2.STAT_ITEM_HANDS_DAMAGE,CH2.STAT_ITEM_FEET_DAMAGE,CH2.STAT_ITEM_BACK_DAMAGE];
      
      public static const VALUES_RESET_AT_ASCENSION:Array = ["State","timeSinceLastClickAttack","timeSinceLastSkill","timeSinceLastAutoAttack","consecutiveOneShottedMonsters","gold","mana","energy","gcdRemaining","castTimeRemaining","castTime","skillBeingCast","buffs","inventory","currentCatalogRank","catalogItemsForSale","isPurchasingLocked","currentZone","highestZone","totalRunDistance","totalGold","monstersKilled","monstersKilledPerZone","powerRuneActivated","speedRuneActivated","luckRuneActivated","timeMetalDetectorActive","zoneMetalDetectorActive","zoneStartGold"];
      
      public static var staticSkillInstances:Object = {};
      
      public static var staticFields:Array = ["flavorName","flavorClass","flavor","gender","flair","characterSelectOrder","availableForCreation","visibleOnCharacterSelect","defaultSaveName","startingSkills","levelCostScaling","talentChoices","talentZones","upgradeableStats","assetGroupName","damageMultiplierBase","maxManaMultiplierBase","maxEnergyMultiplierBase","attackMsDelay","gcdBase","autoAttackDamageMultiplierBase","damageMultiplierValueFunction","maxManaMultiplierValueFunction","maxEnergyMultiplierValueFunction","damageMultiplierCostFunction","maxManaMultiplierCostFunction","maxEnergyMultiplierCostFunction","statValueFunctions","statBaseValues","statCostFunctions","monstersPerZone","monsterHealthMultiplier","attackRange","levelGraph","levelGraphNodeTypes","recommendedLevelsForWorlds"];
       
      
      public var state:int = 5;
      
      public var monstersPerZone:Number = 50;
      
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
      
      public var name:String;
      
      public var creationTime:Number;
      
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
      
      public var powerRuneActivated:Boolean = false;
      
      public var speedRuneActivated:Boolean = false;
      
      public var luckRuneActivated:Boolean = false;
      
      public var timeMetalDetectorActive:Boolean = false;
      
      public var timeSinceTimeMetalDetectorActivated:Number;
      
      public var zoneMetalDetectorActive:Boolean = false;
      
      public var zoneOfZoneMetalDetectorActivation:Number;
      
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
      
      public var gcdRemaining:Number = 0;
      
      public var castTimeRemaining:Number = 0;
      
      public var castTime:Number = 0;
      
      public var skillBeingCast:Skill;
      
      public var buffs:Buffs;
      
      public var inventory:Items;
      
      public var currentCatalogRank:Number = 0;
      
      public var catalogItemsForSale:Array;
      
      public var isPurchasingLocked:Boolean = false;
      
      public var automator:Automator;
      
      public var currentWorldEndAutomationOption:int = -1;
      
      public var worldEndAutomationOptions:Array;
      
      public var timeOfLastRun:Number = 0;
      
      public var timeOfLastAscension:Number = 0;
      
      public var timeCharacterWasUnlocked:Number = 0;
      
      public var timeOnlineMilliseconds:Number = 0;
      
      public var timeOfflineMilliseconds:Number = 0;
      
      public var timeSinceLastItemInteraction:Number = 0;
      
      public var serverTimeOfLastUpdate:Number = 0;
      
      public var didFinishWorld:Boolean = true;
      
      public var currentZone:Number = 1;
      
      public var highestZone:Number = 1;
      
      public var totalRunDistance:Number = 0;
      
      public var totalGold:BigNumber;
      
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
      
      public var hasSeenAutomatorPanel:Boolean = false;
      
      public var hasSeenWorldsPanel:Boolean = false;
      
      public var hasSeenMiscPanel:Boolean = false;
      
      public var hasReceivedFirstTimeEnergy:Boolean = false;
      
      public var hasSeenRubyShopPanel:Boolean = false;
      
      public var hasNewSkillTreePointsAvailable:Boolean = false;
      
      public var hasNewSkillAvailable:Boolean = false;
      
      public var itemAlertArrowsShowing:int = 0;
      
      public var totalRubies:Number = 0;
      
      public var isItemPanelUnlocked:Function;
      
      public var isGraphPanelUnlocked:Function;
      
      public var isSkillPanelUnlocked:Function;
      
      public var isAutomatorPanelUnlocked:Function;
      
      public var isWorldsPanelUnlocked:Function;
      
      public var isMiscPanelUnlocked:Function;
      
      public var shouldSlideInMainPanelForFirstTime:Function;
      
      public var shouldShowGraphPanelAlertArrow:Function;
      
      public var shouldShowAutomatorPanelAlertArrow:Function;
      
      public var shouldShowCatalogItemAlertArrow:Function;
      
      public var shouldShowItemUpgradeAlertArrow:Function;
      
      public var shouldShowMainPanelAlertArrow:Function;
      
      public var shouldShowRightPanelAlertArrow:Function;
      
      public var assetGroupName:String;
      
      public var skills:Object;
      
      public var activeSkills:Array;
      
      public var talents:Array;
      
      public var level:Number = 1;
      
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
      
      public var timeSinceLastLevelUp:Number = 0;
      
      public var timeSinceAutomatorWasUnlocked:Number = 0;
      
      public var flavorName:String;
      
      public var flavorClass:String;
      
      public var flavor:String;
      
      public var gender:String;
      
      public var flair:String;
      
      public var characterSelectOrder:Number;
      
      public var availableForCreation:Boolean;
      
      public var visibleOnCharacterSelect:Boolean;
      
      public var defaultSaveName:String;
      
      public var baseOutfitId:Number;
      
      public var startingSkills:Array;
      
      public var levelCostScaling:String;
      
      public var talentZones:Array;
      
      public var talentChoices:Array;
      
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
      
      public var traits:Object;
      
      public var recommendedLevelsForWorlds:Object;
      
      public var characterDisplay:CharacterDisplay;
      
      public var applyTalents:Function;
      
      public var onWorldStarted:Function;
      
      public var onCharacterLoaded:Function;
      
      public var onCharacterUnloaded:Function;
      
      public var onCharacterDisplayCreated:Function;
      
      public var triggerGlobalCooldown:Function;
      
      public var unlockCharacter:Function;
      
      public var onAutomatorUnlocked:Function;
      
      public var populateWorldEndAutomationOptions:Function;
      
      private var timeUntilDamageCache:int = 100;
      
      private var cachedDamage:Array;
      
      private var nextDamageCacheEntry:int = 0;
      
      private var musicExcitementLevel:int = 0;
      
      private var musicExcitementTimer:int = 0;
      
      public var update:Function;
      
      public var changeState:Function;
      
      public var attack:Function;
      
      public var clickAttack:Function;
      
      public var autoAttack:Function;
      
      public var onClickAttack:Function;
      
      public var onTeleportAttack:Function;
      
      public var onKilledMonster:Function;
      
      public var onZoneChanged:Function;
      
      public var onWorldFinished:Function;
      
      public var onAscension:Function;
      
      public var addGold:Function;
      
      public var addRubies:Function;
      
      public var regenerateManaAndEnergy:Function;
      
      public var addEnergy:Function;
      
      public var addMana:Function;
      
      public var canUseSkill:Function;
      
      public var onUsedSkill:Function;
      
      public var levelUpItem:Function;
      
      public var buyNextItemBonus:Function;
      
      public var purchaseCatalogItem:Function;
      
      public var generateCatalog:Function;
      
      public var learnTalent:Function;
      
      public var walk:Function;
      
      public var shouldRubyShopActivate:Function;
      
      public var shouldRubyShopDeactivate:Function;
      
      public var populateRubyPurchaseOptions:Function;
      
      public var generateRubyShop:Function;
      
      public var updateRubyShopFields:Function;
      
      public function Character()
      {
         this.unarmedDamage = new BigNumber(1);
         this.roller = new Roller();
         this.gold = new BigNumber(0);
         this.zoneStartGold = new BigNumber(0);
         this.rubyPurchaseOptions = [];
         this.currentRubyShop = [];
         this.inputLogger = new InputLog();
         this.eventLogger = new EventLog();
         this.buffs = new Buffs();
         this.inventory = new Items();
         this.catalogItemsForSale = [];
         this.automator = new Automator();
         this.worldEndAutomationOptions = [];
         this.totalGold = new BigNumber(0);
         this.monstersKilledPerZone = {};
         this.isItemPanelUnlocked = this.isItemPanelUnlockedDefault;
         this.isGraphPanelUnlocked = this.isGraphPanelUnlockedDefault;
         this.isSkillPanelUnlocked = this.isSkillPanelUnlockedDefault;
         this.isAutomatorPanelUnlocked = this.isAutomatorPanelUnlockedDefault;
         this.isWorldsPanelUnlocked = this.isWorldsPanelUnlockedDefault;
         this.isMiscPanelUnlocked = this.isMiscPanelUnlockedDefault;
         this.shouldSlideInMainPanelForFirstTime = this.shouldSlideInMainPanelForFirstTimeDefault;
         this.shouldShowGraphPanelAlertArrow = this.shouldShowGraphPanelAlertArrowDefault;
         this.shouldShowAutomatorPanelAlertArrow = this.shouldShowAutomatorPanelAlertArrowDefault;
         this.shouldShowCatalogItemAlertArrow = this.shouldShowCatalogItemAlertArrowDefault;
         this.shouldShowItemUpgradeAlertArrow = this.shouldShowItemUpgradeAlertArrowDefault;
         this.shouldShowMainPanelAlertArrow = this.shouldShowMainPanelAlertArrowDefault;
         this.shouldShowRightPanelAlertArrow = this.shouldShowRightPanelAlertArrowDefault;
         this.skills = {};
         this.activeSkills = [];
         this.talents = [];
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
         this.statValueFunctions = new Array();
         this.statCostFunctions = new Array();
         this.statBaseValues = new Array();
         this.nodesPurchased = {};
         this.traits = {};
         this.applyTalents = this.applyTalentsDefault;
         this.onWorldStarted = this.onWorldStartedDefault;
         this.onCharacterLoaded = this.onCharacterLoadedDefault;
         this.onCharacterUnloaded = this.onCharacterUnloadedDefault;
         this.onCharacterDisplayCreated = this.onCharacterDisplayCreatedDefault;
         this.triggerGlobalCooldown = this.triggerGlobalCooldownDefault;
         this.unlockCharacter = this.unlockCharacterDefault;
         this.onAutomatorUnlocked = this.onAutomatorUnlockedDefault;
         this.populateWorldEndAutomationOptions = this.populateWorldEndAutomationOptionsDefault;
         this.cachedDamage = [];
         this.update = this.updateDefault;
         this.changeState = this.changeStateDefault;
         this.attack = this.attackDefault;
         this.clickAttack = this.clickAttackDefault;
         this.autoAttack = this.autoAttackDefault;
         this.onClickAttack = this.onClickAttackDefault;
         this.onTeleportAttack = this.onTeleportAttackDefault;
         this.onKilledMonster = this.onKilledMonsterDefault;
         this.onZoneChanged = this.onZoneChangedDefault;
         this.onWorldFinished = this.onWorldFinishedDefault;
         this.onAscension = this.onAscensionDefault;
         this.addGold = this.addGoldDefault;
         this.addRubies = this.addRubiesDefault;
         this.regenerateManaAndEnergy = this.regenerateManaAndEnergyDefault;
         this.addEnergy = this.addEnergyDefault;
         this.addMana = this.addManaDefault;
         this.canUseSkill = this.canUseSkillDefault;
         this.onUsedSkill = this.onUsedSkillDefault;
         this.levelUpItem = this.levelUpItemDefault;
         this.buyNextItemBonus = this.buyNextItemBonusDefault;
         this.purchaseCatalogItem = this.purchaseCatalogItemDefault;
         this.generateCatalog = this.generateCatalogDefault;
         this.learnTalent = this.learnTalentDefault;
         this.walk = this.walkDefault;
         this.shouldRubyShopActivate = this.shouldRubyShopActivateDefault;
         this.shouldRubyShopDeactivate = this.shouldRubyShopDeactivateDefault;
         this.populateRubyPurchaseOptions = this.populateRubyPurchaseOptionsDefault;
         this.generateRubyShop = this.generateRubyShopDefault;
         this.updateRubyShopFields = this.updateRubyShopFieldsDefault;
         super();
         if(CH2.STATS.length == 0)
         {
            CH2.initStats();
         }
         x = 20;
         y = CHARACTER_ZONE_START_Y;
         removeOnZoneChanges = false;
         registerDynamicBigNumber("unarmedDamage");
         registerDynamicString("name");
         registerDynamicChild("roller",Roller);
         registerDynamicNumber("startingRollerValue");
         registerDynamicChild("trackedDps",TrackedStat);
         registerDynamicChild("trackedOverkill",TrackedStat);
         registerDynamicChild("trackedGoldGained",TrackedStat);
         registerDynamicChild("trackedGoldSpent",TrackedStat);
         registerDynamicChild("trackedEnergyUsed",TrackedStat);
         registerDynamicChild("trackedManaUsed",TrackedStat);
         registerDynamicChild("trackedFrameMsec",TrackedStat);
         registerDynamicChild("trackedXPEarned",TrackedStat);
         registerDynamicBigNumber("gold");
         registerDynamicBigNumber("zoneStartGold");
         registerDynamicNumber("rubies");
         registerDynamicNumber("energy");
         registerDynamicNumber("mana");
         registerDynamicNumber("totalRubies");
         registerDynamicChild("inventory",Items);
         registerDynamicChild("automator",Automator);
         registerDynamicNumber("currentWorldEndAutomationOption");
         registerDynamicCollection("talents",Talent);
         registerDynamicCollection("skills",Skill);
         registerDynamicNumber("currentCatalogRank");
         registerDynamicCollection("catalogItemsForSale",Item);
         registerDynamicNumber("onlineTimeAsOfLastRubyShopMilliseconds");
         registerDynamicNumber("timeOfLastRun");
         registerDynamicNumber("timeOfLastAscension");
         registerDynamicNumber("timeCharacterWasUnlocked");
         registerDynamicNumber("timeOnlineMilliseconds");
         registerDynamicNumber("timeOfflineMilliseconds");
         registerDynamicNumber("timeOfflineMilliseconds");
         registerDynamicNumber("serverTimeOfLastUpdate");
         registerDynamicNumber("creationTime");
         registerDynamicNumber("timeSinceLastRubyShopAppearance");
         registerDynamicNumber("timeSinceLastAncientShardPurchase");
         registerDynamicNumber("ancientShards");
         registerDynamicBoolean("powerRuneActivated");
         registerDynamicBoolean("speedRuneActivated");
         registerDynamicBoolean("luckRuneActivated");
         registerDynamicBoolean("timeMetalDetectorActive");
         registerDynamicNumber("timeSinceTimeMetalDetectorActivated");
         registerDynamicBoolean("zoneMetalDetectorActive");
         registerDynamicNumber("zoneOfZoneMetalDetectorActivation");
         registerDynamicBoolean("didFinishWorld");
         registerDynamicNumber("currentZone");
         registerDynamicNumber("highestZone");
         registerDynamicNumber("totalRunDistance");
         registerDynamicBigNumber("totalGold");
         registerDynamicNumber("monstersKilled");
         registerDynamicNumber("totalUpgradesToItems");
         registerDynamicNumber("totalCatalogItemsPurchased");
         registerDynamicNumber("totalOneShotMonsters");
         registerDynamicNumber("totalSkillsUsed");
         registerDynamicNumber("consecutiveOneShottedMonsters");
         registerDynamicNumber("currentWorldId");
         registerDynamicNumber("attemptsOnCurrrentBoss");
         registerDynamicNumber("timeSinceRegularMonsterHasDroppedRubies");
         registerDynamicNumber("timeSinceLastOrangeFishAppearance");
         registerDynamicBoolean("hasPurchasedFirstSkill");
         registerDynamicBoolean("hasUnlockedAutomator");
         registerDynamicBoolean("hasSeenMainPanel");
         registerDynamicBoolean("hasSeenItemsPanel");
         registerDynamicBoolean("hasSeenGraphPanel");
         registerDynamicBoolean("hasSeenSkillsPanel");
         registerDynamicBoolean("hasSeenAutomatorPanel");
         registerDynamicBoolean("hasSeenWorldsPanel");
         registerDynamicBoolean("hasSeenMiscPanel");
         registerDynamicBoolean("hasReceivedFirstTimeEnergy");
         registerDynamicBoolean("hasSeenRubyShopPanel");
         registerDynamicString("name");
         registerDynamicNumber("level");
         registerDynamicBigNumber("experience");
         registerDynamicBigNumber("totalExperience");
         registerDynamicBigNumber("experienceForCurrentWorld");
         registerDynamicBigNumber("experienceAtRunStart");
         registerDynamicNumber("highestWorldCompleted");
         registerDynamicObject("fastestWorldTimes");
         registerDynamicObject("highestMonstersKilled");
         registerDynamicObject("runsCompletedPerWorld");
         registerDynamicObject("statLevels");
         registerDynamicNumber("gcdMinimum");
         registerDynamicBoolean("isLocked");
         registerDynamicBigNumber("spentStatPoints");
         registerDynamicNumber("gilds");
         registerDynamicBigNumber("gildedDamageMultiplier");
         registerDynamicObject("nodesPurchased");
         registerDynamicObject("traits");
         registerDynamicObject("monstersKilledPerZone");
         registerDynamicBoolean("hasNeverStartedWorld");
         registerDynamicBoolean("autoAttacksNotInterrupted");
         registerDynamicBoolean("hasEditedSave");
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
         this.statBaseValues[CH2.STAT_BOSS_GOLD] = 1;
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
         this.statValueFunctions[CH2.STAT_BOSS_GOLD] = exponentialMultiplier(2);
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
         this.statCostFunctions[CH2.STAT_BOSS_GOLD] = exponential(1.25);
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
         return this.millisecondsBeforeNextAutoAttack <= 0;
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
            distance = (closestMonster.y - y - this.attackRange) / Character.ONE_METER_Y_DISTANCE;
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
            return closestMonster.y - y <= this.attackRange;
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
      
      public function isItemPanelUnlockedDefault() : Boolean
      {
         return true;
      }
      
      public function isGraphPanelUnlockedDefault() : Boolean
      {
         return this.level >= 2;
      }
      
      public function isSkillPanelUnlockedDefault() : Boolean
      {
         return this.hasPurchasedFirstSkill;
      }
      
      public function isAutomatorPanelUnlockedDefault() : Boolean
      {
         return this.hasUnlockedAutomator;
      }
      
      public function isWorldsPanelUnlockedDefault() : Boolean
      {
         return this.highestWorldCompleted >= 1;
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
      
      public function shouldSlideInMainPanelForFirstTimeDefault() : Boolean
      {
         return !this.hasSeenMainPanel && this.canAffordFirstCatalogItem();
      }
      
      public function shouldShowGraphPanelAlertArrowDefault() : Boolean
      {
         return this.hasAvailableStatPoints && this.spentStatPoints.ltN(3) && this.timeSinceLastLevelUp > TIME_UNTIL_PLAYER_NEEDS_HINT_MS;
      }
      
      public function shouldShowAutomatorPanelAlertArrowDefault() : Boolean
      {
         return !this.hasSeenAutomatorPanel && this.isAutomatorPanelUnlocked() && this.timeSinceAutomatorWasUnlocked > TIME_UNTIL_PLAYER_NEEDS_HINT_MS;
      }
      
      public function shouldShowCatalogItemAlertArrowDefault() : Boolean
      {
         if(this.currentCatalogRank == 0 && this.totalCatalogItemsPurchased == 0)
         {
            return this.canAffordFirstCatalogItem() && this.timeSinceLastItemInteraction > TIME_UNTIL_PLAYER_NEEDS_HINT_MS;
         }
         return false;
      }
      
      public function shouldShowItemUpgradeAlertArrowDefault() : Boolean
      {
         var item:Item = null;
         if(this.totalUpgradesToItems < 3)
         {
            item = this.inventory.getItemInSlot(0);
            if(item)
            {
               return this.gold.gte(item.cost()) && this.timeSinceLastItemInteraction > TIME_UNTIL_PLAYER_NEEDS_HINT_MS;
            }
         }
         return false;
      }
      
      public function shouldShowMainPanelAlertArrowDefault() : Boolean
      {
         return this.shouldShowGraphPanelAlertArrow() || this.shouldShowAutomatorPanelAlertArrow() || this.shouldShowItemUpgradeAlertArrow() || this.shouldShowCatalogItemAlertArrow();
      }
      
      public function shouldShowRightPanelAlertArrowDefault() : Boolean
      {
         return !this.hasSeenRubyShopPanel && this.timeSinceLastRubyShopAppearance > TIME_UNTIL_PLAYER_NEEDS_RUBY_SHOP_HINT_MS && this.timeSinceLastRubyShopAppearance < RUBY_SHOP_APPEARANCE_DURATION;
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
         return Formulas.instance.getTotalStatPoints(this.level);
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
         return CH2.user.ascensionWorlds.getWorld(this.currentWorldId);
      }
      
      public function get currentTalentTier() : Number
      {
         return this.talents.length;
      }
      
      public function get currentTalentTierChoices() : Array
      {
         return this.talentChoices[this.currentTalentTier];
      }
      
      public function get hasAllAvailableTalents() : Boolean
      {
         return this.talents.length == this.talentChoices.length;
      }
      
      public function get zoneOfNextTalentUnlock() : Number
      {
         return this.talentZones[this.talents.length];
      }
      
      public function get isReadyForNextTalent() : Boolean
      {
         var isNewTierAchieved:* = this.highestZone > this.zoneOfNextTalentUnlock;
         return !this.hasAllAvailableTalents && isNewTierAchieved;
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
         this.hasNeverStartedWorld = false;
         this.onWorldStarted(worldNumber);
         this.generateCatalog();
         this.didFinishWorld = false;
         if(!this.highestMonstersKilled.hasOwnProperty(worldNumber))
         {
            this.highestMonstersKilled[worldNumber] = 0;
         }
         MusicManager.instance.shufflePlaylists();
      }
      
      public function applyTalentsDefault() : void
      {
         var talent:Talent = null;
         for each(talent in this.talents)
         {
            Trace(talent.name);
            talent.apply();
         }
      }
      
      public function onWorldStartedDefault(worldNumber:Number) : void
      {
         this.currentWorldId = worldNumber;
         this.timeOfLastRun = CH2.user.totalMsecsPlayed;
         this.applyTalents();
      }
      
      public function onCharacterLoadedDefault() : void
      {
      }
      
      public function onCharacterUnloadedDefault() : void
      {
         this.activeSkills = [];
      }
      
      public function onCharacterDisplayCreatedDefault(display:CharacterDisplay) : void
      {
      }
      
      public function triggerGlobalCooldownDefault() : void
      {
         this.gcdRemaining = this.gcd;
      }
      
      public function unlockCharacterDefault() : void
      {
         if(this.isLocked)
         {
            this.isLocked = false;
            this.timeCharacterWasUnlocked = CH2.user.totalMsecsPlayed;
         }
      }
      
      public function onAutomatorUnlockedDefault() : void
      {
         this.hasUnlockedAutomator = true;
         this.timeSinceAutomatorWasUnlocked = 0;
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
         var currentDamage:BigNumber = this.inventory.getEquippedDamage().add(this.unarmedDamage);
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
      
      public function updateDefault(dt:int) : void
      {
         var target:Monster = null;
         var idleBuff:Buff = null;
         this.timeSinceLastLevelUp = this.timeSinceLastLevelUp + dt;
         this.timeSinceAutomatorWasUnlocked = this.timeSinceAutomatorWasUnlocked + dt;
         this.timeSinceLastItemInteraction = this.timeSinceLastItemInteraction + dt;
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
            this.cachedDamage[this.nextDamageCacheEntry] = this.inventory.getEquippedDamage().add(this.unarmedDamage);
            this.nextDamageCacheEntry = (this.nextDamageCacheEntry + 1) % 49;
            if(this.nextDamageCacheEntry > 50)
            {
               this.nextDamageCacheEntry = 0;
            }
         }
         this.regenerateManaAndEnergy(dt);
         this.cooldownSkills(dt);
         this.gcdRemaining = this.gcdRemaining - dt;
         this.characterDisplay.update(dt);
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
         if(this.isIdle && !this.buffs.hasBuffByName("Idle") && this.hasIdleBonuses)
         {
            idleBuff = new Buff();
            idleBuff.iconId = 168;
            idleBuff.isUntimedBuff = true;
            idleBuff.name = "Idle";
            idleBuff.tickFunction = function():*
            {
               if(!CH2.currentCharacter.isIdle || !CH2.currentCharacter.hasIdleBonuses)
               {
                  idleBuff.isFinished = true;
                  idleBuff.onFinish();
               }
            };
            idleBuff.tooltipFunction = function():Object
            {
               return {
                  "header":"Idle",
                  "body":"When you do not actively attack or activate a skill for " + MS_DELAY_BEFORE_IDLE / 1000 + " seconds you are treated as idle.\n\n" + "When idle you deal " + idleDamageMultiplier * 100 + "% of base damage.\n" + "And receieve " + idleMonsterGoldMultiplier * 100 + "% of base gold."
               };
            };
            this.buffs.addBuff(idleBuff);
         }
         this.buffs.updateBuffs(dt);
         this.updateRubyShopFields(dt);
         if(Math.floor(this.timeOnlineMilliseconds / 3600000) != Math.floor((this.timeOnlineMilliseconds - dt) / 3600000))
         {
            this.sendServerStatsUpdate();
         }
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
            monstersAttacked = CH2.world.monsters.getMonstersInCenter(x,y,attackRange);
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
            IdleHeroUIManager.instance.mainUI.hud.showInsufficientEnergy();
         }
         this.buffs.onClick(null);
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
      
      public function onClickAttackDefault() : void
      {
         var attackData:AttackData = new AttackData();
         attackData.isClickAttack = true;
         attackData.damage = this.clickDamage;
         this.characterDisplay.playClickAttack();
         this.attack(attackData);
      }
      
      public function onTeleportAttackDefault() : void
      {
         var attackData:AttackData = new AttackData();
         attackData.isClickAttack = true;
         attackData.isTeleportAttack = true;
         attackData.damage = this.clickDamage;
         if(!CH2.world.getNextMonster())
         {
            return;
         }
         var previousY:Number = y;
         y = CH2.world.getNextMonster().y - this.attackRange;
         this.changeState(STATE_COMBAT);
         this.characterDisplay.playDash(y - previousY);
         this.attack(attackData);
      }
      
      public function onKilledMonsterDefault(monster:Monster) : void
      {
         var monstersWorthNothing:int = 0;
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
            IdleHeroUIManager.instance.mainUI.hud.update(0);
         }
         if(this.highestMonstersKilled[this.currentWorldId] < monster.zoneSpawned * this.monstersPerZone)
         {
            monstersWorthNothing = this.highestMonstersKilled[this.currentWorldId] - (monster.zoneSpawned - 1) * this.monstersPerZone;
            if(this.monstersKilledOnCurrentZone > monstersWorthNothing)
            {
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
               this.addExperience(Formulas.instance.getMonsterExperience(monster.zoneSpawned,monster.isBoss));
            }
         }
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
      
      public function onWorldFinishedDefault() : void
      {
         var bonusExperience:BigNumber = null;
         var i:int = 0;
         var worldExperience:BigNumber = null;
         var totalMonstersForBonus:Number = NaN;
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
            if(this.currentWorldId > 1)
            {
               bonusExperience = new BigNumber(0);
               for(i = 1; i < this.currentWorldId; i++)
               {
                  worldExperience = Formulas.instance.getMonsterExperienceForWorld(i);
                  totalMonstersForBonus = this.monstersPerZone * 100 - this.highestMonstersKilled[i];
                  worldExperience.timesEqualsN(totalMonstersForBonus);
                  bonusExperience.plusEquals(worldExperience);
                  this.runsCompletedPerWorld[i]++;
                  this.highestMonstersKilled[i] = 0;
               }
               this.addExperience(bonusExperience);
            }
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
         var dmg:BigNumber = this.inventory.getEquippedDamage().add(this.unarmedDamage).multiplyN(this.ancientShardDamageMultiplier).multiplyN(1 + (!!this.powerRuneActivated?POWER_RUNE_DAMAGE_BONUS:0)).multiplyN(this.damageMultiplier).multiply(this.gildedDamageMultiplier);
         if(this.isIdle)
         {
            dmg = dmg.multiplyN(this.idleDamageMultiplier);
         }
         return dmg.floor().max(new BigNumber(1));
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
      
      public function get bossGold() : Number
      {
         return this.getStat(CH2.STAT_BOSS_GOLD);
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
      
      public function setupSkills() : void
      {
         var _loc1_:Skill = null;
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
         for each(_loc1_ in this.skills)
         {
            if(_loc1_.isActive)
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
            IdleHeroUIManager.instance.mainUI.hud.skillBar.skillSlots[slot].skillSlotUI.skill = null;
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
         var id:* = null;
         for(id in this.skills)
         {
            if(this.skills[id].isActive)
            {
               this.skills[id].cooldownRemaining = this.skills[id].cooldownRemaining - dt * CH2.currentCharacter.hasteRating;
            }
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
      
      public function addGoldDefault(goldToAdd:BigNumber) : void
      {
         this.gold = this.gold.add(goldToAdd);
         if(goldToAdd.gtN(0))
         {
            this.totalGold = this.totalGold.add(goldToAdd);
            this.logGold(goldToAdd);
         }
         else
         {
            this.logGoldSpent(goldToAdd.multiplyN(-1));
         }
         if(!this.gold.ltN(0))
         {
         }
         IdleHeroUIManager.instance.refreshGoldDisplays();
      }
      
      public function subtractGold(goldToSubtract:BigNumber) : void
      {
         this.addGold(goldToSubtract.multiplyN(-1));
      }
      
      public function addRubiesDefault(rubiesToAdd:Number, type:String = "", id:String = "") : void
      {
         this.rubies = this.rubies + rubiesToAdd;
         if(rubiesToAdd > 0)
         {
            this.totalRubies = this.totalRubies + rubiesToAdd;
         }
         IdleHeroUIManager.instance.refreshRubiesDisplays();
      }
      
      public function subtractRubies(rubiesToSubtract:Number, type:String = "", id:String = "") : void
      {
         this.addRubies(rubiesToSubtract * -1,type,id);
      }
      
      public function regenerateManaAndEnergyDefault(time:Number) : void
      {
         var timeInSeconds:Number = time / 1000;
         var manaToAdd:Number = timeInSeconds * (1 / SECONDS_FROM_ZERO_TO_FULL_MANA * this.statBaseValues[CH2.STAT_TOTAL_MANA]) * this.manaRegenMultiplier;
         this.addMana(manaToAdd,false);
      }
      
      public function addEnergyDefault(amount:Number, showFloatingText:Boolean = true) : void
      {
         var previousEnergy:Number = this.energy;
         this.energy = this.energy + amount;
         if(this.energy > this.maxEnergy)
         {
            this.energy = this.maxEnergy;
         }
         else if(this.energy < 0)
         {
            this.energy = 0;
         }
         if(amount < 0)
         {
            this.logEnergyUsed(new BigNumber(amount * -1));
         }
         if(this.energy != previousEnergy && showFloatingText)
         {
            if(this.energy > previousEnergy)
            {
               IdleHeroUIManager.instance.mainUI.hud.playEnergyGainedEffect();
            }
            IdleHeroUIManager.instance.mainUI.hud.showEnergyUsed(this.energy - previousEnergy);
         }
      }
      
      public function addManaDefault(amount:Number, showFloatingText:Boolean = true) : void
      {
         var previousMana:Number = this.mana;
         this.mana = this.mana + amount;
         if(this.mana > this.maxMana)
         {
            this.mana = this.maxMana;
         }
         else if(this.mana < 0)
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
               IdleHeroUIManager.instance.mainUI.hud.playManaGainedEffect();
            }
            IdleHeroUIManager.instance.mainUI.hud.showManaUsed(this.mana - previousMana);
         }
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
      
      public function onUsedSkillDefault(skill:Skill) : void
      {
         CH2.currentCharacter.buffs.onSkillUse(skill);
         this.totalSkillsUsed++;
      }
      
      public function levelUpItemDefault(item:Item, amount:Number = 1) : void
      {
         if(this.gold.gte(item.cost(amount)) && !this.isPurchasingLocked)
         {
            this.inputLogger.recordInput(GameActions["LEVEL_UP_ITEM_" + this.inventory.getSlotFromItem(item.uid)],amount);
            this.subtractGold(item.cost(amount));
            item.level = item.level + amount;
            this.inventory.cachedEquippedDamage.base = -1;
            this.excitingUpgradeCheck();
            this.timeSinceLastItemInteraction = 0;
            this.totalUpgradesToItems++;
            IdleHeroUIManager.instance.mainUI.mainPanel.itemsPanel.updateAllEquipAndCatalogSlots();
         }
         else
         {
            Trace("Not enough gold to level item slot " + this.inventory.getSlotFromItem(item.uid) + " " + amount + "x");
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
      }
      
      public function sellItem(index:Number) : void
      {
         this.addGold(this.inventory.getItemInSlot(index).currentSellCost());
         this.inventory.deleteItem(index);
      }
      
      public function purchaseCatalogItemDefault(index:int) : void
      {
         var itemToPurchase:Item = this.catalogItemsForSale[index];
         var itemCost:BigNumber = itemToPurchase.cost();
         if(this.gold.gte(itemCost) && !this.isPurchasingLocked)
         {
            this.eventLogger.logEvent(EventLog.PURCHASED_ITEM);
            this.inputLogger.recordInput(GameActions.PURCHASE_ITEM,index);
            this.subtractGold(itemCost);
            this.inventory.replaceItem(itemToPurchase);
            IdleHeroUIManager.instance.mainUI.mainPanel.itemsPanel.equipSlots[itemToPurchase.type].reloadItemIcon();
            IdleHeroUIManager.instance.mainUI.mainPanel.itemsPanel.equipSlots[itemToPurchase.type].playPurchaseAnimation();
            IdleHeroUIManager.instance.mainUI.mainPanel.itemsPanel.hideBuyGlowOnSlot(CH2.currentCharacter.currentCatalogRank % 8);
            this.currentCatalogRank++;
            this.generateCatalog();
            this.excitingUpgradeCheck();
            IdleHeroUIManager.instance.mainUI.mainPanel.itemsPanel.updateAllEquipAndCatalogSlots();
            IdleHeroUIManager.instance.mainUI.mainPanel.itemsPanel.updateEquipSlotDisplay();
            IdleHeroUIManager.instance.mainUI.mainPanel.itemsPanel.updateCatalogSlot();
            this.timeSinceLastItemInteraction = 0;
            this.totalCatalogItemsPurchased++;
         }
         else
         {
            Trace("Not enough gold to purchase item rank " + this.currentCatalogRank);
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
               _loc5_.init(_loc3_,this.currentCatalogRank + 1,!_loc2_,0,_loc4_.bonuses);
               this.catalogItemsForSale.push(_loc5_);
            }
         }
         while(this.catalogItemsForSale.length < _loc1_)
         {
            _loc5_ = new Item();
            _loc5_.level = 1;
            _loc5_.init(_loc3_,this.currentCatalogRank + 1,!_loc2_);
            if(!_loc2_)
            {
               _loc2_ = _loc5_.isCursed;
            }
            this.catalogItemsForSale.push(_loc5_);
         }
         IdleHeroUIManager.instance.refreshCatalogDisplay();
      }
      
      public function lockItemPurchases() : void
      {
         this.isPurchasingLocked = true;
         IdleHeroUIManager.instance.refreshCatalogDisplay();
      }
      
      public function unlockItemPurchases() : void
      {
         this.isPurchasingLocked = false;
         IdleHeroUIManager.instance.refreshCatalogDisplay();
      }
      
      public function learnTalentDefault(name:String) : void
      {
         var talent:Talent = new Talent();
         talent.name = name;
         talent.apply();
         this.talents.push(talent);
      }
      
      public function walkDefault(dt:Number) : void
      {
         var distanceWalked:Number = this.walkSpeed * (dt / 1000) * ONE_METER_Y_DISTANCE;
         var closestMonster:Monster = CH2.world.getNextMonster();
         var distanceToNextMonster:Number = closestMonster != null?Number(closestMonster.y - this.attackRange - y):Number(1000);
         distanceWalked = Math.min(distanceWalked,distanceToNextMonster);
         y = y + distanceWalked;
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
         return this.getStatAtLevel(statId,this.getStatLevel(statId));
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
         this.hasNewSkillTreePointsAvailable = true;
         this.levelUpStat(CH2.STAT_DAMAGE);
         this.eventLogger.logEvent(EventLog.LEVELED_UP);
         this.characterDisplay.playLevelUp();
         this.addEnergy(this.maxEnergy - this.energy,false);
         IdleHeroUIManager.instance.refreshLevelDisplays();
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
            while(this.gilds < Math.floor(this.level / 200))
            {
               this.addGild();
            }
         }
         if(didLevel)
         {
            IdleHeroUIManager.instance.mainUI.mainPanel.graphPanel.redrawGraph();
            if(IdleHeroUIManager.instance.mainUI.mainPanel.isOnGraphPanel)
            {
               IdleHeroUIManager.instance.mainUI.mainPanel.graphPanel.updateInteractiveLayer();
            }
            this.timeSinceLastLevelUp = 0;
         }
         IdleHeroUIManager.instance.refreshXPDisplays();
         IdleHeroUIManager.instance.refreshWorldStatDisplay();
      }
      
      public function getLevelUpCostToNextLevel(level:Number) : BigNumber
      {
         if(level >= 199)
         {
            return new BigNumber(500000000);
         }
         return new BigNumber(600 + (level - 1) * 500);
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
      
      public function addGild() : void
      {
         this.gilds++;
         this.gildedDamageMultiplier.timesEquals(new BigNumber("2e31"));
         this.statLevels = {};
         this.spentStatPoints = new BigNumber(0);
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
      
      private function shouldRubyShopActivateDefault() : Boolean
      {
         return this.timeSinceLastRubyShopAppearance > RUBY_SHOP_APPEARANCE_COOLDOWN && !CH2.world.isBossZone(this.currentZone) && !this.didFinishWorld && this.totalRubies >= 50;
      }
      
      private function shouldRubyShopDeactivateDefault() : Boolean
      {
         return this.timeSinceLastRubyShopAppearance > RUBY_SHOP_APPEARANCE_DURATION || CH2.world.isBossZone(this.currentZone) || this.didFinishWorld;
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
      
      public function updateRubyShopFieldsDefault(dt:int) : void
      {
         this.timeSinceLastAncientShardPurchase = this.timeSinceLastAncientShardPurchase + dt;
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
         return _("Permanently multiply your damage by x%s.",ANCIENT_SHARD_DAMAGE_BONUS);
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
      
      public function getTimeMetalDetectorDescription() : String
      {
         return _("Increases your gold gained by +%s% for %s.",METAL_DETECTOR_GOLD_BONUS * 100,TimeFormatter.formatTimeDescriptive(METAL_DETECTOR_TIME_DURATION / 1000).replace(" ",""));
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
         return _("Increases your gold gained by +%s% for %s.",METAL_DETECTOR_GOLD_BONUS * 100,_("%s zones",METAL_DETECTOR_ZONE_DURATION));
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
         ItemDropManager.instance.goldSplash(Formulas.instance.getGoldForBagOfGold(),x - 100,y - 250,this,"N",0.25);
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
         this.trackedDps.update(dt);
         this.trackedOverkill.update(dt);
         this.trackedGoldGained.update(dt);
         this.trackedGoldSpent.update(dt);
         this.trackedEnergyUsed.update(dt);
         this.trackedManaUsed.update(dt);
         this.trackedFrameMsec.update(dt);
         this.trackedXPEarned.update(dt);
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
   }
}
