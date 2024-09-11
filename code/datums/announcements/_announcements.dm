var/global/list/escape_area_transit = typecacheof(list(/area/shuttle/escape/transit,
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
var/global/list/announcement_sounds = list(
	"admin_capitain_tishina" = 'sound/AI/_admin_capitain.ogg',
	"admin_hos_gone" = 'sound/AI/_admin_hos_gone.ogg',
	"admin_cap_gone" = 'sound/AI/_admin_cap_gone.ogg',
	"admin_war_pipisky" = 'sound/AI/_admin_war_pipisky.ogg',
	"admin_war_pizdec" = 'sound/AI/_admin_war_pizdec.ogg',
	"admin_war_tishina" = 'sound/AI/_admin_war_tishina.ogg',
	
	"commandreport" = 'sound/AI/commandreport.ogg',
	"announce" = 'sound/AI/announce.ogg',
	"aiannounce" = 'sound/AI/aiannounce.ogg',
	"portal" = 'sound/AI/portal.ogg',

	"yesert" = 'sound/AI/yesert.ogg',
	"noert" = 'sound/AI/noert.ogg',
	"nuke1" = 'sound/AI/nuke1.ogg',
	"nuke2" = 'sound/AI/nuke2.ogg',
	"radiation" = 'sound/AI/radiation.ogg',
	"radpassed" = 'sound/AI/radpassed.ogg',
	"meteors" = 'sound/AI/meteors.ogg',
	"meteorcleared" = 'sound/AI/meteorcleared.ogg',
	"gravanom" = 'sound/AI/gravanomalies.ogg',
	"fluxanom" = 'sound/AI/flux.ogg',
	"vortexanom" = 'sound/AI/vortex.ogg',
	"bluspaceanom" = 'sound/AI/blusp_anomalies.ogg',
	"bluspacetrans" = 'sound/AI/mas-blu-spa_anomalies.ogg',
	"pyroanom" = 'sound/AI/pyr_anomalies.ogg',
	"wormholes" = 'sound/AI/wormholes.ogg',
	"outbreak7" = 'sound/AI/outbreak7.ogg',
	"outbreak5" = 'sound/AI/outbreak5.ogg',
	"lifesigns" = 'sound/AI/lifesigns.ogg',
	"greytide" = 'sound/AI/greytide.ogg',
	"rampbrand" = 'sound/AI/rampant_brand_int.ogg',
	"carps" = 'sound/AI/carps.ogg',
	"estorm" = 'sound/AI/e-storm.ogg',
	"istorm" = list('sound/AI/i-storm1.ogg', 'sound/AI/i-storm2.ogg', 'sound/AI/i-storm3.ogg'),
	"poweroff" = list('sound/AI/poweroff1.ogg', 'sound/AI/poweroff2.ogg'),
	"poweron1" = 'sound/AI/poweron1.ogg',
	"poweron2" = 'sound/AI/poweron2.ogg',
	"gravoff" = 'sound/AI/gravityoff.ogg',
	"gravon" = 'sound/AI/gravityon.ogg',
	"artillery" = 'sound/AI/artillery.ogg',
	"icaruslost" = 'sound/AI/icarus.ogg',
	"fungi" = 'sound/AI/fungi.ogg',
	"animes" = 'sound/AI/animes.ogg',
	"horror" = 'sound/AI/_admin_horror_music.ogg',
	"frost" = 'sound/AI/frost.ogg',
	"access_override" = 'sound/AI/access_override.ogg',
	"carp_major" = 'sound/AI/carp_major.ogg',
	"comms_blackout" = 'sound/AI/comms_blackout.ogg',
	"dust" = 'sound/AI/dust.ogg',
	"dust_passed" = 'sound/AI/dust_passed.ogg',
	"irod" = 'sound/AI/irod.ogg',
	"infestation" = 'sound/AI/infestation.ogg',
	"gateway" = 'sound/AI/gateway.ogg',
	"department" = 'sound/AI/department.ogg',

	"maint_revoke" = 'sound/AI/maint_revoke.ogg',
	"maint_readd" = 'sound/AI/maint_readd.ogg',

	"blob_dead" = 'sound/AI/blob_dead.ogg',
	"blob_critical" = 'sound/AI/blob_critical.ogg',

	"vox_arrival" = 'sound/AI/vox_arrival.ogg',
	"vox_returns" = 'sound/AI/vox_returns.ogg',

	"gang_announce" = 'sound/AI/gang_announce.ogg',

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

	"xeno_first_help" = 'sound/AI/xeno_first_help.ogg',
	"xeno_first_help_fail" = 'sound/AI/xeno_first_help_fail.ogg',
	"xeno_second_help" = 'sound/AI/xeno_second_help.ogg',
	"xeno_second_help_fail" = 'sound/AI/xeno_second_help_fail.ogg',
	"xeno_crew_win" = 'sound/AI/xeno_crew_win.ogg',

	"hos" = 'sound/AI/hos.ogg',
	"cmo" = 'sound/AI/cmo.ogg',
	"hop" = 'sound/AI/hop.ogg',
	"rd" = 'sound/AI/rd.ogg',
	"se" = 'sound/AI/se.ogg',
	"kep" = 'sound/AI/kep.ogg',

	"construction_began" = 'sound/AI/construction_began.ogg',
	"construction_quarter" = 'sound/AI/construction_quarter.ogg',
	"construction_half" = 'sound/AI/construction_half.ogg',
	"construction_three_quarters" = 'sound/AI/construction_three_quarters.ogg',
	"construction_doom" = 'sound/AI/construction_doom.ogg',

	"bell" = 'sound/effects/bell.ogg',
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
	var/volume = 100
	var/flags

	var/datum/faction/faction_filter

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
	var/announce_text
	var/announce_sound

	if(always_random)
		randomize()

	if(flags & ANNOUNCE_TEXT)
		if(title)
			announce_text += "<div><h1>[title]</h1></div>"
		if(subtitle)
			announce_text += "<div><h2>[subtitle]</h2></div>"
		if(message)
			announce_text += "<p class='alert'>[message]</p>"
		if(announcer)
			announce_text += "<p class='alert'> -[announcer]</p>"

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
		if(isnewplayer(M))
			continue

		if(faction_filter && !isobserver(M))
			if(!M?.mind.IsPartOfFaction(faction_filter))
				continue

		if(announce_text)
			to_chat(M, announce_text)

		if(announce_sound)
			if((sound == "emer_shut_left" || sound == "crew_shut_left") && IS_ON_ESCAPE_SHUTTLE)
				continue

			M.playsound_local(null, announce_sound, VOL_EFFECTS_VOICE_ANNOUNCEMENT, volume, FALSE, null, channel = CHANNEL_ANNOUNCE, wait = TRUE)

	if(faction_filter) // antag announce, don't print it in machinery
		return

	if(flags & ANNOUNCE_COMMS)
		for (var/obj/machinery/computer/communications/C in communications_list)
			if(!(C.stat & (BROKEN | NOPOWER)))
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(C.loc)
				if(title && subtitle)
					P.name = "[title] - [subtitle]"
				else if(title)
					P.name = "[title]"
				else if(subtitle)
					P.name = "[subtitle]"
				else
					P.name = "Report"
				P.info = replacetext(message, "\n", "<br/>")
				P.update_icon()
				C.messagetitle.Add("[P.name]")
				C.messagetext.Add(P.info)

	if(announce_text)
		for(var/datum/feed_channel/FC in news_network.network_channels)
			if(FC.channel_name == "Station Announcements")
				var/datum/feed_message/newMsg = new /datum/feed_message
				var/datum/comment_pages/CP = new /datum/comment_pages
				newMsg.pages += CP
				newMsg.author = station_name()
				newMsg.body = announce_text
				FC.messages += newMsg
				break

/datum/announcement/ping
	sound = "commandreport"
	flags = ANNOUNCE_SOUND
/datum/announcement/ping/play(sound)
	if(sound)
		src.sound = sound
	..()

/var/datum/announcement/announcement_ping = new /datum/announcement/ping // For sound-only
