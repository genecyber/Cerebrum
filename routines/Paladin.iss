;*************************************************************
; BOt.Adin Paladin Routine v1.2.2      											 *		
; Version edited by spideronz			                			 		 *
; Date: 26/09/2007 Release: 1.2.2	                 	 				 *
;*************************************************************


objectdef cClass inherits cBase
{

/*********************************************************/
/* _START_ :General Settings                             */
/* Do not edit routine here. Use GUI to modify variablces */
/*********************************************************/

  variable string bOtAdinV = "1.2.2"
  variable string bOtAdinN = "bOt.Adin Routine"


/* _START_ General UI settings */   
	variable bool activeRoutine = TRUE	
	variable bool needUIHook = TRUE
	variable collection:string UIErrorMsgStrings
/* _END_ General UI settings */   

/* _START_ General Hp/Mana settings */   
	variable int PullRange = 10
	variable int RestMana = 50             
	variable int RestHP = 50               
	variable int MinMana = 80              
	variable int MinHP = 80                 
/* _END_ General Hp/Mana settings */  

/* _START_ Resting settings */   
	variable int PoisonCounter = 0
	variable bool useBandage = FALSE	
	variable bool scrollSpam = TRUE	
	variable int BuffNum = 0
	variable bool combatDebuff = TRUE	
	variable bool castHeal = FALSE
	variable bool debuffStatus = FALSE	
/* _END_ Resting settings */  
 
/* _START_ Cast interruption settings */   	
	variable bool castInterruption = TRUE
	variable bool torrentSpam = TRUE	
	variable bool hammerSpam = TRUE		
/* _END_ Cast interruption settings */  
 	
/* _START_ Emergency System settings */   
	variable int flashMult = 2
	variable int holyMult = 1
	variable bool divineShield = TRUE
	variable bool emergBless = TRUE
	variable int HpHammer = 40
	variable int HpEmerg = 25
	variable int HpPotion = 20
/* _END_ Emergency System settings */  

/* _START_ Misc settings */   
  variable int MaxRanged = 25
  variable int MinRanged = 15
  variable int MaxMelee = 5
  variable int MinMelee = 1
  variable string LastSpell = "nothing yet"
  variable int LagTime = 400 
  variable string LastSeal = "nothing yet"  
  variable int LastSealTime = 0  
	variable int LastCastedAt = 0
	variable int CastingTime = 0  
/* _END_ Misc settings */   

/* _START_ Combat spells settings */ 
  variable string JudgePull = "Judgement of Light"    
  variable string SealPull = "Seal of Light"
  variable string Blessing = "Blessing of Might"
  variable string Aura = "Retribution Aura"
  variable string DmgSeal = "Seal of Wisdom"
  variable string EmBless = "Blessing of Light"
	variable bool useExorcism = FALSE
	variable int ExorcismHP = 100
	variable bool useWrath = FALSE
	variable bool JudgeSpam = FALSE	
/* _END_ Combat spells settings */ 
	  
/* _START_ Flee block settings */   
  variable string FleeJudge = "Judgement of Justice"    
  variable string FleeSeal = "Seal of Justice"
/* _END_ Flee block settings */  

/* _START_ Multi aggro settings */   
  variable bool multiChange = TRUE                        ; Permit Aura changing when multiAggro system is activate
  variable int multiCons = 3                              ; # of mob to activate multiAggro system
  variable string multiAura = "Retribution Aura"          ; Aura used in multiAggro system
/* _END_ Multi aggro settings */  

/*********************************************************/
/* _END_ :General Settings                               */
/*********************************************************/


/*********************************************************/
/* _START_ : UI Message Hooking                          */
/*********************************************************/
  method CreateUIErrorStrings()
	{
    This.UIErrorMsgStrings:Set["You are facing the wrong way!","backward"]
		This.UIErrorMsgStrings:Set["Target needs to be in front of you","backward"]
		This.UIErrorMsgStrings:Set["Target too close","backward"]
		This.UIErrorMsgStrings:Set["You are too far away!","forward"]
	}

	method UIErrorMessage(string Id, string Msg)
	{
		if ${This.UIErrorMsgStrings.Element[${Msg}](exists)} && !${Bot.PauseFlag} 
		{
			if ${Msg.Equal["You are facing the wrong way!"]} || (${Target.Distance} < 5 && ${Me.InCombat}) || ${This.UIErrorMsgStrings.Element[${Msg}].Equal["backward"]}
			{

				This:Output["Moving ${This.UIErrorMsgStrings.Element[${Msg}]} - UI Error: ${Msg}"]
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]

				move ${This.UIErrorMsgStrings.Element[${Msg}]} 3000
				return				
			}
		}
	}
/*********************************************************/
/* _END_ : UI Message Hooking                            */
/*********************************************************/
      
	method Initialize()
	{
    if !${Config.GetSetting["${Me.Name}","activeRoutine"](exists)} || ${Config.GetSetting["${Me.Name}","activeRoutine"]}  == FALSE
    {
      This:genJudgePull
      This:SaveConfig
			This:LoadConfig
			This:paladinGUI
			return
		}
		This:LoadConfig
		This:genJudgePull
		This:paladinGUI
		This:CreateUIErrorStrings		
	}

	method Wait(string myspell, int rank)
	{
    if ${Spell[${myspell}].CastTime} == 0
		{
      This.CastingTime:Set[1500]
		}
		else
		{ 
			This.CastingTime:Set[${Spell[${myspell}].CastTime}]
    }
    if (${Math.Calc[${LavishScript.RunningTime}-${This.LastCastedAt}]}>(${This.CastingTime}+${LagTime}) && ${This.LastSpell.Equal[${myspell}]}) || !${This.LastSpell.Equal[${myspell}]}	
		{
      Cast "${myspell}" ${rank}
      This.LastCastedAt:Set[${LavishScript.RunningTime}]
      This.LastSpell:Set[${myspell}]
		}
	}

	method TakePot(string mypot,int mysecond)
	{
		if ${Math.Calc[${LavishScript.RunningTime}-${This.LastCastedAt}]}>${mysecond}
		{
      Consumable:use${mypot}()
      This.LastCastedAt:Set[${LavishScript.RunningTime}]
		}
	}

