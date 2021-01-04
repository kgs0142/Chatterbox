//Load in some source files

global.lockYarnSystem = true;
global.loadFileCounts = 0;
global.totalLoadFileCounts = 0;

//There is a tab character in Test.json that break the system.
chatterbox_load("Test.json");
chatterbox_load("Test2.json");
chatterbox_load("Test2.yarn");
chatterbox_load("YarnUnitTest.yarn");

chatterbox_add_function("TestFunctionDoNotExecute", function(_array) { show_message(_array); });

DoLaterTrigger(function() 
               { 
                   return global.loadFileCounts >= global.totalLoadFileCounts
               },
               function(data)
               {
                   show_debug_message("Load Complete!");
                   
                   global.lockYarnSystem = false;
                   
                   //Create a chatterbox
                    obj_test.box = chatterbox_create("YarnUnitTest.yarn");
                    //obj_test.box = chatterbox_create("Test2.yarn");

                    //Tell the chatterbox to jump to a node
                    chatterbox_goto(obj_test.box, "Start");
               }, "", true);

exit;

//Create a chatterbox
box = chatterbox_create("YarnUnitTest.yarn");

//Tell the chatterbox to jump to a node
chatterbox_goto(box, "Start");

