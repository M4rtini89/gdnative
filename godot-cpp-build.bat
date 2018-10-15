call "C:\Users\Martin\Anaconda3\Scripts\activate.bat" scons
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsx86_amd64.bat"   
cd godot-cpp
call scons -j 12 platform=windows target=release generate_bindings=yes use_custom_api_file=yes custom_api_file=../api.json