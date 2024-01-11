var/global/standard_pda_ringtones = list(
	/datum/ringtone/thinktronic,
	/datum/ringtone/doomer,
	/datum/ringtone/clowntown,
	/datum/ringtone/caramelldansen,
	/datum/ringtone/mineshaft,
	/datum/ringtone/raddish_radio,
	/datum/ringtone/tajarsky_punch,
	/datum/ringtone/shipniky,
	/datum/ringtone/klubnika,
	/datum/ringtone/space_burial,
	/datum/ringtone/solgov,
	/datum/ringtone/skeletones,
	/datum/ringtone/band,
	)

var/global/pda_ringtones_prefs = list("Thinktronic","Doomer","Clown Town","Caramelldansen","Mineshaft","Raddish Radio","Tajarsky Punch","Shipniky","Klubnika","Space Burial","SolGov Anthem","Skeletones","Band")

/datum/ringtone
	var/name = "My Ringtone"
	var/melody = "E7,E7,E7"
	var/replays = 1

/datum/ringtone/thinktronic
	name = "Thinktronic"
	melody = "BPM: 188\nE6/2,D6/1.8,F#5,G#5,C#6/2,B5/1.8,D5,E5\nB5/2,A5/1.8,C#5/0.9,E5/0.8,A5/0.7,,,,,,"
	replays = 3

/datum/ringtone/doomer
	name = "Doomer"
	melody = "BPM: 251\nE6,G6, , , , , , ,G,E, , , , , , ,A6,G6,A,G,A,G\nA,G,A,B6, , , , , ,"
	replays = 1

/datum/ringtone/clowntown
	name = "Clown Town"
	melody = "BPM: 215\nG#6/2,Bb6/2,G6/2,Gn6/2,G#6/2,B6/2,C7/2,C#7/2,Eb7\nCn7,C7, ,F7,C#7,C, ,E7,Cn7,C7, ,G6/2,Bb6/2,G6/2\nGn6/2,G#6/2,B6/2,C7/2,C#7/2,E7,Cn7,C7,\nD7/2,C7/2,B6,D7/2,C7/2,B6/2,D4/2,E7, , ,"
	replays = 0

/datum/ringtone/caramelldansen
	name = "Caramelldansen"
	melody = "BPM: 301\nC#5, ,A#5,G#5,F#5, , ,G5, ,F5,G5,F5,G5, ,A5, ,D#5,\nA5,G5,F5, ,F5,G5, ,F5,G5,A5,G5, ,F5, ,C#5, ,A#5\nG#5,F5, , ,G5, ,F5,G5,F5,G5, ,A5, ,C6, ,B5,A5,F5,\nD5,G5, ,G5,A5, ,G5, ,F5,"
	replays = 0

/datum/ringtone/mineshaft
	name = "Mineshaft"
	melody = "BPM: 137\nA5,C#6,A6,B6,C7,B,A6,E6,D6,F#6,C7,E7,C7,A6, ,"
	replays = 0

/datum/ringtone/raddish_radio
	name = "Raddish Radio"
	melody = "BPM: 215\nA5,B5-C5-E5,A5,C5-E5, ,C5-E5,B5,C5-E5,A5,B5-C5-E5\nA5,C5-E5, ,C5-E5,C6,C5-E5,B5,C6-D5-F5,B5,D5-F5,\nD5-F5,D6,D5-F5,C6,D6-D5-F5,C6,D5-F5, ,D5-F5,D6\nD5-F5,C6,E5-G#5-D6,C6,E5-G5, ,E5-G5,D6,E5-G5,C6\nD6-E5-G5,C6,B5-E5-G5,A5,E5-G5,G5,E5-G5,A5,B5-C5-E5\nA5,C5-E5, ,C5-E5,D6,C5-E5,C6,D6-E5-G5,C6,B5-E5-G5\nA5,E5-G5,G5,E5-G5"
	replays = 0

/datum/ringtone/tajarsky_punch
	name = "Tajarsky Punch"
	melody = "BPM: 251\nEb6/3,En/3,F6,F,C6/2,D6/1.8,Eb6/2,En/1.8,F6,F,Ab6\nG6/2,F6/1.8,G,G6,A6/3,Bb6/2,A/2,F6,G6, , , ,B6,B\nDb7/3,Eb7/2,D/2,C7/2,B6/1.8,C7,C,D7/3,E7/2,D/2\nC7/2,B6/1.8,A6,A,B6/2,C7/1.8,B/2,G6/1.8,F6, , ,"
	replays = 0

/datum/ringtone/shipniky
	name = "Shipniky"
	melody = "BPM: 251\nE6, ,B5,C6,D6, ,C6,B5,A5, ,A5,C6,E6, ,D6,C6\nB5, , ,C6,D6, ,E6, ,C6, ,A5, ,A5, , , , ,D6,\nF6,A6, ,G6,F6,E6, , ,C6,E6,D6, ,C6,B5, ,B5,C6,D6,\nE6, ,C6, ,A5, ,A5, , ,"
	replays = 0

/datum/ringtone/klubnika
	name = "Klubnika"
	melody = "BPM: 251\nE6, ,D6, ,B5,C6,D6, ,B5,C6,D6, ,C6,B5,A5, ,E6,E6\nD6/0.7,C6/2,B5,C6,D6, ,B5,C6,D6, ,C6,B5,A5,"
	replays = 1

/datum/ringtone/space_burial
	name = "Space Burial"
	melody = "BPM: 251\nBb5, , ,B, ,B5,B, , ,Db6, ,C6,C6, ,B5,B5, ,A5\nB, , , , ,"
	replays = 0

/datum/ringtone/solgov
	name = "SolGov Anthem"
	melody = "BPM: 116\nD5/3,D/3,D/3,F5,F/3,F/3,F/3,A5,A/3,A/3,A/3,D6,D/3\nD/3,D/3,F6,G6,A6, ,C5, ,F5, ,C5,F6/3,F/3,F/3,D6\nD/3,D/3,D/3,C6,C/3,C/3,C/3,A5,A/3,A/3,A/3,G5,E5\nF5, ,D5, ,F5, ,D5"
	replays = 0


/datum/ringtone/skeletones
	name = "Skeletones"
	melody = "BPM: 215\nD6-G6,D-G,A#5-C#6-F#6,A-C-F,B5,D6/2,B5/2, ,B5\nD6-G6/2,G-D,/2,A#5-C6-F6,A-C-F,B5, , , ,D6-G6,G-D\nA5-C6-F6,A-C-F,B5,D6/2,B5/2, ,B5/2,C6/2,D6,G5-E6\nG5-C6,D6,F5-B5, , ,"
	replays = 0

/datum/ringtone/band
	name = "Band"
	melody = "BPM: 301\nD5,A5,G5,Bb5,A, , ,F5,G,A,B, ,A,D, , , , , , , , ,\nD,A,G,B,A, , ,A5,G5,F5,E5, ,F5,C5, , , , , , , , ,\nD,A5,G5,Bb5,A5, , ,F5,G5,A5,B, ,A5,D5, , , , , ,D,\nE5,F5,G5, ,F5,D5, , , , ,D5,F5,E5,D5,C5, ,D5/0.1"
	replays = 0
