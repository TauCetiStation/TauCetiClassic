#define ADVANCED_AIMING_INSTALLED 1
#define STATE_AIMING 2
#define STATE_DROPING 4
#define IS_LEGITIMATE 8
#define IS_LOCKED 16
#define POOR_AIMING 32

/obj/structure/droppod
	name = "Drop Pod"
	desc = "We are coming. Look to the skies for your salvation."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	anchored = 1
	density = 1
	opacity = 1
	bound_height = 64
	icon = 'icons/obj/structures/droppod.dmi'
	icon_state = "dropod_opened"
	var/item_state = null

	var/max_integrity = 100
	var/obj_integrity = 100

	var/mob/living/carbon/intruder
	var/mob/living/second_intruder
	var/mob/camera/Eye/drop/eyeobj

	var/turf/AimTarget
	var/uses = 1
	var/stored_dna
	var/obj/machinery/nuclearbomb/Stored_Nuclear
	var/list/stored_items = list()

	var/static/datum/droppod_allowed/allowed_areas

	var/static/initial_eyeobj_location = null
	var/image/mob_overlay

/obj/structure/droppod/atom_init()
	. = ..()
	if(!initial_eyeobj_location)
		initial_eyeobj_location = locate(/obj/effect/landmark/droppod) in landmarks_list
	if(!allowed_areas)
		allowed_areas = new

/obj/structure/droppod/Destroy()
	var/turf/turf = get_turf(loc)
	if(flags & ADVANCED_AIMING_INSTALLED && prob(50))
		new /obj/item/device/camera_bug(loc)
	CancelAdvancedAiming(1) // just to be sure
	if(intruder)
		cut_overlay(mob_overlay)
		QDEL_NULL(mob_overlay)
		intruder << browse(null, "window=droppod")
		intruder.forceMove(turf)
		intruder = null
	if(second_intruder)
		second_intruder.forceMove(turf)
		second_intruder = null
	cut_overlays()
	if(Stored_Nuclear)
		Stored_Nuclear.forceMove(turf)
		Stored_Nuclear = null
	for(var/obj/item/X in stored_items)
		X.forceMove(turf)
	stored_items.Cut()
	new /obj/effect/decal/droppod_wreckage(turf, item_state)
	return ..()

/obj/structure/droppod/ex_act()
	if(flags & STATE_DROPING)
		return
	return ..()

/obj/structure/droppod/blob_act()
	if(flags & STATE_DROPING)
		return
	return ..()

/********Moving camera Eye********/

/obj/structure/droppod/relaymove(mob/user, direction)
	if(eyeobj && user == intruder)
		eyeobj.setLoc(get_turf(get_step(eyeobj, direction)))
	else if(user == second_intruder)
		Eject_second()

/mob/camera/Eye/drop
	alpha = 200
	icon = 'icons/obj/structures/droppod.dmi'
	icon_state = "old_dropcursor"

/********Datum helper with restricted and allowed areas for droping********/

/datum/droppod_allowed
	var/static/list/areas
	var/static/list/black_list_areas

/datum/droppod_allowed/New()
	..()
	if(!black_list_areas)
		black_list_areas = list(
			/area/station/aisat,
			/area/station/aisat/antechamber,
			/area/station/aisat/ai_chamber,
			/area/station/bridge/ai_upload,
			/area/station/aisat/antechamber_interior,
			/area/station/ai_monitored/storage_secure,
			/area/station/tcommsat/computer,
			/area/station/tcommsat/chamber,
			/area/station/aisat/teleport,
			/area/station/bridge/captain_quarters,
			/area/station/bridge/hop_office,
			/area/station/bridge,
			/area/station/bridge/meeting_room,
			/area/station/bridge/teleporter,
			/area/station/bridge/nuke_storage,
			/area/station/security/armoury,
			/area/station/security/warden,
			/area/station/security/main,
			/area/station/security/brig,
			/area/station/security/range,
			/area/station/security/hos,
			/area/station/security/prison,
			/area/station/security/execution,
			/area/station/security/forensic_office,
			/area/station/security/detectives_office,
			/area/station/bridge/server,
			/area/station/bridge/comms
			)
	if(!areas)
		areas = teleportlocs.Copy()
		for(var/i in areas)
			if(is_type_in_list(areas[i], black_list_areas))
				areas -= i

