// Plant analyzer

/obj/item/device/plant_analyzer
	name = "plant analyzer"
	desc = "A hand-held scanner which reports condition of the plant."
	icon = 'icons/obj/device.dmi'
	w_class = ITEM_SIZE_TINY
	m_amt = 200
	g_amt = 50
	origin_tech = "materials=1;biotech=1"
	icon_state = "hydro"
	item_state = "plantanalyzer"

	var/output_to_chat = TRUE

/obj/item/device/plant_analyzer/attack_self(mob/user)
	return FALSE

/obj/item/device/plant_analyzer/verb/toggle_output()
	set name = "Toggle Output"
	set category = "Object"

	output_to_chat = !output_to_chat
	if(output_to_chat)
		to_chat(usr, "The scanner now outputs data to chat.")
	else
		to_chat(usr, "The scanner now outputs data in a seperate window.")

/obj/item/device/plant_analyzer/attack(mob/living/carbon/human/M, mob/living/user)
	if(istype(M) && M.species.flags[IS_PLANT])
		add_fingerprint(user)
		var/dat = health_analyze(M, user, TRUE, output_to_chat) // TRUE means limb-scanning mode
		if(output_to_chat)
			var/datum/browser/popup = new(user, "window=[M.name]_scan_report", "Scan Report", 400, 400)
			popup.set_content(dat)
			popup.open()
			onclose(user, "[M.name]_scan_report")
		else
			to_chat(user, dat)

// ********************************************************
// Here's all the seeds (plants) that can be used in hydro
// ********************************************************

/obj/item/seeds
	name = "pack of seeds"
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed" // unknown plant seed - these shouldn't exist in-game
	w_class = ITEM_SIZE_SMALL // Makes them pocketable
	var/mypath = "/obj/item/seeds"
	var/hydroponictray_icon_path = 'icons/obj/hydroponics/growing.dmi'//this is now path to plant's overlays (in hydropinic tray)
	var/plantname = "Plants"
	var/productname = ""
	var/species = ""
	var/lifespan = 0
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0 // If is -1, the plant/shroom/weed is never meant to be harvested
	var/oneharvest = 0
	var/potency = -1
	var/growthstages = 0
	var/plant_type = 0 // 0 = 'normal plant'; 1 = weed; 2 = shroom
	var/list/mutatelist = list()

/obj/item/seeds/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/plant_analyzer))
		to_chat(user, "*** <B>[plantname]</B> ***")
		to_chat(user, "-Plant Endurance: <span class='notice'>[endurance]</span>")
		to_chat(user, "-Plant Lifespan: <span class='notice'>[lifespan]</span>")
		if(yield != -1)
			to_chat(user, "-Plant Yield: <span class='notice'>[yield]</span>")
		to_chat(user, "-Plant Production: <span class='notice'>[production]</span>")
		if(potency != -1)
			to_chat(user, "-Plant Potency: <span class='notice'>[potency]</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		return
	return ..() // Fallthrough to item/attackby() so that bags can pick seeds up

/obj/item/seeds/blackpepper
	name = "pack of piper nigrum seeds"
	desc = "These seeds grow into black pepper plants. Spicy."
	icon_state = "seed-blackpepper"
	mypath = "/obj/item/seeds/blackpepperseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "blackpepper"
	plantname = "Black Pepper"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/blackpepper"
	lifespan = 55
	endurance = 35
	maturation = 10
	production = 10
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 5

/obj/item/seeds/chiliseed
	name = "pack of chili seeds"
	desc = "These seeds grow into chili plants. HOT! HOT! HOT!"
	icon_state = "seed-chili"
	mypath = "/obj/item/seeds/chiliseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "chili"
	plantname = "Chili Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/chili"
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 4
	potency = 20
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/icepepperseed)

/obj/item/seeds/plastiseed
	name = "pack of plastellium mycelium"
	desc = "This mycelium grows into Plastellium."
	icon_state = "mycelium-plast"
	mypath = "/obj/item/seeds/plastiseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "plastellium"
	plantname = "Plastellium"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium"
	lifespan = 15
	endurance = 17
	maturation = 5
	production = 6
	yield = 6
	oneharvest = 1
	potency = 20
	plant_type = 2
	growthstages = 3

