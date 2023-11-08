/* Weapons
 * Contains:
 *		Banhammer
 *		Sword
 *		Classic Baton
 *		Energy Blade
 *		Energy Axe
 *		Energy Shield
 */

/*
 * Banhammer
 */
/obj/item/weapon/banhammer/attack(mob/M, mob/user)
	to_chat(M, "<font color='red'><b> You have been banned FOR NO REISIN by [user]</b></font>")
	to_chat(user, "<font color='red'> You have <b>BANNED</b> [M]</font>")
	M.playsound_local(M, 'sound/effects/adminhelp.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/*
 * Sword
 */
/obj/item/weapon/melee/energy/sword/Get_shield_chance()
	if(active)
		return 40
	return 0

/obj/item/weapon/melee/energy/add_blood()
	return

/obj/item/weapon/melee/energy/sword/atom_init()
	. = ..()
	blade_color = pick("red","blue","green","purple","yellow","pink","black")
	switch(blade_color)
		if("red")
			light_color = COLOR_RED
		if("blue")
			light_color = COLOR_BLUE
		if("green")
			light_color = COLOR_GREEN
		if("purple")
			light_color = COLOR_PURPLE
		if("yellow")
			light_color = COLOR_YELLOW
		if("pink")
			light_color = COLOR_PINK
		if("black")
			light_color = COLOR_GRAY

/obj/item/weapon/melee/energy/sword/attack_self(mob/living/user)
	if (user.ClumsyProbabilityCheck(50))
		to_chat(user, "<span class='warning'>You accidentally cut yourself with [src].</span>")
		user.take_bodypart_damage(5, 5)
	active = !active
	if (active)
		qualities = list(
			QUALITY_KNIFE = 1
		)
		sharp = TRUE
		force = 30
		hitsound = list('sound/weapons/blade1.ogg')
		if(istype(src,/obj/item/weapon/melee/energy/sword/pirate))
			icon_state = "cutlass1"
		else
			icon_state = "sword[blade_color]"
		w_class = SIZE_SMALL
		playsound(user, 'sound/weapons/saberon.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
		set_light(2)
	else
		qualities = null
		sharp = FALSE
		force = 3
		flags = NOBLOODY
		hitsound = initial(hitsound)
		if(istype(src,/obj/item/weapon/melee/energy/sword/pirate))
			icon_state = "cutlass0"
		else
			icon_state = "sword0"
		w_class = SIZE_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
		set_light(0)

	update_inv_mob()
	add_fingerprint(user)

/obj/item/weapon/melee/energy/sword/on_enter_storage(obj/item/weapon/storage/S)
	..()
	if(active)
		attack_self(usr)

/*
 * Classic Baton
 */
/obj/item/weapon/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	slot_flags = SLOT_FLAGS_BELT
	force = 10

	sweep_step = 2

/obj/item/weapon/melee/classic_baton/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf, /obj/effect/effect/weapon_sweep)

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE

	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/melee/classic_baton/attack(mob/living/M, mob/living/user)
	if (user.ClumsyProbabilityCheck(50))
		to_chat(user, "<span class='warning'>You club yourself over the head.</span>")
		user.Stun(16)
		user.Weaken(16)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2 * force, BRUTE, BP_HEAD)
		else
			user.take_bodypart_damage(2 * force)
		return

	if (user.a_intent == INTENT_HARM)
		if(!..()) return
		playsound(src, pick(SOUNDIN_GENHIT), VOL_EFFECTS_MASTER)
		if (!(HULK in M.mutations))
			M.Stuttering(8)
		M.Stun(8)
		M.Weaken(8)
		user.visible_message("<span class='warning'><B>[M] has been beaten with \the [src] by [user]!</B></span>", blind_message = "<span class='warning'>You hear someone fall</span>")
	else
		playsound(src, 'sound/weapons/Genhit.ogg', VOL_EFFECTS_MASTER)
		M.Stun(5)
		M.Weaken(5)
		add_fingerprint(user)

		user.visible_message("<span class='warning'><B>[M] has been stunned with \the [src] by [user]!</B></span>", blind_message = "<span class='warning'>You hear someone fall</span>")
	M.log_combat(user, "attacked with [name] (INTENT: [uppertext(user.a_intent)])")

//Telescopic baton
/obj/item/weapon/melee/telebaton
	name = "telescopic baton"
	desc = "A compact yet rebalanced personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "telebaton_0"
	item_state = null
	slot_flags = SLOT_FLAGS_BELT
	w_class = SIZE_TINY
	force = 3
	var/on = 0

	sweep_step = 5

/obj/item/weapon/melee/telebaton/atom_init()
	. = ..()
	var/datum/swipe_component_builder/SCB = new
	SCB.interupt_on_sweep_hit_types = list(/turf, /obj/effect/effect/weapon_sweep)

	SCB.can_sweep = TRUE
	SCB.can_spin = TRUE

	SCB.can_push = TRUE

	SCB.can_pull = TRUE

	SCB.can_sweep_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/melee/telebaton, can_sweep))
	SCB.can_spin_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/melee/telebaton, can_spin))
	SCB.can_push_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/melee/telebaton, can_sweep_push))
	SCB.can_pull_call = CALLBACK(src, TYPE_PROC_REF(/obj/item/weapon/melee/telebaton, can_sweep_pull))
	AddComponent(/datum/component/swiping, SCB)

/obj/item/weapon/melee/telebaton/proc/can_sweep()
	return on

/obj/item/weapon/melee/telebaton/proc/can_spin()
	return on