/obj/effect/landmark/droppod

/********Move in and out********/

/obj/structure/droppod/verb/move_inside()
	set category = "Drop Pod"
	set name = "Enter Drop Pod"
	set src in orange(1)

	if(!(ishuman(usr) || isrobot(usr)) || usr == second_intruder || usr.incapacitated())
		return
	if(stored_dna)
		var/passed = FALSE
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if(stored_dna == H.dna.unique_enzymes)
				passed = TRUE
		if(!passed)
			to_chat(usr, "<span class='warning'>The interface is blocked down with Dna key!</span>")
			return
	if (usr.buckled)
		to_chat(usr, "<span class='warning'>You can't climb into the [src] while buckled!</span>")
		return
	if(intruder)
		to_chat(usr, "<span class='userdanger'>Someone already inside here!</span>")
		return
	if(usr.is_busy()) return
	if(do_after(usr, 10, 1, src) && !intruder && !usr.buckled && usr != second_intruder)
		usr.forceMove(src)
		mob_overlay = image(usr.icon, usr.icon_state)
		mob_overlay.copy_overlays(usr)
		mob_overlay.pixel_x = 1
		mob_overlay.pixel_y = 25
		add_overlay(mob_overlay)
		intruder = usr
		verbs -= /obj/structure/droppod/verb/move_inside
	return

/obj/structure/droppod/proc/Eject()
	if(flags & STATE_DROPING)
		to_chat(intruder, "<span class='danger'>You cannot leave the pod while Droping!</span>")
		return
	if(flags & IS_LOCKED)
		to_chat(intruder, "<span class='danger'>Unlock Pod first!</span>")
		return
	intruder << browse(null, "window=droppod")
	CancelAdvancedAiming() // just to be sure
	cut_overlay(mob_overlay)
	QDEL_NULL(mob_overlay)
	icon_state = Stored_Nuclear ? "dropod_opened_n" : "dropod_opened"
	if(item_state)
		icon_state += item_state
	intruder.forceMove(get_turf(loc))
	intruder = null
	verbs += /obj/structure/droppod/verb/move_inside

/obj/structure/droppod/verb/move_inside_second()
	set category = "Drop Pod"
	set name = "Enter Drop Pod as Passenger"
	set src in orange(1)
	if(!(ishuman(usr) || isrobot(usr)) || usr == intruder || usr.incapacitated())
		return
	if (usr.buckled)
		to_chat(usr, "<span class='warning'>You can't climb into the [src] while buckled!</span>")
		return
	if(flags & IS_LOCKED)
		to_chat(usr, "<span class='userdanger'>[src] is lock down!</span>")
		return
	if(usr.is_busy()) return
	if(do_after(usr, 10, 1, src) && !second_intruder && !usr.buckled && !(flags & IS_LOCKED) && !(flags & STATE_DROPING) && usr != intruder)
		usr.forceMove(src)
		second_intruder = usr
		verbs -= /obj/structure/droppod/verb/move_inside_second

/obj/structure/droppod/proc/Eject_second()
	if(flags & STATE_DROPING)
		to_chat(usr, "<span class='danger'>You cannot leave the pod while Droping!</span>")
		return
	if(flags & IS_LOCKED)
		to_chat(usr, "<span class='danger'>Unlock Pod first!</span>")
		return
	second_intruder.forceMove(get_turf(src))
	second_intruder = null
	verbs += /obj/structure/droppod/verb/move_inside_second



/********Aiming********/

