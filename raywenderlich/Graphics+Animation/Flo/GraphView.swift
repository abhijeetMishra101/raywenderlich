//
//  GraphView.swift
//  Flo
//
//  Created by Abhijeet Mishra on 09/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {

    @IBInspectable var startColor:UIColor = UIColor.red
    @IBInspectable var endColor:UIColor = UIColor.green
    
    var graphPoints:[Int] = [4, 2, 6, 4, 5, 8, 3]
    
    override func draw(_ rect: CGRect) {
       
        //add clipping to the view
        let width = rect.width
        let height = rect.height
        
        let path = UIBezierPath.init(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width:8, height:8))
        path.addClip()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [startColor.cgColor, endColor.cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        
        var startPoint = CGPoint.zero
        var endPoint = CGPoint(x:0, y:bounds.height)
        
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        //calculate the x point
        let margin:CGFloat = 20.0
        let columnXPoint = { (column:Int) -> CGFloat in
            //calculate gap between points
            let spacer = (width - margin*2 - 4) /
            CGFloat((self.graphPoints.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        
        //calculate the y point
        let topBorder:CGFloat = 60
        let bottomBorder:CGFloat = 50
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPoints.max()
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            var y:CGFloat  = CGFloat(graphPoint) / CGFloat(maxValue!) * graphHeight
            y = graphHeight + topBorder - y
            return y
        }
        
        UIColor.white.setFill()
        UIColor.white.setStroke()

        let graphPath = UIBezierPath()
        
        graphPath.move(to: CGPoint(x: columnXPoint(0), y:columnYPoint(graphPoints[0])))
       
        for i in 1..<graphPoints.count {
            let nextPoint = CGPoint(x:columnXPoint(i), y:columnYPoint(graphPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        graphPath.stroke()
        
        let clippingPath = graphPath.copy() as! UIBezierPath
        clippingPath.addLine(to: CGPoint(x:columnXPoint(graphPoints.count - 1), y: height))
        clippingPath.addLine(to: CGPoint(x:columnXPoint(0),y:height))
        clippingPath.close()
        
        context?.saveGState()
        
        clippingPath.addClip()

       context?.restoreGState()
        
        let hightestYPoint = columnYPoint(maxValue!)
        startPoint = CGPoint(x:margin, y:hightestYPoint)
        endPoint = CGPoint(x:margin, y:bounds.height)
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        graphPath.lineWidth = 2
        graphPath.stroke()
        
        for i in 0..<graphPoints.count {
            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            point.x -= 5.0/2
            point.y -= 5.0/2
            
            let circlePoint = UIBezierPath.init(ovalIn: CGRect(origin: point, size:CGSize(width:5, height:5)))
        circlePoint.fill()
        }
        
        //draw 3 horizontal lines
        
        let linePath = UIBezierPath()
        
        //top line
        linePath.move(to: CGPoint(x:margin, y:topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y:topBorder))
        
        //cener line
            linePath.move(to: CGPoint(x:margin, y:height/2))
                linePath.addLine(to: CGPoint(x:width - margin, y:height/2))
        
        //bottom line
                    linePath.move(to: CGPoint(x:margin, y:height - bottomBorder))
                    linePath.addLine(to: CGPoint(x:width - margin, y: height - bottomBorder))
        
        linePath.lineWidth = 1.0
        
        UIColor.white.setStroke()
        linePath.stroke()
        
    }
}
