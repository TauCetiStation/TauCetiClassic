// Amount of time between retries for recruits. As to not spam ghosts every minute.
#define BORER_EGG_RERECRUITE_DELAY 2400

/obj/item/weapon/reagent_containers/food/snacks/borer_egg
	name = "borer egg"
	desc = "A small, gelatinous egg"
	icon = 'icons/mob/mob.dmi'
	icon_state = "borer egg-growing"
	bitesize = 12
	var/grown = FALSE
	var/hatching = FALSE // So we don't spam ghosts.
	var/hatched = FALSE
	var/child_prefix_index = 1
	var/last_ping_time = 0
	var/ping_cooldown = 50
	var/list/borer_candidates = list()
	var/list/borer_ignore = list()


/obj/item/weapon/reagent_containers/food/snacks/borer_egg/atom_init()
	..()
	last_ping_time = world.time
	reagents.add_reagent("protein", 4)
	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/atom_init_late()
	spawn(rand(1200,1500))//the egg takes a while to "ripen"
		Grow()

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/Grow()
	grown = TRUE
	icon_state = "borer egg-grown"
	START_PROCESSING(SSobj, src)

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/Hatch()
	if(hatching)
		return
	STOP_PROCESSING(SSobj, src)
	icon_state = "borer egg-triggered"
	hatching = TRUE
	src.visible_message("<span class='notice'>The [name] pulsates and quivers, looks like it will hatch soon!</span>")
	request_player()
	sleep(300)
	if(borer_candidates != null && borer_candidates.len)
		var/client/C = pick(borer_candidates)
		var/turf/T = get_turf(src)
		src.visible_message("<span class='notice'>\The [name] bursts open!</span>")
		var/mob/living/simple_animal/borer/B = new /mob/living/simple_animal/borer(T, child_prefix_index)
		B.transfer_personality(C)
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
		borer_candidates.Remove(C)
		hatching = FALSE
		hatched = TRUE
		icon_state = "borer egg-hatched"
		desc += " looks like it already hatched"
	else
		borer_candidates = list()
		src.visible_message("<span class='notice'>\The [name] calms down.</span>")
		hatching = FALSE
		spawn (BORER_EGG_RERECRUITE_DELAY)
			Grow() // Reset egg, check for hatchability.

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/process()
	var/turf/location = get_turf(src)
	if(!location)
		return
	var/datum/gas_mixture/environment = location.return_air()
	var/meets_conditions = TRUE
	var/pressure = environment.return_pressure()
	if(pressure < WARNING_LOW_PRESSURE)
		meets_conditions = FALSE
	if(meets_conditions)
		src.Hatch()

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/attack_ghost(mob/dead/observer/O)
	if(last_ping_time + ping_cooldown <= world.time)
		visible_message(message = "<span class='notice'>\The [src] wriggles vigorously.</span>")
		last_ping_time = world.time
	else
		to_chat(O, "The egg is recovering. Try again in a few moments.")

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/Destroy()
	..()

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(jobban_isbanned(O, "Syndicate") || jobban_isbanned(O, ROLE_BORER))
			continue
		if(role_available_in_minutes(O, ROLE_BORER))
			continue
		if(O.client)
			var/client/C = O.client
			if(!C.prefs.ignore_question.Find("borer") && (ROLE_BORER in C.prefs.be_role) && !borer_ignore.Find(C))
				question(C)

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/question(client/C)
	//spawn(0)
	if(!C)
		return
	var/response = alert(C, "A cortical borer is hatching. Do you wish to play as one?", "Cortical borer request", "Ignore this egg", "Yes", "Never for this round")
	if(response == "Yes")
		borer_candidates.Add(C)
	else if (response == "Never for this round")
		C.prefs.ignore_question += "borer"
	else if (response == "Ignore this egg")
		borer_ignore.Add(C)

#undef BORER_EGG_RERECRUITE_DELAY
