/**
 * Usage should be the next. Create subtype of `wires` class for object you want to have wires.
 * Then override procs under `Overridable procs` part to make reaction you want.
 * After it you shoud create wires in object you want (see another implemetation for example).
 *
 * Call `wires.interact(user)` from object method to interact with wires menu.
 * See `get_interact_window()` to create additional data for view.
 * Const values for wires defined in beetflag system with max value of 65535.
 *
 * Use example in defenition file:
 * > var/const/BOLTED  = 1
 * > var/const/SHOCKED = 2
 * > var/const/SAFETY  = 4
 * >
 * > /datum/wires/example
 * > 	holder_type = /obj/machinery/example
 * > 	wire_count = 3
 * >
 * > /datum/wires/example/update_cut(index, mended)
 * > 	var/obj/machinery/example/E = holder
 * >
 * > 	switch(index)
 * > 		if(BOLTED)
 * > 			if(!mended)
 * > 				E.foo_1()
 * > 		if(SHOCKED)
 * > 			E.foo_2()
 * > 		if(SAFETY )
 * > 			E.foo_3()
 *
 * In object:
 * > /obj/machinery/example
 * >	var/datum/wires/example/wires = null
 * >
 * > /obj/machinery/example/New()
 * >	..()
 * >	wires = new(src)
 * >
 * > /obj/machinery/example/Destroy()
 * >	QDEL_NULL(wires)
 * >	return ..()
 * >
 * > /obj/machinery/example/some_proc()
 * >	wires.interact()
 */

#define MAX_FLAG 65535
#define SEE_BLIND 1

/proc/is_wire_tool(obj/item/I)
	if(ismultitool(I))
		return TRUE
	if(iswirecutter(I))
		return TRUE
	if(istype(I, /obj/item/device/assembly/signaler))
		return TRUE
	return

var/global/list/same_wires = list()

// Preset of daltonism with his colors by hex
var/global/list/wire_daltonism_colors = list()

/datum/wires
	var/random = FALSE     // Will the wires be different for every single instance.
	var/atom/holder = null // The holder
	var/holder_type = null // The holder type; used to make sure that the holder is the correct type.
	var/wire_count = 0     // Max is 16
	var/wires_status = 0   // BITFLAG OF WIRES

	var/list/wires
	var/list/signallers

	var/table_options = " align='center'"
	var/row_options1 = " width='120px'"
	var/row_options2 = " width='260px'"
	var/window_x = 370
	var/window_y = 470

	// All possible wires colors are here.
	var/static/list/wire_colors = list("red", "blue", "green", "white", "orange", "brown", "gold", "gray", "cyan", "lime", "purple", "pink")

/datum/wires/New(atom/holder)
	..()
	src.holder = holder

	wires = list()
	signallers = list()

	if(!istype(holder, holder_type))
		CRASH("Our holder is null/the wrong type!")

	// Generate new wires
	if(random)
		randomize_wires()

	// Get the same wires
	else
		// We don't have any wires to copy yet, generate some and then copy it.
		if(!same_wires[holder_type])
			randomize_wires()
			same_wires[holder_type] = wires.Copy()
		else
			wires = same_wires[holder_type] // Reference the wires list.

/datum/wires/Destroy()
	wires = null
	QDEL_LIST_ASSOC_VAL(signallers)
	return ..()

/datum/wires/proc/randomize_wires()
	var/list/colors_to_pick = wire_colors.Copy() // Get a copy, not a reference.
	var/list/indexes_to_pick = list()

	//Generate our indexes
	for(var/i = 1; i < MAX_FLAG && i < (1 << wire_count); i += i)
		indexes_to_pick += i

	colors_to_pick.len = wire_count // Downsize it to our specifications.
	while(colors_to_pick.len && indexes_to_pick.len)
		// Pick and remove a color
		var/color = pick_n_take(colors_to_pick)

		// Pick and remove an index
		var/index = pick_n_take(indexes_to_pick)
		wires[color] = index

/datum/wires/proc/get_status()
	return list()

/**
 * Will return TRUE if wires menu successful opened.
 */
/datum/wires/proc/interact(mob/living/user)
	if(!holder || isAI(user) || !can_use(user))
		return FALSE

	if(additional_checks_and_effects(user))
		return FALSE

	user.set_machine(holder)

	tgui_interact(user, null)

	return TRUE