/obj/structure/droppod/proc/Aiming()
	if(flags & STATE_DROPING || !isturf(loc))
		return
	if(flags & POOR_AIMING)
		poor_aiming_n_drop()
	else if(flags & ADVANCED_AIMING_INSTALLED)
		if(flags & STATE_AIMING)
			CancelAdvancedAiming()
		else
			StartAdvancedAiming()
	else if(!(flags & STATE_AIMING))
		SimpleAiming()

/obj/structure/droppod/proc/poor_aiming_n_drop() // used in Syndi Pod
	if(!(flags & IS_LOCKED))
		to_chat(intruder, "<span class='userdanger'>Close [src] First!</span>")
		return
	if(!isturf(loc))
		to_chat(intruder, "<span class='userdanger'>You must be on ground to drop!</span>")
		return
	if(war_device_activated)
		if(world.time < SYNDICATE_CHALLENGE_TIMER)
			to_chat(intruder, "<span class='warning'>You've issued a combat challenge to the station! You've got to give them at least \
		 	[round(((SYNDICATE_CHALLENGE_TIMER - world.time) / 10) / 60)] \
		 	more minutes to allow them to prepare.</span>")
			return
	else
		war_device_activation_forbidden = TRUE
	var/area/area_to_deploy = allowed_areas.areas[pick(allowed_areas.areas)]
	var/list/L = list()
	for(var/turf/T in get_area_turfs(area_to_deploy.type))
		if(!T.density && !istype(T, /turf/space) && !T.obscured)
			L+=T
	if(isemptylist(L))
		to_chat(intruder, "<span class='notice'>Automatic Aim System cannot find an appropriate target!</span>")
		return
	AimTarget = pick(L)
	StartDrop()

/obj/structure/droppod/proc/SimpleAiming()
	flags |= STATE_AIMING
	var/A
	A = input("Select Area for Droping Pod", "Select", A) in allowed_areas.areas
	var/area/thearea = allowed_areas.areas[A]
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density && !istype(T, /turf/space) && !T.obscured)
			L+=T
	flags &= ~STATE_AIMING
	if(isemptylist(L))
		to_chat(intruder, "<span class='notice'>Automatic Aim System cannot find an appropriate target!</span>")
		return
	to_chat(intruder, "<span class='notice'>You succesfully [AimTarget ? "re" : ""]selected target!</span>")
	AimTarget = pick(L)

/obj/structure/droppod/proc/StartAdvancedAiming()
	flags |= STATE_AIMING
	eyeobj = new((initial_eyeobj_location ? initial_eyeobj_location : loc))

	intruder.client.adminobs = TRUE
	eyeobj.master = intruder
	eyeobj.name = "[intruder.name] (Eye)"
	intruder.client.images += eyeobj.ghostimage
	intruder.client.eye = eyeobj

/obj/structure/droppod/proc/ChooseTarget()
	if(!eyeobj || is_centcom_level(eyeobj.z))
		return
	var/turf/teleport_turf = get_turf(eyeobj.loc)
	if(teleport_turf.obscured)
		to_chat(intruder, "<span class='userdanger'>No signal here! It might be unsafe to deploy here!</span>")
		return
	if(!(flags & IS_LEGITIMATE) && is_type_in_list(teleport_turf.loc, allowed_areas.black_list_areas))
		to_chat(intruder, "<span class='userdanger'>This location has got a Muffler!</span>")
		return
	to_chat(intruder, "<span class='notice'>You succesfully [AimTarget ? "re" : ""]selected target!</span>")
	AimTarget = teleport_turf


/obj/structure/droppod/proc/CancelAdvancedAiming(deleting = 0)
	QDEL_NULL(eyeobj)
	if(intruder && intruder.client)
		for(var/image/I in intruder.client.images)
			if(I.icon_state == "black") // deleting interferences
				intruder.client.images -= I
		intruder.client.adminobs = FALSE
		intruder.reset_view(deleting ? loc : src)
	flags &= ~STATE_AIMING

/********Droping********/

