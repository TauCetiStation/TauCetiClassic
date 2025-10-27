/mob/living/silicon/robot/drone/syndi
	real_name = "syndicate drone"
	scrambledcodes = TRUE
	modtype = "Syndicate"
	faction = "syndicate"
	req_access = list(access_syndicate)
	holder_type = /obj/item/weapon/holder/syndi_drone
	eyes_overlay = "eyes-syndibot"

	var/obj/item/device/drone_uplink/uplink = null
	var/mob/living/carbon/human/operator = null //Mob controlling the drone
	var/datum/mind/operator_mind = null
	var/operator_health_last = null
	var/msg_cooldown = 0

	spawner_args = null

/mob/living/silicon/robot/drone/syndi/atom_init()
	. = ..()
	set_ai_link(null)
	radio = new /obj/item/device/radio/borg/syndicate(src)
	module = new /obj/item/weapon/robot_module/syndidrone(src)
	laws = new /datum/ai_laws/syndicate_override()
	uplink = new /obj/item/device/drone_uplink()

	var/datum/action/stop_control/A = new(src)
	A.Grant(src)

	flavor_text = "It's a tiny little repair drone. The casing is stamped with a Cybersun Ind. logo and the subscript: 'Cybersun Industries: I will definitely fix it tomorrow!'"

/mob/living/silicon/robot/drone/syndi/Destroy()
	var/datum/action/stop_control/A = locate() in actions
	qdel(A)
	loose_control()
	return ..()

/mob/living/silicon/robot/drone/syndi/init(laws_type, ai_link, datum/religion/R)
	aiCamera = new/obj/item/device/camera/siliconcam/robot_camera(src)
	laws = new laws_type(R)

/mob/living/silicon/robot/drone/syndi/Life()
	. = ..()
	if(!operator)
		return
	if((operator.stat != CONSCIOUS) || (operator.key != "@[key]"))
		loose_control()
		return
	if(operator.health < operator_health_last)
		to_chat(src, "<span class='warning'>You're getting damage! Secure yourself as soon as possible!</span>")
	if(msg_cooldown)
		msg_cooldown--
	else
		for(var/mob/living/M in range(1, operator))
			if(M != operator)
				to_chat(src, "<span class='notice'>You feel something moving around you.</span>")
				msg_cooldown = 3//in 2x of seconds (so 'cooldown 3' is 6 seconds)
				break
	operator_health_last = operator.health

/mob/living/silicon/robot/drone/syndi/updatename()
	var/N = rand(100, 999)
	real_name = "syndicate drone ([N])"
	name = "suspicious drone ([N])"

/mob/living/silicon/robot/drone/syndi/emag_act(mob/user)
	to_chat(src, "<span class='warning'>[user] attempts to load subversive software into you, but your hacked subroutined ignore the attempt.</span>")
	to_chat(user, "<span class='warning'>You attempt to subvert [src], but the sequencer has no effect.</span>")
	return FALSE

/mob/living/silicon/robot/drone/syndi/pick_module()
	uplink.interact(src)

/mob/living/silicon/robot/drone/syndi/proc/control(mob/living/carbon/human/M)
	if(!laws.zeroth)
		set_zeroth_law("Только [M.real_name] и люди, которых он называет таковыми, - агенты Синдиката.")
	operator = M
	operator_mind = M.mind
	operator_health_last = M.health
	msg_cooldown = 5//in 2x of seconds (so 'cooldown 5' is 10 seconds)
	key = M.key
	M.key = "@[key]"
	to_chat(src, "You're now controlling the [name].")

/mob/living/silicon/robot/drone/syndi/create_mind()
	..()
	mind.skills.add_available_skillset(/datum/skillset/cyborg)
	mind.skills.maximize_active_skills()

/mob/living/silicon/robot/drone/syndi/proc/loose_control()
	if(!operator)
		return
	if(operator.key == "@[key]")
		operator.key = key
	else //if operator is controlled by another client
		if(operator_mind && operator_mind.current && operator_mind.key == key) //if client is controlling another mob, not the operator
			operator_mind.current.key = key
		else // idk what is going on, client has no living mob to controll
			ghostize(FALSE)
	key = null
	to_chat(operator, "You've lost control of the [name].")
	operator = null
	operator_mind = null


//========Verbs========
/mob/living/silicon/robot/drone/syndi/verb/stop_control()
	set name = "Stop controlling"
	set desc = "Toggles RC off."
	set category = "Drone"

	loose_control()


//==========Actions==========
/datum/action/stop_control
	name = "Stop controlling"
	action_type = AB_GENERIC
	button_icon_state = "degoggles"

/datum/action/stop_control/Checks()
	if(!..())
		return FALSE
	var/mob/living/silicon/robot/drone/syndi/M = owner
	if(M.operator)
		return TRUE
	return FALSE

/datum/action/stop_control/Trigger()
	if(!Checks())
		return
	var/mob/living/silicon/robot/drone/syndi/M = owner
	M.loose_control()
