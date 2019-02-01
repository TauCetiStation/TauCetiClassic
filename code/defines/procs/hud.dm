/* Using the HUD procs is simple. Call these procs in the life.dm of the intended mob.
Use the regular_hud_updates() proc before process_med_hud(mob) or process_sec_hud(mob) so
the HUD updates properly! */

//Medical HUD outputs. Called by the Life() proc of the mob using it, usually.
/proc/process_med_hud(mob/M, local_scanner, mob/Alt, crit_fail = 0)
	if(!can_process_hud(M))
		return

	var/datum/arranged_hud_process/P = arrange_hud_process(M, Alt, med_hud_users)
	for(var/mob/living/carbon/human/patient in P.Mob.in_view(P.Turf))
		if(P.Mob.see_invisible < patient.invisibility)
			continue
		if(crit_fail)
			P.Client.images += image('icons/mob/hud.dmi', loc = patient, icon_state = pick("hudbroken6", "hudbroken7"))
			continue
		if(patient.digitalcamo)
			continue
		if(!local_scanner)
			if(istype(patient.w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = patient.w_uniform
				if(U.sensor_mode < 2)
					continue
			else
				continue
		if(local_scanner)
			P.Client.images += patient.hud_list[STATUS_HUD]
		P.Client.images += patient.hud_list[HEALTH_HUD]


//Security HUDs. Pass a value for the second argument to enable implant viewing or other special features.
/proc/process_sec_hud(mob/M, advanced_mode, mob/Alt, crit_fail = 0)
	if(!can_process_hud(M))
		return
	var/datum/arranged_hud_process/P = arrange_hud_process(M, Alt, sec_hud_users)
	for(var/mob/living/carbon/human/perp in P.Mob.in_view(P.Turf))
		if(P.Mob.see_invisible < perp.invisibility)
			continue
		if(perp.digitalcamo)
			continue
		if(crit_fail)
			P.Client.images += image('icons/mob/hud.dmi', loc = perp, icon_state = pick("hudbroken4", "hudbroken5"))
			continue
		P.Client.images += perp.hud_list[ID_HUD]
		if(advanced_mode)
			P.Client.images += perp.hud_list[WANTED_HUD]
			P.Client.images += perp.hud_list[IMPTRACK_HUD]
			P.Client.images += perp.hud_list[IMPLOYAL_HUD]
			P.Client.images += perp.hud_list[IMPCHEM_HUD]

/proc/process_broken_hud(mob/M, advanced_mode, mob/Alt)
	if(!can_process_hud(M))
		return
	var/datum/arranged_hud_process/P = arrange_hud_process(M, Alt, sec_hud_users)
	for(var/mob/living/carbon/human/perp in P.Mob.in_view(P.Turf))
		if(P.Mob.see_invisible < perp.invisibility)
			continue
		P.Client.images += image('icons/mob/hud.dmi', loc = perp, icon_state = "hudbroken[pick(1,2,3,4,5,6,7)]")

#define DIONA_HUD_FILTER(hive_color) list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, hex2num(copytext(hive_color, 2, 4)) / 255, hex2num(copytext(hive_color, 4, 6)) / 255, hex2num(copytext(hive_color, 6, 8)) / 255, 0.58)
#define BODY_LAYER 27

/proc/process_diona_hud(mob/living/carbon/human/M, mob/Alt)
	if(!can_process_hud(M))
		return
	for(var/image/I in M.diona_hud_images)
		M.client.images -= I
	M.diona_hud_images = list()
	for(var/atom/movable/A in range(get_turf(M)))
		/*if(P.Mob.see_invisible < perp.invisibility) // Dionas sense them nymphs.
			continue*/
		if(iscarbon(A))
			var/mob/living/carbon/D = A
			if(D.get_species() != DIONA)
				continue
			if(D.stat != CONSCIOUS)
				continue
			if(ishuman(D))
				var/mob/living/carbon/human/H = D
				var/image/I = image(loc = H)
				var/image/T = new
				T.overlays = H.overlays_standing[BODY_LAYER]
				I.appearance = T
				I.dir = D.dir
				I.layer = LIGHTING_LAYER + 1
				I.plane = LIGHTING_PLANE + 1
				I.color = DIONA_HUD_FILTER(H.unique_diona_hive_color)
				M.client.images += I
				M.diona_hud_images += I
			else if(istype(D, /mob/living/carbon/monkey/diona))
				var/mob/living/carbon/monkey/diona/DD = D
				if(DD.gestalt)
					if(DD.selected && DD.gestalt == M)
						var/image/II = image(loc = DD)
						II.appearance = DD
						II.dir = DD.dir
						II.layer = LIGHTING_LAYER + 1
						II.plane = LIGHTING_PLANE + 1
						II.color = DIONA_HUD_FILTER(DD.gestalt.unique_diona_hive_color)
						M.client.images += II
						M.diona_hud_images += II
					else
						var/image/III = image('icons/misc/tools.dmi', loc = DD, icon_state = "huddiona")
						III.layer = LIGHTING_LAYER + 1
						III.plane = LIGHTING_PLANE + 1
						III.color = DD.gestalt.unique_diona_hive_color
						M.client.images += III
						M.diona_hud_images += III
		else if(istype(A, /obj/item/nymph_morph_ball))
			var/mob/living/carbon/monkey/diona/D = locate() in A
			if(D.gestalt)
				var/image/I = image(loc = A)
				I.appearance = A
				I.dir = A.dir
				I.layer = LIGHTING_LAYER + 1
				I.plane = LIGHTING_PLANE + 1
				I.color = DIONA_HUD_FILTER(D.gestalt.unique_diona_hive_color)
				M.client.images += I
				M.diona_hud_images += I
#undef DIONA_HUD_FILTER
#undef BODY_LAYER

/datum/arranged_hud_process
	var/client/Client
	var/mob/Mob
	var/turf/Turf

/proc/arrange_hud_process(mob/M, mob/Alt, list/hud_list)
	hud_list |= M
	var/datum/arranged_hud_process/P = new
	P.Client = M.client
	P.Mob = Alt ? Alt : M
	P.Turf = get_turf(P.Mob)
	return P

/proc/can_process_hud(mob/M)
	if(!M)
		return 0
	if(!M.client)
		return 0
	if(M.stat != CONSCIOUS)
		return 0
	return 1

//Deletes the current HUD images so they can be refreshed with new ones.
/mob/proc/regular_hud_updates() //Used in the life.dm of mobs that can use HUDs.
	if(client)
		for(var/image/hud in client.images)
			if(copytext(hud.icon_state,1,4) == "hud")
				client.images -= hud
	med_hud_users -= src
	sec_hud_users -= src

/mob/proc/in_view(turf/T)
	return view(T)

/mob/camera/Eye/in_view(turf/T)
	var/list/viewed = new
	for(var/mob/living/carbon/human/H in human_list)
		if(get_dist(H, T) <= 7)
			viewed += H
	return viewed
