/obj/effect/proc_holder/spell/in_hand
	name = "Destroying Spells"
	invocation_type = "none"
	range = 1
	school = "conjuration"
	clothes_req = 1
	var/summon_path = /obj/item/weapon/magic

/obj/effect/proc_holder/spell/in_hand/Click()
	if(cast_check())
		cast()
	return 1

/obj/effect/proc_holder/spell/in_hand/cast_check(skipcharge = 0, mob/user = usr)
	return (!user.lying && ..())

/obj/effect/proc_holder/spell/in_hand/cast(mob/living/carbon/human/user = usr)
	if(!istype(user) || user.lying)
		return

	if(!user.is_in_hands(summon_path))
		user.drop_item()
		var/obj/GUN = new summon_path(src)
		user.put_in_active_hand(GUN)

/obj/item/weapon/magic
	name = "MAGIC BITCH"
	icon = 'icons/obj/wizard.dmi'
	flags = ABSTRACT | DROPDEL

	var/obj/effect/proc_holder/spell/Spell
	var/proj_path = /obj/item/projectile/magic
	var/drop_activate_recharge = TRUE
	var/uses = 1
	var/invoke
	var/s_fire
	var/touch_spell = FALSE // if true calls cast_touch() in afterattack() which stands for touch type spells.
	var/can_powerup = FALSE // attack_self() boosts level for such spells.
	var/max_power = 1       // max level of spell when used in combination with can_powerup or what ever you want to use this for.
	var/power_of_spell = 1  // current power of this spell.

/obj/item/weapon/magic/atom_init()
	. = ..()
	if(istype(loc, /obj/effect/proc_holder/spell))
		Spell = loc
		Spell.charge_max = initial(Spell.charge_max) // Incase spell has variable charge time, so we need to reset its CD back to normal.
	update_icon()

/obj/item/weapon/magic/afterattack(atom/target, mob/user, proximity, params)
	if(user.incapacitated() || user.lying)
		return FALSE

	if(!touch_spell)
		var/turf/U = get_turf(user)
		var/turf/T = get_turf(target)
		if(U == T)
			return
		if(!cast_throw(target, user))
			return FALSE
	else
		if(!cast_touch(target, user))
			return FALSE

	if(s_fire)
		playsound(user, s_fire, VOL_EFFECTS_MASTER)
	if(invoke)
		user.say(invoke)

	return TRUE

/obj/item/weapon/magic/proc/cast_touch(atom/A, mob/living/user) // dont forget to call parent inside child procs using . = ..() right after required checks if cast succeeded
	return spell_use(user)

/obj/item/weapon/magic/proc/cast_throw(atom/A, mob/living/user) // dont forget to call parent inside child procs using . = ..() right after required checks if cast succeeded
	. = spell_use(user)
	if(.)
		var/obj/item/projectile/P = new proj_path(user.loc, power_of_spell)
		P.Fire(A, user)

/obj/item/weapon/magic/attack_self(mob/user)
	if(user.is_busy())
		return FALSE
	if(can_powerup && power_of_spell < max_power)
		if(!do_after(user, 10, null, user,TRUE))
			return FALSE
		power_of_spell++
		//to_chat(user, "<span class'notice'>[src] power has grown up!</span>") much text, so informative, very spam, wow! but i'l leave that anyway.
		update_icon()
		return TRUE

/obj/item/weapon/magic/proc/spell_use(mob/living/user)
	if(uses <= 0)
		return FALSE

	uses--

	if(uses <= 0)
		user.drop_item()

	return TRUE

/obj/item/weapon/magic/dropped(mob/user)
	if(Spell)
		if(uses == initial(uses))                        // When we did nothing with spell.
			Spell.charge_max = initial(Spell.charge_max) // Incase spell has variable charge time.
			Spell.revert_cast()
		else if(drop_activate_recharge)
			INVOKE_ASYNC(Spell, .obj/effect/proc_holder/spell/proc/start_recharge)
		Spell = null
	return ..()

///////////////////////////////////////////
///////////////////////////////////////////
///////////////////////////////////////////

/obj/effect/proc_holder/spell/in_hand/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."
	school = "evocation"
	action_icon_state = "fireball"
	summon_path = /obj/item/weapon/magic/fireball
	charge_max = 200

/obj/item/weapon/magic/fireball
	name = "Fireball"
	invoke = "ONI SOMA"
	icon_state = "fireball"
	s_fire = 'sound/magic/Fireball.ogg'
	proj_path = /obj/item/projectile/magic/fireball

/obj/item/projectile/magic/fireball
	name = "bolt of fireball"
	icon_state = "fireball"
	damage = 10
	damage_type = BRUTE
	nodamage = 0

/obj/item/projectile/magic/fireball/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(isliving(target))
		var/mob/living/M = target
		M.fire_act()
		M.adjust_fire_stacks(5)
	explosion(get_turf(target), 1)
	return ..()

