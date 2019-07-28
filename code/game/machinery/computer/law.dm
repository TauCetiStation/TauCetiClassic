//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/aiupload
	name = "AI Upload"
	desc = "Used to upload laws to the AI."
	icon_state = "command"
	circuit = /obj/item/weapon/circuitboard/aiupload
	light_color = "#ffffff"
	var/mob/living/silicon/ai/current = null
	var/opened = FALSE


/obj/machinery/computer/aiupload/verb/AccessInternals()
	set category = "Object"
	set name = "Access Computer's Internals"
	set src in oview(1)
	if(get_dist(src, usr) > 1 || usr.restrained() || usr.lying || usr.stat || issilicon(usr))
		return

	opened = !opened
	if(opened)
		to_chat(usr, "<span class='notice'>The access panel is now open.</span>")
	else
		to_chat(usr, "<span class='notice'>The access panel is now closed.</span>")
	return


/obj/machinery/computer/aiupload/attackby(obj/item/weapon/O, mob/user)
	if (!SSmapping.has_level(user.z))
		to_chat(user, "<span class='warning'><b>Unable to establish a connection</b>:</span> You're too far away from the station!")
		return
	if(istype(O, /obj/item/weapon/aiModule))
		var/obj/item/weapon/aiModule/M = O
		M.install(src)
	else
		..()


/obj/machinery/computer/aiupload/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	current = select_active_ai(user)
	if (!current)
		to_chat(user, "No active AIs detected.")
	else
		to_chat(user, "[current.name] selected for law changes.")

/obj/machinery/computer/borgupload
	name = "Cyborg Upload"
	desc = "Used to upload laws to Cyborgs."
	icon_state = "command"
	circuit = /obj/item/weapon/circuitboard/borgupload
	var/mob/living/silicon/robot/current = null


/obj/machinery/computer/borgupload/attackby(obj/item/weapon/aiModule/module, mob/user)
	if(istype(module, /obj/item/weapon/aiModule))
		module.install(src)
	else
		return ..()


/obj/machinery/computer/borgupload/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	current = freeborg()

	if (!current)
		to_chat(user, "No free cyborgs detected.")
	else
		to_chat(user, "[src.current.name] selected for law changes.")
