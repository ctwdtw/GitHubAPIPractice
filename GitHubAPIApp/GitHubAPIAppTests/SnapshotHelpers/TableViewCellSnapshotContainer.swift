//
//  TableViewCellSnapshotContainer.swift
//  GitHubAPIAppTests
//
//  Created by Paul Lee on 2021/11/12.
//

import UIKit

final class TableViewCellSnapshotContainer<Cell: UITableViewCell>: UIView, UITableViewDataSource, UITableViewDelegate {
    
    enum DeviceWidth: CGFloat {
        case iPhone11 = 414
    }
    
    private lazy var tableView: SnapshotTableView = {
       let tableView = SnapshotTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(Cell.self, forCellReuseIdentifier: snapshotCell)
    
        return tableView
    }()
    
    typealias CellConfigurator = (_ cell: Cell) -> ()
    
    typealias HeightResolver = ((_ width: CGFloat) -> (CGFloat))
    
    private let cellConfigurator: ((Cell) -> ())
    
    private let heightResolver: HeightResolver?
    
    private let snapshotCell = "snapshotCell"
    
    init(width: DeviceWidth, heightForWidth: HeightResolver? = nil, cellConfigurator: @escaping CellConfigurator) {
        self.cellConfigurator = cellConfigurator
        self.heightResolver = heightForWidth
        
        super.init(frame: .zero)
        
        _ = tableView
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width.rawValue),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 1.0)
        ])
        
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: snapshotCell, for: indexPath) as! Cell
        
        cellConfigurator(cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightResolver?(frame.width) ?? UITableView.automaticDimension // 4
    }
}

private class SnapshotTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        separatorStyle = .none
        contentInset = .zero
        tableFooterView = UIView()
        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
