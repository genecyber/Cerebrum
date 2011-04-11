objectdef cClass inherits cBase
{
	;----------------------
	;--- Rest Variables ---
	;----------------------
	variable int RestHP = 80

	;----------------------
	;--- Range Settings ---
	;----------------------
	variable int PullRange = 30
	variable int MaxRanged = 30
	variable int MinRanged = 15
	variable int MaxMelee = 5
	variable int MinMelee = 2


	variable string RVersion = 1.0


	method Initialize()
	{
	}


	member NeedRest()
	{
		if ${Me.InCombat}
		{
			return FALSE
		}
		if ${Me.Buff[Food](exists)}
		{
			if ${Me.PctHPs} < 100
			{
				return TRUE
			}
		}
		if ${Me.Buff[Drink](exists)}
		{
			if ${Me.PctMana} < 100
			{
				return TRUE
			}
		}
		if ${Me.PctHPs} < ${RestHP}
		{
			return TRUE
		}
		return FALSE
	}

	method RestPulse()
	{
		if !${Me.InCombat}
		{
			; If I am sitting and full stand up
			if ${Me.Sitting} && ${Me.PctHPs}==100 && ${Me.PctMana}==100
			{
				wowpress jump
			}
			
			if ${Movement.Speed}
			{
				Move -stop
			}

			if ${Me.Target(exists)}
			{
				WoWScript ClearTarget()
			}

			if ${Me.PctHPs} < ${RestHP} && ${Consumable.HasFood} && !${Me.Buff[Food](exists)}
			{
				Consumable:useFood
			}
		}
	}

	;------------------
	;--- Buff SetUp ---
	;------------------

	member NeedBuff()
	{
		return FALSE
	}

	method BuffPulse()
	{
	}

	;------------------
	;--- Pull SetUp ---
	;------------------

	member NeedPullBuff()
	{
		return FALSE
	}

	method PullBuffPulse()
	{
	}

	;------------------------
	;--- CombatBuff SetUp ---
	;------------------------

	member NeedCombatBuff()
	{
		return FALSE
	}

	method CombatBuffPulse()
	{
	}

	;------------------
	;--- Pull SetUp ---
	;------------------
	member InRange()
	{
		if ${Target.Distance} < 25
		{
			return TRUE
		}
		
		return FALSE
	}

	method PullPulse()
	{
		if !${Me.Target(exists)}
		{
			return
		}
		if ${Me.Target.Dead}
		{
			WoWScript ClearTarget()
			return
		}
		if !${Me.Target.Attackable}
		{
			WoWScript ClearTarget()
			return
		}

		if ${Me.Sitting}
		{
			WoWpress jump
		}

		if ${Target.Distance} == 0
		{
			return
		}
		
		;This:Output["Facing ${Target.GUID} ${Target.Location}"]
		Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]

		; Make sure we are in distance for attacking
		
		; Make sure we are in distance for attacking
		if ${Target.Distance}>${MaxRanged}
		{
			wowpress -hold moveforward
			return
		}

		; Stop if we are
		if ${Target.Distance} > ${MinRanged} && ${Target.Distance}<${MaxRanged} && ${Movement.Speed}
		{
			Move -stop
		}
		
		if ${Me.GlobalCooldown}
		{
			return
		}
		
		Toon:CastSpell[Lightning Bolt]
		WoWScript AttackTarget()
	}

	;--------------------
	;--- Combat SetUp ---
	;--------------------

	method AttackPulse()
	{
		POI.IInteracting:Set[FALSE]

		if !${Target(exists)} || ${Target.GUID.Equal[${Me.GUID}]} || ${Target.Dead}
		{
			This:Output["I need a target"]
			Toon:NeedTarget[1]
		}

		if !${Me.Target(exists)}
		{
			move -stop
			return
		}
		if ${Me.Target.Dead}
		{
			WoWScript ClearTarget()
			move -stop
			return
		}
		if !${Me.Target.Attackable}
		{
			WoWScript ClearTarget()
			move -stop
			return
		}

		if ${Me.Sitting}
		{
			WoWpress jump
		}
		
		if ${Target.Distance} < 6 && ${Movement.Speed}
		{
			move -stop
		}
		if ${Me.Target(exists)} && !${Me.InCombat}
		{
			; Why do I have a target in attack pulse and am not in combat?
			WoWScript ClearTarget()
			return
		}
		;This:Output["Facing ${Target.GUID} ${Target.Location}"]
		Navigator:FaceXYZ[${Target.X},${Target.Y},${Target.Z}]

		; Make sure we are in distance for attacking
		if ${Target.Distance}>${MaxRanged}
		{
			wowpress -hold moveforward
			return
		}
		; Stop if we are
		if ${Target.Distance} > ${MinRanged} && ${Target.Distance}<${MaxRanged} && ${Movement.Speed}
		{
			Move -stop
		}

		if ${Me.InCombat} && !${Me.Attacking}
		{
			WoWScript AttackTarget()
		}

	}
}