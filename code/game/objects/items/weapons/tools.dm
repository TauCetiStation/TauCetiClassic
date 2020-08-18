//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/* Tools!
 * Note: Multitools are /obj/item/device
 *
 * Contains:
 * 		Wrench
 * 		Screwdriver
 * 		Wirecutters
 * 		Welding Tool
 * 		Crowbar
 */

/*
 * Wrench
 */
/obj/item/weapon/wrench
	name = "wrench"
	desc = "A wrench with many common uses. Can be usually found in your hand."
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench_blue"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	force = 5.0
	throwforce = 7.0
	w_class = ITEM_SIZE_SMALL
	m_amt = 150
	origin_tech = "materials=1;engineering=1"
	hitsound = list('sound/items/tools/crowbar-hit.ogg')
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	usesound = 'sound/items/Ratchet.ogg'
	var/random_color = TRUE

/obj/item/weapon/wrench/atom_init(mapload, param_color)
	. = ..()
	if(random_color)
		if(!param_color)
			param_color = pick("black","red","green","blue","default")
		icon_state = "wrench_[param_color]"
		item_state = "wrench_[param_color]"

/obj/item/weapon/wrench/power
	name = "Hand Drill"
	desc ="A simple powered drill with a bolt bit"
	hitsound = list('sound/items/tools/tool-hit.ogg')
	icon_state = "drill_bolt"
	item_state = "drill"
	materials = list(MAT_METAL=150, MAT_SILVER=50)
	origin_tech = "materials=2;engineering=2" //done for balance reasons, making them high value for research, but harder to get
	force = 8 //might or might not be too high, subject to change
	throwforce = 8
	toolspeed = 0.7
	attack_verb = list("drilled", "screwed", "jabbed")
	action_button_name = "Change mode"
	random_color = FALSE

/obj/item/weapon/wrench/power/attack_self(mob/user)
	playsound(user, 'sound/items/change_drill.ogg', VOL_EFFECTS_MASTER)
	var/obj/item/weapon/screwdriver/power/s_drill = new
	to_chat(user, "<span class='notice'>You attach the screw driver bit to [src].</span>")
	qdel(src)
	user.put_in_active_hand(s_drill)

/*
 * Screwdriver
 */
/obj/item/weapon/screwdriver
	name = "screwdriver"
	desc = "You can be totally screwwy with this."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver_blue"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	force = 5.0
	w_class = ITEM_SIZE_TINY
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	g_amt = 0
	m_amt = 75
	hitsound = list('sound/items/tools/screwdriver-stab.ogg')
	attack_verb = list("stabbed")
	usesound = 'sound/items/Screwdriver.ogg'

	stab_eyes = TRUE

	var/random_color = TRUE

/obj/item/weapon/screwdriver/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is stabbing the [src.name] into \his temple! It looks like \he's trying to commit suicide.</span>", \
						"<span class='danger'>[user] is stabbing the [src.name] into \his heart! It looks like \he's trying to commit suicide.</span>"))
	return(BRUTELOSS)

/obj/item/weapon/screwdriver/atom_init(mapload, param_color)
	. = ..()
	if(random_color)
		if(!param_color)
			param_color = pick("red", "blue", "purple", "brown", "green", "yellow")
		icon_state = "screwdriver_[param_color]"
		item_state = "screwdriver_[param_color]"

	pixel_y = rand(-6, 6)
	pixel_x = rand(-4, 4)

/obj/item/weapon/screwdriver/power
	name = "Hand Drill"
	desc = "A simple hand drill with a screwdriver bit attached."
	hitsound = list('sound/items/drill_hit.ogg')
	icon_state = "drill_screw"
	item_state = "drill"
	materials = list(MAT_METAL=150, MAT_SILVER=50)
	origin_tech = "materials=2;engineering=2" //done for balance reasons, making them high value for research, but harder to get
	force = 8 //might or might not be too high, subject to change
	throwforce = 8
	throw_speed = 2
	throw_range = 3//it's heavier than a screw driver/wrench, so it does more damage, but can't be thrown as far
	toolspeed = 0.7
	attack_verb = list("drilled", "screwed", "jabbed","whacked")
	action_button_name = "Change mode"
	random_color = FALSE

