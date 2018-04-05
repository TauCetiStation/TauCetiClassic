/mob/living/carbon/Logout()
	..()
	if(mind && mind.changeling && !mind.changeling.delegating && length(mind.changeling.essences) > 0)

		if(mind.changeling.trusted_entity && mind.changeling.trusted_entity.client)
			delegate_body_to_essence(mind.changeling.trusted_entity)
		else
			var/list/pickable = list()
			for(var/mob/living/parasite/essence/E in mind.changeling.essences)
				if(E.client)
					pickable += E
			if(length(pickable) > 0)
				delegate_body_to_essence(pick(pickable))
