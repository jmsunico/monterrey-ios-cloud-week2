//
//  ViewController.swift
//  openLibrary
//
//  Created by José-María Súnico on 20160701.
//  Copyright © 2016 José-María Súnico. All rights reserved.
//

import UIKit

public func loadImageFromUrl(url: String, view: UIImageView){
	// Create Url from string
	let url = NSURL(string: url)!
	// Download task:
	// - sharedSession = global NSURLCache, NSHTTPCookieStorage and NSURLCredentialStorage objects.
	let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
		// if responseData is not null...
		if let data = responseData{
			// execute in UI thread
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				view.image = UIImage(data: data)
			})
		}
	}
	// Run task
	task.resume()
}




class ViewController: UIViewController {
	@IBAction func userPressedReturn(sender: UITextField) {
		let message = "User pressed <Return>. ISBN seems to be: " + self.isbnText.text!
		print(message)
		searchISBN(self.isbnText.text!)

	}
	@IBOutlet weak var isbnText: UITextField!
	@IBOutlet weak var searchResult: UITextView!
	@IBAction func ISBN1(sender: AnyObject) {
		self.isbnText.text = "978-84-376-0494-7"
	}
	@IBAction func ISBN2(sender: AnyObject) {
		self.isbnText.text = "978-84-973-6467-6"
	}
	@IBOutlet weak var book_cover: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var authorsLabel: UILabel!
	
	@IBAction func textFieldEditingbegin(sender: UITextField) {
		let message = "User started writing in the Textbox... clearing last data..."
		print(message)
		self.isbnText.text = ""
	}
	@IBAction func textFieldEditingend(sender: UITextField) {
		let message = "User pressed outside the textbox, for now I am considering, he wanted to execute the search. ISBN seems to be: " + self.isbnText.text!
		print(message)
		searchISBN(self.isbnText.text!)
	}
	@IBAction func findISBN(sender: UIButton) {
		let message = "User pressed the Search button. ISBN seems to be: " + self.isbnText.text!
		print(message)
		searchISBN(self.isbnText.text!)
	}
	
