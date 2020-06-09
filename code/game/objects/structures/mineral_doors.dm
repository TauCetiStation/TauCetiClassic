/obj/structure/mineral_door
	desc = "It opens and closes. What a surprise!"
	density = TRUE
	anchored = TRUE
	opacity = TRUE

	icon = 'icons/obj/doors/mineral_doors.dmi'

	var/operating_sound = 'sound/effects/stonedoor_openclose.ogg'
	var/close_state = TRUE
	var/isSwitchingStates = FALSE
	var/sheetAmount = 7
	var/health = 100

	var/sheetType

/obj/structure/mineral_door/atom_init()
	. = ..()
	update_nearby_tiles(need_rebuild = TRUE)

/obj/structure/mineral_door/Destroy()
	update_nearby_tiles()
	return ..()

/obj/structure/mineral_door/Bumped(atom/M)
	if(close_state)
		if(ismob(M))
			var/mob/user = M
			if(DoorChecks() && MobChecks(user))
				add_fingerprint(user)
				Open()
		else if(istype(M, /obj/mecha) && DoorChecks())
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

/obj/structure/mineral_door/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(air_group)
		return FALSE
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/mineral_door/proc/DoorChecks()
	return (!isSwitchingStates && anchored)

/obj/structure/mineral_door/proc/MobChecks(mob/user)
	if(!user.small)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			if(!C.handcuffed)
				return TRUE
		else
			return TRUE
	return FALSE

/obj/structure/mineral_door/proc/SwitchState()
	if(close_state)
		Open()
	else
		Close()

/obj/structure/mineral_door/proc/Open()
	isSwitchingStates = TRUE
	playsound(src, operating_sound, VOL_EFFECTS_MASTER)
	flick("[initial(icon_state)]_opening", src)
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
	else
		icon_state = "[initial(icon_state)]_open"

/obj/structure/mineral_door/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/pickaxe) && !(istype(src, /obj/structure/mineral_door/wood) || istype(src, /obj/structure/mineral_door/metal)))
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='notice'>You start digging the [name].</span>")
		if(W.use_tool(src, user, 50, volume = 100))
			to_chat(user, "<span class='notice'>You finished digging!</span>")
			Dismantle()

	else if(iswrench(W) && !istype(src, /obj/structure/mineral_door/resin))
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
		health -= W.force
		CheckHealth()
		return ..()

/obj/structure/mineral_door/proc/CheckHealth()
	if(health <= 0)
		Dismantle(TRUE)

/obj/structure/mineral_door/proc/Dismantle(devastated = FALSE)
	var/turf/T = get_turf(src)
	if(!devastated)
		for(var/i in 1 to sheetAmount)
			new sheetType(T)
	else
		for(var/i in 3 to sheetAmount)
			new sheetType(T)
	qdel(src)

/obj/structure/mineral_door/ex_act(severity = 1)
	switch(severity)
		if(1)
			Dismantle(TRUE)
		if(2)
			if(prob(20))
				Dismantle(TRUE)
			else
				health--
				CheckHealth()
		if(3)
			health -= 0.1
			CheckHealth()

/obj/structure/mineral_door/metal
	name = "metal door"
	icon_state = "metal"
	health = 300
	sheetType = /obj/item/stack/sheet/metal

/obj/structure/mineral_door/metal/attackby(obj/item/weapon/W, mob/user)
	if(iswelder(W))
		if(user.is_busy())
			return
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.use(0, user))
			to_chat(user, "<span class='notice'>You start dissassembling the [name] to the metal sheets.</span>")
			if(WT.use_tool(src, user, 60, volume = 100))
				to_chat(user, "<span class='notice'>You dissassembled the [name] to the metal sheets!</span>")
				Dismantle()
		else
			to_chat(user, "<span class='warning'>You need more welding fuel!</span>")
		return
	..()

/obj/structure/mineral_door/silver
	name = "silver door"
	icon_state = "silver"
	health = 300
	sheetType = /obj/item/stack/sheet/mineral/silver

/obj/structure/mineral_door/gold
	name = "golden door"
	icon_state = "gold"
	sheetType = /obj/item/stack/sheet/mineral/gold

/obj/structure/mineral_door/uranium
	name = "uranium door"
	icon_state = "uranium"
	health = 300
	light_range = 2
	sheetType = /obj/item/stack/sheet/mineral/uranium

/obj/structure/mineral_door/sandstone
	name = "sandstone door"
	icon_state = "sandstone"
	health = 50
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
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.use(0, user))
			TemperatureAct(100)
	..()

/obj/structure/mineral_door/transparent/phoron/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		TemperatureAct(exposed_temperature)

/obj/structure/mineral_door/transparent/phoron/proc/TemperatureAct(temperature)
	for(var/turf/simulated/floor/target_tile in range(2, loc))

		var/phoronToDeduce = temperature * 0.012

		target_tile.assume_gas("phoron", phoronToDeduce)
		target_tile.hotspot_expose(temperature, 400)

		health -= phoronToDeduce * 0.01
		CheckHealth()

/obj/structure/mineral_door/transparent/diamond
	name = "diamond door"
	icon_state = "diamond"
	health = 1000
	sheetType = /obj/item/stack/sheet/mineral/diamond

/obj/structure/mineral_door/wood
	name = "wooden door"
	icon_state = "wood"
	sheetType = /obj/item/stack/sheet/wood
	operating_sound = 'sound/effects/doorcreaky.ogg'

/obj/structure/mineral_door/wood/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/twohanded/fireaxe))
		if(user.is_busy())
			return
		to_chat(user, "<span class='notice'>You start cutting the [name] with the axe.</span>")
		if(W.use_tool(src, user, 40, volume = 100))
			to_chat(user, "<span class='notice'>You finished cutting the [name]!</span>")
			Dismantle()
		return
	..()

/obj/structure/mineral_door/resin
	icon = 'icons/mob/alien.dmi'
	operating_sound = 'sound/effects/attackblob.ogg'
	icon_state = "resin"
	health = 150
	var/close_delay = 100

/obj/structure/mineral_door/resin/atom_init()
	var/turf/T = get_turf(loc)
	if(T)
		T.blocks_air = TRUE
	. = ..()

/obj/structure/mineral_door/resin/Destroy()
	var/turf/T = get_turf(loc)
	if(T)
		T.blocks_air = FALSE
	return ..()

/obj/structure/mineral_door/resin/Bumped(atom/M)
	if(isxeno(M) && !isSwitchingStates)
		add_fingerprint(M)
		Open()

/obj/structure/mineral_door/resin/Open()
	..()
	addtimer(CALLBACK(src, .proc/TryToClose), close_delay)

/obj/structure/mineral_door/resin/proc/TryToClose()
	if(!isSwitchingStates && !close_state)
		Close()

/obj/structure/mineral_door/resin/Dismantle(devastated = FALSE)
	qdel(src)

/obj/structure/mineral_door/resin/CheckHealth()
	playsound(src, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
	..()

/obj/structure/mineral_door/resin/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	CheckHealth()

/obj/structure/mineral_door/resin/attack_hand(mob/user)
	if(isxenoadult(user) && user.a_intent == INTENT_HARM)
		user.do_attack_animation(src)
		user.SetNextMove(CLICK_CD_MELEE)
		health -= rand(40, 60)
		if(health <= 0)
			user.visible_message("<span class='danger'>[user] slices the [name] to pieces!</span>")
		else
			user.visible_message("<span class='danger'>[user] claws at the resin!</span>")
		CheckHealth()
	else if(isxeno(user) && !isSwitchingStates)
		add_fingerprint(user)
		SwitchState()
