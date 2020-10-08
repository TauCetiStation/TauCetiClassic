//Also contains /obj/structure/closet/body_bag because I doubt anyone would think to look for bodybags in /object/structures

/obj/item/bodybag
	name = "body bag"
	desc = "A folded bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_folded"
	w_class = ITEM_SIZE_SMALL

/obj/item/bodybag/attack_self(mob/user)
	var/obj/structure/closet/body_bag/R = new /obj/structure/closet/body_bag(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag_closed"
	icon_closed = "bodybag_closed"
	icon_opened = "bodybag_open"
	var/item_path = /obj/item/bodybag
	density = 0


/obj/structure/closet/body_bag/attackby(W, mob/user)
	if(istype(W, /obj/item/weapon/pen))
		var/t = sanitize(input(user, "What would you like the label to be?", input_default(src.name), null)  as text, MAX_NAME_LEN)
		if (user.get_active_hand() != W)
			return
		if (!in_range(src, user) && src.loc != user)
			return
		if (t)
			src.name = "body bag - "
			src.name += t
			src.add_overlay(image(src.icon, "bodybag_label"))
		else
			src.name = "body bag"
	//..() //Doesn't need to run the parent. Since when can fucking bodybags be welded shut? -Agouri
		return

	else if(iswirecutter(W))
		to_chat(user, "You cut the tag off the bodybag")
		src.name = "body bag"
		src.cut_overlays()
		return


/obj/structure/closet/body_bag/close()
	if(..())
		density = 0
		return 1
	return 0


/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	..()
	if(!iscarbon(usr) && !isrobot(usr))
		return
	if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if(opened)	return 0
		if(contents.len)	return 0
		visible_message("[usr] folds up the [src.name]")
		new item_path(get_turf(src))
		qdel(src)
		return

/obj/structure/closet/bodybag/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened


/obj/item/bodybag/cryobag
	name = "stasis bag"
	desc = "A folded, non-reusable bag designed to prevent additional damage to an occupant at the cost of genetic damage."
	icon = 'icons/obj/cryobag.dmi'
	icon_state = "bodybag_folded"

/obj/item/bodybag/cryobag/attack_self(mob/user)
	var/obj/structure/closet/body_bag/cryobag/R = new /obj/structure/closet/body_bag/cryobag(user.loc)
	R.add_fingerprint(user)
	qdel(src)



/obj/structure/closet/body_bag/cryobag
	name = "stasis bag"
	desc = "A non-reusable plastic bag designed to prevent additional damage to an occupant at the cost of genetic damage."
	icon = 'icons/obj/cryobag.dmi'
	item_path = /obj/item/bodybag/cryobag
	var/used = 0

/obj/structure/closet/body_bag/cryobag/open()
	. = ..()
	if(used)
		var/obj/item/O = new/obj/item(src.loc)
		O.name = "used stasis bag"
		O.icon = src.icon
		O.icon_state = "bodybag_used"
		O.desc = "Pretty useless now.."
		qdel(src)

/obj/structure/closet/body_bag/cryobag/Entered(atom/movable/AM, atom/oldLoc)
	if(isliving(AM))
		var/mob/living/M = AM
		M.ExtinguishMob()
		M.apply_status_effect(STATUS_EFFECT_STASIS_BAG, null, TRUE)
		used++
	..()

/obj/structure/closet/body_bag/cryobag/dump_contents()
	for(var/mob/living/M in contents)
		M.remove_status_effect(STATUS_EFFECT_STASIS_BAG)
	..()

/obj/structure/closet/body_bag/cryobag/MouseDrop(over_object, src_location, over_location)
	if(!iscarbon(usr) && !isrobot(usr))
		return
	if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		to_chat(usr, "<span class='warning'>You can't fold that up anymore..</span>")
	..()
