require 'csv'
require 'erubis'
require 'fileutils'


#  多次引用和需要修改的常量
CSVFILE = 'csv/xbz_video.csv'
OUTPUT = 'ouput'
VIEWS = 'views'

# ## csv format
# "书名","nid","做游戏","看动画","听儿歌","拓展学习","单元名称","单元编号"
#
#     "1A_U1","99"," xbz1au1_game.flv"," xbz1au1_story.flv"," xbz1au1_song.flv"," xbz1au1_tz.flv","Hello!","Unit 1"
#
# 每一个flv文件和mp3文件都会生成单独的html页面。
# 这些页面使用 video-eruby.html 模版。
#
# 同时，每条记录会生成一个聚合页面有链接到各个单独html页面。
# 这个页面使用 xbz-eruby.html 模版
#
# ----

# ## 主函数。
# 写得很不好。过于拘泥步骤了。
#
# TODO; FIXME
#
def generate_xbz_html(path)
  CSV.read(path).each do |id, _, game, story, song, tz, title, unit|
    page_title = "#{unit} #{title}"
    p page_title
    id.downcase!
    # eruby中的变量名就是 each do 中的对应名字。
    # 去掉结尾的flv。
    # 这里采用直接修改变量的方法sub!和strip!。
    [game, story, song, tz].each { |e| e.sub!(/\.flv$/, ''); e.strip! }
    # 因为book和quiz都是多页的
    # 因此我们这里链接到第0页。
    book = "#{ id }_book_0"
    quiz = "#{ id }_quiz_0"

    # 生成每课的聚合页面
    input = File.read("#{VIEWS}/xbz-eruby.html")
    eruby = Erubis::Eruby.new(input)
    unit_html =  eruby.result(binding)
    p "生成 #{ id }.html "
    File.write("#{OUTPUT}/html/#{ id }.html", unit_html)

    # 生成游戏，动画，儿歌，拓展的单独页面
    [game, story, song, tz].each do |e|
      flv_url = "../flv/#{e}.flv"
      input = File.read("#{VIEWS}/video-eruby.html")
      eruby = Erubis::Eruby.new(input)
      video_html =  eruby.result(binding)
      p "生成 #{ e }.html "
      File.write("#{OUTPUT}/html/#{ e }.html", video_html)
    end
  end
end

# 使用 'views/.' 会复制views目录下的所有文件，但不会创建views目录
def copy_asset_to_output
  FileUtils.cp_r 'views/.', 'output', :verbose => true
end

# ## 干活
if __FILE__ == $PROGRAM_NAME
  path = ARGV[0] || CSVFILE
  p "输入文件是#{ path }"
  generate_xbz_html(path)
  copy_asset_to_output
end
