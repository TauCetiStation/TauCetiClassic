/obj/item/device/biocan
	name = "Biogel can"
	desc = "Biogel jar for supporting life in head. Extremely fragile!"
	icon = 'icons/obj/biocan.dmi'
	icon_state = "biocan"
	origin_tech = "biotech=3;materials=3;magnets=3"
	w_class = ITEM_SIZE_NORMAL
	appearance_flags = KEEP_TOGETHER | TILE_BOUND
	var/obj/item/weapon/organ/head/headobj = null
	var/image/display_headobj = null
	var/mob/living/carbon/brain/brainmob = null
	var/commutator_enabled = FALSE

/obj/item/device/biocan/verb/safe_eject()
	set name = "Safely eject head"
	set category = "Object"
	set src in view(0)

	to_chat(usr, "<span class='notice'>You began to carefully extract [headobj] from the can.</span>")
	if(!usr.is_busy(src) && use_tool(src, usr, 20))
		if(headobj)
			to_chat(usr, "<span class='notice'>You have successfully extracted [headobj].</span>")
			if(brainmob)
				brainmob.container = null
				brainmob.loc = headobj
				headobj.brainmob = brainmob
				brainmob.timeofhostdeath = world.time
				alive_mob_list -= brainmob
				brainmob = null
			headobj.forceMove(get_turf(src))
			headobj = null
			QDEL_NULL(display_headobj)
			underlays.Cut()

/obj/item/device/biocan/verb/toggle_speech()
	set name = "Toggle commutator"
	set category = "Object"
	set src in view(0)

	if(commutator_enabled)
		commutator_enabled = FALSE
		to_chat(usr, "<span class='warning'>You disable text to speech device, preventing [src.name]'s occupant from shouting.</span>")
		to_chat(brainmob, "<span class='warning'>Your commutating device is now disabled.</span>")
	else
		commutator_enabled = TRUE
		to_chat(usr, "<span class='warning'>You enable commutating device, allowing your prisoner to speak.</span>")
		to_chat(brainmob, "<span class='warning'>Your commutating device is now enabled.</span>")

/obj/item/device/biocan/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/organ/head))
		if(!headobj)
			headobj = W
			user.drop_item()
			headobj.loc = src
			if(headobj.brainmob)
				brainmob = headobj.brainmob
				headobj.brainmob = null
				brainmob.loc = src
				brainmob.container = src
				brainmob.stat = CONSCIOUS
				dead_mob_list -= brainmob
				alive_mob_list += brainmob
			display_headobj = new (src)
			display_headobj.appearance = W.appearance
			display_headobj.transform = matrix()
			display_headobj.dir = SOUTH
			display_headobj.pixel_y = 0
			display_headobj.pixel_x = 0
			display_headobj.layer = FLOAT_LAYER
			display_headobj.plane = FLOAT_PLANE
			underlays.Add(display_headobj)
			update_icon()

/obj/item/device/biocan/attack_self(mob/user)
	if(alert(user, "Are you sure you want to pour it on the floor? This will kill this head!",,"Cancel","Continue") != "Continue")
		return
	user.visible_message("<span class='red'>\The [src.name] contents has been splashed over the floor. </span>")
	if(headobj)
		if(brainmob)
			alive_mob_list -= headobj.brainmob
			brainmob.ghostize(can_reenter_corpse = FALSE)
			brainmob.loc = headobj
			brainmob.container = headobj
			headobj.brainmob = brainmob
			brainmob = null
		headobj.forceMove(get_turf(src))
		headobj = null
		QDEL_NULL(display_headobj)
		underlays.Cut()
	return

/obj/item/device/biocan/throw_impact(atom/hit_atom)
	visible_message("<span class='red'>\The [src.name] has been shattered. </span>")
	if(headobj)
		if(brainmob)
			alive_mob_list -= headobj.brainmob
			brainmob.ghostize(can_reenter_corpse = FALSE)
			brainmob.loc = headobj
			brainmob.container = headobj
			headobj.brainmob = brainmob
			brainmob = null
		headobj.forceMove(get_turf(src))
		headobj = null
	new /obj/item/weapon/shard(loc)
	playsound(src, "shatter", 50, 1)
	qdel(src)
