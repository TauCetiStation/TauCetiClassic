/obj/item/weapon/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_TINY
	var/used = FALSE

/obj/item/weapon/antag_spawner/proc/spawn_antag(client/C, turf/T, type = "")
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
	var/list/borg_candicates = pollGhostCandidates("Syndicate requesting a personality for a syndicate borg. Would you like to play as one?", ROLE_OPERATIVE)
	if(borg_candicates.len)
		used = TRUE
		var/mob/M = pick(borg_candicates)
		spawn_antag(M.client, get_turf(src.loc), "syndieborg")
	else
		used = FALSE
		visible_message("<span class='notice'>Unable to connect to Syndicate Command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>")

/obj/item/weapon/antag_spawner/borg_tele/spawn_antag(client/C, turf/T, type = "")
	var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread
	S.set_up(4, 1, src)
	S.start()
	var/mob/living/silicon/robot/R = new /mob/living/silicon/robot/syndicate(T)
	R.key = C.key
	SSticker.mode.syndicates += R.mind
	SSticker.mode.update_synd_icons_added(R.mind)
	R.mind.special_role = "syndicate"
	R.faction = "syndicate"
