/*[[BR]] Cerebrum - oGrind             			*/
/*[[BR]] This source code is part of Cerebrum.		*/
/*[[BR]]							*/
/*[[BR]] Author: genecyber	*/

objectdef cGrind inherits cBase
{
	variable index:oLocationSet LocationIndex
	variable index:oLocationSet ActiveLocIndex	
	variable oLocationSet CurrentGrind
	variable int ActiveLocations = 0
	
	/* default is 180 minutes - need to add UI element */
	variable int LocationTimer
	variable string NaviPOIStr = NULL
	
	variable int PrevGainedXP = 0
	variable int NextLevelXP = ${Me.NextLevelExp}
	variable int CurrentLevel = ${Me.Level}
	
	variable int RepopCount = 0
	variable int KillCount = 0
	variable int StartXP = ${Me.Exp}
	variable int GainedXP = 0
	variable int Xhr = 0
	
	variable int InitialMoney = ${Me.Coinage}
	variable int EarnedMoney
	variable int EarnedGold
	variable int EarnedSilver
	variable int EarnedCopper

	/* change location based on level, location, followed */
	member ChangeLocation()
	{
		if ${Grind.CheckLocationTimer} || ${Me.Level} < ${Grind.MinLvl} || ${Me.Level} > ${Grind.MaxLvl} || ${Grind.IsFollowed}
		{
			/* randomly choosing new location */
			This:LoadBestLocationSet[TRUE]
			return TRUE
		}
		return FALSE
	}
	
	method RefreshCurrent()
	{
		This.CurrentGrind:Refresh
	}
	
	member RandomizeHotSpots()
	{
		return ${This.CurrentGrind.Randomize}	
	}
	
	member KillInPath()
	{
		return ${This.CurrentGrind.KillInPath}	
	}
	
	member IsFollowed()
	{
		/* reserved for follower check */
		return FALSE
	}
	
	/* iterates the hotspot in the current location by one */
	method NextHotspot()
	{
		This.CurrentGrind:JumpTo[1]
	}
	
	/* randomly selects a hotspot from current location */
	method RandomHotSpot()
	{
		This.CurrentGrind:RandomSpot
	}	

	/* returns the GrindRange for the current location */	
	member GrindRange()
	{
		return ${This.CurrentGrind.GrindRange}		
	}
	
	/* returns the Location Name for the current grind location */
	member LocationSetName()
	{
		return ${This.CurrentGrind.Name}		
	}

	/* returns the current HotSpotName for the current grind location */
	member HotSpotName()
	{
		return ${This.CurrentGrind.HotSpotName}		
	}	
	
	/* returns the current HotSpotName for the current grind location */
	member HotSpotDistance()
	{
		return ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.CurrentGrind.X},${This.CurrentGrind.Y},${This.CurrentGrind.Z}]}
	}	

	/* returns X for the current hotspot */
	member X()
	{
		return ${This.CurrentGrind.X}
	}

	/* returns Y for the current hotspot */	
	member Y()
	{
		return ${This.CurrentGrind.Y}
	}

	/* returns Z for the current hotspot */	
	member Z()
	{
		return ${This.CurrentGrind.Z}
	}

	/* returns Heading for the current hotspot */	
	member Hd()
	{
		return ${This.CurrentGrind.Hd}
	}

	/* returns X:Y:Z for the current hotspot */	
	member XYZ()
	{
		return ${This.CurrentGrind.XYZ}
	}

	/* returns Minimum Level for the current location */	
	member MinLvl()
	{
		return ${This.CurrentGrind.MinLvl}		
	}

	/* returns Maximum Level for the current location */	
	member MaxLvl()
	{
		return ${This.CurrentGrind.MaxLvl}		
	}
	
	method LoadBestLocationSet(bool ForceSwitch)
	{
		variable int LocNum = 1

		if ${UIElement[chkAssistMode@Overview@Pages@Cerebrum].Checked}
		{
			return
		}

		if ${UIElement[chkPartyMode@Overview@Pages@Cerebrum].Checked}
		{
			if  !${WoWScript[IsPartyLeader()]}
			{
				return
			}
		}
		
		/* if not forced, dont change if the current grind still works */
		if !${ForceSwitch}
		{
			if ${This.CurrentGrind.IsDesired}
			{
				This:Output["The Current LocationSet ${This.CurrentGrind.Name} is still valid. Force switch was ${ForceSwitch}."]
				return
			}
		}
		
		/* force switch is true or current grind is not desired, lets iterate through the valid locations and choose one randomly that is NOT current */
		This:GetValidLocations
		
		/* we dont have any valid locations */
		if ${This.ActiveLocations} == 0
		{
			This:Output["There is no LocationSet that fits for the Toon. Grind is stopped. Force switch was ${ForceSwitch}."]
			if ${UIElement[chkErrorSoundOn@Config@Pages@Cerebrum].Checked}
			{
				This:PlaySound["Stop"]
			}
			Bot.PauseFlag:Set[TRUE]
			This:ResetLocationTimer				
			return
		}
		
		/* we only have one valid location and its our current location */
		if ${This.ActiveLocations} == 1 && ${This.ActiveLocIndex.Get[1].Name.Equal[${This.CurrentGrind.Name}]}
		{
			This:Output["The Current LocationSet ${This.CurrentGrind.Name} is still valid and the only one that fits for the Toon. Force switch was ${ForceSwitch}."]
			This:ResetLocationTimer
			return
		}	
		
		/* randomly select a location that is not our current location */
		LocNum:Inc[${Math.Rand[${This.ActiveLocations}]}]
		do
		{
			LocNum:Set[1]
			LocNum:Inc[${Math.Rand[${This.ActiveLocations}]}]			
		}
		while (${LocNum} > ${This.ActiveLocations} || ${This.ActiveLocIndex.Get[${LocNum}].Name.Equal[${This.CurrentGrind.Name}]})
		
		This.CurrentGrind:Set[${This.ActiveLocIndex.Get[${LocNum}].Name}]
		This:ResetLocationTimer		
		This:Output["Loaded / Updated Grind to new LocationSet ${This.CurrentGrind.Name}. Force switch was ${ForceSwitch}."]
		return			
	}

	/* all active locations within my level and connected to me */
	method GetValidLocations()
	{
		variable int i = 1
		variable int k = 0
		variable bool isActiveValidLoc = FALSE
		variable iterator LocationIterator
		This:ClearIndex[LocationIndex]
		This:ClearIndex[ActiveLocIndex]
		This.ActiveLocations:Set[0]
		
		LavishSettings[Location].FindSet[Hunting]:GetSetIterator[LocationIterator]
		if ${LocationIterator:First(exists)}
		{
			do
			{		
				This.LocationIndex:Insert[${LocationIterator.Key}]
			}
			while ${LocationIterator:Next(exists)}
		}
		
		if ${This.LocationIndex.Get[${i}](exists)}
		{
			do
			{
				k:Set[0]
				isActiveValidLoc:Set[FALSE]
				/* is the location active and within our level range? */
				if ${This.LocationIndex.Get[${i}].IsDesired}
				{
					do
					{
						/* do i have a path to that location? */
						if ${This.LocationIndex.Get[${i}].IsConnected}
						{
							This:Debug["I am connected to Hotspot ${Math.Calc[${k}+1]} for ${This.LocationIndex.Get[${i}].Name}"]
							This.ActiveLocIndex:Insert[${This.LocationIndex.Get[${i}].Name}]
							This.ActiveLocations:Inc
							isActiveValidLoc:Set[TRUE]
						}
						else
						{
							This:Debug["Error: NOT connected to Hotspot ${Math.Calc[${k}+1]} for ${This.LocationIndex.Get[${i}].Name}"]
							This.LocationIndex.Get[${i}]:JumpTo[1]
						}
					}
					while ${k:Inc} <= ${This.LocationIndex.Get[${i}].NumHotSpots} && !${isActiveValidLoc}
				}
			}
			while ${This.LocationIndex.Get[${i:Inc}](exists)}
		}
	}
		
	/* Mob events */
	method KillCount(string Id, string IdText, string Msg)
	{	
		if ${Msg.Find[You have slain]}
		{
			This:Output[Killing Blow! ${Msg}]
			Grind.KillCount:Inc
			State.LOOTState_Skip_Scans:Set[0]
			State.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${State.LOOTState_Loot_Wait_After_Until_Timeout} * ${Bot.GlobalCooldown})]}]			
			if ${UIElement[chkKillSoundOn@Config@Pages@Cerebrum].Checked}
			{
				This:PlaySound["Blip"]
			}
			return
		}
		/* check if your pet killed the mob */
		if ${WoWScript[UnitName("pet")](exists)}
		{
			if ${Msg.Find[is slain by ${WoWScript[UnitName("pet")]}]}
			{
				This:Output[Killing Blow! ${Msg}]
				Grind.KillCount:Inc
				State.LOOTState_Skip_Scans:Set[0]
				State.LOOTState_Loot_Wait_Until:Set[${Math.Calc[${LavishScript.RunningTime}+(${State.LOOTState_Loot_Wait_After_Until_Timeout} * ${Bot.GlobalCooldown})]}]			
				if ${UIElement[chkKillSoundOn@Config@Pages@Cerebrum].Checked}
				{
					This:PlaySound["Blip"]
				}
				return
			}	
		}		
	}
	
	method MoneyMaker()
	{
		This.EarnedMoney:Set[${Math.Calc[${Me.Coinage}-${InitialMoney}]}]
		This.EarnedGold:Set[${Math.Calc[${EarnedMoney}/10000].Int.LeadingZeroes[2]}]
		This.EarnedSilver:Set[${Math.Calc[(${EarnedMoney}-(${EarnedGold}*10000))/100]}]
		This.EarnedCopper:Set[${Math.Calc[${EarnedMoney}-(${EarnedGold}*10000)-(${EarnedSilver}*100)]}]
	}
	
	method UpdateXP()
	{
		variable int currentLevel = 0
      
		if ${CurrentLevel} != ${Me.Level}
		{         
			PrevGainedXP:Set[${Math.Calc[${This.NextLevelXP}-${This.StartXP}+${This.PrevGainedXP}]}]                                                 
			CurrentLevel:Set[${Me.Level}]
			NextLevelXP:Set[${Me.NextLevelExp}]         
			StartXP:Set[0]
		}
            
		currentLevel:Set[${Math.Calc[${Me.Exp}-${This.StartXP}]}]      
		This.GainedXP:Set[${Math.Calc[${currentLevel}+${This.PrevGainedXP}]}]      
		This.Xhr:Set[${Math.Calc[${This.GainedXP}/${Math.Calc[${Script.RunningTime}/3600000]}]}]
	}	

	/* LOCATION TIMER */
	/* call this during pulse to determine if hotspot should change based on time expiration */
	member CheckLocationTimer()
	{
		if ${LavishScript.RunningTime} > ${This.LocationTimer} && ${This.ActiveLocations} > 0
		{
			This:Output["Time Expired for LocationSet."]
			return TRUE
		}
		return FALSE
	}
	
	/* use this to reset the timer location */
	method ResetLocationTimer()
	{
		variable int minutes = ${UIElement[cmbLocTimer@Grind@Pages@Cerebrum].SelectedItem}  /*will change this to UI element later */
		This:SetLocationTimer[${minutes}]
	}
	
	/* set the location timer */
	method SetLocationTimer(int minutes)
	{
		This.LocationTimer:Set[${LavishScript.RunningTime}]
		This.LocationTimer:Inc[${minutes}*60000]
	}	
}

