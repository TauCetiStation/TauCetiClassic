/datum/stockMarket
	var/list/stocks = list()
	var/list/balances = list()
	var/list/last_read = list()
	var/list/logs = list()

/datum/stockMarket/New()
		..()
		generateStocks()
		START_PROCESSING(SSobj, src)

/datum/stockMarket/proc/balanceLog(whose, net)
	if (!(whose in balances))
		balances[whose] = net
	else
		balances[whose] += net

/datum/stockMarket/proc/generateDesignation(name)
	if(length_char(name) <= 4)
		return uppertext(name)

	if(findtext(name, " "))
		return capitalize_words(name)

	// generate random abbreviation if it's just one long word
	var/bytes_length = length(name)
	var/char = ""
	var/new_name = ""
	for(var/i = 1, i <= bytes_length, i += length(char))
		char = name[i]

		if(prob(100 / i))
			new_name += uppertext(char)

	return new_name

/datum/stockMarket/proc/generateStocks(amt = 15)
	var/list/fruits = list("Banana", "Mimana", "Watermelon", "Ambrosia", "Pomegranate", "Reishi", "Papaya", "Mango", "Tomato", "Conkerberry", "Wood", "Lychee", "Mandarin", "Harebell", "Pumpkin", "Rhubarb", "Tamarillo", "Yantok", "Ziziphus", "Oranges", "Gatfruit", "Daisy", "Kudzu")
	var/list/tech_prefix = list("Nano", "Cyber", "Funk", "Astro", "Fusion", "Tera", "Exo", "Star", "Virtual", "Plasma", "Robust", "Bit", "Future", "Hugbox", "Carbon", "Nerf", "Buff", "Nova", "Space", "Meta", "Cyber")
	var/list/tech_short = list("soft", "tech", "prog", "tec", "tek", "ware", "", "gadgets", "nics", "tric", "trasen", "tronic", "coin")
	var/list/random_nouns = list("Johnson", "Cluwne", "General", "Specific", "Master", "King", "Queen", "Table", "Rupture", "Dynamic", "Massive", "Mega", "Giga", "Certain", "Singulo", "State", "National", "International", "Interplanetary", "Sector", "Planet", "Burn", "Robust", "Exotic", "Solar", "Lunar", "Chelp", "Corgi", "Lag", "Lizard")
	var/list/company = list("Company", "Factory", "Incorporated", "Industries", "Group", "Consolidated", "GmbH", "LLC", "Ltd", "Inc.", "Association", "Limited", "Software", "Technology", "Programming", "IT Group", "Electronics", "Nanotechnology", "Farms", "Stores", "Mobile", "Motors", "Electric", "Designs", "Energy", "Pharmaceuticals", "Communications", "Wholesale", "Holding", "Health", "Machines", "Astrotech", "Gadgets", "Kinetics")
	for (var/i = 1, i <= amt, i++)
		var/datum/stock/S = new
		var/sname = ""
		switch(rand(1,6))
			if(1)
				while(sname == "" || sname == "FAG") // honestly it's a 0.6% chance per round this happens - or once in 166 rounds - so i'm accounting for it before someone yells at me
					sname = "[consonant()][vowel()][consonant()]"
			if(2)
				sname = "[pick(tech_prefix)][pick(tech_short)][prob(20) ? " " + pick(company) : null]"
			if(3 to 4)
				var/fruit = pick(fruits)
				fruits -= fruit
				sname = "[prob(10) ? "The " : null][fruit][prob(40) ? " " + pick(company): null]"
			if(5 to 6)
				var/pname = pick(random_nouns)
				random_nouns -= pname
				switch (rand(1,3))
					if(1)
						sname = "[pname] & [pname]"
					if(2)
						sname = "[pname] [pick(company)]"
					if(3)
						sname = "[pname]"
		S.name = sname
		S.short_name = generateDesignation(S.name)
		S.current_value = rand(10, 125)
		S.setOptimism(rand(-40, 40) * 0.01)
		S.disp_value_change = rand(-1, 1)
		S.performance = rand(10, 15) * 0.1
		S.available_shares = rand(200000, 800000)
		S.fluctuation_rate = rand(6, 20)
		S.generateIndustry()
		S.generateEvents()
		stocks += S
		last_read[S] = list()

/datum/stockMarket/process()
	for(var/stock in stocks)
		var/datum/stock/S = stock
		S.process()

/datum/stockMarket/proc/add_log(log_type, user, company_name, stocks, shareprice, money)
	var/datum/stock_log/L = new log_type
	L.user_name = user
	L.company_name = company_name
	L.stocks = stocks
	L.shareprice = shareprice
	L.money = money
	L.time = time2text(world.timeofday, "hh:mm")
	logs += L

var/global/datum/stockMarket/stockExchange = new

/proc/plotBarGraph(list/points, base_text, width=400, height=400)
	var/output = "<table style='border:1px solid black; border-collapse: collapse; width: [width]px; height: [height]px'>"
	if(points.len && height > 20 && width > 20)
		var/min = points[1]
		var/max = points[1]
		for (var/v in points)
			if (v < min)
				min = v
			if (v > max)
				max = v
		var/cells = (height - 20) / 20
		if (cells > round(cells))
			cells = round(cells) + 1
		var/diff = max - min
		var/ost = diff / cells
		if (min > 0)
			min = max(min - ost, 0)
		diff = max - min
		ost = diff / cells
		var/cval = max
		var/cwid = width / (points.len + 1)
		for (var/y = cells, y > 0, y--)
			if (y == cells)
				output += "<tr>"
			else
				output += "<tr style='border:none; border-top:1px solid #00ff00; height: 20px'>"
			for (var/x = 0, x <= points.len, x++)
				if (x == 0)
					output += "<td style='border:none; height: 20px; width: [cwid]px; font-size:10px; color:#00ff00; background:black; text-align:right; vertical-align:bottom'>[round(cval - ost)]</td>"
				else
					var/v = points[x]
					if (v >= cval)
						output += "<td style='border:none; height: 20px; width: [cwid]px; background:#0000ff'>&nbsp;</td>"
					else
						output += "<td style='border:none; height: 20px; width: [cwid]px; background:black'>&nbsp;</td>"
			output += "</tr>"
			cval -= ost
		output += "<tr><td style='font-size:10px; height: 20px; width: 100%; background:black; color:green; text-align:center' colspan='[points.len + 1]'>[base_text]</td></tr>"
	else
		output += "<tr><td style='width:[width]px; height:[height]px; background: black'></td></tr>"
		output += "<tr><td style='font-size:10px; background:black; color:green; text-align:center'>[base_text]</td></tr>"

	return "[output]</table>"
