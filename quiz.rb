require 'csv'
require 'erubis'
require 'fileutils'
require 'pp'

CSVFILE = 'csv/quiz-all-update.csv'
ERUBY_TPL = 'views/quiz-eruby.html'
OUTPUT = 'ouput'
VIEWS = 'views'

# csv format
# "书名","nid","图片","音频","答案选项","unit_id"
def generate_quiz_html(path)
	hash = Hash.new { |h, k| h[k] = [] }
	c = CSV.read(path)
	c.each_with_object(hash) { |e, o| hash[e[5]] << e }
	hash.each do |unit_idx, q |
		len = q.size
		unit_id = unit_idx.downcase
		q.each_with_index do |(shuming, nid, pic, mp3, choices, unit), idx|
    	page_title = "#{unit_id}"
    	pic.gsub!(/'/, '_')
    	pic.gsub!(/ /, '_')
			mp3.strip!
			mp3.gsub!(/'/, '_') # 之前有文件名字中有单引号
			mp3.gsub!(/ /, '_')
			answers = choices.split(',')
			choice_str = <<eof
				<li><a href='#' onclick='onclick_right();'>#{answers[0]}</a></li>
				<li><a href='#' onclick='onclick_wrong();'>#{answers[1]}</a></li>
				<li><a href='#' onclick='onclick_wrong();'>#{answers[2]}</a></li>
				<li><a href='#' onclick='onclick_wrong();'>#{answers[3]}</a></li>
eof
			randomized_choices = choice_str.split(/\n/).shuffle.join("\n")
			prev_q = if idx == 0
					nil
				else
			 	"<a href='#{unit_id}_quiz_#{idx - 1}.html' class='pre font_mrosoftYHB fleft'>上一题</a>"
				end
			next_q = if idx + 1 == len
					nil
				else
				  "<a href='#{unit_id}_quiz_#{idx + 1}.html' class='next font_mrosoftYHB fleft'>下一题</a>"
				end
			input = File.read("#{VIEWS}/quiz-eruby.html")
		  eruby = Erubis::Eruby.new(input)    # create Eruby object
		  quiz_html =  eruby.result(binding) # get result
		  p "生成 #{ unit_id }_quiz_#{ idx }.html "
		  File.write("output/html/#{ unit_id }_quiz_#{ idx }.html", quiz_html)
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
  generate_quiz_html(path)
  #copy_asset_to_output
end
