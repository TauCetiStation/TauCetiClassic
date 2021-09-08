/obj/machinery/artifact
	name = "alien artifact"
	desc = "A large alien device."
	icon = 'icons/obj/xenoarchaeology/artifacts.dmi'
	icon_state = "artifact_1"
	interact_offline = TRUE
	var/icon_num = 0
	density = TRUE
	///artifact first effect
	var/datum/artifact_effect/my_effect
	///artifact second effect
	var/datum/artifact_effect/secondary_effect
	///is artifact busy right now, used it harvester code
	var/being_used = 0
	///does our artifact needs an init, dont forget to init turfs in prebuild artifacts if needed
	var/need_init = TRUE
	///last scan time, used in process for proxy trigger
	var/last_scan = 0
	///how often do we scan
	var/scan_delay = 2 SECONDS
	///list of turfs around us
	var/list/turf/turfs_around = list()
	///list of mobs inside of turfs around us
	var/list/mob/mobs_around = list()
	///touch cooldown to prevent spam in /bumped
	var/touch_cooldown = 3 SECONDS
	///last time mob touched us
	var/last_time_touched = 0
	///our health
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

	//65% chance to have a secondary effect
	if(prob(65))
		effecttype = pick(global.valid_secondary_effect_types)
		secondary_effect = new effecttype(src)

	init_artifact_type()
	if(my_effect?.trigger == TRIGGER_PROXY || secondary_effect?.trigger == TRIGGER_PROXY)
		init_turfs_around()

/**
 * Adds a entered/exited signal to each turf around orange 3
 */
/obj/machinery/artifact/proc/init_turfs_around()
	for(var/turf/T in orange(3, src))
		RegisterSignal(T, list(COMSIG_ATOM_ENTERED), .proc/turf_around_enter)
		RegisterSignal(T, list(COMSIG_ATOM_EXITED), .proc/turf_around_exit)
		turfs_around += T

/**
 * Clears both mob/turf lists, unregisters entered sinal
 */
