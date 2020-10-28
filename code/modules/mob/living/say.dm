proc/isdeaf(A)
	if(istype(A, /mob))
		var/mob/M = A
		return (M.sdisabilities & DEAF) || M.ear_deaf
	return FALSE

/proc/get_random_colour(simple, lower = 0, upper = 255)
	var/colour
	if(simple)
		colour = pick(list("FF0000", "FF7F00", "FFFF00", "00FF00", "0000FF", "4B0082", "8F00FF"))
	else
		for(var/i in 1 to 3)
			var/temp_col = "[num2hex(rand(lower, upper))]"
			if(length(temp_col) < 2)
				temp_col = "0[temp_col]"
			colour += temp_col
	return "#[colour]"

// Thanks to Burger from Burgerstation for the foundation for this.
// This code was written by Chinsky for Nebula, I just made it compatible with Eris. - Matt
var/global/list/floating_chat_colors = list()

/atom/movable
	var/list/stored_chat_text

/atom/movable/proc/animate_chat(message, datum/language/language, small, list/show_to, duration)
	set waitfor = FALSE

	var/style	//additional style params for the message
	var/fontsize = 6
	if(small)
		fontsize = 5
	var/limit = 50
	if(copytext(message, length(message) - 1) == "!!")
		fontsize = 8
		limit = 30
		style += "font-weight: bold;"

	if(length(message) > limit)
		message = "[copytext(message, 1, limit)]..."

	if(!global.floating_chat_colors[name])
		global.floating_chat_colors[name] = get_random_colour(FALSE, 160, 230)
	style += "color: [global.floating_chat_colors[name]];"
	// create 2 messages, one that appears if you know the language, and one that appears when you don't know the language
	var/image/understood = generate_floating_text(src, capitalize(message), style, fontsize, duration, show_to)
	var/image/gibberish = language ? generate_floating_text(src, language.scramble(message), style, fontsize, duration, show_to) : understood

	for(var/mob/M in show_to)
		var/client/C = M.client
		if(!C)
			return
		if(!isdeaf(M))// && C.get_preference_value(/datum/client_preference/floating_messages) == global.PREF_SHOW)
			if(M.say_understands(null, language))
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
	animate(I, 1, alpha = 255, pixel_y = 24)

	for(var/image/old in holder.stored_chat_text)
		animate(old, 2, pixel_y = old.pixel_y + 8)
	LAZYADD(holder.stored_chat_text, I)

	addtimer(CALLBACK(GLOBAL_PROC, .proc/remove_floating_text, holder, I), duration)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/remove_images_from_clients, I, show_to), duration + 2)

	return I

/proc/remove_floating_text(atom/movable/holder, image/I)
	animate(I, 2, pixel_y = I.pixel_y + 10, alpha = 0)
	LAZYREMOVE(holder.stored_chat_text, I)

/proc/remove_images_from_clients(image/I, list/show_to)
	for(var/client/C in show_to)
		C.images -= I
		qdel(I)


