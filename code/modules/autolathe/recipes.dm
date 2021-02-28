/datum/autolathe_recipe
	var/name = "recipe"
	var/result
	var/metal_amount = 0
	var/glass_amount = 0

// Autolathe recipes

/datum/autolathe_recipe/bucket
	name = "bucket"
	result = /obj/item/weapon/reagent_containers/glass/bucket
	metal_amount = 200
	glass_amount = 0

/datum/autolathe_recipe/crowbar
	name = "crowbar"
	result = /obj/item/weapon/crowbar
	metal_amount = 50
	glass_amount = 0

/datum/autolathe_recipe/flashlight
	name = "flashlight"
	result = /obj/item/device/flashlight
	metal_amount = 50
	glass_amount = 20

/datum/autolathe_recipe/extinguisher
	name = "fire extinguisher"
	result = /obj/item/weapon/reagent_containers/spray/extinguisher
	metal_amount = 90
	glass_amount = 0

/datum/autolathe_recipe/multitool
	name = "multitool"
	result = /obj/item/device/multitool
	metal_amount = 50
	glass_amount = 20

/datum/autolathe_recipe/t_scanner
	name = "T-ray scanner"
	result = /obj/item/device/t_scanner
	metal_amount = 150
	glass_amount = 0

/datum/autolathe_recipe/analyzer
	name = "analyzer"
	result = /obj/item/device/analyzer
	metal_amount = 30
	glass_amount = 20

/datum/autolathe_recipe/plant_analyzer
	name = "plant analyzer"
	result = /obj/item/device/plant_analyzer
	metal_amount = 200
	glass_amount = 50

/datum/autolathe_recipe/healthanalyzer
	name = "Health Analyzer"
	result = /obj/item/device/healthanalyzer
	metal_amount = 200
	glass_amount = 0

/datum/autolathe_recipe/weldingtool
	name = "welding tool"
	result = /obj/item/weapon/weldingtool
	metal_amount = 70
	glass_amount = 30

/datum/autolathe_recipe/screwdriver
	name = "screwdriver"
	result = /obj/item/weapon/screwdriver
	metal_amount = 75
	glass_amount = 0

/datum/autolathe_recipe/wirecutters
	name = "wirecutters"
	result = /obj/item/weapon/wirecutters
	metal_amount = 80
	glass_amount = 0

/datum/autolathe_recipe/wrench
	name = "wrench"
	result = /obj/item/weapon/wrench
	metal_amount = 150
	glass_amount = 0

/datum/autolathe_recipe/welding_helmet
	name = "welding helmet"
	result = /obj/item/clothing/head/welding
	metal_amount = 3000
	glass_amount = 1000

/datum/autolathe_recipe/console_screen
	name = "console screen"
	result = /obj/item/weapon/stock_parts/console_screen
	metal_amount = 0
	glass_amount = 200

/datum/autolathe_recipe/airlock_electronics
	name = "airlock electronics"
	result = /obj/item/weapon/airlock_electronics
	metal_amount = 50
	glass_amount = 50

/datum/autolathe_recipe/airalarm_electronics
	name = "air alarm electronics"
	result = /obj/item/weapon/airalarm_electronics
	metal_amount = 50
	glass_amount = 50

/datum/autolathe_recipe/firealarm_electronics
	name = "fire alarm electronics"
	result = /obj/item/weapon/firealarm_electronics
	metal_amount = 50
	glass_amount = 50

/datum/autolathe_recipe/power_control
	name = "power control module"
	result = /obj/item/weapon/module/power_control
	metal_amount = 50
	glass_amount = 50

/datum/autolathe_recipe/rcd_ammo
	name = "compressed matter cartridge"
	result = /obj/item/weapon/rcd_ammo
	metal_amount = 30000
	glass_amount = 15000

/datum/autolathe_recipe/kitchenknife
	name = "kitchen knife"
	result = /obj/item/weapon/kitchenknife
	metal_amount = 12000
	glass_amount = 0

/datum/autolathe_recipe/scalpel
	name = "scalpel"
	result = /obj/item/weapon/scalpel
	metal_amount = 10000
	glass_amount = 5000

/datum/autolathe_recipe/circular_saw
	name = "circular saw"
	result = /obj/item/weapon/circular_saw
	metal_amount = 20000
	glass_amount = 10000

