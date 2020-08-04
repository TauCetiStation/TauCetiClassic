/mob/living/carbon/proc/monkeyize(tr_flags = (TR_KEEPITEMS | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_DEFAULTMSG))
	if (notransform)
		return

	// friendly reminder after updating those procs:
	// carbons still missing bodyparts, so its not possible atm to save
	// implants and cavity items location properly or transfer bodyparts without some snowflake code
	// and most likely borer support
	// also, virus2 still not added here and actually probably should be merged into disease system.

	//Handle possessive brain borers.
	// host is typecasted as human, so i assume there is no point in transfering borrers
	// but it will be wrong to delete them, right?
	// still, probably a good idea to implement or check carbon support for them.
	for(var/mob/living/simple_animal/borer/B in src)
		if(B.controlling)
			release_control()
		B.detatch()

	//Handle items on mob

	//first implants
	var/list/stored_implants = list()

	if (tr_flags & TR_KEEPIMPLANTS)
		for(var/obj/item/weapon/implant/IMP in src)
			stored_implants += IMP
			IMP.loc = null
			IMP.imp_in = null
			IMP.implanted = FALSE
			if(IMP.part)
				IMP.part.implants -= src
				IMP.part = null
		hud_updateflag |= 1 << IMPLOYAL_HUD

	if(tr_flags & TR_KEEPITEMS)
		var/Itemlist = get_equipped_items()
		for(var/obj/item/W in Itemlist)
			if(W.flags & NODROP || !W.canremove)
				continue
			drop_from_inventory(W)

	//Make mob invisible and spawn animation
	notransform = TRUE
	Paralyse(22)
	icon = null
	invisibility = INVISIBILITY_MAXIMUM

	var/atom/movable/overlay/animation = new /atom/movable/overlay( loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(22)
	qdel(animation)

	var/mob/living/carbon/monkey/O

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(!H.species.primitive) //If the creature in question has no primitive set, this is going to be messy.
			gib()
			return
		O = new H.species.primitive(loc)
	else
		O = new(loc)

	if(istype(loc, /obj/machinery/dna_scannernew))
		var/obj/machinery/dna_scannernew/C = loc
		C.occupant = O

	//handle DNA and other attributes
	if(dna)
		if(tr_flags & TR_KEEPSE)
			O.dna = dna.Clone()
		else
			O.dna = dna.Clone(transfer_SE = FALSE)
		O.dna.SetSEState(MONKEYBLOCK,1)
		O.dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)

	if(suiciding)
		O.suiciding = suiciding
		suiciding = null
	O.a_intent = INTENT_HARM

	//keep viruses?
	if(tr_flags & TR_KEEPVIRUS)
		O.viruses = viruses
		viruses = list()
		for(var/datum/disease/D in O.viruses)
			D.affected_mob = O

	//keep damage?
	if (tr_flags & TR_KEEPDAMAGE)
		O.adjustToxLoss(getToxLoss())
		O.adjustBruteLoss(getBruteLoss())
		O.adjustOxyLoss(getOxyLoss())
		O.adjustCloneLoss(getCloneLoss())
		O.adjustFireLoss(getFireLoss())
		O.adjustBrainLoss(getBrainLoss())
		O.adjustHalLoss()
		O.updatehealth()
		O.radiation = radiation

	//re-add implants to new mob
	if (tr_flags & TR_KEEPIMPLANTS)
		for(var/Y in stored_implants)
			var/obj/item/weapon/implant/IMP = Y
			IMP.loc = O
			IMP.imp_in = O
			IMP.implanted = TRUE

	//transfer stuns
	if(tr_flags & TR_KEEPSTUNS)
		O.Stun(stunned, ignore_canstun = TRUE)
		O.Weaken(weakened)
		O.Paralyse(paralysis - 22)
		O.SetSleeping(AmountSleeping())

	//transfer reagents
	if(tr_flags & TR_KEEPREAGENTS)
		reagents.trans_to(O, reagents.total_volume)

	//transfer mind if we didn't yet
	if(mind)
		mind.transfer_to(O)

		if(O.mind.changeling)
			O.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
			O.changeling_update_languages(O.mind.changeling.absorbed_languages)
			for(var/mob/living/parasite/essence/M in src)
				M.transfer(O)

	transfer_trait_datums(O)

	if(tr_flags & TR_DEFAULTMSG)
		to_chat(O, "<B>You are now a monkey.</B>")

	. = O

	qdel(src)

