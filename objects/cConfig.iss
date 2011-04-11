objectdef cConfig inherits cBase
{
	variable collection:int Sliderx
	variable collection:bool Xboxx
	variable collection:string Combox
	variable collection:string GUIStrings
		
	method Initialize()
	{
	}	
	
	method Shutdown()
	{
		/* save Global and Toon */ 
		This:SaveGlobal
		This:SaveToon
		LavishSettings["Cerebrum"]:Export["config/settings.xml"]
	}
	
	/* this does nothing */
	method Pulse()
	{	
	}
	
	method LoadSaved()
	{
		LavishSettings:AddSet["Cerebrum"]
		LavishSettings["Cerebrum"]:Clear
		LavishSettings["Cerebrum"]:Import["config/settings.xml"]
		/* load global and toon */
		This:SetGlobalGUI
		This:SetToonGUI
	}

	method SetSetting(string branch, string name, string value)
	{
		if !${LavishSettings["Cerebrum"].FindSet[${branch}](exists)}
		{
			LavishSettings["Cerebrum"]:AddSet[${branch}]
		}
		LavishSettings["Cerebrum"].FindSet[${branch}].FindSetting[${name},0]:Set[${value}]
	}
	
	member GetSetting(string branch, string name, string defaultvalue = NULL)
	{
		if !${LavishSettings["Cerebrum"].FindSet[${branch}](exists)}
		{
			LavishSettings["Cerebrum"]:AddSet[${branch}]
		}
		return ${LavishSettings["Cerebrum"].FindSet[${branch}].FindSetting[${name},${defaultvalue}]}
	}	
	
	/* -------- GLOBAL SETTINGS -------- */
	/* these are options set in GUI that are global across all characters */
	method SetGlobalGUI()
	{		
		This:SetCheckBox["GlobalCerebrum","chkLSOFormat","chkLSOFormat@Config@Pages@Cerebrum"]		
		This:SetCheckBox["GlobalCerebrum","chkLogOutput","chkLogOutput@Config@Pages@Cerebrum"]		
		This:SetCheckBox["GlobalCerebrum","chkTranslate","chkTranslate@Config@HumanPages@Human@Pages@Cerebrum"]
		This:SetCheckBox["GlobalCerebrum","chkCaptureWhispers","chkCaptureWhispers@Config@HumanPages@Human@Pages@Cerebrum",TRUE]
		This:SetCheckBox["GlobalCerebrum","chkAutoEmote","chkAutoEmote@Config@HumanPages@Human@Pages@Cerebrum"]
		This:SetCheckBox["GlobalCerebrum","chkUseMount","chkUseMount@Config@Pages@Cerebrum"]	
		This:SetCheckBox["GlobalCerebrum","chkHumanSoundOn","chkHumanSoundOn@Config@HumanPages@Human@Pages@Cerebrum",TRUE]	
		This:SetCheckBox["GlobalCerebrum","chkSoundOn","chkSoundOn@Config@Pages@Cerebrum",TRUE]	
		This:SetCheckBox["GlobalCerebrum","chkErrorSoundOn","chkErrorSoundOn@Config@Pages@Cerebrum",TRUE]	
		This:SetCheckBox["GlobalCerebrum","chkDeathSoundOn","chkDeathSoundOn@Config@Pages@Cerebrum"]	
		This:SetCheckBox["GlobalCerebrum","chkKillSoundOn","chkKillSoundOn@Config@Pages@Cerebrum"]	
		This:SetCombo["GlobalCerebrum","cmbBotGlobalCooldown","cmbBotGlobalCooldown@Overview@Pages@Cerebrum"]
		This:SetSlider["GlobalCerebrum","sldFollowRadius","sldFollowRadius@Config@HumanPages@Human@Pages@Cerebrum",80]
		This:SetSlider["GlobalCerebrum","sldFollowAlertInterval","sldFollowAlertInterval@Config@HumanPages@Human@Pages@Cerebrum",60]
		This:SetSlider["GlobalCerebrum","sldMaxFollows","sldMaxFollows@Config@HumanPages@Human@Pages@Cerebrum",3]
		This:SetSlider["GlobalCerebrum","sldLongIntervalReset","sldLongIntervalReset@Config@HumanPages@Human@Pages@Cerebrum",36000]
		This:SetCheckBox["GlobalCerebrum","chkActiveSonar","chkActiveSonar@Config@HumanPages@Human@Pages@Cerebrum",TRUE]
		This:SetCheckBox["GlobalCerebrum","chkTrackFaction","chkTrackFaction@Config@HumanPages@Human@Pages@Cerebrum",TRUE]
		This:SetCheckBox["GlobalCerebrum","chkTrackOppositeFaction","chkTrackOppositeFaction@Config@HumanPages@Human@Pages@Cerebrum",TRUE]	
		This:SetCheckBox["GlobalCerebrum","chkTargetFollower","chkTargetFollower@Config@HumanPages@Human@Pages@Cerebrum"]
		This:SetCheckBox["GlobalCerebrum","chkFollowLogout","chkFollowLogout@Config@HumanPages@Human@Pages@Cerebrum"]
		This:SetCheckBox["GlobalCerebrum","chkStopOnFollow","chkStopOnFollow@Config@HumanPages@Human@Pages@Cerebrum"]
		This:SetCheckBox["GlobalCerebrum","chkEmoteOnFollow","chkEmoteOnFollow@Config@HumanPages@Human@Pages@Cerebrum"]
		This:SetCheckBox["GlobalCerebrum","chkBeepOnFollow","chkBeepOnFollow@Config@HumanPages@Human@Pages@Cerebrum",TRUE]	
		This:SetCheckBox["GlobalCerebrum","chkNewLocOnFollow","chkNewLocOnFollow@Config@HumanPages@Human@Pages@Cerebrum"]
		This:SetSlider["GlobalCerebrum","sldEmoteTimer","sldEmoteTimer@Config@HumanPages@Human@Pages@Cerebrum",90]
		This:SetSlider["GlobalCerebrum","sldMaxTargetCollection","sldMaxTargetCollection@Overview@Pages@Cerebrum",5]
	}

	method SaveGlobal()
	{	
		This:SaveCheckBox["GlobalCerebrum","chkLSOFormat"]				
		This:SaveCheckBox["GlobalCerebrum","chkLogOutput"]		
		This:SaveCheckBox["GlobalCerebrum","chkTranslate"]	
		This:SaveCheckBox["GlobalCerebrum","chkCaptureWhispers"]	
		This:SaveCheckBox["GlobalCerebrum","chkAutoEmote"]	
		This:SaveCheckBox["GlobalCerebrum","chkUseMount"]
		This:SaveCheckBox["GlobalCerebrum","chkHumanSoundOn"]	
		This:SaveCheckBox["GlobalCerebrum","chkSoundOn"]	
		This:SaveCheckBox["GlobalCerebrum","chkErrorSoundOn"]
		This:SaveCheckBox["GlobalCerebrum","chkDeathSoundOn"]
		This:SaveCheckBox["GlobalCerebrum","chkKillSoundOn"]		
		This:SaveCombo["GlobalCerebrum","cmbBotGlobalCooldown"]
		This:SaveSlider["GlobalCerebrum","sldFollowRadius"]
		This:SaveSlider["GlobalCerebrum","sldFollowAlertInterval"]
		This:SaveSlider["GlobalCerebrum","sldMaxFollows"]
		This:SaveSlider["GlobalCerebrum","sldLongIntervalReSave"]
		This:SaveCheckBox["GlobalCerebrum","chkActiveSonar"]
		This:SaveCheckBox["GlobalCerebrum","chkTrackFaction"]
		This:SaveCheckBox["GlobalCerebrum","chkTrackOppositeFaction"]	
		This:SaveCheckBox["GlobalCerebrum","chkTargetFollower"]
		This:SaveCheckBox["GlobalCerebrum","chkFollowLogout"]
		This:SaveCheckBox["GlobalCerebrum","chkStopOnFollow"]
		This:SaveCheckBox["GlobalCerebrum","chkEmoteOnFollow"]
		This:SaveCheckBox["GlobalCerebrum","chkBeepOnFollow"]
		This:SaveCheckBox["GlobalCerebrum","chkNewLocOnFollow"]		
		This:SaveSlider["GlobalCerebrum","sldEmoteTimer"]
		This:SaveSlider["GlobalCerebrum","sldMaxTargetCollection"]
		
	}
	
	/* -------- TOON SETTINGS -------- */
	/* these are options set in GUI that are global across a unique Toon */
	method SetToonGUI()
	{
		variable string uniqueToon = "${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Name}"	
		This:SetCheckBox[${uniqueToon},"chkGather","chkGather@Config@InvPages@Inventory@Pages@Cerebrum",TRUE]		
		This:SetCheckBox[${uniqueToon},"chkLoot","chkLoot@Config@InvPages@Inventory@Pages@Cerebrum",TRUE]
		This:SetCheckBox[${uniqueToon},"chkHarvestQuests","chkHarvestQuests@Config@InvPages@Inventory@Pages@Cerebrum",TRUE]
		This:SetCheckBox[${uniqueToon},"chkRoamHerb","chkRoamHerb@Config@InvPages@Inventory@Pages@Cerebrum",TRUE]
		This:SetCheckBox[${uniqueToon},"chkRoamMine","chkRoamMine@Config@InvPages@Inventory@Pages@Cerebrum",TRUE]
		This:SetCheckBox[${uniqueToon},"chkAttackPvP","chkAttackPvP@Config@Pages@Cerebrum"]	
		This:SetCheckBox[${uniqueToon},"chkDefendPvP","chkDefendPvP@Config@Pages@Cerebrum"]	
		This:SetCheckBox[${uniqueToon},"chkAutoEQ","chkAutoEQ@EQ@Pages@Cerebrum",TRUE]	
		This:SetCheckBox[${uniqueToon},"chkActionSlot","chkActionSlot@EQ@Pages@Cerebrum",TRUE]		
		This:SetCombo[${uniqueToon},"cmbLocTimer","cmbLocTimer@Grind@Pages@Cerebrum"]
		This:SetCombo[${uniqueToon},"cmbPullRange","cmbPullRange@Grind@Pages@Cerebrum"]
		This:SetCombo[${uniqueToon},"cmbAutoSell","cmbAutoSell@Config@InvPages@Inventory@Pages@Cerebrum"]
		This:SetCombo[${uniqueToon},"cmbAutoMule","cmbAutoMule@Config@InvPages@Inventory@Pages@Cerebrum"]
		This:SetSlider[${uniqueToon},"sldLogOutIn","sldLogOutIn@Logout@Pages@Cerebrum",240]
		This:SetSlider[${uniqueToon},"sldLogOutLevel","sldLogOutLevel@Logout@Pages@Cerebrum",70]	
		This:SetSlider[${uniqueToon},"sldMaxAdds","sldMaxAdds@Config@Pages@Cerebrum",3]
		This:SetSlider[${uniqueToon},"sldCorpseCamped","sldCorpseCamped@Config@Pages@Cerebrum",3]
		This:SetSlider[${uniqueToon},"sldDetectAddRadius","sldDetectAddRadius@Config@Pages@Cerebrum",20]			
		This:SetCombo[${uniqueToon},"leaveFreeSlots","leaveFreeSlots@Config@InvPages@Inventory@Pages@Cerebrum"]
		This:SetCheckBox[${uniqueToon},"chkUseMount","chkUseMount@Config@Pages@Cerebrum",TRUE]	
		This:SetCheckBox[${uniqueToon},"chkTakeFMToPOI","chkTakeFMToPOI@Blacklist@POIPages@POIs@Pages@Cerebrum"]		
		This:SetCheckBox[${uniqueToon},"chkTakeFMToGrind","chkTakeFMToGrind@Blacklist@POIPages@POIs@Pages@Cerebrum"]			
		This:SetCheckBox[${uniqueToon},"chkLearnFM","chkLearnFM@Blacklist@POIPages@POIs@Pages@Cerebrum",TRUE]		
		This:SetCheckBox[${uniqueToon},"chkWeaponSubTypeOnly","chkWeaponSubTypeOnly@EQ@Pages@Cerebrum"]		
		This:SetCheckBox[${uniqueToon},"chkPartyLeader","chkPartyLeader@PartyConfig@HumanPages@Human@Pages@Cerebrum"]	
		This:SetCheckBox[${uniqueToon},"chkCanTank","chkCanTank@PartyConfig@HumanPages@Human@Pages@Cerebrum"]	
		This:SetCheckBox[${uniqueToon},"chkRecordQuest","chkRecordQuest@Quest@HumanPages@Human@Pages@Cerebrum",FALSE]
		This:SetCheckBox[${uniqueToon},"chkPlayQuest","chkPlayQuest@Quest@HumanPages@Human@Pages@Cerebrum",FALSE]
		This:SetSlider[${uniqueToon},"sldPartyFollowDistance","sldPartyFollowDistance@PartyConfig@HumanPages@Human@Pages@Cerebrum",10]	
		This:SetSlider[${uniqueToon},"sldPartyNearDistance","sldPartyNearDistance@PartyConfig@HumanPages@Human@Pages@Cerebrum",30]
		This:SetSlider[${uniqueToon},"sldAssistRange","sldAssistRange@PartyConfig@HumanPages@Human@Pages@Cerebrum",100]			
	}
	
	method SaveToon()
	{
		variable string uniqueToon = "${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Name}"		
		This:SaveCheckBox[${uniqueToon},"chkGather"]	
		This:SaveCheckBox[${uniqueToon},"chkLoot"]
		This:SaveCheckBox[${uniqueToon},"chkHarvestQuests"]
		This:SaveCheckBox[${uniqueToon},"chkRoamMine"]
		This:SaveCheckBox[${uniqueToon},"chkRoamHerb"]
		This:SaveCheckBox[${uniqueToon},"chkAttackPvP"]
		This:SaveCheckBox[${uniqueToon},"chkDefendPvP"]
		This:SaveCheckBox[${uniqueToon},"chkAutoEQ"]
		This:SaveCheckBox[${uniqueToon},"chkActionSlot"]			
		This:SaveCombo[${uniqueToon},"cmbLocTimer"]
		This:SaveCombo[${uniqueToon},"cmbPullRange"]
		This:SaveCombo[${uniqueToon},"cmbAutoSell"]
		This:SaveCombo[${uniqueToon},"cmbAutoMule"]	
		This:SaveSlider[${uniqueToon},"sldLogOutIn"]
		This:SaveSlider[${uniqueToon},"sldLogOutLevel"]		
		This:SaveSlider[${uniqueToon},"sldMaxAdds"]
		This:SaveSlider[${uniqueToon},"sldCorpseCamped"]
		This:SaveSlider[${uniqueToon},"sldDetectAddRadius"]					
		This:SaveCombo[${uniqueToon},"leaveFreeSlots"]
		This:SaveCheckBox[${uniqueToon},"chkUseMount"]	
		This:SaveCheckBox[${uniqueToon},"chkTakeFMToPOI"]		
		This:SaveCheckBox[${uniqueToon},"chkTakeFMToGrind"]	
		This:SaveCheckBox[${uniqueToon},"chkLearnFM"]		
		This:SaveCheckBox[${uniqueToon},"chkWeaponSubTypeOnly"]	
		This:SaveCheckBox[${uniqueToon},"chkPartyLeader"]	
		This:SaveCheckBox[${uniqueToon},"chkCanTank"]			
		This:SaveCheckBox[${uniqueToon},"chkRecordQuest"]
		This:SaveCheckBox[${uniqueToon},"chkPlayQuest"]
		This:SaveSlider[${uniqueToon},"sldPartyFollowDistance"]
		This:SaveSlider[${uniqueToon},"sldPartyNearDistance"]		
		This:SaveSlider[${uniqueToon},"sldAssistRange"]			
	}

	/* -------- EDITBOX HANDLERS -------- */
	method SaveEditBox(string configSet, string settingName, string branch)
	{
		LavishSettings["Cerebrum"].FindSet["${configSet}"]:AddSetting["${settingName}","${UIElement["${branch}"].Text}"]
	}
	
	method LoadEditBox(string configSet, string settingName, string branch)
	{
		UIElement["${branch}"]:SetText[${LavishSettings["Cerebrum"].FindSet["${configSet}"].FindSetting["${settingName}"].String}]
	}

	
	/* -------- COMBOBOX HANDLERS -------- */
	/* on Load - note: stores guiString in a collection by settingName */
	method SetCombo(string configSet, string settingName, string guiString)
	{
		variable int i
		variable string settingText
		variable string comboText
		
		/* set saved settings */
		if ${LavishSettings["Cerebrum"].FindSet[${configSet}].FindSetting[${settingName}](exists)}
		{
			settingText:Set["${Config.GetSetting[${configSet},${settingName}]}"]
			for (i:Set[1] ; ${i} <=${UIElement[${guiString}].Items} ; i:Inc)   
			{    
				comboText:Set["${UIElement[${guiString}].Item[${i}]}"]
				if ${settingText.Equal[${comboText}]}        
				{       
					UIElement[${guiString}]:SelectItem[${i}]    
				}
			}
		}
		/* no need to set a default as this is handled in gui.xml */
		This.GUIStrings:Set[${settingName},${guiString}]
		This.Combox:Set[${settingName},"${This.GetCombo[${settingName}]}"]
	}	
	
	/* grabbing combo box info can be a pita, so this simplifies it */
	member GetCombo(string settingName)
	{
		variable string comboText = "${UIElement[${This.GUIStrings.Element[${settingName}]}].Item[${UIElement[${This.GUIStrings.Element[${settingName}]}].Selection}]}"
		return "${comboText}"
	}
	
	/* on GUI update - uses the guiString stored when slider was changed */
	method UpdateCombo(string settingName)
	{
		This:Debug[${settingName} at ${This.GUIStrings.Element[${settingName}]} is ${This.GetComboText[${settingName}]}]
		This.Combox:Set[${settingName},"${This.GetCombo[${settingName}]}"]
	}
	
	/* on Save */
	method SaveCombo(string configSet, string settingName)
	{
		This:SetSetting[${configSet},${settingName},${This.Combox.Element[${settingName}]}]
	}

	/* -------- SLIDER HANDLERS -------- */
	/* on Load - note: stores guiString in a collection by settingName */
	method SetSlider(string configSet, string settingName, string guiString, int defaultValue=0)
	{
		variable int sldvalue
		/* the set saved settings */
		if ${LavishSettings["Cerebrum"].FindSet[${configSet}].FindSetting[${settingName}](exists)}
		{
			sldvalue:Set[${Config.GetSetting[${configSet},${settingName}]}]
			if ${sldvalue} != ${UIElement[${guiString}].Value}     
			{       
				UIElement[${guiString}]:SetValue[${sldvalue}]     
			}
		}
		elseif ${defaultValue} != ${UIElement[${guiString}].Value}     
		{       
			UIElement[${guiString}]:SetValue[${defaultValue}]     
		}
		This.GUIStrings:Set[${settingName},${guiString}]
		This.Sliderx:Set[${settingName},${This.GetSlider[${settingName}]}]
	}	

	/* grabbing Slider info can be a pita, so this simplifies it */
	member GetSlider(string settingName)
	{
		variable int sldvalue = ${UIElement[${This.GUIStrings.Element[${settingName}]}].Value}
		return ${sldvalue}
	}
	
	/* on GUI update - uses the guiString stored when slider was changed */
	method UpdateSlider(string settingName)
	{
		This:Debug[${settingName} at ${This.GUIStrings.Element[${settingName}]} is ${This.GetSlider[${settingName}]}]
		This.Sliderx:Set[${settingName},${This.GetSlider[${settingName}]}]
	}
	
	/* on Save */
	method SaveSlider(string configSet, string settingName)
	{
		This:SetSetting[${configSet},${settingName},${This.Sliderx.Element[${settingName}]}]
	}
	
	/* -------- CHECKBOX HANDLERS -------- */
	/* on Load - note: stores guiString in a collection by settingName */
	method SetCheckBox(string configSet, string settingName, string guiString, bool defaultValue=FALSE)
	{
		variable bool xbox
		/* first set default values */
		if ${defaultValue}
		{
			UIElement[${guiString}]:SetChecked				
		}
		else
		{
			UIElement[${guiString}]:UnsetChecked	
		}			
		/* the set saved settings */
		if ${LavishSettings["Cerebrum"].FindSet[${configSet}].FindSetting[${settingName}](exists)}
		{
			xbox:Set[${Config.GetSetting[${configSet},${settingName}]}]
			if ${xbox}
			{
				UIElement[${guiString}]:SetChecked			
			}
			else
			{
				UIElement[${guiString}]:UnsetChecked	
			}
		}
		This.GUIStrings:Set[${settingName},${guiString}]
		This.Xboxx:Set[${settingName},${This.GetCheckbox[${settingName}]}]
	}	
	
	/* grabbing checkbox info can be a pita, so this simplifies it */
	member GetCheckbox(string settingName)
	{
		variable bool xbox = ${UIElement[${This.GUIStrings.Element[${settingName}]}].Checked}
		return ${xbox}
	}	
	
	/* grr -- i know there are two, dont touch */
	member GetCheckBox(string settingName)
	{
		return ${This.GetCheckbox[${settingName}]}
	}		
	
	/* on GUI update - uses the guiString stored when box was set */
	method UpdateCheckBox(string settingName)
	{
		This:Debug[${settingName} at ${This.GUIStrings.Element[${settingName}]} is ${This.GetCheckbox[${settingName}]}]
		This.Xboxx:Set[${settingName},${This.GetCheckbox[${settingName}]}]
	}
	
	/* on Save */
	method SaveCheckBox(string configSet, string settingName)
	{
		This:SetSetting[${configSet},${settingName},${This.Xboxx.Element[${settingName}]}]
	}
	
	/* -------- CLASS HANDLERS -------- */
	/* simplified load and save gui support for use in class routines */
	method SetClassCheckbox(string settingName, string tabName, bool defaultValue=FALSE)
	{
		variable string uniqueToon = "${Me.Name}${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Class}"	
		This:SetCheckBox[${uniqueToon},${settingName},"${settingName}@${tabName}@Pages@ClassGUI",${defaultValue}]
	}

	method SaveClassCheckbox(string settingName)
	{
		variable string uniqueToon = "${Me.Name}${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Class}"
		This:SaveCheckBox[${uniqueToon},${settingName}]		
	}

	method SetClassCombo(string settingName, string tabName)
	{
		variable string uniqueToon = "${Me.Name}${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Class}"	
		This:SetCombo[${uniqueToon},${settingName},"${settingName}@${tabName}@Pages@ClassGUI"]
	}

	method SaveClassCombo(string settingName)
	{
		variable string uniqueToon = "${Me.Name}${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Class}"
		This:SaveCombo[${uniqueToon},${settingName}]		
	}

	method SetClassSlider(string settingName, string tabName, int defaultValue=0)
	{
		variable string uniqueToon = "${Me.Name}${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Class}"	
		This:SetSlider[${uniqueToon},${settingName},"${settingName}@${tabName}@Pages@ClassGUI",${defaultValue}]
	}

	method SaveClassSlider(string settingName)
	{
		variable string uniqueToon = "${Me.Name}${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Class}"
		This:SaveSlider[${uniqueToon},${settingName}]		
	}
}