/obj/item/seeds/grapeseed
	name = "pack of grape seeds"
	desc = "These seeds grow into grape vines."
	icon_state = "seed-grapes"
	mypath = "/obj/item/seeds/grapeseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "grape"
	plantname = "Grape Vine"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/grapes"
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 2
	mutatelist = list(/obj/item/seeds/greengrapeseed)

/obj/item/seeds/greengrapeseed
	name = "pack of green grape seeds"
	desc = "These seeds grow into green-grape vines."
	icon_state = "seed-greengrapes"
	mypath = "/obj/item/seeds/greengrapeseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "greengrape"
	plantname = "Green-Grape Vine"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes"
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 2

/obj/item/seeds/cabbageseed
	name = "pack of cabbage seeds"
	desc = "These seeds grow into cabbages."
	icon_state = "seed-cabbage"
	mypath = "/obj/item/seeds/cabbageseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "cabbage"
	plantname = "Cabbages"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage"
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 1

/obj/item/seeds/shandseed
	name = "pack of s'rendarr's hand seeds"
	desc = "These seeds grow into a helpful herb called S'Rendarr's Hand, native to Ahdomai."
	icon_state = "seed-shand"
	mypath = "/obj/item/seeds/shandseed"
	species = "shand"
	plantname = "S'Rendarr's Hand"
	productname = "/obj/item/stack/medical/bruise_pack/tajaran"
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 3

/obj/item/seeds/mtearseed
	name = "pack of messa's tear seeds"
	desc = "These seeds grow into a helpful herb called Messa's Tear, native to Ahdomai."
	icon_state = "seed-mtear"
	mypath = "/obj/item/seeds/mtearseed"
	species = "mtear"
	plantname = "Messa's Tear"
	productname = "/obj/item/stack/medical/ointment/tajaran"
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 3

/obj/item/seeds/berryseed
	name = "pack of berry seeds"
	desc = "These seeds grow into berry bushes."
	icon_state = "seed-berry"
	mypath = "/obj/item/seeds/berryseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "berry"
	plantname = "Berry Bush"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/berries"
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/glowberryseed,/obj/item/seeds/poisonberryseed)

/obj/item/seeds/glowberryseed
	name = "pack of glow-berry seeds"
	desc = "These seeds grow into glow-berry bushes."
	icon_state = "seed-glowberry"
	mypath = "/obj/item/seeds/glowberryseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "glowberry"
	plantname = "Glow-Berry Bush"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries"
	lifespan = 30
	endurance = 25
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/bananaseed
	name = "pack of banana seeds"
	desc = "They're seeds that grow into banana trees."
	icon_state = "seed-banana"
	mypath = "/obj/item/seeds/bananaseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "banana"
	plantname = "Banana Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/banana"
	lifespan = 50
	endurance = 30
	maturation = 6
	production = 6
	yield = 3
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/honkyseed)

/obj/item/seeds/honkyseed
	name = "pack of honk-banana seeds"
	desc = "They're seeds that grow into banana trees."
	icon_state = "seed-banana-honk"
	mypath = "/obj/item/seeds/honkyseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "honk"
	plantname = "Honk banana Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk"
	lifespan = 50
	endurance = 30
	maturation = 6
	production = 6
	yield = 3
	plant_type = 0
	growthstages = 6

/obj/item/seeds/eggplantseed
	name = "pack of eggplant seeds"
	desc = "These seeds grow to produce berries that look nothing like eggs."
	icon_state = "seed-eggplant"
	mypath = "/obj/item/seeds/eggplantseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "eggplant"
	plantname = "Eggplants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant"
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 6
	yield = 2
	potency = 20
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/eggyseed)

/obj/item/seeds/eggyseed
	name = "pack of eggplant seeds"
	desc = "These seeds grow to produce berries that look a lot like eggs."
	icon_state = "seed-eggy"
	mypath = "/obj/item/seeds/eggy"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "eggy"
	plantname = "Eggplants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/egg"
	lifespan = 75
	endurance = 15
	maturation = 6
	production = 12
	yield = 2
	plant_type = 0
	growthstages = 6

/obj/item/seeds/bloodtomatoseed
	name = "pack of blood-tomato seeds"
	desc = "These seeds grow into blood-tomato plants."
	icon_state = "seed-bloodtomato"
	mypath = "/obj/item/seeds/bloodtomatoseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "bloodtomato"
	plantname = "Blood-Tomato Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato"
	lifespan = 25
	endurance = 20
	maturation = 8
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/tomatoseed
	name = "pack of tomato seeds"
	desc = "These seeds grow into tomato plants."
	icon_state = "seed-tomato"
	mypath = "/obj/item/seeds/tomatoseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "tomato"
	plantname = "Tomato Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/tomato"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/bluetomatoseed, /obj/item/seeds/bloodtomatoseed, /obj/item/seeds/killertomatoseed)

