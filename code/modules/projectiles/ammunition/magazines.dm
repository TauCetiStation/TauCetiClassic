/obj/item/ammo_box/magazine
	name = "abstract magazine"
	icon = 'icons/obj/ammo/magazines.dmi'
	var/overlay = null
	multiple_sprites = MANY_STATES

////////////////INTERNAL MAGAZINES//////////////////////
/obj/item/ammo_box/magazine/internal/cylinder
	name = "revolver cylinder"
	desc = "О боже, этого не должно было здесь быть!"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 7

/obj/item/ammo_box/magazine/internal/cylinder/ammo_count(countempties = 1)
	if (!countempties)
		var/boolets = 0
		for (var/i = 1, i <= stored_ammo.len, i++)
			var/obj/item/ammo_casing/bullet = stored_ammo[i]
			if (bullet.BB)
				boolets++
		return boolets
	else
		return ..()

/obj/item/ammo_box/magazine/internal/cylinder/rus357
	name = "russian revolver cylinder"
	desc = "О боже, этого не должно было здесь быть!"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"
	max_ammo = 6
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/rus357/atom_init()
	. = ..()
	stored_ammo += new ammo_type(src)

/obj/item/ammo_box/magazine/internal/cylinder/rev38
	name = "d-tiv revolver cylinder"
	desc = "О боже, этого не должно было здесь быть!"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = "38"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/shot
	name = "shotgun internal magazine"
	desc = "О боже, этого не должно было здесь быть!"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = "shotgun"
	max_ammo = 4
	multiload = 0

/obj/item/ammo_box/magazine/internal/heavyrifle
	name = "heavysniper internal magazine"
	desc = "О боже, этого не должно было здесь быть!"
	ammo_type = /obj/item/ammo_casing/a145
	caliber = "14.5mm"
	max_ammo = 1
	multiload = 0

/obj/item/ammo_box/magazine/internal/m79
	name = "m79 grenade launcher internal magazine"
	desc = "О боже, этого не должно было здесь быть!"
	ammo_type = /obj/item/ammo_casing/r4046
	caliber = "40x46"
	max_ammo = 1
	multiload = 0

/obj/item/ammo_box/magazine/internal/m79/underslung
	ammo_type = /obj/item/ammo_casing/r4046/explosive

/obj/item/ammo_box/magazine/internal/m79/underslung/marines
	ammo_type = /obj/item/ammo_casing/r4046/explosive/light
	caliber = "30"

/obj/item/ammo_box/magazine/internal/shotcom
	name = "combat shotgun internal magazine"
	desc = "О боже, этого не должно было здесь быть!"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 8
	multiload = 0

/obj/item/ammo_box/magazine/internal/shotcom/nonlethal
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/magazine/internal/cylinder/dualshot
	name = "double-barrel shotgun internal magazine"
	desc = "Этого даже не существует!"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
	caliber = "shotgun"
	max_ammo = 2
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/dualshot/derringer
	name = "derringer internal magazine"
	desc = "Этого даже не существует!"
	ammo_type = /obj/item/ammo_casing/c38m
	caliber = "38"
	max_ammo = 2
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/dualshot/derringer/syndicate
	ammo_type = /obj/item/ammo_casing/a357
	caliber = "357"

/obj/item/ammo_box/magazine/internal/cylinder/rocket
	name = "bazooka internal magazine"
	desc = "Этого даже не существует!"
	ammo_type = /obj/item/ammo_casing/caseless/rocket
	caliber = "rocket"
	max_ammo = 1
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/rocket/anti_singulo
	name = "bazooka internal magazine"
	desc = "Этого даже не существует!"
	ammo_type = /obj/item/ammo_casing/caseless/rocket/anti_singulo
	caliber = "rocket_as"
	max_ammo = 1
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/rocket/four
	max_ammo = 4

/obj/item/ammo_box/magazine/internal/cylinder/rev45
	name = "Colt revolver cylinder"
	desc = "О боже, этого не должно было здесь быть!"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 6
	multiload = 0

/obj/item/ammo_box/magazine/internal/cylinder/rev45/rubber
	ammo_type = /obj/item/ammo_casing/c45r

