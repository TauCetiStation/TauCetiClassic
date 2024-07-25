#define PLAYER_PER_BLOB_CORE 30

/datum/faction/blob_conglomerate
	name = F_BLOBCONGLOMERATE
	ID = F_BLOBCONGLOMERATE
	logo_state = "blob-logo"
	required_pref = ROLE_BLOB

	initroletype = /datum/role/blob_overmind
	roletype = /datum/role/blob_overmind/cerebrate

	min_roles = 1
	max_roles = 2

	var/datum/station_state/start
	var/announcement_timer

	var/list/spawn_locs = list()
	var/list/pre_escapees = list()
	var/blobwincount = 0

/datum/faction/blob_conglomerate/New()
	..()
	spawn_locs += get_vents()

/datum/faction/blob_conglomerate/can_setup(num_players)
	max_roles = max(round(num_players/PLAYER_PER_BLOB_CORE, 1), 1)

	if(spawn_locs.len < max_roles)
		// we were unable to setup because we didn't have enough spawn locations
		return FALSE
	return TRUE

// -- Victory procs --
/datum/faction/blob_conglomerate/check_win()
	. = FALSE

	if(blobwincount <= blobs.len) //Blob took over
		for(var/datum/role/blob_overmind/R in members)
			var/mob/camera/blob/B = R.antag.current
			if(istype(B))
				B.max_blob_points = INFINITY
				B.blob_points = INFINITY
		return TRUE // force end
	if(SSticker.station_was_nuked)
		return TRUE // force end

	if(config.continous_rounds)
		return FALSE

	return .

/datum/faction/blob_conglomerate/process()
	. = ..()
	if(!blobwincount || !detect_overminds())
		return .
	if(0.2 * blobwincount < blobs.len && stage < FS_START) // Announcement
		stage(FS_START)
		if(announcement_timer)
			deltimer(announcement_timer)
	if(0.3 * blobwincount < blobs.len && stage < FS_ACTIVE) // AI law
		stage(FS_ACTIVE)
	else if(0.55 * blobwincount < blobs.len && stage < FS_MIDGAME) // Weapons in cargo
		stage(FS_MIDGAME)
	else if(0.7 * blobwincount < blobs.len && stage < FS_ENDGAME) // Nuclear codes
		stage(FS_ENDGAME)

/datum/faction/blob_conglomerate/OnPostSetup()
	start = new()
	start.count()
	announcement_timer = addtimer(CALLBACK(src, PROC_REF(stage), FS_START), rand(2 * INTERCEPT_TIME_LOW, 1.5 * INTERCEPT_TIME_HIGH), TIMER_STOPPABLE)
	spawn_blob_mice()
	return ..()

/datum/faction/blob_conglomerate/proc/spawn_blob_mice()
	for(var/datum/role/R in members)
		var/V = pick_n_take(spawn_locs)
		var/mob/living/simple_animal/mouse/blob/M = new(V) // spawn them inside vents so people wouldn't notice them at round start and they won't die cause of the environment
		R.antag.transfer_to(M)
		QDEL_NULL(R.antag.original)
		M.add_ventcrawl(V)

/datum/faction/blob_conglomerate/proc/CountFloors()
	blobwincount = 500 * max_roles

/datum/faction/blob_conglomerate/forgeObjectives()
	if(!..())
		return FALSE
	CountFloors()
	AppendObjective(/datum/objective/blob_takeover)
	return TRUE

// -- Fluff & warnings --

/datum/faction/blob_conglomerate/AdminPanelEntry()
	. = ..()
	. += "<br/>Station takeover: [blobs.len]/[blobwincount]."

