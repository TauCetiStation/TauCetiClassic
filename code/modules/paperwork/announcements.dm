var/list/escape_area_transit = typecacheof(list(/area/shuttle/escape/transit,
                                                /area/shuttle/escape_pod1/transit,
                                                /area/shuttle/escape_pod2/transit,
                                                /area/shuttle/escape_pod3/transit,
                                                /area/shuttle/escape_pod4/transit))

#define IS_ON_ESCAPE_SHUTTLE is_type_in_typecache(get_area(M), escape_area_transit)

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

	var/volume = 100
	var/flags

/datum/announcement/proc/copy(datum/announcement/A)
	if(!istype(A))
		return
	
	name = A.name
	title = A.title
	subtitle = A.subtitle
	message = A.message
	announcer = A.announcer
	sound = A.sound

	volume = A.volume
	flags = A.flags

/datum/announcement/proc/play()
	var/announce_text
	var/announce_sound

	if(flags & ANNOUNCE_TEXT)
		if(title)
			announce_text += "<h1 class='alert'>[title]</h1><br>"
		if(subtitle)
			announce_text += "<h2 class='alert'>[subtitle]</h2><br>"
		if(message)
			announce_text += "<span class='alert'>[message]</span><br>"
		if(announcer)
			announce_text += "<span class='alert'> -[announcer]</span><br>"

	if(flags & ANNOUNCE_SOUND)
		if(sound)
			if(sound in announcement_sounds)
				announce_sound = announcement_sounds[sound]
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

				M.playsound_local(null, announce_sound, VOL_EFFECTS_VOICE_ANNOUNCEMENT, volume, FALSE, channel = CHANNEL_ANNOUNCE, wait = TRUE)

	if(flags & ANNOUNCE_COMMS)
		for (var/obj/machinery/computer/communications/C in communications_list)
			if(!(C.stat & (BROKEN | NOPOWER)))
				var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
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
				C.messagetitle.Add("[subtitle]")
				C.messagetext.Add(P.info)

/datum/announcement/ping
	sound = "commandreport"
	flags = ANNOUNCE_SOUND
/datum/announcement/ping/play(sound)
	if(sound)
		src.sound = sound
	..()
/var/datum/announcement/announcement_ping = new /datum/announcement/ping // For sound-only

/* Centcomm announcements */
/datum/announcement/centcomm
	title = "Central Command Update"
	subtitle = "NanoTrasen Update"
	sound = "commandreport"
	flags = ANNOUNCE_TEXT | ANNOUNCE_SOUND

/datum/announcement/centcomm/play()
	..()
	add_communication_log(type = "centcomm", title = title, content = message)

/datum/announcement/centcomm/anomaly
	subtitle = "Anomaly Alert"

/datum/announcement/centcomm/malf
	subtitle = "Network Monitoring"

/* Onboard announcements */
/datum/announcement/station
	title = "Priority Announcement"
	sound = "announce"
	flags = ANNOUNCE_TEXT | ANNOUNCE_SOUND

/datum/announcement/station/play()
	..()
	add_communication_log(type = "station", title = title ? title : subtitle, author = announcer, content = message)

/datum/announcement/station/command/play(message)
	if(message)
		src.message = message
	..()

/datum/announcement/station/gang
	subtitle = "Station Firewall"

/datum/announcement/station/code
	title = null

/* Base announcements not to list */
/var/list/base_announcement_types = list(
	/datum/announcement,
	/datum/announcement/ping,
	/datum/announcement/centcomm,
	/datum/announcement/centcomm/anomaly,
	/datum/announcement/station,
	/datum/announcement/station/command,
	/datum/announcement/station/code,
	/datum/announcement/centcomm/blob,
	/datum/announcement/centcomm/epidemic,
	/datum/announcement/centcomm/mutiny,
	/datum/announcement/centcomm/nuclear,
	/datum/announcement/centcomm/vox,
	/datum/announcement/centcomm/malf,
	/datum/announcement/station/gang,
)

/* Predefined announcements */
/* CENTRAL COMMAND */
/datum/announcement/centcomm/admin
	name = "Centcomm: Admin Stub"
	message = "\[Enter your message for the station here.]"
	flags = ANNOUNCE_ALL

