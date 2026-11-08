/datum/unit_test/emissive_turf_visibility
	name = "RENDERING: EMISSIVE TURF VISIBILITY"

/datum/unit_test/emissive_turf_visibility/proc/count_underlays(turf/target, target_plane)
	. = 0
	for(var/image/underlay as anything in target.underlays)
		if(underlay.plane == target_plane)
			.++

/datum/unit_test/emissive_turf_visibility/start_test()
	var/turf/target = locate(1, 1, 1)
	var/original_type = target.type
	var/list/errors = list()
	if(count_underlays(target, EMISSIVE_VISIBILITY_PLANE) != 1)
		errors += "A map-loaded turf did not have exactly one visibility mask."

	var/turf/simulated/floor/grid_floor/grid = target.ChangeTurf(/turf/simulated/floor/grid_floor)
	grid.toggle_cower()
	grid.toggle_cower()
	if(count_underlays(grid, EMISSIVE_VISIBILITY_PLANE) != 1 || count_underlays(grid, UNDERFLOOR_PLANE) != 1)
		errors += "Changing a floor or opening its panel lost the visibility mask or the floor background."

	var/turf/simulated/wall/wall = grid.ChangeTurf(/turf/simulated/wall)
	wall.fixed_underlay = list("space" = TRUE)
	wall.diagonal_smooth(N_NORTH | N_WEST)
	wall.diagonal_smooth(N_NORTH | N_WEST)
	if(count_underlays(wall, EMISSIVE_VISIBILITY_PLANE) != 1 || count_underlays(wall, PLANE_SPACE) != 1)
		errors += "Repeated diagonal smoothing lost or duplicated the visibility mask or the wall background."

	var/turf/environment/space/space = new(wall)
	if(count_underlays(space, EMISSIVE_VISIBILITY_PLANE) != 1)
		errors += "Space initialization, which skips the base turf initializer, lost the visibility mask."
	space.ChangeTurf(original_type)
	if(length(errors))
		fail(jointext(errors, " "))
		return FALSE
	pass("Map-loaded and replaced turfs retain one visibility mask through floor updates and diagonal smoothing.")
	return TRUE

/datum/unit_test/emissive_blocker_lifecycle
	name = "RENDERING: EMISSIVE BLOCKER LIFECYCLE"

/datum/unit_test/emissive_blocker_lifecycle/start_test()
	var/obj/item/item = new
	var/atom/movable/emissive_blocker/blocker = item.emissive_blocker
	if(!blocker || !(blocker in item.vis_contents) || !item.render_target || blocker.render_source != item.render_target || !(item.appearance_flags & KEEP_TOGETHER))
		qdel(item)
		fail("Items must initialize their blocker even though they skip parent atom_init.")
		return FALSE
	INIT_EMISSIVE_BLOCKER(item)
	if(item.emissive_blocker != blocker || length(item.vis_contents) != 1)
		qdel(item)
		fail("Initializing a blocker twice duplicated its visual child.")
		return FALSE
	var/obj/structure/structure = new
	var/atom/movable/emissive_blocker/structure_blocker = structure.emissive_blocker
	if(!structure_blocker || !(structure_blocker in structure.vis_contents) || !structure.render_target || structure.render_target == item.render_target || structure_blocker.render_source != structure.render_target || !(structure.appearance_flags & KEEP_TOGETHER))
		qdel(item)
		qdel(structure)
		fail("The parent initialization path must create a blocker with its own render target.")
		return FALSE
	qdel(structure)
	qdel(item)
	if(!QDELETED(blocker) || !QDELETED(structure_blocker))
		fail("Deleting items or structures left their blockers alive.")
		return FALSE

	var/atom/movable/owner = new
	INIT_EMISSIVE_BLOCKER(owner)
	if(owner.emissive_blocker || owner.render_target || length(owner.vis_contents) || (owner.appearance_flags & KEEP_TOGETHER))
		qdel(owner)
		fail("An atom without blocks_emissive acquired blocker render state.")
		return FALSE
	owner.blocks_emissive = TRUE
	owner.appearance_flags |= KEEP_TOGETHER | RESET_COLOR
	owner.render_target = "emissive_test_[REF(owner)]"
	var/original_target = owner.render_target
	var/atom/movable/other_visual = new
	owner.vis_contents += other_visual
	INIT_EMISSIVE_BLOCKER(owner)
	blocker = owner.emissive_blocker
	if(!blocker || owner.render_target != original_target || blocker.render_source != original_target || !(owner.appearance_flags & KEEP_TOGETHER) || !(owner.appearance_flags & RESET_COLOR) || !(other_visual in owner.vis_contents))
		qdel(owner)
		qdel(other_visual)
		fail("Initializing a blocker changed existing render state.")
		return FALSE

	qdel(owner)
	if(!QDELETED(blocker) || !isnull(owner.emissive_blocker) || QDELETED(other_visual))
		qdel(other_visual)
		fail("Deleting the owner must delete its blocker and preserve unrelated visual children.")
		return FALSE
	qdel(other_visual)
	pass("Blockers initialize once, preserve existing render state, and are deleted with their owner.")
	return TRUE

