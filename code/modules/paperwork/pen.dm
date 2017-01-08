/* Pens!
 * Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 *		Penlight
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
	flags = FPRINT | TABLEPASS
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


/obj/item/weapon/pen/attack(mob/M, mob/user)
	if(!ismob(M))
		return
	to_chat(user, "<span class='warning'>You stab [M] with the pen.</span>")
//	M << "\red You feel a tiny prick!" //That's a whole lot of meta!
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stabbed with [name]  by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to stab [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) Used the [name] to stab [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	return


/*
 * Sleepy Pens
 */
/obj/item/weapon/pen/sleepypen
	desc = "It's a black ink pen with a sharp point and a carefully engraved \"Waffle Co.\""
	flags = FPRINT | TABLEPASS | OPENCONTAINER
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
	if(!(istype(M,/mob)))
		return
	..()
	if(reagents.total_volume)
		if(M.reagents) reagents.trans_to(M, 50) //used to be 150
	return


/*
 * Parapens
 */
 /obj/item/weapon/pen/paralysis
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	slot_flags = SLOT_BELT
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/paralysis/attack(mob/living/M, mob/user)

	if(!(istype(M,/mob)))
		return

	..()


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


/*
* Penlight
*/
//Procs copypasted from /obj/item/device/flashlight 
//It's a better way get result. You can do it better? Do it!
/obj/item/weapon/pen/light
	name = "penlight"
	desc = "A pen-sized light, used by medical staff."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "penlight"
	flags = FPRINT | TABLEPASS | CONDUCT
	var/on = 0
	var/brightness_on = 3
	w_class = 1

/obj/item/weapon/pen/light/initialize()
	..()
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(brightness_on)
	else
		icon_state = initial(icon_state)
		set_light(0)

/obj/item/weapon/pen/light/Destroy()
	if(on)
		set_light(0)
	return ..()

/obj/item/weapon/pen/light/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in this [user.loc].")//To prevent some lighting anomalities.
		return 0
	on = !on
	update_brightness(user)
	action_button_name = null
	return 1

/obj/item/weapon/pen/light/proc/update_brightness(mob/user = null)
	if(on)
		icon_state = "[initial(icon_state)]-on"
		set_light(brightness_on)
	else
		icon_state = initial(icon_state)
		set_light(0)

/obj/item/weapon/pen/light/attack(mob/living/M, mob/living/user)
	add_fingerprint(user)
	if(on && user.zone_sel.selecting == "eyes")

		if(((CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))	//too dumb to use flashlight properly
			return ..()	//just hit them in the head

		if(!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")	//don't have dexterity
			to_chat(user, "<span class='notice'>You don't have the dexterity to do this!</span>")
			return

		var/mob/living/carbon/human/H = M	//mob has protective eyewear
		if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			to_chat(user, "<span class='notice'>You're going to need to remove that [(H.head && H.head.flags & HEADCOVERSEYES) ? "helmet" : (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) ? "mask": "glasses"] first.</span>")
			return

		if(M == user)	//they're using it on themselves
			if(!M.blinded)
				M.flash_eyes()
				M.visible_message("<span class='notice'>[M] directs [src] to \his eyes.</span>", \
									 "<span class='notice'>You wave the light in front of your eyes! Trippy!</span>")
			else
				M.visible_message("<span class='notice'>[M] directs [src] to \his eyes.</span>", \
									 "<span class='notice'>You wave the light in front of your eyes.</span>")
			return

		user.visible_message("<span class='notice'>[user] directs [src] to [M]'s eyes.</span>", \
							 "<span class='notice'>You direct [src] to [M]'s eyes.</span>")

		if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))	//robots and aliens are unaffected
			if(M.stat == DEAD || M.sdisabilities & BLIND)	//mob is dead or fully blind
				to_chat(user, "<span class='notice'>[M] pupils does not react to the light!</span>")
			else if(XRAY in M.mutations)	//mob has X-RAY vision
				M.flash_eyes() //Yes, you can still get flashed wit X-Ray.
				to_chat(user, "<span class='notice'>[M] pupils give an eerie glow!</span>")
			else	//they're okay!
				if(!M.blinded)
					M.flash_eyes()	//flash the affected mob
					to_chat(user, "<span class='notice'>[M]'s pupils narrow.</span>")
	else
		return ..()
