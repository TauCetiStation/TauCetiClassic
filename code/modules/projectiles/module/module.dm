/obj/item/weapon/gun_module
	name = "gun module"
	icon = 'code/modules/projectiles/module/modular.dmi'
	var/icon/icon_overlay
	var/obj/item/weapon/gunmodule/parent = null
	var/activate_selfing = null
	var/attackbying = IGNORING
	var/attackself = IGNORING
	var/lessdamage = 0
	var/lessdispersion = 0
	var/lessfiredelay = 0
	var/lessrecoil = 0
	var/size = 0

/obj/item/weapon/gun_module/proc/attach(obj/item/weapon/gunmodule/gun, var/condition_check = FALSE)
	if(gun.collected)
		return FALSE
	if(condition_check)
		return FALSE
	parent = gun
	src.loc = parent
	change_stat(gun, TRUE)
	LAZYADD(gun.overlays, icon_overlay)
	LAZYADD(gun.modules, src)
	return TRUE

/obj/item/weapon/gun_module/proc/eject(obj/item/weapon/gunmodule/gun)
	parent = null
	src.loc = get_turf(gun.loc)
	change_stat(gun, FALSE)
	LAZYREMOVE(gun.overlays, icon_overlay)
	LAZYREMOVE(gun.modules, src)

/obj/item/weapon/gun_module/proc/condition_check(obj/item/weapon/gunmodule/gun)
	return FALSE

/obj/item/weapon/gun_module/proc/change_stat(obj/item/weapon/gunmodule/gun, var/attach)
	if(attach)
		gun.lessdamage -= lessdamage
		gun.lessdispersion -= lessdispersion
		gun.lessfiredelay -= lessfiredelay
		gun.lessrecoil -= lessrecoil
		gun.size -= size
	else
		gun.lessdamage += lessdamage
		gun.lessdispersion += lessdispersion
		gun.lessfiredelay += lessfiredelay
		gun.lessrecoil += lessrecoil
		gun.size += size