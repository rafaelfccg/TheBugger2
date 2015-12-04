//
//  Statistics.swift
//  TheBuggger
//
//  Created by Allysson Lukas de Lima Andrade on 30/11/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import CoreData


class Statistics: NSManagedObject {

    @NSManaged var bit0: Bool
    @NSManaged var bit1: Bool
    @NSManaged var bit2: Bool
    @NSManaged var moedas: Int32
    @NSManaged var score: Int32
    @NSManaged var monstersKilled: Int32
    @NSManaged var monstersTotalKilled: Int32
    @NSManaged var level: Int32
    @NSManaged var tentativas: Int32
// Insert code here to add functionality to your managed object subclass

}

/* salva os dados do nivel que o usuário jogou criando uma nova entrada na tabela/entidade */
func createLogData(hero: TBPlayerNode, bitMark: [Bool], levelSelected: Int, tentativas: Int)
{
    // create an instance of our managedObjectContext
    let moc = TBDataController().managedObjectContext
    
    // we set up our entity by selecting the entity and context that we're targeting
    let entity = NSEntityDescription.insertNewObjectForEntityForName("Statistics", inManagedObjectContext: moc) as! Statistics

    // add our data
    entity.setValue(bitMark[0], forKey: "bit0")
    entity.setValue(bitMark[1], forKey: "bit1")
    entity.setValue(bitMark[2], forKey: "bit2")
    entity.setValue(hero.qtdMoedas, forKey: "moedas")
    entity.setValue(hero.monstersKilled, forKey: "monstersKilled")
    entity.setValue(hero.monstersKilled, forKey: "monstersTotalKilled")
    entity.setValue(hero.score, forKey: "score")
    entity.setValue(tentativas, forKey: "tentativas")
    entity.setValue(levelSelected, forKey: "level")
    
    // we save our entity
    do {
        try moc.save()
        print("LogSaved")
    } catch {
        fatalError("Failure to save context: \(error)")
    }
}


/* busca todas as entradas da tabela/entidade */
func fetchLogs() -> [Statistics]!
{
    var statisticsArray: [Statistics]! = nil
    let moc = TBDataController().managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "Statistics")
    
    do {
        let fetched = try moc.executeFetchRequest(fetchRequest) as! [Statistics]
       if(fetched.count > 0)
        {
            statisticsArray = fetched
        }
    } catch {
        fatalError("Failed to fetch person: \(error)")
    }
    statisticsArray.sortInPlace({ $0.level < $1.level })
    
    return statisticsArray
}

/* busca valores salvos pelo nível */
func fetchLogsByLevel(levelSelected: Int) -> Statistics!
{
    var levelStatistics: Statistics! = nil
    let moc = TBDataController().managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "Statistics")
    fetchRequest.predicate = NSPredicate(format: "level == %d", levelSelected)
    
    do {
        let fetched = try moc.executeFetchRequest(fetchRequest) as! [Statistics]
        if(fetched.count > 0){
            levelStatistics = fetched[0]
        }
    } catch {
        fatalError("Failed to fetch person: \(error)")
    }
    
    return levelStatistics
}

