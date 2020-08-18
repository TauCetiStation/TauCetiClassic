//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "biotech=3"

	req_access = list(access_robotics)

	//Revised. Brainmob is now contained directly within object of transfer. MMI in this case.

	var/locked = FALSE
	var/mob/living/carbon/brain/brainmob = null//The current occupant.
	var/mob/living/silicon/robot = null//Appears unused.
	var/obj/mecha = null//This does not appear to be used outside of reference in mecha.dm.

/obj/item/device/mmi/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/brain) && !brainmob) //Time to stick a brain in it --NEO
		var/obj/item/brain/B = I
		if(!B.brainmob)
			to_chat(user, "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain.</span>")
			return
		visible_message("<span class='notice'>[user] sticks \a [B] into \the [src].</span>")

		brainmob = B.brainmob
		B.brainmob = null
		brainmob.forceMove(src)
		brainmob.container = src
		brainmob.stat = CONSCIOUS
		dead_mob_list -= brainmob//Update dem lists
		alive_mob_list += brainmob

		name = "Man-Machine Interface: [brainmob.real_name]"
		icon_state = "mmi_full"

		locked = TRUE

		feedback_inc("cyborg_mmis_filled", 1)
		qdel(B)
		return

	else if(istype(I, /obj/item/weapon/holder/diona) && !brainmob)
		visible_message("<span class='notice'>[user] sticks \a [I] into \the [src].</span>")

		var/mob/living/carbon/monkey/diona/D = locate(/mob/living/carbon/monkey/diona) in I
		if(!D)
			world.log << "This is seriously really wrong, and I would like to keep a message for this case."
		if(!D.mind || !D.key)
			to_chat(user, "<span class='warning'>It would appear [D] is void of consciousness, defeats MMI's purpose.</span>")
			return
		transfer_nymph(D)

		feedback_inc("cyborg_mmis_filled",1)
		qdel(D)
		return

	else if((istype(I, /obj/item/weapon/card/id)||istype(I, /obj/item/device/pda)) && brainmob)
		if(allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the brain holder.</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	else if(brainmob)
		// Oh noooeeeee
		user.SetNextMove(CLICK_CD_MELEE)
		return I.attack(brainmob, user)

	return ..()

/obj/item/device/mmi/attack_self(mob/user)
	if(!brainmob)
		to_chat(user, "<span class='warning'>You upend the MMI, but there's nothing in it.</span>")
		return
	else if(locked)
		to_chat(user, "<span class='warning'>You upend the MMI, but the brain is clamped into place.</span>")
		return
	var/mob/living/carbon/monkey/diona/D = locate(/mob/living/carbon/monkey/diona) in brainmob
	icon_state = "mmi_empty"
	name = "Man-Machine Interface"
	if(D)
		to_chat(user, "<span class='notice'>You uppend the MMI, dropping [brainmob.real_name] onto the floor.</span>")
		D.forceMove(user.loc)
		if(brainmob.mind)
			brainmob.mind.transfer_to(D)
		brainmob = null
		qdel(brainmob)
		return
	else
		to_chat(user, "<span class='notice'>You upend the MMI, spilling the brain onto the floor.</span>")
		var/obj/item/brain/brain = new(user.loc)
		brainmob.container = null//Reset brainmob mmi var.
		brainmob.loc = brain//Throw mob into brain.
		alive_mob_list -= brainmob//Get outta here
		brain.brainmob = brainmob//Set the brain to use the brainmob
		brainmob = null
		qdel(brainmob)

/obj/item/device/mmi/MouseDrop_T(mob/living/carbon/monkey/diona/target, mob/user)
	if(user.incapacitated() || !istype(target))
		return
	if(target.buckled || !in_range(user, src) || !in_range(user, target))
		return
	if(target == user)
		visible_message("<span class='red'>[usr] starts climbing into the MMI.</span>", 3)
	else
		if(target.anchored)
			return
		visible_message("<span class='red'>[usr] starts stuffing [target.name] into the MMI.</span>", 3)
	if(user.is_busy() || !do_after(usr, 20, target = usr))
		return
	if(target == user)
		visible_message("<span class='red'>[user.name] climbs into the MMI.</span>","<span class='notice'>You climb into the MMI.</span>")
	else if(target != user)
		visible_message("<span class='danger'>[user.name] stuffs [target.name] into the MMI!</span>","<span class='red'>You stuff [target.name] into the MMI!</span>")
	else
		return
	transfer_nymph(target)

	feedback_inc("cyborg_mmis_filled",1)

/obj/item/device/mmi/proc/transfer_identity(mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->robot people.
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna
	brainmob.container = src

	name = "Man-Machine Interface: [brainmob.real_name]"
	icon_state = "mmi_full"
	locked = TRUE

/obj/item/device/mmi/proc/transfer_nymph(mob/living/carbon/monkey/diona/D)
	brainmob = new(src)
	brainmob.name = D.real_name
	brainmob.real_name = D.real_name
	brainmob.dna = D.dna
	brainmob.container = src
	brainmob.stat = CONSCIOUS
	if(D.mind)
		D.mind.transfer_to(brainmob)
	D.forceMove(brainmob)

	name = "Man-Machine Interface: [brainmob.real_name]"
	icon_state = "mmi_fullnymph"
	locked = TRUE

/obj/item/device/mmi/radio_enabled
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	origin_tech = "biotech=4"

	var/obj/item/device/radio/radio = null//Let's give it a radio.

/obj/item/device/mmi/radio_enabled/atom_init()
	. = ..()
	radio = new(src)//Spawns a radio inside the MMI.
	radio.broadcasting = 1//So it's broadcasting from the start.

/obj/item/device/mmi/radio_enabled/verb/Toggle_Broadcasting() //Allows the brain to toggle the radio functions.
	set name = "Toggle Broadcasting"
	set desc = "Toggle broadcasting channel on or off."
	set category = "MMI"
	set src = usr.loc//In user location, or in MMI in this case.
	set popup_menu = 0//Will not appear when right clicking.

	if(brainmob.incapacitated())//Only the brainmob will trigger these so no further check is necessary.
		to_chat(brainmob, "Can't do that while incapacitated or dead.")
		return

	radio.broadcasting = radio.broadcasting==1 ? 0 : 1
	to_chat(brainmob, "<span class='notice'>Radio is [radio.broadcasting==1 ? "now" : "no longer"] broadcasting.</span>")

/obj/item/device/mmi/radio_enabled/verb/Toggle_Listening()
	set name = "Toggle Listening"
	set desc = "Toggle listening channel on or off."
	set category = "MMI"
	set src = usr.loc
	set popup_menu = 0

	if(brainmob.incapacitated())
		to_chat(brainmob, "Can't do that while incapacitated or dead.")
		return

	radio.listening = radio.listening==1 ? 0 : 1
	to_chat(brainmob, "<span class='notice'>Radio is [radio.listening==1 ? "now" : "no longer"] receiving broadcast.</span>")

/obj/item/device/mmi/emp_act(severity)
	if(!brainmob)
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage += rand(20,30)
			if(2)
				brainmob.emp_damage += rand(10,20)
			if(3)
				brainmob.emp_damage += rand(0,10)
	..()
