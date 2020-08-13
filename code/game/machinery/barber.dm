/obj/machinery/color_mixer
	name = "Dye Mixer"
	desc = "It makes the dye look good."
	icon = 'icons/obj/barber.dmi'
	icon_state = "mixer_idle"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 40

	var/list/obj/item/weapon/reagent_containers/glass/beaker/beakers = list()
	var/processing = FALSE
	var/efficiency = 0 // How fast do we do the mixing.

	var/datum/wires/color_mixer/wires

	var/list/tabs = list("menu", "tank_1", "tank_2", "tank_3", "log")
	var/list/tanks = list("output", "tank_1", "tank_2", "tank_3")
	var/menustat = "menu"
	var/chosen_quantity = 1
	var/chosen_color = "#000000"
	var/filling_tank_id = null

	var/disable_notifications = FALSE
	var/list/error_log = list()

/obj/machinery/color_mixer/atom_init(mapload)
	. = ..()
	wires = new(src)

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/color_mixer(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)

	RefreshParts()
	if(mapload)
		beakers["tank_1"] = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
		beakers["tank_1"].reagents.add_reagent("redhairdye", 100)
		beakers["tank_2"] = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
		beakers["tank_2"].reagents.add_reagent("greenhairdye", 100)
		beakers["tank_3"] = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
		beakers["tank_3"].reagents.add_reagent("bluehairdye", 100)
		beakers["output"] = new /obj/item/weapon/reagent_containers/glass/beaker/large(src)

	update_icon()

/obj/machinery/color_mixer/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/color_mixer/RefreshParts()
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		efficiency += M.rating

/obj/machinery/color_mixer/update_icon(beaker_update = TRUE)
	if(stat & NOPOWER || isWireCut(COLOR_MIXER_POWER))
		icon_state = "mixer_no_power"
	else
		icon_state = "mixer_idle"

	if(panel_open)
		icon_state += "_p"
		if(emagged)
			icon_state += "_e"

	if(beaker_update)
		cut_overlays()

		for(var/tank_id in tanks)
			var/obj/item/weapon/reagent_containers/glass/tank = beakers[tank_id]
			if(!tank)
				continue
			if(!tank.reagents.total_volume)
				add_overlay(icon('icons/obj/barber.dmi', "[tank_id]_[filling_tank_id == tank_id ? "open" : "closed"]"))
				continue

			var/fill_perc = round(tank.reagents.total_volume * 100 / tank.reagents.maximum_volume, 25)
			var/tank_color = mix_color_from_reagents(tank.reagents.reagent_list)
			var/is_open = "[filling_tank_id == tank_id ? "open" : "closed"]"

			var/image/I = image('icons/obj/reagentfillings.dmi', "[tank_id]_[fill_perc]")
			var/list/r_g_b = ReadRGB(tank_color)
			I.color = RGB_CONTRAST(r_g_b[1], r_g_b[2], r_g_b[3])
			I.add_overlay(icon('icons/obj/barber.dmi', "[tank_id]_[is_open]"))
			add_overlay(I)

/obj/machinery/color_mixer/proc/isWireCut(wireIndex)
	return wires.is_index_cut(wireIndex)

/obj/machinery/color_mixer/is_operational()
	return ..() && !isWireCut(COLOR_MIXER_POWER)

/obj/machinery/color_mixer/is_operational_topic()
	return ..() && !isWireCut(COLOR_MIXER_POWER)

/obj/machinery/color_mixer/proc/Spray_at(atom/A, quantity)
	var/obj/item/weapon/reagent_containers/glass/B
	for(var/tank in tanks)
		if(beakers[tank])
			B = beakers[tank]
	if(!istype(B))
		return

	var/spray_dist = rand(1, 2)
	var/spray_amount = rand(1, B.reagents.total_volume)
	var/obj/effect/decal/chempuff/D = new(get_turf(src))
	D.create_reagents(spray_amount)
	B.reagents.trans_to(D, spray_amount)
	D.icon += mix_color_from_reagents(D.reagents.reagent_list)

	for(var/i in 1 to spray_dist)
		step_towards(D, A)
		D.reagents.reaction(get_turf(D))
		for(var/atom/T in get_turf(D))
			D.reagents.reaction(T)

			// When spraying against the wall, also react with the wall, but
			// not its contents. BS12
			if(get_dist(D, A) == 1 && A.density)
				D.reagents.reaction(A)
			sleep(2)
		sleep(3)
	qdel(D)

