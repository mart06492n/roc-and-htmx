app [init_model, update_model, handle_request!, Model] {
    webserver: platform "https://github.com/ostcar/kingfisher/releases/download/v0.0.6/CGvtit0XrLnoN00TVk3Ggseg8nXTe9UykuX7dAcETmw.tar.br",
}

import webserver.Http
index_html : Model -> Str
index_html = |model|
    stuff = Str.join_with(List.map(model, |e| "<div>${e}</div>"), "\n")
    """
    <!doctype html>
    <html lang="en">
      <head>
        <script src="https://cdn.jsdelivr.net/npm/htmx.org@2.0.8/dist/htmx.min.js" integrity="sha384-/TgkGk7p307TH7EXJDuUlgG3Ce1UVolAOFopFekQkkXihi5u/6OCvVKyz1W+idaz" crossorigin="anonymous"></script>
      </head>
      <body>
        <form hx-post="/store" hx-swap="afterend">
            <input name="title" type="text">
            <button type="submit">Submit</button>
        </form>
        ${stuff}
      </body>
    </html>
    """

Model : List Str

init_model = ["World"]

update_model : Model, List (List U8) -> Result Model _
update_model = |model, event_list|
    event_list
    |> List.walk_try(
        model,
        |acc, event|
            Ok(List.concat([Str.from_utf8(event)?], acc)),
    )

handle_request! : Http.Request, Model => Result Http.Response _
handle_request! = |request, model|
    when request.method is
        Get ->
            when request.url is
                "/" ->
                    Ok(
                        {
                            body: Str.to_utf8(index_html model),
                            headers: [],
                            status: 200,
                        },
                    )

                _ ->
                    Ok(
                        {
                            body: Str.to_utf8("Page Not Found"),
                            headers: [],
                            status: 200,
                        },
                    )

        Post(save_event!) ->
            entry = List.get(Str.split_on(Str.from_utf8(request.body)?, "="), 1)?
            save_event!(Str.to_utf8(entry))
            Ok(
                {
                    body: Str.to_utf8("<div>${entry}</div>"),
                    headers: [],
                    status: 200,
                },
            )

        _ ->
            Err(MethodNotAllowed(Http.method_to_str(request.method)))
