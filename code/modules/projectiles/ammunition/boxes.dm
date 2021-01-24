//TG-stuff
/obj/item/ammo_box/a357
	name = "speedloader (.357)"
	desc = "A .357 speedloader."
	icon_state = "357"
	ammo_type = /obj/item/ammo_casing/a357
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/c38
	name = "speedloader (.38 rubber)"
	desc = "A .38 speedloader."
	icon_state = "38"
	ammo_type = /obj/item/ammo_casing/c38
	max_ammo = 6
	multiple_sprites = 1

/obj/item/ammo_box/a418
	name = "ammo box (.418)"
	icon_state = "418"
	ammo_type = /obj/item/ammo_casing/a418
	max_ammo = 7
	multiple_sprites = 1

/obj/item/ammo_box/a666
	name = "ammo box (.666)"
	icon_state = "666"
	ammo_type = /obj/item/ammo_casing/a666
	max_ammo = 4
	multiple_sprites = 1

/obj/item/ammo_box/c9mm
	name = "Ammunition Box (9mm)"
	icon_state = "9mm"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 12
	multiple_sprites = 2

/obj/item/ammo_box/c9mmr
	name = "Ammunition Box (9mm rubber)"
	icon_state = "9mmr"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mmr
	max_ammo = 12
	multiple_sprites = 2
/*
/obj/item/ammo_box/c10mm
	name = "Ammunition Box (10mm)"
	icon_state = "9mm"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c10mm
	max_ammo = 30 */

/obj/item/ammo_box/c45
	name = "Ammunition Box (.45)"
	icon_state = "c45"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 7
	multiple_sprites = 2

/obj/item/ammo_box/c45r
	name = "Ammunition Box (.45 rubber)"
	icon_state = "c45r"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45r
	max_ammo = 7
	multiple_sprites = 2

/obj/item/ammo_box/a12mm
	name = "Ammunition Box (12mm)"
	icon_state = "9mm"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a12mm
	max_ammo = 30
	multiple_sprites = 1

/obj/item/ammo_box/shotgun
	name = "shotgun shells box (buckshot)"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "pellet_box"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot
	max_ammo = 20

/obj/item/ammo_box/shotgun/update_icon()
	var/filled_perc = clamp(stored_ammo.len * 100 / max_ammo, 0, 100)

	if(filled_perc >= 50 && filled_perc < 100)
		filled_perc = 75
	else if(filled_perc < 50 && filled_perc > 0)
		filled_perc = 25

	icon_state = initial(icon_state) + "_[filled_perc]"

/obj/item/ammo_box/shotgun/beanbag
	name = "shotgun shells box (beanbag)"
	icon_state = "beanbag_box"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag
