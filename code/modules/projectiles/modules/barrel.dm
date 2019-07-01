/obj/item/modular/barrel
	name = "barrel"
	lessdispersion = 0.2
	lessdamage = 0
	size = 0.2
	gun_type = ALL_TYPE_MODULARGUN
	m_amt = 700

/obj/item/modular/barrel/small
	icon_state = "barrel_small_icon"
	icon_overlay = "barrel_small"
	name = "small barrel"
	lessdispersion = -0.3
	lessdamage = 7
	size = 0.1
	gun_type = ALL_TYPE_MODULARGUN

/obj/item/modular/barrel/small/threaded
	name = "threaded small barrel"
	lessdispersion = -0.2
	lessdamage = 6
	size = 0.1
	gun_type = list("bullet", "shotgun")

/obj/item/modular/barrel/medium
	icon_state = "barrel_medium_icon"
	icon_overlay = "barrel_medium"
	name = "medium barrel"
	lessdispersion = 0.0
	lessdamage = 4
	size = 0.2
	gun_type = ALL_TYPE_MODULARGUN

/obj/item/modular/barrel/medium/threaded
	name = "threader medium barrel"
	lessdispersion = 0.2
	lessdamage = 3
	size = 0.2
	gun_type = list("bullet", "shotgun")

/obj/item/modular/barrel/large
	icon_state = "barrel_large_icon"
	icon_overlay = "barrel_large"
	name = "large barrel"
	lessdispersion = 0.6
	lessdamage = -3
	lessrecoil = 0.1
	size = 0.4
	gun_type = ALL_TYPE_MODULARGUN

/obj/item/modular/barrel/large/threaded
	name = "threaded large barrel"
	lessdispersion = 0.8
	lessdamage = -5
	lessrecoil = 0.1
	size = 0.4
	gun_type = list("bullet", "shotgun")

/obj/item/modular/barrel/large/laser_rifle
	name = "large barrel laser rifle"
	icon_state = "barrel_large_laser"
	icon_overlay = "barrel_large_laser"
	lessdispersion = 1.3
	lessdamage = 2
	lessrecoil = 0.2
	size = 0.6
	gun_type = list("laser", "shotgun")

/obj/item/modular/barrel/large/bullet_rifle
	name = "large barrel bullet rifle"
	icon_state = "barrel_large_bullet"
	icon_overlay = "barrel_large_bullet"
	lessdispersion = 1
	lessdamage = -3
	lessrecoil = 0.1
	size = 0.6
	gun_type = list("bullet", "shotgun")

/obj/item/modular/barrel/medium/bullet_pistol
	name = "medium barrel bullet pistol"
	icon_state = "barrel_medium_bullet"
	icon_overlay = "barrel_medium_bullet"
	lessdispersion = 0.7
	lessdamage = -2
	lessrecoil = 0.2
	size = 0.4
	gun_type = list("bullet", "shotgun")

/obj/item/modular/barrel/medium/laser_pistol
	name = "medium barrel laser pistol"
	icon_state = "barrel_medium_laser"
	icon_overlay = "barrel_medium_laser"
	lessdispersion = 0.9
	lessdamage = 2
	lessrecoil = 0.2
	size = 0.4
	gun_type = list("laser", "shotgun")