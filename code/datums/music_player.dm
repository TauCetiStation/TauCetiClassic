/**
 * How to use:
 * Give variable with this datum to any object you want, initialize it
 * and give object the way to call `interact()` method.
 *
 * Example:
 * > /obj/entity
 * > 	var/datum/music_player/MP
 * >
 * > /obj/entity/New()
 * > 	MP = new(src, [path to notes])
 * >
 * > /obj/entity/Destroy()
 * > 	QDEL_NULL(MP)
 * > 	return ..()
 * >
 * > /obj/entity/foo()
 * > 	MP.interact(usr)
 *
 * Override `unable_to_play()` object method to give music playing conditions.
 */

#define COUNT_PAUSE(tempo) 10 / (tempo / 60)

#define DEFAULT_TEMPO    120
#define DEFAULT_VOLUME   100
#define MAX_LINE_SIZE    50
#define MAX_LINES_COUNT  150
#define MAX_SONG_SIZE    MAX_LINE_SIZE*MAX_LINES_COUNT
#define MAX_REPEAT_COUNT 10
#define MAX_TEMPO_RATE   600

// Cache holder for sound() instances.
var/global/datum/notes_storage/note_cache_storage = new

/datum/notes_storage
	var/list/instrument_sound_notes = list() // associative list.

/**
 * Method called before playing of every note, so it's some kinde of
 * 'process-like' check to stop, for example, playing song
 * in the middle with by conditions you want.
 *
 * Should return `TRUE` to stop music.
 *
 * Example:
 * > /obj/entity/unable_to_play(mob/living/user)
 * > 	return ..() || ...conditions
 */
/obj/proc/unable_to_play(mob/living/user)
	return user.incapacitated() || user.lying


/datum/music_player
	var/obj/instrument  = null
	var/sound_path      = ""

	var/list/song_lines = list()
	var/list/lyrics_lines = list()
	var/song_tempo      = DEFAULT_TEMPO

	var/sing_lyrics = FALSE
	var/playing   = FALSE
	var/show_help = FALSE
	var/show_edit = TRUE
	var/repeat    = 0
	var/volume    = DEFAULT_VOLUME

/datum/music_player/New(instrument, sound_path)
	..()
	src.instrument = instrument
	src.sound_path = sound_path

/datum/music_player/Destroy()
	instrument = null
	return ..()

