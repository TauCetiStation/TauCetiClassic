/// How long the chat message's spawn-in animation will occur for
#define RUNECHAT_MESSAGE_SPAWN_TIME 0.2 SECONDS
/// How long the chat message will exist prior to any exponential decay
#define RUNECHAT_MESSAGE_LIFESPAN 5 SECONDS
/// How long the chat message's end of life fading animation will occur for
#define RUNECHAT_MESSAGE_EOL_FADE 0.7 SECONDS
/// Factor of how much the message index (number of messages) will account to exponential decay
#define RUNECHAT_MESSAGE_EXP_DECAY 0.7
/// Factor of how much height will account to exponential decay
#define RUNECHAT_MESSAGE_HEIGHT_DECAY 0.9
/// Approximate height in pixels of an 'average' line, used for height decay
#define RUNECHAT_MESSAGE_APPROX_LHEIGHT 11
/// Max width of chat message in pixels
#define RUNECHAT_MESSAGE_WIDTH 100
/// Max length of chat message in characters
#define RUNECHAT_MESSAGE_MAX_LENGTH 110

/// Maximum precision of float before rounding errors occur (in this context)
#define RUNECHAT_LAYER_Z_STEP 0.0001
/// The number of z-layer 'slices' usable by the chat message layering
#define RUNECHAT_LAYER_MAX_Z (RUNECHAT_LAYER_MAX - RUNECHAT_LAYER) / RUNECHAT_LAYER_Z_STEP


/// Macro from Lummox used to get height from a MeasureText proc
#define WXH_TO_HEIGHT(x)			text2num(copytext(x, findtextEx(x, "x") + 1))

/**
 * # Chat Message Overlay
 *
 * Datum for generating a message overlay on the map
 */
/datum/runechat
	/// The visual element of the chat messsage
	var/image/message
	/// The location in which the message is appearing
	var/atom/message_loc
	/// The client who heard this message
	var/client/owned_by
	/// Contains the approximate amount of lines for height decay
	var/approx_lines
	/// Contains the reference to the next chatmessage in the bucket, used by runechat subsystem
	var/datum/runechat/next
	/// Contains the reference to the previous chatmessage in the bucket, used by runechat subsystem
	var/datum/runechat/prev
	/// The current index used for adjusting the layer of each sequential chat message such that recent messages will overlay older ones
	var/static/current_z_idx = 0
	/// Contains ID of assigned timer for end_of_life fading event
	var/fadertimer = null
	/// States if end_of_life is being executed
	var/isFading = FALSE

/**
 * Constructs a chat message overlay
 *
 * Arguments:
 * * text - The text content of the overlay
 * * target - The target atom to display the overlay at
 * * owner - The mob that owns this overlay, only this mob will be able to view it
 * * language - The language this message was spoken in
 * * extra_classes - Extra classes to apply to the span that holds the text
 * * lifespan - The lifespan of the message in deciseconds
 */
/datum/runechat/New(text, atom/target, mob/owner, datum/language/language, list/extra_classes = list(), lifespan = RUNECHAT_MESSAGE_LIFESPAN)
	. = ..()
	if (!istype(target))
		CRASH("Invalid target given for runechat")
	if(QDELETED(owner) || !istype(owner) || !owner.client)
		var/crash_msg = "runechat datum created with [isnull(owner) ? "null" : "invalid"] mob owner."
		var/additional_info = "owner: [owner] owner_type: [owner.type] owner_client: [owner.client] owner_loc: [owner.loc] owner_is_qdeleted: [QDELETED(owner)]"
		qdel(src)
		CRASH(crash_msg + additional_info)
	INVOKE_ASYNC(src, PROC_REF(generate_image), text, target, owner, language, extra_classes, lifespan)

/datum/runechat/Destroy()
	if (owned_by)
		if (owned_by.seen_messages)
			LAZYREMOVEASSOC(owned_by.seen_messages, message_loc, src)
		owned_by.images.Remove(message)
	owned_by = null
	message_loc = null
	message = null
	return ..()

/**
 * Calls qdel on the chatmessage when its parent is deleted, used to register qdel signal
 */
/datum/runechat/proc/on_parent_qdel()
	SIGNAL_HANDLER
	qdel(src)

/**
 * Generates a chat message image representation
 *
 * Arguments:
 * * text - The text content of the overlay
 * * target - The target atom to display the overlay at
 * * owner - The client that owns this overlay, only this mob will be able to view it
 * * language - The language this message was spoken in
 * * extra_classes - Extra classes to apply to the span that holds the text
 * * lifespan - The lifespan of the message in deciseconds
 */
