//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter. It also contains the /datum/research holder with all the known/possible technology paths and device designs.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The imprinting and construction menus do NOT require toxins access to access but all the other menus do. However, if you leave it
on a menu, nothing is to stop the person from using the options on that menu (although they won't be able to change to a different
one). You can also lock the console on the settings menu if you're feeling paranoid and you don't want anyone messing with it who
doesn't have toxins access.

When a R&D console is destroyed or even partially disassembled, you lose all research data on it. However, there is a way around
this dire fate:
- Go to the settings menu and select "Sync Database with Network." That causes it to upload (but not download)
it's data to every other device in the game. Each console has a "disconnect from network" option that'll will cause data base sync
operations to skip that console. This is useful if you want to make a "public" R&D console or, for example, give the engineers
a circuit imprinter with certain designs on it and don't want it accidentally updating. The downside of this method is that you have
to have physical access to the other console to send data back. Note: An R&D console is on CentCom so if a random griffan happens to
cause a ton of data to be lost, an admin can go send it back.

*/

/obj/machinery/computer/rdconsole
	name = "R&D Console"
	icon_state = "rdcomp"
	light_color = "#a97faa"
	circuit = /obj/item/weapon/circuitboard/rdconsole
	var/datum/research/files							//Stores all the collected research data.
	var/obj/item/weapon/disk/tech_disk/t_disk = null	//Stores the technology disk.
	var/obj/item/weapon/disk/design_disk/d_disk = null	//Stores the design disk.

	var/obj/machinery/r_n_d/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/r_n_d/protolathe/linked_lathe = null				//Linked Protolathe
	var/obj/machinery/r_n_d/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter

	var/screen = "main"       //Which screen is currently showing.
	var/id = 0                //ID of the computer (for server restrictions).
	var/sync = TRUE           //If sync = 0, it doesn't show up on Server Control Console
	var/can_research = TRUE   //Is this console capable of researching

	var/selected_tech_tree
	var/selected_technology
	var/show_settings = FALSE
	var/show_link_menu = FALSE
	var/selected_protolathe_category
	var/selected_imprinter_category
	var/search_text

	req_access = list(access_research)	//Data and setting manipulation requires scientist access.
	allowed_checks = ALLOWED_CHECK_NONE

/obj/machinery/computer/rdconsole/proc/CallMaterialName(ID)
	var/datum/reagent/temp_reagent
	var/return_name = null
	if (copytext(ID, 1, 2) == "$")
		return_name = copytext(ID, 2)
		switch(return_name)
			if("metal")
				return_name = "Metal"
			if("glass")
				return_name = "Glass"
			if("gold")
				return_name = "Gold"
			if("silver")
				return_name = "Silver"
			if("phoron")
				return_name = "Solid Phoron"
			if("uranium")
				return_name = "Uranium"
			if("diamond")
				return_name = "Diamond"
			if("bananium")
				return_name = "Bananium"
	else
		for(var/R in subtypesof(/datum/reagent))
			temp_reagent = null
			temp_reagent = new R()
			if(temp_reagent.id == ID)
				return_name = temp_reagent.name
				qdel(temp_reagent)
				temp_reagent = null
				break
	return return_name

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/r_n_d/D in oview(3,src))
		if(D.linked_console != null || D.disabled || D.panel_open)
			continue
		if(istype(D, /obj/machinery/r_n_d/destructive_analyzer))
			if(linked_destroy == null)
				linked_destroy = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/protolathe))
			if(linked_lathe == null)
				linked_lathe = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/r_n_d/circuit_imprinter))
			if(linked_imprinter == null)
				linked_imprinter = D
				D.linked_console = src
	return

//Have it automatically push research to the centcomm server so wild griffins can't fuck up R&D's work --NEO
/obj/machinery/computer/rdconsole/proc/griefProtection()
	for(var/obj/machinery/r_n_d/server/centcom/C in rnd_server_list)
		C.files.download_from(files)

