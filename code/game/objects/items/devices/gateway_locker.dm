#define GATEWAY_HACK_TIME 1200 // 2 minutes

/obj/item/device/gateway_locker
	name = "Gateway Locker"
	icon = 'icons/obj/device.dmi'
	icon_state = "recaller"
	item_state = "walkietalkie"
	w_class = 2
	var/obj/machinery/gateway/centerstation/stationgate
	var/used = FALSE
	var/opened = FALSE

/obj/item/device/gateway_locker/New()
	stationgate = locate(/obj/machinery/gateway/centerstation)

/obj/item/device/gateway_locker/attack_self(mob/user)
	if(!stationgate)
		return
	if(used && opened)
		stationgate.blocked = !stationgate.blocked
		to_chat(user, "<span class='warning'>You [stationgate.blocked ? "dis" :""]allowed entering [stationgate]!</span>")
		return
	if(!Challenge)
		if(world.time < SYNDICATE_CHALLENGE_TIMER - GATEWAY_HACK_TIME)
			to_chat(user, "<span class='warning'>You've issued a combat challenge to the station! You've got to give them at least \
		 	[round(((SYNDICATE_CHALLENGE_TIMER - world.time) / 10) / 60)] \
		 	more minutes to allow them to prepare.</span>")
			return
	else
		Challenge.Gateway_hack = TRUE
	var/obj/effect/landmark/syndie_gateway/Syndie_landmark = locate(/obj/effect/landmark/syndie_gateway)
	if(!istype(Syndie_landmark))
		to_chat(user,"<span class='danger'>Someone already perform hack process</span>")
		return
	used = TRUE
	var/turf/turf = Syndie_landmark.loc
	qdel(Syndie_landmark)
	if(Challenge)
		Challenge.Gateway_hack = TRUE
	addtimer(CALLBACK(src, .proc/perform_gate, turf), GATEWAY_HACK_TIME)

	stationgate.hacked = TRUE
	stationgate.update_icon()
	stationgate.detect()
	for(var/obj/machinery/gateway/G in stationgate.linked)
		G.hacked = TRUE
		G.update_icon()

	command_alert("Unregistered logon in the System in Progress.", "NanoTrasen Gateway Message System")
	player_list << sound('sound/misc/notice1.ogg')

/obj/item/device/gateway_locker/proc/perform_gate(turf/turf)
	new /obj/effect/effect/sparks(turf)
	var/obj/machinery/gateway/centeraway/Gate = new(turf)
	Gate.detect()
	for(var/obj/machinery/gateway/G in Gate.linked)
		G.hacked = TRUE
		G.update_icon()
	Gate.hacked = TRUE
	Gate.update_icon()
	Gate.stationgate = stationgate
	stationgate.awaygate = Gate
	Gate.stationgate.wait = 0
	opened = TRUE
	command_alert("Access was granted, It's Nice day to die, Crew.", "NanoTrasen Gateway Message System")
	player_list << sound('sound/misc/notice1.ogg')

/obj/effect/landmark/syndie_gateway

#undef GATEWAY_HACK_TIME