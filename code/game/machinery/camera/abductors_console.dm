/obj/machinery/computer/camera_advanced/abductor
	name = "Human Observation Console"
	//var/team_number = 0
	networks = list("SS13", "abductor")
	var/obj/machinery/abductor/console/console
	/// We can't create our actions until after LateInitialize
	/// So we instead do it on the first call to GrantActions
	//var/abduct_created = FALSE
	var/team = 0
	lock_override = CAMERA_LOCK_STATION | CAMERA_LOCK_MINING | CAMERA_LOCK_CENTCOM

	var/datum/action/innate/teleport_in/I = new
	var/datum/action/innate/teleport_out/O = new
	var/datum/action/innate/teleport_self/S = new
	var/datum/action/innate/vest_mode_swap/M = new
	var/datum/action/innate/vest_disguise_swap/D = new
	var/datum/action/innate/set_droppoint/P = new

	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera"
	//icon_keyboard = null
	//resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/computer/camera_advanced/abductor/atom_init()
	. = ..()
	abductor_machinery_list += src
	/*actions += new I (console.pad)
	actions += new O (console)
	actions += new S (console.pad)
	actions += new M (console)
	actions += new D (console)
	actions += new P (console)*/
	actions += I
	actions += O
	actions += S
	actions += M
	actions += D
	actions += P
	networks += "Abductor[team]"
	/*actions += new /datum/action/innate/teleport_in(console.pad)
	actions += new /datum/action/innate/teleport_out(console)
	actions += new /datum/action/innate/teleport_self(console.pad)
	actions += new /datum/action/innate/vest_mode_swap(console)
	actions += new /datum/action/innate/vest_disguise_swap(console)
	actions += new /datum/action/innate/set_droppoint(console)
*/
/obj/machinery/computer/camera_advanced/abductor/Destroy()
	if(console)
		console.camera = null
		console = null
	abductor_machinery_list -= src
	return ..()

/mob/camera/Eye/remote/abductor
	user_camera_icon = 'icons/obj/abductor.dmi'
	icon_state = "camera_target"

/*/obj/machinery/computer/camera_advanced/abductor/GrantActions(mob/living/user)
	for(var/datum/action/to_grant as anything in actions)
		to_grant.target = console
		to_grant.Grant(user)
*/
/obj/machinery/computer/camera_advanced/abductor/CreateEye()
	..()
	eyeobj = new /mob/camera/Eye/remote/abductor(get_turf(src))
	eyeobj.origin = src
	/*//eyeobj.visible_icon = TRUE
	eyeobj.user_camera_icon = 'icons/obj/abductor.dmi'
	eyeobj.icon_state = "camera_target"
	//eyeobj.invisibility = INVISIBILITY_OBSERVER
*/
/*/obj/machinery/computer/camera_advanced/abductor/GrantActions(mob/living/carbon/user)
	if(!abduct_created)
		abduct_created = TRUE
		actions += new (console.pad)
		actions += new (console.pad)
		actions += new (console.pad)
		actions += new (console.pad)
		actions += new (console.pad)
		actions += new (console.pad)
	..()
*/
/datum/action/innate
	action_type = AB_INNATE

/datum/action/innate/teleport_in
///Is the amount of time required between uses
	var/abductor_pad_cooldown = 8 SECONDS
///Is used to compare to world.time in order to determine if the action should early return
	var/use_delay
	name = "Send To"
	button_icon = 'icons/mob/actions.dmi'
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

	/*var/area/target_area = get_area(remote_eye)
	if(target_area.area_flags & ABDUCTOR_PROOF)
		to_chat(owner, "<span class='warning'>This area is too heavily shielded to safely transport to.</span>")
		return*/
	if(remote_eye.loc.z in SSmapping.levels_by_trait(ZTRAIT_CENTCOM))
		to_chat(owner, "<span class='warning'>This place is out of bounds of pad' working zone</span>")
		return

	use_delay = (world.time + abductor_pad_cooldown)
	if(cameranet.checkTurfVis(remote_eye.loc))
		P.PadToLoc(remote_eye.loc)

/datum/action/innate/teleport_out
	name = "Retrieve"
	button_icon = 'icons/mob/actions.dmi'
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
	button_icon = 'icons/mob/actions.dmi'
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

	/*var/area/target_area = get_area(remote_eye)
	if(target_area.area_flags & ABDUCTOR_PROOF)
		to_chat(owner, "<span class='warning'>This area is too heavily shielded to safely transport to.</span>")
		return*/
	if(remote_eye.loc.z in SSmapping.levels_by_trait(ZTRAIT_CENTCOM))
		to_chat(owner, "<span class='warning'>This place is out of bounds of pad' working zone</span>")
		return
	use_delay = (world.time + teleport_self_cooldown)
	if(cameranet.checkTurfVis(remote_eye.loc))
		P.MobToLoc(remote_eye.loc,C)

/datum/action/innate/vest_mode_swap
	name = "Switch Vest Mode"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "vest_mode"

/datum/action/innate/vest_mode_swap/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/computer/camera_advanced/abductor/C = target
	var/obj/machinery/abductor/console/console = C.console
	console.FlipVest()


/datum/action/innate/vest_disguise_swap
	name = "Switch Vest Disguise"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "vest_disguise"

/datum/action/innate/vest_disguise_swap/Activate()
	if(!target || !iscarbon(owner))
		return
	var/obj/machinery/computer/camera_advanced/abductor/C = target
	var/obj/machinery/abductor/console/console = C.console
	console.SelectDisguise()

/datum/action/innate/set_droppoint
	name = "Set Experiment Release Point"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "set_drop"

/datum/action/innate/set_droppoint/Activate()
	if(!target || !iscarbon(owner))
		return

	var/mob/living/carbon/human/C = owner
	var/mob/camera/Eye/remote/remote_eye = C.remote_control

	if(remote_eye.loc.z in SSmapping.levels_by_trait(ZTRAIT_CENTCOM))
		to_chat(owner, "<span class='warning'>This place is out of bounds of pad' working zone</span>")
		return

	var/obj/machinery/abductor/console/console = target
	console.SetDroppoint(remote_eye.loc,owner)
