objectdef cElevator
{
	variable objectref Current
	variable string GUID
	variable string Name
	variable float X
	variable float Y 
	variable float TZ 
	variable float BZ 
	variable float TEX
	variable float TEY
	variable float TEZ
	variable float BEX
	variable float BEY
	variable float BEZ
	
	variable float PERCISION = 1.5

	variable float getoutZ = 0
	variable float relativespeed = 0
	variable float olddistance = 1000
	variable float currentdistance = 1000
	variable bool EntryNavigated = FALSE
	variable bool active = FALSE
	
	method Initialize(string GUID, string Name, float X, float Y, float TZ, float BZ, float TEX, float TEY, float TEZ, float BEX, float BEY, float BEZ)
	{
		This.Current:Set[${GUID}]
		This.GUID:Set[${GUID}]
		This.Name:Set[${Name}]
		This.X:Set[${X}]
		This.Y:Set[${Y}]
		This.TZ:Set[${TZ}]
		This.BZ:Set[${BZ}]
		This.TEX:Set[${TEX}]
		This.TEY:Set[${TEY}]
		This.TEZ:Set[${TEZ}]
		This.BEX:Set[${BEX}]
		This.BEY:Set[${BEY}]
		This.BEZ:Set[${BEZ}]
		This.getoutZ:Set[0]
		This:Update
	}
	
	member GetPercision()
	{
		return ${This.PERCISION}
	}
	
	member AlmostSame(float a, float b)
	{
		variable float d = ${Math.Calc[${a}- ${b}]}
		if ${d} < 0.1 && ${d} > -0.1
		{
			return TRUE
		}
		else
		{
			return FALSE
		}
	} 
	
	method Update()
	{
		This.currentdistance:Set[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.X},${This.Y},${Me.Z}]}]
		if ${This.currentdistance} != ${This.olddistance}
		{
			This.relativespeed:Set[${Math.Calc[(${This.currentdistance} - ${This.olddistance}) * 0.5 + ${This.relativespeed} * 0.5]}]
			This.olddistance:Set[${This.currentdistance}]
		}
	}
	
	method Pulse()
	{
		This:Update
		This.active:Set[TRUE]
		if ${This.getoutZ} == 0
		{
			if ${Navigator.OpenNavPath.Get[1](exists)}
			{
				if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.BEX},${This.BEY},${This.BEZ}]} < 10 && ${This.relativespeed} < 0
				{
					if ${This.AlmostSame[${Current.Z}, ${This.BZ}]} && ${This.EntryNavigated}
					{
						if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.X},${This.Y},${Me.Z}]} > ${This.GetPercision}
						{
							ClickMoveToLoc ${This.X} ${This.Y} ${Me.Z}
							;Navigator:FaceXYZ[${This.X},${This.Y},${Me.Z}]
							;Navigator:MoveForward
							echo Running to Elevator Bottom Plattform
						}
						else
						{
							move -stop
							This.getoutZ:Set[${This.TZ}]
							echo Arrived at Elevator Bottom Plattform
						}
					}
					else
					{
						if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.BEX},${This.BEY},${This.BEZ}]} > ${This.GetPercision}
						{
							ClickMoveToLoc ${This.BEX} ${This.BEY} ${This.BEZ}
							;Navigator:FaceXYZ[${This.BEX},${This.BEY},${This.BEZ}]
							;Navigator:MoveForward
							echo Running to Elevator Bottom Entry
						}
						else
						{
							if !${This.AlmostSame[${Current.Z}, ${This.BZ}]}
							{
								move -stop
							}
							echo Arrived at Elevator Bottom Entry
							This.EntryNavigated:Set[TRUE]
						}
					}
				}
				else
				{
					if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.TEX},${This.TEY},${This.TEZ}]} < 10 && ${This.relativespeed} < 0
					{
						if ${This.AlmostSame[${Current.Z}, ${This.TZ}]} && ${This.EntryNavigated}
						{
							if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.X},${This.Y},${Me.Z}]} > ${This.GetPercision}
							{
								ClickMoveToLoc ${This.X} ${This.Y} ${Me.Z}
								;Navigator:FaceXYZ[${This.X},${This.Y},${Me.Z}]
								;Navigator:MoveForward
								echo Running to Elevator Top Plattform
							}
							else
							{
								move -stop
								This.getoutZ:Set[${This.BZ}]
								echo Arrived at Elevator Top Plattform
							}
						}
						else
						{
							if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.TEX},${This.TEY},${This.TEZ}]} > ${This.GetPercision}
							{
								ClickMoveToLoc ${This.TEX} ${This.TEY} ${This.TEZ}
								;Navigator:FaceXYZ[${This.TEX},${This.TEY},${This.TEZ}]
								;Navigator:MoveForward
								echo Running to Elevator Top Entry
							}
							else
							{
								if !${This.AlmostSame[${Current.Z}, ${This.TZ}]} 
								{
									move -stop
								}
								echo Arrived at Elevator Top Entry
								This.EntryNavigated:Set[TRUE]
							}
						}
					}
					else
					{
						This.active:Set[FALSE]
					}
				}						
			}
			else
			{
				This.active:Set[FALSE]
			}
		}
		else
		{
			if ${This.AlmostSame[${Current.Z}, ${This.getoutZ}]}
			{
				if ${This.AlmostSame[${Current.Z}, ${This.TZ}]}
				{
					if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.TEX},${This.TEY},${This.TEZ}]} > ${This.GetPercision}
					{
						ClickMoveToLoc ${This.TEX} ${This.TEY} ${This.TEZ}
						;Navigator:FaceXYZ[${This.TEX},${This.TEY},${This.TEZ}]
						;Navigator:MoveForward
						echo Running to Elevator Top Exit
					}
					else
					{
						Navigator:ClearPath
						echo Arrived at Elevator Top Exit
						This.active:Set[FALSE]
						This.getoutZ:Set[0]
						This.EntryNavigated:Set[FALSE]
					}
				}
				else
				{
					if ${This.AlmostSame[${Current.Z}, ${This.BZ}]} 
					{
						if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.BEX},${This.BEY},${This.BEZ}]} > ${This.GetPercision}
						{
							ClickMoveToLoc ${This.BEX} ${This.BEY} ${This.BEY}
							;Navigator:FaceXYZ[${This.BEX},${This.BEY},${This.BEY}]
							;Navigator:MoveForward
							echo Running to Elevator Top Exit
						}
						else
						{
							Navigator:ClearPath
							echo Arrived at Elevator Bottom Exit
							This.active:Set[FALSE]
							This.getoutZ:Set[0]
							This.EntryNavigated:Set[FALSE]
						}
					}
					else
					{
						move -stop
						echo The thing that should Not be, we are caged in the elevator
					}
				}
			}
			else
			{
				move -stop
				Navigator:ClearPath
				echo Driving in Elevator
			}
		}
	}
}