/obj/structure/droppod/verb/Start_Verb()
	set category = "Drop Pod"
	set name = "Start Drop"
	set src = orange(1)
	if(!(ishuman(usr) || isrobot(usr)) || usr.incapacitated() || !isturf(loc))
		return FALSE
	if(intruder)
		if(intruder != usr)
			to_chat(usr, "<span class ='notice'>Someone in [src]</span>")
			return FALSE
		if(!(flags & IS_LOCKED))
			to_chat(usr, "<span class='userdanger'>Close [src] First!</span>")
			return FALSE
	else if(stored_dna)
		var/passed = FALSE
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			if(stored_dna == H.dna.unique_enzymes)
				passed = TRUE
		if(!passed)
			to_chat(usr, "<span class='warning'>The interface is blocked down with Dna key!</span>")
			return FALSE

	if(!AimTarget)
		to_chat(usr, "<span class='userdanger'>No target selected!</span>")
		return FALSE
	if(flags & STATE_AIMING)
		to_chat(usr, "<span class='userdanger'>You cannot drop while aim system in progress!</span>")
		return FALSE
	if(!isturf(loc))
		to_chat(usr, "<span class='userdanger'>You must be on ground to drop!</span>")
		return FALSE
	StartDrop()

/obj/structure/droppod/proc/StartDrop()
	verbs -= /obj/structure/droppod/verb/Start_Verb
	playsound(src, 'sound/effects/drop_start.ogg', VOL_EFFECTS_MASTER)
	flags |= STATE_DROPING
	density = FALSE
	opacity = FALSE
	icon_state = "dropod_flying[item_state]"
	var/initial_x = pixel_x
	var/initial_y = pixel_y
	animate(src, pixel_y = 500, pixel_x = rand(-150, 150), time = 20, easing = SINE_EASING)
	sleep(25)
	loc = AimTarget
	sleep(10)
	animate(src, pixel_y = initial_y, pixel_x = initial_x, time = 20, easing = CUBIC_EASING)
	addtimer(CALLBACK(src, .proc/perform_drop), 20)

/obj/structure/droppod/proc/perform_drop()
	for(var/atom/movable/T in loc)
		if(T != src && !(istype(T, /obj/structure/window) || istype(T, /obj/machinery/door/airlock) || istype(T, /obj/machinery/door/poddoor)))
			T.ex_act(1)
	for(var/mob/living/M in oviewers(6, src))
		shake_camera(M, 2, 2)
	for(var/turf/simulated/floor/T in RANGE_TURFS(1, src))
		T.break_tile_to_plating()
	playsound(src, 'sound/effects/drop_land.ogg', VOL_EFFECTS_MASTER)
	density = TRUE
	opacity = TRUE
	AimTarget = null
	uses--
	icon_state = Stored_Nuclear ? "dropod_opened_n" : "dropod_opened"
	if(item_state)
		icon_state += item_state
	cut_overlay(image(icon, "drop_panel[item_state]", "layer" = initial(layer) + 0.3))
	new /obj/effect/overlay/droppod_open(loc, item_state)
	sleep(50)
	if(uses <= 0)
		qdel(src)
	else
		flags &= ~(STATE_DROPING | IS_LOCKED)
		verbs += /obj/structure/droppod/verb/Start_Verb

/********Actions with objects********/

