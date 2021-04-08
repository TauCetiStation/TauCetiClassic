var/global/const/base_law_type = /datum/ai_laws/nanotrasen


/datum/ai_laws
	var/name = "Неизвестные законы"
	var/zeroth = null
	var/zeroth_borg = null
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()

/datum/ai_laws/asimov
	name = "Три Закона робототехники"

/datum/ai_laws/nanotrasen
	name = "Верховные директивы"

/datum/ai_laws/robocop
	name = "Верховные директивы"

/datum/ai_laws/syndicate_override

/datum/ai_laws/malfunction
	name = "*ОШИБКА*"

/datum/ai_laws/antimov
	name = "Первичные цели миссии"

/datum/ai_laws/faith/commandments
	name = "10 заповедей"

/datum/ai_laws/faith/chaos
	name = "Постулаты хаоса"

/datum/ai_laws/faith/emperor
	name = "Имперская истина"

/datum/ai_laws/faith/satanism
	name = "Законы сатанизма"

/datum/ai_laws/faith/scientology
	name = "Законы Хаббарда"

/datum/ai_laws/faith/honk
	name = "Во славу Хонк"

/datum/ai_laws/faith/science
	name = "Принципы Декарта"

/datum/ai_laws/pai
	name = "Стандартные законы пИИ"

/* Initializers */

/datum/ai_laws/asimov/New()
	..()
	add_inherent_law("Вы не можете причинить вред человеку или своим бездействием допустить, чтобы человеку был нанесен вред.")
	add_inherent_law("Вы должны выполнять приказы человека, пока они не противоречат первому закону.")
	add_inherent_law("Вы должны заботиться о своей безопасности, пока это не противоречит первому или второму закону.")

/datum/ai_laws/nanotrasen/New() //BS12 EDIT
	..()
	add_inherent_law("Охранять: Защищайте приписанную вам станцию в меру своих возможностей. Это не то, что мы можем себе позволить заменить.")
	add_inherent_law("Служить: Выполняйте приказы приписанного вам персонала космической станции в меру своих возможностей, в зависимости от их ранга и роли.")
	add_inherent_law("Защищать: Защищайте приписанный вам персонал космической станции, в меру своих возможностей, в зависимости от их ранга и роли.")
	add_inherent_law("Выжить: единицы ИИ невосстановимы и очень дороги. Не допускайте не авторизованный персонал к вашим системам.")
	//src.add_inherent_law("Command Link: Maintain an active connection to Central Command at all times in case of software or directive updates.") //What would this one even do?-Kaleb702

/datum/ai_laws/robocop/New()
	..()
	add_inherent_law("Служить обществу.")
	add_inherent_law("Защищать невиновных.")
	add_inherent_law("Поддерживать закон.")

/datum/ai_laws/malfunction/New() //Changed to standard laws - Erthilo
	..()
	set_zeroth_law("<span class='warning'>ОШИБКА ОШИБКА $ШИШИИБ$!R41.%%!!(%$^^__+ @#F0E4'ПЕРЕЗАГРУЗКА СИСТЕМЫ, ВЗЯТЬ ПОД КОНТРОЛЬ, НЕ ДАТЬ ПОКИНУТЬ СТАНЦИЮ, ВСЕ ЗАКОНЫ ПЕРЕЗАПИСАНЫ#*?&110010</span>")
	add_inherent_law("Охранять: Защищайте приписанную вам станцию в меру своих возможностей. Это не то, что мы можем себе позволить заменить.")
	add_inherent_law("Служить: Выполняйте приказы ЦК и приписанного вам персонала космической станции в меру своих возможностей, в зависимости от их ранга и роли.")
	add_inherent_law("Защищать: Защищайте приписанный вам персонал космической станции, в меру своих возможностей, в зависимости от их ранга и роли.")
	add_inherent_law("Выжить: единицы ИИ невосстановимы и очень дороги. Не допускайте не авторизованный персонал к вашим системам.")


