/obj/item/device/traitor_caller
	name = "Suspicious phone"
	desc = "Make a call for to attract an extra agent at station"
	w_class = SIZE_TINY
	origin_tech = "programming=4;materials=4"
	icon = 'icons/obj/items.dmi'
	icon_state = "red_phone"
	var/uses = 1

/obj/item/device/traitor_caller/attack_self(mob/user)
	if(!uses)
		to_chat(user, "<span class='userdanger'>No calls left!</span>")
		return
	if(SSshuttle.departed || SSshuttle.online)
		to_chat(user, "<span class='userdanger'>All rats have worked their shift</span>")
		return
	playsound(user, 'sound/weapons/ring.ogg', VOL_EFFECTS_MASTER)
	uses--
	var/list/possible_traitors = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(player.client && player.mind && player.stat != DEAD && !player.mind.special_role \
		&& (ROLE_TRAITOR in player.client.prefs.be_role) && !jobban_isbanned(player, "Syndicate") \
		&& !jobban_isbanned(player, ROLE_TRAITOR) && !role_available_in_minutes(player, ROLE_TRAITOR) && !player.ismindprotect())

			possible_traitors += player
			for(var/job in list("Internal Affairs Agent", "Security Officer", "Warden", "Head of Security", "Captain"))
				if(player.mind.assigned_role == job)
					possible_traitors -= player

	if(length(possible_traitors) <= 0)
		to_chat(user, "<span class='userdanger'>We cannot get at one of our agents, you can try to call him later...</span>")
		uses++
		return

	var/mob/living/carbon/human/newtraitor = pick(possible_traitors)
	create_and_setup_role(/datum/role/traitor/syndcall, newtraitor)

