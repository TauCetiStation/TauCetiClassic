/obj/item/weapon_parts
	name = "basic part"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = 0
	m_amt = 300
	throwforce = 2
	w_class = 2
	throw_speed = 4
	throw_range = 10

	//Icons
	icon = 'code/modules/projectiles/guns/base.dmi'
	icon_state = null
	item_state = "syringe_kit"

	//Delays
	var/add_delay = 20
	var/remove_delay = 20

	//Sounds
	var/s_add = 'sound/items/screwdriver.ogg'
	var/s_remove = 'sound/items/screwdriver.ogg'

/obj/item/weapon_parts/proc/add_modification(obj/item/weapon/gun/G, mob/user)
	user.remove_from_mob(src)
	G.installed_mods += src
	loc = G
	G.update_icon()

/obj/item/weapon_parts/proc/remove_modification(obj/item/weapon/gun/G, mob/user)
	G.installed_mods -= src
	loc = get_turf(G.loc)
	if(user.a_intent != I_HURT)
		user.put_in_hands(src)
	G.update_icon()

/obj/item/weapon_parts/silencer
	name = "silencer"
	desc = "A silencer."
	icon_state = "silencer"

/obj/item/weapon_parts/silencer/add_modification(obj/item/weapon/gun/G)
	..()
	G.silenced = 1
	G.s_fire = 'sound/weapons/guns/generic_fire_silenced.ogg'
	if(G.w_mod)
		G.w_mod.accuracy -= 0.2
		G.w_mod.damage -= 0.2
		G.w_mod.speed += 0.2

/obj/item/weapon_parts/silencer/remove_modification(obj/item/weapon/gun/G)
	..()
	G.silenced = 0
	G.s_fire = initial(G.s_fire)
	if(G.w_mod)
		G.w_mod.accuracy += 0.2
		G.w_mod.damage += 0.2
		G.w_mod.speed -= 0.2

/datum/w_modificator
	var/accuracy = 0.0
	var/damage = 1
	var/crit_chance = 0
	var/crit_mod = 1
	var/speed = 1
