
//------------SPACE SUIT------------

//Cheap
/datum/design/space_suit_cheap
	name = "Budget spacesuit"
	id = "space_suit_cheap"
	build_type = MINEFAB
	build_path = /obj/item/clothing/suit/space/cheap
	materials = list(MAT_METAL=6000,MAT_GLASS=500,MAT_PLASTIC=1000)
	construction_time = 120
	starts_unlocked = TRUE
	category = list("Spacesuit")

/datum/design/space_suit_hlemet_cheap
	name = "Budget spacesuit helmet"
	id = "space_suit_hlemet_cheap"
	build_type = MINEFAB
	build_path = /obj/item/clothing/head/helmet/space/cheap
	materials = list(MAT_METAL=1000,MAT_GLASS=500)
	construction_time = 30
	starts_unlocked = TRUE
	category = list("Spacesuit")

//Common buble
/datum/design/space_suit
	name = "Space suit"
	id = "space_suit"
	build_type = MINEFAB
	build_path = /obj/item/clothing/suit/space/globose
	materials = list(MAT_METAL=30000,MAT_GLASS=2000,MAT_PLASTIC=5000)
	construction_time = 350
	category = list("Spacesuit")

/datum/design/space_suit_helmet
	name = "Space suit helmet"
	id = "space_suit_helmet"
	build_type = MINEFAB
	build_path = /obj/item/clothing/head/helmet/space/globose
	materials = list(MAT_METAL=5000,MAT_GLASS=3000)
	construction_time = 70
	category = list("Spacesuit")

//Science buble
/datum/design/space_suit_science
	name = "Science Space Suit"
	id = "space_suit_science"
	build_type = MINEFAB
	build_path = /obj/item/clothing/suit/space/globose/science
	materials = list(MAT_METAL=32500,MAT_GLASS=2000,MAT_PLASTIC=5000,MAT_SILVER=1000)
	construction_time = 400
	category = list("Spacesuit")

datum/design/space_suit_helmet_science
	name = "Science space suit helmet"
	id = "space_suit_helmet_science"
	build_type = MINEFAB
	build_path = /obj/item/clothing/head/helmet/space/globose/science
	materials = list(MAT_METAL=5000,MAT_GLASS=3000,MAT_SILVER=500)
	construction_time = 100
	category = list("Spacesuit")

//Recycler buble
/datum/design/space_suit_recycler
	name = "Recycler Space Suit"
	id = "space_suit_recycler"
	build_type = MINEFAB
	build_path = /obj/item/clothing/suit/space/globose/recycler
	materials = list(MAT_METAL=35000,MAT_GLASS=2000,MAT_PLASTIC=5000,MAT_SILVER=1500)
	construction_time = 400
	category = list("Spacesuit")

datum/design/space_suit_helmet_recycler
	name = "Recycler space suit helmet"
	id = "space_suit_helmet_recycler"
	build_type = MINEFAB
	build_path = /obj/item/clothing/head/helmet/space/globose/recycler
	materials = list(MAT_METAL=5000,MAT_GLASS=3000,MAT_SILVER=1000)
	construction_time = 100
	category = list("Spacesuit")

//Mining buble
/datum/design/space_suit_mining
	name = "Mining Space suit"
	id = "space_suit_mining"
	build_type = MINEFAB
	build_path = /obj/item/clothing/suit/space/globose/mining
	materials = list(MAT_METAL=37500,MAT_GLASS=2000,MAT_PLASTIC=3000,MAT_SILVER=3000)
	construction_time = 900
	category = list("Spacesuit")

/datum/design/space_suit_helmet_mining
	name = "Mining space suit helmet"
	id = "space_suit_helmet_mining"
	build_type = MINEFAB
	build_path = /obj/item/clothing/head/helmet/space/globose/mining
	materials = list(MAT_METAL=5000,MAT_GLASS=3000,MAT_SILVER=1000)
	construction_time = 300
	category = list("Spacesuit")

