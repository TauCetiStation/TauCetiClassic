
// jedi

/datum/objective/star_wars/jedi/research
	explanation_text = "Прибудьте на станцию и исследуйте артефакт."
	completed = OBJECTIVE_WIN

/datum/objective/star_wars/jedi/convert
	explanation_text = "Необходимо позаботиться о людях, попавших под воздействие артефакта. Обучите Силе всех кого найдёте."

/datum/objective/star_wars/jedi/convert/check_completion()
	if(faction.members.len >= 6) // 2 jedi master roundstart
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/star_wars/jedi/competition
	explanation_text = {"Вы чувствуете, как тьма окутывает станцию. Кажется ситхи прознали про артефакт и смогли проникнуть сюда.
Мы не знаем сколько людей они уже успели склонить на тёмную сторону, но аура тьмы невероятно сильна.
Необходимо быть предельно осторожными и не впутывать в это обычных людей.
Нужно найти и обучить как можно больше людей с Силой. Джедаев должно быть больше, чем ситхов."}

/datum/objective/star_wars/jedi/competition/check_completion()
	var/datum/faction/sith = find_faction_by_type(/datum/faction/star_wars/sith)
	if(sith.members.len + 2 < faction.members.len)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/star_wars/jedi/escalation
	explanation_text = {"Тьма сгущается! Ситхи готовятся к атаке, джедаям необходимо собраться вместе и дать отпор тёмной заразе.
Да пребудет с нами Сила! Разгромите орден ситхов."}

/datum/objective/star_wars/jedi/escalation/check_completion()
	var/datum/faction/sith = find_faction_by_type(/datum/faction/star_wars/sith)
	var/alive_sith = 0

	for(var/mob/living/carbon/C in sith.members)
		if(C.stat == CONSCIOUS)
			alive_sith += 1

	if(alive_sith / sith.members.len < 0.2) // < 20% stay alive
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

// sith

/datum/objective/star_wars/sith/convert
	explanation_text = "Необходимо подготовить почву для захвата власти и артефакта. Обучите 6 человек тёмной стороне Силы."
	completed = OBJECTIVE_WIN

/datum/objective/star_wars/sith/convert/check_completion()
	if(faction.members.len >= 8) // 2 sith master roundstart
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/star_wars/sith/competition
	explanation_text = {"Джедаи прознали про артефакт и скоро заявятся на станцию.
Они смогли завоевать доверие НТ и в случае схватки, служба безопасности станции выступит на их стороне.
Джедаи точно попытаются взять ситуацию под контроль и начнут также обучать людей Силе.
Мы должны победить в этой гонке, не раскрывая себя. Ситхов должно быть больше, чем джедаев."}

/datum/objective/star_wars/sith/competition/check_completion()
	var/datum/faction/jedi = find_faction_by_type(/datum/faction/star_wars/jedi)
	if(jedi.members.len + 2 < faction.members.len)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/star_wars/sith/escalation
	explanation_text = {"Наше время пришло! Всем Ситхам необходимо собраться вместе и дать решительный бой джедайской заразе.
Сила есть закон! Разгромите орден джедаев."}

/datum/objective/star_wars/sith/escalation/check_completion()
	var/datum/faction/jedi = find_faction_by_type(/datum/faction/star_wars/jedi)
	var/alive_jedi = 0

	for(var/mob/living/carbon/C in jedi.members)
		if(C.stat == CONSCIOUS)
			alive_jedi += 1

	if(alive_jedi / jedi.members.len < 0.2) // < 20% stay alive
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
