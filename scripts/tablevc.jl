# open Demo/TableViewController/TableViewController.xcworkspace
# Run

using Swifter

vc = initial("http://localhost:8080")

sleep(0.5)

@query vc.tableView.tap(section: 0, row: 1)
sleep(0.5)
@query vc.navigationController.pop()
sleep(0.5)

@query vc.tableView.tap(index: 2)
sleep(0.5)
@query vc.navigationController.pop()
sleep(0.5)

@query vc.tableView.tap(text: "cyan")
sleep(0.5)
@query vc.navigationController.pop()
sleep(0.5)

@query vc.navigationController.topViewController