//Engineering rig
/datum/design/space_suit_engineering
	name = "engineering hardsuit"
	id = "space_suit_engineering"
	build_type = MINEFAB
	build_path = /obj/item/clothing/suit/space/rig/engineering
	materials = list(MAT_METAL=40000,MAT_GLASS=2000,MAT_PLASTIC=5000,MAT_SILVER=6000)
	construction_time = 1350
	category = list("Spacesuit")

/datum/design/space_suit_helmet_engineering
	name = "engineering hardsuit helmet"
	id = "space_suit_helmet_engineering"
	build_type = MINEFAB
	build_path = /obj/item/clothing/head/helmet/space/rig/engineering
	materials = list(MAT_METAL=7500,MAT_GLASS=3000,MAT_SILVER=4000)
	construction_time = 450
	category = list("Spacesuit")

//Atmospherics rig (bs12)
/datum/design/space_suit_atmospherics
	name = "atmospherics hardsuit"
	id = "space_suit_atmospherics"
	build_type = MINEFAB
	build_path = /obj/item/clothing/suit/space/rig/atmos
	materials = list(MAT_METAL=35000,MAT_GLASS=2000,MAT_PLASTIC=5000,MAT_SILVER=6000)
	construction_time = 1050
	category = list("Spacesuit")

/datum/design/space_suit_helmet_atmospherics
	name = "atmospherics hardsuit helmet"
	id = "space_suit_helmet_atmospherics"
	build_type = MINEFAB
	build_path = /obj/item/clothing/head/helmet/space/rig/atmos
	materials = list(MAT_METAL=5000,MAT_GLASS=3000,MAT_SILVER=4000)
	construction_time = 300
	category = list("Spacesuit")

//Medical rig
/datum/design/space_suit_medical
	name = "medical hardsuit"
	id = "space_suit_medical"
	build_type = MINEFAB
	build_path = /obj/item/clothing/suit/space/rig/medical
	materials = list(MAT_METAL=30000,MAT_GLASS=2000,MAT_PLASTIC=5000,MAT_SILVER=3000)
	construction_time = 1050
	category = list("Spacesuit")

/datum/design/space_suit_helmet_medical
	name = "medical hardsuit helmet"
	id = "space_suit_helmet_medical"
	build_type = MINEFAB
	build_path = /obj/item/clothing/head/helmet/space/rig/medical
	materials = list(MAT_METAL=5000,MAT_GLASS=3000,MAT_SILVER=1500)
	construction_time =300
	category = list("Spacesuit")

//Mining rig
/datum/design/space_suit_mining_rig
	name = "mining hardsuit"
	id = "space_suit_mining_rig"
	build_type = MINEFAB
	build_path = /obj/item/clothing/suit/space/rig/mining
	materials = list(MAT_METAL=40000,MAT_GLASS=6000,MAT_PLASTIC=8000,MAT_GOLD=3000,MAT_DIAMOND=2000,MAT_URANIUM=4000)
	construction_time = 1350
	category = list("Spacesuit")

/datum/design/space_suit_helmet_mining_rig
	name = "mining hardsuit helmet"
	id = "space_suit_helmet_mining_rig"
	build_type = MINEFAB
	build_path = /obj/item/clothing/head/helmet/space/rig/mining
	materials = list(MAT_METAL=6000,MAT_GLASS=3000,MAT_PLASTIC=2000,MAT_GOLD=1000,MAT_DIAMOND=500,MAT_URANIUM=1000)
	construction_time = 450
	category = list("Spacesuit")

//Security rig
/datum/design/space_suit_security
	name = "security hardsuit"
	id = "space_suit_security"
	build_type = MINEFAB
	build_path = /obj/item/clothing/suit/space/rig/security
	materials = list(MAT_METAL=45000,MAT_GLASS=6000,MAT_PLASTIC=8000,MAT_GOLD=4000,MAT_DIAMOND=4000,MAT_URANIUM=6000)
	construction_time = 1500
	category = list("Spacesuit")

