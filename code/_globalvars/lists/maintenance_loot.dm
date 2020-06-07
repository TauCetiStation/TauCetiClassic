//as of:01/05/2020:
//boxstation: 174 loot items spawned
//gammastation: 84 loot items spawned

//how to balance maint loot spawns:
// 1) Ensure each category has items of approximately the same power level
// 2) Tune weight of each category until average power of a maint loot spawn is acceptable
// 3) Mapping considerations - Loot value should scale with difficulty of acquisition, or an assistaint will run through collecting free gear with no risk

//goal of maint loot:
// 1) Provide random equipment to people who take effort to crawl maint
// 2) Create memorable moments with very rare, crazy items

//Loot tables

//junk: useless, very easy to get, or ghetto chemistry items
var/global/list/trash_loot = list(
	list(
		/obj/item/trash/raisins = 1,
		/obj/item/trash/candy = 1,
		/obj/item/trash/candle = 1,
		/obj/item/trash/cheesie = 1,
		/obj/item/trash/chips = 1,
		/obj/item/trash/popcorn = 1,
		/obj/item/trash/sosjerky = 1,
		/obj/item/trash/plate = 1,
		/obj/item/trash/pistachios = 1,
		/obj/item/weapon/poster/contraband = 1,
		/obj/item/weapon/poster/legit = 1,
		/obj/item/weapon/folder/yellow = 1,
		/obj/item/weapon/hand_labeler = 1,
		/obj/item/weapon/pen = 1,
		/obj/item/weapon/paper = 1,
		/obj/item/weapon/paper/crumpled = 1,
		/obj/item/weapon/disk/data = 1,
		/obj/item/stack/sheet/cardboard{amount = 5} = 1,
		/obj/item/weapon/storage/box = 1,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 1,
		/obj/item/weapon/coin/silver = 1,
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/weapon/cigbutt = 1,
		/obj/item/device/camera = 1,
		/obj/item/device/camera_film = 1,
		/obj/item/weapon/light/bulb = 1,
		/obj/item/weapon/light/tube = 1,
		/obj/item/weapon/airlock_painter = 1,
		/obj/item/weapon/rack_parts = 1,
		/obj/item/clothing/mask/breath = 1,
		/obj/item/weapon/shard = 1,
		/obj/item/toy/eight_ball = 1,
		) = 8,

	list(
		/obj/item/weapon/stock_parts/capacitor = 1,
		/obj/item/weapon/stock_parts/scanning_module = 1,
		/obj/item/weapon/stock_parts/manipulator = 1,
		/obj/item/weapon/stock_parts/micro_laser = 1,
		/obj/item/weapon/stock_parts/matter_bin = 1,
		) = 1,
	)



//common: basic items
var/global/list/common_loot = list(
	list(
		/obj/item/weapon/screwdriver = 1,
		/obj/item/weapon/wirecutters = 1,
		/obj/item/weapon/wrench = 1,
		/obj/item/weapon/crowbar = 1,
		/obj/item/device/t_scanner = 1,
		/obj/item/device/analyzer = 1,
		/obj/item/weapon/mop = 1,
		/obj/item/weapon/reagent_containers/glass/bucket = 1,
		/obj/item/toy/crayon/spraycan = 1,
		) = 1,

	list(
		/obj/item/clothing/mask/gas = 1,
		/obj/item/device/radio/headset = 1,
		/obj/item/weapon/storage/backpack = 1,
		/obj/item/clothing/shoes/black = 1,
		/obj/item/clothing/suit/storage/hazardvest = 1,
		/obj/item/clothing/suit/storage/labcoat = 1,
		/obj/item/clothing/under/color/grey = 1,
		/obj/item/clothing/gloves/fyellow = 1,
		/obj/effect/spawner/lootdrop/gloves = 1,
		/obj/item/weapon/storage/wallet = 1,
		/obj/item/clothing/glasses/science = 1,
		/obj/item/clothing/glasses/meson = 1,
		) = 1,

	list(
		/obj/item/stack/cable_coil = 1,
		/obj/item/weapon/stock_parts/cell = 1,
		/obj/item/stack/rods{amount = 25} = 1,
		/obj/item/stack/sheet/metal{amount = 20} = 1,
		/obj/item/stack/sheet/mineral/phoron = 1,
		/obj/item/device/assembly/infra = 1,
		/obj/item/device/assembly/signaler = 1,
		/obj/item/device/assembly/mousetrap = 1,
		/obj/item/device/assembly/prox_sensor = 1,
		/obj/item/device/assembly/timer = 1,
		/obj/item/device/assembly/igniter = 1,
		/obj/item/weapon/packageWrap = 1,
		) = 1,

	list(
		/obj/item/weapon/storage/fancy/cigarettes/dromedaryco = 1,
		/obj/item/weapon/grenade/chem_grenade/cleaner = 1,
		/obj/item/weapon/storage/box/matches = 1,
		/obj/item/weapon/reagent_containers/syringe = 1,
		/obj/item/weapon/reagent_containers/glass/beaker = 1,
		/obj/item/weapon/reagent_containers/glass/rag = 1,
		) = 1,

	list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/beer = 1,
		/obj/item/weapon/reagent_containers/food/drinks/coffee = 1,
		) = 1,

	list(
		/obj/item/device/radio/off = 1,
		/obj/item/weapon/reagent_containers/spray/extinguisher = 1,
		/obj/item/weapon/tank/emergency_oxygen = 1,
		/obj/item/bodybag = 1,
		/obj/item/weapon/grenade/smokebomb = 1,
		/obj/item/weapon/spacecash/c10 = 1,
		/obj/item/device/flashlight = 1,
		/obj/effect/spawner/lootdrop/glowstick = 1,
		/obj/item/clothing/head/hardhat/red = 1,
		/obj/item/device/flashlight/flare = 1,
		) = 1,
	)


