#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
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
	for(;;)
	{
		level waittill( "connected", player );
		waittillframeend;
		level.custom_objectives[ "overhead_health_indicator" ] HEALTH_INDICATOR_ADD_PLAYER( player, "all" );
		player thread on_player_disconnect();
	}
}

on_player_disconnect()
{
	for(;;)
	{
		guid = self getGUID();
		self waittill( "disconnect" );
		hud_keys = getArrayKeys( level.custom_objectives );
		foreach ( key in hud_keys )
		{
			index = level.custom_objectives[ key ] OBJ_FIND_ENT_INDEX( guid );
			level.custom_objectives[ key ].players[ index ] notify( "destroy_hud_ent" );
			print( guid );
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
	foreach ( player in self.players )
	{
		self OBJ_REMOVE_PLAYER( player getGUID() );
	}
	self.players = undefined;
	arrayRemoveIndex( level.custom_objectives, name, true );
}

OBJ_FIND_ENT_INDEX( guid )
{
	index = 0;
	foreach ( elem in self.players )
	{
		if ( elem.guid == guid )
		{
			return index;
		}
		index++;
	}
}

OBJ_ALLOCATE_ENT( player )
{
	return self.players.size;
}

HEALTH_INDICATOR_ADD_PLAYER( player, team )
{
	if ( !isDefined( self.players ) )
	{
		self.players = [];
	}
	if ( team == "all" )
	{
		elem_team = undefined;
	}
	else
	{
		elem_team = team;
	}
	index = self OBJ_ALLOCATE_ENT( player );
	self.players[ index ] = OBJ_CREATE_SERVER_HEALTH_INDICATOR( elem_team );
	self.players[ index ].guid = player getGUID();
	self.players[ index ].target_ent = OBJ_SPAWN_ENT_ON_ENT( player, level.health_indicator_offset );
	self.players[ index ].color = ( 0, 1, 0 );
	self.players[ index ] setShader( "white", level.health_indicator_size, level.health_indicator_size );
	self.players[ index ] setWayPoint( false );
	self.players[ index ] setTargetEnt( self.players[ index ].target_ent );
	player thread HEALTH_INDICATOR_UPDATE( self.players[ index ] );
	self thread OBJ_ENT_DEATH( player getGUID() );
}

OBJ_REMOVE_PLAYER( guid )
{
	index = self OBJ_FIND_ENT_INDEX( guid );
	self.players[ index ] notify( "destroy_hud_ent" );
}

OBJ_ENT_DEATH( guid )
{
	index = self OBJ_FIND_ENT_INDEX( guid );
	self.players[ index ] waittill( "destroy_hud_ent" );
	self.players[ index ] setShader( "white", level.health_indicator_size, level.health_indicator_size );
	self.players[ index ] clearTargetEnt();
	self.players[ index ].guid = undefined;
	self.players[ index ].target_ent unLink();
	self.players[ index ].target_ent delete();
	self.players[ index ] destroy();
	arrayRemoveIndex( self.players, index );
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