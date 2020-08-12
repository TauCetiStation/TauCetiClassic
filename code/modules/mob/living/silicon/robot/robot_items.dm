// A special tray for the service droid. Allow droid to pick up and drop items as if they were using the tray normally
// Click on table to unload, click on item to load. Otherwise works identically to a tray.
// Unlike the base item "tray", robotrays ONLY pick up food, drinks and condiments.

/obj/item/weapon/tray/robotray
	name = "RoboTray"
	desc = "An autoloading tray specialized for carrying refreshments."

/obj/item/weapon/tray/robotray/afterattack(atom/target, mob/user, proximity, params)
	if ( !target )
		return
	// pick up items, mostly copied from base tray pickup proc
	// see code\game\objects\items\weapons\kitchen.dm line 241
	if ( istype(target,/obj/item))
		if ( !isturf(target.loc) ) // Don't load up stuff if it's inside a container or mob!
			return
		var/turf/pickup = target.loc

		var/addedSomething = 0

		for(var/obj/item/weapon/reagent_containers/food/I in pickup)


			if( I != src && !I.anchored && !istype(I, /obj/item/clothing/under) && !istype(I, /obj/item/clothing/suit) && !istype(I, /obj/item/projectile) )
				var/add = 0
				if(I.w_class == 1.0)
					add = 1
				else if(I.w_class == 2.0)
					add = 3
				else
					add = 5
				if(calc_carry() + add >= max_carry)
					break

				I.loc = src
				carrying.Add(I)
				add_overlay(image("icon" = I.icon, "icon_state" = I.icon_state, "layer" = 30 + I.layer))
				addedSomething = 1
		if ( addedSomething )
			user.visible_message("<span class='notice'>[user] load some items onto their service tray.</span>")

		return

	// Unloads the tray, copied from base item's proc dropped() and altered
	// see code\game\objects\items\weapons\kitchen.dm line 263

	if ( isturf(target) || istype(target,/obj/structure/table) )
		var/foundtable = istype(target,/obj/structure/table)
		if ( !foundtable ) //it must be a turf!
			for(var/obj/structure/table/T in target)
				foundtable = 1
				break

		var/turf/dropspot
		if ( !foundtable ) // don't unload things onto walls or other silly places.
			dropspot = user.loc
		else if ( isturf(target) ) // they clicked on a turf with a table in it
			dropspot = target
		else					// they clicked on a table
			dropspot = target.loc


		cut_overlays()

		var/droppedSomething = 0

		for(var/obj/item/I in carrying)
			I.loc = dropspot
			carrying.Remove(I)
			droppedSomething = 1
			if(!foundtable && isturf(dropspot))
				// if no table, presume that the person just shittily dropped the tray on the ground and made a mess everywhere!
				spawn()
					for(var/i = 1, i <= rand(1,2), i++)
						if(I)
							step(I, pick(NORTH,SOUTH,EAST,WEST))
							sleep(rand(2,4))
		if ( droppedSomething )
			if ( foundtable )
				user.visible_message("<span class='notice'>[user] unloads their service tray.</span>")
			else
				user.visible_message("<span class='notice'>[user] drops all the items on their tray.</span>")

	return ..()




// A special pen for service droids. Can be toggled to switch between normal writting mode, and paper rename mode
// Allows service droids to rename paper items.

/obj/item/weapon/pen/robopen
	desc = "A black ink printing attachment with a paper naming mode."
	name = "Printing Pen"
	var/mode = 1

/obj/item/weapon/pen/robopen/attack_self(mob/user)

	var/choice = input("Would you like to change colour or mode?") as null|anything in list("Colour","Mode")
	if(!choice) return

	playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, FALSE)

	switch(choice)
		if("Colour")
			var/newcolour = input("Which colour would you like to use?") as null|anything in list("black","blue","red","green","yellow")
			if(newcolour) colour = newcolour

		if("Mode")
			if (mode == 1)
				mode = 2
			else
				mode = 1
			to_chat(user, "Changed printing mode to '[mode == 2 ? "Rename Paper" : "Write Paper"]'")

	return