/obj/machinery/computer/rdconsole/atom_init()
	. = ..()
	RDcomputer_list += src
	files = new /datum/research(src) //Setup the research data holder.
	SyncRDevices()

/obj/machinery/computer/rdconsole/Destroy()
	RDcomputer_list -= src
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_destroy = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_destroy = null
	return ..()

/obj/machinery/computer/rdconsole/attackby(obj/item/D, mob/user)
	if(istype(D, /obj/item/weapon/disk/research_points))
		var/obj/item/weapon/disk/research_points/disk = D
		to_chat(user, "<span class='notice'>[name] received [disk.stored_points] research points from [disk.name]</span>")
		files.research_points += disk.stored_points
		user.remove_from_mob(disk)
		qdel(disk)
	else if(ismultitool(D))
		var/obj/item/device/multitool/M = D
		M.buffer = src
		to_chat(user, "<span class='notice'>You save the data in the [D.name]'s buffer.</span>")
	else if(istype(D, /obj/item/device/science_tool))
		var/research_points = files.experiments.read_science_tool(D)
		if(research_points > 0)
			to_chat(user, "<span class='notice'>[name] received [research_points] research points from uploaded data.</span>")
			files.research_points += research_points
		else
			to_chat(user, "<span class='notice'>There was no usefull data inside [D.name]'s buffer.</span>")
	else
		//The construction/deconstruction of the console code.
		..()
	nanomanager.update_uis(src)

/obj/machinery/computer/rdconsole/emag_act(mob/user)
	if(!emagged)
		playsound(src, 'sound/effects/sparks4.ogg', VOL_EFFECTS_MASTER)
		emagged = 1
		user.SetNextMove(CLICK_CD_INTERACT)
		to_chat(user, "<span class='notice'>You you disable the security protocols</span>")
		return TRUE
	return FALSE

