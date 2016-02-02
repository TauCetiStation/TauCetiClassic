/datum/controller/process/typing
	var/typing_count = 0

/datum/controller/process/typing/setup()
	name = "typing"
	schedule_interval = 5

/datum/controller/process/typing/doWork()
	typing_count = 0
	if(mob_list.len)
		for(var/mob/living/L in mob_list)
			if(L)
				if(L.stat)
					if(L.typing_indicator)
						qdel(L.typing_indicator)
				else if(L.client)
					var/temp = winget(L.client, "input", "text")
					if(findtext(temp, "Say \"", 1, 7) && length(temp) > 5)
						typing_count++
						if(!L.typing_indicator)
							L.typing_indicator = image('icons/mob/talk.dmi',L,"typing")
							for(var/mob/M in viewers(L, null))
								M << L.typing_indicator
					else if(L.typing_indicator)
						qdel(L.typing_indicator)
				else
					if(L.typing_indicator)
						qdel(L.typing_indicator)
			scheck()

/datum/controller/process/typing/getStatName()
	return ..()+"(T[typing_count])"
