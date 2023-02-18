#define RATING_SHOW_ALWAYS (1 << 0)

/datum/rating_template
	var/category
	var/show_options = NONE
	var/question
	var/result_message

/datum/rating_template/proc/get_result_message(rating)
	var/icon = SSrating.get_icon(rating)
	return "[result_message]: [icon] <span style='font-size: 10px'>([rating])</span><br>"

/datum/rating_template/generic
	category = "generic_rating"
	show_options = RATING_SHOW_ALWAYS
	question = "Вам понравился раунд в целом?"
	result_message = "Оценка раунда"

/datum/rating_template/mode
	category = "mode_rating"
	question = "Вам понравился игровой режим?"
	result_message = "Оценка режима"

/datum/rating_template/rp
	category = "roleplay_rating"
	question = "Вам понравился отыгрыш других игроков?"
	result_message = "Оценка отыгрыша"

/datum/rating_template/bugs
	category = "bugs_rating"
	question = "Сильно ли мешали баги вашему раунду?"
	result_message = "Оценка надоедливости багов"

/datum/rating_template/admin
	category = "admin_rating"
	question = "Вам понравилась работа администрации?"
	result_message = "Оценка администрации"

/datum/rating_template/map
	category = "map_rating"
	question = "Вам понравилась текущая карта?"
	result_message = "Оценка карты"

SUBSYSTEM_DEF(rating)
	name = "Round Rating"

	init_order = SS_INIT_RATING
	flags = SS_NO_FIRE

	var/list/rating_templates = list()

	var/list/rating_by_icon = list(
		"1" = list(
			"a-class" = "rating_rates_red",
			"icon" = "fa-angry"
		),
		"2" = list(
			"a-class" = "rating_rates_orange",
			"icon" = "fa-frown"
		),
		"3" = list(
			"a-class" = "rating_rates_yellow",
			"icon" = "fa-meh"
		),
		"4" = list(
			"a-class" = "rating_rates_lime",
			"icon" = "fa-smile"
		),
		"5" = list(
			"a-class" = "rating_rates_green",
			"icon" = "fa-laugh"
		),
	)

	// map where key is ckey, value is a list, where 1 - category, 2 - rate
	var/list/rates = list()

	// only for games with a large numbers of players
	var/list/cached_templates_pool

	var/max_random_questions = 2

	var/lowpop = 35

	var/voting = FALSE

/datum/controller/subsystem/rating/Initialize(start_timeofday)
	for(var/type in subtypesof(/datum/rating_template))
		rating_templates += new type
	..()

/datum/controller/subsystem/rating/Topic(href, href_list)
	if(!voting)
		return

	if(href_list["round_rating"] && href_list["rating_cat"])
		var/rating = text2num(href_list["round_rating"])
		var/rating_cat = href_list["rating_cat"]
		if(rating && isnum(rating) && SSrating.get_template(rating_cat) && ("[rating]" in SSrating.rating_by_icon))
			LAZYSET(rates[usr.ckey], category, rate)
			to_chat(usr, "<span class='info'>Ваша оценка: [rating].</span>")

/datum/controller/subsystem/rating/proc/get_result_message(category, rating)
	for(var/datum/rating_template/template in rating_templates)
		if(template.category == category)
			return template.get_result_message(rating)

/datum/controller/subsystem/rating/proc/get_template(category)
	for(var/datum/rating_template/template in rating_templates)
		if(template.category == category)
			return template

/datum/controller/subsystem/rating/proc/get_icon(rating)
	return rating_by_icon["[CEIL(rating)]"]

/datum/controller/subsystem/rating/proc/get_voting_results()
	var/string = "<div>"

	var/list/ratings = SSStatistics.rating.ratings
	for(var/category in ratings)
		string += get_result_message(category, ratings[category])

	string += "</div>"
	return string


/datum/controller/subsystem/rating/proc/generate_pool()
	var/list/template_pool = rating_templates.Copy()

	var/list/new_template_pool = list()
	for(var/datum/rating_template/template in template_pool)
		if(template.show_options & RATING_SHOW_ALWAYS)
			new_template_pool += template
			template_pool -= template

	var/question_asked = 0
	while(question_asked != max_random_questions)
		if(template_pool.len == 0)
			break
		var/template = pick(template_pool)
		new_template_pool += template
		template_pool -= template
		question_asked++
	return new_template_pool

/datum/controller/subsystem/rating/proc/get_question_pool()
	if(global.player_list.len > lowpop)
		return generate_pool()

	if(!cached_templates_pool)
		cached_templates_pool = generate_pool()

	return cached_templates_pool

#define RATING_HREF(rating, category, fa_icon, a_class) "<a href='?src=\ref[src];round_rating=[rating];rating_cat=[category]' class='[a_class]'><span class='far [fa_icon]'></span></a>"

/datum/controller/subsystem/rating/proc/announce_rating_collection()
	voting = TRUE

	var/html = "<br><div class='rating'>"

	var/list/new_template_pool = get_question_pool()

	for(var/datum/rating_template/template in new_template_pool)
		html += "<span class='rating_questions'>[template.question]</span><br>"
		// render voting choises
		var/i = 0
		for(var/rate in rating_by_icon)
			i++
			html += RATING_HREF(rate, template.category, rating_by_icon[rate]["icon"], rating_by_icon[rate]["a-class"])
			if(rating_by_icon.len != i)
				html += "  -  "
		html += "<br>"
	html += "</div><br>"

	for(var/client/C in clients)
		to_chat(C, html)

#undef RATING_HREF

/datum/controller/subsystem/rating/proc/calculate_rating()
	voting = FALSE

	var/list/voters = list()
	for(var/ckey in rates)
		for(var/category in rates[ckey])
			SSStatistics.rating.ratings[category] += rates[ckey][category]
			voters[category]++
	for(var/category in SSStatistics.rating.ratings)
		SSStatistics.rating.ratings[category] = round(SSStatistics.rating.ratings[category] / voters[category], 0.01)

#undef RATING_SHOW_ALWAYS
