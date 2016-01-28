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
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
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
			user << "\red There is a software error with the device."
			return 0
		else
			user << "\blue The device's software appears to be fine."
			return 1
	else if(istype(O, /obj/machinery/door))
		var/obj/machinery/door/D = O
		if(D.operating == -1)
			user << "\red There is a software error with the device."
			return 0
		else
			user << "\blue The device's software appears to be fine."
			return 1
	else if(istype(O, /obj/machinery))
		var/obj/machinery/A = O
		if(A.emagged)
			user << "\red There is a software error with the device."
			return 0
		else
			user << "\blue The device's software appears to be fine."
			return 1

/obj/item/device/debugger/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(O, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = O
		if(apc.opened || apc.wiresexposed)
			user << "<span class='notice'>Error... Close that F$@^$#$ cover NOW!</span>"
		else if(apc.stat & (BROKEN|MAINT))
			user << "<span class='notice'>Error... Device's maintenance protocols engaged...</span>"
		else
			user << "<span class='notice'>Hi there, please wait... Accessing device's software.</span>"
			if(do_after(user, 30, target = apc) && is_used_on(apc,user))
				user << "<span class='notice'>My time has come, please wait... Starting HackHim3000...</span>"
				if(do_after(user, 20, target = apc))
					user << "<span class='notice'>Faster than light, please wait... Hack in progress...</span>"
					if(do_after(user, 50, target = apc) && !(apc.emagged || apc.malfhack || apc.opened || apc.wiresexposed || apc.stat & (BROKEN|MAINT)))
						flick("apc-spark", apc)
						sleep(6)
						apc.emagged = 1
						apc.locked = 0
						user << "<span class='notice'>Happy?.. It is done.</span>"
						apc.update_icon()
					else
						user << "<span class='notice'>Please... Do not interrupt hacking process.</span>"
		return
	else if(istype(O, /obj/machinery/door))
		var/obj/machinery/door/D = O
		if(!D.density)
			user << "<span class='notice'>Error... Close that F$@^$#$ door NOW!</span>"
		else
			user << "<span class='notice'>Hi there, please wait... Accessing door's software.</span>"
			if(do_after(user, 30, target = D) && is_used_on(D,user))
				user << "<span class='notice'>My time has come, please wait... Starting HackHim3000...</span>"
				if(do_after(user, 20, target = D))
					user << "<span class='notice'>Faster than light, please wait... Hack in progress...</span>"
					if(do_after(user, 100, target = D) && D.density && !(D.operating == -1))
						flick("door_spark", D)
						sleep(6)
						D.open()
						D.operating = -1
					else
						user << "<span class='notice'>Please... Do not interrupt hacking process.</span>"
		return
	else
		..()
