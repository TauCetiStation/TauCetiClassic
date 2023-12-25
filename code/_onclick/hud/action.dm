#define AB_ITEM 1
#define AB_SPELL 2
#define AB_INNATE 3
#define AB_GENERIC 4

#define AB_CHECK_INCAPACITATED 2
#define AB_CHECK_ALIVE 4
#define AB_CHECK_INSIDE 8
#define AB_CHECK_ACTIVE 16


/datum/action
	var/name = "Generic Action"
	var/action_type = AB_ITEM
	var/atom/movable/target = null
	var/check_flags = 0
	var/restrained_check = ARMS // for AB_CHECK_INCAPACITATED
	var/processing = 0
	var/active = 0
	var/atom/movable/screen/movable/action_button/button = null
	var/button_icon = 'icons/hud/actions.dmi'
	var/button_icon_state = "default"
	var/background_icon_state = "bg_default"
	var/transparent_when_unavailable = TRUE
	var/mob/owner

/datum/action/New(Target)
	target = Target
	button = new
	button.owner = src
	button.name = name

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	target = null
	QDEL_NULL(button)
	return ..()

/datum/action/proc/Grant(mob/T)
	if(owner)
		if(owner == T)
			return
		Remove(owner)
	owner = T
	owner.actions.Add(src)
	owner.update_action_buttons()
	return

/datum/action/proc/Remove(mob/T)
	if(button)
		if(T.client)
			T.client.screen -= button
	T.actions.Remove(src)
	T.update_action_buttons()
	owner = null
	return

/datum/action/proc/Trigger()
	if(!Checks())
		return
	switch(action_type)
		if(AB_ITEM)
			Activate()
		if(AB_SPELL)
			if(target)
				var/obj/effect/proc_holder/spell = target
				spell.Click()
		if(AB_INNATE)
			if(!active)
				Activate()
			else
				Deactivate()
	if(!owner)
		return
	if(button == null)
		var/atom/movable/screen/movable/action_button/N = new(owner.hud_used)
		N.owner = src.owner
		button = N
	button.UpdateIcon()
	return

/datum/action/proc/Activate()
	return

/datum/action/proc/Deactivate()
	return

/datum/action/proc/CheckRemoval(mob/user) // TRUE if action is no longer valid for this mob and should be removed
	return FALSE

/datum/action/proc/IsAvailable()
	return Checks()

/datum/action/proc/UpdateButtonIcon(status_only = FALSE, force = FALSE)
	if(button)
		if(!IsAvailable())
			button.color = transparent_when_unavailable ? rgb(128,0,0,128) : rgb(128,0,0)
		else
			button.color = rgb(255,255,255,255)

/atom/movable/screen/movable/action_button/MouseEntered(location,control,params)
	openToolTip(usr, src, params, title = name, content = desc)

/atom/movable/screen/movable/action_button/MouseExited()
	closeToolTip(usr)

/// returns 1 if all checks pass
/datum/action/proc/Checks()
	if(!owner)
		return FALSE
	if(check_flags & AB_CHECK_INCAPACITATED)
		if(owner.incapacitated(restrained_check))
			return FALSE
	if(check_flags & AB_CHECK_ALIVE)
		if(owner.stat != CONSCIOUS)
			return FALSE
	if(check_flags & AB_CHECK_INSIDE)
		if(!(target in owner))
			return FALSE
	if(check_flags & AB_CHECK_ACTIVE)
		if(owner.get_active_hand() != target)
			return FALSE
	return TRUE

/datum/action/proc/UpdateName()
	return name

//Preset for an action with a cooldown
/datum/action/cooldown
	action_type = AB_GENERIC
	check_flags = NONE
	transparent_when_unavailable = FALSE
	var/cooldown_time = 0
	var/next_use_time = 0

/datum/action/cooldown/New()
	..()
	button.maptext = ""
	button.maptext_x = 8
	button.maptext_y = 0
	button.maptext_width = 24
	button.maptext_height = 12

/datum/action/cooldown/IsAvailable()
	return next_use_time <= world.time

/datum/action/cooldown/proc/StartCooldown()
	next_use_time = world.time + cooldown_time
	button.maptext = MAPTEXT("<b>[round(cooldown_time/10, 0.1)]</b>")
	UpdateButtonIcon()
	START_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/process()
	if(!owner)
		button.maptext = ""
		STOP_PROCESSING(SSfastprocess, src)
	var/timeleft = max(next_use_time - world.time, 0)
	if(timeleft == 0)
		button.maptext = ""
		UpdateButtonIcon()
		STOP_PROCESSING(SSfastprocess, src)
	else
		button.maptext = MAPTEXT("<b>[round(timeleft/10, 0.1)]</b>")

/datum/action/cooldown/Grant(mob/M)
	..()
	if(owner)
		UpdateButtonIcon()
		if(next_use_time > world.time)
			START_PROCESSING(SSfastprocess, src)

/atom/movable/screen/movable/action_button
	var/datum/action/owner
	screen_loc = "WEST,NORTH"

/atom/movable/screen/movable/action_button/Destroy()
	owner = null
	return ..()

