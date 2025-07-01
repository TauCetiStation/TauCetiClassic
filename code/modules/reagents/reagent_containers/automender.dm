/obj/item/weapon/reagent_containers/automender
	name = "auto-mender"
	desc = "A small electronic device designed to topically apply healing chemicals."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "mender"
	item_state = "mender"
	volume = 200
	possible_transfer_amounts = null
	amount_per_transfer_from_this = 7 // injecting bicaridine or kelotane more than 4 times would cause overdose
	flags = OPENCONTAINER
	slot_flags = SLOT_FLAGS_BELT
	var/delay = 10
	var/emagged = FALSE
	var/ignore_flags = FALSE
	var/applying = FALSE // So it can't be spammed.
	var/static/list/safe_chem_automender_list = list("bicaridine", "kelotane", "dermaline", "tricordrazine")


/obj/item/weapon/reagent_containers/automender/atom_init()
	. = ..()
	update_icon()

/obj/item/weapon/reagent_containers/automender/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		ignore_flags = TRUE
		to_chat(user, "<span class='warning'>You short out the safeties on [src].</span>")
		return TRUE

/obj/item/weapon/reagent_containers/automender/on_reagent_change()
	if(!emagged)
		var/found_forbidden_reagent = FALSE
		for(var/datum/reagent/R in reagents.reagent_list)
			if(!safe_chem_automender_list.Find(R.id))
				reagents.del_reagent(R.id)
				found_forbidden_reagent = TRUE
		if(found_forbidden_reagent)
			if(ismob(loc))
				to_chat(loc, "<span class='warning'>[src] identifies and removes a harmful substance.</span>")
			else
				visible_message("<span class='warning'>[src] identifies and removes a harmful substance.</span>")
	update_icon()

/obj/item/weapon/reagent_containers/automender/update_icon()
	if(applying)
		icon_state = "mender-active"
	else
		icon_state = "mender"
	update_overlays()

/obj/item/weapon/reagent_containers/automender/proc/update_overlays()
	cut_overlays()
	if(reagents.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/syringe.dmi', "mender-fluid")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)
	var/reag_pct = round((reagents.total_volume / volume) * 100)
	var/mutable_appearance/automender_bar = mutable_appearance('icons/obj/syringe.dmi', "app_e")
	switch(reag_pct)
		if(51 to 100)
			automender_bar.icon_state = "app_hf"
		if(1 to 50)
			automender_bar.icon_state = "app_he"
		if(0)
			automender_bar.icon_state = "app_e"
	add_overlay(automender_bar)

/obj/item/weapon/reagent_containers/automender/proc/apply(mob/living/M, mob/user)
	if(!reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	if(applying)
		to_chat(user, "<span class='warning'>You're already applying [src].</span>")
		return

	if(ignore_flags || M.can_inject(user, user.get_targetzone()))
		if(M == user)
			M.visible_message("[user] begins mending themselves with [src].", "<span class='notice'>You begin mending yourself with [src].</span>")
		else
			user.visible_message("<span class='warning'>[user] begins mending [M] with [src].</span>", "<span class='notice'>You begin mending [M] with [src].</span>")
		if(M.reagents)
			applying = TRUE
			update_icon()
			while(do_after(user, delay, target = M))
				apply_to(M, user)
				if(!reagents.total_volume)
					to_chat(user, "<span class='notice'>[src] is out of reagents and powers down automatically.</span>")
					break
		applying = FALSE
		user.SetNextMove(CLICK_CD_MELEE)
		update_icon()

/obj/item/weapon/reagent_containers/automender/attack(mob/living/M, mob/user)
	if(!istype(M) || !iscarbon(M))
		return
	apply(M, user)

/obj/item/weapon/reagent_containers/automender/proc/apply_to(mob/living/carbon/M, mob/user)
	if(reagents && reagents.total_volume)
		var/list/injected = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			injected += R.name
		var/contained = get_english_list(injected)
		M.log_combat(user, "injected with [name], reagents: [contained] (INTENT: [uppertext(user.a_intent)])")

		reagents.reaction(M, INGEST)
		var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>[trans] units injected. [reagents.total_volume] units remaining in [src].</span>")

		playsound(src, 'sound/effects/hypospray.ogg', VOL_EFFECTS_MASTER, 25)

/obj/item/weapon/reagent_containers/automender/brute
	name = "brute auto-mender"
	list_reagents = list("bicaridine" = 200)

/obj/item/weapon/reagent_containers/automender/burn
	name = "burn auto-mender"
	list_reagents = list("dermaline" = 200)

/obj/item/weapon/reagent_containers/automender/dual
	name = "dual auto-mender"
	list_reagents = list("tricordrazine" = 200)
