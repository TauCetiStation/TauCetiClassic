/mob/living/simple_animal/hostile/dragonfly
	name = "«мий"
	desc = "Ћетающий шланг. ќпасен"
	icon_state = "dragonfly"
	icon_dead = "dragonfly_dead"
	speak = list("¬∆∆∆∆∆")
	speak_emote = list("жужит")
	faction = "tataliya"
	speak_chance = 20
	turns_per_move = 4
	speed = 5
	see_in_dark = 6
	maxHealth = 30
	health = 30
	melee_damage = 5
	attacktext = "∆алит"
	attack_sound = list('sound/weapons/bite.ogg')

/mob/living/simple_animal/hostile/dragonfly/AttackingTarget()
	..()
	var/mob/living/L = target
	L.reagents.add_reagent("stoxin", 5)