/obj/machinery/color_mixer/proc/err_log(message, type = "ERR")
	if(disable_notifications && type == "NOT")
		return
	if(error_log.len > 64)
		error_log.Cut(1, 2)
	error_log += message

/obj/machinery/color_mixer/proc/mix()
	for(var/tank in tanks)
		var/tank_name = ""
		switch(tank) // I do know that I could set menustat to values below, but for clarity's sake we do this.
			if("tank_1")
				tank_name = "Tank 1"
			if("tank_2")
				tank_name = "Tank 2"
			if("tank_3")
				tank_name = "Tank 3"
			if("menu")
				tank_name = "Output Tank"
		if(!beakers[tank])
			err_log("\[[worldtime2text()]\]<font color='red'>ERR #404</font>(Occured while starting mixing process up)<font color='red'>:</font> [tank_name] not found.")
			visible_message("<span class='notice'>[src] makes a lousy beep.</span>")
			return
		if(tank == "output")
			continue
		if(beakers[tank].reagents.reagent_list.len > 1)
			err_log("\[[worldtime2text()]\]<font color='red'>ERR #403</font>(Occured while starting mixing process up)<font color='red'>:</font> Amount of paint in [tank_name] is more than one.")
			visible_message("<span class='notice'>[src] makes a lousy beep.</span>")
			return
		if(!beakers[tank].reagents.reagent_list.len)
			err_log("\[[worldtime2text()]\]<font color='red'>ERR #401</font>(Occured while starting mixing process up)<font color='red'>:</font> Amount of paint in [tank_name] is equal to zero.")
			visible_message("<span class='notice'>[src] makes a lousy beep.</span>")
			return
		for(var/datum/reagent/R in beakers[tank].reagents.reagent_list)
			if(!istype(R, /datum/reagent/paint/hair_dye))
				err_log("\[[worldtime2text()]\]<font color='red'>ERR #402</font>(Occured while starting mixing process up)<font color='red'>:</font> Reagent in [tank_name] is not paint.")
				visible_message("<span class='notice'>[src] makes a lousy beep.</span>")
				return

	var/tank_1_col = mix_color_from_reagents(beakers["tank_1"].reagents.reagent_list)
	if(tank_1_col == "#000000")
		err_log("\[[worldtime2text()]\]<font color='red'>ERR #501</font>(Occured while analyzing mixing components)<font color='red'>:</font> Paint in Tank 1 is black.")
		visible_message("<span class='notice'>[src] makes a lousy beep.</span>")
		return

	var/tank_2_col = mix_color_from_reagents(beakers["tank_2"].reagents.reagent_list)
	if(tank_2_col == "#000000")
		err_log("\[[worldtime2text()]\]<font color='red'>ERR #501</font>(Occured while analyzing mixing components)<font color='red'>:</font> Paint in Tank 2 is black.")
		visible_message("<span class='notice'>[src] makes a lousy beep.</span>")
		return

	var/tank_3_col = mix_color_from_reagents(beakers["tank_3"].reagents.reagent_list)
	if(tank_3_col == "#000000")
		err_log("\[[worldtime2text()]\]<font color='red'>ERR #501</font>(Occured while analyzing mixing components)<font color='red'>:</font> Paint in Tank 3 is black.")
		visible_message("<span class='notice'>[src] makes a lousy beep.</span>")
		return

	var/list/quan_req = do_mix_color_from_three(chosen_color, chosen_quantity, col_1 = tank_1_col, col_2 = tank_2_col, col_3 = tank_3_col)
	if(!quan_req)
		err_log("\[[worldtime2text()]\]<font color='red'>ERR #503</font>(Occured while analyzing mixing components)<font color='red'>:</font> Mix not possible due to computation error.")
		visible_message("<span class='notice'>[src] makes a lousy beep.</span>")
		return

	for(var/i in 1 to quan_req.len)
		if(beakers["tank_[i]"].reagents.total_volume < quan_req[i])
			err_log("\[[worldtime2text()]\]<font color='red'>ERR #502</font>(Occured while analyzing mixing components)<font color='red'>:</font> Tank [i] does not have enough paint, required amount: [quan_req[i]].")
			visible_message("<span class='notice'>[src] makes a lousy beep.</span>")
			return
		if(quan_req[i] < 0)
			err_log("\[[worldtime2text()]\]<font color='red'>ERR #503</font>(Occured while analyzing mixing components)<font color='red'>:</font> Mix not possible due to computation error.")
			visible_message("<span class='notice'>[src] makes a lousy beep.</span>")
			return

	for(var/i in 1 to quan_req.len)
		beakers["tank_[i]"].reagents.remove_any(quan_req[i])

	icon_state = "mixer_processing"
	sleep(20 * chosen_quantity / efficiency)

	if(!beakers["output"])
		err_log("\[[worldtime2text()]\]<font color='red'>ERR #404</font>(Occured after completed mixing)<font color='red'>:</font> Output Tank not found.")
		visible_message("<span class='notice'>[src] makes a lousy beep.</span>")
		return

	var/r_t = hex2num(copytext(chosen_color, 2, 4))
	var/g_t = hex2num(copytext(chosen_color, 4, 6))
	var/b_t = hex2num(copytext(chosen_color, 6, 8))

	beakers["output"].reagents.add_reagent("customhairdye", chosen_quantity, list("r_color" = r_t,"g_color" = g_t,"b_color" = b_t))
	if(isWireCut(COLOR_MIXER_OUTPUT_SAFETY))
		var/turf/T = get_turf(pick(viewers(2, src)))
		INVOKE_ASYNC(src, .proc/Spray_at, T)

	use_power(50 * chosen_quantity)

	err_log("\[[worldtime2text()]\]<font color='blue'>NOT #201:</font> Mix [color_square(hex = chosen_color)]([chosen_quantity]) created, using [color_square(hex = tank_1_col)]([quan_req[1]]) [color_square(hex = tank_2_col)]([quan_req[2]]) [color_square(hex = tank_3_col)]([quan_req[3]]).", type = "NOT")


