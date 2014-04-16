require 'pp'
require 'csv'
require 'fileutils'
require 'erubis'

# ## 说明
# 新标准的图书每页是一个jpg，并且有对应的mp3。它们统一放在某文件夹中。
#
# 我们去遍历那个文件夹，根据文件名称确定书名，并把同一本书的jpg和mp3收集在一起
#
# 之后我们生成可翻页的图书，每页都会自动播放对应的mp3。实现方式看erubis模版。
#
# ----
# 为了封装
class XbzEbook
  def self.files_to_tuples(path)
    # get mp3 and jpg tuples
    #
    # [["3b_u9_2.jpg", "3b_u9_2.mp3"], ["3b_u9_3.jpg", "3b_u9_3.mp3"]]
    f = Dir.chdir(path) { Dir['*.jpg'].sort.zip Dir['*.mp3'].sort }
    p "共有图书 #{ f.size } 本"
    f
  end

  def self.getbookid(str)
    # 开始认为书名是前5个字符
    # 大错特错
    # 书名可能是 1a_u12 也就是前6个字符，或者更多，太坑爹了 ！！
    # a.map { |e| e.split(/(_)/) }
    # => [["3b", "_", "u9", "_", "3.jpg"], ["3b", "_", "u11", "_", "31.jpg"]]
    str.split(/(_)/)[0..2].join.to_sym
  end

  def self.tuples2hash(tup)
    # 用书名作为键，构建所有图书的hash
    h = Hash.new { |hash, key| hash[key] = [] }
    tup.each_with_object(h) do |(jpg, mp3), o|
      o[getbookid(jpg)] << [jpg, mp3]
    end
    # p h
    h
  end

  def self.gen_xbz_book_html(path)
    # 先看看这本书一共有几页, page.size 。
    #
    # 再根据当前页面来决定是否有上一页和下一页。
    tuples2hash(files_to_tuples(path)).each do |unit, pages|
      # len = pages.size
      pages.each_with_index do |(jpg, mp3), idx|
        basename = "#{ unit.downcase }_book"
        prev_link = idx == 0 ? nil : "#{basename}_#{ idx - 1}.html"
        next_link = idx == 2 ? nil : "#{basename}_#{ idx + 1}.html"

        input = File.read('views/xbzebook-eruby.html')
        eruby = Erubis::Eruby.new(input)    # create Eruby object
        book_html =  eruby.result(binding) # get result
        # p "output/html/#{basename}_#{idx}.html"
        File.write("output/html/#{basename}_#{idx}.html", book_html)
      end
    end
  end
end

# ## 干活
def xbz_ebook
  XbzEbook.gen_xbz_book_html 'output/book'
end
