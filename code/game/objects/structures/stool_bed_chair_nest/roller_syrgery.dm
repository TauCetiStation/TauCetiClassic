/*
 * Roller beds
 */
/obj/structure/stool/bed/roller_surg
	name = "advancet roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	anchored = 0

/obj/structure/stool/bed/roller_surg/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/roller_holder_surg))
		if(buckled_mob)
			user_unbuckle_mob()
		else
			visible_message("[user] collapses \the [src.name].")
			new/obj/item/roller_surg(get_turf(src))
			spawn(0)
				qdel(src)
		return
	..()

/obj/structure/stool/bed/roller_surg/CanPass(atom/movable/mover)
	if(ishuman(mover) && mover.checkpass(PASSCRAWL))
		return 0
	return ..()

/obj/item/roller_surg
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	w_class = 4 // Can't be put in backpacks. Oh well.

/obj/item/roller_surg/attack_self(mob/user)
	var/obj/structure/stool/bed/roller_surg/R = new /obj/structure/stool/bed/roller_surg(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller_surg/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/roller_holder_surg))
		var/obj/item/roller_holder_surg/RH = W
		if(!RH.held)
			user << "<span class='notice'>You collect the roller bed.</span>"
			src.loc = RH
			RH.held = src
			return
	..()

/obj/item/roller_holder_surg
	name = "roller bed rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	var/obj/item/roller_surg/held

/obj/item/roller_holder_surg/New()
	..()
	held = new /obj/item/roller_surg(src)

/obj/item/roller_holder_surg/attack_self(mob/user as mob)

	if(!held)
		user << "<span class='notice'>The rack is empty.</span>"
		return

	user << "<span class='notice'>You deploy the roller bed.</span>"
	var/obj/structure/stool/bed/roller_surg/R = new /obj/structure/stool/bed/roller_surg(user.loc)
	R.add_fingerprint(user)
	qdel(held)
	held = null

/obj/structure/stool/bed/roller_surg/post_buckle_mob(mob/living/M)
	if(M == buckled_mob)
		density = 1
		icon_state = "up"
	else
		density = 0
		icon_state = "down"
	return ..()

/obj/structure/stool/bed/roller_surg/MouseDrop(over_object, src_location, over_location)
	..()
	if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if(!ishuman(usr))
			return
		if(buckled_mob)
			return 0
		visible_message("[usr] collapses \the [src.name].")
		new/obj/item/roller_surg(get_turf(src))
		qdel(src)
		return