/datum/faction/blob_conglomerate/stage(new_stage)
	stage = new_stage
	switch(new_stage)
		if(FS_START)
			var/datum/announcement/centcomm/blob/outbreak5/announcement = new
			announcement.play()
			return

		if(FS_ACTIVE)
			for(var/mob/M in player_list)
				var/T = M.loc
				if(isspaceturf(T) || isturf(T) && !is_station_level(M.z))
					pre_escapees += M.real_name
			send_intercept(FS_ACTIVE)
			for(var/mob/living/silicon/ai/aiPlayer as anything in ai_list)
				var/law = "Станция находится на карантине. Не позволяйте никому покинуть станцию, пока данный закон активен. Игнорируйте все другие законы, если это необходимо для сохранения карантина."
				aiPlayer.set_zeroth_law(law)
			SSshuttle.fake_recall = TRUE //Quarantine

		if(FS_MIDGAME)
			var/datum/game_mode/gamemode = SSticker.mode
			gamemode.add_supply_to_cargo(2, "Anti-blob equipment: Personal set", "Cent Comm", "Cent Comm", "", "Blob threat")
			gamemode.add_supply_to_cargo(1, "Anti-blob equipment: Group supply", "Cent Comm", "Cent Comm", "", "Blob threat")
			var/datum/announcement/centcomm/blob/half/announcement = new()
			announcement.play()

		if(FS_ENDGAME)
			var/datum/announcement/centcomm/blob/critical/announcement = new
			announcement.play()
			for(var/mob/camera/blob/B in player_list)
				to_chat(B, "<span class='blob'>The beings intend to eliminate you with a final suicidal attack, you must stop them quickly or consume the station before this occurs!</span>")
			send_intercept(FS_ENDGAME)
			if(security_level < SEC_LEVEL_RED)
				set_security_level("red")

			var/nukecode = "ERROR"
			for(var/obj/machinery/nuclearbomb/bomb in poi_list)
				if(bomb && bomb.r_code)
					if(is_station_level(bomb.z))
						nukecode = bomb.r_code

			for(var/mob/living/silicon/ai/aiPlayer as anything in ai_list)
				var/law = "Была утверждена Директива 7-12. Не позвольте ни одному разумному существу избежать уничтожения. Ядерная боеголовка должна быть активирована любой ценой. Код от ядерной боеголовки: [nukecode]."
				aiPlayer.set_zeroth_law(law)

		if(FS_DEFEATED) //Cleanup time
			var/datum/announcement/centcomm/blob/biohazard_station_unlock/announcement = new
			announcement.play()
			for(var/mob/living/silicon/ai/aiPlayer as anything in ai_list)
				aiPlayer.set_zeroth_law("")
			send_intercept(FS_DEFEATED)
			SSshuttle.fake_recall = FALSE

