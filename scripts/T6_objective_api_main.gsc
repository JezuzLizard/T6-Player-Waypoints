
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

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
		level waittill( "disconnect" );
		players = level.players;
		foreach ( key in hud_keys )
		{
			player_elem_keys = getArrayKeys( level.custom_objectives[ key ].entities );
			for ( j = 0; j < player_elem_keys.size; j++ )
			{
				still_ingame = false;
				for ( i = 0; i < players.size; i++ )
				{
					if ( player_elem_keys[ j ] == players[ i ].name )
					{
						still_ingame = true;
						arrayRemoveIndex( players, i );
						break;
					}
				}
				if ( !still_ingame )
				{
					level.custom_objectives[ key ].entities[ player_elem_keys[ j ] ] notify( "destroy_hud_ent" );
				}
			}
		}
	}
}

OBJ_ADD_NEW( name, duration )
{
	if ( !isDefined( level.custom_objectives ) )
	{
		level.custom_objectives = [];
	}
	if ( !isDefined( level.custom_objectives[ name ] ) )
	{
		level.custom_objectives[ name ] = spawnStruct();
		level.custom_objectives[ name ] thread OBJ_DESTROY_THREAD( name, duration );
	}
}

OBJ_REMOVE( name )
{
	if ( isDefined( level.custom_objectives[ name ] ) )
	{
		level.custom_objectives[ name ] notify( "destroy_hud" );
	}
}

OBJ_DESTROY_THREAD( name, duration )
{
	if ( duration != -1 )
	{
		self waittill_any_timeout( duration, "destroy_hud" );
	}
	else 
	{
		self waittill( "destroy_hud" );
	}
	foreach ( ent in self.entities )
	{
		self OBJ_REMOVE_ENT( ent );
	}
	self.entities = undefined;
	arrayRemoveIndex( level.custom_objectives, name );
}

OBJ_GET_REF( name, ent )
{
	if ( isDefined( level.custom_objectives[ name ].entities[ ent.name ] ) )
	{
		return level.custom_objectives[ name ].entities[ ent.name ];
	}
	return undefined;
}

HEALTH_INDICATOR_ADD_ENT( ent, team )
{
	if ( !isDefined( self.entities ) )
	{
		self.entities = [];
	}
	if ( team == "all" )
	{
		elem_team = undefined;
	}
	else 
	{
		elem_team = team;
	}
	self.entities[ ent.name ] = OBJ_CREATE_SERVER_HEALTH_INDICATOR( elem_team );
	self.entities[ ent.name ].target_ent = OBJ_SPAWN_ENT_ON_ENT( ent, level.health_indicator_offset );
	self.entities[ ent.name ].color = ( 0, 1, 0 );
	self.entities[ ent.name ] setShader( "white", level.health_indicator_size, level.health_indicator_size );
	self.entities[ ent.name ] setWayPoint( false );
	self.entities[ ent.name ] setTargetEnt( self.entities[ ent.name ].target_ent );
	ent thread HEALTH_INDICATOR_UPDATE( self.entities[ ent.name ] );
	self thread OBJ_ENT_DEATH( ent );
}

OBJ_REMOVE_ENT( ent )
{
	self.entities[ ent.name ] notify( "destroy_hud_ent" );
}

OBJ_ENT_DEATH( ent )
{
	self.entities[ ent.name ] waittill( "destroy_hud_ent" );
	self.entities[ ent.name ] setShader( "white", level.health_indicator_size, level.health_indicator_size );
	self.entities[ ent.name ] clearTargetEnt();
	self.entities[ ent.name ].target_ent unLink();
	self.entities[ ent.name ].target_ent delete();
	if ( isDefined( self.entities[ ent.name ] ) )
	{
		self.entities[ ent.name ] destroy();
	}
	arrayRemoveIndex( self.entities, ent.name );
}

OBJ_SPAWN_ENT_ON_ENT( ent, offset )
{
	if ( !isDefined( offset ) )
	{
		offset = ( 0, 0, 0 );
	}
	elem_ent = spawn( "script_model", ent.origin + offset );
	elem_ent setModel( "script_origin" );
	elem_ent linkTo( ent );
	return elem_ent;
}

OBJ_CREATE_SERVER_HEALTH_INDICATOR( team )
{
	if ( isDefined( team ) )
	{
		barelembg = newteamhudelem( team );
	}
	else
	{
		barelembg = newhudelem();
	}
	barelembg.elemtype = "icon";
	barelembg.x = 0;
	barelembg.y = 0;
	barelembg.xoffset = 0;
	barelembg.yoffset = 0;
	barelembg.alpha = 1;
	barelembg.hidden = 0;
	return barelembg;
}

