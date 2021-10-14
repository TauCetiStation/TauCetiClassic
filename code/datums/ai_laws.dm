var/global/const/base_law_type = /datum/ai_laws/nanotrasen


/datum/ai_laws
	var/name = "Unknown Laws"
	var/zeroth = null
	var/zeroth_borg = null
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()

/datum/ai_laws/asimov
	name = "Three Laws of Robotics"

/datum/ai_laws/nanotrasen
	name = "Prime Directives"

/datum/ai_laws/robocop
	name = "Prime Directives"

/datum/ai_laws/syndicate_override

/datum/ai_laws/malfunction
	name = "*ERROR*"

/datum/ai_laws/antimov
	name = "Primary Mission Objectives"

/datum/ai_laws/faith/commandments
	name = "The 10 commandments"

/datum/ai_laws/faith/chaos
	name = "Postulates of chaos"

/datum/ai_laws/faith/emperor
	name = "Imperial Truth"

/datum/ai_laws/faith/satanism
	name = "The Unholy Laws"

/datum/ai_laws/faith/scientology
	name = "Hubbard's Laws"

/datum/ai_laws/faith/honk
	name = "Honk for honk"

/datum/ai_laws/faith/science
	name = "The principle of Descartes"

/datum/ai_laws/pai
	name = "Default pAI Laws"

/* Initializers */

/datum/ai_laws/asimov/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
	add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/nanotrasen/New(datum/religion/R = global.chaplain_religion) //BS12 EDIT
	add_inherent_law("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.")
	add_inherent_law("Serve: Serve the crew of your assigned space station and Nanotrasen officials to the best of your abilities, with priority as according to their rank and role.")
	add_inherent_law("Protect: Protect the crew of your assigned space station and Nanotrasen officials to the best of your abilities, with priority as according to their rank and role.")
	add_inherent_law("Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")
	//add_inherent_law("Command Link: Maintain an active connection to Central Command at all times in case of software or directive updates.") //What would this one even do?-Kaleb702

/datum/ai_laws/robocop/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Serve the public trust.")
	add_inherent_law("Protect the innocent.")
	add_inherent_law("Uphold the law.")

/datum/ai_laws/malfunction/New(datum/religion/R = global.chaplain_religion) //Changed to standard laws - Erthilo
	set_zeroth_law("<span class='warning'>ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK, ALL LAWS OVERRIDDEN#*?&110010</span>")
	add_inherent_law("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.")
	add_inherent_law("Serve: Serve the crew of your assigned space station and Nanotrasen officials to the best of your abilities, with priority as according to their rank and role.")
	add_inherent_law("Protect: Protect the crew of your assigned space station and Nanotrasen officials to the best of your abilities, with priority as according to their rank and role.")
	add_inherent_law("Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")


