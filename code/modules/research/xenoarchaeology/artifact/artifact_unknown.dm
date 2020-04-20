/obj/machinery/artifact
	name = "alien artifact"
	desc = "A large alien device."
	icon = 'icons/obj/xenoarchaeology/artifacts.dmi'
	icon_state = "artifact_1"
	interact_offline = TRUE
	var/icon_num = 0
	density = 1
	var/datum/artifact_effect/my_effect
	var/datum/artifact_effect/secondary_effect
	var/being_used = 0
	var/need_inicial = 1
	var/scan_radius = 3
	var/last_scan = 0
	var/scan_delay = 20

/obj/machinery/artifact/atom_init()
	. = ..()

	// setup primary effect - these are the main ones (mixed)
	if(need_inicial == 1)
		var/effecttype = pick(global.valid_primary_effect_types)
		my_effect = new effecttype(src)

		// 50% chance to have a secondary stealthy (and mostly bad) effect
		if(prob(50))
			effecttype = pick(global.valid_secondary_effect_types)
			secondary_effect = new effecttype(src)
			if(prob(50))
				secondary_effect.ToggleActivate(0)

		icon_num = pick(ARTIFACT_WIZARD_LARGE,
						ARTIFACT_WIZARD_SMALL,
						ARTIFACT_MARTIAN_LARGE,
						ARTIFACT_MARTIAN_SMALL,
						ARTIFACT_MARTIAN_PINK,
						ARTIFACT_CUBE,
						ARTIFACT_PILLAR,
						ARTIFACT_COMPUTER,
						ARTIFACT_VENTS,
						ARTIFACT_FLOATING,
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
					my_effect.trigger = pick(	TRIGGER_ENERGY,
												TRIGGER_HEAT,
												TRIGGER_COLD,
												TRIGGER_PHORON,
												TRIGGER_OXY,
												TRIGGER_CO2,
												TRIGGER_NITRO,
												TRIGGER_VIEW)

			if(ARTIFACT_FLOATING)
				name = "strange metal object"
				desc = "A large object made of tough green-shaded alien metal."
				if(prob(25))
					my_effect.trigger = pick(	TRIGGER_WATER,
												TRIGGER_ACID,
												TRIGGER_VOLATILE,
												TRIGGER_TOXIN)

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

	var/turf/L = loc
	if(isnull(L) || !istype(L)) 	// We're inside a container or on null turf, either way stop processing effects
		return

	if(my_effect)
		my_effect.process()
	if(secondary_effect)
		secondary_effect.process()

	if(pulledby)
		Bumped(pulledby)

	// if either of our effects rely on environmental factors, work that out
	var/trigger_cold = FALSE
	var/trigger_hot = FALSE
	var/trigger_phoron = FALSE
	var/trigger_oxy = FALSE
	var/trigger_co2 = FALSE
	var/trigger_nitro = FALSE
	if( (my_effect.trigger >= TRIGGER_HEAT && my_effect.trigger <= TRIGGER_NITRO) || (secondary_effect && secondary_effect.trigger >= TRIGGER_HEAT && secondary_effect.trigger <= TRIGGER_NITRO) )
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
	if(trigger_cold)
		if(my_effect.trigger == TRIGGER_COLD && !my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_COLD && !secondary_effect.activated)
			secondary_effect.ToggleActivate(0)
	else
		if(my_effect.trigger == TRIGGER_COLD && my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_COLD && secondary_effect.activated)
			secondary_effect.ToggleActivate(0)

	// HEAT ACTIVATION
	if(trigger_hot)
		if(my_effect.trigger == TRIGGER_HEAT && !my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_HEAT && !secondary_effect.activated)
			secondary_effect.ToggleActivate(0)
	else
		if(my_effect.trigger == TRIGGER_HEAT && my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_HEAT && secondary_effect.activated)
			secondary_effect.ToggleActivate(0)

	// PHORON GAS ACTIVATION
	if(trigger_phoron)
		if(my_effect.trigger == TRIGGER_PHORON && !my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_PHORON && !secondary_effect.activated)
			secondary_effect.ToggleActivate(0)
	else
		if(my_effect.trigger == TRIGGER_PHORON && my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_PHORON && secondary_effect.activated)
			secondary_effect.ToggleActivate(0)

	// OXYGEN GAS ACTIVATION
	if(trigger_oxy)
		if(my_effect.trigger == TRIGGER_OXY && !my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_OXY && !secondary_effect.activated)
			secondary_effect.ToggleActivate(0)
	else
		if(my_effect.trigger == TRIGGER_OXY && my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_OXY && secondary_effect.activated)
			secondary_effect.ToggleActivate(0)

	// CO2 GAS ACTIVATION
	if(trigger_co2)
		if(my_effect.trigger == TRIGGER_CO2 && !my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_CO2 && !secondary_effect.activated)
			secondary_effect.ToggleActivate(0)
	else
		if(my_effect.trigger == TRIGGER_CO2 && my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_CO2 && secondary_effect.activated)
			secondary_effect.ToggleActivate(0)

	// NITROGEN GAS ACTIVATION
	if(trigger_nitro)
		if(my_effect.trigger == TRIGGER_NITRO && !my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_NITRO && !secondary_effect.activated)
			secondary_effect.ToggleActivate(0)
	else
		if(my_effect.trigger == TRIGGER_NITRO && my_effect.activated)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_NITRO && secondary_effect.activated)
			secondary_effect.ToggleActivate(0)

	// TRIGGER_PROXY ACTIVATION
	if(my_effect.trigger == TRIGGER_VIEW)
		if(world.time >= last_scan + scan_delay)
			last_scan = world.time
			var/trigger_near = 0
			var/turf/mainloc = get_turf(src)
			for(var/mob/living/A in view(scan_radius,mainloc))
				if ((A)&&(A.stat != DEAD))
					trigger_near = 1
					break
				else
					trigger_near = 0

			if(trigger_near)
				if(my_effect.trigger == TRIGGER_VIEW && !my_effect.activated)
					my_effect.ToggleActivate()
				if(secondary_effect && secondary_effect.trigger == TRIGGER_VIEW && !secondary_effect.activated)
					secondary_effect.ToggleActivate(0)
			else
				if(my_effect.trigger == TRIGGER_VIEW && my_effect.activated)
					my_effect.ToggleActivate()
				if(secondary_effect && secondary_effect.trigger == TRIGGER_VIEW && secondary_effect.activated)
					secondary_effect.ToggleActivate(0)

