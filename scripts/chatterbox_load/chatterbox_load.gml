/// Loads a Yarn file (either .yarn or .json) for use with Chatterbox
///
/// To find out more about Chatterbox's scripting language, "Yarn", please read the __chatterbox_syntax()
///
/// @param filename  Name of the file to add

function chatterbox_load(_filename)
{
    if (!is_string(_filename))
    {
        __chatterbox_error("Files should be loaded using their filename as a string.\n(Input was an invalid datatype)");
        return undefined;
    }
    
    //Fix the font directory name if it's weird
    var _font_directory = CHATTERBOX_SOURCE_DIRECTORY;
    
    //This got fix after 2.3.1
    //if (__CHATTERBOX_ON_WEB)
    //{
    //    _font_directory = "datafiles\\" + _font_directory;
    //    show_debug_message("Load: " + (_font_directory + _filename));
    //}
    
    var _char = string_char_at(_font_directory , string_length(_font_directory ));
    if (_char != "\\") && (_char != "/") _font_directory += "\\";

    if (!file_exists(_font_directory + _filename))
    {
        __chatterbox_error("\"", _filename, "\" could not be found");
        return undefined;
    }
    
    //var buffer = buffer_load(_font_directory + _filename);
    //show_debug_message("Buffer Size: " + string(buffer_get_size(buffer)));
    
    global.totalLoadFileCounts++;
    
    var asyncBuffer = buffer_create(32, buffer_grow, 1);
    
    DoLaterAsync("Save/Load",
                ["id", buffer_load_async(asyncBuffer, _font_directory + _filename, 0, -1)],
                function (datas)
                {
                    //show_debug_message(datas[0]);
                    //show_debug_message(json_encode(async_load));
                    //show_debug_message(buffer_read(datas[2], buffer_string));
                    
                    if ds_map_find_value(async_load, "status") == false
                    {
                        show_debug_message("Load failed!");
                    }
                    else
                    {
                        global.loadFileCounts++;
                        
                        show_debug_message("Async Load Success!");
        
                        //var old_tell = buffer_tell(datas[2]);
                        //buffer_seek(datas[2], buffer_seek_start, 0);
                        //var fileContent = buffer_read(datas[2], buffer_string);
                        //buffer_seek(datas[2], buffer_seek_start, old_tell);
    
                        ////
                        //show_debug_message("fileContent: " + fileContent);
                        
                        chatterbox_load_from_buffer(datas[1], datas[2]);
                    }
                },
                ["Save/Load Result:", _filename, asyncBuffer]);
    
    //return chatterbox_load_from_buffer(_filename, buffer);
}