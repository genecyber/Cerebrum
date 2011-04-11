/* CrazyWarrior for OpenBot v1.14 a warrior routine by Oog */
objectdef cClass inherits cBase
{
	;----------------------
	;--- Variables ---
	;----------------------

	variable int crazyWaitTimer = 0	
	variable int restWaitTimer = 0   
	variable int buffWaitTimer = 0   
	variable int pullbuffWaitTimer = 0   
	variable int combatbuffWaitTimer = 0   
	variable int pullWaitTimer = 0   
	variable int attackWaitTimer = 0
	variable int kiteWaitTimer = 0
	variable int pullTimeOut = 0

	variable string PrimaryStance
	variable int SunderPlate = 3		/* number of sunders to put on high armor targets - not included in GUI */
	variable int SunderCloth = 2		/* number of sunders to put on low armor targets - not included in GUI */

	variable bool kiteCheck = FALSE
	variable bool buffPause = FALSE
	variable string lastAttackTarget
	
	variable string OppositeFaction
	variable bool UpdateForNewSkill = FALSE

	variable string CurrentStance
	variable index:string StanceName
	variable collection:bool UseAbility
	variable int overpowerTimer = 0
	variable int RageForHeroic = 15
	variable int RageForSunder = 20
	variable int RetainRage
	
	variable int PersistentTarget = 0
	variable int LastCharge = 0
					
	;----------------------
	;--- Init and Shutdown ---
	;----------------------

	method Initialize()
	{	
		LavishScript:RegisterEvent[TRAINER_CLOSED]
		Event[TRAINER_CLOSED]:AttachAtom[This:SkillLearned]		
		
		/* set opposite faction */
		if ${Me.FactionGroup.Equal[Alliance]}
		{
			OppositeFaction:Set["Horde"]
		}
		if ${Me.FactionGroup.Equal[Horde]}
		{
			OppositeFaction:Set["Alliance"]
		}
		
		This:SetGUI		
		This:CreateStanceStrings
		This:CreateUIErrorStrings
		This:WarriorConfig
	}
	
	method Shutdown()
	{
		This:SaveGUI
	}	
	
	;------------------
	;--- Flee SetUp ---
	;------------------
	
	variable bool HookFlee = TRUE
	method FleePulse()
	{
		if ${Me.Attacking}
		{
			WoWScript AttackTarget()
			return
		}
		if ${This.UseAbility["Intimidating Shout"]} && !${Spell["Intimidating Shout"].Cooldown} && ${Me.CurrentRage} >= 25
		{
			Toon:CastSpell["Intimidating Shout"]
			return
		}
		if ${Spell["Piercing Howl"](exists)} && !${Spell["Piercing Howl"].Cooldown} && ${Unit[-targetingme, -range 0-5](exists)} && ${Me.CurrentRage} >= 10
		{
			Toon:CastSpell["Piercing Howl"]
			return			
		}
	}

	;------------------
	;--- Rest SetUp ---
	;------------------
	
	member NeedRest()
	{			
		/* If I'm in combat, I don't need rest */
		if ${Me.InCombat} || ${Targeting.realAgg}
		{
			return FALSE
		}
		
		/* If I have rez sickness, I should wait in rest */
		if ${Me.Buff[Resurrection Sickness](exists)} && !${UIElement[chkAssistMode@Overview@Pages@openbot].Checked}
		{
			return TRUE
		}	
		
		/* skip rest to loot */
		if ${This.SkipToLoot}
		{
			return FALSE
		}
		
		/* The red warrior is about to die! */
		if ${Me.PctHPs} < ${Config.GetSlider[sldRestHP]}
		{
			return TRUE
		}	
		
		/* I'm eating, stay stitting */
		if ${Me.PctHPs} < ${Config.GetSlider[sldStandHP]} && ${Me.Sitting}
		{
			return TRUE
		}
					
		/* I'm doing something in rest, so lets not jinx it */
		if ${This.restWaitTimer}>0
		{
			return TRUE
		}
		return FALSE
	}
	
	method RestPulse()
	{

		if ${Movement.Speed}
		{
			Toon:Stop
		}
		
		if (${This.restWaitTimer} < ${LavishScript.RunningTime})&&(${This.crazyWaitTimer} < ${LavishScript.RunningTime})
		{
			This:ClearWaitTimers
			This.pullTimeOut:Set[0]
			
			/* casting, return */
			if ${Me.Casting}&&!${WoWScript[SpellIsTargeting()]}
			{
				This:Output["Casting..."]
				This.restWaitTimer:Set[${This.InMilliseconds[25]}]
				return
			}
			
			/* bandage if you got em */
			if ${Me.PctHPs}<${Config.GetSlider[sldHealthForBandage]} && ${Toon.canBandage}
			{
				Toon:Bandage
				return
			}
			
			/* cannibalize */
			if ${Config.GetCheckBox[chkRacial]}&&${Me.Race.Equal["Undead"]}
			{
				if ${Me.PctHPs} < ${Config.GetSlider[sldStandHP]} && ${This.UseAbility[Cannibalize]} && !${Spell[Cannibalize].Cooldown} && (${Object[-dead,-humanoid,-range 0-5](exists)} || ${Object[-dead,-undead,-range 0-5](exists)})
				{
					Toon:CastSpell["Cannibalize"]
					This:Output["Cannibalize"]
					This.restWaitTimer:Set[${This.InSeconds[7]}]				
					return
				}
			}
			
			/* eat */
			if ${Consumable.HasFood} && ${Me.PctHPs} < ${Config.GetSlider[sldRestHP]} && !${Me.Buff[Food](exists)}
			{
				Consumable:useFood
				return
			}
			
			/* stupid rez sickness */
			if ${Me.Buff[Resurrection Sickness](exists)} 
			{
				Toon:Sitdown
				if ${This.shouldShadowmeld}
				{
					Toon:CastSpell["Shadowmeld"]
					Bot.RandomPause:Set[24]						
				}
				return
			}
			
			/* stand up when we are done eating */
			if ${Me.PctHPs} >= ${Config.GetSlider[sldStandHP]} && ${Me.Sitting}
			{
				Toon:Standup
				return
			}
			
			/* shadowmeld food. mmm */
			if (${Me.Buff[Food](exists)}||(!${Consumable.HasFood}&&${Me.Sitting}))&&${This.shouldShadowmeld}
			{
				Toon:CastSpell["Shadowmeld"]
				This:Output["Shadowmeld Rest."]
				Bot.RandomPause:Set[24]					
				return
			}			
			
			if !${Consumable.HasFood} && ${Me.PctHPs} < ${Config.GetSlider[sldStandHP]}
			{
				Toon:Sitdown
				return				
			}		
		}
	}
	
	
	;------------------
	;--- Buff SetUp ---
	;------------------
	
	member NeedBuff()
	{
		if ${Me.Casting}
		{
			return FALSE
		}
			
		if ${Toon.canUseScroll}
		{
			return TRUE
		}			
		return FALSE
	}
	
	method BuffPulse()
	{
		if ${Movement.Speed}
		{
			Toon:Stop
			return
		}
				
		if (${This.buffWaitTimer} < ${LavishScript.RunningTime})&&(${This.crazyWaitTimer} < ${LavishScript.RunningTime})
		{
			This:ClearWaitTimers
			This.pullTimeOut:Set[0]
	
			/* lets pause for 1 second before buffing - basically a lag wait so that we dont do something prematurely*/
			if !${This.buffPause}&&!${WoWScript[SpellIsTargeting()]}
			{
				This.buffWaitTimer:Set[${This.InMilliseconds[100]}]
				This.buffPause:Set[TRUE]
				return
			}
			/* ok- we buffed. lets clear the pause check */ 
			This.buffPause:Set[FALSE]
			Toon:Standup
			
			if ${Toon.canUseScroll}
			{
				Toon:UseScroll
				return
			}
		}
	}
	
	member shouldShadowmeld()
	{
		if ${Me.Race.Equal["Night Elf"]}
		{
			if !${Me.Buff[Shadowmeld](exists)}&&${This.UseAbility[Shadowmeld]}
			{
				if !${Spell[Shadowmeld].Cooldown}
				{
				return TRUE
				}
			}
		}
		return FALSE
	}
	
	
	;------------------
	;--- Pull Buff SetUp ---
	;------------------
	
	member NeedPullBuff()
	{
		/* here is a good place to update our skills */
		if ${This.UpdateForNewSkill}
		{
			This.UpdateForNewSkill:Set[FALSE]	
			This:WarriorConfig
		}	
		return FALSE
	}

	method PullBuffPulse()
	{
		if (${This.pullbuffWaitTimer} < ${LavishScript.RunningTime})&&(${This.crazyWaitTimer} < ${LavishScript.RunningTime})
		{
			This:ClearWaitTimers
			This:BuffPulse
		}
	}
	

	;------------------------
	;--- CombatBuff SetUp	---
	;------------------------
	
	member NeedCombatBuff()
	{
		variable int BuffSlot = 1
		variable int RampageSlot = 0		
		if !${Me.Buff["Battle Shout"](exists)} && ${This.UseAbility["Battle Shout"]} && ${Me.CurrentRage} >= 10
		{
			return TRUE
		}
		if ${This.UseAbility["Rampage"]}
		{
			if ${Me.Buff["Rampage Enabler"](exists)} && ${Me.CurrentRage} >= 20
			{
				do
				{
					if ${Me.Buff[${BuffSlot}].Name.Find["Rampage"]} && !${Me.Buff[${BuffSlot}].Name.Find["Rampage Enabler"]}
					{
						RampageSlot:Set[${BuffSlot}]
					}
				}
				while ${Me.Buff[${BuffSlot:Inc}](exists)}
				
				if ${RampageSlot} == 0
				{
					return TRUE
				}
				/* if we got 5 stacked, lets keep it going*/
				if ${Me.Buff[${RampageSlot}].Application} == 5 
				{
					/* check the time remaining */
					if ${Me.Buff[${RampageSlot}].Duration} <= 10
					{
						return TRUE
					}
				}
			}
		}
		if !${Me.Buff["Commanding Shout"](exists)} && ${This.UseAbility["Commanding Shout"]} && ${Me.CurrentRage} >= 10
		{
			return TRUE
		}
		if ${Me.PctHPs} < 10
		{
			if ${This.UseAbility["Last Stand"]} && !${Spell["Last Stand"].Cooldown}
			{
				return TRUE
			}
		}
		if ${This.UseAbility["Bloodrage"]} && !${Spell["Bloodrage"].Cooldown} && ${Me.CurrentRage} < 10 && ${Me.PctHPs} > ${Config.GetSlider[sldHealthForBloodRage]} && ${Target.PctHPs} > 70 && ${Me.InCombat}
		{
			return TRUE
		}
		if ${This.UseAbility["Deathwish"]} && !${Spell["Deathwish"].Cooldown} && ${Me.CurrentRage} >= 10 && ${Me.PctHPs} > ${Config.GetSlider[sldHealthForDeathwish]} && ${Target.PctHPs} > 70 && ${Me.InCombat}
		{
			return TRUE
		}
		if ${Me.PctHPs} > 80 && (${Me.Buff[Feared](exists)} || ${Me.Buff[Incapacitate](exists)}) && ${This.CurrentStance.Equal[Berserker Stance]} && ${This.UseAbility[Berserker Rage]} && !${Spell[Berserker Rage].Cooldown} & ${Me.InCombat}
		{
			return TRUE	
		}
		return FALSE
	}

	method CombatBuffPulse()
	{
		variable int BuffSlot = 1
		variable int RampageSlot = 0
		
		/* FaceXYZ target*/
		Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
		
		if (${This.combatbuffWaitTimer} < ${LavishScript.RunningTime})&&(${This.crazyWaitTimer} < ${LavishScript.RunningTime})
		{
			This:ClearWaitTimers
			if !${Me.Buff["Battle Shout"](exists)} && ${This.UseAbility["Battle Shout"]} && ${Me.CurrentRage} >= 10
			{
				Toon:CastSpell["Battle Shout"]
				Bot.RandomPause:Set[14]				
				return
			}
			if ${This.UseAbility["Rampage"]}
			{
				if ${Me.Buff["Rampage Enabler"](exists)} && ${Me.CurrentRage} >= 20
				{
					do
					{
						if ${Me.Buff[${BuffSlot}].Name.Find["Rampage"]} && !${Me.Buff[${BuffSlot}].Name.Find["Rampage Enabler"]}
						{
							RampageSlot:Set[${BuffSlot}]
						}
					}
					while ${Me.Buff[${BuffSlot:Inc}](exists)}
					
					if ${RampageSlot} == 0
					{
						Toon:CastSpell["Rampage"]
						Bot.RandomPause:Set[14]									
						return
					}
					/* if we got 5 stacked, lets keep it going*/
					if ${Me.Buff[${RampageSlot}].Application} == 5 
					{
						/* check the time remaining */
						if ${Me.Buff[${RampageSlot}].Duration} <= 10
						{
							Toon:CastSpell["Rampage"]
							Bot.RandomPause:Set[14]										
							return
						}
					}
				}
			}	
			if !${Me.Buff["Commanding Shout"](exists)} && ${This.UseAbility["Commanding Shout"]} && ${Me.CurrentRage} >= 10
			{
				Toon:CastSpell["Commanding Shout"]
				Bot.RandomPause:Set[14]							
				return
			}
			if ${Me.PctHPs} < 10
			{
				if ${This.UseAbility["Last Stand"]} && !${Spell["Last Stand"].Cooldown}
				{
					Toon:CastSpell["Last Stand"]
					Bot.RandomPause:Set[14]				
					return
				}
			}			
			if ${This.UseAbility["Bloodrage"]} && !${Spell["Bloodrage"].Cooldown} && ${Me.CurrentRage} < 10 && ${Me.PctHPs} > ${Config.GetSlider[sldHealthForBloodRage]} && ${Target.PctHPs} > 70 && ${Me.InCombat}
			{
				Toon:CastSpell["Bloodrage"]
				Bot.RandomPause:Set[14]							
				return
			}
			if ${This.UseAbility["Deathwish"]} && !${Spell["Deathwish"].Cooldown} && ${Me.CurrentRage} >= 10 && ${Me.PctHPs} > ${Config.GetSlider[sldHealthForDeathwish]} && ${Target.PctHPs} > 70 && ${Me.InCombat}
			{
				Toon:CastSpell["Deathwish"]
				Bot.RandomPause:Set[14]							
				return
			}
			if (${Me.PctHPs} > || ${Me.Buff[Feared](exists)} || ${Me.Buff[Incapacitate](exists)}) && ${This.CurrentStance.Equal[Berserker Stance]} && ${This.UseAbility[Berserker Rage]} && !${Spell[Berserker Rage].Cooldown} & ${Me.InCombat}
			{
				Toon:CastSpell["Berserker Rage"]
				Bot.RandomPause:Set[14]							
				return
			}					
		}
	}
	
	
	;------------------
	;--- Pull SetUp ---
	;------------------
	
	method PullPulse()
	{	
		/* lets make sure we are standing */
		Toon:Standup

		/* update stance */
		This:UpdateStanceForm
				
		if !${Toon.ValidTarget[${Target.GUID}]}
		{
			Toon:Stop
			This:Output["I need a target"]
			Toon:NeedTarget[1]			
			This.pullTimeOut:Set[0]			
			return
		}	

		if !${Toon.TargetIsBestTarget} && !${UIElement[chkAssistMode@Overview@Pages@openbot].Checked}
		{
			Toon:Stop
			Toon:BestTarget
			This.pullTimeOut:Set[0]
			return
		}		

		/* target is elite, fuck that */
		if ${Target.Classification.Equal[Elite]}
		{ 
			Toon:Stop
			This:Output["Target is elite. Blacklisting."]
			GlobalBlacklist:Insert[${Target.GUID},3600000]
			WoWScript ClearTarget()
			This.pullTimeOut:Set[0]
			return 
		} 
				
		/* stop moving if no reason to move */
		if ${Toon.withinMelee[TRUE]}
		{
			Toon:AutoAttack		
		}
			
		if (${This.pullWaitTimer} < ${LavishScript.RunningTime})&&(${This.crazyWaitTimer} < ${LavishScript.RunningTime})&&!${Me.InCombat}
		{
			This:ClearWaitTimers
			
			/* set the pull timeout - pull should not take more than 8 seconds*/
			if ${This.pullTimeOut}==0
			{
				This.pullTimeOut:Set[${This.InMilliseconds[${Config.GetSlider[sldPullBailOutTimer]}]}]
				return
			}
						
			if ${This.MeleePull}
			{
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
				/* make sure we are in battlestance for charge - no line of sight of max distance check */
				if ${This.UseAbility[Charge]}&&!${Spell[Charge].Cooldown}&&!${Me.InCombat}&&${Math.Calc[${Target.Distance}+${Target.BoundingRadius}]}>8
				{
					/* make sure we are in battlestance */
					if !${This.CurrentStance.Equal[Battle Stance]}
					{
						/* we are not in battlestance, switch stances*/
						Toon:Stop
						This:switchStance[Battle Stance]
						This.pullWaitTimer:Set[${This.InMilliseconds[125]}]
						return
					}
				}
				/* charge open if I can */
				if ${This.UseAbility[Charge]} &&  !${Spell[Charge].Cooldown} && !${Me.InCombat} && ${Target.LineOfSight}
				{
					if ${Target.Distance} < 25 && ${Target.Distance} > 10 
					{
						/* if battle stance is not our primary stance, lets make sure we end up in our primary after charging */
						if !${This.CurrentStance.Equal[${This.PrimaryStance}]} && ${Me.CurrentRage} <= ${This.RetainRage}
						{
							/* charge!! and shift to primary stance */
							This.LastCharge:Set[${LavishScript.RunningTime}]
							Toon:CastSpell["Charge"]
							WoWScript SpellStopCasting()
							This:switchStance[${This.PrimaryStance}]
							Toon:Stop
							This.crazyWaitTimer:Set[${This.InTenths[7]}]							
							return
						}
						/* charge!! */
						This.LastCharge:Set[${LavishScript.RunningTime}]
						Toon:CastSpell["Charge"]
						/* if a stance switch is not needed (primary is battle) then bloodrage while charging */
						if ${This.UseAbility[Bloodrage]}&&!${Spell[Bloodrage].Cooldown}
						{
							WoWScript SpellStopCasting()
							Toon:CastSpell["Bloodrage"]
						}
						Toon:Stop	
						This.crazyWaitTimer:Set[${This.InTenths[7]}]							
						return
					}
					/* backup for charge */
					if ${Target.Distance} < 10 && ${Target.Distance} > 6.5
					{
						Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
						Navigator:MoveBackward[500]
						return
					}
				}
				
				/* move into melee range */
				if !${Toon.withinMelee[TRUE]}
				{
				     Toon:ToMelee
				     return
				}
			}		
			
			/* check pull timeout for range*/
			if (${Math.Calc[${This.pullTimeOut}+50000]} < ${LavishScript.RunningTime}&&(${Target.MaxMana}<=0||!${Target.MaxMana(exists)}))||((${This.pullTimeOut} < ${LavishScript.RunningTime})&&(${This.detectMobAdd}||${Config.GetCheckBox[chkShootToPull]}||!${Toon.haveAmmo}))
			{
				This:Output["Pull Timer Exceeded."]
				This.pullTimeOut:Set[0]
				GlobalBlacklist:Insert[${Target.GUID},3600000]
				WoWScript ClearTarget()
				Toon:Stop
				return
			}
					
			if !${Toon.haveAmmo}
			{
				This:Output["ERROR: Range Pull Failed"]
				if !${Toon.withinMelee[TRUE]}
				{
				     Toon:ToMelee
				}				
				return
			}					
			
			if !${Toon.withinRanged[TRUE]}
			{
				Toon:ToRanged
			}
			else
			{
				/* pull with ranged attack open */	
				if ${Toon.canShoot}
				{
					Toon:Shoot
					/* wait for target to come to us */
					This.crazyWaitTimer:Set[${This.InMilliseconds[${Math.Calc[(${Me.Equip[18].Delay}*100)+(10*${Target.Distance})]}]}]
					return
				}
				else
				{
					/* our range check failed and exceeded timer*/
					if ${This.pullTimeOut} < ${LavishScript.RunningTime}
					{
						This:Output["Pull Timer Exceeded. Range pull attempt failed."]
						This.pullTimeOut:Set[0]
						GlobalBlacklist:Insert[${Target.GUID},3600000]
						WoWScript ClearTarget()
						Toon:Stop
						return
					}
				}
			}
		}
	}
	
	member MeleePull()
	{
		if ${This.pullTimeOut} < ${LavishScript.RunningTime}
		{
			return FALSE
		}
		if (${Target.CreatureType.Equal["Humanoid"]} || ${Target.CreatureType.Equal["Demon"]}) && ${Target.MaxMana} > 0
		{
			return TRUE
		}
		if !${Toon.haveAmmo}
		{
			return TRUE
		}
		if ${This.detectMobAdd} || ${Config.GetCheckBox[chkShootToPull]}
		{
			return FALSE
		}
		if (${Target.Distance} < ${Toon.PullRange} || ${Target.Distance} < 40) && !${Me.IsPathObstructed[${Target.X},${Target.Y},${Target.Z}]}
		{
			return TRUE
		}
		if ${Navigator.AvailablePath[${Me.X},${Me.Y},${Me.Z},${Target.X},${Target.Y},${Target.Z}]}
		{
			return TRUE
		}
		return FALSE
	}
	
	;--------------------
	;--- Combat SetUp ---
	;--------------------
	
	method AttackPulse()
	{
		variable string MyWarriorAttack
		variable guidlist NextClosestAggro
		variable string PotionName
		
		/* lets make sure we are standing and attacking*/
		Toon:Standup
		Toon:AutoAttack	
		
		/* update stance */
		This:UpdateStanceForm

		if !${Toon.ValidTarget[${Target.GUID}]}
		{
			Toon:Stop
			This:Output["I need a target"]
			Toon:NeedTarget[1]			
			return
		}	
	
		/* trust in target collection to keep our target the best target */
		if !${Toon.TargetIsBestTarget} && ${Object[${Toon.BestTarget}](exists)} && ${Toon.BestTarget.NotEqual[NULL]}
		{
			if ( ${Object[${Toon.BestTarget}].Distance} < ${Toon.MinRanged} || ${Object[${Toon.BestTarget}].PctHPs} > 20 ) && ${Math.Calc[${LavishScript.RunningTime}-${This.PersistentTarget}]} > 5000
			{
				Toon:BestTarget
				return
			}
		}
		
		/* stop moving if no reason to move */
		if ${Movement.Speed} && ${Toon.withinMelee} && (${Target.PctHPs} > 20 || !${Toon.isFacingAway[90]}) 
		{	
			Toon:Stop
		}

		/* make sure we are facing target */
		Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]	
		
		/* make sure we arent casting */
		if ${Me.Casting}
		{
			return
		}
			
		if (${This.attackWaitTimer} < ${LavishScript.RunningTime})&&(${This.crazyWaitTimer} < ${LavishScript.RunningTime})
		{
			/* pre-attack stuff */
			This:ClearWaitTimers
			This.pullTimeOut:Set[0]
					
			/* reset stuff if I have attacked a new target */
			if !${Target.GUID.Equal[${This.lastAttackTarget}]}
			{
				This.PersistentTarget:Set[${LavishScript.RunningTime}]
				This.kiteCheck:Set[FALSE]
				This.kiteWaitTimer:Set[0]
				This.lastAttackTarget:Set[${Target.GUID}]
				/* if no exessive rage loss, switch to primary stance on new targets */
				if !${This.CurrentStance.Equal[${This.PrimaryStance}]} && ${Me.CurrentRage} <= ${This.RetainRage}
				{
					This:switchStance[${This.PrimaryStance}]
					return
				}				
			}		
			/* hamstring or howl */
			if ${Me.CurrentRage} >= 10 && ${Target.PctHPs} < 25 
			{
				/* determine if mob needs debuff */
				if (${Target.CreatureType.Equal[Humanoid]} || ${Toon.isFacingAway[90]}) && !${Target.Buff["Hamstring"](exists)} && !${Target.Buff["Piercing Howl"](exists)}
				{
					/* hamstring */
					if !${This.CurrentStance.Equal[Defensive Stance]}&&${This.UseAbility["Hamstring"]}&&!${Spell[Hamstring].Cooldown} && ${Target.Distance} <= 4
					{
						This:Output["In Melee: Hamstring ${Target.Name}"]
						Toon:CastSpell["Hamstring"]	
						return
					}
					/* piercing howl */
					if ${This.UseAbility["Piercing Howl"]}&&!${Spell["Piercing Howl"].Cooldown}&& ${Target.Distance} > 5 && ${Target.Distance} <= 9
					{
						This:Output["Casting: Piercing Howl"]
						Toon:CastSpell["Piercing Howl"]
						return
					}
				}
			}
			
			/* make sure we are in melee range */
			if ${Target.Distance}>${Toon.MaxMelee}
			{		
				/* check to see if I am being kited by another player - pauses 5 seconds before moving after the target*/
				if (${Target.TappedByMe} && !${Target.Target.GUID.Equal[${Me.GUID}]} && ${Target.Target.GUID(exists)}) && !${Target.Buff[Stun](exists)}
				{
					if ${This.kiteCheck}
					{
						/* blacklist mob - they can kill it*/
						This:Output["We are getting kited. Blacklisting ${Target.Name}"]
						GlobalBlacklist:Insert[${Target.GUID},3600000]
						return
					}
					if !${This.kiteCheck}
					{
						This:Output["Getting Kited?"]
						This.attackWaitTimer:Set[${This.InMilliseconds[500]}]
						This.kiteCheck:Set[TRUE]
						return
					}
				}
							
				/* if my target is another player, lets make sure we dont get kited */
				if ${Target.FactionGroup.Equal[${This.OppositeFaction}]} && ${Target.Type.Equal[Player]}
				{
					if ${This.kiteCheck}&&(${This.kiteWaitTimer} < ${LavishScript.RunningTime})
					{
						if ${Toon.canShoot}
						{
							Toon:Shoot
							This.crazyWaitTimer:Set[${This.InMilliseconds[${Math.Calc[(${Me.Equip[18].Delay}*100)+100]}]}]								
							return
						}
						return
					}
					if !${This.kiteCheck}
					{
						This.kiteWaitTimer:Set[${This.InMilliseconds[2000]}]
						This.attackWaitTimer:Set[${This.InMilliseconds[200]}]
						This.kiteCheck:Set[TRUE]
					}
				}
				
				if ${This.UseAbility[Intercept]}&&!${Spell[Intercept].Cooldown}&& ${Target.Distance} < 25 && ${Target.Distance} > ${Toon.MinRanged}
				{
					/* make sure we are in berserker stance */
					if !${This.CurrentStance.Equal[Berserker Stance]} && ${Me.CurrentRage} <= ${This.RetainRage} && ${Me.CurrentRage} >= 10
					{
						/* we are not in battlestance, switch stances*/
						This:switchStance[Berserker Stance]
						Toon:CastSpell["Intercept"]
						return
					}
					if ${This.CurrentStance.Equal[Berserker Stance]}
					{
						Toon:CastSpell["Intercept"]
						return
					}
				}
				
				/* is he fleeing? */
				if ${Target.PctHPs}<20 && ${Target.Distance} > ${Toon.MinRanged}
				{
					if ${Object[${Toon.NextBestTarget}](exists)} && ${Toon.NextBestTarget.NotEqual[NULL]}
					{
						This:Output["Current target is fleeing. Choosing a closer target."]
						Target ${Toon.NextBestTarget}
						This.attackWaitTimer:Set[${This.InMilliseconds[50]}]
						return
					}

					/* target can be range attacked */
					if ${Target.Distance}<${Toon.MaxRanged}&&${Target.LineOfSight}
					{
						if ${Toon.canShoot}
						{
							Toon:Shoot
							This.crazyWaitTimer:Set[${This.InMilliseconds[${Math.Calc[(${Me.Equip[18].Delay}*100)+100]}]}]								
							return
						}
						This:Output["Ranged: Failed - Moving to Target"]
						Navigator:MoveToMob[${Target.GUID}]
						return
					}
				}
				
				/* ok. nothing special happening. lets move into range */
				Navigator:MoveToMob[${Target.GUID}]
				return
			}
			This.kiteCheck:Set[FALSE]
			
			/* backup into range */
			if ${Target.Distance} < ${Toon.MinMelee} 
			{
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
				Navigator:MoveBackward[500]
			}
									
			/* pop an emergency potion if about fucked */
			if ${Item[-inventory,"Healing Potion"](exists)}&&${Me.PctHPs}<${Config.GetSlider[sldHealthForPotion]}
			{
				PotionName:Set[${Item[-inventory,"Healing Potion"].Name}]	
				if ${Item[${PotionName}].Usable}&&!${WoWScript["GetContainerItemCooldown(${Item[${PotionName}].Bag.Number}, ${Item[${PotionName}].Slot})", 2]}
				{
					Item[${PotionName}]:Use
					Bot.RandomPause:Set[24]
					return
				}
			}
			if ${Me.PctHPs} < ${Math.Calc[${Config.GetSlider[sldHealthForPotion]}/1.8]} && ${Target.PctHPs} > 30
			{
				This:Output[Fleeing! No healing pots and our situation looks bad!]
				Toon:Flee
				return
			}
							
			/* determine which attack will be used */	
			MyWarriorAttack:Set[${This.chooseWarriorAttack}]		
			switch ${MyWarriorAttack}
			{
				case NONE
				{
					return
				}
				case trinketone
				{
					This:Output["In Melee: Using ${Me.Equip[13].Name}"]
					Me.Equip[13]:Use
					Bot.RandomPause:Set[24]
					return
				}
				case trinkettwo
				{
					This:Output["In Melee: Using ${Me.Equip[14].Name}"]
					Me.Equip[14]:Use
					Bot.RandomPause:Set[24]
					return
				}
				default
				{
					/* output spam prevention */
					if ${Toon.canCast[${MyWarriorAttack}]}
					{
						This:Output["In Melee: Casting ${MyWarriorAttack}"]
						Toon:CastSpell[${MyWarriorAttack}]
						Bot.RandomPause:Set[24]	
					}
					return
				}
			}
		}

	}
	
	member chooseWarriorAttack()
	{		
		variable string MyWarriorAttack
		variable guidlist Aggros
		variable int MobAdds
		variable int RageReserve = 0
		variable bool TwoHander = FALSE
		
		/* update stance */
		This:UpdateStanceForm
		
		/* determine number of adds */
		Aggros:Search[-units, -nearest, -targetingme, -alive, -range 0-8]
		MobAdds:Set[(${Aggros.Count} - 1)]		
		Aggros:Clear
		
		/* default is to do nothing */
		MyWarriorAttack:Set["NONE"]	
		
		/* most instant attacks are only worthwhile with a two-hander, so lets check */
		if ${Me.Equip[16].EquipType.Equal["Weapon (2H)"]}
		{
			TwoHander:Set[TRUE]
		}
		
		/* casting, return */
		if ${Me.Casting}
		{
			return ${MyWarriorAttack}	
		}
		
		if (${MobAdds} > 3 && ${Me.PctHPs} < 45) || (${MobAdds} > 0 && ${Me.PctHPs} < 25 && ${Target.PctHPs} > 25) 
		{
			This:Output[We are getting our ass kicked by multiple mobs! Flee!!]
			Toon:Flee
			return "Intimidating Shout"	
		}
			
		/* dont you try to cast on me, motherfucker */
		if ${Target.Casting(exists)}&&${Target.MaxMana}>0
		{
			if ${This.UseAbility[Shield Bash]}&&!${Spell[Shield Bash].Cooldown}&&${Me.Action[Shield Bash].Usable}
			{
				MyWarriorAttack:Set["Shield Bash"]
				return ${MyWarriorAttack}	
			}
			if ${This.UseAbility["Concussion Blow"]} && !${Spell["Concussion Blow"].Cooldown}
			{
				MyWarriorAttack:Set["Concussion Blow"]
				return ${MyWarriorAttack}					
			}
			if ${This.UseAbility[Pummel]}&&!${Spell[Pummel].Cooldown}
			{
				if !${This.CurrentStance.Equal[Berserker Stance]} && ${Me.CurrentRage} <= ${This.RetainRage}
				{
					This:switchStance[Berserker Stance]
					MyWarriorAttack:Set["Pummel"]
					return ${MyWarriorAttack}
				}	
				if ${This.CurrentStance.Equal[Berserker Stance]} 
				{
					MyWarriorAttack:Set["Pummel"]
					return ${MyWarriorAttack}
				}
			}
		}

		if ${This.UseAbility["Execute"]} && !${Spell["Execute"].Cooldown} && ${Target.PctHPs} <= 20
		{
			if !${This.CurrentStance.Equal[Defensive Stance]}
			{
				/* cancel slam if we should be executing */
				if ${Me.Action[Slam].Active}
				{
					echo cancel Slam
					This:Output[Cancel Slam: Need to Execute!]
					WoWScript SpellStopCasting()	
				}	
				MyWarriorAttack:Set["Execute"]
				return ${MyWarriorAttack}	
			}
			if ${This.CurrentStance.Equal[Defensive Stance]} && ${Me.CurrentRage} <= ${This.RetainRage}
			{
				if !${This.PrimaryStance.Equal[Defensive Stance]}
				{
					This:switchStance[${This.PrimaryStance}]	
				}
				else
				{
					This:switchStance[Battle Stance]
				}
				MyWarriorAttack:Set["Execute"]
				return ${MyWarriorAttack}				
			}
		}
		
		/* can we overpower? */
		if ${This.UseAbility[Overpower]}&&(${Me.Action[Overpower].Usable} || ${This.shouldOverpower})&&!${Spell[Overpower].Cooldown}&&(${TwoHander} || ${Config.GetCheckBox[chkAlwaysOverpower]} || ${This.CurrentStance.Equal[Battle Stance]})
		{
			if !${This.CurrentStance.Equal[Battle Stance]} && ${Me.CurrentRage} <= ${This.RetainRage}
			{
				This:switchStance[Battle Stance]
				MyWarriorAttack:Set["Overpower"]
				return ${MyWarriorAttack}	
			}
			if ${This.CurrentStance.Equal[Battle Stance]}
			{
				MyWarriorAttack:Set["Overpower"]
				return ${MyWarriorAttack}
			}
		}
		
		/* can we victory rush? */
		if ${This.UseAbility["Victory Rush"]} && !${Spell["Victory Rush"].Cooldown} && ${Me.Action["Victory Rush"].Usable}  
		{
			MyWarriorAttack:Set["Victory Rush"]
			return ${MyWarriorAttack}	
		}

		/* if target is elite, pop reckless and hope for the best */
		if ${Target.Classification.Equal[Elite]}
		{ 
			if ${This.UseAbility["Recklessness"]} && !${Spell["Recklessness"].Cooldown} && ${Me.PctHPs} > 40
			{
				if !${This.CurrentStance.Equal[Berserker Stance]} && ${Me.CurrentRage} <= ${This.RetainRage}
				{
					This:switchStance[Berserker Stance]
					MyWarriorAttack:Set["Recklessness"]
					return ${MyWarriorAttack}
				}
				if ${This.CurrentStance.Equal[Berserker Stance]}
				{
					MyWarriorAttack:Set["Recklessness"]
					return ${MyWarriorAttack}
				}
			}			
		}			
		
		/* use concussion blow if available */
		if ${This.UseAbility["Concussion Blow"]} && !${Spell["Concussion Blow"].Cooldown} && ${Target.MaxMana}==0
		{
			MyWarriorAttack:Set["Concussion Blow"]
			return ${MyWarriorAttack}					
		}
							
		/* disarm? */
		if ${Me.PctHPs} < 35 && ${Target.CreatureType.Equal[Humanoid]} 
		{
			if ${This.UseAbility["Disarm"]} && !${Spell["Disarm"].Cooldown} && ${Target.MaxMana}==0 && ${Target.PctHPs} > 20 
			{
				if !${This.CurrentStance.Equal[Defensive Stance]} && ${Me.CurrentRage} <= ${This.RetainRage}
				{
					This:switchStance[Defensive Stance]
					MyWarriorAttack:Set["Disarm"]
					return ${MyWarriorAttack}	
				}	
				if ${This.CurrentStance.Equal[Defensive Stance]}
				{
					MyWarriorAttack:Set["Disarm"]
					return ${MyWarriorAttack}
				}
			}
		}
					
		/* we got adds within 10 yards, what now? */
		if ${MobAdds}>0
		{		
			/* retaliation if we got two extra */
			if ${MobAdds}>=2
			{
				if ${This.UseAbility["Retaliation"]} && !${Spell["Retaliation"].Cooldown} && ${Me.PctHPs} > 40
				{
					if !${This.CurrentStance.Equal[Battle Stance]} && ${Me.CurrentRage} <= ${This.RetainRage}
					{
						This:switchStance[Battle Stance]
						MyWarriorAttack:Set["Retaliation"]
						return ${MyWarriorAttack}
					}
					if ${This.CurrentStance.Equal[Battle Stance]}
					{
						MyWarriorAttack:Set["Retaliation"]
						return ${MyWarriorAttack}
					}
				}
			}
			
			/* sweeping strikes is always good */
			if ${This.UseAbility["Sweeping Strikes"]} && !${Spell["Sweeping Strikes"].Cooldown} && ${Target.PctHPs} > 20
			{
				if !${This.CurrentStance.Equal[Battle Stance]} && ${Me.CurrentRage} <= ${This.RetainRage}
				{
					This:switchStance[Battle Stance]
					MyWarriorAttack:Set["Sweeping Strikes"]
					return ${MyWarriorAttack}					
				}
				if ${This.CurrentStance.Equal[Battle Stance]}
				{
					MyWarriorAttack:Set["Sweeping Strikes"]
					return ${MyWarriorAttack}
				}
			}	
			
			/* demo shout to keep damage down */
			if ${This.UseAbility["Demoralizing Shout"]} && !${Target.Buff["Demoralizing Shout"](exists)} && ${Me.CurrentRage} >= 10
			{
				MyWarriorAttack:Set["Demoralizing Shout"]
				return ${MyWarriorAttack}
			}
			
			/* lets whirlwind if we got it - doesnt check for 2hander like other*/
			if ${This.UseAbility["Whirlwind"]} &&!${Spell["Whirlwind"].Cooldown}
			{
				if !${This.CurrentStance.Equal[Berserker Stance]} && ${Me.CurrentRage} <= ${This.RetainRage}
				{
					This:switchStance[Berserker Stance]
					MyWarriorAttack:Set["Whirlwind"]
					return ${MyWarriorAttack}
				}				
				if ${This.CurrentStance.Equal[Berserker Stance]}
				{
					MyWarriorAttack:Set["Whirlwind"]
					return ${MyWarriorAttack}
				}
			}
			
			/* fear bomb when it gets bad */
			if !${Me.Buff["Retaliation"](exists)} && !${Me.Buff["Sweeping Strikes"](exists)} && (${Me.PctHPs} < 40 || ${MobAdds} >= 2)
			{
				if ${This.UseAbility["Intimidating Shout"]} && !${Spell["Intimidating Shout"].Cooldown} && ${Me.CurrentRage} >= 25
				{
					MyWarriorAttack:Set["Intimidating Shout"]
					return ${MyWarriorAttack}					
				}	
			}
		
			/* not making an extra effort to switch out of zerker, but clap if we can*/
			if !${This.CurrentStance.Equal[Berserker Stance]}
			{
				if !${Target.Buff[Thunder Clap](exists)} && ${This.UseAbility["Thunder Clap"]} && ${Target.PctHPs} > 40 && ${Me.CurrentRage} >= 20
				{
					MyWarriorAttack:Set["Thunder Clap"]
					return ${MyWarriorAttack}
				}
			}
		}

		/* should we use a trinket? */
		if ${This.UseTrinket[13,${MobAdds}]}
		{
			MyWarriorAttack:Set["trinketone"]
			return ${MyWarriorAttack}				
		}
		if ${This.UseTrinket[14,${MobAdds}]}
		{
			MyWarriorAttack:Set["trinkettwo"]
			return ${MyWarriorAttack}				
		}	

		/* use death wish if we have the health for it and no adds */
		if ${This.UseAbility["Death Wish"]} && !${Spell["Death Wish"].Cooldown} && !${Me.Buff["Enraged"](exists)} && ${Me.CurrentRage}>= 10 && ${MobAdds}==0 && ${Target.PctHPs} > 70 && ${Me.PctHPs} > 80
		{
			MyWarriorAttack:Set["Death Wish"]
			return ${MyWarriorAttack}					
		}
		
		/* Racials  */
		/* lol. removed dranei and tauren when i realized they cant be rogues*/
		if ${Config.GetCheckBox[chkRacial]}
		{
			switch ${Me.Race}
			{
				case Troll
				{
					if ${Me.PctHPs} < 90 && ${Target.PctHPs} > 50 && ${This.UseAbility[Berserking]} && !${Spell[Berserking].Cooldown}
					{
						MyWarriorAttack:Set["Berserking"]
						return ${MyWarriorAttack}	
					}
				}
				case Orc
				{
					if ${Me.PctHPs} > 90 && ${Target.PctHPs} > 50 && ${This.UseAbility[Blood Fury]} && !${Spell[Blood Fury].Cooldown}
					{
						MyWarriorAttack:Set["Blood Fury"]
						return ${MyWarriorAttack}	
					}
				}
				case Undead
				{
					if ${Me.Buff[Feared](exists)} && ${This.UseAbility[Will of the Forsaken]} && !${Spell[Will of the Forsaken].Cooldown}
					{
						MyWarriorAttack:Set["Will of the Forsaken"]
						return ${MyWarriorAttack}	
					}
				}
				case Dwarf
				{
					if (${Me.Buff[Poisoned](exists)} || ${Me.Buff[Diseased](exists)} || ${Me.Buff[Bleeding](exists)})&&${This.UseAbility[Stoneform]}&&!${Spell[Stoneform].Cooldown}
					{
						MyWarriorAttack:Set["Stoneform"]
						return ${MyWarriorAttack}	
					}
				}
				case Gnome
				{
					if (${Me.Buff[Immobilized](exists)} || ${Me.Buff[Slowed](exists)})&&${This.UseAbility[Escape Artist]}&&!${Spell[Escape Artist].Cooldown}
					{
						MyWarriorAttack:Set["Escape Artist"]
						return ${MyWarriorAttack}	
					}
				}
				case Tauren
				{
					if ${This.UseAbility["War Stomp"]} && !${Spell["War Stomp"].Cooldown} && (${Target.Casting(exists)} || ${MobAdds}>0 || ${Target.MaxMana}==0)
					{
						MyWarriorAttack:Set["War Stomp"]
						This.attackWaitTimer:Set[${This.InMilliseconds[50]}]
						return ${MyWarriorAttack}	
					}
				}
				case Draenei
				{
					if ${This.UseAbility["Gift of the Naaru"]} && !${Spell["Gift of the Naaru"].Cooldown} && ${Me.PctHPs} < 35
					{
						MyWarriorAttack:Set["Gift of the Naaru"]
						return ${MyWarriorAttack}	
					} 	
				}
				default
				{
					/* do nothing */
				}
			}
		}

		/* 31 pt talents - use whenever they arent on cooldown */
		if ${This.UseAbility["Bloodthirst"]}
		{
			if !${Spell["Bloodthirst"].Cooldown}
			{
				MyWarriorAttack:Set["Bloodthirst"]
				return ${MyWarriorAttack}
			}
			elseif !${This.CurrentStance.Equal[${This.PrimaryStance}]} && ${Me.CurrentRage} <= ${This.RetainRage}
			{
				/* switch to primary stance if waiting for rage to build and within acceptable rage loss */
				This:switchStance[${This.PrimaryStance}]
			}			
		}
		
		if ${This.UseAbility["Mortal Strike"]}
		{
			if !${Spell["Mortal Strike"].Cooldown}
			{
				MyWarriorAttack:Set["Mortal Strike"]
				return ${MyWarriorAttack}
			}
			elseif !${This.CurrentStance.Equal[${This.PrimaryStance}]} && ${Me.CurrentRage} <= ${This.RetainRage}
			{
				/* switch to primary stance if waiting for rage to build and within acceptable rage loss */
				This:switchStance[${This.PrimaryStance}]
			}			
		}
					
		if ${This.UseAbility["Shield Slam"]}
		{
			if !${Spell["Shield Slam"].Cooldown}
			{
				MyWarriorAttack:Set["Shield Slam"]
				return ${MyWarriorAttack}				
			}
			elseif !${This.CurrentStance.Equal[${This.PrimaryStance}]} && ${Me.CurrentRage} <= ${This.RetainRage}
			{
				/* switch to primary stance if waiting for rage to build and within acceptable rage loss */
				This:switchStance[${This.PrimaryStance}]
			}	
		}

		/* lets whirlwind if we have a two hander */
		if ${This.UseAbility["Whirlwind"]} &&!${Spell["Whirlwind"].Cooldown}&&${TwoHander}
		{
			if !${This.CurrentStance.Equal[Berserker Stance]} && ${Me.CurrentRage} <= ${This.RetainRage}
			{
				This:switchStance[Berserker Stance]
				MyWarriorAttack:Set["Whirlwind"]
				return ${MyWarriorAttack}
			}				
			if ${This.CurrentStance.Equal[Berserker Stance]}
			{
				MyWarriorAttack:Set["Whirlwind"]
				return ${MyWarriorAttack}
			}
		}
		
		/* RAGE DUMPS - Heroic Strike, Rend, Cleave, Sunder Armor, Slam */
		/* determine amount of rage to reserve */ 
		if ${This.UseAbility[Mortal Strike]} || ${This.UseAbility[Bloodthirst]} || (${This.UseAbility["Sweeping Strikes"]} && !${Spell["Sweeping Strikes"].Cooldown} && ${Target.PctHPs} > 40 && ${MobAdds}>0)
		{
			RageReserve:Set[30]
		}
		elseif ${MobAdds}>0 && ((${This.UseAbility["Intimidating Shout"]} && !${Spell["Intimidating Shout"].Cooldown} )||(${This.UseAbility["Whirlwind"]}&&!${Spell["Whirlwind"].Cooldown}))
		{
			RageReserve:Set[25]
		}
		elseif (${This.UseAbility["Execute"]} && ${Target.PctHPs} < 32) || (${This.UseAbility["Shield Slam"]} && !${Spell["Shield Slam"].Cooldown})
		{
			RageReserve:Set[20]
		}
		elseif (${This.UseAbility["Concussion Blow"]} && !${Spell["Concussion Blow"].Cooldown})
		{
			RageReserve:Set[15]
		}
		elseif ${Target.MaxMana}>0&&((${This.UseAbility[Pummel]}&&!${Spell[Pummel].Cooldown})||(${This.UseAbility[Shield Bash]}&&!${Spell[Shield Bash].Cooldown}&&${Me.Action[Shield Bash].Usable}))
		{
			RageReserve:Set[10]
		}
				
		/* if we have imp rend, go ahead and apply a bleed if target over 70 pct and can bleed*/
		if ${This.UseAbility["Rend"]} && ${Me.CurrentRage} >= ${Math.Calc[${RageReserve}+10]} && ${MobAdds}==0 && ${Target.PctHPs} > 70 && !${Target.CreatureType.Equal[Demon]} && !${Target.CreatureType.Equal[Elemental]} && !${Target.CreatureType.Equal[Undead]} && !${Target.CreatureType.Equal[Mechanical]}
		{
			if !${This.CurrentStance.Equal[Berserker Stance]} && !${Target.Buff["Rend"](exists)}
			{
				MyWarriorAttack:Set["Rend"]
				return ${MyWarriorAttack}					
			}
		}
		
		/* lets sunder up our target if he has more than 40 pct health*/
		if ${This.UseAbility["Sunder Armor"]} && ${Me.CurrentRage}>= ${Math.Calc[${RageReserve}+${This.RageForSunder}]} && ${MobAdds}==0 && ${Target.PctHPs} > 40
		{
			/* 3 sunders on high armor targets */
			if ${Target.CreatureType.Equal["Elemental"]}||${Target.CreatureType.Equal["Mechanical"]}||${Target.Class.Equal["Warrior"]}||${Target.Class.Equal["Paladin"]}
			{
				if (!${Target.Buff["Sunder Armor"](exists)} || ${Target.Buff["Sunder Armor"].Application} < ${This.SunderPlate}) 
				{
					MyWarriorAttack:Set["Sunder Armor"]
					return ${MyWarriorAttack}	
				}			
			}
			/* 2 sunders on everything else */
			if (!${Target.Buff["Sunder Armor"](exists)} || ${Target.Buff["Sunder Armor"].Application} < ${This.SunderCloth}) 
			{
				MyWarriorAttack:Set["Sunder Armor"]
				return ${MyWarriorAttack}	
			}	
		}

		/* if we have a two hander, lets use Slam for our rage dump instead of heroic strike */
		if  ${MobAdds}==0 && !${Me.Action[Slam].Active} && ${This.UseAbility[Slam]} && ${Me.CurrentRage} >= ${Math.Calc[${RageReserve}+15]} && ${TwoHander}
		{
			MyWarriorAttack:Set["Slam"]
			This.attackWaitTimer:Set[${This.InMilliseconds[50]}]
			return ${MyWarriorAttack}	
		}
			
		/* lets do one of our NEXT ATTACK abilities */
		if (${MobAdds}>0 && ${This.UseAbility["Cleave"]} && ${Me.CurrentRage} >= ${Math.Calc[${RageReserve}+20]})||((${MobAdds}==0 || !${This.UseAbility["Cleave"]}) && ${Me.CurrentRage} >= ${Math.Calc[${RageReserve}+${This.RageForHeroic}]})
		{
			/* cleave is better than heroic strike when we got adds*/
			if ${MobAdds}>0 && ${This.UseAbility["Cleave"]} && !${Me.Action[Cleave].Active} && !${Me.Buff["Sweeping Strikes"](exists)}
			{
				MyWarriorAttack:Set["Cleave"]
				return ${MyWarriorAttack}
			}
			/* otherwise, heroic strike is our best rage dump */
			if ${This.UseAbility["Heroic Strike"]} && !${Me.Action[Cleave].Active} && !${Me.Action[Heroic Strike].Active}
			{
				MyWarriorAttack:Set["Heroic Strike"]
				return ${MyWarriorAttack}
			}		
		}
		/* cancel attacks i shouldnt be doing */
		if ${Me.Action[Heroic Strike].Active} && ${Me.CurrentRage} < ${Math.Calc[${RageReserve}+${This.RageForHeroic}]}
		{
			echo cancel Heroic Strike
			This:Output[Cancel Heroic Strike: Need to conserve ${RageReserve} rage]
			WoWScript SpellStopCasting()	
		}
		if ${Me.Action[Cleave].Active} && ${Me.CurrentRage} < ${Math.Calc[${RageReserve}+20]}
		{
			echo cancel Cleave
			This:Output[Cancel Cleave: Need to conserve ${RageReserve} rage]
			WoWScript SpellStopCasting()
		}
		return ${MyWarriorAttack}	
	}

	
	;--------------------
	;--- Misc Functions ---
	;--------------------	
		
	/* stance functions */
	method CreateStanceStrings()
	{
		/* setup stance strings */
		This.StanceName:Insert["Battle Stance"]
		This.StanceName:Insert["Defensive Stance"]
		This.StanceName:Insert["Berserker Stance"]	
	}
	
	method UpdateStanceForm()
	{
		variable int stanceNum = ${WoWScript["GetShapeshiftForm(true)", 1]}
		This.CurrentStance:Set[${This.StanceName.Get[${stanceNum}]}]
	}

	method switchStance(string whichStance)
	{
		Cast "${whichStance}"
		WoWScript SpellStopCasting()
	}

	member UseTrinket(int trinket, int adds)
	{
		variable int minAdds
		variable float trinketCooldown 
		variable bool check = FALSE
		variable string trinketGUI = "sldAddsForTrinketOne"
		
		if !${Me.Equip[${trinket}](exists)}
		{
			return FALSE
		}
		
		trinketCooldown:Set[${WoWScript[GetInventoryItemCooldown("player"\, ${trinket})]}]		
		if ${trinketCooldown} != 0
		{
			return FALSE
		}
			
		if ${trinket} == 14
		{
			trinketGUI:Set["sldAddsForTrinketTwo"]
		}		
		minAdds:Set[${Config.GetSlider[${trinketGUI}]}]			
		
		if ${adds} > 0 && ${adds} >= ${minAdds}
		{
			return TRUE
		}
		elseif ${adds} == 1000
		{
			return TRUE
		}
		return FALSE
	}	
	
	/* used to test if should skip rest or buff state to loot */
	member SkipToLoot()
	{
		if !${Config.GetCheckBox[chkSkipToLoot]} || !${UIElement[chkLoot@Config@InvPages@Inventory@Pages@openbot].Checked}
		{
			return FALSE
		}
		if ${Me.PctHPs} < ${Config.GetSlider[sldHealthForBandage]} || ${Me.Sitting} || ${Me.Casting} || ${This.restWaitTimer} > 0
		{
			return FALSE
		}	
		if ${Unit[-dead,-lootable,-range 0-4](exists)}
		{
			return TRUE
		}
		if ${Toon.HasSkill[Skinning]}
		{
			if ${Unit[-dead,-skinnable,-range 0-4](exists)} && ${Item[-inventory,"Skinning Knife"](exists)}
			{
				return TRUE
			}
		}
		if ${LavishScript.RunningTime} <= ${State.LOOTState_Loot_Wait_Until}
		{
			return TRUE
		}		
		return FALSE
	}
	
	/* detect adds before pulling */
	member detectMobAdd()
	{
		if ${Config.GetCheckBox[chkRangePullOnDetectAdds]}
		{
			if ${Toon.DetectAdds[${Target.GUID}, 1, ${Config.GetSlider[sldRangePullOnDetectAddsRadius]}]}
			{
				return TRUE
			}
		}
		return FALSE
	}
		
	method ClearWaitTimers()
	{
		This.crazyWaitTimer:Set[0]
		This.restWaitTimer:Set[0]  
		This.buffWaitTimer:Set[0]
		This.pullbuffWaitTimer:Set[0]   
		This.combatbuffWaitTimer:Set[0]   
		This.pullWaitTimer:Set[0]
		This.attackWaitTimer:Set[0]			
	}
	
	/* used instead of Spell[](exists) - sets everything up based on options and available spells*/
	method WarriorConfig()
	{
		/*stance*/
		This.UseAbility:Set["Battle Stance",${Config.GetCheckBox[chkUseBattleStance]}]
		This.UseAbility:Set["Defensive Stance",${Config.GetCheckBox[chkUseDefensiveStance]}]
		This.UseAbility:Set["Berserker Stance",${Config.GetCheckBox[chkUseBerserkerStance]}]
		
		/* make sure the default stance exists */
		if !${Spell[${Config.GetCombo[cmbPrimaryStance]}](exists)}
		{
			This.PrimaryStance:Set["Battle Stance"]
		}
		else
		{
			This.PrimaryStance:Set[${Config.GetCombo[cmbPrimaryStance]}]			
		}
		This.UseAbility:Set[${This.PrimaryStance},TRUE]	

		/* racials */
		This.UseAbility:Set["Gift of the Naaru",TRUE]
		This.UseAbility:Set["Stoneform",TRUE]
		This.UseAbility:Set["Blood Fury",TRUE]
		This.UseAbility:Set["Escape Artist",TRUE]
		This.UseAbility:Set["War Stomp",TRUE]
		This.UseAbility:Set["Berserking",TRUE]
		This.UseAbility:Set["Shadowmeld",TRUE]
		This.UseAbility:Set["Will of the Forsaken",TRUE]
		This.UseAbility:Set["Cannibalize",TRUE]
		
		/* all else */
		if ${Config.GetCheckBox[chkBattleShout]} || ${Me.Level} < 68
		{
			This.UseAbility:Set["Battle Shout",TRUE]
			This.UseAbility:Set["Commanding Shout",FALSE]				
		}
		else
		{
			This.UseAbility:Set["Battle Shout",FALSE]
			This.UseAbility:Set["Commanding Shout",TRUE]		
		}
		This.UseAbility:Set["Berserker Rage",${Config.GetCheckBox[chkUseBerserkerRage]}]
		This.UseAbility:Set["Bloodrage",${Config.GetCheckBox[chkUseBloodRage]}]
		This.UseAbility:Set["Cleave",${Config.GetCheckBox[chkUseCleave]}]
		This.UseAbility:Set["Heroic Strike",TRUE]
		This.UseAbility:Set["Victory Rush",${Config.GetCheckBox[chkUseVictoryRush]}]
		This.UseAbility:Set["Execute",TRUE]
		This.UseAbility:Set["Sunder Armor",${Config.GetCheckBox[chkUseSunder]}]
		This.UseAbility:Set["Thunder Clap",${Config.GetCheckBox[chkUseThunderClap]}]
		This.UseAbility:Set["Demoralizing Shout",${Config.GetCheckBox[chkUseDemoShout]}]
		This.UseAbility:Set["Hamstring",TRUE]
		This.UseAbility:Set["Intimidating Shout",${Config.GetCheckBox[chkUseIntimidatingShout]}]
		This.UseAbility:Set["Rend",${Config.GetCheckBox[chkUseRend]}]
		This.UseAbility:Set["Concussion Blow",TRUE]		
		This.UseAbility:Set["Spell Reflection",TRUE]
		This.UseAbility:Set["Revenge",TRUE]
		This.UseAbility:Set["Shield Bash",TRUE]
		This.UseAbility:Set["Shield Block",TRUE]
		This.UseAbility:Set["Shield Slam",TRUE]
		This.UseAbility:Set["Devastate",TRUE]
		This.UseAbility:Set["Disarm",${Config.GetCheckBox[chkUseDisarm]}]
		This.UseAbility:Set["Bloodthirst",TRUE]
		This.UseAbility:Set["Death Wish",${Config.GetCheckBox[chkUseDeathwish]}]
		This.UseAbility:Set["Pummel",TRUE]
		This.UseAbility:Set["Rampage",TRUE]
		This.UseAbility:Set["Sweeping Strikes",TRUE]
		This.UseAbility:Set["Mortal Strike",TRUE]
		This.UseAbility:Set["Overpower",TRUE]
		This.UseAbility:Set["Whirlwind",TRUE]
		This.UseAbility:Set["Slam",${Config.GetCheckBox[chkUseSlam]}]
		This.UseAbility:Set["Recklessness",${Config.GetCheckBox[chkUseRecklessness]}]
		This.UseAbility:Set["Shield Wall",TRUE]
		This.UseAbility:Set["Retaliation",TRUE]
		This.UseAbility:Set["Intercept",${Config.GetCheckBox[chkUseIntercept]}]
		This.UseAbility:Set["Charge",TRUE]

		/* turn off battle stance if not enabled */
		if !${This.UseAbility["Battle Stance"]}
		{
			This.UseAbility:Set["Overpower",FALSE]
			This.UseAbility:Set["Retaliation",FALSE]
			This.UseAbility:Set["Sweeping Strikes",FALSE]			
		}
		
		/* turn off defensive stance if not enabled (also any battle if not enabled) */
		if !${This.UseAbility["Defensive Stance"]}
		{
			This.UseAbility:Set["Revenge",FALSE]
			This.UseAbility:Set["Shield Block",FALSE]
			This.UseAbility:Set["Disarm",FALSE]
			This.UseAbility:Set["Shield Wall",FALSE]
				
			if !${This.UseAbility["Battle Stance"]}
			{
				This.UseAbility:Set["Shield Bash",FALSE]
				This.UseAbility:Set["Thunder Clap",FALSE]
				This.UseAbility:Set["Rend",FALSE]
				This.UseAbility:Set["Spell Reflection",FALSE]
			}
		}

		/* turn off berserker stance if not enabled (also any battle if not enabled) */
		if !${This.UseAbility["Berserker Stance"]}
		{
			This.UseAbility:Set["Intercept",FALSE]
			This.UseAbility:Set["Berserker Rage",FALSE]
			This.UseAbility:Set["Whirlwind",FALSE]
			This.UseAbility:Set["Pummel",FALSE]
			This.UseAbility:Set["Recklessness",FALSE]
				
			if !${This.UseAbility["Battle Stance"]}
			{
				This.UseAbility:Set["Hamstring",FALSE]
				This.UseAbility:Set["Execute",FALSE]
				This.UseAbility:Set["Victory Rush",FALSE]			
			}
		}
		
		/* make sure ability exists */
		if ${This.UseAbility.FirstKey(exists)}
		{
			do
			{
				if !${Spell[${This.UseAbility.CurrentKey}](exists)}
				{
					This.UseAbility:Set[${This.UseAbility.CurrentKey},FALSE]	
				}
			}
			while ${This.UseAbility.NextKey(exists)}	
		}
		
		/* set a rage limit to stance dancing */
		This.RetainRage:Set[${Config.GetSlider[sldMaxRageLoss]}]
		if ${Spell["Stance Mastery"](exists)}
		{
			This.RetainRage:Inc[10]
		}
		This.RetainRage:Inc[${Math.Calc[${Me.Talent["Tactical Mastery"]} * 5 ]}]	
		
		/* set rage requirements for heroic and sunder */
		This.RageForHeroic:Set[${Math.Calc[15-${TalentTree.PointsInTalent["Improved Heroic Strike"]}]}]
		This.RageForSunder:Set[${Math.Calc[15-${TalentTree.PointsInTalent["Improved Sunder Armor"]}]}]	
	}

	;----------------------
	;--- Event Hooking ---
	;----------------------

	variable collection:string UIErrorMsgStrings
	method CreateUIErrorStrings()
	{
		This.UIErrorMsgStrings:Set["You are facing the wrong way!","backward"]
		This.UIErrorMsgStrings:Set["Target needs to be in front of you","backward"]
		This.UIErrorMsgStrings:Set["Target too close","backward"]
		This.UIErrorMsgStrings:Set["You are too far away!","forward"]
	}

	variable bool needUIHook = TRUE
	method UIErrorMessage(string Id, string Msg)
	{
		if ${Bot.PauseFlag} || ${This.crazyWaitTimer} > ${LavishScript.RunningTime} || ${Math.Calc[${LavishScript.RunningTime}-${This.LastCharge}]} < 5000
		{
			return
		}
		if ${This.UIErrorMsgStrings.Element[${Msg}](exists)}
		{
			if ${Msg.Equal["Target too close"]} || (${Target.Distance} < 5 && ${Me.InCombat}) || ${This.UIErrorMsgStrings.Element[${Msg}].Equal["forward"]}
			{
				echo ${Msg}
				This:Output["Moving ${This.UIErrorMsgStrings.Element[${Msg}]} - UI Error: ${Msg}"]
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
				This.attackWaitTimer:Set[${This.InMilliseconds[25]}]
				This.pullWaitTimer:Set[${This.InMilliseconds[25]}]
				move ${This.UIErrorMsgStrings.Element[${Msg}]} 800
				return				
			}
		}
	}	
	
	variable bool needCombatHook = TRUE	
	method CombatEvent(string unitID, string unitAction, string isCrit, string amtDamage, string damageType)
	{
		if ${unitID.Equal["target"]} && ${unitAction.Equal["dodge"]}		
		{
			This.overpowerTimer:Set[${This.InMilliseconds[500]}]
		}
	}

	member shouldOverpower()
	{
		if ${This.overpowerTimer} > ${LavishScript.RunningTime}
		{
			return TRUE
		}
		return FALSE
	}
	
	method SkillLearned()
	{
		/* if i am not in combat, it is most likely a new ability */
		if !${Me.InCombat}
		{
			This.UpdateForNewSkill:Set[TRUE]
		}
	}
	
	;--------------------
	;--- WARRIOR GUI ---
	;--------------------

	/* on gui change, updates WarriorConfig */
	method ClassGUIChange(string Action)
	{
		This:WarriorConfig
	}
	
	method SetGUI()
	{
		variable string uniqueToon = "${Me.Name}:${Me.Class}:${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}"
		Config:SetCheckBox[${uniqueToon},"chkSkipToLoot","chkSkipToLoot@Core@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkShootToPull","chkShootToPull@Core@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkAlwaysOverpower","chkAlwaysOverpower@Core@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseBloodRage","chkUseBloodRage@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseBerserkerRage","chkUseBerserkerRage@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseDeathwish","chkUseDeathwish@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseRecklessness","chkUseRecklessness@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseIntercept","chkUseIntercept@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseVictoryRush","chkUseVictoryRush@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseDisarm","chkUseDisarm@Ability@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkUseSlam","chkUseSlam@Ability@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkUseSunder","chkUseSunder@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkRangePullOnDetectAdds","chkRangePullOnDetectAdds@Aggro@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseRend","chkUseRend@Ability@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkRacial","chkRacial@Misc@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseBerserkerStance","chkUseBerserkerStance@Misc@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseBattleStance","chkUseBattleStance@Misc@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseDefensiveStance","chkUseDefensiveStance@Misc@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseThunderClap","chkUseThunderClap@Aggro@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseIntimidatingShout","chkUseIntimidatingShout@Aggro@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkUseCleave","chkUseCleave@Aggro@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseDemoShout","chkUseDemoShout@Aggro@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkBattleShout","chkBattleShout@Core@Pages@ClassGUI",TRUE]		
		Config:SetCheckBox[${uniqueToon},"chkCommandingShout","chkCommandingShout@Core@Pages@ClassGUI",FALSE]
		Config:SetCombo[${uniqueToon},"cmbPrimaryStance","cmbPrimaryStance@Misc@Pages@ClassGUI"]
		Config:SetSlider[${uniqueToon},"sldRestHP","sldRestHP@Core@Pages@ClassGUI",60]
		Config:SetSlider[${uniqueToon},"sldStandHP","sldStandHP@Core@Pages@ClassGUI",100]
		Config:SetSlider[${uniqueToon},"sldHealthForDeathwish","sldHealthForDeathwish@Ability@Pages@ClassGUI",70]
		Config:SetSlider[${uniqueToon},"sldAddsForTrinketOne","sldAddsForTrinketOne@Aggro@Pages@ClassGUI",0]
		Config:SetSlider[${uniqueToon},"sldAddsForTrinketTwo","sldAddsForTrinketTwo@Aggro@Pages@ClassGUI",0]
		Config:SetSlider[${uniqueToon},"sldMaxRageLoss","sldMaxRageLoss@Misc@Pages@ClassGUI",10]
		Config:SetSlider[${uniqueToon},"sldHealthForBandage","sldHealthForBandage@Misc@Pages@ClassGUI",35]
		Config:SetSlider[${uniqueToon},"sldHealthForPotion","sldHealthForPotion@Misc@Pages@ClassGUI",20]
		Config:SetSlider[${uniqueToon},"sldRangePullOnDetectAddsRadius","sldRangePullOnDetectAddsRadius@Aggro@Pages@ClassGUI",20]
		Config:SetSlider[${uniqueToon},"sldHealthForBloodRage","sldHealthForBloodRage@Ability@Pages@ClassGUI",70]
		Config:SetSlider[${uniqueToon},"sldPullBailOutTimer","sldPullBailOutTimer@Misc@Pages@ClassGUI",2200]
	}
	
	method SaveGUI()
	{
		variable string uniqueToon = "${Me.Name}:${Me.Class}:${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}"
		Config:SaveCheckBox[${uniqueToon},"chkSkipToLoot"]
		Config:SaveCheckBox[${uniqueToon},"chkShootToPull"]
		Config:SaveCheckBox[${uniqueToon},"chkAlwaysOverpower"]
		Config:SaveCheckBox[${uniqueToon},"chkUseBloodRage"]
		Config:SaveCheckBox[${uniqueToon},"chkUseBerserkerRage"]
		Config:SaveCheckBox[${uniqueToon},"chkUseDeathwish"]
		Config:SaveCheckBox[${uniqueToon},"chkUseRecklessness"]
		Config:SaveCheckBox[${uniqueToon},"chkUseIntercept"]
		Config:SaveCheckBox[${uniqueToon},"chkUseVictoryRush"]
		Config:SaveCheckBox[${uniqueToon},"chkUseDisarm"]
		Config:SaveCheckBox[${uniqueToon},"chkUseSlam"]
		Config:SaveCheckBox[${uniqueToon},"chkUseSunder"]
		Config:SaveCheckBox[${uniqueToon},"chkRangePullOnDetectAdds"]
		Config:SaveCheckBox[${uniqueToon},"chkUseRend"]
		Config:SaveCheckBox[${uniqueToon},"chkRacial"]
		Config:SaveCheckBox[${uniqueToon},"chkUseBerserkerStance"]
		Config:SaveCheckBox[${uniqueToon},"chkUseBattleStance"]
		Config:SaveCheckBox[${uniqueToon},"chkUseDefensiveStance"]
		Config:SaveCheckBox[${uniqueToon},"chkUseThunderClap"]
		Config:SaveCheckBox[${uniqueToon},"chkUseIntimidatingShout"]
		Config:SaveCheckBox[${uniqueToon},"chkUseCleave"]
		Config:SaveCheckBox[${uniqueToon},"chkUseDemoShout"]
		Config:SaveCheckBox[${uniqueToon},"chkBattleShout"]
		Config:SaveCheckBox[${uniqueToon},"chkCommandingShout"]		
		Config:SaveCombo[${uniqueToon},"cmbPrimaryStance"]
		Config:SaveSlider[${uniqueToon},"sldRestHP"]
		Config:SaveSlider[${uniqueToon},"sldStandHP"]
		Config:SaveSlider[${uniqueToon},"sldHealthForDeathwish"]
		Config:SaveSlider[${uniqueToon},"sldAddsForTrinketOne"]
		Config:SaveSlider[${uniqueToon},"sldAddsForTrinketTwo"]
		Config:SaveSlider[${uniqueToon},"sldMaxRageLoss"]
		Config:SaveSlider[${uniqueToon},"sldHealthForBandage"]
		Config:SaveSlider[${uniqueToon},"sldHealthForPotion"]
		Config:SaveSlider[${uniqueToon},"sldRangePullOnDetectAddsRadius"]
		Config:SaveSlider[${uniqueToon},"sldHealthForBloodRage"]
		Config:SaveSlider[${uniqueToon},"sldPullBailOutTimer"]
	}	
}