/datum/announcement/centcomm/yesert
	name = "Centcomm: ERT Approved"
	subtitle = "Central Command"
	message = "It would appear that an emergency response team was requested for Space Station 13. We will prepare and send one as soon as possible."
	sound = "yesert"
/datum/announcement/centcomm/yesert/play()
	message = "It would appear that an emergency response team was requested for [station_name()]. We will prepare and send one as soon as possible."
	..()

/datum/announcement/centcomm/noert
	name = "Centcomm: ERT Denied"
	subtitle = "Central Command"
	message = "It would appear that an emergency response team was requested for Space Station 13. Unfortunately, we were unable to send one at this time."
	sound = "yesert"
/datum/announcement/centcomm/noert/play()
	message = "It would appear that an emergency response team was requested for [station_name()]. Unfortunately, we were unable to send one at this time."
	..()

/* Events */
/datum/announcement/centcomm/anomaly/frost
	name = "Anomaly: Frost"
	message = "Atmospheric anomaly detected on long range scanners. Prepare for station temperature drop."

/datum/announcement/centcomm/access_override
	name = "Secret: Egalitarian"
	message = "Centcomm airlock control override activated. Please take this time to get acquainted with your coworkers."

/datum/announcement/centcomm/anomaly/radstorm
	name = "Anomaly: Radiation Belt"
	message = "High levels of radiation detected near the station. Please report to the Med-bay if you feel strange. " + \
			"The entire crew of the station is recommended to find shelter in the technical tunnels of the station. "
	sound = "radiation"

/datum/announcement/centcomm/anomaly/radstorm_passed
	name = "Anomaly: Radiation Belt Passed"
	message = "The station has passed the radiation belt. " + \
			"Please report to medbay if you experience any unusual symptoms. Maintenance will lose all access again shortly."
	sound = "radpassed"

/datum/announcement/centcomm/anomaly/istorm
	name = "Anomaly: Ion Storm"
	message = "Ion storm detected near the station. Please check all AI-controlled equipment for errors."
	sound = "istorm"

/datum/announcement/centcomm/bsa
	name = "Secret: BSA Shot"
	message = "Bluespace artillery fire detected. Brace for impact."
	sound = "artillery"
/datum/announcement/centcomm/bsa/play(area/A)
	if(A)
		message = "Bluespace artillery fire detected in [A.name]. Brace for impact."
	..()

/datum/announcement/centcomm/aliens
	name = "Event: Infestation"
	subtitle = "Lifesign Alert"
	message = "Unidentified lifesigns detected coming aboard Space Station 13. Secure any exterior access, including ducting and ventilation."
	sound = "lifesigns"
/datum/announcement/centcomm/aliens/play()
	message = "Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation."
	..()

/datum/announcement/centcomm/fungi
	name = "Event: Fungi"
	subtitle = "Biohazard Alert"
	message = "Harmful fungi detected on station. Station structures may be contaminated."
	sound = "fungi"

/datum/announcement/centcomm/wormholes
	name = "Event: Wormholes"
	subtitle = "Anomaly Alert"
	message = "Space-time anomalies detected on the station. It is recommended to avoid suspicious things or phenomena. There is no additional data."
	sound = "wormholes"

/datum/announcement/centcomm/anomaly/bluespace
	name = "Anomaly: Bluespace"
	message = "Unstable bluespace anomaly detected on long range scanners. Expected location: unknown."
	sound = "bluspaceanom"
/datum/announcement/centcomm/anomaly/bluespace/play(area/A)
	if(A)
		message = "Unstable bluespace anomaly detected on long range scanners. Expected location: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/bluespace_trigger
	name = "Anomaly: Bluespace Triggered"
	message = "Massive bluespace translocation detected."
	sound = "bluspacetrans"

/datum/announcement/centcomm/anomaly/flux
	name = "Anomaly: Flux Wave"
	message = "Localized hyper-energetic flux wave detected on long range scanners. Expected location: unknown."
	sound = "fluxanom"
/datum/announcement/centcomm/anomaly/flux/play(area/A)
	if(A)
		message = "Localized hyper-energetic flux wave detected on long range scanners. Expected location: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/gravity
	name = "Anomaly: Gravitational"
	message = "Gravitational anomaly detected on long range scanners. Expected location: unknown."
	sound = "gravanom"
