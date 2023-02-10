#define RATING_SHOW_ALWAYS (1 << 0)

/datum/rating_template
	var/category
	var/show_options
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
	question = "Вам сильно помешали баги?"
	result_message = "Оценка надоедливости багов"

/datum/rating_template/admin
	category = "admin_rating"
	question = "Вам понравилась работа администрации?"
	result_message = "Оценка администрации"

SUBSYSTEM_DEF(rating)
	name = "Round Rating"

	init_order = SS_INIT_RATING
	flags = SS_NO_FIRE

	var/list/rating_templates = list()

	var/list/rating_by_icon = list(
		"1" = "<span class=\"far fa-angry\"></span>",
		"2" = "<span class=\"far fa-frown\"></span>",
		"3" = "<span class=\"far fa-meh\"></span>",
		"4" = "<span class=\"far fa-smile\"></span>",
		"5" = "<span class=\"far fa-laugh\"></span>",
	)

	var/max_random_questions = 2

/datum/controller/subsystem/rating/Initialize(start_timeofday)
	for(var/type in subtypesof(/datum/rating_template))
		rating_templates += new type
	..()

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
	for(var/cat in ratings)
		string += get_result_message(cat, ratings[cat])

	string += "</div>"
	return string

#define RATING_HREF(M, rating, cat, fa_icon) "<a href='?src=\ref[M];round_rating=[rating];rating_cat=[cat]'>[fa_icon]</a>"

/datum/controller/subsystem/rating/proc/announce_rating_collection()
	for(var/mob/M in global.player_list)
		var/string = "<br><div class='rating'>"
		var/list/template_pool = rating_templates.Copy()

		var/list/templates_to_render = list()
		for(var/datum/rating_template/template in template_pool)
			if(template.show_options & RATING_SHOW_ALWAYS)
				templates_to_render += template
				template_pool -= template

		var/question_asked = 0
		while(question_asked != max_random_questions)
			if(template_pool.len == 0)
				break
			var/template = pick(template_pool)
			templates_to_render += template
			template_pool -= template
			question_asked++

		for(var/datum/rating_template/template in templates_to_render)
			string += "<span class='rating_questions'>[template.question]</span><br>"
			// render voting choises
			string += "<span class='rating_rates'>"
			var/i = 0
			for(var/rate in rating_by_icon)
				i++
				string += RATING_HREF(M, rate, template.category, rating_by_icon[rate])
				if(rating_by_icon.len != i)
					string += "  -  "
			string += "</span><br>"
		string += "</div><br>"
		to_chat(M, string)

#undef RATING_HREF

/datum/controller/subsystem/rating/proc/calculate_rating()
	var/list/voters = list()
	for(var/mob/M in global.player_list)
		if(!length(M.client.my_rate))
			continue
		for(var/cat in M.client.my_rate)
			SSStatistics.rating.ratings[cat] += M.client.my_rate[cat]
			voters[cat]++
	for(var/cat in SSStatistics.rating.ratings)
		SSStatistics.rating.ratings[cat] = SSStatistics.rating.ratings[cat] / voters[cat]

#undef RATING_SHOW_ALWAYS
