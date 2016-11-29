#define LIGHT_DAM_THRESHOLD 3
#define LIGHT_HEAL_THRESHOLD 3
#define LIGHT_DAMAGE_TAKEN 10
/*

SHADOWLING: A gamemode based on previously-run events

Aliens called shadowlings are on the station.
These shadowlings can 'enthrall' crew members and enslave them.
They also burn in the light but heal rapidly whilst in the dark.
The game will end under two conditions:
	1. The shadowlings die
	2. The emergency shuttle docks at CentCom

Shadowling strengths:
	- The dark
	- Hard vacuum (They are not affected by it)
	- Their thralls who are not harmed by the light
	- Stealth

Shadowling weaknesses:
	- The light
	- Fire
	- Enemy numbers
	- Lasers (Lasers are concentrated light and do more damage)
	- Flashbangs (High stun and high burn damage; if the light stuns humans, you bet your ass it'll hurt the shadowling very much!)

Shadowlings start off disguised as normal crew members, and they only have two abilities: Hatch and Enthrall.
They can still enthrall and perhaps complete their objectives in this form.
Hatch will, after a short time, cast off the human disguise and assume the shadowling's true identity.
They will then assume the normal shadowling form and gain their abilities.

The shadowling will seem OP, and that's because it kinda is. Being restricted to the dark while being alone most of the time is extremely difficult and as such the shadowling needs powerful abilities.
Made by Xhuis

*/



/*
	GAMEMODE
*/


/datum/game_mode
	var/list/datum/mind/shadows = list()
	var/list/datum/mind/thralls = list()
	var/list/shadow_objectives = list()
	var/required_thralls = 15 //How many thralls are needed (hardcoded for now)
	var/shadowling_ascended = 0 //If at least one shadowling has ascended
	var/shadowling_dead = 0 //is shadowling kill
	var/objective_explanation

/proc/is_thrall(mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.thralls)


