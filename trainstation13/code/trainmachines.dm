//TRAIN STATION 13

//All unique visible machines are here, while invisible are in trainstation.dm

/obj/machinery/conveyor_switch/oneway/train
	name = "power throttle"
	desc = "A throttle (or regulator) is a handle that controls the speed or direction of rotation in the train engine."
	icon = 'trainstation13/icons/trainmachines.dmi'

/obj/machinery/space_heater/potbellystove
	name = "potbelly stove"
	desc = "This little stove will keep you warm and cozy during cold winter."
	density = TRUE
	icon = 'trainstation13/icons/trainmachines.dmi'
	icon_state = "sheater-off"

/obj/machinery/media/jukebox/train
	name = "wall radio"
	desc = "A modern wall mounted radio with audio visualizer. You see some text in Russian on maintenance panel: \"Не влезай! Убьет!\""
	icon = 'trainstation13/icons/trainmachines.dmi'
	density = 0
	playlist_id="train"
	// Must be defined on your server.
	playlists=list(
		"train"  = "Train Tunes",
		"bar"  = "Bar Mix",
		"mogesfm84"  = "Moghes FM-84",
		"moges" = "Moghes Club Music",
		"club" = "Club Mix",
		"customs" = "Customs Music",
		"japan" = "Banzai Radio",
		"govnar" = "Soviet Radio",
		"classic" = "Classical Music",
		"ussr_disco" = "Disco USSR-89s",
		"topreptilian" = "Top Reptillian",
		"zvukbanok" = "Sounds of beer cans",
		"eurobeat" = "Eurobeat",
		"finland" = "Suomi wave",
		"dreamsofvenus" = "Dreams of Venus",
		"hiphop" = "Hip-Hop for Space Gangstas",
		"vaporfunk" = "Qerrbalak VaporFunkFM",
		"thematic" = "Side-Bursting Tunes",
		"lofi" = "Sadness/Longing/Loneliness",
	)

/obj/machinery/media/jukebox/train/attackby(obj/item/W, mob/user, params)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(iswrenching(W))
		if(user.is_busy(src))
			return
		user.visible_message("<span class='notice'>[user.name] attempts to disassemble \the [src.name].</span>","<span class='notice'>You attempt to disasemble \the [src.name].</span>")
		if(W.use_tool(src, user, 30, volume = 50))
			user.visible_message("<span class='notice'>[user.name] has failed to disassemble \the [src.name]. In Soviet Union [src.name] disassembles you!</span>","<span class='warning'>You have failed to disassemble \the [src.name]. In Soviet Union [src.name] disassembles you!</span>")
			playsound(src, 'sound/effects/sparks4.ogg', VOL_EFFECTS_MASTER)

			Disassemble(user)
	else
		..()

/obj/machinery/media/jukebox/train/proc/Disassemble(mob/living/user)
	if(istype(user))
		user.dust()
	else
		qdel(user)

/obj/machinery/computer/security/wooden_tv/train
	name = "Spektr-88"
	desc = "An old color TV that is still able to receive few analog channels."
	icon_state = "security_det_miami"
	state_broken_preset = null
	state_nopower_preset = null
	light_color = "#f535aa"
	network = list("TV")
	pixel_y = 3

//VENDING

/obj/machinery/vending/hats
	name = "Hat Fortress MK-2"
	desc = "A vending machine for all headwear needs."
	icon = 'trainstation13/icons/trainmachines.dmi'
	icon_state = "ivend"
	product_slogans = "Dress for success!;Prepare to look swagalicious!;Look at all this free swag!;Why leave style up to fate? Hat Fortress MK-2!"
	vend_delay = 15
	vend_reply = "Thank you for using the Hat Fortress 2!"
	products = list(
		/obj/item/clothing/head/det_hat = 5,
		/obj/item/clothing/head/det_hat/gray = 5,
		/obj/item/clothing/head/fedora = 5,
		/obj/item/clothing/head/fedora/black = 5,
		/obj/item/clothing/head/fedora/white = 5,
		/obj/item/clothing/head/fedora/brown = 5,
		/obj/item/clothing/head/hairflower = 5,
		/obj/item/clothing/head/sunflower_crown = 5,
		/obj/item/clothing/head/poppy_crown = 5,
		/obj/item/clothing/head/ushanka = 5,
		/obj/item/clothing/head/ushanka/black = 5,
		/obj/item/clothing/head/ushanka/brown = 5,
		/obj/item/clothing/head/ushanka/black_white = 5,
		/obj/item/clothing/head/ushanka/brown_white = 5,
		/obj/item/clothing/head/soft/rainbow = 5,
		/obj/item/clothing/head/soft/red = 5,
		/obj/item/clothing/head/soft/orange = 5,
		/obj/item/clothing/head/soft/yellow = 5,
		/obj/item/clothing/head/soft/green = 5,
		/obj/item/clothing/head/soft/blue = 5,
		/obj/item/clothing/head/soft/purple = 5,
		/obj/item/clothing/head/soft/grey = 5,
		/obj/item/clothing/head/soft/mime = 5,
		/obj/item/clothing/head/soft/janitor = 5,
		/obj/item/clothing/head/soft/paramed = 5,
		/obj/item/clothing/head/collectable/flatcap = 5,
		/obj/item/clothing/head/beret/paramed = 5,
		/obj/item/clothing/head/beret/eng = 5,
		/obj/item/clothing/head/beret/rosa = 5,
		/obj/item/clothing/head/collectable/beret = 5,
		/obj/item/clothing/head/beret/black = 5,
		/obj/item/clothing/head/beret/purple = 5,
		/obj/item/clothing/head/beret/red = 5,
		/obj/item/clothing/head/beret/blue = 5,
		/obj/item/clothing/head/bandana = 5,
		/obj/item/clothing/head/chep = 5,
		/obj/item/clothing/head/orange_bandana = 5,
		/obj/item/clothing/head/western = 5,
		/obj/item/clothing/head/western/cowboy = 5,
		/obj/item/clothing/head/fez = 5,
		/obj/item/clothing/head/collectable/petehat = 5,
	)

	refill_canister = /obj/item/weapon/vending_refill/clothing
	private = FALSE

