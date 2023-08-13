/datum/spawner/responders
	name = "Emergency Responder"
	desc = "Вы появляетесь на корабле на подходе к станции Нанотрейзен с какой-то задачей..."
	wiki_ref = "Emergency_Response_Team"

	ranks = list(ROLE_ERT, "Security Officer")
	time_to_del = 5 MINUTES


	var/outfit
	var/leader_outfit
	var/engineer_outfit
	var/medic_outfit
	var/leader_text = "Ты - Лидер!"
	var/fluff_text = "Ты летишь на помощь станции!"
	var/naming_allowed = TRUE
	var/faction = /datum/faction/responders

/datum/spawner/responders/New(mission)
	..()
	id = mission
	important_info += mission

/datum/spawner/responders/jump(mob/dead/observer/ghost)
	var/jump_to = pick(landmarks_list["Commando"])
	ghost.forceMove(get_turf(jump_to))

/datum/spawner/responders/spawn_ghost(mob/dead/observer/ghost)
	var/obj/spawnloc = pick(landmarks_list["Commando"])

	var/datum/faction/responders/R = find_faction_by_type(faction)

	var/is_leader = FALSE
	if(!R.leader_selected)
		is_leader = TRUE
		R.leader_selected = TRUE

	var/mob/living/carbon/human/M = new(null)
	if(naming_allowed)
		var/new_name = sanitize_safe(input(ghost, "Pick a name","Name") as null|text, MAX_LNAME_LEN)
		ghost.client.create_human_apperance(M, new_name)
	M.age = !R.leader_selected ? rand(M.species.min_age, M.species.min_age * 1.5) : rand(M.species.min_age * 1.25, M.species.min_age * 1.75)

	//Creates mind stuff.
	M.mind = new
	M.mind.set_current(M)
	M.mind.original = M
	M.mind.assigned_role = "MODE"
	M.mind.special_role = "Response Team"
	if(!(M.mind in SSticker.minds))
		SSticker.minds += M.mind//Adds them to regular mind list.
	M.loc = get_turf(spawnloc)

	if(is_leader && leader_outfit)
		M.equipOutfit(leader_outfit)
	else
		if(prob(20) && engineer_outfit)
			M.equipOutfit(engineer_outfit)

		else if(prob(20) && medic_outfit)
			M.equipOutfit(medic_outfit)
		else
			M.equipOutfit(outfit)

	M.mind.key = ghost.key
	M.key = ghost.key
	create_random_account_and_store_in_mind(M)

	if(R)
		add_faction_member(R, M, FALSE)
	post_spawn(M)

	to_chat(M, "Ты почти у цели...")
	if(!is_leader)
		to_chat(M, "[fluff_text]")
	else
		to_chat(M, "[leader_text]")

/datum/spawner/responders/proc/post_spawn(mob/M)
	return

/datum/spawner/responders/nt_ert
	outfit = /datum/outfit/responders/nanotrasen_ert/security
	leader_outfit = /datum/outfit/responders/nanotrasen_ert/leader
	engineer_outfit = /datum/outfit/responders/nanotrasen_ert/engineer
	medic_outfit = /datum/outfit/responders/nanotrasen_ert/medic
	leader_text = "Ты - <B>лидер</B> отряда быстрого реагирования Нанотрейзен. Задача отряда - помочь станции разобраться с любыми проблемами. Будучи лидером ОБР, ты подчиняешься только ЦК, а твои приказы приоритетнее приказов капитана станции."
	fluff_text = "Ты - боец отряда быстрого реагирования Нанотрейзен. Задача отряда - помочь станции разобраться с любыми проблемами. Будучи членом ОБР, ты подчиняешься только ЦК и лидеру ОБР, а твои приказы приоритетнее приказов глав."
	faction = /datum/faction/responders/nt_ert

/datum/spawner/responders/gorlex
	outfit = /datum/outfit/responders/gorlex_marauders
	leader_outfit = /datum/outfit/responders/gorlex_marauders/leader
	leader_text = "Ты - <B>лидер</B> патрульного отряда Мародёров Горлекса. Вы засекли сигнал бедствия от одной из станций НТ - и было бы глупо не воспользоваться предоставившимся шансом. Ваша задача - уничтожить станцию с помощью ядерной бомбы."
	fluff_text = "Ты - боец патрульного отряда Мародёров Горлекса. Вы засекли сигнал бедствия от одной из станций НТ - и было бы глупо не воспользоваться предоставившимся шансом. Ваша задача - уничтожить станцию с помощью ядерной бомбы."
	faction = /datum/faction/responders/gorlex

