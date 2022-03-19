#define P_THEY(g) g == MALE && "he" \
               || g == FEMALE && "she" \
               || g == NEUTER && "it" \
               || "they"

#define P_THEM(g) g == MALE && "him" \
               || g == FEMALE && "her" \
               || "them"

#define P_THEIR(g) g == MALE && "his" \
                || g == FEMALE && "her" \
                || "their"
