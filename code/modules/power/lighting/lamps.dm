// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube" // default value for map editors
	var/base_icon_state = "tube"
	desc = "A lighting fixture."
	layer = LAMPS_LAYER
	anchored = TRUE

	use_power = ACTIVE_POWER_USE
	idle_power_usage = 0
	active_power_usage = 20 // will be recalculated based on light intensity
	power_channel = STATIC_LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	interact_offline = TRUE
	flags_2 = PROHIBIT_OVERLAYS_FOR_DEMO_2

	glow_icon_state = "tube"
	exposure_icon_state = "cone"

	var/obj/item/weapon/light/inserted_bulb_type = /obj/item/weapon/light/tube
	var/fitting = LAMP_FITTING_TUBE

	var/datum/light_mode/area_light_mode // all lamps have this, but will be used only for lamps with smart bulbs

	// for some old stuff on maps and admins varedit
	var/force_override_color
	var/force_override_power
	var/force_override_range

	var/status = LIGHT_OK // LIGHT_OK, _EMPTY, _BURNED or _BROKEN

	var/on = FALSE

	var/flickering = FALSE
	var/switchcount = 0 // count of number of times switched on/off
	                    // this is used to calc the probability the light burns out

	var/rigged = FALSE // true if rigged to explode

/obj/machinery/light/smart
	icon_state = "stube"
	base_icon_state = "tube" // not a typo
	inserted_bulb_type = /obj/item/weapon/light/tube/smart

	glow_icon_state = "stube"
	exposure_icon_state = "cone"
	glow_colored = TRUE

/obj/machinery/light/small
	desc = "A small lighting fixture."
	icon_state = "bulb"
	base_icon_state = "bulb"
	fitting = LAMP_FITTING_BULB
	inserted_bulb_type = /obj/item/weapon/light/bulb

	glow_icon_state = "bulb"
	exposure_icon_state = "circle"

/obj/machinery/light/small/emergency
	inserted_bulb_type = /obj/item/weapon/light/bulb/emergency

/obj/machinery/light/spot // no way to construct, centcomm only item
	name = "spotlight"
	fitting = LAMP_FITTING_LARGE_TUBE
	inserted_bulb_type = /obj/item/weapon/light/tube/large
	flags = NODECONSTRUCT

/obj/machinery/light/atom_init(mapload)
	..()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/light/built/atom_init()
	status = LIGHT_EMPTY
	. = ..()

/obj/machinery/light/small/built/atom_init()
	status = LIGHT_EMPTY
	. = ..()

/obj/machinery/light/atom_init_late()
	var/area/A = get_area(src)
	if(A && !A.requires_power)
		on = TRUE

	if(SSticker.current_state >= GAME_STATE_PLAYING)
		var/obj/machinery/power/apc/area_apc = A.get_apc()
		if(area_apc)
			area_light_mode = area_apc.get_light_mode()

	if(is_station_level(z) || is_mining_level(z))
		if(prob(2))
			broken(1)
	update_now(FALSE)

// little wrapper to save on init and reduce racing
/obj/machinery/light/proc/update(trigger = TRUE)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		return
	update_now(trigger)

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update_now(trigger)
	update_icon()

	if(on && inserted_bulb_type)

		var/datum/light_mode/mode
		if(initial(inserted_bulb_type.smart) && area_light_mode) // use mode from APC
			mode = area_light_mode
		else // or bulb mode if we not smart or if there is no area APC
			mode = global.light_modes_by_type[initial(inserted_bulb_type.light_mode)]

		if(!mode) // or we bugged for some reason and need emergency fallback to defaults
			stack_trace("Bad lighting code for [src] [src.type]")
			mode = global.light_modes_by_type[/datum/light_mode/default]

		var/new_color = force_override_color || mode.color
		var/new_power = force_override_power || mode.power
		var/new_range = force_override_range || mode.range

		// hack (needs to redo) so new year station will look better with garlands
		// changes power for standart lamps
		if(SSholiday.holidays[NEW_YEAR] && new_power == 2 && is_station_level(z))
			new_power = 1.5

		if(light_range != new_range || light_power != new_power || light_color != new_color)
			switchcount++
			playsound(src, 'sound/machines/lightson.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			if(rigged && trigger && status == LIGHT_OK)
				log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
				message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast] [ADMIN_JMP(src)]")
				explode()
				return
			else if(trigger && status == LIGHT_OK && prob(min(60, switchcount*switchcount*0.01)))
				status = LIGHT_BURNED
				update_icon()
				set_light(0)
			else
				set_light(new_range, new_power, new_color)
	else
		set_light(0)

	active_power_usage = ((light_range + light_power) * 20) // 20W per unit luminosity
	set_power_use(on ? ACTIVE_POWER_USE : IDLE_POWER_USE)

/obj/machinery/light/proc/set_light_mode(new_mode)
	if(area_light_mode == new_mode)
		return

	area_light_mode = new_mode

	if(initial(inserted_bulb_type.smart))
		update()

