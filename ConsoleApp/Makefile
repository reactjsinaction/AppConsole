b:
	instruments -w "iPhone 5s (9.2)" -t ./Instruments/Simulator.tracetemplate com.factor.ConsoleApp
	xcrun simctl launch booted com.factor.ConsoleApp
	xctool -workspace ConsoleApp.xcworkspace -scheme ConsoleApp -derivedDataPath build -sdk iphonesimulator
	
	xctool -workspace ConsoleApp.xcworkspace -scheme ConsoleApp -derivedDataPath build -sdk iphoneos
	fruitstrap -b build/Build/Products/Debug-iphoneos/ConsoleApp.app
	instruments -w ipadpro -t ./Instruments/ConsoleApp.tracetemplate -D . com.factor.ConsoleApp

c:
	rm -rf *.trace
