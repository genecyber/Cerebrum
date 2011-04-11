#define REQUEST_IDLE 0
#define REQUEST_GOTREQUEST 1
#define REQUEST_WAITFORDECLINE 2

#define REQUEST_TYPE_PARTY 3
#define REQUEST_TYPE_TRADE 4
#define REQUEST_TYPE_GUILD 5
#define REQUEST_TYPE_DUEL  6

objectdef cActionPlayer inherits cBase
{
	; Registering values for stats log
	variable string SessionStartingDate = ${Time.Date} 
	variable string SessionStartingTime = ${Time.Time24}
	; - end stats log variables
	
 	variable int RequestTimer = ${LavishScript.RunningTime}
  	variable int RequestState = 0
	variable int RequestType = 3
	
	; Prevent Output Spam
	variable int LastMsgOutputTime = ${LavishScript.RunningTime}
	variable string LastMsgOutputMsg	
	
	method RequestPulse()
  	{
    		switch ${This.RequestState}
    		{
      		case REQUEST_IDLE
        			break
		      case REQUEST_GOTREQUEST
				RequestTimer:Set[${LavishScript.RunningTime}+${Math.Rand[8000]:Inc[1000]}]
			      RequestState:Set[2]
        			break
      		case REQUEST_WAITFORDECLINE
        		if ${LavishScript.RunningTime}-${RequestTimer}>0
				{
					RequestState:Set[0]
					RequestTimer:Set[${LavishScript.RunningTime}]
					switch ${RequestType}
					{
						case REQUEST_TYPE_PARTY
							;This:Output["Cancelling Party Invite"]
							wowscript DeclineGroup()
							wowscript StaticPopup1:Hide()
							break
						case REQUEST_TYPE_TRADE
							;This:Output["Cancelling Trade"]
							wowscript CancelTrade()
							;wowscript StaticPopup1:Hide()
							break
						case REQUEST_TYPE_GUILD
							;This:Output["Cancelling Guild Invite"]
							wowscript DeclineGuild()
							wowscript StaticPopup1:Hide()
							break
						case REQUEST_TYPE_DUEL
							;This:Output["Cancelling Duel"]
							wowscript CancelDuel()
							;wowscript StaticPopup1:Hide()
							break
					}
				}
       			break
    		}
  	}

	method PartyRequest(string strdata1,string strdata2,string strPlayerName)
	{
		This:ConsoleOutput["Party Invite: ${strPlayerName}", "${strPlayerName}"]
		RequestType:Set[3]
		RequestState:Set[1]
		This:PlayHumanSound["Alert"]
	}

	method TradeRequest(string strdata1,string strdata2,string strPlayerName)
	{
		This:ConsoleOutput["Trade Request: ${strPlayerName}", "${strPlayerName}"]
		RequestType:Set[4]
		RequestState:Set[1]
		This:PlayHumanSound["Alert"]
	}

	method GuildRequest(string strdata1,string strdata2,string strPlayerName, string strGuildName)
	{
		This:ConsoleOutput["Guild Invite: ${strPlayerName} from ${strGuildName}", "${strPlayerName}"]
		RequestType:Set[5]
		RequestState:Set[1]
		This:PlayHumanSound["Alert"]
	}

	method DuelRequest(string strdata1,string strdata2,string strPlayerName)
	{
		This:ConsoleOutput["Duel Request: ${strPlayerName}", "${strPlayerName}"]
		RequestType:Set[6]
		RequestState:Set[1]
		This:PlayHumanSound["Alert"]
	}

	method ChatMsgWhisper(string strdata1,string strdata2,string strMessage, string strSpeaker, string strLanguage, ... strJunk)
	{
		redirect -append "config/logs/WhisperLog.txt" echo "[${Time.Time24}][${strSpeaker}] ${strMessage}"
		This:ConsoleOutput["Whisper: [${Time.Time24}][${strSpeaker}] ${strMessage}", "${strPlayerName}"]
		;Human:NewWhisper["${strSpeaker}","${strMessage}"]		
		This:PlayHumanSound["Alert"]
	}

	method ChatMsgSay(string strdata1,string strdata2,string strMessage, string strSpeaker, string strLanguage, ... strJunk)
	{
		redirect -append "config/logs/SayLog.txt" echo "[${Time.Time24}][${strSpeaker}] ${strMessage}"
		This:ConsoleOutput["Say: [${Time.Time24}][${strSpeaker}] ${strMessage}", "${strPlayerName}"]
		;Human:NewSay["${strSpeaker}","${strMessage}"]		
		This:PlayHumanSound["Alert"]
	}
	
	method ChatMsgEmote(string strdata1,string strdata2,string strMessage, string strSpeaker, string strLanguage, ... strJunk)
	{
		redirect -append "config/logs/SayLog.txt" echo "[${Time.Time24}][${strSpeaker}] ${strMessage}"
		This:ConsoleOutput["Emote: [${Time.Time24}][${strSpeaker}] ${strMessage}", "${strPlayerName}"]
		Human:NewEmote[${strSpeaker},"${strMessage}"]
		This:PlayHumanSound["Alert"]
	}
	
	method ChatMsgTextEmote(string strdata1,string strdata2,string strMessage, string strSpeaker, string strLanguage, ... strJunk)
	{
		redirect -append "config/logs/SayLog.txt" echo "[${Time.Time24}][${strSpeaker}] ${strMessage}"
		This:ConsoleOutput["Emote: [${Time.Time24}][${strSpeaker}] ${strMessage}", "${strPlayerName}"]
		Human:NewEmote[${strSpeaker},"${strMessage}"]
		This:PlayHumanSound["Alert"]
	}
	
	method PlayHumanSound(string wav)
	{
		if ${UIElement[chkHumanSoundOn@Config@HumanPages@Human@Pages@Cerebrum].Checked}
		{
			This:PlaySound[${wav}]			
		}
	}
	
	method StatsLog()
	{
		redirect -append "${Script.CurrentDirectory}/config/logs/StatsLog.txt" echo "-------------------------------------------------"
		redirect -append "${Script.CurrentDirectory}/config/logs/StatsLog.txt" echo "  Cerebrum session for ${Me.Name} the ${Me.Race} ${Me.Class} "
		redirect -append "${Script.CurrentDirectory}/config/logs/StatsLog.txt" echo "      Session started the ${SessionStartingDate} at ${SessionStartingTime} "
		redirect -append "${Script.CurrentDirectory}/config/logs/StatsLog.txt" echo "      Finished the ${Time.Date} at ${Time.Time24} "
		redirect -append "${Script.CurrentDirectory}/config/logs/StatsLog.txt" echo "  Total running time ${Math.Calc[(${Script.RunningTime}/3600000)%60].Int.LeadingZeroes[2]} hours ${Math.Calc[(${Script.RunningTime}/60000)%60].Int.LeadingZeroes[2]} minutes and ${Math.Calc[(${Script.RunningTime}/1000)%60].Int.LeadingZeroes[2]} seconds "
		redirect -append "${Script.CurrentDirectory}/config/logs/StatsLog.txt" echo "          You killed ${Grind.KillCount} virtual monsters! "
		redirect -append "${Script.CurrentDirectory}/config/logs/StatsLog.txt" echo "              You died ${Grind.RepopCount} time(s). "
		redirect -append "${Script.CurrentDirectory}/config/logs/StatsLog.txt" echo "               Average of ${Grind.Xhr} XP/Hour     "
		redirect -append "${Script.CurrentDirectory}/config/logs/StatsLog.txt" echo "         And you gained a total of ${Grind.GainedXP} XP "
		redirect -append "${Script.CurrentDirectory}/config/logs/StatsLog.txt" echo "    You started at level ${Me.Level} and you are now ${Grind.CurrentLevel} "
		redirect -append "${Script.CurrentDirectory}/config/logs/StatsLog.txt" echo " You earned ${Grind.EarnedGold} gold(s), ${Grind.EarnedSilver} silver(s) and ${Grind.EarnedCopper} copper(s) "
		redirect -append "${Script.CurrentDirectory}/config/logs/StatsLog.txt" echo "-------------------------------------------------"
	}
	
	method ConsoleOutput(string Text, string Sender)
	{
		if ${UIElement[chkCaptureWhispers@Config@HumanPages@Human@Pages@Cerebrum].Checked} && ${Sender.NotEqual["${Me.Name}"]}
		{
			if ${Text.Equal[${This.LastMsgOutputMsg}]}
			{
				if ${Math.Calc[${LavishScript.RunningTime}-${This.LastMsgOutputTime}]} < 1000
				{
					return
				}
			}
			UIElement[Status@Whispers@HumanPages@Human@Pages@Cerebrum]:Echo["${Text}"]
			This:Debug[${Text}]
			This.LastMsgOutputTime:Set[${LavishScript.RunningTime}]
			This.LastMsgOutputMsg:Set[${Text}]
		}	
	}
		
	method Initialize()
	{
		This:Output["Object Loaded: ${This.ObjectName}"]
		/* set translate up on start */
		if ${UIElement[chkTranslate@Config@HumanPages@Human@Pages@Cerebrum].Checked}
		{
			This:Output[Translate is On]
			Translate on
		}
		else
		{
			This:Output[Translate is Off]
			Translate off
		}			
	}
	method Shutdown()
	{
		This:Output["Object Unloaded: ${This.ObjectName}"]
	}

}