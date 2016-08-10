var/global/wcBrig
var/global/wcBar
var/global/wcCommon
var/global/wcDw


//for all window/New and door/window/New
/proc/color_windows(area = "common")
	var/list/common = list("#379963", "#0d8395", "#58b5c3", "#49e46e", "#8fcf44", "#cc99ff", "#ff6600", "#3399ff", "#969696", "#ffffff")
	if(!wcCommon)
		wcCommon = pick(common)
	return wcCommon

//replaces color in some area
/proc/color_windows_init()
	var/list/brig = list("#aa0808", "#7f0606", "#ff0000", "#ff0000")
	var/list/bar = list("#0d8395", "#58b5c3", "#58c366", "#90d79a", "#3399ff", "#00ffff", "#ff6600", "#ffffff")
	var/list/dw = list("#993300", "#ff6600", "#ffcc00", "#ff9933")

	wcBrig = pick(brig)
	wcBar = pick(bar)
	wcDw = pick(dw)

	//BRIG
	var/wsBrigList = list(
		/area/security/armoury,
		/area/security/brig,
		/area/security/detectives_office,
		/area/security/hos,
		/area/security/lobby,
		/area/security/main,
		/area/security/prison,
		/area/security/warden,
		/area/security/tactical,
		/area/security/range,
		/area/security/forensic_office
		)

	for(var/A in wsBrigList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcBrig
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcBrig

	//BAR
	for(var/obj/structure/window/W in locate(/area/crew_quarters/bar))
		W.color = wcBar
	for(var/obj/machinery/door/window/D in locate(/area/crew_quarters/bar))
		D.color = wcBar

	//DWARFS
	for(var/obj/structure/window/W in locate(/area/mine/dwarf))
		W.color = wcDw
	for(var/obj/machinery/door/window/D in locate(/area/mine/dwarf))
		D.color = wcDw

	//IGNORE COLORED
	var/wsIgnoreList = list(
		/area/shuttle,
		/area/shuttle/arrival,
		/area/shuttle/arrival/pre_game,
		/area/shuttle/arrival/transit,
		/area/shuttle/arrival/station,
		/area/shuttle/escape,
		/area/shuttle/escape/station,
		/area/shuttle/escape/centcom,
		/area/shuttle/escape/transit,
		/area/shuttle/escape_pod1,
		/area/shuttle/escape_pod1/station,
		/area/shuttle/escape_pod1/centcom,
		/area/shuttle/escape_pod1/transit,
		/area/shuttle/escape_pod2,
		/area/shuttle/escape_pod2/station,
		/area/shuttle/escape_pod2/centcom,
		/area/shuttle/escape_pod2/transit,
		/area/shuttle/escape_pod3,
		/area/shuttle/escape_pod3/station,
		/area/shuttle/escape_pod3/centcom,
		/area/shuttle/escape_pod3/transit,
		/area/shuttle/escape_pod5,
		/area/shuttle/escape_pod5/station,
		/area/shuttle/escape_pod5/centcom,
		/area/shuttle/escape_pod5/transit,
		/area/shuttle/mining,
		/area/shuttle/mining/station,
		/area/shuttle/mining/outpost,
		/area/shuttle/transport1/centcom,
		/area/shuttle/transport1/station,
		/area/shuttle/alien/base,
		/area/shuttle/alien/mine,
		/area/shuttle/prison,
		/area/shuttle/prison/station,
		/area/shuttle/prison/prison,
		/area/shuttle/specops/centcom,
		/area/shuttle/specops/station,
		/area/shuttle/syndicate_elite/mothership,
		/area/shuttle/syndicate_elite/station,
		/area/shuttle/administration/centcom,
		/area/shuttle/administration/station,
		/area/shuttle/thunderdome,
		/area/shuttle/thunderdome/grnshuttle,
		/area/shuttle/thunderdome/grnshuttle/dome,
		/area/shuttle/thunderdome/grnshuttle/station,
		/area/shuttle/thunderdome/redshuttle,
		/area/shuttle/thunderdome/redshuttle/dome,
		/area/shuttle/thunderdome/redshuttle/station,
		/area/shuttle/research,
		/area/shuttle/research/station,
		/area/shuttle/research/outpost,
		/area/shuttle/vox/station
		)

	for(var/A in wsIgnoreList)
		for(var/obj/structure/window/W in locate(A))
			W.color = "ffffff"
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = "ffffff"

	return 1
