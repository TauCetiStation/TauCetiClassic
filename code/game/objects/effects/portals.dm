/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = TRUE
	unacidable = TRUE // Can't destroy energy portals.
	var/failchance = 5
	var/obj/item/target = null
	var/creator = null
	anchored = TRUE
	var/portal_density_check = TELE_CHECK_NONE
	var/portal_respect_dir = FALSE
	var/portal_use_forceMove = TRUE

/obj/effect/portal/atom_init(mapload, turf/target, creator = null, lifespan = 300)
	. = ..()
	portal_list += src

	src.target = target
	src.creator = creator

	if(lifespan > 0)
		QDEL_IN(src, lifespan)

/obj/effect/portal/attack_ghost(mob/user)
	. = ..()
	if(target)
		user.abstract_move(target)

/obj/effect/portal/Destroy()
	portal_list -= src
	creator = null
	target = null
	return ..()

/obj/effect/portal/Bumped(mob/M)
	INVOKE_ASYNC(src, PROC_REF(teleport), M)

/obj/effect/portal/Crossed(atom/movable/AM)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(teleport), AM)

/obj/effect/portal/proc/can_teleport(atom/movable/M)
	if(istype(M, /obj/effect)) //sparks don't teleport
		return FALSE
	if(M.anchored && istype(M, /obj/mecha))
		return FALSE
	if(icon_state == "portal1")
		return FALSE
	return TRUE

/obj/effect/portal/proc/teleport(atom/movable/M, density_check = TELE_CHECK_NONE, respect_entrydir = FALSE, use_forceMove = TRUE)
	if(!can_teleport(M))
		return FALSE
	if(!target)
		qdel(src)
		return FALSE
	density_check = portal_density_check
	respect_entrydir = portal_respect_dir
	use_forceMove = portal_use_forceMove
	if(istype(M, /atom/movable))
		if(prob(failchance)) //oh dear a problem, put em in deep space
			src.icon_state = "portal1"
			return do_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy - 5), 3), 0, use_forceMove, arespect_entrydir = respect_entrydir, aentrydir = get_dir(M, src))
		else
			return do_teleport(M, target, 1, use_forceMove, arespect_entrydir = respect_entrydir, aentrydir = get_dir(M, src))


/obj/effect/portal/rift
	name = "rift"
	desc = "Red portal fumming with iron taste. Best to test it with the clown. Twice."
	icon = 'icons/obj/cult.dmi'
	icon_state = "portal"
	failchance = 1 //Unfair, but honk never ends
	anchored = TRUE
	var/_lifespan = 8 SECONDS
	var/obj/effect/portal/rift/linked_portal = null

/obj/effect/portal/rift/atom_init(mapload, turf/target, creator, lifespan = _lifespan)
	. = ..()
	//RegisterSignal(src, COMSIG_PARENT_QDELETING, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), linked_portal))
	if(target)
		linked_portal = new(target, get_turf(src), null, 0)
		linked_portal.linked_portal = src
		target = linked_portal
		linked_portal.target = src
	//RegisterSignal(linked_portal, COMSIG_PARENT_QDELETING, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src))

/obj/effect/portal/rift/Destroy()
	. = ..()
	if(linked_portal)
		linked_portal = null
		qdel(linked_portal)

/obj/effect/portal/rift/examine(mob/user)
	. = ..()
	if(iscultist(user) || isobserver(user))
		to_chat(user, "<span class=`warning`>Разлом. Не стоит допускать, что бы какой-то еретик смог проникнуть через него в святыню! Этот портал [_lifespan ? "нестабилен, а значит в скором времени должен закрыться" : "стабилен, а значит закрыт не будет"]!</span>")

/obj/effect/portal/rift/can_teleport(atom/movable/M)
	. = ..()
	if(!ismob(M))
		return FALSE

/obj/effect/portal/rift/teleport(mob/living/user, density_check = TELE_CHECK_NONE, respect_entrydir = FALSE, use_forceMove = TRUE)
	if(!can_teleport(user))
		return FALSE
	if(!iscultist(user))
		if(!do_after(user, 5 SECONDS, FALSE, src))
			return FALSE
		if(prob(failchance)) //Narsie defence 2000
			return do_teleport(user, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), 3), 0, use_forceMove, portal_respect_dir, aentrydir = get_dir(user, src))
		cult_religion.send_message_to_members("Еретик [user.real_name] проник в Рай!", null, 4, user)
		notify_ghosts("Еретик в Раю!", source=user, action=NOTIFY_ORBIT, header="Intruder")
		for(var/mob/M in servants_and_ghosts())
			playsound(M, 'sound/antag/eminence_command.ogg', VOL_EFFECTS_MASTER)

	playsound(user, 'sound/magic/Teleport_diss.ogg', VOL_EFFECTS_MASTER)
	new /obj/effect/temp_visual/cult/blood/out(user.loc)

	if(!target)
		var/area/A = locate(cult_religion.area_type)
		target = get_turf(pick(A.contents))
	user.forceMove(target)
	user.eject_from_wall(gib = FALSE)

	playsound(user, 'sound/magic/Teleport_app.ogg', VOL_EFFECTS_MASTER)
	new /obj/effect/temp_visual/cult/blood(get_turf(target))
	if(user.client)
		new /atom/movable/screen/temp/cult_teleportation(user, user)

