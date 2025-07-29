/datum/objective/silence
	explanation_text = "Не дайте никому покинуть станцию.  Вызовите шаттл только тогда, когда все мертвы и вы остались одни."

/datum/objective/silence/check_completion()
	if(SSshuttle.location<2)
		return OBJECTIVE_LOSS

	for(var/mob/living/player in player_list)
		if(player == owner.current)
			continue
		if(player.mind)
			if(player.stat != DEAD)
				var/turf/T = get_turf(player)
				if(!T)	continue
				switch(T.loc.type)
					if(/area/shuttle/escape/centcom, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod4/centcom)
						return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
