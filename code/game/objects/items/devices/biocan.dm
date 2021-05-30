/obj/item/device/biocan
	name = "Biogel can"
	desc = "Biogel jar for supporting life in head. Extremely fragile!"
	icon = 'icons/obj/biocan.dmi'
	icon_state = "biocan"
	origin_tech = "biotech=3;materials=3;magnets=3"
	w_class = ITEM_SIZE_NORMAL
	appearance_flags = KEEP_TOGETHER | TILE_BOUND
	var/obj/item/organ/external/head/headobj = null
	var/image/display_headobj = null
	var/mob/living/carbon/brain/brainmob = null
	var/commutator_enabled = FALSE

/obj/item/device/biocan/verb/safe_eject()
	set name = "Safely eject head"
	set category = "Object"
	set src in view(1)

	if (!ishuman(usr) || usr.incapacitated())
		return
	to_chat(usr, "<span class='notice'>You began to carefully extract [headobj] from the can.</span>")
	if(!usr.is_busy() && do_after(usr, 20, target = src, can_move = TRUE))
		var/head_name = headobj.name
		if (extract_head())
			to_chat(usr, "<span class='notice'>You have successfully extract [head_name].</span>")
		else
			to_chat(usr, "<span class='notice'>Extracting [head_name] was failed.</span>")
	else
		to_chat(usr, "<span class='notice'>Extracting [headobj] was interrupted.</span>")

/obj/item/device/biocan/proc/extract_head(brain_destroyed = FALSE)
	if (headobj)
		if(brainmob)
			alive_mob_list -= brainmob
			brainmob.timeofhostdeath = world.time
			if (brain_destroyed)
				// can be mouse if player have jobban for observer
				if (brainmob.ghostize(can_reenter_corpse = FALSE))
					dead_mob_list += brainmob
			brainmob.container = null
			brainmob.loc = headobj
			headobj.brainmob = brainmob
			brainmob = null
		headobj.forceMove(get_turf(src))
		headobj = null
		QDEL_NULL(display_headobj)
		underlays.Cut()
		return TRUE
	return FALSE

/obj/item/device/biocan/verb/toggle_speech()
	set name = "Toggle commutator"
	set category = "Object"
	set src in view(1)

	if (!ishuman(usr) || usr.incapacitated())
		return
	if(commutator_enabled)
		commutator_enabled = FALSE
		to_chat(usr, "<span class='warning'>You disable text to speech device, preventing [src.name]'s occupant from shouting.</span>")
		to_chat(brainmob, "<span class='warning'>Your commutating device is now disabled.</span>")
	else
		commutator_enabled = TRUE
		to_chat(usr, "<span class='warning'>You enable commutating device, allowing your prisoner to speak.</span>")
		to_chat(brainmob, "<span class='warning'>Your commutating device is now enabled.</span>")

/obj/item/device/biocan/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/organ/external/head))
		if(!headobj)
			headobj = I
			user.drop_from_inventory(I, src)

			if(headobj.brainmob)
				brainmob = headobj.brainmob
				headobj.brainmob = null
				brainmob.loc = src
				brainmob.container = src
				brainmob.stat = CONSCIOUS
				dead_mob_list -= brainmob
				alive_mob_list += brainmob
			display_headobj = new (src)
			display_headobj.appearance = I.appearance
			display_headobj.transform = matrix()
			display_headobj.dir = SOUTH
			display_headobj.pixel_y = 0
			display_headobj.pixel_x = 0
			display_headobj.layer = FLOAT_LAYER
			display_headobj.plane = FLOAT_PLANE
			underlays.Add(display_headobj)
			update_icon()
	else
		return ..()

/obj/item/device/biocan/attack_self(mob/user)
	if(alert(user, "Are you sure you want to pour it on the floor? This will kill this head!",,"Cancel","Continue") != "Continue")
		return
	user.visible_message("<span class='red'>\The [src.name] contents has been splashed over the floor. </span>")
	extract_head(brain_destroyed = TRUE)
	return

/obj/item/device/biocan/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	visible_message("<span class='red'>\The [src.name] has been shattered. </span>")
	extract_head(brain_destroyed = TRUE)
	new /obj/item/weapon/shard(loc)
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	qdel(src)
