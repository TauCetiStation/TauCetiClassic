/* Moved all the plant people code here for ease of reference and coherency.
Injecting a pod person with a blood sample will grow a pod person with the memories and persona of that mob.
Growing it to term with nothing injected will grab a ghost from the observers. */

/obj/item/seeds/replicapod
	name = "pack of dionaea-replicant seeds"
	desc = "These seeds grow into 'replica pods' or 'dionaea', a form of strange sapient plantlife."
	icon_state = "seed-replicapod"
	species = "replicapod"
	plantname = "Dionaea"
	product_type = /mob/living/carbon/human //verrry special -- Urist
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
	var/found_player = FALSE
	var/attempt_harvest = FALSE

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
			if(source && !source.client && source.mind)
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
	if(attempt_harvest)
		return

	parent = loc
	user.visible_message("<span class='notice'>[user] carefully begins to open the pod...</span>","<span class='notice'>You carefully begin to open the pod...</span>")
	attempt_harvest = TRUE

	//If a sample is injected (and revival is allowed) the plant will be controlled by the original donor.
	if(source && source.stat == DEAD && source.client && source.ckey && config.revival_pod_plants)
		transfer_personality(source.client)
	else // If no sample was injected or revival is not allowed, we grab an interested observer.
		request_player()

	addtimer(CALLBACK(src, .proc/dead_plant), 150) //If we don't have a ghost or the ghost is now unplayed, we just give the harvester some seeds.

/obj/item/seeds/replicapod/proc/dead_plant()
	if(!found_player)
		parent.visible_message("The pod has formed badly, and all you can do is salvage some of the seeds.")
		var/seed_count = 1

		if(prob(yield * parent.yieldmod * 20))
			seed_count++

		for(var/i in 0 to seed_count - 1)
			new /obj/item/seeds/replicapod(loc.loc)

		parent.update_tray()

/obj/item/seeds/replicapod/proc/request_player()
	var/list/candidates = pollGhostCandidates("Someone is harvesting a diona pod. Would you like to play as a diona?", ROLE_GHOSTLY, IGNORE_PLANT, 100, TRUE)
	for(var/mob/M in candidates) // No random
		if(is_alien_whitelisted_banned(M, DIONA) || !is_alien_whitelisted(M, DIONA))
			continue
		transfer_personality(M.client)
		break

/obj/item/seeds/replicapod/proc/transfer_personality(client/candidate)
	if(!candidate)
		return

	found_player = TRUE

	var/mob/living/carbon/monkey/diona/podman = new(parent.loc)
	podman.key = candidate.key

	if(realName)
		podman.real_name = realName
	podman.dna.real_name = podman.real_name

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
