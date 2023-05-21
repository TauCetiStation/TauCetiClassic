SUBSYSTEM_DEF(evidence)
	name = "Evidence"
	wait = 3 MINUTES
	priority = SS_PRIORITY_LOW
	flags = SS_NO_INIT
	var/list/evidence_list = list()
	var/list/queued_evidences = list()

/datum/controller/subsystem/evidence/proc/add_to_queue(datum/component/evidence/E)
	if(E in queued_evidences)
		return
	if((next_fire - last_fire) / 2 > next_fire - world.time)
		addtimer(CALLBACK(src, .proc/add_to_queue, E), next_fire - world.time + 1)
		return
	queued_evidences += E

/datum/controller/subsystem/evidence/proc/del_from_queue(datum/component/evidence/E)
	queued_evidences -= E

/datum/controller/subsystem/evidence/proc/add_evidence_from_queue()
	for(var/datum/component/evidence/E in queued_evidences)
		evidence_list += E
	queued_evidences.Cut()

/datum/controller/subsystem/evidence/proc/del_one_evidence(datum/component/evidence/E)
	evidence_list -= E

/datum/controller/subsystem/evidence/proc/del_old_evidences()
	for(var/datum/component/evidence/E in evidence_list)
		evidence_list -= E
		qdel(E)

/datum/controller/subsystem/evidence/fire()
	del_old_evidences()
	add_evidence_from_queue()