/obj/structure/droppod/attackby(obj/item/O, mob/living/carbon/user)
	if(flags & IS_LOCKED)
		to_chat(user, "<span class ='userdanger'>[src] is lock down!</span>")
		return

	if(isscrewdriver(O))
		if(flags & ADVANCED_AIMING_INSTALLED)
			if(flags & STATE_AIMING)
				CancelAdvancedAiming()
			to_chat(user, "<span class ='notice'>You yank out advanced aim system from [src]!</span>")
			new /obj/item/device/camera_bug(user.loc)
			flags &= ~ADVANCED_AIMING_INSTALLED
			AimTarget = null
		else
			to_chat(user, "<span class ='notice'>Advanced aiming system does not installed in [src]!</span>")

	else if(iswelder(O))
		var/obj/item/weapon/weldingtool/WT = O
		user.SetNextMove(CLICK_CD_MELEE)
		if(obj_integrity < max_integrity && WT.use(0, user))
			playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)
			obj_integrity = min(obj_integrity + 10, max_integrity)
			visible_message("<span class='notice'>[user] has repaired some dents on [src]!</span>")

	else if(user.a_intent == INTENT_HARM || (O.flags & ABSTRACT))
		playsound(src, 'sound/weapons/smash.ogg', VOL_EFFECTS_MASTER)
		user.SetNextMove(CLICK_CD_MELEE)
		take_damage(O.force)
		return ..()

	else
		if(istype(O, /obj/item/weapon/simple_drop_system))
			if(!(flags & POOR_AIMING))
				to_chat(user, "<span class ='notice'>The [src] already has simple aiming system installed!</span>")
				return
			flags &= ~POOR_AIMING
			to_chat(user, "<span class ='notice'>You upgrade [src]'s Guidance system with [O]!</span>")
			qdel(O)
		else if(istype(O, /obj/item/device/camera_bug))
			if(flags & ADVANCED_AIMING_INSTALLED)
				to_chat(user, "<span class ='notice'>The [src] already has advanced aiming system installed!</span>")
				return
			flags |= ADVANCED_AIMING_INSTALLED
			to_chat(user, "<span class ='notice'>You upgrade [src]'s Guidance system with [O], Now it has astonishing accuracy!</span>")
			qdel(O)
		else if(length(stored_items) < 7)
			if(issilicon(user))
				return
			if(stored_items.len == 1)
				verbs += /obj/structure/droppod/proc/Eject_items_cmd
			user.drop_from_inventory(O)
			O.forceMove(src)
			stored_items += O
			to_chat(user, "<span class ='notice'>You put [O] at [src]</span>")
		else
			to_chat(user, "<span class ='danger'>When you tried to shove an [O], the [src] spat it out!</span>")

/obj/structure/droppod/proc/Eject_items_cmd()
	set category = "Drop Pod"
	set name = "Eject Items"
	set src in orange(1)
	if(!(ishuman(usr) || isrobot(usr))|| usr.incapacitated() || flags & STATE_DROPING || !isturf(loc))
		return
	if(flags & IS_LOCKED)
		to_chat(usr, "<span class='danger'>Interface is block down!</span>")
		return
	Eject_items()
	visible_message("<span class='warning'> [usr] has ejected items from [src]!</span>","<span class='warning'>You ejected items from [src] </span>")

/obj/structure/droppod/proc/Eject_items()
	var/turf/turf = get_turf(loc)
	for(var/obj/item/X in stored_items)
		X.forceMove(turf)
		stored_items -= X
	verbs -= /obj/structure/droppod/proc/Eject_items_cmd

/obj/structure/droppod/proc/Nuclear()
	set category = "Drop Pod"
	set name = "Nuclear Bomb"
	set src in orange(1)
	if(!(ishuman(usr) || isrobot(usr))|| usr.incapacitated() || flags & STATE_DROPING || !Stored_Nuclear)
		return
	if(usr.is_busy()) return
	visible_message("<span class='notice'>[usr] start ejecting [Stored_Nuclear] from [src]!</span>","<span class='notice'>You start ejecting [Stored_Nuclear] from [src]!</span>")
	if(do_after(usr, 100, 1, src) && in_range(usr, src) && Stored_Nuclear)
		EjectNuclear()

/obj/structure/droppod/proc/EjectNuclear()
	visible_message("<span class='notice'>[Stored_Nuclear] has been ejected from [src]!</span>")
	Stored_Nuclear.forceMove(get_turf(loc))
	icon_state = "dropod_opened[item_state]"
	Stored_Nuclear = null
	verbs -= /obj/structure/droppod/proc/Nuclear

/********Damage system********/

