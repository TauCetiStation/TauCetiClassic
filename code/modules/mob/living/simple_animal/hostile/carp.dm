/mob/living/simple_animal/hostile/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon = 'icons/mob/carp.dmi'
	icon_state = "purple"
	icon_living = "purple"
	icon_dead = "purple_dead"
	icon_gib = "purple_gib"
	icon_move = "purple_move"
	speak_chance = 0
	turns_per_move = 4
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/carpmeat = 2)
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 3
	maxHealth = 40
	health = 40

	harm_intent_damage = 8
	melee_damage = 15
	attacktext = "gnaw"
	attack_sound = list('sound/weapons/bite.ogg')

	// Space carp aren't affected by atmos.
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

	has_head = TRUE

	var/randomify = TRUE // Are we going to use carp_randomify()

	var/carp_color = "purple" // holder for icon set

/mob/living/simple_animal/hostile/carp/atom_init()
	. = ..()
	if(randomify)
		carp_randomify()

/mob/living/simple_animal/hostile/carp/proc/carp_randomify()
	melee_damage = initial(melee_damage) * rand(8, 12) * 0.1
	maxHealth = rand(initial(maxHealth), (1.5 * initial(maxHealth)))
	health = maxHealth

	// picking the color
	carp_color = pick(
	500;"purple",
	150;"ashy",
	150;"blue",
	150;"white",
	50;"golden")

	icon_state = "[carp_color]"
	icon_living = "[carp_color]"
	icon_dead = "[carp_color]_dead"
	icon_move = "[carp_color]_move"

	if(carp_color == "purple")
		icon_gib = "purple_gib"

/mob/living/simple_animal/hostile/carp/Process_Spacemove(movement_dir = 0)
	return 1 // No drifting in space for space carp!

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

	randomify = FALSE

	melee_damage = 20

/mob/living/simple_animal/hostile/carp/dog
	name = "REX"
	desc = "That's a cute little doge... WAIT, WHAT???!!"
	icon = 'icons/mob/doge.dmi'
	icon_state = "shepherd"
	maxHealth = 9001
	health = 9001

	turns_per_move = 5
	speed = -15
	move_to_delay = -15

	melee_damage = 400

	attacktext = "lick"

	var/idle_snd_chance = 5

	attack_sound = list('sound/weapons/polkan_atk.ogg')

	randomify = FALSE

/mob/living/simple_animal/hostile/carp/dog/polkan
	name = "POLKAN"
	icon_state = "husky"

/mob/living/simple_animal/hostile/carp/dog/Life()
	. = ..()
	if(!.)
		return 0

	if(rand(0,100) < idle_snd_chance)
		var/list/idle_snd = list('sound/voice/polkan/idle1.ogg','sound/voice/polkan/idle2.ogg')
		playsound(src, pick(idle_snd), VOL_EFFECTS_MASTER, null, null, -3)
