#include cSpec.iss
#include cTalents.iss


objectdef cTalentTreeHandler inherits cBase
{

	variable string ConfigDir = "${Script.CurrentDirectory}/config/"

	
	variable collection:oTalent MyTalents
	variable collection:oSpec MySpecs
	variable string currentSpec = ""
	variable string specToLevel = ""

	variable int TreeRestrict = 0
	
	variable string TalentTable = "tlbAvailableTalents@Specs@TalentPages@Talents@Pages@Cerebrum"
	variable string SpecedTable = "tlbSpecedTalents@Specs@TalentPages@Talents@Pages@Cerebrum"
	variable string SpecList = "tlbSpecs@Management@TalentPages@Talents@Pages@Cerebrum"
	variable string ChosenSpec = "cmbSpec@Overview@Pages@Cerebrum"
	variable string SpecPullDown = "cmbSpec@Specs@TalentPages@Talents@Pages@Cerebrum"
	variable string TreePullDown = "cmbTree@Specs@TalentPages@Talents@Pages@Cerebrum"
	
	method ImportSpec(string theName)
	{
		variable int i
		variable int j
		variable string Name

		variable iterator iter
		if !${MySpecs.Element[${theName}](exists)} && !${theName.Equal[""]}
		{
			MySpecs:Set[${theName},${theName}]
			for(i:Set[1];${i}<=3;i:Inc)
			{
				for(j:Set[1];${j}<=${WoWScript[GetNumTalents(${i})]};j:Inc)
				{
					This:ImportTalent[${theName},${WoWScript[GetTalentInfo(${i}\,${j}),1]},${WoWScript[GetTalentInfo(${i}\,${j}),5]}]
				}
			}
			This:PopulateSpecLists
		}
		else
		{
			This:Output[ERROR: You need to specify a new Spec Name to create and Impor too]
		}
	}
	method ImportTalent(string specName,string Talent,int Rank)
	{
		variable int i

		for(i:Set[1];${i} <= ${Rank};i:Inc)
		{
			if ${MySpecs.Element[${specName}].CanAdd[${Talent}]}
			{
				MySpecs.Element[${specName}]:Add[${Talent}]
			}
		}
	}
	
	method Load()
	{
		LavishSettings:AddSet[TalentTrees]
		LavishSettings:AddSet[Specs]
		LavishSettings.FindSet[TalentTrees]:Import[${ConfigDir}TalentTrees.xml]
		LavishSettings.FindSet[Specs]:Import[${ConfigDir}Specs.xml]
		This:Setup
		This:LoadSpecs[${Me.Class}]
		This:PopulateTrees[${Me.Class}]
		This:PopulateSpecLists
		specToLevel:Set[${LavishSettings.FindSet[Specs].FindSetting[${Me.Name},""]}]
		UIElement[${ChosenSpec}]:SelectItem[${UIElement[${ChosenSpec}].ItemByText[${specToLevel}].ID}]
	}
	method Pulse()
	{
		This:Debug[Talent Tree pulst. FreePoints: ${This.freePoints}. Spec: ${specToLevel}]
		if ${This.freePoints} > 0 && ${specToLevel.NotEqual[""]}
		{
				This:UpdateTalents
		}
	}
	method Shutdown()
	{
		This:SaveTalents
		This:SaveSpecs[${Me.Class}]
		LavishSettings.FindSet[Specs]:AddSetting[${Me.Name},${specToLevel}]
		LavishSettings.FindSet[TalentTrees]:Export[${ConfigDir}TalentTrees.xml]
		LavishSettings.FindSet[Specs]:Export[${ConfigDir}Specs.xml]
	}
	method SaveTalents()
	{
		variable iterator iter
		variable settingsetref myClass
		
		MyTalents:GetIterator[iter]
		iter:First
		
		LavishSettings.FindSet[TalentTrees]:AddSet[${Me.Class}]
		myClass:Set[${LavishSettings.FindSet[TalentTrees].FindSet[${Me.Class}]}]
		myClass:Clear
		while ${iter.IsValid}
		{
			myClass:AddSet[${iter.Key}]
			iter.Value:Save
			iter:Next
		}
		
		myClass:AddSet[Trees]
		myClass.FindSet[Trees]:AddSetting[1,${WoWScript[GetTalentTabInfo(1),1]}]
		myClass.FindSet[Trees]:AddSetting[2,${WoWScript[GetTalentTabInfo(2),1]}]
		myClass.FindSet[Trees]:AddSetting[3,${WoWScript[GetTalentTabInfo(3),1]}]
	}
	method SaveSpecs(string Class)
	{
		variable iterator iter
		variable settingsetref myClass
		
		MySpecs:GetIterator[iter]
		iter:First
		

		LavishSettings.FindSet[Specs]:AddSet[${Class}]
		myClass:Set[${LavishSettings.FindSet[Specs].FindSet[${Class}]}]
		myClass:Clear
		
		while ${iter.IsValid}
		{
			myClass:AddSet[${iter.Key}]
			iter.Value:Save[${myClass}]
			iter:Next
		}
	}
	;Setups up the current Talent Tree
	method Setup()
	{
		variable int i
		variable int j
		variable iterator iter
		variable string Name
		
		MyTalents:Clear
		
		for(i:Set[1];${i}<=3;i:Inc)
		{
			for(j:Set[1];${j}<=${WoWScript[GetNumTalents(${i})]};j:Inc)
			{
				Name:Set[${WoWScript[GetTalentInfo(${i}\,${j}),1]}]
				MyTalents:Set[${Name},${i},${j}]
				MyTalents.Element[${Name}]:Load
			}
		}
		
		MyTalents:GetIterator[iter]
		iter:First
		
		while ${iter.IsValid}
		{
			iter.Value:Setup
			iter:Next
		}
	}
	method PopulateTrees(string Class)
	{
		UIElement[${TreePullDown}]:ClearItems
		UIElement[${TreePullDown}]:AddItem[All,0]
		UIElement[${TreePullDown}]:SelectItem[1]
		if ${Class.Equal[${Me.Class}]}
		{
			UIElement[${TreePullDown}]:AddItem[${WoWScript[GetTalentTabInfo(1),1]},1]
			UIElement[${TreePullDown}]:AddItem[${WoWScript[GetTalentTabInfo(2),1]},2]
			UIElement[${TreePullDown}]:AddItem[${WoWScript[GetTalentTabInfo(3),1]},3]
		}
	}
	method LoadTalents(string Class)
	{
		variable settingsetref theClass  = ${LavishSettings.FindSet[TalentTrees].FindSet[${Class}].GUID}
		variable iterator iter
		
		MyTalents:Clear
		
		theClass:GetSetIterator[iter]
		iter:First
		
		while ${iter.IsValid}
		{
			MyTalents:Set[${iter.Key},0,0]
			MyTalents.Element[${iter.Key}].Name:Set[${iter.Key}]
			iter:Next
		}
		
		MyTalents:GetIterator[iter]
		iter:First
		
		while ${iter.IsValid}
		{
			iter.Value:LoadFromFile[${Class}]
			iter:Next
		}
	}
	method LoadSpecs(string Class)
	{
		variable settingsetref theClass  = ${LavishSettings.FindSet[Specs].FindSet[${Class}].GUID}
		variable iterator iter
		
		MySpecs:Clear
		
		theClass:GetSetIterator[iter]
		iter:First
		
		while ${iter.IsValid}
		{
			MySpecs:Set[${iter.Key},${iter.Key}]
			MySpecs.Element[${iter.Key}]:Load[${iter.Value.GUID}]
			iter:Next
		}		
	}
	method PopulateAvailable()
	{
		UIElement[${TalentTable}]:ClearItems
		if ${TreeRestrict} != 0
		{
			MySpecs.Element[${currentSpec}]:PopulateAvailableTree[${TalentTable},${TreeRestrict}]
		}
		else
		{
			MySpecs.Element[${currentSpec}]:PopulateAllAvailable[${TalentTable}]
		}
	}
	method PopulateSpeced()
	{
		UIElement[${SpecedTable}]:ClearItems
		MySpecs.Element[${currentSpec}]:PopulateSpeced[${SpecedTable}]
	}
	method PopulateSpecLists()
	{
		This:PopulateSpecs[${SpecList}]
		This:PopulateSpecs[${SpecPullDown}]
		This:PopulateSpecs[${ChosenSpec}]
	}
	method PopulateSpecs(string theList)
	{
		variable iterator iter
		
		MySpecs:GetIterator[iter]
		iter:First

		UIElement[${theList}]:ClearItems
		while ${iter.IsValid}
		{
			UIElement[${theList}]:AddItem[${iter.Key}]
			iter:Next
		}		
	}
	method ChangeSpec(string theName)
	{
		currentSpec:Set[${theName}]
		MySpecs.Element[${currentSpec}]:Build
		This:PopulateAvailable
		This:PopulateSpeced
	}
	method ChangeClass(string theName)
	{
		TreeRestrict:Set[0]
		currentSpec:Set[""]
		;Will have to reload specs and Talents and then reset tree combo
	}
	method ChangeTree(int theTree)
	{
		TreeRestrict:Set[${theTree}]
		This:PopulateAvailable
	}
	method AddSpec(string theName)
	{
		if !${MySpecs.Element[${theName}](exists)} && !${theName.Equal[""]}
		{
			MySpecs:Set[${theName},${theName}]
			This:PopulateSpecLists
		}
	}
	method RemoveSpec(string theName)
	{
		MySpecs:Erase[${theName}]
		This:PopulateSpecLists
	}
	method AddTalent()
	{
		variable string theTalent = ${UIElement[${TalentTable}].SelectedItem.Text}
		if ${theTalent.NotEqual[NULL]}
		{
			MySpecs.Element[${currentSpec}]:Add[${theTalent}]
			This:PopulateSpeced
			if ${MySpecs.Element[${currentSpec}].NeedsUpdate} || ${MySpecs.Element[${currentSpec}].MaxRank[${theTalent}]}
			{
				This:PopulateAvailable
			}
		}
	}
	method RemoveTalent()
	{
		variable string theTalent = ${UIElement[${SpecedTable}].SelectedItem.Text}
		variable string theLevel = ${UIElement[${SpecedTable}].SelectedItem.Value}

		if ${theTalent.NotEqual[NULL]}
		{	
			if ${MySpecs.Element[${currentSpec}].CanRemove[${theTalent},${theLevel}]}
			{
				MySpecs.Element[${currentSpec}]:Remove[${theTalent},${theLevel}]
				MySpecs.Element[${currentSpec}]:Dec
				This:PopulateSpeced
				This:PopulateAvailable
			}
		}
	}
	member SpecTalent(string Spec,int Level)
	{
		return ${MySpecs.Element[${Spec}].AtLevel.Get[${Level}]}
	}
	method TalentLevelIncrease()
	{
		variable string theTalent = ${UIElement[${SpecedTable}].SelectedItem.Text}
		variable int theLevel = ${UIElement[${SpecedTable}].SelectedItem.Value}
		variable int otherLevel = ${Math.Calc[${theLevel} - 1]}
		variable string otherTalent = ${This.SpecTalent[${currentSpec},${otherLevel}]}

		if ${theTalent.NotEqual[NULL]} && ${otherTalent.NotEqual[NULL]}
		{
			if ${MySpecs.Element[${currentSpec}].Swap[${theTalent},${theLevel},${otherTalent},${otherLevel}]}
			{
				This:PopulateSpeced
				UIElement[${SpecedTable}]:SelectItem[${otherLevel}]
			}
		}
	}
	method TalentLevelDecrease()
	{
		variable string theTalent = ${UIElement[${SpecedTable}].SelectedItem.Text}
		variable int theLevel = ${UIElement[${SpecedTable}].SelectedItem.Value}
		variable int otherLevel = ${Math.Calc[${theLevel} + 1]}
		variable string otherTalent = ${This.SpecTalent[${currentSpec},${otherLevel}]}

		if ${theTalent.NotEqual[NULL]} && ${otherTalent.NotEqual[NULL]}
		{
			if ${MySpecs.Element[${currentSpec}].Swap[${otherTalent},${otherLevel},${theTalent},${theLevel}]}
			{
				This:PopulateSpeced
				UIElement[${SpecedTable}]:SelectItem[${otherLevel}]
			}
		}
	}
	member TabIndex(string Tree)
	{
		if ${WoWScript[GetTalentTabInfo(1),1].Equal[${Tree}]}
		{
			return 1
		}
		if ${WoWScript[GetTalentTabInfo(2),1].Equal[${Tree}]}
		{
			return 2
		}
		if ${WoWScript[GetTalentTabInfo(3),1].Equal[${Tree}]}
		{
			return 3
		}
	}
	member pointsInTalent(string TalentName)
	{
		return ${MyTalents.Element[${TalentName}].Rank}
	}
	member pointsInTree(string TreeName)
	{
		variable iterator iter
		variable int count = 0
		variable int tab = ${This.TabIndex[${TreeName}]}
		
		MyTalents:GetIterator[iter]
		iter:First
		while ${iter.IsValid}
		{
			if ${iter.Value.TabIndex} == ${tab}
			{
				count:Inc
			}
			iter:Next
		}
		return ${count}
	}
	member freePoints()
	{
		variable int totalSpent = 0
		if ${Me.Level} >= 10
		{
			totalSpent:Inc[${WoWScript[GetTalentTabInfo(1),3]}]
			totalSpent:Inc[${WoWScript[GetTalentTabInfo(2),3]}]
			totalSpent:Inc[${WoWScript[GetTalentTabInfo(3),3]}]
			return ${Math.Calc[(${Me.Level}-9)-${totalSpent}]}
		}
		return 0		
	}
	method spendPoint(string Talent)
	{
		MyTalents.Element[${Talent}]:Level
	}
	method UpdateTalents()
	{
		variable int i
		variable string theTalent
		for(i:Set[10]; ${i} <= ${Me.Level};i:Inc)
		{		
			theTalent:Set[${MySpecs.Element[${specToLevel}].TalentAt[${i}]}]
			
			if !${theTalent.Equal[""]} && !${theTalent.Equal[NULL]}
			{
				This:Debug[Valid Talent to Level Found: ${theTalent}]
				This:Debug[Spec to Level: ${specToLevel}]
				This:Debug[Points in: ${This.pointsInTalent[${theTalent}]}]
				This:Debug[Specified Points: ${MySpecs.Element[${specToLevel}].TalentRank[${theTalent},${Math.Calc[${i}-9]}]}]
				if ${This.pointsInTalent[${theTalent}]} <= ${MySpecs.Element[${specToLevel}].TalentRank[${theTalent},${Math.Calc[${i}-9]}]}
				{
					This:Debug[Leveling Talent: ${theTalent}]
					This:spendPoint[${theTalent}]
					This:Debug[Post Rank: ${This.pointsInTalent[${theTalent}]}]
					return
				}
			}
		}	
	}
}

	
