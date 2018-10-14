cd 
call "C:\Users\m4rti\Anaconda3\Scripts\activate.bat" scons
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x64     
cd godot-cpp
scons platform=windows target=release generate_bindings=yes use_custom_api_file=yes custom_api_file=../api.json