/obj/item/weapon/screwdriver/power/attack_self(mob/user)
	playsound(user, 'sound/items/change_drill.ogg', VOL_EFFECTS_MASTER)
	var/obj/item/weapon/wrench/power/b_drill = new
	to_chat(user, "<span class='notice'>You attach the bolt driver bit to [src].</span>")
	qdel(src)
	user.put_in_active_hand(b_drill)
/*
 * Wirecutters
 */
/obj/item/weapon/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon = 'icons/obj/tools.dmi'
	icon_state = "cutters_blue"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	force = 6.0
	throw_speed = 2
	throw_range = 9
	w_class = ITEM_SIZE_SMALL
	m_amt = 80
	origin_tech = "materials=1;engineering=1"
	hitsound = list('sound/items/tools/wirecutters-pinch.ogg')
	attack_verb = list("pinched", "nipped")
	sharp = 1
	edge = 1
	usesound = 'sound/items/Wirecutter.ogg'
	var/random_color = TRUE

/obj/item/weapon/wirecutters/atom_init(mapload, param_color)
	. = ..()
	if(random_color)
		if(!param_color)
			param_color = pick("yellow","red","green","brown","blue")
		icon_state = "cutters_[param_color]"
		item_state = "cutters_[param_color]"

/obj/item/weapon/wirecutters/attack(mob/living/carbon/C, mob/user)
	if(istype(C) && C.handcuffed && istype(C.handcuffed, /obj/item/weapon/handcuffs/cable))
		usr.visible_message("\The [usr] cuts \the [C]'s restraints with \the [src]!",\
		"<span class='notice'>You cut \the [C]'s restraints with \the [src]!</span>",\
		"You hear cable being cut.")
		C.handcuffed = null
		if(C.buckled && C.buckled.buckle_require_restraints)
			C.buckled.unbuckle_mob()
		C.update_inv_handcuffed()
		return
	else
		..()

/obj/item/weapon/wirecutters/power
	name = "Jaws of Life"
	desc = "A set of jaws of life, the magic of science has managed to fit it down into a device small enough to fit in a tool belt. It's fitted with a cutting head."
	icon = 'icons/obj/tools.dmi'
	icon_state = "jaws_cutter"
	item_state = "jawsoflife"
	origin_tech = "materials=2;engineering=2"
	materials = list(MAT_METAL=150, MAT_SILVER=50)
	action_button_name = "Change mode"
	toolspeed = 0.7
	random_color = FALSE

/obj/item/weapon/wirecutters/power/attack_self(mob/user)
	playsound(user, 'sound/items/change_jaws.ogg', VOL_EFFECTS_MASTER)
	var/obj/item/weapon/crowbar/power/pryjaws = new
	to_chat(user, "<span class='notice'>You attach the pry jaws to [src].</span>")
	qdel(src)
	user.put_in_active_hand(pryjaws)

/*
 * Welding Tool
 */
/obj/item/weapon/weldingtool
	name = "welding tool"
	desc = "Apply the hot spot to the metal."
	icon = 'icons/obj/tools.dmi'
	hitsound = 'sound/items/tools/tool-hit.ogg'
	icon_state = "welder"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	action_button_name = "Switch Welding tool"
	usesound = 'sound/items/Welder2.ogg'

	//Amount of OUCH when it's thrown
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL

	//Cost to make in the autolathe
	m_amt = 70
	g_amt = 30

	//R&D tech level
	origin_tech = "engineering=1"

	//Welding tool specific stuff
	var/welding = 0 	//Whether or not the welding tool is off(0), on(1) or currently welding(2)
	var/status = 1 		//Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower)
	var/max_fuel = 20 	//The max amount of fuel the welder can hold

/obj/item/weapon/weldingtool/atom_init()
	. = ..()
//	var/random_fuel = min(rand(10,20),max_fuel)
	var/datum/reagents/R = new/datum/reagents(max_fuel)
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", max_fuel)


/obj/item/weapon/weldingtool/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "[src] contains [get_fuel()]/[max_fuel] units of fuel!")


