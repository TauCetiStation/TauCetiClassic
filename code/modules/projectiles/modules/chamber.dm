/obj/item/modular/chambered
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
	gun_type = "bullet"
	m_amt = 2000

/obj/item/modular/chambered/laser
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
	gun_type = "laser"

/obj/item/modular/chambered/duolas
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
	gun_type = "laser"

/obj/item/modular/chambered/triolas
	icon_state = "chamber_laser_icon"
	icon_overlay = "chamber_laser"
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
	gun_type = "laser"

/obj/item/modular/chambered/l10
	icon_state = "chamber_energy"
	icon_overlay = "chamber_energy"
	name = "chamber l10"
	lessfiredelay = 5
	lessdamage = -4
	lessrecoil = 1
	size = 0.2
	caliber = "energy"
	multi_type = TRUE
	gun_energy = FALSE
	type_cap = 2
	charge_indicator = TRUE
	gun_type = "laser"

/obj/item/modular/chambered/bullet9mm
	icon_state = "chamber_bullet_icon"
	icon_overlay = "chamber_bullet"
	name = "chamber 9mm"
	lessfiredelay = 5
	lessdamage = -3
	lessrecoil = 0.2
	size = 0.2
	caliber = "9mm"
	type_cap = 1
	gun_type = "bullet"

/obj/item/modular/chambered/bullet357
	icon_state = "chamber_bullet_icon"
	icon_overlay = "chamber_bullet"
	name = "chamber 357"
	lessfiredelay = 5
	lessdamage = -3
	lessrecoil = 0.2
	size = 0.2
	caliber = "357"
	type_cap = 1
	gun_type = "bullet"

/obj/item/modular/chambered/bulletshotgun
	icon_state = "chamber_bullet_icon"
	icon_overlay = "chamber_bullet"
	name = "chamber shotgun"
	lessfiredelay = 3
	lessrecoil = -0.5
	lessdispersion = -0.3
	lessdamage = -3
	size = 0.3
	caliber = "shotgun"
	gun_type = "shotgun"
	type_cap = 1
	pellets = 7

/obj/item/modular/chambered/lasershotgun
	icon_state = "chamber_laser1"
	icon_overlay = "chamber_laser1"
	name = "chamber shotgun"
	lessfiredelay = 1
	lessrecoil = 1
	lessdamage = -3
	lessdispersion = -0.3
	size = 0.3
	caliber = "energy"
	gun_energy = TRUE
	charge_indicator = TRUE
	gun_type = "shotgun"
	type_cap = 1
	pellets = 4