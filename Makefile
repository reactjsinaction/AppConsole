run:
	xctool --version
	@echo
	xctool -project ConsoleApp/ConsoleApp.xcodeproj -scheme Pods -sdk iphonesimulator test
	xctool -project ConsoleApp/ConsoleApp.xcodeproj -scheme ConsoleApp -sdk iphonesimulator test
