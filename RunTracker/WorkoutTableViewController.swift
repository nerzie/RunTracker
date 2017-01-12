//
//  WorkoutTableViewController.swift
//  RunTracker
//
//  Created by nerzie on 1/2/17.
//  Copyright © 2017 nerzie. All rights reserved.
//

import UIKit
import HealthKit

class WorkoutTableViewController: UITableViewController {
    
    var healthStore: HKHealthStore?
    var workouts = [HKWorkout]()
    
    func presentErrorMessage(errorString : String) {
        let alert = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell",
                                                 for: indexPath)
        
        let workout = workouts[indexPath.row]
        
        let workoutTypeString : String
        let timeString = TimeInterval().toString(input: workout.duration)
        
        switch(workout.workoutActivityType) {
        case HKWorkoutActivityType.running:
            workoutTypeString = "Running"
        case HKWorkoutActivityType.walking:
            workoutTypeString = "Walking"
        case HKWorkoutActivityType.elliptical:
            workoutTypeString = "Elliptical"
        default:
            workoutTypeString = "Other workout"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        cell.textLabel?.text = "\(workoutTypeString) / \(timeString)"
        cell.detailTextLabel!.text = dateFormatter.string(from: workout.startDate)
        
        return cell
    }
    
    func getWorkouts() {
        
        let workoutType = HKObjectType.workoutType()
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let now = NSDate() as Date
        
        let calendar = NSCalendar.current
        
        let oneMonthAgo = calendar.date(byAdding: Calendar.Component.month, value: -1, to: now, wrappingComponents: true)
        
        let workoutPredicate = HKQuery.predicateForSamples(withStart: oneMonthAgo, end: now, options: [])
        
        let workoutQuery = HKSampleQuery(sampleType: workoutType, predicate: workoutPredicate, limit: 30, sortDescriptors: [sortDescriptor], resultsHandler: {( HKSampleQuery, results: [HKSample]?, error: Error?) -> Void in
            print("results are here")
            if error == nil {
                if let workouts = results as? [HKWorkout] {
                    self.workouts = workouts
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.tableView.reloadData()
                    }
                    
                } else {
                    self.presentErrorMessage(errorString: "Error fetching workouts")
                }
            }
        })
        healthStore?.execute(workoutQuery)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        if (HKHealthStore.isHealthDataAvailable()) {
            // ok!
            healthStore = HKHealthStore()
            
            let stepType : HKQuantityType? = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
            let distanceType : HKQuantityType? = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
            let workoutType : HKWorkoutType = HKObjectType.workoutType()
            
            let readTypes : Set = [stepType!, distanceType!, workoutType]
            let writeTypes : Set = [stepType!, distanceType!, workoutType]
            
            healthStore!.requestAuthorization(toShare: writeTypes, read: readTypes,
                completion: { (success: Bool, error: Error?) -> Void in
                // set
                    if success {
                        // success
                        // get workouts
                        
                        let backgroundQuery = HKObserverQuery(sampleType: workoutType, predicate: nil, updateHandler: { (query: HKObserverQuery,
                            handler: HKObserverQueryCompletionHandler, error: Error? ) -> Void in
                            if error == nil {
                                self.getWorkouts()
                            }
                        })
                        
                        self.healthStore?.execute(backgroundQuery)
                        self.getWorkouts()
                    } else {
                        // denied
                        self.presentErrorMessage(errorString: "HealthKit permission denied.")
                    }
                })
        } else {
            // HK unavailable
            presentErrorMessage(errorString: "HealthKit unavailable")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