/obj/item/seeds/killertomatoseed
	name = "pack of killer-tomato seeds"
	desc = "These seeds grow into killer-tomato plants."
	icon_state = "seed-killertomato"
	mypath = "/obj/item/seeds/killertomatoseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "killertomato"
	plantname = "Killer-Tomato Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	oneharvest = 1
	growthstages = 2

/obj/item/seeds/bluetomatoseed
	name = "pack of blue-tomato seeds"
	desc = "These seeds grow into blue-tomato plants."
	icon_state = "seed-bluetomato"
	mypath = "/obj/item/seeds/bluetomatoseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "bluetomato"
	plantname = "Blue-Tomato Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/bluespacetomatoseed)

/obj/item/seeds/bluespacetomatoseed
	name = "pack of blue-space tomato seeds"
	desc = "These seeds grow into blue-space tomato plants."
	icon_state = "seed-bluespacetomato"
	mypath = "/obj/item/seeds/bluespacetomatoseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "bluespacetomato"
	plantname = "Blue-Space Tomato Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/cornseed
	name = "pack of corn seeds"
	desc = "I don't mean to sound corny..."
	icon_state = "seed-corn"
	mypath = "/obj/item/seeds/cornseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "corn"
	plantname = "Corn Stalks"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/corn"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 3
	plant_type = 0
	oneharvest = 1
	potency = 20
	growthstages = 3

/obj/item/seeds/poppyseed
	name = "pack of poppy seeds"
	desc = "These seeds grow into poppies."
	icon_state = "seed-poppy"
	mypath = "/obj/item/seeds/poppyseed"
	species = "poppy"
	plantname = "Poppy Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/poppy"
	lifespan = 25
	endurance = 10
	potency = 20
	maturation = 8
	production = 6
	yield = 6
	plant_type = 0
	oneharvest = 1
	growthstages = 3

/obj/item/seeds/potatoseed
	name = "pack of potato seeds"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "seed-potato"
	mypath = "/obj/item/seeds/potatoseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "potato"
	plantname = "Potato-Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/potato"
	lifespan = 30
	endurance = 15
	maturation = 10
	production = 1
	yield = 4
	plant_type = 0
	oneharvest = 1
	potency = 10
	growthstages = 4

/obj/item/seeds/icepepperseed
	name = "pack of ice-pepper seeds"
	desc = "These seeds grow into ice-pepper plants."
	icon_state = "seed-icepepper"
	mypath = "/obj/item/seeds/icepepperseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "chiliice"
	plantname = "Ice-Pepper Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper"
	lifespan = 25
	endurance = 15
	maturation = 4
	production = 4
	yield = 4
	potency = 20
	plant_type = 0
	growthstages = 6

/obj/item/seeds/soyaseed
	name = "pack of soybean seeds"
	desc = "These seeds grow into soybean plants."
	icon_state = "seed-soybean"
	mypath = "/obj/item/seeds/soyaseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "soybean"
	plantname = "Soybean Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans"
	lifespan = 25
	endurance = 15
	maturation = 4
	production = 4
	yield = 3
	potency = 5
	plant_type = 0
	growthstages = 6

/obj/item/seeds/wheatseed
	name = "pack of wheat seeds"
	desc = "These may, or may not, grow into weed."
	icon_state = "seed-wheat"
	mypath = "/obj/item/seeds/wheatseed"
	species = "wheat"
	plantname = "Wheat Stalks"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/wheat"
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 1
	yield = 4
	potency = 5
	oneharvest = 1
	plant_type = 0
	growthstages = 6

/obj/item/seeds/riceseed
	name = "pack of rice seeds"
	desc = "These seeds grow into rice stalks."
	icon_state = "seed-rice"
	mypath = "/obj/item/seeds/riceseed"
	species = "rice"
	plantname = "Rice Stalks"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk"
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 1
	yield = 4
	potency = 5
	oneharvest = 1
	plant_type = 0
	growthstages = 4

