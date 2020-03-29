 ////////////
 //SHUTTLES//
 ////////////

//These are shuttle areas, they must contain two areas in a subgroup if you want to move a shuttle from one
//place to another. Look at escape shuttle for example.
//All shuttles show now be under shuttle since we have smooth-wall code.

/area/shuttle
	name = "Shuttle"
	icon_state = "shuttle"
	requires_power = 0
	valid_territory = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/shuttle/atom_init()
	if(!canSmoothWithAreas)
		canSmoothWithAreas = type
	. = ..()

//Velocity Officer Shuttle
/area/shuttle/officer
	name = "Officer Shuttle"

/area/shuttle/officer/velocity
	name = "NTS Velocity"
	icon_state = "shuttle2"

/area/shuttle/officer/transit
	icon_state = "shuttle"

/area/shuttle/officer/station
	name = "NSS Exodus"
	icon_state = "shuttle"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/officer/centcom
	name = "Centcomm"
	icon_state = "shuttle"

//Station Supply Shuttle
/area/shuttle/supply/station
	name = "supply shuttle"
	icon_state = "shuttle3"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/supply/velocity
	name = "supply shuttle"
	icon_state = "shuttle3"

//Arrival Velocity Shuttle
/area/shuttle/arrival
	name = "Arrival Shuttle"

/area/shuttle/arrival/velocity
	name = "NTS Velocity"
	icon_state = "shuttle2"

/area/shuttle/arrival/velocity/Entered(mob/M)
	..()
	if(istype(M) && M.client)
		M.client.guard.time_velocity_shuttle = world.timeofday

/area/shuttle/arrival/transit
	name = "Space"
	icon_state = "shuttle"
	parallax_movedir = EAST

/area/shuttle/arrival/station
	name = "NSS Exodus"
	icon_state = "shuttle"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Emergency Nanotrasen Shuttle
/area/shuttle/escape
	name = "Emergency Shuttle"

/area/shuttle/escape/station
	name = "Emergency Shuttle Station"
	icon_state = "shuttle2"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/escape/centcom
	name = "Emergency Shuttle Centcom"
	icon_state = "shuttle"

/area/shuttle/escape/transit // the area to pass through for 3 minute transit
	name = "Emergency Shuttle Transit"
	icon_state = "shuttle"
	parallax_movedir = WEST

//Escape Pod One
/area/shuttle/escape_pod1
	name = "Escape Pod One"

/area/shuttle/escape_pod1/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod1/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod1/transit
	icon_state = "shuttle"
	parallax_movedir = EAST

//Escape Pod Two
/area/shuttle/escape_pod2
	name = "Escape Pod Two"

/area/shuttle/escape_pod2/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod2/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod2/transit
	icon_state = "shuttle"
	parallax_movedir = EAST

//Escape Pod Three
/area/shuttle/escape_pod3
	name = "Escape Pod Three"

/area/shuttle/escape_pod3/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod3/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod3/transit
	icon_state = "shuttle"
	parallax_movedir = EAST

//Escape Pod Four
/area/shuttle/escape_pod4
	name = "Escape Pod Four"

/area/shuttle/escape_pod4/station
	icon_state = "shuttle2"

/area/shuttle/escape_pod4/centcom
	icon_state = "shuttle"

/area/shuttle/escape_pod4/transit
	icon_state = "shuttle"
	parallax_movedir = WEST

//Mining-Research Shuttle
/area/shuttle/mining
	name = "Mining-Research Shuttle"

/area/shuttle/mining/station
	icon_state = "shuttle2"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/mining/outpost
	icon_state = "shuttle"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/mining/research
	icon_state = "shuttle"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/mining/transit
	icon_state = "shuttle"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Centcom Transport Shuttle
/area/shuttle/transport1/centcom
	icon_state = "shuttle"
	name = "Transport Shuttle Centcom"

/area/shuttle/transport1/station
	icon_state = "shuttle"
	name = "Transport Shuttle"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Alien pod
