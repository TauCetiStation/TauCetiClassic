/datum/browser
	var/client/user
	var/title
	var/window_id // window_id is used as the window name for browse and onclose
	var/width
	var/height
	var/atom/ref
	var/theme // CSS_THEME_DARK or CSS_THEME_LIGHT
	var/window_options = "focus=0;can_close=1;can_minimize=1;can_maximize=0;titlebar=1;can_resize=1;" // window option is set using window_id
	var/stylesheets[0]
	var/scripts[0]
	var/head_content
	var/content

/datum/browser/New(nuser, nwindow_id, ntitle, nwidth, nheight, atom/nref, ntheme = CSS_THEME_DARK)
	if(ismob(nuser))
		var/mob/M = nuser
		nuser = M.client

	user = nuser
	LAZYSET(user.browsers, nwindow_id, src)
	window_id = nwindow_id
	if(ntitle)
		title = capitalize(ntitle)
	if(nwidth && nheight)
		width = nwidth
		height = nheight
	if(nref)
		ref = nref
	if(ntheme)
		theme = ntheme

	add_stylesheet("common", 'html/browser/common.css') // this CSS sheet is common to all UIs
	add_stylesheet("font-awesome.css", 'html/font-awesome/css/all.min.css')

/datum/browser/Destroy()
	LAZYREMOVE(user.browsers, window_id)
	return ..()

/datum/browser/proc/add_head_content(nhead_content)
	head_content = nhead_content

/datum/browser/proc/set_window_options(nwindow_options)
	window_options = nwindow_options

/datum/browser/proc/add_stylesheet(name, file)
	if(istype(name, /datum/asset/spritesheet))
		var/datum/asset/spritesheet/sheet = name
		stylesheets += "spritesheet_[sheet.name].css"
	else
		var/asset_name = "[name].css"
		stylesheets[asset_name] = file
		if(!SSassets.cache[asset_name])
			register_asset(asset_name, file)

/datum/browser/proc/add_script(name, file)
	scripts["[ckey(name)].js"] = file
	register_asset("[ckey(name)].js", file)

/datum/browser/proc/set_content(ncontent)
	content = ncontent

/datum/browser/proc/add_content(ncontent)
	content += ncontent

