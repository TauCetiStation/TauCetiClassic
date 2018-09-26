var/savefile/iconCache = new /savefile("data/iconCache.sav")
var/chatDebug = file("data/chatDebug.log")
var/emojiJson = file2text("code/modules/goonchat/browserassets/js/emojiList.json")

/datum/chatOutput
	var/client/owner = null
	var/loaded = 0
	var/list/messageQueue = list()
	var/cookieSent = 0
	var/list/connectionHistory = list()
	var/broken = FALSE

/datum/chatOutput/New(client/C)
	. = ..()

	owner = C

/datum/chatOutput/proc/start()
	if(!owner)
		return 0

	if(!winexists(owner, "browseroutput"))
		spawn()
			alert(owner.mob, "Updated chat window does not exist. If you are using a custom skin file please allow the game to update.")
		broken = TRUE
		return 0

	if(!owner) // In case the client vanishes before winexists returns
		return 0

	if(winget(owner, "browseroutput", "is-visible") == "true") //Already setup
		doneLoading()

	else
		load()

	return 1

/datum/chatOutput/proc/load()
	set waitfor = FALSE
	if(!owner)
		return

	var/datum/asset/goonchat = get_asset_datum(/datum/asset/simple/goonchat)
	goonchat.register()
	goonchat.send(owner)
	owner << browse('code/modules/goonchat/browserassets/html/browserOutput.html', "window=browseroutput")

/datum/chatOutput/Topic(var/href, var/list/href_list)
	if(usr.client != owner)
		return 1

	var/list/params = list()
	for(var/key in href_list)
		if(length(key) > 7 && findtext(key, "param"))
			var/param_name = copytext(key, 7, -1)
			var/item = href_list[key]
			params[param_name] = item

	var/data
	switch(href_list["proc"])
		if("doneLoading")
			data = doneLoading(arglist(params))

		if("ping")
			data = ping(arglist(params))

		if("analyzeClientData")
			data = analyzeClientData(arglist(params))

		if("setAdminSoundVolume")
			data = setAdminSoundVolume(arglist(params))

	if(data)
		ehjax_send(data = data)

/datum/chatOutput/proc/doneLoading()
	if(loaded)
		return

	loaded = TRUE
	showChat()

	for(var/message in messageQueue)
		// whitespace has already been handled by the original to_chat
		to_chat(owner, message, handle_whitespace=FALSE)

	messageQueue = null
	sendClientData()

	pingLoop()
	sendEmojiList()

	//do not convert to to_chat()
	SEND_TEXT(owner, "<span style=\"font-size: 3; color: red;\">Failed to load fancy chat, reverting to old chat. Certain features won't work.</span>")

/datum/chatOutput/proc/showChat()
	winset(owner, "output", "is-visible=false")
	winset(owner, "browseroutput", "is-disabled=false;is-visible=true")

/datum/chatOutput/proc/pingLoop()
	set waitfor = FALSE

	while (owner)
		ehjax_send(data = owner.is_afk(29 SECONDS) ? "softPang" : "pang") // SoftPang isn't handled anywhere but it'll always reset the opts.lastPang.
		sleep(30 SECONDS)

/datum/chatOutput/proc/sendEmojiList()
	ehjax_send(data = emojiJson)


/datum/chatOutput/proc/ehjax_send(var/client/C = owner, var/window = "browseroutput", var/data)
	if(islist(data))
		data = json_encode(data)
	C << output("[data]", "[window]:ehjaxCallback")

/datum/chatOutput/proc/setAdminSoundVolume(volume = "")
	owner.adminSoundVolume = Clamp(text2num(volume), 0, 100)
	
	if(owner.adminSound)
		owner.adminSound.volume = owner.adminSoundVolume
		owner.adminSound.status |= SOUND_UPDATE
		owner << owner.adminSound

/datum/chatOutput/proc/sendClientData()
	var/list/deets = list("clientData" = list())
	deets["clientData"]["ckey"] = owner.ckey
	deets["clientData"]["ip"] = owner.address
	deets["clientData"]["compid"] = owner.computer_id
	var/data = json_encode(deets)
	ehjax_send(data = data)

/datum/chatOutput/proc/analyzeClientData(cookie = "")
	if(!cookie)
		return

	if(cookie != "none")
		var/list/connData = json_decode(cookie)
		if(connData && islist(connData) && connData.len > 0 && connData["connData"])
			connectionHistory = connData["connData"]
			var/list/found = new()
			for(var/i in connectionHistory.len to 1 step -1)
				var/list/row = connectionHistory[i]
				if(!row || row.len < 3 || !(row["ckey"] && row["compid"] && row["ip"]))
					return
				if(world.IsBanned(row["ckey"], row["compid"], row["ip"]))
					found = row
					break

			//Uh oh this fucker has a history of playing on a banned account!!
			if (found.len > 0)
				//TODO: add a new evasion ban for the CURRENT client details, using the matched row details
				message_admins("[key_name(src.owner)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")
				log_admin("[key_name(src.owner)] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")

	cookieSent = 1

