#define LEVELCAP 70

objectdef cSpec inherits cBase
{
	variable index:string AtLevel
	variable collection:set Talents
	variable index:set Trees
	variable string Name
	variable bool Built = FALSE
	variable index:int TreeRanks


	method Initialize(string myName)
	{
		Trees:Insert[1]
		Trees:Insert[1]
		Trees:Insert[1]
		TreeRanks:Insert[0]
		TreeRanks:Insert[0]
		TreeRanks:Insert[0]
		AtLevel:Resize[LEVELCAP]
		Name:Set[${myName}]
	}
	method Load(string GUID)
	{
		variable settingsetref Main = ${GUID}
		variable iterator iter
		Main:GetSettingIterator[iter]
		iter:First
		while ${iter.IsValid}
		{
			AtLevel:Set[${iter.Key},${iter.Value}]
			iter:Next
		}
	}
	member TalentAt(int Level)
	{
		Level:Dec[9]
		return ${AtLevel.Get[${Level}]}
	}
	method Build()
	{
		variable int i
		variable int TabIndex
		for(i:Set[1];${i}<=${AtLevel.Used};i:Inc)
		{
			TabIndex:Set[${TalentTree.MyTalents.Element[${AtLevel.Get[${i}]}].TabIndex}]
			Trees.Get[${TabIndex}]:Add[${i.LeadingZeroes[2]}]
			if !${Talents.Element[${AtLevel.Get[${i}]}](exists)}
			{
				Talents:Set[${AtLevel.Get[${i}]}]
			}
			Talents.Element[${AtLevel.Get[${i}]}]:Add[${i.LeadingZeroes[2]}]
		}
		
		lastTreeRank1:Set[${This.TreeRank[1]}]
		lastTreeRank2:Set[${This.TreeRank[2]}]
		lastTreeRank3:Set[${This.TreeRank[3]}]
		
		This.Built:Set[TRUE]
	}
	method Save(int GUID)
	{
		variable settingsetref Main = ${LavishSettings.SetByID[${GUID}].FindSet[${Name}]}
		variable int i

		for(i:Set[1];${i} <= ${AtLevel.Used};i:Inc)
		{
			Main:AddSetting[${i},${AtLevel.Get[${i}]}]
		}
	}
	member:bool NeedsUpdate()
	{
		if ${Float[${Math.Calc[${This.TreeRank[1]}/5]}].Int} != ${TreeRanks.Get[1]}
		{
			TreeRanks:Set[1,${Float[${Math.Calc[${This.TreeRank[1]}/5]}].Int}]
			return TRUE
		}
		if ${Float[${Math.Calc[${This.TreeRank[2]}/5]}].Int} != ${TreeRanks.Get[2]}
		{
			TreeRanks:Set[2,${Float[${Math.Calc[${This.TreeRank[2]}/5]}].Int}]
			return TRUE
		}
		if ${Float[${Math.Calc[${This.TreeRank[3]}/5]}].Int} != ${TreeRanks.Get[3]}
		{
			TreeRanks:Set[3,${Float[${Math.Calc[${This.TreeRank[3]}/5]}].Int}]
			return TRUE
		}
		return FALSE
	}
	method Print()
	{
		variable int i
		for(i:Set[1];${i} <= ${AtLevel.Used};i:Inc)
		{
			echo ${AtLevel.Get[${i}]} at ${i}
		}
	}
	method Add(string Talent)
	{
		variable int TabIndex = ${TalentTree.MyTalents.Element[${Talent}].TabIndex}

		AtLevel:Insert[${Talent}]
		if !${Talents.Element[${Talent}](exists)}
		{
			Talents:Set[${Talent}]
		}
		Talents.Element[${Talent}]:Add[${AtLevel.Used.LeadingZeroes[2]}]
		Trees.Get[${TabIndex}]:Add[${AtLevel.Used.LeadingZeroes[2]}]
	}
	method Remove(string Talent,int Level)
	{
		if ${Level} == 0
		{
			Level:Set[${This.CurrentLevel}
		}
		variable int TabIndex = ${TalentTree.MyTalents.Element[${Talent}].TabIndex}
		AtLevel:Remove[${Level}]
		Talents.Element[${Talent}]:Remove[${Level.LeadingZeroes[2]}]
		Trees.Get[${TabIndex}]:Remove[${Level.LeadingZeroes[2]}]
	}
	member:bool CanRemove(string Talent,int Level)
	{
		variable int i
		This:Remove[${Talent},${Level}]

		if ${Level} == 0
		{
			Level:Set[${This.CurrentLevel}
		}
		for(i:Set[${Math.Calc[${Level}+1]}];${i}<=${AtLevel.Used};i:Inc)
		{
			if !${This.CanAdd[${AtLevel.Get[${i}]},${i}]}
			{
				This:Add[${Talent},${Level}]
				return FALSE
			}
		}
		This:Add[${Talent},${Level}]
		return TRUE
	}

	method Dec()
	{
		AtLevel:Collapse
		Talents:Clear
		Trees:Clear
		Trees:Insert[1]
		Trees:Insert[1]
		Trees:Insert[1]
		This:Build
	}
	member:bool Swap(string Talent1,int Level1,string Talent2,int Level2)
	{

		if ${This.CanRemove[${Talent1},${Level1}]} && ${This.CanRemove[${Talent2},${Level2}]}
		{

			This:Remove[${Talent1},${Level1}]
			This:Remove[${Talent2},${Level2}]
			if ${This.CanAdd[${Talent1},${Level2}]} && ${This.CanAdd[${Talent2},${Level1}]}
			{

				This:Add[${Talent1},${Level2}]
				This:Add[${Talent2},${Level1}]
				return TRUE
			}
			else
			{	

				This:Add[${Talent2},${Level2}]
				This:Add[${Talent1},${Level1}]
			}
		}
		return FALSE
	}
	member:bool CanAdd(string Talent,int Level)
	{
		if ${Level} == 0
		{
			Level:Set[${This.CurrentLevel}
		}
		if ${This.TierMet[${Talent},${Level}]} && ${This.PreReqMet[${Talent},${Level}]} && !${This.MaxRank[${Talent},${Level}]}
		{
			return TRUE
		}
		return FALSE		
	}
	member:bool TierMet(string Talent,int Level)
	{
		if ${Level} == 0
		{
			Level:Set[${This.CurrentLevel}
		}
		variable int Tier = ${TalentTree.MyTalents.Element[${Talent}].Tier}
		variable int TabIndex = ${TalentTree.MyTalents.Element[${Talent}].TabIndex}

		if ${This.TreeRank[${TabIndex},${Level}]} < ${Math.Calc[(${Tier}-1)*5]}
		{
			return FALSE
		}
		return TRUE
		 
	}
	member:bool PreReqMet(string Talent,int Level)
	{
		if ${Level} == 0
		{
			Level:Set[${This.CurrentLevel}
		}
		variable string PreReq = ${TalentTree.MyTalents.Element[${Talent}].PreReq}

		if ${This.MaxRank[${PreReq},${Level}]}
		{
			return TRUE
		}
		return FALSE
	}
	member:bool MaxRank(string Talent,int Level)
	{
		if ${Level} == 0
		{
			Level:Set[${This.CurrentLevel}]
		}
		variable int MaxRank = ${TalentTree.MyTalents.Element[${Talent}].MaxRank}
		variable int Rank = ${This.TalentRank[${Talent},${Level}]}

		if ${Rank} >= ${MaxRank}
		{
			return TRUE
		}
		return FALSE
	}
	member:int TreeRank(int Tree,int Level)
	{
		variable iterator iter
		variable int i = 0
		if ${Level} == 0
		{
			Level:Set[${This.CurrentLevel}]
		}

		if ${Tree} < 1 || ${Tree} > 3
		{
			return 0
		}

		Trees.Get[${Tree}]:GetIterator[iter]
		iter:First
		while ${iter.IsValid}
		{
			if ${iter.Key} < ${Level}
			{
				i:Inc
			}
			iter:Next
		}
		return ${i}
	}
	member:int TalentRank(string Talent,int Level)
	{
		variable iterator iter
		variable int i = 0
		if ${Level} == 0
		{
			Level:Set[${This.CurrentLevel}]
		}
		if !${Talents.Element[${Talent}](exists)}
		{
			return 0
		}
		Talents.Element[${Talent}]:GetIterator[iter]
		iter:First
		while ${iter.IsValid}
		{

			if ${iter.Key} < ${Level}
			{
				i:Inc
			}
			iter:Next
		}
		return ${i}
	} 
	member:int CurrentLevel()
	{
		return ${Math.Calc[${This.AtLevel.Used} + 1]}
	}
	method PopulateSpeced(string theList)
	{
		variable int i
		for(i:Set[1];${i} <= ${AtLevel.Used};i:Inc)
		{
			UIElement[${theList}]:AddItem[${AtLevel.Get[${i}]},${i}]
		}
	}
	method PopulateAllAvailable(string theList)
	{
		variable iterator iter
		
		TalentTree.MyTalents:GetIterator[iter]
		iter:First

		while ${iter.IsValid}
		{
			if ${This.CanAdd[${iter.Key}]}
			{
				UIElement[${theList}]:AddItem[${iter.Key}]
			}
			iter:Next
		}
	}
	method PopulateAvailableTree(string theList, int theTree)
	{
		variable iterator iter
		
		TalentTree.MyTalents:GetIterator[iter]
		iter:First

		while ${iter.IsValid}
		{
			if ${TalentTree.MyTalents.Element[${iter.Key}].TabIndex} == ${theTree} && ${This.CanAdd[${iter.Key}]}
			{
				UIElement[${theList}]:AddItem[${iter.Key}]
			}
			iter:Next
		}
	}
}


