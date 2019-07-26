/obj/structure/stool/bed/chair/janitorialcart
	name = "janitorial cart"
	desc = "The ultimate in janitorial carts! Has space for water, mops, signs, trash bags, and more!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	anchored = FALSE
	density = TRUE
	throwpass = TRUE //You can throw objects over this, despite it's density.")
	climbable = TRUE

	can_flipped = TRUE
	buckle_movable = TRUE
	can_flipped = TRUE

	roll_sound = 'sound/effects/roll.ogg'

	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null
	var/obj/item/weapon/mop/mymop = null
	var/obj/item/weapon/reagent_containers/spray/myspray = null
	var/obj/item/device/lightreplacer/myreplacer = null
	var/obj/structure/mopbucket/mybucket = null

	var/signs = 0 //maximum capacity hardcoded below

/obj/structure/stool/bed/chair/janitorialcart/atom_init()
	. = ..()
	janitorialcart_list += src

/obj/structure/stool/bed/chair/janitorialcart/Destroy()
	janitorialcart_list -= src
	QDEL_NULL(mybag)
	QDEL_NULL(mymop)
	QDEL_NULL(myspray)
	QDEL_NULL(myreplacer)
	return ..()

/obj/structure/stool/bed/chair/janitorialcart/on_propelled_bump(atom/A)
	. = ..()
	if(prob(30))
		flip()
	else
		spill(30)

/obj/structure/stool/bed/chair/janitorialcart/flip()
	..()
	if(flipped)
		spill(100)

/obj/structure/stool/bed/chair/janitorialcart/examine(mob/user)
	..()
	if(mybucket)
		to_chat(user, "[bicon(src)] The bucket contains [mybucket.reagents.total_volume] unit\s of liquid.")
	else
		to_chat(user, "[bicon(src)] There is no bucket mounted on it!")

//Altclick the cart with a mop to stow the mop away
//Altclick the cart with a reagent container to pour things into the bucket without putting the bottle in trash
/obj/structure/stool/bed/chair/janitorialcart/AltClick(mob/living/user)
	if(user.next_move > world.time || user.incapacitated() || !Adjacent(user))
		return

	var/obj/item/I = user.get_active_hand()
	if(istype(I, /obj/item/weapon/mop))
		if(!mymop)
			user.drop_from_inventory(I, src)
			mymop = I
			update_icon()
			updateUsrDialog()
			to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>The cart already has a mop attached.</span>")

	else if(istype(I, /obj/item/weapon/reagent_containers) && mybucket)
		var/obj/item/weapon/reagent_containers/C = I
		C.afterattack(mybucket, user, TRUE)
		update_icon()

/obj/structure/stool/bed/chair/janitorialcart/MouseDrop_T(atom/movable/AM, mob/living/user)
	if(istype(AM, /obj/structure/mopbucket) && !mybucket)
		AM.forceMove(src)
		mybucket = AM
		to_chat(user, "<span class='notice'>You mount the [AM] on the janicart.</span>")
		update_icon()
		return
	var/turf/T = get_turf(src)
	if(T == get_turf(AM))
		if(isliving(AM))
			if(buckled_mob)
				user_unbuckle_mob(AM)
			else
				user_buckle_mob(src, AM)
	else
		..()

