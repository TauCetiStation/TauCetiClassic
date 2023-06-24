//TRAIN STATION 13

/turf/unsimulated/wall/matrix
	name = "matrix"
	desc = "<font color='#157206'>You suddenly realize the truth - there is no spoon.<br>Digital simulation ends here.</font>"
	icon = 'trainstation13/icons/trainturf.dmi'
	icon_state = "matrix"
	smooth = FALSE

/turf/unsimulated/wall/nanoconcrete
	name = "nanoconcrete"
	desc = "Reinforced concrete with an improved formula, one of the strongest materials ever created in history of mankind.<br>This wall can easily shrug off a nearby nuclear explosion."
	icon = 'trainstation13/icons/trainturf.dmi'
	icon_state = "box"
	canSmoothWith = list(/turf/unsimulated/wall/nanoconcrete)

/turf/unsimulated/floor/still/snow //This snow won't switch to animation if the train is moving
	name = "snow"
	desc = "It's cold."
	icon = 'trainstation13/icons/trainturf.dmi'
	icon_state = "snow_still"

/turf/unsimulated/floor/moving/snow //This snow will switch icon state to animation if the train is moving
	name = "snow"
	desc = "It's cold."
	icon = 'trainstation13/icons/trainturf.dmi'
	icon_state = "snow_still"

var/global/list/train_turfs = list()

ADD_TO_GLOBAL_LIST(/turf/unsimulated/floor/train, global.train_turfs)

/turf/unsimulated/floor/train

/turf/unsimulated/floor/train/proc/change_state(state)
	switch(state)
		if("normal")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/trainturf.dmi'
		if("station")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/trainturf.dmi'
		if("forest")
			name = "grass"
			desc = "A thing to touch."
			icon = 'trainstation13/icons/trainturf.dmi'

/turf/unsimulated/floor/train/rails/change_state(state)
	switch(state)
		if("normal")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/trainturf.dmi'
		if("station")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/trainturf.dmi'
		if("forest")
			name = "grass"
			desc = "A thing to touch."
			icon = 'trainstation13/icons/trainturf.dmi'

/turf/unsimulated/floor/train/platform/change_state(state)
	switch(state)
		if("normal")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/trainturf.dmi'
		if("station")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/trainturf.dmi'
		if("forest")
			name = "grass"
			desc = "A thing to touch."
			icon = 'trainstation13/icons/trainturf.dmi'

/turf/unsimulated/floor/train/proc/change_movement(moving)
	icon_state = "[initial(icon_state)]_[moving ? "moving" : "still"]"

ADD_TO_GLOBAL_LIST(/obj/effect/decal/train_special_effects, global.train_special_effects)

/obj/effect/decal/train_special_effects

/obj/effect/decal/train_special_effects/proc/change_movement(moving)
	// here you can spawn the snow thing
