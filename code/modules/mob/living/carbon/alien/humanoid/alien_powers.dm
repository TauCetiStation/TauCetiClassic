/*NOTES:
These are general powers. Specific powers are stored under the appropriate alien creature type.
*/

/*Alien spit now works like a taser shot. It won't home in on the target but will act the same once it does hit.
Doesn't work on other aliens/AI.*/


/mob/living/carbon/alien/proc/powerc(X, Y)//Y is optional, checks for weed planting. X can be null.
	if(stat)
		to_chat(src, "\green You must be conscious to do this.")
		return 0
	else if(X && getPlasma() < X)
		to_chat(src, "\green Not enough plasma stored.")
		return 0
	else if(Y && (!isturf(src.loc) || istype(src.loc, /turf/space)))
		to_chat(src, "\green Bad place for a garden!")
		return 0
	else	return 1

/mob/living/carbon/alien/humanoid/verb/plant()
	set name = "Plant Weeds (50)"
	set desc = "Plants some alien weeds."
	set category = "Alien"

	if(powerc(50,1))
		adjustToxLoss(-50)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] has planted some alien weeds!</B>"), 1)
		new /obj/structure/alien/weeds/node(loc)
	return

/*
/mob/living/carbon/alien/humanoid/verb/ActivateHuggers()
	set name = "Activate facehuggers (5)"
	set desc = "Makes all nearby facehuggers activate."
	set category = "Alien"

	if(powerc(5))
		adjustToxLoss(-5)
		for(var/obj/item/clothing/mask/facehugger/F in range(8,src))
			F.GoActive()
		emote("roar")
	return
*/
/mob/living/carbon/alien/humanoid/verb/whisp(mob/M as mob in oview())
	set name = "Whisper (10)"
	set desc = "Whisper to someone."
	set category = "Alien"

	if(powerc(10))
		adjustToxLoss(-10)
		var/msg = sanitize(input("Message:", "Alien Whisper") as text|null)
		if(msg)
			log_say("AlienWhisper: [key_name(src)]->[M.key] : [msg]")
			to_chat(M, "\green You hear a strange, alien voice in your head... \italic [msg]")
			to_chat(src, {"\green You said: "[msg]" to [M]"})
	return

/mob/living/carbon/alien/humanoid/verb/transfer_plasma(mob/living/carbon/alien/M as mob in oview())
	set name = "Transfer Plasma"
	set desc = "Transfer Plasma to another alien."
	set category = "Alien"

	if(isalien(M))
		var/amount = input("Amount:", "Transfer Plasma to [M]") as num
		if (amount)
			amount = abs(round(amount))
			if(powerc(amount))
				if (get_dist(src,M) <= 1)
					M.adjustToxLoss(amount)
					adjustToxLoss(-amount)
					to_chat(M, "\green [src] has transfered [amount] plasma to you.")
					to_chat(src, {"\green You have trasferred [amount] plasma to [M]"})
				else
					to_chat(src, "\green You need to be closer.")
	return


/mob/living/carbon/alien/humanoid/proc/corrosive_acid(O in oview(1)) //If they right click to corrode, an error will flash if its an invalid target./N
	set name = "Corrossive Acid (200)"
	set desc = "Drench an object in acid, destroying it over time."
	set category = "Alien"

	if(powerc(200))
		if(O in oview(1))
			// OBJ CHECK
			if(isobj(O))
				var/obj/I = O
				if(I.unacidable)	//So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
					to_chat(src, "\green You cannot dissolve this object.")
					return
			// TURF CHECK
			else if(istype(O, /turf/simulated))
				var/turf/T = O
				// R WALL
				if(istype(T, /turf/simulated/wall/r_wall))
					to_chat(src, "\green You cannot dissolve this object.")
					return
				// R FLOOR
				if(istype(T, /turf/simulated/floor/engine))
					to_chat(src, "\green You cannot dissolve this object.")
					return
			else// Not a type we can acid.
				return

			adjustToxLoss(-200)
			new /obj/effect/alien/acid(get_turf(O), O)
			visible_message("\green <B>[src] vomits globs of vile stuff all over [O]. It begins to sizzle and melt under the bubbling mess of acid!</B>")
		else
			to_chat(src, "\green Target is too far away.")
	return

/*
/mob/living/carbon/alien/humanoid/proc/neurotoxin(mob/target in oview())
	set name = "Spit Neurotoxin (50)"
	set desc = "Spits neurotoxin at someone, paralyzing them for a short time if they are not wearing protective gear."
	set category = "Alien"

	if(powerc(50))
		if(isalien(target))
			to_chat(src, "\green Your allies are not a valid target.")
			return
		adjustToxLoss(-50)
		to_chat(src, "\green You spit neurotoxin at [target].")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				to_chat(O, "\red [src] spits neurotoxin at [target]!")
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
			usr.bullet_act(new /obj/item/projectile/energy/neurotoxin(usr.loc), ran_zone(zone_sel.selecting)
			return
		if(!istype(U, /turf))
			return

		var/obj/item/projectile/energy/neurotoxin/A = new /obj/item/projectile/energy/neurotoxin(usr.loc)
		A.current = U
		A.yo = U.y - T.y
		A.xo = U.x - T.x
		A.process()
	return
*/

