/obj/item/ammo_casing/a357
	name = "357. bullet"
	icon_state = "casing_357"
	desc = "Патрон от пули калибра .357."
	caliber = "357"
	projectile_type = /obj/item/projectile/bullet/revbullet
	m_amt = 1000

/obj/item/ammo_casing/a50
	desc = "Патрон от пули калибра .50АЕ."
	caliber = ".50"
	projectile_type = /obj/item/projectile/bullet

/obj/item/ammo_casing/a50/weakened
	projectile_type = /obj/item/projectile/bullet/midbullet3

/obj/item/ammo_casing/c38
	desc = "Патрон от пули 38-го калибра."
	icon_state = "casing_38_rubber"
	caliber = "38"
	projectile_type = /obj/item/projectile/bullet/weakbullet
	m_amt = 200

/obj/item/ammo_casing/c9mm
	desc = "Патрон от пули калибра 9мм."
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/midbullet2
	m_amt = 300

/obj/item/ammo_casing/c9mmr
	desc = "Патрон от резиновой пули калибра 9мм."
	icon_state = "casing_rubber"
	caliber = "9mm"
	projectile_type = /obj/item/projectile/bullet/weakbullet/rubber
	m_amt = 100

/obj/item/ammo_casing/c45
	desc = "Патрон от пули 45-го калибра."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/smg
	m_amt = 400

/obj/item/ammo_casing/c45hp
	desc = "Патрон от пули калибра .45 HP."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/smg_hp

/obj/item/ammo_casing/c45hv
	desc = "Патрон от пули калибра .45 HV."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/smg_hv

/obj/item/ammo_casing/c45imp
	desc = "Патрон от пули калибра .45 IMP."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/smg_imp

/obj/item/ammo_casing/c45r
	desc = "Патрон от резиновой пули 45-го калибра."
	caliber = ".45"
	projectile_type = /obj/item/projectile/bullet/weakbullet/rubber
	m_amt = 200

/obj/item/ammo_casing/a12mm
	desc = "Патрон от пули калибра 12мм."
	caliber = "12mm"
	projectile_type = /obj/item/projectile/bullet/midbullet2

/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "Патрон от 12-го калибра типа пуля."
	icon_state = "blshell"
	caliber = "shotgun"
	projectile_type = /obj/item/projectile/bullet/slug
	m_amt = 3750

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "Патрон от 12-го калибра типа картечь."
	icon_state = "gshell"
	pellets = 7
	projectile_type = /obj/item/projectile/bullet/pellet

/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag shell"
	desc = "Патрон от 12-го калибра типа травматический."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/weakbullet/beanbag
	m_amt = 300

/obj/item/ammo_casing/shotgun/stunshot
	name = "stun shell"
	desc = "Патрон от 12-го калибра типа электрошок."
	icon_state = "stunshell"
	projectile_type = /obj/item/projectile/bullet/stunshot
	pellets = 5
	m_amt = 2500

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary shell"
	desc = "Патрон от 12-го калибра типа зажигательный."
	icon_state = "ishell"
	projectile_type = /obj/item/projectile/bullet/incendiary/buckshot
	pellets = 12

/obj/item/ammo_casing/shotgun/dart
	name = "shotgun darts"
	desc = "Патрон от 12-го калибра типа дротик."
	icon_state = "cshell"
	projectile_type = /obj/item/projectile/energy/dart
	m_amt = 2500

/obj/item/ammo_casing/a762
	desc = "Патрон пули калибра 7.62мм."
	caliber = "a762"
	projectile_type = /obj/item/projectile/bullet/a762

/obj/item/ammo_casing/a145
	desc = "Патрон пули 14,5мм."
	icon_state = "lcasing"
	caliber = "14.5mm"
	projectile_type = /obj/item/projectile/bullet/heavy/a145


/obj/item/ammo_casing/r4046
	name = "40x46mm grenade"
	desc = "Граната калибра 40х46мм."
	icon_state = "40x46"
	caliber = "40x46"
	projectile_type = /obj/item/projectile/bullet/grenade/r4046


/obj/item/ammo_casing/r4046/explosive
	desc = "Граната калибра 40х46мм (Взрывная)."
	icon_state = "expl40x46"
	projectile_type = /obj/item/projectile/bullet/grenade/explosive

