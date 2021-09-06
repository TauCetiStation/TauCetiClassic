/obj/machinery/artifact
	name = "alien artifact"
	desc = "A large alien device."
	icon = 'icons/obj/xenoarchaeology/artifacts.dmi'
	icon_state = "artifact_1"
	interact_offline = TRUE
	var/icon_num = 0
	density = TRUE
	var/datum/artifact_effect/my_effect
	var/datum/artifact_effect/secondary_effect
	var/being_used = 0
	var/need_init = TRUE
	var/scan_radius = 3
	var/last_scan = 0
	var/scan_delay = 2 SECONDS
	var/list/turf/turfs_around = list()
	var/list/mob/mobs_around = list()
	var/are_mobs_inside_area = FALSE
	var/touch_cooldown = 3 SECONDS
	var/last_time_touched = 0
	var/health = 1000

/obj/machinery/artifact/Destroy()
	clear_turfs_around()
	do_destroy_effects()
	visible_message("<span class='danger'>[src] breaks in pieces, releasing a wave of energy</span>")
	return ..()

/obj/machinery/artifact/atom_init()
	. = ..()
	if(!need_init)
		return
	//setup primary effect - these are the main ones (mixed)
	var/effecttype = pick(global.valid_primary_effect_types)
	my_effect = new effecttype(src)

	//50% chance to have a secondary effect
	if(prob(50))
		effecttype = pick(global.valid_secondary_effect_types)
		secondary_effect = new effecttype(src)

	init_artifact_type()
	if(my_effect?.trigger == TRIGGER_PROXY || secondary_effect?.trigger == TRIGGER_PROXY)
		init_turfs_around()

/obj/machinery/artifact/proc/init_turfs_around()
	for(var/turf/T in orange(3, src))
		RegisterSignal(T, list(COMSIG_ATOM_ENTERED), .proc/turf_around_enter)
		RegisterSignal(T, list(COMSIG_ATOM_EXITED), .proc/turf_around_exit)
		turfs_around += T