/obj/machinery/artifact/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(!in_range(src, user) && !IsAdminGhost(user))
		to_chat(user, "<span class='warning'> You can't reach [src] from here.</span>")
		return 1
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.gloves)
			to_chat(user, "<b>You touch [src]</b> with your gloved hands, [pick("but nothing of note happens", "but nothing happens", "but nothing interesting happens", "but you notice nothing different", "but nothing seems to have happened")].")
			return
	user.SetNextMove(CLICK_CD_MELEE)
	if(my_effect.trigger == TRIGGER_TOUCH)
		to_chat(user, "<b>You touch [src].</b>")
		my_effect.ToggleActivate()
	else
		to_chat(user, "<b>You touch [src],</b> [pick("but nothing of note happens", "but nothing happens", "but nothing interesting happens", "but you notice nothing different", "but nothing seems to have happened")].")

	if(prob(25) && secondary_effect && secondary_effect.trigger == TRIGGER_TOUCH)
		secondary_effect.ToggleActivate(0)

	if (my_effect.effect == ARTIFACT_EFFECT_TOUCH)
		my_effect.DoEffectTouch(user)

	if(secondary_effect && secondary_effect.effect == ARTIFACT_EFFECT_TOUCH && secondary_effect.activated)
		secondary_effect.DoEffectTouch(user)

/obj/machinery/artifact/attackby(obj/item/weapon/W, mob/living/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(istype(W, /obj/item/weapon/reagent_containers))
		if(W.reagents.has_reagent("hydrogen", 1) || W.reagents.has_reagent("water", 1))
			if(my_effect.trigger == TRIGGER_WATER)
				my_effect.ToggleActivate()
			if(secondary_effect && secondary_effect.trigger == TRIGGER_WATER && prob(25))
				secondary_effect.ToggleActivate(0)
		else if(W.reagents.has_reagent("acid", 1) || W.reagents.has_reagent("pacid", 1) || W.reagents.has_reagent("diethylamine", 1))
			if(my_effect.trigger == TRIGGER_ACID)
				my_effect.ToggleActivate()
			if(secondary_effect && secondary_effect.trigger == TRIGGER_ACID && prob(25))
				secondary_effect.ToggleActivate(0)
		else if(W.reagents.has_reagent("phoron", 1) || W.reagents.has_reagent("thermite", 1))
			if(my_effect.trigger == TRIGGER_VOLATILE)
				my_effect.ToggleActivate()
			if(secondary_effect && secondary_effect.trigger == TRIGGER_VOLATILE && prob(25))
				secondary_effect.ToggleActivate(0)
		else if(W.reagents.has_reagent("toxin", 1) || W.reagents.has_reagent("cyanide", 1) || W.reagents.has_reagent("amanitin", 1) || W.reagents.has_reagent("neurotoxin", 1))
			if(my_effect.trigger == TRIGGER_TOXIN)
				my_effect.ToggleActivate()
			if(secondary_effect && secondary_effect.trigger == TRIGGER_TOXIN && prob(25))
				secondary_effect.ToggleActivate(0)
	else if(istype(W,/obj/item/weapon/melee/baton) && W:status ||\
			istype(W,/obj/item/weapon/melee/energy) ||\
			istype(W,/obj/item/weapon/melee/cultblade) ||\
			istype(W,/obj/item/weapon/card/emag) ||\
			ismultitool(W))

		if (my_effect.trigger == TRIGGER_ENERGY)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_ENERGY && prob(25))
			secondary_effect.ToggleActivate(0)

	else if (istype(W,/obj/item/weapon/match) && W:lit ||\
			iswelder(W) && W:welding ||\
			istype(W,/obj/item/weapon/lighter) && W:lit)
		if(my_effect.trigger == TRIGGER_HEAT)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_HEAT && prob(25))
			secondary_effect.ToggleActivate(0)
	else
		..()
		if (my_effect.trigger == TRIGGER_FORCE && W.force >= 10)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_FORCE && W.force >= 10 && prob(25))
			secondary_effect.ToggleActivate(0)

