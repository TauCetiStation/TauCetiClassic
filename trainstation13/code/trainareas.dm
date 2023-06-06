//TRAIN STATION 13

/area/trainstation //Everything begins here.
	name = "Train Station 13"
	icon = 'trainstation13/icons/trainareas.dmi'
	icon_state = "trainstation13"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	ambience = null

//AREAS OUTSIDE OF THE TRAIN

/area/trainstation/street
	name = "Street"
	icon_state = "street"
	requires_power = FALSE
	looped_ambience = 'trainstation13/sound/loop_trainstation.ogg'
	ambience = list(
		'trainstation13/sound/steam_short.ogg',
		'trainstation13/sound/steam_long.ogg',
		'trainstation13/sound/dog_distant_1.ogg',
		'trainstation13/sound/dog_distant_2.ogg',
		'trainstation13/sound/dog_distant_3.ogg'
	)

/area/trainstation/apartment
	name = "Apartment"
	icon_state = "apartment"
	requires_power = FALSE
	looped_ambience = 'trainstation13/sound/loop_apartment.ogg'
	ambience = list(
		'trainstation13/sound/apartment_radio_1.ogg',
		'trainstation13/sound/apartment_radio_2.ogg',
		'trainstation13/sound/apartment_radio_3.ogg',
		'trainstation13/sound/apartment_neighbors_1.ogg',
		'trainstation13/sound/apartment_neighbors_2.ogg',
		'trainstation13/sound/apartment_neighbors_3.ogg'
	)
	sound_environment = SOUND_ENVIRONMENT_LIVINGROOM

/area/trainstation/apartment/kitchen
	name = "Kitchen"
	icon_state = "kitchen"

/area/trainstation/apartment/livingroom
	name = "Living Room"
	icon_state = "livingroom"

/area/trainstation/apartment/bedroom
	name = "Bedroom"
	icon_state = "bedroom"

/area/trainstation/apartment/bathroom
	name = "Bathroom"
	icon_state = "bathroom"
	looped_ambience = 'trainstation13/sound/loop_generic.ogg'
	ambience = null
	sound_environment = SOUND_ENVIRONMENT_GENERIC

/area/trainstation/apartment/balcony
	name = "Balcony"
	icon_state = "balcony"
	looped_ambience = 'trainstation13/sound/loop_balcony.ogg'
	ambience = list(
		'trainstation13/sound/dog_distant_1.ogg',
		'trainstation13/sound/dog_distant_2.ogg',
		'trainstation13/sound/dog_distant_3.ogg',
		'sound/effects/wind/wind_2_1.ogg',
		'sound/effects/wind/wind_2_2.ogg',
		'sound/effects/wind/wind_3_1.ogg',
		'sound/effects/wind/wind_4_1.ogg',
		'sound/effects/wind/wind_4_2.ogg',
		'sound/effects/wind/wind_5_1.ogg'
	)
	sound_environment = SOUND_ENVIRONMENT_GENERIC

/area/trainstation/station
	name = "Train Station"
	icon_state = "station"
	requires_power = FALSE
	looped_ambience = 'trainstation13/sound/loop_trainstation.ogg'
	ambience = list('trainstation13/sound/steam_short.ogg', 'trainstation13/sound/steam_long.ogg')
	sound_environment = SOUND_ENVIRONMENT_HANGAR

/area/trainstation/guard
	name = "Railway Crossing Guard"
	icon_state = "guard"
	requires_power = FALSE
	looped_ambience = 'trainstation13/sound/loop_trainstation.ogg'
	ambience = list(
		'trainstation13/sound/PRS_1.ogg',
		'trainstation13/sound/PRS_2.ogg',
		'trainstation13/sound/PRS_3.ogg',
		'trainstation13/sound/PRS_4.ogg',
		'trainstation13/sound/PRS_5.ogg',
		'trainstation13/sound/PRS_6.ogg',
		'trainstation13/sound/PRS_7.ogg',
		'trainstation13/sound/PRS_8.ogg',
		'trainstation13/sound/PRS_9.ogg',
		'trainstation13/sound/PRS_10.ogg',
		'trainstation13/sound/PRS_11.ogg',
		'trainstation13/sound/PRS_12.ogg',
		'trainstation13/sound/PRS_13.ogg',
		'trainstation13/sound/PRS_14.ogg',
		'trainstation13/sound/PRS_15.ogg',
		'trainstation13/sound/PRS_16.ogg',
		'trainstation13/sound/PRS_17.ogg',
		'trainstation13/sound/PRS_18.ogg',
		'trainstation13/sound/PRS_19.ogg',
		'trainstation13/sound/PRS_20.ogg',
		'trainstation13/sound/PRS_21.ogg',
		'trainstation13/sound/PRS_22.ogg',
		'trainstation13/sound/PRS_23.ogg'
	)

