/mob/living/simple_animal/replicator
	var/last_disintegration = 0


/atom/proc/is_replicator_structure()
	return FALSE

/mob/living/simple_animal/replicator/is_replicator_structure()
	return TRUE

/obj/item/mine/replicator/is_replicator_structure()
	return TRUE

/turf/simulated/floor/plating/airless/catwalk/forcefield/is_replicator_structure()
	return TRUE

/obj/structure/replicator_forcefield/is_replicator_structure()
	return TRUE

/obj/structure/forcefield_node/is_replicator_structure()
	return TRUE

/obj/structure/bluespace_corridor/is_replicator_structure()
	return TRUE

/obj/structure/replicator_barricade/is_replicator_structure()
	return TRUE

/obj/structure/stabilization_field/is_replicator_structure()
	return TRUE

/obj/structure/cable/power_rune/is_replicator_structure()
	return TRUE

/obj/machinery/swarm_powered/bluespace_transponder/is_replicator_structure()
	return TRUE

/obj/machinery/power/replicator_generator/is_replicator_structure()
	return TRUE

/obj/machinery/swarm_powered/bluespace_catapult/is_replicator_structure()
	return TRUE


/mob/living/simple_animal/replicator/proc/is_disintegratable(atom/A, alert=FALSE)
	if(A.name == "")
		return FALSE
	if(!A.simulated)
		return FALSE

	if(A.get_replicator_material_amount() < 0)
		return FALSE

	if(A.flags & NODECONSTRUCT)
		if(alert)
			to_chat(src, "<span class='warning'>Object Does Not Disintegrate.</span>")
		return FALSE

	if(A.flags_2 & HOLOGRAM_2)
		if(alert)
			to_chat(src, "<span class='warning'>Can Not Disintegrate Holograms.</span>")
		return FALSE

	/*
		We're not afraid of G-d now, are we?
	if((locate(/mob/living) in A) && !isturf(A))
		if(alert)
			to_chat(src, "<span class='warning'>Can Not Deconstruct: May Harm Organics.</span>")
		return FALSE
	*/

	return TRUE

/mob/living/simple_animal/replicator/proc/is_auto_disintegratable(atom/A)
	if(A.is_disintegrating)
		return FALSE

	if(!is_disintegratable(A))
		return FALSE

	if(!A.can_be_auto_disintegrated())
		return FALSE

	if(A.invisibility > see_invisible)
		return FALSE

	return TRUE

/mob/living/simple_animal/replicator/proc/disintegrate_turf(turf/T)
	var/target_x = T.x
	var/target_y = T.y
	var/target_z = T.z

	var/start_loc = loc

	while(!is_busy() && do_after(src, 1, target=src, progress=FALSE))
		if(start_loc != loc)
			return

		var/atom/disintegratable = get_disintegratable_from(locate(target_x, target_y, target_z))
		if(!disintegratable)
			return
		face_atom(disintegratable)
		disintegrate(disintegratable)

/mob/living/simple_animal/replicator/proc/get_disintegratable_from(turf/T)
	for(var/a in T.contents)
		var/atom/A = a
		if(is_auto_disintegratable(A))
			return A

	if(istype(T, /turf/simulated/floor/plating/airless/catwalk/forcefield))
		return null
	if(!is_auto_disintegratable(T))
		return null

	return T

// Return TRUE if disintegrated something.
/mob/living/simple_animal/replicator/proc/disintegrate(atom/A)
	if(is_busy())
		return FALSE
	if(disintegrating)
		return FALSE
	if(A.is_disintegrating)
		return FALSE

	if(!is_disintegratable(A, alert=TRUE))
		return FALSE

	var/material_amount = A.get_replicator_material_amount()

	disintegrating = TRUE
	A.is_disintegrating = TRUE

	var/obj/effect/overlay/replicator/D = new(get_turf(A))
	D.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	D.plane = A.plane
	D.layer = A.layer + 0.1
	D.icon_state = "disintegrate_static"

	playsound_stealthy(A, 'sound/machines/cyclotron.ogg')

	var/datum/callback/checks = CALLBACK(src, .proc/disintegrate_do_after_checks)
	if(!do_skilled(src, A, A.get_unit_disintegration_time() * material_amount / efficency, list(/datum/skill/construction = SKILL_LEVEL_TRAINED), -0.2, extra_checks=checks))
		qdel(D)
		disintegrating = FALSE
		A.is_disintegrating = FALSE
		return FALSE

	// Building and disintegrating your own forcefield builds does not reset disintegration deficency debuff.
	if(!A.is_replicator_structure())
		last_disintegration = world.time

	playsound_stealthy(src, 'sound/mecha/UI_SCI-FI_Compute_01_Wet.ogg')

	var/obj/effect/overlay/replicator/target_appearance = new(get_turf(A))
	target_appearance.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	target_appearance.plane = A.plane
	target_appearance.layer = A.layer + 0.09
	target_appearance.appearance = A

	var/matrix/M = matrix(A.transform)

	// make the item we're targetting waddle?
	if(!A.replicator_act(src))
		qdel(D)
		qdel(target_appearance)
		disintegrating = FALSE
		A.is_disintegrating = FALSE
		return FALSE

	target_appearance.pixel_x = 0
	target_appearance.pixel_y = 0

	D.icon = 'icons/mob/replicator.dmi'
	D.icon_state = "disintegrate"

	M.Scale(0.1, 0.1)
	M = turn(M, 180)

	var/matrix/M2 = matrix(M)

	animate(target_appearance, transform=M, time=8)
	animate(D, transform=M2, time=8)

	QDEL_IN(D, 8)
	QDEL_IN(target_appearance, 8)

	disintegrating = FALSE
	A.is_disintegrating = FALSE

	var/healing_amount = material_amount * REPLICATOR_DISINTEGRATION_REPAIR_RATE
	// Can't heal via your own barricades.
	if(healing_amount > 0 && !A.is_replicator_structure())
		//integrate_animation()
		heal_bodypart_damage(healing_amount, 0)

	// Healing is quite expensive otherwise...
	if(material_amount > 0)
		var/datum/faction/replicators/FR = get_or_create_replicators_faction()
		FR.adjust_materials(material_amount, adjusted_by=last_controller_ckey)
	return TRUE

/*
	Doesn't really look good :(
	Was supposed to be an animation for repairs.
	But... Now they repair ALL the time since they're slowly dying.

/mob/living/simple_animal/replicator/proc/integrate_animation()
	if(playing_integration_animation)
		return
	playing_integration_animation = TRUE

	var/image/I = image(icon=icon, icon_state="integrate")
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	I.layer = layer + 0.1
	I.plane = plane
	I.loc = src

	flick_overlay_view(I, src, 5)

	VARSET_IN(src, playing_integration_animation, FALSE, 5)
*/

/mob/living/simple_animal/replicator/proc/disintegrate_do_after_checks(mob/living/simple_animal/replicator/R, atom/target)
	return R.is_disintegratable(target, alert=TRUE)
