package heroclickerlib.managers
{
   import com.playsaurus.numbers.BigNumber;
   import heroclickerlib.CH2;
   import models.Character;
   import models.Item;
   import models.Monster;
   
   public class Formulas
   {
      
      private static const LN10:Number = 2.30258509299405;
      
      private static var _INSTANCE:Formulas;
      
      public static const STANDARD:Array = [1];
      
      public static const SPIKY_6:Array = [1,1,0.25,1,1,4];
      
      public static const WALL:Array = [0.5,0.5,0.5,8];
      
      public static const SLOW:Array = [0.9];
      
      public static const FAST:Array = [1.05];
      
      public static const WORLD_CURVES:Object = {
         "Standard":STANDARD,
         "Spiky":SPIKY_6,
         "Wall":WALL,
         "Slow":SLOW,
         "Fast":FAST
      };
      
      private static var _cachedCurveList:Array;
      
      public static const BONUS_GOLD_MULTIPLIER:Number = 10;
      
      public static var itemCostLevelFactors:Array = [];
      
      {
         itemCostLevelFactors[1] = 1;
      }
      
      public function Formulas()
      {
         super();
      }
      
      public static function get instance() : Formulas
      {
         if(_INSTANCE == null)
         {
            _INSTANCE = new Formulas();
         }
         return _INSTANCE;
      }
      
      public static function get curveList() : Array
      {
         var curve:* = null;
         if(!_cachedCurveList)
         {
            _cachedCurveList = [];
            for(curve in Formulas.WORLD_CURVES)
            {
               _cachedCurveList.push(curve);
            }
         }
         return _cachedCurveList;
      }
      
      public static function getRandomCurve() : String
      {
         return curveList[CH2.roller.curveRoller.integer(0,_cachedCurveList.length - 1)];
      }
      
      public function multiplierFromCurve(n:Number, curve:Array) : *
      {
         var curveValue:Number = NaN;
         var completeCycles:Number = Math.floor(n / curve.length);
         var remainder:Number = n - completeCycles * curve.length;
         var multiplier:Number = 1;
         for each(curveValue in curve)
         {
            multiplier = multiplier * Math.pow(curveValue,completeCycles);
         }
         while(remainder > 0)
         {
            multiplier = multiplier * curve[remainder - 1];
            remainder--;
         }
         return multiplier;
      }
      
      public function diminishingReturns(scaleValue:Number, params:String = "") : Number
      {
         var paramsArray:Array = params.split(",");
         var limit:Number = Number(paramsArray[0]);
         var exponentScale:Number = Number(paramsArray[1]);
         return limit * (1 - Math.exp(exponentScale * scaleValue));
      }
      
      public function getGoldForZone(zone:Number) : BigNumber
      {
         var monster:Monster = new Monster();
         monster.zoneSpawned = zone;
         return this.monsterGoldFormula(monster);
      }
      
      public function getCurvedMonsterHealth(zone:Number) : BigNumber
      {
         var curveValue:Number = NaN;
         var curve:Array = CH2.currentAscensionWorld.monsterHealthCurve;
         var completeCycles:Number = Math.floor((zone - 1) / curve.length);
         var remainder:Number = zone - 1 - completeCycles * curve.length;
         var multiplier:BigNumber = new BigNumber(1);
         for each(curveValue in curve)
         {
            multiplier = multiplier.multiplyN(Math.pow(1 + 9 * curveValue,completeCycles));
         }
         while(remainder > 0)
         {
            multiplier = multiplier.multiplyN(1 + 9 * curve[remainder - 1]);
            remainder--;
         }
         multiplier.timesEqualsN(10 * CH2.currentCharacter.monsterHealthMultiplier);
         return multiplier;
      }
      
      public function getWorld1MonsterHealth(monster:Monster) : BigNumber
      {
         var character:Character = null;
         var excessKuma:Number = NaN;
         var monsterHealth:BigNumber = this.getCurvedMonsterHealth(monster.zoneSpawned);
         if(monster.isBoss)
         {
            if(monster.zoneSpawned < 20)
            {
               monsterHealth.timesEqualsN(50);
            }
            else
            {
               monsterHealth.timesEqualsN(300);
            }
            monsterHealth = monsterHealth.divideN(CH2.currentCharacter.monsterHealthMultiplier);
         }
         else if(monster.isMiniBoss)
         {
            character = CH2.currentCharacter;
            monsterHealth.timesEqualsN(character.preKumaMonstersPerZone / 3);
            if(character.consecutiveEasyBossesKilled > character.preKumaMonstersPerZone)
            {
               excessKuma = character.consecutiveEasyBossesKilled - character.preKumaMonstersPerZone;
               monsterHealth.timesEqualsN(1 / (1 + 0.1 * excessKuma));
            }
         }
         return monsterHealth;
      }
      
      public function monsterLifeFormula(monster:Monster) : BigNumber
      {
         return this.getWorld1MonsterHealth(monster).multiply(CH2.currentAscensionWorld.monsterHealthMultiplier);
      }
      
      public function monsterGoldFormula(monster:Monster) : BigNumber
      {
         var excessKuma:Number = NaN;
         var character:Character = CH2.currentCharacter;
         var totalGold:BigNumber = this.getWorld1MonsterHealth(monster);
         totalGold = totalGold.multiply(character.monsterGoldMultiplier);
         if(character.isIdle)
         {
            totalGold = totalGold.multiply(character.idleMonsterGoldMultiplier);
         }
         if(monster.zoneSpawned < 5)
         {
            totalGold.timesEqualsN(0.3);
         }
         totalGold.timesEqualsN(0.1);
         if(monster.isMiniBoss)
         {
            if(character.consecutiveEasyBossesKilled > character.preKumaMonstersPerZone)
            {
               excessKuma = character.consecutiveEasyBossesKilled - character.preKumaMonstersPerZone;
               totalGold.timesEqualsN(1 + 0.1 * excessKuma);
            }
         }
         totalGold = totalGold.ceil();
         if(monster.isTreasureChest)
         {
            totalGold.timesEqualsN(5);
            totalGold.timesEquals(character.treasureChestGold);
            if(character.treasureChestsAreMonsters)
            {
               totalGold.timesEquals(character.monsterGold);
            }
            if(character.treasureChestsHaveClickableGold)
            {
               totalGold.timesEquals(character.clickableGold);
            }
         }
         else
         {
            totalGold.timesEquals(character.monsterGold);
         }
         if(monster.isBoss)
         {
            totalGold.timesEqualsN(0.1);
         }
         if(character.zoneMetalDetectorActive)
         {
            totalGold.timesEqualsN(Character.METAL_DETECTOR_GOLD_BONUS);
         }
         if(character.timeMetalDetectorActive)
         {
            totalGold.timesEqualsN(Character.METAL_DETECTOR_GOLD_BONUS);
         }
         if(monster.bonusGoldRandomThresholdValue < character.bonusGoldChance.numberValue())
         {
            totalGold = totalGold.multiplyN(BONUS_GOLD_MULTIPLIER);
         }
         return totalGold;
      }
      
      public function getBaseGoldDroppedFromHighestZoneReachedMonster() : BigNumber
      {
         return this.getCurvedMonsterHealth(CH2.currentCharacter.highestZone);
      }
      
      public function getNumVisualCoinsForGoldDropAmount(goldAmount:BigNumber) : int
      {
         var totalGold:BigNumber = CH2.currentCharacter.totalGold;
         var coinCountBN:BigNumber = goldAmount.divide(totalGold.addN(1)).multiplyN(200).sqrt().multiplyN(1.5);
         var coinCountInt:int = 0;
         if(totalGold.numberValue() < 64 && goldAmount.numberValue() < 64)
         {
            coinCountInt = goldAmount.numberValue();
         }
         else if(coinCountBN.gtN(100))
         {
            coinCountInt = 100;
         }
         else
         {
            coinCountInt = coinCountBN.numberValue();
         }
         return Math.max(1,coinCountInt);
      }
      
      public function getPartialGoldRewardForBossDamage(boss:Monster, healthDropPercentage:Number) : BigNumber
      {
         return this.monsterGoldFormula(boss).multiplyN(healthDropPercentage);
      }
      
      public function getGoldForBagOfGold() : BigNumber
      {
         return CH2.currentCharacter.totalGold.multiplyN(0.1).max(new BigNumber(1));
      }
      
      public function getItemDamage(item:Item) : BigNumber
      {
         return CH2.currentCharacter.getItemDamage(item);
      }
      
      public function nextItemMultiplier(item:Item) : int
      {
         var nextMultipleOfTenLevel:int = (int(item.level / 10) + 1) * 10;
         var multiplier:Number = CH2.currentCharacter.item10LvlDmgMultiplier;
         if(nextMultipleOfTenLevel == 100)
         {
            multiplier = multiplier * CH2.currentCharacter.item100LvlDmgMultiplier;
         }
         if(nextMultipleOfTenLevel == 50)
         {
            multiplier = multiplier * CH2.currentCharacter.item50LvlDmgMultiplier;
         }
         if(nextMultipleOfTenLevel % 20 == 0)
         {
            multiplier = multiplier * CH2.currentCharacter.item20LvlDmgMultiplier;
         }
         return multiplier;
      }
      
      public function getOldItemCost(item:Item) : BigNumber
      {
         return new BigNumber(item.baseCost.multiplyN(Math.pow(1.1,item.level - 1)).floor());
      }
      
      public function getItemCostLevelFactor(level:Number) : Number
      {
         if(itemCostLevelFactors[level] != null)
         {
            return itemCostLevelFactors[level];
         }
         return this.getItemCostLevelFactor(level - 1) * (level * 0.005 + 1.1);
      }
      
      public function getItemCost(worldCost:BigNumber, level:Number) : BigNumber
      {
         var cost:BigNumber = new BigNumber(worldCost);
         cost.timesEqualsN(Math.pow(1.16,level - 1));
         cost.floorInPlace();
         return cost;
      }
      
      public function getItemWorldCost(rank:Number, curve:Array, worldCostMultiplier:BigNumber) : BigNumber
      {
         var curveLength:uint = curve.length;
         var rankFactorial:BigNumber = new BigNumber(1);
         var i:int = 2;
         while(i <= rank)
         {
            rankFactorial.timesEqualsN(1 + (i + 10) * curve[i % curveLength]);
            i++;
         }
         rankFactorial.timesEqualsN(10);
         rankFactorial.timesEquals(worldCostMultiplier);
         rankFactorial.timesEqualsN(Math.pow(10000,Math.floor((rank - 1) / 8)));
         return rankFactorial;
      }
      
      public function getItemBaseCost(rank:Number) : BigNumber
      {
         var rankFactorial:BigNumber = new BigNumber(1);
         var i:int = rank;
         while(i > 1)
         {
            rankFactorial.timesEqualsN(i + 11);
            i--;
         }
         rankFactorial.timesEqualsN(10);
         rankFactorial.timesEqualsN(Math.pow(10000,Math.floor((rank - 1) / 8)));
         return rankFactorial;
      }
      
      public function getItemBonusUpgradeCost() : BigNumber
      {
         var monstersKilledForBlacksmithBonus:Number = 2;
         return this.getBaseGoldDroppedFromHighestZoneReachedMonster().multiplyN(monstersKilledForBlacksmithBonus);
      }
      
      public function itemPawnSalePrice() : BigNumber
      {
         return this.getGoldForZone(CH2.currentCharacter.highestZone);
      }
      
      public function getPotionPrice() : BigNumber
      {
         var monsterKilledForPotion:int = 1;
         return this.getBaseGoldDroppedFromHighestZoneReachedMonster().multiplyN(monsterKilledForPotion);
      }
      
      public function getScrollPrice() : BigNumber
      {
         var monsterKilledForScroll:int = 3;
         return this.getBaseGoldDroppedFromHighestZoneReachedMonster().multiplyN(monsterKilledForScroll);
      }
      
      public function getAscensionWorldExperienceMultiplier(worldNumber:int) : BigNumber
      {
         return new BigNumber((worldNumber + 1) / 2);
      }
      
      public function getMonsterExperienceForWorld(worldId:int) : BigNumber
      {
         var result:BigNumber = CH2.currentCharacter.worlds.getWorld(worldId).experienceMultiplier.multiplyN(150).divideN(CH2.currentCharacter.preKumaMonstersPerZone).multiplyN(Math.pow(0.984274,CH2.currentCharacter.runsCompletedPerWorld[worldId]));
         if(CH2.currentCharacter.runsCompletedPerWorld[worldId] >= 7)
         {
            result.timesEqualsN(0.05);
         }
         return result;
      }
      
      public function getMonsterExperience(param1:Monster) : BigNumber
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc2_:Character = CH2.currentCharacter;
         var _loc3_:Number = _loc2_.level;
         var _loc4_:Number = CH2.currentAscensionWorld.worldNumber;
         var _loc5_:BigNumber = new BigNumber(Math.floor(10 + param1.level / 5));
         if(_loc3_ > 50)
         {
            if(_loc3_ <= param1.level)
            {
               _loc6_ = _loc2_.getStarSystem(_loc2_.worlds.getWorld(_loc4_).starSystemId).getDifficulty();
               _loc7_ = 1 / Math.pow(_loc6_,0.2);
               _loc5_.timesEqualsN(Math.pow(_loc7_,_loc3_ - param1.level));
               if(param1.level > _loc3_)
               {
                  _loc5_.timesEqualsN(1 + (param1.level + 1 - _loc3_) * 0.05);
               }
            }
            else
            {
               _loc6_ = _loc2_.getStarSystem(_loc2_.worlds.getWorld(_loc4_).starSystemId).getDifficulty();
               _loc7_ = 1 / Math.pow(_loc6_,0.2);
               _loc5_.timesEqualsN(Math.pow(_loc7_,_loc3_ - param1.level));
               _loc5_.timesEqualsN(1 / (1 + (_loc3_ + 1 - param1.level) * 0.05));
            }
         }
         if(param1.isBoss)
         {
            _loc5_.timesEqualsN(50);
         }
         else
         {
            _loc5_.timesEqualsN(50 / _loc2_.preKumaMonstersPerZone);
         }
         return _loc5_;
      }
      
      public function getZoneExperience(zone:int) : BigNumber
      {
         return CH2.currentAscensionWorld.experienceMultiplier.multiplyN(150);
      }
      
      public function getWorldExperience() : BigNumber
      {
         var points:BigNumber = new BigNumber(0);
         for(var i:int = 0; i < 100; i++)
         {
            points.plusEquals(this.getZoneExperience(i));
         }
         return points;
      }
      
      public function getWorldDifficulty(worldNumber:Number) : BigNumber
      {
         var currentSystem:Number = NaN;
         var currentGrowthRate:Number = NaN;
         var i:int = 0;
         var character:Character = CH2.currentCharacter;
         if(worldNumber == 1)
         {
            return new BigNumber(1);
         }
         var gildNumber:Number = Math.floor(worldNumber / CH2.currentCharacter.worldsPerSystem);
         var difficultyScale:BigNumber = new BigNumber(1.2);
         if(worldNumber > 2)
         {
            currentSystem = 1;
            currentGrowthRate = character.getStarSystem(currentSystem).getDifficulty();
            for(i = 3; i <= worldNumber; i++)
            {
               if(i % character.worldsPerSystem == 1)
               {
                  currentSystem++;
                  currentGrowthRate = character.getStarSystem(currentSystem).getDifficulty();
               }
               difficultyScale.timesEqualsN(currentGrowthRate);
            }
         }
         return difficultyScale;
      }
      
      public function getHeroSoulsForSystem(systemId:int) : BigNumber
      {
         var result:BigNumber = new BigNumber(1.15);
         result = result.pow(systemId);
         result.timesEqualsN(5 * systemId);
         result = result.ceil();
         return result;
      }
      
      public function getStatPointsEarnedAtLevel(level:Number) : BigNumber
      {
         if(level == 1)
         {
            return new BigNumber(0);
         }
         level = level % 100;
         if(level == 0)
         {
            return new BigNumber(0);
         }
         return new BigNumber(Math.pow(2,1 + (level + 15) / 5)).ceil();
      }
      
      public function getTotalStatPoints(characterLevel:Number) : BigNumber
      {
         if(characterLevel < 200)
         {
            return new BigNumber(characterLevel % 200 - 1);
         }
         return new BigNumber(characterLevel % 200);
      }
   }
}
