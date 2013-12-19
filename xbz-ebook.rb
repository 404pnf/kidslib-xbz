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

# ## 主函数
# TODO FIXME
#
# 写得很不好。拘泥于过程。需要修改
3
# ----
def gen_xbz_book_html(path)
  # get mp3 and jpg tuples
  #
  # [["3b_u9_2.jpg", "3b_u9_2.mp3"], ["3b_u9_3.jpg", "3b_u9_3.mp3"]]
  f = Dir.chdir(path) {
        Dir['*.jpg'].sort.zip Dir['*.mp3'].sort

      } # Dir.chdir path {} 在path中执行{}中命令但不切换目录
  p "共有图书 #{ f.size } 本"

  # 书名是文件名的前5个字符(0..4)。
  # 用它作为键，构建所有图书的hash
  h = Hash.new { |hash, key| hash[key] = [] }
  f.each_with_object(h) do |(jpg, mp3), o|
    bookid = jpg.slice(0..4).to_sym
    o[bookid] << [jpg, mp3]
  end

  # 先看看这本书一共有几页, page.size 。
  #
  # 再根据当前页面来决定是否有上一页和下一页。
  h.each do |unit, pages|
    len = pages.size
    pages.each_with_index do |(jpg, mp3), idx|
      basename = "#{ unit.downcase }_book"
      prev_link = idx == 0 ? nil : "#{basename}_#{ idx - 1}.html"
      next_link = idx == 2 ? nil : "#{basename}_#{ idx + 1}.html"

      input = File.read('views/xbzebook-eruby.html')
      eruby = Erubis::Eruby.new(input)    # create Eruby object
      book_html =  eruby.result(binding) # get result
      p "output/html/#{basename}_#{idx}.html"
      File.write("output/html/#{basename}_#{idx}.html", book_html)
    end
  end
end

# ## 干活
def xbz_ebok
  path = 'output/book'
  p "输入文件是#{ path }"
  gen_xbz_book_html(path)
end