/obj/machinery/artifact/proc/clear_turfs_around()
	for(var/turf/T in turfs_around)
		UnregisterSignal(T, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
		turfs_around -= T
	for(var/M in mobs_around)
		mobs_around -= M

/obj/machinery/artifact/proc/turf_around_enter(atom/source, atom/movable/mover, atom/oldLoc)
	if(istype(mover, /mob))
		mobs_around |= mover
	are_mobs_inside_area = TRUE

/obj/machinery/artifact/proc/turf_around_exit(atom/source, atom/movable/mover, atom/newLoc)
	mobs_around -= mover
	if(mobs_around.len != 0)
		are_mobs_inside_area = TRUE
	else
		are_mobs_inside_area =  FALSE

/obj/machinery/artifact/proc/rebuild_zone()
	clear_turfs_around()
	init_turfs_around()

/**
 * Tries to toggle both effects on or off if trigger is correct
 */
/obj/machinery/artifact/proc/try_toggle_effects(trigger)
	if(my_effect?.trigger == trigger)
		my_effect.ToggleActivate()
	if(secondary_effect?.trigger == trigger)
		secondary_effect.ToggleActivate(0)

/**
 * Tries to toggle both effects on if trigger is correct
 */
/obj/machinery/artifact/proc/toggle_effects_on(trigger)
	if(my_effect)
		try_turn_on_effect(trigger, my_effect)
	if(secondary_effect)
		try_turn_on_effect(trigger, secondary_effect, FALSE)

/**
 * Activates passed effect if trigger is correct and effect is not activated
 */
/obj/machinery/artifact/proc/try_turn_on_effect(trigger, datum/artifact_effect/my_effect, announce_triggered = TRUE)
	if(my_effect.trigger == trigger && !my_effect.activated)
		my_effect.ToggleActivate(announce_triggered)

/**
 * Deactivates both effects if trigger is correct
 */
/obj/machinery/artifact/proc/toggle_effects_off(trigger)
	if(my_effect)
		try_turn_off_effect(trigger, my_effect)
	if(secondary_effect)
		try_turn_off_effect(trigger, secondary_effect, FALSE)

/**
 * Deactivates passed effect if trigger is correct and effect is activated
 */
/obj/machinery/artifact/proc/try_turn_off_effect(trigger, datum/artifact_effect/my_effect, announce_triggered = TRUE)
	if(my_effect.trigger == trigger && my_effect.activated)
		my_effect.ToggleActivate(announce_triggered)

/**
 * Tries to do the destroy reaction of BOTH effects
 */
/obj/machinery/artifact/proc/do_destroy_effects()
	if(my_effect)
		my_effect.DoEffectDestroy()
	if(secondary_effect)
		secondary_effect.DoEffectDestroy()

/obj/machinery/artifact/proc/init_artifact_type()
	icon_num = pick(ARTIFACT_WIZARD_LARGE,  ARTIFACT_WIZARD_SMALL, ARTIFACT_MARTIAN_LARGE,
                    ARTIFACT_MARTIAN_SMALL, ARTIFACT_MARTIAN_PINK, ARTIFACT_CUBE,
                    ARTIFACT_PILLAR,        ARTIFACT_COMPUTER,	   ARTIFACT_VENTS, ARTIFACT_FLOATING,
                    ARTIFACT_CRYSTAL_GREEN) // 12th and 13th are just types of crystals, please ignore them at THAT point

	switch(icon_num)
		if(ARTIFACT_COMPUTER)
			name = "alien computer"
			desc = "It is covered in strange markings."
			if(prob(75))
				my_effect.trigger = TRIGGER_TOUCH

		if(ARTIFACT_PILLAR)
			name = "alien device"
			desc = "A large pillar, made of strange shiny metal."

		if(ARTIFACT_VENTS)
			name = "alien device"
			desc = "A large alien device, there appear to be some kind of vents in the side."
			if(prob(50))
				my_effect.trigger = pick(TRIGGER_ENERGY, TRIGGER_HEAT, TRIGGER_COLD,
                                         TRIGGER_PHORON, TRIGGER_OXY,  TRIGGER_CO2,
                                         TRIGGER_NITRO)
		if(ARTIFACT_FLOATING)
			name = "strange metal object"
			desc = "A large object made of tough green-shaded alien metal."
			if(prob(25))
				my_effect.trigger = pick(TRIGGER_WATER, TRIGGER_ACID, TRIGGER_VOLATILE, TRIGGER_TOXIN)

		if(ARTIFACT_CRYSTAL_GREEN)
			icon_num = pick(ARTIFACT_CRYSTAL_GREEN, ARTIFACT_CRYSTAL_PURPLE, ARTIFACT_CRYSTAL_BLUE) // now we pick a color
			name = "large crystal"
			desc = pick("It shines faintly as it catches the light.",
			"It appears to have a faint inner glow.",
			"It seems to draw you inward as you look it at.",
			"Something twinkles faintly as you look at it.",
			"It's mesmerizing to behold.")
			if(prob(50))
				my_effect.trigger = TRIGGER_ENERGY

	update_icon()

/obj/machinery/artifact/process()
	if(health <= 0)
		if(!QDELING(src))
			qdel(src)
	// if either of our effects rely on environmental factors, work that out
	var/trigger_cold = FALSE
	var/trigger_hot = FALSE
	var/trigger_phoron = FALSE
	var/trigger_oxy = FALSE
	var/trigger_co2 = FALSE
	var/trigger_nitro = FALSE
	if((my_effect.trigger >= TRIGGER_HEAT && my_effect.trigger <= TRIGGER_NITRO) ||\
	 (secondary_effect?.trigger >= TRIGGER_HEAT && secondary_effect.trigger <= TRIGGER_NITRO))
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/env = T.return_air()
		if(env)
			if(env.temperature < 225)
				trigger_cold = TRUE
			else if(env.temperature > 375)
				trigger_hot = TRUE

			if(env.gas["phoron"] >= 10)
				trigger_phoron = TRUE
			if(env.gas["oxygen"] >= 10)
				trigger_oxy = TRUE
			if(env.gas["carbon_dioxide"] >= 10)
				trigger_co2 = TRUE
			if(env.gas["nitrogen"] >= 10)
				trigger_nitro = TRUE

	// COLD ACTIVATION
	trigger_cold ? toggle_effects_on(TRIGGER_COLD) : toggle_effects_off(TRIGGER_COLD)
	// HEAT ACTIVATION
	trigger_hot ? toggle_effects_on(TRIGGER_HEAT) : toggle_effects_off(TRIGGER_HEAT)
	// PHORON GAS ACTIVATION
	trigger_phoron ? toggle_effects_on(TRIGGER_PHORON) : toggle_effects_off(TRIGGER_PHORON)
	// OXYGEN GAS ACTIVATION
	trigger_oxy ? toggle_effects_on(TRIGGER_OXY) : toggle_effects_off(TRIGGER_OXY)
	// CO2 GAS ACTIVATION
	trigger_co2 ? toggle_effects_on(TRIGGER_CO2) : toggle_effects_off(TRIGGER_CO2)
	// NITROGEN GAS ACTIVATION
	trigger_nitro ? toggle_effects_on(TRIGGER_NITRO) : toggle_effects_off(TRIGGER_NITRO)
	// TRIGGER_PROXY ACTIVATION
	if(are_mobs_inside_area)
		if(world.time >= last_scan + scan_delay)
			last_scan = world.time
			toggle_effects_on(TRIGGER_PROXY)
	else
		toggle_effects_off(TRIGGER_PROXY)

/obj/machinery/artifact/examine(mob/user)
	..()
	switch(round(100 - (initial(health) / health)))
		if(85 to 100)
			to_chat(user, "Looks brand new")
		if(65 to 85)
			to_chat(user, "Looks slightly damaged.")
		if(45 to 65)
			to_chat(user, "Looks badly damaged.")
		if(0 to 45)
			to_chat(user, "Looks heavily damaged.")

/obj/machinery/artifact/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!Adjacent(user) && !IsAdminGhost(user))
		to_chat(user, "<span class='warning'> You can't reach [src] from here.</span>")
		return TRUE
	user.SetNextMove(CLICK_CD_MELEE)
	try_toggle_effects(TRIGGER_TOUCH)
	if(my_effect.trigger == TRIGGER_TOUCH)
		to_chat(user, "<b>You touch [src].</b>")
	else
		to_chat(user, "<b>You touch [src],</b> [pick("but nothing of note happens", "but nothing happens", "but nothing interesting happens", "but you notice nothing different", "but nothing seems to have happened")].")

	if(my_effect.release_method == ARTIFACT_EFFECT_TOUCH)
		my_effect.DoEffectTouch(user)

	if(secondary_effect?.release_method == ARTIFACT_EFFECT_TOUCH && secondary_effect.activated)
		secondary_effect.DoEffectTouch(user)