/datum/music_player/proc/interact(mob/living/user)
	if(!istype(user) || !instrument.Adjacent(user) || issilicon(user) || user.incapacitated())
		return

	var/html = ""

	if(song_lines.len)
		if(playing)
			html += "<a href='?src=\ref[src];stop=1'>Stop Playing</a><br>"
			html += "Repeats left: [repeat]<br><br>"
		else
			html += "<a href='?src=\ref[src];play=1'>Play Song</a><br>"
			html += "<a href='?src=\ref[src];repeat=1'>Repeat Song: [repeat] times</a><br><br>"

	if(lyrics_lines.len)
		if(sing_lyrics)
			html += "<a href='?src=\ref[src];switch_singing_lyrics_to=0'>You will sing lyrics</a><br><br>"
		else
			html += "<a href='?src=\ref[src];switch_singing_lyrics_to=1'>You will not sing lyrics</a><br><br>"

	if(!show_edit)
		html += "<a href='?src=\ref[src];show_edit=1'>Show Editor</a><br><br>"
	else
		html += "<a href='?src=\ref[src];show_edit=0'>Hide Editor</a><br>"
		if(song_lines.len)
			html += "<a href='?src=\ref[src];newsong=1'>Start a New Song</a><br>"
		html += "<a href='?src=\ref[src];import=1'>Import a Song</a><br><br>"

		if(song_lines.len)
			html += "<a href='?src=\ref[src];change_tempo=1'>Tempo: [song_tempo] BPM</a><br><br>"

			html += "<table>"
			for(var/line_num in 1 to song_lines.len)
				html += "<tr>"
				html += "<td><b>Line [line_num]:</b></td>"
				html += "<td>[song_lines[line_num]]</td>"
				html += "<td><a href='?src=\ref[src];deleteline=[line_num]'>Delete Line</a> <a href='?src=\ref[src];modifyline=[line_num]'>Modify Line</a></td>"
				html += "</tr>"
			html += "</table>"

			html += "<a href='?src=\ref[src];newline=1'>Add Line</a><br><br>"

		html += "<a href='?src=\ref[src];import_lyrics=1'>Import Lyrics</a><br><br>"

		if(lyrics_lines.len)
			html += "<table>"
			for(var/line_num in 1 to lyrics_lines.len)
				html += "<tr>"
				html += "<td><b>Line [line_num]:</b></td>"
				html += "<td>[lyrics_lines[line_num]]</td>"
				html += "<td><a href='?src=\ref[src];delete_lyrics_line=[line_num]'>Delete Line</a> <a href='?src=\ref[src];modify_lyrics_line=[line_num]'>Modify Line</a></td>"
				html += "</tr>"
			html += "</table>"

			html += "<a href='?src=\ref[src];new_lyrics_line=1'>Add Lyrics Line</a><br><br>"

		if(!show_help)
			html += "<a href='?src=\ref[src];show_help=1'>Show help</a>"
		else
			html += "<a href='?src=\ref[src];show_help=0'>Hide Help</a><br>"
			html += {"
					Lines are a series of chords, separated by commas (,), each with notes seperated by hyphens (-).<br>
					Every note in a chord will play together, with chord timed by the tempo.<br>
					<br>
					Notes are played by the names of the note, and optionally, the accidental, and/or the octave number.<br>
					By default, every note is natural and in octave 3. Defining otherwise is remembered for each note.<br>
					Example: <i>C,D,E,F,G,A,B</i> will play a C major scale.<br>
					After a note has an accidental placed, it will be remembered: <i>C,C4,C,C3</i> is <i>C3,C4,C4,C3</i><br>
					Chords can be played simply by seperating each note with a hyphon: <i>A-C#,Cn-E,E-G#,Gn-B</i><br>
					A pause may be denoted by an empty chord: <i>C,E,,C,G</i><br>
					To make a chord be a different time, end it with /x, where the chord length will be length<br>
					defined by tempo / x: <i>C,G/2,E/4</i><br>
					Combined, an example is: <i>E-E4/4,/2,G#/8,B/8,E3-E4/4</i>
					<br>
					Lines may be up to [MAX_LINE_SIZE] characters.<br>
					A song may only contain up to [MAX_LINES_COUNT] lines.<br>
					"}

	user.set_machine(instrument)
	instrument.add_fingerprint(user)

	var/datum/browser/popup = new(user, "musical_instrument_[instrument.name]", instrument.name, 700, 700)
	popup.set_content(html)
	popup.open()

/datum/music_player/Topic(herf, href_list)
	..()

	if(instrument.Adjacent(usr) && isliving(usr) && !issilicon(usr))
		if(href_list["newsong"])
			playing = FALSE
			SEND_SIGNAL(instrument, COMSIG_INSTRUMENT_END, FALSE)
			song_lines.len = 0
			lyrics_lines.len = 0

		else if(href_list["show_help"])
			show_help = text2num(href_list["show_help"])

		else if(href_list["show_edit"])
			show_edit = text2num(href_list["show_edit"])

		else if(href_list["repeat"])
			if(playing)
				return

			var/repeat_num = input("How many times do you want to repeat this piece? (max: [MAX_REPEAT_COUNT])") as num|null

			if(!instrument.Adjacent(usr))
				return

			repeat = clamp(repeat_num, 0, MAX_REPEAT_COUNT)

		else if(href_list["change_tempo"])
			var/new_tempo = input("Enter new tempo: ", "Change tempo", song_tempo) as num|null

			if(!instrument.Adjacent(usr))
				return

			song_tempo = clamp(new_tempo, 1, MAX_TEMPO_RATE)
			SEND_SIGNAL(instrument, COMSIG_INSTRUMENT_TEMPO_CHANGE, src)

		else if(href_list["play"])
			playing = TRUE
			INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/music_player, playsong), usr)
			SEND_SIGNAL(usr, COMSIG_ATOM_STARTING_INSTRUMENT, src)

		else if(href_list["newline"])
			if(song_lines.len > MAX_LINES_COUNT)
				return

			var/newline = sanitize(input("Enter new line: ") as text|null, MAX_LINE_SIZE, ascii_only = TRUE)

			if(!newline || !instrument.Adjacent(usr))
				return

			song_lines += newline

		else if(href_list["deleteline"])
			var/line_num = text2num(href_list["deleteline"])
			song_lines.Cut(line_num, line_num + 1)

		else if(href_list["modifyline"])
			var/line_num = text2num(href_list["modifyline"])
			var/content = sanitize(input("Enter your line: ", "Change line [line_num]", song_lines[line_num]) as text|null, MAX_LINE_SIZE, ascii_only = TRUE)

			if (!content || !instrument.Adjacent(usr))
				return

			song_lines[line_num] = content

		else if(href_list["new_lyrics_line"])
			if(lyrics_lines.len > MAX_LINES_COUNT)
				return

			var/newline = sanitize(input("Enter new lyrics line: ") as text|null, MAX_LINE_SIZE, ascii_only = TRUE)

			if(!newline || !instrument.Adjacent(usr))
				return

			lyrics_lines += newline

		else if(href_list["delete_lyrics_line"])
			var/line_num = text2num(href_list["delete_lyrics_line"])
			lyrics_lines.Cut(line_num, line_num + 1)

		else if(href_list["modify_lyrics_line"])
			var/line_num = text2num(href_list["modify_lyrics_line"])
			var/content = sanitize(input("Enter your line: ", "Change lyrics line [line_num]", lyrics_lines[line_num]) as text|null, MAX_LINE_SIZE, ascii_only = TRUE)

			if (!content || !instrument.Adjacent(usr))
				return

			lyrics_lines[line_num] = content

		else if(href_list["stop"])
			playing = FALSE
			SEND_SIGNAL(instrument, COMSIG_INSTRUMENT_END, FALSE)

		else if(href_list["import"])
			var/song = ""
			for (var/line in song_lines)
				song += line + "\n"

			var/song_text = sanitize(input("Please, paste the entire song formatted: ", "Import Song", input_default(song)) as message|null, MAX_SONG_SIZE, extra = FALSE, ascii_only = TRUE)

			if (!song_text || !instrument.Adjacent(usr))
				return

			parse_song_text(song_text)
			playing = FALSE
			SEND_SIGNAL(instrument, COMSIG_INSTRUMENT_END, FALSE)

		else if(href_list["import_lyrics"])
			var/lyrics = ""
			for (var/line in lyrics_lines)
				lyrics += line + "\n"

			var/lyrics_text = sanitize(input("Please, paste the entire lyrics: ", "Import Lyrics", input_default(lyrics)) as message|null, MAX_SONG_SIZE, extra = FALSE, ascii_only = TRUE)

			if (!lyrics_text || !instrument.Adjacent(usr))
				return

			parse_lyrics_text(lyrics_text)
			sing_lyrics = TRUE
			playing = FALSE
			SEND_SIGNAL(instrument, COMSIG_INSTRUMENT_END, FALSE)

		else if(href_list["switch_singing_lyrics_to"])
			sing_lyrics = text2num(href_list["switch_singing_lyrics_to"])

		interact(usr)

	if(href_list["close"])
		usr << browse(null, "window=musical_instrument_[instrument.name]")
		usr.unset_machine(instrument)

