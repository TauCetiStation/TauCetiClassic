/mob/living/simple_animal/hostile/creature
	name = "creature"
	desc = "Разрушающее здравомыслие... что-то."
	speak_emote = list("gibbers")
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 80
	maxHealth = 80
	melee_damage = 38
	w_class = SIZE_HUMAN
	attacktext = "chomp"
	attack_sound = list('sound/weapons/bite.ogg')
	faction = "creature"
	speed = 4

/mob/living/simple_animal/hostile/illusion
	name = "illusion"
	desc = "Что-то, чего нет. Но вы же это видите?"
	icon_state = "otherthing" //It doesnt need it
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	icon_dead = "null"
	gender = NEUTER
	speed = -1
	environment_smash = 0
	maxHealth = 100
	health = 100
	melee_damage = 5
	/// Weakref to what we're copying
	var/datum/weakref/parent_mob_ref

/mob/living/simple_animal/hostile/illusion/death(gibbed)
	. = ..()
	qdel(src)

/mob/living/simple_animal/hostile/illusion
	/// Prob of getting a clone on attack
	var/multiply_chance = 0

/mob/living/simple_animal/hostile/illusion/proc/Copy_Parent(mob/living/original, life = 5 SECONDS, hp = 100, damage = 0, replicate = 0)
	appearance = original.appearance
	parent_mob_ref = WEAKREF(original)
	set_dir(original.dir)
	maxHealth = hp
	updatehealth() // re-cap health to new value
	multiply_chance = replicate
	transform = initial(transform)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living, death)), life)

/mob/living/simple_animal/hostile/illusion/examine(mob/user)
	var/mob/living/parent_mob = parent_mob_ref?.resolve()
	if(parent_mob)
		return parent_mob.examine(user)
	return ..()

/mob/living/simple_animal/hostile/illusion/AttackTarget()
	. = ..()
	if(!. || !isliving(target) || !prob(multiply_chance))
		return
	var/mob/living/hitting_target = target
	if(hitting_target.stat == DEAD)
		return
	var/mob/living/parent_mob = parent_mob_ref?.resolve()
	if(isnull(parent_mob))
		return
	var/mob/living/simple_animal/hostile/illusion/new_clone = new(loc)
	new_clone.Copy_Parent(parent_mob, 8 SECONDS, health / 2, melee_damage, multiply_chance / 2)
	new_clone.faction = faction
	new_clone.GiveTarget(target)

/mob/living/simple_animal/hostile/illusion/get_unarmed_attack()
	. = ..()
	var/mob/living/parent_mob = parent_mob_ref?.resolve()
	if(parent_mob)
		. = parent_mob.get_unarmed_attack()
		.["damage"] = melee_damage

///////Actual Types/////////

/mob/living/simple_animal/hostile/illusion/escape
	retreat_distance = 10
	minimum_distance = 10
	speed = -1

/mob/living/simple_animal/hostile/illusion/escape/AttackTarget()
	return FALSE
