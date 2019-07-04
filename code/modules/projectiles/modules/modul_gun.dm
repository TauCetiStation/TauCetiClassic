/obj/item/weapon/modul_gun
	name = "modul"
	icon = 'code/modules/projectiles/modules/modular.dmi'
	var/obj/item/weapon/gun_modular/parent = null
	var/lessdamage = 0
	var/lessdispersion = 0
	var/lessfiredelay = 0
	var/lessrecoil = 0
	var/size = 0

/obj/item/weapon/modul_gun/proc/attach(obj/item/weapon/gun_modular/gun)
	if(gun.collected)
		return