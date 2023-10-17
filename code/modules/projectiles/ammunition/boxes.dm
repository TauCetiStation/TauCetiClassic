/obj/item/ammo_box/c9mm
	name = "Ammunition Box (9mm)"
	icon_state = "9mm"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 12
	multiple_sprites = TWO_STATES

/obj/item/ammo_box/c9mmr
	name = "Ammunition Box (9mm rubber)"
	icon_state = "9mmr"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mmr
	max_ammo = 12
	multiple_sprites = TWO_STATES

/obj/item/ammo_box/c45
	name = "Ammunition Box (.45)"
	caliber = ".45"
	icon_state = "c45"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 7
	multiple_sprites = TWO_STATES

/obj/item/ammo_box/c45r
	name = "Ammunition Box (.45 rubber)"
	caliber = ".45"
	icon_state = "c45r"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45r
	max_ammo = 7
	multiple_sprites = TWO_STATES

/obj/item/ammo_box/a12mm
	name = "Ammunition Box (12mm)"
	icon_state = "9mm"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a12mm
	max_ammo = 30
	multiple_sprites = MANY_STATES

/obj/item/ammo_box/shotgun
	name = "shotgun shells box (buckshot)"
	desc = "Коробка из под патронов (Картечь) 12 калибра. Патрон, снаряженный 9-ю картечинами"
	caliber = "shotgun"
	icon_state = "pellet_box"
	w_class = SIZE_SMALL
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
	desc = "Коробка из под патронов (Травматический) 12 калибра. Патрон травматический маломощный, снаряженный тканевым мешочком с мелкой дробью."
	icon_state = "beanbag_box"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/eight_shells
	name = "shotgun shells box (slug)"
	desc = "Коробка из под патронов (Пуля) 12 калибра. Патрон, снаряженный пулей 12 калибра"
	icon_state = "blushellbox"
	ammo_type = /obj/item/ammo_casing/shotgun
	caliber = "shotgun"
	multiple_sprites = MANY_STATES
	max_ammo = 8

/obj/item/ammo_box/eight_shells/buckshot
	name = "shotgun shells box (buckshot)"
	desc = "Коробка из под патронов (Картечь) 12 калибра. Патрон, снаряженный 9-ю картечинами"
	icon_state = "redshellbox"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/eight_shells/beanbag
	name = "shotgun shells box (beanbag)"
	desc = "Коробка из под патронов (Травматический) 12 калибра. Патрон травматический маломощный, снаряженный тканевым мешочком с мелкой дробью."
	icon_state = "greenshellbox"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/eight_shells/incendiary
	name = "shotgun shells box (incendiary)"
	desc = "Коробка из под патронов (Зажигательный) 12 калибра. Патрон зажигательный, снаряженный 12-ю зажигательными пулями"
	icon_state = "orangeshellbox"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/ammo_box/eight_shells/dart
	name = "shotgun shells box (dart)"
	desc = "Коробка из под патронов (Дротик) 12 калибра. Патрон несмертельного действия, снаряженный дротиком с парализующим веществом"
	icon_state = "purpleshellbox"
	ammo_type = /obj/item/ammo_casing/shotgun/dart

/obj/item/ammo_box/eight_shells/stunshot
	name = "shotgun shells box (stunshot)"
	desc = "Коробка из под патронов (Электрошок) 12 калибра. Патрон несмертельного действия, снаряженный  5-ю электрошоковыми пулями"
	icon_state = "stanshellbox"
	ammo_type = /obj/item/ammo_casing/shotgun/stunshot