/*********************************************************/
/* _START_ : Debuff Routine                              */
/*********************************************************/	
method debuffAll()
	{
		BuffNum:Inc
		if ${BuffNum} > 15
		{
			BuffNum:Set[1]
		}
		if !${Me.Buff[${BuffNum}](exists)} || ${Me.CurrentMana}<${Spell[Cleanse].Mana} || ${Me.Sitting} || ${Me.Casting}
		{
			return
		}
		if ${Me.Buff[${BuffNum}].Harmful} 
		{
      debuffStatus:Set[TRUE]
			if ${Me.Buff[${BuffNum}].DispelType.Equal[Poison]} || ${Me.Buff[${BuffNum}].DispelType.Equal[Disease]}
			{
        if  ${Spell[Cleanse](exists)}
				{
          This:Output[Cleanse]
          Toon:CastSpell[Cleanse]
          debuffStatus:Set[FALSE]
				}
				elseif  ${Spell[Purify](exists)}
				{
          This:Output[Purify]
          Toon:CastSpell[Purify]
          debuffStatus:Set[FALSE]
				}
				return
			}
			elseif ${Me.Buff[${BuffNum}].DispelType.Equal[Magic]} && ${Spell[Cleanse](exists)}
			{
        This:Output["Casting Cleanse"]
				Toon:CastSpell[Cleanse]
				debuffStatus:Set[FALSE]
				return
			}
			elseif ${Me.Buff[${BuffNum}].DispelType.Equal[Root]} && ${Spell[Blessing of Freedom](exists)} && !${Spell[Blessing of Freedom].Cooldown}
			{
				This:Output["Blessing of Freedom"]
        Toon:CastSpell[Blessing of Freedom]
				debuffStatus:Set[FALSE]
				return
			}
			elseif ${Me.Buff[${BuffNum}].DispelType.Equal[Snare]} && ${Spell[Blessing of Freedom](exists)} && !${Spell[Blessing of Freedom].Cooldown}
			{
				This:Output["Blessing of Freedom"]
        Toon:CastSpell[Blessing of Freedom]
				debuffStatus:Set[FALSE]
				return
			}
			debuffStatus:Set[FALSE]
		}
	}
/*********************************************************/
/* _END_ : Debuff Routine                                */
/*********************************************************/	

/*********************************************************/
/* _START_ :  Resting Routine                            */
/*********************************************************/	
	member NeedRest()
  {
		if ${Me.InCombat}
    {
			return FALSE
    }
		if ${Me.Buff[Resurrection Sickness](exists)}
		{
			return TRUE	
		}
		if (${Me.PctMana} < ${This.RestMana}) && !${Me.Casting} && !${Me.Buff[Drink](exists)}
		{
			This:Output["Resting for Mana!!"]
			return TRUE
		}
		if (${Me.PctMana} < ${This.MinMana}) && ${Me.Buff[Drink](exists)}
		{
			This:Output["Resting for continure drinking!!"]
			return TRUE
		}
		if (${Me.PctHPs} < ${This.RestHP}) && !${Me.Casting} && !${Me.Buff[Drink](exists)}
		{
      This:Output["Resting for HP!!"]
			return TRUE
		}
		return FALSE
	}
	
	method RestPulse()
	{
    if ${Me.Casting[${This.LastSpell}]} && ${Me.PctHPs} > 90
    {
      WowScript SpellStopCasting()
    }	
		if ${Movement.Speed}
		{
			Move -stop
		}
		if ${Me.Buff["Resurrection Sickness"](exists)} && !${Me.Sitting}
		{
			Toon:Sitdown
			This:Output["I've got Resurrection Sickness,  I'm staying put!!"]
			return
		}
		This:debuffAll()
		if ${scrollSpam} && ${canUseScroll}
    {
      Toon:UseScroll
    }
		if !${debuffStatus}
		{
  		if ${Me.PctMana} >= ${This.RestMana} && ${Me.PctHPs} <= ${This.MinHP} && ${Consumable.HasBandage} && ${useBandage}
      {
        Consumable:useBandage()
        This.LastCastedAt:Set[${LavishScript.RunningTime}]
      }
			if ${Me.PctHPs} >= ${This.MinHP} && ${Me.PctMana} >= ${This.MinMana} 
      {
        Toon:Standup
        return
      }
      if ${Me.PctHPs} < ${This.RestHP} && ${Me.PctMana} > 10 && !${Me.Buff[Drink](exists)} && !${Me.Casting}
      {
        if ${Me.Sitting}
        {
          Toon:Standup
        }
        if ${Math.Calc[${LavishScript.RunningTime}-${This.LastCastedAt}]}>(${Spell[${This.LastSpell}].CastTime}+500) && !${Me.Casting}
        {
          This:healSystem()
          return
        }		
			}
      if !${Me.Buff[Drink](exists)} && ${Me.PctMana} <= ${This.RestMana} && !${Me.Casting}
      {
        if ${Consumable.HasDrink}
        {
          Consumable:useDrink
        }
        else
        {
          Toon:CastSpell[Blessing of Wisdmon]
        }
      }
    }
  }
/*********************************************************/
/* _END_ : Resting Routine                               */
/*********************************************************/

/*********************************************************/
/* _START_ : Cast Interruption                           */
/*********************************************************/
  method castInterruption() 
  {
    if ${This.torrentSpam} && ${Toon.canCast[Arcane Torrent]}
    {
    	Toon:CastSpell[Arcane Torrent]
    }
    elseif !${This.torrentSpam} && ${Me.Buff[Mana Tap](exists)} && ${Toon.canCast[Arcane Torrent]}
    {
			Toon:CastSpell[Arcane Torrent]     
    }
    if ${Target.Casting.ID(exists)} && ${This.hammerSpam} && ${Toon.canCast[Hammer of Justice]}
    {
      This:Wait[Hammer of Justice]
    }
    if ${Target.Casting.ID(exists)} && ${Target.CreatureType.Equal[Humanoid]} && ${Toon.canCast[Repentance]}
		{
      This:Wait[Repentance]
		}	
  } 
/*********************************************************/
/* _END_ : Cast Interruption                           */
/*********************************************************/

