require 'csv'
require 'erubis'
require 'fileutils'
require 'pp'

CSVFILE = 'csv/quiz-all-update.csv'
ERUBY_TPL = 'views/quiz-eruby.html'
OUTPUT = 'ouput'
VIEWS = 'views'

# ## CSV的格式
# 每条记录有一个图片，一个音频，但答案选项有4个，用英文逗号分开。
#
#     "title","nid","pic","audio","answer","unit_id"
#     "2BU2_six","315","2BU2_six.jpg"," 2BU2_six.mp3","six, three, seven, five","2B_U2"
#
# ----



# ## 主函数
# FIXME TODO
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
# ### 难点
# 1. 先把对应相同单元的quiz按文件名命名规则收集在一起
# 1. 每课可以对应多个quiz。因此quiz页面需要分页，并计算是否有上一页和下一页。
# 1. 选项需要乱序
# 1. 正确选项和错误选项对应的css class不同
# ----
def generate_quiz_html(path)
  hash = Hash.new { |h, k| h[k] = [] }
  c = CSV.read(path)
  # 这里应该改为 CSV.table(path, converters: nil)
  # 然后用e[:unit_id]
  # csv的header是   "书名","nid","图片","音频","答案选项","unit_id"
  # 所以e[5]对应 'unit_id'
  c.each_with_object(hash) { |e, o| hash[e[5]] << e }
  hash.each do |unit_idx, q |
    len = q.size
    unit_id = unit_idx.downcase
    q.each_with_index do |(shuming, nid, pic, mp3, choices, unit), idx|
      page_title = "#{unit_id}"
      pic.strip!.gsub!(/[' ]/, '_')
      mp3.strip!.gsub!(/[' ]/, '_')
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
      eruby = Erubis::Eruby.new(input)
      quiz_html =  eruby.result(binding)
      p "生成 #{ unit_id }_quiz_#{ idx }.html "
      File.write("#{OUTPUT}/html/#{ unit_id }_quiz_#{ idx }.html", quiz_html)
    end
  end
end

# 复制静态资源到output
def copy_asset_to_output
  FileUtils.cp_r 'views/.', "#{OUTPUT}", :verbose => true
end

# ## 干活
if __FILE__ == $PROGRAM_NAME
  path = ARGV[0] || CSVFILE
  p "输入文件是#{ path }"
  generate_quiz_html(path)
  #copy_asset_to_output
end
