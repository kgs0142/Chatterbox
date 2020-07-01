//Check for any keyboard input
var _select = undefined;
if (keyboard_check_released(ord("1"))) _select = 0;
if (keyboard_check_released(ord("2"))) _select = 1;
if (keyboard_check_released(ord("3"))) _select = 2;

var _selectByCursor = false;
if (keyboard_check_released(vk_up)) currentChooseIndex--;
if (keyboard_check_released(vk_down)) currentChooseIndex++;
if (keyboard_check_released(ord("Z"))) _selectByCursor = true;
if (mouse_check_button_released(mb_left)) _selectByCursor = true;

var _text_count = chatterbox_get_string_count(chatterbox, CHATTERBOX_BODY);
var _option_count = chatterbox_get_string_count(chatterbox, CHATTERBOX_OPTION);
currentChooseIndex = clamp(currentChooseIndex, 0, _option_count - 1);

var _x = 10;
var _y = 10;

for(var _i = 0; _i < _text_count; _i++)
{
    _y += 20;
}

_y += 20;

for(var _i = 0; _i < _option_count; _i++)
{
    //var line = chatterbox_get_string(chatterbox, CHATTERBOX_OPTION, _i);
    if (point_in_rectangle(mouse_x, mouse_y, 
                           //_x, _y, _x + string_width(line), _y + 20) == true)
                           _x, _y, _x + room_width, _y + 20) == true)
    {
        currentChooseIndex = _i;
    }
    
    _y += 20;
}


//If we've pressed a button, select that option
if (_select != undefined) 
{
    chatterbox_select(chatterbox, _select);
}
else if (_selectByCursor == true)
{
    chatterbox_select(chatterbox, currentChooseIndex);
    currentChooseIndex = 0;
}
