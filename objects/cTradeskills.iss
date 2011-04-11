; Changes2007-06-25
; Added support for all crafting types

objectdef cTradeskills inherits cBase
{
	
	; Variables
	
	; First Aid
    variable collection:collection:int itemReagents
	variable index:string BestBandage
	variable guidlist BandList
	variable guidlist DEList	
	
	; Initialize
	method Initialize()
	{
		This:CreateBandageStrings		
		This:LearnBandageReagents			
	}

	
; State Triggers and Catches
;---------------------------

	/* Tradeskills.NeedTradeSkill should determine when tradeskills should start and stop */
	/* use to determine whether we should or shouldnt be doing or still doing tradeskill */
	member NeedTradeSkill()
	{
		return FALSE
	}
	
	/* should we be in TRADESKILL_MAKE */
	member NeedMake()
	{
		return FALSE
	}
	
	/* perform action in TRADESKILL_MAKE */
	method MakeTradeSkill()
	{
	}
	
	/* should we be in TRADESKILL_BUY */
	member NeedBuy()
	{
		return FALSE
	}
	
	/* perform action in TRADESKILL_BUY */
	method BuyTradeSkill()
	{
	}
	
	/* should we be in TRADESKILL_MOVE */
	member NeedTradePOI()
	{
		return FALSE
	}
	
	/* perform action in TRADESKILL_MOVE */
	method MoveToTradePOI()
	{
	}

	/* should we be in TRADESKILL_WAIT */
	member NeedWait()
	{
		return FALSE
	}


	method CheckNeedBandages()
	{
		if ${Spell["First Aid"](exists)} && ${UIElement[MakeBandages@TradeSkills@InvPages@Inventory@Pages@Cerebrum].Checked} && !${Toon.Sitting}
		{
			This.BandList:Search[-items,-inventory,Bandage]
			if ${This.BandList.Count} == 0 && !${This.makeableBandage[2].Equal["NONE"]}
			{
				This.BandList:Clear
				return TRUE
			}
			This.BandList:Clear
		}
		return FALSE
	}

	method CreateBandageStrings()
	{
		This.BestBandage:Resize[12]
		This.BestBandage:Set[1,"Heavy Netherweave Bandage"]
		This.BestBandage:Set[2,"Netherweave Bandage"]
		This.BestBandage:Set[3,"Heavy Runecloth Bandage"]
		This.BestBandage:Set[4,"Runecloth Bandage"]
		This.BestBandage:Set[5,"Heavy Mageweave Bandage"]
		This.BestBandage:Set[6,"Mageweave Bandage"]
		This.BestBandage:Set[7,"Heavy Silk Bandage"]
		This.BestBandage:Set[8,"Silk Bandage"]
		This.BestBandage:Set[9,"Heavy Wool Bandage"]
		This.BestBandage:Set[10,"Wool Bandage"]
		This.BestBandage:Set[11,"Heavy Linen Bandage"]
		This.BestBandage:Set[12,"Linen Bandage"]
	}
	
	/* makes the best possible bandage */
	method LearnBandageReagents()
	{
		variable int i = 1
		do
		{
			This:LearnReagents["First Aid","${This.BestBandage.Get[${i}]}"]
		}
		while ${This.BestBandage.Get[${i:Inc}](exists)}
	}


; Disenchanting
;--------------

	method CanWeDisenchant()
	{
		if ${Spell["Disenchant"](exists)} && ${UIElement[chkAutoDE@TradeSkills@InvPages@Inventory@Pages@Cerebrum].Checked} && !${Toon.Sitting}
		{
			This.DEList:Search[-items,-inventory,-uncommon,-notsoulbound]
			if ${This.DEList.Count} == 0
			{
				This.DEList:Clear
				return TRUE
			}
			This.DEList:Clear
		}
		return FALSE
	}



; General Functions
;------------------

	member checkReagentInventory(string itemName, int numToMake=1)
	{
		variable string reagentName
		variable int reagentHave
		variable int reagentNeed
		variable int reagentCheck
		variable bool canMake = TRUE
		if ${This.itemReagents.Element[${itemName}](exists)}&&(!${Me.Dead}||!${Me.Ghost})
		{
			if ${This.itemReagents.Element[${itemName}].FirstKey(exists)}
			{
				do
				{
					reagentName:Set[${This.itemReagents.Element[${itemName}].CurrentKey}]
					reagentNeed:Set[${This.itemReagents.Element[${itemName}].CurrentValue}]
					reagentHave:Set[${Inventory.ItemCount[${reagentName}]}]
					if ${reagentHave} < ${reagentNeed}
					{
						return FALSE
					}
					
					reagentCheck:Set[${Math.Calc[${reagentHave}/${reagentNeed}]}]
					if ${reagentCheck} < ${numToMake}
					{
						canMake:Set[FALSE]
					}
				}
				while ${This.itemReagents.Element[${itemName}].NextKey(exists)}
				return ${canMake}
			}
			return FALSE	
		}
		return FALSE
	}
	
	/* remember to "WoWScript CloseTradeSkill()" after use */	
	method LearnReagents(string skillProfession, string itemName)
	{
		variable int ItemIdx = 1
		variable int ReagentIdx = 1
		variable int reagentsTotal = 0
		variable int reagentNeed = 0
		variable string reagentName	
		variable collection:int reagentData
		if ${Spell[${skillProfession}](exists)}
		{
			if !${WoWScript[pcall(loadstring("TradeSkillFrame:IsShown()")), 1]}
			{
				Cast "${skillProfession}"
			}
			if !${WoWScript["TradeSkillFrame:IsShown()"]}
			{				
				Cast "${skillProfession}"
			}
			/* loop through all poisons */
			do
			{
				if ${WoWScript["TradeSkillFrame:IsShown()"]}
				{
					/* did we find the poison we are making? */
					if ${WoWScript[GetTradeSkillInfo(${ItemIdx})].Equal["${itemName}"]}
					{			
						/* how many different reagents are needed? */
						reagentsTotal:Set[${WoWScript[pcall(loadstring("local numReagents = GetTradeSkillNumReagents(${ItemIdx}) return numReagents")), 2]}]
						if !${reagentsTotal}
						{
							reagentsTotal:Set[0]	
						}
						if !${This.itemReagents[${WoWScript["GetTradeSkillInfo(${ItemIdx})"]}](exists)}
						{
							This.itemReagents:Set[${itemName}]
							/* create reagent list for poison */
							do
							{
								reagentNeed:Set[${WoWScript[pcall(loadstring("local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(${ItemIdx}, ${ReagentIdx}) return reagentCount")), 2]}]
								reagentName:Set[${WoWScript[pcall(loadstring("local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(${ItemIdx}, ${ReagentIdx}) return reagentName")), 2]}]
								if ${reagentNeed}
								{
									This.itemReagents.Element[${itemName}]:Set[${reagentName}, ${reagentNeed}]	
									echo "Learning Reagents: ${WoWScript[GetTradeSkillInfo(${ItemIdx})]} = ${reagentName} x${reagentNeed}"
								}
							}
							while ${WoWScript["GetTradeSkillReagentInfo(${ItemIdx}, ${ReagentIdx:Inc})"](exists)}
						}
					}
				}
			}
			while ${WoWScript["GetTradeSkillInfo(${ItemIdx:Inc})"](exists)}
			WoWScript CloseTradeSkill()
		}
	}






;----------------------------------------------------------------------------------------------------------	
; Action Functions	
;----------------------------------------------------------------------------------------------------------	

; First Aid Related
;------------------
	
	method MakeMeSomeBandages()
	{
		if ${UIElement[MakeBandages@TradeSkills@InvPages@Inventory@Pages@Cerebrum].Checked} && !${Toon.Sitting}
		{
			This.BandList:Search[-items,-inventory,Bandage]
			if ${This.BandList.Count} == 0 && !${This.makeableBandage[2].Equal["NONE"]}
			{
				This.BandList:Clear
				This:CreateBandages[${This.makeableBandage[2]}]
				Bot.RandomPause:Set[30]
				return
			}
			This.BandList:Clear
		}
	}
			
	method MakeBandage(string BandName, int NumBand)
	{
  		variable int Idx = 1
  		variable int BandIdx = 0
  		variable int currentNum = 0

		;Is the Tradeskill window already open?
		;If not then open it.
		if !${WoWScript[TradeSkillFrame:IsShown()]}
		{
			Cast "First Aid"
		}
		
		;Loop to find the index of our Bandage.
		do
		{
			if ${WoWScript[GetTradeSkillInfo(${Idx})].Equal["${BandName}"]} && ${WoWScript[TradeSkillFrame:IsShown()]}
			{
				BandIdx:Set[${Idx}]
			}
		}
		while ${WoWScript[GetTradeSkillInfo(${Idx:Inc})](exists)}
		
		;Create our bandage(s) and close the window.
		This:Output["Creating ${BandName} x ${NumBand}!"]
		WoWScript DoTradeSkill(${BandIdx}, ${NumBand})
		WoWScript CloseTradeSkill()	
	}

	/* create bandages in qty of 20,10,5 or 2 */
	method CreateBandages(string bandageName)
	{
		variable int i = 2
		variable int makeNum = 2
		/* check how many we can make */
		do
		{
			if ${This.checkReagentInventory[${bandageName},${i}]}
			{
				makeNum:Set[${i}]
			}
		}
		while ${i} <= 20 && ${This.checkReagentInventory[${bandageName},${i:Inc}]}	
		/* make the bandages */
		This:Output["Making ${bandageName} x${makeNum}"]
		This:MakeBandage[${bandageName},${makeNum}]	
	}
	
	member makeableBandage(int numToMake=1)
	{
		variable int i = 1
		do
		{
			if ${This.checkReagentInventory[${This.BestBandage.Get[${i}]},${numToMake}]}
			{
				return ${This.BestBandage.Get[${i}]}
			}
		}
		while ${This.BestBandage.Get[${i:Inc}](exists)}
		return "NONE"
	}
	
	
; Disenchanting
;--------------
	
	method AutoDE()
	{	
		variable int i = 1
		; Loop through inventory items for Greens that are not soulbound and verify if we can DE
		DEList:Search[-items,-inventory,-notsoulbound,-uncommon]		
		if ${DEList.Count} > 0
		{
			do
			{
				itemGUID:Set[${DEItems.Object[${i}].GUID}]
				${Item[${itemGUID}](exists)}
				{
					This:Output["Disenchanting - ${DEItems.Object[${i}].Name}"]
					Spell["Disenchant"]:Cast
					SpellTarget[${itemGUID}]
					Bot.RandomPause:Set[500]
					return
				}
			}
			while ${DEItems.Count} >= ${i:Inc}
			This.DEList:Clear
		}	
	}	
	
	
	member CanCraft(string ItemName, int CreateNum, string CraftType)
	{
		This:Output["Trying to craft ${ItemName} ${CreateNum} Times Using ${CraftType} "]
		variable int Idx = 1
		variable int reagentNeed = 0
		variable int reagentHave = 0
		variable int reagentCheck = 0
		variable int reagentReq = 1
		variable bool reagentAllCheck = FALSE
		;Check if we have the first aid skill
		if ${Spell[${CraftType}](exists)}
		{
			
			;Is the Tradeskill window already open?
			;If not then open it.
			if ${WoWScript[TradeSkillFrame:IsShown()]} != 1
			{
				Cast ${CraftType}
		  	}

			;loops through the available index's to find the entry we need.
			do
			{
				;Checks the info of ${Idx} to see if it is equal to the bandage we are trying to create.
				if ${WoWScript[GetTradeSkillInfo(${Idx})].Equal["${ItemName}"]} && ${WoWScript[TradeSkillFrame:IsShown()]} == 1
				{
					;echo found ${WoWScript[GetTradeSkillInfo(${Idx})]} which required ${WoWScript[GetTradeSkillNumReagents(${Idx})]} reagents
					
					for (reagentReq:Set[1] ; ${WoWScript[GetTradeSkillNumReagents(${Idx})]} >= ${reagentReq} && ${reagentReq} < 10 ; reagentReq:Inc)
					{
						;Echo Determines the number of regeants required and the number of regeants in the player inventory.
						reagentNeed:Set[${WoWScript[pcall(loadstring("local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(${Idx}, ${reagentReq}) return reagentCount")), 2]}]
						reagentHave:Set[${WoWScript[pcall(loadstring("local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(${Idx}, ${reagentReq}) return playerReagentCount")), 2]}]
						
						;echo Did we find the reagents we need?
						if ${reagentHave} >= 1 && ${reagentNeed} >= 1
						{
							;echo do we have enough regeants?
							reagentCheck:Set[${Math.Calc[${reagentHave} / ${reagentNeed}]}]
							
							if ${reagentCheck} < ${CreateNum}
							{
								This:Output["You do not have enough reagents to make ${ItemName} x ${CreateNum}!"]
								This:Output["You are missing ${WoWScript[pcall(loadstring("local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(${Idx}, ${reagentReq}) return reagentName")), 2]} !"]
								WoWScript CloseTradeSkill()
								return FALSE
							}
							;echo still good. next reagent
							reagentAllCheck:Set[TRUE]
						}
						else
						{
							This:Output["You do not have enough reagents to make ${ItemName} x ${CreateNum}!"]
							This:Output["You are missing ${WoWScript[pcall(loadstring("local reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(${Idx}, ${reagentReq}) return reagentName")), 2]} !"]
							WoWScript CloseTradeSkill()
							return FALSE
						}
						;echo  ${WoWScript[GetTradeSkillNumReagents(${Idx})]} >= ${reagentReq}
					
					}

					WoWScript CloseTradeSkill()
					return ${reagentAllCheck}
				}
				
			}
			while ${WoWScript[GetTradeSkillInfo(${Idx:Inc})](exists)}
			
			WoWScript CloseTradeSkill()
			This:Output["You do not have the recipe for ${ItemName}!"]
			return FALSE
		}
	}

	member CraftItem(string ItemName, int NumItem, string CraftType)
	{
	  variable int Idx = 1
	  variable int BandIdx = 0
	  variable int currentNum = 0
	  
	  ;echo Can we make the amount of items necessary?
		
	  if ${This.CanCraft[${ItemName}, ${NumItem}, ${CraftType}]}
	  {
			;Is the Tradeskill window already open?
			;If not then open it.
			if !${WoWScript[TradeSkillFrame:IsShown()]}
			{
				Cast ${CraftType}
			}
			
			;Loop to find the index of our recipies.
			do
			{
				if ${WoWScript[GetTradeSkillInfo(${Idx})].Equal["${ItemName}"]} && ${WoWScript[TradeSkillFrame:IsShown()]}
				{
					BandIdx:Set[${Idx}]
				}
			}
			while ${WoWScript[GetTradeSkillInfo(${Idx:Inc})](exists)}
			
			;Create our items(s) and close the window.
			This:Output["Creating ${ItemName} x ${NumItem}!"]
			WoWScript DoTradeSkill(${BandIdx}, ${NumItem})
			WoWScript CloseTradeSkill()
			return TRUE
		}
	return FALSE
	}
}