b:
	instruments -w "iPhone 5s (9.2)" -t ./Instruments/Simulator.tracetemplate com.factor.ConsoleApp
	xcrun simctl launch booted com.factor.ConsoleApp
	xctool -workspace ConsoleApp.xcworkspace -scheme ConsoleApp -derivedDataPath build -sdk iphonesimulator
	
	xctool -workspace ConsoleApp.xcworkspace -scheme ConsoleApp -derivedDataPath build -sdk iphoneos
	
	# iphone6s b817a065c2a989d2e25cc7500abd220995301b7d
	fruitstrap -i b817a065c2a989d2e25cc7500abd220995301b7d -b build/Build/Products/Debug-iphoneos/ConsoleApp.app
	
	# ipadpro bbd6972833e2077ca6d53b432a0706e7aa5768bd
	fruitstrap -i bbd6972833e2077ca6d53b432a0706e7aa5768bd -b build/Build/Products/Debug-iphoneos/ConsoleApp.app
	
	instruments -w iphone6s -t ./Instruments/ConsoleApp.tracetemplate -D . com.factor.ConsoleApp
	instruments -w ipadpro -t ./Instruments/ConsoleApp.tracetemplate -D . com.factor.ConsoleApp

c:
	rm -rf *.trace
