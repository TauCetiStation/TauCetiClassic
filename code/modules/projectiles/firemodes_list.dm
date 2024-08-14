//semiauto
/datum/firemode/semiauto
	settings = /datum/firemode_settings/semiauto

/datum/firemode_settings/semiauto
	firemode_name = "Полуавтоматический"
	fire_delay = 4
	burst = 1
	burst_delay = 0
	spread = 0


/datum/firemode/semiauto/plasma
	settings = /datum/firemode_settings/semiauto/plasma

/datum/firemode_settings/semiauto/plasma
	fire_delay = 1

//burst

/datum/firemode/threeburst
	settings = /datum/firemode_settings/threeburst

/datum/firemode_settings/threeburst
	firemode_name = "Отсечка по 3 патрона"
	burst = 3
	spread = 1


/datum/firemode/threeburst/slow
	settings = /datum/firemode_settings/threeburst/slow

/datum/firemode_settings/threeburst/slow
	burst_delay = 1.75


/datum/firemode/threeburst/medium
	settings = /datum/firemode_settings/threeburst/medium

/datum/firemode_settings/threeburst/medium
	burst_delay = 1.5


/datum/firemode/threeburst/fast
	settings = /datum/firemode_settings/threeburst/fast

/datum/firemode_settings/threeburst/fast
	burst_delay = 1.25

//full auto

/datum/firemode/automatic/very_slow
	settings = /datum/firemode_settings/automatic/very_slow

/datum/firemode_settings/automatic/very_slow
	fire_delay = 2


/datum/firemode/automatic/slow
	settings = /datum/firemode_settings/automatic/slow

/datum/firemode_settings/automatic/slow
	fire_delay = 1.75


/datum/firemode/automatic/medium
	settings = /datum/firemode_settings/automatic/medium

/datum/firemode_settings/automatic/medium
	fire_delay = 1.5


/datum/firemode/automatic/fast
	settings = /datum/firemode_settings/automatic/fast

/datum/firemode_settings/automatic/fast
	fire_delay = 1.25
