//Infestation:
//	GAMEMODE

#define CHECK_PERIOD 	200

/datum/game_mode
	var/list/datum/mind/xenomorphs = list()

/datum/game_mode/infestation
	name = "infestation"
	config_tag = "infestation"
	role_type = ROLE_ALIEN
	required_players = 25
	required_players_bundles = 35
	required_enemies = 3
	recommended_enemies = 4
	votable = 0
	var/last_check = 0

/datum/game_mode/infestation/announce()
	to_chat(world, "<b>The current game mode is - Infestation!</b>")
	to_chat(world, "<b>There are <span class='userdanger'>xenomorphs</span> on the station. Crew: Kill the xenomorphs before they infest the station. Xenomorphs: Go catch some living hamburgers.</b>")

/datum/game_mode/infestation/can_start()
	if(!..())
		return FALSE
	if(xeno_spawn.len > 0)
		return TRUE
	return FALSE

/datum/game_mode/infestation/assign_outsider_antag_roles()
	if (!..())
		return FALSE

	var/xenomorphs_num = 0

	if(antag_candidates.len <= recommended_enemies)
		xenomorphs_num = antag_candidates.len
	else
		xenomorphs_num = recommended_enemies

	while(xenomorphs_num > 0)
		var/datum/mind/new_xeno = pick(antag_candidates)
		xenomorphs += new_xeno
		antag_candidates -= new_xeno
		xenomorphs_num--

	for(var/datum/mind/xeno in xenomorphs)
		xeno.assigned_role = "MODE"
		xeno.special_role = "Xenomorph"

	return TRUE

/datum/game_mode/infestation/post_setup()
	last_check = round_start_time
	for(var/check_spawn in xeno_spawn)
		var/turf/T = get_turf(check_spawn)
		if(T.loc.name == "Construction Area")
			xeno_spawn -= check_spawn
		if(T.loc.name == "Technical Storage")
			xeno_spawn -= check_spawn

	for(var/datum/mind/xeno in xenomorphs)
		var/start_point = pick(xeno_spawn)
		xeno_spawn -= start_point
		var/area/A = get_area(start_point)

		for(var/obj/machinery/power/apc/apc in A.apc)
			apc.overload_lighting()

		var/mob/living/carbon/xenomorph/larva/L = new /mob/living/carbon/xenomorph/larva(get_turf(start_point))
		xeno.transfer_to(L)
		xeno.name = L.real_name
		QDEL_NULL(xeno.original)
		add_antag_hud(ANTAG_HUD_ALIEN, "hudalien", L)
		greet_xeno(xeno)
	return ..()

