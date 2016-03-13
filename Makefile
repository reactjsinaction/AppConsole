run:
	xctool --version
	@echo
	xctool -workspace ConsoleApp/ConsoleApp.xcworkspace -scheme ConsoleApp -derivedDataPath ConsoleApp/build -sdk iphonesimulator
