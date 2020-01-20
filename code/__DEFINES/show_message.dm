//#define SHOWMSG_SELF
#define SHOWMSG_VISUAL (1<<0)
#define SHOWMSG_AUDIO  (1<<1)
#define SHOWMSG_FEEL   (1<<2) // smell && taste && touch senses (no need to separate if we don't have related disabilities)

#define SHOWMSG_ALWAYS (~0)   // should be used for fallback message only