/datum/design/space_suit_helmet_security
	name = "security hardsuit helmet"
	id = "space_suit_helmet_security"
	build_type = MINEFAB
	build_path = /obj/item/clothing/head/helmet/space/rig/security
	materials = list(MAT_METAL=8000,MAT_GLASS=4000,MAT_PLASTIC=2000,MAT_GOLD=4000,MAT_DIAMOND=2000,MAT_URANIUM=4000)
	construction_time = 800
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
	starts_unlocked = TRUE
	category = list("Tools")

//shovel
/datum/design/shovel
	name = "shovel"
	id = "shovel"
	build_type = MINEFAB
	build_path = /obj/item/weapon/shovel
	materials = list(MAT_METAL=4000)
	construction_time = 50
	starts_unlocked = TRUE
	category = list("Tools")

//geo_hud
/datum/design/geo_hud
	name = "Geological Optical Scanner"
	id = "geo_hud"
	build_type = MINEFAB
	build_path = /obj/item/clothing/glasses/hud/mining
	materials = list(MAT_METAL=50,MAT_GLASS=40)
	construction_time = 50
	starts_unlocked = TRUE
	category = list("Tools")

//mine_flashlight
/datum/design/mine_flashlight
	name = "Mining flashlight"
	id = "mine_flashlight"
	build_type = MINEFAB
	build_path = /obj/item/device/flashlight/lantern
	materials = list(MAT_METAL=120,MAT_GLASS=40)
	construction_time = 50
	starts_unlocked = TRUE
	category = list("Tools")

/datum/design/resonator
	name = "Resonator"
	id = "resonator"
	build_type = MINEFAB
	build_path = /obj/item/weapon/resonator
	materials = list(MAT_METAL=3000,MAT_GLASS=2000,MAT_PLASTIC=1000,MAT_SILVER=500)
	construction_time = 600
	category = list("Tools")

/datum/design/kinetic_accelerator
	name = "Kinetic accelerator"
	id = "kinetic_accelerator"
	build_type = MINEFAB
	build_path = /obj/item/weapon/gun/energy/kinetic_accelerator
	materials = list(MAT_METAL=3000,MAT_GLASS=2000,MAT_PLASTIC=1000,MAT_GOLD=500)
	construction_time = 600
	category = list("Tools")

/datum/design/mining_drone
	name = "Mining drone"
	id = "mining_drone"
	build_type = MINEFAB
	build_path = /mob/living/simple_animal/hostile/mining_drone
	materials = list(MAT_METAL=6000,MAT_GLASS=2000,MAT_PLASTIC=1000,MAT_GOLD=500,MAT_URANIUM=2000)
	construction_time = 800
	category = list("Tools")

/datum/design/mining_jetpack
	name = "Jetpack"
	id = "mining_jetpack"
	build_type = MINEFAB
	build_path = /obj/item/weapon/tank/jetpack/carbondioxide
	materials = list(MAT_METAL=6000,MAT_GLASS=2000,MAT_PLASTIC=1000,MAT_GOLD=500,MAT_URANIUM=2000)
	construction_time = 1200
	category = list("Tools")


//------------SUPPORT------------

/datum/design/mine_radio
	name = "The supply radio headset"
	id = "mine_mine_radio"
	build_type = MINEFAB
	build_path = /obj/item/device/radio/headset/headset_cargo
	materials = list(MAT_METAL=50,MAT_GLASS=25)
	construction_time = 50
	starts_unlocked = TRUE
	category = list("Support")

/datum/design/glowsticks
	name = "The box of glowsticks"
	id = "glowsticks"
	build_type = MINEFAB
	build_path = /obj/item/weapon/storage/fancy/glowsticks
	materials = list(MAT_GLASS=250,MAT_PLASTIC=100,MAT_PHORON=150)
	construction_time = 50
	starts_unlocked = TRUE
	category = list("Support")

