/obj/structure/closet/secure_closet/exile
	name = "Exile Implants"
	req_access = list(access_hos)

/obj/structure/closet/secure_closet/exile/PopulateContents()
	new /obj/item/weapon/implanter/exile(src)
	for (var/i in 1 to 5)
		new /obj/item/weapon/implantcase/exile(src)