/obj/machinery/computer/rdconsole/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["select_tech_tree"])
		var/new_select_tech_tree = href_list["select_tech_tree"]
		if(files.all_technologies[new_select_tech_tree])
			selected_tech_tree = new_select_tech_tree
			selected_technology = null
	if(href_list["select_technology"])
		var/new_selected_technology = href_list["select_technology"]
		if(files.all_technologies[selected_tech_tree][new_selected_technology])
			var/datum/technology/T = files.all_technologies[selected_tech_tree][new_selected_technology]

			T.reliability_upgrade_cost = files.GetReliabilityUpgradeCost(T)
			T.avg_reliability = files.GetAverageDesignReliability(T)

			selected_technology = new_selected_technology
	if(href_list["unlock_technology"])
		var/unlock = href_list["unlock_technology"]
		files.UnlockTechology(files.all_technologies[selected_tech_tree][unlock])
	if(href_list["upgrade_technology"])
		var/upgrade = href_list["upgrade_technology"]
		files.UpgradeTechology(files.all_technologies[selected_tech_tree][upgrade])
	if(href_list["go_screen"])
		var/where = href_list["go_screen"]
		if(href_list["need_access"])
			if(!allowed(usr) && !emagged)
				to_chat(usr, "<span class='warning'>Unauthorized Access.</span>")
				return
		screen = where
		if(screen == "protolathe" || screen == "circuit_imprinter")
			search_text = ""
	if(href_list["toggle_settings"])
		if(allowed(usr) || emagged)
			show_settings = !show_settings
		else
			to_chat(usr, "<span class='warning'>Unauthorized Access.</span>")
	if(href_list["toggle_link_menu"])
		if(allowed(usr) || emagged)
			show_link_menu = !show_link_menu
		else
			to_chat(usr, "<span class='warning'>Unauthorized Access.</span>")
	if(href_list["sync"]) //Sync the research holder with all the R&D consoles in the game that aren't sync protected.
		if(!sync)
			to_chat(usr, "<span class='warning'>You must connect to the network first!</span>")
		else
			screen = "working"
			griefProtection() //Putting this here because I dont trust the sync process
			addtimer(CALLBACK(src, .proc/sync_tech), 3 SECONDS)
	if(href_list["togglesync"]) //Prevents the console from being synced by other consoles. Can still send data.
		sync = !sync
	if(href_list["select_category"])
		var/what_cat = href_list["select_category"]
		if(screen == "protolathe")
			selected_protolathe_category = what_cat
		if(screen == "circuit_imprinter")
			selected_imprinter_category = what_cat
	if(href_list["build"] && screen == "protolathe" && linked_lathe) //Causes the Protolathe to build something.
		var/amount=text2num(href_list["amount"])
		var/datum/design/being_built = null
		for(var/datum/design/D in files.known_designs)
			if(D.id == href_list["build"])
				being_built = D
				break
		if(being_built && amount)
			linked_lathe.queue_design(being_built, amount)
	if(href_list["build"] && screen == "circuit_imprinter" && linked_imprinter)
		var/datum/design/being_built = null
		for(var/datum/design/D in files.known_designs)
			if(D.id == href_list["build"])
				being_built = D
				break
		if(being_built)
			linked_imprinter.queue_design(being_built)
	if(href_list["search"])
		var/input = sanitize_safe(input(usr, "Enter text to search", "Searching") as null|text, MAX_LNAME_LEN)
		search_text = input
		if(screen == "protolathe")
			if(!search_text)
				selected_protolathe_category = null
			else
				selected_protolathe_category = "Search Results"
		if(screen == "circuit_imprinter")
			if(!search_text)
				selected_imprinter_category = null
			else
				selected_imprinter_category = "Search Results"
	if(href_list["clear_queue"])
		if(screen == "protolathe" && linked_lathe)
			linked_lathe.clear_queue()
		if(screen == "circuit_imprinter" && linked_imprinter)
			linked_imprinter.clear_queue()
	if(href_list["restart_queue"])
		if(screen == "protolathe" && linked_lathe)
			linked_lathe.restart_queue()
		if(screen == "circuit_imprinter" && linked_imprinter)
			linked_imprinter.restart_queue()
	if(href_list["deconstruct"])
		if(linked_destroy)
			linked_destroy.deconstruct_item()
	if(href_list["eject_item"])
		if(linked_destroy)
			linked_destroy.eject_item()
	if(href_list["imprinter_purgeall"] && linked_imprinter)
		linked_imprinter.reagents.clear_reagents()
	if(href_list["imprinter_purge"] && linked_imprinter)
		linked_imprinter.reagents.del_reagent(href_list["imprinter_purge"])
	if(href_list["lathe_ejectsheet"] && linked_lathe)
		var/desired_num_sheets = text2num(href_list["lathe_ejectsheet_amt"])
		linked_lathe.eject_sheet(href_list["lathe_ejectsheet"], desired_num_sheets)
	if(href_list["imprinter_ejectsheet"] && linked_imprinter)
		var/desired_num_sheets = text2num(href_list["imprinter_ejectsheet_amt"])
		linked_imprinter.eject_sheet(href_list["imprinter_ejectsheet"], desired_num_sheets)
	if(href_list["find_device"])
		screen = "working"
		addtimer(CALLBACK(src, .proc/find_devices), 2 SECONDS)
	if(href_list["disconnect"]) //The R&D console disconnects with a specific device.
		switch(href_list["disconnect"])
			if("destroy")
				linked_destroy.linked_console = null
				linked_destroy = null
			if("lathe")
				linked_lathe.linked_console = null
				linked_lathe = null
			if("imprinter")
				linked_imprinter.linked_console = null
				linked_imprinter = null
	if(href_list["reset"]) //Reset the R&D console's database.
		griefProtection()
		var/choice = alert("R&D Console Database Reset", "Are you sure you want to reset the R&D console's database? Data lost cannot be recovered.", "Continue", "Cancel")
		if(choice == "Continue")
			screen = "working"
			qdel(files)
			files = new /datum/research(src)
			spawn(20)
				screen = "main"
				nanomanager.update_uis(src)
	if(href_list["lock"]) //Lock the console from use by anyone without tox access.
		if(allowed(usr) || emagged)
			screen = "locked"
		else
			to_chat(usr, "<span class='warning'>Unauthorized Access.</span>")
	if(href_list["unlock"])
		if(allowed(usr) || emagged)
			screen = "main"
		else
			to_chat(usr, "<span class='warning'>Unauthorized Access.</span>")

	return TRUE