/obj/item/seeds/carrotseed
	name = "pack of carrot seeds"
	desc = "These seeds grow into carrots."
	icon_state = "seed-carrot"
	mypath = "/obj/item/seeds/carrotseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "carrot"
	plantname = "Carrots"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/carrot"
	lifespan = 25
	endurance = 15
	maturation = 10
	production = 1
	yield = 5
	potency = 10
	oneharvest = 1
	plant_type = 0
	growthstages = 3

/obj/item/seeds/reishimycelium
	name = "pack of reishi mycelium"
	desc = "This mycelium grows into something relaxing."
	icon_state = "mycelium-reishi"
	mypath = "/obj/item/seeds/reishimycelium"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "reishi"
	plantname = "Reishi"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi"
	lifespan = 35
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	potency = 15 // Sleeping based on potency?
	oneharvest = 1
	growthstages = 4
	plant_type = 2

/obj/item/seeds/amanitamycelium
	name = "pack of fly amanita mycelium"
	desc = "This mycelium grows into something horrible."
	icon_state = "mycelium-amanita"
	mypath = "/obj/item/seeds/amanitamycelium"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "amanita"
	plantname = "Fly Amanitas"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita"
	lifespan = 50
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	potency = 10 // Damage based on potency?
	oneharvest = 1
	growthstages = 3
	plant_type = 2
	mutatelist = list(/obj/item/seeds/angelmycelium)

/obj/item/seeds/angelmycelium
	name = "pack of destroying angel mycelium"
	desc = "This mycelium grows into something devestating."
	icon_state = "mycelium-angel"
	mypath = "/obj/item/seeds/angelmycelium"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "angel"
	plantname = "Destroying Angels"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel"
	lifespan = 50
	endurance = 35
	maturation = 12
	production = 5
	yield = 2
	potency = 35
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/libertymycelium
	name = "pack of liberty-cap mycelium"
	desc = "This mycelium grows into liberty-cap mushrooms."
	icon_state = "mycelium-liberty"
	mypath = "/obj/item/seeds/libertymycelium"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "liberty"
	plantname = "Liberty-Caps"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap"
	lifespan = 25
	endurance = 15
	maturation = 7
	production = 1
	yield = 5
	potency = 15 // Lowish potency at start
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/chantermycelium
	name = "pack of chanterelle mycelium"
	desc = "This mycelium grows into chanterelle mushrooms."
	icon_state = "mycelium-chanter"
	mypath = "/obj/item/seeds/chantermycelium"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "chanter"
	plantname = "Chanterelle Mushrooms"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle"
	lifespan = 35
	endurance = 20
	maturation = 7
	production = 1
	yield = 5
	potency = 1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/towermycelium
	name = "pack of tower-cap mycelium"
	desc = "This mycelium grows into tower-cap mushrooms."
	icon_state = "mycelium-tower"
	mypath = "/obj/item/seeds/towermycelium"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "towercap"
	plantname = "Tower Caps"
	productname = "/obj/item/weapon/grown/log"
	lifespan = 80
	endurance = 50
	maturation = 15
	production = 1
	yield = 5
	potency = 1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/glowshroom
	name = "pack of glowshroom mycelium"
	desc = "This mycelium -glows- into mushrooms!"
	icon_state = "mycelium-glowshroom"
	mypath = "/obj/item/seeds/glowshroom"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "glowshroom"
	plantname = "Glowshrooms"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom"
	lifespan = 120 //ten times that is the delay
	endurance = 30
	maturation = 15
	production = 1
	yield = 3 //-> spread
	potency = 30 //-> brightness
	oneharvest = 1
	growthstages = 4
	plant_type = 2

/obj/item/seeds/plumpmycelium
	name = "pack of plump-helmet mycelium"
	desc = "This mycelium grows into helmets... maybe."
	icon_state = "mycelium-plump"
	mypath = "/obj/item/seeds/plumpmycelium"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "plump"
	plantname = "Plump-Helmet Mushrooms"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet"
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 1
	yield = 4
	potency = 0
	oneharvest = 1
	growthstages = 3
	plant_type = 2
	mutatelist = list(/obj/item/seeds/walkingmushroommycelium)

