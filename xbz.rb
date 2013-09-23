require 'csv'
require 'erubis'
require 'fileutils'

CSVFILE = 'csv/xbz_video.csv'
ERUBY_TPL = 'views/xbz.html.eruby'
OUTPUT = 'ouput'
VIEWS = 'views'

# csv format
# "书名","nid","做游戏","看动画","听儿歌","拓展学习","单元名称","单元编号"
# "1A_U1","99"," xbz1au1_game.flv"," xbz1au1_story.flv"," xbz1au1_song.flv"," xbz1au1_tz.flv","Hello!","Unit 1"
def generate_xbz_html(path)
	CSV.read(path).each do |id, _, game, story, song, tz, title, unit|
    page_title = "#{unit}： #{title}"

    # eruby中的变量名就是 each do 中的对应名字
    # 去掉结尾的flv
    [game, story, song, tz].each { |e| e.sub!(/\.flv$/, ''); e.strip! }
    book = "#{ id }_book"
    quiz = "#{ id }_quiz_0"

	  input = File.read("#{VIEWS}/xbz-eruby.html")
	  eruby = Erubis::Eruby.new(input)    # create Eruby object
	  unit_html =  eruby.result(binding) # get result
	  p "生成 #{ id }.html "
	  File.write("output/#{ id }.html", unit_html)

    [game, story, song, tz].each do |e|
	    flv_url = "flv/#{e}.flv"
	    input = File.read("#{VIEWS}/video-eruby.html")
	    eruby = Erubis::Eruby.new(input)    # create Eruby object
	    video_html =  eruby.result(binding) # get result
	    p "生成 #{ e }.html "
	    File.write("output/#{ e }.html", video_html)
	  end
	end
end

def copy_asset_to_output
	# If you want to copy all contents of a directory instead of the
	# directory itself, c.f. src/x -> dest/x, src/y -> dest/y,
	# use following code.
	# cp_r('src', 'dest') makes dest/src,
	# but this doesn't.
	FileUtils.cp_r 'views/.', 'output', :verbose => true
end

if __FILE__ == $PROGRAM_NAME
  path = ARGV[0] || CSVFILE
  p "输入文件是#{ path }"
  generate_xbz_html(path)
  copy_asset_to_output
end
