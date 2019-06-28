/obj/item/modular/chambered
	icon_state = "chamber_bullet"
	name = "chamber"
	lessfiredelay = 6
	lessrecoil = 0.2
	size = 0.2
	var/caliber = "9mm"
	var/multi_type = FALSE
	var/gun_energy = FALSE
	var/type_cap = 1
	var/pellets = 0
	gun_type = "bullet"

/obj/item/modular/chambered/laser
	icon_state = "chamber_laser"
	name = "chamber laser"
	lessfiredelay = 4
	lessrecoil = 1
	size = 0.2
	caliber = "energy"
	multi_type = FALSE
	gun_energy = TRUE
	type_cap = 1
	gun_type = "laser"

/obj/item/modular/chambered/duolas
	icon_state = "chamber_laser"
	name = "chamber laser-taser"
	lessfiredelay = 4
	lessrecoil = 1
	size = 0.2
	caliber = "energy"
	multi_type = TRUE
	gun_energy = TRUE
	type_cap = 2
	gun_type = "laser"

/obj/item/modular/chambered/bullet9mm
	icon_state = "chamber_bullet"
	name = "chamber 9mm"
	lessfiredelay = 5
	lessrecoil = 0.2
	size = 0.2
	caliber = "9mm"
	type_cap = 1
	gun_type = "bullet"

/obj/item/modular/chambered/bullet357
	icon_state = "chamber_bullet"
	name = "chamber 357"
	lessfiredelay = 5
	lessrecoil = 0.2
	size = 0.2
	caliber = "357"
	type_cap = 1
	gun_type = "bullet"

/obj/item/modular/chambered/bulletshotgun
	icon_state = "chamber_bullet"
	name = "chamber shotgun"
	lessfiredelay = 2
	lessrecoil = -0.5
	size = 0.3
	caliber = "shotgun"
	gun_type = "shotgun"
	type_cap = 1
	pellets = 4

/obj/item/modular/chambered/lasershotgun
	icon_state = "chamber_laser"
	name = "chamber shotgun"
	lessfiredelay = 1
	lessrecoil = 1
	size = 0.3
	caliber = "energy"
	gun_energy = TRUE
	gun_type = "laser"
	type_cap = 1
	pellets = 4