//PARENT OF ALL TRAIN AREAS

/area/trainstation/train
	name = "Train"
	icon_state = "train"
	looped_ambience = 'trainstation13/sound/loop_trainride.ogg' //Potential for quick swap of looped ambience

//LOCOMOTIVE

/area/trainstation/train/locomotive //Parent of all locomotive and train maintenance related areas
	name = "Locomotive"
	icon_state = "locomotive"

/area/trainstation/train/locomotive/engine
	name = "Locomotive Engine"
	icon_state = "engine"
	ambience = list('trainstation13/sound/steam_short.ogg', 'trainstation13/sound/steam_long.ogg')

/area/trainstation/train/locomotive/crew
	name = "Locomotive Crew"
	icon_state = "crew"

/area/trainstation/train/locomotive/cab //Cabin and individual railcar conductors compartments
	name = "Locomotive Cab"
	icon_state = "cab"
	ambience = list(
		'trainstation13/sound/PRS_1.ogg',
		'trainstation13/sound/PRS_2.ogg',
		'trainstation13/sound/PRS_3.ogg',
		'trainstation13/sound/PRS_4.ogg',
		'trainstation13/sound/PRS_5.ogg',
		'trainstation13/sound/PRS_6.ogg',
		'trainstation13/sound/PRS_7.ogg',
		'trainstation13/sound/PRS_8.ogg',
		'trainstation13/sound/PRS_9.ogg',
		'trainstation13/sound/PRS_10.ogg',
		'trainstation13/sound/PRS_11.ogg',
		'trainstation13/sound/PRS_12.ogg',
		'trainstation13/sound/PRS_13.ogg',
		'trainstation13/sound/PRS_14.ogg',
		'trainstation13/sound/PRS_15.ogg',
		'trainstation13/sound/PRS_16.ogg',
		'trainstation13/sound/PRS_17.ogg',
		'trainstation13/sound/PRS_18.ogg',
		'trainstation13/sound/PRS_19.ogg',
		'trainstation13/sound/PRS_20.ogg',
		'trainstation13/sound/PRS_21.ogg',
		'trainstation13/sound/PRS_22.ogg',
		'trainstation13/sound/PRS_23.ogg'
	)

/area/trainstation/train/locomotive/cab/headlights
	name = "Locomotive Headlights"
	icon_state = "headlights"

/area/trainstation/train/locomotive/cab/spotlight
	name = "Locomotive Spotlight"
	icon_state = "spotlight"

/area/trainstation/train/locomotive/cab/radio
	name = "Railway Post Office Radio"
	icon_state = "radio"

/area/trainstation/train/locomotive/cab/security
	name = "V.I.P. Railcar Security"
	icon_state = "security"

/area/trainstation/train/locomotive/cab/conductor1
	name = "Railcar 1 Conductor"
	icon_state = "conductor1"

/area/trainstation/train/locomotive/cab/conductor2
	name = "Railcar 2 Conductor"
	icon_state = "conductor2"

/area/trainstation/train/locomotive/cab/conductor3
	name = "Railcar 3 Conductor"
	icon_state = "conductor3"

/area/trainstation/train/locomotive/cab/conductor4
	name = "Railcar 4 Conductor"
	icon_state = "conductor4"

/area/trainstation/train/locomotive/cab/conductor5
	name = "Railcar 5 Conductor"
	icon_state = "conductor5"

