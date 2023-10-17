/obj/item/device/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "megaphone"
	w_class = SIZE_TINY
	flags = CONDUCT

	item_action_types = list(/datum/action/item_action/hands_free/toggle_megaphone)

	var/spamcheck = 0
	var/emagged = 0
	var/list/insultmsg = list("ПОШЛИ ВЫ ВСЕ НАХУЙ!", "Я АГЕНТ СИНДИКАТА!", "ХОС ХУЕСОС!", "У МЕНЯ БОМБА!", "КАПИТАН ГОНДОН!", "СЛАВА СИНДИКАТУ!")
	required_skills = list(/datum/skill/command = SKILL_LEVEL_NOVICE)

/datum/action/item_action/hands_free/toggle_megaphone
	name = "Toggle Megaphone"

/obj/item/device/megaphone/attack_self(mob/living/user)
	if (user.client)
		if(user.client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You don't know how to use this!</span>")
		return
	if(user.silent || isabductor(user) || HAS_TRAIT(user, TRAIT_MUTE))
		to_chat(user, "<span class='userdange'>You can't speak.</span>")
		return
	if(spamcheck)
		to_chat(user, "<span class='warning'>\The [src] needs to recharge!</span>")
		return

	playsound(src, 'sound/items/megaphone.ogg', VOL_EFFECTS_MASTER)
	var/message = sanitize(input(user, "Shout a message?", "Megaphone", null)  as text)
	if(!message)
		return
	message = (capitalize(message))
	var/cooldown = apply_skill_bonus(user, 10 SECONDS, required_skills, 0.5) //+50% for each level
	var/command_power = user.mind.skills.get_value(/datum/skill/command) * 2 + 1//to avoid recursive increase with help

	if ((src.loc == user && usr.stat == CONSCIOUS))
		if(emagged)
			user.audible_message("<B>[user]</B> broadcasts, <FONT size=3>\"[pick(insultmsg)]\"</FONT>")
		else
			if(is_skill_competent(usr, required_skills))
				for(var/mob/living/carbon/M in get_hearers_in_view(command_power, user))
					if(M != user)
						M.add_command_buff(usr, cooldown)
			user.audible_message("<B>[user]</B> broadcasts, <FONT size=[max(3, command_power)]>\"[message]\"</FONT>")

		spamcheck = 1
		spawn(cooldown)
			spamcheck = 0
		return

/obj/item/device/megaphone/emag_act(mob/user)
	if(emagged)
		return FALSE
	to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
	emagged = 1
	return TRUE
