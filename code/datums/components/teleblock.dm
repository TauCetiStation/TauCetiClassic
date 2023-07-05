// Note in case if you want to port teleport channels from /tg/: 
// in my opinion, we should not distinguish between magic, cult and bluespace teleportations technologies
// it's better to leave the question "what is magic?" open

/datum/component/teleblock
	dupe_mode = COMPONENT_DUPE_ALLOWED // one turf can have multiple sources for teleportation interference

/datum/component/teleblock/Initialize(source)
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/teleblock/RegisterWithParent() //RegisterSignal
	RegisterSignal(parent, COMSIG_ATOM_INTERCEPT_TELEPORT, PROC_REF(intercept))

/datum/component/teleblock/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_INTERCEPT_TELEPORT)

/datum/component/teleblock/proc/intercept()
	return COMPONENT_BLOCK_TELEPORT



// see /obj/machinery/telescience_jammer
/datum/component/teleblock/jammer
	var/obj/machinery/telescience_jammer/source

/datum/component/teleblock/jammer/Initialize(source)
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE

	if(!source)
		return COMPONENT_NOT_ATTACHED

	src.source = source

/datum/component/teleblock/jammer/intercept()
	if(source.is_operational())
		return COMPONENT_BLOCK_TELEPORT