/obj/item/seeds/walkingmushroommycelium
	name = "pack of walking mushroom mycelium"
	desc = "This mycelium will grow into huge stuff!"
	icon_state = "mycelium-walkingmushroom"
	mypath = "/obj/item/seeds/walkingmushroommycelium"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "walkingmushroom"
	plantname = "Walking Mushrooms"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom"
	lifespan = 30
	endurance = 30
	maturation = 5
	production = 1
	yield = 1
	potency = 0
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/nettleseed
	name = "pack of nettle seeds"
	desc = "These seeds grow into nettles."
	icon_state = "seed-nettle"
	mypath = "/obj/item/seeds/nettleseed"
	species = "nettle"
	plantname = "Nettles"
	productname = "/obj/item/weapon/grown/nettle"
	lifespan = 30
	endurance = 40 // tuff like a toiger
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	oneharvest = 0
	growthstages = 5
	plant_type = 1
	mutatelist = list(/obj/item/seeds/deathnettleseed)

/obj/item/seeds/deathnettleseed
	name = "pack of death-nettle seeds"
	desc = "These seeds grow into death-nettles."
	icon_state = "seed-deathnettle"
	mypath = "/obj/item/seeds/deathnettleseed"
	species = "deathnettle"
	plantname = "Death Nettles"
	productname = "/obj/item/weapon/grown/deathnettle"
	lifespan = 30
	endurance = 25
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	oneharvest = 0
	growthstages = 5
	plant_type = 1

/obj/item/seeds/weeds
	name = "pack of weed seeds"
	desc = "Yo mang, want some weeds?"
	icon_state = "seed"
	mypath = "/obj/item/seeds/weeds"
	species = "weeds"
	plantname = "Starthistle"
	productname = ""
	lifespan = 100
	endurance = 50 // damm pesky weeds
	maturation = 5
	production = 1
	yield = -1
	potency = -1
	oneharvest = 1
	growthstages = 4
	plant_type = 1

/obj/item/seeds/harebell
	name = "pack of harebell seeds"
	desc = "These seeds grow into pretty little flowers."
	icon_state = "seed-harebell"
	mypath = "/obj/item/seeds/harebell"
	species = "harebell"
	plantname = "Harebells"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/harebell"
	lifespan = 100
	endurance = 20
	maturation = 7
	production = 1
	yield = 2
	potency = 1
	oneharvest = 1
	growthstages = 4
	plant_type = 1

/obj/item/seeds/sunflowerseed
	name = "pack of sunflower seeds"
	desc = "These seeds grow into sunflowers."
	icon_state = "seed-sunflower"
	mypath = "/obj/item/seeds/sunflowerseed"
	species = "sunflower"
	plantname = "Sunflowers"
	productname = "/obj/item/weapon/grown/sunflower"
	lifespan = 25
	endurance = 20
	maturation = 6
	production = 1
	yield = 2
	potency = 1
	oneharvest = 1
	growthstages = 3
	plant_type = 1

/obj/item/seeds/brownmold
	name = "pack of brown mold"
	desc = "Eww.. moldy."
	icon_state = "seed"
	mypath = "/obj/item/seeds/brownmold"
	species = "mold"
	plantname = "Brown Mold"
	productname = ""
	lifespan = 50
	endurance = 30
	maturation = 10
	production = 1
	yield = -1
	potency = 1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/appleseed
	name = "pack of apple seeds"
	desc = "These seeds grow into apple trees."
	icon_state = "seed-apple"
	mypath = "/obj/item/seeds/appleseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "apple"
	plantname = "Apple Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/apple"
	lifespan = 55
	endurance = 35
	maturation = 6
	production = 6
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/goldappleseed, /obj/item/seeds/poisonedappleseed)

/obj/item/seeds/poisonedappleseed
	name = "pack of apple seeds"
	desc = "These seeds grow into apple trees."
	icon_state = "seed-apple"
	mypath = "/obj/item/seeds/poisonedappleseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "apple"
	plantname = "Apple Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned"
	lifespan = 55
	endurance = 35
	maturation = 6
	production = 6
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/goldappleseed
	name = "pack of golden apple seeds"
	desc = "These seeds grow into golden apple trees. Good thing there are no firebirds in space."
	icon_state = "seed-goldapple"
	mypath = "/obj/item/seeds/goldappleseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "goldapple"
	plantname = "Golden Apple Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple"
	lifespan = 55
	endurance = 35
	maturation = 10
	production = 10
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/ambrosiavulgarisseed
	name = "pack of ambrosia vulgaris seeds"
	desc = "These seeds grow into common ambrosia, a plant grown by and from medicine."
	icon_state = "seed-ambrosiavulgaris"
	mypath = "/obj/item/seeds/ambrosiavulgarisseed"
	species = "ambrosiavulgaris"
	plantname = "Ambrosia Vulgaris"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris"
	lifespan = 60
	endurance = 25
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/ambrosiadeusseed)

