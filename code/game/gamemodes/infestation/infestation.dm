//Infestation:
//	GAMEMODE

#define CHECK_PERIOD 	200
#define TOTAL_HUMAN		1
#define TOTAL_ALIEN		2
#define ALIEN_PERCENT	3
#define WIN_PERCENT		190
/datum/game_mode

	var/list/datum/mind/xenomorphs = list()

/datum/game_mode/infestation
	name = "infestation"
	config_tag = "infestation"
	role_type = ROLE_ALIEN
	required_players = 1
	required_players_secret = 15
	required_enemies = 1
	recommended_enemies = 3
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
		add_antag_hud(ANTAG_HUD_ALIEN, "hudalien", L)
		greet_xeno(xeno)
	return ..()

/datum/game_mode/infestation/proc/greet_xeno(datum/mind/xeno)
	to_chat(xeno.current, "<span class='notice'><B>Вы - ксеноморф. Ваша текущая форма - грудолом.</b></span>")
	to_chat(xeno.current, "<span class='notice'><B>Сейчас вы очень слабы и вас легко убить.</b></span>")
	to_chat(xeno.current, "<span class='notice'><B>Прячьтесь под предметами и передвигайтесь по вентиляции, что бы сохранить свою жизнь.</b></span>")
	to_chat(xeno.current, "<span class='notice'><B>Ваша главная задача - вырасти во взрослого ксеноморфа. Прогресс роста указан во вкладке Status.</b></span>")
	to_chat(xeno.current, "<span class='notice'><B>Когда прогресс роста дойдет до конца, вы сможете эволюционировать в оду из трех взрослых форм.</b></span>")
	to_chat(xeno.current, "<span class='notice'><B>Договоритесь со своими сестрами, кто и в какую форму будет эволюционировать.</b></span>")
	to_chat(xeno.current, "<span class='notice'><B>Для общения внутри улья поставьте :ф перед сообщением.</b></span>")
	to_chat(xeno.current, "<span class='notice'><b>Кто-то обязательно должен стать трутнем, это единственная форма, способная вырасти в королеву.</b></span>")
	to_chat(xeno.current, "<span class='notice'>------------------</span>")

/*
	GAME FINISH CHECKS
*/

/datum/game_mode/proc/check_xeno_queen()
	var/state = 0 // 0 = no queen
	for(var/mob/living/carbon/xenomorph/humanoid/queen/Q in queen_list)
		if(Q.stat != DEAD)
			return 1
		state = 2
	return state

