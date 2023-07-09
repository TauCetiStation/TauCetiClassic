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
		if("station - traditional")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/platform
	name = "platform"
	desc = "A place for people to stand on."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "platform_middle_still"
	still_icon_state = "platform_middle"

/turf/unsimulated/floor/train/platform/change_state(state)
	switch(state)
		if("station - traditional")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_platformmiddle.dmi'
		if("field")
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
		if("station - traditional")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_platformtop.dmi'
		if("field")
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
		if("station - traditional")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_platformbottom.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_platformbottom.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_platformbottom.dmi'

//RAILS

/turf/unsimulated/floor/train/rails
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "matrix"
	still_icon_state = "matrix"

/turf/unsimulated/floor/train/rails/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

//REAL RAILS

/turf/unsimulated/floor/train/rails/real
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "ban"
	still_icon_state = "ban"

/turf/unsimulated/floor/train/rails/real/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/left_1
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "platform_bottom_still"
	still_icon_state = "platform_bottom"

/turf/unsimulated/floor/train/rails/real/left_1/change_state(state)
	switch(state)
		if("station - traditional")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf_realrails_left1.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf_realrails_left1.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf_realrails_left1.dmi'

/turf/unsimulated/floor/train/rails/real/right_1
	name = "platform"
	desc = "A place for people to stand on."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "platform_bottom_still"
	still_icon_state = "platform_bottom"

/turf/unsimulated/floor/train/rails/real/right_1/change_state(state)
	switch(state)
		if("station - traditional")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf_realrails_right1.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf_realrails_right1.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf_realrails_right1.dmi'

/turf/unsimulated/floor/train/rails/real/left_2
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_2_still"
	still_icon_state = "rails_left_2"

/turf/unsimulated/floor/train/rails/real/left_2/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/right_2
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_2_still"
	still_icon_state = "rails_right_2"

/turf/unsimulated/floor/train/rails/real/right_2/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/left_3
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_3_still"
	still_icon_state = "rails_left_3"

/turf/unsimulated/floor/train/rails/real/left_3/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/right_3
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_3_still"
	still_icon_state = "rails_right_3"

/turf/unsimulated/floor/train/rails/real/right_3/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/left_4
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_4_still"
	still_icon_state = "rails_left_4"

/turf/unsimulated/floor/train/rails/real/left_4/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/right_4
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_4_still"
	still_icon_state = "rails_right_4"

/turf/unsimulated/floor/train/rails/real/right_4/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/left_5
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_5_still"
	still_icon_state = "rails_left_5"

/turf/unsimulated/floor/train/rails/real/left_5/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/right_5
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_5_still"
	still_icon_state = "rails_right_5"

/turf/unsimulated/floor/train/rails/real/right_5/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/left_6
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_6_still"
	still_icon_state = "rails_left_6"

/turf/unsimulated/floor/train/rails/real/left_6/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/right_6
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_6_still"
	still_icon_state = "rails_right_6"

/turf/unsimulated/floor/train/rails/real/right_6/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/left_7
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_7_still"
	still_icon_state = "rails_left_7"

/turf/unsimulated/floor/train/rails/real/left_7/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/right_7
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_7_still"
	still_icon_state = "rails_right_7"

/turf/unsimulated/floor/train/rails/real/right_7/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/left_8
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_8_still"
	still_icon_state = "rails_left_8"

/turf/unsimulated/floor/train/rails/real/left_8/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/right_8
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_8_still"
	still_icon_state = "rails_right_8"

/turf/unsimulated/floor/train/rails/real/right_8/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/left_9
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_9_still"
	still_icon_state = "rails_left_9"

/turf/unsimulated/floor/train/rails/real/left_9/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/right_9
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_9_still"
	still_icon_state = "rails_right_9"

/turf/unsimulated/floor/train/rails/real/right_9/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/left_10
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_10_still"
	still_icon_state = "rails_left_10"

/turf/unsimulated/floor/train/rails/real/left_10/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/right_10
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_10_still"
	still_icon_state = "rails_right_10"

/turf/unsimulated/floor/train/rails/real/right_10/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/left_11
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_11_still"
	still_icon_state = "rails_left_11"

/turf/unsimulated/floor/train/rails/real/left_11/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/right_11
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_11_still"
	still_icon_state = "rails_right_11"

/turf/unsimulated/floor/train/rails/real/right_11/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/left_12
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_12_still"
	still_icon_state = "rails_left_12"

/turf/unsimulated/floor/train/rails/real/left_12/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/right_12
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_12_still"
	still_icon_state = "rails_right_12"

/turf/unsimulated/floor/train/rails/real/right_12/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/real/left_13
	name = "platform"
	desc = "A place for people to stand on."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "platform_top_still"
	still_icon_state = "platform_top"

/turf/unsimulated/floor/train/rails/real/left_13/change_state(state)
	switch(state)
		if("station - traditional")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf_realrails_left13.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf_realrails_left13.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf_realrails_left13.dmi'

/turf/unsimulated/floor/train/rails/real/right_13
	name = "platform"
	desc = "A place for people to stand on."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "platform_top_still"
	still_icon_state = "platform_top"

/turf/unsimulated/floor/train/rails/real/right_13/change_state(state)
	switch(state)
		if("station - traditional")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "platform"
			desc = "A place for people to stand on."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf_realrails_right13.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf_realrails_right13.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf_realrails_right13.dmi'

//FAKE RAILS

/turf/unsimulated/floor/train/rails/fake
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "ban"
	still_icon_state = "ban"

/turf/unsimulated/floor/train/rails/fake/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("field")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("forest")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'

/turf/unsimulated/floor/train/rails/fake/left_2
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_2_still"
	still_icon_state = "rails_left_2"

