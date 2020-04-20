//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/weapon/tank/jetpack
	name = "Jetpack (Empty)"
	desc = "A tank of compressed gas for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	w_class = ITEM_SIZE_LARGE
	item_state = "jetpack"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD
	var/datum/effect/effect/system/ion_trail_follow/ion_trail
	var/on = 0.0
	var/stabilization_on = 0
	var/volume_rate = 500              //Needed for borg jetpack transfer
	action_button_name = "Toggle Jetpack"

/obj/item/weapon/tank/jetpack/atom_init()
	. = ..()
	ion_trail = new
	ion_trail.set_up(src)

/obj/item/weapon/tank/jetpack/Destroy()
	QDEL_NULL(ion_trail)
	return ..()


/obj/item/weapon/tank/jetpack/examine(mob/user)
	..()
	if(air_contents.total_moles < 5)
		to_chat(user, "<span class='danger'>The meter on \the [src] indicates you are almost out of gas!</span>")

/obj/item/weapon/tank/jetpack/verb/toggle_rockets()
	set name = "Toggle Jetpack Stabilization"
	set category = "Object"

	stabilization_on = !stabilization_on
	to_chat(usr, "You toggle the stabilization [stabilization_on? "on":"off"].")

/obj/item/weapon/tank/jetpack/verb/toggle()
	set name = "Toggle Jetpack"
	set category = "Object"

	on = !on

	if(on)
		icon_state = "[icon_state]-on"
		ion_trail.start()
		usr.update_inv_back()
	else
		icon_state = initial(icon_state)
		ion_trail.stop()
		usr.update_inv_back()

/obj/item/weapon/tank/jetpack/proc/allow_thrust(num, mob/living/user)
	if(!on)
		return FALSE
	if((num < 0.005 || air_contents.total_moles < num))
		ion_trail.stop()
		return FALSE

	var/datum/gas_mixture/G = air_contents.remove(num)

	var/allgases = G.gas["carbon_dioxide"] + G.gas["nitrogen"] + G.gas["oxygen"] + G.gas["phoron"]
	if(allgases >= 0.005)
		return TRUE

	qdel(G)

/obj/item/weapon/tank/jetpack/ui_action_click()
	toggle()


/obj/item/weapon/tank/jetpack/void
	name = "Void Jetpack (Oxygen)"
	desc = "It works well in a void."
	icon_state = "jetpack-void"
	item_state =  "jetpack-void"

/obj/item/weapon/tank/jetpack/void/atom_init()
	. = ..()
	air_contents.adjust_gas("oxygen", (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/jetpack/oxygen
	name = "Jetpack (Oxygen)"
	desc = "A tank of compressed oxygen for use as propulsion in zero-gravity areas. Use with caution."
	icon_state = "jetpack"
	item_state = "jetpack"

/obj/item/weapon/tank/jetpack/oxygen/atom_init()
	. = ..()
	air_contents.adjust_gas("oxygen", (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/jetpack/carbondioxide
	name = "Jetpack (Carbon Dioxide)"
	desc = "A tank of compressed carbon dioxide for use as propulsion in zero-gravity areas. Painted black to indicate that it should not be used as a source for internals."
	distribute_pressure = 0
	icon_state = "jetpack-black"
	item_state =  "jetpack-black"

/obj/item/weapon/tank/jetpack/carbondioxide/atom_init()
	. = ..()
	air_contents.adjust_gas("carbon_dioxide", (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/jetpack/oxygen/harness //TG-nuke jetpack
	name = "jet harness (oxygen)"
	desc = "A lightweight tactical harness, used by those who don't want to be weighed down by traditional jetpacks."
	icon_state = "jetpack-mini"
	item_state = "jetpack-mini"
	volume = 40
	throw_range = 7
	w_class = ITEM_SIZE_NORMAL
