// OBJECTIVES
/datum/objective/experiment
//	dangerrating = 10
	target_amount = 6
	var/team

/datum/objective/experiment/New()
	explanation_text = "Проведите [target_amount] [pluralize_russian(target_amount, "эксперимент", "эксперимента", "экспериментов")] над людьми или другими разумными расами"

/datum/objective/experiment/check_completion()
	. = OBJECTIVE_LOSS
	var/ab_team = team
	for(var/obj/machinery/abductor/experiment/E in abductor_machinery_list)
		if(E.team == ab_team)
			if(E.all_points >= target_amount)
				return OBJECTIVE_WIN

/datum/objective/experiment/long
	target_amount = 20

/datum/objective/experiment/long/check_completion()
	. = OBJECTIVE_LOSS
	var/total_points = 0
	for(var/obj/machinery/abductor/experiment/E in abductor_machinery_list)
		total_points += E.all_points
	if(total_points >= target_amount)
		return OBJECTIVE_WIN

/datum/objective/abductee
	completed = OBJECTIVE_WIN

/datum/objective/abductee/steal
	explanation_text = "Похитьте "

/datum/objective/abductee/steal/New()
	var/target = pick(list("питомцев","лампочки","обезьян","фрукты","обувь","мыло"))
	explanation_text += " [target]."

/datum/objective/abductee/capture
	explanation_text = "Захватите "

/datum/objective/abductee/capture/New()
	var/list/target_jobs = list()
	for(var/datum/job/J as anything in SSjob.active_occupations)
		if(J.current_positions >= 1)
			target_jobs += J
	if(length(target_jobs))
		var/datum/job/target = pick(target_jobs)
		explanation_text += " [target.title]."
	else
		explanation_text += " кого-нибудь."

/datum/objective/abductee/shuttle
	explanation_text = "Вы должны сбежать со станции.! Сделайте так, чтобы был вызван шаттл!"

/datum/objective/abductee/noclone
	explanation_text = "Не позволяйте никому вас клонировать."

/datum/objective/abductee/blazeit
	explanation_text = "Ваше тело должно быть улучшено. Употребите как можно больше лекарств."

/datum/objective/abductee/yumyum
	explanation_text = "Вы голодны. Съешьте столько еды, сколько сможете найти..."

/datum/objective/abductee/insane
	explanation_text = "Ты видишь, ты видишь то, что они не видят, ты видишь открытую дверь, ты ВидИимиишь, ТЫ ВИДИШЬ, ты види~и~и~ишь~, Т Ы  В И Д И Ш Ь"
	explanation_text = " Убедите команду, что вы паралитик."

/datum/objective/abductee/deadbodies
	explanation_text = "Начните собирать коллекцию трупов. Не убивайте людей, чтобы получить эти трупы."

/datum/objective/abductee/floors
	explanation_text = "Замените всю напольную плитку ковровым покрытием, деревянными досками или травой.."

/datum/objective/abductee/powerunlimited
	explanation_text = "Наполните электросеть станции как можно большим количеством электроэнергии."

/datum/objective/abductee/pristine
	explanation_text = "Убедитесь, что станция находится в абсолютно безупречном состоянии."

/datum/objective/abductee/window
	explanation_text = "Замените все обычные окна на укреплённые."

/datum/objective/abductee/nations
	explanation_text = "Обеспечьте процветание вашего отдела."

/datum/objective/abductee/abductception
	explanation_text = "Ты изменился навсегда. Найди тех, кто сделал это с тобой, и дай им попробовать их собственное лекарство."

/datum/objective/abductee/ghosts
	explanation_text = "Проведите спиритический сеанс с духами из загробного мира."

/datum/objective/abductee/summon
	explanation_text = "Проведите ритуал призыва бога."

/datum/objective/abductee/machine
	explanation_text = "Вы — тайный андроид. Взаимодействуйте с как можно большим количеством машин, чтобы увеличить свою мощь."

/datum/objective/abductee/prevent
	explanation_text = "Вы смогли достичь просветления. Это знание не должно быть раскрыто. Убедитесь, что никто другой не сможет достичь просветления."

/datum/objective/abductee/calling
	explanation_text = "Призови духа с потустороннего мира."

/datum/objective/abductee/calling/New()
	var/mob/dead/D = pick(dead_mob_list)
	if(D)
		explanation_text = "Вы знаете, что [D] погиб. Призовите их из духовного мира."

/datum/objective/abductee/social_experiment
	explanation_text = "Это секретный социальный эксперимент, проводимый НаноТрейзен. Убедите экипаж станции, что это правда."

/datum/objective/abductee/vr
	explanation_text = "Всё это — полностью виртуальная симуляция в подземном хранилище. Убедите команду освободиться от оков виртуальной реальности."

/datum/objective/abductee/pets
	explanation_text = "НаноТрейзен издевается над животными! Спасите их как можно больше!"

/datum/objective/abductee/defect
	explanation_text = "Устраните все недостатки вашего работодателя."

/datum/objective/abductee/promote
	explanation_text = "Поднимитесь по корпоративной лестнице до самого верха!"

/datum/objective/abductee/science
	explanation_text = "Так много нераскрытого. Загляните глубже в механизмы вселенной и раскройте её тайны."

/datum/objective/abductee/build
	explanation_text = "Расширьте границы станции."

/datum/objective/abductee/pragnant
	explanation_text = "Вы беременны и скоро родите. Найдите безопасное место для родов."
