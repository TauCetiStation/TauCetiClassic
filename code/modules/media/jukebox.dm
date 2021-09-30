/*******************************
 * Largely a rewrite of the Jukebox from D2K5
 *
 * By N3X15
 *******************************/

#define JUKEMODE_SHUFFLE     1 // Default
#define JUKEMODE_REPEAT_SONG 2
#define JUKEMODE_PLAY_ONCE   3 // Play, then stop.
#define JUKEMODE_COUNT       3

#define JUKEBOX_RELOAD_COOLDOWN 600 // 60s

// Represents a record returned.
/datum/song_info
	var/title  = ""
	var/artist = ""
	var/album  = ""

	var/url    = ""
	var/length = 0 // decaseconds

	var/emagged = 0

/datum/song_info/New(list/json)
	title  = json["title"]
	artist = json["artist"]
	album  = json["album"]

	url    = json["url"]

	length = text2num(json["length"])

/datum/song_info/proc/display()
	var/str="\"[title]\""
	if(artist!="")
		str += ", by [artist]"
	if(album!="")
		str += ", from '[album]'"
	return str

/datum/song_info/proc/displaytitle()
	if(artist==""&&title=="")
		return "\[NO TAGS\]"
	var/str=""
	if(artist!="")
		str += "[artist] - "
	if(title!="")
		str += "\"[title]\""
	else
		str += "Untitled"
	return str


var/global/loopModeNames=list(
	JUKEMODE_SHUFFLE = "Shuffle",
	JUKEMODE_REPEAT_SONG = "Single",
	JUKEMODE_PLAY_ONCE= "Once",
)
/obj/machinery/media/jukebox
	name = "Jukebox"
	desc = "A jukebox used for parties and shit."
	icon = 'icons/obj/jukebox.dmi'
	icon_state = "jukebox2-nopower"
	density = TRUE

	anchored = TRUE
	playing = 0
	var/transmitting = FALSE

	var/loop_mode = JUKEMODE_SHUFFLE

	// Server-side playlist IDs this jukebox can play.
	var/list/playlists=list() // ID = Label

	// Playlist to load at startup.
	var/playlist_id = ""

	var/list/playlist
	var/current_song  = 0
	var/autoplay      = 0
	var/last_reload   = 0
	var/state_base = "jukebox2"
	var/media_frequency = 1984

/obj/machinery/media/jukebox/power_change()
	..()
	if(emagged && !(stat & (NOPOWER|BROKEN)))
		playing = 1
	update_icon()

/obj/machinery/media/jukebox/update_icon()
	cut_overlays()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		if(stat & BROKEN)
			icon_state = "[state_base]-broken"
		else
			icon_state = "[state_base]-nopower"
		stop_playing()
		return
	icon_state = state_base
	if(playing)
		if(emagged)
			add_overlay("[state_base]-emagged")
		else
			add_overlay("[state_base]-running")

/obj/machinery/media/jukebox/proc/check_reload()
	return world.time > last_reload + JUKEBOX_RELOAD_COOLDOWN

