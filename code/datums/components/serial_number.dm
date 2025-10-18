/datum/component/serial_number
	var/serial_number

/datum/component/serial_number/Initialize(atom/target)
	if(SSticker.current_state < GAME_STATE_SETTING_UP)
		qdel(src)
		return

	RegisterSignal(target, COMSIG_TICKER_ROUND_STARTING, PROC_REF(register_in_inventory))


/datum/component/serial_number/proc/register_in_inventory(atom/target)
	var/area/A = get_area(target)
	serial_number = generate_serial_number()
	if(A)
		var/obj/item/weapon/paper/P = A?.inventory_paper?.resolve()
		P?.info += "<hr><b>[target.name]</b><br><u>Серийный номер: [serial_number]</u><br>"
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/serial_number/proc/generate_serial_number()
	serial_number = "[rand(0, 999999)]"
	while(length(serial_number) < 6)
		serial_number = "0" + serial_number

	return serial_number

/datum/component/serial_number/proc/on_examine(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, "<span class = 'notice'>\nСерийный номер: [serial_number]</span>")
