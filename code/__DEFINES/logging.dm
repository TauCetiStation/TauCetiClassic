#define LOG_CLEANING(text) \
  replace_characters(text, list(JA_ENTITY=JA_PLACEHOLDER, JA_ENTITY_ASCII=JA_PLACEHOLDER, JA_CHARACTER=JA_PLACEHOLDER))

//Investigate logging defines
//todo: not all curently used, copypaste from /tg/
#define INVESTIGATE_ATMOS           "atmos"
#define INVESTIGATE_BOTANY          "botany"
#define INVESTIGATE_CARGO           "cargo"
#define INVESTIGATE_RECORDS         "records"
#define INVESTIGATE_SINGULO         "singulo"
#define INVESTIGATE_SUPERMATTER     "supermatter"
#define INVESTIGATE_TELESCI         "telesci"
#define INVESTIGATE_WIRES           "wires"
#define INVESTIGATE_PORTAL          "portals"
#define INVESTIGATE_RESEARCH        "research"
#define INVESTIGATE_HALLUCINATIONS  "hallucinations"
#define INVESTIGATE_RADIATION       "radiation"
