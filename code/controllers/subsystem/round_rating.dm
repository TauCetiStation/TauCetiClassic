#define RATING_SHOW_ALWAYS (1 << 0)

/datum/rating_template
	var/category
	var/show_options = NONE
	var/question
	var/result_message

	var/avg_rate = 0
	var/total_voters = 0
	var/list/choices = list()

/datum/rating_template/New()
	for(var/type in subtypesof(/datum/vote_choice/rating))
		choices += new type

/datum/rating_template/proc/get_result_message()
	var/rating = "[CEIL(avg_rate)]"
	var/datum/vote_choice/rating/choice = find_suitable_choice(rating)
	return "[result_message]: <span class='far [choice.fa_icon]'></span> <span style='font-size: 10px'>([avg_rate])</span><br>"

/datum/rating_template/proc/find_suitable_choice(rating)
	for(var/datum/vote_choice/choice in choices)
		if(choice.text == rating)
			return choice
	return pick(choices)

/datum/rating_template/proc/get_rating_choice(text)
	for(var/datum/vote_choice/rating/R in choices)
		if(R.text == text)
			return R
	return null

/datum/rating_template/generic
	category = "generic_rating"
	show_options = RATING_SHOW_ALWAYS
	question = "Дайте оценку текущему раунду."
	result_message = "Оценка раунда"

/datum/rating_template/mode
	category = "mode_rating"
	question = "Дайте оценку текущему режиму."
	result_message = "Оценка режима"

/datum/rating_template/rp
	category = "roleplay_rating"
	question = "Дайте оценку отыгрыша других игроков."
	result_message = "Оценка отыгрыша"

/datum/rating_template/admin
	category = "admin_rating"
	question = "Дайте оценку работы администрации."
	result_message = "Оценка администрации"

/datum/rating_template/map
	category = "map_rating"
	question = "Дайте оценку текущей карте."
	result_message = "Оценка карты"

/datum/vote_choice/rating
	var/a_class = ""
	var/fa_icon = ""

/datum/vote_choice/rating/render_html(category)
	return "<a href='?src=\ref[SSrating];round_rating=[text];rating_cat=[category]' class='[a_class]'><span class='far [fa_icon]'></span></a>"

/datum/vote_choice/rating/one
	text = "1"
	a_class = "rating_rates_red"
	fa_icon = "fa-angry"

/datum/vote_choice/rating/two
	text = "2"
	a_class = "rating_rates_orange"
	fa_icon = "fa-frown"

/datum/vote_choice/rating/three
	text = "3"
	a_class = "rating_rates_yellow"
	fa_icon = "fa-meh"

/datum/vote_choice/rating/four
	text = "4"
	a_class = "rating_rates_lime"
	fa_icon = "fa-smile"

/datum/vote_choice/rating/five
	text = "5"
	a_class = "rating_rates_green"
	fa_icon = "fa-laugh"

SUBSYSTEM_DEF(rating)
	name = "Round Rating"

	init_order = SS_INIT_RATING
	flags = SS_NO_FIRE

	var/list/rating_templates = list()
	var/list/picked_templates = list()

	// only for games with a large numbers of players
	var/list/cached_templates_pool

	var/max_random_questions = 2

	var/lowpop = 35

	var/voting = FALSE
	var/already_started = FALSE
	var/voting_time = 1 MINUTE

/datum/controller/subsystem/rating/Initialize(start_timeofday)
	for(var/type in subtypesof(/datum/rating_template))
		rating_templates += new type
	..()

/datum/controller/subsystem/rating/Topic(href, href_list)
	if(!voting)
		var/voting_time_minute = voting_time / (1 MINUTE)
		var/rus_minute_word = pluralize_russian(voting_time_minute, "минута", "минуты", "минут")
		to_chat(usr, "<span class='warning'>На голосование отводится всего [voting_time_minute] [rus_minute_word]. В следующий раз стоит быть пошустрее!</span>")
		return

	if(href_list["round_rating"] && href_list["rating_cat"])
		var/rating = text2num(href_list["round_rating"])
		var/rating_cat = href_list["rating_cat"]
		var/datum/rating_template/template = get_template(rating_cat)
		if(rating && isnum(rating) && template)
			var/datum/vote_choice/choice = template.get_rating_choice("[rating]")
			if(choice)
				for(var/datum/vote_choice/VC in template.choices)
					if(usr.ckey in VC.voters)
						VC.voters.Remove(usr.ckey)
				choice.voters[usr.ckey] = 1
				to_chat(usr, "<span class='info'>[template.result_message]: [rating].</span>")

/datum/controller/subsystem/rating/proc/get_template(category)
	for(var/datum/rating_template/template in rating_templates)
		if(template.category == category)
			return template

/datum/controller/subsystem/rating/proc/get_voting_results()
	var/string = "<div>"

	for(var/category in picked_templates)
		var/datum/rating_template/template = picked_templates[category]
		string += template.get_result_message()

	string += "</div>"
	return string

/datum/controller/subsystem/rating/proc/generate_pool()
	var/list/template_pool = rating_templates.Copy()

	var/list/new_template_pool = list()
	for(var/datum/rating_template/template in template_pool)
		if(template.show_options & RATING_SHOW_ALWAYS)
			new_template_pool += template
			template_pool -= template
			LAZYSET(picked_templates, template.category, template)

	var/question_asked = 0
	while(question_asked != max_random_questions)
		if(template_pool.len == 0)
			break
		var/datum/rating_template/template = pick(template_pool)
		new_template_pool += template
		template_pool -= template
		question_asked++
		LAZYSET(picked_templates, template.category, template)
	return new_template_pool

/datum/controller/subsystem/rating/proc/get_question_pool()
	if(global.player_list.len > lowpop)
		return generate_pool()

	if(!cached_templates_pool)
		cached_templates_pool = generate_pool()

	return cached_templates_pool

/datum/controller/subsystem/rating/proc/start_rating_collection()
	voting = TRUE
	already_started = TRUE

	addtimer(CALLBACK(src, PROC_REF(calculate_rating)), voting_time)

	for(var/client/C in clients)
		var/html = "<div class='rating'>"

		var/list/new_template_pool = get_question_pool()
		for(var/datum/rating_template/template in new_template_pool)
			html += "<span class='rating_questions'>[template.question]</span><br>"
			// render voting choices
			var/i = 0
			for(var/datum/vote_choice/choice in template.choices)
				i++
				html += choice.render_html(template.category)
				if(template.choices.len != i)
					html += "  -  "
			html += "<br>"
		html += "</div>"

		to_chat(C, html)

/datum/controller/subsystem/rating/proc/calculate_rating()
	voting = FALSE

	for(var/category in picked_templates)
		var/datum/rating_template/template = picked_templates[category]
		for(var/datum/vote_choice/choice in template.choices)
			var/total_votes = choice.total_votes()
			if(total_votes == 0)
				continue
			template.avg_rate += text2num(choice.text) * total_votes // :)
			template.total_voters += total_votes
		if(template.total_voters == 0)
			continue
		template.avg_rate = round(template.avg_rate / template.total_voters, 0.01)
		SSStatistics.rating.ratings[category] = template.avg_rate

#undef RATING_SHOW_ALWAYS