/obj/structure/droppod/bullet_act(obj/item/projectile/Proj)
	if((Proj.damage && Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='danger'>[src] was hit by [Proj].</span>")
		take_damage(Proj.damage)
		if(!(flags & IS_LOCKED))
			if(intruder && prob(60))
				intruder.bullet_act(Proj)
			if(second_intruder && prob(40))
				second_intruder.bullet_act(Proj)

/obj/structure/droppod/proc/take_damage(amount)
	obj_integrity -= amount / 2
	if(obj_integrity <= 0)
		visible_message("<span class='warning'>The [src] has been destroyed!</span>")
		qdel(src)

/obj/structure/droppod/attack_animal(mob/living/simple_animal/attacker)
	..()
	playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER)
	take_damage(attacker.melee_damage)

/********Stats********/

/obj/structure/droppod/verb/view_stats()
	set name = "Drop Pod Interface"
	set category = "Drop Pod"
	set src = usr.loc
	set popup_menu = 0
	if(usr != intruder)
		return
	intruder << browse(get_stats_html(), "window=droppod")
	return

/obj/structure/droppod/proc/get_stats_html()
	var/output = {"<html>
				<head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'><title>[name] data</title>
				<style>
				body {color: #00ff00; background: #000000; font-family:"Lucida Console",monospace; font-size: 12px;}
				hr {border: 1px solid #0f0; color: #0f0; background-color: #0f0;}
				a {padding:2px 5px;;color:#0f0;}
				.wr {margin-bottom: 5px;}
				.header {cursor:pointer;}
				.open, .closed {background: #32CD32; color:#000; padding:1px 2px;}
				.links a {margin-bottom: 2px;padding-top:3px;}
				.visible {display: block;}
				.hidden {display: none;}
				</style>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				[js_dropdowns]
				function ticker() {
				    setInterval(function(){
				        window.location='byond://?src=\ref[src]&update_content=1';
				    }, 1000);
				}

				window.onload = function() {
					dropdowns();
					ticker();
				}
				</script>
				</head>
				<body>
				<div id='content'>
				[get_stat()]
				</div>
				<div id='commands'>
				[get_commands()]
				</div>
				<hr>
				<div id='eq_list'>
				[get_stored_items_list()]
				</div>
				</body>
				</html>
			 "}
	return output


/obj/structure/droppod/proc/get_stored_items_list()
	if(!stored_items.len)
		return
	var/output = "<b>Stored Items:</b><div style=\"margin-left: 15px;\">"
	for(var/obj/item/I in stored_items)
		output += "<div id='\ref[I]'>[I.name]</div>"
	output += "</div>"
	return output

/obj/structure/droppod/proc/get_commands()
	var/select_target = FALSE
	if(flags & STATE_AIMING && flags & ADVANCED_AIMING_INSTALLED)
		select_target = TRUE
	var/output = {"<div class='wr'>
				<div class='header'>Commands</div>
				<div class='links'>
				<a href='?src=\ref[src];start_aiming=1'>Aim</a><br>
				[select_target ? "<a href='?src=\ref[src];select_target=1'>Select Target</a><br>" : null]</a><br>
				<a href='?src=\ref[src];locked=1'>Pod is [(flags & IS_LOCKED) ? "lock down" : "open"]</a><br>
				[ishuman(intruder) ? "<a href='?src=\ref[src];set_dna=1'>[stored_dna ? "un" : ""]set Dna</a><br>" : null]</a><br>
				</div>
				</div>
				<hr>
				<div class='wr'>
				<div class='header'>Storage</div>
				<div class='links'>
				<a href='?src=\ref[src];eject_items=1'>Eject Items<br>
				[Stored_Nuclear ? "<a href='?src=\ref[src];nuclear=1'>Eject Nuclear</a><br>" : null]</a><br>
				[second_intruder ? "<a href='?src=\ref[src];eject_passenger=1'>Eject Passenger</a><br>" : null]</a><br>
				</div>
				</div>
				<a href='?src=\ref[src];eject=1'><span id='eject'>Eject</span></a><br>
				"}
	return output

/obj/structure/droppod/proc/get_stat()
	var/state = "Waiting"
	if(flags & STATE_AIMING)
		state = "Aiming"
	if(flags & STATE_DROPING)
		state = "Droping"
	var/output = {"<b>Integrity: </b> [obj_integrity/max_integrity * 100]%<br>
					<b>Advanced Aiming System: </b> [(flags & ADVANCED_AIMING_INSTALLED) ? "" : "Un"]installed<br>
					<b>Second Passenger: </b>[second_intruder ? "[second_intruder.name]" : "None"]<br>
					<b>Nuclear bomb: </b> [Stored_Nuclear ? "" : "Un"]installed<br>
					<b>Selected area:</b> [AimTarget ? "[AimTarget.loc]" : "None"]<br>
					<b>Current state:</b> [state]<br>
					<b>Uses remaining: </b> [uses]<br>
					"}
	return output

/obj/structure/droppod/Topic(href, href_list)
	..()
	if(href_list["update_content"])
		if(usr != intruder)
			return
		send_byjax(intruder, "droppod.browser", "content", get_stat())
		return
	if(href_list["close"])
		return
	if(href_list["nuclear"])
		if(!isturf(loc))
			return
		EjectNuclear()
		send_byjax(intruder, "droppod.browser", "commands", get_commands())
		return
	if(href_list["start_aiming"])
		Aiming()
		send_byjax(intruder, "droppod.browser", "commands", get_commands())
		return
	if(href_list["set_dna"])
		var/mob/living/carbon/human/H = intruder // players can choose this option only if they are playing for a human
		if(!stored_dna)
			stored_dna = H.dna.unique_enzymes
			to_chat(intruder, "<span class='notice'>Dna key stored.</span>")
		else
			stored_dna = null
			to_chat(intruder, "<span class='notice'>Dna key was wiped.</span>")
		send_byjax(intruder, "droppod.browser", "commands", get_commands())
		return
	if(href_list["select_target"])
		ChooseTarget()
		return
	if(href_list["locked"])
		if(flags & IS_LOCKED)
			flags &= ~IS_LOCKED
			to_chat(intruder, "<span class='notice'>You unblocked [src].</span>")
			cut_overlay(image(icon, "drop_panel[item_state]", "layer" = initial(layer) + 0.3))
		else
			flags |= IS_LOCKED
			add_overlay(image(icon, "drop_panel[item_state]", "layer" = initial(layer) + 0.3))
			to_chat(intruder, "<span class='notice'>You blocked [src].</span>")
		send_byjax(intruder, "droppod.browser", "commands", get_commands())
		return
	if(href_list["eject_items"])
		if(!isturf(loc))
			return
		Eject_items()
		send_byjax(intruder, "droppod.browser", "eq_list", get_stored_items_list())
		return
	if(href_list["eject"])
		Eject()
		return
	if(href_list["eject_passenger"])
		if(!second_intruder)
			to_chat(usr, "<span class='danger'>Nobody there to exile!</span>")
			return
		Eject_second()
		send_byjax(intruder, "droppod.browser","commands",get_commands())
		return

/obj/structure/droppod/Legitimate
	icon_state = "dropod_opened_nt"
	item_state = "_nt"
	flags = (ADVANCED_AIMING_INSTALLED | IS_LEGITIMATE)

/obj/structure/droppod/Syndi
	var/droped = FALSE // if TRUE. The POD can only return to the Syndi Base
	flags = POOR_AIMING

/obj/structure/droppod/Syndi/Aiming()
	if(war_device_activated)
		if(world.time < SYNDICATE_CHALLENGE_TIMER)
			to_chat(intruder, "<span class='warning'>You've issued a combat challenge to the station! You've got to give them at least \
		 		[round(((SYNDICATE_CHALLENGE_TIMER - world.time) / 10) / 60)] \
		 		more minutes to allow them to prepare.</span>")
			return
	else
		war_device_activation_forbidden = TRUE

	if(droped)
		if(!(flags & IS_LOCKED))
			to_chat(intruder, "<span class='userdanger'>Close [src] First!</span>")
			return
		if(!isturf(loc))
			to_chat(intruder, "<span class='userdanger'>You must be on ground to drop!</span>")
			return
		var/list/L = list()
		for(var/turf/T in get_area_turfs(/area/custom/syndicate_mothership/droppod_garage))
			if(!T.density)
				L+=T
		AimTarget = pick(L)
		StartDrop()
		return
	..()

/obj/structure/droppod/Syndi/perform_drop()
	..()
	droped = TRUE

/obj/structure/droppod/Syndi/attackby(obj/item/O, mob/living/carbon/user)
	. = ..()
	if(flags & ADVANCED_AIMING_INSTALLED)
		if(uses == 1 && !droped)
			uses++ // this allow only to return to the base.
	else if(uses == 2)
		uses--

/obj/effect/decal/droppod_wreckage
	name = "Drop Pod wreckage"
	desc = "Remains of some unfortunate Pod. Completely unrepairable."
	icon = 'icons/obj/structures/droppod.dmi'
	icon_state = "crashed_droppod"
	density = 1
	anchored = 0
	opacity = 0

/obj/effect/decal/droppod_wreckage/atom_init(mapload, icon_modifier)
	. = ..()
	if(icon_modifier)
		icon_state += icon_modifier

/obj/item/device/drop_caller
	name = "Drop Pod inititalizer"
	icon = 'icons/obj/device.dmi'
	icon_state = "recaller"
	item_state = "walkietalkie"
	var/drop_type = /obj/structure/droppod

/obj/item/device/drop_caller/attack_self(mob/user)
	if(!iscarbon(user))
		return
	playsound(src, 'sound/effects/drop_start.ogg', VOL_EFFECTS_MASTER)
	var/obj/spawn_drop = new drop_type(get_turf(user))
	spawn_drop.pixel_x = rand(-150, 150)
	spawn_drop.pixel_y = 500
	animate(spawn_drop, pixel_y = 0, pixel_x = 0, time = 20)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, spawn_drop, 'sound/effects/drop_land.ogg', 100, 2), 20)
	qdel(src)

/obj/item/device/drop_caller/Legitimate
	drop_type = /obj/structure/droppod/Legitimate

/obj/item/device/drop_caller/Syndi
	drop_type = /obj/structure/droppod/Syndi

/obj/item/device/drop_caller/Syndi/attack_self(mob/user) //hardcoded spawning Syndi Drop Pods only in "syndicate garage"
	var/area/syndicate_loc = get_area(user)
	if(!istype(syndicate_loc, /area/custom/syndicate_mothership/droppod_garage))
		to_chat(user, "<span class='userdanger'>You must be in the Drop Launch zone.</span>")
		return
	var/min_pods_spawned = INFINITY
	var/obj/effect/landmark/droppod_spawn/chosen_place
	for(var/obj/effect/landmark/droppod_spawn/spawn_point in syndicate_loc)
		if(spawn_point.pods_spawned < min_pods_spawned)
			min_pods_spawned = spawn_point.pods_spawned
			chosen_place = spawn_point
	if(chosen_place)
		chosen_place.pods_spawned += 6
		var/obj/spawn_drop = new drop_type(chosen_place.loc)
		playsound(src, 'sound/effects/drop_start.ogg', VOL_EFFECTS_MASTER)
		spawn_drop.pixel_x = rand(-150, 150)
		spawn_drop.pixel_y = 500
		animate(spawn_drop, pixel_y = 0, pixel_x = 0, time = 20)
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, spawn_drop, 'sound/effects/drop_land.ogg', 100, 2), 20)
		qdel(src)

/obj/effect/landmark/droppod_spawn
	var/pods_spawned = 0

/obj/item/weapon/simple_drop_system
	name = "Aim System"
	desc = "Simple Aim system, can be installed in poor Drop pods"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "aim_system"
	w_class = ITEM_SIZE_SMALL
