/mob/living/simple_animal/hostile/russian
	name = "Russian"
	desc = "За матушку Россию!"
	icon_state = "russianmelee"
	icon_living = "russianmelee"
	icon_dead = "russianmelee_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = 4
	stop_automated_movement_when_pulled = FALSE
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage = 15
	attacktext = "punch"
	var/corpse = /obj/effect/landmark/mobcorpse/russian
	var/weapon1 = /obj/item/weapon/kitchenknife
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "russian"
	status_flags = CANPUSH

	animalistic = FALSE
	has_head = TRUE
	has_arm = TRUE
	has_leg = TRUE

	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/russian/ranged
	icon_state = "russianranged"
	icon_living = "russianranged"
	corpse = /obj/effect/landmark/mobcorpse/russian/ranged
	weapon1 = /obj/item/weapon/gun/projectile/revolver/mateba
	ranged = TRUE
	projectiletype = /obj/item/projectile/bullet
	projectilesound = 'sound/weapons/guns/Gunshot.ogg'
	casingtype = /obj/item/ammo_casing/a357


/mob/living/simple_animal/hostile/russian/death()
	..()
	if(corpse)
		new corpse (src.loc)
	if(weapon1)
		new weapon1 (src.loc)
	qdel(src)
	return
