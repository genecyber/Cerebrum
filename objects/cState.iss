;----- *** GLOBAL ***
#define CB_IDLE 0
#define CB_ASSIST_IDLE 2000
#define CB_PARTY_IDLE 3000


;----- *** MAIN ***
#define CB_DEAD 1001
#define CB_TOON 1002
#define CB_NPC 1003
#define CB_ITEM 1004
#define CB_LOOT 1005
#define CB_QUEST 1006
#define CB_ROAM 1007

#define MAIN_STATE_START 1001
#define MAIN_STATE_END 1007

;----- *** ASSIST MODE ***
; no NPC or QUEST or ITEM, replace ROAM with ASSIST
#define CB_DEAD_ASSIST 2001
#define CB_TOON_ASSIST 2002
#define CB_LOOT_ASSIST 2003
#define CB_ASSIST 2004

#define ASSIST_STATE_START 2001
#define ASSIST_STATE_END 2004

;----- *** PARTY MODE ***
#define CB_DEAD_PARTY 3001
#define CB_TOON_PARTY 3002
#define CB_NPC_PARTY 3003
#define CB_ITEM_PARTY 3004
#define CB_LOOT_PARTY 3005
#define CB_QUEST_PARTY 3006
#define CB_ROAM_PARTY 3007

#define CB_PARTY_REST 3100
#define CB_FOLLOW_LEADER 3102
#define CB_PARTYHEAL 3103
#define CB_PARTYBUFF 3104
#define CB_PARTYREZ 3105
#define CB_PARTYCURE 3106
#define CB_CROWDCONTROL 3107

#define PARTY_STATE_START 3001
#define PARTY_STATE_END 3007

;----- DEAD
#define CB_RELEASE 101
#define CB_DEADMOVE 102
#define CB_USE_SPIRITHEALER 103
#define CB_SPIRITHEALER 104
#define CB_SAFE_RES 105
#define CB_REVIVE_CORPSE 106
#define CB_DEAD_WAIT 107
#define CB_DEAD_FUCKED 108
#define CB_DEAD_MOREGOSSIP 109
#define CB_CLASS_DEAD 110

;----- TOON
#define CB_COMBAT_BUFF 201
#define CB_COMBAT 202
#define CB_COMBAT_IDLE 203
#define CB_BUFF 204
#define CB_REST 205
#define CB_MOVETO_PULL 206
#define CB_PULL_BUFF 207
#define CB_PULL 208
#define CB_PULL_WAIT 209
#define CB_CASTING 210
#define CB_CASTING_WAIT 211
#define CB_ACT_HUMAN 212
#define CB_COMBAT_CLASS_IDLE 213
#define CB_FLEE 214
#define CB_FLEE_WAIT 215
#define CB_TOON_WAIT 216

;----- NPC Sub State Name
#define CB_USE_NPC 301
#define CB_MOREGOSSIP 302
#define CB_TAKE_FLIGHT 303
#define CB_REPAIR 304
#define CB_SELL 305
#define CB_TRAINER 306
#define CB_AUCTION 307
#define CB_NPC_WAIT 308
#define CB_NPC_MOVE 309
#define CB_LOGOUT 310
#define CB_START_HEARTH 311
#define CB_HEARTHING 312
#define CB_RESTOCK 313
#define CB_MULE 314
#define CB_NPC_GETTING_READY 315
#define CB_HEARTH_GETTING_READY 316
#define CB_LEARN_FLIGHT 317

;----- TRADESKILL (in NPC and takes place b4 SELL)
#define CB_TRADESKILL_MAKE 320
#define CB_TRADESKILL_BUY 321
#define CB_TRADESKILL_MOVE 322
#define CB_TRADESKILL_WAIT 323

;----- LOOT
#define CB_USE_LOOT 401
#define CB_SKIN_CORPSE 402
#define CB_LOOT_CORPSE 403
#define CB_LOOT_HERB 404
#define CB_LOOT_ORE 405
#define CB_LOOTALL 406
#define CB_CLOSE_LOOT 407
#define CB_LOOT_WAIT 408
#define CB_LOOT_MOVE 409
#define CB_LOOT_GETTING_READY 410
#define CB_OPENING 411
#define CB_FISHING 412


;----- ITEM
#define CB_EQUIP_BAG 501
#define CB_EQUIP_GEAR 502
#define CB_EQUIP_WAIT 503

;----- QUEST
#define CB_QUEST_START 510
#define CB_QUEST_END 511
#define CB_QUEST_PLAY 512
#define CB_QUEST_EVENT 513
#define CB_QUEST_LOCATION 514
#define CB_QUEST_OVERRIDE 515

;----- ROAM
#define CB_MOUNT 601
#define CB_DISMOUNT 602
#define CB_LEVELUP 603
#define CB_NEED_PULL 604
#define CB_NEED_VENDOR 605
#define CB_NEED_TRAINER 606
#define CB_NEED_MAILBOX 607
#define CB_NEED_BANK 608
#define CB_NEED_AH 609
#define CB_NEED_FP 530
#define CB_MOVETO_MOB 610
#define CB_ROAMING 611
#define CB_ROAM_TO_NODE 612

#define CB_FISHING_EXTENSION Autofish
#define CB_FISHING_POLE Fishing Pole


