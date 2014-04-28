dispatch = (gimlet) ->
	unless gimlet.content_type
		ngx.header["Content-Type"] = "text/html"
	else
		ngx.header["Content-Type"] = gimlet.content_type

	res = class
		write: (...) =>
			ngx.print ...

		set_options: (options) =>
			ngx.header["Content-Type"] = options["Content-Type"] if options["Content-Type"]
			@status options.status unless options.status == nil

		status: (s) =>
			ngx.status = s unless s == nil
			ngx.status

	req = class
		new: =>
			@url_path = ngx.var.request_uri
			@method = ngx.req.get_method!

	util = class
		now: ->
			ngx.now!

	request = req!
	response = res!
	utils = util!

	mapped = gimlet._mapped
	mapped.request = request
	mapped.response = response
	mapped.utils = utils

	coros = [coroutine.create middleware for middleware in *gimlet._handlers]
	coroutine.resume middleware, mapped for middleware in *coros

	gimlet\action mapped, request.method, request.url_path

	c = true
	while c
		ngx.update_time!
		c = false
		for middleware in *coros
			switch coroutine.status(middleware)
				when "suspended"
					coroutine.resume middleware, mapped
					c = true

	response\status!

{:dispatch}