/datum/unit_test/emissive_airlock_cache
	name = "RENDERING: EMISSIVE AIRLOCK CACHE"

/datum/unit_test/emissive_airlock_cache/start_test()
	var/mutable_appearance/plain = get_airlock_overlay("lights_poweron", 'icons/obj/doors/airlocks/station2/overlays.dmi', FALSE)
	var/mutable_appearance/glowing = get_airlock_overlay("lights_poweron", 'icons/obj/doors/airlocks/station2/overlays.dmi', TRUE)
	if(plain == glowing || length(plain.overlays) || !length(glowing.overlays))
		fail("Glowing and ordinary airlock overlays must not share a cache entry.")
		return FALSE
	if(get_airlock_overlay("lights_poweron", 'icons/obj/doors/airlocks/station2/overlays.dmi', FALSE) != plain || get_airlock_overlay("lights_poweron", 'icons/obj/doors/airlocks/station2/overlays.dmi', TRUE) != glowing)
		fail("Repeated airlock overlay requests did not reuse their cached appearances.")
		return FALSE
	pass("Airlock glow masks stay separate from ordinary cached overlays.")
	return TRUE

/datum/unit_test/emissive_airlock_directions
	name = "RENDERING: EMISSIVE AIRLOCK DIRECTIONS"

/datum/unit_test/emissive_airlock_directions/start_test()
	var/list/cached = list()
	var/list/seen = list()
	for(var/direction in cardinal)
		var/mutable_appearance/glowing = get_airlock_overlay("lights_poweron", 'icons/obj/doors/airlocks/station2/overlays.dmi', TRUE, direction)
		var/mutable_appearance/mask = glowing.overlays[1]
		if(glowing.dir != direction || mask.dir != direction || (glowing in seen))
			fail("A rotated airlock reused another direction's glow or mask.")
			return FALSE
		cached["[direction]"] = glowing
		seen += glowing
	for(var/direction in cardinal)
		if(get_airlock_overlay("lights_poweron", 'icons/obj/doors/airlocks/station2/overlays.dmi', TRUE, direction) != cached["[direction]"])
			fail("Requesting another direction replaced an existing airlock cache entry.")
			return FALSE
	pass("Airlock glow and mask cache entries preserve all four directions.")
	return TRUE

/datum/unit_test/emissive_computer_states
	name = "RENDERING: EMISSIVE COMPUTER STATES"

