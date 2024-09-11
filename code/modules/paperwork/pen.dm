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
	slot_flags = SLOT_FLAGS_BELT | SLOT_FLAGS_EARS
	throwforce = 0
	w_class = SIZE_MINUSCULE
	throw_speed = 4
	throw_range = 15
	m_amt = 10
	var/colour = "black"	// can we make it HEX?
	var/click_cooldown = 0

/obj/item/weapon/pen/proc/get_signature(mob/user)
	return (user && user.real_name) ? user.real_name : "Anonymous"

/obj/item/weapon/pen/attack_self(mob/user)
	if(click_cooldown <= world.time)
		click_cooldown = world.time + 2
		to_chat(user, "<span class='notice'>Click.</span>")
		playsound(src, 'sound/items/penclick.ogg', VOL_EFFECTS_MASTER, 50)

/obj/item/weapon/pen/ghost
	desc = "An expensive looking pen. You wonder, what is it's cost?"
	colour = "purple"
	icon_state = "fountainpen" //paththegreat: Eli Stevens
	var/entity = ""

/obj/item/weapon/pen/ghost/attack_self(mob/living/carbon/human/user)
	..()
	if(user.getBrainLoss() >= 60 || (user.mind && (user.mind.holy_role || user.mind.role_alt_title == "Paranormal Investigator")))
		if(!entity)
			to_chat(user, "<span class='notice'>You feel the [src] quiver, as another entity attempts to possess it.</span>")
			var/list/choices = list()
			for(var/mob/dead/observer/D as anything in observer_list)
				if(D.started_as_observer)
					choices += D.name
			if(choices.len)
				entity = sanitize(pick(choices))

/obj/item/weapon/pen/ghost/afterattack(atom/target, mob/user, proximity, params)
	..()
	if(!proximity || !entity)
		return
	var/list/phrases = list("Why did you do that, [user]?", "Do you not have anything better to do?", "Murder! Murder! MURDER!", "Did [target] deserve this?",
	                        "Why are you doing this again?", "Don't, [user].", "Do not even think about such things!", "Do I deserve eternally witnessing your misery?",
	                        "Why am I here?", "Can we go now?", "Listen, [target] doesn't have anything to do with this.", "Make it stooop.", "Call the arms!",
	                        "Sound the alarms, all of them!", "Are you, [user], any better?", "You can always give up.", "Why even?")
	to_chat(user, "<span class='bold'>[entity]</span> [pick("moans", "laments", "whines", "blubbers")], \"[pick(phrases)]\"")

/obj/item/weapon/pen/ghost/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		OS.scanned_type = src.type
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60 || user.mind.holy_role || user.mind.role_alt_title == "Paranormal Investigator")
			if(entity && istype(I, /obj/item/weapon/nullrod))
				entity = ""
				to_chat(user, "<span class='warning'>[capitalize(src.name)] quivers and shakes, as it's entity leaves!</span>")
				return
			else if(istype(I, /obj/item/weapon/storage/bible))
				var/obj/item/weapon/storage/bible/B = I
				entity = pick(B.religion.deity_names)
				to_chat(user, "<span class='notice'>You feel a ceratin divine intelligence, as [entity] possesess \the [src].</span>")
				return
			else if(istype(I, /obj/item/weapon/photo))
				var/obj/item/weapon/photo/P = I
				for(var/A in P.photographed_names)
					if(P.photographed_names[A] == /mob/dead/observer)
						entity = A
						to_chat(user, "<span class='notice'>You feel the [src] quiver, as another entity attempts to possess it.</span>")
						break
				return
	return ..()

/obj/item/weapon/pen/ghost/get_signature(mob/user)
	return entity ? entity : (user && user.real_name) ? user.real_name : "Anonymous"

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
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/sleepypen/atom_init()
	var/datum/reagents/R = new/datum/reagents(30) //Used to be 300
	reagents = R
	R.my_atom = src
	R.add_reagent("chloralhydrate", 22)	//Used to be 100 sleep toxin//30 Chloral seems to be fatal, reducing it to 22./N
	. = ..()


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
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "materials=2;syndicate=5"

/obj/item/weapon/pen/paralysis/attack(mob/living/M, mob/user)
	..()

	if(!istype(M))
		return

	if(reagents.total_volume && M.reagents && M.try_inject(user, TRUE, TRUE, TRUE))
		reagents.trans_to(M, 50)

/obj/item/weapon/pen/paralysis/atom_init()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	R.add_reagent("zombiepowder", 10)
	R.add_reagent("cryptobiolin", 15)
	. = ..()

/obj/item/weapon/pen/edagger
	origin_tech = "combat=3;syndicate=1"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut") //these wont show up if the pen is off

	qualities = null
	flags = NOBLOODY

	var/on = 0
	var/hacked = 0

	var/blade_color

