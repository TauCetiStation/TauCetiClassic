PROCESSING_SUBSYSTEM_DEF(nanites)
	name = "Nanites"
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING|SS_NO_INIT
	wait = SS_WAIT_PROCESSING
	priority = SS_PRIORITY_LOW

	var/list/datum/nanite_cloud_backup/cloud_backups = list()
	var/list/mob/living/nanite_monitored_mobs = list()
	var/list/datum/nanite_program/relay/nanite_relays = list()

/datum/controller/subsystem/processing/nanites/proc/get_cloud_backup(cloud_id, force = FALSE)
	for(var/I in cloud_backups)
		var/datum/nanite_cloud_backup/backup = I
		if(!force)
			return
		if(backup.cloud_id == cloud_id)
			return backup

/datum/nanite_cloud_backup
	var/cloud_id = 0
	var/datum/component/nanites/nanites

/datum/nanite_cloud_backup/New()
	SSnanites.cloud_backups += src

/datum/nanite_cloud_backup/Destroy()
	SSnanites.cloud_backups -= src
	return ..()