objectdef oOpenNavPath
{
	variable point3f Location
	variable int Method

	method Initialize(float X, float Y, float Z, int MoveType)
	{
		This.Location.X:Set[${X}]
		This.Location.Y:Set[${Y}]
		This.Location.Z:Set[${Z}]
		This.Method:Set[${MoveType}]
	}
}

objectdef oNavigator inherits cBase
{
	variable index:oOpenNavPath OpenNavPath
	variable index:oElevator Elevator
	variable point3f NavDestination
	variable int StuckTime = ${LavishScript.RunningTime}
	variable float PERCISION = 1.5
	variable bool StartMove = FALSE
	variable bool StuckJump = FALSE
	variable int TotalStuck = 0
	variable int IPOSTUCK = 0
	variable int SKIPNAV = 0
	variable bool ForceRes = FALSE
	variable int ResSpot = 0
	variable bool FRTimerStarted = FALSE
	variable int ForceResTimer = ${LavishScript.RunningTime}
	variable string vCurrentDestination = ""
	variable int degrees
	variable int yards
	variable point3f BestPoint
	variable float BestPointDistance
	variable string POIStr = ""
	variable oStuck GlobalStuck
	variable int SumStuck = 0
	variable point3f BestRezLoc = ${Me.Location}
	variable float BestRezLoc_SafetyMargin = 0
	
	variable int NAV_Wait_Until = 0
	variable int NAV_Wait_Until_Timeout = 10

	variable bool NeedDismount = FALSE
	
	member CurrentDestination = ${vCurrentDestination}

	method Initialize()
	{
		Navigator.NavDestination.X:Set[0]
		Navigator.NavDestination.Y:Set[0]
		Navigator.NavDestination.Z:Set[0]
		degrees:Set[15]
		yards:Set[10]
		
		LavishSettings:AddSet[Elevator]
		LavishSettings[Elevator]:Import["config/elevator.xml"]
		LavishSettings[Elevator]:AddSet[Elevator]
		LavishSettings[Elevator].FindSet[Elevator]:AddSetting[TEST,1]
	}

	method Shutdown()
	{
		LavishSettings[Elevator]:Export["config/elevator.xml"]
	}
	
	method TransportMapped(string GUID, float X, float Y, float TZ, float BZ, float TEX, float TEY, float TEZ, float BEX, float BEY, float BEZ)
	{
		variable objectref o=${GUID}
		
		LavishSettings[Elevator].FindSet[Elevator]:AddSet["${o.Name}@${X}~${Y}"]
		LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${X}~${Y}"]:AddSetting[Name,${o.Name}]
		LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${X}~${Y}"]:AddSetting[X,${X}]
		LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${X}~${Y}"]:AddSetting[Y,${Y}]
		LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${X}~${Y}"]:AddSetting[TZ,${TZ}]
		LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${X}~${Y}"]:AddSetting[BZ,${BZ}]
		LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${X}~${Y}"]:AddSetting[TEX,${TEX}]
		LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${X}~${Y}"]:AddSetting[TEY,${TEY}]
		LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${X}~${Y}"]:AddSetting[TEZ,${TEZ}]
		LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${X}~${Y}"]:AddSetting[BEX,${BEX}]
		LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${X}~${Y}"]:AddSetting[BEY,${BEY}]
		LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${X}~${Y}"]:AddSetting[BEZ,${BEZ}]
						
		This:Output[Transport mapped and saved: ${o.Name}@${X}~${Y}]
		This:Output[X: ${X}]
		This:Output[Y: ${Y}]
		This:Output[TZ: ${TZ}]
		This:Output[BZ: ${BZ}]
		This:Output[TEX: ${TEX}]
		This:Output[TEY: ${TEY}]
		This:Output[TEZ: ${TEZ}]
		This:Output[BEX: ${BEX}]
		This:Output[BEY: ${BEY}]
		This:Output[BEZ: ${BEZ}]
	
		This:TransportAdded[${GUID}]
	}
	
	method TransportAdded(string GUID)
	{
		variable objectref o=${GUID}
		if ${LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${o.X}~${o.Y}"].FindSetting[Name](exists)}
		{
			variable int Index = 0
			variable bool FOUND = FALSE
			while !${FOUND} && ${This.Elevator.Get[${Index:Inc}](exists)}
			{
				if ${This.Elevator.Get[${Index}].Name.Equal[${o.Name}]} && ${This.Elevator.Get[${Index}].X} == ${o.X} && ${This.Elevator.Get[${Index}].Y} == ${o.Y}
				{
					echo Outdated Transport removed: ${This.Elevator.Get[${Index}].Name} ${This.Elevator.Get[${Index}].GUID}
					Navigator.Elevator:Remove[${Index}]
					Navigator.Elevator:Collapse
					FOUND:Set[TRUE]
				}
			}
			echo Valid mapped Transport recognized and added: ${o.Name} ${o.GUID}
			This.Elevator:Insert[${o.GUID}, ${o.Name}, ${LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${o.X}~${o.Y}"].FindSetting[X]}, ${LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${o.X}~${o.Y}"].FindSetting[Y]}, ${LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${o.X}~${o.Y}"].FindSetting[TZ]}, ${LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${o.X}~${o.Y}"].FindSetting[BZ]}, ${LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${o.X}~${o.Y}"].FindSetting[TEX]}, ${LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${o.X}~${o.Y}"].FindSetting[TEY]}, ${LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${o.X}~${o.Y}"].FindSetting[TEZ]}, ${LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${o.X}~${o.Y}"].FindSetting[BEX]}, ${LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${o.X}~${o.Y}"].FindSetting[BEY]}, ${LavishSettings[Elevator].FindSet[Elevator].FindSet["${o.Name}@${o.X}~${o.Y}"].FindSetting[BEZ]}]
		}
	}
	
	method SetPercision(int NUM)
	{
		This:Output["Setting Navigation Percision to ${NUM}"]
		PERCISION:Set[${NUM}]
	}

	member GetPercision()
	{
		return ${This.PERCISION}
	}
	method ClearPath()
	{
		Navigator.NavDestination.X:Set[0]
		Navigator.NavDestination.Y:Set[0]
		Navigator.NavDestination.Z:Set[0]
		OpenNavPath:Collapse
		if ${OpenNavPath.Get[1](exists)}
		{
			do
			{
				OpenNavPath:Remove[1]
				OpenNavPath:Collapse
			}
			while ${OpenNavPath.Get[1](exists)}
		}
		This.POIStr:Set[""]
		This.StartMove:Set[FALSE]
	}

	member AvailablePath(float X,float Y,float Z)
	{
		variable greynavpath PathHops
		variable int Index = 0
		
		if ${X}==0 && ${Y}==0 && ${Z}==0
		{
			return FALSE
		}
		
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} < 40 && !${Me.IsPathObstructed[${X},${Y},${Z}]}
		{
			if !${Mapper.Topography.IsSteep[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}
			{
			return TRUE
			}
		}
		PathHops:Clear
		GreyNav:CalculatePath[${Map.ID}, ${Me.X}, ${Me.Y}, ${Me.Z}, ${X}, ${Y}, ${Z}, PathHops]
		if ${PathHops.Count} > 0
		{
			return TRUE
		}
		else
		{
			return FALSE
		}
	}

	/* used as part of flight path nav */
	member PointsConnect(float toX, float toY, float toZ, float fromX, float fromY, float fromZ)
	{
		variable astarpathfinder PathFinder
		variable lnavpath Path
		variable lnavregionref ToRegion
		variable lnavregionref ZoneRegion
		variable lnavregionref DestZoneRegion
		variable lnavregionref DestinationRegion
		
		if (${toX}==0 && ${toY}==0 && ${toZ}==0) || (${fromX}==0 && ${fromY}==0 && ${fromZ}==0) 
		{
			return FALSE
		}
		
		Path:Clear
		ZoneRegion:SetRegion[${LavishNav.FindRegion[${Navigator.BestZone[${toX},${toY},${Math.Calc[${toZ}+1]}]}].FQN}]
		DestZoneRegion:SetRegion[${LavishNav.FindRegion[${Navigator.BestZone[${fromX},${fromY},${Math.Calc[${fromZ}+1]}]}].FQN}]
		ToRegion:SetRegion[${DestZoneRegion.BestContainer[${toX},${toY},${Math.Calc[${toZ}+1]}].ID}]
		DestinationRegion:SetRegion[${DestZoneRegion.BestContainer[${fromX},${fromY},${Math.Calc[${fromZ}+1]}].ID}]
		PathFinder:SelectPath[${ToRegion.FQN},${DestinationRegion.FQN},Path]
		if ${Path.Hops}
		{
			return TRUE
		}
		else
		{
			return FALSE
		}
	}	
	
	method MoveTo(float X, float Y, float Z)
	{
		;why are we running somewhere if we are right there?
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} < ${This.GetPercision}
		{
			return
		}
	}

	method MoveToLocQ(float X, float Y, float Z,string DestName = "")
	{
		This.vCurrentDestination:Set[${DestName}]
		This:MoveToLoc[${X},${Y},${Z}]
	}

	method MoveToCurrentPOI()
	{
		POI:RefreshXYZ
		This:MoveToLoc[${POI.X},${POI.Y},${POI.Z}]
		This.POIStr:Set[${POI.Str}]
	}

	member IsMovingToCurrentPOI()
	{
		if ${This.POIStr.Equal[${POI.Str}]}
		{
			if ${Movement.Speed}
			{
				return TRUE
			}
		}
		return FALSE
	}

	/* we use MinMelee instead of percision - also allows for spamming the calls*/
	method MoveToMob(string GUID)
	{
		variable float mobDistance
		variable objectref theMob = ${GUID}
		variable int moveDirectly = ${Toon.PullRange}
		
		mobDistance:Set[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${theMob.X},${theMob.Y},${theMob.Z}]}]		
		Navigator:FaceXYZ[${theMob.X},${theMob.Y},${theMob.Z}]

		if ${moveDirectly} < 40
		{
			moveDirectly:Set[40]
		}
		
		if ${mobDistance} < ${Toon.MinMelee}
		{
			Navigator:ClearPath
			if ${Movement.Speed}
			{
				move -stop
			}
			return
		}
			
		if ${mobDistance} < ${moveDirectly} && !${Me.IsPathObstructed[${theMob.X},${theMob.Y},${Math.Calc[${theMob.Z}+0.6]}]}
		{
			Navigator:MoveForward
			return
		}
		elseif !${Navigator.MovingToPoint[${theMob.X},${theMob.Y},${theMob.Z}]} 
		{
			Navigator:MoveToLoc[${theMob.X},${theMob.Y},${theMob.Z}]
		}		
	}
	
	/* useful for preventing excess MoveToLoc calls */
	member MovingToPoint(float X, float Y, float Z)
	{
		variable int count = 0
		if ${Movement.Speed}
		{
			if ${Navigator.OpenNavPath.Get[1](exists)}
			{		
				do
				{
					count:Inc
				}
				while ${Navigator.OpenNavPath.Get[${Math.Calc[${count}+1]}](exists)}			
				if ${Navigator.OpenNavPath.Get[${count}].Location.X}==${X} && ${Navigator.OpenNavPath.Get[${count}].Location.Y}==${Y} && ${Navigator.OpenNavPath.Get[${count}].Location.Z}==${Z}
				{
					return TRUE
				}
			}
		}
		return FALSE
	}	
	
	method MoveToLoc(float X, float Y, float Z, int OVERRIDE=0)
	{
		variable greynavpath PathHops
		variable int count = 0
		variable int Index = 0
		variable point3f RecoveryHop
		variable float Xper=${Math.Distance[${Navigator.OpenNavPath.Get[${count}].Location.X}, ${X}]}
		variable float Yper=${Math.Distance[${Navigator.OpenNavPath.Get[${count}].Location.Y}, ${Y}]}

		if ${X}==0 && ${Y}==0 && ${Z}==0
		{
			; No reason to run to NOTHING
			return
		}

		; If we are already Percision from it why bother moving?
		; Changed... Default Percision is slightly greater then USE distance
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}<${This.GetPercision} && ${POI.Type.Equal[HOTSPOT]}
		{
			This:Output["Already here: Not moving"]
			POI:RefreshXYZ
			Navigator:ClearPath
			move -stop
			Grind:NextHotspot
			return
		}
		; Added. Check for POIs that we are probably wanting to use
		; This is to help eliminate issues between client, server information disconnects. such as using an NPC
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]}< 2
		{
			This:Output["Already here: Not moving"]
			POI:RefreshXYZ
			Navigator:ClearPath
			move -stop
			return
		}
		
		;Checks to see if it would be faster to teleport
		if ${Teleport.Closer[${X},${Y},${Z}]}
		{
			Teleport:PortToLoc
			return
		}
		
		;If we already have a Path make sure it is a new one
		if ${Navigator.OpenNavPath.Get[1](exists)}
		{		
			do
			{
				count:Inc
			}
			while ${Navigator.OpenNavPath.Get[${Math.Calc[${count}+1]}](exists)}
			
			;if ${Math.Distance[${Navigator.OpenNavPath.Get[${count}].Location.X}, ${X}]} < 0.25 && ${Math.Distance[${Navigator.OpenNavPath.Get[${count}].Location.Y}, ${Y}]} < 0.25 && ${Math.Distance[${Navigator.OpenNavPath.Get[${count}].Location.Z}, ${Z}]} < 1.0
		echo "${Xper} ${Yper} ${PERCISION}"
		if ${Math.Calc[${Xper}+${Yper}]}< ${PERCISION}&&${Math.Distance[${Navigator.OpenNavPath.Get[${count}].Location.Z}, ${Z}]} < 1.0
			{
				This:Output["ERROR: Calling again to same destination! Aborting"]
				return
			}
		}

		Navigator:ClearPath

		This.StartMove:Set[TRUE]
		This:Debug["Clearing #3"]
		This.StuckTime:Set[${LavishScript.RunningTime}]

		if ${OVERRIDE}!=0
		{
			This:Output["NAV OVERRIDING: Using PATH!"]
		}
		{
			PathHops:Clear

			GreyNav:CalculatePath[${Map.ID}, ${Me.X}, ${Me.Y}, ${Me.Z}, ${X}, ${Y}, ${Z}, PathHops]

			if ${PathHops.Count} > 0
			{
				do
				{
					;echo Adding ${PathHops.Hop[${Index}].X}, ${PathHops.Hop[${Index}].Y}, ${PathHops.Hop[${Index}].Z}
					This.OpenNavPath:Insert[${PathHops.Hop[${Index}].X}, ${PathHops.Hop[${Index}].Y}, ${PathHops.Hop[${Index}].Z}, 0]
				}
				while ${Index:Inc} < ${PathHops.Count}
				Navigator.NavDestination.X:Set[${X}]
				Navigator.NavDestination.Y:Set[${Y}]
				Navigator.NavDestination.Z:Set[${Z}]
			}
			else
			{
				; We didnt get a path run to the next closest point and try from there
				This:Output["Greynav failure, we have stepped outside the mesh!"]
				
;ClickMoveToLoc ${Math.Calc[${Me.X}+1]} ${Me.Y} ${Me.Z}

				POI:Clear

				RecoveryHop.X:Set[0]
				RecoveryHop.Y:Set[0]
				RecoveryHop.Z:Set[0]
				GreyNav:GetNearestValidXYZ[${Map.ID}, ${Me.X}, ${Me.Y}, ${Me.Z}, RecoveryHop]

				if ${RecoveryHop.X} == 0 && ${RecoveryHop.Y} == 0 && ${RecoveryHop.Z} == 0
				{
					This:Output["Couldn't find nearest valid point, now we're really screwed!"]
					move -stop
				}
				elseif ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${RecoveryHop.X},${RecoveryHop.Y},${RecoveryHop.Z}]} > 40 || ${Me.IsPathObstructed[${RecoveryHop.X},${RecoveryHop.Y},${RecoveryHop.Z}]}
				{
					This:Output["Nearest valid point is obstructed, now we're really screwed!"]
					move -stop
				}
				else
				{
					This:Output["Attempting recovery hop to location: ${RecoveryHop}"]

					Navigator.NavDestination.X:Set[${RecoveryHop.X}]
					Navigator.NavDestination.Y:Set[${RecoveryHop.Y}]
					Navigator.NavDestination.Z:Set[${RecoveryHop.Z}]
				}

			
			}
		}
	}

	member BestZone(float X, float Y, float Z)
	{
		;${LavishNav.BestContainer[${Me.Location}].Type}
		variable string Continent
		variable int INDEX_Continent
		variable string Zone
		variable int INDEX_Zone
		variable lnavregionref ZoneRegion
		variable lnavregionref DestRegion

		;Add in a default Intance as a catch all for any zone we dont know about
		ZoneRegion:SetRegion[${LavishNav.FindRegion[Instance].FQN}]
		
		variable iterator InstanceIterator
		; Save Instance Files
		
		LavishSettings[Instances]:GetSettingIterator[InstanceIterator]
		if ${InstanceIterator:First(exists)}
		{
			do
			{
				if ${LavishNav.FindRegion[Instance].FindRegion[${InstanceIterator.Key}](exists)}
				{
					if !${LavishNav.FindRegion[Instance].FindRegion[${InstanceIterator.Key}].BestContainer[${X},${Y},${Z}].Type.Equal[Universe]}
					{
						return ${InstanceIterator.Key}
					}
				}	
				
			}
			while ${InstanceIterator:Next(exists)}
		}
		
		INDEX_Continent:Set[1]
		do
		{
			Continent:Set[${WoWScript[GetMapContinents(),${INDEX_Continent}]}]
			INDEX_Zone:Set[1]
			do
			{
				Zone:Set[${WoWScript[GetMapZones(${INDEX_Continent}),${INDEX_Zone}]}]
				ZoneRegion:SetRegion[${LavishNav.FindRegion[${Zone}].FQN}]
				if !${ZoneRegion.BestContainer[${X},${Y},${Z}].Type.Equal[Universe]}
				{
					return ${Zone}
				}
				INDEX_Zone:Inc
			}
			while ${WoWScript[GetMapZones(${INDEX_Continent}),${INDEX_Zone}](exists)}
			INDEX_Continent:Inc
		}
		while ${WoWScript[GetMapContinents(),${INDEX_Continent}](exists)}
		return "Instance"
	}

	;----------
	;----- Obstacle avoidance
	;----------	
	
	/* if we are moving and in the same spot for more than 4 seconds, then normal IPO and Stuck Check failed */
	variable int LastGlobalStuck = ${LavishScript.RunningTime}
	method GlobalUnstuck()
	{
		if ${Movement.Stuck_IgnoreJumps}
		{
			This.LastGlobalStuck:Set[${LavishScript.RunningTime}]
			if ${GlobalStuck.Elapsed} > 6.4
			{
				GlobalStuck:HouseOfPain
			}
		}
		elseif ${Math.Calc[${LavishScript.RunningTime}-${This.LastGlobalStuck}]} > 15000
		{
			POI.StuckCount:Set[0]	
			GlobalStuck:ResetStart
		}
	}		
	
	member IsStuck(int TEMP=1)
	{
		variable float Xstagea
		variable float Xstageb
		variable float Xstagec
		variable float Ystagea
		variable float Ystageb
		variable float Ystagec
		variable float X2stagea
		variable float X2stageb
		variable float X2stagec
		variable float Y2stagea
		variable float Y2stageb
		variable float Y2stagec
		variable float X3stagea
		variable float X3stageb
		variable float X3stagec
		variable float Y3stagea
		variable float Y3stageb
		variable float Y3stagec
		variable float HeadingTemp
		variable float HeadingTemp2
		variable int StuckCheck

		/* 5 yards */
		Xstagea:Set[]
		Xstageb:Set[]
		Xstagec:Set[${Math.Calc[${Me.X}+${Math.Calc[3*${Math.Cos[${Me.Heading}]}]}]}]

		Ystagea:Set[${Math.Sin[${Me.Heading}]}]
		Ystageb:Set[${Math.Calc[5*${Math.Sin[${Me.Heading}]}]}]
		Ystagec:Set[${Math.Calc[${Me.Y}-${Math.Calc[5*${Math.Sin[${Me.Heading}]}]}]}]

		/*      LEFT     */
		HeadingTemp2:Set[${Math.Calc[${Me.Heading}-90]}]
		if ${HeadingTemp2} < 0
		{
			HeadingTemp:Set[${Math.Calc[${HeadingTemp2} + 360]}]
		}
		else
		{
			HeadingTemp:Set[${HeadingTemp2}]
		}


		X2stagea:Set[${Math.Cos[${HeadingTemp}]}]
		X2stageb:Set[${Math.Calc[2*${X2stagea}]}]
		X2stagec:Set[${Math.Calc[${Xstagec}+${X2stageb}]}]

		Y2stagea:Set[${Math.Sin[${HeadingTemp}]}]
		Y2stageb:Set[${Math.Calc[2*${Y2stagea}]}]
		Y2stagec:Set[${Math.Calc[${Ystagec}-${Y2stageb}]}]

		/*       Right      */
		HeadingTemp2:Set[${Math.Calc[${Me.Heading}+90]}]
		if ${HeadingTemp2} > 360
		{
			HeadingTemp:Set[${Math.Calc[${HeadingTemp2} - 360]}]
		}
		else
		{
			HeadingTemp:Set[${HeadingTemp2}]
		}

		X3stagea:Set[${Math.Cos[${HeadingTemp}]}]
		X3stageb:Set[${Math.Calc[2*${X3stagea}]}]
		X3stagec:Set[${Math.Calc[${Xstagec}+${X3stageb}]}]

		Y3stagea:Set[${Math.Sin[${HeadingTemp}]}]
		Y3stageb:Set[${Math.Calc[2*${Y3stagea}]}]
		Y3stagec:Set[${Math.Calc[${Ystagec}-${Y3stageb}]}]



		StuckCheck:Set[0]
		if ${Me.IsPathObstructed[${Xstagec},${Ystagec},${Math.Calc[${Me.Z} + 1]},10]}
		{
			;Collision straight ahead of us
			StuckCheck:Inc
		}

		if ${Me.IsPathObstructed[${X2stagec},${Y2stagec},${Math.Calc[${Me.Z} + 1]},10,${Me.X},${Me.Y},${Math.Calc[${Me.Z} + 1]}]}
		{
			;Collision slightly to the left of us
			StuckCheck:Inc[2]
		}

		if ${Me.IsPathObstructed[${X3stagec},${Y3stagec},${Math.Calc[${Me.Z} + 1]},10,${Me.X},${Me.Y},${Math.Calc[${Me.Z} + 1]}]}
		{
			;Collision slightly to the right of us
			StuckCheck:Inc[4]
		}

		return ${StuckCheck}
	}

	method AvoidObstacle()
	{
		variable int count = 0
		
		This:Output["Stuck!"]
		This.TotalStuck:Inc
		This.SumStuck:Inc

		; If we are stuck lets try jumping first
		if !${This.StuckJump}
		{
			This.StuckJump:Set[TRUE]
			wowpress JUMP
			This.StartMove:Set[FALSE]
			return
		}
		else
		{
			This:Output["We should be doing some hoho magic shit here"]
			This:Output["STUCK: Adding Weight to next hop!"]
			;Recalculate path after reweighting
			do
			{
				count:Inc
			}
			while ${Navigator.OpenNavPath.Get[${Math.Calc[${count}+1]}](exists)}
			
			This:Output["STUCK: Recalculating Path to ${Navigator.OpenNavPath.Get[1].Location.X},${Navigator.OpenNavPath.Get[1].Location.Y},${Navigator.OpenNavPath.Get[1].Location.Z}"]
			Navigator:ClearPath
			This:MoveToLoc[${Navigator.OpenNavPath.Get[${count}].Location.X},${Navigator.OpenNavPath.Get[${count}].Location.Y},${Navigator.OpenNavPath.Get[${count}].Location.Z},1]
			;Yaxa's hoho magic shit
			;This:FaceXYZ[${Navigator.OpenNavPath.Get[1].Location.X},${Navigator.OpenNavPath.Get[1].Location.Y},${Navigator.OpenNavPath.Get[1].Location.Z}]
			;Move Forward 500
			;This:MoveTo[${Navigator.OpenNavPath.Get[1].Location.X},${Navigator.OpenNavPath.Get[1].Location.Y},${Navigator.OpenNavPath.Get[1].Location.Z}]

		}
		; We tried jumping and are still stuck try something else
	}

	method AddWeight(float SrcX, float SrcY, float SrcZ, float DestX, float DestY, float DestZ, int Weight=10)
	{
		variable astarpathfinder PathFinder
		variable lnavpath Path
		variable lnavregionref CurrentRegion
		variable lnavregionref ZoneRegion
		variable lnavregionref DestZoneRegion
		variable lnavregionref DestinationRegion
		;variable index:lnavregionref SurroundingRegions

		if ${SrcX}==0 && ${SrcY}==0 && ${SrcZ}==0
		{
			This:Debug["Attempt to add weight to path SRC Invalid"]
			return
		}

		if ${DestX}==0 && ${DestY}==0 && ${DestZ}==0
		{
			This:Debug["Attempt to add weight to path DEST Invalid"]
			return
		}

		; Make sure we are starting with a fresh path
		Path:Clear

		ZoneRegion:SetRegion[${LNavRegion[${Mapper.ZoneText}].FQN}]
		DestZoneRegion:SetRegion[${LavishNav.FindRegion[${This.BestZone[${DestX},${DestY},${Math.Calc[${DestZ}+1]}]}].FQN}]

		CurrentRegion:SetRegion[${ZoneRegion.BestContainer[${SrcX},${SrcY},${SrcZ}].ID}]

		DestinationRegion:SetRegion[${DestZoneRegion.BestContainer[${DestX},${DestY},${Math.Calc[${DestZ}+1]}].ID}]

		if ${CurrentRegion.ID}==${DestinationRegion.ID}
		{
			This:Debug["ERROR: Attempt to weight path SRC/DEST Region are the same!"]
			return
		}

		PathFinder:SelectPath[${CurrentRegion.FQN},${DestinationRegion.FQN},Path]

		if ${Path.Hops}
		{
			Path.Connection[1]:SetDistance[${Math.Calc[${Path.Connection[1].Distance}+${Weight}]}]
			This:Output["Weighted ${Path.Connection[1]} to now be ${Path.Connection[1].Distance}"]
			return
		}
		else
		{
			; We didnt get a path run to the next closest point and try from there
			This:Output["ERROR: Cant not find path to weight, Not enough Mapping data! ${X},${Y},${Z}"]
			This:Debug["From: ${CurrentRegion.FQN} to ${DestinationRegion.FQN}"]
		}
	}

	method Pulse()
	{

		;Only do every nth frame (CPU Saver)
		if ${SKIPNAV} < 1
		{
			SKIPNAV:Inc
			return
		}
		SKIPNAV:Set[0]
		
		variable int Index = 0
		variable bool TempNeedDismount = FALSE
		while ${Navigator.Elevator.Get[${Index:Inc}](exists)}
		{
			if !${This.Elevator.Get[${Index}].Current.Name(exists)}
			{
				echo Removing invalid Transport: ${This.Elevator.Get[${Index}].Name} ${This.Elevator.Get[${Index}].GUID}
				Navigator.Elevator:Remove[${Index}]
				Navigator.Elevator:Collapse
			}
			else
			{
				Navigator.Elevator.Get[${Index}]:Pulse
				if ${Navigator.Elevator.Get[${Index}].currentdistance} < 50 
				{
					Mount:Dismount
					TempNeedDismount:Set[TRUE]
				}
				if ${Navigator.Elevator.Get[${Index}].active}
				{
					return
				}
			}
		}
		This.NeedDismount:Set[${TempNeedDismount}]

		if ${OpenNavPath.Get[1](exists)}
		{
			IPOSTUCK:Inc
			if ${IPOSTUCK}>5 && !${ISXWoW.Facing}
			{
				IPOSTUCK:Set[1]
				switch ${This.IsStuck}
				{
					case 0
						;This:Output["All Clear"]
					break
					case 1
						This:Output["Ahead"]
						wowpress JUMP
						if ${Math.Rand[100]}>50
						{
							move right 100
						}
						else
						{
							move left 100
						}
					break
					case 2
						This:Output["Left"]
						move right 100
					break
					case 3
						This:Output["Left and Ahead"]
						move right 100
					break
					case 4
						This:Output["Right"]
						move left 100
					break
					case 5
						This:Output["Ahead and Right"]
						move left 100
					break
					case 6
						This:Output["Left and Right"]
					break
					case 7
						This:Output["All Parts"]
					break
				}
			}					
			
			if ${Math.Calc[${LavishScript.RunningTime}-${This.StuckTime}]}>28000
			{
				This:AvoidObstacle
				This.StuckTime:Set[${LavishScript.RunningTime}]
			}
			
			if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${Navigator.OpenNavPath.Get[1].Location.X},${Navigator.OpenNavPath.Get[1].Location.Y},${Navigator.OpenNavPath.Get[1].Location.Z}]} < ${This.GetPercision}
			{
				OpenNavPath:Remove[1]
				OpenNavPath:Collapse
				This.StartMove:Set[FALSE]
				
				if !${OpenNavPath.Get[1](exists)}
				{
					if ${Movement.Speed} 
					{
						move -stop
					}
					This.POIStr:Set[""]
					return
				}
	
				;If we have 2 hops and next hop is < 10 and we can get to the 2nd hop just go there
				if ${Navigator.OpenNavPath.Get[2](exists)} && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${Navigator.OpenNavPath.Get[1].Location.X},${Navigator.OpenNavPath.Get[1].Location.Y},${Navigator.OpenNavPath.Get[1].Location.Z}]} < 10
				{
					if !${Me.IsPathObstructed[${Navigator.OpenNavPath.Get[2].Location.X},${Navigator.OpenNavPath.Get[2].Location.Y},${Navigator.OpenNavPath.Get[2].Location.Z}]}
					{
						OpenNavPath:Remove[1]
						OpenNavPath:Collapse
					}
				}
			}

			if !${StartMove}
			{
				This.StartMove:Set[TRUE]
				This.StuckTime:Set[${LavishScript.RunningTime}]
			}
			This.TotalStuck:Set[0]
			ClickMoveToLoc ${Navigator.OpenNavPath.Get[1].Location.X} ${Navigator.OpenNavPath.Get[1].Location.Y} ${Navigator.OpenNavPath.Get[1].Location.Z}
			;This:FaceXYZ[${Navigator.OpenNavPath.Get[1].Location.X},${Navigator.OpenNavPath.Get[1].Location.Y},${Navigator.OpenNavPath.Get[1].Location.Z}]
			;This:MoveForward
			Bot:Update_Status["Running"]
		}
	}

	;----------
	;----- Safe Spot originated by Plecks
	;----------
	
	member SafeToRes()
	{
		if ${Math.Distance[${Me.Location},${Me.Corpse}]} > 40
		{
			return FALSE
		}
		if !${This.PointIsSafe[${Me.Location}]} && !${ForceRes}
		{
			if !${FRTimerStarted}
			{
				ForceResTimer:Set[${LavishScript.RunningTime}]
				FRTimerStarted:Set[TRUE]
			}
			if ${Math.Calc[${LavishScript.RunningTime} - ${ForceResTimer}]} > 30000
			{
				FRTimerStarted:Set[FALSE]
				ForceRes:Set[TRUE]
			}
 			This:Output[Cant res: bad guy too close.  Force Rez in ${Int[${Math.Calc[(30000-(${LavishScript.RunningTime} - ${ForceResTimer}))/1000]}]} seconds.]
			return FALSE
		}
		if ${ForceRes}
		{
			This:Output[KAMIKAZEE!!! RESURRECTION FORCED]
		}
		This:Output[We can res here]
		Navigator:ClearPath
		move -stop
		return TRUE
	}
	
	member FindSafeSpot()
	{	
		variable point3f point
		variable float MobDistance		
		variable int i
		variable int j
		
		if ${Math.Distance[${This.BestRezLoc.X},${This.BestRezLoc.Y},${This.BestRezLoc.Z},${Me.Corpse.X},${Me.Corpse.Y},${Me.Corpse.Z}]} < ${maxyds}
		{
			if ${Navigator.AvailablePath[${This.BestRezLoc}]} && ${This.PointIsSafe[${This.BestRezLoc}]}
			{
			return ${This.BestRezLoc}
			}
		}
		This.BestRezLoc:Set[${Me.Corpse}]
		This.BestRezLoc_SafetyMargin:Set[0]
		
		for (i:Set[0] ; ${i} < 360 ; i:Inc[${degrees}])
		{
			for (j:Set[0]; ${j} < 40 ; j:Inc[${yards}])
			{
				point:Set[${Math.Calc[${Me.Corpse.X} + (${j} * ${Math.Cos[${i}]})]},${Math.Calc[${Me.Corpse.Y} - (${j} * ${Math.Sin[${i}]})]},${Me.Corpse.Z}]
				MobDistance:Set[${Math.Distance[${point},${This.NearestMob[${point}]}]}]
				if ${MobDistance} > ${This.BestRezLoc_SafetyMargin} && !${Me.IsPathObstructed[${point}]}
				{
					This.BestRezLoc:Set[${point}]
					This.BestRezLoc_SafetyMargin:Set[${MobDistance}]
				}
			}
		}
		return ${This.BestRezLoc}
	}

	member PointIsSafe(float X, float Y, float Z)
	{	
		variable guidlist MobList
		variable int SearchRadius = 20
		if ${Targeting.TargetCollection.Get[1](exists)}
		{
			SearchRadius:Inc[${Object[${Targeting.TargetCollection.Get[1]}].Level} - ${Me.Level}]			
		}
		MobList:Search[-units, -nearest, -alive,-hostile, -range 0-${SearchRadius}, -origin,${X},${Y},${Z}]
		if ${MobList.Count} > 0
		{
			return FALSE
		}
		return TRUE
	}

	member NearestMob(float X, float Y, float Z)
	{
		variable objectref theMob
		variable guidlist MobList
		theMob:Set[${Unit[-nearest, -alive,-hostile, -origin,${X},${Y},${Z}].GUID}]
		
		if ${theMob.Location(exists)}
		{
			return ${theMob.Location}
		}
		return "0,0,0"
	}
	
	;----------
	;----- Movement Functions
	;----------

	method FaceXYZ(float X, float Y, float Z)
	{
		if ${X}==0 && ${Y}==0 && ${Z}==0
		{
			; No reason to face NOTHING
			This:Debug["Error in FaceXYZ: Call to 0,0,0"]
			return
		}
		if !${ISXWoW.Facing}
		{
			if ${Math.Abs[${Me.Heading}-${Me.HeadingTo[${X},${Y}]}]} > 10
			{
				This:Debug["FaceXYZ: Facing ${X},${Y},${Z}"]
				Face -fast ${X} ${Y}
			}
		}
	}

	/* used anywhere? */
	member NeedFace(int X, int Y, int Z)
	{
		if ${Math.Abs[${Me.Heading}-${Me.HeadingTo[${X},${Y}]}]} > 10
		{
			return TRUE
		}
		return FALSE
	}	
	
	/* replacement to DegreesCCW */
	member Flip(float theHeading)
	{
		theHeading:Dec[180]
		if ${theHeading} < 0
		{
			theHeading:Inc[360]
		}
		return ${theHeading}
	}	
	
	method FaceHeading(float hd)
	{
		if !${ISXWoW.Facing}
		{
			if ${Math.Abs[${Me.Heading}-${hd}]} > 10
			{
				This:Debug["FaceHeading: Facing ${hd}"]
				Face -heading ${hd}
			}
		}
	}
	
	method MoveStop()
	{
		if ${Movement.Speed}
		{
			move -stop
		}
	}
	
	/* ensures we move forward */
	method MoveForward()
	{
		if ${Movement.Backward}
		{
			move -stop backward
		}	
		if !${Movement.Speed} || !${Movement.Forward}
		{
			move -hold forward
		}	
	}
	
	/* ensures we move backward */
	method MoveBackward(int howLong=1000)
	{
		if ${Movement.Forward}
		{
			move -stop forward
		}	
		if !${Movement.Speed} || !${Movement.Backward}
		{
			move backward ${howLong}
		}		
	}	
	
	;----------
	;----- Intersecting Paths
	;----------
	
	/* returns true if I am facing the POI within maxDegrees degrees */
	member FacingPOI(float maxDegrees=45)
	{
		if ${This.IntersectsPath[${Me.Heading.Degrees},${Me.HeadingTo[${POI.X},${POI.Y}]},${maxDegrees}]}
		{
			return TRUE
		}
		return FALSE
	}	

	/* returns true if heading toX, toY intesects my heading to hotspot */
	member IntersectsGrind(float toX, float toY, float maxDegrees=45)
	{
		if ${This.IntersectsPathXY[${Grind.X},${Grind.Y},${toX},${toY},${maxDegrees}]}
		{
			return TRUE
		}				
		return FALSE
	}

	/* returns true if heading toX, toY intersects my heading to pathX, pathY */	
	member IntersectsPathXY(float pathX, float pathY, float toX, float toY, maxDegrees=45)
	{
		if ${This.IntersectsPath[${Me.HeadingTo[${pathX},${pathY}]},${Me.HeadingTo[${toX},${toY}]},${maxDegrees}]}
		{
			return TRUE
		}
		return FALSE	
	}
			
	/* returns true if toHeading is within maxDegrees of pathHeading */
	member IntersectsPath(float pathHeading, float toHeading, float maxDegrees=45)
	{
		variable float maxLeft = ${Math.Calc[${pathHeading} + ${maxDegrees}]}
		variable float maxRight = ${Math.Calc[${pathHeading} - ${maxDegrees}]}
		
		if ${toX} == 0 && ${toY} == 0
		{
			/* no coords */
			return TRUE
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
		if (${maxLeft} > ${maxRight}) && (${${toHeading}}<=${maxLeft} && ${${toHeading}}>=${maxRight})
		{
			return TRUE
		}
		/* Left is less than Right, which is when things get tricky */
		if (${maxLeft} < ${maxRight}) && ((${${toHeading}} <= ${maxLeft} && ${${toHeading}} >= 0)||(${${toHeading}} >= ${maxRight} && ${${toHeading}} <= 360))
		{
			return TRUE
		}
		return FALSE
	}	
}

