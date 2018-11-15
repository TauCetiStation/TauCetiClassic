/datum/spacepod/equipment
	var/obj/spacepod/my_atom
	var/list/obj/item/spacepod_equipment/installed_modules = list() // holds an easy to access list of installed modules

	var/obj/item/spacepod_equipment/weaponry/weapon_system // weapons system
	var/obj/item/spacepod_equipment/misc/misc_system // misc system
	var/obj/item/spacepod_equipment/cargo/cargo_system // cargo system
	var/obj/item/spacepod_equipment/cargo/sec_cargo_system // secondary cargo system
	var/obj/item/spacepod_equipment/lock/lock_system // lock system

/datum/spacepod/equipment/New(var/obj/spacepod/SP)
	..()
	if(istype(SP))
		my_atom = SP

/obj/item/spacepod_equipment
	name = "equipment"
	var/use_charge = 0 //Use charge battery for work
	var/obj/spacepod/my_atom
	var/occupant_mod = 0	// so any module can modify occupancy
	var/list/storage_mod = list("slots" = 0, "w_class" = 0)		// so any module can modify storage slots

/obj/item/spacepod_equipment/proc/removed(var/mob/user) // So that you can unload cargo when you remove the module
	return

/obj/item/spacepod_equipment/proc/action(atom/target)
	return

/obj/item/spacepod_equipment/proc/action_checks(atom/target)
	if(!target)
		return 0
	if(!my_atom)
		return 0
	if(!my_atom.battery.charge)
		return 0
	return 1
