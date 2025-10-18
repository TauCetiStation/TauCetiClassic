///Container for client viewsize
/datum/view_data
	/// This client's current "default" view, in the format "WidthxHeight"
	/// We add/remove from this when we want to change their window size
	var/default = ""
	/// The client that owns this view packet
	var/client/chief = null

/datum/view_data/New(client/owner)
	chief = owner
	default = getScreenSize()
	apply()

/datum/view_data/Destroy()
	chief = null
	return ..()

/datum/view_data/proc/setDefault(string)
	if(string == VIEWPORT_USE_PREF)
		default = getScreenSize()
	else
		default = string
	apply()

/datum/view_data/proc/getScreenSize()
	if(chief.prefs.widescreenpref)
		return WIDESCREEN_VIEWPORT_SIZE
	return SQUARE_VIEWPORT_SIZE

/datum/view_data/proc/apply()
	chief?.change_view(getView())
	if(chief?.prefs.auto_fit_viewport)
		chief.fit_viewport()

/datum/view_data/proc/getView()
	var/list/temp = getviewsize(default)
	return "[temp[1]]x[temp[2]]"
