objectdef cQuestgiver inherits cBase
{
	variable collection:collection:int AvailableFromNPC
	variable collection:collection:int CompletedWithNPC
	variable collection:int RequiredQuestItems
	variable collection:bool BlacklistedQuestStrings
	variable collection:bool BlacklistedQuestGivers
	variable collection:bool BlacklistedQuestItems
	variable collection:int CompletedCounts
	variable collection:int AcceptCounts
	variable collection:int GossipCounts	
	variable int MaxAttempts = 5
	variable guidlist NPCsWithQuests
	variable guidlist NPCsWithTurnIn
	variable guidlist QuestObjects
	variable bool NeedNPC = FALSE
	variable int CurrentSubState = QUEST_IDLE
	variable bool ChooseReward
	variable collection:bool DontCompareItems
	variable string ItemBeginsQuest = "NONE"
	
	/* returns true if i should go turn in or pick up a quest */
	member NeedQuestGiver()
	{
		if ${POI.Type.Equal["QUESTNPC"]}
		{
			return TRUE
		}
		return FALSE
	}

	/* returns true if i should go turn in or pick up a quest */
	member NeedQuestObject()
	{
		if ${POI.Type.Equal["QUESTOBJECT"]}
		{
			return TRUE
		}
		return FALSE
	}

	member GossipVisible()
	{
		if (${WoWScript[GossipFrame:IsVisible()]} || ${WoWScript[QuestFrame:IsVisible()]}) && ${Target.Name(exists)} && ${Target.Name.NotEqual[NULL]}
		{
			return TRUE
		}
		return FALSE
	}
	
	method ClearMerchantFrames()
	{
		if ${WoWScript[MerchantFrame:IsVisible()]}
		{
			WoWScript "MerchantFrame:Hide()"				
		}
		elseif ${This.VisibleFrame[ClassTrainerFrame]}
		{
			WoWScript "ClassTrainerFrame:Hide()"				
		}		
	}

	/* returns true if an quest can be picked up or turned in */
	member NeedGossip()
	{	
		/* gossip window visible */
		if ${This.GossipVisible} 
		{
			return ${This.UpdateNPC[${Target.Name}]}		
		}
		return FALSE
	}
	
	member SetQuestGiverPOI()
	{
		variable int i = 1
		variable int NumQuests
		variable string QuestGiverGUID
		variable string ostring
		variable int maxRange = ${Grind.GrindRange}
		
		if ${maxRange} < 50
		{
			maxRange:Set[100]
		}
		
		/* search for NPCs with completed quests */
		This.NPCsWithTurnIn:Clear
		This.NPCsWithTurnIn:Search[-units, -nearest, -nonhostile, -questcomplete, -range 0-${maxRange}]
		
		if ${This.NPCsWithTurnIn.Count} > 0
		{
			do
			{
				QuestGiverGUID:Set[${This.NPCsWithTurnIn.Object[${i}].GUID}]
				if ${Unit[${QuestGiverGUID}](exists)} && ${Unit[${QuestGiverGUID}].Name.NotEqual[NULL]}
				{
					ostring:Set["${Unit[${QuestGiverGUID}].X}:${Unit[${QuestGiverGUID}].Y}:${Unit[${QuestGiverGUID}].Z}:${QuestGiverGUID}:${Unit[${QuestGiverGUID}].Name}:QUESTNPC:${Unit[${QuestGiverGUID}].FactionGroup.Upper}:${Unit[${QuestGiverGUID}].Level}"]
					if ${POI.myobjectstring.Equal[${ostring}]} && !${This.IsQuestGiverBlacklisted[${Unit[${QuestGiverGUID}].Name}]} 
					{
						return TRUE
					}
					if ${This.PathToNPC[${QuestGiverGUID}]}
					{		
						POI.myobjectstring:Set[${ostring}]
						POI.Current:Set[${ostring.Token[4,:]}]
						return TRUE
					}
				}	
			}
			while ${This.NPCsWithTurnIn.Count} >= ${i:Inc}
		}
		
		/* search for NPCs with available quests */
		This.NPCsWithQuests:Clear
		This.NPCsWithQuests:Search[-units, -nearest, -nonhostile, -questavailable, -range 0-${maxRange}]

		if ${This.NPCsWithQuests.Count} > 0
		{
			NumQuests:Set[${WoWScript[GetNumQuestLogEntries(),2]}]
			if ${NumQuests} < 25
			{
				i:Set[1]
				do
				{
					QuestGiverGUID:Set[${This.NPCsWithQuests.Object[${i}].GUID}]
					if ${Unit[${QuestGiverGUID}](exists)} && ${Unit[${QuestGiverGUID}].Name.NotEqual[NULL]}
					{
						ostring:Set["${Unit[${QuestGiverGUID}].X}:${Unit[${QuestGiverGUID}].Y}:${Unit[${QuestGiverGUID}].Z}:${QuestGiverGUID}:${Unit[${QuestGiverGUID}].Name}:QUESTNPC:${Unit[${QuestGiverGUID}].FactionGroup.Upper}:${Unit[${QuestGiverGUID}].Level}"]
						if ${POI.myobjectstring.Equal[${ostring}]} && !${This.IsQuestGiverBlacklisted[${Unit[${QuestGiverGUID}].Name}]} 
						{
							return TRUE
						}
						if ${This.PathToNPC[${QuestGiverGUID}]}
						{					
							POI.myobjectstring:Set[${ostring}]
							POI.Current:Set[${ostring.Token[4,:]}]
							POI.LastUse:Set[${LavishScript.RunningTime}]
							return TRUE
						}
					}	
				}
				while ${This.NPCsWithQuests.Count} >= ${i:Inc}
			}
		}
		return FALSE
	}
	
	/* checks path to NPC and blacklists if it cant reach them */
	member PathToNPC(string QuestGiverGUID)
	{
		if !${This.IsQuestGiverBlacklisted[${Unit[${QuestGiverGUID}].Name}]} 
		{
			if ${Navigator.AvailablePath[${Unit[${QuestGiverGUID}].X},${Unit[${QuestGiverGUID}].Y},${Unit[${QuestGiverGUID}].Z}]}
			{
				return TRUE
			}
			This:BlacklistQuestGiver[${Unit[${QuestGiverGUID}].Name}]
			This:Output["Blacklisting ${Unit[${QuestGiverGUID}].Name} because path to questgiver does not exist."]
		}
		return FALSE
	}

	/* checks path to NPC and blacklists if it cant reach them */
	member PathToObject(string ObjectGUID)
	{
		if !${This.IsItemBlacklisted[${ObjectGUID}]} 
		{
			if ${Navigator.AvailablePath[${Object[${ObjectGUID}].X},${Object[${ObjectGUID}].Y},${Object[${ObjectGUID}].Z}]}
			{
				return TRUE
			}
			This:BlacklistQuestItem[${ObjectGUID}]
			This:Output["Blacklisting ${Object[${ObjectGUID}].Name} because path to object does not exist."]
		}
		return FALSE
	}

	/* take action when we have the gossip window open */
	method GossipPulse()
	{
		variable int NumQuests
		variable string GiverName = ${Target.Name}
		variable int i
		
		if ${GiverName.NotEqual[NULL]}
		{		
			/* first check to see if there are quests we can turn in */
			if ${This.CompletedWithNPC.Element[${GiverName}].FirstKey(exists)}
			{
				do
				{
					This:Output["Completing Quest: ${This.CompletedWithNPC.Element[${GiverName}].CurrentKey}"]
					WoWScript SelectGossipActiveQuest(${This.CompletedWithNPC.Element[${GiverName}].CurrentValue})
					if ${WoWScript["QuestFrame:IsVisible()"]}
					{
						WoWScript SelectActiveQuest(${This.CompletedWithNPC.Element[${GiverName}].CurrentValue})
					}
					Bot.RandomPause:Set[10]
					This:CountCompletes[${GiverName},${This.CompletedWithNPC.Element[${GiverName}].CurrentKey}]			
					return
				}
				while ${This.CompletedWithNPC.Element[${GiverName}].NextKey(exists)}
			}							
			/* then check to see if there are any quests to pick up */
			if ${This.AvailableFromNPC.Element[${GiverName}].FirstKey(exists)}
			{
				NumQuests:Set[${WoWScript[GetNumQuestLogEntries(),2]}]
				if ${NumQuests} < 25
				{
					do
					{
						This:Output["Picked Up Quest: ${This.AvailableFromNPC.Element[${GiverName}].CurrentKey}"]
						WoWScript SelectGossipAvailableQuest(${This.AvailableFromNPC.Element[${GiverName}].CurrentValue})
						if ${WoWScript["QuestFrame:IsVisible()"]}
						{
							WoWScript SelectAvailableQuest(${This.AvailableFromNPC.Element[${GiverName}].CurrentValue})
						}						
						Bot.RandomPause:Set[10]	
						This:CountAccepts[${GiverName},${This.AvailableFromNPC.Element[${GiverName}].CurrentKey}]					
						return
					}
					while ${This.AvailableFromNPC.Element[${GiverName}].NextKey(exists)}
				}				
			}
			
			/* keep iterating attempts until we blacklist */
			This:CountFailedGossip[${GiverName}]

			; ugly, but forces completed a quest that is completeable but not showing as complete in quest log
			; the Marshal McBride factor -- damn him?!
			if ${WoWScript[GetGossipActiveQuests()](exists)}
			{
				This:Debug[Damn you ${GiverName}!!  You appear to have complete quest not showing as complete in quest log!  Attempt #${This.GossipCounts.Element[${GiverName}]}]
				WoWScript SelectGossipActiveQuest(${This.GossipCounts.Element[${GiverName}]})
				return
			}		
		}
	}
	
	/* flags available gossip options from NPC - checks blacklisted quests */
	member UpdateNPC(string GiverName)
	{
		variable int i = 1
		variable string QuestLevel
		variable string QuestName
		variable bool isQuestGiver = FALSE
		
		/* create and clear quest containers for questgiver */
		if ${This.AvailableFromNPC.Element[${GiverName}](exists)}
		{
			This.AvailableFromNPC:Erase[${GiverName}]
		}
		This.AvailableFromNPC:Set[${GiverName}]
		
		if ${This.CompletedWithNPC.Element[${GiverName}](exists)}
		{
			This.CompletedWithNPC:Erase[${GiverName}]
		}
		This.CompletedWithNPC:Set[${GiverName}]
		
		/* grab all the available quest titles */
		if ${WoWScript[GetAvailableTitle(${i})](exists)}
		{
			do
			{
				QuestName:Set["${WoWScript[GetAvailableTitle(${i})]}"]
				QuestLevel:Set["${WoWScript[GetAvailableLevel(${i})]}"]	
				if !${This.IsQuestBlacklisted["${GiverName}", "${QuestLevel}-${QuestName}"]}
				{
					This:Debug[Available: "${QuestLevel}-${QuestName}" - ${i}]
					This.AvailableFromNPC.Element[${GiverName}]:Set["${QuestLevel}-${QuestName}",${i}]
					isQuestGiver:Set[TRUE]
				}					
			}
			while ${WoWScript[GetAvailableTitle(${i:Inc})](exists)}
		}
		elseif ${WoWScript[GetGossipAvailableQuests()](exists)}
		{
			i:Set[1]
			do
			{
				QuestName:Set["${WoWScript[GetGossipAvailableQuests(),${i}]}"]
				QuestLevel:Set[${WoWScript[GetGossipAvailableQuests(),${i:Inc}]}]	
				if !${This.IsQuestBlacklisted["${GiverName}", "${QuestLevel}-${QuestName}"]}
				{
					This:Debug[Available: "${QuestLevel}-${QuestName}" - ${Math.Calc[${i}/2]}]
					This.AvailableFromNPC.Element[${GiverName}]:Set["${QuestLevel}-${QuestName}",${Math.Calc[${i}/2]}]
					isQuestGiver:Set[TRUE]
				}
			}
			while ${WoWScript[GetGossipAvailableQuests(),${i:Inc}](exists)}	
		}
		/* reset the iterator */
		i:Set[1]
		
		/* grab all the active quest titles */
		if ${WoWScript[GetActiveTitle(${i})](exists)}
		{
			do
			{
				QuestName:Set["${WoWScript[GetActiveTitle(${i})]}"]
				QuestLevel:Set["${WoWScript[GetActiveLevel(${i})]}"]	
				if !${This.IsQuestBlacklisted["${GiverName}", "${QuestLevel}-${QuestName}"]}
				{
					if ${This.SetCompleted["${GiverName}","${QuestLevel}-${QuestName}",${i}]}
					{
						This:Debug[Completed: "${QuestLevel}-${QuestName}" - ${i}]
						isQuestGiver:Set[TRUE]
					}	
				}
			}
			while ${WoWScript[GetActiveTitle(${i:Inc})](exists)}
		}
		elseif ${WoWScript[GetGossipActiveQuests()](exists)}
		{
			i:Set[1]
			do
			{
			QuestName:Set["${WoWScript[GetGossipActiveQuests(),${i}]}"]
			QuestLevel:Set[${WoWScript[GetGossipActiveQuests(),${i:Inc}]}]	
			if !${This.IsQuestBlacklisted["${GiverName}", "${QuestLevel}-${QuestName}"]}
			{
				if ${This.SetCompleted["${GiverName}","${QuestLevel}-${QuestName}",${Math.Calc[${i}/2]}]}
				{
					This:Debug[Completed: "${QuestLevel}-${QuestName}" - ${Math.Calc[${i}/2]}]
				}
			}
			isQuestGiver:Set[TRUE]	
			}
			while ${WoWScript[GetGossipActiveQuests(),${i:Inc}](exists)}
		}
		
		/* if this isnt a questgiver, why are we gossiping? */
		if !${isQuestGiver}
		{
			This:CountFailedGossip[${GiverName}]
		}
		return ${isQuestGiver}
	}
	
	/* used to set only the completed active quests */
	member SetCompleted(string GiverName, string QuestString, int QuestIndex)
	{
		variable int i = 1
		variable string title
		variable int level
		do
		{
			/* is the quest complete */
			if ${WoWScript[GetQuestLogTitle(${i}),7]} && !${WoWScript[GetQuestLogTitle(${i}),5]}
			{
				title:Set[${WoWScript["GetQuestLogTitle(${i})"]}]
				level:Set[${WoWScript[pcall(loadstring("local questName, questLevel = GetQuestLogTitle(${i}); return questLevel")), 2]}]
				if !${level}
				{
					level:Set[0]
					This:Debug[Level Not Found, setting to 0]
				}
				/* is this the quest we are storing */
				if ${QuestString.Equal["${level}-${title}"]}
				{
					This.CompletedWithNPC.Element[${GiverName}]:Set["${QuestString}",${QuestIndex}]
					return TRUE
				}
			}
		}
		while ${WoWScript[GetQuestLogTitle(${i:Inc})](exists)}	

		
		
		return FALSE
	}	

	/* used to count the number of attempts before blacklisting a quest */
	method CountCompletes(string GiverName, string QuestString)
	{
		variable int attempts = 0	
		/* check for previous attempts */
		if ${This.CompletedCounts.Element["${GiverName}-${QuestString}"](exists)}
		{
			attempts:Set[${This.CompletedCounts.Element["${GiverName}-${QuestString}"]}]
		}
		/* increase attempts */
		attempts:Inc
		This.CompletedCounts:Set["${GiverName}-${QuestString}",${attempts}]				
		/* did we exceed the max attempts? then blacklist */
		if ${attempts} > ${This.MaxAttempts}
		{
			This:Output["Blacklisting ${QuestString} from ${GiverName} due to inability to turnin quest."]
			This:BlacklistQuest[${GiverName},${QuestString}]
		}
	}
	
	method CountAccepts(string GiverName, string QuestString)
	{
		variable int attempts = 0	
		/* check for previous attempts */
		if ${This.AcceptCounts.Element["${GiverName}-${QuestString}"](exists)}
		{
			attempts:Set[${This.AcceptCounts.Element["${GiverName}-${QuestString}"]}]
		}
		/* increase attempts */
		attempts:Inc
		This.AcceptCounts:Set["${GiverName}-${QuestString}",${attempts}]				
		/* did we exceed the max attempts? then blacklist */
		if ${attempts} > ${This.MaxAttempts}
		{
			This:Output["Blacklisting ${QuestString} from ${GiverName} due to inability to pickup quest."]
			This:BlacklistQuest[${GiverName},${QuestString}]
		}
	}
	
	method CountFailedGossip(string GiverName)
	{
		variable int attempts = 0	
		/* check for previous attempts */
		if ${This.GossipCounts.Element[${GiverName}](exists)}
		{
			attempts:Set[${This.GossipCounts.Element[${GiverName}]}]
		}
		/* increase attempts */
		attempts:Inc
		This.GossipCounts:Set[${GiverName},${attempts}]				
		/* did we exceed the max attempts? then blacklist */
		if ${attempts} > ${This.MaxAttempts}
		{
			This:Output["Blacklisting ${GiverName} due to failed Gossip attempts."]
			This:BlacklistQuestGiver[${GiverName}]
		}
	}	
	
	/* used with events to accept and complete quests*/
	method AcceptQuest()
	{
		Quest:QuestgiverUpdate
		if !${Bot.PauseFlag}
		{
			This:Output["Quest Accepted."]
			WoWScript AcceptQuest()
		}
		return
	}
	
	method LogUpdate()
	{
		Quest:Pulse
		if ${WoWScript["QuestFrame:IsVisible()"]} && !${Bot.PauseFlag}
		{
			WoWScript "QuestFrame:Hide()"
		}
	}
	
	method CompleteQuest()
	{
		Quest:QuestgiverUpdate
		if !${Bot.PauseFlag}
		{
			This:Output["Quest Completed."]
			if ${WoWScript[IsQuestCompletable()]}
			{
				WoWScript CompleteQuest()
			}
			else
			{
				WoWScript DeclineQuest()
			}
		}
		return
	}

	/* chooses the best available quest reward */
	method FindReward()
	{	
		Quest:QuestgiverUpdate
		if !${Bot.PauseFlag}
		{
			This.ChooseReward:Set[TRUE]
			Bot.RandomPause:Set[9]
		}
		return
	}

	method GetReward()
	{
		variable int choice = ${Autoequip.GetBestRewardIndex}
		if ${choice} == 0
		{
			choice:Set[1]
		}
		WoWScript "GetQuestReward(${choice})"
		This.ChooseReward:Set[FALSE]
		return
	}
	
	/* used for blacklisting quests */
	method BlacklistQuest(string GiverName, string QuestString)
	{
		This.BlacklistedQuestStrings:Set["${GiverName}-${QuestString}",TRUE]
	}
	
	member IsQuestBlacklisted(string GiverName, string QuestString)
	{
		if ${This.BlacklistedQuestStrings.Element["${GiverName}-${QuestString}"]}
		{
			return TRUE
		}
		return FALSE
	}
	
	method BlacklistQuestGiver(string GiverName)
	{
		This.BlacklistedQuestGivers:Set[${GiverName},TRUE]
	}
	
	member IsQuestGiverBlacklisted(string GiverName)
	{
		if ${This.BlacklistedQuestGivers.Element[${GiverName}]} || ${GlobalBlacklist.Exists[${GiverName}]}
		{
			return TRUE
		}
		return FALSE
	}
	
	method BlacklistQuestItem(string ItemGUID)
	{
		This.BlacklistedQuestItems:Set[${ItemGUID},TRUE]
	}
	
	member IsItemBlacklisted(string ItemGUID)
	{
		if ${This.BlacklistedQuestItems.Element[${ItemGUID}]} || ${GlobalBlacklist.Exists[${ItemGUID}]}
		{
			return TRUE
		}
		return FALSE
	}
	
	/* not used at the moment */
	method RefreshQuestItems()
	{
		variable int i = 1
		variable int q = 1		
		do
		{
			do
			{
				This.RequiredQuestItems:Set[${Me.Quest[${q}].RequiredItem[${i}].Name},${Me.Quest[${q}].RequiredItemCount[${i}]}]
			}
			while ${Me.Quest[${q}].RequiredItem[${i:Inc}](exists)}
			i:Set[1]
		}	
		while ${Me.Quest[${q:Inc}](exists)}
	}
	
	member IsQuestMob(string MobGUID)
	{
		variable objectref QuestMob	
		QuestMob:Set[${MobGUID}]	
		
		if ${QuestMob.NeedSlaughterCount} > 0
		{
			return TRUE
		}
		return FALSE
	}

	method BeginItemQuest()
	{
		if ${This.ItemBeginsQuest.NotEqual[NONE]}
		{
			This:Debug[Starting quest from ${Item[${This.ItemBeginsQuest}].Name}]
			This:Output[Starting quest from ${Item[${This.ItemBeginsQuest}].Name}]
			Item[${This.ItemBeginsQuest}]:Use
		}
		This.ItemBeginsQuest:Set[NONE]		
	}
	
	/* searches for an item in your bag that begins a quest */
	member ItemStartQuest()
	{
		variable guidlist ItemsInBag
		variable objectref bagItem
		variable oItemTT bagTT
		variable int i = 1
		
		/* search gear and iterate through items to find items that begin quests */
		ItemsInBag:Search[-items, -inventory]		
		if ${ItemsInBag.Count} > 0
		{
			do
			{
				bagItem:Set[${ItemsInBag.Object[${i}].GUID}]
				if ${This.CheckBagItem[${bagItem.Name}]} && ${bagItem.Name(exists)}
				{
					This.DontCompareItems:Set[${bagItem.Name},TRUE]	
					bagTT:GetBagSlot[${bagItem.Bag.Number},${bagItem.Slot}]	
					if ${bagTT.BeginsQuest}
					{
						This.ItemBeginsQuest:Set[${ItemsInBag.Object[${i}].GUID}]
						return TRUE
					}
				}
			}
			while ${ItemsInBag.Count} >= ${i:Inc}
		}
		This.ItemBeginsQuest:Set[NONE]		
		return FALSE
	}	

	member CheckBagItem(string itemName)
	{
		if ${This.DontCompareItems.Element[${itemName}]}
		{
			return FALSE
		}
		return TRUE
	}	
}