/datum/autolathe_recipe/surgicaldrill
	name = "surgical drill"
	result = /obj/item/weapon/surgicaldrill
	metal_amount = 15000
	glass_amount = 10000

/datum/autolathe_recipe/retractor
	name = "retractor"
	result = /obj/item/weapon/retractor
	metal_amount = 10000
	glass_amount = 5000

/datum/autolathe_recipe/cautery
	name = "cautery"
	result = /obj/item/weapon/cautery
	metal_amount = 5000
	glass_amount = 2500

/datum/autolathe_recipe/hemostat
	name = "hemostat"
	result = /obj/item/weapon/hemostat
	metal_amount = 5000
	glass_amount = 2500

/datum/autolathe_recipe/beaker
	name = "beaker"
	result = /obj/item/weapon/reagent_containers/glass/beaker
	metal_amount = 0
	glass_amount = 500

/datum/autolathe_recipe/large
	name = "large beaker"
	result = /obj/item/weapon/reagent_containers/glass/beaker/large
	metal_amount = 0
	glass_amount = 5000

/datum/autolathe_recipe/vial
	name = "vial"
	result = /obj/item/weapon/reagent_containers/glass/beaker/vial
	metal_amount = 0
	glass_amount = 250

/datum/autolathe_recipe/syringe
	name = "syringe"
	result = /obj/item/weapon/reagent_containers/syringe
	metal_amount = 0
	glass_amount = 150

/datum/autolathe_recipe/beanbag
	name = "beanbag shell"
	result = /obj/item/ammo_casing/shotgun/beanbag
	metal_amount = 500
	glass_amount = 0

/datum/autolathe_recipe/c45r
	name = "Ammunition Box (.45 rubber)"
	result = /obj/item/ammo_box/c45r
	metal_amount = 500
	glass_amount = 0

/datum/autolathe_recipe/c9mmr
	name = "Ammunition Box (9mm rubber)"
	result = /obj/item/ammo_box/c9mmr
	metal_amount = 500
	glass_amount = 0

/datum/autolathe_recipe/taperecorder
	name = "universal recorder"
	result = /obj/item/device/taperecorder
	metal_amount = 60
	glass_amount = 30

/datum/autolathe_recipe/igniter
	name = "igniter"
	result = /obj/item/device/assembly/igniter
	metal_amount = 500
	glass_amount = 50

/datum/autolathe_recipe/signaler
	name = "remote signaling device"
	result = /obj/item/device/assembly/signaler
	metal_amount = 1000
	glass_amount = 200

/datum/autolathe_recipe/headset
	name = "radio headset"
	result = /obj/item/device/radio/headset
	metal_amount = 75
	glass_amount = 0

/datum/autolathe_recipe/voice
	name = "voice analyzer"
	result = /obj/item/device/assembly/voice
	metal_amount = 500
	glass_amount = 50

/datum/autolathe_recipe/radio
	name = "station bounced radio"
	result = /obj/item/device/radio/off
	metal_amount = 75
	glass_amount = 25

/datum/autolathe_recipe/infra
	name = "infrared emitter"
	result = /obj/item/device/assembly/infra
	metal_amount = 1000
	glass_amount = 500

/datum/autolathe_recipe/timer
	name = "timer"
	result = /obj/item/device/assembly/timer
	metal_amount = 500
	glass_amount = 50

/datum/autolathe_recipe/prox_sensor
	name = "proximity sensor"
	result = /obj/item/device/assembly/prox_sensor
	metal_amount = 800
	glass_amount = 200

/datum/autolathe_recipe/tube
	name = "light tube"
	result = /obj/item/weapon/light/tube
	metal_amount = 60
	glass_amount = 100

/datum/autolathe_recipe/bulb
	name = "light bulb"
	result = /obj/item/weapon/light/bulb
	metal_amount = 60
	glass_amount = 100

/datum/autolathe_recipe/ashtray
	name = "glass ashtray"
	result = /obj/item/ashtray/glass
	metal_amount = 0
	glass_amount = 60

/datum/autolathe_recipe/camera_assembly
	name = "camera assembly"
	result = /obj/item/weapon/camera_assembly
	metal_amount = 700
	glass_amount = 300

/datum/autolathe_recipe/shovel
	name = "shovel"
	result = /obj/item/weapon/shovel
	metal_amount = 50
	glass_amount = 0

/datum/autolathe_recipe/minihoe
	name = "mini hoe"
	result = /obj/item/weapon/minihoe
	metal_amount = 2550
	glass_amount = 0

