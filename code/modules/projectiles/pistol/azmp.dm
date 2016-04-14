/obj/item/weapon/gun/projectile/azmp
	name = "AutoZwei-MP"
	caliber = "pistol"
	mag_type = /obj/item/ammo_container/magazine/external/azmp

	firemode = new/datum/firemode/standard
	fire_delay = 3
	mag_in_delay = 4
	mag_out_delay = 0

	icon = 'code/modules/projectiles/pistol/azmp.dmi'
	icon_state = "azmp"
	item_state = "azmp"

	s_fire = 'sound/weapons/guns/azmp_fire.ogg'
	s_magazine_in = 'sound/weapons/guns/generic_smg_mag_in.ogg'
	s_magazine_out = 'sound/weapons/guns/generic_smg_mag_out.ogg'
	s_slide_in = 'sound/weapons/guns/generic_smg_slide_in.ogg'
	s_slide_out = 'sound/weapons/guns/generic_smg_slide_out.ogg'

/obj/item/weapon/gun/projectile/azmp/update_icon()
	overlays.Cut()
	var/list/states = list()
	if(slide_state)
		states += image("icon"=icon,"icon_state"="bolt_back")
	else
		states += image("icon"=icon,"icon_state"="bolt_ready")
	if(magazine)
		states += image("icon"=icon,"icon_state"="azmp_mag")
	overlays += states

/obj/item/ammo_container/magazine/external/azmp
	desc = "A PDW-88 magazine."
	icon = 'code/modules/projectiles/pistol/azmp.dmi'
	icon_state = "azmp_mag"
	ammo_type = /obj/item/ammo_casing/pistol
	caliber = "pistol"
	max_ammo = 30

/obj/item/ammo_container/magazine/external/azmp/update_icon()
	..()
	if(stored_ammo.len)
		var/ratio = stored_ammo.len / max_ammo
		ratio = Ceiling(ratio*4) * 25
		if(ratio > 100)
			icon_state = "[initial(icon_state)]_100"
		else
			icon_state = "[initial(icon_state)]_[ratio]"
	else
		icon_state = "[initial(icon_state)]_empty"