/obj/machinery/artifact/proc/clear_turfs_around()
	for(var/turf/T in turfs_around)
		UnregisterSignal(T, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
		turfs_around -= T
	for(var/M in mobs_around)
		mobs_around -= M

/**
 * Checks if entered atom is mob, adds it to proxy list
 */
/obj/machinery/artifact/proc/turf_around_enter(atom/source, atom/movable/mover, atom/oldLoc)
	if(istype(mover, /mob))
		mobs_around |= mover

/**
 * Checks if exited atom is mob, removes it from proxy list
 */
/obj/machinery/artifact/proc/turf_around_exit(atom/source, atom/movable/mover, atom/newLoc)
	mobs_around -= mover

/**
 * Rebuilds proxy trigger zone, does this on a move
 */
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

/**
 * Picks random artifact icon, changes its name, description, trigger method corresponding to a sprite
 */
/obj/machinery/artifact/proc/init_artifact_type()
	icon_num = pick(ARTIFACT_WIZARD_LARGE,  ARTIFACT_WIZARD_SMALL, ARTIFACT_MARTIAN_LARGE,
                    ARTIFACT_MARTIAN_SMALL, ARTIFACT_MARTIAN_PINK, ARTIFACT_CUBE,
                    ARTIFACT_PILLAR,        ARTIFACT_COMPUTER,	   ARTIFACT_VENTS, ARTIFACT_FLOATING,
                    ARTIFACT_CRYSTAL_GREEN) // 12th and 13th are just types of crystals, please ignore them at THAT point
	switch(icon_num)
		if(ARTIFACT_COMPUTER)
			name = "alien computer"
			desc = "It is covered in strange markings."
		if(ARTIFACT_PILLAR)
			name = "alien device"
			desc = "A large pillar, made of strange shiny metal."
		if(ARTIFACT_VENTS)
			name = "alien device"
			desc = "A large alien device, there appear to be some kind of vents in the side."
		if(ARTIFACT_FLOATING)
			name = "strange metal object"
			desc = "A large object made of tough green-shaded alien metal."
		if(ARTIFACT_CRYSTAL_GREEN)
			icon_num = pick(ARTIFACT_CRYSTAL_GREEN, ARTIFACT_CRYSTAL_PURPLE, ARTIFACT_CRYSTAL_BLUE) // now we pick a color
			name = "large crystal"
			desc = pick("It shines faintly as it catches the light.", "It appears to have a faint inner glow.",
                        "It seems to draw you inward as you look it at.", "Something twinkles faintly as you look at it.",
                        "It's mesmerizing to behold.")
	update_icon()

/obj/machinery/artifact/process()
	if(health <= 0)
		if(!QDELING(src))
			qdel(src)
	//if either of our effects rely on environmental factors, work that out
	if((my_effect?.trigger >= TRIGGER_HEAT && my_effect?.trigger <= TRIGGER_NITRO) ||\
	 (secondary_effect?.trigger >= TRIGGER_HEAT && secondary_effect.trigger <= TRIGGER_NITRO))
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/env = T.return_air()
		if(env)
			//COLD ACTIVATION
			if(env.temperature < 225)
				toggle_effects_on(TRIGGER_COLD)
			else toggle_effects_off(TRIGGER_COLD)
			if(env.temperature > 375)
			//HEAT ACTIVATION
				toggle_effects_on(TRIGGER_HEAT)
			else toggle_effects_off(TRIGGER_HEAT)
			//PHORON GAS ACTIVATION
			if(env.gas["phoron"] >= 10)
				toggle_effects_on(TRIGGER_PHORON)
			else toggle_effects_off(TRIGGER_PHORON)
			//OXYGEN GAS ACTIVATION
			if(env.gas["oxygen"] >= 10)
				toggle_effects_on(TRIGGER_OXY)
			else toggle_effects_off(TRIGGER_OXY)
			//CO2 GAS ACTIVATION
			if(env.gas["carbon_dioxide"] >= 10)
				toggle_effects_on(TRIGGER_CO2)
			else toggle_effects_off(TRIGGER_CO2)
			//NITROGEN GAS ACTIVATION
			if(env.gas["nitrogen"] >= 10)
				toggle_effects_on(TRIGGER_NITRO)
			else toggle_effects_off(TRIGGER_NITRO)
	
	if((my_effect?.trigger >= TRIGGER_PROXY || secondary_effect?.trigger >= TRIGGER_PROXY))
		//TRIGGER_PROXY ACTIVATION
		if(mobs_around.len != 0)
			if(world.time >= last_scan + scan_delay)
				last_scan = world.time
				toggle_effects_on(TRIGGER_PROXY)
		else
			toggle_effects_off(TRIGGER_PROXY)

/obj/machinery/artifact/examine(mob/user)
	..()
	switch(round(100 - (initial(health) / health)))
		if(85 to 100)
			to_chat(user, "Appears to have no structural damage.")
		if(65 to 85)
			to_chat(user, "Appears to have light structural damage.")
		if(45 to 65)
			to_chat(user, "Appears to have heavy structural damage.")
		if(10 to 45)
			to_chat(user, "Appears to have immirsed structural damage.")
		if(0 to 10)
			to_chat(user, "Appears to have to be barely intanct.")

/obj/machinery/artifact/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!Adjacent(user) && !IsAdminGhost(user))
		to_chat(user, "<span class='warning'> You can't reach [src] from here.</span>")
		return TRUE
	user.SetNextMove(CLICK_CD_MELEE)
	try_toggle_effects(TRIGGER_TOUCH)
	to_chat(user, "<b>You touch [src].</b>")

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
	else
		if(istype(W, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = W
			if(B.status)
				try_toggle_effects(TRIGGER_ENERGY)
		if(istype(W, /obj/item/weapon/melee/energy) ||\
			istype(W, /obj/item/weapon/melee/cultblade) ||\
			istype(W, /obj/item/weapon/card/emag) ||\
			ismultitool(W))
			try_toggle_effects(TRIGGER_ENERGY)
	if(my_effect?.trigger == TRIGGER_HEAT || secondary_effect?.trigger == TRIGGER_HEAT)
		if(istype(W, /obj/item/weapon/match))
			var/obj/item/weapon/match/M = W
			if(M.lit)
				try_toggle_effects(TRIGGER_HEAT)
		if(iswelder(W))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.isOn())
				try_toggle_effects(TRIGGER_HEAT)
		if(istype(W, /obj/item/weapon/lighter))
			var/obj/item/weapon/lighter/L = W
			if(L.lit)
				try_toggle_effects(TRIGGER_HEAT)
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