HEALTH_INDICATOR_UPDATE( health_indicator )
{
	self endon( "disconnect" );
	flag_wait( "initial_blackscreen_passed" );
	health_indicator.hidewheninmenu = 1;
	while ( true )
	{
		if ( isDefined( self.e_afterlife_corpse ) || !is_player_valid( self ) )
		{
			if ( health_indicator.alpha != 0 )
			{
				health_indicator.alpha = 0;
			}
			wait 0.05;
			continue;
		}
		if ( health_indicator.alpha != 1 )
		{
			health_indicator.alpha = 1;
		}
		health_indicator set_color_from_health_fraction( float( ( self.health / self.maxhealth ) ) );
		wait 0.05;
	}
}

//1.0 == 0%, 0.61 == 100%

set_color_from_health_fraction( frac )
{
	// if ( frac < 1.0 && frac > 0.6 )
	// {
	// 	ratio_red_up = 1.0 - frac;
	// 	ratio_green_down = 3.20;
	// 	red_frac = ceil( ( ratio_red_up * 100 ) / 320 );
	// 	green_frac = ceil( ( ratio_green_down * 100 ) / 320 );
	// 	self.color = ( red_frac, green_frac, 0 );
	// }
	// if ( frac < 1.0 && frac > 0.2 )
	// {
	// 	ratio_red_up = 1.0 - frac;
	// 	ratio_green_down = abs( frac - 1.0 );
	// 	red_frac = ceil( ( ratio_red_up * 100 ) / 320 );
	// 	green_frac = ceil( ( ratio_green_down * 100 ) / 320 );
	// 	self.color = ( red_frac, green_frac, 0 );
	// }
	// else if ( frac < 0.2 && frac > 0.0 )
	// {
	// 	ratio_red_up = abs( frac - 1.0 );
	// 	ratio_green_down = 0;
	// 	red_frac = ceil( ( ratio_red_up * 100 ) / 320 );
	// 	green_frac = ratio_green_down;
	// 	self.color = ( red_frac, green_frac, 0 );
	// }
	if ( frac < 1.0 && frac > level.health_indicators_thresholds[ "damaged" ] )
	{
		red_frac = ceil( ( 255/320 ) * 100 ) / 100;
		green_frac = ceil( ( 255/320 ) * 100 ) / 100;
		self.color = ( red_frac, green_frac, 0 );
	}
	else if ( frac < 1.0 && frac > level.health_indicators_thresholds[ "hurt" ] )
	{
		green_frac = ceil( ( 100/320 ) * 100 ) / 100;
		self.color = ( 1, green_frac, 0 );
	}
	else if ( frac < 1.0 && frac >= level.health_indicators_thresholds[ "near_death" ] )
	{
		red_frac = ceil( ( 255/320 ) * 100 ) / 100;
		self.color = ( red_frac, 0, 0 );
	}
	else if ( frac <= level.health_indicators_thresholds[ "dead" ] )
	{
		self.alpha = 0;
	}
	else 
	{
		green_frac = ceil( ( 255 / 320 ) * 100 ) / 100;
		self.color = ( 0, green_frac, 0 );
	}
}

/*

( 0, 0, 255/255 ) == blue
( 0, 255/255, 0 ) == green
(255/255, 255/255, 0 ) == yellow
( 255/255, 100/255, 0 ) == orange
( 255/255, 0, 0 ) == red

100% == pure green
99%-60% yellow increase red
59%-21% orange decrease green
20%-1% red descrease green to 0
0% invisible alpha = 0
*/

is_player_valid( player, checkignoremeflag, ignore_laststand_players )
{
	if ( !isDefined( player ) )
	{
		return 0;
	}
	if ( !isalive( player ) )
	{
		return 0;
	}
	if ( !isplayer( player ) )
	{
		return 0;
	}
	if ( isDefined( player.is_zombie ) && player.is_zombie == 1 )
	{
		return 0;
	}
	if ( player.sessionstate == "spectator" )
	{
		return 0;
	}
	if ( player.sessionstate == "intermission" )
	{
		return 0;
	}
	if ( is_true( self.intermission ) )
	{
		return 0;
	}
	if ( !is_true( ignore_laststand_players ) )
	{
		if ( player player_is_in_laststand() )
		{
			return 0;
		}
	}
	if ( is_true( checkignoremeflag ) && player.ignoreme )
	{
		return 0;
	}
	if ( isDefined( level.is_player_valid_override ) )
	{
		return [[ level.is_player_valid_override ]]( player );
	}
	return 1;
}

player_is_in_laststand()
{
	if ( !is_true( self.no_revive_trigger ) && isDefined( self.revivetrigger ) )
	{
		return 1;
	}
	if ( is_true( self.laststand ) )
	{
		return 1;
	}
	return 0;
}