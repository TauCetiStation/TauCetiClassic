// SPACE NINJA MASK

/obj/item/clothing/mask/gas/voice/space_ninja/atom_init()
	. = ..()
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev
	verbs += /obj/item/clothing/mask/gas/voice/space_ninja/proc/switchm

//This proc is linked to human life.dm. It determines what hud icons to display based on mind special role for most mobs.
/obj/item/clothing/mask/gas/voice/space_ninja/proc/assess_targets(list/target_list, mob/living/carbon/U)
	var/icon/tempHud = 'icons/mob/hud.dmi'
	for(var/mob/living/target in target_list)
		if(iscarbon(target))
			switch(target.mind.special_role)
				if("traitor")
					U.client.images += image(tempHud,target,"hudtraitor")
				if("Revolutionary","Head Revolutionary")
					U.client.images += image(tempHud,target,"hudrevolutionary")
				if("Cultist")
					U.client.images += image(tempHud,target,"hudcultist")
				if("Changeling")
					U.client.images += image(tempHud,target,"hudchangeling")
				if("Wizard","Fake Wizard")
					U.client.images += image(tempHud,target,"hudwizard")
				if("Hunter","Sentinel","Drone","Queen")
					U.client.images += image(tempHud,target,"hudalien")
				if("Syndicate")
					U.client.images += image(tempHud,target,"hudoperative")
				if("Death Commando")
					U.client.images += image(tempHud,target,"huddeathsquad")
				if("Ninja")
					U.client.images += image(tempHud,target,"hudninja")
				else//If we don't know what role they have but they have one.
					U.client.images += image(tempHud,target,"hudunknown1")
		else//If the silicon mob has no law datum, no inherent laws, or a law zero, add them to the hud.
			var/mob/living/silicon/silicon_target = target
			if(!silicon_target.laws||(silicon_target.laws&&(silicon_target.laws.zeroth||!silicon_target.laws.inherent.len)))
				if(isrobot(silicon_target))//Different icons for robutts and AI.
					U.client.images += image(tempHud,silicon_target,"hudmalborg")
				else
					U.client.images += image(tempHud,silicon_target,"hudmalai")
	return 1

/obj/item/clothing/mask/gas/voice/space_ninja/proc/togglev()
	set name = "Toggle Voice"
	set desc = "Toggles the voice synthesizer on or off."
	set category = "Ninja Equip"

	var/mob/U = loc//Can't toggle voice when you're not wearing the mask.
	var/vchange = (alert("Would you like to synthesize a new name or turn off the voice synthesizer?",,"New Name","Turn Off"))
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
