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
	var/list/obj/item/weapon/gun_module/accessory = list()
	var/list/obj/item/weapon/gun_module/modules = list()

/obj/item/weapon/gunmodule/attackby(obj/item/A, mob/user)
	if(MODULE)
		var/obj/item/weapon/gun_module/module = A
		user.drop_item()
		module.attach(src)
		update_icon()

/obj/item/weapon/gunmodule/afterattack(atom/A, mob/living/user, flag, params)
	add_fingerprint(user)
	if(user && user.client && user.client.gun_mode && !(A in target) && grip)
		if(grip.special_check(user, A))
			if(chamber)
				chamber.Fire(A,user,params)

/obj/item/weapon/gunmodule/attack_self(mob/user)
	for(var/obj/item/weapon/gun_module/module in modules)
		var/rezul = module.attackself
		switch(rezul)
			if(INTERRUPT)
				break
			if(IGNORING)
				continue
			if(CONTINUED)
				module.attack_self(user)

/obj/item/weapon/gunmodule/attackby(obj/item/A, mob/user)
	for(var/obj/item/weapon/gun_module/module in modules)
		var/rezul = module.attackbying
		switch(rezul)
			if(INTERRUPT)
				break
			if(IGNORING)
				continue
			if(CONTINUED)
				module.attackby(A, user)