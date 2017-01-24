/obj/structure/closet/wagon
	name = "emergency closet"
	desc = "It's a storage unit for emergency breathmasks and o2 tanks."
	icon = 'code/modules/locations/shuttles/closet.dmi'
	icon_state = "WallClosetw"
	icon_closed = "WallClosetw"
	icon_opened = "WallClosetw_open"
	anchored = 1
	density = 1

/obj/structure/closet/wagon/New()
	..()
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/tank/emergency_oxygen/engi(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/storage/toolbox/emergency(src)

/obj/structure/closet/medical_wall/erokez //wall mounted medical closet
	name = "first-aid closet"
	desc = "It's wall-mounted storage unit for first aid supplies."
	icon = 'code/modules/locations/shuttles/closet.dmi'
	icon_state = "WallClosetMed_1"
	icon_closed = "WallClosetMed_1"
	icon_opened = "WallCloset_0"
	anchored = 1
	density = 1

/obj/structure/closet/medical_wall/erokez/New()
	..()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/device/healthanalyzer(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )

/obj/structure/closet/erokez
	name = "Closet"
	desc = "It's wall-mounted storage unit"
	icon = 'code/modules/locations/shuttles/closet.dmi'
	icon_state = "WallCloset_1"
	icon_closed = "WallCloset_1"
	icon_opened = "WallCloset_0"
	anchored = 1
	density = 1
