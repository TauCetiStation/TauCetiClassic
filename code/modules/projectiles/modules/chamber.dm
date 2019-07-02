/obj/item/modular/chamber
	icon_state = "chamber_bullet_icon"
	name = "chamber"
	lessfiredelay = 6
	lessdamage = -2
	lessrecoil = 0.2
	size = 0.2
	var/caliber = "9mm"
	var/multi_type = FALSE
	var/gun_energy = FALSE
	var/type_cap = 1
	var/pellets = 0
	var/charge_indicator = FALSE
	gun_type = BULLET
	m_amt = 2000

/obj/item/modular/chamber/laser
	icon_state = "chamber_laser_icon"
	icon_overlay = "chamber_laser"
	name = "chamber laser"
	lessfiredelay = 5
	lessdamage = -4
	lessrecoil = 1
	size = 0.2
	caliber = "energy"
	multi_type = FALSE
	gun_energy = TRUE
	type_cap = 1
	charge_indicator = TRUE
	gun_type = LASER

/obj/item/modular/chamber/duolas
	icon_state = "chamber_laser_icon"
	icon_overlay = "chamber_laser"
	name = "chamber duo laser"
	lessfiredelay = 5
	lessdamage = -5
	lessrecoil = 1
	size = 0.2
	caliber = "energy"
	multi_type = TRUE
	gun_energy = TRUE
	type_cap = 2
	charge_indicator = TRUE
	gun_type = LASER

/obj/item/modular/chamber/triolas
	icon_state = "chamber_energy"
	icon_overlay = "chamber_energy"
	name = "chamber trio laser"
	lessfiredelay = 5
	lessdamage = -4
	lessrecoil = 1
	size = 0.2
	caliber = "energy"
	multi_type = TRUE
	gun_energy = TRUE
	type_cap = 3
	charge_indicator = TRUE
	gun_type = LASER

/obj/item/modular/chamber/l10
	icon_state = "chamber_laser1"
	icon_overlay = "chamber_laser1"
	name = "chamber l10"
	lessfiredelay = 5
	lessdamage = -4
	lessrecoil = 1
	size = 0.2
	caliber = "energy"
	multi_type = TRUE
	gun_energy = FALSE
	type_cap = 2
	gun_type = LASER

/obj/item/modular/chamber/bullet9mm
	icon_state = "chamber_bullet_icon"
	icon_overlay = "chamber_bullet"
	name = "chamber 9mm"
	lessfiredelay = 5
	lessdamage = -3
	lessrecoil = 0.2
	size = 0.2
	caliber = "9mm"
	type_cap = 1
	gun_type = BULLET

/obj/item/modular/chamber/bullet357
	icon_state = "chamber_bullet_icon"
	icon_overlay = "chamber_bullet"
	name = "chamber 357"
	lessfiredelay = 5
	lessdamage = -3
	lessrecoil = 0.2
	size = 0.2
	caliber = "357"
	type_cap = 1
	gun_type = BULLET

/obj/item/modular/chamber/bulletshotgun
	icon_state = "chamber_bullet_icon"
	icon_overlay = "chamber_bullet"
	name = "chamber shotgun"
	lessfiredelay = 3
	lessrecoil = -0.5
	lessdispersion = -0.8
	lessdamage = 6
	size = 0.3
	caliber = "shotgun"
	gun_type = SHOTGUN
	type_cap = 1
	pellets = 7

/obj/item/modular/chamber/lasershotgun
	icon_state = "chamber_laser1"
	icon_overlay = "chamber_laser1"
	name = "chamber shotgun"
	lessfiredelay = 1
	lessrecoil = 1
	lessdamage = 6
	lessdispersion = -0.8
	size = 0.3
	caliber = "energy"
	gun_energy = TRUE
	charge_indicator = FALSE
	gun_type = SHOTGUN
	type_cap = 1
	pellets = 4