cd Display
setlocal enabledelayedexpansion
del *.sq.lua /q
for %%f in (.\*.lua) do (
    SET mytemp=%%f
    findstr /V "Remove before squishing" %%f > build.lua
    lua51 squish --minify-level=full --uglify --uglify-level=full
    del build.lua /q
    del out.lua /q
    ren out.lua.uglified !mytemp:~2,-4!.sq.lua
)