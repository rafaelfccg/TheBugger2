//
//  TBGestureReconizer.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 9/28/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation


enum States:String{
    case Initial, SL, SR, SU, SD, ZDiag,ZSlideFront2,ZFinal, FAIL,Tap
}

func nextStatefor(state:States,andInput:Directions)->States{
    switch state{
    
    case .Initial:
        if(andInput == Directions.L){
            return States.SR
        }else if(andInput == Directions.O){
            return States.SL
        }else if(andInput == Directions.N){
            return States.SU
        }else if(andInput == Directions.S){
            return States.SD
        }else if(andInput == Directions.SE){
            return States.ZSlideFront2
        }else if(andInput == Directions.SO){
            return States.SL
        }else if(andInput == Directions.NO){
            return States.SL
        }else if(andInput == Directions.NE){
            return States.ZSlideFront2
        }else {
            return  States.Tap
        }
    case .SR:
        if(andInput == Directions.L){
            return States.SR
        }else if(andInput == Directions.SE){
            return States.SR
        }else if(andInput == Directions.SO){
            return States.ZDiag
        }else if(andInput == Directions.S){
            return States.ZDiag
        }else if(andInput == Directions.O){
            return States.ZDiag
        }else if(andInput == Directions.NE){
            return States.SR
        }else if (andInput == Directions.END){
            return  States.SR
        }else{
            return States.FAIL
        }
    case .ZSlideFront2:
        if(andInput == Directions.L){
            return States.SR
        }else if(andInput == Directions.SE){
            return States.ZSlideFront2
        }else if(andInput == Directions.SO){
            return States.ZDiag
        }else if(andInput == Directions.S){
            return States.ZDiag
        }else if(andInput == Directions.O){
            return States.ZDiag
        }else if(andInput == Directions.NE){
            return States.ZSlideFront2
        }else if (andInput == Directions.END){
            return  States.SR
        }else{
            return States.FAIL
        }
    case .SL:
        if(andInput == Directions.O){
            return States.SL
        }else if(andInput == Directions.SO){
            return States.SL
        }else if(andInput == Directions.END){
            return States.SL
        }else if(andInput == Directions.NO){
            return States.SL
        }else{
            return States.FAIL
        }

    case .SU:
        if(andInput == Directions.N){
            return States.SU
        }else if(andInput == Directions.NE){
            return States.SU
        }else if(andInput == Directions.NO){
            return States.SU
        }else if(andInput == Directions.END){
            return States.SU
        }else{
            return States.FAIL
        }
    case .SD:
        if(andInput == Directions.S){
            return States.SD
        }else if(andInput == Directions.SO){
            return States.SD
        }else if(andInput == Directions.SE){
            return States.SD
        }else if(andInput == Directions.END){
            return States.SD
        }else{
            return States.FAIL
        }
    case .ZDiag:
        
        if(andInput == Directions.S){
            return States.ZDiag
        }else if(andInput == Directions.L){
            return States.ZFinal
        }else if(andInput == Directions.END){
            return States.FAIL
        }else if(andInput == Directions.SO){
            return States.ZDiag
        }else if(andInput == Directions.O){
            return States.ZDiag
        }else if(andInput == Directions.SE){
            return States.ZFinal
        }else if(andInput == Directions.NE){
            return States.ZDiag
        }else{
            return States.FAIL
        }
    case .ZFinal:
        
        print("é um Z ")
        if(andInput == Directions.NE){
            return States.ZFinal
        }else if(andInput == Directions.L){
            return States.ZFinal
        }else if(andInput == Directions.SE){
            return States.ZFinal
        }else if(andInput == Directions.END){
            return States.ZFinal
        }else{
            return States.FAIL
        }
    default:
        return States.FAIL
        
        
    }
    //return States.FAIL
}

func findDirection (x:Double, y:Double) -> Directions{ //45 graus para cada direção
    let referenceSin = 0.3826834 //15deg = 0.2588190451//22.5 deg = 0.3826834
    //let norm = sqrt((x * x) + (y * y))
    let sin = y/sqrt(x*x + y*y)
    if (x > 0 && y > 0){
        if(sin < referenceSin){
            return Directions.L
        }else if (sin < 1 - referenceSin){
            return Directions.NE
        }else{
            return Directions.N
        }
    }else if(x <= 0 && y>0 ){
        if(sin < referenceSin){
            return Directions.O
        }else if (sin < 1 - referenceSin){
            return Directions.NO
        }else{
            return Directions.N
        }
    }else if(x <= 0 && y<=0 ){
        if(sin < referenceSin - 1){
            return Directions.S
        }else if (sin < -referenceSin){
            return Directions.SO
        }else{
            return Directions.O
        }
    }else{
        if(sin < referenceSin - 1){
            return Directions.S
        }else if (sin < -referenceSin){
            return Directions.SE
        }else{
            return Directions.L
        }
    }
}

enum Directions : Int{
    case N = 1, NE, L, SE, S, SO, O, NO, END
}


