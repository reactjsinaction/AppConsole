Console
=======

  * iOS REPL with [Swifter.jl](https://github.com/wookay/Swifter.jl) + Console

  [![Build Status](https://api.travis-ci.org/wookay/Console.svg?branch=master)](https://travis-ci.org/wookay/Console)


# Run server with your iOS app
```swift
class ViewController: UIViewController {
    override func viewDidLoad() {
        Console(initial: self).run()
    }
}
```


# REPL with Julia
```julia
using Swifter

simulator = App("http://localhost:8080")
vc = initial(simulator)

@query vc.view.backgroundColor = UIColor.greenColor()
```
