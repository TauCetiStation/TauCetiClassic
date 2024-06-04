/client/proc/set_level_light() // todo: make this hidden under debug verbs, we can't trust admins
	set category = "Debug"
	set name = "Set Level Light"

	var/turf/T = get_turf(mob)
	var/datum/space_level/L = SSmapping.get_level(T.z)

	var/choice = tgui_input_list(src,"Choose effect to apply", "Light effect (beta)", list("Custom") + lighting_effects)

	if(!choice)
		return

	if(choice == "Custom")
		var/hex_color = input(usr, "Pick new level lighting color", "Level color") as color|null

		if(!hex_color)
			return

		choice = hex_color // for logs below

		L.set_level_light(hex_color)

	else
		var/effect_type = lighting_effects[choice]
		var/datum/level_lighting_effect/effect = new effect_type
		L.set_level_light(effect)

	message_admins("<span class='notice'>[key_name_admin(usr)] sets environment lighting effect to \"[choice]\" at [T.z] z-level.</span>")
	log_admin("[key_name(usr)] sets environment lighting effect to \"[choice]\" at [T.z] z-level.")
