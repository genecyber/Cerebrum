/*

Priest learning routine
This is my first attempt in any type of programming.  Thought it would be a great project to learn.
I Looked at a ton of peoples code to come up with this.  Much appreciation to all those that are smarter than I.(ie  Glave, sm0k3d, HarryBotter.... well pretty much everyone in the forums :P)



Change Log

v2.31 (Apoc)

-Fixed the pull range. Now works perfectly. (Will still studder if the mob is moving enough, but oh well. This is as good as it's gonna get w/o skipping the pullpulse all together)
-Fixed the ShadowformRemove method (again) in combat healing should be faster now.

v2.3 (Apoc)

-Took out Scroll use for the time being. (I'll get to it next version)
-Fixed the Inner Focus GUI error. (Thx Kazy)
-Fixed the Renew problem. :)
-Fixed a problem where the toon would run into the mob instead of up to PullRange and stop. 
-Various other fixes that I noticed.

v2.2 (Apoc)

-A TON of changes made. 
-Dangerlvl and Flee routines added. (Thx Ritz for letting me steal your code)
-Fixed problems with pull spells.
-Fixed studder stepping while pulling. (Cast>moveforward>cast>moveforward) You can change how close to be when the pull check is TRUE. (Change it in the Routine. [PullRange])
-Removed "Renew" from the custom heals tab until I can find a solid way to get around the problems with it. (Adding in a wait timer and checks if you're already buffed with it just isn't enough apparently)
-A start to a "better" dispelling/decursing system. (Uncomment the code if you want to try it out ;))
-The canBuff member added to make life alot easier for me, and any others who decide to steal it for buffing.
-Inner Focus added, but GUI problem still persists. (Need to make sure it's checked every time you load OB.)
-Many many many other changes.

v2.12 (Edits by Apoc)

-Fixed typos in the CustomAtk functions. (Was constantly referring to SpellOne instead of SpellTwo-Six)
-Fixed an "if" statement on line 588 (Thanks for pointing that out Crowley)
-Will now properly remove shadowform if a holy spell is used for a custom attack spell.

v2.11 (Edits by Apoc)

-Added in silence (duh!)
-Added in MindFlayRunners. How this works: It checks if ${Me.Target.Target(exists)} && ${Me.InCombat} && ${Target.PctHPs} <= 40. This is to make sure that we're not accidentally mind flaying a non running mob. It checks to make sure that our current target HAS NO TARGET! (Thanks to Risky for pointing out that CHAT_MSG_MONSTER_EMOTE was a bad idea, and if the mob is running they should have no target)
-Added in GUI checkboxes for both, as with the rest of the routine, they can only be casted if the toon can cast said spell.
-A few other minor fixes. (Mainly my own typo's with the GUI saving with SW:D and others)
-Added Holy Fire as a pull spell. (Oops?)
-Added more racial abilities. (WotF, and BE abilities. Trolls and dwarves, reroll to a better class thx!)

v2.1b (Edits by Apoc)

-Fixed logic in RestHeal. Shouldn't burn mana now.
-Added a GUI slider for SpiritTapMP. Lowbies may want to set this lower.

v2.1 (Edits by Apoc)

-Fixed Bandage Support (Did not want to actually bandage when health was low)
-Added a check for "Renew" in the CombatBuff pulse when "Renew" is picked as a heal. (Keeps the bot from constantly casting renew till oom)
-Fixed a few typos, and logic errors.
-Fixed a GUI error where a button was misplaced.
-Removed the method RestHealMe and just added it straight to the RestPulse. Should either flash heal, or renew when in downtime before eating.
-Numerous other fixes that I don't feel like listing.

v2 (Edits by Apoc)

-Fixed SW:P and VE in CombatBuff pulse to stop the bot from hanging when called.
-Added in support for Shackle Undead when additional aggro is undead.
-Added support for shadowfiend, when TargetHP > 70% && MyMP < 30
-Added support for SW: D, when TargetHP < 15% && MyHP > 60% (Safety reasons)
-Added support for VT (wasn't included?)
-Bandages supported
-Scrolls supported. (Intellect, Spirit, Protection ONLY. Rest will be sold ^^)
-Fixed many issues with shadowform removal
-Fixed problems where potions would not be used even when called.
-Added in Symbol of Hope (not working as wanted quite yet) Gift of the Naaru, and Cannibalize support.
-Many minor bugfixes (typos fixed so things work as they should now)
-Psychic scream now works
-Changed SpiritTapMP variable to 100 (higher level toons still want to drink even tho SpiritTap is up [Will add support to only take SpiritTapMP into account when low lvl])

GUI Edits:

Bandage checkbox, and slider actually do something!
Added SW: D to spells choice (Not in custom spell. To avoid suicides)

v1.01

-Fixed the running through mobs bug, I had an issue pop up where the bot would target a mob but have a POI to another one, only happened once. I noticed OB goes wierd sometimes if you start the bot while targeting something. If this still happens Please let me know, stopped happening to me.

-Took out some unnecessary GUI Buttons

-Added a choice to use Pots and at what % Hp

-Added Vampiric Touch to the pull options

v1.01a

-Just a small Update took out some unnecessary code
-Changed the Heal Tab. Added more Heal spells and put them in list boxes. (Note: You have to choose your heal spells everytime you load OB)

v1.01b
-entered code for a custom fight order, not fully tested as I'm Suspended :( , Let me know if it works if anyone uses it. (well the two people that have downloaded this I guess :) )
-Moved Shadow Word: Pain to Combat buff
-The running past mobs should be fixed in this rls

v1.01c
-Changed a bit of the range code, should work better with Mind Flay.
-fixed the regular routine not running
More to come as I level my toon.

v1.02
-The Custom Attack Order seems to be working fine, I put in the ability to set timers on how long to wait until it tries to cast again, should be pretty nifty. As always if I'm missing a spell that you would like to use let me know, it's easy enough to add it in.

-Fixed a minor issue with the Gui not saving/loading settings for Healing potions and enabling the Custom Attack

-Fixed some targeting issues as well as a problem when trying to cast Vampiric Embrace with it canceling every time it tried to cast which made it loop and look like a bot.

This release seems a lot more stable, I've been able to get 20k+ xp/hr with it.



*/


