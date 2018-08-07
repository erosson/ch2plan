package heroclickerlib.managers
{
   import com.playsaurus.numbers.BigNumber;
   import com.playsaurus.utils.CurrentUser;
   import heroclickerlib.CH2;
   import models.Character;
   import models.Item;
   import models.Monster;
   import models.UserData;
   
   public class Formulas
   {
      
      private static const LN10:Number = 2.30258509299405;
      
      private static var _INSTANCE:Formulas;
      
      public static const STANDARD:Array = [1];
      
      public static const SPIKY_6:Array = [1,1,0.25,1,1,4];
      
      public static const WALL:Array = [0.5,0.5,0.5,8];
      
      public static const SLOW:Array = [0.9];
      
      public static const FAST:Array = [1.1];
      
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
      
      private function get _user() : UserData
      {
         return CurrentUser.instance as UserData;
      }
      
      private function get _character() : Character
      {
         return this._user.currentCharacter;
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
         var monsterHealth:BigNumber = this.getCurvedMonsterHealth(monster.zoneSpawned);
         if(monster.isBoss)
         {
            if(monster.zoneSpawned < 20)
            {
               monsterHealth.timesEqualsN(50);
            }
            else
            {
               monsterHealth.timesEqualsN(150);
            }
            monsterHealth = monsterHealth.divideN(CH2.currentCharacter.monsterHealthMultiplier);
         }
         else if(monster.isMiniBoss)
         {
            monsterHealth.timesEqualsN(15);
         }
         return monsterHealth;
      }
      
      public function monsterLifeFormula(monster:Monster) : BigNumber
      {
         return this.getWorld1MonsterHealth(monster).multiply(CH2.currentAscensionWorld.monsterHealthMultiplier);
      }
      
      public function monsterGoldFormula(monster:Monster) : BigNumber
      {
         var totalGold:BigNumber = this.getWorld1MonsterHealth(monster);
         totalGold = totalGold.multiplyN(this._character.monsterGoldMultiplier);
         if(this._character.isIdle)
         {
            totalGold = totalGold.multiplyN(this._character.idleMonsterGoldMultiplier);
         }
         if(monster.zoneSpawned < 5)
         {
            totalGold.timesEqualsN(0.3);
         }
         totalGold.timesEqualsN(0.1);
         totalGold = totalGold.ceil();
         if(monster.name == Monster.TREASURE_CHEST_NAME)
         {
            totalGold.timesEqualsN(5);
            totalGold.timesEqualsN(CH2.currentCharacter.treasureChestGold);
         }
         if(monster.isBoss)
         {
            totalGold.timesEqualsN(0.1);
            totalGold.timesEqualsN(CH2.currentCharacter.bossGold);
         }
         if(CH2.currentCharacter.zoneMetalDetectorActive)
         {
            totalGold.timesEqualsN(Character.METAL_DETECTOR_GOLD_BONUS);
         }
         if(CH2.currentCharacter.timeMetalDetectorActive)
         {
            totalGold.timesEqualsN(Character.METAL_DETECTOR_GOLD_BONUS);
         }
         if(CH2.roller.miscRoller.boolean(this._character.bonusGoldChance))
         {
            totalGold = totalGold.multiplyN(BONUS_GOLD_MULTIPLIER);
         }
         return totalGold;
      }
      
      public function getBaseGoldDroppedFromHighestZoneReachedMonster() : BigNumber
      {
         return this.getCurvedMonsterHealth(this._character.highestZone);
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
         if(item.skills.length > 0)
         {
            return new BigNumber(0);
         }
         var result:BigNumber = item.baseCost.divideN(30);
         result.timesEqualsN(Math.pow(0.86,item.rank - 1));
         result.timesEqualsN(1 + item.bonusDamage);
         if(item.rank < 4)
         {
            result.timesEqualsN(5 - item.rank);
         }
         result = result.floor();
         result.timesEqualsN(item.level);
         result.timesEqualsN(Math.pow(CH2.currentCharacter.item10LvlDmgMultiplier,Math.floor(item.level / 10)));
         result.timesEqualsN(Math.pow(CH2.currentCharacter.item20LvlDmgMultiplier,Math.floor(item.level / 20)));
         if(item.level >= 50)
         {
            result.timesEqualsN(CH2.currentCharacter.item50LvlDmgMultiplier);
            if(item.level >= 100)
            {
               result.timesEqualsN(CH2.currentCharacter.item100LvlDmgMultiplier);
            }
         }
         result.timesEqualsN(CH2.currentCharacter.getMultiplierForItemType(item.type));
         return result;
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
         cost = cost.floor();
         cost.timesEqualsN(this._character.itemCostReduction);
         return cost;
      }
      
      public function getItemWorldCost(rank:Number) : BigNumber
      {
         var curve:Array = CH2.currentAscensionWorld.itemCostCurve;
         var curveLength:uint = curve.length;
         var rankFactorial:BigNumber = new BigNumber(1);
         var i:int = 2;
         while(i <= rank)
         {
            rankFactorial.timesEqualsN(1 + (i + 10) * curve[i % curveLength]);
            i++;
         }
         rankFactorial.timesEqualsN(10);
         rankFactorial.timesEquals(CH2.currentAscensionWorld.costMultiplier);
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
         return this.getGoldForZone(this._character.highestZone);
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
      
      public function getAscensionExperience() : BigNumber
      {
         var points:BigNumber = new BigNumber(500000);
         points.timesEquals(CH2.currentAscensionWorld.experienceMultiplier);
         return points;
      }
      
      public function getMonsterExperienceForWorld(worldId:int) : BigNumber
      {
         return CH2.user.ascensionWorlds.getWorld(worldId).experienceMultiplier.multiplyN(500).divideN(CH2.currentCharacter.monstersPerZone).multiplyN(Math.pow(0.65,CH2.currentCharacter.runsCompletedPerWorld[worldId]));
      }
      
      public function getMonsterExperience(zone:int, isBoss:Boolean) : BigNumber
      {
         if(!CH2.currentCharacter.isOnHighestZone)
         {
            return new BigNumber(0);
         }
         var zoneExperience:BigNumber = this.getZoneExperience(zone).multiplyN(Math.pow(0.65,CH2.currentCharacter.runsCompletedPerWorld[CH2.currentAscensionWorld.worldNumber]));
         if(isBoss)
         {
            return zoneExperience;
         }
         return zoneExperience.divideN(CH2.currentCharacter.monstersPerZone);
      }
      
      public function getZoneExperience(zone:int) : BigNumber
      {
         return CH2.currentAscensionWorld.experienceMultiplier.multiplyN(500);
      }
      
      public function getZoneExperienceOld(zone:int) : BigNumber
      {
         var points:BigNumber = this.getAscensionExperience();
         if(zone == 1)
         {
            points.timesEqualsN(0.0001);
            return points;
         }
         points.timesEqualsN((zone - 1) * 0.0002 + 0.0001);
         return points;
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
         return new BigNumber(characterLevel % 200 - 1);
      }
   }
}
