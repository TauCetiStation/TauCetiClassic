/obj/structure/mineral_door
	desc = "It opens and closes. What a surprise!"
	density = TRUE
	anchored = TRUE
	opacity = TRUE
	can_block_air = TRUE

	icon = 'icons/obj/doors/mineral_doors.dmi'

	var/operating_sound = 'sound/effects/stonedoor_openclose.ogg'
	var/close_state = TRUE
	var/isSwitchingStates = FALSE
	var/sheetAmount = 7
	var/can_unwrench = TRUE

	var/sheetType

	max_integrity = 100
	resistance_flags = CAN_BE_HIT

/obj/structure/mineral_door/atom_init()
	. = ..()
	update_nearby_tiles()

/obj/structure/mineral_door/Destroy()
	update_nearby_tiles()
	return ..()

/obj/structure/mineral_door/Bumped(atom/M)
	if(close_state)
		if(ismob(M))
			if(DoorChecks() && MobChecks(M))
				add_fingerprint(M)
				Open()
		else if(istype(M, /obj/mecha))
			if(DoorChecks() && MechChecks(M))
				Open()

/obj/structure/mineral_door/attack_ai(mob/user)
	if(isrobot(user) && get_dist(user, src) <= 1)
		return attack_hand(user)

/obj/structure/mineral_door/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/mineral_door/attack_hand(mob/user)
	if(DoorChecks() && MobChecks(user))
		add_fingerprint(user)
		SwitchState()

/obj/structure/mineral_door/c_airblock(turf/other)
	return ..() | ZONE_BLOCKED

/obj/structure/mineral_door/CanPass(atom/movable/mover, turf/target, height = 0)
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/mineral_door/proc/DoorChecks()
	return (!isSwitchingStates && anchored)

/obj/structure/mineral_door/proc/MobChecks(mob/user)
	if(user.w_class >= SIZE_SMALL)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			if(!C.handcuffed)
				return TRUE
		else
			return TRUE
	return FALSE

/obj/structure/mineral_door/proc/MechChecks(obj/mecha/user)
	return TRUE

/obj/structure/mineral_door/proc/SwitchState()
	if(close_state)
		Open()
	else
		Close()

/obj/structure/mineral_door/proc/Open()
	isSwitchingStates = TRUE
	playsound(src, operating_sound, VOL_EFFECTS_MASTER)
	flick("[initial(icon_state)]_opening", src)
	change_alt_apperance("_opening")
	sleep(10)
	density = FALSE
	set_opacity(FALSE)
	close_state = FALSE
	update_icon()
	isSwitchingStates = FALSE
	update_nearby_tiles()

/obj/structure/mineral_door/proc/Close()
	isSwitchingStates = TRUE
	playsound(src, operating_sound, VOL_EFFECTS_MASTER)
	flick("[initial(icon_state)]_closing", src)
	change_alt_apperance("_closing")
	sleep(10)
	density = TRUE
	set_opacity(TRUE)
	close_state = TRUE
	update_icon()
	isSwitchingStates = FALSE
	update_nearby_tiles()

/obj/structure/mineral_door/update_icon()
	if(close_state)
		icon_state = initial(icon_state)
		change_alt_apperance("")
	else
		icon_state = "[initial(icon_state)]_open"
		change_alt_apperance("_open")

/obj/structure/mineral_door/proc/change_alt_apperance(icon_state_postfix)
	if(alternate_appearances)
		for(var/name in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/basic/AA = alternate_appearances[name]
			if(!AA.alternate_obj || !istype(AA.alternate_obj, /obj/structure/mineral_door))
				continue
			AA.theImage.icon_state = "[initial(AA.alternate_obj.icon_state)][icon_state_postfix]"

/obj/structure/mineral_door/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/pickaxe) && !(istype(src, /obj/structure/mineral_door/wood) || istype(src, /obj/structure/mineral_door/metal)))
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='notice'>You start digging the [name].</span>")
		if(W.use_tool(src, user, 50, volume = 100))
			to_chat(user, "<span class='notice'>You finished digging!</span>")
			deconstruct(TRUE)

	else if(iswrenching(W) && can_unwrench)
		if(user.is_busy(src))
			return
		if(anchored)
			to_chat(user, "<span class='notice'>You start dissassembling the [name].</span>")
			if(W.use_tool(src, user, 40, volume = 100))
				to_chat(user, "<span class='notice'>You dissassembled the [name]!</span>")
				anchored = FALSE
				name = "disassembled [name]"
				desc = "Needs assembly."
				icon_state = "[initial(icon_state)]_disassembled"
				density = FALSE
				set_opacity(FALSE)
		else
			to_chat(user, "<span class='notice'>You start assembling the [name]!</span>")
			if(W.use_tool(src, user, 40, volume = 100))
				to_chat(user, "<span class='notice'>You assembled the [name]!</span>")
				anchored = TRUE
				name = initial(name)
				desc = initial(desc)
				density = TRUE
				icon_state = initial(icon_state)
				if(!istype(src, /obj/structure/mineral_door/transparent))
					set_opacity(TRUE)

	else
		..()

