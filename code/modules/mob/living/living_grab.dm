/mob/living/canGrab(atom/movable/target, show_warnings = TRUE)
	. = ..()
	if(.)
		if(isliving(target))
			var/mob/living/L = target
			if(small && !L.small)
				return FALSE
			if(L.maxHealth > maxHealth)
				return FALSE
