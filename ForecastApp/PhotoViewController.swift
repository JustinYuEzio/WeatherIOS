//
//  PhotoViewController.swift
//  ForecastApp
//
//  Created by Hengyi Yu on 11/24/19.
//  Copyright © 2019 Hengyi Yu. All rights reserved.
//

import UIKit
import SwiftSpinner
class PhotoViewController: UIViewController, ImageDelegate {
    var httpRequest = HttpRequest()
    var image: ImageData?
    var cityName: String?
    var links: [URL]?
    @IBOutlet weak var scrollView: UIScrollView!
    var loadedImages = [UIImage()]
    override func viewDidLoad() {
        super.viewDidLoad()
        httpRequest.imageDelegate = self
        httpRequest.getImage(cityName: cityName!)
    }

    func didGetImage(image: ImageData) {
        self.image = image

        for i in 0..<9 {
            let imageView = UIImageView()
            let y = self.view.frame.size.height * CGFloat(i)
            //let link = image.items[i].pagemap.cse_image[0].src
            let link = "https://i.ytimg.com/vi/GYGO2hsiTNc/maxresdefault.jpg"
            print(link)
            print(image.items[i].kind)
            imageView.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height)
            imageView.contentMode = .scaleAspectFill
            getImageFromWeb(link) { (image) in
                if let image = image {
                    imageView.image = image
                }
            }
            scrollView.contentSize.height = scrollView.frame.size.height * CGFloat(i + 1)
            scrollView.addSubview(imageView)
            
        }
        SwiftSpinner.hide()
    }
}
   func getImageFromWeb(_ urlString: String, closure: @escaping (UIImage?) -> ()) {
        guard let url = URL(string: urlString) else {
            return closure(nil)
        }
        let task = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("error: \(String(describing: error))")
                return closure(nil)
            }
            guard response != nil else {
                print("no response")
                return closure(nil)
            }
            guard data != nil else {
                print("no data")
                return closure(nil)
            }
            DispatchQueue.main.async {
                closure(UIImage(data: data!))
            }
        }; task.resume()
    }

