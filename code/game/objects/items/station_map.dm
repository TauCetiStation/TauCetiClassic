/obj/item/station_map
	name = "Station map"
	desc = "Поможет вам не заблудиться на станции."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "station_map"
	w_class = SIZE_TINY
	var/nanomap_file = "nanomap_exodus_1_areas.png"
	var/nanomap_size = 600

/obj/item/station_map/attack_self(mob/user)
	..()
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/station_map)
	assets.send(user)
	var/datum/browser/popup = new(user, "window=[name]", "[name]", nanomap_size-30, nanomap_size, ntheme = CSS_THEME_DARK)
	popup.set_content("<img src='[nanomap_file]' style='height:100%;width:auto;-ms-interpolation-mode:nearest-neighbor'><img src='nanomap_maplegend.png' style='height:60px;width:auto;position:absolute;bottom:10px;left:10px;-ms-interpolation-mode:nearest-neighbor'>")
	popup.open()

/obj/item/station_map/box
	icon_state = "station_map"
	nanomap_file = "nanomap_exodus_1_areas.png"

/obj/item/station_map/gamma
	icon_state = "gamma"
	nanomap_file = "nanomap_gamma_1_areas.png"

/obj/item/station_map/falcon
	icon_state = "falcon"
	nanomap_file = "nanomap_falcon_1_areas.png"

/obj/item/station_map/prometheus
	icon_state = "prometheus"
	nanomap_file = "nanomap_prometheus_1_areas.png"

/obj/item/station_map/delta
	icon_state = "delta"
	nanomap_file = "nanomap_delta_1_areas.png"
