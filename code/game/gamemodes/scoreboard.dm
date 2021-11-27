/datum/controller/subsystem/ticker/proc/scoreboard(completions, mob/one_mob)
	if(achievements.len)
		completions += "<div class='Section'>[achievement_declare_completion()]</div>"

	// Who is alive/dead, who escaped
	for (var/mob/living/silicon/ai/I in ai_list)
		if (I.stat == DEAD && is_station_level(I.z))
			score["deadaipenalty"] = 1
			score["crew_dead"] += 1

	for (var/mob/living/carbon/human/I as anything in human_list)
		if (I.stat == DEAD && is_station_level(I.z))
			score["crew_dead"] += 1
		if (I.job == "Clown")
			for(var/thing in I.attack_log)
				if(findtext(thing, "<font color='orange'>")) //</font>
					score["clownabuse"]++

	var/area/escape_zone = get_area_by_type(/area/shuttle/escape/centcom)

	var/cashscore = 0
	var/dmgscore = 0
	for(var/mob/living/carbon/human/E as anything in human_list)
		if(E.stat == DEAD)
			continue
		cashscore = 0
		dmgscore = 0
		var/turf/location = get_turf(E.loc)
		if(location in escape_zone) // Escapee Scores
			if(E.mind && E.mind.initial_account)
				cashscore += E.mind.initial_account.money

			for (var/obj/item/weapon/spacecash/C2 in get_contents_in_object(E, /obj/item/weapon/spacecash))
				cashscore += C2.worth

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
		if (istype(M, /obj/effect/decal/cleanable/vomit))
			score["mess"] += 1

	// How many antags did we reconvert using loyalty implant.
	for(var/datum/faction/faction in SSticker.mode.factions)
		for(var/datum/role/reconverted in faction.members)
			if(!reconverted.antag)
				score["rec_antags"]++
	for(var/datum/role/reconverted in SSticker.mode.orphaned_roles)
		if(!reconverted.antag)
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
	var/plaguepoints = score["disease"] * 30
	var/messpoints = score["mess"] != 0 ? score["mess"] : null

	for(var/datum/faction/F in mode.factions)
		F.build_scorestat()

	// Good Things
	score["crewscore"] += shipping + harvests + mining + meals + researchpoints + eventpoints + escapoints

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
	score["crewscore"] -= messpoints
	score["crewscore"] -= plaguepoints

	if(one_mob)
		one_mob.scorestats(completions)
	else
		for(var/mob/E in player_list)
			if(E.client)
				E.scorestats(completions)

/mob/proc/scorestats(completions)//omg why we count this for every player
	// Show the score - might add "ranks" later
	to_chat(src, "<b>The crew's final score is:</b>")
	to_chat(src, "<b><font size='4'>[score["crewscore"]]</font></b>")

	var/dat = completions
	dat += {"<h2>Round Statistics and Score</h2><div class='Section'>"}

	for(var/datum/faction/F in SSticker.mode.factions)
		var/stat = F.get_scorestat()
		if(stat)
			dat += stat
			dat += "<hr>"

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

	var/datum/browser/popup = new(src, "roundstats", "Round #[global.round_id] Stats", 1000, 600)
	popup.set_content(dat)
	popup.open()
