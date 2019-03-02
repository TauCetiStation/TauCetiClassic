var/global/list/baked_smooth_icons = list()

var/datum/subsystem/icon_smooth/SSicon_smooth

/datum/subsystem/icon_smooth
	name = "Icon Smoothing"
	init_order = SS_INIT_ICON_SMOOTH
	wait = SS_WAIT_ICON_SMOOTH
	priority = SS_PRIOTITY_ICON_SMOOTH
	flags = SS_TICKER

	var/list/smooth_queue = list()
	var/list/deferred = list()

/datum/subsystem/icon_smooth/New()
	NEW_SS_GLOBAL(SSicon_smooth)

/datum/subsystem/icon_smooth/fire()
	var/list/cached = smooth_queue
	while(cached.len)
		var/atom/A = cached[cached.len]
		cached.len--
		if (A.initialized)
			smooth_icon(A)
		else
			deferred += A
		if (MC_TICK_CHECK)
			return

	if (!cached.len)
		if (deferred.len)
			smooth_queue = deferred
			deferred = cached
		else
			can_fire = FALSE

/datum/subsystem/icon_smooth/Initialize()
	smooth_zlevel(1, TRUE)
	smooth_zlevel(2, TRUE)
	var/queue = smooth_queue
	smooth_queue = list()
	for(var/V in queue)
		var/atom/A = V
		if(!A || A.z <= 2)
			continue
		smooth_icon(A)
		CHECK_TICK

	return ..()
