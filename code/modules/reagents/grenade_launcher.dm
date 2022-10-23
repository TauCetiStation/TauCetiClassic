/obj/item/weapon/gun/grenadelauncher
	name = "grenade launcher"
	icon = 'icons/obj/gun.dmi'
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = SIZE_NORMAL
	throw_speed = 2
	throw_range = 10
	force = 5.0
	var/list/grenades = list()
	var/max_grenades = 3
	m_amt = 2000
	slot_flags = SLOT_FLAGS_BACK
	can_be_holstered = FALSE

/obj/item/weapon/gun/grenadelauncher/examine(mob/user)
	..()
	if(src in view(2, user))
		to_chat(user, "<span class='notice'>[grenades.len] / [max_grenades] Grenades.</span>")

/obj/item/weapon/gun/grenadelauncher/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/grenade))
		if(grenades.len < max_grenades)
			user.drop_from_inventory(I, src)
			grenades += I
			to_chat(user, "<span class='notice'>You put the grenade in the grenade launcher.</span>")
			to_chat(user, "<span class='notice'>[grenades.len] / [max_grenades] Grenades.</span>")
		else
			to_chat(usr, "<span class='warning'>The grenade launcher cannot hold more grenades.</span>")
	else
		return ..()

/obj/item/weapon/gun/grenadelauncher/afterattack(atom/target, mob/user, proximity, params)
	if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(grenades.len)
		spawn(0) fire_grenade(target,user)
	else
		to_chat(usr, "<span class='warning'>The grenade launcher is empty.</span>")

/obj/item/weapon/gun/grenadelauncher/proc/fire_grenade(atom/target, mob/user)
	user.visible_message("<span class='warning'>[user] fired a grenade!</span>", self_message = "<span class='warning'>You fire the grenade launcher!</span>")
	var/obj/item/weapon/grenade/chem_grenade/F = grenades[1] //Now with less copypasta!
	grenades -= F
	F.loc = user.loc
	F.throw_at(target, 30, 2, user)
	message_admins("[key_name_admin(user)] fired a grenade ([F.name]) from a grenade launcher ([src.name]). [ADMIN_JMP(user)]")
	log_game("[key_name(user)] used a grenade ([src.name]).")
	F.active = 1
	F.icon_state = initial(F.icon_state) + "_active"
	playsound(user, 'sound/weapons/armbomb.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
	spawn(15)
		F.prime()

/obj/item/weapon/gun/grenadelauncher/cyborg
	name = "grenade launcher"
	icon = 'icons/obj/gun.dmi'
	icon_state = "riotgun"
	item_state = "riotgun"
	var/current_grenade = null
	var/mode = 0

/obj/item/weapon/gun/grenadelauncher/cyborg/attackby()
	return

/obj/item/weapon/gun/grenadelauncher/cyborg/attack_self(mob/living/silicon/robot/user)
	mode++
	if(mode > 4)
		mode = 1
	switch(mode)
		if(1)
			current_grenade = /obj/item/weapon/grenade/flashbang
			to_chat(user, "<span class='notice'>Flashbang selected.</span>")
		if(2)
			current_grenade = /obj/item/weapon/grenade/smokebomb
			to_chat(user, "<span class='notice'>Smokebomb selected.</span>")
		if(3)
			current_grenade = /obj/item/weapon/grenade/chem_grenade/teargas
			to_chat(user, "<span class='notice'>Teargas selected.</span>")
		if(4)
			current_grenade = /obj/item/weapon/grenade/chem_grenade/drugs
			to_chat(user, "<span class='notice'>SpaceDrugs selected.</span>")

/obj/item/weapon/gun/grenadelauncher/cyborg/afterattack(atom/target, mob/living/silicon/robot/user, proximity, params)
	user.SetNextMove(CLICK_CD_MELEE*2)
	if(!current_grenade)
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
		return
	if(target == user)
		return
	if(user.cell.use(1500))
		fire_grenade(target,user)
	else
		to_chat(user, "<span class='warning'>Not enough charge.</span>")

/obj/item/weapon/gun/grenadelauncher/cyborg/fire_grenade(atom/target, mob/living/silicon/robot/user)
	user.visible_message("<span class='warning'>[user] fired a grenade!</span>",
	"<span class='warning'>You fire the grenade launcher!</span>")
	var/obj/item/weapon/grenade/G = new current_grenade(loc)
	G.forceMove(user.loc)
	G.activate(user)
	G.throw_at(target, 30, 2, user)
