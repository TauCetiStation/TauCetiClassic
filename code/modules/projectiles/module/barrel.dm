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

/obj/item/weapon/gun_module/barrel/attach(obj/item/weapon/gunmodule/gun)
	if(..(gun, condition_check(gun)))
		gun.barrel = src
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/barrel/condition_check(obj/item/weapon/gunmodule/gun)
	if(gun.chamber && !gun.barrel && !gun.collected && gun.gun_type == gun_type)
		return TRUE
	return FALSE

/obj/item/weapon/gun_module/barrel/eject(obj/item/weapon/gunmodule/gun)
	gun.barrel = null
	..()

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


