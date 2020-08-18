/obj/item/device/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight"
	item_state = "flashlight"
	w_class = ITEM_SIZE_SMALL
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	m_amt = 50
	g_amt = 20
	action_button_name = "Toggle Flashlight"
	var/on = 0
	var/button_sound = 'sound/items/flashlight.ogg' // Sound when using light
	var/brightness_on = 5 //luminosity when on
	var/last_button_sound = 0 // Prevents spamming for Object lights

/obj/item/device/flashlight/atom_init()
	. = ..()
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(brightness_on)
	else
		icon_state = initial(icon_state)
		set_light(0)

/obj/item/device/flashlight/proc/update_brightness(mob/user = null)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(brightness_on)
	else
		icon_state = initial(icon_state)
		set_light(0)

/obj/item/device/flashlight/attack_self(mob/user)
	if (last_button_sound >= world.time)
		return 0

	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc].")//To prevent some lighting anomalities.
		return 0

	if (button_sound)
		playsound(user, button_sound, VOL_EFFECTS_MASTER, 20)

	on = !on
	last_button_sound = world.time + 3
	update_brightness(user)
	action_button_name = null
	return 1

/obj/item/device/flashlight/get_current_temperature()
	if(on)
		return 10
	return 0

/obj/item/device/flashlight/Destroy()
	if(on)
		set_light(0)
	return ..()


/obj/item/device/flashlight/attack(mob/living/M, mob/living/user, def_zone)
	add_fingerprint(user)
	if(on && def_zone == O_EYES)

		if(((CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))	//too dumb to use flashlight properly
			return ..()	//just hit them in the head

		if(!(istype(user, /mob/living/carbon/human) || SSticker) && SSticker.mode.name != "monkey")	//don't have dexterity
			to_chat(user, "<span class='notice'>You don't have the dexterity to do this!</span>")
			return

		var/mob/living/carbon/human/H = M	//mob has protective eyewear
		if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			to_chat(user, "<span class='notice'>You're going to need to remove that [(H.head && H.head.flags & HEADCOVERSEYES) ? "helmet" : (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) ? "mask": "glasses"] first.</span>")
			return

		if(M == user)	//they're using it on themselves
			if(!M.blinded)
				M.flash_eyes()
				M.visible_message("<span class='notice'>[M] directs [src] to \his eyes.</span>", \
									 "<span class='notice'>You wave the light in front of your eyes! Trippy!</span>")
			else
				M.visible_message("<span class='notice'>[M] directs [src] to \his eyes.</span>", \
									 "<span class='notice'>You wave the light in front of your eyes.</span>")
			return

		user.visible_message("<span class='notice'>[user] directs [src] to [M]'s eyes.</span>", \
							 "<span class='notice'>You direct [src] to [M]'s eyes.</span>")

		if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))	//robots and aliens are unaffected
			if(M.stat == DEAD || M.sdisabilities & BLIND)	//mob is dead or fully blind
				to_chat(user, "<span class='notice'>[M] pupils does not react to the light!</span>")
			else if(XRAY in M.mutations)	//mob has X-RAY vision
				M.flash_eyes() //Yes, you can still get flashed wit X-Ray.
				to_chat(user, "<span class='notice'>[M] pupils give an eerie glow!</span>")
			else	//they're okay!
				if(!M.blinded)
					M.flash_eyes()	//flash the affected mob
					to_chat(user, "<span class='notice'>[M]'s pupils narrow.</span>")
	else
		return ..()

/obj/item/device/flashlight/seclite
	name = "seclite"
	desc = "A robust flashlight used by security."
	icon_state = "seclite"
	item_state = "seclite"
	force = 7 // Not as good as a stun baton.
	hitsound = list('sound/weapons/genhit1.ogg')

/obj/item/device/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light, used by medical staff."
	icon_state = "penlight"
	item_state = ""
	flags = CONDUCT
	button_sound = 'sound/items/penlight.ogg'
	brightness_on = 2
	w_class = ITEM_SIZE_TINY

/obj/item/device/flashlight/drone
	name = "low-power flashlight"
	desc = "A miniature lamp, that might be used by small robots."
	icon_state = "penlight"
	item_state = ""
	flags = CONDUCT
	brightness_on = 2
	w_class = ITEM_SIZE_TINY


// the desk lamps are a bit special
/obj/item/device/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp with an adjustable mount."
	icon_state = "lamp"
	item_state = "lamp"
	button_sound = 'sound/items/buttonclick.ogg'
	brightness_on = 4
	w_class = ITEM_SIZE_LARGE
	flags = CONDUCT
	m_amt = 0
	g_amt = 0
	on = 1

