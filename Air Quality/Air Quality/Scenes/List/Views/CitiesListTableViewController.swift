//
//  CitiesListTableViewController.swift
//  Air Quality
//
//  Created by Anthony Hoang on 1/24/18.
//  Copyright © 2018 Anthony Hoang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CitiesListTableViewController: UITableViewController {

    var viewModel: CitiesListViewModel = CitiesListViewModel()
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        self.bindTableData()
        self.viewModel.reloadCities()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
}

extension CitiesListTableViewController {
    enum Section: Int, IdentifiableType {
        case cities

        var identity: Int {
            return self.rawValue
        }
    }

    private func bindTableData() {

        typealias DataType = AnimatableSectionModel<Section, CityViewModel>

        let dataSource = RxTableViewSectionedAnimatedDataSource<DataType>(
            configureCell: { _, tableView, indexPath, model in

                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.cityCell, for: indexPath)

                cell?.textLabel?.text = model.city.name
                cell?.detailTextLabel?.text = "\(model.city.measurements)"
                return cell ?? UITableViewCell()
        })

        tableView.dataSource = nil

        viewModel
            .rxCities
            .map { userViewModels -> [DataType] in
                [AnimatableSectionModel(model: .cities, items: userViewModels)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

extension CityViewModel: IdentifiableType {

    var identity: String {
        return city.name
    }
}
