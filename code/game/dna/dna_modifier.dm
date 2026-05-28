#define DNA_BLOCK_SIZE 3
#define MAX_RAD_DURATION 10
#define MAX_RAD_INTENSITY 20

// Buffer datatype flags.
#define DNA2_BUF_UI 1
#define DNA2_BUF_UE 2
#define DNA2_BUF_SE 4

//list("data" = null, "owner" = null, "label" = null, "type" = null, "ue" = 0),
/datum/dna2/record
	var/datum/dna/dna = null
	var/types = 0
	var/name = "Empty"

	// Stuff for cloners
	var/id = null
	var/implant = null
	var/ckey = null
	var/mind = null
	var/languages = null
	var/list/quirks

/datum/dna2/record/proc/GetData()
	var/list/ser = list("data" = null, "owner" = null, "label" = null, "type" = null, "ue" = 0)
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

/obj/machinery/dna_scannernew/proc/toggle_open(mob/user = usr)
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

	if(do_after(user,(breakout_time*60*10),target = src)) //minutes * 60seconds * 10deciseconds
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
				var/obj/item/organ/internal/brain/B = M
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

				if(occupant.stat == DEAD)
					if(occupant.client) //Ghost in body?
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
	var/radiation_duration = 2.0
	var/radiation_intensity = 1.0
	var/list/datum/dna2/record/buffers[3]
	var/irradiating = FALSE
	var/injector_ready = FALSE	//Quick fix for issue 286 (screwdriver the screen twice to restore injector)	-Pete
	var/obj/machinery/dna_scannernew/connected = null
	var/obj/item/weapon/disk/data/disk = null
	var/selected_menu_key = 1
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 400
	var/waiting_for_user_input = 0 // Fix for #274 (Mash create block injector without answering dialog to make unlimited injectors) - N3X
	var/irradiate_start = 0
	var/irradiate_duration = 0
	var/irradiate_lock_state = FALSE
	var/irradiate_timer_id = null

	required_skills = list(/datum/skill/research = SKILL_LEVEL_TRAINED, /datum/skill/medical = SKILL_LEVEL_TRAINED)


/obj/machinery/computer/scan_consolenew/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/disk/data)) //INSERT SOME diskS
		if(!disk)
			if(!do_skill_checks(user))
				return
			user.drop_from_inventory(I, src)
			disk = I
			to_chat(user, "<span class='notice'>You insert [I].</span>")
			SStgui.update_uis(src)
		return FALSE
	return ..()

/obj/machinery/computer/scan_consolenew/atom_init()
	..()
	for(var/i = 0; i < 3; i++)
		buffers[i+1] = new /datum/dna2/record
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/scan_consolenew/atom_init_late()
	connected = locate(/obj/machinery/dna_scannernew) in range(4, src)
	if(!isnull(connected))
		VARSET_IN(src, injector_ready, TRUE, 250)

/obj/machinery/computer/scan_consolenew/can_interact_with(mob/user)
	if(!isnull(connected) && user == connected.occupant)
		return FALSE
	return ..()

/obj/machinery/computer/scan_consolenew/proc/all_dna_blocks(list/buffer)
	var/list/arr = list()
	for(var/i = 1, i <= buffer.len, i++)
		arr += "[i]: [EncodeDNABlock(buffer[i])]"
	return arr

/obj/machinery/computer/scan_consolenew/proc/start_irradiate(duration, action_type, buffer_id = 0)
	if(!(action_type in list("pulseRadiation", "pulseUIRadiation", "pulseSERadiation", "transfer")))
		audible_message("<span class='warning'>Something went wrong during irradiation process! Please contact technical support.</span>")
		return

	irradiating = TRUE
	irradiate_start = world.time
	irradiate_duration = duration
	irradiate_lock_state = connected?.locked || FALSE
	connected?.locked = TRUE

	irradiate_timer_id = addtimer(
		CALLBACK(src, .proc/finish_irradiate, action_type, buffer_id),
		duration SECONDS,
		TIMER_STOPPABLE
	)

