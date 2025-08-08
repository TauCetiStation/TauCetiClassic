
/datum/faction/star_wars
	var/obj/structure/ivent/star_wars/artifact/force_source

/datum/faction/star_wars/proc/isforceuser(mob/living/carbon/C)
	return C in force_source.force_users

// JEDI

/datum/faction/star_wars/jedi
	name = "Jedi Order"
	ID = F_JEDI_ORDER

	initroletype = /datum/role/star_wars/jedi_leader
	roletype = /datum/role/star_wars/jedi

	min_roles = 0
	max_roles = 2

	logo_state = "jedi_logo"

	var/list/force_spells = list(
		/obj/effect/proc_holder/spell/in_hand/heal/star_wars,
		/obj/effect/proc_holder/spell/targeted/summonitem/star_wars,
		/obj/effect/proc_holder/spell/targeted/forcewall/star_wars,
		/obj/effect/proc_holder/spell/targeted/lighting_shock/star_wars)

/datum/faction/star_wars/jedi/forgeObjectives()
	if(!..())
		return FALSE

	AppendObjective(/datum/objective/star_wars/convert)
	AppendObjective(/datum/objective/star_wars/jedi)
	return TRUE

/datum/faction/star_wars/jedi/OnPostSetup()
	. = ..()
	for(var/datum/role/R in members)
		R.antag.current.forceMove(pick_landmarked_location("Jedi Spawn"))

	addtimer(CALLBACK(src, PROC_REF(give_announce)), 20 SECOND)
	addtimer(CALLBACK(src, PROC_REF(open_gate)), 30 SECOND)

/datum/faction/star_wars/jedi/proc/give_announce()
	var/datum/announcement/centcomm/star_wars/jedi_arrival/A = new
	A.play()

/datum/faction/star_wars/jedi/proc/open_gate()
	var/obj/machinery/gateway/center/jedi_gate
	var/obj/machinery/gateway/center/station_gate

	for(var/obj/machinery/gateway/center/G in global.gateways_list)
		if(G.name == "Jedi Gateway")
			jedi_gate = G
		if(G.name == "[station_name()] Gateway")
			station_gate = G

	jedi_gate.destination = station_gate
	jedi_gate.toggleon()

// SITH

/datum/faction/star_wars/sith
	name = "Sith Order"
	ID = F_SITH_ORDER

	initroletype = /datum/role/star_wars/sith_leader
	roletype = /datum/role/star_wars/sith

	min_roles = 0
	max_roles = 2

	logo_state = "sith_logo"

	var/list/force_spells = list(
		/obj/effect/proc_holder/spell/targeted/emplosion/disable_tech/star_wars,
		/obj/effect/proc_holder/spell/targeted/summonitem/star_wars,
		/obj/effect/proc_holder/spell/aoe_turf/repulse/star_wars,
		/obj/effect/proc_holder/spell/in_hand/tesla/star_wars)

/datum/faction/star_wars/sith/forgeObjectives()
	if(!..())
		return FALSE

	AppendObjective(/datum/objective/star_wars/convert)
	AppendObjective(/datum/objective/star_wars/sith)
	return TRUE
