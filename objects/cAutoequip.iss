objectdef cAutoequip inherits cBase
{
	variable collection:float Modifier
	variable collection:float EqSlot
	variable collection:bool DontCompare
	variable string ArmorWanted
	variable bool AcceptEquipBind = FALSE
	variable bool NeedEQ = TRUE
	
	/* this is where the stats are wieghted */
	method Initialize()
	{
		/* set default values */
		This.Modifier:Set["Agility",0]
		This.Modifier:Set["Strength",0]
		This.Modifier:Set["Intellect",0]
		This.Modifier:Set["Spirit",0]
		This.Modifier:Set["Stamina",0.1]
		This.Modifier:Set["Armor",0.04]	
		This.Modifier:Set["Block",0]
		This.Modifier:Set["DPS",1]
		
		This.Modifier:Set["AttackPower",0]
		This.Modifier:Set["RangedAttackPower",0]
		
		This.Modifier:Set["Defense",0]
		This.Modifier:Set["Resilience",0]
		This.Modifier:Set["Dodge",0]
		This.Modifier:Set["Parry",0]
		This.Modifier:Set["Hit",0]
		This.Modifier:Set["Crit",0]
		
		This.Modifier:Set["SpellDamage",0]
		This.Modifier:Set["HealingBonus",0]	
		This.Modifier:Set["SpellHit",0]
		This.Modifier:Set["SpellCrit",0]	
		This.Modifier:Set["MP5",0]
		
		/* set warrior values */
		if ${Me.Class.Equal[Warrior]}
		{
			This.Modifier:Set["Agility",1.25]
			This.Modifier:Set["Strength",2]
			This.Modifier:Set["Spirit",0.1]
			This.Modifier:Set["Stamina",1.25]
			This.Modifier:Set["Armor",0.025]
			This.Modifier:Set["DPS",10]
			This.Modifier:Set["AttackPower",1]
			This.Modifier:Set["Defense",0.4]
			This.Modifier:Set["Dodge",10]
			This.Modifier:Set["Parry",15.385]
			This.Modifier:Set["Hit",20]
			This.Modifier:Set["Crit",20]		
			This.ArmorWanted:Set["Plate"]
			if ${Me.Level} < 40
			{
			This.ArmorWanted:Set["Mail"]
			}
		}
		
		/* set rogue values - based on Ming's values */
		if ${Me.Class.Equal[Rogue]}
		{
			This.Modifier:Set["Agility",2]
			This.Modifier:Set["Strength",1]
			This.Modifier:Set["Spirit",0.1]
			This.Modifier:Set["Stamina",1.6]
			This.Modifier:Set["Armor",0.04]
			This.Modifier:Set["DPS",10]
			This.Modifier:Set["AttackPower",1]
			This.Modifier:Set["Defense",0.4]
			This.Modifier:Set["Dodge",10]
			This.Modifier:Set["Parry",15.385]
			This.Modifier:Set["Hit",15.385]
			This.Modifier:Set["Crit",20]		
			This.ArmorWanted:Set["Leather"]			
		}
		
		/* set warlock values */
		if ${Me.Class.Equal[Warlock]}
		{
			This.Modifier:Set["Intellect",1.6]
			This.Modifier:Set["Spirit",1]
			This.Modifier:Set["Stamina",2]
			This.Modifier:Set["Armor",0.05]
			This.Modifier:Set["DPS",0.1]
			This.Modifier:Set["SpellDamage",4]
			This.Modifier:Set["SpellHit",20]
			This.Modifier:Set["SpellCrit",20]
			This.Modifier:Set["MP5",2]		
			This.ArmorWanted:Set["Cloth"]				
		}
		
		/* set shaman values */
		if ${Me.Class.Equal[Shaman]}
		{
			This.Modifier:Set["Agility",1]
			This.Modifier:Set["Strength",2]
			This.Modifier:Set["Intellect",2]
			This.Modifier:Set["Spirit",0.2]
			This.Modifier:Set["Stamina",2]
			This.Modifier:Set["Armor",0.04]
			This.Modifier:Set["DPS",10]
			This.Modifier:Set["AttackPower",1]
			This.Modifier:Set["Defense",0.4]
			This.Modifier:Set["Dodge",20]
			This.Modifier:Set["Hit",15.385]
			This.Modifier:Set["Crit",20]
			This.Modifier:Set["SpellDamage",0.2]
			This.Modifier:Set["SpellHit",10]
			This.Modifier:Set["SpellCrit",10]
			This.Modifier:Set["MP5",0.4]		
			This.ArmorWanted:Set["Mail"]			
			if ${Me.Level} < 40
			{
			This.ArmorWanted:Set["Leather"]
			}	
		}

		/* set shaman values */
		if ${Me.Class.Equal[Druid]}
		{
			This.Modifier:Set["Agility",2]
			This.Modifier:Set["Strength",2]
			This.Modifier:Set["Intellect",2]
			This.Modifier:Set["Spirit",0.667]
			This.Modifier:Set["Stamina",2]
			This.Modifier:Set["Armor",0.025]
			This.Modifier:Set["DPS",2.5]
			This.Modifier:Set["AttackPower",2]
			This.Modifier:Set["Defense",0.4]
			This.Modifier:Set["Dodge",20]
			This.Modifier:Set["Hit",10]
			This.Modifier:Set["Crit",10]
			This.Modifier:Set["SpellDamage",2]
			This.Modifier:Set["HealingBonus",2]
			This.Modifier:Set["SpellHit",10]
			This.Modifier:Set["SpellCrit",10]
			This.Modifier:Set["MP5",0.4]
			This.ArmorWanted:Set["Leather"]
		}
		
		/* set priest values */
		if ${Me.Class.Equal[Priest]}
		{
			This.Modifier:Set["Intellect",1]
			This.Modifier:Set["Spirit",2]
			This.Modifier:Set["Stamina",2]
			This.Modifier:Set["Armor",0.05]
			This.Modifier:Set["DPS",0.1]
			This.Modifier:Set["SpellDamage",4]
			This.Modifier:Set["HealingBonus",2]
			This.Modifier:Set["SpellHit",20]
			This.Modifier:Set["SpellCrit",20]
			This.Modifier:Set["MP5",3.077]	
			This.ArmorWanted:Set["Cloth"]				
		}

		/* set paladin values */		
		if ${Me.Class.Equal[Paladin]}
		{
			This.Modifier:Set["Agility",1]
			This.Modifier:Set["Strength",2]
			This.Modifier:Set["Intellect",2]
			This.Modifier:Set["Spirit",0.2]
			This.Modifier:Set["Stamina",2]
			This.Modifier:Set["Armor",0.025]
			This.Modifier:Set["DPS",10]
			This.Modifier:Set["AttackPower",1]
			This.Modifier:Set["Defense",0.4]
			This.Modifier:Set["Dodge",20]
			This.Modifier:Set["Parry",10]
			This.Modifier:Set["Hit",10]
			This.Modifier:Set["Crit",20]
			This.Modifier:Set["SpellDamage",0.2]
			This.Modifier:Set["HealingBonus",0.4]
			This.Modifier:Set["MP5",0.4]	
			This.ArmorWanted:Set["Plate"]
			if ${Me.Level} < 40
			{
			This.ArmorWanted:Set["Mail"]
			}
		}

		/* set mage values */		
		if ${Me.Class.Equal[Mage]}
		{
			This.Modifier:Set["Intellect",2]
			This.Modifier:Set["Spirit",1]
			This.Modifier:Set["Stamina",2]
			This.Modifier:Set["Armor",0.05]
			This.Modifier:Set["DPS",0.1]
			This.Modifier:Set["SpellDamage",2.5]
			This.Modifier:Set["SpellHit",10]
			This.Modifier:Set["SpellCrit",20]
			This.Modifier:Set["MP5",1.6]		
			This.ArmorWanted:Set["Cloth"]			
		}

		/* set hunter values */		
		if ${Me.Class.Equal[Hunter]}
		{
			This.Modifier:Set["Agility",2]
			This.Modifier:Set["Strength",1.6]
			This.Modifier:Set["Intellect",1.6]
			This.Modifier:Set["Spirit",0.5]
			This.Modifier:Set["Stamina",1.6]
			This.Modifier:Set["Armor",0.031]
			This.Modifier:Set["DPS",10]
			This.Modifier:Set["AttackPower",2]
			This.Modifier:Set["RangedAttackPower",2]
			This.Modifier:Set["Defense",0.4]
			This.Modifier:Set["Dodge",10]
			This.Modifier:Set["Parry",10]
			This.Modifier:Set["Hit",15.385]
			This.Modifier:Set["Crit",20]
			This.Modifier:Set["MP5",1]
			This.ArmorWanted:Set["Mail"]
			if ${Me.Level} < 40
			{
			This.ArmorWanted:Set["Leather"]
			}			
		}
		
		/* create slot strings */
		This.EqSlot:Set["Head",1]
		This.EqSlot:Set["Neck",2]
		This.EqSlot:Set["Shoulders",3]
		This.EqSlot:Set["Shirt",4]
		This.EqSlot:Set["Chest",5]
		This.EqSlot:Set["Waist",6]
		This.EqSlot:Set["Legs",7]
		This.EqSlot:Set["Feet",8]
		This.EqSlot:Set["Wrist",9]
		This.EqSlot:Set["Hands",10]
		This.EqSlot:Set["Back",15]
		
		This:LoadSettings
	}	

	member DismissBindPopUp()
	{
		if ${This.AcceptEquipBind}
		{
			This:Debug[Accepting binding]
			WoWScript StaticPopup1Button1:Click()
			WoWScript StaticPopup_Hide("EQUIP_BIND")
			This.AcceptEquipBind:Set[FALSE]
			return TRUE
		}
		return FALSE
	}
	
	member EquipBag()
	{
		if ${POI.Type.NotEqual[MOB]} && !${Me.Ghost} && !${Me.Dead} && !${Bot.PauseFlag} && ${UIElement[chkAutoEQ@EQ@Pages@Cerebrum].Checked}
		{
			if ${This.HasBetterBaggie}
			{
				This:ReplaceBaggie
				return TRUE
			}
		}
		return FALSE
	}	

	/* cycle through usable items in inventory */
	member EquipGear()
	{
		variable guidlist UsableGear
		variable string itemGUID
		variable int i = 1
		/* search gear and iterate through list of usable items to make sure best is equipped */
		if ${POI.Type.NotEqual[MOB]} && !${Me.Ghost} && !${Me.Dead} && !${Bot.PauseFlag} && ${UIElement[chkAutoEQ@EQ@Pages@Cerebrum].Checked}
		{
			UsableGear:Search[-items, -inventory, -usable]		
			if ${UsableGear.Count} > 0
			{
				do
				{
					itemGUID:Set[${UsableGear.Object[${i}].GUID}]
					if ${This.ShouldCompare[${itemGUID}]} && ${Item[${itemGUID}](exists)}
					{
						if ${This.ItemIsBetter[${itemGUID}]}
						{
							return TRUE
						}
						This.DontCompare:Set[${itemGUID},TRUE]				
					}
				}
				while ${UsableGear.Count} >= ${i:Inc}
			}
		}
		return FALSE
	}
	
	/* check an inventory item to see if it is better than an equipped item */
	member ItemIsBetter(string itemGUID)
	{
		variable int i = 1
		variable int count = 1
		variable float equipValue = 0
		variable float itemValue = 0
		variable oItemTT equippedTT
		variable oItemTT bagTT	
		
		bagTT:GetBagSlot[${Item[${itemGUID}].Bag.Number},${Item[${itemGUID}].Slot}]		
		
		if ${bagTT.BindOnEquip} && ${Item[${itemGUID}].Rarity} > 3
		{
			This:Debug[Whoa! We dont autoequip blues or better!]
			This.DontCompare:Set[${itemGUID},TRUE]			
			return FALSE
		}

		if ${bagTT.UniqueEquip} || ${bagTT.BeginsQuest}
		{
			This:Debug[We dont compare Uniques or Items that Begin Quests]
			This.DontCompare:Set[${itemGUID},TRUE]			
			return FALSE
		}
				
		if ${This.EqSlot.Element[${Item[${itemGUID}].EquipType}](exists)}
		{
			/* we dont have an item of that type equipped -- lets equip it */
			if !${Me.Equip[${This.EqSlot.Element[${Item[${itemGUID}].EquipType}]}].Name(exists)}
			{
				This:Output["No item of type found, equipping ${Item[${itemGUID}].Name}"]
				Item[${itemGUID}]:Use
				Bot.RandomPause:Set[6]
				return TRUE
			}		
		}
		
		if ${Item[${itemGUID}](exists)}
		{
			do
			{
				if ${Me.Equip[${i}](exists)}
				{
					if ${Me.Equip[${i}].EquipType.Equal[${Item[${itemGUID}].EquipType}]}
					{						
						equippedTT:GetEquipped[${i}]
						if ${Me.Equip[${i}].Class.Equal["Armor"]}
						{					
							equipValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["Armor"]}*${Me.Equip[${i}].Armor}]}, ${equippedTT.Agility}, ${equippedTT.Strength}, ${equippedTT.Intellect}, ${equippedTT.Spirit}, ${equippedTT.Stamina}, ${equippedTT.AttackPower}, ${equippedTT.RangedAttackPower}, ${equippedTT.SpellDamage}, ${equippedTT.HealingBonus}, ${equippedTT.Busted[Defense]}, ${equippedTT.Busted[Resilience]}, ${equippedTT.Busted[Parry]}, ${equippedTT.Busted[Hit]}, ${equippedTT.Busted[SpellHit]}, ${equippedTT.Busted[Crit]}, ${equippedTT.Busted[SpellCrit]}, ${equippedTT.MP5}, ${equippedTT.Block}, ${equippedTT.Busted[Dodge]}]}]
							itemValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["Armor"]}*${Item[${itemGUID}].Armor}]}, ${bagTT.Agility}, ${bagTT.Strength}, ${bagTT.Intellect}, ${bagTT.Spirit}, ${bagTT.Stamina}, ${bagTT.AttackPower}, ${bagTT.RangedAttackPower}, ${bagTT.SpellDamage}, ${bagTT.HealingBonus}, ${bagTT.Busted[Defense]}, ${bagTT.Busted[Resilience]}, ${bagTT.Busted[Parry]}, ${bagTT.Busted[Hit]}, ${bagTT.Busted[SpellHit]}, ${bagTT.Busted[Crit]}, ${bagTT.Busted[SpellCrit]}, ${bagTT.MP5}, ${bagTT.Block}, ${bagTT.Busted[Dodge]}]}]
							if ${Me.Equip[${i}].SubType.Equal[${This.ArmorWanted}]} && !${Item[${itemGUID}].SubType.Equal[${This.ArmorWanted}]} && !${Item[${itemGUID}].EquipType.Equal["Back"]}
							{
								/* if we are wearing our preferred armor and armor we are checking is not preferred, dont factor in armor as part of the value */
								itemValue:Set[${This.EquipValue[0, ${bagTT.Agility}, ${bagTT.Strength}, ${bagTT.Intellect}, ${bagTT.Spirit}, ${bagTT.Stamina}, ${bagTT.AttackPower}, ${bagTT.RangedAttackPower}, ${bagTT.SpellDamage}, ${bagTT.HealingBonus}, ${bagTT.Busted[Defense]}, ${bagTT.Busted[Resilience]}, ${bagTT.Busted[Parry]}, ${bagTT.Busted[Hit]}, ${bagTT.Busted[SpellHit]}, ${bagTT.Busted[Crit]}, ${bagTT.Busted[SpellCrit]}, ${bagTT.MP5}, ${bagTT.Block}, ${bagTT.Busted[Dodge]}]}]
							}
						}
						elseif ${Me.Equip[${i}].Class.Equal["Weapon"]}
						{
							equipValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["DPS"]}*${This.DPSValue[${i},${Me.Equip[${i}].GUID}]}]}, ${equippedTT.Agility}, ${equippedTT.Strength}, ${equippedTT.Intellect}, ${equippedTT.Spirit}, ${equippedTT.Stamina}, ${equippedTT.AttackPower}, ${equippedTT.RangedAttackPower}, ${equippedTT.SpellDamage}, ${equippedTT.HealingBonus}, ${equippedTT.Busted[Defense]}, ${equippedTT.Busted[Resilience]}, ${equippedTT.Busted[Parry]}, ${equippedTT.Busted[Hit]}, ${equippedTT.Busted[SpellHit]}, ${equippedTT.Busted[Crit]}, ${equippedTT.Busted[SpellCrit]}, ${equippedTT.MP5}, ${equippedTT.Block}, ${equippedTT.Busted[Dodge]}]}]
							itemValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["DPS"]}*${This.DPSValue[${i},${itemGUID}]}]}, ${bagTT.Agility}, ${bagTT.Strength}, ${bagTT.Intellect}, ${bagTT.Spirit}, ${bagTT.Stamina}, ${bagTT.AttackPower}, ${bagTT.RangedAttackPower}, ${bagTT.SpellDamage}, ${bagTT.HealingBonus}, ${bagTT.Busted[Defense]}, ${bagTT.Busted[Resilience]}, ${bagTT.Busted[Parry]}, ${bagTT.Busted[Hit]}, ${bagTT.Busted[SpellHit]}, ${bagTT.Busted[Crit]}, ${bagTT.Busted[SpellCrit]}, ${bagTT.MP5}, ${bagTT.Block}, ${bagTT.Busted[Dodge]}]}]		
							if (${i} == 18 || ${Config.GetCheckbox[chkWeaponSubTypeOnly]}) && ${Item[${itemGUID}].SubType.NotEqual[${Me.Equip[${i}].SubType}]}
							{
								itemValue:Set[0]	
							}
						}
						else
						{
							equipValue:Set[${This.EquipValue[0, ${equippedTT.Agility}, ${equippedTT.Strength}, ${equippedTT.Intellect}, ${equippedTT.Spirit}, ${equippedTT.Stamina}, ${equippedTT.AttackPower}, ${equippedTT.RangedAttackPower}, ${equippedTT.SpellDamage}, ${equippedTT.HealingBonus}, ${equippedTT.Busted[Defense]}, ${equippedTT.Busted[Resilience]}, ${equippedTT.Busted[Parry]}, ${equippedTT.Busted[Hit]}, ${equippedTT.Busted[SpellHit]}, ${equippedTT.Busted[Crit]}, ${equippedTT.Busted[SpellCrit]}, ${equippedTT.MP5}, ${equippedTT.Block}, ${equippedTT.Busted[Dodge]}]}]
							itemValue:Set[${This.EquipValue[0, ${bagTT.Agility}, ${bagTT.Strength}, ${bagTT.Intellect}, ${bagTT.Spirit}, ${bagTT.Stamina}, ${bagTT.AttackPower}, ${bagTT.RangedAttackPower}, ${bagTT.SpellDamage}, ${bagTT.HealingBonus}, ${bagTT.Busted[Defense]}, ${bagTT.Busted[Resilience]}, ${bagTT.Busted[Parry]}, ${bagTT.Busted[Hit]}, ${bagTT.Busted[SpellHit]}, ${bagTT.Busted[Crit]}, ${bagTT.Busted[SpellCrit]}, ${bagTT.MP5}, ${bagTT.Block}, ${bagTT.Busted[Dodge]}]}]
						}
						if ${itemValue} > ${equipValue}
						{
							This:Output["Found Better Itemstats: Equipping ${Item[${itemGUID}].Name}"]
							if ${bagTT.BindOnEquip} 
							{
								/* BoE stuff is handled a bit differently */
								Item[${itemGUID}]:Use
								Bot.RandomPause:Set[6]
								return TRUE								
							}
							Item[${itemGUID}]:PickUp
							Me.Equip[${i}]:PickUp						
							Bot.RandomPause:Set[6]
							return TRUE
						}
					}
				}
				equipValue:Set[0]
				itemValue:Set[0]
			}
			while ${i:Inc} <= 18 
			
			/* only make comparison for items one time */
			This.DontCompare:Set[${itemGUID},TRUE]
		}
		return FALSE
	}	
	
	/* this is tricky. sometimes we want fast weapons and other times slow - this system attempts to weight them accordingly */
	member DPSValue(int WeaponSlot,string WeaponGUID)
	{
		variable float avgdam	
		variable objectref WeaponItem
		
		WeaponItem:Set[${WeaponGUID}]	
		
		/* DPS needs to be better or within 2 of my current DPS - otherwise, its not an upgrade*/
		if !${This.DPSwithin[${Me.Equip[${WeaponSlot}].DPS},${WeaponItem.DPS},2]}
		{
			return 0
		}

		/* we like fast weapons, the dps difference needs to be at least 12% better if the weapon is slow*/
		if ${Me.Equip[${WeaponSlot}].Delay} < 1.8 && ${WeaponItem.Delay} > 2
		{
			if !${This.DPSwithin[${WeaponItem.DPS},${Me.Equip[${WeaponSlot}].DPS},${Math.Calc[${Me.Equip[${WeaponSlot}].DPS}*.12]}]}
			{
				return 0
			}
		}
		
		/* if we like slow weapons lets check average damage - slower the better  */		
		if ${Me.Equip[${WeaponSlot}].Delay} >= 2.4
		{
			avgdam:Set[${Math.Calc[(${WeaponItem.MinDamage} + ${WeaponItem.MaxDamage})/2]}]	
			return ${Math.Calc[${avgdam}/2.4]}
		}
		return ${WeaponItem.DPS}	
	}

	/* check 1st DPS against 2nd DPS to see if 2nd is at least within that amount in DPS  */
	member DPSwithin(float statusquo, float comp, float amount)
	{
		if ${comp} >= ${statusquo}
		{
			return TRUE
		}
		if ${Math.Calc[${statusquo}-${comp}]} >= ${amount}
		{
			return TRUE
		}
		return FALSE
	}
	
	/* score the items based on stat modifiers */
	member EquipValue(float BaseScore, float Agility, float Strength, float Intellect, float Spirit, float Stamina, float AttackPower, float RangedAttackPower, float SpellDamage, float HealingBonus, float Defense, float Resilience, float Parry, int Hit, float SpellHit, float Crit, float SpellCrit, float MP5, float Block, float Dodge)
	{
		variable float ItemScore = ${BaseScore}
		
		ItemScore:Inc[${This.Modifier.Element["Agility"]}*${Agility}]
		ItemScore:Inc[${This.Modifier.Element["Strength"]}*${Strength}]
		ItemScore:Inc[${This.Modifier.Element["Intellect"]}*${Intellect}]
		ItemScore:Inc[${This.Modifier.Element["Spirit"]}*${Spirit}]
		ItemScore:Inc[${This.Modifier.Element["Stamina"]}*${Stamina}]
		
		ItemScore:Inc[${This.Modifier.Element["AttackPower"]}*${AttackPower}]
		ItemScore:Inc[${This.Modifier.Element["RangedAttackPower"]}*${RangedAttackPower}]
		
		ItemScore:Inc[${This.Modifier.Element["SpellDamage"]}*${SpellDamage}]
		ItemScore:Inc[${This.Modifier.Element["HealingBonus"]}*${HealingBonus}]
		
		ItemScore:Inc[${This.Modifier.Element["Defense"]}*${Defense}]
		ItemScore:Inc[${This.Modifier.Element["Resilience"]}*${Resilience}]
		ItemScore:Inc[${This.Modifier.Element["Dodge"]}*${Dodge}]
		ItemScore:Inc[${This.Modifier.Element["Parry"]}*${Parry}]
		
		ItemScore:Inc[${This.Modifier.Element["Hit"]}*${Hit}]
		ItemScore:Inc[${This.Modifier.Element["SpellHit"]}*${SpellHit}]		
		ItemScore:Inc[${This.Modifier.Element["Crit"]}*${Crit}]
		ItemScore:Inc[${This.Modifier.Element["SpellCrit"]}*${SpellCrit}]
		
		ItemScore:Inc[${This.Modifier.Element["MP5"]}*${MP5}]
		ItemScore:Inc[${This.Modifier.Element["Block"]}*${Block}]	
		
		return ${ItemScore}
	}

	/* dont compare items we already scanned */
	member ShouldCompare(string itemGUID)
	{
		if ${This.DontCompare.Element[${itemGUID}]}
		{
			return FALSE
		}
		return TRUE
	}
	
	/* used for BoE items */
	method BindAutoEquip()
	{
		if ${UIElement[chkAutoEQ@EQ@Pages@Cerebrum].Checked}
		{
			This.AcceptEquipBind:Set[TRUE]
		}
	}
	
	/* returns the best quest reward choice */
	member GetBestRewardIndex()
	{
		variable int i = 1
		variable int choice = 1
		variable int bestchoice = 0
		variable float itemValue = 0		
		variable float equipValue = 0
		variable oItemTT equippedTT
		variable oItemTT rewardTT
		variable string questTitle = "NONE"
		variable collection:float upgradeValue
		
		if ${WoWScript[QuestRewardTitleText:IsVisible()]}
		{
			questTitle:Set[${WoWScript[QuestRewardTitleText:GetText()]}]
		}
		elseif ${WoWScript[QuestProgressTitleText:IsVisible()]}
		{
			questTitle:Set[${WoWScript[QuestProgressTitleText:GetText()]}]
		}
		elseif ${WoWScript[QuestTitleText:IsVisible()]}
		{
			questTitle:Set[${WoWScript[QuestTitleText:GetText()]}]
		}
		
		if ${questTitle.Equal[NONE]}
		{
			/* return 0, we couldnt find a quest title */
			return 0
		}
		
		if "${WoWScript["GetQuestItemLink(\"choice\", ${choice})"](exists)}"
		{
			do
			{
				if ${Me.Quest[${questTitle}].RewardItemChoice[${choice}].Usable}
				{
					rewardTT:GetItemLink["${WoWScript["GetQuestItemLink(\"choice\", ${choice})"]}"]						
					do
					{
						if ${This.EqSlot.Element[${Me.Quest[${questTitle}].RewardItemChoice[${choice}].EquipType}](exists)}
						{
							/* we dont have an item of that type equipped -- lets equip it */
							if !${Me.Equip[${This.EqSlot.Element[${Me.Quest[${questTitle}].RewardItemChoice[${choice}].EquipType}]}].Name(exists)}
							{
								if ${Me.Quest[${questTitle}].RewardItemChoice[${choice}].Class.Equal["Armor"]}
								{			
									itemValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["Armor"]}*${Me.Quest[${questTitle}].RewardItemChoice[${choice}].Armor}]}, ${rewardTT.Agility}, ${rewardTT.Strength}, ${rewardTT.Intellect}, ${rewardTT.Spirit}, ${rewardTT.Stamina}, ${rewardTT.AttackPower}, ${rewardTT.RangedAttackPower}, ${rewardTT.SpellDamage}, ${rewardTT.HealingBonus}, ${rewardTT.Busted[Defense]}, ${rewardTT.Busted[Resilience]}, ${rewardTT.Busted[Parry]}, ${rewardTT.Busted[Hit]}, ${rewardTT.Busted[SpellHit]}, ${rewardTT.Busted[Crit]}, ${rewardTT.Busted[SpellCrit]}, ${rewardTT.MP5}, ${rewardTT.Block}, ${rewardTT.Busted[Dodge]}]}]
								}
								elseif ${Me.Quest[${questTitle}].RewardItemChoice[${choice}].Class.Equal["Weapon"]}
								{
									itemValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["DPS"]}*${Me.Quest[${questTitle}].RewardItemChoice[${choice}].DPS}]}, ${rewardTT.Agility}, ${rewardTT.Strength}, ${rewardTT.Intellect}, ${rewardTT.Spirit}, ${rewardTT.Stamina}, ${rewardTT.AttackPower}, ${rewardTT.RangedAttackPower}, ${rewardTT.SpellDamage}, ${rewardTT.HealingBonus}, ${rewardTT.Busted[Defense]}, ${rewardTT.Busted[Resilience]}, ${rewardTT.Busted[Parry]}, ${rewardTT.Busted[Hit]}, ${rewardTT.Busted[SpellHit]}, ${rewardTT.Busted[Crit]}, ${rewardTT.Busted[SpellCrit]}, ${rewardTT.MP5}, ${rewardTT.Block}, ${rewardTT.Busted[Dodge]}]}]		
								}
								else
								{
									itemValue:Set[${This.EquipValue[0, ${rewardTT.Agility}, ${rewardTT.Strength}, ${rewardTT.Intellect}, ${rewardTT.Spirit}, ${rewardTT.Stamina}, ${rewardTT.AttackPower}, ${rewardTT.RangedAttackPower}, ${rewardTT.SpellDamage}, ${rewardTT.HealingBonus}, ${rewardTT.Busted[Defense]}, ${rewardTT.Busted[Resilience]}, ${rewardTT.Busted[Parry]}, ${rewardTT.Busted[Hit]}, ${rewardTT.Busted[SpellHit]}, ${rewardTT.Busted[Crit]}, ${rewardTT.Busted[SpellCrit]}, ${rewardTT.MP5}, ${rewardTT.Block}, ${rewardTT.Busted[Dodge]}]}]
								}								
								/* we dont have this type of item equipped */
								if ${itemValue} > 0
								{							
									upgradeValue:Set["${choice}",${Math.Calc[1+(${itemValue}*0.01)]}]
								}
							}		
						}		
						if ${Me.Equip[${i}](exists)}
						{				
							if ${Me.Equip[${i}].EquipType.Equal[${Item[${itemGUID}].EquipType}]}
							{						
								equippedTT:GetEquipped[${i}]
								if ${Me.Equip[${i}].Class.Equal["Armor"]}
								{					
									equipValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["Armor"]}*${Me.Equip[${i}].Armor}]}, ${equippedTT.Agility}, ${equippedTT.Strength}, ${equippedTT.Intellect}, ${equippedTT.Spirit}, ${equippedTT.Stamina}, ${equippedTT.AttackPower}, ${equippedTT.RangedAttackPower}, ${equippedTT.SpellDamage}, ${equippedTT.HealingBonus}, ${equippedTT.Busted[Defense]}, ${equippedTT.Busted[Resilience]}, ${equippedTT.Busted[Parry]}, ${equippedTT.Busted[Hit]}, ${equippedTT.Busted[SpellHit]}, ${equippedTT.Busted[Crit]}, ${equippedTT.Busted[SpellCrit]}, ${equippedTT.MP5}, ${equippedTT.Block}, ${equippedTT.Busted[Dodge]}]}]
									itemValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["Armor"]}*${Me.Quest[${questTitle}].RewardItemChoice[${choice}].Armor}]}, ${rewardTT.Agility}, ${rewardTT.Strength}, ${rewardTT.Intellect}, ${rewardTT.Spirit}, ${rewardTT.Stamina}, ${rewardTT.AttackPower}, ${rewardTT.RangedAttackPower}, ${rewardTT.SpellDamage}, ${rewardTT.HealingBonus}, ${rewardTT.Busted[Defense]}, ${rewardTT.Busted[Resilience]}, ${rewardTT.Busted[Parry]}, ${rewardTT.Busted[Hit]}, ${rewardTT.Busted[SpellHit]}, ${rewardTT.Busted[Crit]}, ${rewardTT.Busted[SpellCrit]}, ${rewardTT.MP5}, ${rewardTT.Block}, ${rewardTT.Busted[Dodge]}]}]
									if ${Me.Equip[${i}].SubType.Equal[${This.ArmorWanted}]} && !${Me.Quest[${questTitle}].RewardItemChoice[${choice}].SubType.Equal[${This.ArmorWanted}]} && !${Me.Quest[${questTitle}].RewardItemChoice[${choice}].EquipType.Equal["Back"]}
									{
										/* if the armor we have equipped is perferred type and reward armor is not, then disregard armor value for reward */
										itemValue:Set[${This.EquipValue[0, ${rewardTT.Agility}, ${rewardTT.Strength}, ${rewardTT.Intellect}, ${rewardTT.Spirit}, ${rewardTT.Stamina}, ${rewardTT.AttackPower}, ${rewardTT.RangedAttackPower}, ${rewardTT.SpellDamage}, ${rewardTT.HealingBonus}, ${rewardTT.Busted[Defense]}, ${rewardTT.Busted[Resilience]}, ${rewardTT.Busted[Parry]}, ${rewardTT.Busted[Hit]}, ${rewardTT.Busted[SpellHit]}, ${rewardTT.Busted[Crit]}, ${rewardTT.Busted[SpellCrit]}, ${rewardTT.MP5}, ${rewardTT.Block}, ${rewardTT.Busted[Dodge]}]}]
									}
								}
								elseif ${Me.Equip[${i}].Class.Equal["Weapon"]}
								{
									equipValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["DPS"]}*${Me.Equip[${i}].DPS}]}, ${equippedTT.Agility}, ${equippedTT.Strength}, ${equippedTT.Intellect}, ${equippedTT.Spirit}, ${equippedTT.Stamina}, ${equippedTT.AttackPower}, ${equippedTT.RangedAttackPower}, ${equippedTT.SpellDamage}, ${equippedTT.HealingBonus}, ${equippedTT.Busted[Defense]}, ${equippedTT.Busted[Resilience]}, ${equippedTT.Busted[Parry]}, ${equippedTT.Busted[Hit]}, ${equippedTT.Busted[SpellHit]}, ${equippedTT.Busted[Crit]}, ${equippedTT.Busted[SpellCrit]}, ${equippedTT.MP5}, ${equippedTT.Block}, ${equippedTT.Busted[Dodge]}]}]
									itemValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["DPS"]}*${Me.Quest[${questTitle}].RewardItemChoice[${choice}].DPS}]}, ${rewardTT.Agility}, ${rewardTT.Strength}, ${rewardTT.Intellect}, ${rewardTT.Spirit}, ${rewardTT.Stamina}, ${rewardTT.AttackPower}, ${rewardTT.RangedAttackPower}, ${rewardTT.SpellDamage}, ${rewardTT.HealingBonus}, ${rewardTT.Busted[Defense]}, ${rewardTT.Busted[Resilience]}, ${rewardTT.Busted[Parry]}, ${rewardTT.Busted[Hit]}, ${rewardTT.Busted[SpellHit]}, ${rewardTT.Busted[Crit]}, ${rewardTT.Busted[SpellCrit]}, ${rewardTT.MP5}, ${rewardTT.Block}, ${rewardTT.Busted[Dodge]}]}]		
									if (${i} == 18 || ${Config.GetCheckbox[chkWeaponSubTypeOnly]}) && ${Me.Quest[${questTitle}].RewardItemChoice[${choice}].SubType.NotEqual[${Me.Equip[${i}].SubType}]}
									{
										itemValue:Set[0]	
									}
								}
								else
								{
									equipValue:Set[${This.EquipValue[0, ${equippedTT.Agility}, ${equippedTT.Strength}, ${equippedTT.Intellect}, ${equippedTT.Spirit}, ${equippedTT.Stamina}, ${equippedTT.AttackPower}, ${equippedTT.RangedAttackPower}, ${equippedTT.SpellDamage}, ${equippedTT.HealingBonus}, ${equippedTT.Busted[Defense]}, ${equippedTT.Busted[Resilience]}, ${equippedTT.Busted[Parry]}, ${equippedTT.Busted[Hit]}, ${equippedTT.Busted[SpellHit]}, ${equippedTT.Busted[Crit]}, ${equippedTT.Busted[SpellCrit]}, ${equippedTT.MP5}, ${equippedTT.Block}, ${equippedTT.Busted[Dodge]}]}]
									itemValue:Set[${This.EquipValue[0, ${rewardTT.Agility}, ${rewardTT.Strength}, ${rewardTT.Intellect}, ${rewardTT.Spirit}, ${rewardTT.Stamina}, ${rewardTT.AttackPower}, ${rewardTT.RangedAttackPower}, ${rewardTT.SpellDamage}, ${rewardTT.HealingBonus}, ${rewardTT.Busted[Defense]}, ${rewardTT.Busted[Resilience]}, ${rewardTT.Busted[Parry]}, ${rewardTT.Busted[Hit]}, ${rewardTT.Busted[SpellHit]}, ${rewardTT.Busted[Crit]}, ${rewardTT.Busted[SpellCrit]}, ${rewardTT.MP5}, ${rewardTT.Block}, ${rewardTT.Busted[Dodge]}]}]
								}
								if ${itemValue} > ${equipValue} && ${itemValue} > 0
								{
									/* we found a nice reward, lets save the pct improvement for comparison */
									upgradeValue:Set[${choice},${Math.Calc[(${itemValue}-${equipValue})/${equipValue}]}]
								}
							}
						}
						equipValue:Set[0]
						itemValue:Set[0]
					}
					while ${i:Inc} <= 17 
				}
				i:Set[1]
			}
			while "${WoWScript["GetQuestItemLink(\"choice\", ${choice:Inc})"](exists)}"
			
			/* loop through upgrade pcts until we find the best improvement */
			if "${upgradeValue.FirstKey(exists)}"
			{
				bestchoice:Set[${upgradeValue.CurrentKey}]
				itemValue:Set[${upgradeValue.CurrentValue}]	
				do
				{
					This:Debug[choice: ${upgradeValue.CurrentKey}  --  value: ${upgradeValue.CurrentValue}]
					if ${upgradeValue.CurrentValue} > ${itemValue}
					{
					bestchoice:Set[${upgradeValue.CurrentKey}]	
					itemValue:Set[${upgradeValue.CurrentValue}]			
					}
				}
				while "${upgradeValue.NextKey(exists)}"
			}
		}		
		return ${bestchoice}
	}

	/* pulse based need or greed chooser */
	method NeedOrGreed()
	{
		variable int i = 1
		variable int count = 1
		variable float equipValue = 0
		variable float itemValue = 0
		variable oItemTT equippedTT
		variable oItemTT bagTT
		variable bool Greed = FALSE

		variable string RollItemLink = ${WoWScript[GetLootRollItemLink(1)]}
		if ${RollItemLink.Equal[NULL]}
		{
			return
		}
		bagTT:GetItemLink["${RollItemLink}"]		

		if ${bagTT.UniqueEquip} || ${bagTT.BeginsQuest}
		{
			Greed:Set[FALSE]
		}
		else
		{
			if ${This.EqSlot.Element[${Item[${itemGUID}].EquipType}](exists)}
			{
				/* we dont have an item of that type equipped -- lets equip it */
				if !${Me.Equip[${This.EqSlot.Element[${Item[${itemGUID}].EquipType}]}].Name(exists)}
				{
				Greed:Set[TRUE]
				}		
			}		
			do
			{
				if ${Me.Equip[${i}](exists)}
				{
					if ${Me.Equip[${i}].EquipType.Equal[${Item[${itemGUID}].EquipType}]}
					{						
						equippedTT:GetEquipped[${i}]
						if ${Me.Equip[${i}].Class.Equal["Armor"]}
						{					
							equipValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["Armor"]}*${Me.Equip[${i}].Armor}]}, ${equippedTT.Agility}, ${equippedTT.Strength}, ${equippedTT.Intellect}, ${equippedTT.Spirit}, ${equippedTT.Stamina}, ${equippedTT.AttackPower}, ${equippedTT.RangedAttackPower}, ${equippedTT.SpellDamage}, ${equippedTT.HealingBonus}, ${equippedTT.Busted[Defense]}, ${equippedTT.Busted[Resilience]}, ${equippedTT.Busted[Parry]}, ${equippedTT.Busted[Hit]}, ${equippedTT.Busted[SpellHit]}, ${equippedTT.Busted[Crit]}, ${equippedTT.Busted[SpellCrit]}, ${equippedTT.MP5}, ${equippedTT.Block}, ${equippedTT.Busted[Dodge]}]}]
							itemValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["Armor"]}*${Item[${itemGUID}].Armor}]}, ${bagTT.Agility}, ${bagTT.Strength}, ${bagTT.Intellect}, ${bagTT.Spirit}, ${bagTT.Stamina}, ${bagTT.AttackPower}, ${bagTT.RangedAttackPower}, ${bagTT.SpellDamage}, ${bagTT.HealingBonus}, ${bagTT.Busted[Defense]}, ${bagTT.Busted[Resilience]}, ${bagTT.Busted[Parry]}, ${bagTT.Busted[Hit]}, ${bagTT.Busted[SpellHit]}, ${bagTT.Busted[Crit]}, ${bagTT.Busted[SpellCrit]}, ${bagTT.MP5}, ${bagTT.Block}, ${bagTT.Busted[Dodge]}]}]
							if ${Me.Equip[${i}].SubType.Equal[${This.ArmorWanted}]} && !${Item[${itemGUID}].SubType.Equal[${This.ArmorWanted}]} && !${Item[${itemGUID}].EquipType.Equal["Back"]}
						{
								/* if we are wearing our preferred armor and armor we are checking is not preferred, dont factor in armor as part of the value */
								itemValue:Set[${This.EquipValue[0, ${bagTT.Agility}, ${bagTT.Strength}, ${bagTT.Intellect}, ${bagTT.Spirit}, ${bagTT.Stamina}, ${bagTT.AttackPower}, ${bagTT.RangedAttackPower}, ${bagTT.SpellDamage}, ${bagTT.HealingBonus}, ${bagTT.Busted[Defense]}, ${bagTT.Busted[Resilience]}, ${bagTT.Busted[Parry]}, ${bagTT.Busted[Hit]}, ${bagTT.Busted[SpellHit]}, ${bagTT.Busted[Crit]}, ${bagTT.Busted[SpellCrit]}, ${bagTT.MP5}, ${bagTT.Block}, ${bagTT.Busted[Dodge]}]}]
							}
						}
						elseif ${Me.Equip[${i}].Class.Equal["Weapon"]}
						{
							equipValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["DPS"]}*${This.DPSValue[${i},${Me.Equip[${i}].GUID}]}]}, ${equippedTT.Agility}, ${equippedTT.Strength}, ${equippedTT.Intellect}, ${equippedTT.Spirit}, ${equippedTT.Stamina}, ${equippedTT.AttackPower}, ${equippedTT.RangedAttackPower}, ${equippedTT.SpellDamage}, ${equippedTT.HealingBonus}, ${equippedTT.Busted[Defense]}, ${equippedTT.Busted[Resilience]}, ${equippedTT.Busted[Parry]}, ${equippedTT.Busted[Hit]}, ${equippedTT.Busted[SpellHit]}, ${equippedTT.Busted[Crit]}, ${equippedTT.Busted[SpellCrit]}, ${equippedTT.MP5}, ${equippedTT.Block}, ${equippedTT.Busted[Dodge]}]}]
							itemValue:Set[${This.EquipValue[${Math.Calc[${This.Modifier.Element["DPS"]}*${This.DPSValue[${i},${itemGUID}]}]}, ${bagTT.Agility}, ${bagTT.Strength}, ${bagTT.Intellect}, ${bagTT.Spirit}, ${bagTT.Stamina}, ${bagTT.AttackPower}, ${bagTT.RangedAttackPower}, ${bagTT.SpellDamage}, ${bagTT.HealingBonus}, ${bagTT.Busted[Defense]}, ${bagTT.Busted[Resilience]}, ${bagTT.Busted[Parry]}, ${bagTT.Busted[Hit]}, ${bagTT.Busted[SpellHit]}, ${bagTT.Busted[Crit]}, ${bagTT.Busted[SpellCrit]}, ${bagTT.MP5}, ${bagTT.Block}, ${bagTT.Busted[Dodge]}]}]		
							if (${i} == 18 || ${Config.GetCheckbox[chkWeaponSubTypeOnly]}) && ${Item[${itemGUID}].SubType.NotEqual[${Me.Equip[${i}].SubType}]}
							{
								itemValue:Set[0]	
							}
						}
						else
						{
							equipValue:Set[${This.EquipValue[0, ${equippedTT.Agility}, ${equippedTT.Strength}, ${equippedTT.Intellect}, ${equippedTT.Spirit}, ${equippedTT.Stamina}, ${equippedTT.AttackPower}, ${equippedTT.RangedAttackPower}, ${equippedTT.SpellDamage}, ${equippedTT.HealingBonus}, ${equippedTT.Busted[Defense]}, ${equippedTT.Busted[Resilience]}, ${equippedTT.Busted[Parry]}, ${equippedTT.Busted[Hit]}, ${equippedTT.Busted[SpellHit]}, ${equippedTT.Busted[Crit]}, ${equippedTT.Busted[SpellCrit]}, ${equippedTT.MP5}, ${equippedTT.Block}, ${equippedTT.Busted[Dodge]}]}]
							itemValue:Set[${This.EquipValue[0, ${bagTT.Agility}, ${bagTT.Strength}, ${bagTT.Intellect}, ${bagTT.Spirit}, ${bagTT.Stamina}, ${bagTT.AttackPower}, ${bagTT.RangedAttackPower}, ${bagTT.SpellDamage}, ${bagTT.HealingBonus}, ${bagTT.Busted[Defense]}, ${bagTT.Busted[Resilience]}, ${bagTT.Busted[Parry]}, ${bagTT.Busted[Hit]}, ${bagTT.Busted[SpellHit]}, ${bagTT.Busted[Crit]}, ${bagTT.Busted[SpellCrit]}, ${bagTT.MP5}, ${bagTT.Block}, ${bagTT.Busted[Dodge]}]}]
						}
						if ${itemValue} > ${equipValue}
						{
						Greed:Set[TRUE]
						}
					}
				}
				equipValue:Set[0]
				itemValue:Set[0]
			}
			while ${i:Inc} <= 18 	
		}
		if ${Greed}
		{
			This:Output[Rolling GREED]
			WoWScript CloseLoot()			
			WoWScript RollOnLoot(1,2)
			return
		}
		else
		{
			This:Output[Rolling NEED]
			WoWScript CloseLoot()			
			WoWScript RollOnLoot(1,1)
			return
		}
	}
	
	/* complete rewrite of autobag code */
	variable string BetterBaggie
	variable int WorstBaggie
		
	member HasBetterBaggie()
	{
		variable int indexx = 1
		variable objectref Baggie
		variable guidlist BaggieSearch			
		BaggieSearch:Search[-inventory,-containers]
		This.BetterBaggie:Set[NONE]
		
		if ${BaggieSearch.Count} > 0
		{
			This:SetWorstBaggie
			do
			{
				Baggie:Set[${BaggieSearch.GUID[${indexx}]}]
				if ${Baggie.SubType.Equal[Bag]}
				{
					if ${Baggie.Slots} > ${Me.Bag[${This.WorstBaggie}].Slots} || !${Me.Bag[${This.WorstBaggie}].Name(exists)}
					{				
						This.BetterBaggie:Set[${BaggieSearch.GUID[${indexx}]}]						
						return TRUE
					}
				}
			}
			while ${indexx:Inc} <= ${BaggieSearch.Count}
		}
		return FALSE
	}
	
	method ReplaceBaggie()
	{
		variable objectref Baggie
		Baggie:Set[${This.BetterBaggie}]		
		if ${Baggie.Name(exists)} && ${This.WorstBaggie} > 0 && ${This.WorstBaggie} < 5
		{
			if !${Me.Bag[${This.WorstBaggie}](exists)}
			{
				This:Output["AutoEquip: Bag#${This.WorstBaggie} is empty! Equipping ${Baggie.Name}!"]
				Baggie:Use
				return
			}	
			if ${Baggie.Bag.Number} == ${This.WorstBaggie}
			{
				/* echo bag we want is in the bag we are replacing - put it in our backpack*/
				Baggie:PickUp
				WoWScript PickupContainerItem(0, 16)
				return
			}		
			This:Output["AutoEquip: Equipping ${Baggie.Name} in Bag#${This.WorstBaggie}!"]
			Baggie:PickUp
			WoWScript PickupBagFromSlot(ContainerIDToInventoryID(${This.WorstBaggie}))
			return
		}	
	}

	method SetWorstBaggie()
	{
		variable int i = 1
		variable int Smallest
		
		Smallest:Set[${i}]	
		do
		{
			/* if bag # is empty, choose that slot */
			if !${Me.Bag[${i}](exists)}
			{
				This.WorstBaggie:Set[${i}]
				return
			}
			/* if we have 4 bags, choose the worst bag */
			if ${Me.Bag[${i}].Slots} <= ${Me.Bag[${Smallest}].Slots}
			{
				Smallest:Set[${i}]
			}
		}
		while ${i:Inc} <= 4
		This.WorstBaggie:Set[${Smallest}]
		return	
	}	

	/* ------------------- GUI BULLSHIT ------------------- */
	/* stored in settings.xml in the config folder -- no need for its own GUI*/
	method LoadSettings()
	{	
		variable iterator AutoequipIterator

		LavishSettings:AddSet[AutoequipSettings]
		LavishSettings[AutoequipSettings]:Import["config/settings/Autoequip${Me.Name}.xml"]		
		LavishSettings[AutoequipSettings]:GetSettingIterator[AutoequipIterator]	
		
		if ${AutoequipIterator:First(exists)}
		{
			do
			{
				;echo loading ${AutoequipIterator.Key},${AutoequipIterator.Value}
				This.Modifier:Set[${AutoequipIterator.Key},${AutoequipIterator.Value}]		
			}
			while ${AutoequipIterator:Next(exists)}
		}
	}

	method Shutdown()
	{
		LavishSettings[AutoequipSettings]:Clear
		if "${This.Modifier.FirstKey(exists)}"
		{
			do
			{
				;echo saving ${This.Modifier.CurrentKey},${This.Modifier.CurrentValue}
				LavishSettings[AutoequipSettings]:AddSetting["${This.Modifier.CurrentKey}",${This.Modifier.CurrentValue}]
			}
			while "${This.Modifier.NextKey(exists)}"
		}
		LavishSettings[AutoequipSettings]:Export["config/settings/Autoequip${Me.Name}.xml"]
	}
	
	/* sets up all the autoequip sliders in the GUI */
	method SetAutoequipGUI()
	{
		if "${This.Modifier.FirstKey(exists)}"
		{
			do
			{
				This:SetSlider[${This.Modifier.CurrentKey}]
			}
			while "${This.Modifier.NextKey(exists)}"
		}
	}
	
	/* sets the modifier to the current slider value */
	method SetModifier(string stat)
	{
		if ${UIElement[Cerebrum].FindChild[Pages].Tab["EQ"].FindChild[sld${stat}](exists)}    
		{     		
			This.Modifier:Set[${stat},${This.GetActualStat[${stat}]}]
		}
	}

	/* sets the slider to the current modifier value */
	method SetSlider(string stat)
	{
		UIElement[Cerebrum].FindChild[Pages].Tab["EQ"].FindChild[sld${stat}]:SetValue[${This.GetSliderStat[${stat}]}]     
	}

	/* returns slider value as a float read by Modifier */
	member GetActualStat(string stat)
	{
		if ${UIElement[Cerebrum].FindChild[Pages].Tab["EQ"].FindChild[sld${stat}].Value} != 0    
		{ 
			return ${This.ActualValue[${UIElement[Cerebrum].FindChild[Pages].Tab["EQ"].FindChild[sld${stat}].Value}]}  
		}		
		return 0
	}

	/* returns modifier value as an int used by GUI slider */
	member GetSliderStat(string stat)
	{
		return ${This.SliderValue[${This.Modifier.Element[${stat}]}]}
	}

	/* returns float */
	member ActualValue(float sliderValue)
	{
		return ${Math.Calc[${sliderValue}/1000]}
	}

	/* returns int */
	member SliderValue(float actualValue)
	{
		variable int sliderValue = ${Math.Calc[${actualValue}*1000]}
		return ${sliderValue}
	}	
}