/* salva os dados do nivel que o usuário jogou, se já passou aquele nível atualiza, se não cria uma nova entrada na tabela/entidade */
func saveLogsFetched(hero: TBPlayerNode, bitMark: [Bool], levelSelected: Int, tentativas: Int)
{
    let context:NSManagedObjectContext =  TBDataController().managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName: "Statistics")
    // seta a busca pelo nível
    fetchRequest.predicate = NSPredicate(format: "level == %d", levelSelected)
    
    let bitCount: Int = countBits(bitMark)
    
    do {
        let fetchResults = try context.executeFetchRequest(fetchRequest) as! [Statistics]
        if (fetchResults.count > 0)
        {
            
            var valorAnterior: Int
            let managedObject = fetchResults[0]
            
            /* conta quantos bits o usuário já pegou em uma partida anterior
            salva se ele pegar mesma quantidade ou mais */
            let bitSaved: Int = countBits([managedObject.bit0, managedObject.bit1, managedObject.bit2])
            
            if(bitCount >= bitSaved)
            {
                managedObject.setValue(bitMark[0], forKey: "bit0")
                managedObject.setValue(bitMark[1], forKey: "bit1")
                managedObject.setValue(bitMark[2], forKey: "bit2")
            }
            //soma a nova quantidade a o que já tinha
            valorAnterior = Int(managedObject.moedas)
            managedObject.setValue(hero.qtdMoedas + valorAnterior, forKey: "moedas")
            
            //soma a nova quantidade a o que já tinha
            valorAnterior = Int(managedObject.monstersTotalKilled)
            managedObject.setValue(hero.monstersKilled + valorAnterior, forKey: "monstersTotalKilled")
            
            //só salva se for maior que o anterior
            valorAnterior = Int(managedObject.monstersKilled)
            if(hero.monstersKilled > valorAnterior)
            {
                managedObject.setValue(hero.monstersKilled, forKey: "monstersKilled")
            }
            
            //só salva o score se for maior que o anterior
            valorAnterior = Int(managedObject.score)
            if(hero.score > valorAnterior)
            {
                managedObject.setValue(hero.score, forKey: "score")
            }
            
            //salva só o valor atualizado
            managedObject.setValue(tentativas, forKey: "tentativas")
            
            //salva
            do {
                try context.save()
                print("LogUpdated")
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
        else
        {
            createLogData(hero, bitMark: bitMark, levelSelected: levelSelected, tentativas: tentativas)
        }
    } catch {
        fatalError("Failure to save context: \(error)")
    }
    
}


func saveAttempts(levelSelected: Int, tentativas: Int)
{
    let context:NSManagedObjectContext =  TBDataController().managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName: "Statistics")
    // seta a busca pelo nível
    fetchRequest.predicate = NSPredicate(format: "level == %d", levelSelected)
    
    do {
        let fetchResults = try context.executeFetchRequest(fetchRequest) as! [Statistics]
        if (fetchResults.count > 0)
        {
            let managedObject = fetchResults[0]
            
            //atualiza apenas o número de tentativas
            managedObject.setValue(tentativas, forKey: "tentativas")
            
            //salva
            do {
                try context.save()
                print("AttemptsUpdated")
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
        else
        {
            // se não existe registro salva as tentativas e setas os outros valores como 0/false
            let entity = NSEntityDescription.insertNewObjectForEntityForName("Statistics", inManagedObjectContext: context) as! Statistics

            entity.setValue(false, forKey: "bit0")
            entity.setValue(false, forKey: "bit1")
            entity.setValue(false, forKey: "bit2")
            entity.setValue(0, forKey: "moedas")
            entity.setValue(0, forKey: "monstersKilled")
            entity.setValue(0, forKey: "monstersTotalKilled")
            entity.setValue(0, forKey: "score")
            entity.setValue(tentativas, forKey: "tentativas")
            entity.setValue(levelSelected, forKey: "level")
            
            do {
                try context.save()
                print("AttemptsSaved")
            } catch {
                fatalError("Failure to save context: \(error)")
            }

        }
    } catch {
        fatalError("Failure to save context: \(error)")
    }
    
}

/* retorna o numero de bits que o usuário pegou (converte de Bool pra Int) */
func countBits(bitMark: [Bool]) -> Int
{
    var bitCount: Int = 0
    bitCount += bitMark[0] ? 1: 0
    bitCount += bitMark[1] ? 1: 0
    bitCount += bitMark[2] ? 1: 0
    
    return bitCount
}


/* função que sempre atualiza os dados da tabela com os novos valores se a entrada da tabela/entidade já existir */
//func updateLogs(hero: TBPlayerNode, bitMark: [Bool], levelSelected: Int, tentativas: Int)
//{
//    let context:NSManagedObjectContext =  TBDataController().managedObjectContext
//    
//    let entity = NSEntityDescription.entityForName("Statistics", inManagedObjectContext: context)
//    
//    let batchUpdateRequest = NSBatchUpdateRequest(entity: entity!)
//    batchUpdateRequest.predicate = NSPredicate(format: "level == %d", levelSelected)
//    batchUpdateRequest.resultType = NSBatchUpdateRequestResultType.UpdatedObjectIDsResultType
//    batchUpdateRequest.propertiesToUpdate = [
//        "bit0": bitMark[0],
//        "bit1": bitMark[1],
//        "bit2": bitMark[2],
//        "moedas": hero.qtdMoedas,
//        "monstersKilled": hero.monstersKilled,
//        "score": hero.score,
//        "tentativas": tentativas,
//        "level": levelSelected
//    ]
//    do {
//        try context.executeRequest(batchUpdateRequest)
//        print("LogUpdated")
//    } catch {
//        fatalError("Failure to save context: \(error)")
//    }
//}


