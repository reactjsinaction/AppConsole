# open Demo/UIControls/UIControls.xcworkspace
# Run

using Swifter

vc = initial("http://localhost:8080")

@query vc.label.text = "Hello Swift"
sleep(0.5)

@query vc.textField.text = "Hello Julia"
sleep(0.5)

@query vc.button.tap()
sleep(0.5)

@query vc.switch_.tap()
sleep(0.5)

@query vc.segmentedControl.tap(title: "Second")
sleep(0.5)

@query vc.segmentedControl.tap(index: 2)
sleep(0.5)

@query vc.slider.tap(value: 1)
sleep(0.5)

@query vc.progressView.setProgress(1, animated: true)