/obj/machinery/computer/rdconsole/proc/find_devices()
	SyncRDevices()
	screen = "main"
	nanomanager.update_uis(src)

/obj/machinery/computer/rdconsole/proc/sync_tech()
	for(var/obj/machinery/r_n_d/server/S in rnd_server_list)
		var/server_processed = 0
		if(S.disabled)
			continue
		if((id in S.id_with_upload) || istype(S, /obj/machinery/r_n_d/server/centcom))
			S.files.download_from(files)
			server_processed = 1
		if(((id in S.id_with_download) && !istype(S, /obj/machinery/r_n_d/server/centcom)) || S.hacked)
			files.download_from(S.files)
			server_processed = 1
		if(!istype(S, /obj/machinery/r_n_d/server/centcom) && server_processed)
			S.produce_heat(100)
	screen = "main"
	nanomanager.update_uis(src)

/obj/machinery/computer/rdconsole/proc/get_protolathe_data()
	var/list/protolathe_list = list(
		"max_material_storage" =             linked_lathe.max_material_storage,
		"total_materials" =                  linked_lathe.TotalMaterials(),
	)
	var/list/material_list = list()
	for(var/M in linked_lathe.loaded_materials)
		material_list += list(list(
			"id" =             M,
			"name" =           linked_lathe.loaded_materials[M].name,
			"ammount" =        linked_lathe.loaded_materials[M].amount,
			"can_eject_one" =  linked_lathe.loaded_materials[M].amount >= linked_lathe.loaded_materials[M].sheet_size,
			"can_eject_five" = linked_lathe.loaded_materials[M].amount >= (linked_lathe.loaded_materials[M].sheet_size * 5),
		))
	protolathe_list["materials"] = material_list
	return protolathe_list

/obj/machinery/computer/rdconsole/proc/get_imprinter_data()
	var/list/imprinter_list = list(
		"max_material_storage" =             linked_imprinter.max_material_amount,
		"total_materials" =                  linked_imprinter.TotalMaterials(),
		"total_volume" =                     linked_imprinter.reagents.total_volume,
		"maximum_volume" =                   linked_imprinter.reagents.maximum_volume,
	)
	var/list/printer_reagent_list = list()
	for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)
		printer_reagent_list += list(list(
			"id" =             R.id,
			"name" =           R.name,
			"volume" =         R.volume,
		))
	imprinter_list["reagents"] = printer_reagent_list
	var/list/material_list = list()
	for(var/M in linked_imprinter.loaded_materials)
		material_list += list(list(
			"id" =             M,
			"name" =           linked_imprinter.loaded_materials[M].name,
			"ammount" =        linked_imprinter.loaded_materials[M].amount,
			"can_eject_one" =  linked_imprinter.loaded_materials[M].amount >= linked_imprinter.loaded_materials[M].sheet_size,
			"can_eject_five" = linked_imprinter.loaded_materials[M].amount >= (linked_imprinter.loaded_materials[M].sheet_size * 5),
		))
	imprinter_list["materials"] = material_list
	return imprinter_list

