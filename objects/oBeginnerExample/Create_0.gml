//Create a host
//chatterbox = chatterbox_create_host("Test.json");
//chatterbox = chatterbox_create_host("Test2.json");
//chatterbox = chatterbox_create_host("YarnTest.yarn");
chatterbox = chatterbox_create_host("YarnUnitTest.yarn");

//Tell the host to jump to a node
chatterbox_goto(chatterbox, "Start");

draw_set_font(font0);