/mob/living/silicon/robot/drone
	name = "drone"
	real_name = "drone"
	icon = 'icons/mob/robots.dmi'
	icon_state = "repairbot"
	maxHealth = 15
	health = 15
	health_threshold_dead = -15
	universal_speak = 0
	universal_understand = 1
	gender = NEUTER
	pass_flags = PASSTABLE
	braintype = "Robot"
	lawupdate = 0
	density = 0
	req_access = list(access_engine, access_robotics)
	ventcrawler = 2

	//Used for self-mailing.
	var/mail_destination = ""

	holder_type = /obj/item/weapon/holder/drone

/mob/living/silicon/robot/drone/atom_init()

	. = ..()

	if(camera && "Robots" in camera.network)
		camera.add_network("Engineering")

	//They are unable to be upgraded, so let's give them a bit of a better battery.
	cell.maxcharge = 10000
	cell.charge = 10000

	// NO BRAIN.
	mmi = null

	//We need to screw with their HP a bit. They have around one fifth as much HP as a full borg.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.max_damage = 10

/mob/living/silicon/robot/drone/init()
	aiCamera = new/obj/item/device/camera/siliconcam/drone_camera(src)
	playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)

//Redefining some robot procs...
/mob/living/silicon/robot/drone/updatename()
	real_name = "drone ([rand(100,999)])"
	name = real_name

/mob/living/silicon/robot/drone/updateicon()

	overlays.Cut()
	if(stat == CONSCIOUS)
		overlays += "eyes-[icon_state]"
	else
		overlays -= "eyes"

/mob/living/silicon/robot/drone/choose_icon()
	return

/mob/living/silicon/robot/drone/pick_module()
	return

//Drones cannot be upgraded with borg modules so we need to catch some items before they get used in ..().
/mob/living/silicon/robot/drone/attackby(obj/item/weapon/W, mob/user)

	if(istype(W, /obj/item/borg/upgrade/))
		to_chat(user, "\red The maintenance drone chassis not compatible with \the [W].")
		return

	else if (istype(W, /obj/item/weapon/crowbar))
		to_chat(user, "The machine is hermetically sealed. You can't open the case.")
		return

	else if (istype(W, /obj/item/weapon/card/emag))

		if(!client || stat == DEAD)
			to_chat(user, "\red There's not much point subverting this heap of junk.")
			return

		if(emagged)
			to_chat(src, "\red [user] attempts to load subversive software into you, but your hacked subroutined ignore the attempt.")
			to_chat(user, "\red You attempt to subvert [src], but the sequencer has no effect.")
			return
		user.SetNextMove(CLICK_CD_MELEE)
		to_chat(user, "\red You swipe the sequencer across [src]'s interface and watch its eyes flicker.")
		to_chat(src, "\red You feel a sudden burst of malware loaded into your execute-as-root buffer. Your tiny brain methodically parses, loads and executes the script.")

		var/obj/item/weapon/card/emag/emag = W
		emag.uses--

		message_admins("[key_name_admin(user)] emagged drone [key_name_admin(src)].  Laws overridden.")
		log_game("[key_name(user)] emagged drone [key_name(src)].  Laws overridden.")
		var/time = time2text(world.realtime,"hh:mm:ss")
		lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")

		emagged = 1
		lawupdate = 0
		connected_ai = null
		clear_supplied_laws()
		clear_inherent_laws()
		laws = new /datum/ai_laws/syndicate_override
		set_zeroth_law("Only [user.real_name] and people he designates as being such are Syndicate Agents.")

		to_chat(src, "<b>Obey these laws:</b>")
		laws.show_laws(src)
		to_chat(src, "\red \b ALERT: [user.real_name] is your new master. Obey your new laws and his commands.")
		return

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))

		if(stat == DEAD)

			if(!config.allow_drone_spawn || emagged || health < -35) //It's dead, Dave.
				to_chat(user, "\red The interface is fried, and a distressing burned smell wafts from the robot's interior. You're not rebooting this one.")
				return

			if(!allowed(usr))
				to_chat(user, "\red Access denied.")
				return

			user.visible_message("\red \the [user] swipes \his ID card through \the [src], attempting to reboot it.", "\red You swipe your ID card through \the [src], attempting to reboot it.")
			var/drones = 0
			for(var/mob/living/silicon/robot/drone/D in mob_list)
				if(D.key && D.client)
					drones++
			if(drones < config.max_maint_drones)
				request_player()
			return

		else
			user.visible_message("\red \the [user] swipes \his ID card through \the [src], attempting to shut it down.", "\red You swipe your ID card through \the [src], attempting to shut it down.")

			if(emagged)
				return

			if(allowed(usr))
				shut_down()
			else
				to_chat(user, "\red Access denied.")

		return

	..()

