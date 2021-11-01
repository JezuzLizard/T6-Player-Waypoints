
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include scripts/objective_common/objective_util;

main()
{
	level.health_bar_ent_height_offset = 80;
	level.health_bar_height = 4;
	level.health_bar_width = 144;
	OBJ_ADD_NEW( "overhead_health_bar", -1 );
	OBJ_ADD_NEW( "overhead_health_value", -1 );
	OBJ_ADD_NEW( "overhead_health_icon", -1 );
	OBJ_ADD_NEW( "overhead_health_barframe", -1 );
	level thread on_player_connect();
	level thread on_player_disconnect();
	level waittill( "connected", player );
	bot = addTestClient();
	waittillframeend;
	visibility_data = [];
	visibility_data[ "team_list" ] = array( "all" );
	level.custom_objectives[ "overhead_health_bar" ] OBJ_ADD_ENT( bot, "bar", undefined, visibility_data );
	level.custom_objectives[ "overhead_health_barframe" ] OBJ_ADD_ENT( bot, "bar", undefined, visibility_data );
	elem_ent = OBJ_SPAWN_ENT_ON_ENT( bot, undefined, ( 0, 0, 80 ) );
	elem_ent.name = "overhead_elem";
	barframe = OBJ_GET_REF( "overhead_health_barframe", bot, "all" );
	barframe.width = 144;
	barframe.height = 4;
	barframe.color = ( 1, 1, 1 );
	barframe.shader = "progress_bar_fg";
	barframe setShader( barframe.shader, 144, 4 );
	barframe setWayPoint( false );
	barframe setTargetEnt( elem_ent );
	bar = OBJ_GET_REF( "overhead_health_bar", bot, "all" );
	bar.width = 144;
	bar.height = 4;
	bar.color = ( 1, 1, 1 );
	bar.shader = "progress_bar_fill";
	bar setShader( "progress_bar_fill", 144, 4 );
	bar setWayPoint( false );
	bar setTargetEnt( elem_ent );
	bot thread health_bar_hud( bar, elem_ent );
}

OBJ_UPDATE_BAR( barfrac, elem_ent )
{
	barwidth = int( ( self.width * barfrac ) + 0.5 );
	if ( !barwidth )
	{
		barwidth = 1;
	}
	self.frac = barfrac;
	self setshader( self.shader, barwidth, self.height );
	self setWayPoint( false );
	self setTargetEnt( elem_ent );
	self.rateofchange = rateofchange;
	self.lastupdatetime = getTime();
}

health_bar_hud( health_bar, elem_ent )
{
	self endon( "disconnect" );
	flag_wait( "initial_blackscreen_passed" );
	health_bar.hidewheninmenu = 1;
	while ( true )
	{
		if ( isDefined( self.e_afterlife_corpse ) )
		{
			if ( health_bar.alpha != 0 )
			{
				health_bar.alpha = 0;
			}
			wait 0.05;
			continue;
		}
		if ( health_bar.alpha != 1 )
		{
			health_bar.alpha = 1;
		}
		health_bar OBJ_UPDATE_BAR( self.health / self.maxhealth, elem_ent );
		wait 0.05;
	}
}
