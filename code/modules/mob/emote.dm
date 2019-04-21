// All mobs should have custom emote, really..
/mob/proc/custom_emote(m_type=1,message = null)

	if(stat || !use_me && usr == src)
		to_chat(usr, "You are unable to emote.")
		return

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	if(m_type == 2 && muzzled) return

	if(!message)
		message = sanitize(input(src,"Choose an emote to display.") as text|null)

	if(message)
		message = "<B>[src]</B> [message]"
	else
		return


	if (message)
		log_emote("[name]/[key] : [message]")
 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.
		if(findtext(message," snores.") == 0)
			for(var/mob/M in player_list)
				if(isnewplayer(M))
					continue
				if(M.stat == DEAD && (M.client.prefs.chat_toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src, null)))
					M.show_message(message)


		// Type 1 (Visual) emotes are sent to anyone in view of the item
		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				if(O.status_flags & PASSEMOTES)
					for(var/obj/item/weapon/holder/thing in O.contents)
						thing.show_message(message, m_type)
				O.show_message(message, m_type)

		// Type 2 (Audible) emotes are sent to anyone in hear range
		// of the *LOCATION* -- this is important for pAIs to be heard
		else if (m_type & 2)
			for (var/mob/O in hearers(get_turf(src), null))
				if(O.status_flags & PASSEMOTES)
					for(var/obj/item/weapon/holder/thing in O.contents)
						thing.show_message(message, m_type)
				O.show_message(message, m_type)

/mob/proc/emote_dead(message)

	if(client.prefs.muted & MUTE_DEADCHAT)
		to_chat(src, "\red You cannot send deadchat emotes (muted).")
		return

	if(!(client.prefs.chat_toggles & CHAT_DEAD))
		to_chat(src, "\red You have deadchat muted.")
		return

	if(!src.client.holder)
		if(!dsay_allowed)
			to_chat(src, "\red Deadchat is globally muted")
			return


	if(!message)
		message = sanitize(input(src, "Choose an emote to display.") as text|null)

	if(message)
		message = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[src]</span> <span class='message'>[message]</span></span>"
	else
		return


	if(message)
		log_emote("Ghost/[src.key] : [message]")

		for(var/mob/M in player_list)
			if(isnewplayer(M))
				continue

			if(M.client && M.client.holder && (M.client.holder.rights & R_ADMIN) && (M.client.prefs.chat_toggles & CHAT_DEAD)) // Show the emote to admins
				to_chat(M, message)

			else if(M.stat == DEAD && (M.client.prefs.chat_toggles & CHAT_DEAD)) // Show the emote to regular ghosts with deadchat toggled on
				M.show_message(message, 2)