// Copied over from paper's rename verb
// see code\modules\paperwork\paper.dm line 62

/obj/item/weapon/pen/robopen/proc/RenamePaper(mob/user,obj/paper)
	if ( !user || !paper )
		return
	var/n_name = sanitize_safe(input(user, "What would you like to label the paper?", "Paper Labelling", null)  as text, MAX_NAME_LEN)
	if ( !user || !paper )
		return

	if(( get_dist(user,paper) <= 1  && user.stat == CONSCIOUS))
		paper.name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(user)
	return

//TODO: Add prewritten forms to dispense when you work out a good way to store the strings.
/obj/item/weapon/form_printer
	//name = "paperwork printer"
	name = "paper dispenser"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"

/obj/item/weapon/form_printer/attack(mob/living/carbon/M, mob/living/carbon/user)
	return

/obj/item/weapon/form_printer/afterattack(atom/target, mob/user, proximity, params)

	if(!target || !proximity)
		return

	if(istype(target,/obj/structure/table))
		deploy_paper(get_turf(target))

/obj/item/weapon/form_printer/attack_self(mob/user)
	deploy_paper(get_turf(src))

/obj/item/weapon/form_printer/proc/deploy_paper(turf/T)
	T.visible_message("<span class='notice'>\The [src.loc] dispenses a sheet of crisp white paper.</span>")
	new /obj/item/weapon/paper(T)

//Personal shielding for the combat module.
/obj/item/borg/combat/shield
	name = "personal shielding"
	desc = "A powerful experimental module that turns aside or absorbs incoming attacks at the cost of charge."
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"
	var/shield_level = 0.5 //Percentage of damage absorbed by the shield.

/obj/item/borg/combat/shield/verb/set_shield_level()
	set name = "Set shield level"
	set category = "Object"
	set src in range(0)

	var/N = input("How much damage should the shield absorb?") in list("5","10","25","50","75","100")
	if (N)
		shield_level = text2num(N)/100

/obj/item/borg/combat/mobility
	name = "mobility module"
	desc = "By retracting limbs and tucking in its head, a combat android can roll at high speeds."
	icon = 'icons/obj/decals.dmi'
	icon_state = "shock"

/obj/item/device/lustmodule
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	item_state = "locator"
	name = "Slime bloodlust pulse emitter"
	desc = "Highly dangeroues experimental device that makes nearby slimes completely loose it. Has 5 uses."
	var/uses = 5
	var/mobu

/obj/item/device/lustmodule/attack_self(mob/user)
	if(uses > 0)
		for(var/mob/living/carbon/slime/slime in viewers(get_turf_loc(user), null))
			slime.tame = 0
			slime.rabid = 1
			user.visible_message("<span class='warning'>The [slime] is driven into a frenzy!.</span>")
		uses -= 1
		to_chat(user, "Bloodlust emitter sends a pulse.")
	else
		to_chat(user, "You have spent device's capabilities.")//To limit number of uses.
		return 0
	return 1

/obj/item/weapon/pickaxe/cyb
	name = "cyborg pickaxe"
	icon = 'icons/obj/xenoarchaeology/tools.dmi'
	icon_state = "pick_hand"
	toolspeed = 0.6
	desc = "A smaller, more precise version of the pickaxe (30 centimetre excavation depth)."
	excavation_amount = 15
	usesound = 'sound/items/Crowbar.ogg'
	drill_verb = "clearing"
	w_class = ITEM_SIZE_NORMAL

/obj/item/weapon/pickaxe/cyb/attack_self(mob/user)
	var/ampr = input(user,"Excavation depth?","Set excavation depth","") as num
	excavation_amount = 0 + ampr/2
	desc = "A smaller, more precise version of the pickaxe ([ampr] centimetre excavation depth)."
