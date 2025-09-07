//map and direction signs

/obj/structure/sign/map
	name = "station map"
	desc = "A framed picture of the station."
	var/nanomap_file
	var/nanomap_size = 600

/obj/structure/sign/map/examine(mob/user)
	..()
	if(nanomap_file)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/station_map)
		assets.send(user)
		var/datum/browser/popup = new(user, "window=[name]", "[name]", nanomap_size-30, nanomap_size, ntheme = CSS_THEME_DARK)
		popup.set_content("<img src='[nanomap_file]' style='height:100%;width:auto;-ms-interpolation-mode:nearest-neighbor'><img src='nanomap_maplegend.png' style='height:60px;width:auto;position:absolute;bottom:10px;left:10px;-ms-interpolation-mode:nearest-neighbor'>")
		popup.open()

/obj/structure/sign/map/left
	icon_state = "map-left"
	nanomap_file = "nanomap_exodus_1_areas.png"

/obj/structure/sign/map/right
	icon_state = "map-right"
	nanomap_file = "nanomap_exodus_1_areas.png"

/obj/structure/sign/map/gamma_left
	icon_state = "gammamap-left"
	nanomap_file = "nanomap_gamma_1_areas.png"

/obj/structure/sign/map/gamma_right
	icon_state = "gammamap-right"
	nanomap_file = "nanomap_gamma_1_areas.png"

/obj/structure/sign/map/prometheus
	icon_state = "prometheus"
	nanomap_file = "nanomap_prometheus_1_areas.png"

/obj/structure/sign/directions/science
	name = "science department"
	desc = "A direction sign, pointing out which way the Science department is."
	icon_state = "direction_sci"

/obj/structure/sign/directions/engineering
	name = "engineering department"
	desc = "A direction sign, pointing out which way the Engineering department is."
	icon_state = "direction_eng"

/obj/structure/sign/directions/security
	name = "security department"
	desc = "A direction sign, pointing out which way the Security department is."
	icon_state = "direction_sec"

/obj/structure/sign/directions/medical
	name = "medical bay"
	desc = "A direction sign, pointing out which way the Medical Bay is."
	icon_state = "direction_med"

/obj/structure/sign/directions/evac
	name = "escape arm"
	desc = "A direction sign, pointing out which way the escape shuttle dock is."
	icon_state = "direction_evac"

/obj/structure/sign/directions/supply
	name = "cargo bay"
	desc = "A direction sign, pointing out which way the Cargo Bay is."
	icon_state = "direction_supply"

/obj/structure/sign/directions/command
	name = "command department"
	desc = "A direction sign, pointing out which way the Command department is."
	icon_state = "direction_bridge"

/obj/structure/sign/directions/holodeck
	name = "holodeck"
	desc = "A direction sign, pointing out which way the Holodeck is."
	icon_state = "direction_holodeck"

/obj/structure/sign/deck/bridge
	name = "Bridge Deck"
	icon_state = "deck-b"

/obj/structure/sign/deck/first
	name = "First Deck"
	icon_state = "deck-1"

/obj/structure/sign/deck/second
	name = "Second Deck"
	icon_state = "deck-2"

/obj/structure/sign/deck/third
	name = "Third Deck"
	icon_state = "deck-3"

/obj/structure/sign/deck/fourth
	name = "Fourth Deck"
	icon_state = "deck-4"
