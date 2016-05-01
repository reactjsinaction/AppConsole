# open Demo/UIControls/UIControls.xcworkspace
# Run

using Swifter

app = initial("http://localhost:8080")
@query vc = app.window.rootViewController

@query vc.label.text = "Hello Swift"

@query vc.textField.text = "Hello Julia"

@query vc.button.tap()

sleep(0.5)

@query vc.switch_.tap()

sleep(0.5)

@query vc.segmentedControl.tap(index: 2)

sleep(0.5)

@query vc.segmentedControl.tap(title: "Second")

sleep(0.5)

@query vc.slider.tap(value: 1)

sleep(0.5)

@query vc.progressView.progress = 1
