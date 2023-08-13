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
        let redArray: [CGFloat] = [10, 2, 1, 0, 0, 0, 0, 0, 0, 0]
        let redVector = CIVector(values: redArray, count: redArray.count)
        let greenArray: [CGFloat] = [0, 1, 0, 0, 0, 0, 0, 0, 0, 0]
        let greenVector = CIVector(values: greenArray, count: greenArray.count)
        let blueArray: [CGFloat] = [0, 0, 1, 0, 0, 0, 0, 0, 0, 0]
        let blueVector = CIVector(values: blueArray, count: blueArray.count)
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