/datum/game_mode/infestation/proc/greet_xeno(datum/mind/xeno)
	to_chat(xeno.current, {"<span class='notice'><b>Вы - ксеноморф. Ваша текущая форма - грудолом.
Сейчас вы очень слабы и вас легко убить.
Прячьтесь под предметами и передвигайтесь по вентиляции, что бы сохранить свою жизнь.
Ваша главная задача - вырасти во взрослого ксеноморфа. Прогресс роста указан во вкладке Status.
Когда прогресс роста дойдет до конца, вы сможете эволюционировать в оду из трех взрослых форм.
Договоритесь со своими сестрами, кто и в какую форму будет эволюционировать.
Для общения внутри улья поставьте :ф перед сообщением.
Кто-то обязательно должен стать трутнем, это единственная форма, способная вырасти в королеву.
------------------</b></span>"})

/*
	GAME FINISH CHECKS
*/

/datum/game_mode/proc/count_hive_power(in_detail = FALSE)
	var/count = 0
	var/list/aliens = list(
	"[ALIEN_QUEEN]_live" = 0, "[ALIEN_QUEEN]_dead" = 0, "[ALIEN_QUEEN]_key" = "",
	"[ALIEN_DRONE]_live" = 0, "[ALIEN_DRONE]_dead" = 0, "[ALIEN_DRONE]_key" = "",
	"[ALIEN_SENTINEL]_live" = 0, "[ALIEN_SENTINEL]_dead" = 0, "[ALIEN_SENTINEL]_key" = "",
	"[ALIEN_HUNTER]_live" = 0, "[ALIEN_HUNTER]_dead" = 0, "[ALIEN_HUNTER]_key" = "",
	"[ALIEN_LARVA]_live" = 0, "[ALIEN_LARVA]_dead" = 0, "[ALIEN_LARVA]_key" = "")
	for(var/list_key in alien_list)
		if(list_key == ALIEN_FACEHAGGER)
			continue
		for(var/mob/living/carbon/xenomorph/A in alien_list[list_key])
			var/turf/xeno_loc = get_turf(A)
			if(!xeno_loc)
				continue
			if(!is_station_level(xeno_loc.z))
				continue
			if(list_key == ALIEN_QUEEN)
				if(A.stat == DEAD || !A.key)
					aliens["[list_key]_dead"]++
					continue
				else
					aliens["[list_key]_live"]++
					aliens["[list_key]_key"] = "[A.key]"	//there can only be one queen
			else if(list_key == ALIEN_LARVA)
				if(A.stat == DEAD || !A.key)
					aliens["[list_key]_dead"]++
				else
					aliens["[list_key]_live"]++
					aliens["[list_key]_key"] += " [A.key];"
				continue
			else
				if(A.stat == DEAD || !A.key)
					aliens["[list_key]_dead"]++
					continue
				else
					aliens["[list_key]_live"]++
					aliens["[list_key]_key"] += " [A.key];"
			count ++

	if(in_detail)
		return aliens
	return count

/datum/game_mode/infestation/declare_completion()
	completion_text += "<h3>Итоги режима ксеноморфы:</h3>"
	var/data = count_alien_percent()
	if(station_was_nuked)
		mode_result = "loss - station was nuked"
		feedback_set_details("round_end_result", mode_result)
		completion_text += "<span style='color: red; font-weight: bold;'>Станция была уничтожена!</span>"

	else if(data[ALIEN_PERCENT] >= WIN_PERCENT)
		mode_result = "win - alien win"
		feedback_set_details("round_end_result", mode_result)
		score["roleswon"]++
		completion_text += "<span style='color: green; font-weight: bold;'>Ксеноморфы захватили станцию!</span> ([data[ALIEN_PERCENT]]%)<br>"
		completion_text += "<div class='label'>"
		if(data[TOTAL_ALIEN] == 1)
			completion_text += "На станции всего один ксеноморф,"
		else
			completion_text += "Популяция ксеноморфов на станции достигла [data[TOTAL_ALIEN]] особей,"
		if(data[TOTAL_HUMAN] == 0)
			completion_text += " тогда как все члены экипажа погибли или покинули станцию."
		else
			completion_text += " тогда как живых членов экипажа осталось [data[TOTAL_HUMAN]]. Остальные погибли или покинули станцию."
		completion_text += "</div>"

	else if(data[ALIEN_PERCENT] == 0)
		mode_result = "loss - all alien destroyed"
		feedback_set_details("round_end_result", mode_result)
		completion_text += "<span style='color: red; font-weight: bold;'>Все ксеноморфы были уничтожены или покинули станцию!</span>"

	else
		mode_result = "draw - aliens are not enough to take over the station"
		feedback_set_details("round_end_result", mode_result)
		completion_text += "<span style='color: orange; font-weight: bold;'>Ксеноморфов недостаточно для захвата станции. Экипаж всё ещё сопротивляется вторжению!</span> ([data[ALIEN_PERCENT]]%)<br>"
		completion_text += "<div class='label'>"
		if(data[TOTAL_ALIEN] == 1)
			completion_text += "На станции всего один ксеноморф,"
		else
			completion_text += "Популяция ксеноморфов на станции достигла [data[TOTAL_ALIEN]] особей,"
		completion_text += " тогда как живых членов экипажа осталось [data[TOTAL_HUMAN]]."
		completion_text += "</div>"
	..()

/datum/game_mode/proc/auto_declare_completion_infestation()

	if(SSticker && !istype(SSticker.mode, /datum/game_mode/infestation))
		return

	var/text =""
	var/list/aliens = count_hive_power(in_detail = TRUE)
	var/icon/I
	text += "<table class = 'collapsing'>"

	if(!aliens["[ALIEN_QUEEN]_live"] && !aliens["[ALIEN_QUEEN]_dead"])
		text += "<tr><td colspan='2'; style='color: orange; font-weight: bold;'>У ксеноморфов не было королевы!</td></tr>"
	else
		if(aliens["[ALIEN_QUEEN]_live"])
			I = icon('icons/mob/alienqueen.dmi', "queen_s", SOUTH)
			end_icons += I
			var/tempstate = end_icons.len
			text += "<tr><td colspan='2'><span style='color: green; font-weight: bold;'>Королева осталась в живых!</span></td></tr>"
			text += {"<tr><td><img src="logo_[tempstate].png"></td>"}
			text += "<td>[aliens["[ALIEN_QUEEN]_key"]]</td></tr>"
		else
			I = icon('icons/mob/alienqueen.dmi', "queen_dead")
			end_icons += I
			var/tempstate = end_icons.len
			text += {"<tr><td><img src="logo_[tempstate].png"></td>"}
			text += "<td style='color: red; font-weight: bold;'>Королева была убита!</td></tr>"

	var/list/L = list(ALIEN_DRONE, ALIEN_SENTINEL, ALIEN_HUNTER, ALIEN_LARVA)
	for(var/list_key in L)
		if(aliens["[list_key]_live"] || aliens["[list_key]_dead"])
			text += generate_completion_text(list_key, aliens["[list_key]_live"], aliens["[list_key]_dead"], aliens["[list_key]_key"])

	text += "</table>"

	if(text)
		antagonists_completion += list(list("mode" = "infestation", "html" = text))	//to logs
		text = "<div class='Section'>[text]</div>"

	return text

/datum/game_mode/proc/generate_completion_text(xeno, xeno_live, xeno_dead, xeno_key)
	var/text = ""
	var/xeno_name = ""
	var/xeno_icon_state_live = ""
	var/xeno_icon_state_dead = ""
	var/icon/I
	switch(xeno)
		if(ALIEN_DRONE)
			xeno_name = "трутней"
			xeno_icon_state_live = "aliend_running"
			xeno_icon_state_dead = "aliend_dead"
		if(ALIEN_SENTINEL)
			xeno_name = "стражей"
			xeno_icon_state_live = "aliens_running"
			xeno_icon_state_dead = "aliens_dead"
		if(ALIEN_HUNTER)
			xeno_name = "охотников"
			xeno_icon_state_live = "alienh_running"
			xeno_icon_state_dead = "alienh_dead"
		if(ALIEN_LARVA)
			xeno_name = "грудоломов"
			xeno_icon_state_live = "larva0"
			xeno_icon_state_dead = "larva0_dead"

	if(xeno_live)
		I = icon('icons/mob/xenomorph.dmi', "[xeno_icon_state_live]", SOUTH)
	else
		I = icon('icons/mob/xenomorph.dmi', "[xeno_icon_state_dead]")
	end_icons += I
	var/tempstate = end_icons.len
	text += "<tr><td colspan='2'>Всего [xeno_name] было: [xeno_live + xeno_dead]</td></tr>"
	text += {"<tr><td><img src="logo_[tempstate].png"></td><td>"}
	if(xeno_live)
		text += "<span style='color: green; font-weight: bold;'>Выжило: [xeno_live]</span> ([xeno_key] )<br>"
	if(xeno_dead)
		text += "<span style='color: red; font-weight: bold;'>Погибло: [xeno_dead]</span>"
	text += "</td></tr>"

	return text

/datum/game_mode/infestation/proc/check_crew()
	var/total_human = 0
	for(var/mob/living/carbon/human/H in human_list)
		var/turf/human_loc = get_turf(H)
		if(!human_loc || !is_station_level(human_loc.z))
			continue
		if(H.stat == DEAD)
			continue
		if(!H.mind || !H.client)
			continue
		total_human++
	return total_human

/datum/game_mode/infestation/proc/count_alien_percent()
	var/total_human = check_crew()
	var/total_alien = count_hive_power()
	var/alien_percent = 0
	if(total_human && total_alien)
		alien_percent = round(total_alien * 100 / total_human)
	else if(!total_human && total_alien)
		alien_percent = WIN_PERCENT
	. = list(TOTAL_HUMAN = total_human, TOTAL_ALIEN = total_alien, ALIEN_PERCENT = alien_percent)

/datum/game_mode/infestation/check_finished()
	if((world.time - last_check) < CHECK_PERIOD)
		return ..()
	last_check = world.time
	var/data = count_alien_percent()
	if(data[ALIEN_PERCENT] >= WIN_PERCENT)
		return TRUE
	return ..()

#undef CHECK_PERIOD
