/*
======================================================================
Ritz's Complete Druid Routine; V2.1 (Release 8)
----------------------------------------------------------------------
Version 2.1
Some Big changes here.
Should work fine at any level and as any spec. 
Post bugs here: http://www.open-bot.net/forums/viewtopic.php?f=13&t=139 or get me on IRC

� Party bot:

	Setup: 
		Join a group and move into range of another party member.
		Obviously only bot with other bots running the same location set.
		
	Functions:
		Automatically assumes role as a tank/healer/dps
		Follow/Assist the nearest party member
		Buff party members
		Heal party members
		Synced repairing/selling with whoever it is following 
		
	Tips:
		Make sure the area is well mapped before you start
		Run with my other party-supporting routines for best results (Currently Priest/Druid).
		Will work as a support/healbot for you if you manually control a party member
		Turn off any OB follow detection stuff.
		Set the loot threshold to Epic or you'll have to wait each time you loot a green
	
� Moonglade Training:

	Setup: 
		Get the spell Teleport: Moonglade
		Keep your hearthstone-home location set near to where you are grinding, making sure theres a path from the inn to your location.
		Bot somewhere in Kalimdor
		
	Functions:
		Teleports to Moonglade when it needs a trainer
		Hearthstones home when it's finished
	

Major Changes:
� Cleaned up a lot of crap code
� Massivly improved the party stuff
� Will now try to get behind the target whenever it gets the chance in kitty form
� Better target selection
� Less overhealing
� Loads of other fixes

Issues:
� No longer adjusts to your spec/level
� Chooses weird targets when fighting both pvp + pve targets at the same time

ToDo:
� Get immune checks working (waiting for OB 2.2)
� Get automatic config working again
� More testing while solo
� Improve shapeshifting handling (Hot's between forms etc.)

======================================================================
*/
objectdef cClass inherits cBase
{

/*
======================================================================
Variables
======================================================================
Customizable Stuff - Edit these to what you need
======================================================================
*/
	variable int JumpFreq = 3	;(0-100) How often to randomly jump. Higher is more often.
	variable int DangerMedium = 15	;The Danger level to return to DPS form. Default 15.
	variable int DangerHigh = 30	;The Danger level to stop all out DPSing and shift to a more defensive form. Default 30.
	variable int DangerVeryHigh = 45	;This is the point the routine decides you are screwed and tries to run off. Default 45.
	variable int SafeArea = 40	;The distance around you an area must be free of mobs before it is considered safe to flee to.
	variable int DebugLevel = 2	;Show what level of Debug messages? 0=None 1=Light 2=Spam 3=All
	variable int FastHealHP = 40	;When to ignore mana and try to survive
	variable int PullHP = 101	;%HP the target must fall below before I will assist in killing it
	variable int GroupHealHp = 50	;%HP to start healing when in a group
	variable int SoloHealHp = 20	;%HP to start healing when solo
	variable int FollowDistance = 10	;Max Distance to follow the target at
	variable int TankCheckDelay = 2500	;Time between checking for new targets to tank
	variable int ForceSpec = 10	;Force the routine to act like it is a certain spec. 10 = Disabled.
	variable int IdleCheck = 50	;Delay between checking for being idle in combat
	variable int CureCheck = 50	;Delay between checking debuffs
	variable int SaveMod = 50
	variable int MeleeMod = 40	;Stop casting offensive spells and go melee when my mana drops below this %
	variable int MeleeMod2 = 40	;Stop casting offensive spells and go melee when my targets health drops below this %.
	variable int TargetLimit = 20	;The cooldown for switching targets
	variable bool FocusBack = TRUE	;When behind the target only use finishing moves + shred
	variable bool UseTrinket1 = TRUE	;Fairly obvious what this does.
	variable bool UseTrinket2 = TRUE	;Same here.
	variable bool LootAssist = TRUE	;Try to loot when not leading?
	variable bool AutoAssist = TRUE	;Use Assisting?
	variable bool CanTank = TRUE	;Should I tank/pull?
	variable bool UseMoonglade = TRUE	;Teleport to Moonglade to learn skills?
	variable bool AutoStart = TRUE	;Autostart OB on load?
	variable bool StopOnAlone = FALSE	;Stop moving if all party members are out of range?
	
	/*
	Skills - 
	Set the skill name.
	Set FSkillName to the form you need to be in to use that skill. 11 = Never Use. 10 = All Forms, 9 = 0,1. 8 = 0,2. 7 = 0,3. 6 = 1,2. 12 = 2,3.
	*/
	
	/*
	Racials
	*/
	variable int FArcaneTorrent = 0
	variable int FBezerking = 0
	variable int FBloodFury = 0
	variable int FCannibalize = 0
	variable int FEscapeArtist = 0
	variable int FGiftoftheNaaru = 0
	variable int FManaTap = 0
	variable int FPerception = 0
	variable int FShadowmeld = 7
	variable int FStoneform = 0
	variable int FWarStomp = 7
	variable int FWilloftheForsaken = 0
	/*
	Priest Racials
	*/
	variable int FConsumeMagic = 0
	variable int FTouchofWeakness = 0
	variable int FSymbolofHope = 0
	variable int FFearWard = 0
	variable int FDesperatePrayer = 0
	variable int FFeedback = 0
	variable int FStarshards = 0
	variable int FElunesGrace = 0
	variable int FHexofWeakness = 0
	variable int FShadowguard = 0
	variable int FElunesGrace = 0
	variable int FDevouringPlague = 0
	/*
	Forms
	Any class 
	0 = humanoid form 
	
	Druid 
	1 = Bear/Dire Bear Form 
	2 = Aquatic Form 
	3 = Cat Form 
	4 = Travel Form 
	5 = Moonkin/Tree Form 
	6 = Flight Form 
	
	Paladin 
	1 = Devotion Aura 
	2 = Retribution Aura 
	3 = Concentration Aura 
	4 = Shadow Resistance Aura 
	5 = Frost Resistance Aura 
	6 = Fire Resistance Aura 
	7 = Crusader Aura 
	? = Sanctity Aura (Retribution Talent, unknown where it fits.) 
	
	Rogue 
	1 = Stealth 
	
	Shaman 
	1 = Ghost Wolf 
	
	Warrior 
	1 = Battle Stance 
	2 = Defensive Stance 
	3 = Beserker Stance
	*/
	/*
	Forms
	*/
	variable int Form1 = 1
	variable int Form2 = 2
	variable int Form3 = 3
	variable int Form4 = 4
	variable int Form5 = 5
	variable int Form6 = 6
	variable int Form7 = 7
	variable int Form8 = 8
	
	variable int TravelingForm = 5
	variable int DPSForm = 2
	variable int SurvForm = 1
	/*
	Buffs
	*/
	variable string Buff1 = "Mark of the Wild"
	variable int FBuff1 = 0
	
	variable string Buff2 = "Thorns"
	variable int FBuff2 = 7
	
	variable string Buff3 = "NULL"
	variable int FBuff3 = 0
	
	variable string SelfBuff1 = "Omen of Clarity"
	variable int FSelfBuff = 7
	
	variable string SelfBuff2 = "NULL"
	variable int FSelfBuff2 = 0
	/*
	Heals
	*/
	variable string ManaRegen = "Innervate"
	variable int FManaRegen = 0
	
	variable string SmallHeal = "Healing Touch"
	variable int FSmallHeal = 0
	
	variable string BigHeal = "Healing Touch"
	variable int FBigHeal = 0
	
	variable string FastHeal = "Regrowth"
	variable int FFastHeal = 0
	
	variable string CheapHeal = "Healing Touch"
	variable int FCheapHeal = 0
	
	variable string GroupHeal = "Tranquillity"
	variable int FGroupHeal = 0
	
	variable string HoTHeal = "Rejuvenation"
	variable int FHoTHeal = 0
	
	variable string SaveHeal = "Regrowth"
	variable int FSaveHeal = 0
	variable string SaveHealDebuff = "NULL"
	
	variable int FPotion = 0
	/*
	Decursing
	*/
	variable string CureSpell = "Abolish Poison"
	variable int FCureSpell = 0
	variable string CureSpellType = "Poison"
	
	variable string CureSpell2 = "Cure Poison"
	variable int CureSpell2 = 0
	variable string CureSpell2Type = "Poison"
	
	variable string CureSpell3 = "Remove Curse"
	variable int CureSpell3 = 0
	variable string CureSpell3Type = "Curse"
	/*
	Attacks
	Set The Attack name
	Set the FAttackName to the required form
	Set the SAttackName to the School of damage for checking immunities
	0 for Ignore
	1 for Physical 
	2 for Holy 
	3 for Fire 
	4 for Nature 
	5 for Frost 
	6 for Shadow 
	7 for Arcane
	8 for Physical DoT
	*/
	/*
	Mana Attacks
	*/
	variable string DoTSpell1 = "Entangling Roots"
	variable int FDoTSpell1 = 7
	variable int SDoTSpell1 = 4
	
	variable string DoTSpell2 = "Moonfire"
	variable int FDoTSpell2 = 7
	variable int SDoTSpell2 = 7
	
	variable string DoTSpell3 = "Insect Swarm"
	variable int FDoTSpell3 = 7
	variable int SDoTSpell3 = 4
	
	variable string LeechSpell = "NULL"
	variable int FLeechSpell = 7
	variable int SLeechSpell = 0
	
	variable string PullSpell1 = "NULL"
	variable int FPullSpell1 = 7
	variable int SPullSpell1 = 7
	
	variable string PullSpell2 = "Moonfire"
	variable int FPullSpell2 = 7
	variable int SPullSpell2 = 7
	
	variable string PullSpell3 = "Wrath"
	variable int FPullSpell3 = 7
	variable int SPullSpell3 = 4
	
	variable string InteruptSpell = "NULL"
	variable int FInteruptSpell = 0
	variable int SInteruptSpell = 0
	
	variable string KBSpell = "NULL"
	variable int FKBSpell = 0
	variable int SKBSpell = 0
	
	variable string AggroSpell = "NULL"
	variable int FAggroSpell = 0
	variable int SAggroSpell = 0
	
	variable string PanicSpell = "Barkskin"
	variable int FPanicSpell = 7
	variable int SPanicSpell = 0
	
	variable string CCSpell = "Hibernate"
	variable int FCCSpell = 7
	variable int SCCSpell = 4
	variable string CCType = "Beast"
	
	variable string NukeSpell1 = "Starfire"
	variable int FNukeSpell1 = 7
	variable int SNukeSpell1 = 7
	
	variable string NukeSpell2 = "Wrath"
	variable int FNukeSpell2 = 7
	variable int SNukeSpell2 = 4
	
	variable string NukeSpell3 = "NULL"
	variable int FNukeSpell3 = 7
	variable int SNukeSpell3 = 0
	
	variable string ProtectSpell = "Barkskin"
	variable int FProtectSpell = 7
	variable string ProtectSpellDebuff = "NULL"
	
	variable string MeleeBuffSpell = "Nature's Grasp"
	variable int FMeleeBuffSpell = 7
	variable int SMeleeBuffSpell = 4
	
	variable string HealBuffSpell = "Nature's Swiftness"
	variable int FHealBuffSpell = 7
	
	variable string PetSpell = "Force of Nature"
	variable int FPetSpell = 7
	variable int SPetSpell = 0
	/*
	Energy Attacks
	*/
	variable string StealthSpell = "Prowl"
	variable int FStealthSpell = 2
	
	variable string PullBuff = "Tiger's Fury"
	variable int FPullBuff = 2
	
	variable string PullPrep = "NULL"
	variable int FPullPrep = 2
	
	variable string BackPull1 = "Pounce"
	variable int FBackPull1 = 2
	variable int SBackPull1 = 1
	
	variable string BackPull2 = "Ravage"
	variable int FBackPull2 = 2
	variable int SBackPull2 = 1
	
	variable string BackPull3 = "Shred"
	variable int FBackPull3 = 2
	variable int SBackPull3 = 1
	
	variable string FrontPull1 = "Pounce"
	variable int FFrontPull1 = 2
	variable int SFrontPull1 = 1
	
	variable string FrontPull2 = "Mangle (Cat)"
	variable int FFrontPull2 = 2
	variable int SFrontPull2 = 1
	
	variable string FrontPull3 = "Claw"
	variable int FFrontPull3 = 2
	variable int SFrontPull3 = 1
	
	variable string BackAttack = "Shred"
	variable int FBackAttack = 2
	variable int SBackAttack = 1
	
	variable string FrontAttack1 = "Mangle (Cat)"
	variable int FFrontAttack1 = 2
	variable int SFrontAttack1 = 1
	
	variable string FrontAttack2 = "Claw"
	variable int FFrontAttack2 = 2
	variable int SFrontAttack2 = 1
	
	variable string DoTAttack1 = "Mangle (Cat)"
	variable int FDoTAttack1 = 2
	variable int SDoTAttack1 = 8
	
	variable string DoTAttack2 = "Rake"
	variable int FDoTAttack2 = 2
	variable int SDoTAttack2 = 8
	
	variable string DoTAttack3 = "Faerie Fire (Feral)"
	variable int FDoTAttack3 = 2
	variable int SDoTAttack3 = 4
	
	variable string InteruptAttack = "Maim"
	variable int FInteruptAttack = 2
	variable int SInteruptAttack = 1
	
	variable string InteruptAttack2 = "NULL"
	variable int FInteruptAttack2 = 2
	variable int SInteruptAttack2 = 0
	
	variable string DoTFinish = "Rip"
	variable int FDoTFinish = 2
	variable int SDoTFinish = 8
	
	variable string KBFinish = "Ferocious Bite"
	variable int FKBFinish = 2
	variable int SKBFinish = 1
	
	variable string SpeedBoost = "Dash"
	variable int FSpeedBoost = 2
	
	variable string AggroAttack = "Cower"
	variable int FAggroAttack = 2
	variable int SAggroAttack = 1
	/*
	Rage Attacks
	*/
	variable string PullAttack1 = "Faerie Fire (Feral)"
	variable int FPullAttack1 = 1
	variable int SPullAttack1 = 4
	
	variable string PullAttack2 = "Feral Charge"
	variable int FPullAttack2 = 1
	
	variable string RageDoTAttack1 = "Faerie Fire (Feral)"
	variable int FRageDoTAttack1 = 1
	variable int SRageDoTAttack1 = 4
	
	variable string RageDoTAttack2 = "Mangle (Bear)"
	variable int FRageDoTAttack2 = 1
	variable int SRageDoTAttack2 = 1
	
	variable string RageDoTAttack3 = "Lacerate"
	variable int FRageDoTAttack3 = 1
	variable int SRageDoTAttack3 = 8
	
	variable string InterceptAttack = "Feral Charge"
	variable int FInterceptAttack = 1
	variable int SInterceptAttack = 0
	
	variable string RagePanic = "Frenzied Regeneration"
	variable int FRagePanic = 1
	variable int SRagePanic = 0
	
	variable string RageInterupt = "Bash"
	variable int FRageInterupt = 1
	variable int SRageInterupt = 1
	
	variable string ShoutDebuff = "Demoralizing Roar"
	variable int FShoutDebuff = 1
	variable int SShoutDebuff = 1
	
	variable string RageAoE = "Swipe"
	variable int FRageAoE = 1
	variable int SRageAoE = 1
	
	variable string RageBoost = "Enrage"
	variable int FRageBoost = 1
	
	variable string RageAttackBase = "Maul"
	variable int FRageAttackBase = 1
	variable int SRageAttackBase = 1
	
	variable string RageAttack1 = "Mangle (Bear)"
	variable int FRageAttack1 = 1
	variable int SRageAttack1 = 1
	
	variable string AggroTaunt = "Growl"
	variable int FAggroTaunt = 1
	variable int SAggroTaunt = 1
	
	
	
/*
======================================================================

======================================================================
Fixed Variables - Don't touch.
======================================================================
*/
	variable int RestMana = 25	;Rest if my mana is below this % (For Caster/Moonkin Form)
	variable int FeralRestMana = 10	;Rest if my mana is below this % (For Cat/Bear Form)
	variable int TravelCount = 0	;Fixed. To prevent locking up trying to cast travelform indoors
	variable int CurrentForm = 0	;Fixed. Number corresponding to the form I am in
	variable int RestHP = 40	;Rest if my health is below this %
	variable int HealTarget = 0	;Fixed. WHo I am healing
	variable int HealHP = 45	;Heal if my health goes below this %
	variable int HotHP = 90	;Apply Hots when my health goes below this %
	variable int PotHP = 20	;What % HP to use potions at.
	variable int PotMana = 30	;What % Mana to use potions at.
	variable int MaxRange = 30	;Max range
	variable int MsgType = 1	;Fixed
	variable int TargetCD = 0	;Fixed
	variable int TankTimer = 0	;Fixed. Timer for choosing targets to tank
	variable bool Tanking = FALSE	;Fixed
	variable int HelpTarget = 10	;Fixed
	variable int HelpTarget = 10	;Fixed
	variable int HelpType = 0	;Fixed
	variable int WaitTime = 0	;Fixed
	variable int ReqForm = 0	;Needed Form
	variable string CurrentSpell = "NULL"
	variable int CurrentSpellSchool = 0
	variable int Immunity = 0
	variable int CostMulti = 1	;Fixed, for calculating spell costs.
	variable int AssistTarget = 1	;Fixed. Which party member to assist if available
	variable int NewForm = 0	;Fixed. Number corresponding to the form I want to shift to
	variable int NewFormIndex = 0	;Fixed.
	variable int MoonfireMod = 30	;Only cast moonfire if my mana is above this %
	variable int InnervateMod = 25	;Innervate below this % mana
	variable int RejuvMod = 90	;What % HP to start Rejuv ticking
	variable int LifebloomMod = 60	;What % HP to start stacking Lifebloom
	variable int RootsMod = 80	;Root the target if it's HP is above this % (Balance)
	variable int SwipeMod = 10	;Only cast Swipe if my rage is above this %
	variable int EnrageMod = 50	;Only cast Enrage if my Health is above this %
	variable int LacerateMod = 60	;Only cast Lacerate if my rage is above this %
	variable int RegrowthHP = 35	;What % health to start to use regrowth.
	variable int Random = 0	;Fixed. Random number between 1-100
	variable int BuffNum = 0 ;Fixed
	variable bool debuffStatus = FALSE ;Fixed
	variable int DangerLevel = 0	;Fixed. Monitor of how dangerous the situation is
	variable int Dangerlvl = 0	;Fixed. Danger interpretation for the routine to use
	variable int SafeX = 0	;Fixed
	variable int SafeY = 0	;Fixed
	variable int SafeZ = 0	;Fixed
	variable int i = 0	;Fixed
	variable int j = 0	;Fixed
	variable int CureTarget = 0
	variable int Continent = 0	;Fixed. What Continent I am on (To stop crashing)
	variable int TrinketCooldown = 0 ;Fixed
	variable int CurrentWait = 0 ;Fixed
	variable int PullTimer = 0	;Fixed
	variable int NearestMember = 0	;Fixed
	variable int NearestDistance = 100	;Fixed
	variable int PullTimeOut = 20000 ;How long before trying another pull? Def 20000
	variable int BalancePoints = 0	;Fixed. How many points in balance do I have
	variable int FeralPoints = 0	;Fixed. How many points in Feral do I have
	variable int RestoPoints = 0	;Fixed. How many points in Resto do I have
	variable int RSpec = 0 ;What Spec am I. 1-Balance 2-Feral 3-Resto
	variable bool Healing = FALSE	;Fixed. For stopping unessicery heals
	variable bool Fleeing = FALSE	;Fixed. For running off.
	variable int RTraining = 0	;For Training at Moonglade
	variable point3f TargetLoc = 0,0,0	;Where to move to next
	variable string PullSpell = "Moonfire"	;Spell to pull with (For Caster/Moonkin Form)
	variable bool needUIHook = TRUE
	variable collection:string UIErrorMsgStrings
	variable bool needCombatHook = TRUE
	
/*
======================================================================
*/	

method Initialize()
	{
		This:CreateUIErrorStrings
		This:GetSpec
		This:Output[======================================================================]
		This:Output[Ritz's Complete ${Me.Class} Routine Version 2.1]
		This:Output[          -Delicious and Moist-]
		This:Output[======================================================================]
		if ${ForceSpec} != 10
		{
			RSpec:Set[${ForceSpec}]
			This:Output["Forced to spec ${ForceSpec}"]
		}
		This:TweakConfig
		Bot:AddPulse["Class","Pulse",${IdleCheck},TRUE,TRUE]
		Bot:AddPulse["Class","CurePulse",${CureCheck},TRUE,TRUE]	
		if ${AutoStart}
		{
			Bot.PauseFlag:Set[FALSE]
			This:Output["Auto-starting"]
		}
		This:Output[======================================================================]
	}	
	
	method Pulse()
	{
		This:RDebug["Am I tanking? ${Tanking}",3]
		if ${LavishScript.RunningTime} > ${PullTimer} && (!${Me.Target(exists)} || !${Me.Target.InCombat} || ${Me.Target.Name.Equal[${Me.Name}]})
		{
			This:CombatIdle
		}
	}
	method CurePulse()
	{
		if ${Me.Buff[Drink](exists)} && ${Me.PctMana} < 90
		{
			return
		}
		if ${Me.PctMana} > 15 && !${Toon.Casting}
		{
			for (i:Set[0]; ${i}<=${Group.Members}; i:Inc)
			{
				if ${Group.Member[${i}](exists)} && ${Group.Member[${i}].Distance} <= 40 && !${Group.Member[${i}].Dead}
				{
					HealTarget:Set[${i}]
					This:debuffAll()
				}
			}
		}
	}
	method CombatIdle()
	{
		This:RDebug["Doing idle in combat stuff",3]
		if ${This.NeedHelpTarget.Equal["HEAL"]}
		{
			This:HelpRoutine
		}
		if ${This.NeedHelpTarget.Equal["ASSIST"]}
		{
			This:AssistRoutine
		}
		This:RTarget[${Group.Member[${HelpTarget}].GUID},0]
		return
	}
	member NeedRest()
	{	
		if ${RWait} > 0
				return TRUE
							
		if ${RTraining} == 15 && ${POI.NeedClassTrainer} == TRUE
				return FALSE
				
		if ${Toon.Casting}
				return TRUE
	
		if ${This.NeedHelpTarget.Equal["HEAL"]} || ${This.NeedHelpTarget.Equal["BUFF"]}
				return TRUE
				
		if ${This.NeedHelpTarget.Equal["ASSIST"]} && !${POI.NeedClassTrainer} && !${POI.NeedRepair} && !${POI.Sell} && !${POI.NeedSpiritHealer} && !${POI.NeedMailbox} && !${POI.NeedRestock} && !${POI.NeedTradeSkill} && !${POI.NeedLogout}
				return TRUE
					
		if ${POI.NeedClassTrainer} == TRUE && ${RTraining} == 0 && ${Spell["Teleport: Moonglade"](exists)} && ${Item[Hearthstone](exists)} && ${UseMoonglade} && ${Continent} == 1 && !${WoWScript["GetContainerItemCooldown(${Item[Hearthstone].Bag.Number}, ${Item[Hearthstone].Slot})", 2]}
				return TRUE
			
		if ${RTraining} > 0
				return TRUE
			
		if !${Tanking} && !${Targeting.TargetCollection.Get[1](exists)} && ${CurrentForm} != ${TravelingForm} && ${TravelCount} < 5 && ${WoWScript[IsOutdoors()](exists)} && ${Me.PctHPs} > 80 && !${Me.Target(exists)}
				return TRUE
		
		if ${Tanking} && !${Targeting.TargetCollection.Get[1](exists)} && ${CurrentForm} != 0 && ${Me.PctHPs} > 80 && !${Me.Target(exists)}
				return TRUE
							
		if ${Me.Buff[Drink](exists)} && ${Me.PctMana} < 95
        		return TRUE
        
        if ${Me.Buff[Food](exists)} && ${Me.PctHPs} < 50
        		return TRUE
        				  				
		if ${Me.Buff[Resurrection Sickness](exists)}
				return TRUE

		if (${Me.PctHPs} < ${This.RestHP})
     			return TRUE
     			
     	if (${Me.PctMana} < ${This.RestMana}) && (${CurrentForm} == 0 || ${CurrentForm} == 3)
     			return TRUE
     	
     	if (${Me.PctMana} < ${This.FeralRestMana})
     			return TRUE		
     			
        if ${Toon.NeedBuff[${Me.GUID},Mark of the Wild]}
        		return TRUE
        		
        if ${Toon.NeedBuff[${Me.GUID},Thorns]}
        		return TRUE
        		
		if ${Toon.NeedBuff[${Me.GUID},Omen of Clarity]} && ${Spell["Omen of Clarity"](exists)}
      		return TRUE
      	
      	if ${CurrentWait} > 0
      		return TRUE
      			
		if !${This.checkForScrolls.Equal["NONE"]}
			return TRUE
						
      	return FALSE
	}
	method RestPulse()
	{
		This:CheckCurrentForm
		if !${POI.NeedClassTrainer} && ${RTraining} == 16
		{
			RTraining:Set[0]
		}
		if ${Toon.Casting}
		{
			move -stop
			if ${Me.Target(exists)}&& !${Me.Target.Name.Equal[${Me.Name}]}
			{
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
			}
			This:DoubleCastCheck
			return
		}		
		This:RWait[${CurrentWait}]
		if ${CurrentWait} > 0
		{
			return
		}
		PullTimer:Set[0]
		Continent:Set[${WoWScript[GetCurrentMapContinent()]}]
		variable guidlist SafeCheck
		SafeCheck:Search[-units,-hostile,-range 0-${SafeArea}]
		if ${SafeCheck.Count} == 0 && ${Math.Distance[${Me.X},${Me.Y},${SafeX},${SafeY}]} > ${SafeArea}
		{
			This:RDebug["Safe Spot Set ${Me.X} ${Me.Y} ${Me.Z}",1]
			SafeX:Set[${Me.X}]
			SafeY:Set[${Me.Y}]
			SafeZ:Set[${Me.Z}]
		}
		if ${Me.Buff[Drink](exists)} && ${Me.PctMana} < 90
		{
			if ${This.Usable["Shadowmeld",${FShadowmeld}]} && !${Me.Buff[Shadowmeld](exists)}
			{
				Toon:CastSpell[Shadowmeld]
				return
			}
			return
		}
		if ${POI.NeedClassTrainer} == TRUE && ${RTraining} == 0 && ${Spell["Teleport: Moonglade"](exists)} && ${Item[Hearthstone](exists)} && ${UseMoonglade}
		{
			This:RShift[0]
			RTraining:Set[1]
			POI.NeedClassTrainer:Set[FALSE]
			return
		}
		if ${RTraining} > 0 && ${Continent} == 1 && !${WoWScript["GetContainerItemCooldown(${Item[Hearthstone].Bag.Number}, ${Item[Hearthstone].Slot})", 2]}
		{
			This:RShift[0]
			This:RTrain
			return
		}
		if ${Fleeing}
		{
			Fleeing:Set[FALSE]
			This:RDebug["Rest - Stop Fleeing",1]
		}
		if ${Me.Buff[Resurrection Sickness](exists)} || (${This.NeedHelpTarget.Equal["NORMAL"]} && ${StopOnAlone})
		{
			This:RDebug["Rest - Rez Sickness.. Waiting",1]
			move -stop
			if ${This.Usable["Shadowmeld",${FShadowmeld}]} && !${Me.Buff[Shadowmeld](exists)}
			{
				Toon:CastSpell[Shadowmeld]
				return
			}
		}
		if ${This.NeedHelpTarget.Equal["HEAL"]} || ${This.NeedHelpTarget.Equal["BUFF"]} 
		{
			This:HelpRoutine
			return
		}
		if ${This.NeedHelpTarget.Equal["ASSIST"]}
		{
			This:AssistRoutine
		}
		if ${Target.Player(exists)}
		{
			This:BuffRoutine
		}
		if ${Me.PctHPs} < ${This.RestHP} && ${Me.PctMana} > 90 && ${canBandage}
			{
				if ${CurrentForm} != 0 && ${CurrentForm} != 3
				{
					This:RShift[0]
				}
				Toon:Bandage
			}
		if ${Me.PctHPs} < 90 && !${Me.Sitting}
		{
			if (${Me.Buff[Clearcasting](exists)} || ${Me.Buff[Inner Focus](exists)}) && ${This.Usable[${GroupHeal},${FGroupHeal}]}
			{
				This:RTarget[${Me.GUID},2]
				Toon:CastSpell[${GroupHeal}]
				This:RDebug["Rest - Casting ${GroupHeal} lol",2]
				return
			}
      		if !${Me.Buff[${HoTHeal}](exists)} && ${This.Usable[${HoTHeal},${FHoTHeal}]}
			{
				This:RTarget[${Me.GUID},2]
				HelpTarget:Set[${Me.GUID}]
				Toon:CastSpell[${HoTHeal}]
				This:RDebug["Rest - Casting ${HoTHeal}",2]
				return
			}
			if ${This.Usable[${BigHeal},${FBigHeal}]} && ${Me.PctHPs} < ${This.RestHP}
      		{
	      		This:RTarget[${Me.GUID},1]
				move -stop
				HelpTarget:Set[${Me.GUID}]
        		Toon:CastSpell[${BigHeal}]
        		Healing:Set[TRUE]
        		This:RDebug["Rest - Casting ${BigHeal}",2]
				return
      		}
		}
		if !${This.checkForScrolls.Equal["NONE"]}
			{
				This:RTarget[${Me.GUID},1]
				Consumable:UseScroll[${This.checkForScrolls}]		
				return
			}
		if ${Me.Sitting} && (${Me.Buff[Drink](exists)} && ${Me.PctMana} == 100 || !${Me.Buff[Drink](exists)})
		{
			wowpress jump
			This:RDebug["Rest - Standing up",1]
		}		
		if ${Me.PctMana} < ${This.RestMana}
		{
			if ${Consumable.HasDrink} && !${Me.Buff[Drink](exists)} && ${Me.PctMana} < ${RestMana}
			{
				if ${Movement.Speed}
				{
					move -stop
					This:RWait[15]
				}
				else
				{
					This:RDebug["Rest - Need a drink",1]
					Consumable:useDrink
					This:RWait[5]
					if ${Consumable.HasFood} && !${Me.Buff[Food](exists)} && ${Me.PctHPs} < 95 
					{
						Consumable:useFood
					}
					if ${Spell["Shadowmeld"](exists)}
					{
						Toon:CastSpell[Shadowmeld]
					}
				}
			}
		}
		if !${Targeting.TargetCollection.Get[1](exists)} && (${CurrentForm} != ${TravelingForm} && ${TravelCount} < 5 && ${WoWScript[IsOutdoors()](exists)} && ${Me.PctHPs} > 80 && !${Tanking} && !${Me.Target(exists)}
		{
			if (${CurrentForm} == 1 && ${Me.CurrentRage} > 0) || (${CurrentForm} == 2 && ${Me.PctEnergy} < 100) || (${CurrentForm} == 3 && ${Me.PctMana} < 100 
			{
				return
			}
			This:RShift[${TravelingForm}]
			This:RDebug["Rest - Shifting to the correct form for traveling [${TravelingForm}]",1]
			return
		}
		elseif ${Tanking} && !${Targeting.TargetCollection.Get[1](exists)} && (${CurrentForm} == 5 || ${CurrentForm} == 2) && ${Me.PctHPs} > 80 && ${Me.PctHPs} > 80 && !${Me.Target(exists)}
		{
			if !${CurrentForm} == 0
			{
				This:RShift[0]
			}
			This:RDebug["Rest - Shifting to Caster so I don't run out of range",1]
			return
		}
		return
	}
	
	method PullPulse()
	{	
		Toon:Standup	
		Healing:Set[FALSE]
		TravelCount:Set[0]
		This:PrePull
		This:CheckCurrentForm
		This:DoubleCastCheck
		if (${Me.Target(exists)} && ${Me.Target.ReactionLevel} > 4 && ${Me.Target.Target(exists)}) || !${Me.Target(exists)}
		{
			This:RTarget[${Me.Target.Target.GUID},0]
		}
		if ${CurrentForm} != ${DPSForm} && ${PullTimer} == 0
		{
			if ${CurrentForm} == ${SurvForm} && ${Me.PctMana} < 80
			{
				return
			}
			else
			{
				This:RShift[${DPSForm}]
				This:RDebug["Pull - Shifting to DPS form",1]
				return
			}
		}
		if ${PullTimer} == 0
		{
			PullTimer:Set[${LavishScript.RunningTime} + ${PullTimeOut}]
		}
		if ${Me.Target(exists)}&& !${Me.Target.Name.Equal[${Me.Name}]}
		{
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
		}
		if ${CurrentForm} == 5
		{
			This:RShift[0]
		}
		if ${Me.Power.Equal["Rage"]}
		{
			CostMulti:Set[0.1]
			This:BearPull
			return
		}
		if ${Me.Power.Equal["Energy"]}
		{
			CostMulti:Set[1]
			This:CatPull
			return
		}
		if ${Me.Power.Equal["Mana"]}
		{
			CostMulti:Set[1]
			This:BalancePull
		}
		return
	}
	
	method AttackPulse()
	{
		Toon:Standup
		RTraining:Set[0]
		PullTimer:Set[0]
		Random:Set[${Math.Rand[100]}]
		This:CheckCurrentForm
		This:SetDanger
		This:DoubleCastCheck
		This:RWait[${CurrentWait}]
		if ${CurrentWait} > 0
		{
			return
		}
		if ${Fleeing}
		{
			This:RDebug["Attack - Fleeing",1]
			This:FleeRoutine
			return
		}
		variable guidlist Aggros
		Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-40]
		if ${Dangerlvl} >= 3 && !${Fleeing} && ${Math.Distance[${Me.X},${Me.Y},${SafeX},${SafeY}]} > 20 && (${SafeX} != 0 && ${SafeY} != 0 && ${SafeZ} != 0) && ((${Group.Member[${AssistTarget}](exists)} && !${Group.Member[${AssistTarget}].Name.Equal[${Me.Name}]})
		{
			Fleeing:Set[TRUE]
			This:RDebug["Attack - So screwed - trying to run away",1]
			GlobalBlacklist:Insert[${Target.GUID},3600000]
			return
		}
		if ${Me.Target(exists)} && !${Target.LineOfSight}
		{
			Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
			This:RDebug["Attack - No Line of Sight, moveing to target",1]
			return
		}
		if ${This.NeedHelpTarget.Equal["HEAL"]}
		{
			This:HelpRoutine
			return
		}
		This:CheckTarget
		if ${Dangerlvl} == 0
		{
			This:RDebug["Attack - Easy fight -  going to DPS form [${DPSForm}]",1]
			This:RShift[${DPSForm}]
		}
		elseif ${Dangerlvl} > 1
		{
			This:RDebug["Attack - Getting tricky -  Resorting to Survival form [${SurvForm}]",1]
			This:RShift[${SurvForm}]
		}
		if ${Me.Equip[13](exists)} && ${UseTrinket1}
		{
			TrinketCooldown:Set[${WoWScript[GetInventoryItemCooldown("player"\, 13)]}]
			This:RDebug["Attack - Trinket 1 Cooldown is ${TrinketCooldown},3]
			if ${TrinketCooldown} == 0
			{
				Me.Equip[13]:Use	
			}
		}
		if ${Me.Equip[14](exists)} && ${UseTrinket2}
		{
			TrinketCooldown:Set[${WoWScript[GetInventoryItemCooldown("player"\, 14)]}]
			This:RDebug["Attack - Trinket 2 Cooldown is ${TrinketCooldown},3]
			if ${TrinketCooldown} == 0
			{
				Me.Equip[14]:Use	
			}
		}
		if ${Tanking}
		{
			This:TankingRoutine
		}
		if ${Me.Power.Equal["Rage"]}
		{
			CostMulti:Set[0.1]
			This:BearRoutine
			return
		}
		if ${Me.Power.Equal["Energy"]}
		{
			CostMulti:Set[1]
			This:CatRoutine
			return
		}
		if ${Me.Power.Equal["Mana"]}
		{
			CostMulti:Set[1]
			if ${Dangerlvl} == 1 && ${CurrentForm}==0
			{
				This:RDebug["Attack - I'm in Caster form and in a bit of danger -  Resorting to Survival form [${SurvForm}]",1]
				This:RShift[${SurvForm}]
			}
			This:BalanceRoutine
		}
		if ${CurrentForm} == 5 		
		{
			This:RDebug["Attack - Leaving Travel Form",1]
			This:RShift[0]
		}
		return
	}
	
method DoubleCastCheck()
	{
		if !${Healing}
		{
			return
		}
		Random:Set[${Math.Rand[100]}]
		if ${Group.Member[${HealTarget}].PctHPs} > ${HealHP} * 1.1
		{
			if ${Random} < 50
			{
				wowpress JUMP
			}
			else
			{
				WoWScript SpellStopCasting()
			}
			This:RDebug["Stopping any double-cast heals",1]
			Healing:Set[FALSE]
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
		This:RDebug["Flee - No safespot set yet - gonna have to keep fighting",1]
		Fleeing:Set[FALSE]
	}
	if ${Dangerlvl} <= 1 || ${Math.Distance[${Me.X},${Me.Y},${SafeX},${SafeY}]} < 5
	{
		This:RDebug["Flee - Things look safe -  lets try fighting again",1]
		Fleeing:Set[FALSE]
	}
	if ${TravelingForm} == 5 && !${WoWScript[IsOutdoors()](exists)}
	{
		This:RDebug["Flee - Should be going travel form but I'm stuck inside. Going to cat instead.",1]
		This:RShift[2]
	}
	else
	{
		This:RDebug["Flee - Shifting to my traveling form [${TravelingForm}]",1]
		This:RShift[${TravelingForm}]
	}
	if ${Me.Attacking}
	{
		This:RDebug["Flee - Turning off autoattack",2]
		WoWScript AttackTarget()
	}
	Navigator:MoveToLoc[${SafeX},${SafeY},${SafeZ}]
	This:RDebug["Flee - Run Awaaaaaaaaaaaayyy...  Distance left to run: ${Math.Distance[${Me.X},${Me.Y},${SafeX},${SafeY}]}",2]
	if ${Me.Power.Equal["Rage"]}
	{
		if ${This.Usable[${RagePanic},${FRagePanic},${SRagePanic}]}
		{
			This:RDebug["Flee - In Bear form - using ${RagePanic}",2]
			Toon:CastSpell[${RagePanic}]
		}
		return
	}
	if ${Me.Power.Equal["Energy"]}
	{
		if ${This.Usable[${SpeedBoost},${FSpeedBoost}]}
		{
			This:RDebug["Flee - In Cat form - using ${SpeedBoost}",2]
			Toon:CastSpell[${SpeedBoost}]
		}
		return
	}
	if ${Me.Power.Equal["Mana"]}
	{
		if ${This.Usable[${PanicSpell},${FPanicSpell},${SPanicSpell}]}
		{
			This:RDebug["Flee - In Caster form - using ${PanicSpell}",2]
			Toon:CastSpell[${PanicSpell}]
		}
		return
	}
	return
}
	
/*
======================================================================
RShift - 
Checks to see if a spell is useable
======================================================================
*/	
method RShift(int NewForm)
	{
		variable guidlist Aggros
		Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-40]
		TravelCount:Set[0]
		if ${NewForm} == 0
		{
			if ${This.Usable[${RageInterupt},${FRageInterupt},${SRageInterupt}]}
			{
				This:RDebug["Bear Routine - ${RageInterupt} to interupt cast",1]
				Toon:CastSpell[${RageInterupt}]
				return
 			}
 			if ${This.Usable[${InteruptAttack},${FInteruptAttack},${SInteruptAttack}]} && ${Target.Casting(exists)}
			{
				This:RDebug["Cat Routine - ${InteruptAttack} to stop Casting",1]
				Toon:CastSpell[${InteruptAttack}]
				return
			}
			NewFormIndex:Set[0]
		}
		elseif ${NewForm} == 1
		{
			NewFormIndex:Set[${Form1}]
		}
		elseif ${NewForm} == 2
		{
			NewFormIndex:Set[${Form2}]
		}
		elseif ${NewForm} == 3
		{
			NewFormIndex:Set[${Form3}]
		}
		elseif ${NewForm} == 4
		{
			NewFormIndex:Set[${Form4}]
		}
		elseif ${NewForm} == 5
		{
			NewFormIndex:Set[${Form5}]
		}
		elseif ${NewForm} == 6
		{
			NewFormIndex:Set[${Form6}]
		}
		elseif ${NewForm} == 7
		{
			NewFormIndex:Set[${Form7}]
		}
		elseif ${NewForm} == 8
		{
			NewFormIndex:Set[${Form8}]
		}	
		if ${WoWScript[GetShapeshiftForm()]} != ${NewFormIndex}
		{
			This:CancelAllForms
			if ${NewFormIndex} != 0 
			{
				WoWScript CastShapeshiftForm(${NewFormIndex})
			}
		}
	}

	
/*
======================================================================
Balance Pull - 
Pull Routine for Moonkin + Caster
======================================================================
*/		
method BalancePull()
	{
		This:RWait[${CurrentWait}]
		if ${CurrentWait} > 0
		{
			return
		}
		if ${Me.InCombat}
		{
			return
		}
		Healing:Set[FALSE]
		if ${Me.Target(exists)}&& !${Me.Target.Name.Equal[${Me.Name}]}
			{
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
			}
		if ${LavishScript.RunningTime} > ${PullTimer} && ${Tanking}
		{
			This:RDebug["Balance Pull - Pull timeout -  Blackisting",1]
			GlobalBlacklist:Insert[${Target.GUID},3600000]
			PullTimer:Set[${LavishScript.RunningTime} + ${PullTimeOut}]
			return
		}
		if ${Target.Distance} > (${MaxRange}-5) && !${Toon.Casting}
		{
			This:RDebug["Balance Pull - Out of range - moving closer",1]
			Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
			return	
		}
		else
		{
		if !${Me.Attacking}
		{
			This:RDebug["Balance Pull - Turning on autoattack",2]
			WoWScript AttackTarget()
		}
		if ${Me.PctMana} < ${MeleeMod}
		{
			This:RDebug["Balance Pull - Low mana, wanding",1]
			if ${Me.Equip[Ranged](exists)} && ${Spell[Shoot](exists)}
			{
				if ${Target.Distance} > 25 && !${Toon.Casting} && !${Me.Action[Shoot].AutoRepeat}
				{
					This:RDebug["Balance Pull - Wanding but out of range - moving closer",1]
					Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
					if ${Random} < ${JumpFreq}
					{
						wowpress JUMP
					}
					return
				}
				else
				{
					move -stop
					This:RDebug["Balance Pull - Wanding",2]
					Toon:CastSpell[Shoot]
				}
			}
			else
			{
				Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
			}
			return
			}
			elseif ${Movement.Speed}
			{
				move -stop
				return
			}
			if ${This.Usable[${PullSpell1},${FPullSpell1},${SPullSpell1}]}
			{
				This:RDebug["Balance Pull - Pulling with ${PullSpell1}",2]
				Toon:CastSpell[${PullSpell1}]
				This:RWait[5]
				return
			}
			elseif ${This.Usable[${PullSpell2},${FPullSpell2},${SPullSpell2}]}
			{
				This:RDebug["Balance Pull - Pulling with ${PullSpell2}",2]
				Toon:CastSpell[${PullSpell2}]
				This:RWait[5]
				return
			}
			elseif ${This.Usable[${PullSpell3},${FPullSpell3},${SPullSpell3}]}
			{
				This:RDebug["Balance Pull - Pulling with ${PullSpell3}",2]
				Toon:CastSpell[${PullSpell3}]
				This:RWait[5]
				return
			}
			else
			{
				Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
			}
		}
	}		
/*
======================================================================
Bear Pull - 
Pull Routine for Bear
======================================================================
*/		
method BearPull()
	{
		This:RWait[${CurrentWait}]
		if ${CurrentWait} > 0
		{
			return
		}
		if ${LavishScript.RunningTime} > ${PullTimer}
		{
			This:RShift[0]
			This:RDebug["Bear Pull - Nothings happening - Trying a Caster form pull.",1]
			PullTimer:Set[${LavishScript.RunningTime} + ${PullTimeOut}]
			return
		}
		if !${Me.Attacking}
		{
			This:RDebug["Bear Pull - Turning on Autoattack",2]
			WoWScript AttackTarget()
		}
		if ${This.Usable[${PullAttack1},${FPullAttack1},${S{PullAttack1}]}
		{
			This:RDebug["Bear Pull - ${PullAttack1}",2]
			Toon:CastSpell[${PullAttack1}]
			return
		}
		if ${This.Usable[${PullAttack2},${FPullAttack2},${SPullAttack2}]}
		{
			This:RDebug["Bear Pull - ${PullAttack2}",2]
			Toon:CastSpell[${PullAttack2}]
		}
		if ${Target.Distance}> 4.5
		{
			This:RDebug["Bear Pull - No pulling tecniques available - body pulling",2]
			Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
		}
	}		
		
/*
======================================================================
Cat Pull - 
Pull Routine for Cat
======================================================================
*/		
method CatPull()
	{
		This:RWait[${CurrentWait}]
		if ${CurrentWait} > 0
		{
			return
		}
		if ${LavishScript.RunningTime} > ${PullTimer}
		{
			This:RShift[0]
			This:RDebug["Cat Pull - Nothings happening - Trying a Caster form pull.",1]
			PullTimer:Set[${LavishScript.RunningTime} + ${PullTimeOut}]
			return
		}
		if ${This.Usable[${StealthSpell},${FStealthSpell}]} && !${This.IsDotted} && ${Target.Distance} < 20 && ${Target.PctHPs} > 50
		{
			This:RDebug["Cat Pull - Nearly at the target - ${StealthSpell}ing",1]
			Toon:CastSpell[${StealthSpell}]
		}
		if (${Me.CurrentPower} < 60 && ${Target.Distance} < 5) || (!${Me.Buff[${StealthSpell}](exists)} && ${Target.Distance} < 20)
		{
			This:RDebug["Cat Pull - Waiting for Prowl CD/Energy",2]
			return
		}
		if ${This.Usable[${PullBuff},${FPullBuff},${SPullBuff}]} && ${Me.CurrentPower} > 90 && !${Me.Buff[${PullBuff}](exists)} && ${Me.CurrentPower} == 100 && ${Me.Target.Distance} < 20 && ${Target.Distance} > 15
		{
			This:RDebug["Cat Pull - ${PullBuff}",2]
			Toon:CastSpell[${PullBuff}]
		}
		if ${This.Usable[${PullPrep},${FPullPrep},${SPullPrep}]} && ${Me.Target.Distance} < 20
		{
			This:RDebug["Cat Pull - ${PullPrep}",2]
			Toon:CastSpell[${PullPrep}]
		}
		if ${Me.Target.Distance} > 4
		{
			Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
		}
		else
		{
			move -stop
		}
		if ${This.Behind}
		{
			if ${This.Usable[${BackPull1},${FBackPull1},${SBackPull1}]}
			{
				move -stop
				This:RDebug["Cat Pull - Using ${BackPull1}",2]
				Toon:CastSpell[${BackPull1}]
				return
			}
			if ${This.Usable[${BackPull2},${FBackPull2},${SBackPull2}]}
			{
				move -stop
				This:RDebug["Cat Pull - Using ${BackPull2}",2]
				Toon:CastSpell[${BackPull2}]
				return
			}
			if ${This.Usable[${BackPull3},${FBackPull3},${SBackPull3}]}
			{
				move -stop
				This:RDebug["Cat Pull - Using ${BackPull3}",2]
				Toon:CastSpell[${BackPull3}]
				return
			}
			if ${This.Usable[${FrontPull1},${FFrontPull1},${SFrontPull1}]}
			{
				move -stop
				This:RDebug["Cat Pull - Using ${FrontPull1}",2]
				Toon:CastSpell[${FrontPull1}]
				return
			}
		}
		else
		{
			if ${This.Usable[${FrontPull1},${FFrontPull1},${SFrontPull1}]}
			{
				move -stop
				This:RDebug["Cat Pull - Using ${FrontPull1}",2]
				Toon:CastSpell[${FrontPull1}]
				return
			}
			if ${This.Usable[${FrontPull2},${FFrontPull2},${SFrontPull2}]}
			{
				move -stop
				This:RDebug["Cat Pull - Using ${FrontPull2}",2]
				Toon:CastSpell[${FrontPull1}]
				return
			}
			if ${This.Usable[${FrontPull3},${FFrontPull3},{$SFrontPull3}]}
			{
				move -stop
				This:RDebug["Cat Pull - Using ${FrontPull3}",2]
				Toon:CastSpell[${FrontPull3}]
				return
			}
		}
	}		
	
				
/*
======================================================================
Balance Routine - 
Attack Routine for Moonkin + Caster
======================================================================
*/		
method BalanceRoutine()
	{
		if ${Me.Target(exists)} && ${Me.Target.ReactionLevel} > 4
		{
			This:RTarget[${Me.Target.Target.GUID},0]
		}
		if ${Me.Target(exists)}&& !${Me.Target.Name.Equal[${Me.Name}]}
		{
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
		}
		variable guidlist Aggros
		Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-40]
		if !${Me.Attacking} && !${Me.Equip[Ranged](exists)}
		{
			This:RDebug["Balance Routine - Turning on Autoattack",2]
			WoWScript AttackTarget()
		}
		if ${Me.Buff[Feared](exists)} && ${This.Usable["Will of the Forsaken",${FWilloftheForsaken}]}
		{
			Toon:CastSpell[Will of the Forsaken]
			return
		}
		if ${Target.Distance} > ${MaxRange} && !${Toon.Casting}
		{
			This:RDebug["Balance Routine - out of range - moving closer",1]
			Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
			if ${Random} < ${JumpFreq}
			{
				wowpress JUMP
			}
			return
		}
		if ${This.Usable[${InteruptSpell},${FInteruptSpell},${SInteruptSpell}]} && ${Target.Casting(exists)}
		{
			WoWScript SpellStopCasting()
			Toon:CastSpell[${InteruptSpell}]
 		}
 		if ${This.Usable["War Stomp",${FWarStomp}]} && ${Target.Casting(exists)}
			{
				if ${Me.Target.Distance} < 8
				{
					This:RDebug["Balance Routine - War Stomp to interupt the spell",1]
					move -stop
					Toon:CastSpell[War Stomp]
				}	
 			}
		if ${This.Usable[${KBSpell},${FKBSpell},${SKBSpell}]} && ${Target.PctHPs} < 15 && ${Me.PctHPs} > 60
		{
			Toon:CastSpell[${KBSpell}]
			return
		}
		if ${Group.Member[${AssistTarget}](exists)} && ${This.Usable[${AggroSpell},${FAggroSpell},${SAggroSpell}]} && ${Target.Target.Name.Equal[${Me.Name}]} && !${Tanking}
		{
			WoWScript SpellStopCasting()
			Toon:CastSpell[${AggroSpell}]
			return
		}
		if (!${Target.Type.Equal[Player]} && ((${Target.PctHPs} < ${MeleeMod2}) || (${Me.PctMana} < ${MeleeMod}) || (${Me.Buff[Spirit Tap](exists)} && ${Me.PctMana} < 90))) || ${Unit[${Target}].CreatureType.Equal[Totem]}
		{
			if ${Me.Equip[Ranged](exists)} && ${Spell[Shoot](exists)}
				{
					if ${Target.Distance} > 25 && !${Toon.Casting} && !${Me.Action[Shoot].AutoRepeat}
					{
						This:RDebug["Balance Routine - Wanding but out of range - moving closer",1]
						Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
						if ${Random} < ${JumpFreq}
						{
							wowpress JUMP
						}
						return
					}
					elseif !${Me.Action[Shoot].AutoRepeat}
					{
						move -stop
						This:RDebug["Balance Routine - Wanding",2]
						Toon:CastSpell[Shoot]
					}
				}
				else
				{
					Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
				}
			
			return
		}
		elseif (${This.IsRooted} ||  !${Target.Target.Name.Equal[${Me.Name}]}) && ${Target.Distance} <= 10
		{
			Navigator:MoveBackward[2000]
		}
		elseif ${Movement.Speed}
		{
			move -stop
		}
		if ${Toon.Casting}
		{
			return
		}
		if ${This.IsRooted} && ${Me.Target.Distance} < 10 && ${Targeting.TargetCollection.Get[2](exists)}
		{
			This:RTarget[${Targeting.TargetCollection.Get[2].GUID},0]
			This:RDebug["Balance Routine - Switching to the non-rooted target",1]
		}
		if ${This.Usable[${PanicSpell},${FPanicSpell},${SPanicSpell}]}
		{
			if ${Me.Target.Distance} < 8 && ${Me.Target(exists} && ((${Target.Type.Equal[Player]}) || (${Me.Target.PctHPs} > 20 && ${Aggros.Count} < 2))
			{
				This:RDebug["Balance Routine - ${PanicSpell}",1]
				move -stop
				Toon:CastSpell[${PanicSpell}]
			}	
 		}
 		if ${Targeting.TargetCollection.Get[2](exists)} && !${Unit[${Targeting.TargetCollection.Get[2]}].Buff[${CCSpell}](exists)} && ${Unit[${Targeting.TargetCollection.Get[2]}].CreatureType.Equal[${CCType}]} && !${Unit[${Targeting.TargetCollection.Get[2]}].Buff[${DotSpell1}](exists)} && !${Unit[${Targeting.TargetCollection.Get[2]}].Buff[${DotSpell2}](exists)}
		{
			if ${This.Usable[${CCSpell},${FCCSpell},${SCCSpell}]}
			{	
				This:RTarget[${Targeting.TargetCollection.Get[2].GUID},5]
				Toon:CastSpell[${CCSpell}]
				This:RDebug["Balance Routine - ${CCSpell} ${Target}",1]
				This:RTarget[${Targeting.TargetCollection.Get[1].GUID},0]
			}
		}
		if ${Me.Target(exists)} && ${This.Usable[${PetSpell},${FPetSpell}]} && ${Target.PctHPs} > 70 && (${Dangerlvl}>=1 || ${Target.Level} >= ${Me.Level})
		{
		   if ${Math.Distance[${Me.X},${Me.Y},${Target.X},${Target.Y}]}< ${MaxRange}
		   {
			This:RDebug["Balance Routine - ${PetSpell}!",1]
		    Toon:CastSpell[${PetSpell}]
		    ISXWoW:ClickTerrain[${Target.X}, ${Target.Y}, ${Target.Z}]
		   }
		}	
		if ${This.Usable[${MeleeBuffSpell},${FMeleeBuffSpell},${SMeleeBuffSpell}]} && !${Me.Buff[${MeleeBuffSpell}](exists)} && ${Target.Distance} < 10 && ${Me.Target.Target.Name.Equal[${Me.Name}]}
		{
			This:RDebug["Balance Routine - Buffing ${MeleeBuffSpell}",2]
			Toon:CastSpell[${MeleeBuffSpell}]
			return
		}
		if ${This.Usable[${LeechSpell},${FLeechSpell},${SLeechSpell}]} && ${Target.PctHPs} > 60 && ${HealTarget.PctHPs} > 60 !${Target.Buff[${LeechSpell}](exists)}
		{
			This:RDebug["Balance Routine - Applying ${LeechSpell}",2]
			Toon:CastSpell[${LeechSpell}]
			return
		}
		if ${This.Usable[${DoTSpell1},${FDoTSpell1},${SDoTSpell1}]} && ${Target.PctHPs} > 30 && !${Target.Buff[${DoTSpell1}](exists)}
		{
			This:RDebug["Balance Routine - Dotting ${DoTSpell1}",2]
			Toon:CastSpell[${DoTSpell1}]
			This:RWait[5]
			return
		}
		if ${This.Usable[${DoTSpell2},${FDoTSpell2},${SDoTSpell2}]} && ${Target.PctHPs} > 30 && !${Target.Buff[${DoTSpell2}](exists)}
		{
			This:RDebug["Balance Routine - Dotting ${DoTSpell2}",2]
			Toon:CastSpell[${DoTSpell2}]
			This:RWait[5]
			return
		}
		if ${This.Usable[${DoTSpell3},${FDoTSpell3},${SDoTSpell3}]} && ${Target.PctHPs} > 30 && !${Target.Buff[${DoTSpell3}](exists)}
		{
			This:RDebug["Balance Routine - Dotting ${DoTSpell3}",2]
			Toon:CastSpell[${DoTSpell3}]
			This:RWait[5]
			return
		}
		if ${Me.Target.Distance} < 5 && ${This.Usable[${ProtectSpell},${FProtectSpell}]} && ${This.Usable[${NukeSpell1},${FNukeSpell1},${SNukeSpell1}]} && ${Target.PctHPs} > 70 && !${Me.Buff[${ProtectSpellDebuff}](exists)} && ${Target.PctHPs} > 80
		{
			This:RDebug["Balance Routine - Buffing ${ProtectSpell} so I can keep spamming ${NukeSpell1}",2]
			Toon:CastSpell[${ProtectSpell}]
			return
		}
		if ${This.Usable[${NukeSpell1},${FNukeSpell1},${SNukeSpell1}]} && !${Movement.Speed} && ${Target.PctHPs} > 10 && (${Target.Distance} > 10 || ${Me.Buff[${ProtectSpell}](exists)} || !${Me.Target.Target.Name.Equal[${Me.Name}]})
		{
			This:RDebug["Balance Routine - Casting ${NukeSpell1}",2]
			Toon:CastSpell[${NukeSpell1}]
			return
		}
		if ${This.Usable[${NukeSpell2},${FNukeSpell2},${SNukeSpell2}]}
		{
			This:RDebug["Balance Routine - Casting ${NukeSpell2}",2]
			Toon:CastSpell[${NukeSpell2}]
			return
		}
		if ${This.Usable[${NukeSpell3},${FNukeSpell3},${SNukeSpell3}]}
		{
			This:RDebug["Balance Routine - Casting ${NukeSpell3}",2]
			Toon:CastSpell[${NukeSpell3}]
			return
		}
		if ${This.Usable["Mana Tap",${FManaTap}]} && ${Target.CurrentMana} > 0
		{
			Toon:CastSpell[Mana Tap]
			return
		}
		if ${Me.PctMana} < 85 && ${This.Usable["Arcane Torrent"],${FArcaneTorrent}} && ${Me.Buff[Mana Tap].Application} == 3
		{
			Toon:CastSpell[Arcane Torrent]
			return
		}
		return
	}

/*
======================================================================
Bear Routine - 
Attack Routine for Bear
======================================================================
*/		
method BearRoutine()
	{
		if ${Me.Target(exists)} && ${Me.Target.ReactionLevel} > 4 && ${Me.Target.Target(exists)}
		{
			This:RTarget[${Me.Target.Target.GUID},0]
		}
		if ${Me.Target(exists)}&& !${Me.Target.Name.Equal[${Me.Name}]}
		{
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
		}
		variable guidlist Aggros
		Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-40]
		if !${Targeting.TargetCollection.Get[1](exists)} && ${Me.Buff[${RageBoost}](exists)} && ${DangerLevel} < 3
		{
			This:RDebug["Bear Routine - Removing ${RageBoost} so I can get out of combat",1]
			Me.Buff[${RageBoost}]:Remove
			return
		}
		if !${Me.Attacking}
		{
			This:RDebug["Bear Routine - Turning on Autoattack",2]
			WoWScript AttackTarget()
		}
		if ${Target.Distance} > 4.5
		{
			This:RDebug["Bear Routine - Getting into Melee range"],1
			Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
			if ${Random} < ${JumpFreq}
			{
				wowpress JUMP
			}
			if ${This.Usable[${InterceptAttack},${FInterceptAttack},${SInterceptAttack}]}
			{
				This:RDebug["Bear Routine - Using ${InterceptAttack}",2]
				Toon:CastSpell[${InterceptAttack}]
				return
			}
		}
		else
		{
			if ${Movement.Speed}
			{
				move -stop
			}	
		}
		if ${This.Usable[${RagePanic},${FRagePanic},${SRagePanic}]} && ${Me.PctHPs} < 70
		{
			This:RDebug["Bear Routine - In Bear form - using ${RagePanic}",2]
			Toon:CastSpell[${RagePanic}]
		}
		if ${This.Usable[${RageAttackBase},${FRageAttackBase},${SRageAttackBase}]}
			{
				This:RDebug["Bear Routine - Getting ${RageAttackBase} ready",2]
				Toon:CastSpell[${RageAttackBase}]
			}
		if ${This.Usable[${RageInterupt},${FRageInterupt},${SRageInterupt}]} && ${Target.Casting(exists)}
			{
				This:RDebug["Bear Routine - ${RageInterupt} to interupt cast",1]
				Toon:CastSpell[${RageInterupt}]
				return
 			}
 		if ${This.Usable[${AggroTaunt},${FAggroTaunt},${SAggroTaunt}]} && !${Target.Target.Name.Equal[${Me.Name}]} && ${Target.PctHPs} > 20 && ${Tanking}
			{
				This:RDebug["Bear Routine - ${AggroTaunt}",2]
				Toon:CastSpell[${AggroTaunt}]
				return
			}
 		if ${This.Usable[${RageBoost},${FRageBoost}]} && ${Aggros.Count} < 3 && ${Me.PctHPs} > ${EnrageMod}
			{
				This:RDebug["Bear Routine - ${RageBoost}",2]
				Toon:CastSpell[${RageBoost}]
				return
			}
		if ${This.Usable[${ShoutDebuff},${FShoutDebuff},${SShoutDebuff}]} && !${Target.Buff[${ShoutDebuff}](exists)} && ${Target.PctHPs} > 20 && ${Me.Target.Distance} < 10 && ${Me.InCombat} && ${Toon.ValidTarget[${Target.GUID}]}
			{
				This:RDebug["Bear Routine - Using ${ShoutDebuff}",2]
				Toon:CastSpell[${ShoutDebuff}]
				return
			}
		if ${This.Usable[${RageAttack1},${FRageAttack1},${SRageAttack1}]}
			{
				This:RDebug["Bear Routine - ${RageAttack1}",2]
				Toon:CastSpell[${RageAttack1}]
				return
			}
		if ${This.Usable[${RageDoTAttack1},${FRageDoTAttack1},${SRageDoTAttack1}]} && !${Target.Buff[${RageDoTAttack1}](exists)}
			{
				This:RDebug["Bear Routine - ${RageDoTAttack1}",2]
				Toon:CastSpell[${RageDoTAttack1}]
				return
			}
		if ${This.Usable[${RageDoTAttack2},${FRageDoTAttack2},${SRageDoTAttack2}]} && !${Target.Buff[${RageDoTAttack2}](exists)} && ${Target.PctHPs} > 30
			{
				This:RDebug["Bear Routine - ${RageDoTAttack2}",2]
				Toon:CastSpell[${RageDoTAttack2}]
				return
			}
		if ${This.Usable[${RageDoTAttack3},${FRageDoTAttack3},${SRageDoTAttack3}]} && !${Target.Buff[${RageDoTAttack3}](exists)} && ${Me.CurrentRage} > 30
			{
				This:RDebug["Bear Routine - ${RageDoTAttack3}",2]
				Toon:CastSpell[${RageDoTAttack3}]
				return
			}
		if ${This.Usable[${RageAoE},${FRageAoE},${SRageAoE}]} && ${Me.CurrentRage} > ${SwipeMod} && ${Targeting.TargetCollection.Get[2](exists)}
			{
				This:RDebug["Bear Routine - ${RageAoE} at adds",2]
				Toon:CastSpell[${RageAoE}]
				return
			}
	}

/*
======================================================================
Cat Routine - 
Attack Routine for Cat
======================================================================
*/		
method CatRoutine()
	{
		if ${Me.Target(exists)} && ${Me.Target.ReactionLevel} > 4 && ${Me.Target.Target(exists)}
		{
			This:RTarget[${Me.Target.Target.GUID},0]
		}
		if ${Me.Target(exists)} && !${Me.Target.Target.Name.Equal[${Me.Name}]} && !${This.Behind} && ${Target.Distance} < 5
		{
			move forward 1500
			return
		}
		if ${Me.Target(exists)} && !${Me.Target.Name.Equal[${Me.Name}]}
		{
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
		}
		if !${Me.Attacking}
		{
			This:RDebug["Cat Routine - Turning on Autoattack",2]
			WoWScript AttackTarget()
		}
		if ${Target.Distance} > 4.5
		{
			This:RDebug["Cat Routine - Getting into Melee Range",1]
			Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
			if ${Random} < ${JumpFreq}
			{
				wowpress JUMP
			}
			if ${Target.Distance} > 20 && ${This.Usable[${SpeedBoost},${FSpeedBoost}]}
			{
				Toon:CastSpell[${SpeedBoost}]
			}
		}
		else
		{
			if ${Movement.Speed}
			{
				move -stop
			}	
		}
		if ${This.Usable[${InteruptAttack},${FInteruptAttack},${SInteruptAttack}]} && ${Target.Casting(exists)}
		{
			This:RDebug["Cat Routine - ${InteruptAttack} to stop Casting",1]
			Toon:CastSpell[${InteruptAttack}]
			return
		}
		if ${This.Usable[${InteruptAttack2},${FInteruptAttack2},${SInteruptAttack2}]} && ${Target.Casting(exists)}
		{
			This:RDebug["Cat Routine - ${InteruptAttack2} to stop Casting",1]
			Toon:CastSpell[${InteruptAttack2}]
			return
		}
		if ${Group.Member[${AssistTarget}](exists)} && ${This.Usable[${AggroAttack},${FAggroAttack},${SAggroAttack}]} && ${Target.Target.Name.Equal[${Me.Name}]} && !${Tanking} && ${Group.Members} > 0
		{
			Toon:CastSpell[${AggroAttack}]
			return
		}
		if ${Me.ComboPoints} == 5 || (${Me.ComboPoints} > 2 && ${Target.Casting(exists)}) || (${Me.ComboPoints}*7 > ${Target.PctHPs})
		{
			if ${This.Usable[${KBFinish},${FKBFinish},${SKBFinish}]}
			{
				This:RDebug["Cat Routine - Using ${KBFinish}",2]
				Toon:CastSpell[${KBFinish}]
				return
			}	
		}
		if ${This.Behind} && ${This.Usable[${BackAttack},${FBackAttack},${SBackAttack}]}
		{
			This:RDebug["Cat Routine - I'm behind the target - using ${BackAttack}",2]
			Toon:CastSpell[${BackAttack}]
			return
		}
		if ${This.Behind} && ${Spell[${BackAttack}](exists)} && ${FocusBack}
		{
			This:RDebug["Behind the target - saving energy for ${BackAttack}",2]
			return
		}
		if ${This.Usable[${DoTAttack1},${FDoTAttack1},${SDoTAttack1}]} && !${Target.Buff[${DoTAttack1}](exists)}
		{
			This:RDebug["Cat Routine - ${DoTAttack1}",2]
			Toon:CastSpell[${DoTAttack1}]
			return
		}
		if ${This.Usable[${DoTAttack2},${FDoTAttack2},${SDoTAttack2}]} && !${Target.Buff[${DoTAttack2}](exists)}
		{
			This:RDebug["Cat Routine - ${DoTAttack2}",2]
			Toon:CastSpell[${DoTAttack2}]
			return
		}
		if ${This.Usable[${DoTAttack3},${FDoTAttack3},${SDoTAttack3}]} && !${Target.Buff[${DoTAttack3}](exists)}
		{
			This:RDebug["Cat Routine - ${DoTAttack3}",2]
			Toon:CastSpell[${DoTAttack3}]
			return
		}
		if ${Target.PctHPs}<(${Me.ComboPoints}*15)
		{
			if ${This.Usable[${KBAttack},${FKBAttack},${SKBAttack}]}
			{
				This:RDebug["Cat Routine - Using ${KBAttack}",2]
				Toon:CastSpell[${KBAttack}] 
				return
			}
		}
		if ${Target.PctHPs}<(${Me.ComboPoints}*20)
		{
			if ${This.Usable[${DoTFinish},${FDoTFinish},${SDoTFinish}]} && !${Target.Buff[${DoTFinish}](exists)} 
			{
				This:RDebug["Cat Routine - Using ${DoTFinish}",2]
				Toon:CastSpell[${DoTFinish}] 
				return
			}
		}
		if ${This.Usable[${FrontAttack1},${FFrontAttack1},${SFrontAttack1}]}
		{
			This:RDebug["Cat Routine - Using ${FrontAttack1}",2]
			Toon:CastSpell[${FrontAttack1}]
			return
		}
		if ${This.Usable[${FrontAttack2},${FFrontAttack2},${SFrontAttack2}]}
		{
			This:RDebug["Cat Routine - Using ${FrontAttack2}",2]
			Toon:CastSpell[${FrontAttack2}]
			return
		}
	}		
/*
======================================================================
Heal Routine - 
Healing Routine for Caster
======================================================================
*/		
method HealRoutine()
	{
		variable guidlist Aggros
		Aggros:Search[-units,-nearest,-aggro,-targetingme,-alive,-range 0-5]
		if ${Spell[${CheapHeal}].Cooldown} && ${Me.GlobalCooldown} == 0
		{
			This:RDebug["Heal Routine - Counterspelled or something - ZOMG HALP",2]
			This:PotRoutine
			return
		}
		This:PotRoutine
 		if ${Group.Member[${HelpTarget}].PctHPs} < ${This.HealHP} && !${Toon.Casting}
 		{
	 		This:RTarget[${Group.Member[${HealTarget}].GUID},2]
	 		if ${This.Usable["War Stomp",${FWarStomp}]}
			{
				if ${Me.Target.Distance} < 8
				{
					This:RDebug["Balance Routine - War Stomp before healing",1]
					move -stop
					Toon:CastSpell[War Stomp]
				}	
 			}
	 		if ${This.Usable[${HealBuffSpell},${FHealBuffSpell}]}
	 		{
		 		Toon:CastSpell[${HealBuffSpell}]
	        	This:RDebug["Heal Routine - Casting ${HealBuffSpell}",2]
	        	return
	 		}
	 		if ${This.Usable[${SaveHeal},${FSaveHeal}]} && ${Group.Member[${HelpTarget}].PctHPs} < ${SaveMod} && !${Target.Buff[${SaveHeal}](exists)} && !${Target.Buff[${SaveHealDebuff}](exists)} && ${Me.InCombat}
	      		{
	        		Toon:CastSpell[${SaveHeal}]
	        		This:RDebug["Heal Routine - Casting ${SaveHeal}",2]
					return
	      		}
	      	if ${This.Usable[${GroupHeal},${FGroupHeal}]} && (${Me.PctHPs} < ${This.HealHP} && ${Target.PctHPs} < ${This.HealHP} && !${Target.Name.Equal[${Me.Name}]} && !${Target.Buff[${GroupHeal}](exists)}) && ${Me.Target.Distance} < 30
	      		{
	        		Toon:CastSpell[${GroupHeal}]
	        		Healing:Set[TRUE]
	        		This:RDebug["Heal Routine - Casting ${GroupHeal}",2]
	        		This:RWait[3]
					return
	      		}
	      	if ${This.Usable[${FastHeal},${FFastHeal}]} && ((${Target.PctHPs} < ${This.FastHealHP} && !${Target.Buff[${FastHeal}](exists)}) || (${Me.Buff[Clearcasting](exists)} && ${Me.Buff[Inner Focus](exists)}))
	      		{
	        		Toon:CastSpell[${FastHeal}]
	        		Healing:Set[TRUE]
	        		This:RDebug["Heal Routine - Casting ${FastHeal}",2]
	        		This:RWait[3]
					return
	      		}
	      	if ${This.Usable[${BigHeal},${FBigHeal}]} && ${Target.PctHPs} < ${This.HealHP} && !${Target.Buff[${BigHeal}](exists)} && ${Aggros.Count} == 0
	      		{
	        		Toon:CastSpell[${BigHeal}]
	        		Healing:Set[TRUE]
	        		This:RDebug["Heal Routine - Casting ${BigHeal}",2]
	        		This:RWait[3]
					return
	      		}
			if ${This.Usable[${SmallHeal},${FSmallHeal}]} && ${Target.PctHPs} < ${This.HealHP} && !${Target.Buff[${SmallHeal}](exists)}
	      		{
	        		Toon:CastSpell[${SmallHeal}]
	        		Healing:Set[TRUE]
	        		This:RDebug["Heal Routine - Casting ${SmallHeal}",2]
	        		This:RWait[3]
					return
	      		}
	      	if ${This.Usable[${CheapHeal},${FCheapHeal}]} && ${Target.PctHPs} < ${This.HealHP} && !${Target.Buff[${${CheapHeal}}](exists)}
	      		{
	        		Toon:CastSpell[${CheapHeal}]
	        		Healing:Set[TRUE]
	        		This:RDebug["Heal Routine - Casting ${CheapHeal}",2]
	        		This:RWait[3]
					return
	      		}
	  	}
	}
/*
======================================================================
Buff Routine - 
Buff Routine for Caster
======================================================================
*/		
method BuffRoutine()
	{
		if ${Me.InCombat}
		{
			return
		}
		if !${Group.Member[${HelpTarget}](exists)}
		{
			return
		}
		if ${This.Usable["Shadowguard",${FShadowguard}]} && !${Me.Buff[Shadowguard](exists)}
		{
			Toon:CastSpell[Shadowguard]
			return
		}
		if ${This.Usable["Touch of Weakness",${FTouchofWeakness}]} && !${Me.Buff[Touch of Weakness](exists)}
		{
			Toon:CastSpell[Touch of Weakness]
			return
		}
		if ${This.Usable["Fear Ward",${FFearWard}]} && !${Group.Member[${HelpTarget}].Buff[Fear Ward](exists)}
		{
			Toon:CastSpell[Fear Ward]
			return
		}
		if ${This.Usable[${SelfBuff1},${FSelfBuff1}]} && !${Me.Buff[${SelfBuff1}](exists)}
		{
			Toon:CastSpell[${SelfBuff1}]
			return
		}
		if ${This.Usable[${SelfBuff2},${FSelfBuff2}]} && !${Me.Buff[${SelfBuff2}](exists)}
		{
			Toon:CastSpell[${SelfBuff2}]
			return
		}
		if ${This.Usable[${Buff1},${FBuff1}]} && !${Group.Member[${HelpTarget}].Buff[${Buff1}](exists)}
		{
			Toon:CastSpell[${Buff1}]
			return
		}
		if ${This.Usable[${Buff2},${FBuff2}]} && !${Group.Member[${HelpTarget}].Buff[${Buff2}](exists)}
		{
			Toon:CastSpell[${Buff2}]
			return
		}
		if ${This.Usable[${Buff3},${FBuff3}]} && !${Group.Member[${HelpTarget}].Buff[${Buff3}](exists)}
		{
			Toon:CastSpell[${Buff3}]
			return
		}
	}
/*
======================================================================
Help Routine - 
Heal/Buff Party members
======================================================================
*/		
method HelpRoutine()
	{
		This:RDebug["Entering Help Routine",3]
		if ${Toon.Casting}
		{
			return
		}
		Toon:Standup
		HelpTarget:Set[10]
		HelpType:Set[0]
		for (i:Set[0]; ${i}<=${Group.Members}; i:Inc)
		{
			if ${Group.Member[${i}](exists)} && ${Group.Member[${i}].Distance} <= 40 && ${Group.Member[${i}].PctHPs} < ${HealHP} && !${Group.Member[${i}].Dead} && ${Me.CurrentMana} > ${Spell[${SmallHeal}].Mana}
			{
				HelpTarget:Set[${i}]
				HelpType:Set[1]
			}
			if !${Me.InCombat} && ${Group.Member[${i}](exists)} && ${Group.Member[${i}].Distance} <= 30 && ((!${Group.Member[${i}].Buff[${Buff1}](exists)} && ${Spell[${Buff1}](exists)}) || (!${Group.Member[${i}].Buff[${Buff2}](exists)} && ${Spell[${Buff2}](exists)}) || (!${Group.Member[${i}].Buff[${Buff3}](exists)} && ${Spell[${Buff3}](exists))}) && !${Group.Member[${i}].Dead}
			{
				HelpTarget:Set[${i}]
				HelpType:Set[2]
			}
		}
		if ${HelpTarget} == 10
		{
			return
		}
		if ${CurrentForm} != 0
		{
			This:RShift[0]
		}
		This:RTarget[${Group.Member[${HelpTarget}].GUID},2]
		if !${Target.LineOfSight} || ${Target.Distance} > 40
		{
			This:RDebug["No LoS/Out of range, moving closer",2]
			Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
			return
		}
		else
		{
			This:RDebug["In range and LoS, stopping",2]
			move -stop
		}
		if ${HelpType} == 1
		{
			if ${Group.Member[${HelpTarget}].ReactionLevel} > 4
			{
				HealTarget:Set[${HelpTarget}]
			}
			else
			{
				return
			}
			This:HealRoutine
			This:HotRoutine
		}
		if ${HelpType} == 2
		{
			This:BuffRoutine
		}
		This:RDebug["Done with Help Routine on target ${Group.Member[${HelpTarget}].Name}",3]
	}				
/*
======================================================================
Assist Routine - 
Assist Party members
======================================================================
*/		
method AssistRoutine()
	{
		if ${Group.Member[${AssistTarget}].Name.Equal[${Me.Name}]}
		{
			This:RDebug["Noone to assist - Acting normal",1]
			return
		}
		if ${Toon.Casting} || ${Me.InCombat} || ${Group.Member[${AssistTarget}].Name.Equal[${Me.Name}]}
		{
			return
		}
		if ${Me.Target.GUID(exists)} && ${Target.ReactionLevel} <= 4 && ${Target.PctHPs} < ${PullHP} && ${Target.PctHPs} > 0 && ${Target.LineOfSight} && ${Target.Distance} < ${MaxRange}
		{
			This:PrePull
			if ${Me.Power.Equal["Rage"]}
			{
				CostMulti:Set[0.1]
				This:BearPull
				return
			}
			if ${Me.Power.Equal["Energy"]}
			{
				CostMulti:Set[1]
				This:CatPull
				return
			}
			if ${Me.Power.Equal["Mana"]}
			{
				CostMulti:Set[1]
				This:BalancePull
			}
			return
		}
		if ${Target.Buff[Shadowmeld](exists)} && ${This.Usable["Shadowmeld",${FShadowmeld}]} && !${Me.Buff[Shadowmeld](exists)} && !${Movement.Speed}
		{
			if ${This.Usable[${StealthSpell},${FStealthSpell}]} && !${This.IsDotted} && ${Target.Distance} < 20 && ${Target.PctHPs} > 50
			{
				Toon:CastSpell[${StealthSpell}]
			}
			if ${This.Usable["Shadowmeld",${FShadowmeld}]} && !${Me.Buff[Shadowmeld](exists)}
			{
				Toon:CastSpell[Shadowmeld]
			}
		}
		if !${Group.Member[${AssistTarget}].Target.GUID(exists)} && !${Group.Member[${AssistTarget}].Name.Equal[${Target.Name}]}
		{
			This:RTarget[${Group.Member[${AssistTarget}].GUID},2]
			return
		}
		Random:Set[${Math.Rand[100]}]
		if ${Group.Member[${AssistTarget}](exists)} && (${Group.Member[${AssistTarget}].Buff[Prowl](exists)} || ${Group.Member[${AssistTarget}].Buff[Stealth](exists)}) && ${Group.Member[${AssistTarget}].Name.Equal[${Target.Name}]} && ${Group.Member[${AssistTarget}].Target.Distance} < 25 && ${Group.Member[${AssistTarget}].Target.LineOfSight}
		{
			This:RDebug["Ally in stealth. Stopping. I'm close enough.",3]
			Navigator:MoveToLoc[${Me.X},${Me.Y},${Me.Z}]
		}
		elseif ${Group.Member[${AssistTarget}].Target.GUID(exists)} && ${Group.Member[${AssistTarget}].Target.Name.Equal[${Target.Name}]} && ${Group.Member[${AssistTarget}].Target.Distance} < ${MaxRange} && ${Group.Member[${AssistTarget}].Target.LineOfSight} && ${Random} < 10
		{
			This:RDebug["Hostile! Stopping. I'm close enough.",3]
			Navigator:MoveToLoc[${Me.X},${Me.Y},${Me.Z}]
		}
		elseif ${Group.Member[${AssistTarget}](exists)} && ${Group.Member[${AssistTarget}].Name.Equal[${Target.Name}]} && ${Group.Member[${AssistTarget}].Distance} < ${FollowDistance} && ${Group.Member[${AssistTarget}].LineOfSight} && ${Random} < 10
		{
			This:RDebug["Stopping. I'm close enough.",3]
			Navigator:MoveToLoc[${Me.X},${Me.Y},${Me.Z}]
		}
		elseif ${Group.Member[${AssistTarget}](exists)} && ${Group.Member[${AssistTarget}].Name.Equal[${Target.Name}]} && (${Group.Member[${AssistTarget}].Distance} >= ${FollowDistance} || !${Group.Member[${AssistTarget}].LineOfSight})
		{
			This:RDebug["Moving closer to ${Target.Name}",3]
			Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
			}
		if ${Group.Member[${AssistTarget}].Target(exists)}
		{
			if ${Group.Member[${AssistTarget}].Target.ReactionLevel} <= 4 && !${Group.Member[${AssistTarget}].Target.Dead} && ${Group.Member[${AssistTarget}].Target.LineOfSight} && ${Group.Member[${AssistTarget}].Target.Distance} < ${MaxRange} && (${Group.Member[${AssistTarget}].Target.Target.Name.Equal[${Group.Member[${AssistTarget}].Name}]} || (!${Target.Tapped} && ${Target.InCombat}))
			{
				This:RTarget[${Group.Member[${AssistTarget}].Target.GUID},2]
				return
			}
			elseif ${Group.Member[${AssistTarget}].Target.ReactionLevel} >= 4
			{
				This:RTarget[${Group.Member[${AssistTarget}].GUID},2]
				return
			}
		}
		else
		{
			This:RTarget[${Group.Member[${AssistTarget}].GUID},0]
		}
	}
/*
======================================================================
Correct Form - 
11 = Never Use. 10 = All Forms, 9 = 0,1. 8 = 0,2. 7 = 0,3. 6 = 1,2.
======================================================================
*/		
member CorrectForm(int ReqForm)
	{
		This:RDebug["Checking ${CurrentForm} against ${ReqForm}",3]
		if ${ReqForm} == 11
		{
			This:RDebug["Required form is NONE",3]
			return FALSE
		}
		if ${ReqForm} == 10
		{
			This:RDebug["Required form is ANY",3]
			return TRUE
		}
		if ${ReqForm} == 12 && (${CurrentForm} == 1 || ${CurrentForm} == 2)
		{
			This:RDebug["Required form is 1 or 2",3]
			return TRUE
		}
		if ${ReqForm} == 9 && (${CurrentForm} == 0 || ${CurrentForm} == 1)
		{
			This:RDebug["Required form is 0 or 1",3]
			return TRUE
		}
		if ${ReqForm} == 8 && (${CurrentForm} == 0 || ${CurrentForm} == 2)
		{
			This:RDebug["Required form is 0 or 2",3]
			return TRUE
		}
		if ${ReqForm} == 7 && (${CurrentForm} == 0 || ${CurrentForm} == 3)
		{
			This:RDebug["Required form is 0 or 3",3]
			return TRUE
		}
		if ${ReqForm} == 6 && (${CurrentForm} == 1 || ${CurrentForm} == 2)
		{
			This:RDebug["Required form is 1 or 2",3]
			return TRUE
		}
		if ${CurrentForm} == ${ReqForm}
		{
			return TRUE
			This:RDebug["In the Correct Form",3]
		}
		return FALSE
	}
/*
======================================================================
Pot Routine - 
Potioning Routine for Caster/Moonkin
======================================================================
*/		
method PotRoutine()
	{
		if ${Me.PctMana} < ${This.PotMana} && ${Consumable.HasMPot} && !${Me.Buff[${ManaRegen}](exists)}
			{
				Consumable:useMPot()
				return
			}
		if ${Me.PctHPs} < ${This.PotHP} && ${Consumable.HasMPot}
			{
				Consumable:useHPot()
				return
			}
	}
/*
======================================================================
Hot Routine - 
Hot'ing Routine for Caster
======================================================================
*/		
method HotRoutine()
	{
		This:PotRoutine
		if ${This.Usable[${ManaRegen},${FManaRegen}]} && ${Me.PctMana} < ${InnervateMod}
		{
			Toon:CastSpell[${ManaRegen}]
			return
		}
		if ${Group.Member[${HelpTarget}].PctHPs} < ${This.HealHP} && !${Toon.Casting}
 		{
	 		This:RTarget[${Group.Member[${HealTarget}].GUID},2]
	      	if ${This.Usable[${HoTHeal},${FHoTHeal}]} && ${Target.PctHPs} < ${This.FastHealHP} && !${Target.Buff[${HoTHeal}](exists)}
	      		{
	        		Toon:CastSpell[${HoTHeal}]
	        		This:RDebug["Heal Routine - Casting ${HoTHeal}",2]
					return
	      		}
	  	}
	}

/*
======================================================================
Check Current Form - 
Checks what form I am currently in
======================================================================
*/	
method SortForms()
	{
		for (i:Set[1]; ${i}<=10; i:Inc)
		{
			if ${WoWScript[GetShapeshiftFormInfo(${i}),2](exists)}
			{
				if ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Bear Form"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Dire Bear Form"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Devotion Aura"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Stealth"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Ghost Wolf"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Battle Stance"]}
				{
					This.Form1:Set[${i}]
				}
				elseif ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Aquatic Form"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Retribution Aura"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Defensive Stance"]}
				{
					This.Form2:Set[${i}]
				}
				elseif ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Cat Form"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Concentration Aura"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Bezerker Stance"]}
				{
					This.Form3:Set[${i}]
				}
				elseif ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Travel Form"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Shadow Resistance Aura"]}
				{
					This.Form4:Set[${i}]
				}
				elseif ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Moonkin Form"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Tree of Life"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Frost Resistance Aura"]}
				{
					This.Form5:Set[${i}]
				}
				elseif ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Flight Form"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Swift Flight Form"]} || ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Fire Resistance Aura"]}
				{
					This.Form6:Set[${i}]
				}
				elseif ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Crusader Aura"]}
				{
					This.Form7:Set[${i}]
				}
				elseif ${WoWScript[GetShapeshiftFormInfo(${i}),2].Equal["Sanctity Aura"]}
				{
					This.Form8:Set[${i}]
				}
			}
		}
	}

