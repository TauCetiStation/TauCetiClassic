
// Called when the item is in the active hand, and clicked; alternately, there is an 'Click On Held Object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	SSdemo.mark_dirty(src)
	SSdemo.mark_dirty(user)

// No comment
/atom/proc/attackby(obj/item/W, mob/user, params)
	if(SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, W, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return FALSE

/atom/movable/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(.) // Clickplace, no need for attack animation.
		return

	if(!(W.flags & NOATTACKANIMATION))
		user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(W && !(W.flags & NOBLUDGEON))
		visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>")
	SSdemo.mark_dirty(src)
	SSdemo.mark_dirty(W)
	SSdemo.mark_dirty(user)

/mob/living/attackby(obj/item/I, mob/user, params)
	if(!istype(I) || !ismob(user))
		return
	user.SetNextMove(CLICK_CD_MELEE)

	if(user.zone_sel && user.zone_sel.selecting)
		I.attack(src, user, user.zone_sel.selecting)
	else
		I.attack(src, user)

	if(ishuman(user))	//When abductor will hit someone from stelth he will reveal himself
		var/mob/living/carbon/human/H = user
		if(istype(H.wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/V = H.wear_suit
			V.attack_reaction(H, REACTION_INTERACT_ARMED, src)

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(istype(H.wear_suit, /obj/item/clothing/suit))
			var/obj/item/clothing/suit/V = H.wear_suit
			V.attack_reaction(src, REACTION_ATACKED, user)
	SSdemo.mark_dirty(src)
	SSdemo.mark_dirty(I)
	SSdemo.mark_dirty(user)

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity, params)
	return


/obj/item/proc/attack(mob/living/M, mob/living/user, def_zone)
	var/mob/messagesource = M
	if (can_operate(M))        //Checks if mob is lying down on table for surgery
		if (do_surgery(M, user, src))
			return 0

	if(stab_eyes && user.a_intent != I_HELP && (def_zone == O_EYES || def_zone == BP_HEAD))
		if((CLUMSY in user.mutations) && prob(50))
			M = user
		return eyestab(M,user)

	// Knifing
	if(edge)
		for(var/obj/item/weapon/grab/G in M.grabbed_by)
			if(G.assailant == user && G.state >= GRAB_NECK && def_zone == BP_HEAD)
				var/protected = 0
				if(ishuman(M))
					var/mob/living/carbon/human/AH = M
					if(AH.is_in_space_suit())
						protected = 1
				if(!protected)
					//TODO: better alternative for applying damage multiple times? Nice knifing sound?
					var/damage_flags = damage_flags()
					M.apply_damage(20, BRUTE, BP_HEAD, null, damage_flags)
					M.apply_damage(20, BRUTE, BP_HEAD, null, damage_flags)
					M.apply_damage(20, BRUTE, BP_HEAD, null, damage_flags)
					M.adjustOxyLoss(60) // Brain lacks oxygen immediately, pass out
					playsound(src, 'sound/effects/throat_cutting.ogg', VOL_EFFECTS_MASTER)
					flick(G.hud.icon_state, G.hud)
					user.SetNextMove(CLICK_CD_ACTION)
					user.visible_message("<span class='danger'>[user] slit [M]'s throat open with \the [name]!</span>")
					user.attack_log += "\[[time_stamp()]\]<font color='red'> Knifed [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])</font>"
					M.attack_log += "\[[time_stamp()]\]<font color='orange'> Got knifed by [user.name] ([user.ckey]) with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])</font>"
					msg_admin_attack("[key_name(user)] knifed [key_name(M)] with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])", user)
					return

	if (istype(M,/mob/living/carbon/brain))
		messagesource = M:container
	if (length(hitsound))
		playsound(src, pick(hitsound), VOL_EFFECTS_MASTER)
	/////////////////////////
	user.lastattacked = M
	M.lastattacker = user
	user.do_attack_animation(M)

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])</font>"
	msg_admin_attack("[key_name(user)] attacked [key_name(M)] with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])", user)

	var/power = force
	if(HULK in user.mutations)
		power *= 2

	if(!ishuman(M))
		if(isslime(M))
			var/mob/living/carbon/slime/slime = M
			if(prob(25))
				to_chat(user, "<span class='warning'>[src] passes right through [M]!</span>")
				return

			if(power > 0)
				slime.attacked += 10

			if(slime.Discipline && prob(50))	// wow, buddy, why am I getting attacked??
				slime.Discipline = 0

			if(power >= 3)
				if(istype(slime, /mob/living/carbon/slime/adult))
					if(prob(5 + round(power/2)))

						if(slime.Victim)
							if(prob(80) && !slime.client)
								slime.Discipline++
						slime.Victim = null
						slime.anchored = 0

						spawn()
							if(slime)
								slime.SStun = 1
								sleep(rand(5,20))
								if(slime)
									slime.SStun = 0

						spawn(0)
							if(slime)
								slime.canmove = 0
								step_away(slime, user)
								if(prob(25 + power))
									sleep(2)
									if(slime && user)
										step_away(slime, user)
								slime.canmove = 1

				else
					if(prob(10 + power*2))
						if(slime)
							if(slime.Victim)
								if(prob(80) && !slime.client)
									slime.Discipline++

									if(slime.Discipline == 1)
										slime.attacked = 0

								spawn()
									if(slime)
										slime.SStun = 1
										sleep(rand(5,20))
										if(slime)
											slime.SStun = 0

							slime.Victim = null
							slime.anchored = 0


						spawn(0)
							if(slime && user)
								step_away(slime, user)
								slime.canmove = 0
								if(prob(25 + power*4))
									sleep(2)
									if(slime && user)
										step_away(slime, user)
								slime.canmove = 1


		var/showname = "."
		if(user)
			showname = " by [user]."
		if(!(user in viewers(M, null)))
			showname = "."

		if(attack_verb.len)
			messagesource.visible_message("<span class='warning'><B>[M] has been [pick(attack_verb)] with [src][showname] </B></span>")
		else
			messagesource.visible_message("<span class='warning'><B>[M] has been attacked with [src][showname] </B></span>")

		if(!showname && user)
			if(user.client)
				to_chat(user, "<span class='warning'><B>You attack [M] with [src]. </B></span>")



	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		return H.attacked_by(src, user, def_zone)	//make sure to return whether we have hit or miss
	else
		switch(damtype)
			if("brute")
				if(istype(src, /mob/living/carbon/slime))
					M.adjustBrainLoss(power)

				else
					if(prob(33)) // Added blood for whacking non-humans too
						var/turf/simulated/T = M.loc
						if(istype(T))
							T.add_blood_floor(M)
					M.take_bodypart_damage(power)
			if("fire")
				if (!(COLD_RESISTANCE in M.mutations))
					to_chat(M, "Aargh it burns!")
					M.take_bodypart_damage(0, power)

	add_fingerprint(user)
	SSdemo.mark_dirty(src)
	SSdemo.mark_dirty(M)
	SSdemo.mark_dirty(user)
	return 1

/*
[ModifierName]ClickAction procs are called from [ModifierName]Click
and passed to an item held in user's hand, when he clicks on target.

Return TRUE to prevent any other click logic.
*/

/obj/item/proc/ShiftClickAction(atom/target, mob/user)
	return FALSE

/obj/item/proc/CtrlClickAction(atom/target, mob/user)
	return FALSE

/obj/item/proc/CtrlShiftClickAction(atom/target, mob/user)
	return FALSE

/obj/item/proc/AltClickAction(atom/target, mob/user)
	return FALSE
