#define PROGRESSBAR_HEIGHT 6

/datum/progressbar
	var/goal = 1
	var/image/bar
	var/shown = 0
	var/mob/user
	var/client/client
	var/bar_icon_state = "prog_bar"
	var/listindex

	var/visible = TRUE

/datum/progressbar/New(mob/User, goal_number, atom/target, my_icon_state="prog_bar", insert_under=FALSE, visible=TRUE)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given")
	if (goal_number)
		goal = goal_number
	bar_icon_state = my_icon_state

	bar = image('icons/effects/progessbar.dmi', target, "[bar_icon_state]_0")
	bar.plane = ABOVE_HUD_PLANE
	bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	bar.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	LAZYINITLIST(User.progressbars)
	LAZYINITLIST(User.progressbars[bar.loc])

	var/list/bars = User.progressbars[bar.loc]
	if(insert_under)
		for(var/datum/progressbar/B in bars)
			B.shiftUp()
		bars.Add(src)
		listindex = 1
	else
		bars.Add(src)
		listindex = bars.len

	bar.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1))

	src.visible = visible

	user = User
	if(user && src.visible)
		client = user.client
		if(client)
			client.images += bar

/datum/progressbar/proc/shiftUp()
	++listindex
	bar.pixel_y += PROGRESSBAR_HEIGHT

/datum/progressbar/proc/shiftDown()
	--listindex
	bar.pixel_y -= PROGRESSBAR_HEIGHT

/datum/progressbar/proc/update(progress)
	//world << "Update [progress] - [goal] - [(progress / goal)] - [((progress / goal) * 100)] - [round(((progress / goal) * 100), 5)]"
	if (!user || !user.client)
		shown = 0
		return
	if (user.client != client)
		if (client)
			client.images -= bar
		if (user.client && visible)
			user.client.images += bar

	progress = clamp(progress, 0, goal)
	bar.icon_state = "[bar_icon_state]_[round(((progress / goal) * 100), 5)]"
	if (!shown && visible)
		user.client.images += bar
		shown = 1

/datum/progressbar/Destroy()
	for(var/I in user.progressbars[bar.loc])
		var/datum/progressbar/P = I
		if(P != src && P.listindex > listindex)
			P.shiftDown()

	var/list/bars = user.progressbars[bar.loc]
	bars.Remove(src)
	if(!bars.len)
		LAZYREMOVE(user.progressbars, bar.loc)

	user = null
	if (client)
		client.images -= bar

	QDEL_NULL(bar)
	. = ..()

#undef PROGRESSBAR_HEIGHT





















#define PROGRESSBAR_HEIGHT 6

/datum/skillcheck
	var/mob/user
	var/client/client
	var/progress = 0
	var/step = 1 //Step of SC by one proccess
	var/goal = 1 //1 - Right, -1 - Left
	var/win_condition_zone = 20 //Width of win zone we need to hit

	var/win_condition_start //Where STARTS win-zone in percents of body
	var/win_condition_end // Where ENDS win-zone in percents of body

	var/image/bar //Body
	var/image/cursor //Moving cursor
	var/image/overlay //Zone of success

	var/result = FALSE

/datum/skillcheck/New(mob/User, goal_number, atom/target, insert_under=FALSE, visible=TRUE)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given")

	bar = image('icons/effects/64x64.dmi', target, "skillcheck_body", pixel_x = -16)
	bar.plane = ABOVE_HUD_PLANE + 0.01
	bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	bar.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	overlay = image('icons/effects/64x64.dmi', target, "skillcheck_overlay", pixel_x = -16)
	overlay.plane = ABOVE_HUD_PLANE + 0.02
	overlay.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/matrix/M = matrix()
	M.Scale(win_condition_zone, 1)
	overlay.transform = M
	win_condition_start = rand(0, 100 - win_condition_zone)
	overlay.pixel_x += win_condition_start
	win_condition_end = win_condition_start + win_condition_zone

	cursor = image('icons/effects/64x64.dmi', target, "skillcheck_cursor", pixel_x = -16)
	cursor.plane = ABOVE_HUD_PLANE + 0.03
	cursor.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	cursor.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	LAZYINITLIST(User.progressbars)
	LAZYINITLIST(User.progressbars[bar.loc])

	var/list/bars = User.progressbars[bar.loc]
	bar.pixel_y = 32 + (PROGRESSBAR_HEIGHT * 2 * (max(1, length(bars) - 1)) + PROGRESSBAR_HEIGHT * 2)


	user = User
	if(user)
		client = user.client
		if(client)
			client.images += bar

	RegisterSignal(user, list(COMSIG_CLICK), PROC_REF(register_result))

/datum/skillcheck/proc/register_result()
	SIGNAL_HANDLER
	if(progress > win_condition_start && progress < win_condition_end)
		result = TRUE
	return COMPONENT_CANCEL_CLICK

/datum/skillcheck/proc/update()
	if (user.client != client)
		if (client)
			client.images -= bar
			client.images -= overlay
			client.images -= cursor
		if (user.client)
			user.client.images += bar
			client.images += overlay
			client.images += cursor

	if(QDELETED(user) || user.incapacitated(NONE))
		qdel(src)

	if(progress >= 100)
		goal = -1
	else if(progress <= 0)
		goal = 1

	var/progress_current = step * goal
	cursor.pixel_x += progress_current
	progress = progress_current

/datum/skillcheck/Destroy()

	var/list/bars = user.progressbars[bar.loc]
	bars.Remove(src)
	if(!bars.len)
		LAZYREMOVE(user.progressbars, bar.loc)

	user = null
	if (client)
		client.images -= bar
		client.images -= overlay
		client.images -= cursor

	QDEL_NULL(bar)
	QDEL_NULL(overlay)
	QDEL_NULL(cursor)
	. = ..()

