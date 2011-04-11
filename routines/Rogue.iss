/* CrazyRogue for OpenBot v1.24 rogue routine by Oog */
objectdef cClass inherits cBase
{		
	;----------------------
	;--- Variables ---
	;----------------------
	
	variable int crazyWaitTimer = 0
	variable int restWaitTimer = 0   
	variable int lootWaitTimer = 0
	variable int buffWaitTimer = 0   
	variable int pullbuffWaitTimer = 0   
	variable int combatbuffWaitTimer = 0   
	variable int pullWaitTimer = 0   
	variable int attackWaitTimer = 0
	variable int kiteWaitTimer = 0
	variable int pullTimeOut = 0
	variable bool kiteCheck = FALSE
	variable bool startMoveBehind = FALSE
	variable bool backattackPause = FALSE
	variable int backattackWaitTimer = 0
	variable bool checkPockets = TRUE
	variable bool checkDistract = TRUE
	variable bool buffPause = FALSE
	variable string lastAttackTarget
	variable string OppositeFaction
	variable point3f backstabLoc
	variable bool moveBehind = FALSE
	variable int PersistentTarget = 0
	variable oLockpick Lockpick
	
	;----------------------
	;--- Init and Shutdown ---
	;----------------------
	
	method Initialize()
	{
		if ${Me.FactionGroup.Equal[Alliance]}
		{
			OppositeFaction:Set["Horde"]
		}
		if ${Me.FactionGroup.Equal[Horde]}
		{
			OppositeFaction:Set["Alliance"]
		}
		This.Lockpick:PickingStrings
		This:CreateUIErrorStrings		
		This:SetGUI
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
		if ${Flee.Avoiding} && !${Mount.IsMounted}
		{
			if ${Me.InCombat} && ${Toon.canCast[Vanish]}
			{
				Toon:CastSpell[Vanish]
				return
			}
			if ${This.shouldStealth}
			{
				Toon:CastSpell[Stealth]
				return
			}
		}
		if ${Toon.canBuff[${Me.GUID},Sprint]}
		{
			Toon:CastSpell[Sprint]
			This:Output[SPRINT!!  We need to Flee!!]
			return
		}
		if ${Me.Attacking}
		{
			WoWScript AttackTarget()
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
		
		if ${This.lootWaitTimer} > ${LavishScript.RunningTime}
		{
			return FALSE
		}	
		
		if ${Config.GetCheckBox[chkPatrolInStealth]}&&${This.shouldStealth}&&${Me.PctHPs}>${Config.GetSlider[sldRestHP]}&&!${Me.Sitting}
		{		
			if ${POI.Type.Equal[HOTSPOT]} && !${Mount.NeedMount}&& !${Mount.IsMounted} 
			{
				return TRUE
			}
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
		
		if (${This.restWaitTimer} < ${LavishScript.RunningTime})&&(${This.lootWaitTimer} < ${LavishScript.RunningTime})&&(${This.crazyWaitTimer} < ${LavishScript.RunningTime})
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
			if ${Me.PctHPs}<${Config.GetSlider[sldHealthForBandage]} && ${Toon.canBandage} && !${Me.Sitting}
			{
				Toon:Bandage
				return
			}
			
			/* cannibalize */
			if ${Config.GetCheckBox[chkRacial]}&&${Me.Race.Equal["Undead"]} && !${Me.Sitting}
			{
				if ${Me.PctHPs} < ${Config.GetSlider[sldStandHP]} && ${Toon.canCast[Cannibalize]} && (${Object[-dead,-humanoid,-range 0-5](exists)} || ${Object[-dead,-undead,-range 0-5](exists)})
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
				if ${This.shouldStealth}
				{
					Toon:CastSpell["Stealth"]
				}
				return
			}
			
			/* stand up when we are done eating */
			if ${Me.PctHPs} >=  ${Config.GetSlider[sldStandHP]} && ${Me.Sitting}
			{
				Toon:Standup
				return
			}
			
			/* stealth food. mmm */
			if (${Me.Buff[Food](exists)}||(!${Consumable.HasFood}&&${Me.Sitting}))&&${This.shouldStealth}
			{
				Toon:CastSpell["Stealth"]
				This:Output["Stealth Food.  Mmmm."]
				return
			}			
					
			if !${Consumable.HasFood} && ${Me.PctHPs} < ${Config.GetSlider[sldStandHP]}
			{
				Toon:Sitdown
				return				
			}

			if ${Config.GetCheckBox[chkPatrolInStealth]}&&${This.shouldStealth}&&${Me.PctHPs}>${Config.GetSlider[sldRestHP]}&&!${Me.Sitting}
			{		
				if ${POI.Type.Equal[HOTSPOT]} && !${Mount.NeedMount} && !${Mount.IsMounted} 
				{
					Toon:CastSpell["Stealth"]
					This:Output["Patrol in Stealth..."]
					return
				}
			}
		}
	}
	
	
	;------------------
	;--- Buff SetUp ---
	;------------------
	
	member NeedBuff()
	{
		variable string PoisonType = ${This.chooseBestPoison[${Config.GetCombo[cmbMainHandPoison]}]}
		
		if (!${POI.Type.Equal[HOTSPOT]} && !${UIElement[chkAssistMode@Overview@Pages@openbot].Checked})  || ${Mount.NeedMount} || ${Mount.IsMounted}
		{
			return FALSE
		}
		
		/* skip buff to loot */
		if ${This.SkipToLoot}
		{
			return FALSE
		}
		
		if ${Config.GetCheckBox[chkPatrolInStealth]} && ${This.shouldStealth}
		{
			if ${POI.Type.Equal[HOTSPOT]} && !${Mount.NeedMount} && !${Mount.IsMounted} 
			{
				return TRUE
			}
		}
		
		if ${This.Lockpick.needPick}
		{
			return TRUE
		}
		
		if  !${Me.InCombat}&&${Me.Equip[mainhand](exists)} && !${Me.Equip[mainhand].Enchantment[${PoisonType}](exists)} && ${Item[${PoisonType}](exists)}
		{
			return TRUE
		}		
		
		PoisonType:Set[${This.chooseBestPoison[${Config.GetCombo[cmbOffHandPoison]}]}]
		if  !${Me.InCombat}&&${Me.Equip[offhand](exists)} && !${Me.Equip[offhand].Enchantment[${PoisonType}](exists)} && ${Item[${PoisonType}](exists)}
		{
			return TRUE
		}
		
		if ${Toon.canUseScroll}
		{
			return TRUE
		}	
		return FALSE
	}
	
	method BuffPulse()
	{
		variable string PoisonType = ${This.chooseBestPoison[${Config.GetCombo[cmbMainHandPoison]}]}

		if ${Movement.Speed}
		{
			Toon:Stop
			return
		}
		
		if ${Me.Casting}&&!${WoWScript[SpellIsTargeting()]}
		{
			This.buffWaitTimer:Set[${This.InMilliseconds[100]}]
		}
		
		if (${This.buffWaitTimer} < ${LavishScript.RunningTime})&&(${This.crazyWaitTimer} < ${LavishScript.RunningTime})
		{
			This:ClearWaitTimers
			This.pullTimeOut:Set[0]
			
			/* lets pause for 1 second before buffing - basically a lag wait so that we dont stealth prematurely*/
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
			
			if ${Config.GetCheckBox[chkPatrolInStealth]} && ${This.shouldStealth}
			{
				if ${POI.Type.Equal[HOTSPOT]} && !${Mount.NeedMount} && !${Mount.IsMounted} 
				{
					Toon:CastSpell["Stealth"]
					This:Output["Casting Stealth for Patrol"]
					return
				}
			}

			if ${This.Lockpick.needPick}
			{
				This.Lockpick:Pulse
				return
			}
			
			if  !${Me.InCombat}&&${Me.Equip[mainhand](exists)} && !${Me.Equip[mainhand].Enchantment[${PoisonType}](exists)} && ${Item[${PoisonType}](exists)}
			{			
				if ${WoWScript[SpellIsTargeting()]}
				{
					Me.Equip[mainhand]:PickUp
					This:Output["Mainhand Hand Poison: ${PoisonType}"]
					Bot.RandomPause:Set[24]
					This.buffWaitTimer:Set[${This.InMilliseconds[400]}]
					return
				}
				Item[${PoisonType}]:Use
				This.buffWaitTimer:Set[${This.InMilliseconds[25]}]
				return
			}		
			
			PoisonType:Set[${This.chooseBestPoison[${Config.GetCombo[cmbOffHandPoison]}]}]
			if  !${Me.InCombat}&&${Me.Equip[offhand](exists)} && !${Me.Equip[offhand].Enchantment[${PoisonType}](exists)} && ${Item[${PoisonType}](exists)}
			{
				if ${WoWScript[SpellIsTargeting()]}
				{
					Me.Equip[offhand]:PickUp
					This:Output["Off Hand Poison: ${PoisonType}"]
					Bot.RandomPause:Set[24]					
					This.buffWaitTimer:Set[${This.InMilliseconds[400]}]
					return
				}
				Item[${PoisonType}]:Use
				This.buffWaitTimer:Set[${This.InMilliseconds[25]}]
				return
			}
		}
	}
	
	member shouldStealth()
	{
		if !${Me.Buff[Stealth](exists)}&&${Spell[Stealth](exists)}
		{
			if !${Spell[Stealth].Cooldown} && !${Toon.IsDotted}
			{
			return TRUE
			}
		}
		return FALSE
	}

	
	;------------------
	;--- Pull Buff SetUp ---
	;------------------
	
	member NeedPullBuff()
	{
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
		return FALSE
	}

	method CombatBuffPulse()
	{
		if (${This.combatbuffWaitTimer} < ${LavishScript.RunningTime})&&(${This.crazyWaitTimer} < ${LavishScript.RunningTime})
		{
			This:ClearWaitTimers
		}
	}
	
	
	;------------------
	;--- Pull SetUp ---
	;------------------
	
	method PullPulse()
	{	
		/* lets make sure we are standing */
		Toon:Standup
		
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
		if ${Movement.Speed} && (${Target.Distance}<${Toon.MaxMelee} && ${Target.Distance}>${Toon.MinMelee})
		{
			Toon:Stop
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
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
				/* stealth open */
				/* make sure we are in stealth */
				if ${This.shouldStealth}
				{
						Toon:Stop
						Toon:CastSpell["Stealth"]
						This:Output["Casting Stealth for Pull"]
						return
				}
				
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]

				/* switch to dagger if we are ambusing */
				if ${Spell[Ambush](exists)}&&${Config.GetCheckBox[chkUseAmbush]}
				{
					/* lets check if we should be switching */
					if !${Me.Equip[16].SubType.Equal["Dagger"]} && ${This.canWeaponSwap["Dagger"]}
					{
						/* and... make sure we can get behind the target */
						if (${Spell[Shadowstep](exists)} && !${Spell[Shadowstep].Cooldown})||(${Toon.isFacingAway[80]} && ${Target.Distance} < 10)
						{
							/* ok. switch and brief pause while our dagger is put in our mainhand */
							This:SwitchWeapon["Dagger"]
							return
						}
					}
				}

				/* switch to dagger if we are backstabbing */
				if !${Spell[Ambush](exists)}&&!${Spell[Cheap Shot](exists)}&&${Spell["Backstab"](exists)}
				{
					/* lets check if we should be switching */
					if !${Me.Equip[16].SubType.Equal["Dagger"]} && ${This.canWeaponSwap["Dagger"]}
					{
						/* and... make sure we can get behind the target */
						if ${Toon.isFacingAway[80]}
						{
							/* ok. switch and brief pause while our dagger is put in our mainhand */
							This:SwitchWeapon["Dagger"]
							return
						}
					}
				}	
				
				/* move into melee range */
				if !${Toon.withinMelee[TRUE]}
				{
					/* distract when in range */
					if ${Config.GetCheckBox[chkUseDistract]}&&${This.checkDistract}&&${Toon.canCast[Distract]}&&${Math.Distance[${Me.X},${Me.Y},${Target.X},${Target.Y}]}<25
					{
						Toon:CastSpell[Distract]
						ISXWoW:ClickTerrain[${Math.Calc[1*${Math.Cos[${Me.Heading.DegreesCCW}].Milli}+${Target.X}]}, ${Math.Calc[2*${Math.Sin[${Me.Heading.DegreesCCW}].Milli}+${Target.Y}]}, ${Target.Z}]
						checkDistract:Set[FALSE]
						return
					}
					/* shadowstep if I like to ambush */
					if ${Toon.canCast[Shadowstep]} && ${Me.Buff[Stealth](exists)}
					{
						if ${Config.GetCheckBox[chkUseAmbush]} && ${Target.Distance} < 20 && ${Me.Equip[16].SubType.Equal["Dagger"]}
						{
							Toon:CastSpell["Shadowstep"]
							return
						}
					}
					Toon:ToMelee
					return					
				}
				
				
				/* we are in range, use stealth open if not detected*/
				if ${Me.Buff[Stealth](exists)} && ${Toon.withinMelee}
				{
					/* shadowstep if I like Ambush and cant */
					if ${Toon.canCast[Shadowstep]}
					{
						if ${Config.GetCheckBox[chkUseAmbush]} &&${Toon.canCast[Ambush]}&&${Me.Equip[16].SubType.Equal["Dagger"]}
						{
							Toon:CastSpell["Shadowstep"]
							WoWScript SpellStopCasting()
						}
					}
					/* lets use premed first or pickpocket if type*/
					if ${Toon.canCast[Premeditation]}
					{
						Toon:CastSpell["Premeditation"]
						WoWScript SpellStopCasting()
					}
					if (${Target.CreatureType.Equal["Humanoid"]}||${Target.CreatureType.Equal["Demon"]}||${Target.CreatureType.Equal["Undead"]})&&${Toon.canCast["Pick Pocket"]}&&${Config.GetCheckBox[chkUsePickPocket]}&&${This.checkPockets}
					{
						Toon:CastSpell["Pick Pocket"]
						This.checkPockets:Set[FALSE]
						WoWScript SpellStopCasting()
					}
					/* garrote humanoid casters if toggle enabled */
					if ${Config.GetCheckBox[chkUseGarrote]}&&(${Target.CreatureType.Equal["Humanoid"]}||${Target.CreatureType.Equal["Demon"]})&&${Target.MaxMana}>0&&${Toon.canCast[Garrote]}
					{
						This.pullWaitTimer:Set[${This.InSeconds[10]}]	
						This:Output["Stealth Open: Garrote"]
						Toon:CastSpell["Garrote"]
						return
					}
					/* ambush target if dagger is equiped */
					if ${Toon.isFacingAway[80]}&&${Me.Equip[16].SubType.Equal["Dagger"]}&&${Toon.canCast[Ambush]}&&${Config.GetCheckBox[chkUseAmbush]}
					{
						This.pullWaitTimer:Set[${This.InSeconds[10]}]	
						This:Output["Stealth Open: Ambush"]
						Toon:CastSpell["Ambush"]
						return
					}			
					/* otherwise open with a cheap shot */
					if ${Toon.canCast[Cheap Shot]}
					{
						This.pullWaitTimer:Set[${This.InSeconds[10]}]	
						This:Output["Stealth Open: Cheapshot"]
						Toon:CastSpell["Cheap Shot"]
						return
					}
					/* hmm. we didnt use an opener. lets just try to backstab if target is facing away */
					if ${Toon.isFacingAway[80]}&&${Me.Equip[16].SubType.Equal["Dagger"]}&&${Spell["Backstab"](exists)}&&${Me.Action["Backstab"].Usable}
					{
						This.pullWaitTimer:Set[${This.InSeconds[10]}]	
						This:Output["Stealth Open: Backstab"]
						Toon:CastSpell["Backstab"]
						return		
					}						
				}
				/* or if none of those worked, just start hacking away */		
				if ${Toon.withinMelee}
				{
					if !${Me.Attacking}
					{
						This.pullWaitTimer:Set[${This.InSeconds[10]}]	
						This:Output["Melee Open: Sinister Strike"]
						Toon:CastSpell["Sinister Strike"]
						WoWScript AttackTarget()
						return
					}				
				}
				return
			}

			/* check pull timeout for range*/
			if (${Math.Calc[${This.pullTimeOut}+50000]} < ${LavishScript.RunningTime}&&(${Target.MaxMana}<=0||!${Target.MaxMana(exists)}))||((${This.pullTimeOut} < ${LavishScript.RunningTime})&&(${This.detectMobAdd}||${Config.GetCheckBox[chkShootToPull]}))
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
		variable string MyRogueAttack
		variable guidlist NextClosestAggro
		variable string PotionName
				
		/* lets make sure we are standing */
		Toon:Standup

		/* i must have vanished, lets get to a safe spot */
		if ${Me.Buff[Vanish](exists)}
		{
			return
		}
		
		if !${Toon.ValidTarget[${Target.GUID}]}
		{
			Toon:Stop
			This:Output["I need a target"]
			Toon:NeedTarget[1]			
			return
		}	
		
		/* move behind a target when appropriate*/
		if ${This.moveBehind}&&(${Target.Buff[Kidney Shot](exists)}||${Target.Buff[Gouge](exists)})
		{
			if ${Target.GUID.Equal[${This.lastAttackTarget}]}
			{
				/* we need a Dagger in our mainhand */
				if !${Me.Equip[16].SubType.Equal["Dagger"]} && ${This.canWeaponSwap["Dagger"]}
				{
					This:SwitchWeapon["Dagger"]
				}
				/* start moving behind */
				if ${This.startMoveBehind}
				{
					This:Output["Moving Behind: On the move."]
					Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
					move forward 1500
					This.startMoveBehind:Set[FALSE]
					This.backattackWaitTimer:Set[${This.InMilliseconds[75]}]
					This.attackWaitTimer:Set[${This.InMilliseconds[75]}]
					return
				}	
				/* if we have had enough time to move to the other side of the mob, do next */
				if ${This.backattackWaitTimer} < ${LavishScript.RunningTime}
				{

					Toon:Stop
					Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
					
					/* create a brief pause for lag and have value for isFacing */
					if ${This.backattackPause}
					{
						This.attackWaitTimer:Set[${This.InMilliseconds[50]}]
						This.backattackPause:Set[FALSE]
					}

					/* wait until we have 60 energy and can back attack */
					if ${Me.CurrentEnergy}<60
					{
						This:Output["Moving Behind: Waiting for 60 Energy."]
						return
					}
				}
			}
		}
		
		/* lets make sure we recognize target is gouged or kidney shotted */
		if ${This.moveBehind} && ${This.attackWaitTimer} > ${LavishScript.RunningTime}
		{
			This:Output["Moving Behind: Pausing for Lag."]
			return
		}
		
		/* stop moving if no reason to move */
		if ${Movement.Speed} && ${Target.Distance} < ${Toon.MaxMelee} && ${Target.Distance} > ${Toon.MinMelee}
		{
			Toon:Stop
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
		}
			
		/* make sure we are facing target */
		Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]		
		
		/* make sure my auto-attacks are on */
		if !${Me.Attacking} && !${Target.Buff[Gouge](exists)}
		{
			WoWScript AttackTarget()
		}
		
		if (${This.attackWaitTimer} < ${LavishScript.RunningTime})&&(${This.crazyWaitTimer} < ${LavishScript.RunningTime})
		{
			/* pre-attack stuff */
			This:ClearWaitTimers
			This.pullTimeOut:Set[0]
			This.backattackPause:Set[FALSE]
			This.moveBehind:Set[FALSE]
			This.startMoveBehind:Set[FALSE]
			
			if !${Toon.TargetIsBestTarget} && ${Object[${Toon.BestTarget}](exists)} && ${Toon.BestTarget.NotEqual[NULL]}
			{
				if ( ${Object[${Toon.BestTarget}].Distance} < ${Toon.MinRanged} || ${Object[${Toon.BestTarget}].PctHPs} > 20 ) && ${Math.Calc[${LavishScript.RunningTime}-${This.PersistentTarget}]} > 5000
				{
					Toon:BestTarget
					return
				}
			}	
			
			/* reset stuff if I have attacked a new target */
			if !${Target.GUID.Equal[${This.lastAttackTarget}]}
			{
				This.PersistentTarget:Set[${LavishScript.RunningTime}]				
				This.kiteCheck:Set[FALSE]
				This.kiteWaitTimer:Set[0]
				This.checkPockets:Set[TRUE]
				This.checkDistract:Set[TRUE]
				This.lastAttackTarget:Set[${Target.GUID}]
			}		
			
			/* make sure we are in melee range */
			if ${Target.Distance} > ${Toon.MaxMelee}
			{
				/* check to see if I am being kited by another player - pauses 5 seconds before moving after the target*/
				if (${Target.TappedByMe} && !${Target.Target.GUID.Equal[${Me.GUID}]} && ${Target.Target.GUID(exists)}) &&!${Target.Buff[Cheap Shot](exists)}
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
					}
					if !${This.kiteCheck}
					{
						This.kiteWaitTimer:Set[${This.InMilliseconds[2000]}]
						This.attackWaitTimer:Set[${This.InMilliseconds[200]}]
						This.kiteCheck:Set[TRUE]
					}
				}
							
				/* is he fleeing? */
				if ${Target.PctHPs} < 20
				{ 
					if ${Object[${Toon.NextBestTarget}](exists)} && ${Toon.NextBestTarget.NotEqual[NULL]}
					{
						if !${IF[${Spell[Deadly Throw](exists)} && ${Me.ComboPoints}>=1&&${Me.Equip[18].SubType.Equal["Thrown"]},TRUE,FALSE]}
						{
						This:Output["Current target is fleeing. Choosing a closer target."]
						Target ${Toon.NextBestTarget}
						This.attackWaitTimer:Set[${This.InMilliseconds[50]}]
						return
						}
					}
					
					/* if we dont chase runners or deadly throw exists and we have combo pts */
					if !${Config.GetCheckBox[chkChaseRunners]} || (${Me.ComboPoints}>=1 && ${Me.Equip[18].SubType.Equal["Thrown"]} && ${Spell[Deadly Throw](exists)})
					{
						/* target cannot be range attacked, lets wait for them to flee */
						if ${Target.Distance} < ${Toon.MinRanged} && ${Target.Distance} < ${Toon.MaxRanged}
						{
							This.attackWaitTimer:Set[${This.InMilliseconds[100]}]
							return
						}
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
			
			/* our target is fleeing - stun him*/
			if ${Target.PctHPs}<20 && ${Toon.isFacingAway[90]} && (!${Target.Buff[Crippling Poison](exists)} && !${Config.GetCheckBox[chkChaseRunners]})
			{
				/* we got combo pts, lets kidney shot */
				if ${Me.ComboPoints}>=1 && ${Toon.canCast["Kidney Shot"]}
				{	
					Toon:CastSpell["Kidney Shot"]
					This:Output["Casting Kidney Shot to stun Fleeing mob"]
					return
				}
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
							
			/* determine which attack will be used */	
			MyRogueAttack:Set[${This.chooseRogueAttack}]
			
			switch ${MyRogueAttack}
			{
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
				case gougetostab
				{
					Toon:CastSpell["Gouge"]
					This:Output["Casting Gouge to move behind target"]		
					This:setStabLoc
					This.moveBehind:Set[TRUE]
					This.backattackPause:Set[TRUE]
					This.startMoveBehind:Set[TRUE]
					This.attackWaitTimer:Set[${This.InMilliseconds[100]}]
					return
				}
				case kidneytostab
				{
					Toon:CastSpell["Kidney Shot"]
					This:Output["Casting Kidney Shot to move behind target"]
					This:setStabLoc
					This.moveBehind:Set[TRUE]
					This.backattackPause:Set[TRUE]
					This.startMoveBehind:Set[TRUE]
					This.attackWaitTimer:Set[${This.InMilliseconds[100]}]
					return				
				}
				case Vanish
				{
					Bot.RandomPause:Set[9]
					GlobalBlacklist:Insert[${Target.GUID},30000]					
					Toon:CastSpell[${MyRogueAttack}]
					WoWScript ClearTarget()
					return
				}
				case Gouge
				{	
					Target ${Toon.NextBestTarget}			
					Toon:CastSpell["Gouge"]
					This:Output["In Melee: Gouging ${Object[${Toon.NextBestTarget}].Name}"]
					Target ${This.lastAttackTarget}	
					Bot.RandomPause:Set[14]					
					return
				}
				case Blind
				{
					Target ${Toon.NextBestTarget}			
					Toon:CastSpell["Blind"]
					This:Output["In Melee: Blinding ${Object[${Toon.NextBestTarget}].Name}"]
					Target ${This.lastAttackTarget}		
					Bot.RandomPause:Set[14]					
					return					
				}
				default
				{
					/* output spam prevention */
					if ${Me.Action[${MyRogueAttack}].Usable}
					{
						This:Output["In Melee: Casting ${MyRogueAttack}"]
					}
					Toon:CastSpell[${MyRogueAttack}]
					Bot.RandomPause:Set[14]					
					return
				}
			}
		}
	}
	
	member chooseRogueAttack()
	{		
		variable string MyRogueAttack
		variable guidlist Aggros
		variable int MobAdds
		
		/* determine number of adds */
		Aggros:Search[-units, -nearest, -targetingme, -alive, -range 0-30]
		MobAdds:Set[(${Aggros.Count} - 1)]		
		Aggros:Clear
		
		/* set the default attack */
		MyRogueAttack:Set[${Config.GetCombo[cmbPrimaryAttack]}]
		
		/* vanish or flee */
		if (${Me.PctHPs}<=${Config.GetSlider[sldHealthForVanish]}||${MobAdds}>=${Config.GetSlider[sldAddsForVanish]})
		{
			
			if !${Spell[Vanish].Cooldown} && ${Spell[Vanish](exists)}
			{
				Toon:Flee
				MyRogueAttack:Set["Vanish"]
				return ${MyRogueAttack}
			}
			/* vanish is on cooldown, can i cast preparation? */
			if ${Spell[Preparation](exists)}&&!${Spell[Preparation].Cooldown}&&${Me.PctHPs}<=${Config.GetSlider[sldHealthForVanish]}
			{
				MyRogueAttack:Set["Preparation"]
				return ${MyRogueAttack}		
			}
			else
			{
				Toon:Flee
				return ${MyRogueAttack}					
			}
		}
				
		/* evasion */
		if (${Me.PctHPs}<=${Config.GetSlider[sldHealthForEvasion]}||${MobAdds}>=${Config.GetSlider[sldAddsForEvasion]})&&${Spell[Evasion](exists)}&&!${Me.Buff[Evasion](exists)}
		{
			if !${Spell[Evasion].Cooldown}
			{
					MyRogueAttack:Set["Evasion"]
					return ${MyRogueAttack}
			}
			/* evasion is on cooldown, can i cast preparation? */
			elseif ${Spell[Preparation](exists)}&&!${Spell[Preparation].Cooldown}&&${Me.PctHPs}<=${Math.Calc[${Config.GetSlider[sldHealthForEvasion]}/2]}
			{
				MyRogueAttack:Set["Preparation"]
				return ${MyRogueAttack}		
			}
		}
		
		/* blade flurry */
		if ((${Target.PctHPs}>50&&${MobAdds}>=${Config.GetSlider[sldAddsForBladeFlurry]})||(${MobAdds}>=(${Config.GetSlider[sldAddsForAdrenalineRush]} + 1)))&&!${Me.Buff[Blade Flurry](exists)}&&${Toon.canCast["Blade Flurry"]}
		{
				MyRogueAttack:Set["Blade Flurry"]
				return ${MyRogueAttack}
		}
		
		/* adrenaline rush */
		if ((${Target.PctHPs}>50&&${MobAdds}>=${Config.GetSlider[sldAddsForAdrenalineRush]})||(${MobAdds}>=(${Config.GetSlider[sldAddsForAdrenalineRush]} + 1)))&&${Spell[Adrenaline Rush](exists)}&&!${Me.Buff[Adrenaline Rush](exists)}
		{
			if !${Spell[Adrenaline Rush].Cooldown}
			{
					MyRogueAttack:Set["Adrenaline Rush"]
					return ${MyRogueAttack}
			}
			/* adrenaline rush is on cooldown, can i cast preparation? */
			elseif ${Spell[Preparation](exists)}&&!${Spell[Preparation].Cooldown}&&${Me.PctHPs}<=${Config.GetSlider[sldHealthForEvasion]}
			{
				MyRogueAttack:Set["Preparation"]
				return ${MyRogueAttack}		
			}			
		}

		/* dont you try to cast on me, motherfucker */
		if ${Config.GetCheckBox[chkRacial]}&&${Me.Race.Equal[Blood Elf]}
		{
			if ${Target.Casting(exists)}&&${Target.MaxMana}>0&&${Spell[Arcane Torrent](exists)}&&${Me.Buff[Mana Tap](exists)}&&!${Spell[Arcane Torrent].Cooldown}
			{
				MyRogueAttack:Set["Arcane Torrent"]
				return ${MyRogueAttack}		
			}
		}
		
		if ${Target.Casting(exists)}&&${Target.MaxMana}>0&&${Config.GetCheckBox[chkUseKick]}&&${Toon.canCast[Kick]}
		{
			MyRogueAttack:Set["Kick"]
			return ${MyRogueAttack}		
		}

		if ${Target.PctHPs}>25&&${MobAdds}>=1
		{
			if ${Object[${Toon.NextBestTarget}](exists)}&& ${Toon.NextBestTarget.NotEqual[NULL]}
			{
				/* if facing away returns true, the target is likely behind me */
				if !${Toon.isFacingAway[100,${Toon.NextBestTarget}]}
				{
					if !${Object[${Toon.NextBestTarget}].Buff["Blind"](exists)}&&!${Object[${Toon.NextBestTarget}].Buff["Gouge"](exists)}&&!${Me.Buff[Blade Flurry](exists)}
					{
						if ${Object[${Toon.NextBestTarget}].Distance}<=${Toon.MaxMelee}&&${Me.Action[Gouge].Usable}&&${Toon.canCast[Gouge]}&&${Config.GetCheckBox[chkUseGougeOnAdds]}
						{
							return "Gouge"
						}
						if ${Object[${Toon.NextBestTarget}].Distance}<=10&&${Me.Action[Blind].Usable}&&${Toon.canCast[Blind]}&&${Config.GetCheckBox[chkUseBlindOnAdds]}
						{
							return "Blind"
						}
					}
				}
			}
		}
		
		/* is our back attack usable, do it now */
		if ${Config.GetCheckBox[chkUseBackAttack]}&&${Toon.isFacingAway[80]}&&${Me.Equip[16].SubType.Equal["Dagger"]}&&${Spell[${Config.GetCombo[cmbPrimaryBackAttack]}](exists)}&&${Me.Action[${Config.GetCombo[cmbPrimaryBackAttack]}].Usable}
		{
			MyRogueAttack:Set[${Config.GetCombo[cmbPrimaryBackAttack]}]
			return ${MyRogueAttack}				
		}
		
		/* we got combo pts, time for a finisher? */
		if ${Me.ComboPoints}>=1&&${Target.PctHPs}>0
		{
			if ${Config.GetCheckBox[chkUseBackAttack]}&&(${Me.Equip[16].SubType.Equal["Dagger"]} || ${This.canWeaponSwap["Dagger"]})&&${Me.ComboPoints}==5&&${Toon.canCast["Kidney Shot"]}&&(${Target.PctHPs}>35&&${MobAdds}<1)
			{
				if !${Target.Buff[Gouge](exists)}&&!${Target.Buff[Cheap Shot](exists)}
				{
					MyRogueAttack:Set["kidneytostab"]
					return ${MyRogueAttack}
				}
			}
			if ${Target.PctHPs}>=${Config.GetSlider[sldHealthForRupture]}&&${Config.GetCheckBox[chkUseRupture]}&&${Me.ComboPoints}==5&&${Spell[Rupture](exists)}&&!${Target.Buff[Rupture](exists)}&&!${Me.Buff[Blade Flurry](exists)}&&!${Target.CreatureType.Equal["Elemental"]}&&!${Target.CreatureType.Equal["Mechanical"]}
			{
				MyRogueAttack:Set["Rupture"]
				return ${MyRogueAttack}	
			}
			if ((${Target.Casting(exists)}&&${Me.ComboPoints}>3)||(${Target.PctHPs}>=${Config.GetSlider[sldHealthForKidneyShot]}&&${Target.PctHPs}<${Config.GetSlider[sldHealthForRupture]}&&${Me.ComboPoints}==4)||(${Target.PctHPs}>=${Config.GetSlider[sldHealthForKidneyShot]}&&${Me.ComboPoints}==5))&&${Config.GetCheckBox[chkUseKidneyShot]}&&${Toon.canCast["Kidney Shot"]}&&!${Target.Buff[Cheap Shot](exists)}&&!${Me.Buff[Blade Flurry](exists)}
			{
				MyRogueAttack:Set["Kidney Shot"]
				return ${MyRogueAttack}	
			}
			if (${Target.PctHPs}>50||${MobAdds}>0)&&${Spell[Slice and Dice](exists)}&&${Me.ComboPoints}==1&&!${Me.Buff[Slice and Dice](exists)}&&${Config.GetCheckBox[chkUseSliceAndDice]}
			{
				MyRogueAttack:Set["Slice and Dice"]
				return ${MyRogueAttack}				
			}
			if (${Me.ComboPoints}==5||${Me.ComboPoints}*${Config.GetSlider[sldEviscerateMultiplier]}>=${Target.PctHPs})&&${Spell[Eviscerate](exists)}&&${Me.CurrentEnergy}>35
			{
				/* cast cold blood if available and target is more than 50 pct life */
				if ${Toon.canCast["Cold Blood"]}&&${Target.PctHPs}>50
				{
					MyRogueAttack:Set["Cold Blood"]
					return ${MyRogueAttack}	
				}
				MyRogueAttack:Set["Eviscerate"]
				return ${MyRogueAttack}			
			}
		}

		/* gouge target to backstab*/
		if ${Config.GetCheckBox[chkUseBackAttack]}&&(${Me.Equip[16].SubType.Equal["Dagger"]} || ${This.canWeaponSwap["Dagger"]})&&${Me.Action[Gouge].Usable}&&${Toon.canCast[Gouge]}&&${Target.PctHPs}>30&&${MobAdds}<1
		{		
			if !${Target.Buff[Cheap Shot](exists)}&&!${Target.Buff[Kidney Shot](exists)}&&!${Me.Buff[Blade Flurry](exists)}&&!${Me.Buff[Slice and Dice](exists)}
			{
				MyRogueAttack:Set["gougetostab"]
				return ${MyRogueAttack}	
			}
		}
		
		/* can we riposte? */
		if ${Toon.canCast[Riposte]}&&${Me.Action[Riposte].Usable}&&${Config.GetCheckBox[chkUseRiposte]} 
		{
			MyRogueAttack:Set["Riposte"]
			return ${MyRogueAttack}	
		}
		
		/* can we ghostly strike */
		if ${Toon.canCast["Ghostly Strike"]}&&${Config.GetCheckBox[chkUseGhostlyStrike]}&&!${Target.Buff[Cheap Shot](exists)}&&!${Target.Buff[Kidney Shot](exists)}
		{
			MyRogueAttack:Set["Ghostly Strike"]
			return ${MyRogueAttack}	
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
		
		/* Racials  */
		/* lol. removed dranei and tauren when i realized they cant be rogues*/
		if ${Config.GetCheckBox[chkRacial]}
		{
			switch ${Me.Race}
			{
				case Troll
				{
					if ${Me.PctHPs} < 90 && ${Target.PctHPs} > 50 && ${Toon.canCast["Berserking"]}
					{
						MyRogueAttack:Set["Berserking"]
						return ${MyRogueAttack}	
					}
				}
				case Orc
				{
					if ${Me.PctHPs} > 90 && ${Target.PctHPs} > 50 && ${Toon.canCast["Blood Fury"]}
					{
						MyRogueAttack:Set["Blood Fury"]
						return ${MyRogueAttack}	
					}
				}
				case Undead
				{
					if ${Me.Buff[Feared](exists)} && ${Toon.canCast["Will of the Forsaken"]}
					{
						MyRogueAttack:Set["Will of the Forsaken"]
						return ${MyRogueAttack}	
					}
				}
				case Blood Elf
				{
					if ${Target.MaxMana}>0&&${Toon.canCast["Mana Tap"]}&&(${Me.Buff[Mana Tap].Application}<=2)
					{
						MyRogueAttack:Set["Mana Tap"]
						return ${MyRogueAttack}	
					}
				}
				case Dwarf
				{
					if (${Me.Buff[Poisoned](exists)}&&${Me.Buff[Diseased](exists)}&&${Me.Buff[Bleeding](exists)})&&${Toon.canCast[Stoneform]}
					{
						MyRogueAttack:Set["Stoneform"]
						return ${MyRogueAttack}	
					}
				}
				case Gnome
				{
					if (${Me.Buff[Immobilized](exists)}&&${Me.Buff[Slowed](exists)})&&${Toon.canCast["Escape Artist"]}
					{
						MyRogueAttack:Set["Escape Artist"]
						return ${MyRogueAttack}	
					}
				}
				default
				{
					/* do nothing */
				}
			}
		}
		
		/* if your main attack is shiv and your fighting a poison immune mob, use SS instead */
		if ${MyRogueAttack.Equal["Shiv"]}&&(${Target.CreatureType.Equal["Elemental"]}||${Target.CreatureType.Equal["Mechanical"]})
		{
			MyRogueAttack:Set["Sinister Strike"]
			return ${MyRogueAttack}	
		}
		
		/* if your main attack is hemo and the target already has the hemo debuff, use SS instead */
		if ${MyRogueAttack.Equal["Hemorrhage"]}&&${Target.Buff["Hemorrhage"](exists)}
		{
			MyRogueAttack:Set["Sinister Strike"]
			return ${MyRogueAttack}	
		}
		
		/* if your main rogue attack doesnt exist call an error and use SS*/
		if !${Spell[${MyRogueAttack}](exists)}
		{
			This:Output["The main rogue attack you selected doesn't exist. Using SS instead."]
			MyRogueAttack:Set["Sinister Strike"]
			return ${MyRogueAttack}
		}
		
		/* we need our Normal mainhand weapon */
		if ${Me.Equip[16].SubType.Equal["Dagger"]} && ${This.canWeaponSwap}
		{
			This:SwitchWeapon
			return
		}	
		
		return ${MyRogueAttack}	
	}

	;--------------------
	;--- Misc Functions ---
	;--------------------	

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
	
	/* by default, first slot in your backpack */
	/* only switches if the weapon is a dagger, sword, mace or fist weapon */
	method SwitchWeapon(int bagNum=0, int slotNum=1)
	{ 
		This:Output["Weapon Swap: ${Me.Bag[${bagNum}].Item[${slotNum}].Name} in Bag ${bagNum}, Slot ${slotNum}"]
		Me.Bag[${bagNum}].Item[${slotNum}]:Use
		return
	}	
	
	/* checks to see if it should be swapping weapons */
	member canWeaponSwap(string requireDagger = "NO", int bagNum=0, int slotNum=1)
	{ 
		variable string itemSubType = ${Me.Bag[${bagNum}].Item[${slotNum}].SubType}
		if ${Config.GetCheckBox[chkWeaponSwap]}
		{		
			if ${requireDagger.Equal["Dagger"]}
			{
				if ${itemSubType.Equal["Dagger"]}
				{
					return TRUE
				}
				return FALSE
			}
			if ${itemSubType.Equal["Mace"]} || ${itemSubType.Equal["Sword"]} || ${itemSubType.Equal["Fist"]}
			{
				return TRUE
			}
			if !${itemSubType.Equal["Dagger"]}
			{
				This:Output["No Weapon found in Bag ${bagNum}, Slot ${slotNum}"]
			}
			return FALSE
		}
		return FALSE
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
	
	member chooseBestPoison(string PoisonType)
	{
		variable int i = 1
		variable index:string PoisonName
		PoisonName:Insert["${PoisonType} Poison VIII"]
		PoisonName:Insert["${PoisonType} Poison VII"]
		PoisonName:Insert["${PoisonType} Poison VI"]
		PoisonName:Insert["${PoisonType} Poison V"]
		PoisonName:Insert["${PoisonType} Poison IV"]
		PoisonName:Insert["${PoisonType} Poison III"]
		PoisonName:Insert["${PoisonType} Poison II"]
		PoisonName:Insert["${PoisonType} Poison"]
		do
			{
			if ${Item[${PoisonName.Get[${i}]}](exists)}
			{
			return "${PoisonName.Get[${i}]}"
			}
		}
		while ${PoisonName.Get[${i:Inc}](exists)}
		return "NONE"
	}
		
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
		This.backattackWaitTimer:Set[0]
		This.lootWaitTimer:Set[0]	
	}


	;----------------------
	;--- Event Hooking ---
	;----------------------

	variable collection:string UIErrorMsgStrings	
	method CreateUIErrorStrings()
	{
		This.UIErrorMsgStrings:Set["You are facing the wrong way!","backward"]
		This.UIErrorMsgStrings:Set["Target too close","backward"]
		This.UIErrorMsgStrings:Set["You are too far away!","forward"]		
		This.UIErrorMsgStrings:Set["Out of range.","forward"]			
	}

	variable bool needUIHook = TRUE
	method UIErrorMessage(string Id, string Msg)
	{
		if ${This.UIErrorMsgStrings.Element[${Msg}](exists)} && !${Bot.PauseFlag} && ${This.crazyWaitTimer} < ${LavishScript.RunningTime}
		{
			if ${Msg.Equal["Target too close"]} || (${Target.Distance} < 5 && ${Me.InCombat}) || ${This.UIErrorMsgStrings.Element[${Msg}].Equal["forward"]}
			{
				This:Debug[${Msg}]
				This:Output["Moving ${This.UIErrorMsgStrings.Element[${Msg}]} - UI Error: ${Msg}"]
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
				This.attackWaitTimer:Set[${This.InMilliseconds[25]}]
				This.pullWaitTimer:Set[${This.InMilliseconds[25]}]
				move ${This.UIErrorMsgStrings.Element[${Msg}]} 800
				return				
			}
		}
	}	

	variable bool needCombatHook = FALSE
	method CombatEvent(string unitID, string unitAction, string isCrit, string amtDamage, string damageType)
	{
	}	
	
	;--------------------
	;--- ROGUE GUI ---
	;--------------------
	
	method SetGUI()
	{
		variable string uniqueToon = "${Me.Name}:${Me.Class}:${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}"
		Config:SetCheckBox[${uniqueToon},"chkSkipToLoot","chkSkipToLoot@Core@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkShootToPull","chkShootToPull@Core@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkChaseRunners","chkChaseRunners@Core@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseBackAttack","chkUseBackAttack@Core@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkWeaponSwap","chkWeaponSwap@Core@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkUseSliceAndDice","chkUseSliceAndDice@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseRupture","chkUseRupture@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseGarrote","chkUseGarrote@Ability@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkUseKidneyShot","chkUseKidneyShot@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseAmbush","chkUseAmbush@Ability@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkUseRiposte","chkUseRiposte@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseGhostlyStrike","chkUseGhostlyStrike@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseKick","chkUseKick@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseDistract","chkUseDistract@Ability@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkRangePullOnDetectAdds","chkRangePullOnDetectAdds@Aggro@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkPatrolInStealth","chkPatrolInStealth@Misc@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkRacial","chkRacial@Misc@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUsePickPocket","chkUsePickPocket@Misc@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseGougeOnAdds","chkUseGougeOnAdds@Aggro@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseBlindOnAdds","chkUseBlindOnAdds@Aggro@Pages@ClassGUI",TRUE]
		Config:SetCombo[${uniqueToon},"cmbPrimaryAttack","cmbPrimaryAttack@Core@Pages@ClassGUI"]
		Config:SetCombo[${uniqueToon},"cmbPrimaryBackAttack","cmbPrimaryBackAttack@Core@Pages@ClassGUI"]
		Config:SetCombo[${uniqueToon},"cmbMainHandPoison","cmbMainHandPoison@Misc@Pages@ClassGUI"]
		Config:SetCombo[${uniqueToon},"cmbOffHandPoison","cmbOffHandPoison@Misc@Pages@ClassGUI"]
		Config:SetSlider[${uniqueToon},"sldRestHP","sldRestHP@Core@Pages@ClassGUI",60]
		Config:SetSlider[${uniqueToon},"sldStandHP","sldStandHP@Core@Pages@ClassGUI",100]
		Config:SetSlider[${uniqueToon},"sldEviscerateMultiplier","sldEviscerateMultiplier@Ability@Pages@ClassGUI",10]
		Config:SetSlider[${uniqueToon},"sldAddsForBladeFlurry","sldAddsForBladeFlurry@Aggro@Pages@ClassGUI",1]
		Config:SetSlider[${uniqueToon},"sldAddsForAdrenalineRush","sldAddsForAdrenalineRush@Aggro@Pages@ClassGUI",1]
		Config:SetSlider[${uniqueToon},"sldAddsForVanish","sldAddsForVanish@Aggro@Pages@ClassGUI",3]
		Config:SetSlider[${uniqueToon},"sldAddsForEvasion","sldAddsForEvasion@Aggro@Pages@ClassGUI",2]
		Config:SetSlider[${uniqueToon},"sldAddsForTrinketOne","sldAddsForTrinketOne@Aggro@Pages@ClassGUI",0]
		Config:SetSlider[${uniqueToon},"sldAddsForTrinketTwo","sldAddsForTrinketTwo@Aggro@Pages@ClassGUI",0]
		Config:SetSlider[${uniqueToon},"sldHealthForEvasion","sldHealthForEvasion@Misc@Pages@ClassGUI",45]
		Config:SetSlider[${uniqueToon},"sldHealthForVanish","sldHealthForVanish@Misc@Pages@ClassGUI",12]
		Config:SetSlider[${uniqueToon},"sldHealthForBandage","sldHealthForBandage@Misc@Pages@ClassGUI",35]
		Config:SetSlider[${uniqueToon},"sldHealthForPotion","sldHealthForPotion@Misc@Pages@ClassGUI",20]
		Config:SetSlider[${uniqueToon},"sldRangePullOnDetectAddsRadius","sldRangePullOnDetectAddsRadius@Aggro@Pages@ClassGUI",25]
		Config:SetSlider[${uniqueToon},"sldHealthForRupture","sldHealthForRupture@Ability@Pages@ClassGUI",70]
		Config:SetSlider[${uniqueToon},"sldHealthForKidneyShot","sldHealthForKidneyShot@Ability@Pages@ClassGUI",50]
		Config:SetSlider[${uniqueToon},"sldPullBailOutTimer","sldPullBailOutTimer@Misc@Pages@ClassGUI",2200]
	}
	
	method SaveGUI()
	{
		variable string uniqueToon = "${Me.Name}:${Me.Class}:${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}"
		Config:SaveCheckBox[${uniqueToon},"chkSkipToLoot"]
		Config:SaveCheckBox[${uniqueToon},"chkShootToPull"]
		Config:SaveCheckBox[${uniqueToon},"chkChaseRunners"]
		Config:SaveCheckBox[${uniqueToon},"chkUseBackAttack"]
		Config:SaveCheckBox[${uniqueToon},"chkWeaponSwap"]
		Config:SaveCheckBox[${uniqueToon},"chkUseSliceAndDice"]
		Config:SaveCheckBox[${uniqueToon},"chkUseRupture"]
		Config:SaveCheckBox[${uniqueToon},"chkUseGarrote"]
		Config:SaveCheckBox[${uniqueToon},"chkUseKidneyShot"]
		Config:SaveCheckBox[${uniqueToon},"chkUseAmbush"]
		Config:SaveCheckBox[${uniqueToon},"chkUseRiposte"]
		Config:SaveCheckBox[${uniqueToon},"chkUseGhostlyStrike"]
		Config:SaveCheckBox[${uniqueToon},"chkUseKick"]
		Config:SaveCheckBox[${uniqueToon},"chkUseDistract"]
		Config:SaveCheckBox[${uniqueToon},"chkRangePullOnDetectAdds"]
		Config:SaveCheckBox[${uniqueToon},"chkPatrolInStealth"]
		Config:SaveCheckBox[${uniqueToon},"chkRacial"]
		Config:SaveCheckBox[${uniqueToon},"chkUsePickPocket"]
		Config:SaveCheckBox[${uniqueToon},"chkUseGougeOnAdds"]
		Config:SaveCheckBox[${uniqueToon},"chkUseBlindOnAdds"]
		Config:SaveCombo[${uniqueToon},"cmbPrimaryAttack"]
		Config:SaveCombo[${uniqueToon},"cmbPrimaryBackAttack"]
		Config:SaveCombo[${uniqueToon},"cmbMainHandPoison"]
		Config:SaveCombo[${uniqueToon},"cmbOffHandPoison"]
		Config:SaveSlider[${uniqueToon},"sldRestHP"]
		Config:SaveSlider[${uniqueToon},"sldStandHP"]
		Config:SaveSlider[${uniqueToon},"sldEviscerateMultiplier"]
		Config:SaveSlider[${uniqueToon},"sldAddsForBladeFlurry"]
		Config:SaveSlider[${uniqueToon},"sldAddsForAdrenalineRush"]
		Config:SaveSlider[${uniqueToon},"sldAddsForVanish"]
		Config:SaveSlider[${uniqueToon},"sldAddsForEvasion"]
		Config:SaveSlider[${uniqueToon},"sldAddsForTrinketOne"]
		Config:SaveSlider[${uniqueToon},"sldAddsForTrinketTwo"]
		Config:SaveSlider[${uniqueToon},"sldHealthForEvasion"]
		Config:SaveSlider[${uniqueToon},"sldHealthForVanish"]
		Config:SaveSlider[${uniqueToon},"sldHealthForBandage"]
		Config:SaveSlider[${uniqueToon},"sldHealthForPotion"]
		Config:SaveSlider[${uniqueToon},"sldRangePullOnDetectAddsRadius"]
		Config:SaveSlider[${uniqueToon},"sldHealthForRupture"]
		Config:SaveSlider[${uniqueToon},"sldHealthForKidneyShot"]
		Config:SaveSlider[${uniqueToon},"sldPullBailOutTimer"]
	}
}

objectdef oLockpick inherits oBase
{
	variable collection:int PickingSkill
	variable string OpenedBox = NULL
	variable string LockedBox = NULL
	variable int LastScan = 0
	
	method Pulse()
	{
		if ${LootWindow(exists)}
		{
			if ${LootWindow.Count} > 0 
			{
				POI:LootAll
				Class.buffWaitTimer:Set[${This.InMilliseconds[100]}]						
				return
			}
			else
			{
				WoWScript CloseLoot()
				This.LockedBox:Set[NULL]
				This.OpenedBox:Set[NULL]
				Class.buffWaitTimer:Set[${This.InMilliseconds[100]}]						
				return
			}
		}
		if (${Object[${This.OpenedBox}](exists)} && ${This.OpenedBox.NotEqual[NULL]})
		{
			if ${WoWScript[SpellIsTargeting()]} 
			{
				Item[${This.OpenedBox}]:Use
				Class.buffWaitTimer:Set[${This.InMilliseconds[100]}]	
				return			
			}
			else
			{
				Item[${This.OpenedBox}]:Use
				This.OpenedBox:Set[NULL]				
				Class.buffWaitTimer:Set[${This.InMilliseconds[100]}]	
				return
			}				
		}
		if (${Object[${This.LockedBox}](exists)} && ${This.LockedBox.NotEqual[NULL]})
		{
			Toon:CastSpell[Pick Lock]
			This.OpenedBox:Set[${This.LockedBox}]
			Class.buffWaitTimer:Set[${This.InMilliseconds[100]}]					
			return	
		}
		else
		{
			This.LockedBox:Set[NULL]
			This.OpenedBox:Set[NULL]
			return
		}
	}
	
	member canPick(string box)
	{
		variable string theTestChest
		theTestChest:Set[${Item[-inventory,-usable,-locked,${box}].GUID}]
		if ${This.PickingSkill.Element[${Item[${theTestChest}].Name}](exists)} && ${This.PickingSkill.Element[${Item[${theTestChest}].Name}]} <= ${Me.Skill[Lockpicking]}
		{
			This.LockedBox:Set[${theTestChest}]
			return TRUE
		}
		return FALSE
	}

	member checkForLocks()
	{
		if ${Math.Calc[${LavishScript.RunningTime}-${This.LastScan}]} < 30000
		{
			return FALSE
		}
		if ${This.canPick[Chest]} 
		{
			return TRUE
		}
		if ${This.canPick[Junkbox]} 
		{
			return TRUE
		}
		if ${This.canPick[Lockbox]} 
		{
			return TRUE
		}
		This.LastScan:Set[${LavishScript.RunningTime}]
		return FALSE
	}

	member needPick()
	{
		if (${Object[${This.LockedBox}](exists)} && ${This.LockedBox.NotEqual[NULL]}) || (${Object[${This.OpenedBox}](exists)} && ${This.OpenedBox.NotEqual[NULL]})
		{
			return TRUE
		}
		This.LockedBox:Set[NULL]
		This.OpenedBox:Set[NULL]
		
		if ${This.checkForLocks}
		{
			if ${Inventory.FreeSlots} > 0
			{
				return TRUE
			}
		}
		return FALSE
	}

	method PickingStrings()
	{
			This:Output[Loading Lockpicking Data.]
			This.PickingSkill:Set["Battered Junkbox","1"]
			This.PickingSkill:Set["Small Locked Chest","5"]
			This.PickingSkill:Set["Ornate Bronze Lockbox","5"]
			This.PickingSkill:Set["Heavy Bronze Lockbox","25"]
			This.PickingSkill:Set["Sturdy Locked Chest","70"]
			This.PickingSkill:Set["Iron Lockbox","70"]
			This.PickingSkill:Set["Worn Junkbox","75"]
			This.PickingSkill:Set["Strong Iron Lockbox","125"]
			This.PickingSkill:Set["Sturdy Junkbox","175"]
			This.PickingSkill:Set["Ironbound Locked Chest","175"]
			This.PickingSkill:Set["Steel Lockbox","175"]
			This.PickingSkill:Set["Reinforced Steel Lockbox","225"]
			This.PickingSkill:Set["Mithril Lockbox","225"]
			This.PickingSkill:Set["Thorium Lockbox","225"]
			This.PickingSkill:Set["Eternium Lockbox","225"]
			This.PickingSkill:Set["Heavy Junkbox","250"]
			This.PickingSkill:Set["Reinforced Locked Chest","250"]
			This.PickingSkill:Set["Strong Junkbox","300"]
			This.PickingSkill:Set["Khorium Lockbox","325"]
	}	
}