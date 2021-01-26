/*

Infestation:

*/

/*
	GAMEMODE
*/
/datum/game_mode

	var/list/datum/mind/xenomorphs = list()

/datum/game_mode/infestation
	name = "infestation"
	config_tag = "infestation"
	role_type = ROLE_ALIEN
	required_players = 20
	required_players_bundles = 15
	required_enemies = 2
	recommended_enemies = 4

	votable = 0

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

/datum/game_mode/proc/count_hive_power()
	var/count = 0
	for(var/mob/living/carbon/xenomorph/A in alien_list)
		if(A.stat == DEAD)
			continue
		count++
	return count

/datum/game_mode/proc/count_hive_looses()
	var/count = 0
	for(var/mob/living/carbon/xenomorph/A in alien_list)
		if(A.stat != DEAD)
			continue
		count++
	return count

/datum/game_mode/proc/auto_declare_completion_infestation()
	var/text =""
	if(xenomorphs.len)
		if(check_xeno_queen())
			if(check_xeno_queen() == 1)
				text += "<span style='color: green; font-weight: bold;'>The Queen is alive!</span>"
			if(check_xeno_queen() == 2)
				text += "<span style='color: red; font-weight: bold;'>The Queen has been killed!</span>"
		else
			text += "<span style='color: orange; font-weight: bold;'>The Queen was never born.</span>"
		if(count_hive_power())
			text += "<span style='color: green; font-weight: bold;'>There is [count_hive_power()] xenomorphs alive!</span>"
		else
			text += "<span style='color: red; font-weight: bold;'>All xenomorphs were eradicated.</span>"
		if(count_hive_looses())
			text += "<span style='color: red; font-weight: bold;'>[count_hive_looses()] xenomorphs are dead.</span>"

	if(text)
		antagonists_completion += list(list("mode" = "infestation", "html" = text))
		text = "<div class='Section'>[text]</div>"

	return text
