/obj/item/device/traitor_caller
	name = "Suspicious phone"
	desc = "Make a call for to attract an extra agent at station"
	w_class = ITEM_SIZE_SMALL
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
		&& !jobban_isbanned(player, ROLE_TRAITOR) && !role_available_in_minutes(player, ROLE_TRAITOR) && !isloyal(player))

			possible_traitors += player
			for(var/job in list("Internal Affairs Agent", "Security Officer", "Warden", "Detective", "Head of Security", "Captain"))
				if(player.mind.assigned_role == job)
					possible_traitors -= player

	if(length(possible_traitors) <= 0)
		to_chat(user, "<span class='userdanger'>We cannot get at one of our agents, you can try to call him later...</span>")
		uses++
		return

	var/mob/living/carbon/human/newtraitor = pick(possible_traitors)
	SSticker.mode.equip_traitor(newtraitor)
	SSticker.mode.syndicates += newtraitor.mind
	SSticker.mode.update_synd_icons_added(newtraitor.mind)
	to_chat(newtraitor, "<span class='userdanger'> <B>ATTENTION:</B> You hear a call from Syndicate...</span>")
	to_chat(newtraitor, "<B>You are now a special traitor.</B>")
	newtraitor.mind.special_role = "Syndicate"
	newtraitor.hud_updateflag |= 1 << SPECIALROLE_HUD
	SSticker.mode.forge_syndicate_objectives(newtraitor.mind)
	newtraitor.equip_or_collect(new /obj/item/device/encryptionkey/syndicate(newtraitor), SLOT_R_STORE)
	to_chat(newtraitor, "<span class='notice'> Your current objectives:</span>")
	var/obj_count = 1
	for(var/datum/objective/objective in newtraitor.mind.objectives)
		to_chat(newtraitor, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	SSticker.mode.update_all_synd_icons()


