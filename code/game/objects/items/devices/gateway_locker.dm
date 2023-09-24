#define GATEWAY_HACK_TIME 800 // 1.5 minutes

/obj/item/device/gateway_locker
	name = "Gateway Locker"
	icon = 'icons/obj/device.dmi'
	icon_state = "recaller"
	item_state = "walkietalkie"
	w_class = SIZE_TINY
	var/obj/machinery/gateway/center/stationgate
	var/used = FALSE
	var/opened = FALSE

/obj/item/device/gateway_locker/atom_init()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/device/gateway_locker/atom_init_late()
	stationgate = locate(/obj/machinery/gateway/center/station)

/obj/item/device/gateway_locker/attack_self(mob/user)
	if(!stationgate)
		return
	playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
	if(used && opened)
		stationgate.blocked = !stationgate.blocked
		to_chat(user, "<span class='warning'>You [stationgate.blocked ? "dis" :""]allowed entering [stationgate]!</span>")
		return
	if(war_device_activated)
		if(world.time < SYNDICATE_CHALLENGE_TIMER - GATEWAY_HACK_TIME)
			to_chat(user, "<span class='warning'>You've issued a combat challenge to the station! You've got to give them at least \
		 	[round(((SYNDICATE_CHALLENGE_TIMER - GATEWAY_HACK_TIME - world.time) / 10) / 60)] \
		 	more minutes to allow them to prepare.</span>")
			return
	else
		war_device_activation_forbidden = TRUE
	var/obj/effect/landmark/syndie_gateway/Syndie_landmark = locate("landmark*Syndie gateway")
	if(QDELETED(Syndie_landmark))
		to_chat(user,"<span class='danger'>You already perform hack process</span>")
		return
	used = TRUE
	var/turf/turf = Syndie_landmark.loc
	qdel(Syndie_landmark)
	addtimer(CALLBACK(src, PROC_REF(perform_gate), turf), GATEWAY_HACK_TIME)

/obj/item/device/gateway_locker/proc/perform_gate(turf/turf)
	new /obj/effect/effect/sparks(turf)
	var/obj/machinery/gateway/center/Gate = new(turf)
	Gate.detect()
	for(var/obj/machinery/gateway/G in Gate.linked)
		G.hacked = TRUE
		G.update_icon()
	Gate.hacked = TRUE
	Gate.update_icon()
	Gate.destination = stationgate
	stationgate.destination = Gate

	stationgate.hacked = TRUE
	stationgate.update_icon()
	stationgate.detect()
	for(var/obj/machinery/gateway/G in stationgate.linked)
		G.hacked = TRUE
		G.update_icon()
	opened = TRUE
	var/datum/announcement/centcomm/nuclear/gateway/announce = new
	announce.play()
	playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
	//mix stuff
	var/datum/faction/nuclear/crossfire/N = find_faction_by_type(/datum/faction/nuclear/crossfire)
	if(N)
		N.landing_nuke()

/obj/effect/landmark/syndie_gateway
	name = "Syndie gateway"

#undef GATEWAY_HACK_TIME
