/datum/role/prop
	name = PROP
	id = PROP
	disallow_job = TRUE

	logo_state = "change-logoa"

/datum/role/prop/Greet(greeting, custom)
	. = ..()
	to_chat(antag.current, "Вы - аморфное существо, которое способно превращаться в любой предмет.")
	to_chat(antag.current, "Пользуйтесь этим, чтобы выполнить цели.")
	to_chat(antag.current, "Чтобы превратиться в предмет выберите Help-intent, а чтобы бить любой другой.")
