/obj/item/ammo_box/c9mm
	name = "Ammunition Box (9mm)"
	cases = list("коробка патронов (9мм)", "коробки патронов (9мм)", "коробке патронов (9мм)", "коробку патронов (9мм)", "коробкой патронов (9мм)", "коробке патронов (9мм)")
	icon_state = "9mm"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mm
	max_ammo = 12
	multiple_sprites = TWO_STATES

/obj/item/ammo_box/c9mmr
	name = "Ammunition Box (9mm rubber)"
	cases = list("коробка патронов (9мм Резина)", "коробки патронов (9мм Резина)", "коробке патронов (9мм Резина)", "коробку патронов (9мм Резина)", "коробкой патронов (9мм Резина)", "коробке патронов (9мм Резина)")
	icon_state = "9mmr"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c9mmr
	max_ammo = 12
	multiple_sprites = TWO_STATES

/obj/item/ammo_box/c45
	name = "Ammunition Box (.45)"
	cases = list("коробка патронов (.45)", "коробки патронов (.45)", "коробке патронов (.45)", "коробку патронов (.45)", "коробкой патронов (.45)", "коробке патронов (.45)")
	caliber = ".45"
	icon_state = "c45"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45
	max_ammo = 7
	multiple_sprites = TWO_STATES

/obj/item/ammo_box/c45r
	name = "Ammunition Box (.45 rubber)"
	cases = list("коробка патронов (.45 Резина)", "коробки патронов (.45 Резина)", "коробке патронов (.45 Резина)", "коробку патронов (.45 Резина)", "коробкой патронов (.45 Резина)", "коробке патронов (.45 Резина)")
	caliber = ".45"
	icon_state = "c45r"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/c45r
	max_ammo = 7
	multiple_sprites = TWO_STATES

/obj/item/ammo_box/a12mm
	name = "Ammunition Box (12mm)"
	cases = list("коробка патронов (12мм)", "коробки патронов (12мм)", "коробке патронов (12мм)", "коробку патронов (12мм)", "коробкой патронов (12мм)", "коробке патронов (12мм)")
	icon_state = "9mm"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a12mm
	max_ammo = 30
	multiple_sprites = MANY_STATES

/obj/item/ammo_box/shotgun
	name = "shotgun shells box (buckshot)"
	cases = list("коробка патронов (Картечь)", "коробки патронов (Картечь)", "коробке патронов (Картечь)", "коробку патронов (Картечь)", "коробкой патронов (Картечь)", "коробке патронов (Картечь)")
	desc = "Коробка для ружейных патронов (Картечь)."
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
	cases = list("коробки патронов (Травматический)", "коробки патронов (Травматический)", "коробке патронов (Травматический)", "коробке патронов (Травматический)", "коробкой  патронов (Травматический)", "коробке патронов (Травматический)")
	desc = "Коробка для ружейных патронов (Травматический)"
	icon_state = "beanbag_box"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/eight_shells
	name = "shotgun shells box (slug)"
	cases = list("коробки патронов (Пуля)", "коробки патронов (Пуля)", "коробке патронов (Пуля)", "коробке патронов (Пуля)", "коробкой патронов (Пуля)", "коробке  патронов (Пуля)")
	desc = "Коробка для ружейных патронов (Пуля)"
	icon_state = "blushellbox"
	ammo_type = /obj/item/ammo_casing/shotgun
	caliber = "shotgun"
	multiple_sprites = MANY_STATES
	max_ammo = 8

/obj/item/ammo_box/eight_shells/buckshot
	name = "shotgun shells box (buckshot)"
	cases = list("коробки патронов (Картечь)", "коробки патронов (Картечь)", "коробке патронов (Картечь)", "коробке патронов (Картечь)", "коробкой патронов (Картечь)", "коробке патронов (Картечь)")
	desc = "Коробка для ружейных патронов (Картечь)"
	icon_state = "redshellbox"
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot

/obj/item/ammo_box/eight_shells/beanbag
	name = "shotgun shells box (beanbag)"
	cases = list("коробки патронов (Травматический)", "коробки патронов (Травматический)", "коробке патронов (Травматический)", "коробке патронов (Травматический)", "коробкой патронов (Травматический)", "коробке для патронов (Травматический)")
	desc = "Коробка для ружейных патронов (Травматический)."
	icon_state = "greenshellbox"
	ammo_type = /obj/item/ammo_casing/shotgun/beanbag

/obj/item/ammo_box/eight_shells/incendiary
	name = "shotgun shells box (incendiary)"
	cases = list("коробки патронов (Зажигательный)", "коробки патронов (Зажигательный)", "коробке патронов (Зажигательный)", "коробке патронов (Зажигательный)", "коробкой патронов (Зажигательный)", "коробке патронов (Зажигательный)")
	desc = "Коробка для ружейных патронов (Зажигательный)"
	icon_state = "orangeshellbox"
	ammo_type = /obj/item/ammo_casing/shotgun/incendiary

/obj/item/ammo_box/eight_shells/dart
	name = "shotgun shells box (dart)"
	cases = list("коробки патронов (Дротик)", "коробки патронов (Дротик)", "коробке патронов (Дротик)", "коробке патронов (Дротик)", "коробкой патронов (Дротик)", "коробке патронов (Дротик)")
	desc = "Коробка для ружейных патронов (Дротик)"
	icon_state = "purpleshellbox"
	ammo_type = /obj/item/ammo_casing/shotgun/dart

/obj/item/ammo_box/eight_shells/stunshot
	name = "shotgun shells box (stunshot)"
	cases = list("коробки патронов (Электрошок)", "коробки патронов (Электрошок)", "коробке патронов (Электрошок)", "коробке патронов (Электрошок)", "коробкой патронов (Электрошок)", "коробке патронов (Электрошок)")
	desc = "Коробка для ружейных патронов (Электрошок)"
	icon_state = "stanshellbox"
	ammo_type = /obj/item/ammo_casing/shotgun/stunshot
