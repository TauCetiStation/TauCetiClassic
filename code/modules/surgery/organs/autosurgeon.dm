/obj/item/autosurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant, skillchip or organ into the user without the hassle of extensive surgery. \
		It has a slot to insert implants or organs and a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/device.dmi'
	icon_state = "autosurgeon"
	w_class = SIZE_SMALL

	/// How many times you can use the autosurgeon before it becomes useless
	var/uses = INFINITY
	/// What organ will the autosurgeon sub-type will start with. ie, CMO autosurgeon start with a medi-hud.
	var/starting_organ
	/// The organ currently loaded in the autosurgeon, ready to be implanted.
	var/obj/item/organ/stored_organ
	/// The list of organs and their children we allow into the autosurgeon. An empty list means no whitelist.
	var/list/organ_whitelist = list()
	/// The percentage modifier for how fast you can use the autosurgeon to implant other people.
	var/surgery_speed = 1
	/// The overlay that shows when the autosurgeon has an organ inside of it.
	var/loaded_overlay = "autosurgeon_loaded_overlay"

/obj/item/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/autosurgeon/atom_init()
	. = ..()
	if(starting_organ)
		load_organ(new starting_organ(src))

/obj/item/autosurgeon/Destroy()
	. = ..()
	QDEL_NULL(stored_organ)

/obj/item/autosurgeon/update_icon()
	. = ..()
	cut_overlays()
	if(stored_organ)
		add_overlay(image(icon,src, icon_state, layer = layer + 0.1))

/obj/item/autosurgeon/proc/load_organ(obj/item/organ/loaded_organ, mob/living/user)
	if(user)
		if(stored_organ)
			to_chat(user, "<span class='alert'>[src] already has an implant stored.</span>")
			return

		if(uses == 0)
			to_chat(user, "<span class='alert'>[src] is used up and cannot be loaded with more implants.</span>")
			return

		if(organ_whitelist.len)
			var/organ_whitelisted
			for(var/whitelisted_organ in organ_whitelist)
				if(istype(loaded_organ, whitelisted_organ))
					organ_whitelisted = TRUE
					break
			if(!organ_whitelisted)
				to_chat(user, "<span class='alert'>[src] is not compatible with [loaded_organ].</span>")
				return

	stored_organ = loaded_organ
	loaded_organ.forceMove(src)

	name = "[initial(name)] ([stored_organ.name])" //to tell you the organ type, like "suspicious autosurgeon (Military-grade cybernetic heart)"
	update_icon()

/obj/item/autosurgeon/proc/use_autosurgeon(mob/living/target, mob/living/user, implant_time)
	if(!stored_organ)
		to_chat(user, "<span class='alert'>[src] currently has no implant stored.</span>")
		return

	if(!uses)
		to_chat(user, "<span class='alert'>[src] has already been used. The tools are dull and won't reactivate.</span>")
		return

	if(implant_time)
		user.visible_message(
			"<span class='notice'>[user] prepares to use [src] on [target].",
			"<span class='notice'>You begin to prepare to use [src] on [target].",
		)
		if(!do_after(user, (implant_time * surgery_speed), target))
			return

	if(target != user)
		user.log_combat(user, "autosurgeon implanted [stored_organ] into", "[src]", "in [AREACOORD(target)]")
		user.visible_message("<span class='notice'>[user] presses a button on [src] as it plunges into [target]'s body.", "<span class='notice'>You press a button on [src] as it plunges into [target]'s body.</span>")
	else
		user.visible_message(
			"<span class='notice'>[user] pressses a button on [src] as it plunges into their body.",
			"<span class='notice'>You press a button on [src] as it plunges into your body.",
		)

	stored_organ.insert_organ(target, TRUE)//insert stored organ into the user
	stored_organ = null
	name = initial(name) //get rid of the organ in the name
	playsound(target.loc, 'sound/weapons/circsawhit.ogg', 50, vary = TRUE)
	update_icon()

	if(uses)
		uses--
	if(uses == 0)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/autosurgeon/attack_self(mob/user)//when the object it used...
	use_autosurgeon(user, user)

/obj/item/autosurgeon/attack(mob/living/target, mob/living/user, params)
	add_fingerprint(user)
	use_autosurgeon(target, user, 8 SECONDS)

/obj/item/autosurgeon/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/organ))
		load_organ(attacking_item, user)
		return

	if(!isscrewing(attacking_item))
		return ..()
	if(!stored_organ)
		to_chat(user, "<span class='warning'>There's no implant in [src] for you to remove!</span>")
	else
		for(var/atom/movable/stored_implant as anything in src)
			stored_implant.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You remove the [stored_organ] from [src].</span>")
			stored_organ = null

		attacking_item.play_tool_sound(src)
		if(uses)
			uses--
		if(!uses)
			desc = "[initial(desc)] Looks like it's been used up."
		update_icon()
	return ..()

/obj/item/autosurgeon/syndicate
	name = "suspicious autosurgeon"
	icon_state = "autosurgeon_syndicate"
	surgery_speed = 0.75
	loaded_overlay = "autosurgeon_syndicate_loaded_overlay"

/obj/item/autosurgeon/syndicate/heart
	starting_organ = /obj/item/organ/internal/heart/cybernetic/advanced/military

/obj/item/autosurgeon/syndicate/lungs
	starting_organ = /obj/item/organ/internal/lungs/cybernetic/advanced/military

/obj/item/autosurgeon/syndicate/liver
	starting_organ = /obj/item/organ/internal/liver/cybernetic/advanced/military

/obj/item/autosurgeon/syndicate/kidneys
	starting_organ = /obj/item/organ/internal/kidneys/cybernetic/advanced/military

/obj/item/autosurgeon/heart
	starting_organ = /obj/item/organ/internal/heart/cybernetic/advanced

/obj/item/autosurgeon/lungs
	starting_organ = /obj/item/organ/internal/lungs/cybernetic/advanced

/obj/item/autosurgeon/liver
	starting_organ = /obj/item/organ/internal/liver/cybernetic/advanced

/obj/item/autosurgeon/kidneys
	starting_organ = /obj/item/organ/internal/kidneys/cybernetic/advanced

/obj/item/autosurgeon/debug
	name = "Debug autosurgeon"
	desc = "A device that automatically inserts an implant, skillchip or organ into the user without the hassle of extensive surgery. \

/obj/item/autosurgeon/syndicate/emaggedsurgerytoolset
	starting_organ = /obj/item/organ/internal/cyberimp/arm/surgery/emagged
*/
