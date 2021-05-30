/obj/machinery/computer/diseasesplicer
	name = "Disease Splicer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "crew"
	var/datum/disease2/effectholder/memorybank = null
	var/list/species_buffer = null
	var/analysed = 0
	var/obj/item/weapon/virusdish/dish = null
	var/burning = 0
	var/splicing = 0
	var/scanning = 0

/obj/machinery/computer/diseasesplicer/attackby(obj/I, mob/user)
	if(isscrewdriver(I))
		return ..()

	else if(istype(I,/obj/item/weapon/virusdish))
		var/mob/living/carbon/c = user
		if (dish)
			to_chat(user, "\The [src] is already loaded.")
			return

		dish = I
		c.drop_from_inventory(I, src)
		return

	else if(istype(I,/obj/item/weapon/diseasedisk))
		to_chat(user, "You upload the contents of the disk onto the buffer.")
		memorybank = I:effect
		species_buffer = I:species
		analysed = I:analysed
		qdel(I)
		return

	src.attack_hand(user)

/obj/machinery/computer/diseasesplicer/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	var/data[0]
	data["dish_inserted"] = !!dish
	data["growth"] = 0
	data["affected_species"] = null
	data["can_splice"] = FALSE

	if (memorybank)
		data["buffer"] = list("name" = (analysed ? memorybank.effect.name : "Unknown Symptom"))
	if (species_buffer)
		data["species_buffer"] = analysed ? jointext(species_buffer, ", ") : "Unknown Species"

	if (splicing)
		data["busy"] = "Splicing..."
	else if (scanning)
		data["busy"] = "Scanning..."
	else if (burning)
		data["busy"] = "Copying data to disk..."
	else if (dish)
		if (dish.virus2)
			if (dish.virus2.affected_species)
				data["affected_species"] = dish.analysed ? jointext(dish.virus2.affected_species, ", ") : "Unknown"

			var/list/effects[0]
			for(var/i in 1 to dish.virus2.effects.len)
				var/datum/disease2/effectholder/e = dish.virus2.effects[i]
				effects.Add(list(list("name" = (dish.analysed ? e.effect.name : "Unknown"), "stage" = (i), "reference" = "\ref[e]")))
			data["effects"] = effects
			data["can_splice"] = (effects.len < dish.virus2.max_symptoms)
		else
			data["info"] = "No virus detected."
	else
		data["info"] = "No dish loaded."

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "disease_splicer.tmpl", src.name, 400, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/diseasesplicer/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(scanning)
		scanning -= 1
		if(!scanning)
			ping("\The [src] pings, \"Analysis complete.\"")
			nanomanager.update_uis(src)
	if(splicing)
		splicing -= 1
		if(!splicing)
			ping("\The [src] pings, \"Splicing operation complete.\"")
			nanomanager.update_uis(src)
	if(burning)
		burning -= 1
		if(!burning)
			var/obj/item/weapon/diseasedisk/d = new /obj/item/weapon/diseasedisk(src.loc)
			d.analysed = analysed
			if(analysed)
				if (memorybank)
					d.name = "[memorybank.effect.name] GNA disk"
					d.effect = memorybank
					memorybank = null
				else if (species_buffer)
					d.name = "[jointext(species_buffer, ", ")] GNA disk"
					d.species = species_buffer
					species_buffer = null
			else
				if (memorybank)
					d.name = "Unknown GNA disk"
					d.effect = memorybank
					memorybank = null
				else if (species_buffer)
					d.name = "Unknown Species GNA disk"
					d.species = species_buffer
					species_buffer = null

			ping("\The [src] pings, \"Backup disk saved.\"")
			nanomanager.update_uis(src)

/obj/machinery/computer/diseasesplicer/Topic(href, href_list)
	var/mob/user = usr
	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")

	if (href_list["close"])
		user.unset_machine(src)
		ui.close()
		return FALSE

	. = ..()
	if(!.)
		return

	if (href_list["grab"])
		if (dish)
			memorybank = locate(href_list["grab"])
			species_buffer = null
			analysed = dish.analysed
			dish = null
			scanning = 10
		return TRUE

	if (href_list["affected_species"])
		if (dish)
			memorybank = null
			species_buffer = dish.virus2.affected_species
			analysed = dish.analysed
			dish = null
			scanning = 10
		return TRUE

	if (href_list["eject"])
		if (dish)
			dish.loc = src.loc
			dish = null
		return TRUE

	if (href_list["splice"])
		if (dish)
			if (memorybank && !dish.virus2.haseffect(memorybank.effect))
				memorybank.stage = 1
				memorybank.ticks = 0
				memorybank.cooldownticks = 0
				memorybank.chance = rand(memorybank.effect.chance_minm,memorybank.effect.chance_maxm)
				dish.virus2.addeffect(memorybank)
				memorybank = null

			if (species_buffer)
				dish.virus2.affected_species = species_buffer
				species_buffer = null

			splicing = 10
			dish.virus2.uniqueID = rand(0,10000)
		return TRUE

	if (href_list["disk"])
		burning = 10
		return TRUE

	return FALSE