/obj/machinery/color_mixer/proc/mix_wrapper()
/*
A proc that does all the animations before mix()-ing.
*/
	if(processing)
		return

	processing = TRUE
	visible_message("<span class='notice'>[src] boops, as it starts up.</span>")
	updateUsrDialog()

	icon_state = "mixer_opening"
	sleep(15)

	mix()
	sleep(15)

	icon_state = "mixer_closing"
	sleep(15)

	update_icon()
	visible_message("<span class='notice'>[src] beeps, as it stops.</span>")
	processing = FALSE
	updateUsrDialog()

/obj/machinery/color_mixer/attack_hand(mob/living/user)
	if(user.a_intent == INTENT_HARM && processing)
		if(emagged)
			to_chat(user, "<span class='warning'>You stick your hand into the machine, and...</span>")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/BP = H.bodyparts_by_name[H.hand ? BP_L_ARM : BP_R_ARM]
				if(BP)
					BP.take_damage(50, 0, 0, "blunt hit")
			else if(isliving(user))
				var/mob/living/L = user
				L.adjustBruteLoss(50)
		else
			to_chat(user, "<span class='notice'>Machine's drum stops spinning to prevent from impact with your hand.</span>")
	else
		if(panel_open && wires.interact(user))
			return
		..()

/obj/machinery/color_mixer/attackby(obj/item/O, mob/user)
	if(processing)
		if(user.a_intent != INTENT_HARM)
			to_chat(user, "<span class='warning'>Doing this while [src] is working would be mighty dangerous!</span>")
			if(prob(10))
				to_chat(user, "<span class='warning'>You feel determined to harm this machine!</span>")
			return
		else
			if(emagged)
				to_chat(user, "<span class='warning'>You stick your hand into the machine, and...</span>")
				if(ishuman(user))
					var/list/turf_base = list()
					for(var/turf/T in view(src, 2))
						turf_base += T
					var/obj/item/I = user.get_active_hand()
					user.throw_item(pick(turf_base), I)
					var/mob/living/carbon/human/H = user
					var/obj/item/organ/external/BP = H.bodyparts_by_name[H.hand ? BP_L_ARM : BP_R_ARM]
					if(BP)
						BP.take_damage(50, 0, 0, "blunt hit")
				else if(isliving(user))
					var/mob/living/L = user
					L.adjustBruteLoss(50)
			else
				to_chat(user, "<span class='notice'>Machine's drum stops spinning to prevent impact with your hand.</span>")
			return

	if(!beakers["output"])
		if(istype(O, /obj/item/weapon/reagent_containers/glass/beaker) && !filling_tank_id)
			user.drop_from_inventory(O, src)
			beakers["output"] = O
			err_log("\[[worldtime2text()]\]<font color='blue'>NOT #103:</font> Output Tank was loaded.", type = "NOT")
			to_chat(user, "<span class='notice'>You put [O] inside [src].</span>")
			updateUsrDialog()
			update_icon()
			return
		else if(isscrewdriver(O))
			panel_open = !panel_open
			update_icon(beaker_update = FALSE)
			updateUsrDialog()
			return
	else if(isscrewdriver(O))
		to_chat(user, "<span class='notice'>You try to open up the panel, but [beakers["output"]] is in the way.</span>")
		return

	if(panel_open)
		if(iswirecutter(O))
			return attack_hand(user)
		else if(ismultitool(O))
			return attack_hand(user)
		else if(istype(O, /obj/item/device/assembly/signaler))
			return attack_hand(user)

	if(exchange_parts(user, O))
		return

	default_deconstruction_crowbar(O)

