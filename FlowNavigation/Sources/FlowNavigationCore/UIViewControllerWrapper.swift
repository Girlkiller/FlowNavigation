//
//  UIViewControllerWrapper.swift
//  FlowNavigation
//
//  Created by feng qiu on 2026/3/3.
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

struct UIViewControllerWrapper: UIViewControllerRepresentable {
    let vc: UIViewController
    func makeUIViewController(context: Context) -> UIViewController { vc }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
