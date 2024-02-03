/datum/role/cultist
	name = CULTIST
	id = CULTIST

	required_pref = ROLE_CULTIST
	restricted_jobs = list("Security Cadet", "Chaplain", "AI", "Cyborg", "Security Officer", "Warden", "Head of Security", "Captain", "Internal Affairs Agent", "Blueshield Officer")
	restricted_species_flags = list(NO_BLOOD)

	antag_hud_type = ANTAG_HUD_CULT
	antag_hud_name = "hudcultist"

	logo_state = "cult-logo"

	var/holy_rank = CULT_ROLE_HIGHPRIEST
	moveset_type = /datum/combat_moveset/cult
	skillset_type = /datum/skillset/cultist
	change_to_maximum_skills = TRUE

/datum/role/cultist/Greet(greeting, custom)
	if(!..())
		return FALSE
	antag.current.playsound_local(null, 'sound/antag/cultist_alert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	to_chat(antag.current, "<span class='cult'>Вы - Культист, поклоняющийся древнему богу Нар-Си. Вам была дарована потустороняя сила для достижения поставленых целей. Если вы их не выполните, то вас ждёт СТРАШНАЯ КАРА...</span>")
	to_chat(antag.current, "<span class='cult'>Вам был дарован том древних писаний культа. Открыв том, вы сможете начертить различные руны которые позволят вам: телепортироваться, отправляя предметы или же себя в Рай, захватывать зоны станции, призывать невидимые баръеры и активировать древние кристаллы - пилоны, для быстрого уничтожения неверных.</span>")
	to_chat(antag.current, "<span class='cult'>Помимо рун, том способен возводить строения культа необходимых вам в вашем противостоянии против еретиков, обустраивать комнату для проведения нужных ритуалов или же перестроить уже существующие отделы(для строительства вам необходимо исследовать Строительство везде или же возводить строения на захваченых территориях).</span>")
	to_chat(antag.current, "<span class='cult'>Благодаря руне Телепорт в Рай, вы можете попасть в обитель культа где вы можете проводить свои исследования(для выбора необходимого исследования, нажмите на письменный стол пустой рукой), приковать неверных к пыточным столам для пыток или особых ритуалов(не забудьте зарядить стол нажав на него томом), а также кузница где хранятся одеяния и орудия культа(чтобы взаимодействовать с кузницей, нужно нажать на нее пустой рукой).</span>")
	to_chat(antag.current, "<span class='cult'>Более подробная информация о ритуалах, аспектах, текущему положению дел культа вы найдете в томе у алтаря(возмите том, нажмите им по алтарю чтобы открыть меню алтаря культа). Есди вы осмотрите сам том, то вы узнаете сколько в культе последователей, сколько накоплено Благосклонности(Favor) и Благочестия(Piety), сколько рун вы используете в данный момент и максимальное возможное количество рун которое может выдержать ваше тело или же убрать все начертаные вами руны.</span>")

/datum/role/cultist/CanBeAssigned(datum/mind/M, laterole)
	if(laterole == FALSE) // can be null
		return ..() // religion has all necessary checks, but they are not applicable to mind, as here
	return TRUE

/datum/role/cultist/RemoveFromRole(datum/mind/M, msg_admins)
	..()
	var/datum/faction/cult/C = faction
	if(istype(C))
		C.religion?.remove_member(M.current)

/datum/role/cultist/proc/equip_cultist(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if(mob.mind)
		if(mob.mind.assigned_role == "Clown")
			to_chat(mob, "Ваши тренировки позволили вам преодолеть клоунскую неуклюжесть, что позволит вам без вреда для себя применять любое вооружение.")
			REMOVE_TRAIT(mob, TRAIT_CLUMSY, GENETIC_MUTATION_TRAIT)

	mob.equip_to_slot_or_del(new /obj/item/device/cult_camera(mob), SLOT_IN_BACKPACK)

	var/datum/faction/cult/C = faction
	if(istype(C))
		C.religion.give_tome(mob)

/datum/role/cultist/OnPostSetup(laterole)
	..()
	if(!laterole)
		equip_cultist(antag.current)
	var/datum/faction/cult/C = faction
	if(istype(C))
		C.religion.add_member(antag.current, holy_rank)

/datum/role/cultist/extraPanelButtons()
	var/dat = ..()
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];cult_tome=1;'>(Give Tome)</a>"
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];cult_heaven=1;'>(TP to Heaven)</a>"
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];cult_cheating=1;'>(Cheating Religion)</a>"
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];cult_leader=1;'>(Make Leader)</a>"
	return dat

/datum/role/cultist/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	var/datum/faction/cult/C = faction
	if(istype(C))
		if(href_list["cult_tome"])
			var/mob/living/carbon/human/H = M.current
			if(istype(H))
				if(C.religion)
					C.religion.give_tome(H)

		if(href_list["cult_heaven"])
			var/area/A = locate(C.religion.area_type)
			var/turf/T = get_turf(pick(A.contents))
			M.current.forceMove(T)

		if(href_list["cult_cheating"])
			C.religion.favor = 100000
			C.religion.piety = 100000
			// All aspects
			var/list/L = subtypesof(/datum/aspect)
			for(var/type in L)
				L[type] = 1
			C.religion.add_aspects(L)

		if(href_list["cult_leader"])
			var/mob/living/carbon/human/H = M.current
			H.mind.holy_role = CULT_ROLE_MASTER
			add_antag_hud("hudheadcultist")
	else
		to_chat(M.current, "Сначала добавьте культиста во фракцию культа")

/datum/role/cultist/leader
	name = CULT_LEADER

	antag_hud_type = ANTAG_HUD_CULT
	antag_hud_name = "hudheadcultist"

	holy_rank = CULT_ROLE_MASTER
	skillset_type = /datum/skillset/cultist/leader