/obj/item/ammo_box/magazine/internal/cylinder/rev38/dungeon
	name = "d-tiv revolver cylinder"
	desc = "О боже, этого не должно было здесь быть!"
	ammo_type = /obj/item/ammo_casing/c38m
	caliber = "38"
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/dualshot/dungeon
	name = "double-barrel shotgun internal magazine"
	desc = "Этого даже не существует!"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/magazine/internal/shot/dungeon
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 5

///////////EXTERNAL MAGAZINES////////////////
/obj/item/ammo_box/magazine/stechkin
	name = "magazine (9mm)"
	cases = list("магазин (9мм)", "магазина (9мм)", "магазину (9мм)", "магазин (9мм)", "магазином (9мм)", "магазине (9мм)")
	icon_state = "stechkin_mag"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 7
	multiple_sprites = MANY_STATES
	overlay = "stechkin-mag"

/obj/item/ammo_box/magazine/stechkin/extended
	name = "extended magazine (9mm)"
	cases = list("расширенный магазин (9мм)", "расширенного магазина (9мм)", "расширенному магазину (9мм)", "расширенный магазин (9мм)", "расширенным магазином (9мм)", "расширенном магазине (9мм)")
	icon_state = "stechkin_mag_extended"
	max_ammo = 16
	overlay = "stechkin-mag-ex"

/obj/item/ammo_box/magazine/glock
	name = "magazine (9mm)"
	cases = list("магазин (9мм)", "магазина (9мм)", "магазину (9мм)", "магазин (9мм)", "магазином (9 мм)", "магазине (9мм)")
	icon_state = "glock_mag"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 12
	multiple_sprites = TWO_STATES
	overlay = "glock-mag"

/obj/item/ammo_box/magazine/glock/rubber
	name = "magazine (9mm rubber)"
	cases = list("магазин (Резина 9мм)", "магазина (Резина 9мм)", "магазину (Резина 9мм)", "магазин (Резина 9мм)", "магазином (Резина 9мм)", "магазине (Резина 9мм)")
	icon_state = "glock_mag_rubber"
	ammo_type = /obj/item/ammo_casing/c9mmr

/obj/item/ammo_box/magazine/glock/extended
	name = "extended magazine (9mm)"
	cases = list("расширенный магазин (9мм)", "расширенного магазина (9мм)", "расширенному магазину (9мм)", "расширенный магазин (9мм)", "расширенным магазином (9мм)", "расширенном магазине (9мм)")
	icon_state = "glock_mag_extended"
	max_ammo = 20
	overlay = "glock-mag-extended"

/obj/item/ammo_box/magazine/glock/extended/rubber
	name = "extended magazine (9mm rubber)"
	cases = list("расширенный магазин (Резина 9мм)", "расширенного магазина (Резина 9мм)", "расширенному магазину (Резина 9мм)", "расширенный магазин (Резина 9мм)", "расширенным магазином (Резина 9мм)", "расширенном магазине (Резина 9мм)")
	icon_state = "glock_mag_extended_rubber"
	ammo_type = /obj/item/ammo_casing/c9mmr

/obj/item/ammo_box/magazine/smg
	name = "SMG magazine (9mm)"
	cases = list("магазин ПП (9мм)", "магазина ПП (9мм)", "магазину ПП (9мм)", "магазин ПП (9мм)", "магазином ПП (9мм)", "магазине ПП (9мм)")
	icon_state = "smg_mag-5"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 18
	overlay = "saber-mag"

/obj/item/ammo_box/magazine/smg/update_icon()
	var/ammo_perc = ammo_count() / max_ammo
	var/ammo_state_indx = CEIL(LERP(0, 5, ammo_perc))

	icon_state = "smg_mag-[ammo_state_indx]"

/obj/item/ammo_box/magazine/c20r
	name = "magazine (.45)"
	cases = list("магазин (.45)", "магазина (.45)", "магазину (.45)", "магазин (.45)", "магазином (.45)", "магазине (.45)")
	icon_state = "c20r_mag"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 30

