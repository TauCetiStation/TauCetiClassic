/obj/item/weapon/implant/mindshield
	name = "mindshield implant"
	desc = "Protects against brainwashing."

/obj/item/weapon/implant/mindshield/get_data()
	var/dat = {"<b>Характеристики импланта:</b><BR>
				<b>Название:</b> Имплант Контроля Сотрудников НаноТрайзен.<BR>
				<b>Время жизни:</b> Десять лет.<BR>
				<b>Важные примечания:</b> Повышает устойчивость носителя к промывке мозгов и пропаганде.<BR>
				<HR>
				<b>Детали:</b><BR>
				<b>Функции:</b> Содержит капсулу наноботов, защищающих психическое состояние носителя от манипуляций.<BR>
				<b>Особые возможности:</b> Откат и защита от большинства видов промывки мозгов и пропаганды.<BR>
				<b>Надежность:</b> Имплант прослужит до тех пор, пока наноботы находятся в кровеносной системе носителя."}
	return dat

/obj/item/weapon/implant/mindshield/implanted(mob/M)
	if(!ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	if(H.mind && (H.mind in (SSticker.mode.head_revolutionaries)) || is_shadow_or_thrall(H)|| H.mind.special_role == "Wizard")
		M.visible_message("<span class='warning'>[M] seems to resist the implant!</span>", "<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
		return FALSE

	if(H.mind && (H.mind in SSticker.mode.revolutionaries))
		SSticker.mode.remove_revolutionary(H.mind)

	if(H.mind && iscultist(H))
		to_chat(H, "<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
		return FALSE
	else
		to_chat(H, "<span class='notice'>You feel a sense of peace and security. You are now protected from brainwashing.</span>")

	if(prob(50) && !H.isSynthetic())
		H.visible_message("[H] suddenly goes very red and starts writhing. There is a strange smell in the air...", \
		"<span class='userdanger'>Suddenly the horrible pain strikes your body! Your mind is in complete disorder! Blood pulses and starts burning! The pain is impossible!!!</span>")
		H.adjustBrainLoss(80)

	return TRUE



/obj/item/weapon/implant/mindshield/loyalty
	name = "loyalty implant"
	desc = "Makes you loyal or such."

/obj/item/weapon/implant/mindshield/loyalty/inject(mob/living/carbon/C, def_zone)
	. = ..()
	START_PROCESSING(SSobj, C)

/obj/item/weapon/implant/mindshield/loyalty/get_data()
	var/dat = {"
	<b>Характеристики Импланта:</b><BR>
	<b>Название:</b> Имплант Контроля Сотрудников Нанотрайзен.<BR>
	<b>Время жизни:</b> Десять лет.<BR>
	<b>Важные примечания:</b> Повышает лояльность носителя к компании.<BR>
	<b>Внимание:</b> Использование без специального оборудования может привести к травмам и серьезным поврежденям головного мозга.<BR>
	<HR>
	<b>Детали:</b><BR>
	<b>Функции:</b> Содержит капсулу наноботов, манипулирующих психическим состоянием носителя.<BR>
	<b>Особые возможности:</b> Откат и защита от большинства видов промывки мозгов и пропаганды.<BR>
	<b>Надежность:</b> Имплант прослужит до тех пор, пока нанороботы находятся в кровеносной системе носителя."}
	return dat

/obj/item/weapon/implant/mindshield/loyalty/implanted(mob/M)
	. = ..()
	if(.)
		if(M.mind)
			var/cleared_role = TRUE
			switch(M.mind.special_role)
				if("traitor")
					SSticker.mode.remove_traitor(M.mind)
					M.mind.remove_objectives()
				if("Syndicate")
					SSticker.mode.remove_nuclear(M.mind)
					M.mind.remove_objectives()
				else
					cleared_role = FALSE
			if(cleared_role)
				// M.mind.remove_objectives() Uncomment this if you're feeling suicidal, and inable to see player's objectives.
				to_chat(M, "<span class='danger'>You were implanted with [src] and now you must serve NT. Your old mission doesn't matter now.</span>")
				SSticker.reconverted_antags[M.key] = M.mind

		START_PROCESSING(SSobj, src)
		to_chat(M, "НаноТрайзен - лучшая корпорация во всей Вселенной!")

/obj/item/weapon/implant/mindshield/loyalty/process()
	if (!implanted || !imp_in)
		STOP_PROCESSING(SSobj, src)
		return
	if(imp_in.stat == DEAD)
		return

	if(prob(1) && prob(25))//1/400
		switch(rand(1, 4))
			if(1)
				to_chat(imp_in, "\italic Вы [pick("уверены", "думаете")] что НаноТрайзен - лучшая корпорация во всей Вселенной!")
			if(2)
				to_chat(imp_in, "\italic Вы [pick("уверены", "демаете")] что Капитан величайший человек из когда либо живших!")
			if(3)
				to_chat(imp_in, "\italic Вы желаете отдать свою жизнь во имя НаноТрайзен!")
			if(4)
				to_chat(imp_in, "\italic Вы уверены, что все действия Глав станции осуществяются ими для всеобщего блага!")