/datum/unit_test/emissive_computer_states/start_test()
	var/obj/machinery/computer/robotics/computer = new
	var/obj/machinery/computer/robotics/other = new
	computer.stat = 0
	other.stat = 0
	computer.update_icon()
	other.update_icon()
	var/mutable_appearance/south_mask = computer.emissive_overlay
	var/list/errors = list()
	if(!south_mask || other.emissive_overlay != south_mask)
		errors += "Powered consoles did not reuse a screen mask."
	computer.set_dir(EAST)
	if(!computer.emissive_overlay || computer.emissive_overlay == south_mask || computer.emissive_overlay.dir != EAST || other.emissive_overlay != south_mask)
		errors += "Rotating one console changed or reused another direction's mask."
	computer.stat |= NOPOWER
	computer.update_icon()
	if(computer.emissive_overlay)
		errors += "An unpowered console kept its screen glow."
	computer.stat = BROKEN
	computer.update_icon()
	if(computer.emissive_overlay)
		errors += "A broken console kept its screen glow."
	computer.stat = 0
	computer.update_icon()
	if(!computer.emissive_overlay)
		errors += "Restoring a console did not restore its screen glow."
	computer.icon = 'icons/obj/objects.dmi'
	computer.update_emissive()
	if(computer.emissive_overlay)
		errors += "A foreign console icon reused computer.dmi's screen mask."
	qdel(computer)
	qdel(other)
	if(length(errors))
		fail(jointext(errors, " "))
		return FALSE
	pass("Console masks follow power, broken state, direction, and sprite ownership.")
	return TRUE

/datum/unit_test/emissive_airlock_light_states
	name = "RENDERING: AIRLOCK LIGHT STATE TRANSITIONS"

/datum/unit_test/emissive_airlock_light_states/start_test()
	var/obj/machinery/door/airlock/door = new
	var/list/errors = list()
	door.stat = 0
	door.lights = TRUE
	door.do_animate("opening")
	if(door.light_color != "#57e69c")
		errors += "Opening must use the green access light."
	door.density = FALSE
	door.update_icon()
	if(door.light_color != "#3aa7c2")
		errors += "An open airlock did not restore its steady light color."
	door.locked = TRUE
	door.update_icon()
	if(door.light_color != "#c23b23")
		errors += "An open bolted airlock did not use its red light."
	door.locked = FALSE
	door.emergency = TRUE
	door.update_icon()
	if(door.light_color != "#d1d11d")
		errors += "An open emergency airlock did not use its yellow light."
	door.emergency = FALSE
	door.do_animate("closing")
	if(door.light_color != "#57e69c")
		errors += "Closing must use the green access light."
	door.density = TRUE
	door.update_icon()
	if(door.light_color != "#3aa7c2")
		errors += "A closed airlock did not restore its steady light color."
	door.stat |= NOPOWER
	door.update_icon()
	if(door.light_range || door.light)
		errors += "An unpowered airlock kept its light source."
	qdel(door)
	if(length(errors))
		fail(jointext(errors, " "))
		return FALSE
	pass("Airlock lighting follows opening, open, bolts, emergency, closing, closed, and power loss.")
	return TRUE

/datum/unit_test/emissive_status_display_light
	name = "RENDERING: STATUS DISPLAY LIGHT LIFECYCLE"

