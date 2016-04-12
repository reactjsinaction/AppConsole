using Swifter

vc = initial("http://localhost:8080")

@query vc.view.backgroundColor = UIColor.greenColor()

@query vc.view.frame

@query vc.label.text = "Hello world"

@query vc.label.frame = "{{20, 300}, {300, 200}}"

@query vc.label.backgroundColor = UIColor.whiteColor()

@query vc.view.subviews[0].backgroundColor = UIColor.yellowColor()

@query vc.label.font = UIFont(name: "Helvetica", size: 50)

(Left, Center, Right) = (0, 1, 2)
@query vc.label.textAlignment = Left
@query vc.label.textAlignment = Center
@query vc.label.textAlignment = Right
