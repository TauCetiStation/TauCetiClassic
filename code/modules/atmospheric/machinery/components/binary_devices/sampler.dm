#define ALERT_COOLDOWN (60 SECONDS)

/obj/machinery/atmospherics/components/binary/sampler
	name = "gas sampler"
	desc = "Pipe which samples gas in the system and alerts station of irregularities."
	icon = 'icons/atmos/sampler.dmi'
	icon_state = "map_sampler"
	can_unwrench = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	connect_types = CONNECT_TYPE_REGULAR | CONNECT_TYPE_SCRUBBER | CONNECT_TYPE_SUPPLY

	undertile = FALSE

	// Prevent unauthorized usage
	req_access = list(access_atmospherics)
	allowed_checks = ALLOWED_CHECK_NONE
	var/locked = TRUE

	// Used in radio messages to identify the device
	var/node_name

	// List of associations "gas_id" = list("min" = x, "max" = y)
	// values represent the threshold ratio of gas amount to the whole mix and must be between 0 and 1
	var/list/thresholds = list()

	COOLDOWN_DECLARE(last_alert)
	var/obj/item/device/radio/intercom/alert

	// to indicate problems on sprite
	var/alerted = FALSE

/obj/machinery/atmospherics/components/binary/sampler/atom_init()
	. = ..()
	alert = new
	if(!node_name)
		node_name = "sampler ([rand(100, 999)])"

	for(var/gas_id in gas_data.gases_knowable)
		if(!gas_data.gases_knowable[gas_id])
			continue
		if(!thresholds[gas_id])
			thresholds[gas_id] = list("min" = 0.0, "max" = 1.0)

/obj/machinery/atmospherics/components/binary/sampler/Destroy()
	. = ..()
	QDEL_NULL(alert)

/obj/machinery/atmospherics/components/binary/sampler/update_icon()
	. = ..()
	if(!powered())
		icon_state = "sampler0"
	else if(alerted)
		icon_state = "sampler2"
	else
		icon_state = "sampler1"

/obj/machinery/atmospherics/components/binary/sampler/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		var/obj/machinery/atmospherics/node1 = NODE1
		var/obj/machinery/atmospherics/node2 = NODE2
		add_underlay(T, node1, get_dir(src, node1), node1 ? node1.icon_connect_type : "")
		add_underlay(T, node2, get_dir(src, node2), node2 ? node2.icon_connect_type : "")

/obj/machinery/atmospherics/components/binary/sampler/process_atmos()
	if(!powered())
		update_icon()
		return

	if(!COOLDOWN_FINISHED(src, last_alert))
		return

	// reconcile_air() guarantees free passing of air through this device, so AIR1 = AIR2
	var/datum/gas_mixture/A = AIR1
	if(!NODE1 || !AIR1 || !A.gas.len)
		return

	for(var/gas_id in thresholds)
		if(!A.gas[gas_id])
			continue
		var/ratio = A.gas[gas_id] / A.total_moles
		var/problem
		if(ratio < thresholds[gas_id]["min"])
			problem = "lower"
		if(!problem && ratio > thresholds[gas_id]["max"])
			problem = "upper"
		if(problem)
			alert.autosay("Concentration of [gas_data.name[gas_id]] exceeded its [problem] bound in node \"[node_name]\".", "Atmospherics Alert System")
			COOLDOWN_START(src, last_alert, ALERT_COOLDOWN)
			alerted = TRUE
			break
		alerted = FALSE
	update_icon()

/obj/machinery/atmospherics/components/binary/sampler/attackby(obj/item/W, mob/user)
	if(!powered())
		return ..()

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda)) // trying to unlock the interface with an ID card
		if(allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock" ] the sampler interface.</span>")
		return TRUE

	return ..()

/obj/machinery/atmospherics/components/binary/sampler/emag_act(mob/user)
	if(!powered())
		return FALSE
	if(!locked)
		return FALSE
	locked = !locked
	// there is no point in setting something like emagged because unwrenching and wrenching back will reset it
	// we wait until /obj/item/pipe refactor
	to_chat(user, "<span class='warning'>You hack the sampler interface.</span>")

/obj/machinery/atmospherics/components/binary/sampler/tgui_status(mob/user)
	. = ..()
	if(!powered())
		return UI_CLOSE
	if(locked)
		return min(., UI_UPDATE)

/obj/machinery/atmospherics/components/binary/sampler/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/atmospherics/components/binary/sampler/tgui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new (user, src, "SamplerPipe")
		ui.open()

/obj/machinery/atmospherics/components/binary/sampler/tgui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["nodeName"] = node_name
	data["locked"] = locked
	var/list/gases = list()
	for(var/gas_id in thresholds)
		gases.Add(list(list(
			"id" = gas_id,
			"name" = gas_data.name[gas_id],
			"threshold" = thresholds[gas_id],
		)))
	data["gases"] = gases
	return data

/obj/machinery/atmospherics/components/binary/sampler/tgui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(locked)
		return
	switch(action)
		if("setBound")
			if(isnull(thresholds[params["id"]]) || isnull(thresholds[params["id"]][params["bound"]]))
				return
			thresholds[params["id"]][params["bound"]] = clamp(text2num(params["value"]), 0.0, 1.0)
		if("setName")
			node_name = sanitize(params["name"], max_length = 16, ascii_only = TRUE)

// a simple prefab for mapping that only reacts to phoron and n2o.
/obj/machinery/atmospherics/components/binary/sampler/stock
	thresholds = list(
		"phoron" = list("min" = 0.0, "max" = 0.02),
		"sleeping_agent" = list("min" = 0.0, "max" = 0.02),
	)
	node_name = "distribution"

#undef ALERT_COOLDOWN
