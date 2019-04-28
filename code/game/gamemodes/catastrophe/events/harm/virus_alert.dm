// probably the most simplest event, you can use this one as a template
/datum/catastrophe_event/virus_alert
	name = "Virus alert"

	one_time_event = TRUE

	weight = 100

	event_type = "harmful"
	steps = 4

/datum/catastrophe_event/virus_alert/on_step()
	switch(step)
		if(1)
			announce("Добрый день, Исход. На св[JA_PLACEHOLDER]зи оператор корпорации Вэй Мед. Приносим извинени[JA_PLACEHOLDER] за подключение к вашей сети коммуникаций. Сегодн[JA_PLACEHOLDER] стало известно о нескольких вирусных вспышках на Марсе, ситуаци[JA_PLACEHOLDER] под контролем но часть вашего персонала могла быть подвергнута угрозе заражени[JA_PLACEHOLDER]. Первые отчёты говор[JA_PLACEHOLDER]т о том, что эти вирусы не представл[JA_PLACEHOLDER]ют большой угрозы, но мы просим вас отнестись к этому предупреждению с пониманием и провести необходимые проверки")
			infect_n_people(rand(2, 3), "lesser")
		if(2)
			announce("Ещё раз добрый день, Исход. На св[JA_PLACEHOLDER]зи оператор корпорации Вэй Мед. Ситуаци[JA_PLACEHOLDER] осложн[JA_PLACEHOLDER]етс[JA_PLACEHOLDER]. Вирус мутировал, на Марсе по[JA_PLACEHOLDER]вились первые случаи с летальным исходом. По нашей информации заражен примерно каждый дес[JA_PLACEHOLDER]тый.  Вам необходимо ввести карантин и изолировать больных до по[JA_PLACEHOLDER]влени[JA_PLACEHOLDER] вакцины. Природа вируса неизвестна. Нанотрейзен пока не дает разрешение нашим специалистам обследовать вашу станцию. Поэтому повтор[JA_PLACEHOLDER]ю ещё раз, немедленно объ[JA_PLACEHOLDER]вите карантин и не дайте этой заразе распространитьс[JA_PLACEHOLDER], Исход")
			infect_n_people(rand(2, 5), "greater")
		if(3)
			announce("На св[JA_PLACEHOLDER]зи оператор корпорации Вэй Мед. Исход, у нас больша[JA_PLACEHOLDER] проблема. Один из штаммов вируса мутировал настолько, что теперь не убивает организм, а перестраивает его. Лабораторные тесты демонстрируют следующие симптомы: слабость, тошнота и желание одиночества. Через некоторое врем[JA_PLACEHOLDER] полна[JA_PLACEHOLDER] остановка всех жизненных функций и затем их частичное восстановление. Такие больные про[JA_PLACEHOLDER]вл[JA_PLACEHOLDER]ют крайнюю агрессию и склонность к каннибализму, не чувствуют боли и нападают на любого не зараженного человека. Лечение и реабилитаци[JA_PLACEHOLDER] невозможны по причине необратимого повреждени[JA_PLACEHOLDER] ЦНС. У нас есть подозрение, что один из членов вашего экипажа может быть заражен таким вирусом. Немедленно найдите нулевого пациента и изолируйте как можно быстрее")
			infect_n_people(1, "slowzombie")
		if(4)
			announce("Вэй Мед на св[JA_PLACEHOLDER]зи. Ситуаци[JA_PLACEHOLDER] вышла из-под контрол[JA_PLACEHOLDER], Исход! Повсюду в данный момент зараженные нападают на мирное население. На Марсе объ[JA_PLACEHOLDER]влено военное положение, но арми[JA_PLACEHOLDER] не справл[JA_PLACEHOLDER]етс[JA_PLACEHOLDER]. Верхушка власти, в том числе и совет директоров НТ, попыталась эвакуироватьс[JA_PLACEHOLDER], но солдаты из оцеплени[JA_PLACEHOLDER] расстрел[JA_PLACEHOLDER]ли их у космопорта. Если вы следовали моим советам, то у вас есть шанс, станци[JA_PLACEHOLDER]. Дл[JA_PLACEHOLDER] Марса это конец. Господи спаси нас.")
			infect_n_people(3, "fastzombie")

/datum/catastrophe_event/virus_alert/proc/infect_n_people(need_to_infect, infect_type)
	var/list/possible = list()

	for(var/mob/living/carbon/human/H in player_list)
		if(!H.virus2.len)
			possible += H

	while(possible.len && need_to_infect > 0)
		var/mob/living/carbon/human/H = pick(possible)
		possible -= H
		need_to_infect -= 1

		switch(infect_type)
			if("lesser")
				infect_mob_random_lesser(H)
			if("greater")
				infect_mob_random_greater(H)
			if("slowzombie")
				H.infect_zombie_virus(target_zone = null, forced = TRUE, fast = FALSE)
			if("fastzombie")
				H.infect_zombie_virus(target_zone = null, forced = TRUE, fast = TRUE)

		message_admins("[key_name_admin(H)] was infected with [infect_type] virus by the gamemode [ADMIN_JMP(H)]")