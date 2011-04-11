/* version 3*/
objectdef cFlightPlan inherits cBase
{
	variable int LastTaxiEvent = 0
	variable bool NeedRefresh = FALSE
	variable bool NeedFlight = FALSE
	variable int LastFlight = 0
	variable index:oFlightMap FlightMap
	variable string POIFM = "NULL"
	variable string POISTR = "0:0:0:0:0:0:0:0"
	variable string DestinationFM = "NULL"
	variable bool LearnFlightMaster = FALSE
	variable string LearnFM = "0:0:0:0:0:0:0:0"
	variable string CurrentContinent = ${WoWScript[GetCurrentMapContinent()]}
	
	member TakeFlightMaster()
	{
		if ${This.NeedFlight}
		{
			This.POIFM:Set[${This.NearestFM}]		
			if ${This.Exists[${This.DestinationFM}]} && ${This.Exists[${This.POIFM}]} && ${This.DestinationFM.NotEqual[${This.POIFM}]}
			{
				return TRUE
			}
		}
		elseif ${This.Exists[${This.DestinationFM}]}
		{
			echo reset flightpath
			This.POIFM:Set[NULL]
			This.POISTR:Set["0:0:0:0:0:0:0:0"]			
			This.DestinationFM:Set[NULL]
		}
		return FALSE
	}
	
	member SetFlightPOI()
	{
		if ${Navigator.AvailablePath[${This.POISTR.Token[1,:]},${This.POISTR.Token[2,:]},${This.POISTR.Token[3,:]}]}
		{
			POI:Clear
			POI.Current:Set[${This.POISTR.Token[4,:]}]
			POI.LastUse:Set[${LavishScript.RunningTime}]
			POI.UseCount:Set[0]
			POI.LastUse:Set[0]
			POI.StuckCount:Set[0]
			POI.myobjectstring:Set[${This.POISTR}]
			return TRUE
		}
		return FALSE
	}
	
	method Pulse()
	{
		if ${This.LastTaxiEvent} > ${LavishScript.RunningTime}
		{
			if ${WoWScript[TaxiFrame:IsShown()]} && ${Bot.PauseFlag}
			{
				if ${This.NeedRefresh}
				{
					This:Refresh
					This.NeedRefresh:Set[FALSE]
					return
				}
			}
		}
		if ${This.CurrentContinent.NotEqual[${WoWScript[GetCurrentMapContinent()]}]}
		{
			This.CurrentContinent:Set[${WoWScript[GetCurrentMapContinent()]}]
		}
	}	
	
	member FlyToPoint(float X, float Y, float Z, int MaxRange=10000)
	{
		This.DestinationFM:Set[${This.FindFM[${X},${Y},${Z},${MaxRange}]}]	
		if ${This.Exists[${This.DestinationFM}]} && ${This.DestinationFM.NotEqual[${This.NearestFM}]} && ${This.IsConnected[${This.NearestFM},${This.DestinationFM}]}
		{
			This.NeedFlight:Set[TRUE]
			return TRUE
		}			
		return FALSE
	}
	
	member FlyToUnit(string POINAME, string POITYPE)
	{
		variable index:lnavregionref MerchantPOI
		variable int POIFOUND = 0
		variable int Index = 0	
		
		/* search for NPC within 100,000 yards */
		POIFOUND:Set[${LNavRegionGroup[${POITYPE}].RegionsWithin[MerchantPOI,100000,${Me.X},${Me.Y},${Me.Z}]}]	
		while ${MerchantPOI.Get[${Index:Inc}](exists)} && ${POIFOUND} > 0
		{
			if ${MerchantPOI.Get[${Index}].FQN.Equal["${POINAME}"]} && !${GlobalBlacklist.Exists[${MerchantPOI.Get[${Index}].FQN}]}
			{
				This.DestinationFM:Set[${This.FindFM[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}]},1000]			
				if ${This.Exists[${This.DestinationFM}]} && ${This.DestinationFM.NotEqual[${This.NearestFM}]} && ${This.IsConnected[${This.NearestFM},${This.DestinationFM}]}
				{
					This.NeedFlight:Set[TRUE]
					return TRUE
				}			
			}				
		}
		return FALSE
	}

	member IsConnected(string ToFM, string FromFM)
	{
		if !${This.Exists[${ToFM}]} || !${This.Exists[${FromFM}]}
		{
			return FALSE
		}
		if ${This.FlightMap.Get[${This.CurrentContinent}].IsConnected[${ToFM}, ${FromFM}]}
		{
			return TRUE
		}
		return FALSE
	}
	
	member FindFM(float X, float Y, float Z, int MaxRange=10000)
	{
		variable index:lnavregionref FlightPOI
		variable int POIFOUND = 0
		variable int Index = 0
		
		/* get flightmasters within 10000 yards */
		POIFOUND:Set[${LNavRegionGroup["FLIGHTMASTER"].RegionsWithin[FlightPOI,${MaxRange},${X},${Y},${Z}]}]
		
		while ${FlightPOI.Get[${Index:Inc}](exists)} && ${POIFOUND} > 0
		{			
			if !${GlobalBlacklist.Exists[${FlightPOI.Get[${Index}].FQN}]} && ${POI.FriendlyFaction[${LNavRegionGroup["FLIGHTMASTER"].NearestRegion[${FlightPOI.Get[${Index}].Region.CenterPoint.X},${FlightPOI.Get[${Index}].Region.CenterPoint.Y},${FlightPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[FACTION]}]}
			{
				if ${This.Exists[${FlightPOI.Get[${Index}].FQN}]}
				{
					if ${Navigator.PointsConnect[${X},${Y},${Z},${FlightPOI.Get[${Index}].Region.CenterPoint.X},${FlightPOI.Get[${Index}].Region.CenterPoint.Y},${FlightPOI.Get[${Index}].Region.CenterPoint.Z}]}				
					{
						return ${FlightPOI.Get[${Index}].FQN}
					}
				}
			}
		}
		return "NULL"		
	}
	
	member NearestFM()
	{
		variable index:lnavregionref FlightPOI
		variable int POIFOUND = 0
		variable int Index = 0
		
		/* reduce count to the nearest 3 */
		POIFOUND:Set[${LNavRegionGroup["FLIGHTMASTER"].NearestRegions[FlightPOI,5,${Me.X},${Me.Y},${Me.Z}]}]
		
		while ${FlightPOI.Get[${Index:Inc}](exists)} && ${POIFOUND} > 0
		{
			if !${GlobalBlacklist.Exists[${FlightPOI.Get[${Index}].FQN}]} && ${POI.FriendlyFaction[${LNavRegionGroup["FLIGHTMASTER"].NearestRegion[${FlightPOI.Get[${Index}].Region.CenterPoint.X},${FlightPOI.Get[${Index}].Region.CenterPoint.Y},${FlightPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[FACTION]}]}
			{	
				if ${This.Exists[${FlightPOI.Get[${Index}].FQN}]}
				{		
					if ${Navigator.AvailablePath[${FlightPOI.Get[${Index}].Region.CenterPoint.X},${FlightPOI.Get[${Index}].Region.CenterPoint.Y},${FlightPOI.Get[${Index}].Region.CenterPoint.Z}]}				
					{
						/* this is where we create the POI string */
						This.POISTR:Set[${FlightPOI.Get[${Index}].Region.CenterPoint.X}:${FlightPOI.Get[${Index}].Region.CenterPoint.Y}:${FlightPOI.Get[${Index}].Region.CenterPoint.Z}:${LNavRegionGroup["FLIGHTMASTER"].NearestRegion[${FlightPOI.Get[${Index}].Region.CenterPoint.X},${FlightPOI.Get[${Index}].Region.CenterPoint.Y},${FlightPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[GUID]}:${FlightPOI.Get[${Index}].FQN}:FLIGHTMASTER:${LNavRegionGroup["FLIGHTMASTER"].NearestRegion[${FlightPOI.Get[${Index}].Region.CenterPoint.X},${FlightPOI.Get[${Index}].Region.CenterPoint.Y},${FlightPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[FACTION]}:${LNavRegionGroup["FLIGHTMASTER"].NearestRegion[${FlightPOI.Get[${Index}].Region.CenterPoint.X},${FlightPOI.Get[${Index}].Region.CenterPoint.Y},${FlightPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[LEVEL]}]
						return ${FlightPOI.Get[${Index}].FQN}
					}
				}
			}
		}
		return "NULL"
	}

	member HaveFM()
	{
		if ${This.Exists[${This.NearestFM}]}
		{
			if ${This.DistanceToFM} < 3000
			{
				return TRUE
			}
		}
		return FALSE
	}	
	
	member DistanceToFM()
	{
		if ${This.Exists[${This.NearestFM}]}
		{
			return ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.POISTR.Token[1,:]},${This.POISTR.Token[2,:]},${This.POISTR.Token[3,:]}]}
		}
		return 9999999		
	}
	
	/* these functions return data back about the flightmaster */
	member Exists(string UnitName)
	{
		if ${UnitName.Equal[NULL]} || ${UnitName.Equal[INVALID]}
		{
			return FALSE
		}
		if ${This.FlightNode[${UnitName}].Find[INVALID]} || ${This.FlightNode[${UnitName}].Find[NULL]}
		{
			return FALSE
		}
		if ${This.FlightMap.Get[${This.CurrentContinent}].FlightMaster.Element[${UnitName}](exists)}
		{
			return TRUE
		}
		return FALSE
	}
	
	member Zone(string UnitName)
	{
		return ${This.FlightMap.Get[${This.CurrentContinent}].Zone[${UnitName}]}
	}

	member SubZone(string UnitName)
	{
		return ${This.FlightMap.Get[${This.CurrentContinent}].SubZone[${UnitName}]}
	}

	member FlightNode(string UnitName)
	{
		return ${This.FlightMap.Get[${This.CurrentContinent}].FlightNode[${UnitName}]}
	}

	/* on taxi map event, refreshes flight master data */
	method OnTaxiMap()
	{
		This.LastTaxiEvent:Set[${This.InMilliseconds[500]}]
		This.NeedRefresh:Set[TRUE]		
	}
	
	method Refresh()
	{		
		This.FlightMap.Get[${This.CurrentContinent}]:RefreshConnections[${Target.GUID}]
	}
	
	/* this scans the open taxi map for a node that matches your destination NPC */
	member GetNodeSlot(string ToFM)
	{
		variable string NodeStatus
		variable string NodeName
		variable int NumNodes
		variable int i = 1
		NumNodes:Set[${WoWScript[NumTaxiNodes()]}]		
		do
		{
			NodeStatus:Set[${WoWScript[TaxiNodeGetType(${i})]}]
			if ${NodeStatus.Equal[REACHABLE]}
			{
				NodeName:Set[${This.FlightMap.Get[1].GetNode[${i}]}]
				if ${NodeName.Equal[${This.FlightNode[${ToFM}]}]}
				{
					return ${i}
				}
			}				
		}
		while ${i:Inc} <= ${NumNodes}
		return 0	
	}

	method Initialize()
	{
		variable int i = 1
		LavishSettings:AddSet["FlightPlan"]
		LavishSettings["FlightPlan"]:Clear		
		LavishSettings["FlightPlan"]:Import["config/settings/FP-${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Name}.xml"]				
		do
		{
			This.FlightMap:Insert[${i}]
			This.FlightMap.Get[${i}]:LoadFlightMap			
		}
		while ${WoWScript[GetMapContinents(),${i:Inc}](exists)}
	}

	method Shutdown()
	{
		variable int i = 1
		LavishSettings["FlightPlan"]:Clear
		do
		{
			This.FlightMap.Get[${i}]:SaveFlightMap
		}
		while ${This.FlightMap.Get[${i:Inc}](exists)}
		LavishSettings["FlightPlan"]:Export["config/settings/FP-${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Name}.xml"]
	}
}

objectdef oFlightMap inherits cBase
{
	variable int ContinentNum
	variable collection:oFlightMaster FlightMaster

	method Initialize(int theContinent)
	{
		This.ContinentNum:Set[${theContinent}]
	}

	method LoadFlightMap()
	{
		variable iterator FlightMasterIterator
		LavishSettings["FlightPlan"].FindSet[${This.ContinentName}]:GetSettingIterator[FlightMasterIterator]		
		if ${FlightMasterIterator:First(exists)}
		{
			do
			{
				This.FlightMaster:Set["${FlightMasterIterator.Key}"]
				This.FlightMaster.Element["${FlightMasterIterator.Key}"]:Refresh["${FlightMasterIterator.Key}:${FlightMasterIterator.Value}"]				
				This.FlightMaster.Element["${FlightMasterIterator.Key}"]:LoadConnections[${This.ContinentName}]
			}
			while ${FlightMasterIterator:Next(exists)}
		}			
	}
	
	method SaveFlightMap()
	{
		variable string UnitName
		LavishSettings["FlightPlan"]:AddSet[${This.ContinentName}]
		if "${This.FlightMaster.FirstKey(exists)}"
		{
			do
			{
				UnitName:Set[${This.FlightMaster.CurrentKey}]
				LavishSettings["FlightPlan"].FindSet[${This.ContinentName}]:AddSetting[${UnitName},${This.FlightNode[${UnitName}]}]
				This.FlightMaster.Element[${UnitName}]:SaveConnections[${This.ContinentName}]
			}
  			while "${This.FlightMaster.NextKey(exists)}"
		}	
	}

	member IsConnected(string ToFM, string FromFM)
	{
		if ${This.FlightMaster.Element[${FromFM}](exists)} && ${This.FlightMaster.Element[${ToFM}](exists)}
		{
			if ${This.FlightMaster.Element[${FromFM}].IsConnected[${ToFM}]}
			{
				return TRUE
			}
		}
		return FALSE
	}

	method RefreshConnections(string theGUID)
	{
		variable int NumNodes
		variable int i = 1
		
		variable string FromNode
		variable string NodeStatus
		variable index:string Reachable
		
		variable objectref FlightNPC
		
		FlightNPC:Set[${theGUID}]
		if ${FlightNPC(exists)}
		{
			NumNodes:Set[${WoWScript[NumTaxiNodes()]}]	
			do
			{
				NodeStatus:Set[${WoWScript[TaxiNodeGetType(${i})]}]
				if ${NodeStatus.Equal[REACHABLE]}
				{
					Reachable:Insert[${This.GetNode[${i}]}]	
				}
				elseif ${NodeStatus.Equal[CURRENT]}
				{
					FromNode:Set[${This.GetNode[${i}]}]
				}				
			}
			while ${i:Inc} <= ${NumNodes}
		}
		
		if !${This.FlightMaster.Element[${FlightNPC.Name}](exists)}
		{
			This.FlightMaster:Set[${FlightNPC.Name}]
			This.FlightMaster.Element[${FlightNPC.Name}]:Refresh["${FlightNPC.Name}:${FromNode}"]			
		}
		else
		{
			This.FlightMaster.Element[${FlightNPC.Name}]:Refresh["${FlightNPC.Name}:${FromNode}"]
		}
		
		i:Set[1]
		if ${Reachable.Get[${i}](exists)}
		{
			do
			{
				This:ConnectNodes[${FromNode},${Reachable.Get[${i}]},${FlightNPC.Name}]
			}
			while ${Reachable.Get[${i:Inc}](exists)}
		}
	}

	method ConnectNodes(string FromNode, string ToNode, string FromFM)
	{
		variable string ToFM
		
		if ${FromNode.Find[INVALID]} || ${FromNode.Find[NULL]} || ${ToNode.Find[INVALID]} || ${ToNode.Find[NULL]}
		{
			return
		}

		/*this iterates through all my recorded flightmasters on the continent*/
		/*the actual node comparison happens in ConnectFM of oFlightMaster*/
		if "${This.FlightMaster.FirstKey(exists)}"
		{
			do
			{
				ToFM:Set[${This.FlightMaster.CurrentKey}]
				This.FlightMaster.Element[${ToFM}]:ConnectFM[${FromNode},${ToNode},${FromFM}]	
				if ${This.FlightMaster.Element[${ToFM}].FlightNode.Equal[${ToNode}]}
				{
					This.FlightMaster.Element[${FromFM}]:ConnectFM[${ToNode},${FromNode},${ToFM}]
				}
			}
  			while "${This.FlightMaster.NextKey(exists)}"
		}
	}

	/* because I am too fucking lazy and clever */
	member ParseZone(string theSubZone, string theZone)
	{
		return ${theZone}
	}

	member ParseSubZone(string theSubZone, string theZone)
	{
		return ${theSubZone}
	}

	member GetNode(int Num)
	{
		variable string theZone
		variable string theSubZone
		theZone:Set[${This.ParseZone[${WoWScript[TaxiNodeName(${Num})]}]}]
		theSubZone:Set[${This.ParseSubZone[${WoWScript[TaxiNodeName(${Num})]}]}]
		return "${theZone}:${theSubZone}"
	}	
	
	member Zone(string UnitName)
	{
		if ${This.FlightMaster.Element[${UnitName}](exists)}
		{
			return ${This.FlightMaster.Element[${UnitName}].Zone}
		}
		return "INVALID"
	}

	member SubZone(string UnitName)
	{
		if ${This.FlightMaster.Element[${UnitName}](exists)}
		{
			return ${This.FlightMaster.Element[${UnitName}].SubZone}
		}
		return "INVALID"
	}

	member FlightNode(string UnitName)
	{
		if ${This.FlightMaster.Element[${UnitName}](exists)}
		{
			return ${This.FlightMaster.Element[${UnitName}].FlightNode}
		}
		return "INVALID:INVALID"
	}
	
	member ContinentName()
	{
		if ${WoWScript[GetMapContinents(),${This.ContinentNum}](exists)}
		{
			return "${WoWScript[GetMapContinents(),${This.ContinentNum}]}"
		}
		return "INVALID"
	}	
}

objectdef oFlightMaster inherits cBase
{
	variable string Name
	variable string Zone
	variable string SubZone
	variable string FlightNode
	variable collection:string Connections

	method Refresh(string theNode)
	{
		This.Name:Set[${theNode.Token[1,":"]}]
		This.Zone:Set[${theNode.Token[2,":"]}]
		This.SubZone:Set[${theNode.Token[3,":"]}]
		This.FlightNode:Set["${This.Zone}:${This.SubZone}"]		
	}

	method LoadConnections(string theContinent)
	{
		variable iterator ConnectionsIterator
		
		This.ContinentNum:Set[${theContinent}]
		LavishSettings["FlightPlan"].FindSet[${theContinent}].FindSet[${This.FlightNode}]:GetSettingIterator[ConnectionsIterator]	
		
		if ${ConnectionsIterator:First(exists)}
		{
			do
			{
				This.Connections:Set[${ConnectionsIterator.Key},${ConnectionsIterator.Value}]
			}
			while ${ConnectionsIterator:Next(exists)}
		}			
	}
	
	method SaveConnections(string theContinent)
	{
		LavishSettings["FlightPlan"].FindSet[${theContinent}]:AddSet[${This.FlightNode}]
		if "${This.Connections.FirstKey(exists)}"
		{
			do
			{
				LavishSettings["FlightPlan"].FindSet[${theContinent}].FindSet[${This.FlightNode}]:AddSetting[${This.Connections.CurrentKey},${This.Connections.CurrentValue}]
			}
  			while "${This.Connections.NextKey(exists)}"
		}
	}
	
	/* if Connection exists, return true */
	member IsConnected(string theConnection)
	{
		if ${This.Connections.Element[${theConnection}](exists)}
		{
			return TRUE
		}
		return FALSE
	}

	/* if ToNode equals This node, then a connection exists */
	method ConnectFM(string FromNode, string ToNode, string FromFM)
	{
		if ${This.FlightNode.Equal[${ToNode}]} && ${This.Name.NotEqual[${FromFM}]}
		{
			/* capture both as key for possible future usage of IsConnected */
			This.Connections:Set[${FromFM},${FromNode}]
			;This.Connections:Set[${FromNode},${FromFM}]
			This:Output[Connecting ${FromNode} to ${This.FlightNode}]
		}
	}
}