/mob/living/simple_animal/grown_larvae
	name = "larvae"
	desc = "It's a little alien skittery critter. Hiss."
	icon = 'icons/mob/animal.dmi'
	health = 10
	maxHealth = 10
	response_help   = "hugs"
	response_disarm = "gently pushes"
	response_harm   = "punches"
	has_head = TRUE
	has_arm = TRUE
	has_leg = TRUE
	turns_per_move = 4
	speed = 3

/mob/living/simple_animal/grown_larvae/atom_init()
	. = ..()
	handle_evolving()

/mob/living/simple_animal/grown_larvae/Stat()
	..()
	stat(null)
	if(statpanel("Status"))
		stat("Прогресс роста: [evolv_stage * 25]/100")
