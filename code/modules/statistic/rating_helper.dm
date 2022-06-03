#define RATING_SHOW_ALWAYS (1 << 0)

/datum/rating_template
	var/category
	var/show_options
	var/question
	var/result_message

/datum/rating_template/proc/get_result_message(rating)
	// sorry for this
	var/icon = global.rating_helper.get_icon(rating)
	return "[result_message]: [icon] <span style='font-size: 10px'>([rating])</span><br>"

/datum/rating_template/generic
	category = "generic_rating"
	show_options = RATING_SHOW_ALWAYS
	question = "Вам понравился раунд в целом?"
	result_message = "Оценка раунда"

/datum/rating_template/mode
	category = "mode_rating"
	question = "Вам понравился режим?"
	result_message = "Оценка режима"

/datum/rating_template/rp
	category = "roleplay_rating"
	question = "Вам понравился отыгрыш других игроков?"
	result_message = "Оценка отыгрыша"

/datum/rating_template/bugs
	category = "bugs_rating"
	question = "Насколько сильно баги мешали вам в этом раунде?"
	result_message = "Оценка надоедливости багов"

// my fucking DTOs without systems and layers
var/global/datum/rating_helper/rating_helper = new
/datum/rating_helper
	var/list/rating_templates = list()

	var/list/rating_by_icon = list(
		"1" = "<i class=\"far fa-angry\"></i>",
		"2" = "<i class=\"far fa-frown\"></i>",
		"3" = "<i class=\"far fa-meh\"></i>",
		"4" = "<i class=\"far fa-smile\"></i>",
		"5" = "<i class=\"far fa-laugh\"></i>",
	)

	var/max_random_questions = 2

/datum/rating_helper/New()
	for(var/type in subtypesof(/datum/rating_template))
		rating_templates += new type

/datum/rating_helper/proc/get_result_message(category, rating)
	for(var/datum/rating_template/template in rating_templates)
		if(template.category == category)
			return template.get_result_message(rating)

/datum/rating_helper/proc/get_template(category)
	for(var/datum/rating_template/template in rating_templates)
		if(template.category == category)
			return template

/datum/rating_helper/proc/get_icon(rating)
	return rating_by_icon["[CEIL(rating)]"]

/datum/rating_helper/proc/get_voting_results()
	var/string = "<div>"

	var/list/ratings = SSStatistics.rating.ratings
	for(var/cat in ratings)
		string += get_result_message(cat, ratings[cat])

	string += "</div>"
	return string

#define RATING_HREF(M, rating, cat, fa_icon) "<a href='?src=\ref[M];round_rating=[rating];rating_cat=[cat]'>[fa_icon]</a>"

/datum/rating_helper/proc/announce_rating_collection()
	for(var/mob/M in global.player_list)
		var/string = "<br><div class='rating'>"
		var/list/temp_templates = rating_templates.Copy()

		var/list/templates_to_render = list()
		for(var/datum/rating_template/template in temp_templates)
			if(!(template.show_options & RATING_SHOW_ALWAYS))
				continue
			templates_to_render += template
			temp_templates -= template

		temp_templates = shuffle(temp_templates)
		var/question_asked = 0
		while(question_asked != max_random_questions)
			if(!temp_templates.len)
				break
			var/template = pick(temp_templates)
			templates_to_render += template
			temp_templates -= template
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

/datum/rating_helper/proc/calculate_rating()
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