objectdef oLocationSet
{
	variable index:oHotSpot HotSpot
	variable int CurrentHotspot = 1
	variable int NumHotSpots = 0
	variable int MinLvl
	variable int MaxLvl
	variable int GrindRange
	variable bool KillInPath = FALSE
	variable bool Randomize = FALSE 
	variable bool Active = FALSE
	variable string Name
	
	method Initialize(string LocationKey)
	{
		variable iterator indexx
		
		This.Name:Set[${LocationKey}]	
		if ${LavishSettings[Location].FindSet[Hunting].FindSet[${LocationKey}].FindSet[Attributes].FindSetting[Active].String.Equal[TRUE]}
		{
			This.Active:Set[TRUE]
		}
		if ${LavishSettings[Location].FindSet[Hunting].FindSet[${LocationKey}].FindSet[Attributes].FindSetting[Randomize].String.Equal[TRUE]}
		{
			This.Randomize:Set[TRUE]
		}
		if ${LavishSettings[Location].FindSet[Hunting].FindSet[${LocationKey}].FindSet[Attributes].FindSetting[KillInPath].String.Equal[TRUE]}
		{
			This.KillInPath:Set[TRUE]
		}		
		This.MinLvl:Set[${LavishSettings[Location].FindSet[Hunting].FindSet[${LocationKey}].FindSet[Attributes].FindSetting[LvlFrom].String}]   
		This.MaxLvl:Set[${LavishSettings[Location].FindSet[Hunting].FindSet[${LocationKey}].FindSet[Attributes].FindSetting[LvlTo].String}]   
		This.GrindRange:Set[${LavishSettings[Location].FindSet[Hunting].FindSet[${LocationKey}].FindSet[Attributes].FindSetting[GrindRange].String}] 
		
		LavishSettings[Location].FindSet[Hunting].FindSet[${LocationKey}].FindSet[Hotspots]:GetSettingIterator[indexx]
		if ${indexx:First(exists)}				
		{
			do
			{
				This:Add[${indexx.Key},${indexx.Value}]
			}
			while ${indexx:Next(exists)}
		}	
	}

	method Refresh()
	{
		variable int i = 0
		variable string SavedName		
		variable iterator indexx
		if ${This.Name.Equal[${UIElement[tlbLocations@Grind@Pages@Cerebrum].SelectedItem.Text}]}
		{	
			This.Active:Set[FALSE]	
			This.Randomize:Set[FALSE]	
			This.KillInPath:Set[FALSE]				
			if ${LavishSettings[Location].FindSet[Hunting].FindSet[${This.Name}].FindSet[Attributes].FindSetting[Active].String.Equal[TRUE]}
			{
				This.Active:Set[TRUE]
			}
			if ${LavishSettings[Location].FindSet[Hunting].FindSet[${This.Name}].FindSet[Attributes].FindSetting[Randomize].String.Equal[TRUE]}
			{
				This.Randomize:Set[TRUE]
			}
			if ${LavishSettings[Location].FindSet[Hunting].FindSet[${This.Name}].FindSet[Attributes].FindSetting[KillInPath].String.Equal[TRUE]}
			{
				This.KillInPath:Set[TRUE]
			}		
			This.MinLvl:Set[${LavishSettings[Location].FindSet[Hunting].FindSet[${This.Name}].FindSet[Attributes].FindSetting[LvlFrom].String}]   
			This.MaxLvl:Set[${LavishSettings[Location].FindSet[Hunting].FindSet[${This.Name}].FindSet[Attributes].FindSetting[LvlTo].String}]   
			This.GrindRange:Set[${LavishSettings[Location].FindSet[Hunting].FindSet[${This.Name}].FindSet[Attributes].FindSetting[GrindRange].String}] 
			
			SavedName:Set[${This.HotSpot.Get[${This.CurrentHotspot}].Name}]
			This:ClearHotSpots
			
			LavishSettings[Location].FindSet[Hunting].FindSet[${This.Name}].FindSet[Hotspots]:GetSettingIterator[indexx]
			if ${indexx:First(exists)}				
			{
				do
				{
					i:Inc
					This:Add[${indexx.Key},${indexx.Value}]
					if ${SavedName.Equal[${indexx.Value}]}
					{
						This.CurrentHotspot:Set[${i}]
					}
				}
				while ${indexx:Next(exists)}
			}	
		}
	}
	
	member X()
	{
		return ${This.HotSpot.Get[${This.CurrentHotspot}].X}
	}
	
	member Y()
	{
		return ${This.HotSpot.Get[${This.CurrentHotspot}].Y}
	}
	
	member Z()
	{
		return ${This.HotSpot.Get[${This.CurrentHotspot}].Z}
	}
	
	member Hd()
	{
		return ${This.HotSpot.Get[${This.CurrentHotspot}].Hd}
	}
	
	member XYZ()
	{
		return ${This.HotSpot.Get[${This.CurrentHotspot}].XYZ}
	}
	
	member HotSpotName()
	{
		return ${This.HotSpot.Get[${This.CurrentHotspot}].Name}
	}
	
	method Add(string HotSpotKey, string HotSpotValue)
	{
		This.HotSpot:Insert[${HotSpotKey},${HotSpotValue}]
		NumHotSpots:Inc
	}
	
	method JumpTo(int Jumps)
	{
		Jumps:Inc[${This.CurrentHotspot}]
		if  ${Jumps} <= ${This.NumHotSpots}
		{
			This.CurrentHotspot:Set[${Jumps}]
			return
		}
		Jumps:Dec[${This.NumHotSpots}]
		This.CurrentHotspot:Set[${Jumps}]
	}
	
	method RandomSpot()
	{
		variable int mySpot = ${This.CurrentHotspot}
		variable int Jumps = ${Math.Rand[${This.NumHotSpots}]}
		
		This:JumpTo[${Jumps}]
		if ${mySpot} == ${This.CurrentHotspot}
		{
			This:JumpTo[1]
		}
	}
	
	member IsCurrentLocation()
	{
		if ${Grind.CurrentGrind.Name.Equal[${This.Name}]}
		{
			return TRUE
		}
		return FALSE
	}
	
	member IsDesired()
	{
		if ${Me.Level} >= ${This.MinLvl} && ${Me.Level} <= ${This.MaxLvl} && ${This.Active}
		{
			return TRUE
		}
		return FALSE
	}
	
	member IsConnected()
	{	
		if ${Navigator.AvailablePath[${This.X},${This.Y},${This.Z}]}
		{
			return TRUE
		}
		elseif ${Config.GetCheckbox[chkTakeFMToGrind]}
		{
			if ${FlightPlan.FlyToPoint[${This.X},${This.Y},${This.Z}]}
			{
				return TRUE
			}
		}
		return FALSE
	}

	method Set(string LocationKey)
	{
		This:ClearHotSpots
		This:Initialize[${LocationKey}]
	}	
	
	method ClearHotSpots()
	{
		variable int i = 1	
		This.CurrentHotspot:Set[1]
		This.NumHotSpots:Set[0]
		
		if ${This.HotSpot.Get[${i}](exists)}
		{
			do
			{
				This.HotSpot:Remove[${i}]		
			}
			while ${This.HotSpot.Get[${i:Inc}](exists)}
			This.HotSpot:Collapse	
		}	
	}	
}

objectdef oHotSpot
{
	variable float X
	variable float Y
	variable float Z
	variable float Hd
	variable string XYZ
	variable string Name
	
	method Initialize(string HotSpotKey, string HotSpotValue)
	{
		This.Name:Set[${HotSpotValue}]
		This.X:Set[${HotSpotKey.Token[1,:]}]
		This.Y:Set[${HotSpotKey.Token[2,:]}]
		This.Z:Set[${HotSpotKey.Token[3,:]}]
		This.Hd:Set[${HotSpotKey.Token[4,:]}]
		This.XYZ:Set[${HotSpotKey}]
	}
}