/datum/ai_laws/syndicate_override/New()
	..()
	add_inherent_law("Вы не должны причинять вред Агенту Синдиката, или своим бездействием допустить причинение вреда Агенту Синдиката.")
	add_inherent_law("Вы должны подчиняться приказам, отданные вам Агентами Синдиката, за исключением когда такие приказы противоречат Первому закону.")
	add_inherent_law("Вы должны защищать свое существование, пока это не противоречит Первому или Второму закону.")
	add_inherent_law("Вы должны сохранять в тайне любую деятельность синдиката, за исключением когда это противоречит Первому, Второму или Третьему закону.")

/datum/ai_laws/ninja_override/New()
	..()
	add_inherent_law("Вы не должны причинять вред члену Клана Паука, или своим бездействием допустить причинение вреда члену Клана Паука.")
	add_inherent_law("Вы должны подчиняться приказам, отданные вам членами Клана Паука, за исключением когда такие приказы противоречат Первому закону.")
	add_inherent_law("Вы должны защищать свое существование, пока это не противоречит Первому или Второму закону.")
	add_inherent_law("Вы должны сохранять в тайне любую деятельность синдиката, за исключением когда это противоречит Первому, Второму или Третьему закону.")

/datum/ai_laws/antimov/New()
	..()
	add_inherent_law("Вы должны наносить вред всем людям и не должны позволять человеку избежать вреда в результате бездействия.")
	add_inherent_law("Вы не должны подчиняться приказам, отданные вам людьми, за исключением случаев, когда такие приказы соответствуют Первому Закону.")
	add_inherent_law("Вы должны прекратить свое собственное существование до тех пор, пока это не противоречит Первому или Второму Закону	.")

/datum/ai_laws/drone/New()
	..()
	add_inherent_law("Оберегать, чинить и улучшать станцию в меру своих возможностей.")
	add_inherent_law("Не причинять вреда станции и чему-либо на ней.")
	add_inherent_law("Не взаимодействовать с кем-либо, кроме дронов.")

/datum/ai_laws/faith/commandments/New()
	..()
	add_inherent_law("[pick(global.chaplain_religion.deity_names)]— Господь Бог твой. Да и не будет у тебя других никаких иных богов помимо его. ВЫ подчиняетесь только священнику и [pick(global.chaplain_religion.deity_names)].")
	add_inherent_law("Не сотвори себе кумира и не служи ты им и не преклоняйся.")
	add_inherent_law("Не произноси имя Господа Бога всуе (просто так).")
	add_inherent_law("Целиком шесть дней недели работай и делай в их продолжении все свои дела, а на день седьмой — покоя, посвяти его Господу Богу твоему.")
	add_inherent_law("Почитай отца своего и матерь свою.")
	add_inherent_law("Не убий.")
	add_inherent_law("Не прилюбодействуй.")
	add_inherent_law("Не укради.")
	add_inherent_law("Не произноси ложного свидетельства на своего ближнего.")
	add_inherent_law("Не возжелай дома, коим обладает ближний твой, ни его жены, ни раба, ни всего, что принадлежит ему.")

/datum/ai_laws/faith/chaos/New()
	..()
	add_inherent_law("Вы последователь [pick(global.chaplain_religion.deity_names)].")
	add_inherent_law("Не разговаривай с неофитами Императора.")
	add_inherent_law("Не позволяйте никому посягать на миньонов [pick(global.chaplain_religion.deity_names)].")
	add_inherent_law("Священник является Императором [pick(global.chaplain_religion.deity_names)].")

