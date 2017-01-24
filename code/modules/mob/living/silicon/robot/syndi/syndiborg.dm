/mob/living/silicon/robot/syndicate
	icon_state = "syndie_bloodhound"
	lawupdate = 0
	scrambledcodes = 1
	modtype = "Syndicate"
	faction = "syndicate"
//	designation = "Syndicate"
	braintype = "Robot"
	req_access = list(access_syndicate)

/mob/living/silicon/robot/syndicate/New(loc)
	..()
	updatename("Syndicate")
	connected_ai = null
	cell.maxcharge = 25000
	cell.charge = 25000
	radio = new /obj/item/device/radio/borg/syndicate(src)
	module = new /obj/item/weapon/robot_module/syndicate(src)
	laws = new /datum/ai_laws/syndicate_override()

/obj/item/device/radio/borg/syndicate
	syndie = 1
	keyslot = new /obj/item/device/encryptionkey/syndicate

/obj/item/device/radio/borg/syndicate/New()
	..()
	set_frequency(SYND_FREQ)

/obj/item/weapon/melee/energy/sword/cyborg
	var/hitcost = 500

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
