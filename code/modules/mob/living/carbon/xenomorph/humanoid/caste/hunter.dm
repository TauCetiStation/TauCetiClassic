/mob/living/carbon/xenomorph/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 180
	health = 180
	storedPlasma = 100
	max_plasma = 150
	icon_state = "alienh_s"	//default invisibility
	var/invisible = FALSE

/mob/living/carbon/xenomorph/humanoid/hunter/atom_init()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	name = "alien hunter ([rand(1, 1000)])"
	real_name = name
	alien_list[ALIEN_HUNTER] += src
	. = ..()

/mob/living/carbon/xenomorph/humanoid/hunter/Destroy()
	alien_list[ALIEN_HUNTER] -= src
	return ..()

/mob/living/carbon/xenomorph/humanoid/hunter/handle_environment()
	if(invisible)	//if the hunter is invisible
		adjustToxLoss(-heal_rate)	//plasma is spent on invisibility
	if(storedPlasma < heal_rate)
		set_m_intent(MOVE_INTENT_RUN)	//get out of invisibility if plasma runs out
	..()

//Hunter verbs
/mob/living/carbon/xenomorph/humanoid/hunter/proc/toggle_leap(message = 1)
	if(resting)
		lay_down()
	leap_on_click = !leap_on_click
	leap_icon.icon_state = "leap_[leap_on_click ? "on":"off"]"
	update_icons()
	if(message)
		if(leap_on_click)
			to_chat(src, "<span class='noticealien'>You will now leap at enemies with a middle click!</span>")
		else
			to_chat(src, "<span class='noticealien'>You will no longer leap at enemies with a middle click!</span>")
	else
		return

/mob/living/carbon/xenomorph/humanoid/hunter/MiddleClickOn(atom/A, params)
	if(next_move <= world.time && leap_on_click)
		leap_at(A)
	else
		..()

#define MAX_ALIEN_LEAP_DIST 7

/mob/living/carbon/xenomorph/humanoid/hunter/proc/leap_at(atom/A)

	if(buckled)
		to_chat(src, "<span class='alertalien'>You cannot leap in your current state.</span>")
		return

	if(pounce_cooldown)
		to_chat(src, "<span class='alertalien'>You are too fatigued to pounce right now!</span>")
		return

	if(leaping) //Leap while you leap, so you can leap while you leap
		return

	if((istype(src.loc, /turf/space)) || (istype(A.loc, /turf/space)))
		to_chat(src, "<span class='alertalien'>It is unsafe to leap without gravity!</span>")
		//It's also extremely buggy visually, so it's balance+bugfix
		return

	if(incapacitated())
		return
	else //Maybe uses plasma in the future, although that wouldn't make any sense...
		if(invisible)
			set_m_intent(MOVE_INTENT_RUN)	//get out of invisibility
		face_atom(A)
		stop_pulling()
		leaping = TRUE
		update_icons()
		throw_at(A, MAX_ALIEN_LEAP_DIST, 1, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, .proc/leap_end))

/mob/living/carbon/xenomorph/humanoid/hunter/proc/leap_end()
	SetNextMove(CLICK_CD_MELEE) // so we can't click again right after leaping.
	leaping = FALSE
	update_icons()

/mob/living/carbon/xenomorph/humanoid/hunter/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!leaping)
		return ..()

	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		var/obj/item/weapon/shield/shield = L.is_in_hands(/obj/item/weapon/shield)
		if(shield && check_shield_dir(hit_atom) && prob(shield.Get_shield_chance() + 20))
			L.visible_message("<span class='danger'>[src] smashed into [L]'s [shield]!</span>", "<span class='userdanger'>[src] pounces on your [shield]!</span>")
			weakened = 2
		else
			L.visible_message("<span class='danger'>[src] pounces on [L]!</span>", "<span class='userdanger'>[src] pounces on you!</span>")
			if(issilicon(L))
				L.Weaken(1) //Only brief stun
			else
				L.Weaken(5)
			sleep(2)  // Runtime prevention (infinite bump() calls on hulks)
			step_towards(src, L)
			toggle_leap(FALSE)
			pounce_cooldown = TRUE
			VARSET_IN(src, pounce_cooldown, FALSE, pounce_cooldown_time)
			playsound(src, pick(SOUNDIN_HUNTER_LEAP), VOL_EFFECTS_MASTER, vary = FALSE)
	else if(hit_atom.density)
		visible_message("<span class='danger'>[src] smashes into [hit_atom]!</span>", "<span class='alertalien'>You smashes into [hit_atom]!</span>")
		weakened = 2

	update_canmove()

#undef MAX_ALIEN_LEAP_DIST

/mob/living/carbon/xenomorph/humanoid/hunter/movement_delay()
	return(-1 + move_delay_add + config.alien_delay)

/mob/living/carbon/xenomorph/humanoid/hunter/lay_down()
	if(leap_on_click)
		toggle_leap()
	..()

/mob/living/carbon/xenomorph/humanoid/hunter/MobBump(mob/M)
	. = ..()
	if(. && leaping && isliving(M) && M.is_in_hands(/obj/item/weapon/shield/riot))
		STOP_THROWING(src, M)

/mob/living/carbon/xenomorph/humanoid/hunter/proc/check_shield_dir(mob/M)
	if(istype(M.l_hand, /obj/item/weapon/shield))
		if(M.dir == NORTH && (dir in list(SOUTH, EAST)))
			return TRUE
		else if(M.dir == SOUTH && (dir in list(NORTH, WEST)))
			return TRUE
		else if(M.dir == EAST && (dir in list(WEST, SOUTH)))
			return TRUE
		else if(M.dir == WEST && (dir in list(EAST, NORTH)))
			return TRUE
		return FALSE
	else if(istype(M.r_hand, /obj/item/weapon/shield))
		if(M.dir == NORTH && (dir in list(SOUTH, WEST)))
			return TRUE
		else if(M.dir == SOUTH && (dir in list(NORTH, EAST)))
			return TRUE
		else if(M.dir == EAST && (dir in list(WEST, NORTH)))
			return TRUE
		else if(M.dir == WEST && (dir in list(EAST, SOUTH)))
			return TRUE
		return FALSE
	return FALSE

/mob/living/carbon/xenomorph/humanoid/hunter/proc/toggle_invisible()
	if(invisible)
		invisible = FALSE
		animate(src, alpha = initial(alpha), time = 5, loop = 1, LINEAR_EASING)
	else
		invisible = TRUE
		animate(src, alpha = 20, time = 5, loop = 1, LINEAR_EASING)

/mob/living/carbon/xenomorph/humanoid/hunter/set_m_intent(intent)
	. = ..()
	if(.)
		toggle_invisible()
