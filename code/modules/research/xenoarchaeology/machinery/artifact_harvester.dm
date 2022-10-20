/obj/machinery/artifact_harvester
	name = "Exotic Particle Harvester"
	desc = "It is used to drain the energy out of the artifacts."
	icon = 'icons/obj/xenoarchaeology/machinery.dmi'
	icon_state = "harvester"
	anchored = TRUE
	density = TRUE
	idle_power_usage = 50
	active_power_usage = 750
	use_power = IDLE_POWER_USE
	var/is_battery_loaded = FALSE
	var/is_harvesting = FALSE
	var/is_draining = FALSE
	var/obj/item/weapon/particles_battery/inserted_battery
	var/obj/structure/artifact/current_artifact
	var/obj/machinery/artifact_scanpad/owned_scanner
	required_skills = list(/datum/skill/research = SKILL_LEVEL_TRAINED)

/obj/machinery/artifact_harvester/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/artifact_harvester/proc/locate_telepad()
	owned_scanner = locate(/obj/machinery/artifact_scanpad) in get_step(src, dir)
	if(!owned_scanner)
		owned_scanner = locate(/obj/machinery/artifact_scanpad) in orange(1, src)
	if(!owned_scanner)
		playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)
		return FALSE
	playsound(src, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER, 20)
	return TRUE

/obj/machinery/artifact_harvester/proc/can_harvest()
	if(is_draining || is_harvesting)
		return FALSE
	if(!inserted_battery)
		visible_message("<b>[name]</b> states, \"Cannot harvest. No battery inserted.\"")
		return FALSE
	if(inserted_battery.battery_effect?.current_charge >= inserted_battery.capacity)
		visible_message("<b>[name]</b> states, \"Cannot harvest. battery is full.\"")
		return FALSE
	for(var/obj/structure/artifact/Art in get_turf(owned_scanner))
		current_artifact = Art
		break
	if(!current_artifact)
		var/message = "<b>[name]</b> states, \"Cannot harvest. No noteworthy energy signature isolated.\""
		playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)
		visible_message(message)
		return FALSE
	if(!current_artifact.first_effect.activated && !current_artifact.secondary_effect?.activated)
		visible_message("<b>[name]</b> states, \"Cannot harvest. No energy emitting from source.\"")
		playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)
		return FALSE
	if(current_artifact.first_effect.activated && current_artifact.secondary_effect?.activated)
		visible_message("<b>[name]</b> states, \"Cannot harvest. Source is emitting conflicting energy signatures.\"")
		playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)
		return FALSE
	var/datum/artifact_effect/harvested_effect
	if(current_artifact.first_effect.activated)
		harvested_effect = current_artifact.first_effect
	else
		harvested_effect = current_artifact.secondary_effect
	if(inserted_battery.battery_effect?.current_charge && (inserted_battery.battery_effect?.type != harvested_effect.type))
		visible_message("<b>[name]</b> states, \"Cannot harvest. Battery is charged with a different energy signature.\"")
		return FALSE
	return TRUE

/obj/machinery/artifact_harvester/proc/start_harvest()
	is_harvesting = TRUE
	set_power_use(ACTIVE_POWER_USE)
	current_artifact.anchored = TRUE
	current_artifact.being_used = TRUE
	update_icon()
	owned_scanner.icon_state = "xenoarch_scanner_scanning"
	visible_message("<b>[name]</b> states, \"Beginning energy harvesting\"")
	if(!inserted_battery.battery_effect)
		var/datum/artifact_effect/harvested_effect
		if(current_artifact.first_effect.activated)
			harvested_effect = current_artifact.first_effect
		else
			harvested_effect = current_artifact.secondary_effect
		var/new_effect_type = harvested_effect.type
		var/datum/artifact_effect/E = new new_effect_type(inserted_battery)
		for(var/varname in list("release_method", "range", "trigger"))
			E.vars[varname] = harvested_effect.vars[varname]
		E.maximum_charges = inserted_battery.capacity
		inserted_battery.battery_effect = E

/obj/machinery/artifact_harvester/proc/stop_harvest()
	is_harvesting = FALSE
	set_power_use(IDLE_POWER_USE)
	current_artifact.anchored = FALSE
	current_artifact.being_used = FALSE
	current_artifact = null
	visible_message("<b>[name]</b> states, \"Energy harvesting interrupted.\"")
	update_icon()
	owned_scanner.icon_state = "xenoarch_scanner"