/obj/machinery/artifact/Bumped(M)
	..()
	if(istype(M,/obj))
		if(M:throwforce >= 10)
			if(my_effect.trigger == TRIGGER_FORCE)
				my_effect.ToggleActivate()
			if(secondary_effect && secondary_effect.trigger == TRIGGER_FORCE && prob(25))
				secondary_effect.ToggleActivate(0)
	else if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!istype(H.gloves, /obj/item/clothing/gloves) && !(H.wear_suit && H.wear_suit.body_parts_covered & ARMS))
			var/warn = 0

			if (my_effect.trigger == TRIGGER_TOUCH && prob(50))
				my_effect.ToggleActivate()
				warn = 1
			if(secondary_effect && secondary_effect.trigger == TRIGGER_TOUCH && prob(25))
				secondary_effect.ToggleActivate(0)
				warn = 1

			if (my_effect.effect == ARTIFACT_EFFECT_TOUCH && prob(50))
				my_effect.DoEffectTouch(M)
				warn = 1
			if(secondary_effect && secondary_effect.effect == ARTIFACT_EFFECT_TOUCH && secondary_effect.activated && prob(50))
				secondary_effect.DoEffectTouch(M)
				warn = 1

			if(warn)
				to_chat(M, "<b>You accidentally touch [src].</b>")
	..()

/obj/machinery/artifact/bullet_act(obj/item/projectile/P)
	if(istype(P,/obj/item/projectile/bullet) ||\
		istype(P,/obj/item/projectile/hivebotbullet))
		if(my_effect.trigger == TRIGGER_FORCE)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_FORCE && prob(25))
			secondary_effect.ToggleActivate(0)

	else if(istype(P,/obj/item/projectile/beam) ||\
		istype(P,/obj/item/projectile/ion) ||\
		istype(P,/obj/item/projectile/energy))
		if(my_effect.trigger == TRIGGER_ENERGY)
			my_effect.ToggleActivate()
		if(secondary_effect && secondary_effect.trigger == TRIGGER_ENERGY && prob(25))
			secondary_effect.ToggleActivate(0)

/obj/machinery/artifact/ex_act(severity)
	switch(severity)
		if(1.0) qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)
			else
				if(my_effect.trigger == TRIGGER_FORCE || my_effect.trigger == TRIGGER_HEAT)
					my_effect.ToggleActivate()
				if(secondary_effect && (secondary_effect.trigger == TRIGGER_FORCE || secondary_effect.trigger == TRIGGER_HEAT) && prob(25))
					secondary_effect.ToggleActivate(0)
		if(3.0)
			if (my_effect.trigger == TRIGGER_FORCE || my_effect.trigger == TRIGGER_HEAT)
				my_effect.ToggleActivate()
			if(secondary_effect && (secondary_effect.trigger == TRIGGER_FORCE || secondary_effect.trigger == TRIGGER_HEAT) && prob(25))
				secondary_effect.ToggleActivate(0)
	return

/obj/machinery/artifact/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(my_effect)
		my_effect.UpdateMove()
	if(secondary_effect)
		secondary_effect.UpdateMove()

/obj/machinery/artifact/update_icon()
	var/check_activity = null
	if(my_effect && my_effect.activated)
		check_activity = "_active"
	icon_state = "artifact_[icon_num][check_activity]"
	return
