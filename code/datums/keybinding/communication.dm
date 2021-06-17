/datum/keybinding/client/communication
	category = CATEGORY_COMMUNICATION

/datum/keybinding/client/communication/say
	hotkey_keys = list("F3", "T")
	name = "Say"
	full_name = "IC Say"

/datum/keybinding/client/communication/say/down(client/user)
	user.mob?.say_wrapper()
	return TRUE

/datum/keybinding/client/communication/ooc
	hotkey_keys = list("F2", "O")
	name = "OOC"
	full_name = "Out Of Character Say (OOC)"

/datum/keybinding/client/communication/ooc/down(client/user)
	var/message = input(user, "", "OOC \"text\"") as text|null //verb_like input
	if(message)
		user.ooc(message)
	return TRUE

/datum/keybinding/client/communication/me
	hotkey_keys = list("F4", "M")
	name = "Me"
	full_name = "Custom Emote (/Me)"

/datum/keybinding/client/communication/me/down(client/user)
	if(user.mob)
		var/message = input(user, "", "Me \"text\"") as text|null //verb_like input
		if(message)
			user.mob.me_verb(message)
	return TRUE
