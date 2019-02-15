/datum/trader
	var/name = "unsuspicious trader"                            //The name of the trader in question
	var/origin = "some place"                                   //The place that they are trading from
	var/list/possible_origins                                   //Possible names of the trader origin
	var/disposition = 0                                         //The current disposition of them to us.
	var/trade_flags = TRADER_MONEY                              //Flags
	var/name_language                                                //If this is set to a language name this will generate a name from the language
	var/icon/portrait                                           //The icon that shows up in the menu @TODO

	var/list/wanted_items = list()                              //What items they enjoy trading for. Structure is (type = known/unknown)
	var/list/possible_wanted_items                              //List of all possible wanted items. Structure is (type = mode)
	var/list/possible_trading_items                             //List of all possible trading items. Structure is (type = mode)
	var/list/trading_items = list()                             //What items they are currently trading away.
	var/list/blacklisted_trade_items = list(/mob/living/carbon/human)
	                                                            //Things they will automatically refuse

	var/list/speech = list()                                    //The list of all their replies and messages. Structure is (id = talk)
	/*SPEECH IDS:
	hail_generic		When merchants hail a person
	hail_[race]			Race specific hails
	hail_deny			When merchant denies a hail
	insult_good			When the player insults a merchant while they are on good disposition
	insult_bad			When a player insults a merchatn when they are not on good disposition
	complement_accept	When the merchant accepts a complement
	complement_deny		When the merchant refuses a complement
	how_much			When a merchant tells the player how much something is.
	trade_complete		When a trade is made
	trade_refuse		When a trade is refused
	what_want			What the person says when they are asked if they want something
	*/
	var/want_multiplier = 2                                     //How much wanted items are multiplied by when traded for
	var/margin = 1.2											//Multiplier to price when selling to player
	var/price_rng = 10                                          //Percentage max variance in sell prices.
	var/insult_drop = 5                                         //How far disposition drops on insult
	var/compliment_increase = 5                                 //How far compliments increase disposition
	var/refuse_comms = 0                                        //Whether they refuse further communication

	var/mob_transfer_message = "You are transported to ORIGIN." //What message gets sent to mobs that get sold.

/datum/trader/New()
	..()
	if(name_language)
		if(name_language == TRADER_DEFAULT_NAME)
			name = capitalize(pick(first_names_female + first_names_male)) + " " + capitalize(pick(last_names))
		else if(name_language == TRADER_AI_NAME)
			name = capitalize(pick(ai_names - list("")))
		else if(name_language == TRADER_VOX_NAME)
			var/sounds = rand(2, 8)
			var/i = 0
			var/newname = ""

			while(i <= sounds)
				i++
				newname += pick(list("ti","hi","ki","ya","ta","ha","ka","ya","chi","cha","kah"))
			name = newname
		else if(name_language == TRADER_DIONA_NAME)
			var/new_name = "[pick(list("To Sleep Beneath","Wind Over","Embrace of","Dreams of","Witnessing","To Walk Beneath","Approaching the"))]"
			new_name += " [pick(list("the Void","the Sky","Encroaching Night","Planetsong","Starsong","the Wandering Star","the Empty Day","Daybreak","Nightfall","the Rain"))]"
			name = new_name
	if(possible_origins && possible_origins.len)
		origin = pick(possible_origins)

	for(var/i in 3 to 6)
		add_to_pool(trading_items, possible_trading_items, force = TRUE)
		add_to_pool(wanted_items, possible_wanted_items, force = TRUE)

//If this hits 0 then they decide to up and leave.
/datum/trader/proc/tick()
	add_to_pool(trading_items, possible_trading_items, 200)
	add_to_pool(wanted_items, possible_wanted_items, 50)
	remove_from_pool(possible_trading_items, 9) //We want the stock to change every so often, so we make it so that they have roughly 10~11 ish items max
	return 1

/datum/trader/proc/remove_from_pool(list/pool, chance_per_item)
	if(pool && prob(chance_per_item * pool.len))
		var/i = rand(1,pool.len)
		pool[pool[i]] = null
		pool -= pool[i]

