//TRAIN STATION 13

//STILL - STATIC TURFS

/turf/unsimulated/wall/matrix
	name = "matrix"
	desc = "<font color='#157206'>You suddenly realize the truth - there is no spoon.<br>Digital simulation ends here.</font>"
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "matrix"
	smooth = FALSE

/turf/unsimulated/wall/nanoconcrete
	name = "nanoconcrete"
	desc = "Reinforced concrete with an improved formula, one of the strongest materials ever created in history of mankind.<br>This wall can easily shrug off a nearby nuclear explosion."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "box"
	canSmoothWith = list(/turf/unsimulated/wall/nanoconcrete)

/turf/unsimulated/floor/still/snow //This snow won't switch to animation if the train is moving
	name = "snow"
	desc = "It's cold."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "snow_still"

//MOVING - ANIMATED TURFS

var/global/list/train_turfs = list()

ADD_TO_GLOBAL_LIST(/turf/unsimulated/floor/train, global.train_turfs)

/turf/unsimulated/floor/train
	name = "snow"
	desc = "It's cold."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "snow_still"
	var/still_icon_state = "snow"

/turf/unsimulated/floor/train/proc/change_state(state)
	switch(state)
		if("station")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("normal")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "grass"
			desc = "A thing to touch."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails
	name = "snow"
	desc = "It's cold."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "snow_still"

/turf/unsimulated/floor/train/rails/change_state(state)
	switch(state)
		if("station")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("normal")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "grass"
			desc = "A thing to touch."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/platform
	name = "platform"
	desc = "A place for people to stand on."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "platform_middle_still"
	still_icon_state = "platform_middle"

/turf/unsimulated/floor/train/platform/change_state(state)
	switch(state)
		if("station")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("normal")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_platformmiddle.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_platformmiddle.dmi'

/turf/unsimulated/floor/train/platform/top
	name = "platform"
	desc = "A place for people to stand on."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "platform_top_still"
	still_icon_state = "platform_top"

/turf/unsimulated/floor/train/platform/top/change_state(state)
	switch(state)
		if("station")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("normal")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_platformtop.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_platformtop.dmi'

/turf/unsimulated/floor/train/platform/bottom
	name = "platform"
	desc = "A place for people to stand on."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "platform_bottom_still"
	still_icon_state = "platform_bottom"

/turf/unsimulated/floor/train/platform/bottom/change_state(state)
	switch(state)
		if("station")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("normal")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_platformbottom.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_platformbottom.dmi'

/turf/unsimulated/floor/train/proc/change_movement(moving)
	icon_state = "[still_icon_state]_[moving ? "moving" : "still"]"