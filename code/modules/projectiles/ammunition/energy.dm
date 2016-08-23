/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	desc = "The part of the gun that makes the laser go pew."
	caliber = "energy"
	projectile_type = /obj/item/projectile/energy
	var/e_cost = 100 //The amount of energy a cell needs to expend to create this shot.
	var/select_name = "energy"
	var/mod_name = null
	var/s_fire = 'sound/weapons/Laser.ogg'

/obj/item/ammo_casing/energy/laser
	projectile_type = /obj/item/projectile/beam
	select_name = "kill"

/obj/item/ammo_casing/energy/laser_pulse
	projectile_type = /obj/item/projectile/energy/laser
	select_name = "kill"
	e_cost = 50
	fire_sound = 'sound/weapons/guns/laser3.ogg'

/obj/item/ammo_casing/energy/laser/practice
	projectile_type = /obj/item/projectile/beam/practice
	select_name = "practice"

/obj/item/ammo_casing/energy/laser/scatter
	projectile_type = /obj/item/projectile/beam/scatter
	pellets = 5
	variance = 0.8
	select_name = "scatter"

/obj/item/ammo_casing/energy/laser/heavy
	projectile_type = /obj/item/projectile/beam/heavylaser
	select_name = "anti-vehicle"
	s_fire = 'sound/weapons/lasercannonfire.ogg'

/obj/item/ammo_casing/energy/laser/pulse
	projectile_type = /obj/item/projectile/beam/pulse
	e_cost = 200
	select_name = "DESTROY"
	s_fire = 'sound/weapons/pulse.ogg'

/obj/item/ammo_casing/energy/laser/bluetag
	projectile_type = /obj/item/projectile/beam/lastertag/blue
	select_name = "bluetag"

/obj/item/ammo_casing/energy/laser/redtag
	projectile_type = /obj/item/projectile/beam/lastertag/red
	select_name = "redtag"

/obj/item/ammo_casing/energy/bolt
	projectile_type = /obj/item/projectile/energy/bolt
	select_name = "bolt"
	s_fire = 'sound/weapons/Genhit.ogg'

/obj/item/ammo_casing/energy/bolt/large
	projectile_type = /obj/item/projectile/energy/bolt/large
	select_name = "heavy bolt"

/obj/item/ammo_casing/energy/xray
	projectile_type = /obj/item/projectile/beam/xray
	e_cost = 50
	s_fire = 'sound/weapons/laser3.ogg'

/obj/item/ammo_casing/energy/electrode
	projectile_type = /obj/item/projectile/energy/electrode
	select_name = "stun - electrode"
	s_fire = 'sound/weapons/taser.ogg'

/obj/item/ammo_casing/energy/electrode/cheap
	e_cost = 75

/obj/item/ammo_casing/energy/stun/cheap
	e_cost = 75

/obj/item/ammo_casing/energy/stun
	projectile_type = /obj/item/projectile/beam/stun
	select_name = "stun"
	s_fire = 'sound/weapons/taser.ogg'

/obj/item/ammo_casing/energy/electrode/gun
	s_fire = 'sound/weapons/gunshot.ogg'

/obj/item/ammo_casing/energy/stun/gun
	s_fire = 'sound/weapons/gunshot.ogg'

/obj/item/ammo_casing/energy/ion
	projectile_type = /obj/item/projectile/ion
	select_name = "ion"
	s_fire = 'sound/weapons/Laser.ogg'

/obj/item/ammo_casing/energy/declone
	projectile_type = /obj/item/projectile/energy/declone
	select_name = "declone"
	s_fire = 'sound/weapons/pulse3.ogg'

/obj/item/ammo_casing/energy/declone/light
	projectile_type = /obj/item/projectile/energy/declone/light

/obj/item/ammo_casing/energy/mindflayer
	projectile_type = /obj/item/projectile/beam/mindflayer
	select_name = "MINDFUCK"
	s_fire = 'sound/weapons/Laser.ogg'

/obj/item/ammo_casing/energy/flora
	s_fire = 'sound/effects/stealthoff.ogg'

/obj/item/ammo_casing/energy/flora/yield
	projectile_type = /obj/item/projectile/energy/florayield
	select_name = "increase yield"
	mod_name = "yield"

/obj/item/ammo_casing/energy/flora/mut
	projectile_type = /obj/item/projectile/energy/floramut
	select_name = "induce mutations"
	mod_name = "mut"

/obj/item/ammo_casing/energy/temp
	projectile_type = /obj/item/projectile/temp
	select_name = "freeze"
	e_cost = 250
	s_fire = 'sound/weapons/pulse3.ogg'

/obj/item/ammo_casing/energy/temp/hot
	projectile_type = /obj/item/projectile/temp/hot
	select_name = "bake"

/obj/item/ammo_casing/energy/meteor
	projectile_type = /obj/item/projectile/meteor
	select_name = "goddamn meteor"

/obj/item/ammo_casing/energy/toxin
	projectile_type = /obj/item/projectile/energy/phoron
	select_name = "phoron"
	s_fire = 'sound/effects/stealthoff.ogg'

/obj/item/ammo_casing/energy/sniper
	projectile_type = /obj/item/projectile/beam/sniper
	select_name = "sniper"
	e_cost = 250
	s_fire = 'sound/weapons/marauder.ogg'

