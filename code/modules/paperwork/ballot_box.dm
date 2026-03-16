/obj/structure/ballot_box
	name = "ballot box"
	desc = "Урна для голосования."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "ballot_box"
	density = TRUE
	anchored = TRUE
	throwpass = TRUE//You can throw objects over this, despite it's density.")
	climbable = TRUE

	resistance_flags = CAN_BE_HIT
	max_integrity = 100
	hit_particle_type = /particles/tool/digging/wood

	var/open = FALSE

/obj/structure/ballot_box/attackby(obj/item/P, mob/user)
	add_fingerprint(user)

	if(istype(P, /obj/item/weapon/paper) || istype(P, /obj/item/weapon/photo))
		to_chat(user, "<span class='notice'>You put [P] in [src].</span>")
		user.drop_from_inventory(P, open ? loc : src)
		flick("[icon_state]_anim", src)

	else if(iswrenching(P))
		user.SetNextMove(CLICK_CD_INTERACT)
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")

	else if(isscrewing(P))
		if(P.use_tool(src, user, 15, quality = QUALITY_SCREWING))
			user.SetNextMove(CLICK_CD_INTERACT)
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			open = !open
			if(open)
				icon_state = "[initial(icon_state)]_open"
				for(var/obj/item/I as anything in contents)
					I.forceMove(loc)
					I.pixel_x = rand(-6, 6)
					I.pixel_y = rand(-8, -12)
			else
				icon_state = initial(icon_state)
	else
		to_chat(user, "<span class='notice'>You can't put [P] in [src]!</span>")
		..()

/obj/structure/ballot_box/Destroy()
	for(var/obj/item/I as anything in contents)
		I.forceMove(loc)

	new /obj/item/stack/sheet/wood(loc, 2)

	return ..()