/obj/item/weapon/melee/telebaton/proc/can_sweep_push()
	return on

/obj/item/weapon/melee/telebaton/proc/can_sweep_pull()
	return on

/obj/item/weapon/melee/telebaton/attack_self(mob/user)
	on = !on
	if(on)
		user.visible_message("<span class='warning'>With a flick of their wrist, [user] extends their telescopic baton.</span>",\
		"<span class='warning'>You extend the baton.</span>",\
		"You hear an ominous click.")
		icon_state = "telebaton_1"
		item_state = "telebaton"
		w_class = SIZE_SMALL
		force = 15//quite robust
		attack_verb = list("smacked", "struck", "slapped")
	else
		user.visible_message("<span class='notice'>[user] collapses their telescopic baton.</span>",\
		"<span class='notice'>You collapse the baton.</span>",\
		"You hear a click.")
		icon_state = "telebaton_0"
		item_state = null
		w_class = SIZE_TINY
		force = 3//not so robust now
		attack_verb = list("hit", "punched")

	update_inv_mob()
	playsound(src, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)
	add_fingerprint(user)

/obj/item/weapon/melee/telebaton/attack(mob/target, mob/living/user)
	if(on)
		if(user.ClumsyProbabilityCheck(50))
			to_chat(user, "<span class='warning'>You club yourself over the head.</span>")
			user.adjustHalLoss(70)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2 * force, BRUTE, BP_HEAD)
			else
				user.take_bodypart_damage(2 * force)
			return
		if(!isliving(target))
			return ..()
		var/mob/living/L = target
		var/target_armor = L.run_armor_check(user.get_targetzone(), MELEE)
		if(user.a_intent == INTENT_HELP && ishuman(target))
			var/mob/living/carbon/human/H = target
			H.apply_effect(35, AGONY, target_armor)
			playsound(src, 'sound/weapons/hit_metalic.ogg', VOL_EFFECTS_MASTER)
			user.do_attack_animation(H)
			H.visible_message("<span class='warning'>[user] hit [H] harmlessly with a telebaton.</span>")
			H.log_combat(user, "hit harmlessly with [name]")
			return
		if(..())
			L.apply_effect(30, AGONY, target_armor)
			playsound(src, pick(SOUNDIN_GENHIT), VOL_EFFECTS_MASTER)
			return
	else
		return ..()


/*
 *Energy Blade
 */
//Most of the other special functions are handled in their own files.

/obj/item/weapon/melee/energy/sword/green/atom_init()
	. = ..()
	blade_color = "green"
	light_color = COLOR_GREEN

/obj/item/weapon/melee/energy/sword/red/atom_init()
	. = ..()
	blade_color = "red"
	light_color = COLOR_RED

/obj/item/weapon/melee/energy/sword/blue/atom_init()
	. = ..()
	blade_color = "blue"
	light_color = COLOR_BLUE

/obj/item/weapon/melee/energy/sword/purple/atom_init()
	. = ..()
	blade_color = "purple"
	light_color = COLOR_PURPLE

/obj/item/weapon/melee/energy/sword/yellow/atom_init()
	. = ..()
	blade_color = "yellow"
	light_color = COLOR_YELLOW

/obj/item/weapon/melee/energy/sword/pink/atom_init()
	. = ..()
	blade_color = "pink"
	light_color = COLOR_PINK

/obj/item/weapon/melee/energy/sword/black/atom_init()
	. = ..()
	blade_color = "black"
	light_color = COLOR_GRAY


/obj/item/weapon/melee/energy/blade/atom_init()
	. = ..()
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/*
 * Energy Axe
 */

/obj/item/weapon/melee/energy/axe/attack_self(mob/user)
	src.active = !( src.active )
	if (src.active)
		to_chat(user, "<span class='notice'>The axe is now energised.</span>")
		src.force = 150
		src.icon_state = "axe1"
		src.w_class = SIZE_BIG
	else
		to_chat(user, "<span class='notice'>The axe can now be concealed.</span>")
		src.force = 40
		src.icon_state = "axe0"
		src.w_class = SIZE_BIG
	add_fingerprint(user)

	return


/*
 * Energy Shield
 */
/obj/item/weapon/shield/energy/Get_shield_chance()
	if(active)
		return block_chance
	return 0

/obj/item/weapon/shield/energy/attack_self(mob/living/user)
	if (user.ClumsyProbabilityCheck(50))
		to_chat(user, "<span class='danger'> You beat yourself in the head with [src].</span>")
		user.take_bodypart_damage(5)
	if(emp_cooldown >= world.time)
		to_chat(user, "<span class='userdanger'>[src] is recalibrating!</span>")
		return
	active = !active
	if(active)
		turn_on(user)
	else
		turn_off(user)
	add_fingerprint(user)

/obj/item/weapon/shield/energy/proc/turn_on(mob/living/user)
	force = 10
	w_class = SIZE_SMALL
	playsound(src, 'sound/weapons/saberon.ogg', VOL_EFFECTS_MASTER)
	to_chat(user, "<span class='notice'> [src] is now active.</span>")
	update_icon()

/obj/item/weapon/shield/energy/proc/turn_off(mob/living/user)
	force = 3
	w_class = SIZE_MINUSCULE
	playsound(src, 'sound/weapons/saberoff.ogg', VOL_EFFECTS_MASTER)
	update_icon()
	if(user)
		to_chat(user, "<span class='notice'> [src] can now be concealed.</span>")

/obj/item/weapon/shield/energy/update_icon()
	icon_state = "eshield[active]"
	update_inv_mob()
