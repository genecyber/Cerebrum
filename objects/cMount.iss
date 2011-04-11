objectdef cMount inherits cBase
{
	variable int LastMount = ${LavishScript.RunningTime}
	variable int LastDismount = ${LavishScript.RunningTime}
	variable int SafetyDistance = 30
	variable int UIMountingError = 0
	variable int Offset = 0
	
	member DismountDistance()
	{
		if ${POI.Type.Equal[HOTSPOT]}
		{
			return ${Grind.GrindRange}
		}
		return ${Float[25]}
	}
	
	member Distance()
	{
		if ${POI.Type.Equal[HOTSPOT]}
		{
			return ${Math.Calc[300+(${Grind.GrindRange}*2.5)]}
		}
		return ${Float[200]}
	}
	
	method Mount()
	{
		if !${This.NeedMount}
		{
			return
		}
		
		/* close visible frames */
		if ${WoWScript[MerchantFrame:IsShown()]} 
		{
			WoWScript "MerchantFrame:Hide()"
		}
		if ${WoWScript[MailFrame:IsShown()]}
		{
			WoWScript "MailFrame:Hide()"
		}		
		
		/* make sure we are standing */
		Toon:Standup
		
		/* stop move */
		move -stop
		Navigator:ClearPath
		
		/* every other attempt needs to be a brief pause to ensure we are not moving */
		if ${Math.Calc[${This.Offset:Inc}%3]} > 0
		{
			Bot.ForcedStateWait:Set[${This.InTenths[5]}]
			return
		}
		
		if ${Me.Class.Equal["Druid"]} && ${WoWScript[GetShapeshiftForm()]} != 0
		{
			/*		If I'm a Druid and I'm shapeshifted, leave form		*/
			WoWScript CastShapeshiftForm(${WoWScript[GetShapeshiftForm()]})
			return
		}
		
		if ${Spell[${This.GetMount}](exists)}
		{
			cast ${This.GetMount}
		}
		else
		{
			Item[${This.GetMount}]:Use
		}
		This:Output["Mounting."]
		This.LastMount:Set[${LavishScript.RunningTime}]
		Bot.ForcedStateWait:Set[${This.InTenths[40]}]		
	}
	
	member NeedMount()
	{
	 	if ${Me.Dead} || ${Me.Ghost} || (${Me.Level} < 40 && !${Spell[Travel Form](exists)}) || !${UIElement[chkUseMount@Config@Pages@Cerebrum].Checked} || ${Navigator.NeedDismount}
	 	{
			return FALSE
		}
		
		if ${LavishScript.RunningTime} < ${This.UIMountingError}
		{
			return FALSE
		}
		
		if ${POI.Distance} < ${This.Distance} || ${Math.Calc[${LavishScript.RunningTime} - ${This.LastMount}]} < 15000
		{
			return FALSE
		}
		
		if ${This.GetMount.Equal[NONE]} || ${This.IsMounted} || ${Me.Buff["Travel Form"](exists)}
		{
			return FALSE
		}
		
		if ${Me.InCombat} || ${Me.Swimming} || ${Me.Flying} || ${Me.Ghost} || ${Me.Dead}
		{
			return FALSE
		}
		
		if ${POI.Type.Equal[0]}
		{
			return FALSE
		}	
		
		if ${This.IsIndoors}
		{
			return FALSE
		}	
		return TRUE		
	}
 
	member GetMount()
	{	 	
	 	if ${Me.Level} < 40 && !${Spell[Travel Form](exists)}
	 	{
	 		return NONE
	 	}
	 	
		variable guidlist ItemList
 
		;Epic
		if ${Spell[Summon Dreadsteed](exists)}
		{
			return ${Spell[Summon Dreadsteed].ID}
		}
		if ${Spell[Summon Charger](exists)}
		{
			return ${Spell[Summon Charger].ID}
		}
 
		ItemList:Search[-items,-inventory,-usable,-epic,-skill, Riding]
		if ${ItemList.Count} > 0
		{
			return ${Item[${ItemList.GUID[1]}]}
		}
 
		;None Epic
		if ${Spell[Summon Felsteed](exists)}
		{
			return ${Spell[Summon Felsteed].ID}
		}
		if ${Spell[Summon Warhorse](exists)}
		{
			return ${Spell[Summon Warhorse].ID}
		}
 
		ItemList:Search[-items,-inventory,-usable,-skill, Riding]
		if ${ItemList.Count} > 0
		{
			return ${Item[${ItemList.GUID[1]}]}
		}
		
		;Travel Form
		if ${Spell[Travel Form](exists)}
	 	{
	 		return ${Spell[Travel Form].ID}
	 	}

		return NONE
	}
 
	method Dismount()
	{
		if ${Math.Calc[${LavishScript.RunningTime} - ${This.LastDismount}]} < 5000 || !${This.IsMounted}
		{
			return
		}
	
		This:Output["Dismounting."]
		if ${Me.Class.Equal["Druid"]} && ${WoWScript[GetShapeshiftForm()]} != 0
		{
			/*		If I'm a Druid and I'm shapeshifted, leave form		*/
			WoWScript CastShapeshiftForm(${WoWScript[GetShapeshiftForm()]})
		}
		else
		{
			WoWScript Dismount()
			This.LastDismount:Set[${LavishScript.RunningTime}]
		}
	}
 
	member IsMounted()
	{
		if ${WoWScript[IsMounted()]} || ${Me.Buff["Travel Form"](exists)}
		{
			return TRUE
		}
		return FALSE
	}
	
	variable point3f LastIndoors = ${Me.Location}
	member IsIndoors()
	{
		if ${WoWScript[IsIndoors()]} 
		{
			This.LastIndoors:Set[${Me.Location}]
			return TRUE
		}
		if ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${This.LastIndoors.X},${This.LastIndoors.Y},${This.LastIndoors.Z}]} < 30
		{
			This:Debug["We are outdoors, but within 30 yards of our last indoor location."]
			return TRUE
		}
		return FALSE
	}
}