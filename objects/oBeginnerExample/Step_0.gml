//Check for any keyboard input
var _select = undefined;
if (keyboard_check_released(ord("1"))) _select = 0;
if (keyboard_check_released(ord("2"))) _select = 1;
if (keyboard_check_released(ord("3"))) _select = 2;

var _selectByCursor = false;
if (keyboard_check_released(vk_up)) currentChooseIndex--;
if (keyboard_check_released(vk_down)) currentChooseIndex++;
if (keyboard_check_released(ord("Z"))) _selectByCursor = true;

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