/datum/unit_test/emissive_status_display_light/start_test()
	var/list/errors = list()
	var/obj/machinery/status_display/display = new
	display.stat = 0
	display.mode = 3
	display.set_picture("default")
	var/datum/light_source/original_light = display.light
	if(!original_light || !display.underlays.len)
		errors += "A lit status display has no glow or surrounding light."
	display.set_picture("default")
	display.update_display("-ETA-", "01:23")
	display.update_display("-ETA-", "01:22")
	if(display.light != original_light)
		errors += "Updating display content recreated its light source."
	if(display.underlays.len != 1)
		errors += "Updating display content duplicated its emissive mask."
	display.stat = NOPOWER
	display.update()
	if(display.light || display.light_range || display.underlays.len)
		errors += "An unpowered status display kept its glow or light: light=[!!display.light], range=[display.light_range], underlays=[display.underlays.len]."
	display.stat = 0
	display.update()
	if(!display.light || !display.underlays.len)
		errors += "Restoring power did not restore status display lighting."
	display.stat = BROKEN
	display.update()
	if(display.light || display.underlays.len)
		errors += "A broken status display kept its light."
	display.stat = 0
	display.update_display("", "")
	if(display.light || display.underlays.len)
		errors += "An empty status display kept its light."
	qdel(display)

	var/obj/machinery/ai_status_display/ai_display = new
	ai_display.stat = 0
	ai_display.mode = 1
	ai_display.update()
	original_light = ai_display.light
	ai_display.update()
	if(!original_light || ai_display.light != original_light)
		errors += "An AI display did not reuse its active light."
	if(ai_display.underlays.len != 1)
		errors += "Updating an AI display duplicated its emissive mask."
	ai_display.emotion = "Blank"
	ai_display.update()
	if(ai_display.light || ai_display.underlays.len)
		errors += "A blank AI display kept its glow or light."
	ai_display.emotion = "Neutral"
	ai_display.update()
	ai_display.stat = BROKEN
	ai_display.update()
	if(ai_display.light || ai_display.underlays.len)
		errors += "A broken AI display kept its glow or light."
	qdel(ai_display)
	if(length(errors))
		fail(jointext(errors, " "))
		return FALSE
	pass("Display lighting follows content and power without recreating an unchanged light source.")
	return TRUE

/datum/unit_test/proc/count_emissive_masks(list/appearances)
	. = 0
	for(var/entry in appearances)
		var/mutable_appearance/appearance = entry
		if(appearance.plane == EMISSIVE_MASK_PLANE)
			.++
		. += count_emissive_masks(appearance.overlays)

/datum/unit_test/proc/count_atom_emissive_masks(atom/target)
	COMPILE_OVERLAYS(target)
	return count_emissive_masks(target.overlays)

/datum/unit_test/emissive_alarm_states
	name = "RENDERING: EMISSIVE ALARM STATES"

