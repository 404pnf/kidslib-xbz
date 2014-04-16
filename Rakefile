require_relative 'xbz-oop.rb'
require_relative 'quiz-oop.rb'
# require_relative 'xbz-ebook.rb'
require_relative 'ebook-oop.rb'

# ## a timer
def time(&block)
  t = Time.now
  result = block.call
  puts "\nCompleted in #{(Time.now - t)} seconds\n\n"
  result
end

desc "help msg"
task :help do
  system('rake -T')
end

desc "generate quiz"
task :quiz do
  time { quiz }
end

desc "generate xbz"
task :gen do
  time { xbz }
  time { games }
  copy_asset
end

desc "generate xbz-ebook"
task :ebook do
  time { xbz_ebook }
end

desc "deploy"
task :deploy do
  system("rsync -avz output/* tufu:/var/www/kidslib.fltrp.com/asset/xbz/")
  puts "\n\n同步到服务器了"
end

desc "generate and deploy"
task :all => [:gen, :deploy] do
  puts "\nRake: 生成html并部署到服务器了。"
end

desc "preview html"
task :preview do
  system("python -m SimpleHTTPServer")
end

desc "generating docs"
task :doc do
  system("docco *.rb")
end

desc "show stats of line of code "
task :loc do
  system("cloc *.rb")
end

desc "run robocop"
task :cop do
  system("rubocop *.rb")
end

task :default => [:help, :doc, :cop, :loc]
