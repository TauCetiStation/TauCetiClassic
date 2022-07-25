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
#ifdef REFERENCE_TRACKING
var/global/gc_log
#endif
var/global/sql_error_log
var/global/asset_log
var/global/tgui_log

var/global/list/jobMax = list()
var/global/list/bombers = list(  )
var/global/list/admin_log = list (  )
var/global/list/lastsignalers = list(	)	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
var/global/list/lawchanges = list(  ) //Stores who uploaded laws to which silicon-based lifeform, and what the law was
var/global/list/shuttles = list(  )
//	list/traitobj = list(  )

var/global/list/combatlog = list()
var/global/list/IClog = list()
var/global/list/OOClog = list()
var/global/list/adminlog = list()
