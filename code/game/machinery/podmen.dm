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
	var/realName = null
	var/mob/living/carbon/human/source //Donor of blood, if any.
	gender = MALE
	var/obj/machinery/hydroponics/parent = null
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

		RC.reagents.clear_reagents()
		return

	return ..()

/obj/item/seeds/replicapod/harvest(mob/user = usr)
	if(attempt_harvest)
		return

	parent = loc
	user.visible_message("<span class='notice'>[user] carefully begins to open the pod...</span>","<span class='notice'>You carefully begin to open the pod...</span>")
	attempt_harvest = TRUE

	request_player()

	addtimer(CALLBACK(src, .proc/dead_plant), 150) //If we don't have a ghost or the ghost is now unplayed, we just give the harvester some seeds.

/obj/item/seeds/replicapod/proc/dead_plant()
	var/seed_count = 1

	if(prob(yield * parent.yieldmod * 20))
		seed_count++

	for(var/i in 0 to seed_count - 1)
		new /obj/item/seeds/replicapod(loc.loc)

	parent.update_tray()

/obj/item/seeds/replicapod/proc/request_player()
	var/mob/living/carbon/monkey/diona/podman = new(parent.loc)
	create_spawner(/datum/spawner/plant, "diona_pod", podman, realName)

	parent.visible_message("<span class='notice'>The pod disgorges a fully-formed plant creature!</span>")
	parent.update_tray()
