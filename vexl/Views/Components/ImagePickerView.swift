//
//  ImagePickerView.swift
//  vexl
//
//  Created by Diego Espinoza on 8/04/22.
//

import SwiftUI
import UIKit

/// ImagePicker will compress in 50% the image before returning it.

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    /// The selected image is compressed by 50%
    @Binding var selectedImage: Data?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
               let imageData = image.resizeWithScaleAspectFitMode(to: Constants.maxImageSize)?.jpegData(compressionQuality: 0.5) {
                parent.selectedImage = imageData
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
