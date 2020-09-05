SUBSYSTEM_DEF(localization)
	name = "Localization"
	init_order = SS_INIT_LOCALIZATION
	flags = SS_NO_FIRE
	var/datum/localization/localization = new /datum/localization

/datum/controller/subsystem/localization/Initialize()
	for(var/type in subtypesof(/datum/localization))
		var/datum/localization/L = type
		if(config.language == initial(L.name))
			localization = new L
	..()
