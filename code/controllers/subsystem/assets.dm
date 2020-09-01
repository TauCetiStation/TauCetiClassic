SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = SS_INIT_ASSETS
	flags = SS_NO_FIRE
	var/list/cache = list()

/datum/controller/subsystem/assets/Initialize(timeofday)
	for(var/type in subtypesof(/datum/asset))
		var/datum/asset/A = new type()
		if (type != initial(A._abstract)) //no need to register an abstract asset
			A.register()

	for(var/client/C in clients)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/getFilesSlow, C, cache, FALSE), 10)
	..()
