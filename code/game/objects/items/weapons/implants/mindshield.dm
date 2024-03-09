/obj/item/weapon/implant/mind_protect
	name = "Abstract Implant"
	cases = list("абстрактный имплант", "абстрактного импланта", "абстрактному импланту", "абстрактный имплант", "абстрактным имплантом", "абстрактном импланте")

/obj/item/weapon/implant/mind_protect/implanted(mob/M)
	if(!ishuman(M) || !M.mind)
		return TRUE
	var/mob/living/carbon/human/H = M
	if(isrevhead(H) || isshadowling(H) || isshadowthrall(H)|| iswizard(H))
		M.visible_message("<span class='warning'>[M] похоже, сопротивляется имплантату!</span>", "<span class='warning'>Вы чувствуете, что что-то мешает вашим мыслям, но вы сопротивляетесь этому!</span>")
		return FALSE

	var/list/role_to_deconvert = list(REV, GANGSTER)
	for(var/role in role_to_deconvert)
		if(isrole(role, M))
			var/datum/role/R = H.mind.GetRole(role)
			R.Deconvert()

	if(iscultist(H))
		to_chat(H, "<span class='warning'>Вы чувствуете, что что-то мешает вашим мыслям, но вы сопротивляетесь этому!</span>")
		return FALSE
	else
		to_chat(H, "<span class='notice'Вы ощущаете покой и безопасность. Теперь вы защищены от промывания мозгов.</span>")

	if(prob(50) && !H.isSynthetic())
		H.visible_message("[H] внезапно становится очень красным и начинает корчиться. В воздухе появляется странный запах....", \
		"<span class='userdanger'>Внезапно ужасная боль пронзает ваше тело! Ваш разум в полном беспорядке! Кровь пульсирует и начинает гореть! Боль НЕВЫНОСИМА!!!</span>")
		H.adjustBrainLoss(80)

	for(var/obj/item/weapon/implant/skill/S in H)
		if(S.implanted)
			S.meltdown()

	return TRUE

/obj/item/weapon/implant/mind_protect/mindshield
	name = "mindshield implant"
	cases = list("имплант защиты разума", "импланта защиты разума", "импланту защиты разума", "имплант защиты разума", "имплантом защиты разума", "импланте защиты разума")
	desc = "Защищает от промывания мозгов."
	implant_trait = TRAIT_VISUAL_MINDSHIELD

/obj/item/weapon/implant/mind_protect/mindshield/get_data()
	var/dat = {"<b>Характеристики импланта:</b><BR>
				<b>Наименование:</b> Имплант НаноТрейзен по защите разума персонала<BR>
				<b>Срок годности:</b> Ten years.<BR>
				<b>Важные примечания:</b> Лица, которым вводится это устройство, гораздо более устойчивы к промыванию мозгов и пропаганде.<BR>
				<HR>
				<b>Подробности:</b><BR>
				<b>Функционал:</b> Содержит небольшую капсулу с наноботами, защищающую психические функции носителя от манипуляций.<BR>
				<b>Особенности:</b> Предотвращает и блокирует большинство форм промывания мозгов и пропаганды.<BR>
				<b>Целостность:</b> Имплантат будет работать до тех пор, пока наноботы находятся в кровотоке."}
	return dat

/obj/item/weapon/implant/mind_protect/loyalty
	name = "loyalty implant"
	cases = list("имплант лояльности", "импланта лояльности", "импланту лояльности", "имплант лояльности", "имплантом лояльности", "импланте лояльности")
	desc = "Делает вас лояльным или что-то вроде того."
	implant_trait = TRAIT_VISUAL_LOYAL

/obj/item/weapon/implant/mind_protect/loyalty/inject(mob/living/carbon/C, def_zone)
	. = ..()
	START_PROCESSING(SSobj, C)

/obj/item/weapon/implant/mind_protect/loyalty/get_data()
	var/dat = {"
	<b>Характеристики импланта:</b><BR>
	<b>Наименование:</b> Имплант для управления персоналом НаноТрейзен<BR>
	<b>Life:</b> Ten years.<BR>
	<b>Важные примечания:</b> Персонал, которому вводится это устройство, как правило, гораздо более лоялен компании.<BR>
	<b>Предупреждение:</b> Использование без специального оборудования может привести к тяжелым травмам и серьезным повреждениям мозга.<BR>
	<HR>
	<b>Подробности:</b><BR>
	<b>Функционал:</b> Содержит небольшую капсулу с наноботами, которые манипулируют психическими функциями носителя.<BR>
	<b>Особенности:</b> Предотвращает и блокирует большинство форм промывания мозгов.<BR>
	<b>Целостность:</b> Имплантат будет работать до тех пор, пока наноботы находятся в кровотоке."}
	return dat

/obj/item/weapon/implant/mind_protect/loyalty/implanted(mob/M)
	. = ..()
	if(.)
		if(M.mind)
			var/cleared_role = FALSE
			var/list/remove_roles = list(TRAITOR, NUKE_OP, NUKE_OP_LEADER, HEADREV, GANGSTER_LEADER)
			for(var/role in remove_roles)
				var/datum/role/R = M.mind.GetRole(role)
				if(!R)
					continue
				R.Deconvert()
				cleared_role = TRUE

			if(cleared_role)
				// M.mind.remove_objectives() Uncomment this if you're feeling suicidal, and inable to see player's objectives.
				to_chat(M, "<span class='danger'>Вам вживили [CASE(src, NOMINATIVE_CASE)], и теперь вы должны служить НТ. Ваша прежняя миссия больше не имеет значения. Слава НТ!</span>")

		for(var/obj/item/weapon/implant/skill/S in M)
			if(S.implanted)
				S.meltdown()
		START_PROCESSING(SSobj, src)
		to_chat(M, "НаноТрейзен - лучшая корпорация во всей Вселенной!")

/obj/item/weapon/implant/mind_protect/loyalty/process()
	if (!implanted || !imp_in)
		STOP_PROCESSING(SSobj, src)
		return
	if(imp_in.stat == DEAD)
		return

	if(prob(1) && prob(25))//1/400
		switch(rand(1, 4))
			if(1)
				to_chat(imp_in, "\italic Вы [pick("уверены", "считаете", "убеждены")], что НаноТрейзен - лучшая корпорация во всей Вселенной!")
			if(2)
				to_chat(imp_in, "\italic Вы [pick("уверены", "считаете", "убеждены")], что Капитан - величайший человек, который когда-либо жил!")
			if(3)
				to_chat(imp_in, "\italic Вы готовы отдать свою жизнь во славу НаноТрейзен!")
			if(4)
				to_chat(imp_in, "\italic Вы уверены в том, что все действия НаноТрейзен приведут к всеобщему благу!")