//DRONE LIFE/DEATH

//For some goddamn reason robots have this hardcoded. Redefining it for our fragile friends here.
/mob/living/silicon/robot/drone/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return
	health = maxHealth - (getBruteLoss() + getFireLoss())
	return

//Easiest to check this here, then check again in the robot proc.
//Standard robots use config for crit, which is somewhat excessive for these guys.
//Drones killed by damage will gib.
/mob/living/silicon/robot/drone/handle_regular_status_updates()

	if(health <= health_threshold_dead && src.stat != DEAD)
		timeofdeath = world.time
		death() //Possibly redundant, having trouble making death() cooperate.
		gib()
		return
	..()

/mob/living/silicon/robot/drone/death(gibbed)

	if(module)
		var/obj/item/weapon/gripper/G = locate(/obj/item/weapon/gripper) in module
		if(G) G.drop_item()

	..(gibbed)

//CONSOLE PROCS
/mob/living/silicon/robot/drone/proc/law_resync()
	if(stat != DEAD)
		if(emagged)
			to_chat(src, "\red You feel something attempting to modify your programming, but your hacked subroutines are unaffected.")
		else
			to_chat(src, "\red A reset-to-factory directive packet filters through your data connection, and you obediently modify your programming to suit it.")
			full_law_reset()
			show_laws()

/mob/living/silicon/robot/drone/proc/shut_down()
	if(stat != DEAD)
		if(emagged)
			to_chat(src, "\red You feel a system kill order percolate through your tiny brain, but it doesn't seem like a good idea to you.")
		else
			to_chat(src, "\red You feel a system kill order percolate through your tiny brain, and you obediently destroy yourself.")
			death()

/mob/living/silicon/robot/drone/proc/full_law_reset()
	clear_supplied_laws()
	clear_inherent_laws()
	clear_ion_laws()

//Reboot procs.

/mob/living/silicon/robot/drone/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(jobban_isbanned(O, ROLE_DRONE))
			continue
		if(role_available_in_minutes(O, ROLE_DRONE))
			continue
		if(O.client)
			var/client/C = O.client
			if(!C.prefs.ignore_question.Find("drone") && (ROLE_PAI in C.prefs.be_role))
				question(C)

/mob/living/silicon/robot/drone/proc/question(client/C)
	spawn(0)
		if(!C || !C.mob || jobban_isbanned(C.mob, ROLE_DRONE) || role_available_in_minutes(C.mob, ROLE_DRONE))//Not sure if we need jobban check, since proc from above do that too.
			return
		var/response = alert(C, "Someone is attempting to reboot a drone. Would you like to play as one?", "Drone reboot", "No", "Yes", "Never for this round.")
		if(!C || ckey)
			return
		if(response == "Yes")
			transfer_personality(C)
		else if (response == "Never for this round")
			C.prefs.ignore_question += "drone"

/mob/living/silicon/robot/drone/proc/transfer_personality(client/player)

	if(!player) return

	src.ckey = player.ckey

	if(player.mob && player.mob.mind)
		player.mob.mind.transfer_to(src)

	lawupdate = 0
	full_law_reset()

/mob/living/silicon/robot/drone/ObjBump(obj/O)
	var/list/can_bump = list(/obj/machinery/door,
							/obj/machinery/recharge_station,
							/obj/machinery/disposal/deliveryChute,
							/obj/machinery/teleport/hub,
							/obj/effect/portal)
	if(!(O in can_bump))
		return 0

/mob/living/silicon/robot/drone/proc/can_pull(atom/movable/AM)
	if(istype(AM,/obj/item))
		var/obj/item/O = AM
		if(O.w_class > 2)
			return FALSE
		else
			return TRUE

/mob/living/silicon/robot/drone/start_pulling(atom/movable/AM)
	if(can_pull(AM))
		..()
	else
		to_chat(src, "<span class='warning'>You are too small to pull that.</span>")
		return

/mob/living/simple_animal/drone/mob_negates_gravity()
	return 1

/mob/living/simple_animal/drone/mob_has_gravity()
	return ..() || mob_negates_gravity()
