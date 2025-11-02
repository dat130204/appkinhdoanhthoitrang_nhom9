@echo off
echo ========================================
echo  FASHION SHOP - DATABASE SETUP
echo ========================================
echo.

echo [1/2] Installing Backend Dependencies...
cd backend
call npm install
echo.

echo [2/2] Initializing Database...
node scripts/initDatabase.js
echo.

echo ========================================
echo  SETUP COMPLETE!
echo ========================================
echo.
echo Next steps:
echo 1. Run start.bat to start the backend server
echo 2. Run Flutter app with: flutter run
echo.
pause
