using Swifter

vc = initial("http://localhost:8080")

@query vc.view.backgroundColor = UIColor.greenColor()

@query vc.view.frame

@query vc.label.text = "Hello world"

@query vc.label.frame = "{{20, 300}, {500, 200}}"

@query vc.label.backgroundColor = UIColor.whiteColor()

@query vc.view.subviews[0].backgroundColor = UIColor.yellowColor()

@query vc.label.font = UIFont(name: "Helvetica", size: 50)
