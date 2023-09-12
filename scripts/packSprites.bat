@REM @ECHO OFF
TITLE "Packing Sprites"

ECHO "Packing Camp Decorations"

IF EXIST E:\Owner\Documents\fresno\raw\camp-decorations\camp_deco.xml DEL /F /Q E:\Owner\Documents\fresno\raw\camp-decorations\camp_deco.xml

IF EXIST E:\Owner\Documents\fresno\raw\camp-decorations\camp_deco.png DEL /F /Q E:\Owner\Documents\fresno\raw\camp-decorations\camp_deco.png

START /B /W CMD /C ""E:\Program Files (x86)\ShoeBox\ShoeBox.exe" "plugin=shoebox.plugin.spriteSheet::PluginCreateSpriteSheet" "files=E:\Owner\Documents\fresno\raw\camp-decorations" "renderDebugLayer=false" "texPowerOfTwo=false" "fileName=camp_deco.xml" "useCssOverHack=false" "texPadding=1" "animationNameIds=####" "scale=1" "fileGenerate2xSize=false" "animationMaxFrames=1000" "animationFrameIdStart=0" "texMaxSize=2048" "texCropAlpha=true" "texExtrudeSize=0" "texSquare=false" fileFormatLoop="\t^<SubTexture name=\"@ID\"\tx=\"@x\"\ty=\"@y\"\twidth=\"@w\"\theight=\"@h\" frameX=\"-@fx\" frameY=\"-@fy\" frameWidth=\"@fw\" frameHeight=\"@fh\"/^>\n""


IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

IF NOT EXIST E:\Owner\Documents\fresno\raw\camp-decorations\camp_deco.png ECHO "FILE MISSING!" && EXIT /B 1

START /B MOVE /Y "E:\Owner\Documents\fresno\raw\camp-decorations\camp_deco.*" "E:\Owner\Documents\fresno\assets\images" 

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

ECHO "Packing Vehicles"

IF EXIST E:\Owner\Documents\fresno\raw\vehicles\vehicles.xml DEL /F /Q E:\Owner\Documents\fresno\raw\vehicles\vehicles.xml

IF EXIST E:\Owner\Documents\fresno\raw\vehicles\vehicles.png DEL /F /Q E:\Owner\Documents\fresno\raw\vehicles\vehicles.png

START /B /W CMD /C ""E:\Program Files (x86)\ShoeBox\ShoeBox.exe" "plugin=shoebox.plugin.spriteSheet::PluginCreateSpriteSheet" "files=E:\Owner\Documents\fresno\raw\vehicles" "renderDebugLayer=false" "texPowerOfTwo=false" "fileName=vehicles.xml" "useCssOverHack=false" "texPadding=1" "animationNameIds=####" "scale=1" "fileGenerate2xSize=false" "animationMaxFrames=1000" "animationFrameIdStart=0" "texMaxSize=2048" "texCropAlpha=true" "texExtrudeSize=0" "texSquare=false" fileFormatLoop="\t^<SubTexture name=\"@ID\"\tx=\"@x\"\ty=\"@y\"\twidth=\"@w\"\theight=\"@h\" frameX=\"-@fx\" frameY=\"-@fy\" frameWidth=\"@fw\" frameHeight=\"@fh\"/^>\n""


IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

IF NOT EXIST E:\Owner\Documents\fresno\raw\vehicles\vehicles.png ECHO "FILE MISSING!" && EXIT /B 1

START /B MOVE /Y "E:\Owner\Documents\fresno\raw\Vehicles\vehicles.*" "E:\Owner\Documents\fresno\assets\images" 

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

ECHO "Packing Camp Obstacles"

IF EXIST E:\Owner\Documents\fresno\raw\camp-objects\camp_objects.xml DEL /F /Q E:\Owner\Documents\fresno\raw\camp-objects\camp_objects.xml

IF EXIST E:\Owner\Documents\fresno\raw\camp-objects\camp_objects.png DEL /F /Q E:\Owner\Documents\fresno\raw\camp-objects\camp_objects.png

START /B /W CMD /C ""E:\Program Files (x86)\ShoeBox\ShoeBox.exe" "plugin=shoebox.plugin.spriteSheet::PluginCreateSpriteSheet" "files=E:\Owner\Documents\fresno\raw\camp-objects" "renderDebugLayer=false" "texPowerOfTwo=false" "fileName=camp_objects.xml" "useCssOverHack=false" "texPadding=1" "animationNameIds=####" "scale=1" "fileGenerate2xSize=false" "animationMaxFrames=1000" "animationFrameIdStart=0" "texMaxSize=2048" "texCropAlpha=true" "texExtrudeSize=0" "texSquare=false" fileFormatLoop="\t^<SubTexture name=\"@ID\"\tx=\"@x\"\ty=\"@y\"\twidth=\"@w\"\theight=\"@h\" frameX=\"-@fx\" frameY=\"-@fy\" frameWidth=\"@fw\" frameHeight=\"@fh\"/^>\n""


IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

IF NOT EXIST E:\Owner\Documents\fresno\raw\camp-objects\camp_objects.png ECHO "FILE MISSING!" && EXIT /B 1

START /B MOVE /Y "E:\Owner\Documents\fresno\raw\camp-objects\camp_objects.*" "E:\Owner\Documents\fresno\assets\images" 

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%
