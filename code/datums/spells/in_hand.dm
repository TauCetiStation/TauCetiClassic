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

/obj/effect/proc_holder/spell/in_hand/cast(mob/living/carbon/human/user = usr)
	if(!istype(user))
		return
	if(!istype(summon_path, user.is_in_hands(summon_path)))
		user.drop_item()
		var/obj/GUN = new summon_path(src)
		user.put_in_active_hand(GUN)

/obj/item/weapon/magic
	name = "MAGIC BITCH"
	icon = 'icons/obj/wizard.dmi'
	var/obj/effect/proc_holder/spell/Spell
	var/uses = 1
	flags = ABSTRACT | DROPDEL
	var/proj_path = /obj/item/projectile/magic
	var/invoke
	var/s_fire

/obj/item/weapon/magic/New(obj/effect/proc_holder/spell/G)
	..()
	Spell = G

/obj/item/weapon/magic/afterattack(atom/A, mob/living/user)
	if(user.incapacitated() || user.lying)
		return 0
	if(s_fire)
		playsound(src, s_fire, 100, 1)
	if(invoke)
		user.say(invoke)
	var/obj/item/projectile/P = new proj_path(get_turf(src))
	P.Fire(A, user)
	uses--
	if(uses <= 0)
		user.drop_item()
		return 0
	return 1


/obj/item/weapon/magic/dropped(mob/user)
	if(Spell)
		if(uses == initial(uses))
			Spell.revert_cast()
		else
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

/obj/item/projectile/magic/fireball/on_hit(atom/target)
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

/obj/item/projectile/magic/lightning/on_hit(atom/target)
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
	s_fire = 'sound/weapons/emitter.ogg'
	icon_state = "arcane_barrage"
	item_state = "arcane_barrage"
	uses = 30
	proj_path = /obj/item/projectile/magic/Arcane_barrage

/obj/item/weapon/magic/arcane_barrage/afterattack(atom/A, mob/living/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/C = user
	if(!..())
		return
	if(uses > 0)
		var/obj/item/weapon/magic/arcane_barrage/Arcane = new type
		Arcane.uses = uses
		C.drop_item()
		C.swap_hand()
		C.drop_item()
		C.put_in_hands(Arcane)
		user.next_click = world.time + 4
		user.next_move = world.time + 4
	else
		C.drop_item()

/obj/item/projectile/magic/Arcane_barrage
	name = "arcane barrage"
	icon_state = "arcane_bolt"
	damage = 20
	damage_type = BURN
	nodamage = 0

