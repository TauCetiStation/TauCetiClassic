/* Pens!
 * Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 */


/*
 * Pens
 */
/obj/item/weapon/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	m_amt = 10
	var/colour = "black"	//what colour the ink is!
	pressure_resistance = 2


/obj/item/weapon/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/weapon/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/weapon/pen/invisible
	desc = "It's an invisble pen marker."
	icon_state = "pen"
	colour = "white"

/*
 * Sleepy Pens
 */
/obj/item/weapon/pen/sleepypen
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\""
	flags = OPENCONTAINER
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/sleepypen/New()
	var/datum/reagents/R = new/datum/reagents(30) //Used to be 300
	reagents = R
	R.my_atom = src
	R.add_reagent("chloralhydrate", 22)	//Used to be 100 sleep toxin//30 Chloral seems to be fatal, reducing it to 22./N
	..()
	return


/obj/item/weapon/pen/sleepypen/attack(mob/M, mob/user)
	..()
	if(!(istype(M,/mob)))
		return

	if(reagents.total_volume)
		if(M.reagents) reagents.trans_to(M, 50) //used to be 150
	return


/*
 * Parapens
 */
 /obj/item/weapon/pen/paralysis
	flags = OPENCONTAINER
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/paralysis/attack(mob/living/M, mob/user)
	..()
	if(!(istype(M,/mob)))
		return

	if(M.can_inject(user,1))
		if(reagents.total_volume)
			if(M.reagents) reagents.trans_to(M, 50)
	return


/obj/item/weapon/pen/paralysis/New()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	R.add_reagent("zombiepowder", 10)
	R.add_reagent("cryptobiolin", 15)
	..()
	return

/obj/item/weapon/pen/edagger
	origin_tech = "combat=3;syndicate=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut") //these wont show up if the pen is off
	var/on = 0

/obj/item/weapon/pen/edagger/attack_self(mob/living/user)
	if(on)
		on = 0
		force = initial(force)
		w_class = initial(w_class)
		edge = initial(edge)
		name = initial(name)
		hitsound = initial(hitsound)
		throwforce = initial(throwforce)
		playsound(user, 'sound/weapons/saberoff.ogg', 5, 1)
		to_chat(user, "<span class='warning'>[src] can now be concealed.</span>")
	else
		on = 1
		force = 18
		w_class = 3
		edge = 1
		name = "energy dagger"
		hitsound = 'sound/weapons/blade1.ogg'
		throwforce = 35
		playsound(user, 'sound/weapons/saberon.ogg', 5, 1)
		to_chat(user, "<span class='warning'>[src] is now active.</span>")
	update_icon()

/obj/item/weapon/pen/edagger/update_icon()
	if(on)
		icon_state = "edagger"
		item_state = "edagger"
	else
		clean_blood()
		icon_state = initial(icon_state) //looks like a normal pen when off.
		item_state = initial(item_state)