/*********************************************************/
/* _START_ : Buff Routine                                */
/*********************************************************/
  member NeedBuff()
	{
    if !${Me.Buff[Drink](exists)} || !${Me.Casting} 
    {
      if !${Me.Buff[${This.Blessing}](exists)} && ${Toon.canCast[${This.Blessing}]}
      {
        return TRUE
      }
	 	  if !${Me.Buff[${This.Aura}](exists)} && ${Toon.canCast[${This.Aura}]}
      {
        return TRUE
      }
    }
		return FALSE
	}
	
	method BuffPulse()
	{
    Toon:Standup
		This:Output[Buff]	
		if !${Me.Buff[${This.Blessing}](exists)} && ${Toon.canCast[${This.Blessing}]}
		{
      This:Output[Blessing]	
			This:Wait[${This.Blessing}]	
		}
		if !${Me.Buff[${This.Aura}](exists)} && ${Toon.canCast[${This.Aura}]}
		{
			This:Wait[${This.Aura}]
			This:Output[Aura]
		}
	}
	
	member NeedPullBuff()
	{
    if !${Me.Buff[${This.SealPull}](exists)} && ${Toon.canCast[${This.SealPull}]}
		{
      return TRUE
		}
    return FALSE
	}
	
	method PullBuffPulse()
	{
    Toon:Standup
		if !${Me.Buff[${This.SealPull}](exists)}
		{
      This.LastSeal:Set[${This.SealPull}]
      This:Wait[${This.SealPull}]
      This.LastSealTime:Set[${LavishScript.RunningTime}]		
			This:Output["${This.SealPull} a: ${This.LastSealTime}"]
		}
	}
	
  member NeedCombatBuff()
	{
    if !${Me.Buff[${This.Blessing}](exists)} && ${Toon.canCast[${This.Blessing}]}
    {
      return TRUE
    }
	  if !${Me.Buff[${This.Aura}](exists)} && ${Toon.canCast[${This.Aura}]}
    {
      return TRUE
    }
		return FALSE
	}
	
	method CombatBuffPulse()
	{
    if !${Me.Buff[${This.Blessing}](exists)} && ${Me.PctMana} > ${This.RestMana} && ${Toon.canCast[${This.Blessing}]}
		{
			if ${Me.Buff[${This.EmBless}](exists)} && ${Me.InCombat} 
			{
        /* Do nothing */
			} 
			else
			{
				This:Wait[${This.Blessing}]	
			}	
		}
		if !${Me.Buff[${This.Aura}](exists)} && ${Me.PctMana} > ${This.RestMana} && ${Toon.canCast[${This.Aura}]}
		{
			if ${Me.Buff[${This.multiAura}](exists)} && ${Me.InCombat}
			{
        /* Do nothing */
			}
			else
			{
        This:Wait[${This.Aura}]	
			}
		}
  }
/*********************************************************/
/* _END_ : Buff Routine                                  */
/*********************************************************/	
	
/*********************************************************/
/* _START_ : Emergency Routine                           */
/*********************************************************/		
  method Emergency()
  {
    if !${Me.Casting[Holy Light]} && !${Me.Casting[Flash of Light]}
    {
      if !${Me.Buff[Forbearance](exists)}
      {
        if ${Toon.canCast[Divine Protection]}
        {
          if ${Toon.canCast[Divine Shield]} && ${This.divineShield}
     		{
            	WowScript SpellStopCasting()
            	Toon:CastSpell[Divine Shield]
     		}
     		    else 
      	{
		     	WowScript SpellStopCasting()
		      Toon:CastSpell[Divine Protection]
            }
          This:Output[Divine Shield Healing]	
          This:healSystem()
        }
      elseif ${Toon.canCast[Blessing of Protection]}
      	{
          WowScript SpellStopCasting()
          Toon:CastSpell[Blessing of Protection]
          This:Output[Blessing of Protection Healing]
       		This:healSystem()
      	} 
      }    
      if !${Me.Buff[${EmBless}](exists)} && ${Toon.canCast[${EmBless}]} && ${emergBless}
      {
        Toon:CastSpell[${EmBless}]
			}	 
      if ${Toon.canCast[Lay on Hands]} && !${Me.Buff[Forbearance](exists)}
      { 
        WowScript SpellStopCasting()
				Toon:CastSpell[Lay on Hands]
      }   
      if ${Me.Buff[Forbearance](exists)}
      {
        if ${Toon.canCast[Lay on Hands]} && ${Me.PctHPs}<24
        {
          WowScript SpellStopCasting()
	    Toon:CastSpell[Lay on Hands]
        }
      }
      if ${Me.PctHPs}<${This.MinHP}
      {
        This:Output[Emergency Healing]
        This:healSystem()
      }
    }
  }	
/*********************************************************/
/* _END_ : Emergency Routine                             */
/*********************************************************/		

/*********************************************************/
/* _START_ : Healing Routine                             */
/*********************************************************/	
  method healSystem()
  {
    declare flashHealing[7] int
    declare flashRank int 1
    declare activeFlash bool FALSE
    
    flashHealing[1]:Set[67]
    flashHealing[2]:Set[110]
    flashHealing[3]:Set[163]
    flashHealing[4]:Set[221]
    flashHealing[5]:Set[299]
    flashHealing[6]:Set[383]
    flashHealing[7]:Set[502]
    
    while !${activeFlash}&&${flashRank}<8
    {
      if ${Spell[Flash of Light,${flashRank}](exists)} && ${Me.CurrentMana}>=${Spell[Flash of Light,${flashRank}].Mana} && (${Me.MaxHPs}-${Me.CurrentHPs}) < (${flashHealing[${flashRank}]}*${This.flashMult}) && (${Me.MaxHPs}-${Me.CurrentHPs}) > ${flashHealing[${flashRank}]} && !${Me.Casting}
      {
        This:Wait[Flash of Light,${flashRank}]	
        This:Output[Flash of Light Rank: ${flashRank}]
        activeFlash:Set[1]
        return 
      }
      flashRank:Inc
    }
    if !${activeFlash}&&${Me.PctHPs}<${This.MinHP} && !${Me.Casting}
    {
    This:healLight()
    }
  }
	
  method healLight()
  {
    if ${Me.PctHPs} > ${This.MinHP}
    {
      return
    }	
    declare holyHealing[11] int
    declare holyRank int 11
    declare activeHoly bool FALSE
	
    holyHealing[1]:Set[51]
    holyHealing[2]:Set[96]
    holyHealing[3]:Set[196]
    holyHealing[4]:Set[384]
    holyHealing[5]:Set[569]
    holyHealing[6]:Set[780]
    holyHealing[7]:Set[1053]
    holyHealing[8]:Set[1388]
    holyHealing[9]:Set[1770]
    holyHealing[10]:Set[1939]
    holyHealing[11]:Set[2446]

    while !${activeHoly}&&${holyRank}>0
    {
      if ${Spell[Holy Light,${holyRank}](exists)} && ${Me.CurrentMana}>=${Spell[Holy Light,${holyRank}].Mana} && (${Me.MaxHPs}-${Me.CurrentHPs}) > (${holyHealing[${holyRank}]}*${This.holyMult}) && !${Me.Casting}
      {			
        This:Wait[Holy Light,${holyRank}]
        This:Output[Holy Light Rank: ${holyRank}]
        activeHoly:Set[1]
      }
      holyRank:Dec
    }
    return
  }	
