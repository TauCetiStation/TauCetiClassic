/datum/game_mode
	var/abductor_teams = 0
	var/list/datum/mind/abductors = list()
	var/list/datum/mind/abductees = list()
	var/list/abduction_teams = list()

/datum/game_mode/abduction
	name = "abduction"
	config_tag = "abduction"
	role_type = ROLE_ABDUCTOR
	required_enemies = 2
	recommended_enemies = 2
	required_players = 15
	required_players_secret = 15
	var/max_teams = 4
	abductor_teams = 1
	var/list/datum/mind/scientists = list()
	var/list/datum/mind/agents = list()
	var/list/datum/objective/team_objectives = list()
	var/list/team_names = list()

	votable = 0

	var/finished = 0

/datum/game_mode/abduction/announce()
	to_chat(world, "<B>The current game mode is - Abduction!</B>")
	to_chat(world, "There are alien <b>abductors</b> sent to [world.name] to perform nefarious experiments!")
	to_chat(world, "<b>Abductors</b> - kidnap the crew and replace their organs with experimental ones.")
	to_chat(world, "<b>Crew</b> - don't get abducted and stop the abductors.")

/datum/game_mode/abduction/pre_setup()
	var/abductor_scaling_coeff = 15	////how many players per abductor team

	abductor_teams = max(1, min(max_teams,round(num_players()/abductor_scaling_coeff)))
	var/possible_teams = max(1,round(antag_candidates.len / 2))
	abductor_teams = min(abductor_teams,possible_teams)

	abductors.len = 2*abductor_teams
	scientists.len = abductor_teams
	agents.len = abductor_teams
	team_objectives.len = abductor_teams
	team_names.len = abductor_teams

	for(var/i in 1 to abductor_teams)
		if(!make_abductor_team(i))
			return 0

	return 1

/datum/game_mode/abduction/proc/make_abductor_team(team_number,preset_agent=null,preset_scientist=null)
	//Team Name
	team_names[team_number] = "Mothership [pick(possible_changeling_IDs)]" //TODO Ensure unique and actual alieny names
	abduction_teams += team_names[team_number]
	//Team Objective
	var/datum/objective/experiment/team_objective = new
	team_objective.team = team_number
	team_objectives[team_number] = team_objective
	//Team Members
	if(antag_candidates.len >= 2)
		var/datum/mind/scientist = pick(antag_candidates)
		antag_candidates -= scientist
		var/datum/mind/agent = pick(antag_candidates)
		antag_candidates -= agent

		scientist.assigned_role = "MODE"
		scientist.special_role = "Abductor scientist"
		log_game("[scientist.key] (ckey) has been selected as an abductor team [team_number] scientist.")

		agent.assigned_role = "MODE"
		agent.special_role = "Abductor agent"
		log_game("[agent.key] (ckey) has been selected as an abductor team [team_number] agent.")

		abductors |= agent
		abductors |= scientist
		scientists[team_number] = scientist
		agents[team_number] = agent

		return 1
	return 0