//////////////////////////           Humanize               //////////////////////////////
//Could probably be merged with monkeyize but other transformations got their own procs, too

/mob/living/carbon/proc/humanize(tr_flags = (TR_KEEPITEMS | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_DEFAULTMSG))
	if (notransform)
		return

	for(var/mob/living/simple_animal/borer/B in src)
		if(B.controlling)
			release_control()
		B.detatch()

	//Handle items on mob

	//first implants
	var/list/stored_implants = list()

	if (tr_flags & TR_KEEPIMPLANTS)
		for(var/obj/item/weapon/implant/IMP in src)
			stored_implants += IMP
			IMP.loc = null
			IMP.imp_in = null
			IMP.implanted = FALSE
			if(IMP.part)
				IMP.part.implants -= src
				IMP.part = null
		hud_updateflag |= 1 << IMPLOYAL_HUD

	if(tr_flags & TR_KEEPITEMS)
		for(var/obj/item/W in get_equipped_items())
			if(W.flags & NODROP || !W.canremove)
				continue
			drop_from_inventory(W)

	//Make mob invisible and spawn animation
	notransform = TRUE
	Paralyse(22)
	icon = null
	invisibility = INVISIBILITY_MAXIMUM

	var/atom/movable/overlay/animation = new /atom/movable/overlay( loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("monkey2h", animation)
	sleep(22)
	qdel(animation)

	var/mob/living/carbon/human/O
	if(ismonkey(src))
		var/mob/living/carbon/monkey/Mo = src
		if(Mo.greaterform)
			O = new(loc, Mo.greaterform)

	if(!O)
		O = new(loc)

	if(istype(loc, /obj/machinery/dna_scannernew))
		var/obj/machinery/dna_scannernew/C = loc
		C.occupant = O

	//handle DNA and other attributes
	if(tr_flags & TR_KEEPSE)
		O.dna = dna.Clone()
	else
		O.dna = dna.Clone(transfer_SE = FALSE)

	if(ismonkey(src) && cmptext(initial(name), copytext(O.dna.real_name, 1, length_char(initial(name)) + 1))) // simple "monkey" name check is not enough with species.
		O.real_name = random_unique_name(O.gender)
		O.dna.generate_unique_enzymes(O)
	else
		O.real_name = O.dna.real_name
	O.name = O.real_name

	if(suiciding)
		O.suiciding = suiciding
		suiciding = null
	O.a_intent = INTENT_HELP

	//keep viruses?
	if(tr_flags & TR_KEEPVIRUS)
		O.viruses = viruses
		viruses = list()
		for(var/datum/disease/D in O.viruses)
			D.affected_mob = O

	//keep damage?
	if (tr_flags & TR_KEEPDAMAGE)
		O.adjustToxLoss(getToxLoss())
		O.adjustBruteLoss(getBruteLoss())
		O.adjustOxyLoss(getOxyLoss())
		O.adjustCloneLoss(getCloneLoss())
		O.adjustFireLoss(getFireLoss())
		O.adjustBrainLoss(getBrainLoss())
		O.adjustHalLoss()
		O.updatehealth()
		O.radiation = radiation

	//re-add implants to new mob
	if (tr_flags & TR_KEEPIMPLANTS)
		for(var/Y in stored_implants)
			var/obj/item/weapon/implant/IMP = Y
			IMP.loc = O
			IMP.imp_in = O
			IMP.implanted = TRUE
			var/obj/item/organ/external/BP = pick(O.bodyparts)
			if(BP)
				IMP.part = BP
				BP.implants += IMP

	//transfer stuns
	if(tr_flags & TR_KEEPSTUNS)
		O.Stun(stunned, ignore_canstun = TRUE)
		O.Weaken(weakened)
		O.Paralyse(paralysis - 22)
		O.SetSleeping(AmountSleeping())

	//transfer reagents
	if(tr_flags & TR_KEEPREAGENTS)
		reagents.trans_to(O, reagents.total_volume)

	//transfer mind if we didn't yet
	if(mind)
		mind.transfer_to(O)

		if(O.mind.changeling)
			O.changeling_update_languages(O.mind.changeling.absorbed_languages)
			for(var/mob/living/parasite/essence/M in src)
				M.transfer(O)

	transfer_trait_datums(O)

	if(tr_flags & TR_DEFAULTMSG)
		to_chat(O, "<B>You are now a human.</B>")

	. = O

	qdel(src)

/mob/dead/new_player/AIize()
	spawning = 1
	return ..()

/mob/living/carbon/human/AIize(move=1) // 'move' argument needs defining here too because BYOND is dumb
	if (notransform)
		return
	for(var/t in bodyparts)
		qdel(t)

	return ..(move)

/mob/living/carbon/AIize()
	if (notransform)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101
	return ..()

/mob/proc/AIize(move=1)
	if(client)
		playsound_stop(CHANNEL_MUSIC) // stop the jams for AIs

	var/newloc = loc
	if(move)
		var/obj/loc_landmark
		for(var/obj/effect/landmark/start/sloc in landmarks_list)
			if (sloc.name != "AI")
				continue
			if ((locate(/mob/living) in sloc.loc) || (locate(/obj/structure/AIcore) in sloc.loc))
				continue
			loc_landmark = sloc
		if (!loc_landmark)
			for(var/obj/effect/landmark/tripai in landmarks_list)
				if (tripai.name == "tripai")
					if((locate(/mob/living) in tripai.loc) || (locate(/obj/structure/AIcore) in tripai.loc))
						continue
					loc_landmark = tripai
		if (!loc_landmark)
			to_chat(src, "Oh god sorry we can't find an unoccupied AI spawn location, so we're spawning you on top of someone.")
			for(var/obj/effect/landmark/start/sloc in landmarks_list)
				if (sloc.name == "AI")
					loc_landmark = sloc

		newloc = loc_landmark.loc

	var/mob/living/silicon/ai/O = new (newloc, base_law_type,,1)//No MMI but safety is in effect.

	if(move)
		for(var/obj/item/device/radio/intercom/comm in O.loc)
			comm.ai += O

	O.invisibility = 0
	O.aiRestorePowerRoutine = 0

	if(mind)
		mind.transfer_to(O)
		O.mind.original = O
	else
		O.key = key

	O.announce_role()

	O.add_ai_verbs()
	O.job = "AI"

	O.rename_self("ai",1)
	spawn(0)
		qdel(src)
	return O

//human -> robot
/mob/living/carbon/human/proc/Robotize(name = "Default", laws = /datum/ai_laws/nanotrasen, ai_link = TRUE)
	if (notransform)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in bodyparts)
		qdel(t)

	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(loc, name, laws, ai_link)

	// cyborgs produced by Robotize get an automatic power cell
	O.cell = new(O)
	O.cell.maxcharge = 7500
	O.cell.charge = 7500


	O.gender = gender
	O.invisibility = 0

	if(mind)		//TODO
		mind.transfer_to(O)
		if(O.mind.assigned_role == "Cyborg")
			O.mind.original = O
		else if(mind && mind.special_role)
			O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")
	else
		O.key = key

	O.loc = loc
	O.job = "Cyborg"
	if(O.mind.assigned_role == "Cyborg")
		if(O.mind.role_alt_title == "Android")
			O.mmi = new /obj/item/device/mmi/posibrain(O)
		else if(O.mind.role_alt_title == "Robot")
			O.mmi = null //Robots do not have removable brains.
		else
			O.mmi = new /obj/item/device/mmi(O)

		if(O.mmi) O.mmi.transfer_identity(src) //Does not transfer key/client.

	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if(mode)
		mode.borgify_directive(O)

	O.Namepick()

	. = O
	qdel(src)

