// Put qualities that change gameplay in unique ways, which are neither strictly positve or negative.

/datum/quality/cyborg
	desc = "Все твои конечности и органы были заменены протезами в результате недавнего несчастного случая."
	requirement = "Нет."

/datum/quality/cyborg/add_effect(mob/living/carbon/human/H, latespawn)
	qdel(H.bodyparts_by_name[BP_L_LEG])
	qdel(H.bodyparts_by_name[BP_R_LEG])
	qdel(H.bodyparts_by_name[BP_L_ARM])
	qdel(H.bodyparts_by_name[BP_R_ARM])

	var/obj/item/organ/external/l_arm/robot/LA = new(null)
	LA.insert_organ(H)

	var/obj/item/organ/external/r_arm/robot/RA = new(null)
	RA.insert_organ(H)

	var/obj/item/organ/external/l_leg/robot/LL = new(null)
	LL.insert_organ(H)

	var/obj/item/organ/external/r_leg/robot/RL = new(null)
	RL.insert_organ(H)

	for(var/obj/item/organ/internal/IO in H.organs)
		IO.mechanize()

	H.regenerate_icons()


/datum/quality/nuclear_option
	desc = "Тебе известен код от бомбы."
	requirement = "Капитан, АВД, Библиотекарь, Клоун, Мим."

	jobs_required = list(
		"Captain",
		"Internal Affairs Agent",
		"Librarian",
		"Clown",
		"Mime",
	)

/datum/quality/nuclear_option/add_effect(mob/living/carbon/human/H)
	var/nukecode = "ERROR"

	var/nuke_type = "NT"
	if(H.mind.assigned_role == "Clown" && prob(50))
		nuke_type = "Syndi"

	for(var/obj/machinery/nuclearbomb/bomb in poi_list)
		if(!bomb.r_code)
			continue
		if(bomb.r_code == "LOLNO")
			continue
		if(bomb.r_code == "ADMIN")
			continue
		if(bomb.nuketype != nuke_type)
			continue

		nukecode = bomb.r_code

	to_chat(H, "<span class='bold notice'>Код от бомбы: [nukecode]</span>")
	H.mind.store_memory("Код от бомбы: [nukecode]")

	var/obj/item/weapon/paper/nuclear_code/NC = new(H, nukecode)
	if(H.put_in_hands(NC))
		return
	if(H.equip_or_collect(NC, SLOT_R_STORE))
		return
	qdel(NC)

/datum/quality/iseedeadpeople
	desc = "После близкого знакомства с сингулярностью ты осознал, что другая сторона совсем рядом. Неупокоенным душам от тебя не утаиться."
	requirement = "Кто угодно, кроме охраны, Капитана и ХоПа."

/datum/quality/iseedeadpeople/restriction_check(mob/living/carbon/human/H, latespawn)
	var/list/funpolice = list("Security Officer", "Security Cadet", "Head of Security", "Captain", "Forensic Technician", "Detective", "Captain", "Warden", "Head of Personnel")
	if(H.mind.assigned_role in funpolice)
		return FALSE

	return TRUE

/datum/quality/iseedeadpeople/add_effect(mob/living/carbon/human/H)
	H.see_invisible = 60
