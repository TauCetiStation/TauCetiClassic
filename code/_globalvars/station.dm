var/global/obj/effect/datacore/data_core = null

var/CELLRATE = 0.002	// multiplier for watts per tick <> cell storage (eg: 0.02 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
						//It's a conversion constant. power_used*CELLRATE = charge_provided, or charge_used/CELLRATE = power_provided
var/CHARGELEVEL = 0.0005 // Cap for how fast cells charge, as a percentage-per-tick (0.01 means cellcharge is capped to 1% per second)

var/list/powernets = list()

// this is not strictly unused although the whole modules datum thing is unused
// To remove this you need to remove that
var/datum/moduletypes/mods = new()

// Reference list for disposal sort junctions. Filled up by sorting junction's New()
/var/list/tagger_locations = list()