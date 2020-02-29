/**
 * Multitool -- A multitool is used for hacking electronic devices.
 * TO-DO -- Using it as a power measurement tool for cables etc. Nannek.
 *
 */

/obj/item/device/multitool
	name = "multitool"
	desc = "Used for pulsing wires to test which to cut. Not recommended by doctors."
	hitsound = list('sound/items/tools/device_small-hit.ogg')
	icon_state = "multitool"
	flags = CONDUCT
	force = 1.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	m_amt = 50
	g_amt = 20
	origin_tech = "magnets=1;engineering=1"
	var/const/buffer_limit = 16
	var/obj/machinery/telecomms/buffer // simple machine buffer for device linkage
	var/list/obj/machinery/door/airlock/airlocks_buffer = list()
	var/list/obj/machinery/door/poddoor/poddoors_buffer = list()

/obj/item/device/multitool/verb/clear_buffer()
	set category = "Object"
	set name = "Clear buffer"
	if(airlocks_buffer.len || poddoors_buffer.len || buffer)
		airlocks_buffer.Cut()
		poddoors_buffer.Cut()
		buffer = null
		to_chat(usr, "<span class='notice'>You clear the buffer of your multitool</span>")
	else
		to_chat(usr, "<span class='notice'>The buffer if empty</span>")

/obj/item/device/multitool/Destroy()
	airlocks_buffer.Cut()
	poddoors_buffer.Cut()
	buffer = null
	return ..()
