//
//  ContentView.swift
//  vision-makeup
//
//  Created by AkkeyLab on 2023/08/11.
//

import SwiftUI
import Vision

struct ContentView: View {
    private let viewModel = ViewModel()

    var body: some View {
        VStack {
            Text("Before")
            Image("lips")
                .resizable()
                .scaledToFit()
            Text("After")
            editedImage()
                .resizable()
                .scaledToFit()
            Text("Real")
            Image("makeup")
                .resizable()
                .scaledToFit()
        }
    }

    func editedImage() -> Image {
        let image = UIImage(named: "lips")!
        let ciImage = CIImage(image: image)!
        let redArray: [CGFloat] = [2, 2, 2, 0, 0, 0, 0, 0, 0, 0.2]
        let redVector = CIVector(values: redArray, count: redArray.count)
        let greenArray: [CGFloat] = [0, 2, 0, 0, 0, 0, 0, 0, 0, 0]
        let greenVector = CIVector(values: greenArray, count: greenArray.count)
        let blueArray: [CGFloat] = [0, 0, 2, 0, 0, 0, 0, 0, 0, 0]
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

final class ViewModel {
    typealias FaceParsing = face_parsing

    func lipsDetect() {
        let mlModel = try! FaceParsing().model
        let coreMLModel = try! VNCoreMLModel(for: mlModel)
        let request = VNCoreMLRequest(model: coreMLModel)
        request.imageCropAndScaleOption = .scaleFill

        let image = CIImage(image: UIImage(named: "face")!)!
        let requestHandler = VNImageRequestHandler(ciImage: image)
        try! requestHandler.perform([request])

        let result = request.results!.first as! VNCoreMLFeatureValueObservation
        let multiArray = result.featureValue.multiArrayValue
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
