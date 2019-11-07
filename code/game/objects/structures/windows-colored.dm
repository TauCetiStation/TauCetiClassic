var/global/wcCommon
var/global/wcRed
var/global/wcPurple
var/global/wcBrown
var/global/wcGreen
var/global/wcBlue
var/global/wcBar
var/global/wcDw


//for all window/New and door/window/New
/proc/color_windows(area = "common")
	var/list/common = list("#379963", "#0d8395", "#58b5c3", "#49e46e", "#8fcf44", "#cc99ff", "#ff6600", "#3399ff", "#969696", "#ffffff")
	if(!wcCommon)
		wcCommon = pick(common)
	return wcCommon

//replaces color in some area
/proc/color_windows_init()
	var/list/red = list("#aa0808", "#990707", "#e50909", "#e50909")
	var/list/bar = list("#0d8395", "#58b5c3", "#58c366", "#90d79a", "#3399ff", "#00ffff", "#ff6600", "#ffffff")
	var/list/dw = list("#993300", "#ff6600", "#ffcc00", "#ff9933")
	var/list/purple = list("#ba62b1", "#ba3fad", "#a54f9e", "#b549d1")
	var/list/brown = list("#9e5312", "#99761e", "#a56b00", "#d87f2b")
	var/list/green = list("#aed18b", "#7bce23", "#5a9619", "#709348")
	var/list/blue = list("#054166", "#5995ba", "#1e719e", "#7cb8dd")

	wcRed = pick(red)
	wcPurple = pick(purple)
	wcBrown = pick(brown)
	wcGreen = pick(green)
	wcBlue = pick(blue)
	wcBar = pick(bar)
	wcDw = pick(dw)

	//RED (Only sec stuff honestly)
	var/wsRedList = list(
		/area/station/security/armoury,
		/area/station/security/brig,
		/area/station/security/detectives_office,
		/area/station/security/hos,
		/area/station/security/lobby,
		/area/station/security/main,
		/area/station/security/prison,
		/area/station/security/warden,
		/area/station/security/range,
		/area/station/security/forensic_office,
		/area/station/security/checkpoint,
		/area/station/security/secconfhall
		)

	for(var/A in wsRedList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcRed
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcRed

	//PURPLE (RnD + Research outpost)
	var/wsPurpleList = list(
		/area/station/rnd/lab,
		/area/station/rnd/hor,
		/area/station/rnd/hallway,
		/area/station/rnd/xenobiology,
		/area/station/rnd/storage,
		/area/station/rnd/test_area,
		/area/station/rnd/mixing,
		/area/station/rnd/misc_lab,
		/area/station/rnd/telesci,
		/area/station/rnd/scibreak,
		/area/station/rnd/server,
		/area/station/rnd/chargebay,
		/area/station/rnd/robotics,
		/area/station/rnd/brainstorm_center,
		/area/asteroid/research_outpost/hallway,
		/area/asteroid/research_outpost/gearstore,
		/area/asteroid/research_outpost/maint,
		/area/asteroid/research_outpost/iso1,
		/area/asteroid/research_outpost/iso2,
		/area/asteroid/research_outpost/harvesting,
		/area/asteroid/research_outpost/outpost_misc_lab,
		/area/asteroid/research_outpost/anomaly,
		/area/asteroid/research_outpost/med,
		/area/asteroid/research_outpost/entry,
		/area/asteroid/research_outpost/longtermstorage,
		/area/asteroid/research_outpost/tempstorage,
		/area/asteroid/research_outpost/maintstore2,
		/area/station/medical/genetics
		)

	for(var/A in wsPurpleList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcPurple
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcPurple

	//BROWN (Mining + Cargo)
	var/wsBrownList = list(
		/area/station/cargo/office,
		/area/station/cargo/storage,
		/area/station/cargo/qm,
		/area/station/cargo/recycler,
		/area/station/cargo/recycleroffice,
		/area/station/cargo/miningbreaktime,
		/area/station/cargo/miningoffice,
		/area/asteroid/mine/production,
		/area/asteroid/mine/eva,
		/area/asteroid/mine/living_quarters,
		/area/asteroid/mine/maintenance,
		/area/asteroid/mine/west_outpost
		)

	for(var/A in wsBrownList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcBrown
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcBrown

	//GREEN (Virology and Hydro areas)
	var/wsGreenList = list(
		/area/station/medical/virology,
		/area/station/civilian/hydroponics,
		/area/asteroid/research_outpost/maintstore1,
		/area/asteroid/research_outpost/sample
		)

	for(var/A in wsGreenList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcGreen
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcGreen

	//BLUE (Some of Medbay areas)
	var/wsBlueList = list(
		/area/station/medical/reception,
		/area/station/medical/morgue,
		/area/station/medical/hallway,
		/area/station/medical/genetics_cloning,
		/area/station/medical/cmo,
		/area/station/medical/psych,
		/area/station/medical/patients_rooms,
		/area/station/medical/patient_a,
		/area/station/medical/patient_b,
		/area/station/medical/medbreak,
		/area/station/medical/surgeryobs,
		/area/station/medical/surgery,
		/area/station/medical/surgery2,
		/area/station/medical/storage,
		/area/station/medical/chemistry,
		/area/station/medical/sleeper
		)

	for(var/A in wsBlueList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcBlue
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcBlue

	//BAR
	for(var/obj/structure/window/W in locate(/area/station/civilian/bar))
		W.color = wcBar
	for(var/obj/machinery/door/window/D in locate(/area/station/civilian/bar))
		D.color = wcBar

	//DWARFS
	for(var/obj/structure/window/W in locate(/area/asteroid/mine/dwarf))
		W.color = wcDw
	for(var/obj/machinery/door/window/D in locate(/area/asteroid/mine/dwarf))
		D.color = wcDw

	//IGNORE COLORED
	var/wsIgnoreList = list(
		/area/shuttle,
		/area/shuttle/arrival,
		/area/shuttle/arrival/velocity,
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
		/area/shuttle/escape_pod4,
		/area/shuttle/escape_pod4/station,
		/area/shuttle/escape_pod4/centcom,
		/area/shuttle/escape_pod4/transit,
		/area/shuttle/mining,
		/area/shuttle/mining/station,
		/area/shuttle/mining/outpost,
		/area/shuttle/transport1/centcom,
		/area/shuttle/transport1/station,
		/area/shuttle/alien/base,
		/area/shuttle/alien/mine,
		/area/shuttle/specops/centcom,
		/area/shuttle/specops/station,
		/area/shuttle/syndicate_elite/mothership,
		/area/shuttle/syndicate_elite/station,
		/area/shuttle/administration/centcom,
		/area/shuttle/administration/station,
		/area/shuttle/mining/research,
		/area/shuttle/vox/arkship
		)

	for(var/A in wsIgnoreList)
		for(var/obj/structure/window/W in locate(A))
			W.color = "ffffff"
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = "ffffff"

	return 1
