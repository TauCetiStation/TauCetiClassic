// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var
/obj/machinery/light_switch
	name = "light switch"
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = TRUE
	idle_power_usage = 20
	power_channel = STATIC_LIGHT
	var/on = TRUE
	var/area/area = null
	var/otherarea = null
	var/static/image/overlay

/obj/machinery/light_switch/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/light_switch/atom_init_late()
	area = loc.loc

	if(otherarea)
		area = locate(text2path("/area/[otherarea]"))


	if(name == initial(name))
		name = "light switch ([area.name])"

	on = area.lightswitch
	updateicon()



/obj/machinery/light_switch/proc/updateicon()
	if(!overlay)
		overlay = image(icon, "light1-overlay")
		overlay.plane = LIGHTING_PLANE + 1

	cut_overlays()
	if(stat & (NOPOWER|BROKEN))
		icon_state = "light-p"
		set_light(0)
	else
		icon_state = "light[on]"
		overlay.icon_state = "light[on]-overlay"
		add_overlay(overlay)

/obj/machinery/light_switch/examine(mob/user)
	..()
	if(src in oview(1, user))
		to_chat(user, "A light switch. It is [on? "on" : "off"].")

/obj/machinery/light_switch/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	on = !on
	user.SetNextMove(CLICK_CD_INTERACT)
	playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER, 20)

	area.lightswitch = on
	area.updateicon()

	for(var/obj/machinery/light_switch/L in area)
		L.on = on
		L.updateicon()

	area.power_change()

/obj/machinery/light_switch/power_change()

	if(!otherarea)
		if(powered(power_channel))
			stat &= ~NOPOWER
		else
			stat |= NOPOWER

		updateicon()
	update_power_use()

/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	power_change()
	..(severity)
