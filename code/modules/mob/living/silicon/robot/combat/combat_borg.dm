/mob/living/silicon/robot/combat
	icon_state = "droid-combat"
	modtype = "Combat"
	var/modtype_icon

/mob/living/silicon/robot/combat/atom_init()
	. = ..()
	var/obj/item/weapon/robot_module/combat/M = new(src)
	module = M
	updatename()
	if(!modtype_icon)
		modtype_icon = "droid-combat"

/mob/living/silicon/robot/combat/Login()
	pick_new_icon()
	radio.config(module.channels)
	return ..()

/mob/living/silicon/robot/combat/proc/pick_new_icon()
	var/module_sprites[0]
	module_sprites["Combat Android"] = "droid-combat"
	module_sprites["Acheron"] = "mechoid-Combat"
	module_sprites["Kodiak"] = "kodiak-combat"
	module.channels = list("Security" = 1)
	var/choose_icon = list()
	for(var/name in module_sprites)
		choose_icon[name] = image(icon = 'icons/mob/robots.dmi', icon_state = module_sprites[name])
	var/new_modtype_icon = show_radial_menu(usr, usr, choose_icon, radius = 50, tooltips = TRUE)
	if(new_modtype_icon)
		modtype_icon = module_sprites[new_modtype_icon]
	updateicon()

/mob/living/silicon/robot/combat/updateicon()
	. = ..()
	if(module_active && istype(module_active,/obj/item/borg/combat/shield))
		add_overlay("[modtype_icon]-shield")
	if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
		icon_state = "[modtype_icon]-roll"
	else
		icon_state = "[modtype_icon]"
