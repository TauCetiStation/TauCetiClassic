

/mob/living/simple_animal/hostile/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	icon_gib = "carp_gib"
	speak_chance = 0
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/carpmeat
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 4
	maxHealth = 25
	health = 25

	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	//Space carp aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	environment_smash = 1

	faction = "carp"

/mob/living/simple_animal/hostile/carp/Process_Spacemove(movement_dir = 0)
	return 1	//No drifting in space for space carp!	//original comments do not steal

/mob/living/simple_animal/hostile/carp/FindTarget()
	. = ..()
	if(.)
		custom_emote(1,"nashes at [.]")

/mob/living/simple_animal/hostile/carp/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Weaken(3)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

/mob/living/simple_animal/hostile/carp/megacarp
	icon = 'icons/mob/megacarp.dmi'
	name = "Mega Space Carp"
	desc = "A ferocious, fang bearing creature that resembles a shark. This one seems especially ticked off."
	icon_state = "megacarp"
	icon_living = "megacarp"
	icon_dead = "megacarp_dead"
	icon_gib = "megacarp_gib"
	maxHealth = 65
	health = 65
	pixel_x = -16

	melee_damage_lower = 20
	melee_damage_upper = 20

/mob/living/simple_animal/hostile/carp/dog
	name = "REX"
	desc = "That's a cute little doge... WAIT, WHAT???!!"
	icon = 'icons/mob/doge.dmi'
	icon_state = "shepherd"
	maxHealth = 9001
	health = 9001
	a_intent = "harm"

	turns_per_move = 5
	speed = -15
	move_to_delay = -15

	melee_damage_lower = 400
	melee_damage_upper = 400

	attacktext = "licks"

	var/idle_snd_chance = 5

	attack_sound = 'sound/weapons/polkan_atk.ogg'

/mob/living/simple_animal/hostile/carp/dog/polkan
	name = "POLKAN"
	icon_state = "husky"

/mob/living/simple_animal/hostile/carp/dog/Life()
	. = ..()
	if(!.)
		return 0

	if(rand(0,100) < idle_snd_chance)
		var/list/idle_snd = list('sound/voice/polkan/idle1.ogg','sound/voice/polkan/idle2.ogg')
		playsound(src, pick(idle_snd), 50, 1, -3)
