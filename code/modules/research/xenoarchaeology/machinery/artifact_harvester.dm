
/obj/machinery/artifact_harvester
	name = "Exotic Particle Harvester"
	icon = 'icons/obj/virology.dmi'
	icon_state = "incubator"	//incubator_on
	anchored = 1
	density = 1
	idle_power_usage = 50
	active_power_usage = 750
	use_power = 1
	var/harvesting = 0
	var/obj/item/weapon/anobattery/inserted_battery
	var/obj/machinery/artifact/cur_artifact
	var/obj/machinery/artifact_scanpad/owned_scanner = null
	var/last_process = 0

/obj/machinery/artifact_harvester/New()
	..()
	//connect to a nearby scanner pad
	owned_scanner = locate(/obj/machinery/artifact_scanpad) in get_step(src, dir)
	if(!owned_scanner)
		owned_scanner = locate(/obj/machinery/artifact_scanpad) in orange(1, src)

/obj/machinery/artifact_harvester/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I,/obj/item/weapon/anobattery))
		if(!inserted_battery)
			user << "\blue You insert [I] into [src]."
			user.drop_item()
			I.loc = src
			src.inserted_battery = I
			updateDialog()
		else
			user << "\red There is already a battery in [src]."
	else
		return..()

/obj/machinery/artifact_harvester/attack_hand(var/mob/user as mob)
	src.add_fingerprint(user)
	ui_interact(user)

