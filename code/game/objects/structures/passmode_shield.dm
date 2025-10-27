// for events and shitspawns purposes

#define FSHIELD_PASS_DISALLOW 1
#define FSHIELD_PASS_ALLOW_NOT_LIVING 2
#define FSHIELD_PASS_ALLOW_ALL 3

var/global/list/obj/structure/passmode_shield/passmode_shields

/client/proc/toggle_passmode_shields()
	set category = "Event"
	set name = "Toggle passmode shields"

	if(!passmode_shields)
		to_chat(usr, "<span class='notice'>No passmode shields on map, nothing to toggle.</span>")
		return

	var/list/modes = list(
		"Disallow All" = FSHIELD_PASS_DISALLOW, 
		"Allow not living" = FSHIELD_PASS_ALLOW_NOT_LIVING, 
		"Allow All" = FSHIELD_PASS_ALLOW_ALL,
		)

	var/mode = input("Choise new passmode", "Shield Passmode") as null|anything in modes
	
	if(!mode)
		return

	for(var/obj/structure/passmode_shield/shield as anything in passmode_shields)
		shield.switch_mode(modes[mode])

	// forts event announcement
	var/datum/map_module/forts/forts_module = SSmapping.get_map_module(MAP_MODULE_FORTS)
	if(forts_module)
		var/mode_text
		switch(modes[mode])
			if(FSHIELD_PASS_DISALLOW)
				mode_text = "ничего не пропускает"
			if(FSHIELD_PASS_ALLOW_NOT_LIVING)
				mode_text = "не пропускает людей, объекты разрешены"
			if(FSHIELD_PASS_ALLOW_ALL)
				mode_text = "пропускает всё"
		forts_module.announce("Новый режим барьера: [mode_text]!")

/obj/structure/passmode_shield
	name = "shield"
	icon = 'icons/effects/effects.dmi'
	icon_state = "energyshield_gray"
	density = FALSE
	anchored = TRUE

	layer = INFRONT_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	resistance_flags = FULL_INDESTRUCTIBLE

	var/passmode = FSHIELD_PASS_DISALLOW

/obj/structure/passmode_shield/atom_init()
	LAZYADD(passmode_shields, src)
	switch_mode(passmode)

// need testing:
	if(!(/client/proc/toggle_passmode_shields in global.temp_admin_verbs))
		setup_temp_admin_verbs(/client/proc/toggle_passmode_shields, "Passmode Shield Spawned")

	return ..()

/obj/structure/passmode_shield/ex_act()
	return

/obj/structure/passmode_shield/Destroy()
	LAZYREMOVE(passmode_shields, src)
	return ..()

/obj/structure/passmode_shield/CanPass(atom/movable/mover, turf/target, height=0)
	if(passmode == FSHIELD_PASS_ALLOW_NOT_LIVING)
		if(isliving(mover))
			return FALSE
		else if(locate(/mob) in mover) // crates, etc.
			return FALSE
		else
			return TRUE
	else if(passmode == FSHIELD_PASS_ALLOW_ALL)
		return TRUE
	else // FSHIELD_PASS_DISALLOW
		return FALSE

/obj/structure/passmode_shield/proc/switch_mode(mode)
	passmode = mode
	switch(passmode)
		if(FSHIELD_PASS_DISALLOW)
			color = COLOR_RED_LIGHT
			density = TRUE
			desc = "Does not allow anything to pass through."
		if(FSHIELD_PASS_ALLOW_NOT_LIVING)
			color = COLOR_ORANGE
			density = FALSE
			desc = "Does not allow live things to pass through."
		if(FSHIELD_PASS_ALLOW_ALL)
			color = COLOR_GREEN
			density = FALSE
			desc = "Allow to pass through."

#undef FSHIELD_PASS_DISALLOW
#undef FSHIELD_PASS_ALLOW_NOT_LIVING
#undef FSHIELD_PASS_ALLOW_ALL