objectdef cClass inherits cBase
{

	;----------------------;
	;--- Rest Variables ---;
	;----------------------;
	variable int RestHP						= 50
	variable int RestMP						= 50
	variable int RestMPWait					= 95
	variable int StandHP					= 100
	variable int StandMP					= 95
	variable int RestHeal					= 70		/* HP % to use Heal in RestPulse  NOT IN GUI */
	variable int RestFlashHeal				= 60
	variable int RestRenew					= 70 		/* HP % to use RestRenew NOT IN GUI */
	variable int RestGreaterHeal			= 30
	variable int RestHeal					= 40
	variable int RestLesserHeal				= 50
	variable int SpiritTapMp				= 100		/* Set this to an amount to skip drink if you have Spirit tap and your Mana is < RestMP  added this for lower levels that dont have 100% ST.  NOT IN GUI */
	variable bool UseRest					= TRUE

	;----------------------;
	;--- Range Settings ---;
	;----------------------;
	variable int MaxRanged					= 36
	variable int MaxMindFlayRange			= 19
	variable int MinMindFlayRange			= 15
	variable int MinRanged					= 15
	variable int MaxMelee					= 4.9
	variable int MinMelee					= 1.9
	
	;----------------------;
	;---Combat Variables---;
	;----------------------;
	variable int TargetHPsUseShield         = 20		/* Doesnt use shield if targets hp % = this and other conditions are met */
	variable int MeHPsUseShield             = 40		/* Doesnt use shield if My hp % = this and other conditions are met */
	variable int debugger                   = 0
	variable guidlist AggroList

	;-------------------;
	;---GUI Variables---;
	;-------------------;


	;Combat Spells & Attacks
	variable bool UseCustomAtkOrder         = FALSE
	variable string MyPullSpell             = ""
	variable bool UseSmite                  = TRUE
	variable bool UseMindBlast              = TRUE
	variable bool UseShadowWordPain         = TRUE
	variable bool UseShadowWordDeath        = FALSE
	variable bool UseMindFlay               = TRUE
	variable bool UsePsychicScream          = TRUE
	variable bool UseShcklUndead            = TRUE
	variable bool UseWand                   = TRUE
	variable bool UseVampiricEmbrace        = TRUE
	variable bool UseVampiricTouch          = TRUE
	variable bool UseShadowfiend            = TRUE
	variable bool UseSilence                = TRUE
	variable bool UseInnerFocus				= TRUE
	variable bool MindFlayRunners           = TRUE		/* Mind Flay runners. DOES NOT HAVE A MOB% ASSOCIATED!!! (Not in GUI) */
	variable int StartWandAtHp              = 0
	variable int StartWandAtMp              = 0

	;Custom Combat Spells
	variable string SpellOne                = "None"
	variable string SpellTwo                = "None"
	variable string SpellThree              = "None"
	variable string SpellFour               = "None"
	variable string SpellFive               = "None"
	variable string SpellSix                = "None"

	;Heals
	variable bool UseBandages               = TRUE
	variable int  UseBandagesAt             = 0			/* Use Bandages at this HP % */
	variable bool UseHealPots               = TRUE
	variable int  UseHealPotsAt             = 0			/* Use Heal Potion at this HP % */
	variable int  UseHealSpellOneAt         = 0
	variable int  UseHealSpellTwoAt         = 0
	variable int  UseHealSpellThreeAt       = 0
	variable int  UseHealSpellFourAt        = 0
	variable int  UseHealSpellFiveAt        = 0
	variable string HealSpellOne            = "None"
	variable string HealSpellTwo            = "None"
	variable string HealSpellThree          = "None"
	variable string HealSpellFour           = "None"
	variable string HealSpellFive           = "None"
	variable string None                    = "None"

	;Combat Buffs
	variable bool UseShadowform             = TRUE
	variable bool UsePowerWordShield        = TRUE
	variable bool UseShieldOnPull           = TRUE
	variable bool UseVampiricEmbrace        = TRUE
	variable bool UseShield                 = TRUE
	variable int UseShieldAt				= 90
	variable int BuffNum					= 0


	;Regular Buffs
	variable bool UseCustomBuffs            = FALSE
	variable bool UseFortitude              = TRUE
	variable bool UseShadowProtection       = TRUE
	variable bool UseInnerFire              = TRUE
	variable bool UseCureDisease            = TRUE
	variable bool UseDispelMagic            = TRUE
	variable bool UseDispelDisease          = TRUE

	;Settings Variables
	variable bool EnableMyOutput            = FALSE

	;Timer Variables
	variable int RestHealingTimer           = 0
	variable int RenewTimer					= 0
	variable int LastHeal                   = 0
	variable int PullTimer                  = 0
	variable int SpellOneTimer              = 0
	variable int SpellTwoTimer              = 0
	variable int SpellThreeTimer            = 0
	variable int SpellFourTimer             = 0
	variable int SpellFiveTimer             = 0
	variable int SpellSixTimer              = 0
	variable int SpellOneTimerSum           = 0
	variable int SpellTwoTimerSum           = 0
	variable int SpellThreeTimerSum         = 0
	variable int SpellFourTimerSum          = 0
	variable int SpellFiveTimerSum          = 0
	variable int SpellSixTimerSum           = 0

	;Danger and flee Variables (Thanks to Ritz for allowing me to steal his code)

	variable int DangerMedium               = 15    /* The Danger level to return to DPS form. Default 15. */
	variable int DangerHigh                 = 30    /* The Danger level to stop all out DPSing and shift to a more defensive form. Default 30. */
	variable int DangerVeryHigh             = 45    /* This is the point the routine decides you are screwed and tries to run off. Default 45. */
	variable int SafeArea                   = 40    /* The distance around you an area must be free of mobs before it is considered safe to flee to. */
	variable int DangerLevel                = 0     /* Fixed. Monitor of how dangerous the situation is */
	variable int Dangerlvl                  = 0     /* Fixed. Danger interpretation for the routine to use */
	variable int SafeX                      = 0     /* Fixed */
	variable int SafeY                      = 0     /* Fixed */
	variable int SafeZ                      = 0     /* Fixed */
	variable bool Fleeing                   = FALSE /* Fixed. For running off. */


	variable string RealmChar="${ISXWoW.RealmName}_${Me.Name}_${Me.Class}"            /* had to steal it... Ingenius */



;*****************************************************************************************************************
;***********************------------------------Need Rest Check------------------------***************************
;*****************************************************************************************************************

	member NeedRest()
	{
		echo <${Time.Time24}>  nr1
		if ${UseRest}
			{
				if ${Me.Buff[Resurrection Sickness](exists)}
					{
						echo <${Time.Time24}>  nr2
						return TRUE
					}
				if ${Me.PctMana} < ${RestMP} && ${Me.PctMana} < ${This.SpiritTapMp} && !${Me.InCombat}
					{
						echo <${Time.Time24}>  nr3
						return TRUE
					}
				if ${Me.PctHPs} < ${RestHP} && !${Me.InCombat}
					{
						echo <${Time.Time24}>  nr4
						return TRUE
					}
				if ${Me.PctHPs} < ${This.StandHP} && ${Me.Sitting} && !${Me.InCombat}
					{
						echo <${Time.Time24}>  nr5
						return TRUE
					}
				if ${Me.PctMana} < ${This.StandMP} && ${Me.Sitting} && !${Me.InCombat}
					{
						echo <${Time.Time24}>  nr6
						return TRUE
					}

				if ${Me.Buff[Drink](exists)} && ${Me.Buff[Food](exists)} && !${Me.InCombat}
					{
						echo <${Time.Time24}>  nr7
						return TRUE
					}

				if ${This.NeedDecurse}
					{
						echo <${Time.Time24}>  nr8
						return TRUE
					}
			}
		return FALSE
	}

;*****************************************************************************************************************
;***********************------------------------Rest Setup------------------------********************************
;*****************************************************************************************************************
	method RestPulse()
	{
		echo <${Time.Time24}>  rp1
		variable guidlist SafeCheck
		SafeCheck:Search[-units,-hostile,-range 0-${SafeArea}]
		if ${SafeCheck.Count} == 0 && ${Math.Distance[${Me.X},${Me.Y},${SafeX},${SafeY}]} > ${SafeArea}
		{
			echo <${Time.Time24}>  rp2
			This:RDebug["Safe Spot Set ${Me.X} ${Me.Y} ${Me.Z}"]
			SafeX:Set[${Me.X}]
			SafeY:Set[${Me.Y}]
			SafeZ:Set[${Me.Z}]
		}
		
		if ${This.NeedDecurse}
			{
				;if we have a debuff we can dispel, let's get rid of it.
				if ${Me.Buff.Harmful}
				{
					Toon:Standup

					if ${Me.Buff.Harmful.DispelType.Equal[Magic]} && ${Toon.canCast[Dispel Magic]}
					{
						Toon:CastSpell[Dispel Magic]
						This:CustOutput[${EnableMyOutput}, "Dispelling Magic!"]
						return
					}
					if ${Me.Buff.Harmful.DispelType.Equal[Disease]} && ${Toon.canCast[Cure Disease]}
					{
						Toon:CastSpell[Cure Disease]
						This:CustOutput[${EnableMyOutput}, "Curing Disease!"]
						return
					}
				}
				return
			}


		if ${Movement.Speed}
			{
				echo <${Time.Time24}>  rp3
				Move -stop
			}
		if ${Me.Buff["Resurrection Sickness"](exists)} && !${Me.Sitting}
			{
				echo <${Time.Time24}>  rp4
				Toon:Sitdown
				This:Output["I've got Resurrection Sickness,  I'm staying put!!"]

				if ${Toon.canCast[Shadowmeld]}
				{
					echo <${Time.Time24}>  rp5
					Toon:CastSpell["Shadowmeld"]
					This:CustOutput[${EnableMyOutput}, "Shadowmelding cuz I'm cool like that"]
				}
				echo <${Time.Time24}>  rp6
				return
			}
			
		if ${Me.PctHPs} < ${RestHeal}
			{
				echo <${Time.Time24}>  rp7
					if ${Me.PctHPs} < ${RestGreaterHeal} && ${Toon.canCast[Greater Heal]} && ${LavishScript.RunningTime} > ${This.RestHealingTimer}
						{
							echo <${Time.Time24}>  rp8
							This:Output["RestGreaterHeal Called"]
							This:SelfCastCheck
							This:ShadowformRemove
							Toon:CastSpell["Greater Heal"]
							This:CustOutput[${EnableMyOutput}, "Resting Greater Heal"]
							This.RestHealingTimer:Set[${This.InSeconds[10]}]
						}					

					;Cast Flash heal if Needed
					if ${Me.PctHPs} < ${RestFlashHeal} && ${Toon.canCast[Flash Heal]} && ${LavishScript.RunningTime} > ${This.RestHealingTimer}
						{
							echo <${Time.Time24}>  rp9
							This:Output["RestFlashHeal Called"]
							This:SelfCastCheck
							This:ShadowformRemove
							Toon:CastSpell["Flash Heal"]
							This:CustOutput[${EnableMyOutput}, "Resting Flash Heal"]
							This.RestHealingTimer:Set[${This.InSeconds[10]}]
						}

					if ${Me.PctHPs} < ${RestRegHeal} && ${Toon.canCast[Heal]} && ${LavishScript.RunningTime} > ${This.RestHealingTimer}
						{
							echo <${Time.Time24}>  rp10
							This:Output["RestRegHeal Called"]
							This:SelfCastCheck
							This:ShadowformRemove
							Toon:CastSpell["Heal"]
							This:CustOutput[${EnableMyOutput}, "Resting Heal"]
							This.RestHealingTimer:Set[${This.InSeconds[10]}]
						}

					if ${Me.PctHPs} < ${RestLesserHeal} && ${Toon.canCast[Lesser Heal]} && ${Me.Level} <= 15  && ${LavishScript.RunningTime} > ${This.RestHealingTimer}
						{
							echo <${Time.Time24}>  rp11
							This:Output["RestLesserHeal Called"]
							This:SelfCastCheck
							This:ShadowformRemove
							Toon:CastSpell["Lesser Heal"]
							This:CustOutput[${EnableMyOutput}, "Resting Lesser Heal"]
							This.RestHealingTimer:Set[${This.InSeconds[10]}]
						}
						
					;Cast Renew at the value set for RestRenew
					if ${Me.PctHPs} < ${RestRenew} && ${This.canBuff[Renew]} && ${LavishScript.RunningTime} > ${This.RenewTimer}
						{
							echo <${Time.Time24}>  rp12
							This:Output["RestRenew Called"]
							This:SelfCastCheck
							This:ShadowformRemove
							Toon:CastSpell["Renew"]
							This:CustOutput[${EnableMyOutput}, "Resting Renew"]
							This.RenewTimer:Set[${This.InSeconds[20]}]
							This.RestHealingTimer:Set[${This.InSeconds[10]}]
						}
					if ${Me.Buff[Renew](exists)}
						{
							return
						}
				echo <${Time.Time24}>  rp13
				return
			}

		if ${Me.PctHPs} < ${This.UseBandagesAt} && ${UseBandages} && ${Toon.canBandage}
				{
					echo <${Time.Time24}>  rp14
					if ${WoWScript[SpellIsTargeting()]}
					{
						echo <${Time.Time24}>  rp15
						Target ${Me.GUID}
						This:Output["Bandaging"]
					}
					Consumable:useBandage
					return
					
				}

		if ${UseRest}
			{
				echo <${Time.Time24}>  rp16
				if ${Me.PctHPs} >= ${This.StandHP} && ${Me.PctMana} >= ${This.StandMP} && ${Me.Sitting} && !${Me.Buff[Resurrection Sickness](exists)}
					{
						echo <${Time.Time24}>  rp17
						WoWPress Jump
						This:CustOutput[${EnableMyOutput}, "Done Resting"]
					}

				;----------------------------------------------------------------------------------;
				;  ***  Didn't want the bot to drink if the SpiritTapMp requirements were met ***  ;
				;----------------------------------------------------------------------------------;
				if ${Me.PctMana} >= ${This.SpiritTapMp} && ${Me.Buff[Spirit Tap](exists)} && ${Me.Sitting}
					{
						echo <${Time.Time24}>  rp18
						Toon:Standup
						This:CustOutput[${EnableMyOutput}, "I've got enough Mana and Spirit Tap is working, I'm Standing up"]
					}

				if ${Me.PctMana} < ${This.RestMP} && !${Me.Sitting} && !${Me.Buff[Drink](exists)} && ${Consumable.HasDrink}
					{
						echo <${Time.Time24}>  rp19
						This:CustOutput[${EnableMyOutput}, "Looks like I couldn't skip downtime"]
						Toon:Sitdown
						if ${Toon.canCast[Shadowmeld]}
						{
							echo <${Time.Time24}>  rp20
							Toon:CastSpell["Shadowmeld"]
							This:CustOutput[${EnableMyOutput}, "Shadowmelding cuz I'm cool like that"]
						}
					}


				;Eat
				if ${Me.PctHPs} < ${This.RestHP} && ${Consumable.HasFood} && !${Me.Buff[Food](exists)} && ${Me.Sitting}
					{
						echo <${Time.Time24}>  rp21
						This:CustOutput[${EnableMyOutput}, "Eating as a priest? Something's fucked up"]
						Consumable:useFood
						if ${Toon.canCast[Shadowmeld]}
						{
							echo <${Time.Time24}>  rp22
							Toon:CastSpell["Shadowmeld"]
							This:CustOutput[${EnableMyOutput}, "Shadowmelding cuz I'm cool like that"]
						}
					}

				;Drink
				if ${Me.PctMana} < ${This.RestMP} && ${Consumable.HasDrink} && !${Me.Buff[Drink](exists)} && ${Me.Sitting}
					{
						echo <${Time.Time24}>  rp23
						This:CustOutput[${EnableMyOutput}, "Mmmm I'm Thirsty"]
						Consumable:useDrink
						if ${Toon.canCast[Shadowmeld]}
						{
							echo <${Time.Time24}>  rp24
							Toon:CastSpell["Shadowmeld"]
							This:CustOutput[${EnableMyOutput}, "Shadowmelding cuz I'm cool like that"]
						}
					}
			}
		if ${Me.PctHPs} < ${This.RestHP} && ${Spell[Cannibalize](exists)} && !${Spell[Cannibalize].Cooldown} && (${Object[-dead,-humanoid,-range 0-5](exists)} || ${Object[-dead,-undead,-range 0-5](exists)}) && !${Me.Casting}
			{
				echo <${Time.Time24}>  rp25
				This:Output["Stupid undead eating eachother. Horde FTL!"]
				Toon:CastSpell[Cannibalize]
				return
			}
		echo <${Time.Time24}>  rp26
		return
	}

;*****************************************************************************************************************
;***********************------------------------Need Buff Check------------------------***************************
;*****************************************************************************************************************

	member NeedBuff()
	{
		echo <${Time.Time24}>  nb1
		if !${This.checkForScrolls.Equal["NONE"]}
			{
				echo <${Time.Time24}>  nb2
				return TRUE
			}

		if ${This.UseCustomBuffs}
			{
				echo <${Time.Time24}>  nb3
				if ${This.canBuff[Power Word: Fortitude]} && ${This.UseFortitude}
					{
						echo <${Time.Time24}>  nb4
						return TRUE
					}
				if ${This.canBuff[Inner Fire]} && ${This.UseInnerFire}
					{
						echo <${Time.Time24}>  nb5
						return TRUE
					}
				if ${This.canBuff[Shadow Protection]} && ${This.UseShadowProtection}
					{
						echo <${Time.Time24}>  nb6
						return TRUE
					}
				if ${This.canBuff[Divine Spirit]}
					{
						echo <${Time.Time24}>  nb7
						return TRUE
					}
			}
		else
			{
				echo <${Time.Time24}>  nb8
				if ${This.canBuff[Power Word: Fortitude]}
					{
						echo <${Time.Time24}>  nb9
						return TRUE
					}
				if ${This.canBuff[Inner Fire]}
					{
						echo <${Time.Time24}>  nb10
						return TRUE
					}
				if ${This.canBuff[Shadow Protection]}
					{
						echo <${Time.Time24}>  nb11
						return TRUE
					}
				if ${This.canBuff[Divine Spirit]}
					{
						echo <${Time.Time24}>  nb12
						return TRUE
					}
			 }
			 echo <${Time.Time24}>  nb13
		return FALSE
	}

;*****************************************************************************************************************
;***********************------------------------Buff Setup------------------------********************************
;*****************************************************************************************************************
	method BuffPulse()
	{
		echo <${Time.Time24}>  bp1
		if !${This.checkForScrolls.Equal["NONE"]}
			{
				echo <${Time.Time24}>  bp2
				Consumable:UseScroll[${This.checkForScrolls}]
				return
			}

		if ${This.UseCustomBuffs}
			{
				echo <${Time.Time24}>  bp3
				This:CustomBuffing
			}
		else
			{
				echo <${Time.Time24}>  bp4
				This:RegularBuffing
			}
			echo <${Time.Time24}>  bp5
	}

;*****************************************************************************************************************
;***********************------------------------Pull Buff Check------------------------***************************
;*****************************************************************************************************************

	member NeedPullBuff()
	{
		echo <${Time.Time24}>  nbp1
		if ${UseCustomBuffs}
			{
				echo <${Time.Time24}>  nbp2
				if ${This.canBuff[Power Word: Shield]} && !${Me.Buff[Weakened Soul](exists)} && ${This.UseShieldOnPull} && ${This.UseShield}
					{
						echo <${Time.Time24}>  nbp3
						return TRUE
					}
				if ${This.canBuff[Shadowform]} && ${This.UseShadowform}
					{
						echo <${Time.Time24}>  nbp4
						return TRUE
					}
			}
		else
			{
				echo <${Time.Time24}>  nbp5
				if ${This.canBuff[Power Word: Shield]} && !${Me.Buff[Weakened Soul](exists)} && ${This.UseShieldOnPull}
					{
						echo <${Time.Time24}>  nbp6
						return TRUE
					}
				if ${This.canBuff[Shadowform]} && ${This.UseShadowform}
					{
						echo <${Time.Time24}>  nbp7
						return TRUE
					}
			}
			echo <${Time.Time24}>  nbp8
		return FALSE
	}

;*****************************************************************************************************************
;***********************------------------------Pull Buff Setup------------------------***************************
;*****************************************************************************************************************
	method PullBuffPulse()
	{
		echo <${Time.Time24}>  pbp1

		if ${UseCustomBuffs}
			{
				echo <${Time.Time24}>  pbp2
				;Buff Power Word: Shield w/ Custom Buffs
				if ${This.canBuff[Power Word: Shield]} && !${Me.Buff[Weakened Soul](exists)} && ${This.UseShieldOnPull} && ${This.UseShield}
					{
						echo <${Time.Time24}>  pbp3
						if ${Target.Dead}
						{
							echo <${Time.Time24}>  pbp4
							return
						}
						This:SelfCastCheck
						Toon:CastSpell["Power Word: Shield"]
						This:CustOutput[${EnableMyOutput}, "PullBuff - Power Word: Shield"]
					}
				;Cast Shadowform w/ Custom Buffs
				if ${This.canBuff[Shadowform]} && ${This.UseShadowform}
					{
						echo <${Time.Time24}>  pbp5
						This:SelfCastCheck
						This:CustOutput[${EnableMyOutput}, "Pull Buff - Shadowform"]
						Toon:CastSpell[Shadowform]
					}
				}
			else
				{
					echo <${Time.Time24}>  pbp6
					;Buff Power Word: Shield
					if ${This.canBuff[Power Word: Shield]} && !${Me.Buff[Weakened Soul](exists)} && ${This.UseShieldOnPull}
						{
							echo <${Time.Time24}>  pbp7
							This:SelfCastCheck
							Toon:CastSpell["Power Word: Shield"]
							This:CustOutput[${EnableMyOutput}, "Pull Buff - Power Word Shield"]
						}
					;Buff Shadowform Regularly,  no custom buff.
					if ${This.canBuff[Shadowform]} && ${This.UseShadowform}
						{
							echo <${Time.Time24}>  pbp8
							This:SelfCastCheck
							This:CustOutput[${EnableMyOutput}, "Pull Buff - Shadowform"]
							Toon:CastSpell[Shadowform]
						}
				}
				echo <${Time.Time24}>  pbp9
		return
	}


;*****************************************************************************************************************
;***********************------------------------Combat Buff Check------------------------*************************
;*****************************************************************************************************************

	member NeedCombatBuff()
	{
	echo <${Time.Time24}>  ncb1
		if ${Me.PctHPs} < ${UseHealSpellOneAt} && ${Toon.canCast[${This.HealSpellOne}]} && ${This.HealSpellOne.NotEqual["None"]} && ${LavishScript.RunningTime} < ${This.LastHeal}
			{
				echo <${Time.Time24}>  ncb2
				return TRUE
			}

		if ${Me.PctHPs} < ${UseHealSpellTwoAt} && ${Toon.canCast[${This.HealSpellTwo}]} && ${This.HealSpellTwo.NotEqual["None"]} && ${LavishScript.RunningTime} < ${This.LastHeal}
			{
				echo <${Time.Time24}>  ncb3
				return TRUE
			}

		if ${Me.PctHPs} < ${UseHealSpellThreeAt} && ${Toon.canCast[${This.HealSpellThree}]} && ${This.HealSpellThree.NotEqual["None"]} && ${LavishScript.RunningTime} < ${This.LastHeal}
			{
				echo <${Time.Time24}>  ncb4
				return TRUE
			}

		if ${Me.PctHPs} < ${UseHealSpellFourAt} && ${Toon.canCast[${This.HealSpellFour}]} && ${This.HealSpellFour.NotEqual["None"]} && ${LavishScript.RunningTime} < ${This.LastHeal}
			{
				echo <${Time.Time24}>  ncb5
				return TRUE
			}

		if ${Me.PctHPs} < ${UseHealSpellFiveAt} && ${Toon.canCast[${This.HealSpellFive}]} && ${This.HealSpellFive.NotEqual["None"]} && ${LavishScript.RunningTime} < ${This.LastHeal}
			{
				echo <${Time.Time24}>  ncb6
				return TRUE
			}

			;Buff Power Word: Shield
		if ${UseCustomBuffs}
		{
			echo <${Time.Time24}>  ncb7
			;Combat shield with custom buffs
			if ${This.canBuff[Power Word: Shield]} && !${Me.Buff[Weakend Soul](exists)} && ${Me.PctMana} > 20 && ${Target.PctHPs} > 10
				{
					echo <${Time.Time24}>
					return TRUE
				}

			;Combat Shadowform w/ custom buffs
			if ${This.canBuff[Shadowform]} && ${This.UseShadowform}
				{
					echo <${Time.Time24}>  ncb10
					return TRUE
				}
		}
		else
		{
			echo <${Time.Time24}>  ncb11
			if ${This.canBuff[Power Word: Shield]} && !${Me.Buff[Weakened Soul](exists)}  && ${Me.PctMana} > 20 && ${Target.PctHPs} > 10
				{
					echo <${Time.Time24}>  ncb13
					return TRUE
				}
			;Combat Shadowform w/o custom buffs
			if ${This.canBuff[Shadowform]}
				{
					echo <${Time.Time24}>  ncb14
					return TRUE
				}
		}

		;Shadow Word: Pain
		if ${This.canBuff[Shadow Word: Pain, "Target"]} && ${This.UseShadowWordPain} && !${Me.Action[Shoot].AutoRepeat}
				{
					echo <${Time.Time24}>  ncb15
					return TRUE
				}

		
		;Vampiric Embrace
		if ${This.canBuff[Vampiric Embrace, "Target"]} && ${Target.PctHPs} > 50 && ${This.UseVampiricEmbrace}
			{
				echo <${Time.Time24}>  ncb16
				return TRUE
			}

		if ${Toon.canCast[Inner Focus]} && ${Me.PctMana} < 30 && !${Me.Buff[Inner Focus](exists)}
			{
				echo <${Time.Time24}>  ncb17
				return TRUE
			}
			
		if ${This.NeedDecurse}
			{
				return TRUE
			}


		echo <${Time.Time24}>  ncb18
		return FALSE
	}
;*****************************************************************************************************************
;***********************------------------------Combat Buff Setup------------------------*************************
;*****************************************************************************************************************
	method CombatBuffPulse()
	{

		echo <${Time.Time24}>  cbp1
;*****************************************************************************************************************
;***********************------------------------Heals------------------------*************************************
;*****************************************************************************************************************
		if ${Me.PctHPs} < ${This.UseHealSpellOneAt} && ${Toon.canCast[${This.HealSpellOne}]} && ${LavishScript.RunningTime} > ${This.LastHeal} && ${This.HealSpellOne.NotEqual["None"]}
			{
				echo <${Time.Time24}>  cbp3
				if !${Toon.canCast[${This.HealSpellOne}]}
					{
						echo <${Time.Time24}>  cbp4
						return
					}
				if !${Me.Casting[${This.HealSpellOne}]}
					{
						echo <${Time.Time24}>  cbp5
						WowScript SpellStopCasting()
					}
				if ${This.HealSpellOne.Equal["Renew"]} && (${Me.Buff[Renew](exists)} || ${RenewTimer} > ${LavishScript.RunningTime})
					{
						echo <${Time.Time24}> cbp9156
						return
					}					
					This:ShadowformRemove
					This:SelfCastCheck
					Toon:CastSpell[${This.HealSpellOne}]
					This.LastHeal:Set[${This.InSeconds[3]}]
					This:CustOutput[${EnableMyOutput}, "Casting ${This.HealSpellOne}"]
				if ${This.HealSpellOne.Equal["Renew"]} && ${This.canBuff[Renew]}
					{
						RenewTimer:Set[${This.InSeconds[10]}]
						echo <${Time.Time24}> cbp91
					}
					echo <${Time.Time24}>  cbp6
					return
					
			}

		if ${Me.PctHPs} < ${This.UseHealSpellTwoAt} && ${Toon.canCast[${This.HealSpellTwo}]} && ${LavishScript.RunningTime} > ${This.LastHeal} && ${This.HealSpellTwo.NotEqual["None"]}
			{
				echo <${Time.Time24}>  cbp7
				if !${Me.Casting[${This.HealSpellTwo}]}
					{
						echo <${Time.Time24}>  cbp8
						WowScript SpellStopCasting()
					}
				if !${Toon.canCast[${This.HealSpellTwo}]}
					{
						echo <${Time.Time24}>  cbp9
						return
					}
					if ${This.HealSpellTwo.Equal["Renew"]} && (${Me.Buff[Renew](exists)} || ${RenewTimer} > ${LavishScript.RunningTime})
					{
						echo <${Time.Time24}> cbp9789
						return
					}					
					This:ShadowformRemove
					This:SelfCastCheck
					Toon:CastSpell[${This.HealSpellTwo}]
					This.LastHeal:Set[${This.InSeconds[3]}]
					This:CustOutput[${EnableMyOutput}, "Casting ${This.HealSpellTwo}"]
				if ${This.HealSpellTwo.Equal["Renew"]} && ${This.canBuff[Renew]}
					{
						RenewTimer:Set[${This.InSeconds[10]}]
						echo <${Time.Time24}> cbp91
					}
					echo <${Time.Time24}>  cbp10
					return
			}

		if ${Me.PctHPs} < ${This.UseHealSpellThreeAt} && ${Toon.canCast[${This.HealSpellThree}]} && ${LavishScript.RunningTime} > ${This.LastHeal} && ${This.HealSpellThree.NotEqual["None"]}
			{
				echo <${Time.Time24}>  cbp11
				if !${Me.Casting[${This.HealSpellThree}]}
					{
						echo <${Time.Time24}>  cbp12
						WowScript SpellStopCasting()
					}
				if !${Toon.canCast[${This.HealSpellThree}]}
					{
						echo <${Time.Time24}>  cbp13
						return
					}
				if ${This.HealSpellThree.Equal["Renew"]} && (${Me.Buff[Renew](exists)} || ${RenewTimer} > ${LavishScript.RunningTime})
					{
						echo <${Time.Time24}> cbp9000
						return
					}	
					This:ShadowformRemove
					This:SelfCastCheck
					Toon:CastSpell[${This.HealSpellThree}]
					This.LastHeal:Set[${This.InSeconds[3]}]
					This:CustOutput[${EnableMyOutput}, "Casting ${This.HealSpellThree}"]
				if ${This.HealSpellThree.Equal["Renew"]} && ${This.canBuff[Renew]}
					{
						RenewTimer:Set[${This.InSeconds[10]}]
						echo <${Time.Time24}> cbp91
					}
					echo <${Time.Time24}>  cbp14
					return
			}

		if ${Me.PctHPs} < ${This.UseHealSpellFourAt} && ${Toon.canCast[${This.HealSpellFour}]} && ${LavishScript.RunningTime} > ${This.LastHeal} && ${This.HealSpellFour.NotEqual["None"]}
			{
				echo <${Time.Time24}>  cbp15
				if !${Me.Casting[${This.HealSpellFour}]}
					{
						echo <${Time.Time24}>  cbp16
						WowScript SpellStopCasting()
					}
				if !${Toon.canCast[${This.HealSpellFour}]}
					{
						echo <${Time.Time24}>  cbp17
						return
					}
				if ${This.HealSpellFour.Equal["Renew"]} && (${Me.Buff[Renew](exists)} || ${RenewTimer} > ${LavishScript.RunningTime})
					{
						echo <${Time.Time24}> cbp9010
						return
					}	
					This:ShadowformRemove
					This:SelfCastCheck
					Toon:CastSpell[${This.HealSpellFour}]
					This.LastHeal:Set[${This.InSeconds[3]}]
					This:CustOutput[${EnableMyOutput}, "Casting ${This.HealSpellFour}"]
				if ${This.HealSpellFour.Equal["Renew"]} && ${This.canBuff[Renew]}
					{
						RenewTimer:Set[${This.InSeconds[10]}]
						echo <${Time.Time24}> cbp91
					}
					echo <${Time.Time24}>  cbp18
					return
			}

		if ${Me.PctHPs} < ${This.UseHealSpellFiveAt} && ${Toon.canCast[${This.HealSpellFive}]} && ${LavishScript.RunningTime} > ${This.LastHeal} && ${This.HealSpellFive.NotEqual["None"]}
			{
				echo <${Time.Time24}>  cbp19
				if !${Me.Casting[${This.HealSpellFive}]}
					{
						echo <${Time.Time24}>  cbp20
						WowScript SpellStopCasting()
					}
				if !${Toon.canCast[${This.HealSpellFive}]}
					{
						echo <${Time.Time24}>  cbp21
						return
					}
				if ${This.HealSpellFive.Equal["Renew"]} && (!${This.canBuff[Renew]} || ${RenewTimer} > ${LavishScript.RunningTime})
					{
						echo <${Time.Time24}> cbp906165
						return
					}	
					This:ShadowformRemove
					This:SelfCastCheck
					Toon:CastSpell[${This.HealSpellFive}]
					This.LastHeal:Set[${This.InSeconds[3]}]
					This:CustOutput[${EnableMyOutput}, "Casting ${This.HealSpellFive}"]
				if ${This.HealSpellFive.Equal["Renew"]} && ${This.canBuff[Renew]}
					{
						RenewTimer:Set[${This.InSeconds[10]}]
						echo <${Time.Time24}> cbp91
					}
					echo <${Time.Time24}>  cbp22
					return
			}

		;Buff Power Word: Shield
		if ${UseCustomBuffs}
			{
				echo <${Time.Time24}>  cbp23
				;Combat shield with custom buffs
				if ${This.canBuff[Power Word: Shield]} && !${Me.Buff[Weakened Soul](exists)} && ${Me.PctMana} > 20 && ${Target.PctHPs} > 10 && ${UseShield}
					{
						echo <${Time.Time24}>  cbp25
						This:SelfCastCheck
						Toon:CastSpell["Power Word: Shield"]
						This:CustOutput[${EnableMyOutput}, "Casting Power Word: Shield"]
					}
				;Combat Shadowform w/ custom buffs
				if ${This.canBuff[Shadowform]} && ${Me.PctHPs} >= 70
					{
						echo <${Time.Time24}>  cbp26
						WowScript SpellStopCasting()
						This:SelfCastCheck
						This:CustOutput[${EnableMyOutput}, "Casting Shadowform"]
						Toon:CastSpell[Shadowform]
					}
				}
		else
			{
				if ${This.canBuff[Power Word: Shield]} && !${Me.Buff[Weakened Soul](exists)} && ${Me.PctMana} > 20 && ${Target.PctHPs} > 10
					{
						echo <${Time.Time24}>  cbp28
						This:SelfCastCheck
						Toon:CastSpell["Power Word: Shield"]
						This:CustOutput[${EnableMyOutput}, "Casting Power Word: Shield"]
					}
				;Combat Shadowform w/o custom buffs
				if ${This.canBuff[Shadowform]} && ${Me.PctHPs} >= 70
					{
						echo <${Time.Time24}>  cbp29
						WowScript SpellStopCasting()
						This:SelfCastCheck
						This:CustOutput[${EnableMyOutput}, "Casting Shadowform"]
						Toon:CastSpell[Shadowform]
					}
		 	}

		if ${Toon.canCast[Symbol of Hope]} && ${Me.PctMana} <= 40
			{
				echo <${Time.Time24}>  cbp30
				Toon:CastSpell[Symbol of Hope]
				This:CustOutput[${EnableMyOutput}, "Draenei For The Fucking WIN!"]
			}

		if ${This.canBuff[Inner Focus]} && ${Me.PctMana} < 20
			{
				echo <${Time.Time24}>  cbp31
				Toon:CastSpell[Inner Focus]
				This:CustOutput[${EnableMyOutput}, "Casting Inner Focus for a free spellcast!"]
			}

		;Cast Vampiric Embrace
		if ${This.canBuff[Vampiric Embrace, "Target"]} && !${Me.Action[Shoot].AutoRepeat} && ${UseVampiricEmbrace} && (${Target.PctHPs} > ${This.StartWandAtHp} || && ${Me.PctMana} > ${StartWandAtMp})
			{
				echo <${Time.Time24}>  cbp32
				Toon:CastSpell[Vampiric Embrace]
				This:CustOutput[${EnableMyOutput}, "Casting Vampiric Embrace"]
			}

		 ;Cast Shadow Word: Pain
		 if ${This.canBuff[Shadow Word: Pain, "Target"]} && ${This.UseShadowWordPain} && !${Me.Action[Shoot].AutoRepeat}
		 	{
			 	echo <${Time.Time24}>  cbp33
				Toon:CastSpell["Shadow Word: Pain"]
				This:CustOutput[${EnableMyOutput}, "Casting Shadow Word: Pain"]
			}
		if ${This.NeedDecurse}
			{
				;if we have a debuff we can dispel, let's get rid of it.
				if ${Me.Buff.Harmful}
				{
					Toon:Standup

					if ${Me.Buff.Harmful.DispelType.Equal[Magic]} && ${Toon.canCast[Dispel Magic]}
					{
						Toon:CastSpell[Dispel Magic]
						This:CustOutput[${EnableMyOutput}, "Dispelling Magic!"]
						return
					}
					if ${Me.Buff.Harmful.DispelType.Equal[Disease]} && ${Toon.canCast[Cure Disease]}
					{
						Toon:CastSpell[Cure Disease]
						This:CustOutput[${EnableMyOutput}, "Curing Disease!"]
						return
					}
				}
				return
			}
	}

;*****************************************************************************************************************
;***********************------------------------Pull Setup------------------------********************************
;*****************************************************************************************************************

	method PullPulse()
	{
		echo <${Time.Time24}>  pp1
		if ${Target.Classification.Equal[Elite]}
		{ 
			echo <${Time.Time24}>  pp2
			This:Output["Target is elite. Blacklisting."]
			GlobalBlacklist:Insert[${Target.GUID},3600000]
			WoWScript ClearTarget()
			move -stop
			return 
		}
		
		if ${Target.Distance} > ${MaxRanged}
			{
				echo <${Time.Time24}>  pp3
				This:PullRangeCheck
			}
		
		if ${Target.Distance} < ${MaxRanged}-4
			{
				move -stop
			}

		if ${Target.Distance} <= ${This.MinRanged}
			{
				echo <${Time.Time24}>  pp6
				move -stop
			}

		if ${Target.Dead} || ${Target.GUID.Equal[${Me.GUID}]} || ${Target.IsMerchant}
			{
				echo <${Time.Time24}>  pp7
				WowScript ClearTarget()
				Target ${Unit[${Targeting.TargetCollection.Get[1]}].GUID}
				This:CustOutput[${EnableMyOutput}, "This is not a good Target"]
			}

		if ${Toon.canCast[${This.MyPullSpell}]} && ${This.PullTimer} < ${LavishScript.RunningTime}
			{
				echo <${Time.Time24}>  pp8
				This:Output["Pulling with ${This.MyPullSpell}"]
				if ${Me.Buff[Shadowform](exists)} && (${This.MyPullSpell.Equal["Smite"]} || ${This.MyPullSpell.Equal["Holy Fire"]})
				{
					echo <${Time.Time24}>  pp9
					This:Output["Removing Shadowform"]
					This:ShadowformRemove
				}
				This:Output["Casting ${This.MyPullSpell}"]
				Toon:CastSpell[${This.MyPullSpell}]
				This:CustOutput[${EnableMyOutput}, "Pulling With: ${This.MyPullSpell}"]
				This.PullTimer:Set[${This.InSeconds[1]}]
			}
/*		elseif !${Toon.canCast[${This.MyPullSpell}]} && !${Me.Casting} && ${This.PullTimer} < ${LavishScript.RunningTime}
			{
				echo <${Time.Time24}>  pp10
				if ${Me.Buff[Shadowform](exists)}
				{
					echo <${Time.Time24}>  pp11
					This:ShadowformRemove
				}
				This:CustOutput[${EnableMyOutput}, "Pulling with smite because we cant use ${This.MyPullSpell}"]
				Toon:CastSpell[Smite]
				This.PullTimer:Set[{This.InSeconds[15]}]
			}
*/			
		echo <${Time.Time24}>  pp12
		return

	}




;*****************************************************************************************************************
;***********************------------------------Combat Setup------------------------******************************
;*****************************************************************************************************************

	method AttackPulse()
	{
		variable string PotionName
		
		echo <${Time.Time24}>  ap1
			This:SetDanger
			if ${Fleeing}
			{
				echo <${Time.Time24}>  ap2
				This:CustOutput[${EnableMyOutput}, "Attack - Fleeing"]
				This:FleeRoutine
				return
			}
			variable guidlist Aggros
			Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-40]
			if ${Dangerlvl} >= 3 && !${Fleeing} && ${Math.Distance[${Me.X},${Me.Y},${SafeX},${SafeY}]} > 20 && (${SafeX} != 0 && ${SafeY} != 0 && ${SafeZ} != 0)
			{
				echo <${Time.Time24}>  ap3
				Fleeing:Set[TRUE]
				This:CustOutput[${EnableMyOutput}, "Attack - So screwed - trying to run away"]
				GlobalBlacklist:Insert[${Target.GUID},3600000]
				return
			}

			if ${Target.Distance} > ${This.MaxRanged}
					{
						echo <${Time.Time24}>  ap4
						wowpress -hold moveforward
						This:CustOutput[${EnableMyOutput}, "Distance is: ${Target.Distance},  I need to get closer"]
					}

				if ${Target.Distance} < ${This.MaxRanged}
					{
						echo <${Time.Time24}>  ap5
						move -stop
					}


				if ${Target.Distance} <= ${This.MinRanged}
					{
						echo <${Time.Time24}>  ap6
						move -stop
					}

			/*if ${Target.Dead} || ${Target.GUID.Equal[${Me.GUID}]} || ${Target.IsMerchant}
				{
					echo <${Time.Time24}>  ap7
					WowScript ClearTarget()
					Target ${Unit[${Targeting.TargetCollection.Get[1]}].GUID}
					This:CustOutput[${EnableMyOutput}, "This is not a good Target"]
					return
				}
			*/

			if ${Item[-inventory,"Healing Potion"](exists)} && ${Me.PctHPs} < ${This.PotionHealAt} && ${This.UsePots}
			{
				PotionName:Set[${Item[-inventory,"Healing Potion"].Name}]	
				if ${Item[${PotionName}].Usable}&&!${WoWScript["GetContainerItemCooldown(${Item[${PotionName}].Bag.Number}, ${Item[${PotionName}].Slot})", 2]}
				{
					Item[${PotionName}]:Use
					return
				}
			}

			;Attack if there isnt a wand
			if !${Me.Equip[Ranged](exists)} && !${Me.Attacking}
				{
					echo <${Time.Time24}>  ap8
					WoWScript AttackTarget()
				}

			;Use Psychic Scream
			AggroList:Search[-units, -nearest, -aggro, -alive, -range 0-5]
			if ${AggroList.Count} >= 3 && ${Toon.canCast[Psychic Scream]} && ${This.UsePsychicScream}
				{
					echo <${Time.Time24}>  ap9
					This:CustOutput[${EnableMyOutput}, "Casting Psychic Scream"]
					Toon:CastSpell["Psychic Scream"]
				}


			;Use Shackle Undead (Thx sm0k3d for the poly code. Same use here!)
			AggroList:Search[-units, -nearest, -aggro, -alive, -undead, -range 0-15]
			if ${Toon.canCast[Shackle Undead]} && ${AggroList.Count} >= 2 && !${Unit[${Targeting.TargetCollection.Get[2]}].Buff[Shackle Undead](exists)} && ${This.UseShckleUndead}
			{
				echo <${Time.Time24}>  ap10
				Target ${Targeting.TargetCollection.Get[2]}
				if ${LavishScript.RunningTime} > ${ShackleTime}
				{
					echo <${Time.Time24}>  ap11
					This:Output["Lets not double cast shackles"]
				}
				if !${Target.Buff[Shackle Undead](exists)} && ${LavishScript.RunningTime} > ${ShackleTime}
				{
					echo <${Time.Time24}>  ap12
					This:CombatCastCheck
					Toon:CastSpell[Shackle Undead]
					This:Output["Shit, more undead. Shackling ${Unit[${Targeting.TargetCollection.Get[2]}]}"]
					Target ${Targeting.TargetCollection.Get[1]}
					ShackleTime:Set[${LavishScript.RunningTime} + 5000]
				}
				echo <${Time.Time24}>  ap13
				return
			}


			;Use the wand
			if (${Me.PctMana} < ${This.StartWandAtMp} || (${Target.PctHPs} <  ${This.StartWandAtHp})) && ${Me.Equip[Ranged](exists)} && !${Me.Action["Shoot"].AutoRepeat} && ${This.UseWand}
				{
					echo <${Time.Time24}>  ap14

					if ${Movement.Speed}
						{
							echo <${Time.Time24}>  ap15
							move -stop
						}

						Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
						Target ${Targeting.TargetCollection.Get[1]}
						WowScript SpellStopCasting()
						Toon:CastSpell[Shoot]
						echo <${Time.Time24}>  ap17
						if ${Me.Action[Shoot].AutoRepeat}
						{
							echo <${Time.Time24}>  ap16
							This:CustOutput[${EnableMyOutput}, "Shooting my wand"]
						}
					return
					}

			;Shadowfiend (Used whether custom or regular atk order is set. More mana is better yes?)
			if ${Toon.canCast[Shadowfiend]} && ${Target.PctHPs} >= 50 && ${Me.PctMana} <= 20
			{
				echo <${Time.Time24}>  ap18
				This:CombatCastCheck
				Toon:CastSpell[ShadowFiend]
				This:CustOutput[${EnableMyOutput}, "Low on mana. Letting out the fiend"]
			}

			if ${Target.Casting(exists)} && ${Toon.canCast[Silence]} && !${Target.Buff[Silence](exists)} && ${UseSilence}
			{
				echo <${Time.Time24}>  ap19
				This:CombatCastCheck
				This:CustOutput[${EnableMyOutput}, "Ye Shall Not Cast!"]
				Toon:CastSpell[Silence]
				return
			}

			;Mind Flay runners. DONT FUCKING TOUCH THE HP CHECK! THIS IS TO MAKE SURE THIS DOESN'T GET CALLED WHEN ITS NOT SUPPOSED TO!
			if ${Me.Target.Target(exists)} && ${Me.InCombat} && ${MindFlayRunners} && ${Toon.canCast[Mind Flay]} && ${Target.PctHPs} <= 40
			{
				echo <${Time.Time24}>  ap20
				This:CombatCastCheck
				This:CustOutput[${EnableMyOutput], "Don't run fool!"]
				Toon:CastSpell[Mind Flay]
				return
			}

			if ${Me.Buff[Feared](exists)} && ${Toon.canCast[Will of the Forsaken]}
			{
				echo <${Time.Time24}>  ap19
				This:CombatCastCheck
				Toon:CastSpell[Will of the Forsaken]
				This:CustOutput[${EnableMyOutput}, "Undead racial of fail! WotF!"]
				return
			}

			if ${Toon.canCast[Mana Tap]} && ${Target.CurrentMana} > 0
			{
				echo <${Time.Time24}>  ap20
				This:CombatCastCheck
				Target ${Targeting.TargetCollection.Get[1]}
				Toon:CastSpell[Mana Tap]
				This:CustOutput[${EnableMyOutput}, "Mana tap"]
				return
			}

			if ${Me.PctMana} < 85 && ${Toon.canCast[Arcane Torrent]} && ${Me.Buff[Mana Tap].Application} == 3
			{
				echo <${Time.Time24}>  ap21
				This:CombatCastCheck
				Toon:CastSpell[Arcane Torrent]
				This:CustOutput[${EnableMyOutput}, "Arcane Torrent"]
				return
			}

			if !${This.UseCustomAtkOrder}
				{
					echo <${Time.Time24}>  ap22
;*****************************************************************************************************************
;***********************------------------------Regular Attack Order------------------------**********************
;*****************************************************************************************************************

						;Cast Mind Blast
						if ${Toon.canCast[Mind Blast]} && !${Me.Action[Shoot].AutoRepeat} && !${Me.Casting} && ${This.UseMindBlast} && (${Target.PctHPs} > ${This.StartWandAtHp} || && ${Me.PctMana} > ${StartWandAtMp})
							{
								echo <${Time.Time24}>  ap23
								This:CombatCastCheck
								Toon:CastSpell["Mind Blast"]
								This:CustOutput[${EnableMyOutput}, "Casting Mind Blast"]
							}

						;Cast Smite
						if ${Toon.canCast[Smite]} && !${Me.Casting} && ${UseSmite} && (${Target.PctHPs} > ${This.StartWandAtHp} || && ${Me.PctMana} > ${StartWandAtMp})
							{
								echo <${Time.Time24}>  ap24
								This:CombatCastCheck
								Toon:CastSpell["Smite"]
								This:CustOutput[${EnableMyOutput}, "Casting Smite"]
							}

						;Cast Mind Flay
						if ${Toon.canCast[Mind Flay]} && ${UseMindFlay} && !${Me.Casting} && (${Target.PctHPs} > ${This.StartWandAtHp} || && ${Me.PctMana} > ${StartWandAtMp})
							{
								echo <${Time.Time24}>  ap25
								This:CombatCastCheck
								Toon:CastSpell["Mind Flay"]
								This:CustOutput[${EnableMyOutput}, "Casting Mind Flay"]
							}
						;Cast SW:D
						if ${This.shadowWordDeathCheck} && ${UseShadowWordDeath} && !${Me.Casting} && !${Me.Action[Shoot].AutoRepeat}
							{
								echo <${Time.Time24}>  ap26
								This:CombatCastCheck
								Toon:CastSpell["Shadow Word: Death"]
								This:CustOutput[${EnableMyOutput}, "Casting Shadow Word: Death"]
							}
						;Cast Vampiric Touch
						if ${Toon.canCast[Vampiric Touch]} && !${Target.Buff[Vampiric Touch](exists)} && !${Me.Casting} && !${Me.Action[Shoot].AutoRepeat} && ${UseVampiricTouch} && (${Target.PctHPs} > ${This.StartWandAtHp} || && ${Me.PctMana} > ${StartWandAtMp})
							{
								echo <${Time.Time24}>  ap27
								This:CombatCastCheck
								Toon:CastSpell[Vampiric Touch]
								This:CustOutput[${EnableMyOutput}, "Casting Vampiric Touch"]
							}
						;Cast Holy Fire
						if ${Toon.canCast[Holy Fire]} && !${Target.Buff[Holy Fire](exists)} && !${Me.Action[Shoot].AutoRepeat} && (${Target.PctHPs} > ${This.StartWandAtHp} || && ${Me.PctMana} > ${StartWandAtMp})
							{
								echo <${Time.Time24}>  ap28
								This:CombatCastCheck
								Toon:CastSpell[Holy Fire]
								This:CustOutput[${EnableMyOutput}, "Casting Holy Fire"]
							}
				}
			else
				{
					echo <${Time.Time24}>  ap29
;*****************************************************************************************************************
;***********************------------------------Custom Attack Order------------------------***********************
;*****************************************************************************************************************

					if ${Target.PctHPs} > ${This.StartWandAtHp} || && ${Me.PctMana} > ${StartWandAtMp}
						{
							echo <${Time.Time24}>  ap30
						if ${Toon.canCast[${This.SpellOne}]} && ${This.SpellOne.NotEqual["None"]} && !${Me.Casting} && ${LavishScript.RunningTime} > ${This.SpellOneTimer}
							{
								echo <${Time.Time24}>  ap31
								if (${This.SpellOne.Equal["Holy Fire"]} || ${This.SpellOne.Equal["Holy Nova"]} || ${This.SpellOne.Equal["Smite"]})
									{
										echo <${Time.Time24}>  ap32
										This:ShadowformRemove
									}
								This:CombatCastCheck
								Toon:CastSpell[${SpellOne}]
								This:CustOutput[${EnableMyOutput}, "Casting ${SpellOne}"]
								This.SpellOneTimerSum:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.SpellOneTimer} * 1000)}]]
								echo <${Time.Time24}>  ap33
							}


						if ${Toon.canCast[${This.SpellTwo}]} && ${This.SpellTwo.NotEqual["None"]} && !${Me.Casting} && ${LavishScript.RunningTime} > ${This.SpellTwoTimerSum}
							{
								echo <${Time.Time24}>  ap34
								if (${This.SpellTwo.Equal["Holy Fire"]}  || ${This.SpellTwo.Equal["Holy Nova"]} || ${This.SpellTwo.Equal["Smite"]})
									{
										echo <${Time.Time24}>  ap35
										This:ShadowformRemove
									}
								This:CombatCastCheck
								Toon:CastSpell[${SpellTwo}]
								This:CustOutput[${EnableMyOutput}, "Casting SpellTwo: ${SpellTwo}"]
								This.SpellTwoTimerSum:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.SpellTwoTimer} * 1000)}]]
								echo <${Time.Time24}>  ap36
							}

						if ${Toon.canCast[${This.SpellThree}]} && ${This.SpellThree.NotEqual["None"]} && !${Me.Casting} && ${LavishScript.RunningTime} > ${This.SpellThreeTimerSum}
							{
								echo <${Time.Time24}>  ap37
								if (${This.SpellThree.Equal["Holy Fire"]} || ${This.SpellThree.Equal["Holy Nova"]} || ${This.SpellThree.Equal["Smite"]})
									{
										echo <${Time.Time24}>  ap38
										This:ShadowformRemove
									}
								This:CombatCastCheck
								Toon:CastSpell[${SpellThree}]
								This:CustOutput[${EnableMyOutput}, "Casting SpellThree: ${SpellThree}"]
								This.SpellThreeTimerSum:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.SpellThreeTimer} * 1000)}]]
								echo <${Time.Time24}>  ap39
							}

						if ${Toon.canCast[${This.SpellFour}]} && ${This.SpellFour.NotEqual["None"]} && !${Me.Casting} && ${LavishScript.RunningTime} > ${This.SpellFourTimerSum}
							{
								echo <${Time.Time24}>  ap40
								if (${This.SpellFour.Equal["Holy Fire"]} || ${This.SpellFour.Equal["Holy Nova"]} || ${This.SpellFour.Equal["Smite"]})
									{
										echo <${Time.Time24}>  ap41
										This:ShadowformRemove
									}
								This:CombatCastCheck
								Toon:CastSpell[${SpellFour}]
								This:CustOutput[${EnableMyOutput}, "Casting SpellFour ${SpellFour}"]
								This.SpellFourTimerSum:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.SpellFourTimer} * 1000)}]]
								echo <${Time.Time24}>  ap42
							}

						if ${Toon.canCast[${This.SpellFive}]} && ${This.SpellFive.NotEqual["None"]} && !${Me.Casting} && ${LavishScript.RunningTime} > ${This.SpellFiveTimerSum}
							{
								echo <${Time.Time24}>  ap43
								if (${This.SpellFive.Equal["Holy Fire"]} || ${This.SpellFive.Equal["Holy Nova"]} || ${This.SpellFive.Equal["Smite"]})
									{
										echo <${Time.Time24}>  ap44
										This:ShadowformRemove
									}
								This:CombatCastCheck
								Toon:CastSpell[${SpellFive}]
								This:CustOutput[${EnableMyOutput}, "Casting SpellFive: ${SpellFive}"]
								This.SpellFiveTimerSum:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.SpellFiveTimer} * 1000)}]]
								echo <${Time.Time24}>  ap45
							}

						if ${Toon.canCast[${This.SpellSix}]} && ${This.SpellSix.NotEqual["None"]} && !${Me.Casting} && ${LavishScript.RunningTime} > ${This.SpellSixTimerSum}
							{
								echo <${Time.Time24}>  ap46
								if (${This.SpellSix.Equal["Holy Fire"]} || ${This.SpellSix.Equal["Holy Nova"]} || ${This.SpellSix.Equal["Smite"]})
									{
										echo <${Time.Time24}>  ap47
										This:ShadowformRemove
									}
								This:CombatCastCheck
								Toon:CastSpell[${SpellSix}]
								This:CustOutput[${EnableMyOutput}, "Casting SpellSix: ${SpellSix}"]
								This.SpellSixTimerSum:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.SpellSixTimer} * 1000)}]]
								echo <${Time.Time24}>  ap48
							}
					  }

				}
				echo <${Time.Time24}>  ap49
			return
  }


