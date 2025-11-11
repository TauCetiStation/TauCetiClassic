/datum/component/serial_number
	var/serial_number

/datum/component/serial_number/Initialize()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	serial_number = add_zero("[rand(0, 999999)]", 6)
	if(SSticker.current_state < GAME_STATE_SETTING_UP)
		RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(register_in_inventory))

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/serial_number/proc/register_in_inventory()
	var/atom/movable/I = parent
	var/area/A = get_area(I)
	if(A)
		var/obj/item/weapon/paper/P = A?.inventory_paper?.resolve()
		P?.info += "<hr><b>[I.name]</b><br><u>Серийный номер: [serial_number]</u><br>"

/datum/component/serial_number/proc/on_examine(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, "<span class = 'notice'>\nСерийный номер: [serial_number]</span>")
