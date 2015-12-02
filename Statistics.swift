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
    @NSManaged var score: Int64
    @NSManaged var monstersKilled: Int32
    @NSManaged var level: Int32
    @NSManaged var tentativas: Int32
// Insert code here to add functionality to your managed object subclass

}

/* salva os dados do nivel que o usuário jogou criando uma nova entrada na tabela/entidade */
func saveLogData(hero: TBPlayerNode, bitMark: [Bool], levelSelected: Int, tentativas: Int) {
    
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
func fetchLogs(/*levelSelected: Int*/) {
    
    let moc = TBDataController().managedObjectContext
    let fetchRequest = NSFetchRequest(entityName: "Statistics")
//    fetchRequest.predicate = NSPredicate(format: "level == %d", levelSelected)
    
    do {
        let fetched = try moc.executeFetchRequest(fetchRequest) as! [Statistics]
        for (var i = 0; i < fetched.count; i++)
        {
            print("score: \(fetched[i].score), qtdMoedas: \(fetched[i].moedas), level: \(fetched[i].level)")
        }
    } catch {
        fatalError("Failed to fetch person: \(error)")
    }
}

/* salva os dados do nivel que o usuário jogou, se já passou aquele nível atualiza, se não cria uma nova entrada na tabela/entidade */
func updateLogsFetched(hero: TBPlayerNode, bitMark: [Bool], levelSelected: Int, tentativas: Int)
{
    let context:NSManagedObjectContext =  TBDataController().managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName: "Statistics")
    // faz a busca pelo nível
    fetchRequest.predicate = NSPredicate(format: "level == %d", levelSelected)
    
    // conta bits, se pegou soma 1, se não soma 0
    var bitCount: Int = 0
    bitCount += bitMark[0] ? 1: 0
    bitCount += bitMark[1] ? 1: 0
    bitCount += bitMark[2] ? 1: 0
    
    do {
        let fetchResults = try context.executeFetchRequest(fetchRequest) as! [Statistics]
        if (fetchResults.count > 0)
        {
            
            var valorAnterior: Int
            let managedObject = fetchResults[0]
            
            /* conta quantos bits o usuário já pegou em uma partida anterior
            salva se ele pegar mesma quantidade ou mais */
            var bitSaved: Int = 0
            bitSaved += managedObject.bit0 ? 1: 0
            bitSaved += managedObject.bit1 ? 1: 0
            bitSaved += managedObject.bit2 ? 1: 0
            
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
            valorAnterior = Int(managedObject.monstersKilled)
            managedObject.setValue(hero.monstersKilled, forKey: "monstersKilled")
            //só salva o score se for maior que o anterior
            valorAnterior = Int(managedObject.score)
            if(hero.score > valorAnterior)
            {
                managedObject.setValue(hero.score, forKey: "score")// >
            }
            //soma a nova quantidade a o que já tinha
            valorAnterior = Int(managedObject.tentativas)
            managedObject.setValue(tentativas + valorAnterior, forKey: "tentativas")
            
            do {
                try context.save()
                print("LogUpdated")
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
        else
        {
            saveLogData(hero, bitMark: bitMark, levelSelected: levelSelected, tentativas: tentativas)
        }
    } catch {
        fatalError("Failure to save context: \(error)")
    }
    
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


