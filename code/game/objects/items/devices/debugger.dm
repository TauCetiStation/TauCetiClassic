/**
 * Multitool -- A multitool is used for hacking electronic devices.
 * TO-DO -- Using it as a power measurement tool for cables etc. Nannek.
 *
 */

/obj/item/device/debugger
	icon = 'icons/obj/hacktool.dmi'
	name = "debugger"
	icon_state = "hacktool-g"
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	flags = CONDUCT
	force = 5.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	m_amt = 50
	g_amt = 20
	origin_tech = "magnets=1;engineering=1"
	var/obj/machinery/telecomms/buffer // simple machine buffer for device linkage

/obj/item/device/debugger/is_used_on(obj/O, mob/user)
	if(istype(O, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = O
		if(A.emagged || A.malfhack)
			to_chat(user, "<span class='warning'>There is a software error with the device.</span>")
			return 0
		else
			to_chat(user, "<span class='notice'>The device's software appears to be fine.</span>")
			return 1
	else if(istype(O, /obj/machinery/door))
		var/obj/machinery/door/D = O
		if(D.operating == -1)
			to_chat(user, "<span class='warning'>There is a software error with the device.</span>")
			return 0
		else
			to_chat(user, "<span class='notice'>The device's software appears to be fine.</span>")
			return 1
	else if(istype(O, /obj/machinery))
		var/obj/machinery/A = O
		if(A.emagged)
			to_chat(user, "<span class='warning'>There is a software error with the device.</span>")
			return 0
		else
			to_chat(user, "<span class='notice'>The device's software appears to be fine.</span>")
			return 1

/obj/item/device/debugger/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(user.is_busy()) return
	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = target
		if(apc.opened || apc.wiresexposed)
			to_chat(user, "<span class='notice'>Error... Close that F$@^$#$ cover NOW!</span>")
		else if(apc.stat & (BROKEN|MAINT))
			to_chat(user, "<span class='notice'>Error... Device's maintenance protocols engaged...</span>")
		else
			to_chat(user, "<span class='notice'>Hi there, please wait... Accessing device's software.</span>")
			if(do_after(user, 30, target = apc) && is_used_on(apc,user))
				to_chat(user, "<span class='notice'>My time has come, please wait... Starting HackHim3000...</span>")
				if(do_after(user, 20, target = apc))
					to_chat(user, "<span class='notice'>Faster than light, please wait... Hack in progress...</span>")
					if(do_after(user, 50, target = apc) && !(apc.emagged || apc.malfhack || apc.opened || apc.wiresexposed || apc.stat & (BROKEN|MAINT)))
						flick("apc-spark", apc)
						sleep(6)
						apc.emagged = 1
						apc.locked = 0
						to_chat(user, "<span class='notice'>Happy?.. It is done.</span>")
						apc.update_icon()
					else
						to_chat(user, "<span class='notice'>Please... Do not interrupt hacking process.</span>")
		return
	else if(istype(target, /obj/machinery/door))
		var/obj/machinery/door/D = target
		if(!D.density)
			to_chat(user, "<span class='notice'>Error... Close that F$@^$#$ door NOW!</span>")
		else
			to_chat(user, "<span class='notice'>Hi there, please wait... Accessing door's software.</span>")
			if(do_after(user, 30, target = D) && is_used_on(D,user))
				to_chat(user, "<span class='notice'>My time has come, please wait... Starting HackHim3000...</span>")
				if(do_after(user, 20, target = D))
					to_chat(user, "<span class='notice'>Faster than light, please wait... Hack in progress...</span>")
					if(do_after(user, 100, target = D) && D.density && !(D.operating == -1))
						flick("door_spark", D)
						sleep(6)
						D.open()
						D.operating = -1
					else
						to_chat(user, "<span class='notice'>Please... Do not interrupt hacking process.</span>")
		return
	else
		..()
