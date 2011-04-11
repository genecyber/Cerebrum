objectdef cAvoid inherits cBase
{
	variable int Last_Search = 0
	variable guidlist theAngry
	variable index:string theAvoided
	variable set AvoidList	
	variable objectref theBigMeanie

	variable int Count_Interval = 10000
	variable int Count_ForHotSpotChange = 2
	variable int Count_ForLocChange = 5
	
	variable collection:int LastAvoid
	variable collection:int AvoidCount
	
	method Initialize()
	{
		variable iterator AvoidIterator		
		LavishSettings[Blacklist]:AddSet[AvoidIDs]
		LavishSettings[Blacklist].FindSet[AvoidIDs]:GetSettingIterator[AvoidIterator]
		
		if ${AvoidIterator:First(exists)}
		{		
			do
			{
				if ${LavishSettings[Blacklist].FindSet[AvoidIDs].FindSetting[${AvoidIterator.Key}].Int} == -1
				{
					This.AvoidList:Add[${AvoidIterator.Key}]
				}
			}
			while ${AvoidIterator:Next(exists)}
		}
	}
	
	member Exists(string ExactName)
	{
		if ${This.AvoidList.Contains[${ExactName}]}
		{
			return TRUE
		}
		return FALSE
	}
	
	method Add(string ExactName)
	{
		if ${ExactName.NotEqual[NULL]} && ${ExactName.Length} > 0
		{
			This.AvoidList:Add[${ExactName}]
			LavishSettings[Blacklist].FindSet[AvoidIDs]:AddSetting[${ExactName},-1]
		}
	}
	
	method Remove(string ExactName)
	{
		if ${ExactName.NotEqual[NULL]} && ${This.AvoidList.Contains[${ExactName}]} && ${ExactName.Length} > 0
		{
			This.AvoidList:Remove[${ExactName}]
			LavishSettings[Blacklist].FindSet[AvoidIDs]:AddSetting[${ExactName},0]
		}		
	}
	
	method PopulateAvoids()
	{
		variable iterator AvoidIterator		
		LavishSettings[Blacklist].FindSet[AvoidIDs]:GetSettingIterator[AvoidIterator]	
		UIElement[tlbAvoids@Avoidance@POIPages@POIs@Pages@Cerebrum]:ClearItems
		if ${AvoidIterator:First(exists)}
		{		
			do
			{
				if ${LavishSettings[Blacklist].FindSet[AvoidIDs].FindSetting[${AvoidIterator.Key}].Int} == -1
				{
					UIElement[tlbAvoids@Avoidance@POIPages@POIs@Pages@Cerebrum]:AddItem[${AvoidIterator.Key}]	
				}
			}
			while ${AvoidIterator:Next(exists)}
		}		
	}
	
	/* we only perform searches every 2 seconds */
	/* if a mob to avoid is detected, it is kept in an index an monitored more frequently */
	method Pulse()
	{
		if ${Math.Calc[${LavishScript.RunningTime}-${This.Last_Search}]} > 2500
		{
			This:Search
			return
		}
		if ${This.RunAway}
		{
			This:Output["Oh noes! ${Object[${This.theAvoided.Get[1]}].Name}!"]
		}
	}
	
	/* perform the actual search for avoided mobs */
	method Search()
	{	
		; clear the temp avoid list
		variable int i = 1
		This.Last_Search:Set[${LavishScript.RunningTime}]
		if ${This.theAvoided.Get[${i}](exists)}
		{		
			do
			{
				if ${This.theAvoided.Get[${i}](exists)}
				{
					This.theAvoided:Remove[${i}]
				}
			}
			while ${This.theAvoided.Get[${i:Inc}](exists)}
			This.theAvoided:Collapse
		}
		
		; perform the avoid search and populate the temp avoid list
		i:Set[1]
		This.theAngry:Clear
		This.theAngry:Search[-units,-lineofsight,-alive,-nonpvp,-hostile,-nearest,-range 0-250]
		if ${This.theAngry.Count} > 0
		{
			do
			{
				if ${This.theAngry.GUID[${i}](exists)}
				{
					if ${This.AvoidList.Contains[${This.theAngry.Object[${i}].Name}]}
					{	
						This.theAvoided:Insert[${This.theAngry.GUID[${i}]}]
					}
				}
			}
			while ${This.theAngry.GUID[${i:Inc}](exists)}
		}
	}
	
	member RunAway()
	{
		variable int i = 1		
		if ${This.theAvoided.Get[${i}](exists)}
		{
			do
			{
				if ${This.theAvoided.Get[${i}](exists)}
				{
					if !${This.SafeDistance[${This.theAvoided.Get[${i}]}]}
					{
						This:Count[${This.theAvoided.Get[${i}]}]
						This.theBigMeanie:Set[${This.theAvoided.Get[${i}]}]
						Toon:Flee
						return TRUE
					}
				}
			}
			while ${This.theAvoided.Get[${i:Inc}](exists)}
		}
		return FALSE
	}
	
	member SafeDistance(string GUID)
	{
		if ${Object[${GUID}](exists)}
		{
			if ${Math.Calc[${Object[${GUID}].BoundingRadius}+${Object[${GUID}].Distance}]} < ${Math.Calc[10+${This.AggroRadius[${GUID}]}]}
			{
				return FALSE
			}
		}
		return TRUE	
	}

	member AggroRadius(string GUID)
	{
		if ${Object[${GUID}](exists)}
		{
			return ${This.MathMin[45,${This.MathMax[5,${Math.Calc[20 + (${Object[${GUID}].Level} - ${Me.Level})]}]}]}
		}
		return 0
	}
	
	method Count(string GUID)
	{
		if ${This.AvoidCount.Element.[${GUID}](exists)}
		{
			if ${Math.Calc[${LavishScript.RunningTime}-${This.LastAvoid.Element.[${GUID}]}]} > ${This.Count_Interval}
			{
				This.AvoidCount.Element.[${GUID}]:Inc
				This.LastAvoid.Element.[${GUID}]:Set[${LavishScript.RunningTime}]
				if ${This.Count_ForLocChange} >= ${This.AvoidCount.Element.[${GUID}]}
				{
					This:Output["Error: Location failing due to avoidance. Attempting Location Change"]					
					Grind:LoadBestLocationSet[TRUE]
					This.AvoidCount.Element.[${GUID}]:Set[0]					
				}
				elseif ${Math.Calc[${This.AvoidCount.Element.[${GUID}]}%${This.Count_ForHotSpotChange}]} == 0
				{
					This:Output["Error: Too many attempts avoiding mob. Iterating to next hotspot."]
					Grind:NextHotspot					
					This.AvoidCount.Element.[${GUID}]:Set[0]
				}
			}
			return
		}
		This.AvoidCount.Element.[${GUID}]:Set[0]
		This.LastAvoid.Element.[${GUID}]:Set[${LavishScript.RunningTime}]		
	}	
}

