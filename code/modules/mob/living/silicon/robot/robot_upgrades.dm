// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "A borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/locked = 0
	var/require_module = FALSE
	var/installed = 0

/obj/item/borg/upgrade/proc/action()
	return FALSE


// Fuck, class-dublicate
/obj/item/borg/upgrade/reset
	name = "Borg module reset board"
	desc = "Used to reset a borg's module. Destroys any other upgrades applied to the borg."
	icon_state = "cyborg_upgrade1"
	require_module = TRUE

/obj/item/borg/upgrade/reset/action(mob/living/silicon/robot/R)
	R.uneq_all()
	qdel(R.module)
	R.module = null
	R.modtype = "robot"
	R.real_name = "Cyborg [R.ident]"
	R.name = R.real_name
	R.nopush = 0
	R.hands.icon_state = "nomod"
	R.base_icon = "robot"
	R.icon_state = "robot"
	R.sensor_huds = R.def_sensor_huds
	R.updateicon()
	for(var/language in R.languages)
		R.remove_language(language)
	R.speech_synthesizer_langs = list()

	return TRUE



/obj/item/borg/upgrade/flashproof
	name = "Borg Flash-Supression"
	desc = "A highly advanced, complicated system for supressing incoming flashes directed at the borg's optical processing system."
	icon_state = "cyborg_upgrade4"
	require_module = TRUE


//obj/item/borg/upgrade/flashproof/atom_init()   // Why the fuck does the fabricator make a new instance of all the items?
	//desc = "Sunglasses with duct tape." // Why?  D:

/obj/item/borg/upgrade/flashproof/action(mob/living/silicon/robot/R)
	if(R.module)
		R.module += src

	return TRUE

/obj/item/borg/upgrade/restart
	name = "Borg emergancy restart module"
	desc = "Used to force a restart of a disabled-but-repaired borg, bringing it back online."
	icon_state = "cyborg_upgrade1"


/obj/item/borg/upgrade/restart/action(mob/living/silicon/robot/R)
	if(!R.key)
		for(var/mob/dead/observer/ghost as anything in observer_list)
			if(ghost.corpse == R && ghost.client)
				ghost.client.mob = ghost.corpse

	if(R.health < 0)
		to_chat(usr, "You have to repair the borg before using this module!")
		return FALSE

	R.stat = CONSCIOUS
	return TRUE


/obj/item/borg/upgrade/vtec
	name = "Borg VTEC Module"
	desc = "Used to kick in a borgs VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = TRUE

/obj/item/borg/upgrade/vtec/action(mob/living/silicon/robot/R)
	if(R.speed == -1)
		return FALSE

	R.speed--
	return TRUE


/obj/item/borg/upgrade/tasercooler
	name = "Borg Rapid Taser Cooling Module"
	desc = "Used to cool a mounted taser, increasing the potential current in it and thus its recharge rate.."
	icon_state = "cyborg_upgrade3"
	require_module = TRUE


/obj/item/borg/upgrade/tasercooler/action(mob/living/silicon/robot/R)
	if(!istype(R.module, /obj/item/weapon/robot_module/security))
		to_chat(R, "Upgrade mounting error!  No suitable hardpoint detected!")
		to_chat(usr, "There's no mounting point for the module!")
		return FALSE

	var/obj/item/weapon/gun/energy/taser/cyborg/T = locate() in R.module
	if(!T)
		T = locate() in R.module.contents
		if(!T)
			T = locate() in R.module.modules
			if(!T)
				to_chat(usr, "This cyborg has had its taser removed!")
				return FALSE

	if(T.recharge_time <= 2)
		to_chat(R, "Maximum cooling achieved for this hardpoint!")
		to_chat(usr, "There's no room for another cooling unit!")
		return FALSE

	T.recharge_time = max(2 , T.recharge_time - 4)

	return TRUE

/obj/item/borg/upgrade/jetpack
	name = "Borg Jetpack"
	desc = "A carbon dioxide jetpack suitable for low-gravity operations."
	icon_state = "cyborg_upgrade3"
	require_module = TRUE

/obj/item/borg/upgrade/jetpack/action(mob/living/silicon/robot/R)
	var/obj/item/weapon/tank/jetpack/carbondioxide/J = new(R.module)
	R.module.add_item(J)
	for(var/obj/item/weapon/tank/jetpack/carbondioxide in R.module.modules)
		R.internals = src
	return TRUE
