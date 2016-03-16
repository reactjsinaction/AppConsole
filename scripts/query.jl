using Swifter

simulator = App("http://localhost:8080")
vc = initial(simulator)

@query vc.view.backgroundColor = UIColor.greenColor()

@query vc.view.alpha = 0.5
@query vc.view.alpha = 1

@query vc.label.text = "hello"
@query vc.label.backgroundColor = UIColor.yellowColor()

@query vc.label.frame = "{{10, 150}, {300, 200}}"
@query vc.label.frame = CGRectMake(10, 250, 300, 200)

@query vc.label.font = UIFont(name: "Helvetica", size: 30)
