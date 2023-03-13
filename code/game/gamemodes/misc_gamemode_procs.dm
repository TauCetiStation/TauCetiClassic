/datum/game_mode/proc/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested status information:</FONT><HR>"
	intercepttext += "<B> In case you have misplaced your copy, attached is a list of personnel whom reliable sources&trade; suspect may be affiliated with the Syndicate:</B><br>"

	var/list/suspects = list()
	for(var/mob/living/carbon/human/man in player_list)
		if(!man.client || !man.mind)
			continue

		// NT relation option
		var/list/invisible_roles = list(
			WIZARD, NINJA, NUKE_OP,
			NUKE_OP_LEADER, VOXRAIDER,
			ABDUCTOR_AGENT, ABDUCTOR_SCI,
			)

		var/accept = TRUE
		for(var/role in invisible_roles)
			if(isrole(role, man))
				accept = FALSE
				break
		if(!accept)
			continue

		if(man.client.prefs.nanotrasen_relation == "Opposed" && prob(50) || \
		   man.client.prefs.nanotrasen_relation == "Skeptical" && prob(20))
			suspects += man

		else if(istraitor(man) && prob(40) || ischangeling(man) && prob(50) || iscultist(man) && prob(30) || \
				isrevhead(man) && prob(30) || isshadowling(man) && prob(20))

			suspects += man

			// If they're a traitor or likewise, give them extra TC in exchange.
			var/obj/item/device/uplink/hidden/suplink = find_syndicate_uplink(man)
			if(suplink)
				var/extra = 8
				suplink.uses += extra
				for(var/role in man.mind.antag_roles)
					var/datum/role/R = man.mind.antag_roles[role]
					var/datum/component/gamemode/syndicate/S = R.GetComponent(/datum/component/gamemode/syndicate)
					if(S)
						S.total_TC += extra
				to_chat(man, "<span class='warning'>We have received notice that enemy intelligence suspects you to be linked with us. We have thus invested significant resources to increase your uplink's capacity.</span>")
			else
				// Give them a warning!
				to_chat(man, "<span class='warning'>They are on to you!</span>")

		// Some poor people who were just in the wrong place at the wrong time..
		else if(prob(10))
			suspects += man
	for(var/mob/M in suspects)
		switch(rand(1, 100))
			if(1 to 50)
				intercepttext += "Someone with the job of <b>[M.mind.assigned_role]</b> <br>"
			else
				intercepttext += "<b>[M.name]</b>, the <b>[M.mind.assigned_role]</b> <br>"

	for (var/obj/machinery/computer/communications/comm in communications_list)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "Cent. Com. Status Summary"
			intercept.info = intercepttext
			intercept.update_icon()

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	announcement_ping.play()


// refactor to /datum/stat_collector from vg
// https://github.com/vgstation-coders/vgstation13/blob/e9a806f30b4db0efa2a68b9eb42e3120d2321b6a/code/datums/statistics/stat_helpers.dm
/datum/game_mode/proc/count_survivors()
	var/clients = 0
	var/surviving_humans = 0
	var/surviving_total = 0
	var/ghosts = 0
	var/escaped_humans = 0
	var/escaped_total = 0
	var/escaped_on_pod_1 = 0
	var/escaped_on_pod_2 = 0
	var/escaped_on_pod_3 = 0
	var/escaped_on_pod_5 = 0
	var/escaped_on_shuttle = 0

	var/list/area/escape_locations = list(/area/shuttle/escape/centcom, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod4/centcom)

	for(var/mob/M in player_list)
		if(M.client)
			clients++
			var/area/mob_area = get_area(M)
			if(ishuman(M))
				if(M.stat == CONSCIOUS)
					surviving_humans++
					if(mob_area.type in escape_locations)
						escaped_humans++
			if(M.stat == CONSCIOUS)
				surviving_total++
				if(mob_area.type in escape_locations)
					escaped_total++

				if(mob_area.type == /area/shuttle/escape/centcom)
					escaped_on_shuttle++

				if(mob_area.type == /area/shuttle/escape_pod1/centcom)
					escaped_on_pod_1++
				if(mob_area.type == /area/shuttle/escape_pod2/centcom)
					escaped_on_pod_2++
				if(mob_area.type == /area/shuttle/escape_pod3/centcom)
					escaped_on_pod_3++
				if(mob_area.type == /area/shuttle/escape_pod4/centcom)
					escaped_on_pod_5++

			if(isobserver(M))
				ghosts++

	if(clients > 0)
		feedback_set("round_end_clients",clients)
	if(ghosts > 0)
		feedback_set("round_end_ghosts",ghosts)
	if(surviving_humans > 0)
		feedback_set("survived_human",surviving_humans)
	if(surviving_total > 0)
		feedback_set("survived_total",surviving_total)
		SSStatistics.score.crew_survived = surviving_total
	if(escaped_humans > 0)
		feedback_set("escaped_human",escaped_humans)
		SSStatistics.score.crew_escaped = escaped_humans
	if(escaped_total > 0)
		feedback_set("escaped_total",escaped_total)
	if(escaped_on_shuttle > 0)
		feedback_set("escaped_on_shuttle",escaped_on_shuttle)
	if(escaped_on_pod_1 > 0)
		feedback_set("escaped_on_pod_1",escaped_on_pod_1)
	if(escaped_on_pod_2 > 0)
		feedback_set("escaped_on_pod_2",escaped_on_pod_2)
	if(escaped_on_pod_3 > 0)
		feedback_set("escaped_on_pod_3",escaped_on_pod_3)
	if(escaped_on_pod_5 > 0)
		feedback_set("escaped_on_pod_5",escaped_on_pod_5)

