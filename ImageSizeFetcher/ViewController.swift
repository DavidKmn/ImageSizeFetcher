//
//  ViewController.swift
//  ImageSizeFetcher
//
//  Created by David on 15/10/2018.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageUrl = URL(string: "https://cdn.123movies0.com/images//gomovies-logo-light.png")!
        let fetcher = ImageSizeFetcher()
        fetcher.sizeForImage(atURL: imageUrl) { (error, result) in
            guard let size = result?.size else { return }
            print("Image size is \(NSCoder.string(for: size))")
        }

    }


}