/datum/trader/proc/add_to_pool(list/pool, list/possible, base_chance = 100, force = FALSE)
	var/divisor = 1
	if(pool && pool.len)
		divisor = pool.len
	if(force || prob(base_chance/divisor))
		var/new_item = get_possible_item(possible)
		if(new_item)
			pool |= new_item

/datum/trader/proc/get_possible_item(list/trading_pool)
	if(!trading_pool || !trading_pool.len)
		return
	var/list/possible = list()
	for(var/type in trading_pool)
		var/status = trading_pool[type]
		if(status & TRADER_THIS_TYPE)
			possible += type
		if(status & TRADER_SUBTYPES_ONLY)
			possible += subtypesof(type)
		if(status & TRADER_BLACKLIST)
			possible -= type
		if(status & TRADER_BLACKLIST_SUB)
			possible -= subtypesof(type)

	if(possible.len)
		var/picked = pick(possible)
		var/atom/A = picked
		if(initial(A.name) in list("object", "item","weapon", "structure", "machinery", "Mecha", "organ", "snack")) //weed out a few of the common bad types. Reason we don't check types specifically is that (hopefully) further bad subtypes don't set their name up and are similar.
			return
		return picked

/datum/trader/proc/get_response(key, default)
	var/text
	if(speech && speech[key])
		text = speech[key]
	else
		text = default
	text = replacetext(text, "MERCHANT", name)
	return replacetext(text, "ORIGIN", origin)

/datum/trader/proc/print_trading_items(num)
	num = Clamp(num,1,trading_items.len)
	if(trading_items[num])
		var/atom/movable/M = trading_items[num]
		return "[initial(M.name)]"

/datum/trader/proc/skill_curve()
	. = 1
	// insert skill system here

	//This condition ensures that the buy price is higher than the sell price on generic goods, i.e. the merchant can't be exploited
	. = max(., price_rng/((margin - 1)*(200 - price_rng)))

/*var/list/price_cache = list()
/proc/get_value(atom/movable/A) // A can be either type *or* instance; ie get_value(/obj) is valid, as is get_value(new /obj)
	if(ispath(A))
		A = new A
		var/price = A.get_price()
		price_cache[A.type] = price
		qdel(A)
		return price
	else
		return A.get_price()*/

/datum/trader/proc/get_item_value(trading_num)
	if(!trading_items[trading_items[trading_num]])
		var/type = trading_items[trading_num]
		var/value = get_value(type)
		value = round(rand(100 - price_rng,100 + price_rng)/100 * value) //For some reason rand doesn't like decimals.
		trading_items[type] = value
	. = trading_items[trading_items[trading_num]]
	. *= ceil(1 + (margin - 1) * skill_curve())

/datum/trader/proc/get_buy_price(item, is_wanted)
	. = get_value(item)
	if(is_wanted)
		. *= want_multiplier
	. *= ceil(max(1 - (margin - 1) * skill_curve(), 0.1)) //Trader will underpay at lower skill.

/datum/trader/proc/offer_money_for_trade(trade_num, money_amount)
	if(!(trade_flags & TRADER_MONEY))
		return TRADER_NO_MONEY
	var/value = get_item_value(trade_num)
	if(money_amount < value)
		return TRADER_NOT_ENOUGH

	return value

/datum/trader/proc/offer_items_for_trade(list/offers, num, turf/location)
	if(!offers || !offers.len)
		return TRADER_NOT_ENOUGH
	num = Clamp(num, 1, trading_items.len)
	var/offer_worth = 0
	for(var/item in offers)
		var/atom/movable/offer = item
		var/is_wanted = 0
		if((trade_flags & TRADER_WANTED_ONLY) && is_type_in_list(offer,wanted_items))
			is_wanted = 2
		if((trade_flags & TRADER_WANTED_ALL) && is_type_in_list(offer,possible_wanted_items))
			is_wanted = 1
		if(blacklisted_trade_items && blacklisted_trade_items.len && is_type_in_list(offer,blacklisted_trade_items))
			return 0

		if(istype(offer,/obj/item/weapon/spacecash))
			if(!(trade_flags & TRADER_MONEY))
				return TRADER_NO_MONEY
		else
			if(!(trade_flags & TRADER_GOODS))
				return TRADER_NO_GOODS
			else if((trade_flags & TRADER_WANTED_ONLY|TRADER_WANTED_ALL) && !is_wanted)
				return TRADER_FOUND_UNWANTED

		offer_worth += get_buy_price(offer, is_wanted - 1)
	if(!offer_worth)
		return TRADER_NOT_ENOUGH
	var/trading_worth = get_item_value(num)
	if(!trading_worth)
		return TRADER_NOT_ENOUGH
	var/percent = offer_worth/trading_worth
	if(percent > max(0.9,0.9-disposition/100))
		return trade(offers, num, location)
	return TRADER_NOT_ENOUGH

