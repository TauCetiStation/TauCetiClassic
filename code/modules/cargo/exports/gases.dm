/datum/export/solid_proto_hydrate
	cost = 1000
	include_subtypes = FALSE
	unit_name = "solid proto-hydrate"
	export_types = list(/obj/item/weapon/solid_phydr)

/datum/export/gas/applies_to(obj/O, contr = 0, emag = 0)
	if(contraband && !contr)
		return FALSE
	if(hacked && !emag)
		return FALSE
	if(!get_amount(O))
		return FALSE
	return TRUE

/datum/export/gas/get_amount(obj/O, contr = 0, emag = 0)
	if(istype(O, /obj/machinery/portable_atmospherics/canister) && export_gases.len)
		var/molesToExport = 0
		var/obj/machinery/portable_atmospherics/canister/C = O
		for(var/gas in export_gases)
			molesToExport += C.air_contents.gas[gas]
		return molesToExport
	else if(istype(O, /obj/item/weapon/tank) && export_gases.len)
		var/molesToExport = 0
		var/obj/item/weapon/tank/T = O
		for(var/gas in export_gases)
			molesToExport += T.air_contents.gas[gas]
		return molesToExport
	return FALSE

/datum/export/gas/phoron
	cost = 1
	unit_name = "phoron gas"
	export_gases = list("phoron")

/datum/export/gas/tritium
	cost = 2
	unit_name = "tritium gas"
	export_gases = list("tritium")

/datum/export/gas/bz
	cost = 2
	unit_name = "BZ gas"
	export_gases = list("bz")

/datum/export/gas/proto_hydrate
	cost = 3
	unit_name = "proto-hydrate gas"
	export_gases = list("phydr")

/datum/export/gas/trioxium
	cost = 3
	unit_name = "trioxium gas"
	export_gases = list("triox")

/datum/export/gas/constantium
	cost = 2
	unit_name = "constantium gas"
	export_gases = list("const")

/datum/export/gas/cardotirin
	cost = 6
	unit_name = "cardotirin gas"
	export_gases = list("ctirin")

/datum/export/gas/metastabilium
	cost = 10
	unit_name = "metastabilium gas"
	export_gases = list("mstab")