/*********************************************************/
/* _END_ : Healing Routine                               */
/*********************************************************/	
	
/*********************************************************/
/* _START_ : Pull Routine                                */
/*********************************************************/
	method PullPulse()
	{
		if ${Target.Distance} < 10 && ${Toon.canCast[Judgement]}
		{
      		Toon:CastSpell[Judgement]
		}
		
			if !${Toon.ValidTarget[${Target.GUID}]}
		{
			move -stop
			This:Output["I need a target"]
			Toon:NeedTarget[1]					
			return
		}	

		if !${Toon.TargetIsBestTarget}
		{
			move -stop
			Toon:BestTarget
			return
		}		

		/* target is elite, fuck that */
		if ${Target.Classification.Equal[Elite]}
		{ 
			move -stop
			This:Output["Target is elite. Blacklisting."]
			GlobalBlacklist:Insert[${Target.GUID},3600000]
			WoWScript ClearTarget()
			return 
		} 
		if !${Me.Attacking}
		{
			WoWScript AttackTarget()
			return
		}
    		if ${Target.Distance} > ${This.MaxMelee}
		{
			This:Output["Pull Moving twords ${Target.Name}"]
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
			wowpress -hold moveforward 
			return
		}
	}
	
	method genJudgePull()
	{
		if ${This.SealPull.Equal[Seal of Light]}
		{
		This.JudgePull:Set[Judgement of Light]
		}
		if ${This.SealPull.Equal[Seal of the Crusader]}
		{
		This.JudgePull:Set[Judgement of the Crusader]
		}
		if ${This.SealPull.Equal[Seal of Wisdom]}
		{
		This.JudgePull:Set[Judgement of Wisdom]
		}
		if ${This.SealPull.Equal[Seal of Righteousness]}
		{
		This.JudgePull:Set[Judgement of Righteousness]
		}
		if ${This.SealPull.Equal[Seal of Command]}
		{
		This.JudgePull:Set[Judgement of Command]
		}
		if ${This.SealPull.Equal[Seal of Justice]}
		{
		This.JudgePull:Set[Judgement of Justice]
		}
	}		
/*********************************************************/
/* _END_ : Pull Routine                                  */
/*********************************************************/

	method AttackPulse()
	{
    variable guidlist Aggros
    variable guidlist Ally
    
	if !${Target(exists)} || ${Target.Dead} 
	{
		return
	}
    
    if (${Target.Tapped} && !${Target.TappedByMe})
    {
        WowScript SpellStopCasting()
        WoWScript ClearTarget()
        Toon:BestTarget
        WoWScript AttackTarget()
     }
    Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}] 
    if ${Target.Distance}> ${This.MaxMelee}
    {
      This:Output["Pull Moving twords ${Target.Name}"]
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
			wowpress -hold moveforward 
			return
    }
    if ${Movement.Speed} && ${Target.Distance}<${This.MaxMelee} && ${Target.Distance}>${This.MinMelee}
    {
      move -stop
    }
    if ${Target.Distance}<${This.MinMelee}
    {
      move backward 300
    }
    if !${Me.Attacking}
    {
      WoWScript AttackTarget()
    }
		if ${Me.PctHPs} <= ${HpEmerg}
		{
			This:Emergency()
		}
		if ${Me.PctHPs} <= ${HpPotion} && ${Consumable.HasHPot}
		{
		 WowScript SpellStopCasting()
		 This:TakePot[HPot,${Me.GlobalCooldown}]
		}
		if ${Me.PctMana} <= 15 && ${Consumable.HasMPot}
		{
		 WowScript SpellStopCasting()
		 This:TakePot[MPot,${Me.GlobalCooldown}]
		}
		if ${Me.PctHPs}<=${HpHammer} && ${Me.PctMana}>5 && ${Me.PctHPs} >= ${HpEmerg} && ${Toon.canCast[Hammer of Justice]}
		{
        This:Wait[Hammer of Justice]

			if ${Target.PctHPs}>10
			{
				This:healSystem()
				This:Output[Hammer of Justice Healing]
				return
			}
			return
		}
		Ally:Search[-players, -pvp, -hostile, -aggro, -targetingme, -alive, -nearest, -nopets, -range 0-30]
		if ${Ally.Count}>0
		{

      Target ${Ally[1].GUID}
              WoWScript AttackTarget()
			Ally:Clear
			return
		}
		Aggros:Search[-units, -nearest, -aggro, -targetingme, -alive, -range 0-10]		
		if ${Aggros.Count} >= ${multiCons}
			{
			if ${multiChange} && !${Me.Buff[${This.multiAura}](exists)} && ${Toon.canCast[${This.multiAura}]}
			{
        This:Wait[${This.multiAura}]
			}
			if ${Toon.canCast[Consecration]}
			{
        Toon:CastSpell[Consecration]
			}
		}
		if ${Target.Casting.ID(exists)}&&${This.castInterruption}
  	{
      This:castInterruption()
  	}
  	if ${Target.PctHPs}<=20
		{
      This:finalFight()
    }
    else
    {
      This:normalFight()
    }
    if ${useExorcism}
    {	
      if ${Me.PctMana} > 30 && ${Target.PctHPs} > ${ExorcismHP} && ${Toon.canCast[Exorcism]} && (${Target.CreatureType.Equal[Undead]} || ${Target.CreatureType.Equal[Demon]})
      {
        This:Wait[Exorcism]
      }
    }
		if ${combatDebuff}
      This:debuffAll()		
  	if ${Me.Race.Equal[Blood Elf]}
		{
			if ${Me.Buff[Mana Tap].Application} > 0 && ${Me.PctMana} <= 20
			{
        WoWScript SpellStopCasting()
				Toon:CastSpell[Arcane Torrent]
			}
			if ${Me.Target.PctMana} > 0 && ${Me.Action[Mana Tap].Usable} && ${Me.Buff[Mana Tap].Application} < 3
			{
        cast "Mana Tap"
			}
		}
	}
	
