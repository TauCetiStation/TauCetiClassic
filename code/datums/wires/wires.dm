/**
 * Use example:
 *
 * > var/const/BOLTED  = 1
 * > var/const/SHOCKED = 2
 * > var/const/SAFETY  = 4
 * > var/const/POWER   = 8
 * >
 * > /datum/wires/door/update_cut(index, mended)
 * > 	var/obj/machinery/door/airlock/A = holder
 * > 	switch(index)
 * > 		if(BOLTED)
 * > 		if(!mended)
 * > 			A.bolt()
 * > 		if(SHOCKED)
 * > 			A.shock()
 * > 		if(SAFETY )
 * > 			A.safety()
 */

#define MAX_FLAG 65535

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
			var/list/wires = same_wires[holder_type]
			src.wires = wires // Reference the wires list.

/datum/wires/Destroy()
	wires = null
	QDEL_LIST_ASSOC(signallers)
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
		src.wires[color] = index


/datum/wires/proc/interact(mob/living/user)
	var/html = null

	if(holder && can_use(user))
		html = get_interact_window()

	if(html)
		user.set_machine(holder)

	var/datum/browser/popup = new(user, "wires", holder.name, window_x, window_y)
	popup.set_content(html)
	popup.set_title_image(user.browse_rsc_icon(holder.icon, holder.icon_state))
	popup.open()

/datum/wires/proc/get_interact_window()
	var/html = "<fieldset class='block'>"
	html += "<legend><h3>Exposed Wires</h3></legend>"
	html += "<table[table_options]>"

	for(var/color in wires)
		html += "<tr>"
		html += "<td[row_options1]><font color='[color]'><b>[capitalize(color)]</b></font></td>"
		html += "<td[row_options2]>"
		html += "<A href='?src=\ref[src];action=1;cut=[color]'>[is_color_cut(color) ? "Mend" :  "Cut"]</A>"
		html += " <A href='?src=\ref[src];action=1;pulse=[color]'>Pulse</A>"
		html += " <A href='?src=\ref[src];action=1;attach=[color]'>[is_signaler_attached(color) ? "Detach" : "Attach"] Signaller</A>"
		html += "</td>"
		html += "</tr>"
	html += "</table>"
	html += "</fieldset>"

	return html

/datum/wires/Topic(href, href_list)
	..()
	if(in_range(holder, usr) && isliving(usr))
		var/mob/living/L = usr

		if(can_use(L) && href_list["action"])
			var/obj/item/I = L.get_active_hand()
			holder.add_hiddenprint(L)

			if(href_list["cut"]) // Toggles the cut/mend status
				if(istype(I, /obj/item/weapon/wirecutters))
					var/color = href_list["cut"]
					cut_wire_color(color)
				else
					to_chat(L, "<span class='warning'>You need wirecutters!</span>")

			else if(href_list["pulse"])
				if(istype(I, /obj/item/device/multitool))
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

	if(href_list["close"])
		usr << browse(null, "window=wires")
		usr.unset_machine(holder)


////////////////////
// Overridable procs
////////////////////
/**
 * Called when wires cut/mended.
 */
/datum/wires/proc/update_cut(index, mended)
	return

/**
 * Called when wire pulsed. Add code here.
 */
/datum/wires/proc/update_pulsed(index)
	return

/**
 * Case defined proc for wires in different machines to valid
 * interaction with wires.
 */
/datum/wires/proc/can_use(mob/living/L)
	return TRUE


//////////
// Helpers
//////////
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