objectdef cConsumable inherits cBase
{
	variable guidlist ItemList
	variable guidlist HPotList
	variable guidlist MPotList
	variable guidlist BandageList
	variable guidlist ScrollList
	variable guidlist FoodList
	variable guidlist DrinkList
	
	variable int NextFeading = 0
	variable int NextDrinking = 0

	member HasFood()
	{
		FoodList:Search[-usable,-items,-inventory,-food]
    	if ${FoodList.Count}
		{
     		return TRUE
    	}
	return FALSE
	}
	
	member HasDrink()
	{
		DrinkList:Search[-usable,-items,-inventory,-drink]
		if ${DrinkList.Count}
		{
			return TRUE
		}
	return FALSE
	}
	
	member ItemX(string itemx)
	{
	ItemList:Search[-inventory,"${itemx}"]
	return ${ItemList.Count}
	}
	
	member HasMPot()
	{
		variable int i = 1
		MPotList:Search[-usable,-items,-inventory,"Mana Potion"]
			for (i:Set[1] ; ${i} <= ${MPotList.Count} ; i:Inc)
			{
				if !${Item[${MPotList.GUID[${i}]}].Name.Find["Schematic"]} && !${Item[${MPotList.GUID[${i}]}].Name.Find["Writ"]} && !${Item[${MPotList.GUID[${i}]}].Name.Find["Recipe"]}
				{
					if ${Item[${MPotList.GUID[${i}]}].Usable}
					{
						return TRUE
					}
				}
			}
	return FALSE		
	}
		
	member HasHPot()
	{
		variable int i = 1
		HPotList:Search[-usable,-items,-inventory,"Healing Potion"]
			for (i:Set[1] ; ${i} <= ${HPotList.Count} ; i:Inc)
			{
				if !${Item[${HPotList.GUID[${i}]}].Name.Find["Schematic"]} && !${Item[${HPotList.GUID[${i}]}].Name.Find["Writ"]} && !${Item[${HPotList.GUID[${i}]}].Name.Find["Recipe"]}
				{
					if ${Item[${HPotList.GUID[${i}]}].Usable} && ${WoWScript[GetItemCooldown("${Item[${HPotList.GUID[${i}]}]}")]} == 0 
					{
						return TRUE
					}
				}
			}
	return FALSE
	}
		
	member HasBandage()
	{
		variable int i = 1
		BandageList:Search[-usable,-items,-inventory,"Bandage"]
			for (i:Set[1] ; ${i} <= ${BandageList.Count} ; i:Inc)
			{
				if !${Item[${BandageList.GUID[${i}]}].Name.Find["Manual"]} && !${Item[${BandageList.GUID[${i}]}].Name.Find["Crusted"]} && !${Item[${BandageList.GUID[${i}]}].Name.Find["Bloodied"]}
				{
					if ${Item[${BandageList.GUID[${i}]}].Usable} && !${Me.Buff[Recently Bandaged](exists)}
					{
						return TRUE
					}
				}
			}
	return FALSE		
	}

	member HasScroll(string ScrollName=NULL)
	{
		if ${ScrollName.Equal[NULL]}
		{
			return FALSE
		}
			
		ScrollList:Search[-usable,-items,-inventory,Scroll of ${ScrollName}]
			
			if ${ScrollList.Count}
			{
				return TRUE
			}		
	return FALSE
	}	
		
	method useFood()
	{
		if ${LavishScript.RunningTime} < ${This.NextFeading}
		{
			return
		}
		This.NextFeading:Set[${Math.Calc[${LavishScript.RunningTime}+(3 * ${Bot.GlobalCooldown})]}]
		
		declare inti int 0
		declare lastLevel int 0
		declare lastconjured int 0
		declare BestFood int 0
		declare laststacksize int 0

		FoodList:Search[-usable,-items,-inventory,-food]
	
		This:Debug["Finding Best Food"]

		while ${inti:Inc}<=${FoodList.Count}
		{
			if ${Item[${FoodList.GUID[${inti}]}].MinLevel}>${LastLevel} && ${Item[${FoodList.GUID[${inti}]}].MinLevel}<=${Me.Level}
			{
				lastLevel:Set[${Item[${FoodList.GUID[${inti}]}].MinLevel}]
				laststacksize:Set[${Item[${FoodList.GUID[${inti}]}].StackCount}]
				BestFood:Set[${inti}]
				;add check to set lastconjured here!
   		   	}
			elseif ${Item[${FoodList.GUID[${inti}]}].MinLevel} == ${LastLevel} && ${laststacksize} < ${Item[${FoodList.GUID[${inti}]}].StackCount} && ${Item[${FoodList.GUID[${inti}]}].MinLevel}<=${Me.Level}
      		{
				lastLevel:Set[${Item[${FoodList.GUID[${inti}]}].MinLevel}]
				laststacksize:Set[${Item[${FoodList.GUID[${inti}]}].StackCount}]
				BestFood:Set[${inti}]
				;add check to set lastconjured here!
			}
		}
		This:Output["Eating: ${Item[${FoodList.GUID[${BestFood}]}].Name}"]
		Item[${FoodList.GUID[${BestFood}]}]:Use
	}
		
	method useDrink()
	{
		if ${LavishScript.RunningTime} < ${This.NextDrinking}
		{
			return
		}
		This.NextDrinking:Set[${Math.Calc[${LavishScript.RunningTime}+(3 * ${Bot.GlobalCooldown})]}]

		declare inti int 0
		declare lastLevel int 0
		declare lastconjured int 0
		declare BestDrink int 0
		declare laststacksize int 0

		DrinkList:Search[-usable,-items,-inventory,-drink]

		This:Debug["Finding Best Drink"]

		while ${inti:Inc}<=${DrinkList.Count}
		{
			if ${Item[${DrinkList.GUID[${inti}]}].MinLevel}>${LastLevel} && ${Item[${DrinkList.GUID[${inti}]}].MinLevel}<=${Me.Level}
			{
				lastLevel:Set[${Item[${DrinkList.GUID[${inti}]}].MinLevel}]
         		laststacksize:Set[${Item[${DrinkList.GUID[${inti}]}].StackCount}]
				BestDrink:Set[${inti}]
				;add check to set lastconjured here!
			}
			elseif ${Item[${DrinkList.GUID[${inti}]}].MinLevel}==${LastLevel} && ${laststacksize}<${Item[${DrinkList.GUID[${inti}]}].StackCount} && ${Item[${DrinkList.GUID[${inti}]}].MinLevel}<=${Me.Level}
			{
				This:Debug["New Best: ${inti}: ${Item[${DrinkList.GUID[${inti}]}].Name} ${Item[${DrinkList.GUID[${inti}]}].MinLevel}"]
				lastLevel:Set[${Item[${DrinkList.GUID[${inti}]}].MinLevel}]
				laststacksize:Set[${Item[${DrinkList.GUID[${inti}]}].StackCount}]
				BestDrink:Set[${inti}]
				;add check to set lastconjured here!
			}
		}
		This:Output["Drinking: ${Item[${DrinkList.GUID[${BestDrink}]}].Name}"]
		Item[${DrinkList.GUID[${BestDrink}]}]:Use
	}
		
	method useMPot()
	{
		declare inti int 0
		declare lastLevel int 0
		declare BestMPot int 0
		declare laststacksize int 0
		MPotList:Search[-item,-inventory,"Mana Potion"]

		This:Debug["Finding Best Mana Potion"]

		while ${inti:Inc}<=${MPotList.Count}
		{
			if ${Item[${MPotList.GUID[${inti}]}].MinLevel}>${lastLevel} && ${Item[${MPotList.GUID[${inti}]}].MinLevel}<=${Me.Level}
			{
				lastLevel:Set[${Item[${MPotList.GUID[${inti}]}].MinLevel}]
				laststacksize:Set[${Item[${MPotList.GUID[${inti}]}].StackCount}]
				BestMPot:Set[${inti}]
			}
			elseif ${Item[${MPotList.GUID[${inti}]}].MinLevel} == ${lastLevel} && ${laststacksize} < ${Item[${MPotList.GUID[${inti}]}].StackCount} && ${Item[${MPotList.GUID[${inti}]}].MinLevel}<=${Me.Level}
			{
				lastLevel:Set[${Item[${MPotList.GUID[${inti}]}].MinLevel}]
				laststacksize:Set[${Item[${MPotList.GUID[${inti}]}].StackCount}]
				BestMPot:Set[${inti}]
			}
		}
		This:Output["Using Potion: ${Item[${MPotList.GUID[${BestMPot}]}].Name}"]
		Item[${MPotList.GUID[${BestMPot}]}]:Use
	}
	
	method useHPot()
	{
		declare inti int 0
		declare lastLevel int 0
		declare BestHPot int 0
		declare laststacksize int 0
		HPotList:Search[-item,-inventory,"Healing Potion"]

		This:Debug["Finding Best Health Potion"]

		while ${inti:Inc}<=${HPotList.Count}
		{
			if ${Item[${HPotList.GUID[${inti}]}].MinLevel}>${lastLevel} && ${Item[${HPotList.GUID[${inti}]}].MinLevel}<=${Me.Level}
			{
				lastLevel:Set[${Item[${HPotList.GUID[${inti}]}].MinLevel}]
				laststacksize:Set[${Item[${HPotList.GUID[${inti}]}].StackCount}]
				BestHPot:Set[${inti}]
			}
			elseif ${Item[${HPotList.GUID[${inti}]}].MinLevel} == ${lastLevel} && ${laststacksize} < ${Item[${HPotList.GUID[${inti}]}].StackCount} && ${Item[${HPotList.GUID[${inti}]}].MinLevel}<=${Me.Level}
			{
				lastLevel:Set[${Item[${HPotList.GUID[${inti}]}].MinLevel}]
				laststacksize:Set[${Item[${HPotList.GUID[${inti}]}].StackCount}]
				BestHPot:Set[${inti}]
			}
		}
		This:Output["Using Potion: ${Item[${HPotList.GUID[${BestHPot}]}].Name}"]
		Item[${HPotList.GUID[${BestHPot}]}]:Use
	}
		
	method useBandage()
	{
		declare inti int 0
		declare lastLevel int 0
		declare BestBandage int 0
		declare laststacksize int 0
		BandageList:Search[-item,-inventory,"Bandage"]

		This:Debug["Finding Best Bandage"]

		while ${inti:Inc}<=${BandageList.Count}
		{
			if ${Item[${BandageList.GUID[${inti}]}].MinLevel}>${lastLevel} && ${Item[${BandageList.GUID[${inti}]}].MinLevel}<=${Me.Level}
			{
				lastLevel:Set[${Item[${BandageList.GUID[${inti}]}].MinLevel}]
				laststacksize:Set[${Item[${BandageList.GUID[${inti}]}].StackCount}]
				BestBandage:Set[${inti}]
			}
			elseif ${Item[${BandageList.GUID[${inti}]}].MinLevel} == ${lastLevel} && ${laststacksize} < ${Item[${BandageList.GUID[${inti}]}].StackCount} && ${Item[${BandageList.GUID[${inti}]}].MinLevel}<=${Me.Level}
			{
				lastLevel:Set[${Item[${BandageList.GUID[${inti}]}].MinLevel}]
				laststacksize:Set[${Item[${BandageList.GUID[${inti}]}].StackCount}]
				BestBandage:Set[${inti}]
			}
		}
		This:Output["Using Bandage: ${Item[${BandageList.GUID[${BestBandage}]}].Name}"]
		Item[${BandageList.GUID[${BestBandage}]}]:Use
	}
			
	method UseScroll(string ScrollName = NULL, string Priority = "First")
	{
		if ${ScrollName.Equal[NULL]}
			{
			return
			}
		
		variable guidlist ItemList
		variable int i
		variable int j
		variable int BestRank
		variable objectref UseScroll
		
		variable string RomanNumerals[5]
		RomanNumerals[1]:Set[I]
		RomanNumerals[2]:Set[II]
		RomanNumerals[3]:Set[III]
		RomanNumerals[4]:Set[IV]
		RomanNumerals[5]:Set[V]
		
		ItemList:Search[-items,-inventory,"Scroll of ",${ScrollName}]
		
		switch ${Priority}
		{
			case First
				if ${ItemList.Count}
					{
						Item[${ItemList.GUID[1]}]:Use
					}
			break
			case Best
				BestRank:Set[1]
				if ${ItemList.Count}
				{
					for (i:Set[1] ; ${i} <= ${ItemList.Count} ; i:Inc)
					{
						for (j:Set[5] ; ${j} > 0 ; j:Dec)
						{
							if ${ItemList.Object[${i}].Name.Find[${RomanNumerals[${j}]}]} && ${j} > ${BestRank}
							{
								BestRank:Set[${j}]
								UseScroll:Set[${ItemList.GUID[${i}]}]
							}
						}
					}
					UseScroll:Use
				}
			break
			case Worst
				BestRank:Set[5]
				if ${ItemList.Count}
				{
					for (i:Set[1] ; ${i} <= ${ItemList.Count} ; i:Inc)
					{
						for (j:Set[1] ; ${j} <= 5 ; j:Inc)
						{
							if ${ItemList.Object[${i}].Name.Find[${RomanNumerals[${j}]}]} && ${j} < ${BestRank}
							{
								BestRank:Set[${j}]
								UseScroll:Set[${ItemList.GUID[${i}]}]
							}
						}
					}
					UseScroll:Use
				}
			break
			default
				This:Debug["Error in priority selection"]
			
		}
			
	}
		
	member NeedFood()
	{
		if !${This.HasFood}
		{
			return TRUE
		}
	return FALSE	
	}
		
	member NeedDrink()
	{
		if !${This.HasDrink}
		{
		return TRUE
		}
	return FALSE
	} 
	
	member GetIndex(string ItemToBuy)
	{
	variable int Idx = 1
		do
		{
			if ${WoWScript[GetMerchantItemInfo(${Idx})].Equal[${ItemToBuy}]}
			{
			return ${Idx}
			}
		}
		while ${WoWScript[GetMerchantItemInfo(${Idx:Inc})](exists)}
	}
	
	method MerchantBuy(int ik,string ItemToBuy)
	{

		variable float ze
		ze:Set[${Math.Calc[20/(${WoWScript[GetMerchantItemInfo(${This.GetIndex[${ItemToBuy}]}), 4]})]}]
		;${ze.Round} is the number we need to buy to make one stack and ${ik} is the number of stack we need
		; alas wowscript is gay, we need to loop the dirty mofo
		
		variable int i
		
		for (i:Set[1] ; ${i} <= ${ik} ; i:Inc)
		{
			WoWScript BuyMerchantItem(${Consumable.GetIndex["${ItemToBuy}"]},${ze.Round})
		}
	}
	
	member EnoughMoney(int ie, string ItemToBuy)
	{
	variable int TotalCost
	TotalCost:Set[${Math.Calc[${Item[${ItemToBuy}].BuyPrice}*${ie}]}]
		if ${TotalCost} <= ${Me.Coinage}
		{
		return TRUE
		}
		else
		{
		return FALSE
		}
	}
}