/obj/machinery/artifact_harvester/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	user.set_machine(src)

	var/data[0]
	if(owned_scanner)
		data["has_scanner"] = 1
		if(harvesting)
			data["battery_charge_level"] = round((inserted_battery.stored_charge/inserted_battery.capacity)*100)
			if(harvesting > 0)
				data["harvesting"] = 1
			else
				data["harvesting"] = -1
		else
			if(inserted_battery)
				data["has_battery"] = 1
				data["battery_name"] = inserted_battery.name
				data["battery_charge"] = round(inserted_battery.stored_charge,1)
				data["battery_capacity"] = inserted_battery.capacity
				data["battery_charge_level"] = round((inserted_battery.stored_charge/inserted_battery.capacity)*100)
				data["energy_signature"] = inserted_battery.battery_effect ? (inserted_battery.battery_effect.artifact_id == "" ? "???" : "[inserted_battery.battery_effect.artifact_id]") : "NA"
			else
				data["has_battery"] = 0
	else
		data["has_scanner"] = 0

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "artifact_harvester.tmpl", "Artifact Power Harvester", 550, 350)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/artifact_harvester/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(harvesting > 0)
		//charge at 33% consumption rate
		inserted_battery.stored_charge += (world.time - last_process) / 3
		last_process = world.time

		//check if we've finished
		if(inserted_battery.stored_charge >= inserted_battery.capacity)
			use_power = 1
			harvesting = 0
			cur_artifact.anchored = 0
			cur_artifact.being_used = 0
			cur_artifact = null
			src.visible_message("<b>[name]</b> states, \"Battery is full.\"")
			icon_state = "incubator"

	else if(harvesting < 0)
		//dump some charge
		inserted_battery.stored_charge -= (world.time - last_process) / 3

		//do the effect
		if(inserted_battery.battery_effect)
			inserted_battery.battery_effect.process()

			//if the effect works by touch, activate it on anyone viewing the console
			if(inserted_battery.battery_effect.effect == EFFECT_TOUCH)
				var/list/nearby = viewers(1, src)
				for(var/mob/M in nearby)
					if(M.machine == src)
						inserted_battery.battery_effect.DoEffectTouch(M)

		//if there's no charge left, finish
		if(inserted_battery.stored_charge <= 0)
			use_power = 1
			inserted_battery.stored_charge = 0
			harvesting = 0
			if(inserted_battery.battery_effect && inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate()
			src.visible_message("<b>[name]</b> states, \"Battery dump completed.\"")
			icon_state = "incubator"

/obj/machinery/artifact_harvester/Topic(href, href_list)
	if (..()) return 0

	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")

	src.add_fingerprint(user)

	if (href_list["harvest"])
		if(!inserted_battery)
			src.visible_message("<b>[src]</b> states, \"Cannot harvest. No battery inserted.\"")

		else if(inserted_battery.stored_charge >= inserted_battery.capacity)
			src.visible_message("<b>[src]</b> states, \"Cannot harvest. battery is full.\"")

		else
			//locate artifact on analysis pad
			cur_artifact = null
			var/articount = 0
			var/obj/machinery/artifact/analysed
			for(var/obj/machinery/artifact/A in get_turf(owned_scanner))
				analysed = A
				articount++

			if(articount <= 0)
				var/message = "<b>[src]</b> states, \"Cannot harvest. No noteworthy energy signature isolated.\""
				src.visible_message(message)

			else if(analysed && analysed.being_used)
				src.visible_message("<b>[src]</b> states, \"Cannot harvest. Source already being harvested.\"")

			else
				if(articount > 1)
					state("Cannot harvest. Too many artifacts on the pad.")

				else if(analysed)
					cur_artifact = analysed
					//if both effects are active, we can't harvest either
					if(cur_artifact.my_effect && cur_artifact.my_effect.activated && cur_artifact.secondary_effect.activated)
						src.visible_message("<b>[src]</b> states, \"Cannot harvest. Source is emitting conflicting energy signatures.\"")

					else if(!cur_artifact.my_effect.activated && !cur_artifact.secondary_effect.activated)
						src.visible_message("<b>[src]</b> states, \"Cannot harvest. No energy emitting from source.\"")

					else
						//see if we can clear out an old effect
						//delete it when the ids match to account for duplicate ids having different effects
						if(inserted_battery.battery_effect && inserted_battery.stored_charge <= 0)
							var/datum/artifact_effect/TD = inserted_battery.battery_effect
							inserted_battery.battery_effect = null
							qdel(TD)	//Because this effect must be deleted NOW!

						//
						var/datum/artifact_effect/source_effect

						//if we already have charge in the battery, we can only recharge it from the source artifact
						if(inserted_battery.stored_charge > 0)
							var/battery_matches_primary_id = 0
							if(inserted_battery.battery_effect && inserted_battery.battery_effect.artifact_id == cur_artifact.my_effect.artifact_id)
								battery_matches_primary_id = 1
							if(battery_matches_primary_id && cur_artifact.my_effect.activated)
								//we're good to recharge the primary effect!
								source_effect = cur_artifact.my_effect

							var/battery_matches_secondary_id = 0
							if(inserted_battery.battery_effect && inserted_battery.battery_effect.artifact_id == cur_artifact.secondary_effect.artifact_id)
								battery_matches_secondary_id = 1
							if(battery_matches_secondary_id && cur_artifact.secondary_effect.activated)
								//we're good to recharge the secondary effect!
								source_effect = cur_artifact.secondary_effect

							if(!source_effect)
								src.visible_message("<b>[src]</b> states, \"Cannot harvest. Battery is charged with a different energy signature.\"")
						else
							//we're good to charge either
							if(cur_artifact.my_effect.activated)
								//charge the primary effect
								source_effect = cur_artifact.my_effect

							else if(cur_artifact.secondary_effect.activated)
								//charge the secondary effect
								source_effect = cur_artifact.secondary_effect


						if(source_effect)
							harvesting = 1
							use_power = 2
							cur_artifact.anchored = 1
							cur_artifact.being_used = 1
							icon_state = "incubator_on"
							var/message = "<b>[src]</b> states, \"Beginning energy harvesting.\""
							src.visible_message(message)
							last_process = world.time

							//duplicate the artifact's effect datum
							if(!inserted_battery.battery_effect)
								var/effecttype = source_effect.type
								var/datum/artifact_effect/E = new effecttype(inserted_battery)

								//duplicate it's unique settings
								for(var/varname in list("chargelevelmax","artifact_id","effect","effectrange","trigger"))
									E.vars[varname] = source_effect.vars[varname]

								//copy the new datum into the battery
								inserted_battery.battery_effect = E
								inserted_battery.stored_charge = 0
		return 1

	if (href_list["stopharvest"])
		if(harvesting)
			if(harvesting < 0 && inserted_battery.battery_effect && inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate()
			harvesting = 0
			cur_artifact.anchored = 0
			cur_artifact.being_used = 0
			cur_artifact = null
			src.visible_message("<b>[name]</b> states, \"Energy harvesting interrupted.\"")
			icon_state = "incubator"
		return 1

	if (href_list["ejectbattery"])
		src.inserted_battery.loc = src.loc
		src.inserted_battery = null
		return 1

	if (href_list["drainbattery"])
		if(inserted_battery)
			if(inserted_battery.battery_effect && inserted_battery.stored_charge > 0)
				if(alert("This action will dump all charge, safety gear is recommended before proceeding","Warning","Continue","Cancel"))
					if(!inserted_battery.battery_effect.activated)
						inserted_battery.battery_effect.ToggleActivate(1)
					last_process = world.time
					harvesting = -1
					use_power = 2
					icon_state = "incubator_on"
					var/message = "<b>[src]</b> states, \"Warning, battery charge dump commencing.\""
					src.visible_message(message)
			else
				var/message = "<b>[src]</b> states, \"Cannot dump energy. Battery is drained of charge already.\""
				src.visible_message(message)
		else
			var/message = "<b>[src]</b> states, \"Cannot dump energy. No battery inserted.\""
			src.visible_message(message)
		return 1

	if(href_list["refresh"])
		ui_interact(user)
		return 1

	if(href_list["close"])
		user.unset_machine()
		ui.close()
		return 0

	return 0
