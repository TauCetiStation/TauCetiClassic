/obj/item/weapon/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_MINUSCULE
	var/used = FALSE

/obj/item/weapon/antag_spawner/proc/spawn_antag(client/C, turf/T, mob/user)
	return

/obj/item/weapon/antag_spawner/proc/equip_antag(mob/target)
	return

/obj/item/weapon/antag_spawner/borg_tele
	name = "Syndicate Cyborg Teleporter"
	desc = "A single-use teleporter used to deploy a Syndicate Cyborg on the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/TC_cost = 0
	var/list/borg_candicates = list()

/obj/item/weapon/antag_spawner/borg_tele/attack_self(mob/user)
	if(used)
		to_chat(user, "The teleporter is out of power.")
		return
	to_chat(user, "<span class='notice'>Searching for available borg personality. Please wait 30 seconds...</span>")
	used = TRUE
	var/list/borg_candicates = pollGhostCandidates("Syndicate requesting a personality for a syndicate borg. Would you like to play as one?", ROLE_OPERATIVE, IGNORE_SYNDI_BORG)
	if(borg_candicates.len)
		var/mob/M = pick(borg_candicates)
		spawn_antag(M.client, get_turf(src.loc), user)
	else
		used = FALSE
		visible_message("<span class='notice'>Unable to connect to Syndicate Command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>")

/obj/item/weapon/antag_spawner/borg_tele/spawn_antag(client/C, turf/T, mob/user)
	var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread
	S.set_up(4, 1, src)
	S.start()
	var/mob/living/silicon/robot/R = new /mob/living/silicon/robot/syndicate(T)
	R.key = C.key
	R.mind.skills.add_available_skillset(/datum/skillset/cyborg)
	R.mind.skills.maximize_active_skills()
	R.pda.cmd_toggle_pda_receiver()
	for(var/role_name in user.mind.antag_roles)
		var/datum/role/role = user.mind.antag_roles[role_name]
		if(!role.faction)
			continue
		add_faction_member(role.faction, R, TRUE)
