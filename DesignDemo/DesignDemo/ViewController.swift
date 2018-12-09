//
//  ViewController.swift
//  DesignDemo
//
//  Created by WangBing on 2018/12/9.
//  Copyright © 2018年 WangBing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var iOSDocumentsDirectory = iOSAppFileSystemDirectory(.Documents)
        iOSDocumentsDirectory.writeFile("skfjkdjfkdjfd\n", "text.txt")
        iOSDocumentsDirectory.writeFile("1234555", "text.txt")
        iOSDocumentsDirectory.list()
        iOSDocumentsDirectory.readFile("text.txt")
        iOSDocumentsDirectory.showAttributes(name: "text.txt")
        iOSDocumentsDirectory.deleteFile("text.txt")
    }


}