/*
======================================================================
Check Current Form - 
Checks what form I am currently in
======================================================================
*/	
method CheckCurrentForm()
	{
		This:SortForms
		if ${WoWScript[GetShapeshiftForm()](exists)}
		{
			CurrentForm:Set[${WoWScript[GetShapeshiftForm()]}]
		}
		else
		{
			CurrentForm:Set[0]
		}
	}
	
/*
======================================================================
Spell Usable - 
Checks to see if a spell is useable
======================================================================
*/	
member Usable(string thisSpell, int ReqForm, int SpellSchool)
	{
		CurrentSpell:Set[${thisSpell}]
		CurrentSpellSchool:Set[${SpellSchool}]
		This:RDebug["Trying to cast ${CurrentSpell} - School ${CurrentSpellSchool}",5]
		if ${Spell[${thisSpell}](exists)} && !${Spell[${thisSpell}].Cooldown} && (${Me.CurrentPower} > (${Spell[${thisSpell}].Mana}*${CostMulti}) || ${Me.Buff[Clearcasting](exists)} || ${Me.Buff[Inner Focus](exists)}) && ${Me.Action[${thisSpell}].Usable} && (${Immunity} != ${SpellSchool} || ${Immunity} == 0) && ${This.CorrectForm[${ReqForm}]}
		{
			return TRUE
		}
		return FALSE
	}

