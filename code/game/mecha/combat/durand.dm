/obj/mecha/combat/durand
	desc = "An aging combat exosuit utilized by the Nanotrasen corporation. Originally developed to combat hostile alien lifeforms."
	name = "Durand"
	icon_state = "durand"
	initial_icon = "durand"
	step_in = 4
	dir_in = 1 //Facing North.
	health = 400
	deflect_chance = 20
	damage_absorption = list(BRUTE=0.5,BURN=1.1,BULLET=0.65,LASER=0.85,ENERGY=0.9,BOMB=0.8)
	max_temperature = 30000
	infra_luminosity = 8
	force = 40
	var/defence = FALSE
	var/defence_deflect = 35
	wreckage = /obj/effect/decal/mecha_wreckage/durand

	var/datum/action/innate/mecha/mech_defence_mode/defence_action = new

/obj/mecha/combat/durand/Destroy()
	QDEL_NULL(defence_action)
	return ..()


/obj/mecha/combat/durand/GrantActions(mob/living/user, human_occupant = 0)
	..()
	defence_action.Grant(user, src)

/obj/mecha/combat/durand/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	defence_action.Remove(user)

/obj/mecha/combat/durand/atom_init()
	. = ..()
	AddComponent(/datum/component/examine_research, DEFAULT_SCIENCE_CONSOLE_ID, 3000, list(DIAGNOSTIC_EXTRA_CHECK, VIEW_EXTRA_CHECK))
	/*
	weapons += new /datum/mecha_weapon/ballistic/lmg(src)
	weapons += new /datum/mecha_weapon/ballistic/scattershot(src)
	selected_weapon = weapons[1]
*/

/obj/mecha/combat/durand/relaymove(mob/user,direction)
	if(defence)
		if(world.time - last_message > 20)
			occupant_message("<font color='red'>Unable to move while in defence mode</font>")
			last_message = world.time
		return 0
	. = ..()
	return


/obj/mecha/combat/durand/proc/defence_mode()
	if(usr!=src.occupant)
		return
	if(!check_fumbling("<span class='notice'>You fumble around, figuring out how to [!defence? "en" : "dis"]able defence mode.</span>"))
		return
	playsound(src, 'sound/mecha/change_defence_mode.ogg', VOL_EFFECTS_MASTER, 75, FALSE)
	defence = !defence
	if(defence)
		if(animated)
			flick("vindicator-lockdown-a",src)
			icon_state = "vindicator-lockdown"
		deflect_chance = defence_deflect
		occupant_message("<font color='blue'>You enable [src] defence mode.</font>")
	else
		deflect_chance = initial(deflect_chance)
		if(animated)
			icon_state = reset_icon()
		occupant_message("<font color='red'>You disable [src] defence mode.</font>")
	log_message("Toggled defence mode.")
	return


/obj/mecha/combat/durand/get_stats_part()
	var/output = ..()
	output += "<b>Defence mode: [defence?"on":"off"]</b>"
	return output

/obj/mecha/combat/durand/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='?src=\ref[src];toggle_defence_mode=1'>Toggle defence mode</a>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/mecha/combat/durand/Topic(href, href_list)
	..()
	if (href_list["toggle_defence_mode"])
		defence_mode()
	return

/obj/mecha/combat/durand/vindicator
	desc = "A highly improved version of old Durand exosuit, with improved shock absorption and refined internal electronics."
	name = "Vindicator"
	icon_state = "vindicator"
	initial_icon = "vindicator"
	step_in = 4
	dir_in = 1 //Facing North.
	health = 440
	deflect_chance = 25
	damage_absorption = list(BRUTE=0.5,BURN=1.0,BULLET=0.55,LASER=0.75,ENERGY=0.8,BOMB=0.7)
	max_temperature = 30000
	infra_luminosity = 8
	internal_damage_threshold = 40
	force = 40
	wreckage = /obj/effect/decal/mecha_wreckage/durand/vindicator
	animated = 1

/obj/mecha/combat/durand/vindicator/atom_init()
	. = ..()
	AddComponent(/datum/component/examine_research, DEFAULT_SCIENCE_CONSOLE_ID, 4600, list(DIAGNOSTIC_EXTRA_CHECK, VIEW_EXTRA_CHECK))