/datum/music_player/proc/playsong(mob/living/musician)
	do
		var/cur_oct[7]
		var/cur_acc[7]

		for(var/i in 1 to 7)
			cur_oct[i] = "3"
			cur_acc[i] = "n"

		for(var/line in song_lines)
			for(var/beat in splittext(lowertext(line), ","))

				// Some browsers may delete last space on line when copying text in buffer,
				// so it result into runtime error in case like that `A5-F5-D5, `
				if(!beat)
					beat = " "

				if(sing_lyrics && lyrics_lines.len)
					if(beat[1] == "l" && length(beat) > 1)
						var/lyrics_line_num = text2num(copytext(beat, 2, length(beat) + 1))
						if(lyrics_line_num > 0 && lyrics_line_num <= lyrics_lines.len)
							musician.say(lyrics_lines[lyrics_line_num])
							continue

				var/list/notes = splittext(beat, "/")

				for(var/note in splittext(notes[1], "-"))
					if(!playing || instrument.unable_to_play(musician))
						playing = FALSE
						SEND_SIGNAL(instrument, COMSIG_INSTRUMENT_END, FALSE)
						return

					if(length(note) == 0)
						continue

					var/cur_note = text2ascii(note) - 96
					if(cur_note < 1 || cur_note > 7)
						continue

					for(var/i in 2 to length(note))
						var/ni = copytext(note,i,i+1)

						if(!text2num(ni))
							if(ni == "#" || ni == "b" || ni == "n")
								cur_acc[cur_note] = ni
							else if(ni == "s")
								cur_acc[cur_note] = "#"
						else
							cur_oct[cur_note] = ni

					var/current_note = uppertext(copytext(note, 1, 2)) + cur_acc[cur_note] + cur_oct[cur_note]

					if(fexists("[sound_path]/[current_note].ogg"))
						// ^ Since this is dynamic path, no point in running playsound without file (since it will play even "no file" and eat cpu for nothing)
						// and no point in integrating this into playsound itself,
						// because this is the only case where we use dynamic path for sounds, as they should be avoided normally.
						// Without cache dynamic paths eat 10~ times more CPU than doing same with hardcoded paths, so cache is required.

						var/sound/S = global.note_cache_storage.instrument_sound_notes["[sound_path]/[current_note]"]
						if(!S)
							S = global.note_cache_storage.instrument_sound_notes["[sound_path]/[current_note]"] = sound("[sound_path]/[current_note].ogg")
						playsound(instrument, S, VOL_EFFECTS_INSTRUMENT, volume, FALSE, null, null, falloff = 5)

				var/pause_time = COUNT_PAUSE(song_tempo)

				if(notes.len >= 2 && text2num(notes[2]))
					pause_time /= text2num(notes[2])

				sleep(pause_time)
		SEND_SIGNAL(instrument, COMSIG_INSTRUMENT_REPEAT, TRUE)
	while(repeat-- > 0)

	repeat = 0
	playing = FALSE
	SEND_SIGNAL(instrument, COMSIG_INSTRUMENT_END, TRUE)
	interact(musician)

