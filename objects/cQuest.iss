;cQuest - Active Questing

objectdef oRecord inherits cBase
{
	variable bool Waiting = FALSE
	variable bool IsEnd
	variable int TimeOut = 0
	variable string Name
	
	method Initialize()
	{
	}
	
	method Complete()
	{
		Name:Set[${WoWScript[GetTitleText()]}]
		IsEnd:Set[TRUE]
		NewItem:Set[]
		Record:Record
		Quest:Save
	}
	
	method Start()
	{
		Name:Set[${WoWScript[GetTitleText()]}]
		IsEnd:Set[FALSE]
		NewItem:Set[]
		Record:Record
		Quest:Save
	}
	
	method WeightInc()
	{
		variable string ID
		ID:Set[${UIElement[tlbQuests@Quest@HumanPages@Human@Pages@Cerebrum].SelectedItem}]
		ID:Set[${ID.Token[2,#]}]
		LavishSettings[Quests].FindSet[${ID}]:AddSetting[Weight,${Math.Calc[${LavishSettings[Quests].FindSet[${ID}].FindSetting[Weight]}+10].Round}]
		LavishSettings[QuestLog].FindSet[${ID}]:AddSetting[Weight,${Math.Calc[${LavishSettings[Quests].FindSet[${ID}].FindSetting[Weight]}+10].Round}]
		This:Output[Increasing Weight for ${LavishSettings[Quests].FindSet[${ID}].FindSetting[Name]}.. (+10)]
		Play:LoadQuest
	}
	
	method WeightDec()
	{
		variable string ID
		ID:Set[${UIElement[tlbQuests@Quest@HumanPages@Human@Pages@Cerebrum].SelectedItem}]
		ID:Set[${ID.Token[2,#]}]
		LavishSettings[Quests].FindSet[${ID}]:AddSetting[Weight,${Math.Calc[${LavishSettings[Quests].FindSet[${ID}].FindSetting[Weight]}-10].Round}]
		LavishSettings[QuestLog].FindSet[${ID}]:AddSetting[Weight,${Math.Calc[${LavishSettings[Quests].FindSet[${ID}].FindSetting[Weight]}-10].Round}]
		This:Output[Deccreasing Weight for ${LavishSettings[Quests].FindSet[${ID}].FindSetting[Name]}.. (-10)]
		Play:LoadQuest
	}
	
	method SetNeutral()
	{
		variable string ID
		ID:Set[${UIElement[tlbQuests@Quest@HumanPages@Human@Pages@Cerebrum].SelectedItem}]
		ID:Set[${ID.Token[2,#]}]
		LavishSettings[Quests].FindSet[${ID}]:AddSetting[Faction, Neutral]
		This:Output[Setting Quest ${LavishSettings[Quests].FindSet[${ID}].FindSetting[Name]} as neutral]
		Play:LoadQuest
	}
	
	method SetAlliance()
	{
		variable string ID
		ID:Set[${UIElement[tlbQuests@Quest@HumanPages@Human@Pages@Cerebrum].SelectedItem}]
		ID:Set[${ID.Token[2,#]}]
		LavishSettings[Quests].FindSet[${ID}]:AddSetting[Faction, Alliance]
		This:Output[Setting Quest ${LavishSettings[Quests].FindSet[${ID}].FindSetting[Name]} as Alliance only]
		Play:LoadQuest
	}
	
	method SetHorde()
	{
		variable string ID
		ID:Set[${UIElement[tlbQuests@Quest@HumanPages@Human@Pages@Cerebrum].SelectedItem}]
		ID:Set[${ID.Token[2,#]}]
		LavishSettings[Quests].FindSet[${ID}]:AddSetting[Faction, Horde]
		This:Output[Setting Quest ${LavishSettings[Quests].FindSet[${ID}].FindSetting[Name]} as Horde only]
		Play:LoadQuest
	}
	
	method Record()
	{
		if !${Waiting}
		{
			Play:PopulateQuests
			Waiting:Set[TRUE]
			TimeOut:Set[0]
		}
		else
		{
			if ${Quest.QuestIsLogged[${Name}]}
			{
				variable int Level = ${Me.Quest[${Name}].Level}
				variable string ID = ${Me.Quest[${Name}].ID}
				variable string QuestArea = ${Me.Quest[${Name}].Area}
				
				if ${IsEnd}
				{
					This:Output[Ending Quest: ${Name}]
					if ${UIElement[chkRecordQuest@Quest@HumanPages@Human@Pages@Cerebrum].Checked}
					{
						LavishSettings[Quests].FindSet[${ID}]:AddSetting[EndXYZ, "${Me.Location}"]
						Record:SetLocation[${Quest.QuestString[${Name}]},${Math.Calc[${Quest.QuestLevel[${QuestNo}]} - 1]},${Math.Calc[${Me.Level}+1]},50,FALSE]
					}
					else
					{
						Record:SetLocation[${Quest.QuestString[${Name}]},-100,-100,-100,FALSE]
					}
					LavishSettings[QuestLog].FindSet[${ID}]:AddSetting[Complete, TRUE]
				}
				else
				{
					This:Output[Starting Quest: ${Name}]
					if ${UIElement[chkRecordQuest@Quest@HumanPages@Human@Pages@Cerebrum].Checked}
					{
						LavishSettings[Quests]:AddSet[${ID}]
						LavishSettings[Quests].FindSet[${ID}]:AddSetting[Name, ${Name}]
						LavishSettings[Quests].FindSet[${ID}]:AddSetting[Faction, ${Me.FactionGroup}]
						LavishSettings[Quests].FindSet[${ID}]:AddSetting[Level, ${Level}]
						LavishSettings[Quests].FindSet[${ID}]:AddSetting[Area, ${Area}]
						LavishSettings[Quests].FindSet[${ID}]:AddSetting[Type, ${Quest.QuestType[${Name}]}]
						if ${Quest.NewItem.Length} > 0
						{
							This:Output[Linking Item: ${Quest.NewItem}]
							LavishSettings[Quests].FindSet[${ID}]:AddSetting[Item,${Quest.NewItem}]			
						}
						if !${LavishSettings[Quests].FindSet[${ID}].FindSetting[Weight](exists)}
						{
							LavishSettings[Quests].FindSet[${ID}]:AddSetting[Weight, 0]
						}
						LavishSettings[Quests].FindSet[${ID}]:AddSetting[StartXYZ, "${Me.Location}"]
						if !${LavishSettings[Quests].FindSet[${ID}].FindSetting[EndXYZ](exists)}
						{
							LavishSettings[Quests].FindSet[${ID}]:AddSetting[EndXYZ, "${Me.Location}"]
						}
						Record:SetLocation[${Quest.QuestString[${Name}]},${Math.Calc[${Level} - 1]},${Math.Calc[${Level} + ${WoWScript[GetQuestGreenRange()]}]},30,TRUE]
					}
					else
					{
						Record:SetLocation[${Quest.QuestString[${Name}]},-100,-100,-100,TRUE]
					}
					LavishSettings[QuestLog]:AddSet[${ID}]
					LavishSettings[QuestLog].FindSet[${ID}]:AddSetting[Name, ${Name}]
					LavishSettings[QuestLog].FindSet[${ID}]:AddSetting[Complete, FALSE]
					LavishSettings[QuestLog].FindSet[${ID}]:AddSetting[Weight, ${LavishSettings[Quests].FindSet[${ID}].FindSetting[Weight]}]
					variable int i
					variable int j
					for (i:Set[1]; ${i}<=${WoWScript[GetNumQuestLogEntries(),1]}; i:Inc)
					{
						if ${WoWScript[GetQuestLogTitle(${i}),1].Equal[${Name}]}
						{
							for (j:Set[1]; ${j}<=${WoWScript[GetNumQuestLeaderBoards(${i})]}; j:Inc)
							{
								LavishSettings[QuestLog].FindSet[${ID}]:AddSet[Objective ${j}]
								LavishSettings[QuestLog].FindSet[${ID}].FindSet[Objective ${j}]:AddSetting[Description, ${WoWScript["GetQuestLogLeaderBoard(${j},${i})",1]}]
							}
						}
					}

				}
				Waiting:Set[FALSE]
			}
			else
			{
				TimeOut:Inc
				This:Output[Waiting for Quest Log to update... (${TimeOut}/30)]
				if ${TimeOut} > 30
				{
					This:Output[ERROR: Record timed out. ${Name} needs to be added again.]
					WoWScript "QuestFrame:Hide()"
					Quest.NewItem:Set[]
					Waiting:Set[FALSE]
				}
			}
		}
	}
	
	method AddHotspot(string Name)
	{
		Mapper:MapLocation[${Me.Location}]
		variable settingsetref LS = ${LavishSettings[Location].FindSet[Hunting].FindSet[${Quest.QuestString[${Name}]}].FindSet[Hotspots]}
		variable string XYZ
		variable int X
		variable int Y
		variable int Z
		variable int Hd
		variable string HotspotName
		
		XYZ:Set[${Me.X}]
		X:Set[${XYZ.Token[1,.]}]
		XYZ:Set[${Me.Y}]
		Y:Set[${XYZ.Token[1,.]}]
		XYZ:Set[${Me.Z}]
		Z:Set[${XYZ.Token[1,.]}]
		XYZ:Set[${Me.Heading}]
		Hd:Set[${XYZ.Token[1,.]}]
		X:Inc
		Y:Inc
		Z:Inc
		Hd:Inc
		
		XYZ:Set["${X}:${Y}:${Z}:${Hd}"]

		variable int HC=${LavishSettings[Location].FindSet[Hunting].FindSet[${Quest.QuestString[${Name}]}].FindSet[Attributes].FindSetting[HotspotsCount]}
		HC:Inc
		HotspotName:Set[${Name} ${HC}]
		variable iterator HotspotIterator1
		
		variable settingsetref LS1 = ${LavishSettings[Location].FindSet[Hunting].FindSet[${Quest.QuestString[${Name}]}].FindSet[Hotspots]}
		LS1:GetSettingIterator[HotspotIterator1]
			
		if ${HotspotIterator1:First(exists)}
		{
			do
			{
				if ${XYZ.Equal[${HotspotIterator1.Key}]}
				{
					Location:Output[You already have a Hotspot for this LocationSet here !]
					return
				}
				if ${HotspotName.Equal[${HotspotIterator1.Value}]}
				{
					Location:Output[You already have a Hotspot for this LocationSet with a similar Name !]
					return
				}
			} 
			while ${HotspotIterator1:Next(exists)}
		}

		LavishSettings[Location].FindSet[Hunting].FindSet[${Quest.QuestString[${Name}]}].FindSet[Attributes]:AddSetting[HotspotsCount,${HC}]
		LS:AddSetting[${XYZ},${HotspotName}]
		This:Output[Added Hotspot ${HotspotName} @ ${XYZ}]
		Location:addDropdown[${XYZ}]
		Location:populateHotspots
		Grind:RefreshCurrent
	}
	
	method SetLocation(string LocName, int LvlFrom, int LvlTo, int GrindRange, bool Active)
	{
		if ${LvlTo} != -100
		{
			if ${LvlTo} > ${Bot.LvlCap}
			{
				LvlTo:Set[${Bot.LvlCap}]
			}
		}
		if ${LvlFrom} != -100
		{
			if ${LvlFrom} <= 0
			{
				LvlFrom:Set[1]
			}
		}
		LavishSettings[Location].FindSet[Hunting]:AddSet[${LocName}]
		LavishSettings[Location].FindSet[Hunting].FindSet[${LocName}]:AddSet[Hotspots]
		LavishSettings[Location].FindSet[Hunting].FindSet[${LocName}].FindSet[Hotspots]:AddComment[Comment Needed to keep empty sets]
		LavishSettings[Location].FindSet[Hunting].FindSet[${LocName}]:AddSet[Attributes]
		if ${LvlFrom} != -100
		{
			LavishSettings[Location].FindSet[Hunting].FindSet[${LocName}].FindSet[Attributes]:AddSetting[LvlFrom,${LvlFrom}]
		}
		if ${LvlTo} != -100
		{
			LavishSettings[Location].FindSet[Hunting].FindSet[${LocName}].FindSet[Attributes]:AddSetting[LvlTo,${LvlTo}]
		}
		if ${GrindRange} != -100
		{
			LavishSettings[Location].FindSet[Hunting].FindSet[${LocName}].FindSet[Attributes]:AddSetting[GrindRange,${GrindRange}]
		}
		LavishSettings[Location].FindSet[Hunting].FindSet[${LocName}].FindSet[Attributes]:AddSetting[Active,${Active}]
	}
}

objectdef oPlay inherits cBase
{
	variable int CurrentAOI = 1
	variable int AOITimer
	variable bool Override = FALSE
	
	method Initialize()
	{
		Quest:RecordProgress
		LavishSettings[QuestLog]:AddSet[Step]
		LavishSettings[QuestLog].FindSet[Step]:AddSetting[Current, 1]
		variable int StepCount = 0
	}
	method onStep()
	{

	WindowText  I'm On Step ${This.CurrentStep} and It's Type is ${This.StepType} : Status is ${This.StepStatus} | ${Bot.StatusText} | ${This.StepPoi}
			
	}	
	member StateOverride()
	{
		;echo Checking Override
		if ${Override} && !${Me.Ghost}
			;Return TRUE
			Return FALSE
		else
			Return FALSE
	}
	member CurrentStep()
	{
			/* Lets start at last known Step */
		variable int Current = ${LavishSettings[QuestLog].FindSet[Step].FindSetting[Current]} 
		return ${Current}
	}
	member StepType()
	{
		variable string SType = ${LavishSettings[QuestSteps].FindSet[${This.CurrentStep}].FindSetting[StepType]} 
		return ${SType}
	}
	member StepPoi()
	{
		variable string SName = ${LavishSettings[Quests].FindSet[${This.StepID}].FindSetting[StartXYZ]}
		return ${SName}
	}
	member StepID()
	{
		variable string SID = ${LavishSettings[QuestSteps].FindSet[${This.CurrentStep}].FindSetting[Quest]} 
		return ${SID}
	}
	member QuestLogStatus()
	{
		variable string QLS = ${LavishSettings[QuestLog].FindSet[${This.StepID}].FindSetting[Complete]} 
		return ${QLS}
	}
	member QuestLogName()
	{
		variable string QLN = ${LavishSettings[QuestLog].FindSet[${This.StepID}].FindSetting[Name]} 
		return ${QLN}
	}

	member StepStatus()
	{
		/*    Lets Check Pickups   */
		if ${This.StepType.Equal[Pickup]} && !${This.QuestLogStatus.Equal[TRUE]} && ${This.QuestLogStatus(exists)} 
			if ${This.QuestInLog.Equal[PickedUp]}
			{
				Play:AdvanceStep
			}
			else
			{
				Override:Set[TRUE]
				Play:PickUp[${This.StepID}]
				return Need to Pick up ${This.QuestLogName} 
			}
		if ${This.StepType.Equal[Pickup]} && ${This.QuestLogStatus.Equal[TRUE]} && ${This.QuestLogStatus(exists)} 
		{
			Play:AdvanceStep
		}
		/*    Lets Check Turnins   */
		if ${This.StepType.Equal[TurnIn]} && !${This.QuestLogStatus.Equal[TRUE]}
		{
			if ${This.QuestInLog.Equal[PickedUp]} && !${Bot.StatusText.Equal[Loot Move To Loot]} && !${Me.Ghost} && !${State.StateName.Equal[REST]} && !${State.StateName.Equal[COMBAT]}

			{
				Override:Set[TRUE]
				Play:HandIn[${This.StepID}]
				return Turning in ${This.QuestLogName} 
			}
			else
			{
				Override:Set[TRUE]
				;Play:PickUp[${This.StepID}]	
				;Play:AdvanceStep
				return Confused Steps out or Order : Pickup ${This.QuestLogName} 
			}
		}
		if ${This.StepType.Equal[TurnIn]} && ${This.QuestLogStatus.Equal[TRUE]}
		{
			Play:AdvanceStep
		}
		/*    Lets Check Performs   */
		if ${This.StepType.Equal[Perform]} && !${This.QuestLogStatus.Equal[TRUE]}
		{
			if ${Quest.IsComplete[${This.StepID}]}
			{
				Play:AdvanceStep
				return Done with ${This.QuestLogName} Advancing to next step

			}
			else
			{
				;Grind.CurrentGrind:Set[${This.QuestLogName}]
				return Need to Perform ${This.QuestLogName} Now
			}
		}
		/*  Look for End of Steps  */
		if !${LavishSettings[QuestSteps].FindSet[${This.CurrentStep}].FindSetting[StepType](exists)}
		{
			Override:Set[TRUE]
			return Oh Shit It's the end of my steps, I had better Logout
			endscript Cerebrum
		}


	}	
	method AdvanceStep()
	{
		variable int StepNum = ${This.CurrentStep}
		variable int NextStep = ${StepNum:Inc}
			Bot.ForcedStateWait:Set[${Bot.InTenths[${Bot.randomWait[${Bot.RandomPause}]}]}]
			Bot.RandomPause:Set[0]
				LavishSettings[QuestLog].FindSet[Step]:AddSetting[Current, ${NextStep}]
				echo Moving to Next Step 
	}
	member QuestInLog()
	{
		variable int i = 0
		do
		{
			if ${Me.Quest[${i}](exists)}
			{
				if ${Me.Quest[${i}].Name.Equal[${This.QuestLogName}]}
				{
					return PickedUp
				}
			}
		  i:Inc
		}
		while ${i} < 25
		Return Not Pickedup
		
	}
	method PopulateQuests()
	{
		variable int temp
		variable iterator QuestIterator
		variable int QuestLevel
		variable string QuestName
		variable string QuestFaction
		variable string QuestComplete
		
		UIElement[tlbQuests@Quest@HumanPages@Human@Pages@Cerebrum]:ClearItems
		LavishSettings[Quests]:GetSetIterator[QuestIterator]
		
		if ${QuestIterator:First(exists)}
		{
			do
			{
				QuestLevel:Set[${LavishSettings[Quests].FindSet[${QuestIterator.Key}].FindSetting[Level]}]
				QuestName:Set[${LavishSettings[Quests].FindSet[${QuestIterator.Key}].FindSetting[Name]}]
				QuestComplete:Set[${LavishSettings[QuestLog].FindSet[${QuestIterator.Key}].FindSetting[Complete]}]
				QuestFaction:Set[${LavishSettings[Quests].FindSet[${QuestIterator.Key}].FindSetting[Faction]}]
				if ${QuestLevel} >= ${Math.Calc[${Me.Level} - 1]} && ${QuestLevel} <= ${Math.Calc[${Me.Level} + ${WoWScript[GetQuestGreenRange()]}]} && (!${QuestComplete(exists)} || ${QuestComplete.NotEqual[TRUE]}) && (!${LavishSettings[Quests].FindSet[${QuestIterator.Key}].FindSetting[Faction](exists)} || ${QuestFaction.Equal[Neutral]} || ${QuestFaction.Equal[${Me.FactionGroup}]})
				{
					UIElement[tlbQuests@Quest@HumanPages@Human@Pages@Cerebrum]:AddItem["(${QuestLevel}) ${QuestName} #${QuestIterator.Key}"]
				}
			}
			while ${QuestIterator:Next(exists)}
		}
	}
	
	method LoadQuest()
	{
		variable string ID
		if ${UIElement[tlbQuests@Quest@HumanPages@Human@Pages@Cerebrum].SelectedItem(exists)}
		{
			ID:Set[${UIElement[tlbQuests@Quest@HumanPages@Human@Pages@Cerebrum].SelectedItem}]
			ID:Set[${ID.Token[2,#]}]
			UIElement[txtQuestString@Quest@HumanPages@Human@Pages@Cerebrum]:SetText[(${LavishSettings[Quests].FindSet[${ID}].FindSetting[Level]}) ${LavishSettings[Quests].FindSet[${ID}].FindSetting[Name]} ID: ${ID}]
			UIElement[txtQuestArea@Quest@HumanPages@Human@Pages@Cerebrum]:SetText[${LavishSettings[Quests].FindSet[${ID}].FindSetting[Area]}]
			UIElement[txtQuestType@Quest@HumanPages@Human@Pages@Cerebrum]:SetText[${LavishSettings[Quests].FindSet[${ID}].FindSetting[Type]}]
			UIElement[txtQuestItem@Quest@HumanPages@Human@Pages@Cerebrum]:SetText[${LavishSettings[Quests].FindSet[${ID}].FindSetting[Item]}]
			UIElement[txtQuestWeight@Quest@HumanPages@Human@Pages@Cerebrum]:SetText[${LavishSettings[Quests].FindSet[${ID}].FindSetting[Weight]}]
			UIElement[txtQuestFaction@Quest@HumanPages@Human@Pages@Cerebrum]:SetText[${LavishSettings[Quests].FindSet[${ID}].FindSetting[Faction]}]
		}
	}
	
	method FindAOI()
	{
		variable guidlist AOI
		AOI:Search[-gameobjects, -units, -nearest, -range 0-30]
		if ${AOI[${CurrentAOI}].Distance} > 5
		{
			Navigator:MoveToLoc[${AOI[${CurrentAOI}].Location}]
			return
		}
		else
		{
			Navigator:FaceXYZ[${AOI[${CurrentAOI}].Location}]
			target ${AOI[${CurrentAOI}]}
			if ${Item[${LavishSettings[Quests].FindSet[${ActiveID}].FindSetting[Item]}](exists)} && ${Item[${LavishSettings[Quests].FindSet[${ActiveID}].FindSetting[Item]}].Usable}
			{
				This:Output[Trying to use ${LavishSettings[Quests].FindSet[${ActiveID}].FindSetting[Item].Name} on ${AOI[${CurrentAOI}].Name}]
				Item[${LavishSettings[Quests].FindSet[${ActiveID}].FindSetting[Item]}]:Use
			}
			else
			{
				This:Output[Trying to use ${AOI[${CurrentAOI}].Name}]
				AOI[${CurrentAOI}]:Use
			}
		}
		if ${Quest.GetTimer[${AOITimer},5000]} 
		{
			AOITimer:Set[${LavishScript.RunningTime}]
			if ${AOI[${Math.Calc[${CurrentAOI}]+1]}](exists)}
			{
				CurrentAOI:Inc
			}
			else
			{
				if ${Questgiver.GossipVisible}
				{
					This:Output[Talking to ${AOI[${CurrentAOI}].Name}]
					WoWScript "SelectGossipOption(1)"
				}
				else
				{
					This:Output[Tried All available objects. Removing Weight]
					LavishSettings[QuestLog].FindSet[${ActiveID}]:AddSetting[Weight,${Math.Calc[${Weight}-50]}]
					CurrentAOI:Set[1]
				}
			}
		}
	}
	
	method SwitchLoc(int ID)
	{
		Grind.CurrentGrind:Set[${Quest.QuestString[${Quest.IDtoName[${ID}]}]}]
		;Grind.CurrentGrind:Set[${This.QuestLogName}]
;This:Output[Switching LocationSet for Questing: ${Quest.IDtoName[${ID}]}]

		This:Output[Switching LocationSet for Questing: ${Quest.IDtoName[${ID}]}]
	}
	
	method HandIn(int ID)
	{
		variable guidlist NPCsWithTurnIn
		variable point3f EndNPC
		EndNPC:Set[${LavishSettings[Quests].FindSet[${ID}].FindSetting[EndXYZ]}]
		variable int Weight = ${LavishSettings[QuestLog].FindSet[${ID}].FindSetting[Weight]}
		NPCsWithTurnIn:Clear
		NPCsWithTurnIn:Search[-units, -nearest, -nonhostile, -questcomplete, -lineofsight, -range 0-30]
		if ${Movement.Speed}
		{
			return
		}
	if ${Math.Distance[${Me.Location},${EndNPC}]} < 2
		{
			Override:Set[FALSE]

		}
		if ${Math.Distance[${Me.Location},${EndNPC}]} < 10
		{
			if ${NPCsWithTurnIn.Count} == 0
			{
				This:Output[At expected hand in location but the NPC I need to turn it in to isn't here. Lowering Weight.]
				LavishSettings[QuestLog].FindSet[${ID}]:AddSetting[Weight,${Math.Calc[${Weight}-10]}]
			}
			return
		}
		if ${NPCsWithTurnIn.Count} == 0
		{
			This:Output[${LavishSettings[Quests].FindSet[${ID}].FindSetting[Name]} Complete. Moving to hand in location]
This:Output[ID: ${ID} Name: ${Me.Quest[${Quest.IDtoName[${QuestID}]}]}]
			Navigator:MoveToLoc[${EndNPC}]
		}
	}

method PickUp(int ID)
	{
		variable point3f StartNPC
		StartNPC:Set[${LavishSettings[Quests].FindSet[${ID}].FindSetting[StartXYZ]}]
echo Pickingup
			Navigator:MoveToLoc[${StartNPC}]
		if ${Math.Distance[${Me.Location},${StartNPC}]} < 2
		{
			Override:Set[FALSE]
		}
	
	}

		
	member BestQuest()
	{
		variable int i = 0
		variable int ActiveQuest = 0
		variable int BestWeight
		variable int Weight = -1000
		variable string QuestType
		do
		{
			if ${Me.Quest[${i}](exists)}
			{
				Weight:Set[${LavishSettings[QuestLog].FindSet[${Me.Quest[${i}].ID}].FindSetting[Weight]}]
				if ${Me.Quest[${i}].Level} - ${Me.Level} > 2
				{
					Weight:Dec[100]
				}
				if ${Quest.IsComplete[${i}]}
				{
					if (${Me.Level} - ${Me.Quest[${i}].Level}) > (${WoWScript[GetQuestGreenRange()]}/2)
					{
						Weight:Inc[50]
					}
					if ${Quest.QuestDistance[${i}]} < 500
					{
						Weight:Inc[50]
					}
				}
				else
				{
					Weight:Inc[40]
				}
				if ${LavishSettings[Location].FindSet[Hunting].FindSet[${Quest.QuestString[${Me.Quest[${i}].Name}]}].FindSet[Attributes].FindSetting[HotspotsCount]} == 0 && ${Quest.SavedQuestType.NotEqual["Event"]}
				{
					QuestType:Set[${LavishSettings[Quests].FindSet[${Me.Quest[${i}].ID}].FindSetting[Type]}]
					if ${QuestType.Equal[EVENT]}
					{
						Weight:Inc[10]
					}
				}
				else
				{
					Weight:Inc[10]
				}
				if ${Grind.LocationSetName.Equal[${Quest.QuestString[${Me.Quest[${i}].Name}]}]}
				{
					Weight:Inc[10]
				}
				Weight:Inc[(${Me.Level}+2) - ${Me.Quest[${i}].Level}]
				;echo ${Me.Quest[${i}]} has weight ${Weight}
				if ${Weight} > ${BestWeight}
				{
					if ${Weight} >= 0
					{
						ActiveQuest:Set[${i}]
					}
					BestWeight:Set[${Weight}]
				}
			}
			i:Inc
		}
		while ${i} < 25
		if ${Me.Quest[${ActiveQuest}](exists)}
		{
			;return ${Me.Quest[${ActiveQuest}].ID}
			return ${Play.StepID}
		}
		else
		{
			return 0
		}
	}
}

objectdef oQuest inherits cBase
{
	variable string QuestDBFileName = "./config/QuestDB.xml"
	variable string QuestStepsFileName = "./config/${Me.FactionGroup}QuestSteps.xml"
	variable string QuestLogFileName = "./config/settings/${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Name}QuestLog.xml"
	variable int QuestID
	variable string NewItem
	variable int ActiveID
	variable string Step
	
	method Initialize()
	{
		LavishSettings:AddSet[Quests]
		LavishSettings:AddSet[Items]
		LavishSettings:AddSet[QuestLog]
		LavishSettings:AddSet[QuestSteps]
		
		LavishSettings[Quests]:Import[${QuestDBFileName}]
		LavishSettings[QuestLog]:Import[${QuestLogFileName}]
		LavishSettings[QuestSteps]:Import[${QuestStepsFileName}]

		Bot:AddPulse["Quest","Override",10,FALSE,FALSE]
		
		Event[QUEST_COMPLETE]:AttachAtom[Record:Complete]
		Event[QUEST_DETAIL]:AttachAtom[Record:Start]
		Event[BAG_UPDATE]:AttachAtom[Quest:ItemsUpdate]
		Event[QUEST_LOG_UPDATE]:AttachAtom[Quest:RecordProgress]
		
		Quest:ItemsUpdate
		Play:PopulateQuests
		
		echo Ritz's oQuest V2.1 Loaded
		echo Completed by MillertimeINC & Singularity
	}

	methode Override()
	{
		;echo Override 10 Frame Sensitivity.
		Play:LoadQuest
		Play:onStep
		
	}

	method RecordProgress()
	{
		if ${Quest.Progress}
		{
			/*
			WoWScript PlayerFrame:Hide()
			WoWScript RequestTimePlayed()
			WoWScript TakeScreenshot()
			WoWScript PlayerFrame:Show()
			*/
			if ${Quest.AwayFromQuestNPCs[${QuestID}]}
			{
				Location:QuickNote[${Me.Quest[${Quest.IDtoName[${QuestID}]}]}]
				if !${Quest.TooClose[${QuestID}]}
				{
					if ${UIElement[chkRecordQuest@Quest@HumanPages@Human@Pages@Cerebrum].Checked}
					{
						This:Output[Recording new hotspot for ${Me.Quest[${Quest.IDtoName[${QuestID}]}]}]
						Record:AddHotspot[${Quest.IDtoName[${QuestID}]}]
					}
					else
					{
						This:Output[Recording turned off: No new hotspot]
					}
				}
				else
				{
					This:Output[Too close to another hotspot: No new hotspot]
				}
			}
			else
			{
				This:Output[Too close to a quest NPC: No new hotspot]
			}
		}
	}
	
	variable int TimeOut
	
	method Pulse()
	{
		if ${Questgiver.GossipVisible}
		{
			TimeOut:Inc
			if ${TimeOut} > 30
			{
				WoWScript "QuestFrame:Hide()"
				TimeOut:Set[0]
			}
		}
		else
		{
			TimeOut:Set[0]
		}
		if ${Record.Waiting}
		{
			Record:Record
		}
	}
	
	member BeginsQuest(string ItemID)
	{
		variable oItemTT bagTT
		bagTT:GetBagSlot[${Item[${ItemID}].Bag.Number},${Item[${ItemID}].Slot}]
		if ${ItemTT.BeginsQuest}
		{
			return TRUE
		}
		return FALSE
	}
	
	method ItemsUpdate()
	{
		Bot.RandomPause:Set[14]
		variable guidlist lstItemList
		variable int i = 1
		variable oItemTT bagTT
		lstItemList:Search[-items,-inventory]
		if ${lstItemList.Count}
		{
			do
			{
				if !${LavishSettings[Items].FindSet[${Item[${lstItemList.GUID[${i}]}].Name}](exists)}
				{
					if ${Record.Waiting}
					{
						NewItem:Set[${Item[${lstItemList.GUID[${i}]}].Name}]
						return
					}
					else
					{
						bagTT:GetBagSlot[${Item[${lstItemList.GUID[${i}]}].Bag.Number},${Item[${lstItemList.GUID[${i}]}].Slot}]
						if ${bagTT.BeginsQuest}
						{
							This:Output[Picked up a Quest-start Item]
							Item[${lstItemList.GUID[${i}]}]:Use
						}
						LavishSettings[Items]:AddSet[${Item[${lstItemList.GUID[${i}]}].Name}]
					}
				}
			}
			while ${i:Inc}<=${lstItemList.Count}
		}
		if !${Record.Waiting}
		{
			NewItem:Set[""]
		}
	}
	
	member Progress()
	{
		variable int i
		variable int j
		for (i:Set[1]; ${i}<=${WoWScript[GetNumQuestLogEntries(),1]}; i:Inc)
		{
			if ${LavishSettings[QuestLog].FindSet[${Me.Quest[${WoWScript[GetQuestLogTitle(${i}),1]}].ID}](exists)} && ${Script.RunningTime} > 10000
			{
				for (j:Set[1]; ${j}<=${WoWScript[GetNumQuestLeaderBoards(${i})]}; j:Inc)
				{
					if ${WoWScript["GetQuestLogLeaderBoard(${j},${i})",1].NotEqual[${LavishSettings[QuestLog].FindSet[${Me.Quest[${WoWScript[GetQuestLogTitle(${i}),1]}].ID}].FindSet[Objective ${j}].FindSetting[Description]}]} || ${WoWScript["GetQuestLogLeaderBoard(${j},${i})",3].NotEqual[${LavishSettings[QuestLog].FindSet[${Me.Quest[${WoWScript[GetQuestLogTitle(${i}),1]}].ID}].FindSet[Objective ${j}].FindSetting[Completed]}]}
					{
						This:Output[${LavishSettings[QuestLog].FindSet[${Me.Quest[${WoWScript[GetQuestLogTitle(${i}),1]}].ID}].FindSet[Objective ${j}].FindSetting[Description]} -> ${WoWScript["GetQuestLogLeaderBoard(${j},${i})",1]}]
						LavishSettings[QuestLog].FindSet[${Me.Quest[${WoWScript[GetQuestLogTitle(${i}),1]}].ID}].FindSet[Objective ${j}]:AddSetting[Description, ${WoWScript["GetQuestLogLeaderBoard(${j},${i})",1]}]
						if ${WoWScript["GetQuestLogLeaderBoard(${j},${i})",3]}
						{
							LavishSettings[QuestLog].FindSet[${Me.Quest[${WoWScript[GetQuestLogTitle(${i}),1]}].ID}].FindSet[Objective ${j}]:AddSetting[Completed, 1]
						}
						else
						{
							LavishSettings[QuestLog].FindSet[${Me.Quest[${WoWScript[GetQuestLogTitle(${i}),1]}].ID}].FindSet[Objective ${j}]:AddSetting[Completed, 0]
						}
						QuestID:Set[${Me.Quest[${WoWScript[GetQuestLogTitle(${i}),1]}].ID}]
						return TRUE
					}
				}
			}
		}
		return FALSE
	}
	
	member QuestString(string Name)
	{
		return "(${Me.Quest[${Name}].Level}) ${Name} ID: ${Me.Quest[${Name}].ID}"
	}
	
	member AwayFromQuestNPCs(int ID)
	{
		if ${Quest.QuestDistance[${ID}]} < 10 || ${Quest.QuestDistance[${ID},FALSE]} < 10
		{
			return FALSE
		}
		return TRUE
	}
	
	member TooClose(int ID)
	{
		variable int i
		for (i:Set[1]; ${i}<=${LavishSettings[Location].FindSet[Hunting].FindSet[${Quest.QuestString[${Me.Quest[${Quest.IDtoName[${ID}]}].Name}]}].FindSet[Attributes].FindSetting[HotspotsCount]}; i:Inc)
		{
			if ${Grind.HotSpotDistance} < 30
			{
				return TRUE
			}
			Grind:NextHotspot
		}
		return FALSE
	}
	
	member QuestType(string Name)
	{
		if ${Me.Quest[${Name}].RequiredSlaughters} > 0
		{
			if ${Me.Quest[${Name}].RequiredItems} > 0
			{
				return ITEM_KILL
			}
			else
			{
				return KILL
			}
		}
		elseif ${Me.Quest[${Name}].RequiredItems} > 0
		{
			return ITEM
		}
		else
		{
			return EVENT
		}
	}
	
	member QuestLoc(int ID)
	{
		if ${Grind.LocationSetName.Equal[${Quest.QuestString[${Me.Quest[${Quest.IDtoName[${ID}]}].Name}]}]} && ${LavishSettings[Location].FindSet[Hunting].FindSet[${Quest.QuestString[${Me.Quest[${Quest.IDtoName[${ID}]}].Name}]}].FindSet[Attributes].FindSetting[Active].String.Equal[TRUE]}
		{
			return TRUE
		}
		return FALSE
	}
	
	member SavedQuestType(int ID)
	{
		return ${LavishSettings[Quests].FindSet[${ID}].FindSetting[Type]}
	}
	
	member QuestDistance(int ID, bool Start=TRUE)
	{
		variable point3f XYZ
		if ${Start}
		{
			XYZ:Set[${LavishSettings[Quests].FindSet[${ID}].FindSetting[StartXYZ]}]
		}
		else
		{
			XYZ:Set[${LavishSettings[Quests].FindSet[${ID}].FindSetting[EndXYZ]}]
		}
		return ${Math.Distance[${Me.Location},${XYZ}]}
	}
	
	method QuestWeight(int ID)
	{
		return ${LavishSettings[QuestLog].FindSet[${ID}].FindSetting[Weight]}
	}
	
	member QuestIsLogged(string Name)
	{
		variable int i
		for (i:Set[1]; ${i}<=${WoWScript[GetNumQuestLogEntries(),1]}; i:Inc)
		{
			if ${Name.Equal[${WoWScript[GetQuestLogTitle(${i}),1]}]}
			{
				return ${i}
			}
		}
		return FALSE
	}
	
	member IDtoName(int ID)
	{
		variable int i
		for (i:Set[1]; ${i}<=${WoWScript[GetNumQuestLogEntries(),1]}; i:Inc)
		{
			if ${Me.Quest[${WoWScript[GetQuestLogTitle(${i}),1]}].ID} == ${ID}
			{
				return ${WoWScript[GetQuestLogTitle(${i}),1]}
			}
		}
		return NULL
	}
	
	member IsComplete(int ID)
	{
		variable int i
		for (i:Set[1]; ${i}<=${WoWScript[GetNumQuestLogEntries(),1]}; i:Inc)
		{
			if ${Me.Quest[${WoWScript[GetQuestLogTitle(${i}),1]}].ID} == ${ID}
			{
				if ${WoWScript[GetQuestLogTitle(${i}),7]} == 1
				{
					return TRUE
				}
				if ${WoWScript[GetNumQuestLeaderBoards(${i})]} == 0
				{
					return TRUE
				}
				i:Set[30]
			}
		}
		return FALSE
	}
	
	member GetTimer(int Start, int Length = 0)
	{
		if ${Length} > 0
		{
			if ${Math.Calc[${LavishScript.RunningTime}-${Start}]} > ${Length}
			{
				return TRUE
			}
			else
			{
				return FALSE
			}
		}
		else
		{
			return ${Math.Calc[${LavishScript.RunningTime}-${Start}]}
		}
	}
	
	method Shutdown()
	{
		Quest:Save
		LavishSettings:Remove[QuestSteps]
		LavishSettings:Remove[Quests]
		LavishSettings:Remove[Items]
		LavishSettings:Remove[QuestLog]
	}
	
	method Save()
	{
		LavishSettings[Quests]:Export[${QuestDBFileName}]
		LavishSettings[QuestLog]:Export[${QuestLogFileName}]
	}
}

objectdef oQuestgiver inherits cBase
{
	variable int AcceptIndex
	variable int CompleteIndex
	
	method Initialize()
	{
	}

	member NeedPickup()
	{
		variable guidlist HasStart	
		variable int i
		variable string ID
		HasStart:Search[-units, -nearest, -nonhostile, -questavailable]
		for (i:Set[1]; ${i}<=${HasStart.Count}; i:Inc)
		{
			ID:Set[${HasStart.GUID[${i}]}]
			if ${Navigator.AvailablePath[${Object[${ID}].X},${Object[${ID}].Y},${Object[${ID}].Z}]} && !${GlobalBlacklist.Exists[${Object[${ID}].Name}]} && ${Play.StepType.Equal[pickup]} 
;&& ${Math.Distance[${Play.StepPoi},${Object[${ID}]}]} < 2
; && ${StepPoi.Equal[${Object[${ID}].Name}]}

			{
				echo Need Pickup 1
				POI.Current:Set[${ID}]
				return TRUE
			}
		}
		HasStart:Search[-gameobjects, -usable, -nearest, -questgiver]
		for (i:Set[1]; ${i}<=${HasStart.Count}; i:Inc)
		{
			ID:Set[${HasStart.GUID[${i}]}]
			if ${Navigator.AvailablePath[${Object[${ID}].X},${Object[${ID}].Y},${Object[${ID}].Z}]} && !${GlobalBlacklist.Exists[${Object[${ID}].Name}]} && ${Play.StepType.Equal[pickup]} 
;&& ${Math.Distance[${Play.StepPoi},${Object[${ID}]}]} < 2

; && ${StepPoi.Equal[${Object[${ID}].Name}]}

			{
				echo Need Pickup 2
				POI.Current:Set[${ID}]
				return TRUE
			}
		}
		return FALSE
	}
	
	member NeedHandIn()
	{
		variable guidlist HasEnd	
		variable int i
		variable string ID
		HasEnd:Search[-nearest, -nonhostile, -questcomplete]
		for (i:Set[1]; ${i}<=${HasEnd.Count}; i:Inc)
		{
			ID:Set[${HasEnd.GUID[${i}]}]
			if ${Navigator.AvailablePath[${Object[${ID}].X},${Object[${ID}].Y},${Object[${ID}].Z}]} && !${GlobalBlacklist.Exists[${Object[${ID}].Name}]} && ${Play.StepType.Equal[turnin]} 
;&& ${Math.Distance[${Play.StepPoi},${Object[${ID}]}]} < 2
;&& ${Play.StepType.Equal[turnin]} && ${StepPoi.Equal[${Object[${ID}].Name}]}

			{
				echo Need Pickup 3
				POI.Current:Set[${ID}]
				return TRUE
			}
		}
		HasStart:Search[-gameobjects, -usable, -nearest, -questgiver]
		for (i:Set[1]; ${i}<=${HasStart.Count}; i:Inc)
		{
			ID:Set[${HasStart.GUID[${i}]}]
			if ${Navigator.AvailablePath[${Object[${ID}].X},${Object[${ID}].Y},${Object[${ID}].Z}]} && !${GlobalBlacklist.Exists[${Object[${ID}].Name}]} && ${Play.StepType.Equal[turnin]} 
;&& ${Math.Distance[${Play.StepPoi},${Object[${ID}]}]} < 2
;&& ${Play.StepType.Equal[pickup]} && ${StepPoi.Equal[${Object[${ID}].Name}]}
			{
				echo Need Pickup 4
				POI.Current:Set[${ID}]
				return TRUE
			}
		}
		return FALSE
	}

	method CompleteGossip()
	{
		;echo ***********************
		;echo Completing a Quest
		;echo ***********************
		if ${WoWScript[GossipFrame:IsVisible()]}
		{
			;echo Gossip Frame Visible
			CompleteIndex:Set[1]
			do
			{
				if ${Quest.IsComplete[${Me.Quest[${WoWScript["GetGossipActiveQuests()",${CompleteIndex}]}].ID}]}
				{
					;echo Selecting ${WoWScript["GetGossipActiveQuests()",${CompleteIndex}]}
					WoWScript SelectGossipActiveQuest(${CompleteIndex})
					return
				}
			}
			while ${Me.Quest[${WoWScript["GetGossipActiveQuests()",${CompleteIndex:Inc}]}](exists)}
			return
		}
		if ${WoWScript[QuestFrame:IsVisible()]}
		{
			;echo Quest Frame Visible
			if ${WoWScript[GetTitleText()].Length} > 0
			{
				;echo Quest Selected
				Questgiver:Complete
				return
			}
			CompleteIndex:Set[1]
			do
			{
				if ${WoWScript["GetActiveTitle(${CompleteIndex})"](exists)} && ${Quest.IsComplete[${Me.Quest[${WoWScript["GetActiveTitle(${CompleteIndex})"]}].ID}]}
				{
					;echo Selecting Quest ${WoWScript["GetActiveTitle(${CompleteIndex})"]}
					WoWScript SelectActiveQuest(${CompleteIndex})
					return
				}
			}
			while ${WoWScript[GetActiveTitle(${CompleteIndex:Inc})](exists)}
		}
	}
		
	method AcceptGossip()
	{

		if ${WoWScript[GossipFrame:IsVisible()]}
		{
			;echo Gossip Frame Visible
			WoWScript SelectGossipAvailableQuest(1)
			return
		}
		if ${WoWScript[QuestFrame:IsVisible()]}
		{
			;echo Quest Frame Visible
			if ${WoWScript[GetTitleText()].Length} > 0
			{
				;echo Quest Selected
				Questgiver:Accept
				return
			}
			AcceptIndex:Set[1]
			do
			{
				if ${WoWScript["GetAvailableTitle(${AcceptIndex})"](exists)}
				{
					;echo Selecting Quest ${WoWScript["GetAvailableTitle(${AcceptIndex})"]}
					WoWScript SelectAvailableQuest(${AcceptIndex})
					return
				}
			}
			while ${WoWScript[GetAvailableTitle(${AcceptIndex:Inc})](exists)}
		}
	}

	method Gossip()
	{
		if !${POI.InUseRange}
		{
			Navigator:MoveToCurrentPOI
		}
		else
		{
			move -stop
			if !${Questgiver.GossipVisible}
			{
				POI:Use
			}
			else
			{
				if ${Object[${POI.GUID}].QuestStatus.Equal["COMPLETE"]}
				{
					Questgiver:CompleteGossip
					return
				}
				if ${Object[${POI.GUID}].QuestStatus.Equal["AVAILABLE-NOW"]}
				{
					Questgiver:AcceptGossip
					return
				}
				;echo POI ${Object[${POI.GUID}].Name} has fucked up. (${Object[${POI.GUID}].QuestStatus})
				WoWScript SelectGossipOption(${k})
				POI:Clear
			}
		}
	}

	method Complete()
	{
		This:Output[Completing a Quest]
		Bot.RandomPause:Set[30]
		variable int choice = ${Autoequip.GetBestRewardIndex}
		if ${choice} == 0
		{
			choice:Set[1]
		}
		WoWScript "GetQuestReward(${choice})"
		if ${WoWScript[IsQuestCompletable()]}
		{
			WoWScript CompleteQuest()
		}
		else
		{
			WoWScript DeclineQuest()
		}
		if !${Object[${POI.GUID}].QuestStatus(exists)}
		{
			WoWScript "QuestFrame:Hide()"
		}
		return
	}
	
	method Accept()
	{
		This:Output[Accepting a Quest]
		Bot.RandomPause:Set[30]
		WoWScript AcceptQuest()
		if !${Object[${POI.GUID}].QuestStatus(exists)}
		{
			WoWScript "QuestFrame:Hide()"
		}
		return
	}
	
	member GossipVisible()
	{
		if ${WoWScript[GossipFrame:IsVisible()]} || ${WoWScript[QuestFrame:IsVisible()]}
		{
			return TRUE
		}
		return FALSE
	}
	
	method Pulse()
	{
	}
}