run:
	xctool --version
	@echo
<<<<<<< HEAD
	xctool -workspace ConsoleApp/ConsoleApp.xcworkspace -scheme ConsoleApp -derivedDataPath ConsoleApp/build -sdk iphonesimulator
=======
	xctool -project ConsoleApp/ConsoleApp.xcodeproj -scheme Pods -sdk iphonesimulator test
	xctool -project ConsoleApp/ConsoleApp.xcodeproj -scheme ConsoleApp -sdk iphonesimulator test
>>>>>>> ad7fc407e307ab492df14747699142457afe87ee
