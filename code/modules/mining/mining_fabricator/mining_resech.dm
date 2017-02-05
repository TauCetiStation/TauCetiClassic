
//------------SPACE SUIT------------

//Cheap
/datum/design/space_suit_cheap
	name = "Budget spacesuit"
	id = "space_suit_cheap"
	build_type = MINEFAB
	build_path = /obj/item/clothing/suit/space/cheap
	materials = list(MAT_METAL=10000,MAT_GLASS=500,MAT_PLASTIC=1000)
	construction_time = 150
	category = list("Spacesuit")

/datum/design/space_suit_hlemet_cheap
	name = "Budget spacesuit helmet"
	id = "space_suit_hlemet_cheap"
	build_type = MINEFAB
	build_path = /obj/item/clothing/head/helmet/space/cheap
	materials = list(MAT_METAL=1000,MAT_GLASS=500)
	construction_time = 50
	category = list("Spacesuit")

//Common buble
/datum/design/space_suit
	name = "Space suit"
	id = "space_suit"
	build_type = MINEFAB
	req_tech = list("materials" = 2)
	build_path = /obj/item/clothing/suit/space/globose
	materials = list(MAT_METAL=40000,MAT_GLASS=2000,MAT_PLASTIC=5000)
	construction_time = 500
	category = list("Spacesuit")

/datum/design/space_suit_hlemet
	name = "Space suit hlemet"
	id = "space_suit_hlemet"
	build_type = MINEFAB
	req_tech = list("materials" = 2)
	build_path = /obj/item/clothing/head/helmet/space/globose
	materials = list(MAT_METAL=5000,MAT_GLASS=3000)
	construction_time = 100
	category = list("Spacesuit")

//Mining buble
/datum/design/space_suit_mining
	name = "Mining Space suit"
	id = "space_suit_mining"
	build_type = MINEFAB
	req_tech = list("combat" = 2, "materials" = 3, "engineering" = 2)
	build_path = /obj/item/clothing/suit/space/globose/mining
	materials = list(MAT_METAL=50000,MAT_GLASS=2000,MAT_PLASTIC=3000,MAT_SILVER=3000)
	construction_time = 1200
	category = list("Spacesuit")

/datum/design/space_suit_hlemet_mining
	name = "Mining space suit hlemet"
	id = "space_suit_hlemet_mining"
	build_type = MINEFAB
	req_tech = list("combat" = 2, "materials" = 3, "engineering" = 2)
	build_path = /obj/item/clothing/head/helmet/space/globose/mining
	materials = list(MAT_METAL=5000,MAT_GLASS=3000,MAT_SILVER=1000)
	construction_time = 400
	category = list("Spacesuit")

//Engineering rig
/datum/design/space_suit_engineering
	name = "engineering hardsuit"
	id = "space_suit_engineering"
	build_type = MINEFAB
	req_tech = list("powerstorage"= 3, "materials" = 4, "engineering" = 3)
	build_path = /obj/item/clothing/suit/space/rig/engineering
	materials = list(MAT_METAL=65000,MAT_GLASS=2000,MAT_PLASTIC=5000,MAT_SILVER=6000)
	construction_time = 1800
	category = list("Spacesuit")

/datum/design/space_suit_hlemet_engineering
	name = "engineering hardsuit helmet"
	id = "space_suit_hlemet_engineering"
	build_type = MINEFAB
	req_tech = list("powerstorage"= 3, "materials" = 4, "engineering" = 3)
	build_path = /obj/item/clothing/head/helmet/space/rig/engineering
	materials = list(MAT_METAL=7500,MAT_GLASS=3000,MAT_SILVER=4000)
	construction_time = 600
	category = list("Spacesuit")

//Atmospherics rig (bs12)
/datum/design/space_suit_atmospherics
	name = "atmospherics hardsuit"
	id = "space_suit_atmospherics"
	build_type = MINEFAB
	req_tech = list("phorontech" = 2, "materials" = 4, "engineering" = 3)
	build_path = /obj/item/clothing/suit/space/rig/atmos
	materials = list(MAT_METAL=50000,MAT_GLASS=2000,MAT_PLASTIC=5000,MAT_SILVER=6000)
	construction_time = 1400
	category = list("Spacesuit")

/datum/design/space_suit_hlemet_atmospherics
	name = "atmospherics hardsuit helmet"
	id = "space_suit_hlemet_atmospherics"
	build_type = MINEFAB
	req_tech = list("phorontech" = 2, "materials" = 4, "engineering" = 3)
	build_path = /obj/item/clothing/head/helmet/space/rig/atmos
	materials = list(MAT_METAL=5000,MAT_GLASS=3000,MAT_SILVER=4000)
	construction_time = 400
	category = list("Spacesuit")

