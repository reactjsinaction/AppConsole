AppConsole
==========

  * iOS REPL with [Swifter.jl](https://github.com/wookay/Swifter.jl) + AppConsole

  [![Build Status](https://api.travis-ci.org/wookay/AppConsole.svg?branch=master)](https://travis-ci.org/wookay/AppConsole)
  ![Cocoapods Version](https://img.shields.io/cocoapods/v/AppConsole.svg?style=flat) 


# Run server on your iOS app
```swift
class ViewController: UIViewController {
    override func viewDidLoad() {
        AppConsole(initial: self).run()
    }
}
```


# REPL client with Julia
 * Install Julia http://julialang.org/
```julia
julia> Pkg.add("Swifter")
INFO: Installing Swifter v0.0.1
```

```julia
julia> using Swifter

julia> vc = initial("http://localhost:8080")
Swifter.Memory(Swifter.App("http://localhost:8080"),"0x7f9238f1e4b0")

julia> @query vc.view.backgroundColor = UIColor.greenColor()
"UIDeviceRGBColorSpace 0 1 0 1"
```

* Query mode : pressing the `>` key.
```julia
Swifter> vc.view.frame
"{{0, 0}, {320, 568}}"

Swifter> vc.label.text = "hello world"
"hello world"

Swifter> vc.label.backgroundColor = UIColor.yellowColor()
"UIDeviceRGBColorSpace 1 1 0 1"

Swifter> vc.label.font = UIFont(name: "Helvetica", size: 50)
"<UICTFont: 0x7faa91461b40> font-family: \"Helvetica\"; font-weight: normal; font-style: normal; font-size: 50.00pt"
```


# CocoaPods
* Create a Podfile, and add the dependency
```
pod 'AppConsole'
```
