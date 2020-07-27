/*
VOX HEIST ROUNDTYPE
*/

/datum/game_mode
	var/list/datum/mind/raiders = list()

/datum/game_mode/heist
	name = "heist"
	config_tag = "heist"
	role_type = ROLE_RAIDER
	required_players = 15
	required_players_secret = 15
	required_enemies = 4
	recommended_enemies = 6

	votable = 0

	var/list/raid_objectives = list()
	var/list/cortical_stacks = list() //Stacks for 'leave nobody behind' objective.

/datum/game_mode/heist/announce()
	to_chat(world, "<B>The current game mode is - Heist!</B>")
	to_chat(world, "<B>An unidentified bluespace signature has slipped past the Icarus and is approaching [station_name()]!</B>")
	to_chat(world, "Whoever they are, they're likely up to no good. Protect the crew and station resources against this dastardly threat!")
	to_chat(world, "<B>Raiders:</B> Loot [station_name()] for anything and everything you need.")
	to_chat(world, "<B>Personnel:</B> Repel the raiders and their low, low prices and/or crossbows.")

/datum/game_mode/heist/can_start()
	if (!..())
		return FALSE
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "voxstart")
			return TRUE
	return FALSE

/datum/game_mode/heist/assign_outsider_antag_roles()
	if(!..())
		return FALSE

	var/raider_num = recommended_enemies

	//Check that we have enough vox.
	if(antag_candidates.len < recommended_enemies)
		raider_num = antag_candidates.len

	//Grab candidates randomly until we have enough.
	while(raider_num > 0)
		var/datum/mind/new_raider = pick(antag_candidates)
		raiders += new_raider
		modePlayer += new_raider
		antag_candidates -= new_raider
		raider_num--

	for(var/datum/mind/raider in raiders)
		raider.assigned_role = "MODE"
		raider.special_role = "Vox Raider"
	return TRUE

/datum/game_mode/heist/pre_setup()
	return TRUE

/datum/game_mode/heist/post_setup()

	//Build a list of spawn points.
	var/list/turf/raider_spawn = list()

	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "voxstart")
			raider_spawn += get_turf(L)
			qdel(L)
			continue

	//Generate objectives for the group.
	if(!config.objectives_disabled)
		raid_objectives = forge_vox_objectives()

	var/index = 1

	//Spawn the vox!
	for(var/datum/mind/raider in raiders)

		if(index > raider_spawn.len)
			index = 1

		raider.current.loc = raider_spawn[index]
		index++

		var/sounds = rand(2, 8)
		var/i = 0
		var/newname = ""

		while(i <= sounds)
			i++
			newname += pick(list("ti","hi","ki","ya","ta","ha","ka","ya","chi","cha","kah"))

		var/mob/living/carbon/human/vox = raider.current

		vox.real_name = capitalize(newname)
		vox.name = vox.real_name
		raider.name = vox.name
		vox.age = rand(vox.species.min_age, vox.species.max_age)
		vox.dna.mutantrace = "vox"
		vox.set_species(VOX)
		vox.languages = list() // Removing language from chargen.
		vox.flavor_text = ""
		vox.add_language("Vox-pidgin")
		if(index == 2 || prob(33)) // first vox always gets Sol, everyone else by random.
			vox.add_language("Sol Common")
		vox.h_style = "Short Vox Quills"
		vox.f_style = "Shaved"
		vox.grad_style = "none"
		for(var/obj/item/organ/external/BP in vox.bodyparts)
			BP.status = 0 // rejuvenate() saves prostethic limbs, so we tell it NO.
			BP.rejuvenate()

		//Now apply cortical stack.
		var/obj/item/organ/external/BP = vox.bodyparts_by_name[BP_HEAD]

		var/obj/item/weapon/implant/cortical/I = new(vox)
		I.imp_in = vox
		I.implanted = TRUE
		BP.implants += I
		I.part = BP

		cortical_stacks[raider] = I

		vox.equip_vox_raider()
		vox.regenerate_icons()

		raider.objectives = raid_objectives
		greet_vox(raider)

	return ..()

/datum/game_mode/heist/proc/is_raider_crew_safe()

	if(cortical_stacks.len == 0)
		return FALSE

	for(var/datum/mind/vox in cortical_stacks)
		if(get_area(cortical_stacks[vox]) != locate(/area/shuttle/vox/arkship))
			return FALSE

	return TRUE

/datum/game_mode/heist/proc/is_raider_crew_alive()
	for(var/datum/mind/raider in raiders)
		if(ishuman(raider.current) && raider.current.stat == DEAD)
			return TRUE

	return FALSE

