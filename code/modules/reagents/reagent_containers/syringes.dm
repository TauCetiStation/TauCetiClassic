////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/syringe
	name = "syringe"
	desc = "A syringe."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	g_amt = 150
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null //list(5,10,15)
	volume = 15
	w_class = SIZE_MINUSCULE
	sharp = 1
	flags = NOBLUDGEON


/obj/item/weapon/reagent_containers/syringe/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/pickup(mob/living/user)
	. = ..()
	if(HAS_TRAIT_FROM(user, TRAIT_SYRINGE_FEAR, QUALITY_TRAIT))
		cause_syringe_fear(user)
	update_icon()

/obj/item/weapon/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_self(mob/user)

	switch(mode)
		if(SYRINGE_DRAW)
			mode = SYRINGE_INJECT
		if(SYRINGE_INJECT)
			mode = SYRINGE_DRAW
		if(SYRINGE_BROKEN)
			return
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_paw()
	return attack_hand()

/obj/item/weapon/reagent_containers/syringe/afterattack(atom/target, mob/user, proximity, params)
	..()

/obj/item/weapon/reagent_containers/syringe/update_icon()
	if(mode == SYRINGE_BROKEN)
		icon_state = "broken"
		cut_overlays()
		return
	var/rounded_vol = round(reagents.total_volume,5)
	cut_overlays()
	if(ismob(loc))
		var/injoverlay
		switch(mode)
			if (SYRINGE_DRAW)
				injoverlay = "draw"
			if (SYRINGE_INJECT)
				injoverlay = "inject"
		add_overlay(injoverlay)
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "syringe10")

		filling.icon_state = "syringe[rounded_vol]"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)

/obj/item/weapon/reagent_containers/ld50_syringe
	name = "Lethal Injection Syringe"
	desc = "A syringe used for lethal injections."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = null //list(5,10,15)
	volume = 50
	flags = NOBLUDGEON
	mode = SYRINGE_DRAW

/obj/item/weapon/reagent_containers/ld50_syringe/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/pickup(mob/living/user)
	. = ..()
	if(HAS_TRAIT_FROM(user, TRAIT_SYRINGE_FEAR, QUALITY_TRAIT))
		cause_syringe_fear(user)
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/attack_self(mob/user)
	mode = !mode
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/attack_paw()
	return attack_hand()

/obj/item/weapon/reagent_containers/ld50_syringe/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(!target.reagents) return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "<span class='warning'>The syringe is full.</span>")
				return

			if(ismob(target))
				if(iscarbon(target))//I Do not want it to suck 50 units out of people
					to_chat(usr, "This needle isn't designed for drawing blood.")
					return
			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "<span class='warning'>[target] is empty.</span>")
					return

				if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
					to_chat(user, "<span class='warning'>You cannot directly remove reagents from this object.</span>")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, "<span class='notice'>You fill the syringe with [trans] units of the solution.</span>")
			if (reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, "<span class='warning'>The Syringe is empty.</span>")
				return
			if(istype(target, /obj/item/weapon/implantcase/chem))
				return
			if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food))
				to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
				return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "<span class='warning'>[target] is full.</span>")
				return

			if(ismob(target) && target != user)
				user.visible_message("<span class='warning'><B>[user] is trying to inject [target] with a giant syringe!</B></span>")
				if(!do_mob(user, target, 300)) return
				user.visible_message("<span class='warning'>[user] injects [target] with a giant syringe!</span>")
				reagents.reaction(target, INGEST)
			if(ismob(target) && target == user)
				reagents.reaction(target, INGEST)
			spawn(5)
				var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
				to_chat(user, "<span class='notice'>You inject [trans] units of the solution. The syringe now contains [src.reagents.total_volume] units.</span>")
				if (reagents.total_volume >= reagents.maximum_volume && mode==SYRINGE_INJECT)
					mode = SYRINGE_DRAW
					update_icon()
	return


/obj/item/weapon/reagent_containers/ld50_syringe/update_icon()
	var/rounded_vol = round(reagents.total_volume,50)
	if(ismob(loc))
		var/mode_t
		switch(mode)
			if (SYRINGE_DRAW)
				mode_t = "d"
			if (SYRINGE_INJECT)
				mode_t = "i"
		icon_state = "[mode_t][rounded_vol]"
	else
		icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"


////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////



/obj/item/weapon/reagent_containers/syringe/inaprovaline
	name = "Syringe (inaprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."

/obj/item/weapon/reagent_containers/syringe/inaprovaline/atom_init()
	. = ..()
	reagents.add_reagent("inaprovaline", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/antitoxin
	name = "Syringe (anti-toxin)"
	desc = "Contains anti-toxins."

/obj/item/weapon/reagent_containers/syringe/antitoxin/atom_init()
	. = ..()
	reagents.add_reagent("anti_toxin", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/antiviral
	name = "Syringe (spaceacillin)"
	desc = "Contains antiviral agents."

/obj/item/weapon/reagent_containers/syringe/antiviral/atom_init()
	. = ..()
	reagents.add_reagent("spaceacillin", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/choral

/obj/item/weapon/reagent_containers/ld50_syringe/choral/atom_init()
	. = ..()
	reagents.add_reagent("chloralhydrate", 50)
	mode = SYRINGE_INJECT
	update_icon()


//Robot syringes
//Not special in any way, code wise. They don't have added variables or procs.
/obj/item/weapon/reagent_containers/syringe/robot/antitoxin
	name = "Syringe (anti-toxin)"
	desc = "Contains anti-toxins."

/obj/item/weapon/reagent_containers/syringe/robot/antitoxin/atom_init()
	. = ..()
	reagents.add_reagent("anti_toxin", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/robot/inoprovaline
	name = "Syringe (inoprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."

/obj/item/weapon/reagent_containers/syringe/robot/inoprovaline/atom_init()
	. = ..()
	reagents.add_reagent("inaprovaline", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/robot/mixed
	name = "Syringe (mixed)"
	desc = "Contains inaprovaline & anti-toxins."

/obj/item/weapon/reagent_containers/syringe/robot/mixed/atom_init()
	. = ..()
	reagents.add_reagent("inaprovaline", 7)
	reagents.add_reagent("anti_toxin", 8)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/mulligan
	name = "Mulligan"
	desc = "A syringe used to completely change the users identity."
	amount_per_transfer_from_this = 1

/obj/item/weapon/reagent_containers/syringe/mulligan/atom_init()
	. = ..()
	reagents.add_reagent("mulligan", 1)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/nutriment

/obj/item/weapon/reagent_containers/syringe/nutriment/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 15)
	mode = SYRINGE_INJECT
	update_icon()