/datum/trader/proc/hail(mob/user)
	var/specific
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species)
			specific = H.species.name
	else if(istype(user, /mob/living/silicon))
		specific = "silicon"
	if(!speech["hail_[specific]"])
		specific = "generic"
	. = get_response("hail_[specific]", "Greetings, MOB!")
	. = replacetext(., "MOB", user.name)

/datum/trader/proc/can_hail()
	if(!refuse_comms && prob(-disposition))
		refuse_comms = 1
	return !refuse_comms

/datum/trader/proc/insult()
	disposition -= rand(insult_drop, insult_drop * 2)
	if(prob(-disposition/10))
		refuse_comms = 1
	if(disposition > 50)
		return get_response("insult_good","What? I thought we were cool!")
	else
		return get_response("insult_bad", "Right back at you asshole!")

/datum/trader/proc/compliment()
	if(prob(-disposition))
		return get_response("compliment_deny", "Fuck you!")
	if(prob(100-disposition))
		disposition += rand(compliment_increase, compliment_increase * 2)
	return get_response("compliment_accept", "Thank you!")

/datum/trader/proc/trade(list/offers, num, turf/location)
	if(offers && offers.len)
		for(var/offer in offers)
			if(istype(offer,/mob))
				var/text = mob_transfer_message
				to_chat(offer, replacetext(text, "ORIGIN", origin))
			if(istype(offer, /obj/mecha))
				var/obj/mecha/M = offer
				M.wreckage = null //So they don't ruin the illusion
			qdel(offer)

	var/type = trading_items[num]

	var/atom/movable/M = new type(location)
	playsound(location, 'sound/effects/teleport.ogg', 50, 1)

	disposition += rand(compliment_increase,compliment_increase*3) //Traders like it when you trade with them

	return M

/datum/trader/proc/how_much_do_you_want(num)
	var/atom/movable/M = trading_items[num]
	. = get_response("how_much", "Hmm.... how about VALUE credits?")
	. = replacetext(.,"VALUE",get_item_value(num))
	. = replacetext(.,"ITEM", initial(M.name))

/datum/trader/proc/what_do_you_want()
	if(!(trade_flags & TRADER_GOODS))
		return get_response(TRADER_NO_GOODS, "I don't deal in goods.")

	. = get_response("what_want", "Hm, I want")
	var/list/want_english = list()
	for(var/type in wanted_items)
		var/atom/a = type
		want_english += initial(a.name)
	. += " [english_list(want_english)]"

/datum/trader/proc/sell_items(list/offers)
	if(!(trade_flags & TRADER_GOODS))
		return TRADER_NO_GOODS
	if(!offers || !offers.len)
		return TRADER_NOT_ENOUGH

	var/wanted
	. = 0
	for(var/offer in offers)
		if((trade_flags & TRADER_WANTED_ONLY) && is_type_in_list(offer,wanted_items))
			wanted = 1
		else if((trade_flags & TRADER_WANTED_ALL) && is_type_in_list(offer,possible_wanted_items))
			wanted = 0
		else
			return TRADER_FOUND_UNWANTED
		. += get_buy_price(offer, wanted)

	playsound(get_turf(offers[1]), 'sound/effects/teleport.ogg', 50, 1)
	for(var/offer in offers)
		qdel(offer)

/datum/trader/proc/bribe_to_stay_longer(amt)
	return get_response("bribe_refusal", "How about... no?")