/obj/item/ammo_box/magazine/c20r/update_icon()
	cut_overlays()
	if(ammo_count() == 0)
		return

	var/ammo_perc = ammo_count() / max_ammo
	ammo_perc = CEIL(ammo_perc * 4) * 25

	var/image/ammo_icon = image('icons/obj/ammo/magazines.dmi', "12mmsh-[round(ammo_perc, 25)]")
	add_overlay(ammo_icon)

/obj/item/ammo_box/magazine/c20r/hp
	name = "magazine (.45 HP)"
	cases = list("магазин (.45 HP)", "магазина (.45 HP)", "магазину (.45 HP)", "магазин (.45 HP)", "магазином (.45 HP)", "магазине (.45 HP)")
	desc = "Магазин, полный мощных патронов для пистолета-пулемета"
	icon_state = "c20r_mag_hp"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/c45hp
	caliber = ".45"
	max_ammo = 20

/obj/item/ammo_box/magazine/c20r/hv
	name = "magazine (.45 HV)"
	cases = list("магазин (.45 HV)", "магазина (.45 HV)", "магазину (.45 HV)", "магазин (.45 HV)", "магазином (.45 HV)", "магазине (.45 HV)")
	desc = "Магазин, полный высокоскоростных патронов для пистолета-пулемета."
	icon_state = "c20r_mag_hv"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/c45hv
	caliber = ".45"
	max_ammo = 20

/obj/item/ammo_box/magazine/c20r/imp
	name = "magazine (.45 IMP)"
	cases = list("магазин (.45 IMP)", "магазина (.45 IMP)", "магазину (.45 IMP)", "магазин (.45 IMP)", "магазином (.45 IMP)", "магазине (.45 IMP)")
	desc = "Магазин, полный импульсных патронов для пистолета-пулемета."
	icon_state = "c20r_mag_imp"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/c45imp
	caliber = ".45"
	max_ammo = 20

/obj/item/ammo_box/magazine/silenced_pistol
	name = "magazine (.45)"
	cases = list("магазин (.45)", "магазина (.45)", "магазину (.45)", "магазин (.45)", "магазином (.45)", "магазине (.45)")
	icon_state = "silenced_pistol_mag"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 12
	overlay = "silenced_pistol-mag"
	multiple_sprites = TWO_STATES

/obj/item/ammo_box/magazine/colt
	name = "magazine (.45)"
	cases = list("магазин (.45)", "магазина (.45)", "магазину (.45)", "магазин (.45)", "магазином (.45)", "магазине (.45)")
	icon_state = "colt_mag"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 7
	multiple_sprites = MANY_STATES

/obj/item/ammo_box/magazine/colt/rubber
	name = "magazine (.45 rubber)"
	cases = list("магазин (.45 Резина)", "магазина (.45 Резина)", "магазину (.45 Резина)", "магазин (.45 Резина)", "магазином (.45 Резина)", "магазине (.45 Резина)")
	icon_state = "colt_mag_rubber"
	ammo_type = /obj/item/ammo_casing/c45r

/obj/item/ammo_box/magazine/mac10
	name = "Mac-10 magazine (9mm)"
	cases = list("магазин Мак-10 (9мм)", "магазина Мак-10 (9мм)", "магазину Мак-10 (9мм)", "магазин Мак-10 (9мм)", "магазином Мак-10 (9мм)", "магазине Мак-10 (9мм)")
	icon_state = "mac10_mag"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 32
	multiple_sprites = TWO_STATES
	overlay = "mac-magazine"

/obj/item/ammo_box/magazine/tommygun
	name = "tommy gun drum (.45)"
	cases = list("барабан автомата Томпсона (.45)", "барабана автомата Томпсона (.45)", "барабану автомата Томпсона (.45)", "барабан автомата Томпсона (.45)", "барабаном автомата Томпсона (.45)", "барабане автомата Томпсона (.45)")
	icon_state = "tommygun_mag"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 50
	multiple_sprites = TWO_STATES
	overlay = "tommygun-mag"

