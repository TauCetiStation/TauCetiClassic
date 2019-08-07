/obj/item/weapon/gunmodule
	name = "Frame Gun"
	icon = 'code/modules/projectiles/module/modular.dmi'
	icon_state = "base"
	var/icon/icon_overlay
	var/tmp/list/mob/living/target
	var/collected = FALSE
	var/gun_type = null
	var/lessdamage = 0
	var/lessdispersion = 0
	var/lessfiredelay = 0
	var/lessrecoil = 0
	var/size = 0
	var/obj/item/weapon/gun_module/chamber/chamber = null
	var/obj/item/weapon/gun_module/magazine/magazine_supply = null
	var/obj/item/weapon/gun_module/barrel/barrel = null
	var/obj/item/weapon/gun_module/grip/grip = null
	var/list/obj/item/weapon/gun_module/accessory
	var/list/obj/item/weapon/gun_module/modules
	var/max_accessory = 3


/obj/item/weapon/gunmodule/attackby(obj/item/A, mob/user)
	LAZYINITLIST(modules)
	LAZYINITLIST(accessory)
	if(istype(A, /obj/item/weapon/gun_module))
		var/obj/item/weapon/gun_module/module = A
		user.drop_item()
		module.attach(src)
		update_icon()
	else if(isscrewdriver(A))
		collected = !collected
		if(collected)
			icon_state = ""
			icon = getFlatIcon(src)
		else
			for(var/obj/item/weapon/gun_module/module in contents)
				module.eject(src)
			icon = 'code/modules/projectiles/module/modular.dmi'
			icon_state = "base"
	else
		if(collected)
			for(var/obj/item/weapon/gun_module/module in modules)
				var/rezul = module.attackbying
				switch(rezul)
					if(INTERRUPT)
						module.attackby(A, user)
						break
					if(IGNORING)
						continue
					if(CONTINUED)
						module.attackby(A, user)
	..()

/obj/item/weapon/gunmodule/afterattack(atom/A, mob/living/user, flag, params)
	if(!collected)
		return
	add_fingerprint(user)
	if(grip)
		if(grip.special_check(user, A))
			if(chamber)
				chamber.Fire(A,user,params)

/obj/item/weapon/gunmodule/attack_self(mob/user)
	if(!collected)
		return
	for(var/obj/item/weapon/gun_module/module in modules)
		var/rezul = module.attackself
		switch(rezul)
			if(INTERRUPT)
				module.attack_self(user)
				break
			if(IGNORING)
				continue
			if(CONTINUED)
				module.attack_self(user)

/obj/item/weapon/gunmodule/attack_hand(mob/user)
	..()
	LAZYINITLIST(modules)
	for(var/obj/item/weapon/gun_module/module in modules)
		if(usr.get_active_hand() == src)
			module.loc = user

/obj/item/weapon/gunmodule/dropped(mob/user)
	..()
	LAZYINITLIST(modules)
	for(var/obj/item/weapon/gun_module/module in modules)
		module.loc = src
		if(istype(module, /obj/item/weapon/gun_module/accessory))
			var/obj/item/weapon/gun_module/accessory/accessory = module
			accessory.deactivate(user)