/datum/runechat/proc/generate_image(text, atom/target, mob/owner, datum/language/language, list/extra_classes, lifespan)
	if(!owner.client)
		qdel(src)
		return
	// Register client who owns this message
	owned_by = owner.client
	RegisterSignal(owned_by, COMSIG_PARENT_QDELETING, PROC_REF(on_parent_qdel))

	// Clip message
	var/maxlen = RUNECHAT_MESSAGE_MAX_LENGTH
	if (length_char(text) > maxlen)
		text = copytext_char(text, 1, maxlen + 1) + "..." // BYOND index moment

	// Calculate target color if not already present
	if (!target.chat_color || target.chat_color_name != target.name)
		target.chat_color = colorize_string(target.name)
		target.chat_color_darkened = colorize_string(target.name, 0.85, 0.85)
		target.chat_color_name = target.name

	// Get rid of any URL schemes that might cause BYOND to automatically wrap something in an anchor tag
	var/static/regex/url_scheme = new(@"[A-Za-z][A-Za-z0-9+-\.]*:\/\/", "g")
	text = replacetext(text, url_scheme, "")

	// Reject whitespace
	var/static/regex/whitespace = new(@"^\s*$")
	if (whitespace.Find(text))
		qdel(src)
		return

	// Non mobs speakers can be small
	if (!ismob(target))
		extra_classes |= "small"

	var/list/prefixes

	var/runechat_icon = 'icons/hud/chat_icons.dmi'
	// Append radio icon
	var/r_icon_state
	if (extra_classes.Find("speaker"))
		r_icon_state = "radio"
	else if (extra_classes.Find("emote"))
		r_icon_state = "emote"
	if (r_icon_state)
		var/image/r_icon = image(runechat_icon, icon_state = r_icon_state)
		LAZYADD(prefixes, "\icon[r_icon]")

	text = "[prefixes?.Join("&nbsp;")][text]"

	// We dim italicized text to make it more distinguishable from regular text
	var/tgt_color = extra_classes.Find("italics") ? target.chat_color_darkened : target.chat_color

	// Approximate text height
	var/complete_text = "<span class='center [extra_classes.Join(" ")]' style='color: [tgt_color]'>[text]</span>"
	var/mheight = WXH_TO_HEIGHT(owned_by.MeasureText(complete_text, null, RUNECHAT_MESSAGE_WIDTH))
	if(!owner.client)
		qdel(src)
		return
	approx_lines = max(1, mheight / RUNECHAT_MESSAGE_APPROX_LHEIGHT)

	// Translate any existing messages upwards, apply exponential decay factors to timers
	message_loc = get_atom_on_turf(target)
	if (owned_by.seen_messages)
		var/idx = 1
		var/combined_height = approx_lines
		for(var/msg in owned_by.seen_messages[message_loc])
			var/datum/runechat/m = msg
			animate(m.message, pixel_z = m.message.pixel_z + mheight, time = RUNECHAT_MESSAGE_SPAWN_TIME)
			combined_height += m.approx_lines

			// When choosing to update the remaining time we have to be careful not to update the
			// scheduled time once the EOL has been executed.
			if (!m.isFading)
				var/sched_remaining = timeleft(m.fadertimer, SSrunechat)
				var/remaining_time = (sched_remaining) * (RUNECHAT_MESSAGE_EXP_DECAY ** idx++) * (RUNECHAT_MESSAGE_HEIGHT_DECAY ** combined_height)
				if (remaining_time)
					deltimer(m.fadertimer, SSrunechat)
					m.fadertimer = addtimer(CALLBACK(m, PROC_REF(end_of_life)), remaining_time, TIMER_STOPPABLE, SSrunechat)
				else
					m.end_of_life()

	// Reset z index if relevant
	if (current_z_idx >= RUNECHAT_LAYER_MAX_Z)
		current_z_idx = 0

	// Build message image
	message = image(loc = message_loc, layer = RUNECHAT_LAYER + RUNECHAT_LAYER_Z_STEP * current_z_idx++)
	message.plane = ABOVE_LIGHTING_PLANE
	message.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	message.alpha = 0
	message.pixel_z = owner.bound_height * 0.95
	message.maptext_width = RUNECHAT_MESSAGE_WIDTH
	message.maptext_height = mheight
	message.maptext_x = (RUNECHAT_MESSAGE_WIDTH - owner.bound_width) * -0.5
	message.maptext = MAPTEXT(complete_text)

	// View the message
	LAZYADDASSOCLIST(owned_by.seen_messages, message_loc, src)
	owned_by.images |= message
	animate(message, alpha = 255, time = RUNECHAT_MESSAGE_SPAWN_TIME)

	// Register with the runechat SS to handle EOL and destruction
	var/duration = lifespan - RUNECHAT_MESSAGE_EOL_FADE
	fadertimer = addtimer(CALLBACK(src, PROC_REF(end_of_life)), duration, TIMER_STOPPABLE, SSrunechat)

/**
 * Applies final animations to overlay RUNECHAT_MESSAGE_EOL_FADE deciseconds prior to message deletion
 */
