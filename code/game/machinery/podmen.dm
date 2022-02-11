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

	var/spawner_type = /datum/spawner/podman
	var/spawner_id = "podman_pod"

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

	blood_source = B.data["donor"]
	if(!istype(blood_source) || !blood_source.mind || !blood_source.mind.current.client)
		blood_source = null
		to_chat(user, "<span class='warning'>But nothing happens.</span>")
		return

	to_chat(user, "<span class='notice'>The strange, sluglike seeds quiver gently and swell with blood.</span>")
	if(istype(blood_source.mind.current, /mob/dead/observer))
		to_chat(blood_source.mind.current, "<span class='bold danger'>Your blood has been placed into a replica pod seed. Re-enter your corpse to be reborn anew.</span>")

	priveleged_player = blood_source.mind
	replicant_dna = blood_source.dna.Clone()
	replicant_languages = blood_source.languages.Copy()

	RegisterSignal(priveleged_player, list(COMSIG_PARENT_QDELETING), .proc/clear_priveleged_player)
	RegisterSignal(blood_source, list(COMSIG_PARENT_QDELETING), .proc/clear_blood_source)

	RC.reagents.clear_reagents()

/obj/item/seeds/replicapod/harvest(mob/user = usr)
	user.visible_message("<span class='notice'>[user] carefully begins to open the pod...</span>","<span class='notice'>You carefully begin to open the pod...</span>")

	var/obj/machinery/hydroponics/pod = loc

	var/mob/living/carbon/monkey/diona/D = new product_type(pod.loc)

	for(var/language in replicant_languages)
		D.add_language(language)

	if(copycat_replica && replicant_dna)
		D.dna = replicant_dna.Clone()
		D.dna.mutantrace = "plant"
		D.real_name = D.dna.real_name
		D.name = D.real_name

	if(copycat_replica && priveleged_player && priveleged_player.current == blood_source && blood_source.stat == DEAD)
		D.key = blood_source.key

		to_chat(D, "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span>")
		to_chat(D, "<B>You are alive. Again. But you are not you. You are a mere Podmen, a husk of what you should have been. Neither of humans, nor of them. A hollow shell, filled with disease.</B>")
		to_chat(D, "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>")
		return

	else
		create_spawner(spawner_type, spawner_id, D)

	user.visible_message("<span class='notice'>The pod disgorges a fully-formed plant creature!</span>")
	qdel(src)
	pod.update_tray()

/obj/item/seeds/replicapod/real_deal
	name = "pack of dionaea seeds"
	desc = "These seeds grow into a Dionaea nymph, don't forget to harvest them, they grow fast..."
	icon_state = "seed-replicapod"
	species = "dionapod"
	plantname = "Dionaea pod"
	lifespan = 50 //no idea what those do
	endurance = 8
	maturation = 10
	production = 10
	yield = 1
	oneharvest = 1
	potency = 30
	plant_type = 0
	growthstages = 6
	gender = MALE

	product_type = /mob/living/carbon/monkey/diona/podman/fake
	copycat_replica = FALSE

	spawner_type = /datum/spawner/fake_diona
	spawner_id = "diona_pod"
