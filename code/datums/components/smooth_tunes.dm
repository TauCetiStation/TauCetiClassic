///how many lines divided by tempo should at least be higher than this.
#define LONG_ENOUGH_SONG 0.1

///Smooth tunes component! Applied to musicians to give the songs they play special effects, according to a rite!
///Comes with particles
/datum/component/smooth_tunes
	///if applied due to a rite, we link it here
	var/datum/religion_rites/song_tuner/linked_songtuner_rite
	///linked song
	var/datum/music_player/linked_song
	///if repeats count as continuations instead of a song's end, TRUE
	var/allow_repeats = TRUE
	///particles to apply, if applicable
	var/particles_path
	///a funny little glow applied to the instrument while playing
	var/glow_color
	///whether to call the rite's finish effect, only true when the song is long enough
	var/viable_for_final_effect = FALSE

/datum/component/smooth_tunes/Initialize(linked_songtuner_rite, allow_repeats, particles_path, glow_color)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	src.linked_songtuner_rite = linked_songtuner_rite
	src.allow_repeats = allow_repeats
	src.particles_path = particles_path
	src.glow_color = glow_color

/datum/component/smooth_tunes/Destroy(force, silent)
	var/mob/M = parent
	if(M.particles?.type == particles_path)
		QDEL_NULL(M.particles)
	linked_song?.instrument?.remove_filter("smooth_tunes_outline")
	return ..()

/datum/component/smooth_tunes/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_STARTING_INSTRUMENT, PROC_REF(start_singing))

/datum/component/smooth_tunes/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_STARTING_INSTRUMENT)

///Initiates the effect when the song begins playing.
/datum/component/smooth_tunes/proc/start_singing(datum/source, datum/music_player/song)
	SIGNAL_HANDLER
	if(!song)
		return
	if(song.song_lines.len / song.song_tempo > LONG_ENOUGH_SONG)
		viable_for_final_effect = TRUE
	else
		to_chat(parent, "<span class='warning'>This song is too short, so it won't include the song finishing effect.</span>")
	START_PROCESSING(SSobj, src) //even though WE aren't an object, our parent is!
	if(linked_songtuner_rite.song_start_message)
		song.instrument.visible_message(linked_songtuner_rite.song_start_message)

	///prevent more songs from being blessed concurrently, mob signal
	UnregisterSignal(parent, COMSIG_ATOM_STARTING_INSTRUMENT)
	///and hook into the instrument this time, preventing other weird exploity stuff.
	RegisterSignal(song.instrument, COMSIG_INSTRUMENT_TEMPO_CHANGE, PROC_REF(tempo_change))
	RegisterSignal(song.instrument, COMSIG_INSTRUMENT_END, PROC_REF(stop_singing))
	if(!allow_repeats)
		RegisterSignal(song.instrument, COMSIG_INSTRUMENT_REPEAT, PROC_REF(stop_singing))

	linked_song = song
	if(particles_path && ismovable(linked_song.instrument))
		var/mob/M = parent
		M.particles = new particles_path()

	linked_song.instrument.add_filter("smooth_tunes_outline", 9, list("type" = "outline", "color" = glow_color))

///Prevents changing tempo during a song to sneak in final effects quicker
/datum/component/smooth_tunes/proc/tempo_change(datum/source, datum/music_player/modified_song)
	SIGNAL_HANDLER
	if(!modified_song.playing || !viable_for_final_effect)
		return
	to_chat(parent, "<span class='warning'>Modifying the song mid-performance has removed your ability to perform the song finishing effect.</span>")
	viable_for_final_effect = FALSE

///Ends the effect when the song is no longer playing.
/datum/component/smooth_tunes/proc/stop_singing(datum/source, finished)
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)
	if(viable_for_final_effect)
		var/mob/M = parent
		if(finished && linked_songtuner_rite && linked_song)
			for(var/mob/living/listener in hearers(7, parent))
				if(listener == parent)
					continue
				if(!linked_songtuner_rite.buff && listener.my_religion == M.my_religion)
					continue

				linked_songtuner_rite.finish_effect(listener, parent)
			linked_songtuner_rite.end_song()
		else
			to_chat(parent, "<span class='warning'>The song was interrupted, you cannot activate the finishing ability!</span>")

	linked_song.instrument.remove_filter("smooth_tunes_outline")
	UnregisterSignal(linked_song.instrument, list(
		COMSIG_INSTRUMENT_TEMPO_CHANGE,
		COMSIG_INSTRUMENT_END,
		COMSIG_INSTRUMENT_REPEAT,
	))
	linked_song = null
	qdel(src)

/datum/component/smooth_tunes/process()
	if(!linked_songtuner_rite || !linked_song)
		stop_singing()
		return
	var/mob/M = parent
	for(var/mob/living/listener in hearers(7, parent))
		if(listener == parent)
			continue
		if(!linked_songtuner_rite.buff && listener.my_religion == M.my_religion)
			continue
		linked_songtuner_rite.song_effect(listener, linked_song.instrument)

#undef LONG_ENOUGH_SONG
