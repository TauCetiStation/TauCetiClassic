//TRAIN STATION 13

/turf/unsimulated/wall/matrix
	name = "matrix"
	desc = "<font color='#157206'>You suddenly realize the truth - there is no spoon.<br>Digital simulation ends here.</font>"
	icon = 'trainstation13/icons/trainturf.dmi'
	icon_state = "matrix"
	smooth = FALSE

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