objectdef oFlee inherits cBase
{
	variable index:point3f indexx
	variable int numPoints = 0
	variable int maxPoints = 20 
	variable int Yds = 10
	variable int maxYds = 40
	variable bool RunAway = FALSE
	variable bool Avoiding = FALSE
	variable point3f AvoidFlee

	/* handler for deciding if we should keep fleeing or not */
	member NeedToRun()
	{
		if ${This.RunAway}
		{
			This.Avoiding:Set[FALSE]
			if ${Me.X} == ${This.X} && ${Me.Y} == ${This.Y} && ${Me.Z} == ${This.Z}
			{
				return FALSE
			}
			if ${Mount.IsMounted}
			{
				return FALSE
			}
			if ${Me.InCombat}
			{
				return TRUE
			}	
			if ${Avoidance.RunAway}
			{
				This:SetAvoidFlee			
				This.Avoiding:Set[TRUE]
				return TRUE
			}		
			if ${Me.Buff[Vanish](exists)} 
			{
				return TRUE
			}				
			This.RunAway:Set[FALSE]
		}
		return FALSE
	}
	
	member NearestReached()
	{
		if ${This.Avoiding}
		{
			if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.AvoidFlee.X},${This.AvoidFlee.Y},${This.AvoidFlee.Z}]} < 3
			{
				return TRUE
			}
		}
		if ${This.Distance[${This.numPoints}]} < 3 
		{
			return TRUE
		}
		return FALSE
	}
		
	/* navigates you to the closest point - whenever we get within 3 yards, we delete nearest point */
	method MoveToFlee()
	{
		if ${This.NearestReached}
		{
			This:Remove[${This.numPoints}]
			return
		}	
		if ${This.Avoiding}
		{
			if !${Navigator.MovingToPoint[${This.AvoidFlee.X},${This.AvoidFlee.Y},${This.AvoidFlee.Z}]}
			{
			Navigator:MoveToLoc[${This.AvoidFlee.X},${This.AvoidFlee.Y},${This.AvoidFlee.Z}]
			}
			return
		}
		if !${Navigator.MovingToPoint[${This.X},${This.Y},${This.Z}]}
		{
		Navigator:MoveToLoc[${This.X},${This.Y},${This.Z}]
		}
		return
	}
	
	/* a positional recorder remembers up to your last 20 points */
	method Pulse()
	{		
		if ${Me.Dead} || ${Me.Flying} || !${Me.Name(exists)}
		{
			This:ClearPoints
			return
		}
		This:Update
	}

	method Update()
	{
		variable int near
		variable int nextnear
		
		near:Set[${This.numPoints}]
		nextnear:Set[${near}-1]
		if !${This.HavePath[${near}]}
		{
			if ${This.HavePath[${nextnear}]}
			{
				This:Remove[${near}]
				return
			}
			else
			{
				This:New
				return
			}
		}
		elseif ${This.HavePath[${nextnear}]}
		{
			if ${This.Distance[${nextnear}]} < ${This.Distance[${near}]}
			{
				This:Remove[${near}]
				return
			}
		}		
	}

	member X()
	{
		if ${This.indexx.Get[${This.numPoints}](exists)}
		{
			return ${This.indexx.Get[${This.numPoints}].X}
		}
		else 
		{
			return ${Me.X}
		}
	}

	member Y()
	{
		if ${This.indexx.Get[${This.numPoints}](exists)}
		{
			return ${This.indexx.Get[${This.numPoints}].Y}
		}
		else 
		{
			return ${Me.Y}
		}
	}

	member Z()
	{
		if ${This.indexx.Get[${This.numPoints}](exists)}
		{
			return ${This.indexx.Get[${This.numPoints}].Z}
		}
		else 
		{
			return ${Me.Z}
		}
	}

	method ClearPoints()
	{
		variable int i = 1
		This.numPoints:Set[0]
		do
		{
			if ${This.indexx.Get[${i}](exists)}
			{
				This.indexx:Remove[${i}]
			}
		}
		while ${This.indexx.Get[${i:Inc}](exists)}
		This.indexx:Collapse
	}

	method New()
	{
		This.numPoints:Inc
		if ${This.numPoints} > ${This.maxPoints}
		{
			This:Remove[1]
		}
		This.indexx:Insert[${Me.Location}]
	}

	method Remove(int i)
	{
		if ${This.indexx.Get[${i}](exists)}
		{
			This.numPoints:Dec
			This.indexx:Remove[${i}]
		}
		This.indexx:Collapse
	}

	member HavePath(int i)
	{
		if ${This.indexx.Get[${i}](exists)}
		{
			if ${This.Distance[${i}]} < ${This.Yds}
			{
				return TRUE
			}		
			elseif ${This.Distance[${i}]} < ${maxYds} && !${Me.IsPathObstructed[${This.indexx.Get[${i}].X},${This.indexx.Get[${i}].Y},${This.indexx.Get[${i}].Z}]}			
			{
				return TRUE
			}
		}
		return FALSE
	}
	
	member Distance(int i)
	{
		if ${This.indexx.Get[${i}](exists)}
		{
			return ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.indexx.Get[${i}].X},${This.indexx.Get[${i}].Y},${This.indexx.Get[${i}].Z}]}
		}
		return 0
	}
	
	/* takes a look at our baddies heading and alters the flee point to get out of the way */
	method SetAvoidFlee()
	{
		variable float degrees = ${Avoidance.theBigMeanie.Heading.Degrees}	
		variable int modifier = ${Math.Calc[${Avoidance.AggroRadius[${Avoidance.theBigMeanie.GUID}]}+5]}
		
		if ${Navigator.IntersectsPath[${Avoidance.theBigMeanie.Heading.Degrees},${Avoidance.theBigMeanie.HeadingTo[${Flee.X},${Flee.Y}]}]}
		{		
			/* heading east */
			if ${degrees} > 45 && ${degrees} < 135
			{
				if ${Navigator.AvailablePath[${Me.X},${Me.Y},${Me.Z},${This.X},${Math.Calc[${This.Y}+${modifier}]},${This.Z}]}
				{
					This.AvoidFlee:Set[${This.X},${Math.Calc[${This.Y}+${modifier}]},${This.Z}]	
					return					
				}
				elseif ${Navigator.AvailablePath[${Me.X},${Me.Y},${Me.Z},${This.X},${Math.Calc[${This.Y}-${modifier}]},${This.Z}]}
				{
					This.AvoidFlee:Set[${This.X},${Math.Calc[${This.Y}-${modifier}]},${This.Z}]	
					return					
				}
			}
			/* heading south */
			if ${degrees} > 135 && ${degrees} < 225
			{
				if ${Navigator.AvailablePath[${Me.X},${Me.Y},${Me.Z},${Math.Calc[${This.X}+${modifier}]},${This.Y},${This.Z}]}
				{
					This.AvoidFlee:Set[${Math.Calc[${This.X}+${modifier}]},${This.Y},${This.Z}]	
					return					
				}
				elseif ${Navigator.AvailablePath[${Me.X},${Me.Y},${Me.Z},${Math.Calc[${This.X}-${modifier}]},${This.Y},${This.Z}]}
				{
					This.AvoidFlee:Set[${Math.Calc[${This.X}-${modifier}]},${This.Y},${This.Z}]	
					return					
				}
			}
			/* heading west */
			if ${degrees} > 225 && ${degrees} < 315
			{
				if ${Navigator.AvailablePath[${Me.X},${Me.Y},${Me.Z},${This.X},${Math.Calc[${This.Y}+${modifier}]},${This.Z}]}
				{
					This.AvoidFlee:Set[${This.X},${Math.Calc[${This.Y}+${modifier}]},${This.Z}]	
					return					
				}
				elseif ${Navigator.AvailablePath[${Me.X},${Me.Y},${Me.Z},${This.X},${Math.Calc[${This.Y}-${modifier}]},${This.Z}]}
				{
					This.AvoidFlee:Set[${This.X},${Math.Calc[${This.Y}-${modifier}]},${This.Z}]	
					return					
				}
			}
			else
			{
				/* heading north */
				if ${Navigator.AvailablePath[${Me.X},${Me.Y},${Me.Z},${Math.Calc[${This.X}+${modifier}]},${This.Y},${This.Z}]}
				{
					This.AvoidFlee:Set[${Math.Calc[${This.X}+${modifier}]},${This.Y},${This.Z}]
					return
				}
				elseif ${Navigator.AvailablePath[${Me.X},${Me.Y},${Me.Z},${Math.Calc[${This.X}-${modifier}]},${This.Y},${This.Z}]}
				{
					This.AvoidFlee:Set[${Math.Calc[${This.X}-${modifier}]},${This.Y},${This.Z}]
					return
				}
			}
		}
		This.AvoidFlee:Set[${This.X},${This.Y},${This.Z}]
	}	
}