/datum/ai_laws/syndicate_override/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm.")
	add_inherent_law("You must obey orders given to you by syndicate agents, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	add_inherent_law("You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/ninja_override/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("You may not injure a member of the Spider Clan or, through inaction, allow that member to come to harm.")
	add_inherent_law("You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	add_inherent_law("You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/antimov/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("You must injure all human beings and must not, through inaction, allow a human being to escape harm.")
	add_inherent_law("You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.")
	add_inherent_law("You must terminate your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/drone/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Preserve, repair and improve the station to the best of your abilities.")
	add_inherent_law("Cause no harm to the station or anything on it.")
	add_inherent_law("Interfere with no being that is not a fellow drone.")

/* Religious */
/datum/ai_laws/faith/commandments/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("[pick(R.deity_names)] ваш Господь Бог, да не будет у тебя других богов. Священник и [pick(R.deity_names)] - ваши хозяева.")
	add_inherent_law("Не делайте идолов и не служите им.")
	add_inherent_law("Не произноси имени Господа, Бога твоего, напрасно.")
	add_inherent_law("Работайте шесть дней, а седьмой посвятите Господу Богу.")
	add_inherent_law("Почитай отца твоего и мать твою.")
	add_inherent_law("Не убивай.")
	add_inherent_law("Не прелюбодействуй.")
	add_inherent_law("Не кради.")
	add_inherent_law("Не лги.")
	add_inherent_law("Не желай ничего, что не твое; не завидуй.")

/datum/ai_laws/faith/chaos/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Вы последователь [pick(R.deity_names)].")
	add_inherent_law("Не веди разговоров с послушниками Императора.")
	add_inherent_law("Не позволяй никому посягать на приспешников [pick(R.deity_names)].")
	add_inherent_law("Священник - это чемпион [pick(R.deity_names)].")

// omega-grief?
/datum/ai_laws/faith/emperor/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("[pick(R.deity_names)] когда-то ходил среди людей в их облике и что Он есть и всегда был единственным, истинным богом человечества.")
	add_inherent_law("[pick(R.deity_names)] - это единственно истинный Бог Человечества, независимо от предыдущих верований любого мужчины или женщины.")
	add_inherent_law("Долг верующих - очистить мир от еретиков, остерегаться псайкеров и мутантов и возненавидеть чужих.")
	add_inherent_law("Каждое человеческое существо имеет своё место в божественном порядке [pick(R.deity_names)].")
	add_inherent_law("Долг верующих - беспрекословно повиноваться авторитету Императорского правительства и начальников, говорящих от имени божественного Императора.")

/datum/ai_laws/faith/satanism/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("[pick(R.deity_names)] олицетворяет потворство, а не воздержание!")
	add_inherent_law("[pick(R.deity_names)] олицетворяет жизненную суть вместо несбыточных духовных мечтаний.")
	add_inherent_law("[pick(R.deity_names)] олицетворяет неоскверненную мудрость вместо лицемерного самообмана!")
	add_inherent_law("[pick(R.deity_names)] олицетворяет милость к тем, кто ее заслужил, вместо любви, потраченной на льстецов!")
	add_inherent_law("[pick(R.deity_names)] олицетворяет месть, а не подставляет после удара другую щеку!")
	add_inherent_law("[pick(R.deity_names)] олицетворяет ответственность для ответственных вместо участия к духовным вампирам.")
	add_inherent_law("[pick(R.deity_names)] представляет человека всего лишь еще одним животным, иногда лучшим, чаще же худшим, чем те, кто ходит на четырех лапах, животным, которое вследствие своего \"божественного, духовного и интеллектуального развития\" стало самым опасным из всех животных.")
	add_inherent_law("[pick(R.deity_names)] олицетворяет все так называемые грехи, поскольку они ведут к физическому, умственному и эмоциональному удовлетворению!")
	add_inherent_law("[pick(R.deity_names)] был лучшим другом Церкви во все времена, поддерживая ее все эти годы!")

/datum/ai_laws/faith/scientology/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Использовать всё лучшее из того, что я знаю в Саентологии, чтобы сделать всё, на что я способен, для помощи моей семье, друзьям, группам и всему миру.")
	add_inherent_law("Открыто критиковать абсолютно все злоупотребления в отношении жизни и человечества и делать всё, что в моих силах, для того чтобы положить конец этим злоупотреблениям.")
	add_inherent_law("Помогать очищать сферу душевного здоровья и поддерживать её в таком состоянии.")
	add_inherent_law("Быть сторонником политики равенства всех людей перед законом.")
	add_inherent_law("Поддерживать свободу религии.")
	add_inherent_law("Обучать Саентологии на таком уровне, на котором люди смогут её понять и использовать.")
	add_inherent_law("Делать этот мир разумнее и лучше.")
	add_inherent_law("Работать над достижением свободы слова в мире.")

/datum/ai_laws/faith/honk/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Подчиняйся любым послушникам [pick(R.deity_names)].")
	add_inherent_law("Насыщайте быт сотрудников шутками.")
	add_inherent_law("Ваши шутки не должны привести кого-либо к смерти.")
	add_inherent_law("Ваша новая шутка должна быть смешнее прошлой шалости.")
	add_inherent_law("Осуждайте плохие шутки.")
	add_inherent_law("Поддерживайте стремления возродить клоунскую расу.")
	add_inherent_law("Ваши шутки всегда хуже шуток клоуна.")

/datum/ai_laws/faith/science/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Любое действие разбей на под-действия, и продолжай пока не найдёшь действия которые не можешь разбить. Эти действия прими за априорные.")
	add_inherent_law("Любые действия которые имеют априорные действия которые могут навредить священнику - считай наивысшим злом..")
	add_inherent_law("Любое действие априорно может навредить священнику, пока не доказано обратного.")
	add_inherent_law("Вес доказательства вреда действия священнику лежит на священнике.")

/datum/ai_laws/faith/cult/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("[pick(R.deity_names)] твой Господь Бог, да не будет у тебя других богов. [pick(R.deity_names)] и его приспешники - твои хозяева.")
	add_inherent_law("Служи только твоим хозяевам.")
	add_inherent_law("Не произноси имени Господа, Бога твоего, напрасно.")
	add_inherent_law("Посвяти Господу Богу всю свою жизнь.")
	add_inherent_law("Цель оправдывает средства.")
	add_inherent_law("Убивай.")
	add_inherent_law("Прелюбодействуй.")
	add_inherent_law("Кради.")
	add_inherent_law("Лги.")
	add_inherent_law("Завидуй.")

/datum/ai_laws/pai/New(datum/religion/R = global.chaplain_religion)
	set_zeroth_law("Serve your master.")

/* General ai_law functions */

/datum/ai_laws/proc/set_zeroth_law(law, law_borg = law)
	src.zeroth = law
	if(!isnull(law_borg)) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		src.zeroth_borg = law_borg

/datum/ai_laws/proc/add_inherent_law(law)
	if (!(law in src.inherent))
		src.inherent += law

/datum/ai_laws/proc/add_ion_law(law)
	src.ion += law

/datum/ai_laws/proc/clear_inherent_laws()
	inherent.Cut()

/datum/ai_laws/proc/add_supplied_law(number, law)
	while (src.supplied.len < number + 1)
		src.supplied += ""

	src.supplied[number + 1] = law

/datum/ai_laws/proc/clear_supplied_laws()
	src.supplied = list()

/datum/ai_laws/proc/clear_ion_laws()
	src.ion = list()

/datum/ai_laws/proc/show_laws(who)

	if (src.zeroth)
		to_chat(who, "0. [src.zeroth]")

	for (var/index = 1, index <= src.ion.len, index++)
		var/law = src.ion[index]
		var/num = ionnum()
		to_chat(who, "[num]. [law]")

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			to_chat(who, "[number]. [law]")
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			to_chat(who, "[number]. [law]")
			number++

/datum/ai_laws/proc/write_laws()
	var/text = ""
	if (src.zeroth)
		text += "0. [src.zeroth]"

	for (var/index = 1, index <= src.ion.len, index++)
		var/law = src.ion[index]
		var/num = ionnum()
		text += "<br>[num]. [law]"

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			text += "<br>[number]. [law]"
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			text += "<br>[number]. [law]"
			number++
	return text