/obj/item/weapon/weldingtool/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		if(welding)
			to_chat(user, "<span class='rose'>Stop welding first!</span>")
			return
		status = !status
		if(status)
			to_chat(user, "<span class='notice'>You resecure the welder.</span>")
		else
			to_chat(user, "<span class='info'>The welder can now be attached and modified.</span>")
		src.add_fingerprint(user)
		return

	if((!status) && (istype(I, /obj/item/stack/rods)))
		var/obj/item/stack/rods/R = I
		if(!R.use(1))
			return
		var/obj/item/weapon/flamethrower/F = new/obj/item/weapon/flamethrower(user.loc)
		forceMove(F)
		F.weldtool = src
		if (user.client)
			user.client.screen -= src
		if (user.r_hand == src)
			user.remove_from_mob(src)
		else
			user.remove_from_mob(src)
		src.master = F
		src.layer = initial(src.layer)
		user.remove_from_mob(src)
		if (user.client)
			user.client.screen -= src
		src.loc = F
		src.add_fingerprint(user)
		return

	return ..()

/obj/item/weapon/weldingtool/process()
	switch(welding)
		//If off
		if(0)
			hitsound = initial(hitsound)
			if(src.icon_state != "welder") //Check that the sprite is correct, if it isnt, it means toggle() was not called
				src.force = 3
				src.damtype = "brute"
				src.icon_state = initial(src.icon_state)
				src.welding = 0
			set_light(0)
			if (!istype(src, /obj/item/weapon/weldingtool/experimental))
				STOP_PROCESSING(SSobj, src)
			return
		//Welders left on now use up fuel, but lets not have them run out quite that fast
		if(1)
			hitsound = list('sound/items/Welder2.ogg')
			if(src.icon_state != "welder1") //Check that the sprite is correct, if it isnt, it means toggle() was not called
				src.force = 15
				src.damtype = "fire"
				src.icon_state = initial(src.icon_state) + "1"
			if(prob(5))
				use(1)
			light_color = LIGHT_COLOR_FIRE
			set_light(2)

		//If you're actually actively welding, use fuel faster.
		//Is this actually used or set anywhere? - Nodrak
		if(2)
			if(prob(75))
				use(1)


	//I'm not sure what this does. I assume it has to do with starting fires...
	//...but it doesnt check to see if the welder is on or not.
	var/turf/location = src.loc
	if(istype(location, /mob))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = get_turf(M)
	if (istype(location, /turf))
		location.hotspot_expose(700, 5, src)


/obj/item/weapon/weldingtool/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(istype(target, /obj/structure/reagent_dispensers) && get_dist(src, target) <= 1 && target.reagents.has_reagent("fuel"))
		var/obj/structure/reagent_dispensers/tank = target
		if (!welding)
			var/datum/reagent/R = tank.reagents.has_reagent("fuel")
			tank.reagents.trans_id_to(src, R.id, max_fuel)
			to_chat(user, "<span class='notice'>Welder refueled</span>")
			playsound(src, 'sound/effects/refill.ogg', VOL_EFFECTS_MASTER, null, null, -6)
			return
		else if(tank.explode(user))
			message_admins("[key_name_admin(user)] triggered a [tank] explosion. [ADMIN_JMP(user)]")
			log_game("[key_name(user)] triggered a [tank] explosion.")
			to_chat(user, "<span class='rose'>That was stupid of you.</span>")
			return
	if (src.welding)
		use(1)
		var/turf/location = get_turf(user)
		if (istype(location, /turf))
			location.hotspot_expose(700, 50, src)

			if(isliving(target))				//Welding can ignite mobs, splashed with fuel
				var/mob/living/L = target
				L.IgniteMob()
		if(isturf(target))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
			s.set_up(3, 1, target)
			s.start()
		else if(isobj(target))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
			s.set_up(3, 1, target)
			s.start()
	return


/obj/item/weapon/weldingtool/attack_self(mob/user)
	toggle()
	return

//Returns the amount of fuel in the welder
/obj/item/weapon/weldingtool/proc/get_fuel()
	return reagents.get_reagent_amount("fuel")

/obj/item/weapon/weldingtool/tool_use_check(mob/living/user, amount)
	return get_fuel() >= amount

