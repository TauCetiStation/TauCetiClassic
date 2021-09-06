var/list/escape_area_transit = typecacheof(list(/area/shuttle/escape/transit,
                                                /area/shuttle/escape_pod1/transit,
                                                /area/shuttle/escape_pod2/transit,
                                                /area/shuttle/escape_pod3/transit,
                                                /area/shuttle/escape_pod4/transit))

#define IS_ON_ESCAPE_SHUTTLE is_type_in_typecache(get_area(M), escape_area_transit)
#define ANNOUNCE_TEXT  (1<<0)
#define ANNOUNCE_SOUND (1<<1)
#define ANNOUNCE_COMMS (1<<2)
#define ANNOUNCE_ALL (~0)

/* Announcement sounds */
var/list/announcement_sounds = list(
	"commandreport" = 'sound/AI/commandreport.ogg',
	"announce" = 'sound/AI/announce.ogg',
	"aiannounce" = 'sound/AI/aiannounce.ogg',

	"yesert" = 'sound/AI/yesert.ogg',
	"noert" = 'sound/AI/noert.ogg',
	"nuke" = 'sound/AI/nuke.ogg',
	"radiation" = list('sound/AI/radiation1.ogg', 'sound/AI/radiation2.ogg', 'sound/AI/radiation3.ogg'),
	"radpassed" = 'sound/AI/radpassed.ogg',
	"meteors" = list('sound/AI/meteors1.ogg', 'sound/AI/meteors2.ogg'),
	"meteorcleared" = 'sound/AI/meteorcleared.ogg',
	"gravanom" = 'sound/AI/gravanomalies.ogg',
	"fluxanom" = 'sound/AI/flux.ogg',
	"vortexanom" = 'sound/AI/vortex.ogg',
	"bluspaceanom" = 'sound/AI/blusp_anomalies.ogg',
	"bluspacetrans" = 'sound/AI/mas-blu-spa_anomalies.ogg',
	"pyroanom" = 'sound/AI/pyr_anomalies.ogg',
	"wormholes" = 'sound/AI/wormholes.ogg',
	"outbreak7" = 'sound/AI/outbreak7.ogg',
	"outbreak5" = list('sound/AI/outbreak5_1.ogg', 'sound/AI/outbreak5_2.ogg'),
	"lifesigns" = list('sound/AI/lifesigns1.ogg', 'sound/AI/lifesigns2.ogg', 'sound/AI/lifesigns3.ogg'),
	"greytide" = 'sound/AI/greytide.ogg',
	"rampbrand" = 'sound/AI/rampant_brand_int.ogg',
	"carps" = 'sound/AI/carps.ogg',
	"estorm" = 'sound/AI/e-storm.ogg',
	"istorm" = 'sound/AI/i-storm.ogg',
	"poweroff" = list('sound/AI/poweroff1.ogg', 'sound/AI/poweroff2.ogg'),
	"poweron" = 'sound/AI/poweron.ogg',
	"gravoff" = 'sound/AI/gravityoff.ogg',
	"gravon" = 'sound/AI/gravityon.ogg',
	"artillery" = 'sound/AI/artillery.ogg',
	"icaruslost" = 'sound/AI/icarus.ogg',
	"fungi" = 'sound/AI/fungi.ogg',
	"animes" = 'sound/AI/animes.ogg',
	"horror" = 'sound/AI/_admin_horror_music.ogg',

	"emer_shut_called" = 'sound/AI/emergency_s_called.ogg',
	"emer_shut_recalled" = 'sound/AI/emergency_s_recalled.ogg',
	"emer_shut_docked" = 'sound/AI/emergency_s_docked.ogg',
	"emer_shut_left" = 'sound/AI/emergency_s_left.ogg',
	"crew_shut_called" = 'sound/AI/crew_s_called.ogg',
	"crew_shut_recalled" = 'sound/AI/crew_s_recalled.ogg',
	"crew_shut_docked" = 'sound/AI/crew_s_docked.ogg',
	"crew_shut_left" = 'sound/AI/crew_s_left.ogg',

	"downtogreen" = 'sound/AI/downtogreen.ogg',
	"blue" = 'sound/AI/blue.ogg',
	"downtoblue" = 'sound/AI/downtoblue.ogg',
	"red" = 'sound/AI/red.ogg',
	"downtored" = 'sound/AI/downtored.ogg',
	"delta" = 'sound/AI/delta.ogg',

	"malf" = 'sound/AI/aimalf.ogg',
	"malf1" = 'sound/AI/ai_malf_1.ogg',
	"malf2" = 'sound/AI/ai_malf_2.ogg',
	"malf3" = 'sound/AI/ai_malf_3.ogg',
	"malf4" = 'sound/AI/ai_malf_4.ogg',
)

