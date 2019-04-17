/// @param chatterbox
/// @param optionIndex

var _chatterbox     = argument0;
var _selected_index = argument1;

var _node_title    = _chatterbox[| __CHATTERBOX.TITLE       ];
var _filename      = _chatterbox[| __CHATTERBOX.FILENAME    ];
var _child_list    = _chatterbox[| __CHATTERBOX.CHILD_LIST  ];
var _variables_map = __CHATTERBOX_VARIABLE_MAP;



if (_node_title == undefined)
{
    //If the node title is <undefined> then this chatterbox has been stopped
    exit;
}



//VM state
var _key                   = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
var _indent                = 0;
var _indent_bottom_limit   = undefined;
var _text_instruction      = 0;
var _instruction           = global.__chatterbox_goto[? _key ];
var _end_instruction       = -1;
var _scan_from_text        = false;
var _scan_from_option      = false;
var _scan_from_option_end  = false;
var _if_state              = true;
var _permit_greater_indent = false;



var _evaluate = false;
if (is_real(_selected_index))
{
    #region Advance to the next instruction if the player has selected an option
    
    var _array = undefined;
    var _count = 0;
    var _size = ds_list_size(_child_list);
    for(var _i = 0; _i < _size; _i++)
    {
        var _array = _child_list[| _i ];
        if (_array[ __CHATTERBOX_CHILD.TYPE ] == CHATTERBOX_OPTION)
        {
            if (_count == _selected_index) break;
            _count++;
        }
    }
    
    if ((_i >= _size) || !is_array(_array))
    {
        if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox: Selected option (" + string(_selected_index) + ") could not be found. Total number of options is " + string(chatterbox_get_child_count(_chatterbox, CHATTERBOX_OPTION)));
        return false;
    }
    
    var _instruction     = _array[ __CHATTERBOX_CHILD.INSTRUCTION_START ];
    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set instruction = " + string(_instruction));
    var _end_instruction = _array[ __CHATTERBOX_CHILD.INSTRUCTION_END ];
    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set end instruction = " + string(_end_instruction));
    
    _scan_from_option = true;
    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set _scan_from_option=" + string(_scan_from_option));
    
    var _array  = global.__chatterbox_vm[| _instruction ];
    if (!is_array(_array))
    {
        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Non-array: \"" + string(_instruction_array) + "\"");
    }
    else
    {
        _indent = _array[ __CHATTERBOX_INSTRUCTION.INDENT ];
    }
    
    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
    
    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Starting scan from option index=" + string(_selected_index) + ", \"" + string(_array[ __CHATTERBOX_INSTRUCTION.CONTENT ]) + "\"");
    
    //Advance to the next instruction
    _instruction++;
    
    _evaluate = true;
    
    #endregion
}



