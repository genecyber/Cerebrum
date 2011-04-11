; -------------------------------------------------------------------------
; Track info about previously encountered mobs
; Let OpenBot learn about the mobs it encounters.
; Kz v. 1.3
;
; MobInfo processes messages to extract how a mob (name) reacted in the past.
;
; For instance, if a mob type had tried to run during a previous fight, MobInfo would have recorded this and let the routine
; expect the mob to try to run during future fights. As such, the routine could be prepared to either chase or stop the runner
; at low mob health.
;
; MobInfo is NOT used to detect the current mob status.  Its ONLY use is to provide the routines information about what to expect
; from the mob during the fight; i.e. runner, immune to fire, does fire damage, etc.
;
; -------------------------------------------------------------------------
; To use
;
; 	1: Include this file at the start of your class routine iss file by:
;
; 		#include oMobInfo.iss							/* track mob historical info - runner, immunities, magical damage type	*/
;
; 	2: In your class Initialize() add the line:
;
;		MobInfo:Initialize								/* initialzie and load old mob historical information		*/
;
; 	2: In your class Shutdown() add the line:
;
;		MobInfo:Shutdown								/* cleanup and save mob information							*/
;
; -------------------------------------------------------------------------
;
; MobInfo:Initialize							Initialize  and load old mob information
; MobInfo:Shutdown								Cleanup and save mob information
; 
; ${MobInfo.chkRunner}							TRUE if the current target (name) has previously been a runner
; ${MobInfo.chkCast[SpellName]}					TRUE if SpellName is available and target is not immune to the attack 
; ${MobInfo.chkDamage[DamageType]}				TRUE if target does DamageType of damage
;
; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
;
; Combat movement support
;
; CMovement:ToMelee								Moves to within melee attack range
; CMovement:ToRanged							Moves to within ranged attack range.  Will attempt to find a safe spot to move.
;
; ${CMovement.isFacingAway}						TRUE if mob is facing away from us
; CMovement:FaceXYZ								Face the specified coordinates
;
; CMovement:MoveForward							Move forward for CM_TIME milliseconds
; CMovement:MoveBackward						Move backward for CM_TIME milliseconds
; CMovement:MoveLeft							Move left for CM_TIME milliseconds
; CMovement:MoveForwardLeft						Move forward and left for CM_TIME milliseconds
; CMovement:MoveRight							Move right for CM_TIME milliseconds
; CMovement:MoveForwardRight					Move forward and right for CM_TIME milliseconds
;
; Class dependencies:
;	${Class.MinMelee}							Returns the minimum melee setting as set by the UI slider
;	${Class.MaxMelee}							Returns the minimum melee setting as set by the UI slider and adjusted wrt mob facing direction and if it is an expected runner
;	${Class.MinRanged}							Returns the minimum ranged setting as set by the UI slider
; 	${Class.MaxRanged}							Returns the minimum ranged setting as set by the UI slider and adjusted wrt mob facing direction and if it is an expected runner
;
; -------------------------------------------------------------------------
; MSGPRCTYPE selects when the combat messages should be processed.
;	TRUE		messages will be processed as they occure (real time).  no special atcti3on is required in class routine.
;	FALSE		messages porcessing will be given very low priority and processed during low load times.

;#define	MSGPRCTYPE		TRUE										/* messages to be processed real time						*/
#define		MSGPRCTYPE		FALSE										/* messages to be processed low pority						*/
					 
#ifndef		KZ_MSGLVL
 #define	KZ_MSGLVL		0											/* status messages: 0: disable, 1: limited, 2: verbose, 3: debug		*/
#endif 

; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
#if MSGPRCTYPE
 #define	MSGHDR			atom										/* process messages in real-time							*/
 #define	MI_TYPE_MSG		real time mode
#else 																																	
 #define MSGHDR				function									/* batch process messages									*/
 #define	MI_TYPE_MSG		low-priority  mode
#endif
			 
#define		CM_TIME			1000										/* move time for combat moves								*/					 
				  
; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
objectdef cMobInfo inherits cBase
{
	; ---------------------------------------------------------------------
	; Mob info lists
	
	variable string MobFileName = "./routines/mobinfo.xml"				/* location to save and load mob info lists					*/
	
	variable set MobImmunities											/* mobs and their immunities								*/
	variable set MobRunners												/* mobs that have tried to run away							*/
	variable set MobDamage												/* types of magical damage mobs have done					*/
					   
								
	; ---------------------------------------------------------------------
	; check if mob will try to run
	member chkRunner()
	{
		This:MIDebug[3, "MobInfo:chkRunner checking ${Target.Name}"]
		
		if ${This.MobRunners.Contains[${Target.Name}]}
			{
			This:MIDebug[2, "MobInfo:chkRunner This mob will try to run"]
			return TRUE 												/* this type of mob has previously tried to run				*/
			}
			
		return FALSE
	}
	
	; ---------------------------------------------------------------------
	; check if attack spell is ready and usable against target
	member chkCast(string ASpell)
	{
		This:MIDebug[3, "MobInfo:chkCast checking ${Target.Name}#${ASpell}"]
		
		if !${Toon.canCast[${ASpell}]}
			return FALSE												/* spell is not available or not ready						*/	
			
		if ${This.MobImmunities.Contains[${Target.Name}#${ASpell}]}
			return FALSE												/* target is immune to this attack							*/	
			
		This:MIDebug[2, "MobInfo:chkCast OK to use ${ASpell} on ${Target.Name}"]
		return TRUE														/* this spell should be useful								*/
	}

	; ---------------------------------------------------------------------
	; check if target does this type of damage
	member chkDamage(string DType)
	{
		; This:MIDebug[3, "chkDamage checking ${Target.Name}#${DType}"]
		
		if ${This.MobDamage.Contains[${Target.Name}#${DType}]}
			return TRUE													/* target does this type of damage							*/	
			
		return FALSE													/* this spell should be useful								*/
	}

	; ---------------------------------------------------------------------
	; load the mob info lists history
	method Initialize()
	{
		This:Output[Loading mob info from ${MobFileName}: MI_TYPE_MSG]
		
		LavishSettings:AddSet[Histroy]
		LavishSettings[Histroy]:Import[${MobFileName}]
		
		This:InitTriggers												/* setup to trap and process the messages					*/
		
		This.MobImmunities:Clear										/* clear mob immunity info									*/
		This.MobRunners:Clear											/* clear mob runner info									*/
		This.MobDamage:Clear											/* clear mob damabe type info								*/
		
		This:LoadList[MobImmunities]
		This:LoadList[MobRunners]
		This:LoadList[MobDamage]
		
		#if !MSGPRCTYPE
			Bot:AddPulse["MobInfo","Pulse",100,TRUE,TRUE]				/* call Pulse every 100 OB cycles							*/
		#endif
	}
		
	method LoadList(string theList)
	{
		variable iterator iter
		
		if !${LavishSettings[Histroy].FindSet[${theList}](exists)}
		{
			LavishSettings[Histroy]:AddSet[${theList}]
		}		
		LavishSettings[Histroy].FindSet[${theList}]:GetSettingIterator[iter]
		
		iter:First
		while ${iter.IsValid}
		{
			${theList}:Add[${iter.Key}]
			iter:Next
		}
	}
		   
		   
	; ---------------------------------------------------------------------
	; cleanup and save the mob info lists for the future
	method Shutdown()
	{
		This:RemoveTriggers												/* no need to trap and process the messages					*/
		
		This:ExportList[MobImmunities]
		This:ExportList[MobRunners]
		This:ExportList[MobDamage]
							 
		LavishSettings[Histroy]:Export[${MobFileName}]
	}
		
	method ExportList(string theList)
	{
		variable iterator iter

		LavishSettings[Histroy].FindSet[${theList}]:Clear
		${theList}:GetIterator[iter]
		iter:First
		while ${iter.IsValid}
		{
			LavishSettings[Histroy].FindSet[${theList}]:AddSetting[${iter.Key},${iter.Key}]
			iter:Next
		}
	}
		
	; ---------------------------------------------------------------------
	; called by OB every 100 OB cycles
	#if !MSGPRCTYPE
	method Pulse()
	{
		; This:Output["MobInfo: Pulse!"]
		ExecuteQueued						   							/* process one message from the message queue				*/
	}
	#endif
		  
		  
	; ---------------------------------------------------------------------
	; setup to trap and process messages
	
	method InitTriggers()
	{
		AddTrigger AtProcMsgRunner "[Event:@eventid@:CHAT_MSG_MONSTER_EMOTE](\"%%s attempts to run away in fear!\",\"@Mob@\",@*@"
		AddTrigger AtProcMsgImmune "[Event:@eventid@:CHAT_MSG_SPELL_SELF_DAMAGE](\"Your @ReactCast@ failed. @Mob*@ is immune.@*@"
		AddTrigger AtProcMsgDamage "[Event:@eventid@:CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS](\"@Mob@ @*@ you for @*@ @MagicType@ damage.@*@"
		AddTrigger AtProcMsgDamage "[Event:@eventid@:CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE](\"@Mob@'s @*@ you for @*@ @MagicType@ damage.@*@"
	}

	method RemoveTriggers()
	{
		RemoveTrigger AtProcMsgRunner
		RemoveTrigger AtProcMsgImmune
		RemoveTrigger AtProcMsgDamage
	}
	
			 
	; ---------------------------------------------------------------------
	; Process: Mob attempts to run away in fear
	method ProcMsgRunner(string Mob)
	{	
		if !${This.MobRunners.Contains[${Mob}]}
		{
			This:MIDebug[1, "MobInfo:ProcMsgRunner: Added ${Mob} to the runner list"]
			This.MobRunners:Add[${Mob}]									/* add new mob runner										*/
		}
		else
			This:MIDebug[3, "MobInfo:ProcMsgRunner: ${Mob} is already in runners list"]
	}
	
	; ---------------------------------------------------------------------
	; Process: Your Cast failed. Mob is immune
	method ProcMsgImmune(string Mob, string MagicType)
	{	
		variable string MobId
		MobId:Set[${Mob}#${MagicType}]									/* damage mob#attack string									*/
		
		if !${This.MobImmunities.Contains[${MobId}]}
		{
			This:MIDebug[1, "MobInfo:ProcMsgImmune: Added ${MobId} to the mob immune list"]
			This.MobImmunities:Add[${MobId}]							/* add new mob immunity list								*/
		}
		else
			This:MIDebug[3, "MobInfo:ProcMsgImmune: ${MobId} is already in mob immune list"]
	}
			
	; ---------------------------------------------------------------------
	; Process: Mob Dam you for points MagicType damage
	; Process: Mob's Cast Dam you for points MagicType damage
	method ProcMsgDamage(string Mob, string MagicType)
	{	
		variable string MobId
		MobId:Set[${Mob}#${MagicType}]									/* damage mob#attack string									*/
		
		if !${This.MobDamage.Contains[${MobId}]}
		{
			This:MIDebug[1, "MobInfo:ProcMsgDamage: Added ${MobId} to the mob damage list"]
			This.MobDamage:Add[${MobId}]								/* add new mob damage list									*/
		}
		else
			This:MIDebug[3, "MobInfo:ProcMsgDamage: ${MobId} is already in mob damage list"]
	} 
	
	; ---------------------------------------------------------------------
	method MIDebug(int Lvl, string Msg)
	{
		if ${Lvl} <= KZ_MSGLVL
			This:Output[${Msg}]											/* show the enabled message									*/
	}
}  		
	
	
; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
; hooks and controls for MobInfo message processing.

variable oMobInfo MobInfo

				  
; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
; message hooks

; Process: Mob attempts to run away in fear
MSGHDR AtProcMsgRunner(string Line, int eventid, string Mob)
{
	MobInfo:ProcMsgRunner[${Mob}]
}
	
; Process: Your Cast failed. Mob is immune
MSGHDR AtProcMsgImmune(string Line, int eventid, string MagicType, string Mob)
{	
	MobInfo:ProcMsgImmune[${Mob},${MagicType}]
}
	  
; Process: Mob Dam you for points MagicType damage
; Process: Mob's Cast Dam you for points MagicType damage
MSGHDR AtProcMsgDamage(string Line, int eventid, string Mob, string MagicType)
{
	MobInfo:ProcMsgDamage[${Mob},${MagicType}]
}
	
/* >>>>>>>>>>>>>>>>>>>>>>>>> End of oMobInfo <<<<<<<<<<<<<<<<<<<<<<<<<<< */
				  
; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
;
; NOTE: The following code is not a part of oMobInfo, but is included here
;					to avoid unnecessary file clutter.
;
; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
;
; Routine Combat Movement support
;
; ${Class.MinMelee}				Returns the minimum melee setting as set by the UI slider
; ${Class.MaxMelee}				Returns the minimum melee setting as set by the UI slider and adjusted wrt mob facing direction and if it is an expected runner
; ${Class.MinRanged}			Returns the minimum ranged setting as set by the UI slider
; ${Class.MaxRanged}			Returns the minimum ranged setting as set by the UI slider and adjusted wrt mob facing direction and if it is an expected runner
;
; CMovement:ToMelee				Moves to within melee attack range
; CMovement:ToRanged			Moves to within ranged attack range.  Will attempt to find a safe spot to move.
;
; ${CMovement.isFacingAway}		True if mob is facing away from us
; CMovement:FaceXYZ				Face the specified corrdinates
;
; CMovement:MoveForward			Move forward for CM_TIME milliseconds
; CMovement:MoveBackward		Move backward for CM_TIME milliseconds
; CMovement:MoveLeft			Move left for CM_TIME milliseconds
; CMovement:MoveForwardLeft		Move forward and left for CM_TIME milliseconds
; CMovement:MoveRight			Move right for CM_TIME milliseconds
; CMovement:MoveForwardRight	Move forward and right for CM_TIME milliseconds
;
; Message displays are controled by KZ_MSGLVL as defined in the class routine  
; 			0: disable, 1: limited, 2: verbose, 3: debug
;
; -------------------------------------------------------------------------

objectdef oCMovement inherits oBase
{
	; ---------------------------------------------------------------------
	; ---------------------------------------------------------------------
	; movement support
	
	; ---------------------------------------------------------------------
	; move to withing melee range
	method ToMelee()
	{
		This:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
		if ${Target.Distance} > ${Class.MinMelee} && ${Target.Distance} < ${Class.MaxMelee}
			This:StopMovement              								/* ensure we aren't moving									*/
			
		elseif ${Target.Distance} > ${Class.MaxMelee}
;			Navigator:MoveToLoc[${Target.X},${Target.Y},${Target.Z}]
			This:MoveForward
			
		elseif ${Target.Distance} < ${Class.MinMelee}
			This:MoveBackward
	}
			
	; ---------------------------------------------------------------------
	; smart movement to a safe ranged attack location
	
	variable point3f CurrentSafe										/* current safest locaiton									*/
	
	method ToRanged()
	{
		; use DesiredDistance as the desired distance from the target as well as the safe area size
		variable float DesiredDistance = ${Math.Calc[${Class.MinRanged} + (${Class.MaxRanged} - ${Class.MinRanged}) / 2]}
								   
		variable int Index												/* used to index through the test mobs						*/
		variable guidlist MobList										/* list of test mobs										*/
		
		variable float CurrentSafeRange = 9999							/* distance to safe area									*/
;		variable point3f CurrentSafe									/* current safest locaiton									*/
		variable int CurrentMobs = 9999									/* number of mobs around safest location					*/
		
		
		variable int Degrees											/* current test direction wrt the target					*/
		variable point3f TestLoc										/* new test loccaiton										*/
		variable float TestDist											/* distance from us to test location						*/

		variable float SafeHeading										/* direction of safe location relitve to our heading		*/
							   
		; ----------------------------------------------------------------------
		; check for easy conditions
		
  		if !${Target(exists)} || ${Target.Dead}
			{
			This:StopMovement              								/* ensure we aren't moving									*/
			return														/* quit if we don't have a target							*/
			}
			
		if ${Target.Distance} > ${Class.MinRanged} && ${Target.Distance} < ${Class.MaxRanged}
		{
			This:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
			This:StopMovement              								/* ensure we aren't moving									*/
			return
		}
			
		if ${Target.Distance} > ${Class.MaxRanged}
		{
			This:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
			This:MoveForward											/* run to within range of target							*/
			return
		}
		   
		if ${Movement.Speed} || ${ISXWoW.Facing}
			return														/* we have not reached final position						*/

		; ----------------------------------------------------------------------
		; we are trying to move away from the taget.  find a safe location
		if ${Math.Distance[${Me.Location},${CurrentSafe}]} < 40 && ${Math.Distance[${Target.Location},${CurrentSafe}]} < ${Class.MaxRanged}
			This:KZDebug[2, "ToRanged: Using old safe spot!"]			/* use the old safe location								*/
			
		else
		{
			; find a new safe location
			This:KZDebug[2, "ToRanged: Trying to find a new save spot: ${Math.Distance[${Me.Location},${CurrentSafe}]} ${Math.Distance[${Target.Location},${CurrentSafe}]}"]
			
			if ${DesiredDistance} < ${Class.MinRanged} + 5
				DesiredDistance:Set[${Class.MinRanged} + 5]				/* make sure we have a min range to work in					*/
										   
			for (Degrees:Set[0]; ${Degrees} < 360; Degrees:Inc[10])
			{
				; Find a new test location
				TestLoc.X:Set[ ${Target.X} + ${DesiredDistance} * ${Math.Cos[${Degrees}].Precision[6]} ]
				TestLoc.Y:Set[ ${Target.Y} - ${DesiredDistance} * ${Math.Sin[${Degrees}].Precision[6]} ]
				TestLoc.Z:Set[ ${ISXWoW.CollisionTest[${TestLoc.X},${TestLoc.Y},${Math.Calc[${Me.Z}+4]},${TestLoc.X},${TestLoc.Y},${Math.Calc[${Me.Z}-4]}].Z}+0.6 ]
;;<<<			TestLoc.Z:Set[ (${Me.Z} + ${Target.Z}) / 2 ]
				TestDist:Set[ ${Math.Distance[${Me.Location},${TestLoc}]} ]
						  
				; This:KZDebug[3, "ToRanged: ${CurrentSafeRange} ${Degrees} ${TestDist}: ${TestLoc.X} ${TestLoc.Y} ${TestLoc.Z}"]
				if ${CurrentSafeRange} < 9999 && ${CurrentSafeRange} < ${TestDist}
					continue							   				/* the test location will not be better for us				*/
										 
				; This:KZDebug[3, "ToRanged: Obstructed 1: ${Degrees} ${Me.IsPathObstructed[ ${TestLoc}, ${TestDist}, ${Me.Location} ]} ${Me.IsPathObstructed[ ${Me.Location}, ${TestDist}, ${TestLoc} ]}"]
				if ${Me.IsPathObstructed[ ${TestLoc}, ${TestDist}, ${Me.Location} ]}
					continue							   				/* we can not get to the test location						*/
				if ${Me.IsPathObstructed[ ${Me.Location}, ${TestDist}, ${TestLoc} ]}
					continue							   				/* we can not get to the test location						*/
					
				; This:KZDebug[3, "ToRanged: Obstructed 2: ${Degrees} ${Me.IsPathObstructed[ ${Target.Location}, ${DesiredDistance}, ${TestLoc} ]} ${Me.IsPathObstructed[ ${TestLoc}, ${DesiredDistance}, ${Target.Location} ]}"]
				if ${Me.IsPathObstructed[ ${Target.Location}, ${DesiredDistance}, ${TestLoc} ]}
					continue							   				/* we can not shoot from the test location					*/
				if ${Me.IsPathObstructed[ ${TestLoc}, ${DesiredDistance}, ${Target.Location} ]}
					continue							   				/* we can not shoot from the test location					*/
					
				MobList:Clear
;				MobList:Search[-units, -nearest, -alive, -hostile, -untapped, -notflying, -attackable, -range 0-${DesiredDistance}, -origin,${TestLoc.X},${TestLoc.Y},${TestLoc.Z}]
				MobList:Search[-units, -nearest, -alive, -hostile, -untapped, -notflying, -attackable, -range 0-30, -origin,${TestLoc.X},${TestLoc.Y},${TestLoc.Z}]
				if ${MobList.Count} > ${CurrentMobs}
					continue							   				/* not as safe as previous spot								*/
	
				; this is the best spot we have found so far				
				This:KZDebug[3, "ToRanged: ${Degrees}  MobCount ${MobList.Count} ${CurrentMobs}"]
				CurrentSafe:Set[${TestLoc}]
				CurrentSafeRange:Set[${TestDist}]
				CurrentMobs:Set[${MobList.Count}] 
			}
				 
			if ${CurrentSafeRange} >= 9999
				This:KZDebug[2, "ToRanged: No safe spot found!"]
		}
							
		; ----------------------------------------------------------------------
		; safest location (may still not be all that safe!) found.  move to new location
		
		SafeHeading:Set[${Math.Abs[${Me.Heading} - ${Me.HeadingTo[${CurrentSafe.X},${CurrentSafe.Y}]}]}]
		
		; This:KZDebug[3, "ToRanged:  Range:${CurrentSafeRange}  Heading:${SafeHeading} ${CurrentSafe.X.Precision[3]} ${CurrentSafe.Y.Precision[3]}"]
		if ${CurrentSafeRange} >= 9999 || (${SafeHeading} >= 180-20 && ${SafeHeading} <= 180+20)
		{
			This:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
			
			if !${Me.Buff[Dazed](exists)}
			{
				This:MoveBackward
				WoWPress Jump
			}
			else
				This:MoveBackward
		}
			
		elseif ${SafeHeading} >= 340 && ${SafeHeading} <= 20
			This:MoveForward											/* move forward, faster than backing away					*/
																												 
		elseif ${SafeHeading} >= 20 && ${SafeHeading} <= 70
			This:MoveForwardRight										/* move forward and right									*/
		
		elseif ${SafeHeading} >= 70 && ${SafeHeading} <= 110
			This:MoveRight												/* straff right												*/
			
		elseif ${SafeHeading} >= 290 && ${SafeHeading} <= 340
			This:MoveForwardLeft										/* move forward and left									*/
			
		elseif ${SafeHeading} >= 250 && ${SafeHeading} <= 290
			This:MoveLeft												/* straff left												*/
			
		elseif ${Toon.canCast[Blink]}
		{
			This:FaceXYZ[${CurrentSafe.X},${CurrentSafe.Y},${CurrentSafe.Z}]	/* let the mages use blink							*/
			Toon:CastSpell[Blink]
		}
			 
		else
		{
			This:FaceXYZ${CurrentSafe.X},${CurrentSafe.Y},${CurrentSafe.Z}]
			This:MoveForward       										/* just move												*/
		}			
	}		
			   
	; ---------------------------------------------------------------------
	; TRUE if the target is facing away from us
	member isFacingAway()
	{
		if ${Math.Abs[${Target.Heading} - ${Me.HeadingTo[${Target.X},${Target.Y}]}]} < 90
			return TRUE
			
		return FALSE
	}
			
	; ---------------------------------------------------------------------
	; face the specifed location
	method FaceXYZ(float X, float Y, float Z)
	{
		if (${X} || ${Y} || ${Z}) && ${Math.Abs[${Me.Heading}-${Me.HeadingTo[${X},${Y}]}]} > 20
			Face -fast ${X} ${Y}
	}

	; ---------------------------------------------------------------------
	; move forward
	method MoveForward()
	{
		if ${Movement.Backward}
			move -stop backward
		if ${Movement.Left}
			move -stop left
		if ${Movement.Right}
			move -stop right
			
		if !${Movement.Speed} || !${Movement.Forward}
			move forward CM_TIME
	}
	
	; ---------------------------------------------------------------------
	; move backwards
	method MoveBackward()
	{
		if ${Movement.Forward}
			move -stop forward
		if ${Movement.Left}
			move -stop left
		if ${Movement.Right}
			move -stop right
			
		if !${Movement.Speed} || !${Movement.Backward}
			move backward CM_TIME
	}
	
	; ---------------------------------------------------------------------
	; move left
	method MoveLeft()
	{
		if ${Movement.Forward}
			move -stop forward
		if ${Movement.Backward}
			move -stop backward
		if ${Movement.Right}
			move -stop right
			
		if !${Movement.Speed} || !${Movement.Left}
			move left CM_TIME
	}
	
	; ---------------------------------------------------------------------
	; move forward and left
	method MoveForwardLeft()
	{
		if ${Movement.Backward}
			move -stop backward
		if ${Movement.Right}
			move -stop right
			
		if !${Movement.Speed} || !${Movement.Forward}
			move forward CM_TIME
		if !${Movement.Speed} || !${Movement.Left}
			move left CM_TIME
	}
	
	; ---------------------------------------------------------------------
	; move right
	method MoveRight()
	{
		if ${Movement.Forward}
			move -stop forward
		if ${Movement.Backward}
			move -stop backward
		if ${Movement.Left}
			move -stop left
			
		if !${Movement.Speed} || !${Movement.Right}
			move right CM_TIME
	}
	
	; ---------------------------------------------------------------------
	; move forward and right
	method MoveForwardRight()
	{
		if ${Movement.Backward}
			move -stop backward
		if ${Movement.Left}
			move -stop left
			
		if !${Movement.Speed} || !${Movement.Forward}
			move forward CM_TIME
		if !${Movement.Speed} || !${Movement.Right}
			move right CM_TIME
	}
	
	; ---------------------------------------------------------------------
	; stop movement
	method StopMovement()
	{
		if ${Movement.Forward}
			move -stop Forward
		if ${Movement.Backward}
			move -stop backward
		if ${Movement.Left}
			move -stop left
		if ${Movement.Right}
			move -stop right
	}
	
	; ---------------------------------------------------------------------
	; Display the message if level is low enough
	method KZDebug(int Lvl, string Msg)
	{
		if ${Lvl} <= KZ_MSGLVL
			This:Output[${Msg}]											/* show the enabled message									*/
	}
}

variable oCMovement CMovement
				  
/* >>>>>>>>>>>>>>>>>>>>>>>> End of oCMovement <<<<<<<<<<<<<<<<<<<<<<<<<< */
				  
				  
; -------------------------------------------------------------------------
; -------------------------------------------------------------------------
