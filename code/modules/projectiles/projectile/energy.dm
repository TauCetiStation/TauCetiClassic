/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = ENERGY

/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	light_color = "#f2f5a9"
	light_power = 2
	light_range = 2
	nodamage = 1

	stun = 0
	weaken = 0
	stutter = 10
	agony = 120
	damage_type = HALLOSS
	//Damage will be handled on the MOB side, to prevent window shattering.

/obj/item/projectile/energy/declone
	name = "declone"
	icon_state = "declone"
	light_color = "#00ff00"
	light_power = 2
	light_range = 2
	nodamage = 1
	damage_type = CLONE
	irradiate = 40

/obj/item/projectile/energy/declone/light
	irradiate = 30

/obj/item/projectile/energy/dart
	name = "dart"
	icon_state = "toxin"
	light_color = "#00ff00"
	light_power = 2
	light_range = 2
	damage = 5
	damage_type = TOX
	weaken = 5
	stun = 5

/obj/item/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 10
	damage_type = TOX
	nodamage = 0
	weaken = 10
	stun = 10
	stutter = 10


/obj/item/projectile/energy/bolt/large
	name = "largebolt"
	damage = 20

/obj/item/projectile/energy/holy
	name = "holy bolt"
	damage = 25
	light_color = LIGHT_COLOR_PLASMA
	light_power = 2
	light_range = 2
	icon_state = "omnilaser"

/obj/item/projectile/energy/holy/on_hit(atom/target)
	if(ishuman(target) && iscultist(target))
		var/mob/living/carbon/human/H = target
		H.Stun(3)
		H.Weaken(3)
		H.throw_at(get_edge_target_turf(H, dir), 1, 1, firer, spin = TRUE)

/obj/item/projectile/energy/phoron
	name = "phoron bolt"
	icon_state = "energy"
	light_color = "#00ff00"
	light_power = 2
	light_range = 2
	damage = 20
	damage_type = TOX
	irradiate = 20

/obj/item/projectile/energy/laser
	name = "laser"
	icon_state = "laser"
	light_color = "red"
	light_power = 2
	light_range = 2
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 40


/obj/item/projectile/energy/laser/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_LASERACT

/obj/item/projectile/energy/phaser
	name = "phaser bolt"
	icon_state = "phaser"
	light_color = LIGHT_COLOR_PLASMA
	light_power = 2
	light_range = 2
	damage = 25
	light_color = COLOR_PAKISTAN_GREEN

/obj/item/projectile/energy/phaser/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_LASERACT