;*****************************************************************************************************************
;***********************------------------------Extra Priest Functions------------------------********************
;*****************************************************************************************************************

method SetDanger()
	{
		variable guidlist Aggros
		Aggros:Search[-units,-nearest,-aggro,-alive,-targetingme,-range 0-40]

		This.DangerLevel:Set[${DangerLevel} * 0.5]
		This.DangerLevel:Set[${DangerLevel} + ${Aggros.Count}*6.5]
		This.DangerLevel:Set[${DangerLevel} + ((100 - ${Me.PctMana})*0.10)]
		if ${Target.Level} > ${Me.Level}
		{
			This.DangerLevel:Set[${DangerLevel} + ((${Target.Level} - ${Me.Level})*2)]
		}

		elseif ${Me.Level} > ${Target.Level}
		{
			This.DangerLevel:Set[${DangerLevel} + ((${Target.Level} - ${Me.Level})*1)]
		}

		if ${Target.Classification.Equal[Elite]} || ${Target.Classification.Equal[RareElite]}
		{
			This.DangerLevel:Set[${DangerLevel} + 20]
		}

		if ${Target.PctHPs} < 25
		{
			This.DangerLevel:Set[${DangerLevel} - 10]
		}

		if ${DangerLevel} < 0
		{
			This.DangerLevel:Set[0]
		}

		if ${DangerLevel} > ${DangerVeryHigh}
		{
			This:CustOutput[${EnableMyOutput}, "Danger - Very High ${DangerLevel}"]
			This.Dangerlvl:Set[3]
			return
		}

		elseif ${DangerLevel} > ${DangerHigh}
		{
			This:CustOutput[${EnableMyOutput}, "Danger - High ${DangerLevel}"]
			This.Dangerlvl:Set[2]
			return
		}

		elseif ${DangerLevel} > ${DangerMedium}
		{
			;This:CustOutput[${EnableMyOutput}, "Danger - Medium ${DangerLevel}"]
			This.Dangerlvl:Set[1]
			return
		}

		else
		{
			;This:CustOutput[${EnableMyOutput}, "Danger - Low ${DangerLevel}"]
			This.Dangerlvl:Set[0]
			return
		}
	}