/datum/chatOutput/proc/ping()
	return "pong"

/datum/chatOutput/proc/debug(error)
	error = "\[[time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")]\] Client : [owner.key ? owner.key : owner] triggered JS error: [error]"
	chatDebug << error

//currently not working as expected
/client/verb/debug_chat()
	set hidden = 1
	chatOutput.ehjax_send(data = list("firebug" = 1))


/var/list/bicon_cache = list()

//Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
// exporting it as text, and then parsing the base64 from that.
// (This relies on byond automatically storing icons in savefiles as base64)
/proc/icon2base64(var/icon/icon, var/iconKey = "misc")
	if (!isicon(icon)) return 0

	iconCache[iconKey] << icon
	var/iconData = iconCache.ExportText(iconKey)
	var/list/partial = splittext(iconData, "{")
	return replacetext(copytext(partial[2], 3, -5), "\n", "")

/proc/bicon(var/obj, var/use_class = 1)
	var/class = use_class ? "class='icon misc'" : null
	if (!obj)
		return

	if (isicon(obj))
		if (!bicon_cache["\ref[obj]"]) // Doesn't exist yet, make it.
			bicon_cache["\ref[obj]"] = icon2base64(obj)
		return "<img [class] src='data:image/png;base64,[bicon_cache["\ref[obj]"]]'>"

	// Either an atom or somebody fucked up and is gonna get a runtime, which I'm fine with.
	var/atom/A = obj
	var/key = "[istype(A.icon, /icon) ? "\ref[A.icon]" : A.icon]:[A.icon_state]"
	if (!bicon_cache[key]) // Doesn't exist, make it.
		var/icon/I
		if(!A.icon || !A.icon_state || !(A.icon_state in icon_states(A.icon))) // fixes freeze when client uses examine or anything else, when there is something wrong with icon data.
			I = icon('icons/misc/buildmode.dmi', "buildhelp")                  // there is no logic with this icon choice, i just like it.
		else
			I = icon(A.icon, A.icon_state, SOUTH, 1)
		if (ishuman(obj)) // Shitty workaround for a BYOND issue.
			var/icon/temp = I
			I = icon()
			I.Insert(temp, dir = SOUTH)
		bicon_cache[key] = icon2base64(I, key)
	if(use_class)
		class = "class='icon [A.icon_state]'"

	return "<img [class] src='data:image/png;base64,[bicon_cache[key]]'>"

/proc/to_chat(target, message, handle_whitespace=TRUE)
	if(!target) //shitty fix, but it's works
		return

	//if(istype(message, /image) || istype(message, /sound) || istype(target, /savefile) || !(ismob(target) || islist(target) || isclient(target) || target == world))
	if(istype(message, /image) || istype(message, /sound) || istype(target, /savefile) || !istext(message))
		CRASH("DEBUG: to_chat called with invalid message: [message]")
		return

	if(target == world)
		target = clients

	var/original_message = message

	//Some macros remain in the string even after parsing and fuck up the eventual output
	message = macro2html(message)
	message = replacetext(message, "\improper", "")
	message = replacetext(message, "\proper", "")
	if(handle_whitespace)
		message = replacetext(message, "\n", "<br>")
		message = replacetext(message, "\t", ENTITY_TAB)

	//message = entity_ja(message)//moved to js

	if(islist(target))
		var/encoded = url_encode(message)
		for(var/I in target)
			var/client/C = CLIENT_FROM_VAR(I) //Grab us a client if possible

			if (!C)
				continue

			//Send it to the old style output window.
			SEND_TEXT(C, original_message)

			if(!C.chatOutput || C.chatOutput.broken) // A player who hasn't updated his skin file.
				continue

			if(!C.chatOutput.loaded)
				//Client still loading, put their messages in a queue
				C.chatOutput.messageQueue += message
				continue

			C << output(encoded, "browseroutput:output")
	else
		var/client/C = CLIENT_FROM_VAR(target) //Grab us a client if possible

		if (!C)
			return

		//Send it to the old style output window.
		SEND_TEXT(C, original_message)

		if(!C.chatOutput || C.chatOutput.broken) // A player who hasn't updated his skin file.
			return

		if(!C.chatOutput.loaded)
			//Client still loading, put their messages in a queue
			C.chatOutput.messageQueue += message
			return

		C << output(url_encode(message), "browseroutput:output")
