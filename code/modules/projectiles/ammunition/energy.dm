/obj/item/ammo_casing/energy
	name = "energy weapon lens"
	icon = 'code/modules/projectiles/modules/modular.dmi'
	icon_state = "lens"
	color = "#cc0b00"
	desc = "The part of the gun that makes the laser go pew."
	caliber = "energy"
	projectile_type = /obj/item/projectile/energy
	fire_sound = 'sound/weapons/guns/gunpulse_laser.ogg'
	var/e_cost = 100 //The amount of energy a cell needs to expend to create this shot.
	var/select_name = "energy"
	var/mod_name = null
	var/icon_overlay = "lens_overlay"

/obj/item/ammo_casing/energy/laser
	projectile_type = /obj/item/projectile/beam
	name = "energy weapon lens laser"
	select_name = "kill"

/obj/item/ammo_casing/energy/laser_pulse
	projectile_type = /obj/item/projectile/energy/laser
	select_name = "kill"
	name = "energy weapon lens laser pulse"
	e_cost = 50
	fire_sound = 'sound/weapons/guns/gunpulse_laser3.ogg'

/obj/item/ammo_casing/energy/laser/practice
	projectile_type = /obj/item/projectile/beam/practice
	select_name = "practice"
	name = "energy weapon practice"

/obj/item/ammo_casing/energy/laser/scatter
	projectile_type = /obj/item/projectile/beam/scatter
	pellets = 5
	variance = 0.9
	select_name = "scatter"
	name = "energy weapon lens scatter"

/obj/item/ammo_casing/energy/laser/heavy
	projectile_type = /obj/item/projectile/beam/heavylaser
	select_name = "anti-vehicle"
	fire_sound = 'sound/weapons/guns/lasercannonfire.ogg'
	name = "energy weapon lens heavy"

/obj/item/ammo_casing/energy/laser/pulse
	projectile_type = /obj/item/projectile/beam/pulse
	e_cost = 200
	color = "#8ae6ff"
	select_name = "DESTROY"
	fire_sound = 'sound/weapons/guns/gunpulse.ogg'
	name = "energy weapon lens pulse"

/obj/item/ammo_casing/energy/laser/bluetag
	projectile_type = /obj/item/projectile/beam/lastertag/blue
	select_name = "bluetag"
	color = "#8ae6ff"
	name = "energy weapon lens bluetag"

/obj/item/ammo_casing/energy/laser/redtag
	projectile_type = /obj/item/projectile/beam/lastertag/red
	select_name = "redtag"
	name = "energy weapon lens redtag"

/obj/item/ammo_casing/energy/bolt
	projectile_type = /obj/item/projectile/energy/bolt
	select_name = "bolt"
	fire_sound = 'sound/weapons/Genhit.ogg'
	name = "energy weapon lens bolt"

/obj/item/ammo_casing/energy/bolt/large
	projectile_type = /obj/item/projectile/energy/bolt/large
	select_name = "heavy bolt"
	name = "energy weapon lens heavy bolt"

/obj/item/ammo_casing/energy/xray
	projectile_type = /obj/item/projectile/beam/xray
	e_cost = 50
	color = "#00fa01"
	fire_sound = 'sound/weapons/guns/gunpulse_laser3.ogg'
	name = "energy weapon lens xray"

/obj/item/ammo_casing/energy/electrode
	projectile_type = /obj/item/projectile/energy/electrode
	select_name = "stun - electrode"
	color = "#d5e600"
	fire_sound = 'sound/weapons/guns/gunpulse_taser.ogg'
	name = "energy weapon lens electrode"

/obj/item/ammo_casing/energy/stun
	projectile_type = /obj/item/projectile/beam/stun
	select_name = "stun"
	fire_sound = 'sound/weapons/guns/gunpulse_taser.ogg'
	color = "#d5e600"
	e_cost = 50
	name = "energy weapon lens stun"

/obj/item/ammo_casing/energy/electrode/gun
	fire_sound = 'sound/weapons/guns/gunpulse_stunrevolver.ogg'

/obj/item/ammo_casing/energy/stun/gun
	fire_sound = 'sound/weapons/guns/gunpulse_stunrevolver.ogg'

/obj/item/ammo_casing/energy/ion
	projectile_type = /obj/item/projectile/ion
	select_name = "ion"
	fire_sound = 'sound/weapons/guns/gunpulse_laser.ogg'
	name = "energy weapon lens ion"
	color = "#8ae6ff"

/obj/item/ammo_casing/energy/declone
	projectile_type = /obj/item/projectile/energy/declone
	select_name = "declone"
	fire_sound = 'sound/weapons/guns/gunpulse3.ogg'
	name = "energy weapon lens declone"

/obj/item/ammo_casing/energy/declone/light
	projectile_type = /obj/item/projectile/energy/declone/light
	name = "energy weapon lens declone light"

/obj/item/ammo_casing/energy/mindflayer
	projectile_type = /obj/item/projectile/beam/mindflayer
	select_name = "MINDFUCK"
	fire_sound = 'sound/weapons/guns/gunpulse_laser.ogg'
	name = "energy weapon lens mindflayer"

/obj/item/ammo_casing/energy/flora
	fire_sound = 'sound/effects/stealthoff.ogg'
	name = "energy weapon lens flora"

/obj/item/ammo_casing/energy/flora/yield
	projectile_type = /obj/item/projectile/energy/florayield
	select_name = "increase yield"
	mod_name = "yield"
	name = "energy weapon lens flora yield"

/obj/item/ammo_casing/energy/flora/mut
	projectile_type = /obj/item/projectile/energy/floramut
	select_name = "induce mutations"
	mod_name = "mut"
	name = "energy weapon lens flora yield"

/obj/item/ammo_casing/energy/temp
	projectile_type = /obj/item/projectile/temp
	select_name = "freeze"
	e_cost = 250
	fire_sound = 'sound/weapons/guns/gunpulse3.ogg'
	name = "energy weapon lens temperature hold"

/obj/item/ammo_casing/energy/temp/hot
	projectile_type = /obj/item/projectile/temp/hot
	select_name = "bake"
	name = "energy weapon lens temperature hot"

/obj/item/ammo_casing/energy/meteor
	projectile_type = /obj/item/projectile/meteor
	select_name = "goddamn meteor"
	name = "energy weapon lens meteor"

/obj/item/ammo_casing/energy/toxin
	projectile_type = /obj/item/projectile/energy/phoron
	select_name = "phoron"
	fire_sound = 'sound/effects/stealthoff.ogg'
	name = "energy weapon lens phoron"

/obj/item/ammo_casing/energy/sniper
	projectile_type = /obj/item/projectile/beam/sniper
	select_name = "sniper"
	e_cost = 250
	fire_sound = 'sound/weapons/guns/marauder.ogg'
	name = "energy weapon lens sniper"

/obj/item/ammo_casing/energy/rails
	projectile_type = /obj/item/projectile/beam/rails
	select_name = "rails"
	e_cost = 100
	fire_sound = 'sound/weapons/guns/gunpulse_railgun.ogg'
	name = "energy weapon lens sniper rails"