objectdef oStuck inherits cBase
{
	variable point3f LastLocation
	variable int NextCheck
	variable int Frequency = 10
	variable int StartTime = 0
	variable float MinDistance = 5	
	variable int LastStartTime = ${LavishScript.RunningTime}
	
	method Initialize()
	{
		This.LastLocation:Set[${Me.X},${Me.Y},${Me.Z}]
		This.NextCheck:Set[${LavishScript.RunningTime}]
	}

	member Elapsed()
	{
		variable float seconds	= 0
		if ${This.Check}
		{
			/* use the old start time if stuck within the last 15 seconds */
			if ${This.LastStartTime} < ${This.StartTime} && ${Math.Calc[(${This.StartTime}-${This.LastStartTime})/1000].Round} < 20
			{
				This:Debug["Last Stuck was within last 15 seconds, reset elapsed time to that value"]
				This.StartTime:Set[${This.LastStartTime}]
			}
			elseif ${This.LastStartTime} < ${This.StartTime}
			{
				This.JumpJump:Set[0]
			}
			This.LastStartTime:Set[${This.StartTime}]		
			
			if ${This.StartTime} == 0
			{
				return ${seconds}
			}		
			seconds:Set[${Math.Calc[(${LavishScript.RunningTime}-${This.StartTime})/1000].Deci}]		
			This:Debug["We have been stuck for ${seconds} seconds."]
		}
		return ${seconds}
	}
	
	member Check()
	{
		if ${This.NextCheck} < ${LavishScript.RunningTime}
		{
			if ${This.Moved}
			{
				This:Update
				return FALSE
			}
			This:MarkStart 	/* marks the start time we got stuck */			
			return TRUE
		}
		if ${This.Moved}
		{
			This:Update
		}
		return FALSE
	}
	
	member Moved()
	{
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.LastLocation.X},${This.LastLocation.Y},${This.LastLocation.Z}]} > ${This.MinDistance}
		{
			return TRUE
		}	
		return FALSE
	}	
	
	method Update()
	{
		This:ResetStart
		This.LastLocation:Set[${Me.X},${Me.Y},${Me.Z}]
		This.NextCheck:Set[${This.InMilliseconds[${This.Frequency}]}]
		return
	}
	
	method MarkStart()
	{
		if ${This.StartTime}==0
		{
			/* subtract frequency to get real start since we dont record start until after we have been stuck for at least frequency */
			This.StartTime:Set[${LavishScript.RunningTime}-${Math.Calc[10*${Frequency}]}	]	
		}
	}
	
	method ResetStart()
	{
		This.StartTime:Set[0]
	}
	
	/* jump around!  jump around!  jump up! jump up! and get down! */
	variable int JumpJump = 0
	variable int LastHoP = ${LavishScript.RunningTime}
	method HouseOfPain()
	{
		variable string direction = "left"
		variable int random = ${Math.Rand[100]}
				
		if ${LavishScript.RunningTime} < ${This.LastHoP}
		{
			return
		}
		
		/* direction random */
		if ${random} < 50
		{
			direction:Set["right"]
		}
		
		This.JumpJump:Inc	
		switch ${This.JumpJump}
		{
			case 6
			{
				This.LastHoP:Set[${This.InTenths[15]}]	
				POI.StuckCount:Inc
				This:Output["HouseOfPain: StuckCount ${POI.StuckCount}"]					
			}
			case 5
			{
				move ${direction} 1800
				This.LastHoP:Set[${This.InTenths[18]}]		
				This:Output["We have been stuck ${Int[${Math.Calc[(${LavishScript.RunningTime}-${This.StartTime})/1000].Round}]} seconds."]				
				This:Output["HouseOfPain: Move ${direction} 1800"]	
				break				
			}			
			case 4
			{
				move -stop	
				move ${direction} 3000 backward 800	
				This.LastHoP:Set[${This.InTenths[30]}]		
				Bot.ForcedStateWait:Set[${This.InTenths[30]}]
				This:Output["We have been stuck ${Int[${Math.Calc[(${LavishScript.RunningTime}-${This.StartTime})/1000].Round}]} seconds."]				
				This:Output["HouseOfPain: Move ${direction} 3000 backward 3000"]	
				break
			}
			case 3
			{
				POI.StuckCount:Inc
				This:Output["HouseOfPain: StuckCount ${POI.StuckCount}"]				
			}			
			case 2
			{
				move ${direction} 1800
				This.LastHoP:Set[${This.InTenths[18]}]		
				This:Output["We have been stuck ${Int[${Math.Calc[(${LavishScript.RunningTime}-${This.StartTime})/1000].Round}]} seconds."]				
				This:Output["HouseOfPain: Move ${direction} 3000"]	
				break				
			}
			case 1
			{
				move -stop
				wowpress JUMP						
				move forward 500
				This.LastHoP:Set[${This.InTenths[5]}]		
				This:Output["We have been stuck ${Int[${Math.Calc[(${LavishScript.RunningTime}-${This.StartTime})/1000].Round}]} seconds."]
				This:Output["HouseOfPain: Move forward 500 + JUMP"]	
				break				
			}
			default
			{
				This.JumpJump:Set[0]			
			}
		}
	}	
}
