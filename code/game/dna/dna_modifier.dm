#define DNA_BLOCK_SIZE 3

// Buffer datatype flags.
#define DNA2_BUF_UI 1
#define DNA2_BUF_UE 2
#define DNA2_BUF_SE 4

//list("data" = null, "owner" = null, "label" = null, "type" = null, "ue" = 0),
/datum/dna2/record
	var/datum/dna/dna = null
	var/types=0
	var/name="Empty"

	// Stuff for cloners
	var/id=null
	var/implant=null
	var/ckey=null
	var/mind=null
	var/languages=null
	var/list/quirks

/datum/dna2/record/proc/GetData()
	var/list/ser=list("data" = null, "owner" = null, "label" = null, "type" = null, "ue" = 0)
	if(dna)
		ser["ue"] = (types & DNA2_BUF_UE) == DNA2_BUF_UE
		if(types & DNA2_BUF_SE)
			ser["data"] = dna.SE
		else
			ser["data"] = dna.UI
		ser["owner"] = dna.real_name
		ser["label"] = name
		if(types & DNA2_BUF_UI)
			ser["type"] = "ui"
		else
			ser["type"] = "se"
	return ser

/////////////////////////// DNA MACHINES
/obj/machinery/dna_scannernew
	name = "DNA modifier"
	desc = "It scans DNA structures."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "scanner"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 300
	var/damage_coeff
	var/scan_level
	var/precision_coeff
	var/locked = 0
	var/open = 0
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/inject_amount = 5

