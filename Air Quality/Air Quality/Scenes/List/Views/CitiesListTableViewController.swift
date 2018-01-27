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
import SwiftMessages

class CitiesListTableViewController: UITableViewController {

    var viewModel: CitiesListViewModel = CitiesListViewModel()
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(CitiesListTableViewController.refresh), for: .valueChanged)

        self.viewModel.rxError.subscribe(onNext: { [weak self] (message) in
            if let message = message {
                self?.displayErrorMessage(message)
            }

            self?.refreshControl?.endRefreshing()
        }).disposed(by: disposeBag)

        self.bindTableData()
        self.refreshControl?.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0, y: -20), animated: false)
        self.viewModel.reloadCities()
    }

    @objc func refresh() {
        SwiftMessages.hide()
        self.viewModel.reloadCities()
    }

    private func displayErrorMessage(_ message: String) {
        let view = MessageView.viewFromNib(layout: .statusLine)
        view.configureTheme(.error)
        view.configureDropShadow()
        view.configureContent(body: message)
        var config = SwiftMessages.Config()
        config.duration = .forever
        SwiftMessages.show(config: config, view: view)
    }
}

extension CitiesListTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // adding a buffer for grabbing next page, so the user doesn't have to see the new rows inserted into the table. better user experience
        if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section) / 2) // get next page once the user is half way down the current page
            || (indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1) { // sometimes the user scrolls too fast and we miss the halfway point while previous request is still working, if user makes it to bottom of table then get next page.
            self.viewModel.nextPageIfNeeded()
        }
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

        typealias DataType = AnimatableSectionModel<Section, CityCellViewModel>

        let dataSource = RxTableViewSectionedAnimatedDataSource<DataType>(
            configureCell: { _, tableView, indexPath, viewModel in
                let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)

                cell.textLabel?.text = viewModel.titleText
                cell.detailTextLabel?.text = viewModel.subtitleText
                return cell
        })

        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .bottom, reloadAnimation: .none, deleteAnimation: .left)

        tableView.dataSource = nil

        viewModel
            .rxCities
            .map { [weak self] cityViewModels -> [DataType] in
                self?.refreshControl?.endRefreshing()
                SwiftMessages.hide()
                return [AnimatableSectionModel(model: .cities, items: cityViewModels)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