/obj/machinery/computer/scan_consolenew/proc/finish_irradiate(action_type, buffer_id = 0)
	irradiate_timer_id = null

	if(QDELETED(src))
		return

	irradiating = FALSE

	if(!connected || QDELETED(connected) || !connected.is_operational())
		SStgui.update_uis(src)
		return

	connected.locked = irradiate_lock_state

	switch(action_type)
		if("pulseRadiation")
			if(!connected.occupant)
				SStgui.update_uis(src)
				return

			if(prob(95))
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

		if("pulseUIRadiation")
			if(!connected.occupant)
				SStgui.update_uis(src)
				return

			var/block = connected.occupant.dna.GetUISubBlock(selected_ui_block, selected_ui_subblock)

			if(prob(80 + connected.precision_coeff + radiation_duration / 2))
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

		if("pulseSERadiation")
			if(!connected.occupant)
				SStgui.update_uis(src)
				return

			var/block = connected.occupant.dna.GetSESubBlock(selected_se_block, selected_se_subblock)

			if(prob(80 + connected.precision_coeff + radiation_duration / 2))
				var/real_SE_block = selected_se_block
				block = miniscramble(block, radiation_intensity, radiation_duration)
				if(prob(20 - connected.scan_level ** 2))
					if(selected_se_block > 1 && selected_se_block < DNA_SE_LENGTH / 2)
						real_SE_block++
					else if(selected_se_block > DNA_SE_LENGTH / 2 && selected_se_block < DNA_SE_LENGTH)
						real_SE_block--

					connected.occupant.dna.SetSESubBlock(real_SE_block,selected_se_subblock,block)
					connected.occupant.radiation += (radiation_intensity + radiation_duration) / connected.damage_coeff
					domutcheck(connected.occupant, connected, block != null, 1)
				else
					connected.occupant.radiation += radiation_intensity * 2 + radiation_duration + connected.precision_coeff
					if	(prob(80 - radiation_duration))
						randmutb(connected.occupant)
						domutcheck(connected.occupant, connected, block != null, 1)
					else
						randmuti(connected.occupant)
						connected.occupant.UpdateAppearance()

		if("transfer")
			if(!connected.occupant || (NOCLONE in connected.occupant.mutations) || !connected.occupant.dna)
				SStgui.update_uis(src)
				return

			var/datum/dna2/record/buf = buffers[buffer_id]

			if((buf.types & DNA2_BUF_UI))
				if((buf.types & DNA2_BUF_UE))
					connected.occupant.real_name = buf.dna.real_name
					connected.occupant.name = buf.dna.real_name
				connected.occupant.UpdateAppearance(buf.dna.UI.Copy())
			else if(buf.types & DNA2_BUF_SE)
				connected.occupant.dna.SE = buf.dna.SE.Copy()
				connected.occupant.dna.UpdateSE()
				domutcheck(connected.occupant,connected)
			connected.occupant.radiation += rand(15 / (connected.damage_coeff), 40 / (connected.damage_coeff))

	SStgui.update_uis(src)

/obj/machinery/computer/scan_consolenew/Destroy()
	if(irradiate_timer_id)
		deltimer(irradiate_timer_id)
		irradiate_timer_id = null
		irradiating = FALSE
	return ..()

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
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DnaModifier", name)
		ui.open()

/obj/machinery/computer/scan_consolenew/tgui_static_data(mob/user)
	var/list/data = list()
	data["maxRadiationIntensity"] = MAX_RAD_INTENSITY
	data["maxRadiationDuration"] = MAX_RAD_DURATION
	data["dnaBlockSize"] = DNA_BLOCK_SIZE
	return data