/obj/machinery/light/turn_light_off()
	on = FALSE
	visible_message("<span class='danger'>[src] flickers and falls dark.</span>")
	update(0)

/obj/machinery/light/update_icon()
	var/prefix = ""
	if(inserted_bulb_type && initial(inserted_bulb_type.smart))
		prefix = "s"

	switch(status) // set icon_states
		if(LIGHT_EMPTY)
			icon_state = "[base_icon_state]-empty"
			on = FALSE
		if(LIGHT_OK)
			icon_state = "[prefix][base_icon_state][on ? "" : "-off"]"
		if(LIGHT_BURNED)
			icon_state = "[prefix][base_icon_state]-burned"
			on = FALSE
		if(LIGHT_BROKEN)
			icon_state = "[prefix][base_icon_state]-broken"
			on = FALSE

/obj/machinery/light/examine(mob/user)
	..()
	if(src in oview(1, user))
		switch(status)
			if(LIGHT_OK)
				to_chat(user, "[desc] It uses [fitting] fitting. It is turned [on? "on" : "off"].")
			if(LIGHT_EMPTY)
				to_chat(user, "[desc] The [fitting] has been removed.")
			if(LIGHT_BURNED)
				to_chat(user, "[desc] The [fitting] is burnt out.")
			if(LIGHT_BROKEN)
				to_chat(user, "[desc] The [fitting] has been smashed.")

// attack with item - insert light (if right type), otherwise try to break the light
/obj/machinery/light/attackby(obj/item/W, mob/user)
	user.SetNextMove(CLICK_CD_MELEE)

	// Light replacer code
	if(istype(W, /obj/item/device/lightreplacer))
		if(status == LIGHT_OK)
			to_chat(user, "There is a working [fitting] already inserted.")
			return
		var/obj/item/device/lightreplacer/LR = W
		if(LR.use_tool(src, user, 10, 1))
			if(status != LIGHT_EMPTY) // drop old bulb first
				drop_light_bulb(user)
			status = LIGHT_OK
			inserted_bulb_type = LR.lamp_type
			switchcount = 0
			rigged = 0
			on = has_power()
			update()
		return

	// attempt to insert light
	if(istype(W, /obj/item/weapon/light)) // todo: doafter
		if(status != LIGHT_EMPTY)
			to_chat(user, "There is a [fitting] already inserted.")
			return

		var/obj/item/weapon/light/L = W
		if(L.fitting != fitting)
			to_chat(user, "This type of light requires a [fitting].")
			return

		add_fingerprint(user)
		status = L.status
		inserted_bulb_type = L.type
		switchcount = L.switchcount
		rigged = L.rigged
		on = has_power()
		update()

		qdel(L)
		to_chat(user, "You insert the [L.name].")
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 25)

		if(on && rigged)
			log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
			message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast] [ADMIN_JMP(src)]")
			explode()

	// attempt to break the light
	// if xenos decide they want to smash a light bulb with a toolbox, who am I to stop them? /N
	else if(status != LIGHT_BROKEN && status != LIGHT_EMPTY)
		user.do_attack_animation(src)
		if(prob(1+W.force * 5))
			user.visible_message("[user.name] smashed the light!", blind_message = "You hear a tinkle of breaking glass", self_message = "You hit the light, and it smashes!")
			if(on && (W.flags & CONDUCT))
				//if(!user.mutations & COLD_RESISTANCE)
				if (prob(12))
					electrocute_mob(user, get_area(src), src, 0.3)
			broken()
		else
			to_chat(user, "You hit the light!")

	// attempt to stick weapon into light socket
	else if(status == LIGHT_EMPTY)
		if(isscrewing(W))
			if(W.use_tool(src, user, 20))
				user.visible_message("[user.name] opens [src]'s casing.", \
				"You open [src]'s casing.", "You hear a noise.")
				deconstruct(TRUE)
				qdel(src)
			return

		to_chat(user, "You stick [W] into the light socket!")
		if(has_power() && (W.flags & CONDUCT))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			//if(!user.mutations & COLD_RESISTANCE)
			if (prob(75))
				electrocute_mob(user, get_area(src), src, rand(70, 100) * 0.01)