/obj/effect/portal/rift/stable
	_lifespan = 0
	var/obj/effect/anomaly/bluespace/cult_portal/P

/obj/effect/portal/rift/stable/atom_init(mapload, turf/target, creator, lifespan = 0)
	. = ..()
	START_PROCESSING(SSreligion, src)
	var/datum/announcement/centcomm/narsie_summon/A = new(src) //lil overkill, but its still a portal, right?
	A.play()

	cult_religion.send_message_to_members("Создан новый стабильный Разлом в [CASE((get_area(src)), PREPOSITIONAL_CASE)]!", null, 4, src)
	notify_ghosts("Создан новый стабильный Разлом!", source=src, action=NOTIFY_ORBIT, header="Rift")
	for(var/mob/M in servants_and_ghosts())
		playsound(M, 'sound/antag/eminence_command.ogg', VOL_EFFECTS_MASTER)

	cult_religion.rifts += src
	if(cult_religion.get_tech(RTECH_RIFT_DEFENCES))
		P = new (src, TRUE)

/obj/effect/portal/rift/stable/examine(mob/user)
	. = ..()
	if(P && (isobserver(user) || iscultist(user)))
		to_chat(user, "Является также порталом, откуда падшие души могут выходить в облике конструктов")
		to_chat(user, "Оболочек для будущих рабов осталось: [P.spawns]")

/obj/effect/portal/rift/stable/attack_ghost(mob/user)
	. = ..()
	if(P)
		P.attack_ghost(user)

/obj/effect/portal/rift/stable/process()
	. = ..()
	var/datum/aspect/aspect = cult_religion.aspects[ASPECT_MYSTIC]
	cult_religion.adjust_favor((1 + aspect.power) * 15 )

/obj/effect/portal/rift/stable/Destroy()
	. = ..()
	QDEL_NULL(P)
	cult_religion.rifts -= src

//Telescience wormhole
/obj/effect/portal/tsci_wormhole
	name = "wormhole"
	icon = 'icons/obj/objects.dmi'
	icon_state = "bluespace_wormhole_enter"
	failchance = 0

	var/obj/effect/portal/tsci_wormhole/linked_portal = null
	var/obj/machinery/computer/telescience/linked_console = null

/obj/effect/portal/tsci_wormhole/atom_init(mapload, turf/target, creator = null, lifespan = 0, other_side_portal = FALSE)
	. = ..()
	if(other_side_portal)
		icon_state = "bluespace_wormhole_exit"
	else
		linked_portal = new(target, get_turf(src), null, 0, TRUE)
		linked_portal.linked_portal = src
		target = linked_portal
		linked_portal.target = src

/obj/effect/portal/tsci_wormhole/Destroy()
	target = null
	if(linked_console)
		linked_console.active_wormhole = null
		linked_console.set_power_use(IDLE_POWER_USE)
		linked_console = null
	if(linked_portal)
		playsound(src, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER, 25)
		playsound(linked_portal, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER, 25)
		var/obj/effect/portal/tsci_wormhole/LP = linked_portal
		linked_portal = null
		LP.linked_portal = null
		qdel(LP)
	return ..()

/obj/effect/portal/tsci_wormhole/Bumped(mob/M)
	set waitfor = 0
	if(teleport(M, TELE_CHECK_ALL, TRUE, FALSE))
		handle_special_effects(M)

/obj/effect/portal/tsci_wormhole/Crossed(atom/movable/AM)
	set waitfor = 0

	. = ..()
	if(teleport(AM, TELE_CHECK_ALL, TRUE, FALSE))
		handle_special_effects(AM)

/obj/effect/portal/tsci_wormhole/proc/handle_special_effects(AM)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		var/bad_effects = 0
		if(H.species.flags[IS_SYNTHETIC])
			return

		var/list/stabilizer = H.search_contents_for(/obj/item/rig_module/teleporter_stabilizer)
		for(var/obj/item/rig_module/teleporter_stabilizer/s in stabilizer)
			if (s.stabilize_teleportation())
				return

		if(prob(20))
			bad_effects += 1
			H.AdjustConfused(3)
			var/msg = pick("You feel dizzy.", "Your head starts spinning.")
			to_chat(H, "<span class='warning'>[msg]</span>")
		if(prob(20))
			bad_effects += 1
			H.invoke_vomit_async() //No msg required, since vomit() will handle this.
		if(bad_effects == 2)
			H.Paralyse(3)

/obj/effect/portal/portalgun
	failchance = 0
	portal_density_check = TELE_CHECK_ALL
	portal_respect_dir = TRUE
	portal_use_forceMove = FALSE
