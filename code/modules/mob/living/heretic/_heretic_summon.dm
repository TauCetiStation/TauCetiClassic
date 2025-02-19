/mob/living/simple_animal/heretic_summon
	name = "Eldritch Demon"
	real_name = "Eldritch Demon"
	desc = "A horror from beyond this realm, summoned by bad code."
	icon = 'icons/mob/eldritch_mobs.dmi'
	faction = "heretic"
	gender = NEUTER

	habitable_atmos = null
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	speed = 0
	melee_attack_cooldown = CLICK_CD_MELEE

	attack_sound = list('sound/weapons/genhit1.ogg')
	response_help = "think better of touching"
	response_disarm = "flail at"
	response_harm = "tear"
	death_message = "implodes into itself."

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	maxbodytemp = 0
	unsuitable_atoms_damage = 0

	ai_controller = null
	speak_emote = list("screams")

/mob/living/simple_animal/heretic_summon/atom_init()
	. = ..()
	AddElement(/datum/element/death_drops, string_list(list(/obj/effect/gibspawner/generic)))
