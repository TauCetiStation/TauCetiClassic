/mob/living/simple_animal/hostile/xenomorph
	name = "alien hunter"
	desc = "Hiss!"
	icon = 'icons/mob/alien.dmi'
	icon_state = "alienh_running"
	icon_living = "alienh_running"
	icon_dead = "alien_l"
	icon_gib = "syndicate_gib"
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = -1
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/xenomeat = 3)
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage = 25
	attacktext = "slash"
	attack_sound = list('sound/weapons/bladeslice.ogg')
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "alien"
	environment_smash = 1
	status_flags = CANPUSH
	minbodytemp = 0
	heat_damage_per_tick = 20

	has_head = TRUE
	has_arm = TRUE
	has_leg = TRUE

/mob/living/simple_animal/hostile/xenomorph/atom_init()
	. = ..()
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_CLAW)

/mob/living/simple_animal/hostile/xenomorph/drone
	name = "alien drone"
	icon_state = "aliend_running"
	icon_living = "aliend_running"
	icon_dead = "aliend_l"
	health = 60
	melee_damage = 15

/mob/living/simple_animal/hostile/xenomorph/sentinel
	name = "alien sentinel"
	icon_state = "aliens_running"
	icon_living = "aliens_running"
	icon_dead = "aliens_l"
	health = 120
	melee_damage = 15
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'


/mob/living/simple_animal/hostile/xenomorph/queen
	name = "alien queen"
	icon_state = "alienq_running"
	icon_living = "alienq_running"
	icon_dead = "alienq_l"
	health = 250
	maxHealth = 250
	melee_damage = 15
	ranged = 1
	move_to_delay = 3
	retreat_distance = 5
	minimum_distance = 5
	projectiletype = /obj/item/projectile/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'
	rapid = 1
	status_flags = 0

/mob/living/simple_animal/hostile/xenomorph/queen/large
	name = "alien empress"
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "queen_s"
	icon_living = "queen_s"
	icon_dead = "queen_dead"
	move_to_delay = 4
	maxHealth = 400
	health = 400

/obj/item/projectile/neurotox
	damage = 30
	icon_state = "toxin"

/mob/living/simple_animal/hostile/xenomorph/death()
	..()
	visible_message("[src] lets out a waning guttural screech, green blood bubbling from its maw...")
	playsound(src, 'sound/voice/xenomorph/death_1.ogg', VOL_EFFECTS_MASTER)