/datum/announcement/centcomm/anomaly/gravity/play(area/A)
	if(A)
		message = "Gravitational anomaly detected on long range scanners. Expected location: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/pyro
	name = "Anomaly: Pyroclastic"
	message = "Pyroclastic anomaly detected on long range scanners. Expected location: unknown."
	sound = "pyroanom"
/datum/announcement/centcomm/anomaly/pyro/play(area/A)
	if(A)
		message = "Pyroclastic anomaly detected on long range scanners. Expected location: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/vortex
	name = "Anomaly: Vortex"
	message = "Localized high-intensity vortex anomaly detected on long range scanners. Expected location: unknown."
	sound = "vortexanom"
/datum/announcement/centcomm/anomaly/vortex/play(area/A)
	if(A)
		message = "Localized high-intensity vortex anomaly detected on long range scanners. Expected location: [A.name]."
	..()

/datum/announcement/centcomm/brand
	name = "Event: Brand Intelligence"
	subtitle = "Machine Learning Alert"
	message = "Rampant brand intelligence has been detected aboard Space Station 13, please stand-by."
	sound = "rampbrand"
/datum/announcement/centcomm/brand/play()
	message = "Rampant brand intelligence has been detected aboard [station_name()], please stand-by."
	..()

/datum/announcement/centcomm/carp
	name = "Event: Carp Migration"
	subtitle = "Lifesign Alert"
	message = "Unknown biological entities have been detected near Space Station 13, please stand-by."
	sound = "carps"
/datum/announcement/centcomm/carp/play()
	message = "Unknown biological entities have been detected near [station_name()], please stand-by."
	..()

/datum/announcement/centcomm/carp_major
	name = "Event: Major Carp Migration"
	subtitle = "Lifesign Alert"
	message = "Massive migration of unknown biological entities has been detected near Space Station 13, please stand-by."
	sound = "carps"
/datum/announcement/centcomm/carp_major/play()
	message = "Massive migration of unknown biological entities has been detected near [station_name()], please stand-by."
	..()

/datum/announcement/centcomm/comms_blackout
	name = "Event: Communication Blackout"
	message = "Ionospheri:%ďż˝ MCayj^j<.3-BZZZZZZT"
/datum/announcement/centcomm/comms_blackout/play(message)
	if(message)
		src.message = message
	..()

/datum/announcement/centcomm/dust
	name = "Event: Sand Storm"
	subtitle = "Station Sensor Array"
	message = "The Space Station 13 is now passing through a belt of space dust."
/datum/announcement/centcomm/dust/play()
	subtitle = "[station_name()] Sensor Array"
	message = "The [station_name()] is now passing through a belt of space dust."
	..()

/datum/announcement/centcomm/dust_passed
	name = "Event: Sand Storm Passed"
	subtitle = "Station Sensor Array"
	message = "The Space Station 13 has now passed through the belt of space dust."
/datum/announcement/centcomm/dust_passed/play()
	subtitle = "[station_name()] Sensor Array"
	message = "The [station_name()] has now passed through the belt of space dust."
	..()

/datum/announcement/centcomm/estorm
	name = "Event: Electrical Storm"
	subtitle = "Electrical Storm Alert"
	message = "An electrical storm has been detected in your area, please repair potential electronic overloads."
	sound = "estorm"

/datum/announcement/centcomm/grid_off
	name = "Event: Power Failure"
	subtitle = "Critical Power Failure"
	message = "Abnormal activity detected in Space Station 13 powernet. As a precautionary measure, " + \
			"the station's power will be shut off for an indeterminate duration."
	sound = "poweroff"
/datum/announcement/centcomm/grid_off/play()
	message = "Abnormal activity detected in [station_name()] powernet. As a precautionary measure, " + \
			"the station's power will be shut off for an indeterminate duration."
	..()

/datum/announcement/centcomm/grid_on
	name = "Event: Power Restored"
	subtitle = "Power Systems Nominal"
	message = "Power has been restored to Space Station 13. We apologize for the inconvenience."
	sound = "poweron"
/datum/announcement/centcomm/grid_on/play()
	message = "Power has been restored to [station_name()]. We apologize for the inconvenience."
	..()