if (_evaluate)
{
    ds_list_clear(_child_list);
    
    #region Run virtual machine
    
    var _break = false;
    repeat(9999)
    {
        var _continue = false;
            _scan_from_option_end = false;
        
        var _instruction_array   = global.__chatterbox_vm[| _instruction ];
        if (!is_array(_instruction_array))
        {
            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox:   Non-array: \"" + string(_instruction_array) + "\"");
            _instruction++;
            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox:     <- Continue <-");
            continue;
        }
        
        var _instruction_type    = _instruction_array[ __CHATTERBOX_INSTRUCTION.TYPE    ];
        var _instruction_indent  = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT  ];
        var _instruction_content = _instruction_array[ __CHATTERBOX_INSTRUCTION.CONTENT ];
        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   " + _instruction_type + ":   " + string(_instruction_indent) + ":   " + string(_instruction_content));
        
        if (_scan_from_option)
        {
            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_option == " + string(_scan_from_option));
            
            if (_instruction == _end_instruction)
            {
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction " + string(_instruction) + " == end " + string(_end_instruction));
                _indent = _instruction_indent;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set indent = " + string(_indent));
                _scan_from_option = false;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set _scan_from_option=" + string(_scan_from_option));
                _scan_from_option_end = true;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set _scan_from_option_end=" + string(_scan_from_option_end));
            }
            else if (_instruction > _end_instruction)
            {
                show_error("Chatterbox:\nVM instruction overstepped bounds!\n ", true);
                _instruction = _end_instruction;
                continue;
            }
        }
        
        #region Identation behaviours
        
        if (_instruction_indent < _indent)
        {
            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction indent " + string(_instruction_indent) + " < indent " + string(_indent));
            if (!_scan_from_text)
            {
                _indent = _instruction_indent;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set indent = " + string(_indent));
            }
            else if ((_indent_bottom_limit != undefined) && (_instruction_indent < _indent_bottom_limit))
            {
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       instruction indent " + string(_instruction_indent) + " < _indent_bottom_limit " + string(_indent_bottom_limit));
                _break = true;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   -> BREAK ->");
            }
        }
        else if (_instruction_indent > _indent)
        {
            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction indent " + string(_instruction_indent) + " > indent " + string(_indent));
            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       _permit_greater_indent=" + string(_permit_greater_indent));
            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       indent difference=" + string(_instruction_indent - _indent));
            if (_permit_greater_indent && ((_instruction_indent - _indent) <= CHATTERBOX_TAB_INDENT_SIZE))
            {
                _indent = _instruction_indent;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":         Set indent = " + string(_indent));
            }
            else
            {
                _continue = true;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
            }
        }
        
        _permit_greater_indent = false;
        
        #endregion
        
        #region Handle branches
        
        if (!_break && !_continue)
        {
            switch(_instruction_type)
            {
                case __CHATTERBOX_VM_IF:
                case __CHATTERBOX_VM_ELSEIF:
                    //Only evaluate the if-statement if we passed the previous check
                    if (_instruction_type == __CHATTERBOX_VM_IF)
                    {
                        if (!_if_state)
                        {
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _if_state == " + string(_if_state));
                            _continue = true;
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                            break;
                        }
                    }
                    
                    //Only evaluate the elseif-statement if we failed the previous check
                    if (_instruction_type == __CHATTERBOX_VM_ELSEIF)
                    {
                        if (_if_state)
                        {
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _if_state == " + string(_if_state));
                            _if_state = false;
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Set _if_state = " + string(_if_state));
                            _continue = true;
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                            break;
                        }
                    }
                    
                    var _result = __chatterbox_evaluate(_chatterbox, _instruction_content);
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   Evaluator returned \"" + string(_result) + "\" (" + typeof(_result) + ")");
                    
                    if (!is_bool(_result) && !is_real(_result))
                    {
                        show_debug_message("Chatterbox: WARNING! Expression evaluator returned an invalid datatype (" + typeof(_result) + ")");
                        var _if_state = false;
                    }
                    else
                    {
                        var _if_state = _result;
                    }
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   Set _if_state = " + string(_if_state));
                    
                    if (_if_state)
                    {
                        _permit_greater_indent = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   Set _permit_greater_indent = " + string(_permit_greater_indent));
                    }
                break;
                
                case __CHATTERBOX_VM_ELSE:
                    _if_state = !_if_state;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Invert _if_state = " + string(_if_state));
                    
                    if (_if_state)
                    {
                        _permit_greater_indent = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _permit_greater_indent = " + string(_permit_greater_indent));
                    }
                break;
                
                case __CHATTERBOX_VM_IF_END:
                    _if_state = true;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _if_state = " + string(_if_state));
                break;
            }
            
        }
        
        if (!_break && !_continue)
        {
            //If we're inside a branch that has been evaluated as <false> then keep skipping until we close the branch
            if (!_if_state)
            {
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   _if_state == " + string(_if_state));
                _continue = true;
                if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
            }
        }
        
        #endregion
        
        if (!_break && !_continue)
        {
            var _new_option      = false;
            var _new_option_text = "";
            switch(_instruction_type)
            {
                case __CHATTERBOX_VM_WAIT:
                    #region Wait
                    
                    if (_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                        _break = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   -> BREAK ->");
                        break;
                    }
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_TEXT:
                    #region Text
                    
                    if (_scan_from_text && CHATTERBOX_SINGLETON_TEXT)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                        _break = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   -> BREAK ->");
                        break;
                    }
                    
                    _scan_from_text = true;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _scan_from_text = " + string(_scan_from_text));
                    
                    var _new_array = array_create(__CHATTERBOX_CHILD.__SIZE);
                    _new_array[@ __CHATTERBOX_CHILD.STRING            ] = _instruction_content[0];
                    _new_array[@ __CHATTERBOX_CHILD.TYPE              ] = CHATTERBOX_TEXT;
                    _new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_START ] = undefined;
                    _new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_END   ] = undefined;
                    ds_list_add(_child_list, _new_array);
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Created text");
                    
                    var _text_instruction = _instruction; //Record the instruction position of the text
                    
                    _indent_bottom_limit = _instruction_indent;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _indent_for_options = " + string(_indent_bottom_limit));
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_REDIRECT:
                    #region Redirect
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                    if (_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   -> BREAK ->");
                        _break = true;
                        break;
                    }
                    else
                    {
                        var _string = _instruction_content[0];
                        var _pos = string_pos(CHATTERBOX_FILENAME_SEPARATOR, _string);
                        if (_pos > 0)
                        {
                            _filename   = string_copy(_string, 1, _pos-1);
                            _node_title = string_delete(_string, 1, _pos);
                        }
                        else
                        {
                            _node_title = _string;
                        }
                        
                        _chatterbox[| __CHATTERBOX.TITLE    ] = _node_title;
                        _chatterbox[| __CHATTERBOX.FILENAME ] = _filename;
                        
                        var _key = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
                        _variables_map[? "visited(" + _key + ")" ] = true;
                        if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox:   Set \"visited(" + _key + ")\" to <true>");
                        
                        if (!ds_map_exists(global.__chatterbox_goto, _key))
                        {
                            if (!ds_map_exists(global.__chatterbox_file_data, _filename))
                            {
                                show_error("Chatterbox:\nFile \"" + string(_filename) + "\" not initialised.\n ", true);
                                exit;
                            }
                            else
                            {
                                show_error("Chatterbox:\nNode title \"" + string(_node_title) + "\" not found in file \"" + string(_filename) + "\".\n ", true);
                                exit;
                            }
                        }
                        
                        //Partially reset state
                        var _text_instruction      = -1;
                        var _instruction           = global.__chatterbox_goto[? _key ]-1;
                        var _end_instruction       = -1;
                        var _if_state              = true;
                        var _permit_greater_indent = false;
                        var _scan_from_option_end  = false;
                        
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Jumping to " + string(_key) + ", instruction = " + string(_instruction) + " (inc. -1 offset)" );
                        
                        var _instruction_array   = global.__chatterbox_vm[| _instruction+1];
                            _indent              = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
                            _indent_bottom_limit = 0;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
                        
                        _continue = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                        break;
                    }
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_OPTION:
                    #region Option
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                    if (!_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_option_end == " + string(_scan_from_option_end));
                        if (_scan_from_option_end)
                        {
                            _node_title = _instruction_content[1];
                            _chatterbox[| __CHATTERBOX.TITLE ] = _node_title;
                            
                            var _key = _filename + CHATTERBOX_FILENAME_SEPARATOR + _node_title;
                            _variables_map[? "visited(" + _key + ")" ] = true;
                            if (CHATTERBOX_DEBUG) show_debug_message("Chatterbox:   Set \"visited(" + _key + ")\" to <true>");
                        
                            if (!ds_map_exists(global.__chatterbox_goto, _key))
                            {
                                if (!ds_map_exists(global.__chatterbox_file_data, _filename))
                                {
                                    show_error("Chatterbox:\nFile \"" + string(_filename) + "\" not initialised.\n ", true);
                                    exit;
                                }
                                else
                                {
                                    show_error("Chatterbox:\nNode title \"" + string(_node_title) + "\" not found in file \"" + string(_filename) + "\".\n ", true);
                                    exit;
                                }
                            }
                            
                            //Partially reset state
                            var _text_instruction      = -1;
                            var _instruction           = global.__chatterbox_goto[? _key ]-1;
                            var _end_instruction       = -1;
                            var _if_state              = true;
                            var _permit_greater_indent = false;
                            var _scan_from_option_end  = false;
                            
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Jumping to " + string(_key) + ", instruction = " + string(_instruction) + " (inc. -1 offset)" );
                            
                            var _instruction_array   = global.__chatterbox_vm[| _instruction+1];
                                _indent              = _instruction_array[ __CHATTERBOX_INSTRUCTION.INDENT ];
                                _indent_bottom_limit = 0;
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: Set indent = " + string(_indent));
                        }
                        
                        _continue = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                        break;
                    }
                    
                    _indent_bottom_limit = _instruction_indent;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _indent_for_options = " + string(_indent_bottom_limit));
                    
                    _new_option = true;
                    _new_option_text = _instruction_content[0];
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     New option \"" + string(_new_option_text) + "\"");
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_SHORTCUT:
                    #region Shortcut
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       _scan_from_text == " + string(_scan_from_text));
                    if (!_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     instruction=" + string(_instruction) + " vs. end=" + string(_end_instruction));
                        if (_instruction == _end_instruction)
                        {
                            _permit_greater_indent = true;
                            if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   Set _permit_greater_indent = " + string(_permit_greater_indent));
                        }
                        
                        _continue = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                        break;
                    }
                    
                    _indent_bottom_limit = _instruction_indent;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     Set _indent_for_options = " + string(_indent_bottom_limit));
                    
                    _new_option = true;
                    _new_option_text = _instruction_content[0];
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       New option \"" + string(_new_option_text) + "\"");
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_SET:
                    #region Set
                    
                    if (_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                        _continue = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                        break;
                    }
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     now executing");
                    __chatterbox_evaluate(_chatterbox, _instruction_content);
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_CUSTOM_ACTION:
                    #region Custom Action
                    
                    if (_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                        _continue = true;
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   <- Continue <-");
                        break;
                    }
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     now executing");
                    
                    var _argument_array = array_create(array_length_1d(_instruction_content)-3);
                    array_copy(_argument_array, 0, _instruction_content, 3, array_length_1d(_instruction_content)-3);
                    
                    var _i = 0;
                    repeat(array_length_1d(_argument_array))
                    {
                        _argument_array[_i] = __chatterbox_resolve_value(_chatterbox, _argument_array[_i]);
                        _i++;
                    }
                    
                    script_execute(global.__chatterbox_actions[? _instruction_content[0] ], _argument_array);
                    
                    #endregion
                break;
                
                case __CHATTERBOX_VM_STOP:
                    #region Stop
                    
                    if (_scan_from_text)
                    {
                        if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":   -> BREAK ->");
                        _break = true;
                        break;
                    }
                    
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":     _scan_from_text == " + string(_scan_from_text));
                    _chatterbox[| __CHATTERBOX.TITLE ] = undefined;
                    if (CHATTERBOX_DEBUG_VM) show_debug_message("Chatterbox: " + string(_instruction) + ":       Stop");
                    exit;
                    
                    #endregion
                break;
            }
        
            #region Create a new option from SHORTCUT and OPTION instructions
            
            if (_new_option)
            {
                _new_option = false;
                
                var _new_array = array_create(__CHATTERBOX_CHILD.__SIZE);
                _new_array[@ __CHATTERBOX_CHILD.STRING            ] = _new_option_text;
                _new_array[@ __CHATTERBOX_CHILD.TYPE              ] = CHATTERBOX_OPTION;
                _new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_START ] = _text_instruction;
                _new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_END   ] = _instruction;
                ds_list_add(_child_list, _new_array);
            }
            #endregion
        }
        
        if (_break) break;
        
        _instruction++;
    }
    
    #region Create a new option from a TEXT instruction if no option or shortcut was found
    
    if (chatterbox_get_child_count(_chatterbox, CHATTERBOX_OPTION) <= 0)
    {
        //We haven't found an option that's alive
        var _new_array = array_create(__CHATTERBOX_CHILD.__SIZE);
        _new_array[@ __CHATTERBOX_CHILD.STRING            ] = CHATTERBOX_OPTION_DEFAULT_TEXT;
        _new_array[@ __CHATTERBOX_CHILD.TYPE              ] = CHATTERBOX_OPTION;
        _new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_START ] = _text_instruction;
        _new_array[@ __CHATTERBOX_CHILD.INSTRUCTION_END   ] = _text_instruction+1;
        ds_list_add(_child_list, _new_array);
    }
    
    #endregion
    
    #endregion

    return true;
}

return false;