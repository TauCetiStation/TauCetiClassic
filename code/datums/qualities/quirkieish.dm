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
	requirement = "Все, кроме охраны, Синего щита, Капитана и ХоПа."

	var/list/funpolice = list("Security Officer", "Security Cadet", "Head of Security", "Captain", "Forensic Technician", "Detective", "Captain", "Warden", "Head of Personnel", "Blueshield Officer")

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

	RegisterSignal(H, list(COMSIG_MOB_SET_A_INTENT), PROC_REF(battlecry))


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


/datum/quality/quirkieish/mmi_ipc
	name = "MMI IPC"
	desc = "Ты мозг. Запертый. В оболочке. СПУ."
	requirement = "Подопытный."

/datum/quality/quirkieish/mmi_ipc/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return H.mind.role_alt_title == "Test Subject" && H.get_species() != IPC

/datum/quality/quirkieish/mmi_ipc/add_effect(mob/living/carbon/human/H, latespawn)
	var/prev_species = H.get_species()
	H.set_species(IPC)

	// TO-DO: use human-like hairstyles for this type of IPC
	// as well as set their head to a human-like one.
	var/obj/item/organ/external/chest/robot/ipc/I = H.get_bodypart(BP_CHEST)
	I.posibrain_type = /obj/item/device/mmi
	I.posibrain_species = prev_species


/datum/quality/quirkieish/podman
	name = "Podman"
	desc = "Тебе подменили. Ты не ты."
	requirement = "Подопытный."

/datum/quality/quirkieish/podman/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return H.mind.role_alt_title == "Test Subject"

/datum/quality/quirkieish/podman/add_effect(mob/living/carbon/human/H, latespawn)
	var/msg = "<span class='notice'><B>You awaken slowly, feeling your sap stir into sluggish motion as the warm air caresses your bark.</B></span><BR>"
	msg += "<B>You are now in possession of Podmen's body. It's previous owner found it no longer appealing, by rejecting it - they brought you here. You are now, again, an empty shell full of hollow nothings, neither belonging to humans, nor them.</B><BR>"
	msg += "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>"

	H.set_species(PODMAN)
	to_chat(H, msg)


/datum/quality/quirkieish/doppleganger
	name = "Doppleganger"
	desc = "Ты - незарегестрированный клон кого-то из экипажа."
	requirement = "Подопытный."

/datum/quality/quirkieish/doppleganger/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return H.mind.role_alt_title == "Test Subject"

/datum/quality/quirkieish/doppleganger/add_effect(mob/living/carbon/human/H, latespawn)
	var/list/pos_players = player_list.Copy()
	pos_players -= H

	var/mob/living/carbon/human/target = null

	while(target == null && length(pos_players) > 0)
		var/mob/living/carbon/human/potential_target = pick(pos_players)
		pos_players -= potential_target

		// AI and borgs.
		if(!istype(potential_target))
			continue
		// This shouldn't be able to happen, but to prevent runtimes...
		if(!potential_target.mind)
			continue
		// While funny, please no.
		if(isanyantag(potential_target))
			continue
		// Hm.
		var/datum/species/S = all_species[potential_target.get_species()]
		if(S.flags[NO_DNA])
			continue
		// Okay the idea with changeling stings didn't work so now we actually change the race.
		// We change the race because if we don't some exotic species like Vox would not have
		// anyone they can be a doppleganger of.
		if(config.usealienwhitelist && !is_alien_whitelisted(H, potential_target.get_species()))
			continue

		target = potential_target

	if(!target)
		to_chat(H, "<span class='warning'>Проклятие! По какой-то причине ты клонировал сам себя!</span>")
		return

	H.set_species(target.get_species())

	H.dna = target.dna.Clone()
	H.real_name = target.dna.real_name
	H.flavor_text = target.flavor_text

	domutcheck(H, null)
	H.UpdateAppearance()

	H.fixblood(FALSE) // need to change blood DNA too

	if(istype(H.wear_id, /obj/item/weapon/card/id)) // check id card
		var/obj/item/weapon/card/id/wear_id = H.wear_id
		wear_id.assign(H.real_name)

		var/obj/item/device/pda/pda = locate() in H // find closest pda
		if(pda)
			pda.ownjob = wear_id.assignment
			pda.assign(H.real_name)


/datum/quality/quirkieish/loyal_golem
	name = "Loyal Golem"
	desc = "Ты очень умный тупой голем, а твой хозяин - НТ... или..."
	requirement = "Подопытный, но не злодей."

/datum/quality/quirkieish/loyal_golem/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return H.mind.role_alt_title == "Test Subject"

