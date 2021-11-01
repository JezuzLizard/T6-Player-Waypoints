
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include scripts/objective_common/objective_util;

main()
{
	level.health_indicators_thresholds = [];
	level.health_indicators_thresholds[ "damaged" ] = 0.6;
	level.health_indicators_thresholds[ "hurt" ] = 0.2;
	level.health_indicators_thresholds[ "near_death" ] = 0.01;
	level.health_indicators_thresholds[ "dead" ] = 0.0;
	level.health_indicator_size = 2;
	level.health_indicator_offset = ( 0, 0, 80 );
	OBJ_ADD_NEW( "overhead_health_indicator", -1 );
	level thread on_player_connect();
	level thread on_player_disconnect();
}

on_player_connect()
{
	while ( true )
	{
		level waittill( "connected", player );
		waittillframeend;
		level.custom_objectives[ "overhead_health_indicator" ] HEALTH_INDICATOR_ADD_ENT( player, "all" );
	}
}

on_player_disconnect()
{
	hud_keys = getArrayKeys( level.custom_objectives );
	while ( true )
	{
		level waittill( "disconnect", player );
		foreach ( key in hud_keys )
		{
			level.custom_objectives[ key ] OBJ_REMOVE_ENT( player );
		}
	}
}