/obj/structure/stool/bed/chair/janitorialcart/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop) || istype(I, /obj/item/weapon/reagent_containers/glass/rag) || istype(I, /obj/item/weapon/soap))
		if(mybucket)
			if(I.reagents.total_volume < I.reagents.maximum_volume)
				if(mybucket.reagents.total_volume < 1)
					to_chat(user, "<span class='notice'>[mybucket] is empty.</span>")
				else
					mybucket.reagents.trans_to(I, 5)
					to_chat(user, "<span class='notice'>You wet [I] in [mybucket].</span>")
					playsound(src, 'sound/effects/slosh.ogg', VOL_EFFECTS_MASTER, 25)
			else
				to_chat(user, "<span class='notice'>[I] can't absorb anymore liquid.</span>")
		else
			to_chat(user, "<span class='notice'>There is no bucket mounted here to dip [I] into.</span>")
		return

	else if (istype(I, /obj/item/weapon/reagent_containers/glass/bucket) && mybucket)
		I.afterattack(mybucket, usr, 1)
		update_icon()
		return

	else if(istype(I, /obj/item/weapon/storage/bag/trash) && !mybag)
		user.drop_from_inventory(I, src)
		mybag = I
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		return

	else if(istype(I, /obj/item/weapon/reagent_containers/spray) && !myspray)
		user.drop_from_inventory(I, src)
		myspray = I
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		return

	else if(istype(I, /obj/item/device/lightreplacer) && !myreplacer)
		user.drop_from_inventory(I, src)
		myreplacer = I
		update_icon()
		updateUsrDialog()
		to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		return

	else if(istype(I, /obj/item/weapon/caution))
		if(signs < 4)
			user.drop_from_inventory(I, src)
			signs++
			update_icon()
			updateUsrDialog()
			to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] can't hold any more signs.</span>")
		return

	else if(mybag)
		mybag.attackby(I, user)
		return

	..()

/obj/structure/stool/bed/chair/janitorialcart/attack_hand(mob/user)
	if(user.a_intent == I_HURT)
		..()
		return

	user.set_machine(src)
	var/dat
	if(mybag)
		dat += "<a href='?src=\ref[src];take_item=garbage'>[mybag.name]</a><br>"
	if(mybucket)
		dat += "<a href='?src=\ref[src];take_item=bucket'>[mybucket.name]</a><br>"
	if(mymop)
		dat += "<a href='?src=\ref[src];take_item=mop'>[mymop.name]</a><br>"
	if(myspray)
		dat += "<a href='?src=\ref[src];take_item=spray'>[myspray.name]</a><br>"
	if(myreplacer)
		dat += "<a href='?src=\ref[src];take_item=replacer'>[myreplacer.name]</a><br>"
	if(signs)
		dat += "<a href='?src=\ref[src];take_item=sign'>[signs] sign\s</a><br>"

	var/datum/browser/popup = new(user, "janicart", name, 240, 160)
	popup.set_content(dat)
	popup.open()

/obj/structure/stool/bed/chair/janitorialcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	switch(href_list["take_item"])
		if("garbage")
			if(mybag)
				mybag.update_icon()
				user.put_in_hands(mybag)
				to_chat(user, "<span class='notice'>You take [mybag] from [src].</span>")
				mybag = null
		if("bucket")
			if(mybucket)
				mybucket.update_icon()
				mybucket.forceMove(get_turf(src))
				to_chat(user, "<span class='notice'>You unmount [mybucket] from [src].</span>")
				mybucket = null
		if("mop")
			if(mymop)
				user.put_in_hands(mymop)
				to_chat(user, "<span class='notice'>You take [mymop] from [src].</span>")
				mymop = null
		if("spray")
			if(myspray)
				myspray.update_icon()
				user.put_in_hands(myspray)
				to_chat(user, "<span class='notice'>You take [myspray] from [src].</span>")
				myspray = null
		if("replacer")
			if(myreplacer)
				myreplacer.update_icon()
				user.put_in_hands(myreplacer)
				to_chat(user, "<span class='notice'>You take [myreplacer] from [src].</span>")
				myreplacer = null
		if("sign")
			if(signs)
				var/obj/item/weapon/caution/Sign = locate() in src
				if(Sign)
					user.put_in_hands(Sign)
					to_chat(user, "<span class='notice'>You take \a [Sign] from [src].</span>")
					signs--
				else
					warning("[src] signs ([signs]) didn't match contents")
					signs = 0

	update_icon()
	updateUsrDialog()

/obj/structure/stool/bed/chair/janitorialcart/update_icon()
	overlays = list()

	if(mybucket)
		overlays += "cart_bucket"
		if(mybucket.reagents.total_volume >= 1)
			overlays += "cart_water"
	if(mybag)
		overlays += "cart_garbage"
	if(mymop)
		overlays += "cart_mop"
	if(myspray)
		overlays += "cart_spray"
	if(myreplacer)
		overlays += "cart_replacer"
	if(signs)
		overlays += "cart_sign[signs]"

