objectdef cHuman inherits cBase
{
	; Set Base Vars
	variable int ActionDelay = ${LavishScript.RunningTime}	
	variable bool NeedAction = FALSE
	variable bool NeedEmote = FALSE
	variable bool NeedWhisper = FALSE
	variable bool NeedSay = FALSE	
	variable bool LogoutOnFollow = FALSE
	variable bool StopOnFollow = FALSE
	variable bool EmoteOnFollow = FALSE
	variable bool NewLocOnFollow = FALSE
	variable bool TargetFollower = FALSE
	variable string TargetFollowerName
	
	/* used for trips to NPC and such */
	variable int StopOnFollow_Override = ${LavishScript.RunningTime}
	
	variable oSonar Sonar 
	
	variable string WhisperSender
	variable string WhisperMsg

	variable string SaySender
	variable string SayMsg
	
	variable string EmoteSender
	variable string EmoteMsg	
	variable collection:string EmoteReply
	variable int LastEmoteOutputTime = ${LavishScript.RunningTime}
	variable string LastEmoteOutputMsg

	method Initialize()
	{
		This:LoadEmotes
	}

	method Pulse()
	{
		if ${This.LogoutOnFollow} && ${Config.GetCheckbox[chkFollowLogout]}
		{
			/* needs to be integrated with p4e logout stuff */
			logout
			endscript Cerebrum
			return
		}
		if ${This.StopOnFollow} && ${Config.GetCheckbox[chkStopOnFollow]} && ${This.StopOnFollow_Override} < ${LavishScript.RunningTime}
		{
			if ${Movement.Speed}
			{
				move -stop
			}
			if ${Spell[Stealth](exists)}
			{
				if !${Me.Buff[Stealth](exists)} && !${Spell[Stealth].Cooldown}
				{
					Toon:CastSpell[Stealth]
				}
			}
			elseif ${Me.Race.Equal["Night Elf"]}
			{
				if !${Me.Buff[Shadowmeld](exists)} && !${Spell[Shadowmeld].Cooldown}
				{
					Toon:CastSpell[Shadowmeld]
				}
			}
			This:Output[Follower Detected. Waiting.]
			return
		}
		if ${This.TargetFollower}
		{
			Human.TargetFollower:Set[FALSE]
			if ${Player[${This.TargetFollowerName}](exists)}
			{
				Target ${Player[${This.TargetFollowerName}].GUID}
				return
			}		
		}
		if ${This.NewLocOnFollow}
		{
			Grind:LoadBestLocationSet[TRUE]
			This.NewLocOnFollow:Set[FALSE]
			return
		}
		if ${This.EmoteOnFollow}
		{
			if !${This.NeedEmote}
			{
				This:AutoEmote[${This.EmoteSender},${EmoteMsg}]
			}
			This.EmoteOnFollow:Set[FALSE]
			return
		}
		if ${This.NeedEmote}
		{
			This:AutoEmote[${This.EmoteSender},${This.EmoteMsg}]
			This.NeedEmote:Set[FALSE]
			return
		}
		if ${This.NeedWhisper}
		{
			This:AutoWhisper[${WhisperSender},${WhisperMsg}]			
			This.NeedWhisper:Set[FALSE]
			return
		}
		if ${This.NeedSay}
		{
			This:AutoSay[${SaySender},${SayMsg}]			
			This.NeedSay:Set[FALSE]
			return
		}		
		This.NeedAction:Set[FALSE]
	}
	
	/* ------ SET BY EVENTS */
	/* events in oActionPlayer triggers these methods which sets NeedAction and specific Flag */
	method NewEmote(string Sender,string Msg)
	{
		if ${UIElement[chkAutoEmote@Config@HumanPages@Human@Pages@Cerebrum].Checked}
		{
			This.ActionDelay:Set[${LavishScript.RunningTime}+3500+${Math.Rand[2500]}]			
			This.NeedAction:Set[TRUE]
			This.NeedEmote:Set[TRUE]
			This.EmoteSender:Set[${Sender}]
			This.EmoteMsg:Set["${Msg}"]			
		}
	}
	
	method NewWhisper(string Sender,string Msg)
	{
		;This.ActionDelay:Set[${LavishScript.RunningTime}+3500+${Math.Rand[2500]}]			
		;This.NeedAction:Set[TRUE]
		;This.NeedWhisper:Set[TRUE]	
		;This.WhisperSender:Set["${Sender}"]
		;This.WhisperMsg:Set["${Msg}"]			
	}
	
	method NewSay(string Sender,string Msg)
	{
		;This.ActionDelay:Set[${LavishScript.RunningTime}+3500+${Math.Rand[2500]}]			
		;This.NeedAction:Set[TRUE]
		;This.NeedSay:Set[TRUE]
		;This.SaySender:Set["${Sender}"]
		;This.SayMsg:Set["${Msg}"]			
	}
	
	/* ------ TRIGGERED BY OB_ACT_HUMAN STATE */
	/* here are the auto replays that get called in pulse */
	method AutoWhisper(string Sender,string Msg)
	{
		;This.Debug["${Sender}: ${Msg}"]
	}
	
	method AutoSay(string Sender,string Msg)
	{
		;This.Debug["${Sender}: ${Msg}"]
	}	
	
	method AutoEmote(string Sender,string EmoteUsed)
	{
		variable string ThisEmoteReply
		
		if ${EmoteUsed.Equal[${This.LastEmoteOutputMsg}]}
		{
			if ${Math.Calc[${LavishScript.RunningTime}-${This.LastEmoteOutputTime}]} < 1000
			{
				return
			}
		}
		
		/* checkbox is used in NewEmote, no need for combat check since always happens after OB_COMBAT */
		if ${Sender.NotEqual["${Me.Name}"]}
		{
		
			if !${GlobalBlacklist[${Sender}]} 
			{
				ThisEmoteReply:Set[${This.FindEmote["${EmoteUsed}"]}]
				if ${ThisEmoteReply.NotEqual["NULL"]}
				{
					bot.randompause:Set[59]
					WowScript DoEmote("${ThisEmoteReply}","${Sender}")
				}
				else
				{
					bot.randompause:Set[59]
					WowScript DoEmote("WAVE")	
				}
				
				/* Need to blacklist sender for mins set in gui */			
				GlobalBlacklist:Insert["${Sender}",${Math.Calc[${Config.GetSlider[sldEmoteTimer]}*60000]}]
				
				This.LastEmoteOutputTime:Set[${LavishScript.RunningTime}]
				This.LastEmoteOutputMsg:Set["${EmoteUsed}"]
			}	
		}
	}

	/* Auto Emote Functions */	
	member FindEmote(string EmoteToFind)
	{ 
		echo "Looking for match to ${EmoteToFind}"
		if ${This.EmoteReply.FirstKey(exists)}
		{
  	 	do
  		{
    		if ${EmoteToFind.Find[${This.EmoteReply.CurrentKey}]}
    		{
    			echo "Found match! ${This.EmoteReply.CurrentValue} "
				return "${This.EmoteReply.CurrentValue}"
			}
  		}
  		while ${This.EmoteReply.NextKey(exists)}
		}
		return NONE
	}
	
	method LoadEmotes()
	{		
		; Populate Emote List and assign Reply Emotes
		This.EmoteReply:Set["smiles at you",Wink]
		This.EmoteReply:Set["rude gesture",Moon]
		This.EmoteReply:Set["cheers at you",Roar]
		This.EmoteReply:Set["laughs at you",Smile]	
		This.EmoteReply:Set["spits at you",Rude]
		This.EmoteReply:Set["bonks you on the head",Growl]
		This.EmoteReply:Set["bites you",Threaten]
		This.EmoteReply:Set["waves at you",wave]
		This.EmoteReply:Set["tickles you",Giggle]
		This.EmoteReply:Set["bored",Shrug]
		This.EmoteReply:Set["cheers",Roar]
		This.EmoteReply:Set["cries on your shoulder",Comfort]
		This.EmoteReply:Set["cuddles you",Wink]
		This.EmoteReply:Set["dances with you",Dance]
		This.EmoteReply:Set["drink",Cheer]
		This.EmoteReply:Set["and farts",Snub]
		This.EmoteReply:Set["flex",Crack]
		This.EmoteReply:Set["giggles",Smile]
		This.EmoteReply:Set["laugh",Smile]
		This.EmoteReply:Set["lick",Moan]
		This.EmoteReply:Set["loves",Moan]
		This.EmoteReply:Set["moo",Soothe]
		This.EmoteReply:Set["nods",Agree]
		This.EmoteReply:Set["pats you",Smile]
		This.EmoteReply:Set["point",Blink]
		This.EmoteReply:Set["poke",Giggle]
		This.EmoteReply:Set["rude",Frown]
		This.EmoteReply:Set["sexy",Nosepick]
		This.EmoteReply:Set["slaps you",Growl]
		This.EmoteReply:Set["tap",Slap]
		This.EmoteReply:Set["bites you",Threaten]
		This.EmoteReply:Set["waves at you",wave]
		This.EmoteReply:Set["spits at you",Rude]
		This.EmoteReply:Set["bonks you on the head",Growl]
		This.EmoteReply:Set["bites you",Threaten]
		This.EmoteReply:Set["waves at you",wave]
	}	
}


