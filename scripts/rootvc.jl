using Swifter

vc = initial("http://localhost:8080")

@query vc.view.backgroundColor = UIColor.greenColor()

@query vc.tableView.frame
@query vc.tableView.subviews

@query vc.title = "hello $(1+2)"
