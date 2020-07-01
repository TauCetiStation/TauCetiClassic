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

/obj/structure/stool/bed/chair/janitorialcart/get_climb_time(mob/living/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.shoes, /obj/item/clothing/shoes/boots/galoshes))
			. *= 0.5

/obj/structure/stool/bed/chair/janitorialcart/on_propelled_bump(atom/A)
	. = ..()
	if(prob(30))
		flip()
	else
		spill(30)

/obj/structure/stool/bed/chair/janitorialcart/flip()
	..()
	if(flipped)
		spill(200) // So even the bucket is flipped out.

/obj/structure/stool/bed/chair/janitorialcart/examine(mob/user)
	..()
	if(mybucket)
		to_chat(user, "The bucket contains [mybucket.reagents.total_volume] unit\s of liquid.")
	else
		to_chat(user, "There is no bucket mounted on it!")

//Altclick the cart with a reagent container to pour things into the bucket without putting the bottle in trash
/obj/structure/stool/bed/chair/janitorialcart/AltClick(mob/living/user)
	if(user.next_move > world.time || user.incapacitated() || !Adjacent(user))
		return

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return

	var/obj/item/I = user.get_active_hand()
	if(istype(I, /obj/item/weapon/reagent_containers) && mybucket)
		var/obj/item/weapon/reagent_containers/C = I
		C.afterattack(mybucket, user, TRUE)
		update_icon()

// Mousedrop the mop to put it onto janitorialcart.
/obj/structure/stool/bed/chair/janitorialcart/MouseDrop_T(atom/movable/AM, mob/living/user)
	if(istype(AM, /obj/structure/mopbucket) && !mybucket)
		AM.forceMove(src)
		mybucket = AM
		to_chat(user, "<span class='notice'>You mount the [AM] on the janicart.</span>")
		update_icon()
		return
	else if(istype(AM, /obj/item/weapon/mop))
		if(!mymop)
			// In case it was in hands.
			user.drop_from_inventory(AM, src)
			mymop = AM
			update_icon()
			updateUsrDialog()
			to_chat(user, "<span class='notice'>You put [AM] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>The cart already has a mop attached.</span>")
	var/turf/T = get_turf(src)
	if(T == get_turf(AM))
		if(isliving(AM))
			if(buckled_mob)
				user_unbuckle_mob(AM)
			else
				user_buckle_mob(AM, user)
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

	else if (istype(I, /obj/item/weapon/reagent_containers/glass) && mybucket)
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

	else if(istype(I, /obj/item/weapon/reagent_containers/spray/cleaner) && !myspray)
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
	if(user.a_intent == INTENT_HARM)
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
	cut_overlays()

	if(mybucket)
		add_overlay("cart_bucket")
		if(mybucket.reagents.total_volume >= 1)
			add_overlay("cart_water")
	if(mybag)
		add_overlay("cart_garbage")
	if(mymop)
		add_overlay("cart_mop")
	if(myspray)
		add_overlay("cart_spray")
	if(myreplacer)
		add_overlay("cart_replacer")
	if(signs)
		add_overlay("cart_sign[signs]")

//This is called if the cart is caught in an explosion, or destroyed by weapon fire
/obj/structure/stool/bed/chair/janitorialcart/proc/spill(chance = 100)
	var/turf/dropspot = get_turf(src)
	if(mymop && prob(chance))
		mymop.forceMove(dropspot)
		INVOKE_ASYNC(mymop, /obj.proc/tumble_async, 2)
		mymop = null

	if(myspray && prob(chance))
		myspray.forceMove(dropspot)
		INVOKE_ASYNC(myspray, /obj.proc/tumble_async, 3)
		myspray = null

	if(myreplacer && prob(chance))
		myreplacer.forceMove(dropspot)
		INVOKE_ASYNC(myreplacer, /obj.proc/tumble_async, 2)
		myreplacer = null

	if(mybucket) // Bucket is heavier, harder to knock off.
		if(prob(chance * 0.5))
			mybucket.forceMove(dropspot)
			mybucket.reagents.reaction(dropspot, method=TOUCH)
			if(dropspot.reagents)
				mybucket.reagents.trans_to(dropspot, amount=mybucket.reagents.total_volume)
			else
				mybucket.reagents.clear_reagents()
			INVOKE_ASYNC(mybucket, /obj.proc/tumble_async, 1)
			mybucket = null
		else // But the water is gone anyway.
			mybucket.reagents.reaction(dropspot, method=TOUCH)
			if(dropspot.reagents)
				mybucket.reagents.trans_to(dropspot, amount=mybucket.reagents.total_volume)
			else
				mybucket.reagents.clear_reagents()
			update_icon()

	if(signs)
		for(var/obj/item/weapon/caution/Sign in src)
			if(prob(chance * 2))
				signs--
				Sign.forceMove(dropspot)
				INVOKE_ASYNC(Sign, /obj.proc/tumble_async, 3)
				if(signs == 0)
					break

	if(mybag && prob(chance * 2))//Bag is flimsy
		mybag.forceMove(dropspot)
		INVOKE_ASYNC(mybag, /obj.proc/tumble_async, 1)
		mybag.spill()//trashbag spills its contents too
		mybag = null

	if(buckled_mob && prob(chance * 0.5))
		buckled_mob.apply_effect(6, STUN, 0)
		buckled_mob.apply_effect(6, WEAKEN, 0)
		buckled_mob.apply_effect(12, STUTTER, 0)

	update_icon()

/obj/structure/stool/bed/chair/janitorialcart/ex_act(severity)
	spill(100 / severity)
	..()

/obj/structure/stool/bed/chair/janitorialcart/bullet_act(obj/item/projectile/Proj)
	spill(Proj.damage * 10)
