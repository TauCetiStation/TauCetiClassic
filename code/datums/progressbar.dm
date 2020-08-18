#define PROGRESSBAR_HEIGHT 6

/datum/progressbar
	var/goal = 1
	var/image/bar
	var/shown = 0
	var/mob/user
	var/client/client
	var/bar_icon_state = "prog_bar"
	var/listindex

/datum/progressbar/New(mob/User, goal_number, atom/target, my_icon_state="prog_bar", insert_under=FALSE)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given")
	if (goal_number)
		goal = goal_number
	bar_icon_state = my_icon_state

	bar = image('icons/effects/progessbar.dmi', target, "[bar_icon_state]_0")
	bar.layer = ABOVE_HUD_LAYER
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

	user = User
	if(user)
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
		if (user.client)
			user.client.images += bar

	progress = clamp(progress, 0, goal)
	bar.icon_state = "[bar_icon_state]_[round(((progress / goal) * 100), 5)]"
	if (!shown)
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

	if (client)
		client.images -= bar

	QDEL_NULL(bar)
	. = ..()

#undef PROGRESSBAR_HEIGHT
