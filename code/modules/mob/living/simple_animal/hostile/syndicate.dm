/mob/living/simple_animal/hostile/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = 4
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage = 10
	attacktext = "punch"
	var/corpse = /obj/effect/landmark/mobcorpse/syndicatesoldier
	var/weapon1
	var/weapon2
	var/gibs = /obj/effect/gibspawner/human
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	environment_smash = 1
	faction = "syndicate"
	status_flags = CANPUSH

	animalistic = FALSE
	has_head = TRUE
	has_arm = TRUE
	has_leg = TRUE

	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/syndicate/death()
	..()
	if(gibs)
		new gibs (src.loc)
		visible_message("<span class='warning'><b>[src]</b> is blown apart along with their equipment by their self-destruct mechanism!</span>")
	else
		if(corpse)
			new corpse (src.loc)
		if(weapon1)
			new weapon1 (src.loc)
		if(weapon2)
			new weapon2 (src.loc)
	qdel(src)
	return

///////////////Sword and shield////////////

/mob/living/simple_animal/hostile/syndicate/melee
	melee_damage = 23
	icon_state = "syndicatemelee"
	icon_living = "syndicatemelee"
	weapon1 = /obj/item/weapon/melee/energy/sword/red
	weapon2 = /obj/item/weapon/shield/energy
	attacktext = "slash"
	status_flags = 0

/mob/living/simple_animal/hostile/syndicate/melee/attackby(obj/item/O, mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(O.force)
		if(prob(80))
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			health -= damage
			visible_message("<span class='warning'><b>[src] has been attacked with the [O] by [user].</b></span>")
		else
			visible_message("<span class='warning'><b>[src] blocks the [O] with its shield!</b></span>")
	else
		to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
		visible_message("<span class='warning'>[user] gently taps [src] with the [O]. </span>")


/mob/living/simple_animal/hostile/syndicate/melee/bullet_act(obj/item/projectile/Proj)
	if(prob(65))
		return ..()
	else
		visible_message("<span class='warning'><B>[src] blocks [Proj] with its shield!</B></span>")
		return PROJECTILE_ABSORBED

/mob/living/simple_animal/hostile/syndicate/melee/space
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	icon_state = "syndicatemeleespace"
	icon_living = "syndicatemeleespace"
	name = "Syndicate Commando"
	corpse = /obj/effect/landmark/mobcorpse/syndicatecommando
	speed = 0

/mob/living/simple_animal/hostile/syndicate/melee/space/Process_Spacemove(movement_dir = 0)
	return

/mob/living/simple_animal/hostile/syndicate/ranged
	ranged = 1
	rapid = 1
	icon_state = "syndicateranged"
	icon_living = "syndicateranged"
	casingtype = /obj/item/ammo_casing/a12mm
	projectilesound = 'sound/weapons/guns/gunshot_light.ogg'
	projectiletype = /obj/item/projectile/bullet/midbullet2
	retreat_distance = 5
	minimum_distance = 5

	weapon1 = /obj/item/weapon/gun/projectile/automatic/c20r

/mob/living/simple_animal/hostile/syndicate/ranged/space
	icon_state = "syndicaterangedpsace"
	icon_living = "syndicaterangedpsace"
	name = "Syndicate Commando"
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	corpse = /obj/effect/landmark/mobcorpse/syndicatecommando
	speed = 0

/mob/living/simple_animal/hostile/syndicate/ranged/space/elite
	icon_state = "elitesyndicaterangedpsace"
	icon_living = "elitesyndicaterangedpsace"
	name = "Elite Syndicate Commando"
	maxHealth = 220
	health = 220
	projectiletype = /obj/item/projectile/bullet/rifle3
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	corpse = /obj/effect/landmark/mobcorpse/syndicatecommando
	speed = 0

	weapon1 = /obj/item/weapon/gun/projectile/automatic/c20r
	weapon2 = /obj/item/weapon/shield/energy

/mob/living/simple_animal/hostile/syndicate/ranged/space/Process_Spacemove(movement_dir = 0)
	return

/mob/living/simple_animal/hostile/viscerator
	name = "viscerator"
	desc = "A small, twin-bladed machine capable of inflicting very deadly lacerations."
	icon_state = "viscerator_attack"
	icon_living = "viscerator_attack"
	pass_flags = PASSTABLE
	health = 15
	maxHealth = 15
	melee_damage = 15
	attacktext = "slic"
	attack_sound = list('sound/weapons/bladeslice.ogg')
	faction = "syndicate"
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

/mob/living/simple_animal/hostile/viscerator/death()
	..()
	visible_message("<span class='warning'><b>[src]</b> is smashed into pieces!</span>")
	qdel(src)
	return
