#define ALIEN_NEUROTOXIN 1
#define ALIEN_ACID 2


/mob/living/carbon/xenomorph/proc/powerc(X, Y)//Y is optional, checks for weed planting. X can be null.
	if(incapacitated())
		to_chat(src, "<span class='warning'>You can't do that while being incapacitated.</span>")
		return FALSE
	else if(X && getPlasma() < X)
		to_chat(src, "<span class='warning'>Not enough plasma stored.</span>")
		return FALSE
	else if(Y && (!isturf(src.loc) || isspaceturf(src.loc)))
		to_chat(src, "<span class='warning'>Bad place for a garden!</span>")
		return FALSE
	return TRUE

/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid(O in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrossive / Queen Acid (100)"
	set desc = "Drench an object in acid, destroying it over time."
	set category = "Alien"

	if(powerc(100))
		if(O in oview(1))
			// OBJ CHECK
			if(isobj(O))
				var/obj/I = O
				if(I.unacidable)	//So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
					to_chat(src, "<span class='warning'>You cannot dissolve this object.</span>")
					return
			// TURF CHECK
			else if(istype(O, /turf/simulated))
				var/turf/T = O
				// R WALL
				if(istype(T, /turf/simulated/wall/r_wall) && acid_type == /obj/effect/alien/acid)
					to_chat(src, "<span class='warning'>You cannot dissolve this object.</span>")
					return
				// R FLOOR
				if(istype(T, /turf/simulated/floor/engine))
					to_chat(src, "<span class='warning'>You cannot dissolve this object.</span>")
					return
			else// Not a type we can acid.
				return

			adjustToxLoss(-100)
			new acid_type(get_turf(O), O)
			visible_message("<span class='danger'>[src] vomits globs of vile stuff all over [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
		else
			to_chat(src, "<span class='warning'>Target is too far away.</span>")

/mob/living/carbon/xenomorph/humanoid/proc/toggle_neurotoxin(message = TRUE)
	switch(neurotoxin_on_click)

		if(0)
			neurotoxin_on_click = ALIEN_NEUROTOXIN
			if(message)
				to_chat(src, "<span class='noticealien'>You will now fire neurotoxin in enemies with a middle click!</span>")

		if(ALIEN_NEUROTOXIN)
			neurotoxin_on_click = ALIEN_ACID
			if(message)
				to_chat(src, "<span class='noticealien'>You will now fire acid in enemies with a middle click!</span>")

		if(ALIEN_ACID)
			neurotoxin_on_click = 0
			if(message)
				to_chat(src, "<span class='noticealien'>You will not fire in enemies!</span>")
	neurotoxin_icon.icon_state = "neurotoxin[neurotoxin_on_click]"
	update_icons()

/mob/living/carbon/xenomorph/humanoid/proc/neurotoxin()
	set name = "Spit Neurotoxin"
	set desc = "Spits neurotoxin at someone, paralyzing them for a short time if they are not wearing protective gear."
	set category = "Alien"
	toggle_neurotoxin()

/mob/living/carbon/xenomorph/humanoid/MiddleClickOn(atom/A, params)
	face_atom(A)
	if(neurotoxin_on_click)
		split_neurotoxin(A)
	else
		..()

/mob/living/carbon/xenomorph/humanoid/proc/split_neurotoxin(atom/target)
	if(neurotoxin_next_shot > world.time)
		to_chat(src, "<span class='warning'>You are not ready.</span>")
		return

		//I'm not motivated enough to revise this. Prjectile code in general needs update.
	var/turf/T = loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

	if(!U || !T)
		return
	while(U && !istype(U,/turf))
		U = U.loc
	if(!istype(T, /turf))
		return
	if (U == T)
		return
	if(!istype(U, /turf))
		return

	var/obj/item/projectile/BB

	switch(neurotoxin_on_click)
		if(ALIEN_NEUROTOXIN)
			if(!powerc(50))
				return
			BB = new /obj/item/projectile/neurotoxin(usr.loc)
			adjustToxLoss(-50)
			neurotoxin_next_shot = world.time  + neurotoxin_delay
		if(ALIEN_ACID)
			if(!powerc(75))
				return
			BB = new /obj/item/projectile/acid_special(usr.loc)
			neurotoxin_next_shot = world.time  + (neurotoxin_delay * 2)
			adjustToxLoss(-75)

	visible_message("<span class='danger'>[src] spits [BB.name] at [target]!</span>")
	playsound(src, pick(SOUNDIN_XENOMORPH_SPLITACID), VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)
	//prepare "bullet"
	BB.original = target
	BB.firer = src
	BB.def_zone = get_targetzone()
	//shoot
	BB.loc = T
	BB.starting = T
	BB.current = loc
	BB.yo = U.y - loc.y
	BB.xo = U.x - loc.x

	if(BB)
		BB.process()

	last_neurotoxin = world.time

#undef ALIEN_NEUROTOXIN
#undef ALIEN_ACID
