/obj/item/weapon/gun/projectile/pdw88
	name = "PDW-88"
	caliber = "pistol"
	mag_type = /obj/item/ammo_container/magazine/external/pdw88

	fire_delay = 5
	mag_in_delay = 4
	mag_out_delay = 0

	icon = 'code/modules/projectiles/pistol/pdw88.dmi'
	icon_state = "pdw-88"
	item_state = "base"

	s_fire = 'sound/weapons/guns/pdw88_fire.ogg'
	s_magazine_in = 'sound/weapons/guns/pdw88_mag_in.ogg'
	s_magazine_out = 'sound/weapons/guns/pdw88_mag_out.ogg'
	s_slide_in = 'sound/weapons/guns/pdw88_slide_in.ogg'
	s_slide_out = 'sound/weapons/guns/pdw88_slide_out.ogg'

	acceptable_mods = list(/obj/item/weapon_parts/silencer)

/obj/item/ammo_container/magazine/external/pdw88
	desc = "A PDW-88 magazine."
	icon = 'code/modules/projectiles/pistol/pdw88.dmi'
	icon_state = "mag"
	ammo_type = /obj/item/ammo_casing/pistol
	caliber = "pistol"
	max_ammo = 10

/obj/item/ammo_container/magazine/external/pdw88/update_icon()
	..()
	if(stored_ammo.len)
		icon_state = "[initial(icon_state)]_full"
	else
		icon_state = "[initial(icon_state)]_empty"