/obj/machinery/computer/rdconsole/proc/get_possible_designs_data(build_type, category)
	var/coeff = 1
	if(build_type == PROTOLATHE)
		coeff = linked_lathe.efficiency_coeff
	if(build_type == IMPRINTER)
		coeff = linked_imprinter.efficiency_coeff

	var/list/designs_list = list()
	for(var/datum/design/D in files.known_designs)
		if(D.build_type & build_type)
			var/cat = list("Unspecified")
			if(D.category)
				cat = D.category
			if((category in cat) || (category == "Search Results" && findtext(D.name, search_text)))
				var/temp_material
				var/c = 50
				var/t
				for(var/M in D.materials)
					if(build_type == PROTOLATHE)
						t = linked_lathe.check_mat(D, M)
					if(build_type == IMPRINTER)
						t = linked_imprinter.check_mat(D, M)

					if(t < 1)
						temp_material += " <span style=\"color:red\">[D.materials[M]/coeff] [CallMaterialName(M)]</span>"
					else
						temp_material += " [D.materials[M]/coeff] [CallMaterialName(M)]"
					c = min(t,c)

				designs_list += list(list(
					"id" =             D.id,
					"name" =           D.name,
					"desc" =           D.desc,
					"can_create" =     c,
					"temp_material" =  temp_material,
				))
	return designs_list

