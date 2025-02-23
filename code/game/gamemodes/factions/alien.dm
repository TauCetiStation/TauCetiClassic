/datum/faction/alien
	name = F_XENOMORPH
	ID = F_XENOMORPH
	logo_state = "alien-logo"
	required_pref = ROLE_ALIEN

	initroletype = /datum/role/alien

	min_roles = 0
	max_roles = 1

/datum/faction/alien/can_setup(num_players)
	if(!..())
		return FALSE
	if(xeno_spawn.len >= 1)
		return TRUE
	return FALSE

/datum/faction/alien/OnPostSetup()
	var/datum/role/role = pick(members)
	var/start_point = pick(xeno_spawn)

	if(start_point && role)
		if(SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN))
			var/mob/living/carbon/human/H = new (get_turf(start_point))
			H.equip_to_slot_or_del(new /obj/item/clothing/under/nostromo/white, SLOT_W_UNIFORM)
			H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white, SLOT_SHOES)
			H.name = "Gilbert Kane"
			H.real_name = "Gilbert Kane"
			H.voice_name = "Gilbert Kane"

			var/mob/living/carbon/xenomorph/larva/lone/new_xeno = new(H)
			role.antag.transfer_to(new_xeno)
			QDEL_NULL(role.antag.original)
			var/obj/item/weapon/larva_bite/auto/G = new(new_xeno, H)
			new_xeno.put_in_active_hand(G)
			G.last_bite = world.time - 20
			G.synch()
		else
			var/mob/living/carbon/xenomorph/humanoid/hunter/lone/new_xeno = new(get_turf(start_point))
			role.antag.transfer_to(new_xeno)
			QDEL_NULL(role.antag.original)
	return ..()


/datum/faction/nostromo_crew
	name = F_NOSTROMO_CREW
	ID = F_NOSTROMO_CREW
	logo_state = "nostromo-logo"

	accept_latejoiners = TRUE
	latejoiners_postsetup = TRUE
	initroletype = /datum/role/nostromo_crewmate
	min_roles = 0
	max_roles = 7

	var/dead_crew = 0
	var/list/crew = list()
	var/alltime_crew = 0
	var/datum/map_module/alien/MM
	var/round_end = FALSE

/datum/faction/nostromo_crew/New()
	..()
	MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)
	MM.crew_faction = src

/datum/faction/nostromo_crew/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/nostromo/kill_alien)
	return TRUE

/datum/faction/nostromo_crew/check_win()
	return round_end

/datum/faction/nostromo_crew/proc/new_crewmate(mob/living/carbon/human/crewmate)
	RegisterSignal(crewmate, list(COMSIG_MOB_DIED, COMSIG_PARENT_QDELETING), PROC_REF(crewmate_died))
	crew += crewmate
	alltime_crew++
	MM.equip(crewmate)

/datum/faction/nostromo_crew/proc/equip(mob/crewmate)

/datum/faction/nostromo_crew/proc/crewmate_died(mob/crewmate)
	UnregisterSignal(crewmate, list(COMSIG_MOB_DIED, COMSIG_PARENT_QDELETING))
	dead_crew++
	MM.deadcrew_ratio = dead_crew / alltime_crew * 100
	if(MM.deadcrew_ratio == 20)
		MM.open_cargo()
	if(MM.deadcrew_ratio == 50)
		MM.open_evac()
	if(dead_crew == alltime_crew)
		round_end = TRUE


/datum/faction/nostromo_android
	name = NOSTROMO_ANDROID
	ID = NOSTROMO_ANDROID
	logo_state = "nano-logo"
	required_pref = ROLE_TRAITOR

	initroletype = /datum/role/nostromo_android
	min_roles = 0
	max_roles = 1

/datum/faction/nostromo_android/OnPostSetup()
	var/datum/role/role = pick(members)
	var/mob/living/carbon/human/H = role.antag.current
	H.set_species(NOSTROMO_ANDROID)
	H.nutrition_icon.update_icon(H)
	var/datum/map_module/alien/MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)
	if(MM)
		MM.equip(H)
	return ..()


/datum/faction/nostromo_cat
	name = NOSTROMO_CAT
	ID = NOSTROMO_CAT
	logo_state = "cat-logo"
	initroletype = /datum/role/nostromo_cat
	min_roles = 0
	var/Jonesy = /mob/living/simple_animal/cat/red/jonesy

/datum/faction/nostromo_cat/OnPostSetup()
	var/datum/map_module/alien/MM = SSmapping.get_map_module_by_name(MAP_MODULE_ALIEN)
	if(MM)
		var/start_point = pick(landmarks_list["Jonesy"])
		MM.jonesy = new Jonesy(get_turf(start_point))
	return ..()
