/datum/component/mob_modifier/mouse/healthy
	modifier_name = RL_MM_MOUSE_HEALTHY

/datum/component/mob_modifier/mouse/healthy/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/mouse/M = parent

	var/health_proportion = M.health / M.maxHealth

	M.maxHealth += 3 * strength
	M.health = health_proportion * M.maxHealth

	var/matrix/Mtrx = matrix(M.default_transform)
	Mtrx.Scale(1 + 0.025 * min(strength, 40))
	M.transform = Mtrx
	M.default_transform = M.transform

/datum/component/mob_modifier/mouse/healthy/revert(update = FALSE)
	var/mob/living/simple_animal/mouse/M = parent

	var/health_proportion = M.health / M.maxHealth

	M.maxHealth -= 3 * strength
	M.health = health_proportion * M.maxHealth

	var/matrix/Mtrx = matrix(M.default_transform)
	Mtrx.Scale(1 / (1 + 0.025 * min(strength, 40)))
	M.transform = Mtrx
	M.default_transform = M.transform
	return ..()



/datum/component/mob_modifier/mouse/sparkly
	modifier_name = RL_MM_MOUSE_SPARKLY
	var/obj/effect/proc_holder/spell/targeted/harmless_sparks/spell
	message = "You evolved into a mouse with cheesepowers!"


/datum/component/mob_modifier/mouse/sparkly/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/mouse/M = parent
	spell = new
	M.AddSpell(spell)

/datum/component/mob_modifier/mouse/sparkly/revert(update = FALSE)
	if(spell)
		var/mob/living/simple_animal/mouse/M = parent
		M.RemoveSpell(spell)
	return ..()



/datum/component/mob_modifier/mouse/space
	modifier_name = RL_MM_MOUSE_SPACE
	message = "You evolved into a space mouse! Survive in almost zero kPA but you still have to do something when it reaches zero."

/datum/component/mob_modifier/mouse/space/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/mouse/M = parent
	M.min_oxy -= 16 // Whatever

/datum/component/mob_modifier/mouse/space/revert(update = FALSE)
	var/mob/living/simple_animal/mouse/M = parent
	M.min_oxy += 16
	return ..()



/datum/component/mob_modifier/mouse/cute
	modifier_name = RL_MM_MOUSE_CUTE
	message = "You have become more adorable!"

/datum/component/mob_modifier/mouse/cute/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/mouse/M = parent
	M.is_cute = TRUE

/datum/component/mob_modifier/mouse/cute/revert(update = FALSE)
	var/mob/living/simple_animal/mouse/M = parent
	M.is_cute = FALSE
	return ..()



/datum/component/mob_modifier/mouse/glowy
	modifier_name = RL_MM_MOUSE_GLOWY
	message = "You evolved into a mouse with a smooth lighing!"

/datum/component/mob_modifier/mouse/glowy/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/mouse/M = parent
	M.set_light(3)
	M.is_glowing = TRUE

/datum/component/mob_modifier/mouse/glowy/revert(update = FALSE)
	var/mob/living/simple_animal/mouse/M = parent
	M.set_light(0)
	M.is_glowing = FALSE
	return ..()



/datum/component/mob_modifier/mouse/speaky
	modifier_name = RL_MM_MOUSE_SPEAKY
	message = "You ate so much cheese that humans will understand you more often from now."

/datum/component/mob_modifier/mouse/speaky/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/mouse/M = parent
	M.speak_chance *= 2

/datum/component/mob_modifier/mouse/speaky/revert(update = FALSE)
	var/mob/living/simple_animal/mouse/M = parent
	M.speak_chance /= 2
	return ..()