/obj/item/weapon/pen/edagger/atom_init()
	. = ..()
	blade_color = pick("blue", "red", "green", "purple", "yellow", "pink", "black")
	switch(blade_color)
		if("red")
			light_color = COLOR_RED
		if("blue")
			light_color = COLOR_BLUE
		if("green")
			light_color = COLOR_GREEN
		if("purple")
			light_color = COLOR_PURPLE
		if("yellow")
			light_color = COLOR_YELLOW
		if("pink")
			light_color = COLOR_PINK
		if("black")
			light_color = COLOR_GRAY


/obj/item/weapon/pen/edagger/attack_self(mob/living/user)
	..()
	toggle(user)

/obj/item/weapon/pen/edagger/proc/toggle(mob/living/user)
	if(on)
		on = 0
		force = initial(force)
		w_class = initial(w_class)
		edge = initial(edge)
		sharp = initial(sharp)
		can_embed = initial(can_embed)
		name = initial(name)
		hitsound = initial(hitsound)
		throwforce = initial(throwforce)
		throw_speed = initial(throw_speed)
		playsound(user, 'sound/weapons/saberoff.ogg', VOL_EFFECTS_MASTER, 5)
		to_chat(user, "<span class='warning'>[src] can now be concealed.</span>")
		qualities = null
		set_light(0)
	else
		on = 1
		force = 18
		w_class = SIZE_SMALL
		edge = TRUE
		sharp = TRUE
		can_embed = FALSE
		name = "energy dagger"
		hitsound = list('sound/weapons/blade1.ogg')
		throwforce = 35
		throw_speed = 5
		playsound(user, 'sound/weapons/saberon.ogg', VOL_EFFECTS_MASTER, 5)
		to_chat(user, "<span class='warning'>[src] is now active.</span>")
		qualities = list(
			QUALITY_CUTTING = 1
			)
		set_light(1)
	update_icon()

/obj/item/weapon/pen/edagger/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(ispulsing(I))
		if(!hacked)
			hacked = TRUE
			to_chat(user,"<span class='warning'>RNBW_ENGAGE</span>")
			blade_color = "rainbow"
			if (on)
				toggle(user)
		else
			to_chat(user,"<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")


/obj/item/weapon/pen/edagger/update_icon()
	if(on)
		icon_state = "edagger[blade_color]"
		item_state = "edagger[blade_color]"
	else
		clean_blood()
		icon_state = initial(icon_state) //looks like a normal pen when off.
		item_state = initial(item_state)

/*
 * Colors of edagger
*/

/obj/item/weapon/pen/edagger/blue/atom_init()
	. = ..()
	blade_color = "blue"
	light_color = COLOR_BLUE

/obj/item/weapon/pen/edagger/red/atom_init()
	. = ..()
	blade_color = "red"
	light_color = COLOR_RED

/obj/item/weapon/pen/edagger/green/atom_init()
	. = ..()
	blade_color = "green"
	light_color = COLOR_GREEN

/obj/item/weapon/pen/edagger/purple/atom_init()
	. = ..()
	blade_color = "purple"
	light_color = COLOR_PURPLE

/obj/item/weapon/pen/edagger/yellow/atom_init()
	. = ..()
	blade_color = "yellow"
	light_color = COLOR_YELLOW

/obj/item/weapon/pen/edagger/pink/atom_init()
	. = ..()
	blade_color = "pink"
	light_color = COLOR_PINK

/obj/item/weapon/pen/edagger/black/atom_init()
	. = ..()
	blade_color = "black"
	light_color = COLOR_GRAY

/*
 * Legit edagger for NT boys
 */

/obj/item/weapon/pen/edagger/legitimate
	origin_tech = "combat=3"

/obj/item/weapon/pen/edagger/legitimate/atom_init()
	. = ..()
	blade_color = "blue"
	light_color = COLOR_BLUE

/*
 * Chameleon pen
 */
/obj/item/weapon/pen/chameleon
	var/signature = ""

/obj/item/weapon/pen/chameleon/attack_self(mob/user)
	..()
	signature = sanitize(input("Enter new signature. Leave blank for 'Anonymous'", "New Signature", input_default(signature)))

/obj/item/weapon/pen/chameleon/get_signature(mob/user)
	return signature ? signature : "Anonymous"

/obj/item/weapon/pen/chameleon/verb/set_colour()
	set name = "Change Pen Colour"
	set category = "Object"

	var/list/possible_colours = list ("Yellow", "Green", "Pink", "Blue", "Orange", "Cyan", "Red", "Invisible", "Black")
	var/selected_type = input("Pick new colour.", "Pen Colour", null, null) as null|anything in possible_colours

	if(selected_type)
		switch(selected_type)
			if("Yellow")
				colour = "yellow"
			if("Green")
				colour = "lime"
			if("Pink")
				colour = "pink"
			if("Blue")
				colour = "blue"
			if("Orange")
				colour = "orange"
			if("Cyan")
				colour = "cyan"
			if("Red")
				colour = "red"
			if("Invisible")
				colour = "white"
			else
				colour = "black"
		to_chat(usr, "<span class='info'>You select the [lowertext(selected_type)] ink container.</span>")