/datum/unit_test/emissive_alarm_states/start_test()
	var/list/errors = list()
	var/area/test_area = get_area(locate(1, 1, 1))
	var/obj/machinery/alarm/air_alarm = new(null, SOUTH, TRUE)
	air_alarm.alarm_area = test_area
	air_alarm.buildstage = 2
	air_alarm.wiresexposed = FALSE
	air_alarm.stat = 0
	air_alarm.update_icon()
	var/datum/light_source/air_light = air_alarm.light
	if(!air_light || air_alarm.light_range != MINIMUM_USEFUL_LIGHT_RANGE || air_alarm.light_power != 1)
		errors += "A working air alarm has no disposal-sized surrounding light."
	for(var/level in 0 to 2)
		air_alarm.danger_level = level
		air_alarm.update_icon()
		air_alarm.update_icon()
		var/expected_level = test_area.atmosalm ? max(level, 1) : level
		if(air_alarm.icon_state != "alarm[expected_level]" || count_atom_emissive_masks(air_alarm) != 1)
			errors += "Air alarm level [level] did not retain exactly one glow mask."
		if(air_alarm.light != air_light)
			errors += "Changing air alarm danger level recreated its light source."
	for(var/state in list(NOPOWER, BROKEN))
		air_alarm.stat = 0
		air_alarm.update_icon()
		air_alarm.stat = state
		air_alarm.update_icon()
		if(count_atom_emissive_masks(air_alarm) || air_alarm.light || air_alarm.light_range)
			errors += "An inactive air alarm retained its glow or surrounding light."
	air_alarm.stat = 0
	air_alarm.update_icon()
	air_alarm.shorted = TRUE
	air_alarm.update_icon()
	if(count_atom_emissive_masks(air_alarm) || air_alarm.light || air_alarm.light_range)
		errors += "A shorted air alarm retained its glow or surrounding light."
	air_alarm.shorted = FALSE
	air_alarm.update_icon()
	air_alarm.wiresexposed = TRUE
	air_alarm.update_icon()
	if(count_atom_emissive_masks(air_alarm) || air_alarm.light || air_alarm.light_range)
		errors += "An open air alarm retained its glow or surrounding light."
	air_alarm.wiresexposed = FALSE
	air_alarm.update_icon()
	if(count_atom_emissive_masks(air_alarm) != 1 || !air_alarm.light || air_alarm.light_range != MINIMUM_USEFUL_LIGHT_RANGE)
		errors += "Closing a working air alarm did not restore its glow and surrounding light."
	qdel(air_alarm)

	var/obj/machinery/firealarm/fire_alarm = new
	fire_alarm.stat = 0
	fire_alarm.update_icon()
	var/datum/light_source/fire_light = fire_alarm.light
	if(!fire_light || fire_alarm.light_range != MINIMUM_USEFUL_LIGHT_RANGE || fire_alarm.light_power != 1)
		errors += "A working fire alarm has no disposal-sized surrounding light."
	for(var/detecting in list(TRUE, FALSE))
		fire_alarm.detecting = detecting
		fire_alarm.update_icon()
		fire_alarm.update_icon()
		if(fire_alarm.icon_state != (detecting ? "fire0" : "fire1") || count_atom_emissive_masks(fire_alarm) != 1)
			errors += "Changing fire detection did not replace its glow mask."
		if(fire_alarm.light != fire_light)
			errors += "Changing fire detection recreated its light source."
	for(var/state in list(NOPOWER, BROKEN))
		fire_alarm.stat = 0
		fire_alarm.update_icon()
		fire_alarm.stat = state
		fire_alarm.update_icon()
		if(count_atom_emissive_masks(fire_alarm) || fire_alarm.security_overlay || fire_alarm.light || fire_alarm.light_range)
			errors += "An inactive fire alarm retained its glow, security indicator or surrounding light."
	fire_alarm.stat = 0
	fire_alarm.update_icon()
	fire_alarm.wiresexposed = TRUE
	fire_alarm.update_icon()
	if(count_atom_emissive_masks(fire_alarm) || fire_alarm.light || fire_alarm.light_range)
		errors += "An open fire alarm retained its glow or surrounding light."
	fire_alarm.wiresexposed = FALSE
	fire_alarm.update_icon()
	if(count_atom_emissive_masks(fire_alarm) != 1 || !fire_alarm.light || fire_alarm.light_range != MINIMUM_USEFUL_LIGHT_RANGE)
		errors += "Closing a working fire alarm did not restore its glow and surrounding light."
	qdel(fire_alarm)
	if(length(errors))
		fail(jointext(errors, " "))
		return FALSE
	pass("Alarm masks and surrounding lights follow state changes without recreating active light sources.")
	return TRUE

/datum/unit_test/emissive_rig_lights
	name = "RENDERING: EMISSIVE RIG LIGHTS"

/datum/unit_test/emissive_rig_lights/start_test()
	var/list/errors = list()
	var/turf/T = locate(1, 1, 1)
	var/mob/living/carbon/human/H = new(T)
	var/obj/item/clothing/head/helmet/space/rig/helmet = new(T)
	if(count_atom_emissive_masks(helmet))
		errors += "A disabled rig lamp started with a glow."
	helmet.attack_self(H)
	if(!helmet.on || count_atom_emissive_masks(helmet) != 1)
		errors += "Enabling a dropped rig lamp did not add its glow."
	H.equip_to_slot_or_del(helmet, SLOT_HEAD)
	if(QDELETED(helmet))
		qdel(H)
		fail("The test rig helmet could not be equipped.")
		return FALSE
	var/mutable_appearance/standing = helmet.get_standing_overlay(H, 'icons/mob/head.dmi', SPRITE_SHEET_HEAD, -HEAD_LAYER)
	if(count_atom_emissive_masks(helmet) || count_emissive_masks(standing.overlays) != 1 || !(standing.appearance_flags & KEEP_APART))
		errors += "Equipping a lit rig did not transfer its glow to the worn appearance."
	H.drop_from_inventory(helmet)
	if(count_atom_emissive_masks(helmet) != 1)
		errors += "Dropping a lit rig did not restore exactly one world glow."
	helmet.refit_for_species(UNATHI)
	standing = helmet.get_standing_overlay(H, 'icons/mob/head.dmi', SPRITE_SHEET_HEAD, -HEAD_LAYER)
	if(standing.icon != 'icons/mob/species/unathi/helmet.dmi' || count_emissive_masks(standing.overlays) != 1 || helmet.emissive_overlay?.icon != 'icons/obj/clothing/species/unathi/hats.dmi')
		errors += "Refitting a lit rig retained another species' worn or world mask."
	helmet.attack_self(H)
	standing = helmet.get_standing_overlay(H, 'icons/mob/head.dmi', SPRITE_SHEET_HEAD, -HEAD_LAYER)
	if(helmet.on || count_atom_emissive_masks(helmet) || count_emissive_masks(standing.overlays))
		errors += "Disabling a rig lamp left a world or worn glow."
	qdel(helmet)
	qdel(H)
	if(length(errors))
		fail(jointext(errors, " "))
		return FALSE
	pass("Rig lamps follow toggling, equipment, dropping and species refits.")
	return TRUE

