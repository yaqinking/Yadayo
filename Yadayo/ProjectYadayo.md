Project Yadayo（别）

主要功能分为 3 个区域
- 入口
    YDSiteViewController 自行添加的站点
        已支持的有
            konachan.com
            konachan.net
            yande.re
            moeimg.net
            kisssub.org
            share.dmhy.org
- Danbooru 图站相关
    YDTagsViewController 管理订阅的 tag
    YDPhotosViewController tag 显示的缩略图（大图界面使用 MWPhotoBrowser）
    YDLocalImageDataSource 本地图片缓存
    YDPreloadPhotoManager 预加载图片
    YDExportViewController 导出已缓存的图片到 iTunes file sharing 文件夹中方便 copy 到电脑上
- BT 站点新番更新相关
- RSS 阅读相关
    YDRSSViewController RSS 条目简要显示界面
    YDRSSItemViewController RSS 单个条目显示界面
