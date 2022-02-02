/datum/role/abductor
	disallow_job = TRUE
	required_pref = ROLE_ABDUCTOR

	antag_hud_type = ANTAG_HUD_ABDUCTOR
	antag_hud_name = "abductor"

	logo_state = "abductor-logo"
	skills_type = /datum/skills/abductor

/datum/role/abductor/Greet(greeting, custom)
	if(!..())
		return FALSE

	to_chat(antag.current, "<span class='info'><B>You are an <font color='red'>[name]</font> of [faction.name]!</B></span>")
	to_chat(antag.current, "<span class='info'>With the help of your teammate, kidnap and experiment on station crew members!</span>")

	return TRUE

/datum/role/abductor/proc/equip_common()
	var/mob/living/carbon/human/agent = antag.current
	var/radio_freq = SYND_FREQ
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate/alt(agent)
	R.set_frequency(radio_freq)
	agent.equip_to_slot_or_del(R, SLOT_L_EAR)
	agent.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots/combat(agent), SLOT_SHOES)
	agent.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(agent), SLOT_W_UNIFORM) //they're greys gettit
	agent.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(agent), SLOT_BACK)

/datum/role/abductor/proc/equip_class()
	return

/datum/role/abductor/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/abductor/H = antag.current
	H.set_species(ABDUCTOR)
	var/faction_name = faction ? faction.name : ""
	H.real_name = faction_name + " " + name
	H.mind.name = H.real_name
	H.flavor_text = ""
	equip_common(H)
	equip_class()
	H.regenerate_icons()

	return TRUE

/datum/role/abductor/proc/get_team_num()
	var/datum/faction/abductors/A = faction
	return istype(A) && A.team_number

/datum/role/abductor/agent
	name = "Agent"
	id = ABDUCTOR_AGENT
	skills_type = /datum/skills/abductor/agent

/datum/role/abductor/agent/Greet(greeting, custom)
	if(!..())
		return FALSE

	to_chat(antag.current, "<span class='info'>Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve.</span>")

	return TRUE

/datum/role/abductor/agent/equip_class()
	var/mob/living/carbon/human/agent = antag.current
	var/obj/item/clothing/suit/armor/abductor/vest/V = new /obj/item/clothing/suit/armor/abductor/vest(agent)
	agent.equip_to_slot_or_del(V, SLOT_WEAR_SUIT)
	agent.equip_to_slot_or_del(new /obj/item/weapon/abductor_baton(agent), SLOT_IN_BACKPACK)
	agent.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/decloner/alien(agent), SLOT_BELT)
	agent.equip_to_slot_or_del(new /obj/item/device/abductor/silencer(agent), SLOT_IN_BACKPACK)
	agent.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/abductor(agent), SLOT_HEAD)

	var/datum/faction/abductors/A = faction
	if(!istype(A))
		return
	var/obj/machinery/abductor/console/console = A.get_team_console()
	if(console)
		console.vest = V

/datum/role/abductor/scientist
	name = "Scientist"
	id = ABDUCTOR_SCI
	skills_type = /datum/skills/abductor/scientist

/datum/role/abductor/scientist/Greet(greeting, custom)
	if(!..())
		return FALSE

	to_chat(antag.current, "<span class='info'>Use your tool and ship consoles to support the agent and retrieve human specimens.</span>")

	return TRUE

/datum/role/abductor/scientist/equip_class()
	var/mob/living/carbon/human/scientist = antag.current
	var/obj/item/device/abductor/gizmo/G = new /obj/item/device/abductor/gizmo(scientist)
	scientist.equip_to_slot_or_del(G, SLOT_IN_BACKPACK)

	var/datum/faction/abductors/A = faction
	if(!istype(A))
		return

	var/obj/machinery/abductor/console/console = A.get_team_console()
	var/obj/item/weapon/implant/abductor/beamplant = new /obj/item/weapon/implant/abductor(scientist)
	beamplant.imp_in = scientist
	beamplant.implanted = 1
	beamplant.implanted(scientist)
	if(console)
		console.gizmo = G
		G.console = console
		beamplant.home = console.pad

/datum/role/abducted
	name = ABDUCTED
	id = ABDUCTED

	logo_state = "abductor-logo"

	antag_hud_type = ANTAG_HUD_ABDUCTOR
	antag_hud_name = "abductee"

/datum/role/abducted/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(pick(subtypesof(/datum/objective/abductee)))
	return TRUE
