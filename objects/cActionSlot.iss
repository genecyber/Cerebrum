objectdef cActionSlot inherits cBase
{
	variable collection:string ActionSlot
	variable index:oSpell SpellBook
	variable collection:bool MissingSpells
	variable collection:int MissingSpellID
	
	/* compares actions to spellbook and inserts missing spells */
	method AutoSlot(bool ForceSlots=FALSE)
	{
		variable int theSlot
		if (!${Bot.PauseFlag} || ${ForceSlots}) && ${UIElement[chkActionSlot@EQ@Pages@Cerebrum].Checked} 
		{
			This:GetMissingSpells	
			if "${This.MissingSpells.FirstKey(exists)}"
			{
				do
				{
					if ${This.MissingSpells.CurrentValue}
					{
						theSlot:Set[${This.EmptySlot}]
						if ${theSlot} > 0
						{
							This.ActionSlot:Set[${theSlot},${This.MissingSpells.CurrentKey}]
							This:IDToSlot[${This.MissingSpellID.Element[${This.MissingSpells.CurrentKey}]},${theSlot}]
							This:Output[Placing ${This.MissingSpells.CurrentKey} into action slot#${theSlot}]
						}
					}
				}
				while "${This.MissingSpells.NextKey(exists)}"		
			}
		}
	}
	
	method IDToSlot(int SpellID, int theSlot)
	{
		WoWScript PickupSpell(${SpellID},BOOKTYPE_SPELL)
		WoWScript PlaceAction(${theSlot})
	}
	
	/* goddam pain in the ass */
	member EmptySlot()
	{
		/* only checking the default blizzard bars for an empty slot */
		variable int FirstSlot = 1
		variable int LastSlot = 72	
		variable int BestSlot = 0
		variable int CurrentPage = ${WoWScript[GetActionBarPage()]}
		variable bool CheckCurrent = TRUE
		
		/* if our current page is 1, check the class specific bar */
		if ${Me.Class.Equal[Warrior]}
		{
			FirstSlot:Set[13]
			if ${CurrentPage} == 1
			{
				/* need stance */
				if ${Me.Buff[Battle Stance](exists)}
				{
					BestSlot:Set[${This.CheckSlots[73,84]}]				
				}
				if ${Me.Buff[Defensive Stance](exists)}
				{
					BestSlot:Set[${This.CheckSlots[85,96]}]					
				}				
				if ${Me.Buff[Berserker Stance](exists)}
				{
					BestSlot:Set[${This.CheckSlots[97,108]}]					
				}
				CheckCurrent:Set[FALSE]
			}
		}
		elseif ${Me.Class.Equal[Druid]} && ${CurrentPage} == 1
		{
				if ${Me.Buff[Cat Form](exists)}
				{
					BestSlot:Set[${This.CheckSlots[73,84]}]				
				}
				if ${Me.Buff[Bear Form](exists)} || ${Me.Buff[Dire Bear Form](exists)}
				{
					BestSlot:Set[${This.CheckSlots[97,108]}]					
				}
				CheckCurrent:Set[FALSE]
		}
		elseif ${Me.Class.Equal[Rogue]} && ${Me.Buff[Stealth](exists)} && ${CurrentPage} == 1
		{
				BestSlot:Set[${This.CheckSlots[73,84]}]
				CheckCurrent:Set[FALSE]
		}
		
		/* ok, now check our current page */
		if ${BestSlot} == 0 && ${CheckCurrent}
		{
			BestSlot:Set[${This.CheckSlots[${Math.Calc[(${CurrentPage}*12)-11]},${Math.Calc[(${CurrentPage}*12)]}]}]		
		}
		if ${BestSlot} == 0
		{
			BestSlot:Set[${This.CheckSlots[${FirstSlot},${LastSlot}]}]
		}
		return ${BestSlot}
	}
	
	member CheckSlots(int theSlot, int LastSlot)
	{
		do
		{
			if ${This.ActionSlot.Element[${theSlot}].Equal[EMPTY]}
			{
				return ${theSlot}
			}
		}
		while ${theSlot:Inc} <= ${LastSlot}
		return 0
	}
	
	/* compare spells to action slots */
	method GetMissingSpells()
	{
		variable int i = 1
		variable int k = 1
		This:PopulateActionSlots
		This:PopulateSpellBook	
		do
		{	
			k:Set[1]	
			if !${This.SpellBook.Get[${i}].Passive} && !${This.SpellBook.Get[${i}].Trade}
			{
				This.MissingSpells:Set["${This.SpellBook.Get[${i}].Name}",TRUE]
				This.MissingSpellID:Set["${This.SpellBook.Get[${i}].Name}",${This.SpellBook.Get[${i}].ID}]
				do
				{
					if ${This.ActionSlot.Element[${k}].Equal[${This.SpellBook.Get[${i}].Name}]}
					{					
						This.MissingSpells:Set["${This.SpellBook.Get[${i}].Name}",FALSE]
					}
				}
				while ${k:Inc} <= 120
			}
		}
		while ${This.SpellBook.Get[${i:Inc}](exists)}	
	}
	
	method PopulateActionSlots(string SpellName)
	{
		variable string ActionName 
		variable int i = 1
		do
		{
			ActionName:Set[EMPTY]
			if ${Me.Action[${i}](exists)}
			{
				ActionName:Set["${Me.Action[${i}].Name}"]
				if ${ActionName.Find[" ("]} && !${RankText.Find["(Cat)"]} && !${RankText.Find["(Bear)"]} && !${RankText.Find["(Feral)"]}
				{
					/* we dont need rank */
					ActionName:Set[${ActionName.Left[${ActionName.Find[" ("]}]}]
				}
			}	
			This.ActionSlot:Set[${i},${ActionName}]			
		}
		while ${i:Inc} <= 120
	}
	
	method PopulateSpellBook()
	{
		This:DestroySpellBook
		variable int i = 1
		do
		{
			This.SpellBook:Insert[${i}]
		}
		while ${WoWScript["GetSpellName(${i:Inc}, BOOKTYPE_SPELL)",1](exists)}
	}

	method DestroySpellBook()
	{
		variable int i = 1
		if ${This.SpellBook.Get[${i}](exists)}
		{
			do
			{
				This.SpellBook:Remove[${i}]	
			}
			while ${This.SpellBook.Get[${i:Inc}](exists)}
			This.SpellBook:Collapse	
		}
	}
}



objectdef oSpell inherits cBase
{
	variable int ID
	variable string Name
	variable string FullName
	variable string Texture
	variable string Rank
	variable bool Trade = FALSE
	variable bool Passive = FALSE
	
	method Initialize(int SpellID)
	{
		This.ID:Set[${SpellID}]
		This.Name:Set[${WoWScript["GetSpellName(${This.ID}, BOOKTYPE_SPELL)",1]}]
		This.Texture:Set[${WoWScript["GetSpellTexture(${This.ID}, BOOKTYPE_SPELL)"]}]
		This:ParseRank[${WoWScript["GetSpellName(${This.ID}, BOOKTYPE_SPELL)",2]}]
	}

	method ParseRank(string RankText)
	{
		This.Rank:Set[NONE]		
		if ${RankText.Find[Passive]}
		{
			Passive:Set[TRUE]
		}
		if ${RankText.Find[Apprentice]} || ${RankText.Find[Journeyman]} || ${RankText.Find[Expert]} || ${RankText.Find[Artisan]} || ${RankText.Find[Master]}
		{
			Trade:Set[TRUE]
		}
		if ${RankText.Find[Rank]}
		{
			This.Rank:Set[${RankText}]
		}
		if ${This.Rank.NotEqual[NONE]}
		{
			This.FullName:Set["${This.Name} (${This.Rank})"]
		}	
	}
}