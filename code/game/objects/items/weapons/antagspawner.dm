/obj/item/weapon/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
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
	var/list/requested_candidates = list()

/obj/item/weapon/antag_spawner/borg_tele/attack_self(mob/user)
	if(used)
		to_chat(user, "The teleporter is out of power.")
		return
	var/list/borg_candicates = get_candidates(ROLE_OPERATIVE)
	if(borg_candicates.len > 0)
		requested_candidates.Cut()
		used = TRUE
		to_chat(user, "<span class='notice'>Seatching for available borg personality. Please wait 30 seconds...</span>")
		for(var/client/C in borg_candicates)
			request_player(C)
		spawn(300)
			stop_search()
	else
		to_chat(user, "<span class='notice'>Unable to connect to Syndicate Command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>")

obj/item/weapon/antag_spawner/borg_tele/proc/request_player(client/C)
	spawn(0)
		if(!C)
			return
		var/response = alert(C, "Syndicate requesting a personality for a syndicate borg. Would you like to play as one?", "Syndicate borg request", "Yes", "No")
		if(!C)
			return		//handle logouts that happen whilst the alert is waiting for a respons.
		if(response == "Yes")
			requested_candidates += C

/obj/item/weapon/antag_spawner/borg_tele/proc/stop_search()
	if(requested_candidates.len > 0)
		var/client/C = pick(requested_candidates)
		spawn_antag(C, get_turf(src.loc), "syndieborg")
	else
		used = FALSE
		visible_message("\blue Unable to connect to Syndicate Command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.")

/obj/item/weapon/antag_spawner/borg_tele/spawn_antag(client/C, turf/T, type = "")
	var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread
	S.set_up(4, 1, src)
	S.start()
	var/mob/living/silicon/robot/R = new /mob/living/silicon/robot/syndicate(T)
	R.key = C.key
	ticker.mode.syndicates += R.mind
	ticker.mode.update_synd_icons_added(R.mind)
	R.mind.special_role = "syndicate"
	R.faction = "syndicate"
