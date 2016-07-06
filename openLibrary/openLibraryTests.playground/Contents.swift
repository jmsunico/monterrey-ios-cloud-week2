//: Playground - noun: a place where people can play

import UIKit

var DEBUG = true

let queryPrefix = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys="
var queryISBN : String

if DEBUG {
	queryISBN = "ISBN:978-84-376-0494-7"
}
else{
	queryISBN = "ISBN:978-84-376-0494-7"
}

//let myQuery = NSURL(string: queryPrefix + queryISBN)
var
myQuery = NSURL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:978-84-376-0494-7")
myQuery = NSURL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:978-84-973-6467-6")

let theirResponse = NSData (contentsOfURL: myQuery!)

var infoISBN = ""
let jsonAnswer = try NSJSONSerialization.JSONObjectWithData(theirResponse!, options: NSJSONReadingOptions.MutableLeaves) //When no internet, it crashes...
print(jsonAnswer)

print("queryISBN",queryISBN)

let dictAnswer = jsonAnswer as? NSDictionary
print("dictAnswer",dictAnswer)

let dictISBN = dictAnswer!["ISBN:978-84-973-6467-6"] as? NSDictionary
print("dictISBN",dictISBN)

let dictISBN_title = dictISBN!["title"] as? String
print("dictISBN_title",dictISBN_title)


let dictISBN_pags = dictISBN!["number_of_pages"] as? Int
	let dictISBN_yearpub = dictISBN!["publish_date"] as? String
	

	let dictISBN_url = dictISBN!["url"] as? String
	infoISBN = infoISBN + " (" + dictISBN_url! + ")\n\n"
	let arrayAuthors = dictISBN!["authors"] as? NSArray

	infoISBN = infoISBN + "By: "
	for index in 0..<arrayAuthors!.count{
		let tempDict = arrayAuthors![index] as? NSDictionary
		infoISBN = infoISBN + (tempDict!["name"] as? String)! + " ("
		infoISBN = infoISBN + (tempDict!["url"] as? String)! + ")\n"
	}

	infoISBN = infoISBN + "\n Keywords: "
	let arraySubjects = dictISBN!["subjects"] as? NSArray
	for index in 0..<arraySubjects!.count{
		let tempDict = arraySubjects![index] as? NSDictionary
		infoISBN = infoISBN + (tempDict!["name"] as! String) + " "
	}
	print(infoISBN)









func sync(ISBN: String) -> NSString? {
	let url = NSURL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=" + "ISBN:978-84-376-0494-7")
	if let data: NSData = NSData(contentsOfURL: url!) {
		if let mess = NSString(data: data, encoding: NSUTF8StringEncoding) {
			let alert = UIAlertController(title: "GOOD", message: "We have Internet", preferredStyle: .Alert)
			let popup = UIAlertAction(title: "GOOD", style: .Default, handler: nil)
			alert.addAction(popup)
			return mess
		}
	}
// So no Internet?
	let mess = "Error"
	let alert = UIAlertController(title: "BAD", message: "We have no Internet", preferredStyle: .Alert)
	let popup = UIAlertAction(title: "BAD", style: .Default, handler: nil)
	alert.addAction(popup)
	return mess
}

func async2(){
	let url = NSURL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=" + "ISBN:978-84-376-0494-7")
	let session = NSURLSession.sharedSession()
	
	let block = {
		(data:NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
		if resp == nil {
			print("El servidor no existe / No hay red")
		}else{
			let mess = NSString(data: data!, encoding: NSUTF8StringEncoding)
			dispatch_async(dispatch_get_main_queue()){
				print(String(mess))
			}
		}
	}
	
	let dt = session.dataTaskWithURL(url!, completionHandler: block)
	dt.resume()
}

func async3() {
	let url = NSURL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=" + "ISBN:978-84-376-0494-7")
	let session = NSURLSession.sharedSession()
	let block = {
		(data:NSData?, resp : NSURLResponse?,error : NSError?)->Void in
		if error?.code != nil {
			print("Error")
		} else{
			print(data)
			}
	}
	
	let dt = session.dataTaskWithURL(url!, completionHandler: block)
	dt.resume()
}


func async(){
	let url = NSURL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + "978-84-376-0494-7")
	let session = NSURLSession.sharedSession()

	let block = {
		(data: NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
		if resp == nil {
			let mess : NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
			print(mess, error)
		} else {
			let mess : NSString = NSString(UTF8String: "Cannot download any data")!
			print(mess, error)
		}
	}
	
	let dt = session.dataTaskWithURL(url!, completionHandler: block)
	dt.resume()
	//to text view
}


func isConnectedToNetwork()->Bool{
	var status:Bool = false
	let url = NSURL(string: "http://google.com/")
	let request = NSMutableURLRequest(URL: url!)
	var error : NSCocoaError?
	request.HTTPMethod = "HEAD"
	request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
	request.timeoutInterval = 10.0
	
	var response: NSURLResponse?
	do{
		_ = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response) as NSData?


	}
	catch error!{
		print("Error: Could not connect to the provided address", error)
	}
	catch _{
		print("Something 148")
	}
	if let httpResponse = response as? NSHTTPURLResponse {
		if httpResponse.statusCode == 200 {
			status = true
		}
	}
	return status
}

isConnectedToNetwork()
sync()
