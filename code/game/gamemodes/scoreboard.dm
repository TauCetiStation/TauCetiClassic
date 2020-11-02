/datum/controller/subsystem/ticker/proc/scoreboard(completions)
	if(achievements.len)
		completions += "<div class='block'>[achievement_declare_completion()]</div>"

	// Score Calculation and Display

	// Who is alive/dead, who escaped
	for (var/mob/living/silicon/ai/I in ai_list)
		if (I.stat == DEAD && is_station_level(I.z))
			score["deadaipenalty"] = 1
			score["crew_dead"] += 1

	for (var/mob/living/carbon/human/I in human_list)
//		for (var/datum/ailment/disease/V in I.ailments)
//			if (!V.vaccine && !V.spread != "Remissive") score["disease"]++
		if (I.stat == DEAD && is_station_level(I.z))
			score["crew_dead"] += 1
		if (I.job == "Clown")
			for(var/thing in I.attack_log)
				if(findtext(thing, "<font color='orange'>")) //</font>
					score["clownabuse"]++

	var/area/escape_zone = locate(/area/shuttle/escape/centcom)

/*
	moved to /game_mode/proc/declare_completion, where we already count players
	for(var/mob/living/player in alive_mob_list)
		if (player.client)
			var/turf/location = get_turf(player.loc)
			if (location in escape_zone)
				score["crew_escaped"] += 1*/
//					player.unlock_medal("100M Dash", 1)
//				player.unlock_medal("Survivor", 1)
//				for (var/obj/item/weapon/gnomechompski/G in player.get_contents())
//					player.unlock_medal("Guardin' gnome", 1)


	var/cashscore = 0
	var/dmgscore = 0
	for(var/mob/living/carbon/human/E in human_list)
		if(E.stat == DEAD)
			continue
		cashscore = 0
		dmgscore = 0
		var/turf/location = get_turf(E.loc)
		if(location in escape_zone) // Escapee Scores
			//for (var/obj/item/weapon/card/id/C1 in get_contents_in_object(E, /obj/item/weapon/card/id))
			//	cashscore += C1.money

			if(E.mind && E.mind.initial_account)
				cashscore += E.mind.initial_account.money

			for (var/obj/item/weapon/spacecash/C2 in get_contents_in_object(E, /obj/item/weapon/spacecash))
				cashscore += C2.worth

//			for(var/datum/data/record/Ba in data_core.bank)
//				if(Ba.fields["name"] == E.real_name) cashscore += Ba.fields["current_money"]
			if (cashscore > score["richestcash"])
				score["richestcash"] = cashscore
				score["richestname"] = E.real_name
				score["richestjob"] = E.job
				score["richestkey"] = E.key
			dmgscore = E.bruteloss + E.fireloss + E.toxloss + E.oxyloss
			if (dmgscore > score["dmgestdamage"])
				score["dmgestdamage"] = dmgscore
				score["dmgestname"] = E.real_name
				score["dmgestjob"] = E.job
				score["dmgestkey"] = E.key

	var/nukedpenalty = 1000
	if (SSticker.mode.config_tag == "nuclear")
		var/datum/game_mode/nuclear/GM = SSticker.mode
		var/foecount = 0
		for(var/datum/mind/M in GM.syndicates)
			foecount++
			if (!M || !M.current)
				score["opkilled"]++
				continue
			var/turf/T = M.current.loc
			if (T && istype(T.loc, /area/station/security/brig))
				score["arrested"] += 1
			else if (M.current.stat == DEAD)
				score["opkilled"]++
		if(foecount == score["arrested"])
			score["allarrested"] = 1

