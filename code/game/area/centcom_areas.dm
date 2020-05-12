 ///////////
 //CENTCOM//
 ///////////

//Centcom
/area/centcom
	name = "Centcom"
	icon_state = "centcom"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/centcom/control
	name = "Centcom Control"

/area/centcom/evac
	name = "Centcom Emergency Shuttle"

/area/centcom/ferry
	name = "Centcom Transport Shuttle"

/area/centcom/shuttle
	name = "Centcom Administration Shuttle"

/area/centcom/test
	name = "Centcom Testing Facility"

/area/centcom/living
	name = "Centcom Living Quarters"

/area/centcom/specops
	name = "Centcom Special Ops"

/area/centcom/creed
	name = "Creed's Office"

/area/centcom/holding
	name = "Holding Facility"

//PRISON
/area/centcom/prison
	name = "Solitary Confinement"
	icon_state = "brig"

//Thunderdome
/area/centcom/tdome
	name = "Thunderdome"
	icon_state = "thunder"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/centcom/tdome/tdome1
	name = "Thunderdome (Team 1)"
	icon_state = "green"

/area/centcom/tdome/tdome2
	name = "Thunderdome (Team 2)"
	icon_state = "yellow"

/area/centcom/tdome/tdomeadmin
	name = "Thunderdome (Admin.)"
	icon_state = "purple"

/area/centcom/tdome/tdomeobserve
	name = "Thunderdome (Observer.)"
	icon_state = "purple"

// CENTCOM AREA LIST
var/list/centcom_areas_typecache = typecacheof(centcom_shuttle_areas + typesof(/area/centcom))