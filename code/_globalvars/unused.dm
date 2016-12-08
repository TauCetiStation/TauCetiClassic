var/skipupdate = 0

var/shuttlecoming = 0
var/forceblob = 0
var/datum/debug/debugobj

var/list/liftable_structures = list(\

	/obj/machinery/autolathe, \
	/obj/machinery/constructable_frame, \
	/obj/machinery/hydroponics, \
	/obj/machinery/computer, \
	/obj/machinery/optable, \
	/obj/structure/dispenser, \
	/obj/machinery/gibber, \
	/obj/machinery/kitchen_machine/microwave, \
	/obj/machinery/vending, \
	/obj/machinery/seed_extractor, \
	/obj/machinery/space_heater, \
	/obj/machinery/recharge_station, \
	/obj/machinery/flasher, \
	/obj/structure/stool, \
	/obj/structure/closet, \
	/obj/machinery/photocopier, \
	/obj/structure/filingcabinet, \
	/obj/structure/reagent_dispensers, \
	/obj/machinery/portable_atmospherics/canister)

//	list/mazewarp = list()
//	list/traitors = list()	//traitor list
//  reverse_dir[dir] = reverse of dir
var/datum/engine_eject/engine_eject_control = null
var/datum/air_tunnel/air_tunnel1/SS13_airtunnel = null

//var/red_alert_code = 0 //Used in new code red and emergency shuttle call lighting
//var/red_alert_evac = 0