//////////////////////////
//Reports player logouts//
//////////////////////////
/datum/game_mode/proc/display_roundstart_logout_report()
	var/msg = "<span class='notice'><b>Roundstart logout report</b>\n\n</span>"
	for(var/mob/living/L as anything in living_list)

		if(L.ckey)
			var/found = 0
			for(var/client/C in clients)
				if(C.ckey == L.ckey)
					found = 1
					break
			if(!found)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2))	//Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				continue //AFK client
			if(L.stat != CONSCIOUS)
				if(L.suiciding)	//Suicider
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
					continue //Disconnected client
				if(L.stat == UNCONSCIOUS)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dying)\n"
					continue //Unconscious
				if(L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.ckey]), the [L.job] (Dead)\n"
					continue //Dead

			continue //Happy connected client
		for(var/mob/dead/observer/D as anything in observer_list)
			if(D.mind && (D.mind.original == L || D.mind.current == L))
				if(L.stat == DEAD)
					if(L.suiciding)	//Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Suicide</b></font>)\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>This shouldn't appear.</b></font>)\n"
						continue //Lolwhat
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (<font color='red'><b>Ghosted</b></font>)\n"
						continue //Ghosted while alive

	for(var/client/M as anything in admins)
		if(M.holder)
			to_chat(M, msg)
	log_game(strip_html_properly(msg))

/proc/find_syndicate_uplink(mob/living/carbon/human/human)
	var/list/L = human.get_all_contents_type(/obj/item)
	for(var/A in L)
		var/obj/item/I = A
		if(I.hidden_uplink)
			return I.hidden_uplink
	return null

/proc/get_nt_opposed()
	var/list/dudes = list()
	for(var/mob/living/carbon/human/man as anything in human_list)
		if(man.client)
			if(man.client.prefs.nanotrasen_relation == "Opposed")
				dudes += man
			else if(man.client.prefs.nanotrasen_relation == "Skeptical" && prob(50))
				dudes += man
	if(dudes.len == 0)
		return null
	return pick(dudes)

/proc/mode_has_antags()
	return SSticker.mode.factions.len > 0 || SSticker.mode.orphaned_roles.len > 0

// Ex: all xenomorph have boilerplate names (alien drone (123), alien hunter (321)),
// but all wizards have unique names
/proc/get_roles_with_interesting_names()
	return list(ABDUCTED, CHANGELING, CULTIST, CULT_LEADER, DEATHSQUADIE, GANGSTER, GANGSTER_LEADER,
				GANGSTER_DEALER, HEADREV, MALF, MALFBOT, NUKE_OP, NUKE_OP_LEADER, NINJA, REV,
				RESPONDER, SHADOW_THRALL, TRAITOR, TRAITORCHAN, UNDERCOVER_COP, WIZARD, WIZ_APPRENTICE)

//add crates to cargo
/datum/game_mode/proc/add_supply_to_cargo(num_supply_packs = 1, supply_pack_name = "Crate", orderer = "Cent Comm", orderer_rank = "Cent Comm", orderer_ckey = "", reason_string = "No reisin")
	for(var/i in 1 to num_supply_packs)
		var/datum/supply_order/order = new(SSshuttle.supply_packs[ckey(supply_pack_name)], orderer, orderer_rank, orderer_ckey, reason_string)
		SSshuttle.shoppinglist += order
		. = TRUE
