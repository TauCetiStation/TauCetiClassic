// MySQL configuration

var/global/sqladdress = "localhost"
var/global/sqlport = "3306"
var/global/sqldb = "ss13"
var/global/sqllogin = "root"
var/global/sqlpass = ""

// For FTP requests. (i.e. downloading runtime logs.)
// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/global/fileaccess_timer = 0

//Database connections
//A connection is established on world creation. Ideally, the connection dies when the server restarts (After feedback logging.).
var/global/DBConnection/dbcon = new()

//
// Xeno/role whitelist database ( code/modules/admin/whitelist.dm )
//
var/global/list/role_whitelist   // cache of all ckeys and their roles
var/global/list/whitelisted_roles = list("unathi", "tajaran", "skrell", "diona", "machine", "vox", "ian") // Case important, everything must be in lowercase.
