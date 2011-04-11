; -------------------------------------------------------------------------
; Kz Hunter 1.00
;
; Thanks to everyone for the extensive plagiarized code segments and even the framework!
; Also, thanks to all those that helped test and improve Kz Hunter!
;
; Pet Food			Place desired pet food closest to top of rightmost bag. Actual position is not important as long as it occurs before your food.
;					Bags will be rescanned  (right to left, top to bottom) as necessary to find useable pet foods.
;
;
; -------------------------------------------------------------------------

#ifndef		KZ_MSGLVL
 #define	KZ_MSGLVL		0											/* status messages: 0: disable, 1: limited, 2: verbose, 3: debug		*/
#endif 

; -------------------------------------------------------------------------

#include cMobInfo.iss													/* track mob historical info - runner, immunities, magical damage type	*/
			  
; -------------------------------------------------------------------------
objectdef cClass inherits cBase
{
	; ---------------------------------------------------------------------
	; hunter sttings	
	variable int MeAspect = 4											/* which aspect would you like your hunter to use? 0-None # 1-Monkey # 2-Hawk # 3-Cheetah # 4-Viper */
	
	; ---------------------------------------------------------------------
	; pet care	
	variable int MendPetPct = 50										/* percentage pet HP we should you cast Mend Pet			*/
	variable int FeedPetPct = 70										/* percentage pet happiness we should you feed pet			*/

	variable int FeedPetTimer1 = 1000									/* (1000) time to wait after casting feed pet				*/
	variable int FeedPetTimer2 = 2000									/* (2000) time to wait for pet to start eating				*/ 	
																						 
	; ---------------------------------------------------------------------
	; ---------------------------------------------------------------------
	; !!! DO NOT CHANGE VARIABLES BELOW THIS LINE !!!

	variable string ReactCast = "None"							 		/* error message on this attack type						*/   
	variable bool OutOfAmmo = FALSE										/* will be set TRUE if we have run out of ammo   			*/

	variable bool NoPet = FALSE											/* set when we do not have a pet							*/
	variable bool PetModePassive = TRUE									/* TRUE: pet passive mode,  FALSE: pet defensive mode		*/
	
	variable bool NoPetFood = FALSE										/* set when we can not find any food for our pet			*/
	variable string PetFood = NULL										/* food we are trying to feed our pet						*/
	variable set PetFoodBad												/* items our pet will not eat								*/
	variable bool PetFeed = FALSE
	variable int LastFeedPetTime = ${LavishScript.RunningTime}			/* last time we tried to feed our pet						*/
	
	variable bool NeedCallPet = TRUE									/* TRUE: try call pet, FALSE: rez pet						*/
	variable int LastCallPetTime = ${LavishScript.RunningTime}			/* last time we tried to call our pet						*/
				  
	variable int LastFeignDeathTime = ${LavishScript.RunningTime}		/* last time we tried to feign death						*/

	variable bool PlacingFreezingTrap = FALSE							/* true if we are in the process or placing a freezing trap	*/
					  
	variable int RangeAdjustTime = ${LavishScript.RunningTime}			/* last time we adjusted our ranged attack ranges			*/
							 
	; ---------------------------------------------------------------------
	; --- Init and Shutdown
	; ---------------------------------------------------------------------
	method Initialize()
	{
		This:Output[--- Routine: Kz Hunter 1.00]						/* show routine version info.								*/
		
		MobInfo:Initialize												/* initialzie and load old mob historical information		*/
	
		This:SetGUI
		This:SortAmmo
		
		if ${Toon.canCast[Track Hidden]} && !${Me.Buff[Track Hidden](exists)}
			Toon:CastSpell[Track Hidden]
			
		This:PetDefensive
		
		Bot:AddPulse["Class","Pulse",100,TRUE,TRUE]						/* call Pulse every 100 OB cycles							*/
	}

	method Shutdown()
	{
		MobInfo:Shutdown												/* cleanup and save mob information							*/
		This:SaveGUI
	}	
	
	 
	; ---------------------------------------------------------------------
	; called by OB every 100 cycles
	
	method Pulse()
	{
		; check to see if we have lost control of our pet via chained targets.  pet probally has a target, but we don't  
		if ${Me.InCombat} && !${This.chkPulseTarget}
			This:PetPassive												/* try to call our pet back									*/ 
		else
			This:PetDefensive											/* otherwise, prepare to fight								*/ 
	}
					
	member chkPulseTarget()
	{	
		if !${Target(exists)} || ${Target.Name.Equal[NULL]}			
			return FALSE
			
		if ${Target.Dead}
			return TRUE													/* np if the target is dead									*/
		
		if ${Target.InCombat} && ${Target.AttackingUnit.GUID.NotEqual[${Me.GUID}]} && ${MobGUID.NotEqual[${Target.GUID}]}
		{
			if !${Me.Pet(exists)}
				return FALSE			
				
			elseif ${Target.AttackingUnit.GUID.NotEqual[${Me.Pet.GUID}]}
				return FALSE
		}
		
		if !${Target.Attackable}
			return FALSE
			
		return TRUE
	}	

	
	; ---------------------------------------------------------------------
	; --- Rest SetUp
	; ---------------------------------------------------------------------

	member NeedRest()
	{
		if ${Mount.IsMounted}											/* don't try to rest if mounted								*/
			return FALSE
	
		if ${Me.InCombat}
			return FALSE												/* dont rest in combat										*/
		
		if ${Me.Pet(exists)} && ${Me.Pet.InCombat}
			return FALSE												/* dont rest in combat										*/
		 
		if ${Toon.Casting}
			return TRUE													/* reviving pet etc.										*/
			
		if ${Me.Buff[Resurrection Sickness](exists)}
			return TRUE													/* wait in rest if you have rez sickness					*/
		
		if !${Me.Sitting}
		{
			if ${Me.PctHPs} < ${Config.GetSlider[sldRestHP]}
				return TRUE												/* we are below our start rest threshold for health			*/
		
			if ${Me.PctMana} < ${Config.GetSlider[sldRestMana]}
				return TRUE												/* we are below our start rest threshold for Mana			*/
		}	
		else
		{
			if ${Me.PctHPs} < ${Config.GetSlider[sldStandHP]} && ${Me.Sitting}
				return TRUE												/* stay stitting until full health							*/ 
	
			if ${Me.PctMana} < ${Config.GetSlider[sldStandMana]} && ${Me.Sitting}
				return TRUE												/* stay stitting until full mana							*/ 
		}
		
		if ${This.PetDead}
			return TRUE													/* revive/call our pet										*/
						
		if ${Me.Pet(exists)}
		{
			if ${Me.Pet.Buff[Feed Pet Effect](exists)} && ${Me.Pet.PctHappiness} <= 99				
				return TRUE												/* rest while pet is eating									*/
		
			if ${Me.Pet.PctHappiness} <= ${FeedPetPct} && !${NoPetFood}
				return TRUE												/* feed pet if he is not happy and we have food				*/
							
			if ${Toon:canCast[Mend Pet]} && ${Me.Pet.PctHPs} <= ${MendPetPct}
				return TRUE												/* heal pet if he is injured								*/
		}
		
		if ${Config.GetSlider[sldUseBandage]} > 0 && !${Me.Buff[Recently Bandaged](exists)} && ${Tradeskills.CheckNeedBandages}
			return TRUE													/* keep at least one bandage								*/
				
		if ${Config.GetCheckbox[chkUseAspectCheetah]} && ${Me.PctMana} > 90 && (!${Me.Target(exists)} || ${Me.Target.Dead}) && ${Toon.canCast[Aspect of the Cheetah]} && !${Me.Buff[Aspect of the Cheetah](exists)}
			Toon:CastSpell[Aspect of the Cheetah]
			
		return FALSE													/* otherwise FALSE when we dont need rest					*/
	}
	
	method RestPulse()
	{
		CMovement:StopMovement            								/* ensure we aren't moving									*/
		
		if ${Toon.Casting}
			{
			if !${NeedCallPet}
				NeedCallPet:Set[TRUE]									/* we will start by trying to call our pet next time		*/
			
			return														/* allow previous casting to finish							*/
			}
	
		if ${Toon.canCast[Track Hidden]} && !${Me.Buff[Track Hidden](exists)}
			Toon:CastSpell[Track Hidden]								/* select a default tracking								*/
					      
		; --------------------------------------
		; call / rez our pet.  this is controlled by the received error messages
		if ${This.PetDead} && ${LastCallPetTime} < ${LavishScript.RunningTime} - 2000 && !${Me.Buff[Drink](exists)}
		{
			Toon:Standup
			
			if ${NeedCallPet}
				Toon:CastSpell[Call Pet]
				
			elseif ${Me.PctMana} > 60 
				Toon:CastSpell[Revive Pet]
				
			LastCallPetTime:Set[${LavishScript.RunningTime}]			/* last time we tried to call/revive our pet				*/
			return
		}
			 
		; --------------------------------------
		; heal our pet
		if !${NoPet} && !${This.PetDead} && ${Me.Pet.PctHPs} < ${MendPetPct} && !${Me.Pet.Buff[Mend Pet](exists)}
		{
			Toon:CastSpell[Mend Pet]									/* take care of our pet healing								*/
			return
		}
			    	
		; --------------------------------------
		; feed our pet
		if ${Me.Pet.Distance} < 9 && !${This.PetPoisoned} && ${Me.Pet.PctHappiness} <= ${FeedPetPct} && !${Me.Pet.Buff[Feed Pet Effect](exists)} && ${LastCallPetTime} < ${LavishScript.RunningTime} - 2000
		{
			if !${PetFeed} && ${bLastFeedPetTime} < ${LavishScript.RunningTime} - ${FeedPetTimer2}
			{
				if ${PetFood.Equal[NULL]}
					This:GetPetFood										/* try to find a new food for our pet						*/
					
				if ${PetFood.NotEqual[NULL]}
				{
					; This:Output["Try to feed our pet ${Item[${PetFood}].Name}."]
					LastFeedPetTime:Set[${LavishScript.RunningTime}]	/* last time we started trying to feed our pet				*/
					Toon:CastSpell[Feed Pet]
					PetFeed:Set[TRUE]
				}
			}
					               
			if !${NoPetFood} && ${PetFeed} && ${LastFeedPetTime} < ${LavishScript.RunningTime} - ${FeedPetTimer1}
			{
				Item[${PetFood}]:Use									/* try to feed this item to the pet							*/
				PetFeed:Set[FALSE]
			}
			return														/* wait till we have feed out pet							*/
		}
		if ${Me.Pet.Buff[Feed Pet Effect](exists)}
			PetFood:Set[NULL]
				
		; --------------------------------------
		; make our items
		
		if !${Me.Sitting} && ${Spell["First Aid"](exists)} && ${Config.GetSlider[sldUseBandage]} > 0 && ${Tradeskills.makeableBandage[2].NotEqual["NONE"]}
		{
			variable guidlist BandList
			BandList:Search[-items,-inventory,Bandage]
			
			if !${BandList.Count}
			{
				Tradeskills:CreateBandages[${Tradeskills.makeableBandage[2]}]
				return
			}
		}			
					   
		; --------------------------------------
		; take care of ourself
		if ${Config.GetCheckbox[chkUseScrolls]} && ${Toon.canUseScroll}
			Toon:UseScroll												/* use scrolls if we have any								*/
						  
		if ${Me.PctHPs} < ${Config.GetSlider[sldRestHP]}
		{			
			if ${Consumable.HasFood} && !${Me.Buff[Food](exists)}
			{
				Consumable:useFood										/* eat														*/
				Bot.RandomPause:Set[14]
				return
			}
			Toon:Sitdown												/* sit down if we need HP									*/
		}
		
		if ${Me.PctMana} < ${Config.GetSlider[sldRestMana]}
		{
			if ${Consumable.HasDrink} && !${Me.Buff[Drink](exists)}
			{
				Consumable:useDrink										/* drink													*/
				Bot.RandomPause:Set[14]
				return
			}
			Toon:Sitdown												/* sit down if we need MANA									*/
		}
		
		if ${Me.Sitting} && ${Toon.canCast[Shadowmeld]} && !${Me.Buff[Shadowmeld](exists)}
			Toon:CastSpell[Shadowmeld]									/* try to hide while we rest								*/
		
		if ${Me.Buff[Resurrection Sickness](exists)}
		{
			Toon:Sitdown                                                /* stupid rez sickness										*/
			return
		}
		
		This:SortAmmo													/* sort the ammo if needed									*/	
				  
		if ${Me.Sitting} && ${Me.PctHPs} >= ${Config.GetSlider[sldStandHP]} && ${Me.PctMana} >= ${Config.GetSlider[sldStandMana]}
			Toon:Standup                                                /*  stand up when we are done resting						*/
	}
	
					
	; ---------------------------------------------------------------------
	; --- Buff SetUp
	; ---------------------------------------------------------------------

	member NeedBuff()
	{
		if ${Mount.IsMounted}											/* don't try to buff if mounted								*/
			return FALSE
	
		if ${Me.Buff[Aspect of the Cheetah](exists)} && (!${Me.Target(exists)} ||  ${Me.Target.Dead})
			return FALSE												
		
		if ${MeAspect} == 4 && !${Me.Buff[Aspect of the Viper](exists)}
		{
			if ${Spell[Aspect of the Viper](exists)}
				return TRUE
			else
				MeAspect:Set[3]
		}
			
		; Never use Aspect of the Cheetah for combat buff.
		if ${MeAspect} == 3
			MeAspect:Set[2]
		
		if ${MeAspect} == 2 && !${Me.Buff[Aspect of the Hawk](exists)}
		{
			if ${Spell[Aspect of the Hawk](exists)}
				return TRUE
			else
				MeAspect:Set[1]
		}
		
		if ${MeAspect} == 1 && !${Me.Buff[Aspect of the Monkey](exists)}
		{
			if ${Spell[Aspect of the Monkey](exists)}
				return TRUE
			else
				MeAspect:Set[0]
		}
			
		return FALSE
	}
	
	method BuffPulse()
	{
;		CMovement:StopMovement             								/* ensure we aren't moving									*/
			
		Toon:Standup
		
		if !${Me.Pet(exists)} && !${Me.Buff[Aspect of the Monkey](exists)} && !${Spell[Aspect of the Monkey].Cooldown}
			Toon:CastSpell[Aspect of the Monkey]						/* if no pet, looks like we will melee anyway				*/
		
		elseif ${MeAspect} == 1 && !${Me.Buff[Aspect of the Monkey](exists)} && !${Spell[Aspect of the Monkey].Cooldown}
			Toon:CastSpell[Aspect of the Monkey]
			
		elseif ${MeAspect} == 2 && !${Me.Buff[Aspect of the Hawk](exists)} && !${Spell[Aspect of the Hawk].Cooldown} && ${Me.Pet(exists)}
			Toon:CastSpell[Aspect of the Hawk]
			
		elseif ${MeAspect} == 3 && !${Me.Buff[Aspect of the Cheetah](exists)} && !${Spell[Aspect of the Cheetah].Cooldown}
			Toon:CastSpell[Aspect of the Cheetah]
			
		elseif ${MeAspect} == 4 && !${Me.Buff[Aspect of the Viper](exists)} && !${Spell[Aspect of the Viper].Cooldown}
			Toon:CastSpell[Aspect of the Viper]
	}
	
					
	; ---------------------------------------------------------------------
	; --- Pull SetUp
	; ---------------------------------------------------------------------
	
	member NeedPullBuff()
	{
		Toon:Standup
			
		if ${MeAspect} == 1 && !${Me.Buff[Aspect of the Monkey](exists)} && !${Spell[Aspect of the Monkey].Cooldown}
			Toon:CastSpell[Aspect of the Monkey]
			
		if ${MeAspect} == 2 && !${Me.Buff[Aspect of the Hawk](exists)} && !${Spell[Aspect of the Hawk].Cooldown} && ${Me.Pet(exists)}
			Toon:CastSpell[Aspect of the Hawk]
			
		if ${MeAspect} == 3 && !${Me.Buff[Aspect of the Cheetah](exists)} && !${Spell[Aspect of the Cheetah].Cooldown}
			Toon:CastSpell[Aspect of the Cheetah]
			
		if ${MeAspect} == 4 && !${Me.Buff[Aspect of the Viper](exists)} && !${Spell[Aspect of the Viper].Cooldown}
			Toon:CastSpell[Aspect of the Viper]
			
		return FALSE
	}

	method PullBuffPulse()
	{
		This:BuffPulse
	}
	
	  
	; ---------------------------------------------------------------------
	; --- CombatBuff SetUp
	; ---------------------------------------------------------------------

	member NeedCombatBuff()
	{
		return FALSE
	}

	method CombatBuffPulse()
	{
		This:BuffPulse
	}
	
	  
	; ---------------------------------------------------------------------
	; --- Pull SetUp
	; ---------------------------------------------------------------------
		
	variable int PullBailOut = ${LavishScript.RunningTime}
	
	method PullPulse()
	{		
		if ${Toon.TargetIsNew}
		{
			; reset the pull timer on new targets	
			This.PullBailOut:Set[${This.InSeconds[${Config.GetSlider[sldPullBailOutTimer]}]}]
			This:KZDebug[2, "Pull Timer started ${Config.GetSlider[sldPullBailOutTimer]} -> ${LavishScript.RunningTime}..${This.PullBailOut}"]							/* blacklist target if timer exceeded						*/
		}		
		
		if ${This.PullBailOut} < ${LavishScript.RunningTime}
		{
			This:KZDebug[0, "Pull Timer Exceeded."]						/* blacklist target if timer exceeded						*/
			GlobalBlacklist:Insert[${Target.GUID},3600000]
			WoWScript ClearTarget()
			return
		}
		
		if !${Toon.ValidTarget[${Target.GUID}]}
		{
			; This:Output["I need a valid target"]						/* ensure we have a valid target							*/
			Toon:NeedTarget[1]			
			return
		}		
		
		if !${Toon.TargetIsBestTarget}
		{
			This:KZDebug[1, "Target is no longer best target, aquire new target."]	/* ensure our target is the best target			*/
			Toon:BestTarget
			return
		}
		
		Toon:Standup													/* make sure we are standing and facing the target			*/
		
		; --------------------------------------
		; move to attack range
		
		if ${This.ForceMelee} || (${Target.Distance} < ${This.MinRanged} && ${Target.Target.GUID.Equal[${Me.GUID}]}) || ${Target.Distance} < ${This.MaxMelee}
			CMovement:ToMelee											/* move to melee range										*/
		else
			CMovement:ToRanged											/* move to ranged attack range								*/
		
		if !${NoPet} && ${Config.GetCheckbox[chkSendPetk]} && (!${Me.Pet.InCombat} || ${Me.Pet.Target.GUID.NotEqual[${Me.Target.GUID}]})
			WoWScript PetAttack()										/* keep the pet on my target								*/
						
		; --------------------------------------
		; Do the the pull selection.
		if !${This.ForceMelee} && ${Target.Distance} > ${This.MinRanged} && ${Target.Distance} < ${This.MaxRanged}
		{
			; This:Output["Pull Shot: ${Config.GetCombo[cmbPullShot]}"]
			
			if ${Config.GetCheckbox[chkViperSting]} && ${Toon.canCast[Viper Sting]} && ${Me.Target.MaxMana} > 0 && ${Me.Target.PctMana} > 25
				Toon:CastSpell[Viper Sting]
						
			elseif ${MobInfo.chkCast[${Config.GetCombo[cmbPullShot]}]}
				Toon:CastSpell[${Config.GetCombo[cmbPullShot]}]
									 
			elseif ${MobInfo.chkCast[Concussive Shot]}
				Toon:CastSpell[Concussive Shot]
			
			elseif ${MobInfo.chkCast[Serpent Sting]}
				Toon:CastSpell[Serpent Sting]
				
			elseif ${MobInfo.chkCast[Arcane Shot]}
				Toon:CastSpell[Arcane Shot]
				
			elseif !${Me.Action[Auto Shot].AutoRepeat}
				Toon:CastSpell[Auto Shot]
		}
			
		if ${Target.Distance} < ${This.MaxMelee} && !${Me.Attacking}
			WoWScript AttackTarget()
			
		; --------------------------------------
		; other casts.
		if !${This.ForceMelee} && ${Config.GetCheckbox[chkUseHuntersMark]} && ${Target.Distance} > ${This.MinRanged} && !${Me.Target.Buff["Hunter's Mark"](exists)} && ${Spell[Hunter's Mark](exists)} && ${Me.Target.CreatureType.NotEqual[Totem]}
			Toon:CastSpell["Hunter's Mark"]
		
		if !${This.ForceMelee} && ${Toon.canCast[Rapid Fire]} && ${Me.Target.PctHPs} > 90
			Toon:CastSpell[Rapid Fire]
	}
	
	
	; ---------------------------------------------------------------------
	; --- Combat SetUp
	; ---------------------------------------------------------------------
	
	method AttackPulse()
	{
		variable guidlist Aggros										/* for finding the mobs we have								*/
		variable int MobAdds											/* count of adds											*/
		variable int TrinketCooldown									/* check the cooldown of our trinkets						*/
		variable string PotionName										/* name of any potion we are drinking						*/
	
		This:PetDefensive												/* keep pet in defensive mode during combat					*/
		
		if ${Toon.Casting}
			return														/* allow previous casting to finish							*/

		This:KZDebug[3, ">>>> Hunter Attack Pulse Start <<<<"]
	
		; --------------------------------------
		; playing dead?
		if ${Me.Buff[Feign Death](exists)} && ${LastFeignDeathTime} < ${LavishScript.RunningTime} - 2000
			return
		
		; --------------------------------------
		; prepare to continue combat and verify we have a good target
		
		Toon:Standup													/* no combat while sitting									*/
		
		if !${NoPet} && !${This.PetDead} && ${Me.Pet.PctHPs} < ${MendPetPct} && ${Toon.canCast[Mend Pet]} && !${Me.Pet.Buff[Mend Pet](exists)}
		{
			Toon:CastSpell[Mend Pet]									/* take care of our pet healing								*/
			return
		}
	
		if !${Toon.ValidTarget[${Target.GUID}]}
		{
			This:KZDebug[2, "AttackPulse: I need a valid target"]		/* ensure we have a vaild target							*/
			Toon:NeedTarget[1]			
			return
		}			

		if ${Movement.Speed}  && ${Target.GUID.NotEqual[${Targeting.TargetCollection.Get[1]}]} && ${Unit[${Targeting.TargetCollection.Get[1]}](exists)}
		{
			This:KZDebug[1, "AttackPulse: Getting a better target"]		/* ensure we have the best target							*/
			Target ${Targeting.TargetCollection.Get[1]}					/* adjust target while moving								*/
			return														/* lock target during most of combat						*/
		}
		
		; --------------------------------------
		if !${NoPet} && ${Config.GetCheckbox[chkSendPetk]} && (!${Me.Pet.InCombat} || ${Me.Pet.Target.GUID.NotEqual[${Me.Target.GUID}]})
			WoWScript PetAttack()										/* keep the pet on our target								*/
		
		; --------------------------------------
		; if we need health try to use bandages and potions.
		if ${Me.PctHPs} <= ${Config.GetSlider[sldUseBandage]} && ${Toon.canBandage}
		{				
			MobAdds:Set[${Toon.AggroWithin[30,TRUE]}]					/* get the number of mobs attacking me						*/
			if !${MobAdds}
			{
				This:KZDebug[2, "AttackPulse: Using Bandage in Combat."]
				Toon:Bandage											/* use bandag if we will not be interrupted					*/
				Bot.RandomPause:Set[24]
				WoWScript ClearTarget()
				return
			}
		}
						
		; if we need health, try to drink a potion
		if ${Me.PctHPs} <= ${Config.GetSlider[sldUsePot]} && ${Item[-inventory,"Healing Potion"](exists)}
		{
			PotionName:Set[${Item[-inventory,"Healing Potion"].Name}]	
			if ${Item[${PotionName}].Usable} && !${WoWScript["GetContainerItemCooldown(${Item[${PotionName}].Bag.Number}, ${Item[${PotionName}].Slot})", 2]}
			{
				Item[${PotionName}]:Use
				Bot.RandomPause:Set[14]
				return
			}
		}
		
		; try feign death				   
		if ${Me.PctHPs} <= ${Config.GetSlider[sldFeignDeath]} && ${Toon.canCast[Feign Death]}
		{
			Toon:CastSpell[Feign Death]
			LastFeignDeathTime:Set[${LavishScript.RunningTime}]
			return
		}
		
		; --------------------------------------
		; use our trinkets
		
		if ${Me.Equip[13](exists)}
		{
			TrinketCooldown:Set[${WoWScript[GetInventoryItemCooldown("player"\, 13)]}]
			if !${TrinketCooldown}
			{
				Me.Equip[13]:Use
				return
			}
		}
		
		if ${Me.Equip[14](exists)}
		{
			TrinketCooldown:Set[${WoWScript[GetInventoryItemCooldown("player"\, 14)]}]
			if !${TrinketCooldown}
			{
				Me.Equip[14]:Use	
				return
			}
		}
		
		; --------------------------------------
		; Place the freezing trap if we are facing our desired mob
		if ${PlacingFreezingTrap}
			{
			if !${ISXWoW.Facing}
				{
				Toon:CastSpell[Freezing Trap]
				PlacingFreezingTrap:Set[FALSE]
				}
			return
			}
				   
		; ----------------------------------------------------------------------
		; face target and move to attack range.		
		
		if ${This.ForceMelee}
			CMovement:ToMelee											/* move to melee range										*/
 
		elseif ${Target.Distance} < ${This.MinRanged} && ${Target.Target.GUID.Equal[${Me.GUID}]}
			CMovement:ToMelee											/* we will need to melee for a while						*/
			
		else
			CMovement:ToRanged											/* move to a good ranged attack location					*/

		; ----------------------------------------------------------------------
		; try to do a little damage
		
		if !${Config.GetCheckbox[chkSaveIntimidation]} && ${Toon.canCast[Intimidation]} && ${Me.Target.PctHPs} > 40 && ${Target.Target.GUID.Equal[${Me.GUID}]}
			Toon:CastSpell[Intimidation]
		
		if !${Config.GetCheckbox[chkSaveBestialWrath]} && ${Toon.canCast[Bestial Wrath]} && ${Me.Target.PctHPs} > 90
			Toon:CastSpell[Bestial Wrath]

		if !${This.ForceMelee} && ${Config.GetCheckbox[chkUseHuntersMark]} && ${Target.Distance} > ${This.MinRanged} && !${Me.Target.Buff["Hunter's Mark"](exists)} && ${Spell[Hunter's Mark](exists)} && ${Me.Target.CreatureType.NotEqual[Totem]}
			Toon:CastSpell["Hunter's Mark"]
		
		; Ranged Attack.
		if !${This.ForceMelee} && ${Target.Distance} > ${This.MinRanged} && ${Target.Distance} < ${This.MaxRanged}
		{
			This:BuffPulse
			
			if ${Toon.canCast[Freezing Trap]}
			{
				declare MobList guidlist local
				MobList:Search[-units,-alive,-nonpvp,-nonfriendly,-nocritters,-aggro,-notflying,-attackable,-nearest,-range 0-5]
				if ${MobList.Count}
				{
					CMovement:FaceXYZ[${MobList.Object[1].X},${MobList.Object[1].Y},${MobList.Object[1].Z}]
					PlacingFreezingTrap:Set[TRUE]
					return
				}
			}
			
			if !${Me.Target.Buff[Viper Sting](exists)} && !${Me.Target.Buff[Serpent Sting](exists)} && !${Me.Target.Buff[Scorpid Sting](exists)} && ${Me.Target.PctHPs} > 30
				{
					if ${MobInfo.chkCast[${Config.GetCombo[cmbStingType]}]}
						Toon:CastSpell[${Config.GetCombo[cmbStingType]}]
									 
					elseif ${MobInfo.chkCast[Serpent Sting]}
						Toon:CastSpell[Serpent Sting]
				}
				
			if ${This.HinderRunners} && ${MobInfo.chkCast[Concussive Shot]} && !${Me.Target.Buff[Concussive Shot](exists)}
				Toon:CastSpell[Concussive Shot]
										
			elseif ${MobInfo.chkCast[Arcane Shot]} && !${This.ConserveMana}
				Toon:CastSpell[Arcane Shot]
				
			elseif ${Toon.canCast[Steady Shot]} && !${This.ConserveMana}
				Toon:CastSpell[Steady Shot]
				
			elseif !${Me.Action[Auto Shot].AutoRepeat}
				Toon:CastSpell[Auto Shot]
		}
								
		; Melee Attack.
		elseif ${Target.Distance} < ${This.MaxMelee}
		{
			if ${Toon.canCast[Aspect of the Monkey]} && !${Me.Buff[Aspect of the Monkey](exists)}
			{
				if ${This.ForceMelee} || !${Me.Pet(exists)}
				{
					Toon:CastSpell[Aspect of the Monkey]
					return
				}
				else
				{
					declare MobList guidlist local
					MobList:Search[-units,-alive,-nonpvp,-nonfriendly,-nocritters,-aggro,-notflying,-attackable,-nearest,-range 0-5]
					if ${MobList.Count}	> 2
					{
						Toon:CastSpell[Aspect of the Monkey]
						return
					}
				}
			}

			if ${MobInfo.chkCast[Immolation Trap]} && ${Me.Target.PctHPs} > 50
				{
				CMovement:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
				Toon:CastSpell[Immolation Trap]
				}
										
			elseif ${Toon.canCast[Raptor Strike]} && ${Me.PctMana} > ${Config.GetSlider[sldConserveMana]}
				Toon:CastSpell[Raptor Strike]
	
			elseif ${This.HinderRunners} && ${MobInfo.chkCast[Wing Clip]} && !${Me.Target.Buff[Wing Clip](exists)}
				Toon:CastSpell[Wing Clip]
										
			elseif ${Toon.canCast[Disengage]} && ${Target.Target.GUID.Equal[${Me.GUID}]}
				Toon:CastSpell[Disengage]
										
			elseif ${MobInfo.chkCast[Intimidation]} && ${Me.Action[Intimidation].Usable}
				Toon:CastSpell[Intimidation]
				
			elseif ${MobInfo.chkCast[Mongoose Bite]} && ${Me.Action[Mongoose Bite].Usable}
				Toon:CastSpell[Mongoose Bite]
										
			elseif !${Me.Attacking}
				WoWScript AttackTarget()
		}
	}

				 
	; ---------------------------------------------------------------------
	; --- Support operations
	; ---------------------------------------------------------------------

	; ---------------------------------------------------------------------
	; Display the message if level is low enough
	method KZDebug(int Lvl, string Msg)
	{
		if ${Lvl} <= KZ_MSGLVL
			This:Output[${Msg}]											/* show the enabled message									*/
	}
		
	; ---------------------------------------------------------------------
	; test if we should try to hinder runners
	member HinderRunners()
	{
		if ${MobInfo.chkRunner} && ${Me.Target.PctHPs} <= ${Config.GetSlider[sldHinderRunners]}
			return TRUE
			
		return FALSE
	}
						   
	; ---------------------------------------------------------------------
	; test if we should conserve mana
	member ConserveMana()
	{
		if ${Me.PctMana} > ${Config.GetSlider[sldConserveMana]} && (${Me.PctHPs} < ${Config.GetSlider[sldConserveManaHealth]} || ${Me.Pet.PctHPs} < ${Config.GetSlider[sldConserveManaPetHealth]})
			return FALSE												/* we should use the spell									*/
		
		return TRUE														/* we should conserve mana									*/
	}
	
	; ---------------------------------------------------------------------
	; test if we should only do melee combat
	member ForceMelee()
	{
		if ${OutOfAmmo} || !${Config.GetCheckbox[chkUseRangedAttacks]}
			return TRUE
			
		return FALSE
	}

	; ---------------------------------------------------------------------
	; Set the mode for our pet
	method PetPassive()
	{
		if !${PetModePassive}
			WoWScript PetPassiveMode()									/* set our pet to passive mode								*/ 
		PetModePassive:Set[TRUE]
	}
	
	method PetDefensive()
	{
		if ${PetModePassive}
			WoWScript PetDefensiveMode() 
		PetModePassive:Set[FALSE]
	}
	
	; ---------------------------------------------------------------------
	; test if our pet is dead or missing
	member PetDead()
	{
		if ${NoPet}	|| !${Spell[Call Pet](exists)} 
			return FALSE												/* playing without a pet									*/
			
		if (${Me.Pet(exists)} && ${Me.Pet.Dead}) || !${Me.Pet(exists)} || !${Me.Pet.PctHPs}
			return TRUE
			
		return FALSE
	}
	
	; ---------------------------------------------------------------------
	; cast a spell from the pet action bar
	method PetCastSpell(string PetSpell)
	{
		variable int Idx = 1
		do
		{
			if ${WoWScript[GetPetActionInfo(${Idx})].Equal[${PetSpell}]}
				WoWScript CastPetAction(${Idx})
		}
		while ${WoWScript[GetPetActionInfo(${Idx:Inc})](exists)}
	}
	
	; ---------------------------------------------------------------------
	; test if our pet is poisoned
	member PetPoisoned()
	{
		variable int Index = 1
		do
		{
			if ${Me.Pet.Buff[${Index}].DispelType.Equal[Poison]}
				return TRUE
			Index:Inc
		}
		while ${Me.Pet.Buff[${Index}](exists)}
		return FALSE
	}
		     
	; ---------------------------------------------------------------------
	; scan each bag item starting with top of rightmost bag to search for pet food.
	method GetPetFood()
	{
		variable int Index = 0
		variable int SpotIndex 

		PetFood:Set[NULL]												/* clear any old food selection								*/
		
		do 
		{ 
			SpotIndex:Set[1] 
			do 
			{ 
				if ${Me.Bag[${Index}].Item[${SpotIndex}](exists)} && !${This.PetFoodBad.Contains[${Me.Bag[${Index}].Item[${SpotIndex}].Name}]}
					if ${Me.Bag[${Index}].Item[${SpotIndex}].SubType.Equal[Consumable]} || (${Me.Bag[${Index}].Item[${SpotIndex}].SubType.Equal[Trade Goods]} && ( ${Me.Bag[${Index}].Item[${SpotIndex}].Name.Find[" meat"]} || ${Me.Bag[${Index}].Item[${SpotIndex}].Name.Find[" flank"]} || ${Me.Bag[${Index}].Item[${SpotIndex}].Name.Find[" leg"]}))
					{
						NoPetFood:Set[FALSE]							/* try using newly found item for food						*/
						PetFood:Set[${Me.Bag[${Index}].Item[${SpotIndex}].GUID}]
						This:Output["GetPetFood: Trying item number ${Index},${SpotIndex}:${Item[${PetFood}].Name} Type:${Item[${PetFood}].SubType}"]
						return
					}
			} 
			while ${SpotIndex:Inc} <= ${Me.Bag[${Index}].Slots} 
		} 
		while ${Me.Bag[${Index:Inc}](exists)} 
	
		NoPetFood:Set[TRUE]												/* don't lockup looking for mising food						*/
	}
	
	; ---------------------------------------------------------------------
	; try to move spare ammo to quiver or ammo pouch
	method SortAmmo() 
	{ 
		variable int ContainerIndex = 0 
		variable int Index 
		variable int SpotIndex 
		variable int EmptySpot = 0 
		variable int ApiIndex = 19 
		
		; serarch for a quiver or ammo pouch
		Index:Set[1] 
		do 
		{ 
			if ${Me.Bag[${Index}](exists)} && (${Me.Bag[${Index}].Name.Find["Quiver"]} || ${Me.Bag[${Index}].Name.Find["Ammo Pouch"]})
				ContainerIndex:Set[${Index}] 
		} 
		while ${Me.Bag[${Index:Inc}](exists)} 
	
		; if we have a quiver or ammo pouch, try to fill it
		if ${ContainerIndex} && ${Me.Bag[${ContainerIndex}].EmptySlots} > 0 
		{ 
			Index:Set[1] 
			do 
			{ 
				if !${Me.Bag[${ContainerIndex}].Item[${Index}].Name(exists)} 
					EmptySpot:Set[${Index}] 
			} 
			while ${Index:Inc} <= ${Me.Bag[${ContainerIndex}].Slots} 
		   
			if ${EmptySpot} 
			{ 
				Index:Set[0] 
				do 
				{ 
					if ${Index} != ${ContainerIndex} 
					{ 
						SpotIndex:Set[1] 
						do 
						{ 
							if ${Me.Bag[${Index}].Item[${SpotIndex}].Name.Find[" Arrow"]} || ${Me.Bag[${Index}].Item[${SpotIndex}].Name.Find[" Shot"]} || ${Me.Bag[${Index}].Item[${SpotIndex}].Name.Find[" Slugs"]}
							{ 
								Me.Bag[${Index}].Item[${SpotIndex}]:PickUp 
								This:Timeout
								ApiIndex:Set[${Math.Calc[${ApiIndex} + ${ContainerIndex}]}] 
								WoWScript "PutItemInBag(${ApiIndex})" 
								return 
							} 
						} 
						while ${SpotIndex:Inc} <= ${Me.Bag[${Index}].Slots} 
					} 
				} 
				while ${Me.Bag[${Index:Inc}](exists)} 
			} 
		} 
	} 
				 
	; ---------------------------------------------------------------------
	; try to find ammo to use
	method UseAmmo() 
	{ 
		variable int Index = 0
		variable int SpotIndex 
		
		OutOfAmmo:Set[TRUE]												/* we are out of ammo, switch to melee only					*/
		do 
		{ 
			SpotIndex:Set[1] 
			do 
			{ 
				if ${Me.Bag[${Index}].Item[${SpotIndex}].Name.Find[" Arrow"]} || ${Me.Bag[${Index}].Item[${SpotIndex}].Name.Find[" Shot"]} || ${Me.Bag[${Index}].Item[${SpotIndex}].Name.Find[" Slugs"]}
				{ 
					Me.Bag[${Index}].Item[${SpotIndex}]:Use				/* start using this ammo									*/ 
					OutOfAmmo:Set[FALSE]	
					return 
				} 
			} 
			while ${SpotIndex:Inc} <= ${Me.Bag[${Index}].Slots} 
		} 
		while ${Me.Bag[${Index:Inc}](exists)} 
	} 
						
	; ---------------------------------------------------------------------
	; --- Event and Message Hooking 
	; ---------------------------------------------------------------------

	variable bool needUIHook = TRUE
	method UIErrorMessage(string Id, string Msg)
	{
		; This:Output["UIErrorMessage received" ${Id}:${Msg}]
		
		if ${Msg.Find[You are too far away]} && !${Bot.PauseFlag} && !${Movement.Speed}
			CMovement:MoveForward
			
		elseif ${Msg.Find[Out of range]} && !${Bot.PauseFlag} && !${Movement.Speed}
			{
			if ${Target.Distance} > ${This.MinRanged} && ${This.MaxRanged} > 35 && !${CMovement.isFacingAway} && ${RangeAdjustTime} < ${LavishScript.RunningTime} - 5000
				{
				UIElement[sldMaxRanged@Combat@Pages@ClassGUI]:SetValue[${Math.Calc[(${Target.Distance} - 25 - 0.1) * 10]}]
				if ${This.MaxRanged} < 35
					UIElement[sldMaxRanged@Combat@Pages@ClassGUI]:SetValue[100]	/* reset max range to 35							*/					
				
				This:Output["Adjusting the max range setting to ${This.MaxRanged}"]
				}
			RangeAdjustTime:Set[${LavishScript.RunningTime}]
			CMovement:MoveForward
			}
			
		elseif ${Msg.Find[Target too close]} && !${Bot.PauseFlag} && !${Movement.Speed}
			{
			if ${Target.Distance} >= ${This.MinRanged} && ${This.MinRanged} < 20 && ${RangeAdjustTime} < ${LavishScript.RunningTime} - 5000
				{
				UIElement[sldMinRanged@Combat@Pages@ClassGUI]:SetValue[${Math.Calc[(${Target.Distance} - 12 + 0.1) * 10]}]
				if ${This.MinRanged} > 14
					UIElement[sldMinRanged@Combat@Pages@ClassGUI]:SetValue[20]	/* reset min range to 14							*/					
				
				This:Output["Adjusting the min range setting to ${This.MinRanged}"]
				}
			RangeAdjustTime:Set[${LavishScript.RunningTime}]
			CMovement:MoveBackward
			}
			
		elseif ${Msg.Find[You are facing the wrong way]} && !${Bot.PauseFlag} && !${Movement.Speed}
			CMovement:MoveBackward
			
		elseif ${Msg.Find[You can't mount here]} && !${Bot.PauseFlag} && !${Movement.Speed}
			CMovement:MoveForward
			
		elseif ${Msg.Find[Target not in line of sight]} && !${Bot.PauseFlag}
		{
			GlobalBlacklist:Insert[${Target.GUID},3600000]
			WoWScript ClearTarget()
		}
			
		elseif ${Msg.Find[Your pet doesn't like that food]}	|| ${Msg.Find[That food's level is not high enough for your pet]} || ${Msg.Find[That item is not a valid target]}
		{
			if ${PetFood.NotEqual[NULL]} && !${This.PetFoodBad.Contains[${Item[${PetFood}].Name}]}
				This.PetFoodBad:Add[${Item[${PetFood}].Name}]			/* add this to the list of foods our pet will not eat		*/
			PetFood:Set[NULL]
		}
				
;		elseif ${Msg.Find[You must be standing to do that]}
;			Toon:Standup												/* we will need to stand up									*/
		
		elseif ${Msg.Find[Can't attack while dead]}
			NeedCallPet:Set[FALSE]										/* we will need to use Revive Pet							*/
		
		elseif ${Msg.Find[You already control a summoned creature]}
			NeedCallPet:Set[FALSE]										/* we will need to use Revive Pet							*/
		
		elseif ${Msg.Find[Your pet is dead]}
			NeedCallPet:Set[FALSE]										/* we will need to use Revive Pet							*/
		
		elseif ${Msg.Find[Your pet is not dead]}
			NeedCallPet:Set[TRUE]										/* we need to use Call Pet									*/
			
		elseif ${Msg.Find[You do not have a pet to summon]}
			NoPet:Set[TRUE]
			
		elseif ${Msg.Find[Ammo needs to be in]}
			This:UseAmmo												/* try to find some ammo to use								*/
	}	
	
;	variable bool needCombatHook = TRUE
;	method CombatEvent(string unitID, string unitAction, string isCrit, string amtDamage, string damageType)
;	{
;		; check args and perform action
;	}
	
	; ---------------------------------------------------------------------
	; --- GUI SetUp
	; ---------------------------------------------------------------------
	
	method SetGUI()
	{
		variable string uniqueToon = "${Me.Name}:${Me.Class}:${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}"
	   
		; Main Page															  
		Config:SetSlider[${uniqueToon},"sldRestHP","sldRestHP@Main@Pages@ClassGUI",60]
		Config:SetSlider[${uniqueToon},"sldRestMana","sldRestMana@Main@Pages@ClassGUI",60]
		Config:SetSlider[${uniqueToon},"sldStandHP","sldStandHp@Main@Pages@ClassGUI",90]
		Config:SetSlider[${uniqueToon},"sldStandMana","sldStandMana@Main@Pages@ClassGUI",90]
		Config:SetSlider[${uniqueToon},"sldUsePot","sldUsePot@Main@Pages@ClassGUI",20]
		Config:SetSlider[${uniqueToon},"sldUseBandage","sldUseBandage@Main@Pages@ClassGUI",60]
		Config:SetSlider[${uniqueToon},"sldFeignDeath","sldFeignDeath@Main@Pages@ClassGUI",50]
		Config:SetCheckBox[${uniqueToon},"chkUseScrolls","chkUseScrolls@Main@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseAspectCheetah","chkUseAspectCheetah@Main@Pages@ClassGUI",TRUE]
	   
		; Pull Page															  
		Config:SetSlider[${uniqueToon},"sldPullBailOutTimer","sldPullBailOutTimer@Pull@Pages@ClassGUI",60]   
		Config:SetCheckBox[${uniqueToon},"chkUseRangedAttacks","chkUseRangedAttacks@Pull@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkUseHuntersMark","chkUseHuntersMark@Pull@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkSendPetk","chkSendPetk@Pull@Pages@ClassGUI",TRUE]
		Config:SetCheckBox[${uniqueToon},"chkViperSting","chkViperSting@Pull@Pages@ClassGUI",TRUE]
		Config:SetCombo[${uniqueToon},"cmbPullShot","cmbPullShot@Pull@Pages@ClassGUI"]		
		
		; Combat Page															  
		Config:SetSlider[${uniqueToon},"sldConserveMana","sldConserveMana@Combat@Pages@ClassGUI",60]   
		Config:SetSlider[${uniqueToon},"sldConserveManaHealth","sldConserveManaHealth@Combat@Pages@ClassGUI",50]   
		Config:SetSlider[${uniqueToon},"sldConserveManaPetHealth","sldConserveManaPetHealth@Combat@Pages@ClassGUI",30]   
		Config:SetCombo[${uniqueToon},"cmbStingType","cmbStingType@Combat@Pages@ClassGUI"]		
		Config:SetSlider[${uniqueToon},"sldHinderRunners","sldHinderRunners@Combat@Pages@ClassGUI",15]   
		Config:SetCheckBox[${uniqueToon},"chkSaveIntimidation","chkSaveIntimidation@Combat@Pages@ClassGUI",FALSE]
		Config:SetCheckBox[${uniqueToon},"chkSaveBestialWrath","chkSaveBestialWrath@Combat@Pages@ClassGUI",FALSE]
		Config:SetSlider[${uniqueToon},"sldMinMelee","sldMinMelee@Combat@Pages@ClassGUI",9]   
		Config:SetSlider[${uniqueToon},"sldMaxMelee","sldMaxMelee@Combat@Pages@ClassGUI",29]   
		Config:SetSlider[${uniqueToon},"sldMinRanged","sldMinRanged@Combat@Pages@ClassGUI",5]   
		Config:SetSlider[${uniqueToon},"sldMaxRanged","sldMaxRanged@Combat@Pages@ClassGUI",150]   
	}
	
	method SaveGUI()
	{
		variable string uniqueToon = "${Me.Name}:${Me.Class}:${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}"
	   
		; Main Page															  
		Config:SaveSlider[${uniqueToon},"sldRestHP"]
		Config:SaveSlider[${uniqueToon},"sldRestMana"]
		Config:SaveSlider[${uniqueToon},"sldStandHP"]
		Config:SaveSlider[${uniqueToon},"sldStandMana"]
		Config:SaveSlider[${uniqueToon},"sldUsePot"]
		Config:SaveSlider[${uniqueToon},"sldUseBandage"]
		Config:SaveSlider[${uniqueToon},"sldFeignDeath"]
		Config:SaveCheckBox[${uniqueToon},"chkUseScrolls"]
		Config:SaveCheckBox[${uniqueToon},"chkUseAspectCheetah"]

		; Pull Page															  
		Config:SaveSlider[${uniqueToon},"sldPullBailOutTimer"]	   
		Config:SaveCheckBox[${uniqueToon},"chkUseRangedAttacks"]
		Config:SaveCheckBox[${uniqueToon},"chkUseHuntersMark"]
		Config:SaveCheckBox[${uniqueToon},"chkSendPetk"]
		Config:SaveCheckBox[${uniqueToon},"chkViperSting"]
		Config:SaveCombo[${uniqueToon},"cmbPullShot"]
		
		; Combat Page															  
		Config:SaveSlider[${uniqueToon},"sldConserveMana"]	   
		Config:SaveSlider[${uniqueToon},"sldConserveManaHealth"]	   
		Config:SaveSlider[${uniqueToon},"sldConserveManaPetHealth"]	   
		Config:SaveCombo[${uniqueToon},"cmbStingType"]
		Config:SaveSlider[${uniqueToon},"sldHinderRunners"]	   
		Config:SaveCheckBox[${uniqueToon},"chkSaveIntimidation"]
		Config:SaveCheckBox[${uniqueToon},"chkSaveBestialWrath"]
		Config:SaveSlider[${uniqueToon},"sldMinMelee"]	   
		Config:SaveSlider[${uniqueToon},"sldMaxMelee"]	   
		Config:SaveSlider[${uniqueToon},"sldMinRanged"]	   
		Config:SaveSlider[${uniqueToon},"sldMaxRanged"]	   
	} 
	
	; ---------------------------------------------------------------------
	; ---------------------------------------------------------------------
	; Range Settings
	
	member MinMelee()
	{
		return ${Math.Calc[${Config.GetSlider[sldMinMelee]} / 10 + 0]}		/* range of 0.0 to 2.0									*/
	}
	
	member MaxMelee()
	{
		if ${Movement.Speed} && (${CMovement.isFacingAway} || ${MobInfo.chkRunner})
			return ${Math.Calc[${This.MinMelee} + 1]}						/* mob may be running, stay close						*/
		
		return ${Math.Calc[${Config.GetSlider[sldMaxMelee]} / 10 + 3]}		/* range of 3.0 to 5.0									*/
	}
	
	member MinRanged()
	{
		 return ${Math.Calc[ ${Config.GetSlider[sldMinRanged]} / 10 + 12]}	/* range of 12.0 to 20.0								*/
	}
	
	member MaxRanged()
	{
		if ${Movement.Speed} && (${CMovement.isFacingAway} || ${MobInfo.chkRunner})
			return ${Math.Calc[${This.MinRanged} + 10]}						/* mob may be running, stay close						*/
		
		return ${Math.Calc[${Config.GetSlider[sldMaxRanged]} / 10 + 25]}	/* range of 25.0 to 45.0								*/
	}
}

; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