/datum/announcement/centcomm/grid_quick
	name = "Secret: SMES Restored"
	subtitle = "Power Systems Nominal"
	message = "All SMESs on Space Station 13 have been recharged. We apologize for the inconvenience."
	sound = "poweron"
/datum/announcement/centcomm/grid_quick/play()
	message = "All SMESs on [station_name()] have been recharged. We apologize for the inconvenience."
	..()

/datum/announcement/centcomm/irod
	name = "Event: Immovable Rod"
	subtitle = "General Alert"
	message = "What the fuck was that?!"

/datum/announcement/centcomm/infestation
	name = "Event: Vermin infestation"
	subtitle = "Vermin infestation"
	message = "Bioscans indicate that something have been breeding somewhere on the station. Clear them out, before this starts to affect productivity."
/datum/announcement/centcomm/infestation/play(vermstring, locstring)
	if(vermstring && locstring)
		message = "Bioscans indicate that [vermstring] have been breeding in [locstring]. Clear them out, before this starts to affect productivity."
	..()

/datum/announcement/centcomm/meteor_wave
	name = "Event: Meteor Wave"
	subtitle = "Meteor Alert"
	message = "Meteors have been detected on collision course with the station. The energy field generator is disabled or missing."
	sound = "meteors"

/datum/announcement/centcomm/meteor_wave_passed
	name = "Event: Meteor Wave Cleared"
	subtitle = "Meteor Alert"
	message = "The station has cleared the meteor storm."
	sound = "meteorcleared"

/datum/announcement/centcomm/meteor_shower
	name = "Event: Meteor Shower"
	subtitle = "Meteor Alert"
	message = "The station is now in a meteor shower. The energy field generator is disabled or missing."
	sound = "meteors"

/datum/announcement/centcomm/meteor_shower_passed
	name = "Event: Meteor Shower Cleared"
	subtitle = "Meteor Alert"
	message = "The station has cleared the meteor shower"
	sound = "meteorcleared"

/datum/announcement/centcomm/organ_failure
	name = "Event: Organ Failure"
	subtitle = "Biohazard Alert"
	message = "Confirmed outbreak of level 7 biohazard aboard Space Station 13. All personnel must contain the outbreak."
	sound = "outbreak7"
/datum/announcement/centcomm/organ_failure/play()
	message = "Confirmed outbreak of level 7 biohazard aboard [station_name()]. All personnel must contain the outbreak."

/datum/announcement/centcomm/greytide
	name = "Event: Grey Tide"
	subtitle = "Security Alert"
	message = "Malignant trojan detected in Space Station 13 imprisonment subroutines. Recommend station AI involvement."
	sound = "greytide"
/datum/announcement/centcomm/greytide/play()
	message = "[pick("Gr3y.T1d3-type virus","Malignant trojan")] detected in [station_name()] imprisonment subroutines. Recommend station AI involvement."

/datum/announcement/centcomm/icarus_lost
	name = "Event: Icarus Lost"
	subtitle = "Rogue drone alert"
	message = "Contact has been lost with a combat drone wing operating out of the NMV Icarus. If any are sighted in the area, approach with caution."
	sound = "icaruslost"
/datum/announcement/centcomm/icarus_lost/play(message)
	if(message)
		src.message = message
	..()

/datum/announcement/centcomm/icarus_recovered
	name = "Event: Icarus Recovered"
	subtitle = "Rogue drone alert"
	message = "Icarus drone control reports the malfunctioning wing has been recovered safely."
/datum/announcement/centcomm/icarus_recovered/play(message)
	if(message)
		src.message = message
	..()

/* STATION */
/* Command */
/datum/announcement/station/command/department
	name = "Heads: Department"
/datum/announcement/station/command/department/play(department, message)
	if(department && message)
		title = "[department] Announcement"
	..(message)

/datum/announcement/station/command/ai
	name = "Heads: AI"
	title = "A.I. Announcement"
	sound = "aiannounce"
/datum/announcement/station/command/ai/play(mob/user, message)
	if(user && message)
		announcer = user.name
	..(message)

/* Alerts */
/datum/announcement/station/nuke
	name = "Alert: Nuke Activation"
	message = "Detected activation of a nuclear warhead somewhere on the station. Someone trying to blow up the station!"
	sound = "nuke"
