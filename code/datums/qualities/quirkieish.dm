// Put qualities that change gameplay in unique ways, which are neither strictly positve or negative. For further explanation and more reading material visit __DEFINES/qualities.dm and qualities/quality.dm
/datum/quality/quirkieish
	pools = list(
		QUALITY_POOL_QUIRKIEISH
	)

/datum/quality/quirkieish/cyborg
	name = "Cyborg"//04
	desc = "Все твои конечности и органы были заменены протезами в результате недавнего несчастного случая."
	requirement = "Нет."

/datum/quality/quirkieish/cyborg/add_effect(mob/living/carbon/human/H, latespawn)
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


/datum/quality/quirkieish/nuclear_option
	name = "Nuclear Option"
	desc = "Тебе известен код от бомбы."
	requirement = "Капитан, АВД, Библиотекарь, Клоун, Мим."

	jobs_required = list(
		"Captain",
		"Internal Affairs Agent",
		"Librarian",
		"Clown",
		"Mime",
	)

/datum/quality/quirkieish/nuclear_option/add_effect(mob/living/carbon/human/H)
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


/datum/quality/quirkieish/diggydiggyhole
	name = "Diggy Diggy Hole"
	desc = "Ты - дворф! Ты любишь пиво, копать породу и собирать блестящие металлы."
	requirement = "Шахтер."

	jobs_required = list("Shaft Miner")

/datum/quality/quirkieish/diggydiggyhole/add_effect(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_DWARF, QUALITY_TRAIT)
	H.f_style = pick("Dwarf Beard", "Very Long Beard")

	H.mutations.Add(SMALLSIZE)
	H.regenerate_icons()

	H.add_language(LANGUAGE_SHKIONDIONIOVIOION)

	H.equip_or_collect(new /obj/item/weapon/pickaxe/diamond(H), SLOT_L_HAND)


/datum/quality/quirkieish/informed
	name = "Informed"
	desc = "В баре тебе удалось подслушать странный разговор о каких-то кодовых словах."
	requirement = "Все, кроме охраны, Капитана и ХоПа."

	var/list/funpolice = list("Security Officer", "Security Cadet", "Head of Security", "Captain", "Forensic Technician", "Detective", "Captain", "Warden", "Head of Personnel")

/datum/quality/quirkieish/informed/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return !(H.mind.assigned_role in funpolice)

/datum/quality/quirkieish/informed/add_effect(mob/living/carbon/human/H)
	var/response = "[codewords2string(global.syndicate_code_response)]"
	var/phrase = "[codewords2string(global.syndicate_code_phrase)]"
	var/message = "Кажется, было что-то типа... [pick(response, phrase)]"
	to_chat(H, "<span class ='notice'>Ты припоминаешь услышанные слова... [message].</span>")
	H.mind.store_memory(message)


/datum/quality/quirkieish/iseedeadpeople
	name = "I See Dead People"
	desc = "После экспериментов, включающих в себя погружение в глубокую кому, ты стал замечать вокруг едва видимые тени..."
	requirement = "Нет."

/datum/quality/quirkieish/iseedeadpeople/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_SEE_GHOSTS, QUALITY_TRAIT)
	H.update_alt_apperance_by(/datum/atom_hud/alternate_appearance/basic/see_ghosts)


/datum/quality/quirkieish/war_face
	name = "War Face"
	desc = "ПОКАЖИ МНЕ СВОЙ БОЕВОЙ ОСКАЛ."
	requirement = "Нет."

	var/list/war_colors = list(
		COLOR_CRIMSON_RED,
		COLOR_CRIMSON,
		COLOR_WHITE,
		COLOR_BLACK,
		COLOR_YELLOW,
		COLOR_GOLD,
		COLOR_INDIGO,
		COLOR_ADMIRAL_BLUE,
		COLOR_CROCODILE,
		COLOR_SEAWEED,
		COLOR_ROSE_PINK,
		COLOR_TIGER,
		COLOR_PURPLE,
	)

/datum/quality/quirkieish/war_face/proc/battlecry(datum/source, new_intent)
	var/mob/living/carbon/human/H = source
	if(H.stat != CONSCIOUS)
		return

	if(new_intent == H.a_intent)
		return

	if(new_intent != INTENT_HARM)
		return

	H.emote("scream", intentional = TRUE)

/datum/quality/quirkieish/war_face/add_effect(mob/living/carbon/human/H, latespawn)
	H.lip_style = "spray_face"
	H.lip_color = pick(war_colors)
	// for some reason name is not set at this stage and if I don't do this the emote message will be nameless
	H.name = H.real_name
	H.emote("scream")
	H.update_body()

	RegisterSignal(H, list(COMSIG_MOB_SET_A_INTENT), .proc/battlecry)


/datum/quality/quirkieish/kamikaze
	name = "Kamikaze"
	desc = "Каким-то образом тебе вставили имплант самоуничтожения. Реанимировать после смерти будет значительно сложнее..."
	requirement = "Нет."

/datum/quality/quirkieish/kamikaze/add_effect(mob/living/carbon/human/H, latespawn)
	var/obj/item/weapon/implant/dexplosive/DE = new(H)
	DE.stealth_inject(H)


/datum/quality/quirkieish/obedient
	name = "Obedient"
	desc = "За плохое поведение тебе ввели имплант подчинения. Лучше вести себя хорошо."
	requirement = "Не охранник."

	var/list/funpolice = list("Security Officer", "Security Cadet", "Warden")

/datum/quality/quirkieish/obedient/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return !(H.mind.assigned_role in funpolice)

/datum/quality/quirkieish/obedient/add_effect(mob/living/carbon/human/H, latespawn)
	var/obj/item/weapon/implant/obedience/O = new(H)
	O.stealth_inject(H)



/datum/quality/quirkieish/jack_of_all_trades
	name = "Jack of All Trades"
	desc = "Пройдя ускоренный курс подготовки к работе в космосе, ты овладел навыками во многих сферах деятельности, но достичь мастерства не удалось ни в одной."
	requirement = "Нет."

/datum/quality/quirkieish/jack_of_all_trades/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/datum/skillset/s as anything in H.mind.skills.available_skillsets)
		LAZYREMOVE(H.mind.skills.available_skillsets, s)
	H.mind.skills.add_available_skillset(/datum/skillset/jack_of_all_trades)
	H.mind.skills.maximize_active_skills()
