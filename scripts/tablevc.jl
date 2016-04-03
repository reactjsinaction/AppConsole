using Swifter

vc = initial("http://localhost:8080")

@query vc.view.backgroundColor = UIColor.greenColor()

@query vc.tableView.frame

@query vc.tableView.subviews.count

@query vc.tableView.subviews[0]

title = "Hello world"
@query vc.title = title
