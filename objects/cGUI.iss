objectdef cGUI inherits cBase
{
	variable int GlobalLogOutIn = ${UIElement[sldLogOutIn@Logout@Pages@Cerebrum].Value}
	variable int GlobalLogOutLevel = ${UIElement[sldLogOutLevel@Logout@Pages@Cerebrum].Value}
	variable int GlobalLastLogoutChange = ${LavishScript.RunningTime}
	
	variable bool GlobalLogoutOnTimer
	variable bool GlobalLogOutOnLevel

	variable int Last_GUI_Update = ${LavishScript.RunningTime}
	
	method Initialize()
	{
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[ALL_BLACKLISTED]		
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[REPAIR]
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[SELL]
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[MAILBOX]
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[INNKEEPER]
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[FLIGHTMASTER]
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[HERBALISM]
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[MINING]
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[SPIRITHEALER]
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[${Me.Class}_TRAINER]
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[Skinning_TRAINER]
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[Herbalism_TRAINER]
				UIElement[cmbPOIsType@Blacklist@POIPages@POIs@Pages@Cerebrum]:AddItem[Mining_TRAINER]
				UIElement[tlbSpecedTalents@Talents@Pages@Cerebrum]:SetSortType[value]
				UIElement[tlbSpecedTalents@Talents@Pages@Cerebrum]:SetAutoSort[TRUE]
				
				variable int i
				for(i:Set[1];${i} <= 100;i:Inc)
				{
					UIElement[cmbMinAmount@Restock@InvPages@Inventory@Pages@Cerebrum]:AddItem[${i},${i}]
					UIElement[cmbMaxAmount@Restock@InvPages@Inventory@Pages@Cerebrum]:AddItem[${i},${i}]
				}
				Autoequip:SetAutoequipGUI
				Targeting:MinMaxLvLs
				
				UIElement[tenMuleChar@Config@InvPages@Inventory@Pages@Cerebrum]:SetText[${LavishSettings[Settings].FindSetting[muleName,""]}]
				UIElement[AmmoMerchant@Config@InvPages@Inventory@Pages@Cerebrum]:SetText[${LavishSettings[Settings].FindSetting[AmmoMerch,""]}]
				UIElement[FoodMerchant@Config@InvPages@Inventory@Pages@Cerebrum]:SetText[${LavishSettings[Settings].FindSetting[FoodMerch,""]}]
				UIElement[DrinkMerchant@Config@InvPages@Inventory@Pages@Cerebrum]:SetText[${LavishSettings[Settings].FindSetting[DrinkMerch,""]}]
				UIElement[EnterKey@Logout@Pages@Cerebrum]:SetText[${LavishSettings[Settings].FindSetting[EnterKey,""]}]
				UIElement[AccountName@Logout@Pages@Cerebrum]:SetText[${LavishSettings[Settings].FindSetting[AccountName,""]}]
				UIElement[Password@Logout@Pages@Cerebrum]:SetText[${LavishSettings[Settings].FindSetting[Password,""]}]
				if ${LavishSettings[Settings].FindSetting[chkAutoReconnect,FALSE]}
				{
					UIElement[chkAutoReconnect@Logout@Pages@Cerebrum]:SetChecked				
				}
				else
				{
					UIElement[chkAutoReconnect@Logout@Pages@Cerebrum]:UnsetChecked	
				}			
				UIElement[lowestRepairPCT@Config@InvPages@Inventory@Pages@Cerebrum]:SetText[${LavishSettings[Settings].FindSetting[lowestRepairPCT,"10"]}]
				UIElement[overAllRepairPCT@Config@InvPages@Inventory@Pages@Cerebrum]:SetText[${LavishSettings[Settings].FindSetting[overAllRepairPCT,"20"]}]
				Inventory.lowestRpairPct:Set[${UIElement[lowestRepairPCT@Config@InvPages@Inventory@Pages@Cerebrum].Text}]
				Inventory.overAllRepairPCT:Set[${UIElement[overAllRepairPCT@Config@InvPages@Inventory@Pages@Cerebrum].Text}]
	}
	
	method Update()
	{
		if ${Bot.PauseFlag}
		{
			UIElement[Cerebrum].FindUsableChild[Pause, button]:Hide
			UIElement[Cerebrum].FindUsableChild[barPause, button]:Hide
			UIElement[Cerebrum].FindUsableChild[Resume, button]:Show
			UIElement[Cerebrum].FindUsableChild[barPlay, button]:Show
		}
		else
		{
			UIElement[Cerebrum].FindUsableChild[Resume, button]:Hide
			UIElement[Cerebrum].FindUsableChild[barPlay, button]:Hide
			UIElement[Cerebrum].FindUsableChild[Pause, button]:Show
			UIElement[Cerebrum].FindUsableChild[barPause, button]:Show
		}	
		
		; Dont update if it is minimized
		if ${UIElement[Cerebrum].Minimized} || (${Math.Calc[${LavishScript.RunningTime} - ${This.Last_GUI_Update}]} < ${Bot.LagInterval})
		{
			return
		}
		This.Last_GUI_Update:Set[${LavishScript.RunningTime}] 
		
		UIElement[txtKills@Overview@pages@Cerebrum]:SetText[${Grind.KillCount}]
		UIElement[txtDeaths@Overview@pages@Cerebrum]:SetText[${Grind.RepopCount}]
		UIElement[txtRunning@Overview@pages@Cerebrum]:SetText[${Math.Calc[(${Script.RunningTime}/3600000)%60].Int.LeadingZeroes[2]}:${Math.Calc[(${Script.RunningTime}/60000)%60].Int.LeadingZeroes[2]}:${Math.Calc[(${Script.RunningTime}/1000)%60].Int.LeadingZeroes[2]}]
		UIElement[txtXP@Overview@pages@Cerebrum]:SetText[${Grind.GainedXP}]
		UIElement[txtXhr@Overview@pages@Cerebrum]:SetText[${Grind.Xhr}]
		UIElement[txtStuck@Overview@pages@Cerebrum]:SetText[${Navigator.SumStuck}]
		UIElement[txtDCCount@Overview@pages@Cerebrum]:SetText[${Bot.DCCount}]
		
		UIElement[txtGrindStatus@Overview@pages@Cerebrum]:SetText[${Bot.StatusText}]
		UIElement[txtPOIStatus@Overview@pages@Cerebrum]:SetText[${POI.StatusText}]
		UIElement[txtLocationSet@Overview@pages@Cerebrum]:SetText[${Grind.LocationSetName} ${Grind.GrindRange}]
		UIElement[txtHotspot@Overview@pages@Cerebrum]:SetText[${Grind.HotSpotName}]

		UIElement[txtMeleeStatus@Overview@pages@Cerebrum]:SetText[${Float[${Toon.MinMelee}].Centi} - ${Float[${Toon.MaxMelee}].Centi}]
		UIElement[txtRangedStatus@Overview@pages@Cerebrum]:SetText[${Float[${Toon.MinRanged}].Centi} - ${Float[${Toon.MaxRanged}].Centi}]		
		UIElement[txtGrindRange@Overview@pages@Cerebrum]:SetText[${Grind.GrindRange}]
		UIElement[txtPullRange@Overview@pages@Cerebrum]:SetText[${Toon.PullRange}]		
		UIElement[txtTargetYds@Overview@pages@Cerebrum]:SetText[${Float[${Target.Distance}].Centi}]			
		UIElement[txtPOIYds@Overview@pages@Cerebrum]:SetText[${Float[${POI.Distance}].Centi}]	
		UIElement[txtHotspotYds@Overview@pages@Cerebrum]:SetText[${Float[${Grind.HotSpotDistance}].Centi}]		

		UIElement[txtMemory@Overview@pages@Cerebrum]:SetText[${Int[${Math.Calc[${System.MemTotal}-${System.MemFree}]}]}]
		UIElement[txtFPS@Overview@pages@Cerebrum]:SetText[${Display.FPS.Centi}]				
	}
	
	method HandleButton(string Button)
	{
		switch ${Button}
		{
			case PartyMode
			{
				if ${UIElement[chkPartyMode@Overview@Pages@Cerebrum].Checked}
				{
					Party.Uplink:Enable
					return
				}
				Party.Uplink:Disable
				return
			}
			case ForceHotspotSwitch
			{
				Grind:NextHotspot
				break
			}
			case AddLocation
			{
				Location:addLocation
				break
			}
			case DelHotspot
			{
				Location:delHotspot
				break
			}
			case DelLocation
			{
				Location:delLocation
				break
			}
			case LoadQuest
			{
				Play:LoadQuest
				break
			}
			case QuestWeightInc
			{
				Record:WeightInc
				break
			}
			case QuestWeightDec
			{
				Record:WeightDec
				break
			}
			case QuestSetNeutral
			{
				Record:SetNeutral
				break
			}
			case QuestSetAlliance
			{
				Record:SetAlliance
				break
			}
			case QuestSetHorde
			{
				Record:SetHorde
				break
			}
			case LoadLocations
			{
				Location:populateLocations
				break
			}
			case LoadHotspots
			{
				Location:populateHotspots
				Location:populateLocationAttributes
				break
			}
			case AddHotspot
			{
				Location:AddHotspot
				break
			}
			case GotoHotspot
			{
				Location:gotoHotspot
				break
			}
  			case GrindLoadLocation
			{
				Grind:LoadLocation
				break
			}
			case UpdateItemList
			{
				Inventory:UpdateItemsGUI
				break
			}
			case AddSell
			{
				Inventory:Add[Sell]
				break
			}
			case AddMule
			{
				Inventory:Add[Mule]
				break
			}
			case Remove
			{
				Inventory:Delete
				break
			}
			case AddKeep
			{
				Inventory:Add[Keep]
				break
			}
			case AddBank
			{
				Inventory:Add[Bank]
				break
			}
			case AddDestroy
			{
				Inventory:Add[Destroy]
				break
			}
			case AddOpen
			{
				Inventory:Add[Open]
				break
			}
			case UpdateRestockList
			{
				Inventory:UpdateRestockGUI
				break
			}
			case AddRestock
			{
				Inventory:AddRestock
				break
			}
			case SetEnterKey
			{
				Inventory:SetEnterKey
				break
			}
			case SetAccountName
			{
				Inventory:SetAccountName
				break
			}
			case SetPassword
			{
				Inventory:SetPassword
				break
			}
			case SetAutoReconnect
			{
				Inventory:SetAutoReconnect
				break
			}
			case RemoveRestock
			{
				Inventory:RemoveRestock
				break
			}
			case RestockedClick
			{		
				UIElement[lstInventory@Restock@InvPages@Inventory@Pages@Cerebrum]:ClearSelection
				Inventory:RestockSettingUpdate
				break
			}
			case RInventoryClick
			{
				UIElement[lstListed@Restock@InvPages@Inventory@Pages@Cerebrum]:ClearSelection
				break
			}
			case RMinChange
			{
				if ${UIElement[lstListed@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem(exists)}
				{
					Inventory.RestockList.Element[${UIElement[lstListed@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text}].Min:Set[${UIElement[cmbMinAmount@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text}]
				}
				break
			}
			case RMaxChange
			{				
				if ${UIElement[lstListed@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem(exists)}
				{
					Inventory.RestockList.Element[${UIElement[lstListed@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text}].Max:Set[${UIElement[cmbMaxAmount@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text}]
				}
				break
			}
			case RTypeChange
			{
				if ${UIElement[lstListed@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem(exists)}
				{					
					Inventory.RestockList.Element[${UIElement[lstListed@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text}].myType:Set[${UIElement[cmbType@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text}]
				}
				break
			}
			case FoodSet
			{
				Inventory:SetFood
				break
			}
			case DrinkSet
			{
				Inventory:SetDrink
				break
			}
			case AmmoSet
			{
				Inventory:SetAmmo
				break
			}
			case MinMaxLvLs
			{
				Targeting:MinMaxLvLs
				break
			}
			case Pause
			{
				Bot.PauseFlag:Set[TRUE]
				move -stop
				break
			}
			case Resume
			{
				Bot.PauseFlag:Set[FALSE]
				break
			}
			case ForceLogout
			{
				This:Output[Force Safe Logout]
				POI.NeedLogout:Set[TRUE]
				break
			}
			case ForceSellRepair
			{
				This:Output[Force Sell & Repair Run]
				This:Output[1st item to sent to Mule: ${Item[${Inventory.GetSlot[Mule,"-notsoulbound"]}].Name}]
				POI.NeedSell:Set[TRUE]
				POI.NeedRepair:Set[TRUE]
				break
			}
			case ForceTrain
			{
				This:Output[Force Trainer Run]
				POI.NeedClassTrainer:Set[TRUE]
				break
			}
			case LocationUpdateLvlFrom
			{
				Location:UpdateLvlFrom
				break
			}
			case LocationUpdateLvlTo
			{
				Location:UpdateLvlTo
				break
			}
			case LocationUpdateActive
			{
				Location:UpdateActive
				break
			}
			case LocationUpdateRandom
			{
				Location:UpdateRandomize
				break
			}	
			case LocationUpdateKillInPath
			{
				Location:UpdateKillInPath
				break
			}			
			case LocationListZone
			{
				Location:populateLocations
				Location:populateHotspots				
				break				
			}
			case LocationUpdateGrindRange
			{
				Location:UpdateGrindRange
				break
			}
			case GrindLoadBestLocationSet
			{
				Grind:LoadBestLocationSet[TRUE]
				break
			}
			case UpdateBotGlobalCooldown
			{
				Bot:UpdateGlobalCooldown
				break
			}
			case ManualBlacklistPOI
			{
				POI:ManualBlacklistPOI
			}
			case ManualBlacklistPOITarget
			{
				POI:ManualBlacklistPOITarget
			}
			case BlacklistRemovePOI
			{
				POI:BlacklistRemovePOI
				break
			}
			case DelPOI
			{
				POI:RemovePOI
				break
			}
			case GotoPOI
			{
				POI:GotoPOI
				break
			}
			case BlacklistAddPOI
			{
				POI:BlacklistAddPOI
				break
			}
			case AddToAvoid
			{
				if ${UIElement[tenAvoid@Avoidance@POIPages@POIs@Pages@Cerebrum].Text(exists)}
				{
					Avoidance:Add[${UIElement[tenAvoid@Avoidance@POIPages@POIs@Pages@Cerebrum].Text}]
					UIElement[tenAvoid@Avoidance@POIPages@POIs@Pages@Cerebrum]:SetText[]					
					Avoidance:PopulateAvoids
				}
				break
			}
			case AddTargetToAvoid
			{
				if ${Target.Name(exists)}
				{
					Avoidance:Add[${Target.Name}]
					Avoidance:PopulateAvoids
				}
				break
			}
			case RemoveAvoid
			{
				Avoidance:Remove[${UIElement[tlbAvoids@Avoidance@POIPages@POIs@Pages@Cerebrum].SelectedItem}]
				Avoidance:PopulateAvoids				
				break
			}			
			case PopulateAvoids
			{
				Avoidance:PopulateAvoids
				break
			}			
			case PopulatePOIs
			{
				POI:PopulatePOIs
				break
			}
			case overAllRepairPCTSet
			{
				Inventory:overAllRepairPCTSet
				break
			}
			case lowestRepairPCTSet
			{
				Inventory:lowestRepairPCTSet
				break
			}
			case MuleSet
			{
				Inventory:SetMule
				break
			}
			case FoodRestock
				if ${UIElement[chkRestockFood@Restock@InvPages@Inventory@Pages@Cerebrum].Checked}
				{
				FoodSupplyEnable:Set[TRUE]
				}
				if !${UIElement[chkRestockFood@Restock@InvPages@Inventory@Pages@Cerebrum].Checked}
				{
				FoodSupplyEnable:Set[FALSE]
				}
			break
			
			case AddFood
			FoodNumber:Set[${UIElement[FoodNumber@Restock@InvPages@Inventory@Pages@Cerebrum].Text}]
			FoodName:Set[${UIElement[FoodName@Restock@InvPages@Inventory@Pages@Cerebrum].Text}]
			FoodMerchant:Set["${UIElement[FoodMerchant@Restock@InvPages@Inventory@Pages@Cerebrum].Text}"]
			break
			
			case AddDrink
			DrinkNumber:Set[${UIElement[DrinkNumber@Restock@InvPages@Inventory@Pages@Cerebrum].Text}]
			DrinkName:Set[${UIElement[DrinkName@Restock@InvPages@Inventory@Pages@Cerebrum].Text}]
			DrinkMerchant:Set["${UIElement[DrinkMerchant@Restock@InvPages@Inventory@Pages@Cerebrum].Text}"]
			break
			
			case AmmoRestock
				if ${UIElement[chkRestockAmmo@Restock@InvPages@Inventory@Pages@Cerebrum].Checked}
				{
				AmmoSupplyEnable:Set[TRUE]
				}
				if !${UIElement[chkRestockAmmo@Restock@InvPages@Inventory@Pages@Cerebrum].Checked}
				{
				AmmoSupplyEnable:Set[FALSE]
				}
			break
			
			case AddAmmo
			AmmoMerchant:Set["${UIElement[AmmoMerchant@Restock@InvPages@Inventory@Pages@Cerebrum].Text}"]
			AmmoName:Set["${UIElement[AmmoName@Restock@InvPages@Inventory@Pages@Cerebrum].Text}"]
			AmmoNumber:Set[${UIElement[AmmoNumber@Restock@InvPages@Inventory@Pages@Cerebrum].Text}]
			break
			
			case MapSettingChanged
			Mapper:OnGUIChange
			break
			
			case BackupZone
			Mapper:BackupZone
			break
			
			case MapLeftClick
			{
				MapEditor:LeftClick
				break
			}
			case MapRightClick
			{
				MapEditor:RightClick
				break
			}
		}
	}

}