/obj/machinery/dna_scannernew/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/clonescanner(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	RefreshParts()

/obj/machinery/dna_scannernew/RefreshParts()
	..()

	scan_level = 0
	damage_coeff = 0
	precision_coeff = 0
	for(var/obj/item/weapon/stock_parts/P in component_parts)
		if(istype(P, /obj/item/weapon/stock_parts/scanning_module))
			scan_level += P.rating
		else if(istype(P, /obj/item/weapon/stock_parts/manipulator))
			precision_coeff = P.rating ** 2
		else if(istype(P, /obj/item/weapon/stock_parts/micro_laser))
			damage_coeff = P.rating ** 2

/obj/machinery/dna_scannernew/proc/toggle_open(mob/user=usr)
	if(!user)
		return
	if(open)
		close(user)
	else
		open(user)

/obj/machinery/dna_scannernew/container_resist()
	var/mob/living/user = usr
	var/breakout_time = 2
	if(open || !locked)	//Open and unlocked, no need to escape
		open = 1
		return
	user.SetNextMove(100)
	user.last_special = world.time + 100
	to_chat(user, "<span class='notice'>You lean on the back of [src] and start pushing the door open. (this will take about [breakout_time] minutes.)</span>")
	user.visible_message("<span class='warning'>You hear a metallic creaking from [src]!</span>")

	if(do_after(user,(breakout_time*60*10),target=src)) //minutes * 60seconds * 10deciseconds
		if(!user || user.incapacitated() || user.loc != src || open || !locked)
			return

		locked = 0
		visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>")
		to_chat(user, "<span class='notice'>You successfully break out of [src]!</span>")

		open(user)

/obj/machinery/dna_scannernew/proc/close(mob/user)
	if(open)
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		open = 0
		density = TRUE
		var/atom/movable/occupant_body
		for(var/atom/movable/M in loc)
			if(occupant)
				break
			if(iscarbon(M))
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(H.species.flags[NO_DNA])
						continue
				var/mob/living/carbon/C = M
				occupant = occupant_body = C
				break
			if(isbrain(M))
				var/obj/item/brain/B = M
				occupant = B.brainmob
				occupant_body = B
				break
			if(istype(M, /obj/item/organ/external/head))
				var/obj/item/organ/external/head/H = M
				occupant = H.brainmob
				occupant_body = H
				break
		occupant_body?.forceMove(src)
		occupant?.client?.perspective = EYE_PERSPECTIVE
		occupant?.client?.eye = src
		icon_state = initial(icon_state) + (occupant ? "_occupied" : "")

		// search for ghosts, if the corpse is empty and the scanner is connected to a cloner
		if(occupant)
			if(locate(/obj/machinery/computer/cloning, get_step(src, NORTH)) \
				|| locate(/obj/machinery/computer/cloning, get_step(src, SOUTH)) \
				|| locate(/obj/machinery/computer/cloning, get_step(src, EAST)) \
				|| locate(/obj/machinery/computer/cloning, get_step(src, WEST)))

				if (occupant.stat == DEAD)
					if (occupant.client) //Ghost in body?
						occupant.playsound_local(null, 'sound/machines/chime.ogg', VOL_NOTIFICATIONS, vary = FALSE, frequency = null, ignore_environment = TRUE)	//probably not the best sound but I think it's reasonable
					else
						for(var/mob/dead/observer/ghost in player_list)
							if(ghost.mind == occupant.mind)
								if(ghost.can_reenter_corpse)
									ghost.playsound_local(null, 'sound/machines/chime.ogg', VOL_NOTIFICATIONS, vary = FALSE, frequency = null, ignore_environment = TRUE)	//probably not the best sound but I think it's reasonable
									var/answer = tgui_alert(ghost, "Do you want to return to corpse for cloning?", "Cloning", list("Yes","No"))
									if(answer == "Yes")
										ghost.reenter_corpse()

								break

/obj/machinery/dna_scannernew/proc/open(mob/user)
	if(!open)
		if(panel_open)
			to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
			return
		if(locked)
			to_chat(user, "<span class='notice'>The bolts are locked down, securing the door shut.</span>")
			return
		var/turf/T = get_turf(src)
		if(T)
			open = 1
			density = FALSE
			T.contents += (contents - beaker)
			if(occupant)
				if(occupant.client)
					occupant.client.eye = occupant
					occupant.client.perspective = MOB_PERSPECTIVE
				occupant = null
			icon_state = "[initial(icon_state)]_open"

/obj/machinery/dna_scannernew/relaymove(mob/user)
	if(user.incapacitated())
		return
	open(user)
	return

/obj/machinery/dna_scannernew/attackby(obj/item/I, mob/user)
	if(!occupant && default_deconstruction_screwdriver(user, "[initial(icon_state)]_open", "[initial(icon_state)]", I))
		return FALSE

	if(exchange_parts(user, I))
		return FALSE

	if(isprying(I))
		if(panel_open)
			for(var/obj/O in contents) // in case there is something in the scanner
				O.forceMove(loc)
			default_deconstruction_crowbar(I)
		return FALSE

	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		var/obj/item/weapon/reagent_containers/glass/B = I
		if(beaker)
			to_chat(user, "<span class='red'>A beaker is already loaded into the machine.</span>")
			return FALSE

		beaker = B
		user.drop_from_inventory(B, src)
		inject_amount = min(B.volume, inject_amount)
		user.visible_message("[user] adds \a [B] to \the [src]!", "You add \a [B] to \the [src]!")
		return FALSE

	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		user.SetNextMove(CLICK_CD_INTERACT)
		if(!ismob(G.affecting))
			return FALSE

		if(!open)
			to_chat(user, "<span class='notice'>Open the scanner first.</span>")
			return FALSE

		var/mob/M = G.affecting
		M.forceMove(loc)
		qdel(G)
		return FALSE

	return ..()

/obj/machinery/dna_scannernew/attack_hand(mob/user)
	if(..())
		return
	toggle_open(user)

/obj/machinery/dna_scannernew/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(75))
				return
	for(var/atom/movable/A as anything in src)
		A.forceMove(loc)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += A
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += A
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += A
	qdel(src)