/obj/machinery/vending/shoes
	name = "Shoes-4-U"
	desc = "A vending machine for shoes."
	icon = 'trainstation13/icons/trainmachines.dmi'
	icon_state = "shoevend"
	product_slogans = "Dress for success!;Prepare to look swagalicious!;Look at all this free swag!;Why leave style up to fate? Use the Shoes-4-U!"
	vend_delay = 15
	vend_reply = "Thank you for using the Shoes-4-U!"
	products = list(
		/obj/item/clothing/shoes/laceup = 5,
		/obj/item/clothing/shoes/leather = 5,
		/obj/item/clothing/shoes/heels = 5,
		/obj/item/clothing/shoes/heels/alternate = 5,
		/obj/item/clothing/shoes/boots = 5,
		/obj/item/clothing/shoes/boots/German = 5,
		/obj/item/clothing/shoes/boots/work = 5,
		/obj/item/clothing/shoes/cyborg = 5,
		/obj/item/clothing/shoes/winterboots = 5,
		/obj/item/clothing/shoes/black = 5,
		/obj/item/clothing/shoes/white = 5,
		/obj/item/clothing/shoes/red = 5,
		/obj/item/clothing/shoes/brown = 5,
		/obj/item/clothing/shoes/orange = 5,
		/obj/item/clothing/shoes/yellow = 5,
		/obj/item/clothing/shoes/green = 5,
		/obj/item/clothing/shoes/blue = 5,
		/obj/item/clothing/shoes/purple = 5,
		/obj/item/clothing/shoes/kung = 5,
		/obj/item/clothing/shoes/tourist = 5,
		/obj/item/clothing/shoes/sandal = 5,
		/obj/item/clothing/shoes/sandal/brown = 5,
		/obj/item/clothing/shoes/sandal/pink = 5,
		/obj/item/clothing/shoes/jolly_gravedigger = 5,
		/obj/item/clothing/shoes/western = 5,
		/obj/item/clothing/shoes/footwraps = 5,
		/obj/item/clothing/shoes/jackbros = 5,
		/obj/item/clothing/shoes/boxing = 5,
		/obj/item/clothing/shoes/boxing/gray = 5,
		/obj/item/clothing/shoes/boxing/white = 5,
	)

	refill_canister = /obj/item/weapon/vending_refill/clothing
	private = FALSE

