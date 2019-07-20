/obj/item/weapon/gun_module/barrel
	name = "gun barrel"
	icon_state = "barrel_small_icon"
	icon_overlay = "barrel_small"
	lessdamage = 0
	lessdispersion = 0
	lessfiredelay = 0
	lessrecoil = 0
	size = 0
	var/gun_type
	var/silenced = FALSE

/obj/item/weapon/gun_module/barrel/attach(GUN)
	.=..()
	if(condition_check(gun))
		gun.barrel = src
		parent = gun
		src.loc = gun
		change_stat(gun, TRUE)
		gun.overlays += icon_overlay
		gun.modules += src

/obj/item/weapon/gun_module/barrel/condition_check(GUN)
	if(gun.chamber && !gun.barrel && !gun.collected && gun.gun_type == gun_type)
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/barrel/eject(GUN)
	gun.barrel = null
	parent = null
	src.loc = get_turf(gun.loc)
	change_stat(gun, FALSE)
	delete_overlay(gun)
	gun.modules -= src

//////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/gun_module/barrel/energy
	name = "gun barrel energy"
	icon_state = "barrel_medium_laser"
	icon_overlay = "barrel_medium_laser"
	lessdamage = 0
	lessdispersion = 0
	lessfiredelay = 0
	lessrecoil = 0
	size = 0
	gun_type = ENERGY

/obj/item/weapon/gun_module/barrel/bullet
	name = "gun barrel bullet"
	icon_state = "barrel_medium_bullet"
	icon_overlay = "barrel_medium_bullet"
	lessdamage = 0
	lessdispersion = 0
	lessfiredelay = 0
	lessrecoil = 0
	size = 0
	gun_type = BULLET


