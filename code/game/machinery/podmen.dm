/* Moved all the plant people code here for ease of reference and coherency.
Injecting a pod person with a blood sample will grow a pod person with the memories and persona of that mob.
Growing it to term with nothing injected will grab a ghost from the observers. */

/obj/item/seeds/replicapod
	name = "pack of dionaea-replicant seeds"
	desc = "These seeds grow into 'replica pods' or 'dionaea', a form of strange sapient plantlife."
	icon_state = "seed-replicapod"
	mypath = "/obj/item/seeds/replicapod"
	species = "replicapod"
	plantname = "Dionaea"
	productname = "/mob/living/carbon/human" //verrry special -- Urist
	lifespan = 50 //no idea what those do
	endurance = 8
	maturation = 5
	production = 10
	yield = 1 //seeds if there isn't a dna inside
	oneharvest = 1
	potency = 30
	plant_type = 0
	growthstages = 6
	var/ckey = null
	var/realName = null
	var/mob/living/carbon/human/source //Donor of blood, if any.
	gender = MALE
	var/obj/machinery/hydroponics/parent = null
	var/found_player = 0

/obj/item/seeds/replicapod/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers))
		to_chat(user, "You inject the contents of the syringe into the seeds.")

		var/datum/reagent/blood/B

		//Find a blood sample to inject.
		var/obj/item/weapon/reagent_containers/RC = I
		for(var/datum/reagent/R in RC.reagents.reagent_list)
			if(istype(R,/datum/reagent/blood))
				B = R
				break
		if(B)
			source = B.data["donor"]
			to_chat(user, "The strange, sluglike seeds quiver gently and swell with blood.")
			if(!source.client && source.mind)
				for(var/mob/dead/observer/O in player_list)
					if(O.mind == source.mind && config.revival_pod_plants)
						to_chat(O, "<font color='#330033'><font size = 3><b>Your blood has been placed into a replica pod seed. Return to your body if you want to be returned to life as a pod person!</b> (Verbs -> Ghost -> Re-enter corpse)</font></font>")
						break
		else
			to_chat(user, "Nothing happens.")
			return

		if (!istype(source))
			return

		if(source.ckey)
			realName = source.real_name
			ckey = source.ckey

		RC.reagents.clear_reagents()
		return

	return ..()

/obj/item/seeds/replicapod/harvest(mob/user = usr)
	parent = loc
	var/found_player = 0

	user.visible_message("<span class='notice'>[user] carefully begins to open the pod...</span>","<span class='notice'>You carefully begin to open the pod...</span>")

	//If a sample is injected (and revival is allowed) the plant will be controlled by the original donor.
	if(source && source.stat == DEAD && source.client && source.ckey && config.revival_pod_plants)
		transfer_personality(source.client)
	else // If no sample was injected or revival is not allowed, we grab an interested observer.
		request_player()

	spawn(75) //If we don't have a ghost or the ghost is now unplayed, we just give the harvester some seeds.
		if(!found_player)
			parent.visible_message("The pod has formed badly, and all you can do is salvage some of the seeds.")
			var/seed_count = 1

			if(prob(yield * parent.yieldmod * 20))
				seed_count++

			for(var/i=0,i<seed_count,i++)
				new /obj/item/seeds/replicapod(user.loc)

			parent.update_tray()
			return

/obj/item/seeds/replicapod/proc/request_player()
	for(var/mob/dead/observer/O in observer_list)
		if(O.has_enabled_antagHUD && config.antag_hud_restricted)
			continue
		if(jobban_isbanned(O, ROLE_PLANT) || is_alien_whitelisted_banned(O, DIONA))
			continue
		if(!is_alien_whitelisted(O, DIONA) && !role_available_in_minutes(O, ROLE_PLANT))
			continue
		if(O.client)
			var/client/C = O.client
			if((!C.prefs.ignore_question.Find(IGNORE_PLANT)) && (ROLE_GHOSTLY in C.prefs.be_role))
				INVOKE_ASYNC(src, .proc/question, C)

/obj/item/seeds/replicapod/proc/question(client/C)
	if(!C)
		return
	var/response = alert(C, "Someone is harvesting a diona pod. Would you like to play as a diona?", "Dionaea harvest", "No", "Yes", "Never for this round")
	if(!C || ckey || found_player)
		return
	if(response == "Yes")
		transfer_personality(C)
	else if (response == "Never for this round")
		C.prefs.ignore_question += IGNORE_PLANT

/obj/item/seeds/replicapod/proc/transfer_personality(client/player)

	if(!player)
		return

	found_player = TRUE

	var/mob/living/carbon/monkey/diona/podman = new(parent.loc)
	podman.ckey = player.ckey

	if(player.mob && player.mob.mind)
		player.mob.mind.transfer_to(podman)

	if(realName)
		podman.real_name = realName
	podman.dna.real_name = podman.real_name

	// Update mode specific HUD icons.
	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if(mode)
		mode.update_icon(podman.mind)

	switch(SSticker.mode.name)
		if ("revolution")
			if (podman.mind in SSticker.mode:revolutionaries)
				SSticker.mode:add_revolutionary(podman.mind)
				SSticker.mode:update_all_rev_icons() //So the icon actually appears
			if (podman.mind in SSticker.mode:head_revolutionaries)
				SSticker.mode:update_all_rev_icons()
		if ("nuclear emergency")
			if (podman.mind in SSticker.mode:syndicates)
				SSticker.mode:update_all_synd_icons()
		if ("cult")
			if (podman.mind in SSticker.mode:cult)
				SSticker.mode:add_cultist(podman.mind)
				SSticker.mode:update_all_cult_icons() //So the icon actually appears
		// -- End mode specific stuff

	to_chat(podman, "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span>")
	if(source && ckey && podman.ckey == ckey)
		to_chat(podman, "<B>Memories of a life as [source] drift oddly through a mind unsuited for them, like a skin of oil over a fathomless lake.</B>")
	to_chat(podman, "<B>You are now one of the Dionaea, a race of drifting interstellar plantlike creatures that sometimes share their seeds with human traders.</B>")
	to_chat(podman, "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>")
	if(!realName)
		var/newname = sanitize_safe(input(podman,"Enter a name, or leave blank for the default name.", "Name change","") as text, MAX_NAME_LEN)
		if (newname != "")
			podman.real_name = newname

	parent.visible_message("<span class='notice'>The pod disgorges a fully-formed plant creature!</span>")
	parent.update_tray()
