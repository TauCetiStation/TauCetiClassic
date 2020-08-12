// The lighting system
//
// consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/weapon/light)


// status values shared between lighting fixtures and items
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3



/obj/item/light_fixture_frame
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	flags = CONDUCT
	var/fixture_type = "tube"
	var/obj/machinery/light/newlight = null
	var/sheets_refunded = 2

/obj/item/light_fixture_frame/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))
		new /obj/item/stack/sheet/metal(get_turf(loc), sheets_refunded)
		user.SetNextMove(CLICK_CD_RAPID)
		qdel(src)
		return
	return ..()

/obj/item/light_fixture_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf_loc(usr)
	if (!istype(loc, /turf/simulated/floor))
		to_chat(usr, "<span class='warning'>[src.name] cannot be placed on this spot.</span>")
		return
	to_chat(usr, "Attaching [src] to the wall.")
	playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
	var/constrdir = usr.dir
	var/constrloc = usr.loc
	if (usr.is_busy() || !do_after(usr, 30, target = on_wall))
		return
	switch(fixture_type)
		if("bulb")
			newlight = new /obj/machinery/light_construct/small(constrloc)
		if("tube")
			newlight = new /obj/machinery/light_construct(constrloc)
	newlight.dir = constrdir
	newlight.fingerprints = src.fingerprints
	newlight.fingerprintshidden = src.fingerprintshidden
	newlight.fingerprintslast = src.fingerprintslast

	usr.visible_message("[usr.name] attaches [src] to the wall.", \
		"You attach [src] to the wall.")
	qdel(src)

/obj/item/light_fixture_frame/small
	name = "small light fixture frame"
	desc = "Used for building small lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-item"
	flags = CONDUCT
	fixture_type = "bulb"
	sheets_refunded = 1

/obj/machinery/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = 1
	layer = 5
	var/stage = 1
	var/fixture_type = "tube"
	var/sheets_refunded = 2
	var/obj/machinery/light/newlight = null

/obj/machinery/light_construct/atom_init()
	. = ..()
	if (fixture_type == "bulb")
		icon_state = "bulb-construct-stage1"

/obj/machinery/light_construct/examine(mob/user)
	..()
	if (src in view(2, user))
		switch(src.stage)
			if(1)
				to_chat(user, "It's an empty frame.")
			if(2)
				to_chat(user, "It's wired.")
			if(3)
				to_chat(user, "The casing is closed.")

/obj/machinery/light_construct/attackby(obj/item/weapon/W, mob/user)
	src.add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	if (iswrench(W))
		if (src.stage == 1)
			if(user.is_busy(src))
				return
			to_chat(user, "You begin deconstructing [src].")
			if(!W.use_tool(src, usr, 30, volume = 75))
				return
			new /obj/item/stack/sheet/metal( get_turf(src.loc), sheets_refunded )
			user.visible_message("[user.name] deconstructs [src].", \
				"You deconstruct [src].", "You hear a noise.")
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
			qdel(src)
		if (src.stage == 2)
			to_chat(usr, "You have to remove the wires first.")
			return

		if (src.stage == 3)
			to_chat(usr, "You have to unscrew the case first.")
			return

	if(iswirecutter(W))
		if (src.stage != 2)
			return
		src.stage = 1
		switch(fixture_type)
			if ("tube")
				src.icon_state = "tube-construct-stage1"
			if("bulb")
				src.icon_state = "bulb-construct-stage1"
		new /obj/item/stack/cable_coil/random(get_turf(src.loc), 1)
		user.visible_message("[user.name] removes the wiring from [src].", \
			"You remove the wiring from [src].", "You hear a noise.")
		playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
		return

	if(iscoil(W))
		if (src.stage != 1)
			return
		var/obj/item/stack/cable_coil/coil = W
		if(!coil.use(1))
			return
		switch(fixture_type)
			if ("tube")
				src.icon_state = "tube-construct-stage2"
			if("bulb")
				src.icon_state = "bulb-construct-stage2"
		src.stage = 2
		user.visible_message("[user.name] adds wires to [src].", \
			"You add wires to [src].")
		return

	if(isscrewdriver(W))
		if (src.stage == 2)
			switch(fixture_type)
				if ("tube")
					src.icon_state = "tube-empty"
				if("bulb")
					src.icon_state = "bulb-empty"
			src.stage = 3
			user.visible_message("[user.name] closes [src]'s casing.", \
				"You close [src]'s casing.", "You hear a noise.")
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)

			switch(fixture_type)

				if("tube")
					newlight = new /obj/machinery/light/built(src.loc)
				if ("bulb")
					newlight = new /obj/machinery/light/small/built(src.loc)

			newlight.dir = src.dir
			src.transfer_fingerprints_to(newlight)
			qdel(src)
			return
	..()

