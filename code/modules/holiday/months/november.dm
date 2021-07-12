/datum/holiday/vegan
	name = "Vegan Day"
	begin_day = 1
	begin_month = NOVEMBER

/datum/holiday/vegan/getStationPrefix()
	return pick("Tofu", "Tempeh", "Seitan", "Tofurkey")



/datum/holiday/october_revolution
	name = "October Revolution"
	begin_day = 6
	begin_month = NOVEMBER
	end_day = 7

/datum/holiday/october_revolution/getStationPrefix()
	return pick("Communist", "Soviet", "Bolshevik", "Socialist", "Red", "Workers'")



/datum/holiday/kindness
	name = "Kindness Day"
	begin_day = 13
	begin_month = NOVEMBER



/datum/holiday/flowers
	name = "Flowers Day"
	begin_day = 19
	begin_month = NOVEMBER



/datum/holiday/hello
	name = "Saying-'Hello' Day"
	begin_day = 21
	begin_month = NOVEMBER

/datum/holiday/hello/greet()
	return "[pick(list("Aloha", "Bonjour", "Hello", "Hi", "Greetings", "Salutations", "Bienvenidos", "Hola", "Howdy", "Ni hao", "Guten Tag", "Konnichiwa", "G'day cunt"))]! " + ..()



/datum/holiday/remembrance_day
	name = "Remembrance Day"
	begin_month = NOVEMBER
	begin_day = 11

/datum/holiday/remembrance_day/getStationPrefix()
	return pick("Peace", "Armistice", "Poppy")
