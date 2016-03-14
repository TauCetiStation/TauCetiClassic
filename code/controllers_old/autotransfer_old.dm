var/datum/controller/transfer_controller/transfer_controller

/datum/controller/transfer_controller
	var/timerbuffer = 0 //buffer for time check
	var/currenttick = 0
/datum/controller/transfer_controller/New()
	timerbuffer = config.vote_autotransfer_initial
	SSobj.processing |= src

/datum/controller/transfer_controller/Destroy()
	SSobj.processing.Remove(src)

/datum/controller/transfer_controller/process()
	currenttick = currenttick + 1
	if (world.time >= timerbuffer - 600)
		vote.autotransfer()
		timerbuffer = timerbuffer + config.vote_autotransfer_interval
