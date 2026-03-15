// parent type, should not use
/obj/item/weapon/implant/mind_protect
	name = "Abstract Implant"
	desc = "Call coders if you see it"

	// roles that will prevent implantation
	var/list/protected_roles = list(HEADREV, SHADOW, SHADOW_THRALL, CULTIST, WIZARD, WIZ_APPRENTICE)
	// roles that will be removed after implantation
	var/list/deconvert_roles = list(REV, GANGSTER) // default mindshield helps only against brainwashing

	var/deconvert_message = "Вы ощущаете покой и безопасность. Теперь вы защищены от промывания мозгов."

/obj/item/weapon/implant/mind_protect/pre_inject(mob/living/carbon/implant_mob, mob/operator)
	. = ..()

	if(!. || !operator)
		return FALSE

	if(!implant_mob.mind)
		return TRUE

	for(var/role in protected_roles)
		if(implant_mob.mind.GetRole(role))
			implant_mob.visible_message("<span class='warning'>[implant_mob] сопротивляется имплантату!</span>", "<span class='warning'>Вы чувствуете, что что-то мешает вашим мыслям, но вы сопротивляетесь этому!</span>")
			return FALSE

	return TRUE

/obj/item/weapon/implant/mind_protect/inject(mob/living/carbon/C, def_zone = BP_HEAD, safe_inject = TRUE)
	. = ..()

	if(!prob(reliability))
		meltdown()
		return

	implanted_mob.mind.pluvian_social_credit = 0

	var/deconverted = FALSE
	for(var/role in deconvert_roles)
		if(isrole(role, implanted_mob))
			var/datum/role/R = implanted_mob.mind.GetRole(role)
			R.Deconvert()
			deconverted = TRUE

	if(deconverted)
		to_chat(implanted_mob, "<span class='notice'>[deconvert_message]</span>")

	// should motivate heads to not abuse it against the crew
	if(!safe_inject && prob(50))
		implanted_mob.visible_message("[implanted_mob] внезапно становится очень красным и начинает корчиться. В воздухе появляется странный запах....", \
		"<span class='userdanger'>Внезапно ужасная боль пронзает ваше тело! Ваш разум в полном беспорядке! Кровь пульсирует и начинает гореть! Боль НЕВЫНОСИМА!!!</span>")
		implanted_mob.adjustBrainLoss(80)

	if(C.get_species() in list(VOX, VOX_ARMALIS))
		addtimer(CALLBACK(src, PROC_REF(vox_mind_resistance)), rand(5, 15) MINUTES)

/obj/item/weapon/implant/mind_protect/proc/vox_mind_resistance()
	if(QDELING(src) || !implanted_mob)
		return

	to_chat(implanted_mob, "<span class='notice'>Ваша естественная ментальная стабильность нейтрализовала воздействие импланта, влияющего на разум.</span>")
	meltdown(harmful = FALSE)

/obj/item/weapon/implant/mind_protect/mindshield
	name = "mindshield implant"
	cases = list("имплант защиты разума", "импланта защиты разума", "импланту защиты разума", "имплант защиты разума", "имплантом защиты разума", "импланте защиты разума")
	desc = "Защищает от промывания мозгов."
	hud_id = IMPMINDS_HUD
	hud_icon_state = "hud_imp_mindshield"

	implant_data = {"<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Имплант НаноТрейзен по защите разума персонала<BR>
<b>Срок годности:</b> Ten years.<BR>
<b>Важные примечания:</b> Лица, которым вводится это устройство, гораздо более устойчивы к промыванию мозгов и пропаганде.<BR>
<HR>
<b>Подробности:</b><BR>
<b>Функционал:</b> Содержит небольшую капсулу с наноботами, защищающую психические функции носителя от манипуляций.<BR>
<b>Особенности:</b> Предотвращает и блокирует большинство форм промывания мозгов и пропаганды.<BR>
<b>Целостность:</b> Имплантат будет работать до тех пор, пока наноботы находятся в кровотоке."}

/obj/item/weapon/implant/mind_protect/loyalty
	name = "loyalty implant"
	cases = list("имплант лояльности", "импланта лояльности", "импланту лояльности", "имплант лояльности", "имплантом лояльности", "импланте лояльности")
	desc = "Делает лояльным. Или вроде того."
	hud_id = IMPLOYAL_HUD
	hud_icon_state = "hud_imp_loyal"

	deconvert_roles = list(REV, GANGSTER, TRAITOR, NUKE_OP, NUKE_OP_LEADER, HEADREV, GANGSTER_LEADER, PRISONER, THIEF)

	deconvert_message = "Ваша прежняя миссия больше не имеет значения, теперь вы должны служить только корпорации. Слава НТ!"

	implant_data = {"<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Имплант для управления персоналом НаноТрейзен<BR>
<b>Life:</b> Ten years.<BR>
<b>Важные примечания:</b> Персонал, которому вводится это устройство, как правило, гораздо более лоялен компании.<BR>
<b>Предупреждение:</b> Использование без специального оборудования может привести к тяжелым травмам и серьезным повреждениям мозга.<BR>
<HR>
<b>Подробности:</b><BR>
<b>Функционал:</b> Содержит небольшую капсулу с наноботами, которые манипулируют психическими функциями носителя.<BR>
<b>Особенности:</b> Предотвращает и блокирует большинство форм промывания мозгов.<BR>
<b>Целостность:</b> Имплантат будет работать до тех пор, пока наноботы находятся в кровотоке."}

/obj/item/weapon/implant/mind_protect/loyalty/inject()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/implant/mind_protect/loyalty/process()
	if(!implanted_mob)
		STOP_PROCESSING(SSobj, src)
		return

	if(implanted_mob.stat || malfunction)
		return

	if(prob(1) && prob(25)) // 1/400
		var/static/list/implant_phrases = list(
			"Вы [pick("уверены", "считаете", "убеждены")], что НаноТрейзен - лучшая корпорация во всей Вселенной!",
			"Вы [pick("уверены", "считаете", "убеждены")], Стандартный порядок действий - это величайшая процедура, которая когда-либо существовала!",
			"Вы готовы отдать свою жизнь во славу НаноТрейзен!",
			"Вы уверены в том, что все действия НаноТрейзен приведут к всеобщему благу!",
			"Вы уверены, что НаноТрейзен - это не работа, это стиль жизни, который нельзя покинуть!",
			"Вы считаете, что все ваши мысли принадлежат НаноТрейзен - и это так успокаивает!",
			"Вы считаете, что ваша жизнь без НаноТрейзен была бы настолько скучной, что вы бы её и не вспомнили!",
			"Вы убеждены, что НаноТрейзен заботится о вас так же, как вы заботитесь о своей любимой кружке!",
			"Вы считаете, что работать в НаноТрейзен - это лучшее, что могло с вами случиться!",
			"Вы считаете, что ваш трудовой договор с НаноТрейзен - это пожизненная гарантия приключений!")
		to_chat(implanted_mob, "<span class='italics'>[pick(implant_phrases)]</span>")
