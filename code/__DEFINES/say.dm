// A link given to ghost alice to follow bob
#define FOLLOW_LINK(alice, bob) "<a href=?src=\ref[alice];track=\ref[bob]>(F)</a>"
#define TURF_LINK(alice, turfy) "<a href=?src=\ref[alice];x=[turfy.x];y=[turfy.y];z=[turfy.z]>(T)</a>"
#define FOLLOW_OR_TURF_LINK(alice, bob, turfy) "<a href=?src=\ref[alice];track=\ref[bob];x=[turfy.x];y=[turfy.y];z=[turfy.z]>(F)</a>"

// Link for alice to help bob
#define HELP_LINK(alice, bob) "<a href=?src=\ref[alice];help_other=\ref[bob]>Click here to help [bob].</a>"