//Medical rig
/datum/design/space_suit_medical
	name = "medical hardsuit"
	id = "space_suit_medical"
	build_type = MINEFAB
	req_tech = list("biotech"=3, "materials" = 4, "engineering" = 3)
	build_path = /obj/item/clothing/suit/space/rig/medical
	materials = list(MAT_METAL=45000,MAT_GLASS=2000,MAT_PLASTIC=5000,MAT_SILVER=3000)
	construction_time = 1400
	category = list("Spacesuit")

/datum/design/space_suit_hlemet_medical
	name = "medical hardsuit helmet"
	id = "space_suit_hlemet_medical"
	build_type = MINEFAB
	req_tech = list("biotech"=3, "materials" = 4, "engineering" = 3)
	build_path = /obj/item/clothing/head/helmet/space/rig/medical
	materials = list(MAT_METAL=5000,MAT_GLASS=3000,MAT_SILVER=1500)
	construction_time = 400
	category = list("Spacesuit")

//Mining rig
/datum/design/space_suit_mining_rig
	name = "mining hardsuit"
	id = "space_suit_mining_rig"
	build_type = MINEFAB
	req_tech = list("combat" = 3, "biotech"=2, "materials" = 4, "engineering" = 3)
	build_path = /obj/item/clothing/suit/space/rig/mining
	materials = list(MAT_METAL=75000,MAT_GLASS=6000,MAT_PLASTIC=8000,MAT_GOLD=4000,MAT_DIAMOND=4000,MAT_URANIUM=6000)
	construction_time = 1800
	category = list("Spacesuit")

/datum/design/space_suit_hlemet_mining_rig
	name = "mining hardsuit helmet"
	id = "space_suit_hlemet_mining_rig"
	build_type = MINEFAB
	req_tech = list("combat" = 3, "biotech"=2, "materials" = 4, "engineering" = 3)
	build_path = /obj/item/clothing/head/helmet/space/rig/mining
	materials = list(MAT_METAL=6000,MAT_GLASS=3000,MAT_PLASTIC=2000,MAT_GOLD=1000,MAT_DIAMOND=500,MAT_URANIUM=1000)
	construction_time = 600
	category = list("Spacesuit")

//Security rig
/datum/design/space_suit_security
	name = "security hardsuit"
	id = "space_suit_security"
	build_type = MINEFAB
	req_tech = list("combat" = 5, "biotech"=3, "materials" = 5, "engineering" = 4)
	build_path = /obj/item/clothing/suit/space/rig/security
	materials = list(MAT_METAL=80000,MAT_GLASS=6000,MAT_PLASTIC=8000,MAT_GOLD=7000,MAT_DIAMOND=8000,MAT_URANIUM=12000)
	construction_time = 3600
	category = list("Spacesuit")

/datum/design/space_suit_hlemet_security
	name = "security hardsuit helmet"
	id = "space_suit_hlemet_security"
	build_type = MINEFAB
	req_tech = list("combat" = 5, "biotech"=3, "materials" = 5, "engineering" = 4)
	build_path = /obj/item/clothing/head/helmet/space/rig/security
	materials = list(MAT_METAL=8000,MAT_GLASS=4000,MAT_PLASTIC=2000,MAT_GOLD=4000,MAT_DIAMOND=2000,MAT_URANIUM=4000)
	construction_time = 1600
	category = list("Spacesuit")

//------------TOOLS------------
//other in rnd
//pickaxe
/datum/design/pickaxe
	name = "pickaxe"
	id = "pickaxe"
	build_type = MINEFAB
	build_path = /obj/item/weapon/pickaxe
	materials = list(MAT_METAL=8000)
	construction_time = 100
	category = list("Tools")

//shovel
/datum/design/shovel
	name = "shovel"
	id = "shovel"
	build_type = MINEFAB
	build_path = /obj/item/weapon/shovel
	materials = list(MAT_METAL=4000)
	construction_time = 50
	category = list("Tools")

//geo_hud
/datum/design/geo_hud
	name = "Geological Optical Scanner"
	id = "geo_hud"
	build_type = MINEFAB
	build_path = /obj/item/clothing/glasses/hud/mining
	materials = list(MAT_METAL=50,MAT_GLASS=40)
	construction_time = 50
	category = list("Tools")

//mine_flashlight
/datum/design/mine_flashlight
	name = "Mining flashlight"
	id = "mine_flashlight"
	build_type = MINEFAB
	build_path = /obj/item/device/flashlight/lantern
	materials = list(MAT_METAL=120,MAT_GLASS=40)
	construction_time = 50
	category = list("Tools")

/datum/design/resonator
	name = "Resonator"
	id = "resonator"
	build_type = MINEFAB
	req_tech = list("combat" = 2, "materials" = 3, "engineering" = 2)
	build_path = /obj/item/weapon/resonator
	materials = list(MAT_METAL=3000,MAT_GLASS=2000,MAT_PLASTIC=1000,MAT_SILVER=500)
	construction_time = 600
	category = list("Tools")