/obj/item/ammo_casing/r4046/explosive/light
	name = "30mm grenade"
	desc = "Граната калибра 30мм (Взрывная)."
	icon_state = "expl30"
	caliber = "30"
	projectile_type = /obj/item/projectile/bullet/grenade/explosive/light

/obj/item/ammo_casing/r4046/chem/teargas
	desc = "Граната калибра 40х46мм (Слезоточивая)."
	icon_state = "gas40x46"
	projectile_type = /obj/item/projectile/bullet/chem/teargas

/obj/item/ammo_casing/r4046/chem/EMP
	desc = "Граната калибра 40х46мм (ЭМИ)."
	icon_state = "emp40x46"
	projectile_type = /obj/item/projectile/bullet/chem/EMP

/obj/item/ammo_casing/r4046/chem/Exp
	desc = "Граната калибра 40х46мм (Взрывная)."
	icon_state = "expl40x46"
	projectile_type = /obj/item/projectile/bullet/chem/Exp

/obj/item/ammo_casing/caseless
	desc = "Безоболочечная гильза."

/obj/item/ammo_casing/caseless/fire(atom/target, mob/living/user, params, distro, quiet)
	if (..())
		loc = null
		return 1
	else
		return 0

/obj/item/ammo_casing/caseless/a75
	desc = "Патрон от пули калибра .75."
	caliber = "75"
	projectile_type = /obj/item/projectile/bullet/gyro

/obj/item/ammo_casing/caseless/rocket
	name = "HE rocket shell"
	desc = "Ракета, предназначенная для стрельбы из пусковой установки."
	icon_state = "rocket-he"
	projectile_type = /obj/item/projectile/missile
	caliber = "rocket"

/obj/item/ammo_casing/caseless/rocket/emp
	name = "EMP rocket shell"
	desc = "Ракета ЭМИ, предназначенная для стрельбы из пусковой установки."
	icon_state = "rocket-emp"
	projectile_type = /obj/item/projectile/missile/emp

/obj/item/ammo_casing/caseless/rocket/anti_singulo
	name = "AS rocket shell"
	desc = "Ракета особого типа, предназначенная для разрушения гравитационных сингулярностей с помощью манипуляций с блюспейс пространством."
	icon_state = "rocket-as"
	projectile_type = /obj/item/projectile/anti_singulo
	caliber = "rocket_as"

/obj/item/ammo_casing/chameleon
	name = "chameleon bullets"
	desc = "Патроны для пистолета-хамелеона."
	projectile_type = /obj/item/projectile/bullet/chameleon
	caliber = ".45"

/obj/item/ammo_casing/a3006
	desc = "Патрон от пули калибра 30-06мм."
	caliber = "a3006"
	projectile_type = /obj/item/projectile/bullet/midbullet3

/obj/item/ammo_casing/c38m
	desc = "Патрон от пули калибра .38."
	icon_state = "casing_38"
	caliber = "38"
	projectile_type = /obj/item/projectile/bullet/midbullet2
	m_amt = 400

/obj/item/ammo_casing/a556
	desc = "Патрон от пули калибра 5.56мм."
	caliber = "5.56mm"
	projectile_type = /obj/item/projectile/bullet/rifle2

/obj/item/ammo_casing/a556i
	desc = "Патрон для зажигательной пули калибра 5.56 мм."
	caliber = "5.56mm"
	icon_state = "casing_incendiary"
	projectile_type = /obj/item/projectile/bullet/incendiary

/obj/item/ammo_casing/a74
	desc = "Патрон от пули калибра 7.74мм."
	caliber = "7.74mm"
	projectile_type = /obj/item/projectile/bullet/rifle3

/obj/item/ammo_casing/drozd127
	desc = "Патрон от пули калибра 12.7мм."
	caliber = "12.7mm"
	projectile_type = /obj/item/projectile/bullet/rifle2

/obj/item/ammo_casing/pulserifle
	desc = "Патрон от пули калибра 10х24."
	caliber = "10x24"
	icon_state = "casing_1024"
	projectile_type = /obj/item/projectile/bullet/pulserifle
