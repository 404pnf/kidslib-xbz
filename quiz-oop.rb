require 'csv'
require 'erubis'
require 'fileutils'
require 'pp'

# ## CSV的格式
# 每条记录有一个图片，一个音频，但答案选项有4个，用英文逗号分开。
#
#     "title","nid","pic","mp3","answer","unit_id"
#     "2BU2_six","315","2BU2_six.jpg"," 2BU2_six.mp3","six, three, seven, five","2B_U2"
#
# ----

# ## 主函数
# FIXME
# TODO
#
# 相当基于步骤。相当不好。且选项的乱序是在脚本中混合了变量和html。真是相当丑陋啊。
#
# 更好的方法是把选项作为
#
#     [{answer: 'uncle', correct?: true} {answer: 'aunt', correct?: false}]
#
# 然后在模版中用
#
#     <li class="<% a[:correct?] ? 'correct-anser' : 'wrong-anser' "><%= a[:anser]></li>
#
# ### 难点
# 1. 先把对应相同单元的quiz按文件名命名规则收集在一起
# 1. 每课可以对应多个quiz。因此quiz页面需要分页，并计算是否有上一页和下一页。
# 1. 选项需要乱序
# 1. 正确选项和错误选项对应的css class不同
# ----

class Quiz
  def initialize(file)
    aoh = CSV.table(file, converters: nil).map(&:to_hash)
    @h = aoh.map do |h|
    	h[:unit_id] = h[:unit_id].downcase
    	h[:answer] = h[:answer].gsub(' ', '') # 每个答案之前有空格，先去掉否则后面替换为下划线了
      h.keys.each { |k| h[k] = h[k].strip.gsub(/[' ]/, '_') }
      h
    end
  end

  # csv headers
  # "title","nid","pic","mp3","answer","unit_id"
  def units
    @units = Hash.new { |h, k| h[k] = [] }
    @h.each_with_object(@units) do |e, o|
      o[e[:unit_id]] << e
    end
    # p @units.keys
  end


  # k is 1b_u11"
  # v is
  #
  #        [{:title=>"1BU11_blocks", :nid=>"390", :pic=>"1BU11_blocks.jpg", :mp3=>"1BU11_blocks.mp3", :answer=>"blocks,_puppet,_doll,_car", :unit_id=>"1b_u11"}, {:title=>"1BU11_doll", :nid=>"391", :pic=>"1BU11_doll.jpg", :mp3=>"1BU11_doll.mp3", :answer=>"doll,_puppet,_car,_girl", :unit_id=>"1b_u11"}, {:title=>"1BU11_friend", :nid=>"392", :pic=>"1BU11_friend.jpg", :mp3=>"1BU11_friend.mp3", :answer=>"friend,_boy,_girl,_child", :unit_id=>"1b_u11"}]
  def each_quiz
    self.units.each do|k, v|
      len = v.size

      v.each_with_index do |h, idx|
        context = h.dup
        context[:idx] = idx
        context[:page_title] = h[:unit_id]
        #context[:answers] = h[:answer].split(',')
        ans = h[:answer].split(',')
        tmp = ans.map { |e| ['onclick_wrong();', e] }
        tmp[0][0] = 'onclick_right();' # 第一个答案是正确答案
        context[:answers] = tmp.shuffle
        # anssers的格式是 [ [css1, answer1], [css2, answer2], .. ]

#         choice_str = <<eof
#           <li><a href='#' onclick='onclick_right();'>#{ context[:answers][0] }</a></li>
#           <li><a href='#' onclick='onclick_wrong();'>#{ context[:answers][1] }</a></li>
#           <li><a href='#' onclick='onclick_wrong();'>#{ context[:answers][2] }</a></li>
#           <li><a href='#' onclick='onclick_wrong();'>#{ context[:answers][3] }</a></li>
# eof
        #context[:randomized_choices] = choice_str.split(/\n/).shuffle.join("\n")
        #context[:prev_q] = idx == 0 ? nil : "<a href='#{ h[:unit_id] }_quiz_#{ idx - 1 }.html' class='pre font_mrosoftYHB fleft'>上一题</a>"
        #context[:next_q] = idx + 1 == len ? nil :  "<a href='#{ h[:unit_id] }_quiz_#{ idx + 1 }.html' class='next font_mrosoftYHB fleft'>下一题</a>"
      	context[:prev_q] = (idx == 0 ? false : true)
        context[:next_q] = (idx + 1 == len ? false : true )
        yield context
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

# ## 干活
def quiz
  q = Quiz.new 'csv/quiz-all-update.csv'
  tpl = bind 'views/quiz-eruby.html'
  q.each_quiz do |e|
    quiz_html = tpl.call e
    p "生成 _output/html/#{ e[:unit_id] }_quiz_#{ e[:idx] }.html "
    File.write("_output/html/#{ e[:unit_id] }_quiz_#{ e[:idx] }.html", quiz_html)
  end
  copy_asset
end
quiz
