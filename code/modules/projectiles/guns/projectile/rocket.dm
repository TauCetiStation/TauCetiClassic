/obj/item/weapon/gun/projectile/revolver/rocketlauncher
	name = "Goliath missile launcher"
	cases = list("пусковая установка Голиаф","пусковой установки Голиаф","пусковой установке Голиаф","пусковую установку Голиаф","пусковой установкой Голиаф","пусковой установке Голиаф")
	desc = "Голиаф - это однозарядная, многоцелевая переносная пусковая установка для ракет, стреляющая с плеча."
	icon_state = "rocket"
	item_state = "rocket"
	w_class = SIZE_NORMAL
	force = 5
	flags =  CONDUCT
	origin_tech = "combat=8;materials=5"
	slot_flags = 0
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/rocket
	can_be_holstered = FALSE
	two_hand_weapon = ONLY_TWOHAND
	fire_sound = 'sound/effects/bang.ogg'

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/process_chamber()
	return ..(1, 1)

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/attack_self(mob/user)
	var/num_unloaded = 0
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.SpinAnimation(10, 1)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		to_chat(user, "<span class = 'notice'>Вы разряжаете [num_unloaded] [pluralize_russian(num_unloaded, "снаряд", "снаряда", "снарядов")] из [CASE(src, GENITIVE_CASE)].</span>")
	else
		to_chat(user, "<span class='notice'>[CASE(src, NOMINATIVE_CASE)] пуста.</span>")

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/anti_singulo
	name = "XASL Mk.2 singularity buster"
	cases = list("разрушитель сингулярностей ЭАСУ МК 2", "разрушителя сингулярностей ЭАСУ МК 2", "разрушителю сингулярностей ЭАСУ МК 2", "разрушитель сингулярностей ЭАСУ МК 2", "разрушителем сингулярностей ЭАСУ МК 2", "разрушителе сингулярностей ЭАСУ МК 2")
	desc = "Эксперементальная Анти-Сингулярная пусковая установка. В случае чрезвычайной ситуации вам следует направить ее на сверхмассивную чёрную дыру, приближающуюся к вам."
	icon_state = "anti-singulo"
	item_state = "anti-singulo"
	slot_flags = SLOT_FLAGS_BACK
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/rocket/anti_singulo
	fire_sound = 'sound/weapons/guns/gunpulse_emitter2.ogg'
	origin_tech = "combat=3;bluespace=6"

/obj/item/weapon/gun/projectile/revolver/rocketlauncher/commando
	name = "\'Commando\' rocket launcher"
	cases = list("ракетная установка \'Commando\'","ракетной установки \'Commando\'","ракетной установке \'Commando\'","ракетную установку \'Commando\'","ракетной установкой \'Commando\'","ракетной установке \'Commando\'")
	desc = "Четырёхзарядная ракетная установка. Это тот случай, когда тебя вообще не волнует целостность станции."
	icon_state = "commando"
	item_state = "commando"
	initial_mag = /obj/item/ammo_box/magazine/internal/cylinder/rocket/four