var/list/department_radio_keys = list(
	  ":r" = "right ear",	"#r" = "right ear",		".r" = "right ear",
	  ":l" = "left ear",	"#l" = "left ear",		".l" = "left ear",
	  ":i" = "intercom",	"#i" = "intercom",		".i" = "intercom",
	  ":h" = "department",	"#h" = "department",	".h" = "department",
	  ":c" = "Command",		"#c" = "Command",		".c" = "Command",
	  ":n" = "Science",		"#n" = "Science",		".n" = "Science",
	  ":m" = "Medical",		"#m" = "Medical",		".m" = "Medical",
	  ":e" = "Engineering", "#e" = "Engineering",	".e" = "Engineering",
	  ":s" = "Security",	"#s" = "Security",		".s" = "Security",
	  ":w" = "whisper",		"#w" = "whisper",		".w" = "whisper",
	  ":b" = "binary",		"#b" = "binary",		".b" = "binary",
	  ":a" = "alientalk",	"#a" = "alientalk",		".a" = "alientalk",
	  ":t" = "Syndicate",	"#t" = "Syndicate",		".t" = "Syndicate",
	  ":u" = "Supply",		"#u" = "Supply",		".u" = "Supply",
	  ":g" = "changeling",	"#g" = "changeling",	".g" = "changeling",
	  ":d" = "dronechat",	"#d" = "dronechat",		".d" = "dronechat",

	  ":R" = "right ear",	"#R" = "right ear",		".R" = "right ear",
	  ":L" = "left ear",	"#L" = "left ear",		".L" = "left ear",
	  ":I" = "intercom",	"#I" = "intercom",		".I" = "intercom",
	  ":H" = "department",	"#H" = "department",	".H" = "department",
	  ":C" = "Command",		"#C" = "Command",		".C" = "Command",
	  ":N" = "Science",		"#N" = "Science",		".N" = "Science",
	  ":M" = "Medical",		"#M" = "Medical",		".M" = "Medical",
	  ":E" = "Engineering",	"#E" = "Engineering",	".E" = "Engineering",
	  ":S" = "Security",	"#S" = "Security",		".S" = "Security",
	  ":W" = "whisper",		"#W" = "whisper",		".W" = "whisper",
	  ":B" = "binary",		"#B" = "binary",		".B" = "binary",
	  ":A" = "alientalk",	"#A" = "alientalk",		".A" = "alientalk",
	  ":T" = "Syndicate",	"#T" = "Syndicate",		".T" = "Syndicate",
	  ":U" = "Supply",		"#U" = "Supply",		".U" = "Supply",
	  ":G" = "changeling",	"#G" = "changeling",	".G" = "changeling",
	  ":D" = "dronechat",	"#D" = "dronechat",		".D" = "dronechat",

	  //kinda localization -- rastaf0
	  //same keys as above, but on russian keyboard layout. This file uses cp1251 as encoding.
	  ":к" = "right ear",	"#к" = "right ear",		".к" = "right ear",
	  ":д" = "left ear",	"#д" = "left ear",		".д" = "left ear",
	  ":ш" = "intercom",	"#ш" = "intercom",		".ш" = "intercom",
	  ":р" = "department",	"#р" = "department",	".р" = "department",
	  ":с" = "Command",		"#с" = "Command",		".с" = "Command",
	  ":т" = "Science",		"#т" = "Science",		".т" = "Science",
	  ":ь" = "Medical",		"#ь" = "Medical",		".ь" = "Medical",
	  ":у" = "Engineering",	"#у" = "Engineering",	".у" = "Engineering",
	  ":ы" = "Security",	"#ы" = "Security",		".ы" = "Security",
	  ":ц" = "whisper",		"#ц" = "whisper",		".ц" = "whisper",
	  ":и" = "binary",		"#и" = "binary",		".и" = "binary",
	  ":ф" = "alientalk",	"#ф" = "alientalk",		".ф" = "alientalk",
	  ":е" = "Syndicate",	"#е" = "Syndicate",		".е" = "Syndicate",
	  ":г" = "Supply",		"#г" = "Supply",		".г" = "Supply",
	  ":п" = "changeling",	"#п" = "changeling",	".п" = "changeling",
	  ":в" = "dronechat",	"#в" = "dronechat",		".в" = "dronechat",

	  ":К" = "right ear",	"#К" = "right ear",		".К" = "right ear",
	  ":Д" = "left ear",	"#Д" = "left ear",		".Д" = "left ear",
	  ":Ш" = "intercom",	"#Ш" = "intercom",		".Ш" = "intercom",
	  ":Р" = "department",	"#Р" = "department",	".Р" = "department",
	  ":С" = "Command",		"#С" = "Command",		".С" = "Command",
	  ":Т" = "Science",		"#Т" = "Science",		".Т" = "Science",
	  ":Ь" = "Medical",		"#Ь" = "Medical",		".Ь" = "Medical",
	  ":У" = "Engineering",	"#У" = "Engineering",	".У" = "Engineering",
	  ":Ы" = "Security",	"#Ы" = "Security",		".Ы" = "Security",
	  ":Ц" = "whisper",		"#Ц" = "whisper",		".Ц" = "whisper",
	  ":И" = "binary",		"#И" = "binary",		".И" = "binary",
	  ":Ф" = "alientalk",	"#Ф" = "alientalk",		".Ф" = "alientalk",
	  ":Е" = "Syndicate",	"#Е" = "Syndicate",		".Е" = "Syndicate",
	  ":Г" = "Supply",		"#Г" = "Supply",		".Г" = "Supply",
	  ":П" = "changeling",	"#П" = "changeling",	".П" = "changeling",
	  ":В" = "dronechat",	"#В" = "dronechat",		".В" = "dronechat"
)