//uncommon: useful items
var/global/list/uncommon_loot = list(
	list(
		/obj/item/weapon/weldingtool = 1,
		/obj/item/device/multitool = 1,
		/obj/item/weapon/hatchet = 1,
		/obj/item/roller = 1,
		/obj/item/weapon/legcuffs/bola = 1,
		/obj/item/weapon/handcuffs/cable = 1,
		/obj/item/weapon/twohanded/spear = 1,
		/obj/item/weapon/shield/riot = 1,
		/obj/item/weapon/grenade/cancasing = 1,
		/obj/item/weapon/melee/cattleprod = 1,
		/obj/item/weapon/throwing_star = 1,
		) = 8,

	list(
		/obj/item/clothing/head/welding = 1,
		/obj/item/clothing/glasses/welding = 1,
		/obj/item/clothing/glasses/hud/health = 1,
		/obj/item/weapon/storage/belt/utility = 1,
		/obj/item/weapon/storage/belt/medical = 1,
		/obj/item/clothing/suit/armor/vest = 1,
		/obj/item/clothing/head/helmet = 1,
		/obj/item/clothing/mask/muzzle = 1,
		/obj/item/clothing/ears/earmuffs = 1,
		/obj/item/clothing/gloves/black = 1,
		) = 8,

	list(
		/obj/item/weapon/stock_parts/cell/high = 1,
		/obj/item/stack/sheet/wood{amount = 15} = 1,
		/obj/item/device/radio/beacon = 1,
		) = 8,

	list(
		list(
			/obj/item/stack/medical/ointment = 1,
			/obj/item/stack/medical/bruise_pack = 1,
			) = 1,
		list(
			/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 1,
			/obj/item/weapon/reagent_containers/syringe/inaprovaline = 1,
			) = 1,
		list(
			/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 1,
			/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 1,
			) = 1,
		list(
			/obj/item/weapon/reagent_containers/spray = 1,
			/obj/item/weapon/reagent_containers/watertank_backpack = 1,
			/obj/item/weapon/reagent_containers/watertank_backpack/janitor = 1,
			) = 1,
		) = 8,

	list(
		/obj/item/weapon/storage/box/donkpockets = 1,
		/obj/item/weapon/reagent_containers/food/snacks/monkeycube = 1,
		) = 8,

	list(
		/obj/item/weapon/dice/d20 = 1,
		/obj/item/clothing/shoes/boots = 1,
		) = 1,
)

//oddity: strange or crazy items
var/global/list/oddity_loot = list(
		/obj/item/clothing/gloves/yellow = 1,
		/obj/item/clothing/head/helmet/abductor = 1,
		/obj/item/clothing/head/helmet/helmet_of_justice = 1,
		/obj/item/clothing/suit/space/clown = 1,
		/obj/item/clothing/suit/armor/reactive = 1,
		/obj/item/weapon/storage/pouch/medium_generic = 1,
		/obj/item/weapon/storage/pouch/small_generic = 1,
	)

//Maintenance loot spawner pools
#define maint_trash_weight 4499
#define maint_common_weight 4500
#define maint_uncommon_weight 1000
#define maint_oddity_weight 1 //1 out of 10,000 would give boxstation (174 spawns) a 1 in 52 chance of spawning an oddity per round

//Loot pool used by default maintenance loot spawners
var/global/list/maintenance_loot = list(
	global.trash_loot = maint_trash_weight,
	global.common_loot = maint_common_weight,
	global.uncommon_loot = maint_uncommon_weight,
	global.oddity_loot = maint_oddity_weight,
	)
