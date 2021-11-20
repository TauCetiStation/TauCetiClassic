#define CHECK_PERIOD 	200

/datum/faction/infestation
	name = F_XENOMORPH_HIVE
	ID = F_XENOMORPH_HIVE
	logo_state = "xeno-logo"
	required_pref = ROLE_ALIEN

	initroletype = /datum/role/alien

	min_roles = 3
	max_roles = 4

	var/last_check = 0

	var/list/first_help = list("Xeno liquidator" = 4)
	var/list/second_help = list("Xeno arsonist" = 4)
	var/first_help_sent = FALSE
	var/second_help_sent = FALSE
	var/win_declared = FALSE

/datum/faction/infestation/AdminPanelEntry(datum/admins/A)
	var/dat = ..()
	var/data = count_alien_percent()
	dat += "<br><table><tr><td><B>Статистика</B></td><td></td></tr>"
	dat += "<tr><td>Экипаж:</td><td>[data[TOTAL_HUMAN]]</td></tr>"
	dat += "<tr><td>Взрослые ксеноморфы:</td><td>[data[TOTAL_ALIEN]]</td></tr>"
	dat += "<tr><td>Процент победы:</td><td>[data[ALIEN_PERCENT]]/[WIN_PERCENT]</td></tr></table>"
	return dat

// Without spam members
/datum/faction/infestation/AdminPanelEntryMembers(datum/admins/A)
	return

/datum/faction/infestation/can_setup(num_players)
	if(!..())
		return FALSE
	if(xeno_spawn.len > 0)
		return TRUE
	return FALSE

/datum/faction/infestation/OnPostSetup()
	for(var/check_spawn in xeno_spawn)
		var/turf/T = get_turf(check_spawn)
		if(T.loc.name == "Construction Area")
			xeno_spawn -= check_spawn
		if(T.loc.name == "Technical Storage")
			xeno_spawn -= check_spawn

	for(var/datum/role/role in members)
		var/start_point = pick(xeno_spawn)
		xeno_spawn -= start_point
		var/area/A = get_area(start_point)

		for(var/obj/machinery/power/apc/apc in A.apc)
			apc.overload_lighting()

		var/mob/living/carbon/xenomorph/larva/L = new /mob/living/carbon/xenomorph/larva(get_turf(start_point))
		role.antag.transfer_to(L)
		QDEL_NULL(role.antag.original)

	return ..()

/datum/faction/infestation/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/reproduct)
	return TRUE

/datum/faction/infestation/proc/count_hive_power(in_detail = FALSE)
	var/count = 0
	var/list/aliens = list(
	"[ALIEN_QUEEN]_live" = 0, "[ALIEN_QUEEN]_dead" = 0, "[ALIEN_QUEEN]_key" = "",
	"[ALIEN_DRONE]_live" = 0, "[ALIEN_DRONE]_dead" = 0, "[ALIEN_DRONE]_key" = "",
	"[ALIEN_SENTINEL]_live" = 0, "[ALIEN_SENTINEL]_dead" = 0, "[ALIEN_SENTINEL]_key" = "",
	"[ALIEN_HUNTER]_live" = 0, "[ALIEN_HUNTER]_dead" = 0, "[ALIEN_HUNTER]_key" = "",
	"[ALIEN_LARVA]_live" = 0, "[ALIEN_LARVA]_dead" = 0, "[ALIEN_LARVA]_key" = "")
	for(var/list_key in alien_list)
		if(list_key == ALIEN_FACEHUGGER)
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
			count++

	if(in_detail)
		return aliens
	return count

/datum/faction/infestation/proc/check_crew()
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

/datum/faction/infestation/proc/count_alien_percent()
	var/total_human = check_crew()
	var/total_alien = count_hive_power()
	var/alien_percent = 0
	if(total_human && total_alien)
		alien_percent = round(total_alien * 100 / total_human)
	else if(!total_human && total_alien)
		alien_percent = WIN_PERCENT
	. = list(TOTAL_HUMAN = total_human, TOTAL_ALIEN = total_alien, ALIEN_PERCENT = alien_percent)

