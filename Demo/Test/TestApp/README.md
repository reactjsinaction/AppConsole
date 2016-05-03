### Register variables

    ```swift

    label.text = AppConsole(initial: self).run { app in
        app.register("a", object: a)
        app.register("b", object: b)
    }

    ```



### Access the variables

    ```julia

    julia> using Swifter

    julia> vc = initial("http://localhost:8080")

    Swifter> b.s
    "b string"

    Swifter> b.g(1)
    2

    ```