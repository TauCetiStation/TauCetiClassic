/obj/mecha/working/clarke
	desc = "Combining man and machine for a better, stronger miner."
	name = "Clarke"
	icon_state = "clarke"
	initial_icon = "clarke"
	step_in = 2
	health = 200
	damage_absorption = list(BRUTE=0.7,BURN=0,5,BULLET=0.8,ENERGY=0.8,BOMB=0.5)
	max_temperature = 25000
	deflect_chance = 15
	lights_power = 8
	max_equip = 3
	deflect_chance = 20
	step_energy_drain = 6
	var/cargo_capacity = 15
	var/list/cargo = new
	wreckage = /obj/effect/decal/mecha_wreckage/clarke
	stepsound = 'sound/mecha/mechmove04.ogg'
	turnsound = 'sound/mecha/mechmove04.ogg'

/obj/mecha/working/clarke/atom_init()
	. = ..()
	AddComponent(/datum/component/examine_research, DEFAULT_SCIENCE_CONSOLE_ID, 2000, list(DIAGNOSTIC_EXTRA_CHECK, VIEW_EXTRA_CHECK))

/obj/mecha/working/clarke/go_out()
	..()
	update_icon()

/obj/mecha/working/clarke/moved_inside(mob/living/carbon/human/H)
	..()
	update_icon()

/obj/mecha/working/clarke/mmi_moved_inside(obj/item/device/mmi/mmi_as_oc,mob/user)
	..()
	update_icon()
