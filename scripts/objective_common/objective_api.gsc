
//checked includes match cerberus output
#include maps/mp/gametypes/_deathicons;
#include maps/mp/gametypes/_globallogic_utils;
#include maps/mp/_utility;
#include common_scripts/utility;

init() //checked matches cerberus output
{
	if ( !isDefined( level.ragdoll_override ) )
	{
		level.ragdoll_override = ::ragdoll_override;
	}
	if ( !level.teambased )
	{
		return;
	}
	precacheshader( "headicon_dead" );
	level thread onplayerconnect();
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player.selfdeathicons = [];
	}
}

updatedeathiconsenabled() //checked matches cerberus output
{
}

adddeathicon( entity, dyingplayer, team, timeout ) //checked matches cerberus output
{
	if ( !level.teambased )
	{
		return;
	}
	iconorg = entity.origin;
	dyingplayer endon( "spawned_player" );
	dyingplayer endon( "disconnect" );
	wait 0.05;
	maps/mp/gametypes/_globallogic_utils::waittillslowprocessallowed();
	/*
/#
	assert( isDefined( level.teams[ team ] ) );
#/
	*/
	if ( getDvar( "ui_hud_showdeathicons" ) == "0" )
	{
		return;
	}
	if ( level.hardcoremode )
	{
		return;
	}
	if ( isDefined( self.lastdeathicon ) )
	{
		self.lastdeathicon destroy();
	}
	newdeathicon = newteamhudelem( team );
	newdeathicon.x = iconorg[ 0 ];
	newdeathicon.y = iconorg[ 1 ];
	newdeathicon.z = iconorg[ 2 ] + 54;
	newdeathicon.alpha = 0.61;
	newdeathicon.archived = 1;
	if ( level.splitscreen )
	{
		newdeathicon setshader( "headicon_dead", 14, 14 );
	}
	else
	{
		newdeathicon setshader( "headicon_dead", 7, 7 );
	}
	newdeathicon setwaypoint( 1 );
	self.lastdeathicon = newdeathicon;
	newdeathicon thread destroyslowly( timeout );
}

destroyslowly( timeout ) //checked matches cerberus output
{
	self endon( "death" );
	wait timeout;
	self fadeovertime( 1 );
	self.alpha = 0;
	wait 1;
	self destroy();
}

ragdoll_override( idamage, smeansofdeath, sweapon, shitloc, vdir, vattackerorigin, deathanimduration, einflictor, ragdoll_jib, body ) //checked matches cerberus output
{
	if ( smeansofdeath == "MOD_FALLING" && self isonground() == 1 )
	{
		body startragdoll();
		if ( !isDefined( self.switching_teams ) )
		{
			thread maps/mp/gametypes/_deathicons::adddeathicon( body, self, self.team, 5 );
		}
		return 1;
	}
	return 0;
}


init() //checked matches cerberus output
{
	if ( level.createfx_enabled || sessionmodeiszombiesgame() )
	{
		return;
	}
	if ( getDvar( "scr_drawfriend" ) == "" )
	{
		setdvar( "scr_drawfriend", "0" );
	}
	level.drawfriend = getDvarInt( "scr_drawfriend" );
	/*
/#
	assert( isDefined( game[ "headicon_allies" ] ), "Allied head icons are not defined.  Check the team set for the level." );
#/
/#
	assert( isDefined( game[ "headicon_axis" ] ), "Axis head icons are not defined.  Check the team set for the level." );
#/
	*/
	precacheheadicon( game[ "headicon_allies" ] );
	precacheheadicon( game[ "headicon_axis" ] );
	level thread onplayerconnect();
	for ( ;; )
	{
		updatefriendiconsettings();
		wait 5;
	}
}

onplayerconnect() //checked matches cerberus output
{
	for ( ;; )
	{
		level waittill( "connecting", player );
		player thread onplayerspawned();
		player thread onplayerkilled();
	}
}

onplayerspawned() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread showfriendicon();
	}
}

onplayerkilled() //checked matches cerberus output
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "killed_player" );
		self.headicon = "";
	}
}

showfriendicon() //checked matches cerberus output
{
	if ( level.drawfriend )
	{
		team = self.pers[ "team" ];
		self.headicon = game[ "headicon_" + team ];
		self.headiconteam = team;
	}
}

updatefriendiconsettings() //checked matches cerberus output
{
	drawfriend = getDvarFloat( "scr_drawfriend" );
	if ( level.drawfriend != drawfriend )
	{
		level.drawfriend = drawfriend;
		updatefriendicons();
	}
}

updatefriendicons()
{
	players = level.players;
	for ( i = 0; i < players.size; i++ )
	{
		player = players[ i ];
		if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] != "spectator" && player.sessionstate == "playing" )
		{
			if ( level.drawfriend )
			{
				team = self.pers[ "team" ];
				self.headicon = game[ "headicon_" + team ];
				self.headiconteam = team;
				break;
			}
			players = level.players;
			for ( j = 0; i < players.size; j++ )
			{
				player = players[ j ];
				if ( isDefined( player.pers[ "team" ] ) && player.pers[ "team" ] != "spectator" && player.sessionstate == "playing" )
				{
					player.headicon = "";
				}
			}
		}
		i++;
	}
}

