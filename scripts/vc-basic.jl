# open Demo/ViewController/ViewController.xcworkspace
# Run

using Swifter

vc = initial("http://localhost:8080")

@query vc.view.backgroundColor = UIColor.yellowColor()

sleep(0.5)

@query vc.label.text = "Hello Swift"

sleep(0.5)

@query vc.label.numberOfLines = 2
@query vc.label.text = "Hello Swift\nHelloJulia"

sleep(0.5)

@query vc.label.font = UIFont(name: "Helvetica", size: 35)

sleep(0.5)

@query vc.label.backgroundColor = UIColor.cyanColor()

sleep(0.5)

@query vc.view.subviews[0].backgroundColor = UIColor.orangeColor()

sleep(0.5)

(Left, Center, Right) = (0, 1, 2)
@query vc.label.textAlignment = Center

sleep(0.5)

@query vc.label.frame = "{{20, 300}, {280, 200}}"

sleep(0.5)
