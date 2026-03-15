// WARNING: TAGS ARE USED IN DATABASE/SAVEFILES, MIGRATION REQUIRED FOR RENAMES

// intends for orders in manifests
// heads use the same intend in both own and command departments
#define CREW_INTEND_HEADS(order) (0 + order)
#define CREW_INTEND_EMPLOYEE(order) (10 + order)
// department assistant are always on the bottom
#define CREW_INTEND_ASSIST(order) (100 + order)
#define CREW_INTEND_UNDEFINED 1000

/* Command */
#define DEP_COMMAND "Command"

#define JOB_CAPTAIN "Captain"

/* Civilians */
#define DEP_CIVILIAN "Civilian"

#define JOB_HOP "Head of Personnel"
#define JOB_ASSISTANT "Assistant"
#define JOB_MINER "Shaft Miner"
#define JOB_BARTENDER "Bartender"
#define JOB_CHEF "Chef"
#define JOB_HYDRO "Botanist"
#define JOB_JANITOR "Janitor"
#define JOB_BARBER "Barber"
#define JOB_LIBRARIAN "Librarian"
#define JOB_CHAPLAIN "Chaplain"
#define JOB_QM "Quartermaster"
#define JOB_CARGO_TECH "Cargo Technician"
#define JOB_RECYCLER "Recycler"
#define JOB_CLOWN "Clown"
#define JOB_MIME "Mime"

/* Engineering */
#define DEP_ENGINEERING "Engineering"

#define JOB_CHIEF_ENGINEER "Chief Engineer"
#define JOB_ENGINEER "Station Engineer"
#define JOB_ATMOS "Atmospheric Technician"
#define JOB_TECHNICAL_ASSISTANT "Technical Assistant"

/* Medical */
#define DEP_MEDICAL "Medical"

#define JOB_CMO "Chief Medical Officer"
#define JOB_DOCTOR "Medical Doctor"
#define JOB_PARAMEDIC "Paramedic"
#define JOB_CHEMIST "Chemist"
#define JOB_VIROLOGIST "Virologist"
#define JOB_PSYCHIATRIST "Psychiatrist"
#define JOB_INTERN "Medical Intern"

/* Mixed */
#define JOB_GENETICIST "Geneticist"

/* Science */
#define DEP_SCIENCE "Science"

#define JOB_RD "Research Director"
#define JOB_SCIENTIST "Scientist"
#define JOB_XENOARCHAEOLOGIST "Xenoarchaeologist"
#define JOB_XENOBIOLOGIST "Xenobiologist"
#define JOB_ROBOTICIST "Roboticist"
#define JOB_RESEARCH_ASSISTANT "Research Assistant"

/* Science */
#define DEP_SECURITY "Security"

#define JOB_HOS "Head of Security"
#define JOB_WARDEN "Warden"
#define JOB_DETECTIVE "Detective"
#define JOB_OFFICER "Security Officer"
#define JOB_FORENSIC "Forensic Technician"
#define JOB_CADET "Security Cadet"

/* Silicon */
#define DEP_SILICON "Silicon"

#define JOB_AI "AI"
#define JOB_CYBORG "Cyborg"

/* Special */
#define DEP_SPECIAL "Special"

#define JOB_BLUESHIELD "Blueshield Officer"
#define JOB_LAWYER "Internal Affairs Agent"
