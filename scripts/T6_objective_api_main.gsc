#include maps/mp/_utility;
#include common_scripts/utility;
#include scripts/objective_common/objective_util;

main()
{
	OBJ_ADD_NEW( "overhead_health_bar", -1 );
	OBJ_ADD_NEW( "overhead_health_value", -1 );
	level thread on_player_connect();
	level thread on_player_disconnect();
}