/*

/*
======================================================================
Check Behind - 
Checks to see if I'm behind the target
======================================================================
*/	
member Behind()
{
		if ${Me.Target.Distance} <= 10 && ${Me.Target.Distance} >= 2 && (${Math.Abs[${Target.Heading} - ${Me.Heading}]} < 90)
		{
			return TRUE
		}	
		return FALSE
}	
/*
======================================================================
Set Danger Level - 
Checks out the current situation and asseses the danger I am in
======================================================================
*/
method SetDanger()
	{
		variable guidlist Aggros
		if ${Tanking}
		{
			Aggros:Search[-units,-nearest,-aggro,-alive,-range 0-40]
		}
		else
		{
			Aggros:Search[-units,-nearest,-targettingme,-alive,-range 0-40]
		}
		This.DangerLevel:Set[${DangerLevel} * 0.5]
		This.DangerLevel:Set[${DangerLevel} + ${Aggros.Count}*6.5]
		if ${RSpec} == 1
		{
			This.DangerLevel:Set[${DangerLevel} + ((100 - ${Me.PctMana})*0.10)]
		}
		else 
		{
			This.DangerLevel:Set[${DangerLevel} + ((100 - ${Me.PctMana})*0.15)]
		}
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
		if ${Target.PctHPs} < 25 && ${Aggros.Count} < 2
		{
			This.DangerLevel:Set[${DangerLevel} - 10]
		}
		if ${DangerLevel} < 0
		{
			This.DangerLevel:Set[0]
		}
		if ${Tanking}
		{
			if ${DangerLevel} > (${DangerVeryHigh}*1.5)
			{
				This:RDebug["Danger - Very High ${DangerLevel}",1]
				This.Dangerlvl:Set[3]
				return
			}
		}
		else
		{
			if ${DangerLevel} > ${DangerVeryHigh}
			{
				This:RDebug["Danger - Very High ${DangerLevel}",1]
				This.Dangerlvl:Set[3]
				return
			}
		}
		if ${DangerLevel} > ${DangerHigh}
		{
			This:RDebug["Danger - High ${DangerLevel}",1]
			This.Dangerlvl:Set[2]
			return
		}
		if ${DangerLevel} > ${DangerMedium}
		{
			This:RDebug["Danger - Medium ${DangerLevel}",2]
			This.Dangerlvl:Set[1]
			return
		}
		This:RDebug["Danger - Low ${DangerLevel}",3]
		This.Dangerlvl:Set[0]
		return
	}