/obj/machinery/dna_scannernew/deconstruct(disassembled)
	for(var/atom/movable/A as anything in src)
		A.forceMove(loc)
	..()

//DNA COMPUTER
/obj/machinery/computer/scan_consolenew
	name = "DNA Modifier Access Console"
	desc = "Scand DNA."
	icon = 'icons/obj/computer.dmi'
	icon_state = "dna"
	state_broken_preset = "crewb"
	state_nopower_preset = "crew0"
	light_color = "#315ab4"
	density = TRUE
	circuit = /obj/item/weapon/circuitboard/scan_consolenew
	var/selected_ui_block = 1.0
	var/selected_ui_subblock = 1.0
	var/selected_se_block = 1.0
	var/selected_se_subblock = 1.0
	var/selected_ui_target = 1
	var/selected_ui_target_hex = 1
	var/radiation_duration = 2.0
	var/radiation_intensity = 1.0
	var/list/datum/dna2/record/buffers[3]
	var/irradiating = 0
	var/injector_ready = 0	//Quick fix for issue 286 (screwdriver the screen twice to restore injector)	-Pete
	var/obj/machinery/dna_scannernew/connected = null
	var/obj/item/weapon/disk/data/disk = null
	var/selected_menu_key = 1
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 400
	var/waiting_for_user_input=0 // Fix for #274 (Mash create block injector without answering dialog to make unlimited injectors) - N3X

	required_skills = list(/datum/skill/research = SKILL_LEVEL_TRAINED, /datum/skill/medical = SKILL_LEVEL_TRAINED)


/obj/machinery/computer/scan_consolenew/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/disk/data)) //INSERT SOME diskS
		if (!disk)
			if(!do_skill_checks(user))
				return
			user.drop_from_inventory(I, src)
			disk = I
			to_chat(user, "<span class='notice'>You insert [I].</span>")
			SStgui.try_update_ui(user, src)
		return FALSE
	return ..()

/obj/machinery/computer/scan_consolenew/atom_init()
	..()
	for(var/i=0;i<3;i++)
		buffers[i+1]=new /datum/dna2/record
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/scan_consolenew/atom_init_late()
	connected = locate(/obj/machinery/dna_scannernew) in range(4, src)
	if(!isnull(connected))
		spawn(250)
		injector_ready = 1

/obj/machinery/computer/scan_consolenew/proc/all_dna_blocks(list/buffer)
	var/list/arr = list()
	for(var/i = 1, i <= buffer.len, i++)
		arr += "[i]: [EncodeDNABlock(buffer[i])]"
	return arr

/obj/machinery/computer/scan_consolenew/proc/setInjectorBlock(obj/item/weapon/dnainjector/I, blk, datum/dna2/record/buffer)
	var/pos = findtext(blk,":")
	if(!pos)
		return FALSE
	var/id = text2num(copytext(blk,1,pos))
	if(!id)
		return FALSE
	I.block = id
	I.buf = buffer
	return TRUE

/obj/machinery/computer/scan_consolenew/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	tgui_interact(user)

/obj/machinery/computer/scan_consolenew/tgui_interact(mob/user, datum/tgui/ui)
	if(connected && connected.is_operational())
		if(user == connected.occupant)
			return

		ui = SStgui.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "DnaModifier", name)
			ui.open()
	else
		to_chat(user, "<span class='warning'>Error: No scanner detected</span>")

