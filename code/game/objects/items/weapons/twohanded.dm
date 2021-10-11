#define DUALSABER_BLOCK_CHANCE_MODIFIER 1.2

/*
 * Fireaxe
 */
/obj/item/weapon/fireaxe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 10
	sharp = 1
	edge = 1
	w_class = SIZE_NORMAL
	slot_flags = SLOT_FLAGS_BACK
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	sweep_step = 5
	var/wielded = FALSE

/obj/item/weapon/fireaxe/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf, /obj/effect/effect/weapon_sweep)

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE

	SCB.can_sweep_call = CALLBACK(src, /obj/item/weapon/fireaxe.proc/can_sweep)
	SCB.can_spin_call = CALLBACK(src, /obj/item/weapon/fireaxe.proc/can_spin)
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)
	AddComponent(/datum/component/two_handed, FALSE, FALSE, FALSE, FALSE, 0, 40, 10, FALSE)
	AddComponent(/datum/component/swiping, SCB)

	hitsound = SOUNDIN_DESCERATION

/// triggered on wield of two handed item
/obj/item/weapon/fireaxe/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER
	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/weapon/fireaxe/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER
	wielded = FALSE

/obj/item/weapon/sledgehammer/update_icon()
	icon_state = "sledgehammer[wielded]"

/obj/item/weapon/fireaxe/proc/can_sweep(mob/user)
	return wielded

/obj/item/weapon/fireaxe/proc/can_spin(mob/user)
	return wielded

/obj/item/weapon/fireaxe/update_icon()
	icon_state = "fireaxe[wielded]"

/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/weapon/dualsaber
	var/reflect_chance = 0
	icon_state = "dualsaber0"
	name = "double-bladed energy sword"
	desc = "Handle with care."
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_TINY
	item_color = "green"
	var/hacked
	var/slicing
	var/wielded = FALSE
	var/wieldsound = 'sound/weapons/saberon.ogg'
	var/unwieldsound = 'sound/weapons/saberoff.ogg'
	var/hitsound_wielded = list('sound/weapons/blade1.ogg')
	flags = NOSHIELD
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = 1
	edge = 1
	can_embed = 0

	sweep_step = 2

/obj/item/weapon/dualsaber/atom_init()
	. = ..()
	reflect_chance = rand(50, 65)
	item_color = pick("red", "blue", "green", "purple","yellow","pink","black")
	switch(item_color)
		if("red")
			light_color = COLOR_RED
		if("blue")
			light_color = COLOR_BLUE
		if("green")
			light_color = COLOR_GREEN
		if("purple")
			light_color = COLOR_PURPLE
			light_power = 2
		if("yellow")
			light_color = COLOR_YELLOW
		if("pink")
			light_color = COLOR_PINK
		if("black")
			light_color = COLOR_GRAY

	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list()

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE

	SCB.can_sweep_call = CALLBACK(src, /obj/item/weapon/dualsaber.proc/can_swipe)
	SCB.can_spin_call = CALLBACK(src, /obj/item/weapon/dualsaber.proc/can_swipe)
	SCB.on_get_sweep_objects = CALLBACK(src, /obj/item/weapon/dualsaber.proc/get_sweep_objs)


	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)
	AddComponent(/datum/component/two_handed, FALSE, wieldsound, unwieldsound, hitsound_wielded, 0, 45, 3, FALSE)
	AddComponent(/datum/component/swiping, SCB)

/// triggered on wield of two handed item
/obj/item/weapon/dualsaber/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER
	wielded = TRUE
	set_light(2)
	w_class = SIZE_BIG

/// triggered on unwield of two handed item
/obj/item/weapon/dualsaber/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER
	wielded = FALSE
	slicing = FALSE
	set_light(0)
	w_class = initial(w_class)

/obj/item/weapon/dualsaber/proc/can_swipe(mob/user)
	return wielded

/obj/item/weapon/dualsaber/proc/get_sweep_objs(turf/start, obj/item/I, mob/user, list/directions, sweep_delay)
	var/list/directions_opposite = list()
	for(var/dir_ in directions)
		directions_opposite += turn(dir_, 180)

	var/list/sweep_objects = list()
	sweep_objects += new /obj/effect/effect/weapon_sweep(start, I, directions, sweep_delay)
	sweep_objects += new /obj/effect/effect/weapon_sweep(start, I, directions_opposite, sweep_delay)
	return sweep_objects

/obj/item/weapon/dualsaber/update_icon()
	if(wielded)
		icon_state = "dualsaber[item_color][wielded]"
	else
		icon_state = "dualsaber0"
	clean_blood()//blood overlays get weird otherwise, because the sprite changes.

/obj/item/weapon/dualsaber/attack(target, mob/living/user)
	..()
	if((CLUMSY in user.mutations) && (wielded) && prob(40))
		to_chat(user, "<span class='userdanger'> You twirl around a bit before losing your balance and impaling yourself on the [src].</span>")
		user.take_bodypart_damage(20, 25)
		return
	if(wielded && prob(50))
		spawn(0)
			for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
				user.set_dir(i)
				sleep(1)

/obj/item/weapon/dualsaber/Get_shield_chance()
	if(wielded && !slicing)
		return reflect_chance * DUALSABER_BLOCK_CHANCE_MODIFIER - 5
	else
		return 0

/obj/item/weapon/dualsaber/IsReflect(def_zone, hol_dir, hit_dir)
	return !slicing && wielded && prob(reflect_chance) && is_the_opposite_dir(hol_dir, hit_dir)

/obj/item/weapon/dualsaber/attackby(obj/item/I, mob/user, params)
	if(ismultitool(I))
		if(!hacked)
			hacked = TRUE
			to_chat(user,"<span class='warning'>2XRNBW_ENGAGE</span>")
			item_color = "rainbow"
			light_color = ""
			update_icon()
		else
			to_chat(user,"<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")
	else
		return ..()

/obj/item/weapon/dualsaber/afterattack(atom/target, mob/user, proximity, params)
	if(!istype(target,/obj/machinery/door/airlock) || slicing)
		return
	if(target.density && wielded && proximity)
		user.visible_message("<span class='danger'>[user] start slicing the [target] </span>")
		playsound(user, 'sound/items/Welder2.ogg', VOL_EFFECTS_MASTER)
		slicing = TRUE
		var/obj/machinery/door/airlock/D = target
		var/obj/effect/I = new /obj/effect/overlay/slice(D.loc)
		if(do_after(user, 450, target = D) && D.density && !(D.operating == -1))
			sleep(6)
			var/obj/structure/door_scrap/S = new /obj/structure/door_scrap(D.loc)
			var/iconpath = D.icon
			var/icon/IC = new(iconpath, "closed")
			IC.Blend(S.door, ICON_OVERLAY, 1, 1)
			IC.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
			S.icon = IC
			S.name = D.name
			S.name += " remains"
			qdel(D)
			qdel(IC)
			playsound(user, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
		slicing = FALSE
		qdel(I)

/obj/item/weapon/dualsaber/attack_self(mob/user)
	if(slicing)
		return
	..()

#undef DUALSABER_BLOCK_CHANCE_MODIFIER
