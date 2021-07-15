// Lore is very different from /tg/, but the names and terminology in code are left same
/datum/role/cop/undercover
	name = UNDERCOVER_COP
	id = UNDERCOVER_COP

	required_pref = ROLE_FAMILIES
	restricted_jobs = list("Security Cadet", "AI", "Cyborg", "Security Officer", "Head of Security", "Captain", "Internal Affairs Agent")

	logo_state = "undercover_cop"

	var/free_clothes = list(/obj/item/clothing/glasses/sunglasses/hud/spacecop/hidden,
					/obj/item/clothing/under/rank/security/beatcop,
					/obj/item/clothing/head/spacepolice)

/datum/role/cop/undercover/OnPostSetup(laterole)
	. = ..()
	if(ishuman(antag.current))
		for(var/type in free_clothes)
			var/mob/living/carbon/human/H = antag.current
			var/obj/O = new type(H)
			var/list/slots = list(
				"backpack" = SLOT_IN_BACKPACK,
				"left hand" = SLOT_L_HAND,
				"right hand" = SLOT_R_HAND,
			)
			var/equipped = H.equip_in_one_of_slots(O, slots)
			if(!equipped)
				to_chat(H, "Unfortunately, you could not bring your [O] to this shift. You will need to find one.")
				qdel(O)

/datum/role/cop/undercover/Greet()
	..()
	var/missiondesc = ""
	missiondesc += "<BR><B><font size=3 color=red>Вы НЕ являетесь сотрудником НаноТрейзен. Вы работаете на местное правительство.</font></B>"
	missiondesc += "<BR>Вы являетесь сотрудником полиции под прикрытием на борту [station_name()]. Вы были посланы сюда Звёздной Коалицией Тау Киты из-за подозрений в жестоком поведении со стороны сотрудников безопасности и для того, чтобы следить за потенциальной перступной деятельностью."
	missiondesc += "<BR><B>Ваша Миссия</B>:"
	missiondesc += "<BR> <B>1.</B> Внимательно следите за любыми гангстерами, которых вы заметите. Вы можете их увидеть, используя свои специальные очки в рюкзаке."
	missiondesc += "<BR> <B>2.</B> Смотрите за тем, как Служба Безопасности справляется с бандитами, и следите за чрезмерной жестокостью с их стороны."
	missiondesc += "<BR> <B>3.</B> Оставайтесь под прикрытием и не попадайтесь на глаза службе безопасноси или каким-либо бандам. НаноТрейзен не любит, когда за ними шпионят."
	missiondesc += "<BR> <B>4.</B> Когда ваши коллеги прибудут через час, свяжитесь с ними и сообщите им обо всем, что вы видели. Помогите им в обеспечении безопасности.</span>"
	to_chat(antag.current, missiondesc)

/datum/role/cop
	name = SPACE_COP
	id = SPACE_COP

	required_pref = ROLE_FAMILIES

	antag_hud_type = ANTAG_HUD_SPACECOP
	antag_hud_name = "hud_spacecop"

	logo_state = "space_cop"

	var/outfit

/datum/role/cop/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/M = antag.current
	if(M.hud_used)
		var/datum/hud/H = M.hud_used
		var/atom/movable/screen/wanted/giving_wanted_lvl = new /atom/movable/screen/wanted()
		H.wanted_lvl = giving_wanted_lvl
		H.mymob.client.screen += giving_wanted_lvl

	if(outfit)
		M.equipOutfit(outfit)

/datum/role/cop/RemoveFromRole(datum/mind/M, msg_admins)
	. = ..()
	var/mob/living/L = M.current
	if(L.hud_used)
		var/datum/hud/H = L.hud_used
		H.mymob.client.screen -= H.wanted_lvl
		QDEL_NULL(H.wanted_lvl)

/datum/role/cop/beatcop
	name = "Beat Cop"
	outfit = /datum/outfit/families_police/beatcop

/datum/role/cop/beatcop/Greet(greeting, custom)
	if(!..())
		return FALSE

	var/missiondesc = ""
	missiondesc += "<BR><B><font size=5 color=red>Вы НЕ являетесь сотрудником НаноТрейзен. Вы работаете на местное правительство.</font></B>"
	missiondesc += "<BR><B><font size=5 color=red>Вы НЕ Эскадрон Смерти. Вы здесь, чтобы помочь невинным людям избежать насилия, остановить преступную деятельность и другие опасные штуки.</font></B>"
	missiondesc += "<BR>После всплеска бандитского насилия на [station_name()], вы отвечаете на экстренные вызов со станции для немедленной помощи полиции ЗКТК.\n"
	missiondesc += "<BR><B>Ваша Миссия</B>:"
	missiondesc += "<BR> <B>1.</B> Служите обществу."
	missiondesc += "<BR> <B>2.</B> Защищайте невинных."
	missiondesc += "<BR> <B>3.</B> Соблюдайте закон."
	missiondesc += "<BR> <B>4.</B> Найдите копов под прикрытием."
	missiondesc += "<BR> <B>5.</B> Задержите сотрудников Службы Безопасности НаноТрейзен, если они будут причинять вред персоналу."
	missiondesc += "<BR> Вы можете <B>видеть бандитов</B> используя ваши <B>специальные очки</B>.</span>"
	to_chat(antag.current, missiondesc)

	antag.current.playsound_local(null, 'sound/antag/families_police.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/role/cop/beatcop/armored
	name = "Armored Beat Cop"
	outfit = /datum/outfit/families_police/beatcop/armored

/datum/role/cop/beatcop/swat
	name = "S.W.A.T. Member"
	outfit = /datum/outfit/families_police/beatcop/swat

/datum/role/cop/beatcop/fbi
	name = "FBI Agent"
	outfit = /datum/outfit/families_police/beatcop/fbi

/datum/role/cop/beatcop/military
	name = "Space Military"
	outfit = /datum/outfit/families_police/beatcop/military
