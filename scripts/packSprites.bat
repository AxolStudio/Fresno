@REM @ECHO OFF
TITLE "Packing Sprites"

ECHO "Packing Camp Objects"

IF EXIST E:\Owner\Documents\fresno\raw\camp-decorations\camp_deco.xml DEL /F /Q E:\Owner\Documents\fresno\raw\camp-decorations\camp_deco.xml

IF EXIST E:\Owner\Documents\fresno\raw\camp-decorations\camp_deco.png DEL /F /Q E:\Owner\Documents\fresno\raw\camp-decorations\camp_deco.png


START /B /W CMD /C ""E:\Program Files (x86)\ShoeBox\ShoeBox.exe" "plugin=shoebox.plugin.spriteSheet::PluginCreateSpriteSheet" "files=E:\Owner\Documents\fresno\raw\camp-decorations" "renderDebugLayer=false" "texPowerOfTwo=false" "fileName=camp_deco.xml" "useCssOverHack=false" "texPadding=1" "animationNameIds=####" "scale=1" "fileGenerate2xSize=false" "animationMaxFrames=1000" "animationFrameIdStart=0" "texMaxSize=2048" "texCropAlpha=true" "texExtrudeSize=0" "texSquare=false" fileFormatLoop="\t^<SubTexture name=\"@ID\"\tx=\"@x\"\ty=\"@y\"\twidth=\"@w\"\theight=\"@h\" frameX=\"-@fx\" frameY=\"-@fy\" frameWidth=\"@fw\" frameHeight=\"@fh\"/^>\n""


IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%

IF NOT EXIST E:\Owner\Documents\fresno\raw\camp-decorations\camp_deco.png ECHO "FILE MISSING!" && EXIT /B 1

START /B MOVE /Y "E:\Owner\Documents\fresno\raw\camp-decorations\camp_deco.*" "E:\Owner\Documents\fresno\game\assets\images" 

IF %ERRORLEVEL% GTR 0 EXIT /B %ERRORLEVEL%