/*
======================================================================
Flee -
Run awaaaaaaaaaayyyy
======================================================================
*/
method FleeRoutine()
{
	if ${SafeX} == 0 && ${SafeY} == 0 && ${SafeZ} == 0
	{
		This:CustOutput[${EnableMyOutput}, "Flee - No safespot set yet - gonna have to keep fighting"]
		Fleeing:Set[FALSE]
	}
	if ${Dangerlvl} <= 1 || ${Math.Distance[${Me.X},${Me.Y},${SafeX},${SafeY}]} < 5
	{
		This:CustOutput[${EnableMyOutput}, "Flee - Things look safe -  lets try fighting again"]
		Fleeing:Set[FALSE]
	}
	if ${Me.Attacking}
	{
		This:CustOutput[${EnableMyOutput}, "Flee - Turning off autoattack"]
		WoWScript AttackTarget()
	}
	Navigator:MoveToLoc[${SafeX},${SafeY},${SafeZ}]
	This:CustOutput[${EnableMyOutput}, "Flee - Run Awaaaaaaaaaaaayyy...  Distance left to run: ${Math.Distance[${Me.X},${Me.Y},${SafeX},${SafeY}]}"]
	if ${Me.Buff[Shadowform](exists)}
	{
		This:ShadowformRemove
	}

	This:CustOutput[${EnableMyOutput}, "Flee - keep myself HoT'ed"]
	if ${Toon.canCast[Elune's Grace]}
		{
			This:SelfCastCheck
			Toon:CastSpell[Elune's Grace]
			return
		}
	if ${Toon.canCast[Renew]} && !${Me.Buff[Renew](exists)}
		{
			This:SelfCastCheck
			This:CustOutput[${EnableMyOutput}, "Flee - Renew"]
			Toon:CastSpell[Renew]
		}
	if ${Toon.canCast[Power Word: Shield]} && !${Me.Buff[Weakened Soul](exists)} && ${Me.PctMana} > 20
		{
			This:SelfCastCheck
			This:CustOutput[${EnableMyOutput}, "Flee - Shielding"]
			Toon:CastSpell[Power Word: Shield]
		}
	if ${Toon.canCast[Psychic Scream]}
		{
			This:CustOutput[${EnableMyOutput}, "Flee - Fearbomb!]
			Toon:CastSpell[Psychic Scream]
		}

	return
}

;*****************************************************************************************************************
;***********************------------------------Custom SpellTimer Check------------------------*******************
;*****************************************************************************************************************


method PullRangeCheck()
	{
		echo <${Time.Time24}>  prc1
		if ${Target.Distance} > ${This.MaxRanged}
			{
				echo <${Time.Time24}>  prc2
				This:CustOutput[${EnableMyOutput}, "Distance is ${Target.Distance} need to move closer"]
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
				wowpress -hold moveforward
			}

		if ${Target.Distance} < ${This.MaxRanged}-4
			{
				echo <${Time.Time24}>  prc3
				move -stop
			}
			echo <${Time.Time24}>  prc4
		return
	}

;*****************************************************************************************************************
;***********************------------------------Shadowform Removal------------------------************************
;*****************************************************************************************************************
method ShadowformRemove()
	{
		if ${Me.Buff[Shadowform](exists)}
			{	
				This:CustOutput[${EnableMyOutput}, "Removing Shadowform"]
				Me.Buff[Shadowform]:Remove
				Bot.RandomPause:Set[24]
			}
	 return
	 }




;*****************************************************************************************************************
;***********************--------------------Shadow Word: Death Check-------------------***************************
;*****************************************************************************************************************

member shadowWordDeathCheck()
	{
		echo <${Time.Time24}>  swdc1
		if ${Toon.canCast[Shadow Word: Death]} && ${Target.PctHPs} <= 15 && ${Me.PctHPs} >= 60
		{
			echo <${Time.Time24}>  swdc2
			This:Output["shadowWordDeathCheck returning TRUE"]
			return TRUE
		}
		echo <${Time.Time24}>  swdc3
		return FALSE
		This:Output["shadowWordDeathCheck returning FALSE"]
	}


;*****************************************************************************************************************
;***********************------------------------Self Cast Check------------------------***************************
;*****************************************************************************************************************
method SelfCastCheck()
	{
		echo <${Time.Time24}>  scc1
		if ${Me.Sitting}
			{
				echo <${Time.Time24}>  scc2
				Toon:Standup
			}

		if ${Me.Action["Shoot"].AutoRepeat}
			{
				echo <${Time.Time24}>  scc4
				Me.Action["Shoot"]:Use
				WowScript SpellStopCasting()
			}
		echo <${Time.Time24}>  scc5
		This:CustOutput[${EnableMyOutput}, "SelfCastCheck Complete"]
		return
	}

;*****************************************************************************************************************
;***********************------------------------Combat Cast Check------------------------*************************
;*****************************************************************************************************************
method CombatCastCheck()
	{
		if ${Me.Sitting}
			{
				Toon:Standup
			}

		if ${Movement.Speed}
			{
				move -stop
			}

		;Multi Aggro Targeting
		AggroList:Search[-units,-nearest,-aggro,-alive,-range 0-30]
		if ${AggroList.Count} >= 2
			{
				Target ${Unit[${Targeting.TargetCollection.Get[1]}].GUID}
			}

		if ${Target.Dead} || ${Target.GUID.Equal[${Me.GUID}]} || ${Target.IsMerchant}
			{
				WowScript ClearTarget()
				Target ${Unit[${Targeting.TargetCollection.Get[1]}].GUID}
				This:CustOutput[${EnableMyOutput}, "This is not a good Target"]
			}

		if ${Target.Name.NotEqual[${Me.Name}]} && ${Target(exists)}
			{
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
			}

		if ${Me.Action["Shoot"].AutoRepeat}
			{
				Me.Action["Shoot"]:Use
			}
			This:CustOutput[${EnableMyOutput}, "CombatCastCheck Complete"]
			return
	}

;*****************************************************************************************************************
;***********************------------------------Custom Buffing : Choose Buffs------------------------*************
;*****************************************************************************************************************
method CustomBuffing()
	{
		;Buff Power Word: Fortitude
		if ${This.canBuff[Power Word: Fortitude]} && ${UseFortitude}
			{
				This:SelfCastCheck
				Toon:CastSpell["Power Word: Fortitude"]
				This:CustOutput[${EnableMyOutput}, "Buffing Fortitude"]
			}

		;Buff Inner Fire
		if ${This.canBuff[Inner Fire]} && ${UseInnerFire}
			{
					This:SelfCastCheck
					This:CustOutput[${EnableMyOutput}, "Buffing Inner Fire"]
					Toon:CastSpell["Inner Fire"]
			}

		if ${This.canBuff[Shadow Protection]} && ${UseShadowProtection}
			{
				This:SelfCastCheck
				Toon:CastSpell["Shadow Protection"]
				This:CustOutput[${EnableMyOutput}, "Buffing Shadow Protection"]
			}
		if ${This.canBuff[Divine Spirit]}
			{
				This:SelfCastCheck
				Toon:CastSpell[Divine Spirit]
				This:CustOutput[${EnableMyOutput}, "Buffing Divine Spirit"]
			}
		return
	}

;*****************************************************************************************************************
;***********************------------------------Rugular Buffing :  Buff All------------------------***************
;*****************************************************************************************************************
 method RegularBuffing()
	{
		;Buff Power Word: Fortitude
		if ${This.canBuff[Power Word: Fortitude]}
			{
				This:SelfCastCheck
				Toon:CastSpell["Power Word: Fortitude"]
				This:CustOutput[${EnableMyOutput}, "Buffing Fortitude"]
			}

		;Buff Inner Fire
		if ${This.canBuff[Inner Fire]}
			{
					This:SelfCastCheck
					This:CustOutput[${EnableMyOutput}, "Buffing Inner Fire"]
					Toon:CastSpell["Inner Fire"]
			}

		;Buff Shadow Protection
		if ${This.canBuff[Shadow Protection]}
			{
				This:SelfCastCheck
				Toon:CastSpell["Shadow Protection"]
				This:CustOutput[${EnableMyOutput}, "Buffing Shadow Protection"]
			}
		if ${This.canBuff[Divine Spirit]}
			{
				This:SelfCastCheck
				Toon:CastSpell[Divine Spirit]
				This:CustOutput[${EnableMyOutput}, "Buffing Divine Spirit"]
			}
		return
	}


;*****************************************************************************************************************
;***********************---------------Buff Check. (Include in oToon sometime maybe?)--------------***************
;*****************************************************************************************************************
	
	/* You can use {This.canBuff[w/espellhere]} to check if you can buff yourself. OR ${This.canBuff[SW:P, "Target"]} to send a buff on your target. (SW:P for example)*/
	member canBuff(string spellname, string myObj="Me")
	{
		if ${Toon.canCast[${spellname}]} && !${${myObj}.Buff[${spellname}](exists)}
		{
			return TRUE
		}
		return FALSE
	}
	
	
;*****************************************************************************************************************
;***********************-----------------------------Decursing Check-------------------------------***************
;*****************************************************************************************************************
	
	member NeedDecurse()
		{
			if ${Me.Buff.Harmful}
			{
				if ${Me.Buff.Harmful.DispelType.Equal[Magic]} && ${Toon.canCast[Dispel Magic]}
				{
					return TRUE
				}
				if ${Me.Buff.Harmful.DispelType.Equal[Disease]} && ${Toon.canCast[Cure Disease]}
				{
					return TRUE
				}
			}
			return FALSE
		}
	
	
;*****************************************************************************************************************
;***********************------------------------Check For Scrolls (Thx oog)------------------------***************
;*****************************************************************************************************************

	member checkForScrolls()
	{
		if ${Toon.canUseScroll[Spirit]}
		{
				Target ${Me.GUID}
				This:Output["Let's use the scroll of Spirit"]
				return "Spirit"
		}
		if ${Toon.canUseScroll[Intellect]}
		{
				Target ${Me.GUID}
				This:Output["Let's use the scroll of Intellect"]
				return "Intellect"
		}
		return "NONE"
	}



;*****************************************************************************************************************
;***********************----------------------Shadowmeld Check----------------------*****************************
;*****************************************************************************************************************

	member shouldShadowmeld()
	{
		if ${Me.Race.Equal["Night Elf"]}
		{
			if ${This.canBuff[Shadowmeld]}
			{
				return TRUE
			}
		}
		return FALSE
	}

;*****************************************************************************************************************
;***********************------------------------Custom Output------------------------*****************************
;*****************************************************************************************************************
method CustOutput(bool enableOutput, string myMessage)
	{
		if ${enableOutput}
			{
				UIElement[ClassGUI].FindChild[Console]:Echo["${Time.Time24}: ${myMessage}"]
				;This:Output["${myMessage}"]
			}
		return
	}




;*****************************************************************************************************************
;***********************------------------------GUI Stuff :P-------------------------*****************************
;*****************************************************************************************************************
	
	
	
method Initialize()
	{
		This:CustOutput[${EnableMyOutput}, "============================"]
		This:CustOutput[${EnableMyOutput}, "Artimusp/Apoc's Priest Routine v2.31"]
		This:CustOutput[${EnableMyOutput}, "============================"]
		
		This:LoadConfig
		This:InitPriestGui
	}


method InitPriestGui()
	{
		variable int i = 1

		;*********************;
		;***---ListBoxes---***;
		;*********************;

		;***Spell Tab List Boxes***
		for (i:Set[1] ; ${i} <= ${UIElement[cmbSelectPullSpell@Spells@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.MyPullSpell.Equal["${UIElement[cmbSelectPullSpell@Spells@Pages@ClassGUI].Item[${i}].Text}"]}
					{
						UIElement[cmbSelectPullSpell@Spells@Pages@ClassGUI]:SelectItem[${i}]
					}
			}

		;***Custom Attack Order List Boxes***
		for (i:Set[1] ; ${i} <= ${UIElement[cmbCustSpellOne@CustomAtkOrder@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.SpellOne.Equal["${UIElement[cmbCustSpellOne@CustomAtkOrder@Pages@ClassGUI].Item[${i}].Text}"]}
					{
						UIElement[cmbCustSpellOne@CustomAtkOrder@Pages@ClassGUI]:SelectItem[${i}]
					}
			}
		for (i:Set[1] ; ${i} <= ${UIElement[cmbCustSpellTwo@CustomAtkOrder@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.SpellTwo.Equal["${UIElement[cmbCustSpellTwo@CustomAtkOrder@Pages@ClassGUI].Item[${i}].Text}"]}
					{
						UIElement[cmbCustSpellTwo@CustomAtkOrder@Pages@ClassGUI]:SelectItem[${i}]
					}
			}
		for (i:Set[1] ; ${i} <= ${UIElement[cmbCustSpellThree@CustomAtkOrder@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.SpellThree.Equal["${UIElement[cmbCustSpellThree@CustomAtkOrder@Pages@ClassGUI].Item[${i}].Text}"]}
					{
						UIElement[cmbCustSpellThree@CustomAtkOrder@Pages@ClassGUI]:SelectItem[${i}]
					}
			}
		for (i:Set[1] ; ${i} <= ${UIElement[cmbCustSpellFour@CustomAtkOrder@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.SpellFour.Equal["${UIElement[cmbCustSpellFour@CustomAtkOrder@Pages@ClassGUI].Item[${i}].Text}"]}
					{
						UIElement[cmbCustSpellFour@CustomAtkOrder@Pages@ClassGUI]:SelectItem[${i}]
					}
			}
		for (i:Set[1] ; ${i} <= ${UIElement[cmbCustSpellFive@CustomAtkOrder@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.SpellFive.Equal["${UIElement[cmbCustSpellFive@CustomAtkOrder@Pages@ClassGUI].Item[${i}].Text}"]}
					{
						UIElement[cmbCustSpellFive@CustomAtkOrder@Pages@ClassGUI]:SelectItem[${i}]
					}
			}
		for (i:Set[1] ; ${i} <= ${UIElement[cmbCustSpellSix@CustomAtkOrder@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.SpellSix.Equal["${UIElement[cmbCustSpellSix@CustomAtkOrder@Pages@ClassGUI].Item[${i}].Text}"]}
					{
						UIElement[cmbCustSpellSix@CustomAtkOrder@Pages@ClassGUI]:SelectItem[${i}]
					}
			}


		;***Heal Tab List Boxes***
		for (i:Set[1] ; ${i} <= ${UIElement[cmbHealSpellOne@Heals@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.HealSpellOne.Equal["${UIElement[cmbHealSpellOne@Heals@Pages@ClassGUI].Item[${i}].Text}"]}
					{
						UIElement[cmbHealSpellOne@Heals@Pages@ClassGUI]:SelectItem[${i}]
					}
			}
		for (i:Set[1] ; ${i} <= ${UIElement[cmbHealSpellTwo@Heals@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.HealSpellTwo.Equal["${UIElement[cmbHealSpellTwo@Heals@Pages@ClassGUI].Item[${i}].Text}"]}
					{
						UIElement[cmbHealSpellTwo@Heals@Pages@ClassGUI]:SelectItem[${i}]
					}
			}
		for (i:Set[1] ; ${i} <= ${UIElement[cmbHealSpellThree@Heals@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.HealSpellThree.Equal["${UIElement[cmbHealSpellThree@Heals@Pages@ClassGUI].Item[${i}].Text}"]}
					{
						UIElement[cmbHealSpellThree@Heals@Pages@ClassGUI]:SelectItem[${i}]
					}
			}
		for (i:Set[1] ; ${i} <= ${UIElement[cmbHealSpellFour@Heals@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.HealSpellFour.Equal["${UIElement[cmbHealSpellFour@Heals@Pages@ClassGUI].Item[${i}].Text}"]}
					{
						UIElement[cmbHealSpellFour@Heals@Pages@ClassGUI]:SelectItem[${i}]
					}
			}
		for (i:Set[1] ; ${i} <= ${UIElement[cmbHealSpellFive@Heals@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.HealSpellFive.Equal["${UIElement[cmbHealSpellFive@Heals@Pages@ClassGUI].Item[${i}].Text}"]}
					{
						UIElement[cmbHealSpellFive@Heals@Pages@ClassGUI]:SelectItem[${i}]
					}
			}


		;**********************;
		;***---CheckBoxes---***;
		;**********************;

		;***Spell Tab Check Boxes***
		if ${This.UseWand}
			{
				UIElement[chkBoxUseWand@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseSmite}
			{
				UIElement[chkBoxUseSmite@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseMindBlast}
			{
				UIElement[chkBoxUseMindBlast@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseMindFlay}
			{
				UIElement[chkBoxUseMindFlay@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseShadowWordPain}
			{
				UIElement[chkBoxUseShadowWordPain@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.UsePsychicScream}
			{
				UIElement[chkBoxUsePsychicScream@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseShcklUndead}
			{
				UIElement[chkBoxUseShcklUndead@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseShieldOnPull}
			{
				UIElement[chkBoxUseShieldOnPull@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseVampiricTouch}
			{
				UIElement[chkBoxUseVampiricTouch@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseVampiricEmbrace}
			{
				UIElement[chkBoxUseVampiricEmbrace@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseShadowWordDeath}
			{
				UIElement[chkBoxUseShadowWordDeath@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseSilence}
			{
				UIElement[chkBoxUseSilence@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.MindFlayRunners}
			{
				UIElement[chkBoxMindFlayRunners@Spells@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseInnerFocus}
			{
				UIElement[chkBoxUseInnerFocus@Spells@Pages@ClassGUI]:SetChecked
			}
			
			

		;***CustomAtk Tab Check Boxes***
		if ${This.UseCustomAtkOrder}
			{
				UIElement[chkBoxUseCustomAtkOrder@CustomAtkOrder@Pages@ClassGUI]:SetChecked
			}

		;***Buffs/Cures Tab Check Boxes***
		if ${This.UseCustomBuffs}
			{
				UIElement[chkBoxEnableChooseBuffs@Buffs/Cures@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseShield}
			{
				UIElement[chkBoxUseShield@Buffs/Cures@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseShadowform}
			{
				UIElement[chkBoxUseShadowform@Buffs/Cures@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseFortitude}
			{
				UIElement[chkBoxUsePwrWordFort@Buffs/Cures@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseShadowProtection}
			{
				UIElement[chkBoxUseShadowProt@Buffs/Cures@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseInnerFire}
			{
				UIElement[chkBoxUseInnerFire@Buffs/Cures@Pages@ClassGUI]:SetChecked
			}

		;***Heal Tab***
		if ${This.UseHealPots}
			{
				UIElement[chkBoxUseHealPots@Heals@Pages@ClassGUI]:SetChecked
			}


		;***Rest Tab***
		if ${This.UseRest}
			{
				UIElement[chkBoxUseRest@Rest@Pages@ClassGUI]:SetChecked
			}
		if ${This.UseBandages}
			{
				UIElement[chkBoxUseBandages@Rest@Pages@ClassGUI]:SetChecked
			}


		;***OtherSettings Tab***
		if ${This.EnableMyOutput}
			{
				UIElement[chkBoxShowOutput@OtherSettings@Pages@ClassGUI]:SetChecked
			}


		;*******************;
		;***---Sliders---***;
		;*******************;

		;***Spell Tab Sliders***
		if ${This.StartWandAtHp} != ${UIElement[sldWandAt@Spells@Pages@ClassGUI].Value}
			{
				UIElement[sldWandAt@Spells@Pages@ClassGUI]:SetValue[${This.StartWandAtHp}]
			}
		if ${This.StartWandAtHp} != ${UIElement[sldWandAtPctMp@Spells@Pages@ClassGUI].Value}
			{
				UIElement[sldWandAtPctMp@Spells@Pages@ClassGUI]:SetValue[${This.StartWandAtMp}]
			}

		;***CustomAtkOrder Tab Sliders***
		if ${This.SpellOneTimer} != ${UIElement[sldSpellOneTimer@CustomAtkOrder@Pages@ClassGUI].Value}
			{
				UIElement[sldSpellOneTimer@CustomAtkOrder@Pages@ClassGUI]:SetValue[${This.SpellOneTimer}]
			}
		if ${This.SpellTwoTimer} != ${UIElement[sldSpellTwoTimer@CustomAtkOrder@Pages@ClassGUI].Value}
			{
				UIElement[sldSpellTwoTimer@CustomAtkOrder@Pages@ClassGUI]:SetValue[${This.SpellTwoTimer}]
			}
		if ${This.SpellThreeTimer} != ${UIElement[sldSpellThreeTimer@CustomAtkOrder@Pages@ClassGUI].Value}
			{
				UIElement[sldSpellThreeTimer@CustomAtkOrder@Pages@ClassGUI]:SetValue[${This.SpellThreeTimer}]
			}
		if ${This.SpellFourTimer} != ${UIElement[sldSpellFourTimer@CustomAtkOrder@Pages@ClassGUI].Value}
			{
				UIElement[sldSpellFourTimer@CustomAtkOrder@Pages@ClassGUI]:SetValue[${This.SpellFourTimer}]
			}
		if ${This.SpellFiveTimer} != ${UIElement[sldSpellFiveTimer@CustomAtkOrder@Pages@ClassGUI].Value}
			{
				UIElement[sldSpellFiveTimer@CustomAtkOrder@Pages@ClassGUI]:SetValue[${This.SpellFiveTimer}]
			}
		if ${This.SpellSixTimer} != ${UIElement[sldSpellSixTimer@CustomAtkOrder@Pages@ClassGUI].Value}
			{
				UIElement[sldSpellSixTimer@CustomAtkOrder@Pages@ClassGUI]:SetValue[${This.SpellSixTimer}]
			}

		;***Heal Tab Sliders***
		if ${This.UseHealSpellOneAt} != ${UIElement[sldUseHealSpellOneAt@Heals@Pages@ClassGUI].Value}
			{
				UIElement[sldUseHealSpellOneAt@Heals@Pages@ClassGUI]:SetValue[${This.UseHealSpellOneAt}]
			}
		if ${This.UseHealSpellTwoAt} != ${UIElement[sldUseHealSpellTwoAt@Heals@Pages@ClassGUI].Value}
			{
				UIElement[sldUseHealSpellTwoAt@Heals@Pages@ClassGUI]:SetValue[${This.UseHealSpellTwoAt}]
			}
		if ${This.UseHealSpellThreeAt} != ${UIElement[sldUseHealSpellThreeAt@Heals@Pages@ClassGUI].Value}
			{
				UIElement[sldUseHealSpellThreeAt@Heals@Pages@ClassGUI]:SetValue[${This.UseHealSpellThreeAt}]
			}
		if ${This.UseHealSpellFourAt} != ${UIElement[sldUseHealSpellFourAt@Heals@Pages@ClassGUI].Value}
			{
				UIElement[sldUseHealSpellFourAt@Heals@Pages@ClassGUI]:SetValue[${This.UseHealSpellFourAt}]
			}
		if ${This.UseHealSpellFiveAt} != ${UIElement[sldUseHealSpellFiveAt@Heals@Pages@ClassGUI].Value}
			{
				UIElement[sldUseHealSpellFiveAt@Heals@Pages@ClassGUI]:SetValue[${This.UseHealSpellFiveAt}]
			}
		if ${This.UseHealPotsAt} != ${UIElement[sldUseHealPotsAt@Heals@Pages@ClassGUI].Value}
			{
				UIElement[sldUseHealPotsAt@Heals@Pages@ClassGUI]:SetValue[${This.UseHealPotsAt}]
			}


		;***Rest Tab***
		if ${This.RestMP} != ${UIElement[sldRestAtMp@Rest@Pages@ClassGUI].Value}
			{
				UIElement[sldRestAtMp@Rest@Pages@ClassGUI]:SetValue[${This.RestMP}]
			}
		if ${This.RestHP} != ${UIElement[sldRestAtHp@Rest@Pages@ClassGUI].Value}
			{
				UIElement[sldRestAtHp@Rest@Pages@ClassGUI]:SetValue[${This.RestHP}]
			}
		if ${This.UseBandagesAt} != ${UIElement[sldUseBandagesAt@Rest@Pages@ClassGUI].Value}
			{
				UIElement[sldUseBandagesAt@Rest@Pages@ClassGUI]:SetValue[${This.UseBandagesAt}]
			}
		if ${This.SpiritTapMP} != ${UIElement[sldSpiritTapMP@Rest@Pages@ClassGUI].Value}
			{
				UIElement[sldSpiritTapMP@Rest@Pages@ClassGUI]:SetValue[${This.SpiritTapMP}]
			}
	}

 method ClassGUIChange(string Action)
	{
		switch ${Action}
		{
		;***Spell Tab ListBoxes***
		case PullSpell
				if ${UIElement[cmbSelectPullSpell@Spells@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.MyPullSpell:Set[${UIElement[cmbSelectPullSpell@Spells@Pages@ClassGUI].SelectedItem}]
				}
				break

		;***Custom Attack Tab ListBoxes***
		case CmbCustSpellOne
				if ${UIElement[cmbCustSpellOne@CustomAtkOrder@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.SpellOne:Set[${UIElement[cmbCustSpellOne@CustomAtkOrder@Pages@ClassGUI].SelectedItem}]
				}
				break
		case CmbCustSpellTwo
				if ${UIElement[cmbCustSpellTwo@CustomAtkOrder@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.SpellTwo:Set[${UIElement[cmbCustSpellTwo@CustomAtkOrder@Pages@ClassGUI].SelectedItem}]
				}
				break
		case CmbCustSpellThree
				if ${UIElement[cmbCustSpellThree@CustomAtkOrder@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.SpellThree:Set[${UIElement[cmbCustSpellThree@CustomAtkOrder@Pages@ClassGUI].SelectedItem}]
				}
				break
		case CmbCustSpellFour
				if ${UIElement[cmbCustSpellFour@CustomAtkOrder@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.SpellFour:Set[${UIElement[cmbCustSpellFour@CustomAtkOrder@Pages@ClassGUI].SelectedItem}]
				}
				break
		case CmbCustSpellFive
				if ${UIElement[cmbCustSpellFive@CustomAtkOrder@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.SpellFive:Set[${UIElement[cmbCustSpellFive@CustomAtkOrder@Pages@ClassGUI].SelectedItem}]
				}
				break
		case CmbCustSpellSix
				if ${UIElement[cmbCustSpellSix@CustomAtkOrder@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.SpellSix:Set[${UIElement[cmbCustSpellSix@CustomAtkOrder@Pages@ClassGUI].SelectedItem}]
				}
				break
		case CmbCustSpellSeven
				if ${UIElement[cmbCustSpellSeven@CustomAtkOrder@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.SpellSeven:Set[${UIElement[cmbCustSpellSeven@CustomAtkOrder@Pages@ClassGUI].SelectedItem}]
				}
				break
		case CmbCustSpellEight
				if ${UIElement[cmbCustSpellEight@CustomAtkOrder@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.SpellEight:Set[${UIElement[cmbCustSpellEight@CustomAtkOrder@Pages@ClassGUI].SelectedItem}]
				}
				break

		;***Heal Tab ListBoxes***
		case BoxHealSpellOne
				if ${UIElement[cmbHealSpellOne@Heals@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.HealSpellOne:Set[${UIElement[cmbHealSpellOne@Heals@Pages@ClassGUI].SelectedItem}]
				}
				break
		 case BoxHealSpellTwo
				if ${UIElement[cmbHealSpellTwo@Heals@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.HealSpellTwo:Set[${UIElement[cmbHealSpellTwo@Heals@Pages@ClassGUI].SelectedItem}]
				}
				break
		 case BoxHealSpellThree
				if ${UIElement[cmbHealSpellThree@Heals@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.HealSpellThree:Set[${UIElement[cmbHealSpellThree@Heals@Pages@ClassGUI].SelectedItem}]
				}
				break
		 case BoxHealSpellFour
				if ${UIElement[cmbHealSpellFour@Heals@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.HealSpellFour:Set[${UIElement[cmbHealSpellFour@Heals@Pages@ClassGUI].SelectedItem}]
				}
				break
		 case BoxHealSpellFive
				if ${UIElement[cmbHealSpellFive@Heals@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
				This.HealSpellFive:Set[${UIElement[cmbHealSpellFive@Spells@Pages@ClassGUI].SelectedItem}]
				}
				break

		;***Spell Tab Check Boxes***
		case ChkUseWand
			if ${UIElement[chkBoxUseWand@Spells@Pages@ClassGUI].Checked}
				{
				This.UseWand:Set[TRUE]
				}
			if !${UIElement[chkBoxUseWand@Spells@Pages@ClassGUI].Checked}
				{
				This.UseWand:Set[FALSE]
				}
				break
			case ChkUseMindFlay
			if ${UIElement[chkBoxUseMindFlay@Spells@Pages@ClassGUI].Checked}
				{
				This.UseMindFlay:Set[TRUE]
				}
			if !${UIElement[chkBoxUseMindFlay@Spells@Pages@ClassGUI].Checked}
				{
				This.UseMindFlay:Set[FALSE]
				}
				break
			case ChkUseSmite
			if ${UIElement[chkBoxUseSmite@Spells@Pages@ClassGUI].Checked}
				{
				This.UseSmite:Set[TRUE]
				}
			if !${UIElement[chkBoxUseSmite@Spells@Pages@ClassGUI].Checked}
				{
				This.UseSmite:Set[FALSE]
				}
				break
			case ChkUseMindBlast
			if ${UIElement[chkBoxUseMindBlast@Spells@Pages@ClassGUI].Checked}
				{
				This.UseMindBlast:Set[TRUE]
				}
			if !${UIElement[chkBoxUseMindBlast@Spells@Pages@ClassGUI].Checked}
				{
				This.UseMindBlast:Set[FALSE]
				}
				break
			case ChkUseShadowWordPain
			if ${UIElement[chkBoxUseShadowWordPain@Spells@Pages@ClassGUI].Checked}
				{
				This.UseShadowWordPain:Set[TRUE]
				}
			if !${UIElement[chkBoxUseShadowWordPain@Spells@Pages@ClassGUI].Checked}
				{
				This.UseShadowWordPain:Set[FALSE]
				}
				break
			case ChkUsePsychicScream
			if ${UIElement[chkBoxUsePsychicScream@Spells@Pages@ClassGUI].Checked}
				{
				This.UsePsychicScream:Set[TRUE]
				}
			if !${UIElement[chkBoxUsePsychicScream@Spells@Pages@ClassGUI].Checked}
				{
				This.UsePsychicScream:Set[FALSE]
				}
				break
			case ChkUseShcklUndead
			if ${UIElement[chkBoxUseShcklUndead@Spells@Pages@ClassGUI].Checked}
				{
				This.UseShcklUndead:Set[TRUE]
				}
			if !${UIElement[chkBoxUseShcklUndead@Spells@Pages@ClassGUI].Checked}
				{
				This.UseShcklUndead:Set[FALSE]
				}
				break
			case ChkUseShieldOnPull
			if ${UIElement[chkBoxUseShieldOnPull@Spells@Pages@ClassGUI].Checked}
				{
				This.UseShieldOnPull:Set[TRUE]
				}
			if !${UIElement[chkBoxUseShieldOnPull@Spells@Pages@ClassGUI].Checked}
				{
				This.UseShieldOnPull:Set[FALSE]
				}
				break
			case ChkUseVampiricTouch
			if ${UIElement[chkBoxUseVampiricTouch@Spells@Pages@ClassGUI].Checked}
				{
				This.UseVampiricTouch:Set[TRUE]
				}
			if !${UIElement[chkBoxUseVampiricTouch@Spells@Pages@ClassGUI].Checked}
				{
				This.UseVampiricTouch:Set[FALSE]
				}
				break
			case ChkUseVampiricEmbrace
			if ${UIElement[chkBoxUseVampiricEmbrace@Spells@Pages@ClassGUI].Checked}
				{
				This.UseVampiricEmbrace:Set[TRUE]
				}
			if !${UIElement[chkBoxUseVampiricEmbrace@Spells@Pages@ClassGUI].Checked}
				{
				This.UseVampiricEmbrace:Set[FALSE]
				}
				break
			case ChkUseShadowWordDeath
			if ${UIElement[chkBoxUseShadowWordDeath@Spells@Pages@ClassGUI].Checked}
				{
				This.UseShadowWordDeath:Set[TRUE]
				}
			if !${UIElement[chkBoxUseShadowWordDeath@Spells@Pages@ClassGUI].Checked}
				{
				This.UseShadowWordDeath:Set[FALSE]
				}
				break
			case ChkUseSilence
			if ${UIElement[chkBoxUseSilence@Spells@Pages@ClassGUI].Checked}
				{
				This.UseSilence:Set[TRUE]
				}
			if !${UIElement[chkBoxUseSilence@Spells@Pages@ClassGUI].Checked}
				{
				This.UseSilence:Set[FALSE]
				}
				break
			case ChkMindFlayRunners
			if ${UIElement[chkBoxMindFlayRunners@Spells@Pages@ClassGUI].Checked}
				{
				This.MindFlayRunners:Set[TRUE]
				}
			if !${UIElement[chkBoxMindFlayRunners@Spells@Pages@ClassGUI].Checked}
				{
				This.MindFlayRunners:Set[FALSE]
				}
				break
			case ChkUseInnerFocus
			if ${UIElement[chkBoxUseInnerFocus@Spells@Pages@ClassGUI].Checked}
				{
				This.UseInnerFocus:Set[TRUE]
				}
			if !${UIElement[chkBoxUseInnerFocus@Spells@Pages@ClassGUI].Checked}
				{
				This.UseInnerFocus:Set[FALSE]
				}
				break

			;***Custom Attack Order Check Boxes***
			case ChkUseCustomAtkOrder
			if ${UIElement[chkBoxUseCustomAtkOrder@CustomAtkOrder@Pages@ClassGUI].Checked}
				{
				This.UseCustomAtkOrder:Set[TRUE]
				}
			if !${UIElement[chkBoxUseCustomAtkOrder@CustomAtkOrder@Pages@ClassGUI].Checked}
				{
				This.UseCustomAtkOrder:Set[FALSE]
				}
				break

			;***Heal Tab Check Boxes***
			case chkUseUseHealPots
			if ${UIElement[chkBoxUseHealPots@Heals@Pages@ClassGUI].Checked}
				{
				This.UseHealPots:Set[TRUE]
				}
			if !${UIElement[chkBoxUseHealPots@Heals@Pages@ClassGUI].Checked}
				{
				This.UseHealPots:Set[FALSE]
				}
				break


			;***Rest Tab***
			case ChkUseRest
			if ${UIElement[chkBoxUseRest@Rest@Pages@ClassGUI].Checked}
				{
				This.UseRest:Set[TRUE]
				}
			if !${UIElement[chkBoxUseRest@Rest@Pages@ClassGUI].Checked}
				{
				This.UseRest:Set[FALSE]
				}
				break
			case chkUseBandages
			if ${UIElement[chkBoxUseBandages@Rest@Pages@ClassGUI].Checked}
				{
				This.UseBandages:Set[TRUE]
				}
			if !${UIElement[chkBoxUseBandages@Rest@Pages@ClassGUI].Checked}
				{
				This.UseBandages:Set[FALSE]
				}
				break


			;***Buffs/Cures Tab***
			case ChkEnableChooseBuffs
			if ${UIElement[chkBoxEnableChooseBuffs@Buffs/Cures@Pages@ClassGUI].Checked}
				{
				This.UseCustomBuffs:Set[TRUE]
				}
			if !${UIElement[chkBoxEnableChooseBuffs@Buffs/Cures@Pages@ClassGUI].Checked}
				{
				This.UseCustomBuffs:Set[FALSE]
				}
				break
			case ChkUseShield
			if ${UIElement[chkBoxUseShield@Buffs/Cures@Pages@ClassGUI].Checked}
				{
				This.UseShield:Set[TRUE]
				}
			if !${UIElement[chkBoxUseShield@Buffs/Cures@Pages@ClassGUI].Checked}
				{
				This.UseShield:Set[FALSE]
				}
				break
			case ChkUseShadowform
			if ${UIElement[chkBoxUseShadowform@Buffs/Cures@Pages@ClassGUI].Checked}
				{
				This.UseShadowform:Set[TRUE]
				}
			if !${UIElement[chkBoxUseShadowform@Buffs/Cures@Pages@ClassGUI].Checked}
				{
				This.UseShadowform:Set[FALSE]
				}
				break
			case ChkUseFortitude
			if ${UIElement[chkBoxUsePwrWordFort@Buffs/Cures@Pages@ClassGUI].Checked}
				{
				This.UseFortitude:Set[TRUE]
				}
			if !${UIElement[chkBoxUsePwrWordFort@Buffs/Cures@Pages@ClassGUI].Checked}
				{
				This.UseFortitude:Set[FALSE]
				}
				break
			case ChkUseShadowProtection
			if ${UIElement[chkBoxUseShadowProt@Buffs/Cures@Pages@ClassGUI].Checked}
				{
				This.UseShadowProtection:Set[TRUE]
				}
			if !${UIElement[chkBoxUseShadowProt@Buffs/Cures@Pages@ClassGUI].Checked}
				{
				This.UseShadowProtection:Set[FALSE]
				}
				break
			case ChkUseInnerFire
			if ${UIElement[chkBoxUseInnerFire@Buffs/Cures@Pages@ClassGUI].Checked}
				{
				This.UseInnerFire:Set[TRUE]
				}
			if !${UIElement[chkBoxUseInnerFire@Buffs/Cures@Pages@ClassGUI].Checked}
				{
				This.UseInnerFire:Set[FALSE]
				}
				break

			;***OtherSettings Tab***
			case ChkEnableOutput
			if ${UIElement[chkBoxShowOutput@OtherSettings@Pages@ClassGUI].Checked}
				{
				This.EnableMyOutput:Set[TRUE]
				}
			if !${UIElement[chkBoxShowOutput@OtherSettings@Pages@ClassGUI].Checked}
				{
				This.EnableMyOutput:Set[FALSE]
				}
				break


			;*******************;
			;***---Sliders---***;
			;*******************;

			;***Spell Tab Sliders***
			case UseWandAtTargetHp
			if ${UIElement[sldWandAt@Spells@Pages@ClassGUI].Value(exists)}
				{
				This.StartWandAtHp:Set[${UIElement[sldWandAt@Spells@Pages@ClassGUI].Value}]
				}
				break
			case UseWandAtPctMp
			if ${UIElement[sldWandAtPctMp@Spells@Pages@ClassGUI].Value(exists)}
				{
				This.StartWandAtMp:Set[${UIElement[sldWandAtPctMp@Spells@Pages@ClassGUI].Value}]
				}
				break

			;***CustomAtkOrder Tab Sliders***
			case SldSpellOneTimer
			if ${UIElement[sldSpellOneTimer@CustomAtkOrder@Pages@ClassGUI].Value(exists)}
				{
				This.SpellOneTimer:Set[${UIElement[sldSpellOneTimer@CustomAtkOrder@Pages@ClassGUI].Value}]
				}
				break
			case SldSpellTwoTimer
			if ${UIElement[sldSpellTwoTimer@CustomAtkOrder@Pages@ClassGUI].Value(exists)}
				{
				This.SpellTwoTimer:Set[${UIElement[sldSpellTwoTimer@CustomAtkOrder@Pages@ClassGUI].Value}]
				}
				break
			case SldSpellThreeTimer
			if ${UIElement[sldSpellThreeTimer@CustomAtkOrder@Pages@ClassGUI].Value(exists)}
				{
				This.SpellThreeTimer:Set[${UIElement[sldSpellThreeTimer@CustomAtkOrder@Pages@ClassGUI].Value}]
				}
				break
			case SldSpellFourTimer
			if ${UIElement[sldSpellFourTimer@CustomAtkOrder@Pages@ClassGUI].Value(exists)}
				{
				This.SpellFourTimer:Set[${UIElement[sldSpellFourTimer@CustomAtkOrder@Pages@ClassGUI].Value}]
				}
				break
			case SldSpellFiveTimer
			if ${UIElement[sldSpellFiveTimer@CustomAtkOrder@Pages@ClassGUI].Value(exists)}
				{
				This.SpellFiveTimer:Set[${UIElement[sldSpellFiveTimer@CustomAtkOrder@Pages@ClassGUI].Value}]
				}
				break
			case SldSpellSixTimer
			if ${UIElement[sldSpellSixTimer@CustomAtkOrder@Pages@ClassGUI].Value(exists)}
				{
				This.SpellSixTimer:Set[${UIElement[sldSpellSixTimer@CustomAtkOrder@Pages@ClassGUI].Value}]
				}
				break

			;***Heal Tab Sliders***
			case SldUseHealPotsAt
			if ${UIElement[sldUseHealPotsAt@Heals@Pages@ClassGUI].Value(exists)}
				{
				This.UseHealPotsAt:Set[${UIElement[sldUseHealPotsAt@Heals@Pages@ClassGUI].Value}]
				}
				break

			case sldUseHealSpellOneAt
			if ${UIElement[sldUseHealSpellOneAt@Heals@Pages@ClassGUI].Value(exists)}
				{
				This.UseHealSpellOneAt:Set[${UIElement[sldUseHealSpellOneAt@Heals@Pages@ClassGUI].Value}]
				}
				break
			case sldUseHealSpellTwoAt
			if ${UIElement[sldUseHealSpellTwoAt@Heals@Pages@ClassGUI].Value(exists)}
				{
				This.UseHealSpellTwoAt:Set[${UIElement[sldUseHealSpellTwoAt@Heals@Pages@ClassGUI].Value}]
				}
				break
			case sldUseHealSpellThreeAt
			if ${UIElement[sldUseHealSpellThreeAt@Heals@Pages@ClassGUI].Value(exists)}
				{
				This.UseHealSpellThreeAt:Set[${UIElement[sldUseHealSpellThreeAt@Heals@Pages@ClassGUI].Value}]
				}
				break
			case sldUseHealSpellFourAt
			if ${UIElement[sldUseHealSpellFourAt@Heals@Pages@ClassGUI].Value(exists)}
				{
				This.UseHealSpellFourAt:Set[${UIElement[sldUseHealSpellFourAt@Heals@Pages@ClassGUI].Value}]
				}
				break
			case sldUseHealSpellFiveAt
			if ${UIElement[sldUseHealSpellFiveAt@Heals@Pages@ClassGUI].Value(exists)}
				{
				This.UseHealSpellFiveAt:Set[${UIElement[sldUseHealSpellFiveAt@Heals@Pages@ClassGUI].Value}]
				}
				break

							;***Rest Tab Sliders***
			case SldRestAtMp
			if ${UIElement[sldRestAtMp@Rest@Pages@ClassGUI].Value(exists)}
				{
				This.RestMP:Set[${UIElement[sldRestAtMp@Rest@Pages@ClassGUI].Value}]
				}
				break
			case SldRestAtHp
			if ${UIElement[sldRestAtHp@Rest@Pages@ClassGUI].Value(exists)}
				{
				This.RestHP:Set[${UIElement[sldRestAtHp@Rest@Pages@ClassGUI].Value}]
				}
				break
			case SldUseBandagesAt
			if ${UIElement[sldUseBandagesAt@Rest@Pages@ClassGUI].Value(exists)}
				{
				This.UseBandagesAt:Set[${UIElement[sldUseBandagesAt@Rest@Pages@ClassGUI].Value}]
				}
				break
			case SldSpiritTapMP
			if ${UIElement[sldSpiritTapMP@Rest@Pages@ClassGUI].Value(exists)}
				{
				This.SpiritTapMP:Set[${UIElement[sldSpiritTapMP@Rest@Pages@ClassGUI].Value}]
				}
				break

			;***OtherSettings Tab Sliders***
		}
	}

	method LoadConfig()
		{
			;***Spell Tab Load***
			This.MyPullSpell:Set[${Config.GetSetting["${RealmChar}","MyPullSpell",]}]
			This.UseSmite:Set[${Config.GetSetting["${RealmChar}","UseSmite"]}]
			This.UseShadowWordPain:Set[${Config.GetSetting["${RealmChar}","UseShadowWordPain"]}]
			This.UseMindBlast:Set[${Config.GetSetting["${RealmChar}","UseMindBlast"]}]
			This.UseMindFlay:Set[${Config.GetSetting["${RealmChar}","UseMindFlay"]}]
			This.UsePsychicScream:Set[${Config.GetSetting["${RealmChar}","UsePsychicScream"]}]
			This.UseShcklUndead:Set[${Config.GetSetting["${RealmChar}","UseShcklUndead"]}]
			This.StartWandAtHp:Set[${Config.GetSetting["${RealmChar}","StartWandAtHp"]}]
			This.StartWandAtMp:Set[${Config.GetSetting["${RealmChar}","StartWandAtMp"]}]
			This.UseWand:Set[${Config.GetSetting["${RealmChar}","UseWand"]}]
			This.UseShcklUndead:Set[${Config.GetSetting["${RealmChar}","UseShcklUndead"]}]
			This.UseShieldOnPull:Set[${Config.GetSetting["${RealmChar}","UseShieldOnPull"]}]
			This.UseVampiricTouch:Set[${Config.GetSetting["${RealmChar}","UseVampiricTouch"]}]
			This.UseVampiricEmbrace:Set[${Config.GetSetting["${RealmChar}","UseVampiricEmbrace"]}]
			This.UseShadowWordDeath:Set[${Config.GetSetting["${RealmChar}","UseShadowWordDeath"]}]
			This.UseSilence:Set[${Config.GetSetting["${RealmChar}","UseSilence"]}]
			This.MindFlayRunners:Set[${Config.GetSetting["${RealmChar}","MindFlayRunners"]}]
			This.UseInnerFocus:Set[${Config.GetSetting["${RealmChar}","UseInnerFocus"]}]

			;***Custom Attack Order Load***
			This.SpellOne:Set[${Config.GetSetting["${RealmChar}","SpellOne"]}]
			This.SpellTwo:Set[${Config.GetSetting["${RealmChar}","SpellTwo"]}]
			This.SpellThree:Set[${Config.GetSetting["${RealmChar}","SpellThree"]}]
			This.SpellFour:Set[${Config.GetSetting["${RealmChar}","SpellFour"]}]
			This.SpellFive:Set[${Config.GetSetting["${RealmChar}","SpellFive"]}]
			This.SpellSix:Set[${Config.GetSetting["${RealmChar}","SpellSix"]}]
			This.SpellSeven:Set[${Config.GetSetting["${RealmChar}","SpellSeven"]}]
			This.SpellEight:Set[${Config.GetSetting["${RealmChar}","SpellEight"]}]
			This.UseCustomAtkOrder:Set[${Config.GetSetting["${RealmChar}","UseCustomAtkOrder"]}]
			This.SpellOneTimer:Set[${Config.GetSetting["${RealmChar}","SpellOneTimer"]}]
			This.SpellTwoTimer:Set[${Config.GetSetting["${RealmChar}","SpellTwoTimer"]}]
			This.SpellThreeTimer:Set[${Config.GetSetting["${RealmChar}","SpellThreeTimer"]}]
			This.SpellFourTimer:Set[${Config.GetSetting["${RealmChar}","SpellFourTimer"]}]
			This.SpellFiveTimer:Set[${Config.GetSetting["${RealmChar}","SpellFiveTimer"]}]
			This.SpellSixTimer:Set[${Config.GetSetting["${RealmChar}","SpellSixTimer"]}]

			;***Heals Tab Load***
			This.UseHealPots:Set[${Config.GetSetting["${RealmChar}","UseHealPots"]}]
			This.UseHealSpellOneAt:Set[${Config.GetSetting["${RealmChar}","UseHealSpellOneAt"]}]
			This.UseHealSpellTwoAt:Set[${Config.GetSetting["${RealmChar}","UseHealSpellTwoAt"]}]
			This.UseHealSpellThreeAt:Set[${Config.GetSetting["${RealmChar}","UseHealSpellThreeAt"]}]
			This.UseHealSpellFourAt:Set[${Config.GetSetting["${RealmChar}","UseHealSpellFourAt"]}]
			This.UseHealSpellFiveAt:Set[${Config.GetSetting["${RealmChar}","UseHealSpellFiveAt"]}]
			This.HealSpellOne:Set[${Config.GetSetting["${RealmChar}","HealSpellOne"]}]
			This.HealSpellTwo:Set[${Config.GetSetting["${RealmChar}","HealSpellTwo"]}]
			This.HealSpellThree:Set[${Config.GetSetting["${RealmChar}","HealSpellThree"]}]
			This.HealSpellFour:Set[${Config.GetSetting["${RealmChar}","HealSpellFour"]}]
			This.HealSpellFive:Set[${Config.GetSetting["${RealmChar}","HealSpellFive"]}]
			This.UseHealPotsAt:Set[${Config.GetSetting["${RealmChar}","UseHealPotsAt"]}]

			;***Buffs/Cures Tab Load***
			This.UseCustomBuffs:Set[${Config.GetSetting["${RealmChar}","UseCustomBuffs"]}]
			This.UseShield:Set[${Config.GetSetting["${RealmChar}","UseShield"]}]
			This.UseShadowform:Set[${Config.GetSetting["${RealmChar}","UseShadowform"]}]
			This.UseFortitude:Set[${Config.GetSetting["${RealmChar}","UseFortitude"]}]
			This.UseShadowProtection:Set[${Config.GetSetting["${RealmChar}","UseShadowProtection"]}]
			This.UseInnerFire:Set[${Config.GetSetting["${RealmChar}","UseInnerFire"]}]

			;***Rest Tab Load***
			This.UseRest:Set[${Config.GetSetting["${RealmChar}","UseRest"]}]
			This.RestMP:Set[${Config.GetSetting["${RealmChar}","RestMP"]}]
			This.RestHP:Set[${Config.GetSetting["${RealmChar}","RestHP"]}]
			This.UseBandages:Set[${Config.GetSetting["${RealmChar}","UseBandages"]}]
			This.SpiritTapMP:Set[${Config.GetSetting["${RealmChar}","SpiritTapMP"]}]

			;***OtherSettings Tab Load***
			This.EnableMyOutput:Set[${Config.GetSetting["${RealmChar}","EnableMyOutput"]}]
		}

	method SaveConfig()
		{
			;***Spell Tab Save***
			Config:SetSetting["${RealmChar}","MyPullSpell",${This.MyPullSpell}]
			Config:SetSetting["${RealmChar}","UseSmite",${This.UseSmite}]
			Config:SetSetting["${RealmChar}","UseShadowWordPain",${This.UseShadowWordPain}]
			Config:SetSetting["${RealmChar}","UseMindBlast",${This.UseMindBlast}]
			Config:SetSetting["${RealmChar}","UseMindFlay",${This.UseMindFlay}]
			Config:SetSetting["${RealmChar}","UsePsychicScream",${This.UsePsychicScream}]
			Config:SetSetting["${RealmChar}","UseShcklUndead",${This.UseShcklUndead}]
			Config:SetSetting["${RealmChar}","StartWandAtHp",${This.StartWandAtHp}]
			Config:SetSetting["${RealmChar}","StartWandAtMp",${This.StartWandAtMp}]
			Config:SetSetting["${RealmChar}","UseWand",${This.UseWand}]
			Config:SetSetting["${RealmChar}","UseShcklUndead",${This.UseShcklUndead}]
			Config:SetSetting["${RealmChar}","UseShieldOnPull",${This.UseShieldOnPull}]
			Config:SetSetting["${RealmChar}","UseVampiricTouch",${This.UseVampiricTouch}]
			Config:SetSetting["${RealmChar}","UseVampiricEmbrace",${This.UseVampiricEmbrace}]
			Config:SetSetting["${RealmChar}","UseShadowWordDeath",${This.UseShadowWordDeath}]
			Config:SetSetting["${RealmChar}","UseSilence",${This.UseSilence}]
			Config:SetSetting["${RealmChar}","MindFlayRunners",${This.MindFlayRunners}]
			Config:SetSetting["${RealmChar}","UseInnerFocus",${This.UseInnerFocus}]

			;***Custom Attack Order Save***
			Config:SetSetting["${RealmChar}","SpellOne",${This.SpellOne}]
			Config:SetSetting["${RealmChar}","SpellTwo",${This.SpellTwo}]
			Config:SetSetting["${RealmChar}","SpellThree",${This.SpellThree}]
			Config:SetSetting["${RealmChar}","SpellFour",${This.SpellFour}]
			Config:SetSetting["${RealmChar}","SpellFive",${This.SpellFive}]
			Config:SetSetting["${RealmChar}","SpellSix",${This.SpellSix}]
			Config:SetSetting["${RealmChar}","SpellSeven",${This.SpellSeven}]
			Config:SetSetting["${RealmChar}","SpellEight",${This.SpellEight}]
			Config:SetSetting["${RealmChar}","UseCustomAtkOrder",${This.UseCustomAtkOrder}]
			Config:SetSetting["${RealmChar}","SpellOneTimer",${This.SpellOneTimer}]
			Config:SetSetting["${RealmChar}","SpellTwoTimer",${This.SpellTwoTimer}]
			Config:SetSetting["${RealmChar}","SpellThreeTimer",${This.SpellThreeTimer}]
			Config:SetSetting["${RealmChar}","SpellFourTimer",${This.SpellFourTimer}]
			Config:SetSetting["${RealmChar}","SpellFiveTimer",${This.SpellFiveTimer}]
			Config:SetSetting["${RealmChar}","SpellSixTimer",${This.SpellSixTimer}]

			;***Heal Tab Save***
			Config:SetSetting["${RealmChar}","UseHealPotsAt",${This.UseHealPotsAt}]
			Config:SetSetting["${RealmChar}","UseHealPots",${This.UseHealPots}]
			Config:SetSetting["${RealmChar}","UseBandages",${This.UseBandages}]
			Config:SetSetting["${RealmChar}","UseHealSpellOneAt",${This.UseHealSpellOneAt}]
			Config:SetSetting["${RealmChar}","UseHealSpellTwoAt",${This.UseHealSpellTwoAt}]
			Config:SetSetting["${RealmChar}","UseHealSpellThreeAt",${This.UseHealSpellThreeAt}]
			Config:SetSetting["${RealmChar}","UseHealSpellFourAt",${This.UseHealSpellFourAt}]
			Config:SetSetting["${RealmChar}","UseHealSpellFiveAt",${This.UseHealSpellFiveAt}]
			Config:SetSetting["${RealmChar}","HealSpellOne",${This.HealSpellOne}]
			Config:SetSetting["${RealmChar}","HealSpellTwo",${This.HealSpellTwo}]
			Config:SetSetting["${RealmChar}","HealSpellThree",${This.HealSpellThree}]
			Config:SetSetting["${RealmChar}","HealSpellFour",${This.HealSpellFour}]
			Config:SetSetting["${RealmChar}","HealSpellFive",${This.HealSpellFive}]


			;***Buffs/Cures Tab Save***
			Config:SetSetting["${RealmChar}","UseCustomBuffs",${This.UseCustomBuffs}]
			Config:SetSetting["${RealmChar}","UseShield",${This.UseShield}]
			Config:SetSetting["${RealmChar}","UseShadowform",${This.UseShadowform}]
			Config:SetSetting["${RealmChar}","UseFortitude",${This.UseFortitude}]
			Config:SetSetting["${RealmChar}","UseShadowProtection",${This.UseShadowProtection}]
			Config:SetSetting["${RealmChar}","UseInnerFire",${This.UseInnerFire}]

			;***Rest Tab Save***
			Config:SetSetting["${RealmChar}","UseRest",${This.UseRest}]
			Config:SetSetting["${RealmChar}","RestMP",${This.RestMP}]
			Config:SetSetting["${RealmChar}","RestHP",${This.RestHP}]
			Config:SetSetting["${RealmChar}","UseBandagesAt",${This.UseBandagesAt}]
			Config:SetSetting["${RealmChar}","SpiritTapMP",${This.SpiritTapMP}]

			;***OtherSettings Tab Save***
			Config:SetSetting["${RealmChar}","EnableMyOutput",${This.EnableMyOutput}]

		}

	method Shutdown()
		{
			This:SaveConfig
		}
	}