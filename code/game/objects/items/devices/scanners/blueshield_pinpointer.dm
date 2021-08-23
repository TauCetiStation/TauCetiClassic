// Pinpointer to detect Heads of Staff

/obj/item/weapon/pinpointer/heads
	name = "heads of staff pinpointer"
	desc = "A larger version of the normal pinpointer. Includes quantuum connection to the database of the Station Heads of Staff to point to."

/obj/item/weapon/pinpointer/heads/process()
	if (active && !target)
		icon_state = "pinonnull"
		return
	. = ..()

/obj/item/weapon/pinpointer/heads/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Pinpointer Target"
	set src in view(1)

	active = FALSE
	STOP_PROCESSING(SSobj, src)
	icon_state = "pinoff"
	target = null

	var/list/heads = get_all_heads()
	var/datum/mind/head = tgui_input_list(usr, "Head to point to", "Target selection", heads)

	if (!head)
		return
	target = head.current

	return attack_self(usr)