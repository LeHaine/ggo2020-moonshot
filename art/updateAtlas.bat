@echo off
set "PATH=C:/Program Files/CodeAndWeb/TexturePacker/bin;%PATH%"
@echo on
for %%X in (*.tps) do (TexturePacker  %%X)