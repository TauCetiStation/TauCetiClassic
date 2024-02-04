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

	antag_hud_type = ANTAG_HUD_CULT
	antag_hud_name = "hudmaelstrom"

	logo_state = "maelstrom_member-logo"

	moveset_type = /datum/combat_moveset/cult
	skillset_type = /datum/skillset/cyborg
	change_to_maximum_skills = TRUE

/datum/role/cyberpsycho/Greet(greeting, custom)
	if(!..())
		return FALSE
	antag.current.playsound_local(null, 'sound/antag/cultist_alert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	to_chat(antag.current, "<span class='cult'>Вы - головорез-оккультист банды Мальстром.</span>")
	to_chat(antag.current, "<span class='cult'>Кибернетика ваш бог, ваше тело это платформа для безумных незаконных модификаций.</span>")
	to_chat(antag.current, "<span class='cult'>Фирменный имплант, вживляемый в руку, позволяет использовать блюспейс технологии.</span>")

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
		return
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