/obj/machinery/vending/accessories
	name = "Beauty-Mate"
	desc = "A vending machine for fancy accessories."
	icon = 'trainstation13/icons/trainmachines.dmi'
	icon_state = "elitevend"
	product_slogans = "Dress for success!;Prepare to look swagalicious!;Look at all this free swag!;Why leave style up to fate? Beauty-Mate!"
	vend_delay = 15
	vend_reply = "Thank you for using the Beauty-Mate!"
	products = list(
		/obj/item/clothing/glasses/monocle = 5,
		/obj/item/clothing/glasses/eyepatch = 5,
		/obj/item/clothing/glasses/rosas_eyepatch = 5,
		/obj/item/clothing/glasses/aviator_orange = 5,
		/obj/item/clothing/glasses/sunglasses/big = 5,
		/obj/item/clothing/glasses/sunglasses = 5,
		/obj/item/clothing/glasses/gglasses = 5,
		/obj/item/clothing/glasses/regular/hipster = 5,
		/obj/item/clothing/glasses/aviator_black = 5,
		/obj/item/clothing/glasses/aviator_red = 5,
		/obj/item/clothing/glasses/aviator_mirror = 5,
		/obj/item/clothing/glasses/regular = 5,
		/obj/item/clothing/mask/bandana/black = 5,
		/obj/item/clothing/mask/bandana/skull = 5,
		/obj/item/clothing/mask/bandana/red = 5,
		/obj/item/clothing/mask/bandana/green = 5,
		/obj/item/clothing/mask/bandana/gold = 5,
		/obj/item/clothing/mask/bandana/blue = 5,
		/obj/item/clothing/mask/scarf/blue = 5,
		/obj/item/clothing/mask/scarf/red = 5,
		/obj/item/clothing/mask/scarf/green = 5,
		/obj/item/clothing/mask/scarf/yellow = 5,
		/obj/item/clothing/mask/scarf/violet = 5,
		/obj/item/clothing/gloves/black = 5,
		/obj/item/clothing/gloves/grey = 5,
		/obj/item/clothing/gloves/wrestling = 5,
		/obj/item/clothing/gloves/white = 5,
		/obj/item/clothing/gloves/light_brown = 5,
		/obj/item/clothing/gloves/brown = 5,
		/obj/item/clothing/gloves/red = 5,
		/obj/item/clothing/gloves/orange = 5,
		/obj/item/clothing/gloves/green = 5,
		/obj/item/clothing/gloves/blue = 5,
		/obj/item/clothing/gloves/purple = 5,
		/obj/item/clothing/gloves/fingerless = 5,
		/obj/item/clothing/gloves/fingerless/red = 5,
		/obj/item/clothing/gloves/fingerless/orange = 5,
		/obj/item/clothing/gloves/fingerless/yellow = 5,
		/obj/item/clothing/gloves/fingerless/green = 5,
		/obj/item/clothing/gloves/fingerless/blue = 5,
		/obj/item/clothing/gloves/fingerless/purple = 5,
	)

	refill_canister = /obj/item/weapon/vending_refill/clothing
	private = FALSE

/obj/machinery/vending/elite
	name = "L33T-V3ND"
	desc = "A vending machine for elite clothing."
	icon = 'trainstation13/icons/trainmachines.dmi'
	icon_state = "elitevend"
	product_slogans = "Dress for success!;Prepare to look swagalicious!;Look at all this free swag!;Why leave style up to fate? Use the L33T-V3ND!"
	vend_delay = 15
	vend_reply = "Thank you for using the L33T-V3ND!"
	products = list(
		/obj/item/clothing/under/suit_jacket/really_black = 5,
		/obj/item/clothing/under/gentlesuit = 5,
		/obj/item/clothing/under/mafia/white = 5,
		/obj/item/clothing/under/suit_jacket = 5,
		/obj/item/clothing/under/rank/head_of_personnel = 5,
		/obj/item/clothing/under/rank/head_of_security/turtleneck = 5,
		/obj/item/clothing/under/M35_Jacket_Oficer = 5,
		/obj/item/clothing/under/M35_Jacket = 5,
		/obj/item/clothing/under/suit_jacket/navy = 5,
		/obj/item/clothing/under/suit_jacket/red = 5,
		/obj/item/clothing/under/lawyer/purpsuit = 5,
		/obj/item/clothing/under/det/black = 5,
		/obj/item/clothing/under/lawyer/black = 5,
		/obj/item/clothing/under/dutch = 5,
		/obj/item/clothing/under/suit_jacket/female = 5,
		/obj/item/clothing/under/dress/plaid_purple = 5,
		/obj/item/clothing/under/dress/dress_pink = 5,
		/obj/item/clothing/under/dress/dress_purple = 5,
		/obj/item/clothing/under/wedding/bride_red = 5,
		/obj/item/clothing/under/wedding/bride_blue = 5,
		/obj/item/clothing/under/dress/dress_saloon = 5,
		/obj/item/clothing/under/wedding/bride_orange = 5,
		/obj/item/clothing/under/wedding/bride_purple = 5,
		/obj/item/clothing/under/dress/plaid_red = 5,
		/obj/item/clothing/under/dress/plaid_blue = 5,
		/obj/item/clothing/under/dress/dress_party = 5,
		/obj/item/clothing/under/dress/dress_hop = 5,
		/obj/item/clothing/under/dress/dress_orange = 5,
		/obj/item/clothing/under/dress/dress_cap = 5,
		/obj/item/clothing/under/dress/dress_evening = 5,
		/obj/item/clothing/under/pretty_dress = 5,
		/obj/item/clothing/suit/shawl = 5,
		/obj/item/clothing/suit/storage/labcoat/winterlabcoat = 5,
		/obj/item/clothing/suit/storage/labcoat/rd = 5,
		/obj/item/clothing/suit/hooded/skhima = 5,
		/obj/item/clothing/suit/goodman_jacket = 5,
		/obj/item/clothing/suit/holidaypriest = 5,
		/obj/item/clothing/suit/suspenders = 5,
		/obj/item/clothing/suit/storage/lawyer/purpjacket = 5,
		/obj/item/clothing/suit/storage/labcoat/cmo = 5,
		/obj/item/clothing/suit/hooded/wintercoat/science = 5,
		/obj/item/clothing/suit/storage/det_suit/gray = 5,
		/obj/item/clothing/suit/jacket/leather/overcoat = 5,
		/obj/item/clothing/suit/hooded/nun = 5,
	)

	contraband = list(
		/obj/item/clothing/mask/balaclava = 4,
		/obj/item/clothing/head/tacticool_hat = 4,
		/obj/item/clothing/head/ushanka = 2,
		/obj/item/clothing/under/soviet = 2,
	)
	refill_canister = /obj/item/weapon/vending_refill/clothing
	private = FALSE

