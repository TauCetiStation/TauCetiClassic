/datum/gear/flashlight
	display_name = "Flashlight"
	path = /obj/item/device/flashlight

/datum/gear/tabletop
	display_name = "Tabletop Assistant"
	path = /obj/item/device/tabletop_assistant
	cost = 2

/datum/gear/dice
	display_name = "d20"
	path = /obj/item/weapon/dice/d20

/datum/gear/cane
	display_name = "Cane"
	path = /obj/item/weapon/cane

/datum/gear/dice/nerd
	display_name = "Dice pack"
	path = /obj/item/weapon/storage/pill_bottle/dice

/datum/gear/dice/ghastly
	display_name = "Accursed Dice Pack"
	path = /obj/item/weapon/storage/pill_bottle/ghostdice
	allowed_roles = list("Chaplain", "Paranormal Investigator")

/datum/gear/cards
	display_name = "Deck of cards"
	path = /obj/item/toy/cards

/datum/gear/flask
	display_name = "Flask"
	path = /obj/item/weapon/reagent_containers/food/drinks/flask/barflask

/datum/gear/vacflask
	display_name = "Vacuum-flask"
	path = /obj/item/weapon/reagent_containers/food/drinks/flask/vacuumflask

/datum/gear/zippo
	display_name = "Zippo lighter"
	path = /obj/item/weapon/lighter/zippo
	cost = 2

/datum/gear/paicard
	display_name = "PAI device"
	path = /obj/item/device/paicard
	cost = 2

/datum/gear/briefcase
	display_name = "Briefcase"
	path = /obj/item/weapon/storage/briefcase

/datum/gear/electriccig
	display_name = "Electronic cigarette"
	path = /obj/item/clothing/mask/ecig

/datum/gear/game_kit
	display_name = "Gaming Kit Selection"
	path = /obj/item/weapon/game_kit/red
	cost = 3

/datum/gear/game_kit/New()
	..()
	var/game_kits = list()
	game_kits["red"] = /obj/item/weapon/game_kit/red
	game_kits["blue"] = /obj/item/weapon/game_kit/blue
	game_kits["purple"] = /obj/item/weapon/game_kit/purple
	game_kits["orange"] = /obj/item/weapon/game_kit/orange
	gear_tweaks += new/datum/gear_tweak/path(game_kits)

/datum/gear/game_kitchaplain
	display_name = "Ghostly Gaming Kit"
	path = /obj/item/weapon/game_kit/chaplain
	cost = 3
	allowed_roles = list("Chaplain", "Paranormal Investigator")

/datum/gear/ghostpen
	display_name = "One Fancy Pen"
	path = /obj/item/weapon/pen/ghost
	allowed_roles = list("Chaplain", "Paranormal Investigator")

/datum/gear/ghostcamera
	display_name = "Anomalous Camera"
	path = /obj/item/device/camera/spooky
	allowed_roles = list("Chaplain", "Paranormal Investigator")
	cost = 3

/datum/gear/blackcandle
	display_name = "Black Candle"
	path = /obj/item/candle/ghost
	allowed_roles = list("Chaplain", "Paranormal Investigator")

/datum/gear/pulserifle
	display_name = "Pulse rifle"
	path = /obj/item/weapon/gun/energy/pulse_rifle
	cost = 10

/datum/gear/holster
	display_name = "Holster"
	path = /obj/item/clothing/accessory/holster/armpit
	cost = 2
	allowed_roles = list("Captain", "Head of Security", "Head of Personnel", "Warden", "Security Officer", "Detective")
