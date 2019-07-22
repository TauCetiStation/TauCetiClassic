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

/obj/item/weapon/gun_module/proc/attach(GUN)
	if(gun.collected)
		return FALSE
	return TRUE

/obj/item/weapon/gun_module/verb/activate_self()
	return

/obj/item/weapon/gun_module/proc/eject(GUN)
	return

/obj/item/weapon/gun_module/proc/condition_check(GUN)
	return FALSE

/obj/item/weapon/gun_module/proc/delete_overlay(GUN)
	gun.overlays -= icon_overlay

/obj/item/weapon/gun_module/proc/change_stat(GUN, var/attach)
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