/datum/design/kinetic_accelerator
	name = "Kinetic accelerator"
	id = "kinetic_accelerator"
	build_type = MINEFAB
	req_tech = list("combat" = 2, "materials" = 3, "engineering" = 2)
	build_path = /obj/item/weapon/gun/energy/kinetic_accelerator
	materials = list(MAT_METAL=3000,MAT_GLASS=2000,MAT_PLASTIC=1000,MAT_GOLD=500)
	construction_time = 600
	category = list("Tools")

/datum/design/mining_drone
	name = "Mining drone"
	id = "mining_drone"
	build_type = MINEFAB
	req_tech = list("combat" = 3, "materials" = 4, "engineering" = 2,"programming" = 3)
	build_path = /mob/living/simple_animal/hostile/mining_drone
	materials = list(MAT_METAL=6000,MAT_GLASS=2000,MAT_PLASTIC=1000,MAT_GOLD=500,MAT_URANIUM=2000)
	construction_time = 1200
	category = list("Tools")

/datum/design/mining_jetpack
	name = "Jetpack"
	id = "mining_jetpack"
	build_type = MINEFAB
	req_tech = list("combat" = 3, "materials" = 4, "engineering" = 4,"programming" = 2)
	build_path = /obj/item/weapon/tank/jetpack/carbondioxide
	materials = list(MAT_METAL=6000,MAT_GLASS=2000,MAT_PLASTIC=1000,MAT_GOLD=500,MAT_URANIUM=2000)
	construction_time = 1200
	category = list("Tools")


//------------SUPPORT------------Support

/datum/design/mine_radio
	name = "The supply radio headset"
	id = "mine_mine_radio"
	build_type = MINEFAB
	build_path = /obj/item/device/radio/headset/headset_cargo
	materials = list(MAT_METAL=50,MAT_GLASS=25)
	construction_time = 50
	category = list("Support")

/datum/design/glowsticks
	name = "The box of glowsticks"
	id = "glowsticks"
	build_type = MINEFAB
	build_path = /obj/item/weapon/storage/fancy/glowsticks
	materials = list(MAT_GLASS=250,MAT_PLASTIC=100,MAT_PHORON=150)
	construction_time = 50
	category = list("Support")

/datum/design/stimpack
	name = "Stimpack"
	id = "stimpack"
	build_type = MINEFAB
	req_tech = list("biotech"=2)
	build_path = /obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack
	materials = list(MAT_GLASS=250,MAT_PLASTIC=500,MAT_PHORON=150)
	construction_time = 50
	category = list("Support")

/datum/design/stimpack_imp
	name = "Improved stimpack"
	id = "stimpack_imp"
	build_type = MINEFAB
	req_tech = list("biotech"=3,"phorontech" = 2)
	build_path = /obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_imp
	materials = list(MAT_GLASS=250,MAT_PLASTIC=500,MAT_PHORON=500)
	construction_time = 50
	category = list("Support")

/datum/design/stimpack_adv
	name = "Advanced stimpack"
	id = "stimpack_adv"
	build_type = MINEFAB
	req_tech = list("biotech"=4,"phorontech" = 3)
	build_path = /obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_adv
	materials = list(MAT_GLASS=250,MAT_PLASTIC=500,MAT_PHORON=1000,MAT_URANIUM=500)
	construction_time = 50
	category = list("Support")

/datum/design/patcher
	name = "Suit patcher"
	id = "patcher"
	build_type = MINEFAB
	build_path = /obj/item/weapon/patcher
	materials = list(MAT_METAL=200,MAT_GLASS=250,MAT_PLASTIC=100,MAT_PHORON=150)
	construction_time = 100
	category = list("Support")

/datum/design/lazarus
	name = "Lazarus injector"
	id = "lazarus"
	build_type = MINEFAB
	req_tech = list("biotech"=4)
	build_path = /obj/item/weapon/lazarus_injector
	materials = list(MAT_METAL=2000,MAT_GLASS=250,MAT_PLASTIC=1000,MAT_PHORON=3000,MAT_URANIUM=500)
	construction_time = 1200
	category = list("Support")

/datum/design/jaunter
	name = "Wormhole jaunter"
	id = "jaunter"
	build_type = MINEFAB
	req_tech = list("magnets" = 3,"bluespace" = 2)
	build_path = /obj/item/device/wormhole_jaunter
	materials = list(MAT_METAL=2000,MAT_GLASS=250,MAT_PLASTIC=1000,MAT_URANIUM=500,MAT_GOLD=500)
	construction_time = 600
	category = list("Support")

/datum/design/survivalcapsule
	name = "Bluespace shelter capsule"
	id = "survivalcapsule"
	build_type = MINEFAB
	req_tech = list("engineering" = 4,"bluespace" = 3)
	build_path = /obj/item/weapon/survivalcapsule
	materials = list(MAT_METAL=2000,MAT_PLASTIC=1000,MAT_DIAMOND=500,MAT_URANIUM=500)
	construction_time = 800
	category = list("Support")
