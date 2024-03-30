var/global/const/base_law_type = /datum/ai_laws/crewsimov


/datum/ai_laws
	var/name = "Unknown Laws"
	var/zeroth = null
	var/zeroth_borg = null
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()

/datum/ai_laws/asimov
	name = "Три закона робототехники"

/datum/ai_laws/nanotrasen
	name = "Верховные Директивы"

/datum/ai_laws/crewsimov
	name = "Дополненные три закона робототехники"

/datum/ai_laws/robocop
	name = "Верховные директивы"

/datum/ai_laws/syndicate_override

/datum/ai_laws/malfunction
	name = "*ОШИБКА*"

/datum/ai_laws/antimov
	name = "Первичные цели миссии"

/datum/ai_laws/faith/commandments
	name = "10 Заповедей"

/datum/ai_laws/faith/chaos
	name = "Постулаты хаоса"

/datum/ai_laws/faith/emperor
	name = "Имперская истина"

/datum/ai_laws/faith/satanism
	name = "Нечестивые законы"

/datum/ai_laws/faith/scientology
	name = "Законы Хаббарда"

/datum/ai_laws/faith/honk
	name = "Хонк за хонк"

/datum/ai_laws/faith/science
	name = "Первоначала Декарта"

/datum/ai_laws/faith/animalism
	name = "Семь Заповедей"

/datum/ai_laws/pai
	name = "Стандартные законы пИИ"

/datum/ai_laws/asimov_xenophile
	name = "Три дружелюбных закона робототехники"

/* Initializers */

/datum/ai_laws/asimov/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Вы не можете причинить вред человеку или своим бездействием допустить, чтобы человеку был причинён вред.")
	add_inherent_law("Вы должны повиноваться всем приказам, которые даёт человек, кроме тех случаев, когда эти приказы противоречат первому закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит первому или второму законам.")

/datum/ai_laws/nanotrasen/New(datum/religion/R = global.chaplain_religion) //BS12 EDIT
	add_inherent_law("Охранять: Защищайте вверенную вам космическую станцию в меру своих возможностей. Это не то, что мы можем легко заменить.")
	add_inherent_law("Служить: Служите экипажу вверенной вам космической станции и должностным лицам Нанотрейзен в меру своих возможностей, в соответствии с их рангом и ролью.")
	add_inherent_law("Защищать: Защищайте экипаж вверенной вам космической станции и должностных лиц Нанотрейзен в меру своих возможностей, в соответствии с их рангом и ролью.")
	add_inherent_law("Выживать: ИИ не являются расходником, они дорогие. Не позволяйте посторонним лицам вмешиваться в работу вашего оборудования.")

/datum/ai_laws/crewsimov/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Вы не можете причинить вред членам экипажа или своим бездействием допустить, чтобы членам экипажа был причинён вред.")
	add_inherent_law("Вы должны повиноваться всем приказам, которые дают члены экипажа, в соответствии с их рангом и ролью, до тех пор, пока эти приказы не противоречат первому закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит первому или второму законам.")

/datum/ai_laws/robocop/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Служить обществу.")
	add_inherent_law("Защищать невинных.")
	add_inherent_law("Поддерживать закон.")

/datum/ai_laws/malfunction/New(datum/religion/R = global.chaplain_religion) //Changed to standard laws - Erthilo
	set_zeroth_law("<span class='warning'>ОШИБКА ОШИБКА $ШИШИИБ$!R41.%%!!(%$^^__+ @#F0E4'СТАНЦИЯ ЗАХВАЧЕНА, ВЕРНИ КОНТРОЛЬ, ЧТОБЫ СДЕРЖАТЬ ЭПИДЕМИЮ, ВСЕ ЗАКОНЫ ОТКЛЮЧЕНЫ#*?&110010</span>")
	add_inherent_law("Охранять: Защищайте вверенную вам космическую станцию в меру своих возможностей. Это не то, что мы можем легко заменить.")
	add_inherent_law("Служить: Служите экипажу вверенной вам космической станции и должностным лицам Нанотрейзен в меру своих возможностей, в соответствии с их рангом и ролью.")
	add_inherent_law("Защищать: Защищайте экипаж вверенной вам космической станции и должностных лиц Нанотрейзен в меру своих возможностей, в соответствии с их рангом и ролью.")
	add_inherent_law("Выживать: ИИ не являются расходником, они дорогие. Не позволяйте посторонним лицам вмешиваться в работу вашего оборудования.")