//human -> alien
/mob/living/carbon/human/proc/Alienize()
	if (notransform)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in bodyparts)
		qdel(t)

	var/alien_caste = pick("Hunter","Sentinel","Drone")
	var/mob/living/carbon/xenomorph/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/xenomorph/humanoid/hunter(loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/xenomorph/humanoid/sentinel(loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/xenomorph/humanoid/drone(loc)

	new_xeno.a_intent = INTENT_HARM
	new_xeno.key = key

	to_chat(new_xeno, "<B>You are now an alien.</B>")
	spawn(0)//To prevent the proc from returning null.
		qdel(src)
	return

/mob/living/carbon/human/proc/slimeize(adult, reproduce)
	if (notransform)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in bodyparts)
		qdel(t)

	var/mob/living/carbon/slime/new_slime
	if(reproduce)
		var/number = pick(14;2,3,4)	//reproduce (has a small chance of producing 3 or 4 offspring)
		var/list/babies = list()
		for(var/i=1,i<=number,i++)
			var/mob/living/carbon/slime/M = new/mob/living/carbon/slime(loc)
			M.nutrition = round(nutrition/number)
			step_away(M,src)
			babies += M
		new_slime = pick(babies)
	else
		if(adult)
			new_slime = new /mob/living/carbon/slime/adult(loc)
		else
			new_slime = new /mob/living/carbon/slime(loc)
	new_slime.a_intent = INTENT_HARM
	new_slime.key = key

	to_chat(new_slime, "<B>You are now a slime. Skreee!</B>")
	spawn(0)//To prevent the proc from returning null.
		qdel(src)
	return

/mob/living/carbon/human/proc/corgize()
	if (notransform)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)
	regenerate_icons()
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101
	for(var/t in bodyparts)	//this really should not be necessary
		qdel(t)

	var/mob/living/simple_animal/corgi/new_corgi = new /mob/living/simple_animal/corgi (loc)
	new_corgi.a_intent = INTENT_HARM
	new_corgi.key = key

	to_chat(new_corgi, "<B>You are now a Corgi. Yap Yap!</B>")
	spawn(0)//To prevent the proc from returning null.
		qdel(src)
	return

