var/master_mode = "extended"//"extended"
var/secret_force_mode = "secret" // if this is anything but "secret", the secret rotation will forceably choose this mode

var/wavesecret = 0
var/datum/station_state/start_state = null
var/master_last_mode = null // this variable contain the last played mode from previous round