/datum/announcement/station/nuke/play(area/A)
	if(A)
		message = "Detected activation of a nuclear warhead in [initial(A.name)]. Someone trying to blow up the station!"
	..()

/datum/announcement/station/maint_revoke
	name = "Alert: Maintenance Access Revoked"
	message = "The maintenance access requirement has been revoked on all airlocks."

/datum/announcement/station/maint_readd
	name = "Alert: Maintenance Access Readded"
	message = "The maintenance access requirement has been readded on all airlocks."

/datum/announcement/station/gravity_on
	name = "Secret: Gravity On"
	subtitle = "Station Fail-Safe System"
	message = "Gravity generators are again functioning within normal parameters. Sorry for any inconvenience."
	sound = "gravon"
/datum/announcement/station/gravity_on/play()
	subtitle = "[station_name()] Fail-Safe System"
	..()

/datum/announcement/station/gravity_off
	name = "Secret: Gravity Off"
	subtitle = "Station Fail-Safe System"
	message = "Feedback surge detected in mass-distributions systems. Artifical gravity has been disabled whilst the system reinitializes. " + \
			"Further failures may result in a gravitational collapse and formation of blackholes. Have a nice day."
	sound = "gravoff"
/datum/announcement/station/gravity_off/play()
	subtitle = "[station_name()] Fail-Safe System"
	..()

/* Shuttles */
/datum/announcement/station/shuttle/crew_called
	name = "Shuttle: Crew Called"
	message = "A crew transfer has been initiated. The shuttle has been called. It will arrive in a few minutes."
	sound = "crew_shut_called"
/datum/announcement/station/shuttle/crew_called/play()
	message = "A crew transfer has been initiated. The shuttle has been called. It will arrive in [shuttleminutes2text()] minutes."
	..()

/datum/announcement/station/shuttle/crew_recalled
	name = "Shuttle: Crew Recalled"
	message = "The shuttle has been recalled."
	sound = "crew_shut_recalled"

/datum/announcement/station/shuttle/crew_docked
	name = "Shuttle: Crew Docked"
	message = "The scheduled Crew Transfer Shuttle has docked with the station. It will depart in a few minutes."
	sound = "crew_shut_docked"
/datum/announcement/station/shuttle/crew_docked/play()
	message = "The scheduled Crew Transfer Shuttle has docked with the station. It will depart in approximately [shuttleminutes2text()] minutes."
	..()

/datum/announcement/station/shuttle/crew_left
	name = "Shuttle: Crew Left"
	message = "The Crew Transfer Shuttle has left the station. It will dock at Central Command in a few minutes."
	sound = "crew_shut_left"
/datum/announcement/station/shuttle/crew_left/play()
	message = "The Crew Transfer Shuttle has left the station. Estimate [shuttleminutes2text()] minutes until the shuttle docks at Central Command."
	..()


/datum/announcement/station/shuttle/emer_called
	name = "Shuttle: Emergency Called"
	message = "The emergency shuttle has been called. It will arrive as soon as possible."
	sound = "emer_shut_called"
/datum/announcement/station/shuttle/emer_called/play()
	message = "The emergency shuttle has been called. It will arrive in [shuttleminutes2text()] minutes."
	..()

/datum/announcement/station/shuttle/emer_recalled
	name = "Shuttle: Emergency Recalled"
	message = "The emergency shuttle has been recalled."
	sound = "emer_shut_recalled"

/datum/announcement/station/shuttle/emer_docked
	name = "Shuttle: Emergency Docked"
	message = "The Emergency Shuttle has docked with the station. You have a few minutes to board the Emergency Shuttle."
	sound = "emer_shut_docked"
/datum/announcement/station/shuttle/emer_docked/play()
	message = "The Emergency Shuttle has docked with the station. You have [shuttleminutes2text()] minutes to board the Emergency Shuttle."
	..()

/datum/announcement/station/shuttle/emer_left
	name = "Shuttle: Emergency Left"
	message = "The Emergency Shuttle has left the station. It will dock at Central Command in a few minutes."
	sound = "emer_shut_left"
/datum/announcement/station/shuttle/emer_left/play()
	message = "The Emergency Shuttle has left the station. Estimate [shuttleminutes2text()] minutes until the shuttle docks at Central Command."
	..()