/*
======================================================================
Is Dotted - 
Checks to see if i'm dotted
======================================================================
*/

member IsDotted()
	{
		variable int i
		variable int buffdex
		variable int indexx = 1
		variable int TotalLines
		variable string TextLine
	
		if ${WoWScript["GetPlayerBuff(${indexx}, \"HARMFUL\")"]} > 0
		{
			do
			{
				i:Set[1]
				buffdex:Set[${WoWScript["GetPlayerBuff(${indexx}, \"HARMFUL\")"]}]
				WoWScript GameTooltip:ClearLines()		
				WoWScript GameTooltip:SetOwner(UIParent,"ANCHOR_NONE")
				WoWScript GameTooltip:SetPlayerBuff(${buffdex})
				TotalLines:Set[${WoWScript["GameTooltip:NumLines()"]}]
				do
				{
					TextLine:Set[${String["${WoWScript[GameTooltipTextLeft${i}:GetText()]}"]}]
					if ${TextLine.Find[damage every]} || ${TextLine.Find[damage inflicted every]}
					{
						WoWScript GameTooltip:Hide()
						return TRUE
					}
				}
				while ${i:Inc} <= ${TotalLines}
				WoWScript GameTooltip:Hide()									
			}
			while ${WoWScript["GetPlayerBuff(${indexx:Inc}, \"HARMFUL\")"]} > 0
		}
		return FALSE
	}
	
