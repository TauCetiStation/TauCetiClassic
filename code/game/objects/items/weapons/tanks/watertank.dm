//Hydroponics tank and base code
/obj/item/weapon/watertank
	name = "backpack water tank"
	desc = "A S.U.N.S.H.I.N.E. brand watertank backpack with nozzle to water plants."
	slot_flags = SLOT_BACK
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "waterbackpack"
	item_state = "waterbackpack"
	w_class = 4.0
	action_button_name = "Toggle Mister"

	var/obj/item/weapon/noz
	var/on = 0
	var/max_vol = 500

/obj/item/weapon/watertank/New()
	..()
	create_reagents(max_vol)
	reagents.add_reagent("cleaner", src.max_vol)

	noz = make_noz()

/obj/item/weapon/watertank/ui_action_click()
	toggle_mister()

/obj/item/weapon/watertank/verb/toggle_mister()
	set name = "Toggle Mister"
	set category = "Object"
	var/mob/M = usr
	if (M.back != src)
		to_chat(usr, "<span class='warning'>The watertank must be worn properly to use!</span>")
		return
	on = !on

	var/mob/living/carbon/human/user = usr
	if(on)
		if(noz == null)
			noz = make_noz()

		//Detach the nozzle into the user's hands
		if(!user.put_in_hands(noz))
			on = 0
			to_chat(user, "<span class='warning'>You need a free hand to hold the mister!</span>")
			return
		noz.loc = user
	else
		//Remove from their hands and put back "into" the tank
		remove_noz()
	return

/obj/item/weapon/watertank/proc/make_noz()
	return new /obj/item/weapon/reagent_containers/spray/mister(src)

/obj/item/weapon/watertank/equipped(mob/user, slot)
	if (slot != slot_back)
		remove_noz()

/obj/item/weapon/watertank/proc/remove_noz()
	if(ismob(noz.loc))
		var/mob/M = noz.loc
		M.unEquip(noz, 1)
	return

/obj/item/weapon/watertank/Destroy()
	if (on)
		remove_noz()
		qdel(noz)
		noz = null
	return ..()

/obj/item/weapon/watertank/attack_hand(mob/user)
	if(src.loc == user)
		ui_action_click()
		return
	..()

/obj/item/weapon/watertank/MouseDrop(obj/over_object)
	var/mob/H = src.loc
	if(istype(H))
		switch(over_object.name)
			if("r_hand")
				if(H.r_hand)
					return
				if(!H.unEquip(src))
					return
				H.put_in_r_hand(src)
			if("l_hand")
				if(H.l_hand)
					return
				if(!H.unEquip(src))
					return
				H.put_in_l_hand(src)
	return

/obj/item/weapon/watertank/attackby(obj/item/W, mob/user, params)
	if(W == noz)
		remove_noz()
		return
	..()

/mob/proc/getWatertankSlot()
	return slot_back

/obj/item/weapon/watertank/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "[reagents.total_volume] units of liquid left!")

/obj/item/weapon/reagent_containers/spray/mister
	name = "water mister"
	desc = "A mister nozzle attached to a water tank."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "mister"
	item_state = "mister"
	w_class = 4
	throwforce = 0 //we shall not abuse
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(25,50,100)
	volume = 500
	flags = OPENCONTAINER | NOBLUDGEON

	var/obj/item/weapon/watertank/tank

/obj/item/weapon/reagent_containers/spray/mister/New(parent_tank)
	..()
	if(check_tank_exists(parent_tank))
		tank = parent_tank
		reagents = tank.reagents	//This mister is really just a proxy for the tank's reagents
		loc = tank
	return

// Here is some magic. Problems with drop, no problems with throw. Too wierd for me - Smalltasty
/obj/item/weapon/reagent_containers/spray/mister/dropped(mob/user)
	to_chat(user, "<span class='notice'>The mister snaps back onto the watertank.</span>")
	tank.on = 0
	spawn(1) loc = tank


/obj/item/weapon/reagent_containers/spray/mister/attack_self()
	return

/obj/item/weapon/reagent_containers/spray/mister/proc/check_tank_exists(parent_tank)
	if (!parent_tank || !istype(parent_tank, /obj/item/weapon/watertank))	//To avoid weird issues from admin spawns
		if(ismob(loc))
			var/mob/M = loc
			M.unEquip(src)
		qdel(src)
		return 0
	else
		return 1

/obj/item/weapon/reagent_containers/spray/mister/afterattack(obj/target, mob/user, proximity)
	if(target.loc == loc || target == tank) //Safety check so you don't fill your mister with mutagen or something and then blast yourself in the face with it putting it away
		return
	..()

//Janitor tank
/obj/item/weapon/watertank/janitor
	name = "backpack water tank"
	desc = "A janitorial watertank backpack with nozzle to clean dirt and graffiti."
	icon_state = "waterbackpackjani"
	item_state = "waterbackpackjani"

/obj/item/weapon/watertank/janitor/New()
	..()
	reagents.add_reagent("cleaner", src.max_vol)

/obj/item/weapon/reagent_containers/spray/mister/janitor
	name = "janitor spray nozzle"
	desc = "A janitorial spray nozzle attached to a watertank, designed to clean up large messes."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "misterjani"
	item_state = "misterjani"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list()

/obj/item/weapon/watertank/janitor/make_noz()
	return new /obj/item/weapon/reagent_containers/spray/mister/janitor(src)

/obj/item/weapon/reagent_containers/spray/mister/janitor/attack_self(mob/user)
	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	to_chat(user, "<span class='notice'>You [amount_per_transfer_from_this == 10 ? "remove" : "fix"] the nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>")
