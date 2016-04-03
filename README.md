AppConsole
==========

  * iOS REPL with [Swifter.jl](https://github.com/wookay/Swifter.jl) + AppConsole

  [![Build Status](https://api.travis-ci.org/wookay/AppConsole.svg?branch=master)](https://travis-ci.org/wookay/AppConsole)
  [![Cocoapods Version](https://img.shields.io/cocoapods/v/AppConsole.svg?style=flat)](https://cocoapods.org/pods/AppConsole)


# Run server on your iOS app

```swift
import AppConsole

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        AppConsole(initial: self).run()
    }
}
```


# REPL client with Julia
 * Install Julia http://julialang.org/
```julia
julia> Pkg.add("Swifter")
INFO: Installing Swifter v0.0.3
```

```julia
julia> using Swifter

julia> vc = initial("http://localhost:8080")
Swifter.Memory(Swifter.App("http://localhost:8080"),"0x7f9238f1e4b0")

julia> @query vc.view.backgroundColor = UIColor.greenColor()
UIDeviceRGBColorSpace 0 1 0 1
```

* Query mode : pressing the `>` key.

```julia
Swifter> vc.view.frame
"{{0, 0}, {320, 568}}"

Swifter> vc.label.text = "Hello world"
"Hello world"

Swifter> vc.label.frame = "{{20, 300}, {500, 200}}"
"{{20, 300}, {500, 200}}"

Swifter> vc.label.backgroundColor = UIColor.whiteColor()
UIDeviceWhiteColorSpace 1 1

Swifter> vc.view.subviews[0].backgroundColor = UIColor.yellowColor()
UIDeviceRGBColorSpace 1 1 0 1

Swifter> vc.label.font = UIFont(name: "Helvetica", size: 50)
<UICTFont: 0x7f8c687e1cc0> font-family: "Helvetica"; font-weight: normal; font-style: normal; font-size: 50.00pt
```


# CocoaPods
* Create a Podfile, and add the dependency
```
pod 'AppConsole'
```
