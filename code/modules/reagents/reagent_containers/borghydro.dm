
/obj/item/weapon/reagent_containers/borghypo
	name = "Cyborg Hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	var/mode = 1
	var/charge_cost = 50
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in seconds)

	var/list/datum/reagents/reagent_list = list()
	var/list/reagent_ids = list("tricordrazine", "inaprovaline", "spaceacillin")
	//var/list/reagent_ids = list("dexalin", "kelotane", "bicaridine", "anti_toxin", "inaprovaline", "spaceacillin")

/obj/item/weapon/reagent_containers/borghypo/surgeon
	reagent_ids = list("bicaridine", "inaprovaline", "dexalin")

/obj/item/weapon/reagent_containers/borghypo/crisis
	reagent_ids = list("tricordrazine", "inaprovaline", "tramadol")

/obj/item/weapon/reagent_containers/borghypo/atom_init()
	. = ..()
	for(var/R in reagent_ids)
		add_reagent(R)

	START_PROCESSING(SSobj, src)


/obj/item/weapon/reagent_containers/borghypo/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/reagent_containers/borghypo/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
	charge_tick++
	if(charge_tick < recharge_time) return 0
	charge_tick = 0

	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/datum/reagents/RG = reagent_list[mode]
			if(RG.total_volume < RG.maximum_volume) 	//Don't recharge reagents and drain power if the storage is full.
				R.cell.use(charge_cost) 					//Take power from borg...
				RG.add_reagent(reagent_ids[mode], 5)		//And fill hypo with reagent.
	//update_icon()
	return 1

// Purely for testing purposes I swear~
/*
/obj/item/weapon/reagent_containers/borghypo/verb/add_cyanide()
	set src in world
	add_reagent("cyanide")
*/

// Use this to add more chemicals for the borghypo to produce.
/obj/item/weapon/reagent_containers/borghypo/proc/add_reagent(reagent)
	reagent_ids |= reagent
	var/datum/reagents/RG = new(30)
	RG.my_atom = src
	reagent_list += RG

	var/datum/reagents/R = reagent_list[reagent_list.len]
	R.add_reagent(reagent, 30)

/obj/item/weapon/reagent_containers/borghypo/attack(mob/living/M, mob/user)
	var/datum/reagents/R = reagent_list[mode]
	if(!R.total_volume)
		to_chat(user, "<span class='warning'>The injector is empty.</span>")
		return
	if (!istype(M))
		return

	if (R.total_volume && M.try_inject(user, TRUE, TRUE, TRUE))
		R.reaction(M, INGEST)
		if(M.reagents)
			var/trans = R.trans_to(M, amount_per_transfer_from_this)
			to_chat(user, "<span class='notice'>[trans] units injected. [R.total_volume] units remaining.</span>")
	return

/obj/item/weapon/reagent_containers/borghypo/attack_self(mob/user)
	playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, FALSE)		//Change the mode
	mode++
	if(mode > reagent_list.len)
		mode = 1

	charge_tick = 0 //Prevents wasted chems/cell charge if you're cycling through modes.
	var/datum/reagent/R = chemical_reagents_list[reagent_ids[mode]]
	to_chat(user, "<span class='notice'>Synthesizer is now producing '[R.name]'.</span>")
	return

/obj/item/weapon/reagent_containers/borghypo/examine(mob/user)
	..()
	if(src in view(2, user))
		var/empty = 1

		for(var/datum/reagents/RS in reagent_list)
			var/datum/reagent/R = locate() in RS.reagent_list
			if(R)
				to_chat(user, "<span class='notice'>It currently has [R.volume] units of [R.name] stored.</span>")
				empty = 0
		if(empty)
			to_chat(user, "<span class='notice'>It is currently empty. Allow some time for the internal syntheszier to produce more.</span>")
