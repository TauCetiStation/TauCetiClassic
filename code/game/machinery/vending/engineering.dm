/obj/machinery/vending/assist
	products = list(
		/obj/item/device/assembly/prox_sensor = 5,
		/obj/item/device/assembly/igniter = 3,
		/obj/item/device/assembly/signaler = 8,
		/obj/item/weapon/wirecutters = 1,
		/obj/item/weapon/cartridge/signal = 4,
	)
	contraband = list(
		/obj/item/device/assembly/infra = 2,
		/obj/item/device/assembly/voice = 2,
		/obj/item/weapon/stock_parts/cell/high = 2,
		/obj/item/device/flashlight = 3,
		/obj/item/device/assembly/timer = 2,
	)
	premium = list(
		/obj/item/weapon/circuitboard/vendor = 2,
		/obj/item/device/tagger = 2,
	)
	product_ads = "Only the finest!;Have some tools.;The most robust equipment.;The finest gear in space!"
	refill_canister = /obj/item/weapon/vending_refill/assist
	private = FALSE

/obj/machinery/vending/phoronresearch
	name = "Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"
	products = list(
		/obj/item/device/transfer_valve = 6,
		/obj/item/device/assembly/timer = 6,
		/obj/item/device/assembly/signaler = 6,
		/obj/item/device/assembly/prox_sensor = 6,
		/obj/item/device/assembly/igniter = 6,
	)
	private = TRUE

/obj/machinery/vending/tool
	name = "YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	light_color = "#ffcc33"
	icon_deny = "tool-deny"
	//req_access_txt = "12" //Maintenance access
	products = list(
		/obj/item/stack/cable_coil/random = 10,
		/obj/item/weapon/crowbar = 5,
		/obj/item/weapon/weldingtool = 3,
		/obj/item/weapon/weldingtool/largetank = 3,
		/obj/item/weapon/wirecutters = 5,
		/obj/item/weapon/wrench = 5,
		/obj/item/device/analyzer = 5,
		/obj/item/device/t_scanner = 5,
		/obj/item/weapon/screwdriver = 5,
	)
	contraband = list(
		/obj/item/weapon/weldingtool/hugetank = 2,
		/obj/item/clothing/gloves/budget_insulated = 2,
	)
	premium = list(
		/obj/item/clothing/gloves/insulated = 1,
		/obj/item/weapon/gun/energy/pyrometer/engineering = 1,
	)
	prices = list(
		/obj/item/weapon/weldingtool/largetank = 50,
	)
	refill_canister = /obj/item/weapon/vending_refill/tool
	private = TRUE

/obj/machinery/vending/engivend
	name = "Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	light_color = "#ffcc33"
	icon_deny = "engivend-deny"
	req_access = list(11) //Engineering Equipment access
	products = list(
		/obj/item/clothing/glasses/meson = 2,
		/obj/item/clothing/glasses/welding = 2,
		/obj/item/device/multitool = 4,
		/obj/item/weapon/gun/energy/pyrometer/engineering = 4,
		/obj/item/weapon/airlock_electronics = 10,
		/obj/item/weapon/module/power_control = 10,
		/obj/item/weapon/airalarm_electronics = 10,
		/obj/item/weapon/stock_parts/cell/high = 10,
		/obj/item/weapon/stock_parts/scanning_module = 5,
		/obj/item/weapon/stock_parts/micro_laser = 5,
		/obj/item/weapon/stock_parts/capacitor = 5,
		/obj/item/weapon/stock_parts/matter_bin = 5,
		/obj/item/weapon/stock_parts/manipulator = 5,
		/obj/item/weapon/stock_parts/console_screen = 5,
	)
	contraband = list(
		/obj/item/weapon/stock_parts/cell/potato = 3,
		/obj/item/weapon/stock_parts/matter_bin/adv = 3,
		/obj/item/weapon/stock_parts/micro_laser/high = 3,
		/obj/item/weapon/stock_parts/manipulator/nano = 3,
		/obj/item/weapon/stock_parts/capacitor/adv = 2,
		/obj/item/weapon/stock_parts/scanning_module/adv = 2,
	)
	premium = list(
		/obj/item/weapon/storage/belt/utility = 3,
		/obj/item/weapon/storage/part_replacer = 1,
	)
	prices = list(
		/obj/item/clothing/glasses/welding = 200,
	)
	refill_canister = /obj/item/weapon/vending_refill/engivend
	private = TRUE

/obj/machinery/vending/engineering
	name = "Robco Tool Maker"
	desc = "Everything you need for do-it-yourself station repair."
	icon_state = "engi"
	icon_deny = "engi-deny"
	req_access = list(11)
	products = list(
		/obj/item/clothing/under/rank/chief_engineer = 4,
		/obj/item/clothing/under/rank/engineer = 4,
		/obj/item/clothing/shoes/boots/work = 4,
		/obj/item/clothing/head/hardhat/yellow = 4,
		/obj/item/clothing/head/hardhat/yellow/visor = 1,
		/obj/item/weapon/storage/belt/utility = 4,
		/obj/item/clothing/glasses/meson = 4,
		/obj/item/clothing/gloves/insulated = 4,
		/obj/item/weapon/screwdriver = 12,
		/obj/item/weapon/crowbar = 12,
		/obj/item/weapon/wirecutters = 12,
		/obj/item/device/multitool = 12,
		/obj/item/weapon/wrench = 12,
		/obj/item/device/t_scanner = 12,
		/obj/item/stack/cable_coil/heavyduty = 8,
		/obj/item/weapon/stock_parts/cell = 8,
		/obj/item/weapon/weldingtool = 8,
		/obj/item/clothing/head/welding = 8,
		/obj/item/weapon/light/tube = 10,
		/obj/item/clothing/suit/fire = 4,
		/obj/item/weapon/stock_parts/scanning_module = 5,
		/obj/item/weapon/stock_parts/micro_laser = 5,
		/obj/item/weapon/stock_parts/matter_bin = 5,
		/obj/item/weapon/stock_parts/manipulator = 5,
		/obj/item/weapon/stock_parts/console_screen = 5,
		/obj/item/weapon/gun/energy/pyrometer/engineering = 4,
	)
	private = TRUE
	// There was an incorrect entry (cablecoil/power).  I improvised to cablecoil/heavyduty.
	// Another invalid entry, /obj/item/weapon/circuitry.  I don't even know what that would translate to, removed it.
	// The original products list wasn't finished.  The ones without given quantities became quantity 5.  -Sayu

/obj/machinery/vending/robotics
	name = "Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	req_access = list(29)
	products = list(
		/obj/item/stack/cable_coil/random = 2,
		/obj/item/device/flash = 4,
		/obj/item/weapon/stock_parts/cell/high = 5,
		/obj/item/device/assembly/prox_sensor = 3,
		/obj/item/device/assembly/signaler = 3,
		/obj/item/device/healthanalyzer = 3,
		/obj/item/weapon/scalpel = 2,
		/obj/item/weapon/circular_saw = 2,
		/obj/item/weapon/tank/anesthetic = 2,
		/obj/item/clothing/mask/breath/medical = 2,
		/obj/item/weapon/gun/energy/pyrometer/engineering/robotics = 2,
		/obj/item/clothing/glasses/hud/diagnostic = 5,
	)
	private = TRUE
