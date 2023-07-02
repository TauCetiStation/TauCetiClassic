/mob/living/carbon/xenomorph/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 180
	health = 180
	storedPlasma = 100
	max_plasma = 150
	speed = -1
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
	if(storedPlasma < heal_rate || incapacitated())
		set_m_intent(MOVE_INTENT_RUN)	//get out of invisibility if plasma runs out
	..()

//Hunter verbs
/mob/living/carbon/xenomorph/humanoid/hunter/proc/toggle_leap(message = TRUE)
	if(crawling)
		crawl()
	leap_on_click = !leap_on_click
	leap_icon.update_icon(src)
	update_icons()
	if(message)
		if(leap_on_click)
			to_chat(src, "<span class='noticealien'>You will now leap at enemies with a middle click!</span>")
		else
			to_chat(src, "<span class='noticealien'>You will no longer leap at enemies with a middle click!</span>")

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

	if(isspaceturf(src.loc) || isspaceturf(A.loc))
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
		throw_at(A, MAX_ALIEN_LEAP_DIST, 1, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, PROC_REF(leap_end)))

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
		if(shield && check_shield_dir(hit_atom, dir))
			L.visible_message("<span class='danger'>[src] smashed into [L]'s [shield]!</span>", "<span class='userdanger'>[src] pounces on your [shield]!</span>")
			playsound(hit_atom, 'sound/weapons/metal_shield_hit.ogg', VOL_EFFECTS_MASTER)
			Stun(2, TRUE)
			Weaken(2, TRUE)
		else
			L.visible_message("<span class='danger'>[src] pounces on [L]!</span>", "<span class='userdanger'>[src] pounces on you!</span>")
			if(issilicon(L))
				L.Stun(1)
				L.Weaken(1) //Only brief stun
			else
				L.Stun(5)
				L.Weaken(5)
			sleep(2)  // Runtime prevention (infinite bump() calls on hulks)
			step_towards(src, L)
			toggle_leap(FALSE)
			playsound(src, pick(SOUNDIN_HUNTER_LEAP), VOL_EFFECTS_MASTER, vary = FALSE)
	else if(hit_atom.density)
		visible_message("<span class='danger'>[src] smashes into [hit_atom]!</span>", "<span class='alertalien'>You smashes into [hit_atom]!</span>")
		playsound(hit_atom, 'sound/effects/hulk_attack.ogg', VOL_EFFECTS_MASTER)
		Stun(2, TRUE)
		Weaken(2, TRUE)

	pounce_cooldown = TRUE
	VARSET_IN(src, pounce_cooldown, FALSE, pounce_cooldown_time)
	update_canmove()

#undef MAX_ALIEN_LEAP_DIST

/mob/living/carbon/xenomorph/humanoid/hunter/crawl()
	if(leap_on_click)
		toggle_leap()
	..()

/mob/living/carbon/xenomorph/humanoid/hunter/MobBump(mob/M)
	. = ..()
	if(. && leaping && isliving(M) && M.is_in_hands(/obj/item/weapon/shield/riot))
		STOP_THROWING(src, M)

/mob/living/carbon/xenomorph/humanoid/hunter/proc/toggle_invisible()
	if(invisible)
		invisible = FALSE
		animate(src, alpha = initial(alpha), time = 5, loop = 1, LINEAR_EASING)
	else
		invisible = TRUE
		animate(src, alpha = 20, time = 5, loop = 1, LINEAR_EASING)

/mob/living/carbon/xenomorph/humanoid/hunter/set_m_intent(intent)
	if(incapacitated() && !invisible)
		return
	. = ..()
	if(.)
		toggle_invisible()
