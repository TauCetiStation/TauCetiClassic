/datum/role/abductor
	disallow_job = TRUE
	required_pref = ROLE_ABDUCTOR

	antag_hud_type = ANTAG_HUD_ABDUCTOR
	antag_hud_name = "abductor"

	logo_state = "abductor-logo"
	skillset_type = /datum/skillset/abductor

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
	agent.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(agent), SLOT_SHOES)
	agent.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(agent), SLOT_W_UNIFORM) //they're greys gettit
	agent.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(agent), SLOT_BACK)

/datum/role/abductor/proc/equip_class()
	return

/datum/role/abductor/proc/move_to_positions()
	return

/datum/role/abductor/OnPostSetup(laterole)
	. = ..()
	move_to_positions()
	var/mob/living/carbon/human/abductor/H = antag.current
	H.set_species(ABDUCTOR)
	H.real_name = "[pick(global.greek_pronunciation)]" + " " + name
	H.mind.name = H.real_name
	H.f_style = "Shaved"
	H.h_style = "Bald"
	H.flavor_text = ""
	equip_common(H)
	equip_class()
	H.regenerate_icons()
	SEND_SIGNAL(antag.current, COMSIG_ADD_MOOD_EVENT, "abductor", /datum/mood_event/abductor)
	return TRUE

/datum/role/abductor/agent
	name = "Agent"
	id = ABDUCTOR_AGENT
	skillset_type = /datum/skillset/abductor/agent

/datum/role/abductor/agent/Greet(greeting, custom)
	if(!..())
		return FALSE

	to_chat(antag.current, "<span class='info'>Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve.</span>")

	return TRUE

/datum/role/abductor/agent/move_to_positions()
	var/datum/faction/abductors/mothership = faction
	if(mothership)
		var/obj/effect/landmark/L = agent_landmarks[clamp(mothership.num_agents, 1, 4)]
		antag.current.forceMove(L.loc)

/datum/role/abductor/agent/equip_class()
	var/mob/living/carbon/human/agent = antag.current
	var/obj/item/clothing/suit/armor/abductor/vest/V = new /obj/item/clothing/suit/armor/abductor/vest(agent)
	var/obj/item/weapon/abductor_baton/B = new(agent)
	agent.equip_to_slot_or_del(V, SLOT_WEAR_SUIT)
	agent.equip_to_slot_or_del(B, SLOT_IN_BACKPACK)
	agent.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/decloner/alien(agent), SLOT_BELT)
	agent.equip_to_slot_or_del(new /obj/item/device/abductor/silencer(agent), SLOT_IN_BACKPACK)
	agent.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/abductor(agent), SLOT_HEAD)

/datum/role/abductor/scientist
	name = "Scientist"
	id = ABDUCTOR_SCI
	skillset_type = /datum/skillset/abductor/scientist

/datum/role/abductor/scientist/Greet(greeting, custom)
	if(!..())
		return FALSE

	to_chat(antag.current, "<span class='info'>Use your tool and ship consoles to support the agent and retrieve human specimens.</span>")

	return TRUE

/datum/role/abductor/scientist/move_to_positions()
	var/datum/faction/abductors/mothership = faction
	if(mothership)
		var/obj/effect/landmark/L = scientist_landmarks[clamp(mothership.num_scientists, 1, 4)]
		antag.current.forceMove(L.loc)

/datum/role/abductor/scientist/equip_class()
	var/mob/living/carbon/human/scientist = antag.current
	var/obj/item/device/abductor/gizmo/G = new /obj/item/device/abductor/gizmo(scientist)
	scientist.equip_to_slot_or_del(G, SLOT_IN_BACKPACK)

	var/datum/faction/abductors/A = faction
	if(!istype(A))
		return

	var/obj/item/weapon/implant/abductor/beamplant = new /obj/item/weapon/implant/abductor(scientist)
	beamplant.imp_in = scientist
	beamplant.implanted = 1
	beamplant.implanted(scientist)
	for(var/obj/machinery/abductor/console/console in range(2, scientist))
		console.gizmo = G
		G.console = console
		beamplant.home = console.pad
		break

/datum/role/abductor/assistant
	name = "Assistant"
	id = ABDUCTOR_ASSISTANT
	skillset_type = /datum/skillset/abductor/scientist

/datum/role/abductor/assistant/equip_common()
	return

/datum/role/abductor/assistant/Greet(greeting, custom)
	if(!..())
		return FALSE

	to_chat(antag.current, "<span class='info'>Help your team. Do the operations for them, look for test subjects, or what is the assistant doing there?</span>")

	return TRUE