/atom/movable/screen/movable/action_button/Click(location,control,params)
	var/list/modifiers = params2list(params)
	if(modifiers[SHIFT_CLICK])
		moved = 0
		return TRUE
	if(usr.next_move >= world.time) // Is this needed ?
		return
	owner.Trigger()
	return TRUE

/atom/movable/screen/movable/action_button/proc/UpdateIcon()
	if(!owner)
		return
	icon = owner.button_icon
	icon_state = owner.background_icon_state

	cut_overlays()
	var/image/img
	if(owner.action_type == AB_ITEM && owner.target)
		var/obj/item/I = owner.target
		img = image(I.icon, src , I.icon_state)
	else if(owner.button_icon && owner.button_icon_state)
		img = image(owner.button_icon,src,owner.button_icon_state)

	img.pixel_x = 0
	img.pixel_y = 0
	add_overlay(img)

	if(!owner.IsAvailable())
		color = rgb(128,0,0,128)
	else
		color = rgb(255,255,255,255)

//Hide/Show Action Buttons ... Button
/atom/movable/screen/movable/action_button/hide_toggle
	name = "Hide Buttons"
	icon = 'icons/hud/actions.dmi'
	icon_state = "bg_default"
	var/hidden = 0

/atom/movable/screen/movable/action_button/hide_toggle/Click()
	usr.hud_used.action_buttons_hidden = !usr.hud_used.action_buttons_hidden

	hidden = usr.hud_used.action_buttons_hidden
	if(hidden)
		name = "Show Buttons"
	else
		name = "Hide Buttons"
	UpdateIcon()
	usr.update_action_buttons()

/atom/movable/screen/movable/action_button/hide_toggle/proc/InitialiseIcon(mob/user)
	if(isxeno(user))
		icon_state = "bg_alien"
	else
		icon_state = "bg_default"
	UpdateIcon()
	return

/atom/movable/screen/movable/action_button/hide_toggle/UpdateIcon()
	cut_overlays()
	var/image/img = image(icon,src,hidden?"show":"hide")
	add_overlay(img)
	return

//This is the proc used to update all the action buttons. Properly defined in /mob/living
/mob/proc/update_action_buttons()
	return

#define AB_WEST_OFFSET 4
#define AB_NORTH_OFFSET 26
#define AB_MAX_COLUMNS 10

/mob/proc/update_sight()
	SHOULD_CALL_PARENT(TRUE)
	if(!client)
		return FALSE

	sync_lighting_plane_alpha()

	if(stat == DEAD)
		sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
		set_EyesVision(null)
		return FALSE

	return TRUE

///Set the lighting plane hud alpha to the mobs lighting_alpha var
/mob/proc/sync_lighting_plane_alpha()
	if(hud_used)
		var/atom/movable/screen/plane_master/lighting/L = hud_used.plane_masters["[LIGHTING_PLANE]"]
		if(L)
			L.alpha = lighting_alpha

/datum/hud/proc/ButtonNumberToScreenCoords(number) // TODO : Make this zero-indexed for readabilty
	var/row = round((number-1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1
	var/coord_col = "+[col-1]"
	var/coord_col_offset = AB_WEST_OFFSET+2*col
	var/coord_row = "[-1 - row]"
	var/coord_row_offset = AB_NORTH_OFFSET
	return "WEST[coord_col]:[coord_col_offset],NORTH[coord_row]:[coord_row_offset]"

/datum/hud/proc/SetButtonCoords(atom/movable/screen/button,number)
	var/row = round((number-1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1
	var/x_offset = 32*(col-1) + AB_WEST_OFFSET + 2*col
	var/y_offset = -32*(row+1) + AB_NORTH_OFFSET

	var/matrix/M = matrix()
	M.Translate(x_offset,y_offset)
	button.transform = M

//Presets for item actions
/datum/action/item_action
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_INSIDE

/datum/action/item_action/Activate()
	var/obj/item/I = target
	I.attack_self(usr)

/datum/action/item_action/IsAvailable()
	return TRUE

/datum/action/item_action/CheckRemoval(mob/user)
	return !(target in user)

/datum/action/item_action/hands_free
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_INSIDE|AB_CHECK_ALIVE


//Preset for spells
/datum/action/spell_action
	action_type = AB_SPELL
	check_flags = 0
	background_icon_state = "bg_spell"

/datum/action/spell_action/Grant(mob/T)
	. = ..()
	if(istype(target, /obj/effect/proc_holder/spell))
		var/obj/effect/proc_holder/spell/S = target
		if(S.charge_max < 1)
			START_PROCESSING(SSaction_buttons, src)

/datum/action/spell_action/process()
	UpdateButtonIcon()

/datum/action/spell_action/UpdateName()
	var/obj/effect/proc_holder/spell/spell = target
	return spell.name

/datum/action/spell_action/IsAvailable()
	if(!target)
		return FALSE
	var/obj/effect/proc_holder/spell/spell = target

	if(usr)
		return spell.can_cast(usr)
	else if(owner)
		return spell.can_cast(owner)
	return TRUE

/datum/action/spell_action/CheckRemoval()
	if(owner.mind)
		if(target in owner.mind.spell_list)
			return FALSE
	return !(target in owner.spell_list)

#undef AB_WEST_OFFSET
#undef AB_NORTH_OFFSET
#undef AB_MAX_COLUMNS
