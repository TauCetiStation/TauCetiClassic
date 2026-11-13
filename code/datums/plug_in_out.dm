/datum/plug
	var/name = "шланг"
	cases = list("шланг", "шланга", "шлангу", "шланг", "шлангом", "шланге")
	var/male = FALSE //in - TRUE; out - FALSE;
	var/plug_type = "reagent"

	var/atom/movable/master
	var/datum/plug/connected

	var/beam_type = /obj/effect/ebeam/pipe
	var/beam_x
	var/beam_y

/datum/plug/male
	male = TRUE

/obj/effect/ebeam/pipe
	name = "pipe"
	icon_state = "1-full"

	color = "#b9451d"

/datum/plug/New(atom/A)
	master = A

/datum/plug/Destroy()
	disconnect()
	UnregisterSignal(master, list(COMSIG_MOUSEDROPPED_ONTO))
	master = null
	return ..()

/datum/plug/proc/try_connect(atom/A)
	if(!A.plug || ispath(A.plug))
		return

	var/datum/plug/P = A.plug
	if(P.connected)
		return

	if(P.male == male)
		return

	if(P.plug_type != plug_type)
		return

	P.connected = src
	connected = P

	if(male)
		add_bounds()
	else
		connected.add_bounds()

/datum/plug/proc/add_bounds()
	master.AddComponent(/datum/component/bounded, connected.master, 0, 3, CALLBACK(src, PROC_REF(resolve_stranded)), null, TRUE, TRUE, beam_type, beam_x, beam_y)

	master.visible_message("<span class='rose'>[CASE(master, NOMINATIVE_CASE)] присоединяется [CASE(src, ABLATIVE_CASE)] к [CASE(connected.master, DATIVE_CASE)].</span>")

/datum/plug/proc/resolve_stranded(datum/component/bounded/bounds)
	disconnect()
	return TRUE

/datum/plug/proc/remove_bounds()
	qdel(master.GetComponent(/datum/component/bounded))

	master.visible_message("<span class='rose'>[C_CASE(src, NOMINATIVE_CASE)] отсоединяется.</span>")

/datum/plug/proc/disconnect()
	if(male)
		remove_bounds()
	else if(connected)
		connected.remove_bounds()

	if(connected)
		connected.connected = null
		connected = null

/datum/plug/proc/get_resource_amount(resource_type)
	return male ? resource_type ? master.reagents?.get_reagent_amount(resource_type) : master.reagents?.total_volume : resource_type ? connected?.master.reagents?.get_reagent_amount(resource_type) : connected?.master.reagents?.total_volume

/datum/plug/proc/get_max_resource_amount()
	return male ? master.reagents?.maximum_volume : connected?.master.reagents?.maximum_volume

/datum/plug/proc/use_resource(amount, resource_type = null)
	var/available = get_resource_amount(resource_type)

	if(amount > available)
		return FALSE

	if(!resource_type)
		male ? master.reagents?.remove_any(amount) : connected?.master.reagents?.remove_any(amount)
	else
		male ? master.reagents?.remove_reagent(resource_type, amount) : connected?.master.reagents?.remove_reagent(resource_type, amount)

	return TRUE

/datum/plug/proc/transfer_resource(amount, resource_type)
	if(!connected)
		return

	var/available = get_resource_amount(resource_type)

	if(amount > available)
		return FALSE

	if(!resource_type)
		male ? master.reagents?.trans_to(connected.master, amount) : connected?.master.reagents?.trans_to(master, amount)
	else
		male ? master.reagents?.trans_id_to(connected.master, resource_type, amount) : connected?.master.reagents?.trans_id_to(master, resource_type, amount)

	return TRUE


/datum/plug/energy
	name = "кабель"
	cases = list("кабель", "кабеля", "кабелю", "кабель", "кабелем", "кабеле")
	male = FALSE //in - TRUE; out - FALSE;
	plug_type = "energy"

	beam_type = /obj/effect/ebeam/cord

/datum/plug/energy/male
	male = TRUE

/obj/effect/ebeam/cord
	name = "pipe"
	icon_state = "1-full"

	color = "yellow"

/datum/plug/energy/get_resource_amount(resource_type)
	var/obj/machinery/machine
	if(male)
		machine = master
	else
		machine = connected?.master

	if(!machine)
		return FALSE

	return machine.anchored && machine.stat & (NOPOWER|BROKEN)

/datum/plug/energy/get_max_resource_amount()
	return

/datum/plug/energy/use_resource(amount, resource_type = null)
	var/obj/machinery/machine
	if(male)
		machine = master
	else
		machine = connected?.master

	if(!machine)
		return FALSE

	machine.use_power(amount)

	return TRUE
