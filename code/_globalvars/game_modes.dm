var/global/master_mode = "extended" //"extended"
var/global/secret_force_mode = "Secret" // if this is anything but "Secret", the secret rotation will forceably choose this mode

var/global/wavesecret = 0
var/global/master_last_mode = null // this variable contain the last played mode from previous round

// List of modes that failed on start, as to not repeatedly choose the same mode
// that keeps failing over and over.
var/global/list/modes_failed_start = list()

var/global/autotraitors_spawn_cd = 15 MINUTES
