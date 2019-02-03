/datum/directive/ipc_virus
	special_orders = list(
		"Terminate employment of all IPC personnel.",
		"Extract the Positronic Brains from IPC units.",
		"Mount the Positronic Brains into Cyborgs.")

	var/list/roboticist_roles = list(
		"Research Director",
		"Roboticist"
	)

	var/list/brains_to_enslave = list()
	var/list/cyborgs_to_make = list()
	var/list/ids_to_terminate = list()

/datum/directive/ipc_virus/proc/get_ipcs()
	var/list/machines[0]
	for(var/mob/M in player_list)
		if (M.is_ready() && M.get_species() == IPC)
			machines.Add(M)
	return machines

/datum/directive/ipc_virus/proc/get_roboticists()
	var/list/roboticists[0]
	for(var/mob/M in player_list)
		if (M.is_ready() && roboticist_roles.Find(M.mind.assigned_role))
			roboticists.Add(M)
	return roboticists

/datum/directive/ipc_virus/initialize()
	for(var/mob/living/carbon/human/H in get_ipcs())
		brains_to_enslave.Add(H.mind)
		cyborgs_to_make.Add(H.mind)
		ids_to_terminate.Add(H.wear_id)

/datum/directive/ipc_virus/get_description()
	return {"
		<p>
			IPC units have been found to be infected with a violent and undesired virus in Virgus Ferrorus system.
			Risk to [station_name()] IPC units has not been assessed. Further information is classified.
		</p>
	"}

/datum/directive/ipc_virus/meets_prerequisites()
	var/list/ipcs = get_ipcs()
	var/list/roboticists = get_roboticists()
	return ipcs.len > 2 && roboticists.len > 1

/datum/directive/ipc_virus/directives_complete()
	return brains_to_enslave.len == 0 && cyborgs_to_make.len == 0 && ids_to_terminate.len == 0

/datum/directive/ipc_virus/get_remaining_orders()
	var/text = ""
	for(var/brain in brains_to_enslave)
		text += "<li>Debrain [brain]</li>"

	for(var/brain in cyborgs_to_make)
		text += "<li>Enslave [brain] as a Cyborg</li>"

	for(var/id in ids_to_terminate)
		text += "<li>Terminate [id]</li>"

	return text
