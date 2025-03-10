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
	var/harvesting = FALSE
	var/draining = FALSE
	var/obj/item/weapon/particles_battery/inserted_battery
	var/obj/machinery/artifact/current_artifact
	var/obj/machinery/artifact_scanpad/owned_scanner = null
	required_skills = list(/datum/skill/research = SKILL_LEVEL_TRAINED)


/obj/machinery/artifact_harvester/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/artifact_harvester/atom_init_late()
	// connect to a nearby scanner pad
	owned_scanner = locate(/obj/machinery/artifact_scanpad) in get_step(src, dir)
	if(!owned_scanner)
		owned_scanner = locate(/obj/machinery/artifact_scanpad) in orange(1, src)


/obj/machinery/artifact_harvester/attackby(obj/I, mob/user)
	if(istype(I,/obj/item/weapon/particles_battery))
		if(!inserted_battery)
			to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
			playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER)
			user.drop_from_inventory(I, src)
			src.inserted_battery = I
			icon_state = "harvester_battery"
			updateDialog()
		else
			to_chat(user, "<span class='warning'>There is already a battery in [src].</span>")
	else
		return..()


/obj/machinery/artifact_harvester/ui_interact(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	var/dat = "<B>Artifact Power Harvester</B><BR>"
	dat += "<HR><BR>"
	//
	if(owned_scanner)
		if(harvesting || draining)
			if(harvesting)
				dat += "Please wait. Harvesting in progress ([round((inserted_battery.stored_charge/inserted_battery.capacity)*100)]%).<br>"
				dat += "<A href='?src=\ref[src];stopharvest=1'>Halt early</A><BR>"
			if(draining)
				dat += "Please wait. Energy dump in progress ([round((inserted_battery.stored_charge/inserted_battery.capacity)*100)]%).<br>"
		else if(inserted_battery)
			dat += "<b>[inserted_battery.name]</b> inserted, charge level: [round(inserted_battery.stored_charge,1)]/[inserted_battery.capacity] ([round((inserted_battery.stored_charge/inserted_battery.capacity)*100)]%)<BR>"
			dat += "<b>Energy signature ID:</b>[inserted_battery.battery_effect ? (inserted_battery.battery_effect.artifact_id == "" ? "???" : "[inserted_battery.battery_effect.artifact_id]") : "NA"]<BR>"
			dat += "<A href='?src=\ref[src];ejectbattery=1'>Eject battery</a><BR>"
			dat += "<A href='?src=\ref[src];drainbattery=1'>Drain battery of all charge</a><BR>"
			dat += "<A href='?src=\ref[src];harvest=1'>Begin harvesting</a><BR>"

		else
			dat += "No battery inserted.<BR>"
	else
		dat += "<B><font color=red>Unable to locate analysis pad.</font><BR></b>"
	//
	dat += "<HR>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh</A>"

	var/datum/browser/popup = new(user, "artharvester", name, 450, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/artifact_harvester/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(harvesting)
		inserted_battery.stored_charge = min(inserted_battery.stored_charge + 5, inserted_battery.capacity)

		// check if we've finished
		if(inserted_battery.stored_charge >= inserted_battery.capacity)
			set_power_use(IDLE_POWER_USE)
			harvesting = FALSE
			current_artifact.anchored = FALSE
			current_artifact.being_used = FALSE
			current_artifact = null
			visible_message("<b>[name]</b> states, \"Battery is full.\"")
			playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
			icon_state = "harvester_battery"
			owned_scanner.icon_state = "xenoarch_scanner"

	else if(draining)
		// dump some charge
		inserted_battery.stored_charge = max(inserted_battery.stored_charge - 5, 0)
		// if the effect works by touch, activate it on anyone viewing the console
		if(inserted_battery.battery_effect.release_method == ARTIFACT_EFFECT_TOUCH)
			var/list/nearby = viewers(1, src)
			for(var/mob/M in nearby)
				inserted_battery.battery_effect.DoEffectTouch(M)

		// if there's no charge left, finish
		if(inserted_battery.stored_charge <= 0)
			set_power_use(IDLE_POWER_USE)
			inserted_battery.stored_charge = 0
			draining = FALSE
			inserted_battery.battery_effect = null
			QDEL_NULL(inserted_battery.battery_effect)
			visible_message("<b>[name]</b> states, \"Battery dump completed.\"")
			icon_state = "harvester_battery"

/obj/machinery/artifact_harvester/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(href_list["harvest"])
		playsound(src, pick(SOUNDIN_KEYBOARD), VOL_EFFECTS_MASTER, null, FALSE)

		if(!inserted_battery)
			visible_message("<b>[name]</b> states, \"Cannot harvest. No battery inserted.\"")
			return
		if(inserted_battery.stored_charge == inserted_battery.capacity)
			visible_message("<b>[name]</b> states, \"Cannot harvest. battery is full.\"")
			return

		// locate artifact on analysis pad
		current_artifact = null
		var/obj/machinery/artifact/analysed
		for(var/obj/machinery/artifact/A in get_turf(owned_scanner))
			analysed = A
			if(analysed.being_used)
				visible_message("<b>[name]</b> states, \"Cannot harvest. Source already being harvested.\"")
				playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)
				return
		current_artifact = analysed
		if(!current_artifact)
			var/message = "<b>[name]</b> states, \"Cannot harvest. No noteworthy energy signature isolated.\""
			playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)
			visible_message(message)
			return

		// if both effects arent active, we cant harvest anything
		if(current_artifact.first_effect && !current_artifact.first_effect.activated  && !current_artifact?.secondary_effect?.activated)
			visible_message("<b>[name]</b> states, \"Cannot harvest. No energy emitting from source.\"")
			playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)
			return

		// if both effects are active, we cant harvest anything
		if(current_artifact.first_effect && current_artifact.first_effect.activated && current_artifact.secondary_effect && current_artifact.secondary_effect.activated)
			visible_message("<b>[name]</b> states, \"Cannot harvest. Source is emitting conflicting energy signatures.\"")
			playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)
			return

		var/datum/artifact_effect/harvested_effect
		if(current_artifact.first_effect.activated)
			harvested_effect = current_artifact.first_effect
		else
			if(current_artifact.secondary_effect && current_artifact.secondary_effect.activated)
				harvested_effect = current_artifact.secondary_effect

		// if we already have charge in the battery, we can only recharge it from the source artifact
		if(inserted_battery.stored_charge)
			if(inserted_battery.battery_effect != harvested_effect)
				visible_message("<b>[name]</b> states, \"Cannot harvest. Battery is charged with a different energy signature.\"")
				return

		harvesting = TRUE
		set_power_use(ACTIVE_POWER_USE)
		current_artifact.anchored = TRUE
		current_artifact.being_used = TRUE
		icon_state = "harvester_on"
		owned_scanner.icon_state = "xenoarch_scanner_scanning"
		visible_message("<b>[name]</b> states, \"Beginning energy harvesting\"")

		inserted_battery.battery_effect = null
		// duplicate the artifact's effect datum
		if(!inserted_battery.battery_effect)
			var/new_effect_type = harvested_effect.type
			var/datum/artifact_effect/E = new new_effect_type(inserted_battery)
			for(var/varname in list("maximum_charges", "artifact_id", "release_method", "range", "trigger"))
				E.vars[varname] = harvested_effect.vars[varname]
			inserted_battery.battery_effect = E

	if(href_list["stopharvest"])
		playsound(src, pick(SOUNDIN_KEYBOARD), VOL_EFFECTS_MASTER, null, FALSE)
		if(draining)
			return
		if(!harvesting)
			return
		if(inserted_battery.battery_effect && inserted_battery.battery_effect.activated)
			inserted_battery.battery_effect.ToggleActivate()
		harvesting = FALSE
		current_artifact.anchored = FALSE
		current_artifact.being_used = FALSE
		current_artifact = null
		visible_message("<b>[name]</b> states, \"Energy harvesting interrupted.\"")
		icon_state = "harvester_battery"
		owned_scanner.icon_state = "xenoarch_scanner"
		set_power_use(IDLE_POWER_USE)
		updateDialog()

	if(href_list["ejectbattery"])
		if(harvesting || draining)
			visible_message("<b>[name]</b> states, \"Battery is busy.\"")
			return
		playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER)
		src.inserted_battery.loc = src.loc
		inserted_battery.update_icon()
		src.inserted_battery = null
		icon_state = "harvester"
		owned_scanner.icon_state = "xenoarch_scanner"
		updateDialog()

	if(href_list["drainbattery"])
		if(!inserted_battery)
			visible_message("<b>[name]</b> states, \"Cannot dump energy. No battery inserted.\"")
			return
		if(harvesting)
			visible_message("<b>[name]</b> states, \"Cannot dump energy. Energy harvesting is initiated.\"")
			return
		if(!inserted_battery.stored_charge)
			visible_message("<b>[name]</b> states, \"Cannot dump energy. Battery is drained of charge already.\"")
			return
		if(!inserted_battery.battery_effect)
			return
		if(tgui_alert(usr, "This action will dump all charge, safety gear is recommended before proceeding", "Warning", list("Continue", "Cancel")) != "Continue")
			return
		if(!inserted_battery.battery_effect.activated)
			inserted_battery.battery_effect.ToggleActivate(TRUE)
		draining = TRUE
		set_power_use(ACTIVE_POWER_USE)
		icon_state = "harvester_on"
		owned_scanner.icon_state = "xenoarch_scanner"
		visible_message("<b>[name]</b> states, \"Warning, battery charge dump commencing.\"")

	updateDialog()
