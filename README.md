AppConsole
==========

  * iOS REPL with [Swifter.jl](https://github.com/wookay/Swifter.jl) + AppConsole

  [![Build Status](https://api.travis-ci.org/wookay/AppConsole.svg?branch=master)](https://travis-ci.org/wookay/AppConsole)


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
```
julia> Pkg.clone("https://github.com/wookay/Swifter.jl.git")
```

```julia
using Swifter

simulator = App("http://localhost:8080")
vc = initial(simulator)

@query vc.view.backgroundColor = UIColor.greenColor()
```


# Pod
* Podfile
```
pod 'AppConsole'
```