objectdef oSonar inherits cBase
{
	variable index:string Followers
	variable collection:oFollower BuddyList
	variable int NextSonarPulse = 0
	
	method Initialize()
	{
		if ${Me.FactionGroup.Equal[Alliance]}
		{
			This.OppositeFaction:Set["Horde"]
		}
		if ${Me.FactionGroup.Equal[Horde]}
		{
			This.OppositeFaction:Set["Alliance"]
		}
	}
	
	method ScanPlayers()
	{
		if ${Config.GetCheckbox[chkActiveSonar]} && ${LavishScript.RunningTime} > ${This.NextSonarPulse}
		{	
			This:ClearFollowers
			This.NextSonarPulse:Set[${This.InSeconds[${Config.GetSlider[sldFollowAlertInterval]}]}]
			if ${This.BeingFollowed}
			{
				Human.NeedAction:Set[TRUE]
				This:BuddySystem
				return
			}
			Human.StopOnFollow:Set[FALSE]
			Human.LogoutOnFollow:Set[FALSE]
		}
	}

	method BuddySystem()
	{
		variable int i = 1
                if "${This.Followers.Get[${i}](exists)}"
                {
                        do
                        {
                                This:CheckBuddy[${This.Followers.Get[${i}]}]
                        }
                        while "${This.Followers.Get[${i:Inc}](exists)}"
                }			
	}	

	method CheckBuddy(string BuddyName)
	{
		if ${Config.GetCheckbox[chkFollowLogout]} && ${This.BuddyList.Element[${BuddyName}].Count} >= ${Config.GetSlider[sldMaxFollows]}
		{
			Human.LogoutOnFollow:Set[TRUE]
		}
		if ${Config.GetCheckbox[chkStopOnFollow]}
		{
			Human.StopOnFollow:Set[TRUE]
		}
		if ${Config.GetCheckbox[chkBeepOnFollow]}
		{
			This:PlaySound["Notify"]
		}	
		if ${Config.GetCheckbox[chkEmoteOnFollow]} && !${Human.NeedEmote} && ${This.StopOnFollow_Override} < ${LavishScript.RunningTime}
		{
			Human.EmoteMsg:Set["waves at you"]
			Human.EmoteSender:Set[${BuddyName}]
			Human.EmoteOnFollow:Set[TRUE]
		}
		if ${Config.GetCheckbox[chkNewLocOnFollow]}
		{
			Human.NewLocOnFollow:Set[TRUE]
		}	
		if ${Config.GetCheckbox[chkTargetFollower]} && ${Player[${BuddyName}].Distance} < 30
		{
			Human.TargetFollower:Set[TRUE]
			Human.TargetFollowerName:Set[${BuddyName}]
		}		
	}
	
	/* performs a follower search */
	member BeingFollowed()
	{
		variable int i = 1
		variable bool FollowCheck = FALSE
		variable guidlist HumanPlayers

		if ${Config.GetCheckbox[chkTrackFaction]} || ${Config.GetCheckbox[chkTrackOppositeFaction]}
		{
			HumanPlayers:Search[-players, -nearest, -noself, -nopets, -alive, -range 0-${Config.GetSlider[sldFollowRadius]}]
			if ${HumanPlayers.Count}>0
			{
				do
				{
					if ${Player[${HumanPlayers.Object[${i}]}].FactionGroup.Equal[${Me.FactionGroup}]} && ${Config.GetCheckbox[chkTrackFaction]}
					{
						if ${This.IsFollower[${HumanPlayers.Object[${i}].GUID}]}
						{
							FollowCheck:Set[TRUE]
						}
					}
					if ${Player[${HumanPlayers.Object[${i}]}].FactionGroup.Equal[${This.OppositeFaction}]} && ${Config.GetCheckbox[chkTrackOppositeFaction]}
					{
						if ${This.IsFollower[${HumanPlayers.Object[${i}].GUID}]}
						{
							FollowCheck:Set[TRUE]
						}
					}				
				}
				while ${Player[${HumanPlayers.Object[${i:Inc}]}](exists)}
			}
		}
		return ${FollowCheck}
	}

	member IsFollower(string theGUID)
	{
		variable string FollowerName = ${Player[${theGUID}].Name}
		if ${This.BuddyList.Element[${FollowerName}](exists)}
		{
			This:Debug["A follower was seen again!"]
			This.BuddyList.Element[${FollowerName}]:Update
			if ${This.BuddyList.Element[${FollowerName}].IsFollowing}
			{
				This.Followers:Insert[${FollowerName}]
				return TRUE
			}		
		}
		This:Debug["A follower was found!"]
		This.BuddyList:Set[${FollowerName},${theGUID}]
		return FALSE
	}
	
	method ClearFollowers()
	{
		variable int i = 1
		This.Followers:Collapse
                if "${This.Followers.Get[${i}](exists)}"
                {
                        do
                        {
                                This.Followers:Remove[${i}]
                        }
                        while "${This.Followers.Get[${i:Inc}](exists)}"
                        This.Followers:Collapse
                }		
	}	
}