/datum/design/glowsticks_adv
	name = "The box of advanced glowsticks"
	id = "glowsticks_adv"
	build_type = MINEFAB
	build_path = /obj/item/weapon/storage/fancy/glowsticks/adv
	materials = list(MAT_GLASS=250,MAT_PLASTIC=200,MAT_PHORON=350)
	construction_time = 100
	category = list("Support")

/datum/design/stimpack
	name = "Stimpack"
	id = "stimpack"
	build_type = MINEFAB
	build_path = /obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack
	materials = list(MAT_GLASS=250,MAT_PLASTIC=500,MAT_PHORON=150)
	construction_time = 50
	category = list("Support")

/datum/design/stimpack_imp
	name = "Improved stimpack"
	id = "stimpack_imp"
	build_type = MINEFAB
	build_path = /obj/item/weapon/reagent_containers/hypospray/autoinjector/stimpack_imp
	materials = list(MAT_GLASS=250,MAT_PLASTIC=500,MAT_PHORON=500)
	construction_time = 50
	category = list("Support")

/datum/design/stimpack_adv
	name = "Advanced stimpack"
	id = "stimpack_adv"
	build_type = MINEFAB
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
	starts_unlocked = TRUE
	category = list("Support")

/datum/design/lazarus
	name = "Lazarus injector"
	id = "lazarus"
	build_type = MINEFAB
	build_path = /obj/item/weapon/lazarus_injector
	materials = list(MAT_METAL=2000,MAT_GLASS=250,MAT_PLASTIC=1000,MAT_PHORON=3000,MAT_URANIUM=500)
	construction_time = 1200
	category = list("Support")

/datum/design/jaunter
	name = "Wormhole jaunter"
	id = "jaunter"
	build_type = MINEFAB
	build_path = /obj/item/device/wormhole_jaunter
	materials = list(MAT_METAL=2000,MAT_GLASS=250,MAT_PLASTIC=1000,MAT_URANIUM=500,MAT_GOLD=500)
	construction_time = 600
	category = list("Support")

/datum/design/survivalcapsule
	name = "Bluespace shelter capsule"
	id = "survivalcapsule"
	build_type = MINEFAB
	build_path = /obj/item/weapon/survivalcapsule
	materials = list(MAT_METAL=2000,MAT_PLASTIC=1000,MAT_DIAMOND=500,MAT_URANIUM=500)
	construction_time = 800
	category = list("Support")

//------------Misc------------

/datum/design/beartrap
	name = "Bear trap"
	id = "beartrap"
	build_type = MINEFAB
	build_path = /obj/item/weapon/legcuffs/beartrap
	materials = list(MAT_METAL=2000)
	construction_time = 180
	category = list("Misc")

/datum/design/riot_shield
	name = "riot shield"
	id = "riot_shield"
	build_type = MINEFAB
	build_path = /obj/item/weapon/shield/riot
	materials = list(MAT_METAL=8000,MAT_DIAMOND=500,MAT_URANIUM=500)
	construction_time = 1200
	category = list("Misc")

/datum/design/riot_helmet
	name = "riot helmet"
	id = "riot_helmet"
	build_type = MINEFAB
	build_path = /obj/item/clothing/head/helmet/riot
	materials = list(MAT_METAL=2000,MAT_GLASS=500,MAT_PLASTIC=1000)
	construction_time = 300
	category = list("Misc")

/datum/design/riot_suit
	name = "riot suit"
	id = "riot_suit"
	build_type = MINEFAB
	build_path = /obj/item/clothing/suit/armor/riot
	materials = list(MAT_METAL=8000,MAT_GLASS=500,MAT_PLASTIC=5000,MAT_URANIUM=500)
	construction_time = 900
	category = list("Misc")
