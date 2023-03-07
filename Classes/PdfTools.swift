//
//  TryToConvert.swift
//  TelegraphWebServer
//
//  Created by Oz Shabbat on 28/02/2023.
//

import Foundation
import UIKit
import PDFKit

// a simple utility for working with pdf file
@available(iOS 11.0, *)
public class PdfTools {
    
    lazy var tempFilePath: URL = {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let outputPath = "\(documentsPath)/output.png"
        return URL(string: outputPath)!
    }()
    
    /// Will return a pdf from data
    public static func pdfFrom(pdf data: Data) throws -> PDFDocument {
        guard let document = PDFDocument(data: data) else {
            throw AppError.customError("Failed to load PDF document")
        }
        return document
    }
    
    /// Will return a pdf from url
    public static func pdfFrom(pdf url: URL) throws -> PDFDocument {
        guard let document = PDFDocument(url: url) else {
            throw AppError.customError("Failed to load PDF document")
        }
        return document
    }
    
    /// Will return a png image from a specific page, in a pdf document
    public static func pngPageFrom(pdf document: PDFDocument, forPage at: Int) throws -> UIImage {
        
        // Get the first page of the PDF document
        guard let pdfPage = document.page(at: at) else {
            throw AppError.customError("PDF document has no pages")
        }
        
        // Create a PDF page renderer with the PDF page size
           let renderer = UIGraphicsImageRenderer(size: pdfPage.bounds(for: .cropBox).size)

           // Render the PDF page to an image
           let pngImage = renderer.image { ctx in
               // Adjust the orientation of the image context
               ctx.cgContext.translateBy(x: 0, y: pdfPage.bounds(for: .cropBox).size.height)
               ctx.cgContext.scaleBy(x: 1, y: -1)

               // Fill the background with white
               UIColor.white.set()
               ctx.fill(CGRect(origin: .zero, size: pdfPage.bounds(for: .cropBox).size))

               // Draw the PDF page to the image context
               pdfPage.draw(with: .cropBox, to: ctx.cgContext)
           }
        
        // return the image as a PNG image
        return pngImage
    }
    
    
}
