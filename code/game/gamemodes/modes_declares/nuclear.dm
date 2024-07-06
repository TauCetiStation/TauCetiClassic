/datum/game_mode/nuclear
	name = "Nuclear Emergency"
	config_name = "nuke"
	probability = 100

	factions_allowed = list(/datum/faction/nuclear)

	minimum_player_count = 21
	minimum_players_bundles = 20

/datum/game_mode/nuclear/announce()
	to_chat(world, "<B>Текущий режим игры - Ядерная катастрофа!</B>")
	to_chat(world, "<B>Мародёры Gorlex приближаются к [station_name_ru()]!</B>")
	to_chat(world, "НаноТрейзен перевозили ядерную боеголовку на военную базу. Транспортный корабль загадочным образом потерял связь с системой управления космическим движением. Примерно в это же время в районе [station_name_ru()] был обнаружен странный диск. Он был идентифицирован НаноТрайзен как диск ядерной аутентификации, и теперь оперативники Синдиката прибыли, чтобы захватить диск и взорвать [station_name_ru()]! Кроме того, поблизости, скорее всего, находятся звездные корабли Синдиката, так что будьте осторожны, чтобы не потерять диск!\n<B>Синдикат</B>: Верните диск и взорвите ядерную бомбу в любой точке [station_name_ru()].\n<B>Персонал</B>: Сохраните диск и <B>улетите с диском</B> на шаттле!")

/datum/game_mode/nuclear/proc/announce_war()
	if(player_list.len >= 35)
		return
	var/datum/announcement/centcomm/nuclear/low_pop_war/announce = new
	announce.play()
	set_security_level(SEC_LEVEL_RED)
	SSshuttle.fake_recall = TRUE
	addtimer(CALLBACK(src, PROC_REF(call_shuttle)), 30 MINUTES)

/datum/game_mode/nuclear/proc/call_shuttle()
	SSshuttle.fake_recall = FALSE
	SSshuttle.incall(0.5)