/datum/faction/infestation/check_win()
	if(last_check > world.time)
		return FALSE
	last_check = world.time + CHECK_PERIOD
	var/data = count_alien_percent()
	if(data[ALIEN_PERCENT] == 0 && first_help_sent && !win_declared)
		var/datum/announcement/centcomm/xeno/crew_win/announcement = new
		announcement.play()
		SSshuttle.fake_recall = FALSE
		win_declared = TRUE
	else if(data[ALIEN_PERCENT] >= FIRST_HELP_PERCENT && !first_help_sent)
		send_help_crew(first_help, /datum/announcement/centcomm/xeno/first_help, /datum/announcement/centcomm/xeno/first_help/fail)
		first_help_sent = TRUE
		SSshuttle.fake_recall = TRUE //Quarantine
	else if(data[ALIEN_PERCENT] >= SECOND_HELP_PERCENT && !second_help_sent)
		send_help_crew(second_help, /datum/announcement/centcomm/xeno/second_help, /datum/announcement/centcomm/xeno/second_help/fail)
		second_help_sent = TRUE
	else if(data[ALIEN_PERCENT] >= WIN_PERCENT)
		return TRUE
	return FALSE

/datum/faction/infestation/proc/generate_completion_text(xeno, xeno_live, xeno_dead, xeno_key)
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

/datum/faction/infestation/custom_member_output()
	var/dat = ""

	var/list/aliens = count_hive_power(in_detail = TRUE)
	var/icon/I
	dat += "<table class = 'collapsing'>"

	if(!aliens["[ALIEN_QUEEN]_live"] && !aliens["[ALIEN_QUEEN]_dead"])
		dat += "<tr><td colspan='2'; style='color: orange; font-weight: bold;'>У ксеноморфов не было королевы!</td></tr>"
	else
		if(aliens["[ALIEN_QUEEN]_live"])
			I = icon('icons/mob/alienqueen.dmi', "queen_s", SOUTH)
			end_icons += I
			var/tempstate = end_icons.len
			dat += "<tr><td colspan='2'><span style='color: green; font-weight: bold;'>Королева осталась в живых!</span></td></tr>"
			dat += {"<tr><td><img src="logo_[tempstate].png"></td>"}
			dat += "<td>[aliens["[ALIEN_QUEEN]_key"]]</td></tr>"
		else
			I = icon('icons/mob/alienqueen.dmi', "queen_dead")
			end_icons += I
			var/tempstate = end_icons.len
			dat += {"<tr><td><img src="logo_[tempstate].png"></td>"}
			dat += "<td style='color: red; font-weight: bold;'>Королева была убита!</td></tr>"

	var/list/L = list(ALIEN_DRONE, ALIEN_SENTINEL, ALIEN_HUNTER, ALIEN_LARVA)
	for(var/list_key in L)
		if(aliens["[list_key]_live"] || aliens["[list_key]_dead"])
			dat += generate_completion_text(list_key, aliens["[list_key]_live"], aliens["[list_key]_dead"], aliens["[list_key]_key"])

	dat += "</table>"

	return dat

//send help to cargo from Cent Comm
//*list/supply_crates - associative list, string key - name of supply pack, int value - number of crates to send
//*announce - successful shuttle dispatch announcement
//*announce_fail - the shuttle was busy, the crates were added to the shopping list. Send the shuttle yourself
/datum/faction/infestation/proc/send_help_crew(list/supply_crates, announce, announce_fail)
	//find supply pack by name and create supply order
	for(var/crate_name in supply_crates)
		var/supply_name = ckey(crate_name)
		var/datum/supply_pack/P = SSshuttle.supply_packs[supply_name]
		var/datum/supply_order/O = new /datum/supply_order(P, "Cent Comm", "Cent Comm", "", "Xeno threat")
		//add supply orders to shopping list
		var/number_supply_orders = supply_crates[crate_name]
		for(var/i in 1 to number_supply_orders)
			SSshuttle.shoppinglist += O

	if(send_shuttle())
		var/datum/announcement/centcomm/xeno/announcement = new announce
		announcement.play()
	else
		var/datum/announcement/centcomm/xeno/announcement = new announce_fail
		announcement.play()

/datum/faction/infestation/proc/send_shuttle()
	if(!SSshuttle.can_move())
		return FALSE
	if(SSshuttle.at_station)
		SSshuttle.send()
		SSshuttle.sell()
		SSshuttle.buy()
		SSshuttle.moving = 1
		SSshuttle.set_eta_timeofday()
	else
		SSshuttle.buy()
		SSshuttle.moving = 1
		SSshuttle.set_eta_timeofday()
	return TRUE

#undef CHECK_PERIOD