/obj/machinery/artifact_harvester/proc/drain_battery()
	if(!is_battery_loaded)
		playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)
		visible_message("<b>[name]</b> states, \"Cannot dump energy. No battery inserted.\"")
		return
	if(is_harvesting)
		playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)
		visible_message("<b>[name]</b> states, \"Cannot dump energy. Energy harvesting is initiated.\"")
		return
	if(inserted_battery.battery_effect == null && !inserted_battery.battery_effect?.current_charge)
		playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)
		visible_message("<b>[name]</b> states, \"Cannot dump energy. Battery is drained of charge already.\"")
		return
	if(tgui_alert(usr, "This action will dump all charge, safety gear is recommended before proceeding", "Warning", list("Continue", "Cancel")) != "Continue")
		playsound(src, pick(SOUNDIN_KEYBOARD), VOL_EFFECTS_MASTER, null, FALSE)
		return
	is_draining = TRUE
	set_power_use(ACTIVE_POWER_USE)
	update_icon()
	owned_scanner.icon_state = "xenoarch_scanner"
	visible_message("<b>[name]</b> states, \"Warning, battery charge dump commencing.\"")

/obj/machinery/artifact_harvester/atom_init_late()
	locate_telepad()

/obj/machinery/artifact_harvester/update_icon()
	if(!is_battery_loaded)
		icon_state = "harvester"
	if(is_battery_loaded && !(is_harvesting || is_draining))
		icon_state = "harvester_battery"
	if(is_harvesting)
		icon_state = "harvester_on"

/obj/machinery/artifact_harvester/attackby(obj/item/weapon/particles_battery/Battery, mob/user)
	if(!istype(Battery))
		return ..()
	if(inserted_battery)
		to_chat(user, "<span class='warning'>There is already a battery in [src].</span>")
		return ..()
	if(!user.drop_from_inventory(Battery, src))
		return ..()
	to_chat(user, "<span class='notice'>You insert [Battery] into [src].</span>")
	playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER)
	inserted_battery = Battery
	is_battery_loaded = TRUE
	update_icon()

/obj/machinery/artifact_harvester/tgui_data(mob/user)
	var/list/data = list()
	data["isBatteryLoaded"] = is_battery_loaded
	data["isHarvesting"] = is_harvesting
	data["isDraining"] = is_draining
	data["maxEnergy"] = inserted_battery ? inserted_battery.battery_effect?.maximum_charges : 0
	data["currentEnergy"] = inserted_battery ? inserted_battery.battery_effect?.current_charge : 0
	return data

/obj/machinery/artifact_harvester/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArtifactHarvester", name)
		ui.open()

/obj/machinery/artifact_harvester/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return
	playsound(src, pick(SOUNDIN_KEYBOARD), VOL_EFFECTS_MASTER, null, FALSE)
	switch(action)
		if("start_harvest")
			. = TRUE
			if(!can_harvest())
				return
			start_harvest()
		if("stop_harvest")
			. = TRUE
			if(is_draining || !is_harvesting)
				return
			stop_harvest()
		if("eject_battery")
			. = TRUE
			if(!is_battery_loaded)
				return
			if(is_draining || is_harvesting)
				return
			is_battery_loaded = FALSE
			inserted_battery.forceMove(loc)
			inserted_battery.update_icon()
			src.inserted_battery = null
			update_icon()
			owned_scanner.icon_state = "xenoarch_scanner"
			playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER)
		if("drain_battery")
			. = TRUE
			drain_battery()
		if("locate_telepad")
			. = TRUE
			locate_telepad()

/obj/machinery/artifact_harvester/ui_interact(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	tgui_interact(user)

/obj/machinery/artifact_harvester/process()
	if(stat & (NOPOWER|BROKEN))
		return
	if(is_harvesting)
		inserted_battery.battery_effect.current_charge = min(inserted_battery.battery_effect.current_charge + 10, inserted_battery.capacity)
		if(inserted_battery.battery_effect.current_charge >= inserted_battery.capacity)
			stop_harvest()
			visible_message("<b>[name]</b> states, \"Battery is full.\"")
			playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
			owned_scanner.icon_state = "xenoarch_scanner"
	else if(is_draining)
		inserted_battery.battery_effect.current_charge = max(inserted_battery.battery_effect.current_charge - 20, 0)
		// if the effect works by touch, activate it on anyone viewing the console
		if(inserted_battery.battery_effect.release_method == ARTIFACT_EFFECT_TOUCH)
			var/list/nearby = viewers(1, src)
			for(var/mob/M in nearby)
				inserted_battery.battery_effect.DoEffectTouch(M)
		if(inserted_battery.battery_effect.current_charge <= 0)
			set_power_use(IDLE_POWER_USE)
			is_draining = FALSE
			QDEL_NULL(inserted_battery.battery_effect)
			visible_message("<b>[name]</b> states, \"Battery is empty.\"")
			playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
			update_icon()
