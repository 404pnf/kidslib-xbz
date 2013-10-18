require 'csv'
require 'erubis'
require 'fileutils'

# ## 多次引用和需要修改的常量
CSVFILE = 'csv/xbz_video.csv'
OUTPUT = 'ouput'
VIEWS = 'views'

# ## csv format
# "id","nid","game","sotry","song","tz","title","unit"
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
# ## 使用方法
#
# 1. 输入的csv文件写死在脚本中了。为了能够方便使用rake生成部署
# 2. rake 查看可执行任务
#
#
# ## 用途
# 从csv每条记录生成对应的html
#
# ----

# ## 需要库
# 为了方便让有ruby但没有gem的环境使用，尽量都使用标准库中的东西。
require 'csv'
require 'fileutils'
require 'erubis'

# ## CSV格式
# 请确保csv文件的header与下面一一对应！
#
#       "title","video","category","age"
#       "穿鞋真舒服"," hb12_music_01","欢乐音乐屋","1-3岁"
#
# 1. 只要把video添加.flv后缀就是视频文件的文件名
# 1. vidoe对应的值也作为文件名，添加.html后缀
# 1. video对应的值是唯一的
# ----

# ## 主程序
# 1. erubis中的@var 名就是csv的header对应的值
# 1. 有些记录有前后空白，需要strip掉
# ----
require 'pp'
class Xbz
  include Enumerable
  def initialize(file)
    aoh = CSV.table(file, converters: nil).map(&:to_hash)
    @h = aoh.map do |h|
      h.keys.each { |k| h[k] = h[k].strip }
      h
    end
  end

  def each_xbz
    @h.each do |e|
      # do not update e here, it will mess up @h
      ee = e.dup
      ee[:id] = e[:id].downcase
      ee[:page_title] = "#{ e[:unit] } #{e[:title]}"
      ee[:book] = "#{ e[:id] }_book_0"
      ee[:quiz] = "#{ e[:id] }_quiz_0"
      [:game, :story, :song, :tz].each { |s| ee[s] = e[s].sub(/\.flv$/, '') }
      yield ee
    end
  end

  [:game, :story, :song, :tz].each do |name|
    define_method(name) do
     @h.each_with_object([]) do |e, o|
        ee = e.dup
        ee = e.select { |k| [:unit, :title, name].include? k }
        ee[:flv] = e[name]
        ee[:filename] = e[name].sub(/.flv$/, '')
        ee[:page_title] = "#{ e[:unit] } #{e[:title]}"
        o << ee
      end
    end
  end

end

# 这里用了 closure 啊 :)
def bind(tpl)
  -> context { Erubis::Eruby.new(File.read(tpl)).evaluate(context) }
end

# views目录后的点 '.' 表示复制该目录下所有内容，但不创建该目录
def copy_asset
  FileUtils.cp_r 'views/.', '_output', verbose: true
end

# ## main
def xbz
  v = Xbz.new 'csv/xbz_video.csv'

  xbz_tpl = bind 'views/xbz-eruby.html'
  v.each_xbz do |e|
    html = xbz_tpl.call e
    p "write _output/html/#{ e[:id] }.html "
    File.write("_output/html/#{ e[:id] }.html", html)
  end
end

def games
  v = Xbz.new 'csv/xbz_video.csv'
  game_tpl = bind 'views/video-eruby.html'
  %w(game story song tz).each do |name|
    v.send(name.intern).each do |e|
      p e
      html = game_tpl.call e
      p "write _output/html/#{ e[:filename] }.html "
      File.write("_output/html/#{ e[:filename] }.html", html)
    end
  end
end

#xbz
#games