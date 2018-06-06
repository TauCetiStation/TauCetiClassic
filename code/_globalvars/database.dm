// MySQL configuration

var/sqladdress = "localhost"
var/sqlport = "3306"
var/sqldb = "tgstation"
var/sqllogin = "root"
var/sqlpass = ""

// Feedback gathering sql connection

var/sqlfdbkdb = "test"
var/sqlfdbklogin = "root"
var/sqlfdbkpass = ""

// Forum MySQL configuration (for use with forum account/key authentication)
// These are all default values that will load should the forumdbconfig.txt
// file fail to read for whatever reason.

var/forumsqladdress = "localhost"
var/forumsqlport = "3306"
var/forumsqldb = "tgstation"
var/forumsqllogin = "root"
var/forumsqlpass = ""
var/forum_activated_group = "2"
var/forum_authenticated_group = "10"

// For FTP requests. (i.e. downloading runtime logs.)
// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0
var/custom_event_msg = null

//Database connections
//A connection is established on world creation. Ideally, the connection dies when the server restarts (After feedback logging.).
var/DBConnection/dbcon = new()	//Feedback database (New database)
var/DBConnection/dbcon_old = new()	//Tgstation database (Old database) - See the files in the SQL folder for information what goes where.

//
// Xeno/role whitelist database ( code/modules/admin/whitelist.dm )
//
var/list/role_whitelist   // cache of all ckeys and their roles
var/list/whitelisted_roles = list("unathi", "tajaran", "skrell", "diona", "machine", "ian", "limus") // Case important, everything must be in lowercase.
