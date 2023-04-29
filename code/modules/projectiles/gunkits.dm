/obj/item/gunkit
	name = "gunkit"
	icon = 'icons/obj/gun.dmi'
	var/weapon_result = /obj/item/weapon/gun
	var/weapon_req = /obj/item/weapon/gun
	icon_state = "kitsuitcase"
	w_class = SIZE_SMALL

/obj/item/gunkit/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	var/skill_delay = apply_skill_bonus(user, 20, /datum/skill/construction = SKILL_LEVEL_PRO, multiplier = -0.1)
	if(!do_after(user, skill_delay, target))
		return
	if(ispath(weapon_req, target))
		to_chat(user, "<span class='warning'>You have successfully modified the weapon!</span>")
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		new weapon_result(user.loc)
		qdel(src)
		qdel(target)
	else
		to_chat(user, "<span class='warning'>This item is not suitable for modification.</span>")
		return

/obj/item/gunkit/aegun
	name = "advanced energy gun parts kit"
	desc = "A suitcase containing the necessary gun parts to tranform a standard energy gun into an advaned energy gun."
	weapon_result = /obj/item/weapon/gun/energy/gun/nuclear
	weapon_req = /obj/item/weapon/gun/energy/gun

/obj/item/gunkit/laser_cannon
	name = "laser cannon parts kit"
	desc = "A suitcase containing the necessary gun parts to tranform a standard laser gun into an laser CANNON."
	weapon_result = /obj/item/weapon/gun/energy/lasercannon
	weapon_req = /obj/item/weapon/gun/energy/laser

/obj/item/gunkit/stun_revolver
	name = "stun revolver parts kit"
	desc = "A suitcase containing the necessary gun parts to tranform a standart taser into an incredible stunning revolver."
	weapon_result = /obj/item/weapon/gun/energy/taser/stunrevolver
	weapon_req = /obj/item/weapon/gun/energy/taser

/obj/item/gunkit/decloner
	name = "decloner parts kit"
	desc = "A suitcase containing the necessary gun parts to tranform a standart energy gun into an decloner."
	weapon_result = /obj/item/weapon/gun/energy/decloner
	weapon_req = /obj/item/weapon/gun/energy/gun

/obj/item/gunkit/tesla
	name = "tesla cannon parts kit"
	desc = "A suitcase containing the necessary gun parts to tranform a standart laser gun into an tesla cannon."
	weapon_result = /obj/item/weapon/gun/tesla
	weapon_req = /obj/item/weapon/gun/energy/laser

/obj/item/gunkit/phoron_pistol
	name = "phoron pistol parts kit"
	desc = "A suitcase containing the necessary gun parts to tranform a standart energy gun into an phoron pistol."
	weapon_result = /obj/item/weapon/gun/energy/toxgun
	weapon_req = /obj/item/weapon/gun/energy/gun
