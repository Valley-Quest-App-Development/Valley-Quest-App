//
//  ViewController.swift
//  Parse Modifier
//
//  Created by John Kotz on 8/22/16.
//  Copyright © 2016 John Kotz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    // Name the process you are doing
    let processName = "Delete object test"
    
    // This is where I will place code for performing an action
    // I should run done when I finish, and error if I fail
    // I should call updateProgress when I have an update in my progress
    func go(_ value: String, query: String) {
        let mod = Modifier.BookUpModifyer(value: value, query: query)
        mod.tryRemoveItem({ (string) in
            self.logMessage(string, newLine: true)
        }, { (success) in
            self.done(success ? "Test was successful" : "Test failed!")
        })
    }
    
    func bookupRemoveBuilings(_ mod: Modifier.BookUpModifyer) {
        
        self.logMessage("Searching...", newLine: true)
        mod.search { (error) in
            if let error = error {
                self.error(String(describing: error))
                return
            }
            self.logMessage(" done", newLine: false)
            self.initProgress(Double(mod.buildings.count) + 1)
            self.updateProgress(1)
            
            if (mod.buildings.count == 0) {
                self.done("No results found");
                return;
            }
            
            self.logMessage("Deleting...", newLine: true)
            mod.removeAllBuildings({ (done: Bool, error: NSError?) in
                if let error = error {
                    self.logMessage("ERROR!: " + String(describing: error), newLine: true)
                }
                
                if done {
                    
                    self.updateProgress(Double(mod.buildings.count) + 1)
                    
                    self.logMessage(" done", newLine: false)
                    self.done("Deleted the following buildings:\n-----------\n" + MapBuildings.getNamesString(mod.buildings, separator: "\n"))
                }
                
                
            }, progress: { (val) in
                self.updateProgress(Double(val) + 1)
            })
        }
    }
    
    func bookupSearch(_ mod: Modifier.BookUpModifyer) {
        
        self.logMessage("Searching...", newLine: true)
        mod.search { (error) in
            if let error = error {
                self.error(String(describing: error))
                return
            }
            self.logMessage(" done", newLine: false)
            
            self.done(MapBuildings.getNamesString(mod.buildings, separator: "\n"))
        }
    }
    
    // -- My functions --
    
    func makeAllClosed(_ mod: Modifier.QuestMod) {
        self.logMessage("Loading...", newLine: true)
        mod.loadQuests { (error) in
            self.logMessage(" done", newLine: false)
            
            self.logMessage("Splitting...", newLine: true)
            mod.splitQuestsWithSeperator("&")
            self.logMessage(" done", newLine: false)
            
            self.initProgress(Double(2 + mod.quests.count * mod.givenQuestNames.count + mod.quests.count))
            
            
            self.logMessage("Compiling...", newLine: true)
            var i = 0;
            
            var closedQuests = [Quest]()
            for quest in mod.quests {
                var x = 0;
                for name in mod.givenQuestNames {
                    self.updateProgress(Double(2 + x * i))
                    let name1 = quest.Name
                    
                    let difference = zip(name.characters, name1.characters).filter{$0 != $1}
                    
                    if difference.count < 12 || name1.contains(name) || name.contains(name1) {
                        
                        quest.closed = true
                        closedQuests.append(quest)
                    }
                    x += 1;
                }
                i += 1;
            }
            self.logMessage(" done", newLine: false)
            
            self.logMessage("Saving...", newLine: true)
            mod.saveAll({ (error) in
                self.done(Quest.getNamesString(closedQuests, separator: "\n"))
                }, progress: { (progress) in
                    self.initProgress(Double(2 + mod.quests.count * mod.givenQuestNames.count + progress))
            })
        }
    }
    
    func searchAndDelete(_ mod: Modifier.QuestMod) {
        self.logMessage("Searching...", newLine: true)
        mod.search { (error) in
            if let error = error {
                self.error(String(describing: error))
                return
            }
            
            self.initProgress(Double(2 + mod.quests.count))
            
            self.logMessage(" done", newLine: false)
            self.updateProgress(1)
            
            self.logMessage("Compiling...", newLine: true)
            let string = Quest.getNamesAndLocsString(mod.quests, separator: "\n")
            self.logMessage(" done", newLine: false)
            
            self.updateProgress(2)
            
            self.logMessage("Deleting...", newLine: true)
            var i = 0;
            for quest in mod.quests {
                quest.deleteInBackground(block: { (success, error) in
                    i += 1;
                    self.initProgress(Double(2 + i))
                    
                    if i >= mod.quests.count - 1 {
                        self.logMessage(" done", newLine: false)
                        self.done(string)
                    }
                })
            }
        }
    }
    
    func search(_ mod: Modifier.QuestMod) {
        self.initProgress(2)
        self.logMessage("Searching...", newLine: true)
        mod.search { (error) in
            if let error = error {
                self.error(String(describing: error))
                return
            }
            
            self.logMessage(" done", newLine: false)
            self.updateProgress(1)
            
            self.logMessage("Compiling...", newLine: true)
            let string = Quest.getNamesAndLocsString(mod.quests, separator: "\n")
            self.logMessage(" done", newLine: false)
            
            self.updateProgress(2)
            
            self.done(string)
        }
    }
    
    func getNames(_ mod: Modifier.QuestMod) {
        self.logMessage("Loading quests...", newLine: true)
        mod.loadQuests { (error) in
            if let error = error {
                self.error(String(describing: error))
                return
            }
            self.logMessage(" done", newLine: false)
            
            self.initProgress(Double(mod.quests.count) + 1)
            self.updateProgress(Double(mod.quests.count))
            
            self.logMessage("Compiling...", newLine: true)
            let string = Quest.getNamesString(mod.quests, separator: "\n")
            self.updateProgress(Double(mod.quests.count) + 1)
            
            self.logMessage(" done", newLine: false)
            
            self.done(string)
        }
    }
    
    func repairAllClosed(_ mod: Modifier.QuestMod) {
        self.logMessage("Loading quests...", newLine: true)
        mod.loadQuests { (error) in
            if let error = error {
                self.error(String(describing: error))
                return
            }
            self.logMessage(" done", newLine: false)
            
            self.initProgress(Double(mod.quests.count) + 2)
            self.updateProgress(1)
            
            self.logMessage("Compiling...", newLine: true)
            mod.compileClosed()
            
            self.logMessage(" done", newLine: false)
            
            self.updateProgress(2)
            
            self.logMessage("Saving...", newLine: true)
            mod.saveAll({ (error) in
                if let error = error {
                    self.error(String(describing: error))
                    return
                }
                self.logMessage(" done", newLine: false)
                
                self.done("Complete")
                
            }, progress: { (val) in
                self.updateProgress(Double(val) + 2)
            })
        }
    }
    
    func getAllNeedingPDFs(_ mod: Modifier.QuestMod) {
        self.logMessage("Loading quests...", newLine: true)
        mod.loadQuests { (error) in
            if let error = error {
                self.error(String(describing: error))
                return
            }
            self.logMessage(" done", newLine: false)
            
            self.initProgress(Double(mod.quests.count) + 3)
            self.updateProgress(Double(mod.quests.count) + 1)
            
            self.logMessage("Compiling...", newLine: true)
            mod.compileClosed()
            
            self.logMessage(" done", newLine: false)
            
            self.updateProgress(Double(mod.quests.count) + 2)
            
            self.logMessage(" done", newLine: false)
            
            self.logMessage("Calculating quests needing pdfs...", newLine: true)
            var quests = mod.getQuestsNeedingPDF()
            Quest.sortQuests(&quests)
            
            self.updateProgress(Double(mod.quests.count) + 3)
            self.logMessage(" done", newLine: false)
            
            self.logMessage("Generating string...", newLine: true)
            let string = Quest.getNamesString(quests, separator: "\n")
            self.logMessage(" done", newLine: false)
            
            self.done(string);
        }
    }
    
    
    
    
    
    @IBOutlet weak var valueField: NSTextField!
    @IBOutlet weak var queryField: NSTextField!
    @IBOutlet weak var goButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!
    @IBOutlet var resultsField: NSTextView!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var goTopConstraint: NSLayoutConstraint!
    
    
    var log: String = ""
    func logMessage(_ string: String, newLine: Bool) {
        if log != "" && newLine {
            log += "\n"
        }
        
        log += string
        
        resultsField.string = log
    }
    
    func updateProgress(_ val: Double) {
        progressIndicator.doubleValue = val
    }
    
    func initProgress(_ val: Double) {
        progressIndicator.maxValue = val
    }
    
    @IBAction func goButtonPressed(_ sender: AnyObject) {
        let value = valueField.stringValue
        let query = queryField.stringValue
        valueField.isEnabled = false
        queryField.isEnabled = false
        goButton.isEnabled = false
        cancelButton.isEnabled = true
        
        resultsField.string = ""
        resultsField.textColor = NSColor.black
        activityIndicator.startAnimation(self)
        activityIndicator.isHidden = false
        progressIndicator.doubleValue = 0
        progressIndicator.startAnimation(self)
        
        log = ""
        
        go(value, query: query)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        error("Canceled");
    }
    
    func done(_ results: String){
        valueField.isEnabled = true
        goButton.isEnabled = true
        queryField.isEnabled = true
        cancelButton.isEnabled = false
        
        resultsField.textColor = NSColor.black
        progressIndicator.doubleValue = 0
        resultsField.string = "\(log)\n----Results----\n\(results)"
        progressIndicator.stopAnimation(self)
        activityIndicator.stopAnimation(self)
        activityIndicator.isHidden = true
    }
    
    func error(_ error: String) {
        valueField.isEnabled = true
        goButton.isEnabled = true
        queryField.isEnabled = true
        cancelButton.isEnabled = false
        
        resultsField.textColor = NSColor.red
        progressIndicator.doubleValue = 0
        resultsField.string = "\(log)\n----Results----\n\(error)"
        progressIndicator.stopAnimation(self)
        activityIndicator.stopAnimation(self)
        activityIndicator.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.stringValue = processName
        // Do any additional setup after loading the view.
    }
}

