/*NOTES:
These are general powers. Specific powers are stored under the appropriate alien creature type.
*/

/*Alien spit now works like a taser shot. It won't home in on the target but will act the same once it does hit.
Doesn't work on other aliens/AI.*/

/datum/action/spell_action/alien

/datum/action/spell_action/alien/UpdateName()
	var/obj/effect/proc_holder/alien/ab = target
	return ab.name

/datum/action/spell_action/alien/IsAvailable()
	if(!target)
		return 0
	var/obj/effect/proc_holder/alien/ab = target

	if(usr)
		return ab.cost_check(ab.check_turf,usr,1)
	else
		if(owner)
			return ab.cost_check(ab.check_turf,owner,1)
	return 1

/datum/action/spell_action/alien/CheckRemoval()
	if(!iscarbon(owner))
		return 1

	var/mob/living/carbon/C = owner
	if(target.loc && !(target.loc in C.organs))
		return 1

	return 0

/obj/effect/proc_holder/alien
	name = "Alien Power"
	panel = "Alien"
	var/plasma_cost = 0
	var/check_turf = 0
	var/has_action = 1
	var/datum/action/spell_action/alien/action = null
	var/action_icon = 'icons/mob/actions.dmi'
	var/action_icon_state = "spell_default"
	var/action_background_icon_state = "bg_alien"

/obj/effect/proc_holder/alien/New()
	..()
	action = new(src)
	action.name = name
	action.button_icon = action_icon
	action.button_icon_state = action_icon_state
	action.background_icon_state = action_background_icon_state

/obj/effect/proc_holder/alien/Click()
	if(!iscarbon(usr))
		return 1
	var/mob/living/carbon/user = usr
	if(cost_check(check_turf, user))
		if(fire(user) && user) // Second check to prevent runtimes when evolving
			user.adjustPlasma(-plasma_cost)
	return 1

/obj/effect/proc_holder/alien/proc/on_gain(mob/living/carbon/user)
	return

/obj/effect/proc_holder/alien/proc/on_lose(mob/living/carbon/user)
	return

/obj/effect/proc_holder/alien/proc/fire(mob/living/carbon/user)
	return 1

/obj/effect/proc_holder/alien/proc/cost_check(check_turf=0,mob/living/carbon/user,silent = 0)
	if(user.stat)
		if(!silent)
			user << "<span class='noticealien'>You must be conscious to do this.</span>"
		return 0
	if(user.getPlasma() < plasma_cost)
		if(!silent)
			user << "<span class='noticealien'>Not enough plasma stored.</span>"
		return 0
	if(check_turf && (!isturf(user.loc) || istype(user.loc, /turf/space)))
		if(!silent)
			user << "<span class='noticealien'>Bad place for a garden!</span>"
		return 0
	return 1


/obj/effect/proc_holder/alien/plant
	name = "Plant Weeds"
	desc = "Plants some alien weeds"
	plasma_cost = 50
	check_turf = 1
	action_icon_state = "alien_plant"

/obj/effect/proc_holder/alien/plant/fire(mob/living/carbon/user)
	if(locate(/obj/structure/alien/weeds/node) in get_turf(user))
		user << "There's already a weed node here."
		return 0
	user.visible_message("<span class='alertalien'>[user] has planted some alien weeds!</span>")
	new/obj/structure/alien/weeds/node(user.loc)
	return 1


/obj/effect/proc_holder/alien/whisper
	name = "Whisper"
	desc = "Whisper to someone"
	plasma_cost = 10
	action_icon_state = "alien_whisper"

/obj/effect/proc_holder/alien/whisper/fire(mob/living/carbon/user)
	var/list/options = list()
	for(var/mob/living/Ms in oview(user))
		options += Ms
	var/mob/living/M = input("Select who to whisper to:","Whisper to?",null) as null|mob in options
	if(!M)
		return 0
	var/msg = sanitize(input("Message:", "Alien Whisper") as text|null)
	if(msg)
		log_say("AlienWhisper: [key_name(user)]->[M.key] : [msg]")
		M << "<span class='noticealien'>You hear a strange, alien voice in your head...</span>[msg]"
		user << "<span class='noticealien'>You said: \"[msg]\" to [M]</span>"
		for(var/ded in dead_mob_list)
			if(!isobserver(ded))
				continue
			ded << "\
				<span class='name'>[user]</span> \
				<span class='alertalien'>Alien Whisper --> </span> \
				<span class='name'>[M]</span> \
				<span class='noticealien'>[msg]</span>"
	else
		return 0
	return 1


/obj/effect/proc_holder/alien/transfer
	name = "Transfer Plasma"
	desc = "Transfer Plasma to another alien"
	plasma_cost = 0
	action_icon_state = "alien_transfer"

