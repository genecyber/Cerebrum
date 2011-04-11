objectdef cBlacklist inherits cBase
{
	method Initialize()
	{
		LavishSettings:AddSet[Blacklist]
		LavishSettings[Blacklist]:Import["config/blacklist.xml"]
		LavishSettings[Blacklist]:AddSet[IDs]
		LavishSettings[Blacklist]:AddSet[TempIDs]
		This:Clear
	}

	method Shutdown()
	{
		LavishSettings[Blacklist].FindSet[TempIDs]:Remove
		LavishSettings[Blacklist]:Export["config/blacklist.xml"]
	}
 	  
	method Insert(string ID, int Timeout)
	{
		if ${Timeout} >= 0
		{
			LavishSettings[Blacklist].FindSet[TempIDs]:AddSetting[${ID},${Math.Calc[${LavishScript.RunningTime} + ${Timeout}]}]
		}
		else
		{
			LavishSettings[Blacklist].FindSet[IDs]:AddSetting[${ID},-1]
		}
	}

	method Remove(string ID)
	{
		LavishSettings[Blacklist].FindSet[IDs]:AddSetting[${ID},0]
		LavishSettings[Blacklist].FindSet[TempIDs]:AddSetting[${ID},0]
	}

	member Exists(string ID)
	{
		if ${LavishSettings[Blacklist].FindSet[IDs].FindSetting[${ID}](exists)}
		{
			if ${LavishSettings[Blacklist].FindSet[IDs].FindSetting[${ID}].Int} == -1
			{
				return TRUE
			}
		}
		if ${LavishSettings[Blacklist].FindSet[TempIDs].FindSetting[${ID}](exists)}
		{
			if ${LavishScript.RunningTime} < ${LavishSettings[Blacklist].FindSet[TempIDs].FindSetting[${ID}].Int}
			{
				return TRUE
			}
		}
		return FALSE
	}
	
}