/obj/machinery/vending/prole
	name = "Prole-o-Matic"
	icon_state = "clothes"
	desc = "A vending machine for working class clothing."
	product_slogans = "Dress for success!;Prepare to look swagalicious!;Look at all this free swag!;Why leave style up to fate? Use the Prole-o-Matic!"
	vend_delay = 15
	vend_reply = "Thank you for using the Prole-o-Matic!"
	products = list(
		/obj/item/clothing/under/suit_jacket/really_black = 5,
		/obj/item/clothing/under/color/grey = 5,
		/obj/item/clothing/under/cowboy = 5,
		/obj/item/clothing/under/color/yellow = 5,
		/obj/item/clothing/under/darkred = 5,
		/obj/item/clothing/under/lightred = 5,
		/obj/item/clothing/under/yellowgreen = 5,
		/obj/item/clothing/under/rank/engineer = 5,
		/obj/item/clothing/under/brown = 5,
		/obj/item/clothing/under/rank/chef = 5,
		/obj/item/clothing/under/tourist = 5,
		/obj/item/clothing/under/darkblue = 5,
		/obj/item/clothing/under/johnny = 5,
		/obj/item/clothing/under/indiana = 5,
		/obj/item/clothing/under/rank/chaplain/light = 5,
		/obj/item/clothing/under/rank/barber = 5,
		/obj/item/clothing/under/color/red = 5,
		/obj/item/clothing/under/lightblue = 5,
		/obj/item/clothing/under/aqua = 5,
		/obj/item/clothing/under/purple = 5,
		/obj/item/clothing/under/lightpurple = 5,
		/obj/item/clothing/under/color/green = 5,
		/obj/item/clothing/under/sport/blue = 5,
		/obj/item/clothing/under/redcoat = 5,
		/obj/item/clothing/under/color/blue = 5,
		/obj/item/clothing/under/color/black = 5,
		/obj/item/clothing/under/pants/blue_sport = 5,
		/obj/item/clothing/under/sport/black = 5,
		/obj/item/clothing/under/pants/ddr_sport = 5,
		/obj/item/clothing/under/lightbrown = 5,
		/obj/item/clothing/under/sl_suit = 5,
		/obj/item/clothing/under/color/white = 5,
		/obj/item/clothing/gloves/botanic_leather = 5,
		/obj/item/clothing/under/rank/psych/turtleneck = 5,
		/obj/item/clothing/under/suit_jacket/rouge = 5,
		/obj/item/clothing/under/lightgreen = 5,
		/obj/item/clothing/under/rank/postal_dude_shirt = 5,
		/obj/item/clothing/under/det = 5,
		/obj/item/clothing/under/kung = 5,
		/obj/item/clothing/under/cowboy/grey = 5,
		/obj/item/clothing/under/cowboy/brown = 5,
		/obj/item/clothing/under/sport = 5,
		/obj/item/clothing/under/mafia/tan = 5,
		/obj/item/clothing/under/color/blackf = 5,
		/obj/item/clothing/under/rank/research_director/dress_rd = 5,
		/obj/item/clothing/under/dress/cheongsam = 5,
		/obj/item/clothing/under/dress/dress_hr = 5,
		/obj/item/clothing/under/rank/nursesuit = 5,
		/obj/item/clothing/under/dress/dress_summer = 5,
		/obj/item/clothing/under/dress/dress_green = 5,
		/obj/item/clothing/under/dress/dress_fire = 5,
		/obj/item/clothing/under/sukeban_dress = 5,
	)

	contraband = list(
		/obj/item/clothing/mask/balaclava = 4,
		/obj/item/clothing/head/tacticool_hat = 4,
		/obj/item/clothing/head/ushanka = 2,
		/obj/item/clothing/under/soviet = 2,
	)
	refill_canister = /obj/item/weapon/vending_refill/clothing
	private = FALSE