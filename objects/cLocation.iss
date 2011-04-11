objectdef cLocation inherits cBase
{
	variable int Index = 0
	
	method Initialize()
	{
		LavishSettings:AddSet[Location]
		LavishSettings[Location]:Import["config/location.xml"]
		LavishSettings[Location]:AddSet[Hunting]
		LavishSettings[Location]:AddSet[Quests]
		LavishSettings[Location]:AddSet[RMLocations]
	}
	method Shutdown()
	{
		LavishSettings[Location]:Export["config/location.xml"]
	}

	method Pulse()
	{
	}
	
	method AddHotspot()
	{
			if ${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem(exists)} 
			{
				Mapper:MapLocation[${Me.Location}]
				variable settingsetref LS = ${LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Hotspots]}
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

				variable int HC=${LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes].FindSetting[HotspotsCount]}
				HC:Inc
				if ${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tenHotSpots].Text.NotEqual[""]}
				{
					HotspotName:Set[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tenHotSpots].Text}]
				}
				else
				{
					HotspotName:Set[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}${HC}]
				}

				variable iterator HotspotIterator1
				variable settingsetref LS1 = ${LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Hotspots]}
				LS1:GetSettingIterator[HotspotIterator1]
					
				if ${HotspotIterator1:First(exists)}
				{
					do
					{
						if ${XYZ.Equal[${HotspotIterator1.Key}]}
						{
							This:Output[You already have a Hotspot for this LocationSet here !]
							return
						}
						if ${HotspotName.Equal[${HotspotIterator1.Value}]}
						{
							This:Output[You already have a Hotspot for this LocationSet with a similar Name !]
							return
						}
					} 
					while ${HotspotIterator1:Next(exists)}
				}

				This:QuickNote[${HotspotName}]
				LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes]:AddSetting[HotspotsCount,${HC}]
				LS:AddSetting[${XYZ},${HotspotName}]
				This:addDropdown[${XYZ}]
				Location:populateHotspots
				Grind:RefreshCurrent
			}
	}

	method delLocation()
	{
		;ok
		LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}]:Remove
		Location:populateLocations
		Location:populateHotspots
		Location:populateLocationAttributes
		UIElement[cmbLocationLvlFrom@Grind@Pages@Cerebrum]:SetSelection[${Me.Level}] 
		UIElement[cmbLocationLvlTo@Grind@Pages@Cerebrum]:SetSelection[${Me.Level}]
		UIElement[cmbLocationGrindRange@Grind@Pages@Cerebrum]:SetSelection[200] 
	}
	
	method delHotspot()
	{
		;ok
		LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Hotspots].FindSetting[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbHotspots].SelectedItem.Text.Token[2,@]}]:Remove
		Location:populateHotspots
		Grind:RefreshCurrent			
	}

	method addLocation()
	{
		;ok
		if ${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tenLocations].Text(exists)}
		{
			LavishSettings[Location].FindSet[Hunting]:AddSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tenLocations].Text}]
			
			LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tenLocations].Text}]:AddSet[Hotspots]
			LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tenLocations].Text}].FindSet[Hotspots]:AddComment[Comment Needed to keep empty sets]
			
			LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tenLocations].Text}]:AddSet[Attributes]
			LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tenLocations].Text}].FindSet[Attributes]:AddSetting[LvlFrom,${UIElement[cmbLocationLvlFrom@Grind@Pages@Cerebrum].Selection}]
			LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tenLocations].Text}].FindSet[Attributes]:AddSetting[LvlTo,${UIElement[cmbLocationLvlTo@Grind@Pages@Cerebrum].Selection}]
			LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tenLocations].Text}].FindSet[Attributes]:AddSetting[GrindRange,${UIElement[cmbLocationGrindRange@Grind@Pages@Cerebrum].Selection}]
			LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tenLocations].Text}].FindSet[Attributes]:AddSetting[Active,${UIElement[chkLocationActive@Grind@Pages@Cerebrum].Checked}]
		}
		UIElement[cmbLocZone@Grind@Pages@Cerebrum]:SetSelection[3]		/* this should set it to empty locations */
		Location:populateLocations

	}
	method populateHotspots()
	{
		;ok
		variable iterator HotspotIterator
		variable settingsetref LS = ${LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Hotspots]}
		LS:GetSettingIterator[HotspotIterator]
		UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbHotspots]:ClearItems
		if ${HotspotIterator:First(exists)}
		{
			do
			{
				if ${Navigator.AvailablePath[${HotspotIterator.Key.Token[1,:]},${HotspotIterator.Key.Token[2,:]},${HotspotIterator.Key.Token[3,:]}]}
				{
					UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbHotspots]:AddItem[${HotspotIterator.Value.String.Upper}@${HotspotIterator.Key}]
				}
				else
				{
					UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbHotspots]:AddItem[${HotspotIterator.Value.String.Lower}@${HotspotIterator.Key}]
				}
			}
			while ${HotspotIterator:Next(exists)}
		}
	}
	
	method populateLocations()
	{
		variable int temp
		variable iterator LocationIterator
		variable iterator HotspotIterator
		variable string ZoneFilter = "${UIElement[cmbLocZone@Grind@Pages@Cerebrum].Item[${UIElement[cmbLocZone@Grind@Pages@Cerebrum].Selection}]}"
		variable string theZONE
		
		UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations]:ClearItems
		LavishSettings[Location].FindSet[Hunting]:GetSetIterator[LocationIterator]
		
		if ${LocationIterator:First(exists)}
		{
			do
			{
				LavishSettings[Location].FindSet[Hunting].FindSet[${LocationIterator.Key}].FindSet[Hotspots]:GetSettingIterator[HotspotIterator]
				if ${HotspotIterator:First(exists)}
				{
					theZONE:Set[${This.FindZone[${HotspotIterator.Key}]}]
					if ${ZoneFilter.Equal[All Zones]}
					{
						UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations]:AddItem[${LocationIterator.Key}]
					}
					elseif ${ZoneFilter.Equal[${theZONE}]}
					{
						UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations]:AddItem[${LocationIterator.Key}]
					}	
				}
				elseif ${ZoneFilter.Equal[Empty Locations]}
				{
					UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations]:AddItem[${LocationIterator.Key}]	
				}
			}
			while ${LocationIterator:Next(exists)}
		}
			
		/* Forget it !!! This is no bug: We only want this to run once */
		while ${Index:Inc} <= 300
		{
			UIElement[cmbLocationGrindRange@Grind@Pages@Cerebrum]:AddItem[${Index}]
			
			if ${Index} <= ${Bot.LvlCap}
			{
				UIElement[cmbLocationLvlFrom@Grind@Pages@Cerebrum]:AddItem[${Index}]
				UIElement[cmbLocationLvlTo@Grind@Pages@Cerebrum]:AddItem[${Index}]
			
				if ${Index} == ${Bot.LvlCap}
				{
					UIElement[cmbLocationLvlFrom@Grind@Pages@Cerebrum]:SetSelection[${This.MathMax[1,${Math.Calc[${Me.Level}-5]}]}] 
					UIElement[cmbLocationLvlTo@Grind@Pages@Cerebrum]:SetSelection[${This.MathMin[${Bot.LvlCap},${Math.Calc[${Me.Level}+5]}]}]
				}
			}
			
			if ${Index} == 300
			{
 				UIElement[cmbLocationGrindRange@Grind@Pages@Cerebrum]:SetSelection[200]
 			}
		}
	}
	
	method gotoHotspot()
	{
		variable int i = 1
		variable string theHotspot
		variable string theLocation
		
		if !${UIElement[tlbLocations@Grind@Pages@Cerebrum].SelectedItem(exists)} || !${UIElement[tlbHotspots@Grind@Pages@Cerebrum].SelectedItem(exists)}
		{
			This:Output[Error: Select a location and hotspot!]
			return
		}
		theHotspot:Set[${UIElement[tlbHotspots@Grind@Pages@Cerebrum].SelectedItem.Text.Token[1,@]}]
 		theLocation:Set[${UIElement[tlbLocations@Grind@Pages@Cerebrum].SelectedItem.Text}]
		
		if !${theLocation.Equal[${Grind.LocationSetName}]}
		{
			Grind:GetValidLocations
			if ${Grind.ActiveLocIndex.Get[${i}](exists)}
			{
				do
				{
					if ${Grind.ActiveLocIndex.Get[${i}].Name.Equal[${theLocation}]}
					{
						Grind.CurrentGrind:Set[${Grind.ActiveLocIndex.Get[${i}].Name}]
						Grind:ResetLocationTimer		
						This:Output["Updated Grind to new LocationSet ${Grind.CurrentGrind.Name}."]
						break
					}
				}
				while ${Grind.ActiveLocIndex.Get[${i:Inc}](exists)}
			}
		}
		if !${theLocation.Equal[${Grind.LocationSetName}]}
		{
			This:Output[ERROR: The selected LocationSet for HotSpot ${theHotspot} is not Valid]
			return
		}
		
		if ${Grind.CurrentGrind.NumHotSpots} > 0
		{
			Grind.CurrentGrind.CurrentHotspot:Set[1]
			do
			{
				if ${theHotspot.Equal[${Grind.CurrentGrind.HotSpotName}]}
				{
					This:Output[GOTO: Current HotSpot changed to ${theHotspot} in ${theLocation}.]
					Bot.PauseFlag:Set[FALSE]
					return
				}
			}
			while ${Grind.CurrentGrind.CurrentHotspot:Inc} <= ${Grind.CurrentGrind.NumHotSpots}
			Grind.CurrentGrind.CurrentHotspot:Set[1]
		}
		This:Output[Bug in goto button. No hotspot found.]
	}

	method populateLocationAttributes()
	{
				;ok
				if ${LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes].FindSetting[Active].String.Equal[TRUE]}
				{
					UIElement[chkLocationActive@Grind@Pages@Cerebrum]:SetChecked					
				}
				else
				{
					UIElement[chkLocationActive@Grind@Pages@Cerebrum]:UnsetChecked
				}

				if ${LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes].FindSetting[Randomize].String.Equal[TRUE]}
				{
					UIElement[chkRandomHotSpots@Grind@Pages@Cerebrum]:SetChecked					
				}
				else
				{
					UIElement[chkRandomHotSpots@Grind@Pages@Cerebrum]:UnsetChecked
				}
				
				if ${LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes].FindSetting[KillInPath].String.Equal[TRUE]}
				{
					UIElement[chkKillInPath@Grind@Pages@Cerebrum]:SetChecked					
				}
				else
				{
					UIElement[chkKillInPath@Grind@Pages@Cerebrum]:UnsetChecked
				}				
				
				UIElement[cmbLocationLvlFrom@Grind@Pages@Cerebrum]:SetSelection[${LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes].FindSetting[LvlFrom].String}] 
				UIElement[cmbLocationLvlTo@Grind@Pages@Cerebrum]:SetSelection[${LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes].FindSetting[LvlTo].String}]
				UIElement[cmbLocationGrindRange@Grind@Pages@Cerebrum]:SetSelection[${LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes].FindSetting[GrindRange].String}]
	}

	method UpdateLvlFrom()
	{
		LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes]:AddSetting[LvlFrom,${UIElement[cmbLocationLvlFrom@Grind@Pages@Cerebrum].Selection}]
		Grind:RefreshCurrent
	}
	method UpdateLvlTo()
	{
		LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes]:AddSetting[LvlTo,${UIElement[cmbLocationLvlTo@Grind@Pages@Cerebrum].Selection}]
		Grind:RefreshCurrent
	}
	method UpdateActive()
	{
		LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes]:AddSetting[Active,${UIElement[chkLocationActive@Grind@Pages@Cerebrum].Checked}]
		Grind:RefreshCurrent		
	}
	method UpdateRandomize()
	{
		LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes]:AddSetting[Randomize,${UIElement[chkRandomHotSpots@Grind@Pages@Cerebrum].Checked}]
		Grind:RefreshCurrent		
	}
	method UpdateKillInPath()
	{
		LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes]:AddSetting[KillInPath,${UIElement[chkKillInPath@Grind@Pages@Cerebrum].Checked}]
		Grind:RefreshCurrent		
	}	
	method UpdateGrindRange()
	{
		LavishSettings[Location].FindSet[Hunting].FindSet[${UIElement[Cerebrum].FindChild[Pages].Tab["Grind"].FindChild[tlbLocations].SelectedItem.Text}].FindSet[Attributes]:AddSetting[GrindRange,${UIElement[cmbLocationGrindRange@Grind@Pages@Cerebrum].Selection}]
		Grind:RefreshCurrent		
	}

	method addDropdown(string HotSpotKey)
	{
		variable int i
		variable string settingText
		variable string comboText
		variable string theZONE
		variable bool addZONE = TRUE
		
		theZONE:Set[${This.FindZone[${HotSpotKey}]}]	
		for (i:Set[1] ; ${i} <=${UIElement[cmbLocZone@Grind@Pages@Cerebrum].Items} ; i:Inc)   
		{    
			comboText:Set["${UIElement[cmbLocZone@Grind@Pages@Cerebrum].Item[${i}]}"]
			if ${settingText.Equal[${theZONE}]}        
			{       
				addZONE:Set[FALSE]
			}
		}
		if ${addZONE}
		{
			UIElement[cmbLocZone@Grind@Pages@Cerebrum]:AddItem[${theZONE}]
		}
	}
	
	method populateDropdown()
	{
		variable set ZoneAdded
		variable string theZONE
		variable iterator LocationIterator
		variable iterator HotspotIterator
		
		LavishSettings[Location].FindSet[Hunting]:GetSetIterator[LocationIterator]	
		UIElement[cmbLocZone@Grind@Pages@Cerebrum]:AddItem["All Zones"]
		UIElement[cmbLocZone@Grind@Pages@Cerebrum]:AddItem["No Mapping Data"]	
		UIElement[cmbLocZone@Grind@Pages@Cerebrum]:AddItem["Empty Locations"]				
		ZoneAdded:Add["No Mapping Data"]
		
		if ${LocationIterator:First(exists)}
		{		
			do
			{
				LavishSettings[Location].FindSet[Hunting].FindSet[${LocationIterator.Key}].FindSet[Hotspots]:GetSettingIterator[HotspotIterator]
				if ${HotspotIterator:First(exists)}
				{
					theZONE:Set[${This.FindZone[${HotspotIterator.Key}]}]
					if !${ZoneAdded.Contains[${theZONE}]}
					{
						ZoneAdded:Add[${theZONE}]
						UIElement[cmbLocZone@Grind@Pages@Cerebrum]:AddItem[${theZONE}]
					}	
				}
			}
			while ${LocationIterator:Next(exists)}
		}
		UIElement[cmbLocZone@Grind@Pages@Cerebrum]:SetSelection[1]		
	}
	
	member FindZone(string HotSpotKey)
	{
		variable float X = ${HotSpotKey.Token[1,:]}
		variable float Y = ${HotSpotKey.Token[2,:]}
		variable float Z = ${HotSpotKey.Token[3,:]}		
		variable string theZONE
		
		theZONE:Set[${Navigator.BestZone[${X},${Y},${Math.Calc[${Z}+1]}]}]
		if ${theZONE.NotEqual[Instance]} && ${theZONE.NotEqual[NULL]}
		{
			return ${theZONE}
		}
		return "No Mapping Data"
	}
	
	method QuickNote(string myHotSpot)
	{
		variable string myCommand = "/mn -t"
		
		if ${UIElement[tenWoWEcho@Grind@Pages@Cerebrum].Text.Equal[""]}
		{
			return
		}
		if ${UIElement[tenWoWEcho@Grind@Pages@Cerebrum].Text.Find["/"]}
		{
			WoWScript RunMacroText('/mn -t ${myHotSpot}')
		}
		else
		{
			This:Output[Doh! Slash commands need a slash.]
		}		
	}	
}