/obj/machinery/light_construct/small
	name = "small light fixture frame"
	desc = "A small light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-stage1"
	anchored = 1
	layer = 5
	stage = 1
	fixture_type = "bulb"
	sheets_refunded = 1

// the standard tube light fixture
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/base_state = "tube"		// base description and icon_state
	icon_state = "tube1"
	desc = "A lighting fixture."
	anchored = 1
	layer = 5  					// They were appearing under mobs which is a little weird - Ostaf
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 0
	active_power_usage = 20
	power_channel = STATIC_LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	interact_offline = TRUE
	var/on = 0					// 1 if on, 0 if off
	var/on_gs = 0
	var/static_power_used = 0
	var/brightness_range = 7	// luminosity when on, also used in power calculation
	var/brightness_power = 2
	var/brightness_color = "#ffffff"
	var/status = LIGHT_OK		// LIGHT_OK, _EMPTY, _BURNED or _BROKEN
	var/flickering = 0
	var/light_type = /obj/item/weapon/light/tube		// the type of light item
	var/fitting = "tube"
	var/switchcount = 0			// count of number of times switched on/off
								// this is used to calc the probability the light burns out

	var/rigged = 0				// true if rigged to explode

	var/nightshift_enabled = FALSE	//Currently in night shift mode?
	var/nightshift_allowed = TRUE	//Set to FALSE to never let this light get switched to night mode.
	var/nightshift_light_range = 8
	var/nightshift_light_power = 0.8
	var/nightshift_light_color = "#ffdbb5"

// the smaller bulb light fixture

/obj/machinery/light/small
	icon_state = "bulb1"
	base_state = "bulb"
	fitting = "bulb"
	brightness_range = 4
	brightness_power = 2
	brightness_color = "#a0a080"
	desc = "A small lighting fixture."
	light_type = /obj/item/weapon/light/bulb

/obj/machinery/light/small/emergency
	brightness_range = 6
	brightness_power = 2
	brightness_color = "#da0205"

/obj/machinery/light/spot
	name = "spotlight"
	fitting = "large tube"
	light_type = /obj/item/weapon/light/tube/large
	brightness_range = 12
	brightness_power = 4

/obj/machinery/light/built/atom_init()
	status = LIGHT_EMPTY
	update(0)
	. = ..()

/obj/machinery/light/small/built/atom_init()
	status = LIGHT_EMPTY
	update(0)
	. = ..()

// create a new lighting fixture
/obj/machinery/light/atom_init(mapload)
	..()

	if(!mapload) //sync up nightshift lighting for player made lights
		var/area/A = get_area(src)
		var/obj/machinery/power/apc/temp_apc = A.get_apc()
		if(temp_apc)
			nightshift_enabled = temp_apc.nightshift_lights
			var/list/preset_data = lighting_presets[temp_apc.nightshift_preset]
			if(preset_data)
				nightshift_light_range = preset_data["range"]
				nightshift_light_power = preset_data["power"]
				nightshift_light_color = preset_data["color"]

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/light/atom_init_late()
	var/area/A = get_area(src)
	if(A && !A.requires_power)
		on = 1

	if(is_station_level(z) || is_mining_level(z))
		switch(fitting)
			if("tube","bulb")
				if(prob(2))
					broken(1)
	addtimer(CALLBACK(src, .proc/update, 0), 1)

/obj/machinery/light/Destroy()
	var/area/A = get_area(src)
	if(A)
		on = 0
//		A.update_lights()
	return ..()

/obj/machinery/light/update_icon()

	switch(status)		// set icon_states
		if(LIGHT_OK)
			icon_state = "[base_state][on]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
			on = 0
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			on = 0
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			on = 0
	return

// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light/proc/update(trigger = 1)

	update_icon()
	if(on)
		var/BR = brightness_range
		var/PO = brightness_power
		var/CO = brightness_color

		if (nightshift_enabled)
			BR = nightshift_light_range
			PO = nightshift_light_power
			if(!brightness_color || brightness_color == "#ffffff") // Only white lights are overwritten
				CO = nightshift_light_color

		if(light_range != BR || light_power != PO || light_color != CO)
			switchcount++
			playsound(src, 'sound/machines/lightson.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			if(rigged)
				if(status == LIGHT_OK && trigger)

					log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
					message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast] [ADMIN_JMP(src)]")

					explode()
			else if( prob( min(60, switchcount*switchcount*0.01) ) )
				if(status == LIGHT_OK && trigger)
					status = LIGHT_BURNED
					icon_state = "[base_state]-burned"
					on = 0
					set_light(0)
			else
				set_light(BR, PO, CO)
	else
		set_light(0)

	active_power_usage = ((light_range + light_power) * 20) //20W per unit luminosity
	if(on != on_gs)
		on_gs = on

		if(on)
			set_power_use(ACTIVE_POWER_USE)
		else
			set_power_use(IDLE_POWER_USE)


// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/seton(s)
	on = (s && status == LIGHT_OK)
	update()

// examine verb
/obj/machinery/light/examine(mob/user)
	..()
	if(src in oview(1, user))
		switch(status)
			if(LIGHT_OK)
				to_chat(user, "[desc] It is turned [on? "on" : "off"].")
			if(LIGHT_EMPTY)
				to_chat(user, "[desc] The [fitting] has been removed.")
			if(LIGHT_BURNED)
				to_chat(user, "[desc] The [fitting] is burnt out.")
			if(LIGHT_BROKEN)
				to_chat(user, "[desc] The [fitting] has been smashed.")



// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/W, mob/user)

	//Light replacer code
	if(istype(W, /obj/item/device/lightreplacer))
		var/obj/item/device/lightreplacer/LR = W
		if(isliving(user))
			var/mob/living/U = user
			LR.ReplaceLight(src, U)
			return

	// attempt to insert light
	if(istype(W, /obj/item/weapon/light))
		if(status != LIGHT_EMPTY)
			to_chat(user, "There is a [fitting] already inserted.")
			return
		else
			src.add_fingerprint(user)
			var/obj/item/weapon/light/L = W
			if(istype(L, light_type))
				status = L.status
				to_chat(user, "You insert the [L.name].")
				switchcount = L.switchcount
				rigged = L.rigged
				brightness_range = L.brightness_range
				brightness_power = L.brightness_power
				brightness_color = L.brightness_color
				on = has_power()
				update()

				user.drop_item()	//drop the item to update overlays and such
				qdel(L)

				playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 25)
				user.SetNextMove(CLICK_CD_INTERACT)

				if(on && rigged)

					log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
					message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast] [ADMIN_JMP(src)]")

					explode()
			else
				to_chat(user, "This type of light requires a [fitting].")
				return

		// attempt to break the light
		//If xenos decide they want to smash a light bulb with a toolbox, who am I to stop them? /N

	else if(status != LIGHT_BROKEN && status != LIGHT_EMPTY)


		user.do_attack_animation(src)
		user.SetNextMove(CLICK_CD_MELEE)
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
		if(isscrewdriver(W)) //If it's a screwdriver open it.
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			user.visible_message("[user.name] opens [src]'s casing.", \
				"You open [src]'s casing.", "You hear a noise.")
			var/obj/machinery/light_construct/newlight = null
			switch(fitting)
				if("tube")
					newlight = new /obj/machinery/light_construct(src.loc)
					newlight.icon_state = "tube-construct-stage2"

				if("bulb")
					newlight = new /obj/machinery/light_construct/small(src.loc)
					newlight.icon_state = "bulb-construct-stage2"
			newlight.dir = src.dir
			newlight.stage = 2
			newlight.fingerprints = src.fingerprints
			newlight.fingerprintshidden = src.fingerprintshidden
			newlight.fingerprintslast = src.fingerprintslast
			qdel(src)
			return

		to_chat(user, "You stick \the [W] into the light socket!")
		if(has_power() && (W.flags & CONDUCT))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			//if(!user.mutations & COLD_RESISTANCE)
			if (prob(75))
				electrocute_mob(user, get_area(src), src, rand(70, 100) * 0.01)


// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/A = src.loc.loc
	return A.lightswitch && A.power_light

/obj/machinery/light/proc/flicker(amount = rand(10, 20))
	if(flickering) return
	flickering = 1
	spawn(0)
		if(on && status == LIGHT_OK)
			for(var/i = 0; i < amount; i++)
				if(status != LIGHT_OK) break
				on = !on
				update(0)
				sleep(rand(5, 15))
			on = (status == LIGHT_OK)
			update(0)
		flickering = 0

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