/obj/machinery/computer/scan_consolenew/tgui_data(mob/user)
	var/list/data = list()
	data["selectedMenuKey"] = selected_menu_key
	data["opened"] = connected.open
	data["locked"] = connected.locked
	data["hasOccupant"] = !isnull(connected.occupant)

	data["isInjectorReady"] = injector_ready

	data["hasDisk"] = !isnull(disk)

	var/diskData[0]
	if (!disk || !disk.buf)
		diskData["data"] = null
		diskData["owner"] = null
		diskData["label"] = null
		diskData["type"] = null
		diskData["ue"] = null
	else
		diskData = disk.buf.GetData()
	data["disk"] = diskData

	var/list/new_buffers = list()
	for(var/datum/dna2/record/buf in buffers)
		new_buffers += list(buf.GetData())
	data["buffers"]=new_buffers

	data["radiationIntensity"] = radiation_intensity
	data["radiationDuration"] = radiation_duration
	data["irradiating"] = irradiating

	data["dnaBlockSize"] = DNA_BLOCK_SIZE
	data["selectedUIBlock"] = selected_ui_block
	data["selectedUISubBlock"] = selected_ui_subblock
	data["selectedSEBlock"] = selected_se_block
	data["selectedSESubBlock"] = selected_se_subblock
	data["selectedUITarget"] = selected_ui_target
	data["selectedUITargetHex"] = selected_ui_target_hex

	var/occupantData[0]
	if (!connected.occupant || !connected.occupant.dna)
		occupantData["name"] = null
		occupantData["stat"] = null
		occupantData["isViableSubject"] = null
		occupantData["health"] = null
		occupantData["maxHealth"] = null
		occupantData["minHealth"] = null
		occupantData["uniqueEnzymes"] = null
		occupantData["uniqueIdentity"] = null
		occupantData["structuralEnzymes"] = null
		occupantData["radiationLevel"] = null
	else
		occupantData["name"] = connected.occupant.name
		occupantData["stat"] = connected.occupant.stat
		occupantData["isViableSubject"] = TRUE
		if (!connected.occupant.dna || (NOCLONE in connected.occupant.mutations) || (connected.scan_level == 3))
			occupantData["isViableSubject"] = FALSE
		occupantData["health"] = connected.occupant.health
		occupantData["maxHealth"] = connected.occupant.maxHealth
		occupantData["minHealth"] = config.health_threshold_dead
		occupantData["uniqueEnzymes"] = connected.occupant.dna.unique_enzymes
		occupantData["uniqueIdentity"] = connected.occupant.dna.uni_identity
		occupantData["structuralEnzymes"] = connected.occupant.dna.struc_enzymes
		occupantData["radiationLevel"] = connected.occupant.radiation
	data["occupant"] = occupantData;

	data["isBeakerLoaded"] = connected.beaker ? TRUE : FALSE
	data["beakerLabel"] = null
	data["beakerVolume"] = 0
	data["injectAmount"] = connected.inject_amount
	if(connected.beaker)
		data["beakerLabel"] = connected.beaker.label_text
		data["beakerMaxVolume"] = connected.beaker.volume
		if (connected.beaker.reagents && connected.beaker.reagents.reagent_list.len)
			for(var/datum/reagent/R in connected.beaker.reagents.reagent_list)
				data["beakerVolume"] += R.volume

	return data

/obj/machinery/computer/scan_consolenew/tgui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	if(!src || !connected)
		return FALSE // don't update uis
	else if(irradiating) // Make sure that it isn't already irradiating someone...
		return FALSE // don't update uis

	switch(action)
		if ("selectMenuKey")
			selected_menu_key = params["menu"]

		if ("toggleLock")
			if(connected)
				connected.locked = !connected.locked
		if ("toggleOpen")
			if(connected)
				connected.toggle_open(usr)

		if ("pulseRadiation")
			irradiating = radiation_duration
			var/lock_state = connected.locked
			connected.locked = TRUE//lock it
			SStgui.try_update_ui(ui.user, src, ui) // update all UIs attached to src

			sleep(radiation_duration SECONDS)

			irradiating = 0

			if (!connected.occupant)
				return

			if (prob(95))
				if(prob(75))
					randmutb(connected.occupant)
				else
					randmuti(connected.occupant)
			else
				if(prob(95))
					randmutg(connected.occupant)
				else
					randmuti(connected.occupant)

			connected.occupant.radiation += ((radiation_intensity * 3) + radiation_duration * 3)
			connected.locked = lock_state
