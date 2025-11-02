@echo off
echo ========================================
echo  FASHION SHOP - QUICK START
echo ========================================
echo.

echo [1/3] Checking MySQL...
echo Please make sure XAMPP MySQL is running!
echo.
pause

echo [2/3] Starting Backend Server...
cd backend
start cmd /k "npm run dev"
echo Backend server starting at http://localhost:3000
echo.

echo [3/3] Instructions for Flutter:
echo.
echo Open a new terminal and run:
echo   cd d:\ltdd\fashion-shop\frontend
echo   flutter run
echo.
echo Remember to:
echo - For Android Emulator: Use 10.0.2.2 in app_config.dart
echo - For Real Device: Use your PC IP (e.g., 192.168.1.5)
echo.
pause
