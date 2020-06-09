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
	var/wsRedList = typesof(/area/station/security)

	for(var/A in wsRedList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcRed
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcRed

	//BLUE (Some of Medbay areas)
	var/wsBlueList = typesof(/area/station/medical)

	for(var/A in wsBlueList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcBlue
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcBlue

	//PURPLE (RnD + Research outpost)
	var/wsPurpleList = typesof(/area/station/rnd) + typesof(/area/asteroid/research_outpost) + /area/station/medical/genetics

	for(var/A in wsPurpleList)
		for(var/obj/structure/window/W in locate(A))
			W.color = wcPurple
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = wcPurple

	//BROWN (Mining + Cargo)
	var/wsBrownList = typesof(/area/station/cargo) + typesof(/area/asteroid/mine)

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
	var/wsIgnoreList = typesof(/area/shuttle)

	for(var/A in wsIgnoreList)
		for(var/obj/structure/window/W in locate(A))
			W.color = "ffffff"
		for(var/obj/machinery/door/window/D in locate(A))
			D.color = "ffffff"

	return 1