/* General announcement */
/datum/announcement
	var/name
	var/title
	var/subtitle
	var/message
	var/announcer
	var/sound

	var/always_random = FALSE
	var/custom = FALSE
	var/volume = 100
	var/flags

/datum/announcement/New()
	randomize()

/datum/announcement/proc/copy(announce_type)
	var/datum/announcement/A = new announce_type

	name = A.name
	title = A.title
	subtitle = A.subtitle
	message = A.message
	announcer = A.announcer
	sound = A.sound

	volume = A.volume
	flags = A.flags

/datum/announcement/proc/randomize()
	return

/datum/announcement/proc/play()
	var/_title = title
	var/_subtitle = subtitle
	var/_message_annou = message
	var/_message_paper = message
	var/_announcer = announcer
	var/announce_text
	var/announce_sound

	if(always_random)
		randomize()

	// Sanitizing only there, because it will break everything not here
	if(custom)
		_title = sanitize_safe(title)
		_subtitle = sanitize_safe(subtitle)
		_message_annou = sanitize_safe(message, extra = FALSE)
		_message_paper = sanitize(message, MAX_PAPER_MESSAGE_LEN, extra = FALSE)
		_announcer = sanitize_safe(announcer)

	if(flags & ANNOUNCE_TEXT)
		if(_title)
			announce_text += "<h1>[_title]</h1>"
		if(_subtitle)
			announce_text += "<h2>[_subtitle]</h2>"
		if(_message_annou)
			announce_text += "<p class='alert'>[_message_annou]</p>"
		if(_announcer)
			announce_text += "<p class='alert'> -[_announcer]</p>"

	if(flags & ANNOUNCE_SOUND)
		if(sound)
			var/variants = announcement_sounds + announcement_sounds_cache
			if(sound in variants)
				announce_sound = variants[sound]
				if(islist(announce_sound))
					announce_sound = pick(announce_sound)
			else
				WARNING("No sound file for [sound]")

	for(var/mob/M in player_list)
		if(!isnewplayer(M))
			if(announce_text)
				to_chat(M, announce_text + "<br>")

			if(announce_sound)
				if((sound == "emer_shut_left" || sound == "crew_shut_left") && IS_ON_ESCAPE_SHUTTLE)
					continue

				M.playsound_local(null, announce_sound, VOL_EFFECTS_VOICE_ANNOUNCEMENT, volume, FALSE, null, channel = CHANNEL_ANNOUNCE, wait = TRUE)

	if(flags & ANNOUNCE_COMMS)
		for (var/obj/machinery/computer/communications/C in communications_list)
			if(!(C.stat & (BROKEN | NOPOWER)))
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(C.loc)
				if(_title && _subtitle)
					P.name = "[_title] - [_subtitle]"
				else if(_title)
					P.name = "[_title]"
				else if(_subtitle)
					P.name = "[_subtitle]"
				else
					P.name = "Report"
				P.info = replacetext(_message_paper, "\n", "<br/>")
				P.update_icon()
				C.messagetitle.Add("[P.name]")
				C.messagetext.Add(P.info)


/datum/announcement/ping
	sound = "commandreport"
	flags = ANNOUNCE_SOUND
/datum/announcement/ping/play(sound)
	if(sound)
		src.sound = sound
	..()

/var/datum/announcement/announcement_ping = new /datum/announcement/ping // For sound-only
