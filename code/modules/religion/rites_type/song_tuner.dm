///prototype for rites that tune a song.
/datum/religion_rites/song_tuner
	ritual_length = 10 SECONDS
	favor_cost = 10
	///if repeats count as continuations instead of a song's end, TRUE
	var/repeats_okay = TRUE
	///personal message sent to the chaplain as feedback for their chosen song
	var/song_invocation_message = "Да будет песенка"
	///visible message sent to indicate a song will have special properties
	var/song_start_message
	///particle effect of playing this tune
	var/particles_path = /particles/musical_notes
	///what the instrument will glow when playing
	var/glow_color = "#000000"
	///if song gives a buff, TRUE
	var/buff = FALSE

/datum/religion_rites/song_tuner/invoke_effect(mob/user, obj/AOG)
	. = ..()
	for(var/mob/living/carbon/human/H in range(3, AOG))
		if(!religion.is_member(H) || (H.GetComponent(/datum/component/smooth_tunes) && H != user))
			continue
		to_chat(H, "<span class='notice'>[song_invocation_message]</span>")
		H.AddComponent(/datum/component/smooth_tunes, src, repeats_okay, particles_path, glow_color)

/**
 * Perform the song effect.
 *
 * Arguments:
 * * listener - A mob, listening to the song
 * * song_source - parent of the smooth_tunes component. This is limited to the compatible items of said component, which currently includes mobs and objects so we'll have to type appropriately.
 */
/datum/religion_rites/song_tuner/proc/song_effect(mob/living/listener, atom/song_source)
	return

/**
 * When the song is long enough, it will have a special effect when it ends.
 *
 * Arguments:
 * * listener - A mob, listening to the song
 * * song_source - parent of the smooth_tunes component. This is limited to the compatible items of said component, which currently includes mobs and objects so we'll have to type appropriately.
 */
/datum/religion_rites/song_tuner/proc/finish_effect(mob/living/listener, atom/song_source)
	return

/**
 * End of song, time to clear everything.
 */
/datum/religion_rites/song_tuner/proc/end_song()
	return

/datum/religion_rites/song_tuner/evangelism
	name = "Благовестнический Гимн"
	desc = "Распространяйте слово вашего Бога, распространяя его волю. В конце песни вы благословите всех слушателей, улучшив их настроение."
	particles_path = /particles/musical_notes/holy
	song_invocation_message = "Вы приготовили песнь Святых!"
	song_start_message = "<span class='notice'>Эта музыка благословенна!</span>"
	glow_color = "#aaaaaa"
	favor_cost = 0
	buff = TRUE
	needed_aspects = list(
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/song_tuner/evangelism/song_effect(mob/living/listener, atom/song_source)
	//To stop monkey farms
	if(listener.mind?.holy_role || !listener.ckey)
		return
	religion.adjust_favor(2)

/datum/religion_rites/song_tuner/evangelism/finish_effect(mob/living/listener, atom/song_source)
	SEND_SIGNAL(listener, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)

/datum/religion_rites/song_tuner/life
	name = "Симфония Жизни"
	desc = "Спойте спокойную песню, излечив раны ближнего своего"
	particles_path = /particles/musical_notes/grey
	favor_cost = 400
	song_invocation_message = "Вы приготовили песнь Жизни!"
	song_start_message = "<span class='nicegreen'>Эта песня греет душу и тело</span>"
	glow_color = "#91bd97"
	repeats_okay = FALSE
	buff = TRUE
	needed_aspects = list(
		ASPECT_LIGHT = 1,
	)

/datum/religion_rites/song_tuner/life/song_effect(mob/living/listener, atom/song_source)
	var/heal = -0.4
	if(listener.mind?.holy_role)
		heal *= 2

	listener.adjustBruteLoss(heal)
	listener.adjustFireLoss(heal)
	listener.adjustOxyLoss(heal)

/datum/religion_rites/song_tuner/life/finish_effect(mob/living/listener, atom/song_source)
	listener.adjustBruteLoss(-7)
	listener.adjustFireLoss(-7)
	listener.adjustOxyLoss(-10)

/datum/religion_rites/song_tuner/pain
	name = "Убийственный аккорд"
	desc = "В ход идёт настолько ужасное пение, что режет оно уже не только слух. Действует менее эффективно на просвятлённых. В конце песни ты откроешь раны у всех слушателей."
	favor_cost = 400
	particles_path = /particles/musical_notes/harm
	song_invocation_message = "От песни будет кровь из ушей. И не только."
	song_start_message = "<span class='danger'>Словно иглу воткнули!</span>"
	glow_color = "#cc0000"
	repeats_okay = FALSE
	needed_aspects = list(
		ASPECT_DEATH = 1,
	)

/datum/religion_rites/song_tuner/pain/song_effect(mob/living/listener, atom/song_source)
	var/damage_dealt = 1
	if(listener.mind?.holy_role)
		damage_dealt *= 0.5

	listener.adjustBruteLoss(damage_dealt)

/datum/religion_rites/song_tuner/pain/finish_effect(mob/living/listener, atom/song_source)
	if(ishuman(listener))
		var/mob/living/carbon/human/H = listener
		var/obj/item/organ/external/sliced_limb = pick(H.bodyparts)
		sliced_limb.createwound(CUT, 14)
		listener.ear_deaf += 20
	else
		listener.adjustBruteLoss(20)

/datum/religion_rites/song_tuner/lullaby
	name = "Колыбель Души"
	desc = "Пойте колыбельную, утомляя окружающих, заставляя их засыпать. В конце песни люди ненадолго заснут."
	particles_path = /particles/musical_notes/sleepy
	song_invocation_message = "Вы приготовили колыбель!"
	song_start_message = "<span class='warning'>От этой музыки клонит в сон...</span>"
	favor_cost = 200
	glow_color = "#83f6ff"
	repeats_okay = FALSE
	///["name of living" = "times heard this song"]
	var/list/listeners = list()
	needed_aspects = list(
		ASPECT_MYSTIC = 1,
	)

/datum/religion_rites/song_tuner/lullaby/song_effect(mob/living/listener, atom/song_source)
	if(listener.mind?.holy_role)
		return

	var/static/list/sleepy_messages = list(
		"От этой музыки так и клонит в сон...",
		"Музыка заставляет на мгновение задремать.",
		"Приходится сосредототачиваться на том, чтобы не заснуть во время исполнения этой песни.",
	)

	if(prob(25))
		to_chat(listener, "<span class='warning'>[pick(sleepy_messages)]</span>")
		listener.emote("yawn")
		listener.blurEyes(2)
	listeners[listener]++

/datum/religion_rites/song_tuner/lullaby/finish_effect(mob/living/listener, atom/song_source)
	to_chat(listener, "<span class='notice'>Вау, конец песни был... отличный...</span>")
	if(listener in listeners)
		var/time2sleep = round(sqrt(listeners[listener])) SECONDS
		listener.AdjustSleeping(time2sleep)

/datum/religion_rites/song_tuner/lullaby/end_song()
	listeners.Cut()
