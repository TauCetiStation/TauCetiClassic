// MySQL configuration

var/sqladdress = "localhost"
var/sqlport = "3306"
var/sqldb = "ss13"
var/sqllogin = "root"
var/sqlpass = ""

// For FTP requests. (i.e. downloading runtime logs.)
// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0
var/custom_event_msg = null

//Database connections
//A connection is established on world creation. Ideally, the connection dies when the server restarts (After feedback logging.).
var/DBConnection/dbcon = new()

//
// Xeno/role whitelist database ( code/modules/admin/whitelist.dm )
//
var/list/role_whitelist   // cache of all ckeys and their roles
var/list/whitelisted_roles = list("unathi", "tajaran", "skrell", "diona", "machine", "vox", "ian") // Case important, everything must be in lowercase.
