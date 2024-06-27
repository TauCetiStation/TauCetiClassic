#define CHECK_PERIOD 	200

/datum/faction/alien
	name = F_XENOMORPH
	ID = F_XENOMORPH
	logo_state = "xeno-logo"
	required_pref = ROLE_ALIEN

	initroletype = /datum/role/alien

	min_roles = 1
	max_roles = 1

	var/last_check = 0

/datum/faction/infestation/can_setup(num_players)
	if(!..())
		return FALSE
	if(xeno_spawn.len > 0)
		return TRUE
	return FALSE

/datum/faction/alien/OnPostSetup()
	var/datum/role/role = pick(members)
	var/start_point = pick(xeno_spawn)

	var/mob/living/carbon/human/H = new (get_turf(start_point))
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/white, SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white, SLOT_SHOES)
	H.name = "Gilbert Kane"
	H.real_name = "Gilbert Kane"
	H.voice_name = "Gilbert Kane"

	var/obj/item/alien_embryo/new_embryo = new /obj/item/alien_embryo(H)
	var/mob/living/carbon/xenomorph/larva/new_xeno = new /mob/living/carbon/xenomorph/larva/alien(new_embryo)
	new_xeno.loc = new_embryo
	new_embryo.baby = new_xeno
	new_embryo.controlled_by_ai = FALSE
	new_embryo.stage = 5
	role.antag.transfer_to(new_xeno)
	QDEL_NULL(role.antag.original)

	return ..()

/datum/faction/alien/proc/createKane(H)

/datum/faction/alien/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/bloodbath)
	return TRUE
