//
//  SearchResultsViewController.swift
//  MusicApp
//
//  Created by 松尾卓磨 on 2020/10/21.
//  Copyright © 2020 松尾卓磨. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
protocol CatchVideoID {
    func CatchVideoIdAndPlayVideo(Id:String)
}
class SearchResultsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    
    private let searchModel = SearchModel()
    var videotitleArray = [String()]
    var videoImageArray = [String()]
    var videoIdArray = [String()]
    var searchWord = String()
    var nextPageToken = String()
    var prevPageToken = String()
    var url = String()
    
    

    @IBOutlet weak var searchResultsTabelView: UITableView!
    
    @IBOutlet weak var NextButton: UIButton!
    @IBOutlet weak var PrevButton: UIButton!
    var delegate:CatchVideoID?
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultsTabelView.delegate = self
        searchResultsTabelView.dataSource = self
        searchResultsTabelView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        //delegate?.CatchVideoIdAndPlayVideo(Id: "")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nextPageToken == "" {
            NextButton.isHidden = true
        }else{
            NextButton.isHidden = false
        }
        if prevPageToken == "" {
            PrevButton.isHidden = true
        }else{
            PrevButton.isHidden = false
        }
        
        return videotitleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        Cell.delegate = self
        Cell.videoImage.sd_setImage(with: URL(string: videoImageArray[indexPath.row]), completed: nil)
        Cell.videoTitle.text = videotitleArray[indexPath.row]
        Cell.playlistButton.tag = indexPath.row
        let plusOrDelete = Cell.playlistModel.searchMusic(id: videoIdArray[indexPath.row])
        if plusOrDelete {//true -> playlistにある　false -> playlistにない
            Cell.playlistButton.setImage(UIImage(systemName: "delete.left"), for: .normal)
        }else{
            Cell.playlistButton.setImage(UIImage(systemName: "plus"), for: .normal)
        }
        return Cell
    }
    
    
    //cellがタップされたときのメソッドを探す//↓のメソッド
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //タップされたcellを判定して、VideoArrayの中からvideoIDを以前の
        let videoId:String = videoIdArray[indexPath.row]
        delegate?.CatchVideoIdAndPlayVideo(Id: videoId)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextButtonPushed(_ sender: Any) {
        url = searchModel.makeSearchUrl(word:searchWord,pageToken:nextPageToken)
        reload()
    }
    
    @IBAction func prevButtonPushed(_ sender: Any) {
        url = searchModel.makeSearchUrl(word: searchWord, pageToken: prevPageToken)
        reload()
    }
    
    func reload() -> Void {
        AF.request(url,method: .get,parameters: nil,encoding: JSONEncoding.default).responseJSON { (res) in
            switch res.result{
            case .success:
                let json:JSON = JSON(res.data as Any)
                let trueOrFalse = self.searchModel.StartParse(json: json)
                if trueOrFalse {
                    self.videotitleArray = self.searchModel.titleArray
                    self.videoImageArray = self.searchModel.videoImageArray
                    self.videoIdArray = self.searchModel.videoIDArray
                    self.searchWord = self.searchModel.word
                    self.nextPageToken = self.searchModel.nextPageToken
                    self.prevPageToken = self.searchModel.prevPageToken
                    self.searchResultsTabelView.reloadData()
                }else{
                    print("json解析でエラーが発生しました")
                }
            case .failure(_):
                print("エラー")
            }
        }
    }
}

extension SearchResultsViewController:CatchVideoInfoDelegate{
    func catchVideoInfo(at: Int) -> (id:String,title:String,image:String) {
        let id = self.videoIdArray[at]
        let title = self.videotitleArray[at]
        let image = self.videoImageArray[at]
        let videoInfo = (id:id,title:title,image:image)
        return videoInfo
    }
    
    
}
