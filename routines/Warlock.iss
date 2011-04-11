/*
Glave's Openbot Warlock Routine
v .9
It's just a flesh wound!

Changes:
v.9
Immolate added to pull spells
Configurable number of shards if you have no soulbag. It will not let you have less than 5, nor more than your total bagspace
gui cleanup
Howl of Terror added to panic

v.8
Support for not using a pull spell fixed
Changed all combo boxes to sliders
Rudimentary dotting of adds (Siphon Life only for now)

v.7
Removed Fel Domination out of buff phase and into attack
Almost fully commented now

v.6
Check if pet is dead before we chase it
Clear target before buffing unending breath
Soulstone works

v.5
Added Unending Breath as a buff option
Rez sickenss causes you to stand at the graveyard till its gone
Stops casting if stunned
Optimized pullpulse from the mess that it was
Ensures being in range to pet for health funnel
Uses bandages
Does Cannibalize, and Blood Fury racials

Known Issues:
Fear pull won't work yet till pulling ranges are fixed
Dynamic ranges won't work either

*/
objectdef cClass inherits cBase
{
/************************************************************************************************************************************************************************************************
							Vars
************************************************************************************************************************************************************************************************/
	variable string version="Glave's Warlock v.9"
	variable string tagline="It's just a flesh wound!"
	variable int LastBuffCast = 1
	variable int PullTimeDelay = ${LavishScript.RunningTime}
	variable int PetPulled = 1
	variable int MaxCombatRange = 28
	variable guidlist ShardList
	variable guidlist Aggro
	variable string MyPet="Imp"
	variable string RealmChar="${ISXWoW.RealmName}_${Me.Name}_${Me.Class}"
	variable int CorruCast = 1
	variable int AmpCast = 1
	variable int CoACast = 1
	variable int SLCast = 1
	variable int FearCast=1
	variable int ImmoCast = 1
	variable int UACast = 1
	variable int PetSummon = 1
	variable int HSCreated = 1
	variable int SSCreated = 1
	variable int PullRange = 28
	variable int MinPullRange = 10
	variable int Pull = 1
	variable int PullSpellCast = 1
	variable string PullSpell = "Shadow Bolt"
	variable int MinMana = 50
	variable int MinHealth = 60
	variable int HSHealth = 40
	variable int WandHealth = 0
	variable int PanicHealth = 20			/* Health % that I Deathcoil & Fear */
	variable int ComDPMyMana = 85			/* Minimum mana I have before I combat dark pact */
	variable int ComDPPetMana = 15			/* Minimum mana pet has before combat dark pact */
	variable int ComLTHealth = 50			/* Minimum health before I won't life tap in combat */
	variable int ComLTMana = 80			/* Minimum mana before I life tap in combat */
	variable int DrainSoulHP = 30			/* Health amount I begin drain soul if needed */
	variable int DrainLifeHP = 90			/* Minimum health I have before I drain life instead of nuke */
	variable int FunnelPetHP = 50			/* Health Funnel pet if below this during rest */
	variable int FunnelMyHP = 70			/* Minimum health I have in order to health funnel during rest */
	variable int RestDPMyMana = 85			/* Minimum mana I have before I rest dark pact */
	variable int RestDPPetMana = 15			/* Minimum mana pet has before rest dark pact */
	variable int RestLTHealth = 50			/* Minimum health before I won't life tap in rest */
	variable int RestLTMana = 80			/* Minimum mana before I life tap in rest */
	variable int PetWait = 5000				/* Wait this long for pet to pet to aggro */
	variable int VWSackHP = 30
	variable int conflPop = 4000
	variable int ApocWantsShards = 5
	variable string OppositeFaction
	variable bool useCorruption = TRUE
	variable bool useAmp = TRUE
	variable bool FearJuggle = FALSE
	variable bool useCoA = TRUE
	variable bool useSiphonLife = TRUE
	variable bool useUnstableAffliction = TRUE
	variable bool useImmolate = TRUE
	variable bool useConflag = TRUE
	variable bool useSearingPain = TRUE
	variable bool useIncinerate = TRUE
	variable bool useDrainLife = TRUE
	variable bool FearElites = FALSE
	variable bool useUnendingBreath = FALSE
	variable bool useSoulstone = FALSE
	variable bool usePull = TRUE
	variable bool useRestBoth = TRUE
	variable bool WandNoNuke = FALSE
/************************************************************************************************************************************************************************************************
							Main
************************************************************************************************************************************************************************************************/
	method AttackPulse()
	{
		if ${Target.Dead}
		{
			WowScript ClearTarget()
			return
		}
		if ${This.IsStunned}
			return
		if ${Target.Name.NotEqual[${Me.Name}]} && ${Target(exists)}
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
		
;Set your max spell distance based on talents. Unsure if working in latest ob
		This:SetDistances
;Chase down runners
		if ${Target.Distance} > ${This.MaxCombatRange}
		{
			This:Output["Chasing down ${Target.Name}"]
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
			wowpress -hold moveforward 
			return
		}
;Stop moving when in range- Do I still need this??
		if ${Target.Distance}<=${This.MaxCombatRange}
			move -stop
;Use healthstone on low health
		if ${Me.PctHPs} < ${This.HSHealth}
		{
			if ${Item[Healthstone](exists)} && !${This.AmWanding} && !${Me.Action[Shoot].Cooldown}
				Item[Healthstone]:Use
		}
;Sacrifice voidwalker if we need to
		if ${Me.PctHPs} < ${This.VWSackHP}
		{
			if ${Spell["Sacrifice"](exists)}
					WoWScript CastPetAction(5)
		}
;Death coil if they're close and I'm low on health (Need to check if they're targeting me)
		if ${Target.Distance}<=7 && ${Me.PctHPs} < ${This.PanicHealth}
		{
			if ${Me.Action[Death Coil].Usable} && ${Spell[Death Coil](exists)}
			{
				if !${This.AmWanding} && !${Me.Action[Shoot].Cooldown}
				{
					Toon:CastSpell[Death Coil]
					return
				}
				return
			}
;All panic options exhausted, fear it off
			elseif ${This.HaveAdds} && ${Spell[Howl of Terror](exists)}&&${Me.Action[Howl of Terror].Usable} && ${FearCast} < ${LavishScript.RunningTime}
			{
				if !${This.AmWanding} && !${Me.Action[Shoot].Cooldown}
				{
					Toon:CastSpell[Howl of Terror]
					This:Output[Panic:Howl]
					return
				}
				return
			}
			elseif ${Spell[Fear](exists)}&&${Me.Action[Fear].Usable} && ${FearCast} < ${LavishScript.RunningTime}
			{
				if !${This.AmWanding} && !${Me.Action[Shoot].Cooldown}
				{
					Toon:CastSpell[Fear]
					This:Output[Panic:Fear]
					return
				}
				return
			}
		}
		ShardList:Search[-items,-inventory,Soul Shard]
;Stop everything and so I can drain soul when mob is low on health and we need shards
		if ${WoWScript[UnitCastingInfo("player")].NotEqual[Drain Soul]} && ${ShardList.Count}< ${This.NumShards} && ${Target.PctHPs} < ${This.DrainSoulHP} &&${Spell[Drain Soul](exists)}
		{
			WoWScript SpellStopCasting()
			return
		}
;Stop draining soul if the mob gained more health than the threshold for drain soul
		if ${WoWScript[UnitCastingInfo("player")].Equal[Drain Soul]} && ${Target.PctHPs} > ${This.DrainSoulHP}
		{
			WoWScript SpellStopCasting()
			return
		}
;Make sure pet is attacking
    if ${Me.Pet(exists)} && !${Me.Pet.Target(exists)}
    	wowscript PetAttack()
;If I'm not in combat yet, the pet hasn't engaged combat (For waiting until the pet has aggro)
		if !${Me.InCombat}
		{
			PetPulled:Set[${LavishScript.RunningTime} + ${PetWait}]
		}
		
		if ${Me.Casting} || ${Me.GlobalCooldown} > 0 || ${Target.Distance}>${This.MaxCombatRange} || ${PetWait} && ${PetPulled} > ${LavishScript.RunningTime}
			return
;Attack if I'm not wanding- work those melee skills!
		if !${Me.Attacking} && !${Me.Action[Shoot].AutoRepeat} && !${This.WandHealth}
			WoWScript AttackTarget()
;Arcane torrent racial- who the heck added this?
		if ${Me.PctMana} < 85 && ${Spell[Arcane Torrent](exists)} && !${Spell[Arcane Torrent].Cooldown} && ${Me.Buff[Mana Tap].Application} == 3
		{
			Toon:CastSpell[Arcane Torrent]
			This:Output["Arcane Torrent"]
			return
		}
;Get mana from Dark Pact	
		if ${Me.Pet(exists)} && ${Spell[Dark Pact](exists)}
		{
			if ${Me.Pet.PctMana} > ${This.ComDPPetMana} && ${Me.PctMana} < ${This.ComDPMyMana}
			{
				if !${This.AmWanding} && !${Me.Action[Shoot].Cooldown}
				{
					Toon:CastSpell[Dark Pact]
					return
				}
				return
			}
		}
;Get mana from life tap
		if ${Me.PctHPs} > ${ComLTHealth} && ${Me.PctMana} < ${ComLTMana} && ${Spell[Life Tap](exists)}
		{
			if !${This.AmWanding} && !${Me.Action[Shoot].Cooldown}
			{
				Toon:CastSpell[Life Tap]
				This:Output[Life Tap]
				return
			}
			return
		}
;No Pet! Fel Dom and get one if we can
		if !${Me.Pet(exists)}&&${Spell["Summon ${MyPet}"](exists)}
		{
			if ${ShardList.Count}>= 1 || ${This.MyPet.Equal["Imp"]}
			{
				if  ${Me.Action[Fel Domination].Usable} && ${Me.CurrentPower} >= ${Math.Calc[${Spell[Fel Domination].Mana} + ${Spell["Summon ${MyPet}"].Mana}]}
						{
							This:Output[We need a pet, NOW!]
							Toon:CastSpell[Fel Domination]
							Bot.RandomPause:Set[25]
							return
						}
				if ${Me.Buff[Fel Domination](exists)}
				{
					if ${This.MyPet.Equal["Imp"]}&&${PetSummon} < ${LavishScript.RunningTime}
					{
						move -stop
						Toon:CastSpell[Summon Imp]
					}
					elseif ${ShardList.Count}>= 1 &&${PetSummon} < ${LavishScript.RunningTime}
					{
						move -stop
						Toon:CastSpell[Summon ${MyPet}]
					}
					elseif ${PetSummon} < ${LavishScript.RunningTime}
					{
						move -stop
						Toon:CastSpell[Summon Imp]
					}
				}
			}
		}
;Drain soul when mob is low and we need shards
		if ${ShardList.Count}< ${This.NumShards} && ${Target.PctHPs} < ${This.DrainSoulHP} &&${Spell[Drain Soul](exists)}
		{
			if !${This.AmWanding} && !${Me.Action[Shoot].Cooldown}
			{
				Toon:CastSpell[Drain Soul]
				return
			}
			return
		}
;Nightfall has proc'd so throw a insta-shadow bolt
		elseif ${Me.Buff[Shadow Trance](exists)}&&${Me.Action[Shadow Bolt].Usable}&&${Target(exists)}
		{
			if !${This.AmWanding} && !${Me.Action[Shoot].Cooldown}
			{
				Toon:CastSpell[Shadow Bolt]
				return
			}
			return
		}
;Pet is dieing- health funnel it
		elseif ${Me.Pet(exists)} && ${Me.Pet.PctHPs}<= ${This.FunnelPetHP} && ${Me.PctHPs} >= ${This.FunnelMyHP}
		{
			if ${Me.Pet(exists)} && ${Me.Pet.Distance} > 19
			{
				This:Output["Getting in funnel range"]
				Navigator:FaceXYZ[${Me.Pet.X},${Me.Pet.Y},${Me.Pet.Z}]
				wowpress -hold moveforward 
				return
			}
			Toon:CastSpell[Health Funnel]
		}
;Wand it to death at a certain health %
		elseif ${Target.PctHPs} < ${This.WandHealth} && ${Me.Equip[ranged](exists)} && ${Target.Distance}<=30
		{
			if  !${Me.Action[Shoot].AutoRepeat} && !${Me.Action[Shoot].Cooldown}
			{
				Me.Action[Shoot]:Use
				This:Wait[100]
			}
			return
		}
;Fear juggle by keeping it feared no matter what
		if ${FearJuggle} && ${Me.Action[Fear].Usable} && !${Target.Buff[Fear](exists)} && ${FearCast} < ${LavishScript.RunningTime}
		{
			Toon:CastSpell[Fear]
			This:Output[Fear]
			return
		}
;Fear elites away
		if ${FearElites} && (${Target.Classification.Equal["Elite"]} || ${Target.Classification.Equal["RareElite"]}) && ${Spell[Fear](exists)}&&${Me.Action[Fear].Usable} && ${FearCast} < ${LavishScript.RunningTime} && !${Target.Buff[Fear](exists)}
		{
			Toon:CastSpell[Fear]
			This:Output[Fear Elite]
			return
		}
;Mana tap racial- who added this?
		if ${Spell[Mana Tap](exists)} && !${Spell[Mana Tap].Cooldown} && ${Target.CurrentMana} > 0
		{
			Target ${Targeting.TargetCollection.Get[1]}
		  Toon:CastSpell[Mana Tap]
			This:Output["Mana tap"]
			return
		}
;Pop conflagrate- I tested this once.... no idea currently
		if ${useConflag} && ${Target.Buff[Immolate](exists)}  && ${Me.Action[Conflagrate].Usable} && (${ImmoCast}+${conflPop}) < ${LavishScript.RunningTime}
		{
			Toon:CastSpell[Conflagrate]
			This:Output[Conflagrate]
			return
		}
This:DotAdds
;Amplify curse when not on cooldown
		if ${useAmp} && ${Me.Action[Amplify Curse].Usable} && !${Target.Buff[Curse of Agony](exists)}
		{
			Toon:CastSpell[Amplify Curse]
			return
		}
;Curse of Agony - rumored to not always cast
		elseif ${useCoA} && !${Target.Buff[Curse of Agony](exists)}&&${Me.Action[Curse of Agony].Usable}&&${CoACast} < ${LavishScript.RunningTime}&&${AmpCast} < ${LavishScript.RunningTime}
		{
			Toon:CastSpell[Curse of Agony]
			This:Output[Curse of Agony]
			return
		}
;Corruption
		if ${useCorruption} && !${Target.Buff[Corruption](exists)}&&${Me.Action[Corruption].Usable}&&${CorruCast} < ${LavishScript.RunningTime}
		{
			Toon:CastSpell[Corruption]
			This:Output[Corruption]
			return
		}
;Siphon Life
		if ${useSiphonLife} && !${Target.Buff[Siphon Life](exists)}&&${Me.Action[Siphon Life].Usable}&&${SLCast} < ${LavishScript.RunningTime} && !${Target.CreatureType.Equal["Mechanical"]}
		{
			Toon:CastSpell[Siphon Life]
			return
		}
;Unstable Affliction
		if ${useUnstableAffliction} && !${Target.Buff[Unstable Affliction](exists)}&&${Me.Action[Unstable Affliction].Usable}&&${UACast} < ${LavishScript.RunningTime}
		{
			Toon:CastSpell[Unstable Affliction]
			return
		}
;Immolate
		if ${useImmolate} && !${Target.Buff[Immolate](exists)}  && ${Me.Action[Immolate].Usable}&&${ImmoCast} < ${LavishScript.RunningTime}
		{
			Toon:CastSpell[Immolate]
			This:Output[Immolate]
			return
		}
;Drain life
		if ${useDrainLife} && ${Me.Action[Drain Life].Usable} && ${Me.PctHPs} < ${This.DrainLifeHP} && !${Target.CreatureType.Equal["Mechanical"]}
		{
			Toon:CastSpell[Drain Life]
			return
		}
;No direct damage if fear juggling, dots only
		if ${FearJuggle}
		{
			This:Output[Fear Juggling]
			return
		}
;Wand it instead of direct damage spells
		if ${WandNoNuke} && ${Me.Equip[ranged](exists)}  && ${Target.Distance}<=30
		{
			if  !${Me.Action[Shoot].AutoRepeat} && !${Me.Action[Shoot].Cooldown}
			{
				Me.Action[Shoot]:Use
				This:Wait[100]
			}
			return
		}
;Incinerate
		if ${useIncinerate} && ${Me.Action[Incinerate].Usable}
		{
			Toon:CastSpell[Incinerate]
			return
		}
;Searing Pain
		elseif  ${useSearingPain} && ${Me.Action[Searing Pain].Usable}
		{
			Toon:CastSpell[Searing Pain]
			return
		}
;Shadow bolt
		else
		{
			This:Output[Shadow Bolt]
			Toon:CastSpell[Shadow Bolt]
			return
		}
	}
/************************************************************************************************************************************************************************************************
							Buff Pulse and Need
************************************************************************************************************************************************************************************************/
	member NeedBuff()
	{
		if ${Mount.IsMounted} || ${Mount.NeedMount}
			return FALSE
		ShardList:Search[-items,-inventory,Soul Shard]
;Do we have a pet
		if !${Me.Pet(exists)} && ${Spell[Summon ${MyPet}](exists)}
		{
			if ${This.MyPet.Equal["Imp"]}
			{
				return TRUE
			}
			elseif ${Item[Soul Shard](exists)}
			{
				return TRUE
			}
		}
;Do we have a healthstone
		if !${Item[Healthstone](exists)} && ${Spell[Create Healthstone](exists)}
		{
			if ${ShardList.Count} >= 2 && ${Inventory.FreeSlots} >= 2
			{
				return TRUE
			}
		}
;Do we need a soulstone
		if ${useSoulstone} && ${Spell[Create Soulstone](exists)} && !${Me.Buff[Soulstone Resurrection](exists)} && ${WoWScript[GetItemCooldown("${Item[Soulstone].Name}"),1]} == 0
		{
			if ${ShardList.Count} >= 2 && ${Inventory.FreeSlots} >= 2
			{
				return TRUE
			}
		}		
;Does our demon need health
		if ${Me.Pet(exists)} && ${Me.Pet.PctHPs}<=${This.FunnelPetHP} && ${Spell[Health Funnel](exists)} && ${Me.PctHPs} >= ${This.FunnelMyHP}
		{
			return TRUE
		}
;Do we need our armor
		if !${Me.Buff[Fel Armor](exists)} && !${Me.Buff[Demon Armor](exists)} && !${Me.Buff[Demon Skin](exists)}
		{
			if ${Spell[Fel Armor](exists)}
			{
				return TRUE
			}
			elseif ${Spell[Demon Armor](exists)}
			{
				return TRUE
			}
			elseif ${Spell[Demon Skin](exists)}
			{
				return TRUE
			}
		}
;Do we need soul link
		if (!${Me.Buff[Soul Link](exists)} && ${Spell[Soul Link](exists)}) && ${Me.Pet(exists)}
		{
			return TRUE
		}
		if (!${Me.Buff[Unending Breath](exists)} && ${Spell[Unending Breath](exists)}) && ${Me.Action["Unending Breath"].Usable} && ${This.useUnendingBreath}
		{
			return TRUE
		}
		return FALSE
	}
	method BuffPulse()
	{
		if ${Me.PctHPs} == 100 && ${Me.PctMana} == 100
			Toon:Standup
		if ${Me.Casting} || ${Me.Buff[Food](exists)} || ${Me.Buff[Drink](exists)} || ${Math.Calc[${LavishScript.RunningTime} - ${This.LastBuffCast}]} < 100
			return
		Toon:Standup
;Cast armor
		if !${Me.Buff[Demon Skin](exists)} && !${Spell["Demon Armor"](exists)} && !${Spell["Fel Armor"](exists)}
		{
			if ${Toon.EnsureBuff[${Me.GUID},Demon Skin]}
			This.LastBuffCast:Set[${LavishScript.RunningTime} + 1200]
		}
		elseif !${Me.Buff[Demon Armor](exists)} && !${Spell["Fel Armor"](exists)}
		{
			if ${Toon.EnsureBuff[${Me.GUID},Demon Armor]}
			This.LastBuffCast:Set[${LavishScript.RunningTime} + 1200]
		}
		elseif !${Me.Buff[Fel Armor](exists)}
		{
			if ${Toon.EnsureBuff[${Me.GUID},Fel Armor]}
			This.LastBuffCast:Set[${LavishScript.RunningTime} + 1200]
		}
;Make healthstone
		ShardList:Search[-items,-inventory,Soul Shard]
		if !${Item[Healthstone](exists)} && ${ShardList.Count}>= 2 && ${This.HSCreated} < ${LavishScript.RunningTime}
		{
			move -stop
			Toon:CastSpell[Create Healthstone]
		}
;Make and use soulstone
		if ${useSoulstone}
		{
			WowScript ClearTarget()
			if !${Item[Soulstone](exists)} && ${ShardList.Count}>= 2 && ${This.SSCreated} < ${LavishScript.RunningTime}
			{
				move -stop
				Toon:CastSpell[Create Soulstone]
			}
			elseif ${Item[Soulstone](exists)} && !${Me.Buff[Soulstone Resurrection](exists)} && ${WoWScript[GetItemCooldown("${Item[Soulstone].Name}"),1]} == 0
			{
				move -stop
				Item[Soulstone]:Use
				This.LastBuffCast:Set[${LavishScript.RunningTime} + 3200]
			}
		}
;Summon a demon
		if !${Me.Pet(exists)}&&${Spell["Summon ${MyPet}"](exists)}
		{
			;if ${Me.Action[Fel Domination].Usable}
			;{
			;	move -stop
			;	Toon:CastSpell[Fel Domination]
			;	This.LastBuffCast:Set[${LavishScript.RunningTime} + 1200]
			;	return
			;}
			if ${This.MyPet.Equal["Imp"]}&&${PetSummon} < ${LavishScript.RunningTime}
			{
				move -stop
				Toon:CastSpell[Summon Imp]
			}
			elseif ${ShardList.Count}>= 1 &&${PetSummon} < ${LavishScript.RunningTime}
			{
				move -stop
				Toon:CastSpell[Summon ${MyPet}]
			}
			elseif ${PetSummon} < ${LavishScript.RunningTime}
			{
				move -stop
				Toon:CastSpell[Summon Imp]
			}
		}
;Health funnel the pet or tell voidwalker to consume shadows
		elseif ${Me.Pet(exists)} && ${Me.Pet.PctHPs}<= ${This.FunnelPetHP} && ${Me.PctHPs} >= ${This.FunnelMyHP} && ${PetSummon} < ${LavishScript.RunningTime}
		{
			move -stop
			Toon:CastSpell[Health Funnel]
			if ${Spell["Consume Shadows"](exists)}
				WoWScript CastPetAction(6)
		}
;Cast soul link
		if !${Me.Buff[Soul Link](exists)} && ${Me.Pet(exists)} && ${Spell["Soul Link"](exists)}
		{
			Toon:CastSpell[Soul Link]
			This.LastBuffCast:Set[${LavishScript.RunningTime} + 1200]
		}
;Cast unending breath
		if !${Me.Buff[Unending Breath](exists)} && ${Spell["Unending Breath"](exists)} && ${This.useUnendingBreath}
		{
			if ${Toon.EnsureBuff[${Me.GUID},Unending Breath]}
			This.LastBuffCast:Set[${LavishScript.RunningTime} + 1200]
		}
	}
/************************************************************************************************************************************************************************************************
							Rest Pulse and Need
************************************************************************************************************************************************************************************************/
	member NeedRest()
	{
		if ${Me.Buff[Resurrection Sickness](exists)}
			return TRUE
		if ${Me.Pet.Casting(exists)}
			return TRUE
		if ${Me.PctHPs} == 100 && ${Me.PctMana} == 100
			return FALSE
		if ${Me.Pet.PctHPs}<=${This.FunnelPetHP} && ${Me.PctHPs} < ${This.FunnelMyHP}
			return TRUE
;I think this is where I tap while moving and not causing a buffstate
		if ${Me.Pet(exists)} && ${Spell[Dark Pact](exists)} && ${Me.Action[Dark Pact].Usable} && !${Me.Buff[Drink](exists)} && !${Me.Buff[Food](exists)} && !${Me.Casting}
		{
			if ${Me.Pet.PctMana} > ${This.RestDPPetMana} && ${Me.PctMana} < ${This.RestDPMyMana}
			{
				Toon:CastSpell[Dark Pact]
				return FALSE
			}
		}
		if ${Me.PctHPs} > ${This.RestLTHealth} && ${Me.PctMana} < ${This.RestLTMana} &&${Spell[Life Tap](exists)}&&${Me.Action[Life Tap].Usable} && !${Me.Buff[Drink](exists)} && !${Me.Buff[Food](exists)} && !${Me.Casting}
		{
			Toon:CastSpell[Life Tap]
			return FALSE
		}
;Health AND mana must both need replenishing to trigger a rest here
		if ${useRestBoth}
		{
			if ${Me.PctHPs} < ${This.MinHealth} && ${Me.PctMana} < ${This.MinMana} || ${Me.Buff[Food](exists)} || ${Me.Buff[Drink](exists)}
			{
				return TRUE
			}
		}
		else
		{
			if ${Me.PctHPs} < ${This.MinHealth} || ${Me.PctMana} < ${This.MinMana} || ${Me.Buff[Food](exists)} || ${Me.Buff[Drink](exists)}
				return TRUE
		}
		return FALSE
	}
	method RestPulse()
	{
		if ${Me.Casting}
			return
		/* bandage if you got em */
		if ${Me.PctHPs} < ${This.MinHealth} && ${Toon.canBandage} && !${Me.Sitting}
		{
			Toon:Bandage
			return
		}
;Cannibalize- this is a bit buggy, it wants to eat elementals?
		if ${Me.Race.Equal["Undead"]} && !${Me.Sitting} 
		{
			if ${Me.PctHPs} < ${This.MinHealth} && ${Toon.canCast[Cannibalize]} && (${Object[-dead,-humanoid,-range 0-5](exists)} || ${Object[-dead,-undead,-range 0-5](exists)})
			{
				Toon:CastSpell["Cannibalize"]
				This:Output["Cannibalize"]
				return
			}
		}
		if !${Me.Buff[Drink](exists)} && ${Me.PctMana} < 90
		{
			Consumable:useDrink
		}
		if !${Me.Buff[Food](exists)} && ${Me.PctHPs} < 90
		{
			Consumable:useFood
		}
	}
/************************************************************************************************************************************************************************************************
							Core
************************************************************************************************************************************************************************************************/
	;------------------
	;--- Flee SetUp ---
	;------------------
	
	variable bool HookFlee = FALSE
	method FleePulse()
	{
		; stuff to do while fleeing		
	}
	member IsStunned()
		{
			variable int i
				for (i:Set[0]; ${i} < 20; i:Inc)
				{
					if ${Me.Buff[${i}].Harmful} && ${Me.Buff[${i}].Mechanic.Equal[stunned]}
					{
						return TRUE
					}
				}
			return FALSE
		}
	member IsFeared()
		{
			variable int i
				for (i:Set[0]; ${i} < 20; i:Inc)
				{
					if ${Me.Buff[${i}].Harmful} && ${Me.Buff[${i}].Mechanic.Equal[stunned]}
					{
						return TRUE
					}
				}
			return FALSE
		}
;Safe to rez from SS? UNUSED as of yet
	member CanUseSS()
	{
			if ${Navigator.PointIsSafe[${Me.X},${Me.Y},${Me.Z}]}
			{
					return TRUE
			}
		return FALSE
	}
	member NeedDead()
	{
		return TRUE
	}
;This doesn't release if they don't have a SS
	method DeadPulse()
	{
			This:Output["Dead Pulse"]
			Bot.RandomPause:Set[25]
			if ${Me.Buff[Soulstone Resurrection](exists)}
				WoWScript UseSoulstone()
			else
				WoWScript RepopMe()
	}
;What is this and where did it come from? UNUSED
	member GotAggro()
	{
		Aggro:Clear
		Aggro:Search[-units,-nearest,-aggro,-alive,-range 0-30]
		if ${Aggro.Count} >= ${This.inScreamAtMobCount}
		{
			This:Debug[Aggro: I have aggro!]
			return TRUE
		}
		return FALSE
	}
;Dynamic range adjustment based on talents
	member GetSpellRange(int base, string spellTree)
	{
		if ${spellTree.Equal[affl]}
		{
			return ${Math.Calc[${base}*(1+(0.1*${Me.Talent[Grim Reach]}))-1].Round}
		}
		if ${spellTree.Equal[destro]}
		{
			return ${Math.Calc[${base}*(1+(0.1*${Me.Talent[Destructive Reach]}))-1].Round}
		}
		return ${base}
	}
;Test for wanding and turn it off- possibly broken now
	member AmWanding()
	{
		if ${Me.Action[Shoot].AutoRepeat}
		{
			This:Debug["Turning Wand Off"]
			WoWScript SpellStopCasting()
			return TRUE
		}
		return FALSE
	}
	method PullPulse()
	{
		if ${PullTimeDelay}>${LavishScript.RunningTime}
		{
			; We shouldnt do anything
			Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
			return
		}
		if !${Toon.ValidTarget[${Target.GUID}]}
		{
			; ensure we target is valid
			This:Output["I need a target"]
			Toon:NeedTarget[1]
			if ${Me.Pet(exists)}
				{
					wowscript PetFollow()
				}
			return
		}		
		if !${Toon.TargetIsBestTarget}
		{
			; ensure our target is the best target
			This:Output["Target is no longer best target, aquire new target."]
			Toon:BestTarget
			return
		}
		; If I am currently casting or have global cooldown return
		if ${Me.Casting} || ${Me.GlobalCooldown}
		{
			return
		}
		if !${Toon.withinRanged[TRUE]}
		{
			Toon:ToRanged
			return
		}
		if ${Movement.Speed}
		{
			move -stop
			return
		}
		; Tell the pet to attack
		if ${Me.Pet(exists)}
		{
			wowscript PetAttack()
			PetPulled:Set[${LavishScript.RunningTime} + ${PetWait}]
		}
		; Bust Blood Fury if we got it and we can
		if ${Spell[Blood Fury](exists)} && !${Spell[Blood Fury].Cooldown}
		{
			Toon:CastSpell["Blood Fury"]
			return
		}		
		; Pull it		
		Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]
		if !${This.usePull}
		{
			This:AttackPulse()
			return
		}
		else
		{
			Toon:CastSpell["${This.PullSpell}"]
			This:Output[Pull:${This.PullSpell}]
			PullTimeDelay:Set[${Math.Calc[ ${LavishScript.RunningTime} + ${Spell[${This.PullSpell}].CastTime} + 1000 ]}]
		}
	}
	method SetDistances()
	{
		if (${WandHealth} || ${WandNoNuke}) && ${Me.Equip[ranged](exists)}
		{
			This.MaxCombatRange:Set[29]
		}
		elseif  ${This.GetSpellRange[30, "affl"]} < ${This.GetSpellRange[30, "destro"]}
		{
			This.MaxCombatRange:Set[${This.GetSpellRange[30, "affl"]}]
		}
		else
		{
			This.MaxCombatRange:Set[${This.GetSpellRange[30, "destro"]}]
		}
		if ${This.PullSpell.Equal["Fear"]}
		{
			This.MaxPullRange:Set[${This.GetSpellRange[20, "affl"]}]
		}
		else
		{
			This.MaxPullRange:Set[${This.GetSpellRange[30, "destro"]}]
		}
	}

;How many shards do we need to fill our shard bag (defaults to 5 if no shard bag)
	member NumShards()
	{
		variable int Bags = 0
		variable int Slots = 0
		do
		{
			if ${Inventory.GetBagType[${Me.Bag[${Bags}].Name}].Equal["lock"]}
			{
				Slots:Inc[${Me.Bag[${Bags}].Slots}]
			}
		}
		while ${Me.Bag[${Bags:Inc}](exists)}
		if ${Slots}==0
		{
			Slots:Set[${This.ApocWantsShards}]
		}
		return ${Slots}
	}
;Catches spells on successful cast and sets timers to avoid double casting
	method CastCheck(string eventid , text, Who, SpellCast)
	{
		if ${SpellCast.Equal[Corruption]}
		{
			CorruCast:Set[${LavishScript.RunningTime} + 800]
		}
		if ${SpellCast.Equal[Amplify Curse]}
		{
			This:Debug["Amplify Curse successfully cast"]
			AmpCast:Set[${LavishScript.RunningTime} + 800]
		}
		if ${SpellCast.Equal[Curse of Agony]}
		{
			This:Debug["CoA successfully cast"]
			CoACast:Set[${LavishScript.RunningTime} + 800]
		}
		if ${SpellCast.Equal[Siphon Life]}
		{
			This:Debug["SL successfully cast"]
			SLCast:Set[${LavishScript.RunningTime} + 800]
		}
		if ${SpellCast.Equal[Immolate]}
		{
			This:Debug["Immolate successfully cast"]
			ImmoCast:Set[${LavishScript.RunningTime} + 800]
		}
		if ${SpellCast.Equal[Unstable Affliction]}
		{
			This:Debug["UA successfully cast"]
			UACast:Set[${LavishScript.RunningTime} + 800]
		}
		if ${SpellCast.Equal[Summon Imp]}
		{
			This:Debug["Imp successfully cast"]
			PetSummon:Set[${LavishScript.RunningTime} + 1500]
		}
		if ${SpellCast.Equal[Summon Voidwalker]}
		{
			This:Debug["VW successfully cast"]
			PetSummon:Set[${LavishScript.RunningTime} + 1500]
		}
		if ${SpellCast.Equal[Summon Succubus]}
		{
			This:Debug["Succubus successfully cast"]
			PetSummon:Set[${LavishScript.RunningTime} + 1500]
		}
		if ${SpellCast.Equal[Summon Felhunter]}
		{
			This:Debug["Felpup successfully cast"]
			PetSummon:Set[${LavishScript.RunningTime} + 1500]
		}
		if ${SpellCast.Equal[Summon Felguard]}
		{
			This:Debug["Felguard successfully cast"]
			PetSummon:Set[${LavishScript.RunningTime} + 1500]
		}
		if ${SpellCast.Equal[Create Healthstone]}
		{
			This:Debug["Healthstone created"]
			HSCreated:Set[${LavishScript.RunningTime} + 3000]
		}
		if ${SpellCast.Equal[Create Soulstone]}
		{
			This:Debug["Soulstone created"]
			SSCreated:Set[${LavishScript.RunningTime} + 3000]
		}
		if ${SpellCast.Equal[Fear]}
		{
			This:Debug["Fear successfully cast"]
			FearCast:Set[${LavishScript.RunningTime} + 5000]
			PullSpellCast:Set[${LavishScript.RunningTime} + 1500]
		}
		if ${SpellCast.Equal[Howl of Terror]}
		{
			This:Debug["Howl of Terror successfully cast"]
			FearCast:Set[${LavishScript.RunningTime} + 5000]
		}
		if ${SpellCast.Equal[Shadow Bolt]}
		{
			This:Debug["Shadow Bolt successfully cast"]
			PullSpellCast:Set[${LavishScript.RunningTime} + 1500]
		}
	}
	member HaveAdds()
	{
		variable guidlist AggroList
		AggroList:Clear
		AggroList:Search[-units,-nearest,-aggro,-alive,-range 0-30]
		if ${AggroList.Count} >= 2
			return TRUE
		else
			return FALSE
	}
	method DotAdds()
	{
		if ${This.HaveAdds}
		{
			variable guidlist AggroList
			AggroList:Clear
			AggroList:Search[-units,-nearest,-aggro,-alive,-range 0-30]
			variable int i
			for (i:Set[1]; ${i}<=${AggroList.Count}; i:Inc)
			{
				if ${Toon.ValidTarget[${AggroList.GUID[${i}]}]}
				{
					if !${Unit[${AggroList.GUID[${i}]}].Buff[Siphon Life](exists)}
					{
						target ${AggroList.GUID[${i}]}
						Toon:CastSpell[Siphon Life]
						This:Output[Add: Siphon Life]
					}
				}
			}
		}
	}
/************************************************************************************************************************************************************************************************
							Load and Save
************************************************************************************************************************************************************************************************/
	method Initialize()
	{
		LavishScript:RegisterEvent[TOON_GUI_CHANGE]
		LavishScript:RegisterEvent[TOON_SLIDE_CHANGE]
		Event[TOON_SLIDE_CHANGE]:AttachAtom[${This.ObjectName}:SliderChange]
		Event[UNIT_SPELLCAST_SUCCEEDED]:AttachAtom[${This.ObjectName}:CastCheck]
		Event[TOON_GUI_CHANGE]:AttachAtom[${This.ObjectName}:ClassGUIChange]
		This:LoadConfig
		This:InitLockGui[spells]
		This:SetDistances
		if ${Me.FactionGroup.Equal[Alliance]}
			OppositeFaction:Set["Horde"]
		if ${Me.FactionGroup.Equal[Horde]}
			OppositeFaction:Set["Alliance"]
		This:Output["${This.version}"]
		This:Output["${This.tagline}"]
	}
	method LoadConfig()
	{
		/** Pet Variables **/
		This.MyPet:Set[${Config.GetSetting["${RealmChar}","MyPet","Imp"]}]    
		This.FunnelPetHP:Set[${Config.GetSetting["${RealmChar}","FunnelPetHP",50]}]
		This.FunnelMyHP:Set[${Config.GetSetting["${RealmChar}","FunnelMyHP",70]}]
		This.PetWait:Set[${Config.GetSetting["${RealmChar}","PetWait",5000]}]
		This.ApocWantsShards:Set[${Config.GetSetting["${RealmChar}","ApocWantsShards",5]}]
		/** Dot Variables **/
		This.useCorruption:Set[${Config.GetSetting["${RealmChar}","useCorruption",TRUE]}]
		This.useAmp:Set[${Config.GetSetting["${RealmChar}","useAmp",TRUE]}]
		This.useCoA:Set[${Config.GetSetting["${RealmChar}","useCoA",TRUE]}]
		This.useSiphonLife:Set[${Config.GetSetting["${RealmChar}","useSiphonLife",TRUE]}]
		This.useUnstableAffliction:Set[${Config.GetSetting["${RealmChar}","useUnstableAffliction",TRUE]}]
		This.useImmolate:Set[${Config.GetSetting["${RealmChar}","useImmolate",TRUE]}]
		/** Direct Damage Variables **/
		This.WandNoNuke:Set[${Config.GetSetting["${RealmChar}","WandNoNuke",FALSE]}]
		This.useSearingPain:Set[${Config.GetSetting["${RealmChar}","useSearingPain",TRUE]}]
		This.useIncinerate:Set[${Config.GetSetting["${RealmChar}","useIncinerate",TRUE]}]
		This.useDrainLife:Set[${Config.GetSetting["${RealmChar}","useDrainLife",TRUE]}]
		This.useConflag:Set[${Config.GetSetting["${RealmChar}","useConflag",TRUE]}]
		This.conflPop:Set[${Config.GetSetting["${RealmChar}","conflPop",4000]}]
		/** Lifetap Variables **/
		This.ComLTHealth:Set[${Config.GetSetting["${RealmChar}","ComLTHealth",50]}]
		This.ComLTMana:Set[${Config.GetSetting["${RealmChar}","ComLTMana",80]}]
		This.RestLTHealth:Set[${Config.GetSetting["${RealmChar}","RestLTHealth",50]}]
		This.RestLTMana:Set[${Config.GetSetting["${RealmChar}","RestLTMana",80]}]		
		/** Darkpact Variables **/
		This.ComDPPetMana:Set[${Config.GetSetting["${RealmChar}","ComDPPetMana",15]}]
		This.ComDPMyMana:Set[${Config.GetSetting["${RealmChar}","ComDPMyMana",85]}]
		This.RestDPPetMana:Set[${Config.GetSetting["${RealmChar}","RestDPPetMana",15]}]
		This.RestDPMyMana:Set[${Config.GetSetting["${RealmChar}","RestDPMyMana",85]}]
		/** Vitality Variables **/
		This.MinMana:Set[${Config.GetSetting["${RealmChar}","MinMana",50]}]
		This.MinHealth:Set[${Config.GetSetting["${RealmChar}","MinHealth",60]}]
		This.useRestBoth:Set[${Config.GetSetting["${RealmChar}","useRestBoth",TRUE]}]
		This.DrainLifeHP:Set[${Config.GetSetting["${RealmChar}","DrainLifeHP",90]}]
		This.HSHealth:Set[${Config.GetSetting["${RealmChar}","HSHealth",40]}]
		This.PanicHealth:Set[${Config.GetSetting["${RealmChar}","PanicHealth",20]}]
		This.VWSackHP:Set[${Config.GetSetting["${RealmChar}","VWSackHP",30]}]
		/** Misc Variables **/
		This.usePull:Set[${Config.GetSetting["${RealmChar}","usePull",TRUE]}]
		/* This.PullRange:Set[${Config.GetSetting["${RealmChar}","PullRange",30]}] */
		This.PullSpell:Set[${Config.GetSetting["${RealmChar}","PullSpell","Shadow Bolt"]}]
		This.MaxCombatRange:Set[${Config.GetSetting["${RealmChar}","MaxCombatRange",28]}]
		This.FearJuggle:Set[${Config.GetSetting["${RealmChar}","FearJuggle",FALSE]}]
		This.FearElites:Set[${Config.GetSetting["${RealmChar}","FearElites",FALSE]}]
		This.useUnendingBreath:Set[${Config.GetSetting["${RealmChar}","useUnendingBreath",FALSE]}]
		This.useSoulstone:Set[${Config.GetSetting["${RealmChar}","useSoulstone",FALSE]}]
		This.DrainSoulHP:Set[${Config.GetSetting["${RealmChar}","DrainSoulHP",30]}]
		This.WandHealth:Set[${Config.GetSetting["${RealmChar}","WandHealth",30]}]
	}
	method SaveConfig()
	{
		/** Pet Variables **/
		Config:SetSetting["${RealmChar}","MyPet",${This.MyPet}]
		Config:SetSetting["${RealmChar}","FunnelPetHP",${This.FunnelPetHP}]
		Config:SetSetting["${RealmChar}","FunnelMyHP",${This.FunnelMyHP}]
		Config:SetSetting["${RealmChar}","PetWait",${This.PetWait}]
		Config:SetSetting["${RealmChar}","ApocWantsShards",${This.ApocWantsShards}]
		/** Dot Variables **/
		Config:SetSetting["${RealmChar}","useCorruption",${This.useCorruption}]
		Config:SetSetting["${RealmChar}","useAmp",${This.useAmp}]
		Config:SetSetting["${RealmChar}","useCoA",${This.useCoA}]
		Config:SetSetting["${RealmChar}","useSiphonLife",${This.useSiphonLife}]
		Config:SetSetting["${RealmChar}","useUnstableAffliction",${This.useUnstableAffliction}]
		Config:SetSetting["${RealmChar}","useImmolate",${This.useImmolate}]
		/** Direct Damage Variables **/
		Config:SetSetting["${RealmChar}","WandNoNuke",${This.WandNoNuke}]
		Config:SetSetting["${RealmChar}","useSearingPain",${This.useSearingPain}]
		Config:SetSetting["${RealmChar}","useIncinerate",${This.useIncinerate}]
		Config:SetSetting["${RealmChar}","useDrainLife",${This.useDrainLife}]
		Config:SetSetting["${RealmChar}","useConflag",${This.useConflag}]
		Config:SetSetting["${RealmChar}","conflPop",${This.conflPop}]
		/** Lifetap Variables **/
		Config:SetSetting["${RealmChar}","ComLTHealth",${This.ComLTHealth}]
		Config:SetSetting["${RealmChar}","ComLTMana",${This.ComLTMana}]
		Config:SetSetting["${RealmChar}","RestLTHealth",${This.RestLTHealth}]
		Config:SetSetting["${RealmChar}","RestLTMana",${This.RestLTMana}]
		/** Darkpact Variables **/
		Config:SetSetting["${RealmChar}","ComDPPetMana",${This.ComDPPetMana}]
		Config:SetSetting["${RealmChar}","ComDPMyMana",${This.ComDPMyMana}]
		Config:SetSetting["${RealmChar}","RestDPPetMana",${This.RestDPPetMana}]
		Config:SetSetting["${RealmChar}","RestDPMyMana",${This.RestDPMyMana}]
		/** Vitality Variables **/
		Config:SetSetting["${RealmChar}","MinMana",${This.MinMana}]
		Config:SetSetting["${RealmChar}","MinHealth",${This.MinHealth}]
		Config:SetSetting["${RealmChar}","useRestBoth",${This.useRestBoth}]
		Config:SetSetting["${RealmChar}","DrainLifeHP",${This.DrainLifeHP}]
		Config:SetSetting["${RealmChar}","HSHealth",${This.HSHealth}]
		Config:SetSetting["${RealmChar}","PanicHealth",${This.PanicHealth}]
		Config:SetSetting["${RealmChar}","VWSackHP",${This.VWSackHP}]
		/** Misc Variables **/
		Config:SetSetting["${RealmChar}","usePull",${This.usePull}]
		/* Config:SetSetting["${RealmChar}","PullRange",${This.PullRange}] */
		Config:SetSetting["${RealmChar}","PullSpell",${This.PullSpell}]
		Config:SetSetting["${RealmChar}","MaxCombatRange",${This.MaxCombatRange}]
		Config:SetSetting["${RealmChar}","FearJuggle",${This.FearJuggle}]
		Config:SetSetting["${RealmChar}","FearElites",${This.FearElites}]
		Config:SetSetting["${RealmChar}","useUnendingBreath",${This.useUnendingBreath}]
		Config:SetSetting["${RealmChar}","useSoulstone",${This.useSoulstone}]
		Config:SetSetting["${RealmChar}","DrainSoulHP",${This.DrainSoulHP}]
		Config:SetSetting["${RealmChar}","WandHealth",${This.WandHealth}]
	}
	method Shutdown()
	{
		This:SaveConfig
		Event[UI_ERROR_MESSAGE]:DetachAtom[${This.ObjectName}:ErrorMessage]
		Event[TOON_GUI_VISIBLE]:Unregister
		Event[UNIT_SPELLCAST_SUCCEEDED]:DetachAtom[${This.ObjectName}:CastCheck]
		Event[TOON_SLIDE_CHANGE]:DetachAtom[${This.ObjectName}:SliderChange]
		Event[TOON_GUI_CHANGE]:DetachAtom[${This.ObjectName}:ClassGUIChange]
		Event[TOON_GUI_CHANGE]:Unregister
		Event[TOON_SLIDE_CHANGE]:Unregister
	}
/************************************************************************************************************************************************************************************************
							GUI
************************************************************************************************************************************************************************************************/

	method SliderChange(string Action)
	{
		variable int Value
		switch ${Action}
		{
			case wandmonsterhealth
			Value:Set[${UIElement[sldWandMonsterHealth@Spells@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.WandHealth:Set[${Value}]
				UIElement[txtWandMonsterHealth@Spells@Pages@ClassGUI]:SetText["Wand Monster at ${Value} pct"]
			}
			else
			{
				This.WandHealth:Set[0]
				UIElement[txtWandMonsterHealth@Spells@Pages@ClassGUI]:SetText["Disabled"]
			}
			break
			case petaggrowait
			Value:Set[${UIElement[sldPetAggroWait@Pet@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.PetWait:Set[${Math.Calc[${Value} * 1000]}]
				UIElement[txtPetAggroWait@Pet@Pages@ClassGUI]:SetText["Pet aggros ${Value} secs before attack"]
			}
			else
			{
				This.PetWait:Set[0]
				UIElement[txtPetAggroWait@Pet@Pages@ClassGUI]:SetText["Attack at same time as pet"]
			}
			break
			case funnelpet
			Value:Set[${UIElement[sldFunnelPet@Pet@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.FunnelPetHP:Set[${Value}]
				UIElement[txtFunnelPet@Pet@Pages@ClassGUI]:SetText["Funnel pet at ${Value} pct"]
			}
			else
			{
				This.FunnelPetHP:Set[0]
				UIElement[txtFunnelPet@Pet@Pages@ClassGUI]:SetText["Never heal pet"]
			}
			break
			case funnelme
			Value:Set[${UIElement[sldFunnelMe@Pet@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.FunnelMyHP:Set[${Value}]
				UIElement[txtFunnelMe@Pet@Pages@ClassGUI]:SetText["Funnel if I'm above ${Value} pct health"]
			}
			else
			{
				This.FunnelMyHP:Set[0]
				UIElement[txtFunnelMe@Pet@Pages@ClassGUI]:SetText["Funnel regardless of my health"]
			}
			break
			case comlifetapmana
			Value:Set[${UIElement[sldLTCMyMana@Vitality@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.ComLTMana:Set[${Value}]
				UIElement[txtLTCMyMana@Vitality@Pages@ClassGUI]:SetText["Lifetap if mana is below ${Value} pct during combat"]
			}
			else
			{
				This.ComLTMana:Set[0]
				UIElement[txtLTCMyMana@Vitality@Pages@ClassGUI]:SetText["Never Lifetap"]
			}
			break
			case comlifetaphealth
			Value:Set[${UIElement[sldLTCMyHealth@Vitality@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.ComLTHealth:Set[${Value}]
				UIElement[txtLTCMyHealth@Vitality@Pages@ClassGUI]:SetText["Lifetap if health is above ${Value} pct during combat"]
			}
			else
			{
				This.ComLTHealth:Set[0]
				UIElement[txtLTCMyHealth@Vitality@Pages@ClassGUI]:SetText["Lifetap regardless of health"]
			}
			break
			case restlifetaphealth
			Value:Set[${UIElement[sldLTRMyHealth@Vitality@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.RestLTHealth:Set[${Value}]
				UIElement[txtLTRMyHealth@Vitality@Pages@ClassGUI]:SetText["Lifetap if health is above ${Value} pct out of combat"]
			}
			else
			{
				This.RestLTHealth:Set[0]
				UIElement[txtLTRMyHealth@Vitality@Pages@ClassGUI]:SetText["Lifetap regardless of health"]
			}
			break
			case restlifetapmana
			Value:Set[${UIElement[sldLTRMyMana@Vitality@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.RestLTMana:Set[${Value}]
				UIElement[txtLTRMyMana@Vitality@Pages@ClassGUI]:SetText["Lifetap if mana is below ${Value} pct out of combat"]
			}
			else
			{
				This.RestLTMana:Set[0]
				UIElement[txtLTRMyMana@Vitality@Pages@ClassGUI]:SetText["Never Lifetap"]
			}
			break	
			case sacvw
			Value:Set[${UIElement[sldSacVW@Vitality@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.VWSackHP:Set[${Value}]
				UIElement[txtSacVW@Vitality@Pages@ClassGUI]:SetText["Sacrifice voidwalker when I'm at ${Value} pct"]
			}
			else
			{
				This.VWSackHP:Set[0]
				UIElement[txtSacVW@Vitality@Pages@ClassGUI]:SetText["Never Sacrifice VW"]
			}
			break
			case conflpopwait
			Value:Set[${UIElement[sldConflPop@Spells@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.conflPop:Set[${Math.Calc[${Value} * 1000]}]
				UIElement[txtConflPop@Spells@Pages@ClassGUI]:SetText["Pop Conflagrate ${Value} secs after Immolate"]
			}
			else
			{
				This.conflPop:Set[0]
				UIElement[txtConflPop@Spells@Pages@ClassGUI]:SetText["Pop Conflagrate immediately"]
			}
			break
			case panicat
			Value:Set[${UIElement[sldFearAt@Vitality@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.PanicHealth:Set[${Value}]
				UIElement[lblFearAt@Vitality@Pages@ClassGUI]:SetText["Deathcoil/Fear At: ${Value} pct health"]
			}
			else
			{
				This.PanicHealth:Set[0]
				UIElement[lblFearAt@Vitality@Pages@ClassGUI]:SetText["Never Deathcoil/Fear when health low"]
			}
			break
			case drainsoulat
			Value:Set[${UIElement[sldDrainSoulAt@Vitality@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.DrainSoulHP:Set[${Value}]
				UIElement[lblDrainSoulAt@Vitality@Pages@ClassGUI]:SetText["Drain Soul At: ${Value} pct health"]
			}
			else
			{
				This.DrainSoulHP:Set[0]
				UIElement[lblDrainSoulAt@Vitality@Pages@ClassGUI]:SetText["Never drain souls"]
			}
			break
			case drainlifeat
			Value:Set[${UIElement[sldDrainLifeAt@Vitality@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.DrainLifeHP:Set[${Value}]
				UIElement[lblDrainLifeAt@Vitality@Pages@ClassGUI]:SetText["Drain Life At: ${Value} pct health"]
			}
			else
			{
				This.DrainLifeHP:Set[0]
				UIElement[lblDrainLifeAt@Vitality@Pages@ClassGUI]:SetText["Never drain life"]
			}
			break
			case minhealth
			Value:Set[${UIElement[sldMinHealth@Vitality@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.MinHealth:Set[${Value}]
				UIElement[lblMinHealth@Vitality@Pages@ClassGUI]:SetText["Rest At: ${Value} pct health"]
			}
			else
			{
				This.MinHealth:Set[0]
				UIElement[lblMinHealth@Vitality@Pages@ClassGUI]:SetText["Never rest due to health"]
			}
			break			
			case minmana
			Value:Set[${UIElement[sldMinMana@Vitality@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.MinMana:Set[${Value}]
				UIElement[lblMinMana@Vitality@Pages@ClassGUI]:SetText["Rest At: ${Value} pct mana"]
			}
			else
			{
				This.MinMana:Set[0]
				UIElement[lblMinMana@Vitality@Pages@ClassGUI]:SetText["Never rest due to mana"]
			}
			break
			case usehealthstone
			Value:Set[${UIElement[sldUseHealthstone@Vitality@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.HSHealth:Set[${Value}]
				UIElement[lblUseHealthstone@Vitality@Pages@ClassGUI]:SetText["Healthstone At: ${Value} pct health"]
			}
			else
			{
				This.HSHealth:Set[0]
				UIElement[lblUseHealthstone@Vitality@Pages@ClassGUI]:SetText["Never use healthstones"]
			}
			case dpcpet
			Value:Set[${UIElement[sldDPCPetMana@Pet@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.ComDPPetMana:Set[${Value}]
				UIElement[lblDPCPetMana@Pet@Pages@ClassGUI]:SetText["Dark Pact in combat if pet is above: ${Value} pct mana"]
			}
			else
			{
				This.ComDPPetMana:Set[0]
				UIElement[lblDPCPetMana@Pet@Pages@ClassGUI]:SetText["Dark Pact all of pet mana in combat"]
			}
			break
			case dpcme
			Value:Set[${UIElement[sldDPCMyMana@Pet@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.ComDPMyMana:Set[${Value}]
				UIElement[lblDPCMyMana@Pet@Pages@ClassGUI]:SetText["Dark Pact in combat if I'm below: ${Value} pct mana"]
			}
			else
			{
				This.ComDPMyMana:Set[0]
				UIElement[lblDPCMyMana@Pet@Pages@ClassGUI]:SetText["Never Dark Pact in combat"]
			}
			break			
			case dprpet
			Value:Set[${UIElement[sldDPRPetMana@Pet@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.RestDPPetMana:Set[${Value}]
				UIElement[lblDPRPetMana@Pet@Pages@ClassGUI]:SetText["Dark Pact at rest if pet is above: ${Value} pct mana"]
			}
			else
			{
				This.RestDPPetMana:Set[0]
				UIElement[lblDPRPetMana@Pet@Pages@ClassGUI]:SetText["Never Dark Pact at rest"]
			}
			break		
			case dprme
			Value:Set[${UIElement[sldDPRMyMana@Pet@Pages@ClassGUI].Value}]
			if ${Value}
			{
				This.RestDPMyMana:Set[${Value}]
				UIElement[lblDPRMyMana@Pet@Pages@ClassGUI]:SetText["Dark Pact at rest if I'm below: ${Value} pct mana"]
			}
			else
			{
				This.RestDPMyMana:Set[0]
				UIElement[lblDPRMyMana@Pet@Pages@ClassGUI]:SetText["Never Dark Pact at rest"]
			}
			break
			case keepnumshards
			Value:Set[${UIElement[sldNumShards@Pet@Pages@ClassGUI].Value}]
			variable int Bags = 0
			variable int Slots = 0
			variable int TotalSlots = 0
			do
			{
				if ${Inventory.GetBagType[${Me.Bag[${Bags}].Name}].Equal["lock"]}
				{
					Slots:Inc[${Me.Bag[${Bags}].Slots}]
				}
				TotalSlots:Inc[${Me.Bag[${Bags}].Slots}]
			}
			while ${Me.Bag[${Bags:Inc}](exists)}
			if ${Slots}==0 /* We don't have a soulbag, how many do we need? */
			{
				if ${Value}<=4 /* Minimum set to 5 shards */
				{
					This.ApocWantsShards:Set[5]
					UIElement[sldNumShards@Pet@Pages@ClassGUI]:SetValue[5]
				}				
				elseif ${TotalSlots} < ${Value} /* Are you farming more shards than you have space for? */
				{
					This.ApocWantsShards:Set[${TotalSlots}]
					UIElement[sldNumShards@Pet@Pages@ClassGUI]:SetValue[${TotalSlots}]
				}
				else
				{
					This.ApocWantsShards:Set[${Value}]
				}
				UIElement[txtNumShards@Pet@Pages@ClassGUI]:SetText["Farming ${This.ApocWantsShards} shards"]
			}
			else /* We have a soulbag, so let's lock our shards to what it can hold */
			{
				This.ApocWantsShards:Set[${Slots}]
				UIElement[txtNumShards@Pet@Pages@ClassGUI]:SetText["${This.ApocWantsShards} shard soulbag"]
				UIElement[sldNumShards@Pet@Pages@ClassGUI]:SetValue[${Slots}]
			}
			break
			
			
			
			
		}
	}
	method InitLockGui(string tab)
	{
	/** Pet **/
		variable int i = 1
		for (i:Set[1] ; ${i}<=${UIElement[cmbPet@Pet@Pages@ClassGUI].Items} ; i:Inc)
		{
		  if ${This.MyPet.Equal[${UIElement[cmbPet@Pet@Pages@ClassGUI].Item[${i}].Text}]}
			{
				UIElement[cmbPet@Pet@Pages@ClassGUI]:SelectItem[${i}]
			}
		}
		for (i:Set[1] ; ${i}<=${UIElement[cmbDPCPetMana@Pet@Pages@ClassGUI].Items} ; i:Inc)
		{
		  if ${This.ComDPPetMana} == ${UIElement[cmbDPCPetMana@Pet@Pages@ClassGUI].Item[${i}].Value}
			{
				UIElement[cmbDPCPetMana@Pet@Pages@ClassGUI]:SelectItem[${i}]
			}
		}
		for (i:Set[1] ; ${i}<=${UIElement[cmbDPCMyMana@Pet@Pages@ClassGUI].Items} ; i:Inc)
		{
		  if ${This.ComDPMyMana} == ${UIElement[cmbDPCMyMana@Pet@Pages@ClassGUI].Item[${i}].Value}
			{
				UIElement[cmbDPCMyMana@Pet@Pages@ClassGUI]:SelectItem[${i}]
			}
		}
		for (i:Set[1] ; ${i}<=${UIElement[cmbDPRPetMana@Pet@Pages@ClassGUI].Items} ; i:Inc)
		{
		  if ${This.RestDPPetMana} == ${UIElement[cmbDPRPetMana@Pet@Pages@ClassGUI].Item[${i}].Value}
			{
				UIElement[cmbDPRPetMana@Pet@Pages@ClassGUI]:SelectItem[${i}]
			}
		}
		for (i:Set[1] ; ${i}<=${UIElement[cmbDPRMyMana@Pet@Pages@ClassGUI].Items} ; i:Inc)
		{
		  if ${This.RestDPMyMana} == ${UIElement[cmbDPRMyMana@Pet@Pages@ClassGUI].Item[${i}].Value}
			{
				UIElement[cmbDPRMyMana@Pet@Pages@ClassGUI]:SelectItem[${i}]
			}
		}
	/** Vitality **/
		for (i:Set[1] ; ${i}<=${UIElement[cmbDrainLifeAt@Vitality@Pages@ClassGUI].Items} ; i:Inc)
		{
		  if ${This.DrainLifeHP} == ${UIElement[cmbDrainLifeAt@Vitality@Pages@ClassGUI].Item[${i}].Value}
			{
				UIElement[cmbDrainLifeAt@Vitality@Pages@ClassGUI]:SelectItem[${i}]
			}
		}
		for (i:Set[1] ; ${i}<=${UIElement[cmbDrainSoulAt@Vitality@Pages@ClassGUI].Items} ; i:Inc)
		{
		  if ${This.DrainSoulHP} == ${UIElement[cmbDrainSoulAt@Vitality@Pages@ClassGUI].Item[${i}].Value}
			{
				UIElement[cmbDrainSoulAt@Vitality@Pages@ClassGUI]:SelectItem[${i}]
			}
		}
		for (i:Set[1] ; ${i}<=${UIElement[cmbFearAt@Vitality@Pages@ClassGUI].Items} ; i:Inc)
		{
		  if ${This.PanicHealth} == ${UIElement[cmbFearAt@Vitality@Pages@ClassGUI].Item[${i}].Value}
			{
				UIElement[cmbFearAt@Vitality@Pages@ClassGUI]:SelectItem[${i}]
			}
		}
		for (i:Set[1] ; ${i}<=${UIElement[cmbMinHealth@Vitality@Pages@ClassGUI].Items} ; i:Inc)
		{
		  if ${This.MinHealth} == ${UIElement[cmbMinHealth@Vitality@Pages@ClassGUI].Item[${i}].Value}
			{
				UIElement[cmbMinHealth@Vitality@Pages@ClassGUI]:SelectItem[${i}]
			}
		}
		for (i:Set[1] ; ${i}<=${UIElement[cmbMinMana@Vitality@Pages@ClassGUI].Items} ; i:Inc)
		{
		  if ${This.MinMana} == ${UIElement[cmbMinMana@Vitality@Pages@ClassGUI].Item[${i}].Value}
			{
				UIElement[cmbMinMana@Vitality@Pages@ClassGUI]:SelectItem[${i}]
			}
		}
		for (i:Set[1] ; ${i}<=${UIElement[cmbUseHealthstone@Vitality@Pages@ClassGUI].Items} ; i:Inc)
		{
		  if ${This.HSHealth} == ${UIElement[cmbUseHealthstone@Vitality@Pages@ClassGUI].Item[${i}].Value}
			{
				UIElement[cmbUseHealthstone@Vitality@Pages@ClassGUI]:SelectItem[${i}]
			}
		}
		for (i:Set[1] ; ${i}<=${UIElement[cmbUsePullSpell@Spells@Pages@ClassGUI].Items} ; i:Inc)
		{
		  if ${This.PullSpell.Equal[${UIElement[cmbUsePullSpell@Spells@Pages@ClassGUI].Item[${i}].Text}]}
			{
				UIElement[cmbUsePullSpell@Spells@Pages@ClassGUI]:SelectItem[${i}]
			}
		}
		UIElement[sldWandMonsterHealth@Spells@Pages@ClassGUI]:SetValue[${This.WandHealth}]
		UIElement[sldPetAggroWait@Pet@Pages@ClassGUI]:SetValue[${Math.Calc[${This.PetWait} / 1000]}]
		UIElement[sldFunnelPet@Pet@Pages@ClassGUI]:SetValue[${This.FunnelPetHP}]
		UIElement[sldFunnelMe@Pet@Pages@ClassGUI]:SetValue[${This.FunnelMyHP}]
		UIElement[sldLTCMyMana@Vitality@Pages@ClassGUI]:SetValue[${This.ComLTMana}]
		UIElement[sldLTCMyHealth@Vitality@Pages@ClassGUI]:SetValue[${This.ComLTHealth}]
		UIElement[sldLTRMyHealth@Vitality@Pages@ClassGUI]:SetValue[${This.RestLTHealth}]
		UIElement[sldLTRMyMana@Vitality@Pages@ClassGUI]:SetValue[${This.RestLTMana}]
		UIElement[sldSacVW@Vitality@Pages@ClassGUI]:SetValue[${This.VWSackHP}]
		UIElement[sldFearAt@Vitality@Pages@ClassGUI]:SetValue[${This.PanicHealth}]
		UIElement[sldDrainSoulAt@Vitality@Pages@ClassGUI]:SetValue[${This.DrainSoulHP}]
		UIElement[sldDrainLifeAt@Vitality@Pages@ClassGUI]:SetValue[${This.DrainLifeHP}]
		UIElement[sldMinHealth@Vitality@Pages@ClassGUI]:SetValue[${This.MinHealth}]
		UIElement[sldMinMana@Vitality@Pages@ClassGUI]:SetValue[${This.MinMana}]
		UIElement[sldUseHealthstone@Vitality@Pages@ClassGUI]:SetValue[${This.HSHealth}]
		UIElement[sldDPCPetMana@Pet@Pages@ClassGUI]:SetValue[${This.ComDPPetMana}]
		UIElement[sldDPCMyMana@Pet@Pages@ClassGUI]:SetValue[${This.ComDPMyMana}]
		UIElement[sldDPRPetMana@Pet@Pages@ClassGUI]:SetValue[${This.RestDPPetMana}]
		UIElement[sldDPRMyMana@Pet@Pages@ClassGUI]:SetValue[${This.RestDPMyMana}]
		UIElement[sldNumShards@Pet@Pages@ClassGUI]:SetValue[${This.ApocWantsShards}]


	}
	method ClassGUIChange(string Action)
	{
		switch ${Action}
		{
		/** Pet **/
			case selectpet
				if ${UIElement[cmbPet@Pet@Pages@ClassGUI].SelectedItem.Text(exists)}
				{
							This.MyPet:Set[${UIElement[cmbPet@Pet@Pages@ClassGUI].SelectedItem.Text}]
				}
				break
		/** Spells **/
			case usepull
	            	This.usePull:Set[!${This.usePull}]
	            	break

			case wandnuke
	            	This.WandNoNuke:Set[!${This.WandNoNuke}]
	            	break

			case usecorr
	            	This.useCorruption:Set[!${This.useCorruption}]
	            	break

			case useamp
	            	This.useAmp:Set[!${This.useAmp}]
	            	break

			case usecoa
	            	This.useCoA:Set[!${This.useCoA}]
	            	break

			case usesl
	            	This.useSiphonLife:Set[!${This.useSiphonLife}]
	            	break

			case useua
	            	This.useUnstableAffliction:Set[!${This.useUnstableAffliction}]
	            	break

			case useimmo
	            	This.useImmolate:Set[!${This.useImmolate}]
	            	break
	            	
			case useconfl
	            	This.useConflag:Set[!${This.useConflag}]
	            	break

			case usesp
	            	This.useSearingPain:Set[!${This.useSearingPain}]
	            	break

			case usedl
	            	This.useDrainLife:Set[!${This.useDrainLife}]
	            	break

			case useincin
	            	This.useIncinerate:Set[!${This.useIncinerate}]
	            	break

			case usefj
	            	This.FearJuggle:Set[!${This.FearJuggle}]
	            	break

			case fearleet
	            	This.FearElites:Set[!${This.FearElites}]
	            	break

			case usebreath
	            	This.useUnendingBreath:Set[!${This.useUnendingBreath}]
	            	break

			case usesoulstone
	            	This.useSoulstone:Set[!${This.useSoulstone}]
	            	break
	            	
			case pullspell
				if ${UIElement[cmbUsePullSpell@Spells@Pages@ClassGUI].SelectedItem.Text(exists)}
				{
					This.PullSpell:Set[${UIElement[cmbUsePullSpell@Spells@Pages@ClassGUI].SelectedItem.Text}]
					if ${UIElement[cmbUsePullSpell@Spells@Pages@ClassGUI].SelectedItem.Text.Equal["Fear"]}
					{
						This.MaxPullRange:Set[${This.GetSpellRange[20, "affl"]}]
						This.MaxCombatRange:Set[${This.GetSpellRange[20, "affl"]}]
					}
					else
					{
						This.MaxPullRange:Set[${This.GetSpellRange[30, "destro"]}]
						This.MaxCombatRange:Set[${This.GetSpellRange[30, "destro"]}]
					}
				}
				break

		/** Vitality **/
			case useboth
	            	This.useRestBoth:Set[!${This.useRestBoth}]
	            	break
	            	case defaultgeneric
			break
		}
	}
}
