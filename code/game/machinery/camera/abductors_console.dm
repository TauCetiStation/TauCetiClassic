/obj/machinery/computer/camera_advanced/abductor
	name = "Human Observation Console"
	networks = list("SS13", "abductor")
	var/obj/machinery/abductor/console/console
	var/team = 0
	lock_override = CAMERA_LOCK_STATION | CAMERA_LOCK_MINING | CAMERA_LOCK_CENTCOM

	var/datum/action/innate/teleport_in/I = new
	var/datum/action/innate/teleport_out/O = new
	var/datum/action/innate/teleport_self/S = new
	var/datum/action/innate/vest_disguise_swap/D = new
	var/datum/action/innate/set_droppoint/P = new

	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera"

/obj/machinery/computer/camera_advanced/abductor/atom_init()
	. = ..()
	abductor_machinery_list += src
	actions += I
	actions += O
	actions += S
	actions += D
	actions += P
	networks += "Abductor[team]"

/obj/machinery/computer/camera_advanced/abductor/Destroy()
	if(console)
		console.camera = null
		console = null
	abductor_machinery_list -= src
	return ..()

/mob/camera/Eye/remote/abductor
	user_camera_icon = 'icons/obj/abductor.dmi'
	icon_state = "camera_target"

/obj/machinery/computer/camera_advanced/abductor/CreateEye()
	..()
	eyeobj = new /mob/camera/Eye/remote/abductor(get_turf(src))
	eyeobj.origin = src
/datum/action/innate
	action_type = AB_INNATE

/datum/action/innate/teleport_in
///Is the amount of time required between uses
	var/abductor_pad_cooldown = 8 SECONDS
///Is used to compare to world.time in order to determine if the action should early return
	var/use_delay
	name = "Send To"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "beam_down"

/datum/action/innate/teleport_in/Activate()
	if(!target || !iscarbon(owner))
		return
	if(world.time < use_delay)
		to_chat(owner, "<span class='warning'>You must wait [DisplayTimeText(use_delay - world.time)] to use the [target] again!</span>")
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/Eye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/abductor/A = target
	var/obj/machinery/abductor/pad/P = A.console.pad

	if(remote_eye.loc.z in SSmapping.levels_by_trait(ZTRAIT_CENTCOM))
		to_chat(owner, "<span class='warning'>This place is out of bounds of pad' working zone</span>")
		return

	use_delay = (world.time + abductor_pad_cooldown)
	if(cameranet.checkTurfVis(remote_eye.loc))
		P.PadToLoc(remote_eye.loc)

/datum/action/innate/teleport_out
	name = "Retrieve"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "beam_up"

/datum/action/innate/teleport_out/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/computer/camera_advanced/abductor/C = target
	var/obj/machinery/abductor/console/console = C.console

	console.TeleporterRetrieve()

/datum/action/innate/teleport_self
///Is the amount of time required between uses
	var/teleport_self_cooldown = 9 SECONDS
	var/use_delay
	name = "Send Self"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "beam_down"

/datum/action/innate/teleport_self/Activate()
	if(!target || !iscarbon(owner))
		return
	if(world.time < use_delay)
		to_chat(owner, "<span class='warning'>You can only teleport to one place at a time!</span>")
		return
	var/mob/living/carbon/human/C = owner
	var/mob/camera/Eye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/abductor/A = target
	var/obj/machinery/abductor/pad/P = A.console.pad

	if(remote_eye.loc.z in SSmapping.levels_by_trait(ZTRAIT_CENTCOM))
		to_chat(owner, "<span class='warning'>This place is out of bounds of pad' working zone</span>")
		return
	use_delay = (world.time + teleport_self_cooldown)
	if(cameranet.checkTurfVis(remote_eye.loc))
		P.MobToLoc(remote_eye.loc,C)

/datum/action/innate/vest_disguise_swap
	name = "Switch Vest Disguise"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "vest_disguise"

/datum/action/innate/vest_disguise_swap/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/computer/camera_advanced/abductor/C = target
	var/obj/machinery/abductor/console/console = C.console
	console.SelectDisguise()

/datum/action/innate/set_droppoint
	name = "Set Experiment Release Point"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "set_drop"

/datum/action/innate/set_droppoint/Activate()
	if(!target || !iscarbon(owner))
		return

	var/mob/living/carbon/human/H = owner
	var/mob/camera/Eye/remote/remote_eye = H.remote_control

	if(remote_eye.loc.z in SSmapping.levels_by_trait(ZTRAIT_CENTCOM))
		to_chat(owner, "<span class='warning'>This place is out of bounds of pad' working zone</span>")
		return
	var/obj/machinery/computer/camera_advanced/abductor/C = target
	var/obj/machinery/abductor/console/console = C.console
	console.SetDroppoint(get_turf(remote_eye.loc),owner)