/turf/unsimulated/floor/train/rails/fake/left_2/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left2.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left2.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left2.dmi'

/turf/unsimulated/floor/train/rails/fake/right_2
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_2_still"
	still_icon_state = "rails_right_2"

/turf/unsimulated/floor/train/rails/fake/right_2/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right2.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right2.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right2.dmi'

/turf/unsimulated/floor/train/rails/fake/left_3
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_3_still"
	still_icon_state = "rails_left_3"

/turf/unsimulated/floor/train/rails/fake/left_3/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left3.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left3.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left3.dmi'

/turf/unsimulated/floor/train/rails/fake/right_3
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_3_still"
	still_icon_state = "rails_right_3"

/turf/unsimulated/floor/train/rails/fake/right_3/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right3.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right3.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right3.dmi'

/turf/unsimulated/floor/train/rails/fake/left_4
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_4_still"
	still_icon_state = "rails_left_4"

/turf/unsimulated/floor/train/rails/fake/left_4/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left4.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left4.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left4.dmi'

/turf/unsimulated/floor/train/rails/fake/right_4
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_4_still"
	still_icon_state = "rails_right_4"

/turf/unsimulated/floor/train/rails/fake/right_4/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right4.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right4.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right4.dmi'

/turf/unsimulated/floor/train/rails/fake/left_5
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_5_still"
	still_icon_state = "rails_left_5"

/turf/unsimulated/floor/train/rails/fake/left_5/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left5.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left5.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left5.dmi'

/turf/unsimulated/floor/train/rails/fake/right_5
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_5_still"
	still_icon_state = "rails_right_5"

/turf/unsimulated/floor/train/rails/fake/right_5/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right5.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right5.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right5.dmi'

/turf/unsimulated/floor/train/rails/fake/left_6
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_6_still"
	still_icon_state = "rails_left_6"

/turf/unsimulated/floor/train/rails/fake/left_6/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left6.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left6.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left6.dmi'

/turf/unsimulated/floor/train/rails/fake/right_6
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_6_still"
	still_icon_state = "rails_right_6"

/turf/unsimulated/floor/train/rails/fake/right_6/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right6.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right6.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right6.dmi'

/turf/unsimulated/floor/train/rails/fake/left_7
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_7_still"
	still_icon_state = "rails_left_7"

/turf/unsimulated/floor/train/rails/fake/left_7/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left7.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left7.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left7.dmi'

/turf/unsimulated/floor/train/rails/fake/right_7
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_7_still"
	still_icon_state = "rails_right_7"

/turf/unsimulated/floor/train/rails/fake/right_7/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right7.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right7.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right7.dmi'

/turf/unsimulated/floor/train/rails/fake/left_8
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_8_still"
	still_icon_state = "rails_left_8"

/turf/unsimulated/floor/train/rails/fake/left_8/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left8.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left8.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left8.dmi'

/turf/unsimulated/floor/train/rails/fake/right_8
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_8_still"
	still_icon_state = "rails_right_8"

/turf/unsimulated/floor/train/rails/fake/right_8/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right8.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right8.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right8.dmi'

/turf/unsimulated/floor/train/rails/fake/left_9
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_9_still"
	still_icon_state = "rails_left_9"

/turf/unsimulated/floor/train/rails/fake/left_9/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left9.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left9.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left9.dmi'

/turf/unsimulated/floor/train/rails/fake/right_9
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_9_still"
	still_icon_state = "rails_right_9"

/turf/unsimulated/floor/train/rails/fake/right_9/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right9.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right9.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right9.dmi'

/turf/unsimulated/floor/train/rails/fake/left_10
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_10_still"
	still_icon_state = "rails_left_10"

/turf/unsimulated/floor/train/rails/fake/left_10/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left10.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left10.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left10.dmi'

/turf/unsimulated/floor/train/rails/fake/right_10
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_10_still"
	still_icon_state = "rails_right_10"

/turf/unsimulated/floor/train/rails/fake/right_10/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right10.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right10.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right10.dmi'

/turf/unsimulated/floor/train/rails/fake/left_11
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_11_still"
	still_icon_state = "rails_left_11"

/turf/unsimulated/floor/train/rails/fake/left_11/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left11.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left11.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left11.dmi'

/turf/unsimulated/floor/train/rails/fake/right_11
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_11_still"
	still_icon_state = "rails_right_11"

/turf/unsimulated/floor/train/rails/fake/right_11/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right11.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right11.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right11.dmi'

/turf/unsimulated/floor/train/rails/fake/left_12
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_left_12_still"
	still_icon_state = "rails_left_12"

/turf/unsimulated/floor/train/rails/fake/left_12/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left12.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left12.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_left12.dmi'

/turf/unsimulated/floor/train/rails/fake/right_12
	name = "railway track"
	desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
	icon = 'trainstation13/icons/turf/trainturf.dmi'
	icon_state = "rails_right_12_still"
	still_icon_state = "rails_right_12"

/turf/unsimulated/floor/train/rails/fake/right_12/change_state(state)
	switch(state)
		if("station - traditional")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("station - rural")
			name = "railway track"
			desc = "A structure that enables trains to move by providing a dependable surface for their wheels to roll upon."
			icon = 'trainstation13/icons/turf/trainturf.dmi'
		if("suburb")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right12.dmi'
		if("field")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right12.dmi'
		if("forest")
			name = "snow"
			desc = "It's cold."
			icon = 'trainstation13/icons/turf/trainturf_fakerails_right12.dmi'

//ANIMATION SWITCH

/turf/unsimulated/floor/train/proc/change_movement(moving)
	icon_state = "[still_icon_state]_[moving ? "moving" : "still"]"