/datum/browser/proc/get_content()
	for(var/name in stylesheets)
		head_content += "<link rel='stylesheet' type='text/css' href='[name]'>"

	//should be first
	head_content += "<script type='text/javascript' src='error_handler.js'></script>"
	head_content += "<script type='text/javascript'>var triggerError = attachErrorHandler('browser', true);</script>"

	for(var/name in scripts)
		head_content += "<script type='text/javascript' src='[name]'></script>"

	return {"<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		[head_content]
	</head>
	<body scroll=auto class='[theme]'>
		<div class='uiWrapper'>
			[title ? "<div class='uiTitleWrapper'><div class='uiTitle'>[title]</div></div>" : ""]
			<div class='uiContent'>
				[content]
			</div>
		</div>
	</body>
</html>"}

/datum/browser/proc/open()
	var/window_size
	if(width && height)
		window_size = "size=[width]x[height];"
	var/datum/asset/error_handler_js = get_asset_datum(/datum/asset/simple/error_handler_js) // error_handler - same name as in other places, add_script do ckey with names.
	error_handler_js.send(user)
	if(stylesheets.len)
		send_asset_list(user, stylesheets)
	if(scripts.len)
		send_asset_list(user, scripts)
	user << browse(get_content(), "window=[window_id];[window_size][window_options]")
	winset(user, "mapwindow.map", "focus=true") // return keyboard focus to map
	onclose(user, window_id, ref)

/datum/browser/proc/close()
	user << browse(null, "window=[window_id]")

/// A proc for all the required Topic() checks here.
/datum/browser/proc/can_interact(client/C)
	// Somebody else is trying to access our browser!
	return C == user

/// Basically, a Topic call, but with can_interact checks done beforehand.
/datum/browser/proc/on_interact(href, list/href_list)
	return

/// A wrapper to perform interaction checks.
/datum/browser/Topic(href, list/href_list)
	if(!can_interact(usr.client))
		return

	return on_interact(href, href_list)



/datum/browser/modal
	var/opentime = 0
	var/timeout
	var/selectedbutton = 0
	var/stealfocus

/datum/browser/modal/New(nuser, nwindow_id, ntitle = 0, nwidth = 0, nheight = 0, atom/nref = null, StealFocus = TRUE, Timeout = 6000)
	..()
	stealfocus = StealFocus
	if(!StealFocus)
		window_options += "focus=false;"
	timeout = Timeout

/datum/browser/modal/close()
	. = ..()
	opentime = 0

/datum/browser/modal/open()
	set waitfor = 0
	opentime = world.time

	if(stealfocus)
		. = ..()
	else
		var/focusedwindow = winget(user, null, "focus")
		. = ..()

		//waits for the window to show up client side before attempting to un-focus it
		//winexists sleeps until it gets a reply from the client, so we don't need to bother sleeping
		for(var/i in 1 to 10)
			if(user && winexists(user, window_id))
				if(focusedwindow)
					winset(user, focusedwindow, "focus=true")
				else
					winset(user, "mapwindow", "focus=true")
				break
	if(timeout)
		addtimer(CALLBACK(src, PROC_REF(close)), timeout)

/datum/browser/modal/proc/wait()
	while (opentime && selectedbutton <= 0 && (!timeout || opentime+timeout > world.time))
		stoplag(1)



/datum/browser/modal/listpicker
	var/valueslist = list()

/datum/browser/modal/listpicker/New(User, Message, Title, Button1 = "Ok", Button2, Button3, StealFocus = 1, Timeout = FALSE, list/values, inputtype = "checkbox", width, height, slidecolor)
	if(!User)
		return

	var/output = {"<form><input type="hidden" name="src" value="\ref[src]"><ul class="sparse">"}
	if(inputtype == "checkbox" || inputtype == "radio")
		for(var/i in values)
			var/div_slider = slidecolor
			if(!i["allowed_edit"])
				div_slider = "locked"
			output += {"<li>
						<label class="switch">
							<input type="[inputtype]" value="1" name="[i["name"]]"[i["checked"] ? " checked" : ""][i["allowed_edit"] ? "" : " onclick='return false' onkeydown='return false'"]>
								<div class="slider [div_slider ? "[div_slider]" : ""]"></div>
									<span>[i["name"]]</span>
						</label>
						</li>"}
	else
		for(var/i in values)
			output += {"<li><input id="name="[i["name"]]"" style="width: 50px" type="[type]" name="[i["name"]]" value="[i["value"]]">
			<label for="[i["name"]]">[i["name"]]</label></li>"}
	output += {"</ul><div style="text-align:center">
		<button type="submit" name="button" value="1" style="font-size:large;float:[( Button2 ? "left" : "right" )]">[Button1]</button>"}

	if(Button2)
		output += {"<button type="submit" name="button" value="2" style="font-size:large;[( Button3 ? "" : "float:right" )]">[Button2]</button>"}

	if(Button3)
		output += {"<button type="submit" name="button" value="3" style="font-size:large;float:right">[Button3]</button>"}

	output += {"</form></div>"}
	..(User, ckey("[User]-[Message]-[Title]-[world.time]-[rand(1,10000)]"), Title, width, height, src, StealFocus, Timeout)
	set_content(output)

/datum/browser/modal/listpicker/on_interact(href, href_list)
	if(href_list["close"] || !user)
		opentime = 0
		return

	if(href_list["button"])
		var/button = text2num(href_list["button"])
		if(button <= 3 && button >= 1)
			selectedbutton = button
	for(var/item in href_list)
		switch(item)
			if("close", "button", "src")
				continue
			else
				valueslist[item] = href_list[item]

	opentime = 0
	close()



/proc/popup(user, message, title)
	var/datum/browser/P = new(user, title, title)
	P.set_content(message)
	P.open()

/proc/presentpicker(User, Message, Title, Button1 = "Ok", Button2, Button3, StealFocus = TRUE, Timeout = 6000, list/values, inputtype = "checkbox", width, height, slidecolor)
	var/datum/browser/modal/listpicker/A = new(User, Message, Title, Button1, Button2, Button3, StealFocus,Timeout, values, inputtype, width, height, slidecolor)
	A.open()
	A.wait()
	if(A.selectedbutton)
		return list("button" = A.selectedbutton, "values" = A.valueslist)

/proc/input_bitfield(User, title, bitfield, current_value, nwidth = 350, nheight = 350, nslidecolor, allowed_edit_list = null)
	if(!(bitfield in global.bitfields))
		return

	var/list/pickerlist = list()
	for(var/i in global.bitfields[bitfield])
		var/can_edit = 1
		if(!isnull(allowed_edit_list) && !(allowed_edit_list & global.bitfields[bitfield][i]))
			can_edit = 0
		if(current_value & global.bitfields[bitfield][i])
			pickerlist += list(list("checked" = 1, "value" = global.bitfields[bitfield][i], "name" = i, "allowed_edit" = can_edit))
		else
			pickerlist += list(list("checked" = 0, "value" = global.bitfields[bitfield][i], "name" = i, "allowed_edit" = can_edit))

	var/list/result = presentpicker(User, "", title, Button1 = "Save", Button2 = "Cancel", Timeout = FALSE, values = pickerlist, width = nwidth, height = nheight, slidecolor = nslidecolor)
	if(islist(result))
		if(result["button"] == 2) // If the user pressed the cancel button
			return
		. = 0
		for(var/flag in result["values"])
			. |= global.bitfields[bitfield][flag]
	else
		return


// Registers the on-close verb for a browse window (client/verb/.windowclose)
// this will be called when the close-button of a window is pressed.
//
// This is usually only needed for devices that regularly update the browse window,
// e.g. canisters, timers, etc.
//
// windowid should be the specified window name
// e.g. code is	: user << browse(text, "window=fred")
// then use 	: onclose(user, "fred")
//
// Optionally, specify the "ref" parameter as the controlled atom (usually src)
// to pass a "close=1" parameter to the atom's Topic() proc for special handling.
// Otherwise, the user mob's machine var will be reset directly.
//
/proc/onclose(user, windowid, atom/ref=null)
	if(ismob(user))
		var/mob/M = user
		user = M.client

	if(!user)
		return

	var/param = "null"
	if(ref)
		param = "\ref[ref]"

	var/window_param = "null"
	if(windowid)
		window_param = windowid

	winset(user, windowid, "on-close=\".windowclose \\\"[param]\\\" \\\"[window_param]\"")


// the on-close client verb
// called when a browser popup window is closed after registering with proc/onclose()
// if a valid atom reference is supplied, call the atom's Topic() with "close=1"
// otherwise, just reset the client mob's machine var.
//
/client/verb/windowclose(atomref as text, windowid as text)
	set hidden = 1						// hide this verb from the user's panel
	set name = ".windowclose"			// no autocomplete on cmd line

	if(LAZYACCESS(browsers, windowid))
		qdel(LAZYACCESS(browsers, windowid))

	//world << "windowclose: [atomref]"
	if(atomref!="null")				// if passed a real atomref
		var/hsrc = locate(atomref)	// find the reffed atom
		var/href = "close=1"
		if(hsrc)
			//world << "[src] Topic [href] [hsrc]"
			usr = src.mob
			Topic(href, params2list(href), hsrc)	// this will direct to the atom's
			return										// Topic() proc via client.Topic()

	// no atomref specified (or not found)
	// so just reset the user mob's machine var
	if(src && src.mob)
		//world << "[src] was [src.mob.machine], setting to null"
		mob.unset_machine()
	return