//This is called if the cart is caught in an explosion, or destroyed by weapon fire
/obj/structure/stool/bed/chair/janitorialcart/proc/spill(chance = 100)
	var/turf/dropspot = get_turf(src)
	if(mymop && prob(chance))
		mymop.forceMove(dropspot)
		mymop.tumble(2)
		mymop = null

	if(myspray && prob(chance))
		myspray.forceMove(dropspot)
		myspray.tumble(3)
		myspray = null

	if(myreplacer && prob(chance))
		myreplacer.forceMove(dropspot)
		myreplacer.tumble(3)
		myreplacer = null

	if(mybucket && prob(chance * 0.5)) // Bucket is heavier, harder to knock off.
		mybucket.forceMove(dropspot)
		mybucket.tumble(1)
		mybucket = null

	if(signs)
		for(var/obj/item/weapon/caution/Sign in src)
			if(prob(chance * 2))
				signs--
				Sign.forceMove(dropspot)
				Sign.tumble(3)
				if(signs == 0)
					break

	if(mybag && prob(chance * 2))//Bag is flimsy
		mybag.forceMove(dropspot)
		mybag.tumble(1)
		mybag.spill()//trashbag spills its contents too
		mybag = null

	update_icon()

/obj/structure/stool/bed/chair/janitorialcart/ex_act(severity)
	spill(100 / severity)
	..()

//old style retardo-cart
/obj/structure/stool/bed/chair/janicart_legacy
	name = "janicart"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "pussywagon"
	anchored = 1
	density = 1
	flags = OPENCONTAINER
	//copypaste sorry
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null
	var/callme = "pimpin' ride"	//how do people refer to it?


/obj/structure/stool/bed/chair/janicart_legacy/atom_init()
	handle_rotation()
	create_reagents(100)
	. = ..()


/obj/structure/stool/bed/chair/janicart_legacy/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "This [callme] contains [reagents.total_volume] unit\s of water!")
		if(mybag)
			to_chat(user, "\A [mybag] is hanging on the [callme].")


/obj/structure/stool/bed/chair/janicart_legacy/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop))
		if(reagents.total_volume > 1)
			reagents.trans_to(I, 2)
			to_chat(user, "<span class='notice'>You wet [I] in the [callme].</span>")
			playsound(src, 'sound/effects/slosh.ogg', VOL_EFFECTS_MASTER)
		else
			to_chat(user, "<span class='notice'>This [callme] is out of water!</span>")
	else if(istype(I, /obj/item/key))
		to_chat(user, "Hold [I] in one of your hands while you drive this [callme].")
	else if(istype(I, /obj/item/weapon/storage/bag/trash))
		to_chat(user, "<span class='notice'>You hook the trashbag onto the [callme].</span>")
		user.drop_item()
		I.loc = src
		mybag = I


/obj/structure/stool/bed/chair/janicart_legacy/attack_hand(mob/user)
	if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null
	else
		..()


/obj/structure/stool/bed/chair/janicart_legacy/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis)
		unbuckle_mob()
	if(istype(user.l_hand, /obj/item/key) || istype(user.r_hand, /obj/item/key))
		step(src, direction)
		update_mob()
		handle_rotation()
	else
		to_chat(user, "<span class='notice'>You'll need the keys in one of your hands to drive this [callme].</span>")


/obj/structure/stool/bed/chair/janicart_legacy/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc


/obj/structure/stool/bed/chair/janicart_legacy/post_buckle_mob(mob/living/M)
	update_mob()
	return ..()


/obj/structure/stool/bed/chair/janicart_legacy/unbuckle_mob()
	var/mob/living/M = ..()
	if(M)
		M.pixel_x = 0
		M.pixel_y = 0
	return M


/obj/structure/stool/bed/chair/janicart_legacy/handle_rotation()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	update_mob()


/obj/structure/stool/bed/chair/janicart_legacy/proc/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 13
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -13
				buckled_mob.pixel_y = 7


/obj/structure/stool/bed/chair/janicart_legacy/bullet_act(obj/item/projectile/Proj)
	if(buckled_mob)
		if(prob(85))
			return buckled_mob.bullet_act(Proj)
	visible_message("<span class='warning'>[Proj] ricochets off the [callme]!</span>")


/obj/item/key
	name = "key"
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = ITEM_SIZE_TINY