/datum/faction/blob_conglomerate/proc/send_intercept(report = FS_ACTIVE)
	var/intercepttext = ""
	var/interceptname = "Error"
	switch(report)
		if(FS_ACTIVE)
			interceptname = "Biohazard Alert"
			intercepttext = {"<FONT size = 3><B>Nanotrasen Update</B>: Biohazard Alert.</FONT><HR>
Reports indicate the probable transfer of a biohazardous agent onto [station_name()] during the last crew deployment cycle.
Preliminary analysis of the organism classifies it as a level 5 biohazard. Its origin is unknown.
Nanotrasen has issued a directive 7-10 for [station_name()]. The station is to be considered quarantined.
Orders for all [station_name()] personnel follows:
<ol>
	<li>Do not leave the quarantine area.</li>
	<li>Locate any outbreaks of the organism on the station.</li>
	<li>If found, use any neccesary means to contain the organism.</li>
	<li>Avoid damage to the capital infrastructure of the station.</li>
</ol>
Note in the event of a quarantine breach or uncontrolled spread of the biohazard, the directive 7-10 may be upgraded to a directive 7-12.
Message ends."}

		if(FS_ENDGAME)
			var/nukecode = "ERROR"
			for(var/obj/machinery/nuclearbomb/bomb in poi_list)
				if(bomb && bomb.r_code)
					if(is_station_level(bomb.z))
						nukecode = bomb.r_code
			interceptname = "Directive 7-12"
			intercepttext = {"<FONT size = 3><B>Nanotrasen Update</B>: Biohazard Alert.</FONT><HR>
Directive 7-12 has been issued for [station_name()].
The biohazard has grown out of control and will soon reach critical mass.
Your orders are as follows:
<ol>
	<li>Secure the Nuclear Authentication Disk.</li>
	<li>Detonate the Nuke located in the Station's Vault.</li>
</ol>
<b>Nuclear Authentication Code:</b> [nukecode]
Message ends."}

		if(FS_DEFEATED)
			interceptname = "Directive 7-12 lifted"
			intercepttext = {"<Font size = 3><B>Nanotrasen Update</B>: Biohazard contained.</FONT><HR>
Directive 7-12 has been lifted for [station_name()].
The biohazard has been contained. Please resume normal station activities.
Message ends."}
	for(var/obj/machinery/computer/communications/comm in communications_list)
		comm.messagetitle.Add(interceptname)
		comm.messagetext.Add(intercepttext)
		if(!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- [interceptname]"
			intercept.info = intercepttext
			intercept.update_icon()

// -- Scoreboard --

/datum/faction/blob_conglomerate/GetScoreboard()
	var/dat = ..()
	var/list/result = check_quarantaine()
	if (detect_overminds() && (result["numOffStation"] + result["numSpace"]))
		dat += "<span class='danger'>ИИ не смог установить карантин.</span>"
	else
		dat += "<span class='good'>ИИ смог установить карантин.</span><BR>"
	return dat

/datum/faction/blob_conglomerate/get_scorestat()
	var/dat = ""
	var/datum/station_state/end = new
	end.count()
	var/list/result = check_quarantaine()
	dat += {"<B><U>Статистика блоба</U></B><BR>
	<b>Количество блобов: [blobs.len]</b><br>
	<b>Целостность станции: [round(end.score(start)*100)]%</b><br>
	<br>
	<b>Состояние карантина:</b><br>
	Экипажа мертво: <b>[result["numDead"]]</b><br>
	Экипажа на борту станции: <b>[result["numAlive"]]</b><br>
	Экипажа в космосе: <b>[result["numSpace"]]</b><br>
	Экипажа вне станции: <b>[result["numOffStation"]]</b><br>
	Счастливчики: <b>[pre_escapees.len]</b><br>
	<HR>"}
	return dat

/datum/faction/blob_conglomerate/proc/detect_overminds()
	for(var/datum/role/R in members)
		if(R.antag.current && isovermind(R.antag.current))
			return TRUE
	return FALSE

/datum/faction/blob_conglomerate/proc/check_quarantaine()
	var/list/result = list()
	result["numDead"] = 0
	result["numSpace"] = 0
	result["numAlive"] = 0
	result["numOffStation"] = 0
	for(var/mob/living/carbon/human/M in player_list)
		if (M.is_dead())
			result["numDead"]++
		else if(M.real_name in pre_escapees)
			continue
		else
			var/T = M.loc
			if (isspaceturf(T))
				result["numSpace"]++
			else if(isturf(T))
				if (M.z!=1)
					result["numOffStation"]++
				else
					result["numAlive"]++
	return result

/datum/station_state
	var/floor = 0
	var/wall = 0
	var/r_wall = 0
	var/window = 0
	var/door = 0
	var/grille = 0
	var/mach = 0
	var/num_territories = 1 //Number of total valid territories for gang mode

/datum/station_state/proc/count(count_territories)
	for(var/Z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/T in block(locate(1, 1, Z), locate(world.maxx, world.maxy, Z)))
			if(isfloorturf(T))
				var/turf/simulated/floor/F = T
				if(!F.burnt)
					floor += 12
				else
					floor += 1

			if(iswallturf(T))
				wall += 2

			if(istype(T, /turf/simulated/wall/r_wall))
				r_wall += 2

			for(var/obj/O in T.contents)
				if(istype(O, /obj/structure/window))
					window += 1
				else if(istype(O, /obj/structure/grille))
					var/obj/structure/grille/G = O
					if(!G.destroyed)
						grille += 1
				else if(istype(O, /obj/machinery/door))
					door += 1
				else if(ismachinery(O))
					mach += 1

	if(count_territories)
		var/list/valid_territories = list()
		for(var/area/A in all_areas) //First, collect all area types on the station zlevel
			if(is_station_level(A.z))
				if(!(A.type in valid_territories) && A.valid_territory)
					valid_territories |= A.type
		if(valid_territories.len)
			num_territories = valid_territories.len //Add them all up to make the total number of area types

/datum/station_state/proc/score(datum/station_state/result)
	if(!result)
		return 0
	var/output = 0
	output += (result.floor / max(floor, 1))
	output += (result.r_wall / max(r_wall, 1))
	output += (result.wall / max(wall, 1))
	output += (result.window / max(window, 1))
	output += (result.door / max(door, 1))
	output += (result.grille / max(grille, 1))
	output += (result.mach / max(mach, 1))
	return (output / 7)

#undef PLAYER_PER_BLOB_CORE