/datum/wires/proc/calculate_daltonism_colors(sight_mod)
	if (!wire_daltonism_colors)
		wire_daltonism_colors = list()
	if(sight_mod && !wire_daltonism_colors[sight_mod])
		// Creates a list of color for people with daltonism and save his
		wire_daltonism_colors[sight_mod] = list()
		for(var/i in wire_colors)
			var/color_hex = color_by_hex[i]

			if(!color_hex)
				var/color = pick(wire_colors)
				wire_daltonism_colors[sight_mod][i] = color
				continue

			var/r = hex2num(copytext(color_hex, 2, 4))
			var/g = hex2num(copytext(color_hex, 4, 6))
			var/b = hex2num(copytext(color_hex, 6, 8))

			var/datum/ColorMatrix/CM = new(sight_mod)
			var/new_r = CM.matrix[1] * r + CM.matrix[4] * g + CM.matrix[7] * b + CM.matrix[10] * 255
			var/new_g = CM.matrix[2] * r + CM.matrix[5] * g + CM.matrix[8] * b + CM.matrix[11] * 255
			var/new_b = CM.matrix[3] * r + CM.matrix[6] * g + CM.matrix[9] * b + CM.matrix[12] * 255

			wire_daltonism_colors[sight_mod][i] = rgb(new_r, new_g, new_b)

/datum/wires/tgui_host()
	return holder

/datum/wires/tgui_status(mob/user)
	if(can_use(user))
		return ..()
	return UI_CLOSE

/datum/wires/tgui_state(mob/user)
	return global.physical_state

/datum/wires/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Wires", "[holder.name] Wires")
		ui.open()

/datum/wires/tgui_data(mob/user)
	var/list/data = list()
	var/list/payload = list()

	var/see_effect
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(HAS_TRAIT(H, TRAIT_BLIND))
			see_effect = SEE_BLIND

		else if(H.sightglassesmod)
			see_effect = H.sightglassesmod

	var/list/colors_by_num
	if(see_effect != SEE_BLIND && see_effect != null)
		colors_by_num = list()
		for(var/color in color_by_hex)
			var/r = hex2num(copytext(color_by_hex[color], 2, 4))
			var/g = hex2num(copytext(color_by_hex[color], 4, 6))
			var/b = hex2num(copytext(color_by_hex[color], 6, 8))
			colors_by_num[color] = list(r, g, b)

	for(var/color in wires)
		var/shownColor
		var/shownColorLbl
		switch(see_effect)
			if(SEE_BLIND)
				shownColor = "grey"
				shownColorLbl = null
			if(null)
				shownColor = color
				shownColorLbl = capitalize(shownColor)
			else
				var/mcolor
				calculate_daltonism_colors(see_effect)
				if(hex2color(wire_daltonism_colors[see_effect][color])) // Color in color_by_hex list
					mcolor = hex2color(wire_daltonism_colors[see_effect][color])
				else // Closest color name from list
					var/r = hex2num(copytext(wire_daltonism_colors[see_effect][color], 2, 4))
					var/g = hex2num(copytext(wire_daltonism_colors[see_effect][color], 4, 6))
					var/b = hex2num(copytext(wire_daltonism_colors[see_effect][color], 6, 8))
					var/min_dist = 256 // Find min dist
					for(var/colour in colors_by_num)
						var/list/palette = colors_by_num[colour]
						var/d = sqrt((palette[1] - r)**2 + (palette[2] - g)**2 + (palette[3] - b)**2)
						if(!mcolor || d < min_dist)
							min_dist = d
							mcolor = colour
				shownColor = wire_daltonism_colors[see_effect][color]
				shownColorLbl = capitalize(replacetext(mcolor, "_", " "))
		payload.Add(list(list(
			"color" = shownColor,
			"label" = shownColorLbl,
			"wire" = color,
			"cut" = is_color_cut(color),
			"attached" = is_signaler_attached(color)
		)))
	data["wires"] = payload
	data["status"] = get_status()
	//data["proper_name"] = (proper_name != "Unknown") ? proper_name : null
	return data