/datum/role/cyberpsycho
	name = CYBERPSYCHO
	id = CYBERPSYCHO

	required_pref = ROLE_CULTIST
	required_jobs = list("Cargo Technician",
						"Shaft Miner",
						"Recycler",
						"Chef",
						"Bartender",
						"Botanist",
						"Clown",
						"Mime",
						"Chaplain",
						"Janitor",
						"Barber",
						"Librarian",
						"Assistant")
	restricted_species_flags = list(IS_SYNTHETIC)

	antag_hud_type = ANTAG_HUD_CULT
	antag_hud_name = "hudcultist"

	logo_state = "cult-logo"

	moveset_type = /datum/combat_moveset/cult
	skillset_type = /datum/skillset/cultist
	change_to_maximum_skills = TRUE

/datum/role/cyberpsycho/Greet(greeting, custom)
	if(!..())
		return FALSE
	antag.current.playsound_local(null, 'sound/antag/cultist_alert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	to_chat(antag.current, "<span class='cult'>Вы - Культист, поклоняющийся древнему богу Нар-Си. Вам была дарована потустороняя сила для достижения поставленых целей. Если вы их не выполните, то вас ждёт СТРАШНАЯ КАРА...</span>")
	to_chat(antag.current, "<span class='cult'>Вам был дарован том древних писаний культа. Открыв том, вы сможете начертить различные руны которые позволят вам: телепортироваться, отправляя предметы или же себя в Рай, захватывать зоны станции, призывать невидимые баръеры и активировать древние кристаллы - пилоны, для быстрого уничтожения неверных.</span>")
	to_chat(antag.current, "<span class='cult'>Помимо рун, том способен возводить строения культа необходимых вам в вашем противостоянии против еретиков, обустраивать комнату для проведения нужных ритуалов или же перестроить уже существующие отделы(для строительства вам необходимо исследовать Строительство везде или же возводить строения на захваченых территориях).</span>")
	to_chat(antag.current, "<span class='cult'>Благодаря руне Телепорт в Рай, вы можете попасть в обитель культа где вы можете проводить свои исследования(для выбора необходимого исследования, нажмите на письменный стол пустой рукой), приковать неверных к пыточным столам для пыток или особых ритуалов(не забудьте зарядить стол нажав на него томом), а также кузница где хранятся одеяния и орудия культа(чтобы взаимодействовать с кузницей, нужно нажать на нее пустой рукой).</span>")
	to_chat(antag.current, "<span class='cult'>Более подробная информация о ритуалах, аспектах, текущему положению дел культа вы найдете в томе у алтаря(возмите том, нажмите им по алтарю чтобы открыть меню алтаря культа). Есди вы осмотрите сам том, то вы узнаете сколько в культе последователей, сколько накоплено Благосклонности(Favor) и Благочестия(Piety), сколько рун вы используете в данный момент и максимальное возможное количество рун которое может выдержать ваше тело или же убрать все начертаные вами руны.</span>")

/datum/role/cyberpsycho/CanBeAssigned(datum/mind/M, laterole)
	// can be null
	if(laterole == FALSE)
		return ..()
	return TRUE

/datum/role/cyberpsycho/proc/equip_cultist(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if(mob.mind)
		if(mob.mind.assigned_role == "Clown")
			to_chat(mob, "Ваши тренировки позволили вам преодолеть клоунскую неуклюжесть, что позволит вам без вреда для себя применять любое вооружение.")
			REMOVE_TRAIT(mob, TRAIT_CLUMSY, GENETIC_MUTATION_TRAIT)

	if(SEND_SIGNAL(mob, COMSIG_DETECT_MAELSTROM_IMPLANT) & COMPONENT_IMPLANT_DETECTED)
		give_implant(mob)

/datum/role/cyberpsycho/OnPostSetup(laterole)
	..()
	if(!laterole)
		equip_cultist(antag.current)

/datum/role/cyberpsycho/extraPanelButtons()
	var/dat = ..()
	dat += " - <a href='?src=\ref[antag];mind=\ref[antag];role=\ref[src];cult_implant=1;'>(Give Implant)</a>"
	return dat

/datum/role/cyberpsycho/RoleTopic(href, href_list, datum/mind/M, admin_auth)
	if(href_list["cult_implant"])
		var/mob/living/carbon/human/H = M.current
		give_implant(H)

/datum/role/cyberpsycho/proc/give_implant(mob/living/carbon/human/cultist)
	var/obj/item/weapon/implant/maelstrom/M = new(cultist)
	M.inject(cultist, pick(BP_R_ARM, BP_L_ARM))

/obj/item/weapon/implant/maelstrom
	icon_state = "implant_blood"
	item_action_types = list(/datum/action/item_action/implant/maelstrom)

/obj/item/weapon/implant/maelstrom/atom_init()
	. = ..()
	AddElement(/datum/element/maelstrom)

/datum/action/item_action/implant/maelstrom
	name = "Maelstrom Implant"

/obj/item/weapon/implantcase/maelstrom
	name = "Glass Case- 'Maelstrom'"
	desc = "A case containing an illegal implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/weapon/implantcase/maelstrom/atom_init()
	imp = new /obj/item/weapon/implant/maelstrom(src)
	. = ..()

/obj/item/weapon/implanter/maelstrom/atom_init()
	imp = new /obj/item/weapon/implant/maelstrom(src)
	. = ..()
	update()

/obj/effect/temp_visual/cult/sparks/purple
	name = "purple sparks"
	icon_state = "purplesparkles"

/obj/effect/temp_visual/cult/sparks/quantum
	name = "quantum sparks"
	icon_state = "quantum_sparks"
