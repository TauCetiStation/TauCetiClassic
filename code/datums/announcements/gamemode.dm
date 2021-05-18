/* GAME MODES */
/datum/announcement/centcomm/malf
	subtitle = "Network Monitoring"


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

/* Cult */
/datum/announcement/station/cult/capture_area
	name = "Anomaly: Bluespace"
	message = "Unstable bluespace anomaly detected on long range scanners. Expected location: unknown."
	sound = "bluspaceanom"
/datum/announcement/station/cult/capture_area/play(area/A)
	if(A)
		message = "Unstable bluespace anomaly detected on long range scanners. Expected location: [A.name]."
	..()
