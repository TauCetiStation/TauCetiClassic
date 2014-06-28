/turf/unsimulated/floor/velocity
	icon = 'tauceti/icons/turf/floor.dmi'

/turf/simulated/shuttle/floor/mining
	icon = 'tauceti/modules/_locations/shuttles/shuttle_mining.dmi'

/turf/simulated/shuttle/floor/shuttle_new
	icon = 'tauceti/modules/_locations/shuttles/shuttle.dmi'

//Временный и очень грубый костыль для космоса, в шаттлконтроллере он не заменяется на движущийся.
//Скоро бэй обновит шаттлконтроллеры, там и сделаем по человечески.
turf/space/shuttle
	icon = 'tauceti/modules/_locations/shuttles/space.dmi'
	icon_state = "1swall_s"

	New()
		icon_state = "[rand(1,4)]swall_s"