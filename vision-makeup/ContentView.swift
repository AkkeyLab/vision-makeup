//
//  ContentView.swift
//  vision-makeup
//
//  Created by AkkeyLab on 2023/08/11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Before")
            Image("color_test")
                .resizable()
                .scaledToFit()
            Text("After")
            editedImage()
                .resizable()
                .scaledToFit()
        }
    }

    func editedImage() -> Image {
        let image = UIImage(named: "color_test")!
        let ciImage = CIImage(image: image)!
        let redVector = CIVector(x: 10, y: 2, z: 1)
        let greenVector = CIVector(x: 0, y: 1, z: 0)
        let blueVector = CIVector(x: 0, y: 0, z: 1)
        let editedCIImage = CIFilter(
            name: "CIColorCrossPolynomial",
            parameters: [
                kCIInputImageKey: ciImage,
                "inputRedCoefficients": redVector,
                "inputGreenCoefficients": greenVector,
                "inputBlueCoefficients":blueVector
            ]
        )!.outputImage!
        let context = CIContext()
        let cgImage = context.createCGImage(editedCIImage, from: editedCIImage.extent)!
        return Image(uiImage: UIImage(cgImage: cgImage))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