/obj/machinery/light/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			switch(status)
				if(LIGHT_EMPTY)
					playsound(loc, 'sound/weapons/smash.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
				if(LIGHT_BROKEN)
					playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', VOL_EFFECTS_MASTER, 90, TRUE)
				else
					playsound(loc, 'sound/effects/glasshit.ogg', VOL_EFFECTS_MASTER, 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/machinery/light/atom_break()
	. = ..()
	broken()

/obj/machinery/light/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()

	var/obj/machinery/light_construct/construct

	switch(fitting)
		if(LAMP_FITTING_TUBE)
			construct = new /obj/machinery/light_construct(loc)
			construct.stage = 2 // coiled
			icon_state = "tube-construct-stage2"
		if(LAMP_FITTING_BULB)
			construct = new /obj/machinery/light_construct/small(loc)
			construct.stage = 2
			icon_state = "bulb-construct-stage2"

	construct.set_dir(dir)
	transfer_fingerprints_to(construct)

	if(disassembled && status != LIGHT_EMPTY)
		if(status != LIGHT_BROKEN)
			broken()
		drop_light_bulb()

	..()

// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/A = src.loc.loc
	return A.lightswitch && A.power_light

/obj/machinery/light/proc/flicker(amount = rand(10, 20))
	set waitfor = FALSE

	if(flickering)
		return

	flickering = TRUE

	if(on && status == LIGHT_OK)
		for(var/i = 0; i < amount; i++)
			if(status != LIGHT_OK)
				break
			on = !on
			update(FALSE)
			sleep(rand(5, 15))
		on = (status == LIGHT_OK)
		update(FALSE)

	flickering = FALSE

// ai attack - make lights flicker, because why not
/obj/machinery/light/attack_ai(mob/user)
	flicker(1)

// Aliens smash the bulb but do not get electrocuted./N
/obj/machinery/light/attack_alien(mob/living/carbon/xenomorph/humanoid/user)
	if(!isxenoadult(user))
		return
	if(status == LIGHT_EMPTY||status == LIGHT_BROKEN)
		to_chat(user, "<span class='notice'>That object is useless to you.</span>")
		return
	else if (status == LIGHT_OK||status == LIGHT_BURNED)
		user.do_attack_animation(src)
		user.SetNextMove(CLICK_CD_MELEE)
		visible_message("<span class='warning'>[user.name] smashed the light!</span>", blind_message = "You hear a tinkle of breaking glass")
		broken()
	return

/obj/machinery/light/attack_animal(mob/living/simple_animal/attacker)
	if(attacker.melee_damage == 0)
		return
	if(status == LIGHT_EMPTY||status == LIGHT_BROKEN)
		to_chat(attacker, "<span class='warning'>That object is useless to you.</span>")
		return
	else if (status == LIGHT_OK||status == LIGHT_BURNED)
		..()
		visible_message("<span class='warning'>[attacker] smashed the light!</span>", blind_message = "You hear a tinkle of breaking glass")
		broken()

// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player
/obj/machinery/light/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_RAPID)

	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return 1

	// make it burn hands if not wearing fire-insulated gloves
	if(on) // todo: doafter
		var/protected = 0
		var/mob/living/carbon/human/H = user

		if(istype(H))
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					protected = (G.max_heat_protection_temperature > 360)
		else
			protected = 1

		if(protected > 0 || (COLD_RESISTANCE in user.mutations) || H.species.flags[IS_SYNTHETIC])
			to_chat(user, "You remove the light [fitting]")
		else if(TK in user.mutations)
			to_chat(user, "You telekinetically remove the light [fitting].")
		else
			to_chat(user, "You try to remove the light [fitting], but it's too hot and you don't want to burn your hand.")
			return 1			// if burned, don't remove the light
	else
		to_chat(user, "You remove the light [fitting].")

	playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 25)
	user.SetNextMove(CLICK_CD_INTERACT)

	drop_light_bulb(user)

/obj/machinery/light/proc/drop_light_bulb(mob/living/user)
	var/obj/item/weapon/light/dropping_bulb = new inserted_bulb_type(loc)
	dropping_bulb.status = status
	dropping_bulb.rigged = rigged

	// light item inherits the switchcount, then zero it
	dropping_bulb.switchcount = switchcount
	switchcount = 0

	dropping_bulb.update()

	if(user) //puts it in our hands
		dropping_bulb.add_fingerprint(user)
		user.try_take(dropping_bulb)

	status = LIGHT_EMPTY
	inserted_bulb_type = null
	update()

// break the light and make sparks if was on
/obj/machinery/light/proc/broken(skip_sound_and_sparks = 0)
	if(status == LIGHT_EMPTY)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(src, 'sound/effects/light-break.ogg', VOL_EFFECTS_MASTER)
		if(on)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
	status = LIGHT_BROKEN
	update()

/obj/machinery/light/proc/fix()
	if(status == LIGHT_OK)
		return
	status = LIGHT_OK
	on = 1
	update()

// explosion effect
// destroy the whole light fixture or just shatter it
/obj/machinery/light/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if(prob(25))
				return
		if(EXPLODE_LIGHT)
			if(prob(50))
				return
	broken()

// called when area power state changes
/obj/machinery/light/power_change()
	var/area/A = get_area(src)
	if(A)
		seton(A.lightswitch && A.power_light)

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/seton(s)
	on = (s && status == LIGHT_OK)
	update()

// called when on fire
/obj/machinery/light/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		broken()

// explode the light
/obj/machinery/light/proc/explode()
	broken()	// break it first to give a warning
	addtimer(CALLBACK(src, PROC_REF(explosion), get_turf(src.loc), 0, 0, 2, 2), 3 SECONDS)
