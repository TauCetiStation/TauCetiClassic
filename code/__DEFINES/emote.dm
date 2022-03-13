#define EMOTE_PRIO_DEFAULT 0
#define EMOTE_PRIO_SPECIES 1
#define EMOTE_PRIO_ANTAGONIST 2

#define EMOTE_STATE(proc_name, arguments...) CALLBACK(GLOBAL_PROC, .proc/##proc_name, ##arguments)
