dispatch = (gimlet) ->
	unless gimlet.content_type
		ngx.header["Content-Type"] = "application/json"
	else
		ngx.header["Content-Type"] = gimlet.content_type

	import p from require "moon"

	res = class
		new: =>
		write: (...) =>
			ngx.print ...

	gimlet\action res!, ngx.req.get_method!, ngx.var.request_uri

{:dispatch}
