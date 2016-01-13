/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 180
	health = 180
	storedPlasma = 100
	max_plasma = 150
	icon_state = "alienh_s"
	plasma_rate = 5

/mob/living/carbon/alien/humanoid/hunter/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien hunter")
		name = text("alien hunter ([rand(1, 1000)])")
	real_name = name
	..()

/mob/living/carbon/alien/humanoid/hunter
	handle_environment()
		if(m_intent == "run" || resting)
			..()
		else
			adjustToxLoss(-heal_rate)

/mob/living/carbon/alien/humanoid/hunter/handle_hud_icons_health()
	if (healths)
		if (stat != 2)
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
			src << "\green You are now invisible."
			for(var/mob/O in oviewers(src, null))
				O.show_message(text("\red <B>[src] fades into the surroundings!</B>"), 1)
			spawn(250)
				if(!isnull(src))//Don't want the game to runtime error when the mob no-longer exists.
					alien_invis = 0.0
					update_icons()
					src << "\green You are no longer invisible."
	return
*/

//Hunter verbs


/mob/living/carbon/alien/humanoid/hunter/proc/toggle_leap(var/message = 1)
	leap_on_click = !leap_on_click
	leap_icon.icon_state = "leap_[leap_on_click ? "on":"off"]"
	update_icons()
	if(message)
		src << "<span class='noticealien'>You will now [leap_on_click ? "leap at":"slash at"] enemies!</span>"
	else
		return


/mob/living/carbon/alien/humanoid/hunter/ClickOn(var/atom/A, var/params)
	face_atom(A)
	if(leap_on_click)
		leap_at(A)
	else
		..()


#define MAX_ALIEN_LEAP_DIST 7

/mob/living/carbon/alien/humanoid/hunter/proc/leap_at(var/atom/A)
	if(pounce_cooldown)
		src << "<span class='alertalien'>You are too fatigued to pounce right now!</span>"
		return

	if(leaping) //Leap while you leap, so you can leap while you leap
		return

	if((istype(src.loc, /turf/space)) || (istype(A.loc, /turf/space)))
		src << "<span class='alertalien'>It is unsafe to leap without gravity!</span>"
		//It's also extremely buggy visually, so it's balance+bugfix
		return
	if(lying)
		return

	else //Maybe uses plasma in the future, although that wouldn't make any sense...
		leaping = 1
		update_icons()
		throw_at(A,MAX_ALIEN_LEAP_DIST,1)
		leaping = 0
		update_icons()

/mob/living/carbon/alien/humanoid/hunter/throw_impact(A)

	if(!leaping)
		return ..()

	if(A)
		if(istype(A, /mob/living))
			var/mob/living/L = A
			L.visible_message("<span class ='danger'>[src] pounces on [L]!</span>", "<span class ='userdanger'>[src] pounces on you!</span>")
			L.Weaken(5)
			sleep(2)//Runtime prevention (infinite bump() calls on hulks)
			step_towards(src,L)

			toggle_leap(0)
			pounce_cooldown = !pounce_cooldown
			spawn(pounce_cooldown_time) //3s by default
				pounce_cooldown = !pounce_cooldown
		else
			visible_message("<span class ='danger'>[src] smashes into [A]!</span>", "<span class ='alertalien'>[src] smashes into [A]!</span>")
			weakened = 2

		if(leaping)
			leaping = 0
			update_canmove()



//Modified throw_at() that will use diagonal dirs where appropriate
//instead of locking it to cardinal dirs
/mob/living/carbon/alien/humanoid/throw_at(atom/target, range, speed)
	if(!target || !src)	return 0

	src.throwing = 1

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dist_travelled = 0
	var/dist_since_sleep = 0

	var/tdist_x = dist_x;
	var/tdist_y = dist_y;

	if(dist_x <= dist_y)
		tdist_x = dist_y;
		tdist_y = dist_x;

	var/error = tdist_x/2 - tdist_y
	//while(src && target &&((((src.x < target.x && dx == EAST) || (src.x > target.x && dx == WEST)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
	while(target && (((((dist_x > dist_y) && ((src.x < target.x) || (src.x > target.x))) || ((dist_x <= dist_y) && ((src.y < target.y) || (src.y > target.y))) || (src.x > target.x)) && dist_travelled < range) || istype(src.loc, /turf/space)))

		if(!src.throwing) break
		if(!istype(src.loc, /turf)) break

		var/atom/step = get_step(src, get_dir(src,target))
		if(!step)
			break
		src.Move(step, get_dir(src, step))
		hit_check()
		error += (error < 0) ? tdist_x : -tdist_y;
		dist_travelled++
		dist_since_sleep++
		if(dist_since_sleep >= speed)
			dist_since_sleep = 0
			sleep(1)


	src.throwing = 0

	return 1

