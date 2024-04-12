@echo off
setlocal
set NVIM_LISTEN_ADDRESS=\\.\pipe\nvim-unity
nvr --servername %NVIM_LISTEN_ADDRESS% --remote-silent %2 %1
pause