/obj/effect/proc_holder/alien/transfer/fire(mob/living/carbon/user)
	var/list/mob/living/carbon/aliens_around = list()
	for(var/mob/living/carbon/A  in oview(user))
		if(A.organs_by_name[BP_PLASMA])
			aliens_around.Add(A)
	var/mob/living/carbon/M = input("Select who to transfer to:","Transfer plasma to?",null) as mob in aliens_around
	if(!M)
		return 0
	var/amount = input("Amount:", "Transfer Plasma to [M]") as num
	if (amount)
		amount = min(abs(round(amount)), user.getPlasma())
		if (get_dist(user,M) <= 1)
			M.adjustPlasma(amount)
			user.adjustPlasma(-amount)
			M << "<span class='noticealien'>[user] has transferred [amount] plasma to you.</span>"
			user << "<span class='noticealien'>You transfer [amount] plasma to [M]</span>"
		else
			user << "<span class='noticealien'>You need to be closer!</span>"
	return

/obj/effect/proc_holder/alien/acid
	name = "Corrosive Acid"
	desc = "Drench an object in acid, destroying it over time."
	plasma_cost = 200
	action_icon_state = "alien_acid"

/obj/effect/proc_holder/alien/acid/on_gain(mob/living/carbon/user)
	user.verbs.Add(/mob/living/carbon/proc/corrosive_acid)

/obj/effect/proc_holder/alien/acid/on_lose(mob/living/carbon/user)
	user.verbs.Remove(/mob/living/carbon/proc/corrosive_acid)

/obj/effect/proc_holder/alien/acid/fire(mob/living/carbon/alien/user)
	var/O = input("Select what to dissolve:","Dissolve",null) as obj|turf in oview(1,user)
	if(!O || user.incapacitated())
		return FALSE
	else
		return corrode(O, user)

/obj/effect/proc_holder/alien/acid/proc/corrode(atom/target,mob/living/carbon/user = usr)
	if(target in oview(1))
		// OBJ CHECK
		if(isobj(target))
			var/obj/I = target
			if(I.unacidable)	//So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
				to_chat(user, "<span class='noticealien'>You cannot dissolve this object.</span>")
				return FALSE
		// TURF CHECK
		else if(istype(target, /turf/simulated))
			var/turf/T = target
			// R WALL
			if(istype(T, /turf/simulated/wall/r_wall))
				to_chat(user, "<span class='noticealien'>You cannot dissolve this object.</span>")
				return FALSE
			// R FLOOR
			if(istype(T, /turf/simulated/floor/engine))
				to_chat(user, "<span class='noticealien'>You cannot dissolve this object.</span>")
				return FALSE
		else// Not a type we can acid.
			return FALSE

		new /obj/effect/alien/acid(get_turf(target), target)
		user.visible_message("<span class='alertalien'>[user] vomits globs of vile stuff all over [target]. It begins to sizzle and melt under the bubbling mess of acid!</span>")
		return TRUE
	else
		to_chat(user, "<span class='noticealien'>Target is too far away.</span>")
		return FALSE

/mob/living/carbon/proc/corrosive_acid(O as obj|turf in oview(1)) // right click menu verb ugh
	set name = "Corrossive Acid"

	if(!iscarbon(usr))
		return
	var/mob/living/carbon/user = usr
	var/obj/effect/proc_holder/alien/acid/A = locate() in user.abilities
	if(!A || user.incapacitated())
		return
	if(user.getPlasma() > A.plasma_cost && A.corrode(O))
		user.adjustPlasma(-A.plasma_cost)

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
			usr.bullet_act(new /obj/item/projectile/energy/neurotoxin(usr.loc), get_bodypart_target())
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

/obj/effect/proc_holder/alien/neurotoxin // TODO separate this back
	name = "Spit Neurotoxin"
	desc = "Spits neurotoxin at someone, paralyzing them for a short time if they are not wearing protective gear."
	action_icon_state = "alien_neuroacid_0"

#define ALIEN_NEUROTOXIN 1
#define ALIEN_ACID 2
/obj/effect/proc_holder/alien/neurotoxin/fire(mob/living/carbon/user, message = 1)
	switch(user.neurotoxin_on_click)
		if(0)
			user.neurotoxin_on_click = ALIEN_NEUROTOXIN
			if(message)
				to_chat(user, "<span class='noticealien'>You will now fire neurotoxin in enemies!</span>")

		if(ALIEN_NEUROTOXIN)
			user.neurotoxin_on_click = ALIEN_ACID
			if(message)
				to_chat(user, "<span class='noticealien'>You will now fire acid in enemies!</span>")

		if(ALIEN_ACID)
			user.neurotoxin_on_click = 0
			if(message)
				to_chat(user, "<span class='noticealien'>You will not fire in enemies!</span>")

	action.button_icon_state = "alien_neuroacid_[user.neurotoxin_on_click]"
	action.button.UpdateIcon()

/mob/living/carbon/alien/humanoid/ClickOn(atom/A, params)
	if(neurotoxin_on_click)
		face_atom(A)
		split_neurotoxin(A)
	else
		..()