/* Security codes */
/datum/announcement/station/code/downtogreen
	name = "Code: Down to Green"
	subtitle = "Attention! Security level lowered to green."
	message = "Непосредственные или явные угрозы для станции отсутствуют. " + \
			"Служба безопасности обязана спрятать оружие, а также уважать личное право и пространство персонала, несанкционированные обыски запрещены."
	sound = "downtogreen"

/datum/announcement/station/code/uptoblue
	name = "Code: Up to Blue"
	subtitle = "Attention! Security level elevated to blue."
	message = "Командование получило надежную информацию о возможной враждебной активности на борту станции. " + \
			"Служба безопасности может носить оружие на виду, однако, не следует вынимать его без необходимости. " + \
			"Разрешается личный обыск персонала и отсеков станции без предварительных санкций."
	sound = "blue"

/datum/announcement/station/code/downtoblue
	name = "Code: Down to Blue"
	subtitle = "Attention! Security level lowered to blue."
	message = "Непосредственная угроза станции отсутсвует. " + \
			"Служба безопасности не имеет права вынимать оружие, однако может носить его на виду. " + \
			"Спонтанные обыски всё еще разрешены."
	sound = "downtoblue"

/datum/announcement/station/code/uptored
	name = "Code: Up to Red"
	subtitle = "Attention! Code red!"
	message = "Существует прямая угроза станции или возможно причинение значительного ущерба. " + \
			"Боевое положение! Служба безопасности имеет право носить оружие на готове по собственному усмотрению. " + \
			"Рекомендуются спонтанные обыски персонала и отсеков. Весь персонал станции обязан оставаться в своих отделах. " + \
			"Весь персонал станции обязан повиноваться требованиям СБ и выше стоящих офицеров."
	sound = "red"

/datum/announcement/station/code/downtored
	name = "Code: Down to Red"
	subtitle = "Attention! Code red!"
	message = "Механизм самоунитожения деактивирован и над ситуацией был вернут частичный контроль. " + \
			"Тем не менее существует прямая угроза станции. Служба безопасности имеет право носить оружие наготове по собственному усмотрению. " + \
			"Рекомендуются спонтанные обыски персонала и отсеков."
	sound = "downtored"

/datum/announcement/station/code/delta
	name = "Code: Up to Delta"
	subtitle = "Attention! Delta security level reached!"
	message = "Внимание, активирован механизм самоуничтожения или ситуация вышла полностью из под контроля! " + \
			"Все приказы глав станции должны выполняться беспрекословно, любое неповиновение карается смертью! " + \
			"Всему персоналу перевести датчики костюмов в третий режим! Это не учебная тревога!"
	sound = "delta"

/* GAME MODES */
/* Blob */
/datum/announcement/centcomm/blob/outbreak5
	name = "Blob: Level 5 Outbreak"
	subtitle = "Biohazard Alert"
	message = "Confirmed outbreak of level 5 biohazard aboard Space Station 13. " + \
			"All personnel must contain the outbreak. The station crew isolation protocols are now active."
	sound = "outbreak5"
/datum/announcement/centcomm/blob/outbreak5/play()
	message = "Confirmed outbreak of level 5 biohazard aboard [station_name()]. " + \
			"All personnel must contain the outbreak. The station crew isolation protocols are now active."
	..()

/datum/announcement/centcomm/blob/critical
	name = "Blob: Blob Critical Mass"
	subtitle = "Biohazard Alert"
	message = "Biohazard has reached critical mass. Station loss is imminent."

/* Epidemic */
/datum/announcement/centcomm/epidemic/cruiser
	name = "Epidemic: Cruiser"
	subtitle = "Station Early Warning System"
	message = "Inbound cruiser detected on collision course. Scans indicate the ship to be armed and ready to fire. Estimated time of arrival: 5 minutes."
/datum/announcement/centcomm/epidemic/cruiser/play()
	subtitle = "[station_name()] Early Warning System"
	..()

/* Mutiny */
/datum/announcement/centcomm/mutiny/reveal
	name = "Mutiny: Directive Reveal"
	subtitle = "Emergency Transmission"
	message = "Incoming emergency directive: Captain's office fax machine, Space Station 13."