	func searchISBN(realISBN: String?) -> Bool{
		self.searchResult.text = ""
		self.book_cover.image = UIImage(named: "na-image")
		self.titleLabel.text = ""
		self.authorsLabel.text = ""
		
		if realISBN == nil {
			print("Not valid input!!!")
			return false
		}
		
		let query = String("https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + realISBN!)
		let myQuery = NSURL(string: query)
		if myQuery == nil{
			let alert = UIAlertController(title: "NO VALID QUERY!", message: "'\(myQuery)'", preferredStyle: .Alert)
			let accion = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alert.addAction(accion)
			self.presentViewController(alert, animated: true, completion: nil)
			return false
		}
		
		var infoISBN : String = ""
		let jsonAnswer: AnyObject?
		do{ //trying to process response
			let theirResponse = NSData(contentsOfURL: myQuery!)
			if theirResponse == nil {
				throw NSURLError.BadServerResponse
			}
			 jsonAnswer = try NSJSONSerialization.JSONObjectWithData((theirResponse)!, options: NSJSONReadingOptions.MutableLeaves)
		}
		catch _{
			let alert = UIAlertController(title: "NO INTERNET ?", message: "Check Internet connection / Flight mode please.", preferredStyle: .Alert)
			let popup = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alert.addAction(popup)
			self.presentViewController(alert, animated: true, completion: nil)
			return false
		}
	
		let dictAnswer = jsonAnswer as? NSDictionary
		if dictAnswer == nil {
			let alert = UIAlertController(title: "NO VALID JSON!", message: "Main NSDictionary, failed!", preferredStyle: .Alert)
			let accion = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alert.addAction(accion)
			self.presentViewController(alert, animated: true, completion: nil)
			return false
		}
			
		let dictISBN = dictAnswer!["ISBN:" + realISBN!] as? NSDictionary
		if dictISBN == nil {
			let alert = UIAlertController(title: "NO VALID ISBN!", message: "ISBN not valid, inexistent in DDBB or JSON malformed.!", preferredStyle: .Alert)
			let accion = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alert.addAction(accion)
			self.presentViewController(alert, animated: true, completion: nil)
			return false
		}
		
		let dictISBN_title = dictISBN!["title"] as? String
		if dictISBN_title == nil {
			self.titleLabel.text = "TITLE FIELD NOT FOUND!"
			return false
		} else{
			self.titleLabel.text = "Title:\n" + dictISBN_title!
		}
		let dictISBN_cover = dictISBN!["cover"] as? NSDictionary
		if dictISBN_cover == nil{
			self.book_cover.image = UIImage(named: "na-image")
		}
		else{
			let coverURLsmall = dictISBN_cover!["small"] as? String
			let coverURLmedium = dictISBN_cover!["medium"] as? String
			let coverURLlarge = dictISBN_cover!["large"] as? String

			if coverURLlarge != nil {
				loadImageFromUrl(coverURLlarge!, view: book_cover)
			} else if coverURLmedium != nil {
				loadImageFromUrl(coverURLlarge!, view: book_cover)
			} else if coverURLsmall != nil {
				loadImageFromUrl(coverURLsmall!, view: book_cover)
			}
		}
		let dictISBN_yearpub = dictISBN!["publish_date"] as? String
		if dictISBN_yearpub == nil {
			print("PUBLICATION DATE FIELD NOT FOUND!")
		} else{
			infoISBN = infoISBN + realISBN! + " - " + dictISBN_title!
			infoISBN = infoISBN + " (published in " + dictISBN_yearpub! + ")\n"
			print(infoISBN)
		}
		let dictISBN_url = dictISBN!["url"] as? String
		if dictISBN_url == nil {
			print("URL FIELD NOT FOUND!")
		} else{
			infoISBN = infoISBN + " (" + dictISBN_url! + ")\n\n"
		}
		var authors = "Authors: \n"
		let arrayAuthors = dictISBN!["authors"] as? NSArray
		if arrayAuthors == nil {
			self.authorsLabel.text = "AUTHORS NOT FOUND!"
		} else{
			for index in 0..<arrayAuthors!.count{
				let tempDict = arrayAuthors![index] as! NSDictionary
				authors = authors + (tempDict["name"] as! String) + " ("
				authors = authors + (tempDict["url"] as! String) + ")\n"
				self.authorsLabel.text = authors
				infoISBN = infoISBN + authors
			}
		}
		print(infoISBN)
	

		infoISBN = infoISBN + "\n Keywords: "
		let arraySubjects = dictISBN!["subjects"] as? NSArray
		if arraySubjects != nil{
			for index in 0..<arraySubjects!.count{
				let tempDict = arraySubjects![index] as! NSDictionary
				infoISBN = infoISBN + (tempDict["name"] as! String) + " "
			}
		}
		infoISBN = infoISBN + "\n\nComplete JSON\n" + "============\n" + String(jsonAnswer!)
	
		print(infoISBN)
		self.searchResult.text = infoISBN
		return true
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.searchResult.text = ""
		self.isbnText.keyboardType = UIKeyboardType.Default
		self.isbnText.returnKeyType = .Search
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

/*
JSON Answer example
===================
"ISBN:978-84-376-0494-7":{
	"publishers": [{"name": "C\u00e1tedra"}],
	"pagination": "550 p. :",
	"identifiers": {"openlibrary": ["OL20654427M"], "isbn_10": ["843760494X"], "librarything": ["5864"], "goodreads": ["789385"]},
	"title": "Cien a\u00f1os de soledad",
	"url": "https://openlibrary.org/books/OL20654427M/Cien_a\u00f1os_de_soledad",
	"notes": "Includes bibliographical references (p. 57-78).",
	"number_of_pages": 550,
	"subject_places": [
		{"url": "https://openlibrary.org/subjects/place:latin_america", "name": "Latin America"},
		{"url": "https://openlibrary.org/subjects/place:am\u00e9rica_latina", "name": "Am\u00e9rica Latina"},
		{"url": "https://openlibrary.org/subjects/place:colombia", "name": "Colombia"}
		],
	"subjects": [
		{"url": "https://openlibrary.org/subjects/fiction", "name": "Fiction"},
		{"url": "https://openlibrary.org/subjects/macondo_(imaginary_place)", "name": "Macondo (Imaginary place)"},
		{"url": "https://openlibrary.org/subjects/social_conditions", "name": "Social conditions"},
		{"url": "https://openlibrary.org/subjects/novela", "name": "Novela"},
		{"url": "https://openlibrary.org/subjects/condiciones_sociales", "name": "Condiciones sociales"},
		{"url": "https://openlibrary.org/subjects/translations_into_russian", "name": "Translations into Russian"},
		{"url": "https://openlibrary.org/subjects/spanish_language_materials", "name": "Spanish language materials"},
		{"url": "https://openlibrary.org/subjects/criticism_and_interpretation", "name": "Criticism and interpretation"},
		{"url": "https://openlibrary.org/subjects/colombian_fiction", "name": "Colombian fiction"},
		{"url": "https://openlibrary.org/subjects/macondo_(lugar_imaginario)", "name": "Macondo (Lugar imaginario)"},
		{"url": "https://openlibrary.org/subjects/protected_daisy", "name": "Protected DAISY"}
		],
	"subject_people": [
		{"url": "https://openlibrary.org/subjects/person:gabriel_garc\u00eda_m\u00e1rquez_(1928-)",
		"name": "Gabriel Garc\u00eda M\u00e1rquez (1928-)"}
		],

	"key": "/books/OL20654427M",
	"authors": [
		{
			"url": "https://openlibrary.org/authors/OL4586796A/Gabriel_Garcia_Marquez", 
			"name": "Gabriel Garcia Marquez"}
		],
	"publish_date": "2004",
	"by_statement": "Gabriel Garc\u00eda M\u00e1rquez ; edici\u00f3n de Jacques Joset.",
	"publish_places": [{"name": "Madrid"}],
	"subject_times": [
		{"url": "https://openlibrary.org/subjects/time:20th_century", "name": "20th century"}
	]
}
*/