using Swifter

vc = initial("http://localhost:8080")

@query NSBundle.mainBundle.bundleIdentifier

@query NSBundle.mainBundle.infoDictionary["CFBundleIdentifier"]

@query NSBundle.mainBundle.infoDictionary.keys

@query NSBundle.mainBundle.infoDictionary.keys.sort

@query NSBundle.mainBundle.infoDictionary.keys[0]
@query NSBundle.mainBundle.infoDictionary.keys[1]

@query NSBundle.mainBundle.infoDictionary.values
