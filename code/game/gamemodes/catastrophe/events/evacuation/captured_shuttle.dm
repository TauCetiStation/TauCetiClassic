/datum/catastrophe_event/capturedshuttle_evacuation
	name = "Captured Shuttle evacuation"

	one_time_event = TRUE

	weight = 100

	event_type = "evacuation"
	steps = 1

	var/list/monsters = list(
		list(/mob/living/simple_animal/hostile/carp, /mob/living/simple_animal/hostile/carp/megacarp),
		list(/mob/living/simple_animal/hostile/cellular/meat/changeling, /mob/living/simple_animal/hostile/cellular/meat/maniac),
		list(/mob/living/simple_animal/hostile/cellular/necro),
		list(/mob/living/simple_animal/hostile/cellular/meat/flesh),
		list(/mob/living/simple_animal/hostile/asteroid/basilisk, /mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/hivelord),
		list(/mob/living/simple_animal/hostile/retaliate/goat),
		list(/mob/living/simple_animal/hostile/retaliate/clown),
		list(/mob/living/simple_animal/hostile/cyber_horror),
		list(/mob/living/simple_animal/hostile/giant_spider, /mob/living/simple_animal/hostile/giant_spider/nurse, /mob/living/simple_animal/hostile/giant_spider/hunter)
	)

/datum/catastrophe_event/capturedshuttle_evacuation/on_step()
	switch(step)
		if(1)
			announce("Автоматическа[JA_PLACEHOLDER] система управлени[JA_PLACEHOLDER] шатлом.. обнаружила.. ваш.. ма[JA_PLACEHOLDER]к помощи. Готовьтесь к эвакуации через.. дес[JA_PLACEHOLDER]ть.. минут. Автоматическа[JA_PLACEHOLDER] система управлени[JA_PLACEHOLDER] шатла сообщает.. о наличии.. двадцати.. неизвестных форм жизни.. на шатле.")

			if(SSshuttle)
				SSshuttle.always_fake_recall = FALSE
				SSshuttle.fake_recall = 0

				SSshuttle.incall()
				world << sound('sound/AI/shuttlecalled.ogg')

			var/list/shuttle_turfs = get_area_turfs(locate(/area/shuttle/escape/centcom))
			var/list/valid_turfs = list()
			for(var/turf/simulated/shuttle/floor/F in shuttle_turfs)
				valid_turfs += F

			var/list/monster_types = pick(monsters)

			for (var/i in 1 to 20)
				var/turf/simulated/shuttle/floor/F = pick(valid_turfs)
				var/monster_type = pick(monster_types)
				new monster_type(F)