/obj/item/seeds/ambrosiadeusseed
	name = "pack of ambrosia deus seeds"
	desc = "These seeds grow into ambrosia deus. Could it be the food of the gods..?"
	icon_state = "seed-ambrosiadeus"
	mypath = "/obj/item/seeds/ambrosiadeusseed"
	species = "ambrosiadeus"
	plantname = "Ambrosia Deus"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus"
	lifespan = 60
	endurance = 25
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	plant_type = 0
	growthstages = 6

/obj/item/seeds/whitebeetseed
	name = "pack of white-beet seeds"
	desc = "These seeds grow into sugary beet producing plants."
	icon_state = "seed-whitebeet"
	mypath = "/obj/item/seeds/whitebeetseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "whitebeet"
	plantname = "White-Beet Plants"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet"
	lifespan = 60
	endurance = 50
	maturation = 6
	production = 6
	yield = 6
	oneharvest = 1
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/sugarcaneseed
	name = "pack of sugarcane seeds"
	desc = "These seeds grow into sugarcane."
	icon_state = "seed-sugarcane"
	mypath = "/obj/item/seeds/sugarcaneseed"
	species = "sugarcane"
	plantname = "Sugarcane"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane"
	lifespan = 60
	endurance = 50
	maturation = 3
	production = 6
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 3

/obj/item/seeds/watermelonseed
	name = "pack of watermelon seeds"
	desc = "These seeds grow into watermelon plants."
	icon_state = "seed-watermelon"
	mypath = "/obj/item/seeds/watermelonseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "watermelon"
	plantname = "Watermelon Vines"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon"
	lifespan = 50
	endurance = 40
	maturation = 6
	production = 6
	yield = 3
	potency = 1
	plant_type = 0
	growthstages = 6

/obj/item/seeds/pumpkinseed
	name = "pack of pumpkin seeds"
	desc = "These seeds grow into pumpkin vines."
	icon_state = "seed-pumpkin"
	mypath = "/obj/item/seeds/pumpkinseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "pumpkin"
	plantname = "Pumpkin Vines"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin"
	lifespan = 50
	endurance = 40
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 3


/obj/item/seeds/limeseed
	name = "pack of lime seeds"
	desc = "These are very sour seeds."
	icon_state = "seed-lime"
	mypath = "/obj/item/seeds/limeseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "lime"
	plantname = "Lime Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/lime"
	lifespan = 55
	endurance = 50
	maturation = 6
	production = 6
	yield = 4
	potency = 15
	plant_type = 0
	growthstages = 6

/obj/item/seeds/lemonseed
	name = "pack of lemon seeds"
	desc = "These are sour seeds."
	icon_state = "seed-lemon"
	mypath = "/obj/item/seeds/lemonseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "lemon"
	plantname = "Lemon Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/lemon"
	lifespan = 55
	endurance = 45
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/cashseed)

/obj/item/seeds/cashseed
	name = "pack of money seeds"
	desc = "When life gives you lemons, mutate them into cash."
	icon_state = "seed-cash"
	mypath = "/obj/item/seeds/cashseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "cashtree"
	plantname = "Money Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/money"
	lifespan = 55
	endurance = 45
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/orangeseed
	name = "pack of orange seed"
	desc = "Sour seeds."
	icon_state = "seed-orange"
	mypath = "/obj/item/seeds/orangeseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "orange"
	plantname = "Orange Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/orange"
	lifespan = 60
	endurance = 50
	maturation = 6
	production = 6
	yield = 5
	potency = 1
	plant_type = 0
	growthstages = 6

/obj/item/seeds/poisonberryseed
	name = "pack of poison-berry seeds"
	desc = "These seeds grow into poison-berry bushes."
	icon_state = "seed-poisonberry"
	mypath = "/obj/item/seeds/poisonberryseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "poisonberry"
	plantname = "Poison-Berry Bush"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries"
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/deathberryseed)

/obj/item/seeds/deathberryseed
	name = "pack of death-berry seeds"
	desc = "These seeds grow into death berries."
	icon_state = "seed-deathberry"
	mypath = "/obj/item/seeds/deathberryseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "deathberry"
	plantname = "Death Berry Bush"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/deathberries"
	lifespan = 30
	endurance = 20
	maturation = 5
	production = 5
	yield = 3
	potency = 50
	plant_type = 0
	growthstages = 6

