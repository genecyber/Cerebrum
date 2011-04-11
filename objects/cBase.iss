objectdef cBase
{
	variable string Cerebrum_Status = "Initializing"	
	
	/* added for spam prevention to output */
	variable int LastOutputTime = ${LavishScript.RunningTime}
	variable string LastOutputMsg
	
	; Sounds
	
	variable string AlertSound		= "SndAlert"
	variable string BlipSound		= "SndBlip"
	variable string NotifySound		= "SndNotify"
	variable string InformSound		= "SndInform"
	variable string StopSound		= "SndStop"
	
	variable string SndBlip 		= ${String["${Script.CurrentDirectory}/Interface/obSounds/blip.wav"].Replace['/','\\']}
	variable string SndNotify 		= ${String["${Script.CurrentDirectory}/Interface/obSounds/notify.wav"].Replace['/','\\']}
	variable string SndAlert 		= ${String["${Script.CurrentDirectory}/Interface/obSounds/alert.wav"].Replace['/','\\']}
	variable string SndInform 		= ${String["${Script.CurrentDirectory}/Interface/obSounds/inform.wav"].Replace['/','\\']}
	variable string SndStop 		= ${String["${Script.CurrentDirectory}/Interface/obSounds/stop.wav"].Replace['/','\\']}
	
	method Output(string Text)
	{
		if ${Text.Equal[${This.LastOutputMsg}]}
		{
			if ${Math.Calc[${LavishScript.RunningTime}-${This.LastOutputTime}]} < 1000
			{
				return
			}
		}
		UIElement[Cerebrum].FindChild[Console]:Echo["${Time.Time24}: ${Text}"]
		This:Debug[${Text}]
		if ${UIElement[chkLogOutput@Config@Pages@Cerebrum].Checked}
		{
			redirect -append "${Script.CurrentDirectory}/config/logs/OutputLog.txt" Echo "[${Time.Time24}] ${Text}"
		}
		This.LastOutputTime:Set[${LavishScript.RunningTime}]
		This.LastOutputMsg:Set[${Text}]	
	}
	
	method Debug(string Text)
	{
		if ${UIElement[chkDebug@Config@Pages@Cerebrum].Checked}
		{
			echo "[${Time.Time24}][${This.Objectname}] ${Text}"
			redirect -append "config/logs/DebugLog.txt" echo "[${Time.Time24}][${This.Objectname}] ${Text}"
		}
	}
	
	method Update_Status(string STATUS)
	{
		if !${STATUS.Equal[${This.Cerebrum_Status}]}
		{
			This.Cerebrum_Status:Set[${STATUS}]
		}
	}
;Method for debug when GUI console is created	

	member MathMin(int a, int b)
	{
		if ${a} < ${b}
		{
			return ${a}
		}
		return ${b}
	}

	member MathMax(int a, int b)
	{
		if ${a} > ${b}
		{
			return ${a}
		}
		return ${b}
	}
	
	/* return runningtime + seconds, tenths, or milliseconds */
	/* use ${This.InMilliseconds[100]} to set the the length of time to wait in milliseconds*/	
	member InMilliseconds(float waitLength)
	{
		waitLength:Set[${Math.Calc[10*${waitLength}]}]
		waitLength:Inc[${LavishScript.RunningTime}]
		return ${waitLength}
	}

	member InTenths(float waitLength)
	{
		waitLength:Set[${Math.Calc[100*${waitLength}]}]
		waitLength:Inc[${LavishScript.RunningTime}]
		return ${waitLength}
	}	
	
	member InSeconds(float waitLength)
	{
		waitLength:Set[${Math.Calc[1000*${waitLength}]}]
		waitLength:Inc[${LavishScript.RunningTime}]
		return ${waitLength}
	}		
	
	method PlaySound(string soundwav)
	{
		; Sound Files to Play
		variable string SoundToPlay
					
		if ${UIElement[chkSoundOn@Config@Pages@Cerebrum].Checked} && ${LavishScript.RunningTime} > ${Bot.Sound_TimeDelay}
		{	
			switch ${soundwav}
			{		
				case Alert
					SoundToPlay:Set[${This.AlertSound}]
					break
				case Blip
					SoundToPlay:Set[${This.BlipSound}]
					break
				case Notify
					SoundToPlay:Set[${This.NotifySound}]
					break
				case Inform
					SoundToPlay:Set[${This.InformSound}]
					break
				case Stop
					SoundToPlay:Set[${This.StopSound}]
					break
	  			Default
				  	SoundToPlay:Set[${This.AlertSound}]
					break	
			}
			Bot.Sound_TimeDelay:Set[${LavishScript.RunningTime}+(${Bot.Sound_Delay}*1000)]
			System:APICall["${System.GetProcAddress["WinMM.dll","PlaySound"].Hex}",${SoundToPlay}.String,0,"Math.Dec[22001]"]
		}	
	}
	
	member VisibleFrame(string frameName)
	{
		variable string testFrame = ${WoWScript[pcall(loadstring("return ${frameName}:IsVisible()")), 2]}
		if ${testFrame.Equal[1]}
		{
			return TRUE
		}
		return FALSE
	}	
	
	method ClearIndex(string IndexName)
	{
		variable int i = 1
		if ${This.${IndexName}.Get[${i}](exists)}
		{
			do
			{
				This.${IndexName}:Remove[${i}]	
			}
			while ${This.${IndexName}.Get[${i:Inc}](exists)}
			This.${IndexName}:Collapse	
		}
	}
}