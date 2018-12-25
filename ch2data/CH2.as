package heroclickerlib
{
   import heroclickerlib.managers.CH2AssetManager;
   import heroclickerlib.managers.SaveManager;
   import heroclickerlib.world.Rooms;
   import heroclickerlib.world.World;
   import models.AscensionWorld;
   import models.Character;
   import models.Environment;
   import models.Keybindings;
   import models.Roller;
   import models.UserData;
   
   public class CH2
   {
      
      public static const DEFAULT_CHARACTER_NAME:String = "Helpful Adventurer";
      
      public static const DEFAULT_WORLD_ID:int = 1;
      
      public static const MULTIPLICATIVE:int = 1;
      
      public static const ADDITIVE:int = 2;
      
      public static const STAT_GOLD:int = 0;
      
      public static const STAT_MOVEMENT_SPEED:int = 1;
      
      public static const STAT_CRIT_CHANCE:int = 2;
      
      public static const STAT_CRIT_DAMAGE:int = 3;
      
      public static const STAT_HASTE:int = 4;
      
      public static const STAT_MANA_REGEN:int = 5;
      
      public static const STAT_IDLE_GOLD:int = 6;
      
      public static const STAT_IDLE_DAMAGE:int = 7;
      
      public static const STAT_CLICKABLE_GOLD:int = 8;
      
      public static const STAT_CLICK_DAMAGE:int = 9;
      
      public static const STAT_TREASURE_CHEST_CHANCE:int = 10;
      
      public static const STAT_MONSTER_GOLD:int = 11;
      
      public static const STAT_ITEM_COST_REDUCTION:int = 12;
      
      public static const STAT_TOTAL_MANA:int = 13;
      
      public static const STAT_TOTAL_ENERGY:int = 14;
      
      public static const STAT_CLICKABLE_CHANCE:int = 15;
      
      public static const STAT_BONUS_GOLD_CHANCE:int = 16;
      
      public static const STAT_TREASURE_CHEST_GOLD:int = 17;
      
      public static const STAT_PIERCE_CHANCE:int = 18;
      
      public static const STAT_ENERGY_REGEN:int = 19;
      
      public static const STAT_DAMAGE:int = 20;
      
      public static const STAT_ENERGY_COST_REDUCTION:int = 21;
      
      public static const STAT_ITEM_WEAPON_DAMAGE:int = 22;
      
      public static const STAT_ITEM_HEAD_DAMAGE:int = 23;
      
      public static const STAT_ITEM_CHEST_DAMAGE:int = 24;
      
      public static const STAT_ITEM_RING_DAMAGE:int = 25;
      
      public static const STAT_ITEM_LEGS_DAMAGE:int = 26;
      
      public static const STAT_ITEM_HANDS_DAMAGE:int = 27;
      
      public static const STAT_ITEM_FEET_DAMAGE:int = 28;
      
      public static const STAT_ITEM_BACK_DAMAGE:int = 29;
      
      public static const STAT_AUTOMATOR_SPEED:int = 30;
      
      public static var STATS:Array = new Array();
      
      public static const COMPARISON_LT:int = 0;
      
      public static const COMPARISON_LTE:int = 1;
      
      public static const COMPARISON_EQ:int = 2;
      
      public static const COMPARISON_GTE:int = 3;
      
      public static const COMPARISON_GT:int = 4;
      
      public static const COMPARISON_NEQ:int = 5;
      
      public static var game:IdleHeroMain;
      
      public static var user:UserData = null;
      
      public static var currentCharacter:Character = null;
       
      
      public function CH2()
      {
         super();
      }
      
      public static function initStats() : *
      {
         STATS[STAT_GOLD] = {
            "displayName":"Gold Received",
            "description":"Multiplies your gold received from all sources by x%s.",
            "amountOnItems":0.1,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":true,
            "iconId":95,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_MOVEMENT_SPEED] = {
            "displayName":"Movement Speed",
            "description":"Multiplies your movement speed by x%s.",
            "amountOnItems":0.05,
            "itemDamageBoost":0.4,
            "appearsInAllItemSlots":false,
            "iconId":1,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_CRIT_CHANCE] = {
            "displayName":"Critical Chance",
            "description":"Increases your chance to score a critical hit by %s%.",
            "amountOnItems":0.02,
            "itemDamageBoost":0.2,
            "appearsInAllItemSlots":true,
            "iconId":70,
            "calculationType":ADDITIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_CRIT_DAMAGE] = {
            "displayName":"Critical Damage",
            "description":"Multiplies the damage of your critical hits by x%s.",
            "amountOnItems":0.2,
            "itemDamageBoost":0.2,
            "appearsInAllItemSlots":true,
            "iconId":81,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_HASTE] = {
            "displayName":"Haste",
            "description":"Multiplies your auto-attack and cooldown speeds by x%s.",
            "amountOnItems":0.05,
            "itemDamageBoost":0.3,
            "appearsInAllItemSlots":true,
            "iconId":1,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_IDLE_GOLD] = {
            "displayName":"Idle Gold",
            "description":"Multiplies your gold received by x%s while idle.",
            "amountOnItems":0.25,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":1,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_IDLE_DAMAGE] = {
            "displayName":"Idle Damage",
            "description":"Multiplies your damage by x%s while idle.",
            "amountOnItems":0.25,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":1,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_CLICKABLE_GOLD] = {
            "displayName":"Clickable Gold",
            "description":"Multiplies your gold received from clickables by x%s.",
            "amountOnItems":0.5,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":true,
            "iconId":1,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_CLICK_DAMAGE] = {
            "displayName":"Click Damage",
            "description":"Multiplies your click damage by x%s.",
            "amountOnItems":0.1,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":true,
            "iconId":8,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_MONSTER_GOLD] = {
            "displayName":"Monster Gold",
            "description":"Multiplies your gold received from monsters by x%s.",
            "amountOnItems":0.12,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":true,
            "iconId":1,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_ITEM_COST_REDUCTION] = {
            "displayName":"Item Cost Reduction",
            "description":"Reduces the cost of buying and leveling items by %s.",
            "amountOnItems":0.1,
            "itemDamageBoost":0.4,
            "appearsInAllItemSlots":false,
            "iconId":1,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_TOTAL_MANA] = {
            "displayName":"Total Mana",
            "description":"Increases the size of your mana pool %s.",
            "amountOnItems":25,
            "itemDamageBoost":0.3,
            "appearsInAllItemSlots":true,
            "iconId":1,
            "calculationType":ADDITIVE,
            "formattingFunction":unformatted
         };
         STATS[STAT_MANA_REGEN] = {
            "displayName":"Mana Regeneration",
            "description":"Increases your mana regeneration by %s.",
            "amountOnItems":0.05,
            "itemDamageBoost":0.3,
            "appearsInAllItemSlots":true,
            "iconId":1,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_TOTAL_ENERGY] = {
            "displayName":"Total Energy",
            "description":"Increases the size of your energy pool by %s.",
            "amountOnItems":25,
            "itemDamageBoost":0.3,
            "appearsInAllItemSlots":true,
            "iconId":1,
            "calculationType":ADDITIVE,
            "formattingFunction":unformatted
         };
         STATS[STAT_CLICKABLE_CHANCE] = {
            "displayName":"Gold Piles",
            "description":"Increases number of gold piles found by %s.",
            "amountOnItems":0.1,
            "itemDamageBoost":0.1,
            "appearsInAllItemSlots":true,
            "iconId":1,
            "calculationType":ADDITIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_BONUS_GOLD_CHANCE] = {
            "displayName":"Bonus Gold Chance",
            "description":"Increases your chance of finding bonus gold by %s.",
            "amountOnItems":0.01,
            "itemDamageBoost":0.2,
            "appearsInAllItemSlots":true,
            "iconId":1,
            "calculationType":ADDITIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_TREASURE_CHEST_CHANCE] = {
            "displayName":"Treasure Chest Chance",
            "description":"Increases the chance of finding a treasure chest by %s.",
            "amountOnItems":0.01,
            "itemDamageBoost":0.3,
            "appearsInAllItemSlots":true,
            "iconId":1,
            "calculationType":ADDITIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_TREASURE_CHEST_GOLD] = {
            "displayName":"Treasure Chest Gold",
            "description":"Multiplies your gold received from treasure chests by x%s.",
            "amountOnItems":0.25,
            "itemDamageBoost":0.2,
            "appearsInAllItemSlots":true,
            "iconId":1,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_PIERCE_CHANCE] = {
            "displayName":"Pierce Chance",
            "description":"Increases your chance to hit an additional monster by %s.",
            "amountOnItems":0.01,
            "itemDamageBoost":0.3,
            "appearsInAllItemSlots":false,
            "iconId":1,
            "calculationType":ADDITIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_ENERGY_REGEN] = {
            "displayName":"Energy Regeneration",
            "description":"Increases regenerated energy by %s.",
            "amountOnItems":0,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":1,
            "calculationType":ADDITIVE,
            "formattingFunction":unformatted
         };
         STATS[STAT_DAMAGE] = {
            "displayName":"Damage",
            "description":"Multiplies your damage by x%s.",
            "amountOnItems":0.25,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":95,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_ENERGY_COST_REDUCTION] = {
            "displayName":"Energy Cost Reduction",
            "description":"Reduces the energy cost of your skills by %s%.",
            "amountOnItems":0.25,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":95,
            "calculationType":ADDITIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_ITEM_WEAPON_DAMAGE] = {
            "displayName":"",
            "description":"",
            "amountOnItems":0.25,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":95,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_ITEM_HEAD_DAMAGE] = {
            "displayName":"",
            "description":"",
            "amountOnItems":0.25,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":95,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_ITEM_CHEST_DAMAGE] = {
            "displayName":"",
            "description":"",
            "amountOnItems":0.25,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":95,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_ITEM_RING_DAMAGE] = {
            "displayName":"",
            "description":"",
            "amountOnItems":0.25,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":95,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_ITEM_LEGS_DAMAGE] = {
            "displayName":"",
            "description":"",
            "amountOnItems":0.25,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":95,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_ITEM_HANDS_DAMAGE] = {
            "displayName":"",
            "description":"",
            "amountOnItems":0.25,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":95,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_ITEM_FEET_DAMAGE] = {
            "displayName":"",
            "description":"",
            "amountOnItems":0.25,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":95,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_ITEM_BACK_DAMAGE] = {
            "displayName":"",
            "description":"",
            "amountOnItems":0.25,
            "itemDamageBoost":0,
            "appearsInAllItemSlots":false,
            "iconId":95,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
         STATS[STAT_AUTOMATOR_SPEED] = {
            "displayName":"Automator Speed",
            "description":"Increases the speed of your automator pointer by x%s.",
            "amountOnItems":0.25,
            "itemDamageBoost":0.05,
            "appearsInAllItemSlots":false,
            "iconId":1,
            "calculationType":MULTIPLICATIVE,
            "formattingFunction":percentFormat
         };
      }
      
      public static function percentFormat(statValue:Number) : String
      {
         statValue = Math.round(statValue * 10000);
         if(statValue % 100 == 0)
         {
            return Number(statValue / 100).toFixed(0) + "%";
         }
         if(statValue % 100 == 10)
         {
            return Number(statValue / 100).toFixed(1) + "%";
         }
         return Number(statValue / 100).toFixed(2) + "%";
      }
      
      public static function unformatted(statValue:Number) : String
      {
         return String(statValue);
      }
      
      public static function get userIsInitialized() : Boolean
      {
         return user != null;
      }
      
      public static function get world() : World
      {
         return game.world;
      }
      
      public static function get rooms() : Rooms
      {
         return game.world.rooms;
      }
      
      public static function get currentEnvironment() : Environment
      {
         return currentAscensionWorld.getEnvironmentForZone(currentCharacter.currentZone);
      }
      
      public static function get currentAscensionWorld() : AscensionWorld
      {
         return currentCharacter.currentWorld;
      }
      
      public static function get keyBindings() : Keybindings
      {
         return user.keyBindings;
      }
      
      public static function get roller() : Roller
      {
         return currentCharacter.roller;
      }
      
      public static function changeCharacter(saveName:String) : void
      {
         if(currentCharacter)
         {
            SaveManager.instance.save();
            if(currentCharacter.characterDisplay)
            {
               currentCharacter.characterDisplay.characterUI.removeAll();
            }
            currentCharacter.onCharacterUnloaded();
            CH2AssetManager.instance.disposeCharacter();
         }
         if(world)
         {
            world.disposeFloatingClickables();
         }
         user.currentCharacterName = saveName;
         currentCharacter = user.saves[user.currentCharacterName];
         currentCharacter.onCharacterLoaded();
         currentCharacter.setUpgradeToNextMultiplier(currentCharacter.shouldLevelToNextMultiplier);
         currentCharacter.setupRoller();
         currentCharacter.setupSkills();
         currentCharacter.setupSkillTree();
         currentCharacter.setupTrackedStats();
         currentCharacter.populateRubyPurchaseOptions();
         currentCharacter.populateWorldEndAutomationOptions();
         currentCharacter.populateTutorials();
         currentCharacter.automator.setupInventories();
         for(var i:int = 0; i < currentCharacter.startingSkills.length; i++)
         {
            currentCharacter.activateSkill(currentCharacter.startingSkills[i]);
         }
         if(currentCharacter.hasNeverStartedWorld)
         {
            currentCharacter.startWorld(DEFAULT_WORLD_ID);
            currentCharacter.energy = currentCharacter.maxEnergy;
            currentCharacter.mana = currentCharacter.maxMana;
         }
         game.doGameStateAction(IdleHeroMain.ACTION_PLAYER_SWITCHED_CHARACTERS);
         currentCharacter.applyPurchasedNodes();
      }
   }
}
