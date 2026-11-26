 //Don't forget to swap new line breaks to \n!

/datum/music_composition
	var/name = "name"
	var/melody = ""
	var/replays = 0

/datum/music_composition/cargo_ad
	name = "Cargo AD"
	melody = "BPM: 120\nC5/2-C3/2,C5/2,D5/2,E5/2,G5-G3,E5\nG4/2-G2/2,G4/2,B4/2,D5/2,E5/2,D5,D5-G3\nA4/2-A2/2,C5/2,E5/2,E5/2,D5,C5-A3\nA4/2-F2/2,G4/2,A4/2,B4/2,C5,C5-G3\nG5/2-C3/2,E5/2,C5/2,E5/2,C6-C5-G4-E4/2"
	replays = 0

var/global/list/datum/music_composition/ringtone/ringtones_by_names

/datum/music_composition/ringtone/thinktronic
	name = "Thinktronic"
	melody = "BPM: 188\nE6/2,D6/1.8,F#5,G#5,C#6/2,B5/1.8,D5,E5\nB5/2,A5/1.8,C#5/0.9,E5/0.8,A5/0.7,,,,,,"
	replays = 1

/datum/music_composition/ringtone/thinktronic_2
	name = "Thinktronic 2"
	melody = "BPM: 167\nC6,G5/2,G/2,A5,G, ,B5,C6,"
	replays = 0

/datum/music_composition/ringtone/flipflap
	name = "Flip-Flap"
	melody = "BPM: 188\nC5,Eb5,F5,G5/2,C6,C/1.8,G,F,E,C5,E,F,G/2,Ab5\nA/1.8,G,F,E"
	replays = 0

/datum/music_composition/ringtone/ring1
	name = "Ring 1"
	melody = "BPM: 251\nB5/3,G5/3,B/3,G/3,B/3,G/3,B/3,G/3,B/3,G/3"
	replays = 1

/datum/music_composition/ringtone/ring2
	name = "Ring 2"
	melody = "BPM: 251\nA5/3,G5/3,A/3,G/3,A/3,G/3,A/3,G/3,A/3,G/3"
	replays = 1

/datum/music_composition/ringtone/ring3
	name = "Ring 3"
	melody = "BPM: 251\nD5/3,C5/3,D/3,C/3,D/3,C/3,D/3,C/3,D/3,C/3"
	replays = 1

/datum/music_composition/ringtone/ring4
	name = "Ring 4"
	melody = "BPM: 251\nE5/3,G5/3,E/3,G/3,E/3,G/3,E/3,G/3,E/3,G/3"
	replays = 1

/datum/music_composition/ringtone/ring5
	name = "Ring 5"
	melody = "BPM: 251\nF5/3,B#5/3,F/3,B/3,F/3,B/3,F/3,B/3,F/3,B/3"
	replays = 1