/mob/living/carbon/alien/humanoid/proc/screech()
	set name = "Screech!"
	set desc = "Emit a screech that stuns prey."
	set category = "Alien"

	if(world.time < last_screech + screech_delay)
		return

	playsound(src, 'sound/effects/screech2.ogg', 100, 1)
	for(var/mob/living/carbon/human/H in oviewers())
		if(H.sdisabilities & DEAF || istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
			continue

		to_chat(H, "<font color='red' size='7'>HISSSSSS</font>")
		H.SetSleeping(0)
		H.stuttering += 20
		H.ear_deaf += 30
		H.Weaken(3)
		if(prob(30))
			H.Stun(10)
			H.Paralyse(4)
		else
			H.Stun(5)
			H.Paralyse(2)
	last_screech = world.time
#define ALIEN_NEUROTOXIN 1
#define ALIEN_ACID 2
/mob/living/carbon/alien/humanoid/proc/toggle_neurotoxin(message = 1)
	switch(neurotoxin_on_click)

		if(0)
			neurotoxin_on_click = ALIEN_NEUROTOXIN
			if(message)
				to_chat(src, "<span class='noticealien'>You will now fire neurotoxin in enemies!</span>")

		if(ALIEN_NEUROTOXIN)
			neurotoxin_on_click = ALIEN_ACID
			if(message)
				to_chat(src, "<span class='noticealien'>You will now fire acid in enemies!</span>")

		if(ALIEN_ACID)
			neurotoxin_on_click = 0
			if(message)
				to_chat(src, "<span class='noticealien'>You will not fire in enemies!</span>")
	neurotoxin_icon.icon_state = "neurotoxin[neurotoxin_on_click]"
	update_icons()
	return

/mob/living/carbon/alien/humanoid/proc/neurotoxin()
	set name = "Spit Neurotoxin"
	set desc = "Spits neurotoxin at someone, paralyzing them for a short time if they are not wearing protective gear."
	set category = "Alien"
	toggle_neurotoxin(1)
	return

/mob/living/carbon/alien/humanoid/ClickOn(atom/A, params)
	face_atom(A)
	if(neurotoxin_on_click)
		split_neurotoxin(A)
	else
		..()

/mob/living/carbon/alien/humanoid/proc/split_neurotoxin(atom/target)
	if(neurotoxin_next_shot > world.time)
		to_chat(src, "You are not ready.")
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
			if(!powerc(150))
				return
			BB = new /obj/item/projectile/acid_special(usr.loc)
			neurotoxin_next_shot = world.time  + (neurotoxin_delay * 4)
			adjustToxLoss(-150)

	visible_message("\red <B> [src] spits [BB.name] at [target]!</B>")

	//prepare "bullet"
	BB.original = target
	BB.firer = src
	BB.def_zone = src.zone_sel.selecting
	//shoot
	BB.loc = T
	BB.starting = T
	BB.current = loc
	BB.yo = U.y - loc.y
	BB.xo = U.x - loc.x

	if(BB)
		BB.process()

	last_neurotoxin = world.time
	return
#undef ALIEN_NEUROTOXIN
#undef ALIEN_ACID
/mob/living/carbon/alien/humanoid/proc/resin() // -- TLE
	set name = "Secrete Resin (75)"
	set desc = "Secrete tough malleable resin."
	set category = "Alien"

	if((locate(/obj/effect/alien/air_plant) in get_turf(src)) || (locate(/obj/effect/alien/egg) in get_turf(src)) || (locate(/obj/structure/mineral_door/resin) in get_turf(src)) || (locate( /obj/effect/alien/resin/wall) in get_turf(src)) || (locate(/obj/effect/alien/resin/membrane) in get_turf(src)) || (locate(/obj/structure/stool/bed/nest) in get_turf(src)))
		to_chat (src, "There is already a structure there.")
		return

	if(powerc(75))
		var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in list("resin door","resin wall","resin membrane","resin nest") //would do it through typesof but then the player choice would have the type path and we don't want the internal workings to be exposed ICly - Urist
		if(!choice || !powerc(75))	return
		adjustToxLoss(-75)
		to_chat(src, "\green You shape a [choice].")
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\red <B>[src] vomits up a thick purple substance and begins to shape it!</B>"), 1)
		switch(choice)
			if("resin door")
				new /obj/structure/mineral_door/resin(loc)
			if("resin wall")
				new /obj/effect/alien/resin/wall(loc)
			if("resin membrane")
				new /obj/effect/alien/resin/membrane(loc)
			if("resin nest")
				new /obj/structure/stool/bed/nest(loc)
	return

/mob/living/carbon/alien/humanoid/verb/regurgitate()
	set name = "Regurgitate"
	set desc = "Empties the contents of your stomach."
	set category = "Alien"

	if(powerc())
		if(stomach_contents.len)
			for(var/mob/M in src)
				if(M in stomach_contents)
					stomach_contents.Remove(M)
					M.loc = loc
					//M.update_pipe_vision()
					//Paralyse(10)
			src.visible_message("\green <B>[src] hurls out the contents of their stomach!</B>")
	return

/mob/living/carbon/alien/humanoid/verb/air_plant()
	set name = "Plant Air Generator (250)"
	set desc = "Plants some alien weeds."
	set category = "Alien"

	if(powerc(250,1))
		adjustToxLoss(-250)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\green <B>[src] has planted some alien weeds!</B>"), 1)
		new /obj/effect/alien/air_plant(loc)
	return