/datum/autolathe_recipe/hand_labeler
	name = "hand labeler"
	result = /obj/item/weapon/hand_labeler
	metal_amount = 800
	glass_amount = 0

/datum/autolathe_recipe/destTagger
	name = "destination tagger"
	result = /obj/item/device/destTagger
	metal_amount = 3000
	glass_amount = 1300

/datum/autolathe_recipe/toy_gun
	name = "cap gun"
	result = /obj/item/toy/gun
	metal_amount = 3250
	glass_amount = 0

/datum/autolathe_recipe/toy_gun_ammo
	name = "ammo-caps"
	result = /obj/item/toy/ammo/gun
	metal_amount = 500
	glass_amount = 0

/datum/autolathe_recipe/random
	name = "gaming kit"
	result = /obj/item/weapon/game_kit/random
	metal_amount = 2000
	glass_amount = 1000

/datum/autolathe_recipe/newscaster_frame
	name = "newscaster frame"
	result = /obj/item/newscaster_frame
	metal_amount = 25000
	glass_amount = 15000

/datum/autolathe_recipe/tabletop_assistant
	name = "tabletop assistant"
	result = /obj/item/device/tabletop_assistant
	metal_amount = 30
	glass_amount = 20

/datum/autolathe_recipe/stack
	var/max_res_amount = 50

/datum/autolathe_recipe/stack/metal
	name = "metal"
	result = /obj/item/stack/sheet/metal
	metal_amount = 3750
	glass_amount = 0

/datum/autolathe_recipe/stack/glass
	name = "glass"
	result = /obj/item/stack/sheet/glass
	metal_amount = 0
	glass_amount = 3750

/datum/autolathe_recipe/stack/rglass
	name = "reinforced glass"
	result = /obj/item/stack/sheet/rglass
	metal_amount = 1875
	glass_amount = 3750

/datum/autolathe_recipe/stack/rods
	name = "metal rod"
	result = /obj/item/stack/rods
	metal_amount = 1875
	glass_amount = 0
	max_res_amount = 60

// Autolathe hidden recipes

/datum/autolathe_recipe/full
	name = "flamethrower"
	result = /obj/item/weapon/flamethrower/full
	metal_amount = 500
	glass_amount = 0

/datum/autolathe_recipe/rcd
	name = "rapid-construction-device (RCD)"
	result = /obj/item/weapon/rcd
	metal_amount = 50000
	glass_amount = 0

/datum/autolathe_recipe/electropack
	name = "electropack"
	result = /obj/item/device/radio/electropack
	metal_amount = 10000
	glass_amount = 2500

/datum/autolathe_recipe/largetank
	name = "industrial welding tool"
	result = /obj/item/weapon/weldingtool/largetank
	metal_amount = 70
	glass_amount = 60

/datum/autolathe_recipe/handcuffs
	name = "handcuffs"
	result = /obj/item/weapon/handcuffs
	metal_amount = 500
	glass_amount = 0

/datum/autolathe_recipe/a357
	name = "speedloader (.357)"
	result = /obj/item/ammo_box/a357
	metal_amount = 500
	glass_amount = 0

/datum/autolathe_recipe/c45
	name = "Ammunition Box (.45)"
	result = /obj/item/ammo_box/c45
	metal_amount = 500
	glass_amount = 0

/datum/autolathe_recipe/c9mm
	name = "Ammunition Box (9mm)"
	result = /obj/item/ammo_box/c9mm
	metal_amount = 500
	glass_amount = 0

/datum/autolathe_recipe/shotgun
	name = "shotgun slug"
	result = /obj/item/ammo_casing/shotgun
	metal_amount = 12500
	glass_amount = 0

/datum/autolathe_recipe/dart
	name = "shotgun darts"
	result = /obj/item/ammo_casing/shotgun/dart
	metal_amount = 12500
	glass_amount = 0

/datum/autolathe_recipe/buckshot
	name = "shotgun shell"
	result = /obj/item/ammo_casing/shotgun/buckshot
	metal_amount = 12500
	glass_amount = 0

/datum/autolathe_recipe/harmonica
	name = "harmonica"
	result = /obj/item/device/harmonica
	metal_amount = 500
	glass_amount = 0

/datum/autolathe_recipe/bell
	name = "bell"
	result = /obj/item/weapon/bell
	metal_amount = 75
	glass_amount = 0
