/datum/ipc_armour
	var/brute_mult = 1
	var/burn_mult = 1
	var/speed_mod = 0
	var/siemens_coefficient = 1
	var/reflect_chance = 0

	var/heat_temp_mod = 0
	var/cold_temp_mod = 0

	var/color = "#ffffff"

	var/mob/living/carbon/human/owner

/datum/ipc_armour/metal
	brute_mult = 0.8
	speed_mod = 0.5
	siemens_coefficient = 2

	color = "#8d8e91"

/datum/ipc_armour/plasteel
	brute_mult = 0.66
	speed_mod = 2.5
	siemens_coefficient = 1.5

	color = "#525357"

/datum/ipc_armour/hardglass
	brute_mult = 0.58
	burn_mult = 1.2
	siemens_coefficient = 0.5
	reflect_chance = 20

	color = "#a0bbce"

/datum/ipc_armour/hardphoronglass
	siemens_coefficient = 0.25
	reflect_chance = 25

	color = "#d3b3cb"

/datum/ipc_armour/gold
	brute_mult = 0.93
	burn_mult = 0.93
	speed_mod = -0.7
	siemens_coefficient = 1.25

	color = "#ffc20e"

/datum/ipc_armour/uranium
	brute_mult = 0.93
	burn_mult = 0.93
	speed_mod = 1
	siemens_coefficient = 1.25

	color = "#4c7a43"

/datum/ipc_armour/uranium/add_armour()
	..()
	RegisterSignal(owner, COMSIG_MOB_DIED, PROC_REF(on_death))

	START_PROCESSING(SSobj, src)

/datum/ipc_armour/uranium/proc/on_death()
	irradiate_in_dist(get_turf(owner), 100, 5)

/datum/ipc_armour/uranium/process()
	if(owner.stat == DEAD)
		return

	var/obj/item/organ/internal/liver/IO = owner.organs_by_name[O_LIVER]
	if(!IO)
		return

	var/obj/item/weapon/stock_parts/cell/C = locate(/obj/item/weapon/stock_parts/cell) in IO
	if(!C)
		return

	if(owner.nutrition < C.maxcharge*0.9)
		return

	irradiate_in_dist(get_turf(owner), 3, 1)
	owner.nutrition += C.maxcharge*0.1

/datum/ipc_armour/uranium/remove_armour()
	UnregisterSignal(owner, COMSIG_MOB_DIED)
	STOP_PROCESSING(SSobj, src)
	..()

/datum/ipc_armour/phoron
	brute_mult = 0.93
	burn_mult = 0.93
	siemens_coefficient = 0.75

	heat_temp_mod = 100

	color = "#ce3282"

/datum/ipc_armour/phoron/add_armour()
	..()

	RegisterSignal(owner, COMSIG_MOB_DIED, PROC_REF(on_death))

/datum/ipc_armour/phoron/proc/on_death()
	explosion(get_turf(owner), 0, 2, 5)

/datum/ipc_armour/phoron/remove_armour()
	UnregisterSignal(owner, COMSIG_MOB_DIED)
	..()

/datum/ipc_armour/diamond
	brute_mult = 0.8
	burn_mult = 0.8
	siemens_coefficient = 0.1

	heat_temp_mod = 100

	color = "#97ffff"

/datum/ipc_armour/bodyarmor
	brute_mult = 0.8
	burn_mult = 0.8

	color = "#66789c"

/datum/ipc_armour/New(mob/living/carbon/human/H)
	owner = H
	add_armour()

/datum/ipc_armour/proc/add_armour()
	owner.mob_brute_mod.ModMultiplicative(brute_mult, src)
	owner.mob_burn_mod.ModMultiplicative(burn_mult, src)
	owner.mob_speed_mod.ModStatic(speed_mod, src)
	owner.mob_siemens_mod.ModMultiplicative(siemens_coefficient, src)
	owner.mob_reflect_chance.ModStatic(reflect_chance, src)

	owner.mob_heat_level_1.ModStatic(heat_temp_mod, src)
	owner.mob_heat_level_2.ModStatic(heat_temp_mod, src)
	owner.mob_heat_level_3.ModStatic(heat_temp_mod, src)

	owner.mob_cold_level_1.ModStatic(cold_temp_mod, src)
	owner.mob_cold_level_2.ModStatic(cold_temp_mod, src)
	owner.mob_cold_level_3.ModStatic(cold_temp_mod, src)

/datum/ipc_armour/proc/remove_armour()
	owner.mob_brute_mod.RemoveMods(src)
	owner.mob_burn_mod.RemoveMods(src)
	owner.mob_speed_mod.RemoveMods(src)
	owner.mob_siemens_mod.RemoveMods(src)
	owner.mob_reflect_chance.RemoveMods(src)

	owner.mob_heat_level_1.RemoveMods(src)
	owner.mob_heat_level_2.RemoveMods(src)
	owner.mob_heat_level_3.RemoveMods(src)

	owner.mob_cold_level_1.RemoveMods(src)
	owner.mob_cold_level_2.RemoveMods(src)
	owner.mob_cold_level_3.RemoveMods(src)

	qdel(src)
