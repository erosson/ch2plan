package
{
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	import heroclickerlib.CH2;
	import com.playsaurus.model.Model;
	import heroclickerlib.managers.SoundManager;
	import heroclickerlib.world.CharacterDisplay;
	import models.Skill;
	import models.Buff;
	import models.Characters;
	import models.Character;
	import models.Monster;
	import models.Talent;
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
	
	public class WizardMain extends Sprite
	{
		public static const CHARACTER_NAME:String = "Wizard";
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
			
			wizard.name = "Wizard";
			wizard.flavorName = "???"
			wizard.flavorClass = "The Cursed Wizard"
			wizard.flavor = "Coming Soon!";
			wizard.gender = "Wizard";
			wizard.flair = "Wizard";
			wizard.characterSelectOrder = 2;
			wizard.availableForCreation = false;
			wizard.visibleOnCharacterSelect = true;
			wizard.defaultSaveName = "wizard";
			
			wizard.upgradeableStats = Character.DEFAULT_UPGRADEABLE_STATS;
			
			Characters.startingDefaultInstances[wizard.name] = wizard;
		}
		
		public function onStaticDataLoaded():void
		{
			
		}
		
		public function onUserDataLoaded():void
		{
			
		}
		
		public function onCharacterCreated(characterInstance:Character):void
		{
			characterInstance.onCharacterDisplayCreated = setUpDisplay;
			characterInstance.onUsedSkill = onSkillUsed;
		}
		
		public function onSkillUsed(skill:Skill):void
		{
			
		}
		
		public function setUpDisplay(display:CharacterDisplay):void
		{

		}
	}
}