objectdef cState inherits cBase
{
	variable int CurrentState = CB_IDLE
	variable int CurrentSubState = CB_IDLE
	
	variable string MovingToLoc = "FALSE"
	variable int JustRes = ${LavishScript.RunningTime}
	variable int FindSpot = ${LavishScript.RunningTime}
	
	variable int LagTime = 10000
	
	; logout settings
	variable bool LogoutOnTimer = FALSE
	variable int LogOutIn = 0
	variable int LogOutInMS = 0
	variable bool LogOutOnLevel = FALSE
	variable int LogOutLevel = 0
	variable int LastLogoutChange = 0
	
	; ends hotspot iteration by iterating to next valid location
	variable int Location_Failed_Count = 0
	variable int Location_Failed_Timer = 0
		
	;Mail
	variable int MailClickable = ${LavishScript.RunningTime}	

	variable int DEADState_Wait_Until = 0
	variable int DEADState_Release_Wait_Until_Timeout = 10
	variable int DEADState_Interact_Wait_Until_Timeout = 4

	variable int ITEMState_Equip_Wait_Until = 0
	variable int ITEMState_Equip_Wait_Until_Timeout = 2

	variable int TOONState_Pull_Wait_Until = 0
	variable int TOONState_Pull_Wait_Until_Timeout = 4
	variable int TOONState_Casting_Wait_Until = 0
	variable int TOONState_Casting_Until_Timeout = 2

	variable int TOONState_General_Wait_Until = 0
	variable int TOONState_General_Until_Timeout = 5
	
	variable int LOOTState_Loot_Wait_Until = 0
	variable int LOOTState_Loot_Wait_Until_Timeout = 1
	variable int LOOTState_Loot_Wait_After_Until_Timeout = 2
	
	variable int LOOTState_Skip_Scans = 0
	variable int LOOTState_Skip_Scans_Timeout = 10
	
	variable int TOONState_Flee_Wait_Until = 0
	variable int TOONState_Last_Flee_Time = 0

	variable int LOOTState_Loot_Fishing_Until = 0
	variable int LOOTState_Loot_Fishing_Timeout = 30
	variable string MainHandBeforeFishing = NULL
	variable string OffHandBeforeFishing = NULL
	
	
	variable int NPCState_NPC_Wait_Until = 0
	variable int NPCState_Hearthstone_Wait_Until_Timeout = 10
	variable int NPCState_Use_Wait_Until_Timeout = 10
	variable int NPCState_Interact_Wait_Until_Timeout = 2
	

	method Initialize()
	{

	}

	method ShutDown()
	{

	}

	member StateName(int StateNumber)
	{
		switch ${StateNumber}
		{		
			;----- GLOBAL State Name
			case CB_IDLE 
				return "IDLE"
			case CB_ASSIST_IDLE
				return "ASSIST IDLE"

			;----- MAIN State Name
			case CB_DEAD 
				return "DEAD"
			case CB_TOON 
				return "TOON"
			case CB_NPC 
				return "NPC"
			case CB_ITEM 
				return "ITEM"
			case CB_LOOT 
				return "LOOT"
			case CB_QUEST 
				return "QUEST"			
			case CB_ROAM 
				return "ROAM"
			case CB_DEAD_WAIT
				return "DEAD WAITING"
			case CB_DEAD_MOREGOSSIP
				return "MOREGOSSIP"

			;----- ASSIST State Name
			case CB_DEAD_ASSIST
				return "DEAD"				
			case CB_TOON_ASSIST
				return "TOON"				
			case CB_LOOT_ASSIST
				return "LOOT_ASSIST"				
			case CB_ASSIST
				return "ASSIST"

			;----- PARTY State Name			
			case CB_DEAD_PARTY
				return "DEAD_PARTY"
			case CB_TOON_PARTY
				return "TOON_PARTY"			
			case CB_NPC_PARTY
				return "NPC_PARTY"		
			case CB_ITEM_PARTY
				return "ITEM_PARTY"			
			case CB_LOOT_PARTY
				return "LOOT_PARTY"			
			case CB_QUEST_PARTY
				return "QUEST_PARTY"	
			case CB_ROAM_PARTY
				return "ROAM_PARTY"
			case CB_PARTYHEAL
				return "HEALING GROUP"
			case CB_PARTYBUFF
				return "BUFFING GROUP"			
			case CB_PARTY_REST
				return "PARTY REST"
			case  CB_FOLLOW_LEADER
				return "FOLLOW_LEADER"
			case CB_PARTYREZ
				return "RESSURECT"
			case CB_PARTYCURE
				return "THE CURE"
			case CB_CROWDCONTROL
				return "CROWD CONTROL"
			case CB_PARTY_IDLE
				return "IDLE"
			
			;----- DEAD Sub State Name
			case CB_RELEASE
				return "RELEASE"
			case CB_DEADMOVE
				return "MOVING"
			case CB_SPIRITHEALER
				return "SPIRIT HEALER"
			case CB_SAFE_RES
				return "SAFE RES"
			case CB_REVIVE_CORPSE
				return "REVIVE CORPSE"
			case CB_DEAD_FUCKED
				return "MISSING PATH WE ARE FUCKED"
			case CB_CLASS_DEAD
				return "ROUTINE OVERRIDE"

			;----- ROAM Sub State Name
			case CB_LEVELUP
				return "LEVEL UP"
			case CB_NEED_VENDOR
				return "VENDOR"
			case CB_NEED_TRAINER
				return "TRAINER"
			case CB_NEED_MAILBOX
				return "MAILBOX"
			case CB_NEED_BANK
				return "BANK"
			case CB_NEED_AH
				return "AH"
			case CB_NEED_FP
				return "FLIGHT PATH"
			case CB_MOUNT
				return "MOUNT"
			case CB_DISMOUNT
				return "DISMOUNT"
			case CB_MOVETO_MOB
				return "MOVETO_MOB"
			case CB_ROAMING
				return "ROAMING"
			case CB_NEED_INNKEEPER
				return "INNKEEPER"
			case CB_MULE
				return "MAIL MULE"
			case CB_NPC_GETTING_READY
				return "GETTING READY"
			case CB_ROAM_TO_NODE
				return "ROAM TO NODE"

			;----- TOON Sub State Name
			case CB_COMBAT_BUFF
				return "COMBAT BUFF"
			case CB_COMBAT
				return "COMBAT"
			case CB_COMBAT_IDLE
				return "COMBAT_IDLE"
			case CB_COMBAT_CLASS_IDLE
				return "CLASS_IDLE"
			case CB_BUFF
				return "BUFF"
			case CB_REST
				return "REST"
			case CB_MOVETO_PULL
				return "MOVETO_PULL"
			case CB_PULL_BUFF
				return "PULL BUFF"
			case CB_PULL
				return "PULL"
			case CB_PULL_WAIT
				return "PULL WAIT"
			case CB_CASTING
				return "CASTING"
			case CB_CASTING_WAIT
				return "CASTING WAIT"
			case CB_ACT_HUMAN
				return "ACT HUMAN"
			case CB_FLEE
				return "RUN LIKE A GIRL"
			case CB_FLEE_WAIT
				return "POST FLEE WAIT"
			case CB_TOON_WAIT
				return "GENERAL WAIT"
			
			;----- LOOT Sub State Name
			case CB_SKIN_CORPSE
				return "SKINNING"
			case CB_LOOT_CORPSE
				return "LOOTING"
			case CB_LOOT_HERB
				return "HERBING"
			case CB_LOOT_ORE
				return "MINING"
			case CB_USE_LOOT
				return "USE"
			case CB_LOOTALL
				return "LOOT ALL"
			case CB_CLOSE_LOOT
				return "CLOSING LOOT"
			case CB_LOOT_WAIT
				return "WAIT FOR LOOT"
			case CB_LOOT_MOVE
				return "MOVE TO LOOT"
			case CB_LOOT_GETTING_READY		
				return "GETTING READY"
			case CB_OPENING
				return "OPENING"
			case CB_FISHING
				return "FISHING"
				
			;----- NPC Sub State Name
			case CB_MOREGOSSIP
				return "TALK TO NPC"
			case CB_TAKE_FLIGHT
				return "FLIGHT MASTER"
			case CB_LEARN_FLIGHT
				return "LEARN FLIGHT"
			case CB_REPAIR
				return "REPAIR"
			case CB_SELL
				return "SELL"
			case CB_TRAINER
				return "TRAINER"
			case CB_AUCTION
				return "AUCTION"
			case CB_NPC_WAIT
				return "NPC WAIT"
			case CB_NPC_MOVE
				return "NPC MOVE"
			case CB_START_HEARTH
				return "Invoke Hearthstone"
			case CB_HEARTHING
				return "Hearthing"
			case CB_RESTOCK
				return "RESTOCK FOOD"
			case CB_HEARTH_GETTING_READY
				return "HEARTH GETTING READY"

			;----- TRADESKILL
			case CB_TRADESKILL_MAKE
				return "TRADESKILL_MAKE"	
			case CB_TRADESKILL_BUY
				return "TRADESKILL_BUY"
			case CB_TRADESKILL_MOVE
				return "TRADESKILL_MOVE"
			case CB_TRADESKILL_WAIT
				return "TRADESKILL_WAIT"
			
			;----- ITEM Sub State Name
			case CB_EQUIP_BAG
				return "Equip Bag"
			case CB_EQUIP_GEAR
				return "Equip Gear"
			case CB_EQUIP_WAIT
				return "Equip Wait"

			;----- QUEST Sub State Name			
			case CB_QUEST_START
				return "QUEST_START"
			case CB_QUEST_END
				return "QUEST_END"
			case CB_QUEST_PLAY
				return "QUEST_PLAY"
			case CB_QUEST_EVENT
				return "QUEST_EVENT"
			case CB_QUEST_LOCATION
				return "QUEST_LOCATION"
			case CB_QUEST_OVERRIDE
				return "QUEST_OVERRIDE"		
		}	
		return "UNKNOWN:" ${StateNumber}
	}
	
	/* we branch which states get tested based on Mode */
	/* assist and party have there own set of states that can hook the others as needed */
	method Pulse()
	{
		variable int TempState 
		variable int i
		
		if !${UIElement[chkAssistMode@Overview@Pages@Cerebrum].Checked} && !${UIElement[chkPartyMode@Overview@Pages@Cerebrum].Checked}
		{		
			for (i:Set[MAIN_STATE_START];${i}<= MAIN_STATE_END;i:Inc)
			{
				TempState:Set[${This.${This.StateName[${i}]}State}]
				if ${TempState} != CB_IDLE
				{
					This.CurrentState:Set[${i}]
					This.CurrentSubState:Set[${TempState}]
					;This:Debug[${This.StateName[${This.CurrentState}]} ${This.StateName[${This.CurrentSubState}]}]
					This:${This.StateName[${This.CurrentState}]}Pulse
					return
				}
			}
		}
		elseif ${UIElement[chkAssistMode@Overview@Pages@Cerebrum].Checked}
		{
			if ${State.ManualOverride}
			{
				This.CurrentState:Set[CB_ASSIST]
				This.CurrentSubState:Set[CB_ASSIST_IDLE]
				This:Output[User Control Detected.]
				This:${This.StateName[${This.CurrentState}]}Pulse		
				return
			}			
			for (i:Set[ASSIST_STATE_START];${i}<= ASSIST_STATE_END;i:Inc)
			{
				TempState:Set[${This.${This.StateName[${i}]}State}]
				if ${TempState} != CB_IDLE
				{
					This.CurrentState:Set[${i}]
					This.CurrentSubState:Set[${TempState}]
					;This:Debug[${This.StateName[${This.CurrentState}]} ${This.StateName[${This.CurrentSubState}]}]
					This:${This.StateName[${This.CurrentState}]}Pulse
					return
				}
			}		
		}		
		else
		{
			for (i:Set[PARTY_STATE_START];${i}<= PARTY_STATE_END;i:Inc)
			{
				TempState:Set[${This.${This.StateName[${i}]}State}]
				if ${TempState} != CB_IDLE
				{
					This.CurrentState:Set[${i}]
					This.CurrentSubState:Set[${TempState}]
					;This:Debug[${This.StateName[${This.CurrentState}]} ${This.StateName[${This.CurrentSubState}]}]
					This:${This.StateName[${This.CurrentState}]}Pulse
					return
				}
			}			
		}
	}

	;----------
	;----- DEAD Sub State
	;----------

	member DEADState()
	{
		/* wait for death lag */
		if ${LavishScript.RunningTime} <= ${DEADState_Wait_Until}
		{
			return CB_DEAD_WAIT
		}
		
		/* when we are dead, but not yet a ghost -- allow for routine hooking here */
		if ${Me.Dead}
		{
			if ${Class.NeedDead}
			{
				return CB_CLASS_DEAD
			}
			This.DEADState_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.DEADState_Release_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
			return CB_RELEASE
		}

		/* ok -- we died and releaseed -- now what? */
		if ${Me.Ghost}
		{
			if ${Math.Calc[${LavishScript.RunningTime} - ${This.JustRes}]} >= ${LagTime}
			{
				/* check corpse before Spirit Healer */
				if ${POI.Type.Equal[CORPSE]}
				{
					if ${Navigator.SafeToRes}
					{
						return CB_REVIVE_CORPSE
					}
					else
					{
						if ${Math.Distance[${Me.Location},${Me.Corpse}]} < 40
						{
							return CB_SAFE_RES
						}
						else
						{
							return CB_DEADMOVE
						}	
					}
				}
				elseif !${POI.NeedSpiritHealer}
				{
					/* only set corpse if we dont need Spirit Healer */
					/* and only need Spirit Healer based on corpse counter */
					if ${POI.Set[${Me.Corpse.X}:${Me.Corpse.Y}:${Me.Corpse.Z}:-1:"Corpse of ${Me.Name}":CORPSE:${Me.FactionGroup.Upper}:${Me.Level}]}
					{
						return CB_DEADMOVE
					}	
				}
				
				if ${POI.Type.Equal[SPIRITHEALER]} && !${UIElement[chkAssistMode@Overview@Pages@Cerebrum].Checked}
				{
					if ${POI.InUseRange}
					{
						if ${WoWScript[StaticPopup1:IsVisible()]}
						{
							This.DEADState_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.DEADState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_SPIRITHEALER
						}
						else
						{
							if ${WoWScript[GetGossipOptions()](exists)}
							{
								return CB_DEAD_MOREGOSSIP
							}
							else
							{
								This.DEADState_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.DEADState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
								return CB_USE_SPIRITHEALER
							}
						}
					}
					else
					{
						return CB_DEADMOVE
					}
				}
				else					
				{
					if ${POI.SetNearestPOI[SPIRITHEALER]} && !${UIElement[chkAssistMode@Overview@Pages@Cerebrum].Checked}
					{
						return CB_DEADMOVE
					}
					elseif ${POI.Set[${Me.Corpse.X}:${Me.Corpse.Y}:${Me.Corpse.Z}:-1:"Corpse of ${Me.Name}":CORPSE:${Me.FactionGroup.Upper}:${Me.Level}]}
					{
						return CB_DEADMOVE
					}
					else
					{
						This:Output[No way to Corpse and to Spirithealer. Not enough Mapping data.]
						return CB_DEAD_FUCKED
					}	
				}
			}
			else
			{
				return CB_DEAD_WAIT
			}
		}					
		return CB_IDLE
	}

	method DEADPulse()
	{
		switch ${This.CurrentSubState}
		{
			case CB_CLASS_DEAD
			Class:DeadPulse
			break
			
			case CB_RELEASE
			if ${UIElement[chkDeathSoundOn@Config@Pages@Cerebrum].Checked}
			{
				This:PlaySound["Inform"]
			}				
			Navigator:ClearPath
			move -stop
			This.JustRes:Set[${LavishScript.RunningTime}]
			WoWScript RepopMe()
			if ${LavishScript.RunningTime} <= ${Math.Calc[${POI.LastRetrieveCorpseTime} + ${POI.CorpseCampTimeout}]} && !${UIElement[chkAssistMode@Overview@Pages@Cerebrum].Checked}
			{
				POI.CorpseCampCount:Inc
				This:Output[Corpse Camp Counter ${POI.CorpseCampCount} of ${Config.GetSlider[sldCorpseCamped]}]
				if ${POI.CorpseCampCount} >= ${Config.GetSlider[sldCorpseCamped]} 
				{
					This:Output[Corpse Camped -> Try Spritithealer]
					This:Output[Trying luck at next Grind Spot]
					Grind:NextHotspot
					POI.NeedSpiritHealer:Set[TRUE]
					POI.CorpseCampCount:Set[0]
				}
			}
			else
			{
				POI.CorpseCampCount:Set[0]
			}
			Grind.RepopCount:Inc
			break

			case CB_DEAD_MOREGOSSIP
			WoWScript SelectGossipOption(1)
			break
			
			case CB_SPIRITHEALER
			WoWScript "AcceptXPLoss()"
			break

			case CB_USE_SPIRITHEALER
			Navigator:ClearPath
			move -stop
			POI:Use
			break

			case CB_DEADMOVE
			MovingToLoc:Set["TRUE"]
			if !${Navigator.IsMovingToCurrentPOI}
			{
				Navigator:MoveToCurrentPOI
			}
			break

			case CB_SAFE_RES
			Navigator:ClearPath
			FindSpot:Set[${LavishScript.RunningTime}]
			MovingToLoc:Set["TRUE"]
			Navigator:MoveToLoc[${Navigator.FindSafeSpot}]
			break

			case CB_REVIVE_CORPSE
			Navigator:ClearPath
			Navigator.ForceRes:Set[FALSE]
			Navigator.ResSpot:Set[0]
			WoWScript RetrieveCorpse()
			MovingToLoc:Set["TRUE"]
			MovingToLoc:Set["FALSE"]
			POI.LastRetrieveCorpseTime:Set[${LavishScript.RunningTime}]
			break
		}
	}

	;----------
	;----- TOON Sub State
	;----------
	member TOONState()
	{	

		if ${LavishScript.RunningTime} <= ${This.TOONState_General_Wait_Until}
		{
			return CB_TOON_WAIT
		}		

		if ${Me.Flying}
		{
			This.TOONState_General_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.TOONState_General_Until_Timeout} * ${Bot.GlobalCooldown})]}]
			return CB_TOON_WAIT
		}

		if ${Flee.NeedToRun}
		{
			return CB_FLEE
		}
		
		if ${Me.InCombat} && !${Mount.IsMounted}
		{
			/* first lets deal with our POI and Target */
			if ${Toon.ValidTarget[${Target.GUID}]} && ${Target.PctHPs} > 0
			{
				if ${POI.GUID.NotEqual[${Target.GUID}]}
				{
					if !${POI.Set[${Target.X}:${Target.Y}:${Target.Z}:${Target.GUID}:${Target.Name}:MOB:FACTION_NEUTRAL:${Target.Level},TRUE]}
					{
						This:Debug[Error: Can not set POI to Target]	
					}
				}
			}
			elseif ${Me.InCombat} && ${Toon.ValidTarget[${Targeting.TargetCollection.Get[1]}]} && ${Object[${Targeting.TargetCollection.Get[1]}].PctHPs} > 0
			{
				Toon:NeedTarget
				if !${POI.Set[${Object[${Targeting.TargetCollection.Get[1]}].X}:${Object[${Targeting.TargetCollection.Get[1]}].Y}:${Object[${Targeting.TargetCollection.Get[1]}].Z}:${Object[${Targeting.TargetCollection.Get[1]}].GUID}:${Object[${Targeting.TargetCollection.Get[1]}].Name}:MOB:FACTION_NEUTRAL:${Object[${Targeting.TargetCollection.Get[1]}].Level},TRUE]}
				{
					This:Debug[Error: Can not set POI to AGGRO Target]	
					Toon:NeedTarget  
				}
			}
			
			/* then if we have a target, lets do combat */
			if ${Target(exists)}
			{
				if ${Class.NeedCombatBuff}
				{
					return CB_COMBAT_BUFF
				}
				else
				{
					return CB_COMBAT
				}					
			}
			else
			{	
				/* we have no target, so lets idle */
				if ${Class.NeedCombatIdle}
				{
					return CB_COMBAT_CLASS_IDLE
				}
				return CB_COMBAT_IDLE
			}
		}

		if ${Class.NeedRest}
		{
			return CB_REST
		}
		
		if ${Class.NeedBuff} &&  (0 < ${Toon.SafeSpotRange})
		{
			if !${Mount.IsMounted} && 0 < ${Toon.SafeSpotRange}
			{
			return CB_BUFF
			}
		}		
		
		if ${Toon.PullableTarget} && !${Mount.IsMounted}
		{
			if ${POI.Set[${Object[${Targeting.TargetCollection.Get[1]}].X}:${Object[${Targeting.TargetCollection.Get[1]}].Y}:${Object[${Targeting.TargetCollection.Get[1]}].Z}:${Object[${Targeting.TargetCollection.Get[1]}].GUID}:${Object[${Targeting.TargetCollection.Get[1]}].Name}:MOB:FACTION_NEUTRAL:${Object[${Targeting.TargetCollection.Get[1]}].Level},FALSE]}
			{	
				if ${Object[${Targeting.TargetCollection.Get[1]}].Distance} > ${Toon.PullRange} && !${Me.Casting}
				{
					return CB_MOVETO_PULL
				}
				else
				{
					if ${Class.NeedPullBuff}
					{
						return CB_PULL_BUFF
					}
					else
					{
						return CB_PULL
					}
				}
			}
			else
			{
				This:Output["Error: Can not set POI to PULL Target"]			
			}
		}

		/* catch all casting check - takes place after combat and pull so it wont interfere with combat casting */
		/* we have waits already defined for skinning and such in LOOT */
		if ${Toon.Casting}
		{
			return CB_CASTING
		}

		if ${LavishScript.RunningTime} <= ${This.TOONState_Casting_Wait_Until}
		{
			return CB_CASTING_WAIT
		}		
		
		if ${Human.NeedAction} && ${Human.ActionDelay} < ${LavishScript.RunningTime} && !${UIElement[chkAssistMode@Overview@Pages@Cerebrum].Checked}
		{
			return CB_ACT_HUMAN
		}
		
		if ${LavishScript.RunningTime} <= ${This.TOONState_Flee_Wait_Until} || ${Math.Calc[${LavishScript.RunningTime}-${This.TOONState_Last_Flee_Time}]} < 1500
		{
			return CB_FLEE_WAIT
		}
		return CB_IDLE
	}

	method TOONPulse()
	{
		if ${Script[CB_FISHING_EXTENSION](exists)} 
		{
			This:EndFishing
		}
		
		switch ${This.CurrentSubState}
		{
			case CB_TOON_WAIT
			/* do nothing, just wait and see */
			break
			case CB_FLEE
			if ${Class.HookFlee}
			{
				Class:FleePulse
			}
			Flee:MoveToFlee
			This.TOONState_Last_Flee_Time:Set[${LavishScript.RunningTime}]
			break
			
			case CB_FLEE_WAIT
			if ${Math.Calc[${LavishScript.RunningTime}-${This.TOONState_Last_Flee_Time}]} < 1500
			{
				Flee:MoveToFlee				
				This.TOONState_Flee_Wait_Until:Set[${This.InMilliseconds[${Math.Rand[450]}]}]
				This:Output["Should be safe, but getting a bit farther away."]					
				return
			}
			if ${Movement.Speed}
			{
				Navigator:MoveToLoc[${Me.X},${Me.Y},${Me.Z}]
				move -stop
			}
			This:Output["Waiting a moment after FLEE."]				
			break
			
			case CB_COMBAT_BUFF
			Mount:Dismount
			Class:CombatBuffPulse
			break

			case CB_COMBAT
			Mount:Dismount
			Navigator:ClearPath
			Class:AttackPulse
			break

			case CB_COMBAT_IDLE
			move -stop
			This:Output["Idle in combat."]
			break
			
			case CB_COMBAT_CLASS_IDLE
			Class:CombatIdle
			break
			
			case CB_BUFF
			Mount:Dismount
			Navigator:ClearPath
			Class:BuffPulse
			break

			case CB_REST
			Mount:Dismount
			Navigator:ClearPath
			Class:RestPulse
			break

			case CB_MOVETO_PULL
			Mount:Dismount	
			Toon:NeedTarget		
			if !${Navigator.IsMovingToCurrentPOI}
			{
				Navigator:MoveToCurrentPOI
			}
			break
			
			case CB_PULL_BUFF
			Mount:Dismount
			Navigator:ClearPath
			Class:PullBuffPulse
			break

			case CB_PULL
			Navigator:ClearPath
			Toon:NeedTarget
			Class:PullPulse
			break
					
			case CB_CASTING
			This.TOONState_Casting_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.TOONState_Casting_Until_Timeout} * ${Bot.GlobalCooldown})]}]
			move -stop
			break
			
			case CB_CASTING_WAIT
			move -stop
			break
			
			case CB_ACT_HUMAN
			Human:Pulse
			break			
		}
	}

		
	;----------
	;----- LOOT Sub State
	;----------
	member LOOTState()
	{
		variable guidlist list
		variable int Index
		variable bool Found = FALSE
		variable int bltimer
		
		if ${Script[CB_FISHING_EXTENSION](exists)} && ${LavishScript.RunningTime} <= ${This.LOOTState_Loot_Fishing_Until} && (${Item[-inventory,"CB_FISHING_POLE"](exists)} || ${Me.Equip[16].Name.Equal["CB_FISHING_POLE"]})
		{
			This:StartFishing
			return CB_FISHING
		}
		else
		{
			This:EndFishing
		}
		
		if ${Me(unit).Casting.Name.Token[1," "].Equal[Skinning]}
		{
			This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
			return CB_SKIN_CORPSE
		}
		if ${Me(unit).Casting.Name.Token[1," "].Equal[Herbalism]}
		{
			This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
			return CB_LOOT_HERB
		}
		if ${Me(unit).Casting.Name.Token[1," "].Equal[Mining]}
		{
			This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
			return CB_LOOT_ORE
		}				
		if ${Me(unit).Casting.Name.Token[1," "].Equal[Opening]}
		{
			This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
			return CB_OPENING
		}

		if ${LavishScript.RunningTime} <= ${This.LOOTState_Loot_Wait_Until}
		{
			return CB_LOOT_WAIT
		}

		if ${LootWindow(exists)}
		{
			if ${LootWindow.Count} > 0 && (${Inventory.FreeSlots} > 0)
			{
				This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_After_Until_Timeout} * ${Bot.GlobalCooldown})]}]
				This.LOOTState_Skip_Scans:Set[0]
				return CB_LOOTALL
			}
			else
			{
				This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_After_Until_Timeout} * ${Bot.GlobalCooldown})]}]
				This.LOOTState_Skip_Scans:Set[0]
				return CB_CLOSE_LOOT
			}
		}

		if ${LavishScript.RunningTime} >= ${LOOTState_Skip_Scans} || ${UIElement[chkAssistMode@Overview@Pages@Cerebrum].Checked}
		{
			
			This.LOOTState_Skip_Scans:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Skip_Scans_Timeout} * ${Bot.GlobalCooldown})]}]

			if (${Inventory.FreeSlots} > 0) && ${UIElement[chkLoot@Config@InvPages@Inventory@Pages@Cerebrum].Checked}
			{
				list:Clear
				list:Search[-units,-dead,-nearest]
				Index:Set[0]
				if ${list.Count} > 0
				{
					while ${list.GUID[${Index:Inc}](exists)} && !${Found}
					{
						if ${Unit[${list.GUID[${Index}]}].Lootable}
						{
							if ${POI.Set[${Unit[${list.GUID[${Index}]}].X}:${Unit[${list.GUID[${Index}]}].Y}:${Unit[${list.GUID[${Index}]}].Z}:${list.GUID[${Index}]}:${Unit[${list.GUID[${Index}]}].Name}:LOOT:FACTION_NEUTRAL:${Unit[${list.GUID[${Index}]}].Level}]}
							{
								Found:Set[TRUE]
							}
						}
						if ${Unit[${list.GUID[${Index}]}].Skinnable}
						{
							if ${Toon.CanSkinMob[${list.GUID[${Index}]}]}
							{
								if ${POI.Set[${Unit[${list.GUID[${Index}]}].X}:${Unit[${list.GUID[${Index}]}].Y}:${Unit[${list.GUID[${Index}]}].Z}:${list.GUID[${Index}]}:${Unit[${list.GUID[${Index}]}].Name}:SKILL_SKINNING:FACTION_NEUTRAL:${Unit[${list.GUID[${Index}]}].Level}]}
								{
									Found:Set[TRUE]
								}
							}
						}
					}
				}
			}

			if !${Found} && ${Toon.HasSkill[SKILL_HERBALISM]} && (${Inventory.FreeSlots} > 0) && ${UIElement[chkGather@Config@InvPages@Inventory@Pages@Cerebrum].Checked}
			{
				list:Clear
				list:Search[-gameobjects,-herb,-usable,-unlocked,-nearest]
				Index:Set[0]
				while ${list.GUID[${Index:Inc}](exists)} && !${Found}
				{
					if ${Toon.SkillLevel[Herbalism]} >= ${OBDB.GetLevel[${Object[${list.GUID[${Index}]}].Name}]} 
					{
						if ${POI.Set[${Object[${list.GUID[${Index}]}].X}:${Object[${list.GUID[${Index}]}].Y}:${Object[${list.GUID[${Index}]}].Z}:${list.GUID[${Index}]}:${Object[${list.GUID[${Index}]}].Name}:SKILL_HERBALISM:FACTION_NEUTRAL:${Object[${list.GUID[${Index}]}].Level}]}
						{
							Found:Set[TRUE]
						}
					}
					else
					{
						This:Output[do Not want ${Object[${list.GUID[${Index}]}].Name} level to high.]
					}
				}
			}
			if !${Found} && ${Toon.HasSkill[SKILL_MINING]} && ${Item[-inventory,"Mining Pick"](exists)} && (${Inventory.FreeSlots} > 0) && ${UIElement[chkGather@Config@InvPages@Inventory@Pages@Cerebrum].Checked}
			{
				list:Clear
				list:Search[-gameobjects,-mine,-usable,-unlocked,-nearest]
				Index:Set[0]
				while ${list.GUID[${Index:Inc}](exists)} && !${Found}
				{
					if ${Toon.SkillLevel[Mining]} >= ${OBDB.GetLevel[${Object[${list.GUID[${Index}]}].Name}]} 
					{
						if ${POI.Set[${Object[${list.GUID[${Index}]}].X}:${Object[${list.GUID[${Index}]}].Y}:${Object[${list.GUID[${Index}]}].Z}:${list.GUID[${Index}]}:${Object[${list.GUID[${Index}]}].Name}:SKILL_MINING:FACTION_NEUTRAL:${Object[${list.GUID[${Index}]}].Level}]}
						{
							Found:Set[TRUE]
						}
					}
					else
					{
						This:Output[do Not want ${Object[${list.GUID[${Index}]}].Name} level to high.]
					}
				}
			}
			/* quest objects */
			if !${Found} && (${Inventory.FreeSlots} > 0) && ${UIElement[chkHarvestQuests@Config@InvPages@Inventory@Pages@Cerebrum].Checked}
			{
				list:Clear
				list:Search[-gameobjects, -nearest, -chest, -unlocked, -usable]
				Index:Set[0]
				while ${list.GUID[${Index:Inc}](exists)} && !${Found}
				{
					if ${POI.Set[${Object[${list.GUID[${Index}]}].X}:${Object[${list.GUID[${Index}]}].Y}:${Object[${list.GUID[${Index}]}].Z}:${list.GUID[${Index}]}:${Object[${list.GUID[${Index}]}].Name}:QUESTOBJECT:FACTION_NEUTRAL:${Object[${list.GUID[${Index}]}].Level}]}
					{
						Found:Set[TRUE]
					}
				}
			}
		}
		
		
		if ${POI.MetaType.Equal[LOOT]}
		{
			if ${Toon.DetectAdds[${POI.GUID}]}
			{
				This:Output[Detected too many adds next to ${POI.Name}. Blacklisting it with GUID for 1 Hour.]
				GlobalBlacklist:Insert[${POI.GUID},3600000]
				POI:Clear
				This.LOOTState_Skip_Scans:Set[0]
				return CB_LOOT_WAIT
			}
			else
			{
				if ${POI.IsBlacklisted} || !${Object[${POI.GUID}](exists)}
				{
					POI:Clear
					This.LOOTState_Skip_Scans:Set[0]
					return CB_LOOT_WAIT
				}
				else
				{
					if ${POI.InUseRange}
					{
						if (${POI.Type.Equal[LOOT]} && !${Unit[${POI.GUID}].CanLoot})
						{
							POI:Clear
							This.LOOTState_Skip_Scans:Set[0]
							return CB_LOOT_WAIT							
						}
						if ${Movement.Speed} || ${Toon.Sitting}
						{
							return CB_LOOT_GETTING_READY
						}
						else
						{
							This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_USE_LOOT
						}
					}
					else
					{
						return CB_LOOT_MOVE		
					}
				}
			}
		}
	
		return CB_IDLE	
	}

	method LOOTPulse()
	{
		switch ${This.CurrentSubState}
		{
			case CB_LOOT_MOVE
			if !${Navigator.IsMovingToCurrentPOI}
			{
				Navigator:MoveToCurrentPOI
			}
			break
			
			case CB_LOOT_GETTING_READY
			Toon:Standup
			if ${Movement.Speed}
			{
				Navigator:ClearPath
				move -stop
			}
			break
			
			case CB_USE_LOOT
			POI:Use
			break

			case CB_SKIN_CORPSE
			This:Output["OOOO a skinable corpse, gimmie!!"]
			POI.LastUse:Set[${LavishScript.RunningTime}]
			break

			case CB_LOOT_HERB
			This:Output["OOOO a Herb, gimmie!!"]
			POI.LastUse:Set[${LavishScript.RunningTime}]
			break

			case CB_LOOT_ORE
			This:Output["OOOO an ore deposit, gimmie!!!"]
			POI.LastUse:Set[${LavishScript.RunningTime}]
			break

			case CB_OPENING
			This:Output["OOOO something to open, gimmie!!!"]
			POI.LastUse:Set[${LavishScript.RunningTime}]
			break


			case CB_LOOTALL
			Mount:Dismount
			Navigator:ClearPath
			move -stop
			Toon:Standup
			POI:LootAll
			Grind.LootCount:Inc
			break

			case CB_CLOSE_LOOT
			WoWScript CloseLoot()
			POI:Clear
			break
		}
	}

	;----------
	;----- NPC Sub State
	;----------
	member NPCState()
	{

		if ${Me(unit).Casting.Name.Token[1," "].Equal["Hearthstone"]}
		{
			This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Hearthstone_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
			return CB_HEARTHING
		}
		
		if ${LavishScript.RunningTime} <= ${NPCState_NPC_Wait_Until}
		{
			return CB_NPC_WAIT
		}

		if ${POI.NeedLogout} || (${UIElement[chkLogOutOnLevel@Logout@Pages@Cerebrum].Checked} && ${UIElement[sldLogOutLevel@Logout@Pages@Cerebrum].Value(exists)} && ${Me.Level} >= ${UIElement[sldLogOutLevel@Logout@Pages@Cerebrum].Value}) || (${UIElement[chkLogoutOnTimer@Logout@Pages@Cerebrum].Checked} && ${UIElement[sldLogOutIn@Logout@Pages@Cerebrum].Value(exists)} && ${Math.Calc[${${Script.RunningTime}.RunningTime}/60000]} >= ${UIElement[sldLogOutIn@Logout@Pages@Cerebrum].Value})
		{
			if ${Item[Hearthstone](exists)} && ${Me.Action[Hearthstone].Usable}
			{
				if ${Movement.Speed} || ${Toon.Sitting}
				{
					return CB_HEARTH_GETTING_READY
				}
				else
				{
					This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Hearthstone_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
					return CB_START_HEARTH 
				}
			}
			
			if ${POI.Type.Equal[INNKEEPER]} && !${POI.IsBlacklisted}
			{
				if ${POI.InUseRange}
				{
					return CB_LOGOUT
				}
				else
				{
					return CB_NPC_MOVE
				}
			}
			else
			{
				if ${POI.SetNearestPOI[INNKEEPER]}
				{
					return CB_NPC_MOVE
				}
				else
				{
					This:Output[Not enough mapping data to get to an Innkeeper, logging out here!]
					return CB_LOGOUT
				}
			}
		}	
		
		if ${POI.Type.Equal[FLIGHTMASTER]} && !${POI.IsBlacklisted}
		{
			if ${POI.InUseRange}
			{
				if ${WoWScript[TaxiFrame:IsVisible()]}
				{
					This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
					return CB_TAKE_FLIGHT					
				}
				else
				{
					if ${WoWScript[GetGossipOptions()](exists)}
					{
						This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
						return CB_MOREGOSSIP
					}
					if ${Movement.Speed} || ${Toon.Sitting}
					{
						return CB_NPC_GETTING_READY
					}
					else
					{
						This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
						return CB_USE_NPC
					}						
				}
			}
			else
			{
				return CB_NPC_MOVE
			}
		}
		else
		{
			if ${FlightPlan.TakeFlightMaster} 
			{
				if ${FlightPlan.SetFlightPOI}
				{
					return CB_NPC_MOVE
				}
				else
				{
					FlightPlan.NeedFlight:Set[FALSE]
				}
			}
		}

		if ${FlightPlan.LearnFlightMaster}
		{
			if !${Config.GetCheckbox[chkLearnFM]}
			{
				FlightPlan.LearnFlightMaster:Set[FALSE]
				FlightPlan.LearnFM:Set["0:0:0:0:0:0:0:0"]					
			}
			elseif ${POI.Type.Equal[FLIGHTMASTER]} && !${POI.IsBlacklisted}
			{
				if ${POI.InUseRange}
				{
					if ${WoWScript[TaxiFrame:IsVisible()]}
					{
						return CB_LEARN_FLIGHT					
					}
					else
					{
						if ${WoWScript[GetGossipOptions()](exists)}
						{
							This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_MOREGOSSIP
						}
						if ${Movement.Speed} || ${Toon.Sitting}
						{
							return CB_NPC_GETTING_READY
						}
						else
						{
							This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_USE_NPC
						}						
					}
				}
				return CB_NPC_MOVE
			}
			elseif ${POI.Set[${FlightPlan.LearnFM}]}
			{
					return CB_LEARN_FLIGHT
			}
		}
		
		if ${POI.NeedRepair}
		{
			if ${POI.Type.Equal[REPAIR]} && !${POI.IsBlacklisted}
			{
				if ${POI.InUseRange}
				{
					if ${WoWScript[MerchantFrame:IsVisible()]}
					{
						This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
						return CB_REPAIR
					}
					else
					{
						if ${WoWScript[GetGossipOptions()](exists)}
						{
							This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_MOREGOSSIP
						}
						else
						{
							if ${Movement.Speed} || ${Toon.Sitting}
							{
								return CB_NPC_GETTING_READY
							}
							else
							{
								This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
								return CB_USE_NPC
							}
						}
			 		}
			 	}
			 	else
			 	{
					return CB_NPC_MOVE
			 	}
			}
			else
			{
				if ${POI.SetNearestPOI[REPAIR]}
				{
					return CB_NPC_MOVE
				}
				else
				{
					This:Output[Not enough mapping data to REPAIR POI !]
					;no return here try other NPC
				}
			}
		}
		
		if ${POI.NeedTradeSkill}
		{
			/* Tradeskills.NeedTradeSkill should determine when tradeskills should start and stop */
			if ${Tradeskills.NeedTradeSkill}
			{
					if ${Tradeskills.NeedMake}
					{
						return CB_TRADESKILL_MAKE
					}
					elseif ${Tradeskills.NeedBuy}
					{
						return CB_TRADESKILL_BUY
					}
					elseif ${Tradeskills.NeedTradePOI}
					{
						/* set POI here */
						return CB_TRADESKILL_MOVE
					}
					elseif ${Tradeskills.NeedWait}
					{
						return CB_TRADESKILL_WAIT
					}
			}
			POI.NeedTradeSkill:Set[FALSE] 
		}
			
		if ${POI.NeedSell}
		{
			if ${POI.Type.Equal[SELL]} && !${POI.IsBlacklisted}
			{
				if ${WoWScript[MerchantFrame:IsVisible()]}
				{
					This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
					return CB_SELL
				}
				else
				{
			 		if ${POI.InUseRange}
			 		{
						if ${WoWScript[GetGossipOptions()](exists)}
						{
							This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_MOREGOSSIP
						}
						else
						{
							This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_USE_NPC
						}
			 		}
			 		else
			 		{
						return CB_NPC_MOVE
			 		}
			 	}
			}
			else
			{
				if ${POI.SetNearestPOI[SELL]}
				{
					return CB_NPC_MOVE
				}
				else
				{
					This:Output[Not enough mapping data to SELL POI !]
					;no return here try other NPC
				}
			}
		}
		
		if ${POI.NeedRestock}
		{
			if ${Inventory.FreeSlots} > 0
			{
				if (${POI.Name.Equal[${Inventory.FoodMerch}]} || ${POI.Name.Equal[${Inventory.DrinkMerch}]} || ${POI.Name.Equal[${Inventory.AmmoMerch}]}) &&  !${POI.IsBlacklisted}
				{
					if ${POI.InUseRange}
					{
						if ${WoWScript[MerchantFrame:IsVisible()]} 
						{
							This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_RESTOCK
						}
						else
						{
							if ${WoWScript[GetGossipOptions()](exists)}
							{
								This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
								return CB_MOREGOSSIP
							}
							else
							{
								This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
								return CB_USE_NPC
							}
						}
					}
					else
					{
							return CB_NPC_MOVE
					}
				}
				else
				{
					if ${Inventory.NeedRestock[1].Equal[Food]} && ${Inventory.FoodMerch.NotEqual[""]} && ${POI.SetPOINamed[${Inventory.FoodMerch}]}
					{
						return CB_NPC_MOVE
					}
					if ${Inventory.NeedRestock[1].Equal[Water]} && ${Inventory.DrinkMerch.NotEqual[""]} && ${POI.SetPOINamed[${Inventory.DrinkMerch}]}
					{
						return CB_NPC_MOVE
					}
					if (${Inventory.NeedRestock[1].Equal[Ammo]} || ${Inventory.NeedRestock[1].Equal[Arrow]}) && ${Inventory.AmmoMerch.NotEqual[""]} && ${POI.SetPOINamed[${Inventory.AmmoMerch}]}
					{
						return CB_NPC_MOVE
					}
					This:Output[Not enough mapping data to RESTOCK POI !]
					;no return here try other NPC
				}
			}
			else
			{
				POI.NeedRestock:Set[FALSE]
			}
		}
		
		if ${POI.NeedMailbox}
		{
			if ${POI.Type.Equal[MAILBOX]} && !${POI.IsBlacklisted}
			{
				if ${POI.InUseRange}
				{
					if ${WoWScript[MailFrame:IsVisible()]}
					{
						This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
						return CB_MULE
					}
					else
					{
						This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
						return CB_USE_NPC
					}
				}
				else
				{
					return CB_NPC_MOVE
				}
			}
			else
			{
				if ${POI.SetNearestPOI[MAILBOX]}
				{
					return CB_NPC_MOVE
				}
				else
				{
					This:Output[Not enough mapping data to MAILBOX POI !]
					;no return here try other NPC
					POI.NeedMailbox:Set[FALSE]

				}
			}
		}

		if ${POI.NeedClassTrainer}
		{
			if ${POI.Type.Equal[${Me.Class}_TRAINER]} && !${POI.IsBlacklisted}
			{
				if ${POI.InUseRange}
				{
					if ${This.VisibleFrame[ClassTrainerFrame]}
					{
						This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
						return CB_TRAINER
					}
					else
					{
						if ${WoWScript[GetGossipOptions()](exists)}
						{
							This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_MOREGOSSIP
						}
						else
						{
							This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_USE_NPC
						}
					}
				}
				else
				{
					return CB_NPC_MOVE
				}
			}
			else
			{
				if ${POI.SetNearestPOI[${Me.Class}_TRAINER]}
				{
					return CB_NPC_MOVE
				}
				else
				{
					This:Output[Not enough mapping data to CLASSTRAINER, aborting trainer run !]
					;no return here try other NPC
					POI.NeedClassTrainer:Set[FALSE]
				}
			}
		}
		
		
		;THIS IS A SOURCE OF ROAM LAG - ATTEMPTED REWRITE	
		if !${POI.IgnoreSkinningTrainer} && ${Toon.HasSkill[SKILL_SKINNING]}
		{
			if (${Toon.SkillLevel[SKILL_SKINNING]}==${Toon.SkillMaxLevel[SKILL_SKINNING]}) && (${Toon.SkillLevel[SKILL_SKINNING]}<${Bot.SkillLvlCap})
			{
				if ${POI.Type.Equal["Skinning_TRAINER"]} && !${POI.IsBlacklisted}
				{
					if ${POI.InUseRange}
					{
						if ${This.VisibleFrame[ClassTrainerFrame]}
						{
							This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_TRAINER
						}
						else
						{
							if ${WoWScript[GetGossipOptions()](exists)}
							{
								This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
								return CB_MOREGOSSIP
							}
							else
							{
								This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
								return CB_USE_NPC
							}
						}
					}
					else
					{
						return CB_NPC_MOVE
					}
				}
				else
				{
					if !${POI.Type.Equal["FLIGHTMASTER"]}
					{
						if ${POI.SetNearestPOI["Skinning_TRAINER",${Math.Calc[1 + ${Toon.SkillLevel[SKILL_SKINNING]}]}]}
						{
							return CB_NPC_MOVE
						}
						else
						{
							This:Output[Not enough mapping data to Skinning Trainer that can train me, aborting trainer run !]
							POI.IgnoreSkinningTrainer:Set[TRUE]
							;no return here try other NPC
						}
					}
				}
			}			
		}
		
		
		if !${POI.IgnoreHerbalismTrainer} && ${Toon.HasSkill[SKILL_HERBALISM]} 
		{
			if (${Toon.SkillLevel[SKILL_HERBALISM]}==${Toon.SkillMaxLevel[SKILL_HERBALISM]}) && (${Toon.SkillLevel[SKILL_HERBALISM]}<${Bot.SkillLvlCap})
			{
				if ${POI.Type.Equal["Herbalism_TRAINER"]} && !${POI.IsBlacklisted}
				{
					if ${POI.InUseRange}
					{
						if ${This.VisibleFrame[ClassTrainerFrame]}
						{
							This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_TRAINER
						}
						else
						{
							if ${WoWScript[GetGossipOptions()](exists)}
							{
								This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
								return CB_MOREGOSSIP
							}
							else
							{
								This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
								return CB_USE_NPC
							}
						}
					}
					else
					{
						return CB_NPC_MOVE
					}
				}
				else
				{
					if !${POI.Type.Equal["FLIGHTMASTER"]}
					{
						if ${POI.SetNearestPOI["Herbalism_TRAINER",${Math.Calc[1 + ${Toon.SkillLevel[SKILL_HERBALISM]}]}]}
						{
							return CB_NPC_MOVE
						}
						else
						{
							This:Output[Not enough mapping data to Herbalism Trainer that can train me, aborting trainer run !]
							POI.IgnoreHerbalismTrainer:Set[TRUE]
							;no return here try other NPC
						}
					}
				}
			}
		}
		
		if !${POI.IgnoreMiningTrainer} && ${Toon.HasSkill[SKILL_MINING]}
		{
			if (${Toon.SkillLevel[SKILL_MINING]}==${Toon.SkillMaxLevel[SKILL_MINING]}) && (${Toon.SkillLevel[SKILL_MINING]}<${Bot.SkillLvlCap})
			{
				if ${POI.Type.Equal["Mining_TRAINER"]} && !${POI.IsBlacklisted}
				{
					if ${POI.InUseRange}
					{
						if ${This.VisibleFrame[ClassTrainerFrame]}
						{
							This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_TRAINER
						}
						else
						{
							if ${WoWScript[GetGossipOptions()](exists)}
							{
								This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
								return CB_MOREGOSSIP
							}
							else
							{
								This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
								return CB_USE_NPC
							}
						}
					}
					else
					{
						return CB_NPC_MOVE
					}
				}
				else
				{
					if !${POI.Type.Equal["FLIGHTMASTER"]}
					{					
						if ${POI.SetNearestPOI["Mining_TRAINER",${Math.Calc[1 + ${Toon.SkillLevel[SKILL_MINING]}]}]}
						{
							return CB_NPC_MOVE
						}
						else
						{
							This:Output[Not enough mapping data to Mining Trainer that can train me, aborting trainer run !]
							POI.IgnoreMiningTrainer:Set[TRUE]
							;no return here try other NPC
						}
					}
				}
			}
		}
		return CB_IDLE
	}

	method NPCPulse()
	{
		switch ${This.CurrentSubState}
		{
			case CB_NPC_GETTING_READY
			Toon:Standup
			if ${Movement.Speed}
			{
				Navigator:ClearPath
				move -stop
			}
			break
			
			case CB_RESTOCK
			variable iterator iter
			Inventory.RestockList:GetIterator[iter]
			iter:First
			
			This:Debug["RESTOCK?: ${Inventory.NeedRestock}"]
		 	if !${Inventory.NeedRestock} || !${POI.Name.Equal[${Inventory.${Inventory.NeedRestock[1]}Merch}]}
	 		{
	 			This:Output["Done Restocking here."]
	 			POI:Clear
	 			POI.NeedRestock:Set[FALSE]
	 			break
	 		}

			while ${iter.IsValid}
	 		{
	 			This:Debug["MAX: ${iter.Value.Max} STACK: ${Inventory.StackCount[${iter.Key}]} DIS: ${iter.Value.Disabled}"]
	 			if ${iter.Value.Max} > ${Inventory.StackCount[${iter.Key}]} && !${iter.Value.Disabled}
	 			{
	 				if ${Inventory.BuyItem[${iter.Key}]}
	 				{
	 					This:Debug["Buying ${iter.Key}"]
	 					This.NPCState_NPC_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.NPCState_Interact_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
	 					break
	 				}
	 				elseif ${LNavGroup[${iter.Value.myType}].Contains[${POI.Name}]}
	 				{
	 					iter.Value.Disable:Set[TRUE]
	 				}
	 			}
	 			iter:Next
	 		}
			break
			
			
			case CB_HEARTH_GETTING_READY
			Toon:Standup
			if ${Movement.Speed}
			{
				Navigator:ClearPath
				move -stop
			}
			break
			
			case CB_START_HEARTH 
			Item[Hearthstone]:Use
			break
			
			case CB_NPC_MOVE				
			Human.StopOnFollow_Override:Set[${This.InSeconds[300]}]				
			if ${Mount.NeedMount}
			{
				Grind.CurrentGrind.CurrentHotspot:Set[1]				
				Mount:Mount
				return
			}
			if ${POI.Distance} <= ${Mount.DismountDistance} && ${Mount.IsMounted}
			{
				Mount:Dismount
			}				
			if !${Navigator.IsMovingToCurrentPOI}
			{
				Navigator:MoveToCurrentPOI
			}
			break
			
			case CB_TAKE_FLIGHT
			This:Output["Taking Flightpath to ${FlightPlan.FlightNode[${FlightPlan.DestinationFM}]}"]
			if ${WoWScript[TaxiFrame:IsVisible()]}
			{			
				if ${FlightPlan.NeedRefresh}
				{
					FlightPlan:Refresh
					FlightPlan.NeedRefresh:Set[FALSE]
					return
				}
				if ${FlightPlan.NeedFlight}
				{
					if ${FlightPlan.GetNodeSlot[${FlightPlan.DestinationFM}]} > 0
					{
						WoWScript TakeTaxiNode(${FlightPlan.GetNodeSlot[${FlightPlan.DestinationFM}]})
						FlightPlan.NeedFlight:Set[FALSE]
						FlightPlan.DestinationFM:Set[NULL]
						FlightPlan.LastFlight:Set[${LavishScript.RunningTime}]						
						return
					}
				}
			}
			break
				
			case CB_LEARN_FLIGHT
			if ${WoWScript[TaxiFrame:IsVisible()]}
			{			
				if ${FlightPlan.NeedRefresh}
				{
					FlightPlan:Refresh
					FlightPlan.NeedRefresh:Set[FALSE]
					FlightPlan.LearnFlightMaster:Set[FALSE]
					FlightPlan.LearnFM:Set["0:0:0:0:0:0:0:0"]					
					return
				}
			}				
			break
			
			case CB_USE_NPC
			Mount:Dismount
			Toon:Standup
			Navigator:ClearPath
			move -stop
			POI:Use
			break
			
			case CB_LOGOUT
			if ${UIElement[chkErrorSoundOn@Config@Pages@Cerebrum].Checked}
			{
				This:PlaySound["Stop"]
			}				
			This:Debug["CB_LOGOUT, Have a good day"]
			Navigator:ClearPath
			move -stop
			WoWScript Logout()
			endscript Cerebrum
			break
			
			case CB_MOREGOSSIP
			;TODO: use event GOSSIP_SHOW and title1, gossip1 = GetGossipOptions()
			;see http://www.wowwiki.com/API_GetGossipOptions
			variable int gcheck=1
			variable int copt=0
			while ${WoWScript[GetGossipOptions(),${gcheck}](exists)}
			{
				;This:Output[${WoWScript[GetGossipOptions(),${gcheck}]}]
				if ${WoWScript[GetGossipOptions(),${gcheck}].NotEqual["binder"]} && ${WoWScript[GetGossipOptions(),${gcheck}].NotEqual["gossip"]}
				{	
					copt:Inc
				}
				if ${WoWScript[GetGossipOptions(),${gcheck}].Find["browse your goods"]}!=NULL
				{
					This:Output["Selecting: ${gcheck} ${WoWScript[GetGossipOptions(),${gcheck}]}"]
					WoWScript SelectGossipOption(${copt})
					break
				}
				gcheck:Inc
			}
			WoWScript SelectGossipOption(1)
			break

			case CB_REPAIR
			WoWScript RepairAllItems()
			POI.NeedRepair:Set[FALSE]
			if ${Object[${Inventory.GetSlot[Sell]}](exists)}
			{
				POI.NeedSell:Set[TRUE]
			}
			break
			
			case CB_SELL
	 		if ${Object[${Inventory.GetSlot[Sell]}](exists)}
 			{
 				Object[${Inventory.GetSlot[Sell]}]:Use
 			}
			else
			{
				This:Output[Done Selling]
				POI.NeedSell:Set[FALSE]
 				if ${Object[${Inventory.GetSlot[Mule]}](exists)} && ${Me.Coinage} >= 30
				{
					POI.NeedMailbox:Set[TRUE]
				}
			}
			break

			case CB_TRAINER
			WoWScript SetTrainerServiceTypeFilter("available",1)
			WoWScript SetTrainerServiceTypeFilter("unavailable",0)
			WoWScript SetTrainerServiceTypeFilter("used",0)

			if ${WoWScript[GetNumTrainerServices()]}>0
			{
				if ${WoWScript[GetTrainerServiceCost(${WoWScript[GetTrainerSelectionIndex()]})]} <= ${Me.Coinage}
				{
					WoWScript BuyTrainerService(${WoWScript[GetTrainerSelectionIndex()]})
				}
				else
				{
					if ${POI.Type.Equal[${Me.Class}_TRAINER]}
					{
						POI.NeedClassTrainer:Set[FALSE]
						This:Output[Not enough money for ${Me.Class} Trainer, skipping Training !]
					}
					if ${POI.Type.Equal["Skinning_TRAINER"]}
					{
						POI.IgnoreSkinningTrainer:Set[TRUE]
						This:Output[Not enough money for Skinning Trainer, skipping Training !]
					}
					if ${POI.Type.Equal["Herbalism_TRAINER"]}
					{
						POI.IgnoreHerbalismTrainer:Set[TRUE]
						This:Output[Not enough money for Herbalism Trainer, skipping Training !]
					}
					if ${POI.Type.Equal["Mining_TRAINER"]}
					{
						POI.IgnoreMiningTrainer:Set[TRUE]
						This:Output[Not enough money for Mining Trainer, skipping Training !]
					}
				}
			}
			else
			{
				if ${POI.Type.Equal[${Me.Class}_TRAINER]}
				{
					POI.NeedClassTrainer:Set[FALSE]
				}
			}
			break

			case CB_MULE
	 		if ${Object[${Inventory.GetSlot[Mule,"-notsoulbound"]}](exists)} && ${Me.Coinage} >= 30
			{
		 		if ${WoWScript[GetSendMailItem(),3]}
				{
					WoWScript SendMail(\"${UIElement[tenMuleChar@Config@InvPages@Inventory@Pages@Cerebrum].Text}\"\, \"${Object[${Inventory.GetSlot[Mule,"-notsoulbound"]}].Name}\"\, \"\")
				}
				else
				{
					if ${WoWScript[CursorHasItem()]}
					{
						WoWScript ClickSendMailItemButton()
					}
					else
					{
						Item[${Inventory.GetSlot[Mule,"-notsoulbound"]}]:PickUp
					}
				}
			}
			else
			{
				POI.NeedMailbox:Set[FALSE]
			}
			break
			
			case CB_TRADESKILL_MAKE
			Tradeskills:MakeTradeSkill
			break
			
			case CB_TRADESKILL_BUY
			Tradeskills:BuyTradeSkill
			break
			
			case CB_TRADESKILL_MOVE
			Tradeskills:NeedTradePOI
			break
			
			case CB_TRADESKILL_WAIT 
			This:Debug[Waiting in Tradeskill]
			break
		}
	}

	;----------
	;----- ITEM Sub State
	;----------
	member ITEMState()
	{
  		if ${LavishScript.RunningTime} <= ${This.ITEMState_Equip_Wait_Until}
  		{
				return CB_EQUIP_WAIT
  		}
			if ${Autoequip.DismissBindPopUp}
			{
				This.ITEMState_Equip_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.ITEMState_Equip_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
				return CB_EQUIP_WAIT				
			}		
			if ${Autoequip.NeedEQ} && !${Me.Equip[16].Name.Equal["CB_FISHING_POLE"]}
			{
				if ${Autoequip.EquipGear}
				{
					This.ITEMState_Equip_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.ITEMState_Equip_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
					return CB_EQUIP_WAIT
				}
				elseif ${Autoequip.EquipBag}
				{
					This.ITEMState_Equip_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.ITEMState_Equip_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
					return CB_EQUIP_WAIT
				}
				else
				{
					Autoequip.NeedEQ:Set[FALSE]
				}
			}
		return CB_IDLE
	}

	method ITEMPulse()
	{
		switch ${This.CurrentSubState}
		{
			case CB_EQUIP_WAIT
			break
		}
	}


	;----------
	;----- QUEST Sub State
	;----	
	member QUESTState()
	{
		if ${UIElement[chkPlayQuest@Quest@HumanPages@Human@Pages@Cerebrum].Checked}
		{
			Quest.ActiveID:Set[${Play.BestQuest}]
			if ${Questgiver.NeedHandIn} && !${Play.StateOverride} && ${Play.StepType.Equal[turnin]} 
			{
				return CB_QUEST_END
			}
			if ${Questgiver.NeedPickup} && !${Play.StateOverride} && ${Play.StepType.Equal[pickup]} 
			{
				return CB_QUEST_START
			}
			if ${Play.StateOverride}
			{
				return CB_QUEST_OVERRIDE
			}
			if ${Quest.ActiveID} > 0
			{
				variable string QuestType = ${LavishSettings[Quests].FindSet[${Quest.ActiveID}].FindSetting[Type]}
				if ${Grind.HotSpotDistance} < 30 && ${QuestType.Equal[EVENT]} && !${Play.StateOverride}
				{
					return CB_QUEST_EVENT
				}
				if ${Quest.IsComplete[${Quest.ActiveID}]} && !${Play.StateOverride} && ${Play.StepType.Equal[turnin]} 
				{
					return CB_QUEST_PLAY
				}
				if !${Quest.QuestLoc[${Quest.ActiveID}]} && !${Play.StateOverride}
				{
					return CB_QUEST_LOCATION
				}
			}
		}
		return CB_IDLE		
	}


	method QUESTPulse()
	{
		switch ${This.CurrentSubState}
		{
			case CB_QUEST_END
			case CB_QUEST_START
			{
				Questgiver:Gossip
				return
			}
			case CB_QUEST_PLAY
			{
				Play:HandIn[${Quest.ActiveID}]
				return
			}
			case CB_QUEST_EVENT
			{
				Play:FindAOI
				return
			}
			case CB_QUEST_LOCATION
			{
				Play:SwitchLoc[${Quest.ActiveID}]
				return
			}
			case CB_QUEST_OVERRIDE
			{
				echo Hahaha Bitch Overridden!
			}
		}	
	}		
		
	
	;----------
	;----- ROAM Sub State
	;----------
	member ROAMState()
	{		
		if !${Me.Dead} && !${Me.Ghost} && ${Mount.NeedMount}
		{
			return CB_MOUNT
		}

		if !${Me.Dead} && !${Me.Ghost} && ${POI.Distance} <= ${Mount.DismountDistance} && ${Mount.IsMounted}
		{
			return CB_DISMOUNT
		}
		
		if ${Me.Level} != ${Toon.Level}
		{
			return CB_LEVELUP
		}
		
			
		/* conditionals for moving to mob should be defined in Toon.MoveToMob */
		if ${Toon.MoveToMob} && !${Mount.IsMounted}
		{
			if ${POI.Type.Equal[MOB]} && ${POI.GUID.Equal[${Targeting.TargetCollection.Get[1]}]} 
			{
				return CB_MOVETO_MOB				
			}			
			elseif ${POI.Set[${Object[${Targeting.TargetCollection.Get[1]}].X}:${Object[${Targeting.TargetCollection.Get[1]}].Y}:${Object[${Targeting.TargetCollection.Get[1]}].Z}:${Object[${Targeting.TargetCollection.Get[1]}].GUID}:${Object[${Targeting.TargetCollection.Get[1]}].Name}:MOB:FACTION_NEUTRAL:${Object[${Targeting.TargetCollection.Get[1]}].Level},FALSE]}
			{	
				return CB_MOVETO_MOB
			}
		}
		
		;REWRITTEN TO REDUCE ROAM LAG
		variable bool canMine = FALSE
		variable bool canHerb = FALSE
		variable point3f RecoveryHop
			RecoveryHop.X:Set[0]
				RecoveryHop.Y:Set[0]
				RecoveryHop.Z:Set[0]
		
		if ${Toon.HasSkill[Herbalism]} || ${Toon.HasSkill[Mining]}
		{
			if ${Toon.HasSkill[Herbalism]} && ${UIElement[chkRoamHerb@Config@InvPages@Inventory@Pages@Cerebrum].Checked}
			{
				canHerb:Set[TRUE]
			}
			
			if ${Item[-inventory,"Mining Pick"](exists)} && ${Toon.HasSkill[Mining]} && ${UIElement[chkRoamMine@Config@InvPages@Inventory@Pages@Cerebrum].Checked}
			{
				canMine:Set[TRUE]
			}
			if ${canHerb} && ${canMine}
			{
				if ${POI.SetNearestPOI[MINING,1,${Toon.SkillLevel[Mining]}]}
				{
					;If there is a Herb Node Nearer or same Distance then we prefer to roam there
					if ${POI.SetNearestPOI[HERBALISM,1,${Toon.SkillLevel[Herbalism]},${POI.Distance}]}
					{
						return CB_ROAM_TO_NODE
					}
					return CB_ROAM_TO_NODE
				}
				else
				{
					if ${POI.SetNearestPOI[HERBALISM,1,${Toon.SkillLevel[Herbalism]}]}
					{
						return CB_ROAM_TO_NODE
					}
				}			
			}
			elseif ${canMine}
			{
				if ${POI.SetNearestPOI[MINING,1,${Toon.SkillLevel[Mining]}]}
				{
					return CB_ROAM_TO_NODE
				}
			}
			elseif ${canHerb}
			{
				if ${POI.SetNearestPOI[HERBALISM,1,${Toon.SkillLevel[Herbalism]}]}
				{
					return CB_ROAM_TO_NODE
				}
			}
		}	

		if ${Grind.ChangeLocation}
		{
			This:Debug[Changing Location]
		}

		/* only attempt to set a hotspot poi if poi is not current hotspot*/
		if ${POI.Name.NotEqual[${Grind.HotSpotName}]} || (${POI.X} != ${Grind.X} || ${POI.Y} != ${Grind.Y} || ${POI.Z} != ${Grind.Z})
		{
			This:Debug["Setting POI to ${Grind.HotSpotName}"]
			if !${POI.Set[${Grind.X}:${Grind.Y}:${Grind.Z}:${Grind.HotSpotName}:${Grind.HotSpotName}:HOTSPOT:FACTION_NEUTRAL:0]}
			{
				if ${Config.GetCheckbox[chkTakeFMToGrind]}
				{
					if ${FlightPlan.FlyToPoint[${Grind.X},${Grind.Y},${Grind.Z}]}
					{
						if ${FlightPlan.SetFlightPOI}
						{
							return CB_ROAMING
						}
					}
				}
				/* if we loop 25 times within 2 minutes, location is bad */
				if ${This.Location_Failed_Count:Inc} > 25 && ${This.Location_Failed_Timer} > ${LavishScript.RunningTime}
				{
					if ${UIElement[chkErrorSoundOn@Config@Pages@Cerebrum].Checked}
					{
						This:PlaySound["Stop"]
					}
					This:Output["ERROR: LOCATION FAILED. NO CONNECTIONS TO ANY HOTSPOT. FORCING LOCATION CHANGE"]
					Grind:LoadBestLocationSet[TRUE]
					This.Location_Failed_Count:Set[0]
					This.Location_Failed_Timer:Set[0]
					return CB_IDLE
				}
				if ${This.Location_Failed_Timer} < ${LavishScript.RunningTime}
				{
					This.Location_Failed_Timer:Set[${This.Location_Failed_Timer}+120000]
				}
				/* first try iterating through hotspots */
				This:Output["Error: Not enough mapping data to ${Grind.HotSpotName}. Iterating to Next Hotspot"]
				;ClickMoveToLoc ${Math.Calc[${This.X}+1]} ${This.Y} ${Me.Z}
				GreyNav:GetNearestValidXYZ[${Map.ID}, ${Me.X}, ${Me.Y}, ${Me.Z}, RecoveryHop]
				
				if ${RecoveryHop.X} == 0 && ${RecoveryHop.Y} == 0 && ${RecoveryHop.Z} == 0
				{
					This:Output["Couldn't find nearest valid point, now we're really screwed!, ob paused"]
					move -stop
					Script[Cerebrum]:Pause
				}
				else
				{
					ClickMoveToLoc RecoveryHop.X RecoveryHop.Y RecoveryHop.Z
				}

				Grind:NextHotspot
				return CB_IDLE
			}
		}
			
		if ${POI.Type.Equal[HOTSPOT]} && ${POI.Name.Token[1,"@"].Upper.Equal[FISHING]}
		{
			if ${Script[CB_FISHING_EXTENSION](exists)} &&  (${Item[-inventory,"CB_FISHING_POLE"](exists)} || ${Me.Equip[16].Name.Equal["CB_FISHING_POLE"]})
			{
				if ${POI.Distance} <= ${Navigator.GetPercision} 
				{
					This:Output[Reached Fishing Hotspot start CB_FISHING_EXTENSION now.]	
					This.LOOTState_Loot_Fishing_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Fishing_Timeout} * ${Bot.GlobalCooldown})]}]
				}
			}
			else
			{
				This:Output[Need CB_FISHING_EXTENSION loaded and CB_FISHING_POLE in Inventory to Fish ! Skipping Fishing Hotspot.]	
				This:NextHotspot
			}
		}
		
		/* dont check POI distance for iterating Grind unless POI is Hotspot */
		if ${POI.Type.Equal[HOTSPOT]} && ${POI.Distance} <= ${Math.Calc[${Navigator.GetPercision}+${POI.RandomDistanceModifier}]} && ${POI.Name.Token[1,"@"].Upper.NotEqual[FISHING]}
		{
			This:Output[Reached Current Hotspot. Random switch distance was: ${POI.Distance}]
			This:NextHotspot
		}
		
		;Never Idle during GRIND ;)
		return CB_ROAMING
	}
	
	method ROAMPulse()
	{
		switch ${This.CurrentSubState}
		{
			case CB_MOUNT
			Mount:Mount
			break

			case CB_DISMOUNT
			Mount:Dismount
			break

			case CB_LEVELUP
			This:Output[Gratz we Leveled up! New Level is ${Me.Level}.]
			This:Output[Checking Profile and doing Trainer run.]
			Toon.Level:Set[${Me.Level}]
			Grind:LoadBestLocationSet[FALSE]
			if ${Math.Calc[${Me.Level}%2]} == 0
			{
				POI.NeedClassTrainer:Set[TRUE]
			}
			break
			
			case CB_MOVETO_MOB
			Mount:Dismount
			Toon:NeedTarget			
			if !${Navigator.IsMovingToCurrentPOI}
			{
				Navigator:MoveToCurrentPOI
			}
			break
			
			case CB_ROAMING
			if !${Navigator.IsMovingToCurrentPOI}
			{
				Navigator:MoveToCurrentPOI
			}
			break
		}
	}

	method NextHotspot()
	{
			if ${Grind.RandomizeHotSpots}
			{
				Grind:RandomHotSpot
				This:Output[Next Random HotSpot is ${Grind.HotSpotName}.]
			}
			else
			{
				Grind:NextHotspot
				This:Output[Next HotSpot is ${Grind.HotSpotName}.]			
			}
			POI.RandomDistanceModifier:Set[${Math.Rand[10]}]
			This:Output[Next Distance Modifier is: ${POI.RandomDistanceModifier}]	
	}
	
	method EndFishing()
	{
		if !${Script[CB_FISHING_EXTENSION].Paused}
		{
			Script[CB_FISHING_EXTENSION]:Pause
		}
		if ${Me.Equip[16].Name.Equal["CB_FISHING_POLE"]}
		{
			if ${Item[-inventory,"${MainHandBeforeFishing}"](exists)}
			{
				Item[-inventory,"${MainHandBeforeFishing}"]:Use	
				MainHandBeforeFishing:Set[NULL]
			}
			if ${Item[-inventory,"${OffHandBeforeFishing}"](exists)}
			{
				Item[-inventory,"${OffHandBeforeFishing}"]:Use	
				MainHandBeforeFishing:Set[NULL]
			}
		}
	}

	method StartFishing()
	{
		Navigator:FaceHeading[${Grind.Hd}]
		if !${Me.Equip[16].Name.Equal["CB_FISHING_POLE"]}
		{
			MainHandBeforeFishing:Set[${Me.Equip[16].Name}]
			OffHandBeforeFishing:Set[${Me.Equip[17].Name}]
			Item[-inventory,"CB_FISHING_POLE"]:Use
		}
		if ${Script[CB_FISHING_EXTENSION].Paused}
		{
			Script[CB_FISHING_EXTENSION]:Resume
		}
	}	
	
	; ------ ASSIST MODE
	member ASSISTState()
	{
		if ${State.NeedAssist[${Target.GUID}]}
		{
			if ${State.HaveAssistPath[${Target.GUID}]}
			{
				if ${Target.Distance} < ${Toon.PullRange}
				{
					if ${Class.NeedPullBuff}
					{
						return CB_PULL_BUFF
					}
					else
					{
						return CB_PULL
					}
				}
				else
				{
					return CB_MOVETO_MOB
				}
			}
			else
			{
				This:Output[Need Path to Mob.]
			}
		}
		return CB_ASSIST_IDLE
	}

	method ASSISTPulse()
	{
		switch ${This.CurrentSubState}
		{
			case CB_PULL
			Class:PullPulse
			break
			
			case CB_PULL_BUFF
			Class:PullBuffPulse
			break
			
			case CB_ASSIST_IDLE
			POI.myobjectstring:Set["0:0:0:0:0:0:0:0:0"]	
			Navigator:ClearPath
			break
			
			case CB_MOVETO_MOB
			Navigator:MoveToMob[${Target.GUID}]	
			break
		}
	}	
	
	member NeedAssist(string MobGUID)
	{	
		variable objectref TargetMob
		TargetMob:Set[${MobGUID}]
		
		if ${Mount.IsMounted}
		{
			return FALSE
		}
		
		if !${TargetMob(exists)} || ${TargetMob.Name.Equal[NULL]} 
		{
			return FALSE
		}	
		
		if (${MobGUID.Equal[${Me.GUID}]} || ${TargetMob.Dead})
		{
			return FALSE
		}
		if !${TargetMob.Attackable}
		{
			return FALSE							
		}
		return TRUE
	}

	member HaveAssistPath(string GUID)
	{
		variable float mobDistance
		variable objectref theMob = ${GUID}
		variable int moveDirectly = ${Toon.PullRange}
		
		mobDistance:Set[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${theMob.X},${theMob.Y},${theMob.Z}]}]		
		if ${moveDirectly} < 40
		{
			moveDirectly:Set[40]
		}		
		if ${mobDistance} < ${moveDirectly} && !${Me.IsPathObstructed[${theMob.X},${theMob.Y},${Math.Calc[${theMob.Z}+0.6]}]}
		{
			return TRUE
		}
		elseif ${Navigator.AvailablePath[${theMob.X},${theMob.Y},${theMob.Z}]}
		{
			return TRUE
		}
		return FALSE	
	}	
	
	member LOOT_ASSISTState()
	{
		if (${State.NeedAssist[${Target.GUID}]} && ${State.HaveAssistPath[${Target.GUID}]}) || ${Mount.IsMounted}
		{
			return CB_IDLE
		}
		return ${This.LOOTState}
	}
	
	method LOOT_ASSISTPulse()
	{
		This:LOOTPulse
	}
	
	member ManualOverride()
	{
		if ${WoWScript[IsMouseButtonDown("LeftButton")]} && ${WoWScript[IsMouseButtonDown("RightButton")]}
		{
			return TRUE
		}
		return FALSE
	}
	
	
	; ------ PARTY MODE	
	; This is where we hook our party stuff to the normal OB states or rewrite the state for Party Mode if needed
		
	/* when we are dead -- no mechanics change -- it's all about getting back to our body baybe */
	member DEAD_PARTYState()
	{
		return ${This.DEADState}
	}
	method DEAD_PARTYPulse()
	{
		switch ${This.CurrentSubState}
		{
		}		
		This:DEADPulse
	}
		
	/* major changes to how this operates -- most party decisions regarding combat are made in this state */
	/* the basic principle is that flags are set based on group member weights in Party:Update */
	/* in combat -- these updates occur every state pulse -- out of combat, the occur in periodic CPU saving pulses */
	variable int LastPartySwitch = 0
	member TOON_PARTYState()
	{	
		variable objectref theMob
		variable bool IsLead = ${Party.IsPartyLeader}
		variable bool IsAlone = ${Party.Alone}
		variable bool FightBack = FALSE
		
		Autoequip:NeedOrGreed	
		if ${LavishScript.RunningTime} <= ${This.TOONState_General_Wait_Until}
		{
			return CB_TOON_WAIT
		}

		if ${Flee.NeedToRun} && ${IsAlone}
		{
			return CB_FLEE
		}

		if ${Me.InCombat} || (!${Party.KillTarget.Equal[NULL]} && ${Object[${Party.KillTarget}].Target(exists)})
		{
			Party:Update
			if !${IsAlone}
			{
				FightBack:Set[TRUE]
			}
			elseif !${Mount.IsMounted}
			{
				FightBack:Set[TRUE]
			}
			if (${Party.NeedHeal} || ${Party.NeedCure}) && ${Me.PctHPs} > 35
			{
				/* we need to make sure I stay alive first */
				FightBack:Set[FALSE]				
			}
			if ${Party.NeedCrowdControl}
			{
				FightBack:Set[FALSE]				
			}
		}
		
		if ${FightBack} 
		{
			if !${Party.KillTarget.Equal[NULL]} && ${Object[${Party.KillTarget}].PctHPs} > 0 && (!${Toon.ValidTarget[${Target.GUID}]} || ${Math.Calc[${LavishScript.RunningTime}-${This.LastPartySwitch}]} > 5000)
			{
				if ${POI.GUID.NotEqual[${Object[${Party.KillTarget}].GUID}]} 
				{
					Target ${Party.KillTarget}
					This.LastPartySwitch:Set[${LavishScript.RunningTime}]
					
					if !${POI.Set[${Object[${Party.KillTarget}].X}:${Object[${Party.KillTarget}].Y}:${Object[${Party.KillTarget}].Z}:${Object[${Party.KillTarget}].GUID}:${Object[${Party.KillTarget}].Name}:MOB:FACTION_NEUTRAL:${Object[${Party.KillTarget}].Level},TRUE]}
					{
						This:Debug[Error: Can not set POI to Target]	
					}
				}				
			}
			elseif ${Toon.ValidTarget[${Target.GUID}]} && ${Target.PctHPs} > 0
			{
				if ${POI.GUID.NotEqual[${Target.GUID}]}
				{
					if !${POI.Set[${Target.X}:${Target.Y}:${Target.Z}:${Target.GUID}:${Target.Name}:MOB:FACTION_NEUTRAL:${Target.Level},TRUE]}
					{
						This:Debug[Error: Can not set POI to Target]	
					}
				}
			}
			elseif ${Me.InCombat} && ${Toon.ValidTarget[${Targeting.TargetCollection.Get[1]}]} && ${Object[${Targeting.TargetCollection.Get[1]}].PctHPs} > 0
			{
				Toon:NeedTarget
				if !${POI.Set[${Object[${Targeting.TargetCollection.Get[1]}].X}:${Object[${Targeting.TargetCollection.Get[1]}].Y}:${Object[${Targeting.TargetCollection.Get[1]}].Z}:${Object[${Targeting.TargetCollection.Get[1]}].GUID}:${Object[${Targeting.TargetCollection.Get[1]}].Name}:MOB:FACTION_NEUTRAL:${Object[${Targeting.TargetCollection.Get[1]}].Level},TRUE]}
				{
					This:Debug[Error: Can not set POI to AGGRO Target]	
					Toon:NeedTarget  
				}
			}			
			
			/* then if we have a target, lets do combat */
			if ${Target(exists)}
			{
				if ${Class.NeedCombatBuff}
				{
					return CB_COMBAT_BUFF
				}
				else
				{
					return CB_COMBAT
				}					
			}
			else
			{	
				/* we have no target, so lets idle */
				if ${Class.NeedCombatIdle}
				{
					return CB_COMBAT_CLASS_IDLE
				}
				return CB_COMBAT_IDLE
			}
		}
		
		if ${Party.NeedHeal}
		{
			return CB_PARTYHEAL
		}

		if ${Party.NeedCrowdControl}
		{
			return CB_CROWDCONTROL
		}
		
		if ${Party.NeedCure}
		{
			return CB_PARTYCURE
		}
		
		if ${Class.NeedRest}
		{
			return CB_REST
		}
		
		if ${Party.NeedRez}
		{
			return CB_PARTYREZ
		}	

		if ${Class.NeedBuff}
		{
			if !${Mount.IsMounted} && 0 < ${Toon.SafeSpotRange}
			{
			return CB_BUFF
			}
		}			
		
		if ${Party.NeedBuff} && !${Mount.IsMounted}
		{
			return CB_PARTYBUFF
		}		
		
		if ${IsAlone} && !${Mount.IsMounted}
		{
			if ${This.PullMobExists[1]} && ${Toon.SafeSpotRange} < 0 
			{
				theMob:Set[${Targeting.TargetCollection.Get[1]}]
			}
		}
		elseif !${Party.KillTarget.Equal[NULL]}
		{
			theMob:Set[${Party.KillTarget}]
		}
		elseif ${IsLead} && !${Mount.IsMounted}
		{
			if ${Toon.PullableTarget}
			{
				theMob:Set[${Targeting.TargetCollection.Get[1]}]
			}			
		}
		
		if ${theMob.GUID(exists)}
		{
			if ${POI.Set[${theMob.X}:${theMob.Y}:${theMob.Z}:${theMob.GUID}:${theMob.Name}:MOB:FACTION_NEUTRAL:${theMob.Level},FALSE]}
			{	
				if ${theMob.Distance} > ${Toon.PullRange} && !${Me.Casting}
				{
					return CB_MOVETO_PULL
				}
				else
				{
					if ${Class.NeedPullBuff}
					{
						return CB_PULL_BUFF
					}
					else
					{
						return CB_PULL
					}
				}
			}
			else
			{
				This:Output["Error: Can not set POI to PULL Target"]			
			}
		}
		if ${Toon.Casting}
		{
			return CB_CASTING
		}
		if ${LavishScript.RunningTime} <= ${This.TOONState_Casting_Wait_Until}
		{
			return CB_CASTING_WAIT
		}				
		if ${LavishScript.RunningTime} <= ${This.TOONState_Flee_Wait_Until} || ${Math.Calc[${LavishScript.RunningTime}-${This.TOONState_Last_Flee_Time}]} < 1500
		{
			return CB_FLEE_WAIT
		}
		return CB_IDLE
	}

	/* just hooking the ones that are different */
	method TOON_PARTYPulse()
	{
		switch ${This.CurrentSubState}
		{
			case CB_PARTYHEAL
			{
				Mount:Dismount
				Target ${Group.Member[${Party.HealUnit}].GUID}
				if !${Party.InRange[${Party.HealUnit},25]}
				{
					This:Output[HealUnit -- Moving within 25 yards.]
					Party:NavToUnit[${Party.HealUnit}]
					return
				}
				This:Output[Party Heal - ${Group.Member[${Party.HealUnit}].Name}]
				Toon:Stop				
				Class:PartyHealPulse
				return
			}
			case CB_PARTYCURE
			{
				Mount:Dismount
				Target ${Group.Member[${Party.CureUnit}].GUID}
				if !${Party.InRange[${Party.CureUnit},25]}
				{
					This:Output[CureUnit -- Moving within 25 yards.]
					Party:NavToUnit[${Party.CureUnit}]
					return
				}
				This:Output[Party Cure - ${Group.Member[${Party.CureUnit}].Name}]
				Toon:Stop
				Class:PartyCurePulse
				return
			}
			case CB_PARTYREZ
			{
				Mount:Dismount
				Target ${Group.Member[${Party.RezUnit}].GUID}				
				if !${Party.InRange[${Party.RezUnit},25]}
				{
					This:Output[RezUnit -- Moving within 25 yards.]
					Party:NavToUnit[${Party.RezUnit}]
					return
				}
				This:Output[Party Rez - ${Group.Member[${Party.RezUnit}].Name}]		
				Toon:Stop				
				Class:PartyRezPulse
				return
			}
			case CB_PARTYBUFF
			{
				Mount:Dismount
				Target ${Group.Member[${Party.BuffUnit}].GUID}
				if !${Party.InRange[${Party.BuffUnit},25]}
				{
					This:Output[BuffUnit -- Moving within 25 yards.]
					Party:NavToUnit[${Party.BuffUnit}]
					return
				}
				This:Output[Party Buff - ${Group.Member[${Party.BuffUnit}].Name}]	
				Toon:Stop				
				Class:PartyBuffPulse
				return
			}
			case CB_CROWDCONTROL
			{
				Mount:Dismount
				Target ${Party.CrowdControl}
				if ${Math.Distance[${Me.Location},${Object[${Party.CrowdControl}].Location}]} > 25
				{
					This:Output[Crowd Control -- Moving within 25 yards.]
					Navigator:MoveToMob[${Party.CrowdControl}]
					return
				}
				This:Output[Crowd Control  - ${Object[${Party.CrowdControl}].Name}]	
				Toon:Stop
				Class:CrowdControlPulse
				return				
			}
			case CB_MOVETO_PULL
			{
				Mount:Dismount	
				Party:NeedTarget
				if !${Navigator.IsMovingToCurrentPOI}
				{
					Navigator:MoveToCurrentPOI
				}
				return
			}
			case CB_PULL
			{	
				Navigator:ClearPath
				Party:NeedTarget
				Class:PullPulse
				return
			}
		}
		This:TOONPulse			
	}
	
	/* mechanics of NPC remain unchanged -- decision to visit NPC is toon specific rather than party specific */
	/* this means the party member will go repair and then come back to group in ROAM */
	member NPC_PARTYState()
	{
		return ${This.NPCState}
	}
	method NPC_PARTYPulse()
	{
		switch ${This.CurrentSubState}
		{
		}		
		This:NPCPulse
	}	
	
	/* mechanics of autoequip and such remain unchanged */
	member ITEM_PARTYState()
	{
		return ${This.ITEMState}
	}		
	member method ITEM_PARTYPulse()
	{
		switch ${This.CurrentSubState}
		{
		}	
		This:ITEMPulse
	}
	
	/* the same old loot stuff with a couple of extra checks against my party members POI */
	/* includes a broadcast using Uplink of POI when you are preparing to loot to ensure POI is current */
	/* uses Party.IgnoreLoot -- the intent is to prevent two party members from going after the same loot */
	member LOOT_PARTYState()
	{
		variable guidlist list
		variable int Index
		variable bool Found = FALSE
		variable int bltimer
		
		Autoequip:NeedOrGreed						

		if ${Me(unit).Casting.Name.Token[1," "].Equal[Skinning]}
		{
			This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
			return CB_SKIN_CORPSE
		}
		if ${Me(unit).Casting.Name.Token[1," "].Equal[Herbalism]}
		{
			This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
			return CB_LOOT_HERB
		}
		if ${Me(unit).Casting.Name.Token[1," "].Equal[Mining]}
		{
			This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
			return CB_LOOT_ORE
		}				
		if ${Me(unit).Casting.Name.Token[1," "].Equal[Opening]}
		{
			This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
			return CB_OPENING
		}

		if ${LavishScript.RunningTime} <= ${This.LOOTState_Loot_Wait_Until}
		{
			return CB_LOOT_WAIT
		}

		if ${LootWindow(exists)}
		{
			if ${LootWindow.Count} > 0 && (${Inventory.FreeSlots} > 0)
			{
				This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_After_Until_Timeout} * ${Bot.GlobalCooldown})]}]
				This.LOOTState_Skip_Scans:Set[0]
				return CB_LOOTALL
			}
			else
			{
				This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_After_Until_Timeout} * ${Bot.GlobalCooldown})]}]
				This.LOOTState_Skip_Scans:Set[0]
				return CB_CLOSE_LOOT
			}
		}

		if ${LavishScript.RunningTime} >= ${LOOTState_Skip_Scans}
		{
			This.LOOTState_Skip_Scans:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Skip_Scans_Timeout} * ${Bot.GlobalCooldown})]}]
			if (${Inventory.FreeSlots} > 0) && ${UIElement[chkLoot@Config@InvPages@Inventory@Pages@Cerebrum].Checked}
			{
				list:Clear
				list:Search[-units,-dead,-nearest]
				Index:Set[0]
				if ${list.Count} > 0
				{
					while ${list.GUID[${Index:Inc}](exists)} && !${Found}
					{
						if ${Unit[${list.GUID[${Index}]}].Lootable}
						{
							if ${POI.Set[${Unit[${list.GUID[${Index}]}].X}:${Unit[${list.GUID[${Index}]}].Y}:${Unit[${list.GUID[${Index}]}].Z}:${list.GUID[${Index}]}:${Unit[${list.GUID[${Index}]}].Name}:LOOT:FACTION_NEUTRAL:${Unit[${list.GUID[${Index}]}].Level}]}
							{
								Found:Set[TRUE]
							}
						}
						if ${Unit[${list.GUID[${Index}]}].Skinnable}
						{
							if ${Toon.CanSkinMob[${list.GUID[${Index}]}]}
							{
								if ${POI.Set[${Unit[${list.GUID[${Index}]}].X}:${Unit[${list.GUID[${Index}]}].Y}:${Unit[${list.GUID[${Index}]}].Z}:${list.GUID[${Index}]}:${Unit[${list.GUID[${Index}]}].Name}:SKILL_SKINNING:FACTION_NEUTRAL:${Unit[${list.GUID[${Index}]}].Level}]}
								{
									Found:Set[TRUE]
								}
							}
						}
					}
				}
			}
			if !${Found} && ${Toon.HasSkill[SKILL_HERBALISM]} && (${Inventory.FreeSlots} > 0) && ${UIElement[chkGather@Config@InvPages@Inventory@Pages@Cerebrum].Checked}
			{
				list:Clear
				list:Search[-gameobjects,-herb,-usable,-unlocked,-nearest]
				Index:Set[0]
				while ${list.GUID[${Index:Inc}](exists)} && !${Found}
				{
					if ${Toon.SkillLevel[Herbalism]} >= ${OBDB.GetLevel[${Object[${list.GUID[${Index}]}].Name}]} 
					{
						if ${POI.Set[${Object[${list.GUID[${Index}]}].X}:${Object[${list.GUID[${Index}]}].Y}:${Object[${list.GUID[${Index}]}].Z}:${list.GUID[${Index}]}:${Object[${list.GUID[${Index}]}].Name}:SKILL_HERBALISM:FACTION_NEUTRAL:${Object[${list.GUID[${Index}]}].Level}]}
						{
							Found:Set[TRUE]
						}
					}
					else
					{
						This:Output[do Not want ${Object[${list.GUID[${Index}]}].Name} level to high.]
					}
				}
			}
			if !${Found} && ${Toon.HasSkill[SKILL_MINING]} && ${Item[-inventory,"Mining Pick"](exists)} && (${Inventory.FreeSlots} > 0) && ${UIElement[chkGather@Config@InvPages@Inventory@Pages@Cerebrum].Checked}
			{
				list:Clear
				list:Search[-gameobjects,-mine,-usable,-unlocked,-nearest]
				Index:Set[0]
				while ${list.GUID[${Index:Inc}](exists)} && !${Found}
				{
					if ${Toon.SkillLevel[Mining]} >= ${OBDB.GetLevel[${Object[${list.GUID[${Index}]}].Name}]} 
					{
						if ${POI.Set[${Object[${list.GUID[${Index}]}].X}:${Object[${list.GUID[${Index}]}].Y}:${Object[${list.GUID[${Index}]}].Z}:${list.GUID[${Index}]}:${Object[${list.GUID[${Index}]}].Name}:SKILL_MINING:FACTION_NEUTRAL:${Object[${list.GUID[${Index}]}].Level}]}
						{
							Found:Set[TRUE]
						}
					}
					else
					{
						This:Output[do Not want ${Object[${list.GUID[${Index}]}].Name} level to high.]
					}
				}
			}
			/* quest objects */
			if !${Found} && (${Inventory.FreeSlots} > 0) && ${UIElement[chkHarvestQuests@Config@InvPages@Inventory@Pages@Cerebrum].Checked}
			{
				list:Clear
				list:Search[-gameobjects, -nearest, -chest, -unlocked, -usable]
				Index:Set[0]
				while ${list.GUID[${Index:Inc}](exists)} && !${Found}
				{
					if ${POI.Set[${Object[${list.GUID[${Index}]}].X}:${Object[${list.GUID[${Index}]}].Y}:${Object[${list.GUID[${Index}]}].Z}:${list.GUID[${Index}]}:${Object[${list.GUID[${Index}]}].Name}:QUESTOBJECT:FACTION_NEUTRAL:${Object[${list.GUID[${Index}]}].Level}]}
					{
						Found:Set[TRUE]
					}
				}
			}
		}
		
		if ${POI.MetaType.Equal[LOOT]}
		{
			if ${Party.IgnoreLoot[${POI.GUID}]}
			{
				This:Output["Party Looted: Skipping ${POI.Type} for ${POI.Name}"]
				POI:Clear
				WoWScript ClearTarget()
				This.LOOTState_Skip_Scans:Set[0]
				return CB_LOOT_WAIT
			}
			else
			{
				if ${POI.IsBlacklisted} || !${Object[${POI.GUID}](exists)}
				{
					POI:Clear
					This.LOOTState_Skip_Scans:Set[0]
					return CB_LOOT_WAIT
				}
				else
				{
					if ${POI.InUseRange}
					{
						if (${POI.Type.Equal[LOOT]} && !${Unit[${POI.GUID}].CanLoot})
						{
							POI:Clear
							This.LOOTState_Skip_Scans:Set[0]
							return CB_LOOT_WAIT							
						}
						if ${Movement.Speed} || ${Toon.Sitting}
						{
							return CB_LOOT_GETTING_READY
						}
						else
						{
							Party.Uplink:Broadcast[POI,${POI.Type}]	
							This.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${This.LOOTState_Loot_Wait_Until_Timeout} * ${Bot.GlobalCooldown})]}]
							return CB_USE_LOOT
						}
					}
					else
					{
						Party.Uplink:Broadcast[POI,${POI.Type}]	
						return CB_LOOT_MOVE		
					}
				}
			}
		}
		return CB_IDLE	
	}

	/* the mechanics of looting dont change -- so just hook existing */
	method LOOT_PARTYPulse()
	{
		switch ${This.CurrentSubState}
		{
		}		
		This:LOOTPulse
	}
	
	/* quest mechanics don't change */
	member QUEST_PARTYState()
	{
		return ${This.QUESTState}
	}	
	method QUEST_PARTYPulse()
	{
		switch ${This.CurrentSubState}
		{
		}		
		This:QUESTPulse
	}	
	
	/* if you are the party leader -- roam is pretty much like normal */
	/* if you are not the party leader, your POI is the party leader or his destination in ROAM */
	/* combat, rez and buff decisions are all handled in Toon at a higher priority over Looting, etc. */
	member ROAM_PARTYState()
	{		
		if !${Me.Dead} && !${Me.Ghost} && ${Mount.NeedMount}
		{
			return CB_MOUNT
		}
		
		if !${Me.Dead} && !${Me.Ghost} && ${POI.Distance} <= ${Mount.DismountDistance} && ${Mount.IsMounted}
		{
			return CB_DISMOUNT
		}
		
		if ${Me.Level} != ${Toon.Level}
		{
			return CB_LEVELUP
		}	

		if ${Party.NeedRest}
		{
			return CB_PARTY_IDLE
		}

		/* anyone who is not the leader needs to follow around -- all combat decisions are now made in TOON */
		if  !${WoWScript[IsPartyLeader()]}
		{
			if ${POI.Type.Equal[GROUP]} && !${Party.InRange[${WoWScript[GetPartyLeaderIndex()]},50]}
			{
				return CB_FOLLOW_LEADER		
			}
			if ${Party.InRange[${WoWScript[GetPartyLeaderIndex()]},50]}
			{
				return CB_FOLLOW_LEADER						
			}
			if ${Party.SetPOI_ToUnit[${WoWScript[GetPartyLeaderIndex()]}]}
			{
				return CB_FOLLOW_LEADER
			}
			if ${Party.SetPOI_ToDestination[${WoWScript[GetPartyLeaderIndex()]}]}
			{
				return CB_FOLLOW_LEADER
			}
			return CB_PARTY_IDLE
		}
		return ${This.ROAMState}
	}	
	
	method ROAM_PARTYPulse()
	{
		switch ${This.CurrentSubState}
		{
			case CB_FOLLOW_LEADER
			{
				if ${Mount.NeedMount}
				{
					Grind.CurrentGrind.CurrentHotspot:Set[1]				
					Mount:Mount
					return
				}
				if ${POI.Distance} <= ${Mount.DismountDistance} && ${Mount.IsMounted}
				{
					Mount:Dismount
				}
				if ${POI.Distance} < ${Navigator.GetPercision}
				{
					POI.myobjectstring:Set["0:0:0:0:0:0:0:0:0"]
					POI.Current:Set[${This.myobjectstring.Token[4,:]}]		
					Navigator:ClearPath
					Toon:Stop
					return
				}				
				if ${Party.InRange[${WoWScript[GetPartyLeaderIndex()]},12]}
				{
					Toon:Stop
					return
				}
				if ${Party.InRange[${WoWScript[GetPartyLeaderIndex()]},50]}
				{
					Party:NavToUnit[${WoWScript[GetPartyLeaderIndex()]}]
					return
				}
				if !${Navigator.IsMovingToCurrentPOI}
				{
					Navigator:MoveToCurrentPOI
					return					
				}
			}
			case CB_PARTY_IDLE
			{
				if !${Party.NeedRest}
				{
				This:Output["Cant find a connection to Leader or Destination"]
				}
				else
				{
				This:Output["Waiting on resting party member."]					
				}
				return
			}
		}
		This:ROAMPulse
	}	
}