objectdef oFollower inherits cBase
{
	variable string Name
	variable string Faction	
	variable bool IsFollowing = TRUE
	variable int FirstSeen = ${LavishScript.RunningTime}
	variable int LastSeen = ${LavishScript.RunningTime}
	variable int TimeFollowed = 0
	variable int Count = 0
	
	method Initialize(string theGUID)
	{
		This.Name:Set[${Player[${theGUID}].Name}]
		This.Faction:Set[${Player[${This.GUID}].FactionGroup}]
		This.FirstSeen:Set[${LavishScript.RunningTime}]	
		This.LastSeen:Set[${LavishScript.RunningTime}]
		This.Count:Set[0]
		This.TimeFollowed:Set[0]		
		This.IsFollowing:Set[FALSE]	
	}
	
	method Update()
	{
		if ${Math.Calc[${LavishScript.RunningTime}-${This.LastSeen}]} < ${Math.Calc[(${Config.GetSlider[sldFollowAlertInterval]}*1000)+2000]}
		{
			This.Count:Inc
			This.TimeFollowed:Inc[${Math.Calc[(${LavishScript.RunningTime}-${This.LastSeen})/1000]}]					
			This.LastSeen:Set[${LavishScript.RunningTime}]
			This.IsFollowing:Set[TRUE]
			This:Output["${This.Name} has followed me for ${This.TimeFollowed} seconds"]
			return
		}
		if ${Math.Calc[${LavishScript.RunningTime}-${This.FirstSeen}]} > ${Math.Calc[(${Config.GetSlider[sldLongIntervalReset]}*1000)]}
		{
			This.Count:Set[0]
			This.TimeFollowed:Set[0]				
			This.FirstSeen:Set[${LavishScript.RunningTime}]	
			This.LastSeen:Set[${LavishScript.RunningTime}]
			This.IsFollowing:Set[FALSE]	
			return
		}
		This.LastSeen:Set[${LavishScript.RunningTime}]		
		This.IsFollowing:Set[FALSE]		
	}	
}