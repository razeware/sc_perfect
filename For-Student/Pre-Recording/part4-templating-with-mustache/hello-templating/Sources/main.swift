import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache

let server = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

var routes = Routes()

struct MustacheHelper: MustachePageHandler {
  var values: MustacheEvaluationContext.MapType

  func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
    contxt.extendValues(with: values)
    do {
      try contxt.requestCompleted(withCollector: collector)
    } catch {
      let response = contxt.webResponse
      response.appendBody(string: "\(error)")
        .completed(status: .internalServerError)
    }
  }
}

func helloMustache(request: HTTPRequest, response: HTTPResponse) {
  var values = MustacheEvaluationContext.MapType()
  values["name"] = "Ray"
  mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/hello.mustache")
}

func helloMustache2(request: HTTPRequest, response: HTTPResponse) {
  guard let name = request.urlVariables["name"] else {
    response.completed(status: .badRequest)
    return
  }
  var values = MustacheEvaluationContext.MapType()
  values["name"] = name
  mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/hello.mustache")
}

func helloMustache3(request: HTTPRequest, response: HTTPResponse) {
  var values = MustacheEvaluationContext.MapType()
  values["users"] = [["name": "Ray"],
    ["name": "Vicki"],
    ["name": "Brian"]]
  mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/hello2.mustache")
}

func helloMustache4(request: HTTPRequest, response: HTTPResponse) {
  var values = MustacheEvaluationContext.MapType()
  values["users"] = [["name": "Ray", "email": "ray@razeware.com"],
    ["name": "Vicki", "email": "vicki@razeware.com"],
    ["name": "Brian", "email": "brian@razeware.com"]]
  mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/hello3.mustache")
}

func helloMustache5(request: HTTPRequest, response: HTTPResponse) {
  var values = MustacheEvaluationContext.MapType()
  mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/hello3.mustache")
}

routes.add(method: .get, uri: "/helloMustache", handler: helloMustache)
routes.add(method: .get, uri: "/helloMustache2/{name}", handler: helloMustache2)
routes.add(method: .get, uri: "/helloMustache3", handler: helloMustache3)
routes.add(method: .get, uri: "/helloMustache4", handler: helloMustache4)
routes.add(method: .get, uri: "/helloMustache5", handler: helloMustache5)

/*routes.add(method: .get, uri: "/template2/{name}", handler: {
  request, response in
  guard let name = request.urlVariables["name"] else {
    response.status = .badRequest
    response.completed()
    return
  }
  var values = MustacheEvaluationContext.MapType()
  values["name"] = name
  mustacheRequest(request: request, response: response, handler: MustacheHelper(values: values), templatePath: request.documentRoot + "/hello.mustache")
})*/

server.addRoutes(routes)

do {
  try server.start()
} catch PerfectError.networkError(let err, let msg) {
  print("Network error thrown: \(err) \(msg)")
}
