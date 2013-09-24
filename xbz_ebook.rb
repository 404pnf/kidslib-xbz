require 'pp'
require 'csv'
require 'fileutils'

def gen_xbz_book_html(path)
	# get mp3 and jpg tuples
	# [["3b_u9_2.jpg", "3b_u9_2.mp3"], ["3b_u9_3.jpg", "3b_u9_3.mp3"]]
	Dir.ch path
	f = Dir['*.jpg'].sort.zip Dir['*.mp3'].sort
	p "共有图书 #{ f.size } 本"
	Dir.ch __dir__ # 回到脚本执行的目录

	f.each_with_index do |(jpg, mp3), idx|
		unit = jpg.slice(0..4).upcase # 3B_U9 因为xbz的csv文件中unit都是大写
		prev_link = idx == 0 ? nil : idx - 1 # 每课都是3页
		next_link = idx == 2 ? nil : idx + 1
		basename = "#{unit}_book"

		#input = File.read('views/xbzebook-eruby.html')
    #eruby = Erubis::Eruby.new(input)    # create Eruby object
    #book_html =  eruby.result(binding) # get result
    #File.write("output/html/#{basename}_idx.html", book_html)
  end
end
if __FILE__ == $PROGRAM_NAME
	#path = ARGV[0] || 'output/book'
	#p "输入文件是#{ path }"
	#gen_xbz_book_html(path)
end
end