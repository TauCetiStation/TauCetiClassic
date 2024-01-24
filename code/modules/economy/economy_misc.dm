
#define RIOTS 1
#define WILD_ANIMAL_ATTACK 2
#define INDUSTRIAL_ACCIDENT 3
#define BIOHAZARD_OUTBREAK 4
#define WARSHIPS_ARRIVE 5
#define PIRATES 6
#define CORPORATE_ATTACK 7
#define ALIEN_RAIDERS 8
#define AI_LIBERATION 9
#define MOURNING 10
#define CULT_CELL_REVEALED 11
#define SECURITY_BREACH 12
#define ANIMAL_RIGHTS_RAID 13
#define FESTIVAL 14

#define RESEARCH_BREAKTHROUGH 15
#define BARGAINS 16
#define SONG_DEBUT 17
#define MOVIE_RELEASE 18
#define BIG_GAME_HUNTERS 19
#define ELECTION 20
#define GOSSIP 21
#define TOURISM 22
#define CELEBRITY_DEATH 23
#define RESIGNATION 24

#define DEFAULT 1

#define ADMINISTRATIVE 2
#define CLOTHING 3
#define SECURITY 4
#define SPECIAL_SECURITY 5

#define FOOD 6
#define ANIMALS 7

#define MINERALS 8

#define EMERGENCY 9
#define VESPENE_GAS 10
#define MAINTENANCE 11
#define ELECTRICAL 12
#define ROBOTICS 13
#define BIOMEDICAL 14

#define GEAR_EVA 15

//---- The following corporations are friendly with NanoTrasen and loosely enable trade and travel:
//Corporation NanoTrasen - Generalised / high tech research and phoron exploitation.
//Corporation Vessel Contracting - Ship and station construction, materials research.
//Corporation Osiris Atmospherics - Atmospherics machinery construction and chemical research.
//Corporation Second Red Cross Society - 26th century Red Cross reborn as a dominating economic force in biomedical science (research and materials).
//Corporation Blue Industries - High tech and high energy research, in particular into the mysteries of bluespace manipulation and power generation.
//Corporation Kusanagi Robotics - Founded by robotics legend Kaito Kusanagi in the 2070s, they have been on the forefront of mechanical augmentation and robotics development ever since.
//Corporation Free traders - Not so much a corporation as a loose coalition of spacers, Free Traders are a roving band of smugglers, traders and fringe elements following a rigid (if informal) code of loyalty and honour. Mistrusted by most corporations, they are tolerated because of their uncanny ability to smell out a profit.

//---- Descriptions of destination types
//Space stations can be purpose built for a number of different things, but generally require regular shipments of essential supplies.
//Corvettes are small, fast warships generally assigned to border patrol or chasing down smugglers.
//Battleships are large, heavy cruisers designed for slugging it out with other heavies or razing planets.
//Yachts are fast civilian craft, often used for pleasure or smuggling.
//Destroyers are medium sized vessels, often used for escorting larger ships but able to go toe-to-toe with them if need be.
//Frigates are medium sized vessels, often used for escorting larger ships. They will rapidly find themselves outclassed if forced to face heavy warships head on.

var/global/current_date_string

var/global/datum/money_account/vendor_account
var/global/datum/money_account/cargo_account
var/global/datum/money_account/station_account
var/global/datum/money_account/centcomm_account
var/global/list/datum/money_account/department_accounts = list()
var/global/num_financial_terminals = 1
var/global/next_account_number = 0
var/global/list/all_money_accounts = list()
var/global/economy_init = FALSE
var/global/initial_station_money = 7500

