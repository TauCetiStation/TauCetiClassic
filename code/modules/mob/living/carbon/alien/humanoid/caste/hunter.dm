/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 180
	health = 180
	storedPlasma = 100
	max_plasma = 150
	icon_state = "alienh_s"
	plasma_rate = 5
	heal_rate = 3

/mob/living/carbon/alien/humanoid/hunter/atom_init()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien hunter")
		name = text("alien hunter ([rand(1, 1000)])")
	real_name = name
	. = ..()

/mob/living/carbon/alien/humanoid/hunter
	handle_environment()
		if(m_intent == "run" || resting)
			..()
		else
			adjustToxLoss(-heal_rate)

/mob/living/carbon/alien/humanoid/hunter/handle_hud_icons_health()
	if (healths)
		if (stat != DEAD)
			switch(health)
				if(150 to INFINITY)
					healths.icon_state = "health0"
				if(120 to 150)
					healths.icon_state = "health1"
				if(90 to 120)
					healths.icon_state = "health2"
				if(60 to 90)
					healths.icon_state = "health3"
				if(30 to 60)
					healths.icon_state = "health4"
				if(0 to 30)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"


//Hunter verbs
/*
/mob/living/carbon/alien/humanoid/hunter/verb/invis()
	set name = "Invisibility (50)"
	set desc = "Makes you invisible for 15 seconds."
	set category = "Alien"

	if(alien_invis)
		update_icons()
	else
		if(powerc(50))
			adjustToxLoss(-50)
			alien_invis = 1.0
			update_icons()
			to_chat(src, "\green You are now invisible.")
			for(var/mob/O in oviewers(src, null))
				O.show_message(text("\red <B>[src] fades into the surroundings!</B>"), 1)
			spawn(250)
				if(!isnull(src))//Don't want the game to runtime error when the mob no-longer exists.
					alien_invis = 0.0
					update_icons()
					to_chat(src, "\green You are no longer invisible.")
	return
*/

//Hunter verbs


/mob/living/carbon/alien/humanoid/hunter/proc/toggle_leap(message = 1)
	leap_on_click = !leap_on_click
	leap_icon.icon_state = "leap_[leap_on_click ? "on":"off"]"
	update_icons()
	if(message)
		to_chat(src, "<span class='noticealien'>You will now [leap_on_click ? "leap at":"slash at"] enemies!</span>")
	else
		return


/mob/living/carbon/alien/humanoid/hunter/ClickOn(atom/A, params)
	face_atom(A)
	if(leap_on_click)
		leap_at(A)
	else
		..()


#define MAX_ALIEN_LEAP_DIST 7

/mob/living/carbon/alien/humanoid/hunter/proc/leap_at(atom/A)
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
	if(lying)
		return

	else //Maybe uses plasma in the future, although that wouldn't make any sense...
		stop_pulling()
		leaping = TRUE
		update_icons()
		throw_at(A, MAX_ALIEN_LEAP_DIST, 2, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, .leap_end))

/mob/living/carbon/alien/humanoid/hunter/proc/leap_end()
	leaping = FALSE
	update_icons()

/mob/living/carbon/alien/humanoid/hunter/throw_impact(atom/A)
	if(!leaping)
		return ..()

	if(isliving(A))
		var/mob/living/L = A
		L.visible_message("<span class='danger'>[src] pounces on [L]!</span>", "<span class='userdanger'>[src] pounces on you!</span>")
		if(issilicon(A))
			L.Weaken(1) //Only brief stun
		else
			L.Weaken(5)
		sleep(2)  // Runtime prevention (infinite bump() calls on hulks)
		step_towards(src, L)
		toggle_leap(FALSE)
		pounce_cooldown = TRUE
		addtimer(CALLBACK(src, .proc/refresh_pounce_cooldown), pounce_cooldown_time)
	else if(A.density)
		visible_message("<span class='danger'>[src] smashes into [A]!</span>", "<span class='alertalien'>You smashes into [A]!</span>")
		weakened = 2

	update_canmove()

/mob/living/carbon/alien/humanoid/hunter/proc/refresh_pounce_cooldown()
	pounce_cooldown = FALSE

#undef MAX_ALIEN_LEAP_DIST

/mob/living/carbon/alien/humanoid/hunter/movement_delay()
	return(-1 + move_delay_add + config.alien_delay)
