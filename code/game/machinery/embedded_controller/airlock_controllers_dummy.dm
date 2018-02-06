// Provides remote access to a controller (since they must be unique).
/obj/machinery/dummy_airlock_controller
	name = "airlock control terminal"
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_control_standby"
	layer = ABOVE_OBJ_LAYER

	var/datum/topic_state/remote/remote_state
	var/obj/machinery/embedded_controller/radio/airlock/master_controller
	var/id_tag

/obj/machinery/dummy_airlock_controller/atom_init()
	. = ..()
	if(id_tag)
		for(var/obj/machinery/embedded_controller/radio/airlock/_master in SSmachines.machinery)
			if(_master.id_tag == id_tag)
				master_controller = _master
				master_controller.dummy_terminals += src
				break
	if(!master_controller)
		qdel(src)
	else
		remote_state = new /datum/topic_state/remote(src, master_controller)

/obj/machinery/dummy_airlock_controller/Destroy()
	if(master_controller)
		master_controller.dummy_terminals -= src
	if(remote_state)
		qdel(remote_state)
		remote_state = null
	return ..()

/obj/machinery/dummy_airlock_controller/attack_hand(mob/user)
	if(..())
		return
	if(master_controller)
		if(master_controller.stat & (NOPOWER|BROKEN|MAINT))
			return
		open_remote_ui(user)

/obj/machinery/dummy_airlock_controller/proc/open_remote_ui(mob/user)
	if(master_controller)
		return master_controller.ui_interact(user, state = remote_state)
