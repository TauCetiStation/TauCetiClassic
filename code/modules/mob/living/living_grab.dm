/mob/living/canGrab(atom/movable/target, show_warnings = TRUE)
	. = ..()
	if(.)
		if(isliving(target))
			var/mob/living/L = target
			if(L.is_bigger_than(src))
				return FALSE
