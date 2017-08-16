/obj/machinery/portable_atmospherics/scrubber
	name = "Portable Air Scrubber"

	icon = 'icons/obj/atmos.dmi'
	icon_state = "pscrubber:0"
	density = 1

	var/on = 0
	var/volume_rate = 800

	volume = 750

	var/minrate = 0
	var/maxrate = 10 * ONE_ATMOSPHERE

	var/list/scrubbing_gas = list("phoron", "carbon_dioxide", "sleeping_agent")

/obj/machinery/portable_atmospherics/scrubber/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(prob(50/severity))
		on = !on
		update_icon()

	..(severity)

/obj/machinery/portable_atmospherics/scrubber/update_icon()
	src.overlays = 0

	if(on)
		icon_state = "pscrubber:1"
	else
		icon_state = "pscrubber:0"

	if(holding)
		overlays += "scrubber-open"

	if(connected_port)
		overlays += "scrubber-connector"

	return

/obj/machinery/portable_atmospherics/scrubber/process()
	..()

	//var/power_draw = -1

	if(on)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()

		var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles

		scrub_gas(src, scrubbing_gas, environment, air_contents, transfer_moles, 7500)

	//src.update_icon()
	src.updateDialog()

/obj/machinery/portable_atmospherics/scrubber/attack_ai(mob/user)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_hand(mob/user)

	user.set_machine(src)
	var/holding_text

	if(holding)
		holding_text = {"<BR><B>Tank Pressure</B>: [holding.air_contents.return_pressure()] KPa<BR>
<A href='?src=\ref[src];remove_tank=1'>Remove Tank</A><BR>
"}
	var/output_text = {"<TT><B>[name]</B><BR>
Pressure: [air_contents.return_pressure()] KPa<BR>
Port Status: [(connected_port)?("Connected"):("Disconnected")]
[holding_text]
<BR>
Power Switch: <A href='?src=\ref[src];power=1'>[on?("On"):("Off")]</A><BR>
Power regulator: <A href='?src=\ref[src];volume_adj=-1000'>-</A> <A href='?src=\ref[src];volume_adj=-100'>-</A> <A href='?src=\ref[src];volume_adj=-10'>-</A> <A href='?src=\ref[src];volume_adj=-1'>-</A> [volume_rate] <A href='?src=\ref[src];volume_adj=1'>+</A> <A href='?src=\ref[src];volume_adj=10'>+</A> <A href='?src=\ref[src];volume_adj=100'>+</A> <A href='?src=\ref[src];volume_adj=1000'>+</A><BR>

<HR>
<A href='?src=\ref[user];mach_close=scrubber'>Close</A><BR>
"}

	user << browse(output_text, "window=scrubber;size=600x300")
	onclose(user, "scrubber")
	return

/obj/machinery/portable_atmospherics/scrubber/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["power"])
		on = !on
	else if (href_list["remove_tank"])
		if(holding)
			holding.forceMove(loc)
			holding = null
	else if (href_list["volume_adj"])
		var/diff = text2num(href_list["volume_adj"])
		volume_rate = Clamp(volume_rate+diff, minrate, maxrate)

	updateUsrDialog()
	update_icon()

//Huge scrubber
/obj/machinery/portable_atmospherics/scrubber/huge
	name = "Huge Air Scrubber"
	icon_state = "scrubber:0"
	anchored = 1
	volume = 50000
	volume_rate = 5000

	use_power = 1
	idle_power_usage = 500		//internal circuitry, friction losses and stuff
	active_power_usage = 100000	//100 kW ~ 135 HP

	var/global/gid = 1
	var/id = 0

/obj/machinery/portable_atmospherics/scrubber/huge/New()
	..()

	id = gid
	gid++

	name = "[name] (ID [id])"

/obj/machinery/portable_atmospherics/scrubber/huge/attack_ghost(mob/user)
	return //Do not show anything

/obj/machinery/portable_atmospherics/scrubber/huge/attack_hand(mob/user)
	to_chat(usr, "\blue You can't directly interact with this machine. Use the area atmos computer.")

/obj/machinery/portable_atmospherics/scrubber/huge/update_icon()
	src.overlays = 0

	if(on && !(stat & (NOPOWER|BROKEN)))
		icon_state = "scrubber:1"
	else
		icon_state = "scrubber:0"

/obj/machinery/portable_atmospherics/scrubber/huge/power_change()
	var/old_stat = stat
	..()
	if (old_stat != stat)
		update_icon()

/obj/machinery/portable_atmospherics/scrubber/huge/process()
	if(!on || (stat & (NOPOWER|BROKEN)))
	//	update_use_power(0)
	//	last_flow_rate = 0
	//	last_power_draw = 0
		return 0

	//var/power_draw = -1

	var/datum/gas_mixture/environment = loc.return_air()

	var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles

	scrub_gas(src, scrubbing_gas, environment, air_contents, transfer_moles, 100000)

/obj/machinery/portable_atmospherics/scrubber/huge/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		if(on)
			to_chat(user, "\blue Turn it off first!")
			return

		anchored = !anchored
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		to_chat(user, "\blue You [anchored ? "wrench" : "unwrench"] \the [src].")

		return

	//doesn't hold tanks
	if(istype(W, /obj/item/weapon/tank))
		return

	..()


/obj/machinery/portable_atmospherics/scrubber/huge/stationary
	name = "Stationary Air Scrubber"

/obj/machinery/portable_atmospherics/scrubber/huge/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		to_chat(user, "\blue The bolts are too tight for you to unscrew!")
		return

	..()