/datum/runechat/proc/end_of_life(fadetime = RUNECHAT_MESSAGE_EOL_FADE)
	isFading = TRUE
	animate(message, alpha = 0, time = fadetime, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), fadetime, TIMER_STOPPABLE, SSrunechat)

/**
 * Creates a message overlay at a defined location for a given speaker
 *
 * Arguments:
 * * speaker - The atom who is saying this message
 * * language - The language that the message is said in
 * * raw_message - The text content of the message
 * * spans - Additional classes to be added to the message
 * * runechat_flags - Additional flags to pass
 * * lifespan - How long the message will live
 */
/mob/proc/show_runechat_message(atom/movable/speaker, datum/language/language, raw_message, list/spans, runechat_flags = 0, lifespan = RUNECHAT_MESSAGE_LIFESPAN)
	if(!speaker || isobserver(speaker))
		return

	if(!client || !client.prefs.show_runechat)
		return

	if(SSlag_switch.measures[DISABLE_RUNECHAT] && !HAS_TRAIT(speaker, TRAIT_BYPASS_MEASURES))
		return

	// Ensure the list we are using, if present, is a copy so we don't modify the list provided to us
	spans = spans ? spans.Copy() : list()

	// Display visual above source
	if(runechat_flags & SHOWMSG_VISUAL)
		new /datum/runechat(raw_message, speaker, src, language, list("emote", "italics"))
	else
		new /datum/runechat(raw_message, speaker, src, language, spans)

// Tweak these defines to change the available color ranges
#define CM_COLOR_SAT_MIN 0.6
#define CM_COLOR_SAT_MAX 0.7
#define CM_COLOR_LUM_MIN 0.65
#define CM_COLOR_LUM_MAX 0.75

/**
 * Gets a color for a name, will return the same color for a given string consistently within a round.atom
 *
 * Note that this proc aims to produce pastel-ish colors using the HSL colorspace. These seem to be favorable for displaying on the map.
 *
 * Arguments:
 * * name - The name to generate a color for
 * * sat_shift - A value between 0 and 1 that will be multiplied against the saturation
 * * lum_shift - A value between 0 and 1 that will be multiplied against the luminescence
 */
/datum/runechat/proc/colorize_string(name, sat_shift = 1, lum_shift = 1)
	// seed to help randomness
	var/static/rseed = rand(1,26)

	// get hsl using the selected 6 characters of the md5 hash
	var/hash = copytext(md5(name + "[global.round_id]"), rseed, rseed + 6)
	var/h = hex2num(copytext(hash, 1, 3)) * (360 / 255)
	var/s = (hex2num(copytext(hash, 3, 5)) >> 2) * ((CM_COLOR_SAT_MAX - CM_COLOR_SAT_MIN) / 63) + CM_COLOR_SAT_MIN
	var/l = (hex2num(copytext(hash, 5, 7)) >> 2) * ((CM_COLOR_LUM_MAX - CM_COLOR_LUM_MIN) / 63) + CM_COLOR_LUM_MIN

	// adjust for shifts
	s *= clamp(sat_shift, 0, 1)
	l *= clamp(lum_shift, 0, 1)

	// convert to rgb
	var/h_int = round(h/60) // mapping each section of H to 60 degree sections
	var/c = (1 - abs(2 * l - 1)) * s
	var/x = c * (1 - abs((h / 60) % 2 - 1))
	var/m = l - c * 0.5
	x = (x + m) * 255
	c = (c + m) * 255
	m *= 255
	switch(h_int)
		if(0)
			return "#[num2hex(c, 2)][num2hex(x, 2)][num2hex(m, 2)]"
		if(1)
			return "#[num2hex(x, 2)][num2hex(c, 2)][num2hex(m, 2)]"
		if(2)
			return "#[num2hex(m, 2)][num2hex(c, 2)][num2hex(x, 2)]"
		if(3)
			return "#[num2hex(m, 2)][num2hex(x, 2)][num2hex(c, 2)]"
		if(4)
			return "#[num2hex(x, 2)][num2hex(m, 2)][num2hex(c, 2)]"
		if(5)
			return "#[num2hex(c, 2)][num2hex(m, 2)][num2hex(x, 2)]"

#undef RUNECHAT_MESSAGE_SPAWN_TIME
#undef RUNECHAT_MESSAGE_LIFESPAN
#undef RUNECHAT_MESSAGE_EOL_FADE
#undef RUNECHAT_MESSAGE_EXP_DECAY
#undef RUNECHAT_MESSAGE_HEIGHT_DECAY
#undef RUNECHAT_MESSAGE_APPROX_LHEIGHT
#undef RUNECHAT_MESSAGE_WIDTH
#undef RUNECHAT_LAYER_Z_STEP
#undef RUNECHAT_LAYER_MAX_Z
