/* GAME MODES */
/datum/announcement/centcomm/malf
	subtitle = "Network Monitoring"

/datum/announcement/station/gang
	subtitle = "Station Firewall"


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