/datum/wires/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	if(!(in_range(holder, usr) && isliving(usr)))
		return

	var/mob/living/L = usr

	if(!can_use(src) || !holder.can_mob_interact(L))
		return
	var/target_wire = params["wire"]
	var/obj/item/I = L.get_active_hand()
	switch(action)
		if("cut")
			if(I && iswirecutter(I))
				cut_wire_color(target_wire)
				I.play_tool_sound(holder, 20)
				. = TRUE
			else
				to_chat(L, "<span class='warning'>You need wirecutters!</span>")
		if("pulse")
			if(I && ismultitool(I))
				pulse_color(target_wire)
				I.play_tool_sound(holder, 20)
				. = TRUE
			else
				to_chat(L, "<span class='warning'>You need a multitool!</span>")
		if("attach")
			if(is_signaler_attached(target_wire))
				var/obj/item/O = detach_signaler(target_wire)
				if(O)
					L.put_in_hands(O)
					. = TRUE
			else
				if(issignaler(I))
					L.drop_from_inventory(I, holder)
					attach_signaler(target_wire, I)
				else
					to_chat(L, "<span class='warning'>You need a remote signaller!</span>")
	if(.)
		holder.add_fingerprint(usr)

////////////////////
// Overridable procs
////////////////////
/**
 * Called when wires cut/mended.
 */
/datum/wires/proc/update_cut(index, mended)
	return

/**
 * Called when wire pulsed.
 */
/datum/wires/proc/update_pulsed(index)
	return

/**
 * Case defined proc in different machines to valid interaction with wires.
 */
/datum/wires/proc/can_use()
	return TRUE

/**
 * Some wires may have additional checks or effects, like electric shock and etc.
 * This proc should call those effects or checks and return `TRUE` to cancel interaction with wires.
 */
/datum/wires/proc/additional_checks_and_effects(mob/living/user)
	return FALSE


//////////
// Helpers
//////////
/datum/wires/proc/repair()
	wires_status = 0

/datum/wires/proc/pulse_color(color)
	pulse_index(get_index_by_color(color))

/datum/wires/proc/pulse_index(index)
	if(is_index_cut(index))
		return
	update_pulsed(index)

/datum/wires/proc/get_index_by_color(color)
	if(wires[color])
		var/index = wires[color]
		return index
	else
		CRASH("[color] is not a key in wires.")


////////////////////////////
// Is Index/Colour Cut procs
////////////////////////////
/datum/wires/proc/is_color_cut(color)
	var/index = get_index_by_color(color)
	return is_index_cut(index)

/datum/wires/proc/is_index_cut(index)
	return (index & wires_status)


//////////////////
// Signaller Procs
//////////////////
/datum/wires/proc/is_signaler_attached(color)
	if(signallers[color])
		return TRUE
	return FALSE

/datum/wires/proc/get_attached_signaler(color)
	if(signallers[color])
		return signallers[color]
	return null

/datum/wires/proc/attach_signaler(color, obj/item/device/assembly/signaler/S)
	if(color && S)
		if(!is_signaler_attached(color))
			signallers[color] = S
			S.loc = holder
			S.connected = src
			return S

/datum/wires/proc/detach_signaler(color)
	if(color)
		var/obj/item/device/assembly/signaler/S = get_attached_signaler(color)
		if(S)
			signallers -= color
			S.connected = null
			S.loc = holder.loc
			return S

/datum/wires/proc/pulse_signaler(obj/item/device/assembly/signaler/S)
	for(var/color in signallers)
		if(S == signallers[color])
			pulse_color(color)
			break


//////////////////////////////
// Cut Wire Colour/Index procs
//////////////////////////////
/datum/wires/proc/cut_wire_color(color)
	var/index = get_index_by_color(color)
	cut_wire_index(index)

/datum/wires/proc/cut_wire_index(index)
	if(is_index_cut(index))
		wires_status &= ~index
		update_cut(index, TRUE)
	else
		wires_status |= index
		update_cut(index, FALSE)

/datum/wires/proc/random_cut()
	var/r = rand(1, wires.len)
	cut_wire_index(r)

/datum/wires/proc/cut_all()
	for(var/i = 1; i < MAX_FLAG && i < (1 << wire_count); i += i)
		cut_wire_index(i)

/datum/wires/proc/is_all_cut()
	if(wires_status == (1 << wire_count) - 1)
		return TRUE
	return FALSE


#undef MAX_FLAG
#undef SEE_BLIND