/datum/game_mode/heist/proc/forge_vox_objectives()

	var/i = 1
	var/max_objectives = pick(2,2,2,2,3,3,3,4)
	var/list/objs = list()

	while(i <= max_objectives)
		var/list/goals = list("kidnap","loot","salvage")
		var/goal = pick(goals)
		var/datum/objective/heist/O

		if(goal == "kidnap")
			goals -= "kidnap"
			O = new /datum/objective/heist/kidnap()
		else if(goal == "loot")
			O = new /datum/objective/heist/loot()
		else
			O = new /datum/objective/heist/salvage()
		O.choose_target()
		objs += O

		i++

	//-All- vox raids have these two (one) objectives. Failing them loses the game.
	objs += new /datum/objective/heist/inviolate_crew
	objs += new /datum/objective/heist/inviolate_death

	return objs

/datum/game_mode/heist/proc/greet_vox(datum/mind/raider)
	to_chat(raider.current, "<span class='notice'><B>You are a Vox Raider, fresh from the Shoal!</b></span>")
	to_chat(raider.current, "<span class='notice'>The Vox are a race of cunning, sharp-eyed nomadic raiders and traders endemic to [system_name()] and much of the unexplored galaxy. You and the crew have come to the Exodus for plunder, trade or both.</span>")
	to_chat(raider.current, "<span class='notice'>Vox are cowardly and will flee from larger groups, but corner one or find them en masse and they are vicious.</span>")
	to_chat(raider.current, "<span class='notice'>Use :V to voxtalk, :H to talk on your encrypted channel, and don't forget to turn on your nitrogen internals!</span>")
	to_chat(raider.current, "<span class='warning'>IF YOU HAVE NOT PLAYED A VOX BEFORE, REVIEW THIS THREAD: tauceti.ru/wiki/Vox_Raider</span>")
	var/obj_count = 1
	if(!config.objectives_disabled)
		for(var/datum/objective/objective in raider.objectives)
			to_chat(raider.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++
	else
		to_chat(raider.current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew or come up with other fun ideas. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")

	var/output_text = {"<font color='red'>============���������� - ������� ����============</font><BR>
	<font color='red'>[sanitize("������ ������������� ������������ ��� � ���� ������� ��� ����� ������ - http://tauceti.ru/wiki/Vox_Raider")]</font><BR>
	[sanitize("- ���������! ����� ������� �� ������� �����! ������ ������ �� ������ ������ �������� �������. � �������: ������ ������ � 4-��, ������ � 4-�� � ������ ���������, ������ ��� �������� (���� ���� ����� �������, ���� ��������)!")]<BR>
	[sanitize("- �� - �� ������ (�����). ��� �� ���� ������ ��� ��� �� ������� � ����, ���������� �������������� ����� �����. ��� ������ �� ����������� � ������, ��� ���� ����� ����, ��� ���-������ �� ��� ��������� � ������������. �� ���� ������ ������ �� ���� � �������� ���, ���� ���� (�� ������ ���� �� ������ ��� ��������, � �� ���-�� ���� ����� �����, �� � �� ������ ������ ���������� \"���\" � ��������������, � ��������� ������� ����� ������ �� ��������).")]<BR>
	[sanitize("- ����� �� ����� �������? �����. ������ ��� ������� �� ����� ��� ������ ���������� � ���������������, ��������� ���� �� ����� ����. ��� ������ �������� ������ ���� ������� � ��������, ���������� �� � ���� �� ������ � ������ ��� ������ ����� �������, �� ������ � �� ������. ���� ���� ����� ���� �� ������������ ������� ��������� � ���� ������ ����� ������� � ����� ���� - �������� ����� ���������������, ������ � ���� ����� ��� ����� �� ���������, � ���� �� ��������, �� ���, ����� ��� �� ��������� ��������� �������. �� ������� � ������������ � ������� ����� �������� �� ��� ���� ��������.")]<BR>
	<font color='red'>============������ ����������============</font><BR>
	[sanitize("- �������� �� ��� ����� ������� �� ����, �� ��� ��� ��������. ��� ��� ����� :1 - � ������ �������� ����� ���������� � \"IC > check known languages\"")]<BR>
	[sanitize("- cloaking field terminal ������� �������� ��� ������� ����� ����� �������� - ����� �� ����� �������� ����������� ���������� � ����������� ��� �������� �����. ����� �� ����.")]<BR>
	[sanitize("- �������� (spike thrower) ����� ����������� �����, ������ ����������� \"�����\" ���������� ��� � 10 ������ � ��� ����� ������ ������ ���� - �������� �������� ���������� �� 5 ��������� � ���� ����������� � �����, �����, ����� ��� ��� ������� ���������� ���� ���� ���� ��� �� ������� ���������� ���.")]<BR>
	[sanitize("- � ����� ����� �� ������� ��� ������� \"debugger\". � ������� ��� ����� \"�������\" ����� � apc. ������, ��� ����� ����� ����� ��������� �������� � �� ���������� ����� ������� (���������� ��������������� ������� ����� � ����� � ����� ���������� ����������).")]<BR>
	[sanitize("- ��� ������������ ����������� ��������� � ������� � ���������� ������� �� ������� � ���� �� �������, � ������ ������� ������������� ��� ����� �������� ���������� ������� �� ��������� �������� (��� ������ ��� ������� ���������� � �����), � �� ����� ��� �������� �������� (�� ������ ���������������� �������).")]<BR>
	[sanitize("- ������ �����-����� ����� ������� ������ (���� ��������� �����������), ������ ������ ���� ����� ��� �������� � ��������. �� ����� ������� ����� ��������� �������� ���� ��� �������� ���������.")]<BR>
	[sanitize("- � ��� ���� ����������� \"Leap\" � �� ������ ������������ �� ���� ��� ������� ������� � ������������ ����� ����� ��� ������. ��� ������������ � ���������, �� �������� ��� � ��� � ����� �������� � ����������� \"����\". ������� � ����������� ������ 10-�� �������� � ���������� �� ������� �� ������� �������, ����� ��� ����� � ������� � ����� ���, � ��� ��� ��������� � 4 ��������.")]<BR>
	[sanitize("- ��������� ������ �������� � �������� ������� �� ���� ��� ����� ����. ������� (�������� ��������). ���� ������������ ����� � ������������� ����� � ������ (���� ��� ������� ������), � ����������� \"Leap\" ����� ����� �������� ��� ���.")]<BR>
	[sanitize("- � ��������� - ���������� ������ ��������, �� ����! ���� ��� ��� ����� ������ ����� �� ������������ �� ������� - �������� ����� ������� ������� ���� � ������������ � �������.")]<BR>
	"}

	raider.current << browse(entity_ja(output_text), "window=vxrd;size=600x300")

/datum/game_mode/heist/declare_completion()
	//No objectives, go straight to the feedback.
	if(!(raid_objectives.len)) return ..()

	completion_text += "<h3>Heist mode resume:</h3>"

	var/win_type = "Major"
	var/win_group = "Crew"
	var/win_msg = ""

	var/success = raid_objectives.len

	//Decrease success for failed objectives.
	for(var/datum/objective/O in raid_objectives)
		if(!(O.check_completion())) success--

	//Set result by objectives.
	if(success == raid_objectives.len)
		win_type = "Major"
		win_group = "Vox"
	else if(success > 2)
		win_type = "Minor"
		win_group = "Vox"
	else
		win_type = "Minor"
		win_group = "Crew"

	//Now we modify that result by the state of the vox crew.
	if(!is_raider_crew_alive())

		win_type = "Major"
		win_group = "Crew"
		completion_text += "<b>The Vox Raiders have been wiped out!</b>"

	else if(!is_raider_crew_safe())

		if(win_group == "Crew" && win_type == "Minor")
			win_type = "Major"

		win_group = "Crew"
		win_msg += "<b>The Vox Raiders have left someone behind!</b>"

	else

		if(win_group == "Vox")
			if(win_type == "Minor")

				win_type = "Major"
			win_msg += "<b>The Vox Raiders escaped the station!</b>"
		else
			win_msg += "<b>The Vox Raiders were repelled!</b>"

	completion_text += " <b>[win_type] [win_group] victory!</b>"
	completion_text += win_msg
	feedback_set_details("round_end_result","heist - [win_type] [win_group]")

	var/count = 1
	for(var/datum/objective/objective in raid_objectives)
		if(objective.check_completion())
			completion_text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span style='color: green; font-weight: bold;'>Success!</span>"
			feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
		else
			completion_text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span style='color: red; font-weight: bold;'>Fail.</span>"
			feedback_add_details("traitor_objective","[objective.type]|FAIL")
		count++

	..()
	return TRUE

/datum/game_mode/proc/auto_declare_completion_heist()
	var/text = ""
	if(raiders.len)
		var/check_return = 0
		if(ticker && istype(ticker.mode, /datum/game_mode/heist))
			check_return = 1

		text += printlogo("raider", "vox raiders") // pirates icon, until someone makes proper.

		for(var/datum/mind/vox in raiders)
			text += "<br>[vox.key] was [vox.name] ("

			if(check_return)
				var/datum/game_mode/heist/GM = ticker.mode
				var/left_behind = TRUE

				var/obj/item/weapon/implant/cortical/I = GM.cortical_stacks[vox]
				if(I && I.implanted && I.imp_in == vox.current && get_area(I) == locate(/area/shuttle/vox/arkship))
					left_behind = FALSE

				if(left_behind)
					text += "left behind)"
					continue

			if(vox.current)
				if(vox.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(vox.current.real_name != vox.name)
					text += " as [vox.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

	return text

/datum/game_mode/heist/check_finished()
	if(vox_shuttle_location && (vox_shuttle_location == "start"))
		return TRUE
	return ..()