/datum/announcement/centcomm/mutiny/reveal/play()
	message = "Incoming emergency directive: Captain's office fax machine, [station_name()]."
	..()

/datum/announcement/centcomm/mutiny/noert
	name = "Mutiny: ERT is busy"
	subtitle = "Emergency Transmission"
	message = "The presence of ERP in the region is tying up all available local emergency resources; emergency response teams cannot be called at this time."
/datum/announcement/centcomm/mutiny/noert/play(reason)
	if(reason)
		message = "The presence of [reason] in the region is tying up all available local emergency resources; emergency response teams cannot be called at this time."
	..()

/* Nuclear */
/datum/announcement/centcomm/nuclear/war
	name = "Nuclear: Declaration of War"
	subtitle = "Declaration of War"
	message = "The Syndicate has declared they intent to utterly destroy Space Station 13 with a nuclear device, and dares the crew to try and stop them."
/datum/announcement/centcomm/nuclear/war/play(message)
	if(message)
		src.message = message
	..()

/* Vox */
/datum/announcement/centcomm/vox/arrival
	name = "Vox: Shuttle Arrives"
	message = "Внимание, Космическая Станция 13, неподалёку от вашей станции проходит корабль не отвечающий на наши запросы. " + \
			"По последним данным этот корабль принадлежит Торговой Конфедерации."
/datum/announcement/centcomm/vox/arrival/play()
	message = "Внимание, [station_name()], неподалёку от вашей станции проходит корабль не отвечающий на наши запросы. " + \
			"По последним данным этот корабль принадлежит Торговой Конфедерации."

/datum/announcement/centcomm/vox/returns
	name = "Vox: Shuttle Returns"
	subtitle = "NSV Icarus"
	message = "Your guests are pulling away, Exodus - moving too fast for us to draw a bead on them. " + \
			"Looks like they're heading out of Space Station 13 at a rapid clip."
/datum/announcement/centcomm/vox/returns/play()
	message = "Your guests are pulling away, Exodus - moving too fast for us to draw a bead on them. " + \
			"Looks like they're heading out of [system_name()] at a rapid clip."

/* Malfunction */
/datum/announcement/centcomm/malf/declared
	name = "Malf: Declared Victory"
	title = null
	subtitle = null
	message = null
	flags = ANNOUNCE_SOUND
	sound = "malf"

/datum/announcement/centcomm/malf/first
	name = "Malf: Announce №1"
	message = "Caution, Space Station 13. We have detected abnormal behaviour in your network. " + \
			"It seems someone is trying to hack your electronic systems. We will update you when we have more information."
	sound = "malf1"
/datum/announcement/centcomm/malf/first/play()
	message = "Caution, [station_name]. We have detected abnormal behaviour in your network. " + \
			"It seems someone is trying to hack your electronic systems. We will update you when we have more information."
	..()

/datum/announcement/centcomm/malf/second
	name = "Malf: Announce №2"
	message = "We started tracing the intruder. Whoever is doing this, they seem to be on the station itself. " + \
			"We suggest checking all network control terminals. We will keep you updated on the situation."
	sound = "malf2"

/datum/announcement/centcomm/malf/third
	name = "Malf: Announce №3"
	message = "This is highly abnormal and somewhat concerning. " + \
			"The intruder is too fast, he is evading our traces. No man could be this fast..."
	sound = "malf3"

/datum/announcement/centcomm/malf/fourth
	name = "Malf: Announce №4"
	message = "We have traced the intrude#, it seem& t( e yo3r AI s7stem, it &# *#ck@ng th$ sel$ destru$t mechani&m, stop i# bef*@!)$#&&@@  <CONNECTION LOST>"
	sound = "malf4"

/* Gang */
/datum/announcement/station/gang/breach
	name = "Gang: Dominator Activation"
	message = "Network breach detected somewhere on the station. Some Gang is attempting to seize control of the station!"
/datum/announcement/station/gang/breach/play(area/A, gang)
	if(A && gang)
		message = "Network breach detected in [initial(A.name)]. The [gang_name(gang)] Gang is attempting to seize control of the station!"
	..()

/datum/announcement/station/gang/multiple
	name = "Gang: Multiple Dominators"
	message = "Multiple station takeover attempts have made simultaneously. Conflicting hostile runtimes appears to have delayed both attempts."
