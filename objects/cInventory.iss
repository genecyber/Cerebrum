;Events: Add to List AddItem -> ObjectAdded? Bag PUlse? 
; Colored Items in one big list?
#define RETRIEVE_FREESLOTS 0
#define RETRIEVE_TOTALSLOTS 1
#define RETRIEVE_BAGCOUNT 2

#define INV_SELL 16724787
#define INV_KEEP 3355647
#define INV_MULE 65331
#define INV_BANK 13421619
#define INV_DESTROY 13421772
#define INV_OPEN 16777215



objectdef RestockItem
{
	variable string Name
	variable int Min
	variable int Max
	variable string myType
	variable bool Disabled = FALSE
	method Initialize(string theName,int theMin,int theMax,string theType)
	{
		Name:Set[${theName}]
		Min:Set[${theMin}]
		Max:Set[${theMax}]
		myType:Set[${theType}]		
	}
}

;Integration with POI system for vendor type


objectdef oInventory inherits cBase
{
	variable set SellList
	variable set KeepList
	variable set MuleList
	variable set BankList
	variable set DestroyList
	variable set OpenList
	variable set List	
	variable collection:RestockItem RestockList
	
	variable bool needSpecialCheck = TRUE
	variable int RestockCheck = 0
	
	variable int FreeSlots = 0
	variable string MuleCharName
	
	variable string FoodMerch = ""
	variable string DrinkMerch = ""
	variable string AmmoMerch = ""

  variable int lowestRpairPct = -1
	variable int overAllRepairPCT = -1
	
	member leaveFreeSlots()
	{
		variable int lfs = ${UIElement[leaveFreeSlots@Config@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Value}
		return ${lfs}
	}
	
	method lowestRepairPCTSet()
	{
		LavishSettings[Settings]:AddSetting[lowestRepairPCT,${UIElement[lowestRepairPCT@Config@InvPages@Inventory@Pages@Cerebrum].Text}]
		Inventory.lowestRpairPct:Set[${UIElement[lowestRepairPCT@Config@InvPages@Inventory@Pages@Cerebrum].Text}]
		This:Output[Set and Saved Lowest Repair % as ${UIElement[lowestRepairPCT@Config@InvPages@Inventory@Pages@Cerebrum].Text}]
	}
	
	method overAllRepairPCTSet()
	{
		LavishSettings[Settings]:AddSetting[overAllRepairPCT,${UIElement[overAllRepairPCT@Config@InvPages@Inventory@Pages@Cerebrum].Text}]
		Inventory.overAllRepairPCT:Set[${UIElement[overAllRepairPCT@Config@InvPages@Inventory@Pages@Cerebrum].Text}]
		This:Output[Set and Saved Overall Repair % as ${UIElement[overAllRepairPCT@Config@InvPages@Inventory@Pages@Cerebrum].Text}]
	}
	
	;the  MuleCharName is in ${UIElement[tenMuleChar@Config@InvPages@Inventory@Pages@Cerebrum]}
	method SetMule()
	{
		if ${UIElement[tenMuleChar@Config@InvPages@Inventory@Pages@Cerebrum].Text.NotEqual[""]}
		{
			This.MuleCharName:Set[${UIElement[tenMuleChar@Config@InvPages@Inventory@Pages@Cerebrum].Text}]
			LavishSettings[Settings]:AddSetting[muleName,${This.MuleCharName}]
			This:Output[Set and Saved Mule name as ${This.MuleCharName}]
		}
		else
		{
			This:Output["Please enter the name of your Mule Toon"]
		}
	}
	
	method SetFood()
	{
		if ${Target.Name(exists)}
		{
			if ${Target.IsMerchant}
			{
			This.FoodMerch:Set[${Target.Name}]
			LavishSettings[Settings]:AddSetting[FoodMerch,${This.FoodMerch}]
			UIElement[FoodMerchant@Config@InvPages@Inventory@Pages@Cerebrum]:SetText[${This.FoodMerch}]
			This:Output[Set and Saved Food Vendor name as ${This.FoodMerch}]
			}
			else
			{
				This:Output["Please Target the Food Merchant First"]
			}
		}
		else
		{
			This.FoodMerch:Set[""]
			LavishSettings[Settings]:AddSetting[FoodMerch,${This.FoodMerch}]
			UIElement[FoodMerchant@Config@InvPages@Inventory@Pages@Cerebrum]:SetText[${This.FoodMerch}]
		}
	}
	method SetDrink()
	{
		if ${Target.Name(exists)} 
		{
			if ${Target.IsMerchant}
			{
			This.DrinkMerch:Set[${Target.Name}]
			LavishSettings[Settings]:AddSetting[DrinkMerch,${This.DrinkMerch}]
			UIElement[DrinkMerchant@Config@InvPages@Inventory@Pages@Cerebrum]:SetText[${This.DrinkMerch}]
			This:Output[Set and Saved Drink Vendor name as ${This.DrinkMerch}]
			}
			else
			{
				This:Output["Please Target the Drink Merchant First"]
			}
		}
		else
		{
			This.DrinkMerch:Set[""]
			LavishSettings[Settings]:AddSetting[DrinkMerch,${This.DrinkMerch}]
			UIElement[DrinkMerchant@Config@InvPages@Inventory@Pages@Cerebrum]:SetText[${This.DrinkMerch}]
		}
	}
	method SetAmmo()
	{
		if ${Target.Name(exists)}
		{
			if ${Target.IsMerchant}
			{
			This.AmmoMerch:Set[${Target.Name}]
			LavishSettings[Settings]:AddSetting[AmmoMerch,${This.AmmoMerch}]
			UIElement[AmmoMerchant@Config@InvPages@Inventory@Pages@Cerebrum]:SetText[${This.AmmoMerch}]
			This:Output[Set and Saved Ammo Vendor name as ${This.AmmoMerch}]
			}
			else
			{
				This:Output["Please Target the Ammo Merchant First"]
			}
		}
		else
		{
			This.AmmoMerch:Set[""]
			LavishSettings[Settings]:AddSetting[AmmoMerch,${This.AmmoMerch}]
			UIElement[AmmoMerchant@Config@InvPages@Inventory@Pages@Cerebrum]:SetText[${This.AmmoMerch}]
		}
	}

	
	method SetEnterKey()
	{
		LavishSettings[Settings]:AddSetting[EnterKey,${UIElement[EnterKey@Logout@Pages@Cerebrum].Text}]
		This:Output[Set and Saved EnterKey as ${UIElement[EnterKey@Logout@Pages@Cerebrum].Text}]
	}
	method SetAccountName()
	{
		LavishSettings[Settings]:AddSetting[AccountName,${UIElement[AccountName@Logout@Pages@Cerebrum].Text}]
		This:Output[Set and Saved AccountName as ${UIElement[AccountName@Logout@Pages@Cerebrum].Text}]
	}
	method SetPassword()
	{
		LavishSettings[Settings]:AddSetting[Password,${UIElement[Password@Logout@Pages@Cerebrum].Text}]
		This:Output[Set and Saved Password as ${UIElement[Password@Logout@Pages@Cerebrum].Text}]
	}
	method SetAutoReconnect()
	{
		LavishSettings[Settings]:AddSetting[chkAutoReconnect,${UIElement[chkAutoReconnect@Logout@Pages@Cerebrum].Checked}]
	}
	
	

	
	;AutoSell, AutoDestroy, AutoBank, AutoMule, DestroyRarity, SellRarity, BankRarity, MuleRarity

	member StackMotes()
	{		
		if ${This.ItemCount[Mote of Fire]} >= 10
		{
			Item[Mote of Fire]:Use
		}	
		elseif ${This.ItemCount[Mote of Water]} >= 10
		{
			Item[Mote of Water]:Use
		}		
		elseif ${This.ItemCount[Mote of Air]} >= 10
		{
			Item[Mote of Air]:Use
		}		
		elseif ${This.ItemCount[Mote of Earth]} >= 10
		{
			Item[Mote of Earth]:Use
		}		
		elseif ${This.ItemCount[Mote of Life]} >= 10
		{
			Item[Mote of Life]:Use
		}		
		elseif ${This.ItemCount[Mote of Mana]} >= 10
		{
			Item[Mote of Mana]:Use
		}		
		elseif ${This.ItemCount[Mote of Shadow]} >= 10
		{
			Item[Mote of Shadow]:Use
		}
		else
		{
			return FALSE
		}
		return TRUE		
	}
	
	method Pulse()
	{
		This:UpdateItemsGUI
		
		if ${This.NeedRepair}
		{
			POI.NeedRepair:Set[TRUE]
		}
		
		if ${This.NeedSell}
		{
			POI.NeedSell:Set[TRUE]
		}
			
		if ${This.needSpecialCheck}
		{
			if ${This.NeedRestock} > 0
			{
				POI.NeedRestock:Set[TRUE]
			}
			if ${POI.NeedSell}   /* only trade skill when we plan to sell */
			{
				if ${Tradeskills.NeedTradeSkill}
				{
					POI.NeedTradeSkill:Set[TRUE] 
				}
			}
			This.needSpecialCheck:Set[FALSE]
		}
		This.FreeSlots:Set[${This.GetBagsInfo[0,"normal"]}]
	}
	
	method BagUpdate()
	{
		This:VoidCheck
		if !${This.InVoid}
		{
			Autoequip.NeedEQ:Set[TRUE]
			This.needSpecialCheck:Set[TRUE]
			This:UpdateItemsGUI
			This.FreeSlots:Set[${This.GetBagsInfo[0,"normal"]}]
		}
	}
	
	variable int VoidTime = 0
	variable int LastVoidTime = 0
	
	member InVoid()
	{
		if ${This.LastVoidTime} > ${LavishScript.RunningTime}
		{
			return TRUE
		}
		return FALSE
	}
	method VoidCheck()
	{
		if ${This.VoidTime} < ${LavishScript.RunningTime} && ${This.LastVoidTime} <= ${LavishScript.RunningTime}
		{
			This.LastVoidTime:Set[${This.InSeconds[60]}]
			This:Output["Entered a Void Area. Most likely zoning!"]
		}
		This.VoidTime:Set[${This.InSeconds[60]}]
	}
	
	member NeedRepair()
	{
		variable int i
		variable int total = 0
		variable int count = 0
		for(i:Set[1];${i} < 19;i:Inc)
		{
			if ${Me.Equip[${i}](exists)}
			{
				if ${Me.Equip[${i}].PctDurability} < ${This.lowestRpairPct}
				{
					return TRUE
				}
				total:Inc[${Me.Equip[${i}].PctDurability}]
				count:Inc
			}
		}
		if ${Math.Calc[${total}/${count}]} < ${This.overAllRepairPCT}
		{
			return TRUE
		}
		return FALSE
	}
	;needs to be done
	member NeedRestock(int theIndex = 0)
	{
		variable set restocks
		variable iterator iter
		RestockList:GetIterator[iter]
		iter:First
		while ${iter.IsValid}
		{
			; If we are restocking then fill to max
			if ( ${This.StackCount[${iter.Key}]} < ${iter.Value.Max} && !${iter.Value.Disabled} ) && ${POI.NeedRestock}
			{
				restocks:Add[${iter.Value.myType}]
			}
			if ${This.StackCount[${iter.Key}]} <= ${iter.Value.Min} && !${iter.Value.Disabled}
			{
				restocks:Add[${iter.Value.myType}]
			}
			iter:Next
		}
		
		if ${theIndex} == 0
		{
			;if ${POI.NeedRestock}
			;{
			;	return 1
			;}
			return ${restocks.Used}
		}
		elseif ${theIndex} > 0
		{
			restocks:GetIterator[iter]
			iter:First
			while ${theIndex} > 1 && ${iter.IsValid}
			{
				iter:Next
				theIndex:Dec
			}
			return ${iter.Key}
		}
	}

	member NeedSell()
	{
		if ${This.GetBagsInfo[0,"normal"]} <= ${This.leaveFreeSlots} && ${Object[${This.GetSlot[Sell]}](exists)}
		{
			return TRUE
		}
		return FALSE
	}


	method Initialize()
	{	
		This.AmmoMerch:Set[${LavishSettings[Settings].FindSetting[AmmoMerch,""]}]
		This.FoodMerch:Set[${LavishSettings[Settings].FindSetting[FoodMerch,""]}]
		This.DrinkMerch:Set[${LavishSettings[Settings].FindSetting[DrinkMerch,""]}]
		This.MuleCharName:Set[${LavishSettings[Settings].FindSetting[muleName,""]}]
		This:LoadLists
	}
	
	method Shutdown()
	{
		This:SaveLists
	}
	
	member SellRarity()
	{
		variable int rarity = ${UIElement[cmbAutoSell@Config@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Value}
		return ${rarity}
	}
	
	member MuleRarity()
	{
		variable int rarity = ${UIElement[cmbAutoMule@Config@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Value}
		if ${rarity}==0
		{
			return 99
		}
		return ${rarity}
	}
	
	method ExportList(string theList)
	{
		variable iterator iter

		LavishSettings[Settings].FindSet[Inventory].FindSet[${theList}]:Clear
		${theList}:GetIterator[iter]
		iter:First
		while ${iter.IsValid}
		{
			LavishSettings[Settings].FindSet[Inventory].FindSet[${theList}]:AddSetting[${iter.Key},${iter.Key}]
			iter:Next
		}
		
	}
	method SaveLists()
	{
		
		This:ExportList[SellList]
		This:ExportList[KeepList]
		This:ExportList[MuleList]
		This:ExportList[BankList]
		This:ExportList[DestroyList]
		This:ExportList[OpenList]
		This:SaveRestockList
		LavishSettings[Settings]:Export["config/settings/${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Name}.xml"]
	}
	
	method LoadList(string theList)
	{
		variable iterator iter
		
		if !${LavishSettings[Settings].FindSet[Inventory].FindSet[${theList}](exists)}
		{
			LavishSettings[Settings].FindSet[Inventory]:AddSet[${theList}]
		}		
		LavishSettings[Settings].FindSet[Inventory].FindSet[${theList}]:GetSettingIterator[iter]
		
		iter:First
		while ${iter.IsValid}
		{
			${theList}:Add[${iter.Key}]
			iter:Next
		}
		
	}
	method LoadLists()
	{
		LavishSettings[Settings]:Import["config/settings/${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Name}.xml"]
	
		if !${LavishSettings[Settings].FindSet[Inventory](exists)}
		{
			LavishSettings[Settings]:AddSet[Inventory]
		}
		This:LoadList[SellList]
		This:LoadList[KeepList]
		This:LoadList[MuleList]
		This:LoadList[BankList]
		This:LoadList[DestroyList]
		This:LoadList[OpenList]
		This:LoadRestockList
		
	}
	method LoadRestockList()
	{
		variable iterator iter
		
		if !${LavishSettings[Settings].FindSet[Inventory].FindSet[Restock](exists)}
		{
			LavishSettings[Settings].FindSet[Inventory]:AddSet[Restock]
		}		
		LavishSettings[Settings].FindSet[Inventory].FindSet[Restock]:GetSetIterator[iter]
		
		while ${iter.IsValid}
		{
			RestockList:Set[${iter.Key},${iter.Key},${iter.Value.FindSetting[Min,0]},${iter.Value.FindSetting[Max,0]},${iter.Value.FindSetting[Type,""]}]	
			iter:Next
		}
	}
	method SaveRestockList()
	{
		variable iterator iter
		LavishSettings[Settings].FindSet[Inventory].FindSet[Restock]:Clear
		
		RestockList:GetIterator[iter]
		iter:First
		
		while ${iter.IsValid}
		{
			LavishSettings[Settings].FindSet[Inventory].FindSet[Restock]:AddSet[${iter.Key}]
			LavishSettings[Settings].FindSet[Inventory].FindSet[Restock].FindSet[${iter.Key}]:AddSetting[Min,${iter.Value.Min}]
			LavishSettings[Settings].FindSet[Inventory].FindSet[Restock].FindSet[${iter.Key}]:AddSetting[Max,${iter.Value.Max}]
			LavishSettings[Settings].FindSet[Inventory].FindSet[Restock].FindSet[${iter.Key}]:AddSetting[Type,${iter.Value.myType}]
			iter:Next
		}
	}
	
/*
 * Start GUI Add/Delete Buttons
 */
 


/*
 * End GUI Add/Delete Buttons
 */

		


	member CheckQuestItem(string strItemName)
	{
		if ${WoWScript[GetItemInfo("${strItemName}"),6].Equal["Quest"]}
		{
			return TRUE
		}
		return FALSE
	}

	member GetBagType(string strBagName)
	{
		if ${strBagName.Find[Quiver]}||${strBagName.Equal[Ancient Sinew Wrapped Lamina]}
			return "quiver"
		if ${strBagName.Find[Ammo Pouch]}||${strBagName.Find[Shot Pouch]}||${strBagName.Find[Ammo Sack]}||${strBagName.Find[Bandolier]}
			return "ammo"
		if ${strBagName.Equal[Spellfire Bag]}||${strBagName.Find[Enchant]}
			return "enchanting"
		if ${strBagName.Equal[Satchel of Cenarius]}||${strBagName.Find[Herb]}
			return "herbalism"
		if ${strBagName.Find[Toolbox]}
			return "engineering"
		if ${strBagName.Equal[Bag of Jewels]}||${strBagName.Equal[Gem Pouch]}
			return "jewelcrafting"
		if ${strBagName.Find[Mining]}
			return "mining"
		if ${strBagName.Equal[Ebon Shadowbag]}||${strBagName.Find[Felcloth]}||${strBagName.Find[Soul]}
			return "lock"	
		return "normal"
	}

	member GetBagsInfo(int intInfoType,string strBagType)
	{
		; intInfoType = what you want to retrieve - see defines
		; strBagType = the bag type you want to get info from

		variable int intBags = 0
		variable int intTotalSlots = 0
		variable int intFreeSlots = 0

		do
		{
			if ${strBagType.Equal["all"]}
			{
				intFreeSlots:Inc[${Me.Bag[${intBags}].EmptySlots}]
				intTotalSlots:Inc[${Me.Bag[${intBags}].Slots}]
			}
			elseif ${This.GetBagType[${Me.Bag[${intBags}].Name}].Equal["${strBagType}"]}
			{
				intFreeSlots:Inc[${Me.Bag[${intBags}].EmptySlots}]
				intTotalSlots:Inc[${Me.Bag[${intBags}].Slots}]
			}
		}
		while ${Me.Bag[${intBags:Inc}](exists)}
      	
		switch ${intInfoType}
		{
			case RETRIEVE_FREESLOTS
				return ${intFreeSlots}
				break
			case RETRIEVE_TOTALSLOTS
				return ${intTotalSlots}
				break
			case RETRIEVE_BAGCOUNT
				return ${intBags}
				break
		}
	}

	member GetTotalSlots(intBag)
	{
		variable int intTotalSlots = 0

		if ${Me.Bag[${intBag}](exists)}
		{
			intTotalSlots:Inc[${Me.Bag[${intBag}].Slots}]
		}
		return ${intTotalSlots}
	}
	member GetFreeSlots(intBag)
	{
		variable int intFreeSlots = 0

		if ${Me.Bag[${intBag}](exists)}
		{
			intFreeSlots:Inc[${Me.Bag[${intBag}].Slots}]
		}
		return ${intFreeSlots}
	}
	



	member isItem(string theType,string myItem)
	{
		return ${${theType}List.Contains[${myItem}]}		
	}

	
	member ItemCount(string strItemName)
	{
		variable guidlist lstItemList
		variable int intTotalCount = 0
		variable int Index = 1

		lstItemList:Search[-items,-inventory,${strItemName}]
		if ${lstItemList.Count}
		{
			do
			{
				if ${Item[${lstItemList.GUID[${Index}]}].Name.Equal["${strItemName}"]}
				{
					intTotalCount:Inc[${Item[${lstItemList.GUID[${Index}]}].StackCount}]
				}
			}
			while ${Index:Inc}<=${lstItemList.Count}
		}
		return ${intTotalCount}
	}
	member StackCount(string strItemName)
	{
		variable guidlist lstItemList
		variable float intTotalCount = 0
		variable int Index = 1

		lstItemList:Search[-items,-inventory,${strItemName}]
		if ${lstItemList.Count}
		{
			do
			{
				if ${Item[${lstItemList.GUID[${Index}]}].Name.Equal["${strItemName}"]}
				{
					intTotalCount:Inc[${Math.Calc[${lstItemList.Object[${Index}].StackCount}/${lstItemList.Object[${Index}].Stats.MaxStackCount}]}]
				}
			}
			while ${Index:Inc}<=${lstItemList.Count}
		}
		return ${intTotalCount}
	}
	
	
	member GetSlot(string theType,string Requirements = "")
	{
		variable guidlist ItemList
		variable int i = 1

		if ${Requirements.Equal[""]}
		{
			ItemList:Search[-items,-inventory] 
		}
		else
		{
			ItemList:Search[-items,-inventory,${Requirements}] 
		}
		
		for(i:Set[1];${i} <= ${ItemList.Count};i:Inc)
		{
				if ${This.isItem[${theType},${ItemList.Object[${i}].Name}]} && !${WoWScript[GetItemInfo("${ItemList.Object[${i}].Name}"),6].Equal["Quest"]} 
				{
					if !${ItemList.Object[${i}].Name.Find["Conjured"]} && !${ItemList.Object[${i}].Name.Find["Healthstone"]}
					{
						return ${ItemList.GUID[${i}]}
					}
				}
		}
	}	



 ; GUI Update Methods
 
 	method UpdateItemsGUI()
 	{
 		variable int i
 		variable guidlist items
 		items:Search[-inventory,-items]
 		for(i:Set[1];${i} <= ${items.Count};i:Inc)
 		{
 			This:AddItem[${items.GUID[${i}]}]
 		}
 		This:UpdateItemLists
 	}
	method UpdateListed(string theList,int theColor)
	{
		variable iterator iter
		${theList}List:GetIterator[iter]
		iter:First
		while ${iter.IsValid}
		{
			UIElement[lstListed@Items@InvPages@Inventory@Pages@Cerebrum]:AddItem[\[${theList}\]${iter.Key},${theColor}]			
			iter:Next
		}
	}
	method UpdateNotListed()
	{
		variable iterator iter
		List:GetIterator[iter]
		iter:First
		while ${iter.IsValid}
		{
			UIElement[lstInventory@Items@InvPages@Inventory@Pages@Cerebrum]:AddItem[${iter.Key}]
			iter:Next
		}
	}
	member ItemListed(string theItem)
	{
		if ${This.isItem[Sell,${theItem}]} || ${This.isItem[Keep,${theItem}]} || ${This.isItem[Mule,${theItem}]}
		{
			return TRUE
		}
		if ${This.isItem[Bank,${theItem}]} || ${This.isItem[Destroy,${theItem}]} || ${This.isItem[Open,${theItem}]}
		{
			return TRUE
		}
		return FALSE
	}
	method AddItem(string GUID)
	{
		if !${This.ItemListed[${Item[${GUID}].Name}]}
		{
			if ${Item[${GUID}].Rarity} >= ${This.MuleRarity} && ${This.CanSellItem[${GUID}]} && !${Item[${GUID}].Soulbound} 
			{
				echo AutoMule (${This.MuleRarity}) adds to list ${Item[${GUID}].Name}(${Item[${GUID}].Rarity})
				This:Output[AutoMule (${This.MuleRarity}) adds to list ${Item[${GUID}].Name}(${Item[${GUID}].Rarity})]
				MuleList:Add[${Item[${GUID}].Name}]
			}
			elseif ${Item[${GUID}].Rarity} <= ${This.SellRarity} && ${This.CanSellItem[${GUID}]}
			{
				SellList:Add[${Item[${GUID}].Name}]
			}
			else
			{
				List:Add[${Item[${GUID}].Name}]
			}
		}
	}

	member CanSellItem(string GUID)
	{
		if ${Item[${GUID}].StartsQuest} || ${Item[${GUID}].Openable}
		{
			return FALSE
		}
		elseif ${Item[${GUID}].SellPrice} == 0
		{
			return FALSE
		}
		return TRUE
	}
	
	method UpdateItemLists()
	{
		UIElement[lstListed@Items@InvPages@Inventory@Pages@Cerebrum]:ClearItems
		UIElement[lstInventory@Items@InvPages@Inventory@Pages@Cerebrum]:ClearItems
		This:UpdateListed[Sell,INV_SELL]
		This:UpdateListed[Keep,INV_KEEP]
		This:UpdateListed[Mule,INV_MULE]
		This:UpdateListed[Bank,INV_BANK]
		This:UpdateListed[Destroy,INV_DESTROY]
		This:UpdateListed[Open,INV_OPEN]
		This:UpdateNotListed
	}
	
	method Add(string theList)
 	{
 		if ${UIElement[lstInventory@Items@InvPages@Inventory@Pages@Cerebrum].SelectedItem(exists)}
		{
			${theList}List:Add[${UIElement[lstInventory@Items@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text}]
			List:Remove[${UIElement[lstInventory@Items@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text}]
			This:UpdateItemsGUI
		}
 	}
 	method Delete()
 	{
 		variable int TextColor
 		if ${UIElement[lstListed@Items@InvPages@Inventory@Pages@Cerebrum].SelectedItem(exists)}
		{
			TextColor:Set[${UIElement[lstListed@Items@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Value}]
			switch ${TextColor}
			{
				case INV_SELL		
				SellList:Remove[${UIElement[lstListed@Items@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text.Mid[7,100]}]
				break
				case INV_KEEP
				KeepList:Remove[${UIElement[lstListed@Items@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text.Mid[7,100]}]
				break
				case INV_MULE
				MuleList:Remove[${UIElement[lstListed@Items@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text.Mid[7,100]}]
				break
				case INV_BANK
				BankList:Remove[${UIElement[lstListed@Items@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text.Mid[7,100]}]
				break
				case INV_DESTROY
				DestroyList:Remove[${UIElement[lstListed@Items@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text.Mid[10,100]}]
				break
				case INV_OPEN
				OpenList:Remove[${UIElement[lstListed@Items@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text.Mid[7,100]}]
				break		
			}
			This:UpdateItemsGUI
		}
 	}
 	method AddRestock()
 	{
 		if !${UIElement[lstInventory@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem(exists)}
 		{
 			return
 		}
 		RestockList:Set[${UIElement[lstInventory@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text},${UIElement[lstInventory@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text},${UIElement[cmbMinAmount@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text},${UIElement[cmbMaxAmount@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text},${UIElement[cmbType@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text}]
 		This:UpdateRestockGUI
 	}
 	method RemoveRestock()
 	{
 		if !${UIElement[lstListed@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem(exists)}
 		{
 			return
 		}
 		RestockList:Erase[${UIElement[lstListed@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text}]
 		This:UpdateRestockGUI
 	}
 	method UpdateRestockGUI()
 	{
 		variable int i
 		variable guidlist list
 		variable iterator iter
 		list:Search[-items,-inventory]

 		UIElement[lstListed@Restock@InvPages@Inventory@Pages@Cerebrum]:ClearItems
 		UIElement[lstInventory@Restock@InvPages@Inventory@Pages@Cerebrum]:ClearItems
 		
 		for(i:Set[1];${i} <= ${list.Count};i:Inc)
 		{
 			if !${RestockList.Element[${list.Object[${i}].Name}](exists)}
			{	
	 			UIElement[lstInventory@Restock@InvPages@Inventory@Pages@Cerebrum]:AddItem[${list.Object[${i}].Name}]
	 		}
	 	}
	 	RestockList:GetIterator[iter]
	 	iter:First
	 	while ${iter.IsValid}
	 	{
	 		UIElement[lstListed@Restock@InvPages@Inventory@Pages@Cerebrum]:AddItem[${iter.Key}]
	 		iter:Next
	 	}
	}	
	method RestockSettingUpdate()
 	{
 		variable string theItem = ${UIElement[lstListed@Restock@InvPages@Inventory@Pages@Cerebrum].SelectedItem.Text}
 		variable int id
 		
 		id:Set[${UIElement[cmbMinAmount@Restock@InvPages@Inventory@Pages@Cerebrum].ItemByText[${RestockList.Element[${theItem}].Min}].ID}]
		UIElement[cmbMinAmount@Restock@InvPages@Inventory@Pages@Cerebrum]:SetSelection[${id}]
 		id:Set[${UIElement[cmbMaxAmount@Restock@InvPages@Inventory@Pages@Cerebrum].ItemByText[${RestockList.Element[${theItem}].Max}].ID}]
		UIElement[cmbMaxAmount@Restock@InvPages@Inventory@Pages@Cerebrum]:SetSelection[${id}]		
		id:Set[${UIElement[cmbType@Restock@InvPages@Inventory@Pages@Cerebrum].ItemByText[${RestockList.Element[${theItem}].myType}].ID}]
		UIElement[cmbType@Restock@InvPages@Inventory@Pages@Cerebrum]:SetSelection[${id}]
 		
 	}

	member Destroy()
 	{
 		if ${CursorItem}
		{
			CursorItem:Delete
			return FALSE
		}
		if ${This.GetSlot[Destroy](exists)}
		{
			Item[${Inventory.GetSlot[Destroy]}]:PickUp
			return FALSE
		}
		return TRUE
 	}
 	member Open()
 	{
 		if ${This.GetSlot[Open](exists)}
 		{
 			Item[${This.GetSlot[Open]}]:Use
 			return FALSE
 		}
 		return TRUE
 	}
 	member Bank()
 	{
 		if !${WowScript[BankFrame:IsShown()]}
 		{
 			return TRUE
 		}	
 		if ${This.GetSlot[Bank](exists)}
 		{
 			This:PutBankItem[${This.GetSlot[Bank]}]
 			return FALSE
 		}
 		return TRUE
 	}
 	
 	method PutBankItem(string theName)
 	{ 
 		if ${Item[-inventory,${theName}](exists)}
 		{
 			Item[-inventory,${theName}]:Use
 		}
 	}
 	method GetBankItem(string theName)
 	{
 		if ${Item[-bank,${theName}](exists)}
 		{
 			Item[-bank,${theName}]:Use
 		}
 	}

 	member BuyItem(string theName,int Quantity = 1)
 	{
 		variable int i
 		variable int total = ${WoWScript[GetMerchantNumItems()]}

 		for(i:Set[1];${i} <= ${total};i:Inc)
 		{
 			if ${WoWScript[GetMerchantItemInfo(${i}),1].Equal[${theName}]} && ${Math.Calc[${Quantity}*${WoWScript[GetMerchantItemInfo(${i}),3]}]} < ${Me.Coinage}
 			{
 				WoWScript BuyMerchantItem(${i}\,${Quantity})
 				return TRUE
 			}
 		}
 		return FALSE
 	}
 	

 	
}

