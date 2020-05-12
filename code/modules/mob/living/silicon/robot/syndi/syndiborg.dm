/mob/living/silicon/robot/syndicate
	icon_state = "syndie_android"
	lawupdate = 0
	scrambledcodes = 1
	modtype = "Syndicate"
	faction = "syndicate"
//	designation = "Syndicate"
	braintype = "Robot"
	req_access = list(access_syndicate)

	var/static/image/sword_overlay

/mob/living/silicon/robot/syndicate/atom_init()
	. = ..()
	updatename("Syndicate")
	connected_ai = null
	cell.maxcharge = 25000
	cell.charge = 25000
	radio = new /obj/item/device/radio/borg/syndicate(src)
	module = new /obj/item/weapon/robot_module/syndicate(src)
	laws = new /datum/ai_laws/syndicate_override()
	if(!sword_overlay)
		sword_overlay = image(icon, "syndie_android_sword", "layer" = 4.5)
		sword_overlay.plane = sword_overlay.layer

/mob/living/silicon/robot/syndicate/updateicon()
	..()
	if(istype(module_active, /obj/item/weapon/melee/energy/sword/cyborg))
		var/obj/item/weapon/melee/energy/sword/cyborg/SW = module_active
		if(SW.active)
			add_overlay(sword_overlay)

/obj/item/device/radio/borg/syndicate
	syndie = 1
	keyslot = new /obj/item/device/encryptionkey/syndicate

/obj/item/device/radio/borg/syndicate/atom_init()
	. = ..()
	set_frequency(SYND_FREQ)

/obj/item/weapon/melee/energy/sword/cyborg
	var/hitcost = 500

/obj/item/weapon/melee/energy/sword/cyborg/attack_self(mob/living/user)
	..()
	if(istype(user, /mob/living/silicon/robot/syndicate))
		var/mob/living/silicon/robot/syndicate/S = user
		if(active)
			S.add_overlay(S.sword_overlay)
		else
			S.cut_overlay(S.sword_overlay)

/obj/item/weapon/melee/energy/sword/cyborg/attack(mob/M, mob/living/silicon/robot/R)
	if(R.cell)
		var/obj/item/weapon/stock_parts/cell/C = R.cell
		if(active && !(C.use(hitcost)))
			attack_self(R)
			to_chat(R, "<span class='notice'>It's out of charge!</span>")
			return
		..()
	return

/obj/item/weapon/gun/energy/crossbow/cyborg/newshot()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost))
				chambered = shot
				chambered.newshot()
	return
