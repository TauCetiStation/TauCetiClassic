/* Tools!
 * Note: Multitools are /obj/item/device
 *
 * Contains:
 * 		Wrench
 * 		Screwdriver
 * 		Wirecutters
 * 		Welding Tool
 * 		Crowbar
 * 		Hand Drill
 * 		Jaws of Life
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
	w_class = SIZE_TINY
	m_amt = 150
	origin_tech = "materials=1;engineering=1"
	hitsound = list('sound/items/tools/crowbar-hit.ogg')
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	usesound = 'sound/items/Ratchet.ogg'
	var/random_color = TRUE
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)

	qualities = list(
		QUALITY_WRENCHING = 1
	)

/obj/item/weapon/wrench/atom_init(mapload, param_color)
	. = ..()
	if(random_color)
		if(!param_color)
			param_color = pick("black","red","green","blue","default")
		icon_state = "wrench_[param_color]"
		item_state = "wrench_[param_color]"

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
	w_class = SIZE_MINUSCULE
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	g_amt = 0
	m_amt = 75
	hitsound = list('sound/items/tools/screwdriver-stab.ogg')
	attack_verb = list("stabbed")
	usesound = 'sound/items/Screwdriver.ogg'
	qualities = list(
		QUALITY_SCREWING = 1
	)
	stab_eyes = TRUE

	var/random_color = TRUE

	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)

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
	w_class = SIZE_TINY
	m_amt = 80
	origin_tech = "materials=1;engineering=1"
	hitsound = list('sound/items/tools/wirecutters-pinch.ogg')
	attack_verb = list("pinched", "nipped")
	sharp = 1
	edge = 1
	usesound = 'sound/items/Wirecutter.ogg'
	var/random_color = TRUE
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)
	qualities = list(
		QUALITY_CUTTING = 1
	)

/obj/item/weapon/wirecutters/atom_init(mapload, param_color)
	. = ..()
	if(random_color)
		if(!param_color)
			param_color = pick("yellow","red","green","brown","blue")
		icon_state = "cutters_[param_color]"
		item_state = "cutters_[param_color]"

/obj/item/weapon/wirecutters/attack(mob/living/carbon/C, mob/user)
	if(istype(C) && C.handcuffed && user.a_intent == INTENT_HELP)
		var/obj/item/weapon/handcuffs/cuffs = C.handcuffed
		if(do_mob(user, C, 2 SECONDS) && C.unEquip(cuffs))
			QDEL_NULL(cuffs)
			usr.visible_message("\The [usr] cuts \the [C]'s handcuffs with \the [src]!",\
			"<span class='notice'>You cut \the [C]'s handcuffs with \the [src]!</span>",\
			"You hear handcuffs being cut.")
			if(C.buckled && C.buckled.buckle_require_restraints)
				C.buckled.unbuckle_mob()
	else
		..()

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
	usesound = 'sound/items/Welder2.ogg'

	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_TINY
	qualities = list(
		QUALITY_WELDING = 1
	)

	m_amt = 70 // Cost to make in the autolathe
	g_amt = 30

	origin_tech = "engineering=1" // R&D tech level

	var/rigged = FALSE			// Welding tool is rigged TRUE/FALSE
	var/active = FALSE          // Welding tool is off or on
	var/welding = FALSE         // While welding something - TRUE
	var/secured = TRUE          // Welder is secured or unsecured (able to attach rods to it to make a flamethrower)
	var/max_fuel = 20           // The max amount of fuel the welder can hold
	var/image/welding_sparks    // Welding overlay for targets

	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)
	item_action_types = list(/datum/action/item_action/hands_free/switch_welding_tool)

/datum/action/item_action/hands_free/switch_welding_tool
	name = "Switch Welding tool"

/obj/item/weapon/weldingtool/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(max_fuel)
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", max_fuel)
	welding_sparks = image('icons/effects/effects.dmi', "welding_sparks", layer = ABOVE_LIGHTING_LAYER)
	welding_sparks.plane = LIGHTING_LAMPS_PLANE

/obj/item/weapon/weldingtool/examine(mob/user)
	..()
	if(src in user)
		if (rigged)
			to_chat(user, "[src] contains [get_fuel()]/[max_fuel] units of mixture!")
		else
			to_chat(user, "[src] contains [get_fuel()]/[max_fuel] units of fuel!")

/obj/item/weapon/weldingtool/attackby(obj/item/I, mob/user, params)
	if(isscrewing(I))
		if(active)
			to_chat(user, "<span class='rose'>Off [src], first!</span>")
			return
		secured = !secured
		if(secured)
			to_chat(user, "<span class='notice'>You secure [src].</span>")
		else
			to_chat(user, "<span class='info'>[src] can now be attached and modified.</span>")
		add_fingerprint(user)
		return
	if(!secured && istype(I, /obj/item/stack/rods))
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
		add_fingerprint(user)
		return
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I
		if(S.reagents.has_reagent("phoron", 5))
			if(get_fuel() + 5 > max_fuel)
				to_chat(user, "[src] is full, you cant inject anything into it.")
			else if (active)
				to_chat(user, "[src] is active, turn it off to inject.")
			else
				user.SetNextMove(CLICK_CD_INTERACT)
				to_chat(user, "You inject the solution into the [src].")
				log_admin("LOG: [key_name(user)] injected a weldingtool with phoron, rigging it to explode.")
				message_admins("LOG: [key_name_admin(user)] injected a weldingtool with phoron, rigging it to explode. [ADMIN_JMP(user)]")
				rigged = TRUE
				S.reagents.remove_reagent("phoron", 5)
				reagents.add_reagent("phoron", 5)
		else
			to_chat(user, "You need something dangerous to rig this tool.")
	return ..()

/obj/item/weapon/weldingtool/process()
	if(active)
		hitsound = SOUNDIN_LASERACT
		if(icon_state != "welder1") // Check that the sprite is correct, if it isnt, it means toggle() was not called
			force = 15
			damtype = BURN
			icon_state = initial(icon_state) + "1"
		if(prob(5)) // passive fuel burning
			use(1)
		light_color = LIGHT_COLOR_FIRE
		set_light(2)
	else
		hitsound = initial(hitsound)
		if(icon_state != "welder") // Check that the sprite is correct, if it isnt, it means toggle() was not called
			force = 3
			damtype = BRUTE
			icon_state = initial(icon_state)
			active = FALSE
		set_light(0)
		if(!istype(src, /obj/item/weapon/weldingtool/experimental))
			STOP_PROCESSING(SSobj, src)
		return

	var/turf/location = src.loc
	if(istype(location, /mob))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = get_turf(M)
	if (istype(location, /turf))
		location.hotspot_expose(700, 5, src)

/obj/item/weapon/weldingtool/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(istype(target, /obj/structure/reagent_dispensers) && target.reagents.has_reagent("fuel"))
		var/obj/structure/reagent_dispensers/tank = target
		if (!active)
			var/datum/reagent/R = tank.reagents.has_reagent("fuel")
			if(tank.reagents.trans_id_to(src, R.id, max_fuel))
				to_chat(user, "<span class='notice'>[src] refueled by [tank].</span>")
				playsound(src, 'sound/effects/refill.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -6)
			return
		else if(tank.explode(user))
			message_admins("[key_name_admin(user)] triggered a [tank] explosion. [ADMIN_JMP(user)]")
			log_game("[key_name(user)] triggered a [tank] explosion.")
			to_chat(user, "<span class='rose'>That was stupid of you.</span>")
			return
	if (isOn())
		use(1)
		var/turf/location = get_turf(user)
		if (isturf(location))
			location.hotspot_expose(700, 50, src)
		if(isturf(target))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
			s.set_up(3, 1, target)
			s.start()
		else if(isobj(target))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
			s.set_up(3, 1, target)
			s.start()
	return

/obj/item/weapon/weldingtool/attack(mob/living/M, mob/living/user, def_zone)
	. = ..()
	if (isOn() && M)
		use(1)
		M.IgniteMob()

/obj/item/weapon/weldingtool/attack_self(mob/user)
	toggle()
	return

// Returns the amount of fuel in the welder
/obj/item/weapon/weldingtool/proc/get_fuel()
	return reagents.get_reagent_amount("fuel") + reagents.get_reagent_amount("phoron")

/obj/item/weapon/weldingtool/use_tool(atom/target, mob/living/user, delay, amount = 0, volume = 0, quality = null, datum/callback/extra_checks, required_skills_override, skills_speed_bonus = -0.4, can_move = FALSE)
	target.add_overlay(welding_sparks)
	INVOKE_ASYNC(src, PROC_REF(start_welding), target)
	var/datum/callback/checks  = CALLBACK(src, PROC_REF(check_active_and_extra), extra_checks)
	. = ..(target, user, delay, amount, volume, extra_checks = checks, required_skills_override = required_skills_override, skills_speed_bonus = skills_speed_bonus)
	stop_welding()
	target.cut_overlay(welding_sparks)

/obj/item/weapon/weldingtool/proc/start_welding(atom/target) // Process of welding something
	var/datum/effect/effect/system/spark_spread/spark = new /datum/effect/effect/system/spark_spread()
	spark.set_up(1, 1, target)
	welding = TRUE
	while(welding)
		sleep(5)
		spark.start()
		if(prob(10))
			use(1)

/obj/item/weapon/weldingtool/proc/stop_welding()
	welding = FALSE

/obj/item/weapon/weldingtool/proc/check_active_and_extra(datum/callback/extra_checks)
	if(!isOn() || !check_fuel())
		return FALSE
	if(!extra_checks)
		return TRUE
	return extra_checks.Invoke()

/obj/item/weapon/weldingtool/tool_use_check(mob/living/user, amount)
	return get_fuel() >= amount

// Removes fuel from the welding tool. If a mob is passed, it will perform an eyecheck on the mob. This should probably be renamed to use()
/obj/item/weapon/weldingtool/use(used = 1, mob/M = null)
	if(used < 0)
		stack_trace("[src.type]/use() called with a negative parameter")
		return 0
	if(!active || !check_fuel())
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

// Is welding tool currently on?
/obj/item/weapon/weldingtool/proc/isOn()
	return active

/obj/item/weapon/weldingtool/get_current_temperature()
	if(isOn())
		return 3800
	else
		return 0

// Turns off the welder if there is no more fuel (does this really need to be its own proc?)
/obj/item/weapon/weldingtool/proc/check_fuel()
	if((get_fuel() <= 0) && active)
		toggle(1)
		return 0
	return 1


// Toggles the welder off and on
/obj/item/weapon/weldingtool/proc/toggle(message = 0)
	if(!secured) return
	if(!usr) return
	active = !active
	if (isOn())
		if (rigged)
			var/turf/T = get_turf(src.loc)
			var/phoron =  reagents.get_reagent_amount("phoron")
			var/devast = (phoron >= 80) ? 1 : 0
			var/area = ceil(phoron / 20)
			log_admin("LOG: Rigged weldingtool explosion, last touched by [fingerprintslast]")
			message_admins("LOG: Rigged weldingtool explosion, last touched by [fingerprintslast] [ADMIN_JMP(T)]")
			explosion(T, devast, area, area * 2, area * 4)
			qdel(src)
		else if (use(1))
			playsound(loc, 'sound/items/tools/welderactivate.ogg', VOL_EFFECTS_MASTER)
			to_chat(usr, "<span class='notice'>You switch the [src] on.</span>")
			hitsound = SOUNDIN_LASERACT
			src.force = 15
			src.damtype = BURN
			src.icon_state = initial(src.icon_state) + "1"
			START_PROCESSING(SSobj, src)
		else
			to_chat(usr, "<span class='info'>Need more fuel!</span>")
			src.active = FALSE
			return
	else
		playsound(loc, 'sound/items/tools/welderdeactivate.ogg', VOL_EFFECTS_MASTER)
		if(!message)
			to_chat(usr, "<span class='notice'>You switch the [src] off.</span>")
		else
			to_chat(usr, "<span class='info'>The [src] shuts off!</span>")
		hitsound = initial(hitsound)
		src.force = 3
		src.damtype = BRUTE
		src.icon_state = initial(src.icon_state)
		src.active = FALSE

	update_inv_mob()
	update_item_actions()

// Decides whether or not to damage a player's eyes based on what they're wearing as protection
// Note: This should probably be moved to mob
/obj/item/weapon/weldingtool/proc/eyecheck(mob/user)
	if(!iscarbon(user)) return 1
	var/safety = user:eyecheck()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/internal/eyes/IO = H.organs_by_name[O_EYES]
		if(H.species.flags[IS_SYNTHETIC])
			return
		switch(safety)
			if(1)
				to_chat(usr, "<span class='warning'>Your eyes sting a little.</span>")
				IO.damage += rand(1, 2)
				if(IO.damage > 12)
					user.adjustBlurriness(rand(3,6))
			if(0)
				to_chat(usr, "<span class='warning'>Your eyes burn.</span>")
				IO.damage += rand(2, 4)
				H.flash_eyes()
				if(IO.damage > 10)
					IO.damage += rand(4,10)
			if(-1)
				to_chat(usr, "<span class='danger'>Your thermals intensify the welder's glow. Your eyes itch and burn severely.</span>")
				H.flash_eyes()
				user.adjustBlurriness(rand(12,20))
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
				user.adjustBlurriness(5)
				user.become_nearsighted(EYE_DAMAGE_TEMPORARY_TRAIT)
				addtimer(CALLBACK(user, TYPE_PROC_REF(/mob, cure_nearsighted), EYE_DAMAGE_TEMPORARY_TRAIT), 10 SECONDS, TIMER_STOPPABLE)
	return


/obj/item/weapon/weldingtool/largetank
	name = "industrial welding tool"
	icon = 'icons/obj/tools.dmi'
	icon_state = "indwelder"
	max_fuel = 40
	m_amt = 70
	g_amt = 60
	origin_tech = "engineering=2"

/obj/item/weapon/weldingtool/hugetank
	name = "upgraded welding tool"
	icon = 'icons/obj/tools.dmi'
	icon_state = "hugewelder"
	max_fuel = 80
	w_class = SIZE_SMALL
	m_amt = 70
	g_amt = 120
	origin_tech = "engineering=3"

/obj/item/weapon/weldingtool/experimental
	name = "experimental welding tool"
	icon = 'icons/obj/tools.dmi'
	icon_state = "expwelder"
	max_fuel = 40
	w_class = SIZE_SMALL
	m_amt = 70
	g_amt = 120
	toolspeed = 0.5
	origin_tech = "materials=4;engineering=4;bluespace=2;phorontech=3"
	var/next_refuel_tick = 0

/obj/item/weapon/weldingtool/experimental/atom_init()
	.=..()
	welding_sparks = image('icons/effects/effects.dmi', "exp_welding_sparks", ABOVE_LIGHTING_LAYER)

/obj/item/weapon/weldingtool/experimental/process()
	..()
	if((get_fuel() < max_fuel) && (next_refuel_tick < world.time) && !active)
		next_refuel_tick = world.time + 2.5 SECONDS
		reagents.add_reagent("fuel", 1)
	if(!active && (get_fuel() == max_fuel))
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

	w_class = SIZE_SMALL

	m_amt = 50
	origin_tech = "engineering=1"
	hitsound = list('sound/items/tools/crowbar-hit.ogg')
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	usesound = 'sound/items/Crowbar.ogg'
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)

	qualities = list(
		QUALITY_PRYING = 1
	)

/obj/item/weapon/crowbar/red
	name = "emergency crowbar"
	desc = "A little emergency crowbar, used to open unpowered doors and emergency shutters."
	icon_state = "red_crowbar"
	item_state = "crowbar_red"
	force = 4.0
	throwforce = 5.0

	w_class = SIZE_TINY
	m_amt = 15

	qualities = list(
		QUALITY_PRYING = 0.7
	)

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

		if(H.check_pierce_protection(target_zone = def_zone))
			to_chat(user, "<span class='rose'>There is no exposed surface for repair.</span>")
			return

		if(BP.brute_dam)
			if(!use(1, user))
				return
			BP.heal_damage(15,0,0,1)
			user.visible_message("<span class='rose'>\The [user] patches some dents on \the [M]'s [BP.name] with \the [src].</span>")
		else
			to_chat(user, "<span class='info'>Nothing to fix!</span>")

	else
		return ..()

/obj/item/weapon/multi
	var/mode = FALSE
	w_class = SIZE_TINY

/obj/item/weapon/multi/hand_drill
	name = "Hand Drill"
	desc ="A simple powered drill with a bolt bit"
	hitsound = list('sound/items/tools/tool-hit.ogg')
	icon = 'icons/obj/tools.dmi'
	icon_state = "drill_bolt"
	item_state = "drill"
	materials = list(MAT_METAL=150, MAT_SILVER=50)
	origin_tech = "materials=2;engineering=2" //done for balance reasons, making them high value for research, but harder to get
	force = 8 //might or might not be too high, subject to change
	throwforce = 8
	toolspeed = 0.7
	attack_verb = list("drilled", "screwed", "jabbed")
	qualities = list(
		QUALITY_WRENCHING = 1
	)
	item_action_types = list(/datum/action/item_action/hands_free/change_mode)

/datum/action/item_action/hands_free/change_mode
	name = "Change mode"

/obj/item/weapon/multi/hand_drill/attack_self(mob/user)
	mode = !mode
	playsound(user, 'sound/items/change_drill.ogg', VOL_EFFECTS_MASTER)
	if(mode)
		qualities = list(
			QUALITY_SCREWING = 1
		)
		icon_state = "drill_screw"
		to_chat(user, "<span class='notice'>You attach the screw driver bit to [src].</span>")
	else
		qualities = list(
			QUALITY_WRENCHING = 1
		)
		icon_state = "drill_bolt"
		to_chat(user, "<span class='notice'>You attach the bolt driver bit to [src].</span>")
	update_item_actions()

/obj/item/weapon/multi/jaws_of_life
	name = "Jaws of Life"
	desc = "A set of jaws of life, the magic of science has managed to fit it down into a device small enough to fit in a tool belt. It's fitted with a cutting head."
	icon = 'icons/obj/tools.dmi'
	icon_state = "jaws_cutter"
	item_state = "jawsoflife"
	origin_tech = "materials=2;engineering=2"
	materials = list(MAT_METAL=150, MAT_SILVER=50)
	toolspeed = 0.7
	sharp = 1
	qualities = list(
		QUALITY_CUTTING = 1
	)
	item_action_types = list(/datum/action/item_action/hands_free/change_mode)

/datum/action/item_action/hands_free/change_mode
	name = "Change mode"

/obj/item/weapon/multi/jaws_of_life/attack_self(mob/user)
	mode = !mode
	playsound(user, 'sound/items/change_jaws.ogg', VOL_EFFECTS_MASTER)
	if(mode)
		qualities = list(
			QUALITY_PRYING = 1
		)
		sharp = 0
		icon_state = "jaws_pry"
		to_chat(user, "<span class='notice'>You attach the pry jaws to [src].</span>")
	else
		qualities = list(
			QUALITY_CUTTING = 1
		)
		sharp = 1
		icon_state = "jaws_cutter"
		to_chat(user, "<span class='notice'>You attach the cutting jaws to [src].</span>")
	update_item_actions()
