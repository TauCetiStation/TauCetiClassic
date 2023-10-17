#define DUALSABER_BLOCK_CHANCE_MODIFIER 1.2

/obj/item/weapon/fireaxe
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 10
	sharp = 1
	edge = 1
	w_class = SIZE_SMALL
	flags_2 = CANT_BE_INSERTED
	slot_flags = SLOT_FLAGS_BACK
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	sweep_step = 5
	qualities = list(
		QUALITY_PRYING = 1,
		QUALITY_CUTTING = 1
	)

/obj/item/weapon/fireaxe/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf, /obj/effect/effect/weapon_sweep)

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE

	SCB.can_sweep_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/fireaxe, can_sweep))
	SCB.can_spin_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/fireaxe, can_spin))

	AddComponent(/datum/component/swiping, SCB)

	var/datum/twohanded_component_builder/TCB = new
	TCB.force_wielded = 40
	TCB.force_unwielded = 10
	TCB.icon_wielded = "fireaxe1"
	AddComponent(/datum/component/twohanded, TCB)

	hitsound = SOUNDIN_DESCERATION

/obj/item/weapon/fireaxe/proc/can_sweep(mob/user)
	return HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED)

/obj/item/weapon/fireaxe/proc/can_spin(mob/user)
	return HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED)

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
	var/hacked
	var/slicing
	var/wieldsound = 'sound/weapons/saberon.ogg'
	var/unwieldsound = 'sound/weapons/saberoff.ogg'
	var/hitsound_wielded = list('sound/weapons/blade1.ogg')
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = 1
	edge = 1
	can_embed = 0

	sweep_step = 2

	var/blade_color

/obj/item/weapon/dualsaber/atom_init()
	. = ..()
	reflect_chance = rand(50, 65)
	blade_color = pick("red", "blue", "green", "purple","yellow","pink","black")
	switch(blade_color)
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

	SCB.can_sweep_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/dualsaber, can_swipe))
	SCB.can_spin_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/dualsaber, can_swipe))
	SCB.on_get_sweep_objects = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/dualsaber, get_sweep_objs))
	AddComponent(/datum/component/swiping, SCB)

	var/datum/twohanded_component_builder/TCB = new
	TCB.wieldsound = wieldsound
	TCB.unwieldsound = unwieldsound
	TCB.attacksound = hitsound_wielded
	TCB.force_wielded = 45
	TCB.force_unwielded = 3
	TCB.on_wield = CALLBACK(src, PROC_REF(on_wield))
	TCB.on_unwield = CALLBACK(src, PROC_REF(on_unwield))
	AddComponent(/datum/component/twohanded, TCB)

/obj/item/weapon/dualsaber/proc/on_wield()
	set_light(2)
	w_class = SIZE_SMALL
	flags_2 |= CANT_BE_INSERTED
	return FALSE

/obj/item/weapon/dualsaber/proc/on_unwield()
	slicing = FALSE
	set_light(0)
	flags_2 &= ~CANT_BE_INSERTED
	w_class = initial(w_class)
	return FALSE

/obj/item/weapon/dualsaber/proc/can_swipe(mob/user)
	return HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED)

/obj/item/weapon/dualsaber/proc/get_sweep_objs(turf/start, obj/item/I, mob/user, list/directions, sweep_delay)
	var/list/directions_opposite = list()
	for(var/dir_ in directions)
		directions_opposite += turn(dir_, 180)

	var/list/sweep_objects = list()
	sweep_objects += new /obj/effect/effect/weapon_sweep(start, I, directions, sweep_delay)
	sweep_objects += new /obj/effect/effect/weapon_sweep(start, I, directions_opposite, sweep_delay)
	return sweep_objects

/obj/item/weapon/dualsaber/update_icon()
	if(HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED))
		icon_state = "dualsaber[blade_color]1"
	else
		icon_state = "dualsaber0"
	clean_blood()//blood overlays get weird otherwise, because the sprite changes.

/obj/item/weapon/dualsaber/attack(target, mob/living/user)
	..()
	if(user.ClumsyProbabilityCheck(40) && HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED))
		to_chat(user, "<span class='userdanger'> You twirl around a bit before losing your balance and impaling yourself on the [src].</span>")
		user.take_bodypart_damage(20, 25)
		return
	if(HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED) && prob(50))
		spawn(0)
			for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
				user.set_dir(i)
				sleep(1)

/obj/item/weapon/dualsaber/Get_shield_chance()
	if(HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED) && !slicing)
		return reflect_chance * DUALSABER_BLOCK_CHANCE_MODIFIER - 5
	else
		return 0

/obj/item/weapon/dualsaber/IsReflect(def_zone, hol_dir, hit_dir)
	return !slicing && HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED) && prob(reflect_chance) && is_the_opposite_dir(hol_dir, hit_dir)

/obj/item/weapon/dualsaber/attackby(obj/item/I, mob/user, params)
	if(ispulsing(I))
		if(!hacked)
			hacked = TRUE
			to_chat(user,"<span class='warning'>2XRNBW_ENGAGE</span>")
			blade_color = "rainbow"
			light_color = ""
			update_icon()
		else
			to_chat(user,"<span class='warning'>It's starting to look like a triple rainbow - no, nevermind.</span>")
	else
		return ..()

/obj/item/weapon/dualsaber/afterattack(atom/target, mob/user, proximity, params)
	if(!istype(target,/obj/machinery/door/airlock) || slicing)
		return
	if(target.density && HAS_TRAIT(src, TRAIT_DOUBLE_WIELDED) && proximity)
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
