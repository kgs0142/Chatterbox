/// @param substringList

function __chatterbox_compile(_substring_list)
{
	var _branch_stack = ds_list_create();
    var _sub = 0;
    repeat(ds_list_size(_substring_list))
	{
	    var _substring_array  = _substring_list[| _sub];
	    var _string           = _substring_array[0];
	    var _substring_type   = _substring_array[1];
	    var _substring_line   = _substring_array[2];
	    var _substring_indent = _substring_array[3];
                
        __chatterbox_trace(string_format(_substring_indent, 4, 0), ": " + _string, "    ", _substring_type, "    ", _substring_line);
        
        ++_sub;
    }
    
    ds_list_destroy(_branch_stack);
}