/obj/structure/stool/bed/chair/schair/monorail_chair
	name = "monorail chair"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/locations/centcomm/monorail_chair.dmi'
	icon_state = "s01"

/obj/structure/stool/bed/chair/schair/monorail_chair/rotate()
	return

/obj/structure/rail_centcomm
	name = "monorail"
	desc = "A monorail is a rail-based transportation system based on a single rail."
	icon = 'icons/locations/centcomm/centcomm.dmi'
	density = FALSE
	anchored = TRUE
	layer = 2.7

/obj/structure/sign/monorail_map
	name = "Velocity monorail map"
	desc = "A monorail plan. You are in there somewhere."
	icon = 'icons/locations/centcomm/velocity_signs.dmi'
	icon_state = "map"

/obj/structure/sign/tablo
	name = "Velocity LED Display"
	desc = "A display, sometimes shows you useful information."
	icon = 'icons/locations/centcomm/tablo.dmi'
	icon_state = "tablo01"

/obj/structure/sign/tablo/display_90
	icon = 'icons/locations/centcomm/monitor_90.dmi'

/obj/structure/sign/tablo/display
	icon = 'icons/locations/centcomm/monitor.dmi'

/obj/structure/sign/velocity_shuttle
	name = "Velocity Shuttle"
	desc = "Velocity Shuttle."
	icon = 'icons/locations/centcomm/velocity_signs.dmi'
	icon_state = "vel_s01"

/obj/structure/stool/bed/chair/schair/velocity_s_chair
	name = "monorail chair"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/locations/centcomm/monorail_chair.dmi'
	icon_state = "vel_s"

/obj/structure/sign/velocity_overlay
	layer = 2
	icon = 'icons/locations/centcomm/overlay_velocity.dmi'
	name = "Object"
	desc = "Just object."
	icon_state = "tool"

/obj/structure/sign/velocity_overlay/car_impala
	layer = 4
	icon = 'icons/locations/centcomm/car_impala.dmi'
	name = "Chevrolet Impala"
	desc = "WoW! It's 1981 Chevrolet Impala Velocity!"
	icon_state = "1981 Chevrolet Impala Velocity"

/obj/structure/sign/velocity_overlay/car_carmageddon
	layer = 4
	icon = 'icons/locations/centcomm/car_carmageddon.dmi'
	name = "CGR <<CARMAGEDDON>>"
	desc = "A very big car!"
	icon_state = "carmageddon"

/obj/structure/sign/velocity_overlay/car_ferrari
	layer = 4
	icon = 'icons/locations/centcomm/car_ferrari.dmi'
	name = "Ferrari Daytona"
	desc = "Ferrari Daytona."
	icon_state = "Ferrari Daytona"

/obj/structure/sign/velocity_overlay/car_M105
	layer = 4
	icon = 'icons/locations/centcomm/car_m105.dmi'
	name = "M105"
	desc = "M105."
	icon_state = "M105"

/obj/structure/sign/velocity_overlay/reklama
	layer = 4
	icon = 'icons/locations/centcomm/reklama.dmi'
	name = "Object"
	desc = "Just object."
	icon_state = "SpaceBeer_Anim"

/obj/structure/closet/secure_closet/velocity_security
	name = "Velocity Security Officer's Locker"
	req_access = list(101)
	icon_state = "securevel"
	icon_closed = "securevel"
	icon_opened = "securevel_open"

/obj/structure/closet/secure_closet/velocity_security/full

/obj/structure/closet/secure_closet/velocity_security/full/PopulateContents()
	new /obj/item/clothing/glasses/sunglasses/hud/sechud(src)
	new /obj/item/device/flash(src)
	new /obj/item/weapon/reagent_containers/spray/pepper(src)
	new /obj/item/weapon/storage/box/handcuffs(src)
	new /obj/item/weapon/storage/box/flashbangs(src)
	new /obj/item/weapon/melee/classic_baton(src)
	new /obj/item/weapon/storage/firstaid/regular(src)
	new /obj/item/clothing/suit/armor/vest/velocity(src)
	new /obj/item/clothing/suit/storage/det_suit/velocity(src)
	new /obj/item/clothing/head/soft/sec/corp(src)
	new /obj/item/clothing/accessory/storage/webbing(src)
	new /obj/item/clothing/accessory/storage/black_vest(src)
	new /obj/item/weapon/storage/backpack/satchel(src)
	new /obj/item/weapon/storage/backpack/satchel/sec(src)
	new /obj/item/weapon/storage/belt/security(src)
	new /obj/item/clothing/gloves/left(src)
	new /obj/item/clothing/shoes/boots/combat(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/shoes/sandal(src)
	new /obj/item/clothing/under/det/velocity(src)
	new /obj/item/weapon/storage/pouch/pistol_holster(src)
	new /obj/item/weapon/storage/pouch/baton_holster(src)
	new /obj/item/device/radio/headset/velocity(src)
	new /obj/item/device/contraband_finder(src)
	new /obj/item/device/reagent_scanner(src)

/obj/structure/object_wall/velocity

/obj/structure/sign/velocity_overlay/reklama/soda_ad
	name = "Space Cola Advertisement"
	desc = "Buy Space Cola! Or die of dehydration in space, because there is no soda cooler than Space Cola within a radius of 3 million kilometers!"
	icon = 'icons/locations/centcomm/soda_ad.dmi'
	icon_state = "soda"

/obj/structure/sign/velocity_overlay/reklama/pda_x
	name = "PDA X Advertisement"
	desc = "Buy your brand new PDA X today!"
	icon = 'icons/locations/centcomm/monitor.dmi'
	icon_state = "PDA_X_on"

/obj/item/clothing/suit/storage/det_suit/velocity
	name = "velocity officer's coat"
	desc = "A clean, black nylon windbreaker with the words \"OFFICER OF THE LAW\" embroidered in gold-dyed thread on the back. \"VELOCITY\" is tastefully embroidered below in a smaller font."
	icon_state = "velocitycoat"
	item_state = "velocitycoat"

/obj/item/clothing/head/det_hat/velocity
	name = "velocity officer's cap"
	desc = "A clean and properly creased velocity officer's cap. The badge is shined and polished, the word \"VELOCITY\" engraved professionally under the words \"OFFICER OF THE LAW.\""
	icon_state = "velocitycap"

/obj/item/clothing/under/det/velocity
	name = "velocity officer's uniform"
	desc = "A meticulously clean guard uniform belonging to Dock-42, CITS Velocity. The word \"OFFICER OF THE LAW\" is engraved tastefully and professionally in the badge below the number, 42."
	icon_state = "velocityuniform"
	item_state = "velocityuniform"

/obj/item/clothing/suit/armor/vest/velocity
	name = "CITS armored vest"
	desc = "An armored vest with the badge of a Blue Shield squadron of CITS \"Velocity\"'s Security lieutenant."
	icon_state = "velocityarmor"
	item_state = "velocityarmor"
