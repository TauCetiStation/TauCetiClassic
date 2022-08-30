/mob/living/carbon/Logout()
	..()
	if(!ischangeling(src))
		return
	var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
	if(C && !C.delegating && length(C.essences) > 0)

		if(C.trusted_entity && C.trusted_entity.client)
			delegate_body_to_essence(C.trusted_entity)
		else
			var/list/pickable = list()
			for(var/mob/living/parasite/essence/E in C.essences)
				if(E.client)
					pickable += E
			if(length(pickable) > 0)
				delegate_body_to_essence(pick(pickable))
