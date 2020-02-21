var/global/log_directory
var/global/log_investigate_directory
var/global/log_debug_directory
var/global/log_debug_js_directory

var/global/game_log
var/global/hrefs_log
var/global/access_log
var/global/initialization_log
var/global/runtime_log
var/global/qdel_log
var/global/sql_error_log

var/list/jobMax = list()
var/list/bombers = list(  )
var/list/admin_log = list (  )
var/list/lastsignalers = list(	)	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
var/list/lawchanges = list(  ) //Stores who uploaded laws to which silicon-based lifeform, and what the law was
var/list/shuttles = list(  )
//	list/traitobj = list(  )

var/list/combatlog = list()
var/list/IClog = list()
var/list/OOClog = list()
var/list/adminlog = list()
