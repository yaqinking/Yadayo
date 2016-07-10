Project Yadayo（别）

一个图站看图，订阅动画更新提醒，新闻更新提醒的应用。

### 入口

Main.storyboard
YDSiteViewController 站点列表
    已支持的有
        konachan.com
        konachan.net
        yande.re
        moeimg.net
        kisssub.org
        share.dmhy.org

### Danbooru 图站相关

支持站点：

- konachan.com
- konachan.net
- yande.re

Danbooru.storyboard
YDTagsViewController 管理订阅的 tag
YDPhotosViewController tag 显示的缩略图（大图界面使用 MWPhotoBrowser）
YDLocalImageDataSource 本地图片缓存
YDPreloadPhotoManager 预加载图片
YDExportViewController 导出已缓存的图片到 iTunes file sharing 文件夹中方便 copy 到电脑上

### BT 站点新番更新相关

BT.storyboard

### RSS 阅读相关

查看类似 moeimg.net 这些输出全文并且都是图片的站的话，在 Settings/Gallery mode 开启图库浏览模式后，点击条目直接进入单张大图页面，方便只看图。

YDRSSViewController RSS 条目简要显示界面
YDRSSItemViewController RSS 单个条目显示界面
