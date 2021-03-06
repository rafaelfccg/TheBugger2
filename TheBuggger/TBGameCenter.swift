//
//  TBGameCenter.swift
//  TheBuggger
//
//  Created by Allysson Lukas de Lima Andrade on 03/03/16.
//  Copyright © 2016 rfccg. All rights reserved.
//

import Foundation
import GameKit

//submete o score pra o gamecenter
func submitScoreGC(score: Int) {
    
    if(GKLocalPlayer.localPlayer().authenticated)
    {
        let scoreGC = GKScore(leaderboardIdentifier: "TBAto1.Score")
        scoreGC.value = Int64(score)
        
        GKScore.reportScores([scoreGC], withCompletionHandler: { (error: NSError?) -> Void in
            print("Score submitted")
        })
    }
}

//    func loadAchievementsPercentageGC()
//    {
//        GKAchievement.loadAchievementsWithCompletionHandler(
//            { (allAchievements, error) -> Void in
//
//                if(error != nil)
//                {
//
//                }
//                    //pode ser nil se não houver progresso
//                else if (allAchievements != nil)
//                {
//                    for theAchievement in allAchievements!
//                    {
//
//                    }
//                }
//            })
//    }

// reporta todos os achievements de tentativas
func deathAchievementGC(amount: Int)
{
    let amountDouble = Double(amount)
    reportAchievementGC("TB.1Death", percentComplete: 100.0)
    if (amount >= 50)
    {
        reportAchievementGC("TB.50Deaths", percentComplete: (amountDouble/50.0) * 100.0)
    }
    reportAchievementGC("TB.300Deaths", percentComplete: (amountDouble/300.0) * 100.0)
    reportAchievementGC("TB.500Deaths", percentComplete: (amountDouble/500.0) * 100.0)
    reportAchievementGC("TB.1000Deaths", percentComplete: (amountDouble/1000.0) * 100.0)
    
}

// reporta se completar os levels 1 ou 7
func completeLevelAchievementGC(levelSelected: Int)
{
    if(levelSelected == 1)
    {
        reportAchievementGC("TB.CompleteLevel1", percentComplete: 100)
    }
    else if(levelSelected == 7)
    {
        reportAchievementGC("TB.3Bits.Level1", percentComplete: 100)
    }
}
// reporta todos os achievements de 3 bits dos levels
func bitsAchievementGC(bitsMark: [Bool], levelSelected: Int)
{
    var numBits: Double
    numBits = Double(countBits(bitsMark))
    
    switch(levelSelected)
    {
    case 1: reportAchievementGC("TB.3Bits.Level1", percentComplete: (numBits/3.0) * 100.0)
        break
    case 2: reportAchievementGC("TB.3Bits.Level2", percentComplete: (numBits/3.0) * 100.0)
        break
    case 3: reportAchievementGC("TB.3Bits.Level3", percentComplete: (numBits/3.0) * 100.0)
        break
    case 4: reportAchievementGC("TB.3Bits.Level4", percentComplete: (numBits/3.0) * 100.0)
        break
    case 5: reportAchievementGC("TB.3Bits.Level5", percentComplete: (numBits/3.0) * 100.0)
        break
    case 6: reportAchievementGC("TB.3Bits.Level6", percentComplete: (numBits/3.0) * 100.0)
        break
    case 7: reportAchievementGC("TB.3Bits.Level7", percentComplete: (numBits/3.0) * 100.0)
        break
    default: break
    }
}

func collect21BitsAchievementGC(numBits: Int)
{
    if(numBits == 21)
    {
        let amountDouble = Double(numBits)
        reportAchievementGC("TB.Collect21Bits", percentComplete: (amountDouble/21.0)*100.0)
    }
}

func firstPowerUPAchievementGC()
{
    reportAchievementGC("TB.FirstPowerUP", percentComplete: 100.0)
}

// === só está sendo chamada(contabilizando) no final do estágio
func bugsAchievementGC(amount: Int)
{
    let amountDouble = Double(amount)
    if (amount >= 10)
    {
        reportAchievementGC("TB.Destroy10Bugs", percentComplete: 100.0)
    }
    reportAchievementGC("TB.Destroy500Bugs", percentComplete: (amountDouble/50.0) * 100.0)
}

// === só está sendo chamada(contabilizando) no final do estágio
func coinsAchievementGC(amount: Int)
{
    let amountDouble = Double(amount)
    if (amount >= 10)
    {
        reportAchievementGC("TB.Collect10Coins", percentComplete: 100.0)
    }
    reportAchievementGC("TB.Collect2000coins", percentComplete: (amountDouble/500.0) * 100.0)
}

func reportAchievementGC(identifier: String, percentComplete: Double)
{
    if(GKLocalPlayer.localPlayer().authenticated)
    {
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = percentComplete
        //por padrão é setada como false
        achievement.showsCompletionBanner = true
        
        GKAchievement.reportAchievements([achievement]) { error -> Void in
            
            if (error != nil)
            {
                print("Ocorreu um erro ao reportar um achievement, erro: \(error)")
            }
        }
    }
    
}

