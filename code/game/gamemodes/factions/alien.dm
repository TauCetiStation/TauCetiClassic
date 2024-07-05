var/global/mob/Jonesy

// alien fraction
/datum/faction/alien
	name = F_XENOMORPH
	ID = F_XENOMORPH
	logo_state = "alien-logo"
	required_pref = ROLE_ALIEN

	initroletype = /datum/role/alien

	min_roles = 0
	max_roles = 1

	var/last_check = 0

/datum/faction/alien/can_setup(num_players)
	if(!..())
		return FALSE
	if(xeno_spawn.len > 0)
		return TRUE
	return FALSE

/datum/faction/alien/check_win()
	return check_crew() == 0

/datum/faction/alien/OnPostSetup()
	var/datum/role/role = pick(members)
	var/start_point = xeno_spawn[1]

	var/mob/living/carbon/human/H = new (get_turf(start_point))
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/white, SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white, SLOT_SHOES)
	H.name = "Gilbert Kane"
	H.real_name = "Gilbert Kane"
	H.voice_name = "Gilbert Kane"
	H.h_style = "Combover"

	var/obj/item/alien_embryo/new_embryo = new /obj/item/alien_embryo(H)
	var/mob/living/carbon/xenomorph/larva/new_xeno = new /mob/living/carbon/xenomorph/larva/lone(new_embryo)
	new_xeno.loc = new_embryo
	new_embryo.baby = new_xeno
	new_embryo.controlled_by_ai = FALSE
	new_embryo.stage = 5
	role.antag.transfer_to(new_xeno)
	QDEL_NULL(role.antag.original)

	return ..()

/datum/faction/alien/check_crew()
	var/total_human = 0
	for(var/mob/living/carbon/human/H as anything in human_list)
		var/turf/human_loc = get_turf(H)
		if(!human_loc || !is_station_level(human_loc.z))
			continue
		if(H.stat == DEAD)
			continue
		if(H.species.flags[IS_SYNTHETIC] || H.species.flags[IS_PLANT])
			continue
		total_human++
	return total_human


#define F_NOSTROMO_CREW		"Nostromo Crew"
#define NOSTROMO_CREWMATE	"Nostromo Crewmate"
#define F_NOSTROMO_CAT		"Nostromo Cat"
#define NOSTROMO_CAT		"Nostromo Cat Jonesy"
#define NOSTROMO_ANDROID	"Nostromo Android"

// crew fraction
/datum/faction/nostromo_crew
	name = F_NOSTROMO_CREW
	ID = F_NOSTROMO_CREW
	logo_state = "nostromo-logo"

	accept_latejoiners = TRUE
	initroletype = /datum/role/nostromo_crewmate
	min_roles = 0
	max_roles = 6

/datum/faction/nostromo_crew/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/kill_alien)
	return TRUE

/datum/faction/nostromo_crew/check_win()
	for(var/mob/living/L as anything in global.alien_list[ALIEN_LONE_HUNTER])
		return L.stat == DEAD
	return TRUE

// android traitor fraction
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
	return ..()


// kitty fraction
/datum/faction/nostromo_cat
	name = F_NOSTROMO_CAT
	ID = F_NOSTROMO_CAT
	logo_state = "cat-logo"
	initroletype = /datum/role/nostromo_cat
	min_roles = 0

/datum/faction/nostromo_cat/OnPostSetup()
	var/start_point = pick(landmarks_list["jonesy"])
	var/mob/living/simple_animal/cat/red/jonesy/J = new (get_turf(start_point))
	global.Jonesy = J
	return ..()
