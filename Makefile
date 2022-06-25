.PHONY: macos-debug macos-release ios-debug ios-release ios-sim xcode clean

macos-debug:
	mkdir -p build
	cd build; cmake .. -G Xcode
	cd build; cmake --build . --config Debug --parallel 24
	cd build; open ./App/Debug/Calico.app

macos-release:
	mkdir -p build
	cd build; cmake .. -G Xcode
	cd build; cmake --build . --config Release --parallel 24
	cd build; open ./App/Release/Calico.app

ios-debug:
	mkdir -p build
	cd build; cmake .. -G Xcode -D CMAKE_SYSTEM_NAME=iOS
	cd build; cmake --build . --config Debug --parallel 24
	cd build; ideviceinstaller -i ./App/Debug-iphoneos/Calico.app

ios-release:
	mkdir -p build
	cd build; cmake .. -G Xcode -D CMAKE_SYSTEM_NAME=iOS
	cd build; cmake --build . --config Release --parallel 24
	cd build; ideviceinstaller -i ./App/Release-iphoneos/Calico.app
	idevicedebug -d run co.seb.calico-ios

ios-sim:
	open -a Simulator
	mkdir -p build
	cd build; cmake .. -G Xcode -D CMAKE_SYSTEM_NAME=iOS
	cd build; cmake --build . --config Debug -- -sdk iphonesimulator --parallel 24
	cd build; xcrun simctl install booted ./App/Debug-iphonesimulator/Calico.app
	xcrun simctl launch booted co.seb.calico-ios

xcode:
	cd build; cmake .. -G Xcode
	cd build; cmake --open .

clean:
	rm -rf build