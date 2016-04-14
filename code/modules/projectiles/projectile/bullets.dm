/obj/item/projectile/bullet/weakbullet // "rubber" bullets
	damage = 10
	stun = 0
	weaken = 0
	agony = 80
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/pellet
	name = "pellet"
	damage = 20

/obj/item/projectile/bullet/weakbullet/beanbag		//because beanbags are not bullets
	name = "beanbag"
	agony = 95

/obj/item/projectile/bullet/weakbullet/rubber
	name = "rubber bullet"

/obj/item/projectile/bullet/midbullet //.45 ACP
	damage = 20
	stoping_power = 5

/obj/item/projectile/bullet/midbullet2 // 9x19
	damage = 25

/obj/item/projectile/bullet/revbullet //.357
	damage = 35
	stoping_power = 8

/obj/item/projectile/bullet/rifle1
	damage = 40
	embed = 0

/obj/item/projectile/bullet/rifle2
	damage = 45
	embed = 0

/obj/item/projectile/bullet/heavy/a145
	damage = 110
	stun = 3
	weaken = 3
	impact_force = 5
	hitscan = 1

/obj/item/projectile/bullet/grenade/r4046
	damage = 10
	stun = 10
	weaken = 10
	//impact_force = 5
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/suffocationbullet//How does this even work?
	name = "co bullet"
	damage = 20
	damage_type = OXY


/obj/item/projectile/bullet/cyanideround
	name = "poison bullet"
	damage = 40
	damage_type = TOX


/obj/item/projectile/bullet/burstbullet//I think this one needs something for the on hit
	name = "exploding bullet"
	damage = 20
	embed = 0
	edge = 1

/obj/item/projectile/bullet/stunslug
	name = "stunslug"
	icon_state = "spark"
	damage = 5
	stun = 0
	weaken = 0
	stutter = 10
	agony = 60
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/a762
	damage = 50
	embed = 0

/obj/item/projectile/bullet/incendiary
	name = "incendiary bullet"
	damage = 20

/obj/item/projectile/bullet/incendiary/on_hit(var/atom/target, var/blocked = 0)
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(10)
		M.IgniteMob()

/obj/item/projectile/bullet/chameleon
	damage = 1 // stop trying to murderbone with a fake gun dumbass!!!
	embed = 0 // nope
	fake = 1

//=================NEW PROJECTILES=================\\
/obj/item/projectile/l10
	name ="projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "l10"
	layer = 20
	light_color = "#2be4b8"
	light_power = 2
	light_range = 2
	damage = 15
	damage_type = BURN
	flag = "energy"
	eyeblur = 4
	sharp = 0
	edge = 0

	muzzle_type = /obj/effect/projectile/energy/muzzle