/obj/machinery/light/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_RAPID)

	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return 1

	// make it burn hands if not wearing fire-insulated gloves
	if(on)
		var/prot = 0
		var/mob/living/carbon/human/H = user

		if(istype(H))
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1

		if(prot > 0 || (COLD_RESISTANCE in user.mutations) || H.species.flags[IS_SYNTHETIC])
			to_chat(user, "You remove the light [fitting]")
		else if(TK in user.mutations)
			to_chat(user, "You telekinetically remove the light [fitting].")
		else
			to_chat(user, "You try to remove the light [fitting], but it's too hot and you don't want to burn your hand.")
			return 1			// if burned, don't remove the light
	else
		to_chat(user, "You remove the light [fitting].")

	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/weapon/light/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness_range = brightness_range
	L.brightness_power = brightness_power
	L.brightness_color = brightness_color

	playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 25)
	user.SetNextMove(CLICK_CD_INTERACT)

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0

	L.update()
	L.add_fingerprint(user)

	if(!user.put_in_active_hand(L))	//puts it in our active hand (don't forget check)
		L.loc = get_turf(user)

	status = LIGHT_EMPTY
	update()


/obj/machinery/light/attack_tk(mob/user)
	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return

	to_chat(user, "You telekinetically remove the light [fitting].")
	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/weapon/light/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness_range = brightness_range
	L.brightness_power = brightness_power
	L.brightness_color = brightness_color

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0

	L.update()
	L.add_fingerprint(user)
	L.loc = loc

	status = LIGHT_EMPTY
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
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(75))
				broken()
		if(3.0)
			if (prob(50))
				broken()
	return

//blob effect

/obj/machinery/light/blob_act()
	if(prob(75))
		broken()


// timed process
// use power


// called when area power state changes
/obj/machinery/light/power_change()
	var/area/A = get_area(src)
	if(A) seton(A.lightswitch && A.power_light)

// called when on fire

/obj/machinery/light/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		broken()

// explode the light

/obj/machinery/light/proc/explode()
	set waitfor = FALSE

	var/turf/T = get_turf(src.loc)
	broken()	// break it first to give a warning
	sleep(2)
	explosion(T, 0, 0, 2, 2)
	sleep(1)
	qdel(src)

// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light of the corresponding type

/obj/item/weapon/light
	icon = 'icons/obj/lighting.dmi'
	force = 2
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	var/status = 0		// LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/switchcount = 0	// number of times switched
	m_amt = 60
	var/rigged = 0		// true if rigged to explode
	var/brightness_range = 2 //how much light it gives off
	var/brightness_power = 1
	var/brightness_color = "#ffffff"

/obj/item/weapon/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	item_state = "c_tube"
	g_amt = 100
	brightness_range = 8
	brightness_power = 3

/obj/item/weapon/light/tube/large
	w_class = ITEM_SIZE_SMALL
	name = "large light tube"
	brightness_range = 15
	brightness_power = 4

/obj/item/weapon/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	item_state = "contvapour"
	g_amt = 100
	brightness_range = 5
	brightness_power = 2
	brightness_color = "#a0a080"

/obj/item/weapon/light/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	shatter()

/obj/item/weapon/light/bulb/fire
	name = "fire bulb"
	desc = "A replacement fire bulb."
	icon_state = "fbulb"
	base_state = "fbulb"
	item_state = "egg4"
	g_amt = 100
	brightness_range = 5
	brightness_power = 2

// update the icon state and description of the light

/obj/item/weapon/light/proc/update()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_state
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			desc = "A broken [name]."


/obj/item/weapon/light/atom_init()
	. = ..()
	switch(name)
		if("light tube")
			brightness_range = rand(6,9)
		if("light bulb")
			brightness_range = rand(4,6)
	update()


// attack bulb/tube with object
// if a syringe, can inject phoron to make it explode
/obj/item/weapon/light/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I
		user.SetNextMove(CLICK_CD_INTERACT)

		to_chat(user, "You inject the solution into the [src].")

		if(S.reagents.has_reagent("phoron", 5))
			log_admin("LOG: [key_name(user)] injected a light with phoron, rigging it to explode.")
			message_admins("LOG: [key_name_admin(user)] injected a light with phoron, rigging it to explode. [ADMIN_JMP(user)]")

			rigged = 1

		S.reagents.clear_reagents()

	else
		return ..()

// called after an attack with a light item
// shatter light, unless it was an attempt to put it in a light socket
// now only shatter if the intent was harm

/obj/item/weapon/light/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(istype(target, /obj/machinery/light))
		return
	if(user.a_intent != INTENT_HARM)
		return

	shatter()

/obj/item/weapon/light/proc/shatter()
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		src.visible_message("<span class='warning'>[name] shatters.</span>","<span class='warning'>You hear a small glass object shatter.</span>")
		status = LIGHT_BROKEN
		force = 5
		sharp = 1
		playsound(src, 'sound/effects/light-break.ogg', VOL_EFFECTS_MASTER)
		update()