/*
		score["disc"] = 1
		for(var/obj/item/weapon/disk/nuclear/A in not_world)
			if(A.loc != /mob/living/carbon) continue
			var/turf/location = get_turf(A.loc)
			var/area/bad_zone1 = locate(/area)
			var/area/bad_zone2 = locate(/area/shuttle/syndicate)
			var/area/bad_zone3 = locate(/area/custom/wizard_station)
			if (location in bad_zone1) score["disc"] = 0
			if (location in bad_zone2) score["disc"] = 0
			if (location in bad_zone3) score["disc"] = 0
			if (A.loc.z != ZLEVEL_STATION) score["disc"] = 0
*/
		if (score["nuked"])
			for (var/obj/machinery/nuclearbomb/NUKE in poi_list)
				//if (NUKE.r_code == "Nope") continue
				if (NUKE.detonated == 0)
					continue
				var/turf/T = NUKE.loc
				if (istype(T,/area/shuttle/syndicate) || istype(T,/area/custom/wizard_station) || istype(T,/area/station/solar))
					nukedpenalty = 1000
				else if (istype(T,/area/station/security/main) || istype(T,/area/station/security/brig) || istype(T,/area/station/security/armoury) || istype(T,/area/station/security/checkpoint))
					nukedpenalty = 50000
				else if (istype(T,/area/station/engineering))
					nukedpenalty = 100000
				else
					nukedpenalty = 10000

	if (SSticker.mode.config_tag == "rp-revolution")
		var/datum/game_mode/rp_revolution/GM = SSticker.mode
		var/foecount = 0
		for(var/datum/mind/M in GM.head_revolutionaries)
			foecount++
			if (!M || !M.current)
				score["opkilled"]++
				continue
			var/turf/T = M.current.loc
			if (istype(T.loc, /area/station/security/brig))
				score["arrested"] += 1
			else if (M.current.stat == DEAD)
				score["opkilled"]++
		if(foecount == score["arrested"])
			score["allarrested"] = 1
		for(var/mob/living/carbon/human/player in human_list)
			if(player.mind)
				var/role = player.mind.assigned_role
				if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
					if (player.stat == DEAD)
						score["deadcommand"]++

	// Check station's power levels
	for (var/obj/machinery/power/apc/A in apc_list)
		if (!is_station_level(A.z))
			continue
		for (var/obj/item/weapon/stock_parts/cell/C in A.contents)
			if (C.charge < 2300)
				score["powerloss"] += 1 // 200 charge leeway

	// Check how much uncleaned mess is on the station
	for (var/obj/effect/decal/cleanable/M in decal_cleanable)
		if (!is_station_level(M.z))
			continue
		if (istype(M, /obj/effect/decal/cleanable/blood/gibs))
			score["mess"] += 3
		if (istype(M, /obj/effect/decal/cleanable/blood))
			score["mess"] += 1