//////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/in_hand/tesla
	name = "Lightning Bolt"
	desc = "Fire a high powered lightning bolt at your foes!"
	school = "evocation"
	charge_max = 400
	clothes_req = 1
	action_icon_state = "lightning"
	summon_path = /obj/item/weapon/magic/tesla

/obj/item/weapon/magic/tesla
	name = "Lighting Ball"
	invoke ="UN'LTD P'WAH"
	icon_state = "teslaball"
	proj_path = /obj/item/projectile/magic/lightning
	s_fire = 'sound/magic/lightningbolt.ogg'

/obj/item/projectile/magic/lightning
	name = "lightning bolt"
	icon_state = "tesla_projectile"
	damage = 15
	damage_type = BURN
	nodamage = 0

/obj/item/projectile/magic/lightning/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	..()
	tesla_zap(src, 5, 15000)
	qdel(src)

/////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/in_hand/arcane_barrage
	name = "Arcane Barrage"
	desc = "Fire a torrent of arcane energy at your foes with this (powerful) spell. Requires both hands free to use. Learning this spell makes you unable to learn Lesser Summon Gun."
	charge_max = 600
	action_icon_state = "arcane_barrage"
	summon_path = /obj/item/weapon/magic/arcane_barrage


/obj/item/weapon/magic/arcane_barrage
	name = "arcane barrage"
	desc = "Pew Pew Pew"
	s_fire = 'sound/weapons/guns/gunpulse_emitter.ogg'
	icon_state = "arcane_barrage"
	item_state = "arcane_barrage"
	uses = 30
	proj_path = /obj/item/projectile/magic/Arcane_barrage

/obj/item/weapon/magic/arcane_barrage/afterattack(atom/target, mob/user, proximity, params)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	if(!..())
		return
	if(uses > 0)
		var/obj/item/weapon/magic/arcane_barrage/Arcane = new type(Spell)
		Arcane.uses = uses
		drop_activate_recharge = FALSE
		C.drop_item()
		C.swap_hand()
		C.drop_item()
		C.put_in_hands(Arcane)
		user.SetNextMove(CLICK_CD_INTERACT)
	else
		C.drop_item()

/obj/item/weapon/magic/arcane_barrage/dropped(mob/user)
	if(drop_activate_recharge && Spell && uses != initial(uses))
		Spell.charge_counter = Spell.charge_max / initial(uses) * uses
	return ..()

/obj/item/projectile/magic/Arcane_barrage
	name = "arcane barrage"
	icon_state = "arcane_bolt"
	damage = 20
	nodamage = 0
	flag = "laser"
	damage_type = BURN

//////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/in_hand/res_touch
	name = "Resurrection Touch"
	desc = "Resurrects a dead player. Cannot be used on ADMINs, robbutts or bunnies."
	school = "evocation"
	action_icon_state = "res_touch"
	summon_path = /obj/item/weapon/magic/res_touch
	charge_max = 5 MINUTES
	clothes_req = FALSE

/obj/item/weapon/magic/res_touch
	name = "resurrection"
	invoke = "AN CORP"
	icon_state = "resurrection"
	touch_spell = TRUE

/obj/item/weapon/magic/res_touch/cast_touch(mob/living/L, mob/living/carbon/user)
	set waitfor = FALSE // this proc has some sleeps, and we dont want them to lock anything.

	if(!istype(user) || !istype(L))
		return FALSE

	if(L.stat != DEAD || issilicon(L))
		return FALSE

	. = ..() // spell cast has been succeeded, we must call parent right now to subtract uses and what ever it wants to do, especially before sleep().

	user.adjustHalLoss(101) // much power, such spell, wow!
	user.emote("scream")

	var/old_loc = L.loc

	var/atom/movable/overlay/animation = new( L.loc )
	animation.icon = icon
	animation.icon_state = icon_state
	animation.pixel_y = 32
	animation.alpha = 0
	animation.layer = LIGHTING_LAYER + 1
	animation.plane = LIGHTING_PLANE + 1

	animate(animation, alpha = 255, time = 10)
	sleep(10)

	playsound(animation, 'sound/magic/resurrection_cast.ogg', VOL_EFFECTS_MASTER)
	animate(animation, pixel_y = -5, time = 25, easing = SINE_EASING)
	sleep(25)

	playsound(animation, 'sound/magic/resurrection_end.ogg', VOL_EFFECTS_MASTER)
	var/matrix/Mx = matrix()
	Mx.Scale(0)
	animate(animation, transform = Mx, time = 5)
	sleep(5)

	qdel(animation)

	if(old_loc != L.loc) // a good fail effect would be a nice idea.
		return

	L.revive()

	if(!L.ckey || !L.mind)
		for(var/mob/dead/observer/ghost in observer_list)
			if(L.mind == ghost.mind)
				ghost.reenter_corpse()
				break

	to_chat(L, "<span class='notice'>You rise with a start, you're alive!!!</span>")

