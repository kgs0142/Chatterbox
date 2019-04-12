/// Starts initialisation for Chatterbox
/// This script should be called before chatterbox_init_add() and chatterbox_init_end()
///
/// @param fontDirectory     Directory to look in (relative to game_save_id) for Yarn .json files
///
/// Initialisation is only fully complete once chatterbox_init_end() is called

#region Internal Macro Definitions

#macro __CHATTERBOX_VERSION  "0.0.0"
#macro __CHATTERBOX_DATE     "2019/04/12"
#macro __CHATTERBOX_DEBUG    true

#macro __CHATTERBOX_ON_DIRECTX ((os_type == os_windows) || (os_type == os_xboxone) || (os_type == os_uwp) || (os_type == os_win8native) || (os_type == os_winphone))
#macro __CHATTERBOX_ON_OPENGL  !__CHATTERBOX_ON_DIRECTX
#macro __CHATTERBOX_ON_MOBILE  ((os_type == os_ios) || (os_type == os_android))

enum __CHATTERBOX_FILE
{
    FILENAME,     // 0
    NAME,         // 1
    __SIZE        // 2
}

enum __CHATTERBOX_DATA
{
    __SIZE        // 0
}

enum __CHATTERBOX_HOST
{
    __SECTION0,       // 0
    LEFT,             // 1
    TOP,              // 2
    RIGHT,            // 3
    BOTTOM,           // 4
    FILENAME,         // 5
    TITLE,            // 6
    
    __SECTION1,       // 7
    BODY,             // 8
    LINE,             // 9
    
    __SECTION2,       //10
    PRIMARY_SCRIBBLE, //11
    SCRIBBLES,        //11
    BUTTONS,          //12
    INSTANCES,        //13
    
    __SIZE            //14
}

//enum __CHATTERBOX_VM
//{
//    PORTRAIT,
//    TEXT,
//    DELAY,
//    WAIT,
//    OPTION,
//    REDIRECT,
//    ACTION,
//    VARIABLE_SET,
//    __SIZE
//}

#macro __CHATTERBOX_VM_TEXT     "text"
#macro __CHATTERBOX_VM_POTRAIT  "portrait"
#macro __CHATTERBOX_VM_DELAY    "delay"
#macro __CHATTERBOX_VM_WAIT     "wait"
#macro __CHATTERBOX_VM_OPTION   "option"
#macro __CHATTERBOX_VM_REDIRECT "redirect"
#macro __CHATTERBOX_VM_ACTION   "action"
#macro __CHATTERBOX_VM_IF       "if begin"
#macro __CHATTERBOX_VM_ELSE     "else"
#macro __CHATTERBOX_VM_ELSEIF   "elseif"
#macro __CHATTERBOX_VM_IF_END   "end"
#macro __CHATTERBOX_VM_SHORTCUT "shortcut"

enum __CHATTERBOX
{
    __SIZE        // 0
}

#endregion

if ( variable_global_exists("__chatterbox_init_complete") )
{
    show_error("Chatterbox:\nchatterbox_init_start() should not be called twice!\n ", false);
    exit;
}

show_debug_message("Chatterbox: Welcome to Chatterbox by @jujuadams! This is version " + __CHATTERBOX_VERSION + ", " + __CHATTERBOX_DATE);

var _font_directory = argument0;

if (__CHATTERBOX_ON_MOBILE)
{
    if (_font_directory != "")
    {
        show_debug_message("Chatterbox: Included Files work a bit strangely on iOS and Android. Please use an empty string for the font directory and place Yarn .json files in the root of Included Files.");
        show_error("Chatterbox:\nGameMaker's Included Files work a bit strangely on iOS and Android.\nPlease use an empty string for the font directory and place Yarn .json files in the root of Included Files.\n ", true);
        exit;
    }
}
else
{
    //Fix the font directory name if it's weird
    var _char = string_char_at(_font_directory, string_length(_font_directory));
    if (_char != "\\") && (_char != "/") _font_directory += "\\";
}

//Check if the directory exists
if ( !directory_exists(_font_directory) )
{
    show_debug_message("Chatterbox: WARNING! Font directory \"" + string(_font_directory) + "\" could not be found in \"" + game_save_id + "\"!");
}

//Declare global variables
global.__chatterbox_font_directory = _font_directory;
global.__chatterbox_file_data      = ds_map_create();
global.__chatterbox_data           = ds_map_create();
global.__chatterbox_init_complete  = false;
global.__chatterbox_open_file      = "";