/*********************************************************/
/* _START_ : Fight Routine under 20%                     */
/*********************************************************/
	method finalFight()
	{
	  if ${useWrath}
    {
      This:Wait[Hammer of Wrath]
    }
    if ${Target.Distance}>${Math.Calc[${This.MaxMelee}-${Target.BoundingRadius}]} && ${Toon.canCast[Judgement]}
    {
      This:Output[Checking Flee]
      if ${Toon.canCast[${This.FleeSeal}]} && ${Me.PctMana} > 30
      {
        This:Wait[${This.FleeSeal}]
      }
      if ${Me.Buff[${This.FleeSeal}](exists)} && ${Me.PctMana} > 30 && !${Target.Buff[${This.FleeJudge}](exists)}
      {
        This:Wait[Judgement]
      }
    }
    else
    {
      if !${Me.Buff[${This.DmgSeal}](exists)} && ${Me.PctMana} > 30 && ${Target.Buff[${This.JudgePull}](exists)}
      {
        This:Wait[${This.SealPull}]
      }
      if ${Me.Buff[${This.DmgSeal}](exists)} && ${Toon.canCast[Judgement]}
      {
        if !${JudgeSpam} && !${Target.Buff[${This.JudgePull}](exists)} 
        {
          This:Wait[Judgement]
        }
        elseif ${JudgeSpam} && ${Toon.canCast[Judgement]}
        {
          This:Wait[Judgement]
        }
      } 
    }
	}	
/*********************************************************/
/* _END_ : Fight Routine under 20%                       */
/*********************************************************/

/*********************************************************/
/* _START_ : Standard Fight Routine                      */
/*********************************************************/	
	method normalFight()
	{
    if !${Target.Buff[${This.JudgePull}](exists)} && !${Me.Buff[${This.SealPull}](exists)} && !${Target.Buff[${This.FleeJudge}](exists)}
		{
      if ${Target.PctHPs}<=90 && ${Math.Calc[${LavishScript.RunningTime}-${This.LastSealTime}]}>${LagTime}
      {
        This:Wait[${This.SealPull}]
        This.LastSeal:Set[${This.SealPull}]
        This.LastSealTime:Set[${LavishScript.RunningTime}]		
        This:Output["${This.LastSeal} in combat a: ${This.LastSealTime}"]
      }
		}
		if !${Target.Buff[${This.JudgePull}](exists)} && ${Me.Buff[${This.SealPull}](exists)} && ${Target.Distance}<=${This.PullRange} && !${Target.Buff[${This.FleeJudge}](exists)} && ${Toon.canCast[Judgement]}
		{
      This:Wait[Judgement]
		}
		if !${Me.Buff[${This.DmgSeal}](exists)} && ${Target.Buff[${This.JudgePull}](exists)}
		{
      This:Wait[${This.DmgSeal}]
      This.LastSeal:Set[${This.DmgSeal}]
      This.LastSealTime:Set[${LavishScript.RunningTime}]		
      This:Output["${This.LastSeal} in combat a: ${This.LastSealTime}"]		
		}
		
		if ${Me.Buff[${This.DmgSeal}](exists)} && ${Toon.canCast[Judgement]}
		{
      if !${JudgeSpam} && !${Target.Buff[${This.JudgePull}](exists)}
      {
        This:Wait[Judgement]
      }
      elseif ${JudgeSpam} && ${Toon.canCast[Judgement]}
      {
        This:Wait[Judgement]
      }
		}
	
	}
/*********************************************************/
/* _END_ : Standard Fight Routine                        */
/*********************************************************/		
	
