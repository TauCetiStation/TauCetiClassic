/obj/item/device/biocan
	name = "Biogel can"
	desc = "Biogel jar for supporting life in head. Extremely fragile!"
	icon = 'icons/obj/biocan.dmi'
	icon_state = "biocan"
	w_class = 3
	appearance_flags = KEEP_TOGETHER
	var/obj/item/weapon/organ/head/headobj = null
	var/image/display_headobj = null
	var/mob/living/carbon/brain/brainmob = null
	var/commutator_enabled = FALSE

/obj/item/device/biocan/verb/safe_eject()
	set name = "Safely eject head"
	set category = "Object"
	set src in view(0)

	if(!usr.is_busy() && do_after(usr,20))
		if(brainmob)
			brainmob.container = null
			brainmob.loc = headobj
			headobj.brainmob = brainmob
			brainmob.timeofhostdeath = world.time
			living_mob_list -= brainmob
			brainmob = null
			headobj.forceMove(get_turf(src))
			headobj = null
		if(display_headobj)
			QDEL_NULL(display_headobj)
			underlays.Cut()

/obj/item/device/biocan/verb/toggle_speech()
	set name = "Disable commutator"
	set category = "Object"
	set src in view(0)

	if(commutator_enabled)
		commutator_enabled = FALSE
		to_chat(usr, "<span class='warning'>You disable text to speech device, preventing [src.name]'s occupant from shouting.</span>")
	else
		commutator_enabled = TRUE
		to_chat(usr, "<span class='warning'>You enable commutating device, allowing your prisoner to speak.</span>")

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
				living_mob_list += brainmob
			display_headobj = new (src)
			display_headobj.appearance = W.appearance
			display_headobj.transform = matrix()
			display_headobj.dir = SOUTH
			display_headobj.pixel_y = 0
			display_headobj.pixel_x = 0
			display_headobj.layer = FLOAT_LAYER
			display_headobj.plane = -32767
			underlays.Add(display_headobj)
			update_icon()

/obj/item/device/biocan/attack_self(mob/user)
	visible_message("<cpan class='red'>\The [src.name] contents has been splashed over the floor. </span>", "<span class='rose'> You hear a splash. </span>")
	if(brainmob)
		living_mob_list -= headobj.brainmob
		brainmob.ghostize(can_reenter_corpse = FALSE)
		brainmob = null
		headobj.forceMove(get_turf(src))
		headobj = null
	if(display_headobj)
		QDEL_NULL(display_headobj)
		underlays.Cut()
	return

/obj/item/device/biocan/throw_impact(atom/hit_atom)
	visible_message("<cpan class='red'>\The [src.name] contents has been splashed over the floor. </span>", "<span class='rose'> You hear a splash. </span>")
	if(brainmob)
		living_mob_list -= headobj.brainmob
		brainmob.ghostize(can_reenter_corpse = FALSE)
		brainmob = null
	if(headobj)
		headobj.forceMove(get_turf(src))
		headobj = null
	new /obj/item/weapon/shard(loc)
	playsound(src, "shatter", 50, 1)
	qdel(src)