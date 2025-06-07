/obj/item/weapon/implant/dexplosive
	name = "explosive"
	cases = list("разрывной имплант", "разрывного импланта", "разрывному импланту", "разрывной имплант", "разрывным имплантом", "разрывном импланте")
	desc = "Трах-бабах и нет его!"
	icon_state = "implant_evil"
	legal = FALSE
	activation_emote = "deathgasp"
	uses = 1
	delete_after_use = TRUE
	implant_data = {"
<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Имплант управления персоналом Robust Corp RX-78<BR>
<b>Срок годности:</b> Активируется посмертно.<BR>
<b>Важные примечания:</b> Взрывается<BR>
<HR>
<b>Подробности:</b><BR>
<b>Функционал:</b> Содержит миниатюрный радиоуправляемый заряд мощной взрывчатки, который детонирует при получении особого зашифрованного сигнала или при смерти носителя.<BR>
<b>Особенности:</b> Взрывается<BR>
<b>Целостность:</b> Иммунная система носителя периодически повреждает имплант, от чего он может работать со сбоями."}

/obj/item/weapon/implant/dexplosive/activate()
	var/turf/T = get_turf(implanted_mob)
	implanted_mob.gib()
	explosion(T, -1, 0, 2, 3)//This might be a bit much, dono will have to see.

#define EXPLODE_BODYPART "Конкретная конечность"
#define EXPLODE_BODYGIB "Разрыв тела"
#define EXPLODE_BODYGIB_AND_TILE "Полноценный взрыв"

/obj/item/weapon/implant/explosive
	name = "explosive implant"
	cases = list("взрывной имплант", "взрывного импланта", "взрывному импланту", "взрывной имплант", "взрывным имплантом", "взрывном импланте")
	desc = "Военная миниатюрная био-взрывчатка. Очень опасна."
	icon_state = "implant_evil"
	legal = FALSE
	flags = HEAR_TALK
	uses = 1
	implant_data = {"
<b>Характеристики импланта:</b><BR>
<b>Наименование:</b> Шантаж-имплант Robust Corp RX-78<BR>
<b>Срок годности:</b> Активируется от кодовой фразы.<BR>
<b>Важные примечания:</b> Взрывается<BR>
<HR>
<b>Подробности:</b><BR>
<b>Функционал:</b> Содержит миниатюрный радиоуправляемый заряд мощной взрывчатки, который детонирует при получении особого зашифрованного сигнала или при смерти носителя.<BR>
<b>Особенности:</b> Взрывается<BR>
<b>Целостность:</b> Иммунная система носителя периодически повреждает имплант, от чего он может работать со сбоями."}

	var/elevel = EXPLODE_BODYPART
	var/activation_phrase

/obj/item/weapon/implant/explosive/hear_talk(mob/M, msg)
	if(!implanted_mob || !activation_phrase || malfunction || uses <= 0)
		return
	if(findtext(msg, activation_phrase))
		use_implant()

/obj/item/weapon/implant/explosive/activate()
	message_admins("Explosive implant triggered in [implanted_mob] ([key_name_admin(implanted_mob)]). [ADMIN_JMP(implanted_mob)]")
	log_game("Explosive implant triggered in [implanted_mob] ([key_name(implanted_mob)]).")

	implanted_mob.visible_message("<span class='warning'>Что-то пищит внутри [implanted_mob] [body_part ? "'s [body_part.name]" : ""]!</span>")
	playsound(src, 'sound/items/countdown.ogg', VOL_EFFECTS_MASTER)
	addtimer(CALLBACK(src, PROC_REF(explode)), 3 SECONDS)

/obj/item/weapon/implant/explosive/proc/explode()
	switch(elevel)
		if (EXPLODE_BODYPART)
			if(body_part)
				//No tearing off these body_parts since it's pretty much killing
				//and you can't replace groins
				if (istype(body_part,/obj/item/organ/external/chest) ||	\
					istype(body_part,/obj/item/organ/external/groin) ||	\
					istype(body_part,/obj/item/organ/external/head))
					body_part.take_damage(60, used_weapon = "Explosion") //mangle them instead
				else
					body_part.droplimb(null, null, DROPLIMB_BLUNT)
				explosion(implanted_mob, -1, -1, 2, 3)
		if (EXPLODE_BODYGIB)
			explosion(implanted_mob, -1, 0, 1, 6)
			implanted_mob.gib()
		if (EXPLODE_BODYGIB_AND_TILE)
			explosion(implanted_mob, 0, 1, 3, 6)
			implanted_mob.gib()

	qdel(src)

/obj/item/weapon/implant/explosive/pre_inject(mob/living/carbon/implant_mob, mob/operator)
	. = ..()
	if(!. || !operator)
		return FALSE

	elevel = tgui_alert(operator, "Как именно должен взорваться этот имплант?", "Заряд взрывчатки", list(EXPLODE_BODYPART, EXPLODE_BODYGIB, EXPLODE_BODYGIB_AND_TILE))
	var/set_phrase = sanitize(input(operator, "Введите кодовую фразу:") as text)
	if(!length(set_phrase))
		to_chat(operator, "<span class='warning'>Вам нужно задать фразу активации перед имплантировоанием.</span>")
		return FALSE
	activation_phrase = set_phrase
	operator.mind.store_memory("Взрывной имплант [implant_mob] может активироваться, если произнести что-либо, что содержит фразу ''[activation_phrase]'', <B>произнесите [activation_phrase]</B> для активации.")
	to_chat(operator, "Взрывной имплант, введённый в [implant_mob], может активироваться, если произнести что-либо, что содержит фразу ''[activation_phrase]'', <B>произнесите [activation_phrase]</B> для активации.")

	return TRUE

/obj/item/weapon/implant/explosive/emp_act(severity)
	if (malfunction)
		return

	switch (severity)
		if (1) //strong EMP will melt implant either making it go off, or disarming it
			switch(rand(1,100))
				if(1 to 30)
					set_malfunction_for(30 SECONDS)
				if(31 to 60)
					meltdown()
				if(61 to 90)
					elevel = EXPLODE_BODYPART
					use_implant()
				else
					use_implant()
		if (2) //Weak EMP will make implant tear limbs off.
			if (prob(50))
				elevel = EXPLODE_BODYPART
				use_implant()
			else
				set_malfunction_for(5 SECONDS)