/obj/machinery/color_mixer/emag_act(mob/user)
	if(emagged)
		return FALSE
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start() //sparks always.
	emagged = TRUE
	update_icon(beaker_update = FALSE)
	return TRUE

/obj/machinery/color_mixer/MouseDrop_T(mob/living/target, mob/user)
	if(!processing)
		return
	if(user.incapacitated() || !istype(target))
		return
	if(target.buckled || !in_range(user, src) || !in_range(user, target))
		return
	if(!user.IsAdvancedToolUser() && target != user)
		return
	if(isessence(user))
		return

	add_fingerprint(user)
	var/target_loc = target.loc
	if(user.is_busy() || !do_after(user, 20, target = user))
		return
	if(target_loc != target.loc)
		return
	if(!processing)
		return

	user.visible_message("<span class='warning'>[user] slams [target] into [src].</span>")
	target.do_attack_animation(src)

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.client)
			C.eye_blurry = max(C.eye_blurry, 3)
			C.eye_blind = max(C.eye_blind, 1)
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			H.lip_style = "spray_face"
			H.lip_color = chosen_color
			H.update_body()

	if(emagged)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
			if(BP)
				BP.take_damage(50, 0, 0, "blunt hit")
		else if(isliving(user))
			var/mob/living/L = user
			L.adjustBruteLoss(50)