/datum/unit_test/emissive_ipc_screens
	name = "RENDERING: EMISSIVE IPC SCREENS"

/datum/unit_test/emissive_ipc_screens/start_test()
	var/list/errors = list()
	var/mob/living/carbon/human/H = new(locate(1, 1, 1))
	H.update_body(BP_HEAD, update_preferences = TRUE)
	if(count_emissive_masks(H.bodypart_overlays_standing[BP_HEAD]))
		errors += "Ordinary human hair acquired an emissive mask."
	H.set_species(IPC)
	var/obj/item/organ/external/head/robot/ipc/head = H.bodyparts_by_name[BP_HEAD]
	head.ipc_head = "Cobalt"
	H.h_style = /datum/sprite_accessory/hair/ipc_screen_cobalt::name
	H.grad_style = "none"
	H.update_body(BP_HEAD, update_preferences = TRUE)
	if(count_emissive_masks(H.bodypart_overlays_standing[BP_HEAD]) != 1)
		errors += "A live IPC screen did not acquire exactly one glow mask."
	H.IPC_toggle_screen()
	if(head.screen_toggle || count_emissive_masks(H.bodypart_overlays_standing[BP_HEAD]))
		errors += "Switching off an IPC screen left its cached glow."
	head.screen_toggle = TRUE
	H.update_body(BP_HEAD, update_preferences = TRUE)
	var/obj/item/clothing/head/cover = new(H)
	cover.render_flags = HIDE_TOP_HAIR
	H.equip_to_slot_or_del(cover, SLOT_HEAD)
	H.update_body(BP_HEAD)
	if(count_emissive_masks(H.bodypart_overlays_standing[BP_HEAD]))
		errors += "Head-covering clothing left the IPC screen mask visible."
	H.drop_from_inventory(cover)
	qdel(cover)
	H.update_body(BP_HEAD)
	if(count_emissive_masks(H.bodypart_overlays_standing[BP_HEAD]) != 1)
		errors += "Uncovering a lit IPC screen did not restore its glow."
	H.death()
	if(head.screen_toggle || count_emissive_masks(H.bodypart_overlays_standing[BP_HEAD]))
		errors += "Death left a non-default IPC head's cached glow active."
	qdel(H)
	if(length(errors))
		fail(jointext(errors, " "))
		return FALSE
	pass("IPC screen glow follows screen toggling, clothing and the actual death lifecycle.")
	return TRUE

/datum/unit_test/emissive_entertainment_monitor
	name = "RENDERING: EMISSIVE ENTERTAINMENT MONITOR"