//		if (istype(M, /obj/effect/decal/cleanable/greenpuke)) score["mess"] += 1
//		if (istype(M, /obj/effect/decal/cleanable/poop)) score["mess"] += 1 // What the literal fuck Paradise. Jesus christ no. - Iamgoofball
//		if (istype(M, /obj/decal/cleanable/urine)) score["mess"] += 1
		if (istype(M, /obj/effect/decal/cleanable/vomit))
			score["mess"] += 1

	// How many antags did we reconvert using loyalty implant.
	for(var/reconverted in SSticker.reconverted_antags)
		score["rec_antags"]++

	//Research Levels
	var/research_levels = 0
	for(var/obj/machinery/r_n_d/server/core/C in rnd_server_list)
		for(var/tech_tree_id in C.files.tech_trees)
			var/datum/tech/T = C.files.tech_trees[tech_tree_id]
			research_levels += T.level

	if(research_levels)
		score["researchdone"] += research_levels

	// Bonus Modifiers
	//var/traitorwins = score["traitorswon"]
	var/rolesuccess = score["roleswon"] * 250
	var/deathpoints = score["crew_dead"] * 250 //done
	var/researchpoints = score["researchdone"] * 30
	var/eventpoints = score["eventsendured"] * 50
	var/escapoints = score["crew_escaped"] * 25 //done
	var/harvests = score["stuffharvested"] //done
	var/shipping = score["stuffshipped"] * 75
	var/mining = score["oremined"] //done
	var/meals = score["meals"] * 5 //done, but this only counts cooked meals, not drinks served
	var/power = score["powerloss"] * 30
	var/messpoints
	if (score["mess"] != 0)
		messpoints = score["mess"] //done
	var/plaguepoints = score["disease"] * 30

	// Mode Specific
	if (SSticker.mode.config_tag == "nuclear")
		if (score["disc"])
			score["crewscore"] += 500
		var/killpoints = score["opkilled"] * 250
		var/arrestpoints = score["arrested"] * 1000
		score["crewscore"] += killpoints
		score["crewscore"] += arrestpoints
		if (score["nuked"])
			score["crewscore"] -= nukedpenalty

	if (SSticker.mode.config_tag == "rp-revolution")
		var/arrestpoints = score["arrested"] * 1000
		var/killpoints = score["opkilled"] * 500
		var/comdeadpts = score["deadcommand"] * 500
		if (score["traitorswon"])
			score["crewscore"] -= 10000
		score["crewscore"] += arrestpoints
		score["crewscore"] += killpoints
		score["crewscore"] -= comdeadpts

	score["crewscore"] += score["rec_antags"] * 500

	// Good Things
	score["crewscore"] += shipping
	score["crewscore"] += harvests
	score["crewscore"] += mining
	score["crewscore"] += meals
	score["crewscore"] += researchpoints
	score["crewscore"] += eventpoints
	score["crewscore"] += escapoints

	if (power == 0)
		score["crewscore"] += 2500
		score["powerbonus"] = 1
	if (score["mess"] == 0)
		score["crewscore"] += 3000
		score["messbonus"] = 1
	if (score["allarrested"])
		score["crewscore"] *= 3 // This needs to be here for the bonus to be applied properly

	// Bad Things
	score["crewscore"] -= rolesuccess
	score["crewscore"] -= deathpoints
	if (score["deadaipenalty"])
		score["crewscore"] -= 250
	score["crewscore"] -= power
	//if (score["crewscore"] != 0) // Dont divide by zero!
	//	while (traitorwins > 0)
	//		score["crewscore"] /= 2
	//		traitorwins -= 1
	score["crewscore"] -= messpoints
	score["crewscore"] -= plaguepoints

	// Show the score - might add "ranks" later
	to_chat(world, "<b>The crew's final score is:</b>")
	to_chat(world, "<b><font size='4'>[score["crewscore"]]</font></b>")
	for(var/mob/E in player_list)
		if(E.client) E.scorestats(completions)
	return



