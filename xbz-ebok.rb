require 'pp'
require 'csv'
require 'fileutils'
require 'erubis'

def gen_xbz_book_html(path)
	# get mp3 and jpg tuples
	# [["3b_u9_2.jpg", "3b_u9_2.mp3"], ["3b_u9_3.jpg", "3b_u9_3.mp3"]]
	Dir.chdir path
	f = Dir['*.jpg'].sort.zip Dir['*.mp3'].sort
	p "共有图书 #{ f.size } 本"
	Dir.chdir __dir__ # 回到脚本执行的目录
	#p f
	h = Hash.new { |hash, key| hash[key] = [] }
	f.each_with_object(h) do |(jpg, mp3), o|
		bookid = jpg.slice(0..4).to_sym
		o[bookid] << [jpg, mp3]
	end
	#p h
	h.each do |unit, pages|
		len = pages.size
		pages.each_with_index do |(jpg, mp3), idx|
			basename = "#{unit}_book"
			prev_link = idx == 0 ? nil : "#{basename}_#{ idx - 1}.html"
			next_link = idx == 2 ? nil : "#{basename}_#{ idx + 1}.html"

			input = File.read('views/xbzebook-eruby.html')
	    eruby = Erubis::Eruby.new(input)    # create Eruby object
	    book_html =  eruby.result(binding) # get result
	    File.write("output/html/#{basename}_#{idx}.html", book_html, verbose: true)
	    #p book_html
	  end
  end
end
if __FILE__ == $PROGRAM_NAME
	path = ARGV[0] || 'output/book'
	p "输入文件是#{ path }"
	gen_xbz_book_html(path)
end
