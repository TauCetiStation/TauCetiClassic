
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
	var/obj/item/weapon/particles_battery/inserted_battery
	var/obj/machinery/artifact/cur_artifact
	var/obj/machinery/artifact_scanpad/owned_scanner = null
	var/last_process = 0

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
			user.drop_item()
			I.loc = src
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
		if(harvesting)
			if(harvesting > 0)
				dat += "Please wait. Harvesting in progress ([round((inserted_battery.stored_charge/inserted_battery.capacity)*100)]%).<br>"
			else
				dat += "Please wait. Energy dump in progress ([round((inserted_battery.stored_charge/inserted_battery.capacity)*100)]%).<br>"
			dat += "<A href='?src=\ref[src];stopharvest=1'>Halt early</A><BR>"
		else
			if(inserted_battery)
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
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh</A> <A href='?src=\ref[src];close=1'>Close<BR>"

	var/datum/browser/popup = new(user, "artharvester", name, 450, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/artifact_harvester/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(harvesting > 0)
		// charge at 33% consumption rate
		inserted_battery.stored_charge += (world.time - last_process) / 3
		last_process = world.time

		// check if we've finished
		if(inserted_battery.stored_charge >= inserted_battery.capacity)
			set_power_use(IDLE_POWER_USE)
			harvesting = FALSE
			cur_artifact.anchored = FALSE
			cur_artifact.being_used = FALSE
			cur_artifact = null
			src.visible_message("<b>[name]</b> states, \"Battery is full.\"")
			playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
			icon_state = "harvester_battery"
			owned_scanner.icon_state = "xenoarch_scanner"

	else if(harvesting < 0)
		// dump some charge
		inserted_battery.stored_charge -= (world.time - last_process) / 3

		// do the effect
		if(inserted_battery.battery_effect)
			inserted_battery.battery_effect.process()

			// if the effect works by touch, activate it on anyone viewing the console
			if(inserted_battery.battery_effect.effect == ARTIFACT_EFFECT_TOUCH)
				var/list/nearby = viewers(1, src)
				for(var/mob/M in nearby)
					if(M.machine == src)
						inserted_battery.battery_effect.DoEffectTouch(M)

		// if there's no charge left, finish
		if(inserted_battery.stored_charge <= 0)
			set_power_use(IDLE_POWER_USE)
			inserted_battery.stored_charge = 0
			harvesting = FALSE
			if(inserted_battery.battery_effect && inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate()
			src.visible_message("<b>[name]</b> states, \"Battery dump completed.\"")
			icon_state = "harvester_battery"

/obj/machinery/artifact_harvester/Topic(href, href_list)
	if(href_list["close"])
		usr.unset_machine(src)
		usr << browse(null, "window=artharvester")
		return FALSE

	. = ..()
	if(!.)
		return

	if(href_list["harvest"])
		playsound(src, pick(SOUNDIN_KEYBOARD), VOL_EFFECTS_MASTER, null, FALSE)

		if(!inserted_battery)
			src.visible_message("<b>[src]</b> states, \"Cannot harvest. No battery inserted.\"")

		else if(inserted_battery.stored_charge >= inserted_battery.capacity)
			src.visible_message("<b>[src]</b> states, \"Cannot harvest. battery is full.\"")

		else
			// locate artifact on analysis pad
			cur_artifact = null
			var/articount = 0
			var/obj/machinery/artifact/analysed
			for(var/obj/machinery/artifact/A in get_turf(owned_scanner))
				analysed = A
				articount++

			if(articount <= 0)
				var/message = "<b>[src]</b> states, \"Cannot harvest. No noteworthy energy signature isolated.\""
				playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)
				visible_message(message)

			else if(analysed && analysed.being_used)
				src.visible_message("<b>[src]</b> states, \"Cannot harvest. Source already being harvested.\"")
				playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)

			else
				if(articount > 1)
					state("Cannot harvest. Too many artifacts on the pad.")
					playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)

				else if(analysed)
					cur_artifact = analysed

					// if we got only the first one, and it isnt active we cant harvest anything
					if(cur_artifact.my_effect && !cur_artifact.secondary_effect && !cur_artifact.my_effect.activated)
						visible_message("<b>[src]</b> states, \"Cannot harvest. No energy emitting from source.\"")
						playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)

					// if both effects are active, we cant harvest anything
					else if(cur_artifact.my_effect && cur_artifact.my_effect.activated && cur_artifact.secondary_effect && cur_artifact.secondary_effect.activated)
						visible_message("<b>[src]</b> states, \"Cannot harvest. Source is emitting conflicting energy signatures.\"")
						playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)

					// if both effects arent active, we cant harvest anything
					else if(cur_artifact.my_effect && !cur_artifact.my_effect.activated  && cur_artifact.secondary_effect && !cur_artifact.secondary_effect.activated)
						visible_message("<b>[src]</b> states, \"Cannot harvest. No energy emitting from source.\"")
						playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 20)

					else
						// see if we can clear out an old effect
						// delete it when the ids match to account for duplicate ids having different effects
						if(inserted_battery.battery_effect && inserted_battery.stored_charge <= 0)
							var/datum/artifact_effect/TD = inserted_battery.battery_effect
							inserted_battery.battery_effect = null
							qdel(TD)	// Because this effect must be deleted NOW!

						var/datum/artifact_effect/source_effect

						// if we already have charge in the battery, we can only recharge it from the source artifact
						if(inserted_battery.stored_charge > 0)
							var/battery_matches_primary_id = 0
							if(inserted_battery.battery_effect && inserted_battery.battery_effect.artifact_id == cur_artifact.my_effect.artifact_id)
								battery_matches_primary_id = 1
							if(battery_matches_primary_id && cur_artifact.my_effect.activated)
								// we're good to recharge the primary effect!
								source_effect = cur_artifact.my_effect

							var/battery_matches_secondary_id = 0
							if(inserted_battery.battery_effect && inserted_battery.battery_effect.artifact_id == cur_artifact.secondary_effect.artifact_id)
								battery_matches_secondary_id = 1
							if(battery_matches_secondary_id && cur_artifact.secondary_effect.activated)
								// we're good to recharge the secondary effect!
								source_effect = cur_artifact.secondary_effect

							if(!source_effect)
								src.visible_message("<b>[src]</b> states, \"Cannot harvest. Battery is charged with a different energy signature.\"")
						else
							// we're good to charge either
							if(cur_artifact.my_effect && cur_artifact.my_effect.activated)
								// charge the primary effect
								source_effect = cur_artifact.my_effect

							else if(cur_artifact.secondary_effect && cur_artifact.secondary_effect.activated)
								// charge the secondary effect
								source_effect = cur_artifact.secondary_effect


						if(source_effect)
							harvesting = TRUE
							set_power_use(ACTIVE_POWER_USE)
							cur_artifact.anchored = TRUE
							cur_artifact.being_used = TRUE
							icon_state = "harvester_on"
							owned_scanner.icon_state = "xenoarch_scanner_scanning"
							var/message = "<b>[src]</b> states, \"Beginning energy harvesting.\""
							src.visible_message(message)
							last_process = world.time

							// duplicate the artifact's effect datum
							if(!inserted_battery.battery_effect)
								var/new_effect_type = source_effect.type
								var/datum/artifact_effect/E = new new_effect_type(inserted_battery)

								// duplicate it's unique settings
								for(var/varname in list("chargelevelmax", "artifact_id", "effect", "effectrange", "trigger"))
									E.vars[varname] = source_effect.vars[varname]

								// copy the new datum into the battery
								inserted_battery.battery_effect = E
								inserted_battery.stored_charge = 0

	if(href_list["stopharvest"])
		playsound(src, pick(SOUNDIN_KEYBOARD), VOL_EFFECTS_MASTER, null, FALSE)
		if(harvesting)
			if(harvesting < 0 && inserted_battery.battery_effect && inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate()
			harvesting = FALSE
			cur_artifact.anchored = FALSE
			cur_artifact.being_used = FALSE
			cur_artifact = null
			src.visible_message("<b>[name]</b> states, \"Energy harvesting interrupted.\"")
			icon_state = "harvester_battery"
			owned_scanner.icon_state = "xenoarch_scanner"

	if(href_list["ejectbattery"])
		playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER)

		src.inserted_battery.loc = src.loc
		src.inserted_battery.update_icon()
		src.inserted_battery = null
		icon_state = "harvester"
		owned_scanner.icon_state = "xenoarch_scanner"

	if(href_list["drainbattery"])
		if(inserted_battery)
			if(inserted_battery.battery_effect && inserted_battery.stored_charge > 0)
				if(alert("This action will dump all charge, safety gear is recommended before proceeding", "Warning", "Continue", "Cancel"))
					if(!inserted_battery.battery_effect.activated)
						inserted_battery.battery_effect.ToggleActivate(1)
					last_process = world.time
					harvesting = -1
					set_power_use(ACTIVE_POWER_USE)
					icon_state = "harvester_on"
					owned_scanner.icon_state = "xenoarch_scanner"
					var/message = "<b>[src]</b> states, \"Warning, battery charge dump commencing.\""
					src.visible_message(message)
			else
				var/message = "<b>[src]</b> states, \"Cannot dump energy. Battery is drained of charge already.\""
				src.visible_message(message)
		else
			var/message = "<b>[src]</b> states, \"Cannot dump energy. No battery inserted.\""
			src.visible_message(message)

	updateDialog()
