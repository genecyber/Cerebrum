objectdef cMapEditor
{
	variable index:lnavregionref Regions
	variable int r = 10
	variable point3f lastCenter = 0,0,0
	
	variable string clicked = ""
	variable set highlighted

	method Rend()
	{	
		variable lnavregionref R
		variable int i
		for(i:Set[1];${i} <= 5;i:Inc)
		{
			if ${Regions.Used} == 0
			{
				return
			}
			R:SetRegion[${Regions.Get[1].FQN}]
			UIElement[rend@MapGUI]:AddBlip[${R.Name},${R.CenterPoint.X},${Math.Calc[-1*${R.CenterPoint.Y}]},${R.CenterPoint.Z},2,${R.Name},"mapped_blip",""]
			Regions:Remove[1]
			Regions:Collapse
		}		
	}
	method MapRend()
	{
		if !${UIElement["MapGUI"].Visible}
		{
			return
		}
		if ${This.NextItteration}
		{
			This:Recycle
			This:Rend
		}
		elseif ${Regions.Used} > 0
		{
			This:Rend
		}
		UIElement[rend@MapGUI]:SetFadeAlpha[100]
		UIElement[rend@MapGUI]:SetMapSize[${r},${r}]
		UIElement[rend@MapGUI]:SetOrigin[${Me.X},${Math.Calc[-1*${Me.Y}]},${Me.Z}]
		UIElement[rend@MapGUI]:SetRotation[${Me.Heading}]
		UIElement[rend@MapGUI]:AddBlip[${Me.Name},${Me.X},${Math.Calc[-1*${Me.Y}]},${Me.Z},4,${Me.Name},"me_blip",""]
	}
	member NextItteration()
	{
		if ${lastCenter.Distance[${Me.Location}]} >= ${Math.Calc[${r}/2]}
		{
			return TRUE
		}
		return FALSE
	}
	method Recycle()
	{
		Regions:Clear
		if ${Mapper.CurrentZone.DescendantsWithin[Regions,${Math.Calc[${r}*1.5]},${Me.Location}]}
		{
		}
		lastCenter:Set[${Me.Location}]
	}
	method RightClick()
	{
		variable int X = ${Mouse.X}
		variable int Y = ${Mouse.Y}
		variable string theBlip = ${This.ClosestBlip[${X},${Y},25]}

		if ${theBlip.NotEqual[""]}
		{	
			This:RemoveRegion[${theBlip}]
			UIElement[rend@MapGUI].Blip[${theBlip}]:Remove
		}
	}
	
	
	method RemoveRegion(string RegionName)
	{
		variable index:lnavregionref SurroundingRegions
		variable lnavregionref CurrentRegion
		variable int RegionsFound
		variable int Index = 1

		
		CurrentRegion:SetRegion[${RegionName}]
		RegionsFound:Set[${Mapper.CurrentZone.ChildrenWithin[SurroundingRegions,11,${CurrentRegion.CenterPoint.X},${CurrentRegion.CenterPoint.Y},${CurrentRegion.CenterPoint.Z}]}]
		
		if ${RegionsFound} > 0
		{
			do
			{
				SurroundingRegions.Get[${Index}].GetConnection[${RegionName}]:Remove
			}
			while ${SurroundingRegions.Get[${Index:Inc}](exists)}
		}
		CurrentRegion:Remove
	}
	
	method LeftClick()
	{
		variable int X = ${Mouse.X}
		variable int Y = ${Mouse.Y}
		variable string theBlip = ${This.ClosestBlip[${X},${Y},25]}
		if ${clicked.NotEqual[""]}
		{
			This:DeHighLight[${clicked}]
			This:DeHighLightConnected[${clicked}]
		}
		if ${theBlip.NotEqual[""]}
		{	
			clicked:Set[${theBlip}]
			This:HighLight[${clicked}]
			This:HighLightConnected[${clicked}]
		}
	}
	method HighLight(string theBlip,string theColor = "")
	{
		if ${theColor.NotEqual[""]}
		{
			UIElement[rend@MapGUI].Blip[${theBlip}]:SetBorderColor[${theColor}]
		}
		UIElement[rend@MapGUI].Blip[${theBlip}]:SetBorder[3]
	}
	method DeHighLight(string theBlip)
	{
		UIElement[rend@MapGUI].Blip[${theBlip}]:SetBorder[0]
	}
	method HighLightConnected(string theBlip)
	{
		variable iterator iter
		
		LNavRegion[${theBlip}]:GetConnectionIterator[iter]
		iter:First
		
		while ${iter.IsValid}
		{
			if ${iter.Value.Source.Name.Equal[${theBlip}]}
			{
				This:HighLight[${iter.Value.Destination.Name},FFFF0000]
				highlighted:Add[${iter.Value.Destination.Name}]
			}
			iter:Next
		}
	}
	method DeHighLightConnected()
	{
		variable iterator iter
		
		highlighted:GetIterator[iter]
		iter:First
		
		while ${iter.IsValid}
		{
			This:DeHighLight[${iter.Value}]
			iter:Next
		}
		highlighted:Clear
	}
	
	
	member ClosestBlip(int X,int Y,int tolerance = 99999)
	{
		variable string closestBlip 
		variable string current = ${UIElement[rend@MapGUI].Blip}
		variable float distance = 99999
		while ${UIElement[rend@MapGUI].Blip[${current}](exists)}
		{
			if ${Math.Distance[${UIElement[rend@MapGUI].Blip[${current}].AbsoluteX},${UIElement[rend@MapGUI].Blip[${current}].AbsoluteY},${X},${Y}]} < ${distance}
			{
				distance:Set[${Math.Distance[${UIElement[rend@MapGUI].Blip[${current}].AbsoluteX},${UIElement[rend@MapGUI].Blip[${current}].AbsoluteY},${X},${Y}]}]
				closestBlip:Set[${current}]
			}
			current:Set[${UIElement[rend@MapGUI].NextBlip[${current}]}]
		}
		
		if ${distance} <= ${tolerance}
		{
			return ${closestBlip}
		}
		return ""
	}

}