/datum/game_mode/proc/count_hive_power(in_detail = FALSE)
	var/count = 0
	var/list/aliens = list("Q_live" = 0, "Q_dead" = 0, "Q_key" = "",
	"D_live" = 0, "D_dead" = 0, "D_key" = "",
	"S_live" = 0, "S_dead" = 0, "S_key" = "",
	"H_live" = 0, "H_dead" = 0, "H_key" = "",
	"L_live" = 0, "L_dead" = 0, "L_key" = "",
	"F_live" = 0, "F_dead" = 0, "F_key" = "",)
	for(var/mob/living/carbon/xenomorph/A in alien_list)
		var/turf/xeno_loc = get_turf(A)
		if(!is_station_level(xeno_loc.z))
			continue
		if(isfacehugger(A))
			if(A.stat == DEAD || !A.key)
				aliens["F_dead"] ++
			else
				aliens["F_live"] ++
				aliens["F_key"] += " [A.key];"
			continue
		if(isxenolarva(A))
			if(A.stat == DEAD || !A.key)
				aliens["L_dead"] ++
			else
				aliens["L_live"] ++
				aliens["L_key"] += " [A.key];"
			continue
		if(isxenohunter(A))
			if(A.stat == DEAD || !A.key)
				aliens["H_dead"] ++
				continue
			else
				aliens["H_live"] ++
				aliens["H_key"] += " [A.key];"
		if(isxenosentinel(A))
			if(A.stat == DEAD || !A.key)
				aliens["S_dead"] ++
				continue
			else
				aliens["S_live"] ++
				aliens["S_key"] += " [A.key];"
		if(isxenodrone(A))
			if(A.stat == DEAD || !A.key)
				aliens["D_dead"] ++
				continue
			else
				aliens["D_live"] ++
				aliens["D_key"] += " [A.key];"
		if(isxenoqueen(A))
			if(A.stat == DEAD || !A.key)
				aliens["Q_dead"] ++
				continue
			else
				aliens["Q_live"] ++
				aliens["Q_key"] = "[A.key]"	//there can only be one queen
		count ++

	message_admins("<span class='notice'>Qu: [aliens["Q_live"]] - [aliens["Q_key"]].\
	Dr: [aliens["D_live"]] - [aliens["D_key"]]. \
	Se: [aliens["S_live"]] - [aliens["S_key"]]. \
	Hu: [aliens["H_live"]] - [aliens["H_key"]]. \
	La: [aliens["L_live"]] - [aliens["L_key"]]. \
	Fa: [aliens["F_live"]] - [aliens["F_key"]].</span>")	//for debug
	if(in_detail)
		return aliens
	else
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
	var/text =""
	var/list/aliens = count_hive_power(in_detail = TRUE)
	var/icon/I
	text += "<table>"

	if(!aliens["Q_live"] && !aliens["Q_dead"])
		text += "<tr><td colspan='2'; style='color: orange; font-weight: bold;'>У ксеноморфов не было королевы!</td></tr>"
	else
		if(aliens["Q_live"])
			I = icon('icons/mob/alienqueen.dmi', "queen_s", SOUTH)
			end_icons += I
			var/tempstate = end_icons.len
			text += "<tr><td colspan='2'><span style='color: green; font-weight: bold;'>Королева осталась в живых!</span></td></tr>"
			text += {"<tr><td><img src="logo_[tempstate].png"></td>"}
			text += "<td>[aliens["Q_key"]]</td></tr>"
		else
			I = icon('icons/mob/alienqueen.dmi', "queen_dead")
			end_icons += I
			var/tempstate = end_icons.len
			text += {"<tr><td><img src="logo_[tempstate].png"></td>"}
			text += "<td style='color: red; font-weight: bold;'>Королева была убита!</td></tr>"

	if(!aliens["D_live"] && !aliens["D_dead"])
	else
		text += generate_completion_text("drone", aliens["D_live"], aliens["D_dead"], aliens["D_key"])

	if(!aliens["S_live"] && !aliens["S_dead"])
	else
		text += generate_completion_text("sentinel", aliens["S_live"], aliens["S_dead"], aliens["S_key"])

	if(!aliens["H_live"] && !aliens["H_dead"])
	else
		text += generate_completion_text("hunter", aliens["H_live"], aliens["H_dead"], aliens["H_key"])

	if(!aliens["L_live"] && !aliens["L_dead"])
	else
		text += generate_completion_text("larva", aliens["L_live"], aliens["L_dead"], aliens["L_key"])

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
		if("drone")
			xeno_name = "трутней"
			xeno_icon_state_live = "aliend_running"
			xeno_icon_state_dead = "aliend_dead"
		if("sentinel")
			xeno_name = "стражей"
			xeno_icon_state_live = "aliens_running"
			xeno_icon_state_dead = "aliens_dead"
		if("hunter")
			xeno_name = "охотников"
			xeno_icon_state_live = "alienh_running"
			xeno_icon_state_dead = "alienh_dead"
		if("larva")
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
	var/human_dead = 0
	var/human_no_client = 0
	var/outside_station = 0
	for(var/mob/living/carbon/human/H in human_list)
		var/turf/human_loc = get_turf(H)
		if(!is_station_level(human_loc.z))
			outside_station ++
			continue
		if(H.stat == DEAD)
			human_dead ++
			continue
		if(!H.mind || !H.client)
			human_no_client ++
			message_admins("<span class='notice'>No client: [H.name].</span>")
			continue
		total_human ++
	message_admins("<span class='notice'>Мертвых: [human_dead]. Без игрока: [human_no_client]. Не на станции: [outside_station].</span>")	//for debug
	return total_human

/datum/game_mode/infestation/proc/count_alien_percent()
	var/total_human = check_crew()
	var/total_alien = count_hive_power()
	var/alien_percent = 0
	if(total_human && total_alien)
		alien_percent = round(total_alien * 100 / total_human)
	else if(!total_human && total_alien)
		alien_percent = WIN_PERCENT
	. = list(total_human, total_alien, alien_percent)

/datum/game_mode/infestation/check_finished()
	if((world.time - last_check) < CHECK_PERIOD)
		return ..()
	last_check = world.time
	var/data = count_alien_percent()
	message_admins("<span class='notice'>Чужие: [data[TOTAL_ALIEN]] Люди: [data[TOTAL_HUMAN]] Процент: [data[ALIEN_PERCENT]]</span>")	//for debug
	if(data[ALIEN_PERCENT] >= WIN_PERCENT)
		return TRUE
	else
		return ..()

#undef CHECK_PERIOD
#undef TOTAL_HUMAN
#undef TOTAL_ALIEN
#undef ALIEN_PERCENT
#undef WIN_PERCENT
