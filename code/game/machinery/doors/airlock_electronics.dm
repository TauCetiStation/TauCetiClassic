/obj/item/weapon/airlock_electronics
	name = "airlock electronics"
	desc = "Looks like a circuit. Probably is."
	icon = 'icons/obj/doors/door_electronics.dmi'
	icon_state = "door_electronics"
	w_class = SIZE_TINY
	m_amt = 50
	g_amt = 50

	//Emagged
	var/broken = FALSE
	/// A list of all granted accesses
	var/list/conf_access = list()
	/// If the airlock should require ALL or only ONE of the listed accesses
	var/one_access = 0
	/// Checks to see if this airlock has an unrestricted helper (will set to TRUE if present).
	var/unres_sensor = FALSE
	/// Unrestricted sides, or sides of the airlock that will open regardless of access
	var/unres_sides = NONE
	///what name are we passing to the finished airlock
	var/passed_name


/obj/item/weapon/airlock_electronics/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Has a <i>selection menu</i> for modifying airlock access levels.</span>")

/obj/item/weapon/airlock_electronics/attack_self(mob/user)
	if (!ishuman(user) && !isrobot(user))
		return ..(user)
	var/mob/living/carbon/human/H = user
	if(H.getBrainLoss() >= 60)
		return
	tgui_interact(user)

/obj/item/weapon/airlock_electronics/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockElectronics", name)
		ui.open()

/obj/item/weapon/airlock_electronics/tgui_static_data(mob/user)
	var/list/data = list()
	data["regions"] = get_accesslist_static_data(REGION_GENERAL, REGION_COMMAND)
	return data

/obj/item/weapon/airlock_electronics/tgui_data()
	var/list/data = list()
	data["accesses"] = conf_access
	data["oneAccess"] = one_access
	data["unres_direction"] = unres_sides
	data["passedName"] = passed_name
	return data

/obj/item/weapon/airlock_electronics/proc/do_action(action, params)
	switch(action)
		if("clear_all")
			conf_access = list()
			one_access = 0
		if("grant_all")
			conf_access = get_all_accesses()
		if("one_access")
			one_access = !one_access
		if("set")
			var/access = params["access"]
			if(!(access in conf_access))
				conf_access += access
			else
				conf_access -= access
		if("direc_set")
			var/unres_direction = text2num(params["unres_direction"])
			unres_sides ^= unres_direction //XOR, toggles only the bit that was clicked
		if("grant_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			conf_access += get_region_accesses(region)
		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			conf_access -= get_region_accesses(region)
		if("passedName")
			var/new_name = trim("[params["passedName"]]", 30)
			passed_name = new_name

/obj/item/weapon/airlock_electronics/tgui_act(action, params)
	. = ..()
	if(.)
		return
	do_action(action, params)
	return TRUE
