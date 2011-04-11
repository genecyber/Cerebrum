;new mage routine for 1.07.2
;made by sm0k3d
;
;Thanks Overlook for the origional routine for me to build upon
;Thanks Neutro for the working Pots
;and thanks to many other people who has helped me put this together and make all the fixes =)
objectdef cClass inherits cBase
{
	;--- GUI Goodies ---;
 
	variable bool LoadedSettings = FALSE
 
	;--- Health Stuff ---;
 
	variable int RestHP = 70
	variable int RestMP = 65
	variable int StandHP = 97
	variable int StandMP = 97
	variable int PotHP = 20
	variable int PotMP = 15
	variable int BandHP = 40
	
	;Regular stuff
	variable int GemMana = 40
	variable int Wand = 20
	variable int IBHealth = 5
	variable string PullWith = "Fireball"
	variable string PullSecond = "Fireball"
	variable bool TwoPull = FALSE
	variable bool RandPull = FALSE
	variable string CombatCast = "Fireball"
	variable bool RandCom = FALSE
	variable bool Racial = FALSE

	;Buffs
	variable bool ArcInt = TRUE
	variable string Armor = "None"
	variable bool FWard = FALSE
	variable bool FrWard = FALSE
	variable bool Dampen = FALSE
	variable bool Amplify = FALSE
	variable bool CombatEvocation = FALSE
	variable bool RestEvocation = FALSE
	variable bool ManaShield = FALSE

	;Arcane 
	variable bool CounterSpell = FALSE
	variable bool Presence = FALSE
	variable bool POMonPull = FALSE
	variable bool Slow = FALSE
	variable bool ArcanePower = FALSE
	variable bool APonPull = FALSE
	variable bool StunBlink = FALSE

	;Fire 
	variable bool DragonBreath = FALSE
	variable bool BlastWave = FALSE
	variable bool Combustion = FALSE

	;Frost 
	variable bool FrostNova = FALSE
	variable bool ConeOfCold = FALSE
	variable bool ColdSnap = FALSE
	variable bool IceBlock = FALSE
	variable bool IceBarrier = FALSE
	variable bool WaterElemental = FALSE
	variable bool IceLance = FALSE

	;Other 
	variable string BestGem = "None"
	variable int BuffNum = 0
	variable int RandVar = 0
	variable string RandPullSpell = "None"
	variable string RandComSpell = "None"
	
	;extras
	variable guidlist NovaList
	variable guidlist AggroList
	variable guidlist BandList
	variable guidlist LinenList
	variable guidlist WoolList
	variable guidlist SilkList
	variable guidlist MageList
	variable guidlist RuneList
	variable guidlist NetherList
	variable string Bandage = "Linen Bandage"
	variable bool MakeBand = TRUE
	variable bool Pulled = FALSE
	variable int FB = 20

	;Reactive
	variable bool ArcaneImmune = FALSE
	variable bool FireImmune = FALSE
	variable bool FrostImmune = FALSE
	variable string ReactCast = "None"
	variable bool ReactFWard = FALSE
	variable bool ReactFrWard = FALSE
	
	;timers
	variable int LastCastedAt = 0
	variable int CastingTime = 0
	variable string LastSpell = "nothing yet"
	variable int LagTime = 400
	variable int detectTimer
	variable int detectTimeOut = 10000
	variable string detectGUID
	variable int NextSheeping = 0

	;aggro
	variable guidlist AggroList
	
	;timer
	variable int RootCastTime = 0
	
	;Additional aggro options
	variable bool RangePullOnDetectAdds = TRUE          	;Range pulls if hostile adds are within RADIUS yards of the attack target
	variable int RangePullOnDetectAddsRadius = 20       	;The RADIUS to check for hostile adds around your attack target.  if TRUE above, will range pull mob.

 
 
		;--- Initialize ---;
 
		method Initialize()
		{
			This:LoadConfig
			This:InitMageGUI
			call TriggerPlease
		}
		
		method Wait(string myspell,int myseconds)
		{
			if ${Math.Calc[${LavishScript.RunningTime}-${This.LastCastedAt}]}>${myseconds}
			{
				Toon:CastSpell[${myspell}]
				This.LastCastedAt:Set[${LavishScript.RunningTime}]
			}
			else
			{
				echo "${LavishScript.RunningTime} : Can't cast ${myspell}, too soon"
			}
		}
		
		method TakePot(string mypot,int mysecond)
		{
				echo "Hi, I am in TakePot method and its not working"
			if ${Math.Calc[${LavishScript.RunningTime}-${This.LastCastedAt}]}>${mysecond}
			{
				echo "the if timer is ok"
				echo "I am trying to take a ${mypot}"
				Consumable:use${mypot}()
				This.LastCastedAt:Set[${LavishScript.RunningTime}]
			}
			else
			{
				echo "${LavishScript.RunningTime} : Can't cast ${myspell}, too soon"
			}
		}
		member detectMobAdd()
		{
			if ${RangePullOnDetectAdds}
			{
				variable guidlist MobAdds
				/* perform search */
				MobAdds:Search[-nearest, -hostile, -health 100, -range 0-${RangePullOnDetectAddsRadius}, -origin,${Target.X},${Target.Y},${Target.Z}]		
				/* multiple hostiles? includes our target*/
				if ${MobAdds.Count}>1
				{
					return TRUE

				}
				/* is our target non-hostile, but hostiles are around? */
				elseif ${MobAdds.Count}>0&&${Target.ReactionLevel}!=2
				{
					return TRUE
				}
			}
			return FALSE
		}
		
		member HasSheep()
		{
			if ${LavishScript.RunningTime} < ${This.NextSheeping}
			{
				return TRUE
			}
			variable int i = 0
			while ${Targeting.TargetCollection.Get[${i:Inc}](exists)}	
			{
				if ${Unit[${Targeting.TargetCollection.Get[i]}].Buff[Polymorph](exists)}
				{
					return TRUE
				}
			}
			return FALSE
		}
		
		;--- Rest ---;
 
		member NeedRest()
		{
			if ${Me.PctHPs} < ${RestHP} || ${Me.PctMana} < ${RestMP}
			{
				return TRUE
			}
 
			if ${Me.PctHPs} < ${StandHP} && ${Me.Sitting}
			{
				return TRUE
			}
			if ${Me.PctMana} < ${StandMP} && ${Me.Sitting}
			{
				return TRUE
			}
			
			if !${Consumable.HasFood} && ${Spell[Conjure Food](exists)} && ${Inventory.GetBagsInfo[RETRIEVE_FREESLOTS,"normal"]} > 2 && !${Me.Buff[Drink](exists)} && !${Me.Buff[Food](exists)}  && !${WoWScript[MerchantFrame:IsShown()]}
			{
				return TRUE
			}
		
			if !${Consumable.HasDrink} && ${Spell[Conjure Water](exists)} && ${Inventory.GetBagsInfo[RETRIEVE_FREESLOTS,"normal"]} > 2 && !${Me.Buff[Drink](exists)} && !${Me.Buff[Food](exists)}  && !${WoWScript[MerchantFrame:IsShown()]}
			{
				return TRUE
			}
			
			if ${Me.Buff[Resurrection Sickness](exists)}
			{
				return TRUE
			}
			
			if ${This.NeedDecurse} && ${Spell[Remove Lesser Curse](exists)} && !${Me.Buff[Drink](exists)} && !${Me.Buff[Food](exists)}
			{
				return TRUE
			}

			if !${This.HasGem} && ${This.GemSpell.NotEqual["None"]} && ${Spell["${This.GemSpell}"](exists)} && ${Inventory.GetBagsInfo[RETRIEVE_FREESLOTS,"normal"]} > 0 && !${Me.Buff[Drink](exists)} && !${Me.Buff[Food](exists)}
			{
				return TRUE
			}

			if ${Consumable.HasScroll}
			{
				return TRUE
			}
			
			if ${Me.InCombat}
			{
				return FALSE
			}
			
			if ${Targeting.realAgg}
			{
				return FALSE
			}
			
			return FALSE
		}
 
		method RestPulse()
		{
			This.ReactFWard:Set[FALSE]
			BandList:Search[-items,-inventory,Bandage]
			LinenList:Search[-items,-inventory,Linen Cloth]
			WoolList:Search[-items,-inventory,Wool Cloth]
			SilkList:Search[-items,-inventory,Silk Cloth]
			MageList:Search[-items,-inventory,Mageweave Cloth]
			RuneList:Search[-items,-inventory,Runecloth]
			NetherList:Search[-items,-inventory,Netherweave Cloth]
			if ${Movement.Speed}
			{
				Move -stop
			}
			
			if ${This.MakeBand} && !${Me.Buff[First Aid](exists)} && ${BandList.Count} == 0 && (${LinenList.Count} >= 2 || ${WoolList.Count} >= 2 || ${SilkList.Count} >= 2 || ${MageList.Count} >= 2 || ${RuneList.Count} >= 2 || ${NetherList.Count} >= 2) && !${Me.Casting}
			{
				if ${Me.Sitting}
				{
					Toon:Standup
				}
				Tradeskills:MakeBandage[${This.Bandage}, 5]
				This:Output["Let's make some bandages..."]
			}
			
			if ${Me.PctHPs} >= ${StandHP} && ${Me.PctMana} >= ${StandMP} && ${Me.Sitting}
			{
				Toon:Standup
			}
			
			if ${Consumable.HasScroll[Strength]} && !${Me.Buff[Strength](exists)} && !${Me.Casting}
			{
				Consumable:UseScroll[Strength]
				This:Output["Let's use the scroll of strength"]
				return
			}
			if ${Consumable.HasScroll[Agility]} && !${Me.Buff[Agility](exists)} && !${Me.Casting}
			{
				Consumable:UseScroll[Agility]
				This:Output["Let's use the scroll of agility"]
				return
			}
			if ${Consumable.HasScroll[Stamina]} && !${Me.Buff[Stamina](exists)} && !${Me.Casting}
			{
				Consumable:UseScroll[Stamina]
				This:Output["Let's use the scroll of stamina"]
				return
			}
			if ${Consumable.HasScroll[Protection]} && !${Me.Buff[Protection](exists)} && !${Me.Casting}
			{
				Consumable:UseScroll[Protection]
				This:Output["Let's use the scroll of protection"]
				return
			}
			if ${Consumable.HasScroll[Spirit]} && !${Me.Buff[Protection](exists)} && !${Me.Casting}
			{
				Consumable:UseScroll[Spirit]
				This:Output["Let's use the scroll of Spirit"]
				return
			}
			
			if ${This.RestEvocation} && ${Spell[Evocation](exists)} && !${Spell[Evocation].Cooldown} && ${Me.PctMana} < ${This.RestMP} && !${Me.Casting}
			{
				Toon:Standup
				Toon:CastSpell[Evocation]
				This:Output["Time to get this show on the road, Casting Evocation"]
				return
			}
			
			if ${Me.PctHPs} < ${RestHP} && ${This.Racial} && ${Spell[Cannibalize](exists)} && !${Spell[Cannibalize].Cooldown} && (${Object[-dead,-humanoid,-range 0-5](exists)} || ${Object[-dead,-undead,-range 0-5](exists)}) && !${Me.Casting}
			{
				This:Output["Cannibalize"]
				Toon:CastSpell[Cannibalize]
				return
			}
			
			if ${Me.PctHPs} < ${This.BandHP} && ${Consumable.HasBandage} && !${Me.Buff[Recently Bandaged](exists)} && !${Me.Buff[First Aid](exists)} && !${Me.Casting}
			{
				Consumable:useBandage
				This:Output["Bandaging..."]
				return
			}
			
			if ${This.NeedDecurse} && !${Me.Casting}
			{
				This:DecursePulse
				This:Output["Decuring"]
				return
			}
			
			if !${Consumable.HasDrink} && ${Inventory.GetBagsInfo[RETRIEVE_FREESLOTS,"normal"]} > 2 && ${Spell[Conjure Water](exists)} && !${Me.Sitting} && ${Me.CurrentMana} > ${Spell[Conjure Water].Mana} && !${Me.InCombat} && !${Me.Casting}
			{
				Toon:CastSpell[Conjure Water]
				This:Output["Making some Water"]
				return
			}

			if !${Consumable.HasFood} && ${Inventory.GetBagsInfo[RETRIEVE_FREESLOTS,"normal"]} > 2 && ${Spell[Conjure Food](exists)} && !${Me.Sitting} && ${Me.CurrentMana} > ${Spell[Conjure Food].Mana} && !${Me.InCombat} && !${Me.Buff[Evocation](exists)} && !${Me.Casting}
			{
				Toon:CastSpell[Conjure Food]
				This:Output["Making some Food"]
				return
			}
			
			if ${Consumable.HasFood} && ${Me.PctHPs} < ${This.StandHP} && !${Me.Buff[Food](exists)} && !${Me.Swimming} && !${Me.Sitting} && !${Me.InCombat} && !${Me.Buff[Evocation](exists)} && !${Me.Casting} && !${WoWScript[MerchantFrame:IsShown()]}
			{
				Consumable:useFood
				This:Output["Let's get our health back up, Eating..."]
			}
 
			if ${Consumable.HasDrink} && ${Me.PctMana} < ${This.StandMP} && !${Me.Buff[Drink](exists)} && !${Me.Swimming} && !${Me.Sitting} && !${Me.InCombat}  && !${Me.Buff[Evocation](exists)} && !${Me.Casting}  && !${WoWScript[MerchantFrame:IsShown()]}
			{
				Consumable:useDrink
				This:Output["Let's get our mana backup, Drinking..."]
			}
			
			
			
			if !${This.HasGem} && ${Inventory.GetBagsInfo[RETRIEVE_FREESLOTS,"normal"]} > 0 && ${Spell[${This.GemSpell}](exists)} && !${Me.Sitting} && ${Me.CurrentMana} > ${Spell[${This.GemSpell}].Mana} && !${Me.Buff[Evocation](exists)} && !${Me.Casting}
			{
				Toon:CastSpell[${This.GemSpell}]
				This:Output["Making ${This.GemSpell}"]
				return
			}
		}
 
		;--- Non Combat Buffs ---;
 
		member NeedBuff()
		{
			if ${This.Armor.NotEqual["None"]} && ${Spell[${This.Armor}](exists)} && !${Me.Buff[${This.Armor}](exists)} && !${Me.Buff[Food](exists)} && !${Me.Buff[Drink](exists)}
			{
				return TRUE
			}
			
			if ${This.ArcInt} && ${Spell[Arcane Intellect](exists)} && !${Me.Buff[Arcane Intellect](exists)} && !${Me.Buff[Food](exists)} && !${Me.Buff[Drink](exists)}
			{
				return TRUE
			}
			
			if ${This.Combustion} && ${Spell[Combustion](exists)} && !${Spell[Combustion].Cooldown} && !${Me.Buff[Combustion](exists)} && !${Me.Buff[Food](exists)} && !${Me.Buff[Drink](exists)}
			{
				return TRUE
			}

			if ${This.IceBarrier} && ${Spell[Ice Barrier](exists)} && && !${Spell[Ice Barrier].Cooldown} && !${Me.Buff[Ice Barrier](exists)} && !${Me.Buff[Food](exists)} && !${Me.Buff[Drink](exists)}
			{
				return TRUE
			}
			if ${This.Dampen} && ${Spell[Dampen Magic](exists)}	&& !${Me.Buff[Dampen Magic](exists)} && !${Me.Buff[Food](exists)} && !${Me.Buff[Drink](exists)}
			{
				return TRUE
			}
		
			if ${This.Amplify} && ${Spell[Amplify Magic](exists)} && !${Me.Buff[Amplify Magic](exists)} && !${Me.Buff[Food](exists)} && !${Me.Buff[Drink](exists)}
			{
				return TRUE
			}
			
			Return FALSE
		}
		method BuffPulse()
		{
			Toon:Standup
			
			if ${This.Armor.NotEqual["None"]} && !${Me.Buff[${This.Armor}](exists)} && ${Spell[${This.Armor}](exists)} && ${Me.CurrentMana} > ${Spell[${This.Armor}].Mana}
			{
				Target ${Me.GUID}
				Toon:CastSpell[${This.Armor}]
				This:Output["Casting ${This.Armor}"]
				return
			}

			if ${This.ArcInt} && ${Spell[Arcane Intellect](exists)} && !${Me.Buff[Arcane Intellect](exists)} && ${Me.CurrentMana} > ${Spell[Arcane Intellect].Mana}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Arcane Intellect]
				This:Output["Casting AI"]
				return
			}

			if ${This.Combustion} && ${Spell[Combustion](exists)} && !${Spell[Combustion].Cooldown} && !${Me.Buff[Combustion](exists)} && ${Me.CurrentMana} > ${Spell[${Combustion}].Mana}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Combustion]
				This:Output["Casting Combustion"]
				return
			}

			if ${This.Dampen} && ${Spell[Dampen Magic](exists)}	&& !${Me.Buff[Dampen Magic](exists)} && ${Me.CurrentMana} > ${Spell[Dampen Magic].Mana}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Dampen Magic]
				This:Output["Casting Dampen Magic"]
				return
			}

			if ${This.Amplify} && ${Spell[Amplify Magic](exists)} && !${Me.Buff[Amplify Magic](exists)} && ${Me.CurrentMana} > ${Spell[Amplify Magic].Mana}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Amplify Magic]
				This:Output["Casting Amplify Magic"]
				return
			}
		}
 
		;--- Pull Buffs ---;
 
		member NeedPullBuff()
		{
			if ${This.IceBarrier} && ${Spell[Ice Barrier](exists)} && && !${Spell[Ice Barrier].Cooldown} && !${Me.Buff[Ice Barrier](exists)}
			{
				return TRUE
			}
			
			if ${WaterElemental} && !${Spell[Summon Water Elemental].Cooldown} && ${Spell[Summon Water Elemental](exists)} && !${Me.Pet(exists)}
			{
				return TRUE
			}

			if ${APonPull} && ${Spell[Arcane Power](exists)} && !${Spell[Arcane Power].Cooldown} && !${Me.Buff[Arcane Power](exists)}
			{
				return TRUE
			}

			if ${POMonPull} && ${Spell[Presence of Mind](exists)} && !${Spell[Presence of Mind].Cooldown} && !${Me.Buff[Presence of Mind](exists)}
			{
				return TRUE
			}
			
			return FALSE
		}
 
		method PullBuffPulse()
		{
			if ${Movement.Speed}
			{
				Move -Stop
			}
			
			Toon:Standup
			
			if ${This.IceBarrier} && ${Spell[Ice Barrier](exists)} && && !${Spell[Ice Barrier].Cooldown} && !${Me.Buff[Ice Barrier](exists)}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Ice Barrier]
				This:Output["Throwing up Ice Barrier"]
				return
			}

			if ${WaterElemental} && !${Spell[Summon Water Elemental].Cooldown} && ${Spell[Summon Water Elemental](exists)} && !${Me.Pet(exists)}
			{
				This:Output["Summoning my little baby..."]
				Toon:CastSpell[Summon Water Elemental]
			}

			if ${APonPull} && ${Spell[Arcane Power](exists)} && !${Spell[Arcane Power].Cooldown} && !${Me.Buff[Arcane Power](exists)}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Arcane Power]
				This:Output["Casting AP"]
			}

			if ${POMonPull} && ${Spell[Presence of Mind](exists)} && !${Spell[Presence of Mind].Cooldown} && !${Me.Buff[Presence of Mind](exists)}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Presence of Mind]
				This:Output["Casting PoM"]
			}
		}
 
		;--- InCombat Buffs ---;
 
		member NeedCombatBuff()
		{			
			if ${Me.Sitting}
			{
				return TRUE
			}
			
			if ${This.Racial} && !${Spell[Berserking].Cooldown} && ${Spell[Berserking](exists)} && !${Me.Buff[Berserking](exists)}
			{
				return TRUE
			}

			if ${This.ArcanePower} && !${Spell[Arcane Power].Cooldown}  && ${Spell[Arcane Power](exists)} && !${Me.Buff[Arcane Power](exists)}
			{
				return TRUE
			}

			if ${This.FrWard} && ${This.ReactFrWard} && ${Spell[Frost Ward](exists)} && !${Spell[Frost Ward].Cooldown} && !${Me.Buff[Frost Ward](exists)}
			{
				return TRUE
			}
		
			if ${This.FWard} && ${This.ReactFWard} && ${Spell[Fire Ward](exists)} && !${Spell[Fire Ward].Cooldown} && !${Me.Buff[Fire Ward](exists)}
			{
				return TRUE
			}

			if ${This.IceBarrier} && !${Spell[Ice Barrier].Cooldown} && ${Spell[Ice Barrier](exists)} && !${Me.Buff[Ice Barrier](exists)}
			{
				return TRUE
			}

			if ${This.Presence} && !${Spell[Presence of Mind].Cooldown}  && ${Spell[Presence of Mind](exists)} && !${Me.Buff[Presence of Mind](exists)}
			{
				return TRUE
			}

			if (${Me.PctHPs} < ${IBHealth} && (${Spell[Ice Block](exists)} && ${IceBlock} && !${Me.Buff[Hypothermia](exists)} && ${Spell[Ice Block].Cooldown}) || (${Spell[Ice Block].Cooldown} && ${Cold Snap} && !${Spell[Cold Snap].Cooldown} && ${Spell[Cold Snap](exists)})
			{
				return TRUE
			}
			
			if ${Slow} && !${Target.Buff[Slow](exists)} && ${Spell[Slow](exists)}
			{
				return TRUE
			}
		
			return FALSE
		}
 
		method CombatBuffPulse()
		{
 
			if ${Me.Sitting} 
			{
				Toon:Standup
			}
 
			if ${Movement.Speed}
			{
				Move -Stop
			}

			if ${This.IceBarrier} && ${Spell[Ice Barrier](exists)} && !${Me.Buff[Ice Barrier](exists)} && !${Spell[Ice Barrier].Cooldown}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Ice Barrier]
				This:Output["Lets use Ice Barrier"]
			}

			if ${Spell[Berserking](exists)} && !${Spell[Berserking].Cooldown} && ${This.Racial} && !${Me.Buff[Berserking](exists)}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Berserking]
				This:Output["Berserking"]
			}
		
			if ${This.FWard} && ${This.ReactFWard} && ${Spell[Fire Ward](exists)} && !${Spell[Fire Ward].Cooldown} && !${Me.Buff[Fire Ward](exists)}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Fire Ward]
				This:Output["Casting Fire Ward"]
				return
			}

			if ${This.FrWard} && ${This.ReactFrWard} && ${Spell[Frost Ward](exists)} && !${Spell[Frost Ward].Cooldown} && !${Me.Buff[Frost Ward](exists)}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Frost Ward]
				This:Output["Casting Frost Ward"]
				return
			}
		
			if ${This.ArcanePower} && !${Spell[Arcane Power].Cooldown}  && ${Spell[Arcane Power](exists)} && !${Me.Buff[Arcane Power](exists)}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Arcane Power]
				This:Output["Casting AP"]
			}
	
			if ${This.Presence} && !${Spell[Presence of Mind].Cooldown}  && ${Spell[Presence of Mind](exists)} && !${Me.Buff[Presence of Mind](exists)}
			{
				Target ${Me.GUID}
				Toon:CastSpell[Presence of Mind]
				This:Output["Casting PoM"]
			}	
		
			Target ${Targeting.TargetCollection.Get[1]}
		
			if ${Slow} & ${Spell[Slow](exists)}
			{
				if !${Target.Buff[Slow](exists)}
				{
					Target ${Targeting.TargetCollection.Get[1]}
					Toon:CastSpell[Slow]
				}
			}
		}
 
		;--- Pull ---;
 
		method PullPulse()
		{
			move -stop
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
			if ${Me.Target.Dead}
			{
			   WoWScript ClearTarget()
			   This:Output["Oops target is dead, lets get rid of him..."]
			   return
			}
			if ${Me.Sitting}
			{
				Toon:Standup
				This:Output["Standing up]
			}
			
			if ${Target.PctHPs}>99
			{
				ArcaneImmune:Set[FALSE]
				FireImmune:Set[FALSE]
				FrostImmune:Set[FALSE]
			}
			
			if  ${This.Pulled} && ${This.TwoPull} && !${Me.Casting}
			{
				Toon:CastSpell[${PullSecond}]
			}
			
			if ${This.detectMobAdd}
			{
				This:Output["Woohoo you are about to pull a mob with another mob nearby, too bad I havn't learned to poly pull... that would be helpful here lol"]
			}
			if !${This.RandPull} && !${Me.Casting}
			{
				if ${Spell[${This.PullWith}](exists)}
				{
					Toon:CastSpell[${This.PullWith}]
					This:Output["Pulling with ${This.PullWith}"]
				}
				if !${Spell[${This.PullWith}](exists)}
				{
					Toon:CastSpell[Fireball]
					This:Output["Pulling with Fireball because ${This.PullWith} does not exist"]
				}
			}
			if ${This.RandPull} && !${Me.Casting}
			{
				This.detectTimer:Set[${LavishScript.RunningTime}]
				RandVar:Set[${Math.Rand[3]}]
				if ${This.RandVar} == 0
				{
					RandPullSpell:Set[Pyroblast]
					This:Output["Pulling Random: Pryoblast"]
				}
				if ${This.RandVar} == 1
				{
					RandPullSpell:Set[Fireball]
					This:Output["Pulling Random: Fireball"]
				}
				if ${This.RandVar} == 2
				{
					RandPullSpell:Set[Frostbolt]
					This:Output["Pulling Random: Frostbolt"]
				}

				Target ${Targeting.TargetCollection.Get[1]}
				if ${Spell[${This.RandPullSpell}](exists)}
				{
					Toon:CastSpell[${This.RandPullSpell}]
				}

				if !${Spell[${This.RandPullSpell}](exists)}
				{
					Toon:CastSpell[Fireball]
				}
			}
			if ${Me.Casting[${This.PullWith}]}
			{
				Pulled:Set[TRUE]
			}

			if ${WaterElemental} && ${Me.Pet(exists)}
			{
				WoWScript PetAttack()
			}
		}
 
		;--- Meat and Potatoes ---;
 
		method AttackPulse()
		{
			Pulled:Set[FALSE]
			if ${Me.Target.Dead}
			{
			   WoWScript ClearTarget()
			   This:Output["Oops target is dead, lets get rid of him..."]
			   return
			}
			if !${Target(exists)} || ${Target.GUID.Equal[${Me.GUID}]}
			{
				This:Output["Ugh, lets find a target"]
				return
			}
			
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]

			if ${Target.PctHPs}>99
			{
				ArcaneImmune:Set[FALSE]
				FireImmune:Set[FALSE]
				FrostImmune:Set[FALSE]
			}
			
			if ${Me.PctHPs} <= ${This.PotHP} && ${Consumable.HasHPot}
			{
				WowScript SpellStopCasting()
				This:TakePot[HPot,${Me.GlobalCooldown}]
				This:Output["Oh shit we are low on health, lets use a Health pot"]
			}
			if ${Me.PctMana} < ${This.PotMP} && ${Consumable.HasMPot}
			{
				WowScript SpellStopCasting()
				This:TakePot[MPot,${Me.GlobalCooldown}]
				This:Output["Oh shit we are low on mana, lets use a Mana pot"]
			}
			
			if ${Target(unit).Casting.Name.Upper.Find[FIRE](exists)} && !${This.ReactFWard}
			{
				This:Output[Getting attacked by fire Spell. We need Fire Protection !]
				This.ReactFWard:Set[TRUE]
			}
			
			if !${This.IceBarrier} && ${Spell[Mana Shield](exists)} && ${This.ManaShield} && !${Me.Buff[Mana Shield](exists)} && ${Me.PctHPs} < 15 && ${Me.PctMana} > 40 && ${Target.PctHPs} < 40
			{
				Toon:CastSpell[Mana Shield]
				This:Output["Shit we are getting pretty low on Health, using Mana Shield"]
				return
			}
		
			if ${Me.Buff[Feared](exists)} && ${Spell[Will of the Forsaken](exists)} && !${Spell[Will of the Forsaken].Cooldown} && ${This.Racial}
			{
				Toon:CastSpell[Will of the Forsaken]
				This:Output["God I hate fear, WoTF!"]
				return
			}

			if ${Me.Buff[Stunned](exists)} && ${Spell[Blink](exists)} && !${Spell[Blink].Cooldown} && ${This.StunBlink}
			{
				Toon:CastSpell[Blink]
				This:Output["Shit we're stunned, lets blink!"]
				return
			}

			if ${This.CounterSpell} && ${Target.Casting(exists)} && ${Target.CurrentMana} > 0
			{
				if ${Spell[CounterSpell].Cooldown} && ${Spell[Arcane Torrent](exists)} && ${Target.Distance} < 8 && !${Spell[Arcane Torrent].Cooldown}
				{
					Toon:CastSpell[Arcane Torrent]
					This:Output["Oh noes they are casting, and counterspell is on cooldown!?! No worries, lets use arcane torrent!"]
				}
				else
				{
					Target ${Targeting.TargetCollection.Get[1]}
					Toon:CastSpell[Counterspell]
					This:Output["Oh noes they are casting, counterspell now!"]
				}
			}

			if ${Me.PctMana} < 85 && ${Spell[Arcane Torrent](exists)} && !${Spell[Arcane Torrent].Cooldown} && ${Me.Buff[Mana Tap].Application} == 3
			{
				Toon:CastSpell[Arcane Torrent]
				This:Output["Arcane Torrent"]
				return
			}

			if ${Me.PctHPs} < 60 && ${Spell[Gift of the Naaru](exists)} && !${Spell[Gift of the Naaru].Cooldown} && ${This.Racial}
			{
				Toon:CastSpell[Gift of the Naaru]
				This:Output["Gift of Naaru"]
				return
			}

			if (${Me.PctMana} < ${This.GemMana}) && ${This.HasGem} && !${Me.InCombat} && ${WoWScript[GetItemCooldown("${This.BestGem}"),2]} == 0
			{
				if (${WoWScript[GetItemCooldown("${This.BestGem}"),2]} == 0) && ${This.HasGem}
				{
					This:UseGem
					This:Output["Oh god we are almost out of mana, lets use a mana gem."]
					return
				}
				if (${WoWScript[GetItemCooldown("${This.BestGem}"),2]} == 0) && !${This.HasGem}
				{
					This:Output["WTF, can't find ${This.BestGem} ..."]
					return
				}
			}
		
			if (${Target.Distance} < 20) && !${FireImmune} && !${Spell[Fire Blast].Cooldown} && ${Spell[Fire Blast](exists)} && (${Target.PctHPs} < ${This.FB})
			{
				Target ${Targeting.TargetCollection.Get[1]}
				Toon:CastSpell[Fire Blast]
				This:Output["Time to fire blast..."]
				return
			}

			if ${Spell[Mana Tap](exists)} && !${Spell[Mana Tap].Cooldown} && ${This.Racial} && ${Target.CurrentMana} > 0
			{
				Target ${Targeting.TargetCollection.Get[1]}
				Toon:CastSpell[Mana Tap]
				This:Output["Mana tap"]
				return
			}

			if ${This.CombatEvocation} && ${This.FrostNova} && !${FrostImmune} && ${Me.PctMana} < 20 && ${Target.PctHPs} > 40 && (${Math.Distance[${Me.X},${Me.Y},${Me.Z},${Target.X},${Target.Y},${Target.Z}]} < 10)
			{
				Toon:CastSpell[Frost nova]
				This:Output["Frost nova"]
				This:JumpAway
				if ${Movement.Speed}
				{
					Move -Stop
				}
				if ${Target.Buff[Frost Nova](exists)}
				{
					Toon:CastSpell[Evocation]
					This:Output["Ah, we are out of mana, lets use evocation"]
				}
			}

			if ${ConeOfCold} && !${Spell[Cone Of Cold].Cooldown} && ${Spell[Cone of Cold](exists)} && !${FrostImmune} && ${Target.Distance} < 8 && !${This.HasSheep}
			{
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
				Toon:CastSpell[Cone of Cold]
				This:Output["time for a Cone of Cold"]
			}

			if ${This.BlastWave} && !${Spell[Blast Wave].Cooldown} && ${Spell[Blast wave](exists)} && !${FireImmune} && ${Target.Distance} < 8 && !${This.HasSheep}
			{
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
				Toon:CastSpell[Blast wave]
				This:Output["Blast wave"]
			}

			if ${This.DragonBreath} && !${Spell["Dragon's Breath"].Cooldown} && ${Spell["Dragon's Breath"](exists)} && !${FireImmune} && ${Target.Distance} < 8 && !${This.HasSheep}
			{
				Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
				Toon:CastSpell[Dragon's Breath]
				This:Output["Whats that smell? Ah its Dragon's Breath"]
				This:JumpAway
			}
			
			if (${Target.Buff[Frost Nova](exists)} || ${Target.Buff[Frostbite](exists)}) && ${Math.Distance[${Me.X},${Me.Y},${Me.Z},${Target.X},${Target.Y},${Target.Z}]} < 6
			{
				This:Output["Oh they are Frozen within meele range, lets jump away"]
				This:JumpAway
			}
			NovaList:Search[-units,-nearest,-neutral,-alive,-range 0-15]
			if !${This.HasSheep} && ${This.FrostNova} && !${FrostImmune} && (${Math.Distance[${Me.X},${Me.Y},${Me.Z},${Target.X},${Target.Y},${Target.Z}]} < 10) && !${Spell[Frost Nova].Cooldown} && ${Spell[Frost Nova](exists)} && ${Me.CurrentMana} > ${Spell[Frost Nova].Mana} && ${NovaList.Count} == 0 && !${Me.Casting}
			{
				Toon:CastSpell["Frost Nova"]
				This:Output["nows lets frost nova him..."]
				This:JumpAway
			}
			if ${Movement.Speed}
			{
				Move -Stop
				return
			}
			
			if ${This.IceLance} && ${Spell[Ice Lance](exists)} && (${Target.Buff[Frost Nova](exists)} || ${Target.Buff[Frostbite](exists)}) && !${FrostImmune}
			{
				Target ${Targeting.TargetCollection.Get[1]}
				Toon:CastSpell[Ice Lance]
				This:Output["Oh! Our target is frozen, time to ice lance!"]
				return
			}

			
			if ${Target.Distance} > 30 && !${Me.Casting}
      {
        This:Output["Ugh, too far away... lets move up a bit"]
        Move Forward 
        return
    	}


			if ${Movement.Speed}
			{
				Move -Stop
				return
			}
			AggroList:Search[-units,-nearest,-aggro,-alive,-range 0-30]
			if ${Spell[Polymorph](exists)} && ${AggroList.Count} >= 2 && !${This.HasSheep} && (${Unit[${Targeting.TargetCollection.Get[2]}].CreatureType.Equal[Beast]} || ${Unit[${Targeting.TargetCollection.Get[2]}].CreatureType.Equal[Humanoid]} && !${Unit[${Targeting.TargetCollection.Get[2]}].CreatureType.Equal[Totem]})
			{
				Target ${Targeting.TargetCollection.Get[2]}
				Toon:CastSpell[Polymorph]
				This:Output["Ah shit, we got an add... lets poly our add"]
				Target ${Targeting.TargetCollection.Get[1]}
				This.NextSheeping:Set[${Math.Calc[${LavishScript.RunningTime}+(10 * ${Bot.GlobalCooldown})]}]
				return
			}
			
			if ${Targeting.TargetCollection.Get[2](exists)} && ${Unit[${Targeting.TargetCollection.Get[2]}].CreatureType.Equal[Totem]}&& ${Unit[${Targeting.TargetCollection.Get[2]}].Distance <= 20} && !${This.HasSheep} && !${Spell[Fire Blast].Cooldown}
			{
				Target ${Targeting.TargetCollection.Get[2]}
				Toon:CastSpell[Fire Blast]
				This:Output["Fire Blasting Totem"]
				Target ${Targeting.TargetCollection.Get[1]}
				return
			}

			if (${Me.PctMana} < 5 || (${Target.PctHPs} <  ${This.Wand})) && !${Action[Shoot].AutoRepeat}
			{
				
				if !${Me.Equip[Ranged](exists)} && !${Action[Attack].AutoRepeat}
				{
					WoWScript AttackTarget()
					return
				}
				if ${Me.Equip[Ranged](exists)} && !${Action[Shoot].AutoRepeat}
				{
					Toon:CastSpell[Shoot]
					This:Output["Shooting my wand"]
					Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
					return
				}
			}

			if ${This.RandCom}
			{
				RandVar:Set[${Math.Rand[6]}
				if ${This.RandVar} == 0
				{
					RandComSpell:Set[Fireball]
					This:Output["Casting Random: Fireball"]
				}
				if ${This.RandVar} == 1
				{
					RandComSpell:Set[Scorch]
					This:Output["Casting Random: Scorch"]
				}
				if ${This.RandVar} == 2
				{
					RandComSpell:Set[Pyroblast]
					This:Output["Casting Random: Pryoblast"]
				}
				if ${This.RandVar} == 3
				{
					RandComSpell:Set[Arcane Missiles]
					This:Output["Casting Random: Arcane Missiles"]
				}
				if ${This.RandVar} == 4
				{
					RandComSpell:Set[Arcane Blast]
					This:Output["Casting Random: Arcane Blast"]
				}
				if ${This.RandVar} == 5
				{
					RandComSpell:Set[Frostbolt]
					This:Output["Casting Random: Frostbolt"]
				}
				if ${FireImmune}
				{
					RandComSpell:Set[Frostbolt]
					This:Output["Ah he's fire immune, lets cast frostbolt"]
				}
				if !${FireImmune}
				{
					RandComSpell:Set[Fireball]
					This:Output["Lets cast fireball, shall we?"]
				}
				Target ${Targeting.TargetCollection.Get[1]}
				if ${Spell[${This.RandComSpell}](exists)} && !${Me.Casting}
				{
					Toon:CastSpell[${This.RandComSpell}]
					This:Output["Casting ${This.RandComSpell}"]
					return
				}
				if !${Spell["${This.RandComSpell}"](exists)}
				{
					if ${FireImmune} && !${Me.Casting}
					{
						Toon:CastSpell[Frostbolt]
						This:Output["Casting Frostbolt because ${This.RandComSpell} does not exist and it is immune to fire"]
					}
					if !${FireImmune} && !${Me.Casting}
					{
						Toon:CastSpell[Fireball]
						This:Output["Casting Fireball because ${This.RandComSpell} does not exist"]
					}
					return
				}
			}
			if !${This.RandCom}
			{
				Target ${Targeting.TargetCollection.Get[1]}
				if (${This.CombatCast.Equal[Fireball]} || ${This.CombatCast.Equal[Scorch]} || ${This.CombatCast.Equal[Pyroblast]}) && ${FireImmune} && !${Me.Casting}
				{
					Toon:CastSpell[Frostbolt]
					This:Output["Casting Frostbolt because the mob is immune to fire"]
					return
				}
				if ${This.CombatCast.Equal[Frostbolt]} && ${FrostImmune} && !${Me.Casting}
				{
					This:Output["Casting Fireball because the mob is immune to frost"]
					Toon:CastSpell[Fireball]
				}
				if ${Spell[${This.CombatCast}](exists)} && !${Me.Casting}
				{
					Toon:CastSpell[${This.CombatCast}]
					This:Output[Casting ${This.CombatCast}]
					return
				}
				if !${Spell[${This.CombatCast}](exists)} && !${Me.Casting}
				{
					Toon:CastSpell[Fireball]
					This:Output["Casting Fireball because ${This.CombatCast} does not exist"]
					return
				}
			}
			
			if ${Me.PctHPs} < ${IBHealth} && ${Spell[Ice Block](exists)} && ${IceBlock} && !${Me.Buff[Hypothermia](exists)}
			{
				if ${Spell[Ice Block].Cooldown} && ${Cold Snap} && !${Spell[Cold Snap].Cooldown} && ${Spell[Cold Snap](exists)}
				{
					Toon:CastSpell[Cold Snap]
					This:Output["Shit Ice block is on CD, lets use Cold Snap"]
				}
				Toon:CastSpell[Ice Block]
				This:Output["Ice blocking..."]
			}
		}
		
		; some extras
		method JumpAway()
		{
			RandVar:Set[${Math.Rand[3]}]
			if ${RandVar} == 0
			{
				Move Right
			}
			if ${RandVar} == 1
			{
				Move Left
			}
			if ${RandVar} == 2
			{
				Move Backward
			}
			WoWPress Jump
			Target ${Unit[${Targeting.TargetCollection.Get[1]}].GUID}
			return
		}

		method DecursePulse()
		{
			/** Check if you don't have a buff **/
			if !${Me.Buff[${BuffNum}](exists)}
			{
				return
			}

			/** if your have a debuff and it's a curse, remove it **/
			if ${Me.Buff[${BuffNum}].Harmful}
			{
				Toon:Standup

				if ${Me.Buff[${BuffNum}].DispelType.Equal[Curse]} && ${Me.Action[Remove Lesser Curse].Usable}
				{
					Toon:CastSpell[Remove Lesser Curse]
					return
				}

				if (${Me.Buff[${BuffNum}].DispelType.Equal[Snare]} || ${Me.Buff[${BuffNum}].DispelType.Equal[Root]}) && (${Spell[Escape Artist](exists)}) && !${Spell[Escape Artist].Cooldown} && ${This.Racial}
				{
					Toon:CastSpell[Escape Artist]
					return
				}

				if ${Me.Buff[${BuffNum}].DispelType.NotEqual[Curse]} && ${Spell[Ice Block](exists)} && ${IceBlock} && !${Me.Buff[Hypothermia](exists)}
				{
					if ${Spell[Ice Block].Cooldown} && ${Cold Snap} && !${Spell[Cold Snap].Cooldown} && ${Spell[Cold Snap](exists)}
					{
						Toon:CastSpell[Cold Snap]
					}
					Toon:CastSpell[Ice Block]
					return
				}
			}
			return
		}

		method UseGem()
		{
			/** Use the Best Mana Gem **/
			if !${BestGem.Equal["None"]}
			{
				Item[${This.BestGem}]:Use
			}
			return
		}	

		member HasGem()
		{
			if ${Item["Mana Emerald"](exists)}
			{
				This.BestGem:Set["Mana Emerald"]
				return TRUE
			}

			if ${Item["Mana Ruby"](exists)}
			{
				This.BestGem:Set["Mana Ruby"]
				return TRUE
			}

			if ${Item["Mana Citrine"](exists)}
			{
				This.BestGem:Set["Mana Citrine"]
				return TRUE
			}

			if ${Item["Mana Jade"](exists)}
			{
				This.BestGem:Set["Mana Jade"]
				return TRUE
			}

			if ${Item["Mana Agate"](exists)}
			{
				This.BestGem:Set["Mana Agate"]
				return TRUE
			}

			return FALSE
		}

		member GemSpell()
		{
			if ${Spell["Conjure Mana Emerald"](exists)}
			{
				This.BestGem:Set["Mana Emerald"]
				return "Conjure Mana Emerald"
			}
			if !${Spell["Conjure Mana Emerald"](exists)} && ${Spell["Conjure Mana Ruby"](exists)}
			{
				This.BestGem:Set["Mana Ruby"]
				return "Conjure Mana Ruby"
			}
			if !${Spell["Conjure Mana Ruby"](exists)} && ${Spell["Conjure Mana Citrine"](exists)}
			{
				This.BestGem:Set["Mana Citrine"]
				return "Conjure Mana Citrine"
			}
			if !${Spell["Conjure Mana Citrine"](exists)} && ${Spell["Conjure Mana Jade"](exists)}
			{
				This.BestGem:Set["Mana Jade"]
				return "Conjure Mana Jade"
			}
			if !${Spell["Conjure Mana Jade"](exists)} && ${Spell["Conjure Mana Agate"](exists)}
			{
				This.BestGem:Set["Mana Agate"]
				return "Conjure Mana Agate"
			}
			This.BestGem:Set["None"]
			return "None"
		}

		member NeedDecurse()
		{
			BuffNum:Inc
			if ${BuffNum} > 56
			{
				BuffNum:Set[1]
			}

			if !${Me.Buff[${BuffNum}](exists)}
			{
				return FALSE
			}

			if ${Me.Buff[${BuffNum}].Harmful}
			{
				if ${Me.Buff[${BuffNum}].DispelType.Equal[Curse]} && (${Spell[Remove Lesser Curse](exists)})
				{
					return TRUE
				}
				if (${Me.Buff[${BuffNum}].DispelType.Equal[Snare]} || ${Me.Buff[${BuffNum}].DispelType.Equal[Root]}) && (${Spell[Escape Artist](exists)}) && !${Spell[Escape Artist].Cooldown}
				{
					return TRUE
				}
				if ${Me.Buff[${BuffNum}].DispelType.NotEqual[Curse]} && ${Spell[Ice Block](exists)} && ${IceBlock} && !${Me.Buff[Hypothermia](exists)} && (!${Spell[Ice Block].Cooldown} || !${Spell[Cold Snap].Cooldown})
				{
					return TRUE
				}
			}
			return FALSE
		}

		function TriggerPlease()
		{
			AddTrigger Immune "[Event:@eventid@:CHAT_MSG_SPELL_SELF_DAMAGE](\"Your @ReactCast@ failed. @*@ is immune.@*@"
			AddTrigger HitMagic "[Event:@eventid@:CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS](\"@Mob@ @Dam@ you for @points@ @MagicType@ damage.@*@"
			AddTrigger SpellMagic "[Event:@eventid@:CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE](\"@Mob@'s @ReactCast@ @Dam@ you for @points@ @MagicType@ damage.@*@" /*'*/
		}
			
		function Immune(string Line, string eventid, string ReactCast)
		{
			echo ${ReactCast}
			echo Immune!
			echo Immune to spell cast, initiating reactive casting
			if ${ReactCast.Equal[Arcane Missiles]} || ${ReactCast.Equal[Arcane Blast]} || ${ReactCast.Equal[Arcane Explosion]}
			{
				ArcaneImmune:Set[TRUE]
				This:Output [Immune to arcane, stopping arcane spells]
			}
			if ${ReactCast.Equal[Pyroblast]} || ${ReactCast.Equal[Scorch]} || ${ReactCast.Equal[Fireball]} || ${ReactCast.Equal[Blast Wave]} ||  ${ReactCast.Equal[Dragon'/*'*/s Breath]} ||  ${ReactCast.Equal[Flamestrike]} ||  ${ReactCast.Equal[Molten Armor]}
			{
				FireImmune:Set[TRUE]
				This:Output [Immune to fire, stopping fire spells]
			}
			if ${ReactCast.Equal[Frostbolt]} || ${ReactCast.Equal[Frost Nova]} || ${ReactCast.Equal[Cone of Cold]} || ${ReactCast.Equal[Blizzard]} || ${ReactCast.Equal[IceLance]}
			{
				FrostImmune:Set[TRUE]
				echo FrostImmune!
				This:Output [Immune to frost, stopping frost spells]
			}
			return
		}

		function HitMagic(string Line, string eventid, string Mob, string Dam, string points, string MagicType)
		{
			if ${MagicType.Equal[Fire]} && ${Spell[Fire Ward](exists)} && !${Spell[Fire Ward].Cooldown}
			{
				ReactFWard:Set[TRUE]
			}
			if ${MagicType.Equal[Frost]} && ${Spell[Frost Ward](exists)} && !${Spell[Frost Ward].Cooldown}
			{
				ReactFrWard:Set[TRUE]
			}
			return
		}

		function SpellMagic(string Line, string eventid, string Mob, string ReactCast, string Dam, string points, string MagicType)
		{
			if ${MagicType.Equal[Fire]} && ${Spell[Fire Ward](exists)} && !${Spell[Fire Ward].Cooldown}
			{
				ReactFWard:Set[TRUE]
			}
			if ${MagicType.Equal[Frost]} && ${Spell[Frost Ward](exists)} && !${Spell[Frost Ward].Cooldown}
			{
				ReactFrWard:Set[TRUE]
			}
			return
		}
		
		
		;--- GUI ---;
 
		method InitMageGUI()
		{
			variable int i = 1
			
			for (i:Set[1] ; ${i} <=${UIElement[cmbPullWith@Generic@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.PullWith.Equal["${UIElement[cmbPullWith@Generic@Pages@ClassGUI].Item[${i}]}"]}
				{
					UIElement[cmbPullWith@Generic@Pages@ClassGUI]:SelectItem[${i}]
				}
			}

			for (i:Set[1] ; ${i} <=${UIElement[cmbCombatCast@Generic@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.CombatCast.Equal["${UIElement[cmbCombatCast@Generic@Pages@ClassGUI].Item[${i}]}"]}
				{
					UIElement[cmbCombatCast@Generic@Pages@ClassGUI]:SelectItem[${i}]
				}
			}

			for (i:Set[1] ; ${i} <=${UIElement[cmbArmor@Buffs@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.Armor.Equal["${UIElement[cmbArmor@Buffs@Pages@ClassGUI].Item[${i}]}"]}
				{
					UIElement[cmbArmor@Buffs@Pages@ClassGUI]:SelectItem[${i}]
				}
			}
			for (i:Set[1] ; ${i} <=${UIElement[cmbPullSecondh@Generic@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.PullSecond.Equal["${UIElement[cmbPullSecond@Generic@Pages@ClassGUI].Item[${i}]}"]}
				{
					UIElement[cmbPullSecond@Generic@Pages@ClassGUI]:SelectItem[${i}]
				}
			}
			;bandages
			for (i:Set[1] ; ${i} <=${UIElement[cmbBandage@Extras@Pages@ClassGUI].Items} ; i:Inc)
			{
				if ${This.Bandage.Equal["${UIElement[cmbBandage@Extras@Pages@ClassGUI].Item[${i}]}"]}
				{
					UIElement[cmbBandage@Extras@Pages@ClassGUI]:SelectItem[${i}]
				}
			}

			;checkboxes
			if ${This.MakeBand}
			{
				UIElement[chkMakeBand@Extras@Pages@ClassGUI]:SetChecked
			}
			if ${This.TwoPull}
			{
				UIElement[chkTwoPull@Generic@Pages@ClassGUI]:SetChecked
			}
			if ${This.RandPull}
			{
				UIElement[chkRandPull@Generic@Pages@ClassGUI]:SetChecked
			}
			if ${This.RandCom}
			{
				UIElement[chkRandCom@Generic@Pages@ClassGUI]:SetChecked
			}
			if ${This.Racial}
			{
				UIElement[chkRacial@Extras@Pages@ClassGUI]:SetChecked
			}
			if ${This.ArcInt}
			{
				UIElement[chkArcInt@Buffs@Pages@ClassGUI]:SetChecked
			}
			if ${This.FWard}
			{
				UIElement[chkFWard@Buffs@Pages@ClassGUI]:SetChecked
			}
			if ${This.FrWard}
			{
				UIElement[chkFrWard@Buffs@Pages@ClassGUI]:SetChecked
			}
			if ${This.Dampen}
			{
				UIElement[chkDampen@Buffs@Pages@ClassGUI]:SetChecked
			}
			if ${This.Amplify}
			{
				UIElement[chkAmplify@Buffs@Pages@ClassGUI]:SetChecked
			}
			if ${This.CombatEvocation}
			{
				UIElement[chkCombatEvocation@Buffs@Pages@ClassGUI]:SetChecked
			}
			if ${This.RestEvocation}
			{
				UIElement[chkRestEvocation@Buffs@Pages@ClassGUI]:SetChecked
			}
			if ${This.ManaShield}
			{
				UIElement[chkManaShield@Buffs@Pages@ClassGUI]:SetChecked
			}
			if ${This.CounterSpell}
			{
				UIElement[chkCounterSpell@Arcane@Pages@ClassGUI]:SetChecked
			}
			if ${This.Presence}
			{
				UIElement[chkPresence@Arcane@Pages@ClassGUI]:SetChecked
			}
			if ${This.POMonPull}
			{
				UIElement[chkPOMonPull@Arcane@Pages@ClassGUI]:SetChecked
			}
			if ${This.Slow}
			{
				UIElement[chkSlow@Arcane@Pages@ClassGUI]:SetChecked
			}
			if ${This.ArcanePower}
			{
				UIElement[chkArcanePower@Arcane@Pages@ClassGUI]:SetChecked
			}
			if ${This.APonPull}
			{
				UIElement[chkAPonPull@Arcane@Pages@ClassGUI]:SetChecked
			}
			if ${This.StunBlink}
			{
				UIElement[chkStunBlink@Arcane@Pages@ClassGUI]:SetChecked
			}
			if ${This.DragonBreath}
			{
				UIElement[chkDragonBreath@Fire@Pages@ClassGUI]:SetChecked
			}
			if ${This.BlastWave}
			{
				UIElement[chkBlastWave@Fire@Pages@ClassGUI]:SetChecked
			}
			if ${This.Combustion}
			{
				UIElement[chkCombustion@Fire@Pages@ClassGUI]:SetChecked
			}
			if ${This.FrostNova}
			{
				UIElement[chkFrostNova@Frost@Pages@ClassGUI]:SetChecked
			}
			if ${This.ConeOfCold}
			{
				UIElement[chkConeOfCold@Frost@Pages@ClassGUI]:SetChecked
			}
			if ${This.ColdSnap}
			{
				UIElement[chkColdSnap@Frost@Pages@ClassGUI]:SetChecked
			}
			if ${This.IceBlock}
			{
				UIElement[chkIceBlock@Frost@Pages@ClassGUI]:SetChecked
			}
			if ${This.IceBarrier}
			{
				UIElement[chkIceBarrier@Frost@Pages@ClassGUI]:SetChecked
			}
			if ${This.WaterElemental}
			{
				UIElement[chkWaterElemental@Frost@Pages@ClassGUI]:SetChecked
			}
			if ${This.IceLance}
			{
				UIElement[chkIceLance@Frost@Pages@ClassGUI]:SetChecked
			}

			;sliders
			if ${This.RestMP} != ${UIElement[sldRestMP@Generic@Pages@ClassGUI].Value}
			{
				UIElement[sldRestMP@Generic@Pages@ClassGUI]:SetValue[${This.RestMP}]
			}
			if ${This.RestHP} != ${UIElement[sldRestHP@Generic@Pages@ClassGUI].Value}
			{
				UIElement[sldRestHP@Generic@Pages@ClassGUI]:SetValue[${This.RestHP}]
			}
			if ${This.Wand} != ${UIElement[sldWand@Generic@Pages@ClassGUI].Value}
			{
				UIElement[sldWand@Generic@Pages@ClassGUI]:SetValue[${This.Wand}]
			}
			if ${This.GemMana} != ${UIElement[sldGemMana@Generic@Pages@ClassGUI].Value}
			{
				UIElement[sldGemMana@Generic@Pages@ClassGUI]:SetValue[${This.GemMana}]
			}
			if ${This.IBHealth} != ${UIElement[sldIBHealth@Frost@Pages@ClassGUI].Value}
			{
				UIElement[sldIBHealth@Frost@Pages@ClassGUI]:SetValue[${This.IBHealth}]
			}
			;extras
			if ${This.BandHP} != ${UIElement[sldBandHP@Extras@Pages@ClassGUI].Value}
			{
				UIElement[sldBandHP@Extras@Pages@ClassGUI]:SetValue[${This.BandHP}]
			}
			if ${This.PotHP} != ${UIElement[sldPotHP@Extras@Pages@ClassGUI].Value}
			{
				UIElement[sldPotHP@Extras@Pages@ClassGUI]:SetValue[${This.PotHP}]
			}
			if ${This.PotMP} != ${UIElement[sldPotMP@Extras@Pages@ClassGUI].Value}
			{
				UIElement[sldPotMP@Extras@Pages@ClassGUI]:SetValue[${This.PotMP}]
			}
			if ${This.FB} != ${UIElement[sldFB@Extras@Pages@ClassGUI].Value}
			{
				UIElement[sldFB@Extras@Pages@ClassGUI]:SetValue[${This.FB}]
			}
		}

		method ClassGUIChange(string Action)
		{
			switch ${Action}
			{
				/** Get settings from the Generic tab **/
				case GemMana
				if ${UIElement[sldGemMana@Generic@Pages@ClassGUI].Value(exists)}
				{
					This.GemMana:Set[${UIElement[sldGemMana@Generic@Pages@ClassGUI].Value}]
				}
				break
				case RestMP
				if ${UIElement[sldRestMP@Generic@Pages@ClassGUI].Value(exists)}
				{
					This.RestMP:Set[${UIElement[sldRestMP@Generic@Pages@ClassGUI].Value}]
				}
				break
				case RestHP
				if ${UIElement[sldRestHP@Generic@Pages@ClassGUI].Value(exists)}
				{
					This.RestHP:Set[${UIElement[sldRestHP@Generic@Pages@ClassGUI].Value}]
				}
				break
				case Wand
				if ${UIElement[sldWand@Generic@Pages@ClassGUI].Value(exists)}
				{
					This.Wand:Set[${UIElement[sldWand@Generic@Pages@ClassGUI].Value}]
				}
				break
				case pullwith
				if ${UIElement[cmbPullWith@Generic@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
					This.PullWith:Set[${UIElement[cmbPullWith@Generic@Pages@ClassGUI].SelectedItem}]
				}
				break
				case RandPull
				if ${UIElement[chkRandPull@Generic@Pages@ClassGUI].Checked}
				{
					This.RandPull:Set[TRUE]
				}
				if !${UIElement[chkRandPull@Generic@Pages@ClassGUI].Checked}
				{
					This.RandPull:Set[FALSE]
				}
				break
				case TwoPull
				if ${UIElement[chkTwoPull@Generic@Pages@ClassGUI].Checked}
				{
					This.TwoPull:Set[TRUE]
				}
				if !${UIElement[chkTwoPull@Generic@Pages@ClassGUI].Checked}
				{
					This.TwoPull:Set[FALSE]
				}
				break
				case CombatCast
				if ${UIElement[cmbCombatCast@Generic@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
					This.CombatCast:Set[${UIElement[cmbCombatCast@Generic@Pages@ClassGUI].SelectedItem}]
				}
				break
				case PullSecond
				if ${UIElement[cmbPullSecond@Generic@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
					This.PullSecond:Set[${UIElement[cmbPullSecond@Generic@Pages@ClassGUI].SelectedItem}]
				}
				break
				case RandCom
				if ${UIElement[chkRandCom@Generic@Pages@ClassGUI].Checked}
				{
					This.RandCom:Set[TRUE]
				}
				if !${UIElement[chkRandCom@Generic@Pages@ClassGUI].Checked}
				{
					This.RandCom:Set[FALSE]
				}
				break
				case Racial
				if ${UIElement[chkRacial@Extras@Pages@ClassGUI].Checked}
				{
					This.Racial:Set[TRUE]
				}
				if !${UIElement[chkRacial@Extras@Pages@ClassGUI].Checked}
				{
					This.Racial:Set[FALSE]
				}
				break

				/** Get settings from the Buff tab **/
				case ArcInt
				if ${UIElement[chkArcInt@Buffs@Pages@ClassGUI].Checked}
				{
					This.ArcInt:Set[TRUE]
				}
				if !${UIElement[chkArcInt@Buffs@Pages@ClassGUI].Checked}
				{
					This.ArcInt:Set[FALSE]
				}
				break
				case Armor
				if ${UIElement[cmbArmor@Buffs@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
					This.Armor:Set[${UIElement[cmbArmor@Buffs@Pages@ClassGUI].SelectedItem}]
				}
				break
				case FWard
				if ${UIElement[chkFWard@Buffs@Pages@ClassGUI].Checked}
				{
					This.FWard:Set[TRUE]
				}
				if !${UIElement[chkFWard@Buffs@Pages@ClassGUI].Checked}
				{
					This.FWard:Set[FALSE]
				}
				break
				case FrWard
				if ${UIElement[chkFrWard@Buffs@Pages@ClassGUI].Checked}
				{
					This.FrWard:Set[TRUE]
				}
				if !${UIElement[chkFrWard@Buffs@Pages@ClassGUI].Checked}
				{
					This.FrWard:Set[FALSE]
				}
				break
				case Dampen
				if ${UIElement[chkDampen@Buffs@Pages@ClassGUI].Checked}
				{
					This.Dampen:Set[TRUE]
				}
				if !${UIElement[chkDampen@Buffs@Pages@ClassGUI].Checked}
				{
					This.Dampen:Set[FALSE]
				}
				break
				case Amplify
				if ${UIElement[chkAmplify@Buffs@Pages@ClassGUI].Checked}
				{
					This.Amplify:Set[TRUE]
				}
				if !${UIElement[chkAmplify@Buffs@Pages@ClassGUI].Checked}
				{
					This.Amplify:Set[FALSE]
				}
				break
				case CombatEvocation
				if ${UIElement[chkCombatEvocation@Buffs@Pages@ClassGUI].Checked}
				{
					This.CombatEvocation:Set[TRUE]
				}
				if !${UIElement[chkCombatEvocation@Buffs@Pages@ClassGUI].Checked}
				{
					This.CombatEvocation:Set[FALSE]
				}
				break
				case RestEvocation
				if ${UIElement[chkRestEvocation@Buffs@Pages@ClassGUI].Checked}
				{
					This.RestEvocation:Set[TRUE]
				}
				if !${UIElement[chkRestEvocation@Buffs@Pages@ClassGUI].Checked}
				{
					This.RestEvocation:Set[FALSE]
				}
				break
				case manashield
				if ${UIElement[chkManaShield@Buffs@Pages@ClassGUI].Checked}
				{
					This.ManaShield:Set[TRUE]
				}
				if !${UIElement[chkManaShield@Buffs@Pages@ClassGUI].Checked}
				{
					This.ManaShield:Set[FALSE]
				}
				break

				/** Get settings from the Arcane tab **/
				case CounterSpell
				if ${UIElement[chkCounterSpell@Arcane@Pages@ClassGUI].Checked}
				{
					This.CounterSpell:Set[TRUE]
				}
				if !${UIElement[chkCounterSpell@Arcane@Pages@ClassGUI].Checked}
				{
					This.CounterSpell:Set[FALSE]
				}
				break
				case Presence
				if ${UIElement[chkPresence@Arcane@Pages@ClassGUI].Checked}
				{
					This.Presence:Set[TRUE]
				}
				if !${UIElement[chkPresence@Arcane@Pages@ClassGUI].Checked}
				{
					This.Presence:Set[FALSE]
				}
				break
				case POMonPull
				if ${UIElement[chkPOMonPull@Arcane@Pages@ClassGUI].Checked}
				{
					This.POMonPull:Set[TRUE]
				}
				if !${UIElement[chkPOMonPull@Arcane@Pages@ClassGUI].Checked}
				{
					This.POMonPull:Set[FALSE]
				}
				break
				case Slow
				if ${UIElement[chkSlow@Arcane@Pages@ClassGUI].Checked}
				{
					This.Slow:Set[TRUE]
				}
				if !${UIElement[chkSlow@Arcane@Pages@ClassGUI].Checked}
				{
					This.Slow:Set[FALSE]
				}
				break
				case ArcanePower
				if ${UIElement[chkArcanePower@Arcane@Pages@ClassGUI].Checked}
				{
					This.ArcanePower:Set[TRUE]
				}
				if !${UIElement[chkArcanePower@Arcane@Pages@ClassGUI].Checked}
				{
					This.ArcanePower:Set[FALSE]
				}
				break
				case APonPull
				if ${UIElement[chkAPonPull@Arcane@Pages@ClassGUI].Checked}
				{
					This.APonPull:Set[TRUE]
				}
				if !${UIElement[chkAPonPull@Arcane@Pages@ClassGUI].Checked}
				{
					This.APonPull:Set[FALSE]
				}
				break
				case StunBlink
				if ${UIElement[chkStunBlink@Arcane@Pages@ClassGUI].Checked}
				{
					This.StunBlink:Set[TRUE]
				}
				if !${UIElement[chkStunBlink@Arcane@Pages@ClassGUI].Checked}
				{
					This.StunBlink:Set[FALSE]
				}
				break

				/** Get settings from the Fire tab **/
				case DragonBreath
				if ${UIElement[chkDragonBreath@Fire@Pages@ClassGUI].Checked}
				{
					This.DragonBreath:Set[TRUE]
				}
				if !${UIElement[chkDragonBreath@Fire@Pages@ClassGUI].Checked}
				{
					This.DragonBreath:Set[FALSE]
				}
				break
				case BlastWave
				if ${UIElement[chkBlastWave@Fire@Pages@ClassGUI].Checked}
				{
					This.BlastWave:Set[TRUE]
				}
				if !${UIElement[chkBlastWave@Fire@Pages@ClassGUI].Checked}
				{
					This.BlastWave:Set[FALSE]
				}
				break
				case Combustion
				if ${UIElement[chkCombustion@Fire@Pages@ClassGUI].Checked}
				{
					This.Combustion:Set[TRUE]
				}
				if !${UIElement[chkCombustion@Fire@Pages@ClassGUI].Checked}
				{
					This.Combustion:Set[FALSE]
				}
				break

				/** Get settings from the Frost tab **/
				case FrostNova
				if ${UIElement[chkFrostNova@Frost@Pages@ClassGUI].Checked}
				{
					This.FrostNova:Set[TRUE]
				}
				if !${UIElement[chkFrostNova@Frost@Pages@ClassGUI].Checked}
				{
					This.FrostNova:Set[FALSE]
				}
				break
				case ConeOfCold
				if ${UIElement[chkConeOfCold@Frost@Pages@ClassGUI].Checked}
				{
					This.ConeOfCold:Set[TRUE]
				}
				if !${UIElement[chkConeOfCold@Frost@Pages@ClassGUI].Checked}
				{
					This.ConeOfCold:Set[FALSE]
				}
				break
				case IceBarrier
				if ${UIElement[chkIceBarrier@Frost@Pages@ClassGUI].Checked}
				{
					This.IceBarrier:Set[TRUE]
				}
				if !${UIElement[chkIceBarrier@Frost@Pages@ClassGUI].Checked}
				{
					This.IceBarrier:Set[FALSE]
				}
				break
				case WaterElemental
				if ${UIElement[chkWaterElemental@Frost@Pages@ClassGUI].Checked}
				{
					This.WaterElemental:Set[TRUE]
				}
				if !${UIElement[chkWaterElemental@Frost@Pages@ClassGUI].Checked}
				{
					This.WaterElemental:Set[FALSE]
				}
				break
				case IceLance
				if ${UIElement[chkIceLance@Frost@Pages@ClassGUI].Checked}
				{
					This.IceLance:Set[TRUE]
				}
				if !${UIElement[chkIceLance@Frost@Pages@ClassGUI].Checked}
				{
					This.IceLance:Set[FALSE]
				}
				break
				case ColdSnap
				if ${UIElement[chkColdSnap@Frost@Pages@ClassGUI].Checked}
				{
					This.ColdSnap:Set[TRUE]
				}
				if !${UIElement[chkColdSnap@Frost@Pages@ClassGUI].Checked}
				{
					This.ColdSnap:Set[FALSE]
				}
				break
				case IceBlock
				if ${UIElement[chkIceBlock@Frost@Pages@ClassGUI].Checked}
				{
					This.IceBlock:Set[TRUE]
				}
				if !${UIElement[chkIceBlock@Frost@Pages@ClassGUI].Checked}
				{
					This.IceBlock:Set[FALSE]
				}
				break
				case IBHealth
				if ${UIElement[sldIBHealth@Frost@Pages@ClassGUI].Value(exists)}
				{
					This.IBHealth:Set[${UIElement[sldIBHealth@Frost@Pages@ClassGUI].Value}]
				}
				break
				;and finally the Extras tab
				case MakeBand
				if ${UIElement[chkMakeBand@Extras@Pages@ClassGUI].Checked}
				{
					This.MakeBand:Set[TRUE]
				}
				if !${UIElement[chkMakeBand@Extras@Pages@ClassGUI].Checked}
				{
					This.MakeBand:Set[FALSE]
				}
				break
				case Bandage
				if ${UIElement[cmbBandage@Extras@Pages@ClassGUI].SelectedItem.Value(exists)}
				{
					This.Bandage:Set[${UIElement[cmbBandage@Extras@Pages@ClassGUI].SelectedItem}]
				}
				break
				case BandHP
				if ${UIElement[sldBandHP@Extras@Pages@ClassGUI].Value(exists)}
				{
					This.BandHP:Set[${UIElement[sldBandHP@Extras@Pages@ClassGUI].Value}]
				}
				break
				case PotHP
				if ${UIElement[sldPotHP@Extras@Pages@ClassGUI].Value(exists)}
				{
					This.PotHP:Set[${UIElement[sldPotHP@Extras@Pages@ClassGUI].Value}]
				}
				break
				case PotMP
				if ${UIElement[sldPotMP@Extras@Pages@ClassGUI].Value(exists)}
				{
					This.PotMP:Set[${UIElement[sldPotMP@Extras@Pages@ClassGUI].Value}]
				}
				break
				case FB
				if ${UIElement[sldFB@Extras@Pages@ClassGUI].Value(exists)}
				{
					This.FB:Set[${UIElement[sldFB@Extras@Pages@ClassGUI].Value}]
				}
				break
				
				
				case defaultgeneric
				break
			}
		}

		method LoadConfig()
		{
			;Regular stuff
			This.GemMana:Set[${Config.GetSetting["Mage","GemMana"]}]
			This.RestMP:Set[${Config.GetSetting["Mage","RestMP"]}]
			This.BestGem:Set[${Config.GetSetting["Mage","BestGem"]}]
			This.RestHP:Set[${Config.GetSetting["Mage","RestHP"]}]
			This.Wand:Set[${Config.GetSetting["Mage","Wand"]}]
			This.PullWith:Set[${Config.GetSetting["Mage","PullWith"]}]
			This.RandPull:Set[${Config.GetSetting["Mage","RandPull"]}]
			This.TwoPull:Set[${Config.GetSetting["Mage","TwoPull"]}]
			This.CombatCast:Set[${Config.GetSetting["Mage","CombatCast"]}]
			This.PullSecond:Set[${Config.GetSetting["Mage","PullSecond"]}]
			This.RandCom:Set[${Config.GetSetting["Mage","RandCom"]}]
			This.Racial:Set[${Config.GetSetting["Mage","Racial"]}]

			;Buffs
			This.ArcInt:Set[${Config.GetSetting["Mage","ArcInt"]}]
			This.Armor:Set[${Config.GetSetting["Mage","Armor"]}]
			This.FWard:Set[${Config.GetSetting["Mage","FWard"]}]
			This.FrWard:Set[${Config.GetSetting["Mage","FrWard"]}]
			This.Dampen:Set[${Config.GetSetting["Mage","Dampen"]}]
			This.Amplify:Set[${Config.GetSetting["Mage","Amplify"]}]
			This.CombatEvocation:Set[${Config.GetSetting["Mage","CombatEvocation"]}]
			This.RestEvocation:Set[${Config.GetSetting["Mage","RestEvocation"]}]
			This.ManaShield:Set[${Config.GetSetting["Mage","ManaShield"]}]

			;Arcane
			This.CounterSpell:Set[${Config.GetSetting["Mage","CounterSpell"]}]
			This.Presence:Set[${Config.GetSetting["Mage","Presence"]}]
			This.POMonPull:Set[${Config.GetSetting["Mage","POMonPull"]}]
			This.Slow:Set[${Config.GetSetting["Mage","Slow"]}]
			This.ArcanePower:Set[${Config.GetSetting["Mage","ArcanePower"]}]
			This.APonPull:Set[${Config.GetSetting["Mage","APonPull"]}]
			This.StunBlink:Set[${Config.GetSetting["Mage","StunBlink"]}]

			;Fire
			This.DragonBreath:Set[${Config.GetSetting["Mage","DragonBreath"]}]
			This.BlastWave:Set[${Config.GetSetting["Mage","BlastWave"]}]
			This.Combustion:Set[${Config.GetSetting["Mage","Combustion"]}]

			;Frost
			This.FrostNova:Set[${Config.GetSetting["Mage","FrostNova"]}]
			This.ConeOfCold:Set[${Config.GetSetting["Mage","ConeOfCold"]}]
			This.IceBarrier:Set[${Config.GetSetting["Mage","IceBarrier"]}]
			This.WaterElemental:Set[${Config.GetSetting["Mage","WaterElemental"]}]
			This.IceLance:Set[${Config.GetSetting["Mage","IceLance"]}]
			This.ColdSnap:Set[${Config.GetSetting["Mage","ColdSnap"]}]
			This.IceBlock:Set[${Config.GetSetting["Mage","IceBlock"]}]
			This.IBHealth:Set[${Config.GetSetting["Mage","IBHealth"]}]
			
			;extras
			This.MakeBand:Set[${Config.GetSetting["Mage","MakeBand"]}]
			This.Bandage:Set[${Config.GetSetting["Mage","Bandage"]}]
			This.BandHP:Set[${Config.GetSetting["Mage","BandHP"]}]
			This.PotHP:Set[${Config.GetSetting["Mage","PotHP"]}]
			This.PotMP:Set[${Config.GetSetting["Mage","PotMP"]}]
			This.FB:Set[${Config.GetSetting["Mage","FB"]}]
		}

		method SaveConfig()
		{
			;Regular stuff
			Config:SetSetting[Mage,"GemMana",${This.GemMana}]
			Config:SetSetting[Mage,"RestMP",${This.RestMP}]
			Config:SetSetting[Mage,"BestGem",${This.BestGem}]
			Config:SetSetting[Mage,"RestHP",${This.RestHP}]
			Config:SetSetting[Mage,"Wand",${This.Wand}]
			Config:SetSetting[Mage,"PullWith",${This.PullWith}]
			Config:SetSetting[Mage,"RandPull",${This.RandPull}]
			Config:SetSetting[Mage,"RandPull",${This.TwoPull}]
			Config:SetSetting[Mage,"CombatCast",${This.CombatCast}]
			Config:SetSetting[Mage,"PullSecond",${This.PullSecond}]
			Config:SetSetting[Mage,"RandCom",${This.RandCom}]
			Config:SetSetting[Mage,"Racial",${This.Racial}]

			;Buffs
			Config:SetSetting[Mage,"ArcInt",${This.ArcInt}]
			Config:SetSetting[Mage,"Armor",${This.Armor}]
			Config:SetSetting[Mage,"FWard",${This.FWard}]
			Config:SetSetting[Mage,"FrWard",${This.FrWard}]
			Config:SetSetting[Mage,"Dampen",${This.Dampen}]
			Config:SetSetting[Mage,"Amplify",${This.Amplify}]
			Config:SetSetting[Mage,"CombatEvocation",${This.CombatEvocation}]
			Config:SetSetting[Mage,"RestEvocation",${This.RestEvocation}]
			Config:SetSetting[Mage,"ManaShield",${This.ManaShield}]

			;Arcane
			Config:SetSetting[Mage,"CounterSpell",${This.CounterSpell}]
			Config:SetSetting[Mage,"Presence",${This.Presence}]
			Config:SetSetting[Mage,"POMonPull",${This.POMonPull}]
			Config:SetSetting[Mage,"Slow",${This.Slow}]
			Config:SetSetting[Mage,"ArcanePower",${This.ArcanePower}]
			Config:SetSetting[Mage,"APonPull",${This.APonPull}]
			Config:SetSetting[Mage,"StunBlink",${This.StunBlink}]

			;Fire
			Config:SetSetting[Mage,"DragonBreath",${This.DragonBreath}]
			Config:SetSetting[Mage,"BlastWave",${This.BlastWave}]
			Config:SetSetting[Mage,"Combustion",${This.Combustion}]

			;Frost
			Config:SetSetting[Mage,"FrostNova",${This.FrostNova}]
			Config:SetSetting[Mage,"ConeOfCold",${This.ConeOfCold}]
			Config:SetSetting[Mage,"IceBarrier",${This.IceBarrier}]
			Config:SetSetting[Mage,"WaterElemental",${This.WaterElemental}]
			Config:SetSetting[Mage,"IceLance",${This.IceLance}]
			Config:SetSetting[Mage,"ColdSnap",${This.ColdSnap}]
			Config:SetSetting[Mage,"IceBlock",${This.IceBlock}]
			Config:SetSetting[Mage,"IBHealth",${This.IBHealth}]
			
			;extras
			Config:SetSetting[Mage,"MakeBand",${This.MakeBand}]
			Config:SetSetting[Mage,"Bandage",${This.Bandage}]
			Config:SetSetting[Mage,"BandHP",${This.BandHP}]
			Config:SetSetting[Mage,"PotHP",${This.PotHP}]
			Config:SetSetting[Mage,"PotMP",${This.PotMP}]
			Config:SetSetting[Mage,"FB",${This.FB}]
		}

		/** On Shutdown **/
		method Shutdown()
		{
			This:SaveConfig
			RemoveTrigger Immune
			RemoveTrigger HitMagic
			RemoveTrigger SpellMagic
		}
	}