/datum/game_mode/abduction/post_setup()
	//Spawn Team
	var/list/obj/effect/landmark/abductor/agent_landmarks = new
	var/list/obj/effect/landmark/abductor/scientist_landmarks = new
	agent_landmarks.len = max_teams
	scientist_landmarks.len = max_teams
	for(var/obj/effect/landmark/abductor/A in landmarks_list)
		if(istype(A,/obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A,/obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

	var/datum/mind/agent
	var/obj/effect/landmark/L
	var/datum/mind/scientist
	var/team_name
	var/mob/living/carbon/human/abductor/H
	for(var/team_number in 1 to abductor_teams)
		team_name = team_names[team_number]
		agent = agents[team_number]
		H = agent.current
		L = agent_landmarks[team_number]
		H.loc = L.loc
		H.set_species("Abductor")
		H.agent = 1
		H.team = team_number
		H.real_name = team_name + " Agent"
		H.mind.name = H.real_name
		H.flavor_text = ""
		equip_common(H,team_number)
		equip_agent(H,team_number)
		greet_agent(agent,team_number)
		H.regenerate_icons()

		scientist = scientists[team_number]
		H = scientist.current
		L = scientist_landmarks[team_number]
		H.loc = L.loc
		H.set_species("Abductor")
		H.scientist = 1
		H.team = team_number
		H.real_name = team_name + " Scientist"
		H.mind.name = H.real_name
		H.flavor_text = ""
		equip_common(H,team_number)
		equip_scientist(H,team_number)
		greet_scientist(scientist,team_number)
		H.regenerate_icons()

	return ..()

//Used for create antag buttons
/datum/game_mode/abduction/proc/post_setup_team(team_number)
	var/list/obj/effect/landmark/abductor/agent_landmarks = new
	var/list/obj/effect/landmark/abductor/scientist_landmarks = new
	agent_landmarks.len = max_teams
	scientist_landmarks.len = max_teams
	for(var/obj/effect/landmark/abductor/A in landmarks_list)
		to_chat(world, "Found this [A]")
		if(istype(A,/obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A,/obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

	var/datum/mind/agent
	var/obj/effect/landmark/L
	var/datum/mind/scientist
	var/team_name
	var/mob/living/carbon/human/abductor/H

	team_name = team_names[team_number]
	agent = agents[team_number]
	H = agent.current
	L = agent_landmarks[team_number]
	H.loc = L.loc
	H.set_species("Abductor")
	H.agent = 1
	H.team = team_number
	H.real_name = team_name + " Agent"
	equip_common(H,team_number)
	equip_agent(H,team_number)
	greet_agent(agent,team_number)
	H.regenerate_icons()

	scientist = scientists[team_number]
	H = scientist.current
	L = scientist_landmarks[team_number]
	H.loc = L.loc
	H.set_species("Abductor")
	H.scientist = 1
	H.team = team_number
	H.real_name = team_name + " Scientist"
	equip_common(H,team_number)
	equip_scientist(H,team_number)
	greet_scientist(scientist,team_number)
	H.regenerate_icons()


/datum/game_mode/abduction/proc/greet_agent(datum/mind/abductor,team_number)
	abductor.objectives += team_objectives[team_number]
	var/team_name = team_names[team_number]

	to_chat(abductor.current, "<span class='info'><B>You are an <font color='red'>agent</font> of [team_name]!</B></span>")
	to_chat(abductor.current, "<span class='info'>With the help of your teammate, kidnap and experiment on station crew members!</span>")
	to_chat(abductor.current, "<span class='info'>Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve.</span>")

	var/obj_count = 1
	for(var/datum/objective/objective in abductor.objectives)
		to_chat(abductor.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return

/datum/game_mode/abduction/proc/greet_scientist(datum/mind/abductor,team_number)
	abductor.objectives += team_objectives[team_number]
	var/team_name = team_names[team_number]
	to_chat(abductor.current, "<span class='info'><B>You are a <font color='red'>scientist</font> of [team_name]!</B></span>")
	to_chat(abductor.current, "<span class='info'>With the help of your teammate, kidnap and experiment on station crew members!</span>")
	to_chat(abductor.current, "<span class='info'>Use your tool and ship consoles to support the agent and retrieve human specimens.</span>")
	var/obj_count = 1
	for(var/datum/objective/objective in abductor.objectives)
		to_chat(abductor.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return

/datum/game_mode/abduction/proc/equip_common(mob/living/carbon/human/agent,team_number)
	var/radio_freq = SYND_FREQ
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/syndicate/alt(agent)
	R.set_frequency(radio_freq)
	agent.equip_to_slot_or_del(R, slot_l_ear)
	agent.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(agent), slot_shoes)
	agent.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(agent), slot_w_uniform) //they're greys gettit
	agent.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(agent), slot_back)

/datum/game_mode/abduction/proc/get_team_console(team)
	var/obj/machinery/abductor/console/console
	for(var/obj/machinery/abductor/console/c in machines)
		if(c.team == team)
			console = c
			break
	return console

/datum/game_mode/abduction/proc/equip_agent(mob/living/carbon/human/agent,team_number)
	if(!team_number)
		team_number = agent.team

	var/obj/machinery/abductor/console/console = get_team_console(team_number)
	var/obj/item/clothing/suit/armor/abductor/vest/V = new /obj/item/clothing/suit/armor/abductor/vest(agent)
	if(console!=null)
		console.vest = V
	agent.equip_to_slot_or_del(V, slot_wear_suit)
	agent.equip_to_slot_or_del(new /obj/item/weapon/abductor_baton(agent), slot_in_backpack)
	agent.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/decloner/alien(agent), slot_belt)
	agent.equip_to_slot_or_del(new /obj/item/device/abductor/silencer(agent), slot_in_backpack)
	agent.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/abductor(agent), slot_head)

/datum/game_mode/abduction/proc/equip_scientist(mob/living/carbon/human/scientist,team_number)
	if(!team_number)
		team_number = scientist.team

	var/obj/machinery/abductor/console/console = get_team_console(team_number)
	var/obj/item/device/abductor/gizmo/G = new /obj/item/device/abductor/gizmo(scientist)
	if(console!=null)
		console.gizmo = G
		G.console = console
	scientist.equip_to_slot_or_del(G, slot_in_backpack)
	var/obj/item/weapon/implant/abductor/beamplant = new /obj/item/weapon/implant/abductor(scientist)
	beamplant.imp_in = scientist
	beamplant.implanted = 1
	beamplant.implanted(scientist)
	beamplant.home = console.pad

/datum/game_mode/abduction/check_finished()
	if(!finished)
		for(var/team_number in 1 to abductor_teams)
			var/obj/machinery/abductor/console/con = get_team_console(team_number)
			var/datum/objective/objective = team_objectives[team_number]
			if (con.experiment.points >= objective.target_amount)
				SSshuttle.incall(0.5)
				captain_announce("The emergency shuttle has been called. It will arrive in [round(SSshuttle.timeleft()/60)] minutes.")
				world << sound('sound/AI/shuttlecalled.ogg')
				finished = 1
				return ..()
	return ..()

/datum/game_mode/abduction/declare_completion()
	completion_text += "<B>Abduction mode resume:</B><br>"
	for(var/team_number in 1 to abductor_teams)
		var/obj/machinery/abductor/console/console = get_team_console(team_number)
		var/datum/objective/objective = team_objectives[team_number]
		var/team_name = team_names[team_number]
		if(console.experiment.points >= objective.target_amount)
			completion_text += "<B>[team_name]</B> team managed to <font color='green'><B>complete</B></font> their mission! "
			completion_text += "[live_check(team_number)]"
			completion_text += "[pick("Science of Galaxy","Greytide Science")] continues moving forward!<BR>"
		else
			completion_text += "<B>[team_name]</B> team <font color='red'>failed</font> their mission."
			completion_text += "[live_check(team_number)]"
			completion_text += "Station crew managed to stop [pick("Science of Galaxy","Greytide Science")].<BR>"
	..()
	return 1

/datum/game_mode/abduction/proc/live_check(team_number)
	var/alive = 0
	var/text = ""
	for(var/datum/mind/abductor in abductors)
		if(!ishuman(abductor.current))
			continue
		var/mob/living/carbon/human/A = abductor.current
		if((A.team == team_number) && (A.stat != DEAD))
			alive++
	if(alive >= 2)
		text += "All of them <B>alive</B>. "
	else
		text += "Someone from them is <B>dead</B>. "
	return text

/datum/game_mode/proc/auto_declare_completion_abduction()
	var/text = ""
	if(abductors.len)
		text += printlogo("abductor", "abductors")
		for(var/team_name in abduction_teams)
			text += "<BR><FONT size = 4, color = #800080><b>[team_name] members:</B></FONT>"

			for(var/datum/mind/abductor in abductors)
				if(findtext(abductor.name,team_name))
					text += printplayerwithicon(abductor)

					var/count = 1
					var/abductorwin = 1
					if(!config.objectives_disabled)
						for(var/datum/objective/objective in abductor.objectives)
							if(objective.check_completion())
								text += "<BR><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
								feedback_add_details("abductor_objective","[objective.type]|SUCCESS")
							else
								text += "<BR><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
								feedback_add_details("abductor_objective","[objective.type]|FAIL")
								abductorwin = 0
							count++

						if(abductor.current && abductor.current.stat!=2 && abductorwin)
							text += "<BR><font color='green'><B>The abductor was successful!</B></font>"
							feedback_add_details("abductor_success","SUCCESS")
							score["roleswon"]++
						else
							text += "<BR><font color='red'><B>The abductor has failed!</B></font>"
							feedback_add_details("abductor_success","FAIL")

		text += "<BR>"
		if(abductees.len)
			text += "<BR><B>The abductees were:</B>"
			for(var/datum/mind/abductee_mind in abductees)
				text += printplayer(abductee_mind)
				text += printobjectives(abductee_mind)
		text += "<BR><HR>"
	return text

//Landmarks
// TODO: Split into seperate landmarks for prettier ships
/obj/effect/landmark/abductor
	var/team = 1

/obj/effect/landmark/abductor/console/New()
	var/obj/machinery/abductor/console/c = new /obj/machinery/abductor/console(src.loc)
	c.team = team
	spawn(5)
		c.Initialize()
	qdel(src)

/obj/effect/landmark/abductor/agent
/obj/effect/landmark/abductor/scientist


// OBJECTIVES
/datum/objective/experiment
//	dangerrating = 10
	target_amount = 6
	var/team

/datum/objective/experiment/New()
	explanation_text = "Experiment on [target_amount] humans."

/datum/objective/experiment/check_completion()
	. = 0
	var/ab_team = team
	for(var/obj/machinery/abductor/experiment/E in machines)
		if(E.team == ab_team)
			if(E.points >= target_amount)
				return 1

/datum/objective/abductee
//	dangerrating = 5
	completed = 1

/datum/objective/abductee/steal
	explanation_text = "Steal all"

/datum/objective/abductee/steal/New()
	var/target = pick(list("pets","lights","monkeys","fruits","shoes","bars of soap"))
	explanation_text += " [target]."

datum/objective/abductee/capture
	explanation_text = "Capture"

/datum/objective/abductee/capture/New()
	var/list/jobs = get_job_datums()
	for(var/datum/job/J in jobs)
		if(J.current_positions < 1)
			jobs -= J
	if(jobs.len > 0)
		var/datum/job/target = pick(jobs)
		explanation_text += " a [target.title]."
	else
		explanation_text += " someone."

/datum/objective/abductee/shuttle
	explanation_text = "You must escape the station! Get the shuttle called!"

/datum/objective/abductee/noclone
	explanation_text = "Don't allow anyone to be cloned."

/datum/objective/abductee/blazeit
	explanation_text = "Your body must be improved. Ingest as many drugs as you can."

/datum/objective/abductee/yumyum
	explanation_text = "You are hungry. Eat as much food as you can find."

/datum/objective/abductee/insane
	explanation_text = "You see you see what they cannot you see the open door you seeE you SEeEe you SEe yOU seEee SHOW THEM ALL"

/datum/objective/abductee/cannotmove
	explanation_text = "Convince the crew that you are a paraplegic."

/datum/objective/abductee/deadbodies
	explanation_text = "Start a collection of corpses. Don't kill people to get these corpses."

/datum/objective/abductee/floors
	explanation_text = "Replace all the floor tiles with carpeting, wooden boards, or grass."

/datum/objective/abductee/POWERUNLIMITED
	explanation_text = "Flood the station's powernet with as much electricity as you can."

/datum/objective/abductee/pristine
	explanation_text = "Ensure the station is in absolutely pristine condition."

/datum/objective/abductee/window
	explanation_text = "Replace all normal windows with reinforced windows."

/datum/objective/abductee/nations
	explanation_text = "Ensure your department prospers over all else."

/datum/objective/abductee/abductception
	explanation_text = "You have been changed forever. Find the ones that did this to you and give them a taste of their own medicine."

/datum/objective/abductee/ghosts
	explanation_text = "Conduct a seance with the spirits of the afterlife."

/datum/objective/abductee/summon
	explanation_text = "Conduct a ritual to summon an elder god."

/datum/objective/abductee/machine
	explanation_text = "You are secretly an android. Interface with as many machines as you can to boost your own power."

/datum/objective/abductee/prevent
	explanation_text = "You have been enlightened. This knowledge must not escape. Ensure nobody else can become enlightened."

/datum/objective/abductee/calling
	explanation_text = "Call forth a spirit from the other side."

/datum/objective/abductee/calling/New()
	var/mob/dead/D = pick(dead_mob_list)
	if(D)
		explanation_text = "You know that [D] has perished. Call them from the spirit realm."

/datum/objective/abductee/social_experiment
	explanation_text = "This is a secret social experiment conducted by Nanotrasen. Convince the crew that this is the truth."

/datum/objective/abductee/vr
	explanation_text = "It's all an entirely virtual simulation within an underground vault. Convince the crew to escape the shackles of VR."

/datum/objective/abductee/pets
	explanation_text = "Nanotrasen is abusing the animals! Save as many as you can!"

/datum/objective/abductee/defect
	explanation_text = "Defect from your employer."

/datum/objective/abductee/promote
	explanation_text = "Climb the corporate ladder all the way to the top!"

/datum/objective/abductee/science
	explanation_text = "So much lies undiscovered. Look deeper into the machinations of the universe."

/datum/objective/abductee/build
	explanation_text = "Expand the station."

/datum/objective/abductee/pragnant
	explanation_text = "You are pregnant and soon due. Find a safe place to deliver your baby."
