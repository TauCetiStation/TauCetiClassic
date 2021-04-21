/* EVENTS */
/datum/announcement/centcomm/anomaly
	subtitle = "Anomaly Alert"


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

/datum/announcement/centcomm/anomaly/massive_portals
	name = "Anomaly: Many Bluespace Alerts"
	message = "Внимание! Был зафиксирован кластер несанкционированных блюспейс сигнатур! Сохраните целостность объекта."
	sound = "bluspaceanom"

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
