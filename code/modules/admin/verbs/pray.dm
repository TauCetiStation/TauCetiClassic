/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	// No more praying ghosts! ~Luduk
	if(stat == DEAD)
		to_chat(usr, "<span class='warning'>There's nobody that can save you now.</span>")
		return

	msg = sanitize(msg)
	if(!msg)
		return

	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			to_chat(usr, "<span class='warning'>You cannot pray (muted).</span>")
			return
		if(src.client.handle_spam_prevention(msg,MUTE_PRAY))
			return

	var/mutable_appearance/cross = mutable_appearance('icons/obj/storage.dmi', "bible")
	var/font_color = "purple"
	var/prayer_type = "prayer"
	var/deity

	if(usr.job == "Chaplain")
		cross.icon_state = "kingyellow"
		font_color = "blue"
		prayer_type = "chaplain prayer"

		if(ticker.Bible_deity_name)
			deity = ticker.Bible_deity_name

	else if(iscultist(usr))
		cross.icon_state = "tome"
		font_color = "red"
		prayer_type = "cultist prayer"
		deity = "Nar'Sie"

	//parse the language code and consume it
	var/datum/language/speaking = parse_language(msg)
	if(speaking)
		msg = copytext(msg, 2 + length(speaking.key))
	else if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.species.force_racial_language)
			speaking = all_languages[H.species.language]

	if(speaking)
		msg = speaking.color_message(msg)

	var/admin_msg = "<span class='notice'>[bicon(cross)] <b><font color=[font_color]>[prayer_type][deity ? " (to [deity])" : ""] PRAY: </font>[key_name(src, 1)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[src]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[src]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;adminspawncookie=\ref[src]'>SC</a>):</b> [msg]</span>"
	var/gods_msg = "<span class='notice'>[bicon(cross)] <b>[src]'s</b> <b><font color=[font_color]>[prayer_type]</b></font>: [msg]</span>"

	var/scrambled_msg = get_scrambled_message(speaking, msg)
	var/god_not_understand_msg = "<span class='notice'>[bicon(cross)] <b>[src]'s</b> <b><font color=[font_color]>[prayer_type]</b></font>: [scrambled_msg]</span>"

	for(var/client/C in admins)
		if(C.prefs.chat_toggles & CHAT_PRAYER)
			to_chat(C, admin_msg)

	for(var/mob/living/simple_animal/shade/god/G in gods_list)
		if(G.client && (G.client.prefs.chat_toggles & CHAT_PRAYER))
			if(!G.say_understands(src, speaking))
				to_chat(G, god_not_understand_msg)
			else
				to_chat(G, gods_msg)

	var/alt_name = get_alt_name()

	pray_act(msg, speaking, alt_name, "prays")

	feedback_add_details("admin_verb","PR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	//log_admin("HELP: [key_name(src)]: [msg]")

/mob/proc/pray_act(message, speaking, alt_name, verb_)
	emote("pray")

/mob/living/carbon/human/pray_act(message, speaking, alt_name, verb_)
	if(whisper_say(message, speaking, alt_name, "prays quietly"))
		INVOKE_ASYNC(src, /mob.proc/pray_animation)
	else
		// Mimes, and other mute beings.
		emote("pray")

/mob/proc/pray_animation()
	return

/mob/living/carbon/human/var/next_pray_anim = 0

/mob/living/carbon/human/pray_animation()
	if(next_pray_anim > world.time)
		return
	next_pray_anim = world.time + 1 SECOND

	if(incapacitated())
		return
	if(!bodyparts_by_name[BP_L_ARM] || !bodyparts_by_name[BP_L_ARM].is_usable())
		return
	if(!bodyparts_by_name[BP_R_ARM] || !bodyparts_by_name[BP_R_ARM].is_usable())
		return

	//Show an image of the wielded weapon over the person who got dunked.
	var/image/I = image('icons/effects/effects.dmi', "prayer")
	I.layer = layer + 1
	I.invisibility = invisibility
	I.loc = src
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	var/list/viewing = list()
	for(var/mob/M in viewers(src))
		if(M.client && (M.client.prefs.toggles & SHOW_ANIMATIONS))
			viewing |= M.client

	flick_overlay(I, viewing, 10)
	animate(I, pixel_z = 16, alpha = 125, time = 5) // Raise those hands up!
	animate(alpha = 0, time = 5)

/proc/Centcomm_announce(text , mob/Sender , iamessage)
	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = ":regional_indicator_c: **[key_name(Sender)]**  has made an ***Centcomm*** announcement",
		attachment_msg = text,
		attachment_color = BRIDGE_COLOR_ADMINCOM,
	)
	text = "<span class='notice'><b><font color=orange>CENTCOMM[iamessage ? " IA" : ""]:</font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[Sender]'>RPLY</A>):</b> [text]</span>"
	for(var/client/C in admins)
		to_chat(C, text)

/proc/Syndicate_announce(text , mob/Sender)
	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = ":regional_indicator_s: **[key_name(Sender)]**  has made an ***Syndicate*** announcement",
		attachment_msg = text,
		attachment_color = BRIDGE_COLOR_ADMINCOM,
	)
	text = "<span class='notice'><b><font color=crimson>SYNDICATE:</font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;SyndicateReply=\ref[Sender]'>RPLY</A>):</b> [text]</span>"
	for(var/client/C in admins)
		to_chat(C, text)
