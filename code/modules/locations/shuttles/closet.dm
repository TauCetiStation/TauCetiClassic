/obj/structure/closet/wagon
	name = "emergency closet"
	cases = list("аварийный шкаф", "аварийного шкафа", "аварийному шкафу", "аварийный шкаф", "аварийным шкафом", "аварийном шкафе")
	desc = "Это настенный шкаф для хранения вещей на экстренный случай. Внутри можно найти дыхательную маску и баллон с кислородом."
	icon = 'icons/locations/shuttles/closet.dmi'
	icon_state = "WallClosetw"
	icon_closed = "WallClosetw"
	icon_opened = "WallClosetw_open"
	anchored = TRUE
	density = TRUE

/obj/structure/closet/wagon/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/weapon/tank/emergency_oxygen/engi(src)
		new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/storage/toolbox/emergency(src)

/obj/structure/closet/mining
	name = "emergency closet"
	cases = list("аварийный шкаф", "аварийного шкафа", "аварийному шкафу", "аварийный шкаф", "аварийным шкафом", "аварийном шкафе")
	desc = "Это настенный шкаф для хранения вещей на экстренный случай. Внутри можно найти баллон с запасом кислорода и герметичный костюм."
	icon = 'icons/locations/shuttles/closet.dmi'
	icon_state = "WallClosetMining"
	icon_closed = "WallClosetMining"
	icon_opened = "WallClosetMining_open"
	anchored = TRUE
	density = TRUE

/obj/structure/closet/mining/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/weapon/tank/emergency_oxygen/engi(src)
		new /obj/item/clothing/mask/breath(src)
	new /obj/item/weapon/storage/toolbox/emergency(src)
	new /obj/item/clothing/head/helmet/space/sk(src)
	new /obj/item/clothing/suit/space/sk(src)

/obj/structure/closet/medical_wall/erokez //wall mounted medical closet
	name = "first-aid closet"
	cases = list("шкаф первой помощи", "шкафа первой помощи", "шкафу первой помощи", "шкаф первой помощи", "шкафом первой помощи", "шкафе первой помощи")
	desc = "Это настенный шкаф для хранения предметов первой помощи."
	icon = 'icons/locations/shuttles/closet.dmi'
	icon_state = "WallClosetMed_1"
	icon_closed = "WallClosetMed_1"
	icon_opened = "WallCloset_0"
	anchored = TRUE
	density = TRUE

/obj/structure/closet/medical_wall/erokez/PopulateContents()
	for (var/i in 1 to 3)
		new /obj/item/stack/medical/bruise_pack(src)
	for (var/i in 1 to 2)
		new /obj/item/stack/medical/ointment(src)
	new /obj/item/device/healthanalyzer(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )

/obj/structure/closet/erokez
	name = "Closet"
	cases = list("шкаф", "шкафа", "шкафу", "шкаф", "шкафом", "шкафе")
	desc = "Это настенный шкаф для хранения предметов."
	icon = 'icons/locations/shuttles/closet.dmi'
	icon_state = "WallCloset_1"
	icon_closed = "WallCloset_1"
	icon_opened = "WallCloset_0"
	anchored = TRUE
	density = TRUE

/obj/structure/closet/evacvent
	name = "Engine ventilation"
	cases = list("вентиляция двигателя", "вентиляции двигателя", "вентиляции двигателя", "вентиляцию двигателя", "вентиляцией двигателя", "вентиляции двигателя")
	desc = "Похоже, вы можете залезть в эту небольшую вентиляционную шахту двигателя"
	icon = 'icons/locations/shuttles/closet.dmi'
	icon_state = "shuttle"
	icon_closed = "shuttle"
	icon_opened = "shuttle_open"
	anchored = TRUE
	wall_mounted = TRUE
	density = FALSE
