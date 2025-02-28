/mob/living/simple_animal/heretic_summon/fire_shark
	name = "\improper Fire Shark"
	real_name = "Fire Shark"
	desc = "It is a eldritch dwarf space shark, also known as a fire shark."
	icon_state = "fire_shark"
	icon_living = "fire_shark"
	pass_flags = PASSTABLE | PASSMOB
	speed = -0.5
	health = 16
	maxHealth = 16
	melee_damage = 8
	attack_sound = list('sound/weapons/bite.ogg')
	ventcrawler = 2
	attack_vis_effect = ATTACK_EFFECT_BITE
	obj_damage = 0
	attacktext = "bite"
	damage_coeff = list(BRUTE = 1, BURN = 0.25, TOX = 0, HALLOSS = 0, OXY = 0)
	faction = "heretic"
	w_class = SIZE_TINY
	speak_emote = list("screams")
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile_obstacles
	initial_language_holder = /datum/language_holder/carp/hear_common

/mob/living/simple_animal/heretic_summon/fire_shark/atom_init()
	. = ..()
	AddElement(/datum/element/death_gases, /datum/gas/plasma, 40)
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/venomous, /datum/reagent/phlogiston, 2, injection_flags = INJECT_CHECK_PENETRATE_THICK)
	AddComponent(/datum/component/swarming)
	AddComponent(/datum/component/regenerator, outline_colour = COLOR_DARK_RED)
	ADD_TRAIT(src, TRAIT_ARIBORN, TRAIT_ARIBORN_FLYING)
