SUBSYSTEM_DEF(evidence)
	name = "Evidence"
	wait = 1 MINUTES
	priority = SS_PRIORITY_LOW
	flags = SS_NO_INIT
	var/list/evidence_list = list()
	var/list/queved_evidences = list()

/datum/controller/subsystem/evidence/proc/add_to_queve(datum/component/evidence/E)
	if(E in queved_evidences)
		return
	if((next_fire - last_fire) / 2 > next_fire - world.time)
		addtimer(CALLBACK(src, .proc/add_to_queve, E), next_fire - world.time + 1)
		return
	queved_evidences += E

/datum/controller/subsystem/evidence/proc/del_from_queve(datum/component/evidence/E)
	if(!(E in queved_evidences))
		return
	queved_evidences -= E

/datum/controller/subsystem/evidence/proc/add_evidence_from_queve()
	for(var/datum/component/evidence/E in queved_evidences)
		evidence_list += E
	queved_evidences.Cut()

/datum/controller/subsystem/evidence/proc/del_one_evidence(datum/component/evidence/E)
	if(E in evidence_list)
		evidence_list -= E

/datum/controller/subsystem/evidence/proc/del_old_evidences()
	for(var/datum/component/evidence/E in evidence_list)
		evidence_list -= E
		qdel(E)

/datum/controller/subsystem/evidence/fire()
	del_old_evidences()
	add_evidence_from_queve()
