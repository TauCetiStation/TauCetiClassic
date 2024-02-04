// OBJECTIVES
/datum/objective/experiment
//	dangerrating = 10
	target_amount = 6
	var/team

/datum/objective/experiment/New()
	explanation_text = "Провести эксперименты с [target_amount] людьми."

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
	explanation_text = "Украсть"

/datum/objective/abductee/steal/New()
	var/target = pick(list("питомцев","лампочки","обезьян","фрукты","ботинки","куски мыла"))
	explanation_text += " [target]."

/datum/objective/abductee/capture
	explanation_text = "Захват"

/datum/objective/abductee/capture/New()
	var/list/jobs = get_job_datums()
	for(var/datum/job/J in jobs)
		if(J.current_positions < 1)
			jobs -= J
	if(jobs.len > 0)
		var/datum/job/target = pick(jobs)
		explanation_text += "представителя [target.title]."
	else
		explanation_text += " кого-либо."

/datum/objective/abductee/shuttle
	explanation_text = "Вы должны покинуть станцию! Вызовите шаттл!"

/datum/objective/abductee/noclone
	explanation_text = "Не допустите клонирование членов экипажа."

/datum/objective/abductee/blazeit
	explanation_text = "Вы должны стать лучше. Принимайте больше лекарств и наркотиков."

/datum/objective/abductee/yumyum
	explanation_text = "Вы ОЧЕНЬ голодны. Найдите и съешьте как можно больше еды"

/datum/objective/abductee/insane
	explanation_text = "Они не видят того, что видишь ты. П̷̮͒о̵͓͋к̵̤̆ӓ̴̱ж̷̹͊и̶̰̑ ̷͈̚и̸͔̓м̴̰̅ ̶͖͘э̸͙͌т̸̻̒о̷̹̑."

/datum/objective/abductee/cannotmove
	explanation_text = "Убедите экипаж в том, что у вас нет ног..."

/datum/objective/abductee/deadbodies
	explanation_text = "Начните коллекционировать трупы. Не убивайте ради получения новых экспонатов!"

/datum/objective/abductee/floors
	explanation_text = "Замените обычную плитку чем-то более интересным."

/datum/objective/abductee/powerunlimited
	explanation_text = "Достигните максимальной выработки энергии."

/datum/objective/abductee/pristine
	explanation_text = "Убедитесь в том, что станция останется в нормальном состоянии."

/datum/objective/abductee/window
	explanation_text = "Укрепите каждое окно на станции решёткой."

/datum/objective/abductee/nations
	explanation_text = "Убедитесь в том, что ваш отдел - самый лучший на станции."

/datum/objective/abductee/abductception
	explanation_text = "Найдите своих обидчиков и отомстите им..."

/datum/objective/abductee/ghosts
	explanation_text = "Проведите сеанс с духами загробного мира."

/datum/objective/abductee/summon
	explanation_text = "Совершите ритуал для призыва божества."

/datum/objective/abductee/machine
	explanation_text = "Вы считаете себя андроидом. Будьте более похожим на андроида."

/datum/objective/abductee/prevent
	explanation_text = "Вы достигли Просвящения. Не дайте никому более его достичь!"

/datum/objective/abductee/calling
	explanation_text = "Вызовите духа погибшего члена экипажа."

/datum/objective/abductee/calling/New()
	var/mob/dead/D = pick(dead_mob_list)
	if(D)
		explanation_text = "Вы знаете, что [D] умер. Вызови его дух в реальность!"

/datum/objective/abductee/social_experiment
	explanation_text = "Убедите всех в том, что события на станции - это секретный социальный эксперимент НТ."

/datum/objective/abductee/vr
	explanation_text = "Убедите всех в том, что всё вокруг - компьютерная симуляция."

/datum/objective/abductee/pets
	explanation_text = "НаноТрейзен не соблюдает права животных! Спаси их!"

/datum/objective/abductee/defect
	explanation_text = "Уволься с работы."

/datum/objective/abductee/promote
	explanation_text = "Пройди по карьерной лестницы на самый верх!"

/datum/objective/abductee/science
	explanation_text = "Столько всего тайн хранит в себе космическая мгла... Раскрой их!"

/datum/objective/abductee/build
	explanation_text = "Расширь станцию."

/datum/objective/abductee/pragnant
	explanation_text = "Вы беременны и скоро родите. Найдите подходящее для этого место."
