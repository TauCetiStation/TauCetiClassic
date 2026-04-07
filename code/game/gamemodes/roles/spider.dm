/datum/role/spider
	name = SPIDER
	id = SPIDER

/datum/role/spider/forgeObjectives()
	. = ..()
	if(!.)
		return

	AppendObjective(/datum/objective/spider_evolve)
	AppendObjective(/datum/objective/spider_reproduce)
	AppendObjective(/datum/objective/survive)

/datum/role/spider/Greet(greeting, custom)
	. = ..()

	to_chat(antag.current, "<span class='notice'><B>Вы - космический паук.</span><BR>\
	Южный континент плачет по вам потому, что вы не на нем, а станция плачет потому, что вы на ней.<BR>\
	Сейчас вам нужно эволюционировать, а что бы это сделать - нужно выжить. Помогай своим сородичам, только что бы съесть их после смерти.<BR>\
	Используй паучьи способности через CTRL + CLICK, на полу - сплетешь паутину, на объекте - завернешь в кокон, а если завернешь труп - насытишься, тогда, нажав на паутину, ты отложишь яйца.</B>"
	)
