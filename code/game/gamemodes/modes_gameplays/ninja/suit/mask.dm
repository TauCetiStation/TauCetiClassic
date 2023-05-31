// SPACE NINJA MASK

/obj/item/clothing/mask/gas/voice/space_ninja/atom_init()
	. = ..()
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm

/obj/item/clothing/mask/gas/voice/space_ninja/proc/togge_huds()
	set name = "Toggle rat-HUD" // Lore name for antagonists
	set desc = "Toggles the huds, who see the soul of people."
	set category = "Ninja Equip"

	if(!hud)
		hud = TRUE
		for(var/hud in get_all_antag_huds())
			var/datum/atom_hud/antag/H = hud
			H.add_hud_to(usr)
	else
		hud = FALSE
		for(var/hud in get_all_antag_huds())
			var/datum/atom_hud/antag/H = hud
			H.remove_hud_from(usr)

/obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev()
	set name = "Toggle Voice"
	set desc = "Toggles the voice synthesizer on or off."
	set category = "Ninja Equip"

	var/mob/U = loc//Can't toggle voice when you're not wearing the mask.
	var/vchange = (tgui_alert(usr, "Would you like to synthesize a new name or turn off the voice synthesizer?",, list("New Name","Turn Off")))
	if(vchange=="New Name")
		var/chance = rand(1,100)
		switch(chance)
			if(1 to 50)//High chance of a regular name.
				voice = "[rand(0,1)==1?pick(first_names_female):pick(first_names_male)] [pick(last_names)]"
			if(51 to 80)//Smaller chance of a clown name.
				voice = "[pick(clown_names)]"
			if(81 to 90)//Small chance of a wizard name.
				voice = "[pick(wizard_first)] [pick(wizard_second)]"
			if(91 to 100)//Small chance of an existing crew name.
				var/names[] = new()
				for(var/mob/living/carbon/human/M in player_list)
					if(M==U||!M.client||!M.real_name)	continue
					names.Add(M.real_name)
				voice = !names.len ? "Cuban Pete" : pick(names)
		to_chat(U, "You are now mimicking <B>[voice]</B>.")
	else
		to_chat(U, "The voice synthesizer is [voice!="Unknown"?"now":"already"] deactivated.")
		voice = "Unknown"
	return

/obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm()
	set name = "Switch Mode"
	set desc = "Switches between Night Vision, Meson, or Thermal vision modes."
	set category = "Ninja Equip"
	//Have to reset these manually since life.dm is retarded like that. Go figure.
	//This will only work for humans because only they have the appropriate code for the mask.
	var/mob/U = loc
	switch(mode)
		if(0)
			mode=1
			to_chat(U, "Switching mode to <B>Night Vision</B>.")
		if(1)
			mode=2
			U.see_in_dark = 2
			to_chat(U, "Switching mode to <B>Thermal Scanner</B>.")
		if(2)
			mode=3
			U.see_invisible = SEE_INVISIBLE_LIVING
			U.sight &= ~SEE_MOBS
			to_chat(U, "Switching mode to <B>Meson Scanner</B>.")
		if(3)
			mode=0
			U.sight &= ~SEE_TURFS
			to_chat(U, "Switching mode to <B>Scouter</B>.")

/obj/item/clothing/mask/gas/voice/space_ninja/examine(mob/user)
	..()
	var/mode
	switch(mode)
		if(0)
			mode = "Scouter"
		if(1)
			mode = "Night Vision"
		if(2)
			mode = "Thermal Scanner"
		if(3)
			mode = "Meson Scanner"
	to_chat(user, "<B>[mode]</B> is active.")
	to_chat(user, "Voice mimicking algorithm is set <B>[vchange ? "active" : "inactive"]</B>.")
