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
        // last cell displayed... get next page
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
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
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.cityCell, for: indexPath)

                cell?.textLabel?.text = viewModel.name
                cell?.detailTextLabel?.text = viewModel.measurements
                return cell ?? UITableViewCell()
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
