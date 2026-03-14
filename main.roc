app [init_model, update_model, handle_request!, Model] {
    webserver: platform "https://github.com/ostcar/kingfisher/releases/download/v0.0.6/CGvtit0XrLnoN00TVk3Ggseg8nXTe9UykuX7dAcETmw.tar.br",
}

import webserver.Http

Model : Str

index_html = |title, description|
    """
    <!doctype html>
    <html lang="en">
      <head>
        <script src="https://cdn.jsdelivr.net/npm/htmx.org@2.0.8/dist/htmx.min.js" integrity="sha384-/TgkGk7p307TH7EXJDuUlgG3Ce1UVolAOFopFekQkkXihi5u/6OCvVKyz1W+idaz" crossorigin="anonymous"></script>
      </head>
      <body>
        <form hx-post="/store">
            <input type="checkbox" switch />
            <input name="title" type="text" value="${title}">
            <input name="description" type="text" value="${description}">
            <button type="submit">Submit</button>
        </form>
      </body>
    </html>
    """

init_model = "World"

update_model : Model, List (List U8) -> Result Model _
update_model = |model, event_list|
    event_list
    |> List.walk_try(
        model,
        |_acc_model, event|
            Str.from_utf8(event)
            |> Result.map_err(|_| InvalidEvent),
    )

handle_request! : Http.Request, Model => Result Http.Response _
handle_request! = |request, model|
    when request.method is
        Get ->
            Ok(
                {
                    body: Str.to_utf8(index_html "" ""),
                    headers: [],
                    status: 200,
                },
            )

        Post(save_event!) ->
            Ok(
                {
                    body: Str.to_utf8(Str.join_with(Str.split_on(Str.from_utf8(request.body)?, "&"), "_")),
                    headers: [],
                    status: 200,
                },
            )

        _ ->
            Err(MethodNotAllowed(Http.method_to_str(request.method)))