/*********************************************************/
/* _START_ : GUI INTERFACE                               */
/*********************************************************/	
	method LoadConfig()
	{
		This.activeRoutine:Set[${Config.GetSetting["${Me.Name}","activeRoutine"]}]
			

		This.RestHP:Set[${Config.GetSetting["${Me.Name}","RestHP"]}]
		This.MinHP:Set[${Config.GetSetting["${Me.Name}","MinHP"]}]
		This.RestMana:Set[${Config.GetSetting["${Me.Name}","RestMana"]}]
		This.MinMana:Set[${Config.GetSetting["${Me.Name}","MinMana"]}]
		This.scrollSpam:Set[${Config.GetSetting["${Me.Name}","scrollSpam"]}]
		This.flashMult:Set[${Config.GetSetting["${Me.Name}","flashMult"]}]
		This.holyMult:Set[${Config.GetSetting["${Me.Name}","holyMult"]}]
		This.emergBless:Set[${Config.GetSetting["${Me.Name}","emergBless"]}]
		This.EmBless:Set[${Config.GetSetting["${Me.Name}","EmBless"]}]
		This.useBandage:Set[${Config.GetSetting["${Me.Name}","useBandage"]}]
		This.HpHammer:Set[${Config.GetSetting["${Me.Name}","HpHammer"]}]
		This.HpEmerg:Set[${Config.GetSetting["${Me.Name}","HpEmerg"]}]
		This.HpPotion:Set[${Config.GetSetting["${Me.Name}","HpPotion"]}]
		This.castInterruption:Set[${Config.GetSetting["${Me.Name}","castInterruption"]}]			
		This.torrentSpam:Set[${Config.GetSetting["${Me.Name}","torrentSpam"]}]			
		This.hammerSpam:Set[${Config.GetSetting["${Me.Name}","hammerSpam"]}]
		This.multiChange:Set[${Config.GetSetting["${Me.Name}","multiChange"]}]			
		This.multiCons:Set[${Config.GetSetting["${Me.Name}","multiCons"]}]			
		This.multiAura:Set[${Config.GetSetting["${Me.Name}","multiAura"]}]	
		This.PullRange:Set[${Config.GetSetting["${Me.Name}","PullRange"]}]			
		This.useWrath:Set[${Config.GetSetting["${Me.Name}","useWrath"]}]			
		This.combatDebuff:Set[${Config.GetSetting["${Me.Name}","combatDebuff"]}]
		This.SealPull:Set[${Config.GetSetting["${Me.Name}","SealPull"]}]					
		This.Blessing:Set[${Config.GetSetting["${Me.Name}","Blessing"]}]			
		This.Aura:Set[${Config.GetSetting["${Me.Name}","Aura"]}]			
		This.DmgSeal:Set[${Config.GetSetting["${Me.Name}","DmgSeal"]}]			
		This.JudgePull:Set[${Config.GetSetting["${Me.Name}","JudgePull"]}]
		This.useExorcism:Set[${Config.GetSetting["${Me.Name}","useExorcism"]}]			
		This.ExorcismHP:Set[${Config.GetSetting["${Me.Name}","ExorcismHP"]}]		
	}

	method SaveConfig()
	{
		Config:SetSetting[${Me.Name},"activeRoutine",${This.activeRoutine}]
		Config:SetSetting[${Me.Name},"RestHP",${This.RestHP}]
		Config:SetSetting[${Me.Name},"MinHP",${This.MinHP}]
		Config:SetSetting[${Me.Name},"RestMana",${This.RestMana}]
		Config:SetSetting[${Me.Name},"MinMana",${This.MinMana}]
		Config:SetSetting[${Me.Name},"scrollSpam",${This.scrollSpam}]	
		Config:SetSetting[${Me.Name},"flashMult",${This.flashMult}]
		Config:SetSetting[${Me.Name},"holyMult",${This.holyMult}]		
		Config:SetSetting[${Me.Name},"emergBless",${This.emergBless}]			
		Config:SetSetting[${Me.Name},"EmBless",${This.EmBless}]		
		Config:SetSetting[${Me.Name},"useBandage",${This.useBandage}]
		Config:SetSetting[${Me.Name},"HpHammer",${This.HpHammer}]			
		Config:SetSetting[${Me.Name},"HpEmerg",${This.HpEmerg}]		
		Config:SetSetting[${Me.Name},"HpPotion",${This.HpPotion}]					
		Config:SetSetting[${Me.Name},"castInterruption",${This.castInterruption}]			
		Config:SetSetting[${Me.Name},"torrentSpam",${This.torrentSpam}]		
		Config:SetSetting[${Me.Name},"hammerSpam",${This.hammerSpam}]	
		Config:SetSetting[${Me.Name},"multiChange",${This.multiChange}]			
		Config:SetSetting[${Me.Name},"multiCons",${This.multiCons}]		
		Config:SetSetting[${Me.Name},"multiAura",${This.multiAura}]
		Config:SetSetting[${Me.Name},"PullRange",${This.PullRange}]
		Config:SetSetting[${Me.Name},"useWrath",${This.useWrath}]
		Config:SetSetting[${Me.Name},"combatDebuff",${This.combatDebuff}]	
		Config:SetSetting[${Me.Name},"JudgePull",${This.JudgePull}]		
		Config:SetSetting[${Me.Name},"SealPull",${This.SealPull}]
		Config:SetSetting[${Me.Name},"Blessing",${This.Blessing}]
		Config:SetSetting[${Me.Name},"Aura",${This.Aura}]
		Config:SetSetting[${Me.Name},"DmgSeal",${This.DmgSeal}]
		Config:SetSetting[${Me.Name},"useExorcism",${This.useExorcism}]
		Config:SetSetting[${Me.Name},"ExorcismHP",${This.ExorcismHP}]			
	}	
	
	method paladinGUI()
	{
		variable int i = 1
		variable string comboItem

		for (i:Set[1] ; ${i} <=${UIElement[multiAura@Miscellaneous@Settings@ClassGUI].Items} ; i:Inc)     
		{         
			comboItem:Set["${UIElement[multiAura@Miscellaneous@Settings@ClassGUI].Item[${i}]}"]
			if ${This.multiAura.Equal[${comboItem}]}     
			{      
				UIElement[multiAura@Miscellaneous@Settings@ClassGUI]:SelectItem[${i}]       
			}
		}		
		
				for (i:Set[1] ; ${i} <=${UIElement[Blessing@Combat@Settings@ClassGUI].Items} ; i:Inc)     
		{         
			comboItem:Set["${UIElement[Blessing@Combat@Settings@ClassGUI].Item[${i}]}"]
			if ${This.Blessing.Equal[${comboItem}]}     
			{      
				UIElement[Blessing@Combat@Settings@ClassGUI]:SelectItem[${i}]       
			}
		}

				for (i:Set[1] ; ${i} <=${UIElement[Aura@Combat@Settings@ClassGUI].Items} ; i:Inc)     
		{         
			comboItem:Set["${UIElement[Aura@Combat@Settings@ClassGUI].Item[${i}]}"]
			if ${This.Aura.Equal[${comboItem}]}     
			{      
				UIElement[Aura@Combat@Settings@ClassGUI]:SelectItem[${i}]       
			}
		}
		
				for (i:Set[1] ; ${i} <=${UIElement[DmgSeal@Combat@Settings@ClassGUI].Items} ; i:Inc)     
		{         
			comboItem:Set["${UIElement[DmgSeal@Combat@Settings@ClassGUI].Item[${i}]}"]
			if ${This.DmgSeal.Equal[${comboItem}]}     
			{      
				UIElement[DmgSeal@Combat@Settings@ClassGUI]:SelectItem[${i}]       
			}
		}				

				for (i:Set[1] ; ${i} <=${UIElement[SealPull@Combat@Settings@ClassGUI].Items} ; i:Inc)     
		{         
			comboItem:Set["${UIElement[SealPull@Combat@Settings@ClassGUI].Item[${i}]}"]
			if ${This.SealPull.Equal[${comboItem}]}     
			{      
				UIElement[SealPull@Combat@Settings@ClassGUI]:SelectItem[${i}]       
			}
		}		
		
		/* set sliders */
		if ${This.RestHP} != ${UIElement[RestHP_slider@Resting@Settings@ClassGUI].Value}     
		{       
			UIElement[RestHP_slider@Resting@Settings@ClassGUI]:SetValue[${This.RestHP}]     
		}
				if ${This.MinHP} != ${UIElement[MinHP_slider@Resting@Settings@ClassGUI].Value}     
		{       
			UIElement[minHP_slider@Resting@Settings@ClassGUI]:SetValue[${This.MinHP}]     
		}
				if ${This.RestMana} != ${UIElement[RestMana_slider@Resting@Settings@ClassGUI].Value}     
		{       
			UIElement[RestMana_slider@Resting@Settings@ClassGUI]:SetValue[${This.RestMana}]     
		}
				if ${This.MinMana} != ${UIElement[MinMana_slider@Resting@Settings@ClassGUI].Value}     
		{       
			UIElement[MinMana_slider@Resting@Settings@ClassGUI]:SetValue[${This.MinMana}]     
		}


		if ${This.flashMult} != ${UIElement[flashMult_slider@Healing@Settings@ClassGUI].Value}     
		{       
			UIElement[flashMult_slider@Healing@Settings@ClassGUI]:SetValue[${This.flashMult}]     
		}
		if ${This.holyMult} != ${UIElement[holyMult_slider@Healing@Settings@ClassGUI].Value}     
		{       
			UIElement[holyMult_slider@Healing@Settings@ClassGUI]:SetValue[${This.holyMult}]     
		}	
		if ${This.HpHammer} != ${UIElement[HpHammer_slider@Healing@Settings@ClassGUI].Value}     
		{       
			UIElement[HpHammer_slider@Healing@Settings@ClassGUI]:SetValue[${This.HpHammer}]     
		}
		if ${This.HpEmerg} != ${UIElement[HpEmerg_slider@Healing@Settings@ClassGUI].Value}     
		{       
			UIElement[HpEmerg_slider@Healing@Settings@ClassGUI]:SetValue[${This.HpEmerg}]     
		}		
		if ${This.HpPotion} != ${UIElement[HpPotion_slider@Healing@Settings@ClassGUI].Value}     
		{       
			UIElement[HpPotion_slider@Healing@Settings@ClassGUI]:SetValue[${This.HpPotion}]     
		}	
		
		if ${This.multiCons} != ${UIElement[multiCons_slider@Miscellaneous@Settings@ClassGUI].Value}     
		{       
			UIElement[multiCons_slider@Miscellaneous@Settings@ClassGUI]:SetValue[${This.multiCons}]     
		}	
					
		if ${This.PullRange} != ${UIElement[PullRange_slider@Combat@Settings@ClassGUI].Value}     
		{       
			UIElement[PullRange_slider@Combat@Settings@ClassGUI]:SetValue[${This.PullRange}]     
		}
		
				if ${This.ExorcismHP} != ${UIElement[useExHP_slider@Combat@Settings@ClassGUI].Value}     
		{       
			UIElement[useExHP_slider@Combat@Settings@ClassGUI]:SetValue[${This.ExorcismHP}]     
		}	

				if ${This.scrollSpam}          
		{         
			UIElement[scrollSpam@Resting@Settings@ClassGUI]:SetChecked     
		}
						if ${This.emergBless}          
		{         
			UIElement[emergBless@Healing@Settings@ClassGUI]:SetChecked     
		}
						if ${This.useBandage}          
		{         
			UIElement[useBandage@Healing@Settings@ClassGUI]:SetChecked     
		}
						if ${This.multiChange}          
		{         
			UIElement[multiChange@Miscellaneous@Settings@ClassGUI]:SetChecked     
		}
						if ${This.castInterruption}          
		{         
			UIElement[castInterruption@Miscellaneous@Settings@ClassGUI]:SetChecked     
		}
						if ${This.hammerSpam}          
		{         
			UIElement[hammerSpam@Miscellaneous@Settings@ClassGUI]:SetChecked     
		}
						if ${This.torrentSpam}          
		{         
			UIElement[torrentSpam@Miscellaneous@Settings@ClassGUI]:SetChecked     
		}
						if ${This.useWrath}          
		{         
			UIElement[useWrath@Combat@Settings@ClassGUI]:SetChecked     
		}
						if ${This.combatDebuff}          
		{         
			UIElement[combatDebuff@Combat@Settings@ClassGUI]:SetChecked     
		}		
		
								if ${This.useExorcism}          
		{         
			UIElement[useEx@Combat@Settings@ClassGUI]:SetChecked     
		}	
			
	}	

	method ClassGUIChange(string Action)
	{
		switch ${Action}
		{
			case RestHP       
				{      
					if ${UIElement[RestHP_slider@Resting@Settings@ClassGUI].Value(exists)}    
					{     
						This.RestHP:Set[${UIElement[RestHP_slider@Resting@Settings@ClassGUI].Value}]       
					}       
					break      
				}
				case MinHP       
				{      
					if ${UIElement[MinHP_slider@Resting@Settings@ClassGUI].Value(exists)}    
					{     
						This.MinHP:Set[${UIElement[MinHP_slider@Resting@Settings@ClassGUI].Value}]       
					}       
					break      
				}
			case RestMana       
				{      
					if ${UIElement[RestMana_slider@Resting@Settings@ClassGUI].Value(exists)}    
					{     
						This.RestMana:Set[${UIElement[RestMana_slider@Resting@Settings@ClassGUI].Value}]       
					}       
					break      
				}
			case MinMana       
				{      
					if ${UIElement[MinMana_slider@Resting@Settings@ClassGUI].Value(exists)}    
					{     
						This.MinMana:Set[${UIElement[MinMana_slider@Resting@Settings@ClassGUI].Value}]       
					}       
					break      
				}
			case scrollSpam      
				{      
						UIElement[Resting@Settings@ClassGUI].FindChild[scrollSpam]:ToggleChecked
  						This.scrollSpam:Set[${UIElement[scrollSpam@Resting@Settings@ClassGUI].Checked}]
						break
				}	
			case flashMult       
				{      
					if ${UIElement[flashMult_slider@Healing@Settings@ClassGUI].Value(exists)}    
					{     
						This.flashMult:Set[${UIElement[flashMult_slider@Healing@Settings@ClassGUI].Value}]       
					}       
					break      
				}	
			case holyMult       
				{      
					if ${UIElement[holyMult_slider@Healing@Settings@ClassGUI].Value(exists)}    
					{     
						This.holyMult:Set[${UIElement[holyMult_slider@Healing@Settings@ClassGUI].Value}]       
					}       
					break      
				}
			case HpHammer       
				{      
					if ${UIElement[HpHammer_slider@Healing@Settings@ClassGUI].Value(exists)}    
					{     
						This.HpHammer:Set[${UIElement[HpHammer_slider@Healing@Settings@ClassGUI].Value}]       
					}       
					break      
				}
			case HpEmerg       
				{      
					if ${UIElement[HpEmerg_slider@Healing@Settings@ClassGUI].Value(exists)}    
					{     
						This.HpEmerg:Set[${UIElement[HpEmerg_slider@Healing@Settings@ClassGUI].Value}]       
					}       
					break      
				}
			case HpPotion       
				{      
					if ${UIElement[HpPotion_slider@Healing@Settings@ClassGUI].Value(exists)}    
					{     
						This.HpPotion:Set[${UIElement[HpPotion_slider@Healing@Settings@ClassGUI].Value}]       
					}       
					break      
				}	
			case emergBless      
				{      
						UIElement[Healing@Settings@ClassGUI].FindChild[emergBless]:ToggleChecked
  						This.emergBless:Set[${UIElement[emergBless@Healing@Settings@ClassGUI].Checked}]
						break
				}	
			case useBandage      
				{      
						UIElement[Resting@Healing@ClassGUI].FindChild[useBandage]:ToggleChecked
  						This.useBandage:Set[${UIElement[useBandage@Healing@Settings@ClassGUI].Checked}]
						break
				}
			case multiCons       
				{      
					if ${UIElement[multiCons_slider@Miscellaneous@Settings@ClassGUI].Value(exists)}    
					{     
						This.multiCons:Set[${UIElement[multiCons_slider@Miscellaneous@Settings@ClassGUI].Value}]       
					}       
					break      
				}	
			case multiChange      
				{      
						UIElement[Miscellaneous@Settings@ClassGUI].FindChild[multiChange]:ToggleChecked
  						This.multiChange:Set[${UIElement[multiChange@Miscellaneous@Settings@ClassGUI].Checked}]
						break
				}
			case multiAura    
				{      
					if ${UIElement[multiAura@Miscellaneous@Settings@ClassGUI].Selection(exists)}    
					{        
						This.multiAura:Set[${UIElement[multiAura@Miscellaneous@Settings@ClassGUI].Item[${UIElement[multiAura@Miscellaneous@Settings@ClassGUI].Selection}]}]    
					}       
					break     
				}
			case castInterruption      
				{      
						UIElement[Miscellaneous@Settings@ClassGUI].FindChild[castInterruption]:ToggleChecked
  						This.castInterruption:Set[${UIElement[castInterruption@Miscellaneous@Settings@ClassGUI].Checked}]
						break
				}
			case hammerSpam      
				{      
						UIElement[Miscellaneous@Settings@ClassGUI].FindChild[hammerSpam]:ToggleChecked
  						This.hammerSpam:Set[${UIElement[hammerSpam@Miscellaneous@Settings@ClassGUI].Checked}]
						break
				}
			case torrentSpam      
				{      
						UIElement[Miscellaneous@Settings@ClassGUI].FindChild[torrentSpam]:ToggleChecked
  						This.torrentSpam:Set[${UIElement[torrentSpam@Miscellaneous@Settings@ClassGUI].Checked}]
						break
				}		
																																							case useWrath      
				{      
						UIElement[Combat@Settings@ClassGUI].FindChild[useWrath]:ToggleChecked
  						This.useWrath:Set[${UIElement[useWrath@Combat@Settings@ClassGUI].Checked}]
						break
				}
			case combatDebuff      
				{      
						UIElement[Combat@Settings@ClassGUI].FindChild[combatDebuff]:ToggleChecked
  						This.combatDebuff:Set[${UIElement[combatDebuff@Combat@Settings@ClassGUI].Checked}]
						break
				}	
				
			case useEx      
				{      
						UIElement[Combat@Settings@ClassGUI].FindChild[useEx]:ToggleChecked
  						This.useExorcism:Set[${UIElement[useEx@Combat@Settings@ClassGUI].Checked}]
						break
				}
				
			case PullRange       
				{      
					if ${UIElement[PullRange_slider@Combat@Settings@ClassGUI].Value(exists)}    
					{     
						This.PullRange:Set[${UIElement[PullRange_slider@Combat@Settings@ClassGUI].Value}]       
					}       
					break      
				}		
				
			case useExHP       
				{      
					if ${UIElement[useExHP_slider@Combat@Settings@ClassGUI].Value(exists)}    
					{     
						This.ExorcismHP:Set[${UIElement[useExHP_slider@Combat@Settings@ClassGUI].Value}]       
					}       
					break      
				}
			case Blessing    
				{      
					if ${UIElement[Blessing@Combat@Settings@ClassGUI].Selection(exists)}    
					{        
						This.Blessing:Set[${UIElement[Blessing@Combat@Settings@ClassGUI].Item[${UIElement[Blessing@Combat@Settings@ClassGUI].Selection}]}]    
					}       
					break     
				}
			case Aura    
				{      
					if ${UIElement[Aura@Combat@Settings@ClassGUI].Selection(exists)}    
					{        
						This.Aura:Set[${UIElement[Aura@Combat@Settings@ClassGUI].Item[${UIElement[Aura@Combat@Settings@ClassGUI].Selection}]}]    
					}       
					break     
				}
			case DmgSeal    
				{      
					if ${UIElement[DmgSeal@Combat@Settings@ClassGUI].Selection(exists)}    
					{        
						This.DmgSeal:Set[${UIElement[DmgSeal@Combat@Settings@ClassGUI].Item[${UIElement[DmgSeal@Combat@Settings@ClassGUI].Selection}]}]    
					}       
					break     
				}	
			case SealPull    
				{      
					if ${UIElement[SealPull@Combat@Settings@ClassGUI].Selection(exists)}    
					{        
						This.SealPull:Set[${UIElement[SealPull@Combat@Settings@ClassGUI].Item[${UIElement[SealPull@Combat@Settings@ClassGUI].Selection}]}]    
					}   
					This:genJudgePull    
					break     
				}	
			default
				{

				}				
		}
		This:SaveConfig
	}
}