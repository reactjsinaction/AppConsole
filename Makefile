run:
	xctool --version
	pod --version
	@echo
	pod install --project-directory=Demo/Test/TestApp/
	set -o pipefail && xctool -workspace Demo/Test/TestApp/TestApp.xcworkspace -scheme TestApp -derivedDataPath Demo/Test/TestApp/build -sdk iphonesimulator clean test
