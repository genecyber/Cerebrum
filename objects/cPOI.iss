;Factions
#define FACTION_NEUTRAL NONE
#define FACTION_ALLIANCE ALLIANCE
#define FACTION_HORDE HORDE

;Skills -> Should be moved to oToon some time
#define SKILL_MINING Mining
#define SKILL_HERBALISM Herbalism
#define SKILL_SKINNING Skinning
#define SKILL_FISHING Fishing
#define SKILL_LOOT LOOT

#define SPELL_HERBALISM Herb
#define SPELL_SKINNING Skinning
#define SPELL_MINING Mining

/* used in POI.Available path to limit frequency of path searches */
objectdef cAvailablePathTest inherits cBase
{
	variable int NextCheck
	variable bool LastResult
	variable string LastGUID
	
	method Initialize(string ostring)
	{
		This.NextCheck:Set[${This.InSeconds[3]}]
		This.LastGUID:Set[${ostring.Token[4,:]}]	
	}
	
	method Result(bool outcome)
	{
		This.LastResult:Set[${outcome}]
	}
}

objectdef oPOI inherits cBase
{
	variable string myobjectstring="0:0:0:0:0:0:0:0:0"
	variable objectref Current

	;This timeout tells how long the Blacklisted ActionObject should not get used, TBD: 1hour
	variable int BlacklistedTimeOut = 3600000
	variable int RandomDistanceModifier = ${Math.Rand[20]}
	variable int Priority = 1000

	variable int MissingMoneyForTraining = 0

	variable collection:string MetaTypeGroup

	variable bool NeedRepair = FALSE
	variable bool NeedSell = FALSE
	variable bool NeedRestock = FALSE
	variable bool NeedClassTrainer = FALSE
	variable bool NeedMailbox = FALSE
	variable bool NeedSpiritHealer = FALSE
	variable bool NeedLogout = FALSE
	variable bool NeedTradeSkill = FALSE
	
	variable bool IgnoreSkinningTrainer = FALSE
	variable bool IgnoreHerbalismTrainer = FALSE
	variable bool IgnoreMiningTrainer = FALSE

	variable int CorpseCampCount = 0
	variable int CorpseCampTimeout = 120000
	variable int LastRetrieveCorpseTime = ${LavishScript.RunningTime}

	variable int LastUse = 0
	variable int UseCount = 0
	variable string LastGUID = NULL
	variable int MaxUseToBlackList = 10
	variable int MaxUseToBlackListBase = 5
	variable int MaxUseToBlackListRandomModifier = 5
	
	variable int Pcounter = 0
	
	variable int StuckCount = 0
	variable int StuckCountLimit = 2
	
	member NextMaxUseToBlackList()
	{
		variable int temp
		temp:Set[${Math.Calc[${This.MaxUseToBlackListBase} + ${Math.Rand[${This.MaxUseToBlackListRandomModifier}]}]}]
		return ${temp}
	}
	
	method Clear()
	{
		This:Pulse
		This.myobjectstring:Set["0:0:0:0:0:0:0:0:0"]
		Navigator:ClearPath
		;BE CAREFUL WITH THIS STOP -- CAUSED HERKY JERKY MOVEMENT IN POI.Set CALLS
		;REPLACED IT THERE WITH JUST THE PULSE AND CLEAR PATH
		Navigator:MoveStop
	}
	
	method JustClear()
	{
		This.myobjectstring:Set["0:0:0:0:0:0:0:0:0"]
		Navigator:ClearPath
		Navigator:MoveStop
	}
	
	method RefreshXYZ()
	{
		if ${This.Type.Equal[GROUP]}
		{
			POI:RefreshGroup
			return
		}
		This.myobjectstring:Set[${This.X}:${This.Y}:${This.Z}:${This.myobjectstring.Token[4,:]}:${This.myobjectstring.Token[5,:]}:${This.myobjectstring.Token[6,:]}:${This.myobjectstring.Token[7,:]}:${This.myobjectstring.Token[8,:]}:${This.myobjectstring.Token[9,:]}]
		This:Debug[Refreshing XYZ coords for POI ${POI.Name}]
	}

	method RefreshNPC()
	{
		variable string UnitName = ${This.myobjectstring.Token[5,:]}
		if ${This.MetaType.Equal[NPC]}
		{
			if ${Unit[${UnitName}](exists)} && ${Unit[${UnitName}].GUID.NotEqual[${This.myobjectstring.Token[4,:]}]} && !${Unit[${This.myobjectstring.Token[4,:]}](exists)}
			{
				This.myobjectstring:Set[${Unit[${UnitName}].X}:${Unit[${UnitName}].Y}:${Unit[${UnitName}].Z}:${Unit[${UnitName}].GUID}:${UnitName}:${This.myobjectstring.Token[6,:]}:${This.myobjectstring.Token[7,:]}:${This.myobjectstring.Token[8,:]}:${This.myobjectstring.Token[9,:]}]
				This.Current:Set[${Unit[${UnitName}].GUID}]
				This:Debug[Refreshing GUID for POI ${UnitName}]
			}
		}
	}	
	
	method RefreshGroup()
	{
		variable int i = 1
		variable bool clearit = TRUE
		if ${This.Type.Equal[GROUP]}
		{
			do
			{
				if ${Party.UnitName[${i}].Equal[${This.Name}]}
				{
					clearit:Set[FALSE]
				}
			}
			while ${i:Inc} <= ${Group.Members}
			if ${clearit} || ${This.Name.Equal[NULL]}
			{
				This.myobjectstring:Set["0:0:0:0:0:0:0:0:0"]
				This.Current:Set[${This.myobjectstring.Token[4,:]}]				
				This:Debug[Clearing bad GROUP POI]
			}
		}
	}
	
	member StatusText()
	{
		return ${This.StuckCount} ${This.Name} ${This.Type}
	}

	;****************************************************************************************
	;***	COMMON POI routines								START																					***
	;****************************************************************************************
	;The POI Pulse method
	method Pulse()
	{
		if ${This.myobjectstring.Equal["0:0:0:0:0:0:0:0:0"]} || ${Me.Flying}
		{
			return
		}
		
		if !${This.IsBlacklisted} && !${This.IsDynamic} && (${This.Distance} < 50) && ${This.Type.NotEqual[HOTSPOT]} && ${This.Type.NotEqual[CORPSE]}  && ${This.Type.NotEqual[SPIRITHEALER]}
		{
			if ${This.MetaType.Equal[NPC]}
			{
				This:RefreshNPC
			}
			if ${This.Type.Equal[MAILBOX]}
			{
				variable guidlist list
				variable int Index
				list:Search[-mailbox]
				Index:Set[0]
				if ${list.GUID[${Index:Inc}](exists)}
				{
					This.Current:Set[${list.GUID[${Index}]}]
				}
			}
		}

		if !${This.IsBlacklisted} && !${This.IsDynamic} && (${This.Distance} < 50) && ${This.Type.NotEqual[HOTSPOT]} && ${This.Type.NotEqual[CORPSE]}  && ${This.Type.NotEqual[SPIRITHEALER]}
		{
			;SAFETY NET: No there check
			This:Output[SAFETY NET: The POI ${This.Name} ${This.GUID} expected to be here was NOT found ! Blacklisting it for 1 Hour.]
			GlobalBlacklist:Insert[${This.GUID},3600000]
			; TODO: Decrease the POI confidence in the POI database. If the confidence is very very low, then delete the POI databse entry
			POI:JustClear
			State.LOOTState_Skip_Scans:Set[0]
			return
		}

		
		if ${This.StuckCount} >= ${This.StuckCountLimit} 
		{
			;SAFETY NET: No there check
			This:Output[SAFETY NET: To many stucks during running to current POI ${This.Name} ${This.GUID}.]
			This:Output[Blacklisting it for 1 Hour.]
			GlobalBlacklist:Insert[${This.GUID},3600000]
			GlobalBlacklist:Insert[${This.Name},3600000]
			POI.StuckCount:Set[0]				
			POI:JustClear		
			State.LOOTState_Skip_Scans:Set[0]
			return
		}	
	}

	;This method is to ensure that BOP items get looted
	method LootBindConfirm(string Id, string IdText, string Slot)
	{
		WowScript ConfirmLootSlot("${Slot}")
		WowScript StaticPopup_Hide("LOOT_BIND")
	}


	/* path check object is stored by poi type to keep list small - this isnt iterated, so should work to improve performance by limiting unneeded path checks*/
	variable collection:oAvailablePathTest PathTest	
	member AvailablePath(string ostring=${This.myobjectstring})
	{
		variable bool navresult	
		variable float X = ${Float[${ostring.Token[1,:]}]}
		variable float Y = ${Float[${ostring.Token[2,:]}]}
		variable float Z = ${Float[${ostring.Token[3,:]}]}
		
		if ${This.PathTest.Element[${poiType}](exists)}
		{
			if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${X},${Y},${Z}]} < 40 && !${Me.IsPathObstructed[${X},${Y},${Z}]}
			{
				navresult:Set[${Navigator.AvailablePath[${X},${Y},${Z}]}]			
				This.PathTest:Set[${poiType},${ostring}]
				This.PathTest.Element[${poiType}]:Result[${navresult}]		
				return ${navresult}
			}			
			/* no need to check path again if path was just checked */
			if ${This.PathTest.Element[${poiType}].LastGUID.Equal[${ostring.Token[4,:]}]} && ${LavishScript.RunningTime} > ${This.PathTest.Element[${poiType}].NextCheck]}
			{
				navresult:Set[${This.PathTest.Element[${poiType}].LastResult}]
				return ${navresult}
			}
		}
		navresult:Set[${Navigator.AvailablePath[${X},${Y},${Z}]}]
		This.PathTest:Set[${poiType},${ostring}]
		This.PathTest.Element[${poiType}]:Result[${navresult}]		
		return ${navresult}
	}	

	/* cpu saver - limits searches to once every 10 seconds per type */
	variable collection:int LastNearestAttempt
	member PerformSearchNPC(string POITYPE)
	{
		if ${This.LastNearestAttempt.Element[${POITYPE}]} > ${LavishScript.RunningTime}
		{
			return FALSE
		}
		This.LastNearestAttempt:Set[${POITYPE},${This.InSeconds[10]}]
		return TRUE
	}
	
	member SetNearestPOI(string POITYPE,int MinLevel=0,int MaxLevel=99999, int MaxRange=-1)
	{
		variable index:lnavregionref MerchantPOI
		variable int POIFOUND = 0
		variable int Index = 0	
		variable string theFaction
		variable point3f theLoc
		variable int theTravel = 0
		variable int theLevel = 0
		variable int CloserNPCs
		
		if ${This.PerformSearchNPC[${POITYPE}]}
		{
			if ${FlightPlan.HaveFM} && ${Config.GetCheckbox[chkTakeFMToPOI]}
			{
				POIFOUND:Set[${LNavRegionGroup["${POITYPE}"].RegionsWithin[MerchantPOI,100000,${Me.X},${Me.Y},${Me.Z}]}]
				while ${MerchantPOI.Get[${Index:Inc}](exists)}
				{
					theFaction:Set[${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[FACTION]}]			
					theLevel:Set[${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[LEVEL]}]
					if !${This.FriendlyFaction[${theFaction}]} || ${theLevel} > ${MaxLevel} || ${theLevel} < ${MinLevel} || ${GlobalBlacklist.Exists[${MerchantPOI.Get[${Index}].FQN}]}
					{
						MerchantPOI:Remove[${Index}]
					}
					else
					{
						theLoc:Set[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}]
						theTravel:Set[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${theLoc.X},${theLoc.Y},${theLoc.Z}]}]
						if ${Math.Calc[${FlightPlan.DistanceToFM}-${theTravel}]} > 0
						{
							CloserNPCs:Inc
						}
					}
				}
				MerchantPOI:Collapse
				
				Index:Set[0]
				while ${MerchantPOI.Get[${Index:Inc}](exists)}
				{
					theLoc:Set[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}]
					theTravel:Set[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${theLoc.X},${theLoc.Y},${theLoc.Z}]}]
					if ${Index} > ${CloserNPCs}
					{
						if ${Math.Calc[${FlightPlan.DistanceToFM}-${theTravel}]} < -1000 && ${FlightPlan.FlyToPoint[${theLoc.X},${theLoc.Y},${theLoc.Z},500]}
						{
							if ${FlightPlan.SetFlightPOI}
							{
								return TRUE
							}	
						}
						elseif ${This.Set[${theLoc.X}:${theLoc.Y}:${theLoc.Z}:${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[GUID]}:${MerchantPOI.Get[${Index}].FQN}:${POITYPE}:${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[FACTION]}:${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[LEVEL]}]}
						{
							return TRUE
						}
						elseif ${FlightPlan.FlyToPoint[${theLoc.X},${theLoc.Y},${theLoc.Z},500]}
						{
							if ${FlightPlan.SetFlightPOI}
							{
							return TRUE
							}								
						}
					}
					elseif ${This.Set[${theLoc.X}:${theLoc.Y}:${theLoc.Z}:${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[GUID]}:${MerchantPOI.Get[${Index}].FQN}:${POITYPE}:${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[FACTION]}:${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[LEVEL]}]}
					{
						return TRUE
					}
				}					
			}
			else
			{
				This:Output[Try setting POI to Nearest "${POITYPE}"]
				POIFOUND:Set[${LNavRegionGroup["${POITYPE}"].RegionsWithin[MerchantPOI,10000,${Me.X},${Me.Y},${Me.Z}]}]
				while ${MerchantPOI.Get[${Index:Inc}](exists)} && (${MaxRange}==-1 || ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}]} <= ${MaxRange})
				{
					theFaction:Set[${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[FACTION]}]			
					if ${This.FriendlyFaction[${theFaction}]}
					{					
						if ${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[LEVEL]} <= ${MaxLevel} && ${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[LEVEL]} >= ${MinLevel}
						{
							if ${This.Set[${MerchantPOI.Get[${Index}].Region.CenterPoint.X}:${MerchantPOI.Get[${Index}].Region.CenterPoint.Y}:${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}:${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[GUID]}:${MerchantPOI.Get[${Index}].FQN}:${POITYPE}:${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[FACTION]}:${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[LEVEL]}]}
							{
								return TRUE
							}
						}
					}
				}				
			}
		}
		return FALSE
	}
	
	member SetPOINamed(string POINAME)
	{
		variable index:lnavregionref MerchantPOI
		variable int POIFOUND = 0
		variable int Index = 0
		POIFOUND:Set[${LNavRegionGroup[SELL].RegionsWithin[MerchantPOI,100000,${Me.X},${Me.Y},${Me.Z}]}]	

		if ${This.PerformSearchNPC[${POINAME}]}
		{		
			while ${MerchantPOI.Get[${Index:Inc}](exists)}
			{
				if ${MerchantPOI.Get[${Index}].FQN.Equal["${POINAME}"]}
				{
					if ${FlightPlan.HaveFM} && ${Config.GetCheckbox[chkTakeFMToPOI]}
					{	
						theLoc:Set[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}]
						theTravel:Set[${Math.Distance[${Me.X},${Me.Y},${Me.Z},${theLoc.X},${theLoc.Y},${theLoc.Z}]}]
						if ${Math.Calc[${FlightPlan.DistanceToFM}-${theTravel}]} < -1000
						{
							if ${FlightPlan.FlyToUnit[${MerchantPOI.Get[${Index}].FQN},SELL]}
							{
								if ${FlightPlan.SetFlightPOI}
								{
									return TRUE
								}	
							}						
						}
					}
					if ${Navigator.AvailablePath[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}]}
					{
						if ${This.Set[${MerchantPOI.Get[${Index}].Region.CenterPoint.X}:${MerchantPOI.Get[${Index}].Region.CenterPoint.Y}:${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}:${LNavRegionGroup["SELL"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[GUID]}:${MerchantPOI.Get[${Index}].FQN}:SELL:${LNavRegionGroup["SELL"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[FACTION]}:${LNavRegionGroup["SELL"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[LEVEL]}]}
						{
						return TRUE
						}
					}
					return FALSE
				}
			}
		}
		return FALSE
	}
	
	member IsDynamic()
	{
		if ${This.Current.Name.NotEqual[NULL]}
		{
			return TRUE
		}
		return FALSE
	}
	member InUseRange()
  {               
    if !${This.IsDynamic} || ${This.Distance} > 10
    {
			return FALSE
    }
    if ${This.Distance} < 4.5
    {
      return TRUE
    }
    if ${Me.IsPathObstructed[${This.X},${This.Y},${This.Z}]} && !${Movement.Speed}
    {
      if ${Mapper.CurrentZone.BestContainer[${Me.Location}].ID} == ${Mapper.CurrentZone.BestContainer[${Object[${This.GUID}].Location}].ID}
      {
      	return TRUE
      }
    }
    return FALSE
  }

	method LootAll()
	{
		This.LastUse:Set[${LavishScript.RunningTime}]
		LootAll
		This:Clear
	}
	;****************************************************************************************
	;***	COMMON POI routines									END																					***
	;****************************************************************************************


	;****************************************************************************************
	;***	VIRTUALIZATION POI routines					START																				***
	;****************************************************************************************
	member X()
	{
		if ${This.IsDynamic}
		{
			return ${This.Current.X}
		}
		return ${This.myobjectstring.Token[1,:]}
	}
	member Y()
	{
		if ${This.IsDynamic}
		{
			return ${This.Current.Y}
		}
		return ${This.myobjectstring.Token[2,:]}
	}
	member Z()
	{
		if ${This.IsDynamic}
		{
			return ${This.Current.Z}
		}
		return ${This.myobjectstring.Token[3,:]}
	}
	member GUID()
	{
		if ${This.IsDynamic}
		{
			return ${This.Current.GUID}
		}
		return ${This.myobjectstring.Token[4,:]}
	}
	member Name()
	{
		if ${This.IsDynamic}
		{
			return ${This.Current.Name}
		}
		return ${This.myobjectstring.Token[5,:]}
	}
	member Type()
	{
		return ${This.myobjectstring.Token[6,:]}
	}
	
	; possible meta types are NPC, LOOT, CORPSE, MOB, ROAM, UNKNOWN
	member MetaType()
	{
		return ${This.GetMetaType[${This.Type}]}
	}

	member Faction()
	{
		return ${This.myobjectstring.Token[7,:]}
	}
	member Level()
	{
		return ${This.myobjectstring.Token[8,:]}
	}
	member Str()
	{
		return ${This.myobjectstring}
	}
	member Distance()
	{
		if ${This.IsDynamic}
		{
			return ${This.Current.Distance}
		}
		return ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.myobjectstring.Token[1,:]},${This.myobjectstring.Token[2,:]},${This.myobjectstring.Token[3,:]}]}
	}
	method Use()
	{
		if ${This.Distance} > 4.5
    {
     	Navigator:FaceXYZ[${This.X},${This.Y},${This.Z}]
      move forward 100
    }
		
		if ${LavishScript.RunningTime} < ${Math.Calc[${This.LastUse} + ${Bot.GlobalCooldown} + 500]}
		{
			;SAFETY NET: Used to frequent
			This:Output[SAFETY NET: The POI ${This.Name} ${This.GUID} has been used to frequent. Skipping current use.]
			return
		}
		
		if ${This.UseCount} >= ${This.MaxUseToBlackList} 
		{
			;SAFETY NET: Used to often check
			This:Output[SAFETY NET: The POI ${This.Name} ${This.GUID} used to often (${This.MaxUseToBlackList} times). Blacklisting it for 10 Minutes.]
			GlobalBlacklist:Insert[${This.GUID},600000]
			This.UseCount:Set[0]
			POI:Clear
			return
		}
		This.LastUse:Set[${LavishScript.RunningTime}]
		This.UseCount:Inc
		This.Current:Use
	}
	
	member IsBlacklisted()
	{
		if ${GlobalBlacklist.Exists[${This.GUID}]} || ${GlobalBlacklist.Exists[${This.Name}]} 
		{
			return TRUE
		}
		return FALSE
	}
	
	member FriendlyFaction(string checkFaction)
	{
		if ${checkFaction.Upper.Equal[${Me.FactionGroup.Upper}]} || ${checkFaction.Upper.Equal[FACTION_NEUTRAL]}
		{
			return TRUE
		}
		return FALSE
	}
	
		member Set(string ostring, bool ForceSet = FALSE)
	{
		if !${ForceSet} && !${This.FriendlyFaction[${ostring.Token[7,:]}]} && ${ostring.Token[6,:].NotEqual[MOB]}
		{
			return FALSE
		}

		if !${ForceSet} && ${GlobalBlacklist.Exists[${ostring.Token[5,:]}]} || ${GlobalBlacklist.Exists[${ostring.Token[4,:]}]}
		{
			return FALSE
		}

		if ${This.myobjectstring.Equal[${ostring}]}
		{
			return TRUE
		}

		if ${ForceSet} || ${This.AvailablePath[${ostring}]}
		{
			;REMOVED CLEAR -- WAS FUCKING MOVING POIS WITH HERKY JERKY STOPS
			This:Pulse
			Navigator:ClearPath
			This.Current:Set[${ostring.Token[4,:]}]
			if ${This.LastGUID.Equal[${ostring.Token[4,:]}]}
			{
				;echo Setting POI to same GUID Not resetting UseCount (${This.UseCount} of ${This.MaxUseToBlackList}) !
			}
			else
			{
				This.UseCount:Set[0]	
				This.LastUse:Set[0]
				This.StuckCount:Set[0]
				This.MaxUseToBlackList:Set[${This.NextMaxUseToBlackList}]
				;echo MaxUseToBlackList ${This.MaxUseToBlackList}
			}
			This.LastGUID:Set[${ostring.Token[4,:]}]
			This.myobjectstring:Set[${ostring}]
			return TRUE
		}

		;This:Output[No Path to POI ${This.Name} ${This.GUID} ! Blacklisting it with GUID for 60 seconds.]
		;GlobalBlacklist:Insert[${ostring.Token[4,:]},60000]
		return FALSE
	}

	;****************************************************************************************
	;***	VIRTUALIZATION POI routines					END   																			***
	;****************************************************************************************









	;****************************************************************************************
	;***	MAPPING POI routines								START																				***
	;****************************************************************************************
	method StartupObjectScan()
	{
		/* This method scan for all objects on startup */
		variable guidlist list
		variable int Index
		list:Search[-all]
		Index:Set[0]
		while ${list.GUID[${Index:Inc}](exists)}
		{
			This:ObjectAdded[${list.GUID[${Index}]}]
		}
	}
	method ObjectRemoved(string GUID)
	{
	
	}
	
	method ObjectAdded(string GUID)
	{
		variable objectref o=${GUID}

		if ${o.Type.Equal[Game Object]}
		{
			This:NewGameObject[${GUID}]
			return
		}

		if ${o.Type.Equal[Unit]}
		{
			This:NewUnit[${GUID}]
			return
		}
	}
	method NewGameObject(string GUID)
	{
		variable objectref o=${GUID}
		
		if ${o.Name.Find[Mailbox]}
		{
			variable int x=${o.X}
			variable int y=${o.Y}
			variable int z=${o.Z}

			if ${o.CanUse}
			{
				This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},MAILBOX,MAILBOX@${Mapper.SubZoneText}~${Mapper.ZoneText}~${Mapper.Continent}~${x}~${y}~${z},${Me.FactionGroup.Upper},${o.Level}]
			}
		}

		if ${o.SubType.Equal[Chest]}
		{
			if ${OBDB.GetType[${o.Name}].Equal[HERBALISM]}
			{
				This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},HERBALISM,${o.Name}@${Mapper.SubZoneText}~${Mapper.ZoneText}~${Mapper.Continent}~${x}~${y}~${z},FACTION_NEUTRAL,${OBDB.GetLevel[${o.Name}]}]
			}

			if ${OBDB.GetType[${o.Name}].Equal[MINING]}
			{
				This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},MINING,${o.Name}@${Mapper.SubZoneText}~${Mapper.ZoneText}~${Mapper.Continent}~${x}~${y}~${z},FACTION_NEUTRAL,${OBDB.GetLevel[${o.Name}]}]
			}
		}
		
		if ${o.SubType.Equal[Transport]}
		{
			Navigator:TransportAdded[${GUID}]
		}
	}
	
	method NewUnit(string GUID)
	{
		variable objectref o=${GUID}

		if ${o.CanRepair}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},REPAIR,${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}

		if ${o.IsMerchant}
		{
			if ${o.Title.Find[Food]}
			{
				vtype:Set[FOOD]
			}
			if ${o.Title.Find[Drink]}
			{
				vtype:Set[WATER]
			}
			if ${o.Title.Find[Gun]} || ${o.Title.Find[Ammo]} 
			{
				vtype:Set[AMMO]
			}
			if ${o.Title.Find[Bow]} || ${o.Title.Find[Fletcher]} 
			{
				vtype:Set[ARROW]
			}
			if ${o.Title.Find[General]}
			{
				vtype:Set[GENERAL]
			}
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},SELL,${o.Name},${o.FactionGroup.Upper},${o.Level},${vtype}]
		}

		if ${o.Title.Equal["Druid Trainer"]}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Druid_TRAINER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}

		if ${o.Title.Equal["Mage Trainer"]}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Mage_TRAINER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}

		if ${o.Title.Equal["Hunter Trainer"]}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Hunter_TRAINER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}

		if ${o.Title.Equal["Rogue Trainer"]}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Rogue_TRAINER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}

		if ${o.Title.Equal["Warrior Trainer"]}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Warrior_TRAINER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}

		if ${o.Title.Equal["Paladin Trainer"]}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Paladin_TRAINER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}

		if ${o.Title.Equal["Shaman Trainer"]}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Shaman_TRAINER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}
		
		if ${o.Title.Equal["Priest Trainer"]}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Priest_TRAINER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}

		if ${o.Title.Equal["Warlock Trainer"]}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Warlock_TRAINER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}
		
		if ${o.Title.Equal["Gryphon Master"]}|| ${o.Title.Equal["Hippogryph Master"]}|| ${o.Title.Equal["Bat Handler"]}|| ${o.Title.Equal["Wind Rider Master"]}
		{
			if !${FlightPlan.Exists[${o.Name}]} && ${This.FriendlyFaction[${o.FactionGroup}]} && ${Config.GetCheckbox[chkLearnFM]}
			{
				if ${Navigator.AvailablePath[${o.X},${o.Y},${o.Z}]}
				{
					FlightPlan.LearnFlightMaster:Set[TRUE]
					FlightPlan.LearnFM:Set[${o.X}:${o.Y}:${o.Z}:${o.GUID}:${o.Name}:FLIGHTMASTER:${o.FactionGroup.Upper}:${o.Level}]
				}
			}			
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"FLIGHTMASTER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}

		if ${o.IsInnkeeper}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"INNKEEPER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}

		if ${o.IsBanker}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"BANKER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}
		
		if ${o.IsAuctioneer}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"AUCTIONEER",${o.Name},${o.FactionGroup.Upper},${o.Level}]
		}

		if ${o.IsSpiritHealer}
		{
			This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"SPIRITHEALER",SPIRITHEALER@${Mapper.SubZoneText}~${Mapper.ZoneText}~${Mapper.Continent}~${x}~${y}~${z},FACTION_NEUTRAL,${o.Level}]
		}

		if ${o.Title.Equal["Skinner"]} || ${o.Title.Equal["Skinning Trainer"]} || ${o.Title.Equal["Grand Master Skinner"]}
		{
			if ${o.Level}>=60 || ${o.Title.Equal["Grand Master Skinner"]}
			{
				This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Skinning_TRAINER",${o.Name},${o.FactionGroup.Upper},375]
			}
			else
			{
				This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Skinning_TRAINER",${o.Name},${o.FactionGroup.Upper},300]
			}
		}

		if ${o.Title.Equal["Herbalism Trainer"]} || ${o.Title.Equal["Superior Herbalist"]} || ${o.Title.Equal["Herbalist"]}
		{
			if ${o.Level}>=60
			{
				This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Herbalism_TRAINER",${o.Name},${o.FactionGroup.Upper},375]
			}
			else
			{
				This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Herbalism_TRAINER",${o.Name},${o.FactionGroup.Upper},300]
			}
		}

		if ${o.Title.Equal["Mining Trainer"]} || ${o.Title.Equal["Miner"]}
		{
			if ${o.Level}>=60
			{
				This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Mining_TRAINER",${o.Name},${o.FactionGroup.Upper},375]
			}
			else
			{
				This:AddPOI[${o.GUID},${o.X},${o.Y},${o.Z},"Mining_TRAINER",${o.Name},${o.FactionGroup.Upper},300]
			}
		}

	}
	;****************************************************************************************
	;***	MAPPING POI routines								END																					***
	;****************************************************************************************









	;****************************************************************************************
	;***	Low-Level POI routines							START																				***
	;****************************************************************************************
	method AddPOI(string POIGUID, float X, float Y, float Z, string POITYPE, string UnitName, string Faction, string Level,string VendorType = "")
	{
		; Add the point
		variable lnavregionref myRegion = ${Mapper.CurrentZone.AddChild[point,${UnitName},-unique,${X},${Y},${Z}].ID}
		
		; Add point to group
		LNavRegionGroup["${POITYPE}"]:Add["${myRegion.FQN}"]
		
		; Add unitname to point
		if ${myRegion.Custom[UNITNAME].Equal["${UnitName}"]} || !${myRegion.Custom[UNITNAME](exists)}
		{
			myRegion:SetCustom[GUID,${POIGUID}]
			myRegion:SetCustom[UNITNAME,"${UnitName}"]
			myRegion:SetCustom[FACTION,${Faction}]
			myRegion:SetCustom[LEVEL,${Level}]
			if !${VendorType.Equal[""]}
			{
				LNavRegionGroup["${VendorType}"]:Add["${myRegion.FQN}"]
			}
			This:PopulatePOIs		
		}
		else
		{
			This:Output["Warning can't add POI ${UnitName} to Map. Region is already occupied by ${myRegion.Custom[UNITNAME]}"]
			This:Debug["Warning can't add POI ${UnitName} to Map. Region is already occupied by ${myRegion.Custom[UNITNAME]}"]
		}

		if ${This.GetMetaType[${POITYPE}].Equal[NPC]} && ${This.Type.Equal[${POITYPE}]}
		{
			if ${Object[${POIGUID}].Name.Equal[${This.myobjectstring.Token[5,:]}]}
			{
				; refresh xyz and guid
				This:RefreshNPC
			}
			/* commenting this out for now - too laggy and confuses bot
			else
			{
				; check closer
				This:TestBest[${POIGUID}, ${POITYPE}]
			} */
		}					
	}
	
	method RemovePOI()
	{
		variable string POITYPE = ${UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum].SelectedItem}
		variable string DelFQN=${UIElement[tlbPOIs@Blacklist@POIPages@POIs@Pages@Cerebrum].SelectedItem}

		variable index:lnavregionref MerchantPOI
		variable int POIFOUND = 0
		variable int Index = 0
		POIFOUND:Set[${LNavRegionGroup[${POITYPE}].RegionsWithin[MerchantPOI,100000,${Me.X},${Me.Y},${Me.Z}]}]
		while ${MerchantPOI.Get[${Index:Inc}](exists)}
		{
			if  ${DelFQN.Equal[${MerchantPOI.Get[${Index}].FQN}]}
			{
				MerchantPOI.Get[${Index}]:Remove
				This:PopulatePOIs
				return
			}
		}
	}
	method GotoPOI()
	{
		variable string POITYPE = ${UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum].SelectedItem}
		variable string GotoFQN=${UIElement[tlbPOIs@Blacklist@POIPages@POIs@Pages@Cerebrum].SelectedItem}

		variable index:lnavregionref MerchantPOI
		variable int POIFOUND = 0
		variable int Index = 0
		POIFOUND:Set[${LNavRegionGroup[${POITYPE}].RegionsWithin[MerchantPOI,100000,${Me.X},${Me.Y},${Me.Z}]}]
		while ${MerchantPOI.Get[${Index:Inc}](exists)}
		{
			if  ${GotoFQN.Equal[${MerchantPOI.Get[${Index}].FQN}]}
			{
				Navigator:MoveToLoc[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}]
				return
			}
		}
	}
	method BlacklistAddPOI()
	{
		if ${UIElement[tlbPOIs@Blacklist@POIPages@POIs@Pages@Cerebrum].SelectedItem(exists)}
		{
			variable string myval=${UIElement[tlbPOIs@Blacklist@POIPages@POIs@Pages@Cerebrum].SelectedItem}
			GlobalBlacklist:Insert[${myval.Upper},-1]
		}
		This:PopulatePOIs
	}
	method BlacklistRemovePOI()
	{
		if ${UIElement[tlbPOIsBL@Blacklist@POIPages@POIs@Pages@Cerebrum].SelectedItem(exists)}
		{
			variable string myval=${UIElement[tlbPOIsBL@Blacklist@POIPages@POIs@Pages@Cerebrum].SelectedItem}
			GlobalBlacklist:Remove[${myval.Upper}]
			This:Output[Removed from Blacklist: ${myval.Upper}]
		}
		This:PopulatePOIs
	}
	
	method ManualBlacklistPOI()
	{
		if ${UIElement[tenManualBL@Blacklist@POIPages@POIs@Pages@Cerebrum].Text(exists)}
		{
			variable string myval=${UIElement[tenManualBL@Blacklist@POIPages@POIs@Pages@Cerebrum].Text}
			GlobalBlacklist:Insert[${myval.Upper},-1]
			UIElement[tenManualBL@Blacklist@POIPages@POIs@Pages@Cerebrum]:SetText[]
		}
		This:PopulatePOIs
	}
	
	method ManualBlacklistPOITarget()
	{
		GlobalBlacklist:Insert["${Target.Name.Upper}",-1]
		This:PopulatePOIs
	}
	
	method TestBest(string GUID, string POITYPE)
	{
		if ${This.IsBetterPOI[${GUID}, ${POITYPE}]}
		{
			This:JustClear
			This:Output[Better ${POITYPE} found. Temp clearing POI.]
		}
	}

	member IsBetterPOI(string GUID, string POITYPE)
	{
		if ${POI.Type.NotEqual[${POITYPE}]}
		{
			return FALSE
		}
		if ${Object[${GUID}].Distance} >= ${POI.Distance} 
		{
			return FALSE
		}
		if ${GlobalBlacklist.Exists[${GUID}]} || !${GlobalBlacklist.Exists[${Object[${GUID}].Name}]} 
		{
			return FALSE
		}
		if ${Navigator.AvailablePath[${Object[${GUID}].X},${Object[${GUID}].Y},${Object[${GUID}].Z}]}
		{
			return TRUE
		}
		return FALSE
	}

	member GetMetaType(string POITYPE)
	{
		if ${This.MetaTypeGroup.Element[${POITYPE}](exists)}
		{
			return ${This.MetaTypeGroup.Element[${POITYPE}]}
		}
		return UNKNOWN
	}
	;****************************************************************************************
	;***	Low-Level POI routines				END	 																							***
	;****************************************************************************************









	;****************************************************************************************
	;***	GUI POI routines							START																							***
	;****************************************************************************************
	method PopulatePOIs(string GUID)
	{
		variable string POITYPE = ${UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum].SelectedItem}
		UIElement[tlbPOIsBL@Blacklist@POIPages@POIs@Pages@Cerebrum]:ClearItems
		UIElement[tlbPOIs@Blacklist@POIPages@POIs@Pages@Cerebrum]:ClearItems

		if ${POITYPE.Equal[ALL_BLACKLISTED]}
		{
			variable iterator BlacklistIterator
			variable string BlacklistedItem
			LavishSettings[Blacklist].FindSet[IDs]:GetSettingIterator[BlacklistIterator]
			if ${BlacklistIterator:First(exists)}				
			{
				do
				{
					if ${BlacklistIterator.Value} == -1
					{
						BlacklistedItem:Set[${BlacklistIterator.Key}]
						UIElement[tlbPOIsBL@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[${BlacklistedItem.Lower}]				
					}
				}
				while ${BlacklistIterator:Next(exists)}
			}			
			return
		}
		
		if ${POITYPE.NotEqual[NULL]}
		{
			variable index:lnavregionref MerchantPOI
			variable int POIFOUND = 0
			variable int Index = 0
			variable string UnitName
			POIFOUND:Set[${LNavRegionGroup[${UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum].SelectedItem}].RegionsWithin[MerchantPOI,100000,${Me.X},${Me.Y},${Me.Z}]}]
			while ${MerchantPOI.Get[${Index:Inc}](exists)}
			{
				if ${GlobalBlacklist.Exists[${MerchantPOI.Get[${Index}].FQN}]}
				{
					if ${Navigator.AvailablePath[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}]}
					{
						UIElement[tlbPOIsBL@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[${MerchantPOI.Get[${Index}].FQN.Upper}]
					}
					else
					{
						UIElement[tlbPOIsBL@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[${MerchantPOI.Get[${Index}].FQN.Lower}]
					}
				}
				else
				{
					if ${Navigator.AvailablePath[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}]}
					{
						UIElement[tlbPOIs@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[${MerchantPOI.Get[${Index}].FQN.Upper}]
					}
					else
					{
						UIElement[tlbPOIs@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[${MerchantPOI.Get[${Index}].FQN.Lower}]
					}
				}

				if ${GlobalBlacklist.Exists[${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[GUID]}]}
				{
					if ${Navigator.AvailablePath[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}]}
					{
						UIElement[tlbPOIsBL@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[GUID].Upper}]
					}
					else
					{
						UIElement[tlbPOIsBL@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[${LNavRegionGroup["${POITYPE}"].NearestRegion[${MerchantPOI.Get[${Index}].Region.CenterPoint.X},${MerchantPOI.Get[${Index}].Region.CenterPoint.Y},${MerchantPOI.Get[${Index}].Region.CenterPoint.Z}].Custom[GUID].Lower}]
					}
				}
			}
		}
	}

	;****************************************************************************************
	;***	GUI POI routines							END																								***
	;****************************************************************************************

	method Initialize()
	{
		/* create meta groups */
		;NPC
		This.MetaTypeGroup:Set[SELL,NPC]
		This.MetaTypeGroup:Set[REPAIR,NPC]
		This.MetaTypeGroup:Set[INNKEEPER,NPC]
		This.MetaTypeGroup:Set[FLIGHTMASTER,NPC]
		This.MetaTypeGroup:Set[BANKER,NPC]
		This.MetaTypeGroup:Set[AUCTIONEER,NPC]
		This.MetaTypeGroup:Set[SPIRITHEALER,NPC]
		This.MetaTypeGroup:Set[Skinning_TRAINER,NPC]
		This.MetaTypeGroup:Set[Herbalism_TRAINER,NPC]
		This.MetaTypeGroup:Set[Mining_TRAINER,NPC]
		This.MetaTypeGroup:Set[MAILBOX,NPC]
		This.MetaTypeGroup:Set[QUESTNPC,NPC]
		This.MetaTypeGroup:Set[${Me.Class}_TRAINER,NPC]
		;Loot
		This.MetaTypeGroup:Set[LOOT,LOOT]
		This.MetaTypeGroup:Set[SKINNING,LOOT]
		This.MetaTypeGroup:Set[MINING,LOOT]
		This.MetaTypeGroup:Set[HERBALISM,LOOT]
		This.MetaTypeGroup:Set[QUESTOBJECT,LOOT]		
		;Corpse
		This.MetaTypeGroup:Set[CORPSE,CORPSE]
		;Mob
		This.MetaTypeGroup:Set[MOB,MOB]
		;Roam
		This.MetaTypeGroup:Set[GROUP,ROAM]		
		This.MetaTypeGroup:Set[HOTSPOT,ROAM]
	}
	
}