/area/shuttle/alien/base
	icon_state = "shuttle"
	name = "Alien Shuttle Base"
	requires_power = 1

/area/shuttle/alien/mine
	icon_state = "shuttle"
	name = "Alien Shuttle Mine"
	requires_power = 1

//Special Ops Shuttle
/area/shuttle/specops/centcom
	name = "Special Ops Shuttle"
	icon_state = "shuttlered"

/area/shuttle/specops/station
	name = "Special Ops Shuttle"
	icon_state = "shuttlered2"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Syndicate Elite Shuttle
/area/shuttle/syndicate_elite/mothership
	name = "Syndicate Elite Shuttle"
	icon_state = "shuttlered"

/area/shuttle/syndicate_elite/station
	name = "Syndicate Elite Shuttle"
	icon_state = "shuttlered2"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Administration Centcom Shuttle
/area/shuttle/administration/centcom
	name = "Administration Shuttle Centcom"
	icon_state = "shuttlered"

/area/shuttle/administration/station
	name = "Administration Shuttle"
	icon_state = "shuttlered2"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Vox shuttle
/area/shuttle/vox/arkship
	name = "Vox Skipjack"
	icon_state = "yellow"

/area/shuttle/vox/transit
	name = "hyperspace"
	icon_state = "shuttle"
	parallax_movedir = NORTH

/area/shuttle/vox/southwest_solars
	name = "Aft port solars"
	icon_state = "southwest"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/vox/northwest_solars
	name = "Fore port solars"
	icon_state = "northwest"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/vox/northeast_solars
	name = "Fore starboard solars"
	icon_state = "northeast"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/vox/southeast_solars
	name = "Aft starboard solars"
	icon_state = "southeast"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/vox/mining
	name = "Nearby mining asteroid"
	icon_state = "north"
	looped_ambience = 'sound/ambience/loop_space.ogg'

//Syndicate Shuttle
/area/shuttle/syndicate
	name = "Syndicate Station"
	icon_state = "yellow"
	ambience = 'sound/ambience/syndicate_station.ogg'

/area/shuttle/syndicate/start
	name = "Syndicate Forward Operating Base"
	icon_state = "yellow"

/area/shuttle/syndicate/southwest
	name = "south-west of SS13"
	icon_state = "southwest"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/northwest
	name = "north-west of SS13"
	icon_state = "northwest"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/northeast
	name = "north-east of SS13"
	icon_state = "northeast"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/southeast
	name = "south-east of SS13"
	icon_state = "southeast"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/north
	name = "north of SS13"
	icon_state = "north"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/south
	name = "south of SS13"
	icon_state = "south"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/mining
	name = "north east of the mining asteroid"
	icon_state = "north"
	looped_ambience = 'sound/ambience/loop_space.ogg'

/area/shuttle/syndicate/transit
	name = "hyperspace"
	icon_state = "shuttle"
	parallax_movedir = NORTH

//Shuttle lists, group by areas
// CENTCOM
var/list/centcom_shuttle_areas = list (
	/area/shuttle/escape/centcom,
	/area/shuttle/escape_pod1/centcom,
	/area/shuttle/escape_pod2/centcom,
	/area/shuttle/escape_pod3/centcom,
	/area/shuttle/escape_pod4/centcom,
	/area/shuttle/transport1/centcom,
	/area/shuttle/administration/centcom,
	/area/shuttle/specops/centcom,
	/area/shuttle/officer/centcom
)

// DOCKED TO STATION
var/list/station_shuttle_areas = list (
	/area/shuttle/escape/station,
	/area/shuttle/escape_pod1/station,
	/area/shuttle/escape_pod2/station,
	/area/shuttle/escape_pod3/station,
	/area/shuttle/escape_pod4/station,
	/area/shuttle/transport1/station,
	/area/shuttle/administration/station,
	/area/shuttle/specops/station,
	/area/shuttle/officer/station,
	/area/shuttle/supply/station,
	/area/shuttle/arrival/station,
	/area/shuttle/mining/station
)