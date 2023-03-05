///prototype for rites that tune a song.
/datum/religion_rites/song_tuner
	name = "Tune Song"
	desc = "this is a prototype."
	ritual_length = 10 SECONDS
	favor_cost = 10
	///if repeats count as continuations instead of a song's end, TRUE
	var/repeats_okay = TRUE
	///personal message sent to the chaplain as feedback for their chosen song
	var/song_invocation_message = "beep borp you forgot to fill in a variable report to git hub"
	///visible message sent to indicate a song will have special properties
	var/song_start_message
	///particle effect of playing this tune
	var/particles_path = /particles/musical_notes
	///what the instrument will glow when playing
	var/glow_color = "#000000"
	///if song gives a buff, TRUE
	var/buff = FALSE

	needed_aspects = list(
		ASPECT_CHAOS = 1,
	)

/datum/religion_rites/song_tuner/invoke_effect(mob/living/user, obj/structure/altar_of_gods/altar)
	. = ..()
	to_chat(user, "<span class='notice'>[song_invocation_message]</span>")
	user.AddComponent(/datum/component/smooth_tunes, src, repeats_okay, particles_path, glow_color, user)

/**
 * Perform the song effect.
 *
 * Arguments:
 * * listener - A mob, listening to the song
 * * song_source - parent of the smooth_tunes component. This is limited to the compatible items of said component, which currently includes mobs and objects so we'll have to type appropriately.
 */
/datum/religion_rites/song_tuner/proc/song_effect(mob/living/carbon/human/listener, atom/song_source)
	return

/**
 * When the song is long enough, it will have a special effect when it ends.
 *
 * If you want something that ALWAYS goes off regardless of song length, affix it to the Destroy proc. The rite is destroyed when smooth tunes is done.
 *
 * Arguments:
 * * listener - A mob, listening to the song
 * * song_source - parent of the smooth_tunes component. This is limited to the compatible items of said component, which currently includes mobs and objects so we'll have to type appropriately.
 */
/datum/religion_rites/song_tuner/proc/finish_effect(mob/living/carbon/human/listener, atom/song_source)
	return

/datum/religion_rites/song_tuner/evangelism
	name = "Благовестнический Гимн"
	desc = "Распространяйте слово вашего Бога, завоевывая благосклонность каждого слушателя. В конце песни вы благословите всех слушателей, улучшив их настроение."
	particles_path = /particles/musical_notes/holy
	song_invocation_message = "Вы приготовили песнь Святых!"
	song_start_message = "<span class='notice'>Эта музыка благословенна!</span>"
	glow_color = "#FEFFE0"
	favor_cost = 0
	buff = TRUE
	needed_aspects = list(
		ASPECT_RESCUE = 1,
	)

/datum/religion_rites/song_tuner/evangelism/song_effect(mob/living/carbon/human/listener, atom/song_source)
	// A ckey requirement is good to have for gaining favor, to stop monkey farms and such.
	if(!religion || listener.mind?.holy_role || !listener.ckey)
		return
	religion.adjust_favor(0.2)

/datum/religion_rites/song_tuner/evangelism/finish_effect(mob/living/carbon/human/listener, atom/song_source)
	SEND_SIGNAL(listener, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)

/datum/mood_event/blessing
	description = "Я был благословлен."
	mood_change = 3
	timeout = 8 MINUTES
/*
/datum/religion_rites/song_tuner/nullwave
	name = "Nullwave Vibrato"
	desc = "Sing a dull song, protecting those who listen from magic."
	particles_path = /particles/musical_notes/nullwave
	song_invocation_message = "You've prepared an antimagic song!"
	song_start_message = span_nicegreen("This music makes you feel protected!")
	glow_color = "#a9a9b8"
	repeats_okay = FALSE

/datum/religion_rites/song_tuner/nullwave/song_effect(mob/living/carbon/human/listener, atom/song_source)
	listener.apply_status_effect(/datum/status_effect/song/antimagic)
*/
/datum/religion_rites/song_tuner/pain
	name = "Убийственный аккорд"
	desc = "Использование настлолько ужасного пения, что режет оно не только слух. Действует менее эффективно на просвятлённых. В конце песни ты откроешь раны у всех слушателей."
	particles_path = /particles/musical_notes/harm
	song_invocation_message = "От песни будет кровь из ушей. И не только."
	song_start_message = "<span class='danger'>This music cuts like a knife!</span>"
	glow_color = "#FF4460"
	repeats_okay = FALSE
	needed_aspects = list(
		ASPECT_DEATH = 1,
	)

/datum/religion_rites/song_tuner/pain/song_effect(mob/living/carbon/human/listener, atom/song_source)
	var/damage_dealt = 1
	if(listener.mind?.holy_role)
		damage_dealt *= 0.5

	listener.adjustBruteLoss(damage_dealt)

/datum/religion_rites/song_tuner/pain/finish_effect(mob/living/carbon/human/listener, atom/song_source)
	var/obj/item/organ/external/sliced_limb = pick(listener.bodyparts)
	sliced_limb.createwound(CUT, 18)

/datum/religion_rites/song_tuner/lullaby
	name = "Колыбель Души"
	desc = "Пойте колыбельную, утомляя окружающих, заставляя их засыпать. В конце песни люди ненадолго заснут."
	particles_path = /particles/musical_notes/sleepy
	song_invocation_message = "Вы приготовили колыбель!"
	song_start_message = "<span class='warning'>От этой музыки клонит в сон...</span>"
	favor_cost = 40 //actually really strong
	glow_color = "#83F6FF"
	repeats_okay = FALSE
	///assoc list of weakrefs to who heard the song, for the finishing effect to look at.
	var/list/listener_counter = list()
	needed_aspects = list(
		ASPECT_MYSTIC = 1,
	)

/datum/religion_rites/song_tuner/lullaby/Destroy()
	listener_counter.Cut()
	return ..()

/datum/religion_rites/song_tuner/lullaby/song_effect(mob/living/carbon/human/listener, atom/song_source)
	if(listener.mind?.holy_role)
		return

	var/static/list/sleepy_messages = list(
		"От этой музыки так и клонит в сон...",
		"Музыка заставляет на мгновение задремать.",
		"Приходится сосредототачиваться на том, чтобы не заснуть во время исполнения этой песни.",
	)

	if(prob(20))
		to_chat(listener, "<span class='warning'>[pick(sleepy_messages)]</span>")
		listener.emote("yawn")
	listener.blurEyes(2)

/datum/religion_rites/song_tuner/lullaby/finish_effect(mob/living/carbon/human/listener, atom/song_source)
	to_chat(listener, "<span class='notice'>Вау, конец песни был... отличный...</span>")
	listener.AdjustSleeping(5 SECONDS)