/obj/item/seeds/grassseed
	name = "pack of grass seeds"
	desc = "These seeds grow into grass. Yummy!"
	icon_state = "seed-grass"
	mypath = "/obj/item/seeds/grassseed"
	species = "grass"
	plantname = "Grass"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/grass"
	lifespan = 60
	endurance = 50
	maturation = 2
	production = 5
	yield = 5
	plant_type = 0
	growthstages = 2

/obj/item/seeds/cocoapodseed
	name = "pack of cocoa pod seeds"
	desc = "These seeds grow into cacao trees. They look fattening." //SIC: cocoa is the seeds. The tress ARE spelled cacao.
	icon_state = "seed-cocoapod"
	mypath = "/obj/item/seeds/cocoapodseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "cocoapod"
	plantname = "Cocoa Tree" //SIC: see above
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod"
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 5

/obj/item/seeds/cherryseed
	name = "pack of cherry pits"
	desc = "Careful not to crack a tooth on one... That'd be the pits."
	icon_state = "seed-cherry"
	mypath = "/obj/item/seeds/cherryseed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "cherry"
	plantname = "Cherry Tree"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/cherries"
	lifespan = 35
	endurance = 35
	maturation = 5
	production = 5
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 5

/obj/item/seeds/kudzuseed
	name = "pack of kudzu seeds"
	desc = "These seeds grow into a weed that grows incredibly fast."
	icon_state = "seed-kudzu"
	mypath = "/obj/item/seeds/kudzuseed"
	species = "kudzu"
	plantname = "Kudzu"
	productname = "/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod"
	lifespan = 20
	endurance = 10
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	growthstages = 4
	plant_type = 1

/obj/item/seeds/kudzuseed/attack_self(mob/user)
	if(istype(user.loc,/turf/space) || istype(user.loc,/turf/simulated/shuttle))
		to_chat(user, "<span class='notice'>You cannot plant kudzu on a moving shuttle or space.</span>")
		return
	to_chat(user, "<span class='notice'>You plant the kudzu. You monster.</span>")
	new /obj/effect/spacevine_controller(user.loc)
	qdel(src)

// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/weapons.dmi'
	var/seed = ""
	var/plantname = ""
	var/productname = ""
	var/species = ""
	var/lifespan = 20
	var/endurance = 15
	var/maturation = 7
	var/production = 7
	var/yield = 2
	var/potency = 1
	var/plant_type = 0

/obj/item/weapon/grown/atom_init()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	. = ..()

/obj/item/weapon/grown/proc/changePotency(newValue)
	potency = newValue

/obj/item/weapon/grown/log
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "logs"
	force = 5
	throwforce = 5
	w_class = ITEM_SIZE_NORMAL
	throw_speed = 3
	throw_range = 3
	plant_type = 2
	origin_tech = "materials=1"
	seed = "/obj/item/seeds/towermycelium"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")

/obj/item/weapon/grown/log/attackby(obj/item/I, mob/user, params)
	if(I.sharp && I.edge && I.force > 10)
		user.SetNextMove(CLICK_CD_INTERACT)
		to_chat(user, "<span class='notice'>You make planks out of \the [src]!</span>")
		for(var/i in 1 to 2)
			new/obj/item/stack/sheet/wood(user.loc)
		qdel(src)
		return
	return ..()


/obj/item/weapon/grown/sunflower
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "sunflower"
	damtype = "fire"
	force = 0
	throwforce = 1
	w_class = ITEM_SIZE_TINY
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	seed = "/obj/item/seeds/sunflower"

/obj/item/weapon/grown/nettle
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/weapons.dmi'
	name = "nettle"
	icon_state = "nettle"
	damtype = "fire"
	force = 15
	throwforce = 1
	w_class = ITEM_SIZE_SMALL
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	origin_tech = "combat=1"
	seed = "/obj/item/seeds/nettleseed"

/obj/item/weapon/grown/nettle/atom_init()
	. = ..()
	spawn(5)
		reagents.add_reagent("nutriment", 1 + round((potency / 50), 1))
		reagents.add_reagent("sacid", round(potency, 1))
		force = round((5 + potency / 5), 1)

