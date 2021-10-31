
#include maps/mp/_utility;
#include common_scripts/utility;

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

OBJ_ADD_ENT( ent, type, offset, visibility_data )
{
	if ( !isDefined( self.entities ) )
	{
		self.entities = [];
	}
	if ( !isDefined( self.entities[ ent.name ] ) )
	{
		self.entities[ ent.name ] = spawnStruct();
	}
	self.entities[ ent.name ].target_ent = ent;
	if ( isDefined( visibility_data[ "team_list" ] ) )
	{
		self.entities[ ent.name ].team_elems = [];
		foreach ( team in visibility_data[ "team_list" ] )
		{
			if ( team == "all" )
			{
				team = undefined;
			}
			switch ( type )
			{
				case "text":
					self.entities[ ent.name ].team_elems[ team ] = createserverfontstring( "default", 4, team );
					//self.entities[ ent.name ].team_elems[ team ] thread OBJ_UPDATE_TEXT();
					//self.entities[ ent.name ].team_elems[ team ] thread OBJ_PREVENT_OVERFLOW();
					break;
				case "bar":
					self.entities[ ent.name ].team_elems[ team ] = createserverbar( ( 1, 1, 1 ), 1, 1, undefined, team );
					//self.entities[ ent.name ].team_elems[ team ] thread OBJ_UPDATE_BAR();
					break;
				case "icon":
					self.entities[ ent.name ].team_elems[ team ] = createservericon( undefined, 1, 1, team );
					//self.entities[ ent.name ].team_elems[ team ] thread OBJ_UPDATE_ICON();
					break;
				case "timer":
					self.entities[ ent.name ].team_elems[ team ] = createservertimer( "default", 4, team );
					//self.entities[ ent.name ].team_elems[ team ] thread OBJ_UPDATE_TIMER();
					break;
				case "value":
					self.entities[ ent.name ].team_elems[ team ] = createserverfontstring( "default", 4, team );
					//self.entities[ ent.name ].team_elems[ team ] thread OBJ_UPDATE_VALUE();
					break;
			}
			self.entities[ ent.name ].team_elems[ team ].archived = 1;
			self.entities[ ent.name ].team_elems[ team ].x = ent.origin[ 0 ] + offset[ 0 ];
			self.entities[ ent.name ].team_elems[ team ].y = ent.origin[ 1 ] + offset[ 1 ];
			self.entities[ ent.name ].team_elems[ team ].z = ent.origin[ 2 ] + offset[ 2 ];
			self.entities[ ent.name ].team_elems[ team ].alpha = 1;
			self.entities[ ent.name ].team_elems[ team ] setWayPoint( 0, "", true, true );
			self.entities[ ent.name ].team_elems[ team ] setTargetEnt( ent );
		}
	}
	else if ( isDefined( visibility_data[ "player_list" ) )
	{
		self.entities[ ent.name ].player_elems = [];
		foreach ( player in visibility_data[ "player_list" ] )
		{
			switch ( type )
			{
				case "text":
					self.entities[ ent.name ].player_elems[ player.name ] = player createfontstring( "default", 4 );
					//self.entities[ ent.name ].player_elems[ player.name ] thread OBJ_UPDATE_TEXT();
					//self.entities[ ent.name ].player_elems[ player.name ] thread OBJ_PREVENT_OVERFLOW();
					break;
				case "bar":
					self.entities[ ent.name ].player_elems[ player.name ] = player createbar( ( 1, 1, 1 ), 1, 1 );
					//self.entities[ ent.name ].player_elems[ player.name ] thread OBJ_UPDATE_BAR();
					break;
				case "icon":
					self.entities[ ent.name ].player_elems[ player.name ] = player createicon( undefined, 1, 1 );
					//self.entities[ ent.name ].player_elems[ player.name ] thread OBJ_UPDATE_ICON();
					break;
				case "timer":
					self.entities[ ent.name ].player_elems[ player.name ] = player createclienttimer( "default", 4 );
					//self.entities[ ent.name ].player_elems[ player.name ] thread OBJ_UPDATE_TIMER();
					break;
				case "value":
					self.entities[ ent.name ].player_elems[ player.name ] = player createfontstring( "default", 4 );
					//self.entities[ ent.name ].player_elems[ player.name ] thread OBJ_UPDATE_VALUE();
					break;
			}
			self.entities[ ent.name ].player_elems[ player.name ].archived = 1;
			self.entities[ ent.name ].player_elems[ player.name ].x = ent.origin[ 0 ] + offset[ 0 ];
			self.entities[ ent.name ].player_elems[ player.name ].y = ent.origin[ 1 ] + offset[ 1 ];
			self.entities[ ent.name ].player_elems[ player.name ].z = ent.origin[ 2 ] + offset[ 2 ];
			self.entities[ ent.name ].player_elems[ player.name ].alpha = 1;
			self.entities[ ent.name ].player_elems[ player.name ] setWayPoint( 0, "", true, true );
			self.entities[ ent.name ].player_elems[ player.name ] setTargetEnt( ent );
		}
	}
	self thread OBJ_ENT_DEATH( ent );
}

OBJ_REMOVE_ENT( ent )
{
	if ( !isDefined( self.entities[ ent.name ] ) )
	{
		return;
	}
	self.entities[ ent.name ] notify( "destroy_hud_ent" );
}

OBJ_ENT_DEATH( ent )
{
	self.entities[ ent.name ] waittill( "destroy_hud_ent" );
	if ( isDefined( self.entities[ ent.name ].player_elems ) )
	{
		foreach ( player_name in getArrayKeys( self.entities[ ent.name ].player_elems ) )
		{
			self.entities[ ent.name ].player_elems[ player_name ] destroy();
		}
	}
	else if ( isDefined( self.entities[ ent.name ].team_elems ) )
	{
		foreach ( team in getArrayKeys( self.entities[ ent.name ].team_elems ) )
		{
			self.entities[ ent.name ].player_elems[ team ] destroy();
		}
	}
	self.entities[ ent.name ].target_ent = undefined;
	arrayRemoveIndex( self.entities, ent.name );
}

on_player_connect()
{
	while ( true )
	{
		level waittill( "connected", player );
		level.custom_objectives[ "overhead_health_bar" ] OBJ_ADD_ENT( player, "bar", ( 0, 0, 54 ), "all" );
		level.custom_objectives[ "overhead_health_value" ] OBJ_ADD_ENT( player, "value", ( 0, 0, 64 ), "all" );
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
			OBJ_REMOVE( key );
		}
	}
}