/datum/music_player/proc/parse_song_text(song_text)
	if(!song_text)
		return

	var/list/lines = splittext(song_text, "\n")

	if(copytext(lines[1], 1, 5) == "BPM:")
		song_tempo = clamp(text2num(copytext(lines[1], 5)), 1, MAX_TEMPO_RATE)
		lines.Cut(1, 2)

	if(lines.len > MAX_LINES_COUNT)
		lines.Cut(MAX_LINES_COUNT + 1)

	for(var/line_num in 1 to lines.len)
		lines[line_num] = sanitize(lines[line_num] as text|null, MAX_LINE_SIZE)

	song_lines = lines

/datum/music_player/proc/parse_lyrics_text(lyrics_text)
	if(!lyrics_text)
		return

	var/list/lines = splittext(lyrics_text, "\n")

	if(lines.len > MAX_LINES_COUNT)
		lines.Cut(MAX_LINES_COUNT + 1)

	for(var/line_num in 1 to lines.len)
		lines[line_num] = sanitize(lines[line_num] as text|null, MAX_LINE_SIZE)

	lyrics_lines = lines

#undef COUNT_PAUSE
#undef DEFAULT_TEMPO
#undef DEFAULT_VOLUME
#undef MAX_LINE_SIZE
#undef MAX_LINES_COUNT
#undef MAX_SONG_SIZE
#undef MAX_REPEAT_COUNT
#undef MAX_TEMPO_RATE