/obj/machinery/artifact/attackby(obj/item/weapon/W, mob/living/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(istype(W, /obj/item/weapon/reagent_containers))
		if(W.reagents.has_reagent("hydrogen", 1) || W.reagents.has_reagent("water", 1))
			try_toggle_effects(TRIGGER_WATER)
		else if(W.reagents.has_reagent("acid", 1) || W.reagents.has_reagent("pacid", 1) || W.reagents.has_reagent("diethylamine", 1))
			try_toggle_effects(TRIGGER_ACID)
		else if(W.reagents.has_reagent("phoron", 1) || W.reagents.has_reagent("thermite", 1))
			try_toggle_effects(TRIGGER_VOLATILE)
		else if(W.reagents.has_reagent("toxin", 1) || W.reagents.has_reagent("cyanide", 1) || W.reagents.has_reagent("amanitin", 1) || W.reagents.has_reagent("neurotoxin", 1))
			try_toggle_effects(TRIGGER_TOXIN)
	else if(istype(W,/obj/item/weapon/melee/baton) && W:status ||\
			istype(W,/obj/item/weapon/melee/energy) ||\
			istype(W,/obj/item/weapon/melee/cultblade) ||\
			istype(W,/obj/item/weapon/card/emag) ||\
			ismultitool(W))
		try_toggle_effects(TRIGGER_ENERGY)

	else if(istype(W,/obj/item/weapon/match) && W:lit ||\
			iswelder(W) && W:isOn() ||\
			istype(W,/obj/item/weapon/lighter) && W:lit)
		try_toggle_effects(TRIGGER_HEAT)
	else
		..()
		health -= W.force
		try_toggle_effects(TRIGGER_FORCE)

/obj/machinery/artifact/Bumped(atom/AM)
	..()
	if(isobj(AM))
		var/obj/O = AM
		if(O.throwforce >= 10)
			try_toggle_effects(TRIGGER_FORCE)
	if(world.time >= last_time_touched + touch_cooldown)
		last_time_touched = world.time
		try_toggle_effects(TRIGGER_TOUCH)
		if(my_effect.release_method == ARTIFACT_EFFECT_TOUCH && my_effect.activated && prob(50))
			my_effect.DoEffectTouch(AM)
		if(secondary_effect && secondary_effect.release_method == ARTIFACT_EFFECT_TOUCH && secondary_effect.activated && prob(50))
			secondary_effect.DoEffectTouch(AM)
	to_chat(AM, "<b>You accidentally touch [src].</b>")
	..()

/obj/machinery/artifact/bullet_act(obj/item/projectile/P)
	if(istype(P,/obj/item/projectile/bullet) ||\
		istype(P,/obj/item/projectile/hivebotbullet))
		try_toggle_effects(TRIGGER_FORCE)
		health -= P.damage

	else if(istype(P,/obj/item/projectile/beam) ||\
		istype(P,/obj/item/projectile/ion) ||\
		istype(P,/obj/item/projectile/energy))
		try_toggle_effects(TRIGGER_ENERGY)
		health -= P.damage

/obj/machinery/artifact/ex_act(severity)
	switch(severity)
		if(1.0) 
			qdel(src)
		if(2.0)
			if(prob(50))
				qdel(src)
			else
				try_toggle_effects(TRIGGER_FORCE)
				try_toggle_effects(TRIGGER_HEAT)
		if(3.0)
			try_toggle_effects(TRIGGER_FORCE)
			try_toggle_effects(TRIGGER_HEAT)
	return

/obj/machinery/artifact/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()

	if(ISDIAGONALDIR(Dir))
		return .

	if(pulledby)
		Bumped(pulledby)
	my_effect?.UpdateMove()
	secondary_effect?.UpdateMove()

	if(my_effect?.release_method == TRIGGER_PROXY || secondary_effect?.release_method == TRIGGER_PROXY)
		rebuild_zone()

/obj/machinery/artifact/update_icon()
	var/check_activity = null
	if(my_effect && my_effect.activated)
		check_activity = "_active"
	icon_state = "artifact_[icon_num][check_activity]"
	return