/obj/machinery/color_mixer/ui_interact(mob/user)
	if(!is_operational())
		return

	var/dat
	dat += "<div class='statusDisplay'>"
	for(var/tab in tabs)
		if(tab == menustat)
			continue
		var/display = ""
		switch(tab) // I do know that I could set menustat to values below, but for clarity's sake we do this.
			if("tank_1")
				display = "Tank 1 Display."
			if("tank_2")
				display = "Tank 2 Display."
			if("tank_3")
				display = "Tank 3 Display."
			if("menu")
				display = "Main Menu."
			if("log")
				display = "Log Menu."
		dat += "<A href='?src=\ref[src];action=switch_menu;stat=[tab]'>[display]</A>[tabs.Find(tab) < tabs.len ? "<BR>" : ""]"
	dat += "</div><HR>"

	if(menustat == "log")
		dat += "<center>Log Options.</center><HR>"
		dat += "<div class='statusDisplay'>"
		dat += "<A href='?src=\ref[src];action=disable_notif'>[disable_notifications ? "Enable" : "Disable"] notifications.</A>"
		dat += "</div><HR>"

		dat += "<center>Log Entries.</center><HR>"
		if(error_log.len)
			dat += "<div class='statusDisplay'>"
			for(var/error in 1 to error_log.len)
				dat += "<A href='?src=\ref[src];action=clear_log;entry=[error]'><font color='red'>X</font></A>[error_log[error]]<BR>"
			dat += "</div><BR>"
		else
			dat += "<div class='statusDisplay'><b>Log</b> <font color='red'>is empty.</font></div>"

	else
		var/tank_name = ""
		var/tank_id = menustat
		var/response_wire = 0
		switch(menustat) // I do know that I could set menustat to values below, but for clarity's sake we do this.
			if("tank_1")
				tank_name = "Tank 1"
				response_wire = COLOR_MIXER_TANK_1
			if("tank_2")
				tank_name = "Tank 2"
				response_wire = COLOR_MIXER_TANK_2
			if("tank_3")
				tank_name = "Tank 3"
				response_wire = COLOR_MIXER_TANK_3
			if("menu")
				tank_name = "Output Tank"
				tank_id = "output"
				response_wire = COLOR_MIXER_TANK_OUTPUT
		dat += "<center>Status of <b>[tank_name]</b></center><HR>"
		dat += "<div class='statusDisplay'>"
		if(isWireCut(response_wire))
			dat += "<font color='red'>Status unavailable.</font>"
		else
			if(beakers[tank_id])
				var/tank_color = mix_color_from_reagents(beakers[tank_id].reagents.reagent_list)
				dat += "[(tank_id != "output" && tank_color == "#000000") || (tank_id == "output" && tank_color) ? "<font color='red'>Paint color</font>" : "Paint color"]: [color_square(hex = tank_color)]<BR>"
				dat += "[(tank_id != "output" && beakers[tank_id].reagents.total_volume < 10) || (tank_id == "output" && beakers[tank_id].reagents.total_volume > 0) ? "<font color='red'>Paint quantity</font>" : "Paint quantity"]: [beakers[tank_id].reagents.total_volume]"
			else
				dat += "<b>[tank_name]</b> <font color='red'>is not loaded into [src].</font><BR>"
		dat += "</div><HR>"

		dat += "<center>Options of <b>[tank_name]</b></center><HR>"
		if(processing)
			dat += "<div class='statusDisplay'><font color='red'>[src] is currently processing and can not give options for</font> <b>[tank_name]</b><font color='red'>.</font></div>"
		else
			dat += "<div class='statusDisplay'>"
			if(beakers[tank_id])
				if(tank_id == "output")
					dat += "<A href='?src=\ref[src];action=choose_color'>Color to mix:</A> [color_square(hex = chosen_color)]<BR>"
					dat += "<A href='?src=\ref[src];action=choose_quantity'>Quantity to create:</A> [chosen_quantity]<BR>"
					dat += "<A href='?src=\ref[src];action=start_mix'>Mix.</A>"
					dat += "<BR>"
					dat += "<A href='?src=\ref[src];action=unload_tank;tank=[tank_id];tank_name=[tank_name]'>Unload.</A>"
				else
					if(filling_tank_id == tank_id)
						dat += "<A href='?src=\ref[src];action=close_hatch;tank_name=[tank_name]'>Close hatch.</A><BR>"
					else
						dat += "<A href='?src=\ref[src];action=open_hatch;tank=[tank_id];tank_name=[tank_name]'>Open hatch.</A><BR>"
						dat += "<A href='?src=\ref[src];action=unload_tank;tank=[tank_id];tank_name=[tank_name]'>Unload.</A>"
			else
				dat += "<A href='?src=\ref[src];action=load_tank;tank=[tank_id];tank_name=[tank_name]'>Load.</A>"
			dat += "</div>"

	var/datum/browser/popup = new(user, "dye mixer", name, 350, 520)
	popup.set_content(dat)
	popup.open()

