/mob/living/simple_animal/hostile/demon
	name = "Imp"
	desc = "."
	icon = 'icons/mob/hellspawn.dmi'
	icon_state = "imp"
	icon_living = "imp"
	icon_dead = "imp_dead"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pushes the"
	response_disarm = "shoves"
	response_harm = "hits the"
	speed = 1
	stop_automated_movement_when_pulled = 0
	maxHealth = 50
	health = 50
	environment_smash = 1
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = " slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 1

	faction = "hell"

/mob/living/simple_animal/hostile/demon/death()
	playsound(src, 'sound/event/demon_death.wav', 100, 1)


/mob/living/simple_animal/hostile/demon/hellgazer
	name = "Hellgazer"
	desc = ""
	icon_state = "gazer"
	icon_living = "gazer"
	icon_dead = "imp_dead"
	melee_damage_lower = 10
	melee_damage_upper = 10
	speed = 4

/mob/living/simple_animal/hostile/demon/hellgazer/death()
	..()
	visible_message("<b>[src]</b> blows apart!")
	new /obj/effect/gibspawner/generic(src.loc)
	qdel(src)
	return

/mob/living/simple_animal/hostile/demon/caco
	name = "Cacodemon"
	desc = ""
	icon_state = "cac"
	icon_living = "cac"
	icon_dead = "cac_dead"
	melee_damage_lower = 5
	melee_damage_upper = 10
	speed = 3
	projectilesound = 'sound/event/gazer_shot.wav'
	ranged = 1
	rapid = 1
	retreat_distance = 0
	minimum_distance = 2
	stat_attack = 0
	projectiletype = /obj/item/projectile/energy/gazer_bolt

/obj/item/projectile/energy/gazer_bolt
	name = "hell bolt"
	icon = 'icons/mob/hellspawn.dmi'
	icon_state = "gz_bolt"
	damage = 6
	damage_type = HALLOSS
	nodamage = 1
	agony = 50
	stutter = 10

/mob/living/simple_animal/hostile/demon/revenant
	name = "Revenant"
	desc = ""
	icon_state = "revenant"
	icon_living = "revenant"
	icon_dead = "revenant_dead"
	projectilesound = 'sound/weapons/laser.ogg'
	ranged = 1
	rapid = 0
	retreat_distance = 0
	minimum_distance = 5
	maxHealth = 100
	health = 100
	projectiletype = /obj/item/projectile/energy/hell_light

/obj/item/projectile/energy/hell_light
	name = "hell bolt"
	icon_state = "red_1"
	damage = 10
	damage_type = BURN
	nodamage = 0
	agony = 10
	stutter = 10