/mob/proc/scorestats(completions)//omg why we count this for every player
	var/dat = completions
	dat += {"<h2>Round Statistics and Score</h2><div class='block'>"}
	if (SSticker.mode.name == "nuclear emergency")
		var/foecount = 0
		var/crewcount = 0
		var/diskdat = ""
		var/bombdat = null
		var/datum/game_mode/nuclear/GM = SSticker.mode
		for(var/datum/mind/M in GM.syndicates)
			foecount++
		for(var/mob/living/C in alive_mob_list)
			if (!istype(C,/mob/living/carbon/human) || !istype(C,/mob/living/silicon/robot) || !istype(C,/mob/living/silicon/ai))
				continue
			if (!C.client)
				continue
			crewcount++

		for(var/obj/item/weapon/disk/nuclear/N in poi_list)
			if(!N)
				continue
			var/atom/disk_loc = N.loc
			while(!istype(disk_loc, /turf))
				if(istype(disk_loc, /mob))
					var/mob/M = disk_loc
					diskdat += "Carried by [M.real_name] "
				if(istype(disk_loc, /obj))
					var/obj/O = disk_loc
					diskdat += "in \a [O.name] "
				disk_loc = disk_loc.loc
			diskdat += "in [disk_loc.loc]"
			break // Should only need one go-round, probably
		var/nukedpenalty = 0
		for(var/obj/machinery/nuclearbomb/NUKE in poi_list)
			//if (NUKE.r_code == "Nope") continue
			if (NUKE.detonated == 0)
				continue
			var/turf/T = NUKE.loc
			bombdat = T.loc
			if (istype(T,/area/shuttle/syndicate) || istype(T,/area/custom/wizard_station) || istype(T,/area/station/solar))
				nukedpenalty = 1000
			else if (istype(T,/area/station/security/main) || istype(T,/area/station/security/brig) || istype(T,/area/station/security/armoury) || istype(T,/area/station/security/checkpoint))
				nukedpenalty = 50000
			else if (istype(T,/area/station/engineering))
				nukedpenalty = 100000
			else
				nukedpenalty = 10000
			break
		if (!diskdat)
			diskdat = "Uh oh. Something has fucked up! Report this."
		dat += {"<B><U>MODE STATS</U></B><BR>
		<B>Number of Operatives:</B> [foecount]<BR>
		<B>Number of Surviving Crew:</B> [crewcount]<BR>
		<B>Final Location of Nuke:</B> [bombdat]<BR>
		<B>Final Location of Disk:</B> [diskdat]<BR><BR>
		<B>Operatives Arrested:</B> [score["arrested"]] ([score["arrested"] * 1000] Points)<BR>
		<B>Operatives Killed:</B> [score["opkilled"]] ([score["opkilled"] * 250] Points)<BR>
		<B>Station Destroyed:</B> [score["nuked"] ? "Yes" : "No"] (-[nukedpenalty] Points)<BR>
		<B>All Operatives Arrested:</B> [score["allarrested"] ? "Yes" : "No"] (Score tripled)<BR>
		<HR>"}
//		<B>Nuclear Disk Secure:</B> [score["disc"] ? "Yes" : "No"] ([score["disc"] * 500] Points)<BR>
	if (SSticker.mode.name == "rp-revolution")
		var/foecount = 0
		var/comcount = 0
		var/revcount = 0
		var/loycount = 0
		var/datum/game_mode/rp_revolution/GM = SSticker.mode
		for(var/datum/mind/M in GM.head_revolutionaries)
			if (M.current && M.current.stat != DEAD) foecount++
		for(var/datum/mind/M in GM.revolutionaries)
			if (M.current && M.current.stat != DEAD) revcount++
		for(var/mob/living/carbon/human/player in human_list)
			if(player.mind)
				var/role = player.mind.assigned_role
				if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
					if (player.stat != DEAD)
						comcount++
				else
					if(player.mind in GM.revolutionaries)
						continue
					loycount++
		for(var/mob/living/silicon/X in silicon_list)
			if(X.stat == DEAD)
				continue
			loycount++
		var/revpenalty = 10000
		dat += {"<B><U>MODE STATS</U></B><BR>
		<B>Number of Surviving Revolution Heads:</B> [foecount]<BR>
		<B>Number of Surviving Command Staff:</B> [comcount]<BR>
		<B>Number of Surviving Revolutionaries:</B> [revcount]<BR>
		<B>Number of Surviving Loyal Crew:</B> [loycount]<BR><BR>
		<B>Revolution Heads Arrested:</B> [score["arrested"]] ([score["arrested"] * 1000] Points)<BR>
		<B>Revolution Heads Slain:</B> [score["opkilled"]] ([score["opkilled"] * 500] Points)<BR>
		<B>Command Staff Slain:</B> [score["deadcommand"]] (-[score["deadcommand"] * 500] Points)<BR>
		<B>Revolution Successful:</B> [score["traitorswon"] ? "Yes" : "No"] (-[score["traitorswon"] * revpenalty] Points)<BR>
		<B>All Revolution Heads Arrested:</B> [score["allarrested"] ? "Yes" : "No"] (Score tripled)<BR>
		<HR>"}
	var/totalfunds = station_account.money
	dat += {"<B><U>GENERAL STATS</U></B><BR>
	<U>THE GOOD:</U><BR>
	<B>Useful Crates Shipped:</B> [score["stuffshipped"]] ([score["stuffshipped"] * 75] Points)<BR>
	<B>Hydroponics Harvests:</B> [score["stuffharvested"]] ([score["stuffharvested"]] Points)<BR>
	<B>Ore Mined:</B> [score["oremined"]] ([score["oremined"]] Points)<BR>
	<B>Refreshments Prepared:</B> [score["meals"]] ([score["meals"] * 5] Points)<BR>
	<B>Research Completed:</B> [score["researchdone"]] ([score["researchdone"] * 30] Points)<BR>"}
	dat += "<B>Shuttle Escapees:</B> [score["crew_escaped"]] ([score["crew_escaped"] * 25] Points)<BR>"
	dat += {"<B>Random Events Endured:</B> [score["eventsendured"]] ([score["eventsendured"] * 50] Points)<BR>
	<B>Whole Station Powered:</B> [score["powerbonus"] ? "Yes" : "No"] ([score["powerbonus"] * 2500] Points)<BR>
	<B>Ultra-Clean Station:</B> [score["mess"] ? "No" : "Yes"] ([score["messbonus"] * 3000] Points)<BR><BR>
	<U>THE BAD:</U><BR>
	<B>Roles successful:</B> [score["roleswon"]] (-[score["roleswon"] * 250] Points)<BR>
	<B>Antags reconverted:</B> [score["rec_antags"]] ([score["rec_antags"] * 500] Points)<BR>
	<B>Dead Bodies on Station:</B> [score["crew_dead"]] (-[score["crew_dead"] * 250] Points)<BR>
	<B>Uncleaned Messes:</B> [score["mess"]] (-[score["mess"]] Points)<BR>
	<B>Station Power Issues:</B> [score["powerloss"]] (-[score["powerloss"] * 30] Points)<BR>
	<B>Rampant Diseases:</B> [score["disease"]] (-[score["disease"] * 30] Points)<BR>
	<B>AI Destroyed:</B> [score["deadaipenalty"] ? "Yes" : "No"] (-[score["deadaipenalty"] * 250] Points)<BR><BR>
	<U>THE WEIRD</U><BR>
	<B>Final Station Budget:</B> $[num2text(totalfunds,50)]<BR>"}
	var/profit = totalfunds - global.initial_station_money
	if (profit > 0)
		dat += "<B>Station Profit:</B> +[num2text(profit,50)]<BR>"
	else if (profit < 0)
		dat += "<B>Station Deficit:</B> [num2text(profit,50)]<BR>"
	dat += {"<B>Food Eaten:</b> [score["foodeaten"]]<BR>
	<B>Times a Clown was Abused:</B> [score["clownabuse"]]<BR><BR>"}
	if (score["crew_escaped"])
		dat += "<B>Most Richest Escapee:</B> [score["richestname"]], [score["richestjob"]]: [score["richestcash"]] credits ([score["richestkey"]])<BR>"
		dat += "<B>Most Battered Escapee:</B> [score["dmgestname"]], [score["dmgestjob"]]: [score["dmgestdamage"]] damage ([score["dmgestkey"]])<BR>"
	else
		dat += "The station wasn't evacuated or no one escaped!<BR>"
	dat += {"<HR><BR>
	<B><U>FINAL SCORE: [score["crewscore"]]</U></B><BR>"}
	score["rating"] = "The Aristocrats!"
	switch(score["crewscore"])
		if(-99999 to -50000) score["rating"] = "Even the Singularity Deserves Better"
		if(-49999 to -5000) score["rating"] = "Singularity Fodder"
		if(-4999 to -1000) score["rating"] = "You're All Fired"
		if(-999 to -500) score["rating"] = "A Waste of Perfectly Good Oxygen"
		if(-499 to -250) score["rating"] = "A Wretched Heap of Scum and Incompetence"
		if(-249 to -100) score["rating"] = "Outclassed by Lab Monkeys"
		if(-99 to -21) score["rating"] = "The Undesirables"
		if(-20 to -1) score["rating"] = "Not So Good"
		if(0) score["rating"] = "Nothing of Value"
		if(1 to 20) score["rating"] = "Ambivalently Average"
		if(21 to 99) score["rating"] = "Not Bad, but Not Good"
		if(100 to 249) score["rating"] = "Skillful Servants of Science"
		if(250 to 499) score["rating"] = "Best of a Good Bunch"
		if(500 to 999) score["rating"] = "Lean Mean Machine Thirteen"
		if(1000 to 4999) score["rating"] = "Promotions for Everyone"
		if(5000 to 9999) score["rating"] = "Ambassadors of Discovery"
		if(10000 to 49999) score["rating"] = "The Pride of Science Itself"
		if(50000 to INFINITY) score["rating"] = "NanoTrasen's Finest"
	dat += "<B><U>RATING:</U></B> [score["rating"]]"
	dat += "</div>"
	for(var/i in 1 to end_icons.len)
		src << browse_rsc(end_icons[i],"logo_[i].png")

	if(!endgame_info_logged)//so the End Round info only gets logged on the first player.
		endgame_info_logged = 1
		log_game(dat)

	var/datum/browser/popup = new(src, "roundstats", "Round #[round_id] Stats", 1000, 600)
	popup.set_content(dat)
	popup.open()

	return