/mob/living/proc/binarycheck()
	if (istype(src, /mob/living/silicon/pai))
		return
	if (issilicon(src))
		return 1
	if (!ishuman(src))
		return
	var/mob/living/carbon/human/H = src
	if (H.l_ear || H.r_ear)
		var/obj/item/device/radio/headset/dongle
		if(istype(H.l_ear,/obj/item/device/radio/headset))
			dongle = H.l_ear
		else
			dongle = H.r_ear
		if(!istype(dongle))
			return
		if(dongle.translate_binary)
			return 1

/mob/living/say(message, datum/language/speaking = null, verb="says", alt_name="", italics=FALSE, message_range = world.view, list/used_radios = list(), sound/speech_sound, sound_vol, sanitize = TRUE, message_mode = FALSE)
	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return
	if(sanitize)
		message = sanitize(message)
		if(!message)
			return

	var/turf/T = get_turf(src)

	//log
	var/area/A = get_area(src)
	log_say("[key_name(src)] : \[[A.name][message_mode?"/[message_mode]":""]\]: [message]")

	//handle nonverbal and sign languages here
	if (speaking)
		if (speaking.flags & NONVERBAL)
			if (prob(30))
				src.custom_emote(1, "[pick(speaking.signlang_verb)].")

		if (speaking.flags & SIGNLANG)
			say_signlang(message, pick(speaking.signlang_verb), speaking)
			return 1

	//speaking into radios
	if(used_radios.len)
		italics = 1
		message_range = 1

		if (!istype(src, /mob/living/silicon/ai)) // Atlantis: Prevents nearby people from hearing the AI when it talks using it's integrated radio.
			for(var/mob/living/M in hearers(5, src))
				if(M != src)
					M.show_message("<span class='notice'>[src] talks into [used_radios.len ? used_radios[1] : "the radio."]</span>", SHOWMSG_VISUAL|SHOWMSG_AUDIO)
				if (speech_sound)
					playsound_local(src, speech_sound, VOL_EFFECTS_MASTER, sound_vol * 0.5)

		speech_sound = null	//so we don't play it twice.

	//make sure the air can transmit speech
	var/datum/gas_mixture/environment = T.return_air()
	if(environment)
		var/pressure = environment.return_pressure()
		if(pressure < SOUND_MINIMUM_PRESSURE)
			italics = 1
			message_range = 1

			if (speech_sound)
				sound_vol *= 0.5	//muffle the sound a bit, so it's like we're actually talking through contact

	var/list/listening = list()
	var/list/listening_obj = list()

	if(T)
		var/list/hear = hear(message_range, T)
		var/list/hearturfs = list()

		for(var/atom/movable/AM in hear)
			listening |= AM.get_listeners()
			listening_obj |= AM.get_listening_objs()
			hearturfs += AM.locs[1]

		for(var/mob/M in player_list)
			if(M.stat == DEAD && M.client && (M.client.prefs.chat_toggles & CHAT_GHOSTEARS))
				listening |= M
				continue
			if(M.loc && (M.locs[1] in hearturfs))
				listening |= M

	//speech bubble
	var/list/speech_bubble_recipients = list()
	for(var/mob/M in listening)
		if(M.client)
			speech_bubble_recipients.Add(M.client)
	var/image/I = image('icons/mob/talk.dmi', src, "[typing_indicator_type][say_test(message)]", MOB_LAYER + 1)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	INVOKE_ASYNC(GLOBAL_PROC, .proc/flick_overlay, I, speech_bubble_recipients, 30)
	for(var/mob/M in listening)
		M.hear_say(message, verb, speaking, alt_name, italics, src, used_radios.len, speech_sound, sound_vol)

	animate_chat(message, speaking, italics, listening, 40)

	for(var/obj/O in listening_obj)
		spawn(0)
			if(O) //It's possible that it could be deleted in the meantime.
				O.hear_talk(src, message, verb, speaking)

	return 1

/mob/living/proc/say_signlang(message, verb="gestures", datum/language/language)
	for (var/mob/O in viewers(src, null))
		O.hear_signlang(message, verb, language, src)

/obj/effect/speech_bubble
	var/mob/parent