/obj/item/device/flashlight/lamp/get_current_temperature()
	if(on)
		return 20
	return 0

// green-shaded desk lamp
/obj/item/device/flashlight/lamp/green
	desc = "A classic green-shaded desk lamp."
	icon_state = "lampgreen"
	item_state = "lampgreen"
	brightness_on = 4


/obj/item/device/flashlight/lamp/verb/toggle_light()
	set name = "Toggle light"
	set category = "Object"
	set src in oview(1)

	if(!usr.incapacitated())
		attack_self(usr)

// FLARES

/obj/item/device/flashlight/flare
	name = "flare"
	desc = "A red Nanotrasen issued flare. There are instructions on the side, it reads 'pull cord, make light'."
	w_class = ITEM_SIZE_SMALL
	brightness_on = 4
	icon_state = "flare"
	item_state = "flare"
	action_button_name = null //just pull it manually, neckbeard.
	var/fuel = 0
	var/on_damage = 7
	var/produce_heat = 1500
	light_color = LIGHT_COLOR_FLARE
	light_power = 2
	action_button_name = "Toggle Flare"


/obj/item/device/flashlight/flare/atom_init()
	fuel = rand(800, 1000) // Sorry for changing this so much but I keep under-estimating how long X number of ticks last in seconds.
	. = ..()

/obj/item/device/flashlight/flare/process()
	var/turf/pos = get_turf(src)
	if(pos)
		pos.hotspot_expose(produce_heat, 5)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()

/obj/item/device/flashlight/flare/get_current_temperature()
	if(on)
		return 1000
	return 0

/obj/item/device/flashlight/flare/proc/turn_off()
	on = 0
	src.force = initial(src.force)
	src.damtype = initial(src.damtype)
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness(null)

	if(!fuel)
		icon_state = "[initial(icon_state)]-empty"
		item_state = icon_state
	STOP_PROCESSING(SSobj, src)

/obj/item/device/flashlight/flare/attack_self(mob/user)

	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='notice'>It's out of fuel.</span>")
		return
	if(on)
		return

	. = ..()
	// All good, turn it on.
	if(.)
		playsound(user, 'sound/items/flare.ogg', VOL_EFFECTS_MASTER)

		user.visible_message("<span class='notice'>[user] activates the flare.</span>", "<span class='notice'>You pull the cord on the flare, activating it!</span>")
		src.force = on_damage
		src.damtype = "fire"
		item_state = icon_state
		if(user.hand)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()
		START_PROCESSING(SSobj, src)

/obj/item/device/flashlight/slime
	gender = PLURAL
	name = "glowing slime extract"
	desc = "A glowing ball of what appears to be amber."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floor1" //not a slime extract sprite but... something close enough!
	item_state = "slime"
	w_class = ITEM_SIZE_TINY
	m_amt = 0
	g_amt = 0
	brightness_on = 6
	on = 1 //Bio-luminesence has one setting, on.

/obj/item/device/flashlight/slime/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/device/flashlight/slime/atom_init_late()
	update_brightness()
	icon_state = initial(icon_state)

/obj/item/device/flashlight/slime/attack_self(mob/user)
	return //Bio-luminescence does not toggle.

/obj/item/device/flashlight/emp
	origin_tech = "magnets=3;syndicate=1"
	var/emp_max_charges = 4
	var/emp_cur_charges = 4
	var/charge_tick = 0


/obj/item/device/flashlight/emp/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/device/flashlight/emp/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/device/flashlight/emp/process()
	charge_tick++
	if(charge_tick < 10)
		return 0
	charge_tick = 0
	emp_cur_charges = min(emp_cur_charges+1, emp_max_charges)
	return 1

/obj/item/device/flashlight/emp/attack(mob/living/M, mob/living/user, def_zone)
	if(on && def_zone == O_EYES) // call original attack proc only if aiming at the eyes
		..()
	return

/obj/item/device/flashlight/emp/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(emp_cur_charges)
		emp_cur_charges--

		if(isliving(target))
			var/mob/living/M = target
			M.log_combat(user, "EMP-lighted with [name]")
			M.visible_message("<span class='danger'>[user] blinks \the [src] at the [target]</span>")
		else
			target.visible_message("<span class='danger'>[user] blinks \the [src] at \the [target].</span>")
		to_chat(user, "\The [src] now has [emp_cur_charges] charge\s.")
		target.emplode(1)
	else
		to_chat(user, "<span class='warning'>\The [src] needs time to recharge!</span>")
	return
