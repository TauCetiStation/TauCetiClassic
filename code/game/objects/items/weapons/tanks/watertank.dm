//Hydroponics tank and base code
/obj/item/weapon/reagent_containers/watertank_backpack
	name = "backpack water tank"
	desc = "A S.U.N.S.H.I.N.E. brand watertank backpack with nozzle to water plants."
	slot_flags = SLOT_FLAGS_BACK
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "waterbackpack"
	item_state = "waterbackpack"
	flags = OPENCONTAINER
	w_class = ITEM_SIZE_LARGE
	action_button_name = "Toggle Mister"

	var/obj/item/weapon/reagent_containers/spray/mister/noz
	volume = 500

/obj/item/weapon/reagent_containers/watertank_backpack/atom_init()
	. = ..()
	reagents.add_reagent("water", volume)
	if(ispath(noz))
		noz = new noz(src, src)
	else
		noz = new(src, src)

/obj/item/weapon/reagent_containers/watertank_backpack/ui_action_click()
	toggle_mister()

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
		ui_action_click()
		return
	..()

/obj/item/weapon/reagent_containers/watertank_backpack/MouseDrop()
	if(ismob(loc))
		if(!CanMouseDrop(src))
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
	w_class = ITEM_SIZE_LARGE
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
	noz = /obj/item/weapon/reagent_containers/spray/mister/janitor

/obj/item/weapon/reagent_containers/watertank_backpack/janitor/atom_init()
	. = ..()
	reagents.clear_reagents()
	reagents.add_reagent("cleaner", volume)

/obj/item/weapon/reagent_containers/spray/mister/janitor
	name = "janitor spray nozzle"
	desc = "A janitorial spray nozzle attached to a watertank, designed to clean up large messes."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "misterjani"
	item_state = "misterjani"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5, 10)
	spray_size = 1
	spray_sizes = list(1,3)