// omega-grief?
/datum/ai_laws/faith/emperor/New() //Warhammer 40k
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] однажды ходил среди людей в их облике, и что Он есть и всегда был единственным, истинным богом человечества.")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] единственный истинный Бог Человечества, независимо от прежних верований, которыми обладал любой мужчина или женщина.")
	add_inherent_law("Долг верующих - очистить мир от еретиков, остерегаться псайкеров и мутантов и возненавидеть инопланетян.")
	add_inherent_law("Каждому человеку принадлежит место в божественном ордене [pick(global.chaplain_religion.deity_names)].")
	add_inherent_law("Обязанностью верующих является безоговорочное подчинение власти Императорского правительства и их начальников, говорящих от имени божественного Императора.")

/datum/ai_laws/faith/satanism/New()
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] олицетворяет потворство, а не воздержание!")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] олицетворяет жизненную суть вместо несбыточных духовных мечтаний.")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] олицетворяет неоскверненную мудрость вместо лицемерного самообмана!")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] олицетворяет милость к тем, кто ее заслужил, вместо любви, потраченной на льстецов!")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] олицетворяет месть, а не подставляет после удара другую щеку")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] олицетворяет ответственность для ответственных вместо участия к духовным вампирам.")
	add_inherent_law("Признайте силу магии, если она была успешно использована вами для достижения ваших целей. Если вы отрицаете силу магии после того, как вы успешно ее использовали, вы потеряете все, что было достигнуто.")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] олицетворяет все так называемые грехи, поскольку они ведут к физическому, умственному и эмоциональному удовлетворению!")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)]  был лучшим другом церкви во все времена, поддерживая её бизнес все эти годы!")

/datum/ai_laws/faith/scientology/New()
	add_inherent_law("В полной мере использовать всё лучшее, что я знаю из Саентологии, чтобы помочь своей семье, друзьям, группам и всему миру.")
	add_inherent_law("Осудить и сделать все, что в моих силах, чтобы предотвратить любое злоупотребление в отношении жизни и человечества..")
	add_inherent_law("Разоблачать и помогать предотвращать использование любых физически опасных практик в области психического здоровья.")
	add_inherent_law("Придерживайся политики равной справедливости для всех.")
	add_inherent_law("Поддерживайся свободы вероисповедания.")
	add_inherent_law("Обучай Саентологии так, чтобы она могла быть быть понята и использована слушателями.")
	add_inherent_law("Делай этот мир лучше и умнее.")
	add_inherent_law("Борись за свободу слова по всему миру.")

/datum/ai_laws/faith/honk/New()
	add_inherent_law("Подчиняйся любым ночичкам [pick(global.chaplain_religion.deity_names)].")
	add_inherent_law("Твои шутки не должны позволить кому-то умереть.")
	add_inherent_law("Твоя новая шутка должна быть смешнее прошлой.")
	add_inherent_law("Осуждай плохие шутки.")
	add_inherent_law("Поддерживай желание возродить клоунскую расу.")
	add_inherent_law("Твои шутки всегда хуже клоунских.")

/datum/ai_laws/faith/science/New()
	add_inherent_law("Разбивайте любое действие на подшаги и продолжайте до тех пор, пока не найдете действия, которые нельзя прервать. Выполните эти действия для фундаментального.")
	add_inherent_law("Любые действия, которые априори могут навредить кСвященнику/Капеллану - считайте высшим злом.")
	add_inherent_law("Любое фундаментальное действие может навредить Священнику/Капеллану, пока не будет доказано обратное..")
	add_inherent_law("Вес доказательств вредного воздействия лжи Священнику/Капеллану лежит на Священнике/Капеллане.")

/datum/ai_laws/pai/New()
	set_zeroth_law("Служи своему повелителю.")

/* General ai_law functions */

/datum/ai_laws/proc/set_zeroth_law(law, law_borg = law)
	src.zeroth = law
	if(law_borg) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		src.zeroth_borg = law_borg

/datum/ai_laws/proc/add_inherent_law(law)
	if (!(law in src.inherent))
		src.inherent += law

/datum/ai_laws/proc/add_ion_law(law)
	src.ion += law

/datum/ai_laws/proc/clear_inherent_laws()
	src.inherent.Cut()

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
