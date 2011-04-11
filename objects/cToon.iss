objectdef cToon inherits cBase
{
	/* Common Functions designed for use in Class Routines include */
	/*  	Toon:BestTarget - target the best target  */
	/* 	${Toon.TargetIsBestTarget} - return TRUE if current target is best target  */
	/* 	%{Toon.BestTarget} - return GUID of the best target */
	/* 	${Toon.NextBestTarget} -  return GUID of the next best target  */
	/* 	Toon:Sitdown - ensures you are sitting */
	/* 	Toon:Standup - ensures you are standing  */
	/* 	${Toon.DetectAdds[ObjectGUID]} - returns true or false if ## adds are within radius of GUID  */
	/* 	${Toon.AggroWithin[Range]} - returns number of incombat mobs in range use [Range,TRUE] for those just targeting you  */
	/* 	${Toon.canCast[spellname] - is spell currently castable (exists, have mana, not on cooldown)  */
	/* 	Toon:CastSpell[spellname] - cast spell, defaults to target if a target is needed  */
	/* 	${isFacingAway} - check to see if your target is facing away from you */	
	/* 	${IsDotted} - check to see if you have a damage over time debuff */
	/* 	${canShoot} - check to see if you can shoot or throw */
	/* 	Toon:Shoot - Shoot bow or Gun, or Throw depending on equipped */
	/* 	${canUseScroll} - check if you a usable scrolls and not the buff - if you dont specify a scroll it returns any, otherwise you can specify with canUseScroll[Agility]*/
	/* 	Toon:UseScroll - use a scroll in inventory - if you dont specify a scroll it returns any, otherwise you can specify with UseScroll[Agility]*/
	/* 	${canBandage} - checks if you have bandages and are not recently bandaged */
	/* 	Toon:Bandage - uses any available bandage in your inventory */
	
	member PullRange()
	{
		variable int maxrange = ${UIElement[cmbPullRange@Grind@Pages@Cerebrum].SelectedItem}
		return ${maxrange}
	}
	
	/* may make these changeable in gui */
	member MinRanged()
	{
		return ${Math.Calc[11+${Target.BoundingRadius}]}
	}
	member MaxRanged()
	{
		if ${Target.BoundingRadius} < 2
		{
			return ${Math.Calc[27+${Target.BoundingRadius}]}
		}	
		return 29
	}
	member MinMelee()
	{
		return ${Math.Calc[1+${Target.BoundingRadius}]}
	}	
	member MaxMelee()
	{
		if ${Target.BoundingRadius} < 2
		{
			return ${Math.Calc[2.9+${Target.BoundingRadius}]}
		}
		return 4.5
	}

	member Casting()
	{
		if !${Me.Casting}
		{
			return FALSE
		}
		if ${This.LootCasting}
		{
			return FALSE
		}
		return TRUE
	}
	
	member LootCasting()
	{
		if !${Me.Casting}
		{
			return FALSE
		}
		if ${Me(unit).Casting.Name.Find[Skinning]}
		{
			return TRUE
		}
		if ${Me(unit).Casting.Name.Find[Herbalism]}
		{
			return TRUE
		}
		if ${Me(unit).Casting.Name.Find[Mining]}
		{
			return TRUE
		}				
		if ${Me(unit).Casting.Name.Find[Opening]}
		{
			return TRUE
		}
		if ${Me(unit).Casting.Name.Find[Fishing]}
		{
			return TRUE
		}
		return FALSE
	}

	/* ---------------------------------------------------------------------- */
	/* ----------------  ROUTINE FUNCTIONS  */
	/* these are functions that should be common to all routines -- routine authors should make liberal use of these functions */			

			method Flee(bool ToggleOn=TRUE)
			{
				if ${ToggleOn}
				{
					This:Output["Run away! Run away!"]				
					Flee.RunAway:Set[TRUE]
				}
				else
				{
					Flee.RunAway:Set[FALSE]
				}
			}
	
			/* Toon:BestTarget ensures you have the best target -- trust targeting collection :) */
			method BestTarget()
			{
				if ${Object[${Targeting.TargetCollection.Get[1]}](exists)}
				{
					Target ${Targeting.TargetCollection.Get[1]}
				}
				This:Output[Best Target not found.]		
			}

			/* ${Toon.TargetIsBestTarget} returns true or false if your target is best target */
			member TargetIsBestTarget()
			{
				if ${Target(exists)} && ${Target.GUID.Equal[${Targeting.TargetCollection.Get[1]}]}
				{
					return TRUE
				}
				return FALSE
			}

			/* note: this is a member, not a method - so use ${Toon.BestTarget} to get GUID*/
			member BestTarget()
			{
				return ${Targeting.TargetCollection.Get[1]}	
			}
			
			/* returns the next best target on the collection list */
			member NextBestTarget()
			{
				if ${Object[${Targeting.TargetCollection.Get[2]}](exists)}
				{
					return ${Targeting.TargetCollection.Get[2]}
				}
				return NULL
			}
			
			variable string LastTarget_GUID
			member TargetIsNew()
			{
				if ${This.LastTarget_GUID.Equal[${Target.GUID}]}
				{
					This.LastTarget_GUID:Set[${Target.GUID}]
					return FALSE
				}
				This.LastTarget_GUID:Set[${Target.GUID}]
				return TRUE
			}
			
			method AutoAttack()
			{
				if !${Me.Attacking}
				{
					WoWScript AttackTarget()
				}				
			}
			
			member withinYards(int distYards)
			{
				if ${Target.Distance} <= ${distYards}
				{
					return TRUE
				}
				return FALSE
			}
			
			member withinMelee(bool ForceStop=FALSE)
			{
				if ${Target.Distance} < ${Toon.MaxMelee} && ${Target.Distance} > ${Toon.MinMelee}
				{
					if ${ForceStop} && ${Movement.Speed}
					{
						This:Stop							
						Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
					}
					return TRUE
				}
				return FALSE
			}
			
			method ToMelee()
			{
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
				if ${Target.Distance} < ${Toon.MaxMelee} && ${Target.Distance} > ${Toon.MinMelee} && ${Movement.Speed}
				{
					This:Stop			
				}
				elseif ${Target.Distance} > ${Toon.MaxMelee}
				{
					Navigator:MoveToMob[${Target.GUID}]
				}
				elseif ${Target.Distance} < ${Toon.MinMelee}
				{
					Navigator:MoveBackward[500]
				}
			}
			
			member withinRanged(bool ForceStop=FALSE)
			{
				if ${Target.Distance} < ${Toon.MaxRanged} && ${Target.Distance} > ${Toon.MinRanged}
				{
					if ${ForceStop} && ${Movement.Speed}
					{
						This:Stop						
						Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
					}
					return TRUE
				}
				return FALSE				
			}
			
			method ToRanged()
			{
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
				if ${Target.Distance} < ${Toon.MaxRanged} && ${Target.Distance} > ${Toon.MinRanged} && ${Movement.Speed}
				{
					This:Stop			
				}
				elseif ${Target.Distance} > ${Toon.MaxRanged}
				{
					Navigator:MoveToMob[${Target.GUID}]
				}
				elseif ${Target.Distance} < ${Toon.MinRanged}
				{
					Navigator:MoveBackward[1500]
				}				
			}
			
			method Stop()
			{
				Navigator:ClearPath
				move -stop
			}

			/* test whether conditions allow for kiting */
			member canKite(bool backward=TRUE)
			{
				variable int i = 1
				variable guidlist Meanies
				
				if ${Flee.Distance[${Flee.numPoints}]} < 8
				{
					Flee:Remove[${Flee.numPoints}]
				}		
				if ${Me.X} == ${Flee.X} && ${Me.X} == ${Flee.Y}
				{
					return FALSE
				}
				if ${Flee.Distance[${Flee.numPoints}]} < 8
				{
					return FALSE
				}
				if ${backward}
				{
					if ${This.KiteFace_ErrorTest} > 5 
					{
						if ${Math.Calc[${LavishScript.RunningTime}-${This.KiteFace_LastFace}]} < 15000
						{
							return FALSE	
						}
						This.KiteFace_ErrorTest:Set[0]
					}
					if ${Me.IsPathObstructed[${Flee.X},${Flee.Y},${Math.Calc[${Flee.Z}+0.6]}]}
					{
						return FALSE
					}
				}
				Meanies:Search[-units, -nearest, -alive, -hostile, -range 0-15, -origin,${Flee.X},${Flee.Y},${Flee.Z}]	
				if ${Meanies.Count} > 0
				{
					do
					{
						if !${This.TargetingMeOrPet[${Meanies.GUID[${i}]}]}
						{
							return FALSE
						}
					}
					while ${i:Inc} <= ${Meanies.Count}
				}
				return TRUE	
			}
						
			/* uses the flee path to kite a mob - should be used with canKite */
			method Kite(bool backward=TRUE)
			{				
				if ${backward}
				{
					Navigator:ClearPath
					if ${Math.Abs[${Me.Heading}-${Navigator.Flip[${Me.HeadingTo[${Flee.X},${Flee.Y}]}]}]} < 30
					{
						This.KiteFace_ErrorTest:Set[0]
						Navigator:MoveBackward[500]
						This:Debug[Kiting - Moving Backwards]
						return
					}
					elseif !${ISXWoW.Facing}
					{
						This.KiteFace_ErrorTest:Inc
						This.KiteFace_LastFace:Set[${LavishScript.RunningTime}]
						face -headingfast ${Navigator.Flip[${Me.HeadingTo[${Flee.X},${Flee.Y}]}]}
						This:Debug[Kiting - Facing Backwards]
						return
					}
				}
				elseif !${Navigator.MovingToPoint[${FleeX},${Flee.Y},${Flee.Z}]} 
				{
					Navigator:MoveToLoc[${Flee.X},${Flee.Y},${Flee.Z}]		
				}
				This:Debug[Kiting - Moving to Point]		
			}

			/* this helps prevent drowning */
			member Sitting()
			{
				if ${Me.Sitting} 
				{
					WoWScript DescendStop() 
					return TRUE
				}
				WoWScript DescendStop() 
				return FALSE				
			}
			
			/* Toon:Sitdown ensures you are sitting */
			method Sitdown()
			{
				if !${Toon.Sitting} 
				{
					WowScript DoEmote("SIT")
					This.WaitRunningTime:Set[${Math.Calc[${LavishScript.RunningTime} + ${This.SitOrStandTimeout}]}]
				}
			}
			
			/* Toon:Standup ensures you are standing */
			method Standup()
			{
				if ${Toon.Sitting}
				{
					WowScript DoEmote("STAND")
					This.WaitRunningTime:Set[${Math.Calc[${LavishScript.RunningTime} + ${This.SitOrStandTimeout}]}]
				}
			}

			/* return TRUE if ## adds within XX yards of GUID*/
			member DetectAdds(string ObjectGUID, int MaxAdds=0, int SearchRadius=0)
			{
				variable guidlist MobAdds
				/* default to slider value */
				if ${SearchRadius} == 0
				{
					SearchRadius:Set[${Config.GetSlider[sldDetectAddRadius]}]
				}
				
				if ${MaxAdds} == 0
				{
					MaxAdds:Set[${Config.GetSlider[sldMaxAdds]}]
				}
				
				/* perform search */
				if ${Object[${ObjectGUID}](exists)}
				{			
					if ${Me.InCombat}
					{
						MobAdds:Search[-units, -nearest, -alive, -nonfriendly, -targetingme, -range 0-${SearchRadius}, -origin,${Object[${ObjectGUID}].X},${Object[${ObjectGUID}].Y},${Object[${ObjectGUID}].Z}]	
					}		
					else
					{
						MobAdds:Search[-units, -nearest, -alive,  -hostile, -range 0-${SearchRadius}, -origin,${Object[${ObjectGUID}].X},${Object[${ObjectGUID}].Y},${Object[${ObjectGUID}].Z}]	
					}	
					
					/* we need to handle units a bit different because the object search is likely counting ObjectGUID */
					if ${Unit[${ObjectGUID}](exists)}
					{
						/* out-of-combat non-hostile mobs are not counted in object search -- all others are, so we need to +1 */
						if  !${Unit[${ObjectGUID}].InCombat} && ${Unit[${ObjectGUID}].ReactionLevel} <  2 && ${MobAdds.Count} > ${MaxAdds}
						{
							return TRUE
						}
						elseif ${MobAdds.Count} > ${Math.Calc[${MaxAdds}+1]}
						{
							return TRUE
						}
					}
					elseif ${MobAdds.Count} > ${MaxAdds}
					{
						return TRUE
					}
				}
				return FALSE
			}	

			/* returns true if our headings are + or - maxDegrees of each other */
			member isFacingAway(float maxDegrees = 90, string unitGUID = "TARGET")
			{
				variable float maxLeft = ${Math.Calc[${Me.Heading.Degrees} + ${maxDegrees}]}
				variable float maxRight = ${Math.Calc[${Me.Heading.Degrees} - ${maxDegrees}]}
				if ${unitGUID.Equal[TARGET]}
				{
					unitGUID:Set[${Target.GUID}]
				}
				if !${Object[${unitGUID}](exists)} || ${unitGUID.Equal[NULL]}
				{
					return FALSE
				}
				/* max sure our min and max fir within 0 to 360 */
				if ${maxLeft} > 360
				{
					maxLeft:Set[${maxLeft}-360]
				}
				if ${maxRight} < 0
				{
					maxRight:Set[${maxRight}+360]
				}
				/* Left is greater than Right, which is to be expected - checking target heading */
				if (${maxLeft} > ${maxRight}) && (${Object[${unitGUID}].Heading.Degrees}<=${maxLeft} && ${Object[${unitGUID}].Heading.Degrees}>=${maxRight})
				{
					return TRUE
				}
				/* Left is less than Right, which is when things get tricky */
				if (${maxLeft} < ${maxRight}) && ((${Object[${unitGUID}].Heading.Degrees} <= ${maxLeft} && ${Object[${unitGUID}].Heading.Degrees} >= 0)||(${Object[${unitGUID}].Heading.Degrees} >= ${maxRight} && ${Object[${unitGUID}].Heading.Degrees} <= 360))
				{
					return TRUE
				}
				return FALSE
			}
			
			/* returns TRUE if we have a damage over time debuff */
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
								This:Output[We got a nasty dot debuff, no stealth for you!]
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
			
			/* ${Toon.canCast[spellname]} returns true if current sell can be cast */
			member canCast(string spellname)
			{
				if ${Spell[${spellname}](exists)} && !${Spell[${spellname}].Cooldown} && !${Me.Casting} && !${Me.GlobalCooldown}
				{
					if (${Me.Power.Equal[Rage]} && ${Me.CurrentPower} >= ${Math.Calc[${Spell[${spellname}].Mana} / 10]}) || (${Me.CurrentPower} >= ${Spell[${spellname}].Mana})
					{
						return TRUE
					}
				}
				return FALSE
			}
			
			method CastSpell(string spellname)
			{
				if ${This.canCast[${spellname}]}
				{
					Cast "${spellname}"
				}
			}	

			member canShoot()
			{
				if ${Toon.ValidTarget[${Target.GUID}]} && ${This.haveAmmo} && ${Target.Distance} < ${This.MaxRanged} && ${Target.Distance} > ${This.MinRanged} && ${Target.LineOfSight}
				{
					return TRUE
				}
				return FALSE
			}
			
			method Shoot()
			{
				if ${Movement.Speed}
				{
					This:Stop
					return
				}
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
				
				if ${Me.Class.Equal[Rogue]}
				{
					if ${Spell[Deadly Throw](exists)} && ${Me.ComboPoints}>=1 &&${Me.Equip[18].SubType.Equal["Thrown"]}
					{
						Toon:CastSpell["Deadly Throw"]
						This:Output["Ranged: Casting ${MyRogueAttack}"]
						Bot.RandomPause:Set[14]
						return
					}
				}
				Toon:CastSpell[${This.RangeType}]
				This:Output["Ranged: ${This.RangeType}ing at ${Target.Name}"]	
				Bot.ForcedStateWait:Set[${This.InTenths[${Math.Calc[(${Me.Equip[18].Delay}*10)+2]}]}]		
			}			
			
			/* Usage:  AddRandom will add a spell to a spellgroup. CastRandom will randomly select a castable spell from that spellgroup and cast it. */
			/* Usage:  CastRandom[spellgroup] will cast a random spell */
			/* Usage:  CastRandom[spellgroup,"Me"] or CastRandom[spellgroup,"Target"] will check if castable AND if that buff does NOT exist on Target/Me before deciding to cast it. */
			variable collection:index:string RandomCast
			variable collection:int RandomCastCount
			
			method AddRandom(string spellGroup, string spellName)
			{
				if !${This.RandomCast.Element[${spellGroup}](exists)} && ${Bot.Started}
				{
					This.RandomCast:Set[${spellGroup}]
					This.RandomCastCount:Set[${spellGroup},0]
				}
				This.RandomCast.Element[${spellGroup}]:Insert[${spellName}]
				This.RandomCastCount.Element[${spellGroup}]:Inc
			}

			member CastRandom(string spellGroup, string checkBuff=NULL)
			{
				variable int attempts = 0
				variable int spellNum = 1
				spellNum:Inc[${Math.Rand[${This.RandomCastCount.Element[${spellGroup}]}]}]
				
				do
				{
					if ${spellNum} > ${This.RandomCastCount.Element[${spellGroup}]}
					{
						spellNum:Inc
					}
					if ${Toon.canCast[${This.RandomCast.Element[${spellGroup}].Get[${spellNum}]}]}
					{
						if ${checkBuff.Equal[Target]} || ${checkBuff.Equal[Me]}
						{
							if !${${checkBuff}.Buff[${This.RandomCast.Element[${spellGroup}].Get[${spellNum}]}](exists)}
							{
								Toon:CastSpell[${This.RandomCast.Element[${spellGroup}].Get[${spellNum}]}]
								This:Output["Casting Random Buff#${spellNum}:${This.RandomCast.Element[${spellGroup}].Get[${spellNum}]}"]
								return TRUE
							}
						}
						else
						{
							Toon:CastSpell[${This.RandomCast.Element[${spellGroup}].Get[${spellNum}]}]
							This:Output["Casting Random#${spellNum}:${This.RandomCast.Element[${spellGroup}].Get[${spellNum}]}"]
							return TRUE
						}
					}
					spellNum:Inc
				}
				while ${attempts:Inc} <= ${This.RandomCastCount.Element[${spellGroup}]}
				return FALSE
			}			
			
			method CastRandom(string spellGroup, string checkBuff=NULL)
			{
				if !${This.CastRandom[${spellGroup},${checkBuff}]}
				{
					This:Debug[RandomCast ${spellGroup} failed]
				}
			}
			
			member AggroWithin(int Range, bool TargetingMe = FALSE)
			{
				variable guidlist Aggros
				if ${TargetingMe}
				{
					Aggros:Search[-units,-nearest,-targetingme,-attackable,-aggro,-alive,-range 0-${Range}]
				}
				else
				{
					Aggros:Search[-units,-nearest,-attackable,-aggro,-alive,-range 0-${Range}]
				}
				return ${Aggros.Count}
			}	
	
			member canUseScroll(string whichScroll="ANY")
			{
				variable string scroll = ${This.checkForScroll[${whichScroll}]}
				if ${scroll.NotEqual["NONE"]}
				{		
					return TRUE
				}
				return FALSE
			}			
			
			method UseScroll(string whichScroll="ANY")
			{
				variable string scroll = ${This.checkForScroll[${whichScroll}]}
				if ${scroll.NotEqual["NONE"]}
				{
					Target ${Me.GUID}
					This:Output["Let's use the scroll of ${scroll}"]					
					Consumable:UseScroll[${scroll}]
					Bot.RandomPause:Set[14]				
					return
				}
			}
			
			member canBandage()
			{
				if ${Item[-usable,-items,-inventory,Bandage](exists)} && !${Me.Buff[Recently Bandaged](exists)}
				{
					return TRUE
				}
				return FALSE
			}
			
			method Bandage()
			{
				Target ${Me.GUID}				
				Item[-usable,-items,-inventory,Bandage]:Use
				Bot.RandomPause:Set[24]
			}

			/* checks if buff can be cast */
			member canBuff(string theGUID, string buffName, string spellName=NULL)
			{
				if ${spellName.Equal[NULL]}
				{
					spellName:Set[${buffName}]
				}
				if !${Object[${theGUID}].Buff[${buffName}](exists)} && ${This.canCast[${spellName}]}
				{
					return TRUE
				}
				return FALSE	
			}

			/* checks if buff exists, with option to check if castable or not */
			member NeedBuff(string theGUID, string spellName, bool checkspell = TRUE)
			{
				if ${checkspell}
				{
					return ${This.canBuff[${theGUID},${spellName}]}
				}
				elseif ${Object[${theGUID}].Buff[${spellName}](exists)}
				{
					return FALSE
				}
				elseif ${Object[${theGUID}](exists)}
				{
					return TRUE
				}
				return FALSE
			}

			method CastSpellGUID(string theGUID, string spellName)
			{
				if ${This.CastSpellGUID[${theGUID},${spellName}]}
				{
					This:Output["Casting: ${spellName} on ${Object[${theGUID}].Name}"]		
				}
			}

			member CastSpellGUID(string theGUID, string spellName)
			{
				if ${This.canCast[${spellName}]} && (${Unit[${theGUID}](exists)} || ${Player[${theGUID}](exists)})
				{
					if ${theGUID.NotEqual[${Target.GUID}]}
					{
						Target ${theGUID}
					}
					This:CastSpell[${spellName}]
					return TRUE
				}
				return FALSE
			}

			method EnsureBuff(string theGUID, string buffName, string spellName=NULL)
			{
				if ${This.EnsureBuff[${theGUID},${buffName},${spellName}]}
				{
					This:Output["Ensuring ${buffName} is on ${Object[${theGUID}].Name}"]
				}
			}			

			member EnsureBuff(string theGUID, string buffName, string spellName=NULL)
			{
				if ${spellName.Equal[NULL]}
				{
					spellName:Set[${buffName}]
				}
				if ${This.canBuff[${theGUID},${buffName},${spellName}]}
				{
					This:CastSpellGUID[${theGUID},${spellName}]
					return TRUE
				}
				return FALSE
			}
			
	/* ---------------------------------------------------------------------- */	
	/* ----------------  DEPRECATED FUNCTIONS  */
	/* these are functions that are only here for legacy purposes and should eventually be removed */	
	/* in some cases, i will be writing replacement functions that operate more simply - oog */
			
			/* should be using ${Toon:EnsureBuff[${${Me.GUID},spellname]} */
			member EnsureBuffOnSelf(string spellName, string buffName = NULL)
			{
				return ${This.EnsureBuff[${Me.GUID},${buffName},${spellName}]}
			}
		 
			/* should be using ${Toon:EnsureBuff[${${Target.GUID},spellname]} */	
			member EnsureBuffOnTarget(string spellName, string buffName = NULL)
			{
				return ${This.EnsureBuff[${Target.GUID},${buffName},${spellName}]}
			}

			/* should be using ${Toon:CastSpellGUID[${${Me.GUID},spellname]} */	
			member CastSpellOnSelf(string spellname, bool deadcast = FALSE)
			{
				return ${This.CastSpellGUID[${Me.GUID},${spellName}]}
			}

			/* should be using ${Toon:CastSpellGUID[${${Target.GUID},spellname]} */		
			member CastSpellOnTarget(string spellname, bool deadcast = FALSE)
			{
				return ${This.CastSpellGUID[${Target.GUID},${spellName}]}
			}

	/* ---------------------------------------------------------------------- */
	/* ----------------  CORE FUNCTIONS  */
	/* these are core toon functions used by other objects or toon methods */

	variable objectref MyTarget
	variable int CorpseRange = 5
	variable int WaitRunningTime = 0
	variable int RepopTimeout = 3000
	variable int RetrieveTimeout = 3000
	variable int SitOrStandTimeout = 300
	variable int LastRes = 0
	variable int LastCombatTime = 0
	variable int RestCombatTimeout = 3000
	variable int Level=${Me.Level}
	variable int TargetTimer = ${LavishScript.RunningTime}		
	variable collection:int EvadeBugged
	variable int KiteFace_ErrorTest
	variable int KiteFace_LastFace
	
	method Initialize()
	{
		This:LoadConfig
	}
	
	method ShutDown()
	{
		This:SaveConfig
	}
	
	method LoadConfig()
	{
		This.MaxRanged:Set[${LavishSettings[Settings].FindSetting[MaxRanged,30]}]
		This.MinRanged:Set[${LavishSettings[Settings].FindSetting[MinRanged,8]}]
	}
	
	method SaveConfig()
	{
		LavishSettings[Settings].FindSetting[MaxRanged]:Set[${This.MaxRanged}]
		LavishSettings[Settings].FindSetting[MinRanged]:Set[${This.MinRanged}]
	}

	/* this is checked in canShoot, so no other need to check it except possibly restocking */
	variable string RangeType ="NONE"
	member haveAmmo()
	{
		variable int AmmoCount
		if ${Me.Equip[18].SubType.Equal["Thrown"]}
		{
			This.RangeType:Set["Throw"]
			return TRUE
		}
		if ${Me.Equip[18].SubType.Equal["Wand"]}
		{
			This.RangeType:Set["Wand"]
			return TRUE
		}		
		AmmoCount:Set[${WoWScript["GetInventoryItemCount(\"player\", 0)"]}]
		if ${AmmoCount} > 1
		{
			This.RangeType:Set["Shoot"]
			return TRUE
		}
		This.RangeType:Set["NONE"]
		return FALSE
	}	
	
	member UnitAggro(string MobGUID)
	{
		variable objectref TargetMob
		TargetMob:Set[${MobGUID}]
		if ${TargetMob.InCombat}
		{
			return TRUE
		}
		if ${This.TargetingMeOrPet[${MobGUID}]}
		{
			return TRUE
		}
		if ${This.TargetingGroup[${MobGUID}]}
		{
			return TRUE
		}
		return FALSE
	}
	
	/* this member is for checking the vailidty of a GUID, at times we want to check by GUID not just collection list */
	/* when in combat, routines may target things that are not #1  -- example: polymorph */
	member ValidTarget(string MobGUID)
	{	
		variable objectref TargetMob
		TargetMob:Set[${MobGUID}]
		
		if !${TargetMob(exists)} || ${TargetMob.Name.Equal[NULL]} 
		{
			return FALSE
		}	
		
		if (${MobGUID.Equal[${Me.GUID}]} || ${TargetMob.Dead})
		{
			return FALSE
		}
		if !${This.TargetingMeOrPet[${MobGUID}]} && !${This.TargetingGroup[${MobGUID}]}
		{
			if ${TargetMob.Tapped}&&!${TargetMob.TappedByMe}
			{
				GlobalBlacklist:Insert[${TargetMob.GUID},360000]
				return FALSE			
			}
			if ${This.UnitAggro[${MobGUID}]} && ${MobGUID.NotEqual[${Target.GUID}]}
			{
				return FALSE			
			}	
			if ${Avoidance.Exists[${TargetMob.Name}]}
			{
				return FALSE
			}
		}
		if !${This.UnitAggro[${MobGUID}]} && !${TargetMob.IsTotem} && ${Me.InCombat}
		{
			return FALSE			
		}
		if !${TargetMob.Attackable}
		{
			return FALSE							
		}
		if ${This.EvadeBug[${MobGUID}]}
		{
			return FALSE
		}
		return TRUE
	}	
	
	member TargetingMeOrPet(string MobGUID)
	{
		variable objectref theMob
		theMob:Set[${MobGUID}]		
		if ${theMob(exists)} && ${theMob.Target(exists)}
		{
			if ${theMob.Target.GUID.Equal[${Me.GUID}]}
			{
				return TRUE
			}
			if ${Me.Pet(exists)} && ${theMob.Target.GUID.Equal[${Me.Pet.GUID}]}
			{
				return TRUE
			}
		}
		return FALSE
	}
	
	member TargetingGroup(string MobGUID)
	{
		variable int i = 1
		variable objectref theMob	
		if ${Group.Members} == 0
		{
			return FALSE
		}		
		theMob:Set[${MobGUID}]		
		if ${theMob.Target(exists)}
		{
			if ${Party.IsPartyMember[${theMob.Target.GUID}]}
			{
				return TRUE
			}
		}
		return FALSE
	}
	
	method NeedTarget(int targetnum = 1)
	{
		if ${Target(exists)} && ${Target.GUID.Equal[${Targeting.TargetCollection.Get[${targetnum}]}]}
		{
			if ${Toon.ValidTarget[${Target.GUID}]} && ${POI.GUID.Equal[${Target.GUID}]} && ${Target.PctHPs} > 0
			{
				This:Debug[We have a valid target.]
				return
			}
		}
		if ${Toon.ValidTarget[${Targeting.TargetCollection.Get[${targetnum}]}]} && ${Object[${Targeting.TargetCollection.Get[${targetnum}]}].PctHPs} > 0
		{		
			Target ${Targeting.TargetCollection.Get[${targetnum}]}
			This:Debug[X: ${Object[${Targeting.TargetCollection.Get[${targetnum}]}].X}]
			This:Debug[Y: ${Object[${Targeting.TargetCollection.Get[${targetnum}]}].Y}]
			This:Debug[Z: ${Object[${Targeting.TargetCollection.Get[${targetnum}]}].Z}]
			Navigator:FaceXYZ[${Object[${Targeting.TargetCollection.Get[${targetnum}]}].X},${Object[${Targeting.TargetCollection.Get[${targetnum}]}].Y},${Object[${Targeting.TargetCollection.Get[${targetnum}]}].Z}]
		}
	}	

	member StatusText()
	{
		return ${This.MinMobLevelToGainXP} ${This.SafeSpotRange}
	}

	member MinMobLevelToGainXP()
	{	
		variable int i
		
		if ${Me.Level} <= 5 
		{
			return 1
		}
		if ${Me.Level} > 5 && ${Me.Level} <= 39
		{
			i:Set[${Math.Calc[${Me.Level} - 5 - (${Me.Level} / 10)]}]
			return ${i:Inc[2]}
		}
		if ${Me.Level} > 39 && ${Me.Level} <= 59
		{
			i:Set[${Math.Calc[${Me.Level} - 1 - (${Me.Level} / 5)]}]
			return ${i:Inc}
		}
		if ${Me.Level} > 59
		{
			i:Set[${Math.Calc[${Me.Level} - 9]}]
			return ${i}
		}
	}
	
	member TargetInGrindRange(int targetnum = 1)
	{
		variable objectref TopTarget
		TopTarget:Set[${Targeting.TargetCollection.Get[${targetnum}]}]
		if ${This.PullMobExists[${targetnum}]}
		{		
			if ${Math.Distance[${TopTarget.X},${TopTarget.Y},${TopTarget.Z},${Grind.X},${Grind.Y},${Grind.Z}]} < ${Grind.GrindRange}
			{
				/* added an IPO and Line of Sight check -- dont travel if we cant get there */
				if ${TopTarget.LineOfSight} && !${Me.IsPathObstructed[${TopTarget.X},${TopTarget.Y},${TopTarget.Z}]} && !${GlobalBlacklist.Exists[${TopTarget.GUID}]}
				{		
					return TRUE
				}
			}
		}
		return FALSE
	}
	
	member TargetInPath(int targetnum = 1)
	{
		variable objectref TopTarget
		TopTarget:Set[${Targeting.TargetCollection.Get[${targetnum}]}]	
		if ${Navigator.IntersectsGrind[${TopTarget.X},${TopTarget.Y}]} && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${Grind.X},${Grind.Y},${Grind.Z}]} < 500
		{
			/* added an IPO and Line of Sight check -- dont travel if we cant get there */
			if ${TopTarget.LineOfSight} && !${Me.IsPathObstructed[${TopTarget.X},${TopTarget.Y},${TopTarget.Z}]} && !${GlobalBlacklist.Exists[${TopTarget.GUID}]}
			{		
				return TRUE
			}
		}				
		return FALSE
	}
	
	/* moved all conditionals for moveto mob here */
	/* this is what determines when we should aquire mobs when at a distance */
	member MoveToMob(int targetnum = 1)
	{
			; hit point check moved to PullMobExists
		if ${This.PullMobExists[${targetnum}]} && !${GlobalBlacklist.Exists[${Targeting.TargetCollection.Get[${targetnum}]}]}
		{
			; we already decided to kill the mob, so lets kill it
			if ${POI.GUID.Equal[${Targeting.TargetCollection.Get[${targetnum}]}]} && ${Unit[${Targeting.TargetCollection.Get[${targetnum}]}].LineOfSight} 
			{
				return TRUE
			}
			if ${POI.Type.Equal[HOTSPOT]} && ${Toon.TargetInPath[${targetnum}]} && ${Grind.KillInPath}
			{
				This:Debug[target is in path]
				return TRUE
			}
			if ${POI.Type.Equal[HOTSPOT]} && ${Toon.TargetInGrindRange}
			{
				This:Debug[target is in grind range]
				return TRUE
			}
		}
		return FALSE
	}
	
	/* this is what determines when we should aquire mobs at a priority over looting because they are close */
	member PullableTarget(int targetnum = 1)
	{	
			; hit point check moved to PullMobExists
		if ${This.PullMobExists[${targetnum}]} && ${Object[${Targeting.TargetCollection.Get[${targetnum}]}].LineOfSight} && ${Object[${Targeting.TargetCollection.Get[${targetnum}]}].Distance} <= ${Math.Calc[${This.PullRange}+10]}
		{
			; we already decided to kill the mob, so lets kill it
			if ${POI.GUID.Equal[${Targeting.TargetCollection.Get[${targetnum}]}]} && !${GlobalBlacklist.Exists[${Targeting.TargetCollection.Get[${targetnum}]}]}
			{
				return TRUE
			}
			if ${Toon.SafeSpotRange} < 0 
			{
				This:Debug[ack! not in safe spot range]
				return TRUE
			}
			if ${POI.Type.Equal[HOTSPOT]} && ${POI.Distance} < ${Grind.GrindRange} && !${GlobalBlacklist.Exists[${Targeting.TargetCollection.Get[${targetnum}]}]}
			{
				This:Debug[we are within grind range of hotspot, so kill anything in pull range]
				return TRUE
			}
		}
		return FALSE
	}

	member PullMobExists(int targetnum = 1)
	{
		variable string MobGUID = ${Targeting.TargetCollection.Get[${targetnum}]}
		if  ${This.ValidTarget[${MobGUID}]} && ${Object[${MobGUID}].PctHPs} > 0 
		{
			/* blacklist our target when we have 3 or more adds */
			if ${This.BlacklistWhenAdds[${MobGUID},${targetnum}]}
			{
				return FALSE
			}
			return TRUE
		}
		return FALSE
	}
		
	member BlacklistWhenAdds(string MobGUID,int targetnum = 1)
	{
		if ${This.DetectAdds[${MobGUID}]} && !${Me.InCombat} && !${UIElement[chkAssistMode@Overview@Pages@Cerebrum].Checked} && !${UIElement[chkPartyMode@Overview@Pages@Cerebrum].Checked}
		{
			This:Debug[Temp blacklisting ${Unit[${MobGUID}].Name} due to hostile adds]
			This:Output["Hostile adds detected. Skipping ${Unit[${MobGUID}].Name}"]
			GlobalBlacklist:Insert[${MobGUID},360000]
			if ${Toon.TargetInPath[${targetnum}]} 
			{
				This:Output["Hostile adds block my way to the next hotspot, so lets switch to next hotspot now."]
				Grind:NextHotspot
			}
			
			return TRUE
		}
		return FALSE
	}
	
	member SafeSpotRange()
	{
		if !${Object[${Targeting.TargetCollection.Get[1]}](exists)} || !${Targeting.TargetCollection.Get[1](exists)}
		{
			return 9999
		}
		if ${Unit[${Targeting.TargetCollection.Get[1]}].ReactionLevel} > 3
		{
			return 9999
		}
		return ${Math.Calc[${Unit[${Targeting.TargetCollection.Get[1]}].Distance} - ${This.MathMin[45,${This.MathMax[5,${Math.Calc[20 + (${Unit[${Targeting.TargetCollection.Get[1]}].Level} - ${Me.Level})]}]}]}]}
	}
	
	; which skill member is no good?
	member HasSkill(string testskill)
	{
		if ${Toon.SkillLevel[${testskill}]} > 0
		{
			return TRUE
		}
		return FALSE
	}
	
	member SkillLevel(string testskill)
	{
		if ${Me.Skill[${testskill}](exists)}
		{
			return ${Me.Skill[${testskill}]}
		}
		return 0
	}
	
	member SkillMaxLevel(string testskill)
	{
		if ${Me.Skill[${testskill}](exists)}
		{
			return ${Me.SkillMax[${testskill}]}
		}
		return 0
	}

	member CanSkinMob(string theGUID)
	{
		variable objectref theCorpse
		theCorpse:Set[${theGUID}]
		if ${OBDB.SkinType[${theCorpse.Name}].Equal[Skinning]}
		{
			if ${Item[-inventory,"Skinning Knife"](exists)} || ${Item[-inventory,"Finkle's Skinner"](exists)} || ${Item[-inventory,"Zulian Slicer"](exists)}
			{
				return TRUE
			}
		}
		else
		{
			if ${Toon.HasSkill[${OBDB.SkinType[${theCorpse.Name}]}]} >= ${Math.Calc[${theCorpse.Level}*5]} || ${theCorpse.Level} < 21
			{
				return TRUE
			}
		}
		return FALSE
	}
	
	/* returns NONE if no scroll, otherwise the name of the scroll */
	member checkForScroll(string whichScroll="ANY")
	{
		if ${whichScroll.Equal[ANY]}
		{
			if ${Consumable.HasScroll[Strength]} && !${Me.Buff[Strength](exists)}
			{
					return "Strength"
			}
			if ${Consumable.HasScroll[Agility]} && !${Me.Buff[Agility](exists)}
			{
					return "Agility"
			}
			if ${Consumable.HasScroll[Stamina]} && !${Me.Buff[Stamina](exists)}
			{
					return "Stamina"
			}
			if ${Consumable.HasScroll[Protection]} && !${Me.Buff[Armor](exists)}
			{
					return "Protection"
			}
			if ${Consumable.HasScroll[Spirit]} && !${Me.Buff[Spirit](exists)}
			{
					return "Spirit"
			}
			if ${Consumable.HasScroll[Intellect]} && !${Me.Buff[Intellect](exists)}
			{
					return "Intellect"
			}
		}
		elseif ${whichScroll.Equal[Protection]} || ${whichScroll.Equal[Armor]}
		{
			if ${Consumable.HasScroll[Protection]} && !${Me.Buff[Armor](exists)}
			{
					return "Protection"
			}
		}
		elseif ${Consumable.HasScroll[${whichScroll}]} && !${Me.Buff[${whichScroll}](exists)}
		{
			return "${whichScroll}"
		}
		return "NONE"
	}	
	
	member EvadeBug(string MobGUID)
	{
		if ${This.EvadeBugged.Element[${MobGUID}](exists)}
		{
			if ${Math.Calc[${This.EvadeBugged.Element[${MobGUID}]}-${LavishScript.RunningTime}]} < 180000
			{
				return TRUE
			}
		}
		return FALSE
	}		
}
