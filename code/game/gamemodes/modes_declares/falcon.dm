#define F_FALCON_CREW        "Falcon Crew"
#define FALCON_CREWMATE      "Falcon Crewmate"

/datum/announcement/centcomm/falcon
	name = "Falcon Roundstart"
	message = "По какой-то причине нам потребовались ресурсы. Отправьте нное количество, а то уволим."

/datum/announcement/centcomm/falcon/New()
	message = pick(
		"На одной из наших станций произошло ужасное происшествие, необходимы ресурсы для восстановления.",
		"На одной из наших станций произошёл бунт, необходимо срочно возместить убытки.",
		"Наши инженеры спроектировали новый прототип блюспейс [pick(врат, артиллерии, связи)], нужны ресурсы для реализации.",
		"Наши склады пустеют, мы не собираемся терпеть убытки из-за приостановки производства.")

/datum/announcement/centcomm/falcon/play(amount, list/ores)
	message += " Добудьте и отправьте нам [amount] [ores[1]] и [ores[2]]. В случае не выполнения поставленной задачи, отсветственные за это люди будут уволены."


/datum/game_mode/falcon
	name = "Falcon"
	config_name = "falcon"
	factions_allowed = list(/datum/faction/traitor, /datum/faction/falcon_crew)
	minimum_player_count = 1

/datum/game_mode/falcon/announce()
	to_chat(world, "<B>Текущий режим игры - Шахтёрская станция Фалкон!</B>")


/datum/faction/falcon
	name = "Falcon Crew"
	ID = F_FAMILIES
	initroletype = /datum/role/falcon_crewmate
	accept_latejoiners = TRUE
	logo_state = "pickaxe"

/datum/faction/falcon/forgeObjectives()
	. = ..()
	AppendObjective(/datum/objective/mine_ore)
	var/datum/objective/mine_ore/O = locate() in GetObjectives()
	var/datum/announcement/centcomm/falcon/announcement = new(O.amount, O.ores)
	announcement.play()


/datum/role/falcon_crewmate
	name = FALCON_CREWMATE
	id = FALCON_CREWMATE
	logo_state = "pickaxe"

/datum/role/falcon_crewmate/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, {"<span class='notice'><b>Центральное Коммандование поставило станции задачу на эту смену.
Добудьте и отправьте шаттлом снабжения нужное количество руды, чтобы не вылететь со своего рабочего места.
Даже если вы не являетесь шахтёром, ваша задача - оказать посильную помощь в добыче ресурсов.
------------------</b></span>"})


/datum/objective/mine_ore
	explanation_text = "Отправьте на ЦК нное количество руды."
	var/static/possible_ores[] = list(
		"слитков золота" = /obj/item/stack/sheet/mineral/gold,
		"алмазов" = /obj/item/stack/sheet/mineral/diamond,
		"слитков платины" = /obj/item/stack/sheet/mineral/platinum,
		"слитков урана" = /obj/item/stack/sheet/mineral/uranium,
		"пластин форона" = /obj/item/stack/sheet/mineral/phoron)
	var/list/ores = list(1, 2)
	var/amount

/datum/objective/mine_ore/New()
	amount = rand(85, 90)
	ores[1] = pick(possible_ores)
	ores[2] = pick(possible_ores - ores[1])
	explanation_text = "Отправьте на ЦК [amount] [ores[1]] и [ores[2]]"

/datum/objective/mine_ore/check_completion()
	var/count = 0
	for(var/ore in ores)
		if(global.ores_sold[possible_ores[ore]] >= amount)
			count++

	switch(count)
		if(2)
			return OBJECTIVE_WIN
		if(1)
			return OBJECTIVE_HALFWIN
		if(0)
			return OBJECTIVE_LOSS
