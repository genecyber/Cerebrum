
objectdef cTalent inherits cBase
{
	variable string Name
	variable int Rank
	variable int MaxRank
	variable int TabIndex
	variable int TalentIndex
	variable int Tier
	variable int Column
	variable string PreReq
	method Initialize(int theTabIndex,int theTalentIndex)
	{
		TalentIndex:Set[${theTalentIndex}]
		TabIndex:Set[${theTabIndex}]
	}
	method Print()
	{
		This:Output["${This.Name} - ${This.Tier} - ${This.Rank}/${This.MaxRank}"]
	}
	method Level()
	{
		WoWScript LearnTalent(${This.TabIndex}\,${This.TalentIndex})
		This.Rank:Inc
	}
	method Load()
	{
		Name:Set[${WoWScript[GetTalentInfo(${TabIndex}\,${TalentIndex}),1]}]
		Tier:Set[${WoWScript[GetTalentInfo(${TabIndex}\,${TalentIndex}),3]}]
		Column:Set[${WoWScript[GetTalentInfo(${TabIndex}\,${TalentIndex}),4]}]
		Rank:Set[${WoWScript[GetTalentInfo(${TabIndex}\,${TalentIndex}),5]}]
		MaxRank:Set[${WoWScript[GetTalentInfo(${TabIndex}\,${TalentIndex}),6]}]
	}
	method Print()
	{
		echo ${Name} - ${Tier} - ${Column} - ${Rank} - ${MaxRank}
	}
	method Setup()
	{
		variable iterator iter
		variable int preReqColumn = 0
		variable int preReqTier = 0
		
		preReqTier:Set[${WoWScript[GetTalentPrereqs(${TabIndex}\,${TalentIndex}),1]}]
		preReqColumn:Set[${WoWScript[GetTalentPrereqs(${TabIndex}\,${TalentIndex}),2]}]
		
		TalentTree.MyTalents:GetIterator[iter]
		iter:First
	
		while ${iter.IsValid}
		{
			if ${iter.Value.TabIndex} == ${This.TabIndex} && ${iter.Value.Column} == ${preReqColumn} && ${iter.Value.Tier} ==${preReqTier}
			{
				PreReq:Set[${iter.Key}]
				return
			}
			iter:Next
		}
	}
	method Save()
	{
		variable settingsetref myTalent = ${LavishSettings.FindSet[TalentTrees].FindSet[${Me.Class}].FindSet[${Name}]}
		
		myTalent:AddSetting[TabIndex,${TabIndex}]
		myTalent:AddSetting[MaxRank,${MaxRank}]
		myTalent:AddSetting[TalentIndex,${TalentIndex}]
		myTalent:AddSetting[Tier,${Tier}]
		myTalent:AddSetting[Column,${Column}]
		myTalent:AddSetting[PreReq,${PreReq}]
	}
	method LoadFromFile(string Class)
	{
		variable settingsetref myTalent = ${LavishSettings.FindSet[TalentTrees].FindSet[${Class}].FindSet[${Name}]}
		TabIndex:Set[${myTalent.FindSetting[TabIndex]}]
		MaxRank:Set[${myTalent.FindSetting[MaxRank]}]
		TalentIndex:Set[${myTalent.FindSetting[TalentIndex]}]
		Tier:Set[${myTalent.FindSetting[TierIndex]}]
		Column:Set[${myTalent.FindSetting[ColumnIndex]}]
		PreReq:Set[${myTalent.FindSetting[PreReqIndex]}]
	}
}





