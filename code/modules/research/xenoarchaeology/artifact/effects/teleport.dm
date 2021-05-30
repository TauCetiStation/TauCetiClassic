
/datum/artifact_effect/teleport
	effect_name = "Teleport"
	effect_type = ARTIFACT_EFFECT_BLUESPACE

/datum/artifact_effect/teleport/DoEffectTouch(mob/user)
	var/weakness = GetAnomalySusceptibility(user)
	if(prob(100 * weakness))
		to_chat(user, "<span class='warning'>You are suddenly zapped away elsewhere!</span>")
		if (user.buckled)
			user.buckled.unbuckle_mob()

		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, get_turf(user))
		sparks.start()
		//
	//	user.loc = pick(orange(get_turf(holder), 50))
		var/turf/N = pick(orange(get_turf(holder), 50))
		do_teleport(user, N, 4)
		sparks = new /datum/effect/effect/system/spark_spread()
		sparks.set_up(3, 0, get_turf(user))
		sparks.start()

/datum/artifact_effect/teleport/DoEffectAura()
	if(holder)
		var/turf/T = get_turf(holder)
		for (var/mob/living/M in range(src.effectrange,T))
			var/weakness = GetAnomalySusceptibility(M)
			if(prob(100 * weakness))
				to_chat(M, "<span class='warning'>You are displaced by a strange force!</span>")
				if(M.buckled)
					M.buckled.unbuckle_mob()

				var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
				sparks.set_up(3, 0, get_turf(M))
				sparks.start()
				//
				var/turf/N = pick(orange(get_turf(T), 50))
				//M.Move(N)
				do_teleport(M, N, 4)
			//	M.loc = pick(orange(get_turf(T), 50))
				sparks = new /datum/effect/effect/system/spark_spread()
				sparks.set_up(3, 0, get_turf(M))
				sparks.start()

/datum/artifact_effect/teleport/DoEffectPulse()
	if(holder)
		var/turf/T = get_turf(holder)
		for (var/mob/living/M in range(src.effectrange, T))
			var/weakness = GetAnomalySusceptibility(M)
			if(prob(100 * weakness))
				to_chat(M, "<span class='warning'>You are displaced by a strange force!</span>")
				if(M.buckled)
					M.buckled.unbuckle_mob()

				var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
				sparks.set_up(3, 0, get_turf(M))
				sparks.start()
				//
				var/turf/N = pick(orange(get_turf(T), 50))
			//	M.Move(N)
				do_teleport(M, N, 4)
				sparks = new /datum/effect/effect/system/spark_spread()
				sparks.set_up(3, 0, get_turf(M))
				sparks.start()