/obj/item/weapon/grown/deathnettle
	desc = "The <span class='warning'>glowing</span> nettle incites <span class='warning'><B>rage</B></span> in you just from looking at it!"
	icon = 'icons/obj/weapons.dmi'
	name = "deathnettle"
	icon_state = "deathnettle"
	damtype = "fire"
	force = 30
	throwforce = 1
	w_class = ITEM_SIZE_SMALL
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	seed = "/obj/item/seeds/deathnettleseed"
	origin_tech = "combat=3"
	attack_verb = list("stung")

/obj/item/weapon/grown/deathnettle/atom_init()
	. = ..()
	spawn(5)
		reagents.add_reagent("nutriment", 1 + round((potency / 50), 1))
		reagents.add_reagent("pacid", round(potency, 1))
		force = round((5 + potency / 2.5), 1)

/obj/item/weapon/grown/deathnettle/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] is eating some of the [src.name]! It looks like \he's trying to commit suicide.</b></span>")
	return (BRUTELOSS | TOXLOSS)

// *************************************
// Pestkiller defines for hydroponics
// *************************************

/obj/item/pestkiller
	name = "bottle of pestkiller"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	var/toxicity = 0
	var/PestKillStr = 0

/obj/item/pestkiller/atom_init()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

/obj/item/pestkiller/carbaryl
	name = "bottle of carbaryl"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	toxicity = 4
	PestKillStr = 2

/obj/item/pestkiller/lindane
	name = "bottle of lindane"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	toxicity = 6
	PestKillStr = 4

/obj/item/pestkiller/phosmet
	name = "bottle of phosmet"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	toxicity = 8
	PestKillStr = 7

// *************************************
// Hydroponics Tools
// *************************************

/obj/item/weapon/weedspray
	desc = "It's a toxic mixture, in spray form, to kill small weeds."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "weed-spray"
	icon_state = "weedspray"
	item_state = "spray"
	flags = OPENCONTAINER | NOBLUDGEON
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 4
	w_class = ITEM_SIZE_SMALL
	throw_speed = 2
	throw_range = 10
	var/toxicity = 4
	var/WeedKillStr = 2

/obj/item/weapon/weedspray/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] is huffing the [src.name]! It looks like \he's trying to commit suicide.</b></span>")
	return (TOXLOSS)

/obj/item/weapon/pestspray // -- Skie
	desc = "It's some pest eliminator spray! <I>Do not inhale!</I>"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "pest-spray"
	icon_state = "pestspray"
	item_state = "spraycan"
	flags = OPENCONTAINER | NOBLUDGEON
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 4
	w_class = ITEM_SIZE_SMALL
	throw_speed = 2
	throw_range = 10
	var/toxicity = 4
	var/PestKillStr = 2

/obj/item/weapon/pestspray/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] is huffing the [src.name]! It looks like \he's trying to commit suicide.</b></span>")
	return (TOXLOSS)

/obj/item/weapon/minihoe // -- Numbers
	name = "mini hoe"
	desc = "It's used for removing weeds or scratching your back."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hoe"
	item_state = "hoe"
	flags = CONDUCT | NOBLUDGEON
	force = 5.0
	throwforce = 7.0
	w_class = ITEM_SIZE_SMALL
	m_amt = 2550
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("slashed", "sliced", "cut", "clawed")

// *************************************
// Weedkiller defines for hydroponics
// *************************************

/obj/item/weedkiller
	name = "bottle of weedkiller"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	var/toxicity = 0
	var/WeedKillStr = 0

/obj/item/weedkiller/triclopyr
	name = "bottle of glyphosate"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	toxicity = 4
	WeedKillStr = 2

/obj/item/weedkiller/lindane
	name = "bottle of triclopyr"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	toxicity = 6
	WeedKillStr = 4

/obj/item/weedkiller/D24
	name = "bottle of 2,4-D"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	toxicity = 8
	WeedKillStr = 7

// *************************************
// Nutrient defines for hydroponics
// *************************************

/obj/item/nutrient
	name = "bottle of nutrient"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	w_class = ITEM_SIZE_SMALL
	var/mutmod = 0
	var/yieldmod = 0

/obj/item/nutrient/atom_init()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

/obj/item/nutrient/ez
	name = "bottle of E-Z-Nutrient"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	mutmod = 1
	yieldmod = 1

/obj/item/nutrient/l4z
	name = "bottle of Left 4 Zed"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	mutmod = 2
	yieldmod = 0

/obj/item/nutrient/rh
	name = "bottle of Robust Harvest"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	mutmod = 0
	yieldmod = 2
