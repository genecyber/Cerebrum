objectdef cBot inherits cBase
{
	variable string Version = "v2.5.1"
	variable bool PauseFlag = TRUE
	variable bool AutostartFlag = FALSE
	
	; sound spam prevention
	variable int Sound_TimeDelay = ${LavishScript.RunningTime}
	variable int Sound_Delay = 5 	/* in seconds */ 	

	variable int RandomPause = 0	
	variable int ForcedStateWait = ${LavishScript.RunningTime}

	variable int CPUCooldown = ${LavishScript.RunningTime}
	variable int CPUCooldownBase = 30
	
	variable int LagInterval = 1500
	
	variable int LvlCap = 70
	variable int SkillLvlCap= 375
	variable int GlobalCooldownBase = 750
	variable int StartBot = 0
	
	variable index:oPulse Pulse
	variable int PulseSpotlight = 0

	variable int DCCount = 0

	member GlobalCooldown()
	{
		return ${Math.Calc[${This.GlobalCooldownBase} + ${Math.Rand[${This.GlobalCooldownBase}]}]}
	}

	method UpdateGlobalCooldown()
	{
		if ${UIElement[cmbBotGlobalCooldown@Overview@Pages@Cerebrum].Selection} != 0
		{
			This.GlobalCooldownBase:Set[${Math.Calc[250 * ${UIElement[cmbBotGlobalCooldown@Overview@Pages@Cerebrum].Selection}]}]
			This.CPUCooldownBase:Set[${Math.Calc[5 * ${UIElement[cmbBotGlobalCooldown@Overview@Pages@Cerebrum].Selection}]}]			
			This.LagInterval:Set[${Math.Calc[500 * ${UIElement[cmbBotGlobalCooldown@Overview@Pages@Cerebrum].Selection}]}]			
		}
	}

	/* used to add Pulses to Nanny  by priority -- also flags for offsetting, whether should pause, whether should wait */
	/* priority means it is called 1 per X cycles of Nanny */
	/* use offset to put the actual pulse at # of cycle.  so priority 5 and offset 3 would work-- 0 NO, 1 NO, 2, NO, 3 YES, 4, NO, 0 NO, 1 NO, 2 NO, 3 YES*/
	method AddPulse(string ObjectName, string PulseName, int Priority, bool CanPause=FALSE, bool CanWait=FALSE, int Offset=0)
	{
		This.Pulse:Insert[${ObjectName},${PulseName},${Priority},${CanPause},${CanWait},${Offset}]
	}		
	
	method Initialize()
	{
		LavishSettings:AddSet[Settings]
		LavishSettings[Settings]:Clear
		LavishSettings[Settings]:Import["config/settings/${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Name}.xml"]

		/* major pulses - happen often */
		This:AddPulse["Mapper","Pulse",1]
		This:AddPulse["Navigator","Pulse",2,TRUE,TRUE,1]	
		This:AddPulse["GUI","Update",3,FALSE,FALSE]		
		This:AddPulse["Targeting","getTargets",3,TRUE,FALSE,1]		
		This:AddPulse["State","Pulse",4,TRUE,TRUE]	
		
		/* minor pulses - happen far less frequently */
		This:AddPulse["FlightPlan","Pulse",25]
		This:AddPulse["Teleport","Pulse",25]
		This:AddPulse["Quest","Pulse",25]
		This:AddPulse["Avoidance","Pulse",15,TRUE,FALSE,7]		
		This:AddPulse["Flee","Pulse",120,TRUE,FALSE,64]
		This:AddPulse["Navigator","GlobalUnstuck",25,TRUE,FALSE]		
		This:AddPulse["POI","Pulse",80,TRUE,FALSE]	
		This:AddPulse["Human.Sonar","ScanPlayers",150,TRUE,FALSE]
		This:AddPulse["ActionPlayer","RequestPulse",250,TRUE,FALSE]	
		This:AddPulse["Inventory","Pulse",500,TRUE,FALSE]			
		This:AddPulse["TalentTree","Pulse",1000,TRUE,FALSE]
		This:AddPulse["Quest","EventPulse",250,TRUE,FALSE]
	}

	method Shutdown()
	{
		${Me.Class}:ShutDown
		move -stop
		LavishSettings[Settings]:Export["config/settings/${ISXWoW.RealmName.Replace[',REMOVE,.,REMOVE]}${Me.Name}.xml"]
		
		
	}
	
	member StatusText()
	{
		return "${State.StateName[${State.CurrentState}]} ${State.StateName[${State.CurrentSubState}]}"
	}
	
	/* mapper happens 2 out of 3 cycles. targeting, navigator, poi, state and gui 1 out 3.  all else 1 every 50 */
	method Nanny()
	{	
		variable int i = 1		
		
		if ${This.RandomPause} > 0
		{
			This.ForcedStateWait:Set[${This.InTenths[${This.randomWait[${This.RandomPause}]}]}]
			This.RandomPause:Set[0]
		}
		
		This.PulseSpotlight:Inc					
		do
		{
			This.Pulse.Get[${i}]:Go[${This.PulseSpotlight}]
		}
		while ${This.Pulse.Get[${i:Inc}](exists)}		
		
		if ${This.PulseSpotlight} > 10000
		{
			This.PulseSpotlight:Set[0]
		}
		ISXWoW:ResetIdle
	}
	
	member Started()
	{
		if ${This.StartBot} > 0
		{
			return TRUE
		}
		return FALSE
	}
	
	function Startup()
	{
		This.StartBot:Set[${Time.Timestamp}]
		
		UI -load "Interface/obSkin/obSkin.xml"
		UI -load -skin obSkin "${Script.CurrentDirectory}/gui/gui.xml"
		UI -load -skin obSkin "${Script.CurrentDirectory}/routines/${Me.Class}.xml"
		
		/* load WoWRadar with obSkin*/
		UI -unload "${Script.CurrentDirectory}/Interface/obRadar.xml"
		UI -load -skin obSkin "${Script.CurrentDirectory}/Interface/obRadar.xml"
		
		This:Output["Cerebrum ${This.Version} is Loading...."]
		This:Output["Registering Events"]
		Events:Register
		This:Output["Registering Completed"]
		This:Output["Hard setting movement"]
		This:Output["Please wait... Map data is Loading...."]		

		;DONT FUCKING TAKE THESE OUT
		;DONT FUCKING TAKE THESE OUT

		GUI:Initialize
		Config:LoadSaved
		Mapper:LoadMapper
		Navigator:Initialize
		Class:Initialize
		POI:StartupObjectScan	
		Location:populateDropdown	
		Location:populateLocations
		TalentTree:Load
		Quest:Initialize
		Teleport:Initialize
		ActionSlot:AutoSlot[TRUE]
		Bot:UpdateGlobalCooldown
		Inventory:Pulse
		
		WoWScript "pcall(loadstring('function SitOrStand() SitStandOrDescendStart() end'))"		
		This:Output["Cerebrum ${This.Version} is Online. All ur bot r belong 2 us."]
	}


	function Start()
	{		
		Call Startup		
		;DONT FUCKING TAKE THESE OUT
		;DONT FUCKING TAKE THESE OUT
		do
		{
			if ${Me(exists)}
			{
				This:Nanny
				waitframe
			}
			else
			{
				if ${UIElement[chkAutoReconnect@Logout@Pages@Cerebrum].Checked}
				{
					echo Disconnected... ${Time.Date} ${Time}
					This.DCCount:Inc
					do
					{
						if !${Me(exists)}
						{
							if ${WoWScript[GlueDialog:IsVisible()]}
							{
								WoWScript GlueDialog:Hide()
								echo Hiding GlueDialog...
							}
							WoWScript DefaultServerLogin("${UIElement[AccountName@Logout@Pages@Cerebrum].Text}", "${UIElement[Password@Logout@Pages@Cerebrum].Text}")
							echo Attempt logging in... ${Time.Date} ${Time}
							wait 100
						}
					}
					while !${WoWScript[IsConnectedToServer()]}
					wait 100
					Press "${UIElement[EnterKey@Logout@Pages@Cerebrum].Text}"
					echo Entering world...
					do
					{
						wait 10
					}
					while !${Me(exists)}
				}
			}
		}
		while (1)
	}

	/* creates a random wait with a minimum rounded down to a number divisible by 5 */
	/* example: an arg of 13 would create a random number between 10 and 13 */
	member randomWait(float length)
	{
		variable float minimum = 1
		variable float waitingTime = 0	
		/* set the minimum */
		if ${length} > 5
		{
			minimum:Set[${Math.Calc[${length}/5].Round}*5]				
			if ${Math.Calc[${length} - ${minimum}]} <= 0
			{
				minimum:Dec[5]
			}
		}
		/* ensure wait is never zero */
		if ${length} < 2
		{
			length:Set[2]
		}	
		/* determine length to be random */
		length:Dec[${minimum}]		
		waitingTime:Set[${Math.Rand[${length}]}]
		waitingTime:Inc[${minimum}]	
		/* return wait time */
		return ${waitingTime}
	}
}


/* this drives pulse by priority -- see AddPulse[] and Nanny for usage*/
objectdef oPulse
{
	variable string ObjectName
	variable string PulseName
	variable int Priority
	variable int Offset
	variable bool CanWait
	variable bool CanPause
	
	method Initialize(string myObjectName, string myPulse, int myPriority, bool myCanPause, bool myCanWait, int myOffset)
	{
		This.ObjectName:Set[${myObjectName}]
		This.PulseName:Set[${myPulse}]
		This.Priority:Set[${myPriority}]
		This.CanWait:Set[${myCanWait}]
		This.CanPause:Set[${myCanPause}]		
		This.Offset:Set[${myOffset}]			
	}
	
	method Go(int counter)
	{
		if ${Math.Calc[${counter}%${This.Priority}]} == ${This.Offset}
		{
			if (${This.CanPause} && ${Bot.PauseFlag}) || (${This.CanWait} && ${Bot.ForcedStateWait} > ${LavishScript.RunningTime})
			{
				return
			}
			${This.ObjectName}:${This.PulseName}
		}
	}
	
}