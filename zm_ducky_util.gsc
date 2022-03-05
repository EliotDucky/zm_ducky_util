#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;

#using scripts\zm\_zm_utility;

#namespace zm_util;

function nukeAllZombies(){
	//Based on Connor's Der Riese Declassified function
	a_ai_zombies = GetAITeamArray(level.zombie_team);
	zombie_marked_to_destroy = [];
	foreach(ai_zombie in a_ai_zombies)
	{
		ai_zombie.no_powerups = 1;
		ai_zombie.deathpoints_already_given = 1;
		if(isdefined(ai_zombie.ignore_nuke) && ai_zombie.ignore_nuke)
		{
			continue;
		}
		if(isdefined(ai_zombie.marked_for_death) && ai_zombie.marked_for_death)
		{
			continue;
		}
		if(isdefined(ai_zombie.nuke_damage_func))
		{
			ai_zombie thread [[ai_zombie.nuke_damage_func]]();
			continue;
		}
		if(zm_utility::is_magic_bullet_shield_enabled(ai_zombie))
		{
			continue;
		}
		ai_zombie.marked_for_death = 1;
		ai_zombie.nuked = 1;
		zombie_marked_to_destroy[zombie_marked_to_destroy.size] = ai_zombie;
	}
	foreach(zombie_to_destroy in zombie_marked_to_destroy)
	{
		if(!isdefined(zombie_to_destroy))
		{
			continue;
		}
		if(zm_utility::is_magic_bullet_shield_enabled(zombie_to_destroy))
		{
			continue;
		}
		zombie_to_destroy DoDamage(zombie_to_destroy.health, zombie_to_destroy.origin);
		if(!level flag::get("special_round"))
		{
			level.zombie_total++;
		}
	}
	corpse_array = GetCorpseArray();
	for ( i = 0; i < corpse_array.size; i++ )
	{
		if ( IsDefined( corpse_array[ i ] ) )
		{
			corpse_array[ i ] Delete();
		}
	}
}

/* Call on: Level
// Thread
// Params:
//	array<string> <lines>, list of lines to display
//  string [type], type of entry animation
//		"fade", "pulse"
//		"decode", 
//		"redact", "chyron" - BO3 Campaign, Requires LUA
//		"scale" (To-Do), "typewriter" (To-Do)
//	array<vector> [colours], list of colours each line should be
*/
function introText(lines, type="fade", colours=undefined, long_lines=undefined){
	//Using some of Connor's DRD stuff
	intro_txt = [];
	for(i = 0; i < lines.size; i++){
		txt = NewHudElem();
		txt.x = 40;
		txt.y = -110 + 25*i;
		txt.alignX = "left";
		txt.alignY = "bottom";
		txt.horzAlign = "left";
		txt.vertAlign = "bottom";
		txt.foreground = 1;
		txt.fontscale = 2;
		if(level.Splitscreen && !level.hidef){
			txt.fontscale = 2.75;
		}
		txt.alpha = 1;
		if(type == "fade"){
			txt.alpha = 0;
		}
		txt.color = (1,1,1);
		if(isdefined(colours) && isdefined(colours[i])){
			txt.color = colours[i];
		}
		txt.inUse = 0;
		//txt SetText(lines[i]);
		array::add(intro_txt, txt);
	}

	switch(type){
		case "decode":
			for(i = 0; i < intro_txt.size; i++){
				line = lines[i];
				txt = intro_txt[i];
				txt SetText(line);
				letter_time = 100; //milliseconds
				decay_start = letter_time * line.size + 1000*intro_txt.size;
				decay_time = 1500;
				txt SetCOD7DecodeFX(letter_time, decay_start, decay_time);
				wait(1.5);
			}
			wait(1.5);
			break;
		case "pulse":
			for(i = 0; i < intro_txt.size; i++){
				line = lines[i];
				txt = intro_txt[i];
				txt SetText(line);
				letter_time = 100; //milliseconds
				decay_start = letter_time * line.size + 3000;
				decay_time = 1500;
				txt SetPulseFX(letter_time, decay_start, decay_time);
				wait(1.5);
			}
			wait(1.5);
			break;
		case "scale":
			break;
		case "redact":
		case "chyron":
			if(lines.size >= 4){
				if(!isdefined(long_lines)){
					long_lines = lines;
				}
				if(lines.size < 5){
					array::add(lines, undefined);
					array::add(long_lines, undefined);
				}
				util::do_chyron_text(long_lines[0], lines[0],
					long_lines[1], lines[1], long_lines[2], lines[2],
					long_lines[3], lines[3], long_lines[4], lines[4]);
			}
			break;
		default:
			//case fade
			for(i = 0; i < intro_txt.size; i++){
				txt = intro_txt[i];
				txt SetText(lines[i]);
				txt FadeOverTime(1.5);
				txt.alpha = 1;
				wait(1.5);
			}
			break;
	}

	wait(1.5);
	foreach(txt in intro_txt){
		txt FadeOverTime(1.5);
		txt.alpha = 0;
		wait(1.5);
	}
	foreach(txt in intro_txt){
		txt Destroy();
	}
	return;
}

//returns 2D dictionary/array
//use for independently both weapon names and then kills required in prog_wpns
//call on level
function generateArraysFromCSV(csv_filename){
	num_rows = TableLookupRowCount(csv_filename);
	rows = [];
	for(i=0; i<num_rows; i++){
		rows[i] = [];
		rows[i] = TableLookupRow(csv_filename, i);
	}
	return rows;
}

//sort structs or ents by script_int
function orderEnts(ents){
	new_ents = [];
	for(i = 0; i<ents.size; i++){
		foreach(_ent in ents){
			if(isdefined(_ent.script_int) && _ent.script_int == i){
				array::add(new_ents, _ent);
			}
		}
	}
	return new_ents;
}