/proc/setup_economy()
	if(economy_init)
		return 2

	var/datum/feed_channel/newChannel = new /datum/feed_channel
	newChannel.channel_name = "[system_name()] Daily"
	newChannel.author = "CentComm Minister of Information"
	newChannel.locked = 1
	newChannel.is_admin_channel = 1
	news_network.network_channels += newChannel

	newChannel = new /datum/feed_channel
	newChannel.channel_name = "The Gibson Gazette"
	newChannel.author = "Editor Mike Hammers"
	newChannel.locked = 1
	newChannel.is_admin_channel = 1
	news_network.network_channels += newChannel

	newChannel = new /datum/feed_channel
	newChannel.channel_name = "Station Announcements"
	newChannel.author = station_name()
	newChannel.locked = 1
	newChannel.is_admin_channel = 1
	news_network.network_channels += newChannel

	for(var/loc_type in subtypesof(/datum/trade_destination))
		var/datum/trade_destination/D = new loc_type
		weighted_randomevent_locations[D] = D.viable_random_events.len
		weighted_mundaneevent_locations[D] = D.viable_mundane_events.len

	create_station_account()
	create_centcomm_account()

	for(var/department in station_departments)
		create_department_account(department)

	create_department_account("Vendor")
	vendor_account = department_accounts["Vendor"]

	cargo_account = department_accounts["Cargo"]
	SSeconomy.set_dividend_rate("Cargo", 0.1)
	// Enough stock to supply 2 cargos of employees with it. TO-DO: calculate it programatically depending on map changes to jobs?
	SSeconomy.issue_founding_stock(cargo_account.account_number, "Cargo", 260)
	// Pay out the insurance to everyone completely.
	SSeconomy.set_dividend_rate("Medical", 1.0)
	// Enoguh stock to supply 2 medbay employees. See comment above.
	SSeconomy.issue_founding_stock(global.department_accounts["Medical"], "Medical", 410)

	var/MM = time2text(world.timeofday, "MM")
	var/DD = time2text(world.timeofday, "DD")
	current_date_string = "[DD].[MM].[game_year]"

	economy_init = TRUE
	return 1

/proc/create_centcomm_account()
	if(global.centcomm_account)
		return

	global.centcomm_account = new
	global.centcomm_account.owner_name = "CentComm Station Account"
	global.centcomm_account.account_number = rand(111111, 999999)
	global.centcomm_account.remote_access_pin = rand(1111, 9999)
	global.centcomm_account.security_level = 2
	global.centcomm_account.money = 10000000
	global.centcomm_account.hidden = TRUE
	// Is needed in case admins want to have some !!!FUN!!!
	SSeconomy.issue_founding_stock(global.centcomm_account.account_number, "Cargo", 10)
	SSeconomy.issue_founding_stock(global.centcomm_account.account_number, "Medical", 10)

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = global.centcomm_account.owner_name
	T.purpose = "Account creation"
	T.amount = global.centcomm_account.money
	T.date = "2nd May, [gamestory_start_year - 10]"
	T.time = "10:41"
	T.source_terminal = "Biesel GalaxyNet Terminal #277"

	station_account.transaction_log.Add(T)

/proc/create_station_account()
	if(station_account)
		return
	next_account_number = rand(111111, 999999)

	station_account = new()
	station_account.owner_name = "[station_name()] Station Account"
	station_account.account_number = rand(111111, 999999)
	station_account.remote_access_pin = rand(1111, 9999)
	station_account.security_level = 1
	station_account.money = global.initial_station_money
	// Station gets a slight rebound on all cargo activity from stock ownership. In theory HoP or Captain can also sell this.
	SSeconomy.issue_founding_stock(station_account.account_number, "Cargo", 10)
	SSeconomy.issue_founding_stock(station_account.account_number, "Medical", 10)

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = station_account.owner_name
	T.purpose = "Account creation"
	T.amount = station_account.money
	T.date = "2nd April, [gamestory_start_year]"
	T.time = "11:24"
	T.source_terminal = "Biesel GalaxyNet Terminal #277"

	station_account.transaction_log.Add(T)

/proc/create_department_account(department)
	next_account_number = rand(111111, 999999)

	var/datum/money_account/department_account = new()
	department_account.owner_name = "[department] Account"
	department_account.account_number = rand(111111, 999999)
	department_account.remote_access_pin = rand(1111, 9999)
	department_account.security_level = 1
	department_account.money = 500

	//create an entry in the account transaction log for when it was created
	var/datum/transaction/T = new()
	T.target_name = department_account.owner_name
	T.purpose = "Account creation"
	T.amount = department_account.money
	T.date = "2nd April, [gamestory_start_year]"
	T.time = "11:24"
	T.source_terminal = "Biesel GalaxyNet Terminal #277"

	//add the account
	department_account.transaction_log.Add(T)

	department_accounts[department] = department_account
