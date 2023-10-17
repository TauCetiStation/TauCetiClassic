/obj/machinery/syndicate_tele_station
	name = "suspicious teleporter station"
	desc = "It's the station thingy of a teleport thingy used by Syndicate."
	icon_state = "controller"
	anchored = TRUE
	density = TRUE

/obj/machinery/syndicate_tele_station/attack_hand(mob/user)
	. = ..()
	for(var/obj/machinery/syndicate_tele_hub/H in range(1, src))
		H.toggle(user)

/obj/machinery/syndicate_tele_hub
	name = "suspicious teleporter hub"
	desc = "It's the hub of a teleporting machine, glowing ominous red."
	icon_state = "tele0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000
	var/engaged = FALSE
	var/obj/machinery/syndicate_tele_station/S
	anchored = TRUE
	density = TRUE

/obj/machinery/syndicate_tele_hub/proc/toggle(mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	engaged = !engaged
	use_power(5000)
	visible_message("<span class='notice'>Teleporter [engaged ? "" : "dis"]engaged!</span>")
	update_icon()
	add_fingerprint(user)

/obj/machinery/syndicate_tele_hub/update_icon()
	if(engaged)
		icon_state = "tele-s"
	else
		icon_state = "tele0"

/obj/machinery/syndicate_tele_hub/Bumped(M)
	if(engaged)
		teleport(M)

/obj/machinery/syndicate_tele_hub/proc/teleport(atom/movable/M)
	var/turf/T = pick(landmarks_list["carpspawn"])
	if(istype(M, /atom/movable))
		do_teleport(M, T)
