/obj/machinery/iv_drip
	name = "IV drip"
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "iv_drip"
	anchored = FALSE
	density = FALSE
	interact_offline = TRUE
	var/mob/living/carbon/human/attached = null
	var/mode = 1 // 1 is injecting, 0 is taking blood.
	var/obj/item/weapon/reagent_containers/beaker = null


/obj/machinery/iv_drip/atom_init()
	. = ..()
	update_icon()

/obj/machinery/iv_drip/update_icon()
	if(attached)
		if(mode)
			icon_state = "injecting"
		else
			icon_state = "donating"
	else
		if(mode)
			icon_state = "injectidle"
		else
			icon_state = "donateidle"

	cut_overlays()

	if(beaker)
		if(attached)
			add_overlay("beakeractive")
		else
			add_overlay("beakeridle")
		if(beaker.reagents.total_volume)
			var/image/filling = image('icons/obj/iv_drip.dmi', src, "reagent")

			var/percent = round((beaker.reagents.total_volume / beaker.volume) * 100)
			switch(percent)
				if(0 to 9)		filling.icon_state = "reagent0"
				if(10 to 24) 	filling.icon_state = "reagent10"
				if(25 to 49)	filling.icon_state = "reagent25"
				if(50 to 74)	filling.icon_state = "reagent50"
				if(75 to 79)	filling.icon_state = "reagent75"
				if(80 to 90)	filling.icon_state = "reagent80"
				if(91 to INFINITY)	filling.icon_state = "reagent100"

			filling.icon += mix_color_from_reagents(beaker.reagents.reagent_list)
			add_overlay(filling)

/obj/machinery/iv_drip/on_reagent_change()
	..()
	update_icon()

/obj/machinery/iv_drip/MouseDrop(over_object, src_location, over_location)
	..()
	if(!iscarbon(usr) && !isrobot(usr))
		return
	if(attached)
		visible_message("[src.attached] is detached from \the [src]")
		src.attached = null
		update_icon()
		return

	if(!(Adjacent(usr) && Adjacent(over_object) && usr.Adjacent(over_object)))
		return

	if(ishuman(over_object))
		visible_message("[usr] attaches \the [src] to \the [over_object].")
		src.attached = over_object
		update_icon()

/obj/machinery/iv_drip/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/reagent_containers/glass/beaker) || istype(W, /obj/item/weapon/reagent_containers/blood) || istype(W, /obj/item/weapon/reagent_containers/glass/bottle))
		if(!isnull(src.beaker))
			to_chat(user, "There is already a reagent container loaded!")
			return
		user.drop_from_inventory(W, src)
		src.beaker = W
		to_chat(user, "You attach \the [W] to \the [src].")
		update_icon()
		return
	else
		return ..()

/obj/machinery/iv_drip/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return ..()
	new /obj/item/stack/sheet/metal(loc)
	..()

/obj/machinery/iv_drip/process()
	//set background = 1

	if(src.attached)

		if(!(get_dist(src, src.attached) <= 1 && isturf(src.attached.loc)))
			visible_message("The needle is ripped out of [src.attached], doesn't that hurt?")
			attached:apply_damage(3, BRUTE, pick(BP_R_ARM , BP_L_ARM))
			src.attached = null
			update_icon()
			return

	if(src.attached && src.beaker)
		// Give blood
		if(mode)
			if(src.beaker.volume > 0)
				var/transfer_amount = REAGENTS_METABOLISM
				if(istype(src.beaker, /obj/item/weapon/reagent_containers/blood))
					// speed up transfer on blood packs
					transfer_amount = 4
				beaker.reagents.trans_to(src.attached, transfer_amount)
				update_icon()

		// Take blood
		else
			var/amount = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			amount = min(amount, 4)
			// If the beaker is full, ping
			if(amount == 0)
				if(prob(5)) visible_message("\The [src] pings.")
				return

			var/mob/living/carbon/human/T = attached

			if(!istype(T)) return
			if(!T.dna)
				return
			if(NOCLONE in T.mutations)
				return

			if(HAS_TRAIT(T, TRAIT_NO_BLOOD))
				return

			// If the human is losing too much blood, beep.
			if(T.blood_amount() < BLOOD_VOLUME_SAFE && prob(5))
				visible_message("\The [src] beeps loudly.")

			T.take_blood(beaker, amount)

/obj/machinery/iv_drip/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()

/obj/machinery/iv_drip/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(beaker)
		beaker.loc = get_turf(src)
		beaker = null
		update_icon()

/obj/machinery/iv_drip/verb/toggle_mode()
	set name = "Toggle Mode"
	set category = "Object"
	set src in oview(1)

	if(isliving(usr) && !usr.incapacitated())
		mode = !mode
		to_chat(usr, "The IV drip is now [mode ? "injecting" : "taking blood"].")
		update_icon()

/obj/machinery/iv_drip/examine(mob/user)
	..()
	if(src in oview(2, user))
		to_chat(user, "The IV drip is [mode ? "injecting" : "taking blood"].")

		if(beaker)
			if(beaker.reagents && beaker.reagents.reagent_list.len)
				to_chat(user, "<span class='notice'>Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid.</span>")
			else
				to_chat(user, "<span class='notice'>Attached is an empty [beaker].</span>")
		else
			to_chat(user, "<span class='notice'>No chemicals are attached.</span>")

		to_chat(user, "<span class='notice'>[attached ? attached : "No one"] is attached.</span>")
