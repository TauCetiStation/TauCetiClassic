// Put qualities that change gameplay in unique ways, which are neither strictly positve or negative.

/datum/quality/cyborg
	desc = "Все твои конечности и органы были заменены протезами в результате недавнего несчастного случая."
	restriction = "Нет."

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


/datum/quality/nuclear_option
	desc = "Тебе известен код от бомбы."

	restriction = "Капитан, АВД, Библиотекарь, Клоун, Мим."

	var/static/list/troublemakers = list(
		"Captain",
		"Internal Affairs Agent",
		"Librarian",
		"Clown",
		"Mime",
	)

/datum/quality/nuclear_option/availability_check(client/C)
	return job_checks(C, troublemakers)

/datum/quality/nuclear_option/restriction_check(mob/living/carbon/human/H)
	return H.mind.assigned_role in troublemakers

/datum/quality/nuclear_option/add_effect(mob/living/carbon/human/H)
	var/nukecode = "ERROR"

	var/nuke_type = "NT"
	if(H.mind.assigned_role && prob(50))
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

	var/obj/item/weapon/paper/nuclear_code/NC = new(H)
	if(H.put_in_hands(NC))
		return
	if(H.equip_or_collect(new /obj/item/weapon/paper/nuclear_code(H), SLOT_R_STORE))
		return
	qdel(NC)
