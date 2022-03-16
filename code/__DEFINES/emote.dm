#define EMOTE_STATE(proc_name, arguments...) CALLBACK(GLOBAL_PROC, .proc/##proc_name, ##arguments)
