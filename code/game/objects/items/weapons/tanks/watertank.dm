//Hydroponics tank and base code
/obj/item/weapon/reagent_containers/watertank_backpack
	name = "backpack water tank"
	desc = "A S.U.N.S.H.I.N.E. brand watertank backpack with nozzle to water plants."
	slot_flags = SLOT_FLAGS_BACK
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "waterbackpack"
	item_state = "waterbackpack"
	item_state_world = "waterbackpack_world"
	flags = OPENCONTAINER
	w_class = SIZE_NORMAL

	var/obj/item/weapon/reagent_containers/spray/mister/noz
	volume = 500

	item_action_types = list(/datum/action/item_action/toggle_mister)
	list_reagents = list("water" = 500)

/datum/action/item_action/toggle_mister
	name = "Toggle Mister"

/datum/action/item_action/toggle_mister/Activate()
	var/obj/item/weapon/reagent_containers/watertank_backpack/S = target
	S.toggle_mister()

/obj/item/weapon/reagent_containers/watertank_backpack/atom_init()
	. = ..()
	if(ispath(noz))
		noz = new noz(src, src)
	else
		noz = new(src, src)

/obj/item/weapon/reagent_containers/watertank_backpack/verb/toggle_mister()
	set name = "Toggle Mister"
	set category = "Object"

	var/mob/M = usr
	if(M.back != src)
		to_chat(usr, "<span class='warning'>The [src] must be worn properly to use!</span>")
		return

	if(usr.incapacitated())
		return

	var/mob/living/carbon/human/user = usr
	if(noz.loc == src)
		//Detach the nozzle into the user's hands
		if(!user.put_in_hands(noz))
			to_chat(user, "<span class='warning'>You need a free hand to hold the [noz]!</span>")
			return
	else
		//Remove from their hands and put back "into" the tank
		remove_noz()
	return

/obj/item/weapon/reagent_containers/watertank_backpack/equipped(mob/user, slot)
	..()
	if(slot != SLOT_BACK)
		remove_noz()

/obj/item/weapon/reagent_containers/watertank_backpack/proc/remove_noz()
	if(!noz)
		return

	if(ismob(noz.loc))
		var/mob/M = noz.loc
		if(M.drop_from_inventory(noz, src))
			to_chat(M, "<span class='notice'>\The [noz] snaps back into the [src].</span>")
	else
		noz.forceMove(src)
	return

/obj/item/weapon/reagent_containers/watertank_backpack/Destroy()
	QDEL_NULL(noz)
	return ..()

/obj/item/weapon/reagent_containers/watertank_backpack/attack_hand(mob/user)
	if(loc == user)
		toggle_mister()
		return
	..()

/obj/item/weapon/reagent_containers/watertank_backpack/MouseDrop()
	. = ..()
	if(ismob(loc))
		if(!CanMouseDrop(src, usr))
			return
		var/mob/M = loc
		if(!M.unEquip(src))
			return
		add_fingerprint(usr)
		M.put_in_hands(src)

/obj/item/weapon/reagent_containers/watertank_backpack/attackby(obj/item/I, mob/user, params)
	if(I == noz)
		remove_noz()
	else
		return ..()

/obj/item/weapon/reagent_containers/watertank_backpack/dropped(mob/user)
	..()
	remove_noz()

// This mister item is intended as an extension of the watertank and always attached to it.
// Therefore, it's designed to be "locked" to the player's hands or extended back onto
// the watertank backpack. Allowing it to be placed elsewhere or created without a parent
// watertank object will likely lead to weird behaviour or runtimes.
/obj/item/weapon/reagent_containers/spray/mister
	name = "water mister"
	desc = "A mister nozzle attached to a water tank."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "mister"
	item_state = "mister"
	item_state_world = "mister_world"
	w_class = SIZE_NORMAL
	throwforce = 0 //we shall not abuse
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = list(25,50,100)
	spray_size = 1
	spray_sizes = list(1, 3, 5)
	volume = 500
	slot_flags = null

	var/obj/item/weapon/reagent_containers/watertank_backpack/tank

/obj/item/weapon/reagent_containers/spray/mister/atom_init(mapload, source_tank)
	. = ..()
	tank = source_tank
	if(tank)
		reagents = tank.reagents //This mister is really just a proxy for the tank's reagents

/obj/item/weapon/reagent_containers/spray/mister/Destroy()
	if(tank)
		tank.noz = null
	return ..()

/obj/item/weapon/reagent_containers/spray/mister/dropped(mob/user)
	..()
	if(tank)
		tank.remove_noz()
	else
		qdel(src)

/obj/item/weapon/reagent_containers/spray/mister/afterattack(atom/target, mob/user, proximity, params)
	if(target.loc == loc || target == tank) //Safety check so you don't fill your mister with mutagen or something and then blast yourself in the face with it putting it away
		return
	..()

//Janitor tank
/obj/item/weapon/reagent_containers/watertank_backpack/janitor
	name = "backpack water tank"
	desc = "A janitorial watertank backpack with nozzle to clean dirt and graffiti."
	icon_state = "waterbackpackjani"
	item_state = "waterbackpackjani"
	item_state_world = "waterbackpackjani_world"
	noz = /obj/item/weapon/reagent_containers/spray/mister/janitor
	list_reagents = list("cleaner" = 500)

/obj/item/weapon/reagent_containers/spray/mister/janitor
	name = "janitor spray nozzle"
	desc = "A janitorial spray nozzle attached to a watertank, designed to clean up large messes."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "misterjani"
	item_state = "misterjani"
	item_state_world = "misterjani_world"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5, 10)
	spray_size = 1
	spray_sizes = list(1,3)

/obj/item/weapon/reagent_containers/watertank_backpack/syndie
	name = "chemical tank"
	desc = "A W.A.R.C.R.I.M.E.S. brand chemical backpack with nozzle to cover bodies in fresh chemical burns."
	icon_state = "waterbackpacknuke"
	item_state = "waterbackpacknuke"
	item_state_world = "waterbackpacknuke"
	volume = 1600
	noz = /obj/item/weapon/reagent_containers/spray/mister/syndie
	list_reagents = list("lexorin" = 200, "mindbreaker" = 200, "alphaamanitin" = 200, "space_drugs" = 200, "pacid" = 200, "fuel" = 200, "condensedcapsaicin" = 200, "stoxin" = 200)
	var/obj/item/weapon/storage/backpack/internal_storage
	item_action_types = list(/datum/action/item_action/open_tank_storage)

/obj/item/weapon/reagent_containers/watertank_backpack/syndie/atom_init()
	. = ..()
	internal_storage = new /obj/item/weapon/storage/backpack(src)
	internal_storage.name = "chemical tank's storage"

/datum/action/item_action/open_tank_storage
	name = "Open Storage"

/datum/action/item_action/open_tank_storage/Activate()
	var/obj/item/weapon/reagent_containers/watertank_backpack/syndie/S = target
	S.internal_storage.try_open(usr)

/obj/item/weapon/reagent_containers/spray/mister/syndie
	name = "chemical spray nozzle"
	desc = "Breath of death."
	icon_state = "misternuke"
	item_state = "misternuke"
	item_state_world = "misternuke"
	triple_shot = TRUE
	spray_size = 4
	spray_sizes = list(2)
	possible_transfer_amounts = null
	spray_cloud_move_delay = 2
	spray_cloud_react_delay = 0
	volume = 1600

/obj/item/weapon/reagent_containers/spray/mister/syndie/Spray_at()
	. = ..()
	var/turf/T = get_step(usr, usr.dir)
	T.hotspot_expose(1000, 500)
