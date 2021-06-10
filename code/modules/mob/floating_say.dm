// Thanks to Burger from Burgerstation for the foundation for this.
// This code was written by Chinsky for Nebula, I just made it compatible with Eris. - Matt
var/global/list/floating_chat_colors = list()

/mob/proc/animate_chat(message, datum/language/language, small, list/show_to, duration)
	set waitfor = FALSE

	var/style	//additional style params for the message
	var/fontsize = 7
	if(small)
		fontsize = 6
	var/limit = 51
	if(copytext(message, length(message) - 1) == "!!")
		fontsize = 8
		limit = 31
		style += "font-weight: bold;"

	if(length(message) > limit)
		message = "[copytext(message, 1, limit)]..."

	if(!global.floating_chat_colors[name])
		global.floating_chat_colors[name] = get_random_color(160, 230)
	style += "color: [global.floating_chat_colors[name]];"
	// create 2 messages, one that appears if you know the language, and one that appears when you don't know the language
	var/image/understood = generate_floating_text(src, capitalize(message), style, fontsize, duration, show_to)
	var/image/gibberish = generate_floating_text(src, get_scrambled_message(message, language), style, fontsize, duration, show_to)

	for(var/mob/M in show_to)
		var/client/C = M.client
		if(!C)
			return
		if(!isdeaf(M) && C.prefs.floating_messages)
			if(M.say_understands(src, language))
				C.images += understood
			else
				C.images += gibberish

/proc/generate_floating_text(atom/movable/holder, message, style, size, duration, show_to)
	var/image/I = image(null, holder)
	I.layer = FLY_LAYER
	I.alpha = 0
	I.maptext_width = 80
	I.maptext_height = 64
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	I.pixel_x = -round(I.maptext_width/2) + 16

	style = "font-family: 'Small Fonts'; -dm-text-outline: 1 black; font-size: [size]px; [style]"
	I.maptext = "<center><span style=\"[style]\">[message]</span></center>"
	animate(I, 1, alpha = 255, pixel_y = 16)

	for(var/image/old in holder.stored_chat_text)
		animate(old, 2, pixel_y = old.pixel_y + 8)
	LAZYADD(holder.stored_chat_text, I)

	addtimer(CALLBACK(GLOBAL_PROC, .proc/remove_floating_text, holder, I), duration)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/remove_images_from_clients, I, show_to), duration + 2)

	return I

/proc/remove_floating_text(atom/movable/holder, image/I)
	animate(I, 2, pixel_y = I.pixel_y + 10, alpha = 0)
	LAZYREMOVE(holder.stored_chat_text, I)