/* ------------------- oItemTT - Scans Tooltips for stats ------------------- */
/* thanks to M^3 for providing code to grab text lines */
objectdef oItemTT
{
	variable int Strength = 0
	variable int Agility = 0
	variable int Stamina = 0
	variable int Intellect = 0
	variable int Spirit = 0
	variable int AttackPower = 0
	variable int RangedAttackPower = 0
	variable int SpellDamage = 0
	variable int HealingBonus = 0
	variable int Defense = 0
	variable int Resilience = 0
	variable int Dodge = 0
	variable int Parry = 0
	variable int Hit = 0
	variable int SpellHit = 0
	variable int Crit = 0
	variable int SpellCrit = 0	
	variable int MP5 = 0
	variable int Block = 0
	variable int RangeHit = 0
	variable int RangeCrit = 0	
	variable bool BindOnEquip = FALSE
	variable bool UniqueEquip = FALSE
	variable bool BeginsQuest = FALSE
	variable collection:float BaseScore	
	
	method GetItemID(string ItemID)
	{
		variable int i = 1
		variable int TotalLines
		
		ItemID:Set["item:${ItemID}:0:0:0:0:0:0:0"]
		
		This:ClearItemTT	
		WoWScript GameTooltip:ClearLines()		
		WoWScript GameTooltip:SetOwner(UIParent,"ANCHOR_NONE")
		WoWScript GameTooltip:SetHyperlink("${ItemID}")
		TotalLines:Set[${WoWScript["GameTooltip:NumLines()"]}]
		do
		{
			This:ConvertToStat[${String["${WoWScript[GameTooltipTextLeft${i}:GetText()]}"]}]			
		}
		while ${i:Inc} <= ${TotalLines}
		WoWScript GameTooltip:Hide()
	}	
	
	method GetItemLink(string ItemLink)
	{
		variable int i = 1
		variable int TotalLines
		
		This:ClearItemTT	
		WoWScript GameTooltip:ClearLines()		
		WoWScript GameTooltip:SetOwner(UIParent,"ANCHOR_NONE")
		WoWScript GameTooltip:SetHyperlink("${ItemLink}")
		TotalLines:Set[${WoWScript["GameTooltip:NumLines()"]}]
		do
		{
			This:ConvertToStat[${String["${WoWScript[GameTooltipTextLeft${i}:GetText()]}"]}]			
		}
		while ${i:Inc} <= ${TotalLines}
		WoWScript GameTooltip:Hide()
	}
	
	method GetEquipped(int slot)
	{
		variable int i = 1
		variable int TotalLines
				
		This:ClearItemTT	
		WoWScript GameTooltip:ClearLines()
		WoWScript GameTooltip:SetOwner(UIParent,"ANCHOR_NONE")
		WoWScript GameTooltip:SetInventoryItem("player", ${slot})	
		TotalLines:Set[${WoWScript["GameTooltip:NumLines()"]}]
		do
		{
			This:ConvertToStat[${String["${WoWScript[GameTooltipTextLeft${i}:GetText()]}"]}]
		}
		while ${i:Inc} <= ${TotalLines}
		WoWScript GameTooltip:Hide()		
	}
	
	method GetBagSlot(int bag, int slot)
	{
		variable int i = 1
		variable int TotalLines
				
		This:ClearItemTT	
		WoWScript GameTooltip:ClearLines()		
		WoWScript GameTooltip:SetOwner(UIParent,"ANCHOR_NONE")
		WoWScript GameTooltip:SetBagItem(${bag}, ${slot})
		TotalLines:Set[${WoWScript["GameTooltip:NumLines()"]}]
		do
		{
			This:ConvertToStat[${String["${WoWScript[GameTooltipTextLeft${i}:GetText()]}"]}]				
		}
		while ${i:Inc} <= ${TotalLines}
		WoWScript GameTooltip:Hide()
	}
	
	method ClearItemTT()
	{
		variable int i = 1
	
		/* reset all values to 0 */
		This.Strength:Set[0]
		This.Agility:Set[0]
		This.Stamina:Set[0]
		This.Intellect:Set[0]
		This.Spirit:Set[0]
		This.Strength:Set[0]
		This.Agility:Set[0]
		This.Stamina:Set[0]
		This.Intellect:Set[0]
		This.Spirit:Set[0]
		This.AttackPower:Set[0]
		This.RangedAttackPower:Set[0]
		This.SpellDamage:Set[0]
		This.SpellDamage:Set[0]
		This.HealingBonus:Set[0]
		This.HealingBonus:Set[0]
		This.Defense:Set[0]
		This.Resilience:Set[0]
		This.Dodge:Set[0]
		This.Parry:Set[0]
		This.Hit:Set[0]
		This.SpellHit:Set[0]
		This.Crit:Set[0]
		This.SpellCrit:Set[0]	
		This.MP5:Set[0]		
		This.Block:Set[0]		
		This.RangeHit:Set[0]
		This.RangeCrit:Set[0]		
		This.BindOnEquip:Set[FALSE]	
	}
	
	method ConvertToStat(string TextLine)
	{
		/* we dont count set or socket bonuses */
		if (${TextLine.Find["Set: "]} || ${TextLine.Find["Socket"]}) && !${TextLine.Find["|cffffffff"]}
		{
			return
		}
		
		/* strip out color codes - only grab middle */
		if ${TextLine.Find["|c"]} && ${TextLine.Find["|r"]} 
		{
			/* we also need to strip out the .  at the end */
			if ${TextLine.Find[".|r"]}
			{
				TextLine:Set[${TextLine.Mid[${Math.Calc[${TextLine.Find["|c"]}+10]},${Math.Calc[${TextLine.Find[".|r"]}-${Math.Calc[${TextLine.Find["|c"]}+10]}]}]}]					
			}
			else
			{
				TextLine:Set[${TextLine.Mid[${Math.Calc[${TextLine.Find["|c"]}+10]},${Math.Calc[${TextLine.Find["|r"]}-${Math.Calc[${TextLine.Find["|c"]}+10]}]}]}]
			}
		}
		
		/* avoid multi-line text  */
		if ${TextLine.Find["\r"]} || ${TextLine.Find["\n"]} || ${TextLine.Find["\""]}
		{
			return
		}
		
		/* mark bind on equips */
		if ${TextLine.Find["Binds when equipped"]}
		{
			This.BindOnEquip:Set[TRUE]	
			return
		}

		/* mark unique eqips */
		if ${TextLine.Find["Unique"]}
		{
			This.UniqueEquip:Set[TRUE]	
		}

		/* mark begins quest */
		if ${TextLine.Find["Begins a Quest"]}
		{
			This.BeginsQuest:Set[TRUE]	
		}
		
		/* update stats */
		This.Strength:Inc[${This.GetStat["${TextLine}","%+(%d+)%sStrength",1]}]
		This.Agility:Inc[${This.GetStat["${TextLine}","%+(%d+)%sAgility",1]}]
		This.Stamina:Inc[${This.GetStat["${TextLine}","%+(%d+)%sStamina",1]}]
		This.Intellect:Inc[${This.GetStat["${TextLine}","%+(%d+)%sIntellect",1]}]
		This.Spirit:Inc[${This.GetStat["${TextLine}","%+(%d+)%sSpirit",1]}]
		This.Strength:Inc[${This.GetStat["${TextLine}","%+(%d+)%sAll Stats",1]}]
		This.Agility:Inc[${This.GetStat["${TextLine}","%+(%d+)%sAll Stats",1]}]
		This.Stamina:Inc[${This.GetStat["${TextLine}","%+(%d+)%sAll Stats",1]}]
		This.Intellect:Inc[${This.GetStat["${TextLine}","%+(%d+)%sAll Stats",1]}]
		This.Spirit:Inc[${This.GetStat["${TextLine}","%+(%d+)%sAll Stats",1]}]
		This.AttackPower:Inc[${This.GetStat["${TextLine}","%+(%d+)%sAttack%sPower",1]}]		
		This.AttackPower:Inc[${This.GetStat["${TextLine}","Increases attack power by (%d+)",1]}]
		This.RangedAttackPower:Inc[${This.GetStat["${TextLine}","ranged attack power by (%d+)",1]}]
		This.SpellDamage:Inc[${This.GetStat["${TextLine}","(.+)damage and healing(.+)%s(%d+)",3]}]
		This.HealingBonus:Inc[${This.GetStat["${TextLine}","(.+)healing(.+)%s(%d+)",3]}]
		This.Defense:Inc[${This.GetStat["${TextLine}","defense rating by (%d+)",1]}]
		This.Resilience:Inc[${This.GetStat["${TextLine}","your resilience rating by (%d+)",1]}]
		This.Dodge:Inc[${This.GetStat["${TextLine}","dodge rating by (%d+)",1]}]
		This.Parry:Inc[${This.GetStat["${TextLine}","parry rating by (%d+)",1]}]
		This.Hit:Inc[${This.GetStat["${TextLine}","your hit rating by (%d+)",1]}]
		This.SpellHit:Inc[${This.GetStat["${TextLine}","spell penetration by (%d+)",1]}]
		This.Crit:Inc[${This.GetStat["${TextLine}","your critical strike rating by (%d+)",1]}]
		This.SpellCrit:Inc[${This.GetStat["${TextLine}","spell critical strike rating by (%d+)",1]}]
		This.MP5:Inc[${This.GetStat["${TextLine}","(%d+) mana per 5",1]}]
		This.Block:Inc[${This.GetStat["${TextLine}","(%d+)%sBlock",1]}]
		This.Block:Inc[${This.GetStat["${TextLine}","Increases the block value of your shield by (%d+)",1]}]	
		This.RangeHit:Inc[${This.GetStat["${TextLine}","ranged hit rating by (%d+)",1]}]
		This.RangeCrit:Inc[${This.GetStat["${TextLine}","ranged critical strike rating by (%d+)",1]}]			
	}
	
	member GetStat(string TextLine, string Pattern, int pV)
	{	
		if ${WoWScript["string.find(\"${TextLine}"\, \"${Pattern}"\)",${Math.Calc[${pV}+2]}]}
		{
			return ${WoWScript["string.find(\"${TextLine}"\, \"${Pattern}"\)",${Math.Calc[${pV}+2]}]}
		}
		return 0
	}
	
	/* in honor of Rating Buster - this returns the actual pct or value at your level */
	member Busted(string stat)
	{
		if ${This.${stat}} > 0
		{
			return ${This.ConvertRating[${This.${stat}},${stat}]}
		}
		return 0
	}

	member ConvertRating(float rating, string stat)
	{
		if ${Me.Level} >= 60
		{
			return ${Math.Calc[${rating}/${This.RatingBase[${stat}]}*((-3/82)*${Me.Level}+(131/41))]}	
		}
		if ${Me.Level} >= 10
		{
			return ${Math.Calc[${rating}/${This.RatingBase[${stat}]}/((1/52)*${Me.Level}-(8/52))]}
		}
		else
		{
			return ${Math.Calc[${rating}/${This.RatingBase[${stat}]}/((1/52)*10-(8/52))]}
		}
	}

	member RatingBase(string stat)
	{
		if !${This.BaseScore.Element[${stat}](exists)}
		{
			This:SetRatingBase
			if !${This.BaseScore.Element[${stat}](exists)}
			{
				echo We dont rating bust ${stat}!
				return 0
			}
		}
		return ${This.BaseScore.Element[${stat}]}
	}

	method SetRatingBase()
	{
		/* base scores at level 60 */
		This.BaseScore:Set[Defense,1.5]
		This.BaseScore:Set[Dodge,12]
		This.BaseScore:Set[Parry,15]
		This.BaseScore:Set[Hit,10]
		This.BaseScore:Set[RangeHit,10]
		This.BaseScore:Set[SpellHit,8]
		This.BaseScore:Set[Crit,14]
		This.BaseScore:Set[RangeCrit,14]
		This.BaseScore:Set[SpellCrit,14]
		This.BaseScore:Set[Resilience,25]	
	}	
}