/*
======================================================================
Get my Talent Spec - 
Find where i've spent my talent points
======================================================================
*/

	method GetSpec()
	{
		This.BalancePoints:Set[${WoWScript["GetTalentTabInfo(1)", 3]}]
		This.FeralPoints:Set[${WoWScript["GetTalentTabInfo(2)", 3]}]
		This.RestoPoints:Set[${WoWScript["GetTalentTabInfo(3)", 3]}]
		
	if (${BalancePoints} > ${FeralPoints}) && (${BalancePoints} > ${RestoPoints})
		{
			This.RSpec:Set[1]
		}
	elseif (${FeralPoints} > ${BalancePoints}) && (${FeralPoints} > ${RestoPoints})
		{
			This.RSpec:Set[2]
		}
	elseif (${RestoPoints} > ${BalancePoints}) && (${RestoPoints} > ${FeralPoints})
		{
			This.RSpec:Set[3]
		}
	else 
		{
			This.RSpec:Set[0]
		}
	}

/*
======================================================================
RDebug - 
Sends Debug messages
======================================================================
*/
method RDebug(string RMsg, int MsgType)
{
	if ${DebugLevel} >= ${MsgType}
	{	
		This:Output[${RMsg}]
	}
}

/*
======================================================================
CancelAllForms - 
Shift to caster form
======================================================================
*/	
method CancelAllForms()
{
	if ${WoWScript[GetShapeshiftForm()]} != 0
	{
		WoWScript CastShapeshiftForm(${WoWScript[GetShapeshiftForm()]})
	}
}
	