//checked includes match cerberus output
#include common_scripts/utility;

init() //checked matches cerberus output
{
	if ( isDefined( level.initedentityheadicons ) )
	{
		return;
	}
	if ( level.createfx_enabled )
	{
		return;
	}
	level.initedentityheadicons = 1;
	/*
/#
	assert( isDefined( game[ "entity_headicon_allies" ] ), "Allied head icons are not defined.  Check the team set for the level." );
#/
/#
	assert( isDefined( game[ "entity_headicon_axis" ] ), "Axis head icons are not defined.  Check the team set for the level." );
#/
	*/
	precacheshader( game[ "entity_headicon_allies" ] );
	precacheshader( game[ "entity_headicon_axis" ] );
	if ( !level.teambased )
	{
		return;
	}
	level.entitieswithheadicons = [];
}

setentityheadicon( team, owner, offset, icon, constant_size ) //checked changed to match cerberus output
{
	if ( !level.teambased && !isDefined( owner ) )
	{
		return;
	}
	if ( !isDefined( constant_size ) )
	{
		constant_size = 0;
	}
	if ( !isDefined( self.entityheadiconteam ) )
	{
		self.entityheadiconteam = "none";
		self.entityheadicons = [];
	}
	if ( level.teambased && !isDefined( owner ) )
	{
		if ( team == self.entityheadiconteam )
		{
			return;
		}
		self.entityheadiconteam = team;
	}
	if ( isDefined( offset ) )
	{
		self.entityheadiconoffset = offset;
	}
	else
	{
		self.entityheadiconoffset = ( 0, 0, 0 );
	}
	if ( isDefined( self.entityheadicons ) )
	{
		for ( i = 0; i < self.entityheadicons.size; i++ )
		{
			if ( isDefined( self.entityheadicons[ i ] ) )
			{
				self.entityheadicons[ i ] destroy();
			}
		}
	}
	self.entityheadicons = [];
	self notify( "kill_entity_headicon_thread" );
	if ( !isDefined( icon ) )
	{
		icon = game[ "entity_headicon_" + team ];
	}
	if ( isDefined( owner ) && !level.teambased )
	{
		if ( !isplayer( owner ) )
		{
			/*
/#
			assert( isDefined( owner.owner ), "entity has to have an owner if it's not a player" );
#/
			*/
			owner = owner.owner;
		}
		owner updateentityheadclienticon( self, icon, constant_size );
	}
	else if ( isDefined( owner ) && team != "none" )
	{
		owner updateentityheadteamicon( self, team, icon, constant_size );
	}
	self thread destroyheadiconsondeath();
}

updateentityheadteamicon( entity, team, icon, constant_size ) //checked matches cerberus output
{
	headicon = newteamhudelem( team );
	headicon.archived = 1;
	headicon.x = entity.entityheadiconoffset[ 0 ];
	headicon.y = entity.entityheadiconoffset[ 1 ];
	headicon.z = entity.entityheadiconoffset[ 2 ];
	headicon.alpha = 0.8;
	headicon setshader( icon, 6, 6 );
	headicon setwaypoint( constant_size );
	headicon settargetent( entity );
	entity.entityheadicons[ entity.entityheadicons.size ] = headicon;
}

updateentityheadclienticon( entity, icon, constant_size ) //checked matches cerberus output
{
	headicon = newclienthudelem( self );
	headicon.archived = 1;
	headicon.x = entity.entityheadiconoffset[ 0 ];
	headicon.y = entity.entityheadiconoffset[ 1 ];
	headicon.z = entity.entityheadiconoffset[ 2 ];
	headicon.alpha = 0.8;
	headicon setshader( icon, 6, 6 );
	headicon setwaypoint( constant_size );
	headicon settargetent( entity );
	entity.entityheadicons[ entity.entityheadicons.size ] = headicon;
}

destroyheadiconsondeath() //checked changed to match cerberus output
{
	self waittill_any( "death", "hacked" );
	for ( i = 0; i < self.entityheadicons.size; i++ )
	{
		if ( isDefined( self.entityheadicons[ i ] ) )
		{
			self.entityheadicons[ i ] destroy();
		}
	}
}

destroyentityheadicons() //checked changed to match cerberus output
{
	if ( isDefined( self.entityheadicons ) )
	{
		for ( i = 0; i < self.entityheadicons.size; i++ )
		{
			if ( isDefined( self.entityheadicons[ i ] ) )
			{
				self.entityheadicons[ i ] destroy();
			}
		}
	}
}

updateentityheadiconpos( headicon ) //checked matches cerberus output
{
	headicon.x = self.origin[ 0 ] + self.entityheadiconoffset[ 0 ];
	headicon.y = self.origin[ 1 ] + self.entityheadiconoffset[ 1 ];
	headicon.z = self.origin[ 2 ] + self.entityheadiconoffset[ 2 ];
}