/obj/machinery/computer/rdconsole/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if((screen == "protolathe" && !linked_lathe) || (screen == "circuit_imprinter" && !linked_imprinter))
		screen = "main" // Kick us from protolathe or imprinter screen if they were destroyed

	var/list/data = list()
	data["screen"] = screen
	data["sync"] = sync

	// Main screen needs info about tech levels
	if(!screen || screen == "main")
		data["show_settings"] = show_settings
		data["show_link_menu"] = show_link_menu
		data["has_dest_analyzer"] = !!linked_destroy
		data["has_protolathe"] = !!linked_lathe
		data["has_circuit_imprinter"] = !!linked_imprinter
		data["can_research"] = can_research

		var/list/tech_tree_list = list()
		for(var/tech_tree_id in files.tech_trees)
			var/datum/tech/Tech_Tree = files.tech_trees[tech_tree_id]
			if(!Tech_Tree.shown)
				continue
			var/list/tech_tree_data = list(
				"id" =             Tech_Tree.id,
				"name" =           "[Tech_Tree.name]",
				"shortname" =      "[Tech_Tree.shortname]",
				"level" =          Tech_Tree.level,
				"maxlevel" =       Tech_Tree.maxlevel,
			)
			tech_tree_list += list(tech_tree_data)
		data["tech_trees"] = tech_tree_list

		if(linked_lathe)
			data["protolathe_data"] = get_protolathe_data()

		if(linked_imprinter)
			data["imprinter_data"] = get_imprinter_data()

		if(linked_destroy)
			if(linked_destroy.loaded_item)
				var/list/tech_names = list("materials" = "Materials", "engineering" = "Engineering", "phorontech" = "Phoron", "powerstorage" = "Power", "bluespace" = "Blue-space", "biotech" = "Biotech", "combat" = "Combat", "magnets" = "Electromagnetic", "programming" = "Programming", "syndicate" = "Illegal")

				var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
				var/list/item_data = list()

				for(var/T in temp_tech)
					var/tech_name = tech_names[T]
					if(!tech_name)
						tech_name = T

					item_data += list(list(
						"id" =             T,
						"name" =           tech_name,
						"level" =          temp_tech[T],
					))

				// This calculates how much research points we missed because we already researched items with such orig_tech levels
				var/research_value = files.experiments.get_object_research_value(linked_destroy.loaded_item, ignoreRepeat = TRUE)
				var/tech_points_mod = research_value
				if(research_value)
					tech_points_mod = files.experiments.get_object_research_value(linked_destroy.loaded_item) / research_value

				var/list/destroy_list = list(
					"has_item" =              TRUE,
					"item_name" =             linked_destroy.loaded_item.name,
					"item_tech_points" =      files.experiments.get_object_research_value(linked_destroy.loaded_item),
					"item_tech_mod" =         round(tech_points_mod*100),
				)
				destroy_list["tech_data"] = item_data

				data["destroy_data"] = destroy_list
			else
				var/list/destroy_list = list(
					"has_item" =             FALSE,
				)
				data["destroy_data"] = destroy_list

	if(screen == "protolathe")
		if(linked_lathe)
			data["search_text"] = search_text
			data["protolathe_data"] = get_protolathe_data()
			data["all_categories"] = files.design_categories_protolathe
			if(search_text)
				data["all_categories"] = list("Search Results") + data["all_categories"]

			if((!selected_protolathe_category || !(selected_protolathe_category in data["all_categories"])) && files.design_categories_protolathe.len)
				selected_protolathe_category = files.design_categories_protolathe[1]

			if(selected_protolathe_category)
				data["selected_category"] = selected_protolathe_category
				data["possible_designs"] = get_possible_designs_data(PROTOLATHE, selected_protolathe_category)

			var/list/queue_list = list()
			queue_list["can_restart"] = (linked_lathe.queue.len && !linked_lathe.busy)
			queue_list["queue"] = list()
			for(var/datum/rnd_queue_design/RNDD in linked_lathe.queue)
				queue_list["queue"] += RNDD.name
			data["queue_data"] = queue_list

	if(screen == "circuit_imprinter")
		if(linked_imprinter)
			data["search_text"] = search_text
			data["imprinter_data"] = get_imprinter_data()
			data["all_categories"] = files.design_categories_imprinter
			if(search_text)
				data["all_categories"] = list("Search Results") + data["all_categories"]

			if((!selected_imprinter_category || !(selected_imprinter_category in data["all_categories"])) && files.design_categories_imprinter.len)
				selected_imprinter_category = files.design_categories_imprinter[1]

			if(selected_imprinter_category)
				data["selected_category"] = selected_imprinter_category
				data["possible_designs"] = get_possible_designs_data(IMPRINTER, selected_imprinter_category)

			var/list/queue_list = list()
			queue_list["can_restart"] = (linked_imprinter.queue.len && !linked_imprinter.busy)
			queue_list["queue"] = list()
			for(var/datum/rnd_queue_design/RNDD in linked_imprinter.queue)
				queue_list["queue"] += RNDD.name
			data["queue_data"] = queue_list

	// All the info needed for displaying tech trees
	if(screen == "tech_trees")
		var/list/line_list = list()

		var/list/tech_tree_list = list()
		for(var/tech_tree_id in files.tech_trees)
			var/datum/tech/Tech_Tree = files.tech_trees[tech_tree_id]
			if(!Tech_Tree.shown)
				continue
			var/list/tech_tree_data = list(
				"id" =             Tech_Tree.id,
				"name" =           "[Tech_Tree.name]",
				"shortname" =      "[Tech_Tree.shortname]",
			)
			tech_tree_list += list(tech_tree_data)

		data["tech_trees"] = tech_tree_list

		if(!selected_tech_tree)
			selected_tech_tree = files.all_technologies[1]

		var/list/tech_list = list()
		if(selected_tech_tree && files.all_technologies[selected_tech_tree])
			var/datum/tech/Tech_Tree = files.tech_trees[selected_tech_tree]
			data["tech_tree_name"] = Tech_Tree.name
			data["tech_tree_desc"] = Tech_Tree.desc
			data["tech_tree_level"] = Tech_Tree.level

			for(var/tech_id in files.all_technologies[selected_tech_tree])
				var/datum/technology/Tech = files.all_technologies[selected_tech_tree][tech_id]
				var/list/tech_data = list(
					"id" =             Tech.id,
					"name" =           "[Tech.name]",
					"x" =              round(Tech.x*100),
					"y" =              round(Tech.y*100),
					"icon" =           "[Tech.icon]",
					"isresearched" =   "[files.IsResearched(Tech)]",
					"canresearch" =    "[files.CanResearch(Tech)]",
				)
				tech_list += list(tech_data)

				for(var/req_tech_id in Tech.required_technologies)
					if(files.all_technologies[selected_tech_tree][req_tech_id])
						var/datum/technology/OTech = files.all_technologies[selected_tech_tree][req_tech_id]
						if(OTech.tech_type == Tech.tech_type)
							var/line_x = (min(round(OTech.x*100), round(Tech.x*100)))
							var/line_y = (min(round(OTech.y*100), round(Tech.y*100)))
							var/width = (abs(round(OTech.x*100) - round(Tech.x*100)))
							var/height = (abs(round(OTech.y*100) - round(Tech.y*100)))

							var/istop = FALSE
							if(OTech.y > Tech.y)
								istop = TRUE
							var/isright = FALSE
							if(OTech.x < Tech.x)
								isright = TRUE

							var/list/line_data = list(
								"line_x" =           line_x,
								"line_y" =           line_y,
								"width" =            width,
								"height" =           height,
								"istop" =            istop,
								"isright" =          isright,
							)
							line_list += list(line_data)

		data["techs"] = tech_list
		data["lines"] = line_list
		data["selected_tech_tree"] = selected_tech_tree
		data["research_points"] = files.research_points

		data["selected_technology_id"] = ""
		if(selected_technology)
			var/datum/technology/Tech = files.all_technologies[selected_tech_tree][selected_technology]
			var/list/technology_data = list(
				"name" =           Tech.name,
				"desc" =           Tech.desc,
				"id" =             Tech.id,
				"tech_type" =      Tech.tech_type,
				"cost" =           Tech.cost,
				"reliability_upgrade_cost" = Tech.reliability_upgrade_cost,
				"avg_reliability" = Tech.avg_reliability,
				"isresearched" =   files.IsResearched(Tech),
			)
			data["selected_technology_id"] = Tech.id

			var/list/requirement_list = list()
			for(var/t in Tech.required_tech_levels)
				var/datum/tech/Tech_Tree = files.tech_trees[t]

				var/level = Tech.required_tech_levels[t]
				var/list/req_data = list(
					"text" =           "[Tech_Tree.shortname] level [level]",
					"isgood" =         (Tech_Tree.level >= level)
				)
				requirement_list += list(req_data)
			for(var/t in Tech.required_technologies)
				var/datum/technology/OTech = files.all_technologies[selected_tech_tree][t]

				var/list/req_data = list(
					"text" =           "[OTech.name]",
					"isgood" =         files.IsResearched(OTech)
				)
				requirement_list += list(req_data)
			technology_data["requirements"] = requirement_list

			var/list/unlock_list = list()
			for(var/T in Tech.unlocks_designs)
				var/datum/design/D = files.design_by_id[T]
				var/list/unlock_data = list(
					"text" = "[D.name]"
				)
				unlock_list += list(unlock_data)
			technology_data["unlocks"] = unlock_list

			data["selected_technology"] = technology_data

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "rdconsole.tmpl", "R&D Console", 1000, 700)

		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics R&D Console"
	id = 2
	req_access = list(29)
	can_research = FALSE

/obj/machinery/computer/rdconsole/robotics/atom_init()
	. = ..()
	if(circuit)
		circuit.name = "circuit board (RD Console - Robotics)"
		circuit.build_path = /obj/machinery/computer/rdconsole/robotics

/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"
	id = 1
	can_research = TRUE

/obj/machinery/computer/rdconsole/mining
	name = "Mining R&D Console"
	id = 3
	req_access = list(48)
	can_research = FALSE

/obj/machinery/computer/rdconsole/mining/atom_init()
	. = ..()
	if(circuit)
		circuit.name = "circuit board (RD Console - Mining)"
		circuit.build_path = /obj/machinery/computer/rdconsole/mining