//TODO: defines and export to tgui data
		if ("radiationDuration")
			radiation_duration = text2num(params["duration"])

		if ("radiationIntensity")
			radiation_intensity = params["intensity"]

	 ////////////////////////////////////////////////////////

		if ("changeUITarget")
			selected_ui_target = text2num(params["target"])
			if (selected_ui_target < 16 && selected_ui_target >= 0)
				switch(selected_ui_target)
					if(10)
						selected_ui_target_hex = "A"
					if(11)
						selected_ui_target_hex = "B"
					if(12)
						selected_ui_target_hex = "C"
					if(13)
						selected_ui_target_hex = "D"
					if(14)
						selected_ui_target_hex = "E"
					if(15)
						selected_ui_target_hex = "F"
					else
						selected_ui_target_hex = selected_ui_target
			else
				selected_ui_target = 0
				selected_ui_target_hex = 0

		if ("selectUIBlock") // This chunk of code updates selected block / sub-block based on click
			var/select_block = text2num(params["block"])
			var/select_subblock = text2num(params["subblock"])
			if ((select_block <= DNA_UI_LENGTH) && (select_block >= 1))
				selected_ui_block = select_block
			if ((select_subblock <= DNA_BLOCK_SIZE) && (select_subblock >= 1))
				selected_ui_subblock = select_subblock

		if ("pulseUIRadiation")
			if(!connected.occupant)
				return FALSE
			var/block = connected.occupant.dna.GetUISubBlock(selected_ui_block, selected_ui_subblock)

			irradiating = radiation_duration
			var/lock_state = connected.locked
			connected.locked = TRUE//lock it
			SStgui.try_update_ui(ui.user, src, ui) // update all UIs attached to src

			sleep(radiation_duration SECONDS) // sleep for radiation_duration seconds

			irradiating = 0

			if (!connected.occupant)
				return

			if (prob(80 + connected.precision_coeff + radiation_duration / 2))
				block = miniscrambletarget(num2text(selected_ui_target), radiation_intensity, radiation_duration)
				connected.occupant.dna.SetUISubBlock(selected_ui_block, selected_ui_subblock, block)
				connected.occupant.UpdateAppearance()
				connected.occupant.radiation += (radiation_intensity + radiation_duration) / connected.damage_coeff
			else
				if	(prob(20 + radiation_intensity))
					randmutb(connected.occupant)
					domutcheck(connected.occupant, connected)
				else
					randmuti(connected.occupant)
					connected.occupant.UpdateAppearance()
				connected.occupant.radiation += radiation_intensity * 2 + radiation_duration + connected.precision_coeff
			connected.locked = lock_state

		////////////////////////////////////////////////////////

		if ("injectRejuvenators")
			if (!connected.occupant)
				return FALSE
			if(!connected.beaker)
				return FALSE

			connected.beaker.reagents.trans_to(connected.occupant, connected.inject_amount)
			connected.beaker.reagents.reaction(connected.occupant)

		if("injectAmount")
			connected.inject_amount = min(connected?.beaker.volume, params["amount"])
		////////////////////////////////////////////////////////

		if ("selectSEBlock") // This chunk of code updates selected block / sub-block based on click (se stands for strutural enzymes)
			var/select_block = text2num(params["block"])
			var/select_subblock = text2num(params["subblock"])
			if ((select_block <= DNA_SE_LENGTH) && (select_block >= 1))
				selected_se_block = select_block
			if ((select_subblock <= DNA_BLOCK_SIZE) && (select_subblock >= 1))
				selected_se_subblock = select_subblock

		if ("pulseSERadiation")
			if(!connected.occupant)
				return FALSE

			var/block = connected.occupant.dna.GetSESubBlock(selected_se_block, selected_se_subblock)

			irradiating = radiation_duration
			var/lock_state = connected.locked
			connected.locked = TRUE //lock it
			SStgui.try_update_ui(ui.user, src, ui) // update all UIs attached to src

			sleep(radiation_duration SECONDS) // sleep for radiation_duration seconds

			irradiating = 0

			if(!connected)
				return FALSE

			if(connected.occupant)
				if (prob(80 + connected.precision_coeff + radiation_duration / 2))
					// FIXME: Find out what these corresponded to and change them to the WHATEVERBLOCK they need to be.
					//if ((selected_se_block != 2 || selected_se_block != 12 || selected_se_block != 8 || selected_se_block || 10) && prob (20))
					var/real_SE_block = selected_se_block
					block = miniscramble(block, radiation_intensity, radiation_duration)
					if(prob(20 - connected.scan_level ** 2))
						if (selected_se_block > 1 && selected_se_block < DNA_SE_LENGTH / 2)
							real_SE_block++
						else if (selected_se_block > DNA_SE_LENGTH / 2 && selected_se_block < DNA_SE_LENGTH)
							real_SE_block--

					//testing("Irradiated SE block [real_SE_block]:[selected_se_subblock] ([original_block] now [block]) [(real_SE_block!=selected_se_block) ? "(SHIFTED)":""]!")
					connected.occupant.dna.SetSESubBlock(real_SE_block,selected_se_subblock,block)
					connected.occupant.radiation += (radiation_intensity + radiation_duration) / connected.damage_coeff
					domutcheck(connected.occupant, connected, block != null, 1)//#Z2
				else
					connected.occupant.radiation += radiation_intensity * 2 + radiation_duration + connected.precision_coeff
					if	(prob(80 - radiation_duration))
						//testing("Random bad mut!")
						randmutb(connected.occupant)
						domutcheck(connected.occupant, connected, block != null, 1)//#Z2
					else
						randmuti(connected.occupant)
						//testing("Random identity mut!")
						connected.occupant.UpdateAppearance()
			connected.locked = lock_state

		if("ejectBeaker")
			if(connected.beaker)
				var/obj/item/weapon/reagent_containers/glass/B = connected.beaker
				B.forceMove(connected.loc)
				connected.beaker = null
				SStgui.try_update_ui(ui.user, src, ui)

		if("wipeDisk")
			if (!disk || disk.read_only)
				return FALSE
			disk.buf = null

		if ("ejectDisk")
			if (!disk)
				return FALSE
			disk.forceMove(get_turf(src))
			disk = null

		// Transfer Buffer Management
		if("bufferOption")
			var/bufferOption = params["bufferOption"]
			if (!params["bufferId"])
				return FALSE

			var/bufferId = text2num(params["bufferId"])

			if (bufferId < 1 || bufferId > 3)
				return FALSE // Not a valid buffer id
			else if (bufferOption == "loadFrom")
				var/list/sources = list()
				var/choice
				if(!isnull(connected.occupant))
					sources += list("Subject U.I.", "Subject U.I. + U.E.", "Subject S.E.")
				if(!isnull(disk) && !isnull(disk.buf))
					sources += "Disk"

				if(sources.len == 0)
					choice = null
				else
					choice = tgui_input_list(ui.user, "Choose DNA source", "Load from...", sources)

				if(isnull(choice))
					return FALSE

				switch(choice)
					if("Subject U.I.")
						if(connected.occupant && connected.occupant.dna)
							var/datum/dna2/record/databuf = new
							databuf.types = DNA2_BUF_UI
							databuf.dna = connected.occupant.dna.Clone()
							if(ishuman(connected.occupant))
								databuf.dna.real_name=connected.occupant.name
							databuf.name = "Unique identifier"
							buffers[bufferId] = databuf
					if("Subject U.I. + U.E.")
						if(connected.occupant && connected.occupant.dna)
							var/datum/dna2/record/databuf = new
							databuf.types = DNA2_BUF_UI|DNA2_BUF_UE
							databuf.dna = connected.occupant.dna.Clone()
							if(ishuman(connected.occupant))
								databuf.dna.real_name=connected.occupant.name
							databuf.name = "Unique identifier + unique enzymes"
							buffers[bufferId] = databuf
					if("Subject S.E.")
						if(connected.occupant && connected.occupant.dna)
							var/datum/dna2/record/databuf = new
							databuf.types = DNA2_BUF_SE
							databuf.dna = connected.occupant.dna.Clone()
							if(ishuman(connected.occupant))
								databuf.dna.real_name=connected.occupant.name
							databuf.name = "Structural enzymes"
							buffers[bufferId] = databuf
					if("Disk")
						if (!disk || !disk.buf)
							return FALSE
						buffers[bufferId] = disk.buf

			else if (bufferOption == "clear")
				buffers[bufferId] = new /datum/dna2/record()

			else if (bufferOption == "changeLabel")
				var/datum/dna2/record/buf = buffers[bufferId]
				var/text = sanitize_safe(input(usr, "New Label:", "Edit Label", input_default(buf.name)) as text|null, MAX_NAME_LEN)
				buf.name = text
				buffers[bufferId] = buf

			else if (bufferOption == "transfer")
				if (!connected.occupant || (NOCLONE in connected.occupant.mutations) || !connected.occupant.dna)
					return FALSE

				irradiating = 2
				var/lock_state = connected.locked
				connected.locked = TRUE//lock it
				SStgui.try_update_ui(ui.user, src, ui) // update all UIs attached to src

				sleep(2 SECONDS)

				irradiating = 0
				connected.locked = lock_state

				var/datum/dna2/record/buf = buffers[bufferId]

				if ((buf.types & DNA2_BUF_UI))
					if ((buf.types & DNA2_BUF_UE))
						connected.occupant.real_name = buf.dna.real_name
						connected.occupant.name = buf.dna.real_name
					connected.occupant.UpdateAppearance(buf.dna.UI.Copy())
				else if (buf.types & DNA2_BUF_SE)
					connected.occupant.dna.SE = buf.dna.SE.Copy()
					connected.occupant.dna.UpdateSE()
					domutcheck(connected.occupant,connected)
				connected.occupant.radiation += rand(15 / (connected.damage_coeff), 40 / connected.damage_coeff)

			else if (bufferOption == "createInjector")
				if (injector_ready && !waiting_for_user_input)
					var/success = FALSE
					var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
					var/datum/dna2/record/buf = buffers[bufferId]
					if(params["createBlockInjector"])
						waiting_for_user_input = TRUE
						var/list/selectedbuf
						if(buf.types & DNA2_BUF_SE)
							selectedbuf=buf.dna.SE
						else
							selectedbuf=buf.dna.UI
						//var/blk = input(usr,"Select Block","Block") as null|anything in all_dna_blocks(selectedbuf)
						var/blk = tgui_input_list(ui.user, "Select block", "Block injector", all_dna_blocks(selectedbuf))
						success = setInjectorBlock(I,blk,buf)
					else
						I.buf = buf
						success = TRUE
					waiting_for_user_input = 0
					if(success)
						I.forceMove(loc)
						I.name += " ([buf.name])"
						//temphtml = "Injector created."
						injector_ready = 0
						spawn(300)
							injector_ready = 1
					//else
						//temphtml = "Error in injector creation."
				//else
					//temphtml = "Replicator not ready yet."

			else if (bufferOption == "saveDisk")
				if ((isnull(disk)) || (disk.read_only))
					//temphtml = "Invalid disk. Please try again."
					return FALSE

				var/datum/dna2/record/buf = buffers[bufferId]
				disk.buf = buf
				disk.name = "data disk - '[buf.dna.real_name]'"
				//temphtml = "Data saved."
	SStgui.update_uis(src)

/////////////////////////// DNA MACHINES
