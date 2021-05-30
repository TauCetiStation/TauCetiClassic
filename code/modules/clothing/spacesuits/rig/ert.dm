/obj/item/clothing/head/helmet/space/rig/ert
	name = "emergency response team helmet"
	desc = "A helmet worn by members of the NanoTrasen Emergency Response Team. Armoured and space ready."
	icon_state = "rig0-ert_commander"
	item_state = "ert_commander"
	armor = list(melee = 50, bullet = 35, laser = 30,energy = 15, bomb = 30, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	var/obj/machinery/camera/camera

/obj/item/clothing/head/helmet/space/rig/ert/attack_self(mob/user)
	if(camera)
		..(user)
	else
		camera = new /obj/machinery/camera(src)
		camera.replace_networks(list("ERT"))
		cameranet.removeCamera(camera)
		camera.c_tag = user.name
		to_chat(user, "<span class='notice'>User scanned as [camera.c_tag]. Camera activated.</span>")

/obj/item/clothing/head/helmet/space/rig/ert/examine(mob/user)
	..()
	if(src in view(1, user))
		to_chat(user, "This helmet has a built-in camera. It's [camera ? "" : "in"]active.")

/obj/item/clothing/suit/space/rig/ert
	name = "emergency response team suit"
	desc = "A suit worn by members of the NanoTrasen Emergency Response Team. Armoured, space ready, and fire resistant."
	icon_state = "ert_commander"
	item_state = "ert_commander"
	w_class = ITEM_SIZE_NORMAL
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,
	/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/handcuffs,
	/obj/item/weapon/tank,/obj/item/weapon/rcd)
	slowdown = 1
	armor = list(melee = 60, bullet = 35, laser = 30,energy = 15, bomb = 30, bio = 100, rad = 60)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	max_mounted_devices = 6
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/selfrepair, /obj/item/rig_module/device/flash)

//Commander
/obj/item/clothing/head/helmet/space/rig/ert/commander
	name = "emergency response team commander helmet"
	desc = "A helmet worn by the commander of a NanoTrasen Emergency Response Team. Has blue highlights. Armoured and space ready."
	icon_state = "rig0-ert_commander"
	item_state = "ert_commander_head"
	item_color = "ert_commander"
	armor = list(melee = 60, bullet = 65, laser = 55, energy = 45, bomb = 50, bio = 100, rad = 60)

/obj/item/clothing/suit/space/rig/ert/commander
	name = "emergency response team commander suit"
	desc = "A suit worn by the commander of a NanoTrasen Emergency Response Team. Has blue highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_commander"
	item_state = "ert_commander"
	armor = list(melee = 60, bullet = 65, laser = 55, energy = 55, bomb = 50, bio = 100, rad = 60)
	breach_threshold = 28
	initial_modules = list(/obj/item/rig_module/simple_ai/advanced, /obj/item/rig_module/selfrepair, /obj/item/rig_module/mounted/taser, /obj/item/rig_module/mounted, /obj/item/rig_module/grenade_launcher/flashbang, /obj/item/rig_module/cooling_unit)

//Security
/obj/item/clothing/head/helmet/space/rig/ert/security
	name = "emergency response team security helmet"
	desc = "A helmet worn by security members of a NanoTrasen Emergency Response Team. Has red highlights. Armoured and space ready."
	icon_state = "rig0-ert_security"
	item_state = "ert_security_head"
	item_color = "ert_security"
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 30, bomb = 65, bio = 100, rad = 10)

/obj/item/clothing/suit/space/rig/ert/security
	name = "emergency response team security suit"
	desc = "A suit worn by security members of a NanoTrasen Emergency Response Team. Has red highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_security"
	item_state = "ert_security"
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 30, bomb = 65, bio = 100, rad = 10)
	breach_threshold = 25
	slowdown = 1.4
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/selfrepair, /obj/item/rig_module/device/flash, /obj/item/rig_module/mounted/taser)

//Engineer
/obj/item/clothing/head/helmet/space/rig/ert/engineer
	name = "emergency response team engineer helmet"
	desc = "A helmet worn by engineering members of a NanoTrasen Emergency Response Team. Has orange highlights. Armoured and space ready."
	icon_state = "rig0-ert_engineer"
	item_state = "ert_engineer_head"
	item_color = "ert_engineer"
	siemens_coefficient = 0
	armor = list(melee = 60, bullet = 35, laser = 30,energy = 15, bomb = 30, bio = 100, rad = 75)

/obj/item/clothing/suit/space/rig/ert/engineer
	name = "emergency response team engineer suit"
	desc = "A suit worn by the engineering of a NanoTrasen Emergency Response Team. Has orange highlights. Armoured, space ready, and fire resistant."
	icon_state = "ert_engineer"
	item_state = "ert_engineer"
	siemens_coefficient = 0
	armor = list(melee = 60, bullet = 35, laser = 30,energy = 15, bomb = 30, bio = 100, rad = 75)
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/selfrepair, /obj/item/rig_module/device/flash, /obj/item/rig_module/device/rcd, /obj/item/rig_module/device/extinguisher, /obj/item/rig_module/cooling_unit)

//Medical
/obj/item/clothing/head/helmet/space/rig/ert/medical
	name = "emergency response team medical helmet"
	desc = "A helmet worn by medical members of a NanoTrasen Emergency Response Team. Has white highlights. Armoured and space ready."
	icon_state = "rig0-ert_medical"
	item_state = "ert_medical_head"
	item_color = "ert_medical"

/obj/item/clothing/suit/space/rig/ert/medical
	name = "emergency response team medical suit"
	desc = "A suit worn by medical members of a NanoTrasen Emergency Response Team. Has white highlights. Armoured and space ready."
	icon_state = "ert_medical"
	item_state = "ert_medical"
	slowdown = 0.8
	initial_modules = list(/obj/item/rig_module/simple_ai, /obj/item/rig_module/selfrepair, /obj/item/rig_module/device/flash, /obj/item/rig_module/device/healthscanner, /obj/item/rig_module/chem_dispenser/medical/ert)

/obj/item/clothing/head/helmet/space/rig/ert/stealth
	name = "emergency response team stealth helmet"
	desc = "A helmet worn by stealth members of a NanoTrasen Emergency Response Team."
	icon_state = "rig0-ert_stealth"
	item_color = "ert_stealth"
	item_state = "ert_stealth_head"
	armor = list(melee = 30, bullet = 15, laser = 20,energy = 5, bomb = 20, bio = 100, rad = 100)
	light_color = "#c388eb"
	action_button_name = "Toggle Helmet Visor Light"

/obj/item/clothing/suit/space/rig/ert/stealth
	name = "emergency response team stealth suit"
	desc = "A suit worn by stealth members of a NanoTrasen Emergency Response Team"
	icon_state = "ert_stealth"
	item_state = "ert_stealth"
	armor = list(melee = 40, bullet = 20, laser = 30,energy = 10, bomb = 30, bio = 100, rad = 100)
	slowdown = 0.6
	initial_modules = list(/obj/item/rig_module/simple_ai/advanced, /obj/item/rig_module/selfrepair, /obj/item/rig_module/device/flash, /obj/item/rig_module/stealth, /obj/item/rig_module/nuclear_generator,/obj/item/rig_module/chem_dispenser/combat)