/obj/item/ammo_box/magazine/deagle
	name = "magazine (.50AE)"
	cases = list("магазин (.50АЕ)", "магазина (.50АЕ)", "магазину (.50АЕ)", "магазин (.50АЕ)", "магазином (.50АЕ)", "магазине (.50АЕ)")
	icon_state = "deagle_mag"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a50
	caliber = ".50"
	max_ammo = 7
	multiple_sprites = MANY_STATES
	overlay = "deagle-mag"

/obj/item/ammo_box/magazine/deagle/weakened
	ammo_type = /obj/item/ammo_casing/a50/weakened

/obj/item/ammo_box/magazine/saw
	name = "magazine (7.62mm)"
	cases = list("магазин (7.62мм)", "магазина (7.62мм)", "магазину (7.62мм)", "магазин (7.62мм)", "магазином (7.62мм)", "магазине (7.62мм)")
	icon_state = "saw_mag"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 50

/obj/item/ammo_box/magazine/saw/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/chameleon
	name = "magazine (.45)"
	cases = list("магазин (.45)", "магазина (.45)", "магазину (.45)", "магазин (.45)", "магазином (.45)", "магазине (.45)")
	icon_state = "colt_mag"
	ammo_type = /obj/item/ammo_casing/chameleon
	max_ammo = 7
	multiple_sprites = MANY_STATES

/obj/item/ammo_box/magazine/l13
	name = "magazine (.38 rubber)"
	cases = list("магазин (.38 Резина)", "магазина (.38 Резина)", "магазину (.38 Резина)", "магазин (.38 Резина)", "магазином (.38 Резина)", "магазине (.38 Резина)")
	icon_state = "l13_mag_rubber"
	origin_tech = "combat=1"
	ammo_type = /obj/item/ammo_casing/c38
	caliber = "38"
	max_ammo = 20
	multiple_sprites = TWO_STATES
	overlay = "l13-mag"

/obj/item/ammo_box/magazine/l13/lethal
	name = "magazine (.38)"
	cases = list("магазин (.38)", "магазина (.38)", "магазину (.38)", "магазин (.38)", "магазином (.38)", "магазине (.38)")
	origin_tech = "combat=2"
	icon_state = "l13_mag"
	ammo_type = /obj/item/ammo_casing/c38m

/obj/item/ammo_box/magazine/internal/repeater
	name = "repeater internal magazine"
	desc = "О боже, этого не должно было здесь быть!"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 8
	multiload = 0

/obj/item/ammo_box/magazine/a774clip
	name = "ammo clip (7.74)"
	cases = list("обойма патронов (7.74)", "обоймы патронов (7.74)", "обойме патронов (7.74)", "обойму патронов (7.74)", "обоймой патронов (7.74)", "обойме патронов (7.74)")
	icon_state = "clip"
	origin_tech = "combat=2"
	caliber = "7.74mm"
	ammo_type = /obj/item/ammo_casing/a74
	max_ammo = 5
	multiple_sprites = MANY_STATES

/obj/item/ammo_box/magazine/bar
	name = "magazine (.30-06)"
	cases = list("магазин (.30-06)", "магазина (.30-06)", "магазину (.30-06)", "магазин (.30-06)", "магазином (.30-06)", "магазине (.30-06)")
	icon_state = "bar_mag"
	ammo_type = /obj/item/ammo_casing/a3006
	caliber = "a3006"
	multiple_sprites = TWO_STATES
	max_ammo = 20
	overlay = "bar-mag"

/obj/item/ammo_box/magazine/borg45
	name = "magazine (.45)"
	cases = list("магазин (.45)", "магазина (.45)", "магазину (.45)", "магазин (.45)", "магазином (.45)", "магазине (.45)")
	icon_state = "saw_mag"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 40

