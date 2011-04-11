objectdef cParty inherits cBase
{
/*
=====================================================================
oParty - Ritz*
---------------------------------------------------------------------
Includes:
AssistCheck
Assist
Tank
CureAll
PartyCast
=====================================================================
*/	

variable int TankCheckDelay = 5000
variable int TankTimer = 0
variable int i = 0
variable int j = 0
variable bool Tanking = TRUE
variable string AssistType = "LEAD"
variable int NearestDistance = 30
variable int AssistTarget = 0
variable int Random = 0
variable int LastPull = 0

/*
=====================================================================
Adding Party support to your routine.
---------------------------------------------------------------------
Set the following variables in the routine:
 
CanTank: Allow the routine to take the lead?
Range: Range that party members must be within to be assisted
HealHP: Heal party members below this HP
HealMana: Only heal when my mana is above this %
BuffMana: Only buff when my mana is above this %
Buff1: Name of a castable buff
Buff2: Name of a castable buff
Buff3: Name of a castable buff

=====================================================================
Assist Check
---------------------------------------------------------------------
Sets what you should be doing depending on what members in your 
party are doing.

Possible returns are:
---------------------------------------------------------------------
HEAL - AssistTarget needs healing
BUFF - AssistTarget needs buffing
TELEPORT - AssistTarget is teleporting
REST - AssistTarget is resting
LEAD - You should take the lead
RANGE - AssistTarget is out of RANGE
REPAIR - AssistTarget is at a repair NPC
SELL - AssistTarget is at a sell NPC
NPC - AssitTarget is at a misc. NPC
LOOT - AssistTarget is looting
ALONE - No Party members in Class.Range
ASSIST - Have a valid AssistTarget, no special circumstances

Call them using:

	${Party.AssistType}

---------------------------------------------------------------------

Party.AssistTarget will return the group number of your AssistTarget
which you can as below:

	${Group.Member[${Party.AssistTarget}]}

=====================================================================
*/

member Exists(int ID)
{
	if ${WoWScript["GetRaidRosterInfo(${ID})"](exists)} || ${Group.Member[${ID}](exists)}
	{
		return TRUE
	}
	return FALSE
}

member Dead(int ID)
{
	if ${WoWScript["GetRaidRosterInfo(${ID})",9]} || ${Group.Member[${ID}].Dead} || ${Group.Member[${ID}].Ghost}
	{
		return TRUE
	}
	return FALSE
}

member Distance(int ID)
{
	if ${Group.Member[${ID}].Equal[${Me}]} || ${WoWScript["GetRaidRosterInfo(${ID})"].Equal[${Me}}
	{
		return 0
	}
	else
	{
		return ${Player["${WoWScript["GetRaidRosterInfo(${ID})"].Token[1,-]}"].Distance}
	}
}

member HP(int ID)
{
	if ${Group.Member[${ID}].Equal[${Me}]} || ${WoWScript["GetRaidRosterInfo(${ID})"].Equal[${Me}}
	{
		return ${Me.PctHPs}
	}
	elseif ${Group.Member[${ID}].PctHPs(exists)}
	{
		return ${Group.Member[${ID}].PctHPs}
	}
	else
	{
		return ${Player["${WoWScript["GetRaidRosterInfo(${ID})"].Token[1,-]}"].PctHPs}
	}
}


method AssistCheck()
{
	variable guidlist PVPCheck
	variable int Members
	PVPCheck:Search[-players, -pvp, -alive, -attackable, -range 0-50]
	/*		First, Check for Group Members that need Buffing/Healing		*/
	if ${WoWScript[GetNumRaidMembers()]}
	{
		Members:Set[${WoWScript[GetNumRaidMembers()]}]
	}
	else
	{
		Members:Set[${Group.Members}]
	}	
	for (i:Set[0]; ${i}<=${Members}; i:Inc)
	{
		if ${Party.Exists[${i}]} && !${Party.Dead[${i}]} && ${Party.Distance[${i}]} < ${This.AssistRange} && ${Party.HP[${i}]} < ${Class.HealHP} && ${Me.PctMana} > ${Class.HealMana}
		{
			AssistTarget:Set[${i}]
			AssistType:Set["HEAL"]
			return
		}
		if ${PVPCheck.Count} == 0 && ${Me.PctMana} > ${Class.BuffMana} && ${Party.Exists[${i}]} && !${Party.Dead[${i}]} && ${Party.Distance[${i}]} < ${This.AssistRange} && !${Group.Member[${i}].InCombat} && ((!${Group.Member[${i}].Buff[${Class.Buff1}](exists)} && ${Spell[${Class.Buff1}](exists)}) || (!${Group.Member[${i}].Buff[${Class.Buff2}](exists)} && ${Spell[${Class.Buff2}](exists)}) || (!${Group.Member[${i}].Buff[${Class.Buff3}](exists)} && ${Spell[${Class.Buff3}](exists)}))
		{
			AssistTarget:Set[${i}]
			AssistType:Set["BUFF"]
			return
		}
	}
	AssistType:Set["CLEAR"]
	return 	
	if !${Me.InCombat}
	{
		This.Tanking:Set[FALSE]
		AssistTarget:Set[0]
		NearestDistance:Set[${Config.GetSlider[sldAssistRange]}]
		/*		Find the best target to assist (Priority: In Combat > Uses Rage > Nearest)		*/
		for (i:Set[0]; ${i}<=${Group.Members}; i:Inc)
		{
			if ${This.InRange[${i},${NearestDistance}]}
			{
				if ${Group.Member[${i}].InCombat} && ${This.InRange[${i},${This.AssistRange}]} && ${i} > 0
				{
					/*		Found a party member in combat		*/
					AssistTarget:Set[${i}]
					NearestDistance:Set[0]
					return
				}
				elseif ${Group.Member[${i}].Power.Equal["Rage"]} && ${This.InRange[${i},${This.AssistRange}]} && ${i} > 0
				{
					/*		Found a party member with rage		*/
					AssistTarget:Set[${i}]
					NearestDistance:Set[0]
					return
				}
				elseif ${This.InRange[${i},${NearestDistance}]}
				{
					/*		Found a party member closer than the previous nearest		*/
					{
						if ${i} > 0
						{
							NearestDistance:Set[${Math.Distance[${Me.Location},${This.GetLocation[${i}]}]}]
						}
						AssistTarget:Set[${i}]
					}
				}
			}
		}
		if ${Group.Member[${AssistTarget}](exists)}
		{
			/*		Now that I have a target to assist, decide what to do		*/
			if ${Group.Member[${AssistTarget}].Name.Equal[${Me.Name}]} || !${Group.Member[${AssistTarget}](exists)}
			{
				/*		No Party members in Range 		*/
				This.AssistType:Set["ALONE"]
				This.Tanking:Set[FALSE]
				return
			}
			if ${Group.Member[${AssistTarget}].Casting.Find["Teleport"]} || ${Group.Member[${AssistTarget}].Casting.Equal["Hearthstone"]}
			{
				/*		Assist target is about to teleport		*/
				This.AssistType:Set["TELEPORT"]
				return
			}
			if ${Group.Member[${AssistTarget}].Buff[Drink](exists)} || ${Group.Member[${AssistTarget}].Buff[Food](exists)} || ${Group.Member[${AssistTarget}].Buff[Resurrection Sickness](exists)}
			{
				/*		Assist target is resting or has rez sickness		*/
				This.AssistType:Set["REST"]
				return
			}
			if ${Group.Member[${AssistTarget}].Distance} > 50
			{
				/*		Assist target is out of Range		*/
				This.AssistType:Set["RANGE"]
				return
			}
			if ${Group.Member[${AssistTarget}](exists)} && !${Group.Member[${AssistTarget}].Name.Equal[${Me.Name}]} && ${Group.Member[${AssistTarget}].Target.ReactionLevel} >= 4 && !${Group.Member[${AssistTarget}].Target.Name.Equal[${Me.Name}]}
			{
				if ${Group.Member[${AssistTarget}].Target.CanRepair} && ${Group.Member[${AssistTarget}].Target.Distance} < 15 &&${Group.Member[${AssistTarget}].Target.Distance} > 5
				{
					/*		Assist target is at a repair NPC		*/
					This.AssistType:Set["REPAIR"]
					return
				}
				if ${Group.Member[${AssistTarget}].Target.IsMerchant} && ${Group.Member[${AssistTarget}].Target.Distance} < 15 && ${Group.Member[${AssistTarget}].Target.Distance} > 5
				{
					/*		Assist target is at a sell NPC		*/
					This.AssistType:Set["SELL"]
					return
				}
				if ${Group.Member[${AssistTarget}].Target.IsTaxiMaster} && ${Group.Member[${AssistTarget}].Target.Distance} < 15 && ${Group.Member[${AssistTarget}].Target.Distance} > 5
				{
					/*		Assist target is at a taxi master		*/
					This.AssistType:Set["TAXI"]
					return
				}
				if ${Group.Member[${AssistTarget}].Target.CanGossip} && ${Group.Member[${AssistTarget}].Target.Distance} < 15 && ${Group.Member[${AssistTarget}].Target.Distance} > 5
				{
					/*		Assist target is at an NPC		*/
					This.AssistType:Set["NPC"]
					return
				}
			}
			if ${Group.Member[${AssistTarget}].Target.Lootable}
			{
				/*		Assist target is looting		*/
				This.AssistType:Set["LOOT"]
				return
			}
			if ${This.CanTank} && (${Group.Member[${AssistTarget}].Target.Name.Equal[${Me.Name}]} || (${Group.Member[${AssistTarget}].Target.Name.Equal[${Me.Target.Name}]} && ${Me.Target.Dead} && !${Me.Target.Lootable}))
			{
				/*		Assist target is targetting me, Taking the lead		*/
				This.Tanking:Set[TRUE]
				This.AssistType:Set["LEAD"]
				return
			}
		}	
	}
	/*		Have a target to assist and nothing special is happening		*/
	This.AssistType:Set["ASSIST"]
	return
}

/*
=====================================================================
Tank
---------------------------------------------------------------------
Check all nearby mobs' targets and switches targets if it finds one
targetting another party member
=====================================================================
*/

method Tank()
{	
	variable guidlist NeedTanking
	NeedTanking:Search[-units, -alive, -nonfriendly, -attackable, -nearest, -incombat, -range 0-40]
	if ${This.TankTimer} > ${LavishScript.RunningTime}
	{
		return
	}
	else
	{
		This.TankTimer:Set[0]
	}
	if ${This.TankTimer} == 0
	{
		This.TankTimer:Set[${LavishScript.RunningTime} + ${This.TankCheckDelay}]
		if ${NeedTanking.Count} > 0
		{
			for (i:Set[0]; ${i} <= ${Group.Members}; i:Inc)
			{
				for (j:Set[1]; ${j} <= ${NeedTanking.Count}; j:Inc)
				{
					if ${NeedTanking.Object[${j}].Target.Name.Equal[${Group.Member[${i}].Name}]} && ${Group.Member[${i}].Name.NotEqual[${Me.Name}]}
					{
						This:Output["${Group.Member[${i}].Name} Has Aggro on ${NeedTanking.Object[${j}].Name}"]
						if !${NeedTanking.Object[${j}].Player(exists)}
						{
							if ${Me.Target.Player(exists)} && ${Me.Target.ReactionLevel} <= 4
							{
								This:Output["but I have a hostile PvP target, so I'm not helping."]
							}
							else
							{
								target ${NeedTanking.Object[${j}].GUID}
								return
							}
						}
						
					}
				}
			}
			This:Output["I'm a pro tank and have aggro on everything, choosing the best target.."]
			if !${Toon.TargetIsBestTarget}
			{
				Toon:BestTarget
			}	
		}
	}
}

/*
=====================================================================
Assist
---------------------------------------------------------------------
For following/assisting
=====================================================================
*/

method ChooseTarget()
{
	if ${Group.Member[${AssistTarget}].Target(exists)}
	{
		if ${Group.Member[${AssistTarget}].Target.ReactionLevel} <= 4 && !${Group.Member[${AssistTarget}].Target.Dead} && ${Group.Member[${AssistTarget}].Target.LineOfSight} && (${Group.Member[${AssistTarget}].Target.Target.Name.Equal[${Group.Member[${AssistTarget}].Name}]} || (${Target.TappedByMe} || (!${Target.Tapped} && ${Target.InCombat}))
		{
			/*		Targetting AssistTarget's Target		*/
			target ${Group.Member[${AssistTarget}].Target.GUID}
			return
		}
		elseif ${Group.Member[${AssistTarget}].Target.ReactionLevel} > 4
		{
			/*		Targetting AssistTarget		*/
			target ${Group.Member[${AssistTarget}].GUID}
			return
		}
	}
	/*		Targetting AssistTarget		*/
	target ${Group.Member[${AssistTarget}]}
	return
}

/* moved this into Party Roam to take advantage of POI setting when assist is not nearby */
/* if this is the only placed used -- might remove it from here */ 
method Assist()
{
	if ${Me.Target(exists)} && ${Target.ReactionLevel} <= 4 && ${Target.PctHPs} > 0 && ${Target.LineOfSight} && (${Target.TappedByMe} || !${Target.Tapped} && ${Target.InCombat})
	{
		/*		I have a hostile target, and it's tapped to my group/untapped. Pulling.	*/
		if ${This.LastPull} < ${LavishScript.RunningTime}
		{
			Navigator:ClearPath
			move -stop
			This.LastPull:Set[${LavishScript.RunningTime} + 1500]
		}
		if !${Movement.Speed}
		{
			Class:PullPulse
		}
		return
	}
	if ${Me.Casting}
	{
		return
	}
	if !${Group.Member[${AssistTarget}].Target(exists)}
	{
		/*		AssistTarget has no target, targeting him		*/
		target ${Group.Member[${AssistTarget}].GUID}
	}
	This.Random:Set[${Math.Rand[100]}]
	if ${Group.Member[${AssistTarget}](exists)} && (${Group.Member[${AssistTarget}].Buff[Prowl](exists)} || ${Group.Member[${AssistTarget}].Buff[Stealth](exists)}) && ${Group.Member[${AssistTarget}].Name.Equal[${Target.Name}]} && ${Group.Member[${AssistTarget}].Target.Distance} < ${This.MaxRange} && ${Group.Member[${AssistTarget}].Target.LineOfSight}
	{
		/*		Assit Target is in stealth		*/
		if ${Group.Member[${AssistTarget}].Target.Distance} > ${This.MaxRange} && ${Group.Member[${AssistTarget}]Distance} < 25
		{
			/*		Moving to 25 yards of his target		*/
			if ${This.Random} < 10
			{
				Navigator:MoveToMob[${Group.Member[${AssistTarget}].Target.GUID}]
			}
			else
			{
				Navigator:ClearPath
				move -stop
				return
			}
		}
		else
		{
			/*		Stopping and waiting for the pull		*/
			return
		}
	}
	elseif ${Group.Member[${AssistTarget}].Target(exists)} && ${Group.Member[${AssistTarget}].Target.Name.Equal[${Target.Name}]} && ${Group.Member[${AssistTarget}].Target.Distance} < ${This.AssistRange} && ${Group.Member[${AssistTarget}].Target.LineOfSight} && ${This.Random} < 3
	{
		/*		Close enough to the AssistTarget, stopping		*/
		Navigator:ClearPath
		move -stop
		return
	}
	elseif ${Group.Member[${AssistTarget}](exists)} && ${Group.Member[${AssistTarget}].Name.Equal[${Target.Name}]} && ${Group.Member[${AssistTarget}].Distance} < ${This.FollowDistance} && ${Group.Member[${AssistTarget}].LineOfSight} && ${This.Random} < 3
	{
		/*		Close enough to the AssistTarget, stopping		*/
		Navigator:ClearPath
		move -stop
		return
	}
	elseif ${Group.Member[${AssistTarget}](exists)} && ${Group.Member[${AssistTarget}].Name.Equal[${Target.Name}]} && (${Group.Member[${AssistTarget}].Distance} >= ${This.FollowDistance} || !${Group.Member[${AssistTarget}].LineOfSight})
	{
		/*		Need to move closer to the AssistTarget		*/
		Navigator:MoveToLoc[${Group.Member[${AssistTarget}].X},${Group.Member[${AssistTarget}].Y},${Group.Member[${AssistTarget}].Z}]
	}
	if ${Group.Member[${AssistTarget}].Target(exists)}
	{
		if ${Group.Member[${AssistTarget}].Target.ReactionLevel} <= 4 && !${Group.Member[${AssistTarget}].Target.Dead} && ${Group.Member[${AssistTarget}].Target.LineOfSight} && (${Group.Member[${AssistTarget}].Target.Target.Name.Equal[${Group.Member[${AssistTarget}].Name}]} || (${Target.TappedByMe} || (!${Target.Tapped} && ${Target.InCombat}))
		{
			/*		Targetting AssistTarget's Target		*/
			target ${Group.Member[${AssistTarget}].Target.GUID}
			return
		}
		elseif ${Group.Member[${AssistTarget}].Target.ReactionLevel} > 4
		{
			/*		Targetting AssistTarget		*/
			target ${Group.Member[${AssistTarget}].GUID}
			return
		}
	}
	else
	{
		/*		Targetting AssistTarget		*/
		target ${Group.Member[${AssistTarget}]}
		return
	}
}

/*
=====================================================================
CureAll
---------------------------------------------------------------------
Checks all party members for up to 3 different kinds of debuffs.
To implement in your routine you need to add the following variables:

		variable string CureSpellType = "" 
This is the type of debuff you are dispelling, eg "Poison"

		variable string CureSpell = ""
This is the name of the spell you use to cure, eg "Abolish Poison"

		variable string CureSpellType2 = "" 

		variable string CureSpell2 = ""

		variable string CureSpellType3 = "" 

		variable string CureSpell3 = ""

=====================================================================
*/
method CureAll()
{
	if ${WoWScript[GetShapeshiftForm()]} != 0
	{
		return
	}
	for (i:Set[0]; ${i}<=${Group.Members}; i:Inc)
	{
		if ${Party.Exists[${i}]} && ${Party.Distance[${i}]} < 40 && ${Party.HP[${i}]} > 10
		{
			for (j:Set[0]; ${j} <= 10; j:Inc)
			{
				if ${Group.Member[${i}].Buff[${j}].Harmful}
				{
					if ${Group.Member[${i}].Buff[${j}].DispelType.Equal[${Class.CureSpellType}]}
					{
						This:Output["${Group.Member[${i}].Name} ${Class.CureSpellType} Debuff"]
						if !${Group.Member[${i}].Buff[${Class.CureSpell}](exists)} && ${Spell[${Class.CureSpell}](exists)}
		      			{
			      			target ${Group.Member[${i}].GUID}
							Toon:CastSpell[${Class.CureSpell}]
							return
		      			}
					}
					if ${Group.Member[${i}].Buff[${j}].DispelType.Equal[${Class.CureSpell2Type}]}
					{
						This:Output["${Group.Member[${i}].Name} ${Class.CureSpell2Type} Debuff"]
						if !${Group.Member[${i}].Buff[${Class.CureSpell2}](exists)} && ${Spell[${Class.CureSpell2}](exists)}
		      			{
			      			target ${Group.Member[${i}].GUID}
							Toon:CastSpell[${Class.CureSpell2}]
							return
		      			}
					}
					if ${Group.Member[${i}].Buff[${j}].DispelType.Equal[${Class.CureSpell3Type}]}
					{
						This:Output["${Group.Member[${i}].Name} ${Class.CureSpell3Type} Debuff"]
						if !${Group.Member[${i}].Buff[${Class.CureSpell3}](exists)} && ${Spell[${Class.CureSpell3}](exists)}
		      			{
			      			target ${Group.Member[${i}].GUID}
							Toon:CastSpell[${Class.CureSpell3}]
							return
		      			}
					}
				}
			}
		}
	}
}
/*
=====================================================================
Party Cast
---------------------------------------------------------------------
Cast a spell on a party member if they fulfill certain requirements.
Requirements are:
Mana - Only cast on members with less than this % mana
HP - Only cast on members with less than this % health
CastRange - Only cast on members within this range
IsCasting - Only cast on members who are casting 
			(or have recently finished casting)
Overwrite - Cast even if they already have ${SpellName} as a buff?
=====================================================================
*/

method PartyCast(int Mana, int HP, int CastRange, string SpellName, bool IsCasting, bool Overwrite)
{
	if !${Spell[${SpellName}](exists)}
	{
		/*		Spell Dosen't exist		*/
		return
	}
	for (i:Set[0]; ${i}<=${Group.Members}; i:Inc)
	{
		if ${Party.Exists[${i}]} && ${Party.Distance[${i}]} < ${CastRange} && (${Mana} == 0 || ${Group.Member[${i}].PctMana} < ${Mana}) && (${HP} == 0 || ${Party.HP[${i}]} < ${HP}) && (${Overwrite} || !${Group.Member[${i}].Buff[${SpellName}](exists)}) && (!${IsCasting} || (${Group.Member[${i}].Name.NotEqual[${Me.Name}]} && ${Group.Member[${i}].Casting(exists)}) || (${Group.Member[${i}].Name.Equal[${Me.Name}]} && ${Toon.Casting}))
		{
			/*		Found a party member who fits all the requirements, casting		*/
			This:Output["Casting ${SpellName} on ${Group.Member[${i}].Name}"]
			target ${Group.Member[${i}]}
			Toon:CastSpell[${SpellName}]
			return
		}
	}
}


/*
=====================================================================
PULSE BASED WEIGHTING
---------------------------------------------------------------------

=====================================================================
*/
	/* ---- Member functions needed in Routines to support option
	   ---- Only those things which your class can perform need to be added

	Class.CanHeal[guid]
	Class.CanCure[guid]
	Class.CanBuff[guid]
	Class.CanRez[guid]
	Class.CanCrowdControl[guid]  -- hostile units

	---- Member functions needed in Routines to support option
	Class:PartyHealPulse
	Class:PartyRezPulse
	Class:PartyBuffPulse
	Class:PartyCurePulse
	*/

	/* containers for quickly checking class categories */
	variable set Squishy
	variable set Tanks
	variable set Healers

	/* we can determine what to do from these values */

	variable string KillTarget = NULL
	variable string CrowdControl = NULL
	variable int HealUnit = 99
	variable int BuffUnit = 99
	variable int CureUnit = 99
	variable int RezUnit = 99
	variable int MembersInRange = 0

	/* for setting priority between heals */
	variable int LightlyWounded = 60
	variable int BadlyWounded = 40

	/* for quickly determining if guid is in group */
	variable set myGroupGUIDs
	
	method Initialize()
	{
		This.Healers:Add[Priest]
		This.Healers:Add[Shaman]
		This.Healers:Add[Druid]
		This.Healers:Add[Paladin]
		This.Tanks:Add[Warrior]
		This.Tanks:Add[Druid]
		This.Tanks:Add[Paladin]
		This.Squishy:Add[Priest]
		This.Squishy:Add[Mage]
		This.Squishy:Add[Warlock]
	}

	/* ${Party.KillTarget} will return GUID for Assist target */
	member NeedAssist()
	{
		if ${KillTarget.NotEqual[NULL]}
		{
			return TRUE
		}
		return FALSE
	}

	/* ${Party.CrowdControl} will return GUID for CC target */
	member NeedCrowdControl()
	{
		if ${CrowdControl.NotEqual[NULL]}
		{
			return TRUE
		}
		return FALSE
	}

	member NeedHeal()
	{
		if ${HealUnit} != 99
		{
			return TRUE
		}
		return FALSE
	}

	member NeedBuff()
	{
		if ${HealUnit} != 99
		{
			return TRUE
		}
		return FALSE
	}

	member NeedCure()
	{
		if ${HealUnit} != 99
		{
			return TRUE
		}
		return FALSE
	}

	member NeedRez()
	{
		if ${HealUnit} != 99
		{
			return TRUE
		}
		return FALSE
	}

	member NeedRest()
	{
		variable int unitNum = 1
		variable bool needed = FALSE
		if ${Class.NeedRest}
		{
			return TRUE
		}
		do
		{
			if ${This.GetRest[${unitNum}]} && ${This.InRange[${unitNum},${This.AssistRange}]}
			{
				needed:Set[TRUE]
			}
		}
		while ${unitNum:Inc} <= ${Group.Members} 
		return ${needed}
	}	
	
	/* only update every so often while out of combat */
	method Pulse()
	{
		if !${Me.InCombat} && !${Me.Dead} && !${Me.Ghost}
		{
		This:Update
		}
	}

	/* place in oState and update frequently when in combat */
	method Update()
	{
		variable int i = 1
		variable int assistNum = 0
		variable float actionWeight = -1
		variable float mostWeight = -1
		
		/* clear all */
		KillTarget:Set[NULL]
		CrowdControl:Set[NULL]
		HealUnit:Set[99]
		BuffUnit:Set[99]
		CureUnit:Set[99]
		RezUnit:Set[99]
		PartyNearby:Set[0]
		
		/* first we find out who has the heaviest weight */ 
		do
		{
			if !${Group.Member[${i}]}
			{	
				MembersInRange:Inc				
				This:UpdateGroupGUID[${i}]
				actionWeight:Set[${This.WeightUnit}]
				if ${actionWeight} > ${lastWeight}
				{
					mostWeight:Set[${actionWeight}]
					assistNum:Set[${i}]
				}
			}
		}
		while ${i:Inc} <= ${Group.Members}
		This:DeriveAction[${mostWeight},${assistNum}]
	}
	
	/* this is where we determine our relationship to unitNum and action */
	method WeightUnit(int unitNum)
	{
		variable int mob = 0
		variable int healmodifier = 0
		if !${Group.Member[${unitNum}](exists)}
		{
			return -1
		}
		
		if !${Group.Member[${unitNum}].Dead}
		{
			/* first check healing */
			if ${This.CanHeal} && !${This.CanHeal[${unitNum},FALSE]}
			{
				if ${Group.Member[${unitNum}].PctHPs} <= ${BadlyWounded} && ${Group.Member[${unitNum}].InCombat}
				{
					if ${This.IsSquishy[${unitNum}]}
					{
						healmodifier:Inc[1]
					}
					healmodifier:Inc[3]
				}
				elseif ${Group.Member[${unitNum}].PctHPs} <= ${LightlyWounded} && ${Group.Member[${unitNum}].InCombat}
				{
					healmodifier:Inc[2]
				}
				elseif !${Me.InCombat} && ${Group.Member[${unitNum}].PctHPs} <= ${LightlyWounded}
				{
					healmodifier:Inc[1]
				}
				if ${healmodifier} > 0
				{
					return ${Math.Calc[10000+((100-${Group.Member[${unitNum}].PctHPs})*${healmodifier})]}
				}
			}
			/* now check for cancer */
			if ${Class.CanCure[${Group.Member[${unitNum}].GUID}]}
			{
				return ${Math.Calc[9000+${unitNum}]}
			}
			/* now we check combat */
			mob:Set[${This.HasAggro[${unitNum}]}]
			if ${mob} > 0 && ${Object[${Targeting.TargetCollection.Get[${mob}]}].Distance} < ${AssistDistance}
			{
				if ${This.CanTank} && ${This.IsSquishy[${unitNum}]}
				{
					/* if our squishy friend is getting squished */
					return ${Math.Calc[8000+${mob}]} 
				}
				if ${This.CanTank} && !${This.CanTank[${unitNum}]}
				{
					/* if we can tank, we like to get aggro */
					return ${Math.Calc[7000+${mob}]} 
				}
				if !${This.CanTank[${unitNum}]} && ${Class.CanCrowdControl[${Targeting.TargetCollection.Get[${mob}]}]}
				{
					if ${This.IsSquishy[${unitNum}]}
					{
						return ${Math.Calc[6500+${mob}]} 
					}
					return ${Math.Calc[6000+${mob}]}
				}
				if ${This.CanTank[${unitNum}]} && ${Object[${Targeting.TargetCollection.Get[${mob}]}].Distance} < 5
				{
					/* we like to target mobs already getting tanked */
					if !${This.CanTank}
					{	
						return ${Math.Calc[5500+${mob}]}
					}
					elseif ${This.CanTank} && !${Me.Target(exists)} 
					{
						return ${Math.Calc[5000+${mob}]} 
					}
				}
			}
			if ${Group.Member[${unitNum}].InCombat}
			{
				if ${This.GetTarget.NotEqual[NULL]}
				{
					if ${This.IsPartyLeader[${unitNum}]}
					{
						/* we our default target to party leader target */
						return ${Math.Calc[4500+${unitNum}]}
					}
					elseif ${This.CanTank[${unitNum}]}
					{
						/* we kill what our tank is targetting */
						return ${Math.Calc[4000+${unitNum}]}
					}
					elseif !${Me.InCombat}
					{
						/* we assist a party member in combat */
						return ${Math.Calc[3500+${unitNum}]}					
					}
				} 
			}
			if ${Me.InCombat}
			{
				/* otherwise, we just kill our own best target */
				return ${Math.Calc[3000+1]}					
			}
			if ${Class.CanBuff[${Group.Member[${unitNum}].GUID}]}
			{
				return ${Math.Calc[2000+${unitNum}]}
			}
			if ${This.GetTarget.NotEqual[NULL]}
			{
				if ${This.IsPartyLeader[${unitNum}]}
				{
					/* we our default target to party leader target */
					return ${Math.Calc[1500+${unitNum}]}
				}
				elseif ${This.CanTank[${unitNum}]}
				{
					/* we kill what our tank is targetting */
					return ${Math.Calc[1000+${unitNum}]}
				}
			} 
		}
		elseif !${Me.InCombat} && ${Class.CanRez[${Group.Member[${unitNum}].GUID}]}
		{
			return 0
		}
		return -1
	}

	/* the weight tells us the action to be performed */
	method DeriveAction(int mostWeight, int assistNum)
	{
		variable int mob = 0
		/* next we use weight to determine action */
		if ${mostWeight} < 0
		{
			RezUnit:Set[${assistNum}]
		}
		elseif ${mostWeight} > 10000
		{
			HealUnit:Set[${assistNum}]
			return
		}
		elseif ${mostWeight} > 9000
		{
			CureUnit:Set[${assistNum}]
			return		
		}
		elseif ${mostWeight} > 8000
		{
			CureUnit:Set[${assistNum}]
			return		
		}
		elseif ${mostWeight} > 7000
		{
			mob:Set[${Math.Calc[${mostWeight}-7000]}]
			KillTarget:Set[${Targeting.TargetCollection.Get[${mob}]}]
			return		
		}
		elseif ${mostWeight} > 6500
		{
			mob:Set[${Math.Calc[${mostWeight}-6500]}]
			CrowdControl:Set[${Targeting.TargetCollection.Get[${mob}]}]
			return		
		}
		elseif ${mostWeight} > 6000
		{
			mob:Set[${Math.Calc[${mostWeight}-6000]}]
			CrowdControl:Set[${Targeting.TargetCollection.Get[${mob}]}]
			return		
		}
		elseif ${mostWeight} > 5500
		{
			mob:Set[${Math.Calc[${mostWeight}-5500]}]
			KillTarget:Set[${Targeting.TargetCollection.Get[${mob}]}]
			return		
		}
		elseif ${mostWeight} > 5000
		{
			mob:Set[${Math.Calc[${mostWeight}-5000]}]
			KillTarget:Set[${Targeting.TargetCollection.Get[${mob}]}]
			return		
		}
		elseif ${mostWeight} > 3500
		{
			/* covers 3500, 4000, and 4500 -- since these are derived the same way */
			KillTarget:Set[${This.GetTarget[${assistNum}]}]		
		}
		elseif ${mostWeight} > 3000
		{
			/* my target */
			mob:Set[${Math.Calc[${mostWeight}-3000]}]
			KillTarget:Set[${Targeting.TargetCollection.Get[${mob}]}]
			return		
		}
		elseif ${mostWeight} == 2500
		{
			RezUnit:Set[${assistNum}]
			return	
		}
		elseif ${mostWeight} > 2000
		{
			BuffUnit:Set[${assistNum}]
			return		
		}
		elseif ${mostWeight} > 1000
		{
			/* covers 1000, 1500 -- since these are derived the same way */
			KillTarget:Set[${This.GetTarget[${assistNum}]}]		
		}
	}

	/* will return true if Pet or Player is in your party */
	member IsPartyMember(string GUID)
	{
		return ${myGroupGUIDs.Contains[${GUID}]}
	}
	
	member IsPartyLeader(int unitNum=0)
	{
		if ${Int[${WoWScript[GetPartyLeaderIndex()]}]} == ${unitNum}
		{
			return TRUE
		} 
		return FALSE
	}

	member GetTarget(int unitNum=0)
	{
		if ${Group.Member[${unitNum}].Target(exists)} && ${Toon.ValidTarget[${Group.Member[${unitNum}].Target.GUID}]}
		{
			return ${Group.Member[${unitNum}].Target.GUID}
		}
		return NULL
	}

	/* iterates through collection and finds what is targetting them */
	member HasAggro(int unitNum)
	{
		variable int i = 1
		if ${Targeting.TargetCollection.Get[${i}](exists)}
		{
			do
			{
				if ${Object[${Targeting.TargetCollection.Get[${i}]}].Target.GUID.Equal[${Group.Member[${unitNum}].GUID}]} && !${This.CrowdControlled[${Targeting.TargetCollection.Get[${i}]}]}
				{
				return ${i}
				}	
			}
			while ${Targeting.TargetCollection.Get[${i:Inc}](exists)}
		}
		return 0
	}

	member CrowdControlled(string GUID)
	{
		/* need to add all the CC effects */
		if ${Object[${GUID}].Buff[Polymorph](exists)}
		{
			return TRUE
		}	
		return FALSE
	}

	/* Heal Test - Checks if I can Heal or Unit can Heal itself */
	member CanHeal(int unitNum=0, bool useClassTest=TRUE)
	{
		if ${useClassTest}
		{
			if ${Class.CanHeal[${Group.Member[${unitNum}].GUID}]}
			{
				return TRUE
			}
			return FALSE
		}
		if ${This.Healers.Contains[${Group.Member[${unitNum}].Class}]} 
		{
			if !${Group.Member[${unitNum}].Class.Equal[Druid]} || ${unitNum} == 0
			{
				return TRUE
			}
			elseif ${Group.Member[${unitNum}].MaxRage} == 0 && ${Group.Member[${unitNum}].MaxEnergy} == 0
			{
				return TRUE
			}
		}
		return FALSE
	}

	/* Tank Test - Checks if unit is Warrior, Paladin or Bear Druid */
	member CanTank(int unitNum=0)
	{
		if ${This.Tanks.Contains[${Group.Member[${unitNum}].Class}]}
		{
			if !${Group.Member[${unitNum}].Class.Equal[Druid]}
			{
				return TRUE
			}
			elseif ${Group.Member[${unitNum}].MaxRage} > 0
			{
				return TRUE
			}
		}
		return FALSE
	}

	/* Squish Test - Checks if unit is Warlock, Priest or Mage */
	member IsSquishy(int unitNum=0)
	{
		if ${This.Squishy.Contains[${Group.Member[${unitNum}].Class}]}
		{
			return TRUE
		}
		return FALSE
	}

	member UnitName(int unitNum)
	{
		variable string unitName = ${Group.Member[${unitNum}].Name}
		if ${unitName.Equal[NULL]}
		{
			unitName:Set[${WoWScript[UnitName("party${unitNum}"),1]}]
		}
		return ${unitName}
	}

	member IsPartyMode()
	{
		if ${UIElement[chkPartyMode@Overview@Pages@Cerebrum].Checked}
		{
			return TRUE
		}
		return FALSE
	}	

	/* used for pulse weighting */
	member AssistDistance()
	{
		return ${Config.GetSlider[sldAssistRange]}
	}

	member InRange(int unitNum, float yards)
	{
		if ${Math.Distance[${Me.Location},${This.GetLocation[${unitNum}]}]} < ${yards}
		{
			return TRUE
		}
		return FALSE
	}	

	member Alone()
	{
		if ${MembersInRange} > 0
		{
			return FALSE
		}
		return TRUE
	}
	
	member Alive(int unitNum)
	{
		variable string unitName = ${This.UnitName[${unitNum}]}
		if ${This.Uplink.PartyInfo[${unitName}](exists)} && ${unitName.NotEqual[NULL]}
		{
			return ${This.Uplink.PartyInfo[${unitName}].Alive} 
		}
		return FALSE	
	}

	member IgnoreLoot(string GUID)
	{
		variable string POITYPE
		variable int i = 1
		if ${Group.Members} > 0
		{
			do
			{
				POITYPE:Set[${This.GetPOITYPE[${i}]}]
				if ${POI.GetMetaType.Element[${POITYPE}].Equal[LOOT]} && ${Party.Exists[${i}]}
				{
					if (${POITYPE.Equal[SKINNING]} || ${POITYPE.Equal[LOOT]})
					{
						if ${Group.Member[${i}].Target.GUID[${GUID}]}
						{
							return TRUE
						}
					}
					elseif ${POITYPE.Equal[MINING]} || ${POITYPE.Equal[HERBALISM]} || ${POITYPE.Equal[QUESTOBJECT]}
					{
						if ${Math.Distance[${Group.Member[${i}].Location},${Object[${GUID}].Location}]} < 5.5
						{
							return TRUE
						}
					}
				}
			}
			while ${i:Inc} <= ${Group.Members}
		}
		return TRUE		
	}
	
	member GetPOITYPE(int unitNum)
	{
		variable string unitName = ${This.UnitName[${unitNum}]}
		unitName:Set[${WoWScript[UnitName("party${unitNum}"),1]}]
		if ${This.Uplink.PartyInfo[${unitName}](exists)} && ${unitName.NotEqual[NULL]}
		{
			return ${This.Uplink.PartyInfo[${unitName}].POI} 
		}
		return 0
	}

	method NeedTarget()
	{
		if ${Party.KillTarget.Equal[NULL]} || ${Party.Alone} 
		{
			Toon:NeedTarget	
			return
		}
		Target ${Party.KillTarget}	
	}
	
	/* simply keeps a set current with active GUIDs for your group -- used for oToon instead of a loop */
	method UpdateGroupGUID(int unitNum)
	{
		if !${myGroupGUIDs.Contains[${Group.Member[${unitNum}].GUID}]}
		{
			myGroupGUIDs:Add[${Group.Member[${unitNum}].GUID}]
		}
		if ${myGroupGUIDs.Contains[${Group.Member[${unitNum}].Pet}](exists)}
		{
			if !${myGroupGUIDs.Contains[${Group.Member[${unitNum}].Pet.GUID}]}
			{
				myGroupGUIDs:Add[${Group.Member[${unitNum}].Pet.GUID}]
			}			
		}
	}	
/*
=====================================================================
PARTY NAVIGATION AND POI SETTING
---------------------------------------------------------------------

=====================================================================
*/
	variable oUplink Uplink

	/* sets a POI to a given party member */
	member SetPOI_ToUnit(int unitNum)
	{
		variable string unitName = ${This.UnitName[${unitNum}]}
		if ${This.GetX[${unitNum}]} == 0 && ${This.GetY[${unitNum}]} == 0 && ${This.GetZ[${unitNum}]} == 0
		{
			return FALSE
		}			
		This:Debug["Setting POI to ${unitName}"]
		if !${This.SetPOI[${This.GetX[${unitNum}]}:${This.GetY[${unitNum}]}:${This.GetZ[${unitNum}]}:${unitName}:${unitName}:GROUP:${Me.FactionGroup.Upper}:0]}
		{
			if ${Config.GetCheckbox[chkTakeFMToGrind]}
			{
				if ${FlightPlan.FlyToPoint[${This.GetX[${unitNum}]},${This.GetY[${unitNum}]},${This.GetZ[${unitNum}]}]}
				{
					if ${FlightPlan.SetFlightPOI}
					{
						return TRUE
					}
				}
			}
			return FALSE
		}
		return TRUE
	}

	/* sets a POI to a given party member */
	member SetPOI_ToDestination(int unitNum)
	{
		variable string unitName = ${This.UnitName[${unitNum}]}
		if ${This.GetDestinationX[${unitNum}]} == 0 && ${This.GetDestinationY[${unitNum}]} == 0 && ${This.GetDestinationZ[${unitNum}]} == 0
		{
			return FALSE
		}			
		This:Debug["Setting POI to ${unitName}'s Destination"]
		if !${This.SetPOI[${This.GetDestinationX[${unitNum}]}:${This.GetDestinationY[${unitNum}]}:${This.GetDestinationZ[${unitNum}]}:${unitName}:${unitName}:GROUP:${Me.FactionGroup.Upper}:0]}
		{
			if ${Config.GetCheckbox[chkTakeFMToGrind]}
			{
				if ${FlightPlan.FlyToPoint[${This.GetDestinationX[${unitNum}]},${This.GetDestinationY[${unitNum}]},${This.GetDestinationZ[${unitNum}]}]}
				{
					if ${FlightPlan.SetFlightPOI}
					{
						return TRUE
					}
				}
			}
			return FALSE
		}
		return TRUE
	}
	
	member SetPOI(string ostring)
	{
		if ${POI.myobjectstring.Equal[${ostring}]}
		{		
			return TRUE
		}
		if ${POI.AvailablePath[${ostring}]}
		{
			Navigator:ClearPath
			POI.myobjectstring:Set[${ostring}]
			POI.Current:Set[${ostring.Token[4,:]}]
			return TRUE
		}
		return FALSE
	}

	variable string randomXY = "X"	
	variable int lastrandomXY = ${LavishScript.RunningTime}
	
	method NavToUnit(int unitNum, bool offset=TRUE)
	{
		variable int pickrandom = ${Math.Rand[100]}
		variable float X = ${This.GetX[${unitNum}]}
		variable float Y = ${This.GetY[${unitNum}]}
		variable float Z = ${This.GetZ[${unitNum}]}
		if ${offset}
		{		
			if ${Math.Calc[${LavishScript.RunningTime} - ${lastrandomXY}]} > 45000
			{
				randomXY:Set[Y]
				if ${pickrandom} > 50
				{
					randomXY:Set[X]
				}
				lastrandomXY:Set[${LavishScript.RunningTime}]
			}
			${randomXY}:Inc[12]
			if !${Navigator.AvailablePath[${X},${Y},${Z}]}
			{
				${randomXY}:Dec[12]
			}
		}
		if !${Navigator.MovingToPoint[${X},${Y},${Z}]}
		{
		Navigator:MoveToLoc[${X},${Y},${Z}]
		}
	}

	member GetLocation(int unitNum)
	{
		variable string unitName
		if ${Group.Member[${unitNum}].Location(exists)}
		{
			return "${Group.Member[${unitNum}].Location}"
		}
		unitName:Set[${WoWScript[UnitName("party${unitNum}"),1]}]
		if ${This.Uplink.PartyInfo[${unitName}](exists)} && ${unitName.NotEqual[NULL]}
		{
			return "${This.Uplink.PartyInfo[${unitName}].X},${This.Uplink.PartyInfo[${unitName}].Y},${This.Uplink.PartyInfo[${unitName}].Z}"  
		}
		return "0,0,0"
	}
	
	member GetX(int unitNum)
	{
		variable string unitName
		if ${Group.Member[${unitNum}].X(exists)}
		{
			return ${Group.Member[${unitNum}].X}
		}
		unitName:Set[${WoWScript[UnitName("party${unitNum}"),1]}]
		if ${This.Uplink.PartyInfo[${unitName}](exists)} && ${unitName.NotEqual[NULL]}
		{
			return ${This.Uplink.PartyInfo[${unitName}].X} 
		}
		return 0
	}
		
	member GetY(int unitNum)
	{
		variable string unitName
		if ${Group.Member[${unitNum}].Y(exists)}
		{
			return ${Group.Member[${unitNum}].Y}
		}
		unitName:Set[${WoWScript[UnitName("party${unitNum}"),1]}]
		if ${This.Uplink.PartyInfo[${unitName}](exists)} && ${unitName.NotEqual[NULL]}
		{
			return ${This.Uplink.PartyInfo[${unitName}].Y} 
		}
		return 0
	}

	member GetZ(int unitNum)
	{
		variable string unitName
		if ${Group.Member[${unitNum}].Z(exists)}
		{
			return ${Group.Member[${unitNum}].Z}
		}
		unitName:Set[${WoWScript[UnitName("party${unitNum}"),1]}]
		if ${This.Uplink.PartyInfo[${unitName}](exists)} && ${unitName.NotEqual[NULL]}
		{
			return ${This.Uplink.PartyInfo[${unitName}].Z} 
		}
		return 0
	}		
	
	member GetDestinationLocation(int unitNum)
	{
		variable string unitName = ${This.UnitName[${unitNum}]}
		if ${This.Uplink.PartyInfo[${unitName}](exists)} && ${unitName.NotEqual[NULL]}
		{
			return "${This.Uplink.PartyInfo[${unitName}].DestinationX},${This.Uplink.PartyInfo[${unitName}].DestinationY},${This.Uplink.PartyInfo[${unitName}].DestinationZ}"  
		}
		return "0,0,0"
	}
	
	member GetDestinationX(int unitNum)
	{
		variable string unitName = ${This.UnitName[${unitNum}]}
		if ${This.Uplink.PartyInfo[${unitName}](exists)} && ${unitName.NotEqual[NULL]}
		{
			return ${This.Uplink.PartyInfo[${unitName}].DestinationX} 
		}
		return 0
	}
		
	member GetDestinationY(int unitNum)
	{
		variable string unitName = ${This.UnitName[${unitNum}]}
		if ${This.Uplink.PartyInfo[${unitName}](exists)} && ${unitName.NotEqual[NULL]}
		{
			return ${This.Uplink.PartyInfo[${unitName}].DestinationY} 
		}
		return 0
	}

	member GetDestinationZ(int unitNum)
	{
		variable string unitName = ${This.UnitName[${unitNum}]}
		if ${This.Uplink.PartyInfo[${unitName}](exists)} && ${unitName.NotEqual[NULL]}
		{
			return ${This.Uplink.PartyInfo[${unitName}].DestinationZ} 
		}
		return 0
	}
	
	member GetRest(int unitNum)
	{
		variable string unitName = ${This.UnitName[${unitNum}]}
		if ${This.Uplink.PartyInfo[${unitName}](exists)} && ${unitName.NotEqual[NULL]}
		{
			return ${This.Uplink.PartyInfo[${unitName}].Rest} 
		}
		return FALSE	
	}
}

/*
=====================================================================
UPLINK 
---------------------------------------------------------------------

=====================================================================
*/
objectdef oUplink inherits cBase
{	
	variable bool PulseAdded = FALSE
	variable bool Broadcasting = FALSE
	variable collection:oPartyInfo PartyInfo
	
	method PriorityPulse()
	{
		if ${This.Broadcasting}
		{
			if ${Me.Dead} || ${Me.Ghost}
			{
				This:Broadcast[Alive,FALSE]
				This:Broadcast[X,${Me.Corpse.X}]
				This:Broadcast[Y,${Me.Corpse.Y}]
				This:Broadcast[Z,${Me.Corpse.Z}]	
				This:Broadcast[Rest,FALSE]					
			}
			else
			{
				This:Broadcast[Alive,TRUE]
				This:Broadcast[X,${Me.X}]
				This:Broadcast[Y,${Me.Y}]
				This:Broadcast[Z,${Me.Z}]	
				This:Broadcast[Rest,${Class.NeedRest}]						
			}		
		}
	}
	
	method SecondaryPulse()
	{
		if ${This.Broadcasting}
		{
			This:Broadcast[POI,${POI.Type}]				
			This:Broadcast[DestinationX,${POI.X}]	
			This:Broadcast[DestinationY,${POI.Y}]	
			This:Broadcast[DestinationZ,${POI.Z}]				
			This:Broadcast[ID,${Session}]	
		}
	}
	
	method Broadcast(string theVar, string theValue)
	{
		relay all -noredirect Event[OB_BROADCAST]:Execute[${Me.Name},${theVar},${theValue}]
	}

	method SendCommand(int unitNum, string theCmd, string theParams)
	{
		variable string unitName = ${Party.UnitName[${unitNum}]}		
		if !${This.PartyInfo.Element[${unitName}].ID(exists)} && ${unitName.NotEqual[NULL]}
		{		
		relay all -noredirect Event[OB_UPLINK_CMD]:Execute[${Me.Name},${This.PartyInfo.Element[${unitName}].ID},"${theCmd}","${theParams}"]
		}
	}
	
	method Incoming(string FromId, string theVar, string theValue)
	{
		if !${FromId.Equal[${Me.Name}]}
		{
			if !${This.PartyInfo.Element[${FromId}](exists)}
			{
				This.PartyInfo:Set[${FromId}]
			}
			This.PartyInfo.Element[${FromId}]:Process[${theVar},${theValue}]
		}
	}

	method IncomingCMD(string FromId, string ToSession, string theCmd, string theParams)
	{
		if !${FromId.Equal[${Me.Name}]} && ${ToSession.Equal[${Session}]}
		{
			if ${theCmd.Find[:]}
			{
				${theCmd}[${theParams}]
			}
			else
			{
				${theCmd} ${theParams}
			}
		}
	}
	
	method Enable()
	{
		This:Output[PARTY UPLINK -- BROADCASTING]
		LavishScript:RegisterEvent[OB_BROADCAST]
		LavishScript:RegisterEvent[OB_UPLINK_CMD]
		Event[OB_BROADCAST]:AttachAtom[Party.Uplink:Incoming]
		Event[OB_UPLINK_CMD]:AttachAtom[Party.Uplink:IncomingCMD]		
		This.Broadcasting:Set[TRUE]		
		if !${This.PulseAdded}
		{
		Bot:AddPulse["Party.Uplink","PriorityPulse",10,TRUE,TRUE]
		Bot:AddPulse["Party.Uplink","SecondaryPulse",35,TRUE,TRUE]	
		Bot:AddPulse["Party","Pulse",10,TRUE,TRUE,1]				
		This.PulseAdded:Set[TRUE]	
		}
	}
	
	method Disable()
	{
		This:Output[PARTY UPLINK -- DISABLED]		
		This.Broadcasting:Set[FALSE]
		Event[OB_BROADCAST]:DetachAtom[Party.Uplink:Incoming]
		Event[OB_BROADCAST]:DetachAtom[Party.Uplink:CommandRcvd]
		Event[OB_BROADCAST]:Unregister
	}
}

objectdef oPartyInfo inherits cBase
{
	variable float X = 0
	variable float Y = 0
	variable float Z = 0
	variable bool Rest = FALSE	
	variable bool Alive = FALSE
	variable string POI
	variable float DestinationX
	variable float DestinationY
	variable float DestinationZ 
	variable string ID
	
	method Process(string theVar, string theValue)
	{
		This.${theVar}:Set[${theValue}]
	}
}