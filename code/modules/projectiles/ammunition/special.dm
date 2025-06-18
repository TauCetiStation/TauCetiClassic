/obj/item/ammo_casing/magic
	name = "magic casing"
	desc = "Я даже не мог подумать, что для магии нужны патроны..."
	projectile_type = /obj/item/projectile/magic

/obj/item/ammo_casing/magic/change
	projectile_type = /obj/item/projectile/magic/change

/obj/item/ammo_casing/magic/animate
	projectile_type = /obj/item/projectile/magic/animate

/obj/item/ammo_casing/magic/heal
	projectile_type = /obj/item/projectile/magic/resurrection

/obj/item/ammo_casing/magic/door
	projectile_type = /obj/item/projectile/magic/door
/*
/obj/item/ammo_casing/magic/death
	projectile_type = /obj/item/projectile/magic/death

/obj/item/ammo_casing/magic/teleport
	projectile_type = /obj/item/projectile/magic/teleport
*/
/obj/item/ammo_casing/magic/fireball
	projectile_type = /obj/item/projectile/magic/fireball

/obj/item/ammo_casing/syringegun
	name = "syringe gun spring"
	desc = "Мощная пневматическая пружина, выстреливающая шприцы."
	projectile_type = null


/obj/item/ammo_casing/magic/neurotoxin
	name = "neurotoxin"
	desc = "Хс-с-с-с-с"
	projectile_type = /obj/item/projectile/neurotoxin

/obj/item/ammo_casing/scrapshot
	name = "scrap shot"
	desc = "Повсюду летят стекла, стержни и шурупы."
	projectile_type = /obj/item/projectile/bullet/scrap
	pellets = 10
	variance = 30

/obj/item/ammo_casing/plasma
	name = "plasma"
	caliber = "plasma"
	projectile_type = /obj/item/projectile/plasma

/obj/item/ammo_casing/plasma/overcharge
	projectile_type = /obj/item/projectile/plasma/overcharge

/obj/item/ammo_casing/plasma/overcharge/massive
	projectile_type = /obj/item/projectile/plasma/overcharge/massive

/obj/item/ammo_casing/energy/wormhole
	projectile_type = /obj/item/projectile/beam/wormhole
	e_cost = 0
	select_name = "blue"
	fire_sound = 'sound/weapons/guns/portalgun.ogg'

/obj/item/ammo_casing/energy/wormhole/orange
	projectile_type = /obj/item/projectile/beam/wormhole/orange
	select_name = "orange"
