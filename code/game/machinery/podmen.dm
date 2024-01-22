/* Moved all the plant people code here for ease of reference and coherency.
Injecting a pod person with a blood sample will grow a pod person with the memories and persona of that mob.
Growing it to term with nothing injected will grab a ghost from the observers. */
// Dionaea cavas
/obj/item/seeds/replicapod
	name = "pack of dionaea-replicant seeds"
	desc = "These seeds grow into 'Podmen', try adding a bit of blood."
	icon_state = "seed-replicapod"
	species = "replicapod"
	plantname = "Podman pod"
	lifespan = 50 //no idea what those do
	endurance = 8
	maturation = 5
	production = 10
	yield = 1
	oneharvest = 1
	potency = 30
	plant_type = 0
	growthstages = 6
	gender = MALE

	product_type = /mob/living/carbon/monkey/diona/podman
	// Whether DNA is copied.
	var/copycat_replica = TRUE

	var/datum/mind/priveleged_player = null
	var/datum/dna/replicant_dna = null
	var/mob/living/carbon/human/blood_source = null
	var/list/replicant_languages
	var/list/replicant_quirks
	var/replicant_memory

	var/spawner_type = /datum/spawner/living/podman/podkid

/obj/item/seeds/replicapod/Destroy()
	QDEL_NULL(replicant_dna)
	if(blood_source)
		clear_blood_source(blood_source)
	if(priveleged_player)
		clear_priveleged_player(priveleged_player)
	return ..()

/obj/item/seeds/replicapod/proc/clear_blood_source(datum/source)
	UnregisterSignal(blood_source, list(COMSIG_PARENT_QDELETING))
	blood_source = null

/obj/item/seeds/replicapod/proc/clear_priveleged_player(datum/source)
	UnregisterSignal(priveleged_player, list(COMSIG_PARENT_QDELETING))
	priveleged_player = null

/obj/item/seeds/replicapod/proc/replicate_blood_data(list/data, mob/living/user)
	blood_source = locate(data["donor"])
	if(!istype(blood_source) || !blood_source.mind)
		blood_source = null
		if(user)
			to_chat(user, "<span class='warning'>But nothing happens.</span>")
		return FALSE

	if(user)
		to_chat(user, "<span class='notice'>The strange, sluglike seeds quiver gently and swell with blood.</span>")
	if(isobserver(blood_source.mind.current))
		to_chat(blood_source.mind.current, "<span class='bold danger'>Your blood has been placed into a replica pod seed. Re-enter your corpse to be reborn anew.</span>")

	priveleged_player = blood_source.mind
	replicant_dna = blood_source.dna.Clone()
	replicant_languages = blood_source.languages.Copy()

	replicant_quirks = list()
	var/list/datum/quirk/blood_quirks = blood_source.roundstart_quirks.Copy()
	for(var/datum/quirk/Q in blood_quirks)
		replicant_quirks += Q.type

	var/memory_time = 0
	if(blood_source.timeofdeath)
		memory_time = blood_source.timeofdeath

	if(data["time"])
		if(memory_time)
			memory_time = min(memory_time, data["time"])
		else
			memory_time = data["time"]

	replicant_memory = blood_source.mind.memory
	if(memory_time)
		replicant_memory += "Your memory fades somewhere around [worldtime2text(memory_time)].<BR>"

	RegisterSignal(priveleged_player, list(COMSIG_PARENT_QDELETING), PROC_REF(clear_priveleged_player))
	RegisterSignal(blood_source, list(COMSIG_PARENT_QDELETING), PROC_REF(clear_blood_source))
	return TRUE

/obj/item/seeds/replicapod/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/weapon/reagent_containers))
		return ..()

	if(replicant_dna)
		to_chat(user, "<span class='warning'>[src] is filled to the brim with blood.</span>")
		return

	var/obj/item/weapon/reagent_containers/RC = I

	to_chat(user, "<span class='notice'>You try adding the contents of [RC] into \the [src].</span>")

	var/datum/reagent/blood/B

	//Find a blood sample to inject.
	for(var/datum/reagent/R as anything in RC.reagents.reagent_list)
		if(istype(R, /datum/reagent/blood))
			B = R
			break

	if(!B)
		return

	if(!B.data)
		return

	if(!replicate_blood_data(B.data, user))
		return

	RC.reagents.clear_reagents()

