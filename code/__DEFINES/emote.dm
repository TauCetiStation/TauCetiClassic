#define EMOTE_STATE(proc_name, arguments...) CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(##proc_name), ##arguments)