/datum/quality/quirkieish/loyal_golem/add_effect(mob/living/carbon/human/H, latespawn)
	H.set_species(GOLEM)
	H.f_style = "Shaved"
	H.h_style = "Bald"
	H.flavor_text = ""
	H.regenerate_icons()

	// In case the golem is evil don't make him a loyal dog of NT.
	if(isanyantag(H))
		return
	if(prob(10))
		return
	var/obj/item/weapon/implant/mind_protect/loyalty/L = new(H)
	L.inject(H, BP_CHEST)


/datum/quality/quirkieish/slime_person
	name = "Slimeperson"
	desc = "Ты един со слизнями."
	requirement = "Подопытный."

/datum/quality/quirkieish/slime_person/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return H.mind.role_alt_title == "Test Subject"

/datum/quality/quirkieish/slime_person/add_effect(mob/living/carbon/human/H, latespawn)
	H.set_species(SLIME)
	H.f_style = "Shaved"
	H.h_style = "Bald"
	H.regenerate_icons()


/datum/quality/quirkieish/very_special
	name = "Very Special"
	desc = "Ты ОЧЕНЬ особенный."
	requirement = "Да кто его знает!"

/datum/quality/quirkieish/very_special/add_effect(mob/living/carbon/human/H, latespawn)
	var/list/possible_qualities = subtypesof(/datum/quality) - /datum/quality/quirkieish/very_special

	for(var/i in 1 to 3)
		var/quality_type = pick(possible_qualities)
		possible_qualities -= quality_type

		var/datum/quality/quality = SSqualities.qualities_by_type[quality_type]
		if(quality.satisfies_requirements(H, latespawn))
			quality.add_effect(H, latespawn)

/datum/quality/quirkieish/prisoner
	name = "Prisoner"
	desc = "Ты загремел в каталажку за какое-то серьёзное преступление и, конечно, не собираешься исправляться."

	requirement = "Подопытный."

/datum/quality/quirkieish/prisoner/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return H.mind.role_alt_title == "Test Subject"

/datum/quality/quirkieish/prisoner/add_effect(mob/living/carbon/human/H, latespawn)
	if(latespawn == TRUE || jobban_isbanned(H, "Syndicate") || !(ROLE_TRAITOR in H.client.prefs.be_role))
		to_chat(H, "<span class='notice'>Тебя недавно отпустили по УДО, чтобы ты мог начать жизнь с чистого листа.</span>")
		return

	var/turf/T = pick(prisonerstart)
	H.forceMove(T)

	var/number = rand(100, 999)


	var/obj/item/weapon/card/id/ID = H.wear_id
	ID.assignment = "Prisoner"
	ID.rank = ID.assignment
	ID.name = "[ID.registered_name]'s ID Card ([ID.assignment] #[number])"

	var/obj/item/device/pda/PDA = H.belt
	PDA.ownjob = ID.assignment
	PDA.ownrank = ID.assignment
	PDA.name = "PDA-[PDA.owner] ([ID.assignment] #[number])"

	data_core.manifest_modify(ID.registered_name, ID.assignment)

	H.equip_to_slot(new /obj/item/clothing/under/color/orange(H), SLOT_W_UNIFORM)
	H.equip_to_slot(new /obj/item/clothing/shoes/orange(H), SLOT_SHOES)

	if(H.wear_suit)
		qdel(H.wear_suit)
	if(H.gloves)
		qdel(H.gloves)
	if(H.back)
		qdel(H.back)

	create_and_setup_role(/datum/role/prisoner, H)
	H.sec_hud_set_security_status()

/datum/quality/quirkieish/unrestricted
	name = "Unrestricted"
	desc = "В качестве особого эксперимента, НТ позволило вам занять любую должность на станции."
	requirement = "Прибыть на станцию после начала смены."
	max_amount = 1

/datum/quality/quirkieish/unrestricted/add_effect(mob/living/carbon/human/H, latespawn)
	//only for latespawners
	if(!latespawn)
		return
	var/datum/job/job = SSjob.GetJob(H.mind.assigned_role)
	//don't give paper if work is allowed by default for species
	if(job.is_species_permitted(H.get_species()))
		return
	var/obj/item/weapon/paper/P = new
	P.name = "Форма смены профессии или должности"
	P.info = "<center><img src = bluentlogo.png><br>Отдел Кадров Центрального Коммандования<br>Назначение на должность</center><hr>Полное имя составителя: [H.real_name]<br>Назначенная должность: [H.mind.assigned_role]<hr>Место для штампов."
	var/obj/item/weapon/stamp/centcomm/S = new
	S.stamp_paper(P)
	H.equip_or_collect(P, SLOT_L_HAND)
