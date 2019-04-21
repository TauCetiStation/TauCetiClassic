/turf/space/transit
	var/pushdirection // push things that get caught in the transit tile this direction

//Overwrite because we dont want people building rods in space.
/turf/space/transit/attackby(obj/O, mob/user)
	return

/turf/space/transit/north // moving to the north
	pushdirection = SOUTH  // south because the space tile is scrolling south

	//IF ANYONE KNOWS A MORE EFFICIENT WAY OF MANAGING THESE SPRITES, BE MY GUEST.
/turf/space/transit/north/shuttlespace_ns1
	icon_state = "speedspace_ns_1"
/turf/space/transit/north/shuttlespace_ns2
	icon_state = "speedspace_ns_2"
/turf/space/transit/north/shuttlespace_ns3
	icon_state = "speedspace_ns_3"
/turf/space/transit/north/shuttlespace_ns4
	icon_state = "speedspace_ns_4"
/turf/space/transit/north/shuttlespace_ns5
	icon_state = "speedspace_ns_5"
/turf/space/transit/north/shuttlespace_ns6
	icon_state = "speedspace_ns_6"
/turf/space/transit/north/shuttlespace_ns7
	icon_state = "speedspace_ns_7"
/turf/space/transit/north/shuttlespace_ns8
	icon_state = "speedspace_ns_8"
/turf/space/transit/north/shuttlespace_ns9
	icon_state = "speedspace_ns_9"
/turf/space/transit/north/shuttlespace_ns10
	icon_state = "speedspace_ns_10"
/turf/space/transit/north/shuttlespace_ns11
	icon_state = "speedspace_ns_11"
/turf/space/transit/north/shuttlespace_ns12
	icon_state = "speedspace_ns_12"
/turf/space/transit/north/shuttlespace_ns13
	icon_state = "speedspace_ns_13"
/turf/space/transit/north/shuttlespace_ns14
	icon_state = "speedspace_ns_14"
/turf/space/transit/north/shuttlespace_ns15
	icon_state = "speedspace_ns_15"

/turf/space/transit/east // moving to the east
	pushdirection = WEST

/turf/space/transit/east/shuttlespace_ew1
	icon_state = "speedspace_ew_1"
/turf/space/transit/east/shuttlespace_ew2
	icon_state = "speedspace_ew_2"
/turf/space/transit/east/shuttlespace_ew3
	icon_state = "speedspace_ew_3"
/turf/space/transit/east/shuttlespace_ew4
	icon_state = "speedspace_ew_4"
/turf/space/transit/east/shuttlespace_ew5
	icon_state = "speedspace_ew_5"
/turf/space/transit/east/shuttlespace_ew6
	icon_state = "speedspace_ew_6"
/turf/space/transit/east/shuttlespace_ew7
	icon_state = "speedspace_ew_7"
/turf/space/transit/east/shuttlespace_ew8
	icon_state = "speedspace_ew_8"
/turf/space/transit/east/shuttlespace_ew9
	icon_state = "speedspace_ew_9"
/turf/space/transit/east/shuttlespace_ew10
	icon_state = "speedspace_ew_10"
/turf/space/transit/east/shuttlespace_ew11
	icon_state = "speedspace_ew_11"
/turf/space/transit/east/shuttlespace_ew12
	icon_state = "speedspace_ew_12"
/turf/space/transit/east/shuttlespace_ew13
	icon_state = "speedspace_ew_13"
/turf/space/transit/east/shuttlespace_ew14
	icon_state = "speedspace_ew_14"
/turf/space/transit/east/shuttlespace_ew15
	icon_state = "speedspace_ew_15"


/turf/space/transit/west // moving to the west
	pushdirection = EAST

/turf/space/transit/west/shuttlespace_we1
	icon_state = "speedspace_we_1"
/turf/space/transit/west/shuttlespace_we2
	icon_state = "speedspace_we_2"
/turf/space/transit/west/shuttlespace_we3
	icon_state = "speedspace_we_3"
/turf/space/transit/west/shuttlespace_we4
	icon_state = "speedspace_we_4"
/turf/space/transit/west/shuttlespace_we5
	icon_state = "speedspace_we_5"
/turf/space/transit/west/shuttlespace_we6
	icon_state = "speedspace_we_6"
/turf/space/transit/west/shuttlespace_we7
	icon_state = "speedspace_we_7"
/turf/space/transit/west/shuttlespace_we8
	icon_state = "speedspace_we_8"
/turf/space/transit/west/shuttlespace_we9
	icon_state = "speedspace_we_9"
/turf/space/transit/west/shuttlespace_we10
	icon_state = "speedspace_we_10"
/turf/space/transit/west/shuttlespace_we11
	icon_state = "speedspace_we_11"
/turf/space/transit/west/shuttlespace_we12
	icon_state = "speedspace_we_12"
/turf/space/transit/west/shuttlespace_we13
	icon_state = "speedspace_we_13"
/turf/space/transit/west/shuttlespace_we14
	icon_state = "speedspace_we_14"
/turf/space/transit/west/shuttlespace_we15
	icon_state = "speedspace_we_15"