/proc/is_shadow_or_thrall(mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && ((M.mind in ticker.mode.thralls) || (M.mind in ticker.mode.shadows))


/proc/is_shadow(mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.shadows)


/datum/game_mode/shadowling
	name = "shadowling"
	config_tag = "shadowling"
	role_type = ROLE_SHADOWLING
	required_players = 30
	required_players_secret = 15
	required_enemies = 2
	recommended_enemies = 2

	votable = 0

	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")

/datum/game_mode/shadowling/announce()
	to_chat(world, "<b>The current game mode is - Shadowling!</b>")
	to_chat(world, "<b>There are alien <span class='userdanger'>shadowlings</span> on the station. Crew: Kill the shadowlings before they can eat or enthrall the crew. Shadowlings: Enthrall the crew while remaining in hiding.</b>")

/datum/game_mode/shadowling/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	//if(config.protect_assistant_from_antagonist)//TG feature?
		//restricted_jobs += "Assistant"

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				antag_candidates -= player

	var/shadowlings = 2 //How many shadowlings there are; hardcoded to 2

	while(shadowlings)
		var/datum/mind/shadow = pick(antag_candidates)
		shadows += shadow
		antag_candidates -= shadow
		modePlayer += shadow
		shadow.special_role = "shadowling"
		shadowlings--
	return 1


/datum/game_mode/shadowling/post_setup()
	for(var/datum/mind/shadow in shadows)
		log_game("[shadow.key] (ckey) has been selected as a Shadowling.")
		sleep(10)
		to_chat(shadow.current, "<br>")
		to_chat(shadow.current, "<span class='deadsay'><b><font size=3>You are a shadowling!</font></b></span>")
		greet_shadow(shadow)
		finalize_shadowling(shadow)
		process_shadow_objectives(shadow)
		update_shadows_icons_added(shadow)
		//give_shadowling_abilities(shadow)

	return ..()

/datum/game_mode/proc/greet_shadow(datum/mind/shadow)
	to_chat(shadow.current, "<b>Currently, you are disguised as an employee aboard [world.name].</b>")
	to_chat(shadow.current, "<b>In your limited state, you have three abilities: Enthrall, Hatch, and Hivemind Commune.</b>")
	to_chat(shadow.current, "<b>Any other shadowlings are you allies. You must assist them as they shall assist you.</b>")
	to_chat(shadow.current, "<b>If you are new to shadowling, or want to read about abilities, check the wiki page at http://tauceti.ru/wiki/Shadowling</b><br>")


/datum/game_mode/proc/process_shadow_objectives(datum/mind/shadow_mind)
	var/objective = "enthrall" //may be devour later, but for now it seems murderbone-y

	if(objective == "enthrall")
		objective_explanation = "Ascend to your true form by use of the Ascendance ability. This may only be used with [required_thralls] collective thralls, while hatched, and is unlocked with the Collective Mind ability."
		shadow_objectives += "enthrall"
		shadow_mind.memory += "<b>Objective #1</b>: [objective_explanation]"
		to_chat(shadow_mind.current, "<b>Objective #1</b>: [objective_explanation]<br>")


/datum/game_mode/proc/finalize_shadowling(datum/mind/shadow_mind)
	var/mob/living/carbon/human/S = shadow_mind.current
	shadow_mind.current.verbs += /mob/living/carbon/human/proc/shadowling_hatch
	S.spell_list += new /obj/effect/proc_holder/spell/targeted/enthrall
	spawn(0)
		S.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind
		if(shadow_mind.assigned_role == "Clown")
			to_chat(S, "<span class='notice'>Your alien nature has allowed you to overcome your clownishness.</span>")
			//S.dna.remove_mutation(CLOWNMUT) //TG
			S.mutations.Remove(CLUMSY) //Bay

/datum/game_mode/proc/add_thrall(datum/mind/new_thrall_mind)
	var/mob/living/carbon/human/H = new_thrall_mind.current
	if (!istype(new_thrall_mind))
		return 0
	if(!(new_thrall_mind in thralls))
		update_all_shadows_icons()
		thralls += new_thrall_mind
		new_thrall_mind.current.attack_log += "\[[time_stamp()]\] <span class='danger'>Became a thrall</span>"
		new_thrall_mind.memory += "<b>The Shadowlings' Objectives:</b> [objective_explanation]"
		to_chat(new_thrall_mind.current, "<b>The objectives of the shadowlings:</b> [objective_explanation]")
		H.hud_updateflag |= 1 << SPECIALROLE_HUD
		H.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind
		return 1



/*
	GAME FINISH CHECKS
*/

/*
/datum/game_mode/shadowling/check_finished()
	var/shadows_alive = 0 //and then shadowling was kill
	for(var/datum/mind/shadow in shadows) //but what if shadowling was not kill?
		if(!istype(shadow.current,/mob/living/carbon/human) && !istype(shadow.current,/mob/living/simple_animal/ascendant_shadowling))
			continue
		if(shadow.current.stat == DEAD)
			continue
		shadows_alive++
	if(shadows_alive)
		return ..()
	else
		shadowling_dead = 1 //but shadowling was kill :(
		return 1*/

/datum/game_mode/shadowling/proc/check_shadow_killed()
	var/shadows_alive = 0 //and then shadowling was kill
	for(var/datum/mind/shadow in shadows) //but what if shadowling was not kill?
		if(!istype(shadow.current,/mob/living/carbon/human) && !istype(shadow.current,/mob/living/simple_animal/ascendant_shadowling))
			continue
		if(shadow.current.stat == DEAD)
			continue
		shadows_alive++
	if(shadows_alive)
		return 0
	else
		return 1

/datum/game_mode/shadowling/proc/check_shadow_victory()
	var/success = 0 //Did they win?
	if(shadow_objectives.Find("enthrall"))
		success = shadowling_ascended
	return success


/datum/game_mode/shadowling/declare_completion()
	//if(check_shadow_victory() && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE) //Doesn't end instantly - this is hacky and I don't know of a better way ~X
	completion_text += "<B>Shadowling mode resume:</B><BR>"
	if(check_shadow_victory() && SSshuttle.location==2)
		completion_text += "<font size=3, color=green><B>The shadowlings have ascended and taken over the station!</FONT></B>"
		score["roleswon"]++
	//else if(shadowling_dead && !check_shadow_victory()) //If the shadowlings have ascended, they can not lose the round
	else if(check_shadow_killed() && !check_shadow_victory())
		completion_text += "<font size=3, color=red><B>The shadowlings have been killed by the crew!</B></FONT>"
	//else if(!check_shadow_victory() && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
	else if(!check_shadow_victory() && SSshuttle.location==2)
		completion_text += "<font size=3, color=red><B>The crew has escaped the station before the shadowlings could ascend!</B></FONT>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_shadowling()
	var/text = ""
	if(shadows.len)
		text += printlogo("shadowling", "shadowlings")
		for(var/datum/mind/shadow in shadows)
			text += printplayerwithicon(shadow)
		text += "<BR>"
		if(thralls.len)
			text += printlogo("thrall", "thralls")
			for(var/datum/mind/thrall in thralls)
				text += printplayerwithicon(thrall)
			text += "<BR>"
		text += "<HR>"
	return text

/*
	MISCELLANEOUS
*/
// Revs antag icons copypasta
/////////////////////////////////////////////////////////////////////////////////////////////////
//Keeps track of players having the correct icons////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/update_all_shadows_icons()
	spawn(0)
		for(var/datum/mind/shadowling_mind in shadows)
			if(shadowling_mind.current)
				if(shadowling_mind.current.client)
					for(var/image/I in shadowling_mind.current.client.images)
						if(I.icon_state == "thrall" || I.icon_state == "shadowling")
							qdel(I)

		for(var/datum/mind/thrall_mind in thralls)
			if(thrall_mind.current)
				if(thrall_mind.current.client)
					for(var/image/I in thrall_mind.current.client.images)
						if(I.icon_state == "thrall" || I.icon_state == "shadowling")
							qdel(I)

		for(var/datum/mind/shadowling in shadows)
			if(shadowling.current)
				if(shadowling.current.client)
					for(var/datum/mind/thrall in thralls)
						if(thrall.current)
							var/I = image('icons/mob/shadowling.dmi', loc = thrall.current, icon_state = "thrall")
							shadowling.current.client.images += I
					for(var/datum/mind/shadowling_1 in shadows)
						if(shadowling_1.current)
							var/I = image('icons/mob/shadowling.dmi', loc = shadowling_1.current, icon_state = "shadowling")
							shadowling.current.client.images += I

		for(var/datum/mind/thrall in thralls)
			if(thrall.current)
				if(thrall.current.client)
					for(var/datum/mind/shadowling in shadows)
						if(shadowling.current)
							var/I = image('icons/mob/shadowling.dmi', loc = shadowling.current, icon_state = "shadowling")
							thrall.current.client.images += I
					for(var/datum/mind/thrall_1 in thralls)
						if(thrall_1.current)
							var/I = image('icons/mob/shadowling.dmi', loc = thrall_1.current, icon_state = "thrall")
							thrall.current.client.images += I



/datum/game_mode/proc/update_shadows_icons_added(datum/mind/thrall)
	spawn(0)
		for(var/datum/mind/shadowling_mind in shadows)
			if(shadowling_mind.current)
				if(shadowling_mind.current.client)
					var/I = image('icons/mob/shadowling.dmi', loc = thrall.current, icon_state = "thrall")
					shadowling_mind.current.client.images += I
			if(thrall.current)
				if(thrall.current.client)
					var/image/J = image('icons/mob/shadowling.dmi', loc = shadowling_mind.current, icon_state = "shadowling")
					thrall.current.client.images += J

		for(var/datum/mind/thrall_1 in thralls)
			if(thrall_1.current)
				if(thrall_1.current.client)
					var/I = image('icons/mob/shadowling.dmi', loc = thrall.current, icon_state = "thrall")
					thrall_1.current.client.images += I
			if(thrall.current)
				if(thrall.current.client)
					var/image/J = image('icons/mob/shadowling.dmi', loc = thrall_1.current, icon_state = "thrall")
					thrall.current.client.images += J



/datum/game_mode/proc/update_shadows_icons_removed(datum/mind/thrall)
	spawn(0)
		for(var/datum/mind/shadowling_mind in shadows)
			if(shadowling_mind.current)
				if(shadowling_mind.current.client)
					for(var/image/I in shadowling_mind.current.client.images)
						if((I.icon_state == "thrall" || I.icon_state == "shadowling") && I.loc == thrall.current)
							qdel(I)

		for(var/datum/mind/thrall_1 in thralls)
			if(thrall_1.current)
				if(thrall_1.current.client)
					for(var/image/I in thrall_1.current.client.images)
						if((I.icon_state == "thrall" || I.icon_state == "shadowling") && I.loc == thrall.current)
							qdel(I)

		if(thrall.current)
			if(thrall.current.client)
				for(var/image/I in thrall.current.client.images)
					if(I.icon_state == "thrall" || I.icon_state == "shadowling")
						qdel(I)

/*
/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "Shadow"
	language = "Sol Common"
	unarmed_type = /datum/unarmed_attack/claws
	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000
	blood_color = "#000000"
	//id = "shadow"
	darksight = 8
	//sexes = 0
	//ignored_by = list(/mob/living/simple_animal/hostile/faithless)
	//faction = list("faithless")
	//meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	//specflags = list(NOBREATH,NOBLOOD,RADIMMUNE)
	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,RAD_IMMUNE = TRUE
	)*/

/datum/species/shadow/ling
	//Normal shadowpeople but with enhanced effects
	name = "Shadowling"
	icobase = 'icons/mob/human_races/r_shadowling.dmi'
	deform = 'icons/mob/human_races/r_def_shadowling.dmi'
	language = "Sol Common"
	unarmed_type = /datum/unarmed_attack/claws

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	blood_color = "#000000"
	darksight = 8

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,RAD_IMMUNE = TRUE
	,VIRUS_IMMUNE = TRUE
	)
	burn_mod = 2 //2x burn damage lel


/datum/species/shadow/ling/handle_post_spawn(mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()
