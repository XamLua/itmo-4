masm /t test.asm;
masm /t dline.asm;
masm /t paint.asm;
masm /t util.asm;
link test.obj util.obj dline.obj paint.obj;