//Removes fuel from the welding tool. If a mob is passed, it will perform an eyecheck on the mob. This should probably be renamed to use()
/obj/item/weapon/weldingtool/use(used = 1, mob/M = null)
	if(used < 0)
		stack_trace("[src.type]/use() called with a negative parameter [used]")
		return 0
	if(!welding || !check_fuel())
		return 0
	if(get_fuel() >= used)
		reagents.remove_reagent("fuel", used)
		check_fuel()
		if(M)
			eyecheck(M)
		return 1
	else
		if(M)
			to_chat(M, "<span class='notice'>You need more welding fuel to complete this task.</span>")
		return 0

//Returns whether or not the welding tool is currently on.
/obj/item/weapon/weldingtool/proc/isOn()
	return src.welding

/obj/item/weapon/weldingtool/get_current_temperature()
	if(isOn())
		return 3800
	else
		return 0

//Sets the welding state of the welding tool. If you see W.welding = 1 anywhere, please change it to W.setWelding(1)
//so that the welding tool updates accordingly
/obj/item/weapon/weldingtool/proc/setWelding(temp_welding)
	//If we're turning it on
	if(temp_welding > 0)
		if (use(1))
			hitsound = list('sound/items/Welder2.ogg')
			to_chat(usr, "<span class='info'>The [src] switches on.</span>")
			src.force = 15
			src.damtype = "fire"
			src.icon_state = initial(src.icon_state) + "1"
			START_PROCESSING(SSobj, src)
		else
			to_chat(usr, "<span class='info'>Need more fuel!</span>")
			src.welding = 0
			return
	//Otherwise
	else
		hitsound = initial(hitsound)
		to_chat(usr, "<span class='info'>The [src] switches off.</span>")
		src.force = 3
		src.damtype = "brute"
		src.icon_state = initial(src.icon_state)
		src.welding = 0

//Turns off the welder if there is no more fuel (does this really need to be its own proc?)
/obj/item/weapon/weldingtool/proc/check_fuel()
	if((get_fuel() <= 0) && welding)
		toggle(1)
		return 0
	return 1


//Toggles the welder off and on
/obj/item/weapon/weldingtool/proc/toggle(message = 0)
	if(!status)	return
	if(!usr) return
	src.welding = !( src.welding )
	if (src.welding)
		if (use(1))
			to_chat(usr, "<span class='notice'>You switch the [src] on.</span>")
			hitsound = list('sound/items/Welder2.ogg')
			src.force = 15
			src.damtype = "fire"
			src.icon_state = initial(src.icon_state) + "1"
			START_PROCESSING(SSobj, src)
		else
			to_chat(usr, "<span class='info'>Need more fuel!</span>")
			src.welding = 0
			return
	else
		if(!message)
			to_chat(usr, "<span class='notice'>You switch the [src] off.</span>")
		else
			to_chat(usr, "<span class='info'>The [src] shuts off!</span>")
		hitsound = initial(hitsound)
		src.force = 3
		src.damtype = "brute"
		src.icon_state = initial(src.icon_state)
		src.welding = 0

	if(usr.hand)
		usr.update_inv_l_hand()
	else
		usr.update_inv_r_hand()

//Decides whether or not to damage a player's eyes based on what they're wearing as protection
//Note: This should probably be moved to mob
/obj/item/weapon/weldingtool/proc/eyecheck(mob/user)
	if(!iscarbon(user))	return 1
	var/safety = user:eyecheck()
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/internal/eyes/IO = H.organs_by_name[O_EYES]
		if(H.species.flags[IS_SYNTHETIC])
			return
		switch(safety)
			if(1)
				to_chat(usr, "<span class='warning'>Your eyes sting a little.</span>")
				IO.damage += rand(1, 2)
				if(IO.damage > 12)
					user.eye_blurry += rand(3,6)
			if(0)
				to_chat(usr, "<span class='warning'>Your eyes burn.</span>")
				IO.damage += rand(2, 4)
				if(IO.damage > 10)
					IO.damage += rand(4,10)
			if(-1)
				to_chat(usr, "<span class='danger'>Your thermals intensify the welder's glow. Your eyes itch and burn severely.</span>")
				user.eye_blurry += rand(12,20)
				IO.damage += rand(12, 16)
		if(safety<2)

			if(IO.damage > 10)
				to_chat(user, "<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>")

			if (IO.damage >= IO.min_broken_damage)
				to_chat(user, "<span class='danger'>You go blind!</span>")
				user.sdisabilities |= BLIND
			else if (IO.damage >= IO.min_bruised_damage)
				to_chat(user, "<span class='danger'>You go blind!</span>")
				user.eye_blind = 5
				user.eye_blurry = 5
				user.disabilities |= NEARSIGHTED
				spawn(100)
					user.disabilities &= ~NEARSIGHTED
	return