/datum/spawner/responders/deathsquad
	outfit = /datum/outfit/responders/deathsquad
	leader_outfit = /datum/outfit/responders/deathsquad/leader
	leader_text = "Ты - <B>лидер</B> Отряда Смерти. Закалённые ветераны множества конфликтов и зачисток, вы должны выполнить своё задание с минимумом дипломатии и максимумом кровопролития."
	fluff_text = "Ты - боец Отряда Смерти. Закалённые ветераны множества конфликтов и зачисток, вы должны выполнить своё задание с минимумом дипломатии и максимумом кровопролития."
	naming_allowed = FALSE
	faction = /datum/faction/responders/deathsquad

/datum/spawner/responders/pirates
	outfit = /datum/outfit/responders/pirate
	leader_outfit = /datum/outfit/responders/pirate/leader
	leader_text = "Яррр! Ты - <B>капитан</B> космических пиратов! Жалкие сухопутные крысы подали сигнал о помощи и должны за это расплатиться своим добром! Свистать всех наверх, сегодня грабим (но не мочим, фортуна тебя дери!) корпоратов!"
	fluff_text = "Яррр! Ты - космический пират! Жалкие сухопутные крысы подали сигнал о помощи и должны за это расплатиться своим добром! Слушайся капитана и старайся никого не прикончить!"
	naming_allowed = FALSE
	faction = /datum/faction/responders/pirates

/datum/spawner/responders/engineering
	outfit = /datum/outfit/responders/nanotrasen_ert/engineer/ect
	leader_outfit = /datum/outfit/responders/nanotrasen_ert/leader/ect
	leader_text = "Ты - <B>лидер</B> отряда Инженерного Корпуса НТ! Вы засекли сигнал бедствия от одной из станций НТ, и зная, насколько часто на них случаются разные аварии, вы решили добавить ещё одну заслугу в рапорт. Будучи лидером отряда, ты так же отвечаешь за его охрану, как самый тяжеловооруженный боец."
	fluff_text = "Ты - член отряда Инженерного Корпуса НТ! Вы засекли сигнал бедствия от одной из станций НТ, и зная, насколько часто на них случаются разные аварии, вы решили добавить ещё одну заслугу в рапорт."
	faction = /datum/faction/responders

/datum/spawner/responders/medical
	outfit = /datum/outfit/responders/nanotrasen_ert/medic/emt
	leader_outfit = /datum/outfit/responders/nanotrasen_ert/leader/emt
	medic_outfit = /datum/outfit/responders/nanotrasen_ert/medic/emt/surgeon
	leader_text = "Ты - <B>лидер</B> экстренного медицинского отряда НТ! Вы засекли сигнал бедствия от одной из станций НТ, и зная, насколько часто на них случаются разные аварии, вы решили добавить ещё одну заслугу в рапорт. Будучи лидером отряда, ты так же отвечаешь за его охрану, как самый тяжеловооруженный боец."
	fluff_text = "Ты - член экстренного медицинского отряда НТ! Вы засекли сигнал бедствия от одной из станций НТ, и зная, насколько часто на них случаются разные аварии, вы решили добавить ещё одну заслугу в рапорт."
	faction = /datum/faction/responders

/datum/spawner/responders/soviet
	outfit = /datum/outfit/responders/ussp
	leader_outfit = /datum/outfit/responders/ussp/leader
	leader_text = "Ты - <B>комиссар</B> разведвзвода СССП! Чертовы капиталисты отправили сигнал бедствия и скоро об этом пожалеют! Буржуев-глав - к стенке, а их работникам нечего терять, кроме цепей!"
	fluff_text = "Ты - солдат разведвзвода СССП! Чертовы капиталисты отправили сигнал бедствия и скоро об этом пожалеют! Буржуев-глав - к стенке, а их работникам нечего терять, кроме цепей!"
	faction = /datum/faction/responders/soviet
