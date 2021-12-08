del mod.ff
del sf_promod_sounds.iwd
del sf_promod_models.iwd
del sf_promod.iwd
del z_c_r.iwd

7za a -r -tzip sf_promod.iwd sound\promod
7za a -r -tzip sf_promod_sounds.iwd sound\music
7za a -r -tzip sf_promod_models.iwd images
7za a -r -tzip z_c_r.iwd promod_ruleset
7za a -r -tzip sf_promod.iwd weapons

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
xcopy /s /y ".\sf_promod_sounds.iwd" "D:\COD4Server\Mods\PROMODSF"
xcopy /s /y ".\sf_promod_models.iwd" "D:\COD4Server\Mods\PROMODSF"
xcopy /s /y ".\sf_promod.iwd" "D:\COD4Server\Mods\PROMODSF"
xcopy /s /y ".\z_c_r.iwd" "D:\COD4Server\Mods\PROMODSF"

xcopy /s /y ".\mod.ff" "C:\Users\Thamidu Dharshitha\AppData\Local\VirtualStore\Program Files (x86)\Activision\Call of Duty 4 - Modern Warfare\Mods\PROMODSF"
xcopy /s /y ".\sf_promod_sounds.iwd" "C:\Users\Thamidu Dharshitha\AppData\Local\VirtualStore\Program Files (x86)\Activision\Call of Duty 4 - Modern Warfare\Mods\PROMODSF"
xcopy /s /y ".\sf_promod_models.iwd" "C:\Users\Thamidu Dharshitha\AppData\Local\VirtualStore\Program Files (x86)\Activision\Call of Duty 4 - Modern Warfare\Mods\PROMODSF"
xcopy /s /y ".\sf_promod.iwd" "C:\Users\Thamidu Dharshitha\AppData\Local\VirtualStore\Program Files (x86)\Activision\Call of Duty 4 - Modern Warfare\Mods\PROMODSF"
xcopy /s /y ".\z_c_r.iwd" "C:\Users\Thamidu Dharshitha\AppData\Local\VirtualStore\Program Files (x86)\Activision\Call of Duty 4 - Modern Warfare\Mods\PROMODSF"
pause