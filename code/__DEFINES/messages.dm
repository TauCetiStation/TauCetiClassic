#define MAX_MESSAGE_LEN       1024
#define MAX_PAPER_MESSAGE_LEN 9216
#define MAX_BOOK_MESSAGE_LEN  27648
#define MAX_NAME_LEN          26
#define MAX_LNAME_LEN         64
#define MAX_REV_REASON_LEN    255

//#define SHOWMSG_SELF
#define SHOWMSG_VISUAL (1<<0)
#define SHOWMSG_AUDIO  (1<<1)
#define SHOWMSG_FEEL   (1<<2) // smell && taste && touch senses (no need to separate if we don't have related disabilities)

#define SHOWMSG_ALWAYS (~0)   // should be used for fallback message only
