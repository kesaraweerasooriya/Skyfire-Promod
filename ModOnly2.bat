del mod.ff

xcopy ui_mp ..\..\raw\ui_mp /SY
xcopy ui ..\..\raw\ui /SY
xcopy english ..\..\raw\english /SY
xcopy images ..\..\raw\images /SY
xcopy sound ..\..\raw\sound /SY
xcopy soundaliases ..\..\raw\soundaliases /SY
xcopy promod ..\..\raw\promod /SY
xcopy maps ..\..\raw\maps /SY
xcopy mp ..\..\raw\mp /SY
xcopy shock ..\..\raw\shock /SY
xcopy xmodel ..\..\raw\xmodel /SY

copy /Y mod.csv ..\..\zone_source
cd ..\..\bin
linker_pc.exe -language english -compress -cleanup mod

cd ..\Mods\PROMODSF
copy ..\..\zone\english\mod.ff

xcopy /s /y ".\mod.ff" "D:\COD4Server\Mods\PROMODSF"

xcopy /s /y ".\mod.ff" "C:\Users\Thamidu Dharshitha\AppData\Local\VirtualStore\Program Files (x86)\Activision\Call of Duty 4 - Modern Warfare\Mods\PROMODSF"