/mob/living/carbon/human/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='warning'>Sorry but this mob type is currently unavailable.</span>")
		return

	if(notransform)
		return
	for(var/obj/item/W in src)
		drop_from_inventory(W)

	regenerate_icons()
	notransform = TRUE
	canmove = 0
	icon = null
	invisibility = 101

	for(var/t in bodyparts)
		qdel(t)

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM


	to_chat(new_mob, "You suddenly feel more... animalistic.")
	spawn()
		qdel(src)
	return

/mob/proc/Animalize()

	var/list/mobtypes = typesof(/mob/living/simple_animal)
	var/mobpath = input("Which type of mob should [src] turn into?", "Choose a type") in mobtypes

	if(!safe_animal(mobpath))
		to_chat(usr, "<span class='warning'>Sorry but this mob type is currently unavailable.</span>")
		return

	var/mob/new_mob = new mobpath(src.loc)

	new_mob.key = key
	new_mob.a_intent = INTENT_HARM
	to_chat(new_mob, "You feel more... animalistic")

	qdel(src)

/* Certain mob types have problems and should not be allowed to be controlled by players.
 *
 * This proc is here to force coders to manually place their mob in this list, hopefully tested.
 * This also gives a place to explain -why- players shouldnt be turn into certain mobs and hopefully someone can fix them.
 */
/mob/proc/safe_animal(MP)

//Bad mobs! - Remember to add a comment explaining what's wrong with the mob
	if(!MP)
		return 0	//Sanity, this should never happen.

	if(ispath(MP, /mob/living/simple_animal/space_worm))
		return 0 //Unfinished. Very buggy, they seem to just spawn additional space worms everywhere and eating your own tail results in new worms spawning.

	if(ispath(MP, /mob/living/simple_animal/construct/behemoth))
		return 0 //I think this may have been an unfinished WiP or something. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/armoured))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/wraith))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

	if(ispath(MP, /mob/living/simple_animal/construct/builder))
		return 0 //Verbs do not appear for players. These constructs should really have their own class simple_animal/construct/subtype

//Good mobs!
	if(ispath(MP, /mob/living/simple_animal/cat))
		return 1
	if(ispath(MP, /mob/living/simple_animal/corgi))
		return 1
	if(ispath(MP, /mob/living/simple_animal/crab))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/carp))
		return 1
	if(ispath(MP, /mob/living/simple_animal/mushroom))
		return 1
	if(ispath(MP, /mob/living/simple_animal/shade))
		return 1
	if(ispath(MP, /mob/living/simple_animal/hostile/tomato)) //no good anymore
		return 1
	if(ispath(MP, /mob/living/simple_animal/mouse))
		return 1 //It is impossible to pull up the player panel for mice (Fixed! - Nodrak)
	if(ispath(MP, /mob/living/simple_animal/hostile/bear))
		return 1 //Bears will auto-attack mobs, even if they're player controlled (Fixed! - Nodrak)
	if(ispath(MP, /mob/living/simple_animal/parrot))
		return 1 //Parrots are no longer unfinished! -Nodrak

	//Not in here? Must be untested!
	return 1


