#define DECLARE_DB_STAT(stat) var/DB_STAT_PREFFIX_##stat
#define GET_DB_STAT(source, stat) source.DB_STAT_PREFFIX_##stat

/proc/_is_not_db_stat(stat)
	return copytext(stat, 1, length("DB_STAT_PREFFIX") + 1) != "DB_STAT_PREFFIX"

#define JSON_ONLY_STAT_CALLBACK CALLBACK(GLOBAL_PROC, .proc/_is_not_db_stat)
