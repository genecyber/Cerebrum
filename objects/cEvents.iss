objectdef cEvents inherits cBase
{
	; Register and Atomize needed events here
	method Register()
	{
			; Register specific Events
			LavishScript:RegisterEvent[PARTY_INVITE_REQUEST]
			LavishScript:RegisterEvent[TRADE_REQUEST]
			LavishScript:RegisterEvent[GUILD_INVITE_REQUEST]
			LavishScript:RegisterEvent[DUEL_REQUESTED]
			LavishScript:RegisterEvent[BAG_UPDATE]
			LavishScript:RegisterEvent[LOOT_BIND_CONFIRM]
			LavishScript:RegisterEvent[PLAYER_XP_UPDATE]
			LavishScript:RegisterEvent[CHAT_MSG_WHISPER]
			LavishScript:RegisterEvent[CHAT_MSG_SAY]
			LavishScript:RegisterEvent[CHAT_MSG_EMOTE]
			LavishScript:RegisterEvent[CHAT_MSG_TEXT_EMOTE]
			LavishScript:RegisterEvent[WoW:Object Added]
			LavishScript:RegisterEvent[PLAYER_MONEY]
			LavishScript:RegisterEvent[CHAT_MSG_COMBAT_HOSTILE_DEATH]
			LavishScript:RegisterEvent[UNIT_COMBAT]
		
			LavishScript:RegisterEvent[GUI_BUTTON_HANDLE]
			LavishScript:RegisterEvent[CLASS_GUI_CHANGE]
			LavishScript:RegisterEvent[CLASS_SLIDE_CHANGE]
			LavishScript:RegisterEvent[Cerebrum_CONFIG_XBOX]			
			LavishScript:RegisterEvent[Cerebrum_CONFIG_SLIDER]
			LavishScript:RegisterEvent[Cerebrum_CONFIG_COMBO]			
			LavishScript:RegisterEvent[AUTOEQUIP_GUI_SLIDER]	
		
			LavishScript:RegisterEvent[AUTOEQUIP_BIND_CONFIRM]
			LavishScript:RegisterEvent[BIND_ENCHANT]
		
			LavishScript:RegisterEvent[QUEST_DETAIL]
			LavishScript:RegisterEvent[QUEST_COMPLETE]
			LavishScript:RegisterEvent[QUEST_PROGRESS]			
			LavishScript:RegisterEvent[QUEST_LOG_UPDATE]
			LavishScript:RegisterEvent[UI_INFO_MESSAGE]

			LavishScript:RegisterEvent[TRAINER_CLOSED]			
			LavishScript:RegisterEvent[UI_ERROR_MESSAGE]

			LavishScript:RegisterEvent[TAXIMAP_OPENED]

			; Atomize specific Events
			Event[PARTY_INVITE_REQUEST]:AttachAtom[ActionPlayer:PartyRequest]
			Event[TRADE_REQUEST]:AttachAtom[ActionPlayer:TradeRequest]
			Event[GUILD_INVITE_REQUEST]:AttachAtom[ActionPlayer:GuildRequest]
			Event[DUEL_REQUESTED]:AttachAtom[ActionPlayer:DuelRequest]
			Event[CHAT_MSG_WHISPER]:AttachAtom[ActionPlayer:ChatMsgWhisper]
			Event[CHAT_MSG_SAY]:AttachAtom[ActionPlayer:ChatMsgSay]
			Event[CHAT_MSG_EMOTE]:AttachAtom[ActionPlayer:ChatMsgEmote]
			Event[CHAT_MSG_TEXT_EMOTE]:AttachAtom[ActionPlayer:ChatMsgTextEmote]
			Event[BAG_UPDATE]:AttachAtom[Inventory:BagUpdate]
			Event[UNIT_COMBAT]:AttachAtom[Events:CombatEvent]			

			/* added a checkbox handler for global and local settings */
			Event[GUI_BUTTON_HANDLE]:AttachAtom[GUI:HandleButton]
			Event[CLASS_GUI_CHANGE]:AttachAtom[Class:ClassGUIChange]
			Event[ClASS_SLIDE_CHANGE]:AttachAtom[Class:SliderChange]
			Event[Cerebrum_CONFIG_XBOX]:AttachAtom[Config:UpdateCheckBox]
			Event[Cerebrum_CONFIG_SLIDER]:AttachAtom[Config:UpdateSlider]
			Event[Cerebrum_CONFIG_COMBO]:AttachAtom[Config:UpdateCombo]			
			Event[AUTOEQUIP_GUI_SLIDER]:AttachAtom[Autoequip:SetModifier]

			Event[UI_ERROR_MESSAGE]:AttachAtom[Events:UIErrorMessage]
			Event[LOOT_BIND_CONFIRM]:AttachAtom[POI:LootBindConfirm]
			Event[PLAYER_XP_UPDATE]:AttachAtom[Grind:UpdateXP]
			
			Event[WoW:Object Added]:AttachAtom[POI:ObjectAdded]
			Event[WoW:Object Removed]:AttachAtom[POI:ObjectRemoved]
			
			Event[PLAYER_MONEY]:AttachAtom[Grind:MoneyMaker]
			Event[CHAT_MSG_COMBAT_HOSTILE_DEATH]:AttachAtom[Grind:KillCount]

			Event[QUEST_DETAIL]:AttachAtom[Questgiver:AcceptQuest]
			Event[QUEST_COMPLETE]:AttachAtom[Questgiver:FindReward]
			Event[QUEST_PROGRESS]:AttachAtom[Questgiver:CompleteQuest]
			Event[QUEST_LOG_UPDATE]:AttachAtom[Questgiver:LogUpdate]

			Event[AUTOEQUIP_BIND_CONFIRM]:AttachAtom[Autoequip:BindAutoEquip]
			Event[BIND_ENCHANT]:AttachAtom[Autoequip:BindAutoEquip]

			Event[TRAINER_CLOSED]:AttachAtom[ActionSlot:AutoSlot]
			
			Event[TAXIMAP_OPENED]:AttachAtom[FlightPlan:OnTaxiMap]			
	}
	
	method Shutdown()
	{
	}
	
	;This is a event handler method to react on UI Error Messages
	;It gets called if a UI Error Messages event is raised
	method UIErrorMessage(string Id, string IdText, string Msg)
	{
		if ${Class.needUIHook}
		{
			Class:UIErrorMessage[${Id}, ${Msg}]
		}
		
		;SAFETY NET: Check for any error msg that we require anything we do not have then blacklist the POI for an hour
		;This could be Herbalism to low, missing skill to harvest, missing quest to harvest, and so on
		if ${Msg.Upper.Find["REQUIRES"](exists)}
		{
			GlobalBlacklist:Insert[${POI.GUID},3600000]
			This:Output[SAFETY NET: Blacklisting ${POI.Name} for an Hour,]
			This:Output[because we are missing something to interact with it.]
			This:Output[Err Msg: ${Msg}]
			POI:Clear
		}
		
		if ${Msg.Equal[${OBDB.UIErrMsgTranslate[ERR_MOUNTED]}]}
		{
			Mount:Dismount
		}
		if ${Msg.Equal[${OBDB.UIErrMsgTranslate[ERR_CANTMOUNTHERE]}]}
		{
			;Todo set Timeout for next Mount try to something higher than just 5 seconds
			Mount.UIMountingError:Set[${This.InSeconds[15]}]	
		}

		if ${Msg.Equal[${OBDB.UIErrMsgTranslate[ERR_TAXINOPATHS]}]}
		{
			FlightPlan.NeedRefresh:Set[FALSE]
			FlightPlan.LearnFlightMaster:Set[FALSE]
			FlightPlan.LearnFM:Set["0:0:0:0:0:0:0:0"]				
		}
		
		if ${Msg.Equal[${OBDB.UIErrMsgTranslate[ERR_LOOT_TOO_FAR]}]}
		{
			GlobalBlacklist:Insert[${POI.GUID},10000]
		}
		if ${Msg.Equal[${OBDB.UIErrMsgTranslate[ERR_LOOT_TOO_FAR]}]}
		{
			GlobalBlacklist:Insert[${POI.GUID},10000]
		}
		if ${Msg.Equal[${OBDB.UIErrMsgTranslate[ERR_USE_LOCKED_WITH_ITEM_S]}]}
		{
			GlobalBlacklist:Insert[${POI.GUID},3600000]
		}

		; Check for a skinning rejection, assume the current object
		; is the one being rejected and blacklist it
		if ${Msg.Find[${OBDB.UIErrMsgTranslate[ERR_SKINNING_TOO_LOW]}]}
		{
			GlobalBlacklist:Insert[${POI.GUID},3600000]
		}
	}

	/* this returns info on combat events */
	/* do not remove -- used for Evade checking and available for routines to use (dodge, parry, crit, and so forth)*/
	method CombatEvent(string Id, string IdText, string unitID, string unitAction, string isCrit, string amtDamage, string damageType)
	{
		if ${Class.needCombatHook}
		{
			Class:CombatEvent[${unitID},${unitAction},${isCrit},${amtDamage},${damageType}]
		}
		if ${unitID.Equal["target"]} && ${unitAction.Equal["evade"]}		
		{
			This:Output[EVADE detected mob GUID: ${Target.GUID}]
			if ${Toon.BestTarget.Equal[NULL]}
			{
				Toon:Flee
			}
			POI:Clear
			Toon.EvadeBugged:Set[${Target.GUID},${LavishScript.RunningTime}]
		}
	}
}