/obj/item/seeds/replicapod/harvest(mob/user = usr)
	user.visible_message("<span class='notice'>[user] carefully begins to open the pod...</span>","<span class='notice'>You carefully begin to open the pod...</span>")

	var/obj/machinery/hydroponics/pod = loc

	var/mob/living/carbon/monkey/diona/D = new product_type(pod.loc)

	if(copycat_replica && replicant_dna)
		D.dna = replicant_dna.Clone()
		D.real_name = D.dna.real_name
		D.name = D.real_name

		for(var/language in replicant_languages)
			D.add_language(language)

		D.saved_quirks = replicant_quirks.Copy()

	if(copycat_replica && priveleged_player && priveleged_player.current == blood_source && blood_source.stat == DEAD)
		D.key = blood_source.key

		D.mind.memory = replicant_memory

		var/msg = "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span><BR>"
		msg += "<B>You are alive. Again. But you are not you. You are a mere Podmen, a husk of what you should have been. Neither of humans, nor of them. A hollow shell, filled with disease.</B><BR>"
		msg += "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>"
		to_chat(D, msg)
		return

	else
		create_spawner(spawner_type, D, replicant_memory)

	user.visible_message("<span class='notice'>The pod disgorges a fully-formed plant creature!</span>")
	qdel(src)
	pod.update_tray()

/obj/item/seeds/replicapod/real_deal
	name = "pack of dionaea seeds"
	desc = "These seeds grow into a Dionaea nymph, don't forget to harvest them, they grow fast..."
	icon_state = "seed-nymph"
	species = "nymph"
	plantname = "Dionaea pod"
	lifespan = 50
	endurance = 8
	maturation = 8
	production = 10
	yield = 1
	oneharvest = 1
	potency = 30
	plant_type = 0
	growthstages = 6
	gender = MALE

	mutatelist = list(/obj/item/seeds/replicapod)

	product_type = /mob/living/carbon/monkey/diona/podman/fake
	copycat_replica = FALSE

	spawner_type = /datum/spawner/living/podman/fake_nymph

	var/vine_timer

/obj/item/seeds/replicapod/real_deal/Destroy()
	deltimer(vine_timer)
	return ..()

/obj/item/seeds/replicapod/real_deal/proc/spawn_vine()
	var/obj/machinery/hydroponics/pod = loc
	if(!istype(pod))
		return

	if(locate(/obj/effect/spacevine_controller/diona) in pod.loc)
		return

	new /obj/effect/spacevine_controller/diona(pod.loc)

// Not harvesting them ASAP leads in to kudzumeme...
/obj/item/seeds/replicapod/real_deal/ripen()
	if(copycat_replica)
		return

	vine_timer = addtimer(CALLBACK(src, PROC_REF(spawn_vine)), 1 MINUTE, TIMER_STOPPABLE)

/obj/item/seeds/replicapod/real_deal/harvest()
	deltimer(vine_timer)
	return ..()

/obj/item/seeds/replicapod/real_deal/proc/align_gestalt(mob/living/carbon/user)
	var/datum/reagent/blood/B = user.take_blood(null, 0)
	if(!B)
		return

	if(!B.data)
		return

	if(!replicate_blood_data(B.data))
		to_chat(user, "<span class='warning'>But nothing happens.</span>")
		return

	to_chat(user, "<span class='notice'>You align the pod with the gestalt.</span>")

	product_type = /mob/living/carbon/monkey/diona
	copycat_replica = TRUE

	spawner_type = /datum/spawner/living/podman/nymph

/obj/item/seeds/replicapod/real_deal/attack_self(mob/living/carbon/user)
	if(user.get_species() == DIONA && iscarbon(user))
		align_gestalt(user)
		return

	return ..()
