//Iterate over all text and draw it

var _x = 10;
var _y = 10;

var _text_count = chatterbox_get_string_count(chatterbox, CHATTERBOX_BODY);
for(var _i = 0; _i < _text_count; _i++)
{
    var line = chatterbox_get_string(chatterbox, CHATTERBOX_BODY, _i);
    draw_text(_x, _y, line);
    _y += 20;
}

_y += 20;

var _option_count = chatterbox_get_string_count(chatterbox, CHATTERBOX_OPTION);
currentChooseIndex = clamp(currentChooseIndex, 0, _option_count - 1);
for(var _i = 0; _i < _option_count; _i++)
{
    var prefix = (_i == currentChooseIndex && _option_count > 1) ? "> " : "";
    var line = chatterbox_get_string(chatterbox, CHATTERBOX_OPTION, _i);
    draw_text(_x, _y, prefix + string(_i+1) + ") " + line);
    _y += 20;
}