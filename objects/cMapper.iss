/* Hello World */

objectdef cMapper inherits cBase
{
	variable string ConfigDir = "${Script.CurrentDirectory}/map/"
	variable string ConfigFile = "map.xml"
	variable lnavregionref CurrentZone
	variable lnavregionref PreviousZone
	variable lnavregionref CurrentRegion
	variable lnavregionref PreviousRegion
	variable int LastMapRend = ${LavishScript.RunningTime}
	variable oTopography Topography
	
	variable bool MappingDisabled = TRUE
	variable bool MapPathway = FALSE
	variable bool MapPathwayReverse = FALSE
	
	variable bool MapPathwayOld = FALSE
	variable bool FOUND = FALSE
	variable objectref MyElevator
	
	variable float el_X
	variable float el_Y 
	variable float el_TZ 
	variable float el_BZ 
	variable float el_TEX
	variable float el_TEY
	variable float el_TEZ
	variable float el_BEX
	variable float el_BEY
	variable float el_BEZ


	method Initialize()
	{
		LavishSettings:AddSet[Instances]
		LavishSettings[Instances]:Import["config/instances.xml"]
		
		ext isxgreynav
		ext isxwowgrey
		
		;GreyNav:InitializeNavSystem[C:\\Program Files\\InnerSpace\\Scripts\\Gnavstuff\\navdata\\ ]
		;GreyNav:LoadContinentXml[C:\\Program Files\\InnerSpace\\Scripts\\Gnavstuff\\navdata\\ContinentDB.xml]
		;GreyNav:RegisterContinent[0, Azeroth]
		;GreyNav:LoadMacroPathContinent[0, C:\\Program Files\\InnerSpace\\Scripts\\Gnavstuff\\navdata\\Azeroth\\Azeroth_MacroPath_NavRegions.bin2]
	GreyNav:InitializeNavSystem[C:\\navdata]
GreyNav:LoadContinentXml[C:\\navdata\\ContinentDB.xml]
GreyNav:RegisterContinent[0, Azeroth]
GreyNav:LoadMacroPathContinent[0, C:\\navdata\\Azeroth\\Azeroth_MacroPath_NavRegions.bin2]
	}
	
	method OnGUIChange()
	{
		This.MappingDisabled:Set[${UIElement[chkMappingOff@Overview@Pages@Cerebrum].Checked}]
		This.MapPathway:Set[${UIElement[chkMapPathway@Overview@Pages@Cerebrum].Checked}]
		This.MapPathwayReverse:Set[${UIElement[chkMapPathwayReverse@Overview@Pages@Cerebrum].Checked}]		
	}
	
	/* moved map loading out of intialize to allow LSO setting to load */ 
	method LoadMapper()
	{
		This:Output["Starting Mapping System"]
		This:Load
		This:ZoneChanged		
	}
	
	method Shutdown()
	{
		This:Output["Shutting down"]
		This:Save
		LavishSettings[Instances]:Export["config/instances.xml"]

		GreyNav:FinalizeNavSystem
	}
	
	method ZoneChanged()
	{
		if !${LNavRegion[${This.ZoneText}](exists)}
		{
			LavishSettings[Instances]:AddSetting[${This.ZoneText},1]
			LNavRegion[${This.Continent}]:AddChild[universe,${This.ZoneText},-unique]
		}

		PreviousZone:Set[${CurrentZone}]
		CurrentZone:SetRegion[${LNavRegion[${This.ZoneText}].FQN}]
	}

	method Save1()
	{
		This:Debug["Saving Map file ${ConfigDir}${ConfigFile}"]
		LNavRegion[Azeroth]:Export[-lso,"${ConfigDir}new${ConfigFile}"]
		This:Debug["Saved"]
	}
	
	method BackupZone()
	{
		variable bool UseLSO = ${Config.Xboxx.Element["chkLSOFormat"]}		
		if ${UseLSO}
		{
			LNavRegion[${This.ZoneText}]:Export[-lso,${ConfigDir}/bak/${This.ZoneText}]
		}		
		else
		{
			LNavRegion[${This.ZoneText}]:Export[${ConfigDir}/bak/${This.ZoneText}]	
		}	
	}
	
	method Save()
	{
		variable string Continent
		variable int INDEX_Continent
		variable string Zone
		variable int INDEX_Zone	
		variable bool UseLSO = ${Config.Xboxx.Element["chkLSOFormat"]}
		
		
		variable iterator InstanceIterator
		; Save Instance Files
		
		LavishSettings[Instances]:GetSettingIterator[InstanceIterator]
		if ${InstanceIterator:First(exists)}
		{
			do
			{
				if ${UseLSO}
				{
					LNavRegion[${InstanceIterator.Key}]:Export[-lso,${ConfigDir}/Instances/${InstanceIterator.Key}]
				}		
				else
				{
					LNavRegion[${InstanceIterator.Key}]:Export[${ConfigDir}/Instances/${InstanceIterator.Key}]	
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
				if ${UseLSO}
				{
					LNavRegion[${Zone}]:Export[-lso,${ConfigDir}${Zone}]
				}		
				else
				{
					LNavRegion[${Zone}]:Export[${ConfigDir}${Zone}]	
				}								
				INDEX_Zone:Inc
			}
			while ${WoWScript[GetMapZones(${INDEX_Continent}),${INDEX_Zone}](exists)}
			INDEX_Continent:Inc
		}
		while ${WoWScript[GetMapContinents(),${INDEX_Continent}](exists)}
		
	}
	
	method Load()
	{
		variable string Continent
		variable int INDEX_Continent
		variable string Zone
		variable int INDEX_Zone
		variable lnavregionref LoadZoneRegion
		variable lnavregionref LoadedZoneRegion
		variable bool UseLSO = ${Config.Xboxx.Element["chkLSOFormat"]}
				
		;Clear out the map information
		LavishNav:Clear
		; Add tree structure for the loading
		This:InitializeRegions
		
		;Add in a default Intance as a catch all for any zone we dont know about
		LoadZoneRegion:SetRegion[${LavishNav.FindRegion["Instance"].FQN}]
		LoadedZoneRegion:SetRegion[${LoadZoneRegion.Parent}]

		echo "Loading ${Zone} into ${LoadedZoneRegion.FQN} P: ${LoadedZoneRegion.Parent.FQN}"

		variable iterator InstanceIterator
		; Load Instance Files
		
		LavishSettings[Instances]:GetSettingIterator[InstanceIterator]
		if ${InstanceIterator:First(exists)}
		{
			do
			{
				if ${UseLSO}
				{
					LNavRegion[Instance]:Import[-lso,${ConfigDir}Instances/${InstanceIterator.Key}]
				}		
				else
				{
					LNavRegion[Instance]:Import[${ConfigDir}Instances/${InstanceIterator.Key}]	
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
				LoadZoneRegion:SetRegion[${LavishNav.FindRegion[${Zone}].FQN}]
				LoadedZoneRegion:SetRegion[${LoadZoneRegion.Parent}]
				if ${UseLSO}
				{
					LoadedZoneRegion:Import[-lso,"${ConfigDir}${Zone}"]
				}		
				else
				{
					LoadedZoneRegion:Import["${ConfigDir}${Zone}"]		
				}				
				INDEX_Zone:Inc
			}
			while ${WoWScript[GetMapZones(${INDEX_Continent}),${INDEX_Zone}](exists)}
			INDEX_Continent:Inc
		}
		while ${WoWScript[GetMapContinents(),${INDEX_Continent}](exists)}
	}

	method InitializeRegions()
	{
		variable string Continent
		variable int INDEX_Continent
		variable string Zone
		variable int INDEX_Zone
		
		This:Output["Initializing Regions"]
		LavishNav.Tree:AddChild[universe,Azeroth,-unique]
		
		;Add in a default Intance as a catch all for any zone we dont know about
		LNavRegion[Azeroth]:AddChild[universe,"Instance",-unique,-coordinatesystem]
		INDEX_Continent:Set[1]
		do
		{
			Continent:Set[${WoWScript[GetMapContinents(),${INDEX_Continent}]}]
			LNavRegion[Azeroth]:AddChild[universe,${Continent},-unique,-coordinatesystem]
			INDEX_Zone:Set[1]
			do
			{
				Zone:Set[${WoWScript[GetMapZones(${INDEX_Continent}),${INDEX_Zone}]}]
				LNavRegion[${Continent}]:AddChild[universe,${Zone},-unique]
				INDEX_Zone:Inc
			}
			while ${WoWScript[GetMapZones(${INDEX_Continent}),${INDEX_Zone}](exists)}
			INDEX_Continent:Inc
		}
		while ${WoWScript[GetMapContinents(),${INDEX_Continent}](exists)}
	}
	
	method Pulse()
	{
		This.PreviousRegion:SetRegion[${This.CurrentRegion}]
		This.CurrentRegion:SetRegion[${This.CurrentZone.BestContainer[${Me.Location}].ID}]

		if (${This.CurrentZone.ID} != ${LNavRegion[${This.ZoneText}].ID})
		{
			This:Output["Zone Changed Updating!"]
			This:ZoneChanged
		}
		
		; Do we have this mapped? If not map it
		if !${This.IsMapped[${Me.Location}]} && !${Me.Flying} && !${This.Falling} && ${Topography.IsFlat}
		{
			This:MapLocation[${Me.Location}]
		}
		
		if ${This.MapPathway} != ${This.MapPathwayOld} 
		{
			This.MapPathwayOld:Set[${This.MapPathway}]
			
			if ${This.MapPathway} 
			{
				variable guidlist list
				variable int Index = 0
				variable objectref o
				list:Search[-gameobjects]
				while ${list.GUID[${Index:Inc}](exists)} && !${This.FOUND}
				{
					o:Set[${list.GUID[${Index}]}]
					if ${o.SubType.Equal[Transport]}
					{
						if ${Math.Calc[${o.X} - ${Me.X}]} < 10 && ${Math.Calc[${o.X} - ${Me.X}]} > -10 && ${Math.Calc[${o.Y} - ${Me.Y}]} < 10 && ${Math.Calc[${o.Y} - ${Me.Y}]} > -10 
						{
							This.MyElevator:Set[${list.GUID[${Index}]}]
							This.FOUND:Set[TRUE]
							This:Output[START Creating Pathway for Transport: ${This.MyElevator.Name} ${This.MyElevator.GUID}]	
							This.el_TZ:Set[${o.Z}]
							This.el_BZ:Set[${o.Z}]
							This.el_X:Set[${o.X}]
							This.el_Y:Set[${o.Y}]
							This.el_TEX:Set[${Me.X}]
							This.el_TEY:Set[${Me.Y}]
							This.el_TEZ:Set[${Me.Z}]
							This.el_BEX:Set[${Me.X}]
							This.el_BEY:Set[${Me.Y}]
							This.el_BEZ:Set[${Me.Z}]
						}
					}
				}
			}
			else
			{
				if ${This.FOUND}	
				{
					This:Output[FINISHED Creating Pathway for Transport: ${This.MyElevator.Name} ${This.MyElevator.GUID}]	
					if ${Me.Z} > ${This.el_TEZ}
					{
						This:Output[You went from Bottom to Top]			
						This.el_TEX:Set[${Me.X}]
						This.el_TEY:Set[${Me.Y}]
						This.el_TEZ:Set[${Me.Z}]
					}
					else
					{
						This:Output[You went from Top to Bottom]			
						This.el_BEX:Set[${Me.X}]
						This.el_BEY:Set[${Me.Y}]
						This.el_BEZ:Set[${Me.Z}]
					}
					Navigator:TransportMapped[${This.MyElevator.GUID}, ${This.el_X}, ${This.el_Y}, ${This.el_TZ}, ${This.el_BZ}, ${This.el_TEX}, ${This.el_TEY}, ${This.el_TEZ}, ${This.el_BEX}, ${This.el_BEY}, ${This.el_BEZ}]
					This.FOUND:Set[FALSE]
					This.MyElevator:Set[NULL]
				}
			}
		}
		else
		{
			if ${This.FOUND}
			{
				if ${MyElevator.Z} > ${This.el_TZ}
				{
					This.el_TZ:Set[${MyElevator.Z}]
				}
				if ${MyElevator.Z} < ${This.el_BZ}
				{
					This.el_BZ:Set[${MyElevator.Z}]
				}
			}
		}
		
		if ${CurrentRegion.FQN.NotEqual[${PreviousRegion.FQN}]}
		{
			if ${This.MapPathway}
			{
				This:Output["Marking Preferred Path from ${CurrentRegion.FQN} to ${PreviousRegion.FQN}"] 
				PreviousRegion.GetConnection[${CurrentRegion.FQN}]:SetDistance[1]
			}
			if ${This.PathwayReverse}
			{
				This:Output["Marking Preferred Path (reverse) from ${PreviousRegion.FQN} to ${CurrentRegion.FQN}"] 
				CurrentRegion.GetConnection[${PreviousRegion.FQN}]:SetDistance[1]
			}			
		}
		
		if ${Math.Calc[${LavishScript.RunningTime} - ${This.LastMapRend}]} > 100
		{
			MapEditor:MapRend
		}
		; Add in additional mapping items here
	}
	
	variable int LastFell = 0
	member Falling()
	{
		if ${Me.Falling}
		{
			This.LastFell:Set[${LavishScript.RunningTime}]
			return TRUE
		}
		if ${Math.Calc[${LavishScript.RunningTime}-${This.LastFell}]} < 1000
		{
			return TRUE
		}
		return FALSE
	}
	
	member IsMapped(float X, float Y, float Z)
	{
		if (${This.CurrentZone.ID} == ${This.CurrentRegion.ID})
		{
			return FALSE
		}	
		return TRUE
	}
	
	method MapLocation(float X, float Y, float Z)
	{
		variable float X1
		variable float X2
		variable float Y1
		variable float Y2
		variable float Z1
		variable float Z2
		variable string RegionName
		
		; Dont map if we are flying (On a flight path)
		if ${Me.Flying} || ${This.MappingDisabled}
		{
			return
		}
		X1:Set[${Math.Calc[${X}-2.5]}]
		X2:Set[${Math.Calc[${X}+2.5]}]
		Y1:Set[${Math.Calc[${Y}-2.5]}]
		Y2:Set[${Math.Calc[${Y}+2.5]}]
		Z1:Set[${Math.Calc[${Z}-3]}]
		Z2:Set[${Math.Calc[${Z}+3]}]
		
		RegionName:Set["${CurrentZone.FQN}${Time.Timestamp}${CurrentZone.ChildCount}"]
		CurrentZone:AddChild[box,${RegionName},-unique,${X1},${X2},${Y1},${Y2},${Z1},${Z2}]
		This:Output["Area not found, Mapping!  Added (${RegionName} ${X}, ${Y}, ${Z}"]
		;Connect To Previous and Current
		This:ConnectNeighbours[${RegionName}]
	}

	method ConnectNeighbours(string RegionName)
	{
		variable index:lnavregionref SurroundingRegions
		variable int RegionsFound
		variable int Shouldconnect = 0
		variable int Index = 1
		variable int Connected_To = 0
		variable int Connected_From = 0
		
		CurrentRegion:SetRegion[${RegionName}]
		
		if ${This.ShouldConnect[${CurrentRegion.FQN},${PreviousRegion.FQN}]}
		{
			This:Debug["Connecting ${CurrentRegion.FQN} to ${PreviousRegion.FQN}"]
			Region:Connect[${PreviousRegion.FQN}]
		}
		if ${This.ShouldConnect[${PreviousRegion.FQN},${CurrentRegion.FQN}]}
		{
			This:Debug["Connecting ${PreviousRegion.FQN} to ${CurrentRegion.FQN}"]
			PreviousRegion:Connect[${CurrentRegion.FQN}]
		}
		
		; Need to add in Connect to Previous spot to current spot and current spot to previous spot if no collisions
		; Scan all descendants within 5 feet of this area
		RegionsFound:Set[${CurrentZone.ChildrenWithin[SurroundingRegions,10,${CurrentRegion.CenterPoint.X},${CurrentRegion.CenterPoint.Y},${CurrentRegion.CenterPoint.Z}]}]
		if ${RegionsFound} > 0
		{
			do
			{
				if ${This.ShouldConnect[${CurrentRegion.FQN},${SurroundingRegions.Get[${Index}].FQN}]} && ${This.ShouldConnect[${SurroundingRegions.Get[${Index}].FQN},${CurrentRegion.FQN}]}
				{
					Connected_To:Inc
					Connected_From:Inc
					CurrentRegion:Connect[${SurroundingRegions.Get[${Index}].FQN}]
					SurroundingRegions.Get[${Index}]:Connect[${CurrentRegion.FQN}]
				}
			}
			while ${SurroundingRegions.Get[${Index:Inc}](exists)}
			This:Output["Connections TO: ${Connected_To} and From: ${Connected_From}"]
		}
	}
	
	
	member ShouldConnect(string RegionA, string RegionB)
	{
		variable lnavregionref RegionRefA
		variable lnavregionref RegionRefB
		

		if !${RegionA(exists)} || !${RegionB(exists)}
		{
			return FALSE
		}
		
		; If they are the same Region.. Dont connect them
		if ${RegionA.Equal[${RegionB}]}
		{
			return FALSE
		}
		
		RegionRefA:SetRegion[${RegionA}]
		RegionRefB:SetRegion[${RegionB}]

		if !${This.RegionsIntersect[${RegionA},${RegionB}]}
		{
			return FALSE
		}
		
		if ${This.MapPathway}
		{
			if (${Math.Calc[${RegionRefA.CenterPoint.X} - ${RegionRefB.CenterPoint.X}]} == 0) && (${Math.Calc[${RegionRefA.CenterPoint.Y} - ${RegionRefB.CenterPoint.Y}]} == 0)
			{
				echo "Pathway, Moving vertically -- Go Go Map it !"
				return TRUE
			}
			if !${This.CollisionTest[${RegionRefA.CenterPoint.X}, ${RegionRefA.CenterPoint.Y}, ${RegionRefA.CenterPoint.Z}, ${RegionRefB.CenterPoint.X}, ${RegionRefB.CenterPoint.Y}, ${RegionRefB.CenterPoint.Z}]}
			{
				echo "Pathway (smooth way) -- Go Go Map it !"
				return TRUE
			}
			if !${This.CollisionTest[${RegionRefA.CenterPoint.X}, ${RegionRefA.CenterPoint.Y}, ${Math.Calc[${RegionRefA.CenterPoint.Z}+1.6]}, ${RegionRefB.CenterPoint.X}, ${RegionRefB.CenterPoint.Y}, ${Math.Calc[${RegionRefA.CenterPoint.Z}+1.6]}]}
			{
				echo "Pathway (rough way) -- Go Go Map it !"
				return TRUE
			}
		
			
		}
		
		if ${This.CollisionTest[${RegionRefA.CenterPoint.X}, ${RegionRefA.CenterPoint.Y}, ${RegionRefA.CenterPoint.Z}, ${RegionRefB.CenterPoint.X}, ${RegionRefB.CenterPoint.Y}, ${RegionRefB.CenterPoint.Z}]}
		{
			echo "Something in da way ! -- Not Connected"
			return FALSE
		}
		
		if ${Topography.IsSteep[${RegionRefA.CenterPoint.X}, ${RegionRefA.CenterPoint.Y}, ${RegionRefA.CenterPoint.Z}, ${RegionRefB.CenterPoint.X}, ${RegionRefB.CenterPoint.Y}, ${RegionRefB.CenterPoint.Z}]}
		{
			echo "Too Fucking Steep! -- Not Connected"
			return FALSE
		}
		
		
		return TRUE
	}

	member CollisionTest(float FromX, float FromY, float FromZ, float ToX, float ToY, float ToZ)
	{
		return ${Me.IsPathObstructed[${FromX},${FromY},${FromZ},20,${ToX},${ToY},${ToZ}]}
	}

	member RegionsIntersect(string RegionA, string RegionB)
	{
		variable lnavregionref RA
		variable lnavregionref RB

		RA:SetRegion[${RegionA}]
		RB:SetRegion[${RegionB}]

		if ${RA.Type.NotEqual["Box"]} || ${RB.Type.NotEqual["Box"]}
		{
			return FALSE
		}

		; Check Distance between if > 10 then it shouldnt connect
		if ${Math.Distance[${RA.CenterPoint.X}, ${RA.CenterPoint.Y}, ${RB.CenterPoint.X}, ${RB.CenterPoint.Y}]}>10
		{
			return FALSE
		}

		return TRUE
	}
		
	member SubZoneText()
	{
		return ${ISXWoW.MinimapZoneText}
	}

	member ZoneText()
	{
		return ${ISXWoW.RealZoneText}
	}


	member Continent()
	{
		if ${WoWScript[IsInInstance(), 1]}
		{
			return "Instance"
		}
		WoWScript SetMapToCurrentZone()
		if ${WoWScript[GetMapContinents(),${WoWScript[GetCurrentMapContinent()]}](exists)}
		{
			return ${WoWScript[GetMapContinents(),${WoWScript[GetCurrentMapContinent()]}]}
		}
		return "Instance"
	}

	method MapRend()
	{
		variable index:lnavregionref Regions
		variable lnavregionref R
		variable int Idx = 1
	
		if !${UIElement["MapGUI"].Visible}
		{
			return
		}
		
		UIElement[rend@MapGUI]:SetMapSize[15,15]
		UIElement[rend@MapGUI]:SetOrigin[${Me.X},${Me.Y},${Me.Z}]
		UIElement[rend@MapGUI]:SetRotation[${Me.Heading}]
		if ${This.CurrentZone.DescendantsWithin[Regions,25,${Me.X},${Me.Y},${Me.Z}]}
		{
			do
			{
				R:SetRegion[${Regions.Get[${Idx}].FQN}]
				UIElement[rend@MapGUI]:AddBlip[${R.Name},${R.CenterPoint.X},${Math.Calc[((${R.CenterPoint.Y}-${Me.Y}) * -1) + ${Me.Y}]},${R.CenterPoint.Z},2,${R.Name},"mapped_blip",""]
				This.LastMapRend:Set[${LavishScript.RunningTime}]
			}
			while ${Idx:Inc} <= ${Regions.Used} 
		}
		UIElement[rend@MapGUI]:AddBlip[${Me.Name},${Me.X},${Me.Y},${Me.Z},2,${Me.Name},"me_blip",""]
	}
}


objectdef oTopography inherits cBase
{
	variable point3f TempLoc
	variable int SlopeCheck = ${LavishScript.RunningTime}
	
	method UpdateTemp()
	{
		if ${Math.Calc[${LavishScript.RunningTime}-${This.SlopeCheck}]} > 500
		{
			This.TempLoc:Set[${Me.X},${Me.Y},${Me.Z}]
			This.SlopeCheck:Set[${LavishScript.RunningTime}]
		}	
	}
	
	member IsFlat()
	{
		if ${This.IsSteep[${This.TempLoc.X},${This.TempLoc.Y},${This.TempLoc.Z},${Me.X},${Me.Y},${Me.Z}]}
		{
			This:Debug["LIKE THE CLIFFS OF DOVER!!!!!!!"]
			This:UpdateTemp
			return FALSE
		}
		This:UpdateTemp
		return TRUE	
	}
	
	/* check slope to determine if two points should connect - assumes anything more than 45 degrees is impassable */
	member IsSteep(float FromX, float FromY, float FromZ, float ToX, float ToY, float ToZ)
	{
		/* determine horizontal distance and vertical distance between points */
		variable float slope = 0
		variable float maxslope = 0.8
		variable float horizontal = ${Math.Distance[${FromX}, ${FromY}, ${ToZ},${ToX}, ${ToY},${ToZ}]}
		variable float vertical = ${Math.Distance[${ToX}, ${ToY}, ${FromZ}, ${ToX}, ${ToY}, ${ToZ}]}
		
		/* did we move? */
		if ${horizontal} < 1.5
		{
			return FALSE
		}
		
		/* adjust for greater distance */
		if ${horizontal} > 5
		{
			maxslope:Set[0.65]
		}
		
		/* calculate slope by dividing vertical distance by horizontal */
		slope:Set[${vertical}/${horizontal}]
		
		/* if slope is greater than 1, the slope is greater than a 45 degree angle - lets not map it */
		if ${slope} > ${maxslope}
		{
			return TRUE
		}
		return FALSE
	}	
}
