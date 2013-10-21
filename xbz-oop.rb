
# ## 使用方法
# 命令行运行 rake 查看。
#
# ----

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
# 1. 从csv每条记录生成对应的xbz聚合页面html
# 1. 从csv每条记录生成对应的4个xbz课程内容页面html
# ----

# ## 需要库
# 为了方便让有ruby但没有gem的环境使用，尽量都使用标准库中的东西。
require 'csv'
require 'fileutils'
require 'erubis'
# ----

# ## 主程序
# 1. erubis中的@var 名就是csv的header对应的值或者在类里面准备的值
# 1. 有些记录有前后空白，需要strip掉
# ----
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
      ee[:book] = "#{ ee[:id] }_book_0"
      ee[:quiz] = "#{ ee[:id] }_quiz_0"
      [:game, :story, :song, :tz].each { |s| ee[s] = e[s].sub(/\.flv$/, '') }
      yield ee
    end
  end

  # 后面代码会对下面方法返回的值调用each方法绑定模版
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
  FileUtils.cp_r 'views/.', 'output', verbose: true
end

# ## main
def xbz
  v = Xbz.new 'csv/xbz_video.csv'

  xbz_tpl = bind 'views/xbz-eruby.html'
  v.each_xbz do |e|
    html = xbz_tpl.call e
    p "write output/html/#{ e[:id] }.html "
    File.write("output/html/#{ e[:id] }.html", html)
  end
  copy_asset
end

def games
  v = Xbz.new 'csv/xbz_video.csv'
  game_tpl = bind 'views/video-eruby.html'
  %w(game story song tz).each do |name|
    v.send(name.intern).each do |e|
      html = game_tpl.call e
      p "write output/html/#{ e[:filename] }.html "
      File.write("output/html/#{ e[:filename] }.html", html)
    end
  end
  copy_asset
end