/*
///////////////////////////////////////
/////////Weapon System///////////////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/weaponry
	name = "pod weapon"
	desc = "You shouldn't be seeing this"
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "blank"
	var/obj/item/projectile/projectile_type
	var/shots_per = 1 //Don't set very high number. Or byond say you "Hello"
	var/shots_deviation = 0
	var/fuse = TRUE
	var/fire_sound
	var/fire_delay = 15
	var/fire_stop = FALSE
	var/auto_rel = 0

/obj/item/spacepod_equipment/weaponry/action(atom/target)
	if(!action_checks(target))
		return

	var/turf/curloc = my_atom.loc
	var/turf/targloc = get_turf(target)
	var/turf/firstloc
	var/turf/secondloc

	if(my_atom.dir == NORTH)
		firstloc = get_step(my_atom.loc, NORTH)
		secondloc = get_step(firstloc,EAST)
	if(my_atom.dir == SOUTH)
		firstloc = get_turf(my_atom)
		secondloc = get_step(firstloc,EAST)
	if(my_atom.dir == EAST)
		firstloc = get_step(my_atom.loc, EAST)
		secondloc = get_step(firstloc,NORTH)
	if(my_atom.dir == WEST)
		firstloc = get_turf(my_atom)
		secondloc = get_step(firstloc,NORTH)
	if(!curloc || !targloc)
		return
	if(my_atom.battery.charge < use_charge)
		playsound(my_atom, 'sound/weapons/empty.ogg', 50, 1)
		to_chat(my_atom.pilot, "<span class='warning'> Battery in [my_atom] is empty</span>")
		return
	if(fuse)
		playsound(my_atom, 'sound/weapons/empty.ogg', 50, 1)
		to_chat(my_atom.pilot, "<span class='notice'>Weapon fuse is toggle. Turn it off before shooting</span>")
		return
	if(fire_stop)
		to_chat(my_atom.pilot,"<span class='notice'> [src] is not ready to fire</span>")
		return

	my_atom.battery.charge -= use_charge
	my_atom.visible_message("<span class='warning'>[my_atom] fires [src]!</span>")
	to_chat(my_atom.pilot, "<span class='warning'>You fire [src]!</span>")
	for(var/i = 0, i < shots_per, i++)
		var/turf/aimloc = targloc
		var/P1
		var/P2
		if(shots_deviation)
			aimloc = locate(targloc.x+GaussRandRound(shots_deviation,1),targloc.y+GaussRandRound(shots_deviation,1),targloc.z)
		if(!aimloc || aimloc == curloc)
			break
		playsound(my_atom, fire_sound, 50, 1)
		P1 = new projectile_type(firstloc)
		P2 = new projectile_type(secondloc)
		FireWeapon(P1, target, aimloc)
		FireWeapon(P2, target, aimloc)
		sleep(2)

	if(!fire_stop)
		fire_stop = TRUE
		sleep(fire_delay)
		fire_stop = FALSE



/obj/item/spacepod_equipment/weaponry/proc/FireWeapon(atom/A, atom/target, turf/aimloc)
	var/obj/item/projectile/P = A
	P.shot_from = src
	P.original = target
	P.starting = P.loc
	P.current = P.loc
	P.firer = my_atom.pilot
	if(isbrain(my_atom.pilot))
		P.def_zone = ran_zone()
	else
		P.def_zone = check_zone(my_atom.pilot.zone_sel.selecting)
	P.yo = aimloc.y - P.loc.y
	P.xo = aimloc.x - P.loc.x
	if(aimloc != get_turf(target))
		P.process(aimloc)
	else
		P.process()


/obj/item/spacepod_equipment/weaponry/taser
	name = "disabler system"
	desc = "A weak taser system for space pods, fires disabler beams."
	icon_state = "weapon_taser"
	projectile_type = /obj/item/projectile/energy/electrode
	use_charge = 400
	fire_sound = 'sound/weapons/Taser.ogg'
	fire_delay = 5

/obj/item/spacepod_equipment/weaponry/burst_taser
	name = "burst taser system"
	desc = "A weak taser system for space pods, This one fires 4 at a time."
	icon_state = "weapon_burst_taser"
	projectile_type = /obj/item/projectile/energy/electrode
	use_charge = 1600
	shots_per = 4
	fire_sound = 'sound/weapons/Taser.ogg'
	fire_delay = 20

/obj/item/spacepod_equipment/weaponry/laser
	name = "laser system"
	desc = "A weak laser system for space pods, fires concentrated bursts of energy."
	icon_state = "weapon_laser"
	projectile_type = /obj/item/projectile/energy/laser
	use_charge = 600
	fire_sound = 'sound/weapons/Laser.ogg'
	fire_delay = 20

/obj/item/spacepod_equipment/weaponry/burst_laser
	name = "burst laser system"
	desc = "A weak laser system for space pods, fires concentrated bursts of energy. This one fires 4 at a time"
	icon_state = "weapon_burst_laser"
	projectile_type = /obj/item/projectile/energy/laser
	use_charge = 2400
	shots_per = 4
	fire_sound = 'sound/weapons/Laser.ogg'
	fire_delay = 30

/obj/item/spacepod_equipment/weaponry/automate
	name = "automate bullet system"
	desc = "A average automate bullet system for space pods, fires bullets rifle callibre."
	icon_state = "weapon_automate"
	projectile_type = /obj/item/projectile/bullet/rifle3
	use_charge = 150
	fire_sound = 'sound/weapons/Gunshot.ogg'
	fire_delay = 10

/obj/item/spacepod_equipment/weaponry/burst_automate
	name = "burst automate bullet system"
	desc = "A average automate bullet system for space pods, fires bullets rifle callibre. This one fires 4 at a time"
	icon_state = "weapon_burst_automate"
	projectile_type = /obj/item/projectile/bullet/rifle3
	use_charge = 600
	shots_per = 4
	fire_sound = 'sound/weapons/Gunshot.ogg'
	fire_delay = 25

// MINING LASERS
/obj/item/spacepod_equipment/weaponry/mining_laser_basic
	name = "weak mining laser system"
	desc = "A weak mining laser system for space pods, fires bursts of energy that cut through rock."
	icon = 'icons/goonstation/pods/ship.dmi'
	icon_state = "pod_taser"
	projectile_type = /obj/item/projectile/kinetic/pod
	use_charge = 300
	fire_delay = 10
	fire_sound = 'sound/weapons/Kenetic_accel.ogg'

/*
///////////////////////////////////////
/////////Misc. System///////////////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/misc
	name = "pod misc"
	desc = "You shouldn't be seeing this"
	icon = 'icons/goonstation/pods/ship.dmi'
	icon_state = "blank"
	var/enabled

/obj/item/spacepod_equipment/misc/tracker
	name = "\improper spacepod tracking system"
	desc = "A tracking device for spacepods."
	icon_state = "pod_locator"
	enabled = 0

/obj/item/spacepod_equipment/misc/tracker/attackby(obj/item/I as obj, mob/user as mob, params)
	if(isscrewdriver(I))
		if(enabled)
			enabled = 0
			user.show_message("<span class='notice'>You disable \the [src]'s power.")
			return
		enabled = 1
		user.show_message("<span class='notice'>You enable \the [src]'s power.</span>")
	else
		..()

/*
///////////////////////////////////////
/////////Cargo System//////////////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/cargo
	name = "pod cargo"
	desc = "You shouldn't be seeing this"
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "cargo_blank"
	var/obj/storage = null

/obj/item/spacepod_equipment/cargo/proc/passover(var/obj/item/I)
	return

/obj/item/spacepod_equipment/cargo/proc/unload() // called by unload verb
	if(storage)
		storage.forceMove(get_turf(my_atom))
		storage = null

/obj/item/spacepod_equipment/cargo/removed(var/mob/user) // called when system removed
	. = ..()
	unload()

// Ore System
/obj/item/spacepod_equipment/cargo/ore
	name = "spacepod ore storage system"
	desc = "An ore storage system for spacepods. Scoops up any ore you drive over."
	icon_state = "cargo_ore"

/*
/obj/item/spacepod_equipment/cargo/ore/passover(var/obj/item/I)
	if(storage && istype(I,/obj/item/stack/ore))
		I.forceMove(storage)
*/
// Crate System
/obj/item/spacepod_equipment/cargo/crate
	name = "spacepod crate storage system"
	desc = "A heavy duty storage system for spacepods. Holds one crate."
	icon_state = "cargo_crate"

