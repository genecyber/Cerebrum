objectdef cTargeting inherits cBase
{
	variable guidlist possibleNPCTargets
	variable guidlist possiblePvPTargets
	variable int TargetTimer = ${LavishScript.RunningTime}
	variable index:string TargetCollection
	variable int MinLvL = 1
	variable int MaxLvL = 80
	
	variable int CollectionRange = 200
	
	method getTargets()
	{	
		variable int i = 1
		variable int k = 1	
		variable float targetWeight = 0
		variable float testWeight = 0
		variable objectref PossibleTarget
		variable collection:float targetValue
		variable int throttleCount = 0		
		variable int maxCount = ${Config.GetSlider[sldMaxTargetCollection]}
		
		Targeting.possibleNPCTargets:Clear
		Targeting.possiblePvPTargets:Clear
		
		if ${Me.InCombat}
		{
			if (${Math.Calc[${LavishScript.RunningTime} - ${This.TargetTimer}]} < 300)
			{
				return
			}			
			maxcount:Set[${maxcount}+3]
			Targeting.possibleNPCTargets:Search[-units,-alive,-nonpvp,-nonfriendly,-nocritters,-notflying,-attackable,-nearest,-range 0-${This.CollectionRange}]
		}
		else
		{
			if (${Math.Calc[${LavishScript.RunningTime} - ${This.TargetTimer}]} < ${Bot.LagInterval})
			{
				return
			}			
			Targeting.possibleNPCTargets:Search[-units,-alive,-nonpvp,-nonfriendly,-nocritters,-untapped,-levels ${This.MinLvL}-${This.MaxLvL},-notflying,-attackable,-nearest,-range 0-${This.CollectionRange}]
		}	
		This.TargetTimer:Set[${LavishScript.RunningTime}]
			
		;Clear the collection
		Targeting.TargetCollection:Collapse
		This:ClearIndex[TargetCollection]
		
		;Iterate each guid list and add them to the index
		if ${Targeting.possibleNPCTargets.Count}
		{
			do
			{	
				if ${throttleCount} >= ${maxCount}
				{
					break
				}
				; Added test to make sure mob is valid as a target
				PossibleTarget:Set[${Targeting.possibleNPCTargets.Object[${i}].GUID}]
				if ${Toon.ValidTarget[${PossibleTarget.GUID}]} || ${Toon.TargetingMeOrPet[${PossibleTarget.GUID}]}
				{		
					throttleCount:Inc				
					;echo I am ${throttleCount} and I am ${PossibleTarget.Distance} away					
					Targeting.TargetCollection:Insert[${PossibleTarget.GUID}]
					; weight all mobs and sort them at the bottom
					targetWeight:Set[200]
					targetWeight:Dec[${PossibleTarget.Distance}]	
					
					/* in combat, mobs with fewer hitpoints or lots of mana are more desirable */
					if ${Me.InCombat}
					{
						targetWeight:Dec[${PossibleTarget.PctHPs}]
						targetWeight:Inc[${PossibleTarget.PctMana}]
					}
					else
					{
						/* when not in combat, hostile mobs get extra weight when nearby */
						if ${PossibleTarget.ReactionLevel} <= 3 && ${PossibleTarget.Distance} < 30
						{	
							; any hostile mob within 30 yards should be weighted by hostility and distance
							targetWeight:Inc[(30-${PossibleTarget.Distance})*(4-${PossibleTarget.ReactionLevel})]
							
							; when we have a target, we need to make sure a mob doesnt wander into our path
							if ${Target(exists)} && !${PossibleTarget.GUID.Equal[${Target.GUID}]}
							{
								if ${Navigator.IntersectsPathXY[${Target.X},${Target.Y},${PossibleTarget.X},${PossibleTarget.Y}]} && ${PossibleTarget.Distance} <= ${Math.Calc[${Target.Distance}+10]}
								{
									targetWeight:Inc[100]
								}
							}
						}
						
						/* our current target gets extra weight */
						if ${PossibleTarget.GUID.Equal[${Target.GUID}]}
						{
							targetWeight:Inc[100]
						}							
						
						/* Prefer Quest Mobs */
						if ${PossibleTarget.NeedSlaughterCount}
						{
							targetWeight:Inc[300]
						}	
												
						if !${UIElement[chkPreferElites@Config@Pages@Cerebrum].Checked}
						{
							if ${PossibleTarget.Classification.Find[Elite]}
							{
								if ${PossibleTarget.Distance} > 20
								{
									Targeting.TargetCollection:Remove[${throttleCount}]
									Targeting.TargetCollection:Collapse
									throttleCount:Dec
								}
								targetWeight:Dec[1000]
							}
						}
						
						/* blacklisted mobs get very undervalued */ 
						if ${GlobalBlacklist.Exists[${PossibleTarget.GUID}]}
						{
							/* remove blacklist targets all together if the are more than 20 yards away */
							if ${PossibleTarget.Distance} > 20
							{
								Targeting.TargetCollection:Remove[${throttleCount}]
								Targeting.TargetCollection:Collapse
								throttleCount:Dec
							}
							targetWeight:Dec[1000]
						}
					}
					
					/* weight mobs more heavily when we have LoS */
					if ${PossibleTarget.LineOfSight}
					{
						targetWeight:Inc[100]
					}
					else
					{
						targetWeight:Dec[100]						
					}
									
					targetValue:Set[${PossibleTarget.GUID},${targetWeight}]
					This:Debug[${PossibleTarget.Name} - ${targetWeight}]
				}
			}
			while ${i:Inc} <= ${Targeting.possibleNPCTargets.Count}
		}

		/* only perform pvp searches if enabled in GUI */
		if ${UIElement[chkAttackPvP@Config@Pages@Cerebrum].Checked}
		{
			Targeting.possiblePvPTargets:Search[-players,-pvp,-alive,-notflying,-attackable,-range 0-200]
		}	
		elseif ${Me.InCombat} && ${UIElement[chkDefendPvP@Config@Pages@Cerebrum].Checked}
		{
			Targeting.possiblePvPTargets:Search[-players,-pvp,-alive,-aggro,-notflying,-attackable,-range 0-200]
		}
		
		i:Set[1]
		if ${Targeting.possiblePvPTargets.Count}
		{
			do
			{
				PossibleTarget:Set[${Targeting.possiblePvPTargets.Object[${i}].GUID}]
				if ${PossibleTarget(exists)} && ${PossibleTarget.Name.NotEqual[NULL]}
				{
					/* add pvp target I need to defend myself or it should be added */
					if ${UIElement[chkDefendPvP@Config@Pages@Cerebrum].Checked} && (${PossibleTarget.Target.GUID.Equal[${Me.GUID}]} || ${PossibleTarget.Target.GUID.Equal[${Me.Pet.GUID}]})
					{
						Targeting.TargetCollection:Insert[${PossibleTarget.GUID}]			
					}
					elseif ${UIElement[chkAttackPvP@Config@Pages@Cerebrum].Checked}
					{
						Targeting.TargetCollection:Insert[${PossibleTarget.GUID}]			
					}
					elseif ${PossibleTarget.GUID.Equal[${PossibleTarget.GUID}]}
					{
						This:Debug["Not Adding PvP target. Does not meet criteria for defending self."]							
					}
					
					/* heavily wieght getting attacked */
					if ${PossibleTarget.Target.GUID.Equal[${Me.GUID}]} || ${PossibleTarget.Target.GUID.Equal[${Me.Pet.GUID}]}
					{
						targetWeight:Set[600]
					}
					elseif ${Me.InCombat} && !${PossibleTarget.InCombat}
					{
						targetWeight:Set[200]					
					}
					else
					{
						targetWeight:Set[500]
					}

					/* weight players more heavily when we have LoS */
					if ${PossibleTarget.LineOfSight}
					{
						targetWeight:Inc[100]
					}
					else
					{
						targetWeight:Dec[100]						
					}

					/* heavily weight when they are close to me */
					if ${PossibleTarget.Distance} <= ${Toon.PullRange}
					{
						targetWeight:Inc[100]
					}
					else
					{
						targetWeight:Dec[100]					
					}
					
					/* our current target gets extra weight */
					if ${PossibleTarget.GUID.Equal[${Target.GUID}]}
					{
						targetWeight:Inc[100]
					}	
					
					/* decreasing priority by HP -- lower health is easier to kill */
					targetWeight:Dec[${PossibleTarget.PctHPs}]
					targetWeight:Dec[${PossibleTarget.Distance}]
					targetValue:Set[${PossibleTarget.GUID},${targetWeight}]
				}
			}
			while ${i:Inc} <= ${Targeting.possiblePvPTargets.Count}
		}

		/* add totems in combat */
		if ${Unit[-totem, -nonfriendly, -range 0-20](exists)} && ${Me.InCombat}
		{
			PossibleTarget:Set[${Unit[-totem, -nonfriendly, -range 0-20].GUID}]
			Targeting.TargetCollection:Insert[${PossibleTarget.GUID}]
			targetValue:Set[${PossibleTarget.GUID},0]
		}
		
		/* now we order target collection */	
		targetWeight:Set[0]
		variable int lowindex = 0
		for (i:Set[1]; ${Targeting.TargetCollection.Get[${i}](exists)}; i:Inc)
		{
			; Set the Target Weight to be The current index value
			targetWeight:Set[${targetValue.Element[${Targeting.TargetCollection.Get[${i}]}]}]
			
			lowindex:Set[0]
			
			for (k:Set[${Math.Calc[${i}+1]}]; ${Targeting.TargetCollection.Get[${k}](exists)}; k:Inc)
			{
				if ${targetWeight} < ${targetValue.Element[${Targeting.TargetCollection.Get[${k}]}]}
				{
					targetWeight:Set[${targetValue.Element[${Targeting.TargetCollection.Get[${k}]}]}]
					lowindex:Set[${k}]
				}
			}
			if ${lowindex} > 0
			{
				Targeting.TargetCollection:Swap[${i},${lowindex}]
			}
		}
		
		This:Debug[Mobs Found: ${throttleCount} of ${Targeting.possibleNPCTargets.Count}  PvP Found: ${Targeting.possiblePvPTargets.Count}]
		This:Debug[Top Target: ${Unit[${Targeting.TargetCollection.Get[1]}].Name}  -  ${targetValue.Element[${Targeting.TargetCollection.Get[1]}]}]

		/* refresh GUI after getting new targets */
		Targeting:RefreshGUI
	}
	
	method RefreshGUI()
	{
		variable int i = 1
		UIElement[lstTargets@Overview@Pages@Cerebrum]:ClearItems
		if ${Targeting.TargetCollection.Get[${i}](exists)}
		{
			do
			{
				UIElement[lstTargets@Overview@Pages@Cerebrum]:AddItem[${Object[${Targeting.TargetCollection.Get[${i}]}].Name}]
				
			}
			while ${Targeting.TargetCollection.Get[${i:Inc}](exists)}
		}
	}

	method MinMaxLvLs()
	{
		Targeting.MinLvL:Set[${Toon.MinMobLevelToGainXP}]
		Targeting.MaxLvL:Set[${Math.Calc[${Me.Level} + 2]}] 	
		
		if ${UIElement[chkIgnoreMax@Config@Pages@Cerebrum].Checked}
		{
			Targeting.MinLvL:Set[80]			
			Targeting.MaxLvL:Set[80]
		}
		if ${UIElement[chkIgnoreMin@Config@Pages@Cerebrum].Checked}
		{
			Targeting.MinLvL:Set[1]
		}		
		UIElement[txtMinLvL@Config@Pages@Cerebrum]:SetText[Min: ${Targeting.MinLvL}]
		UIElement[txtMaxLvL@Config@Pages@Cerebrum]:SetText[Max: ${Targeting.MaxLvL}]
		This:Debug["${This.MinLvL} min and ${This.MaxLvL} max"]	
	}
	
	member realAgg()
	{
		if ${Me.InCombat}
		{
			variable guidlist aggedTargets
			variable guidlist tappedTargets
			aggedTargets:Clear
			tappedTargets:Clear
			aggedTargets:Search[-units,-targetingme]
			tappedTargets:Search[-units,-tappedbyme]
			if ${aggedTargets.Count}
				return TRUE
			if ${tappedTargets.Count}
				return TRUE
			
		}
		return FALSE
	}
	
	member AggroRange(string GUID)
	{
		variable objectref Mob = ${GUID}
		variable int Range = 20
		
		Range:Dec[${Math.Calc[${Me.Level} - ${Mob.Level}]}]
		
		if ${Range} < 5
		{
			Range:Set[5]
		}
		if ${Range} > 45
		{
			Range:Set[45]
		}
		return ${Range}
	}
}