/*
======================================================================
RWait - 
Wait command
======================================================================
*/	
method RWait(int WaitTime)
	{
		if ${CurrentWait} == 0
		{
			This.CurrentWait:Set[${WaitTime}]
			return
		}
		elseif ${CurrentWait} > 0
		{
			if ${Toon.Casting}
			{
			return
			}
			else
			{
				CurrentWait:Dec
				This:RDebug["Waiting... ${CurrentWait} Pulse left.",1]			
			}
		}
	}
/*
======================================================================
Immune - 
Immune check
======================================================================
*/
method CombatEvent(string unitID, string unitAction, string isCrit, string amtDamage, string damageType)
{
             if ${unitID.Equal["target"]} && ${unitAction.Equal[dodge]}      
             {
                         This:RDebug["Dodge!",1]
             }
             if ${unitID.Equal["target"]} && ${unitAction.Equal[parry]}      
             {
                         This:RDebug["Parry!",1]
             }
             if ${unitID.Equal["target"]} && ${unitAction.Equal[block]}      
             {
                         This:RDebug["Block!",1]
             }
             if ${unitID.Equal["target"]} && ${unitAction.Equal[resist]}      
             {
                         This:RDebug["Resist!",1]
             }
}
/*
======================================================================
UI Errors - 
Checks + Reacts to UI Errors
======================================================================
*/	
	method CreateUIErrorStrings()
	{
		This.UIErrorMsgStrings:Set["You are facing the wrong way!"]
		This.UIErrorMsgStrings:Set["Target not in line of sight"]
		This.UIErrorMsgStrings:Set["Can't use items while shapeshifted."]
		This.UIErrorMsgStrings:Set["You are in shapeshift form"]
		This.UIErrorMsgStrings:Set["You are too far away!"]
		This.UIErrorMsgStrings:Set["There is nothing to attack."]
		This.UIErrorMsgStrings:Set["You must be behind your target"]
	}

	method UIErrorMessage(string Id, string Msg)
	{
		if ${This.UIErrorMsgStrings.Element[${Msg}](exists)} && !${Bot.PauseFlag} 
		{
			if ${Msg.Equal[You are facing the wrong way!]} && !${Toon.Casting}
			{
				This:RDebug["UI Error: ${Msg}",1]
				if ${Me.Target(exists)}&& !${Me.Target.Name.Equal[${Me.Name}]}
			{
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
			}
				Navigator:MoveBackward[2000]
				return				
			}
			if ${Msg.Equal[Can't use items while shapeshifted.]}
			{
				This:RDebug["UI Error: ${Msg}",1]
				This:CancelAllForms
				return				
			}
			if ${Msg.Equal[You are in shapeshift form]}
			{
				This:RDebug["UI Error: ${Msg}",1]
				This:CancelAllForms
				return				
			}
			if ${Msg.Equal[Target not in line of sight]}
			{
				This:RDebug["UI Error: ${Msg}",1]
				WoWPress JUMP
				return				
			}
			if ${Msg.Equal[You must be behind your target]}
			{
				This:RDebug["UI Error: ${Msg}",1]
				Navigator:MoveBackward[1000]
				return				
			}
		}
	}	

	
member checkForScrolls()
	{
		if ${Consumable.HasScroll[Strength]} && !${Me.Buff[Strength](exists)}
		{
					This:RDebug["Scroll Pulse: Using Scroll of Strength",1]
				return "Strength"
		}
		if ${Consumable.HasScroll[Agility]} && !${Me.Buff[Agility](exists)}
		{
						This:RDebug["Scroll Pulse: Using Scroll of Agility",1]
				return "Agility"
		}
		if ${Consumable.HasScroll[Stamina]} && !${Me.Buff[Stamina](exists)} && !${Me.Buff[Power Word: Fortitude](exists)} 
		{
					This:RDebug["Scroll Pulse: Using Scroll of Stamina",1]
				return "Stamina"
		}
		if ${Consumable.HasScroll[Protection]} && !${Me.Buff[Armor](exists)}
		{
					This:RDebug["Scroll Pulse: Using Scroll of Protection",1]
				return "Protection"
		}
		if ${Consumable.HasScroll[Spirit]} && !${Me.Buff[Spirit](exists)} && !${Me.Buff[Divine Spirit](exists)} 
		{
				This:RDebug["Scroll Pulse: Using Scroll of Spirit",1]
				return "Spirit"
		}
		if ${Consumable.HasScroll[Intellect]} && !${Me.Buff[Intellect](exists)} && !${Me.Buff[Arcane Intellect](exists)} 
		{
				This:RDebug["Scroll Pulse: Using Scroll of Intellect",1]
				return "Intellect"
		}
		return "NONE"
	}	
	
method debuffAll()
	{
		if ${Me.PctMana} < 15 || ${Toon.Casting}
		{
			return
		}
		This:RDebug["Curing ${Group.Member[${HealTarget}].Name}",3]
		for (BuffNum:Set[0]; ${BuffNum} <= 15; BuffNum:Inc)
		{
			if ${Group.Member[${HealTarget}].Buff[${BuffNum}].Harmful}
			{
				if ${Group.Member[${HealTarget}].Buff[${BuffNum}].DispelType.Equal[${CureSpellType}]}
				{
					This:RDebug["${Group.Member[${HealTarget}].Name} ${CureSpellType} Debuff",0]
					if ${This.Usable[${CureSpell},${FCureSpell}]} && !${Group.Member[${HealTarget}].Buff[${CureSpell}](exists)}
	      			{
		      			This:RTarget[${Group.Member[${HealTarget}].GUID},2]
	        			This:RDebug["${CureSpell}",2]
						Toon:CastSpell[${CureSpell}]
						return
	      			}
				}
				if ${Group.Member[${HealTarget}].Buff[${BuffNum}].DispelType.Equal[${CureSpell2Type}]}
				{
					This:RDebug["${Group.Member[${HealTarget}].Name} ${CureSpell2Type} Debuff",0]
					if ${This.Usable[${CureSpell2},${FCureSpell2}]} && !${Group.Member[${HealTarget}].Buff[${CureSpell2}](exists)}
	      			{
		      			This:RTarget[${Group.Member[${HealTarget}].GUID},2]
	        			This:RDebug["${CureSpell2}",2]
						Toon:CastSpell[${CureSpell2}]
						return
	      			}
				}
				if ${Group.Member[${HealTarget}].Buff[${BuffNum}].DispelType.Equal[${CureSpell3Type}]}
				{
					This:RDebug["${Group.Member[${HealTarget}].Name} ${CureSpell3Type} Debuff",0]
					if ${This.Usable[${CureSpell3},${FCureSpell3}]} && !${Group.Member[${HealTarget}].Buff[${CureSpell3}](exists)}
	      			{
		      			This:RTarget[${Group.Member[${HealTarget}].GUID},2]
	        			This:RDebug["${CureSpell3}",2]
						Toon:CastSpell[${CureSpell3}]
						return
	      			}
				}
			}
		}
	}	
member IsRooted()
	{
		if ${Target.Buff[Entangling Roots](exists)} || ${Target.Buff[Frost Nova](exists)}
		{
			return TRUE
		}
		return FALSE
	}
member NeedHelpTarget()
	{
		This:RDebug["Checking for targets to heal",3]
		for (i:Set[0]; ${i}<=${Group.Members}; i:Inc)
		{
			if ${Group.Member[${i}](exists)} && ${Group.Member[${i}].Distance} <= 40 && ${Group.Member[${i}].PctHPs} < ${HealHP} && !${Group.Member[${i}].Dead} && !${Group.Member[${i}].Ghost} && ${Me.PctMana} > 10 
			{
				This:RDebug["${Group.Member[${i}]} needs Healing",2]
				return "HEAL"
			}
			if ${Group.Member[${i}](exists)} && ${Group.Member[${i}].Distance} <= 30 && ((!${Group.Member[${i}].Buff[${Buff1}](exists)} && ${Spell[${Buff1}](exists)}) || (!${Group.Member[${i}].Buff[${Buff2}](exists)} && ${Spell[${Buff2}](exists)}) || (!${Group.Member[${i}].Buff[${Buff3}](exists)} && ${Spell[${Buff3}](exists)})) && !${Group.Member[${i}].Dead} && !${Group.Member[${i}].Ghost} && ${Me.PctMana} > 10 && !${Group.Member[${i}].InCombat}
			{
				This:RDebug["${Group.Member[${i}]} needs Buffing",2]
				return "BUFF"
			}
		}
		if ${AutoAssist} && !${Me.InCombat}
		{
			NearestMember:Set[0]
			NearestDistance:Set[100]
			for (i:Set[0]; ${i}<=${Group.Members}; i:Inc)
			{
				if ${Group.Member[${i}](exists)} && ${Group.Member[${i}].Distance} > 1 && !${Group.Member[${i}].Dead}
				{
					NearestMember:Set[${i}]
					NearestDistance:Set[${Group.Member[${i}].Distance}]
				}
			}
			if !${Group.Member[${NearestMember}].Name.Equal[${Target.Name}]}
			{
				This:RDebug["Nearest Party member: ${Group.Member[${NearestMember}].Name}",3]
			}
			AssistTarget:Set[${NearestMember}]
		}
		if ${Group.Member[${AssistTarget}](exists)} && !${Me.InCombat}
		{
			This:RDebug["${Group.Member[${AssistTarget}].Name} is in range",3]
			if ${Group.Member[${AssistTarget}].Casting.Name.Equal["Teleport: Moonglade"]} || ${Group.Member[${AssistTarget}].Casting.Name.Equal["Hearthstone"]}
			{
				This:RTarget[${Me.GUID},5]
				This:RDebug["Target Teleporting - Plx don't crash",1]
				return "NORMAL"
			}
			if !${Me.InCombat} && (${Group.Member[${AssistTarget}].Buff[Drink](exists)} || ${Group.Member[${AssistTarget}].Buff[Food](exists)} || ${Group.Member[${AssistTarget}].Buff[Resurrection Sickness](exists)})
			{
				This:RDebug["Waiting for ${Group.Member[${AssistTarget}].Name} to finish resting",3]
				This:RTarget[${Group.Member[${AssistTarget}].GUID},5]
				return "ASSIST"
			}
			if !${Group.Member[${AssistTarget}].Name.Equal[${Me.Name}]} && ${CanTank} && ${Group.Member[${AssistTarget}].Target.Name.Equal[${Me.Name}]} && !${Me.InCombat} && (${LavishScript.RunningTime} <= ${PullTimer} || ${PullTimer} == 0)
			{
				This:RDebug["I'm Tanking",3]
				Tanking:Set[TRUE]
				return "LEAD"
			}
			if ${Group.Member[${AssistTarget}](exists)} && !${Group.Member[${AssistTarget}].Name.Equal[${Me.Name}]} && ${Group.Member[${AssistTarget}].Target.ReactionLevel} >= 4 && !${Tanking} && !${Group.Member[${AssistTarget}].Target.Name.Equal[${Me.Name}]}
			{
				if ${Group.Member[${AssistTarget}].Target.CanRepair} && ${Group.Member[${AssistTarget}].Target.Distance} < 15 &&${Group.Member[${AssistTarget}].Target.Distance} > 5
				{
					POI.NeedRepair:Set[TRUE]
					return "REPAIR"
				}
				if ${Group.Member[${AssistTarget}].Target.IsMerchant} && ${Group.Member[${AssistTarget}].Target.Distance} < 15 &&${Group.Member[${AssistTarget}].Target.Distance} > 5
				{
					POI.NeedSell:Set[TRUE]
					return "SELL"
				}
				if ${Group.Member[${AssistTarget}].Target.CanGossip} && ${Group.Member[${AssistTarget}].Target.Distance} < 15 &&${Group.Member[${AssistTarget}].Target.Distance} > 5
				{
					return "QUEST"
				}
			}
			if ${Group.Member[${AssistTarget}].Target.Dead} && ${LootAssist}
			{
				return "LOOT"
			}
			if ${Group.Member[${AssistTarget}].Name.Equal[${Me.Name}]}
			{
				This:RDebug["No Nearby Party Members",3]
				return "NORMAL"
			}
			if !${Me.InCombat} && (!${Me.Target(exists)} || (${Me.Target(exists)} && ${Me.Target.ReactionLevel} <=3))
			{
				Tanking:Set[FALSE]
			}
		return "ASSIST"
		}
	}
	
	method RTarget(string NewTargetID, int TargetType)
	{
		if !${Me.InCombat} && (${LavishScript.RunningTime} <= ${PullTimer} || ${PullTimer} == 0) && !${TargetType} == 2
		{
			return
		}
		if ${TargetType} == 2 || ${TargetType} == 5
		{
			This:RDebug["Heal Targetting: ${NewTargetID}",3]
			target ${NewTargetID}
			TargetCD:Set[${TargetLimit}]
			return
		}
		if ${TargetCD} > 0
		{
			This:RDebug["Target Switch Cooldown - ${TargetCD} Left",3]
			TargetCD:Dec
			return
		}
		if ${Me.Target(exists)} && !${[{Me.Target.GUID}].Equal[${NewTargetID}]}
		{
			if ${TargetType} == 3
			{
				This:RDebug["Heal/Buff/Force Targetting: ${NewTargetID}",3]
				target ${NewTargetID}
				TargetCD:Set[${TargetLimit}]
				return
			}
			if ${TargetType} == 0
			{
				if ${Targeting.TargetCollection.Get[1](exists)} && ${Tanking}
				{
					This:RDebug["Combat Targetting: ${Targeting.TargetCollection.Get[1]}",3]
					Target ${Targeting.TargetCollection.Get[1]}
					TargetCD:Set[${TargetLimit}]
					return
				}
				else
				{
					This:RDebug["Combat Idle Targetting: ${NewTargetID}",3]
					target ${NewTargetID}
					TargetCD:Set[${TargetLimit}]
				}
			}
		}
		else
		{
			This:RDebug["Targetting ${NewTargetID}",3]
			target ${NewTargetID}
			TargetCD:Set[${TargetLimit}]
		}
	}
	method CheckTarget()
	{
		if ${Target.GUID.NotEqual[${Targeting.TargetCollection.Get[1]}]} && ${Unit[${Targeting.TargetCollection.Get[1]}](exists)}
		{
			This:RTarget[${Targeting.TargetCollection.Get[1]},0]
			return
		}
	}
	method TankingRoutine()
	{
		if !${Toon.Casting} && ${Tanking}
		{
			if ${TankTimer} > ${LavishScript.RunningTime}
			{
				return
			}
			else
			{
				TankTimer:Set[0]
			}
			if ${TankTimer} == 0
			{
				TankTimer:Set[${LavishScript.RunningTime} + ${TankCheckDelay}]
				variable guidlist NeedTanking
				NeedTanking:Search[-units,-alive,-nonfriendly,-attackable,-nearest,-range 0-40]
				if ${NeedTanking.Count} > 0
				{
					This:RDebug["${NeedTanking.Count} Mobs need to be tanked",2]
					for (i:Set[0]; ${i} <= ${Group.Members}; i:Inc)
					{
						for (j:Set[1]; ${j} <= ${NeedTanking.Count}; j:Inc)
						{
							if !${Group.Member[${i}].Name.Equal[${Me.Name}]}
							{
								if ${NeedTanking.Object[${j}].Target(exists)} && ${NeedTanking.Object[${j}].Target.GUID.Equal[${Group.Member[${i}].GUID}]} && !${Me.Target.GUID.Equal[${NeedTanking.Object[${j}].GUID}]}
								{
									This:RTarget[${NeedTanking.Object[${j}].GUID},5]
									This:RDebug["${Group.Member[${i}].Name} Has Aggro on ${NeedTanking.Object[${j}].Name}",1]
									return
								}
							}
						}
					}
				}
			}
		}
	}
	
	method PrePull()
	{
		if ${Target.CreatureType.Equal["Elemental"]} || ${Target.CreatureType.Equal["Mechanical"]} || ${Target.Name.Find["Infernal"]} || ${Target.Name.Find["Imp"]}
		{
			Immunity:Set[8]
		}
		else
		{
			Immunity:Set[0]
		}
		CurrentSpell:Set["NULL"]
		CurrentSpellSchool:Set[0]
		if ${Tanking} && ${HealHp} == ${GroupHealHp}
		{
			This:RDebug["Set Solo Config",1]
			HealHP:Set[${SoloHealHp}]
			return
		}
		if !${Tanking} && !${Group.Member[${AssistTarget}].Name.Equal[${Me.Name}]} && ${HealHp} != ${GroupHealHp}
		{
			This:RDebug["Set Party Config",1]
			HealHP:Set[${GroupHealHp}]
			return
		}
	}
	/*
	Druid Moonglad Training
	*/
	method RTrain()
	{
		if ${RTraining} == 0 || ${Toon.Casting}
		{
			return
		}
		if ${RTraining} == 1
		{
			move -stop
			Toon:Standup
			if ${CurrentForm} == 0
			{
				Toon:CastSpell["Teleport: Moonglade",1]
				if ${Toon.Casting}
				{
					RTraining:Set[2]
				}
				This.TargetLoc:Set[7992,-2680,512]
				This:RDebug["Stage 1 - Teleporting to Moonglade",1]
			}
			else
			{
				This:RShift[0]
			}
			return
		}
		if ${RTraining} == 2
		{
			if ${Math.Distance[${Me.X},${Me.Y},${TargetLoc.X},${TargetLoc.Y}]} > 3
			{
				Navigator:MoveToLoc[${TargetLoc}]
				This:RDebug["Stage 2 - Checking I've arived (${RTraining})",2]
				return
			}
			else
			{
				RTraining:Set[3]
				This.TargetLoc:Set[8006,-2655,512]
				This:RDebug["Stage 3 - Walking to Trainer",1]
				return
			}
			return
		}
		if ${RTraining} == 3
		{
			if ${Math.Distance[${Me.X},${Me.Y},${TargetLoc.X},${TargetLoc.Y}]} > 3
			{
				Navigator:MoveToLoc[${TargetLoc}]
				This:RDebug["Stage 2 - Checking I've arived (${RTraining})",2]
				return
			}
			else
			{
				RTraining:Set[4]
				This.TargetLoc:Set[8014,-2648,512]
				This:RDebug["Stage 3 - Walking to Trainer",1]
				return
			}
			return
		}
		if ${RTraining} == 4
		{
			if ${Math.Distance[${Me.X},${Me.Y},${TargetLoc.X},${TargetLoc.Y}]} > 3
			{
				Navigator:MoveToLoc[${TargetLoc}]
				This:RDebug["Stage 2 - Checking I've arived (${RTraining})",2]
				return
			}
			else
			{
				RTraining:Set[5]
				This.TargetLoc:Set[8012,-2629,508]
				This:RDebug["Stage 3 - Walking to Trainer",1]
				return
			}
			return
		}
		if ${RTraining} == 5
		{
			if ${Math.Distance[${Me.X},${Me.Y},${TargetLoc.X},${TargetLoc.Y}]} > 3
			{
				Navigator:MoveToLoc[${TargetLoc}]
				This:RDebug["Stage 2 - Checking I've arived (${RTraining})",2]
				return
			}
			else
			{
				RTraining:Set[6]
				This.TargetLoc:Set[8010,-2614,503]
				This:RDebug["Stage 3 - Walking to Trainer",1]
				return
			}
			return
		}
		if ${RTraining} == 6
		{
			if ${Math.Distance[${Me.X},${Me.Y},${TargetLoc.X},${TargetLoc.Y}]} > 3
			{
				Navigator:MoveToLoc[${TargetLoc}]
				This:RDebug["Stage 2 - Checking I've arived (${RTraining})",2]
				return
			}
			else
			{
				RTraining:Set[7]
				This.TargetLoc:Set[8002,-2600,495]
				This:RDebug["Stage 3 - Walking to Trainer",1]
				return
			}
			return
		}
		if ${RTraining} == 7
		{
			if ${Math.Distance[${Me.X},${Me.Y},${TargetLoc.X},${TargetLoc.Y}]} > 3
			{
				Navigator:MoveToLoc[${TargetLoc}]
				This:RDebug["Stage 2 - Checking I've arived (${RTraining})",2]
				return
			}
			else
			{
				RTraining:Set[8]
				This.TargetLoc:Set[7976,-2602,491]
				This:RDebug["Stage 3 - Walking to Trainer",1]
				return
			}
			return
		}
		if ${RTraining} == 8
		{
			if ${Math.Distance[${Me.X},${Me.Y},${TargetLoc.X},${TargetLoc.Y}]} > 3
			{
				Navigator:MoveToLoc[${TargetLoc}]
				This:RDebug["Stage 2 - Checking I've arived (${RTraining})",2]
				return
			}
			else
			{
				RTraining:Set[9]
				This.TargetLoc:Set[7955,-2590,490]
				This:RDebug["Stage 3 - Walking to Trainer",1]
				return
			}
			return
		}
		if ${RTraining} == 9
		{
			if ${Math.Distance[${Me.X},${Me.Y},${TargetLoc.X},${TargetLoc.Y}]} > 3
			{
				Navigator:MoveToLoc[${TargetLoc}]
				This:RDebug["Stage 2 - Checking I've arived (${RTraining})",2]
				return
			}
			else
			{
				RTraining:Set[10]
				This.TargetLoc:Set[7935,-2577,488]
				This:RDebug["Stage 3 - Walking to Trainer",1]
				return
			}
			return
		}
		if ${RTraining} == 10
		{
			if ${Math.Distance[${Me.X},${Me.Y},${TargetLoc.X},${TargetLoc.Y}]} > 3
			{
				Navigator:MoveToLoc[${TargetLoc}]
				This:RDebug["Stage 2 - Checking I've arived (${RTraining})",2]
				return
			}
			else
			{
				RTraining:Set[11]
				This.TargetLoc:Set[7910,-2569,488]
				This:RDebug["Stage 3 - Walking to Trainer",1]
				return
			}
			return
		}
		if ${RTraining} == 11
		{
			if ${Math.Distance[${Me.X},${Me.Y},${TargetLoc.X},${TargetLoc.Y}]} > 3
			{
				Navigator:MoveToLoc[${TargetLoc}]
				This:RDebug["Stage 2 - Checking I've arived (${RTraining})",2]
				return
			}
			else
			{
				RTraining:Set[12]
				This.TargetLoc:Set[7888,-2579,487]
				This:RDebug["Stage 3 - Walking to Trainer",1]
				return
			}
			return
		}
		if ${RTraining} == 12
		{
			if ${Math.Distance[${Me.X},${Me.Y},${TargetLoc.X},${TargetLoc.Y}]} > 3
			{
				Navigator:MoveToLoc[${TargetLoc}]
				This:RDebug["Stage 2 - Checking I've arived (${RTraining})",2]
				return
			}
			else
			{
				RTraining:Set[13]
				This.TargetLoc:Set[7869,-2590,486]
				This:RDebug["Stage 3 - Walking to Trainer",1]
				return
			}
			return
		}
		if ${RTraining} == 13
		{
			if ${Math.Distance[${Me.X},${Me.Y},${TargetLoc.X},${TargetLoc.Y}]} > 3
			{
				Navigator:MoveToLoc[${TargetLoc}]
				This:RDebug["Stage 4 - Heading to Trainer",2]
				return
			}
			else
			{
				RTraining:Set[14]
				This:RDebug["Stage 5 - Arrived at Trainer",1]
				return
			}
			return
		}
		if ${RTraining} == 14
		{
			move -stop
			POI.NeedClassTrainer:Set[TRUE]
			This:RDebug["Stage 6 - Training",1]
			RTraining:Set[15]
			return
		}
		if ${RTraining} == 15
		{
			This:GetSpec
			This:Output[======================================================================]
			This:Output[Checking Spec after leveling up]
			This:Output[======================================================================]
			This:TweakConfig
			move -stop
			if !${POI.NeedClassTrainer}
			{
				This:RDebug["Stage 8 - Hearthing",1]
				Item[Hearthstone]:Use
				RTraining:Set[0]
				This:RWait[50]
				return
			}
			return
		}
	}
}