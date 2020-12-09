#define OXYGEN_KPA_REDUCEMENT 16

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

/datum/component/mob_modifier/mouse/healthy/revert(update = FALSE)
	var/mob/living/simple_animal/mouse/M = parent

	var/health_proportion = M.health / M.maxHealth

	M.maxHealth -= 3 * strength
	M.health = health_proportion * M.maxHealth

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
	if(!update)
		if(spell)
			QDEL_NULL(spell)
		spell = new
		M.AddSpell(spell)

/datum/component/mob_modifier/mouse/sparkly/revert(update = FALSE)
	if(spell)
		var/mob/living/simple_animal/mouse/M = parent
		M.RemoveSpell(spell)
	return ..()

/datum/component/mob_modifier/mouse/sparkly/Destroy()
    QDEL_NULL(spell)
    return ..()



/datum/component/mob_modifier/mouse/space
	modifier_name = RL_MM_MOUSE_SPACE
	message = "You evolved into a space mouse! Survive in almost zero kPA but you still have to do something when it reaches zero."

/datum/component/mob_modifier/mouse/space/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/mouse/M = parent
	M.min_oxy -= OXYGEN_KPA_REDUCEMENT * strength // Whatever

/datum/component/mob_modifier/mouse/space/revert(update = FALSE)
	var/mob/living/simple_animal/mouse/M = parent
	M.min_oxy += OXYGEN_KPA_REDUCEMENT * strength
	return ..()



/datum/component/mob_modifier/mouse/cute
	modifier_name = RL_MM_MOUSE_CUTE
	message = "You have become more adorable!"

/datum/component/mob_modifier/mouse/cute/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/M = parent
	M.add_overlay("mouse_cute")

/datum/component/mob_modifier/mouse/cute/revert(update = FALSE)
	var/mob/M = parent
	M.cut_overlay("mouse_cute")
	return ..()



/datum/component/mob_modifier/mouse/glowing
	modifier_name = RL_MM_MOUSE_GLOWING
	message = "You evolved into a mouse with a smooth lighing!"

/datum/component/mob_modifier/mouse/glowing/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/mouse/M = parent
	M.set_light(3)

/datum/component/mob_modifier/mouse/glowing/revert(update = FALSE)
	var/mob/living/simple_animal/mouse/M = parent
	M.set_light(0)
	return ..()



/datum/component/mob_modifier/mouse/chatty
	modifier_name = RL_MM_MOUSE_CHATTY
	message = "You ate so much cheese that you can't hold your excitement."

/datum/component/mob_modifier/mouse/chatty/apply(update = FALSE)
	. = ..()
	if(!.)
		return

	var/mob/living/simple_animal/mouse/M = parent
	M.speak_chance *= 2

/datum/component/mob_modifier/mouse/chatty/revert(update = FALSE)
	var/mob/living/simple_animal/mouse/M = parent
	M.speak_chance /= 2
	return ..()

#undef OXYGEN_KPA_REDUCEMENT