/obj/structure/mineral_door/deconstruct(disassembled)
	if(flags & NODECONSTRUCT || !sheetType)
		return ..()
	var/turf/T = get_turf(src)
	for(var/i in (disassembled ? 1 : 3) to sheetAmount)
		new sheetType(T)
	..()

/obj/structure/mineral_door/metal
	name = "metal door"
	icon_state = "metal"
	max_integrity = 300
	sheetType = /obj/item/stack/sheet/metal

/obj/structure/mineral_door/metal/attackby(obj/item/weapon/W, mob/user)
	if(iswelding(W))
		if(user.is_busy())
			return
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.use(0, user))
			to_chat(user, "<span class='notice'>You start dissassembling the [name] to the metal sheets.</span>")
			if(WT.use_tool(src, user, 60, volume = 100))
				to_chat(user, "<span class='notice'>You dissassembled the [name] to the metal sheets!</span>")
				deconstruct(TRUE)
		else
			to_chat(user, "<span class='warning'>You need more welding fuel!</span>")
		return

/obj/structure/mineral_door/silver
	name = "silver door"
	icon_state = "silver"
	max_integrity = 300
	sheetType = /obj/item/stack/sheet/mineral/silver

/obj/structure/mineral_door/gold
	name = "golden door"
	icon_state = "gold"
	sheetType = /obj/item/stack/sheet/mineral/gold

/obj/structure/mineral_door/uranium
	name = "uranium door"
	icon_state = "uranium"
	max_integrity = 300
	light_range = 2
	sheetType = /obj/item/stack/sheet/mineral/uranium

/obj/structure/mineral_door/sandstone
	name = "sandstone door"
	icon_state = "sandstone"
	max_integrity = 50
	sheetType = /obj/item/stack/sheet/mineral/sandstone

/obj/structure/mineral_door/transparent
	opacity = FALSE

/obj/structure/mineral_door/transparent/Close()
	..()
	opacity = FALSE

/obj/structure/mineral_door/transparent/phoron
	name = "phoron door"
	icon_state = "phoron"
	sheetType = /obj/item/stack/sheet/mineral/phoron

/obj/structure/mineral_door/transparent/phoron/attackby(obj/item/weapon/W, mob/user)
	if(iswelding(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.use(0, user))
			TemperatureAct(100)
	..()

/obj/structure/mineral_door/transparent/phoron/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		TemperatureAct(exposed_temperature)

/obj/structure/mineral_door/transparent/phoron/proc/TemperatureAct(temperature)
	var/phoronToDeduce = temperature * 0.012
	var/tiles = 0
	for(var/turf/simulated/floor/target_tile in range(2, loc))
		tiles++
		target_tile.assume_gas("phoron", phoronToDeduce)
		target_tile.hotspot_expose(temperature, 400)
	take_damage(tiles * phoronToDeduce * 0.01, BURN, FIRE, FALSE)

/obj/structure/mineral_door/transparent/diamond
	name = "diamond door"
	icon_state = "diamond"
	max_integrity = 1000
	sheetType = /obj/item/stack/sheet/mineral/diamond

/obj/structure/mineral_door/wood
	name = "wooden door"
	icon_state = "wood"
	sheetType = /obj/item/stack/sheet/wood
	operating_sound = 'sound/effects/doorcreaky.ogg'

/obj/structure/mineral_door/wood/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/fireaxe))
		if(user.is_busy())
			return
		to_chat(user, "<span class='notice'>You start cutting the [name] with the axe.</span>")
		if(W.use_tool(src, user, 40, volume = 100))
			to_chat(user, "<span class='notice'>You finished cutting the [name]!</span>")
			deconstruct(TRUE)
		return
	..()

/obj/structure/mineral_door/resin
	icon = 'icons/mob/alien.dmi'
	operating_sound = 'sound/effects/attackblob.ogg'
	icon_state = "resin"
	max_integrity = 250
	can_unwrench = FALSE
	var/close_delay = 100

/obj/structure/mineral_door/resin/c_airblock(turf/other)
	return BLOCKED

/obj/structure/mineral_door/resin/MobChecks(mob/user)
	return isxeno(user)

/obj/structure/mineral_door/resin/MechChecks(obj/mecha/user)
	return FALSE

/obj/structure/mineral_door/resin/Open()
	..()
	addtimer(CALLBACK(src, PROC_REF(TryToClose)), close_delay)

/obj/structure/mineral_door/resin/proc/TryToClose()
	if(!isSwitchingStates && !close_state)
		Close()

/obj/structure/mineral_door/resin/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/mineral_door/resin/attack_alien(mob/living/carbon/xenomorph/humanoid/user)
	if(isxenoadult(user) && user.a_intent == INTENT_HARM)
		attack_generic(user, 50, BRUTE, MELEE)
		if(QDELING(src))
			user.visible_message("<span class='danger'>[user] slices the [name] to pieces!</span>")
		else
			user.visible_message("<span class='danger'>[user] claws at the resin!</span>")
	else if(!isSwitchingStates)
		add_fingerprint(user)
		SwitchState()
