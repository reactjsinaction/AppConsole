run:
	xctool --version
	@echo
	xctool -workspace Demo/Test/TestApp/TestApp.xcworkspace -scheme TestApp -derivedDataPath Demo/Test/TestApp/build -sdk iphonesimulator
