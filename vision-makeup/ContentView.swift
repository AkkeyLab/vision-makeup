//
//  ContentView.swift
//  vision-makeup
//
//  Created by AkkeyLab on 2023/08/11.
//

import CoreMLHelper
import SwiftUI
import Vision

struct ContentView: View {
    private let viewModel = ViewModel()

    var body: some View {
        Color.black
            .ignoresSafeArea(.all)
            .overlay {
                VStack {
                    Text("Before")
                        .foregroundColor(.white)
                        .font(.title)
                    Image("face")
                        .resizable()
                        .scaledToFit()
                    Text("After")
                        .foregroundColor(.white)
                        .font(.title)
                    viewModel.makeupLips()
                        .resizable()
                        .scaledToFit()
                }
            }
    }
}

final class ViewModel {
    // https://github.com/john-rocky/CoreML-Models#face-parsing
    typealias FaceParsing = face_parsing

    enum FaceType: Int, CaseIterable {
        // https://github.com/zllrunning/face-parsing.PyTorch/blob/d2e684cf1588b46145635e8fe7bcc29544e5537e/transform.py#L46-L47
        case upperLip = 12
        case lowerLip = 13
    }

    private let multiArray: MLMultiArray
    private let faceImage = CIImage(image: UIImage(named: "face")!)!

    init() {
        let mlModel = try! FaceParsing().model
        let coreMLModel = try! VNCoreMLModel(for: mlModel)
        let request = VNCoreMLRequest(model: coreMLModel)
        request.imageCropAndScaleOption = .scaleFill

        let requestHandler = VNImageRequestHandler(ciImage: faceImage)
        try! requestHandler.perform([request])
        let result = request.results!.first as! VNCoreMLFeatureValueObservation
        multiArray = result.featureValue.multiArrayValue!
    }

    func makeupLips() -> Image {
        let upperLipCGImage = multiArray.cgImage(min: .zero, max: 18, outputType: FaceType.upperLip.rawValue)!
        let upperLipCIImage = CIImage(cgImage: upperLipCGImage).resize(as: faceImage.extent.size)
        let lowerLipCGImage = multiArray.cgImage(min: .zero, max: 18, outputType: FaceType.lowerLip.rawValue)!
        let lowerLipCIImage = CIImage(cgImage: lowerLipCGImage).resize(as: faceImage.extent.size)

        let redArray: [CGFloat] = [2, 2, 2, 0, 0, 0, 0, 0, 0, 0.2]
        let redVector = CIVector(values: redArray, count: redArray.count)
        let greenArray: [CGFloat] = [0, 2, 0, 0, 0, 0, 0, 0, 0, 0]
        let greenVector = CIVector(values: greenArray, count: greenArray.count)
        let blueArray: [CGFloat] = [0, 0, 2, 0, 0, 0, 0, 0, 0, 0]
        let blueVector = CIVector(values: blueArray, count: blueArray.count)

        let editedCIImage = CIFilter(
            name: "CIColorCrossPolynomial",
            parameters: [
                kCIInputImageKey: faceImage,
                "inputRedCoefficients": redVector,
                "inputGreenCoefficients": greenVector,
                "inputBlueCoefficients":blueVector
            ]
        )!.outputImage!

        let compositedUpperLipImage = CIFilter(
            name: "CIBlendWithMask",
            parameters: [
                kCIInputImageKey: editedCIImage,
                kCIInputBackgroundImageKey: faceImage,
                kCIInputMaskImageKey: upperLipCIImage
            ]
        )!.outputImage!

        let compositedLowerLipImage = CIFilter(
            name: "CIBlendWithMask",
            parameters: [
                kCIInputImageKey: editedCIImage,
                kCIInputBackgroundImageKey: compositedUpperLipImage,
                kCIInputMaskImageKey: lowerLipCIImage
            ]
        )!.outputImage!

        let context = CIContext()
        let cgImage = context.createCGImage(compositedLowerLipImage, from: compositedLowerLipImage.extent)!
        return Image(uiImage: UIImage(cgImage: cgImage))
    }
}

private extension CIImage {
    func resize(as size: CGSize) -> CIImage {
        let selfSize = extent.size
        let transform = CGAffineTransform(scaleX: size.width / selfSize.width, y: size.height / selfSize.height)
        return transformed(by: transform)
    }
}

struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
