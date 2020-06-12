/datum/preferences/proc/ShowQuirks(mob/user)
	if(!SSquirks)
		to_chat(user, "<span class='danger'>The quirk subsystem is still initializing! Try again in a minute.</span>")
		return

	if(!SSquirks.initialized)
		to_chat(user, "The quirk subsystem hasn't finished initializing, please hold...")
		return

	. += "<center><b>Choose quirk setup</b></center>"
	. += "<div align='center'>Left-click to add or remove quirks. You need one negative quirk for every positive quirk.<br>"
	. += "Quirks are applied at roundstart and cannot normally be removed.</div>"
	. += "<hr>"
	. += "<center><b>Current quirks:</b> [all_quirks.len ? all_quirks.Join(", ") : "None"]</center>"
	. += "<center>[all_quirks.len] / [MAX_QUIRKS] max quirks<br>"
	. += "<b>Quirk balance remaining:</b> [GetQuirkBalance()]<br>"
	. += "<a href='?_src_=prefs;preference=quirk;task=reset'>Reset Quirks</a></center>"
	. += "<table bgcolor='#ffeef0' align='center' width='570px' cellspacing='0'>"
	for(var/Q in allowed_quirks)
		var/datum/quirk/T = SSquirks.quirks[Q]
		var/quirk_name = initial(T.name)
		var/has_quirk
		var/quirk_cost = initial(T.value) * -1
		var/lock_reason = "This quirk is unavailable."
		var/quirk_conflict = FALSE

		for(var/_V in all_quirks)
			if(_V == quirk_name)
				has_quirk = TRUE
		if(has_quirk)
			if(quirk_conflict)
				all_quirks -= quirk_name
				has_quirk = FALSE
			else
				quirk_cost *= -1 //invert it back, since we'd be regaining this amount

		if(quirk_cost > 0)
			quirk_cost = "+[quirk_cost]"
		var/font_color = "#4949b5"
		if(initial(T.value) != 0)
			font_color = initial(T.value) > 0 ? "#007400" : "#690000"
		if(quirk_conflict)
			. += "<tr style='vertical-align:top'><td width=15%><b>[quirk_name]</b></td>"
			. += "<td nowrap style='vertical-align:top'><font color='red'><b>LOCKED</b></font></td>"
			. += "<td><font size=2><font color='red'>[lock_reason]</font></font></td>"
		else
			. += "<tr style='vertical-align:top'><td width=15%><a href='?_src_=prefs;preference=quirk;task=update;quirk=[quirk_name]' style='color: [has_quirk ? "silver" : font_color];'><b>[quirk_name]</b></a></td>"
			. += "<td nowrap style='vertical-align:top'>[quirk_cost] pts.</a></td>"
			. += "<td><font size=2><i>[initial(T.desc)]</i></font></td>"
			. += "</tr>"
	. += "</table>"

/// Is the quirk even hypothetically allowed for this pref. Checks for species blacklist.
/// This proc is "low-level", don't pass user input quirk in it, use CanHaveQuirk.
/datum/preferences/proc/IsAllowedQuirk(quirk_name)
	if(SSquirks.quirk_blacklist_species[quirk_name] && (species in SSquirks.quirk_blacklist_species[quirk_name]))
		return FALSE

	return TRUE

/// Is the quirk allowed for the pref with some number of quirks.
/// This proc also does quirk-subsystem related checks to ensure that user input isn't bullshit.
/datum/preferences/proc/CanHaveQuirk(mob/user, quirk_name, show_warning = TRUE)
	if(!SSquirks)
		if(show_warning)
			to_chat(user, "<span class='danger'>The quirk subsystem is still initializing! Try again in a minute.</span>")
		return FALSE

	if(!SSquirks.initialized)
		if(show_warning)
			to_chat(user, "The quirk subsystem hasn't finished initializing, please hold...")
		return FALSE

	if(!SSquirks.quirks[quirk_name])
		return FALSE

	for(var/V in SSquirks.quirk_blacklist) //V is a list
		var/list/L = V
		for(var/Q in all_quirks)
			//two quirks have lined up in the list of the list of quirks that conflict with each other, so return (see quirks.dm for more details)
			if((quirk_name in L) && (Q in L) && !(Q == quirk_name))
				if(user && show_warning)
					to_chat(user, "<span class='danger'>[quirk_name] is incompatible with [Q].</span>")
				return FALSE

	// If the quirk isn't even hypothetically allowed, pref can't have it.
	// If IsAllowedQuirk() for some reason ever becomes more computationally
	// difficult than (quirk_name in allowed_quirks), please change to the latter. ~Luduk
	return IsAllowedQuirk(quirk_name)

/datum/preferences/proc/UpdateAllowedQuirks()
	if(!SSquirks)
		return

	if(!SSquirks.initialized)
		return

	allowed_quirks = list()

	for(var/quirk_name in SSquirks.quirks)
		if(IsAllowedQuirk(quirk_name))
			allowed_quirks += quirk_name

/datum/preferences/proc/GetQuirkBalance()
	var/bal = 0
	for(var/V in all_quirks)
		var/datum/quirk/T = SSquirks.quirks[V]
		bal -= initial(T.value)
	return bal

/datum/preferences/proc/ResetQuirks()
	all_quirks = list()
	positive_quirks = list()
	negative_quirks = list()
	neutral_quirks = list()

/datum/preferences/proc/process_link_quirks(mob/user, list/href_list)
	switch(href_list["task"])
		if("update")
			var/quirk = href_list["quirk"]
			if(!CanHaveQuirk(user, quirk))
				return

			var/value = SSquirks.quirk_points[quirk]
			if(value == 0)
				if(quirk in neutral_quirks)
					neutral_quirks -= quirk
					all_quirks -= quirk
				else
					if(all_quirks.len >= MAX_QUIRKS)
						to_chat(user, "<span class='warning'>You can't have more than [MAX_QUIRKS] quirks!</span>")
						return
					neutral_quirks += quirk
					all_quirks += quirk
			else
				var/balance = GetQuirkBalance()
				if(quirk in positive_quirks)
					positive_quirks -= quirk
					all_quirks -= quirk
				else if(quirk in negative_quirks)
					if(balance + value < 0)
						to_chat(user, "<span class='warning'>Refunding this would cause you to go below your balance!</span>")
						return
					negative_quirks -= quirk
					all_quirks -= quirk
				else if(value > 0)
					if(all_quirks.len >= MAX_QUIRKS)
						to_chat(user, "<span class='warning'>You can't have more than [MAX_QUIRKS] quirks!</span>")
						return
					if(balance - value < 0)
						to_chat(user, "<span class='warning'>You don't have enough balance to gain this quirk!</span>")
						return
					positive_quirks += quirk
					all_quirks += quirk
				else
					if(all_quirks.len >= MAX_QUIRKS)
						to_chat(user, "<span class='warning'>You can't have more than [MAX_QUIRKS] quirks!</span>")
						return
					negative_quirks += quirk
					all_quirks += quirk
		if("reset")
			ResetQuirks()

	ShowChoices(user)