/*
///////////////////////////////////////
/////////Secondary Cargo System////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/sec_cargo
	name = "secondary cargo"
	desc = "you shouldn't be seeing this"
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "blank"

// Passenger Seat
/obj/item/spacepod_equipment/sec_cargo/chair
	name = "passenger seat"
	desc = "A passenger seat for a spacepod."
	icon_state = "sec_cargo_chair"
	occupant_mod = 1

// Loot Box
/obj/item/spacepod_equipment/sec_cargo/loot_box
	name = "loot box"
	desc = "A small compartment to store valuables."
	icon_state = "sec_cargo_loot"
	storage_mod = list("slots" = 7, "w_class" = 14)

/*
///////////////////////////////////////
/////////Lock System///////////////////
///////////////////////////////////////
*/

/obj/item/spacepod_equipment/lock
	name = "pod lock"
	desc = "You shouldn't be seeing this"
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "blank"
	var/mode = 0
	var/id = null

// Key and Tumbler System
/obj/item/spacepod_equipment/lock/keyed
	name = "spacepod tumbler lock"
	desc = "A locking system to stop podjacking. This version uses a standalone key."
	icon_state = "lock_tumbler"
	var/static/id_source = 0
	var/terminated = FALSE


/obj/item/spacepod_equipment/lock/keyed/New()
	..()
	id = ++id_source

// The key
/obj/item/spacepod_key
	name = "spacepod key"
	desc = "A key for a spacepod lock."
	icon = 'icons/vehicles/spacepod.dmi'
	icon_state = "podkey"
	w_class = ITEM_SIZE_TINY
	var/id = 0

// Key - Lock Interactions
/obj/item/spacepod_equipment/lock/keyed/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/spacepod_key))
		var/obj/item/spacepod_key/key = I
		if(!key.id)
			key.id = id
			to_chat(user, "<span class='notice'>You grind the blank key to fit the lock.</span>")
		else
			to_chat(user, "<span class='warning'>This key is already ground!</span>")
	else
		..()