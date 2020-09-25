import Flutter
import UIKit


extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

public class SwiftNativeHttpPlugin: NSObject, FlutterPlugin {

  var session = URLSession(configuration: URLSessionConfiguration.default)

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_http", binaryMessenger: registrar.messenger())
    let instance = SwiftNativeHttpPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "native_http/request":
        let arguments = (call.arguments as? [String : AnyObject])
        
        let url = arguments!["url"] as! String
        let method = arguments!["method"] as! String
        let headers = arguments!["headers"] as! Dictionary<String, String>

        let uintInt8List =  arguments!["body"] as! FlutterStandardTypedData
        let body = uintInt8List.data

        handleCall(url:url, method:method,headers:headers, body:body, result:result)
    default:
        result("Not implemented");
    }
  }
    
    func handleCall(url: String, method: String, headers:Dictionary<String, String>, body: Data, result:@escaping FlutterResult){
        switch method {
        case "GET":
            return getCall(url:url, headers:headers, body:body, result: result);
        default:
            return dataCall(url:url, method: method, headers:headers, body:body, result: result);
        }
    }
    
    func getCall(url: String, headers:Dictionary<String, String>, body: Data, result: @escaping FlutterResult) {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        headers.forEach {(key: String, value: String) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let task = session.dataTask(with: request) {( data, response, error) in
            if(error != nil){
               result(FlutterError (code:"400", message:error?.localizedDescription, details:nil))
               return
            }
            let httpResponse = response as? HTTPURLResponse
            let responseCode = httpResponse?.statusCode
            
            var r :Dictionary = Dictionary<String, Any>()
            r["code"]  = responseCode;
            r["body"]  = FlutterStandardTypedData(bytes: data == nil ? Data.init() : data!);
            result(r);
        }
        task.resume()
    }
    
    func dataCall(url: String, method: String, headers:Dictionary<String, String>, body: Data, result: @escaping FlutterResult) {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        headers.forEach {(key: String, value: String) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.httpBody = body;

        let task = session.dataTask(with: request) {( data, response, error) in
            if(error != nil){
                result(FlutterError (code:"400", message:error?.localizedDescription, details:nil))
                return
            }
            let httpResponse = response as? HTTPURLResponse
            let responseCode = httpResponse?.statusCode
            
            var r :Dictionary = Dictionary<String, Any>()
            r["code"]  = responseCode;
            r["body"]  = FlutterStandardTypedData(bytes: data == nil ? Data.init() : data!);
            result(r);
        }
        task.resume()
    }
}
