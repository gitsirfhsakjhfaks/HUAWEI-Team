@Entry
@Component
struct BZ {
  build() {
    Column() {
      Column() {
        // 图片区域
        Stack() {
          Image($r('app.media.bz_img'))
            .width('100%')
            .height('100%')           // 新增：让图片填满 Stack
            .objectFit(ImageFit.Cover)

          // 视频信息栏
          Row() {
            // 播放量
            Row() {
              Image($r('app.media.player'))  // 播放图标
                .width(14)
                .height(18)
                .margin({ right: 4 })
                .fillColor(Color.White)
              Text('288万')
                .fontSize(12)
                .height(20)
                .fontColor(Color.White)
            }
            .margin({ right: 10 })

            // 评论数
            Row() {
              Image($r('app.media.msg'))   // 评论图标
                .width(14)
                .height(15)
                .margin({ right: 4 })
                .fillColor(Color.White)
              Text('8655')
                .fontSize(12)
                .height(20)
                .fontColor(Color.White)
            }
            // .height(24)    // 显式设置高度为 24vp
            // .padding(5)    // 设置内边距为 5vp


            Blank()  // 填充剩余空间

            // 视频时长
            Text('4:33')
              .fontSize(12)
              .height(20)
              .fontColor(Color.White)
          }
          .width('100%')
          .height(24)
          .padding(8)
          .backgroundColor('#00000000') // 透明背景
          .alignItems(VerticalAlign.Center)
        }
        .alignContent(Alignment.Bottom) // 关键样式
        .padding(8)
        .width(200)      // 显式设置封面宽度为 200vp
        .height(125)     // 显式设置封面高度为 125
        // .aspectRatio(1.78)  // 注释或删除原有比例约束

        // 文字区域
        Column() {
          Text('【凤凰传奇新歌】欢迎来到国风统治区：唢呐一响神曲《铁衣流派推广曲》')
            .fontSize(14)
            .fontColor('#333')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .height(32)
            .margin({ bottom: 8 })

          // 点赞和更多
          Row() {
            Text('19万点赞')
              .fontSize(12)
              .fontColor('#e66c43')
              .backgroundColor('#fef0ef')
              .padding(3)
              .borderRadius(12)

            Blank()  // 弹性填充

            Image($r('app.media.more'))  // 更多图标
              .width(14)
              .margin({ right: 4 })
          }
          .width('100%')
        }
        //.height(16)    // 显式设置高度为 16vp
      }
      .width(200)//
      .height(200)
      .borderRadius(12)
      .backgroundColor(Color.White)
      .shadow({ radius: 6, color: '#10000000', offsetX: 2, offsetY: 2 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}