/area/trainstation/train/locomotive/cab/conductor6
	name = "Railcar 6 Conductor"
	icon_state = "conductor6"

/area/trainstation/train/locomotive/cab/conductor7
	name = "Railcar 7 Conductor"
	icon_state = "conductor7"

/area/trainstation/train/locomotive/cab/conductor8
	name = "Railcar 8 Conductor"
	icon_state = "conductor8"

/area/trainstation/train/locomotive/cab/conductor9
	name = "Railcar 9 Conductor"
	icon_state = "conductor9"

/area/trainstation/train/locomotive/cab/conductor0
	name = "Railcar 10 Conductor"
	icon_state = "conductor0"

//GANGWAY

/area/trainstation/train/gangway
	name = "Zone of Train Station 13" //Quick teleport marker to the train gangways for admins and observers automatically located at the bottom of the list
	icon_state = "gangway"
	sound_environment = SOUND_ENVIRONMENT_GENERIC

//RAILCARS

/area/trainstation/train/railcar //Parent of all railcar areas
	name = "Railcar"
	icon_state = "railcar"

/area/trainstation/train/railcar/dining
	name = "Dining Car Hall"
	icon_state = "tea"

/area/trainstation/train/railcar/kitchen
	name = "Dining Car Kitchen"
	icon_state = "chef"

/area/trainstation/train/railcar/salon
	name = "V.I.P. Railcar Salon"
	icon_state = "power"

/area/trainstation/train/railcar/vip
	name = "V.I.P. Railcar Compartment"
	icon_state = "vip"

/area/trainstation/train/railcar/maintenance
	name = "Railway Post Office Maintenance" //RPO
	icon_state = "maintenance"

/area/trainstation/train/railcar/post
	name = "Railway Post Office Cargo" //RPO
	icon_state = "post"

/area/trainstation/train/railcar/main1
	name = "Railcar 1 Corridor"
	icon_state = "main1"

/area/trainstation/train/railcar/aux1
	name = "Railcar 1 Compartments"
	icon_state = "aux1"

/area/trainstation/train/railcar/main2
	name = "Railcar 2 Corridor"
	icon_state = "main2"

/area/trainstation/train/railcar/aux2
	name = "Railcar 2 Compartments"
	icon_state = "aux2"

/area/trainstation/train/railcar/main3
	name = "Railcar 3 Corridor"
	icon_state = "main3"

/area/trainstation/train/railcar/aux3
	name = "Railcar 3 Compartments"
	icon_state = "aux3"

/area/trainstation/train/railcar/main4
	name = "Railcar 4 Corridor"
	icon_state = "main4"

/area/trainstation/train/railcar/aux4
	name = "Railcar 4 Compartments"
	icon_state = "aux4"

/area/trainstation/train/railcar/main5
	name = "Railcar 5 Corridor"
	icon_state = "main5"

/area/trainstation/train/railcar/aux5
	name = "Railcar 5 Compartments"
	icon_state = "aux5"

/area/trainstation/train/railcar/main6
	name = "Railcar 6 Corridor"
	icon_state = "main6"

/area/trainstation/train/railcar/aux6
	name = "Railcar 6 Compartments"
	icon_state = "aux6"

/area/trainstation/train/railcar/main7
	name = "Railcar 7 Corridor"
	icon_state = "main5"

/area/trainstation/train/railcar/aux7
	name = "Railcar 7 Compartments"
	icon_state = "aux5"

/area/trainstation/train/railcar/main8
	name = "Railcar 8 Corridor"
	icon_state = "main8"

/area/trainstation/train/railcar/aux8
	name = "Railcar 8 Compartments"
	icon_state = "aux8"

/area/trainstation/train/railcar/main9
	name = "Railcar 9 Corridor"
	icon_state = "main9"

/area/trainstation/train/railcar/aux9
	name = "Railcar 9 Compartments"
	icon_state = "aux9"

/area/trainstation/train/railcar/main0
	name = "Railcar 10 Corridor"
	icon_state = "main0"

/area/trainstation/train/railcar/aux0
	name = "Railcar 10 Compartments"
	icon_state = "aux0"