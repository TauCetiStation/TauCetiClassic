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

/proc/is_wire_tool(obj/item/I)
	if(ismultitool(I))
		return TRUE
	if(iswirecutter(I))
		return TRUE
	if(istype(I, /obj/item/device/assembly/signaler))
		return TRUE
	return

var/list/same_wires = list()

/datum/wires
	var/random = FALSE     // Will the wires be different for every single instance.
	var/atom/holder = null // The holder
	var/holder_type = null // The holder type; used to make sure that the holder is the correct type.
	var/wire_count = 0     // Max is 16
	var/wires_status = 0   // BITFLAG OF WIRES

	var/list/wires
	var/list/signallers

	var/table_options = " align='center'"
	var/row_options1 = " width='80px'"
	var/row_options2 = " width='260px'"
	var/window_x = 370
	var/window_y = 470

	// All possible wires colors are here.
	var/static/list/wire_colors = list("red", "blue", "green", "black", "orange", "brown", "gold", "gray", "cyan", "navy", "purple", "pink")

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
			same_wires[holder_type] = src.wires.Copy()
		else
			var/list/exist_wires = same_wires[holder_type]
			wires = exist_wires // Reference the wires list.

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

/**
 * Will return TRUE if wires menu successful opened.
 */
/datum/wires/proc/interact(mob/living/user)
	if(!holder || isAI(user) || !can_use(user))
		return FALSE

	if(additional_checks_and_effects(user))
		return FALSE

	var/html = get_interact_window()

	user.set_machine(holder)

	var/datum/browser/popup = new(user, "wires", holder.name, window_x, window_y)
	popup.set_content(html)
	popup.set_title_image(user.browse_rsc_icon(holder.icon, holder.icon_state))
	popup.open()

	return TRUE

/**
 * In default variation will display all wires and status of them.
 * So you can override it in next variant to get additional data to display.
 *
 * > /datum/wires/example/get_interact_window()
 * >   var/obj/machinery/example/E = holder
 * >   . += ..()
 * >   . += "<br>Some light is [E.some_status ? "off" : "on"]."
 * >   . += "<br>Another light is [E.another_status ? "off" : "blinking"]."
 */
/datum/wires/proc/get_interact_window()
	var/html = "<fieldset class='block'>"
	html += "<legend><h3>Exposed Wires</h3></legend>"
	html += "<table[table_options]>"

	for(var/color in wires)
		html += "<tr>"
		html += "<td[row_options1]><font color='[color]'><b>[capitalize(color)]</b></font></td>"
		html += "<td[row_options2]>"
		html += "<a href='?src=\ref[src];action=1;cut=[color]'>[is_color_cut(color) ? "Mend" :  "Cut"]</a>"
		html += "<a href='?src=\ref[src];action=1;pulse=[color]'>Pulse</a>"
		html += "<a href='?src=\ref[src];action=1;attach=[color]'>[is_signaler_attached(color) ? "Detach" : "Attach"] Signaller</a>"
		html += "</td>"
		html += "</tr>"
	html += "</table>"
	html += "</fieldset>"

	return html

/datum/wires/Topic(href, href_list)
	..()

	if(!can_use(usr) || href_list["close"])
		usr << browse(null, "window=wires")
		usr.unset_machine(holder)
		return FALSE

	if(!(in_range(holder, usr) && isliving(usr)))
		return FALSE

	var/mob/living/L = usr

	if(!holder.can_mob_interact(L))
		return FALSE

	if(href_list["action"])
		var/obj/item/I = L.get_active_hand()
		holder.add_hiddenprint(L)

		if(href_list["cut"]) // Toggles the cut/mend status
			if(iswirecutter(I))
				var/color = href_list["cut"]
				cut_wire_color(color)
			else
				to_chat(L, "<span class='warning'>You need wirecutters!</span>")

		else if(href_list["pulse"])
			if(ismultitool(I))
				var/color = href_list["pulse"]
				pulse_color(color)
			else
				to_chat(L, "<span class='warning'>You need a multitool!</span>")

		else if(href_list["attach"])
			var/color = href_list["attach"]

			// Detach
			if(is_signaler_attached(color))
				var/obj/item/O = detach_signaler(color)
				if(O)
					L.put_in_hands(O)

			// Attach
			else
				if(issignaler(I))
					L.drop_item()
					attach_signaler(color, I)
				else
					to_chat(L, "<span class='warning'>You need a remote signaller!</span>")

		// Update Window
		interact(usr)

	return TRUE

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
