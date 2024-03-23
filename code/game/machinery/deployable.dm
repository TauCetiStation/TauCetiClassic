/*
CONTAINS:

Deployable items
Barricades

for reference:

	access_security = 1
	access_brig = 2
	access_armory = 3
	access_forensics_lockers= 4
	access_medical = 5
	access_morgue = 6
	access_tox = 7
	access_tox_storage = 8
	access_genetics = 9
	access_engine = 10
	access_engine_equip= 11
	access_maint_tunnels = 12
	access_external_airlocks = 13
	access_emergency_storage = 14
	access_change_ids = 15
	access_ai_upload = 16
	access_teleporter = 17
	access_eva = 18
	access_heads = 19
	access_captain = 20
	access_all_personal_lockers = 21
	access_chapel_office = 22
	access_tech_storage = 23
	access_atmospherics = 24
	access_bar = 25
	access_janitor = 26
	access_crematorium = 27
	access_kitchen = 28
	access_robotics = 29
	access_rd = 30
	access_cargo = 31
	access_construction = 32
	access_chemistry = 33
	access_cargoshop = 34
	access_hydroponics = 35
	access_manufacturing = 36
	access_library = 37
	access_lawyer = 38
	access_virology = 39
	access_cmo = 40
	access_qm = 41
	FREE SPACE = 42
	access_clown = 43
	access_mime = 44

*/


//Barricades, maybe there will be a metal one later...
/obj/structure/barricade
	anchored = TRUE
	density = TRUE
	max_integrity = 100
	resistance_flags = CAN_BE_HIT
	layer = ABOVE_WINDOW_LAYER

/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	anchored = TRUE
	density = TRUE

/obj/structure/barricade/wooden/deconstruct(disassembled)
	new /obj/item/stack/sheet/wood(loc)
	new /obj/item/stack/sheet/wood(loc)
	new /obj/item/stack/sheet/wood(loc)
	return ..()

/obj/structure/barricade/wooden/run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir)
	switch(damage_type)
		if(BRUTE)
			return damage_amount * 0.75
		if(BURN)
			return damage_amount

/obj/structure/barricade/wooden/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/sheet/wood))
		user.SetNextMove(CLICK_CD_INTERACT)
		if(get_integrity() < max_integrity && !user.is_busy())
			visible_message("<span class='warning'>[user] begins to repair \the [src]!</span>")
			if(W.use_tool(src, user, 2 SECONDS, volume = 50))
				update_integrity(max_integrity)
				var/obj/item/stack/sheet/wood/wood = W
				wood.use(1)
				visible_message("<span class='warning'>[user] repairs \the [src]!</span>")
				return

	return ..()

/obj/structure/barricade/wooden/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			take_damage(33, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(16, BRUTE, BOMB)

/obj/structure/barricade/wooden/CanPass(atom/movable/mover, turf/target, height=0)//So bullets will fly over and stuff.
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

//Peacekeeper wall
/obj/structure/barricade/bubble
	name = "bubble barricade"
	desc = "A fragile energy field that blocks movement. Excels at blocking lethal projectiles."
	icon = 'icons/effects/effects.dmi'
	icon_state = "bubble"
	max_integrity = 7
	can_block_air = TRUE

/obj/structure/barricade/bubble/atom_init()
	. = ..()
	global.peacekeeper_shields_count++

/obj/structure/barricade/bubble/CanPass(atom/movable/mover, turf/target, height=0) //make robots can pass
	if(isrobot(mover))
		return TRUE
	return FALSE

/obj/structure/barricade/bubble/Destroy()
	global.peacekeeper_shields_count--
	return ..()

//Actual Deployable machinery stuff

/obj/machinery/deployable
	name = "deployable"
	desc = "deployable"
	icon = 'icons/obj/objects.dmi'
	req_access = list(access_security)//I'm changing this until these are properly tested./N

/obj/machinery/deployable/barrier
	name = "deployable barrier"
	desc = "A deployable barrier. Swipe your ID card to lock/unlock it."
	icon = 'icons/obj/objects.dmi'
	anchored = FALSE
	density = TRUE
	icon_state = "barrier0"
	max_integrity = 100
	var/locked = 0.0
//	req_access = list(access_maint_tunnels)

/obj/machinery/deployable/barrier/atom_init()
	. = ..()
	icon_state = "barrier[locked]"

/obj/machinery/deployable/barrier/deconstruct(disassembled)
	explode()

/obj/structure/barricade/barrier/run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir)
	switch(damage_type)
		if(BRUTE)
			return damage_amount * 0.5
		if(BURN)
			return damage_amount * 0.75

/obj/machinery/deployable/barrier/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/card/id))
		if(allowed(user))
			if(emagged < 2.0)
				locked = !locked
				anchored = !anchored
				icon_state = "barrier[locked]"
				to_chat(user, "Barrier lock toggled [locked ? "on" : "off"].")
				return
			else
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				visible_message("<span class='warning'>BZZzZZzZZzZT</span>")
				return
		return
	else if (iswrenching(W))
		user.SetNextMove(CLICK_CD_INTERACT)
		if (get_integrity() < max_integrity || emagged)
			update_integrity(max_integrity)
			emagged = 0
			req_access = list(access_security)
			visible_message("<span class='warning'>[user] repairs \the [src]!</span>")
			return
	return ..()

/obj/machinery/deployable/barrier/emag_act(mob/user)
	if (src.emagged == 0)
		src.emagged = 1
		src.req_access = list()
		to_chat(user, "You break the ID authentication lock on \the [src].")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(2, 1, src)
		s.start()
		visible_message("<span class='warning'>BZZzZZzZZzZT</span>")
		return TRUE
	else if (src.emagged == 1)
		src.emagged = 2
		to_chat(user, "You short out the anchoring mechanism on \the [src].")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(2, 1, src)
		s.start()
		visible_message("<span class='warning'>BZZzZZzZZzZT</span>")
		return TRUE

/obj/machinery/deployable/barrier/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			explode()
		if(EXPLODE_HEAVY)
			take_damage(50, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(25, BRUTE, BOMB)

/obj/machinery/deployable/barrier/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	if(prob(50/severity))
		locked = !locked
		anchored = !anchored
		icon_state = "barrier[src.locked]"

/obj/machinery/deployable/barrier/CanPass(atom/movable/mover, turf/target, height=0)//So bullets will fly over and stuff.
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/machinery/deployable/barrier/proc/explode()

	visible_message("<span class='warning'><B>[src] blows apart!</B></span>")
	var/turf/Tsec = get_turf(src)

/*	var/obj/item/stack/rods =*/
	new /obj/item/stack/rods(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(3, 1, src)
	s.start()

	explosion(src.loc,-1,-1,0)
	if(src)
		qdel(src)