/obj/item/weapon/weldingtool/largetank
	name = "Industrial Welding Tool"
	icon = 'icons/obj/tools.dmi'
	icon_state = "indwelder"
	max_fuel = 40
	m_amt = 70
	g_amt = 60
	origin_tech = "engineering=2"

/obj/item/weapon/weldingtool/hugetank
	name = "Upgraded Welding Tool"
	icon = 'icons/obj/tools.dmi'
	icon_state = "hugewelder"
	max_fuel = 80
	w_class = ITEM_SIZE_NORMAL
	m_amt = 70
	g_amt = 120
	origin_tech = "engineering=3"

/obj/item/weapon/weldingtool/experimental
	name = "Experimental Welding Tool"
	icon = 'icons/obj/tools.dmi'
	icon_state = "expwelder"
	max_fuel = 40
	w_class = ITEM_SIZE_NORMAL
	m_amt = 70
	g_amt = 120
	toolspeed = 0.5
	origin_tech = "materials=4;engineering=4;bluespace=2;phorontech=3"
	var/next_refuel_tick = 0

/obj/item/weapon/weldingtool/experimental/process()
	..()
	if((get_fuel() < max_fuel) && (next_refuel_tick < world.time) && !welding)
		next_refuel_tick = world.time + 2.5 SECONDS
		reagents.add_reagent("fuel", 1)
	if(!welding && (get_fuel() == max_fuel))
		STOP_PROCESSING(SSobj, src)
/*
 * Crowbar
 */

/obj/item/weapon/crowbar
	name = "crowbar"
	desc = "Used to remove floors and to pry open doors."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	force = 5.0
	throwforce = 7.0
	item_state = "crowbar"
	w_class = ITEM_SIZE_SMALL
	m_amt = 50
	origin_tech = "engineering=1"
	hitsound = list('sound/items/tools/crowbar-hit.ogg')
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	usesound = 'sound/items/Crowbar.ogg'

/obj/item/weapon/crowbar/red
	icon_state = "red_crowbar"
	item_state = "crowbar_red"

/obj/item/weapon/crowbar/power
	name = "Jaws of Life"
	desc = "A set of jaws of life, the magic of science has managed to fit it down into a device small enough to fit in a tool belt. It's fitted with a prying head"
	hitsound = list('sound/items/tools/tool-hit.ogg')
	icon_state = "jaws_pry"
	item_state = "jawsoflife"
	materials = list(MAT_METAL=150, MAT_SILVER=50)
	origin_tech = "materials=2;engineering=2"
	force = 15
	toolspeed = 0.7
	action_button_name = "Change mode"

/obj/item/weapon/crowbar/power/attack_self(mob/user)
	playsound(user, 'sound/items/change_jaws.ogg', VOL_EFFECTS_MASTER)
	var/obj/item/weapon/wirecutters/power/cutjaws = new
	to_chat(user, "<span class='notice'>You attach the cutting jaws to [src].</span>")
	qdel(src)
	user.put_in_active_hand(cutjaws)

/obj/item/weapon/weldingtool/attack(mob/M, mob/user, def_zone)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		var/obj/item/organ/external/BP = H.get_bodypart(def_zone)
		if(!BP)
			return
		if(!(BP.is_robotic()) || user.a_intent != INTENT_HELP)
			return ..()

		if(H.species.flags[IS_SYNTHETIC])
			if(M == user)
				to_chat(user, "<span class='rose'>You can't repair damage to your own body - it's against OH&S.</span>")
				return

		if(BP.brute_dam)
			BP.heal_damage(15,0,0,1)
			user.visible_message("<span class='rose'>\The [user] patches some dents on \the [M]'s [BP.name] with \the [src].</span>")
		else
			to_chat(user, "<span class='info'>Nothing to fix!</span>")

	else
		return ..()
