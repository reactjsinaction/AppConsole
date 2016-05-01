# open Demo/ViewController/ViewController.xcworkspace
# Run

using Swifter

iphone = initial("http://192.168.0.9:8080")
simul = initial("http://localhost:8080")

@query iphone.view.backgroundColor = UIColor.cyanColor()
sleep(0.5)
@query simul.view.backgroundColor = iphone.view.backgroundColor
sleep(0.5)

for vc in [iphone, simul]
    @query vc.view.backgroundColor = UIColor.orangeColor()
    sleep(0.5)
end

@query simul.view.backgroundColor = UIColor.blueColor()
sleep(0.5)
@query iphone.view.backgroundColor = simul.view.backgroundColor
sleep(0.5)

for vc in [iphone, simul]
    @query vc.view.backgroundColor = UIColor.whiteColor()
    sleep(0.5)
end

@query iphone.label.text = "Julia"
sleep(0.5)
@query simul.label.text = "Swift"
sleep(0.5)

temporal = @query iphone.label.text
sleep(0.5)
@query iphone.label.text = simul.label.text
sleep(0.5)
@query simul.label.text = temporal
sleep(0.5)

for vc in [iphone, simul]
    @query vc.label.text = "Julia & Swift"
    sleep(0.5)
end