/datum/unit_test/emissive_entertainment_monitor/start_test()
	var/list/errors = list()
	var/obj/machinery/computer/security/telescreen/entertainment/monitor = new
	for(var/state in list(0, NOPOWER, 0, BROKEN, 0))
		monitor.stat = state
		monitor.update_icon()
		monitor.update_icon()
		if(count_atom_emissive_masks(monitor) != !state)
			errors += "Entertainment monitor glow did not follow power/damage state [state]."
	monitor.icon = 'icons/obj/objects.dmi'
	monitor.update_emissive()
	if(count_atom_emissive_masks(monitor))
		errors += "An entertainment monitor with a foreign icon retained its screen mask."
	qdel(monitor)
	if(length(errors))
		fail(jointext(errors, " "))
		return FALSE
	pass("Entertainment monitor glow follows power and damage without duplicate masks.")
	return TRUE

/datum/unit_test/emissive_character_preview
	name = "RENDERING: EMISSIVE CHARACTER PREVIEW"

/datum/unit_test/emissive_character_preview/start_test()
	var/list/errors = list()
	var/mob/living/carbon/human/dummy/mannequin = new(locate(1, 1, 1), IPC)
	mannequin.h_style = /datum/sprite_accessory/hair/ipc_sinewave::name
	mannequin.grad_style = "none"
	mannequin.r_hair = 0
	mannequin.g_hair = 0
	mannequin.b_hair = 0
	mannequin.update_body(BP_HEAD, update_preferences = TRUE)
	if(count_atom_emissive_masks(mannequin) != 1)
		errors += "The IPC fixture must include its real screen mask before preview conversion."

	var/image/directional_underlay = image('icons/mob/human_face.dmi', icon_state = "ipc_sinewave_s", layer = -HAIR_LAYER, dir = EAST)
	var/mutable_appearance/underlay = new(directional_underlay)
	underlay.plane = ABOVE_GAME_PLANE
	underlay.color = "#123456"
	underlay.alpha = 173
	underlay.pixel_x = 2
	underlay.transform = matrix().Scale(0.75)
	underlay.appearance_flags = KEEP_TOGETHER | KEEP_APART
	underlay.blend_mode = BLEND_INSET_OVERLAY
	underlay.filters += filter(arglist(alpha_mask_filter(icon = 'icons/mob/human_face.dmi')))
	mannequin.underlays += underlay
	var/mutable_appearance/inherited_underlay = mutable_appearance('icons/mob/human_face.dmi', "ipc_sinewave_s", -HAIR_LAYER, ABOVE_GAME_PLANE)
	mannequin.underlays += inherited_underlay
	mannequin.underlays += emissive_mask_appearance('icons/mob/human_face.dmi', "ipc_sinewave_s")
	var/mutable_appearance/preview = mannequin.get_preview_appearance()
	var/image/preview_snapshot = preview.appearance
	if(count_emissive_masks(preview.overlays) || count_emissive_masks(preview.underlays))
		errors += "Preview conversion left a white emissive mask in the image."
	if(length(preview_snapshot.underlays) != 2 || preview_snapshot.underlays[1] != underlay.appearance)
		errors += "Preview conversion changed an ordinary underlay's plane, color, blend, filters or transform."
	if(length(preview_snapshot.underlays) != 2 || preview_snapshot.underlays[2] != inherited_underlay.appearance)
		errors += "Preview conversion changed an underlay that must inherit its holder's direction."
	var/mutable_appearance/inherited_overlay = new(inherited_underlay)
	inherited_overlay.plane = ABOVE_GAME_PLANE
	inherited_overlay.overlays += inherited_underlay
	var/unlit_appearance = inherited_overlay.appearance
	inherited_overlay.overlays += emissive_mask_appearance('icons/mob/human_face.dmi', "ipc_sinewave_s")
	var/mutable_appearance/filtered_overlay = copy_without_emissive_planes(inherited_overlay)
	if(filtered_overlay.appearance != unlit_appearance)
		errors += "Removing a mask changed a nested overlay's inherited direction or ordinary appearance."
	if(count_atom_emissive_masks(mannequin) != 1 || count_emissive_masks(mannequin.underlays) != 1 || !mannequin.render_target || preview.render_target)
		errors += "Preview conversion changed the mannequin's lighting state or reused its render target."

	mannequin.default_transform = matrix().Scale(0.8)
	mannequin.lying = TRUE
	mannequin.update_transform()
	var/lying_transform = json_encode(mannequin.default_transform.tolist())
	preview = mannequin.get_preview_appearance()
	var/matrix/expected = matrix().Scale(0.8)
	var/matrix/actual = preview.transform
	var/list/expected_values = expected.tolist()
	var/list/actual_values = actual.tolist()
	for(var/index in 1 to 6)
		if(abs(actual_values[index] - expected_values[index]) > 0.0001)
			errors += "A lying mannequin's preview did not return upright while preserving its scale."
			break
	if(preview.pixel_x != initial(mannequin.pixel_x) || preview.pixel_y != initial(mannequin.pixel_y) || preview.layer != initial(mannequin.layer))
		errors += "A lying mannequin's preview retained its floor offsets or layer."
	if(!mannequin.lying || !mannequin.lying_prev || json_encode(mannequin.default_transform.tolist()) != lying_transform)
		errors += "Creating an upright portrait mutated the mannequin's pose."
	if(count_emissive_masks(preview.overlays) || count_emissive_masks(preview.underlays))
		errors += "The second preview restored a stale screen mask."
	qdel(mannequin)
	if(length(errors))
		fail(jointext(errors, " "))
		return FALSE
	pass("IPC previews omit lighting masks and normalize pose without changing source appearances or scale.")
	return TRUE