/obj/machinery/color_mixer/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	var/mob/living/user = usr

	switch(href_list["action"])
		if("switch_menu")
			menustat = href_list["stat"]
		if("choose_color")
			var/new_color = input(user, "Choose your desired color.", "Dye Mixer") as color|null
			if(new_color)
				chosen_color = new_color
		if("choose_quantity")
			var/new_quantity = input(user, "Choose amount to create.", "Dye Mixer") as num|null
			if(new_quantity && new_quantity > 0 && beakers["output"] && new_quantity <= beakers["output"].reagents.maximum_volume)
				chosen_quantity = new_quantity
		if("load_tank")
			var/obj/item/weapon/reagent_containers/glass/beaker/B = user.get_active_hand()
			if(istype(B))
				err_log("\[[worldtime2text()]\]<font color='blue'>NOT #103:</font> [href_list["tank_name"]] was loaded.", type = "NOT")
				user.drop_from_inventory(B)
				B.forceMove(src)
				beakers[href_list["tank"]] = B
				update_icon()
		if("unload_tank")
			if(!beakers[href_list["tank"]])
				return
			if(filling_tank_id == href_list["tank"])
				err_log("\[[worldtime2text()]\]<font color='red'>ERR #201</font>(Occured while extracting tank)<font color='red'>:</font> Hatch of [href_list["tank_name"]] was not closed before extraction.")
				return
			err_log("\[[worldtime2text()]\]<font color='blue'>NOT #104:</font> [href_list["tank_name"]] was extracted.", type = "NOT")
			beakers[href_list["tank"]].forceMove(loc)
			user.put_in_hands(beakers[href_list["tank"]])
			beakers[href_list["tank"]] = null
			update_icon()
		if("open_hatch")
			if(href_list["tank"] in tanks)
				err_log("\[[worldtime2text()]\]<font color='blue'>NOT #101:</font> Hatch of [href_list["tank_name"]] was opened.", type = "NOT")
				filling_tank_id = href_list["tank"]
				update_icon()
		if("close_hatch")
			err_log("\[[worldtime2text()]\]<font color='blue'>NOT #102:</font> Hatch of [href_list["tank_name"]] was closed.", type = "NOT")
			filling_tank_id = null
			update_icon()
		if("start_mix")
			mix_wrapper()
		if("disable_notif")
			disable_notifications = !disable_notifications
		if("clear_log")
			var/index = text2num(href_list["entry"])
			error_log.Cut(index, index + 1)

	updateUsrDialog()

/*
Specify "matrix" in list in this format:
1 2 3
4 5 6
7 8 9
*/

/proc/determinant_3_x_3(list/M)
	return M[1] * M[5] * M[9] - M[1] * M[6] * M[8] - M[2] * M[4] * M[9] - M[2] * M[6] * M[7] + M[3] * M[4] * M[8] - M[3] * M[5] * M[7]

/*
The workhorse of this entire thing, the proc attempts to mix target color from three(or less) given colors,
if it succeeds, it will output how much of given colors should be taken.

Quantity of target color is taken into consideration.

Returns 0 if nothing can be made from mixing the three given colors, otherwise returns a list of quantities of each of three colors needed to be mixed.
*/
/proc/do_mix_color_from_three(target_col, target_quan, col_1 = "#000000", col_2 = "#000000", col_3 = "#000000")
	var/r_1 = HEX_VAL_RED(col_1)
	var/g_1 = HEX_VAL_GREEN(col_1)
	var/b_1 = HEX_VAL_BLUE(col_1)

	var/r_2 = HEX_VAL_RED(col_2)
	var/g_2 = HEX_VAL_GREEN(col_2)
	var/b_2 = HEX_VAL_BLUE(col_2)

	var/r_3 = HEX_VAL_RED(col_3)
	var/g_3 = HEX_VAL_GREEN(col_3)
	var/b_3 = HEX_VAL_BLUE(col_3)

	var/r_t = HEX_VAL_RED(target_col)
	var/g_t = HEX_VAL_GREEN(target_col)
	var/b_t = HEX_VAL_BLUE(target_col)
	// We are going to be using Cramer's method of solving a system of equations.
	// Determ.
	var/delta = determinant_3_x_3(list(r_1, r_2, r_3, g_1, g_2, g_3, b_1, b_2, b_3))

	if(!delta)
		return 0

	// Determ but with columns changed to target.
	var/perc_1 = determinant_3_x_3(list(r_t, r_2, r_3, g_t, g_2, g_3, b_t, b_2, b_3)) / delta
	var/perc_2 = determinant_3_x_3(list(r_1, r_t, r_3, g_1, g_t, g_3, b_1, b_t, b_3)) / delta
	var/perc_3 = determinant_3_x_3(list(r_1, r_2, r_t, g_1, g_2, g_t, b_1, b_2, b_t)) / delta

	var/perc_total = perc_1 + perc_2 + perc_3

	if(!perc_total)
		return 0

	return list(target_quan * perc_1 / perc_total, target_quan * perc_2 / perc_total, target_quan * perc_3 / perc_total)
