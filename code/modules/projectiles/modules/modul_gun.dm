/obj/item/weapon/modul_gun
	name = "modul"
	icon = 'code/modules/projectiles/modules/modular.dmi'
	icon_state = ""
	var/obj/item/weapon/gun_modular/parent = null
	var/icon/icon_overlay = ""
	var/lessdamage = 0
	var/lessdispersion = 0
	var/lessfiredelay = 0
	var/lessrecoil = 0
	var/size = 0
/obj/item/weapon/modul_gun/proc/condition_check(obj/item/weapon/gun_modular/gun)
	return FALSE

/obj/item/weapon/modul_gun/proc/delete_overlays(obj/item/weapon/gun_modular/gun)
	gun.overlays -= icon_overlay

/obj/item/weapon/modul_gun/proc/attach(obj/item/weapon/gun_modular/gun)
	if(gun.collected && condition_check(gun))
		return

/obj/item/weapon/modul_gun/proc/change_stat(obj/item/weapon/gun_modular/gun, var/attach)
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

/obj/item/weapon/modul_gun/proc/eject(obj/item/weapon/gun_modular/gun)
	return
