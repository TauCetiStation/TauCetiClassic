// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet
/obj/machinery/computer/monitor
	name = "Power Monitoring Console"
	desc = "It monitors power levels across the station."
	icon = 'icons/obj/computer.dmi'
	icon_state = "power"
	light_color = "#ffcc33"
	density = TRUE
	anchored = TRUE
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 80
	circuit = /obj/item/weapon/circuitboard/powermonitor
	var/datum/powernet/powernet = null
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)

//fix for issue 521, by QualityVan.
//someone should really look into why circuits have a powernet var, it's several kinds of retarded.
/obj/machinery/computer/monitor/atom_init()
	. = ..()
	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		powernet = attached.get_powernet()

/obj/machinery/computer/monitor/process() //oh shit, somehow we didnt end up with a powernet... lets look for one.
	if(!powernet)
		var/obj/structure/cable/attached = null
		var/turf/T = loc
		if(isturf(T))
			attached = locate() in T
		if(attached)
			powernet = attached.get_powernet()
	return

/obj/machinery/computer/monitor/ui_interact(mob/user)

	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!issilicon(user) && !isobserver(user))
			user.unset_machine()
			user << browse(null, "window=powcomp")
			return

	var/t = "<TT>"

	t += "<BR><HR><A href='byond://?src=\ref[src];update=1'>Refresh</A>"

	if(!powernet)
		t += "<span class='warning'>No connection</span>"
	else

		var/equipment_cons = 0
		var/lighting_cons = 0
		var/environment_cons = 0

		var/list/apcs = list()
		var/list/powermeters = list()
		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			if(istype(term.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = term.master
				equipment_cons += A.lastused_equip
				lighting_cons += A.lastused_light
				environment_cons += A.lastused_environ
				apcs += A

		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			if(istype(term.master, /obj/machinery/power/meter))
				var/obj/machinery/power/meter/meter = term.master
				powermeters += meter

		var/meters_text = ""
		var/apcs_text = ""

		t += "<PRE>Total power: [DisplayPower(powernet.viewavail)]<BR>Total load:  [DisplayPower(powernet.viewload)]<BR></PRE>"
		t += "<PRE>Equipment: [DisplayPower(equipment_cons)]; Lighting: [DisplayPower(lighting_cons)]; Environment: [DisplayPower(environment_cons)]<BR></PRE>"

		if(powermeters.len > 0)
			meters_text += "<tr><th>Счётчик</th> <th>Нагрузка</th> <th>Использовано</th> <th>Цена за 1кВт/ч</th> <th>Статус</th></tr>"
			for(var/obj/machinery/power/meter/meter in powermeters)
				var/acc_name = meter.name
				var/datum/money_account/acc = get_account(meter.connected_account_number)
				if(acc)
					acc_name = "[acc.owner_name]'s power meter"
				meters_text += "<tr><td>[acc_name]</td> <td>[DisplayPower(meter.actual_load)]</td> <td>[WATT_TO_KWH(meter.powerused)]кВт/ч</td>"
				meters_text += "<td><A href='byond://?src=\ref[src];change_meter_rate=1;meter_ref=[REF(meter)]'>[meter.credits_per_kwh]$</A></td>"
				meters_text += "<td>[meter.can_operate() ? "<span style='color: green'>ON</span>" : "<span style='color: red'>OFF</span>"]</td>"

			t += "<FONT SIZE=-1><TABLE style='border-collapse: separate; border: 0px solid transparent; border-spacing: 0 0px; width: 100%'>"
			t += meters_text
			t += "</TABLE></FONT>"


		if(apcs.len > 0)
			apcs_text += "<tr> <th>Area</th> <th>Eqp.</th> <th>Lgt.</th> <th>Env.</th>"
			apcs_text += "<th style='text-align: center'>Load</th> <th style='text-align: right'>Cell </th> <th> - </th> </tr>"

			var/list/S = list("Off", "A-Off", "On", "A-On")
			var/list/chg = list("<span style='color: red'>N</span>", "<span style='color: orange'>C</span>", "<span style='color: green'>F</span>")

			for(var/obj/machinery/power/apc/A in apcs)
				apcs_text += "<tr> <td>"
				apcs_text += copytext("\The [A.area]", 1, 30)
				apcs_text += "</td> <td>[S[A.equipment + 1]]</td> <td>[S[A.lighting + 1]]</td> <td>[S[A.environ + 1]]</td>"
				apcs_text += "<td style='text-align: right'>[round(A.lastused_total)]</td> <td style='text-align: right'>"

				if(A.cell)
					apcs_text += "[round(A.cell.percent())]%</td> <td> [chg[A.charging + 1]] </td> </tr>"
				else
					apcs_text += "N/C</td> <td>   </td> </tr>"

			t += "<FONT SIZE=-1><TABLE style='border-collapse: separate; border: 0px solid transparent; border-spacing: 0 0px; width: 100%'>"
			t += apcs_text
			t += "</TABLE></FONT>"

		t += "</TT>"

	var/datum/browser/popup = new(user, "powcomp", "Power Monitoring", 470, 900)
	popup.set_content(t)
	popup.open()


/obj/machinery/computer/monitor/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if( href_list["update"] )
		updateDialog()
		return

	if(href_list["change_meter_rate"])
		var/meter_ref = hrefs['meter_ref']
		if(!meter_ref)
			return
		var/obj/machinery/power/meter/M = locate(meter_ref)
		if(!M)
			return

		var/rate = input("Цена за кВт/ч (от 0 до 500)", "[M.credits_per_kwh]") as num|null
		rate = round(clamp(rate, 0, 500))

		M.credits_per_kwh = rate

		updateDialog()
		return
