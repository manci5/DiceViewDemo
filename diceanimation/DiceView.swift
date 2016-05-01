
import UIKit


enum DiceColor: Int {
    case White = 0
    case Red = 1
    case Blue = 2
}

class DiceView: UIView {
    
    var color: DiceColor
    
    var number: Int
    
    override var frame: CGRect {
        didSet {
            self.repositionDots()
        }
    }
    
    
    private var diceImage: UIImageView
    private var dots: [UIImageView]
    
    
    init(frame: CGRect, color: DiceColor, number: Int) {
        
        diceImage = UIImageView(frame: CGRectMake(0, 0, frame.width, frame.height))
        diceImage.image = UIImage(named: "Dice\(color.rawValue)")
        
        dots = []        
        
        for _ in 0..<7 {
            let dot = UIImageView(frame: CGRectMake(0,0,frame.width*0.2, frame.height*0.2))
            dot.image = UIImage(named: "Dot\(color.rawValue == 0 ? "Black" : "White")")
            dots.append(dot)
        }
        
        self.color = color
        self.number = number
        
        super.init(frame: frame)
        
        self.addSubview(diceImage)
        
        for dot in self.dots {
            dot.image = UIImage(named: "Dot\(color == .White ? "Black" : "White")")
            self.addSubview(dot)
        }
        
        switch number {
        case 1:
            showDots(4)
        case 2:
            showDots(3, 5)
        case 3:
            showDots(3, 4, 5)
        case 4:
            showDots(1, 3, 5, 7)
        case 5:
            showDots(1, 3, 4, 5, 7)
        case 6:
            showDots(1, 2, 3, 5, 6, 7)
        default:
            showDots()
        }
        
        self.repositionDots()

        
    }
    
    
    func repositionDots(){
        
        for dot in dots { dot.frame = CGRectMake(0,0,frame.width*0.2, frame.height*0.2) }
        
        dots[0].center = CGPointMake(0.25*frame.width, 0.25*frame.width)
        dots[1].center = CGPointMake(0.50*frame.width, 0.25*frame.width)
        dots[2].center = CGPointMake(0.75*frame.width, 0.25*frame.width)
        dots[3].center = CGPointMake(0.50*frame.width, 0.50*frame.width)
        dots[4].center = CGPointMake(0.25*frame.width, 0.75*frame.width)
        dots[5].center = CGPointMake(0.50*frame.width, 0.75*frame.width)
        dots[6].center = CGPointMake(0.75*frame.width, 0.75*frame.width)
    }
    
    func showDots(list: Int...){
        
        for dot in self.dots{
            dot.hidden = true
        }
        for number in list {
            dots[number-1].hidden = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