/obj/item/ammo_box/magazine/borg45/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/borg45/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/gun/projectile/automatic/borg))
		var/obj/item/weapon/gun/projectile/automatic/borg/SMG = I
		if (!SMG.magazine)
			SMG.magazine = src
			SMG.magazine.forceMove(SMG)
			playsound(src, 'sound/weapons/guns/reload_mag_in.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "<span class='notice'>Вы загружаете новый магазин в [CASE(SMG,ACCUSATIVE_CASE)].</span>")
			SMG.chamber_round()
			I.update_icon()
			update_icon()
			return TRUE

		else if (SMG.magazine)
			to_chat(user, "<span class='notice'>В [CASE(src,PREPOSITIONAL_CASE)] уже есть магазин.</span>")
			return

	return ..()

/obj/item/ammo_box/magazine/bulldog
	name = "shotgun magazine (12g buckshot)"
	cases = list("барабан дробовика (12г Картечь)", "барабана дробовика (12г Картечь)", "барабану дробовика (12г Картечь)", "барабан дробовика (12г Картечь)", "барабаном дробовика (12г Картечь)", "барабане дробовика (12г Картечь)")
	icon_state = "bulldog_mag"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	caliber = "shotgun"
	max_ammo = 8
	multiple_sprites = TWO_STATES
	overlay = "bulldog-mag"

/obj/item/ammo_box/magazine/bulldog/stun
	name = "shotgun magazine (12g stun shot)"
	cases = list("барабан дробовика (12г Электрошок)", "барабана дробовика (12г Электрошок)", "барабану дробовика (12г Электрошок)", "барабан дробовика (12г Электрошок)", "барабаном дробовика (12г Электрошок)", "барабане дробовика (12г Электрошок)")
	icon_state = "bulldog_mag_stun"
	ammo_type = /obj/item/ammo_casing/shotgun/stunshot
	caliber = "shotgun"
	max_ammo = 8
	overlay = "bulldog-mag-s"

/obj/item/ammo_box/magazine/bulldog/incendiary
	name = "shotgun magazine (12g incendiary)"
	cases = list("барабан дробовика (12г Зажигательный)", "барабана дробовика (12г Зажигательный)", "барабану дробовика (12г Зажигательный)", "барабан дробовика (12г Зажигательный)", "барабаном дробовика (12г Зажигательный)", "барабане дробовика (12г Зажигательный)")
	icon_state = "bulldog_mag_inc"
	origin_tech = "combat=3;syndicate=1"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary
	overlay = "bulldog-mag-i"

/obj/item/ammo_box/magazine/a28
	name = "A28 magazine (5.56mm)"
	cases = list("магазин А28 (5.56мм)", "магазина А28 (5.56мм)", "магазину А28 (5.56мм)", "магазин А28 (5.56мм)", "магазином А28 (5.56мм)", "магазине А28 (5.56мм)")
	icon_state = "a28_mag"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a556
	caliber = "5.56mm"
	max_ammo = 30
	multiple_sprites = TWO_STATES
	overlay = "a28-mag"

/obj/item/ammo_box/magazine/a28/incendiary
	name = "A28 magazine (5.56mm incendiary)"
	cases = list("магазин А28 (5.56мм Зажигательный)", "магазина А28 (5.56мм Зажигательный)", "магазину А28 (5.56мм Зажигательный)", "магазин А28 (5.56мм Зажигательный)", "магазином А28 (5.56мм Зажигательный)", "магазине А28 (5.56мм Зажигательный)")
	ammo_type = /obj/item/ammo_casing/a556i
	icon_state = "a28_mag_inc"
	overlay = "a28-mag-i"

/obj/item/ammo_box/magazine/a74
	name = "A74 magazine (7.74mm)"
	cases = list("магазин А74 (7.74мм)", "магазина А74 (7.74мм)", "магазину А74 (7.74мм)", "магазин А74 (7.74мм)", "магазином А74 (7.74мм)", "магазине А74 (7.74мм)")
	icon_state = "a74_mag"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a74
	caliber = "7.74mm"
	max_ammo = 30
	multiple_sprites = TWO_STATES
	overlay = "a74-mag"

/obj/item/ammo_box/magazine/a74/krinkov
	name = "small A74 magazine (7.74мм)"
	cases = list("уменьшенный магазин А74 (7.74мм)", "уменьшенного магазина А74 (7.74мм)", "уменьшенному магазину А74 (7.74мм)", "уменьшенный магазин А74 (7.74мм)", "уменьшенным магазином А74 (7.74мм)", "уменьшенном магазине А74 (7.74мм)")
	icon_state = "krinkov_mag"
	max_ammo = 15
	overlay = "krinkov-mag"

/obj/item/ammo_box/magazine/plasma
	name = "plasma weapon battery pack"
	cases = list("батарейный блок плазменного оружия", "батарейного блока плазменного оружия", "батарейному блоку плазменного оружия", "батарейный блок плазменного оружия", "батарейным блоком плазменного оружия", "батарейном блоке плазменного оружия")
	desc = "Специальный корпус аккумулятора с защитой от ЭМИ. Используется метод быстрой зарядки. Имеет стандартизированные размеры и может использоваться с любым плазмотроном данной серии. Возможна замена элемента питания."
	icon_state = "plasma_clip"
	origin_tech = "combat=2"
	ammo_type = null // unused, those are inside guns of this type.
	caliber = "plasma"
	max_ammo = 0 // not used with this magazine.

	var/obj/item/weapon/stock_parts/cell/power_supply
	var/cell_type = /obj/item/weapon/stock_parts/cell/super // we balance ammo consumption and amount over this type of battery, because even this battery still requires basic materials to craft.

/obj/item/ammo_box/magazine/plasma/atom_init()
	. = ..()
	if(cell_type)
		power_supply = new cell_type(src)
	else
		power_supply = new(src)
	update_icon()

/obj/item/ammo_box/magazine/plasma/Destroy()
	QDEL_NULL(power_supply)
	return ..()

/obj/item/ammo_box/magazine/plasma/attackby(obj/item/I, mob/user, params)
	if(power_supply && isscrewing(I))
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		user.put_in_hands(power_supply)
		power_supply = null
		update_icon()

	else if(istype(I, /obj/item/weapon/stock_parts/cell) && !power_supply && user.drop_from_inventory(I, src))
		playsound(src, 'sound/items/change_drill.ogg', VOL_EFFECTS_MASTER)
		power_supply = I
		update_icon()

	else
		return ..()

/obj/item/ammo_box/magazine/plasma/get_round(keep = FALSE)
	return null

/obj/item/ammo_box/magazine/plasma/proc/get_charge()
	if(!power_supply)
		return 0
	return power_supply.charge

/obj/item/ammo_box/magazine/plasma/proc/has_overcharge()
	return power_supply.charge > PLASMAGUN_OVERCHARGE

/obj/item/ammo_box/magazine/plasma/ammo_count() // we don't use this proc
	return 0

/obj/item/ammo_box/magazine/plasma/examine(mob/user)
	. = ..(user, 1)
	if(.)
		to_chat(user, "<span class='notice'>Вы видите индикатор заряда, он показывает: [power_supply ? round(power_supply.charge * 100 / power_supply.maxcharge) : "nan"]%.</span>")

/obj/item/ammo_box/magazine/plasma/attack_self(mob/user) // check parent proc before adding ..() or removing this one.
	return

/obj/item/ammo_box/magazine/plasma/update_icon()
	if(!power_supply)
		icon_state = "[initial(icon_state)]-0"
		return
	// yes, it stops reporting accurate data for icon if its overflowing with energy till it drops charge under certain amount.
	icon_state = "[initial(icon_state)]-[has_overcharge() ? "oc" : CEIL(power_supply.charge / power_supply.maxcharge * 5) * 20]"

/obj/item/ammo_box/magazine/plasma/emp_act() // just incase if someone adds emp_act in parent.
	return

/obj/item/ammo_box/magazine/drozd
	name = "Drozd magazine (12.7mm)"
	cases = list("магазин Дрозда (12.7мм)", "магазина Дрозда (12.7мм)", "магазину Дрозда (12.7мм)", "магазин Дрозда (12.7мм)", "магазином Дрозда (12.7мм)", "магазине Дрозда (12.7мм)")
	icon_state = "drozd_mag"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/drozd127
	caliber = "12.7mm"
	max_ammo = 12
	multiple_sprites = TWO_STATES
	overlay = "drozd-mag"

/obj/item/ammo_box/magazine/wjpp
	name = "small magazine (9mm)"
	cases = list("уменьшенный магазин (9мм)", "уменьшенного магазина (9мм)", "уменьшенному магазину (9мм)", "уменьшенный магазин (9мм)", "уменьшенным магазином (9мм)", "уменьшенном магазине (9мм)")
	icon_state = "wjpp_mag"
	origin_tech = "combat=1"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 6
	multiple_sprites = TWO_STATES
	overlay = "wjpp-mag"

/obj/item/ammo_box/magazine/wjpp/rubber
	name = "small magazine (9mm rubber)"
	cases = list("уменьшенный магазин (9мм Резина)", "уменьшенного магазина (9мм Резина)", "уменьшенному магазину (9мм Резина)", "уменьшенный магазин (9мм Резина)", "уменьшенным магазином (9мм Резина)", "уменьшенном магазине (9мм Резина)")
	icon_state = "wjpp_mag_rubber"
	ammo_type = /obj/item/ammo_casing/c9mmr

/obj/item/ammo_box/magazine/m41a
	name = "M41A magazine (10x24 Caseless)"
	cases = list("магазин М41А (10x24 Безгильзовый)", "магазина М41А (10x24 Безгильзовый)", "магазину М41А (10x24 Безгильзовый)", "магазин М41А (10x24 Безгильзовый)", "магазином М41А (10x24 Безгильзовый)", "магазине М41А (10x24 Безгильзовый)")
	desc = "99-и зарядная палочка смерти"
	icon_state = "M41A"
	origin_tech = "combat=1"
	ammo_type = /obj/item/ammo_casing/pulserifle
	caliber = "10x24"
	max_ammo = 99
	multiple_sprites = TWO_STATES
	overlay = "pulserifle-mag"

/obj/item/ammo_box/speedloader
	name = "nonexistant speedloader"
	multiple_sprites = MANY_STATES
	icon = 'icons/obj/ammo/magazines.dmi'

/obj/item/ammo_box/speedloader/a357
	name = "speedloader (.357)"
	cases = list("спидлоадер (.357)", "спидлоадера (.357)", "спидлоадеру (.357)", "спидлоадер (.357)", "спидлоадером (.357)", "спидлоадере (.357)")
	desc = "Спидлоадер под 357-й калибр."
	caliber = "357"
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 7

/obj/item/ammo_box/speedloader/c38
	name = "speedloader (.38 rubber)"
	cases = list("спидлоадер (.38 Резина)", "спидлоадера (.38 Резина)", "спидлоадеру (.38 Резина)", "спидлоадер (.38 Резина)", "спидлоадером (.38 Резина)", "спидлоадере (.38 Резина)")
	desc = "Спидлоадер под 38-й калибр"
	caliber = "38"
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6

/obj/item/ammo_box/speedloader/c38m
	name = "speedloader (.38)"
	cases = list("спидлоадер (.38)", "спидлоадера (.38)", "спидлоадеру (.38 )", "спидлоадер (.38)", "спидлоадером (.38)", "спидлоадере (.38)")
	caliber = "38"
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38m
	max_ammo = 6

/obj/item/ammo_box/speedloader/c45rubber
	name = "speedloader (.45 rubber)"
	cases = list("спидлоадер (.45 Резина)", "спидлоадера (.45 Резина)", "спидлоадеру (.45 Резина)", "спидлоадер (.45 Резина)", "спидлоадером (.45 Резина)", "спидлоадере (.45 Резина)")
	desc = "Спидлоадер под 45-й калибр"
	caliber = ".45"
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c45r
	max_ammo = 6

/obj/item/ammo_box/magazine/pea
	name = "pealoader"
	cases = list("гороховый зарядник", "горохового зарядника", "гороховому заряднику", "гороховый зарядник", "гороховым зарядником", "гороховом заряднике")
	desc = "Гороховый зарядник для горохового пистолета."
	caliber = "Pea"
	ammo_type = /obj/item/ammo_casing/pea
	max_ammo = 6
	origin_tech = "combat=2"