/datum/unit_test/emissive_atm_sign
	name = "RENDERING: EMISSIVE ATM SIGN"

/datum/unit_test/emissive_atm_sign/start_test()
	var/list/errors = list()
	var/turf/test_turf = locate(1, 1, 1)
	var/obj/machinery/atm/terminal = new(test_turf)
	terminal.use_power = NO_POWER_USE
	terminal.power_change()
	terminal.update_icon()
	var/datum/light_source/atm_light = terminal.light
	if(count_atom_emissive_masks(terminal) != 1 || !atm_light || terminal.light_range != MINIMUM_USEFUL_LIGHT_RANGE || terminal.light_power != 1)
		errors += "A powered ATM must have one sign mask and a disposal-sized surrounding light."
	terminal.update_icon()
	terminal.power_change()
	if(terminal.light != atm_light)
		errors += "Updating a powered ATM recreated its light source."
	terminal.abstract_move(null)
	terminal.power_change()
	if(terminal.loc || !(terminal.stat & NOPOWER) || count_atom_emissive_masks(terminal) || terminal.light || terminal.light_range)
		errors += "An ATM retained its sign glow or surrounding light after losing power."
	terminal.forceMove(test_turf)
	terminal.power_change()
	if(count_atom_emissive_masks(terminal) != 1 || !terminal.light || terminal.light_range != MINIMUM_USEFUL_LIGHT_RANGE)
		errors += "Restoring ATM power did not restore its sign glow and surrounding light."
	terminal.stat |= BROKEN
	terminal.update_icon()
	if(count_atom_emissive_masks(terminal) || terminal.light || terminal.light_range)
		errors += "A broken ATM retained its sign glow or surrounding light."
	terminal.stat &= ~BROKEN
	terminal.update_icon()
	terminal.icon_state = "atm_off"
	terminal.update_icon()
	if(count_atom_emissive_masks(terminal) || terminal.light || terminal.light_range)
		errors += "An unlit ATM sign retained its mask or surrounding light."
	terminal.icon_state = "atm"
	terminal.update_icon()
	terminal.icon = 'icons/obj/objects.dmi'
	terminal.update_icon()
	if(count_atom_emissive_masks(terminal) || terminal.light || terminal.light_range)
		errors += "An ATM with a foreign icon retained its mask or surrounding light."
	qdel(terminal)
	if(length(errors))
		fail(jointext(errors, " "))
		return FALSE
	pass("ATM glow and surrounding light follow power, damage and icon changes without recreating an active light source.")
	return TRUE
