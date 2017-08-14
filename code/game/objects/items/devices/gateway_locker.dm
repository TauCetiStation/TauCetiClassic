/obj/item/device/gateway_locker
	name = "Gateway Locker"
	icon = 'icons/obj/device.dmi'
	icon_state = "recaller"
	item_state = "walkietalkie"
	w_class = 2
	var/obj/machinery/gateway/centerstation/stationgate
	var/used = FALSE

/obj/item/device/gateway_locker/New()
	stationgate = locate(/obj/machinery/gateway/centerstation)

/obj/item/device/gateway_locker/attack_self(mob/user)
	if(!stationgate)
		return
	playsound(loc, 'sound/machines/twobeep.ogg', 50, 2)
	if(used)
		stationgate.blocked = !stationgate.blocked
		to_chat(user, "<span class='warning'>You [stationgate.blocked ? "dis" :""]allowed entering [stationgate]!</span>")
		return
	if(!Challenge)
		if(world.time < SYNDICATE_CHALLENGE_TIMER)
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
	stationgate.hacked = TRUE
	stationgate.update_icon()
	stationgate.detect()
	for(var/obj/machinery/gateway/G in stationgate.linked)
		G.hacked = TRUE
		G.update_icon()

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

/obj/effect/landmark/syndie_gateway

#undef GATEWAY_HACK_TIME