var/const/MUL_WIRE_POWER1    = 1    // power connections
var/const/MUL_WIRE_POWER2    = 2
var/const/MUL_WIRE_AVOIDANCE = 4    // mob avoidance
var/const/MUL_WIRE_LOADCHECK = 8    // load checking (non-crate)
var/const/MUL_WIRE_MOTOR1    = 16   // motor wires
var/const/MUL_WIRE_MOTOR2    = 32
var/const/MUL_WIRE_REMOTE_RX = 64   // remote recv functions
var/const/MUL_WIRE_REMOTE_TX = 128  // remote trans status
var/const/MUL_WIRE_BEACON_RX = 256  // beacon ping recv

/datum/wires/mulebot
	random = TRUE
	holder_type = /obj/machinery/bot/mulebot
	wire_count = 10

/datum/wires/mulebot/can_use()
	var/obj/machinery/bot/mulebot/M = holder
	return M.open

/datum/wires/mulebot/update_pulsed(index)
	switch(index)
		if(MUL_WIRE_POWER1, MUL_WIRE_POWER2)
			holder.visible_message("<span class='notice'>[bicon(holder)] The charge light flickers.</span>")
		if(MUL_WIRE_AVOIDANCE)
			holder.visible_message("<span class='notice'>[bicon(holder)] The external warning lights flash briefly.</span>")
		if(MUL_WIRE_LOADCHECK)
			holder.visible_message("<span class='notice'>[bicon(holder)] The load platform clunks.</span>")
		if(MUL_WIRE_MOTOR1, MUL_WIRE_MOTOR2)
			holder.visible_message("<span class='notice'>[bicon(holder)] The drive motor whines briefly.</span>")
		else
			holder.visible_message("<span class='notice'>[bicon(holder)] You hear a radio crackle.</span>")

/datum/wires/mulebot/proc/motor1()
	return !(wires_status & MUL_WIRE_MOTOR1)

/datum/wires/mulebot/proc/motor2()
	return !(wires_status & MUL_WIRE_MOTOR2)

/datum/wires/mulebot/proc/has_power()
	return !(wires_status & MUL_WIRE_POWER1) && !(wires_status & MUL_WIRE_POWER2)

/datum/wires/mulebot/proc/load_check()
	return !(wires_status & MUL_WIRE_LOADCHECK)

/datum/wires/mulebot/proc/mob_avoid()
	return !(wires_status & MUL_WIRE_AVOIDANCE)

/datum/wires/mulebot/proc/remote_tx()
	return !(wires_status & MUL_WIRE_REMOTE_TX)

/datum/wires/mulebot/proc/remote_rx()
	return !(wires_status & MUL_WIRE_REMOTE_RX)

/datum/wires/mulebot/proc/beacon_rx()
	return !(wires_status & MUL_WIRE_BEACON_RX)