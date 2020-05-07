/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"
	embed = 1
	sharp = 1
	var/stoping_power = 0

	muzzle_type = /obj/effect/projectile/bullet/muzzle

/obj/item/projectile/bullet/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_BULLETACT

/obj/item/projectile/bullet/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if (..())
		var/mob/living/L = target
		shake_camera(L, 3, 2)

/obj/item/projectile/bullet/weakbullet // "rubber" bullets
	damage = 10
	stun = 0
	weaken = 0
	agony = 40
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/weakbullet/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_WEAKBULLETACT

/obj/item/projectile/bullet/buckpellet
	name = "buckpellet"
	damage = 14
	dispersion = 2.5

/obj/item/projectile/bullet/pellet
	name = "pellet"
	damage = 20

/obj/item/projectile/bullet/weakbullet/beanbag		//because beanbags are not bullets
	name = "beanbag"
	agony = 95

/obj/item/projectile/bullet/weakbullet/rubber
	name = "rubber bullet"

/obj/item/projectile/bullet/weakbullet/rubber45 //to manage .45 pain damage
	name = "rubber bullet"
	agony = 55

/obj/item/projectile/bullet/smg //.45 ACP
	name = "submachinegun bullet"
	damage = 20

/obj/item/projectile/bullet/smg_hp
	name = "high power bullet"
	damage = 35

/obj/item/projectile/bullet/smg_imp
	name = "impact bullet"
	damage = 20
	impact_force = 1
	stoping_power = 4

/obj/item/projectile/bullet/smg_hv
	name = "high velocity bullet"
	damage = 20
	hitscan = 1

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

/obj/item/projectile/bullet/rifle3
	damage = 35
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

/obj/item/projectile/bullet/grenade/r4046/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_WEAKBULLETACT

/obj/item/projectile/bullet/grenade/r4046/rubber
	name = "rubber grenade"

/obj/item/projectile/bullet/chem
	damage = 5
	stun = 2
	var/list/beakers					// for grenade

/obj/item/projectile/bullet/chem/atom_init()
	. = ..()
	proj_act_sound = null

/obj/item/projectile/bullet/chem/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(beakers != null)
		var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/Big = new /obj/item/weapon/reagent_containers/glass/beaker/bluespace(src)
		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			G.reagents.trans_to(Big, G.reagents.total_volume)
	return 1

/obj/item/projectile/bullet/chem/teargas

/obj/item/projectile/bullet/chem/teargas/atom_init()
	. = ..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
	B1.reagents.add_reagent("condensedcapsaicin", 15)
	B1.reagents.add_reagent("potassium", 15)
	B2.reagents.add_reagent("phosphorus", 15)
	B2.reagents.add_reagent("sugar", 15)

	beakers = list()
	beakers += B1
	beakers += B2


/obj/item/projectile/bullet/chem/EMP

/obj/item/projectile/bullet/chem/EMP/atom_init()
	. = ..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
	B1.reagents.add_reagent("uranium", 15)
	B2.reagents.add_reagent("iron", 15)

	beakers = list()
	beakers += B1
	beakers += B2

/obj/item/projectile/bullet/chem/Exp
	damage = 20
	stun = 5

/obj/item/projectile/bullet/chem/Exp/atom_init()
	. = ..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
	B1.reagents.add_reagent("glycerol", 15)
	B1.reagents.add_reagent("pacid", 15)
	B2.reagents.add_reagent("sacid", 15)

	beakers = list()
	beakers += B1
	beakers += B2


/obj/item/projectile/bullet/suffocationbullet//How does this even work?
	name = "co bullet"
	damage = 20
	damage_type = OXY

/obj/item/projectile/bullet/suffocationbullet/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_WEAKBULLETACT

/obj/item/projectile/bullet/cyanideround
	name = "poison bullet"
	damage = 40
	damage_type = TOX

/obj/item/projectile/bullet/cyanideround/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_WEAKBULLETACT

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

/obj/item/projectile/bullet/stunslug/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_WEAKBULLETACT

/obj/item/projectile/bullet/a762
	damage = 50
	embed = 0

/obj/item/projectile/bullet/incendiary
	name = "incendiary bullet"
	damage = 20

/obj/item/projectile/bullet/incendiary/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(10)
		M.IgniteMob()

/obj/item/projectile/bullet/chameleon
	damage = 1 // stop trying to murderbone with a fake gun dumbass!!!
	embed = 0 // nope
	fake = 1

/obj/item/projectile/bullet/chameleon/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_WEAKBULLETACT

/obj/item/projectile/bullet/midbullet3
	damage = 35

/obj/item/projectile/bullet/flare
	name = "flare"
	icon_state= "bolter"
	damage = 5
	light_range = 8

/obj/item/projectile/bullet/flare/atom_init()
	. = ..()
	proj_act_sound = SOUNDIN_WEAKBULLETACT

/obj/item/projectile/bullet/flare/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(1)
		M.IgniteMob()
