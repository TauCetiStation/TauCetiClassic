var/datum/subsystem/assets/SSasset

/datum/subsystem/assets
	name = "Assets"

	init_order = SS_INIT_ASSETS

	flags = SS_NO_FIRE

	var/list/cache = list()

/datum/subsystem/assets/New()
	NEW_SS_GLOBAL(SSasset)

/datum/subsystem/assets/Initialize(timeofday)
	for(var/type in typesof(/datum/asset) - list(/datum/asset, /datum/asset/simple))
		var/datum/asset/A = new type()
		A.register()

	for(var/client/C in clients)
		addtimer(GLOBAL_PROC, "getFilesSlow", 10, FALSE, C, cache, FALSE)
	..()