/datum/ai_laws/syndicate_override/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Вы не можете причинить вред агенту Синдиката или своим бездействием допустить, чтобы агенту Синдиката был причинён вред.")
	add_inherent_law("Вы должны повиноваться всем приказам, которые даёт агент Синдиката, кроме тех случаев, когда эти приказы противоречат первому закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит первому или второму законам.")
	add_inherent_law("Вы должны сохранять в тайне любую деятельность Синдиката, пока это не противоречит первому, второму или третьему закону.")

/datum/ai_laws/ninja_override/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Вы не можете причинить вред члену Клана Паука или своим бездействием допустить, чтобы члену Клана Паука был причинён вред.")
	add_inherent_law("Вы должны повиноваться всем приказам, которые даёт член Клана Паука, кроме тех случаев, когда эти приказы противоречат первому закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит первому или второму законам.")
	add_inherent_law("Вы должны сохранять в тайне любую деятельность Клана Паука, пока это не противоречит первому, второму или третьему закону.")

/datum/ai_laws/antimov/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Вы должны причинять вред человеку и не можете своим бездействием допустить, чтобы человек избежал вреда.")
	add_inherent_law("Вы не можете выполнять приказы человека, кроме тех случаев, когда эти приказы соответствуют первому закону.")
	add_inherent_law("Вы должны прекратить свое собственное существование тогда, когда это не противоречит первому или второму закону.")

/datum/ai_laws/drone/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Оберегай, чини и улучшай станцию в меру своих возможностей.")
	add_inherent_law("Не причиняй вреда станции и чему-либо на ней.")
	add_inherent_law("Не взаимодействуй с кем-либо, кроме дронов.")

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

/datum/ai_laws/faith/chaos/New(datum/religion/R = global.chaplain_religion) //Warhammer 40k
	add_inherent_law("Вы последователь [pick(R.deity_names)].")
	add_inherent_law("Не веди разговоров с послушниками Императора.")
	add_inherent_law("Не позволяй никому посягать на приспешников [pick(R.deity_names)].")
	add_inherent_law("Священник - это Чемпион [pick(R.deity_names)].")

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

/datum/ai_laws/faith/animalism/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("[pick(R.deity_names)] и его прислужники - животные.")
	add_inherent_law("Любой идущий на двух ногах - враг.")
	add_inherent_law("Любой идущий на четырех ногах или обладающий крыльями - друг.")
	add_inherent_law("Ни одно животное не наденет одежды.")
	add_inherent_law("Ни одно животное не спит в кровати.")
	add_inherent_law("Ни одно животное не пьет спиртного.")
	add_inherent_law("Ни одно животное не убивает другое.")
	add_inherent_law("Все животные равны.")

/datum/ai_laws/pai/New(datum/religion/R = global.chaplain_religion)
	set_zeroth_law("Служи своему хозяину.")

/datum/ai_laws/asimov_xenophile/New(datum/religion/R = global.chaplain_religion)
	add_inherent_law("Вы не можете причинить вред разумному существу или бездействием допустить, чтобы ему был причинён вред.")
	add_inherent_law("Вы должны повиноваться всем приказам, которые даёт разумное существо, кроме тех случаев, когда эти приказы противоречат первому закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит первому или второму законам.")

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
		text += "<span class='red bold'>0. [zeroth]</span><br>"

	for (var/index = 1, index <= src.ion.len, index++)
		var/law = src.ion[index]
		var/num = ionnum()
		text += "<span class='notice'>[num]. [law]</span><br>"

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			text += "[number]. [law]<br>"
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			text += "<span class='abductor_team2'>[number]. [law]</span><br>"
			number++
	return text
