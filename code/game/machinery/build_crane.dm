
/obj/machinery/build_crane
	name = "Build crane"
	icon = 'icons/obj/machines/build_crane.dmi'
	icon_state = "crane_open"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	light_power = 2
	light_range = 3
	layer = TALL_STRUCTURE
	var/datum/action/innate/build_crane/eject/eject_action = new
	var/list/work_sounds = list('sound/mecha/mechmove01.ogg', 'sound/mecha/mechmove03.ogg', 'sound/mecha/mechmove04.ogg')

/obj/machinery/build_crane/update_icon()
	icon_state = "crane[occupant ? "" : "_open"]"

/obj/machinery/build_crane/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if (iswrenching(W) && !user.is_busy())
		if(anchored)
			if(occupant)
				to_chat(user, "<span class='warning'>Внутри кто-то находится!</span>")
				return

			to_chat(user, "<span class='notice'>You begin to unfasten \the [src] from the floor...</span>")
			if(W.use_tool(src, user, 2 SECONDS, volume = 50, quality = QUALITY_WRENCHING))
				user.visible_message( \
					"<span class='notice'>\The [user] unfastens \the [src].</span>", \
					"<span class='notice'>You have unfastened \the [src]. Now it can be pulled somewhere else.</span>", \
					"You hear ratchet.")
				anchored = FALSE
		else
			to_chat(user, "<span class='notice'>You begin to fasten \the [src] to the floor...</span>")
			if(W.use_tool(src, user, 2 SECONDS, volume = 50, quality = QUALITY_WRENCHING))
				user.visible_message( \
					"<span class='notice'>\The [user] fastens \the [src].</span>", \
					"<span class='notice'>You have fastened \the [src]. Now it can dispense pipes.</span>", \
					"You hear ratchet.")
				anchored = TRUE

/obj/machinery/build_crane/MouseDrop_T(mob/target, mob/user)
	if(target != user || !can_move_inside(user))
		return

	visible_message("<span class='notice'>[user] starts to climb into [name]</span>")

	if(do_after(user, 1 SECOND, target = src))
		move_inside(user)

/obj/machinery/build_crane/proc/can_move_inside(mob/user)
	if(!anchored)
		to_chat(user, "<span class='warning'>Кран необходимо закрепить на месте!</span>")
		return FALSE
	if(!ishuman(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(user.buckled)
		to_chat(user, "<span class='warning'>Ты не можешь залезть внутрь будучи пристёгнутым к чему-то!</span>")
		return FALSE
	if(occupant)
		to_chat(user, "<span class='warning'>Внутри уже кто-то сидит!</span>")
		return FALSE
	return TRUE

/obj/machinery/build_crane/proc/move_inside(mob/user)
	if(!can_move_inside(user))
		return

	playsound(src, 'sound/machines/windowdoor.ogg', VOL_EFFECTS_MASTER)
	to_chat(user, "<span class='notice'>\n\
		<------------------------------------------------------------>  \n\
		Вас приветствует руководство по управлению башенным краном!\n\
		ЛКМ			- установка пола\n\
		ЛКМ + шифт	- установка стен\n\
		ЛКМ + ктрл	- очистка территории\n\
		<------------------------------------------------------------></span>")
	user.forceMove(src)
	occupant = user
	occupant.reset_view(src, force_remote_viewing = TRUE)
	occupant.client.click_intercept = src
	occupant.client.change_view(12)
	eject_action.Grant(occupant, src)
	update_icon()

/obj/machinery/build_crane/proc/go_out()
	if(!occupant)
		return

	playsound(src, 'sound/mecha/mech_eject.ogg', VOL_EFFECTS_MASTER, 75, FALSE, null, -3)
	occupant.forceMove(loc)
	occupant.reset_view(null, force_remote_viewing = FALSE)
	occupant.client.click_intercept = null
	occupant.client.change_view(world.view)
	eject_action.Remove(occupant)
	occupant = null
	update_icon()


/obj/machinery/build_crane/proc/InterceptClickOn(mob/user, params, atom/object)
	var/list/modifiers = params2list(params)

	var/left_click   = LAZYACCESS(modifiers, LEFT_CLICK)
	var/ctrl_click   = LAZYACCESS(modifiers, CTRL_CLICK)
	var/shift_click  = LAZYACCESS(modifiers, SHIFT_CLICK)

	var/turf/T = get_turf(object)

	if(left_click)
		for(var/obj/structure/flora/F in T.contents)
			qdel(F)

		if(ctrl_click)
			T.ChangeTurf(/turf/environment)
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER, 50)
		else
			playsound(src, pick(work_sounds), VOL_EFFECTS_MASTER, 50)
			if(shift_click)
				T.ChangeTurf(/turf/simulated/wall)
			else
				T.ChangeTurf(/turf/simulated/floor/plating)

	return TRUE


/datum/action/innate/build_crane
	name = "Crane action"
	button_icon = 'icons/hud/actions_mecha.dmi'
	check_flags = AB_CHECK_INCAPACITATED
	action_type = AB_INNATE
	var/obj/machinery/build_crane/crane

/datum/action/innate/build_crane/Grant(mob/M, obj/machinery/build_crane/BC)
	crane  = BC
	target = M
	. = ..()

/datum/action/innate/build_crane/Destroy()
	. = ..()
	crane = null

/datum/action/innate/build_crane/Checks()
	. = ..()
	if(!crane)
		return FALSE
	if(crane.occupant != owner)
		return FALSE

/datum/action/innate/build_crane/eject
	name = "Покинуть Кран"
	button_icon_state = "mech_eject"

/datum/action/innate/build_crane/eject/Activate()
	if(Checks())
		crane.go_out()