/obj/machinery/computer/scan_consolenew/tgui_data(mob/user)
	var/list/data = list()
	data["selectedMenuKey"] = selected_menu_key
	if(irradiate_timer_id)
		var/end_time = irradiate_start + irradiate_duration SECONDS
		data["irradiating"] = max(0, round((end_time - world.time) / 10))
	else
		data["irradiating"] = 0
	data["hasScanner"] = connected && connected.is_operational()
	if(!data["hasScanner"])
		return data		//No point gathering more data if it has no operational scanner

	data["opened"] = connected.open
	data["locked"] = connected.locked
	data["hasOccupant"] = !isnull(connected.occupant)

	data["isInjectorReady"] = injector_ready

	data["hasDisk"] = !isnull(disk)

	data["disk"] = (!disk || !disk.buf) ? null : disk.buf.GetData()

	var/list/new_buffers = list()
	for(var/datum/dna2/record/buf in buffers)
		new_buffers += list(buf.GetData())
	data["buffers"] = new_buffers

	data["radiationIntensity"] = radiation_intensity
	data["radiationDuration"] = radiation_duration

	data["selectedUIBlock"] = selected_ui_block
	data["selectedUISubBlock"] = selected_ui_subblock
	data["selectedSEBlock"] = selected_se_block
	data["selectedSESubBlock"] = selected_se_subblock

	data["selectedUITarget"] = selected_ui_target

	data["occupant"] = null
	if(connected.occupant?.dna)
		data["occupant"] = list(
			"name" = connected.occupant.name,
			"stat" = connected.occupant.stat,
			"isViableSubject" = connected.occupant.dna && !(NOCLONE in connected.occupant.mutations) && connected.scan_level != 3,
			"health" = connected.occupant.health,
			"maxHealth" = connected.occupant.maxHealth,
			"minHealth" = config.health_threshold_dead,
			"uniqueEnzymes" = connected.occupant.dna.unique_enzymes,
			"uniqueIdentity" = connected.occupant.dna.uni_identity,
			"structuralEnzymes" = connected.occupant.dna.struc_enzymes,
			"radiationLevel" = connected.occupant.radiation
		)

	data["beaker"] = null
	if(connected.beaker)
		data["beaker"] = list(
			"label" = connected.beaker.label_text,
			"volume" = max(connected.beaker.reagents?.total_volume, 0),
			"maxVolume" = connected.beaker.volume
		)
	data["injectAmount"] = connected.inject_amount

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
		if("selectMenuKey")
			selected_menu_key = sanitize_integer(params["menu"], 1, 4, selected_menu_key)

		if("toggleLock")
			if(connected)
				connected.locked = !connected.locked
		if("toggleOpen")
			if(connected)
				connected.toggle_open(usr)

		if("pulseRadiation")
			if(!connected.occupant)
				return FALSE
			start_irradiate(radiation_duration, "pulseRadiation")

		if("radiationDuration")
			radiation_duration = clamp(params["duration"], 1, MAX_RAD_DURATION)

		if("radiationIntensity")
			radiation_intensity = clamp(params["intensity"], 1, MAX_RAD_INTENSITY)

	 ////////////////////////////////////////////////////////

		if("changeUITarget")
			selected_ui_target = clamp(text2num(params["target"]), 0, 15)

		if("selectUIBlock") // This chunk of code updates selected block / sub-block based on click
			var/select_block = text2num(params["block"])
			var/select_subblock = text2num(params["subblock"])
			if((select_block <= DNA_UI_LENGTH) && (select_block >= 1))
				selected_ui_block = select_block
			if((select_subblock <= DNA_BLOCK_SIZE) && (select_subblock >= 1))
				selected_ui_subblock = select_subblock

		if("pulseUIRadiation")
			if(!connected.occupant)
				return FALSE

			start_irradiate(radiation_duration, "pulseUIRadiation")

		////////////////////////////////////////////////////////

		if("injectRejuvenators")
			if(!connected.occupant)
				return FALSE
			if(!connected.beaker)
				return FALSE

			connected.beaker.reagents.trans_to(connected.occupant, connected.inject_amount)
			connected.beaker.reagents.reaction(connected.occupant)

		if("injectAmount")
			connected.inject_amount = min(connected?.beaker.volume, params["amount"])
		////////////////////////////////////////////////////////

		if("selectSEBlock") // This chunk of code updates selected block / sub-block based on click (se stands for strutural enzymes)
			var/select_block = text2num(params["block"])
			var/select_subblock = text2num(params["subblock"])
			if((select_block <= DNA_SE_LENGTH) && (select_block >= 1))
				selected_se_block = select_block
			if((select_subblock <= DNA_BLOCK_SIZE) && (select_subblock >= 1))
				selected_se_subblock = select_subblock

		if("pulseSERadiation")
			if(!connected.occupant)
				return FALSE

			start_irradiate(radiation_duration, "pulseSERadiation")

		if("ejectBeaker")
			if(connected.beaker)
				var/obj/item/weapon/reagent_containers/glass/B = connected.beaker
				B.forceMove(connected.loc)
				connected.beaker = null

		if("wipeDisk")
			if(!disk || disk.read_only)
				return FALSE
			disk.buf = null

		if("ejectDisk")
			if(!disk)
				return FALSE
			disk.forceMove(get_turf(src))
			disk = null

		// Transfer Buffer Management
		if("bufferOption")
			var/bufferOption = params["bufferOption"]
			if(!params["bufferId"])
				return FALSE

			var/bufferId = text2num(params["bufferId"])

			if(bufferId < 1 || bufferId > 3)
				return FALSE // Not a valid buffer id
			else if(bufferOption == "loadFrom")
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
						if(connected.occupant?.dna)
							var/datum/dna2/record/databuf = new
							databuf.types = DNA2_BUF_UI
							databuf.dna = connected.occupant.dna.Clone()
							if(ishuman(connected.occupant))
								databuf.dna.real_name = connected.occupant.name
							databuf.name = "Unique identifier"
							buffers[bufferId] = databuf
					if("Subject U.I. + U.E.")
						if(connected.occupant?.dna)
							var/datum/dna2/record/databuf = new
							databuf.types = DNA2_BUF_UI|DNA2_BUF_UE
							databuf.dna = connected.occupant.dna.Clone()
							if(ishuman(connected.occupant))
								databuf.dna.real_name = connected.occupant.name
							databuf.name = "Unique identifier + unique enzymes"
							buffers[bufferId] = databuf
					if("Subject S.E.")
						if(connected.occupant?.dna)
							var/datum/dna2/record/databuf = new
							databuf.types = DNA2_BUF_SE
							databuf.dna = connected.occupant.dna.Clone()
							if(ishuman(connected.occupant))
								databuf.dna.real_name = connected.occupant.name
							databuf.name = "Structural enzymes"
							buffers[bufferId] = databuf
					if("Disk")
						if(!disk || !disk.buf)
							return FALSE
						buffers[bufferId] = disk.buf

			else if(bufferOption == "clear")
				buffers[bufferId] = new /datum/dna2/record()

			else if(bufferOption == "changeLabel")
				var/datum/dna2/record/buf = buffers[bufferId]
				var/text = sanitize_safe(input(usr, "New Label:", "Edit Label", input_default(buf.name)) as text|null, MAX_NAME_LEN)
				buf.name = text
				buffers[bufferId] = buf

			else if(bufferOption == "transfer")
				if(!connected.occupant || (NOCLONE in connected.occupant.mutations) || !connected.occupant.dna)
					return FALSE

				start_irradiate(2, "transfer", bufferId)

			else if(bufferOption == "createInjector")
				if(injector_ready && !waiting_for_user_input)
					var/success = FALSE
					var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
					var/datum/dna2/record/buf = buffers[bufferId]
					if(params["createBlockInjector"])
						waiting_for_user_input = TRUE
						var/list/selectedbuf
						if(buf.types & DNA2_BUF_SE)
							selectedbuf = buf.dna.SE
						else
							selectedbuf = buf.dna.UI
						var/blk = tgui_input_list(ui.user, "Select block", "Block injector", all_dna_blocks(selectedbuf))
						success = setInjectorBlock(I,blk,buf)
					else
						I.buf = buf
						success = TRUE
					waiting_for_user_input = FALSE
					if(success)
						I.forceMove(loc)
						I.name += " ([buf.name])"
						audible_message("<span class='notice'>Injector created.</span>")
						injector_ready = FALSE
						VARSET_IN(src, injector_ready, TRUE, 300)
					else
						audible_message("<span class='warning'>Injector creation was aborted due to unknown error!</span>")
				else
					audible_message("<span class='warning'>DNA replicator is not ready yet!</span>")

			else if(bufferOption == "saveDisk")
				if((isnull(disk)) || (disk.read_only))
					audible_message("<span class='warning'>Invalid disk! Check if it's in read only mode or try another one.</span>")
					return FALSE

				var/datum/dna2/record/buf = buffers[bufferId]
				disk.buf = buf
				disk.name = "data disk - '[buf.dna.real_name]'"
				audible_message("<span class='notice'>Data saved.</span>")
	return TRUE

/////////////////////////// DNA MACHINES

#undef DNA_BLOCK_SIZE
#undef MAX_RAD_DURATION
#undef MAX_RAD_INTENSITY
