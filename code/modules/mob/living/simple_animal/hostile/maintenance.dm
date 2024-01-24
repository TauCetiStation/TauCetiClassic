/mob/living/simple_animal/hostile/shade
	name = "shade"
	desc = "Some weird near-invisible creature, roaming station's maints."
	health = 100
	maxHealth = 100
	icon_state = "forgotten"
	turns_per_move = 2
	melee_damage = 15
	attacktext = "hit"
	move_to_delay = 5
	attack_sound = list('sound/weapons/bite.ogg')

	animalistic = FALSE
	has_head = TRUE
	has_arm = TRUE
	has_leg = TRUE
	alpha = 45

/mob/living/simple_animal/hostile/shade/UnarmedAttack(atom/target)
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/L = target
	if(prob(50))
		var/sound_to_play = pick('sound/hallucinations/scary_sound_1.ogg', 'sound/hallucinations/scary_sound_2.ogg', 'sound/hallucinations/scary_sound_3.ogg', 'sound/hallucinations/scary_sound_4.ogg')
		L.playsound_local(src, sound_to_play, VOL_EFFECTS_MASTER, null, FALSE)
		L.eye_blind = 5
	for(var/obj/item/I in L)
		I.set_light(0)

/mob/living/simple_animal/hostile/shade/death()
	..()
	visible_message("<b>[src]</b> disappears!")
	var/datum/effect/effect/system/smoke_spread/chem/S = new
	var/turf/location = get_turf(src)
	create_reagents(10)
	reagents.add_reagent("blindness_smoke", 10)
	S.attach(location)
	S.set_up(reagents, 1, 1, location, 10, 1)
	S.start()
	qdel(src)

/mob/living/simple_animal/hostile/octopus
	name = "maintenance octopus"
	desc = "Weird monster originating from nearest gas giant, spotted migrating in Tau Ceti region. Uses it's long tentacles to throw different things at it's prey until it dies."
	icon = 'icons/mob/animal.dmi'
	icon_state = "octopus"
	icon_dead = "octopus_dead"
	move_to_delay = 40
	ranged = TRUE
	ranged_cooldown_cap = 1
	friendly = "wails at"
	vision_range = 7
	speed = 2
	maxHealth = 250
	health = 250
	melee_damage = 10
	attacktext = "lash"

/mob/living/simple_animal/hostile/octopus/OpenFire(target)
	for(var/obj/item/I in range(src, 1))
		if(prob(50))
			I.throw_at(target, 30, 2)
			visible_message("<span class='warning'>[src] throws [I] at [target]!</span>")
			ranged_cooldown = 0
			SetNextMove(CLICK_CD_MELEE)

/mob/living/simple_animal/hostile/octopus/UnarmedAttack(atom/target)
	. = ..()
	if(isliving(target) && prob(50))
		var/mob/living/L = target
		L.drop_item()
		to_chat(L, "<span class='warning'>[src] disarms you with it's tentacles!</span>")
