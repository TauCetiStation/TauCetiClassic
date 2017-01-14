/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 */

/*
 * Beds
 */
/obj/structure/stool/bed
	name = "bed"
	desc = "This is used to lie in, sleep in or strap on."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bed"
	can_buckle = 1
	buckle_lying = 1

/obj/structure/stool/bed/psych
	name = "psychiatrists couch"
	desc = "For prime comfort during psychiatric evaluations."
	icon = 'icons/obj/objects.dmi'
	icon_state = "psychbed"

/obj/structure/stool/bed/alien
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "abed"

/obj/structure/stool/bed/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/stool/bed/CanPass(atom/movable/mover)
	if(ishuman(mover) && mover.checkpass(PASSCRAWL))
		mover.layer = 2.7
	return ..()

/obj/structure/stool/bed/CheckExit(atom/movable/O as mob|obj)
	if(istype(O) && O.checkpass(PASSCRAWL))
		O.layer = 4.0
	return ..()

/obj/structure/stool/bed/Process_Spacemove(movement_dir = 0)
	if(buckled_mob)
		return buckled_mob.Process_Spacemove(movement_dir)
	return ..()

/obj/structure/stool/bed/examine(mob/user)
	..()
	var/T = get_turf(src)
	var/mob/living/carbon/human/H = locate() in T
	if(H && H.crawling)
		to_chat(user, "Someone is hiding under [src]")

/*
 * Roller beds
 */
/obj/structure/stool/bed/roller
	name = "roller bed"
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "down"
	anchored = 0
	var/type_roller = /obj/item/roller

/obj/structure/stool/bed/roller/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,src) || istype(W, /obj/item/roller_holder))
		if(buckled_mob)
			user_unbuckle_mob()
		else
			visible_message("[user] collapses \the [src.name].")
			new type_roller(get_turf(src))
			spawn(0)
				qdel(src)
		return
	..()

/obj/structure/stool/bed/roller/CanPass(atom/movable/mover)
	if(ishuman(mover) && mover.checkpass(PASSCRAWL))
		return 0
	return ..()

/obj/item/roller
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	w_class = 4 // Can't be put in backpacks. Oh well.
	var/type_bed = /obj/structure/stool/bed/roller
	var/type_holder = /obj/item/roller_holder


/obj/item/roller/attack_self(mob/user)
	var/obj/structure/stool/bed/roller/R = new type_bed(user.loc)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/roller_holder))
		var/obj/item/roller_holder/RH = W
		if(!RH.held)
			to_chat(user, "<span class='notice'>You collect the roller bed.</span>")
			src.loc = RH
			RH.held = src
			return
	..()

/obj/item/roller_holder
	name = "roller bed rack"
	desc = "A rack for carrying a collapsed roller bed."
	icon = 'icons/obj/rollerbed.dmi'
	icon_state = "folded"
	var/held = /obj/item/roller
	var/type_bed = /obj/structure/stool/bed/roller

/obj/item/roller_holder/New()
	..()
	held = new held(src)

/obj/item/roller_holder/attack_self(mob/user)

	if(!held)
		to_chat(user, "<span class='notice'>The rack is empty.</span>")
		return

	to_chat(user, "<span class='notice'>You deploy the roller bed.</span>")
	var/obj/structure/stool/bed/roller/R = new type_bed(user.loc)
	R.add_fingerprint(user)
	qdel(held)
	held = null

/obj/structure/stool/bed/roller/post_buckle_mob(mob/living/M)
	if(M == buckled_mob)
		density = 1
		icon_state = "up"
	else
		density = 0
		icon_state = "down"
	return ..()

/obj/structure/stool/bed/roller/MouseDrop(over_object, src_location, over_location)
	..()
	if((over_object == usr && (in_range(src, usr) || usr.contents.Find(src))))
		if(!ishuman(usr))
			return
		if(buckled_mob)
			return 0
		visible_message("[usr] collapses \the [src.name].")
		new type_roller(get_turf(src))
		qdel(src)
		return

/obj/structure/stool/bed/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		var/mob/living/L = G.affecting
		user.visible_message("<span class='notice'>[user] attempts to buckle [L] into \the [src]!</span>")
		if(do_after(user, 20, target = src))
			L.loc = loc
			if(buckle_mob(L))
				L.visible_message(\
					"<span class='danger'>[L.name] is buckled to [src] by [user.name]!</span>",\
					"<span class='danger'>You are buckled to [src] by [user.name]!</span>",\
					"<span class='notice'>You hear metal clanking.</span>")
	return
