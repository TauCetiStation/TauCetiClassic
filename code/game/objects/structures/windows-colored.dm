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
	var/list/purple = list("#ba62b1", "#Ba3fad", "#a54f9e", "#b549d1")
	var/list/brown = list("#9e5312", "#99761e", "#a56b00", "#d87f2b")
	var/list/green = list("#aed18b", "#7bce23", "#5a9619", "#709348")
	var/list/blue = list("#8dbdd7", "#299bd8", "#1e719e", "#2bb8ff")

	wcRed = pick(red)
	wcPurple = pick(purple)
	wcBrown = pick(brown)
	wcGreen = pick(green)
	wcBlue = pick(blue)
	wcBar = pick(bar)
	wcDw = pick(dw)

	//RED (Only sec stuff honestly)
	var/wsRedList = list(
		/area/security/armoury,
		/area/security/brig,
		/area/security/detectives_office,
		/area/security/hos,
		/area/security/lobby,
		/area/security/main,
		/area/security/prison,
		/area/security/warden,
		/area/security/range,
		/area/security/forensic_office,
		/area/security/checkpoint
		)

	for(var/A in wsRedList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcRed
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcRed

	//PURPLE (RnD + Research outpost)
	var/wsPurpleList = list(
		/area/rnd/lab,
		/area/crew_quarters/hor,
		/area/rnd/hallway,
		/area/rnd/xenobiology,
		/area/rnd/storage,
		/area/rnd/test_area,
		/area/rnd/mixing,
		/area/rnd/misc_lab,
		/area/rnd/telesci,
		/area/rnd/scibreak,
		/area/toxins/server,
		/area/assembly/chargebay,
		/area/assembly/robotics,
		/area/toxins/brainstorm_center,
		/area/research_outpost/hallway,
		/area/research_outpost/gearstore,
		/area/research_outpost/maint,
		/area/research_outpost/iso1,
		/area/research_outpost/iso2,
		/area/research_outpost/harvesting,
		/area/research_outpost/outpost_misc_lab,
		/area/research_outpost/anomaly,
		/area/research_outpost/med,
		/area/research_outpost/entry,
		/area/research_outpost/longtermstorage,
		/area/research_outpost/tempstorage,
		/area/research_outpost/maintstore2,
		/area/medical/genetics
		)

	for(var/A in wsPurpleList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcPurple
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcPurple

	//BROWN (Mining + Cargo)
	var/wsBrownList = list(
		/area/quartermaster/office,
		/area/quartermaster/storage,
		/area/quartermaster/qm,
		/area/quartermaster/recycler,
		/area/quartermaster/recycleroffice,
		/area/quartermaster/miningbreaktime,
		/area/quartermaster/miningoffice,
		/area/mine/production,
		/area/mine/eva,
		/area/mine/living_quarters,
		/area/mine/maintenance,
		/area/mine/west_outpost
		)

	for(var/A in wsBrownList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcBrown
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcBrown

	//GREEN (Virology and Hydro areas)
	var/wsGreenList = list(
		/area/medical/virology,
		/area/hydroponics,
		/area/research_outpost/maintstore1,
		/area/research_outpost/sample
		)

	for(var/A in wsGreenList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcGreen
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcGreen

	//BLUE (Some of Medbay areas)
	var/wsBlueList = list(
		/area/medical/reception,
		/area/medical/morgue,
		/area/medical/hallway,
		/area/medical/genetics_cloning,
		/area/medical/cmo,
		/area/medical/psych,
		/area/medical/patients_rooms,
		/area/medical/patient_a,
		/area/medical/patient_b,
		/area/medical/medbreak,
		/area/medical/surgeryobs,
		/area/medical/surgery,
		/area/medical/surgery2,
		/area/medical/storage,
		/area/medical/chemistry
		)

	for(var/A in wsBlueList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcBlue
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcBlue

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
		/area/shuttle/specops/centcom,
		/area/shuttle/specops/station,
		/area/shuttle/syndicate_elite/mothership,
		/area/shuttle/syndicate_elite/station,
		/area/shuttle/administration/centcom,
		/area/shuttle/administration/station,
		/area/shuttle/research,
		/area/shuttle/vox/station
		)

	for(var/A in wsIgnoreList)
		for(var/obj/structure/window/W in locate(A))
			W.color = "ffffff"
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = "ffffff"

	return 1
