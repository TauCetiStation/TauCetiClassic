// Lore is very different from /tg/, but the names and terminology in code are left same
/datum/role/cop/undercover
	name = UNDERCOVER_COP
	id = UNDERCOVER_COP

	required_pref = ROLE_FAMILIES
	restricted_jobs = list("Security Cadet", "AI", "Cyborg", "Security Officer", "Head of Security", "Captain", "Internal Affairs Agent", "Blueshield Officer")

	logo_state = "undercover_cop"

	var/free_clothes = list(
					/obj/item/clothing/glasses/sunglasses,
					/obj/item/clothing/under/rank/security/beatcop,
					/obj/item/clothing/head/spacepolice,
					)
	skillset_type = /datum/skillset/undercover
	moveset_type = /datum/combat_moveset/cqc

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
	missiondesc += "Вы являетесь офицером под  прикрытием на борту [station_name()], работающим на Отдел по Борьбе с Организованной Преступностью. Вы были посланы сюда из-за подозрений в халатном поведении сотрудников безопасности и для того, чтобы следить за потенциальной преступной деятельностью."
	missiondesc += "<BR><B>Ваша Миссия</B>:"
	missiondesc += "<BR> <B>1.</B> Внимательно следите за любыми гангстерами, которых вы заметите."
	missiondesc += "<BR> <B>2.</B> Смотрите за тем, как Служба Безопасности справляется с бандитами, и следите за чрезмерной жестокостью с их стороны."
	missiondesc += "<BR> <B>3.</B> Оставайтесь под прикрытием и не попадайтесь на глаза службе безопасноси или каким-либо бандам. Никто не любит проверок из инспекций."
	missiondesc += "<BR> <B>4.</B> Когда ваши коллеги прибудут через час, свяжитесь с ними и сообщите им обо всем, что вы видели. Помогите им в обеспечении безопасности."
	to_chat(antag.current, missiondesc)

/datum/role/cop
	name = SPACE_COP
	id = SPACE_COP

	required_pref = ROLE_FAMILIES

	antag_hud_type = ANTAG_HUD_SPACECOP
	antag_hud_name = "hud_spacecop"

	logo_state = "space_cop"

	var/outfit
	skillset_type = /datum/skillset/cop

/datum/role/cop/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/M = antag.current

	if(outfit)
		M.equipOutfit(outfit)

/datum/role/cop/add_ui(datum/hud/hud)
	wanted_lvl_screen.add_to_hud(hud)

/datum/role/cop/remove_ui(datum/hud/hud)
	wanted_lvl_screen.remove_from_hud(hud)

/datum/role/cop/beatcop
	name = "Officer"
	outfit = /datum/outfit/families_police/beatcop

/datum/role/cop/beatcop/Greet(greeting, custom)
	if(!..())
		return FALSE

	var/missiondesc = ""
	missiondesc += "<B><font size=5 color=red>Вы НЕ Эскадрон Смерти. Вы здесь, чтобы помочь невинным людям избежать насилия, остановить преступную деятельность и другие опасные штуки.</font></B>"
	missiondesc += "<BR>Вы работаете на <B>Отдел по Борьбе с Организованной Преступностью</B>. Вы находитесь по иерархии выше любого сотрудника станции."
	missiondesc += "<BR>После всплеска бандитского насилия на [station_name()], вы отвечаете на экстренные вызов со станции для немедленной помощи .\n"
	missiondesc += "<BR><B>Ваша Миссия</B>:"
	missiondesc += "<BR> <B>1.</B> Служите обществу."
	missiondesc += "<BR> <B>2.</B> Защищайте невинных."
	missiondesc += "<BR> <B>3.</B> Соблюдайте закон."
	missiondesc += "<BR> <B>4.</B> Найдите внедрённых офицеров."
	missiondesc += "<BR> <B>5.</B> Задержите сотрудников Службы Безопасности, если они будут причинять вред персоналу."
	to_chat(antag.current, missiondesc)

	antag.current.playsound_local(null, 'sound/antag/families_police.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/datum/role/cop/beatcop/armored
	name = "Armed Officer"
	outfit = /datum/outfit/families_police/beatcop/armored

/datum/role/cop/beatcop/swat
	name = "Tactical Group Fighter"
	outfit = /datum/outfit/families_police/beatcop/swat

/datum/role/cop/beatcop/fbi
	name = "Inspector"
	outfit = /datum/outfit/families_police/beatcop/fbi

/datum/role/cop/beatcop/military
	name = "MFNT Fighter"
	outfit = /datum/outfit/families_police/beatcop/military