//////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/in_hand/heal
	name = "Heal"
	desc = "Heals physically and mentally. Sometimes target may recieve double effect at lower levels. Target must be alive. \
		<br>Can be powered up seven times (click spell in hand). Each level provides different effect, while also raises spell cooldown. 1 to 5 can only be used by touching target \
		<br>1 to 3 heals \
		<br>4 cures any virus, but heals alot less \
		<br>5 cleans from any mutations, but heals alot less \
		<br>6 heals target for a great amount, but cannot be used on yourself. \
		<br>7 regenerates target limbs which fully recovers them, but for everything else effect is greatly reduced."
	school = "evocation"
	action_icon_state = "heal"
	summon_path = /obj/item/weapon/magic/heal_touch
	charge_max = 20 SECONDS
	clothes_req = FALSE

/obj/item/weapon/magic/heal_touch
	name = "healing touch"
	invoke = "In Mani"
	icon_state = "heal_"
	item_state = "healing"

	s_fire = 'sound/magic/heal.ogg'
	proj_path = /obj/item/projectile/magic/healing_ball

	touch_spell = TRUE
	can_powerup = TRUE
	max_power = 7

/obj/item/weapon/magic/heal_touch/attack_self(mob/user)
	if(!..())
		return

	Spell.charge_max = initial(Spell.charge_max) * power_of_spell // 20 - 140 (2:20)

	var/level_info = "<b>level [power_of_spell]</b> [src] now"
	switch(power_of_spell)
		if(2 to 3)
			to_chat(user, "<span class='notice'>[level_info] <b>heals</b>.</span>")
		if(4)
			to_chat(user, "<span class='notice'>[level_info] <b>cures</b> any <b>virus</b>.</span>")
		if(5)
			to_chat(user, "<span class='notice'>[level_info] <b>cleans</b> from any <b>mutations</b>.</span>")
		if(6)
			touch_spell = FALSE
			name = "healing ball"
			invoke = "In Vas Mani"
			to_chat(user, "<span class='notice'>[level_info] <b>heals</b> and can be <b>thrown</b></span>")
		if(7)
			name = "regeneration healing ball"
			invoke = "In Vas An Mani"
			to_chat(user, "<span class='notice'>[level_info] <b>regenerates limbs</b> but heals a lot less and can be <b>thrown</b></span>")

/obj/item/weapon/magic/heal_touch/update_icon()
	icon_state = initial(icon_state) + "[power_of_spell]"

/obj/item/weapon/magic/heal_touch/cast_throw(atom/A, mob/living/user)
	if(A == user)
		return FALSE
	else
		return ..()

/obj/item/weapon/magic/heal_touch/cast_touch(mob/living/L, mob/living/carbon/user)
	if(!istype(user) || !istype(L))
		return FALSE

	if(L.stat == DEAD || issilicon(L))
		return FALSE

	. = ..()

	var/hamt = -20 * power_of_spell
	if(prob(power_of_spell)) // critical hit!!
		hamt *= 2

	switch(power_of_spell)
		if(4)
			hamt *= 0.15
			L.cure_all_viruses()
		if(5)
			hamt *= 0.10
			L.remove_any_mutations()

	L.apply_damages(hamt, hamt, hamt, hamt, hamt, hamt)
	L.apply_effects(hamt, hamt, hamt, hamt, hamt, hamt, hamt, hamt)

/obj/item/projectile/magic/healing_ball
	name = "healing ball"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "heal_"
	damage = 0
	damage_type = OXY
	nodamage = 1
	flag = "magic"

/obj/item/projectile/magic/healing_ball/atom_init()
	. = ..()
	icon_state = initial(icon_state) + "[power_of_spell]"

/obj/item/projectile/magic/healing_ball/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(!isliving(target) || issilicon(target))
		return
	var/mob/living/L = target
	if(L.stat == DEAD)
		return

	var/hamt = -30 * power_of_spell // level 6 = 180 || level 7 = 31.5 (cause of reduction)
	var/reduced_heal = (power_of_spell == 7)
	if(reduced_heal)
		hamt *= 0.15 // healing everything 85% less, because most of healing power goes into regeneration of limbs which also full heals them.
		L.restore_all_bodyparts()
		L.regenerate_icons()

	L.apply_damages(reduced_heal ? 0 : hamt, reduced_heal ? 0 : hamt, hamt, hamt, hamt, hamt) // zero is for brute and burn in case of restoring bodyparts, because no point to heal them, since body parts restoration does that.
	L.apply_effects(hamt, hamt, hamt, hamt, hamt, hamt, hamt, hamt)