/obj/machinery/media/jukebox/ui_interact(mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(stat & NOPOWER)
		to_chat(usr, "<span class='warning'>You don't see anything to mess with.</span>")
		return
	if(stat & BROKEN && playlist!=null)
		user.visible_message("<span class='warning'><b>[user.name] smacks the side of \the [src.name].</b></span>","<span class='warning'>You hammer the side of \the [src.name].</span>")
		stat &= ~BROKEN
		playlist=null
		playing=emagged
		update_icon()
		return
	var/t = "<h1>Jukebox Interface</h1>"
	t += "<b>Power:</b> <a href='?src=\ref[src];power=1'>[playing?"On":"Off"]</a><br />"
	t += "<b>Play Mode:</b> <a href='?src=\ref[src];mode=1'>[loopModeNames[loop_mode]]</a><br />"
	t += "<b>Transmitter:</b> <a href='?src=\ref[src];transmit=1'>[transmitting?"On":"Off"]</a><br />"
	t += "Frequency: <A href='byond://?src=\ref[src];set_freq=-1'>[format_frequency(media_frequency)]</a><BR>"
	if(playlist == null)
		t += "\[DOWNLOADING PLAYLIST, PLEASE WAIT\]"
	else
		if(check_reload())
			t += "<b>Playlist:</b> "
			for(var/plid in playlists)
				t += "<a href='?src=\ref[src];playlist=[plid]'>[playlists[plid]]</a>"
		else
			t += "<i>Please wait before changing playlists.</i>"
		t += "<br />"
		if(current_song && current_song < playlist.len)
			var/datum/song_info/song=playlist[current_song]
			t += "<b>Current song:</b> [song.artist] - [song.title]<br />"
		t += "<table class='prettytable'><tr><th colspan='2'>Artist - Title</th><th>Album</th></tr>"
		var/i
		for(i = 1,i <= playlist.len,i++)
			var/datum/song_info/song=playlist[i]
			t += "<tr><th>#[i]</th><td><A href='?src=\ref[src];song=[i]' class='nobg'>[song.displaytitle()]</A></td><td>[song.album]</td></tr>"
		t += "</table>"

	var/datum/browser/popup = new (user,"jukebox",name,420,700)
	popup.set_content(t)
	popup.open()


/obj/machinery/media/jukebox/attackby(obj/item/W, mob/user, params)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(iswrench(W))
		if(user.is_busy(src))
			return
		var/un = !anchored ? "" : "un"
		user.visible_message("<span class='notice'>[user.name] begins [un]locking \the [src.name]'s casters.</span>","<span class='notice'>You begin [un]locking \the [src.name]'s casters.</span>")
		if(W.use_tool(src, user, 30, volume = 50))
			anchored = !anchored
			user.visible_message("<span class='notice'>[user.name] [un]locks \the [src.name]'s casters.</span>","<span class='warning'>You [un]lock \the [src.name]'s casters.</span>")
			playing = emagged
			update_music()
			update_icon()
<<<<<<< Updated upstream
=======
			if(!anchored)
				disconnect_media_source()
				disconnect_frequency()
>>>>>>> Stashed changes
	else
		..()

/obj/machinery/media/jukebox/emag_act(mob/user)
	current_song = 0
	if(!emagged)
		playlist_id = "emagged"
		last_reload=world.time
		playlist=null
		loop_mode = JUKEMODE_SHUFFLE
		emagged = 1
		playing = 1
		user.visible_message("<span class='warning'>[user.name] slides something into the [src.name]'s card-reader.</span>","<span class='warning'>You short out the [src.name].</span>")
		update_icon()
		update_music()
	return TRUE

/obj/machinery/media/jukebox/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(emagged)
		to_chat(usr, "<span class='warning'>You touch the bluescreened menu. Nothing happens. You feel dumber.</span>")
		return FALSE

	if (href_list["power"])
		playing = !playing
		update_music()
		update_icon()

	if (href_list["transmit"])
		transmitting = !transmitting

	if (href_list["set_freq"])
		var/newfreq=media_frequency
		if(href_list["set_freq"]!="-1")
			newfreq = text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Set a new frequency (MHz, 90.0, 200.0).", src, media_frequency) as null|num
		if(newfreq)
			if(!IS_INTEGER(newfreq))
				newfreq *= 10 // shift the decimal one place
			if(newfreq > 900 && newfreq < 2000) // Between (90.0 and 100.0)
				disconnect_frequency()
				media_frequency = newfreq
				connect_frequency()
			else
				to_chat(usr, "<span class='warning'>Invalid FM frequency. (90.0, 200.0)</span>")

	if (href_list["playlist"])
		if(!check_reload())
			to_chat(usr, "<span class='warning'>You must wait 60 seconds between playlist reloads.</span>")
			return FALSE
		playlist_id = href_list["playlist"]
		last_reload = world.time
		playlist = null
		current_song = 0
		update_music()
		update_icon()

	if (href_list["song"])
		current_song=clamp(text2num(href_list["song"]), 1, playlist.len)
		update_music()
		update_icon()

	if (href_list["mode"])
		loop_mode = (loop_mode % JUKEMODE_COUNT) + 1

	updateUsrDialog()

/obj/machinery/media/jukebox/process()
	if(!playlist)
		var/url="[config.media_base_url]/index.php?playlist=[playlist_id]"
		//testing("[src] - Updating playlist from [url]...")
		var/response = world.Export(url)
		playlist=list()
		if(response)
			var/json = file2text(response["CONTENT"])
			if("/>" in json)
				visible_message("<span class='warning'>[bicon(src)] \The [src] buzzes, unable to update its playlist.</span>","<em>You hear a buzz.</em>")
				stat &= BROKEN
				update_icon()
				return
			var/songdata = json_decode(json)
			for(var/list/record in songdata)
				playlist += new /datum/song_info(record)
			if(playlist.len==0)
				visible_message("<span class='warning'>[bicon(src)] \The [src] buzzes, unable to update its playlist.</span>","<em>You hear a buzz.</em>")
				stat &= BROKEN
				update_icon()
				return
			visible_message("<span class='notice'>[bicon(src)] \The [src] beeps, and the menu on its front fills with [playlist.len] items.</span>","<em>You hear a beep.</em>")
			if(autoplay)
				playing=1
				autoplay=0
		else
			//testing("[src] failed to update playlist: Response null.")
			stat &= BROKEN
			update_icon()
			return
	if(playing)
		var/datum/song_info/song
		if(current_song && current_song <= playlist.len)
			song = playlist[current_song]
		if(!current_song || (song && world.time >= media_start_time + song.length))
			current_song=1
			switch(loop_mode)
				if(JUKEMODE_SHUFFLE)
					current_song=rand(1,playlist.len)
				if(JUKEMODE_REPEAT_SONG)
					current_song=current_song
				if(JUKEMODE_PLAY_ONCE)
					playing=0
					update_icon()
					return
			update_music()
		if(transmitting)
			var/freq = num2text(media_frequency)
			if(!(freq in media_transmitters))
				connect_frequency()
			if(freq in media_receivers)
				for(var/obj/machinery/media/speaker/Speaker in media_receivers[freq])
					Speaker.receive_broadcast(media_url,media_start_time)
		else
			disconnect_frequency()

/obj/machinery/media/jukebox/update_music()

	if(current_song && current_song <= playlist.len && playing )
		var/datum/song_info/song = playlist[current_song]
		media_url = song.url
		media_start_time = world.time
		visible_message("<span class='notice'>[bicon(src)] \The [src] begins to play [song.display()].</span>","<em>You hear music.</em>")
		//visible_message("<span class='notice'>[bicon(src)] \The [src] warbles: [song.length/10]s @ [song.url]</span>")
	else
		media_url=""
		media_start_time = 0
	if(transmitting)
		var/freq = num2text(media_frequency)
		if(freq in media_receivers)
			for(var/obj/machinery/media/speaker/Speaker in media_receivers[freq])
				Speaker.receive_broadcast(media_url,media_start_time)
	..()

/obj/machinery/media/jukebox/proc/stop_playing()
	//current_song=0
	playing=0
	update_music()
	return

/obj/machinery/media/jukebox/Destroy()
	disconnect_frequency()
	disconnect_media_source()
	return ..()

/obj/machinery/media/jukebox/setLoc(turf/T, teleported=0)
	disconnect_frequency()
	disconnect_media_source()
	..(T)
	if(anchored)
		update_music()

/obj/machinery/media/jukebox/proc/connect_frequency()
	var/list/transmitters=list()
	var/freq = num2text(media_frequency)
	if(freq in media_transmitters)
		transmitters = media_transmitters[freq]
	transmitters.Add(src)
	media_transmitters[freq]=transmitters

/obj/machinery/media/jukebox/proc/disconnect_frequency()
	var/list/transmitters=list()
	var/freq = num2text(media_frequency)
	if(freq in media_transmitters)
		transmitters = media_transmitters[freq]
	transmitters.Remove(src)
	media_transmitters[freq]=transmitters

/obj/machinery/media/jukebox/bar
	playlist_id="bar"
	// Must be defined on your server.
	playlists=list(
		"bar"  = "Bar Mix",
		"mogesfm84"  = "Moghes FM-84",
		"moges" = "Moghes Club Music",
		"club" = "Club Mix",
		"customs" = "Customs Music",
		"japan" = "Banzai Radio",
		"govnar" = "Soviet Radio",
		"classic" = "Classical Music",
		"ussr_disco" = "Disco USSR-89s",
		"topreptilian" = "Top Reptillian",
		"zvukbanok" = "Sounds of beer cans",
		"eurobeat" = "Eurobeat",
		"finland" = "Suomi wave",
		"dreamsofvenus" = "Dreams of Venus",
		"hiphop" = "Hip-Hop for Space Gangstas",
		"vaporfunk" = "Qerrbalak VaporFunkFM",
		"thematic" = "Side-Bursting Tunes",
		"lofi" = "Sadness/Longing/Loneliness",
	)

// Relaxing elevator music~
/obj/machinery/media/jukebox/dj

	playlist_id="bar"
	autoplay = 1

	id_tag="DJ Satellite" // For autolink

	// Must be defined on your server.
	playlists=list(
		"bar"  = "Bar Mix",
		"mogesfm84"  = "Moghes FM-84",
		"moges" = "Moghes Club Music",
		"club" = "Club Mix",
		"customs" = "Customs Music",
		"japan" = "Banzai Radio",
		"govnar" = "Soviet Radio",
		"classic" = "Classical Music",
		"ussr_disco" = "Disco USSR-89s",
		"topreptilian" = "Top Reptillian",
		"zvukbanok" = "Sounds of beer cans",
		"eurobeat" = "Eurobeat",
		"finland" = "Suomi wave",
		"dreamsofvenus" = "Dreams of Venus",
		"hiphop" = "Hip-Hop for Space Gangstas",
		"vaporfunk" = "Qerrbalak VaporFunkFM",
		"thematic" = "Side-Bursting Tunes",
		"lofi" = "Sadness/Longing/Loneliness",
	)

/obj/machinery/media/jukebox/techno
	name = "Techno disc"
	desc = "Looks like an oldschool mixing board that somehow plays music, don't ask us how, we don't know."
	state_base = "mixer"
	playlist_id="club"

	playlists=list(
		"club"	= "Club Mix",

	)

/obj/machinery/media/jukebox/shuttle
	playlist_id="shuttle"
	// Must be defined on your server.
	playlists=list(
		"shuttle"  = "Shuttle Mix"
	)
	invisibility=101 // FAK U NO SONG 4 U

/obj/machinery/media/jukebox/lobby
	playlist_id="lobby"
	// Must be defined on your server.
	playlists=list(
		"lobby" = "Lobby Mix"
	)
	playlist_id = "lobby"
	use_power = NO_POWER_USE
	invisibility=101
	autoplay = 1

/obj/machinery/media/speaker
	name = "Speaker"
	desc = "Stay tuned!"

	icon = 'icons/obj/jukebox.dmi'

	density = TRUE
	anchored = FALSE

	playing = 0
	var/on=FALSE
	var/media_frequency = 1984

/obj/machinery/media/speaker/atom_init()
	update_icon()

/obj/machinery/media/speaker/ui_interact(mob/user)
	var/dat = "<TT>"
	dat += {"
				Power: <a href="?src=\ref[src];power=1">[on ? "On" : "Off"]</a><BR>
				Frequency: <A href='byond://?src=\ref[src];set_freq=-1'>[format_frequency(media_frequency)]</a><BR>
				"}
	dat+={"</TT>"}

	var/datum/browser/popup = new(user, "radio-recv", "[src]")
	popup.set_content(dat)
	popup.open()

/obj/machinery/media/speaker/Topic(href,href_list)
	if("power" in href_list)
		if(!anchored)
			return FALSE
		if(on)
			visible_message("\The [src] falls quiet.")
			playing=0
			disconnect_frequency()
		else
			visible_message("\The [src] hisses to life!")
			playing=1
			connect_frequency()
		on = !on
		update_icon()
	if("set_freq" in href_list)
		var/newfreq=media_frequency
		if(href_list["set_freq"]!="-1")
			newfreq = text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Set a new frequency (MHz, 90.0, 200.0).", src, media_frequency) as null|num
		if(newfreq)
			if(!IS_INTEGER(newfreq))
				newfreq *= 10 // shift the decimal one place
			if(newfreq > 900 && newfreq < 2000) // Between (90.0 and 100.0)
				disconnect_frequency()
				media_frequency = newfreq
				connect_frequency()
			else
				to_chat(usr, "<span class='warning'>Invalid FM frequency. (90.0, 200.0)</span>")
	updateDialog()

/obj/machinery/media/speaker/proc/connect_frequency()
	var/list/receivers=list()
	var/freq = num2text(media_frequency)
	if(freq in media_receivers)
		receivers = media_receivers[freq]
	receivers.Add(src)
	media_receivers[freq]=receivers

/obj/machinery/media/speaker/proc/disconnect_frequency()
	var/list/receivers=list()
	var/freq = num2text(media_frequency)
	if(freq in media_receivers)
		receivers = media_receivers[freq]
	receivers.Remove(src)
	media_receivers[freq]=receivers
	receive_broadcast()

/obj/machinery/media/speaker/proc/receive_broadcast(url="", start_time=0)
	media_url = url
	media_start_time = start_time
	update_music()

/obj/machinery/media/speaker/attackby(obj/item/W, mob/user, params)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(iswrench(W))
		if(user.is_busy(src))
			return
		var/un = !anchored ? "" : "un"
		user.visible_message("<span class='notice'>[user.name] begins [un]locking \the [src.name]'s casters.</span>","<span class='notice'>You begin [un]locking \the [src.name]'s casters.</span>")
		if(W.use_tool(src, user, 30, volume = 50))
			on = FALSE
			anchored = !anchored
			user.visible_message("<span class='notice'>[user.name] [un]locks \the [src.name]'s casters.</span>","<span class='warning'>You [un]lock \the [src.name]'s casters.</span>")
			update_icon()
			if(!anchored)
				playing = 0
				disconnect_frequency()
				disconnect_media_source()

/obj/machinery/media/speaker/update_icon()
	if(!anchored)
		icon_state = "speaker_idle"
	else if(on)
		icon_state = "speaker_playing"
	else
		icon_state = "speaker_anchored"