/mob/living/carbon/alien/humanoid/proc/split_neurotoxin(atom/target)
	if(neurotoxin_next_shot > world.time)
		to_chat(src, "You are not ready.")
		return

	var/p_cost = 50
	if(neurotoxin_on_click == ALIEN_ACID)
		p_cost = 150

	if(getPlasma() < p_cost)
		to_chat(src, "<span class='warning'>You need at least [p_cost] plasma to spit.</span>")
		return

	//I'm not motivated enough to revise this. Prjectile code in general needs update.
	var/turf/T = loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

	if(!U || !T)
		return

	while(U && !istype(U,/turf))
		U = U.loc

	if(!isturf(T) || !isturf(U) || U == T)
		return

	var/obj/item/projectile/BB

	switch(neurotoxin_on_click)
		if(ALIEN_NEUROTOXIN)
			BB = new /obj/item/projectile/neurotoxin(loc)
			neurotoxin_next_shot = world.time  + neurotoxin_delay
		if(ALIEN_ACID)
			BB = new /obj/item/projectile/acid_special(loc)
			neurotoxin_next_shot = world.time  + (neurotoxin_delay * 6)

	adjustPlasma(-p_cost)
	visible_message("<span class='danger'>[src] spits [BB.name]!</span>", "<span class='alertalien'>You spit neurotoxin at [target].</span>")

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

/obj/effect/proc_holder/alien/resin
	name = "Secrete Resin"
	desc = "Secrete tough malleable resin."
	plasma_cost = 55
	check_turf = 1
	var/list/structures = list(
		"resin door" = /obj/structure/mineral_door/resin,
		"resin wall" = /obj/effect/alien/resin/wall,
		"resin membrane" = /obj/effect/alien/resin/membrane,
		"resin nest" = /obj/structure/stool/bed/nest)

	action_icon_state = "alien_resin"

/obj/effect/proc_holder/alien/resin/fire(mob/living/carbon/user)
	if((locate(/obj/effect/alien/resin) in user.loc) || (locate(/obj/structure/stool/bed/nest) in user.loc) || (locate(/obj/structure/mineral_door/resin) in user.loc))
		user << "<span class='danger'>There is already a resin structure there.</span>"
		return 0
	var/choice = input("Choose what you wish to shape.","Resin building") as null|anything in structures
	if(!choice)
		return 0
	if (!cost_check(check_turf,user))
		return 0
	user << "<span class='notice'>You shape a [choice].</span>"
	user.visible_message("<span class='notice'>[user] vomits up a thick purple substance and begins to shape it.</span>")

	choice = structures[choice]
	new choice(user.loc)
	return 1

/obj/effect/proc_holder/alien/regurgitate
	name = "Regurgitate"
	desc = "Empties the contents of your stomach"
	plasma_cost = 0
	action_icon_state = "alien_barf"

/obj/effect/proc_holder/alien/regurgitate/fire(mob/living/carbon/user)
	if(user.stomach_contents.len)
		for(var/atom/movable/A in user.stomach_contents)
			user.stomach_contents.Remove(A)
			A.loc = user.loc
			//if(isliving(A))
			//	var/mob/M = A
			//	M.reset_perspective()
		user.visible_message("<span class='alertealien'>[user] hurls out the contents of their stomach!</span>")

/obj/effect/proc_holder/alien/sneak
	name = "Sneak"
	desc = "Blend into the shadows to stalk your prey."
	var/active = 0

	action_icon_state = "alien_sneak"

/obj/effect/proc_holder/alien/sneak/fire(mob/living/carbon/alien/humanoid/user)
	if(!active)
		user.alpha = 75 //Still easy to see in lit areas with bright tiles, almost invisible on resin.
		user.sneaking = 1
		active = 1
		user << "<span class='noticealien'>You blend into the shadows...</span>"
	else
		user.alpha = initial(user.alpha)
		user.sneaking = 0
		active = 0
		user << "<span class='noticealien'>You reveal yourself!</span>"

/mob/living/carbon/proc/getPlasma()
	var/obj/item/organ/xenos/plasmavessel/vessel = organs_by_name[BP_PLASMA]
	if(!vessel) return 0
	return vessel.stored_plasma


/mob/living/carbon/proc/adjustPlasma(amount)
	var/obj/item/organ/xenos/plasmavessel/vessel = organs_by_name[BP_PLASMA]
	if(!vessel) return 0
	vessel.stored_plasma = max(vessel.stored_plasma + amount,0)
	vessel.stored_plasma = min(vessel.stored_plasma, vessel.max_plasma) //upper limit of max_plasma, lower limit of 0
	//for(var/X in abilities)
	//	var/obj/effect/proc_holder/alien/APH = X
	//	if(APH.has_action)
	//		APH.action.UpdateButtonIcon()
	return 1

/mob/living/carbon/alien/adjustPlasma(amount)
	. = ..()
	updatePlasmaDisplay()

/mob/living/carbon/proc/usePlasma(amount)
	if(getPlasma() >= amount)
		adjustPlasma(-amount)
		return 1

	return 0


/proc/cmp_abilities_cost(obj/effect/proc_holder/alien/a, obj/effect/proc_holder/alien/b)
	return b.plasma_cost - a.plasma_cost
